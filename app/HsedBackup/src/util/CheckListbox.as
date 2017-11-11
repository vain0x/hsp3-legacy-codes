//---------------------------------------------------------------------
//	チェックボックス付きリストビュー表示モジュール
//	by Kpan (Let's HSP!)
//	http://lhsp.s206.xrea.com/
//
//	！Windows 9x系OSは要IE3以降
//
//
//	■ CL_SetObject p1, p2, p3, p4, p5
//		p1, p2 = リストビューのサイズ(ドット単位)
//		p3 = リストビュー内の項目文字列 (項目ごとに [\n] 区切り)
//		p4 = 追加のスタイル
//			+ 0x0008 = フォーカスがない場合も選択項目を淡色表示に
//			+ 0x0010 = 項目文字列をもとに表示列を昇順ソート
//			+ 0x0020 = 項目文字列をもとに表示列を降順ソート
//		p5 = 追加の拡張スタイル
//			+ 0x0001 = グリッド線を表示
//			+ 0x0020 = 選択項目の場合に列全体を選択状態に
//			+ 0x0840 = カーソル下の項目文字列に下線を表示 (要IE4以降)
//	
//	　チェックボックス項目が付いたリストビューを表示します。
//	statには、オブジェクトID が返ります。
//	　(Windows XP以降) 項目の文字列部分を選択しても、チェックボックス
//	の状態は変化しません。
//	
//	■ CL_SetCheckState p1, p2, p3
//		p1 = リストビューのオブジェクトID
//		p2 = 項目のインデックス番号(-1, 0～)
//		p3 = False (チェックを外す) or True(チェックする)
//	
//	　チェックボックスの状態を設定します。状態を設定したい項目の
//	インデックス番号(0～)を指定してください。
//	-1の場合は、すべての項目に適用されます。
//	
//	■ CL_GetCheckState p1, p2
//		p1 = リストビューのオブジェクトID
//		p2 = 項目のインデックス番号(0～)
//	
//	　チェックボックスの状態を取得します。状態を取得したい項目の
//	インデックス番号(0～)を指定してください。
//	stat にFalse(チェックなし) or True(チェックあり)が返ります。
//	
//	■ CL_GetNextItem p1
//		p1 = リストビューのオブジェクトID
//
//	リストビュー内の選択状態になっている項目のインデックス番号
//	(0～)を取得します。stat に値が返ります。-1の場合は、選択項目
//	がないことを意味します。
//	
//	■ CL_GetItemCount p1
//		p1 = リストビューのオブジェクトID
//	
//	リストビュー内の項目数を取得します。statに値が返ります。
//	
//	■ CL_GetItemText p1, p2
//		p1 = リストビューのオブジェクトID
//		p2 = 項目のインデックス番号(0～)
//
//	リストビューの特定項目の文字列を取得します。取得する項目のイン
//	デックス番号(0～)を指定してください。refstrに文字列が返ります。
//	
//	■ CL_SetItemText p1, p2, p3
//		p1 = リストビューのオブジェクトID
//		p2 = 項目のインデックス番号(0～)
//		p3 = 項目文字列
//	
//	リストビューの特定項目の文字列を変更(差し替え)します。変更する
//	項目のインデックス番号(0～)を指定してください。
//	
//	■ CL_InsertItem p1, p2, p3
//		p1 = リストビューのオブジェクトID
//		p2 = 項目のインデックス番号(0～)
//		p3 = 項目文字列
//	
//	リストビューの特定項目に新たな文字列を挿入します。一度に複数の
//	項目を挿入することはできません。挿入する項目のインデックス番号
//	(0～)を指定してください。
//	
//	■ CL_DeleteItem p1, p2
//		p1 = リストビューのオブジェクトID
//		p2 = 項目のインデックス番号(0～)
//	
//	リストビューの特定項目を削除します。削除したい項目のインデックス
//	番号(0～)を指定してください。
//	
//	■ CL_DeleteAllItem p1
//		p1 = リストビューのオブジェクトID
//	
//	リストビューのすべての項目を削除します。
//	
//	■ CL_SetTextColor p1, p2
//		p1 = リストビューのオブジェクトID
//		p2 = 色コード (0xBBGGRR形式)
//	
//	リストビュー全体の文字色を設定します。色コードは、たとえば、
//	「0xFF0000」なら青、「0xFF00FF」ならピンクです。RGBマクロも別途
//	用意しています。
//	項目ごとに異なる文字色を指定する処理は用意していません。
//	
//	■ CL_SetBkColor p1, p2
//		p1 = リストビューのオブジェクトID
//		p2 = 色コード (0xBBGGRR形式)
//		
//	リストビュー全体の背景色を設定します。
//	項目ごとに異なる背景色を指定する処理は用意していません。
//	
//	■ RGB (p1, p2, p3)
//		p1,p2,p3 = R、G、Bの輝度値 (0～255)
//		
//	RGB値をCOLORREF値(0xBBGGRR形式)に変換するマクロです。
//	
//---------------------------------------------------------------------


#module

#define ctype RGB(%1,%2,%3) (%1 | (%2 << 8) | (%3 << 16))

#deffunc CL_SetObject int p1, int p2, str p3, int p4, int p5,  \
	local LVCOLUMN
	
	winobj "syslistview32", "", $200, $50004005 | p4, p1, p2
	IDObject = stat
	hObject = objinfo (stat, 2)
	
;	LVM_SETEXTENDEDLISTVIEWSTYLE
	sendmsg hObject, $1036, , $4 | p5
	
;	LVM_INSERTCOLUMN
	sendmsg hObject, $101B, , varptr (LVCOLUMN)
	
	sdim pszText_list, 512
	pszText_list = p3
	sdim pszText, 128
	
	i = 0
	repeat
		getstr pszText, pszText_list, i, $0D
		if strsize = 0 : break
		i += strsize + 1
		
;		LVM_INSERTITEM
		LVITEM = 0x01, cnt, 0, 0, 0, varptr (pszText)
		sendmsg hObject, 0x1007, , varptr (LVITEM)
	loop
	
;	LVM_SETCOLUMNWIDTH
	sendmsg hObject, $101E, , -2
	
	return IDObject
	
	
#deffunc CL_SetCheckState int p1, int p2, int p3
;	LVM_SETITEMSTATE
	LVITEM.3 = p3 + 1 << 12, $F000
	sendmsg objinfo (p1, 2), $102B, p2, varptr (LVITEM)
	
	return
	
	
#deffunc CL_GetCheckState int p1, int p2
;	LVM_GETITEMSTATE
	sendmsg objinfo (p1, 2), $102C, p2, $F000
	
	return (stat >> 12) - 1
	
	
#deffunc CL_GetNextItem int p1
;	LVM_GETNEXTITEM
	sendmsg objinfo (p1, 2), $100C, -1, $2

	return stat


#deffunc CL_GetItemCount int p1
;	LVM_GETITEMCOUNT
	sendmsg objinfo (p1, 2), 0x1004

	return (stat)
	
	
#deffunc CL_GetItemText int p1, int p2
;	LVM_GETITEMTEXT
	LVITEM = $1, 0, 0, 0, 0, varptr (pszText), 128
	sendmsg objinfo (p1, 2), $102D, p2, varptr (LVITEM)
	
	return pszText
	
	
#deffunc CL_SetItemText int p1, int p2, str p3
;	LVM_SETITEMTEXT
	pszText = p3
	LVITEM = $1, 0, 0, 0, 0, varptr (pszText)
	sendmsg objinfo (p1, 2), $102E, p2, varptr (LVITEM)

	return


#deffunc CL_InsertItem int p1, int p2, str p3
;	LVM_INSERTITEM
	pszText = p3
	LVITEM = $1, p2, 0, 0, 0, varptr (pszText)
	sendmsg hObject, $1007, , varptr (LVITEM)

;	LVM_SETCOLUMNWIDTH
	sendmsg hObject, $101E, , -2

	return


#deffunc CL_DeleteItem int p1, int p2
;	LVM_DELETEITEM
	sendmsg objinfo (p1, 2), $1008, p2

	return


#deffunc CL_DeleteAllItem int p1
;	LVM_DELETEALLITEMS
	sendmsg objinfo (p1, 2), $1009

	return


#deffunc CL_SetTextColor int p1, int p2
;	LVM_SETTEXTCOLOR
	sendmsg objinfo (p1, 2), $1024, , p2

;	LVM_UPDATE
	sendmsg objinfo (p1, 2), $102A

	return


#deffunc CL_SetBkColor int p1, int p2
;	LVM_SETBKCOLOR
	sendmsg objinfo (p1, 2), $1001, , p2

;	LVM_SETTEXTBKCOLOR
	sendmsg objinfo (p1, 2), $1026, , p2

;	LVM_UPDATE
	sendmsg objinfo (p1, 2), $102A

	return

#global


#if 0
	sdim list_text, 128
	list_text = "HSP3\nリストビュー\nチェックリスト\nスクリプト\nLet's HSP!"

;	チェックボックス付きリストビュー設置
	pos 10, 10
	CL_SetObject 200, 100, list_text
	idListview = stat

;	文字色を赤に
	CL_SetTextColor idListview, RGB ($FF, 0, 0)

;	後から項目追加
	CL_InsertItem idListview, 1, "(追加) サンプルコード"

;	インデックス番号２の項目をチェック
	CL_SetCheckState idListview, 2, 1

	button "チェック状態", *getstate
	button "チェック反転", *setstate

	stop


*getstate
;	項目数取得
	CL_GetItemCount idListview

	result = ""
	repeat stat
;		項目状態取得
		CL_GetCheckState idListview, cnt
		result += "["+stat+"]"
	loop
	mes result

	stop


*setstate
;	項目数取得
	CL_GetItemCount idListview

	repeat stat
;		項目状態取得
		CL_GetCheckState idListview, cnt
		if stat {
;			状態変更 (チェック外す)
			CL_SetCheckState idListview, cnt
		} else {
;			状態変更 (チェック付ける)
			CL_SetCheckState idListview, cnt, 1
		}
	loop

	stop
#endif