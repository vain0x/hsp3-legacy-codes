// opex - command header

#ifndef IG_COMMAND_OPEX_H
#define IG_COMMAND_OPEX_H

#include "hsp3plugin_custom.h"

extern void assign();
extern int  assign( PDAT** ppResult );

extern void swap();
extern int  swap( PDAT** ppResult );

extern void clone();
extern int  clone( PDAT** ppResult );

extern int  castTo( PDAT** ppResult );

extern void memberOf();
extern int  memberOf(PDAT** ppResult);
extern void memberClone();

extern int shortLogOp( PDAT** ppResult, bool bAnd );
extern int   cmpLogOp( PDAT** ppResult, bool bAnd );

extern int which(PDAT** ppResult);
extern int what(PDAT** ppResult);

extern int exprs( PDAT** ppResult );

extern int vtname(PDAT** ppResult);
//extern int labelname(PDAT** ppResult);

extern int kw_constptr( PDAT** ppResult );

// 定数
enum OPTYPE
{
	OPTYPE_MIN = 0,
	OPTYPE_ADD = OPTYPE_MIN,
	OPTYPE_SUB,
	OPTYPE_MUL,
	OPTYPE_DIV,
	OPTYPE_MOD,
	OPTYPE_AND,
	OPTYPE_OR,
	OPTYPE_XOR,
	OPTYPE_EQ,
	OPTYPE_NE,
	OPTYPE_GT,
	OPTYPE_LT,
	OPTYPE_GTEQ,
	OPTYPE_LTEQ,
	OPTYPE_RR,
	OPTYPE_LR,
	OPTYPE_MAX
};

namespace OpexCmd
{
	int const ConstPtr = 0x200;
}

#endif
