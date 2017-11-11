// Light Filer - MCView

#ifndef __LFILER_MODULECLASS_VIEW_AS__
#define __LFILER_MODULECLASS_VIEW_AS__

#include "Mo/abdata/dlinklist.as"
#include "Mo/BitmapMaker.as"
#include "Mo/exginfo.as"
#include "Mo/GetFontOfHSP.as"
#include "Mo/icomod.as"
#include "Mo/pvalptr.as"
#include "Mo/MCLongString.as"
#include "Mo/MCNoteRepeat.as"

#include "MCViewData.as"

#module MCView mhParent, mwID, mhWnd, mTv, minfTv, mLv, minfLv, miLv, msPath, mData, mInstVDat, mhFont, mhImglist

// Win32API
#uselib "user32.dll"
#cfunc  GetWindowLong@MCView "GetWindowLongA" int,int
#func   SetWindowLong@MCView "SetWindowLongA" int,int,int
#func   MoveWindow@MCView    "MoveWindow"     int,int,int,int,int,int

// 定数
#define true 1
#define false 0
#define mv modvar MCView@
#define MAX_PATH 260

// サイズ
#const  PX_TV 0
#const  PY_TV 0
#define CX_TV (_tvcx@ * bUseTv@)
#define CY_TV exginfo(13, mwID)

#define PX_LV CX_TV
#const  PY_LV 0
#define CX_LV (exginfo(12, mwID) - CX_TV)
#define CY_LV exginfo(13, mwID)

//##############################################################################
//        下請け命令・関数群
//##############################################################################
// モジュール初期化
#deffunc _init@MCView
	return
	
// フォルダ名で終わるパスにする
#defcfunc ToFolderPath str p1, local path, local len, local c
	len  = strlen(p1)
	if ( len == 0 ) { return dir_desktop }	// デスクトップ
	sdim path, len + 3
	path = p1
	c    = peek(path, len - 1)
	
	if ( c == '\\' ) {
		poke path, len - 1, 0
	}
	return path
	
// \ で終わるパスにする
#defcfunc ToBSlashPath str p1, local path, local len, local c
	len  = strlen(p1)
	sdim path, len + 3
	if ( len == 0 ) { return dir_desktop +"\\" }
	path = p1
	c    = peek(path, len - 1)
	
	if ( c != '\\' ) {
		wpoke path, len, '\\'
	}
	return path
	
// ディレクトリが存在するかどうかを調べる
#defcfunc existsDir str p1, local flist
	dirlist flist, ToFolderPath(p1), 5
	return stat != 0
	
// パスがドライブのパスかどうかを調べる( x:\ )
#defcfunc IsDrivePath str p1, local path, local len
	len  = strlen(p1)
	sdim path, len + 1
	path = p1
	return ( ( len == 2 || len == 3 ) && peek(path, 1) == ':' )
	
// フォルダ名を取り出す
#defcfunc GetFolderName str p1, local path
	if ( IsDrivePath(p1) ) {
		path = p1
		return strmid(path, 0, 1)
	}
	return getpath(ToFolderPath(p1), 8)
	
//##############################################################################
//        メンバ命令・関数群
//##############################################################################

// (private) 現在のパスを再設定
#modfunc View_SetCurPath@MCView local vdat
	DLList_PeekNext mData, vdat
	msPath = ViewData_path(vdat)
	return
	
// (private) 履歴に追加する
#modfunc View_AddHistory@MCView str path, local vdat
	
	// 履歴の途中の場合
	while ( DLList_IterIsLast(mData) == false )
		DLList_Skip   mData, 1
		DLList_DelNow mData		// 後ろの履歴がすべて削除される
	wend
	
	// 追加
	newmod mInstVDat, MCViewData, ToBSlashPath( path )
	DLList_InsNow_var mData, mInstVDat(stat)
	
	// ログ出力
;	DLList_AllPut mData, ViewData_path( allput_dat )
	
	return
	
// (private) リストボックスを更新する
#modfunc View_RenewLv@MCView local vdat
	sendmsg  minfLv, 0x000B, false, 0
	LvDeleteAll mLv					// 全項目を削除
	
	DLList_PeekNext mData, vdat		// データを得る
	
	// フォルダを優先
	repeat ViewData_cntFolders( vdat )
		LvInsertItem  mLv, ViewData_folderlist( vdat, cnt )
		LvCtBackColor mLv, stat, 0xEEEEFF
	loop
	
	// ファイルを追加
	repeat ViewData_cntFiles( vdat )
		LvInsertItem  mLv, ViewData_filelist( vdat, cnt )
		LvCtBackColor mLv, stat, 0xEEFFEE
	loop
	
	sendmsg minfLv, 0x000B, true, 0
	return
	
// フォルダを開く
#modfunc View_GoDir str path, int bHisMoving, local vdat
	if ( existsDir( path ) == false ) {
		return false
	}
	
;	logmes "godir : "+ path
	
	if ( bHisMoving == false ) {
		View_AddHistory thismod, path	// 履歴に追加する
	}
	View_SetCurPath	thismod				// 現在のパスに更新
	View_RenewLv    thismod				// リストボックスを更新する
	
	sendmsg mhParent, UWM_SETPATH, mwID, varptr(msPath)
	return true
	
//######## ハンドラ ##############################
// アクティブ化したとき
#modfunc View_OnActivate
	sendmsg mhParent, UWM_SETPATH, mwID, varptr(msPath)
	return
	
// サイズが変わったとき
#modfunc View_OnSize
	MoveWindow minfTv, PX_TV, PY_TV, CX_TV, CY_TV, true
	MoveWindow minfLv, PX_LV, PY_LV, CX_LV, CY_LV, true
	sendmsg    minfLv, 0x101E, 3, -2		// LVM_SETCOLUMNWIDTH
	return
	
// 「戻る」とき
#modfunc View_OnBack local vdat
	if ( DLList_IterIsTop( mData ) ) { return false }
	
	DLList_Back     mData, 1
	View_SetCurPath thismod
	View_GoDir      thismod, msPath, true
	return true
	
// 「進む」とき
#modfunc View_OnNext local vdat
	if ( DLList_IterIsLast( mData ) ) { return false }
	
	DLList_Skip     mData, 1
	View_SetCurPath thismod
	View_GoDir      thismod, msPath, true
	return true
	
// 「上へ」のとき
#modfunc View_OnUp
	if ( IsDrivePath(msPath) ) {
		View_GoDir thismod, dir_desktop +"\\"
	} else {
		View_GoDir thismod, getpath(ToFolderPath(msPath), 32)
	}
	return
	
// WM_NOTIFY のとき
#modfunc View_OnNotify int wp, int lp, local stmp, local nmhdr
	
	dupptr nmhdr, lp, 12
	
	if ( nmhdr(0) == minfLv ) {
		
		// NM_CUSTOMDRAW (これはカスタムドローの処理)
		if ( nmhdr(2) == -12 ) {
			
			if ( LvIsCustom(mLv) ) {
				dupptr NMLVCUSTOMDRAW, lp, 60		// NMLVCUSTOMDRAW 構造体
				
				if ( NMLVCUSTOMDRAW(3) == 0x0001 ) {	// CDDS_REPAINT (描画サイクルの前)
					return 0x0020						// CDRF_NOTIFYITEMDRAW (アイテムの描画処理を親に通知)
				}
				
				if ( NMLVCUSTOMDRAW(3) == 0x10001 ) {	// CDDS_ITEMREPAINT (描画前)
					NMLVCUSTOMDRAW(12) = LvTextColor(mLv, NMLVCUSTOMDRAW(9))	// 文字色
					NMLVCUSTOMDRAW(13) = LvBackColor(mLv, NMLVCUSTOMDRAW(9))	// 背景色
					return 0x0002
				}
			}
			
		} else : if ( nmhdr(2) == -101 ) {	// LVN_ITEMCHANGED
			dupptr NMLISTVIEW, lp, 12 + 32		// NMLISTVIEW 構造体
			miLv = NMLISTVIEW(3)				// NMLISTVIEW::iItem
;			if ( NMLISTVIEW(5) & 0x02 ) {		// NMLISTVIEW::uNewState & LVIS_SELECTED
;				// 選択された
;			}
		} else : if ( nmhdr(2) == -114 ) {	// LVN_ITEMACTIVATE
			if ( miLv < 0 ) { return }
			
			stmp = msPath + LvGetStr( mLv, miLv )
			
			if ( existsDir(stmp) ) {
				View_GoDir thismod, stmp
			} else {
				exec stmp, 16
			}
		}
		
	}
	return 0
	
//##############################################################################
//        取得系関数群
//##############################################################################
#defcfunc View_wID mv
	return mwID
	
#defcfunc View_hwnd mv
	return mhWnd
	
#defcfunc View_path mv
	return msPath
	
//##############################################################################
//        コンストラクタ・デストラクタ
//##############################################################################
#modinit int hParent, int wID, str path
	
	old_actwID = ginfo(2)
	gsel wID
	
	// メンバ変数の初期化
	mhParent = hParent
	mwID     = wID
	dim  minfTv, 2
	dim  minfLv, 2
	sdim msPath, MAX_PATH
	
	DLList_new mData				// データリスト履歴
	
	msPath = ToBSlashPath(path)		// \ で終わるパス
	mhWnd  = hwnd					// ハンドル
	
	// 初期化処理
	gosub *LCreateTreeview			// ツリービューを作成
	gosub *LCreateListview			// リストビューを作成
	oncmd gosub *OnNotify, 0x004E	// 割り込みを受け付ける
	
	View_GoDir thismod, msPath		// ディレクトリを開く
	
	gsel old_actwID
	return getaptr(thismod)
	
*LCreateTreeview
;	pos PX_TV, PY_TV
	return
	
*LCreateListview
	pos PX_LV, PY_LV
	CreateListview mLv, ginfo(20), ginfo(21), 0x0001 | 0x0200 | 0x8000
	minfLv = objinfo(stat, 2), stat
	
	MoveWindow minfLv, PX_LV, PY_LV, CX_LV, CY_LV, true
	
	LvInsertColumn mLv, "名前",     0, 240, 0
	LvInsertColumn mLv, "サイズ",   1,  60, 1
	LvInsertColumn mLv, "種類",     2, 100, 2
	LvInsertColumn mLv, "更新日時", 3,  80, 3
	
	LvSetExStyle    mLv, 0x0001 | 0x0010 | 0x0020 ;| 0x0004
	LvUseCustomMode mLv
	
	await 0
	ChangeControlFont minfLv, "MS Gothic", 12
	mhFont = stat
	return
	
#modterm
	DeleteFont mhFont : mhFont = 0
	return
	
//##############################################################################
//        その他
//##############################################################################
*OnNotify
	
	View_OnNotify mView@( TabInt( mTab@, WtoI( mTab@, ginfo(24) - IDW_TABTOP@ ) ) ), wparam, lparam
	
	return stat
	
#global
_init@MCView

#endif
