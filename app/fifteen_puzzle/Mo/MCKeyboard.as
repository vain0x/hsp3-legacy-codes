// キーボード一括チェッククラス

#ifndef __MODULECLASS_KEYBOARD_AS__
#define __MODULECLASS_KEYBOARD_AS__

#module MCKeyboard mbKeyboard

#uselib "user32.dll"
#func   GetKeyboardState@MCKeyboard "GetKeyboardState" int

#define mv modvar MCKeyboard@

//##############################################################################
//        メンバ命令・関数
//##############################################################################
//*--------------------------------------------------------*
//        状態取得系
//*--------------------------------------------------------*
// キーボード状態を更新
#modfunc KeyBd_check
	GetKeyboardState varptr(mbKeyboard)
	return
	
// キーが押されているか
#defcfunc KeyBd_isPut mv, int keycode
	return ( peek(mbKeyboard, keycode) & 0x80 )
	
// キーがトグル状態か
#defcfunc KeyBd_isToggle mv, int keycode
	return ( peek(mbKeyboard, keycode) & 1 )
	
//##############################################################################
//        コンストラクタ・デストラクタ
//##############################################################################
#modinit
	sdim mbKeyboard, 256 + 2
	return
	
#global

#endif
