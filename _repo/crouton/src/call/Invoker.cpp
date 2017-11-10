
#include <stack>
#include "mod_argGetter.h"

#include "iface_call.h"
#include "Invoker.h"
#include "Argument.h"

#include "../var_vector/cmd_vector.h"

using namespace hpimod;

ManagedPVal Caller::lastResult { nullptr };

ArgData const ArgData::Default { Style::Default };
ArgData const ArgData::End { Style::End };

//------------------------------------------------
// 次の値を取り出す (oode_getprm の call.hpi 版)
//------------------------------------------------
static ArgData my_code_getarg(prmtype_t prmtype)
{
	switch ( code_get_procHeader() ) {
		case PARAM_END:
		case PARAM_ENDSPLIT: return ArgData::End;
		case PARAM_DEFAULT:  return ArgData::Default;
		default:
		{
			if ( *type == g_pluginType_call ) {
				switch ( *val ) {
					case CallCmd::Id::noBind:
					{
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
						return ArgData::noBind(priority);
					}
					case CallCmd::Id::call_byRef_:
					case CallCmd::Id::call_byThismod_:
					{
						// 明示的参照渡し (byRef, byThismod)
						// 中間コードは [ keyword, var ] となっている。

						bool const bByRef = (*val == CallCmd::Id::call_byRef_);
						code_get_singleToken();

						PVal* const pval = code_get_var();
						return bByRef
							? ArgData::byRef(pval)
							: ArgData::byThismod(pval);
					}
#if 0
					case CallCmd::Id::call_byFlex_:
					{
						// 明示的可変長引数渡し (byFlex)
						// 中間コードは [ byFlex, flex-vector ] となっている。

						code_get_singleToken();

						vector_t&& vec = code_get_vector();
						return ArgData::byFlex(vec);
					}
#endif
					case CallCmd::Id::byDef:
					{
						// 明示的引数省略 (bydef)

						code_get_singleToken();
						return ArgData::Default;
					}
					default: break;
				}
			}

			if ( PrmType::isRef(prmtype) ) {
				switch ( prmtype ) {
					case PrmType::Array:  return ArgData::byRef(code_getpval());
					case PrmType::Var:    return ArgData::byRef(code_get_var());
					case PrmType::Modvar: return ArgData::byThismod(code_get_var());
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
							return ArgData::byVal(Valptr_cnvTo(mpval->pt, mpval->flag, prmtype), prmtype);
						} else {
							return ArgData::byVal(mpval->pt, mpval->flag);
						}
					}
					case PARAM_END:
					case PARAM_ENDSPLIT: return ArgData::End;
					case PARAM_DEFAULT:  return ArgData::Default;
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

		switch ( result.getStyle() ) {
			using Sty = ArgData::Style;
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

	getArgs()->finalize();

	// 残りを flex 引数として取り出す
	if ( code_isNextArg() ) {
		if ( vector_t* const vec = getArgs()->peekFlex() ) {
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

	auto&& result = my_code_getarg(getArgs()->getNextPrmType());

	switch ( result.getStyle() ) {
		using Sty = ArgData::Style;
		case Sty::Default:   getArgs()->pushArgByDefault(); break;
		case Sty::ByVal:     getArgs()->pushArgByVal(result.getValptr(), result.getVartype()); break;
		case Sty::ByRef:     getArgs()->pushArgByRef(result.getPVal(), result.getPVal()->offset); break;
		case Sty::ByThismod: getArgs()->pushThismod(result.getPVal(), result.getPVal()->offset); break;
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

	for ( size_t i = getArgs()->cntArgs(); i < getPrms().cntPrms(); ++i ) {
		getArgs()->allocArgNoBind(NobindPriorityMax);
	}

	getArgs()->finalize();

	// 残りを flex 引数として取り出す
	if ( code_isNextArg() ) {
		if ( vector_t* const vec = getArgs()->peekFlex() ) {
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

	auto&& result = my_code_getarg(getArgs()->getNextPrmType());

	switch ( result.getStyle() ) {
		using Sty = ArgData::Style;
		case Sty::Default:   getArgs()->pushArgByDefault(); break;
		case Sty::ByVal:     getArgs()->pushArgByVal(result.getValptr(), result.getVartype()); break;
		case Sty::ByRef:     getArgs()->pushArgByRef(result.getPVal(), result.getPVal()->offset); break;
		case Sty::ByThismod: getArgs()->pushThismod(result.getPVal(), result.getPVal()->offset); break;
		case Sty::ByFlex: dbgout("未実装"); puterror(HSPERR_UNSUPPORTED_FUNCTION); break;
		case Sty::NoBind:    getArgs()->allocArgNoBind(result.getPriority()); break;
		case Sty::End: //
		default: assert(false);
	}
	return true;
}

//******************************************************************************

//------------------------------------------------
// ラベル呼び出しの実体
//------------------------------------------------
PVal* callLabelWithPrmStk(label_t lb, void* prmstk)
{
	auto const prmstk_bak = ctx->prmstack;
	ctx->prmstack = prmstk;

	code_call(lb);

	assert(ctx->prmstack == prmstk);
	ctx->prmstack = prmstk_bak;

	// return から返値を受け取る (やや黒魔術？)
	if ( ctx->retval_level == (ctx->sublev + 1) ) {
		ctx->retval_level = 0;
		return *exinfo->mpval;
	} else {
		return nullptr;
	}
}
