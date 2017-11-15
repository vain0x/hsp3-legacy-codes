;    低機能なタブコントロール作成モジュール (by Kpan) を参考にしました
;
#module

#uselib "user32"
#func GetClientRect "GetClientRect" int, int
#func SetWindowLong "SetWindowLongA" int, int, int
#func SetParent "SetParent" int, int

#uselib "gdi32"
#cfunc GetStockObject "GetStockObject" int

	; CreateTab p1, p2, p3, p4
	; タブコントロールを設置します。statにタブコントロールのハンドルが返ります。
	; p1～p2=タブコントロールのX/Y方向のサイズ
	; p3(1)=タブの項目として貼り付けるbgscr命令の初回ウィンドウID値
	; p4=タブコントロールの追加ウィンドウスタイル
	
#deffunc CreateTab int p1, int p2, int p3, int p4
	winobj "systabcontrol32", "", , $52000000 | p4, p1, p2
	hTab = objinfo (stat, 2)
	sendmsg hTab, $30, GetStockObject (17)
	
	TabID = p3
	if TabID = 0 : TabID = 1
	
	dim rect, 4
	
		return hTab	; この値が stat に代入される

	; InsertTab "タブつまみ部分の文字列"
	; タブコントロールに項目を追加します。
	
#deffunc InsertTab str p2
	pszText = p2 : tcitem = 1, 0, 0, varptr (pszText)
	sendmsg hTab, $1307, TabItem, varptr (tcitem)
	
	GetClientRect hTab, varptr (rect)
	sendmsg hTab, $1328, , varptr (rect)

bgscr TabID + TabItem, rect.2 - rect.0, rect.3 - rect.1, 2, rect.0, rect.1
	SetWindowLong hwnd, -16, $40000000
	SetParent hwnd, hTab

	TabItem = TabItem + 1
		return

	; タブ切り替え処理用
	
#deffunc ChangeTab
	gsel wID + TabID, -1
	
	sendmsg hTab, $130B
	wID = stat
	gsel wID + TabID, 1
	
		return

#global