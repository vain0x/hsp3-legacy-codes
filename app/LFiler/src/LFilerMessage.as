// LightFiler - UserMessage

#ifndef __LFILER_USERMESSAGE_AS__
#define __LFILER_USERMESSAGE_AS__

#enum global UWM_FIRST = 0x0500
#enum global UWM_OPENNEWVIEW = UWM_FIRST	// 新しいビューを開く( iTab, sptr )
#enum global UWM_SETPATH					// パス文字列を設定 ( 0, sptr )
#enum global UWM_ACTVIEW_CHANGE				// ビューをアクティブにする( iTab, 0 )
##enum global UWM_
#enum global UWM_LAST

#const global UWM_COUNT ( UWM_LAST - UWM_FIRST )

#endif
