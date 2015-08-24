// ProcMemory Module

#ifndef __PROCMEMORY_MODULE_AS__
#define __PROCMEMORY_MODULE_AS__

#module pcmem mhWnd, mProcID, mhProc, mpMem, mMSize

// マクロ
#define mv modvar pcmem@

// 定数
#define true  1
#define false 0
#define NULL  0

// API 関数向けの定数
#define PROCESS_VM_OPERATION	0x0008
#define PROCESS_VM_READ			0x0010
#define PROCESS_VM_WRITE		0x0020
#define MEM_COMMIT				0x1000
#define MEM_RELEASE				0x8000
#define MEM_RESERVE				0x2000
#define PAGE_READWRITE			4

#define PROCESS_ALL_ACCESS		(0x000F0000 | 0x00100000 | 0x0FFF)

// WinAPI
#uselib "user32.dll"
#func   GetWindowThreadProcessId@pcmem "GetWindowThreadProcessId" int,int

#uselib "kernel32.dll"
#func   GetVersionEx@pcmem       "GetVersionExA"      int
#func   OpenProcess@pcmem        "OpenProcess"        int,int,int
#func   CloseHandle@pcmem        "CloseHandle"        int
#func   VirtualAllocEx@pcmem     "VirtualAllocEx"     int,int,int,int,int
#func   VirtualFreeEx@pcmem      "VirtualFreeEx"      int,int,int,int
#func   WriteProcessMemory@pcmem "WriteProcessMemory" int,int,int,int,int
#func   ReadProcessMemory@pcmem  "ReadProcessMemory"  int,int,int,int,int

// 仮想メモリの確保
#modfunc PCM_Alloc int nSize
	if ( mMSize || mhProc == NULL ) { return NULL }
	VirtualAllocEx mhProc, NULL, nSize, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE
	mpMem  = stat
	mMSize = nSize
	return mpMem
	
// 仮想メモリの解放
#modfunc PCM_Free
	if ( mhProc == NULL || mMSize == 0 ) { return false }
	VirtualFreeEx mhProc, mpMem, mMSize, MEM_RELEASE
	mpMem  = NULL
	mMSize = 0
	return true
	
// 仮想メモリへの書き込み
#modfunc PCM_WriteVM int ptr, int pValue, int nSize
	if ( pValue == NULL || mhProc == NULL ) { return false }
	WriteProcessMemory mhProc, ptr, pValue, nSize, NULL
	return
	
// 確保した仮想メモリへの書き込み( ポインタ )
#modfunc PCM_Write int pValue, int nSize, int offset
	if ( (offset + nSize) > mMSize ) { return false }
	PCM_WriteVM thismod, mpMem + offset, pValue, nSize
	return stat
	
// 確保した仮想メモリへの書き込み( 変数 )
#modfunc PCM_WriteVar var p2, int nSize, int offset
	PCM_Write thismod, varptr(p2), nSize, offset
	return stat
	
// 仮想メモリへの書き込み( 値 )
#define global PCM_WriteInt(%1,%2=0,%3=0) val@pcmem = %2 : PCM_WriteVar %1,val@pcmem,4,%3
#define global PCM_WriteDouble(%1,%2,%3=0)val@pcmem = %2 : PCM_WriteVar %1,val@pcmem,8,%3
#define global PCM_WriteStr(%1,%2,%3=0)  sval@pcmem = %2 : PCM_WriteVar %1,sval@pcmem,strlen(sval@pcmem) + 1,%3

// 仮想メモリからの読み込み
#modfunc PCM_ReadVM int ptr, int pBuffer, int nSize
	if ( pBuffer == NULL || mhProc == NULL ) { return false }
	ReadProcessMemory mhProc, ptr, pBuffer, nSize, NULL
	return
	
// 確保した仮想メモリからの読み込み( ポインタ )
#modfunc PCM_Read int pBuffer, int nSize, int offset
	PCM_ReadVM thismod, mpMem + offset, pBuffer, nSize
	return stat
	
// 確保した仮想メモリからの読み込み( 変数 )
#modfunc PCM_ReadVar var p2, int nSize, int offset
	PCM_Read thismod, varptr(p2), nSize, offset
	return stat
	
// 確保した仮想メモリの先頭へのポインタを得る
#defcfunc PCM_GetPtr mv
	return mpMem
	
// 確保したサイズ
#defcfunc PCM_GetSize mv
	return mMSize
	
// プロセスハンドルを得る
#defcfunc PCM_hProc mv
	return mhProc
	
// コンストラクタ
#modinit int hWindow
	// メンバ変数の初期化
	mhWnd = hWindow
	dim mProcID
	dim mhProc
	dim mpMem
	dim mMSize
	
	// プロセスのハンドルを得る
	GetWindowThreadProcessId mhWnd, varptr(mProcID)
	OpenProcess PROCESS_ALL_ACCESS, false, mProcID
	mhProc = stat
	
	return mhProc
	
// デストラクタ
#modterm
	// メモリが確保されていたら解放する
	if ( mpMem != NULL ) { PCM_Free thismod }
	
	// プロセスハンドルを閉じる
	if ( mhProc ) {
		CloseHandle mhProc : mhProc = NULL
	}
	return
	
#global

#endif
