#include <vector>
#include <map>

#include "hsp3plugin_custom.h"
#include "mod_makepval.h"

#include "cmd_valptr.h"

static std::vector<PVal*> st_valptr;

//------------------------------------------------
// 値の型の取得
//------------------------------------------------
int Valtype( void** ppResult )
{
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	return SetReffuncResult( ppResult, mpval->flag );
}

//------------------------------------------------
// local: プラグイン側で PVal を用意する
// 
// @ 初期化済み(init)
//------------------------------------------------
static PVal* NewPVal( vartype_t vt )
{
	PVal* pval = reinterpret_cast<PVal*>( sbAlloc(sizeof(PVal)) );
	PVal_init( pval, vt );
	st_valptr.push_back( pval );				// リストに追加 (後で解放するため)
	return pval;
}

//------------------------------------------------
// 値の valptr 化
//------------------------------------------------
int NewValptr( void** ppResult )
{
	//if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	
	PVal* pval = NewPVal( HSPVAR_FLAG_INT );
	//PVal_copy( pval, mpval );					// 受け取った値で初期化する
	
	for ( int i = 0; ; ++ i ) {
		// 代入する値
		if ( code_getprm() <= PARAM_END ) {
			if ( i == 0 ) puterror( HSPERR_NO_DEFAULT );	// 最低1つは必要
			break;
		}
		
		// 配列を拡張する
		if ( i > 0 ) exinfo->HspFunc_redim( pval, 1, i + 1 );
		
		// 要素番号を設定
		HspVarCoreReset( pval );
		exinfo->HspFunc_array( pval, i );
		
		// 代入
		HspVarProc* pHvp = exinfo->HspFunc_getproc( mpval->flag );
		PVal_assign( pval, pHvp->GetPtr(mpval), mpval->flag );
	}
	
//	dbgout( "new [0x%08X]", pval );
	return SetReffuncResult( ppResult, reinterpret_cast<int>(pval) );
}

//------------------------------------------------
// valptr から値を得る
//------------------------------------------------
// 命令形式
void FromValptr()
{
	PVal* pvDst  = code_getpval();		// 配列を受け取る
	int   valptr = code_geti();			// NewValptr() で得た値
	
	PVal* pvSrc = reinterpret_cast<PVal*>(valptr);
	if ( pvSrc == NULL ) return;
	
	// 代入先に複製する
	PVal_copy( pvDst, pvSrc );
}

// 関数形式
int FromValptr(void** ppResult)
{
	PVal* pvSrc = reinterpret_cast<PVal*>( code_geti() );		// NewValptr() で得た値
	if ( pvSrc == NULL ) {
		puterror( HSPERR_ILLEGAL_FUNCTION );
	}
	
	APTR aptr = code_getdi(0);		// 要素番号
	
	HspVarCoreReset( pvSrc );
	exinfo->HspFunc_array( pvSrc, aptr );
	
	HspVarProc* pHvp = exinfo->HspFunc_getproc(pvSrc->flag);
	*ppResult = pHvp->GetPtr(pvSrc);
	return pvSrc->flag;
}

//------------------------------------------------
// 関数形式代入
//------------------------------------------------
int Assign(void** ppResult)
{
	PVal* pvDst;
	APTR  aptr = code_getva( &pvDst );			// 代入先
	
	if ( code_getprm() <= PARAM_END ) {			// 代入する値
		puterror( HSPERR_NO_DEFAULT );
	}
	
	// 単純代入処理
	PVal_assign( pvDst, exinfo->HspFunc_getproc(mpval->flag)->GetPtr(mpval), mpval->flag );
	
	return SetReffuncResult( ppResult, pvDst->offset );	// 代入した要素番号 (一次元)
}

//------------------------------------------------
// valptr 実体を全て解放する
//------------------------------------------------
void TermValptr(void)
{
	for ( std::vector<PVal*>::iterator iter = st_valptr.begin()
		; iter != st_valptr.end()
		; ++ iter
	) {
	//	dbgout( "delete [0x%08X]", *iter );
		
		PVal_free( *iter );
		sbFree( *iter );
	}
	st_valptr.clear();
	
	return;
}

//------------------------------------------------
// int 型の値を返値として返す
//------------------------------------------------
int SetReffuncResult(void** ppResult, int n)
{
	return SetReffuncResult_core<int, HSPVAR_FLAG_INT>( ppResult, n );
}
