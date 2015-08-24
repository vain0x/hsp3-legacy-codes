#ifndef __FLEXFRAME_AS__
#define __FLEXFRAME_AS__

#module

#define ctype numrg(%1,%2,%3) (((%2)<=(%1)) && ((%1)<=(%3)))

// 可変フレームのハンドラ
#define global OnSizingToFlexFrame(%1,%2,%3=wparam,%4=lparam) _OnSizingToFlexFrame %1,%2,%3,%4
#deffunc _OnSizingToFlexFrame int cx, int cy, int wp, int lp
	
	dupptr lpRect, lp, 4 * 4, vartype("int")
	size(0) = lpRect(2) - lpRect(0)
	size(1) = lpRect(3) - lpRect(1)
	
	if ( size(0) <= cx ) {
		if ( (wp \ 3) == 1 ) {			// (wparam == 1 || wparam == 4 || wparam == 7)
			lpRect(0) = lpRect(2) - cx
		} else : if ( (wp \ 3) == 2 ) {	// (wparam == 2 || wparam == 5 || wparam == 8)
			lpRect(2) = lpRect(0) + cx
		}
	}
	if ( size(1) <= cy ) {
		if ( numrg(wp, 3, 5) ) {
			lpRect(1) = lpRect(3) - cy
		} else : if ( numrg(wp, 6, 8) ) {
			lpRect(3) = lpRect(1) + cy
		}
	}
	return
	
#global

#endif
