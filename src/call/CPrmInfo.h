// 仮引数情報クラス

#ifndef IG_CLASS_PARAMETER_INFORMATION_H
#define IG_CLASS_PARAMETER_INFORMATION_H

#include <vector>
#include "PrmType.h"
#include "cmd_call.h"

/**
@summary:
	仮引数情報を管理する。
	何を呼び出すかは知らない。CCall に所持・使用される。
	cmd_sub.cpp, CBound などが、呼び出し先と対にして生成・管理する。
	全体的に constexpr が多いはずなのに。

	解体処理の必要がない値だけを持っている。
**/
class CPrmInfo
{
public:
	using prmlist_t = std::vector<prmtype_t>;
	using offset_t  = std::vector<size_t>;

private:
	size_t cntPrms_;		// 受け取る実引数の数
	size_t cntCaptures_;	// キャプチャ値の数
	size_t cntLocals_;		// ローカル変数の数
	bool bFlex_;			// 可変長引数か否か

	// 仮引数リスト
	prmlist_t prmlist_;

	// オフセット値のキャッシュ (PrmStk を参照するたびに必要なので、生成時にすべて計算しておく)
	offset_t offsetlist_;
	size_t stkOffsetCapture_;
	size_t stkOffsetLocal_;
	size_t stkOffsetFlex_;
	size_t stkSize_;

public:
	//--------------------------------------------
	// 構築
	//--------------------------------------------
	CPrmInfo() : CPrmInfo(nullptr) { }
	CPrmInfo(prmlist_t const* pPrmlist);

	CPrmInfo(prmlist_t&& prmlist) : CPrmInfo(&prmlist) { }
#if 0
	CPrmInfo(CPrmInfo&&) = default;
#else
	CPrmInfo(CPrmInfo&& src)
		: cntPrms_ { src.cntPrms_ }
		, cntCaptures_ { src.cntCaptures_ }
		, cntLocals_ { src.cntLocals_ }
		, bFlex_ { src.bFlex_ }
		, prmlist_( std::move(src.prmlist_) )
		, offsetlist_( std::move(src.offsetlist_) )
		, stkOffsetCapture_ { src.stkOffsetCapture_ }
		, stkOffsetLocal_ { src.stkOffsetLocal_ }
		, stkOffsetFlex_ { src.stkOffsetFlex_ }
		, stkSize_ { src.stkSize_ }
	{}

	CPrmInfo(CPrmInfo const&) = delete;
	CPrmInfo& operator=(CPrmInfo const&) = delete;
#endif

private:
	void calcOffsets();
	void setPrmlist(prmlist_t const& prmlist);

public:
	//--------------------------------------------
	// 取得系
	//--------------------------------------------
	size_t cntPrms()     const { return cntPrms_; }
	size_t cntCaptures() const { return cntCaptures_; }
	size_t cntLocals()   const { return cntLocals_; }
	bool   isFlex()      const { return bFlex_; }

	prmtype_t getPrmType( size_t idx ) const;

	size_t getStackSize() const { return stkSize_; }
	size_t getStackOffset(size_t idx) const;
	size_t getStackOffsetParam(size_t idx) const;
	size_t getStackOffsetCapture(size_t idx) const;
	size_t getStackOffsetLocal(size_t idx) const;
	size_t getStackOffsetFlex() const { return stkOffsetFlex_; }

	//--------------------------------------------
	// その他
	//--------------------------------------------
	PVal* getDefaultArg( size_t iArg ) const;
	void checkCorrectArg( PVal const* pvArg, size_t iArg, bool bByRef = false ) const;

	//--------------------------------------------
	// 演算子オーバーロード
	//--------------------------------------------
	int compare( CPrmInfo const& rhs ) const;
	bool operator ==( CPrmInfo const& rhs ) const { return compare( rhs ) == 0; }
	bool operator !=( CPrmInfo const& rhs ) const { return !( *this == rhs ); }

	// その他
public:
	static CPrmInfo Create(hpimod::stdat_t);

	// 未宣言関数の仮引数
	static CPrmInfo const undeclaredFunc;

	// 仮引数を1つも持たない関数の仮引数
	static CPrmInfo const noprmFunc;
};

#endif
