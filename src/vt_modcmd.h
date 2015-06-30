// var_modcmd - VarProc header

#ifndef IG_VAR_MODCMD_VARPROC_H
#define IG_VAR_MODCMD_VARPROC_H

#include "hsp3plugin_custom.h"

extern void HspVarModcmd_Init( HspVarProc* vp );

extern hpimod::vartype_t g_vtModcmd;
extern HspVarProc* g_pHvpModcmd;

namespace VtModcmd
{
	typedef int value_t;	// modcmd 型変数の実体
	typedef value_t* valptr_t;
	const int basesize = sizeof(value_t);
	const value_t null = -1;		// 0xFF で memset した状態
	
	inline value_t make(int id) { return static_cast<value_t>(id); }
	inline bool isValid(const value_t& val) { return 0 <= val && val < ctx->hsphed->max_finfo; }
	value_t& at(PVal* pval);
};

typedef VtModcmd::value_t modcmd_t;

#endif
