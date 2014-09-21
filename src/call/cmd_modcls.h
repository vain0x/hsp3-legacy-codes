// Call(ModCls) - Command header

#ifndef IG_CALL_MODCLS_COMMAND_H
#define IG_CALL_MODCLS_COMMAND_H

#include "hsp3plugin_custom.h"

namespace ModCls
{
	extern bool isWorking();
	extern void init();
	extern void term();
}

enum OpFlag
{
	OpFlag_Calc  = 0x0000,
	OpFlag_CnvTo = 0x0100,
	OpFlag_Sp    = 0x0200,

	// ‚»‚Ì‘¼
	OpId_Dup    = OpFlag_Sp | 0,
	OpId_Cmp    = OpFlag_Sp | 1,
	OpId_Method = OpFlag_Sp | 2,

	OpId_Max
};

#endif
