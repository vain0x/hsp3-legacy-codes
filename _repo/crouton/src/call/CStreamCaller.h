// ストリーム呼び出しオブジェクト

#ifndef IG_CLASS_STREAM_CALLER_H
#define IG_CLASS_STREAM_CALLER_H

// 「呼び出しの途中」を保存するオブジェクト

#include "hsp3plugin_custom.h"
#include "Invoker.h"
#include "Functor.h"

class CStreamCaller
	: public IFunctor
{
private:
	std::unique_ptr<Caller> caller_;

public:
	CStreamCaller(functor_t f);

	hpimod::label_t getLabel() const override;
	int getAxCmd() const override;
	int getUsing() const override;
	CPrmInfo const& getPrmInfo() const override { return CPrmInfo::noprmFunc; };

	void call( Caller& callerGiven );

	Caller& getCaller() { return *caller_; }
};

#endif
