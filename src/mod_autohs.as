// hs 自動生成モジュール

#ifndef IG_MODULE_AUTO_HS_AS
#define IG_MODULE_AUTO_HS_AS

#include "Mo/HPM_split.as"

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

//------------------------------------------------
// hs 自動生成
//------------------------------------------------
#define nowTkType tktypelist(idx)
#define nowTkStr  tkstrlist (idx)

#define NextToken \
	autogen_get_next_token autogen, idx

#deffunc CreateHs \
	var result, var script, int fSplit, \
	var autogen, array tktypelist, array tkstrlist, \
	local cntToken, local idx, \
	local deftype, local sDefIdent, \
	local bGlobal, local bInModule
	
	// 字句解析
	hpm_split tktypelist, tkstrlist, script, fSplit
	cntToken = stat
	
	autogen_set_cnt_tokens autogen, cntToken
	
	// 番兵
	tkstrlist(cntToken)  = ""
	tktypelist(cntToken) = TKTYPE_ERROR
	
	// hs 生成
	dim deftype
	dim idx
	dim bInModule
	
	repeat
		gosub *LProcToken
		NextToken
		if ( idx >= cntToken ) {
			break
		}
	loop
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
				case "uselib"   : deftype  = DEFTYPE_LIB   : bGlobal = false : goto *LAddDefinition
				
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
	autogen_add_def autogen, sDefIdent, deftype, idx
	return
	
#global

#endif
