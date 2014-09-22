// call - SubCommand

#include <stack>
#include <map>

#include "hsp3plugin_custom.h"
#include "mod_varutil.h"
#include "mod_argGetter.h"

#include "cmd_sub.h"

#include "CPrmInfo.h"
#include "Functor.h"

#include "CBound.h"

#include "vt_functor.h"

using namespace hpimod;

//##########################################################
//       仮引数リスト
//##########################################################
// 仮引数宣言データ
static std::map<label_t, CPrmInfo> g_prmlistLabel;

//------------------------------------------------
// 仮引数リストの宣言
//------------------------------------------------
CPrmInfo const& DeclarePrmInfo(label_t lb, CPrmInfo&& prminfo)
{
	if ( &GetPrmInfo(lb) != &CPrmInfo::undeclaredFunc ) {
		dbgout("多重定義です。");
		puterror(HSPERR_ILLEGAL_FUNCTION);
	}
	return g_prmlistLabel.insert({ lb, std::move(prminfo) }).first->second;
}

//------------------------------------------------
// 仮引数の取得 (ラベル)
//------------------------------------------------
CPrmInfo const& GetPrmInfo(label_t lb)
{
	auto const iter = g_prmlistLabel.find(lb);
	return (iter != g_prmlistLabel.end())
		? iter->second
		: CPrmInfo::undeclaredFunc;
}

CPrmInfo const& GetPrmInfo(stdat_t stdat)
{
	assert(stdat->index == STRUCTDAT_INDEX_FUNC || stdat->index == STRUCTDAT_INDEX_CFUNC);
	auto const lb = hpimod::getLabel(stdat->otindex);

	auto const iter = g_prmlistLabel.find(lb);
	if ( iter != g_prmlistLabel.end() ) {
		return iter->second;
	} else {
		return DeclarePrmInfo(lb, CPrmInfo::Create(stdat));
	}
}

#if 0
//------------------------------------------------
// CPrmInfo <- 中間コード
// 
// @prm: [ label, (prmlist) ]
//------------------------------------------------
CPrmInfo const& code_get_prminfo()
{
	{
		int const chk = code_getprm();
		if ( chk <= PARAM_END ) puterror(HSPERR_NO_DEFAULT);
	}

	// label
	if ( mpval->flag == HSPVAR_FLAG_LABEL ) {
		auto const lb = VtTraits::derefValptr<vtLabel>(mpval->pt);
		CPrmInfo::prmlist_t&& prmlist = code_get_prmlist();
		return CPrmInfo(&prmlist);

	// axcmd
	} else if ( mpval->flag == HSPVAR_FLAG_INT ) {
		int const axcmd = VtTraits::derefValptr<vtInt>(mpval->pt);

		if ( AxCmd::getType(axcmd) != TYPE_MODCMD ) puterror(HSPERR_ILLEGAL_FUNCTION);
		return GetPrmInfo(getSTRUCTDAT(AxCmd::getCode(axcmd)));

	// functor
	} else if ( mpval->flag == g_vtFunctor ) {
		return VtTraits::derefValptr<vtFunctor>(mpval->pt)->getPrmInfo();

	} else {
		puterror(HSPERR_LABEL_REQUIRED);
	}
}
#endif

//------------------------------------------------
// 仮引数列を取得する
//------------------------------------------------
CPrmInfo::prmlist_t code_get_prmlist()
{
	CPrmInfo::prmlist_t prmlist;

	// 仮引数リスト
	while ( code_isNextArg() ) {
		auto const prmtype = code_get_prmtype(PrmType::None);
		if ( prmtype == PrmType::None ) puterror(HSPERR_ILLEGAL_FUNCTION);

		prmlist.push_back(prmtype);
	}

	return std::move(prmlist);
}
