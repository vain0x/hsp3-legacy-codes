// ツリービュー管理モジュール

#ifndef IG_MODULECLASS_TREEVIEW_AS
#define IG_MODULECLASS_TREEVIEW_AS

#include "Treeview.as"

#module tvmod minfTv

#define true  1
#define false 0
#define mv modvar tvmod@

//------------------------------------------------
// モジュール初期化
//------------------------------------------------
#deffunc _init@tvmod
	dim tvitem, 10		// TVITEM 構造体
	dim  tvins, 12		// TVINSERTSTRUCT 構造体
	sdim pszText, 512
	return
	
//##############################################################################
//        メンバ命令・関数群
//##############################################################################
//------------------------------------------------
// 追加
//------------------------------------------------
#define global Tv_Insert(%1,%2="",%3=TVI_ROOT,%4=TVI_SORT,%5=0,%6=0) _Tv_Insert %1,%2,%3,%4,%5,%6
#modfunc _Tv_Insert str p2, int hTvParent, int hTvItem, int status, int iImg
	pszText  = p2				// いったん変数に移しておく
	
	tvins(0) = hTvParent		// 親アイテムのハンドル
	tvins(1) = hTvItem			// 挿入位置のアイテムハンドル
	tvins(2) = 0x002F			// TVIF_TEXT | TVIF_IMAGE | TVIF_STATE | TVIF_SELECTEDIMAGE
	tvins(4) = status, status	// アイテムの状態
	tvins(6) = varptr(pszText)	// 文字列のアドレス
	tvins(8) = iImg				// イメージインデックス(非選択時)
	tvins(9) = iImg				// イメージインデックス(選択時)
	
	sendmsg minfTv, 0x1100, 0, varptr(tvins)	// TVM_INSERTITEM
	return stat
	
//------------------------------------------------
// 削除
//------------------------------------------------
#modfunc Tv_Delete int hTvItem
	sendmsg minfTv, 0x1101, 0, hTvItem
	return
	
#define global Tv_DeleteAll(%1) Tv_Delete %1, TVI_ROOT

//##########################################################
//        ハンドル取得系
//##########################################################
//------------------------------------------------
// 取得
// 
// TVGN_*, hTvItem(p2に依存)
//------------------------------------------------
#define global ctype Tv_GetTarget(%1,%2,%3=0) _Tv_GetTarget(%1,%2,%3)
#defcfunc _Tv_GetTarget mv, int p2, int hTvItem
	sendmsg minfTv, 0x110A, p2, hTvItem	// TVM_GETNEXTITEM
	return stat
	
#define global ctype Tv_GetRoot(%1)     Tv_GetTarget(%1, TVGN_ROOT)//      ルート
#define global ctype Tv_GetNext(%1,%2)  Tv_GetTarget(%1, TVGN_NEXT,  %2)// 弟
#define global ctype Tv_GetPrev(%1,%2)  Tv_GetTarget(%1, TVGN_PREV,  %2)// 兄
#define global ctype Tv_GetParent(%1,%2)Tv_GetTarget(%1, TVGN_PARENT,%2)// 親
#define global ctype Tv_GetChild(%1,%2) Tv_GetTarget(%1, TVGN_CHILD, %2)// 長子
#define global ctype Tv_GetSelected(%1) Tv_GetTarget(%1, TVGN_CARET)//     選択状態
#define global ctype Tv_GetDropped(%1)  Tv_GetTarget(%1, TVGN_DROPHILIGHT)// ドロップ対象

//##########################################################
//        項目文字列操作系
//##########################################################
//------------------------------------------------
// 取得
//------------------------------------------------
#define global ctype Tv_GetString(%1,%2,%3=511) _Tv_GetString(%1,%2,%3)
#defcfunc _Tv_GetString mv, int hTvItem, int p3
	if ( p3 > 511 ) { memexpand pszText, p3 + 1 }
	
	tvitem(0) = 1, hTvItem				// TVIF_TEXT
	tvitem(4) = varptr(pszText), p3		// 文字列のアドレスと、最大文字列長
	
	sendmsg minfTv, 0x110C, 0, varptr(tvitem)	// TVM_GETITEM
	return pszText
	
//------------------------------------------------
// 設定
//------------------------------------------------
#modfunc Tv_SetString int hTvItem, str p3
	pszText   = p3
	tvitem(0) = 1, hTvItem
	tvitem(4) = varptr(pszText)
	
	sendmsg minfTv, 0x110D, 0, varptr(tvitem)	// TVM_SETITEM
	return
	
//##########################################################
//        イメージリスト関係
//##########################################################

//------------------------------------------------
// ツリービューにイメージリストを関連づける
//------------------------------------------------
#modfunc Tv_SetImglist int hImglist
	sendmsg minfTv, 0x1109, 0, hImglist		// TVM_SETIMAGELIST
	return
	
	
//##########################################################
//        汎用メンバ関数群
//##########################################################
//------------------------------------------------
// 項目の開閉
//------------------------------------------------
#modfunc Tv_Expand int hTvItem, int flag
	sendmsg minfTv, 0x1102, flag, hTvItem
	return
	
//------------------------------------------------
// 項目数
//------------------------------------------------
#defcfunc Tv_GetCount mv
	sendmsg minfTv, 0x1105, 0, 0		// TVM_GETCOUNT
	return stat
	
//------------------------------------------------
// 項目のRECT
//------------------------------------------------
#modfunc Tv_GetRect mv, int hTvItem, array _rect
	dim _rect, 4
		_rect(0) = hTvItem
	
	sendmsg minfTv, 0x1104, false, varptr(_rect)	// TVM_GETITEMRECT
	if ( stat == false ) {		// 失敗した
		memset _rect, 0, 16		// 0 で埋める
		return false
	}
	return true
	
//##############################################################################
//        コンストラクタ・デストラクタ
//##############################################################################
#define global CreateTreeview(%1,%2,%3,%4=0) newmod %1,tvmod,%2,%3,%4
#modinit int cx, int cy, int p4
	dim minfTv, 2
	
	winobj "SysTreeView32", "", 0, 0x50000000 | p4, cx, cy
	minfTv = objinfo(stat, 2), stat
	
	return minfTv(1)
	
#global
_init@tvmod

//##############################################################################
//        サンプル・スクリプト
//##############################################################################
#if 0

#include "Mo/BitmapMaker.as"

	// イメージリスト作成 (16×16×4, 24bit, マスクあり)
	CreateImageList 16, 16, 25, 4
	hIml = stat					// イメージリストのハンドル
	
	// イメージリスト作成用バッファウィンドウ
	buffer 2, , , 0
	picload "treeicon.bmp"		// ビットマップの読み込み
	
	// イメージリストにイメージを追加
	AddImageList hIml, 0, 0, 16 * 4, 16, 0x00F0CAA6
	
	// ツリービュー作成
	gsel 0
	CreateTreeview mTv, ginfo(12) / 2, ginfo(13), 0x800000 | TVS_HASBUTTON | TVS_HASLINES | TVS_LINESATROOT
	hTree = objinfo(stat, 2)		// ツリービューのハンドル
	
	// ツリービューのイメージリストを設定
	Tv_SetImglist mTv, hIml
	
	dim hRoot , 2
	dim hChild, 2
	
	// ツリービューのアイテム追加
	Tv_Insert         mTv, "親アイテム１",   TVI_ROOT, TVI_SORT,, 0 : hRoot     = stat
		Tv_Insert     mTv, "子アイテム１",      hRoot, TVI_SORT,, 1 : hChild(0) = stat
			Tv_Insert mTv, "孫アイテム１",  hChild(0), TVI_SORT,, 2
		Tv_Insert     mTv, "子アイテム２",      hRoot, TVI_SORT,, 1 : hChild(1) = stat
			Tv_Insert mTv, "孫アイテム２",  hChild(1), TVI_SORT,, 2
	
	gsel 0
	oncmd gosub *OnNotify, 0x004E
	
	pos ginfo(12) / 2 + 5, 0
	stop
	
*OnNotify
	dupptr nmhdr, lparam, 12			// NMHDR構造体
	
	if ( nmhdr(0) == hTree ) {
		
		if ( nmhdr(2) == TVN_SELCHANGED ) {
			mes Tv_GetString( mTv, Tv_GetSelected( mTv ) )
		}
		
	}
	return
	
#endif

#endif
