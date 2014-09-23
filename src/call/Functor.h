// 関数子オブジェクト

#ifndef IG_CLASS_FUNCTOR_H
#define IG_CLASS_FUNCTOR_H

#include "IFunctor.h"
#include "Managed.h"

using functor_t = hpimod::Managed<IFunctor, true>;

// include core functors
//#include "CLabelFunc.h"
//#include "CDeffunc.h"

namespace Functor
{
	extern functor_t const& New(int axcmd);
	extern functor_t const& New(hpimod::label_t lb);

//	template<typename TFunctor, typename ...Args>
//	static functor_t New(Args&&... args) { return functor_t::make<TFunctor>(std::forward<Args>(args)...); }

	extern void Terminate();
}

#endif
