// ビットマップ＆
// イメージリスト作成
// モジュール
#ifndef __BITMAP_AND_IMAGELIST_MAKE_MODULE__
#define __BITMAP_AND_IMAGELIST_MAKE_MODULE__

#module BMPmod

#uselib "gdi32.dll"
#cfunc  CreateDC               "CreateDCA"              sptr,nullptr,nullptr,nullptr
#cfunc  CreateCompatibleBitmap "CreateCompatibleBitmap" int,int,int
#cfunc  CreateCompatibleDC     "CreateCompatibleDC"     int
#func   SelectObject           "SelectObject"           int,int
#func   BitBlt                 "BitBlt"                 int,int,int,int,int,int,int,int,int
#func   DeleteDC               "DeleteDC"               int
#func   DeleteObject           "DeleteObject"           int
#cfunc  GetStockObject         "GetStockObject"         int

#uselib "comctl32.dll"
#func   ImageList_Create    "ImageList_Create"    int,int,int,int,int
#func   ImageList_AddMasked "ImageList_AddMasked" int,int,int
#func   ImageList_Draw      "ImageList_Draw"      int,int,int,int,int,int
#func   ImageList_Destroy   "ImageList_Destroy"   int

//######## init 命令 #############################
#deffunc BMPOBJ_MOD_init
	dim hBitmap , 2
	dim hImgList, 2
	dim count   , 2		// (0) = bmp, (1) = img
	return
	
// 内部処理用命令 ( int型一次元配列を拡張 )
#define _RedimInt _______RedimInt
#deffunc _______RedimInt array p1, int p2, local temp
	if ( length(p1) >= p2 ) { return }	// 増えない場合は無視
	dim    temp, length(p1)
	memcpy temp, p1, length(p1) * 4		// コピー
	dim    p1, p2
	memcpy p1, temp, length(temp) * 4	// 戻す
	return
	
//######## ビットマップ オブジェクト編 #########################################
/*************************************************
|*		描画中ウィンドウのイメージから
|*		ビットマップオブジェクト(DIB)作成
|*
|*	ret = CreateDIB (p1, p2, p3, p4)
|*		p1 = int	: HSPウィンドウx座標
|*		p2 = int	: HSPウィンドウy座標
|*		p3 = int	: 幅
|*		p4 = int	: 高さ
|*		返 = stat	: ビットマップのハンドル
.************************************************/
#defcfunc CreateDIB int x, int y, int w, int h
	_RedimInt hBitmap, count	// 拡張
	
	hDisplayDC     = CreateDC              ("DISPLAY")			// 
	hBitMap(count) = CreateCompatibleBitmap(hDisplayDC, w, h)	// 
	hCcDc          = CreateCompatibleDC    (hDisplayDC)			// 
	SelectObject hCcDc, hBitmap( count )						// 
	BitBlt       hCcDc, 0, 0, w, h, hdc, x, y, 0x00CC0020		// 画面からコピー (SRCCOPY)
	DeleteDC     hDisplayDC										// Display の hDC 解放
	DeleteDC     hCcDc											// 解放
	count ++
	return hBitmap( count - 1 )
	
// 解放用命令 ( 呼び出す必要はありません )
#deffunc DeleteBmpObj int p1
	repeat count
		if ( hBitmap( cnt ) == p1 ) {		// モジュール側で作ったものか探す
			 hBitmap( cnt ) = 0				// 消しておく
		}
	loop
	DeleteObject p1	// 削除
	return (stat)
	
//######## イメージリスト編 ####################################################
/*************************************************
|*		イメージリストの作成
|*	CreateImageList	p1, p2, p3, p4
|*		p1 = int	: イメージの幅
|*		p2 = int	: イメージの高さ
|*		p3 = int	: イメージリストのタイプ
|*		p4 = int	: イメージの数
|*		返 = stat	: イメージリストのハンドルが返る
.************************************************/
#define global CreateImageList(%1,%2,%3,%4,%5=0) _CreateImageList %1,%2,%3,%4,%5
#deffunc _CreateImageList int p1, int p2, int p3, int p4, int p5
	_RedimInt   hImgList, count(1)		// 拡張
	
	ImageList_Create p1, p2, p3, p4, p5	// 作成
	hImgList( count(1) ) = stat
	count(1) ++
	return
	
/*************************************************
|*		イメージリストに描画中ウィンドウのイメージ追加
|*	AddImageList p1, p2, p3, p4, p5
|*		p1 = HWND		: イメージリストのハンドル
|*		p2 = int		: HSPウィンドウx座標
|*		p3 = int		: HSPウィンドウy座標
|*		p4 = int		: 幅
|*		p5 = int		: 高さ
|*		p6 = COLORREF	: マスクに用いる色
|*		返 = stat		: イメージのインデックスが返る
.************************************************/
#deffunc AddImageList int hIml, int cx, int cy, int sx, int sy, int crmask, local index, local hBmp

	// DIBオブジェクトの作成
	hBmp = CreateDIB( cx, cy, sx, sy )		// ビットマップハンドル
	
	// ビットマップをイメージリストに追加
	ImageList_AddMasked hIml, hBmp, crmask
	index = stat				// 最初のイメージのインデックス
	
	// ビットマップオブジェクトを削除
	DeleteBmpObj hBmp
	
	return index		// イメージのインデックスを返す
	
/*************************************************
|*		イメージリストの破棄
|*	DestroyImageList p1
|*		p1 = HWND	: イメージリストのハンドル
|*		返 = void
.************************************************/
#deffunc DestroyImageList int p1
	if ( p1 ) {
		ImageList_Destroy p1
	}
	repeat count(1)
		// 再解放しないように、NULL にしておく
		if ( hImgList(cnt) == p1 ) {
			 hImgList(cnt) = 0
		}
	loop
	return
	
//######## デストラクタ ########################################################
#deffunc ONEXIT_ON_BMPMOD onexit
	// ビットマップ・オブジェクトを解放
	repeat count(0)
		if ( hBitmap(cnt)  ) { DeleteObject hBitmap(cnt) }
	loop
	
	// イメージリストを解放
	repeat count(1)
		if ( hImgList(cnt) ) { ImageList_Destroy hImgList(cnt) }
	loop
	
	return 0
	
#global
BMPOBJ_MOD_init
#endif
