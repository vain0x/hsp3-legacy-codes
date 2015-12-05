// FifPz - public header

#ifndef __FIFPZ_HEADER_AS__
#define __FIFPZ_HEADER_AS__

//##############################################################################
//        定数・マクロ
//##############################################################################

#const global MAX_SHARDS_NUMBER 7

// ID of Window
#enum global IDW_MAIN = 0			// メイン画面
#enum global IDW_PUZZLE				// パズル画面
#enum global IDW_PICFULL			// 画像全体
#enum global IDW_PICSHARD_ENABLE	// 無効な断片
#enum global IDW_PICSHARD_TOP		// 画像断片

// XY
#const global x 0
#const global y 1

// 方向
#enum global DIR_UPPER = 0	// 上
#enum global DIR_RIGHT		// 右
#enum global DIR_LOWER		// 下
#enum global DIR_LEFT		// 左
#enum global DIR_MAX

// ID of MenuItem
#enum global IDM_NONE = 0
#enum global IDM_OPEN
#enum global IDM_CLOSE
#enum global IDM_QUIT
#enum global IDM_REPLACE
#enum global IDM_PLACE_ANS
#enum global IDM_SHARDS_NUMBER
#enum global IDM_SHARDS_NUMBER_END = IDM_SHARDS_NUMBER + MAX_SHARDS_NUMBER
#enum global IDM_MAX

#endif
