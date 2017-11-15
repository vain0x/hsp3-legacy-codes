#ifndef ___DLLMAIN_H__
#define ___DLLMAIN_H__

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "hsp3plugin.h"

EXPORT void WINAPI hsp3hpi_init(HSP3TYPEINFO *info);

#endif
