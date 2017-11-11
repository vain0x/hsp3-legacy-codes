// コマンドライン取得モジュール

#ifndef __GET_COMMANDLINE_AS__
#define __GET_COMMANDLINE_AS__

#module getcmdline_mod

#define MAX_PATH (260 + 3)

#uselib "kernel32.dll"
#func VirtualProtect "VirtualProtect" sptr,int,int,sptr
#define xdim(%1,%2) dim %1,%2:VirtualProtect varptr(%1),%2*4,0x40,varptr(lpflOldProtect)

#deffunc _init@getcmdline_mod
	sdim buf
	dim  prm, 3
	xdim GetCmdline_Code, 36
	GetCmdline_Code( 0) = 0x83EC8B55, 0xC033F8C4, 0xC933D233, 0x89575653, 0xC033F845, 0x4589F633
	GetCmdline_Code( 6) = 0xFC5D8BFC, 0x3B08458B, 0x5F7F0C5D, 0x75223880, 0x0FC9850A, 0xE183C194
	GetCmdline_Code(12) = 0x8A44EB01, 0x20FB8018, 0xDB840474, 0xC9852C75, 0xD2852875, 0x5D8B3174
	GetCmdline_Code(18) = 0xC6DE0310, 0x42001304, 0x03F845FF, 0x8BD233F2, 0x5D3BF85D, 0x83187514
	GetCmdline_Code(24) = 0x7400147D, 0xF8458B12, 0x5D8B1CEB, 0x8DDE0310, 0x188A133C, 0xFF421F88
	GetCmdline_Code(30) = 0x8B40FC45, 0x5D3BFC5D, 0x8BA17E0C, 0x5E5FF845, 0x5D59595B, 0x000000C3
	GetCmdline_ptr = varptr(GetCmdline_Code)
	return
	
// GetCmdlineFunc (CmdlineStr, 受け取り変数(p3 * 260 +1 確保), 受け取る数の最大)
#defcfunc GetCmdlineFunc str p1, array bufvar, int _max
	buf = p1
	prm = varptr(buf), strlen(p1), varptr(bufvar), _max
	return callfunc(prm, GetCmdline_ptr, 4)
	
/**
 * コマンドライン文字列を分解する
 * 変数 list に、取得したコマンドの文字列を格納する。
 * 最大は getmax 個のコマンド。
 * 引用符( " )は削除される。
 * - などの記号はそのまま。
 *
 * stat に、取得した個数が返る。
 *
 * @prm list = array	: コマンドのリスト。初期化される
 * @prm max  = int(10)	: 取得する最大
 * @return = int	: 取得した個数
 */
#define global GetCmdline(%1,%2,%3=dir_cmdline) _GetCmdline %1,%2,%3
#deffunc _GetCmdline array list, int getmax, str cmdline
	sdim cmd,  MAX_PATH, 2
	     cmd = cmdline		// コマンドライン
	sdim list, MAX_PATH, getmax
	
	i       = 0
	index   = 0
	cntCmds = 0
	
	if ( cmd != "" ) {		// コマンドラインがあるなら
		sdim buf, (MAX_PATH * getmax) + 1			// 受け取り用変数
		cntCmds = GetCmdlineFunc(cmd, buf, getmax)	// コマンドラインを buf に取得
		
		// コマンドライン処理
		repeat cntCmds					// 拾った数
			getstr cmd(1), buf, index	// コマンド文字列
			index += strsize + 1
			
			// 追加
			list(i) = cmd(1)	// 
			i ++				// カウンタ
		loop
	}
	return i
	
#global
_init@getcmdline_mod

#endif
