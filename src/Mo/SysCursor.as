// SysCursor module

#ifndef __SYSTEM_CURSOR_MODULE_AS__
#define __SYSTEM_CURSOR_MODULE_AS__

#module syscursor_mod

#define global IDC_ARROW			0x00007F00		// 標準矢印カーソル
#define global IDC_IBEAM			0x00007F01		// I 型カーソル
#define global IDC_WAIT				0x00007F02		// 砂時計
#define global IDC_CROSS			0x00007F03		// 十字
#define global IDC_UPARROW			0x00007F04		// 垂直の矢印カーソル
#define global IDC_SIZE				0x00007F80		// (使用しない)
#define global IDC_ICON				0x00007F81		// (使用しない)
#define global IDC_SIZENWSE			0x00007F82		// 斜め右下がりの矢印カーソル
#define global IDC_SIZENESW			0x00007F83		// 斜め左下がりの矢印カーソル
#define global IDC_SIZEWE			0x00007F84		// 左右 矢印カーソル
#define global IDC_SIZENS			0x00007F85		// 上下 矢印カーソル
#define global IDC_SIZEALL			0x00007F86		// 四方向矢印カーソル
#define global IDC_NO				0x00007F88		// 禁止カーソル
#define global IDC_HAND				0x00007F89		// 手カーソル
#define global IDC_APPSTARTING		0x00007F8A		// 標準矢印カーソルおよび小型砂時計カーソル
#define global IDC_HELP				0x00007F8B		// ？カーソル

#uselib "user32.dll"
#func   SetClassLong@syscursor_mod "SetClassLongA" int,int,int
#cfunc  LoadCursor@syscursor_mod   "LoadCursorA"   nullptr,int
#func   SetCursor@syscursor_mod    "SetCursor"     int
#func   GetCursor@syscursor_mod    "GetCursor"

#define global SetSystemCursor(%1=hwnd,%2) _SetSystemCursor %1,%2
#deffunc _SetSystemCursor int p1, int p2
	
	// システム定義カーソルのハンドル取得
	hCursor = LoadCursor(p2)			// システムのカーソルハンドルを取得する
	if ( hCursor == 0 ) {
		return 1
	}
	
	SetClassLong p1, -12, hCursor		// -12 == GCL_HCURSOR
	SetCursor hCursor 					// カーソル変更
	return 0
	
#global

#if 0

	SetSystemCursor hwnd, IDC_NO;APPSTARTING
	stop
	
#endif

#endif
