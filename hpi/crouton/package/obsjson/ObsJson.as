// json (obsjson)

#ifndef        IG_OBSIDIAN_JSON_HEADER_AS
#define global IG_OBSIDIAN_JSON_HEADER_AS

//------------------------------------------------
// 定数：値の種類
//------------------------------------------------
#enum global ObsJsonValueType_Null = 0
#enum global ObsJsonValueType_Object
#enum global ObsJsonValueType_Pair
#enum global ObsJsonValueType_Array
#enum global ObsJsonValueType_String
#enum global ObsJsonValueType_Number
#enum global ObsJsonValueType_Bool
#enum global ObsJsonValueType_MAX

//------------------------------------------------
// 定数：ノードの種類と名前
//------------------------------------------------
#enum global ObsJsonNodeType_Root = 0
#enum global ObsJsonNodeType_Object
#enum global ObsJsonNodeType_Pair
#enum global ObsJsonNodeType_Array
#enum global ObsJsonNodeType_Value
#enum global ObsJsonNodeType_String
#enum global ObsJsonNodeType_Number
#enum global ObsJsonNodeType_Bool
#enum global ObsJsonNodeType_Null
#enum global ObsJsonNodeType_MAX

#define global ObsJsonNodeName_Root   "json-root"
#define global ObsJsonNodeName_Object "object"
#define global ObsJsonNodeName_Pair   "pair"
#define global ObsJsonNodeName_Array  "array"
#define global ObsJsonNodeName_Value  "value"
#define global ObsJsonNodeName_String "string"
#define global ObsJsonNodeName_Number "number"
#define global ObsJsonNodeName_Bool   "bool"
#define global ObsJsonNodeName_Null   "null"
#define global ObsJsonNodeName_MAX

//------------------------------------------------
// 定数：組み込みの定数識別子
//------------------------------------------------
#define global ObsJsonInternalConst_True  "true"
#define global ObsJsonInternalConst_False "false"
#define global ObsJsonInternalConst_Null  "null"

#endif
