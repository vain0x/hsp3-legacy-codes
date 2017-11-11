/***********************************************************

	プロセスの実行優先度設定モジュール

		【2006/7/6 更新】

***********************************************************/
#ifndef __PRIORITY_AS__
#define __PRIORITY_AS__

#module priority

#uselib "kernel32.dll"
#cfunc   GetCurrentProcess "GetCurrentProcess"
#cfunc   GetCurrentThread  "GetCurrentThread"
#func    SetPriorityClass  "SetPriorityClass"	int,int
#func    SetThreadPriority "SetThreadPriority" int,int

// プロセスの優先度クラス
#define global REALTIME_PRIORITY_CLASS		0x00000100	// リアルタイム (優先度 : 最高) ! 使用すべきでない !
#define global HIGH_PRIORITY_CLASS			0x00000080	// 優先クラス	(優先度 : 高い) ! 使用すべきでない !
#define global ABOVE_NORMAL_PRIORITY_CLASS	0x00008000	// 通常以上		(優先度 : 弱高) XP 以降
#define global NORMAL_PRIORITY_CLASS		0x00000020	// 通常			(優先度 : 普通) 標準
#define global BELOW_NORMAL_PRIORITY_CLASS	0x00004000	// 通常以下		(優先度 : 弱低) XP 以降
#define global IDLE_PRIORITY_CLASS			0x00000040	// アイドル		(優先度 : 低い) 常駐アプリ

// スレッドの相対優先度 ( HSPの場合常にシングルスレッドなので指定してもたぶん意味なし )
#define global THREAD_PRIORITY_IDLE				(-15)	// プロセスの優先度クラスが REALTIME_PRIORITY_CLASS のとき、スレッド優先度を 16 にします。それ以外のときはスレッド優先度を 1 にします
#define global THREAD_PRIORITY_LOWEST			(-2)	// スレッド優先度をプロセスの優先度クラスの通常の優先度より 2 低く設定します。
#define global THREAD_PRIORITY_BELOW_NORMAL		(-1)	// スレッド優先度をプロセスの優先度クラスの通常の優先度より 1 低く設定します。
#define global THREAD_PRIORITY_NORMAL			0		// スレッド優先度をプロセスの優先度クラスの通常の優先度に設定します。
#define global THREAD_PRIORITY_HIGHEST			1		// スレッド優先度をプロセスの優先度クラスの通常の優先度より 1 高く設定します。
#define global THREAD_PRIORITY_ABOVE_NORMAL		2		// スレッド優先度をプロセスの優先度クラスの通常の優先度より 2 高く設定します。
#define global THREAD_PRIORITY_TIME_CRITICAL	15		// プロセスの優先度クラスが REALTIME_PRIORITY_CLASS のとき、スレッド優先度を 31 にします。それ以外のときはスレッド優先度を 15 にします。

// 普通のアプリケーションのデフォルト優先度は
// NORMAL_PRIORITY_CLASS, THREAD_PRIORITY_NORMAL
#define global NormalPriority SetPriority NORMAL_PRIORITY_CLASS, THREAD_PRIORITY_NORMAL//	通常
#define global IdlePriority SetPriority IDLE_PRIORITY_CLASS, THREAD_PRIORITY_IDLE//			最低

/**********************************************************/
// モジュール初期化（ファイル末尾で呼び出し済み）
/**********************************************************/
#deffunc _init_priority_mod
	hProc   = GetCurrentProcess()	// プロセス・ハンドルを取得
	hThread = GetCurrentThread()	// スレッド・ハンドルを取得
	return
	
/**********************************************************/
// 自分自身の実行優先度を設定
//  p1 = プロセスの優先度クラス（上記の定数から指定）
//  p2 = スレッドの相対優先度（上記の定数から指定）
/**********************************************************/
#deffunc SetPriority int p1,int p2
	error = 0
	Prior = p1
	RelativePrior = p2
	
	SetPriorityClass hProc, Prior
	if (stat == 0) {	// 失敗
		error += 1
	}
	
	SetThreadPriority hThread, RelativePrior
	if (stat == 0) {	// 失敗
		error += 2
	}
	
	return error
	
/**********************************************************/
#global
_init_priority_mod

#endif
