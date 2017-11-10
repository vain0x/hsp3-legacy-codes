// hsp plugin interface (var_modcmd)

#include "iface_modcmd.h"
#include "vt_modcmd.h"
#include "cmd_modcmd.h"

#include "hpimod/hsp3plugin_custom.h"
#include "hpimod/reffuncResult.h"
#include "hpimod/cmdfuncTemplate.h"
#include "hpimod/mod_varutil.h" // for modcmdDim

using namespace hpimod;

int g_pluginModcmd;

//------------------------------------------------
// ñΩóﬂ
//------------------------------------------------
static int ProcSttmCmd( int cmd )
{
	switch ( cmd ) {
		case 0x000: hpimod::code_dimtypeEx(g_vtModcmd); break;
		case 0x001: modcmdCall( code_get_modcmd() ); break;
		case 0x002: modcmdCallForwardSttm(); break;
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	
	return RUNMODE_RUN;
}

//------------------------------------------------
// ä÷êî
//------------------------------------------------
static int ProcFuncCmd( int cmd, PDAT** ppResult )
{
	switch ( cmd ) {
	//	case 0x000: return modcmdCnv(ppResult);
		case 0x001: return modcmdCall( code_get_modcmd(), ppResult );
		case 0x002: return modcmdCallForwardFunc( ppResult );
		case 0x100: return hpimod::SetReffuncResult( ppResult, code_get_modcmdId() );
		case 0x101: return hpimod::SetReffuncResult<vtModcmd>( ppResult, VtModcmd::make(code_get_modcmdId()), g_vtModcmd );
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION ); throw;
	}
}

//------------------------------------------------
// ÉVÉXÉeÉÄïœêî
//------------------------------------------------
static int ProcSysvarCmd( int cmd, PDAT** ppResult )
{
	switch ( cmd ) {
		case 0x000: return hpimod::SetReffuncResult<int>(ppResult, g_vtModcmd);

	//	case MocmdCmd::NoCall:
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION ); throw;
	}
}

//------------------------------------------------
// HPIìoò^ä÷êî
//------------------------------------------------
EXPORT void WINAPI hpi_modcmd(HSP3TYPEINFO* info)
{
	g_pluginModcmd = info->type;
	hsp3sdk_init(info);

	registvar(-1, HspVarModcmd_Init);

	info->cmdfunc = &hpimod::cmdfunc<&ProcSttmCmd>;
	info->reffunc = &hpimod::reffunc<&ProcFuncCmd, &ProcSysvarCmd>;
}
