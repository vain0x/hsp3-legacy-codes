#include "dllmain.h"
#include "vp_complex.h"

vartype_t HSPVAR_FLAG_COMPLEX = HSPVAR_FLAG_NONE;
static HspVarProc* g_myvp     = NULL;
static size_t      g_elemsize = sizeof(complex_t);

static int   HspVarComplex_CalcSize( PVal* pval );
static PDAT* HspVarComplex_GetPtr  ( PVal* pval );
static int   HspVarComplex_GetSize ( const PDAT* pdat );
static int   HspVarComplex_GetUsing( const PDAT* pdat );
static void  HspVarComplex_Alloc   ( PVal* pval, const PVal* pval2 );
static void  HspVarComplex_Free    ( PVal* pval );
static void* HspVarComplex_Cnv      ( const void* buffer, int vtSrc );
static void* HspVarComplex_CnvCustom( const void* buffer, int vtDst );
static void* HspVarComplex_GetBlockSize( PVal* pval, PDAT* pdat, int* size );
static void  HspVarComplex_AllocBlock  ( PVal* pval, PDAT* pdat, int  size );
static void* HspVarComplex_ArrayObjectRead( PVal* pval, int* mptype );
static void  HspVarComplex_ArrayObject ( PVal* pval );
static void  HspVarComplex_ObjectWrite ( PVal* pval, void* data, int vtSrc );
static void  HspVarComplex_ObjectMethod( PVal* pval );

static void HspVarComplex_Set( PVal* pval, PDAT* pdat, const void* src );
static void HspVarComplex_AddI( PDAT* pdat, const void* val );
static void HspVarComplex_SubI( PDAT* pdat, const void* val );
static void HspVarComplex_MulI( PDAT* pdat, const void* val );
static void HspVarComplex_DivI( PDAT* pdat, const void* val );
static void HspVarComplex_ModI( PDAT* pdat, const void* val );
static void HspVarComplex_AndI( PDAT* pdat, const void* val );
static void HspVarComplex_OrI ( PDAT* pdat, const void* val );
static void HspVarComplex_XorI( PDAT* pdat, const void* val );
static void HspVarComplex_ShLI( PDAT* pdat, const void* val );
static void HspVarComplex_ShRI( PDAT* pdat, const void* val );
static void HspVarComplex_EqI ( PDAT* pdat, const void* val );
static void HspVarComplex_NeI ( PDAT* pdat, const void* val );
static void HspVarComplex_GtI ( PDAT* pdat, const void* val );
static void HspVarComplex_LtI ( PDAT* pdat, const void* val );
static void HspVarComplex_GtEqI( PDAT* pdat, const void* val );
static void HspVarComplex_LtEqI( PDAT* pdat, const void* val );

//------------------------------------------------
// PVal::pt が必要とするサイズ[byte]を計算する
// 
// @ PVal::size の値に設定される。
//------------------------------------------------
static int HspVarComplex_CalcSize( const PVal* pval )
{
	size_t cntElems = pval->len[1];
	if ( pval->len[2] ) cntElems *= pval->len[2];
	if ( pval->len[3] ) cntElems *= pval->len[3];
	if ( pval->len[4] ) cntElems *= pval->len[4];
	return static_cast<int>( cntElems * g_elemsize );
}

//------------------------------------------------
// 実体ポインタを取得する
// 
// @result: 実質 complex_t*
//------------------------------------------------
static PDAT* HspVarComplex_GetPtr( PVal* pval )
{
	return (PDAT*)( &pval->pt[pval->offset * g_elemsize] );
}

//------------------------------------------------
// Size
//------------------------------------------------
static int HspVarComplex_GetSize( const PDAT* pval )
{
	return g_elemsize;
}

//------------------------------------------------
// PValの変数メモリを確保する
// 
// pval はすでに解放済み。(または未確保)
// pval2 がNULLの場合は、普通に確保する。
// pval2 が指定されている場合は、pval2の内容を継承する
//------------------------------------------------
static void HspVarComplex_Alloc( PVal* pval, const PVal* pval2 )
{
	int size;
	char* pt;
//	complex_t* fv;
	
	if ( pval->len[1] < 1 ) pval->len[1] = 1;	// 配列を最低1は確保する
	size       = HspVarComplex_CalcSize( pval );
	pt         = hspmalloc(size);
	
	// 0クリア
	memset( pt, 0, size );
	
	// 継承する
	if ( pval2 != NULL ) {
		memcpy( pt, pval2->pt, pval2->size );	// 持っていたデータをコピー
		hspfree( pval2->pt );					// 元のバッファを解放
	}
	
	pval->pt   = pt;
	pval->size = size;
	pval->flag = HSPVAR_FLAG_COMPLEX;
	pval->mode = HSPVAR_MODE_MALLOC;
	return;
}

//------------------------------------------------
// PValの変数メモリを解放する
//------------------------------------------------
static void HspVarComplex_Free( PVal* pval )
{
	if ( pval->mode == HSPVAR_MODE_MALLOC ) {
		hspfree( pval->pt );
	}
	
	pval->pt   = NULL;
	pval->mode = HSPVAR_MODE_NONE;
	return;
}

//------------------------------------------------
// cnv: another -> complex
//------------------------------------------------
static void* HspVarComplex_Cnv( const void* buffer, int vtSrc )
{
	static complex_t stt_cnv;
	
	switch ( vtSrc )
	{
		case HSPVAR_FLAG_DOUBLE:
			stt_cnv = complex_t( static_cast<int>(*(double*)buffer), 0 );
			break;
			
		case HSPVAR_FLAG_INT:
			stt_cnv = complex_t( *(int*)buffer, 0 );
			break;
			
		default:
			if ( vtSrc == HSPVAR_FLAG_COMPLEX ) {
				stt_cnv = *(complex_t*)buffer;
				break;
			} else {
				puterror( HSPVAR_ERROR_TYPEMISS );
			}
	}
	return &stt_cnv;
}

//------------------------------------------------
// cnv: complex -> another
//------------------------------------------------
static void* HspVarComplex_CnvCustom( const void* buffer, int vtDst )
{
	const complex_t* p = static_cast<const complex_t*>( buffer );
	
	switch ( flag )
	{
		case HSPVAR_FLAG_DOUBLE:
		{
			static double stt_double;
			if ( p->getIm() != 0 ) puterror( HSPERR_TYPE_MISMATCH );
			stt_double = p->getRe();
			return &stt_double;
		}
		case HSPVAR_FLAG_INT:
		{
			static int stt_int;
			if ( p->getIm() != 0 ) puterror( HSPERR_TYPE_MISMATCH );
			stt_int = p->getRe();
			return &stt_int;
		}
		default:
			if ( flag == HSPVAR_FLAG_COMPLEX ) {
				static complex_t stt_complex;
				stt_complex = *p;
				return &stt_complex;
				
			} else {
				puterror( HSPVAR_ERROR_TYPEMISS );
			}
	}
	return const_cast<void*>( buffer );
}

//------------------------------------------------
// ブロックサイズを取得
//------------------------------------------------
static void* HspVarComplex_GetBlockSize( PVal* pval, PDAT* pdat, int* size )
{
	*size = pval->size - ( (char*)pdat - (char*)pval->pt );
	return pdat;
}

//------------------------------------------------
// 可変長のため
//------------------------------------------------
static void HspVarComplex_AllocBlock( PVal* pval, PDAT* pdat, int size )
{
	return;
}

//------------------------------------------------
// 代入処理
//------------------------------------------------
static void HspVarComplex_Set( PVal* pval, PDAT* pdat, const void* src )
{
	*(complex_t*)pdat = *(complex_t*)src;
	return;
}

//------------------------------------------------
// 算術演算
//------------------------------------------------
#define FTM_OpBinMath( _ident, _op ) \
	static void HspVarComplex_##_ident##I( PDAT* pdat, const void* val )	\
	{\
		*(complex_t*)pdat _op##= *(complex_t*)val;		\
	}

FTM_OpBinMath( Add, + );
FTM_OpBinMath( Sub, - );
FTM_OpBinMath( Mul, * );
FTM_OpBinMath( Div, / );
FTM_OpBinMath( Div, % );

//------------------------------------------------
// 比較演算
//------------------------------------------------
static void HspVarComplex_EqI( PDAT* pdat, const void* val )
{
	*(int*)pdat       = ( *(complex_t*)pdat == *(complex_t*)val );
	g_myvp->aftertype = HSPVAR_FLAG_INT;
	return;
}

static void HspVarComplex_NeI( PDAT* pdat, const void* val )
{
	*(int*)pdat       = ( *(complex_t*)pdat != *(complex_t*)val );
	g_myvp->aftertype = HSPVAR_FLAG_INT;
	return;
}

//------------------------------------------------
// HspVarProc初期化関数
//------------------------------------------------
void HspVarComplex_Init( HspVarProc* vp )
{
	HSPVAR_FLAG_COMPLEX = vp->flag;
	g_myvp              = vp;
	
	vp->GetPtr       = HspVarComplex_GetPtr;
	vp->GetSize      = HspVarComplex_GetSize;
//	vp->GetUsing     = HspVarComplex_GetUsing;
	
	vp->Alloc        = HspVarComplex_Alloc;
	vp->Free         = HspVarComplex_Free;
	
	vp->Cnv          = HspVarComplex_Cnv;
	vp->CnvCustom    = HspVarComplex_CnvCustom;
	
	vp->GetBlockSize = HspVarComplex_GetBlockSize;
	vp->AllocBlock   = HspVarComplex_AllocBlock;
	
	vp->Set          = HspVarComplex_Set;
	
	vp->AddI         = HspVarComplex_AddI;
	vp->SubI         = HspVarComplex_SubI;
	vp->MulI         = HspVarComplex_MulI;
	vp->DivI         = HspVarComplex_DivI;
	vp->ModI         = HspVarComplex_ModI;
	
//	vp->AndI         = HspVarComplex_AndI;
//	vp->OrI          = HspVarComplex_OrI;
//	vp->XorI         = HspVarComplex_XorI;
	
	vp->EqI          = HspVarComplex_EqI;
	vp->NeI          = HspVarComplex_NeI;
	
//	vp->RrI          = HspVarComplex_ShRI;
//	vp->LrI          = HspVarComplex_ShLI;
	
	vp->vartype_name = "complex";	// 型名
	vp->version     = 0x001;		// VarType RuntimeVersion(0x100 = 1.0)
	vp->support     = HSPVAR_SUPPORT_STORAGE
	                | HSPVAR_SUPPORT_FLEXARRAY
					;				// サポート状況フラグ(HSPVAR_SUPPORT_*)
	vp->basesize    = g_elemsize;	// 1つのデータのbytes / 可変長の時は-1
}
