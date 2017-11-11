// タブコントロール操作モジュール

#ifndef IG_MODULECLASS_TAB_CONTROL_AS
#define IG_MODULECLASS_TAB_CONTROL_AS

#include "mod_shiftArray.as"
#include "GetFontOfHSP.as"

// @ 項目がないときの挙動は自信ない。

// TabInt ( 関連数値 ) 機能を使う場合は、定義してください。
;	#define __USE_TABINT__

#ifdef  __USE_TABINT__
 #define global __USE_TABINT_ON__
#endif

//##############################################################################
//                Tab-Ctrl 定数
//##############################################################################
#define global WC_TABCONTROL "SysTabControl32"	// クラス名

#if 1
#define global TCM_FIRST				0x1300		// タブコントロールへ送るメッセージの開始
#define global TCM_GETIMAGELIST			0x1302		// イメージリストを取得
#define global TCM_SETIMAGELIST			0x1303		// イメージリストを設定
#define global TCM_GETITEMCOUNT			0x1304		// タブの数を取得
#define global TCM_GETITEM				0x1305		// タブの情報を取得
#define global TCM_SETITEM				0x1306		// タブの属性を設定
#define global TCM_INSERTITEM			0x1307		// 新しいタブ項目(つまみ)を挿入
#define global TCM_DELETEITEM			0x1308		// つまみを一つ削除
#define global TCM_DELETEALLITEMS		0x1309		// すべてのつまみを削除
#define global TCM_GETITEMRECT			0x130A		// (TIndex, 0) wParam のつまみ部分の RECT を取得
#define global TCM_GETCURSEL			0x130B		// 選択されている TabIndex を取得
#define global TCM_SETCURSEL			0x130C		// つまみを選択
#define global TCM_HITTEST				0x130D		// (0, varptr(TcHitTestInfo)) 指定座標にあるつまみの Index を取得
#define global TCM_SETITEMEXTRA			0x130E		// タブ項目に関連づけるデータのバイト数を設定
#define global TCM_ADJUSTRECT			0x1328		// ウィンドウ領域と表示領域を相互に変換
#define global TCM_SETITEMSIZE			0x1329		// つまみの大きさを変更
#define global TCM_REMOVEIMAGE			0x132A		// イメージリストを破棄
#define global TCM_SETPADDING			0x132B		// タブのアイコンとラベルの間に割り当てる領域を設定する
#define global TCM_GETROWCOUNT			0x132C		// タブの列数を取得する ( 複数行になっている時のみ )
#define global TCM_GETTOOLTIPS			0x132D		// ツールチップのハンドルを取得
#define global TCM_SETTOOLTIPS			0x132E		// ツールチップのハンドルを設定
#define global TCM_GETCURFOCUS			0x132F		// フォーカスのある TabIndex を返す
#define global TCM_SETCURFOCUS			0x1330		// w = TabIndex で、フォーカスをセットする
#define global TCM_SETMINTABWIDTH		0x1331		// つまみの最小幅を指定
#define global TCM_DESELECTALL			0x1332		// 選択項目なしにする (TCS_BUTTONS スタイルの時のみ)
#define global TCM_HIGHLIGHTITEM		0x1333		// wParam = TabIndex で、つまみをハイライト表示する
#define global TCM_SETEXTENDEDSTYLE		0x1334		// TCS_EX_ の拡張スタイルを設定する (SetWindowLong じゃ駄目)
#define global TCM_GETEXTENDEDSTYLE		0x1335		// TCS_EX_ の拡張スタイルを一括取得する

#define global TCM_SETUNICODEFORMAT 	0x2005		// UNICODE対応にするかどうかを設定する ( wparam にフラグ )
#define global TCM_GETUNICODEFORMAT 	0x2006		// UNICODE対応かどうかを取得する

// Ansi 版のメッセージ
#define global TCM_GETITEMA				TCM_GETITEM
#define global TCM_SETITEMA				TCM_SETITEM
#define global TCM_INSERTITEMA			TCM_INSERTITEM

// Unicode版のメッセージ
#define global TCM_GETITEMW				0x133C
#define global TCM_SETITEMW				0x133D
#define global TCM_INSERTITEMW			0x133E

// TabControlStyles
#define global TCS_TABS					0x0000		// デフォルト設定
#define global TCS_SCROLLOPPOSITE		0x0001		// 選択されていないタブ項目を反対側に移動する
#define global TCS_BOTTOM				0x0002		// 下につまみを置く
#define global TCS_RIGHT				0x0002		// 右に付ける ( TCS_VERTICAL とともに指定したとき )
#define global TCS_MULTISELECT			0x0004		// 複数選択を許可( Ctrl キーを押しながら選択 )
#define global TCS_FLATBUTTONS			0x0008		// フラットボタン( 選択しているつまみは凹む。平らなバーになる )
#define global TCS_FORCEICONLEFT		0x0010		// アイコンを左詰めにし、文章を中央に寄せる
#define global TCS_FORCELABELLEFT		0x0020		// アイコンと文章を左詰めにする
#define global TCS_HOTTRACK				0x0040		// つまみの文字列がホット状態になると、色が変わる
#define global TCS_VERTICAL				0x0080		// つまみを縦にする (TCS_RIGHT と併用する時に指定)
#define global TCS_BUTTONS				0x0100		// ボタン式

#define global TCS_SINGLELINE			0x0000		// 一行で表示する ( デフォルト )
#define global TCS_MULTILINE			0x0200		// 多くなると複数行で表示する

#define global TCS_RIGHTJUSTIFY			0x0000		// 左寄せ
#define global TCS_FIXEDWIDTH			0x0400		// つまみの横幅を均一にする
#define global TCS_RAGGEDRIGHT			0x0800		// タブ項目を右詰に表示
#define global TCS_FOCUSONBUTTONDOWN	0x1000		// クリックされたらフォーカスを得る (TCS_BUTTONS の時)
#define global TCS_OWNERDRAWFIXED		0x2000		// オーナー描画である
#define global TCS_TOOLTIPS				0x4000		// ツールチップスを作成する
#define global TCS_FOCUSNEVER			0x8000		// フォーカスを絶対に得ない

#define global TCS_EX_FLATSEPARATORS	0x0001		// つまみ間に区切り線がある
#define global TCS_EX_REGISTERDROP		0x0002		// ドロップされるとき、TCN_GETOBJECT を送る

// タブからの通知コード
#define global TCN_FIRST				(-550)		// 通知コードの開始
#define global TCN_KEYDOWN				(-550)		// キーが押された
#define global TCN_SELCHANGE			(-551)		// 選択状態が変わった
#define global TCN_SELCHANGING			(-552)		// 選択状態が変わろうとしている (まだ変わっていない)
#define global TCN_GETOBJECT			(-553)		// ドロップ対象のオブジェクトを求める
#define global TCN_FOCUSCHANGE			(-554)		// フォーカスが移った
#define global TCN_LAST					(-580)		// 通知コードの最後

// TCITEM 構造体に指定できる定数
#define global TCIF_TEXT				0x0001		// TCITEM.mask に指定 : pszText を有効にする
#define global TCIF_IMAGE				0x0002		// TCITEM.mask に指定 : iImage  を有効にする
#define global TCIF_RTLREADING			0x0004		// TCITEM.mask に指定 : 表示文字列を逆にする ( 一部の言語で使用 )
#define global TCIF_PARAM				0x0008		// TCITEM.mask に指定 : lParam  を有効にする
#define global TCIF_STATE				0x0010		// TCITEM.mask に指定 : dwState を有効にする ( version 4.70以降 )

#define global TCIS_BUTTONPRESSED		0x0001		// TCITEM.dwState に指定 : 選択状態である
#define global TCIS_HIGHLIGHTED			0x0002		// TCITEM.dwState に指定 : ハイライトされている

// HITTEST の値
#define global TCHT_NOWHERE				0x0001		// タブコントロールの上
#define global TCHT_ONITEMICON			0x0002		// つまみのアイコンの上
#define global TCHT_ONITEMLABEL			0x0004		// つまみのラベルの上
#define global TCHT_ONITEM				0x0006		// つまみの上 (TCHT_ONITEMICON | TCHT_ONITEMLABEL)

#endif

//##############################################################################
//                定義部 : MCTab
//##############################################################################

// TtoW …… TabIndex を入力したら、WindowID を返す(相対値)
// WtoT …… WindowID を入力したら、TabIndex を返す
#module MCTab mhTab, mwidPageTop, mcntTab, mfUsing, TtoW, WtoT, midxAct, mwIdAct, mbReversed, mhFont

//------------------------------------------------
// 真理値・成敗値
//------------------------------------------------
#define true    1
#define false   0
#define success 1
#define failure 0

//------------------------------------------------
// マクロ
//------------------------------------------------
#define nBitOfInt 32	// int型のビット数

#define redim ArrayExpand

#define ctype bturn(%1) ( 0xFFFFFFFF ^ (%1) )
#define ctype BITOFF(%1,%2=0) ( bturn(%2) & (%1) )
#define FlagSw(%1=flags,%2=0,%3=true) if (%3) { %1((%2) / nBitOfInt) |= 1 << ((%2) \ nBitOfInt) } else { %1((%2) / nBitOfInt) = BitOff(%1((%2) / nBitOfInt), 1 << ((%2) \ nBitOfInt)) }// On / Off 切り替えマクロ
#define ctype ff(%1=flags,%2=0) ((%1((%2) / nBitOfInt) && (1 << ((%2) \ nBitOfInt))) != 0)// フラグを見る
#define SetStyle(%1,%2=-16,%3=0,%4=0) SetWindowLong %1, %2, BitOff(GetWindowLong(%1,%2) | (%3), %4)
#define ctype MAKELONG(%1,%2) ( LOWORD(%1) | LOWORD(%2) << 16 )
#define ctype LOWORD(%1) ((%1) & 0xFFFF)
#define ctype HIWORD(%1) LOWORD((%1) >> 16)

#define ctype UseTab(%1=0) ff(mfUsing,%1)
#define fUseSw(%1,%2=1) FlagSw mfUsing, %1, %2

#define Reverse_idxTab(%1) if (mbReversed) { %1 = mcntTab - (%1) }
#define ctype rvI(%1) %1;(abs( (mcntTab * (mbReversed != 0)) - (%1) ))// リバースモードなら反転する

#define ResetTCITEM memset tcitem, 0, length(tcitem) * nBitOfInt

;#define RepeatUntilTrue(%1,%2,%3=0,%4=0,%5) %1=%2:repeat %3,%4:if(%5){%1=cnt:break}loop

//------------------------------------------------
// API 関数をローカルで呼び出す
//------------------------------------------------
#uselib "user32.dll"
#func   GetWindowRect@MCTab "GetWindowRect"  int,int
#func   GetClientRect@MCTab "GetClientRect"  int,int
#func   SetWindowLong@MCTab "SetWindowLongA" int,int,int
#cfunc  GetWindowLong@MCTab "GetWindowLongA" int,int
#func   SetParent@MCTab     "SetParent"      int,int
#func   MoveWindow@MCTab    "MoveWindow"     int,int,int,int,int,int

#uselib "gdi32.dll"
#cfunc  GetStockObject@MCTab		"GetStockObject"		int
#func   GetObject@MCTab				"GetObjectA"			int,int,int
#func   DeleteObject@MCTab			"DeleteObject"			int
#func   CreateFontIndirect@MCTab	"CreateFontIndirectA"	int

//------------------------------------------------
// モジュール初期化
//------------------------------------------------
#deffunc initialize@MCTab
	dim  rect, 4		// RECT 構造体
	dim  tcitem, 7		// TCITEM 構造体
	sdim pszText, 520	// 文字列バッファ
	return
	
//###############################################################################
//                メンバ関数
//###############################################################################

//**********************************************************
//        構築・解体
//**********************************************************
//------------------------------------------------
// 構築
// 
// @prm int cx, cy     : Tab-Ctrl の初期クライアント・サイズ
// @prm int widPageTop : ページに使用するウィンドウIDの先頭
// @prm int winStyle   : Tab-Ctrl の Window Style
// @prm int bReversed  : ( 未実装 ) つまみ位置を反転させるか
// @return             : Tab-Ctrl ハンドル
//------------------------------------------------
#define global tab_new(%1,%2,%3,%4=1,%5=0,%6=0) newmod %1, MCTab@, %2, %3, %4, %5, %6

#modinit int cx, int cy, int widPageTop, int winStyle, int bReversed,  local curpos
	
	curpos = ginfo_cx, ginfo_cy
	
	// Tab-Ctrl 生成
	winobj WC_TABCONTROL, "", , 0x52000000 | winStyle, ginfo(20) * 2, ginfo(21) * 2
	mhTab = objinfo(stat, 2)
	
	sendmsg    mhTab, 0x0030, GetStockObject(17)	// デフォルトのフォントに設定する
	MoveWindow mhTab, curpos(0), curpos(1), cx, cy
	
	// メンバ変数の初期化
	mwidPageTop = widPageTop	// 使用するウィンドウ ID の先頭
	dim  mfUsing, 3				// Window の使用状況を表すフラグ
	dim  TtoW, 5				// winID を返す
	dim  WtoT, 5				// index を返す
	dim mhFont					// フォントハンドル (ChangeTabStrFont 使用時のみ)
 #ifdef __USE_TABINT_ON__
	dim  LPRM, 5				// 関連 int ( LPARAM 値 )
 #endif
	
;	mbReversed = ( bReversed != 0 )		// 反転モードか
	
	return mhTab
	
//----------------------------------------------------------
// 解体
//----------------------------------------------------------
#define global tab_delete delmod
#modterm
	if ( mhFont ) { DeleteObject mhFont : mhFont = 0 }	// フォントハンドルを解放する
	return
	
//**********************************************************
//        項目の挿入と除去
//**********************************************************
//------------------------------------------------
// タブつまみの挿入
// 
// @prm modvar self  : MCTab
// @prm str    sItem : タブつまみの文字列
// @prm int    iTab  : 挿入位置
// @return           : 挿入された位置, or 負数
//------------------------------------------------
#modfunc tab_insert str sItem, int iTab,  local iIns, local useId
	
	// 自動修正
	if ( iTab < 0 ) {
		iIns = mcntTab ;* ( mbReversed == 0 )
	} else {
		iIns = rvI( limit(iTab, 0, mcntTab + 1) )
	}
	
	// テーブルの修正
	ArrayInsert TtoW, iIns		// 要素を配列の途中に挿入する
	
 #ifdef __USE_TABINT_ON__
	ArrayInsert LPRM, iIns
 #endif
	
	// アイテムを追加する
	pszText = sItem									// タブ文字列を格納
	tcitem  = 1, 0, 0, varptr(pszText)				// TCIF_TEXT  ( pszText のみ有効 )
	sendmsg mhTab, 0x1307, iIns, varptr(tcitem)		// TCM_INSERTITEM ( 新規アイテムを挿入 )
	iIns = stat										// 挿入位置 or (x < 0)
	if ( iIns < 0 ) { return -1 }					// エラー
	
	// 使用する winID を選び出す
	useId = mcntTab						// デフォルト設定
	repeat  mcntTab
		if ( UseTab(cnt) == false ) {	// 未使用の PageWindow
			useId = cnt
			break
		}
	loop
	
	// テーブルを修正
	WtoT( useId ) = iIns			// TabIndex
	TtoW( iIns  ) = useId			// WindowID
	fUseSw			useId, true		// 使用中にする
	
	// サイズを決める
	tab_getFittingPageRect thismod, rect
	
	// ウィンドウ作成 ( 一応最大サイズで作る )
	bgscr useID + mwidPageTop, ginfo(20), ginfo(21), 2, rect(0), rect(1), rect(2) - rect(0), rect(3) - rect(1)
	SetStyle  hwnd, -16, 0x40000000, 0x80000000	// WS_CHILD を付加し、WS_POPUP を除去する
	SetParent hwnd, mhTab						// 子ウィンドウにする
	
	mcntTab ++				// 使用しているタブの数
	
	return iIns
	
#define global tab_add(%1,%2) tab_insert %1, %2, -1

//------------------------------------------------
// タブつまみの除去
//------------------------------------------------
#modfunc tab_remove int iTab, int bNoActive
	if ( ( 0 <= iTab && iTab <= (mcntTab - 1) ) == false ) {
		return
	}
	
	sendmsg mhTab, 0x1308, iTab					// TCM_DELETETAB (削除)
	fUseSw tab_idxToWId( thismod, iTab ), false	// ウィンドウを未使用とする
	mcntTab --
	
	WtoT( tab_idxToWId(thismod, iTab) ) = -1
	ArrayRemove TtoW, iTab
	
 #ifdef __USE_TABINT_ON__
	ArrayRemove LPRM, iTab
 #endif
	
	if ( bNoActive == false ) {
		if ( midxAct >= iTab ) {
			gsel mwIdAct + mwidPageTop, -1
			midxAct = -1
			mwIdAct = 0
			
			if ( mcntTab > 0 ) {
				tab_show thismod, limit( iTab - 1, 0, mcntTab )
			}
		}
	}
	
	return
	
//**********************************************************
//        項目の選択
//**********************************************************
//------------------------------------------------
// 選択状態を画面にあわせる
// 
// @return: active index
//------------------------------------------------
#modfunc tab_showActive
	
	if ( mcntTab == 0 ) {
		midxAct = -1
		mwIdAct = -1
		return midxAct
	}
	
	gsel mwIdAct + mwidPageTop, -1				// 元のウィンドウを隠す
	
	sendmsg mhTab, 0x130B, 0, 0					// TCM_GETCURSEL (選択されているインデックスを取得)
	midxAct = stat								// 現在の TabIndex
	mwIdAct = tab_idxToWId( thismod, midxAct )	// midxAct の wid
	tab_adjustPageRect      thismod, midxAct	// サイズを調整
	gsel mwIdAct + mwidPageTop, 1				// 公開
	
	return midxAct
	
//------------------------------------------------
// タブ項目を選択する
// 
// @result: active Window ID (relative) or 負数(failure)
//------------------------------------------------
#modfunc tab_show int iTab,  local widAct_old
	if ( midxAct == iTab ) { return -1 }			// 既に active ⇒ なにもしない
	if ( (0 <= iTab && iTab <= mcntTab - 1) == false ) { return -1 }	// iTab が異常値
	
	widAct_old = mwIdAct
	midxAct    = limit( iTab, 0, mcntTab - 1 )	
	mwIdAct    = tab_idxToWId( thismod, midxAct )
	
;	gsel mwIdAct + mwIdPageTop, 1					// 切り替える
	sendmsg mhTab, 0x130C,      midxAct,  0			// TCM_SETCURSEL (タブを選択)
	tab_adjustPageRect thismod, midxAct				// PageWindow のサイズ調整
	
	// 現在のタブを隠し、新しい選択項目を公開
	gsel widAct_old + mwidPageTop, -1
	gsel mwIdAct    + mwidPageTop,  1
	
	return mwIdAct
	
//**********************************************************
//        項目操作
//**********************************************************
//------------------------------------------------
// タブつまみの文字列を設定する
//------------------------------------------------
#modfunc tab_setItemString int iTab, str string
	
	pszText = string
	tcitem  = 1, 0, 0, varptr(pszText)
	sendmsg mhTab, 0x1306, iTab, varptr(tcitem)		// TCM_SETITEM
	
	return stat
	
//------------------------------------------------
// タブつまみの文字列を取得する
//------------------------------------------------
#define global ctype Tab_getItemString(%1,%2=0,%3=511) tab_getItemString_(%1,%2,%3)
#modcfunc tab_getItemString_ int iTab, int bufsize
	
	memexpand pszText, bufsize + 1					// 必要なだけ拡張する
	tcitem = 1, 0, 0, varptr(pszText), bufsize		// ポインタ, バッファサイズ
	sendmsg mhTab, 0x1305, iTab, varptr(tcitem)		// TCM_GETITEM
	
	return pszText
	
//------------------------------------------------
// PageWindow の大きさを調整する
//------------------------------------------------
#modfunc tab_adjustPageRect int iTab,  local wid_actwin
	wid_actwin = ginfo(3)
	
	gsel tab_idxToWId( thismod, iTab ) + mwidPageTop	// hwnd にハンドルを格納させるため
	
	Tab_getFittingPageRect thismod, rect
	MoveWindow hwnd, rect(0), rect(1), rect(2) - rect(0), rect(3) - rect(1), true
	
	gsel wid_actwin
	return
	
//------------------------------------------------
// PageWindow の適切な大きさを取得する
//------------------------------------------------
#modfunc tab_getFittingPageRect array rc,  local size
	dim rc, 4
	
	size = tab_getSize(thismod)
	rc   = 0, 0, LOWORD(size), HIWORD(size)
	
	sendmsg mhTab, 0x1328, 0, varptr(rc)	// TCM_ADJUSTRECT ( TabRect と PageRect の相互変換 )
	return
	
//------------------------------------------------
// Tab-Ctrl の SIZE を取得する
// 
// @result: (int) SIZE
//------------------------------------------------
#modcfunc tab_getSize
	GetClientRect mhTab, varptr(rect)
	return MakeLong( rect(2), rect(3) )
	
//**********************************************************
//        イメージリスト系
//**********************************************************
//------------------------------------------------
// イメージリストをタブに関連づける
//------------------------------------------------
#modfunc tab_setImageList int hImageList
	sendmsg mhTab, 0x1303, 0, hImageList		// TCM_SETIMAGELIST (イメージリストを割り付ける)
	return stat
	
//------------------------------------------------
// イメージリストの取得
//------------------------------------------------
#modcfunc tab_getImageList
	sendmsg mhTab, 0x1302, 0, 0		// TCM_GETIMAGELIST (hImageList を取得)
	return stat
	
//------------------------------------------------
// タブつまみにイメージを付ける
//------------------------------------------------
#modfunc tab_setImage int iTab, int hImg
	tcitem(0) = 2, 0, 0, 0, 0, hImg				// TCIF_IMAGE
	sendmsg mhTab, 0x1306, iTab, varptr(tcitem)	// TCM_SETITEM
	return (stat != 0)
	
//------------------------------------------------
// タブからイメージを除去する
//------------------------------------------------
#modfunc tab_removeImage int iTab
	tab_setImage thismod, iTab, -1
	return stat
	
//**********************************************************
//        タブのフォント
//**********************************************************
//------------------------------------------------
// タブのフォントを設定する
// 
// @ タブつまみの文字列のフォントとして使われる。
//------------------------------------------------
#modfunc tab_font str fontFamily, int fontPt, int fontStyle

	// 解放
	if ( mhFont ) { DeleteObject mhFont }
	
	// フォント作成
	mhFont = CreateFontByHSP( fontFamily, fontPt, fontStyle )
	sendmsg mhTab, 0x0030, mhFont, true
	
	// サイズを適正にする
	repeat mcntTab
		tab_adjustPageRect thismod, cnt
	loop
	
	return
	
//**********************************************************
//        その他の動作
//**********************************************************
//----------------------------------------------------------
// 指定座標に何番目のつまみがあるか
// 
// @ 座標は絶対座標
//----------------------------------------------------------
#modcfunc tab_getIdxFromPt int px, int py,  local tabrect, local cntTabs, local ptMouse, local idx
	
	dim tabrect, 4
	dim ptMouse, 2
	idx = -1
	
	// Tab-Ctrl の WindowRect を取得
	GetWindowRect mhTab, varptr(tabrect)
	
	pt = px - tabrect(0), py - tabrect(1)		// 相対値にする
	
	repeat mcntTab
		// TCM_GETITEMRECT ( wparam のつまみの RECT を lparam(RECT ptr) に格納 )
		sendmsg mhTab, 0x130A, cnt, varptr(rect)
		
		// マウス位置がつまみの中ならＯＫ
		if ( (rect(0) <= pt(0) && pt(0) <= rect(2)) && (rect(1) <= pt(1) && pt(1) <= rect(3)) ) {
			idx = cnt
			break
		}
	loop
	
	return idx
	
//----------------------------------------------------------
// タブつまみの中の空白(padding)を設定する
// 
// @ TCM_SETPADDING
//----------------------------------------------------------
#modfunc tab_setTabPadding int cx, int cy
	sendmsg mhTab, 0x132B, , MakeLong(cx, cy)
	return
	
//----------------------------------------------------------
// タブつまみの最低幅を設定する
// 
// @ TCM_SETMINTABWIDTH
//----------------------------------------------------------
#modfunc tab_setMinWidth int nMinWidth
	sendmsg mhTab, 0x1331, , nMinWidth
	return
	
//**********************************************************
//        関連 int 系
//**********************************************************
//----------------------------------------------------------
// 関連 int の設定
//----------------------------------------------------------
#modfunc tab_setInt int iTab, int value
 #ifdef __USE_TABINT_ON__
	LPRM( iTab ) = value
 #endif
	return
	
//----------------------------------------------------------
// 関連 int の取得
//----------------------------------------------------------
#modcfunc tab_getInt int iTab
 #ifdef __USE_TABINT_ON__
	return LPRM( iTab )
 #else
	return 0	// 一応 0 を返す
 #endif
	
//**********************************************************
//        取得系
//**********************************************************
//------------------------------------------------
// Tab-Ctrl ハンドル
//------------------------------------------------
#modcfunc tab_hwnd
	return mhTab
	
//------------------------------------------------
// 項目数
//------------------------------------------------
#modcfunc tab_count
	return mcntTab
	
#define global tab_size tab_count

//------------------------------------------------
// Active-Item の index
//------------------------------------------------
#modcfunc tab_idxAct
	return midxAct
	
//------------------------------------------------
// Active-Item の Window ID
//------------------------------------------------
#modcfunc tab_widAct
	return mwIdAct
	
//------------------------------------------------
// Tab index <-> 相対 WindowID の相互変換
//------------------------------------------------
#define global ItoW tab_idxToWId
#define global WtoI tab_widToIdx

#modcfunc tab_idxToWId int iTab
	if ( mcntTab == 0 ) { return 0 }
	return TtoW( limit( iTab, 0, mcntTab - 1 ) )
	
#modcfunc tab_widToIdx int widTab
	if ( mcntTab == 0 ) { return 0 }
	return WtoT( limit( widTab, 0, mcntTab - 1 ) )
	
//------------------------------------------------
// つまみ位置が反転しているかどうか
//------------------------------------------------
#modcfunc tab_isReversed
	return mbReversed != 0
	
//**********************************************************
//        static 下請け
//**********************************************************
//------------------------------------------------
// 内部処理用命令
// 
// @ int 型一次元配列を拡張
//------------------------------------------------
#deffunc ArrayExpand@MCTab array arr, int size,  local temp
	if ( length(arr) >= size ) { return }	// 増えない場合は無視
	repeat size - length(arr), length(arr)
		arr(cnt) = 0
	loop
;	dim    temp, length(arr)
;	memcpy temp, arr, length(arr) * 4		// コピー
;	dim    arr, size
;	memcpy arr, temp, length(temp) * 4		// 戻す
	return
	
//**********************************************************
//        Tabmod との互換
//**********************************************************
#define global CreateTab tab_new
#define global InsertTab tab_insert
#define global DeleteTab tab_remove

#define global SetTabStrItem tab_setItemString
#define global GetTabStrItem tab_getItemString

#define global AdjustWindowRect tab_adjustPageRect
#define global GetTabPageRect(%1,%2) tab_getFittingPageRect

#define global ChangeTab tab_showActive
#define global ShowTab   tab_show

#define global SetTabImageList tab_setImageList
#define global GetTabImageList tab_getImageList
#define global SetTabImage     tab_setImage

#define global ChangeTabStrFont tab_font

#define global NumberOfTabInPoint tab_getIdxFromPt

#define global SetTabPadding  tab_setPadding
#define global SetMinTabWidth tab_setMinWidth

#define global SetTabInt tab_setInt
#define global TabInt tab_getInt

#define global GetTabHandle tab_hwnd
#define global GetTabNum    tab_count

#define global ActTabIndex tab_idxAct
#define global ActTabWinID tab_widAct

#define global IsReverse tab_isReversed

#global

	initialize@MCTab

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 0

	#define __USE_BITMAP__

#ifdef __USE_BITMAP__
 #include "BitmapMaker.as"
#endif

#const global IDW_TABTOP 10

// 取得用マクロ
#define tIndex ActTabIndex(mTab)
#define actwin ActTabWinID(mTab)

#uselib "user32.dll"
#func   GetWindowRect "GetWindowRect" int,int

#ifdef __USE_BITMAP__	
	// イメージリスト作成(しなくても良い) (16×16×4, 24bit, マスクあり)
	CreateImageList 16, 16, 25, 4 : hIml = stat		// イメージリストのハンドル
	buffer 2, , , 0 : picload "treeicon.bmp"		// ビットマップの読み込み
	AddImageList hIml, 0, 0, 16 * 4, 16, 0xF0CAA6	// イメージリストにイメージを追加
#endif
	
	screen 0, 400, 300
	syscolor 15 : boxf : color
	title "Tab Sample"
	
//	タブコントロールを設置する。
//	p4 は bgscr 命令で作成するウィンドウID の先頭になります。
//	例えば、下のように [10(IDW_TABTOP)] でタブ項目が4個あると、
//	{10, 11, 12, 13} のウィンドウを使用します。
//	また、[3] でタブの項目が 8個あると、{3, 4, 5, 6, 7, 8, 9, 10} が使われます。
//	別で使用するウィンドウID値と被らないよう注意してください。
	pos 50, 50
	tab_new mTab, 300, 200, IDW_TABTOP, 0x4000	// TCS_TOOLTIPS
	hTab = stat									// Tab-Ctrl のハンドルを取得
	
	// フォントが変更出来ます。必須ではありません。
	// font 命令と同じ感覚で使用できます。
	tab_font mTab, "ＭＳ 明朝", 15, 4			// 下線はアクティブなタブにのみ付く様子
	
#ifdef __USE_BITMAP__
	tab_setImageList mTab, hIml					// イメージリストを関連づける
#endif
	
	// アイテムの挿入 ( モジュール変数, つまみの文字列, 挿入位置 )
	// 挿入位置を省略すると、一番後ろ( 通常は右 )に追加します。
	
	tab_add mTab, "AAA"
//		スクリーン上にオブジェクトを置く感覚で処理を書きます。
//		カレントウィンドウはタブアイテムに使用されたウィンドウになっています。
		pos 50, 50 : mes "A"
	
	tab_add mTab, "BBB"
		pos 50, 50 : mes "B"
	
	tab_add mTab, "CCC"
		pos 50, 50 : mes "C"
	
	tab_add mTab, "DDD"
		pos 50, 50 : mes "D"
	
;	tab_remove mTab, 1			// TabIndex の 1 ("BBB") を除去
	
;	tab_insert mTab, "EEE", 0	// 左端(0) に 0 を挿入
;		pos 50, 50 : mes "E"
		
 #ifdef __USE_BITMAP__
	// イメージを付ける。ここでやらなくてもいいのに……
	repeat 4
		tab_setImage mTab, cnt, cnt
	loop
 #endif
	
	// タブの項目追加が終わったら、タブ内に貼り付けた bgscr 命令が非表示状態になっているので、
	// 表示されるよう gsel 命令を指定してください。
	// tab_new 命令で指定した ウィンドウID の初期値と同じ値を指定します。
	gsel IDW_TABTOP, 1
	
	// ウィンドウID 0 に描画先を戻します。
	gsel
	
	// タブ項目切り替え処理時のメッセージ
	oncmd gosub *OnNotify, 0x004E		// WM_NOTIFY
	
	// タブの挿入・除去テスト用 ( これは無くても良い )
	gsel 0
	objsize 75, 28
	pos  5, 5 : button gosub "Insert !", *TabInsertEdit
	pos 85, 5 : button gosub "Remove !", *TabRemove
	
	screen 1, 230, 160, ( 2 | 4 | 8 )
	syscolor 15 : boxf : color
	title "InsertTab - Edit"
	sdim String   , 64, 2
	sdim InsertPos, 64
	bCheck = 1
	pos  10,  8 : mes "つまみ   : "
	pos 100,  5 : input String(0), 100, 25, 3
	pos  10, 38 : mes "内容     : "
	pos 100, 35 : input String(1), 100, 25, 12
	pos  10, 68 : mes "挿入位置 : "
	pos 100, 65 : input InsertPos, 60, 25, 2
	
	objsize 160, 25
	pos  10, 95 : chkbox "挿入後アクティブにする", bCheck
	
	objsize 80, 28
	pos 120, 125 : button gosub "OK", *TabInsert
	
	gsel 0
	onexit goto *exit
	stop
	
// タブ項目切り替え処理部分
// 重要！！
*OnNotify
	dupptr nmhdr, lparam, 12	// NMHDR 構造体
	
;	logmes "nmhdr = "+ nmhdr(0) +", "+ nmhdr(1) +", "+ nmhdr(2)
	
	if ( nmhdr(0) == hTab ) {	// タブコントロールからの通知 
		
		// 選択アイテムの変更
		if ( nmhdr(2) == -551 ) {
			tab_showActive mTab		// 選択されているアイテムに切り替える。ActiveTabIndex を返す
			
			// 変更の結果を出力 ( actIndex, つまみ文字列, windowID )
			logmes "tab_showActive 「"+ tab_getItemString(mTab, tIndex) +"」 { ( Index, WinID ) == ( "+ tIndex +", "+ tab_idxToWId(mTab, tIndex) +" ) }"
			
			gsel 0	// メインを操作先に戻す
			
		// ショートカットメニュー
		} else : if ( nmhdr(2) == -5 ) {
			// ポップアップさせる
			n = tab_getIdxFromPt( mTab, ginfo(0), ginfo(1) )
			if ( n >= 0 ) {
				logmes "ShortMenu Popup! [No."+ n +"]"
			}
		}
		
	}
	return
	
//	不要な部分
*TabInsertEdit
	gsel 1, 1
	objsel 0
	return
	
// タブ項目の挿入
*TabInsert
	// 挿入位置を決定 (空なら -1(最後) にする)
	iIns = int(InsertPos) - (InsertPos == "")
	
	tab_insert mTab, String(0), iIns
	iIns = stat
	if ( iIns < 0 ) { return }		// 失敗
	
	pos 50, 50 : mes String(1)		// 内部に書き込む
	
	// チェックされていたらアクティブにする
	if ( bCheck ) {
		tab_show mTab, iIns
	}
	
	gsel 1, -1
	gsel 0, 1
	return
	
// タブ項目の除去
*TabRemove
	tab_remove mTab, tIndex		// アクティブなタブを削除する
	tab_show   mTab, tIndex		// 前のタブをアクティブにする
	gsel 0
	return stat
	
// 終了時の処理 ( 不要 )
*exit
	if ( wparam != 0 ) {
		gsel wparam, -1
		stop
	}
	end
	
#endif	// サンプル

#endif	// モジュール全体
