
#include <stack>
#include "mod_argGetter.h"

#include "iface_call.h"
#include "Invoker.h"

using namespace hpimod;

ManagedPVal Caller::lastResult { nullptr };

// nobind(N) に指定できる N の最大値
static int const NobindPriorityMax = std::numeric_limits<unsigned short>::max();

//------------------------------------------------
// my_code_getarg の返値
//
// type CodeGetArgResult =
//	| ByVal * ((PDAT*) * vartype_t)
//	| ByRef * (PVal*)
//	| ByThismod * (PVal*)
//	| ByFlex * (vector_t)
//	| Default
//	| End
//	| NoBind * int
//------------------------------------------------
struct CodeGetArgResult
{
	enum class Style : unsigned char {
		ByVal, ByRef, ByThismod, ByFlex,
		Default, End, NoBind,
	};
private:
	Style style_;
	union {
		struct { PDAT const* pdat_; vartype_t vtype_; };
		MPVarData vardata_;
		int priority_;
	};
public:
	static CodeGetArgResult byVal(PDAT const* pdat, vartype_t vtype) { return CodeGetArgResult(pdat, vtype); }
	static CodeGetArgResult byRef(PVal* pval) { return CodeGetArgResult(pval, pval->offset, Style::ByRef); }
	static CodeGetArgResult byThismod(PVal* pval) { return CodeGetArgResult(pval, pval->offset, Style::ByThismod); }
	static CodeGetArgResult noBind(int priority) { return CodeGetArgResult(priority); }
	static CodeGetArgResult const Default;
	static CodeGetArgResult const End;

	Style getStyle() const { return style_; }
	PDAT const* getValptr() const{ assert(getStyle() == Style::ByVal); return pdat_; }
	vartype_t getVartype() const { assert(getStyle() == Style::ByVal); return vtype_; }
	PVal* getPVal() const { assert(isByRefStyle()); return vardata_.pval; }
	APTR getAptr() const { assert(isByRefStyle()); return vardata_.aptr; }
	int getPriority() const { assert(style_ == Style::NoBind); return priority_; }

private:
	CodeGetArgResult(Style style) : style_ { style }
	{ }
	CodeGetArgResult(PVal* pval, APTR aptr, Style style) : style_ { style }, vardata_ ({ pval, aptr })
	{ assert(style == Style::ByRef || style == Style::ByThismod); }
	CodeGetArgResult(PDAT const* pdat, vartype_t vtype) : style_ { Style::ByVal }, pdat_ { pdat }, vtype_ { vtype }
	{ }
	CodeGetArgResult(int priority) : style_ { Style::NoBind }, priority_ { priority }
	{ }

	bool isByRefStyle() const { return (style_ == Style::ByRef || style_ == Style::ByThismod); }
};

CodeGetArgResult const CodeGetArgResult::Default { Style::Default };
CodeGetArgResult const CodeGetArgResult::End { Style::End };

//------------------------------------------------
// 次の値を取り出す (oode_getprm の call.hpi 版)
//------------------------------------------------
CodeGetArgResult my_code_getarg(int prmtype)
{
	switch ( code_get_procHeader() ) {
		case PARAM_END:
		case PARAM_ENDSPLIT: return CodeGetArgResult::End;
		case PARAM_DEFAULT:  return CodeGetArgResult::Default;
		default:
		{
			if ( *type == g_pluginType_call && *val == CallCmd::Id::noBind ) {
				// 不束縛引数 (noBind)

				code_next();
				int priority = NobindPriorityMax;
				
				if ( *type == TYPE_MARK && *val == '(' ) {
					// ( ) あり => 優先度数を取り出す
					code_next();
					priority = code_getdi(priority);
					if ( !(0 <= priority && priority <= NobindPriorityMax) ) puterror(HSPERR_ILLEGAL_FUNCTION);
					if ( !code_next_expect(TYPE_MARK, ')') ) puterror(HSPERR_TOO_MANY_PARAMETERS);
				}

				*exinfo->npexflg &= ~EXFLG_2;	// 引数取り出し後に必要な処理
				return CodeGetArgResult::noBind(priority);

			} else if ( *type == g_pluginType_call
				&& (*val == CallCmd::Id::call_byRef_ || *val == CallCmd::Id::call_byThismod_) ) {
				// 明示的参照渡し (byRef, byThismod)
				// 中間コードは [ keyword var || ] となっている。

				bool const bByRef = (*val == CallCmd::Id::call_byRef_);
				code_next();
				PVal* const pval = code_get_var();
				if ( !code_next_expect(TYPE_MARK, CALCCODE_OR) ) puterror(HSPERR_SYNTAX);

				return bByRef
					? CodeGetArgResult::byRef(pval)
					: CodeGetArgResult::byThismod(pval);

#if 0
			} else if ( *type == g_pluginType_call && *val == CallCmd::Id::call_byFlex_ ) {
				// 明示的可変長引数渡し (byFlex)
				// 中間コードは [ byFlex, flex-vector ] となっている。

				code_get_singleToken();

				vector_t&& vec = code_get_vector();
				return CodeGetArgResult::byFlex(vec);
#endif
			} else if ( *type == g_pluginType_call && *val == CallCmd::Id::byDef ) {
				// 明示的引数省略 (bydef)

				code_get_singleToken();
				return CodeGetArgResult::Default;

			} else if ( PrmType::isRef(prmtype) ) {
				switch ( prmtype ) {
					case PrmType::Array:  return CodeGetArgResult::byRef(code_getpval());
					case PrmType::Var:    return CodeGetArgResult::byRef(code_get_var());
					case PrmType::Modvar: return CodeGetArgResult::byThismod(code_get_var());
					default: assert(false);
				}
				puterror(HSPERR_VARIABLE_REQUIRED);

			} else {
				switch ( code_getprm() ) {
					case PARAM_OK:
					case PARAM_SPLIT:
					{
						if ( prmtype == HSPVAR_FLAG_DOUBLE && mpval->flag == HSPVAR_FLAG_INT ) {
							// int → double の暗黙変換を許可する
							return CodeGetArgResult::byVal(Valptr_cnvTo(mpval->pt, mpval->flag, prmtype), prmtype);
						} else {
							return CodeGetArgResult::byVal(mpval->pt, mpval->flag);
						}
					}
					case PARAM_END:
					case PARAM_ENDSPLIT: return CodeGetArgResult::End;
					case PARAM_DEFAULT:  return CodeGetArgResult::Default;
					default: assert(false); puterror(HSPERR_UNKNOWN_CODE);
				}
			}
		}
	}
}

//------------------------------------------------
// 引数列を vector のリテラルとして取り出す
//------------------------------------------------
vector_t code_get_vectorFromSequence()
{
	vector_t vec {};
	for (;;) {
		auto&& result = my_code_getarg(PrmType::Any);

		using Sty = CodeGetArgResult::Style;
		switch ( result.getStyle() ) {
			case Sty::End: return std::move(vec);
			case Sty::Default: break;

			case Sty::ByVal: vec->push_back(ManagedVarData(result.getValptr(), result.getVartype())); break;
			case Sty::ByRef: vec->push_back(ManagedVarData(result.getPVal(), result.getPVal()->offset)); break;
			case Sty::ByFlex: dbgout("未実装"); puterror(HSPERR_UNSUPPORTED_FUNCTION);

			case Sty::NoBind: //
			case Sty::ByThismod: puterror(HSPERR_UNSUPPORTED_FUNCTION);
			default: assert(false);
		}
		//assert(code_isNextArg());
	}
}

//******************************************************************************
//------------------------------------------------
// 呼び出し処理
//------------------------------------------------
void Caller::invoke()
{
	push(*this);
	getFunctor()->call(*this);
	pop();
	if ( hasResult() ) {
		lastResult = result_;
	}
	return;
}

//------------------------------------------------
// すべての引数を取り出す
//------------------------------------------------
void Caller::code_get_arguments()
{
	for ( size_t i = 0; i < getPrms().cntPrms(); ++i ) {
		if ( !code_get_nextArgument() ) break;
	}

	getArgs().finalize();

	// 残りを flex 引数として取り出す
	if ( code_isNextArg() ) {
		if ( vector_t* const vec = getArgs().peekFlex() ) {
			*vec = code_get_vectorFromSequence();
		} else {
			puterror(HSPERR_TOO_MANY_PARAMETERS);
		}
	}
	return;
}

//------------------------------------------------
// 次の実引数を取り出す
// 
// @result: 引数を取り出したか？
//------------------------------------------------
bool Caller::code_get_nextArgument()
{
	if ( !code_isNextArg() ) return false;

	auto&& result = my_code_getarg(getArgs().getNextPrmType());

	using Sty = CodeGetArgResult::Style;
	switch ( result.getStyle() ) {
		case Sty::Default:   getArgs().pushArgByDefault(); break;
		case Sty::ByVal:     getArgs().pushArgByVal(result.getValptr(), result.getVartype()); break;
		case Sty::ByRef:     getArgs().pushArgByRef(result.getPVal(), result.getPVal()->offset); break;
		case Sty::ByThismod: getArgs().pushThismod(result.getPVal(), result.getPVal()->offset); break;
		case Sty::ByFlex: dbgout("未実装"); puterror(HSPERR_UNSUPPORTED_FUNCTION); break;
		case Sty::NoBind: puterror(HSPERR_ILLEGAL_FUNCTION);
		case Sty::End: //
		default: assert(false);
	}
	return true;
}

//------------------------------------------------
// 呼び出しスタック
//------------------------------------------------
static std::stack<Caller*> stt_stkCaller;

void Caller::push(Caller& src)
{
	stt_stkCaller.push(&src);
	return;
}

void Caller::pop()
{
	assert(!stt_stkCaller.empty());
	stt_stkCaller.pop();
	return;
}

Caller& Caller::top()
{
	assert(!stt_stkCaller.empty());
	auto const pInv = stt_stkCaller.top();
	assert(pInv);
	return *pInv;
}

//******************************************************************************

//------------------------------------------------
// 起動
//------------------------------------------------
//void ArgBinder::invoke() { }

//------------------------------------------------
// すべての引数を取り出す
//------------------------------------------------
void ArgBinder::code_get_arguments()
{
	for ( size_t i = 0; i < getPrms().cntPrms(); ++i ) {
		if ( !code_get_nextArgument() ) break;
	}

	for ( size_t i = getArgs().cntArgs(); i < getPrms().cntPrms(); ++i ) {
		getArgs().allocArgNoBind(NobindPriorityMax);
	}

	getArgs().finalize();

	// 残りを flex 引数として取り出す
	if ( code_isNextArg() ) {
		if ( vector_t* const vec = getArgs().peekFlex() ) {
			*vec = code_get_vectorFromSequence();
		} else {
			puterror(HSPERR_TOO_MANY_PARAMETERS);
		}
	}
	return;
}

//------------------------------------------------
// 次の実引数を取り出す
// 
// @result: 引数を取り出したか？
//------------------------------------------------
bool ArgBinder::code_get_nextArgument()
{
	if ( !code_isNextArg() ) return false;

	auto&& result = my_code_getarg(getArgs().getNextPrmType());

	using Sty = CodeGetArgResult::Style;
	switch ( result.getStyle() ) {
		case Sty::Default:   getArgs().pushArgByDefault(); break;
		case Sty::ByVal:     getArgs().pushArgByVal(result.getValptr(), result.getVartype()); break;
		case Sty::ByRef:     getArgs().pushArgByRef(result.getPVal(), result.getPVal()->offset); break;
		case Sty::ByThismod: getArgs().pushThismod(result.getPVal(), result.getPVal()->offset); break;
		case Sty::ByFlex: dbgout("未実装"); puterror(HSPERR_UNSUPPORTED_FUNCTION); break;
		case Sty::NoBind:    getArgs().allocArgNoBind(result.getPriority()); break;
		case Sty::End: //
		default: assert(false);
	}
	return true;
}

//------------------------------------------------
// 
//------------------------------------------------
//------------------------------------------------
// 
//------------------------------------------------
