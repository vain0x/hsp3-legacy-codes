// 子ウィンドウ作成モジュール

#ifndef __CREATE_CHILD_WINDOW_AS__
#define __CREATE_CHILD_WINDOW_AS__

#module mCreateChildWindow

#define WS_CHILD 0x40000000
#define WS_POPUP 0x80000000

#uselib "user32.dll"
#func   SetWindowLong@mCreateChildWindow "SetWindowLongA" int,int,int
#cfunc  GetWindowLong@mCreateChildWindow "GetWindowLongA" int,int
#func   SetParent@mCreateChildWindow     "SetParent"      int,int

// マクロ
#define SetStyle(%1,%2=-16,%3=0,%4=0) SetWindowLong %1,%2,BitOff(GetWindowLong(%1,%2) | %3, %4)
#define ctype BITOFF(%1,%2=0) ( ((%2) ^ 0xFFFFFFFF & (%1)) )

// 親hwnd, wID, SizeX, SizeY, Flag, WS, WS_EX, outWS, outWS_EX
#deffunc CreateChildWindow int pHwnd, int winID, int SizeX, int SizeY, int _f, int winStyle, int winStyleEx, int winOutStyle, int winOutStyleEx
	if ( _f & 32 ) {		// 32 は特別
		bgscr  winID, SizeX, SizeY, 2 | (_f & 1), 0, 0
	} else {
		screen winID, SizeX, SizeY, 2 | (_f & 0b11111), 0, 0
	}
	hWin = hwnd
	
	SetStyle hwnd, -16, winStyle | WS_CHILD, winOutStyle | WS_POPUP		// スタイル (子ウィンドウにする)
	
	if ( winStyleEx || winOutStyleEx ) {
		SetStyle hwnd, -20, winStyleEx, winOutStyleEx					// 拡張スタイル
	}
	SetParent hwnd, pHwnd												// 子ウィンドウにする
	
	if ( ( _f & 2 ) == 0 ) {	// 隠し属性が無いなら
		gsel winID, 1			// 開ける
	}
	
	return hWin
	
#global

#if 0
	screen 0, 640, 480, 16
	CreateChildWindow hwnd, 2, 240, 120, 2, 0, 0x00000080	// ツールウィンドウ
	width 120, 80, 0,0
	color : boxf : syscolor 15
	mes "おーい\n…… \n子 window より"
	gsel 2, 1
	gsel 0, 1
	
	wait 500
	end
#endif

#endif
