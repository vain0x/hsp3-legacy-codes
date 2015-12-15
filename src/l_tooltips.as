/*--------------------------------------------------------------------------

	[HSP3] ツールチップ表示モジュール v2
	by Kpan
	http://lhsp.s206.xrea.com/ (Let's HSP!)


	□ SetToolTips p1
		p1=スタイルの指定

	ツールチップコントロールを作成します。最初に1度だけ呼んでください。
	statには、ツールチップコントロールのオブジェクトIDが返ります。
	p1はスタイルの指定です。すべてのツールチップに適用される形になり
	ます。以下の数値を組み合わせてください。無指定の場合は普通のツール
	チップが表示されます。

	$1  : 自ウィンドウがアクティブになっていない時でも常にツールチップ
	      を表示。
	$40 : ツールチップをバルーンタイプで表示。(要IE5以降)


	□ AddToolTips p1, "文字列", p2
		p1=ツールチップを表示するオブジェクトID。
		p2=ツールチップをオブジェクトの真下に表示。($2を指定)

	ツールチップコントロールに表示文字列を登録します。指定したオブ
	ジェクトにツールチップが表示されます。文字列は64バイト分の領域を
	一応用意しています。	

--------------------------------------------------------------------------*/

#module


;	別途user32.asをインクルードしている場合はコメントアウト可
#uselib "user32"
#func GetClientRect "GetClientRect" int, int


#deffunc SetToolTips int p1
	winobj "tooltips_class32", "", , p1
	hTooltips = objinfo (stat, 2)

	dim RECT, 4

	return stat

#deffunc AddToolTips int p1, str p2, int p3
	hObject = objinfo (p1, 2)

	GetClientRect hObject, varptr (RECT)

	sdim lpszText
	lpszText = p2

	TOOLINFO = 40, $10 | p3, hObject, 0, 0, 0, RECT.2, RECT.3, 0, varptr (lpszText)
	sendmsg hTooltips, $404, , varptr (toolinfo)

	return

#global