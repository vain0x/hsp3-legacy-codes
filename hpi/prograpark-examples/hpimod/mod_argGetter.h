// 引数取得モジュール

#ifndef IG_MODULE_ARGUMENT_GETTER_H
#define IG_MODULE_ARGUMENT_GETTER_H

#include "hsp3plugin_custom.h"

//##############################################################################
//                関数宣言
//##############################################################################
// 引数の取得
//extern bool code_getva_ex(PVal** pval, APTR* aptr);
extern int  code_getds_ex(char** ppStr, const char* defstr = "");
extern int  code_getsi(char** ppStr);
extern int  code_getvartype(int defType = HSPVAR_FLAG_NONE);
extern label_t code_getdlb(label_t defLabel = NULL);
//extern label_t code_getlb2(void);

// 配列添字
extern void  code_index_lhs( PVal* pval );
extern void  code_index_rhs( PVal* pval );
extern void  code_index_obj_lhs( PVal* pval );
extern PDAT* code_index_obj_rhs( PVal* pval, int* mptype );

extern void code_index_int( PVal* pval, int offset, bool bRhs );
extern void code_index_int_lhs( PVal* pval, int offset );

extern void code_expand_index_impl( PVal* pval );

// 配列代入エミュレート
extern void code_assign_multi( PVal* pval );

// その他
extern bool code_isNextArg(void);
extern int  code_skipprm(void);

#endif
