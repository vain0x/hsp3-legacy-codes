// ini ファイル操作モジュール

// @ 推奨 → MCIni.as

#ifndef IG_INI_FILE_AS
#define IG_INI_FILE_AS

#uselib "kernel32.dll"
#func   global WritePrivateProfileString_mod_ini "WritePrivateProfileStringA" sptr,sptr,sptr,sptr
#func   global GetPrivateProfileString_mod_ini   "GetPrivateProfileStringA"   sptr,sptr,sptr,int,int,sptr
#cfunc  global GetPrivateProfileInt_mod_ini      "GetPrivateProfileIntA"      sptr,sptr,int,sptr

#define global SetIniName(%1) sdim INIPATH, 260 : INIPATH = str(%1)
#define global INIPATH _stt_ini_file_name@

#define global WriteIni(%1,%2,%3,%4=INIPATH) WritePrivateProfileString_mod_ini %1,%2,str(%3),%4
#define global WriteStrIni(%1,%2,%3,%4=INIPATH) WriteIni %1,%2,"\""+ (%3) +"\"",%4
#define global WriteIntIni WriteIni

#define global GetIni(%1,%2,%3,%4=63,%5="",%6=INIPATH) GetPrivateProfileString_mod_ini %1,%2,str(%5),varptr(%3),%4,%6
#define global ctype GetIntIni(%1,%2,%3=0,%4=INIPATH)  GetPrivateProfileInt_mod_ini(%1,%2,%3,%4)
#define global       GetStrIni IniLoad

#define global DelSectionIni(%1,%2=INIPATH) WritePrivateProfileString_mod_ini %1,0,0,%2
#define global DelKeyIni(%1,%2,%3=INIPATH)  WritePrivateProfileString_mod_ini %1,%2,0,%3

#define global ctype IsExistKeyIni(%1,%2,%3=INIPATH) ( GetIntIni(%1, %2, 0, %3) != 0 && GetIntIni(%1, %2, 1, %3) != 1 )

#module mod_ini

//------------------------------------------------
// ini から読み込む ( 関数形式 )
// 
// @prm section, key
// @prm maxlen    : value (文字列) の最大のサイズ (省略時は 1200)
// @prm default   : 指定キーが存在しない場合に返る値 (省略時は "")
// @prm [inipath] : ini ファイルへのパス
//------------------------------------------------
#define global ctype IniLoad(%1, %2, %3 = 1200, %4 = "", %5 = INIPATH) _IniLoad_mod_ini(%1, %2, %3, %4, %5)
#defcfunc _IniLoad_mod_ini str p1, str p2, int p3, str p4, str p5
	GetIni p1, p2, _stt_stmp_mod_ini@, p3, p4, p5
	return _stt_stmp_mod_ini@
	
#global

	sdim _stt_stmp_mod_ini@, 1201

/***

＠リファレンス

＊INIに関して
	・セクション名、キー名、ファイルパスは、半角アルファベットの大文字・小文字を区別しません。
	・行末コメントはセミコロン ; だけです。ナンバーサイン # やＷスラッシュ // は有効な記号です。
	  まぁ、セクションでもキーでもない場所は意味ない訳ですが。
	
＊INIの設定
	・SetIniName "ファイルパス"
	
	カレント・INIファイルを設定します。パスにはファイル名ではなく、絶対パスか相対パスを指定してください。
	
＊INIへの書き込み
	・WriteIni "sec", "key", "value", ["inipath"]
	
	セクション "sec" のキー "key" の値を value に設定します。型は問いません。
	
	・WriteIni "sec", "key", "value", ["inipath"]
	
	セクション "sec" のキー "key" の値を "value" に設定します。型は問いませんが、
	文字列として書き込まれます。
	読み出す場合は普通に GetIni でかまいません。
	
＊INIからの読み込み
	・GetIni "sec", "key", variable, maxlen, "default", ["inipath"]
	
	セクション "sec" のキー "key" の値を、文字列として variable に返します。int にも使えます。
	maxlen は、読み込む文字列の最大の長さです。通常は 64 ですが、それ以上の場合は
	指定してください。文字列長とぴったりである必要はありません。
	指定したキーが存在しない場合は、"default"の値が返ります。省略すると "" (空文字列)です。
	
	・GetIntIni("sec", "key", default, ["inipath"])
	
	セクション "sec" のキー "key" の値を、数値として読み出して返します。str だと使えません。
	指定したキーが存在しない場合、default の値が返ります。省略すると 0 です。
	
	・IniLoad("sec", "key", maxlen, "default", ["inipath"])
	
	GetIni の関数バージョンです。若干低速になります。maxlen は、省略すると 1200 になります。
	
＊INIデータの削除
	・DelSectionIni "sec", ["inipath"]
	
	セクション "sec" を削除します。元に戻せません。
	
	・DelKeyIni "sec", "key", ["inipath"]
	
	セクション "sec" のキー "key" を削除します。元に戻せません。
	
＊その他
	・IsExistKeyIni("sec", "key", ["inipath"])
	
	セクション "sec" のキー "key" が存在するかどうか。存在するなら真を返します。
	※値のないキー( "key=" だけ )は、存在しないものとして扱われます。
	
***/
#endif
