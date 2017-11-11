// ***** フォルダ選択ダイアログ表示  (foldialog.hsp) [ API版 ] *****
#module
	// ▼必要となるAPIや定数の定義

#uselib "shell32.dll"
#func SHGetPathFromIDList "SHGetPathFromIDList" int,int
#func SHBrowseForFolder "SHBrowseForFolderA" int

#uselib "ole32.dll"
#func CoTaskMemFree "CoTaskMemFree" int

#uselib "user32.dll"
#func SendMessage "SendMessageA" int,int,int,int

#deffunc foldlg str prm1, str prm2, int prm3
	//******************************************************************************
	//		フォルダ選択ダイアログ (foldlg)
	//
	//  戻り値 : 成功 stat = 0, refstr = 選択フォルダ名
	//			 失敗 stat = 1, refstr は変化なし
	//
	//  ・書式	Foldlg "Title", "DefFolder", nOption
	//  ・引数	dlgtitle  (str) : ダイアログタイトル名 (省略可)
	//			deffolder (str) : 初期フォルダ名
	//			nOption   (int) : 0, 1, 0x4000 スタイルオプション値
	//******************************************************************************
	mref ref, 65
	ls = strlen(prm1)
	dlgtitle  = prm1
	if (ls == 0) : dlgtitle = "フォルダを選択して下さい"
	sdim deffolder, 260
	DefFolder = prm2
	if (strlen(deffolder) == 0) : deffolder=exedir
	nOption   = prm3  // (0, 1, 0x4000)
	if ( (nOption != 0) && (nOption != 1) && (nOption != 0x4000) ) : nOption=0
	
	dim browsinfo, 64 : sdim retbuf, 260
	browsinfo(0) = hwnd
	browsinfo(3) = varptr(dlgtitle)
	browsinfo(4) = nOption
	
	// BrowseCallback
	// 初期フォルダ指定可能
	if (deffolder != "") {
		dim brproc, 9
		browsinfo(5) = varptr(brproc) : browsinfo(6) = varptr(deffolder)
		p = varptr(SendMessage)
		brproc    = 0x08247C83, 0x90177501, 0x102474FF, 0x6668016A, 0xFF000004
		brproc(5) = 0xB8102474, p, 0xC031D0FF, 0x000010C2
	}
	SHBrowseForFolder varptr(browsinfo)			: pidl = stat
	SHGetPathFromIDList pidl, varptr(retbuf)	: pidl = stat
	CoTaskMemFree pidl
	ref = retbuf : ls = strlen(retbuf)
	ret = (ls == 0)
	dim browsinfo, 0  : sdim retbuf, 0 : sdim deffolder, 0
	return ret
#global

#if 0
	// ***** sample *****
	
	foldlg "", dirinfo(0), 1
	
	pos 20, 10
	if ( stat == 0 ) {		// 成功
		color 0, 0, 255
		mes refstr
	} else {				// 失敗
		color 255, 0, 0
		mes "フォルダ選択に失敗しました……"
	}
	stop

#endif
