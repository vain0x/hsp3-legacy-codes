// hsed utility module

#ifndef __HSED_UTILITY_MODULE_AS__
#define __HSED_UTILITY_MODULE_AS__

#include "hsedsdk.as"
#include "MCProcMemory.as"

#module hsedutil

//##################################################################################################
//        定数・マクロ
//##################################################################################################
#define true  1
#define false 0
#define NULL  0
#define MAX_PATH 260

#define hIF hIF@hsedsdk

//------------------------------------------------
// Win32 API 関数群
//------------------------------------------------
#uselib "psapi.dll"
#func   EnumProcessModules@hsedutil  "EnumProcessModules"   int,sptr,int,sptr
#func   GetModuleFileNameEx@hsedutil "GetModuleFileNameExA" int,int,sptr,int

//##################################################################################################
//        [define] 命令群
//##################################################################################################
//------------------------------------------------
// スクリプトエディタのフルパスを得る
//------------------------------------------------
#defcfunc hsed_GetHsedPath local hHsed, local mHsedPcm, local path, local hModule, local retSize
	sdim path, MAX_PATH
	
	hsed_getwnd       hHsed, HGW_MAIN
	PCM_new mHsedPcm, hHsed
	
	EnumProcessModules  PCM_hProc(mHsedPcm), varptr(hModule), 4, varptr(retSize)
	GetModuleFileNameEx PCM_hProc(mHsedPcm), hModule, varptr(path), MAX_PATH
	
	PCM_delete mHsedPcm
	return path
	
//------------------------------------------------
// 指定タブが開いているファイルのパスを取得する
//------------------------------------------------
#deffunc hsed_GetFilePath int nTabID,  local path	;, local mTabPcm, local tci, local path, local hTab
	hsed_getpath path, nTabID
	return path
/*
	dim  tci, 7				// TCITEM 構造体
	sdim path, MAX_PATH
	tci(0) = 0x08			// TCIF_PARAM ( lparam )
	
	hsed_getwnd        hTab, HGW_TAB
	PCM_new   mTabPcm, hTab
	PCM_alloc mTabPcm, 7 * 4
	PCM_write mTabPcm, varptr(tci), 7 * 4
	
	// TCM_GETITEM : tcitem.lparam = ptr to filepath
	sendmsg hTab, 0x1305, nTabID, PCM_getPtr( mTabPcm )
	if ( stat == false ) { return "" }					// 失敗
	
	PCM_read mTabPcm, varptr(tci), 7 * 4
	if ( tci(6) != NULL ) {
		PCM_readVM mTabPcm, tci(6), varptr(path), MAX_PATH
	}
	
	PCM_delete mTabPcm
	return path
//*/

//------------------------------------------------
// アクティブな FootyID を返す
//------------------------------------------------
#defcfunc hsed_activeFootyID  local fID
	hsed_getactfootyid fID
	return fID
	
//------------------------------------------------
// アクティブなFootyのテキストを取得
//------------------------------------------------
#deffunc hsed_getActText var p1,  local nActFootyID, local nTextLength
	hsed_capture
	if ( stat ) { return 1 }
	
	sendmsg hIF, _HSED_GETACTFOOTYID@hsedsdk
	nActFootyID = stat
	
	hsed_GetTextLength nTextLength, nActFootyID
	if ( stat ) { return }
	if ( nTextLength == 0 ) {
		p1 = ""
	} else {
		hsed_gettext p1, nActFootyID
	}
	return
	
//------------------------------------------------
// アクティブなFootyのテキストを変更
//------------------------------------------------
#deffunc hsed_setActText str sText, local nActFootyID
	hsed_capture
	if ( stat ) { return 1 }
	
	sendmsg hIF, _HSED_GETACTFOOTYID@hsedsdk
	nActFootyID = stat

	hsed_settext nActFootyID, sText
	return
	
//------------------------------------------------
// キャレットの位置を取得
// @ base 1 ( 行頭 )
//------------------------------------------------
#deffunc hsed_getCaretPos var p1, int nFootyID
	hsed_capture
	if ( stat ) { return 1 }
	sendmsg hIF, _HSED_GETCARETPOS@hsedsdk, nFootyID
	if ( stat <= 0 ) { return 1 }
	p1 = stat
	return 0
	
//------------------------------------------------
// キャレットの位置を取得
// @ base 1 ( スクリプト先頭 )
//------------------------------------------------
#deffunc hsed_getCaretThrough var p1, int nFootyID
	hsed_capture
	if stat : return 1
	sendmsg hIF, _HSED_GETCARETTHROUGH@hsedsdk, nFootyID
	if stat <= 0 : return 1
	p1 = stat
	return 0
	
//------------------------------------------------
// 水平ルーラーの位置を取得
// @ base 1 ( 行頭 )
//------------------------------------------------
#deffunc hsed_getCaretVPos var p1, int nFootyID
	hsed_capture
	if stat : return 1
	sendmsg hIF, _HSED_GETCARETVPOS@hsedsdk, nFootyID
	if stat < 0 : return 1
	p1 = stat
	return 0
	
//------------------------------------------------
// キャレットのある行の行番号を取得
//------------------------------------------------
#deffunc hsed_getCaretLine var p1, int nFootyID
	hsed_capture
	if stat : return 1
	sendmsg hIF, _HSED_GETCARETLINE@hsedsdk, nFootyID
	
	if ( stat <= 0 ) {
		return 1
	} else {
		p1 = stat
		return 0
	}
	
//------------------------------------------------
// 指定位置にキャレットの位置を設定
// @ base 1 ( 行頭 )
//------------------------------------------------
#deffunc hsed_setCaretPos int nFootyID, int nCaretpos
	hsed_capture
	if stat : return 1
	sendmsg hIF, _HSED_SETCARETPOS@hsedsdk, nFootyID, nCaretpos
	return

//------------------------------------------------
// 指定位置にキャレットの位置を変更
// @ base 1 ( スクリプト先頭 )
//------------------------------------------------
#deffunc hsed_setCaretThrough int nFootyID, int nCaretthrough
	hsed_capture
	if stat : return 1
	sendmsg hIF, _HSED_SETCARETTHROUGH@hsedsdk, nFootyID, nCaretthrough
	return
	
//------------------------------------------------
// 指定した行番号にキャレットの位置を変更
//------------------------------------------------
#deffunc hsed_setCaretLine int nFootyID, int nLine
	hsed_capture
	if stat : return 1
	sendmsg hIF, _HSED_SETCARETLINE@hsedsdk, nFootyID, nLine
	return
	
#global

//##################################################################################################
//        サンプル・スクリプト
//##################################################################################################
#if 0

	mes hsed_GetHsedPath()
	hsed_getacttabid nTabID
	hsed_GetFilePath nTabID
	mes refstr
	stop
	
#endif

#endif
