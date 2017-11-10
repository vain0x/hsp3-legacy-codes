#ifndef IG_CLASS_FUNCTION_CALLER_H
#define IG_CLASS_FUNCTION_CALLER_H

// 関数の呼び出しを行うためのオブジェクト

#include "hsp3plugin_custom.h"
#include "Functor.h"
#include "CPrmStk.h"
#include "ManagedPVal.h"

#include "mod_makepval.h"

class Invoker
{
	// 転送先
	functor_t functor_;

	// 実引数データ
	arguments_t args_;

public:
	// @prm f: must be non-null
	Invoker(functor_t const& f)
		: functor_ { (assert(!!f), f) }
		, args_(arguments_t::make(f->getPrmInfo()))
	{ }

	void invoke();

	functor_t const& getFunctor() const { return functor_; }

	// 引数
	CPrmInfo const& getPrms() const { return getArgs()->getPrmInfo(); }
	arguments_t const& getArgs() const { assert(!!args_); return args_; }

	arguments_t& getArgs() { return const_cast<arguments_t&>(static_cast<Invoker const*>(this)->getArgs()); }
};

class Caller
	: public Invoker
{
	using ManagedPVal = hpimod::ManagedPVal;

private:
	// 返値データ
	ManagedPVal result_;

public:
	// 構築
	Caller(functor_t const& f)
		: Invoker(f)
		, result_ { nullptr }
	{ }

public:
	void invoke();

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
	void moveResult(Caller& src)
	{
		// Remark: src.result_ maybe null.
		result_ = src.result_; src.result_.nullify();
		return;
	}

	// コードの取り出し
	void code_get_arguments();
private:
	bool code_get_nextArgument();

public:
	// 最後の返値
	static ManagedPVal lastResult;
	static PVal* getLastResult() { return lastResult.valuePtr(); }
	static void clearLastResult() { lastResult.nullify(); }

protected:
	// 呼び出しスタック
	static void push(Caller&);
	static void pop();
public:
	static Caller& top();
};

// todo: 仕様がふにゃふにゃ
class ArgBinder
	: public Invoker
{
	friend class CBound;

public:
	ArgBinder(functor_t const& f)
		: Invoker(f)
	{ }

	//void invoke();

	// コードの取り出し
	void code_get_arguments();
private:
	bool code_get_nextArgument();
	vector_t code_get_flex();
};

extern PVal* callLabelWithPrmStk(hpimod::label_t lb, void* prmstk);

#endif
