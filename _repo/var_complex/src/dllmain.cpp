#include <windows.h>
#include "hsp3plugin_custom.h"

#include "dllmain.h"
#include "vp_complex.h"
#include "cmd.h"

static int    cmdfunc( int cmd );
static void*  reffunc( int* type_res, int cmd );

static int   ProcFunc( int cmd, void** ppResult );
static int ProcSysvar( int cmd, void** ppResult );

//------------------------------------------------
// 命令コマンド呼び出し関数
//------------------------------------------------
static int cmdfunc(int cmd)
{
	code_next();
	
	switch ( cmd ) {
		case 0x000: dimtype( HSPVAR_FLAG_COMPLEX ); break;
			
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return RUNMODE_RUN;
}

//------------------------------------------------
// 関数コマンド呼び出し関数
//------------------------------------------------
static void* reffunc( int* type_res, int cmd )
{
	void *pResult = NULL;
	
	if ( *type != TYPE_MARK || *val != '(' ) {
		
		*type_res = ProcSysvar( cmd, &pResult );
		
	} else {
		
		// '('で始まるかを調べる
		if ( *type != TYPE_MARK || *val != '(' ) puterror( HSPERR_INVALID_FUNCPARAM );
		code_next();
		
		// コマンド分岐
		*type_res = ProcFunc( cmd, &pResult );
		
		// '('で終わるかを調べる
		if ( *type != TYPE_MARK || *val != ')' ) puterror( HSPERR_INVALID_FUNCPARAM );
		code_next();
	}
	
	if ( pResult == NULL ) puterror( HSPERR_NORETVAL );
	
	return pResult;
}

//------------------------------------------------
// 関数コマンド処理関数
//------------------------------------------------
static int ProcFunc( int cmd, void** ppResult )
{
	switch ( cmd ) {
		case 0x000: return complex_ctor( ppResult, false );
		case 0x100: return complex_ctor( ppResult, true );
		case 0x101: return complex_info( ppResult );
		case 0x102: return complex_opUnary ( ppResult, cmd );
		case 0x103: return complex_opBinary( ppResult, cmd );
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//------------------------------------------------
// システム変数コマンド処理関数
//------------------------------------------------
static int ProcSysvar( int cmd, void** ppResult )
{
	switch ( cmd ) {
		case 0x000: return complex_vt( ppResult );
			
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//------------------------------------------------
// プラグイン初期化関数
//------------------------------------------------
EXPORT void WINAPI hsp3hpi_init( HSP3TYPEINFO* info )
{
	hsp3sdk_init( info );			// SDKの初期化
	
	info->cmdfunc  = cmdfunc;
	info->reffunc  = reffunc;
	
	registvar( -1, (HSPVAR_COREFUNC)HspVarComplex_Init );
}
