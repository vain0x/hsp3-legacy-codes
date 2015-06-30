// hsp plugin interface (var_modcmd)

#include "iface_modcmd.h"
#include "vt_modcmd.h"
#include "cmd_modcmd.h"
#include "mod_varutil.h"	// for modcmdDim

#include "hsp3plugin_custom.h"
#include "mod_func_result.h"

using namespace hpimod;

int g_pluginModcmd;

static int  cmdfunc( int cmd );
static int termfunc( int option );

static int   ProcSttmCmd( int cmd );
static int   ProcFuncCmd( int cmd, void** ppResult );
static int ProcSysvarCmd( int cmd, void** ppResult );

//##########################################################
//        HPI処理
//##########################################################
//------------------------------------------------
// HPI登録関数
//------------------------------------------------
EXPORT void WINAPI hpi_modcmd( HSP3TYPEINFO* info )
{
	g_pluginModcmd = info->type;
	hsp3sdk_init( info );			// SDKの初期化(最初に行なって下さい)
	
	HSPVAR_COREFUNC corefunc = HspVarModcmd_Init;
	registvar(-1, corefunc);		// 新規型を追加
	
	info->cmdfunc  = cmdfunc<&ProcSttmCmd>;
	info->reffunc  = reffunc<&ProcFuncCmd, &ProcSysvarCmd>;
	info->termfunc = termfunc;
	
	return;
}

//------------------------------------------------
// 終了時
//------------------------------------------------
static int termfunc(int option)
{
	return 0;
}

//##########################################################
//        コマンド処理
//##########################################################
//------------------------------------------------
// 命令
//------------------------------------------------
static int ProcSttmCmd( int cmd )
{
	switch ( cmd ) {
		case 0x000: dimtypeEx(g_vtModcmd); break;
		case 0x001: modcmdCall( code_get_modcmd() ); break;
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	
	return RUNMODE_RUN;
}

//------------------------------------------------
// 関数
//------------------------------------------------
static int ProcFuncCmd( int cmd, void** ppResult )
{
	switch ( cmd ) {
	//	case 0x000: return modcmdCnv(ppResult);
		case 0x001: return modcmdCall( code_get_modcmd(), ppResult );
		case 0x100: return hpimod::SetReffuncResult( ppResult, code_get_modcmdId() );
		case 0x101: return hpimod::SetReffuncResult( ppResult, VtModcmd::make(code_get_modcmdId()), g_vtModcmd);
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//------------------------------------------------
// システム変数
//------------------------------------------------
static int ProcSysvarCmd( int cmd, void** ppResult )
{
	switch ( cmd ) {
		case 0x000: return SetReffuncResult(ppResult, g_vtModcmd);

	//	case MocmdCmd::NoCall:
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}
