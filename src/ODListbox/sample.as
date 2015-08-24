// サンプル用ヘッダファイル

// サンプルにしか使わない

#ifndef __SAMPLE_AS__
#define __SAMPLW_AS__

// マクロ
#ifndef __UserDefHeader__
 #define ctype HIWORD(%1) (((%1) >> 16) & 0xFFFF)
 #define ctype LOWORD(%1) ((%1) & 0xFFFF)
 #define ctype RGB(%1=0,%2=0,%3=0) (((%1) & 0xFF) | (((%2) & 0xFF) << 8) | (((%3) & 0xFF) << 16))
 #define global NULL  0
 #define global true  1
 #define global false 0
#endif

// 定義
#define wID_Main 1
#define wID_Buffer 2

// API 呼び出し
#uselib "user32.dll"
#func   DestroyIcon "DestroyIcon" int
#cfunc  GetDC       "GetDC"       int
#func   ReleaseDC   "ReleaseDC"   int,int
#func   MoveWindow  "MoveWindow"  int,int,int,int,int,int

#uselib "gdi32.dll"
#func   BitBlt "BitBlt" int,int,int,int,int,int,int,int,int

#uselib "shell32.dll"
#func   ExtractIconEx "ExtractIconExA" sptr,int,int,int,int


// DrawText関数のフォーマット
#define DT_TOP					0x00000000		// 上揃え (デフォルト)
#define DT_LEFT					0x00000000		// 左寄せ (デフォルト)
#define DT_CENTER				0x00000001		// 水平方向に中央揃え
#define DT_RIGHT				0x00000002		// 右寄せ
#define DT_VCENTER				0x00000004		// 垂直方向に中央揃え
#define DT_BOTTOM				0x00000008		// 下揃え
#define DT_WORDBREAK			0x00000010		// 複数行で描画。折り返しは自動
#define DT_SINGLELINE			0x00000020		// 一行だけ
#define DT_EXPANDTABS			0x00000040		// タブ文字(\t)を展開
#define DT_TABSTOP				0x00000080		// タブ文字の空白文字数を設定。下位ワードの上位バイトで空白数を記憶
#define DT_NOCLIP				0x00000100		// クリッピングを行わない
#define DT_EXTERNALLEADING		0x00000200		// 行高に、行間として適当な高さを加える
#define DT_CALCRECT				0x00000400		// 描画に必要な RECT を lpRect に格納する (描画処理はない)
#define DT_NOPREFIX				0x00000800		// プレフィックス文字(&)を無効化 (& は次の文字に下線を引き、&& -> &)
#define DT_INTERNAL				0x00001000		// DT_CALCRECT のとき、フォントを SystemFont とする
#define DT_EDITCONTROL			0x00002000		// EditControl(複数行) の特性と同じ特性で描画する
#define DT_PATH_ELLIPSIS		0x00004000		// テキストが収まらない場合、途中を省略記号(...)にする
#define DT_END_ELLIPSIS			0x00008000		// テキストが収まらない場合、最後を省略記号(...)にする
#define DT_MODIFYSTRING			0x00010000		// 省略した場合、lpStr に省略後の文字列を格納する
#define DT_RTLREADING			0x00020000		// 右から左に向かって描画。右から左に読む言語で使用する
#define DT_WORD_ELLIPSIS		0x00040000		// テキストが収まらない場合、必ず省略記号(...)にする
#define DT_NOFULLWIDTHCHARBREAK	0x00080000		// 
#define DT_HIDEPREFIX			0x00100000		// プレフィックス文字(&)を無視する ( && は、依然として & になる )
#define DT_PREFIXONLY			0x00200000		// プレフィックス文字(&)による下線のみを描画する


// フォント作成モジュール
#module fontmod
#uselib "gdi32.dll"
#func CreateFontIndirect "CreateFontIndirectA" int
#func GetObject          "GetObjectA"          int,int,int
#func DeleteObject       "DeleteObject"        int
#defcfunc CreateFontByHSP str p1, int p2, int p3
	sdim sFontName, 64 : dim logfont, 15 : mref bmscr, 67
	GetObject bmscr(38), 60, varptr(logfont)				// 現在の LOGFONT 構造体を取得する
	getstr sFontName, logfont(7)								// フォント名
	nFontData = abs(logfont), ((logfont(4) <= 700)) | (((logfont(5) & 0xFF) != 0) << 1) | (((logfont(5) & 0xFF00) != 0) << 2) | (((logfont(5) & 0xFF0000) != 0) << 3) | (((logfont(6) & 0x40000) != 0) << 4)
	font p1, p2, p3 : GetObject bmscr(38), 60, varptr(logfont)	// 新しい論理フォントを取得
	CreateFontIndirect varptr(logfont) : hFont = stat			// HSPの画面から、新しいフォントを作り出す
	font sFontName, nFontData(0), nFontData(1)					// 元に戻す
	return hFont
#define global DeleteFont(%1) if (%1) { DeleteObject@fontmod (%1) }
#global



#endif
