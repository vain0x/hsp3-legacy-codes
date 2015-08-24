#ifndef        __TREEVIEW_MODULE_AS__
#define global __TREEVIEW_MODULE_AS__

//######## ツリービュー操作モジュール ##############################################################
#module Tvmod

#include "h/Treeview.as"

//################################################

/*************************************************
|*		描画中ウィンドウにツリービュー作成
|*	CreateTreeview p1, p2
|*		p1 = int	: 幅
|*		p2 = int	: 高さ
|*		返 = stat	: ツリービューのオブジェクトID
.************************************************/
#deffunc CreateTreeview int sx, int sy, int p3
	winobj WC_TREEVIEW, "", 0, 0x50000000 | p3, sx, sy
	return ( stat )
	
/*************************************************
|*		ツリービューにイメージリストを設定
|*	SetTreeImageList p1, p2
|*		p1 = HWND	: ツリービューのハンドル
|*		p2 = HWND	: イメージリストのハンドル
|*		返 = void
.************************************************/
#define global SetTreeImageList(%1,%2) sendmsg %1, 0x1109, 0, %2

/*************************************************
|*		ツリービューにアイテム追加
|*	AddTreeItem p1, p2, p3, p4, p5
|*		p1 = HWND	: ツリービューのハンドル
|*		p2 = str	: 表示するテキスト
|*		p3 = int	: イメージのインデックス ( iImage )
|*		p4 = HWND	: 親アイテムのハンドル
|*						TVI_ROOT	: ルート要素の時
|*		p5 = int	: 挿入位置のアイテムハンドルまたは以下の値
|*						TVI_FIRST	: リストの最初の位置
|*						TVI_LAST	: リストの最後の位置
|*						TVI_SORT	: リストをアルファベット順にソート
|*		p6 = int	: アイテムの初期状態
|*		返 = int	: アイテムハンドル
.************************************************/
#deffunc AddTreeItem int p1, str p2, int p3, int p4, int p5, int p6, local pszText
	pszText = p2					// いったん変数に移しておく
	
	// TVINSERTSTRUCT 構造体
	dim tvins, 12
		tvins(0) = p4				// 親アイテムのハンドル
		tvins(1) = p5				// 挿入位置のアイテムハンドル
		tvins(2) = 0x002F			// TVIF_TEXT | TVIF_IMAGE | TVIF_STATE | TVIF_SELECTEDIMAGE
		tvins(4) = p6, p6			// アイテムの状態
		tvins(6) = varptr(pszText)	// 文字列のアドレス
		tvins(8) = p3				// イメージインデックス(非選択時)
		tvins(9) = p3				// イメージインデックス(選択時)
	
	sendmsg p1, 0x1100, 0, varptr(tvins)	// TVM_INSERTITEM
	return ( stat )
	
/*************************************************
|*		指定されたツリーアイテムを取得
|*	GetTargetTreeItem( p1, p2, p3=0 )
|*		p1 = HWND	: ツリービューのハンドル
|*		p2 = int	: アイテムとの関係
|*		p3 = HWND	: ツリーアイテムのハンドル( 使わないときもある )
|*		返 = int	: 選択されているアイテムのハンドルが返る
.************************************************/
#define global ctype GetTreeItemTarget(%1,%2,%3=0) _GetTreeItemTarget(%1,%2,%3)
#defcfunc _GetTreeItemTarget int p1, int p2, int p3
	sendmsg p1, 0x110A, p2, p3		// TVM_GETNEXTITEM
	return ( stat )
	
#define global ctype GetTreeItemRoot(%1)     GetTreeItemTarget(%1, TVGN_ROOT)
#define global ctype GetTreeItemNext(%1,%2)  GetTreeItemTarget(%1, TVGN_NEXT,  %2)
#define global ctype GetTreeItemPrev(%1,%2)  GetTreeItemTarget(%1, TVGN_PREV,  %2)
#define global ctype GetTreeItemParent(%1,%2)GetTreeItemTarget(%1, TVGN_PARENT,%2)
#define global ctype GetTreeItemChild(%1,%2) GetTreeItemTarget(%1, TVGN_CHILD, %2)
#define global ctype GetTreeItemSelected(%1) GetTreeItemTarget(%1, TVGN_CARET)

/*************************************************
|*		アイテムの文字列を取得する
|*	GetTreeItemString( p1, p2, p3=256 )
|*		p1 = HWND	: ツリービューのハンドル
|*		p2 = HWND	: ツリーアイテムのハンドル
|*		p3 = int	: 文字列の限界
|*		返 = str	: アイテムの文字列
.************************************************/
#define global ctype GetTreeItemString(%1,%2,%3=256) _GetTreeItemString(%1,%2,%3)
#defcfunc _GetTreeItemString int p1, int p2, int p3, local pszText
	sdim pszText, p3 + 1
	
	// TVITEM 構造体
	dim tvitem, 10
		tvitem(0) = 1, p2					// TVIF_TEXT
		tvitem(4) = varptr(pszText), p3		// 文字列のアドレスと、最大文字列長
	sendmsg p1, 0x110C, 0, varptr(tvitem)
	return pszText
	
/*************************************************
|*		ツリービューアイテムを削除
|*	DeleteTreeItem  p1
|*		p1 = HWND	: ツリービューのハンドル
|*		p2 = HWND	: アイテムハンドル
|*		返 = void
.************************************************/
#define global DeleteTreeItem(%1,%2) sendmsg %1, 0x1101, 0, %2	// TVM_DELETEITEM

#global

//######## サンプル・スクリプト ####################################################################
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
	pos 0, 0 : CreateTreeview ginfo(12) / 2, ginfo(13), 0x800000 | TVS_HASBUTTON | TVS_HASLINES | TVS_LINESATROOT
	hTree = objinfo(stat, 2)		// ツリービューのハンドル
	
	// ツリービューのイメージリストを設定
	SetTreeImageList hTree, hIml
	
	dim hRoot , 2
	dim hChild, 2
	
	// ツリービューのアイテム追加
	AddTreeItem         hTree, "親アイテム１", 0,  TVI_ROOT, TVI_SORT : hRoot(0)  = stat
		AddTreeItem     hTree, "子アイテム１", 1,  hRoot(0), TVI_SORT : hChild(0) = stat
			AddTreeItem hTree, "孫アイテム１", 2, hChild(0), TVI_SORT
		AddTreeItem     hTree, "子アイテム２", 1,  hRoot(0), TVI_SORT : hChild(1) = stat
			AddTreeItem hTree, "孫アイテム２", 2, hChild(1), TVI_SORT
	
	gsel 0
	oncmd gosub *OnNotify, 0x004E
	stop
	
*OnNotify
	dupptr nmhdr, lparam, 12			// NMHDR構造体
	
;	logmes "nmhdr = "+ nmhdr(0) +", "+ nmhdr(1) +", "+ nmhdr(2)
	
	if ( nmhdr(0) == hTree ) {
		if ( nmhdr(2) == TVN_SELCHANGED ) {
			dialog GetTreeItemString( hTree, GetTreeItemSelected( hTree ) )
		}
	}
	return
	
#endif

#endif
