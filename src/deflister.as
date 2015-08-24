// deflister - header

#ifndef __DEFINED_LISTER_HEADER_AS__
#define __DEFINED_LISTER_HEADER_AS__

#include "Mo/cwhich.as"
#include "Mo/LongString.as"
#include "Mo/strutil.as"
#include "Mo/HPM_GetToken.as"

// Win32 API
#uselib "user32.dll"
#func   global SetWindowLong  "SetWindowLongA" int,int,int
#cfunc  global GetWindowLong  "GetWindowLongA" int,int
#func   global MoveWindow     "MoveWindow"     int,int,int,int,int,int
#func   global PostMessage    "PostMessageA"   int,int,int,sptr
#func   global SetScrollInfo  "SetScrollInfo"  int,int,int,int
#cfunc  global LoadCursor     "LoadCursorA"    nullptr,int
#func   global SetClassLong   "SetClassLongA"  int,int,int
#func   global SetCursor      "SetCursor"      int
#func   global EnableWindow   "EnableWindow"   int,int

//##################################################################################################
//        定数・マクロ
//##################################################################################################
// window ID
#const wID_Main 0

#const UWM_SPLITTERMOVE 0x0400

// DEFTYPE
#const global DEFTYPE_LABEL		0x0001		// ラベル
#const global DEFTYPE_MACRO		0x0002		// マクロ
#const global DEFTYPE_CONST		0x0004		// 定数
#const global DEFTYPE_FUNC		0x0008		// 命令・関数

#const global DEFTYPE_CTYPE		0x0100		// CTYPE
#const global DEFTYPE_MODULE	0x0200		// モジュールメンバ

// 特殊な空間名
#define global AREA_GLOBAL "global"
#define global AREA_ALL    "*"

//##################################################################################################
//        モジュール
//##################################################################################################
#module deflister_mod

#include "Mo/ctype.as"
#include "Mo/HPM_Header.as"

#define true  1
#define false 0

// 各行の先頭に行番号を埋め込む
#deffunc SetLineNum var retbuf, str text, str sform, int start, local buf, local tmpbuf, local index, local stmp
	newmod tmpbuf, longstr
	buf   = text
	index = 0
	
	sdim stmp, 320
	
	repeat , start
		// 次の一行を取得
		getstr stmp, buf, index : index += strsize
		
		if ( strsize == 0 ) { break }
		
		// 書き込む
		LongStr_cat tmpbuf, strf(sform, cnt) + stmp +"\n"
	loop
	
	sdim retbuf,  LongStr_len(tmpbuf) + 1
	     retbuf = LongStr_get(tmpbuf)
	return
	
// 指定文字インデックスのある行番号を取得する
#defcfunc GetLinenumByIndex str p1, int p2, int iStart, int iStartLineNum, local text, local linenum, local c
	text    = p1
	linenum = iStartLineNum
	
	if ( iStart > p2 ) { return iStartLineNum }
	
	repeat p2 - iStart, iStart
		c = peek(text, cnt)
		if ( c == 0x0D || c == 0x0A ) {		// 改行コード
			linenum ++
			if ( c == 0x0D && peek(text, cnt + 1) == 0x0A ) {
				continue cnt + 2
			}
		} else : if ( IsSJIS1st(c) ) {		// 全角文字
			continue cnt + 2
			
		} else : if ( c == 0 ) {
			break
		}
	loop
	
	return linenum
	
// 定義タイプから文字列を生成する
#defcfunc MakeDefTypeString int deftype, local stype
	sdim stype, 320
	if ( deftype & DEFTYPE_LABEL ) { stype = "ラベル" }
	if ( deftype & DEFTYPE_MACRO ) { stype = "マクロ" }
	if ( deftype & DEFTYPE_CONST ) { stype = "定数"   }
	if ( deftype & DEFTYPE_FUNC ) {
		if ( deftype & DEFTYPE_CTYPE ) { stype = "関数" } else { stype = "命令" }
	} else {
		if ( deftype & DEFTYPE_CTYPE ) { stype += " Ｃ" }
	}
	if ( deftype & DEFTYPE_MODULE ) { stype += " Ｍ" }
	return stype
	
// (private) モジュール空間名を決定する
#defcfunc TookModuleName var scope, var script, int offset, str defscope, local index
	index = offset
	if ( peek(script, index) == '@' ) {
		index ++
		index += TookIdent(scope, script, index)
		if ( stat == 0 ) { scope = AREA_GLOBAL }
	} else {
		scope = defscope
	}
	return index - offset
	
// 定義をリストアップする( 引数の順番に注意 )
#deffunc TookDefinition str p1, array listIdent, array listLn, array listType, array listScope, local script, local listIndex, local count, local stmp, local index, local textlen, local areaScope, local scope, local nowTT, local befTT, local bPreLine, local bGlobal, local deftype
	script  = p1
	index   = 0
	count   = 0
	textlen = strlen(script)
	sdim stmp, 250
	sdim name
	sdim scope
	sdim areaScope
	
	dim  listLn   ,  5
	sdim listIdent,, 5
	dim  listType ,  5
	sdim listScope,, 5
	dim  listIndex,  5		// 文字インデックスのリスト( 高速化のために使う )
	
	areaScope = AREA_GLOBAL
	
	repeat
		// 空白を飛ばす
		index += CntSpaces(script, index)
		
		// 最後まで取得できたら終了する
		if ( textlen <= index ) { break }
		
		// 次のトークンを取得
		GetNextToken nowtk, script, index, befTT, bPreLine : nowTT = stat
		if ( nowTT == TOKENTYPE_ERROR ) {
			index += strlen(nowtk)
			continue				// 単純に無視するだけ
		}
		
		// トークンの種類ごとに処理をわける
		gosub *L_ProcToken
		
		// インデックスを進める
		index += strlen(nowtk)
		
		befTT = nowTT
	loop
	
	return count
	
*L_ProcToken
	switch nowTT
	
	case TOKENTYPE_COMMENT : nowTT = befTT : swbreak
	
	case TOKENTYPE_END		// 文の終了
		nowTT = TOKENTYPE_NONE
		if ( bPreLine ) { bPreLine = false }
		swbreak
		
	case TOKENTYPE_LABEL	// ラベル
		if ( befTT == TOKENTYPE_NONE ) {	// 行頭の場合のみ
			
			index += strlen(nowtk)
			index += TookModuleName(scope, script, index, areaScope)
			
			// リストに追加
			listIdent(count) = nowtk
			if ( count <= 0 ) {
				listLn(count) = GetLinenumByIndex(script, index, 0, 0)
			} else {
				listLn(count) = GetLinenumByIndex(script, index, listIndex(count - 1), listLn(count - 1))
			}
			listType (count) = DEFTYPE_LABEL
			listScope(count) = scope
			listIndex(count) = index
			count ++
		}
		swbreak
		
	case TOKENTYPE_PREPROC	// プリプロセッサ命令
		if ( IsPreproc(nowtk) ) {
			bPreLine = true
			index   += strlen(nowtk)
			deftype  = 0
			bGlobal  = false
			
			// # と空白を除去する
			getstr nowtk, nowtk, 1 + CntSpaces(nowtk, 1)
			
			switch ( getpath( nowtk, 16 ) )
			case "module"
				index += CntSpaces(script, index)				// ignore 空白
				if ( peek(script, index) == '"' ) { index ++ }	// #module "modname" の形式に対応
				index += TookIdent(areaScope, script, index)	// 空間名
				swbreak
			case "global" : areaScope = AREA_GLOBAL : swbreak	// モジュール空間からの脱出
			
			case "modfunc"  : deftype  = DEFTYPE_MODULE
			case "deffunc"  : deftype |= DEFTYPE_FUNC                   : goto *L_AddDefinition
			case "modcfunc" : deftype  = DEFTYPE_MODULE
			case "defcfunc" : deftype |= DEFTYPE_FUNC   | DEFTYPE_CTYPE : goto *L_AddDefinition
			case "define"   : deftype  = DEFTYPE_MACRO                  : goto *L_AddDefinition
			case "const"
			case "enum"     : deftype  = DEFTYPE_CONST                  : goto *L_AddDefinition
*L_AddDefinition
				index += CntSpaces(script, index)			// 空白 ignore
				index += TookIdent(nowtk, script, index)	// 識別子を取り出す
				switch getpath( nowtk, 16 )
					case "global" : bGlobal  = true          : goto *L_AddDefinition
					case "ctype"  : deftype |= DEFTYPE_CTYPE : goto *L_AddDefinition
					case "local"  : bGlobal  = false         : goto *L_AddDefinition
				swend
				
				index += TookModuleName(scope, script, index, areaScope)
				
				listIdent(count) = nowtk
				if ( count <= 0 ) {
					listLn(count) = GetLinenumByIndex(script, index, 0, 0)
				} else {
					listLn(count) = GetLinenumByIndex(script, index, listIndex(count - 1), listLn(count - 1))
				}
				listType (count) = deftype
				listScope(count) = cwhich( bGlobal, AREA_ALL, scope )
				listIndex(count) = index
				count ++
				swbreak
			swend
			
			poke nowtk
		}
		swbreak
		
	swend
	return
	
// 周辺の三行を取り出す
#deffunc TookArline3 var bufArline3, str p2, int linenum, local text, local index, local stmp, local tmpbuf
	newmod tmpbuf, longstr
	text  = p2
	index = 0
	
	sdim stmp, 1200
	sdim bufArline3, 256
	
	if ( linenum == 0 ) { LongStr_cat tmpbuf, "\n" }
	
	repeat
		// 次の一行を取り出す
		getstr stmp, text, index : index += strsize
		
		if ( strsize == 0 ) {
			break
		}
		
		if ( numrg(cnt, linenum - 1, linenum + 1) ) {
			LongStr_cat tmpbuf, stmp +"\n"
			count ++
			if ( count == 3 ) { break }
		}
		
	loop
	
	if ( count < 3 ) {
		repeat 3 - count
			LongStr_cat tmpbuf, "\n"
			count ++
		loop
	}
	
	sdim bufArline3,  LongStr_len(tmpbuf)
	     bufArline3 = LongStr_get(tmpbuf)
	
	return
	
// コントロールを単一方向にスクロールする( direction = SB_HORZ(=0) or SB_VERT(=1) )
#deffunc ScrollWindow int handle, int direction, int nPos
	dim scrollinfo, 8
	scrollinfo = 32, 0x04, 0, 0, 0, nPos
	SetScrollInfo handle, direction, varptr(scrollinfo), true
	sendmsg       handle, 0x0114 + direction, MAKELONG(4, nPos), handle
	return
	
#global

#endif
