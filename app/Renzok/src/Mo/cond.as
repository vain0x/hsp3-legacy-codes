#ifndef IG_CONDITIONAL_OPERATOR_AS
#define IG_CONDITIONAL_OPERATOR_AS

// Use opex.hpi instead.

#module

#defcfunc cond_i int cond, int then_, int else_
	if (cond) { return then_ } else { return else_ }

#defcfunc cond_d int cond, double then_, double else_
	if (cond) { return then_ } else { return else_ }
	
#define global ctype cond_s(%1, %2 = "", %3 = "") \
	cond_s_(%1, %2, %3)

#defcfunc cond_s_ int cond, str then_, str else_
	if (cond) { return then_ } else { return else_ }
	
#global

#endif
