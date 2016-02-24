// Clrtxt モジュール

#ifndef __CLRTXT_OPTIMIZE_AS__
#define __CLRTXT_OPTIMIZE_AS__

#include "Mo/ini.as"

#module ClrtxtOptimize_mod

//---- マクロを定義 ------------------------------
// 文字列操作マクロ
#define StrDel(%1,%2=offset,%3=size) memcpy %1,%1,strlen(%1)-((%2)+(%3)),(%2),(%2)+(%3) : memset %1,0,%3,strlen(%1)-(%3)
#define StrInsert(%1=strvar,%2="",%3=offset) _StrInsert_len = strlen(%2):\
	sdim _StrInsert_temp, _StrInsert_len +2 : _StrInsert_temp = %2 :\
	memexpand %1, strlen(%1) + (%3) + _StrInsert_len + 2 :\
	memcpy %1,%1, strlen(%1) - (%3), (%3) + _StrInsert_len, %3 :\
	memcpy %1, _StrInsert_temp, _StrInsert_len, %3, 0
	
#define PrmLast getstr mystr, tmp, 8, 0, 17

#define ctype LibName(%1=1) ""+ ClrtxtLib +"ClrtxtLib"+ str(%1) +".ini"
#define InputStr(%1) poke Clrtxt, WriteSize, (%1)+"\n" : WriteSize += strsize
#define InputLine    poke Clrtxt, WriteSize, tmp +"\n" : WriteSize += strsize
//-----
#define Input10Num(%1) \
	getstr tmp(1), tmp, 8, 0, 32			/* 読み込む */:\
	if (peek(tmp(1), 0) == '-') {			/* 先頭が - なら */:\
		InputStr "@("+ %1 +")-1"			/* 負数(全許可) */:\
	} else {\
		num = strsize, 0					/* 読み込んだサイズ */:\
		repeat num							/* 2進数を10進数に変換 */:\
			num(1) += (peek(tmp(1), num-(cnt+1))=='1') * (1 << cnt):\
		loop : InputStr "@("+ %1 +")"+ num(1)		/* 10進数で入力 */\
	}
//-----
#define LoadSomePrms(%1,%2=11) sdim prm, 64, 2 :\
	num = 8, 0, 0									/* 初期化 */:\
	repeat											/**/:\
		memset prm, 0, 11							/* 確保 */:\
		getstr prm, tmp, num, ',', 64				/* 定数読み出し */:\
		if ( prm == "" ) { break }					/* 空文字列なら終了 */:\
		num += strsize								/* インデックス増加 */:\
		GetINI %1, prm, prm(1), %2, "0", LibName(1)	/* prm(1) に読み込み */:\
		num(1) |= int(prm.1)						/* 追加 */:\
	loop : InputStr "@(C"+ %1 +")"+ num(1)			/* */:\
//-----
#define NEXTX_Start /* Renzoku 開始時の処理 */:\
	if ( Renzoku <= 0 ) {					/* 命令の後なら */:\
		InputStr "@(NEXTX)0000000000"		/* 10 桁確保 */:\
		RenzokuStart = WriteSize - 20		/* 記憶しておく */:\
	}

#define NX_MIN 4		// NEXTX を埋め込む最小の数
//------------------------------------------------

//####### Clrtxt の位置を知らせる
#deffunc ClrtxtLibIs var LibVar
	dup  ClrtxtLib,      LibVar
	return
	
//######## Clrtxt を最適化する #####################################################################
#deffunc ClrtxtOptimize str p1, var _buf, local index, local WriteSize, local Renzoku, local len, local dir
	mref mystr, 65
	dim num, 3
	sdim dir, MAX_PATH
	if ( getpath(p1, 32) == "" ) {		// 相対パス
		dir = ""+ ClrtxtLib +""+ p1		// ライブラリのパスをつける
	} else {							// 絶対パス
		dir = p1						// そのまま
	}
	
	// ファイルから読み込む
	exist ""+ dir								// サイズを調べる
	if (strsize == -1) { return -1 }			// 無いなら終わり
	
	sdim Clrtxt, strsize + MAX_PATH + 5			// 確保
	bload dir, Clrtxt, strsize					// 読み込む
	len = strsize								// 長さ取得
	if (strmid(Clrtxt, 0, 8) != "@(CLRTS)") {	// clrtxt の記号(CoLoR Text Start)
		return -1								// 別アプリと思われる (ほぼあり得ないけど)
	}
	sdim tmp, 64
		 tmp = "@(RESET)"
	memcpy    Clrtxt, tmp, 8, 0, 0				// @(RESET) で上書き ( @(CLRTS) を削除 )
	StrInsert Clrtxt, dir, 8					// パスを書き込む
	len += strlen(dir)							// パス分サイズが伸びる
	
	// 最適化処理を行う
	dim    num, 3
	sdim   tmp, 64, 3				// tmp = 1 line (1 & 2) = any
	sdim   buf, strlen(Clrtxt) +1	// 移転用に確保
	memcpy buf, Clrtxt,  len		// コピー
	memset Clrtxt, NULL, len		// 消去
	
//---- @(INPUT) を展開する -----------------------
	sdim filebuf
	index = 0
	while
		num = instr(buf, index, "@(INPUT)")
		if ( num < 0 ) { _break }
		
		index += num
		
		// @ の前が改行かどうか
		if ( index > 2 ) {
			if ( peek(buf, index - 1) != 0x0D && peek(buf, index - 1) != 0x0A ) {
				index += 8
				_continue
			}
		}
		
		getstr tmp, buf, index + 8			// ファイルパスを取得する
		
		if ( getpath(tmp, 32) == "" ) {
			tmp = ClrtxtLib +"\\"+ tmp		// 絶対パスにする
		}
		
		exist tmp
		if ( strsize < 0 ) { index += 8 : _continue }	// なければ無視
		
		notesel  filebuf
		noteload tmp		// ロード
		noteunsel
		
		// @(INPUT)... を削除
		StrDel    buf, index, 8 + strlen(tmp)
		
		// ファイルの文章を挿入
		StrInsert buf, filebuf, index
		
		index += strlen(filebuf)
		
	wend
	
	sdim filebuf
	
//---- Clrtxt に書き込む -------------------------
	dim  num, 3
	sdim tmp, 64, 3				// tmp = 1 line (1 & 2) = any
	sdim prm, 64, 2				// パラメータ用
	fCom  = false				// 複数行コメント
	index = 0
	len   = strlen(buf)
	memexpand Clrtxt, len + 256
	
	do
		getstr tmp, buf, index		// 一行取得
		index += strsize
		
		if ( fCom ) {
			// 複数行コメントモード( @*/ で終了 )
			if ( peek(tmp, 0) == '@' && wpeek(tmp, 1) == 0x2F2A ) {
				fCom = false
			}
			_continue
		}
		
		// 命令か？
		if ( peek(tmp, 0) == '@' ) {			// 命令なら
			switch ( strmid(tmp, 2, 5) )		// 命令部分を取得
			// Entry
			case "ENTRY"
				NEXTX_Start							// NEXTX 埋め込み用処理
				num = 8								// 開始位置( 命令の次 )
				repeat
					getstr tmp(1), tmp, num, ','		// CSV
					num += strsize						//
					if ( peek(tmp(1)) == 0 ) { break }	// 空文字を取得した
					InputStr  tmp(1)					// 無条件で展開
					Renzoku ++
				loop
				_continue : swbreak
			case "COLOR"
				PrmLast
				GetIni "Color", refstr, tmp(1), 12, "", LibName(2)	// ClrtxtLib2 を使う
				InputStr "@(CCREF)"+ tmp(1)							// CCREF 命令に置換しておく
				swbreak
			// nColorRef
			case "CCREF"
				getstr   tmp(1), tmp, 8, , 20					// 20byte まで
				if( peek(tmp(1)) == '$') {							// 先頭が $ なら $BBGGRR
					InputStr "@(CCREF)"+ int(tmp(1))				// 16進数 -> 10進数
				} else {
					InputStr tmp									// そのまま入力
				}
				swbreak
			// nPermission
			case "KYOKA" : Input10Num "KYOKA"		: swbreak	// nPermission
			case "LEVEL" : InputLine				: swbreak	// nLevel
			case "CFLAG" : LoadSomePrms "FLAG", 12	: swbreak	// nFlag
			case "CIDPD" : LoadSomePrms "IDPD", 12	: swbreak	// nIndependence
			
			// nType
			case "CTYPE" // (nType) 定数を書き込む
				PrmLast
				GetINI "TYPE", refstr, prm, 64, "0", LibName(1)	// 定数を読み込む
				InputStr "@(CTYPE)"+   prm
				swbreak
			case "RESET" : InputLine				: swbreak	// Reset
			case "LDEND" : InputLine	: _break	: swbreak	// 読み込み終了
			default
				if ( wpeek(tmp, 1) == 0x2F2F ) { _continue }	// "@//" のコメント
				if ( wpeek(tmp, 1) == 0x2A2F ) {				// "@/*" の複数行コメント
					fCom = true
					_continue
				}
				goto *def@ClrtxtOptimize_mod
			swend
			
			if ( Renzoku > 0 ) {				// 一つ以上なら
				if ( Renzoku < NX_MIN ) {		// 少なければ
					StrDel Clrtxt, RenzokuStart, 20			// 確保した分を削除
					WriteSize -= 20							// 減った分を戻す
				} else {
					tmp(1) = strf("%010d", Renzoku)			//
					memcpy Clrtxt, tmp(1), 10, RenzokuStart + 8	// コピー
				}
				Renzoku = 0
			}
		} else {
			*def@ClrtxtOptimize_mod
			// 定義
			num = strlen(tmp)								// 長さ
			if ( num ) {									// 何かがある
				NEXTX_Start									// NEXTX 埋め込み用処理
				memexpand Clrtxt, WriteSize + num + 2		// NULL も併せて確保
				InputLine									// 一行を書き込む
				Renzoku ++			// カウンタ
			}
		}
	until (index >= len)
	
	// 最後の NEXTX 処理
	if ( Renzoku > 0 ) {				// 一つ以上なら
		if ( Renzoku < NX_MIN ) {		// 少なければ
			StrDel Clrtxt, RenzokuStart, 20			// 確保した分を削除
			WriteSize -= 20							// 減った分を戻す
		} else {
			tmp(1) = strf("%010d", Renzoku)				//
			memcpy Clrtxt, tmp(1), 10, RenzokuStart + 8	// コピー
		}
		Renzoku = 0
	}
	
	sdim   _buf,         WriteSize + 1
	memcpy _buf, Clrtxt, WriteSize, 0, 0
	
	sdim buf   , 0
	sdim Clrtxt, 0
	
	return WriteSize
	
//######## Clrtxt を取り除く #######################################################################
#deffunc ClrtxtDelete var _buf, str p2, local len, local dir
	sdim tmp, 320	// 一行
	dim  num, 3		// Start, index, End
	sdim dir, 260
	
	if (getpath(p2, 32) == "") {			// 相対パスなら
		dir = ClrtxtLib + p2				// Library のディレクトリを追加
	} else {								// 絶対パスなら
		dir = p2							// そのまま格納
	}
	len = strlen(_buf)						// Clrtxt の長さ
	num = instr( _buf, 0, "@(RESET)"+ dir )	// 削除の先頭を探す
	if ( num < 0 || len <= 0 ) {
		return -1							// 無い = Error
	}
	
	num(2) = num + strlen(dir) + 10			// 終端捜索の起点 ( @(RESET)PATH の次の行 )
	// 終端を探す
	repeat
		num(1) = instr(_buf, num(2), "@(RESET)")
		if (num(1) == -1) {					// 無いなら
			num(2) = len					// 終端まで削除する
			break
		}
		num(2) += num(1)
		
		if ( num(2) >= len ) { num(2) = len : break }
		
		getstr tmp, _buf, num(2)			// 一行取得
		if (   tmp != "@(RESET)") {			// パス付きなら
			break							// 終わり
		} else {
			num(2) += strlen(tmp)			// 一行分進める
		}
	loop
	
	// 除去
	StrDel _buf, num, num(2) - num		// num ～ 終端 - 先頭
	
	return (num(2) - num)	// 除去したサイズを返す
	
//######## 最適化済み Clrtxt を入力 ################################################################
#ifdef Footy2Create	// 定義されていたら
#define ctype RGB(%1,%2,%3) ((%1) | (%2) << 8 | (%3) << 16)
#define ClrLoadReset Ctls = EMP_WORD -1, EMPFLAG_NON_CS, 1, 0b0001, -1, RGB(255, 255, 255)
// COLORTXTLOAD 構造体用のマクロ定義
#define nType Ctls(0)
#define nFlag Ctls(1)
#define Level Ctls(2)
#define Kyoka Ctls(3)
#define nIdpd Ctls(4)
#define ColorRef Ctls(5)
#deffunc ClrtxtInput int FootyID, str p2, int bRefresh, local Ctls, local i, local word
	mref mystr, 65
	dim  Ctls, 6		// ClrTxtLoadStruct
	sdim tmp,  64, 2
	sdim word, 64, 2
	
	ClrtxtLength = strlen(p2)		// 長さ
	
	sdim Clrtxt, ClrtxtLength + 1
		 Clrtxt = p2				// コピー
	do
		getstr tmp, Clrtxt, i		// 一行取得
		i += strsize
		
		if (peek(tmp, 0) == '@') {
			tmp(1) = strmid(tmp, 2, 5)		// 命令部分を読み出す
			switch tmp(1)
			case "NEXTX"						// 後ろの X 個を無条件で登録
				getstr mystr, tmp, 8, ' ', 10
				num = int(refstr)				// 数(10 桁)
				if (nType < EMP_LINE_AFTER) {
					repeat num								// 一気に読み込む
						getstr word(0), Clrtxt, i, 0
						i += strsize
					;	logmes word(0)
						Footy2AddEmphasis FootyID, word(0), "", nType +1, nFlag, Level, Kyoka, nIdpd, ColorRef
					loop
				} else {
					repeat num								// 一気に読み込む
						getstr tmp    , Clrtxt,    i : i += strsize
						getstr word(0),    tmp,       0, ' '
						getstr word(1),    tmp, strsize, 0
					;	logmes word(0) +"\t"+ word(1)
						Footy2AddEmphasis FootyID, word(0), word(1), nType +1, nFlag, Level, Kyoka, nIdpd, ColorRef
					loop
				}
				swbreak
			case "CCREF" : PrmLast : ColorRef= int( refstr )	: swbreak	// nColorRef
			case "CTYPE" : PrmLast : nType   = int( refstr )	: swbreak	// nType
			case "KYOKA" : PrmLast : Kyoka   = int( refstr )	: swbreak	// nPermission
			case "LEVEL" : PrmLast : Level   = int( refstr )	: swbreak	// nLevel
			case "CFLAG" : PrmLast : nFlag   = int( refstr )	: swbreak	// nFlag
			case "CIDPD" : PrmLast : nIdpd   = int( refstr )	: swbreak	// nIndependence
			case "RESET" : ClrLoadReset							: swbreak	// Reset
			case "LDEND" : _break								: swbreak	// 読み込み終了
			default : goto *@f
			swend
		} else {
			*@
			if (nType < EMP_LINE_AFTER) {
				// 単語強調
				getstr word(0), tmp
			;	logmes word(0) +"\t"+ word(1)
				Footy2AddEmphasisW FootyID, word(0), "", nType +1, nFlag, Level, Kyoka, nIdpd, ColorRef
			} else {
				// 範囲強調
				getstr word(0), tmp,       0, ' '
				getstr word(1), tmp, strsize, NULL
			;	logmes word(0) +"\t"+ word(1)
				Footy2AddEmphasisW FootyID, word(0), word(1), nType +1, nFlag, Level, Kyoka, nIdpd, ColorRef
			}
		}
	until ( i >= ClrtxtLength ) 	// 長さを超えるまで
	
	if ( bRefresh ) {
		Footy2FlushEmphasis FootyID		// 色分け確定
		Footy2Refresh       FootyID
	}
	return
#endif	/* Footy2Create */

#global

#if 0

#uselib "winmm.dll"
#cfunc timeGetTime "timeGetTime"

	sdim ClrtxtLib, MAX_PATH
	ClrtxtLib = "D:/Docs/prg/hsp/Project/だれでもHTML/Owner/ClrtxtLib"
	ClrtxtLibIs ClrtxtLib		// 変数をクローンさせる
	
	sdim buf, 320
	time = timeGetTime()
	ClrtxtOptimize "ClrtxtBasic.clrtxt", buf
	time = timeGetTime() - time
	logmes "strsize\t : "+ stat
	logmes "strlen\t : " + strlen(buf)
	logmes "time\t : "   + time
	
	sdim   Clrtxt, strlen(buf) * 2
	memcpy Clrtxt, buf, strlen(buf)
	
	sdim buf
	
	ClrtxtOptimize ClrtxtLib +"Hold/HSPDA.clrtxt", buf
	Clrtxt += buf
	
	mesbox Clrtxt, ginfo(12), ginfo(13)
;	mesbox buf, ginfo(12), ginfo(13)
	
	assert 0
	
	ClrtxtDelete Clrtxt, "ClrtxtBasic.clrtxt"
	objprm 0, Clrtxt; +"\nend"
	
	stop
#endif

#endif
