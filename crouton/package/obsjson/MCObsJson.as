// JSON (using obsidian)

#ifndef IG_MODULECLASS_OBSIDIAN_JSON_IMPL_AS
#define IG_MODULECLASS_OBSIDIAN_JSON_IMPL_AS

#include "Mo/strutil.as"

#include "hpi/obsidian/obsidian.as"

#include "ObsJson.as"
#include "MCObsJsonLexer.as"
#include "MCObsJsonParser.as"

#module ObsJson

#include "ObsJson.header.as"

//------------------------------------------------
// 真理値・成敗値・NULL値
//------------------------------------------------
#define true    1
#define false   0
#define success 1
#define failure 0
#define NULL    0

//##########################################################
//        構築・解体
//##########################################################
//------------------------------------------------
// 構築 (文字列)
//------------------------------------------------
#deffunc obsjson_NewFromText array self, str src,  local lexer, local parser, local tklist, local cntToken
	obsjsonLexer_new     lexer, src
	obsjsonLexer_Lex     lexer,       tklist : cntToken = stat
	obsjsonParser_new   parser
	obsjsonParser_Parse parser, self, tklist,  cntToken
	return
	
//------------------------------------------------
// 構築 (部分木)
//------------------------------------------------
#deffunc obsjson_NewFromTree array self, var srcSubtree
	self = srcSubtree
	return
	
//------------------------------------------------
// 解体
//------------------------------------------------
#deffunc obsjson_Delete array self
	self = assocNull
	return
	
//------------------------------------------------
// JSON文字列を生成する
//------------------------------------------------
#defcfunc obsjson_ToJsonText array self,  local stmp
	sdim stmp, 1024
	obsjson_ToJsonText_impl self, stmp, 0
	return stmp
	
#deffunc obsjson_ToJsonText_impl var self, var stmp, int nest,  \
	local self_arr, local text, local key, local val, local type, local node, local chd, local indent
	
	switch ( vartype(self) )
		case vartype("str"):    stmp += "\"" + self + "\"" : swbreak
		case vartype("double"):
		case vartype("int"):    stmp += str(self) : swbreak
			
		case assoc:		// object
			if ( assocIsNull(self) ) {		// null
				stmp += ObsJsonInternalConst_Null
				swbreak
				
			} elsif ( assocSize(self) == 0 ) {
				stmp += "{ }"
				swbreak
			}
			
			self_arr = self
			indent   = strmul("\t", nest)
			stmp    += "{\n"
			
			assocForeach self_arr(0), key
				stmp += indent + "\t\"" + key + "\" : "
				obsjson_ToJsonText_impl assocRef( self_arr(key) ), stmp, nest + 1
				stmp += ",\n"
			assocForeachEnd
			
			stmp += indent + "}"
			swbreak
			
		case vector:	// array
			if ( vectorSize(self) == 0 ) {
				stmp += "[ ]"
				swbreak
			}
			
			self_arr = self
			indent   = strmul("\t", nest)
			stmp    += "[\n"
			
			repeat vectorSize(self)
				stmp += indent + "\t"
				obsjson_ToJsonText_impl vectorRef( self_arr(cnt) ), stmp, nest + 1
				stmp += ",\n"
			loop
			
			stmp += indent + "]"
			swbreak
			
		default:
			dbgout( "unknown-node: " + swthis )
			swbreak
	swend
	return
	
#global

//##############################################################################
//                サンプル・スクリプト
//##############################################################################
#if 1

	src = {"
		{
			"name": "uedai",
			"age":  17,
			"list": [ 3, 1, 7 ],
			"obj": {
				"pt-bgn": {
					"class": "point",
					"x": 2, "y": 7
				},
				"pt-end": {
					"class": "point",
					"x": 1.0e2, "y": 83
				}
			},
			"using": true,
			"skill": null
		}
	"}
	
	obsjson_NewFromText jr, src
	
	buf = obsjson_ToJsonText( jr )
	mes buf
	stop
	
#endif

#endif
