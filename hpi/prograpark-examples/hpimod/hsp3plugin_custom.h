// hsp3plugin Šg’£ƒwƒbƒ_

#ifndef IG_HSP3PLUGIN_CUSTOM_H
#define IG_HSP3PLUGIN_CUSTOM_H

#include <windows.h>
#include "hsp3plugin.h"		// ƒpƒX‚ð’Ê‚·•K—v‚ª‚ ‚é

#ifdef _DEBUG
# include <stdio.h>
# include <stdarg.h>
# define DbgArea /* empty */
# define dbgout(message, ...) msgboxf<void>(message, __VA_ARGS__)//MessageBoxA(0, message, "hpi", MB_OK)
template<class T>
T msgboxf(const char* sFormat, ...)
{
	static char stt_buffer[1024];
	va_list arglist;
	va_start( arglist, sFormat );
	vsprintf_s( stt_buffer, 1024 - 1, sFormat, arglist );
	va_end( arglist );
	MessageBoxA( NULL, stt_buffer, "hpi", MB_OK );
}
#else
# define DbgArea if ( false )
# define dbgout(message, ...) ((void)0)
template<class T> T msgboxf(const char* sFormat, ...) {}
#endif

//##############################################################################
//                éŒ¾•”
//##############################################################################

//##########################################################
//    Œ^éŒ¾
//##########################################################
typedef unsigned short* label_t;
typedef int vartype_t;

typedef void (*operator_t)(PDAT*, const void*);		// HspVarProc ‚Ì‰‰ŽZŠÖ”

//##########################################################
//    ŠÖ”éŒ¾
//##########################################################
static HspVarProc* GetHvp( vartype_t flag )
{
	return exinfo->HspFunc_getproc( flag );
}

static HspVarProc* SeekHvp( const char* name )
{
	return exinfo->HspFunc_seekproc( name );
}

static PVal* code_get_var()
{
	PVal* pval;
	code_getva(&pval);
	return pval;
}

#endif
