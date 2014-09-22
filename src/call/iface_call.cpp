// call.hpi interface

#include "hsp3plugin_custom.h"

#include "iface_call.h"
#include "cmd_call.h"
#include "cmd_modcls.h"
#include "vt_functor.h"

#include "Invoker.h"

using namespace hpimod;

int g_pluginType_call = -1;

//------------------------------------------------
// –½—ß
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
// ŠÖ”
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
// ƒVƒXƒeƒ€•Ï”
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
// I—¹Žž
//------------------------------------------------
static int termfunc(int option)
{
	g_resFunctor.nullify();

	Functor::Terminate();
	Invoker::clearLastResult();
//	Proto_Term();
//	ModOp_Term();
	return 0;
}

//------------------------------------------------
// str, double, int ‚ðƒVƒXƒeƒ€•Ï”‚Æ‚µ‚ÄŽg‚¦‚é‚æ‚¤‚É‚·‚é
// 
// @ ‚»‚ê‚¼‚ê‘Î‰ž‚·‚éŒ^ƒ^ƒCƒv’l‚ð•Ô‹p‚·‚éB
// @ ‚©‚È‚è’x‚­‚È‚é‚Ì‚Å‚â‚ç‚È‚¢B
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
	return 0;	// Œx—}§
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
// HPI“o˜^ŠÖ”
//------------------------------------------------
EXPORT void WINAPI hsp3typeinfo_call(HSP3TYPEINFO* info)
{
	g_pluginType_call = info->type;

	hsp3sdk_init(info);			// SDK‚Ì‰Šú‰»(Å‰‚És‚È‚Á‚Ä‰º‚³‚¢)

	info->cmdfunc = cmdfunc<&ProcSttmCmd>;
	info->reffunc = reffunc<&ProcFuncCmd, &ProcSysvarCmd>;
	info->termfunc = termfunc;

	// functor Œ^‚ð“o˜^
	registvar(-1, reinterpret_cast<HSPVAR_COREFUNC>(HspVarFunctor_init));

	// TYPE_INTFUNC ‚Ìƒ‰ƒbƒsƒ“ƒO
//	wrap_reffunc_intfunc( &(info - g_pluginType_call)[TYPE_INTFUNC] );	// info ‚ª HSP3TYPEINFO[] ‚Å‚ ‚é‚±‚Æ‚ª‘O’ñ
	return;
}
