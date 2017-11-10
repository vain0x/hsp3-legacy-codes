// assoc - VarProc code

#include "vt_assoc.h"

#include "hsp3plugin_custom.h"
#include "mod_makepval.h"
#include "mod_argGetter.h"
#include "vp_template.h"

#include "for_knowbug.var_assoc.h"

using namespace hpimod;

// 変数の定義
int g_vtAssoc;
HspVarProc* g_hvpAssoc;

static StAssocMapList* HspVarAssoc_GetMapList( assoc_t src );	// void* user

//------------------------------------------------
// ヘルパ関数
//------------------------------------------------
PVal* assocAt(assoc_t self, APTR offset)
{
	if ( !(0 <= offset && static_cast<size_t>(offset) < self->size()) ) return nullptr;

	auto iter = self->begin();
	std::advance(iter, offset);
	return iter->second.getVar();
}

APTR assocFindDynamic(assoc_t self, assocKey_t const& key)
{
	auto const iter = self->insert({ key, assocValue_t {} }).first;
	return std::distance(self->begin(), iter);
}

APTR assocFindStatic(assoc_t self, assocKey_t const& key)
{
	auto const iter = self->find(key);
	return (iter != self->end()
		? std::distance(self->begin(), iter)
		: -1
	);
}

//------------------------------------------------
// Core
//------------------------------------------------
static PDAT* HspVarAssoc_GetPtr(PVal* pval)
{
	return VtTraits::asPDAT<vtAssoc>(VtTraits::getValptr<vtAssoc>(pval));
}

//------------------------------------------------
// Using
//------------------------------------------------
static int HspVarAssoc_GetUsing( PDAT const* pdat )
{
	return HspBool(!!VtTraits::derefValptr<vtAssoc>(pdat));
}

//------------------------------------------------
// PValの変数メモリを確保する
//
// @ pval は未確保 or 解放済みの状態。
// @ pval2 != nullptr => pval2の内容を継承する。
//------------------------------------------------
static void HspVarAssoc_Alloc( PVal* pval, PVal const* pval2 )
{
	if ( pval->len[1] < 1 ) pval->len[1] = 1;		// 最低1要素は確保する
	
	size_t const cntElems = PVal_cntElems( pval );
	size_t const     size = cntElems * VtTraits::basesize<vtAssoc>::value;

	if ( cntElems >= VtTraits::assocElementsMax ) puterror(HSPERR_ARRAY_OVERFLOW);

	// バッファ確保
	assoc_t* pt;
	size_t lenOld = 0;

	// 継承
	if ( pval2 ) {
		lenOld = pval2->size / VtTraits::basesize<vtAssoc>::value;
		pt = reinterpret_cast<assoc_t*>(hspexpand(reinterpret_cast<char*>(pval2->pt), size));

	} else {
		pt = reinterpret_cast<assoc_t*>(hspmalloc(size));
	}

	// 初期化
	for ( size_t i = lenOld; i < cntElems; ++i ) {
		new(&pt[i]) assoc_t {};
	}

	// pval へ設定
	pval->flag   = g_vtAssoc;
	pval->mode   = HSPVAR_MODE_MALLOC;
	pval->size   = size;
	pval->pt     = VtTraits::asPDAT<vtAssoc>(pt);
	//pval->master = nullptr;	// 不使用
	return;
}

//------------------------------------------------
// PValの変数メモリを解放する
//------------------------------------------------
static void HspVarAssoc_Free( PVal* pval )
{
	if ( pval->mode == HSPVAR_MODE_MALLOC ) {
		// 全ての要素を Release
		auto const pt = reinterpret_cast<assoc_t*>(pval->pt);
		size_t const cntElems = PVal_cntElems( pval );

		for ( size_t i = 0; i < cntElems; ++ i ) {
			pt[i].~Managed();
		}

		hspfree( pval->pt );
	}

	pval->pt   = nullptr;
	pval->mode = HSPVAR_MODE_NONE;
	return;
}

//------------------------------------------------
// 代入 (=)
// 
// @ 参照共有
//------------------------------------------------
static void HspVarAssoc_Set( PVal* pval, PDAT* pdat, PDAT const* in )
{
	auto& dst = VtTraits::derefValptr<vtAssoc>(pdat);
	auto& src = VtTraits::derefValptr<vtAssoc>(in);

	dst = src;
	
	g_hvpAssoc->aftertype = g_vtAssoc;
	return;
}

/*
//------------------------------------------------
// マージ (+)
// 
// @ 左右の持つキーを併せ持つ Assoc を生成し、返す。
//------------------------------------------------
static void HspVarAssoc_AddI( PDAT* pdat, void const* val )
{

}
//*/

//------------------------------------------------
// 比較関数 (参照同値)
//------------------------------------------------
int HspVarAssoc_CmpI( PDAT* pdat, PDAT const* val )
{
	auto& lhs = VtTraits::derefValptr<vtAssoc>(pdat);
	auto& rhs = VtTraits::derefValptr<vtAssoc>(val);

	int const cmp = (lhs == rhs ? 0 : -1);

	lhs.nullify();
	rhs.beNonTmpObj();

	g_hvpAssoc->aftertype = HSPVAR_FLAG_INT;
	return cmp;
}

//#########################################################
//        連想配列用の関数群
//#########################################################
//------------------------------------------------
// 連想配列::添字処理
// 
// @ ( (idx...(0～4個), "キー", (idx...(内部変数)) )
// @ 内部変数の添字の処理は、呼び出し元が行う。
// @result: 内部変数 or nullptr(assoc自体が参照された)
//------------------------------------------------
template<bool bAsRhs>
static PVal* HspVarAssoc_IndexImpl( PVal* pval )
{
	// [[deprecated]] 添字状態を更新しない (無更新参照)
	if ( *type == TYPE_MARK && *val == ')' ) return nullptr;

	bool bKey = false;		// キーがあったか

	// [1] assoc 自体の添字と、キーを取得

	HspVarCoreReset( pval );		// 添字設定の初期化
	for ( int i = 0; i < (ArrayDimMax + 1) && code_isNextArg(); ++ i )
	{
		PVal pvalTemp;
		HspVarCoreCopyArrayInfo( &pvalTemp, pval );		// 添字状態を保存
		int const chk = code_getprm();
		HspVarCoreCopyArrayInfo( pval, &pvalTemp );

		if ( chk == PARAM_DEFAULT ) {
			// 変数自体の参照 ( (, idxFullSlice) )
			if ( i == 0 && code_getdi(0) == VtTraits::assocIndexFullslice ) {
				break;
			}
			puterror(HSPERR_NO_DEFAULT);
		}
		if ( chk <= PARAM_END ) break;

		// int (最大4連続)
		if ( mpval->flag == HSPVAR_FLAG_INT ) {
			if ( pval->len[i + 1] <= 0 || i == 4 ) puterror( HSPERR_ARRAY_OVERFLOW );

			code_index_int( pval, VtTraits::derefValptr<vtInt>(mpval->pt), !bAsRhs );

		// str (キー)
		} else if ( mpval->flag == HSPVAR_FLAG_STR ) {
			bKey = true;
			++ pval->arraycnt;
			break;
		}
	}

	APTR const aptrAssoc = pval->offset;

	// [2] 参照先 (assoc or 内部変数) を決定

	if ( !bKey ) {
		// キーなし => assoc 自体への参照
		pval->offset = VtTraits::makeIndexOfAssoc(aptrAssoc, VtTraits::assocIndexInnerMask);
		return nullptr;
	}

	assert(mpval->flag == HSPVAR_FLAG_STR);
	assocKey_t const key = VtTraits::asValptr<vtStr>(mpval->pt);

	auto& self = *VtTraits::getValptr<vtAssoc>(pval);
	assert(!!self);

	APTR const aptrInner = (!bAsRhs
		? assocFindDynamic(self, key)	// 左辺値 => 自動拡張あり
		: assocFindStatic(self, key)	// 右辺値 => 自動拡張なし
	);
	if ( bAsRhs && aptrInner < 0 ) puterror( HSPERR_ARRAY_OVERFLOW );

	pval->offset = VtTraits::makeIndexOfAssoc(aptrAssoc, aptrInner);

#if 0
	DbgArea {
		auto iter = self->begin(); std::advance(iter, aptrInner);
		dbgout("(aptrAssoc, key [aptrInner], [aptrInner].key) = (%d, %s [%d], %s)", aptrAssoc, key.c_str(), aptrInner, iter->first.c_str());
	};
#endif

	PVal* const pvInner = assocAt(self, aptrInner);
	assert(!!pvInner);
	return pvInner;
}

//------------------------------------------------
// 連想配列::参照 (左辺値)
//------------------------------------------------
static void HspVarAssoc_ArrayObject( PVal* pval )
{
	PVal* const pvInner = HspVarAssoc_IndexImpl<false>( pval );

	// [3] 内部変数の添字を処理
	if ( pvInner ) {
		if ( code_isNextArg() ) {
			if ( pvInner->arraycnt > 0 ) puterror(HSPERR_INVALID_ARRAY);
			code_expand_index_lhs(pvInner);
		}
	}
	return;
}

//------------------------------------------------
// 連想配列::参照 (右辺値)
//------------------------------------------------
static PDAT* HspVarAssoc_ArrayObjectRead( PVal* pval, int* mptype )
{
	PVal* const pvInner = HspVarAssoc_IndexImpl<true>( pval );

	// assoc 自体の参照
	if ( !pvInner ) {
		*mptype = g_vtAssoc;
		return VtTraits::asPDAT<vtAssoc>(VtTraits::getValptr<vtAssoc>( pval ));
	}

	// [3] 内部変数の添字を処理
	if ( code_isNextArg() ) {
		return code_expand_index_rhs( pvInner, *mptype );

	} else {
		*mptype = pvInner->flag;
		return getHvp( pvInner->flag )->GetPtr( pvInner );
	}
}

//------------------------------------------------
// 連想配列::格納
//------------------------------------------------
static void HspVarAssoc_ObjectWrite( PVal* pval, PDAT const* data, int vflag )
{
	PVal* const pvInner = VtTraits::getAssocInnerVar(pval);

	// assoc への代入
	if ( !pvInner ) {
		if ( vflag != g_vtAssoc ) puterror( HSPERR_INVALID_ARRAYSTORE );

		HspVarAssoc_Set( pval, HspVarAssoc_GetPtr(pval), data );
		//code_assign_multi( pval );

	// 内部変数を参照している場合
	} else {
		PVal_assign( pvInner, data, vflag );	// 内部変数への代入処理
		code_assign_multi( pvInner );
	}

	return;
}

//------------------------------------------------
// メソッド呼び出し
// 
// @ 内部変数の型で提供されているメソッドを使う
//------------------------------------------------
static void HspVarAssoc_ObjectMethod(PVal* pval)
{
	PVal* const pvInner = VtTraits::getAssocInnerVar(pval);
	if ( !pvInner ) puterror( HSPERR_UNSUPPORTED_FUNCTION );

	// 内部変数の処理に転送
	getHvp(pvInner->flag)->ObjectMethod( pvInner );
	return;
}

//------------------------------------------------
// Assoc 登録関数
//------------------------------------------------
void HspVarAssoc_Init(HspVarProc* p)
{
	g_hvpAssoc = p;
	g_vtAssoc  = p->flag;

	p->GetUsing = HspVarAssoc_GetUsing;

	p->Alloc = HspVarAssoc_Alloc;
	p->Free  = HspVarAssoc_Free;

	p->GetPtr       = HspVarTemplate_GetPtr<vtAssoc>;
	p->GetSize      = HspVarTemplate_GetSize<vtAssoc>;
	p->GetBlockSize = HspVarTemplate_GetBlockSize<vtAssoc>;
	p->AllocBlock   = HspVarTemplate_AllocBlock<vtAssoc>;

	// 演算関数
	p->Set = HspVarAssoc_Set;

	HspVarTemplate_InitCmpI_Equality< HspVarAssoc_CmpI >(p);

	p->ObjectMethod    = HspVarAssoc_ObjectMethod;

	// 連想配列用
	p->ArrayObjectRead = HspVarAssoc_ArrayObjectRead;
	p->ArrayObject     = HspVarAssoc_ArrayObject;
	p->ObjectWrite     = HspVarAssoc_ObjectWrite;

	// 拡張データ
	p->user = reinterpret_cast<char*>(HspVarAssoc_GetMapList);

	// その他設定
	p->vartype_name = "assoc_k";		// タイプ名 (衝突しないように変な名前にする)
	p->version = 0x001;			// runtime ver(0x100 = 1.0)

	p->support							// サポート状況フラグ(HSPVAR_SUPPORT_*)
		= HSPVAR_SUPPORT_STORAGE		// 固定長ストレージ
		| HSPVAR_SUPPORT_FLEXARRAY		// 可変長配列
		| HSPVAR_SUPPORT_ARRAYOBJ		// 連想配列サポート
		| HSPVAR_SUPPORT_NOCONVERT		// ObjectWriteで格納
		| HSPVAR_SUPPORT_VARUSE			// varuse関数を適用
		;
	p->basesize = VtTraits::basesize<vtAssoc>::value;
	return;
}

//------------------------------------------------
// すべてのキーを列挙する
// 
// @ for knowbug
// @ リストの削除権限は呼び出し元にある。
//------------------------------------------------
// [[deprecated]]
static StAssocMapList* HspVarAssoc_GetMapList( assoc_t src )
{
	if ( !src || src->empty() ) return nullptr;

	StAssocMapList* head = nullptr;
	StAssocMapList* tail = nullptr;

	for ( auto iter : *src ) {
		auto const list = reinterpret_cast<StAssocMapList*>(hspmalloc(sizeof(StAssocMapList)));

		lstrcpy( list->key, iter.first.c_str() );
		list->pval = iter.second.getVar();

		// 連結
		if ( !head ) {
			head = list;
		} else {
			tail->next = list;
		}
		tail = list;
	}
	if ( tail ) tail->next = nullptr;

	return head;
}

//------------------------------------------------
// knowbug での拡張型表示に対応する
//------------------------------------------------
#include "knowbug/knowbugForHPI.h"

EXPORT void WINAPI knowbugVsw_addValueAssoc(vswriter_t _w, char const* name, PDAT const* ptr)
{
	auto const kvswm = knowbug_getVswMethods();
	if ( !kvswm ) return;

	auto const src = VtTraits::derefValptr<vtAssoc>(ptr);

	// null
	if ( !src) {
		kvswm->catLeafExtra(_w, name, "null_assoc");
	}

	// 要素なし
	if ( src->empty() ) {
		kvswm->catLeafExtra(_w, name, "empty_assoc");
		return;
	}

	for ( auto iter : *src ) {
		auto const& key = iter.first;
		auto const pval = iter.second.getVar();

		if ( kvswm->isLineformWriter(_w) ) {
			// pair: 「key: value...」
			kvswm->catNodeBegin(_w, nullptr, (key + ": ").c_str());
			kvswm->addVar(_w, nullptr, pval);
			kvswm->catNodeEnd(_w, "");
		} else {
			kvswm->addVar(_w, key.c_str(), pval);
		}

	}
	return;

}