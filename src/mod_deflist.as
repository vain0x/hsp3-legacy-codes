// definition list

#ifndef __DEFINITION_LIST_MODULE_AS__
#define __DEFINITION_LIST_MODULE_AS__

#include "Mo/strutil.as"
#include "Mo/HPM_GetToken.as"
#include "Mo/pvalptr.as"

#module deflist mScript, mCount, mFileName, mFilePath, mIdent, mLn, mType, mScope, mInclude, mCntInclude

#include "Mo/HPM_Header.as"

//######## 定数・マクロ ########################################################
#define true  1
#define false 0

//------------------------------------------------
// DEFTYPE
//------------------------------------------------
#const global DEFTYPE_LABEL		0x0001		// ラベル
#const global DEFTYPE_MACRO		0x0002		// マクロ
#const global DEFTYPE_CONST		0x0004		// 定数
#const global DEFTYPE_FUNC		0x0008		// 命令・関数
#const global DEFTYPE_DLL		0x0010		// DLL命令
#const global DEFTYPE_CMD		0x0020		// HPIコマンド

#const global DEFTYPE_CTYPE		0x0100		// CTYPE
#const global DEFTYPE_MODULE	0x0200		// モジュールメンバ

//------------------------------------------------
// 特殊な空間名
//------------------------------------------------
#define global AREA_GLOBAL "global"
#define global AREA_ALL    "*"

//##############################################################################
//                メンバ関数
//##############################################################################
//------------------------------------------------
// 一括して格納する
// 
// @ p2 を負数にすると追加になる
//------------------------------------------------
#define global DefList_set(%1,%2,%3,%4,%5,%6) _DefList_set %1,%2,%3,%4,%5,%6
#define global DefList_add(%1,%2,%3,%4,%5) _DefList_set %1,-1,%2,%3,%4,%5
#modfunc _DefList_set int p2, str ident, int linenum, int deftype, str scope, local iItem
	if ( p2 < 0 ) { iItem = mCount : mCount ++ } else { iItem = p2 }
	mIdent(iItem) = ident
	mLn   (iItem) = linenum
	mType (iItem) = deftype
	mScope(iItem) = scope
	return iItem
	
//------------------------------------------------
// 一括して取得する
//------------------------------------------------
#modfunc DefList_get int p2, var ident, var linenum, var deftype, var scope
	ident   = mIdent(p2)
	linenum = mLn   (p2)
	deftype = mType (p2)
	scope   = mScope(p2)
	return
	
//------------------------------------------------
// 各メンバごとの getter
//------------------------------------------------
#modfunc DefList_getScript var script
	script = mScript
	return
	
#modcfunc DefList_getCount
	return mCount
	
#modcfunc DefList_getFilePath
	return mFilePath
	
#modcfunc DefList_getFileName
	return mFileName
	
#modcfunc DefList_getIdent int p2
	return mIdent(p2)
	
#modcfunc DefList_getLn int p2
	return mLn(p2)
	
#modcfunc DefList_getDefType int p2
	return mType(p2)
	
#modcfunc DefList_getScope int p2
	return mScope(p2)
	
#modcfunc DefList_getCntInclude
	return mCntInclude
	
#modcfunc DefList_getInclude int p2
	return mInclude(p2)
	
//------------------------------------------------
// include ファイルを配列にして返す
//------------------------------------------------
#modfunc DefList_getIncludeArray array p2
	sdim p2,, mCntInclude
	repeat    mCntInclude
		p2(cnt) = mInclude(cnt)
	loop
	return
	
//##############################################################################
//                定義をリストアップする
//##############################################################################
//------------------------------------------------
// 指定文字インデックスのある行番号を取得する
// @private
//------------------------------------------------
#defcfunc GetLinenumByIndex@deflist var text, int p2, int iStart, int iStartLineNum, local linenum, local c
	linenum = iStartLineNum
	
	if ( iStart > p2 ) { return iStartLineNum }
	
	repeat p2 - iStart, iStart
		c = peek( text, cnt )
		if ( c == 0x0D || c == 0x0A ) {		// 改行コード
			linenum ++
			if ( c == 0x0D && peek(text, cnt + 1) == 0x0A ) {
				continue cnt + 2			// CRLF は 2byte
			}
		} else : if ( IsSJIS1st(c) ) {		// 全角文字
			continue cnt + 2				// 次の 1byte は見る必要なし
			
		} else : if ( c == 0 ) {			// '\0' == 終端
			break
		}
	loop
	
	return linenum
	
//------------------------------------------------	
// モジュール空間名を決定する
// @private
//------------------------------------------------
#defcfunc MakeModuleName@deflist var scope, var script, int offset, str defscope, local index
	index = offset
	if ( peek(script, index) == '@' ) {
		index ++
		index += CutIdent(scope, script, index)
		if ( stat == 0 ) { scope = AREA_GLOBAL }
	} else {
		scope = defscope
	}
	return index - offset
	
//------------------------------------------------
// 範囲名を作成する
// @private
//------------------------------------------------
#deffunc MakeScope@deflist var scope, str defscope, int deftype, int bGlobal, int bLocal
	if ( bGlobal ) { scope = AREA_ALL : return }
	
	scope = defscope
	
	if ( bLocal ) { scope += " [local]" }
	return
	
//------------------------------------------------
// 定義をリストアップする
//------------------------------------------------
#modfunc ListupDefinition  local stmp, local index, local textlen, local areaScope, local scope, local linenum, local nowTT, local befTT, local bPreLine, local bGlobal, local bLocal, local deftype, local uniqueCount
	index   = 0
	textlen = strlen(mScript)
	sdim stmp, 250
	sdim name
	sdim scope
	sdim areaScope
	
	dim listIndex, 5	// 文字インデックスのリスト( 高速化のために使う )
	
	uniqueCount = 0
	areaScope   = AREA_GLOBAL
	
	repeat
		// 空白を飛ばす
		index += CntSpaces(mScript, index)
		
		// 最後まで取得できたら終了する
		if ( textlen <= index ) { break }
		
		// 次のトークンを取得
		GetNextToken nowtk, mScript, index, befTT, bPreLine : nowTT = stat
		if ( nowTT == TOKENTYPE_ERROR ) {
			index += strlen(nowtk)
			continue				// 単純に無視するだけ
		}
		
		// トークンの種類ごとに処理をわける
		gosub *L_ProcToken
		
		// インデックスを進める
		index += strlen(nowtk)
		
		befTT = nowTT
	loop
	
	return mCount
	
*L_ProcToken
	switch nowTT
	
	case TOKENTYPE_COMMENT : nowTT = befTT : swbreak
	
	case TOKENTYPE_END		// 文の終了
		nowTT = TOKENTYPE_NONE
		if ( bPreLine && IsNewLine( peek(nowtk) ) ) {
			bPreLine = false
		}
		swbreak
		
	case TOKENTYPE_LABEL	// ラベル
		if ( befTT == TOKENTYPE_NONE ) {	// 行頭の場合のみ
			
			index += strlen(nowtk)
			index += MakeModuleName(scope, mScript, index, areaScope)
			
			// リストに追加
			deftype = DEFTYPE_LABEL
			gosub *L_AddDefList
		}
		swbreak
		
	case TOKENTYPE_PREPROC	// プリプロセッサ命令
		
		if ( IsPreproc(nowtk) ) {
			bPreLine = true
			index   += strlen(nowtk)
			deftype  = 0
			bGlobal  = true
			bLocal   = false
			
			// # と空白を除去する
			getstr nowtk, nowtk, 1 + CntSpaces(nowtk, 1)
			
			switch ( getpath(nowtk, 16) )
			case "module"
				index += CntSpaces(mScript, index)				// ignore 空白
				if ( peek(mScript, index) == '"' ) { index ++ }	// #module "modname" の形式に対応
				index += CutIdent(areaScope, mScript, index)	// 空間名
				if ( stat == 0 ) {
					areaScope   = strf("m%02d [unique]", uniqueCount)	// ユニークな空間名
					uniqueCount ++
				}
				swbreak
			case "global" : areaScope = AREA_GLOBAL : swbreak	// モジュール空間からの脱出
			
			case "include"
			case "addition"
				index += CntSpaces(mScript, index)
				if ( peek(mScript, index) == '"' ) { index ++ }
				getstr nowtk, mScript, index, '"'
				index                += strsize
				mInclude(mCntInclude) = nowtk
				mCntInclude ++
;				logmes "#include "+ nowtk
				swbreak
				
			case "modfunc"  : deftype  = DEFTYPE_MODULE
			case "deffunc"  : deftype |= DEFTYPE_FUNC                    : goto *L_AddDefinition
			case "modcfunc" : deftype  = DEFTYPE_MODULE
			case "defcfunc" : deftype |= DEFTYPE_FUNC   | DEFTYPE_CTYPE  : goto *L_AddDefinition
			case "define"   : deftype  = DEFTYPE_MACRO : bGlobal = false : goto *L_AddDefinition
			case "const"
			case "enum"     : deftype  = DEFTYPE_CONST : bGlobal = false : goto *L_AddDefinition
			case "cfunc"    : deftype  = DEFTYPE_CTYPE
			case "func"     : deftype |= DEFTYPE_DLL   : bGlobal = false : goto *L_AddDefinition
			case "cmd"      : deftype  = DEFTYPE_CMD   : bGlobal = true  : goto *L_AddDefinition
*L_AddDefinition
				index += CntSpaces(mScript, index)			// 空白 ignore
				index += CutIdent(nowtk, mScript, index)	// 識別子を取り出す
				
				switch getpath( nowtk, 16 )
					case "global" : bGlobal  = true                  : goto *L_AddDefinition
					case "ctype"  : deftype |= DEFTYPE_CTYPE         : goto *L_AddDefinition
					case "local"  : bGlobal  = false : bLocal = true : goto *L_AddDefinition
					case "double" : goto *L_AddDefinition
				swend
				
				index += MakeModuleName(scope, mScript, index, areaScope)
				if ( stat ) {	// scope != areaScope ->("ident@scope")
					bGlobal = false
				}
				
				// 範囲を作成
				MakeScope scope, areaScope, deftype, bGlobal, bLocal
				
				// リストに追加
				gosub *L_AddDefList
				swbreak
			swend
			
			poke nowtk
		}
		swbreak
		
	swend
	return
	
*L_AddDefList
	gosub *L_SetLinenum			// linenum に適切な値を代入する
	listIndex(mCount) = index
	DefList_Add thismod, nowtk, linenum, deftype, scope
	return
	
*L_SetLinenum
	if ( mCount <= 0 ) {
		linenum = GetLinenumByIndex(mScript, index, 0, 0)
	} else {
		linenum = GetLinenumByIndex(mScript, index, listIndex(mCount - 1), mLn(mCount - 1))
	}
	return
	
//------------------------------------------------
// コンストラクタ
//------------------------------------------------
#modinit str path
	// メンバ変数を初期化
	sdim mIdent,, 5
	dim  mLn,     5
	dim  mType,   5
	sdim mScope,, 5
	sdim mFileName
	sdim mFilePath, MAX_PATH
	sdim mInclude,  MAX_PATH
	dim  mCntInclude
	
	mFilePath = path
	mFileName = getpath(mFilePath, 8)
	
	// スクリプトを読み込む
	notesel  mScript
	noteload mFilePath
	noteunsel
	
	// 定義をリストアップ
	ListupDefinition thismod
	
	return getaptr(thismod)
	
#global

#endif
