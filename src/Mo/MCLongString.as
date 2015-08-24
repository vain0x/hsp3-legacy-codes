// 長い文字列特化クラス

#ifndef __MODULE_CLASS_LONG_STRING_AS__
#define __MODULE_CLASS_LONG_STRING_AS__

#module MCLongStr mString, mStrlen, mStrSize, mExpand

#define mv modvar MCLongStr@
#define DEFAULT_SIZE 3200

//------------------------------------------------
// コンストラクタ
//------------------------------------------------
#modinit int p2, int p3, local defsize, local expandSize
	if ( p2 <= 0 ) { defsize = DEFAULT_SIZE } else { defsize = p2 }
	if ( p3 <= 0 ) { mExpand = DEFAULT_SIZE } else { mExpand = p3 }
	
	sdim mString, defsize
	mStrlen  = 0
	mStrSize = defsize
	return
	
//------------------------------------------------
// 文字列をクリアする
//------------------------------------------------
#modfunc LongStr_clear
	memset mString, 0, mStrlen
	mStrlen = 0
	return
	
//------------------------------------------------
// 文字列を後ろに追加する
//------------------------------------------------
#modfunc LongStr_cat str p2, int p3
	if ( p3 ) { len = p3 } else { len = strlen(p2) }
	
	// overflow しないように
	if ( ( mStrSize - mStrLen ) <= len ) {	// 足りなければ
		mStrSize += len + mExpand
		memexpand mString, mStrSize			// 拡張する
	}
	
	// 書き込む
	poke mString, mStrlen, p2
	mStrlen += strsize
	return
	
//------------------------------------------------
// 文字列を関数形式で返す( 非推奨 )
//------------------------------------------------
;#defcfunc LongStr_get mv
;	return mString
	
//------------------------------------------------
// 文字列の長さを返す
//------------------------------------------------
#defcfunc LongStr_len mv
	return mStrlen
	
//------------------------------------------------
// 文字列を変数バッファにコピーする
//------------------------------------------------
#modfunc LongStr_tobuf var buf
	if ( vartype( buf ) != vartype("str") ) {
		sdim      buf, mStrlen + 1
	} else {
		memexpand buf, mStrlen + 1
	}
	memcpy buf, mString, mStrlen
	poke   buf, mStrlen, 0
	return
	
#global

#endif
