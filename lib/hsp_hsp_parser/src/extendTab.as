// タブ文字展開モジュール

#ifndef IG_EXTEND_TAB_AS
#define IG_EXTEND_TAB_AS

#module

//------------------------------------------------
// タブ文字を展開する
// 
// @prm src     : 展開元の文字列
// @prm tabsize : タブ幅
// @prm offset  : src の前にあると仮定する byte 数
//------------------------------------------------
#defcfunc extendTab str src_, int tabsize, int offset,  local idx, local iFound, local dst, local dstlen, local size
	idx    = 0
	src    = src_
	iFound = 0
	dstlen = 0
	sdim dst
	
	repeat
		iFound = instr( src, idx, "\t" )
		if ( iFound < 0 ) {
			dst += strmid( src, idx, strlen(src) - idx )
			break
		}
		
		size    = ( tabsize - ((offset + dstlen + iFound) \ tabsize) )
		dst    += strmid( src, idx, iFound ) + strf("%" + size + "s", "")
		dstlen += iFound + size
		idx    += iFound + 1
	loop
	
	return dst

#global

#if 0

	clmn = "012345678901234567890123456789"
	text = "str	length		for		a	o."
	
	sdim buf, 3200
	buf  = strf("%s\n%s\n%s\n\n",   clmn, text, extendTab(text, 8, 0))
	buf += strf("%s\n %s\n %s\n\n", clmn, text, extendTab(text, 8, 1))
	
	objmode 2
	objsize ginfo_winx, ginfo_winy
	mesbox buf
	stop
	
#endif

#endif
