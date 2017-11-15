// vector - Command header

#ifndef IG_VECTOR_COMMAND_H
#define IG_VECTOR_COMMAND_H

#include "hsp3plugin_custom.h"

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

extern void VectorContainerProc( int cmd );	// コンテナ操作系
extern int  VectorContainerProcFunc( PDAT** ppResult, int cmd );

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
		Insert    = 0x20,
		InsertOne = 0x21,
		PushFront = 0x22,
		PushBack  = 0x23,
		Remove    = 0x24,
		RemoveOne = 0x25,
		PopFront  = 0x26,
		PopBack   = 0x27,
		Replace   = 0x28,

		Swap      = 0x30,
		Rotate    = 0x31,
		Reverse   = 0x32,
		Relocate  = 0x33//,
	;
};

#endif
