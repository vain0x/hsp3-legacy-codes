// vartype - functor

#ifndef IG_VARTYPE_FUNCTOR_H
#define IG_VARTYPE_FUNCTOR_H

#include "hsp3plugin_custom.h"
#include "reffuncResult.h"

#include "vp_template.h"
#include "../var_vector/vt_vector.h"

#include "Functor.h"

// 変数
extern hpimod::vartype_t g_vtFunctor;
extern HspVarProc* g_hvpFunctor;

// 関数
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

// 返値設定関数
extern functor_t g_resFunctor;
extern int SetReffuncResult(PDAT** ppResult, functor_t&& src);

// その他
extern vector_t code_get_vectorFromSequence();		// Invoker.cpp
extern functor_t code_get_functor();

#endif
