// call - command.cpp

#include <stack>
#include <set>

#include "hsp3plugin_custom.h"
#include "reffuncResult.h"
#include "mod_argGetter.h"
#include "mod_varutil.h"
#include "axcmd.h"

#include "Functor.h"
#include "Invoker.h"

#include "CBound.h"
#include "CStreamCaller.h"
#include "CLambda.h"
#include "CCoRoutine.h"

#include "cmd_call.h"
#include "cmd_sub.h"

#include "vt_functor.h"

using namespace hpimod;

//------------------------------------------------
// ラベル命令・関数の呼び出し
//------------------------------------------------
int CallCmd::call( PDAT** ppResult )
{
	auto&& f = code_get_functor();

	Caller caller { std::move(f) };
	caller.code_get_arguments();
	//dbgout("%d", caller.getArgs().cntArgs());
	caller.invoke();

	if ( ppResult ) {
		PVal* const pval = caller.getResult();
		*ppResult = pval->pt;
		return pval->flag;
	} else {
		return HSPVAR_FLAG_NONE;
	}
}

//------------------------------------------------
// ラベル命令・関数の仮引数宣言
//------------------------------------------------
static label_t declareImpl()
{
	label_t const lb = code_getlb();
	if ( !lb ) puterror( HSPERR_ILLEGAL_FUNCTION );

	CPrmInfo::prmlist_t&& prmlist = code_get_prmlist();		// 仮引数列

	// 登録
	DeclarePrmInfo( lb, CPrmInfo(std::move(prmlist)) );
	return lb;
}

int CallCmd::declare(PDAT** ppResult)
{
	if ( ppResult ) {
		puterror(HSPERR_UNSUPPORTED_FUNCTION);
		//return SetReffuncResult(ppResult, Functor::New(declareImpl()));
	} else {
		declareImpl();
		return HSPVAR_FLAG_NONE;
	}
}

//------------------------------------------------
// ラベル関数の返値を設定する
//------------------------------------------------
void CallCmd::call_setResult_()
{
	auto& caller = Caller::top();
	if ( code_getprm() <= PARAM_END ) puterror(HSPERR_NO_DEFAULT);

	caller.setResultByVal(mpval->pt, mpval->flag);
	return;
}

//------------------------------------------------
// ラベル関数の返値となった値を取り出す
// 
// @ call 終了後にだけ呼び出される。
//------------------------------------------------
int CallCmd::call_getResult_(PDAT** ppResult)
{
	PVal* const pvResult = Caller::getLastResult();
	if ( pvResult ) {
		*ppResult = pvResult->pt;
		return pvResult->flag;

	} else {
		puterror(HSPERR_NORETVAL);
	}
}

//##########################################################
//        引数情報取得
//##########################################################
//------------------------------------------------
// arginfo
//------------------------------------------------
static int getArgInfo(Caller const& caller, int id, size_t idxArg)
{
	auto const prmtype = caller.getPrms().getPrmType(idxArg);

	switch ( id ) {
		case ArgInfoId::IsVal:
			if ( PrmType::isVartype(prmtype) ) {
				return HspTrue;

			} else if ( prmtype == PrmType::Any ) {
				return HspBool( ManagedPVal::isManagedValue(caller.getArgs()->peekRefArgAt(idxArg)) );
			} else {
				return HspFalse;
			}
		case ArgInfoId::IsRef:
			if ( PrmType::isRef(prmtype) ) {
				return HspTrue;

			} else if ( prmtype == PrmType::Any ) {
				return HspBool(getArgInfo(caller, ArgInfoId::IsVal, idxArg) == HspFalse);

			} else {
				return HspFalse;
			}
		case ArgInfoId::IsMod:
			return prmtype == PrmType::Modvar;

		default: puterror(HSPERR_ILLEGAL_FUNCTION);
	}
}

//------------------------------------------------
// 呼び出し引数情報を取得する関数
//------------------------------------------------
int CallCmd::arginfo(PDAT** ppResult)
{
	auto& caller = Caller::top();

	auto const id = code_geti();	// データの種類
	int const idxArg = code_geti();
	if ( !(0 <= idxArg && static_cast<size_t>(idxArg) < caller.getArgs()->cntArgs()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	return SetReffuncResult( ppResult, getArgInfo(caller, id, idxArg) );
}

//------------------------------------------------
// 引数の値を取得する
//
// @ 参照渡し引数の値は取り出せない。
//------------------------------------------------
int CallCmd::argVal(PDAT** ppResult)
{
	auto& caller = Caller::top();
	auto& args = caller.getArgs();

	int const idxArg = code_geti();
	if ( !(0 <= idxArg && static_cast<size_t>(idxArg) < args->cntArgs()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	// 返値を設定する
	vartype_t vtype;
	*ppResult = args->peekValArgAt(idxArg, vtype);
	return vtype;
}

//------------------------------------------------
// 参照引数のクローンを作る
//------------------------------------------------
void CallCmd::argClone()
{
	auto& caller = Caller::top();
	auto& args = caller.getArgs();

	PVal* const pval = code_getpval();
	int const idxArg = code_geti();
	if ( !(0 <= idxArg && static_cast<size_t>(idxArg) < args->cntArgs()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	PVal* const pvalSrc = args->peekRefArgAt(idxArg);
	PVal_clone(pval, pvalSrc, pvalSrc->offset);
	return;
}

//------------------------------------------------
// 実引数を変数で受け取る
//------------------------------------------------
void CallCmd::argPeekAll()
{
	auto& caller = Caller::top();
	auto& args = caller.getArgs();

	for ( size_t i = 0
		; code_isNextArg() && (i < args->cntArgs())
		; ++i
		) {
		try {
			PVal* const pval = code_getpval();

			bool const bByRef = (getArgInfo(caller, ArgInfoId::IsRef, i) != HspFalse);
			if ( bByRef ) {
				PVal* const pvalSrc = args->peekRefArgAt(i);
				PVal_clone(pval, pvalSrc, pvalSrc->offset);
			} else {
				vartype_t vtype;
				PDAT const* pdat = args->peekValArgAt(i, vtype);
				PVal_assign(pval, pdat, vtype);
			}
		} catch ( HSPERROR e ) {
			if ( e == HSPERR_VARIABLE_REQUIRED ) continue;
			puterror(e);
		}
	}
	return;
}

//------------------------------------------------
// local 変数の値を取得する
//
// @ 最初のローカル変数を 0 とする。
//------------------------------------------------
int CallCmd::localVal( PDAT** ppResult )
{
	auto& caller = Caller::top();

	int const idxLocal = code_geti();
	if ( !(0 <= idxLocal && static_cast<size_t>(idxLocal) < caller.getPrms().cntLocals()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	PVal* const pvLocal = caller.getArgs()->peekLocalAt(idxLocal);
	if ( !pvLocal ) puterror( HSPERR_ILLEGAL_FUNCTION );

	*ppResult = pvLocal->pt;
	return pvLocal->flag;
}

void CallCmd::localClone()
{
	PVal* const pval = code_getpval();

	auto& caller = Caller::top();
	int const idxLocal = code_geti();
	if ( !(0 <= idxLocal && static_cast<size_t>(idxLocal) < caller.getPrms().cntLocals()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	PVal* const pvLocal = caller.getArgs()->peekLocalAt(idxLocal);
	if ( !pvLocal ) puterror( HSPERR_ILLEGAL_FUNCTION );

	PVal_clone(pval, pvLocal);
	return;
}

int CallCmd::localVector(PDAT** ppResult)
{
	auto& caller = Caller::top();

	vector_t vec {};
	for ( size_t i = 0; i < caller.getPrms().cntLocals(); ++i ) {
		vec->push_back({ caller.getArgs()->peekLocalAt(i), 0 });
	}
	return SetReffuncResult(ppResult, std::move(vec));
}

//------------------------------------------------
// 可変長引数の値
//------------------------------------------------
int CallCmd::flexVal(PDAT** ppResult)
{
	auto& caller = Caller::top();

	if ( auto pFlex = caller.getArgs()->peekFlex() ) {
		auto& flex = *pFlex;

		int const idxFlex = code_geti();
		if ( !(0 <= idxFlex && static_cast<size_t>(idxFlex) < flex->size()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

		PVal* const pval = flex->at(idxFlex).getVar();
		*ppResult = pval->pt;
		return pval->flag;
	} else {
		puterror(HSPERR_ILLEGAL_FUNCTION);
	}
}

//------------------------------------------------
// 可変長引数のクローン
//------------------------------------------------
void CallCmd::flexClone()
{
	auto& caller = Caller::top();

	if ( auto pFlex = caller.getArgs()->peekFlex() ) {
		auto& flex = *pFlex;

		int const idxFlex = code_geti();
		if ( !(0 <= idxFlex && static_cast<size_t>(idxFlex) < flex->size()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

		PVal* const pvalDst = code_getpval();
		PVal* const pvalSrc = flex->at(idxFlex).getVar();
		PVal_clone(pvalDst, pvalSrc, pvalSrc->offset);
		return;

	} else {
		puterror(HSPERR_ILLEGAL_FUNCTION);
	}
}

//------------------------------------------------
// 可変長引数の vector
//------------------------------------------------
int CallCmd::flexVector(PDAT** ppResult)
{
	auto& caller = Caller::top();
	if ( auto pFlex = caller.getArgs()->peekFlex() ) {
		return SetReffuncResult(ppResult, *pFlex);

	} else {
		puterror(HSPERR_ILLEGAL_FUNCTION);
	}
}

//------------------------------------------------
// 呼び出されたラベル
//------------------------------------------------
int CallCmd::thislb(PDAT** ppResult)
{
	return SetReffuncResult( ppResult, Caller::top().getFunctor()->getLabel() );
}

int CallCmd::thisfunc(PDAT** ppResult)
{
	puterror(HSPERR_UNSUPPORTED_FUNCTION);
	//return SetReffuncResult( ppResult, Caller::top().getFunctor() );
}

#if 0
//##########################################################
//        引数ストリーム呼び出し
//##########################################################
static std::stack<CCaller*> g_stkStream;

//------------------------------------------------
// 引数ストリーム呼び出し::開始
//------------------------------------------------
void CallCmd::streamBegin()
{
	// 呼び出し前の処理
	g_stkStream.push( new CCaller() );
	CCaller* const pCaller = g_stkStream.top();

	// ラベルの設定
	if ( code_isNextArg() ) {
		CallCmd::streamLabel();
	}
	return;
}


//------------------------------------------------
// 引数ストリーム呼び出し::ラベル設定
//------------------------------------------------
void CallCmd::streamLabel()
{
	if ( g_stkStream.empty() ) puterror( HSPERR_NO_DEFAULT );

	CCaller* const pCaller = g_stkStream.top();

	// ジャンプ先の決定
	pCaller->setFunctor();
	return;
}


//------------------------------------------------
// 引数ストリーム呼び出し::追加
//------------------------------------------------
void CallCmd::streamAdd()
{
	if ( g_stkStream.empty() ) puterror( HSPERR_NO_DEFAULT );

	CCaller* const pCaller = g_stkStream.top();

	// 引数を追加する
	pCaller->setArgAll();

	return;
}


//------------------------------------------------
// 引数ストリーム呼び出し::完了
// 
// @ 命令形式の場合は ppResult == nullptr 。
//------------------------------------------------
int CallCmd::streamEnd(PDAT** ppResult)
{
	if ( g_stkStream.empty() ) puterror( HSPERR_NO_DEFAULT );

	CCaller* const pCaller = g_stkStream.top();

	// 呼び出し
	pCaller->call();

	// 後処理
	g_stkStream.pop();

	vartype_t const restype = pCaller->getCallResult( ppResult );

	delete pCaller;
	return restype;
}

#endif

//------------------------------------------------
// ストリーム呼び出しオブジェクトの生成
//------------------------------------------------
int FunctorCmd::streamCallerNew( PDAT** ppResult )
{
	auto&& f = code_get_functor();

	if ( !!f || f->getUsing() ) puterror(HSPERR_ILLEGAL_FUNCTION);
	auto result = functor_t::makeDerived<CStreamCaller>( std::move(f) );

	return SetReffuncResult( ppResult, std::move(result) );
}

//------------------------------------------------
// ストリーム呼び出しオブジェクトへの引数追加
//------------------------------------------------
void FunctorCmd::streamCallerAdd()
{
	functor_t&& functor = code_get_functor();

	auto* const stream = (functor ? functor->safeCastTo<CStreamCaller>() : nullptr);
	if ( !stream ) puterror(HSPERR_ILLEGAL_FUNCTION);

	stream->getCaller().code_get_arguments();
	return;
}

//##########################################################
//    functor 型関係
//##########################################################
//------------------------------------------------
// functor
//------------------------------------------------
int FunctorCmd::functor(PDAT** ppResult, bool bSysvar)
{
	if ( ppResult && bSysvar ) {
		// 型タイプ値
		
		return SetReffuncResult(ppResult, static_cast<int>(g_vtFunctor));

	} else if ( ppResult && !bSysvar ) {
		// 型変換

		int const chk = code_getprm();
		if ( chk <= PARAM_END ) puterror(HSPERR_NO_DEFAULT);

		*ppResult = g_hvpFunctor->Cnv(mpval->pt, mpval->flag);
		assert(*ppResult == VtTraits::asPDAT<vtFunctor>(&g_resFunctor));
		return g_vtFunctor;

	} else {
		// 変数初期化
		
		code_dimtypeEx(g_vtFunctor);
		return HSPVAR_FLAG_NONE;
	}
}

//------------------------------------------------
// 仮引数情報
//------------------------------------------------
namespace PrmInfoId
{
	static int const
		PrmTypeOf = 0,

		CntPrms = 2,	// ここから仮引数リスト全体に関する情報
		CntLocals = 3,
		IsFlex = 4
	;
}

static int getPrmInfo(CPrmInfo const& prminfo, int id, int idxPrm)
{
	if ( id >= PrmInfoId::CntPrms
		&& !(0 <= idxPrm && static_cast<size_t>(idxPrm) < prminfo.cntPrms()) ) puterror(HSPERR_ILLEGAL_FUNCTION);
	switch ( id ) {
		case PrmInfoId::PrmTypeOf:  return prminfo.getPrmType(idxPrm);
		case PrmInfoId::CntPrms:    return static_cast<int>( prminfo.cntPrms() );
		case PrmInfoId::CntLocals:  return static_cast<int>( prminfo.cntLocals() );
		case PrmInfoId::IsFlex:     return HspBool(prminfo.isFlex());
		default: puterror(HSPERR_ILLEGAL_FUNCTION);
	}
}

int FunctorCmd::prminfo(PDAT** ppResult)
{
	functor_t&& f = code_get_functor();
	int const id = code_geti();
	int const idxPrm = code_getdi(-1);
	return SetReffuncResult( ppResult, getPrmInfo(f->getPrmInfo(), id, idxPrm) );
}

//##########################################################
//    その他
//##########################################################
//------------------------------------------------
// 引数束縛
//------------------------------------------------
int FunctorCmd::argBind( PDAT** ppResult )
{
	auto&& f = code_get_functor();
	auto&& result = functor_t::makeDerived<CBound>(f);

	auto const bound = result->castTo<CBound>();
	assert(bound);
	bound->bind();

	return SetReffuncResult( ppResult, std::move(result) );
}

//------------------------------------------------
// 束縛解除
//------------------------------------------------
int FunctorCmd::unBind( PDAT** ppResult )
{
	puterror(HSPERR_UNSUPPORTED_FUNCTION);
#if 0
	auto&& f = code_get_functor();
	auto const bound = f->safeCastTo<CBound>();
	if ( !bound ) puterror(HSPERR_ILLEGAL_FUNCTION);

	return SetReffuncResult( ppResult, bound->getUnbound() );
#endif
}

//------------------------------------------------
// ラムダ式
// 
// lambda(args..., result) → function() {
//     lambdaBody_ args... : call_setResult_ result : return
// }
//------------------------------------------------
int FunctorCmd::lambda( PDAT** ppResult )
{
	return SetReffuncResult( ppResult, functor_t::makeDerived<CLambda>() );
}

//------------------------------------------------
// lambda が内部で用いるコマンド
// 
// @ LambdaBody_:
// @	引数を順に取り出し、それぞれを local 変数に代入していく。
// @	最後の引数は返値として受け取る。
// @	ゆえに、この命令の引数は必ず (local 変数の数 + 1) 存在する。
// @ LambdaValue_:
// @	idx 番目の local 変数の値を取り出す。現状 localVal に等しい。
//------------------------------------------------
void FunctorCmd::lambdaBody_()
{
	auto& caller = Caller::top();
	size_t const cntLocals = caller.getPrms().cntLocals();

	for ( size_t i = 0; i < cntLocals; ++ i ) {
		int const chk = code_getprm();
		assert(chk > PARAM_END);
		PVal* const pvLocal = caller.getArgs()->peekLocalAt(i);
		PVal_assign( pvLocal, mpval->pt, mpval->flag );
	}

	CallCmd::call_setResult_();
	return;
}

int FunctorCmd::lambdaValue_(PDAT** ppResult)
{
	return CallCmd::localVal(ppResult);
}

//------------------------------------------------
// コルーチン::生成
//------------------------------------------------
int FunctorCmd::coCreate( PDAT** ppResult )
{
	auto&& functor = code_get_functor();

	auto&& result = functor_t::makeDerived<CCoRoutine>(std::move(functor));
	auto const coroutine = result->safeCastTo<CCoRoutine>();

	Caller* const caller = coroutine->getCallerFirst();
	caller->code_get_arguments();

	return SetReffuncResult( ppResult, std::move(result) );
}

//------------------------------------------------
// コルーチン::中断
//------------------------------------------------
void FunctorCmd::coYield_()
{
	// 第一引数を返値として受け取る
	CallCmd::call_setResult_();

	// newlab される変数
	PVal* const pvalResume = code_get_var();

	arguments_t&& args = arguments_t::ofValptr(CPrmStk::ofPrmStkPtr(ctx->prmstack));
	//dbgout("args = %d:%d", (int)!!args, (!!args ? args.cntRefers() : -9));

	CCoRoutine::onYield(
		pvalResume,
		std::move(args)
	);
	return;
}

//##########################################################
//        ラベルのラップ
//##########################################################
//------------------------------------------------
// label 比較
//------------------------------------------------
int HspVarLabel_CmpI(PDAT* pdat, PDAT const* val)
{
	auto& lhs = VtTraits::derefValptr<vtLabel>(pdat);
	auto& rhs = VtTraits::derefValptr<vtLabel>(val);

	getHvp(HSPVAR_FLAG_LABEL)->aftertype = HSPVAR_FLAG_INT;
	return (lhs - rhs);
}

//------------------------------------------------
// label 型の比較演算を定義する
//------------------------------------------------
void CallCmd::call_defineLabelComparison()
{
	auto const hvp = getHvp(HSPVAR_FLAG_LABEL);

	HspVarTemplate_InitCmpI_Full< HspVarLabel_CmpI >(hvp);
	return;
}

//##########################################################
//        一般性のあるコマンド
//##########################################################
//------------------------------------------------
// コマンドを数値化して取得する
//------------------------------------------------
int CallCmd::axcmdOf(PDAT** ppResult)
{
	int const axcmd = code_get_axcmd();
	if ( axcmd == 0 ) puterror(HSPERR_TYPE_MISMATCH);
	return SetReffuncResult(ppResult, axcmd);
}

//------------------------------------------------
// ユーザ定義命令・関数などからラベルを取得する
//------------------------------------------------
static label_t code_labelOfImpl(int axcmd)
{
	if ( AxCmd::isOk(axcmd) ) {
		int const code = AxCmd::getCode(axcmd);
		switch ( AxCmd::getType(axcmd) ) {
			case TYPE_LABEL: return getLabel(code);
			case TYPE_MODCMD:
			{
				stdat_t const stdat = getSTRUCTDAT(code);
				if ( STRUCTDAT_isSttmOrFunc(stdat) ) {
					return getLabel(stdat->otindex);
				}
			}
		}
	}
	puterror(HSPERR_ILLEGAL_FUNCTION);
}

static label_t code_labelOf()
{
	// ユーザ定義コマンド
	if ( *type == TYPE_MODCMD ) {
		return code_labelOfImpl(code_get_axcmd());

		// その他
	} else {
		if ( code_getprm() <= PARAM_END ) puterror(HSPERR_NO_DEFAULT);

		// axcmd
		if ( mpval->flag == HSPVAR_FLAG_INT ) {
			return code_labelOfImpl(VtTraits::derefValptr<vtInt>(mpval->pt));

			// label
		} else if ( mpval->flag == HSPVAR_FLAG_LABEL ) {
			return VtTraits::derefValptr<vtLabel>(mpval->pt);

			// functor
		} else if ( mpval->flag == g_vtFunctor ) {
			return VtTraits::derefValptr<vtFunctor>(mpval->pt)->getLabel();
		}
		puterror(HSPERR_TYPE_MISMATCH);
	}
}

int CallCmd::labelOf(PDAT** ppResult)
{
	return SetReffuncResult(ppResult, code_labelOf());
}

//------------------------------------------------
// コマンドの呼び出し
//------------------------------------------------
int CallCmd::forwardCmd_( PDAT** ppResult )
{
	int const id = code_geti();
	if ( !AxCmd::isOk(id) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	if ( ppResult ) {
		// 関数を呼び出す (その返値をこれ自体の返値とする)
		{
			*type = AxCmd::getType(id);
			*val = AxCmd::getCode(id);
			*exinfo->npexflg = 0;

			if ( code_getprm() <= PARAM_END ) puterror(HSPERR_NO_DEFAULT);
		}
		*ppResult = mpval->pt;
		return mpval->flag;

	} else {
		// 指定した命令コマンドがあることにする (これにより1つのコード潰れるので、ダミーを配置すべし)
		{
			*type = AxCmd::getType(id);
			*val = AxCmd::getCode(id);
			*exinfo->npexflg = EXFLG_1;
		}
		return HSPVAR_FLAG_NONE;
	}
}

//##########################################################
//    テストコード
//##########################################################
#ifdef _DEBUG

int CallCmd::test(PDAT** ppResult)
{
	//

	puterror(HSPERR_UNSUPPORTED_FUNCTION);

	if ( ppResult ) {

	} else {
		return HSPVAR_FLAG_NONE;
	}
}

#endif
