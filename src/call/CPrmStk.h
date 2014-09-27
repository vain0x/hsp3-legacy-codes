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
todo: 引数取り出し部分(Caller)と2重で prmtype を参照するのがもったいない感じ。
//*/

#ifndef IG_CLASS_PARAMETER_STACK_MANAGED_H
#define IG_CLASS_PARAMETER_STACK_MANAGED_H

#include <vector>
#include <memory>

#include "hsp3plugin_custom.h"
#include "CPrmInfo.h"
#include "CPrmStkNative.h"
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

class CBound;
class CPrmStk;
using arguments_t = hpimod::Managed<CPrmStk, true>;

//------------------------------------------------
// 高級な prmstk 
//------------------------------------------------
class CPrmStk
{
private:
	struct Impl;
	std::shared_ptr<Impl> p_;

	// ヘッダ
	static int const MagicCodeNoBind = 0x55AD;

public:
	CPrmStk(CPrmInfo const& prminfo);
	~CPrmStk() { free(); }

	CPrmInfo const& getPrmInfo() const;
	prmtype_t getNextPrmType() const;
	CPrmStkNative const& getPrmStk() const;
	void* getPrmStkPtr();
	size_t cntArgs() const;
	bool hasFinalized() const;

	CPrmStkNative& getPrmStk() { return const_cast<CPrmStkNative&>(static_cast<CPrmStk const*>(this)->getPrmStk()); }

	static CPrmStk* ofPrmStkPtr(void* prmstk);
public:
	// copy/move/swap
	CPrmStk(CPrmStk const& rhs);
	CPrmStk(CPrmStk&& rhs) : p_ { std::move(rhs.p_) } { }

	CPrmStk& swap(CPrmStk& rhs) _NOEXCEPT { std::swap(p_, rhs.p_); return *this; }
	CPrmStk& operator=(CPrmStk rhs) { return this->swap(rhs); }

public:
	//------------------------------------------------
	// 実引数値の push 各種
	//------------------------------------------------
	// 単純な値
	template<typename VtTag>
	void pushValue(PDAT const* pdat);

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
	void pushArgByVal(PDAT const* pdat, hpimod::vartype_t vtype);
	void pushArgByRef(PVal* pval, APTR aptr);
	void pushArgByDefault();
	void allocArgNoBind(unsigned short priority);

	//------------------------------------------------
	// 実引数値の peek 各種
	//------------------------------------------------
	
	PDAT const* peekValArgAt(size_t idx, hpimod::vartype_t& vtype) const;
	PVal const* peekRefArgAt(size_t idx) const;

	hpimod::ManagedVarData const peekAnyAt(size_t idx) const;

	MPVarData const* peekCaptureAt(size_t idx) const;
	PVal const* peekLocalAt(size_t idx) const;
	vector_t const* peekFlex() const;

	unsigned short const* peekArgNoBind(size_t idx) const;

	// nonconst versions

	PDAT* peekValArgAt(size_t idx, hpimod::vartype_t& vtype) { return const_cast<PDAT*>(static_cast<CPrmStk const*>(this)->peekValArgAt(idx, vtype)); }
	PVal* peekRefArgAt(size_t idx) { return const_cast<PVal*>(static_cast<CPrmStk const*>(this)->peekRefArgAt(idx)); }

	hpimod::ManagedVarData peekAnyAt(size_t idx) { return const_cast<hpimod::ManagedVarData&&>(static_cast<CPrmStk const*>(this)->peekAnyAt(idx)); }

	MPVarData* peekCaptureAt(size_t idx){ return const_cast<MPVarData*>(static_cast<CPrmStk const*>(this)->peekCaptureAt(idx)); }
	PVal* peekLocalAt(size_t idx) { return const_cast<PVal*>(static_cast<CPrmStk const*>(this)->peekLocalAt(idx)); }
	vector_t* peekFlex() { return const_cast<vector_t*>(static_cast<CPrmStk const*>(this)->peekFlex()); }

	unsigned short* peekArgNoBind(size_t idx){ return const_cast<unsigned short*>(static_cast<CPrmStk const*>(this)->peekArgNoBind(idx)); }

private:
	//------------------------------------------------
	// prmstk 上へのポインタ
	//------------------------------------------------
	void const* getOffsetPtr(size_t offset) const;
	void const* getArgPtrAt(size_t idx) const;

	//------------------------------------------------
	// その他
	//------------------------------------------------
	// 解体
	void free();

	// for CBound
	void pushArgFromPrmStk(CPrmStk const& src, size_t idxSrc,  CBound* boundfunc = nullptr, CPrmStk* argsMerged = nullptr);
	void pushFinalsFrom(CPrmStk const& src);
public:
	void merge(CPrmStk const& src, CBound& boundfunc, CPrmStk& argsMerged);
};

template<> void CPrmStk::pushValue<hpimod::vtStr>(PDAT const* pdat);

#endif
