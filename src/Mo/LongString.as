// Long String Module

#ifndef __LONG_STRING_MODULE_AS__
#define __LONG_STRING_MODULE_AS__

#module longstr mString, mStrlen, mStrSize

// コンストラクタ
#modinit
	sdim mString, 6400
	mStrlen  = 0
	mStrSize = 6400
	return
	
// 文字列を後ろに追加する
#modfunc LongStr_cat str p2, int p3
	if ( p3 ) { len = p3 } else { len = strlen(p2) }
	
	// overflow しないように
	if ( ( mStrSize - mStrLen) <= len ) {	// 足りなければ
		mStrSize += len + 6400
		memexpand mString, mStrSize			// 拡張する
	}
	
	// 書き込む
	poke mString, mStrlen, p2
	mStrlen += strsize
	return
	
// 文字列を関数形式で返す
#defcfunc LongStr_get modvar longstr@
	return mString
	
// 文字列の長さを返す
#defcfunc LongStr_len modvar longstr@
	return mStrlen
	
// 文字列を変数バッファにコピーする
#modfunc LongStr_tobuf var buf
	memexpand buf, mStrlen + 1
	memcpy    buf, mString, mStrlen
	poke      buf, mStrlen, 0
	return
	
#global

#endif
