// (一次元)配列操作モジュール

#ifndef IG_MODULE_ARRAY_AS
#define IG_MODULE_ARRAY_AS

#module mod_array

//##########################################################
//        演算
//##########################################################
//------------------------------------------------
// ベクトル演算
//------------------------------------------------
#define global ctype array_iter(%1, %2) foreach %1 : %2 : loop
#define global ctype array_operate2_(%1, %2, %3) tmpValue@mod_array = %2 : array_iter(%1, %1(cnt) %3= tmpValue@mod_array)

#define global array_inc(%1,%2) array_iter(%1,  %1(cnt) ++)
#define global array_dec(%1,%2) array_iter(%1,  %1(cnt) --)
#define global array_add(%1,%2) array_operate2_(%1, %2, +)
#define global array_sub(%1,%2) array_operate2_(%1, %2, -)
#define global array_mul(%1,%2) array_operate2_(%1, %2, *)
#define global array_div(%1,%2) array_operate2_(%1, %2, /)
#define global array_mod(%1,%2) array_operate2_(%1, %2, \)
#define global array_and(%1,%2) array_operate2_(%1, %2, &)
#define global array_or(%1,%2)  array_operate2_(%1, %2, |)
#define global array_xor(%1,%2) array_operate2_(%1, %2, ^)
#define global array_shl(%1,%2) array_operate2_(%1, %2, <<)
#define global array_shr(%1,%2) array_operate2_(%1, %2, >>)

#define global array_logmes(%1) array_iter(%1, logmes ("[" + cnt + "] = " + %1(cnt)))

// old
#define global array_use array_iter

//##########################################################
//        順序
//##########################################################
//------------------------------------------------
// 挿入 ( 的な処理 )
//------------------------------------------------
#deffunc array_insert array arr, int idx
	
	// 挿入される場所を空ける
	for i, length(arr), idx, -1
		arr(i) = arr(i - 1)
	next
	
	return
	
//------------------------------------------------
// 除去 ( 的な処理 )
//------------------------------------------------
#deffunc array_remove array arr, int idx
	
	// 除去される場所を消す ( 他の値で上書きする )
	for i, idx, length(arr) - 1
		arr(i) = arr(i + 1)
	next
	
	return
	
//------------------------------------------------
// 移動
//------------------------------------------------
#deffunc array_move array arr, int from, int to,  local temp
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
#deffunc array_swap array arr, int pos1, int pos2,  local temp
	if ( pos1 == pos2 ) { return }
	temp      = arr(pos1)
	arr(pos1) = arr(pos2)
	arr(pos2) = temp
	return
	
//------------------------------------------------
// 巡回
//------------------------------------------------
#deffunc array_rotate array arr
	array_move arr, 0, length(arr) - 1
	return
	
// 逆回転
#deffunc array_rotate_back array arr
	array_move arr, length(arr) - 1, 0
	return
	
//------------------------------------------------
// 反転
//------------------------------------------------
#define global array_reverse(%1,%2=-1) array_reverse_ %1, %2
#deffunc array_reverse_ array arr, int _lenArray,  local lenArray
	if ( _lenArray < 0 ) {
		lenArray = length(arr)
	} else {
		lenArray = _lenArray
	}
	
	repeat lenArray / 2
		array_swap arr, cnt, lenArray - cnt - 1
	loop
	
	return
	
//##########################################################
//        データ操作
//##########################################################
//------------------------------------------------
// 複写 [一次元]
//------------------------------------------------
#deffunc array_copy array dst, array src
	dimtype dst, vartype(src), length(src)
	array_use( src, dst(cnt) = src(cnt) )
	return
	
//------------------------------------------------
// 複写 [多次元]
//------------------------------------------------
#deffunc array_copyEx array dst, array src,  local idx, local len
	len = length(src), length2(src), length3(src), length4(src)
	dimtype dst, vartype(src), len(0), len(1), len(2), len(3)
	
	idx = 0, 0, 0, 0
	if ( len(3) ) {
		repeat len(3) : idx(3) = cnt
		repeat len(2) : idx(2) = cnt
		repeat len(1) : idx(1) = cnt
		repeat len(0) : idx(0) = cnt
			dst( idx(0), idx(1), idx(2), idx(3) ) = src( idx(0), idx(1), idx(2), idx(3) )
		loop
		loop
		loop
		loop
	} else : if ( len(2) ) {
		repeat len(2) : idx(2) = cnt
		repeat len(1) : idx(1) = cnt
		repeat len(0) : idx(0) = cnt
			dst( idx(0), idx(1), idx(2) ) = src( idx(0), idx(1), idx(2) )
		loop
		loop
		loop
	} else : if ( len(1) ) {
		repeat len(1) : idx(1) = cnt
		repeat len(0) : idx(0) = cnt
			dst( idx(0), idx(1) ) = src( idx(0), idx(1) )
		loop
		loop
	} else {
		repeat len(0) : idx(0) = cnt
			dst( idx(0) ) = src( idx(0) )
		loop
	}
	return
	
//##########################################################
//        abdata 対応
//##########################################################
//------------------------------------------------
// [i] 反復子操作
//------------------------------------------------
#deffunc array_iterInit array arr, var iterData
	iterData = -1
	return
	
#defcfunc array_iterNext array arr, var iterData, var it
	iterData ++
	if ( iterData < 0 || iterData >= length(arr) ) { return false }
	dup it, arr(iterData)
	return true
	
#global

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 0

#module

#define global array_print(%1) array_print_ %1, "%1"
#deffunc array_print_ array arr, str ident
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
	
	array_insert a, p
	
	// 挿入する
	a(p) = 100
	
	// 表示
	pos 20, 20
	mes "array_ Insert"
	array_Print a
	return
	
//------------------------------------------------
// 移動
//------------------------------------------------
*LMove
	p = 3	// 移動元の番号
	t = 1	// 移動先の番号
	
	array_move a, p, t
	
	// 表示
	pos 140, 20
	mes "array_ Move"
	array_Print a
	return
	
//------------------------------------------------
// 交換
//------------------------------------------------
*LSwap
	// 交換する要素２つ
	p = 4, 2
	
	array_swap a, p(0), p(1)
	
	// 表示
	pos 260, 20
	mes "array_ Swap"
	array_Print a
	return
	
//------------------------------------------------
// 巡回
//------------------------------------------------
*LRotate
	array_Rotate a
	
	// 表示
	pos 380, 20
	mes "array_ Rotate"
	array_print a
	return
	
//------------------------------------------------
// 除去
//------------------------------------------------
*LRemove
	// 除去する番号
	p = 3
	
	array_remove a, p
	
	// 表示
	pos 500, 20
	mes "array_ Remove"
	array_print a		// (6) は除去された残骸
	
	stop
	
#endif

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 0

#define global array_print(%1) array_iter(%1, print %1(cnt))

	a = 1, 2, 3, 4, 5
	
	array_add   a, 10
	array_mul   a, -1
	array_print a
	
	a(0, 1) = 1, 2, 3, 4, 5
	array_copy  b, a
	
	stop
	
#endif

#endif
