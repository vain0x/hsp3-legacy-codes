// var_modcmd - command

#include "hpimod/hsp3plugin_custom.h"
#include "hpimod/reffuncResult.h"
#include "hpimod/mod_moddata.h"

#include "iface_modcmd.h"
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

//------------------------------------------------
// 呼び出し処理
// 
// @prm ppResult:
// @	nullptr なら命令呼び出しで、この関数は無意味な値を返す
//------------------------------------------------
int modcmdCall( modcmd_t modcmd, PDAT** ppResult )
{
	if ( !VtModcmd::isValid(modcmd) ) puterror(HSPERR_INVALID_ARRAY);
	
	stdat_t const stdat = getSTRUCTDAT(modcmd);
	
	if ( ppResult && stdat->index == STRUCTDAT_INDEX_FUNC ) {	// 命令の関数形式呼び出しを禁止
		puterror( HSPERR_SYNTAX);
	}
	
	// 引数列を取り出す
	void* const prmstk = hspmalloc( stdat->size );
	code_expandstruct( prmstk, stdat, CODE_EXPANDSTRUCT_OPT_LOCALVAR );	// local を variant 引数として展開する設定
	
	if ( !(*exinfo->npexflg & EXFLG_1) && !(*type == TYPE_MARK && *val == ')') ) {
		puterror(HSPERR_TOO_MANY_PARAMETERS);
	}
	
	// prmstack を差し替えて実行
	{
		void* const prmstk_bak = ctx->prmstack;
		ctx->prmstack = prmstk;
		
		code_call( getLabel(stdat->otindex) );
		
		ctx->prmstack = prmstk_bak;
	}

	// prmstack を解体
	customstack_delete(stdat, prmstk);
	
	// 返値を設定
	// return で返値が設定されなかった場合 → HSPERR_NO_RETVAL ; 検知するのは(黒魔術なしでは)難しい？
	PVal* const mpval = *exinfo->mpval;
	
	if ( ppResult ) {
		*ppResult = mpval->pt;
		return mpval->flag;
	} else {
		return 0; //dummy value
	}
}

//------------------------------------------------
// 呼び出し (forward)
// 
// 命令形式：
//	call modcmd : call_nocall args...
// 関数形式：
//	call( modcmd, call_nocall(args...) )
//------------------------------------------------
void modcmdCallForwardSttm()
{
	modcmd_t const modcmd = code_get_modcmd();
	if ( !VtModcmd::isValid(modcmd) ) puterror(HSPERR_INVALID_ARRAY);
	
	*type = TYPE_MODCMD;
	*val  = modcmd;
	*exinfo->npexflg = EXFLG_1;
	return;
}

int modcmdCallForwardFunc(PDAT** ppResult)
{
	modcmd_t const modcmd = code_get_modcmd();
	if ( !VtModcmd::isValid(modcmd) ) puterror(HSPERR_INVALID_ARRAY);
	
	*type = TYPE_MODCMD;
	*val  = modcmd;
	*exinfo->npexflg = 0;
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	
	*ppResult = mpval->pt;
	return mpval->flag;
}

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
	if ( getSTRUCTDAT(modcmdId)->index == STRUCTDAT_INDEX_STRUCT ) puterror(HSPERR_ILLEGAL_FUNCTION);
	
	return modcmdId;
}
