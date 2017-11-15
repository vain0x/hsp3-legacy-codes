// GetOwnpath

#ifndef __GET_OWNPATH_AS__
#define __GET_OWNPATH_AS__

#module mod_getownpath

#define MAX_PATH 260

#uselib "kernel32.dll"
#func   GetModuleFileName@mod_getownpath "GetModuleFileNameA" nullptr,int,int

#ifdef _DEBUG
 #define global ctype GetOwnpath(%1) (%1)
#else
 #define global ctype GetOwnpath(%1) _GetOwnpath()
#defcfunc _GetOwnpath
	sdim ownpath, MAX_PATH + 1
	GetModuleFileName varptr(ownpath), MAX_PATH
	
	ownpath = getpath(ownpath, 32)
	ownpath =  strmid(ownpath, 0, strlen(ownpath) - 1)
	return ownpath
#endif

#global

#endif
