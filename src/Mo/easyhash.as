// 簡易ハッシュ関数

#ifndef __EASY_HASH_FUNCTION_AS__
#define __EASY_HASH_FUNCTION_AS__

#module easyhash_mod

// 文字列からハッシュ値を生成する( 適当アルゴリズム )
#defcfunc EasyHash str p1, int p2, int p3, local hashmax
	if ( p2 == 0 ) { len     = strlen(p1) } else { len     = p2 }
	if ( p3 <= 0 ) { hashmax = 0x7FFFFFFF } else { hashmax = p3 }
	
	sdim text, len + 1
	text = p1
	hash = len << 1
	
	repeat len
		c     = peek(text, cnt)
		hash += c << cnt - (c & 1)
	loop
	
	return hash \ hashmax
	
#global

#endif

#if 0
#include "Mo/MCLongString.as"

	randomize
	newmod ls, MCLongStr
	dim total, HASHMAX
	
	repeat 10000
		n = cnt * rnd(200)
		hash = EasyHash(""+ n)
		LongStr_cat ls, strf("%11d : ", n) + hash +"\n"
		total(hash) ++
	loop
	noteunsel
	
	LongStr_cat ls, "\n\n########[ TOTAL ]########\n"
	repeat HASHMAX
		LongStr_cat ls, strf("%2d : ", cnt) + strf("%3d", total(cnt)) +"\n"
	loop
	
	LongStr_tobuf ls, notebuf
	objmode 2
	mesbox notebuf, ginfo(12), ginfo(13)
	stop
	
#endif
