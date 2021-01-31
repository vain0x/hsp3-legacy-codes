// PVal の独自管理

#include <stdlib.h>
#include <string.h>

#include "mod_makepval.h"

//##########################################################
//    宣言
//##########################################################
static PVal* PVal_initDefault(vartype_t vt);

//##########################################################
//    関数
//##########################################################
//------------------------------------------------
// PVal構造体の初期化
// 
// @ (pval == NULL) => 何もしない。
// @prm pval: 未初期化状態(全メンバが不定値)でも可
//------------------------------------------------
void PVal_init(PVal* pval, vartype_t vflag)
{
	if ( pval == NULL ) return;
	
	pval->flag = vflag;
	pval->mode = HSPVAR_MODE_NONE;
	PVal_alloc( pval );
	return;
}

//------------------------------------------------
// もっと簡単で有効なPVal構造体にする
// 
// @ (pval == NULL || vflag == 無効) => 何もしない。
// @ HspVarCoreDim の代わり (配列添字は指定できないが)。
//------------------------------------------------
void PVal_alloc(PVal* pval, PVal* pval2, vartype_t vflag)
{
	if ( pval  == NULL ) return;
	if ( vflag <= HSPVAR_FLAG_NONE ) vflag = pval->flag;
	
	HspVarProc* vp = GetHvp( vflag );
	
	// pt が確保されている場合、解放する
	if ( pval->flag != HSPVAR_FLAG_NONE && pval->mode == HSPVAR_MODE_MALLOC ) {
		PVal_free( pval );
	}
	
	// 確保処理
	memset( pval, 0x00, sizeof(PVal) );
	pval->flag    = vflag;
	pval->mode    = HSPVAR_MODE_NONE;
	pval->support = vp->support;
	vp->Alloc( pval, pval2 );
	return;
}

//------------------------------------------------
// PVal構造体を簡単に初期化する
// 
// @ 最も簡単な形で確保される。
// @ HspVarCoreClear の代わり。
//------------------------------------------------
void PVal_clear(PVal* pval, vartype_t vflag)
{
	PVal_alloc( pval, NULL, vflag );
}

//------------------------------------------------
// PVal 構造体の中身を解放する
// 
// @ (pval == NULL) => 何もしない。
// @ pval ポインタ自体は破壊されない。
//------------------------------------------------
void PVal_free(PVal* pval)
{
	if ( pval == NULL ) return;
	
	HspVarProc* vp = GetHvp( pval->flag );
	vp->Free( pval );
	
	return;
}

//------------------------------------------------
// 既定値を表す PVal 構造体を初期化
// @private
// @ vt は必ず有効な値 (str ～ int)。
//------------------------------------------------
static PVal* PVal_initDefault(vartype_t vt)
{
	static PVal** stt_pDefPVal   = NULL;
	static int    stt_cntDefPVal = 0;
	
	// stt_pDefPVal の拡張
	if ( stt_cntDefPVal <= vt ) {
		int cntNew = vt + 1;
		
		if ( stt_pDefPVal == NULL ) {
			stt_pDefPVal = (PVal**)hspmalloc( cntNew * sizeof(PVal*) );
			
		} else {
			stt_pDefPVal = (PVal**)hspexpand(
				reinterpret_cast<char*>( stt_pDefPVal ),
				cntNew * sizeof(PVal*)
			);
		}
		
		// 拡張分を NULL で初期化する
		for( int i = stt_cntDefPVal; i < cntNew; ++ i ) {
			stt_pDefPVal[i] = NULL;
		}
		
		stt_cntDefPVal = cntNew;
	}
	
	// 未初期化の場合は、PVal のメモリを確保し、初期化する
	if ( stt_pDefPVal[vt] == NULL ) {
		stt_pDefPVal[vt] = (PVal*)hspmalloc( sizeof(PVal) );
		PVal_init( stt_pDefPVal[vt], vt );
	}
	return stt_pDefPVal[vt];
}

//------------------------------------------------
// 既定値を表す PVal 構造体へのポインタを得る
// 
// @ vt が不正な場合、NULL を返す。
//------------------------------------------------
PVal* PVal_getDefault( vartype_t vt )
{
	if ( vt <= HSPVAR_FLAG_NONE ) {
		return NULL;
		
	} else {
		return PVal_initDefault( vt );
	}
}

//##########################################################
//        変数情報の取得
//##########################################################
//------------------------------------------------
// 変数の要素の総数を返す
//------------------------------------------------
size_t PVal_cntElems( PVal* pval )
{
	int cntElems = 1;
	
	// 要素数を調べる
	for ( unsigned int i = 0; i < ArrayDimCnt; ++ i ) {
		if ( pval->len[i + 1] ) {
			cntElems *= pval->len[i + 1];
		}
	}
	
	return cntElems;
}

//------------------------------------------------
// 変数のサイズを返す
// 
// @ pval->offset を見る。
// @ 固定長型なら HspVarProc::basesize を、
// @	可変長型なら、指定要素のサイズを。
//------------------------------------------------
size_t PVal_size( PVal* pval )
{
	HspVarProc* vp = GetHvp( pval->flag );
	
	if ( vp->basesize < 0 ) {
		return vp->GetSize( (PDAT*)(pval->pt) );
	} else {
		return vp->basesize;
	}
}

//------------------------------------------------
// 変数から実体ポインタを得る
// 
// @ pval->offset を見る。
//------------------------------------------------
PDAT* PVal_getptr( PVal* pval )
{
	return (GetHvp(pval->flag))->GetPtr( pval );
}

//##########################################################
//        変数に対する操作
//##########################################################
//------------------------------------------------
// PValへ値を格納する (汎用)
// 
// @ pval の添字状態を参照する。
//------------------------------------------------
void PVal_assign( PVal* pval, void* pData, vartype_t vflag )
{
	// 添字あり => ObjectWrite
	if ( (pval->support & HSPVAR_SUPPORT_NOCONVERT) && (pval->arraycnt != 0) ) {
		(GetHvp( pval->flag ))->ObjectWrite( pval, pData, vflag );
		
	// 通常の代入
	} else {
		code_setva( pval, pval->offset, vflag, pData );
	}
	return;
}

//------------------------------------------------
// PValの複写
// 
// @ 全要素を複写する。
//------------------------------------------------
void PVal_copy(PVal* pvDst, PVal* pvSrc)
{
	if ( pvDst == pvSrc ) return;
	
	int cntElems = PVal_cntElems(pvSrc);
	
	// pvDst を確保する
	exinfo->HspFunc_dim(
		pvDst, pvSrc->flag, 0, pvSrc->len[1], pvSrc->len[2], pvSrc->len[3], pvSrc->len[4]
	);
	
	// 単純変数 => 第一要素を代入するのみ
	if ( cntElems == 1 ) {
		PVal_assign( pvDst, pvSrc->pt, pvSrc->flag );
		
	// 連続代入処理 => すべての要素を代入する
	} else {
		HspVarProc* pHvpSrc = GetHvp( pvSrc->flag );
		
		pvDst->arraycnt = 1;
		for ( int i = 0; i < cntElems; ++ i ) {
			pvDst->offset = i;
			pvSrc->offset = i;
			
			PVal_assign( pvDst, pHvpSrc->GetPtr( pvSrc ), pvSrc->flag );
		}
	}
	return;
}

//------------------------------------------------
// 変数をクローンにする
// 
// @ HspVarCoreDup, HspVarCoreDupPtr
//------------------------------------------------
void PVal_clone( PVal* pvDst, PVal* pvSrc, APTR aptrSrc )
{
	HspVarProc* vp = GetHvp( pvSrc->flag );
	
	if ( aptrSrc >= 0 ) pvSrc->offset = aptrSrc;
	PDAT* pSrc = vp->GetPtr(pvSrc);			// 実体ポインタ
	
	int size;								// クローンにするサイズ
	vp->GetBlockSize( pvSrc, pSrc, &size );
	
	// 実体ポインタからクローンを作る
	PVal_clone( pvDst, pSrc, pvSrc->flag, size );
	return;
}

void PVal_clone( PVal* pval, void* ptr, int flag, int size )
{
	HspVarProc* vp = GetHvp(flag);
	
	vp->Free( pval );
	pval->pt = (char*)ptr;
	pval->flag = flag;
	pval->size = size;
	pval->mode = HSPVAR_MODE_CLONE;
	pval->len[0] = 1;
	
	if ( vp->basesize < 0 ) {
		pval->len[1] = 1;
	} else {
		pval->len[1] = size / vp->basesize;
	}
	pval->len[2] = 0;
	pval->len[3] = 0;
	pval->len[4] = 0;
	pval->offset = 0;
	pval->arraycnt = 0;
	pval->support = HSPVAR_SUPPORT_STORAGE;
	return;
}

//------------------------------------------------
// 値をシステム変数に代入する
//------------------------------------------------
void SetResultSysvar(const void* pValue, vartype_t vflag)
{
	if ( pValue == NULL ) return;
	
	ctx->retval_level = ctx->sublev;
	
	switch ( vflag ) {
		case HSPVAR_FLAG_INT:
			ctx->stat = *reinterpret_cast<const int*>( pValue );
			break;
			
		case HSPVAR_FLAG_STR:
			strncpy(
				ctx->refstr,
				reinterpret_cast<const char*>( pValue ),
				HSPCTX_REFSTR_MAX - 1
			);
			break;
			
		case HSPVAR_FLAG_DOUBLE:
			ctx->refdval = *reinterpret_cast<const double*>( pValue );
			break;
			
		default:
			puterror( HSPERR_TYPE_MISMATCH );
	}
	return;
}

//------------------------------------------------
// 実体ポインタを型変換する
//------------------------------------------------
const PDAT* Valptr_cnvTo( const PDAT* pValue, vartype_t vtSrc, vartype_t vtDst )
{
	return (const PDAT*)(
		( vtSrc < HSPVAR_FLAG_USERDEF )
			? GetHvp(vtDst)->Cnv( pValue, vtSrc )
			: GetHvp(vtSrc)->CnvCustom( pValue, vtDst )
	);
}
