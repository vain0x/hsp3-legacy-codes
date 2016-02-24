#ifndef IG_RENZOK_AS
#define IG_RENZOK_AS

#uselib "user32.dll"
#func   global SetWindowLong "SetWindowLongA" int,int,int
#cfunc  global GetWindowLong "GetWindowLongA" int,int
#func   global MoveWindow    "MoveWindow"     int,int,int,int,int,int
#cfunc  global LoadCursor    "LoadCursorA"    nullptr,int
#func   global SetClassLong  "SetClassLongA"  int,int,int
#func   global SetCursor     "SetCursor"      int
#func   global ClipCursor    "ClipCursor"     int
#func   global EnableWindow  "EnableWindow"   int,int
#func   global GetScrollInfo "GetScrollInfo"  int,int,int
#func   global GetWindowRect "GetWindowRect"  int,int

#func   global Focus             "" int,int,int,int
#func   global MoveCaret         "" int,int,int,int
#func   global TextModified      "" int,int,int
#func   global InsertModeChanged "" int,int,int

#define global STR_APPNAME "Renzok"
#define global Settitle(%1="") title (STR_APPNAME + " - " + (%1))

#define global STR_BACK      "[[BACK]]"
#define global STR_SEPARATOR "--------"
#define global STR_DIALOG    ":[dialog]:"

// ウィンドウID
#define global wID_Main		0

#define global hMain		hWindow@( wID_Main  )

// サイズ
#define global WIN_DEFAULT_X 640
#define global WIN_DEFAULT_Y 480

#define global MAX_TEXTLEN 0x1FFFF  // 127KB までサポート

#define global LBWIDTH   _LbWidth@
#define global LBHEIGHT  (ginfo(13) - (10 + 20) + 5)
#define global BOXWIDTH  (ginfo(12) - (LBWIDTH + 15))
#define global BOXHEIGHT (ginfo(13) - 10)

// メッセージ
#const global WM_USER			 0x0400 + 0x0100
#const global UWM_LOAD			WM_USER + 0x0001
#const global UWM_CHANGEPATH    WM_USER + 0x0002
#const global UWM_RENEWAL_LIST	WM_USER + 0x0003
#const global UWM_SPLITTERMOVE	WM_USER + 0x0004

// LB_DIR の定数
#const DDL_READWRITE 0x0000  // 読み書き
#const DDL_READONLY  0x0001  // 書き込み禁止ファイル
#const DDL_HIDDEN    0x0002  // 隠しファイル
#const DDL_SYSTEM    0x0004  // システムファイル
#const DDL_DIRECTORY 0x0010  // ディレクトリ
#const DDL_ARCHIVE   0x0020  // アーカイブ
#const DDL_EXCLUSIVE 0x8000  // 排他的にする ( HIDDEN なら、「隠しファイルだけ」 になる )

// MenuCMD
#enum global CMD_NULL = 0
#enum global CMD_UNDO
#enum global CMD_REDO
#enum global CMD_CUT
#enum global CMD_COPY
#enum global CMD_PASTE
#enum global CMD_DELETE
#enum global CMD_SELALL
#enum global CMD_MAX

#ifndef __userdef__
 #define global true  1
 #define global false 0
#endif

#include "Mo/MCNoteRepeat.as"

#module
#undef    getkey
#defcfunc getkey int p2
	getkey@hsp _kc, p2
	return@hsp _kc
	
#deffunc DirlistEx var vfilelist, str path, local lsList, local lIndex
	lIndex = 0
	sdim lsList
	sdim vfilelist, 255
	
	// 親フォルダに戻るコマンドを追加
	poke vfilelist, lIndex, STR_BACK + "\n" : lIndex += strsize
	
	// まずディレクトリのみを取得
	dirlist lsList, path + "\\*?", 5
	if ( stat ) {
		memexpand vfilelist, strlen(lsList) * 2 + 1
		NoteRepeat lsList
			poke vfilelist, lIndex, "[" + nrNote + "]\n"
			lIndex += strsize
		NoteLoop
		
		// セパレータ
		poke vfilelist, lIndex, STR_SEPARATOR + "\n"
		lIndex += strsize
	}
	
	// ファイルのみを取得
	dirlist lsList, path + "\\*.*", 3
	memexpand vfilelist, lIndex + stat * 2 + strlen(lsList) + 1
	NoteRepeat lsList
		poke vfilelist, lIndex, nrNote + "\n"
		lIndex += strsize
	NoteLoop
	return
	
#global

#endif
