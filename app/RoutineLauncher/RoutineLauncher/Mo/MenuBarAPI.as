#ifndef IG_MENU_BAR_API_AS
#define IG_MENU_BAR_API_AS

#uselib "user32.dll"
#cfunc  global CreateMenu         "CreateMenu"							// hMenu = CreateMenu()
#cfunc  global CreatePopupMenu    "CreatePopupMenu"						// hMenu = CreatePopupMenu()
#func   global AppendMenu         "AppendMenuA"        int,int,int,sptr	// hMenu, State, IDM, "str"
#func   global SetMenuItemInfo    "SetMenuItemInfoA"   int,int,int,int	// hMenu, ID, Flag, MENUITEMINFO *
#func   global GetMenuItemInfo    "GetMenuItemInfoA"   int,int,int,int	// ÅV
#func   global EnableMenuItem     "EnableMenuItem"     int,int,int		// hMenu, ID, Flag
#func   global CheckMenuItem      "CheckMenuItem"      int,int,int		// hMenu, ID, Flag
#func   global CheckMenuRadioItem "CheckMenuRadioItem" int,int,int,int,int	// hMenu, FirstID, LastID, DefID, Flag
#func   global SetMenuItemBitmaps "SetMenuItemBitmaps" int,int,int,int,int	// hMenu, ID, Flag, hBmpUnchecking, hBmpChecking
#func   global SetMenu            "SetMenu"            int,int				// hwnd, hMenu
#func   global DrawMenuBar        "DrawMenuBar"        int					// hwnd
#func   global DestroyMenu        "DestroyMenu"        int					// hMenu
#func   global TrackPopupMenuEx   "TrackPopupMenuEx"   int,int,int,int,int,int	// hPopMenu, Flag, sPosX, sPosY, hwnd, LPRECT for Can'tPopupArea (or Nullptr)

#define global AddSeparator(%1) AppendMenu (%1), 0x0800, 0, ""	// hMenu
#define global SetRadioMenu(%1,%2,%3,%4=0) CheckMenuRadioItem %1,%2,%3,(%2)+(%4),0

#module menu_mod

// hMenu, ID, bNewState, 3(Grayed) | 8(Checked)
#deffunc MI_ChangeState int p1, int p2, int p3, int p4
	dim mii, 12								// MENUITEMINFO ç\ë¢ëÃ
		mii = 48, 1, 0, ((p3 != 0) * p4)	// fState
	SetMenuItemInfo p1, p2, 0, varptr(mii)
	return (stat)
	
// hMenu, ID, "NewString"
#deffunc SetMenuString int p1, int p2, str p3
	string = p3
	dim mii, 12
		mii = 48, 0x0040
		mii(9) = varptr(string)
	SetMenuItemInfo p1, p2, 0, varptr(mii)	// ê›íË
	return (stat)
#global

#endif
