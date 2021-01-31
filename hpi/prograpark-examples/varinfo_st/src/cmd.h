// varinfo - cmd header

#ifndef __VARINFO_COMMAND_H__
#define __VARINFO_COMMAND_H__

#include <windows.h>
#include "hsp3plugin.h"

extern void varinfo_st(void);
extern int varinfo_f(void **ppResult);

enum VARINFO {
	VARINFO_MIN  = 0,
	VARINFO_LEN0 = VARINFO_MIN,
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
