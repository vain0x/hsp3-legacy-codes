// var_modcmd - VarProc

#include "hsp3plugin_custom.h"
#include "mod_makepval.h"
#include "mod_argGetter.h"

#include "iface_modcmd.h"
#include "cmd_modcmd.h"
#include "vt_modcmd.h"

using namespace hpimod;

// 変数の定義
vartype_t   g_vtModcmd;
HspVarProc* g_pHvpModcmd;

// 関数の宣言
extern PDAT* HspVarModcmd_GetPtr         ( PVal* pval) ;
extern int   HspVarModcmd_GetSize        ( const PDAT* pdat );
extern int   HspVarModcmd_GetUsing       ( const PDAT* pdat );
extern void* HspVarModcmd_GetBlockSize   ( PVal* pval, PDAT* pdat, int* size );
extern void  HspVarModcmd_AllocBlock     ( PVal* pval, PDAT* pdat, int  size );
extern void  HspVarModcmd_Alloc          ( PVal* pval, const PVal* pval2 );
extern void  HspVarModcmd_Free           ( PVal* pval);
extern void* HspVarModcmd_ArrayObjectRead( PVal* pval, int* mptype );
extern void  HspVarModcmd_ArrayObject    ( PVal* pval);
extern void  HspVarModcmd_ObjectWrite    ( PVal* pval, void* data, int vflag );
extern void  HspVarModcmd_ObjectMethod   ( PVal* pval);

namespace VtModcmd {
	value_t& at(PVal* pval)
	{
		return reinterpret_cast<modcmd_t*>(pval->pt)[pval->offset];
	}
}

//------------------------------------------------
// Core
//------------------------------------------------
static PDAT* HspVarModcmd_GetPtr( PVal* pval )
{
	return reinterpret_cast<PDAT*>( &VtModcmd::at(pval) );
}

//------------------------------------------------
// Size
//------------------------------------------------
static int HspVarModcmd_GetSize( const PDAT* pdat )
{
	return VtModcmd::basesize;
}

//------------------------------------------------
// Using
//------------------------------------------------
static int HspVarModcmd_GetUsing( const PDAT* pdat )
{
	return HspBool(*reinterpret_cast<const modcmd_t*>(pdat) != VtModcmd::null);
}

//------------------------------------------------
// ブロックメモリ
//------------------------------------------------
static void* HspVarModcmd_GetBlockSize( PVal* pval, PDAT* pdat, int* size )
{
	*size = pval->size - ( ((char*)pdat) - ((char*)pval->pt) );
	return pdat;
}

static void HspVarModcmd_AllocBlock( PVal* pval, PDAT* pdat, int size )
{
	return;
}

//------------------------------------------------
// PValの変数メモリを確保する
//
// @ pval は未確保 or 解放済みの状態。
// @ pval2 != nullptr なら、pval2 の内容を引き継ぐ。
//------------------------------------------------
static void HspVarModcmd_Alloc( PVal* pval, const PVal* pval2 )
{
	if ( pval->len[1] < 1 ) pval->len[1] = 1;		// 配列を最低1は確保する
	size_t const cntElems = PVal_cntElems( pval );		// 全要素数 (hpimod/mod_makepval)
	size_t const     size = cntElems * VtModcmd::basesize;
	size_t const oldSize  = pval2 ? pval2->size : 0;
	
	// バッファ確保
	modcmd_t* const pt = reinterpret_cast<modcmd_t*>( hspmalloc(size) );
	
	// 無効値で埋める
	memset(pt + oldSize, 0xFF, size - oldSize);
//	for( size i = 0; i < cntElems; ++ i ) { pt[i] = VtModcmd::null; }
	
	// 引き継ぎ
	if ( pval2 ) {
		memcpy( pt, pval2->pt, pval2->size );
		hspfree( pval2->pt );
	}
	
	// pval へ設定
	pval->flag   = g_vtModcmd;
	pval->mode   = HSPVAR_MODE_MALLOC;
	pval->size   = size;
	pval->pt     = reinterpret_cast<char*>(pt);
//	pval->master = nullptr;
	return;
}

//------------------------------------------------
// PValの変数メモリを解放する
//------------------------------------------------
static void HspVarModcmd_Free( PVal* pval )
{
	if ( pval->mode == HSPVAR_MODE_MALLOC ) {
		hspfree( pval->pt );
	}
	
	pval->pt     = nullptr;
	pval->mode   = HSPVAR_MODE_NONE;
//	pval->master = nullptr;
	return;
}

//------------------------------------------------
// 代入 (=)
// 
// @ 参照共有
//------------------------------------------------
static void HspVarModcmd_Set( PVal* pval, PDAT* pdat, const void* in )
{
	      modcmd_t& dst = *reinterpret_cast<      modcmd_t*>(pdat);
	const modcmd_t& src = *reinterpret_cast<const modcmd_t*>(in);
	
	dst = src;
	
	g_pHvpModcmd->aftertype = g_vtModcmd;
	return;
}

//------------------------------------------------
// 比較関数 (同値性のみ)
// 
// @ 参照カウンタを使わないのでややこしくない。
//------------------------------------------------
static void HspVarModcmd_EqI( PDAT* pdat, const void* val )
{
	      modcmd_t& lhs = *reinterpret_cast<      modcmd_t*>(pdat);
	const modcmd_t& rhs = *reinterpret_cast<const modcmd_t*>(val);
	
	*reinterpret_cast<int*>(pdat) = HspBool(lhs == rhs);
	g_pHvpModcmd->aftertype = HSPVAR_FLAG_INT;
	return;
}

static void HspVarModcmd_NeI( PDAT* pdat, const void* val )
{
	HspVarModcmd_EqI(pdat, val);
	*reinterpret_cast<int*>(pdat) = HspBool( *reinterpret_cast<int*>(pdat) == HspFalse );
	return;
}

//------------------------------------------------
// 登録関数
//------------------------------------------------
void HspVarModcmd_Init( HspVarProc* p )
{
	g_pHvpModcmd     = p;
	g_vtModcmd       = p->flag;
	
	// 関数ポインタを登録
	p->GetPtr       = HspVarModcmd_GetPtr;
	p->GetSize      = HspVarModcmd_GetSize;
	p->GetUsing     = HspVarModcmd_GetUsing;
	
	p->Alloc        = HspVarModcmd_Alloc;
	p->Free         = HspVarModcmd_Free;
	p->GetBlockSize = HspVarModcmd_GetBlockSize;
	p->AllocBlock   = HspVarModcmd_AllocBlock;
	
	// 演算関数
	p->Set          = HspVarModcmd_Set;
//	p->AddI         = HspVarModcmd_AddI;
	p->EqI          = HspVarModcmd_EqI;
	p->NeI          = HspVarModcmd_NeI;
	
	// 連想配列用
	p->ArrayObjectRead = HspVarModcmd_ArrayObjectRead;	// 参照(右)
	p->ArrayObject     = HspVarModcmd_ArrayObject;		// 参照(左)
//	p->ObjectWrite     = HspVarModcmd_ObjectWrite;		// 格納
//	p->ObjectMethod    = HspVarModcmd_ObjectMethod;		// メソッド
	
	// 拡張データ
//	p->user         = (char*)HspVarModcmd_GetMapList;
	
	// その他設定
	p->vartype_name = "modcmd_k";		// タイプ名 (衝突しないように変な名前にする)
	p->version      = 0x001;			// runtime ver(0x100 = 1.0)
	
	p->support							// サポート状況フラグ(HSPVAR_SUPPORT_*)
		= HSPVAR_SUPPORT_STORAGE		// 固定長ストレージ
		| HSPVAR_SUPPORT_FLEXARRAY		// 可変長配列
	    | HSPVAR_SUPPORT_ARRAYOBJ		// 連想配列サポート
//	    | HSPVAR_SUPPORT_NOCONVERT		// ObjectWriteで格納
	    | HSPVAR_SUPPORT_VARUSE			// varuse関数を適用
	    ;
	p->basesize = VtModcmd::basesize;	// size / 要素 (byte)
	return;
}

//#########################################################
//        連想配列用の関数群
//#########################################################
//------------------------------------------------
// 連想配列::参照 (左辺値)
//------------------------------------------------
static void HspVarModcmd_ArrayObject( PVal* pval )
{
	code_expand_index_int( pval, false );
	return;
}

//------------------------------------------------
// 連想配列::参照 (右辺値)
//------------------------------------------------
static void* HspVarModcmd_ArrayObjectRead( PVal* pval, int* mptype )
{
	// 配列 => 添字に対応する要素の値を取り出す、呼び出しは行わない
	if ( pval->len[1] != 1 ) {
		code_expand_index_int( pval, true );
		
		*mptype = g_vtModcmd;
		return &VtModcmd::at(pval);
	}
	
	auto& modcmd = VtModcmd::at(pval);
	
	// 呼び出しを行わない (バグ対策機能)
	if ( *type == g_pluginModcmd && *val == ModcmdCmd::NoCall ) {
		code_next();
		*mptype = g_vtModcmd;
		return &modcmd;
		
	// 呼び出し
	} else {
		void* pResult = nullptr;
		*mptype = modcmdCall( modcmd, &pResult );
		return pResult;
	}
}

//------------------------------------------------
// 連想配列::格納
//------------------------------------------------
/*
static void HspVarModcmd_ObjectWrite( PVal* pval, void* data, int vflag )
{
	// 配列 => 添字に対応する要素へ代入する、呼び出しは行わない
	if ( pval->len[1] != 1 ) {
		code_expand_index_int( pval, false );
		Modcmd::at(pval) = *reinterpret_cast<modcmd_t*>(data);
	}
	//
	throw;
}
//*/

//------------------------------------------------
// メソッド呼び出し
// 
// @ 内部変数の型で提供されているメソッドを使う
//------------------------------------------------
static void HspVarModcmd_ObjectMethod(PVal* pval)
{
	//
}
