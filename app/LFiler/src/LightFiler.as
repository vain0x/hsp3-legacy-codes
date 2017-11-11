// Light Filer - Header

#ifndef __LFILER_HEADER_AS__
#define __LFILER_HEADER_AS__

//##############################################################################
//        Win32API 関数
//##############################################################################
#uselib "user32.dll"
#func   PostMessage   "PostMessageA"   int,int,int,sptr
#cfunc  GetWindowLong "GetWindowLongA" int,int
#func   SetWindowLong "SetWindowLongA" int,int,int
#func   MoveWindow    "MoveWindow"     int,int,int,int,int,int
#func   GetWindowRect "GetWindowRect"  int,int
#func   GetClientRect "GetClientRect"  int,int

//##############################################################################
//        定数・マクロ
//##############################################################################
#define STR_TITLE "LFiler"
#define STR_ININAME "config.ini"

#const MAX_TOOLBTN 7

// 変数
#define actTabIdx ActTabIndex(mTab)
#define actView mView( TabInt(mTab, actTabIdx) )

// ID Window
#enum global IDW_MAIN = 0
#enum global IDW_ICON
#enum global IDW_TEMP		// 一時的なバッファ
#enum global IDW_MAX
#enum global IDW_TABTOP

#define whMain hWindow(IDW_MAIN)
#define whIcon hWindow(IDW_ICON)

// ID Toolbar
#enum IDT_NONE = 0
#enum IDT_BACK = 0
#enum IDT_NEXT
#enum IDT_UP
#enum IDT_FOLDER
#enum IDT_DOS
#enum IDT_RENEW
#enum IDT_DELETE
#enum IDT_MAX

// サイズ
#const  PX_TAB 0
#define PY_TAB (TbHeight + CY_PATH)
#define CX_TAB winsize(0)
#define CY_TAB (winsize(1) - PY_TAB - SbHeight)

#const  PX_PATH 0
#define PY_PATH TbHeight
#define CX_PATH ( winsize(0) - PX_PATH )
#const  CY_PATH 18

#const  PX_TB 0
#const  PY_TB 0
#define CX_TB winsize(0)
#define CY_TB TbHeight

#const  PX_SB 0
#define PY_SB (winsize(1) - CY_SB)
#define CX_SB winsize(0)
#define CY_SB SbHeight

//##############################################################################
//        マクロ命令・関数
//##############################################################################

#define SetTitle(%1="") title getpath((%1), 8) +" ＠"+ STR_TITLE
#define SetActiveView(%1=0) sendmsg whMain, UWM_ACTVIEW_CHANGE, (%1), 0

#endif
