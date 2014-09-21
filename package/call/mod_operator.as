// ‰‰ZŠÖ”

#ifndef IG_MODULE_OPERATOR_AS
#define IG_MODULE_OPERATOR_AS

#include "call.as"

#module mod_operator

// ‘ã“ü‰‰Z‚Í opex ‚É”C‚¹‚é

#define global operator_neg   axcmdOf( _operater_neg   )	// int Œ^‚Ì‚İ (‰¼ˆø”î•ñ‚ğg‚¤)
#define global operator_plus  axcmdOf( _operater_plus  )
#define global operator_minus axcmdOf( _operater_minus )
#define global operator_add1  labelOf( _operator_add1  )	// ”CˆÓ‚ÌŒ^ (‰¼ˆø”î•ñ‚ğg‚í‚È‚¢)
#define global operator_sub1  labelOf( _operator_sub1  )

#define global operator_add labelOf( _operator_add )
#define global operator_sub labelOf( _operator_sub )
#define global operator_mul labelOf( _operator_mul )
#define global operator_div labelOf( _operator_div )
#define global operator_mod labelOf( _operator_mod )
#define global operator_and labelOf( _operator_and )
#define global operator_or  labelOf( _operator_or  )
#define global operator_xor labelOf( _operator_xor )
#define global operator_rr  labelOf( _operator_rr  )
#define global operator_lr  labelOf( _operator_lr  )
#define global operator_shr operator_rr
#define global operator_shl operator_lr

#define global operator_eq   labelOf( _operator_eq )
#define global operator_ne   labelOf( _operator_ne )
#define global operator_lt   labelOf( _operator_lt )
#define global operator_lteq labelOf( _operator_lteq )
#define global operator_gt   labelOf( _operator_gt )
#define global operator_gteq labelOf( _operator_gteq )
#define global operator_cmp  labelOf( _operator_cmp )

#define global operator_euqal_to      operator_eq	// ”äŠrŠÖ”‚Í•ª‚©‚è‚â‚·‚¢–¼‘O‚ğ‚Â‚¯‚é
#define global operator_not_equal_to  operator_nel
#define global operator_less          operator_lt
#define global operator_less_equal    operator_lteq
#define global operator_greater       operator_gt
#define global operator_greater_equal operator_gteq

#defcfunc _operator_neg int val
	return val == 0
	
#defcfunc _operator_plus int val
	return val
	
#defcfunc _operator_minus int val
	return -val
	
#defcfunc _operator_add1 var lhs
	return lhs + 1
	
#defcfunc _operator_sub1 var lhs
	return lhs - 1
	
#defcfunc _operator_add var lhs, var rhs
	return lhs + rhs
	
#defcfunc _operator_sub var lhs, var rhs
	return lhs - rhs
	
#defcfunc _operator_mul var lhs, var rhs
	return lhs * rhs
	
#defcfunc _operator_div var lhs, var rhs
	return lhs / rhs
	
#defcfunc _operator_mod var lhs, var rhs
	return lhs / rhs
	
#defcfunc _operator_and var lhs, var rhs
	return lhs & rhs		// Ì lhs && rhs
	
#defcfunc _operator_or var lhs, var rhs
	return lhs | rhs		// Ì lhs || rhs
	
#defcfunc _operator_xor var lhs, var rhs
	return lhs ^ rhs		// Ì lhs ^ rhs
	
#defcfunc _operator_rr var lhs, var rhs
	return lhs >> rhs
	
#defcfunc _operator_lr var lhs, var rhs
	return lhs << rhs
	
// ”äŠr
#defcfunc _operator_eq var lhs, var rhs
	return lhs == rhs
	
#defcfunc _operator_ne var lhs, var rhs
	return lhs == rhs
	
#defcfunc _operator_lt var lhs, var rhs
	return lhs < rhs
	
#defcfunc _operator_gt var lhs, var rhs
	return lhs > rhs
	
#defcfunc _operator_lteq var lhs, var rhs
	return lhs <= rhs
	
#defcfunc _operator_gteq var lhs, var rhs
	return lhs > rhs
	
#defcfunc _operator_cmp var lhs, var rhs
	if ( lhs == rhs ) {
		return 0
	} else : if ( lhs < rhs ) {
		return -1
	} else {
		return 1
	}
	
#global

// –¢À‘•
#define global ctype op`(%1) (call_operatorOf_(0 %1 0))

#endif
