// DialogEx

#ifndef __DIALOG_EX_MODULE_AS__
#define __DIALOG_EX_MODULE_AS__

#module DialogEx_mod

#uselib "comdlg32.dll"
#func   GetOpenFileName@DialogEx_mod "GetOpenFileNameA" int
#func   GetSaveFileName@DialogEx_mod "GetSaveFileNameA" int

#define BUFSIZE	260
#define FILTERSIZE 512
#define ALLTYPE				"ALL files (*.*)@*.*@"
#define PICTURE				"画像ファイル (*.bmp;*.mag;*.jpg)@*.bmp;*.mag;*.jpg@"
#define SOUND				"音楽ファイル (*.mid;*.mp3;*.wav)@*.mid;*.mp3;*.wav@"
#define DOCUMENT			"文書ファイル (*.txt)@*.txt@"

// フラグ
#define global OFN_READONLY				0x00000001		// 読み取り専用状態で初期化する
#define global OFN_OVERWRITEPROMPT		0x00000002		// 上書きの場合、確認する
#define global OFN_HIDEREADONLY			0x00000004		// ReadOnly チェックボックスを非表示にする
#define global OFN_NOCHANGEDIR			0x00000008		// カレントディレクトリを変更しない
#define global OFN_SHOWHELP				0x00000010		// [？] を表示
#define global OFN_ENABLEHOOK			0x00000020		// lpfnHook でフック関数へのポインタを指定可能
#define global OFN_ENABLETEMPLATE		0x00000040		// lpTemplateName が hInstance で指定されるモジュールの DialogTemplateResouce の名前へのポインタであることを示す
#define global OFN_ENABLETEMPLATEHANDLE	0x00000080		// hInstace が既にロードされている DialogTemplate を所有する DataBlock であることを示す
#define global OFN_NOVALIDATE			0x00000100		// パス内の無効な文字を許可
#define global OFN_ALLOWMULTISELECT		0x00000200		// 複数選択を許可
#define global OFN_EXTENSIONDIFFERENT	0x00000400		// 指定された拡張子が lpstrDefExt とは違うことを示す
#define global OFN_PATHMUSTEXIST		0x00000800		// 有効なパスとディレクトリしか入力できないようにする
#define global OFN_FILEMUSTEXIST		0x00001000		// 存在するファイルのみ選択できる
#define global OFN_CREATEPROMPT			0x00002000		// ユーザーが存在しないファイルを選択しようとした時は確認する
#define global OFN_SHAREAWARE			0x00004000		// ???
#define global OFN_NOREADONLYRETURN		0x00008000		// ???
#define global OFN_NOTESTFILECREATE		0x00010000		// ダイアログが閉じられるまでファイルが作成されないようにする
#define global OFN_NONETWORKBUTTON		0x00020000		// ネットワークボタンを無効・非表示にする
#define global OFN_NOLONGNAMES			0x00040000		// 従来のダイアログで、長いファイル名を使わない
#define global OFN_EXPLORER				0x00080000		// エクスプローラスタイルを使う
#define global OFN_NODEREFERENCELINKS	0x00100000		//
#define global OFN_LONGNAMES			0x00200000		// 長いファイル名を使う
#define global OFN_ENABLEINCLUDENOTIFY	0x00400000		// send include message to callback
#define global OFN_ENABLESIZING			0x00800000		//
#define global OFN_DONTADDTORECENT		0x02000000		// win2k
#define global OFN_FORCESHOWHIDDEN		0x10000000		// Show All files including System and hidden files

// http://hp.vector.co.jp/authors/VA023539/tips/dialog/004.htm

// str Filter, OPENFILENAME *, bSave, flags
#deffunc FileSelDlg str p1, int p2, int p3, int p4, local i, local match
	dim  ofn  , 22
	sdim aplFilter , FILTERSIZE +1
	sdim usrFilter , FILTERSIZE +1
	sdim filename  , BUFSIZE +1
	sdim Filter, strlen(p1) +1
	
	Filter = p1
	i = 0
	repeat
		match = instr(Filter, i, "@")	// @ を探す
		if (match == -1) { break }		// 無ければ終了
		poke Filter,i +  match , 0		// @ を NULL 文字に上書き
					i += match + 1		// Index 追加
	;	await 0
	loop
	
	if ( p2 == 0 ) {		// p2(ofn が 0)
		ofn.0  = 88						// lStructSize
		ofn.1  = bmscr(13)				// hwndOwner
		ofn.2  = bmscr(14)				// hInstance
		ofn.3  = varptr(Filter)			// lpstrFilter
		ofn.4  = varptr(usrFilter)		// lpstrCustomFilter
		ofn.5  = FILTERSIZE				// nMaxCustFilter
		ofn.6  = 1						// nFilterIndex
		ofn.7  = varptr(filename)		// lpstrFile
		ofn.8  = BUFSIZE				// nMaxFile
		ofn.9  = 0						// lpstrFileTitle
		ofn.10 = 0						// nMaxFileTitle
		ofn.11 = 0						// lpstrInitialDir
		ofn.12 = 0						// lpstrTitle
		ofn.13 = OFN_FILEMUSTEXIST | p4	// Flags
		ofn.14 = 0						// nFileOffset
		ofn.15 = 0						// nFileExtension
		ofn.16 = 0						// lpstrDefExt
		ofn.17 = 0						// lCustData
		ofn.18 = 0						// lpfnHook
		ofn.19 = 0						// lpTemplateName
	} else {
		dupptr ofn, p2, 88, 4			// OPENFILENAME構造体
		if ( Filter != "" ) {			// p1 を使用するなら
			ofn(3)  = varptr(Filter)	// フィルタを上書き
		}
	}
	
	if ( p3 == 0 ) {
		GetOpenFileName varptr(ofn)	// 「ファイルを開く」
	} else {
		GetSaveFileName varptr(ofn)	// 「名前をつけて保存」
	}
	if ( stat ) {
		// ファイル名格納
		if ( p2 ) {
			dupptr filename, ofn(7), ofn(8), 2
		}
		ref = filename				// ファイルパスを返す
		
		return varptr(ofn)			// ofn へのポインタ (真値)
	}
	return 0	// 偽
	
#global
	mref bmscr@DialogEx_mod, 67		// BMSCR 構造体
	mref ref@DialogEx_mod, 65		// refstr 割り当て
	
#if 0

#undef false
#undef NULL
#define false 0
#define NULL 0

	FileSelDlg "1@*@2@*@3@*@4@*@5@*@", NULL, false
	pofn = stat
	mes "stat == "+ stat
	mes "refs == "+ refstr
	
	if ( pofn != NULL ) {
		dupptr ofn, pofn, 22 * 4
		mes "index == "+ ofn(6)
	}
	stop
#endif

#endif
