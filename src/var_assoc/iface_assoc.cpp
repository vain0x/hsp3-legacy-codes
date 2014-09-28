/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 |
 *		hsp plugin interface (assoc)
 |
 *				author uedai
 |
.*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

#include "iface_assoc.h"
#include "CAssoc.h"
#include "vt_assoc.h"
#include "cmd_assoc.h"

#include "hsp3plugin_custom.h"
#include "reffuncResult.h"
#include "mod_varutil.h"

using namespace hpimod;

//------------------------------------------------
// 命令
//------------------------------------------------
static int ProcSttmCmd( int cmd )
{
	switch ( cmd ) {
		case 0x000: code_dimtype(code_getpval(), g_vtAssoc); break;
		//case 0x001: break;
		case 0x002: AssocClear();  break;
		case 0x003: AssocChain();  break;
		case 0x004: AssocCopy();   break;

		case 0x010: AssocImport(); break;
		case 0x011: AssocInsert(); break;
		case 0x012: AssocRemove(); break;

		case 0x020: AssocDim();   break;
		case 0x021: AssocClone(); break;

		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}

	return RUNMODE_RUN;
}

//------------------------------------------------
// 関数
//------------------------------------------------
static int ProcFuncCmd( int cmd, PDAT** ppResult )
{
	switch ( cmd ) {
		case 0x000: return AssocMake(ppResult);

		case 0x021:
			AssocClone();
			return SetReffuncResult( ppResult, 0 );		// 添字 0 を返す

		case 0x100:	return AssocVarinfo(ppResult);
		case 0x101: return AssocSize(ppResult);
		case 0x102: return AssocExists(ppResult);
		case 0x103: return AssocForeachNext(ppResult);
		case 0x104: return AssocResult( ppResult );
		case 0x105: return AssocExpr( ppResult );
		case 0x106: return AssocDupShallow(ppResult);
		case 0x107: return AssocDupDeep(ppResult);

		//case 0x200: return AssocIsNull( ppResult );

		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//------------------------------------------------
// システム変数
//------------------------------------------------
static int ProcSysvarCmd( int cmd, PDAT** ppResult )
{
	switch ( cmd ) {
		case 0x000: return hpimod::SetReffuncResult( ppResult, g_vtAssoc );	// assoc

		//case 0x200: return SetReffuncResult(ppResult, nullptr);		// AssocNull

		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//------------------------------------------------
// 終了時
//------------------------------------------------
static int termfunc(int option)
{
	AssocTerm();
	return 0;
}

//------------------------------------------------
// HPI登録関数
//------------------------------------------------
EXPORT void WINAPI hpi_assoc( HSP3TYPEINFO* info )
{
	hsp3sdk_init( info );			// SDKの初期化(最初に行なって下さい)

	info->cmdfunc  = hpimod::cmdfunc<ProcSttmCmd>;
	info->reffunc  = hpimod::reffunc<ProcFuncCmd, ProcSysvarCmd>;
	info->termfunc = termfunc;

	// 新規型を追加
	registvar(-1, HspVarAssoc_Init);
	return;
}
