// ctype which

#ifndef __CTYPE_WHICH_MODULE_AS__
#define __CTYPE_WHICH_MODULE_AS__

#module cwhich_module

#define global ctype cwhich(%1=1,%2=1,%3=0,%4=0) cwhich_core(%1,str(%2),str(%3),%4)
#defcfunc cwhich_core int p1, str TrueValue, str FalseValue, int p4, local sRet
	if (p1) { sRet = TrueValue } else { sRet = FalseValue }
	if (p4) {	// 戻り値の型を指定した場合
		if (p4 == 2) { return sRet         }	// 文字列
		if (p4 == 3) { return double(sRet) }	// 実数値
		if (p4 == 4) { return int(sRet)    }	// 整数値
	}
	if (sRet == int(sRet)) { return int(sRet) }
	if (sRet == double(sRet) && instr(sRet, 0, ".") != -1) { return double(sRet) }
	return sRet
	
#global

#endif
