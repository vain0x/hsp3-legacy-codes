// 可変長フレーム

#ifndef __FLEXFRAME_AS__
#define __FLEXFRAME_AS__

#module fframe_mod

#define ctype numrg(%1,%2,%3) (((%2)<=(%1)) && ((%1)<=(%3)))

//------------------------------------------------
// 可変フレームのハンドラ
//------------------------------------------------
#define global OnSizingToFlexFrame(%1=0,%2=0,%3=0x7FFFFFFF,%4=0x7FFFFFFF,%5=wparam,%6=lparam) _OnSizingToFlexFrame %1,%2,%3,%4,%5,%6
#deffunc _OnSizingToFlexFrame int minX, int minY, int maxX, int maxY, int wp, int lp
	
	dupptr lpRect, lp, 4 * 4, vartype("int")
	size(0) = lpRect(2) - lpRect(0)
	size(1) = lpRect(3) - lpRect(1)
	
	// 横幅が最小サイズより小さくなったら
	if ( size(0) < minX ) {
		if ( (wp \ 3) == 1 ) {				// (wparam == 1 || wparam == 4 || wparam == 7)
			lpRect(0) = lpRect(2) - minX
		} else : if ( (wp \ 3) == 2 ) {		// (wparam == 2 || wparam == 5 || wparam == 8)
			lpRect(2) = lpRect(0) + minX
		}
	}
	
	// 縦幅が最小サイズより小さくなったら
	if ( size(1) < minY ) {
		if ( numrg(wp, 3, 5) ) {
			lpRect(1) = lpRect(3) - minY
		} else : if ( numrg(wp, 6, 8) ) {
			lpRect(3) = lpRect(1) + minY
		}
	}
	
	// 横幅が最大サイズより大きくなったら
	if ( size(0) > maxX ) {
		if ( (wp \ 3) == 1 ) {				// (wparam == 1 || wparam == 4 || wparam == 7)
			lpRect(0) = lpRect(2) - maxX
		} else : if ( (wp \ 3) == 2 ) {		// (wparam == 2 || wparam == 5 || wparam == 8)
			lpRect(2) = lpRect(0) + maxX
		}
	}
	
	// 縦幅が最大サイズより大きくなったら
	if ( size(1) > maxY ) {
		if ( numrg(wp, 3, 5) ) {
			lpRect(1) = lpRect(3) - maxY
		} else : if ( numrg(wp, 6, 8) ) {
			lpRect(3) = lpRect(1) + maxY
		}
	}
	return
	
#global

#endif
