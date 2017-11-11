// 配列シフトモジュール

#ifndef IG_MODULE_SHIFT_ARRAY_AS
#define IG_MODULE_SHIFT_ARRAY_AS

#module shift_array_mod

//------------------------------------------------
// 挿入 ( 的な処理 )
//------------------------------------------------
#deffunc ArrayInsert array arr, int idx
	
	// 挿入される場所を空ける
	for i, length(arr), idx, -1
		arr(i) = arr(i - 1)
	next
	
	return
	
//------------------------------------------------
// 除去 ( 的な処理 )
//------------------------------------------------
#deffunc ArrayRemove array arr, int idx
	
	// 除去される場所を消す ( 他の値で上書きする )
	for i, idx, length(arr) - 1
		arr(i) = arr(i + 1)
	next
	
	return
	
//------------------------------------------------
// 移動
//------------------------------------------------
#deffunc ArrayMove array arr, int from, int to,  local temp
	if ( from == to ) { return }
	
	// 移動元の値を保存する
	temp = arr(from)
	
	// 移動する
	if ( from > to ) {
		dir = -1				// 上に進むなら -1
	} else {
		dir = 1
	}
	for i, from, to, dir
		arr(i) = arr(i + dir)	// 次の場所の値を受け取る
	next
	arr(to) = temp
	
	return
	
//------------------------------------------------
// 交換
//------------------------------------------------
#deffunc ArraySwap array arr, int pos1, int pos2,  local temp
	if ( pos1 == pos2 ) { return }
	temp      = arr(pos1)
	arr(pos1) = arr(pos2)
	arr(pos2) = temp
	return
	
//------------------------------------------------
// 巡回
//------------------------------------------------
#deffunc ArrayRotate array arr, int step,  local temp
	if ( step >= 0 ) {
		ArrayMove arr, 0, length(arr) - 1
	} else {
		ArrayMove arr,    length(arr) - 1, 0
	}
	return
	
// 逆回転
#define global ArrayRotateBack(%1) ArrayRotate %1, -1

//------------------------------------------------
// 反転
//------------------------------------------------
#define global ArrayReverse(%1,%2=-1) ArrayReverse_ %1,%2
#deffunc ArrayReverse_ array arr, int _lenArray,  local lenArray
	if ( _lenArray < 0 ) {
		lenArray = length(arr)
	} else {
		lenArray = _lenArray
	}
	
	repeat lenArray / 2
		ArraySwap arr, cnt, lenArray - cnt - 1
	loop
	
	return
	
#global

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 0

#module

#define global ArrayOutput(%1) ArrayOutput_ %1, "%1"
#deffunc ArrayOutput_ array arr, str ident
	foreach arr
		mes ident + strf("(%d) = ", cnt) + arr(cnt)
	loop
	return
	
#global

	gosub *LInitialize
	gosub *LInsert
	gosub *LMove
	gosub *LSwap
	gosub *LRotate
	gosub *LRemove
	stop
	
//------------------------------------------------
// 初期化
//------------------------------------------------
*LInitialize
	dim a, 6
	
	// 初期値を設定する
	foreach a
		a(cnt) = cnt
	loop
	
	return
	
//------------------------------------------------
// 挿入
//------------------------------------------------
*LInsert
	// 挿入先の番号
	p = 0
	
	ArrayInsert a, p
	
	// 挿入する
	a(p) = 100
	
	// 表示
	pos 20, 20
	mes "Array Insert"
	ArrayOutput a
	return
	
//------------------------------------------------
// 移動
//------------------------------------------------
*LMove
	p = 3	// 移動元の番号
	t = 1	// 移動先の番号
	
	ArrayMove a, p, t
	
	// 表示
	pos 140, 20
	mes "Array Move"
	ArrayOutput a
	return
	
//------------------------------------------------
// 交換
//------------------------------------------------
*LSwap
	// 交換する要素２つ
	p = 4, 2
	
	ArraySwap a, p(0), p(1)
	
	// 表示
	pos 260, 20
	mes "Array Swap"
	ArrayOutput a
	return
	
//------------------------------------------------
// 巡回
//------------------------------------------------
*LRotate
	ArrayRotate a
	
	// 表示
	pos 380, 20
	mes "Array Rotate"
	ArrayOutput a
	return
	
//------------------------------------------------
// 除去
//------------------------------------------------
*LRemove
	// 除去する番号
	p = 3
	
	ArrayRemove a, p
	
	// 表示
	pos 500, 20
	mes "Array Remove"
	ArrayOutput a		// (6) は除去された残骸
	
	stop
	
#endif

#endif
