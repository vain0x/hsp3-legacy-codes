// assoc - Command header

#ifndef IG_ASSOC_COMMAND_H
#define IG_ASSOC_COMMAND_H

#include "vt_assoc.h"

extern void AssocTerm();

extern int SetReffuncResult( PDAT** ppResult, assoc_t const& pAssoc );

// 命令
extern int AssocMake(PDAT** ppResult);
extern int AssocDupShallow(PDAT** ppResult);
extern int AssocDupDeep(PDAT** ppResult);

extern void AssocClear();
extern void AssocChain();
extern void AssocCopy();

extern void AssocImport();
extern void AssocInsert();
extern void AssocRemove();

extern void AssocDim();
extern void AssocClone();
extern int AssocVarinfo(PDAT** ppResult);

// 関数
extern int AssocSize(PDAT** ppResult);
extern int AssocExists(PDAT** ppResult);
extern int AssocIsNull(PDAT** ppResult);
extern int AssocForeachNext(PDAT** ppResult);

extern int AssocResult( PDAT** ppResult );
extern int AssocExpr( PDAT** ppResult );

// システム変数

// 定数

#endif
