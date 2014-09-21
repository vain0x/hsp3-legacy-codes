// 仮引数情報クラス

#include "mod_makepval.h"

#include "CPrmInfo.h"

using namespace hpimod;

CPrmInfo const CPrmInfo::undeclaredFunc({ PrmType::Flex });
CPrmInfo const CPrmInfo::noprmFunc( nullptr );

//##############################################################################
//                定義部 : CPrmInfo
//##############################################################################
//------------------------------------------------
// 標準構築
//------------------------------------------------
CPrmInfo::CPrmInfo(prmlist_t const* pPrmlist)
	: cntPrms_ { 0 }
	, cntCaptures_ { 0 }
	, cntLocals_ { 0 }
	, bFlex_  { false }
{
	if ( pPrmlist ) { setPrmlist( *pPrmlist ); }
	calcOffsets();
	return;
}

//------------------------------------------------
// オフセット値の計算をキャッシュする
//------------------------------------------------
void CPrmInfo::calcOffsets()
{
	assert(offsetlist_.empty());

	offsetlist_.reserve(prmlist_.size());

	size_t offset = 0;
	for ( auto prmtype : prmlist_ ) {
		offsetlist_.push_back(offset);
		offset += PrmType::sizeOf(prmtype);
	}

	stkOffsetCapture_ = offset;

	offset += cntCaptures() * PrmType::sizeOf(PrmType::Capture);
	stkOffsetLocal_ = offset;

	offset += cntLocals() * PrmType::sizeOf(PrmType::Local);
	stkOffsetFlex_ = offset;

	stkSize_ = offset + isFlex() * PrmType::sizeOf(PrmType::Flex);
	return;
}

//###############################################
//    設定系
//###############################################
//------------------------------------------------
// prmlist の複写
//------------------------------------------------
void CPrmInfo::setPrmlist( prmlist_t const& prmlist )
{
	if ( prmlist.empty() ) return;

	cntPrms_ = 0;
	cntCaptures_ = 0;
	cntLocals_ = 0;

	prmlist_.clear();
	prmlist_.reserve(prmlist.size());

	for ( auto& it : prmlist ) {
		if ( it == PrmType::Flex ) {
			bFlex_ = true;

		} else if ( it == PrmType::Capture ) {
			++cntCaptures_;
			
		} else if ( it == PrmType::Local ) {
			++cntLocals_;

		} else {
			prmlist_.push_back( it );
			++cntPrms_;
		}
	}
	return;
}

//###############################################
//    取得系
//###############################################

//-----------------------------------------------
// 仮引数タイプ (failure: PrmType::None)
//-----------------------------------------------
int CPrmInfo::getPrmType( size_t idx ) const
{
	assert( idx < cntPrms_ );

	return prmlist_[idx];
}

//-----------------------------------------------
// スタックのオフセットを得る
//-----------------------------------------------
size_t CPrmInfo::getStackOffset(size_t idx) const
{
	if ( idx < cntPrms() ) return getStackOffsetParam(idx);

	idx -= cntPrms();
	if ( idx < cntCaptures() ) return getStackOffsetCapture(idx);
	
	idx -= cntCaptures();
	if ( idx < cntLocals() ) return getStackOffsetLocal(idx);

	if ( isFlex() ) {
		if ( idx == 0 ) return getStackOffsetFlex();
		--idx;
	}
	if ( idx == 0 ) return stkSize_;

	assert(false); puterror(HSPERR_UNKNOWN_CODE);
}

size_t CPrmInfo::getStackOffsetParam(size_t idx) const
{
	assert ( idx < cntPrms() );
	return offsetlist_.at(idx);
}

size_t CPrmInfo::getStackOffsetCapture(size_t idx) const
{
	// idx: 最初の capture 引数を 0 とする。
	assert(idx < cntCaptures());

	return stkOffsetCapture_ + idx * PrmType::sizeOf(PrmType::Capture);
}

size_t CPrmInfo::getStackOffsetLocal(size_t idx) const
{
	assert(idx < cntLocals());

	return stkOffsetLocal_ + idx * PrmType::sizeOf(PrmType::Local);
}

//-----------------------------------------------
// 正しい引数か否か
//-----------------------------------------------
void CPrmInfo::checkCorrectArg( PVal const* pvArg, size_t iArg, bool bByRef ) const
{
	int const prmtype = getPrmType(iArg);

	// 可変長引数
	if ( iArg >= cntPrms() ) {
		if ( isFlex() ) {
			// 必ず正しいことにする
		} else {
			puterror( HSPERR_TOO_MANY_PARAMETERS );
		}

	// any
	} else if ( prmtype == PrmType::Any ) {
		// OK

	// 参照渡し要求
	} else if ( prmtype == PrmType::Var || prmtype == PrmType::Array ) {
		if ( !bByRef ) {
			puterror( HSPERR_VARIABLE_REQUIRED );
		}

	// 型不一致
	} else if ( prmtype != pvArg->flag ) {
		puterror( HSPERR_TYPE_MISMATCH );
	}

	return;
}

//-----------------------------------------------
// 省略値を取得
// 
// @ 省略できない => エラー
//-----------------------------------------------
PVal* CPrmInfo::getDefaultArg( size_t iArg ) const
{
	// 可変長引数
	if ( iArg >= cntPrms() ) {
		if ( isFlex() ) {
			return PVal_getDefault();
		} else {
			puterror( HSPERR_TOO_MANY_PARAMETERS );
		}
	}

	int const prmtype = getPrmType(iArg);

	switch ( prmtype ) {
		// 通常仮引数で、既定値のある型
		case HSPVAR_FLAG_STR:
		case HSPVAR_FLAG_DOUBLE:
		case HSPVAR_FLAG_INT:
			return PVal_getDefault( prmtype );

		// 通常仮引数で、省略不可
		case HSPVAR_FLAG_LABEL:  puterror( HSPERR_LABEL_REQUIRED );
		case HSPVAR_FLAG_STRUCT: puterror( HSPERR_STRUCT_REQUIRED );

		// any
		case PrmType::Any:
			return PVal_getDefault();

		default:
			// 参照渡し要求
			if ( PrmType::isRef(prmtype) ) puterror( HSPERR_VARIABLE_REQUIRED );

			puterror( HSPERR_NO_DEFAULT );
	}
}

//------------------------------------------------
// 比較
//
// @ 等しい＝「実引数を受け取る仮引数タイプとキャプチャ引数の数がすべて等しい」
// @ 大小はよく分からない感じ。
//------------------------------------------------
int CPrmInfo::compare( CPrmInfo const& rhs ) const
{
	if ( isFlex()  != rhs.isFlex()  ) return (isFlex() - rhs.isFlex());
	if ( cntPrms() != rhs.cntPrms() ) return cntPrms() - rhs.cntPrms();

	for ( size_t i = 0; i < cntPrms(); ++ i ) {
		int const diff = getPrmType(i) - rhs.getPrmType(i);
		if ( diff ) return diff;
	}

	if ( cntCaptures() != rhs.cntCaptures() ) return cntCaptures() - rhs.cntCaptures();
	return 0;
}

//------------------------------------------------
// CPrmInfo <- STRUCTDAT
//------------------------------------------------
CPrmInfo CPrmInfo::Create(stdat_t stdat)
{
	CPrmInfo::prmlist_t prmlist;
	prmlist.reserve(stdat->prmmax);

	stprm_t const stprm = hpimod::STRUCTDAT_getStPrm(stdat);

	for ( int i = 0; i < stdat->prmmax; ++i ) {
		int const prmtype = PrmType::fromMPType(stprm[i].mptype);
		if ( prmtype != PrmType::None ) {
			prmlist.push_back(prmtype);
		}
	}
	return CPrmInfo(&prmlist);
}
