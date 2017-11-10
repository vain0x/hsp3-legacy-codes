// assoc - Command code

#include "vt_assoc.h"
#include "cmd_assoc.h"

#include "mod_makepval.h"
#include "mod_argGetter.h"
#include "mod_varutil.h"
#include "reffuncResult.h"

using namespace hpimod;

// コマンドの返却値用
static assoc_t g_resultAssoc { nullptr };

//------------------------------------------------
// assoc 型の値を受け取る
//------------------------------------------------
assoc_t code_get_assoc()
{
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	if ( mpval->flag != g_vtAssoc ) puterror( HSPERR_TYPE_MISMATCH );

	auto const& self = VtTraits::derefValptr<vtAssoc>(mpval->pt);
	assert(!!self);

	return self;
}

//------------------------------------------------
// assoc の内部変数を受け取る
//
// @ 内部変数を指す添字がついていなければ、nullptr。
//------------------------------------------------
PVal* code_get_assocInner()
{
	PVal* pval = hpimod::code_get_var();
	if ( pval->flag != g_vtAssoc ) puterror(HSPERR_TYPE_MISMATCH);
	return VtTraits::getAssocInnerVar(pval);
}

//------------------------------------------------
// assoc 型の値を返却する
//------------------------------------------------
int SetReffuncResult( PDAT** ppResult, assoc_t&& assoc )
{
	g_resultAssoc = std::move(assoc);
	*ppResult = VtTraits::asPDAT<vtAssoc>(&g_resultAssoc);
	return g_vtAssoc;
}

//------------------------------------------------
// 構築 (リテラル風)
//------------------------------------------------
int AssocMake(PDAT** ppResult)
{
	assoc_t result;

	while ( code_isNextArg() ) {
		// key
		assocKey_t const key = code_gets();

		// value
		int const chk = code_getprm();
		auto const value = ( chk <= PARAM_END
			? ManagedVarData {}
			: ManagedVarData { mpval->pt, static_cast<vartype_t>(mpval->flag) }
		);

		result->insert({ std::move(key), std::move(value) });
	}
	return SetReffuncResult(ppResult, std::move(result.beTmpObj()));
}

//------------------------------------------------
// 構築 (複製)
//------------------------------------------------
int AssocDupShallow(PDAT** ppResult)
{
	assoc_t const&& src = code_get_assoc();
	if ( !src ) puterror(HSPERR_ILLEGAL_FUNCTION);

	assoc_t result = assoc_t::make(src->begin(), src->end());
	return SetReffuncResult(ppResult, std::move(result.beTmpObj()));
}

int AssocDupDeep(PDAT** ppResult)
{
	assoc_t const&& src = code_get_assoc();
	if ( !src ) puterror(HSPERR_ILLEGAL_FUNCTION);

	assoc_t result {};
	for ( auto const& iter : *src ) {
		result->emplace_hint(result->end(),
			std::make_pair(iter.first, ManagedVarData::duplicate(iter.second.getVar()))
		);
	}
	return SetReffuncResult(ppResult, std::move(result.beTmpObj()));
}

//------------------------------------------------
// 外部変数のインポート
//------------------------------------------------
static void AssocImportImpl( assoc_t self, char const* src );

void AssocImport()
{
	assoc_t const self = code_get_assoc();
	if ( !self ) puterror( HSPERR_ILLEGAL_FUNCTION );

	while ( code_isNextArg() ) {
		char const* const src = code_gets();
		AssocImportImpl( self, src );
	}
	return;
}

static void AssocImportImpl( assoc_t const self, char const* const src )
{
	// モジュール名
	if ( src[0] == '@' ) {
		puterror( HSPERR_UNSUPPORTED_FUNCTION );
		/*
		bool bGlobal = ( src[1] == '\0' );

		// すべての静的変数から絞り込み検索
		for ( int i = 0; i < ctx->hsphed->max_val; ++ i ) {
			char const* const name   = exinfo->HspFunc_varname( i );
			char const* const nameAt = strchr(name, '@');

			if (   ( bGlobal && nameAt == NULL )			// グローバル変数
				|| (!bGlobal && nameAt != NULL && !strcmp(nameAt + 1, src + 1) )	// モジュール内変数 (モジュール名一致)
			) {
				self->Insert( name, &ctx->mem_var[i] );
			}
		}
		//*/

	// 変数名
	} else {
		PVal* const pval = hpimod::seekSttVar(src);
		if ( pval ) {
			self->insert({ src, ManagedVarData { pval, pval->offset } });
		} else {
			puterror(HSPERR_ILLEGAL_FUNCTION);
		}
	}
	return;
}

//------------------------------------------------
// キーを挿入・除去する
// 
// @ キーは一つの引数として受け取る。
// @ 挿入はほぼ無意味。
//------------------------------------------------
void AssocInsert()
{
	auto&& self = code_get_assoc();
	char const* const key = code_gets();

	if ( !self ) puterror( HSPERR_ILLEGAL_FUNCTION );

	// 参照された内部変数
	PVal* const pvInner = assocAt(self, assocFindDynamic(self, key));

	// 初期値 (省略可能)
	if ( code_getprm() > PARAM_END ) {
		PVal_assign( pvInner, mpval->pt, mpval->flag );
	}
	return;
}

void AssocRemove()
{
	auto&& self = code_get_assoc();
	assocKey_t const key = code_gets();

	if ( !self ) puterror( HSPERR_ILLEGAL_FUNCTION );

	self->erase(key);
	return;
}

//------------------------------------------------
// 内部変数
//------------------------------------------------
void AssocDim()
{
	PVal* const pvInner = code_get_assocInner();
	if ( !pvInner ) puterror(HSPERR_VARIABLE_REQUIRED);

	code_dimtype(pvInner, code_get_vartype());
	return;
}

void AssocClone()
{
	PVal* const pvInner = code_get_assocInner();
	PVal* const pval = code_getpval();
	if ( !pvInner || !pval ) puterror(HSPERR_VARIABLE_REQUIRED);

	PVal_cloneVar(pval, pvInner);
	return;
}

int AssocVarinfo(PDAT** ppResult)
{
	PVal* const pvInner = code_get_assocInner();
	if ( !pvInner ) puterror(HSPERR_ILLEGAL_FUNCTION);

	return code_varinfo(pvInner);
}

//------------------------------------------------
// assoc 連結 | 複製
//------------------------------------------------
static void AssocChainOrCopy( bool bCopy )
{
	auto&& dst = code_get_assoc();
	auto&& src = code_get_assoc();
	if ( !dst || !src ) puterror( HSPERR_ILLEGAL_FUNCTION );

	if ( bCopy ) dst.reset();

	dst->insert(src->begin(), src->end());
	return;
}

void AssocCopy()  { AssocChainOrCopy( true  ); }
void AssocChain() { AssocChainOrCopy( false ); }

//------------------------------------------------
// assoc 消去
//------------------------------------------------
void AssocClear()
{
	assoc_t const self = code_get_assoc();
	if ( !self ) puterror( HSPERR_ILLEGAL_FUNCTION );

	self->clear();
	return;
}

//#########################################################
//        関数
//#########################################################
//------------------------------------------------
// null か
//------------------------------------------------
int AssocIsNull(PDAT** ppResult)
{
	assoc_t const&& self = code_get_assoc();
	return SetReffuncResult( ppResult, HspBool(!!self));
}

//------------------------------------------------
// 要素数
//------------------------------------------------
int AssocSize(PDAT** ppResult)
{
	assoc_t const&& self = code_get_assoc();
	size_t const size = (self ? self->size() : 0);
	return SetReffuncResult(ppResult, static_cast<int>(size));
}

//------------------------------------------------
// 指定キーが存在するか
//------------------------------------------------
int AssocExists(PDAT** ppResult)
{
	assoc_t&& self = code_get_assoc();
	char const* const key  = code_gets();

	return SetReffuncResult( ppResult, HspBool(self ? assocFindStatic(self, key) >= 0 : false) );
}

//------------------------------------------------
// AssocForeach 更新処理
//------------------------------------------------
int AssocForeachNext(PDAT** ppResult)
{
	assoc_t&& self = code_get_assoc();
	PVal* const pval = code_get_var();	// iter (key)
	int const idx = code_geti();

	bool bContinue =			// 続けるか否か
		( !!self && idx >= 0
		&& static_cast<size_t>(idx) < self->size()
		);

	if ( bContinue ) {
		auto iter = self->begin();
		std::advance(iter, idx);	// 要素 [idx] への反復子を取得する

		// キーの文字列を代入する
		code_setva( pval, pval->offset, HSPVAR_FLAG_STR, iter->first.c_str() );
	}

	return SetReffuncResult( ppResult, HspBool(bContinue) );
}

//------------------------------------------------
// assoc 式
//------------------------------------------------
static int const AssocResultExprMagicNumber = 0xA550C;

int AssocResult( PDAT** ppResult )
{
	g_resultAssoc = code_get_assoc();
	return SetReffuncResult(ppResult, AssocResultExprMagicNumber);
}

int AssocExpr( PDAT** ppResult )
{
	// AssocResult が呼ばれるはず
	if ( code_geti() != AssocResultExprMagicNumber ) puterror(HSPERR_ILLEGAL_FUNCTION);


	*ppResult = VtTraits::asPDAT<vtAssoc>(&g_resultAssoc);
	return g_vtAssoc;
}

//------------------------------------------------
// 終了時関数
//------------------------------------------------
void AssocTerm()
{
	g_resultAssoc.nullify();
	return;
}
