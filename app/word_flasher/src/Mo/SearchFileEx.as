// 指定の検索パスを使って、ファイルを検索する

#ifndef IG_SEARCH_FILE_EX_MODULE_AS
#define IG_SEARCH_FILE_EX_MODULE_AS

#include "MCStrSet.as"

#module SearchFileEx_mod

#uselib "kernel32.dll"
#func   GetFullPathName@SearchFileEx_mod "GetFullPathNameA" sptr,int,int,nullptr

#define MAX_PATH 260

#deffunc SearchFileEx str p1, str fname
	StrSet_new pathset, p1, ";"
	
	sdim filepath, MAX_PATH
	sdim curdir, 320
	
	curdir = dir_cur
	
	repeat StrSet_size(pathset) + 1
		
		if ( cnt == 0 ) {
			path = curdir		// カレントディレクトリでも検索する
		} else {
			path = StrSet_getnext(pathset)		// 次の検索パス
		}
		
		if ( path == "" ) { continue }
		
		chdir path
		exist fname
		if ( strsize >= 0 ) {
			GetFullPathName fname, MAX_PATH, varptr(filepath)
			break
		}
	loop
	
	// カレントディレクトリを元に戻す
	chdir curdir
	
	StrSet_delete pathset
	
	return filepath
	
#global

#if 0

*main
	// "path;path;..." , "filename"
;	SearchFileEx "D:\\D_MyDocuments;D:\\D_MyDocuments\\DProgramFiles\\hsp\\common", "Mo/StrSet.as"
	SearchFileEx "D:\\D_MyDocuments\\DProgramFiles\\hsp\\common;", "Mo/hsptohs.as"
	mes refstr
	stop
	
#endif

#endif
