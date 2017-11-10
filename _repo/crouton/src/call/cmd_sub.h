// Call - SubCommand header

// todo: このファイルの機能をすべて適切な場所に移動する。

#ifndef IG_CALL_SUB_COMMAND_H
#define IG_CALL_SUB_COMMAND_H

#include "hsp3plugin_custom.h"
#include "CPrmInfo.h"

// 仮引数リスト関連
extern CPrmInfo const& DeclarePrmInfo(hpimod::label_t lb, CPrmInfo&& prminfo);
extern CPrmInfo const& GetPrmInfo(hpimod::stdat_t stdat);
extern CPrmInfo const& GetPrmInfo(hpimod::label_t);

extern CPrmInfo::prmlist_t code_get_prmlist();
extern CPrmInfo const& code_get_prminfo();

#endif
