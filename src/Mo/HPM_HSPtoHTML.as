// HSP parse module - HSP to HTML

#ifndef __HSP_PARSE_MODULE_HSP_TO_HTML_AS__
#define __HSP_PARSE_MODULE_HSP_TO_HTML_AS__

#include "Mo/MCLongString.as"	// 長い文字列を扱う
#include "Mo/ToSR_ForHTML.as"	// 実体参照
#include "HPM_getToken.as"		// [判別付き] 識別子取り出しモジュール
#include "HPM_split.as"			// HSPスクリプト分解モジュール

#module hpmod_HSPtoHTML

#include "HPM_header.as"		// ヘッダファイル

#define ctype STR_STARTTAG(%1) "<span class=\""+ (%1) +"\">"
#define STR_ENDTAG "</span>"

#const  LENGTH_STARTTAG 15
#const  LENGTH_ENDTAG   7
#const  LENGTH_TAG      LENGTH_STARTTAG + LENGTH_ENDTAG

#define success 1
#define failure 0

//------------------------------------------------
// HSP スクリプトを HTML に変換する
//------------------------------------------------
#define nxtTkStr  tkstrlist (idx + 1)
#define nxtTkType tktypelist(idx + 1)
#define nowTkStr  tkstrlist (idx)
#define nowTkType tktypelist(idx)
#define befTkStr  tkstrlist (idx - 1)
#define befTkType tktypelist(idx - 1)

#deffunc hpm_HSPtoHTML var outbuf, str in_script, int bEscSpace, int fSplit, int nTabSize,  local tkstrlist, local tktypelist, local ls, local idx, local bSetTag, local bPreprocLine
	
	hpm_split tktypelist, tkstrlist, in_script,  fSplit, nTabSize
	
	// 変数を確保する
	LongStr_new ls
	
	idx = 0
	repeat length(tktypelist)
		
		// トークンの種類ごとに処理をわける
		gosub *LProcToken
		
		// スクリプトに書き込む
		LongStr_cat ls, nowTkStr
		
		idx ++
	loop
	
	LongStr_tobuf  ls, outbuf
	LongStr_delete ls
	return success
	
//------------------------------------------------
// トークンごとに処理をする
//------------------------------------------------
#define INTO_TAG(%1=nowTkType) nowTkStr = STR_STARTTAG(stt_tagname(%1)) + nowTkStr + STR_ENDTAG : bSetTag = false
#define ToSR(%1,%2=0) ToSubstanceReference (%1), (%2)
*LProcToken
	
	bSetTag = true		// 最後に INTO_TAG するかどうか
	
	switch ( nowTkType )
	
	// 文の終了
	case TKTYPE_END
		if ( IsNewLine( peek(nowTkStr) ) ) {
			bPreprocLine = false
		}
		swbreak
		
	// 空白 or コメント or 文字列 or 演算子 => 実体参照に変換する必要がある ( かも )
	case TKTYPE_BLANK
	case TKTYPE_COMMENT
	case TKTYPE_STRING
	case TKTYPE_OPERATOR
		ToSR nowTkStr, bEscSpace
		swbreak
		
	// プリプロセッサ命令
	case TKTYPE_PREPROC
		// preproc 識別子が未定義な場合は、色分けしない
		if ( IsPreproc(nowTkStr) == false ) {
			bSetTag      = false
		} else {
			bPreprocLine = true
		}
		swbreak
		
	// 識別子
;	case TKTYPE_NAME
;		swbreak
	
	swend
	
	// タグで括る
	if ( bSetTag ) {
		if ( stt_tagname(nowTkType) != "" ) {	// 空ならしない
			INTO_TAG
		}
	}
	
	return
	
//------------------------------------------------
// モジュール初期化
//------------------------------------------------
#deffunc _init@hpmod_HSPtoHTML
	
	// タグ名のリスト
	sdim stt_tagname, TKTYPE_MAX
;	stt_tagname(TKTYPE_OPERATOR)     = ""
;	stt_tagname(TKTYPE_CIRCLE_L)     = ""
;	stt_tagname(TKTYPE_CIRCLE_R)     = ""
;	stt_tagname(TKTYPE_MACRO_PRM)    = ""
;	stt_tagname(TKTYPE_MACRO_SP)     = ""
;	stt_tagname(TKTYPE_NUMBER)       = ""
	stt_tagname(TKTYPE_STRING)       = "string"
	stt_tagname(TKTYPE_CHAR)         = "char"
	stt_tagname(TKTYPE_LABEL)        = "label"
	stt_tagname(TKTYPE_PREPROC)      = "preproc"
;	stt_tagname(TKTYPE_KEYWORD)      = ""
;	stt_tagname(TKTYPE_VARIABLE)     = ""		// 無効
;	stt_tagname(TKTYPE_NAME)         = ""		// 〃
	stt_tagname(TKTYPE_COMMENT)      = "comment"
;	stt_tagname(TKTYPE_COMMA)        = ""
;	stt_tagname(TKTYPE_PERIOD)       = ""
	stt_tagname(TKTYPE_SCOPE)        = "scope"
;	stt_tagname(TKTYPE_ESC_LINEFEED) = ""
	
	stt_tagname(TKTYPE_EX_STATEMENT)       = "statement"
	stt_tagname(TKTYPE_EX_FUNCTION)        = "function"
	stt_tagname(TKTYPE_EX_SYSVAR)          = "sysvar"
	stt_tagname(TKTYPE_EX_MACRO)           = "macro"
	stt_tagname(TKTYPE_EX_PREPROC_KEYWORD) = "ppword"
;	stt_tagname(TKTYPE_EX_CONST)           = "const"
;	stt_tagname(TKTYPE_EX_USER_STTM)       = "defsttm"
;	stt_tagname(TKTYPE_EX_USER_FUNC)       = "deffunc"
;	stt_tagname(TKTYPE_EX_DLLFUNC)         = "dllfunc"
;	stt_tagname(TKTYPE_EX_IFACE)           = "iface"
;	stt_tagname(TKTYPE_EX_MODNAME)         = "modname"
;	stt_tagname(TKTYPE_EX_VAR)             = "var"
	return
	
#global
_init@hpmod_HSPtoHTML

#endif
