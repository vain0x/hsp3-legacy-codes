// vector - Command header

#ifndef IG_VECTOR_COMMAND_H
#define IG_VECTOR_COMMAND_H

#include "hsp3plugin_custom.h"
using namespace hpimod;

#include "vt_vector.h"

extern vector_t code_get_vector();

// コマンド用関数のプロトタイプ宣言
extern void VectorDelete();				// 破棄

extern int VectorMake( PDAT** ppResult );			// as literal
extern int VectorSlice( PDAT** ppResult );
extern int VectorSliceOut( PDAT** ppResult );
extern int VectorDup( PDAT** ppResult );

extern int VectorIsNull( PDAT** ppResult );
extern int VectorVarinfo( PDAT** ppResult );
extern int VectorSize( PDAT** ppResult );

extern void VectorDimtype();
extern void VectorClone();

extern void VectorChain(bool bClear);	// 連結 (or 複写)
#if 0
extern void VectorMoving( int cmd );	// 要素順序操作系
extern int  VectorMovingFunc( PDAT** ppResult, int cmd );

extern void VectorInsert();				// 要素追加
extern void VectorInsert1();
extern void VectorPushFront();
extern void VectorPushBack();
extern void VectorRemove();				// 要素削除
extern void VectorRemove1();
extern void VectorPopFront();
extern void VectorPopBack();
extern void VectorReplace();
extern int VectorInsert( PDAT** ppResult ) ;
extern int VectorInsert1( PDAT** ppResult ) ;
extern int VectorPushFront( PDAT** ppResult );
extern int VectorPushBack( PDAT** ppResult );
extern int VectorRemove( PDAT** ppResult );
extern int VectorRemove1( PDAT** ppResult );
extern int VectorPopFront( PDAT** ppResult );
extern int VectorPopBack( PDAT** ppResult );
extern int VectorReplace( PDAT** ppResult );
#endif

extern int VectorResult( PDAT** ppResult );
extern int VectorExpr( PDAT** ppResult );
extern int VectorJoin( PDAT** ppResult );
extern int VectorAt( PDAT** ppResult );

// 終了時
extern void VectorCmdTerminate();

// システム変数

// 定数
namespace VectorCmdId {
	int const
		Move    = 0x20,
		Swap    = 0x21,
		Rotate  = 0x22,
		Reverse = 0x23;
};

#endif
