// var_modcmd - public header

#ifndef IG_VAR_MODCMD_INTERFACE_H
#define IG_VAR_MODCMD_INTERFACE_H

#include "hsp3plugin_custom.h"

extern int g_pluginModcmd;	// プラグインID

EXPORT void WINAPI hpi_modcmd( HSP3TYPEINFO* info );

#endif
