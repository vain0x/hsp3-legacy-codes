// 長い文字列特化クラス

#ifndef IG_MODULE_CLASS_LONG_STRING_AS
#define IG_MODULE_CLASS_LONG_STRING_AS

#module MCLongString mString, mStrlen, mCapacity, mExpand

#define BufSize_Default 4096

// @ 一つのバッファを、適宜広げながらたくさんの文字を確保する。

//------------------------------------------------
// [i] 構築
//------------------------------------------------
#define global LongStr_new(%1, %2 = -1, %3 = -1) newmod %1, MCLongString@, %2, %3
#modinit int p2, int p3,  local defsize, local expandSize
	if ( p2 <= 0 ) { defsize = BufSize_Default } else { defsize = p2 }
	if ( p3 <= 0 ) { mExpand = BufSize_Default } else { mExpand = p3 }
	
	mStrlen = 0
	mCapacity = defsize
	sdim mString, mCapacity
	return
	
//------------------------------------------------
// [i] 解体
//------------------------------------------------
#define global LongStr_delete(%1) delmod %1

//##########################################################
//        公開メソッド
//##########################################################
//------------------------------------------------
// 文字列を設定する
//------------------------------------------------
#modfunc LongStr_set str string
	LongStr_clear thismod
	LongStr_add   thismod, string
	return
	
//------------------------------------------------
// 文字列を後ろに追加する
//------------------------------------------------
#modfunc LongStr_add str src, int _lenToAppend
	// local tmpLen
	if ( _lenToAppend ) { tmpLen = _lenToAppend } else { tmpLen = strlen(src) }
//*
	// overflow しないように
	if ( mCapacity <= mStrlen + tmpLen ) {
		LongStr_expand thismod, tmpLen
	}
	
	// 書き込む (poke 側が src を strlen する分無駄がある)
	poke mString, mStrlen, src
	mStrlen += strsize
	assert (strsize == tmpLen)
/*/
	mref tmpSrcPtr, 3	// 黒魔術：src へのポインタを得る
	dupptr tmpSrc, tmpSrcPtr, tmpLen + 1, 2
	LongStr_addv thismod, tmpSrc, tmpLen
//*/
	return
	
#modfunc LongStr_addv var src, int _lenToAppend
	if ( _lenToAppend ) { tmpLen = _lenToAppend } else { tmpLen = strlen(src) }
	
	if ( mCapacity <= mStrlen + tmpLen ) {
		LongStr_expand thismod, tmpLen
	}
	
	// 書き込む ('\0' を含める)
	memcpy mString, src, tmpLen + 1, mStrlen
	mStrlen += tmpLen
	return
	
#define global LongStr_cat       LongStr_add
#define global LongStr_push_back LongStr_add

// 最後に追加された文字列の長さ
#defcfunc LongStr_lengthLastAddition
	return tmpLen

//------------------------------------------------
// 文字を連結する
//------------------------------------------------
#modfunc LongStr_addchar int c
	if ( c == 0 ) { return }
	
	// over-flow しないように
	if ( mCapacity <= mStrlen + 1 ) {
		LongStr_expand thismod, 1
	}
	
	// 書き込む
	wpoke mString, mStrlen, c
	mStrlen ++
	return
	
//------------------------------------------------
// 文字列を後ろから削る
//------------------------------------------------
#modfunc LongStr_erase_back int sizeErase
	if ( sizeErase <= 0 ) { return }
	
	mStrlen -= sizeErase
	if ( mStrlen < 0 ) { mStrlen = 0 }
	
	// 終端文字を置く
	poke mString, mStrlen, 0
	
	return
	
//------------------------------------------------
// バッファを確保する
//------------------------------------------------
#modfunc LongStr_reserve int size
	if ( mCapacity < size ) {
		mCapacity = size + mExpand
		memexpand mString, mCapacity
	}
	return
	
#modfunc LongStr_expand int size
	mCapacity += size + mExpand
	memexpand mString, mCapacity
	return
	
//------------------------------------------------
// 文字列を変数バッファに複写する
//------------------------------------------------
#modfunc LongStr_tobuf var buf
	if ( vartype( buf ) != vartype("str") ) {
		sdim      buf, mStrlen + 1
	} else {
		memexpand buf, mStrlen + 1
	}
	memcpy buf, mString, mStrlen + 1
	return
	
//------------------------------------------------
// [i] 文字列の長さを返す
//------------------------------------------------
#modcfunc LongStr_length
	return mStrlen
	
#define global LongStr_empty LongStr_length
#define global LongStr_size  LongStr_length
#define global LongStr_count LongStr_length

//------------------------------------------------
// 確保済みバッファの大きさを返す
//------------------------------------------------
#modcfunc LongStr_bufSize
	return mCapacity
	
//------------------------------------------------
// 文字列を関数形式で返す(非推奨)
//------------------------------------------------
#modcfunc LongStr_get
	return mString
	
#modcfunc LongStr_dataPtr
	return varptr(mString)
	
#modfunc longstr_dup var s
	dup s, mString
	return
	
//------------------------------------------------
// [i] 初期化
//------------------------------------------------
#modfunc LongStr_clear
;	memset mString, 0, mStrlen
	poke mString
	mStrlen = 0
	return
	
//------------------------------------------------
// [i] 連結
//------------------------------------------------
#modfunc LongStr_chain var mv_from,  local data, local len
	len = LongStr_length(mv_from)
	dupptr data, LongStr_dataPtr(mv_from), len + 1, vartype("str")
	LongStr_addv thismod, data, len
	return
	
//------------------------------------------------
// [i] 複写
//------------------------------------------------
#modfunc LongStr_copy var mv_from
	LongStr_clear thismod
	LongStr_chain thismod, mv_from
	return
	
//------------------------------------------------
// [i] コンテナ交換
//------------------------------------------------
#modfunc LongStr_exchange var mv2, local mvTemp
	LongStr_new  mvTemp
	LongStr_copy mvTemp,  thismod
	LongStr_copy thismod, mv2
	LongStr_copy mv2,     mvTemp
	LongStr_delete mvTemp
	return
	
#global

#endif
