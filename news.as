; WarigakiEditor 専用の新規命令・関数です。
;
;-------------------------------------------------------------------------------
#deffunc faceup int FaceUp_p1, int FaceUp_p2
	faceupmode = limit(FaceUp_p1, 0, 2)
	if mode = 0 {
		gsel 0, faceupmode
	} else {
		gsel 3, faceupmode
		if FaceUp_p2 >= 1 : gsel 100+actobj, FaceUp_p2
	}
		return
	
;-------------------------------------------------------------------------------
#deffunc ResetSwitch
; 一時保持用変数をリセット
	sdim ms, 1024, 50, 20, 5, 5	; メモ変数
	dim mi, 100, 50, 20, 5		; メモ変数
	sdim edit_buf, 500000, 2		; 交換をするとき、一時的にeditの内容を溜めておく変数
	dim edit_long, 2				; 追加するとき、そのすぐ下までのオフセット値をstrlen関数で溜めておく変数。0が元、1が先。
	n = 0 							; note の略。略しすぎにご注意
	sdim file_Ext, 24				; extention(拡張子)を一時保存するためのもの
	sdim savedl, 510				; セーブするファイルディレクトリ情報。
	
; スイッチをリセット
	LastStr = 0
	Position = 0
	TBC = 0			; TabBoxCanger タブの箱のナンバー。描くたびに一増やし、最後にリセットする。
	makeonly = 0 	; エディットボックスを再描画するときにのみ使用
	bmonly = 0		; back color Brush Make ONLY の略
	wc = 0			; Word Color type の略 0は背景色、1だと文字色
	new_end = 0		; NEW END　[新規]の時に終了セーブを行うために使用
		return
	
;-------------------------------------------------------------------------------
#deffunc SBfunction int SB_p1, int SB_p2
	SetButtonPosx = SB_p1
	SetButtonPosy = SB_p2
	repeat 3
		button gosub box_symbol(cnt), routine	; ID 0〜2
	loop
	
	pos SetButtonPosx, SetButtonPosy	; 130, 50
	
	repeat 3
		button gosub box_symbol(cnt+3), routine	; ID 3〜5
	loop
		return
	
#define global SetButton(%1=130,%2=50) SBfunction %1, %2
	
;-------------------------------------------------------------------------------
#deffunc DelButton
	; 不要な矢印ボタンを削除
	if boxs = 1 			: clrobj 1,5
	if boxs = 2 and btw = 0 : clrobj 2,5
	if boxs = 2 and btw = 1 : clrobj 1,2 : clrobj 4,5
	if boxs = 3 			: clrobj 3,5
	if boxs = 4 and bju = 0 : clrobj 4,5
	if boxs = 4 and bju = 1 : clrobj 2,2 : clrobj 5,5
	if boxs = 5 			: clrobj 5,5
		return
	
;-------------------------------------------------------------------------------
#deffunc Back
	faceup 1
	gsel 1,0 : esr ,1 : gsel 1,-1	; ツール画面初期化
	faceup 0
		return
	
;-------------------------------------------------------------------------------
#deffunc b
	
		return
	
;-------------------------------------------------------------------------------
#deffunc c
	
		return
	
;-------------------------------------------------------------------------------
#deffunc d
	
		return
	
;-------------------------------------------------------------------------------
	; クリーンアップ命令
	; end 命令でも適用される。
#deffunc CleanUpper onexit
	; 邪魔ファイルを消去
	exist "obj"
	if strsize != -1 {
		delete "obj"
	}
	exist "hsptmp"
	if strsize != -1 {
		delete "hsptmp"
	}
	exist "初期設定ファイル名.dat"
	if strsize = 0 {
		delete "初期設定ファイル名.dat"
	}
	gosub *Delete_Brush	; ブラシ削除
		return