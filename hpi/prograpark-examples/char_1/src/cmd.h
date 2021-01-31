// char - command header

#ifndef __CHAR_COMMAND_H__
#define __CHAR_COMMAND_H__

#include <windows.h>
#include <memory>
#include "hsp3plugin.h"

#include "dllmain.h"

extern void char_st(void);
extern int char_f(void **ppResult);

template<typename T>
int SysvarRes(void **ppResult, T& val, int vflag)
{
	static std::unique_ptr<T> stt_result;

	stt_result.reset(new T(val));
	*ppResult = stt_result.get();
	return vflag;
}

#endif
