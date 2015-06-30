// var_modcmd - commad header

#ifndef IG_VAR_MODCMD_COMMAND_H
#define IG_VAR_MODCMD_COMMAND_H

#include "hsp3plugin_custom.h"
#include "vt_modcmd.h"

extern modcmd_t code_get_modcmd();
extern int code_get_modcmdId();

// 命令
//extern void modcmdDim();
extern int modcmdCall(modcmd_t modcmd, void** ppResult = nullptr);

// 関数
//extern int modcmdCnv(void** ppResult);

// システム変数

namespace ModcmdCmd {
	int const
		NoCall = 0x7FF;
}

#endif
