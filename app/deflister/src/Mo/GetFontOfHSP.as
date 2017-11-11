// font 命令での設定を取得する
// コントロールのフォントを簡単に設定する

#ifndef __GETFONT_OF_HSP_AS__
#define __GETFONT_OF_HSP_AS__

#module gfoh_mod

#uselib "gdi32.dll"
#func   CreateFontIndirect@gfoh_mod "CreateFontIndirectA" int
#func   GetObject@gfoh_mod    "GetObjectA"   int,int,int
#func   DeleteObject@gfoh_mod "DeleteObject" int

//------------------------------------------------
// HSP の LOGFONT 構造体を取得する
//------------------------------------------------
#deffunc GetStructLogfont array _logfont
	dim    _logfont, 15
	mref      bmscr, 67
	GetObject bmscr(38), 60, varptr(_logfont)	// LOGFONT 構造体を取得する
	
;	foreach logfont
;		logmes strf("logfont(%2d)", cnt) +" = "+ logfont(cnt)
;	loop
	
	dim bmscr	// 一応通常の変数に戻しておく
	return
	
//------------------------------------------------
// 現在のフォント名取得
//------------------------------------------------
#defcfunc GetFontName local sRet
	sdim   sRet, 64
	GetStructLogfont logfont 
	getstr sRet,     logfont(7)
	return sRet
	
//------------------------------------------------
// 現在のフォントサイズ取得
//------------------------------------------------
#defcfunc GetFontSize int bStillGotLogfont
	if ( bStillGotLogfont == 0 ) {
		GetStructLogfont logfont			// LOGFONT構造体
	}
	return ( logfont(0) ^ 0xFFFFFFFF ) + 1
	
//------------------------------------------------
// 現在のフォントスタイル取得
//------------------------------------------------
#defcfunc GetFontStyle int bStillGotLogfont
	if ( bStillGotLogfont == 0 ) {
		GetStructLogfont logfont			// LOGFONT構造体
	}
/*
	style |= (  logfont(4) >= 700             ) << 0	// Bold
	style |= ( (logfont(5) & 0x000000FF) != 0 ) << 1	// Italic
	style |= ( (logfont(5) & 0x0000FF00) != 0 ) << 2	// UnderLine
	style |= ( (logfont(5) & 0x00FF0000) != 0 ) << 3	// StrikeLine
	style |= ( (logfont(6) & 0x00040000) != 0 ) << 4	// AntiAlias
	return style
/*///
// Compact version ↓
	return ((logfont(4) >= 700)) | (((logfont(5) & 0x000000FF) != 0) << 1) | (((logfont(5) & 0x0000FF00) != 0) << 2) | (((logfont(5) & 0x00FF0000) != 0) << 3) | (((logfont(6) & 0x00040000) != 0) << 4)
//*/

//------------------------------------------------
// フォントオブジェクトを作成する
// 
// @return int
//  フォントハンドル (int)
//  ☆最後に「必ず」 DeleteFont で解放してください！！
// @ HSP のウィンドウを利用している
//------------------------------------------------
#defcfunc CreateFontByHSP str p1, int p2, int p3, local sFontName, local nFontData
	sdim sFontName, 64		// name
	dim  nFontData, 2		// size, style
	
	// 元のフォントデータを記憶
	sFontName = GetFontName()				// 変数 logfont に値が格納される
	nFontData = GetFontSize(1), GetFontStyle(1)
	
	// logfont 構造体を作成
	font p1, p2, p3
	GetStructLogfont          logfont		// フォント情報 (LOGFONT) を取得
	CreateFontIndirect varptr(logfont)		// 新しいフォントオブジェクトを作成
	hFont = stat							// HSPウィンドウから作ったフォントハンドル
	
	// 元に戻す
	font sFontName, nFontData(0), nFontData(1)
	
	return hFont
	
//------------------------------------------------
// コントロールのフォントを設定
// 
// @ WM_SETFONT を送る ( hFont, bRefresh )
//------------------------------------------------
#define global ChangeControlFont(%1,%2="",%3,%4=0,%5=1) _ChangeControlFont %1,%2,%3,%4,%5
#deffunc ChangeControlFont int p1, str p2, int p3, int p4, int bRefresh
	hFont = CreateFontByHSP(p2, p3, p4)
	sendmsg p1, 0x0030, hFont, bRefresh
	return hFont
	
//------------------------------------------------
// 不要なフォントハンドルの解放
//------------------------------------------------
#deffunc DeleteFont int p1
	if ( p1 ) { DeleteObject p1 }
	return
	
#global

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
//------------------------------------------------
// サンプル 1
//------------------------------------------------
#if 0
	// StaticText Control を作成
	winobj "static", " \n表示するテキスト ", 0, 0x50000000, ginfo(12), ginfo(13)
	hStatic = objinfo(stat, 2)		// ハンドル
	
	ChangeControlFont hStatic, "ＭＳ 明朝", 58, 1 | 2	// 太字・斜体
	hFont = stat										// フォントハンドルが返る
	
	onexit goto *exit	// 終了に割り込む
	stop
	
*exit
	DeleteFont hFont	// 最後に解放
	end
	
#endif

//------------------------------------------------
// サンプル 2
//------------------------------------------------
#if 0

#define WAITTIME 120

	// A と B のフォント入れ替え
	screen 0, 320, 240,,  20, 60 : title "Window A" : mes "Window A です"
	screen 1, 320, 240,, 350, 60 : title "Window B" : mes "Window B です"
	
	wait WAITTIME
	
	sdim sFontName, 64, 2
	dim  nFontSize,  2
	dim  nFontStyle, 2
	
	gsel 0, 1
	mes  "sysfont 0"
	font "ＭＳ ゴシック", 24, 2 | 4 | 16
	mes " ＭＳ ゴシック , 24, 2 | 4 | 16"
	
	wait WAITTIME
	
	// ゴシックのデータ
	sFontName (0) = GetFontName()
	nFontSize (0) = GetFontSize()
	nFontStyle(0) = GetFontStyle()
	
	font "ＭＳ 明朝", 16
	mes  "ＭＳ 明朝, 16 に変更"
	
	wait WAITTIME
	
	// 明朝のデータ
	sFontName (1) = GetFontName()
	nFontSize (1) = GetFontSize()
	nFontStyle(1) = GetFontStyle()
	
	gsel 1, 1
	font sFontName(1), nFontSize(1), nFontStyle(1)
	mes "明朝体にしました"
	
	wait WAITTIME
	
	gsel 0, 1
	font sFontName(0), nFontSize(0), nFontStyle(0)
	mes "ＭＳ ゴシックに戻しました"
	stop
	
#endif

#endif
