// タブコントロール操作モジュール

#ifndef __TABCONTROL_MODULE__
#define __TABCONTROL_MODULE__

#module
// 内部処理用命令 ( int 型一次元配列を拡張 )
#deffunc ArrayExpand array p1, int p2, local temp
	// 配列のコピー (一次元限定)
	if ( length(p1) >= p2 ) { return }	// 増えない場合は無視
/*
	// 型無視バージョン
	dimtype temp, vartype(p1), length(p1)
		repeat length(p1)   : temp(cnt) = p1(cnt) : loop
	dimtype p1, vartype(temp), p2
		repeat length(temp) : p1(cnt) = temp(cnt) : loop
/*/
	// int 固定バージョン
	dim    temp, length(p1)
	memcpy temp, p1, length(p1) * 4		// コピー
	dim    p1, p2
	memcpy p1, temp, length(temp) * 4	// 戻す
;*/
	return
#global

// TabInt ( 関連数値 ) 機能を使う場合は、定義してください。
;	#define __USE_TABINT__

#ifdef  __USE_TABINT__
#define global __USE_TABINT_ON__
#endif

// フォント取得モジュール
#module
#uselib "gdi32.dll"
#func GetObject "GetObjectA" int,int,int
#deffunc GetStructLogfont array _logfont, local bmscr
	dim    _logfont, 15
	mref      bmscr, 67
	GetObject bmscr(38), 60, varptr(_logfont)	// LOGFONT 構造体を取得する
	return
	
#defcfunc GetFontName local sRet
	sdim   sRet, 64
	GetStructLogfont logfont 
	getstr sRet,     logfont(7)
	return sRet
	
#defcfunc GetFontSize
	GetStructLogfont logfont 
	return ( logfont(0) ^ 0xFFFFFFFF ) + 1
#defcfunc GetFontStyle
	GetStructLogfont logfont
 #if 0
	style |= (  logfont(4) >= 700             ) << 0	// Bold
	style |= ( (logfont(5) & 0x000000FF) != 0 ) << 1	// Italic
	style |= ( (logfont(5) & 0x0000FF00) != 0 ) << 2	// UnderLine
	style |= ( (logfont(5) & 0x00FF0000) != 0 ) << 3	// StrikeLine
	style |= ( (logfont(6) & 0x00040000) != 0 ) << 4	// AntiAlias
	return style
 #else
	return ((logfont(4) >= 700)) | (((logfont(5) & 0x000000FF) != 0) << 1) | (((logfont(5) & 0x0000FF00) != 0) << 2) | (((logfont(5) & 0x00FF0000) != 0) << 3) | (((logfont(6) & 0x00040000) != 0) << 4)
 #endif
#global

#define global RepeatUntilTrue(%1,%2,%3=0,%4=0,%5) %1=%2:repeat %3,%4:if(%5){%1=cnt:break}loop

//##################################################################################################
#define global WC_TABCONTROL	"SysTabControl32"	// クラス名

// 以降、モジュール内では使いません
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
#define global TCS_TABS					0x0000		// デフォルト設定であることを明示的に示す
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
#define global TCIF_TEXT               0x0001		// TCITEM.mask に指定 : pszText を有効にする
#define global TCIF_IMAGE              0x0002		// TCITEM.mask に指定 : iImage  を有効にする
#define global TCIF_RTLREADING         0x0004		// TCITEM.mask に指定 : 表示文字列を逆にする ( 一部の言語で使用 )
#define global TCIF_PARAM              0x0008		// TCITEM.mask に指定 : lParam  を有効にする
#define global TCIF_STATE              0x0010		// TCITEM.mask に指定 : dwState を有効にする ( version 4.70以降 )

#define global TCIS_BUTTONPRESSED      0x0001		// TCITEM.dwState に指定 : 選択状態である
#define global TCIS_HIGHLIGHTED        0x0002		// TCITEM.dwState に指定 : ハイライトされている

// HITTEST の値
#define global TCHT_NOWHERE				0x0001		// タブコントロールの上
#define global TCHT_ONITEMICON			0x0002		// つまみのアイコンの上
#define global TCHT_ONITEMLABEL			0x0004		// つまみのラベルの上
#define global TCHT_ONITEM				0x0006		// つまみの上 (TCHT_ONITEMICON | TCHT_ONITEMLABEL)

#endif

/**********************************************************************************************************************/

// TtoW …… TabIndex を入力したら、WindowID を返す(相対値)
// WtoT …… WindowID を入力したら、TabIndex を返す
#module Tabmod hTab, TabID, TabNum, fUsing, TtoW, WtoT, Index, wID, fReverse, hFont

#define true  1
#define false 0
#define nBitOfInt 32	// int型のビット数
#define mv modvar Tabmod@

// マクロ
#define ctype BitOff(%1,%2=0) ( ((%1) & (%2) ^ (%1)) )
#define FlagSw(%1=flags,%2=0,%3=true) if(%3){ %1((%2) /nBitOfInt) |= 1 << ((%2) \ nBitOfInt) } else { %1((%2)/nBitOfInt) = BitOff(%1((%2) / nBitOfInt), 1 << ((%2) \ nBitOfInt)) }// On / Off 切り替えマクロ
#define ctype ff(%1=flags,%2=0) ((%1((%2) / nBitOfInt) && (1 << ((%2) \ nBitOfInt))) != 0)// フラグを見る
#define SetStyle(%1,%2=-16,%3=0,%4=0) SetWindowLong %1,%2,BitOff(GetWindowLong(%1,%2) | (%3), %4)
#define ctype MakeLong(%1,%2) ((((%1) & 0xFFFF) << 16) | ((%2) & 0xFFFF))

#define ctype UseTab(%1=0) ff(fUsing,%1)
#define fUseSw(%1,%2=1) FlagSw fUsing,%1,%2
#define ArrayDel(%1,%2,%3=0,%4=4) memcpy %1,%1,(length(%2) - (%3) -1)*(%4),(%3)*(%4),((%3)+1)*(%4):memset %1,0,%4,((%3)*(%4))+((length(%2)-(%3)-1)*(%4))
#define ArrayIns(%1,%2=0,%3=4)    memcpy %1,%1,(length(%1) - (%2) -1)*(%3),((%2)+1)*(%3),(%2)*(%3)

#define Reverse_TabIndex(%1) if(fReverse){%1=TabNum-(%1)}
#define ctype rvI(%1) %1;(abs( (TabNum*(fReverse!=0)) - (%1) ))// リバースモードなら反転する

#define ResetTCITEM memset tcitem, 0, length(tcitem) * nBitOfInt

// API 関数をローカルで呼び出す
#uselib "user32.dll"
#func   GetWindowRect "GetWindowRect"  int,int
#func   GetClientRect "GetClientRect"  int,int
#func   SetWindowLong "SetWindowLongA" int,int,int
#cfunc  GetWindowLong "GetWindowLongA" int,int
#func   SetParent     "SetParent"      int,int
#func   MoveWindow    "MoveWindow"     int,int,int,int,int,int

#uselib "gdi32.dll"
#cfunc  GetStockObject		"GetStockObject"		int
#func   GetObject			"GetObjectA"			int,int,int
#func   DeleteObject		"DeleteObject"			int
#func   CreateFontIndirect	"CreateFontIndirectA"	int

#uselib "comctl32.dll"
#func   InitCommonControls "InitCommonControls"

#deffunc _Tabmod_init
	dim  rect, 4		// RECT 構造体
	dim  tcitem, 7		// TCITEM 構造体
	sdim pszText, 520	// 文字列バッファ
	
	InitCommonControls	// comctl を初期化
	return
	
//######## タブ内ウィンドウのサイズを調整する ######################################################
#modfunc AdjustWindowRect int p2, local _id_actwin	// TabIndex を渡す
	_id_actwin = ginfo(3)
	gsel TtoW( p2 ) + TabID, 0		// hwnd にハンドルを格納させるため
	
	GetClientRect hTab,          varptr(rect)	// TabControl の rect を求める
	sendmsg       hTab, 0x1328,, varptr(rect)	// TCM_ADJUSTRECT ( TabRect と bgscrRect の相互変換 )
	MoveWindow    hwnd, rect(0), rect(1), rect(2) - rect(0), rect(3) - rect(1), true
	gsel _id_actwin, 0
	return varptr(rect)
	
//######## タブつまみの文字列を操作する関数 ########################################################
#modfunc SetTabStrItem int p2, str p3
	
	pszText = p3
	tcitem  = 1, 0, 0, varptr(pszText)
	sendmsg hTab, 0x1306, p2, varptr(tcitem)	// TCM_SETITEM (設定)
	
	return (stat)
	
#define global ctype GetTabStrItem(%1,%2=0,%3=511) _GetTabStrItem(%1,%2,%3)
#defcfunc _GetTabStrItem mv, int p2, int p3
	
	memexpand pszText, p3 + 1					// 必要なだけ拡張する
	tcitem = 1, 0, 0, varptr(pszText), p3		// ポインタ, バッファ数
	sendmsg hTab, 0x1305, p2, varptr(tcitem)	// TCM_GETITEM (取得)
	
	return pszText
	
//######## タブコントロールの新規作成 ##############################################################
#define global CreateTab(%1,%2,%3,%4=1,%5=0,%6=0) newmod %1,Tabmod@,%2,%3,%4,%5,%6
#modinit int p2, int p3, int p4, int p5, int p6, local nRet
	// コントロール生成
	winobj WC_TABCONTROL, "", , 0x52000000 | p5, p2, p3
	
			hTab = objinfo(stat, 2)				// ハンドルを取得
	sendmsg hTab, 0x0030, GetStockObject(17)	// WM_SETFONT (デフォルトのフォント)
	
	TabID = p4				// 使用するウィンドウ ID の先頭
	dim  fUsing, 3			// Window の使用状況を表すフラグ
	dim  TtoW, 5			// winID を返す
	dim  WtoT, 5			// index を返す
	dim hFont				// フォントハンドル (ChangeTabStrFont 使用時のみ)
 #ifdef __USE_TABINT_ON__
	dim  LPRM, 5			// 関連 int ( LPARAM 値 )
 #endif
	
;	fReverse = (p6 != 0)	// リバース・フラグ
	
	return hTab
	
//#### アイテムの追加処理 ######################################################
#define global InsertTab(%1,%2,%3=-1) _InsertTab %1,%2,%3
#modfunc _InsertTab str p2, int p3, local InsPos, local useID
	
	// 自動修正
	if ( p3 < 0 ) {
		InsPos = TabNum ;* ( fReverse == 0 )
	} else {
		InsPos = rvI( limit(p3, 0, TabNum + 1) )
	}
	
	// テーブルの修正
	ArrayExpand WtoT, TabNum + 1		// 配列を、タブの数ぶんにまで拡張 ( + 1 は保険 )
	ArrayExpand	TtoW, TabNum + 1		// 同上
	ArrayIns    TtoW, InsPos			// 要素を配列の途中に挿入する
	
 #ifdef __USE_TABINT_ON__
	ArrayExpand LPRM, TabNum + 1
	ArrayIns    LPRM, InsPos
 #endif
	
	// アイテムを追加する
	pszText  = p2									// タブ文字列を格納
	tcitem   = 1, 0, 0, varptr( pszText )			// TCIF_TEXT  ( pszText のみ有効 )
	sendmsg hTab, 0x1307, InsPos, varptr(tcitem)	// TCM_INSERTITEM ( 新規アイテムを挿入 )
	InsPos = stat									// 挿入位置 or -1
	if ( InsPos < 0 ) { return -1 }					// エラー
	
	// 使用する winID を選び出す
	useID = TabNum						// デフォルト設定
	repeat  TabNum
		if ( UseTab(cnt) == false ) {	// 未使用の タブ用window がある
			useID = cnt
			break
		}
	loop
	
	// テーブルを修正
	WtoT( useID  ) = InsPos			// Index
	TtoW( InsPos ) = useID			// WindowID
	fUseSw			 useID, true	// 使用中にする
	
	// サイズを決める
	GetClientRect hTab,          varptr(rect)	// TabControl の Rect を求める
	sendmsg       hTab, 0x1328,, varptr(rect)	// TCM_ADJUSTRECT ( TabRect と bgscrRect の相互変換 )
	
	// ウィンドウ作成 ( 一応最大サイズで作る )
	bgscr useID + TabID, ginfo(20), ginfo(21), 2, rect(0), rect(1), rect(2) - rect(0), rect(3) - rect(1)
	SetStyle  hwnd, -16, 0x40000000, 0x80000000	// WS_CHILD を付加し、WS_POPUP を除去する
	SetParent hwnd, hTab						// 子にする
	
	TabNum ++				// 使用しているタブの数
	
	return ( InsPos )
	
//#### 選択状態に画面をあわせる処理 ############################################
#modfunc ChangeTab
	
	gsel wID + TabID, -1			// 元のウィンドウを隠す
	
	sendmsg hTab, 0x130B, 0, 0		// TCM_GETCURSEL (選択されているインデックスを取得)
	Index = stat					// 現在のインデックスに修正
	AdjustWindowRect thismod, Index	// サイズを調整
	wID = TtoW( Index )				// Index から WindowID を求め、wID を最新に保つ
	gsel wID + TabID, 1				// 公開
	
	return Index
	
// タブを選択する
#modfunc ShowTab int p2		// TabIndex
	if (Index == p2) { return }			// 変更する必要はない
	
	Index = limit(p2, 0, TabNum)		// 変更
	
	gsel TtoW( Index ) +  TabID,  1		// 切り替える
	sendmsg hTab, 0x130C,     Index, 0	// TCM_SETCURSEL (タブを選択)
	AdjustWindowRect thismod, Index		// サイズ調整
	gsel wID            + TabID, -1		// 現在のタブを隠す
	gsel  TtoW( Index ) + TabID,  1		// 公開
	wID = TtoW( Index )					// 最新にする
	return wID
	
//#### アイテムの削除処理 ######################################################
#modfunc DeleteTab int p2			// TabIndex
	sendmsg hTab, 0x1308, p2		// TCM_DELETETAB (削除)
	fUseSw TtoW( p2 ), false		// 未使用状態にする
	TabNum --						// デクリメント
	
	WtoT   ( TtoW(p2) ) = 0			// 0 にするだけで、削除はしない ( WindowID はシフトしないため )
	ArrayDel TtoW, TtoW, p2			// 削除 ( TabIndex はシフトするため )
	
 #ifdef __USE_TABINT_ON__
	ArrayDel LPRM, LPRM, p2			// 同様に削除する (TabIndex におなじ)
 #endif
	return
	
//######## イメージリスト関係の処理 ############################################
// 関連づけ
#modfunc SetTabImageList int p2
	sendmsg hTab, 0x1303, 0, p2		// TCM_SETIMAGELIST (イメージリストを割り付ける)
	return (stat)
	
// 取得
#defcfunc GetTabImageList mv
	sendmsg hTab, 0x1302, 0, 0		// TCM_GETIMAGELIST (hImageList を取得)
	return (stat)
	
// タブにイメージを付ける ( -1 で取り除く )
#modfunc SetTabImage int p2, int p3
	tcitem(0) = 2, 0, 0, 0, 0, p3				// TCIF_IMAGE
	sendmsg hTab, 0x1306, p2, varptr(tcitem)	// TCM_SETITEM
	return (stat != 0)
	
//######## つまみのフォントを設定する ##########################################
#modfunc ChangeTabStrFont str p2, int p3, int p4, local logfont, local sFontName, local nFontData
	
	if ( hFont ) { DeleteObject hFont }	// 解放しておく
	
	sdim sFontName, 64		// name
	dim  nFontData, 2		// size, style
	
	// 元のフォントデータを記憶
	sFontName    = GetFontName()
	nFontData(0) = GetFontSize(), GetFontStyle()
	
	// logfont 構造体を作成
	font p2, p3, p4							// 希望のモノに変更して、HSP側にオブジェクトを作らせる
	GetStructLogfont          logfont		// フォント情報 (LOGFONT) を取得
	CreateFontIndirect varptr(logfont)		// 新しいフォントオブジェクトを作成 ( 内容は変化させていない )
	hFont = stat							// HSPウィンドウのフォントハンドル
	
	// フォントを変更する
	sendmsg hTab, 0x0030, hFont, 1			// WM_SETFONT ( hFont, bRefresh )
	
	// 元に戻す
	font sFontName, nFontData(0), nFontData(1)
	
	// サイズを適正にする
	repeat TabNum
		AdjustWindowrect thismod, cnt	// すべてを矯正
	loop
	return
	
//######## その他の動作 ########################################################
// 指定座標に何番目のつまみがあるか ( 座標は絶対座標 )
#defcfunc NumberOfTabInPoint mv, int p2, int p3, local tabrect, local cntTabs, local ptMouse, local nRet
	sendmsg hTab, 0x1304, 0, 0	// TCM_GETITEMCOUNT (タブ数を取得)
	cntTabs = stat
	
	dim tabrect, 4
	dim ptMouse, 2
	nRet = -1
	
	// TabControl の Window RECT を取得
	GetWindowRect hTab, varptr(tabrect)
	
	pt = p2 - tabrect(0), p3 - tabrect(1)		// 相対値にする
	
	repeat cntTabs
		// TCM_GETITEMRECT ( wparam のつまみの RECT を lparam(RECT ptr) に格納 )
		sendmsg hTab, 0x130A, cnt, varptr(rect)
		
		// マウス位置がつまみの中ならＯＫ
		if ( (rect(0) <= pt(0) && pt(0) <= rect(2)) && (rect(1) <= pt(1) && pt(1) <= rect(3)) ) {
			nRet = cnt
			break
		}
	loop
	
	return nRet

// タブつまみの中の空白を設定する
#deffunc SetTabPadding int p2, int p3
	sendmsg hTab, 0x132B, 0, MakeLong(p2, p3)	// TCM_SETPADDING
	return
	
// タブつまみの最低幅を設定する
#deffunc SetMinTabWidth int p2
	sendmsg hTab, 0x1331, 0, p2		// TCM_SETMINTABWIDTH
	return
	
//######## 関連int操作命令 #####################################################
// 設定関数
#modfunc TabIntSet int p2, int p3
 #ifdef __USE_TABINT_ON__
	LPRM( p2 ) = p3
 #endif
	return
	
// 取得関数
#defcfunc TabInt mv, int p2
 #ifdef __USE_TABINT_ON__
	return LPRM( p2 )
 #else
	return 0	// 一応 0 を返す
 #endif

//######## 内部参照用関数 ######################################################

#defcfunc GetTabHandle mv
	return hTab
	
#defcfunc GetTabNum mv
	sendmsg hTab, 0x1304, 0, 0		// TCM_GETITEMCOUNT (数を取得する)
	TabNum = stat					// 調整
	return TabNum
	
#defcfunc ActTabIndex mv
	return Index
	
#defcfunc ActTabWinID mv
	return wID
	
#defcfunc  ItoW mv, int p2
	return TtoW( limit( p2, 0, TabNum ) )
	
#defcfunc  WtoI mv, int p2
	return WtoT( limit( p2, 0, TabNum ) )
	
#defcfunc IsReverse mv
	return fReverse != 0
	
// デストラクタ
#modterm
	if ( hFont ) { DeleteObject hFont : hFont = 0 }	// フォントハンドルを解放する
	return
	
#global
_Tabmod_init
//##################################################################################################

// [SAMPLE]
#if 0
	;#define __USE_BITMAP__

#ifdef __USE_BITMAP__
 #include "BitmapMaker.as"
#endif

#const global StartTabID 10

// 取得用マクロ
#define tIndex ActTabIndex(mTab)
#define actwin ActTabWinID(mTab)

#uselib "user32.dll"
#func GetWindowRect "GetWindowRect" int,int

 #ifdef __USE_BITMAP__	
	// イメージリスト作成(しなくても良い) (16×16×4, 24bit, マスクあり)
	CreateImageList 16, 16, 25, 4 : hIml = stat		// イメージリストのハンドル
	buffer 2, , , 0 : picload "treeicon.bmp"		// ビットマップの読み込み
	AddImageList hIml, 0, 0, 16 * 4, 16, 0xF0CAA6	// イメージリストにイメージを追加
 #endif
	
	screen 0, 400, 300			// メインのウィンドウ
	syscolor 15 : boxf : color
	title "Tabmod SAMPLE"
	
//	タブコントロールを設置する。
//	p4 は bgscr 命令で作成するウィンドウID の先頭になります。
//	例えば、下のように [10(StartTabID)] でタブ項目が4個あると、
//	{10, 11, 12, 13} のウィンドウを使用します。
//	また、[3] でタブの項目が 8個あると、{3, 4, 5, 6, 7, 8, 9, 10} が使われます。
//	別で使用するウィンドウID値と被らないよう注意してください。
	pos 50, 50 : CreateTab mTab, 300, 200, StartTabID, 0x4000	// TCS_TOOLTIPS
	hTab = stat		// タブコントロールのハンドルを取得
	
	// フォントが変更出来ます。必須ではありません。
	// font 命令と同じ感覚で使用できます。
	ChangeTabStrFont mTab, "ＭＳ 明朝", 15, 4	// 下線はアクティブなタブにのみ付くようです
	
 #ifdef __USE_BITMAP__
	SetTabImageList mTab, hIml					// イメージリストを関連づける
 #endif
	
	// アイテムの挿入 ( モジュール変数, つまみの文字列, 挿入位置 )
	// 挿入位置を省略すると、一番後ろ( 通常は右 )に追加します。
	
	InsertTab mTab, "AAA", 0
//		スクリーン上にオブジェクトを置く感覚で処理を書きます。
//		カレントウィンドウはタブアイテムに使用されたウィンドウになっています。
		pos 50, 50 : mes "A"
	
	InsertTab mTab, "BBB"
		pos 50, 50 : mes "B"
	
	InsertTab mTab, "CCC"
		pos 50, 50 : mes "C"
	
	InsertTab mTab, "DDD"
		pos 50, 50 : mes "D"
	
	DeleteTab mTab, 1			// TabIndex の 1 ("BBB") を削除します。
	
	InsertTab mTab, "EEE", 0	// 0 …… 左端
		pos 50, 50 : mes "E"
		
 #ifdef __USE_BITMAP__
	// イメージを付ける。ここでやらなくてもいいのに……
	repeat 4
		SetTabImage mTab, cnt, cnt
	loop
 #endif
	
//	タブの項目追加が終わったら、タブ内に貼り付けた bgscr 命令が非表示状態になっているので、
//	表示されるよう gsel 命令を指定してください。
//	CreateTab 命令で指定した ウィンドウID の初期値と同じ値を指定します。
	gsel StartTabID, 1
	
//	ウィンドウID 0 に描画先を戻します。
	gsel
	
//	タブ項目切り替え処理時のメッセージ
	oncmd gosub *Notify, 0x004E			// WM_NOTIFY
	
//	タブの挿入・削除テスト用 ( これは無くても良い )
	gsel 0
	objsize 75, 28
	pos  5, 5 : button gosub "Insert !", *TabInsertEdit
	pos 85, 5 : button gosub "Delete !", *TabDelete
	
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
	pos 120,125 : button gosub "OK", *TabInsert
	
	gsel 0
	onexit goto *exit
	stop
	
// タブ項目切り替え処理部分
// 重要！！
*Notify
	dupptr nmhdr, lparam, 12	// NMHDR 構造体
	
;	logmes "nmhdr = "+ nmhdr(0) +", "+ nmhdr(1) +", "+ nmhdr(2)
	
	if ( nmhdr(0) == hTab ) {	// タブコントロールからの通知 
		
		/* 選択アイテムの変更 */
		if ( nmhdr(2) == -551 ) {
			ChangeTab mTab		// 選択されているアイテムに切り替える。ActiveTabIndex を返す
			
			// 変更の結果を出力 ( actIndex, つまみ文字列, windowID )
			logmes "ChangeTab 「"+ GetTabStrItem(mTab, tIndex) +"」 { ( Index, WinID ) == ( "+ tIndex +", "+ ItoW(mTab, tIndex) +" ) }"
			
			gsel 0, 0	// 元々の screen命令 のウィンドウID 0に描画先を戻します。
			
		/* ショートカットメニュー */
		} else : if ( nmhdr(2) == -5 ) {
			// ポップアップさせる
			n = NumberOfTabInPoint(mTab, ginfo(0), ginfo(1))
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
	
*TabInsert			// アイテムの追加
	// 挿入位置を決定 (空なら -1(最後) にする)
	n = int(InsertPos) - (InsertPos == "")
	
	InsertTab mTab, String(0), n	// 挿入
	n = stat						// 使用した ウィンドウID - TabStartID を返す
	if ( n < 0 ) { return }			// エラー
	
	pos 50, 50 : mes String(1)		// 内部に書き込む
	
	// チェックされていたらアクティブにする
	if ( bCheck ) {
		ShowTab mTab, WtoI(mTab, n)
	}
	
	gsel 1, -1
	gsel 0, 1
	return
	
*TabDelete			// タブの削除
	DeleteTab mTab, tIndex		// アクティブなタブを削除する
	ShowTab   mTab, tIndex -1	// 前のタブをアクティブにする
	gsel 0
	return (stat)
	
// 終了時の処理 ( 不要 )
*exit
	if ( wParam != 0 ) {
		gsel wParam, -1
		stop
	}
	end
	
#endif	// サンプル

#endif	// モジュール全体
