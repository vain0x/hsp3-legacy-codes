// msgbox - dllmain.cpp

#include "dllmain.h"

//------------------------------------------------
// 命令コマンド呼び出し関数
//------------------------------------------------
static int cmdfunc(int cmd)
{
	code_next();
	
	switch( cmd ) {
		//msgbox
		case 0x000: {
			MessageBox(0, "Hello, world!", "Let's make plugin!", MB_OK);
			break;
		}
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return RUNMODE_RUN;
}

//------------------------------------------------
// プラグイン初期化関数
//------------------------------------------------
EXPORT void WINAPI hsp3hpi_init( HSP3TYPEINFO *info )
{
	hsp3sdk_init( info ); // SDKの初期化
	
	info->cmdfunc = cmdfunc; // 実行関数(cmdfunc)の登録
	return;
}
