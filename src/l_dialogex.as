/*--------------------------------------------------------------------------

	[HSP3] 拡張したファイルの開く/保存ダイアログ モジュール
	by Kpan
	http://lhsp.s206.xrea.com/ (Let's HSP!)

	dialogEx p1, p2, p3, p4, p5
		p1=ダイアログの種類 {開く(0) / 保存(1)}
		p2=[ファイルの種類]で表示する文字列
		p3=[ファイル名]で表示する文字列
		p4=ダイアログのタイトル名
		p5=初期フォルダパス

	ファイルの開くダイアログ(dialog命令のタイプ16相当)、保存ダイア
	ログ(タイプ17相当)を表示します。ファイルの選択が正常に行われると、
	statに1、refstrにファイルパスが返ります。キャンセルやエラーの
	場合はstatに0が返ります。

	p2はダイアログの[ファイルの種類]項目で表示する文字列です。リスト
	ボックスに複数の拡張子を用意できます。｢文字列|*.拡張子|～｣という
	形式で書いてください。(詳しくはサンプル参照)

	p3はダイアログの[ファイル名]項目で表示する文字列です。dialog命令
	では拡張子が自動的に表示される部分です。

	p4はダイアログのタイトル名です。｢""｣という形で省略した場合、自動
	的に｢ファイルを開く｣、｢名前をつけて保存｣になります。

	p5は初期フォルダのパスです。chdir命令に相当します。

	(注) モジュールを使用するに当たって、スクリプトエディタの[HSP]
	メニューの[HSP拡張マクロを使用する]を有効にしておいてください。

--------------------------------------------------------------------------*/


#module


#uselib "comdlg32"
#func GetOpenFileName "GetOpenFileNameA" int
#func GetSaveFileName "GetSaveFileNameA" int


#deffunc dialogEx int v0, str v1, str v2, str v3, str v4

	sdim lpstrFilter, 256 : lpstrFilter = v1
	sdim lpstrInitialDir, 128 : lpstrInitialDir = v4
	sdim lpstrFile, 128 : lpstrFile = v2
	sdim lpstrTitle, 64 : lpstrTitle = v3

	repeat strlen (lpstrFilter)
		x = peek (lpstrFilter, cnt)
		if x>$80 & x<$A0 | x>$DF & x<$FD : continue cnt+2
		if x = $7C : poke lpstrFilter, cnt, $00
	loop

	prm = 76, hwnd, hinstance, varptr (lpstrFilter), 0, 0, 0, varptr (lpstrFile), 256, 0, 0, varptr (lpstrInitialDir), varptr (lpstrTitle)

	if v0 {
		prm.13 = $806 : GetSaveFileName varptr (prm)
	} else {
		prm.13 = $1004 : GetOpenFileName varptr (prm)
	}

	if stat = 0 : return
	return lpstrFile

#global
