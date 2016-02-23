// hs 自動生成モジュール

#ifndef IG_MODULE_AUTO_HS_AS
#define IG_MODULE_AUTO_HS_AS

#include "Mo/HPM_split.as"
#include "Mo/MCLongString.as"

//##############################################################################
//                モジュール
//##############################################################################
/**+
 * @name     : mod_autohs
 * @author   : ue-dai
 * @date     : 2009 09/01 (Tue)
 * @version  : 1.0β
 * @type     : autohs 特化モジュール
 * @group    : 
 * @note     : #include "mod_autohs.as" が必要です。
 * @url      : http://prograpark.ninja-web.net/
 * @port
 * @	Win
 * @	Cli
 * @	Let
 * @portinfo : 特になし。
 **/

#module autohs_mod

#include "Mo/HPM_header.as"
#include "Mo/hpm_deftype.hsp"

#define STR_HS_HEADER stt_hsHeader

//------------------------------------------------
// DocData
//------------------------------------------------
#enum DocData_Name = 0		// hs 名称
#enum DocData_Author		// author	: 作者名
#enum DocData_Date			// date		: 日付
#enum DocData_Version		// version	: バージョン情報
#enum DocData_Type			// type		: %type 省略値
#enum DocData_Group			// group	: %group 省略値
#enum DocData_Note			// note		: 備考
#enum DocData_Url			// url		: URL
#enum DocData_Port			// port		: 対応環境
#enum DocData_MAX

//------------------------------------------------
// モジュール初期化
//------------------------------------------------
#deffunc AutohsInitialize
	stt_docdata_identlist = "name", "author", "date", "version", "type", "group", "note", "url", "port"
	return
	
//------------------------------------------------
// ヘッダ文字列を設定する
//------------------------------------------------
#deffunc SetHsHeader str hsHeader
	stt_hsHeader = hsHeader
	strrep stt_hsHeader, "\\n", "\n"
	return
	
//------------------------------------------------
// hs 自動生成
//------------------------------------------------
#define nowTkType tktypelist(idx)
#define nowTkStr  tkstrlist (idx)
#define NextToken GetNextToken idx, tktypelist, tkstrlist, docdata, cntToken

#deffunc CreateHs var result, var script,  \
	local hs, local fSplit, local tktypelist, local tkstrlist, local docdata, local cntToken, local idx, local deftype, local sDefIdent, local prmlist, local cntPrm, local bGlobal, local bInModule
	
	// 字句解析
	fSplit  = HPM_SPLIT_FLAG_NO_RESERVED
;	fSplit |= HPM_SPLIT_FLAG_NO_BLANK
;	fSplit |= HPM_SPLIT_FLAG_NO_COMMENT
;	fSplit |= HPM_SPLIT_FLAG_NO_SCOPE
	
	hpm_split tktypelist, tkstrlist, script, fSplit
	cntToken = stat
	
	// hs 生成
	dim deftype
	dim idx
	dim bInModule
	sdim docdata, , DOCDATA_MAX
	
	LongStr_new hs
	LongStr_add hs, STR_HS_HEADER	// ヘッダ文字列を設定する
	
	repeat
		gosub *LProcToken
		NextToken
		if ( idx >= cntToken ) {
			break
		}
	loop
	
	LongStr_tobuf  hs, result
	LongStr_delete hs
	
	// 埋め込みドキュメント情報の展開
	if ( docdata(DocData_Name) != "" ) {
		repeat DocData_MAX
			strrep result, ";$("+ stt_docdata_identlist(cnt) +")", docdata(cnt)
		loop
	}
	
	return
	
*LProcToken
	switch ( nowTkType )
		//--------------------
		// プリプロセッサ命令
		//--------------------
		case TKTYPE_PREPROC
			deftype  = DEFTYPE_NONE
			nowTkStr = CutPreprocIdent( nowTkStr )		// 識別子部分だけにする
			bGlobal  = true
			
			switch ( nowTkStr )
				case "modfunc"  : deftype  = DEFTYPE_MODULE
				case "deffunc"  : deftype |= DEFTYPE_FUNC                    : goto *LAddDefinition
				case "modcfunc" : deftype  = DEFTYPE_MODULE
				case "defcfunc" : deftype |= DEFTYPE_FUNC  | DEFTYPE_CTYPE   : goto *LAddDefinition
				case "define"   : deftype  = DEFTYPE_MACRO : bGlobal = false : goto *LAddDefinition
				case "const"
				case "enum"     : deftype  = DEFTYPE_CONST : bGlobal = false : goto *LAddDefinition
				case "cfunc"    : deftype  = DEFTYPE_CTYPE
				case "func"     : deftype |= DEFTYPE_DLL   : bGlobal = false : goto *LAddDefinition
				case "cmd"      : deftype  = DEFTYPE_CMD   :                 : goto *LAddDefinition
				case "comfunc"  : deftype  = DEFTYPE_COM   : bGlobal = false : goto *LAddDefinition
				case "usecom"   : deftype  = DEFTYPE_IFACE : bGlobal = false : goto *LAddDefinition
				
				case "module":
					bInModule = true
					deftype = DEFTYPE_NSPACE
					goto *LAddDefinition
				case "global":
					bInModule = false
					swbreak
				
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
							
							// 次にスコープ解決がある場合
							idx ++
							if ( nowTkType == TKTYPE_SCOPE ) {
								if ( nowTkStr != "@" ) {
									bGlobal = false
								}
							}
							idx --
							
							// #module
							if ( deftype == DEFTYPE_NSPACE ) {
								sDefIdent = strtrim(sDefIdent, 0, '"')
								
								// メンバ変数があればクラス
								if ( nowTkType == TKTYPE_IDENT ) {
									deftype = DEFTYPE_CLASS
								}
							}
							
							// 次のトークン
							NextToken
							swbreak
					swend
					
					// 外部に見えないものは無視する
					if ( bInModule && bGlobal == false ) {
						swbreak
					}
					
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
	// 定数とモジュール名は無視する
	if ( deftype == DEFTYPE_CONST || deftype == DEFTYPE_NSPACE || deftype == DEFTYPE_CLASS ) {
		return
	}
	
	// 仮引数リストを作成する
	CreatePrmlist prmlist, deftype, tktypelist, tkstrlist, docdata, idx, cntToken
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
	
#deffunc CreatePrmlist@autohs_mod array prmlist, int deftype, array tktypelist, array tkstrlist, array docdata, var idx, int cntToken,  local cntPrm, local sType, local sIdent, local sDefault
	sdim prmlist, , 20, 3
	dim  cntPrm
	sdim sIdent
	sdim sType
	sdim sDefault
	
	if ( deftype & DEFTYPE_MACRO ) {
		if ( nowTkType != TKTYPE_CIRCLE_L ) { return 0 }
		NextToken
	}
	if ( deftype & DEFTYPE_MODULE ) { AddPrmlist prmlist, "self", "modvar" }
	if ( deftype & DEFTYPE_DLL    ) { NextToken }
	if ( deftype & DEFTYPE_COM    ) { NextToken }
	if ( deftype & DEFTYPE_CMD    ) { return 0 }
	if ( deftype & DEFTYPE_IFACE  ) { return 0 }
	
	repeat
		if ( nowTkType == TKTYPE_END ) { break }
		
		// ユーザ定義命令・関数
		if ( deftype & DEFTYPE_FUNC ) {
			
			sType = nowTkStr : NextToken
			
			if ( nowTkType == TKTYPE_IDENT ) {
				sIdent = nowTkStr
				NextToken
				
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
			NextToken
			
		// マクロ
		} else : if ( deftype & DEFTYPE_MACRO ) {
			if ( nowTkType != TKTYPE_MACRO_PRM ) { break }
			
			NextToken
			if ( nowTkStr == "=" ) {
				NextToken
				sDefault = nowTkStr
				NextToken
			} else {
				poke sDefault
			}
			
			AddPrmlist prmlist, "p"+ (cntPrm + 1), "any", sDefault
		}
		
		// , を飛ばす
		if ( nowTkType == TKTYPE_COMMA ) {
			NextToken
		} else {
			break
		}
	loop
	
	return cntPrm
	
//------------------------------------------------
// idx の増加
//------------------------------------------------
#deffunc GetNextToken var idx, array tktypelist, array tkstrlist, array docdata, int cntToken,  local index
*LNextToken_core
	idx ++
	
	if ( idx >= cntToken ) {
		nowTkType = TKTYPE_ERROR
		nowTkStr  = ""
		return
	}
	
	switch ( nowTkType )
		case TKTYPE_COMMENT
			// 埋め込みドキュメント情報の場合
			if ( lpeek(nowTkStr) == 0x2B2A2A2F ) {	// long("/**+")
				index       = 4
				len_max     = strlen(nowTkStr)
				typeDocdata = -1
				
				repeat
					index += CntSpaces(nowTkStr, index, true)	// 改行を文字列と認める
					
					if ( (len_max - 2) <= index ) { break }
					
					if ( peek(nowTkStr, index) != '*' ) { break }
					index ++
					index += CntSpaces(nowTkStr, index)
					
					// 識別子の取得 ( 情報タイプ )
					if ( peek(nowTkStr, index) != '@' ) { continue }
					index ++
					index += CutIdent( stt_sIdent, nowTkStr, index )
					index += CntSpaces(nowTkStr, index)
					
					stt_sIdent = getpath(stt_sIdent, 16)
					
					// ':' を許可
					if ( peek(nowTkStr, index) == ':' ) {
						index ++
						index += CntSpaces(nowTkStr, index)
						stt_bPermitEmptyLine = true			// 空行でも無視されない
					} else {
						stt_bPermitEmptyLine = false
					}
					
					// doc data の取得 ( 行末まで )
					getstr stt_sData, nowTkStr, index : index += strsize
					
					if ( stt_sIdent != "" ) {		// 維持
						typeDocdata = -1
						repeat DocData_MAX
							if ( stt_sIdent == stt_docdata_identlist(cnt) ) {
								typeDocdata = cnt
								break
							}
						loop
					}
					
					// ドキュメント情報の配列に追加
					if ( typeDocdata < 0 ) {
						break
						
					} else {
						// コロン(:)がない＆空の行 ⇒ 無視する
						if ( stt_bPermitEmptyLine == false && stt_sData == "" ) {
							continue
						}
						
						if ( docdata( typeDocdata ) != "" ) {
							docdata( typeDocdata ) += "\n"
						}
						docdata( typeDocdata ) += stt_sData
					}
				loop
			}
			
			goto *LNextToken_core
			swbreak
			
		case TKTYPE_BLANK
		case TKTYPE_SCOPE
			goto *LNextToken_core
			
		case TKTYPE_ESC_LINEFEED
			idx ++
			gosub *LNextToken_core	// 改行の次に進む
			swbreak
			
		default
			swbreak
	swend
	
	return
	
#global

	AutohsInitialize

#endif
