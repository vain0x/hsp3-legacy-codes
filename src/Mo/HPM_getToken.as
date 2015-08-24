// HSP parse module - GetToken

#ifndef __HSP_PARSE_MODULE_GET_TOKEN_AS__
#define __HSP_PARSE_MODULE_GET_TOKEN_AS__

#include "HPM_TookToken.as"	// 識別子取り出し
#include "HPM_Sub.as"		// モジュール

// 主要モジュール
#module hpm_getToken

#include "HPM_Header.as"

#uselib "user32.dll"
#func   _ChrLow "CharLowerA" int

// マクロ
#define ctype IsWOp(%1) ((%1) == '<' || (%1) == '=' || (%1) == '>' || (%1) == '&' || (%1) == '|' || (%1) == '+' || (%1) == '-')

// 次のトークンを取得する
#deffunc GetNextToken var p1, var p2, int p3, int p_befTT, int bPreLine
	c = peek(p2, p3)
	
	// Name (識別子)
	if ( IsIdentTop(c) ) {
		p1 = TookName(p2, p3)
		return TOKENTYPE_NAME
	}
	
	// Preprocessor
	if ( c == '#' ) {
		iFound = 1 + CntSpaces(p2, p3 + 1)		// 空白
		p1     = strmid(p2, p3, iFound) + TookName(p2, p3 + iFound)
		return TOKENTYPE_PREPROC
	}
	
	// String
	if ( c == '"' ) {
		p1 = TookStr(p2, p3)		// 文字列を取り出す (""を含む)
		return TOKENTYPE_STRING
	}
	if ( wpeek(p2, p3) == 0x227B ) {	// {"
		p1 = TookStrMulti(p2, p3)		// 複数行文字列を取り出す ({" "} 含む)
		return TOKENTYPE_STRING
	}
	
	// 終了記号
	if ( c == ':' || c == '{' || c == '}' || IsNewLine(c) ) {
		p1 = strf("%c", c)
		if ( c == 0x0D ) {		// CRLF
			if ( peek(p2, p3 + 1) == 0x0A ) {
				p1 = "\n"
			}
		} else : if ( c == 0x0A ) {
			p1 = "\r"
		}
		return TOKENTYPE_END
	}
	
	// Sign
	if ( c == ',' ) { p1 = "," : return TOKENTYPE_CAMMA    }
	if ( c == '(' ) { p1 = "(" : return TOKENTYPE_CIRCLE_L }
	if ( c == ')' ) { p1 = ")" : return TOKENTYPE_CIRCLE_R }
	if ( c == '.' ) { p1 = "." : return TOKENTYPE_PERIOD   }
	
	// Label ( * から始まり、次が、文の終端、カンマ、) のうちのどれかのとき )
	if ( c == '*' ) {
		if ( IsLabel(p2, p3, p_befTT) ) {	// ラベルか？
			if ( peek(p2, p3 + 1) == '@' ) {
				p1 = "*@"+ TookName(p2, p3 + 2)	// *@ の後は好きなだけ取り出す
			} else {
				p1 = "*"+ TookName(p2, p3 + 1)	// 切り出す
			}
			return TOKENTYPE_LABEL
		}
	}
	
	// Comment
	if ( c == ';' || wpeek(p2, p3) == 0x2F2F ) {
		getstr p1, p2, p3			// 改行まで取り出す
		return TOKENTYPE_COMMENT
	}
	
	// Comment (multi)
	if ( wpeek(p2, p3) == 0x2A2F ) {
		iFound = instr(p2, p3 + 2, "*/")
		if ( iFound < 0 ) {
			p1 = strmid(p2, p3, strlen(p2) - p3)	// 以降すべてコメント
		} else {
			p1 = strmid(p2, p3, iFound + 4)			// 開始・終了も含む
		}
		return TOKENTYPE_COMMENT
	}
	
	// Operator
	if ( IsOperator(c) ) {							// 演算子か？
		
		// 2 バイトの演算子の時もある
		c2 = peek(p2, p3 + 1)
		if ( c2 == '=' || (IsWOp(c) && c == c2) ) {	// ?= か、&& || などの二重
			p1 = strmid(p2, p3, 2)		// 2 byte
		} else {
			p1 = strf("%c", c)			// 1 byte
		}
		if ( c == '\\' && bPreLine ) {	// 改行回避の可能性
			if ( IsNewLine(c2) ) {
				if ( c2 == 0x0D && peek(p2, p3 + 2) == 0x0A ) {
					lpoke p1, 0, MAKELONG2('\\', 0x0D, 0x0A, 0)	// "\\\n"
				} else {
					lpoke p1, 0, MAKEWORD('\\', c2)
				}
				return TOKENTYPE_ESC_LINEFEED
			}
		}
		return TOKENTYPE_OPERATOR
	}
	
	// Char
	if ( c == '\'' ) {
		p1 = TookCharactor(p2, p3)
		return TOKENTYPE_CHAR
	}
	
	// Number (2 or 16)
	if ( c == '$' ) {
		p1 = "$"+ TookNum_Hex(p2, p3 + 1)
		return TOKENTYPE_NUMBER
	}
	if ( c == '%' ) {
		if ( bPreLine ) {
			p1 = "%"+ TookNum_Dgt(p2, p3 + 1)
			return TOKENTYPE_PARAMETER
		} else {
			p1 = "%"+ TookNum_Bin(p2, p3 + 1)
			return TOKENTYPE_NUMBER
		}
	}
	if ( c == '0' ) {
		c2 = peek(p2, p3 + 1)
		if ( c2 == 'x' || c2 == 'X' ) {
			p1 = strmid(p2, p3, 2) + TookNum_Hex(p2, p3 + 2)
			
		} else : if ( c2 == 'b' || c2 == 'B' ) {
			p1 = strmid(p2, p3, 2) + TookNum_Bin(p2, p3 + 2)
			
		} else {
			p1 = TookNum_Dgt(p2, p3)
		}
		return TOKENTYPE_NUMBER
	}
	
	// Number (10)
	if ( IsDigit(c) || c == '.' ) {
		p1 = TookNum_Dgt(p2, p3)		// 10進数
		return TOKENTYPE_NUMBER
	}
	
	// @Scope
	if ( c == '@' ) {
		p1 = "@"+ TookName(p2, p3 + 1)
		return TOKENTYPE_SCOPE
	}
	
	if ( IsSJIS1st(c) ) {
		logmes "ERROR! SJIS code!"
		wpoke p1, 0, wpeek(p2, p3)	// 書き込む
		poke  p1, 3, 0				// NULL
		return TOKENTYPE_ERROR
	}
	
	// ？？？
	p1 = strf("%c", c)
	logmes "ERROR !! Can't Pop a Token! [ "+ logv(p3) +" : "+ strf("%c", c) +" : "+ c +" ]"
	return TOKENTYPE_ERROR
	
#global

#endif
