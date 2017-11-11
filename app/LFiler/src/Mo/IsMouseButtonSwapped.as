/*************************************************
 * 「マウスの役割が反転しているかどうか」を、
 * 調べるモジュールです。
 * ファイル名・関数名の Is Mouse Button Swapped は、
 * 長ったらしかったら、適当に変更してください。
 * 
 * ☆使い方
 * スクリプトの始めに、CheckMouseButton マクロを使います。
 * グローバル変数 bMouseBtnSwapped に、
 * マウスの役割が交換されていたら、真(0以外)が、
 * そうでなければ、偽(0)が代入されます。
 * 
 * getkey 命令に反映するには、
 * 　左クリック：GETKEY_LBTN
 * 　右クリック：GETKEY_RBTN
 * 
 * stick 命令に反映するには、
 * 　左クリック：STICK_LBTN
 * 　右クリック：STICK_RBTN
 * 
 * を、実際の数値の代わりに使用してください。
 ************************************************/

#ifndef IG_IS_MOUSE_BUTTON_SWAPPED_AS
#define IG_IS_MOUSE_BUTTON_SWAPPED_AS

#uselib "user32.dll"
#cfunc GetSystemMetrics_at_IsMouseBtnSwapped "GetSystemMetrics" int

//------------------------------------------------
// 変数マクロ
//------------------------------------------------
#define global bMouseBtnSwapped __bMouseButtonSwapped@

//------------------------------------------------
// チェックマクロ
// 
// @ これを一度だけ起動する
// @ SM_SWAPBUTTON( マウス機能が交換されていたら真 )
//------------------------------------------------
#define global CheckMouseButton bMouseBtnSwapped = GetSystemMetrics_at_IsMouseBtnSwapped(23)

//------------------------------------------------
// stick用に定義
//------------------------------------------------
#define global Stick_LBtn (256 + (256 * bMouseBtnSwapped))
#define global Stick_RBtn (512 - (256 * bMouseBtnSwapped))

//------------------------------------------------
// getkey用に定義
//------------------------------------------------
#define global GetKey_LBtn (1 + bMouseBtnSwapped)
#define global GetKey_RBtn (2 - bMouseBtnSwapped)

	CheckMouseButton

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 0
	
; #include "IsMouseButtonSwapped.as"	// ← include しておくだけでいい
	
	// 反転したクリックを正確に感知する
	width 240, 180
	
*mainlp
	redraw 2
	
	color 255, 255, 255 : boxf : color
	pos 20, 20
	
	// getkey するバージョン
	mes "getkey"
	getkey bLDown, GETKEY_LBTN : mes "左ボタン："+ bLDown	// 左
	getkey bRDown, GETKEY_RBTN : mes "右ボタン："+ bRDown	// 右
	mes
	
	// stick を使うバージョン
	mes "stick"
	
	stick key, STICK_LBTN	// 左クリックを非トリガーにする
	mes "左ボタン："+ ( key & STICK_LBTN )
	mes "右ボタン："+ ( key & STICK_RBTN )
	
	redraw
	await 20
	goto *mainlp
	
#endif

#endif
