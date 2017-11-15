#ifndef IG_COMPLEX_COMMAND_H
#define IG_COMPLEX_COMMAND_H

#include <windows.h>
#include "hsp3plugin_custom.h"
#include "vp_complex.h"

extern void dimtype( int vt );

extern int complex_ctor( void** ppResult, bool bPolar );
extern int complex_info( void** ppResult );
extern int complex_opUnary ( void** ppResult, int cmd );
extern int complex_opBinary( void** ppResult, int cmd );

extern int complex_vt( void** ppResult );

extern complex_t* code_get_complex(void);

enum ComplexInfo
{
	ComplexInfo_None = 0,
	ComplexInfo_Re   = ComplexInfo_None,
	ComplexInfo_Im,
	ComplexInfo_Abs,
	ComplexInfo_Arg,
	ComplexInfo_Max
};

//------------------------------------------------
// 記号のコード値
//------------------------------------------------
enum MarkCode
{
	MarkCode_Top    = 0,
	MarkCode_Top_Op = MarkCode_Top,
	
	// 単項演算子
	MarkCode_Top_OpUni = MarkCode_Top_Op,
	MarkCode_Plus      = MarkCode_Top_OpUni,
	MarkCode_Minus,
	MarkCode_Inv,
	MarkCode_Neg,
	MarkCode_Pack,
	MarkCode_UnPack,
	MarkCode_Max_OpUni,
	
	// 二項演算子
	MarkCode_Top_OpBin = MarkCode_Max_OpUni,
	MarkCode_Add       = MarkCode_Top_OpBin,
	MarkCode_Sub,
	MarkCode_Mul,
	MarkCode_Div,
	MarkCode_Mod,
	MarkCode_And,
	MarkCode_Or,
	MarkCode_Xor,
	MarkCode_ShL,
	MarkCode_ShR,
	MarkCode_LAnd,
	MarkCode_LOr,
	MarkCode_Cmp,
	MarkCode_Eq,
	MarkCode_Ne,
	MarkCode_IdEq,
	MarkCode_IdNe,
	MarkCode_Lt,
	MarkCode_Gt,
	MarkCode_LtEq,
	MarkCode_GtEq,
	MarkCode_Cat,
	MarkCode_Max_OpBin,
	
	// 終了
	MarkCode_Max = MarkCode_Max_OpBin,
};

typedef MarkCode MarkCode_t;

#endif
