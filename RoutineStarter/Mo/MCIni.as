// ini 管理モジュールクラス

#ifndef IG_MODULECLASS_INI_AS
#define IG_MODULECLASS_INI_AS

#module MCIni mfname

#uselib "kernel32.dll"
#func   WritePrivateProfileString "WritePrivateProfileStringA" sptr,sptr,sptr,sptr
#func   GetPrivateProfileString   "GetPrivateProfileStringA"   sptr,sptr,sptr,int,int,sptr
#cfunc  GetPrivateProfileInt      "GetPrivateProfileIntA"      sptr,sptr,int,sptr

#define true  1
#define false 0
#define null  0

#enum global IniValtype_None = 0
#enum global IniValtype_Indeterminate = 0
#enum global IniValtype_String = 2			// vartype の値と一致
#enum global IniValtype_Double
#enum global IniValtype_Int
#enum global IniValtype_MAX

#define ctype IniKeyArrayIdx(%1, %2) ((%1) + "#" + (%2))
#define ctype IniKeyMember(%1, %2) ((%1) + "." + (%2))

// @static
	stt_stmp = ""

//**********************************************************
//        構築・解体
//**********************************************************
#define global ini_new(%1, %2) newmod %1, MCIni@, %2
#modinit str fname
	mfname = fname
	
	exist fname
	if ( strsize < 0 ) { bsave fname, mfname, 0 }	// 空ファイルで作っておく
	return
	
#define global ini_delete(%1) delmod %1
	
//**********************************************************
//        データ読み込み
//**********************************************************
#define global ctype ini_get(%1, %2, %3, %4 = "", %5 = 0) ini_get_( %1, %2, %3, str(%4), %5 )

//------------------------------------------------
// 文字列 ( sttm-form )
// 
// @prm (this)
// @prm dst : 受け取り変数
// @prm sec : セクション名
// @prm key : キー名
// @prm def : 既定文字列 ( キーが存在しないとき )
// @prm max : 最大文字列長
//------------------------------------------------
#define global ini_getsv(%1, %2, %3, %4, %5 = "", %6 = 1200) ini_getsv_ %1, %2, %3, %4, %5, %6
#modfunc ini_getsv_ var dst, str sec, str key, str def, int maxlen
	if ( maxlen > 1200 ) { memexpand stt_stmp, maxlen + 1 }
	
	GetPrivateProfileString sec, key, def, varptr(stt_stmp), maxlen, varptr(mfname)
	
	dst = stt_stmp
	return
	
//------------------------------------------------
// 文字列 ( func-form )
// 
// @prm (ini_getsv: dst 以外)
//------------------------------------------------
#define global ctype ini_gets(%1, %2, %3, %4 = "", %5 = 1200) ini_gets_(%1, %2, %3, %4, %5)
#modcfunc ini_gets_ str sec, str key, str def, int maxlen
	if ( maxlen > 1200 ) { memexpand stt_stmp, maxlen + 1 }
	
	ini_getsv thismod, stt_stmp, sec, key, def, maxlen
	return stt_stmp
	
//------------------------------------------------
// 実数 ( func-form )
//------------------------------------------------
#modcfunc ini_getd str sec, str key, double def
	GetPrivateProfileString sec, key, str(def), varptr(stt_stmp), 32, varptr(mfname)
	return double(stt_stmp)
	
//------------------------------------------------
// 整数 ( func-form )
//------------------------------------------------
#define global ctype ini_geti(%1, %2, %3, %4 = 0) ini_geti_( %1, %2, %3, %4 )
#modcfunc ini_geti_ str sec, str key, int def
	return GetPrivateProfileInt( sec, key, def, varptr(mfname) )
	
//------------------------------------------------
// 配列
// 
// @prm (this)
// @prm dst : 受け取り変数 (配列として初期化される)
// @prm sec : セクション名
// @prm key : キー名 (配列名)
//------------------------------------------------
#modfunc ini_getArray array dst, str sec, str key,  local len, local valtype
	len     = ini_geti( thismod, sec, IniKeyMember(key, "$length"),  0 )
	valtype = ini_geti( thismod, sec, IniKeyMember(key, "$valtype"), IniValtype_Indeterminate )
	
	if ( valtype == IniValtype_Indeterminate ) {
		valtype = ValtypeByString( ini_gets( thismod, sec, IniKeyArrayIdx(key, 0) ) )	// [0] の型で判定する
	}
	
	dimtype dst, valtype, len
	
	repeat len
		dst(cnt) = ini_get( thismod, sec, IniKeyArrayIdx(key, cnt), , valtype )
	loop
	
	return
	
//------------------------------------------------
// any ( func-form )
//------------------------------------------------
// ini_get
#modcfunc ini_get_ str sec, str key, str def, int valtype_,  local valtype
	ini_getsv thismod, stt_stmp, sec, key, def
	return CastFromString( stt_stemp, valtype_ )
	
//**********************************************************
//        データ書き込み
//**********************************************************
//------------------------------------------------
// 文字列
//------------------------------------------------
#modfunc ini_puts str sec, str key, str data
	WritePrivateProfileString sec, key, "\"" + data + "\"", varptr(mfname)
	return
	
//------------------------------------------------
// 実数 (有効数字16桁)
//------------------------------------------------
#modfunc ini_putd str sec, str key, double data
	WritePrivateProfileString sec, key, strf("%.16e", data), varptr(mfname)
	return
	
//------------------------------------------------
// 整数
//------------------------------------------------
#modfunc ini_puti str sec, str key, int data
	WritePrivateProfileString sec, key, str(data), varptr(mfname)
	return
	
//------------------------------------------------
// any
//------------------------------------------------
#define global ini_put(%1, %2, %3, %4, %5 = 0) stt_tmp@MCIni = (%4) : ini_putv %1, %2, %3, stt_tmp@MCIni, %5
#modfunc ini_putv str sec, str key, var data, int valtype_,  local valtype
	if ( valtype_ ) { valtype = valtype_ } else { valtype = ValtypeByString(str(data)) }
	switch ( valtype )
		case IniValtype_String: ini_puts thismod, sec, key,       (data) : swbreak
		case IniValtype_Double: ini_putd thismod, sec, key, double(data) : swbreak
		case IniValtype_Int:    ini_puti thismod, sec, key,    int(data) : swbreak
	swend
	return
	
//**********************************************************
//        列挙
//**********************************************************
//------------------------------------------------
// 列挙
// 
// @prm (this)
// @prm dst : 受け取り変数 (配列化)
// @prm[sec : セクション名]
//------------------------------------------------
#define global ini_enumSection(%1, %2, %3 = 0) ini_enum_impl %1, %2, "", %3
#define global ini_enumKey(%1, %2, %3, %4 = 0) ini_enum_impl %1, %2, %3, %4

#modfunc ini_enum_impl array dst, str sec_, int maxlen_,  local maxlen, local pSec, local sec
	maxlen = limit(maxlen_, 1024, 0xFFFF)
	
	if ( sec_ == "" ) { pSec = null } else { sec = sec_ : pSec = varptr(sec) }
	
*LReTry:
	if ( maxlen > 1200 ) { memexpand stt_stmp, maxlen + 1 }
	
	GetPrivateProfileString pSec, null, null, varptr(stt_stmp), maxlen, varptr(mfname)
	
	if ( maxlen <= 0 && (stat == maxlen - 2) ) {
		maxlen *= 2
		goto *LReTry
	}
	
	SplitByNull dst, stt_stmp, stat			// 配列化
	return
	
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
	return
	
#ifdef _DEBUG
// すべてのセクションのキーを列挙しデバッグ出力する
 #modfunc ini_dbglog  local seclist, local sec, local keylist, local key, local stmp
	logmes "\n(ini_dbglog): @" + mfname
	
	sdim seclist
	sdim keylist
	sdim stmp
	
	ini_enumSection thismod, seclist			// セクションを列挙
	
	foreach seclist : sec = seclist(cnt)
		logmes strf("[%s]", sec)
		
		ini_enumKey thismod, keylist, sec		// キーを列挙
		foreach keylist : key = keylist(cnt)
			ini_getsv thismod, stmp, sec, key, , 512			// 最長 512 - 1 とする。
			logmes ("\t" + key + " = \"" + stmp + "\"")
		loop
		
	loop
	return
#else
 #define global ini_dbglog :
#endif
	
	
//**********************************************************
//        その他の操作
//**********************************************************
//------------------------------------------------
// キーの有無
// 
// @ GetPrivateProfileString に 既定値("__"), nSize(2) を与えるとき、
// @	キーが存在すれば返値 1 or 0、しなければ 2 となる。
//------------------------------------------------
#modcfunc ini_existsKey str sec, str key
	GetPrivateProfileString sec, key, "__", varptr(stt_stmp), 2, varptr(mfname)
	return ( stat < 2 )
;	return ( false == ( ini_geti( thismod, sec, key, 0 ) == 0 && ini_geti( thismod, sec, key, 1 ) == 1 ) )
	
//------------------------------------------------
// セクション除去
//------------------------------------------------
#modfunc ini_removeSection str sec
	WritePrivateProfileString sec, null, null, varptr(mfname)
	return
	
//------------------------------------------------
// キー除去
//------------------------------------------------
#modfunc ini_removeKey str sec, str key
	WritePrivateProfileString sec, key, null, varptr(mfname)
	return
	
//**********************************************************
//        その他
//**********************************************************
//------------------------------------------------
// 型を判定する (from 文字列)
// 
// @ 0x* などには未対応
//------------------------------------------------
#defcfunc ValtypeByString@MCIni str data
	if ( data == int(data) ) { return IniValtype_Int }
	if ( double(data) != 0 ) {
		if ( IsDoubleImpl(data) ) { return IniValtype_Double }
	}
	return IniValtype_String
	
#defcfunc IsDoubleImpl@MCIni str data_, local data
	data = data_
	return ( instr(data, , ".") >= 0 || instr(data, , "e") >= 0 )
	
//------------------------------------------------
// 型変換 (from str)
//------------------------------------------------
#defcfunc CastFromString@MCIni str data, int valtype_,  local valtype
	if ( valtype_ ) { valtype = valtype_ } else { valtype = ValtypeByString(stt_stmp) }
	switch ( valtype )
		case IniValtype_String: return       (data)
		case IniValtype_Double: return double(data)
		case IniValtype_Int:    return    int(data)
	swend
	
#global

	sdim stt_stmp@MCIni, 1200 + 1
	
//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 0

	ini_new cfg, "C:/appdata.ini"	// 開く ini ファイルをパスで指定します。なかったら作成します。
//	( strsize = 開いたiniファイルのサイズ ; 負数 => なかったので作った )
	
	mes ini_geti( cfg, "appdata", "x" )
	ini_dbglog cfg
;	ini_delete cfg
	stop
	
#endif

/***

＠リファレンス

＊INIに関して
	・セクション名、キー名、ファイルパスは、半角アルファベットの大文字・小文字を区別しません。
	・キー名や値の、先頭および末尾にある空白は無視されます (改行を除く)。
		ただし、キー名や値の全体を "" で括ると、その内部の空白は維持されます (キーは " " を含みます)。
		ex: { x = 3 } <=> (key: 'x', value: '3')
		ex: { " x " = " string " } <=> (key: '" x "', value: ' string ')
	・整数値 0x... は、16進数として扱います。
		ただし、0... としてこれを8進数とする機能はありません。
	・行末コメントはセミコロン ; だけです。ナンバーサイン # やＷスラッシュ // は有効な記号です。
		まぁ、セクションでもキーでもない場所は意味ないわけですが。
	・拡張子は .ini か .cfg が一般的です。
	
＊生成、解体
	・ini_new self, "ファイルパス"
	
	ini ファイルを開きます。なかったら空のファイルを作ります。
	パスにはファイル名ではなく、絶対パスか相対パスを指定してください (例："./cfg.ini", "D:/Cfg/prjx.ini", etc)。
	
	・ini_delete self
	
	ini ファイルを閉じます。必須ではありません。
	ファイルを削除するわけではありせん。
	
＊書き込み
	・ini_puts self, "sec", "key", "value"
	
	セクション "sec" のキー "key" の値を、文字列 value に設定します。
	
	・ini_puti self, "sec", "key", value
	・ini_putv self, "sec", "key", value
	
	セクション "sec" のキー "key" の値を、value の文字列表記に設定します。
	value の型は問いませんが、必ず文字列として書き込まれます。
	
＊読み込み
	・ini_getsv self, dst, "sec", "key", "default", maxlen
	
	セクション "sec" のキー "key" の値を、文字列として変数 dst に格納します。
	( 内容が int でも、文字列型のまま格納されます。 )
	maxlen は、読み込む文字列の最大の長さです。通常は 1200 [byte] ですが、それ以上が必要な
	場合は省略せずに指定してください。
	指定したキーが存在しない場合は、"default"の値が返ります。省略すると "" (空文字列)です。
	
	・ini_geti( self, "sec", "key", default )
	
	セクション "sec" のキー "key" の値を、数値として読み出して返します。str だと 0 が返ります。
	指定したキーが存在しない場合、default の値が返ります。省略すると 0 です。
	
	・ini_gets( self, "sec", "key", "default", maxlen )
	
	ini_getsv の関数形式です。maxlen は、省略すると 1200 になります。
	
＊INIデータの削除
	・ini_removeSection self, "sec"
	
	セクション "sec" を削除します。元に戻せません。
	
	・ini_removeKey self, "sec", "key"
	
	セクション "sec" のキー "key" を削除します。元に戻せません。
	
＊その他
	・ini_existsKey( self, "sec", "key" )
	
	セクション "sec" のキー "key" が存在するかどうか。存在するなら真を返します。
	@ 値のないキー ("key=" だけ) は、存在しないものとして扱われます。
	
***/
#endif
