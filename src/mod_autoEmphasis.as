// emphasis code 自動生成モジュール

#ifndef IG_MODULE_AUTO_HS_AS
#define IG_MODULE_AUTO_HS_AS

#include "Mo/HPM_split.as"

#include "Mo/mod_replace.as"
#include "Mo/MCLongString.as"

//##############################################################################
//                モジュール
//##############################################################################
/**+
 * @name     : mod_autoEmphasis
 * @author   : ue-dai
 * @date     : 2011 12/25 (Sun)
 * @version  : 1.0β
 * @type     : autoEmphasis 特化モジュール
 * @group    : 
 * @note     : #include "mod_autoEmphasis.as" が必要。autohs からの派生。
 * @url      : http://prograpark.ninja-web.net/
 * @port
 * @	Win
 * @	Cli
 * @	Let
 * @portinfo : 特になし。
 **/

#module autohs_mod

#include "Mo/HPM_header.as"

//------------------------------------------------
// DEFTYPE
//------------------------------------------------
#const DEFTYPE_NONE			0x0000
#const DEFTYPE_LABEL		0x0001		// ラベル
#const DEFTYPE_MACRO		0x0002		// マクロ
#const DEFTYPE_CONST		0x0004		// 定数
#const DEFTYPE_FUNC			0x0008		// 命令・関数
#const DEFTYPE_DLL			0x0010		// DLL命令
#const DEFTYPE_CMD			0x0020		// HPIコマンド
#const DEFTYPE_COM			0x0040		// COM命令
#const DEFTYPE_IFACE		0x0080		// インターフェース
#const DEFTYPE_NAMESPACE	0x0100		// モジュール(名前空間)
#const DEFTYPE_CLASS		0x0200		// モジュール(クラス)

#const DEFTYPE_CTYPE		0x1000		// CTYPE
#const DEFTYPE_MODULE		0x2000		// モジュールメンバ

//------------------------------------------------
// hs 自動生成
//------------------------------------------------
#define nowTkType tktypelist(idx)
#define nowTkStr  tkstrlist (idx)
#define NextToken GetNextToken idx, tktypelist, tkstrlist, cntToken

#deffunc CreateHs var result, var script,  \
	local hs, local fSplit, local tktypelist, local tkstrlist, local cntToken, local idx, local deftype, local sDefIdent, local prmlist, local cntPrm, local bGlobal, local bInModule
	
	// 字句解析
	fSplit  = HPM_SPLIT_FLAG_NO_RESERVED
	fSplit |= HPM_SPLIT_FLAG_NO_BLANK
	fSplit |= HPM_SPLIT_FLAG_NO_COMMENT
;	fSplit |= HPM_SPLIT_FLAG_NO_SCOPE
	
	hpm_split tktypelist, tkstrlist, script, fSplit
	cntToken = stat
	
	// hs 生成
	dim deftype
	dim idx
	dim bInModule
	
	LongStr_new hs
	
	repeat
		gosub *LProcToken
		NextToken
		if ( idx >= cntToken ) {
			break
		}
	loop
	
	LongStr_tobuf  hs, result
	LongStr_delete hs
	
	return
	
*LProcToken
	switch ( nowTkType )
		//--------------------
		// ラベル
		//--------------------
		/*
		case TKTYPE_LABEL
			deftype = DEFTYPE_LABEL
			
			// 行頭の場合のみ
			if ( befTkType == TKTYPE_END ) {
				sIdent = nowTkStr
				
			;	gosub *LDecideModuleName
				
				// リストに追加
				deftype = DEFTYPE_LABEL
				gosub *LAddDeflist
			}
			
			swbreak
		//*/
		
		//--------------------
		// プリプロセッサ命令
		//--------------------
		case TKTYPE_PREPROC
			deftype  = DEFTYPE_NONE
			nowTkStr = CutPreprocIdent( nowTkStr )		// 識別子部分だけにする
			bGlobal  = true
			
			switch ( nowTkStr )
				case "modfunc"  :
				case "deffunc"  : deftype  = DEFTYPE_FUNC                    : goto *LAddDefinition
				case "modcfunc" :
				case "defcfunc" : deftype  = DEFTYPE_FUNC  | DEFTYPE_CTYPE   : goto *LAddDefinition
				case "const"    :
				case "enum"     :
				case "define"   : deftype  = DEFTYPE_MACRO : bGlobal = false : goto *LAddDefinition
				case "cfunc"    : deftype  = DEFTYPE_CTYPE
				case "func"     : deftype |= DEFTYPE_DLL   : bGlobal = false : goto *LAddDefinition
				case "cmd"      : deftype  = DEFTYPE_CMD   :                 : goto *LAddDefinition
				case "comfunc"  : deftype  = DEFTYPE_COM   : bGlobal = false : goto *LAddDefinition
				case "usecom"   : deftype  = DEFTYPE_IFACE : bGlobal = false : goto *LAddDefinition
				
				case "module"   : bInModule = true
					deftype = DEFTYPE_NAMESPACE
					goto *LAddDefinition
				case "global"   : bInModule = false : swbreak	// 定義しない
				
			:*LAddDefinition
					NextToken
					
					switch ( nowTkStr )
						case "ctype"  : deftype |= DEFTYPE_CTYPE : goto *LAddDefinition
						case "global" : bGlobal  = true          : goto *LAddDefinition
						case "local"  : bGlobal  = false         : goto *LAddDefinition
						case "double"
							goto *LAddDefinition
						
						// 定義される識別子
						default:
							sDefIdent = nowTkStr
							
							// 次がスコープ解決 => 非グローバル
							idx ++
							if ( nowTkType == TKTYPE_SCOPE ) {
								if ( nowTkStr != "@" ) {
									bGlobal = false
								}
							}
							idx --
							
							// (#module):
							if ( deftype == DEFTYPE_NAMESPACE ) {
								// 識別 (名前空間 or クラス)
								if ( nowTkType == TKTYPE_IDENT ) {
									deftype = DEFTYPE_CLASS
								}
								// "" を外す
								if ( peek(sDefIdent) == '"' ) {
									sDefIdent = strmid(sDefIdent, 1, strlen(sDefIdent) - 2)
								}
							}
							
							// 次のトークン
							NextToken
							swbreak
					swend
					
					// 外部に見えないものは無視する (opt)
					if ( bInModule && bGlobal == false && bIgnoreInnerDefinition@ ) {
						swbreak
					}
					
					// リストに追加
					gosub *LAddDeflist
					swbreak
					
				// uselib
				case "uselib"
					if ( bExplicitUselib@ ) {
						NextToken
						LongStr_add hs, "; #uselib " + nowTkStr + "\n"
					}
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
	
	// 定義タイプの文字列を得る
	deftypeString = MakeDefTypeString( deftype )
	
	// 定義タイプ → (独立性, 色)
	foreach keylist@
		if ( keylist@(cnt) == deftypeString ) {
			dependency = depenId@(cnt)
			clrText    = clrTxId@(cnt)
			break
		}
	loop
	
	// 出力
	if ( dependency != "" && clrText != "" ) {
		LongStr_add hs, sDefIdent + " " + dependency + " " + clrText + "\n"
	}
	
	return
	
//------------------------------------------------
// 定義タイプから文字列を生成する
// @static
// @from deflister
//------------------------------------------------
#defcfunc MakeDefTypeString int deftype,  local stype, local bCType
	sdim stype, 320
	bCType = ( deftype & DEFTYPE_CTYPE ) != false
	
	if ( deftype & DEFTYPE_LABEL ) { stype = "Label" }
	if ( deftype & DEFTYPE_MACRO ) { stype = "Macro" }
	if ( deftype & DEFTYPE_CONST ) { stype = "Const" }
	if ( deftype & DEFTYPE_CMD   ) { stype = "Cmd"   }
	if ( deftype & DEFTYPE_COM   ) { stype = "COM"   }
	if ( deftype & DEFTYPE_IFACE ) { stype = "IFace" }
	
	if ( deftype & DEFTYPE_NAMESPACE ) { stype = "NameSpace" }
	if ( deftype & DEFTYPE_CLASS     ) { stype = "Class" }
	
	if ( deftype & DEFTYPE_DLL ) {
		if ( bCType ) { stype = "Func<dll>" } else { stype = "Sttm<dll>" }
		
	} else : if ( deftype & DEFTYPE_FUNC ) {
		if ( bCType ) { stype = "Func" } else { stype = "Sttm" }
		
		// 静的 or メンバ
		if ( deftype & DEFTYPE_MODULE ) {
			stype += "<member>"
		} else {
			stype += "<static>"
		}
		
	} else {
		if ( bCType ) { stype += "<ctype>" }
	}
	
	return stype
	
//------------------------------------------------
// idx の増加
//------------------------------------------------
#deffunc GetNextToken var idx, array tktypelist, array tkstrlist, int cntToken
*LNextToken_core
	idx ++
	
	if ( idx >= cntToken ) {
		nowTkType = TKTYPE_ERROR
		nowTkStr  = ""
		return
	}
	
;	switch ( nowTkType )
;		default
;			swbreak
;	swend
	
	return
	
#global

#endif
