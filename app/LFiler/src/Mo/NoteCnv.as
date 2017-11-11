#ifndef __NOTE_CONVERTER_AS__
#define __NOTE_CONVERTER_AS__

#include "Mo/MCLongString.as"

#module notecnv_mod

//------------------------------------------------
// 文字列型配列変数 を 複数行文字列 に変換
//------------------------------------------------
#deffunc AryToNote var prmRet, array prmStr,  local ls
	LongStr_new ls
	
	foreach prmStr
		LongStr_add ls, prmStr(cnt) +"\n"
	loop
	
	LongStr_tobuf ls, prmRet
	wpoke prmRet, LongStr_length(ls) - 2, 0	// 最後の2byte(CRLF)を削除
	
	LongStr_delete ls
	return
	
//------------------------------------------------
// 複数行文字列 を 文字列型配列変数 に変換
//------------------------------------------------
#deffunc NoteToAry array prmRet, str prmNote
	
	sBuf   = prmNote		// 一旦変数に移す
	iIndex = 0
	iLen   = strlen(sBuf)	// 全体の長さ
	
	if ( iLen <= 0 ) {		// 異常発生
		return
	}
	
	// 最後が改行かどうかを調べる
	cLast = peek(sBuf, iLen - 1)			// 最後の文字の文字コード
	if ( peek(sBuf, iLen - 2) == 0x0D && cLast == 0x0A ) {
		// CRLF
		wpoke sBuf, iLen - 2, 0
		iLen -= 2
		
	} else : if ( cLast == 0x0D || cLast == 0x0A ) {
		// CR か LF
		poke sBuf, iLen - 1, 0
		iLen --
		
	}
	
	// sBuf をメモリノートにする
	notesel sBuf
	sdim prmRet, , noteinfo()		// 行数分確保
	
	repeat noteinfo()
		
		// 一行ずつ格納していく
		getstr prmRet(cnt), sBuf, iIndex
		iIndex += strsize
		
	loop
	
	noteunsel
	
	sdim sBuf, 0
	return
	
#global

#endif
