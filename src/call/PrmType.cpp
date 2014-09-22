
#include <map>
#include "PrmType.h"

using namespace hpimod;

namespace PrmType
{

//------------------------------------------------
// prmtype <- string (failure: None)
//------------------------------------------------
static prmtype_t fromString(char const* s)
{
	static std::map<std::string, prmtype_t> stt_table = {
		{ "var", PrmType::Var },
		{ "array", PrmType::Array },
		{ "any", PrmType::Any },
		{ "modvar", PrmType::Modvar },
		{ "thismod", PrmType::Modvar },
		{ "local", PrmType::Local },
		{ "...", PrmType::Flex },
		{ "flex", PrmType::Flex },
	};

	if ( HspVarProc* const vp = hpimod::seekHvp(s) ) {
		return vp->flag;

	} else {
		auto const iter = stt_table.find(s);
		if ( iter != stt_table.end() ) {
			return iter->second;

		} else {
			// failure
			return PrmType::None;
		}
	}
}

} // namespace PrmType

//------------------------------------------------
// ‰¼ˆø”ƒ^ƒCƒv‚ğæ“¾‚·‚é
//------------------------------------------------
prmtype_t code_get_prmtype(prmtype_t _default)
{
	int const chk = code_getprm();
	if ( chk <= PARAM_END ) {
		return ( chk == PARAM_DEFAULT )
			? _default
			: PrmType::None;
	}

	switch ( mpval->flag ) {
		case HSPVAR_FLAG_INT:
			return VtTraits::derefValptr<vtInt>(mpval->pt);

		case HSPVAR_FLAG_STR:
		{
			// •¶š—ñ => “Áê•¶š—ñ or Œ^–¼( HspVarProc ‚©‚çæ“¾ )

			auto const prmtype = PrmType::fromString(VtTraits::asValptr<vtStr>(mpval->pt));
			if ( prmtype == PrmType::None ) puterror(HSPERR_ILLEGAL_FUNCTION);
			return prmtype;
		}
		default:
			puterror(HSPERR_TYPE_MISMATCH);
	}
}
