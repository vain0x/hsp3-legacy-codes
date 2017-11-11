// アイコン操作モジュール

#ifndef __ICON_MODULE_AS__
#define __ICON_MODULE_AS__

#module icomod

#uselib "shell32.dll"
#func   DeleteIcon@icomod    "DeleteIcon"     int
#cfunc  ExtractIcon@icomod   "ExtractIconA"   int,sptr,int
#func   ExtractIconEx@icomod "ExtractIconExA" sptr,int,int,int,int

#uselib "user32.dll"
#func   DrawIconEx@icomod "DrawIconEx" int,int,int,int,int,int,int,int,int

//------------------------------------------------
// マクロ
//------------------------------------------------
#define stt_hIcon stt_hIcon_inst(stt_hIcon_c)
#define true  1
#define false 0
#define NULL  0

//------------------------------------------------
// モジュール初期化
//------------------------------------------------
#deffunc local _init@icomod
	dim stt_hIcon_inst, 20
	stt_hIcon_c = -1
	return
	
//##########################################################
//        アイコン作成系
//##########################################################
//------------------------------------------------
// ファイルに含まれるアイコンの総数
//------------------------------------------------
#defcfunc CntIconsInFile str path
	return ExtractIcon( hinstance, path, -1 )
	
//------------------------------------------------
// ファイルからアイコンを抽出
//------------------------------------------------
#defcfunc ExtractIconFromFile str path, int iIcon
	if ( iIcon < 0 ) { return NULL }
	
	stt_hIcon_c ++
	stt_hIcon = ExtractIcon( hinstance, path, iIcon )
	return stt_hIcon
	
//------------------------------------------------
// ファイルから複数のアイコンを抽出
//------------------------------------------------
#define global ExtractBigIconsFromFile(%1,%2="",%3=1,%4=0) _ExtractIconsFromFile@icomod %1,%2,%3,%4,1
#define global ExtractSmlIconsFromFile(%1,%2="",%3=1,%4=0) _ExtractIconsFromFile@icomod %1,%2,%3,%4,0
#deffunc _ExtractIconsFromFile@icomod array ret, str path, int maxicons, int iIcon, int bBig, local cntIcons
	if ( iIcon < 0 ) { return 0 }
	
	stt_hIcon_c ++
	dim ret, maxicons
	
	// 抽出する
	if ( bBig ) {
		ExtractIconEx path, iIcon, varptr(ret), NULL, maxicons
	} else {
		ExtractIconEx path, iIcon, NULL, varptr(ret), maxicons
	}
	cntIcons = stat
	
	// 解放するリストに登録する
	repeat cntIcons
		stt_hIcon_c ++
		stt_hIcon = ret(cnt)
	loop
	
	return cntIcons
	
//------------------------------------------------
// 直前に作成したアイコンのハンドルを返す
//------------------------------------------------
#defcfunc GetLastIcon
	return stt_hIcon
	
//##########################################################
//        アイコン描画系
//##########################################################
//------------------------------------------------
// 通常の描画
//------------------------------------------------
#define global DrawIcon(%1,%2=16,%3=16,%4=3) _DrawIcon@icomod %1,%2,%3,%4
#deffunc _DrawIcon@icomod int hIcon, int cx, int cy, int flag
	if ( hIcon == NULL ) { return }
	DrawIconEx hdc, ginfo(22), ginfo(23), hIcon, cx, cy, 0, 0, flag
	return
	
//##########################################################
//        アイコンハンドル解放系
//##########################################################
//------------------------------------------------
// アイコンを解放する
//------------------------------------------------
#deffunc FreeIcon int hIcon, int bAlldel
	if ( hIcon != NULL ) { DeleteIcon hIcon }
	
	if ( bAlldel == false && stt_hIcon_c > 0 ) {
		repeat stt_hIcon_c
			if ( stt_hIcon_inst(cnt) == hIcon ) {
				stt_hIcon_inst(cnt) = NULL
			}
		loop
	}
	return
	
//------------------------------------------------
// 作成したすべてのアイコンを解放する
//------------------------------------------------
#deffunc FreeAllIcons onexit
	return
	
	repeat stt_hIcon_c + 1
		FreeIcon stt_hIcon_inst(cnt), true	// NULL でなければ解放する
		stt_hIcon_inst(cnt) = NULL
	loop
	
	stt_hIcon_c = -1
	return
	
#global
_init@icomod

//##############################################################################
//        サンプル・スクリプト
//##############################################################################
#if 0

#const ICOSIZE 24
	
	repeat CntIconsInFile("shell32.dll")
		pos 5 + ( cnt \ (640 / ICOSIZE - 1) ) * ICOSIZE, 5 + (cnt / (640 / ICOSIZE - 1)) * ICOSIZE
		DrawIcon ExtractIconFromFile("shell32.dll", cnt), ICOSIZE, ICOSIZE
	loop
	redraw
	stop
	
#endif

#endif
