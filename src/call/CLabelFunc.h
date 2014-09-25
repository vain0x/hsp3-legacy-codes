﻿// ラベル関数

#ifndef IG_CLASS_LABEL_FUNC_H
#define IG_CLASS_LABEL_FUNC_H

#include "hsp3plugin_custom.h"

#include "axcmd.h"
#include "IFunctor.h"
#include "CPrmStk.h"
#include "Invoker.h"

#include "cmd_sub.h"

class CLabelFunc
	: public IFunctor
{
	using label_t = hpimod::label_t;

	label_t lb_;

public:
	CLabelFunc(label_t lb) : lb_ { lb } {}

	// 取得
	label_t getLabel() const override { return lb_; }
	int getAxCmd() const override { return AxCmd::make(TYPE_LABEL, hpimod::getOTPtr(lb_)); }

	int getUsing() const override { return hpimod::HspBool(lb_ != nullptr); }			// 使用状況 (0: 無効, 1: 有効, 2: クローン)
	CPrmInfo const& getPrmInfo() const override {
		return GetPrmInfo(lb_);
	}

	// 動作
	void call(Caller& caller) override
	{
		auto const prmstk_bak = ctx->prmstack;
		auto const prmstk = const_cast<void*>(caller.getArgs().getPrmStkPtr());
		ctx->prmstack = prmstk;

		code_call(getLabel());

		// return から返値を受け取る (やや黒魔術？)
		if ( ctx->retval_level == (ctx->sublev + 1) ) {
			caller.setResultByVal((*exinfo->mpval)->pt, (*exinfo->mpval)->flag);
			ctx->retval_level = 0;
		}

		assert(ctx->prmstack == prmstk);
		ctx->prmstack = prmstk_bak;
		return;
	}
};

#endif
