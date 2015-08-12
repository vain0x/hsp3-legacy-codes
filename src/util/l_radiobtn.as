/*--------------------------------------------------------------------------

	[HSP3] ラジオボタン作成モジュール
	by Kpan
	http://lhsp.s206.xrea.com/ (Let's HSP!)
	
	radiobtn "文字列", p2, p3
		p2 = チェックを入れたい場合に1を指定
		p3 = グループ化を開始したい場合に1を指定 (開始フラグ)
	
	ラジオボタンを表示します。statにオブジェクトIDが返ります。
	くれぐれもグループ中に別のオブジェクト設置命令を呼ばないで
	ください。
	
	
	pushbtn "文字列", p2, p3
		p2 = ボタンを凹ましたい場合に1を指定
		p3 = グループ化を開始したい場合に1を指定 (開始フラグ)
	
	プッシュボタン型ラジオボタンを表示します。statにオブジェクト
	IDが返ります。くれぐれもグループ中に別のオブジェクト設置
	命令を呼ばないでください。
	
	
	prmbtn p1, p2
		p1 = グループ中の最初のオブジェクトID
		p2 = グループ中の最後のオブジェクトID

	ラジオボタンの状態の確認します。くれぐれも指定するオブジェ
	クトID値を間違えないでください。
	statにチェックがある(= ボタンが凹んでいる)オブジェクトIDが
	返ります。-1の場合はチェックが1つもないことを意味します。
	
--------------------------------------------------------------------------*/

#ifndef __l_radiobtn_as
#define __l_radiobtn_as

#module

#uselib "user32"
#func   SetWindowLong "SetWindowLongA" int,int,int

#deffunc radiobtn str p1, int p2, int p3, local objID
	_p2 = p2
	chkbox p1, _p2
	objID = stat
	
	if ( p3 ) {
		SetWindowLong objinfo(objID, 2), -16, 0x50020009
	} else {
		sendmsg objinfo(objID, 2), 0x00F4, 0x0009
	}
	return objID
	
#deffunc pushbtn str p1, int p2, int p3, local objID
	_p2 = p2
	chkbox p1, _p2
	objID = stat

	if ( p3 ) {
		SetWindowLong objinfo(objID, 2), -16, 0x50021009
	} else {
		SetWindowLong objinfo(objID, 2), -16, 0x50001009
	}
	
	return objID
	
#deffunc prmbtn int p1, int p2, local nRet
	nRet = -1
	repeat p2 - p1 + 1, p1
		sendmsg objinfo(cnt, 2), 0x00F0
		if ( stat == 1 ) {
			nRet = cnt
			break
		}
	loop
	return nRet
	
#global
	
#endif
