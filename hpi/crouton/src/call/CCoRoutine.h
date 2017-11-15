// コルーチンクラス

#ifndef IG_CLASS_COROUTINE_H
#define IG_CLASS_COROUTINE_H

#include <memory>
#include <vector>

#include "hsp3plugin_custom.h"
#include "IFunctor.h"
#include "Functor.h"
#include "Invoker.h"
#include "AxCmd.h"

class CCoRoutine
	: public IFunctor
{
private:
	// 元のファンクタ
	std::unique_ptr<Caller> callerFirst_;

	// 再開用
	hpimod::label_t resumeLabel_;
	arguments_t resumeArgs_;

	// yield から受け取る再開用情報
	static arguments_t stt_args;
	static PVal const* stt_pvalResume;

public:
	CCoRoutine(functor_t f);

	Caller* getCallerFirst() { return callerFirst_.get(); }

	// 継承
	CPrmInfo const& getPrmInfo() const override { return CPrmInfo::noprmFunc; }
	hpimod::label_t getLabel() const override {
		return (callerFirst_
			? callerFirst_->getFunctor()->getLabel()
			: resumeLabel_);
	}
	int getAxCmd() const override {
		return (callerFirst_
			? callerFirst_->getFunctor()->getAxCmd()
			: AxCmd::make(TYPE_LABEL, hpimod::getOTPtr(resumeLabel_)));
	}
	int getUsing() const override {
		return (callerFirst_
			? callerFirst_->getFunctor()->getUsing()
			: hpimod::HspBool(!!resumeLabel_));
	}

	// 動作
	void call(Caller& callerGiven) override;

	static void onYield( PVal const* pval, arguments_t args )
	{
		// coYield_ 実行時にコルーチンを参照する方法はないので、static field に入れておく。
		// この直後に起こる call() の返しでこれらを回収する。

		stt_pvalResume = pval;
		stt_args = std::move(args);
	}
};

#endif
