// ctype which

#ifndef IG_CTYPE_WHICH_AS
#define global IG_CTYPE_WHICH_AS
#ifndef cond_i

#module
#defcfunc cond_i int cond, int x, int y
	if (cond) { return x } else { return y }
#global

#module
#define global ctype cond_d(%1, %2 = 0, %3 = 0) cond_d_@__uedai(%1, %2, %3)
#defcfunc cond_d_@__uedai int cond, double x, double y
	if (cond) { return x } else { return y }
#global

#module
#define global ctype cond_s(%1, %2 = "", %3 = "") cond_s_@__uedai(%1, %2, %3)
#defcfunc cond_s_@__uedai int cond, str x, str y
	if (cond) { return x } else { return y }
#global

#endif

#undef cwhich_int
#define global cwhich_int cond_i
#define global cwhich_str cond_s
#define global cwhich_double cond_d

#endif
