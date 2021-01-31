// strmul - command

#include "cmd.h"

char *strmul(void)
{
	static char *psResult = NULL;
	char *ps, *prmstr = NULL;
	int len, times;
	
	if ( psResult == NULL ) psResult = hspmalloc( 64 * sizeof(char) );
	
	ps       = code_gets();
	len      = strlen(ps);
	prmstr   = (char *)hspmalloc( (len + 1) * sizeof(char) );
	strcpy(prmstr, ps);
	
	times    = code_getdi(0);
	psResult = (char *)hspexpand( psResult, (len * times + 1) * sizeof(char) );
	
	// 文字列を times 回コピーする
	for( int i = 0; i < times; i ++ ) {
		strncpy(&psResult[len * i], prmstr, len);
	}
	
	hspfree( prmstr );
	return psResult;
}
