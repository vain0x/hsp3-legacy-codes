// deflister - header

#ifndef __DEFINED_LISTER_HEADER_AS__
#define __DEFINED_LISTER_HEADER_AS__

#include "Mo/strutil.as"

// Win32 API
#uselib "user32.dll"
#func   global SetWindowLong  "SetWindowLongA" int,int,int
#cfunc  global GetWindowLong  "GetWindowLongA" int,int
#func   global MoveWindow     "MoveWindow"     int,int,int,int,int,int
#func   global PostMessage    "PostMessageA"   int,int,int,sptr
#func   global CharLower      "CharLowerA"     sptr
#func   global SetScrollInfo  "SetScrollInfo"  int,int,int,int
#func   global InvalidateRect "InvalidateRect" int,int,int
#func   global UpdateWindow   "UpdateWindow"   int
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

//##################################################################################################
//        モジュール
//##################################################################################################
#module deflister_mod

#define true  1
#define false 0

// 各行の先頭に行番号を埋め込む
#deffunc SetLineNum var retbuf, str text, str sform, int start, local buf, local iWrote, local index, local bufsize, local stmp
	buf     = text
	bufsize = 3200
	index   = 0
	iWrote  = 0
	
	sdim stmp, 250
	sdim retbuf, bufsize
	
	repeat , start
		// 次の一行を取得
		getstr stmp, buf, index : index += strsize
		
		if ( strsize == 0 ) { break }
		
		// オーバーフローを監視
		if ( (bufsize - iWrote - strsize) < 1200 ) {
			bufsize = iWrote + strsize + 3200
			memexpand retbuf, bufsize
		}
		
		// 書き込む
		poke retbuf, iWrote, strf(sform, cnt) + stmp +"\n"
		iWrote += strsize
	loop
	return
	
// 定義をリストアップする
#deffunc TookDefinition var retbuf, array lnlist, str p2, local script, local count, local bufsize, local stmp, local iWrote, local index, local ppName, local ppOffset
	script  = p2
	iWrote  = 0
	index   = 0
	bufsize = 3200
	count   = 0
	sdim   stmp, 250
	sdim ppName
	sdim retbuf, 3200
	
	repeat
		// 次の一行を取得
		getstr stmp, script, index : index += strsize
		
		if ( strsize == 0 ) { break }
		
		// 空白を無視
		ppOffset = CntSpaces(stmp, 0)
		
		// プリプロセッサ命令があれば、チェック
		if ( peek(stmp, ppOffset) == '#' ) {
			ppOffset ++
			ppOffset += CntSpaces(stmp, ppOffset)			// # と名称の間の空白を無視
			ppOffset += TookIdent(ppName, stmp, ppOffset)	// プリプロセッサ命令の名前
			switch getpath( ppName, 16 )
				
				case "deffunc" : case "defcfunc" 
				case "modfunc" : case "modcfunc"
				case "define"  : case "const"    : case "enum"
*@:					ppOffset += CntSpaces(stmp, ppOffset)
					ppOffset += TookIdent(ppName, stmp, ppOffset)
					
					switch getpath( ppName, 16 )
					case "global" : case "local" : case "ctype"
						goto *@b
					swend
					
					// リストに追加
					if ( ( bufsize - iWrote - ppOffset ) < 1200 ) {	// ※ppOffset > strlen(ppName)
						bufsize =    iWrote + ppOffset + 3200
						memexpand retbuf, bufsize
					}
					poke retbuf, iWrote, ppName +"\n" : iWrote += strsize
					lnlist(count) = cnt
					count ++
					swbreak
			swend
		}
	loop
	return count
	
// 周辺の三行を取り出す
#deffunc TookArline3 var bufArline3, str p2, int linenum, local text, local index, local stmp
	text  = p2
	index = 0
	
	sdim stmp, 1200
	sdim bufArline3, 256
	
	if ( linenum == 0 ) { bufArline3 = "\n" }
	
	repeat
		// 次の一行を取り出す
		getstr stmp, text, index : index += strsize
		
		if ( strsize == 0 ) {
			break
		}
		
		if ( numrg(cnt, linenum - 1, linenum + 1) ) {
			bufArline3 += stmp +"\n"
			count ++
			if ( count == 3 ) { break }
		}
		
	loop
	
	if ( count < 3 ) {
		repeat 3 - count
			bufArline3 += "\n"
			count ++
		loop
	}
	
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
