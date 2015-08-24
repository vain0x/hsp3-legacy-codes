// HSP parse module - TookToken

#ifndef __HSP_PARSE_MODULE_TOOK_TOKEN_AS__
#define __HSP_PARSE_MODULE_TOOK_TOKEN_AS__

// 識別子取り出しモジュール
#module hpm_tookToken

#include "HPM_Header.as"

// エスケープシーケンス付き切り出し
#define TEMP_TookTokenInEsqSec(%1,%2) /* p1 = オフセット p2 = 終了条件 */\
	i = (%1) :\
	while :\
		c = peek(p1, p2 + i) : i ++ :\
		if ( c == '\\' || IsSJIS1st(c) ) {		/* 次も確実に書き込む */\
			i ++ :\
		}\
		if ( %2 ) { _break }/* 終了 */\
	wend :\
	return strmid(p1, p2, i)
	
// 文字列か文字定数を切り出す
#defcfunc TookStr_or_Char var p1, int p2, int p3
	TEMP_TookTokenInEsqSec 1, ( c == p3 || IsNewLine(c) || c == 0 )
	
// 　文字列を切り出して返す
// ＆文字定数を切り出して返す
#define global ctype TookStr(%1,%2=0) TookStr_or_Char(%1,%2,'"')
#define global ctype TookCharactor(%1,%2=0) TookStr_or_Char(%1,%2,'\'')

// 複数行文字列を切り出して返す
#defcfunc TookStrMulti var p1, int p2
	TEMP_TookTokenInEsqSec 2, ( peek(p1, p2 + i - 2) == '"' && c == '}' || c == 0 )
	
// 範囲の違う「トークン」を切り出して返す
#define TEMP_TookToken(%1) \
	i = p2 :\
	while :\
		c = peek(p1, i) :\
		if ((%1) == false) { _break } \
		i ++ :\
	wend :\
	return strmid(p1, p2, i - p2)
	
// 識別子を切り出して返す
#defcfunc TookName var p1, int p2
	TEMP_TookToken ( IsIdent(c) )
	
// 16進数を切り出して返す
#defcfunc TookNum_Hex var p1, int p2
	TEMP_TookToken ( IsHex(c) )
	
// 2進数を切り出して返す
#defcfunc TookNum_Bin var p1, int p2
	TEMP_TookToken ( IsBin(c) )
	
// 10進数を切り出して返す
#defcfunc TookNum_Dgt var p1, int p2
	TEMP_TookToken ( IsDigit(c) || c == '.' )
	
	
#global

#endif
