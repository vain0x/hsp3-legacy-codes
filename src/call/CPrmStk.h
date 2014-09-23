// prmstk クラス

/**
HSP の prmstk と同じ形式でデータを格納するコンテナ。

prmstk の内部形式を参照するすべての機能をここに閉じ込める。
prmstk バッファ、str 引数、値渡しされた any 引数用の PVal、flex 用の vector、local 変数を管理する機能を持つ。
動的な値(prmtype)によって型が決まるという、かなりナイーブな仕様なので、扱いに注意する。

バッファは「引数部」「終端部」の2つから成る。
「引数部」は与えられた実引数を積んでいく部分。
「終端部」は、すべての実引数の後に、コードから実引数を受け取らなくていい仮引数タイプに対応する領域を積んでいく部分。
	具体的には、PrmType::Capture, PrmType::Local, PrmType::Flex のための領域が(この順で)積まれる。
なおバッファは固定長であり、仮引数の時点でサイズが確定している。

idx は flex を含まない。
todo: 与えられた MPVarData (Managed かもしれない) を所有するべき
todo: ManagedBuffer (strbuf ポインタを参照カウンタ方式で管理)
todo: 引数取り出し部分(Invoker)と2重で prmtype を参照するのがもったいない感じ。
//*/

#ifndef IG_CLASS_PARAMETER_STACK_CREATOR_MANAGED_H
#define IG_CLASS_PARAMETER_STACK_CREATOR_MANAGED_H

#include <vector>

#include "hsp3plugin_custom.h"
#include "CPrmInfo.h"
#include "CPrmStkCreator.h"
#include "ManagedPVal.h"

#include "../var_vector/vt_vector.h"

namespace ArgInfoId
{
	static int const
		IsVal = 0,
		IsRef = 1,
		IsMod = 2,
		Ptr = 3
		;
}

class CPrmStk;
using arguments_t = CPrmStk;

//------------------------------------------------
// 高級な prmstk 
//------------------------------------------------
class CPrmStk
	: private CPrmStkCreator
{
private:
	CPrmInfo const& prminfo_;

	// 現在、追加された実引数の個数 (flex は除く)
	size_t cntArgs_;

	// 終端部が追加されたか否か
	bool finalized_;

	using super_t = CPrmStkCreator;

	// ヘッダ
	struct header_t {
		unsigned short magicCode;
	};
	static size_t const headerSize = sizeof(header_t);
	static int const MagicCode = 0x55AC;

public:
	CPrmStk(CPrmInfo const& prminfo);
	~CPrmStk() { free(); }

	void* getPrmStkPtr() { return super_t::getptr(); }
	void const* getPrmStkPtr() const { return super_t::getptr(); }

	size_t cntArgs() const { return cntArgs_; }
	bool hasFinalized() const { return finalized_; }

	CPrmInfo const& getPrmInfo() const { return prminfo_; }
	int getNextPrmType() const {
		return prminfo_.getPrmType(cntArgs());
	}

	void incCntArgs() { ++cntArgs_; }

	static bool hasMagicCode(void* prmstk) {
		return (getHeader(prmstk).magicCode == MagicCode);
	}
private:
	static header_t& getHeader(void* prmstk) {
		return reinterpret_cast<header_t*>(prmstk)[-1];
	}

public:
	//------------------------------------------------
	// 実引数値の push 各種
	//------------------------------------------------
	// 単純な値
	template<typename VtTag>
	void pushValue(PDAT const* pdat)
	{
		assert(!hasFinalized());
		int const prmtype = getNextPrmType();
		assert(prmtype == VtTraits::Impl::vartype<VtTag>() && prmtype != HSPVAR_FLAG_STR);

		incCntArgs();
		super_t::pushValue(VtTraits::derefValptr<VtTag>(pdat));
		return;
	}
	template<> void pushValue<vtStr>(PDAT const* pdat);

	// 文字列
	void pushString(char const* src);

	// any
	void pushAnyByVal(PDAT const* pdat, hpimod::vartype_t vtype);
	void pushAnyByRef(PVal* pval, APTR aptr);

	// 変数参照
	void pushPVal(PVal* pval, APTR aptr);
	void pushPVal(PVal* pval);
	void pushThismod(PVal* pval, APTR aptr);

	void importCaptures(vector_t const& captured);
	void finalize();

	//------------------------------------------------
	// 実引数値の動的な push
	//------------------------------------------------
	void pushArgByVal(PDAT const* pdat, vartype_t vtype);
	void pushArgByRef(PVal* pval, APTR aptr);
	void pushArgByDefault();
	void allocArgNoBind(unsigned short magiccode, unsigned short priority);

	//------------------------------------------------
	// 実引数値の peek 各種
	//------------------------------------------------
	
	// 値 or any(byVal)
	// local や参照渡し引数の値は取り出さない。
	PDAT* peekValArgAt(size_t idx, vartype_t& vtype) const;

	// 変数
	PVal* peekRefArgAt(size_t idx) const;

	ManagedVarData peekAnyAt(size_t idx) const
	{
		assert( idx < cntArgs() );
		assert(prminfo_.getPrmType(idx) == PrmType::Any);
		return ManagedVarData { *reinterpret_cast<MPVarData*>(getArgPtrAt(idx)) };
	}

	MPVarData* peekCaptureAt(size_t idx) const
	{
		assert(hasFinalized());
		return reinterpret_cast<MPVarData*>(getOffsetPtr(prminfo_.getStackOffsetCapture(idx)));
	}
	PVal* peekLocalAt(size_t idx) const
	{
		assert(hasFinalized());
		return reinterpret_cast<PVal*>(getOffsetPtr(prminfo_.getStackOffsetLocal(idx)));
	}
	vector_t* peekFlex() const
	{
		return ( prminfo_.isFlex() && hasFinalized() ) 
			? reinterpret_cast<vector_t*>(getOffsetPtr(prminfo_.getStackOffsetFlex()))
			: nullptr;
	}

private:
	//------------------------------------------------
	// prmstk 上へのポインタ
	//------------------------------------------------
	void* getOffsetPtr(size_t offset) const {
		assert(offset <= size());
		return &reinterpret_cast<char*>(getptr())[ offset ];
	}
	void* getArgPtrAt(size_t idx) const
	{
		assert(idx < cntArgs());
		return getOffsetPtr(prminfo_.getStackOffsetParam(idx));
	}

	void free();
};

#endif
