// char - command

#include "cmd.h"

// 変数宣言
void char_st(void)
{
	PVal *pval;
	APTR  aptr;
	
	// 与えられた引数をすべて取得する
	for( int i = 0; !(*exinfo->npexflg & EXFLG_1); i ++ ) {
		// 変数のPValポインタと要素数を取得
		aptr = code_getva( &pval );
		if ( i == 0 && aptr <= 0 ) {	// 先頭で、かつ () なし
			int len[4];
			len[0] = code_getdi(1);
			len[1] = code_getdi(0);
			len[2] = code_getdi(0);
			len[3] = code_getdi(0);
			exinfo->HspFunc_dim(
				pval, HSPVAR_FLAG_CHAR, 0, len[0], len[1], len[2], len[3]
			);
			break;
		}
		exinfo->HspFunc_dim( pval, HSPVAR_FLAG_CHAR, 0, aptr, 0, 0, 0 );
	}
	
	return;
}

// 型変換関数
int char_f(void **ppResult)
{
	static char stt_char;
	
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	
	if ( mpval->flag == HSPVAR_FLAG_CHAR ) {
		stt_char = mpval->pt[0];
		
	} else {
		// 変換する
		HspVarProc *phvp = exinfo->HspFunc_getproc(HSPVAR_FLAG_CHAR);
		stt_char = *(char *)phvp->Cnv(mpval->pt, mpval->flag);
	}
	
	*ppResult = &stt_char;
	
	return HSPVAR_FLAG_CHAR;
}
