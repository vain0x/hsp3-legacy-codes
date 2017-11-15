// var_modcmd.hpi import header

#ifndef        IG_VAR_MODCMD_HPI_AS
#define global IG_VAR_MODCMD_HPI_AS

#define VAR_MODCMD_RELEASE	// last update: 2014/02/16

#ifdef VAR_MODCMD_RELEASE
 #define VAR_MODCMD_HPI_PATH "var_modcmd.hpi"
#else
 #define VAR_MODCMD_HPI_PATH "D:/Docs/prg/cpp/MakeHPI/var_modcmd/Debug/var_modcmd.hpi"
#endif

#regcmd "_hpi_modcmd@4", VAR_MODCMD_HPI_PATH, 1
#cmd modcmd     0x000
#cmd modcmdCall 0x001

#cmd modcmdIdOf 0x100
#cmd modcmdOf	0x101

#cmd modcmd_nocall 0x7FF

#endif
