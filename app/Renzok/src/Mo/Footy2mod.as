#ifndef __FOOTY2MOD_AS__
#define __FOOTY2MOD_AS__

;#include "Footy2.as"

//-------- これは上大が勝手に追加したもの ----------------------------------------------------------
#module
#define ctype IsSJIS1st(%1) ((0x81<=(%1)&&(%1)<=0x9F)||(0xE0<=(%1)&&(%1)<=0xFC))/* 漢字第一バイトを判定 */
#define ctype which_int(%1,%2,%3) ((%2)*((%1)!=0)||(%3)*((%1)==0))

// 文字数を返す
#defcfunc strlenW var p1
	nChar = 0
	count = 0
*@
		chr = peek(p1, count)
		if ( chr == 0 ) { return nChar }
		if ( IsSJIS1st(chr) ) {
			count ++
		}
		nChar ++
		count ++
	goto *@before
	return 0
	
// 文字数と長さを相互変換
// p3 が 偽：文字数->長さ 真：その逆
#defcfunc CnvStrnumLen var p1, int p2, int p3
	nChar = 0	// 文字数
	count = 0	// 見ている位置(長さ)
*@
		if ( p3 == 0 && nChar >= p2 ) {	// 文字数まで達した
			return count
		} else
		if ( p3 != 0 && count >= p2 ) {	// 長さまで達した
			return nChar
		}
		
		chr = peek(p1, count)
		if ( chr == 0 ) { return which_int(p3, nChar, count) }
		if ( IsSJIS1st(chr) ) {			// 二バイト文字か？
			count ++
		}
		nChar ++
		count ++
	goto *@before
	return
	
/**
 * 行頭の文字インデックスを返す
 * @prm p1 var	: 文字列型変数
 * @prm p2 int	: 行番号 ( 0から始まる )
 * @prm p3 int	: 戻り値フラグ
 * @return
 *		p3 == 1 : バイト数
 *		p3 == 2 : 文字数
 *		else    : varptr(ret) : ret = バイト数, 文字数
 */
#defcfunc GetCharIndexAtLineTop var p1, int p2, int p3
	// 行数から文字数を求める
	i = 0
	n = 0
	nChar = 0
	while n < p2
		chr = peek(p1, i)
		if ( chr == 0 ) { _break }			// NULLなら終了
		
		// 改行か
		if ( chr == 0x0A || chr == 0x0D ) {
			if ( chr == 0x0D ) {			// CarriageReturn + LineFeed 形式
				// CR + LF 形式
				if ( peek(p1, i + 1) == 0x0A ) {
					i ++
				}
			}
			n ++	// 改行する
		} else : if ( IsSJIS1st(chr) ) {
			i ++
		}
		nChar ++
		i ++
	wend
	
	if ( p3 == 1 ) {
		return i
	} else : if ( p3 == 2 ) {
		return nChar
	}
	ret = i, nChar
	return varptr(ret)
	
#global

#module footymod
#define _true_  1
#define _false_ 0

#uselib "user32.dll"
#func GetScrollInfo "GetScrollInfo" int,int,int
#func GetWindowRect "GetWindowRect" int,int

#define ctype IsSJIS1st(%1) ((0x81 <= (%1) && (%1) <= 0x9F)||(0xE0 <= (%1) && (%1) <= 0xFC)) ; 漢字第一バイトを判定
##define ctype IsSJIS2nd(%1)((0x40 <= (%1) && (%1) <= 0x7E)||(0x80 <= (%1) && (%1) <= 0xFC)) ; 漢字第二バイトを判定

// 選択状態があるか
#defcfunc IsSelOnFooty int FootyID
	Footy2GetSel FootyID, 0, 0, 0, 0	// 選択状態かどうかを取得(無ければ真)
	return (stat != -5)					// 選択されていれば真
	
// Footy から全文を取り出し、p2(= buf) に格納する
#define global GetAllTextInFooty(%1,%2,%3=LM_AUTOMATIC) _GetAllTextInFooty %1,%2,%3
#deffunc _GetAllTextInFooty int FootyID, var _buf, int LineType
	len = Footy2GetTextLengthW( FootyID, LineType )			// 長さを取得
	len <<= 1							// 二倍にする
	
	sdim _buf, len + 12
	Footy2GetTextW FootyID, varptr(_buf), LineType, len + 2	// 文字列取得
	
	_buf = cnvwtos(_buf)				// Wide から SHIFT_JIS に変換
	if ( len < 260 ) {
		_buf = strmid(_buf, 0, len)		// 260 以下なら、パスが混じっている可能性がある
	}
	return _false_
	
// Footy から p2 の一行を取り出し、p3(= buf) に格納する
#deffunc GetLineInFooty int FootyID, int p2, var _buf, local wchr
	sdim _buf, 64								// 文字列にしておく & 初期化
	len = Footy2GetLineLengthW(FootyID, p2)		// 長さを取得
	if ( len <= 0 ) { return _true_ }
	
	len <<= 1	// 2倍にする
	
	sdim _buf, len + 64							// 多めに確保しておく
	ptr = Footy2GetLineW(FootyID, p2)			// 文字列ポインタを取得
	if ( ptr == 0 ) { return }
	
	sdim   wchr, 64
	dupptr wchr, ptr, len, vartype("str")	// 文字列型
	
	_buf = cnvwtos(wchr)					// Wide から SHIFT_JIS に変換
	if ( len < 260 ) {
		_buf = strmid(_buf, 0, len)			// 260 以下なら、パスが混じっている可能性がある
	}
	return _false_
	
// Footy から選択されている文字列を取り出し、p2(= buf) に格納する
#define global GetSelTextInFooty(%1,%2,%3=LM_AUTOMATIC) _GetSelTextInFooty %1,%2,%3
#deffunc _GetSelTextInFooty int FootyID, var _buf, int LineType
	sdim _buf
	len = Footy2GetSelLengthW(FootyID, LineType)	// 長さを取得
	len <<= 1										// 二倍にする
	
	sdim _buf, len + 64
	Footy2GetSelTextW FootyID, varptr(_buf), LineType, len + 2	// 文字列取得
	
	_buf = cnvwtos(_buf)				// Wide から SHIFT_JIS に変換
	if ( len < 260 ) {
		_buf = strmid(_buf, 0, len)		// 260 以下なら、パスが混じっている可能性がある
	}
	return _false_
	
// 選択文字列の前後に括弧を挿入
#define global SetBracket(%1,%2,%3) _SetBracket %1,""+(%2),""+(%3)
#deffunc _SetBracket int FootyID, str p2, str p3, local _n	// FootyID, 前, 後
	dim _n, 3
	Footy2GetSel FootyID, varptr(_n.1), varptr(_n.2), 0, 0	// 選択範囲の前側を取得
	GetSelTextInFooty      FootyID, buf						// 選択している文字列を buf に格納する
	Footy2SetSelTextW      FootyID, p2 +""+ buf +""+ p3		// 追加
	Footy2SetCaretPosition FootyID, _n(1), _n(2)			// キャレット位置を元に戻す
	return
	
// カーソルを動かす
#deffunc GotopOnFooty  int FootyID
	Footy2SetCaretPosition FootyID, 0, 0, _true_
	return
	
#deffunc GobtmOnFooty  int FootyID, local nLine, local nPos
	nLine = Footy2GetLines(FootyID) - 1				// 最終行の行番号
	nPos  = Footy2GetLineLengthW(FootyID, nLine)
	Footy2SetCaretPosition FootyID, nLine, nPos, _true_
	return
	
#deffunc GoCaretOnFooty int FootyID, array Caret
	Footy2SetCaretPosition  FootyID, Caret(0), Caret(1), _true_
	return
	
// カーソル位置の取得
#deffunc GetCaretOnFooty int FootyID, array Caret
	dim Caret, 2
	Footy2GetCaretPosition FootyID, varptr( Caret(0) ), varptr( Caret(1) )
	return (stat)
	
#deffunc SetCaretOnFooty int FootyID, array Caret, int bRefresh
	Footy2SetCaretPosition FootyID, Caret(0), Caret(1), bRefresh
	return stat
	
// カーソル位置が安全か確認、おかしければ調節
#deffunc AdjustCaretOnFooty int FootyID, array _Caret, local nRet, local temp
	nRet = 0
	if ( _Caret(0) < 0 ) { _Caret(0) = 0 : nRet = 1 }	// 負数なら調節する
	if ( _Caret(1) < 0 ) { _Caret(1) = 0 : nRet = 2 }	// 〃
	
	if ( _Caret(0) >= Footy2GetLines(FootyID) ) {
		 _Caret(0)  = Footy2GetLines(FootyID) - 1	// 行数の異常
		 nRet = 1
	}
	if ( _Caret(1) >= Footy2GetLineLengthW(FootyID, _Caret(0)) ) {
		 _Caret(1)  = Footy2GetLineLengthW(FootyID, _Caret(0))
		 nRet = 2
	}
/*
	sdim temp, 511
	GetLineInFooty FootyID, _Caret(0), temp			// 一行を取得 (桁数チェック)
	if ( _Caret(1) >= strlen(temp) ) {				// でかすぎれば
		 _Caret(1)  = strlen(temp)					// 調整
		 nRet = 2
	}
*/
	return nRet
	
// 範囲を選択する
#deffunc SetSelectOnFooty int FootyID, array select, int bRefresh
	Footy2SetSel FootyID, select(0), select(1), select(2), select(3), bRefresh
	return stat
	
// 選択範囲を取得
#deffunc GetSelectOnFooty int FootyID, array select
	dim select, 4
	Footy2GetSel FootyID, varptr(select(0)), varptr(select(1)), varptr(select(2)), varptr(select(3))
	return (stat)
	
// 範囲の文字列を得る
#deffunc GetTextFromRangeInFooty int FootyID, array range,  local select, local sResult, local bSelected
	bSelected = IsSelOnFooty(FootyID)
	if ( bSelected ) {
		GetSelectOnFooty FootyID, select		// 現在の選択範囲
	} else {
		GetCaretOnFooty  FootyID, select		// 現在のキャレット位置
	}
	
	SetSelectOnFooty  FootyID, range,  _false_	// 指定範囲を選択する
	GetSelTextInFooty FootyID, sResult			// 範囲文字列を得る
	
	if ( bSelected ) {
		SetSelectOnFooty FootyID, select, _false_	// 選択範囲を元に戻す
	} else {
		SetCaretOnFooty  FootyID, select, _false_	// キャレット位置を元に戻す
	}
	return sResult
	
// 全体の文字列長
#define global ctype GetLengthInFooty(%1,%2=LM_AUTOMATIC) _GetLengthInFooty(%1,%2)
#defcfunc _GetLengthInFooty int FootyID, int LineType, local _buf
	sdim _buf
	GetAllTextInFooty FootyID, _buf, LineType		// 全ての文字列を取得
	return strlen(_buf)
	
// 範囲の文字列長を取得
#define global ctype GetLengthBySelectInFooty(%1,%2=0,%3=0,%4=0,%5=0,%6=LM_AUTOMATIC) _GetLengthBySelectInFooty(%1,%2,%3,%4,%5,%6)
#defcfunc _GetLengthBySelectInFooty int FootyID, int scL, int scP, int ecL, int ecP, int LineType, local select
	dim select, 4
	GetSelectOnFooty FootyID, select		// 今の選択範囲を取得
	if ( stat < 0 ) {
		GetCaretOnFooty FootyID, select
		select(2) = 0, 0
	}
	
	Footy2SetSel FootyID, scL, scP, ecL, ecP, _false_					// 範囲を選択する
	len = Footy2GetSelLengthW( FootyID, LineType )						// 長さを取得
	Footy2SetSel FootyID, select(0), select(1), select(2), select(3)	// 範囲を元に戻す
	
	if ( len < 0 ) { return 0 }
	return len
	
// 先頭から、指定キャレットまでの文字列長を取得
#defcfunc GetLengthByCaretInFooty int FootyID, int p2, int p3, int p4, local _buf, local offset
	// 文字列を取得する
	GetAllTextInFooty FootyID, _buf, LM_AUTOMATIC
	
	// 行頭までの文字列長
	dupptr  indexAtLinetop, GetCharIndexAtLineTop(_buf, p2), 8
	i     = indexAtLinetop(0)
	nChar = indexAtLinetop(1)
	
	// 文字列を取得する
	GetAllTextInFooty FootyID, _buf, LM_AUTOMATIC
	
	if ( p4 == 2 ) {		// 文字数だけ
		return nChar + p3
	}
	// バイト数を得る
	offset = nChar
	while (nChar - offset) < p3
		chr = peek(_buf, i)
		if ( chr == 0 ) { _break }
		if ( IsSJIS1st(chr) ) {
			i ++
		}
		nChar ++
		i     ++
	wend
	
	if ( p4 == 1 ) {
		return i
	}
	ret = i, nChar
	return varptr(ret)
	
// 文字列長から、キャレット位置を取得する( len は バイト数 )
// ・キャレット位置までの文字数を取得
// ・_Caret(0)の行の_Caret(1)までの桁のバイト数を得る
// ・指定されたバイト数を進める
// ・バイト数を文字数に変換
#define global GetCaretByLengthOnFooty(%1,%2,%3,%4=LM_AUTOMATIC) _GetCaretByLengthOnFooty %1,%2,%3,%4
#deffunc _GetCaretByLengthOnFooty int FootyID, array _Caret, int _len, int LineType, local _buf, local offset
	if ( _len < 0 ) { return _true_ }
	
;	logmes "defualt : "+ logp(_Caret(0), _Caret(1))
;	logmes logv(_len)
	
	// 文字列を取得する
	GetAllTextInFooty FootyID, _buf, LineType
	
	// 行数から文字数を求める
	dupptr   indexAtLinetop, GetCharIndexAtLineTop(_buf, _Caret(0)), 8
	i      = indexAtLinetop(0)
	offset = indexAtLinetop(1)
;	logmes "行数から求めた文字数："+ offset
	
	offset += _Caret(1)			// 桁の文字数を加算
	
;	logmes logv(offset)
	
	// Caret(1) のバイト数を求め、指定バイト進め、文字数に変換する
	sdim   temp, _Caret(1) * 2 + _len + 1
	getstr temp, _buf, i, , _Caret(1) * 2 + 1
	_Caret1_byte = CnvStrnumLen(temp, _Caret(1))	// 文字数を長さに変換
	
;	logmes logv(_Caret1_byte)
	
	// 進める
	i     += _Caret1_byte
	offset = i
	while (i - offset) < _len
		chr = peek(_buf, i)
		if ( chr == 0 ) { _break }
		if ( chr == 0x0D || chr == 0x0A ) {
			if ( chr == 0x0D ) {			// CarriageReturn + LineFeed 形式
				// CR + LF 形式
				if ( peek(_buf, i + 1) == 0x0A ) {
					i ++
				}
			}
			_Caret(0) ++
			_Caret(1) = -1	// 改行する (インクリメントされるので -1)
		} else : if ( IsSJIS1st(chr) ) {
			i ++
		}
		_Caret(1) ++
		i ++
	wend
	return _false_
	
/**
* 行数を拡張する
* @param fid	: FootyID
* @param lines	: 拡張後の行数
* @return int	: 拡張した行数 or 負数(エラー)
**/
#deffunc SetLinesOnFooty int FootyID, int nLine, local _buf, local _Caret
	n = Footy2GetLines( FootyID )		// 今の行数
	if ( n < 0 || n >= nLine ) {		// 失敗
		return -1
	}
	
	// 改行コードの文字列を作成
	sdim _buf, (nLine - n) * 2 + 64
	repeat nLine - n
		wpoke _buf, cnt * 2, 0x0A0D
	loop
	
	// 追加
	dim _Caret, 2
	GetCaretOnFooty		FootyID, _Caret	// 今のキャレットを取得
	GoBtmOnFooty		FootyID			// 最後尾に移動
	Footy2SetSelTextW	FootyID, _buf	// 挿入
	
	// キャレット位置を戻す
	GoCaretOnFooty FootyID, _Caret
	return nLine - n
	
//######## 文字ドラッグに役立つ ################################################
#define global ctype GetFirstVisibleLineOnFooty(%1,%2) GetFirstVisibleCaretOnFooty(%1,%2,1)
#define global ctype GetFirstVisibleColumnOnFooty(%1,%2) GetFirstVisibleCaretOnFooty(%1,%2,0)
#defcfunc GetFirstVisibleCaretOnFooty int FootyID, int nViewID, int flag, local ScrollInfo
	dim ScrollInfo, 7
	ScrollInfo = 28, 4
	
	GetScrollInfo Footy2GetWnd(FootyID, nViewID), flag, varptr(ScrollInfo)
	return ScrollInfo(5)
	
#define ctype IsInRect(%1=RECT,%2=mousex,%3=mousey)  ( (((%1(0)) <= (%2)) && ((%2) <= (%1(2)))) && (((%1(1)) <= (%3)) && ((%3) <= (%1(3)))) )

// 文字ドラッグ開始可能か
#defcfunc CanStartDragOnFooty int FootyID, int nViewID, int FontSize, int mx, int my, local Caret
	dim Caret, 2, 3
	dim select, 4
	dim rect, 4
	
	// 見える範囲の最小と最大を確保
	Caret(0, 0) =       GetFirstVisibleLineOnFooty  ( FootyID, nViewID )
	Caret(1, 0) =       GetFirstVisibleColumnOnFooty( FootyID, nViewID )
	Caret(0, 1) = Caret(0) + Footy2GetVisibleLines  ( FootyID, nViewID )
	Caret(1, 1) = Caret(1) + Footy2GetVisibleColumns( FootyID, nViewID )
	
	// Footyコントロールの RECT を取得
	GetWindowRect Footy2GetWnd( FootyID, nViewID ), varptr(rect)
	if ( IsInRect(rect, mx, my) == _false_ ) {
		return _false_
	}
	
	// 選択範囲を取得
	GetSelectOnFooty FootyID, select
	
	// 行番号＆ルーラーの幅を取得
	Footy2GetMetrics FootyID, SM_LINENUM_WIDTH, varptr(linenumWidth)	// 行番号の幅
	Footy2GetMetrics FootyID, SM_RULER_HEIGHT , varptr(rulerHeight)		// ルーラーの高さ
	
	logmes dbgstr(linenumWidth)
	logmes dbgstr(rulerHeight)
	
	// マウスの下のキャレット位置を取得
	Caret(0, 2) = ( mx - (rect(0) + linenumWidth) ) / FontSize
	Caret(0, 3) = ( my - (rect(1) +  rulerHeight) ) / (FontSize + 1)
	
	logmes dbgpair(Caret(0, 2), Caret(0, 3))
	
	return 0
	
#global

#endif
