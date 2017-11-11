// MenuBarAPI

#ifndef IG_MENU_BAR_API_AS
#define IG_MENU_BAR_API_AS

#uselib "user32.dll"
#cfunc  global CreateMenu         "CreateMenu"							// hMenu = CreateMenu()
#cfunc  global CreatePopupMenu    "CreatePopupMenu"						// hMenu = CreatePopupMenu()
#func   global AppendMenu         "AppendMenuA"        int,int,int,sptr	// hMenu, State, IDM, "str"
#func   global SetMenuItemInfo    "SetMenuItemInfoA"   int,int,int,int	// hMenu, ID, Flag, MENUITEMINFO *
#func   global GetMenuItemInfo    "GetMenuItemInfoA"   int,int,int,int	// 〃
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

// モジュール
#module menu_mod

// hMenu, ID, bNewState, 3(Grayed) | 8(Checked)
#deffunc MI_ChangeState int p1, int p2, int p3, int p4
	dim mii, 12								// MENUITEMINFO 構造体
		mii = 48, 1, 0, ((p3 != 0) * p4)	// fState
	SetMenuItemInfo p1, p2, 0, varptr(mii)
	return (stat)
	
// hMenu, ID, "NewString"
#deffunc SetMenuString int p1, int p2, str p3
	string = p3
	dim mii, 12
		mii = 48, 0x0040
		mii(9) = varptr(string)
	SetMenuItemInfo p1, p2, 0, varptr(mii)	// 設定
	return (stat)
#global

#if 0

// メニューアイテムの識別子をenumで定義
#enum IDM_NONE = 0	// 1つめは = 0 が必要
	// ファイル
#enum IDM_NEW
#enum IDM_OPEN
#enum IDM_OWS	// = Over Write Save
#enum IDM_SAVE
	#enum IDM_CHAR_SJIS
	#enum IDM_CHAR_UTF_8
	#enum IDM_CHAR_UTF_16
#enum IDM_QUIT
	// 編集
#enum IDM_UNDO
;#enum IDM_REDO
#enum IDM_CUT
#enum IDM_COPY
#enum IDM_PASTE
#enum IDM_DELETE
#enum IDM_ALLSEL
	// 検索
#enum IDM_SEARSH
#enum IDM_FIND_BACK
#enum IDM_FIND_NEXT
#enum IDM_REPLACE
	// ツール
#enum IDM_INSTIME

// その他の定義(必須ではない)
#uselib "user32.dll"
#func PostMessage   "PostMessageA" int,int,int,int
#func MoveWindow    "MoveWindow"   int,int,int,int,int,int
#func GetWindowRect "GetWindowRect" int,int

#define fname getpath(fdir, 8)
#define fext  getpath(fdir, 2+16)
#define titleEx(%1="new") title "Edit - "+ (%1)
#define Renew(%1=buf,%2=fname) objprm EditInfo(1),%1:titleEx %2

#const wID_Main 1

// メイン開始
	gsel 0, -1
	screen 0, 0, 0, 2
*main
	
	screen wID_Main, ginfo(20), ginfo(21), 2,,, 640, 480
	gosub *CreateMenuBar			// メニューバーを作成する
	
	dim    EditInfo, 2
	sdim   buf, 65535
	mesbox buf, ginfo(12), ginfo(13)	// 簡易エディタなので、一応
	EditInfo = objinfo(stat, 2), stat
	
	notesel buf
	
	titleEx
	gsel wID_Main, 1
	
	onIDM  gosub *Command, 0x0111	// WM_COMMAND (メニューバーからの割り込み)
	onIDM  gosub *Resize,  0x0005	// WM_SIZE (サイズ変更)
;	onkey  gosub *key				// キー割り込み
	onexit goto  *exit				// 終了時の呼び出し
	
	stop

*CreateMenuBar
	// メニューアイテムを作成
	hCharacter= CreatePopupMenu() 
	hFileMenu = CreatePopupMenu()
		AppendMenu hFileMenu, 0, IDM_NEW,  "新規作成(&N)"		+"\t\tCtrl + N"
		AppendMenu hFileMenu, 0, IDM_OPEN, "開く(&O)"			+"\t\tCtrl + O"
		AppendMenu hFileMenu, 0, IDM_OWS,  "上書き保存(&S)"		+"\t\tCtrl + S"
		AppendMenu hFileMenu, 0, IDM_SAVE, "名前をつけて保存"
		AddSeparator hFileMenu	// セパレータ
		AppendMenu hFileMenu, 0x10, hCharacter, "文字コード"
			AppendMenu hCharacter, 0, IDM_CHAR_SJIS,   "S-JIS"
			AppendMenu hCharacter, 0, IDM_CHAR_UTF_8,  "UTF-8"
			AppendMenu hCharacter, 0, IDM_CHAR_UTF_16, "UTF-16"
		AddSeparator hFileMenu
		AppendMenu hFileMenu, 0, IDM_QUIT, "このソフトを終了する\t\tCtrl + Q"
	
	hEditMenu = CreatePopupMenu()
		AppendMenu hEditMenu, 0, IDM_UNDO,  "元に戻す(&U)"		+"\t\tCtrl + Z"
		AddSeparator hEditMenu
		AppendMenu hEditMenu, 0, IDM_CUT,   "切り取り(&T)"		+"\t\tCtrl + X"
		AppendMenu hEditMenu, 0, IDM_COPY,  "コピー(&C)"		+"\t\tCtrl + C"
		AppendMenu hEditMenu, 0, IDM_PASTE, "貼り付け(&P)"		+"\t\tCtrl + V"
		AppendMenu hEditMenu, 0, IDM_DELETE, "削除(&D)"			+"\t\t Delete "
		AddSeparator hEditMenu
		AppendMenu hEditMenu, 0, IDM_ALLSEL, "すべて選択 \t\tCtrl + Q"
		
	hFindMenu = CreatePopupMenu()
		AppendMenu hFindMenu, 0, IDM_SEARCH,    "文字列検索" + "\t\tCtrl + F"
		AppendMenu hFindMenu, 0, IDM_FIND_BACK, "後方検索"   + "\t\t  F2"
		AppendMenu hFindMenu, 0, IDM_FIND_NEXT, "前方検索"   + "\t\t  F3"
		AppendMenu hFindMenu, 0, IDM_REPLACE,   "文字列置換" + "\t\tCtrl + R"
		
	hFormMenu = CreatePopupMenu()
		AppendMenu hFormMenu, 0, IDM_INSTIME, "現在の時刻を挿入\t\t F5"
		
	// バーのメニュー
	hMenu = CreateMenu()
		AppendMenu hMenu, 0x10, hFileMenu, "ファイル(&F)"
		AppendMenu hMenu, 0x10, hEditMenu, "編集(&E)"
		AppendMenu hMenu, 0x10, hFindMenu, "検索(&S)"
		AppendMenu hMenu, 0x10, hFormMenu, "書式(&O)"
		AppendMenu hMenu, 0x10, IDM_QUIT,  "終了(&Q)"
		
	// 文字コードをセットにする
	SetRadioMenu hCharacter, IDM_CHAR_SJIS, IDM_CHAR_UTF_16, 0
	
	// メニューバーを作成
	SetMenu     hwnd, hMenu			// メニューをウィンドウに割り当てる
	DrawMenuBar hwnd				// メニューを再描画
	return
	
*Command
	cID = wParam & 0xFFFF
	
	switch cID
	case IDM_NEW	: gosub *new									: swbreak	// 新規作成
	case IDM_OPEN	: gosub *open									: swbreak	// 開く
	case IDM_RELOAD	: gosub *ReLoad									: swbreak	// 再読込
	case IDM_OWS	: gosub *OverWriteSave							: swbreak	// 上書き保存
	case IDM_SAVE	: gosub *Save									: swbreak	// 名前をつけて保存
	case IDM_QUIT	: PostMessage hwnd, 0x0010, 0, 0				: swbreak	// 終了
	
	case IDM_UNDO	: sendmsg EditInfo, 0x0304, 0, 0				: swbreak	// アンドゥ
	case IDM_CUT	: sendmsg EditInfo, 0x0300, 0, 0				: swbreak	// 切り取り
	case IDM_COPY	: sendmsg EditInfo, 0x0301, 0, 0				: swbreak	// コピー
	case IDM_PASTE	: sendmsg EditInfo, 0x0302, 0, 0				: swbreak	// 貼り付け
	case IDM_DELETE	: sendmsg EditInfo, 0x0303, 0, 0				: swbreak	// 削除
	case IDM_ALLSEL	: sendmsg EditInfo, 0x00B1, 0, strlen(buf)		: swbreak	// すべて選択
	
	case IDM_CHAR_SJIS		// この3つのどれでも変更になる
	case IDM_CHAR_UTF_8		// 文字コードを制御する処理は入れていません。
	case IDM_CHAR_UTF_16
		SetRadioMenu hCharacter, IDM_CHAR_SJIS, IDM_CHAR_UTF_16, cID - IDM_CHAR_SJIS
		swbreak
		
	case IDM_INSTIME : gosub *InsTime								: swbreak
	swend
	return
	
*New
	dialog "すべて削除してもよろしいですか？", 2, "警告"
	if ( stat == 7 ) { return }
	
	memset buf,  0, 65535
	memset fdir, 0, 260
	
	Renew "", "new"
	return
	
*Open
	dialog "*", 16, "ﾃｷｽﾄﾌｧｲﾙ"
	if ( stat == 0 ) { return }
	exist refstr
	if ( strsize == -1 ) { return }
	fdir =    refstr
	noteload (refstr)
	
	Renew
	return
	
*Reload
	dialog "現在の編集は無効になり、最後に保存した状態に戻します。\nよろしいですか？", 2, "警告"
	exist fdir
	if ( stat == 0 || strsize == -1 ) { return }
	
	noteload fdir
	Renew
	return
	
*OverWriteSave
	exist fdir
	if ( strsize == -1 ) {
		goto *Save
	}
	notesave fdir
	Renew
	return
	
*Save
	dialog "*", 17, "保存先"
	if ( stat == 0 ) { return }
	fdir =    refstr
	notesave (refstr)
	
	Renew
	return
	
*InsTime			// 現在の時刻を挿入する
	// 書式[21:16 2008/04/23]
	sdim tstr, 320
	tstr = ""+ strf("%02d", gettime(4)) +":"+ strf("%02d", gettime(5)) +" "+ gettime(0) +"/"+ gettime(1) +"/"+ gettime(3)
	
	sendmsg EditInfo, 0x00C2, 1, varptr(tstr)
	return
	
*Resize				// ウィンドウのサイズが変わった
	MoveWindow EditInfo, 0, 0, lParam & 0xFFFF, (lParam >> 16) & 0xFFFF, 1
	return
	
*exit
	// dialog 命令では [キャンセル] 付きのダイアログを出せない。
	dialog "内容を保存しますか？", 2, "終了は止まりません……"
	if ( stat == 6 ) { gosub *Save }
	
	if ( hMenu ) { DestroyMenu hMenu }	// メニューバーを破棄 (必須)
	
	noteunsel	// 必要ない
	end
	
#endif

#endif
