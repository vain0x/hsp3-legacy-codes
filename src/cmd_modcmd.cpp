// var_modcmd - command

#include "hsp3plugin_custom.h"
#include "mod_func_result.h"
#include "mod_moddata.h"

#include "cmd_modcmd.h"
#include "vt_modcmd.h"

using namespace hpimod;

//------------------------------------------------
// modcmd 型の引数を取得する
//------------------------------------------------
modcmd_t code_get_modcmd()
{
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	if ( mpval->flag != g_vtModcmd ) puterror( HSPERR_TYPE_MISMATCH );
	return VtModcmd::at(mpval);
}

//##############################################################################
//        命令コマンド
//##############################################################################
//------------------------------------------------
// 呼び出し処理
// 
// @prm ppResult:
// @	nullptr なら命令呼び出しで、この関数は無意味な値を返す
//------------------------------------------------
int modcmdCall( modcmd_t modcmd, void** ppResult )
{
	if ( !VtModcmd::isValid(modcmd) ) puterror(HSPERR_INVALID_ARRAY);
	
	stdat_t const stdat = GetSTRUCTDAT(modcmd);
	
	if ( ppResult && stdat->index == STRUCTDAT_INDEX_FUNC ) {	// 命令の関数形式呼び出しを禁止
		puterror( HSPERR_SYNTAX);
	}
	
	// 引数列を取り出す
	void* prmstk = hspmalloc( stdat->size );
	code_expandstruct( prmstk, stdat, CODE_EXPANDSTRUCT_OPT_LOCALVAR );	// local を variant 引数として展開する設定
	
	if ( !(*exinfo->npexflg & EXFLG_1) && !(*type == TYPE_MARK && *val == ')') ) {
		puterror(HSPERR_TOO_MANY_PARAMETERS);
	}
	
	// prmstack を差し替えて実行
	{
		void* const prmstk_bak = ctx->prmstack;
		ctx->prmstack = prmstk;
		
		code_call( GetLabel(stdat->otindex) );
		
		ctx->prmstack = prmstk_bak;
	}

	// prmstack を解体
	customstack_delete(stdat, prmstk);
	
	// 返値を設定
	PVal*& real_mpval = *exinfo->mpval;
	
	if ( ppResult ) {
		*ppResult = real_mpval->pt;
		return real_mpval->flag;
	} else {
		return 0;
	}
}

//##############################################################################
//        関数コマンド
//##############################################################################
//------------------------------------------------
// ユーザ定義命令・関数の ID を取り出す
//------------------------------------------------
int code_get_modcmdId()
{
	if ( *type != TYPE_MODCMD ) puterror(HSPERR_TYPE_MISMATCH);
	int const modcmdId = *val;
	code_next();
	
	// 次が文頭や式頭ではなく、')' でもない → 与えられた引数式が2字句以上でできている
	if ( !((*exinfo->npexflg & (EXFLG_1 | EXFLG_2)) != 0 || (*type == TYPE_MARK && *val == ')')) )
		puterror(HSPERR_ILLEGAL_FUNCTION);
	
	// モジュールクラス識別子は認めない
	if ( GetSTRUCTDAT(modcmdId)->index == STRUCTDAT_INDEX_STRUCT ) puterror(HSPERR_ILLEGAL_FUNCTION);
	
	return modcmdId;
}

//##############################################################################
//        システム変数コマンド
//##############################################################################
//------------------------------------------------
// 
//------------------------------------------------

//##############################################################################
//        その他
//##############################################################################

