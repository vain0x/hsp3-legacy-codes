// OwnerDraw Listbox Dll

#ifndef __ODLISTBOX_AS__
#define __ODLISTBOX_AS__

#uselib "ODListbox.dll"
#func   ODLbCreate  "ODLbCreate"  int,int,int,int,int
#func   ODLbDestroy "ODLbDestroy" int
#func   ODLbMove    "ODLbMove"    int,int,int,int,int
#func   ODLbProc    "ODLbProc"    int,int,int,int

#func  _ODLbInsertItem "ODLbInsertItem" int,wstr,int
#define ODLbInsertItem(%1,%2,%3=-1) _ODLbInsertItem %1,%2,%3
#func  _ODLbDeleteItem "ODLbDeleteItem" int,int
#define ODLbDeleteItem(%1,%2=-1) _ODLbDeleteItem %1,%2
#func   ODLbClearItem  "ODLbClearItem"  int
#func   ODLbMoveItem   "ODLbMoveItem"   int,int,int
#func   ODLbSwapItem   "ODLbSwapItem"   int,int,int

#func  _ODLbSetMarginColor "ODLbSetMarginColor" int,int,int
#define ODLbSetMarginColor(%1,%2=-1,%3) _ODLbSetMarginColor %1,%2,%3
#func  _ODLbSetItemColor   "ODLbSetItemColor"   int,int,int,int
#define ODLbSetItemColor(%1,%2=0,%3=0x000000,%4=0xFFFFFF) _ODLbSetItemColor %1,%2,%3,%4
#func   ODLbSetItemPadding "ODLbSetItemPadding" int,int,int,int,int
#func   ODLbSetItemMargin  "ODLbSetItemMargin"  int,int
#func   ODLbSetItemHeight  "ODLbSetItemHeight"  int,int
#func   ODLbSetItemIcon    "ODLbSetItemIcon"    int,int,int
#func   ODLbSetItemLParam  "ODLbSetItemLPARAM"  int,int,int

#func   ODLbUseIcon       "ODLbUseIcon"        int,int
#func   ODLbSetTextFormat "ODLbSetTextFormat"  int,int,int
#func   ODLbSetFont       "ODLbSetFont"        int,int

#func   ODLbSetItemNum      "ODLbSetItemNum"      int,int
#func  _ODLbSetItemNumColor "ODLbSetItemNumColor" int,int,int,int
#define ODLbSetItemNumColor(%1,%2=-1,%3=-1,%4=-1) _ODLbSetItemColor %1,%2,%3,%4
#func   ODLbSetItemNumWidth "ODLbSetItemNumWidth" int,int

#cfunc  ODLbGetHandle       "ODLbGetHandle"       int
#cfunc  ODLbGetLParam       "ODLbGetLPARAM"       int,int

#cfunc  ODLbGetItemHeight   "ODLbGetItemHeight"   int
#cfunc  ODLbGetPadding      "ODLbGetPadding"      int,int
#cfunc  ODLbGetMargin       "ODLbGetMargin"       int
#cfunc  ODLbGetItemNumWidth "ODLbGetItemNumWidth" int
#cfunc  ODLbIsUseIcon       "ODLbIsUseIcon"       int
#cfunc  ODLbGetItemColor    "ODLbGetItemColor"    int,int,int

// ウィンドウクラス
#define WC_ODLISTBOX "LISTBOX"

// ODListbox 専用通知コード
#enum ODLBN_FIRST        = 0x0100
#enum ODLBN_CREATE       = ODLBN_FIRST	// 生成される直前
#enum ODLBN_ITEMINSERTED				// 挿入された
#enum ODLBN_ITEMDELETED					// 削除された
#enum ODLBN_ITEMMOVED					// 移動された
#enum ODLBN_ITEMSWAPPED					// 交換された
#enum ODLBN_ITEMREDRAWN					// 再描画された
#enum ODLBN_LAST

// 関係ありそうでまったくない定数
#const SELMARKWIDTH 5	// 選択項目に付く印の幅
#const ICON_SIZE    16	// 表示できるアイコンのサイズ

#endif
