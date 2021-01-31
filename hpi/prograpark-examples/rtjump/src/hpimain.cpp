/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*
*		jump.hpi / rtjump
*				author uedai
*
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

#include "hpimain.h"
#include "hsp3exrt.h"

// 関数宣言
static int cmdfunc( int cmd );

//------------------------------------------------
// 命令コマンド呼び出し関数
//------------------------------------------------
static int cmdfunc( int cmd )
{
	code_next();
	
	switch( cmd ) {
		case 0x000: code_call( code_getlb() ); break;
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	
	return RUNMODE_RUN;
}

//------------------------------------------------
// プラグイン初期化関数
//------------------------------------------------
HPIINIT(void) hsp3typeinit_jump( HSP3TYPEINFO* info )
{
	hsp3sdk_init( info );			// SDKの初期化
	info->cmdfunc  = cmdfunc;		// 実行関数(cmdfunc)の登録
	return;
}

#ifndef HSPEXRT

//------------------------------------------------
// Dll エントリーポイント
//------------------------------------------------
BOOL WINAPI DllMain( HINSTANCE hInstance, DWORD fdwReason, PVOID pvReserved )
{
	return TRUE;
}

#endif
