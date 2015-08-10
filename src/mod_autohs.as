// hs 自動生成モジュール

#ifndef __MODULE_AUTO_HS_AS__
#define __MODULE_AUTO_HS_AS__

#include "Mo/HPM_split.as"

#include "Mo/mod_replace.as"
#include "Mo/MCLongString.as"

//##############################################################################
//                モジュール
//##############################################################################
#module autohs_mod

#include "Mo/HPM_header.as"

#define STR_HS_HEADER stt_hsHeader

//------------------------------------------------
// DEFTYPE
//------------------------------------------------
#const DEFTYPE_NONE		0x0000
#const DEFTYPE_LABEL	0x0001		// ラベル
#const DEFTYPE_MACRO	0x0002		// マクロ
#const DEFTYPE_CONST	0x0004		// 定数
#const DEFTYPE_FUNC		0x0008		// 命令・関数
#const DEFTYPE_DLL		0x0010		// DLL命令
#const DEFTYPE_CMD		0x0020		// HPIコマンド
#const DEFTYPE_COM		0x0040		// COM命令
#const DEFTYPE_IFACE	0x0080		// インターフェース

#const DEFTYPE_CTYPE	0x0100		// CTYPE
#const DEFTYPE_MODULE	0x0200		// モジュールメンバ

//------------------------------------------------
// モジュール初期化
//------------------------------------------------
#deffunc AutohsInitialize
	return
	
//------------------------------------------------
// ヘッダ文字列を設定する
//------------------------------------------------
#deffunc SetHsHeader str hsHeader
	stt_hsHeader = hsHeader
	replace stt_hsHeader, "\\n", "\n"
	return
	
//------------------------------------------------
// hs 自動生成
//------------------------------------------------
#define nowTkType tktypelist(idx)
#define nowTkStr  tkstrlist (idx)

#deffunc CreateHs var result, var script,  \
	local hs, local fSplit, local tktypelist, local tkstrlist, local cntToken, local idx, local deftype, local sDefIdent, local prmlist, local cntPrm
	
	// 字句解析
	fSplit  = HPM_SPLIT_FLAG_NO_RESERVED
	fSplit |= HPM_SPLIT_FLAG_NO_BLANK
	fSplit |= HPM_SPLIT_FLAG_NO_COMMENT
	fSplit |= HPM_SPLIT_FLAG_NO_SCOPE
	
	hpm_split tktypelist, tkstrlist, script, fSplit
	cntToken = stat
	
	dim deftype
	dim idx
	
	LongStr_new hs
	LongStr_add hs, STR_HS_HEADER	// ヘッダ文字列を設定する
	
	repeat
		gosub *LProcToken
		gosub *LNextToken
		if ( idx >= cntToken ) {
			break
		}
	loop
	
	LongStr_tobuf  hs, result
	LongStr_delete hs
	
	return
	
*LNextToken
	idx ++
	
	if ( idx >= cntToken ) {
		nowTkType = TKTYPE_ERROR
		nowTkStr  = ""
		return
	}
	
	switch ( nowTkType )
		case TKTYPE_BLANK
		case TKTYPE_COMMENT
		case TKTYPE_SCOPE
			goto *LNextToken
			
		case TKTYPE_ESC_LINEFEED
			idx ++
			gosub *LNextToken	// 改行の次に進む
			swbreak
			
		default
			swbreak
	swend
	
	return
	
*LProcToken
	switch ( nowTkType )
		//--------------------
		// プリプロセッサ命令
		//--------------------
		case TKTYPE_PREPROC
			deftype  = DEFTYPE_NONE
			nowTkStr = CutPreprocIdent( nowTkStr )		// 識別子部分だけにする
			
			switch ( nowTkStr )
				case "modfunc"  : deftype  = DEFTYPE_MODULE
				case "deffunc"  : deftype |= DEFTYPE_FUNC                    : goto *LAddDefinition
				case "modcfunc" : deftype  = DEFTYPE_MODULE
				case "defcfunc" : deftype |= DEFTYPE_FUNC   | DEFTYPE_CTYPE  : goto *LAddDefinition
				case "define"   : deftype  = DEFTYPE_MACRO                   : goto *LAddDefinition
			;	case "const"
			;	case "enum"     : deftype  = DEFTYPE_CONST : goto *LAddDefinition
				case "cfunc"    : deftype  = DEFTYPE_CTYPE
				case "func"     : deftype |= DEFTYPE_DLL   : goto *LAddDefinition
				case "cmd"      : deftype  = DEFTYPE_CMD   : goto *LAddDefinition
				case "comfunc"  : deftype  = DEFTYPE_COM   : goto *LAddDefinition
				case "usecom"   : deftype  = DEFTYPE_IFACE : goto *LAddDefinition
			:*LAddDefinition
					gosub *LNextToken
					
					switch ( nowTkStr )
						case "ctype"
							deftype |= DEFTYPE_CTYPE
							/* fall through */
						case "global"
						case "local"
						case "double"
							goto *LAddDefinition
						
						// 定義される識別子
						default:
							sDefIdent = nowTkStr
							gosub *LNextToken
							swbreak
					swend
					
					// リストに追加
					gosub *LAddDeflist
					swbreak
			swend
			swbreak
	swend
	return
	
*LAddDeflist
	// 先頭 or 末尾 が _ なら、無視する
	if ( peek(sDefIdent) == '_' || peek(sDefIdent, strlen(sDefIdent) - 1) == '_' ) {
		return
	}
	
	// 仮引数リストを作成する
	CreatePrmlist prmlist, deftype, tktypelist, tkstrlist, idx
	cntPrm = stat
	
	// 出力
	LongStr_add hs, ";--------------------\n%index\n"+ sDefIdent +"\n\n\n%prm\n"
	
	// 仮引数リスト
	if ( deftype & DEFTYPE_CTYPE ) {
		LongStr_add hs, "("
	}
	
	repeat cntPrm
		if ( cnt ) { LongStr_add hs, ", " }
		
		LongStr_add hs, prmlist(cnt, 0)
		
		// 省略値
		if ( prmlist(cnt, 2) != "" ) {
			LongStr_add hs, " = "+ prmlist(cnt, 2)
		}
	loop
	
	if ( deftype & DEFTYPE_CTYPE ) {
		LongStr_add hs, ")"
	}
	LongStr_add hs, "\n"
	
	// 仮引数詳細
	repeat cntPrm
		LongStr_add hs, prmlist(cnt, 1) +" "+ prmlist(cnt, 0) +" : \n"
	loop
	
	// 残り
	LongStr_add hs, "\n%inst\n\n\n%href\n\n%group\n\n"
	return
	
//------------------------------------------------
// 仮引数リストの作成
//------------------------------------------------
#define AddPrmlist(%1,%2="",%3="",%4="") %1(cntPrm, 0) = %2 : %1(cntPrm, 1) = %3 : %1(cntPrm, 2) = %4 :\
/**/	logmes strf("AddPrmlist[%1] %%s, %%s, %%s", %2, %3, %4) /**/	:\
	cntPrm ++
	
#deffunc CreatePrmlist@autohs_mod array prmlist, int deftype, array tktypelist, array tkstrlist, int _idx,  local idx, local cntPrm, local sType, local sIdent, local sDefault
	sdim prmlist, , 20, 3
	dim  cntPrm
	sdim sIdent
	sdim sType
	sdim sDefault
	
	idx = _idx
	
	if ( deftype & DEFTYPE_MACRO ) {
		if ( nowTkType != TKTYPE_CIRCLE_L ) { return 0 }
		idx ++
	}
	if ( deftype & DEFTYPE_MODULE ) { AddPrmlist prmlist, "self", "modvar" }
	if ( deftype & DEFTYPE_DLL    ) { idx ++ }
	if ( deftype & DEFTYPE_COM    ) { idx ++ }
	if ( deftype & DEFTYPE_CMD    ) { return 0 }
	if ( deftype & DEFTYPE_IFACE  ) { return 0 }
	
	repeat
		if ( nowTkType == TKTYPE_END ) { break }
		
		// ユーザ定義命令・関数
		if ( deftype & DEFTYPE_FUNC ) {
			
			sType = nowTkStr : idx ++
			
			if ( nowTkType == TKTYPE_IDENT ) {
				sIdent = nowTkStr
				idx ++
				
			} else {
				poke sIdent
			}
			
			// ローカル引数は追加しない
			if ( sType != "local" ) {
				AddPrmlist prmlist, sIdent, sType
			}
			
		// Dll 命令・関数
		} else : if ( deftype & DEFTYPE_DLL ) {
			
			if ( nowTkType != TKTYPE_IDENT ) { break }
			
			AddPrmlist prmlist, "p"+ (cntPrm + 1), nowTkStr
			idx ++
			
		// マクロ
		} else : if ( deftype & DEFTYPE_MACRO ) {
			if ( nowTkType != TKTYPE_MACRO_PRM ) { break }
			
			idx ++
			if ( nowTkStr == "=" ) {
				idx ++
				sDefault = nowTkStr
				idx ++
			} else {
				poke sDefault
			}
			
			AddPrmlist prmlist, "p"+ (cntPrm + 1), "any", sDefault
		}
		
		// , を飛ばす
		if ( nowTkType == TKTYPE_COMMA ) {
			idx ++
		} else {
			break
		}
	loop
	
	return cntPrm
	
#global

#endif
