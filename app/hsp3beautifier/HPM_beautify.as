#ifndef IG_HSP_PARSE_MODULE_BEAUTIFY_AS
#define IG_HSP_PARSE_MODULE_BEAUTIFY_AS

#include "Mo/HPM_getToken.as"
#include "Mo/MCLongString.as"
#include "Mo/strutil.as"

#module

#include "Mo/HPM_header.as"

#deffunc hpm_beautify var outbuf, str inbuf
	
	LongStr_new script
	sdim nowtk, 320
;	sdim beftk
	
	textlen = strlen(inbuf)
	sdim buf, textlen + 1
	buf     = inbuf			// 変数に移動
	index   = 0
	bRet    = false
	nestPP  = 0				// プリプロセッサ命令のネスト
	nest    = 1				// ネストの深さ
	
	nowTT = TKTYPE_NONE
	befTT = TKTYPE_NONE
	
	repeat
		gosub *L_SkipSpaces
		
		// 最後まで取得したら終了する
		if ( index >= textlen ) { break }
		
		// 次のトークンを取得
		hpm_GetNextToken nowtk, buf, index, befTT, bPreLine : nowTT = stat
		if ( nowTT == TKTYPE_ERROR ) {
			bRet = true
			break
		}
		
		def_tklen = strlen(nowtk)
		tklen     = def_tklen
		
		// トークンを処理する
		gosub *L_ProcToken
		
		// 更新
		befTT = nowTT
		await 0
	loop
	
	// 戻り値の設定
	if ( bRet == false ) {
		LongStr_tobuf script, outbuf
;		bsave "./_buffer_outbuf.html", outbuf, LongStr_len(script)
	}
	
	LongStr_delete script
	
	return bRet
	
// 空白をスキップする
*L_SkipSpaces
	n = CntSpaces(buf, index)
	c = peek(buf, index + n)	// 次の文字
	
	// 行頭なら、指定された数のネストを付ける
	if ( bNewLine ) {					// 前が改行なら
		if ( c == '#' ) {
			; PREPROC のところでインデント処理を行う
			
		} else : if ( c == '*' ) {
			; label => 字下げしない
			
		} else : if ( c == '/' || c == ';' ) {
			
			if ( n ) {
				LongStr_cat script, strmul("\t", nest), nest
			}
			
		} else {
			if ( c == '}' ) { nest -- }
			LongStr_cat script, strmul("\t", nest), nest		// タブでインデント
			
		}
		bNewLine = false
		
	// スペース無視フラグが立っている場合
	} else : if ( bIgSpace ) {
		bIgSpace = false
		
	// 他の場合は、コピーするだけ
	// <TODO> 代入やらコメントやらをそろえる
	} else {
		if ( n ) {
			LongStr_cat script, strmid(buf, index, n), n
			logmes "[SpaceSkip] "+ n
		}
	}
	
	// 進める
	index += n
	return
	
// トークンごとに処理をする
*L_ProcToken
	switch nowTT
	
	case TKTYPE_END		// 文の終了
		nowTT = TKTYPE_NONE
		if ( bPreLine ) { bPreLine = false }
		
		c = peek(nowtk)
		
		// 改行なら
		if ( IsNewLine(c) ) {	// 改行なら
			index   += tklen
			nowtk    = "\n"		// CR + LF 形式にする
			tklen    = 2
			bNewline = true
			
		// その他の記号なら
		} else {
			// ブロック { } なら
			if ( c == '{' ) {
				nest ++
			} else : if ( c == '}' && befTT != TKTYPE_NONE ) {
				nest --					// 行頭だったら、既に -1 されている
			}
			gosub *L_SetSpacesBoth		// 前後に空白をセットする
			index ++					// index を進める
		}
		gosub *L_DefaultWrite			// 標準の書き込み
		swbreak
		
	case TKTYPE_COMMENT : nowTT = befTT : gosub *L_DefaultProc : swbreak
;	case TKTYPE_STRING  : swbreak
;	case TKTYPE_LABEL   : swbreak
	case TKTYPE_PREPROC
		if ( IsPreproc(nowtk) ) {
			bPreLine = true
			
			// # と識別子の間の空白を削除する( # も取り除く )
			tklen  = strlen(nowtk)
			index += tklen
			nSpace = 1 + CntSpaces(nowtk, 1)
			nowtk  = strmid(nowtk, nSpace, tklen)
			tklen -= nSpace
			
			// 字下げを行い、# を挿入する
			LongStr_cat script, strmul(" ", nestPP) +"#", nestPP + 1	// 半角スペースで字下げ
			
			// 種類によって分岐
			switch nowtk
				case "if"
				case "ifdef"
				case "ifndef"
					nSpace = CntSpaces(buf, index)
					if ( wpeek(buf, index + nSpace) != MAKEWORD('_', '_') ) {
						nestPP ++
					}
					swbreak
					
				case "endif"
					LongStr_erase_back script, 2		// ' ' と '#' を削除
					LongStr_cat script, "#"
					nestPP --
					swbreak
					
				case "func"   : case "cfunc"
				case "define" : case "const" : case "enum"
					// 続く識別子の空白をそろえる
					nSpace = CntSpaces(buf, index)
					index += nSpace
					nowtk += strmul(" ", 7 - tklen)
					tklen += limit(7 - tklen, 0, MAX_INT)
					
					// 次に続くスペースを無視
					bIgSpaces = true
					swbreak
			swend
			
			// 標準書き込み
			gosub *L_DefaultWrite
			
		} else {
			// 標準の操作を行う
			gosub *L_DefaultProc
		}
		swbreak
		
	case TKTYPE_NAME			// 識別子
		switch ( nowtk )
			case "repeat":
			case "while":
			case "for":
				nest ++
				swbreak
				
			case "loop":
			case "wend":
			case "next":
				LongStr_erase_back script, 1
				nest --
				swbreak
				
			case "switch":
				nest += 2
				swbreak
				
			case "swend":
				LongStr_erase_back script, 2
				nest -= 2
				swbreak
				
			case "case":
			case "default":
				LongStr_erase_back script, 1
				swbreak
				
		swend
		gosub *L_DefaultProc
		swbreak
		
	case TKTYPE_OPERATOR		// 演算子
		if ( nowtk == "->" ) {		// 前後に空白をセットしない
			;
		} else {
			gosub *L_SetSpacesBoth	// 前後に空白をセット
		}
		gosub *L_DefaultProc		// 標準処理
		swbreak
		
	case TKTYPE_COMMA
		gosub *L_SetSpacesBehind	// 後ろだけに空白をセットする
		gosub *L_DefaultProc
		swbreak
		
	default
		gosub *L_DefaultProc
		swbreak
		
	swend
	return
	
// 標準の処理
*L_DefaultProc
	gosub *L_DefaultMove
	gosub *L_DefaultWrite
	return
	
// 読み込みインデックスを伸ばす
*L_DefaultMove
	index += def_tklen
	return
	
// スクリプトに書き込む
*L_DefaultWrite
	LongStr_cat script, nowtk, tklen
	return
	
// 記号の前後に空白をセットする
*L_SetSpacesBoth
	gosub *L_SetSpacesBehind
	gosub *L_SetSpacesFront
	return
	
// 記号の後ろに空白をセットする
*L_SetSpacesBehind
	c = peek(buf, index + def_tklen)
	if ( IsBlank(c) == false && c != '"' ) { nowtk += " " : tklen ++ }
	return
	
// 記号の手前に空白をセットする
*L_SetSpacesFront
	if ( index > 0 ) {
		c = peek(buf, index - 1)
		if ( IsBlank(c) == false && c != '"' ) { nowtk = " "+ nowtk : tklen ++ }
	}
	return
	
#global

#endif
