// call.hpi interface

#include "hsp3plugin_custom.h"
#include "cmdfuncTemplate.h"

#include "iface_call.h"
#include "cmd_call.h"
#include "cmd_modcls.h"
#include "vt_functor.h"

#include "Invoker.h"

using namespace hpimod;

int g_pluginType_call = -1;

//------------------------------------------------
// 命令
//------------------------------------------------
static int ProcSttmCmd( int cmd )
{
#define _CmdlistModeProcess 'S'
# include "cmdlistMacro.h"
#include "../../package/callcmd.cmdlist.txt"
# include "cmdlistMacro.h"
#undef _CmdlistModeProcess
	return RUNMODE_RUN;
}

//------------------------------------------------
// 関数
//------------------------------------------------
static int ProcFuncCmd( int cmd, PDAT** ppResult )
{
#define _CmdlistModeProcess 'F'
# include "cmdlistMacro.h"
#include "../../package/callcmd.cmdlist.txt"
# include "cmdlistMacro.h"
#undef _CmdlistModeProcess
	assert(false); throw;
}

//------------------------------------------------
// システム変数
//------------------------------------------------
static int ProcSysvarCmd( int cmd, PDAT** ppResult )
{
#define _CmdlistModeProcess 'V'
# include "cmdlistMacro.h"
#include "../../package/callcmd.cmdlist.txt"
# include "cmdlistMacro.h"
#undef _CmdlistModeProcess
	assert(false); throw;
}

//------------------------------------------------
// 終了時
//------------------------------------------------
static int termfunc(int option)
{
	g_resFunctor.nullify();

	Functor::Terminate();
	Caller::clearLastResult();
//	Proto_Term();
//	ModOp_Term();
	return 0;
}

//------------------------------------------------
// str, double, int をシステム変数として使えるようにする
// 
// @ それぞれ対応する型タイプ値を返却する。
// @ かなり遅くなるのでやらない。
//------------------------------------------------
static void*(*reffunc_intfunc_impl)(int*, int);

int reffunc_intfunc_procSysvar( int cmd, PDAT** ppResult )
{
	switch ( cmd ) {
		case 0x000: return SetReffuncResult( ppResult, HSPVAR_FLAG_INT );		// int()
		case 0x100: return SetReffuncResult( ppResult, HSPVAR_FLAG_STR );		// str()
		case 0x185: return SetReffuncResult( ppResult, HSPVAR_FLAG_DOUBLE );	// double()
		default:    puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;	// 警告抑制
}

void* reffunc_intfunc_wrap( int* type_res, int cmd )
{
	if ( !(*type == TYPE_MARK && *val == '(') ) {
		PDAT* pResult;
		*type_res = reffunc_intfunc_procSysvar( cmd, &pResult );
		return pResult;
	} else {
		return reffunc_intfunc_impl( type_res, cmd );
	}
}

void wrap_reffunc_intfunc(HSP3TYPEINFO* info)
{
	if ( info->type != TYPE_INTFUNC ) return;

	reffunc_intfunc_impl = info->reffunc;
	info->reffunc = reffunc_intfunc_wrap;
	return;
}

//------------------------------------------------
// HPI登録関数
//------------------------------------------------
EXPORT void WINAPI hsp3typeinfo_call(HSP3TYPEINFO* info)
{
	g_pluginType_call = info->type;

	hsp3sdk_init(info);			// SDKの初期化(最初に行なって下さい)

	info->cmdfunc = cmdfunc<&ProcSttmCmd>;
	info->reffunc = reffunc<&ProcFuncCmd, &ProcSysvarCmd>;
	info->termfunc = termfunc;

	// functor 型を登録
	registvar(-1, HspVarFunctor_init);

	// TYPE_INTFUNC のラッピング
//	wrap_reffunc_intfunc( &(info - g_pluginType_call)[TYPE_INTFUNC] );	// info が HSP3TYPEINFO[] であることが前提
	return;
}
