// assoc - VarProc header

#ifndef IG_ASSOC_VARPROC_H
#define IG_ASSOC_VARPROC_H

#include "hsp3plugin_custom.h"

class CAssoc;

extern int g_vtAssoc;
extern HspVarProc* g_hvpAssoc;

// traits
using vtAssoc = hpimod::VtTraits::NativeVartypeTag<CAssoc*>;

namespace hpimod
{
	namespace VtTraits
	{

		namespace Impl
		{
			template<> struct master_type<vtAssoc> { using type = PVal*; };
			template<> static vartype_t vartype<vtAssoc>() { return g_vtAssoc; }
		}
	}
};

// ä÷êî
extern void HspVarAssoc_Init( HspVarProc* );
extern CAssoc* code_get_assoc();
extern PVal*   code_get_assoc_pval();

static int const assocIndexFullslice = 0xFABC0000;

/*
namespace AssocTraits
{

	static valptr_t asValptr(void* pdat) { return reinterpret_cast<valptr_t>(pdat); }
	static const_valptr_t asValptr(void const* pdat) { return reinterpret_cast<const_valptr_t>(pdat); }
	static valptr_t getPtr(PVal* pval) { return (reinterpret_cast<value_t*>(pval->pt) + pval->offset); }
	static master_t getMaster(PVal* pval) { return reinterpret_cast<master_t>(pval->master); }
}//*/

#endif
