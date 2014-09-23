#ifndef IG_CLASS_FUNCTION_CALLER_H
#define IG_CLASS_FUNCTION_CALLER_H

// 関数の呼び出しを行うためのオブジェクト

#include "hsp3plugin_custom.h"
#include "Functor.h"
#include "CPrmStk.h"
#include "ManagedPVal.h"

#include "mod_makepval.h"

enum class InvokeMode : unsigned char
{
	Call = 0,
	Bind,
};

class Invoker
{
	using ManagedPVal = hpimod::ManagedPVal;

private:
	// 転送先
	functor_t functor_;

	// 実引数データ
	arguments_t args_;

	InvokeMode invmode_;

	// 返値データ
	ManagedPVal result_;

	// 最後の返値
	static ManagedPVal lastResult;

public:
	// 構築
	// @prm f: must be non-null
	Invoker(functor_t f, InvokeMode invmode_ = InvokeMode::Call)
		: functor_ { (assert(!f.isNull()), f) }
		, args_ { f->getPrmInfo() }
		, invmode_ { invmode_ }
		, result_ { nullptr }
	{ }

//	Invoker(Invoker const&) = delete;

public:
	void invoke();

	functor_t const& getFunctor() const { return functor_; }
	CPrmInfo const& getPrmInfo() const { return args_.getPrmInfo(); }

	// 実引数
	arguments_t& getArgs() { return args_; }
	arguments_t const& getArgs() const { return args_; }

	// 返値
	bool hasResult() const { return !result_.isNull(); }
	PVal* getResult() const {
		if ( !hasResult() ) puterror(HSPERR_NORETVAL);
		return result_.valuePtr();
	}
	void setResultByRef(PVal* pval)
	{
		result_ = ManagedPVal::ofValptr(pval);
		return;
	}
	void setResultByVal(PDAT const* pdat, hpimod::vartype_t vtype)
	{
		result_.reset();
		hpimod::PVal_assign(result_.valuePtr(), pdat, vtype);
		return;
	}

	// コードの取り出し
	void code_get_arguments();

private:
	bool code_get_nextArgument();

	// 呼び出しスタック
	static void push(Invoker&);
	static void pop();
public:
	static Invoker& top();

	// 返値
	static PVal* getLastResult() { return lastResult.valuePtr(); }
	static void clearLastResult() { lastResult.nullify(); }
};

#endif
