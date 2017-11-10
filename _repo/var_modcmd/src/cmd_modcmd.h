// var_modcmd - commad header

#ifndef IG_VAR_MODCMD_COMMAND_H
#define IG_VAR_MODCMD_COMMAND_H

#include "hpimod/hsp3plugin_custom.h"
#include "vt_modcmd.h"

extern modcmd_t code_get_modcmd();
extern int code_get_modcmdId();

//extern void modcmdDim();
extern int modcmdCall(modcmd_t modcmd, PDAT** ppResult = nullptr);
void modcmdCallForwardSttm();
int modcmdCallForwardFunc(PDAT** ppResult);

//extern int modcmdCnv(PDAT** ppResult);

namespace ModcmdCmd {
	int const
		Call = 0x001,
		NoCall = 0x7FF;
}

#endif
