// とてもシンプルなスプリッタ

// 制約
// @ 1つのウィンドウにのみ使用できる
// @ 非マルチプルインスタンス
//

#ifndef IG_SPLITTER_SIMPLE_AS
#define IG_SPLITTER_SIMPLE_AS

#module SplitterSimple

#uselib "user32.dll"
#func   SetWindowLong "SetWindowLongA" int,int,int
#cfunc  GetWindowLong "GetWindowLongA" int,int
#func   MoveWindow    "MoveWindow"     int,int,int,int,int,int
#func   PostMessage   "PostMessageA"   int,int,int,sptr

#cfunc  LoadCursor     "LoadCursorA"    nullptr,int
#func   SetClassLong   "SetClassLongA"  int,int,int
#func   SetCursor      "SetCursor"      int
#func   ClipCursor     "ClipCursor"     int

#define UWM_SPLITTERMOVE 0x0400

#define ctype boxin(%1=0,%2=0,%3=640,%4=480,%5=mousex,%6=mousey) ( (((%1) <= (%5)) && ((%5) <= (%3))) && (((%2) <= (%6)) && ((%6) <= (%4))) )
#define mousex2 ( ginfo_mx - (ginfo_wx1 + (ginfo_sizex - ginfo_winx) / 2) )
#define mousey2 ( ginfo_my - (ginfo_wy1 + (ginfo_sizey - ginfo_winy) - (ginfo_sizex - ginfo_winx) / 2) )

#if _DEBUG
// @static
	dim bDragging
	dim bLBtnDown
	ldim lbSplitterWhetherDragging, 1
	ldim lbSplitterMoveHandler, 1
	dim refStat
#endif

//------------------------------------------------
// 初期化
//------------------------------------------------
#deffunc SplitterSimple_Init
	oncmd gosub *OnSplitterMove, UWM_SPLITTERMOVE
	return
	
#deffunc SplitterSimple_Term
	if ( bDragging ) {
		ClipCursor NULL		// マウスの移動範囲を解放する
		bDragging = false
	}
	return
	
//------------------------------------------------
// スプリッターの位置を設定
//------------------------------------------------
#define global SplitterSimple_SetWhetherDraggingJudge(%1) \
	lbSplitterWhetherDragging@SplitterSimple = (%1)
	
//------------------------------------------------
// ハンドラの設定
//------------------------------------------------
#define global SplitterSimple_SetMoveHander(%1) \
	lbSplitterMoveHandler@SplitterSimple = (%1)

//------------------------------------------------
// 既定のウィンドウコマンドを定義
//------------------------------------------------
#deffunc SplitterSimple_SetDefaultWindowCommand
	oncmd gosub *OnMouseMove, 0x0200		// WM_MOUSEMOVE (マウスが動いた)
	oncmd gosub *OnLBtnDown,  0x0201		// WM_LBUTTONDOWN
	return
	
//------------------------------------------------
// マウスが仮想スプリッター上を動いたとき
//------------------------------------------------
#deffunc SplitterSimple_OnMouseMove
	gosub lbSplitterWhetherDragging
	if ( stat ) {
		SetCursor LoadCursor(IDC_SIZENS)	// 上下
	}
	return
	
*OnMouseMove
	SplitterSimple_OnMouseMove
	return
	
//------------------------------------------------
// ドラッグ開始
//------------------------------------------------
#deffunc SplitterSimple_OnLBtnDown
	gosub lbSplitterWhetherDragging
	if ( stat ) {
		// 開始時の位置を記憶する
		bDragging   = true					// ドラッグ開始フラッグ
		ptDragStart = ginfo_mx, ginfo_my	// 位置を記憶する
		
		// マウスの移動範囲を制限する
		rc(0) = ginfo_wx1 + 10
		rc(1) = ginfo_wy1 + (10 + 40)
		rc(2) = ginfo_wx2 - 10
		rc(3) = ginfo_wy2 - (10 + 20)
		ClipCursor varptr(rc)
		
		// ボタンが離されるまでループ
		repeat
			getkey bLBtnDown, GETKEY_LBTN
			if ( bLBtnDown == false ) { break }
			await
			
			// スプリッター位置を更新する
			SetCursor LoadCursor(IDC_SIZENS)
			
			ptDragEnd   = ginfo_mx, ginfo_my			// ひとまず今の位置まで動かす
			sendmsg hwnd, UWM_SPLITTERMOVE
			ptDragStart = ptDragEnd(0), ptDragEnd(1)	// ドラッグ再開
		loop
		
		// ドロップされた
		if ( bDragging ) {
			ClipCursor NULL							// 移動制限を解放
			bDragging = false						// 終了
			ptDragEnd = ginfo_mx, ginfo_my			// 位置を記憶する
			
			sendmsg hwnd, UWM_SPLITTERMOVE, 0, 0	// 終了を通知する
		}
	}
	return
	
*OnLBtnDown
	SplitterSimple_OnLBtnDown
	return
	
//------------------------------------------------
// スプリッターが動いたとき
//------------------------------------------------
*OnSplitterMove
	mref refStat, 64
	refStat = ptDragEnd(1) - ptDragStart(1)		// stat にスプリッターの変位を代入
	
	// ユーザ定義ハンドラを呼び出す
	gosub lbSplitterMoveHandler
	return
	
#global

#endif
