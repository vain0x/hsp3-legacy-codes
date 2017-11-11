// コマンドライン文字列を解析・分解する

#ifndef __COMMANDLINE_LEXER_AS__
#define __COMMANDLINE_LEXER_AS__

#module mod_LexCmdline

#define true  1
#define false 0

#define success 1
#define failure 0

//------------------------------------------------
// コマンドライン文字列を解析し、分解する
//------------------------------------------------
#define global LexCmdline(%1=cmdopt@,%2=-1,%3=dir_cmdline) _LexCmdline %1,%2,%3
#deffunc _LexCmdline array cmdopt, int cntMax, str _cmdline,  local cmdline, local index, local c, local bInQuote, local cQuote, local cntOpt, local lenOpt, local iOptBegin
	
	if ( cntMax < 0 ) {
		sdim cmdopt, 320, 10
	} else {
		sdim cmdopt, 320, cntMax
	}
	
	if ( cntMax == 0 ) { return }
	
	cmdline   = _cmdline
	index     = 0
	bInQuote  = false
	cQuote    = 0
	cntOpt    = 0
	lenOpt    = 0
	iOptBegin = -1
	
	// 分解処理
	repeat
		c = peek(cmdline, index)
		
		// 終端文字
		if ( c == 0 ) {
			if ( lenOpt ) {
				gosub *LGetOption
			}
			break
			
		// 引用符発見 ( 引用符は cmdopt に含めない )
		} else : if ( c == '\'' || c == '"' ) {
			
			if ( bInQuote == false ) {		// 引用符の開始
			
				if ( iOptBegin < 0 ) { iOptBegin = index + 1 }
				bInQuote = true
				cQuote   = c
				
			} else : if ( cQuote == c ) {	// 引用符の終了
				
				bInQuote = false
				cQuote   = 0
				
				gosub *LGetOption
				if ( stat == failure ) { break }
				
			} else {	// 関係ない文字
				lenOpt ++
				/* */
			}
			
		// 引用符外の空白発見
		} else : if ( c == ' ' && bInQuote == false ) {
			
			if ( lenOpt ) {
				
				gosub *LGetOption
				if ( stat == failure ) { break }
				
			} else {
				/* 無視 */
			}
			
		// その他の文字
		} else {
			if ( iOptBegin < 0 ) { iOptBegin = index }
			lenOpt ++
		}
		
		index ++
	loop
	
	return cntOpt
	
*LGetOption
	cmdopt( cntOpt ) = strmid( cmdline, iOptBegin, lenOpt )
	cntOpt ++
	lenOpt    = 0
	iOptBegin = -1
	
	if ( cntMax > 0 && cntOpt == cntMax ) {
		return failure
	}
	return success
	
//------------------------------------------------
// 文字コマンドを受け取る
//------------------------------------------------
/*
#define global GetCmdline_Char(%1,%2,%3=dir_cmdline) _GetCmdline_Char
#deffunc _GetCmdline_Char var result_char, array result_str, str cmdline,  local cmdopt
	// コマンドライン解析
	LexCmdline cmdopt, , cmdline
	
	result_char = ""
	sdim result_str, , 1
	
	foreach cmdopt
		c = peek(cmdopt(cnt))
		switch ( c )
			// 文字引数
			case '+':
			case '-':
			case '/':
				getstr cmdopt(cnt), cmdopt(cnt), 1	// 2文字目以降
				result_char += cmdopt(cnt)
				swbreak
				
			// 文字列引数
			default:
				result_str(length(result_str)) = cmdopt(cnt)
				swbreak
		swend
	loop
	
	return
	//*/
	
#global

#endif
