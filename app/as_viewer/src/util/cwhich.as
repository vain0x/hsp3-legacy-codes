#ifndef IG_CTYPE_WHICH_MODULE_AS
#define IG_CTYPE_WHICH_MODULE_AS

// ctype which
// (2015/02/22) use opex.hpi instead.

#module cwhich_module

///一般的な場合
/*
#define global ctype cwhich(%1=1,%2=1,%3=0,%4=0) cwhich_core(%1, str(%2), str(%3), %4)
#defcfunc cwhich_core int p1, str TrueValue, str FalseValue, int p4, local sRet
	if ( p1 ) { sRet = TrueValue } else { sRet = FalseValue }
	if ( p4 ) {	// 戻り値の型を指定した場合
		if ( p4 == 2 ) { return sRet         }	// 文字列
		if ( p4 == 3 ) { return double(sRet) }	// 実数値
		if ( p4 == 4 ) { return int(sRet)    }	// 整数値
	}
	if ( sRet == int(sRet) ) { return int(sRet) }
	if ( sRet == double(sRet) && instr(sRet, 0, ".") > 0 ) { return double(sRet) }
	return sRet
//*/
#define global which !!"deprecated: use cond_<type>"!!
#ifdef __userdef__
 #undef cwhich_int
 #define global cwhich_int cond_i
#endif

///conditional operator
#defcfunc cond_i int cond, int then_, int else_
	if (cond) { return then_ } else { return else_ }

#defcfunc cond_d int cond, double then_, double else_
	if (cond) { return then_ } else { return else_ }
	
#define global ctype cond_s(%1, %2 = "", %3 = "") cond_s_@cwhich_module(%1, %2, %3)
#defcfunc cond_s_@cwhich_module int cond, str then_, str else_
	if (cond) { return then_ } else { return else_ }
	
#global

#endif
