// 参考: 月影とも氏のタスクトレイアイコンモジュール <http://tu3.jp/0108>

#ifndef IG_TRAYICON_AS
#define IG_TRAYICON_AS

#module trayicon

#define WM_TRAYEVENTSTART 0x0900
#define MAX_ICONS  16		// アイコンの最大数
#define POPUP_TIME 30		// タイムアウト時間[sec]

#define NIF_MESSAGE	0x0001
#define NIF_ICON	0x0002
#define NIF_TIP		0x0004

#define NIM_ADD		0x000
#define NIM_MODIFY	0x001
#define NIM_DELETE	0x002

#define ERROR_TIMEOUT 1460

#uselib "kernel32.dll"
#func   GetModuleFileName@trayicon "GetModuleFileNameA" nullptr, prefstr, int
#cfunc  GetLastError@trayicon      "GetLastError"

#uselib "shell32.dll"
#func   ExtractIconEx@trayicon    "ExtractIconExA"    sptr, int, nullptr, var, int
#func   Shell_NotifyIcon@trayicon "Shell_NotifyIconA" int, int

#uselib "user32.dll"
#func   DestroyIcon@trayicon "DestroyIcon" int

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
		
		await 17
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
// 開始時
//------------------------------------------------
#deffunc _init@trayicon
	mref    bmscr, 96
	hWnd_ = bmscr(13)
	dim hIcon, MAX_ICONS
	SetTrayIconFile ""
	return
	
//------------------------------------------------
// 終了時
//------------------------------------------------
#deffunc _term@trayicon onexit
	foreach hIcon
		if ( hIcon(cnt) ) {
			DestroyTrayIcon cnt
		}
	loop
	return
	
#global

	_init@trayicon

#endif
