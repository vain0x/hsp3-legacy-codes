// Call - SubCommand header

// todo: このファイルの機能をすべて適切な場所に移動する。

#ifndef IG_CALL_SUB_COMMAND_H
#define IG_CALL_SUB_COMMAND_H

#include "hsp3plugin_custom.h"
#include "CPrmInfo.h"

using namespace hpimod;

// 仮引数リスト関連
extern CPrmInfo const& DeclarePrmInfo(label_t lb, CPrmInfo&& prminfo);
extern CPrmInfo const& GetPrmInfo(stdat_t stdat);
extern CPrmInfo const& GetPrmInfo(label_t);

extern CPrmInfo::prmlist_t code_get_prmlist();
extern CPrmInfo const& code_get_prminfo();

#endif
