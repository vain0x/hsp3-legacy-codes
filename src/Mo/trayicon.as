/* trayicon.as */

#ifndef IG_TRAYICON_AS
#define IG_TRAYICON_AS

#module trayicon

// HSP3 で タスクトレイアイコンを作るモジュール 0.02 / 月影とも 2005. 8.12

#define WM_TRAYEVENTSTART 0x0900
#define MAX_ICONS  16		// ←アイコン最大数定義
#define POPUP_TIME 30		// タイムアウト時間(sec)

#define NIF_MESSAGE	0x0001
#define NIF_ICON	0x0002
#define NIF_TIP		0x0004

#define NIM_ADD		0x000
#define NIM_MODIFY	0x001
#define NIM_DELETE	0x002

#define ERROR_TIMEOUT 1460	// This operation returned because the timeout period expired.

// 使用するAPIの定義。
#uselib "Kernel32.dll"
#func   GetModuleFileName@trayicon "GetModuleFileNameA" nullptr,prefstr,int	// 自分自身の名前を得るAPI
#cfunc  GetLastError@trayicon      "GetLastError"

#uselib "Shell32.dll"
#func   ExtractIconEx@trayicon    "ExtractIconExA" sptr,int,nullptr,var,int	// ファイルからアイコンを抽出する
#func   Shell_NotifyIcon@trayicon "Shell_NotifyIconA" int,int				// タスクトレイアイコンを制御する

#uselib "user32.dll"
#func   DestroyIcon@trayicon "DestroyIcon" int		// 抽出したアイコンを破棄する

//------------------------------------------------
// タスクトレイにアイコンを追加する
// 
// @prm tooltip : ツールチップ文字列。最大 63 [byte]
// @prm idxIcon : 指定したファイルに含まれるアイコンの番号
// @prm idIcon  : アイコンID
//------------------------------------------------
#deffunc CreateTrayIcon str sTooltip, int idxIcon, int idIcon
	if ( hIcon(idIcon) ) { DestroyTrayIcon idIcon }			// すでに設定されていたら一度削除する
	ExtractIconEx icofile, idxIcon, hIcon(idIcon), 1		// ファイルからアイコンを取り出す。
	
	dim nfid, 88 / 4			// NOTIFYICONDATA 構造体を作る。
	// size of struct, hWindow, idIcon, Flag, MsgID, hIcon, Tooltips
	nfid = 88, hWnd_, idIcon, 7, WM_TRAYEVENTSTART, hIcon(idIcon)
	poke nfid, 4 * 6, sTooltip
	
	// アイコンを登録する
	repeat
		Shell_NotifyIcon NIM_ADD, varptr(nfid)		// アイコンを登録する。
		if ( stat ) { break }						// 真なら終わり
		
		// タイムアウトかどうか調べる
		if ( GetLastError() != ERROR_TIMEOUT ) {
			// アイコン登録エラー
			logmes "通知領域にアイコンを登録できませんでした"
			break
		}
		
		// 登録できていないことを確認する
		Shell_NotifyIcon NIM_MODIFY, varptr(nfid)
		if ( stat ) { break }
		
		wait 10
	loop
	
	// アイコンを弄られたらこのラベルに飛ぶよう指定する
	oncmd gosub *OnTrayIconEvent@, WM_TRAYEVENTSTART
	
	return
	
//------------------------------------------------
// タスクトレイのアイコンを削除する
//------------------------------------------------
#deffunc DestroyTrayIcon int idIcon 
	dim nfid, 88 / 4							// NOTIFYICONDATA 構造体
	nfid = 88, hWnd, idIcon
	Shell_NotifyIcon NIM_DELETE, varptr(nfid)	// アイコンを削除する。
	if ( hIcon(idIcon) ) {
		DestroyIcon hIcon( idIcon )				// トレイから取り除く
		hIcon( idIcon ) = 0						// アイコンハンドル破棄
	}
	return
	
//------------------------------------------------
// アイコンにバルーンチップを付ける
// 
// @ CreateTrayIcon済みのアイコンから、バルーンチップをポップアップさせる。
// @ Windows Me/2000/XP のみで有効、98SE以前では実行しても何も起こらなそう。
// @prm baloonInfoTitle : バルーンチップのタイトル部の文字列。最大 63 [byte]
// @prm balloonInfo     : バルーンチップの本文。最大 255 [byte]
// @prm baloonIcon      : 0 => none, 1 => info(i),  2 => warn(!), 3 => err(X)
// @prm idIcon          : 対象のアイコンID
//------------------------------------------------
#deffunc PopupBalloonTip str balloonInfoTitle, str balloonInfo, int balloonIcon, int idIcon
	dim  nfid,  488 / 4
		 nfid = 488, hWnd_, idIcon, 0x0010
	poke nfid,  4 * 40, balloonInfo
		 nfid(104) = 1000 * POPUP_TIME			// タイムアウト時間
	poke nfid,  4 * 105, balloonInfoTitle
		 nfid(121) = balloonIcon
	
	Shell_NotifyIcon NIM_MODIFY, varptr(nfid)	// アイコンを変更する。
	return
	
//------------------------------------------------
// アイコンを持つファイルを選択する
// 
// @prm filename : ファイルパス。"" => 自分自身
//------------------------------------------------
#deffunc SetTrayIconFile str filename 
	sdim icofile, 260 + 1			// MAX_PATH
	if ( filename == "" ) {
		GetModuleFileName 260
		icofile = refstr
	} else {
		icofile = filename
	}
	return
	
//------------------------------------------------
// モジュール準備
//------------------------------------------------
#deffunc _init@trayicon
	mref    bmscr, 96
	hWnd_ = bmscr(13)
	dim hIcon, MAX_ICONS
	SetTrayIconFile ""
	return
	
//------------------------------------------------
// モジュール破棄
//------------------------------------------------
#deffunc _term@trayicon onexit	// 終了時に全部のアイコンを削除。
	foreach hIcon
		if ( hIcon(cnt) ) {
			DestroyTrayIcon cnt
		}
	loop
	return
	
#global

	_init@trayicon

// サンプル・スクリプト
#if 0
	
	CreateTrayIcon  "さんぷるあいこん 0"	// とりあえず作ってみる。
	PopupBalloonTip "ばるーん", "これはバルーンチップのサンプルです。", 3, 0
	
	SetTrayIconFile "user32.dll"
	CreateTrayIcon  "さんぷるあいこん 1", 1, 1
	CreateTrayIcon  "さんぷるあいこん 2", 4, 2
	
	SetTrayIconFile "winmine.exe"
	CreateTrayIcon  "さんぷるあいこん 3", 0, 3
	mes "トレイにアイコンを作りました。"
	stop
	
*OnTrayIconEvent@
	// コレと似たようなやつを、使う側で作ってください。
	idIcon = wparam
	switch ( lparam )
		case 0x0200 : swbreak		// マウスがアイコンを触っただけ。
		case 0x0201 : mes "アイコン("+ idIcon +")で左ボタンが押下されました"				: swbreak
		case 0x0202 : mes "アイコン("+ idIcon +")で左ボタンが解放されました"				: swbreak
		case 0x0203 : mes "アイコン("+ idIcon +")で左ボタンがダブルクリックされました"		: swbreak
		case 0x0204 : mes "アイコン("+ idIcon +")で右ボタンが押下されました"				: swbreak
		case 0x0205 : mes "アイコン("+ idIcon +")で右ボタンが解放されました"				: swbreak
		case 0x0206 : mes "アイコン("+ idIcon +")で右ボタンがダブルクリックされました"		: swbreak
		case 0x0207 : mes "アイコン("+ idIcon +")で真ん中のボタンが押されました"			: swbreak
		case 0x0208 : mes "アイコン("+ idIcon +")で真ん中のボタンが離されました"			: swbreak
		case 0x0209 : mes "アイコン("+ idIcon +")で真ん中のボタンがダブルクリックされました": swbreak
	swend
	return
	
#endif

#endif
