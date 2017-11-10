#ifndef IG_VALPTR_MAIN_H
#define IG_VALPTR_MAIN_H

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "hsp3plugin_custom.h"

extern int g_pluginType_valptr;

namespace ValptrCmdId
{
	const int
		Valtype    = 0x100,
		
		NewValptr  = 0x110,
		FromValptr = 0x112,
		
		Assign     = 0x120,
		AssignList = 0x121
	;
};

#endif
