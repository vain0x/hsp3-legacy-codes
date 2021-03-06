// ini 管理モジュールクラス

#ifndef IG_MODULECLASS_INI_HSP
#define IG_MODULECLASS_INI_HSP

#module MCIni path_

#uselib "kernel32.dll"
#func   WritePrivateProfileString "WritePrivateProfileStringA" sptr,sptr,sptr,sptr
#func   GetPrivateProfileString   "GetPrivateProfileStringA"   sptr,sptr,sptr,int,int,sptr
#cfunc  GetPrivateProfileInt      "GetPrivateProfileIntA"      sptr,sptr,int,sptr

#define true  1
#define false 0
#define null  0
#define int_max 0x7FFFFFFF

#define BufCapacity_Default 1023

//下位互換用
#define global ini_getsv         ini_gets_v
#define global ini_existsKey     ini_exists_key
#define global ini_enumSection   ini_enum_sections
#define global ini_enumKey       ini_enum_keys
#define global ini_removeSection ini_remove_section
#define global ini_removekey     ini_remove_key
#define global ini_getPath       ini_get_path
#define global ini_getArray      ini_get_array
#define global ini_putArray      ini_put_array

#ifdef _DEBUG //警告避け
	sdim stt_stmp
#endif

/**
* INIファイルを開く
*
* @prm this: 新しいインスタンスが入る配列変数。
*	ほかの ini_ 系命令や関数を使うとき、これを最初の引数に指定する。
* @prm path: INIファイルのパス。必ず相対パスで指定すること。
*/
#define global ini_new(%1, %2) newmod %1, MCIni@, %2

#modinit str fname
	path_ = fname
	
	//なければ空ファイルを作っておく
	exist fname
	if ( strsize < 0 ) { bsave fname, path_, 0 }
	return
	
#define global ini_delete(%1) delmod %1

/**
* 文字列データを読み出す (命令形式)
*
* @param (this)
* @prm dst: 値が書き込まれる変数
* @prm sec: セクション名
* @prm key: キー名
* @prm def: 既定文字列 (キーがないときはこれが返される)
*/
#define global ini_gets_v(%1, %2, %3, %4, %5 = "", %6 = 0) \
	ini_gets_v_ %1, %2, %3, %4, %5, %6

#modfunc ini_gets_v_ var dst, str sec, str key, str def, int maxlen_,  \
	local maxlen
	
	maxlen = limit(maxlen_, BufCapacity_Default, int_max)
	do
		if ( maxlen > BufCapacity_Default ) { memexpand stt_stmp, maxlen + 1 }
		
		GetPrivateProfileString sec, key, def, varptr(stt_stmp), maxlen, varptr(path_)
		
		if ( maxlen_ <= 0 && stat == maxlen - 1 ) { // バッファが足りなかった
			maxlen += maxlen / 2
			_continue
		}
	until true
	dst = stt_stmp
	return
	
/**
* 文字列データを読み出す
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @prm def: 既定文字列 (キーがないときはこれが返される)
*/
#define global ctype ini_gets(%1, %2, %3, %4 = "", %5 = BufCapacity_Default@MCIni) \
	ini_gets_(%1, %2, %3, %4, %5)

#modcfunc ini_gets_ str sec, str key, str def, int maxlen
	if ( maxlen > BufCapacity_Default ) { memexpand stt_stmp, maxlen + 1 }
	
	ini_gets_v thismod, stt_stmp, sec, key, def, maxlen
	return stt_stmp
	
/**
* 実数値データを読み出す
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @prm def: 既定値 (キーがないときはこの値が返される)
*/
#modcfunc ini_getd str sec, str key, double def
	GetPrivateProfileString sec, key, str(def), varptr(stt_stmp), 32, varptr(path_)
	return double(stt_stmp)
	
/**
* 整数値データを読み出す
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @prm def: 既定値 (キーがないときはこの値が返される)
*/
#modcfunc ini_geti str sec, str key, int def
	return GetPrivateProfileInt( sec, key, def, varptr(path_) )
	
/**
* 文字列データを書き込む
*
* データを文字列として書き込みます。
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @prm value: 書き込むデータ
*/
#modfunc ini_puts str sec, str key, str data
	WritePrivateProfileString sec, key, "\"" + data + "\"", varptr(path_)
	return
	
/**
* 実数値データを書き込む
*
* 有効数字16桁で書き込まれます。
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @prm value: 書き込むデータ
*/
#modfunc ini_putd str sec, str key, double data
	WritePrivateProfileString sec, key, strf("%.16e", data), varptr(path_)
	return
	
/**
* 整数値データを書き込む
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @prm value: 書き込むデータ
*/
#modfunc ini_puti str sec, str key, int data
	WritePrivateProfileString sec, key, str(data), varptr(path_)
	return
	
/**
* セクションの列挙
* 
* @prm (this)
* @prm dst: セクション名の配列になる配列変数
* @return: セクションの個数
*/
#define global ini_enum_sections(%1, %2, %3 = 0) \
	ini_enum_impl %1, %2, "", %3
	
/**
* キーの列挙
*
* @prm (this)
* @prm dst: キー名の配列になる配列変数
* @prm sec: セクション名
* @return: キーの個数
*/
#define global ini_enum_keys(%1, %2, %3, %4 = 0) \
	ini_enum_impl %1, %2, (%3) + " ", %4
	
// セクション [] のキーを列挙するとき、セクション名の列挙をリクエストしたと誤認されてしまわないように、名前に空白をくっつけている。この空白は無視されるので問題ない。

#modfunc ini_enum_impl array dst, str sec_, int maxlen_,  \
	local maxlen, local pSec, local sec
	
	maxlen = limit(maxlen_, BufCapacity_Default, int_max)
	
	if ( sec_ == "" ) { pSec = null } else { sec = sec_ : pSec = varptr(sec) }
	do
		if ( maxlen > BufCapacity_Default ) { memexpand stt_stmp, maxlen + 1 }
		
		GetPrivateProfileString pSec, null, null, varptr(stt_stmp), maxlen, varptr(path_)
		
		if ( maxlen_ <= 0 && stat == maxlen - 2 ) {		// バッファが足りなかった
			maxlen += maxlen / 2						// 1.5倍に広げて再チャレンジ
			_continue
		}
	until true
	
	SplitByNull dst, stt_stmp, stat
	return ;stat
	
// cnv: '\0' 区切り文字列 -> 配列
#deffunc SplitByNull@MCIni array dst, var buf, int maxsize,  local idx
	idx = 0
	sdim dst
	repeat
		getstr dst(cnt), buf, idx, , maxsize
	;	logmes dst(cnt)
		idx += strsize + 1
		if ( peek(buf, idx) == 0 ) { break }		// '\0' の2連続は終端フラグ
	loop
	return length(dst) - (idx <= 1)			// 要素数; ただし dst[0] が空のとき 0
	
#ifdef _DEBUG
/**
* すべてのキー・値の対を列挙する。 (デバッグ用)
*/
#modfunc ini_dbglog  local buf
 	ini_dbglogv thismod, buf
	logmes "\n(ini_dbglog): @" + path_
 	logmes buf
 	return
 
#modfunc ini_dbglogv var buf,  \
	local seclist, local sec, local keylist, local key, local stmp
	
	ini_enum_sections thismod, seclist
	repeat stat : sec = seclist(cnt)
		buf += strf("[%s]\n", sec)
		
		ini_enum_keys thismod, keylist, sec
		repeat stat : key = keylist(cnt)
			ini_gets_v thismod, stmp, sec, key, , BufCapacity_Default
			buf += "\t" + key + " = \"" + stmp + "\"\n"
		loop
		
	loop
	return
#else
 #define global ini_dbglog :
 #define global ini_dbglogv :
#endif //defined(_DEBUG)

/**
* キーが存在するか？
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @return: 指定されたキーがあれば真(0以外)を、なければ偽(0)を返す。
*/

#modcfunc ini_exists_key str sec, str key
	GetPrivateProfileString sec, key, "__", varptr(stt_stmp), 2, varptr(path_)
	return ( stat < 2 )
	
/*
GetPrivateProfileString に 既定値("__"), nSize(2) を与えるとき、
キーが存在すれば返値 1 or 0、しなければ 2 となる。
//*/

/**
* セクションを除去する
*
* @prm (this)
* @prm sec: セクション名
*/
#modfunc ini_remove_section str sec
	WritePrivateProfileString sec, null, null, varptr(path_)
	return
	
/**
* キーを除去する
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
*/
#modfunc ini_remove_key str sec, str key
	WritePrivateProfileString sec, key, null, varptr(path_)
	return
	
/**
* INIファイルパス
*
* @prm (this)
* @return: ini_new で指定されたパス
*/
#modcfunc ini_get_path
	return path_
	
#global

#module

#enum global IniValtype_None = 0
#enum global IniValtype_Indeterminate = 0
#enum global IniValtype_String = 2			// vartype の値と一致
#enum global IniValtype_Double
#enum global IniValtype_Int
#enum global IniValtype_MAX

#define stt_stmp stt_stmp@MCIni

/**
* 指定した型のデータを読み出す
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @prm def: 既定文字列 (キーがないときはこれが返される)
*/
#define global ctype ini_get(%1, %2, %3, %4 = "", %5 = 0) \
	ini_get_( %1, %2, %3, str(%4), %5 )

#defcfunc ini_get_ var self, str sec, str key, str def, int valtype
	ini_gets_v self, stt_stmp, sec, key, def
	return CastFromString@MCIni( stt_stmp, valtype )
	
/**
* 指定した型のデータを書き込む
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @prm value: 書き込むデータ
* @param valtype: データの型 (省略時は、value の型が使用されます)
*/
#define global ini_put(%1, %2, %3, %4, %5 = 0) \
	stt_tmp@MCIni = (%4) :\
	ini_putv %1, %2, %3, stt_tmp@MCIni, %5

#deffunc ini_putv var self, str sec, str key, var data, int valtype_,  local valtype
	if ( valtype_ ) { valtype = valtype_ } else { valtype = ValtypeByString@MCIni(str(data)) }
	switch ( valtype )
		case IniValtype_String: ini_puts self, sec, key,       (data) : swbreak
		case IniValtype_Double: ini_putd self, sec, key, double(data) : swbreak
		case IniValtype_Int:    ini_puti self, sec, key,    int(data) : swbreak
	swend
	return
	
// 文字列が表すデータの型を推定する
// 16進数形式の整数値などには未対応
#defcfunc ValtypeByString@MCIni str data
	if ( data == int(data) ) { return IniValtype_Int }
	if ( double(data) != 0 ) {
		if ( IsDoubleImpl@MCIni(data) ) { return IniValtype_Double }
	}
	return IniValtype_String
	
#defcfunc IsDoubleImpl@MCIni str data_, local data
	data = data_
	return ( instr(data, , ".") >= 0 || instr(data, , "e") >= 0 )
	
// 文字列から指定した型に型変換する
#defcfunc CastFromString@MCIni str data, int valtype_,  local valtype
	if ( valtype_ ) { valtype = valtype_ } else { valtype = ValtypeByString@MCIni(stt_stmp) }
	switch ( valtype )
		case IniValtype_String: return       (data)
		case IniValtype_Double: return double(data)
		case IniValtype_Int:    return    int(data)
	swend
#global

#module

#define ctype IniKeyArrayIdx(%1, %2) ((%1) + "#" + (%2))
#define ctype IniKeyMember(%1, %2) ((%1) + "." + (%2))

/**
* 配列データを読み出す
*
* ini_put_array 命令によって書き込んだ、配列データを読み込みます。
*
* @prm (this)
* @prm dst: 値が書き込まれる配列変数
* @prm sec: セクション名
* @prm key: 配列の名前
*/
#deffunc ini_get_array var self, array dst, str sec, str key,  \
	local len, local valtype
	
	len     = ini_geti( self, sec, IniKeyMember(key, "$length"),  0 )
	valtype = ini_geti( self, sec, IniKeyMember(key, "$valtype"), IniValtype_Indeterminate )
	
	if ( valtype == IniValtype_Indeterminate ) {
		valtype = ValtypeByString@MCIni( ini_gets( self, sec, IniKeyArrayIdx(key, 0) ) )
	}
	
	dimtype dst, valtype, len
	repeat len
		dst(cnt) = ini_get( self, sec, IniKeyArrayIdx(key, cnt), , valtype )
	loop
	return
	
/**
* 配列データを書き込む
*
* 配列変数は、str, double, int 型の1次元配列変数にかぎります。
* データの読み込みには ini_get_array を使用してください。
*
* @prm (this)
* @prm sec: セクション名
* @prm key: キー名
* @prm arr: 書き込む配列変数
*/
#deffunc ini_put_array var self, str sec, str key, array src,  \
	local len, local valtype
	
	len     = length(src)
	valtype = vartype(src)
	
	ini_puti self, sec, IniKeyMember(key, "$length"),  len
	ini_puti self, sec, IniKeyMember(key, "$valtype"), valtype
	
	repeat len
		ini_putv self, sec, IniKeyArrayIdx(key, cnt), src(cnt), valtype
	loop
	return
	
#global

	sdim stt_stmp@MCIni, BufCapacity_Default@MCIni + 1

#endif
