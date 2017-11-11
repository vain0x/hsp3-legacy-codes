// 子ウィンドウ作成モジュール

#ifndef IG_CREATE_CHILD_WINDOW_AS
#define IG_CREATE_CHILD_WINDOW_AS

#module mCreateChildWindow

#define WS_CHILD 0x40000000
#define WS_POPUP 0x80000000

#uselib "user32.dll"
#func   SetWindowLong@mCreateChildWindow "SetWindowLongA" int,int,int
#cfunc  GetWindowLong@mCreateChildWindow "GetWindowLongA" int,int
#func   SetParent@mCreateChildWindow     "SetParent"      int,int

// マクロ
#define SetStyle(%1,%2=-16,%3=0,%4=0) SetWindowLong %1, %2, BitOff(GetWindowLong(%1, %2) | %3, %4)
#define ctype BITOFF(%1,%2=0) ( (%1) & ((%2) ^ 0xFFFFFFFF) )

//------------------------------------------------
// 子ウィンドウの作成
// 
// @prm hParent : 親ウィンドウのハンドル
// @prm wid     : 使用されるウィンドウID
// @prm sx, sy  : ウィンドウの最大サイズ
// @prm flag    : フラグ (screen 参照)
// @            : + 32 でキャプションなし (bgscr)
// @prm winStyle      : 追加で使う　　ウィンドウ・スタイル
// @prm winStyleEx    : 追加で使う拡張ウィンドウ・スタイル
// @prm winOutStyle   : 使用しない　　ウィンドウ・スタイル
// @prm winOutStyleEx : 使用しない拡張ウィンドウ・スタイル
// @result stat : ウィンドウ・ハンドル (hwnd)
//------------------------------------------------
#deffunc CreateChildWindow int hParent, int wid, int sx, int sy, int flag, int winStyle, int winStyleEx, int winOutStyle, int winOutStyleEx
	if ( flag & 32 ) {
		bgscr  wid, sx, sy, 2 | (flag & 1), 0, 0
	} else {
		screen wid, sx, sy, 2 | (flag & 0b11111), 0, 0
	}
	
	hChild = hwnd
	SetStyle hwnd, -16, winStyle | WS_CHILD, winOutStyle | WS_POPUP	// スタイル (子ウィンドウにする)
	
	if ( winStyleEx || winOutStyleEx ) {
		SetStyle hwnd, -20, winStyleEx, winOutStyleEx		// 拡張スタイル
	}
	SetParent hwnd, hParent									// 子ウィンドウにする
	
	if ( (flag & 2) == 0 ) {	// 隠し属性が無いなら
		gsel wid, 1			// 開ける
	}
	
	return hWin
	
#global

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 0

#enum IDW_Main = 0
#enum IDW_Child
	
	screen IDW_Main, 640, 480, 16
	CreateChildWindow hwnd, IDW_Child, 240, 120, 2 + 8	// ツールウィンドウ
	width 120, 80, 0,0
	
	color : boxf : syscolor 15
	mes "おーい\n…… \n子 window より"
	gsel IDW_Child, 1
	gsel IDW_Main,  1
	
	stop
	
#endif

#endif
