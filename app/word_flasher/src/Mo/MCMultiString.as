// 複数文字列クラス

#ifndef IG_MODULECLASS_MULTI_STRING_AS
#define IG_MODULECLASS_MULTI_STRING_AS

// @ abdata_list のラッパー

; TODO
; ・ソートのアルゴリズム化
; ・一括置換
; ・高速検索
; ・
// @in iterating:
// @	最後尾への追加のみ許可。それ以外への挿入・除去操作は禁止。

#include "abdata/abdata/list.as"
#include "Mo/MCLongString.as"

	sdim stt_clone@MCMultiString

#module MCMultiString mStrlist

//##############################################################################
//        コンストラクタ・デストラクタ
//##############################################################################
//------------------------------------------------
// [i] 構築
//------------------------------------------------
#define global MStr_new(%1) newmod %1, MCMultiString@
#modinit
	List_new mStrlist
	return
	
//------------------------------------------------
// [i] 解体
//------------------------------------------------
#define global MStr_delete(%1) delmod %1
#modterm
	List_delete mStrlist
	return
	
//##############################################################################
//        メンバ命令・関数
//##############################################################################

//################################################
//        雑多系
//################################################
//------------------------------------------------
// [i] 要素数
//------------------------------------------------
#modcfunc MStr_size
	return List_size( mStrlist )
	
#define global MStr_empty MStr_size
#define global MStr_count MStr_size

//------------------------------------------------
// 範囲チェック
//------------------------------------------------
#modcfunc MStr_isValid int idx
	return List_isValid( mStrlist, idx )
	
//################################################
//        取得系
//################################################
//------------------------------------------------
// 値返し ( 命令形式 )
//------------------------------------------------
#modfunc MStr_getv var vResult, int idx
	List_getv mStrlist, vResult, idx
	return
	
//------------------------------------------------
// 値返し ( 関数形式 )
//------------------------------------------------
#modcfunc MStr_get int idx
	return List_get( mStrlist, idx )
	
//------------------------------------------------
// 参照化 ( 命令形式 )
// 
// @! 確保済み領域を越えると反映されない
//------------------------------------------------
#modfunc MStr_clone var vRef, int idx
	List_clone mStrlist, vRef, idx
	return
	
//------------------------------------------------
// 参照を得る ( 関数形式 )
//------------------------------------------------
#define global ctype MStr_ref(%1, %2 = 0) stt_clone@MCMultiString( MStr_ref_core(%1, %2) )
#modfunc MStr_ref_core int idx
	MStr_clone stt_clone, idx
	return 0
	
//################################################
//        設定系
//################################################
//------------------------------------------------
// データ置換
//------------------------------------------------
#define global MStr_set(%1, %2 = "", %3 = 0) _MStr_set %1, "" + (%2), %3
#define global MStr_setv(%1, %2, %3 = 0)     _MStr_set %1,       %2,  %3
#modfunc _MStr_set str s_value, int idx
	List_set mStrlist, s_value, idx
	return
	
//################################################
//        操作系
//################################################
//------------------------------------------------
// 挿入
//------------------------------------------------
#define global MStr_insert(%1,%2,%3=0) _MStr_insert %1, "" + (%2), %3
#modfunc _MStr_insert str s_value, int idx
	List_insert mStrlist, s_value, idx
	return
	
//------------------------------------------------
// 最後尾への追加
//------------------------------------------------
#define global MStr_add(%1,%2) MStr_insert %1, %2, MStr_size(%1)
#define global MStr_push_back  MStr_add

//------------------------------------------------
// 削除
//------------------------------------------------
#modfunc MStr_remove int idx
	List_remove mStrlist, idx
	return
	
//------------------------------------------------
// 移動
//------------------------------------------------
;#modfunc MStr_move int idxSrc, int idxDst
;	List__move mStrlist, idxSrc, idxDst
	return
	
//------------------------------------------------
// 交換
//------------------------------------------------
;#modfunc MStr_swap int idx1, int idx2
	;List_swap mStrlist, idx1, idx2
	return
	
//------------------------------------------------
// 巡回
//------------------------------------------------
;#modfunc MStr_rotate
	;List_rotate mStrlist
	return
	
//------------------------------------------------
// 巡回 ( 逆回転 )
//------------------------------------------------
;#modfunc MStr_rotate_back
	;List_rotate_back mStrlist
	return
	
//------------------------------------------------
// 反転
//------------------------------------------------
#modfunc MStr_reverse
	List_reverse mStrlist
	return
	
//################################################
//        その他
//################################################
//------------------------------------------------
// [i] 完全消去
//------------------------------------------------
#modfunc MStr_clear
	List_clear mStrlist
	return
	
//------------------------------------------------
// 空文字列の項目を削除する
//------------------------------------------------
#modfunc MStr_removeVoid  local cntItem, local idx
	cntItem = MStr_size(thismod)
	if ( cntItem == 0 ) { return }
	
	repeat cntItem
		idx = cntItem - (cnt + 1)
		if ( MStr_get(thismod, idx) == "" ) {
			MStr_remove idx
		}
	loop
	
	return
	
//------------------------------------------------
// 特定の文字列の項目(完全一致)を探し、index を返す
// 
// @ 線形探索
//------------------------------------------------
#modcfunc MStr_findString str sTarget,  local idx
	idx = -1
	repeat MStr_size(thismod)
		if ( MStr_get(thismod, cnt) == sTarget ) {
			idx = cnt
			break
		}
	loop
	return idx
	
#define global ctype MStr_existsString(%1,%2) ( MStr_findString(%1, %2) >= 0 )
	
//------------------------------------------------
// 特定の文字列の項目を削除する
// 
// @prm bGlobal : すべての項目を削除するか
//------------------------------------------------
#modfunc MStr_removeString str sTarget, int bGlobal,  local idx
	repeat
		idx = MStr_findString(thismod, sTarget)
		if ( bGlobal == false || idx < 0 ) {
			break
		}
		MStr_remove thismod, idx
	loop
	return
	
//################################################
//        連結
//################################################
#define global MStr_cat            MStr_chain
#define global MStr_catSplitString MStr_chainSplitString
#define global MStr_catNoteString  MStr_chainNoteString
#define global MStr_catArray       MStr_chainArray

//------------------------------------------------
// [i] 連結
//------------------------------------------------
#modfunc MStr_chain var mv_src
	// 一つずつマメに追加していく
	repeat MStr_size(mv_src)
		MStr_add thismod, MStr_get(mv_src, cnt)
	loop
	return
	
//------------------------------------------------
// 区切り文字列を追加する
//------------------------------------------------
#modfunc MStr_chainSplitString str split_string, str sSplitter,  local sSrc, local arr
	sSrc = split_string
	split@hsp sSrc, sSplitter, arr
	MStr_chainArray thismod, arr
	return
	
/*
#modfunc MStr_chainSplitString str split_string, str prm_sSplitter,  local sSrc, local stmp, local index, local sSplitter, local lenSplitter
	sdim stmp, 320
	
	index       = 0
	sSplitter   = prm_sSplitter
	lenSplitter = strlen(sSplitter)
	sSrc        = split_string
	
	// 区切ってマメに追加
	repeat
		splitNext stmp, sSrc, index, sSplitter, lenSplitter
		if ( stat == failure ) { break }
		
		MStr_add thismod, stmp
	loop
	
	return
	
//------------------------------------------------
// 次の区切り文字列までを切って返す
//------------------------------------------------
#deffunc splitNext@MCMultiString var result, var sSrc, var index, var sSplitter, int lenSplitter,  local iFound, local lenSrc
	// 改行区切りの場合
	if ( sSplitter == "\n" ) {
		getstr result, sSrc, index : index += strsize
		
		if ( strsize == 0 ) {
			return failure
		}
		
	// 汎用
	} else {
		iFound = instr(sSrc, index, sSplitter)
		
		if ( iFound >= 0 ) {
			result  = strmid(sSrc, index, iFound)
			index += iFound + lenSplitter
			
		} else {
			lenSrc = strlen(sSrc)
			if ( lenSrc <= index ) {
				return failure
			} else {											// まだ文字列が残っている場合
				result = strmid(sSrc, index, lenSrc - index)	// 最後まで切り出す
				index  = lenSrc
			}
		}
	}
	
	return success
//*/
	
//------------------------------------------------
// 複数行文字列を追加する
//------------------------------------------------
#define global MStr_chainNoteString(%1,%2) MStr_chainSplitString %1, %2, "\n"

//------------------------------------------------
// カンマ区切り文字列を追加する
//------------------------------------------------
#define global MStr_chainCsvString(%1,%2) MStr_chainSplitString %1, %2, ","

//------------------------------------------------
// 一次元文字列配列を追加する
//------------------------------------------------
#modfunc MStr_chainArray array arrString
	foreach arrString
		MStr_add thismod, arrString(cnt)
	loop
	return
	
//################################################
//        変換
//################################################
//------------------------------------------------
// 複数行文字列にする
//------------------------------------------------
#define global MStr_toNoteString(%1,%2) MStr_toSplitString %1, %2, "\n"

//------------------------------------------------
// カンマ区切り文字列にする
//------------------------------------------------
#define global MStr_toCsvString(%1,%2) MStr_toSplitString %1, %2, ","

//------------------------------------------------
// 区切り文字列にする
// 
// @result (stat) : buf の文字列長 [byte]
//------------------------------------------------
#modfunc MStr_toSplitString var buf, str prm_sSplitter,  local sSplitter, local ls, local len
	
	sSplitter = prm_sSplitter
	
	// 一つずつマメに連結する
	LongStr_new ls
	repeat MStr_size(thismod)
		if ( cnt ) {
			LongStr_add ls, sSplitter
		}
		LongStr_add ls, MStr_get(thismod, cnt)
	loop
	LongStr_tobuf  ls, buf : len = LongStr_length(ls)
	LongStr_delete ls
	
	return len
	
//------------------------------------------------
// 文字列型配列にする( 一次元 )
//------------------------------------------------
#modfunc MStr_toArray array arrString
	sdim arrString, , MStr_size(thismod)
	
	foreach arrString
		arrString(cnt) = MStr_get(thismod, cnt)
	loop
	
	return
	
//################################################
//        統一関数
//################################################
//------------------------------------------------
// [i] 完全消去
//------------------------------------------------
//------------------------------------------------
// [i] 連結
//------------------------------------------------
// 既述

//------------------------------------------------
// [i] 複製
//------------------------------------------------
#modfunc MStr_copy var mv_from
	MStr_clear thismod
	MStr_chain thismod, mv_from
	return
	
//------------------------------------------------
// [i] 交換
//------------------------------------------------
#modfunc MStr_exchange var mv2,  local mvTemp
	MStr_new  mvTemp
	MStr_copy mvTemp,  thismod
	MStr_copy thismod, mv2
	MStr_copy mv2,     mvTemp
	MStr_delete mvTemp
	return
	
//------------------------------------------------
// [i] 反復子::初期化
//------------------------------------------------
#modfunc MStr_iterInit var iterData
	List_iterInit mStrlist, iterData
	return
	
//------------------------------------------------
// [i] 反復子::更新
//------------------------------------------------
#modcfunc MStr_iterNext var vIt, var iterData
	return List_iterNext( mStrlist, vIt, iterData )
	
//################################################
//        整列
//################################################
//------------------------------------------------
// 整列
//------------------------------------------------
#modfunc MStr_sort int mode
	List_sort mStrlist, mode
	return
	
/*
#modfunc MStr_sort  local ar, local len, local tr, local n, local m, local p, local p1, local e1, local p2, local e2, local s, local mv_temp
	dim ar, MStr_size(thismod)
	
	foreach ar
		ar(cnt) = cnt
	loop
	
	// マージソート
	len = MStr_size(thismod)	// ソートする配列長
	dim tr, len					// temp array
	
	repeat
		// セグメントサイズ定義
		n = 1 << cnt	// マージサイズ
		m = n * 2		// セグメント サイズ
		
		// 全セグメントに対して
		repeat
			// セグメント 領域定義
			p  = m * cnt				// セグメント開始点
			p1 = p						// パート 1 開始点
			e1 = p1 + n					// パート 1 終了点
			p2 = e1						// パート 2 開始点
			e2 = limit(p2 + n, 0, len)	// パート 2 終了点 (clipping)
			s  = e2 - p1				// セグメント サイズ
			
			if ( s <= n ) { break }		// セグメント サイズが閾値以下なら マージしない
			
			// セグメント内 マージ
			repeat s
				if ( p2 >= e2 ) {				// p2 領域外
					tr(cnt) = ar(p1) : p1 ++
				} else : if ( p1 >= e1 ) {		// p1 領域外
					tr(cnt) = ar(p2) : p2 ++
				} else : if ( MStr_get(thismod, ar(p1)) != MStr_get(thismod, ar(p2)) <= 0 ) {	// 比較 & マージ (strcmp)
					tr(cnt) = ar(p1) : p1 ++
				} else {
					tr(cnt) = ar(p2) : p2 ++
				}
			loop
			
			// マージされた配列をソース配列に貼り付け
			memcpy ar(p), tr, s * 4
		loop
		
		// ソート 完了
		if ( n >= len ) : break
	loop
	
	// 元の配列の順番を入れ替えてテンポラリ配列に代入
	MStr_new  mv_temp
	MStr_copy mv_temp, thismod
	
	// 戻り配列に再格納
	MStr_clear thismod
	repeat len
		MStr_add thismod, MStr_get(mv_temp, ar(cnt))
	loop
	return
//*/
	
//################################################
//        ファイル入出力
//################################################
//------------------------------------------------
// ファイルから読み込む
// 
// @ 区切り文字列として読み込む。
// @ 既存のリストに連結する。
//------------------------------------------------
#define global MStr_load(%1,%2,%3="\n") MStr_load_ %1, %2, %3
#modfunc MStr_load_  str filename, str splitter,  local buf
	exist filename
	if ( strsize < 0 ) { return }
	
	sdim            buf, strsize + 1
	bload filename, buf, strsize
	MStr_catSplitString thismod, buf, splitter
	return
	
//------------------------------------------------
// ファイルに保存
// 
// @ 区切り文字列として保存する。
//------------------------------------------------
#define global MStr_save(%1,%2,%3="\n") MStr_save_ %1, %2, %3
#modfunc MStr_save_ str filename, str splitter,  local buf, local memsize, local index
	MStr_toSplitString thismod, buf, splitter
	bsave filename, buf, stat
	return
	
//##############################################################################
//        デバッグ
//##############################################################################
//------------------------------------------------
// デバッグ出力
//------------------------------------------------
#ifdef _DEBUG

#modfunc MStr_dbglog
	logmes "\n[MStr_dbglog]"
	repeat List_size( mStrlist )
		logmes strf("#%02d: ", cnt) + List_get( mStrlist, cnt )
	loop
	return
	
#else
 #define global MStr_dbglog(%1) :
#endif

#global

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 0

#include "d3m.hsp"

	randomize
	
	MStr_new slist
	
	repeat 10
		time = d3timer()
		
		repeat 1000
			
			MStr_clear slist
			MStr_chainCsvString slist, "リンゴ,バナナ,ミカン,Grape,"	// (7 ~ 8)e-2[ms]
			MStr_dbglog         slist
			
		;	MStr_toSplitString  slist, stmp, "|"
			
		;	mes stmp
			
			MStr_sort   slist
		;	MStr_dbglog slist
			
		loop
		
		time = d3timer() - time - 75
		mes "" + time + "[ms]"
	loop
	
	MStr_delete slist
	
	stop
	
#endif

#endif
