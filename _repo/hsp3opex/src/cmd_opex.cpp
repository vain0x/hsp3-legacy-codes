// opex - command

#include "mod_makepval.h"
#include "mod_argGetter.h"
#include "mod_func_result.h"

#include "cmd_opex.h"

static operator_t GetOpFuncPtr( HspVarProc* hvp, OPTYPE optype );

//#########################################################
//        命令
//#########################################################
//------------------------------------------------
// 代入演算
// 
// @ 連続代入演算対応
//------------------------------------------------
int assign( void** ppResult )
{
	PVal* pval = code_get_var();	// 代入先
	
	// 第一値の代入
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	PVal_assign( pval, mpval->pt, mpval->flag );
	
	// 連続代入
	code_assign_multi( pval );
	
	// 関数なら返却値の設定
	if ( ppResult != NULL ) {
		*ppResult = PVal_getptr(pval);
		return pval->flag;
	}
	
	return 0;			// 命令なら適当に値を返しておくだけ
}

//------------------------------------------------
// 交換演算
//------------------------------------------------
int swap( void** ppResult )
{
	PVal* pval1; APTR aptr1 = code_getva( &pval1 );	// 変数#1
	PVal* pval2; APTR aptr2 = code_getva( &pval2 );	// 変数#2
	
	// 交換
	PVal_swap( pval1, pval2, aptr1, aptr2 );
	
	// 関数なら返却値の設定
	if ( ppResult != NULL ) {
		*ppResult = PVal_getptr( pval2 );
		return pval2->flag;
	}
	
	return 0;			// 命令なら適当に値を返しておくだけ
}

//------------------------------------------------
// 
//------------------------------------------------

//#########################################################
//        関数
//#########################################################
//------------------------------------------------
// 短絡論理演算
//------------------------------------------------
int shortLogOp( void** ppResult, bool bAnd )
{
	bool bResult = (bAnd ? true : false);
	
	for(;;) {
		// 条件
		int const prm = code_getprm();
		if ( prm <= PARAM_END ) break;
		if ( mpval->flag != HSPVAR_FLAG_INT ) puterror( HSPERR_TYPE_MISMATCH );
		
		bool predicate = (*(int*)mpval->pt != 0);	// 条件
		if ( bAnd && !predicate ) {				// and: 1つでも false があれば false
			bResult = false;
			break;
			
		} else if ( !bAnd && predicate ) {		// or: 1つでも true があれば true
			bResult = true;
			break;
		}
	}
	
	// 残りの引数を捨てる
	while ( code_skipprm() > PARAM_END )
		;
	
	return SetReffuncResult( ppResult, bResult );
}

//------------------------------------------------
// 比較演算
//------------------------------------------------
int cmpLogOp( void** ppResult, bool bAnd )
{
	bool bResult = (bAnd ? true : false);
	
	// 比較元の値を取得
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	
	vartype_t   flag = mpval->flag;
	HspVarProc* pHvp = exinfo->HspFunc_getproc( flag );
	operator_t  pfOp = GetOpFuncPtr( pHvp, (OPTYPE)OPTYPE_EQ );	// optype: 関係演算ならなんでもいいが、== にする
	
	if ( pfOp == NULL ) puterror( HSPERR_TYPE_MISMATCH );
	
	// 比較元の値を保存
	size_t size      = PVal_size( mpval );
	void* pTarget    = (void*)hspmalloc( size );	// 元データ
	void* pTargetTmp = (void*)hspmalloc( size );	// 作業用バッファ
	if ( pTarget == NULL || pTargetTmp == NULL ) puterror( HSPERR_OUT_OF_MEMORY );
	
	memcpy( pTarget, mpval->pt, size );			// 丸々コピーしておく
	
	// 比較値と比較
	for(;;) {
		int prm = code_getprm();
		if ( prm <= PARAM_END ) break;
		
		bool bPred;
		
		if ( mpval->flag != flag ) {
			bPred = false;	// 型が違う時点でアウト
			
		} else {
			// pTarget を作業用バッファコピー
			memcpy( pTargetTmp, pTarget, size );
			
			// 演算
			(*pfOp)( (PDAT*)pTargetTmp, mpval->pt );	// 演算子の動作
			bPred = ( *(int*)pTargetTmp != 0 );
		}
		
		if ( bAnd && !bPred ) {
			bResult = false;
			break;
			
		} else if ( !bAnd && bPred ) {
			bResult = true;
			break;
		}
	}
	
	// 残りの引数を捨てる
	while ( code_skipprm() > PARAM_END )
		;
	
	// バッファを解放
	if ( pTarget    != NULL ) hspfree( pTarget    );
	if ( pTargetTmp != NULL ) hspfree( pTargetTmp );
	
	return SetReffuncResult( ppResult, bResult );
}

//------------------------------------------------
// 条件演算 (?:)
//------------------------------------------------
int which(void** ppResult)
{
	bool  predicate = (code_geti() != 0);	// 条件
	if ( !predicate ) code_skipprm();		// 偽 => 真の部分を飛ばす
	
	if ( code_getprm() <= PARAM_END ) {
		puterror( HSPERR_NO_DEFAULT );
	}
	
	// 返値となる値を取り出す
	vartype_t flag = mpval->flag;
	*ppResult = mpval->pt;
	
	if ( predicate ) code_skipprm();		// 真 => 偽の部分を飛ばす
	return flag;
}

//------------------------------------------------
// 分岐関数
//------------------------------------------------
int what(void** ppResult)
{
	int idx = code_geti();
	if ( idx < 0 ) puterror( HSPERR_ILLEGAL_FUNCTION );
	
	// 前の部分を飛ばしていく
	for( int i = 0; i < idx; i ++ ) {
		if ( code_skipprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	}
	
	// 返値となる値を取り出す
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	vartype_t flag = mpval->flag;
	*ppResult = mpval->pt;
	
	// 残りの引数を捨てる
	while ( code_skipprm() > PARAM_END )
		;
	
	return flag;
}

//------------------------------------------------
// リスト式
// 
// @ 各引数を評価して、最後の引数の値を返す。
//------------------------------------------------
int exprs( void** ppResult )
{
	while ( code_getprm() > PARAM_END )
		;
	
	*ppResult = mpval->pt;
	return mpval->flag;
}

//------------------------------------------------
// 
//------------------------------------------------

//#########################################################
//        システム変数
//#########################################################
//------------------------------------------------
// 
//------------------------------------------------

//#########################################################
//        下請け
//#########################################################
//------------------------------------------------
// Hvp から演算処理関数を取り出す
//------------------------------------------------
operator_t GetOpFuncPtr( HspVarProc* hvp, OPTYPE optype )
{
	if ( hvp == NULL ) return NULL;
	switch ( optype ) {
		case OPTYPE_ADD: return hvp->AddI;
		case OPTYPE_SUB: return hvp->SubI;
		case OPTYPE_MUL: return hvp->MulI;
		case OPTYPE_DIV: return hvp->DivI;
		case OPTYPE_MOD: return hvp->ModI;
		case OPTYPE_AND: return hvp->AndI;
		case OPTYPE_OR:  return hvp->OrI;
		case OPTYPE_XOR: return hvp->XorI;
		
		case OPTYPE_EQ:   return hvp->EqI;
		case OPTYPE_NE:   return hvp->NeI;
		case OPTYPE_GT:   return hvp->GtI;
		case OPTYPE_LT:   return hvp->LtI;
		case OPTYPE_GTEQ: return hvp->GtEqI;
		case OPTYPE_LTEQ: return hvp->LtEqI;
		
		case OPTYPE_RR: return hvp->RrI;
		case OPTYPE_LR: return hvp->LrI;
		default:
			return NULL;
	}
}
