// varinfo - command

#include "cmd.h"

static int GetVarInfo(PVal *pval, VARINFO type);

//------------------------------------------------
// varinfo 命令
//------------------------------------------------
void varinfo_st(void)
{
	PVal *pvTarget, *pvInfo;
	HspVarProc *phvpint;
	
	code_getva( &pvTarget ); // 対象の変数
	pvInfo = code_getpval(); // 情報を格納する配列
	
	exinfo->HspFunc_dim( pvInfo, HSPVAR_FLAG_INT, 0, VARINFO_MAX, 0, 0, 0 );
	
	phvpint = exinfo->HspFunc_getproc( HSPVAR_FLAG_INT );
	
	// 変数データを varinfo に、一時的に格納
	int varinfo[VARINFO_MAX];
	for ( int i = 0; i < static_cast<VARINFO>(VARINFO_MAX); ++ i ) {
		varinfo[i] = GetVarInfo( pvTarget, static_cast<VARINFO>(i) );
	}
	
	// varinfo データを pvInfo の配列に格納する
	for( int i = 0; i < VARINFO_MAX; ++ i ) {
		pvInfo->offset = i;
		phvpint->Set( pvInfo, phvpint->GetPtr(pvInfo), &varinfo[i] );
	}
	return;
}

//------------------------------------------------
// varinfo()
//------------------------------------------------
int varinfo_f(void **ppResult)
{
	static int result;
	int rettype = HSPVAR_FLAG_INT;
	VARINFO type;
	PVal *pvTarget;
	
	code_getva( &pvTarget ); // 対象の変数の PVal*
	type = static_cast<VARINFO>( code_geti() ); // 情報の種類
	
	result = GetVarInfo(pvTarget, type);
	
	*ppResult = &result;
	return rettype;
}

//------------------------------------------------
// 実際に変数情報を取得する関数
//------------------------------------------------
static int GetVarInfo(PVal *pvTarget, VARINFO type)
{
	switch ( type ) {
		case VARINFO_LEN0: return pvTarget->len[0];
		case VARINFO_LEN1: return pvTarget->len[1];
		case VARINFO_LEN2: return pvTarget->len[2];
		case VARINFO_LEN3: return pvTarget->len[3];
		case VARINFO_LEN4: return pvTarget->len[4];
		case VARINFO_FLAG: return pvTarget->flag;
		case VARINFO_MODE: return pvTarget->mode;
		case VARINFO_PTR: {
			HspVarProc *phvp = exinfo->HspFunc_getproc( pvTarget->flag );
			return reinterpret_cast<int>( phvp->GetPtr(pvTarget) );
		}
		default:
			puterror( HSPERR_ILLEGAL_FUNCTION );
	}
}
