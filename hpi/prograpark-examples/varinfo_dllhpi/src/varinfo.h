// varinfo dllhpi

#ifndef __VARINFO_DLLHPI_H__
#define __VARINFO_DLLHPI_H__

#include <windows.h>
#include "hsp3plugin.h"

EXPORT int WINAPI varinfo(PVal *pval, int type, HSPEXINFO *pExinfo);

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
