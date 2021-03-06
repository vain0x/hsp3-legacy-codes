// プロセスメモリ管理クラス

#ifndef IG_MODULE_CLASS_PROCESS_MEMORY_AS
#define IG_MODULE_CLASS_PROCESS_MEMORY_AS

// @ VirtualAlloc 系のメモリ管理 API をラップする。

#module MCPcMem mhWnd, midProc, mhProc, mpMem, mMSize

//------------------------------------------------
// 定数
//------------------------------------------------
#define true  1
#define false 0
#define NULL  0

//------------------------------------------------
// API 関数向けの定数
//------------------------------------------------
#define PROCESS_VM_OPERATION	0x0008
#define PROCESS_VM_READ			0x0010
#define PROCESS_VM_WRITE		0x0020
#define MEM_COMMIT				0x1000
#define MEM_RELEASE				0x8000
#define MEM_RESERVE				0x2000
#define PAGE_READWRITE			4

#define PROCESS_ALL_ACCESS		(0x000F0000 | 0x00100000 | 0x0FFF)

//------------------------------------------------
// WinAPI
//------------------------------------------------
#uselib "user32.dll"
#func   GetWindowThreadProcessId@MCPcMem "GetWindowThreadProcessId" int,int

#uselib "kernel32.dll"
#func   GetVersionEx@MCPcMem       "GetVersionExA"      int
#func   OpenProcess@MCPcMem        "OpenProcess"        int,int,int
#func   CloseHandle@MCPcMem        "CloseHandle"        int
#func   VirtualAllocEx@MCPcMem     "VirtualAllocEx"     int,int,int,int,int
#func   VirtualFreeEx@MCPcMem      "VirtualFreeEx"      int,int,int,int
#func   WriteProcessMemory@MCPcMem "WriteProcessMemory" int,int,int,int,int
#func   ReadProcessMemory@MCPcMem  "ReadProcessMemory"  int,int,int,int,int

//------------------------------------------------
// 仮想メモリの確保
//------------------------------------------------
#modfunc PcMem_alloc int nSize
	if ( mMSize || mhProc == NULL ) { return NULL }
	VirtualAllocEx mhProc, NULL, nSize, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE
	mpMem  = stat
	mMSize = nSize
	return mpMem
	
//------------------------------------------------
// 仮想メモリの解放
//------------------------------------------------
#modfunc PcMem_free
	if ( mhProc == NULL || mMSize == 0 || mpMem == NULL ) { return false }
	VirtualFreeEx mhProc, mpMem, mMSize, MEM_RELEASE
	mpMem  = NULL
	mMSize = 0
	return true
	
//------------------------------------------------
// 仮想メモリへの書き込み
//------------------------------------------------
#modfunc PcMem_writeVM int ptr, int pValue, int nSize
	if ( pValue == NULL || mhProc == NULL ) { return false }
	WriteProcessMemory mhProc, ptr, pValue, nSize, NULL
	return
	
//------------------------------------------------
// 確保した仮想メモリへの書き込み( ポインタ )
//------------------------------------------------
#modfunc PcMem_write int pValue, int nSize, int offset
	if ( (offset + nSize) > mMSize ) { return false }
	PcMem_writeVM thismod, mpMem + offset, pValue, nSize
	return stat
	
//------------------------------------------------
// 確保した仮想メモリへの書き込み( 変数 )
//------------------------------------------------
#modfunc PcMem_writeVar var p2, int nSize, int offset
	PcMem_write thismod, varptr(p2), nSize, offset
	return stat
	
//------------------------------------------------
// 仮想メモリへの書き込み( 値 )
//------------------------------------------------
#define global PcMem_writeInt(%1,%2=0,%3=0) val@MCPcMem = %2 : PcMem_writeVar %1, val@MCPcMem, 4, %3
#define global PcMem_writeDouble(%1,%2,%3=0)val@MCPcMem = %2 : PcMem_writeVar %1, val@MCPcMem, 8, %3
#define global PcMem_writeStr(%1,%2,%3=0)  sval@MCPcMem = %2 : PcMem_writeVar %1, sval@MCPcMem, strlen(sval@MCPcMem) + 1, %3

//------------------------------------------------
// 仮想メモリからの読み込み
//------------------------------------------------
#modfunc PcMem_readVM int ptr, int pBuffer, int nSize
	if ( pBuffer == NULL || mhProc == NULL ) { return false }
	ReadProcessMemory mhProc, ptr, pBuffer, nSize, NULL
	return
	
//------------------------------------------------
// 確保した仮想メモリからの読み込み( ポインタ )
//------------------------------------------------
#modfunc PcMem_read int pBuffer, int nSize, int offset
	PcMem_readVM thismod, mpMem + offset, pBuffer, nSize
	return stat
	
//------------------------------------------------
// 確保した仮想メモリからの読み込み( 変数 )
//------------------------------------------------
#modfunc PcMem_readVar var p2, int nSize, int offset
	PcMem_read thismod, varptr(p2), nSize, offset
	return stat
	
//------------------------------------------------
// 確保した仮想メモリの先頭へのポインタを得る
//------------------------------------------------
#modcfunc PcMem_getptr
	return mpMem
	
//------------------------------------------------
// 確保したサイズ
//------------------------------------------------
#modcfunc PcMem_getSize
	return mMSize
	
//------------------------------------------------
// プロセスハンドルを得る
//------------------------------------------------
#modcfunc PcMem_hProc
	return mhProc
	
//------------------------------------------------
// [i] コンストラクタ
//------------------------------------------------
#define global PcMem_new(%1,%2) newmod %1, MCPcMem@, %2
#modinit int hWindow
	
	// メンバ変数の初期化
	mhWnd = hWindow
	dim midProc
	dim mhProc
	dim mpMem
	dim mMSize
	
	// プロセスのハンドルを得る
	GetWindowThreadProcessId mhWnd, varptr(midProc)
	OpenProcess PROCESS_ALL_ACCESS, false, midProc
	mhProc = stat
	
	return
	
//------------------------------------------------
// [i] デストラクタ
//------------------------------------------------
#define global PcMem_delete(%1) delmod %1
#modterm
	// 解放する
	PcMem_free thismod
	
	// プロセスハンドルを閉じる
	if ( mhProc ) { CloseHandle mhProc : mhProc = NULL }
	return
	
#global

#endif
