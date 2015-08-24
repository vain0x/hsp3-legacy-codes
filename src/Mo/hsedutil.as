// hsed utility module

#ifndef __HSED_UTILITY_MODULE_AS__
#define __HSED_UTILITY_MODULE_AS__

#include "hsedsdk.as"
#include "ProcMemory.as"

#module hsedutil

//##################################################################################################
//        定数・マクロ
//##################################################################################################
#define true  1
#define false 0
#define NULL  0
#define MAX_PATH 260

// Win32 API 関数群
#uselib "psapi.dll"
#func   global EnumProcessModules  "EnumProcessModules"   int,sptr,int,sptr
#func   global GetModuleFileNameEx "GetModuleFileNameExA" int,int,sptr,int

//##################################################################################################
//        [define] 命令群
//##################################################################################################
// スクリプトエディタのフルパスを得る
#defcfunc hsed_GetHsedPath local hHsed, local mTabPcm, local path, local hModule, local retSize
	sdim path, MAX_PATH
	
	hsed_getwnd             hHsed, HGW_MAIN
	newmod mHsedPcm, pcmem, hHsed
	
	EnumProcessModules  PCM_hProc(mHsedPcm), varptr(hModule), 4, varptr(retSize)
	GetModuleFileNameEx PCM_hProc(mHsedPcm), hModule, varptr(path), MAX_PATH
	
	delmod mHsedPcm
	return path
	
// 指定されたタブが開いているファイルパスを取得する
#deffunc hsed_GetFilePath int nTabID, local mTabPcm, local tci, local path, local hTab
	dim  tci, 7				// TCITEM 構造体
	sdim path, MAX_PATH
	tci(0) = 0x08			// TCIF_PARAM ( lparam )
	
	hsed_getwnd               hTab, HGW_TAB
	newmod    mTabPcm, pcmem, hTab
	PCM_Alloc mTabPcm, 7 * 4
	PCM_Write mTabPcm, varptr(tci), 7 * 4
	
	// TCM_GETITEM : tcitem.lparam = ptr to filepath
	sendmsg hTab, 0x1305, nTabID, PCM_GetPtr( mTabPcm )
	if ( stat == false ) { return "" }					// 失敗
	
	PCM_Read mTabPcm, varptr(tci), 7 * 4
	if ( tci(6) != NULL ) {
		PCM_ReadVM mTabPcm, tci(6), varptr(path), MAX_PATH
	}
	
	delmod mTabPcm
	return path
	
#global

#if 0

	mes hsed_GetHsedPath()
	hsed_getacttabid nTabID
	hsed_GetFilePath nTabID
	mes refstr
	stop
	
#endif

#endif
