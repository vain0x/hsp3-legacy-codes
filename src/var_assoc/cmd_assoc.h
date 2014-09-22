// assoc - Command header

#ifndef IG_ASSOC_COMMAND_H
#define IG_ASSOC_COMMAND_H

#include "vt_assoc.h"

extern void AssocTerm();

extern int SetReffuncResult( PDAT** ppResult, CAssoc* const& pAssoc );

// 命令
extern void AssocNew();		// 構築
extern void AssocDelete();	// 破棄
extern void AssocClear();	// 消去
extern void AssocChain();	// 連結
extern void AssocCopy();	// 複写

extern void AssocImport();	// 外部変数のインポート
extern void AssocInsert();	// キーを挿入する
extern void AssocRemove();	// キーを除去する

extern void AssocDim();		// 内部変数を配列にする
extern void AssocClone();	// 内部変数のクローンを作る

// 関数
extern int AssocNewTemp(PDAT** ppResult);
extern int AssocNewTempDup(PDAT** ppResult);

extern int AssocVarinfo(PDAT** ppResult);
extern int AssocSize(PDAT** ppResult);
extern int AssocExists(PDAT** ppResult);
extern int AssocIsNull(PDAT** ppResult);
extern int AssocForeachNext(PDAT** ppResult);

extern int AssocResult( PDAT** ppResult );	// assoc 返却
extern int AssocExpr( PDAT** ppResult );	// assoc 式

// システム変数

// 定数
enum VARINFO {
	VARINFO_NONE = 0,
	VARINFO_FLAG = VARINFO_NONE,
	VARINFO_MODE,
	VARINFO_LEN,
	VARINFO_SIZE,
	VARINFO_PT,
	VARINFO_MASTER,
	VARINFO_MAX
};

#endif
