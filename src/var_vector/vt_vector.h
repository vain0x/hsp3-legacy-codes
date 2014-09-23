// vector - VarProc header

#ifndef IG_VECTOR_VARPROC_H
#define IG_VECTOR_VARPROC_H

#include <vector>
#include "vp_template.h"
#include "Managed.h"
#include "ManagedPVal.h"
#include "HspAllocator.h"

//#include "CVector.h"

using vector_t = hpimod::Managed<
	std::vector<hpimod::ManagedVarData, hpimod::HspAllocator<hpimod::ManagedVarData>>,
	false
>;

// vartype traits
struct vtVector {

	// special indexes
	static int const IdxBegin = 0;
	static int const IdxLast = (-101);	// 最後の要素を表す添字コード
	static int const IdxEnd  = (-102);	// (最後の要素 + 1)を表す添字コード
	static int const IdxFullSlice = (-100);	// vector の全体スライスを表す添字コード

};

namespace hpimod
{
	namespace VtTraits
	{
		namespace Impl
		{
			template<> struct value_type<vtVector> { using type = vector_t; };
			template<> struct const_value_type<vtVector> { using type = vector_t const; };
			template<> struct valptr_type<vtVector> { using type = vector_t*; };
			template<> struct const_valptr_type<vtVector> { using type = vector_t const*; };
			template<> struct master_type<vtVector> { using type = vector_t; };	// 実体値
			template<> struct basesize<vtVector> { static int const value = sizeof(vector_t); };
		}
	}
}

//------------------------------------------------
// 内部変数の取得
// 
// @ 本体が参照されているときは nullptr を返す。
//------------------------------------------------
static PVal* getInnerPVal(PVal* pval, APTR aptr)
{
	return hpimod::VtTraits::getMaster<vtVector>(pval)->at(aptr).getPVal();
}

static PVal* getInnerPVal(PVal* pval)
{
	if ( pval->arraycnt == 0 ) return nullptr;
	return getInnerPVal(pval, pval->offset);
}

// グローバル変数
extern hpimod::vartype_t g_vtVector;
extern HspVarProc* g_pHvpVector;

// 関数
extern void HspVarVector_Init( HspVarProc* p );
extern int SetReffuncResult( PDAT** ppResult, vector_t const& self );
extern int SetReffuncResult( PDAT** ppResult, vector_t&& self );

extern PDAT* Vector_indexRhs( vector_t self, int* mptype );

#endif
