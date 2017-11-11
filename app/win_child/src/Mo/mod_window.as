// ウィンドウに関するあれこれ

// ・座標変換( スクリーン、ウィンドウ、クライアント )
// ・システムメニュー項目の削除( 移動禁止など )

#ifndef IG_WINDOW_COORD_SYS_AS
#define IG_WINDOW_COORD_SYS_AS

#module mod_window

//------------------------------------------------
//        Win32 API
//------------------------------------------------
#uselib "user32.dll"
#func   SetWindowLong@mod_window  "SetWindowLongA" int,int,int
#cfunc  GetWindowLong@mod_window  "GetWindowLongA" int,int
#func   GetWindowRect@mod_window  "GetWindowRect"  int,int
#func   ScreenToClient@mod_window "ScreenToClient" int,int
#func   ClientToScreen@mod_window "ClientToScreen" int,int
#cfunc  GetSystemMenu@mod_window  "GetSystemMenu"  int,int
#func   DeleteMenu@mod_window     "DeleteMenu"     int,int,int

//------------------------------------------------
//        マクロ
//------------------------------------------------
#define ctype HIWORD(%1) (((%1) >> 16) & 0xFFFF)
#define ctype LOWORD(%1) ((%1) & 0xFFFF)
#define ctype MAKELONG(%1,%2) (LOWORD(%1) | (LOWORD(%2) << 16))
#define true  1
#define false 0
#define NULL  0

//------------------------------------------------
//        定数
//------------------------------------------------
#define SC_MINIMIZE   0xF020
#define SC_MAXIMIZE   0xF030
#define SC_CLOSE      0xF060
#define SC_RESTORE    0xF120
#define SC_TASKLIST   0xF130
#define SC_SCREENSAVE 0xF140

#define WS_MAXIMIZEBOX 0x00010000
#define WS_MINIMIZEBOX 0x00020000
#define WS_SYSMENU     0x00080000

//##############################################################################
//                命令・関数群
//##############################################################################
//------------------------------------------------
// モジュール初期化
//------------------------------------------------
#deffunc initialize_mod_window
	dim rctmp@mod_window, 4
	dim pttmp@mod_window, 2
	return
	
//################################################
//        座標相互変換
//################################################

//------------------------------------------------
// スクリーン座標 ←→ クライアント座標
//------------------------------------------------
#defcfunc CnvScreenToClient int hWindow, int position
	pttmp = LOWORD(position), HIWORD(position)
	ScreenToClient hWindow, varptr(pttmp)
	return MAKELONG( pttmp(0), pttmp(1) )
	
#defcfunc CnvClientToScreen int hWindow, int position
	pttmp = LOWORD(position), HIWORD(position)
	ClientToScreen hWindow, varptr(pttmp)
	return MAKELONG( pttmp(0), pttmp(1) )
	
//------------------------------------------------
// スクリーン座標 ←→ ウィンドウ座標
//------------------------------------------------
#defcfunc CnvScreenToWindow int hWindow, int position
	GetWindowRect hWindow, varptr(rctmp)
	return MAKELONG( LOWORD(position) - rctmp(0), HIWORD(position) - rctmp(1) )
	
#defcfunc CnvWindowToScreen int hWindow, int position
	GetWindowRect hWindow, varptr(rctmp)
	return MAKELONG( LOWORD(position) + rctmp(0), HIWORD(position) + rctmp(1) )
	
//------------------------------------------------
// ウィンドウ座標 ←→ クライアント座標
//------------------------------------------------
#defcfunc CnvWindowToClient int hWindow, int position
	return CnvScreenToClient( hWindow, CnvWindowToScreen(hWindow, position) )
	
#defcfunc CnvClientToWindow int hWindow, int position
	return CnvScreenToWindow( hWindow, CnvClientToScreen(hWindow, position) )
	
//################################################
//        ウィンドウ・サイズ
//################################################
//------------------------------------------------
// WM_SYSCOMMAND 関係
//------------------------------------------------
#define global Window_Minimize(%1) sendmsg %1, 0x0112, SC_MINIMIZE@mod_window, 0
#define global Window_Maximize(%1) sendmsg %1, 0x0112, SC_MAXIMIZE@mod_window, 0
#define global Window_Restore(%1)  sendmsg %1, 0x0112, SC_RESTORE@mod_window,  0
#define global Window_TaskList(%1) sendmsg %1, 0x0112, SC_TASKLIST@mod_window, 0
#define global Window_ScreenSave(%1) sendmsg %1, 0x0112, SC_SCREENSAVE@mod_window, 0

//################################################
//        その他
//################################################
//------------------------------------------------
// 移動を禁ずる
//------------------------------------------------
#deffunc ForbidMoving int hWindow
	DeleteMenu GetSystemMenu( hWindow, false ), 0xF010, 0
	return
	
//------------------------------------------------
// システムメニューを元に戻す
//------------------------------------------------
#deffunc ResetSystemMenu int hWindow
	return GetSystemMenu( hWindow, true )	// p2 に true を指定、戻り値は NULL
	
//------------------------------------------------
// 最大化ボタンを有効化・無効化
//------------------------------------------------
#deffunc EnableMaximizeBox int hWindow, int bAble
	SetWindowLong hWindow, -16, BITOFF(GetWindowLong(hWindow, -16) | WS_MAXIMIZEBOX * (bAble != false), WS_MAXIMIZEBOX * (bAble == false) )
	return
	
//------------------------------------------------
// 最小化ボタンを有効化・無効化
//------------------------------------------------
#deffunc EnableMinimizeBox int hWindow, int bAble
	SetWindowLong hWindow, -16, BITOFF(GetWindowLong(hWindow, -16) | WS_MINIMIZEBOX * (bAble != false), WS_MINIMIZEBOX * (bAble == false) )
	return
	
//------------------------------------------------
// ウィンドウボタンを有効化・無効化
//------------------------------------------------
#deffunc EnableWindowBtn int hWindow, int bAble
	SetWindowLong hWindow, -16, BITOFF(GetWindowLong(hWindow, -16) | WS_SYSMENU * (bAble != false), WS_SYSMENU * (bAble == false) )
	return
	
#global

	initialize_mod_window

/*******************************************************************************
＠座標の説明

＊スクリーン座標
	画面(スクリーン)全体からみた座標。絶対座標的な存在。
	
＊ウィンドウ座標
	ウィンドウの左上を中心とした座標。
	
＊クライアント座標
	ウィンドウの中のクライアント領域の左上を中心とした座標。
	タイトルバーやウィンドウの枠などは含まないため、ウィンドウ座標と若干違う値になる。
	
*******************************************************************************/

#endif
