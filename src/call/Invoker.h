#ifndef IG_CLASS_FUNCTION_CALLER_H
#define IG_CLASS_FUNCTION_CALLER_H

// 関数呼び出しのオブジェクト
// 引数から直接 prmstack の生成を行う。
// CCaller, CCall の代わりにするつもり。

// CStreamCaller に似ているが、呼び出し時に追加の引数を与えられない。

// というつもりで作ったが、肝は CPrmStk (実引数データ) を所有し、コードから実引数を取り出す機能を持つことである。
// argument 型オブジェクトということにした方が収まりがいい気がする。

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
private:
	// 転送先
	functor_t functor_;

	// 実引数データ
	arguments_t args_;

	InvokeMode invmode_;

	// 返値データ
	ManagedPVal result_;

	static ManagedPVal lastResult;

public:
	// 構築
	// @prm f: must be non-null
	Invoker(functor_t f, InvokeMode invmode_ = InvokeMode::Call)
		: functor_ { f }
		, args_ { f->getPrmInfo() }
		, invmode_ { invmode_ }
		, result_ { nullptr }
	{ }

//	Invoker(Invoker const&) = delete;

public:
	void invoke() { push(*this); functor_->invoke(*this); pop(); }

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
	PVal* setResult(PVal* pval)
	{
		result_ = ManagedPVal::ofValptr(pval);
		return getResult();
	}
	PVal* setResult(PDAT const* pdat, vartype_t vtype)
	{
		result_.reset();
		PVal_assign(result_.valuePtr(), pdat, vtype);
		return getResult();
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
