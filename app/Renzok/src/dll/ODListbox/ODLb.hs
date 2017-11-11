%dll
ODListbox.dll
%ver
1.00
%date
2008 9/12 (Fri)
%author
Ue-dai
%url
http://prograpark.ninja-web.net/
%note
ODListbox.as を #include すること
%type
拡張コントロール・ライブラリ
%port
Win
%portinfo

%index
ODLbCreate
オーナー描画リストボックスの生成
%prm
p1, p2, p3, p4, p5
p1 = hwnd	: リストボックスを置くウィンドウのハンドル
p2 = int	: リストボックスの左上Ｘ座標
p3 = int	: リストボックスの左上Ｙ座標
p4 = int	: 横幅
p5 = int	: 縦幅

return = lbID	: ODListboxのID

%inst
ODListbox を生成します。
stat に、作られたリストボックスの ID が返ります。必ず変数に代入して、保存してください。0 から順番に 0, 1, 2 ... となる保証はできません。

%sample
#include "ODListbox.as"
	ODLbCreate hwnd, 10, 10, 200, 400
	lbID = stat
	stop

%href
;ODLbCreate
ODLbDestroy
ODLbProc
%group
ODLb操作系関数
%index
ODLbDestroy
オーナー描画リストボックスの破棄
%prm
p1
p1 = lbID	: ODListboxのID
%inst
オーナー描画リストボックスを破棄します。
終了時にこの命令を呼び出すべきです。
%href
ODLbCreate
;ODLbDestroy
ODLbProc
%group
ODLb操作系関数
%index
ODLbProc
オーナー描画リストボックスのプロシージャ
%prm
p1, p2, p3, p4
p1 = lbID	: ODListboxのID
p2 = int	: ウィンドウメッセージ
p3 = WPARAM	: wparam値
p4 = LPARAM	: lparam値
%inst
このボックスに送られてきたメッセージを処理するためのプロシージャです。
WM_DRAWITEM か WM_MEASUREITEM が親ウィンドウに送られてきた場合、
それの WPARAM と LPARAM をそのまま指定して、この関数を呼び出してください。
この関数のなかで、描画などの必要な処理を行っています。

必ず、ODLbCreate を呼び出す前に、この命令が実行できるようにしておいてください。
(サンプル参照)

※いちいち呼び出さなくてもいいようにしようと奮闘中……。
%sample
#include "ODListbox.as"
	
	// 先に割り込みを設定する
	oncmd gosub *OnDrawItem,    0x002B	// WM_DRAWITEM
	oncmd gosub *OnMeasureItem, 0x002C	// WM_MEASUREITEM
	
	// 生成する
	ODLbCreate hwnd, 10, 10, 200, 400
	lbID = stat
	hListbox = ODLbGetHandle(lbID)
	stop
	
*OnDrawItem
	dupptr dis, lparam, 12		// DRAWITEMSTRUCT 構造体
	if ( hListbox == dis(5) ) {	// ハンドルが同じ場合
		ODLbProc lbID, iparam, wparam, lparam
	}
	return
	
*OnMeasureItem
	// 他のボックスを作らないなら、単に↓だけでもいい
	ODLbProc lbID, iparam, wparam, lparam
	return
	
%href
ODLbCreate
ODLbDestroy
;ODLbProc
%group
ODLb操作系関数
%index
ODLbInsertItem
オーナー描画リストボックスに項目を挿入する
%prm
p1, p2, p3 = -1
p1 = lbID	: ODListboxのID
p2 = str	: 挿入する文字列
p3 = int	: 挿入する項目の番号。省略か負数なら一番後ろ。
%inst
オーナー描画リストボックスに項目を追加・挿入します。
くれぐれも LB_INSERTSTRING や LB_ADDSTRING を送信しないようにしてください。
内部のデータ領域で各項目の情報を管理しているので、それが狂ってしまいます。
%href
;ODLbInsertItem
ODLbDeleteItem
ODLbMoveItem
ODLbSwapItem
%group
ODLb項目操作系関数
%index
ODLbDeleteItem
オーナー描画リストボックスから項目を取り除く
%prm
p1, p2 = -1
p1 = lbID	: ODListboxのID
p2 = int	: 取り除く項目のインデックス (一番上が0で、1ずつ増加する)
%inst
オーナー描画リストボックスから項目を取り除きます。
くれぐれも LB_DELETESTRING や LB_RESETCONTENT を送信しないようにしてください。
内部のデータ領域で各項目の情報を管理しているので、それが狂ってしまいます。
%href
ODLbInsertItem
;ODLbDeleteItem
ODLbMoveItem
ODLbSwapItem
%group
ODLb項目操作系関数
%index
ODLbMoveItem
オーナー描画リストボックスの項目を移動する
%prm
p1, p2, p3
p1 = lbID	: ODListboxのID
p2 = int	: 移動元項目のインデックス (一番上が0で、1ずつ増加する)
p3 = int	: 移動先項目のインデックス (〃)
%inst
インデックス p2 の項目を、p3 の位置に移動させます。
それ以外の項目の順番は移動しません。
%href
ODLbInsertItem
ODLbDeleteItem
;ODLbMoveItem
ODLbSwapItem
%group
ODLb項目操作系関数
%index
ODLbSwapItem
オーナー描画リストボックスの項目を交換する
%prm
p1, p2, p3
p1 = lbID	: ODListboxのID
p2 = int	: 項目インデックス (一番上が0で、1ずつ増加する)
p3 = int	: 〃
%inst
項目インデックス p2, p3 の項目を交換します。
%href
ODLbInsertItem
ODLbDeleteItem
ODLbMoveItem
;ODLbSwapItem
%group
ODLb項目操作系関数
%index
ODLbSetMarginColor
マージン色を設定する
%prm
p1, p2 = -1, p3
p1 = lbID	: ODListboxのID
p2 = int	: 設定する項目のインデックス (一番上が０)
p3 = int	: (COLORREF) マージン色
%inst
オーナー描画リストボックスのマージンの色を設定します。
マージンとは、項目と項目の間にある、項目ではない部分のことです。
通常はないため、ODLbSetItemMargin 命令を呼ばないと見えません。

p2 に項目インデックスを指定した場合、
その項目と、その下にある項目との間のマージンの色が変更されます。
p2 を省略するか、負数(-1)にした場合、すべての項目のマージン色が変更され、
基本マージン色も p3 の色に変更されます。
基本マージン色とは、追加された項目の最初のマージン色になる色のことです。

COLORREF とは、色を表す数値です。
これは、RGB マクロを使用して RGB( r, g, b ) と、指定してください。
16進数で 0xBBGGRR ともできます。
%href
;ODLbSetMarginColor
ODLbSetItemColor
ODLbSetItemPadding
ODLbSetItemMargin
ODLbSetItemHeight
ODLbSetTextFormat
ODLbSetItemLParam
%group
ODLb設定系関数
%index
ODLbSetItemColor
項目の色を設定する
%prm
p1, p2 = 0, p3 = 黒, p4 = 白
p1 = lbID	: ODListboxのID
p2 = int	: 項目インデックス ( 一番上が０ )
p3 = int	: 文字色
p4 = int	: 背景色
%inst
指定した項目の文字色と背景色を変更します。
%href
ODLbSetMarginColor
;ODLbSetItemColor
ODLbSetItemPadding
ODLbSetItemMargin
ODLbSetItemHeight
ODLbSetTextFormat
ODLbSetItemLParam
%group
ODLb設定系関数
%index
ODLbSetItemPadding
項目のパディングを設定する
%prm
p1, p2 = -1, p3 = -1, p4 = -1, p5 = -1
p1 = lbID	: ODListboxのID
p2 = int	: 左のパディング (px)
p3 = int	: 上のパディング (px)
p4 = int	: 右のパディング (px)
p5 = int	: 下のパディング (px)

%inst
すべての項目に含まれるパディングを設定します。
省略したか、負数にしたパラメータのパディングは変更されません。

パディングはマージンと同じく「余白」ですが、
マージンとは違って、「項目の一部」です。

%href
ODLbSetMarginColor
ODLbSetItemColor
;ODLbSetItemPadding
ODLbSetItemMargin
ODLbSetItemHeight
ODLbSetTextFormat
ODLbSetItemLParam
%group
ODLb設定系関数
%index
ODLbSetItemMargin
項目間マージンの大きさを設定する
%prm
p1, p2
p1 = lbID	: ODListboxのID
p2 = int	: マージンの大きさ (px)
%inst
※この命令を使う場合は、必ずODLbSetItemHeight命令を呼ぶ必要があります。

マージンの大きさを設定します。
個別に指定することはできません。
この領域の背景色は、ODLbSetMarginColor 命令で設定してください。

%href
ODLbSetMarginColor
ODLbSetItemColor
ODLbSetItemPadding
;ODLbSetItemMargin
ODLbSetItemHeight
ODLbSetTextFormat
ODLbSetItemLParam
%group
ODLb設定系関数
%index
ODLbSetItemHeight
項目の高さを設定する
%prm
p1, p2
p1 = lbID	: ODListboxのID
p2 = int	: 高さ (px)
%inst
項目の高さを設定します。デフォルトでは20におり、若干窮屈です。
実際の項目の高さは、これに上下のパディングとマージンを足した値になり、
場合によっては、その値を整数倍して調整します。
%href
ODLbSetMarginColor
ODLbSetItemColor
ODLbSetItemPadding
ODLbSetItemMargin
;ODLbSetItemHeight
ODLbSetTextFormat
ODLbSetItemLParam
%group
ODLb設定系関数
%index
ODLbSetTextFormat
項目に描画する文字列のオプションを変更する
%prm
p1, p2, p3
p1 = lbID	: ODListboxのID
p2 = int	: 追加する書式のフラグ
p3 = int	: 取り除く書式のフラグ
%inst
項目に文字列を描画するときに使う、Win32 API の DrawItem 関数に指定する書式を変更します。
デフォルトは (DT_LEFT | DT_END_ELLIPSIS) です。
書式のフラグは、同梱されている ODListbox.as のサンプル部分に定義があります。
それを引用してください。

※p2 と p3 に同じ値を指定した場合、その値は追加されません。

%href
ODLbSetMarginColor
ODLbSetItemColor
ODLbSetItemPadding
ODLbSetItemMargin
ODLbSetItemHeight
;ODLbSetTextFormat
ODLbSetItemLParam
%group
ODLb設定系関数
%index
ODLbSetItemLParam
項目に値を関連づける
%prm
p1, p2
p1 = lbID	: ODListboxのID
p2 = int	: アプリケーション定義値
%inst
%href
ODLbSetMarginColor
ODLbSetItemColor
ODLbSetItemPadding
ODLbSetItemMargin
ODLbSetItemHeight
ODLbSetTextFormat
;ODLbSetItemLParam
%group
ODLb設定系関数
%index
ODLbGetHandle
オーナー描画リストボックスのハンドルを取得
%prm
(p1)
p1 = lbID	: ODListboxのID
return hwnd	: オーナー描画リストボックスのハンドル

%inst
指定したIDのリストボックスのハンドルを取得します。
%href
;ODLbGetHandle
ODLbGetLParam
%group
ODLb取得系関数
%index
ODLbGetLParam
項目に関連づけられた値を取得する
%prm
(p1, p2)
p1 = lbID	: ODListboxのID
p2 = int	: 項目インデックス (一番上が０)
return int	: 関連づけられている値
%inst
指定した項目に関連づけられている値を取得します。
なにも関連づけていない場合は、０が返ります。
%href
ODLbGetHandle
;ODLbGetLParam
%group
ODLb取得系関数
