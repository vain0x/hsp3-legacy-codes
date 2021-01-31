// GetVarinfo - main header

#ifndef __DLLMAIN_H__
#define __DLLMAIN_H__

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include "hsp3plugin.h"

// 配列要素の番号
enum VARINFO {
	VARINFO_LEN0 = 0,
	VARINFO_LEN1,
	VARINFO_LEN2,
	VARINFO_LEN3,
	VARINFO_LEN4,
	VARINFO_FLAG,
	VARINFO_MODE,
	VARINFO_PTR,
	VARINFO_MAX
};

#endif
