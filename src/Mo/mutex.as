// Mutex Module

#ifndef __MUTEX_MODULE_AS__
#define __MUTEX_MODULE_AS__

// ・ミューテックスの作成
//	"Mutex" というWindows 同期オブジェクトを
//	作成し、二重起動時、既に同じ Mutex があったら跳ね返します。
//	確実性があり、かつ拡張DLLは使わない、堅実な方法です。
//
//	HANDLE CreateMutexA (
//		PSECURITY_ATTRIBUTES psa,	// セキリュティの構造体のポインタ（今回は必要無い）
//		BOOL    bInitialOwner,		// 所有権を取得するか（今回はどちらでもかまわない）
//		PCTSTR  pszMutexName,		// 作成するミューテックス名
//	);

#module mutexmod

#define true  1
#define false 0
#define NULL  0

#uselib "kernel32.dll"
#func   CreateMutex@mutexmod  "CreateMutexA" nullptr,int,sptr
#cfunc  GetLastError@mutexmod "GetLastError"
#func   CloseHandle@mutexmod  "CloseHandle"  int

#deffunc CloseMutex		// Mutex 破棄
	if ( hMutex ) { CloseHandle hMutex : hMutex = NULL }
	return false
	
#defcfunc IsUsedByMutex str p1
	// Mutexを作成
	CreateMutex false, p1
	hMutex = stat
	if ( hMutex == NULL ) {
		dialog "MutexObject の作成に失敗しました。", 1, "Error"
		end
	}
	
	// すでに同名の Mutex が存在していた！（存在していて Mutex が作成できなかった）
	if ( GetLastError() == 183 ) {	// ERROR_ALREADY_EXISTS
		CloseMutex					// ハンドルをクローズする
		return true
	}
	return false
	
#global

#endif
