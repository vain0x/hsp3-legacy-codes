/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*
*		jump.hpi
*				author Ue-dai @2008 12/27(Sat)
*
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

#include "dllmain.h"
#include "cmd.h"

// 関数宣言
extern int    cmdfunc(int cmd);
extern void  *reffunc(int *type_res, int cmd);

extern int   ProcFunc(int cmd, void **ppResult);
extern int ProcSysvar(int cmd, void **ppResult);

//###############################################
//        命令コマンド呼び出し関数
//###############################################
static int cmdfunc(int cmd)
{
	code_next();
	
	switch( cmd ) {
		case 0x000: jump_st(); break;
		case 0x001: code_setpc( code_getlb() ); break;
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return RUNMODE_RUN;
}

//###############################################
//        関数コマンド呼び出し関数
//###############################################
static void *reffunc(int *type_res, int cmd)
{
	void *pResult = NULL;
	
//	if ( *type != TYPE_MARK || *val != '(' ) {
//		
//		*type_res = ProcSysvar( cmd, &pResult );
//		
//	} else {
		
		// '('で始まるかを調べる
		if ( *type != TYPE_MARK || *val != '(' ) puterror( HSPERR_INVALID_FUNCPARAM );
		code_next();
		
		// コマンド分岐
		*type_res = ProcFunc( cmd, &pResult );
		
		// '('で終わるかを調べる
		if ( *type != TYPE_MARK || *val != ')' ) puterror( HSPERR_INVALID_FUNCPARAM );
		code_next();
//	}
	
	if ( pResult == NULL ) puterror( HSPERR_NORETVAL );
	
	return pResult;
}

//###############################################
//        関数コマンド処理関数
//###############################################
static int ProcFunc(int cmd, void **ppResult)
{
	switch ( cmd ) {
		case 0x000: return jump_f(ppResult);
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//###############################################
//        システム変数コマンド処理関数
//###############################################
/*
static int ProcSysvar(int cmd, void **ppResult)
{
	switch ( cmd ) {
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}
//*/

//###############################################
//        プラグイン初期化関数
//###############################################
EXPORT void WINAPI hsp3hpi_init(HSP3TYPEINFO *info)
{
	hsp3sdk_init( info );			// SDKの初期化
	
	info->cmdfunc  = cmdfunc;		// 実行関数(cmdfunc)の登録
	info->reffunc  = reffunc;		// 参照関数(reffunc)の登録
//	info->termfunc = termfunc;		// 終了関数(termfunc)の登録
	
	return;
}
