// GetVarinfo - command

#include "dllmain.h"
#include "cmd.h"

void GetVarinfo(void)
{
	PVal *pvTarget, *pvInfo;
	HspVarProc *phvp, *phvpint;
	
	code_getva( &pvTarget );	// 対象の変数
	pvInfo = code_getpval();	// 情報を格納する配列
	
	exinfo->HspFunc_dim( pvInfo, HSPVAR_FLAG_INT, 0, VARINFO_MAX, 0, 0, 0 );
	
	phvp    = exinfo->HspFunc_getproc( pvTarget->flag );
	phvpint = exinfo->HspFunc_getproc( HSPVAR_FLAG_INT );
	
	// 変数データを varinfo に、一時的に格納
	int varinfo[VARINFO_MAX];
	varinfo[VARINFO_LEN0] = pvTarget->len[0];
	varinfo[VARINFO_LEN1] = pvTarget->len[1];
	varinfo[VARINFO_LEN2] = pvTarget->len[2];
	varinfo[VARINFO_LEN3] = pvTarget->len[3];
	varinfo[VARINFO_LEN4] = pvTarget->len[4];
	varinfo[VARINFO_FLAG] = pvTarget->flag;
	varinfo[VARINFO_MODE] = pvTarget->mode;
	varinfo[VARINFO_PTR ] = reinterpret_cast<int>( phvp->GetPtr(pvTarget) );
	
	// varinfo の全データを pvInfo の配列に格納する
	for(int i = 0; i < VARINFO_MAX; i ++) {
		pvInfo->offset = i;
		phvpint->Set(pvInfo, phvpint->GetPtr(pvInfo), &varinfo[i]);
	}
	return;
}
