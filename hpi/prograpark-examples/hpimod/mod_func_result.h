// ä÷êîÇÃï‘ílÇÃèàóù

#ifndef IG_MODULE_HPIMOD_FUNC_RESULT_H
#define IG_MODULE_HPIMOD_FUNC_RESULT_H

#include "hsp3plugin_custom.h"

//##########################################################
//        ä÷êîêÈåæ
//##########################################################
template<class TResult>
int SetFuncResult( void** ppResult, const TResult& src, int vflag )
{
	static TResult stt_result;
	
	stt_result = src;
	*ppResult = &stt_result;
	return vflag;
}

#define FTM_SetFuncResult(_tResult, _vartype) \
	static int SetFuncResult( void** ppResult, const _tResult& src )	\
	{   return SetFuncResult( ppResult, src, _vartype );   }

FTM_SetFuncResult( label_t,   HSPVAR_FLAG_LABEL );
FTM_SetFuncResult( double,    HSPVAR_FLAG_DOUBLE );
FTM_SetFuncResult( int,       HSPVAR_FLAG_INT );
FTM_SetFuncResult( FlexValue, HSPVAR_FLAG_STRUCT );

namespace hpimod
{
	static char stt_result_string[2048];
}

static int SetFuncResultString( void** ppResult )
{
	*ppResult = hpimod::stt_result_string;
	return HSPVAR_FLAG_STR;
}

static int SetFuncResult( void** ppResult, const char*& src )
{
	strcpy_s( hpimod::stt_result_string, src );
	return SetFuncResultString( ppResult );
}

#endif
