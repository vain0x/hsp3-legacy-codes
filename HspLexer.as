// HSP Lexer

#ifndef IG_MODULECLASS_HSP_LEXER_AS
#define IG_MODULECLASS_HSP_LEXER_AS

#include "strutil.as"
#include "extendTab.as"

#module MCHspLexer mSrc, mfOpt, mTabSize

#include "HspLexer_header.as"

#define true  1
#define false 0

#define global HspLexer_Flag_None		0x0000		// 指定なし
#define global HspLexer_Flag_NoBlank	0x0001		// TkType_Blank   を無視する
#define global HspLexer_Flag_NoComment	0x0002		// TkType_Comment を無視する
#define global HspLexer_Flag_NoScope	0x0004		// TkType_Scope   を無視する
#define global HspLexer_Flag_NoReserved	0x0008		// TkType_Ident が予約語かどうかの判定をしない
#define global HspLexer_Flag_ExtendTab	0x0010		// タブ文字を半角スペースに展開する
;#define global HspLexer_Flag_
;#define global HspLexer_Flag_

//------------------------------------------------
// 構築
//------------------------------------------------
#define global hspLexer_new(%1) newmod %1, MCHspLexer@
#modinit
	sdim mSrc, 1024
	mfOpt    = 0
	mTabSize = 4
	return
	
#define global hspLexer_delete(%1) delmod %1

//------------------------------------------------
// 設定
//------------------------------------------------
#modfunc hspLexer_set int fOpt, int tabsize
	mfOpt    = fOpt
	mTabSize = tabsize
	return
	
//------------------------------------------------
// 字句解析
// 
// @prm tktypelist = int[] : TKTYPE の配列
// @prm tkstrlist  = str[] : トークン文字列の配列
// @prm script     = str   : スクリプト
//------------------------------------------------
#modfunc hspLexer_lex array tktypelist, array tkstrlist, str prm_script,  local lenScript, local cntToken, local tkstr, local tklen, local tktype, local bPreprocLine, local index, local befTkType, local posALine, local bNoBlank, local bNoComment, local bNoScope, local bNoReserved, local bExtendTab
	sdim tkstr
	dim  tktype
	
	dim tktypelist
	sdim tkstrlist
	
	bPreprocLine = false
	mSrc      = prm_script
	lenScript = strlen(mSrc)
	index     = 0
	tktype    = TkType_End
	befTkType = TkType_End
	cntToken  = 0
	
	keylist_preproc = "," + KeyWords_PreProc
	keylist_ppword  = "," + KeyWords_PPWord
	
	bNoBlank    = ( mfOpt & HspLexer_Flag_NoBlank    ) != false
	bNoComment  = ( mfOpt & HspLexer_Flag_NoComment  ) != false
	bNoScope    = ( mfOpt & HspLexer_Flag_NoScope    ) != false
	bNoReserved = ( mfOpt & HspLexer_Flag_NoReserved ) != false
	bExtendTab  = ( mfOpt & HspLexer_Flag_ExtendTab  ) != false		// related: mTabSize, posALine
	
	repeat
		// 最後まで取得したら終了する
		if ( lenScript <= index ) { break }
		
		// 次のトークンを取得
		getNextToken tkstr, mSrc, index, befTkType, bPreprocLine
		tktype = stat
		tklen  = strlen(tkstr)
		index += tklen
		
		if ( bExtendTab ) { tkstr = extendTab(tkstr, mTabSize, posALine) : posALine += strlen(tkstr) }
		
		// 無視されるトークン ⇒ 飛ばす
		if ( ( bNoBlank && tktype == TkType_Blank ) || ( bNoComment && tktype == TkType_Comment ) || ( bNoScope && tktype == TkType_Scope ) ) {
			continue
		}
		
;		if ( tktype == TkType_Error ) {
;			cntToken = -1
;			break
;		}
		
;		logmes "type\t= "+ tktype
;		logmes "str\t= "+  tkstr
;		logmes "beftype\t= "+ befTkType
;		logmes "index\t= "+ index
;		logmes ""
		
		tktypelist(cntToken) = tktype
		tkstrlist (cntToken) = tkstr
		
		// トークンごとに必須の処理
		gosub *LProcToken
		
		// 更新
		befTkType = tktype
		cntToken ++
	loop
	
	return cntToken
	
*LProcToken
	switch ( tktype )
		
		// 空白 or コメント
		case TkType_Blank
		case TkType_Comment
			tktype = befTkType
			swbreak
			
		// 文の終了
		case TkType_End
			if ( IsNewLine( peek(tkstr) ) ) {			// 改行
				if ( bPreprocLine ) { bPreprocLine = false }
				if ( bExtendTab   ) { posALine = 0 }
			}
			swbreak
			
		// プリプロセッサ命令
		case TkType_PreProc
			if ( isPreProc(thismod, tkstr) ) {
				bPreprocLine = true
			} else {
				tktype               = TkType_PreProcDisable
				tktypelist(cntToken) = tktype
			}
			swbreak
			
		// 識別子
		case TkType_Ident
			if ( bNoReserved ) { swbreak }
			
			// プリプロセッサ行キーワードか
			if ( bPreprocLine ) {
				if ( isPPWord(thismod, tkstr) ) {
					tktype = TkTypeEx_PPWord
					goto *LChangeTkTypeList
				}
			}
			
		/*
			         if ( isSttm(thismod, tkstr) )    { tkType = TkTypeEx_Sttm		// 標準命令
			} else : if ( isFunc(thismod, tkstr) )    { tkType = TkTypeEx_Func		// 標準関数
			} else : if ( isSysvar(thismod, tkstr) )  { tktype = TkTypeEx_Sysvar	// システム変数
			} else : if ( isMacro(thismod, tkstr) )   { tktype = TkTypeEx_Macro		// マクロ
			} else : if ( isConst(thismod, tkstr) )   { tktype = TkTypeEx_Const		// 定数
			} else : if ( isDefSttm(thismod, tkstr) ) { tktype = TkTypeEx_DefSttm	// ユーザ定義命令
			} else : if ( isDefFunc(thismod, tkstr) ) { tktype = TkTypeEx_DefFunc	// ユーザ定義関数
			} else : if ( isDllFunc(thismod, tkstr) ) { tktype = TkTypeEx_DllFunc	// DllFunc
			} else : if ( isIFace(thismod, tkstr) )   { tktype = TkTypeEx_IFace		// IFace
			} else : if ( isModname(thismod, tkstr) ) { tktype = TkTypeEx_ModName	// モジュール名
			} else {
				tktype = TkTypeEx_Var
			}
		//*/
			
			// 配列に指定した値を変更する
		:*LChangeTkTypeList
			tktypelist(cntToken) = tktype
			swbreak
			
	swend
	
	return
	
//##########################################################
//        識別子切り出し [static]
//##########################################################
//------------------------------------------------
// エスケープシーケンス付き切り出し
//------------------------------------------------
#define FTM_CutTokenInEsqSec(%1,%2,%3) /* %1 = オフセット, %2 = 終了条件 */\
	i = (%1) :\
	repeat :\
		c = peek(sSrc, iOffset + i) : i ++ :\
		if ( c == '\\' || IsSJIS1st(c) ) {		/* 次も確実に書き込む */\
			i ++ :\
		}\
		if ( %2 ) { break }/* 終了 */\
	loop :\
	return strmid(sSrc, iOffset, i)
	
//------------------------------------------------
// 文字列か文字定数を切り出す
//------------------------------------------------
#defcfunc CutStr_or_Char@MCHspLexer var sSrc, int iOffset, int p3
	FTM_CutTokenInEsqSec 1, ( c == p3 || IsNewLine(c) || c == 0 )
	
//------------------------------------------------
// 　文字列を切り出して返す
// ＆文字定数を切り出して返す
//------------------------------------------------
#define ctype CutStr(%1,%2=0) CutStr_or_Char(%1,%2,'"')
#define ctype CutCharactor(%1,%2=0) CutStr_or_Char(%1,%2,'\'')

//------------------------------------------------
// 複数行文字列を切り出して返す
//------------------------------------------------
#defcfunc CutStrMulti@MCHspLexer var sSrc, int iOffset
	FTM_CutTokenInEsqSec 2, ( peek(sSrc, iOffset + i - 2) == '"' && c == '}' || c == 0 )
	
//------------------------------------------------
// 文字列か文字定数の中身を切り出す
//------------------------------------------------
#define _c2 peek(sSrc, iOffset + i)
#defcfunc CutStr_or_Char_inner@MCHspLexer var sSrc, int prm_iOffset, int p3,  local iOffset
	iOffset = prm_iOffset + 1
	FTM_CutTokenInEsqSec 1, ( _c2 == p3 || IsNewLine(_c2) || c == 0 )
	
#undef _c2

//------------------------------------------------
// 　文字列の中身を切り出して返す
// ＆文字定数の中身を切り出して返す
//------------------------------------------------
#define ctype CutStrInner(%1,%2=0) CutStr_or_Char_inner(%1,%2,'"')
#define ctype CutCharactorInner(%1,%2=0) CutStr_or_Char_inner(%1,%2,'\'')

//------------------------------------------------
// 範囲の違う「トークン」を切り出して返す
//------------------------------------------------
#define FTM_CutToken(%1,%2=0) \
	i = iOffset :\
	repeat :\
		c = peek(sSrc, i) :\
		if ((%1) == false || c == 0) { break } \
		if (%2) { i ++ }\
		i ++ :\
	loop :\
	return strmid(sSrc, iOffset, i - iOffset)
	
//------------------------------------------------
// 空白を切り出して返す
//------------------------------------------------
#defcfunc CutSpace@MCHspLexer var sSrc, int iOffset
	FTM_CutToken ( IsSpace(c) )
	
//------------------------------------------------
// 識別子を切り出して返す
//------------------------------------------------
#defcfunc CutName@MCHspLexer var sSrc, int iOffset
	FTM_CutToken ( IsIdent(c) || IsSJIS1st(c) || c == '`' ), IsSJIS1st(c)
	
//------------------------------------------------
// 16進数を切り出して返す
//------------------------------------------------
#defcfunc CutNum_Hex@MCHspLexer var sSrc, int iOffset
	FTM_CutToken ( IsHex(c) || c == '_' )
	
//------------------------------------------------
// 2進数を切り出して返す
//------------------------------------------------
#defcfunc CutNum_Bin@MCHspLexer var sSrc, int iOffset
	FTM_CutToken ( IsBin(c) || c == '_' )
	
//------------------------------------------------
// 10進数を切り出して返す
//------------------------------------------------
#defcfunc CutNum_Dgt@MCHspLexer var sSrc, int iOffset
	FTM_CutToken ( IsDigit(c) || c == '.' || c == '_' )
	
//##########################################################
//        字句取り出し
//##########################################################
#uselib "user32.dll"
#func   CharLower@MCHspLexer "CharLowerA" int

//------------------------------------------------
// マクロ
//------------------------------------------------
#define ctype IsWOp(%1) ((%1) == '<' || (%1) == '=' || (%1) == '>' || (%1) == '&' || (%1) == '|' || (%1) == '+' || (%1) == '-')

#define NULL 0

//------------------------------------------------
// 次のトークンを取得する
//------------------------------------------------
#deffunc getNextToken@MCHspLexer var result, var sSrc, int index, int p_befTT, int bPreLine
	c = peek(sSrc, index)
	
	// 空白 (Blank)
	if ( IsSpace(c) ) {
		result = CutSpace(sSrc, index)
		return TkType_Blank
	}
	
	// 識別子 (Identifier)
	if ( IsIdentTop(c) || c == '`' || IsSJIS1st(c) ) {
		result = CutName(sSrc, index)
		return TkType_Ident
	}
	
	// プリプロセッサ命令 (Preprocessor)
	if ( c == '#' ) {
		iFound = 1 + CntSpaces(sSrc, index + 1)		// 空白
		result = strmid(sSrc, index, iFound) + CutName(sSrc, index + iFound)
		return TkType_PreProc
	}
	
	// 文字列定数 (Single-line String Literal)
	if ( c == '\"' ) {
		result = CutStr(sSrc, index)			// 文字列を取り出す (""を含む)
		return TkType_String
	}
	
	// 複数行文字列定数 (Multi-line String Literal)
	if ( wpeek(sSrc, index) == 0x227B ) {		// {"
		result = CutStrMulti(sSrc, index)		// 複数行文字列を取り出す ({" "} 含む)
		return TkType_String
	}
	
	// 文区切り
	if ( c == ':' || c == '{' || c == '}' || IsNewLine(c) || c == 0 ) {
		result = strf("%c", c)
		if ( c == 0x0D ) {
			if ( peek(sSrc, index + 1) == 0x0A ) {		// CRLF
				result = "\n"
			}
		}
		return TkType_End
	}
	
	// 記号 (Sign)
	if ( c == ',' ) { result = "," : return TkType_Comma  }
	if ( c == '(' ) { result = "(" : return TkType_ParenL }
	if ( c == ')' ) { result = ")" : return TkType_ParenR }
	if ( c == '.' ) { result = "." : return TkType_Period }
	
	// ラベル (Label) := * から始まり、次が「文の終端、カンマ、')'」のどれか
	if ( c == '*' ) {
		if ( IsLabel(sSrc, index, p_befTT, bPreline) ) {
			c2 = peek(sSrc, index + 1)
			if ( c2 == '@' ) {
				result = "*@"+ CutName(sSrc, index + 2)		// *@ の後は好きなだけ取り出す
			} else : if ( c2 == '%' ) {						// *%
				result = "*%"+ CutName(sSrc, index + 2)
			} else {
				result = "*"+ CutName(sSrc, index + 1)		// 切り出す
			}
			return TkType_Label
		}
	}
	
	// 行末コメント (Single-line Comment)
	if ( c == ';' || wpeek(sSrc, index) == 0x2F2F ) {
		getstr result, sSrc, index			// 改行まで取り出す
		return TkType_Comment
	}
	
	// 複数行コメント (Multi-line Comment)
	if ( wpeek(sSrc, index) == 0x2A2F ) {
		iFound = instr(sSrc, index + 2, "*/")
		if ( iFound < 0 ) {
			result = strmid(sSrc, index, strlen(sSrc) - index)	// 以降すべてコメント
		} else {
			result = strmid(sSrc, index, iFound + 4)			// 開始・終了も含む
		}
		return TkType_Comment
	}
	
	// 演算子 (Operator)
	if ( IsOperator(c) ) {
		
		// 2 バイトの演算子の時もある ( '?'= か、&& || などの二重 )
		c2 = peek(sSrc, index + 1)
		if ( c2 == '=' || ( IsWOp(c) && c == c2 ) ) {
			result = strmid(sSrc, index, 2)	// 2 byte
		} else {
			wpoke result, , c			// 1 byte
		}
		
		// 改行回避の可能性
		if ( c == '\\' && bPreLine ) {
			if ( IsNewLine(c2) ) {
				if ( c2 == 0x0D && peek(sSrc, index + 2) == 0x0A ) {
					lpoke result,, MAKELONG2('\\', 0x0D, 0x0A, 0)	// "\\\n"
				} else {
					lpoke result,, MAKEWORD('\\', c2)
				}
				return TkType_EscLineFeed
			}
		}
		
		return TkType_Operator
	}
	
	// 文字定数 (Charactor Literal)
	if ( c == '\'' ) {
		result = CutCharactor(sSrc, index)
		return TkType_Char
	}
	
	// 整数値定数( 2 or 16 進数 ) (Binary or Hexadigimal Number)
	if ( c == '$' ) {
		result = "$"+ CutNum_Hex(sSrc, index + 1)
		return TkType_Numeric
	}
	if ( c == '%' ) {
		c2 = peek(sSrc, index + 1)
		
		if ( bPreLine ) {
			// 二進数表記 ( %%010101 ... etc )
			if ( c2 == '%' && IsBin(peek(sSrc, index + 2)) ) {
				result = "%"+ CutNum_Bin(sSrc, index + 1)
				return TkType_Numeric
				
			// マクロ引数 ( %1, %2, %3 ... etc )
			} else : if ( IsDigit(c2) && c2 != '0' ) {
				result = "%"+ CutNum_Dgt(sSrc, index + 1)
				return TkType_MacroPrm
				
			// 特殊展開マクロ ( %i, %s1 ... etc )
			} else : if ( IsAlpha(c2) ) {
				result = "%"+ CutName(sSrc, index + 1)
				return TkType_MacroSP
			}
		}
		
		// 二進数表記
		result = "%"+ CutNum_Bin(sSrc, index + 1)
		return TkType_Numeric
	}
	
	// '0' か始まる : 0x, 0b, 0123...
	if ( c == '0' ) {
		c2 = peek(sSrc, index + 1)
		if ( c2 == 'x' || c2 == 'X' ) {
			result = strmid(sSrc, index, 2) + CutNum_Hex(sSrc, index + 2)
			
		} else : if ( c2 == 'b' || c2 == 'B' ) {
			result = strmid(sSrc, index, 2) + CutNum_Bin(sSrc, index + 2)
			
		} else {
			gosub *LGetToken_Digit
			return stat
		}
		return TkType_Numeric
	}
	
	// 整数値定数 (10進数) (Digimal Number)
	if ( IsDigit(c) || c == '.' ) {
		gosub *LGetToken_Digit
		return stat
	}
	
	// スコープ解決 (scope solver)
	if ( c == '@' ) {
		result = "@"+ CutName(sSrc, index + 1)
		return TkType_Scope
	}
	
	// 謎な場合
*LUnknownToken
	if ( IsSJIS1st(c) ) {
		logmes "ERROR! SJIS code!"
		wpoke result, 0, wpeek(sSrc, index)	// 書き込む
		poke  result, 3, NULL
		return TkType_Error
	}
	
	// ？？？
	result = strf("%c", c)
	logmes "ERROR !! Can't Pop a Token! [ " + index + strf(" : %c : ", c) + c + " ]"
	return TkType_Error
	
// 10進数を切り出す
*LGetToken_Digit
	result = CutNum_Dgt(sSrc, index)
	len    = strlen(result)
	c      = peek( sSrc, index + len )		// 数の次の文字
	switch ( c )
		case 'f'
		case 'd'
			result += strf("%c", c)
			swbreak
			
		case 'e'
			result += "e"
			
			c2 = peek( sSrc, index + len + 1 )
			if ( c2 == '-' ) {
				result += "-"
				len ++
			}
			
			// 指数を足しておく
			result += CutNum_Dgt( sSrc, index + len + 1 )
			swbreak
	swend
	
	return TkType_Numeric
	
//##############################################################################
//                識別子判定
//##############################################################################
//------------------------------------------------
// 次はラベルか？
// 
// @ 条件 :=
//   　 * から始まり、
//   　その次が「文の終端 or ',' or ')'」のどれか
//------------------------------------------------
#modcfunc isLabel@MCHspLexer var src, int offset, int p_befTT, int bPreLine,  local stmp

	// 最低限のチェック
	if ( peek(src, offset    ) != '*' ) { return false }		// もはやラベルではない
	if ( peek(src, offset + 1) == '@' ) { return true  }		// ローカルラベル
	if ( peek(src, offset + 1) == '%' && bPreLine ) {
		c2 = peek(src, offset + 2)
		switch ( c2 )
			// 特殊展開マクロ
			case 'n' : case 'i' : case 'p' : case 'o'
				swbreak
			default
				// または マクロ引数
				if ( IsDigit(c2) && c2 != '0' ) {
					swbreak
				}
				return false
		swend
		return true
	}
	
	// ラベルの前を調べる
	switch p_befTT
		case TkType_End
		case TkType_Operator
		case TkType_ParenL
		case TkType_Keyword
		case TkType_Comma
		case TkType_MacroPrm
		case TkType_MacroSP
			// 無条件に OK
			swbreak
			
		case TkType_Ident
			// ラベルの前の識別子が、文頭にある or goto / gosub ならＯＫ
			i  = offset
			i -= CntSpacesBack( src, i )
			m  = BackToIdentTop(src, offset)
			if ( m < 0 ) { return false }	// 前が識別子ではない (異常？)
			i -= m
			
;			// ここで、goto gosub なら OK
;			stmp = getpath( CutName(src, i + 1), 16 )
;			if ( stmp == "gosub" || stmp == "goto" ) {
;				swbreak
;			}
			
			i -= CntSpacesBack( src, i )		// 空白 ignore
			i --							// ラベルの前の前
			if ( i < 0 ) { swbreak }
			c  = peek(src, i)
			if ( IsNewLine(c) || c == ':' || c == '{' || c == '}' ) {
				swbreak
			}
			return false
			
		default
			// 予約語も OK
			if ( IsTkTypeReserved(p_befTT) ) {
				swbreak
			}
			
			// その他ならダメ
			return false
	swend
	
	// ラベル名を飛ばす
	c = peek(src, offset + 1)
	if ( IsIdentTop(c) == false ) { return false }	// 次が識別子の先頭でなければ×
	i = offset + 2
	repeat
		c = peek(src, i)
		if ( IsIdent(c) == false ) {
			break
		}
		i ++
	loop
	
#if 0
	// ラベルの後を調べる
	while
		i += CntSpaces(src, i)	// 空白をスキップ
		c  = peek(src, i)		// ラベルの次
		
		if ( c == '/' ) {
			c2 = peek(src, i + 1)
			if ( c2 == '/' ) { return true }		// ダブル・スラッシュのコメント
			if ( c2 == '*' ) {						// 複数行コメント開始
				iFound = instr(src, i + 2, "*/")	// 終了地点を探す
				if ( iFound >= 0 ) {
					i += 4 + iFound					// /**/ + 距離
					_continue						// もう一度「ラベルの次」をチェックする
				}
			}
		} else : if ( c == '@' ) {
			// スコープ名をスキップ
			do
				i ++
				c = peek(src, i)
			until ( IsIdent(c) == false )
			_continue
		}
		_break
	wend
	
	// ;:{}), 改行文字 NULL でなければ×
	if ( c != NULL && (c == ';' || c == ':' || c == '{' || c == '}' || c == ')' || c == ',' || c == 0x0D || c == 0x0A) == false ) {
		return false
	}
#endif
	return true
	
#define ctype isIdentInList(%1,%2=src) ( instr( %1, 0, ","+ getpath(%2, 16) +"," ) >= 0 )
	
//------------------------------------------------
// プリプロセッサ命令か？
//------------------------------------------------
#modcfunc isPreProc@MCHspLexer str src
	return isIdentInList( keylist_preproc, CutPreprocIdent(thismod, src) )
	
//------------------------------------------------
// プリプロセッサ行キーワードか？
//------------------------------------------------
#modcfunc isPPWord@MCHspLexer str src
	return isIdentInList( keylist_ppword )
	
//------------------------------------------------
// プリプロセッサ命令の識別子の部分を取り出す
//------------------------------------------------
#modcfunc CutPreprocIdent@MCHspLexer str src,  local stmp
	stmp = src
	stmp = strmid( stmp, 1 + CntSpaces( stmp, 1 ), strlen(stmp) )
	return stmp
	
	/*
//------------------------------------------------
// 命令か？ ( src に無駄な記号や空白があると、偽 )
//------------------------------------------------
#modcfunc isSttm@MCHspLexer str src
	return isIdentInList( keylist_sttm )
	
//------------------------------------------------
// 関数か？
//------------------------------------------------
#modcfunc isFunc@MCHspLexer str src
	return isIdentInList( keylist_func )
	
//------------------------------------------------
// システム変数か？
//------------------------------------------------
#modcfunc isSysvar@MCHspLexer str src
	return isIdentInList( keylist_sysvar )
	
//------------------------------------------------
// マクロか？
//------------------------------------------------
#modcfunc isMacro@MCHspLexer str src
	return isIdentInList( keylist_macro )
	
//------------------------------------------------
// 定数か？
//------------------------------------------------
#modcfunc isConst@MCHspLexer str src
	return isIdentInList( keylist_const )
	
//------------------------------------------------
// ユーザ定義命令か？
//------------------------------------------------
#modcfunc isDefSttm@MCHspLexer str src
	return isIdentInList( keylist_defsttm )
	
//------------------------------------------------
// ユーザ定義関数か？
//------------------------------------------------
#modcfunc isDefFunc@MCHspLexer str src
	return isIdentInList( keylist_deffunc )
	
//------------------------------------------------
// Dll関数か？
//------------------------------------------------
#modcfunc isDllFunc@MCHspLexer str src
	return isIdentInList( keylist_dllfunc )
	
//------------------------------------------------
// InterFace か？
//------------------------------------------------
#modcfunc isIFace@MCHspLexer str src
	return isIdentInList( keylist_iface )
	
//------------------------------------------------
// モジュール名か？
//------------------------------------------------
#modcfunc isModname@MCHspLexer str src
	return isIdentInList( keylist_modname )
	
//------------------------------------------------
// 変数か？
//------------------------------------------------
#modcfunc isVar@MCHspLexer str src
	return isIdentInList( keylist_var )
	//*/
	
#global

//##############################################################################
//                テスト
//##############################################################################
#if 1

#include "MCLongString.as"

	s = {"
		// 識別子を切り出して返す
		#defcfunc CutName var sSrc, int iOffset,  \\
			local n
		\	
		\	FTM_CutToken ( IsIdent(c) || IsSJIS1st(c) || c == '`' ), IsSJIS1st(c)
		\	return \"Hello, world!\"
	"}
	
	fSplit = HspLexer_Flag_ExtendTab
	
	hspLexer_new lexer
	hspLexer_set lexer, fSplit, 4
	hspLexer_lex lexer, tktypelist, tkstrlist, s
	
	LongStr_new ls
	
	foreach tktypelist
		
		LongStr_add ls, "type\t= "+ tktypelist(cnt) +"\n"
		LongStr_add ls, "str\t= "+  tkstrlist (cnt)  +"\n"
		LongStr_add ls, "\n"
		
	loop
	
	LongStr_toBuf  ls, buf
	LongStr_delete ls
	
	objmode 2
	font msgothic, 12
	mesbox buf, ginfo(12), ginfo(13)
	
	stop
	
#endif

#endif
