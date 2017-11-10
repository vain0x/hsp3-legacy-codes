#include "dllmain.h"
#include "cmd_valptr.h"

extern int g_pluginType_valptr = -1;

extern int   ProcFunc( int cmd, void** ppResult );
//extern int ProcSysvar( int cmd, void** ppResult );

//-----------------------------------------------
// 命令コマンド呼び出し関数
//-----------------------------------------------
static int cmdfunc( int cmd )
{
	code_next();
	
	switch( cmd ) {
		case 0x112: FromValptr(); break;
		
#ifdef _DEBUG
		case 0x0FF: Hpi_test(); break;
#endif
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return RUNMODE_RUN;
}

//-----------------------------------------------
// 関数コマンド呼び出し関数
//-----------------------------------------------
static void* reffunc( int* type_res, int cmd )
{
	void* pResult = NULL;
	
	// '('で始まるかを調べる : 始まらなければシステム変数
	if ( *type != TYPE_MARK || *val != '(' ) {
		
	//	*type_res = ProcSysvar( cmd, &pResult );
		
	} else {
		
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

//-----------------------------------------------
// 関数コマンド処理関数
//-----------------------------------------------
static int ProcFunc( int cmd, void** ppResult )
{
	switch ( cmd ) {
		case 0x100:	return Valtype( ppResult );
		
		case 0x110: return NewValptr( ppResult );
		case 0x112: return FromValptr( ppResult );
		
		case 0x120: return Assign( ppResult );
		
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//-----------------------------------------------
// システム変数コマンド処理関数
//-----------------------------------------------
/*
static int ProcSysvar( int cmd, void** ppResult )
{
	switch ( cmd ) {
		case 0:
	//	case 0x030: return SetReffuncResult( ppResult, HSPVAR_FLAG_CALLER );
		
	//	case 0x200:	return Call_thislb( ppResult );	// call_thislb
			
	//	case valptrCmdId::ByRef: //
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//*/

//-----------------------------------------------
// 終了時呼び出し関数
//-----------------------------------------------
static int termfunc( int option )
{
	TermValptr();
	return 0;
}

//-----------------------------------------------
// プラグイン初期化関数
//-----------------------------------------------
EXPORT void WINAPI hsp3hpi_init( HSP3TYPEINFO* info )
{
	g_pluginType_valptr = info->type;
	
	hsp3sdk_init( info ); // SDKの初期化(最初に行なって下さい)
	
	info->cmdfunc  = cmdfunc;
	info->reffunc  = reffunc;
	info->termfunc = termfunc;
	
	return;
}
