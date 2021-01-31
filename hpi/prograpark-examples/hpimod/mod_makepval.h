// PVal ç\ë¢ëÃÇÃì∆é©ä«óù

#ifndef IG_MODULE_HPIMOD_MAKE_PVAL_H
#define IG_MODULE_HPIMOD_MAKE_PVAL_H

#include "hsp3plugin_custom.h"

static const unsigned int ArrayDimCnt = 4;		// ç≈ëÂéüå≥êî

//##########################################################
//        ä÷êîêÈåæ
//##########################################################
extern void PVal_init( PVal* pval, vartype_t vflag );
extern void PVal_alloc( PVal* pval, PVal* pval2 = NULL, vartype_t vflag = HSPVAR_FLAG_NONE );
extern void PVal_clear( PVal* pval, vartype_t vflag );
extern void PVal_free( PVal* pval );

extern PVal* PVal_getDefault( vartype_t vt = HSPVAR_FLAG_INT );

// éÊìæån
extern size_t PVal_cntElems( PVal* pval );
extern size_t PVal_size( PVal* pval );
extern PDAT*  PVal_getptr( PVal* pval );

// ëÄçÏån
extern void PVal_assign( PVal* pvLeft, void* pData, vartype_t vflag );
extern void PVal_assign_multi( PVal* pvLeft, void* pData, vartype_t vflag );
extern void PVal_copy( PVal* pvDst, PVal* pvSrc );
extern void PVal_clone( PVal* pvDst, PVal* pvSrc, APTR aptrSrc = -1 );
extern void PVal_clone( PVal* pvDst, void* ptr, int flag, int size );

// ÇªÇÃëº
extern void SetResultSysvar( const void* pValue, vartype_t vflag );
extern const PDAT* Valptr_cnvTo( const PDAT* pValue, vartype_t vtSrc, vartype_t vtDst );

// OpenHSP Ç©ÇÁÇÃà¯óp
void HspVarCoreDupptr( PVal* pval, int flag, void* ptr, int size );
void HspVarCoreDup( PVal* pval, PVal* arg, APTR aptr );

#endif
