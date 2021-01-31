// exstrf.hpi

#include "dllmain.h"
#include "cmd.h"

// 関数宣言
extern int    cmdfunc(int cmd);
extern void  *reffunc(int *type_res, int cmd);

extern int   ProcFunc(int cmd, void **ppResult);

//------------------------------------------------
// 命令コマンド呼び出し関数
//------------------------------------------------
static int cmdfunc(int cmd)
{
	code_next();
	
	switch( cmd ) {
		case 0x000: strncpy(ctx->refstr, exstrf(), HSPCTX_REFSTR_MAX - 1); break;
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return RUNMODE_RUN;
}

//------------------------------------------------
// 関数コマンド呼び出し関数
//------------------------------------------------
static void *reffunc(int *type_res, int cmd)
{
	void *pResult = NULL;
	
	// '('で始まるかを調べる
	if ( *type != TYPE_MARK || *val != '(' ) puterror( HSPERR_INVALID_FUNCPARAM );
	code_next();
	
	// コマンド分岐
	*type_res = ProcFunc( cmd, &pResult );
	
	// '('で終わるかを調べる
	if ( *type != TYPE_MARK || *val != ')' ) puterror( HSPERR_INVALID_FUNCPARAM );
	code_next();
	
	if ( pResult == NULL ) puterror( HSPERR_NORETVAL );
	
	return pResult;
}

//------------------------------------------------
// 関数コマンド処理関数
//------------------------------------------------
static int ProcFunc(int cmd, void **ppResult)
{
	switch ( cmd ) {
		case 0x000: *ppResult = exstrf(); return HSPVAR_FLAG_STR;
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//------------------------------------------------
// プラグイン初期化関数
//------------------------------------------------
EXPORT void WINAPI hsp3hpi_init(HSP3TYPEINFO *info)
{
	hsp3sdk_init( info ); // SDKの初期化(最初に行なって下さい)
	
	info->cmdfunc  = cmdfunc; // 実行関数(cmdfunc)の登録
	info->reffunc  = reffunc; // 参照関数(reffunc)の登録
}
