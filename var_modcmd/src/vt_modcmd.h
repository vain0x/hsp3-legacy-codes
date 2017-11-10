// var_modcmd - VarProc header

#ifndef IG_VAR_MODCMD_VARPROC_H
#define IG_VAR_MODCMD_VARPROC_H

#include "hpimod/hsp3plugin_custom.h"
#include "hpimod/vartype_traits.h"

extern void HspVarModcmd_Init( HspVarProc* vp );

extern hpimod::vartype_t g_vtModcmd;
extern HspVarProc* g_pHvpModcmd;

using modcmd_t = int;
using vtModcmd = hpimod::VtTraits::NativeVartypeTag<modcmd_t>;

namespace VtModcmd
{
	typedef int value_t;	// modcmd å^ïœêîÇÃé¿ëÃ
	typedef value_t* valptr_t;
	const int basesize = sizeof(value_t);
	const value_t null = -1;		// 0xFF Ç≈ memset ÇµÇΩèÛë‘
	
	inline value_t make(int id) { return static_cast<value_t>(id); }
	inline bool isValid(const value_t& val) { return 0 <= val && val < ctx->hsphed->max_finfo; }
	value_t& at(PVal* pval);
};

#endif
