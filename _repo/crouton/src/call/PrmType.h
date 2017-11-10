#ifndef IG_PARAMETER_TYPE_H
#define IG_PARAMETER_TYPE_H

#include "hsp3plugin_custom.h"

using prmtype_t = short;

extern prmtype_t code_get_prmtype(prmtype_t _default);

namespace PrmType {

//------------------------------------------------
// 仮引数タイプ (call.hpi 用)
// 
// @ HSPVAR_FLAG_* と併用。
// @ None を除き負値。
//------------------------------------------------
static prmtype_t const
	Var     = (-2),		// var   指定 (参照渡し要求)
	Array   = (-3),		// array 指定 (参照渡し要求)
	Modvar  = (-4),		// modvar指定 (参照渡し要求)
	Any     = (-5),		// any   指定 (既定で値渡し要求、byref で参照渡しも可能)
	Capture = (-6),		// (lambda が内部的に用いる、実引数不要)
	Local   = (-7),		// local 指定 (実引数不要)
	Flex    = (-1),		// 可変長引数
	None    = 0;		// 無効

//------------------------------------------------
// 変数型の仮引数タイプか
//------------------------------------------------
static inline bool isNativeVartype(prmtype_t prmtype)
{
	return (HSPVAR_FLAG_NONE < prmtype && prmtype < HSPVAR_FLAG_STRUCT);
}

static inline bool isExtendedVartype(prmtype_t prmtype)
{
	return (HSPVAR_FLAG_STRUCT <= prmtype && prmtype <= HSPVAR_FLAG_USERDEF + ctx->hsphed->max_varhpi);
}

static inline bool isVartype(prmtype_t prmtype)
{
	return isNativeVartype(prmtype) || isExtendedVartype(prmtype);
}

//------------------------------------------------
// 参照渡しの仮引数タイプか
//
// @ Any は参照渡し引数ではないとする。
//------------------------------------------------
static bool isRef(prmtype_t prmtype)
{
	return prmtype == PrmType::Var
		|| prmtype == PrmType::Array
		|| prmtype == PrmType::Modvar
		;
}

//------------------------------------------------
// 仮引数タイプが prmstack に要求するサイズ
//------------------------------------------------
static size_t sizeOf(prmtype_t prmtype)
{
	switch ( prmtype ) {
		case HSPVAR_FLAG_LABEL:  return sizeof(hpimod::label_t);
		case HSPVAR_FLAG_STR:    return sizeof(char*);
		case HSPVAR_FLAG_DOUBLE: return sizeof(double);
		case HSPVAR_FLAG_INT:    return sizeof(int);
		case PrmType::Modvar:    return sizeof(MPModVarData);
		case PrmType::Local:     return sizeof(PVal);

		case PrmType::Var:
		case PrmType::Array:
		case PrmType::Any:
		case PrmType::Capture: return sizeof(MPVarData);
		case PrmType::Flex:    return sizeof(void*);
		default:
			// その他の型タイプ値
			if ( isExtendedVartype(prmtype) ) {
				return sizeof(MPVarData);
			}
			assert(false); puterror(HSPERR_UNKNOWN_CODE);
	}
}

//------------------------------------------------
// prmtype <- mptype (failure: None)
//------------------------------------------------
static prmtype_t fromMPType(prmtype_t mptype)
{
	switch ( mptype ) {
		case MPTYPE_LABEL:       return HSPVAR_FLAG_LABEL;
		case MPTYPE_LOCALSTRING: return HSPVAR_FLAG_STR;
		case MPTYPE_DNUM:        return HSPVAR_FLAG_DOUBLE;
		case MPTYPE_INUM:        return HSPVAR_FLAG_INT;
		case MPTYPE_SINGLEVAR:   return PrmType::Var;
		case MPTYPE_ARRAYVAR:    return PrmType::Array;
		case MPTYPE_IMODULEVAR:	//
		case MPTYPE_MODULEVAR:   return PrmType::Modvar;
		case MPTYPE_LOCALVAR:    return PrmType::Local;

		// (dtor は mpval の値を保存する領域として、any を1つ持つことにしておく)
		case MPTYPE_TMODULEVAR:  return PrmType::Any;

		default:
			return PrmType::None;
	}
}

//------------------------------------------------
// prmtype <- string (failure: None)
//------------------------------------------------
extern prmtype_t fromString(char const* s);

} // namespace PrmType

#endif
