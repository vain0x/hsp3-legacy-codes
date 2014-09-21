// JSON 構文解析クラス (using obsidian)

#ifndef IG_MODULECLASS_OBSIDIAN_JSON_PARSER_AS
#define IG_MODULECLASS_OBSIDIAN_JSON_PARSER_AS

//##############################################################################
//                  定義部 : MCObsJsonParser
//##############################################################################
#module MCObsJsonParser tktype, tkstr, idx, cntToken, tklist

#include "Mo/ctype.as"
#include "ObsJson.as"
#include "ObsJson.header.as"

//------------------------------------------------
// 真理値・成敗値・NULL値
//------------------------------------------------
#define true    1
#define false   0
#define success 1
#define failure 0
#define NULL    0

//------------------------------------------------
// 定数：解析モード
//------------------------------------------------
#enum ParseMode_Complete = 0
#enum ParseMode_Final
#enum ParseMode_Root
#enum ParseMode_Object
#enum ParseMode_Members
#enum ParseMode_MembersNext
#enum ParseMode_Pair
#enum ParseMode_Array
#enum ParseMode_Elements
#enum ParseMode_ElementsNext
#enum ParseMode_Value

;#enum ParseMode_
;#enum ParseMode_
#enum ParseMode_MAX

//##########################################################
//        構築・解体
//##########################################################
#define global obsjsonParser_new(%1)    newmod %1, MCObsJsonParser@
#define global obsjsonParser_delete(%1) delmod %1

//------------------------------------------------
// 構築
//------------------------------------------------
#modinit
	dim tktype
	sdim tkstr
	return
	
//------------------------------------------------
// 解体
//------------------------------------------------
#modterm
	return
	
//##########################################################
//        動作系
//##########################################################
#define NextToken obsjsonParser_NextToken thismod
#define ctype tktypelist(%1) tklist(0, %1)
#define ctype tkstrlist(%1)  tklist(1, %1)

//------------------------------------------------
// 構文解析 (JSON 構造の生成)
// 
// @alg: 再帰下降構文解析
//------------------------------------------------
#modfunc obsjsonParser_Parse var result, array tklist_, int cntToken_
	tklist   = tklist_()
	idx      = 0
	cntToken = cntToken_
	
	NextToken
	if ( tktype == TkType_Final ) { return }
	
	if ( idx >= cntToken ) { return }
	obsjsonParser_Root thismod, result
	
	return
	
//------------------------------------------------
// 次のトークンを先読みする
//------------------------------------------------
#modfunc obsjsonParser_NextToken
	if ( idx < cntToken ) {
		dbgout( strf( "NextToken[%02d]: (%d, %s)", idx, tktypelist(idx), tkstrlist(idx) ) )
		tktype = tktypelist(idx)
		tkstr  = tkstrlist(idx)
		idx ++
	} else {
		dbgout( "NextToken: Overflow" )
	}
	return
	
//**********************************************************
//        解析ルーチン
//**********************************************************
//*
// スタック方式の解析
#modfunc obsjsonParser_Root var node,  local tmp \
	, local stkMode, local stkNeed, local stkType, local stkData \
	, local mode
	
	stkMode = vector( ParseMode_Final, ParseMode_Root )
	vector stkNeed
	vector stkData	// members の assoc, elements の vector や、value のノード(assoc)が積まれる
	
	repeat
		mode = stkMode(vectorLast) : vectorPop stkMode()
		if ( mode == ParseMode_Final ) { break }
		
		obsjsonParser_ProcNext thismod, mode, stkMode, stkNeed, stkData
		
		if ( stat != ParseMode_Complete ) {
			vectorPush stkMode(), stat	// 遷移先
		}
	loop
	
	node = stkData(vectorLast)	// ルートノード
	vectorPop stkData()
	return
	
#modfunc obsjsonParser_ProcNext int mode, array stkMode, array stkNeed, array stkData,  \
	local tmp, local tmp_rhs
	
	switch ( mode )
		case ParseMode_Root:
			return ParseMode_Value
			
		case ParseMode_Object:
			NextToken			// '{'
			vectorPush stkData(), assoc()	// members
			return ParseMode_Members
			
		case ParseMode_Members:
			if ( tktype == TkType_BrkObjR ) {
				NextToken		// '}'
				return ParseMode_Complete
			}
			
			vectorPush stkMode(), ParseMode_MembersNext
			return ParseMode_Pair
			
		case ParseMode_MembersNext:
			tmp_rhs = stkData(vectorLast) : vectorPop stkData()	// value node
			tmp     = stkData(vectorLast) : vectorPop stkData()	// string (key)
			stkData( vectorLast, tmp ) = tmp_rhs(0)				// members の assoc に追加
			if ( tktype == TkType_Comma ) {
				NextToken
				return ParseMode_Members
			} else {
				if ( tktype != TkType_BrkObjR ) { assert }
				NextToken
				return ParseMode_Complete
			}
			
		case ParseMode_Pair:	// 3つの値 value[string], value[":"], value[?] に展開する
			stkMode += vector( ParseMode_Value, ParseMode_Value )	// 値 * 2
			vectorPush stkNeed(), TkType_Colon
			vectorPush stkNeed(), TkType_String
			return ParseMode_Value
			
		case ParseMode_Array:
			NextToken			// '['
			vectorPush stkData(), vector()	// elements
			return ParseMode_Elements
			
		case ParseMode_Elements:
			if ( tktype == TkType_BrkArrR ) {
				NextToken		// ']'
				return ParseMode_Complete
			}
			
			vectorPush stkMode(), ParseMode_ElementsNext
			return ParseMode_Value
			
		case ParseMode_ElementsNext:
			tmp = stkData(vectorLast) : vectorPop stkData()
			vectorPush stkData(vectorLast), tmp(0)		// elements に追加
			if ( tktype == TkType_Comma ) {
				NextToken
				return ParseMode_Elements
			} else {
				if ( tktype != TkType_BrkArrR ) { assert }
				NextToken
				return ParseMode_Complete
			}
			
		case ParseMode_Value:
			if ( vectorSize(stkNeed()) > 0 ) {		// タイプに制約がある場合
				tmp = stkNeed(vectorLast) : vectorPop stkNeed()
				if ( tktype != tmp ) { assert : NextToken : return ParseMode_Complete }	// error
			}
			
			switch ( tktype )
				case TkType_BrkObjL: return ParseMode_Object
				case TkType_BrkArrL: return ParseMode_Array
					
				case TkType_String:
					vectorPush stkData(), strtrim(tkstr, 0, '"')	// 両端の二重引用符を取り除く
					swbreak
					
				case TkType_Digit:				// 整数
				case TkType_Number:				// 実数 (整数部 [+])
					if ( swthis == TkType_Digit ) {
						vectorPush stkData(), int(tkstr)
					} else {
						vectorPush stkData(), double(tkstr)
					}
					swbreak
					
				case TkType_Ident:
					switch ( tkstr )
						case "true":  vectorPush stkData(), true  : swbreak
						case "false": vectorPush stkData(), false : swbreak
						case "null":  vectorPush stkData(), assocNull : swbreak
					swend
					swbreak
			swend
			NextToken
			return ParseMode_Complete
	swend
	
/*/

//------------------------------------------------
// elem: Root
// 
// @syntax: (Object | Array | Value)
//------------------------------------------------
#modfunc obsjsonParser_Root var node,  local tmp
	switch ( tktype )
		case TkType_BrkObjL: obsjsonParser_Object thismod, tmp : swbreak
		case TkType_BrkArrL: obsjsonParser_Array  thismod, tmp : swbreak
		default:
			obsjsonParser_Value thismod, tmp
			swbreak
	swend
	
	assoc_xtree node, ObsJsonNodeName_Root, tmp(0)
	return
	
//------------------------------------------------
// elem: Object
// 
// @syntax: '{' Members '}'
// @	Members := Pair % ','		( a % b ⇔ (a (b a)*)? )
//------------------------------------------------
#modfunc obsjsonParser_Object var node,  local members, local tmp
	dbgout( "object {" )
	NextToken		// pop '{'
	
	assoc members
	
	// parse Members
	repeat
		if ( tktype == TkType_BrkObjR ) { break }
		
		obsjsonParser_Pair thismod, tmp
		members(refstr) = tmp(0)
		
		if ( tktype != TkType_BrkObjR && tktype != TkType_Comma ) {
			dbgout( "SyntaxError: 'Members' (need ',' or '}')" )	// error
			members = vectorNull
			break
		}
		if ( tktype == TkType_Comma ) { NextToken }
	loop
	
	assoc_xtree node, ObsJsonNodeName_Object, members(0)	// has Map<key, tnode(value)>
	
	NextToken		// pop '}'
	dbgout( "} object" )
	return
	
//------------------------------------------------
// elem: Pair
// 
// @syntax: String ':' Value
// @ キーを refstr に、value を node に返す。
//------------------------------------------------
#modfunc obsjsonParser_Pair var node,  local key
	dbgout( "pair <" )
	
	obsjsonParser_String thismod, key
	if ( tktype != TkType_Colon ) { dbgout( "SyntaxError: 'pair' (need ':')" ) : node = assocNull : return }
	NextToken
	
	obsjsonParser_Value thismod, node
	
	dbgout( "> pair" )
	return key("child")
	
//------------------------------------------------
// elem: Array
// 
// @ syntax: '[' Elements ']'
// @	Elements := Value % ','
//------------------------------------------------
#modfunc obsjsonParser_Array var node,  local elements, local tmp
	dbgout( "array [" )
	NextToken		// pop '['
	
	vector elements
	
	// parse Elements
	repeat
		if ( tktype == TkType_BrkArrR ) { break }
		
		obsjsonParser_Value thismod, tmp
		elements(cnt) = tmp(0)
		
		if ( tktype != TkType_BrkArrR && tktype != TkType_Comma ) {
			dbgout( "SyntaxError: 'Elements' (need ',' or ']')" )	// error
			elements = assocNull
			break
		}
		if ( tktype == TkType_Comma ) { NextToken }
	loop
	
	assoc_xtree node, ObsJsonNodeName_Array, elements()	// has List<Pair>
	
	NextToken		// pop ']'
	dbgout( "] array" )
	return
	
//------------------------------------------------
// elem: Value
// 
// @syntax: (Object | Array | Number | String | Ident)
//------------------------------------------------
#modfunc obsjsonParser_Value var node,  local tmp
	switch ( tktype )
		case TkType_BrkObjL: obsjsonParser_Object thismod, tmp : swbreak
		case TkType_BrkArrL: obsjsonParser_Array  thismod, tmp : swbreak
		
		case TkType_Digit:		// 整数
		case TkType_Number:		// 実数 (整数部 [+])
			obsjsonParser_Number thismod, tmp, (swthis == TkType_Digit)
			swbreak
		
		case TkType_String: obsjsonParser_String thismod, tmp : swbreak
		case TkType_Ident:  obsjsonParser_Ident  thismod, tmp : swbreak
		
		default:
			dbgout( "unknown value: (" + tktype + ", " + tkstr + ")" )
			NextToken
			node = assocNull
			return
	swend
	
	node = tmp(0)
	return
	
//------------------------------------------------
// elem: (Digit | Number)
// 
// @syntax: (略)
//------------------------------------------------
#modfunc obsjsonParser_Number var node, int bDigit
	if ( bDigit ) {
		node = int(tkstr)
	;	assoc_xtree node, ObsJsonNodeName_Number, int(tkstr)
	} else {
		node = double(tkstr)
	;	assoc_xtree node, ObsJsonNodeName_Number, double(tkstr)
	}
	NextToken
	return
	
//------------------------------------------------
// elem: String
// 
// @syntax: '"' [^"]* '"'
//------------------------------------------------
#modfunc obsjsonParser_String var node
	node = tkstr
;	assoc_xtree node, ObsJsonNodeName_String, tkstr
	NextToken
	return
	
//------------------------------------------------
// elem: Ident
// 
// @syntax: ("true" | "false" | "null")
//------------------------------------------------
#modfunc obsjsonParser_Ident var node
	switch ( getpath(tkstr, 16) )
		case "true":  node = true  : swbreak
		case "false": node = false : swbreak
		case "null":  node = null  : swbreak
	;	case "true":  assoc_xtree node, ObsJsonNodeName_Bool, true  : swbreak
	;	case "false": assoc_xtree node, ObsJsonNodeName_Bool, false : swbreak
	;	case "null":  assoc_xtree node, ObsJsonNodeName_Null, null  : swbreak
		default:
			dbgout( "UnknownIdent: " + tkstr )
			node = assocNull
	swend
	NextToken
	return
	
//*/
	
//##########################################################
//        その他
//##########################################################
//------------------------------------------------
// 
//------------------------------------------------

#global

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 0

#endif

#endif
