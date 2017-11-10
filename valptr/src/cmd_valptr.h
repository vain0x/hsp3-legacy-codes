#ifndef IG_VALPTR_COMMAND_H
#define IG_VALPTR_COMMAND_H

#include <windows.h>
#include <stack>

#include "hsp3plugin_custom.h"

extern void FromValptr();

extern int Valtype(void** ppResult);

extern int NewValptr(void** ppResult);
extern int FromValptr(void** ppResult);
//extern int DupValptr(void** ppResult);

extern int Assign(void** ppResult);

extern void TermValptr();

//------------------------------------------------
// 返値設定関数
//------------------------------------------------
template<class T, int T_vartype>
int SetReffuncResult_core(void** ppResult, const T& value)
{
	static T stt_value;
	
	stt_value = value;
	*ppResult = &stt_value;
	return T_vartype;
}

//extern int SetReffuncResult(void** ppResult, label_t lb);
//extern int SetReffuncResult(void** ppresult, char* s);
//extern int SetReffuncResult(void** ppResult, double n);
extern int SetReffuncResult(void** ppResult, int n);

//#include "strbuf.h"
// strbuf.h 対応マクロ
#define sbAlloc  hspmalloc
#define sbFree   hspfree
#define sbExpand hspexpand

#endif
