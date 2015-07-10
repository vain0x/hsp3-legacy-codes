// HSPキーワード

#ifndef IG_HSP_KEYWORDS_AS
#define IG_HSP_KEYWORDS_AS

#include "hspconst.as"

#module hspkeywords

//------------------------------------------------
// 初期化
// 
// @upto: hsp3.31b1
//------------------------------------------------
#deffunc initialize_hspkeywords
	// type 値の名前
	typename      = "TYPE_MARK", "TYPE_VAR", "TYPE_STRING", "TYPE_DNUM", "TYPE_INUM", "TYPE_STRUCT", "TYPE_XLABEL", "TYPE_LABEL", "TYPE_INTCMD", "TYPE_EXTCMD", "TYPE_EXTSYSVAR", "TYPE_CMPCMD", "TYPE_MODCMD", "TYPE_INTFUNC", "TYPE_SYSVAR", "TYPE_PROGCMD", "TYPE_DLLFUNC", "TYPE_DLLCTRL", "TYPE_USERDEF"
;	calccode_name = "CALCCODE_ADD", "CALCCODE_SUB", "CALCCODE_MUL", "CALCCODE_DIV", "CALCCODE_MOD", "CALCCODE_AND", "CALCCODE_OR", "CALCCODE_XOR", "CALCCODE_EQ", "CALCCODE_NE", "CALCCODE_GT", "CALCCODE_LT", "CALCCODE_GTEQ", "CALCCODE_LTEQ", "CALCCODE_RR", "CALCCODE_LR", "CALCCODE_MAX"
	calccode_name    = "+", "-", "*", "/", "\\"
	calccode_name(5) = "&", "|", "^", "=", "!", ">", "<", ">=", "<=", ">>", "<<", "CALCCODE_MAX"
;	calccode_name = "+ (CALCCODE_ADD)", "- (CALCCODE_SUB)", "* (CALCCODE_MUL)", "/ (CALCCODE_DIV)", "\\ (CALCCODE_MOD)", "& (CALCCODE_AND)", "| (CALCCODE_OR)", "^ (CALCCODE_XOR)", "= (CALCCODE_EQ)", "! (CALCCODE_NE)", "> (CALCCODE_GT)", "< (CALCCODE_LT)", ">= (CALCCODE_GTEQ)", "<= (CALCCODE_LTEQ)", ">> (CALCCODE_RR)", "<= (CALCCODE_LR)", "CALCCODE_MAX"
	
	// 命令・関数の名前
	intcmd_name         = "onexit", "onerror", "onkey", "onclick", "oncmd"
	intcmd_name(0x11)   = "exist", "delete", "mkdir", "chdir", "dirlist", "bload", "bsave", "bcopy", "memfile", "poke", "wpoke", "lpoke", "getstr", "chdpm", "memexpand", "memcpy", "memset", "notesel", "noteadd","notedel", "noteload", "notesave", "randomize", "noteunsel", "noteget", "split", "strrep"
	extcmd_name         = "button", "chgdisp", "exec", "dialog"
	extcmd_name(0x08)   = "mmload", "mmplay", "mmstop", "mci","pset", "pget", "syscolor", "mes", "title", "pos", "circle", "cls", "font", "sysfont", "objsize", "picload", "color", "palcolor", "palette", "redraw", "width","gsel", "gcopy", "gzoom", "gmode", "bmpsave", "hsvcolor", "getkey", "listbox", "chkbox", "combox", "input", "mesbox", "buffer", "screen", "bgscr", "mouse", "objsel", "groll", "line", "clrobj", "boxf", "objprm", "objmode", "stick", "grect","grotate", "gsquare", "gradf", "objimage", "objskip", "objenable", "celload", "celdiv", "celput"
	extsysvar_name_0    = "mousex", "mousey", "mousew", "hwnd", "hinstance", "hdc"
	extsysvar_name_1    = "ginfo", "objinfo", "dirinfo", "sysinfo"
	cmpcmd_name         = "if", "else"
	intfunc_name_0      = "int", "rnd", "strlen", "length", "length2", "length3", "length4", "vartype", "gettime", "peek", "wpeek", "lpeek", "varptr", "varuse", "noteinfo", "instr", "abs", "limit"
	intfunc_name_1      = "str", "strmid", "", "strf", "getpath", "strtrim"
	intfunc_name_2      = "sin", "cos", "tan", "atan", "sqrt", "double", "absf", "expf", "logf", "limitf", "powf"
	sysvar_name         = "system", "hspstat", "hspver", "stat", "cnt", "err", "strsize", "looplev", "sublev", "iparam", "wparam", "lparam", "refstr", "refdval", ""
	progcmd_name        = "goto", "gosub", "return", "break", "repeat", "loop", "continue", "wait", "await", "dim", "sdim", "foreach", "(each-chk)", "dimtype", "dup", "dupptr", "end", "stop", "newmod", "setmod", "delmod", "", "mref", "run", "exgoto", "on", "mcall", "assert", "logmes", "newlab", "resume", "yield"
	dllctrl_name_0      = "newcom", "querycom", "delcom", "cnvstow", "comres", "axobj", "winobj", "sendmsg", "comevent", "comevarg", "sarrayconv"
	dllctrl_name_1      = "callfunc", "cnvwtos", "comevdisp", "libptr"
	return
	
//------------------------------------------------
// code値から文字列を求める
//------------------------------------------------
#defcfunc getString_mark int c
	if ( c < length(calccode_name) ) {
		return calccode_name(c)
	}
	return strf("%c", c)
	
#defcfunc getString_type int type
	if ( type < length(typename) - 1 ) {	// TYPE_USERDEF は表示しない
		return typename(type)
	} else {
		return "TYPE_(" + type + ")"
	}
	
#defcfunc getString_intcmd int code
	return intcmd_name(code)
	
#defcfunc getString_extcmd int code
	return extcmd_name(code)
	
#defcfunc getString_extsysvar int code
	if ( code >= 0x100 ) : return extsysvar_name_1(code - 0x100)
	return extsysvar_name_0(code)
	
#defcfunc getString_cmpcmd int code
	return cmpcmd_name(code)
	
#defcfunc getString_intfunc int code
	if ( code >= 0x180 ) : return intfunc_name_2(code - 0x180)
	if ( code >= 0x100 ) : return intfunc_name_1(code - 0x100)
	return intfunc_name_0(code)
	
#defcfunc getString_sysvar int code
	return sysvar_name(code)
	
#defcfunc getString_progcmd int code
	return progcmd_name(code)
	
#defcfunc getString_dllctrl int code
	if ( code >= 0x100 ) : return dllctrl_name_1(code - 0x100)
	return dllctrl_name_0(code)
	
//------------------------------------------------
// mptype から文字列を求める
//------------------------------------------------
#defcfunc getString_mptype int mptype
	switch ( mptype )
		case MPTYPE_NONE        : return "[none]"
		case MPTYPE_VAR         : return "var"
		case MPTYPE_STRING      : return "str"
		case MPTYPE_DNUM        : return "double"
		case MPTYPE_INUM        : return "int"
		case MPTYPE_STRUCT      : return "struct"
		case MPTYPE_LABEL       : return "label"
		case MPTYPE_LOCALVAR    : return "local"
		case MPTYPE_ARRAYVAR    : return "array"
		case MPTYPE_SINGLEVAR   : return "var"
		case MPTYPE_FLOAT       : return "float"
		case MPTYPE_STRUCTTAG   : return "structtag"
		case MPTYPE_LOCALSTRING : return "str"
		case MPTYPE_MODULEVAR   : return "modvar"
		case MPTYPE_PPVAL       : return "pval"
		case MPTYPE_PBMSCR      : return "bmscr"
		case MPTYPE_PVARPTR     : return "var"
		case MPTYPE_IMODULEVAR  : return "modinit"
		case MPTYPE_IOBJECTVAR  : return "comobj"
		case MPTYPE_LOCALWSTR   : return "wstr"
		case MPTYPE_FLEXSPTR    : return "sptr"
		case MPTYPE_FLEXWPTR    : return "wptr"
		case MPTYPE_PTR_REFPTR  : return "prefptr"
		case MPTYPE_PTR_EXINFO  : return "pexinfo"
		case MPTYPE_PTR_DPMINFO : return "pdpminfo"	// ( MPTYPE_PTR_DPMINFO ) #func に 0x20 を指定すると第四引数がこれになる
		case MPTYPE_NULLPTR     : return "nullptr"
		case MPTYPE_TMODULEVAR  : return "modterm"
	swend
	logmes dbgstr(mptype)
	return "[unknown]"
	
#global

initialize_hspkeywords

#endif
