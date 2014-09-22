// vartype - functor

#ifndef IG_VARTYPE_FUNCTOR_H
#define IG_VARTYPE_FUNCTOR_H

#include "hsp3plugin_custom.h"
#include "reffuncResult.h"

#include "vp_template.h"
#include "../var_vector/vt_vector.h"

#include "Functor.h"

// ïœêî
extern vartype_t g_vtFunctor;
extern HspVarProc* g_hvpFunctor;

// ä÷êî
extern void HspVarFunctor_init(HspVarProc* vp);

// vartype traits
using vtFunctor = hpimod::VtTraits::NativeVartypeTag<functor_t>;
namespace hpimod {
	namespace VtTraits
	{
		namespace Impl
		{
			template<> static vartype_t vartype<vtFunctor>() { return g_vtFunctor; }
		}
	}
}

// ï‘ílê›íËä÷êî
extern functor_t g_resFunctor;
extern int SetReffuncResult(PDAT** ppResult, functor_t const& src);
extern int SetReffuncResult(PDAT** ppResult, functor_t&& src);

// ÇªÇÃëº
extern vector_t code_get_vectorFromSequence();		// Invoker.cpp
extern functor_t code_get_functor();

#endif
