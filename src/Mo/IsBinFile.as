#ifndef __IS_BIN_FILE_FUNCTION__
#define __IS_BIN_FILE_FUNCTION__

#module

#enum FT_UNKNOWN = -1
#enum FT_BINARY  = 0
#enum FT_TEXT

//------------------------------------------------
// ファイルがバイナリ形式か調べる 
//------------------------------------------------
#defcfunc IsBinFile str Path
	exist Path
	if ( strsize <= 0 ) { return -1 }		// 分からない
	
	sdim  buf, strsize + 2
	bload Path, buf, strsize			// 読み込む
	bool = FT_TEXT						// 真にセット
	
	// すべて NULL じゃなければ OK
	repeat strsize
		if ( peek( buf, cnt ) == 0 ) {			// NULL 発見
			
			// それ以降も調べる
			for i, cnt + 1, strsize
				if ( peek( buf, i ) != 0 ) {	// まだ有効な値が残っていれば
					bool = FT_BINARY			// バイナリファイルだと言える
					break
				}
			next
			
			break
		}
	loop
	
	sdim buf, 0
	
	return bool		// Binary = 0 : Text = 1 : Unknown = -1
#global

#endif
