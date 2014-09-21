// call - command.cpp

#include <stack>
#include <set>

#include "hsp3plugin_custom.h"
#include "reffuncResult.h"
#include "mod_argGetter.h"
#include "mod_varutil.h"
#include "axcmd.h"

#include "CCall.h"
#include "CCaller.h"

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
	Invoker inv { std::move(f) };
	inv.code_get_arguments();
//	dbgout("%d", inv.getArgs().cntArgs());
	inv.invoke();

	if ( ppResult ) {
		PVal* const pval = inv.getResult();
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
	DeclarePrmInfo( lb, CPrmInfo(&prmlist) );
	return lb;
}

int CallCmd::declare(PDAT** ppResult)
{
	if ( ppResult ) {
		return SetReffuncResult(ppResult, Functor::New(declareImpl()));
	} else {
		declareImpl();
		return HSPVAR_FLAG_NONE;
	}
}

//##########################################################
//        引数情報取得
//##########################################################
//------------------------------------------------
// arginfo
//------------------------------------------------
static int getArgInfo(Invoker const& inv, int id, size_t idxArg)
{
	auto const prmtype = inv.getPrmInfo().getPrmType(idxArg);

	switch ( id ) {
		case ArgInfoId::IsVal:
			if ( PrmType::isVartype(prmtype) ) {
				return HspTrue;

			} else if ( prmtype == PrmType::Any ) {
				return HspBool( ManagedPVal::isManagedValue(inv.getArgs().peekRefArgAt(idxArg)) );
			} else {
				return HspFalse;
			}
		case ArgInfoId::IsRef:
			if ( PrmType::isRef(prmtype) ) {
				return HspTrue;

			} else if ( prmtype == PrmType::Any ) {
				return HspBool(getArgInfo(inv, ArgInfoId::IsVal, idxArg) == HspFalse);

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
	auto& inv = Invoker::top();

	auto const id = code_geti();	// データの種類
	int const idxArg = code_geti();
	if ( !(0 <= idxArg && static_cast<size_t>(idxArg) < inv.getArgs().cntArgs()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	return SetReffuncResult( ppResult, getArgInfo(inv, id, idxArg) );
}

//------------------------------------------------
// ラベル関数の返値を設定する
//------------------------------------------------
void CallCmd::call_setResult_()
{
	auto& inv = Invoker::top();
	if ( code_getprm() <= PARAM_END ) puterror(HSPERR_NO_DEFAULT);

	inv.setResult(mpval->pt, mpval->flag);
	return;
}

//------------------------------------------------
// ラベル関数の返値となった値を取り出す
// 
// @ call 終了後にだけ呼び出される。
//------------------------------------------------
int CallCmd::call_getResult_(PDAT** ppResult)
{
	PVal* const pvResult = Invoker::getLastResult();
	if ( pvResult ) {
		*ppResult = pvResult->pt;
		return pvResult->flag;

	} else {
		puterror(HSPERR_NORETVAL);
	}
}

//------------------------------------------------
// 引数の値を取得する
//
// @ 参照渡し引数の値は取り出せない。
//------------------------------------------------
int CallCmd::argVal(PDAT** ppResult)
{
	auto& inv = Invoker::top();
	auto& args = inv.getArgs();

	int const idxArg = code_getdi(0);
	if ( !(0 <= idxArg && static_cast<size_t>(idxArg) < args.cntArgs()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	// 返値を設定する
	vartype_t vtype;
	*ppResult = args.peekValArgAt(idxArg, vtype);
	return vtype;
}

//------------------------------------------------
// 参照引数のクローンを作る
//------------------------------------------------
void CallCmd::argClone()
{
	auto& inv = Invoker::top();
	auto& args = inv.getArgs();

	PVal* const pval = code_getpval();
	int const idxArg = code_geti();
	if ( !(0 <= idxArg && static_cast<size_t>(idxArg) < args.cntArgs()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	PVal* const pvalSrc = args.peekRefArgAt(idxArg);
	PVal_clone(pval, pvalSrc, pvalSrc->offset);
	return;
}

//------------------------------------------------
// エイリアス名を一括して付ける
//------------------------------------------------
void CallCmd::argCloneAll()
{
	auto& inv = Invoker::top();
	auto& args = inv.getArgs();

	// 列挙された変数をエイリアスにする
	for ( size_t i = 0
		; code_isNextArg() && (i < args.cntArgs())
		; ++i
		) {
		try {
			PVal* const pval = code_getpval();
			PVal* const pvalSrc = args.peekRefArgAt(i);
			PVal_clone(pval, pvalSrc, pvalSrc->offset);

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
	auto& inv = Invoker::top();

	int const idxLocal = code_geti();
	if ( !(0 <= idxLocal && static_cast<size_t>(idxLocal) < inv.getPrmInfo().cntLocals()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	PVal* const pvLocal = inv.getArgs().peekLocalAt(idxLocal);
	if ( !pvLocal ) puterror( HSPERR_ILLEGAL_FUNCTION );

	*ppResult = pvLocal->pt;
	return pvLocal->flag;
}

void CallCmd::localClone()
{
	PVal* pval = code_getpval();

	auto& inv = Invoker::top();
	int const idxLocal = code_geti();
	if ( !(0 <= idxLocal && static_cast<size_t>(idxLocal) < inv.getPrmInfo().cntLocals()) ) puterror(HSPERR_ILLEGAL_FUNCTION);

	PVal* const pvLocal = inv.getArgs().peekLocalAt(idxLocal);
	if ( !pvLocal ) puterror( HSPERR_ILLEGAL_FUNCTION );

	PVal_clone(pval, pvLocal);
	return;
}

#if 0
int CallCmd::localVector(PDAT** ppResult)
{
	auto& inv = Invoker::top();

	vector_t vec {};
	for ( size_t i = 0; i < inv.getPrmInfo().cntLocals(); ++i ) {
		vec->push_back({ inv.getArgs().peekLocalAt(i), 0 });
	}
	return SetReffuncResult(ppResult, std::move(vec));
}
#endif


//------------------------------------------------
// 可変長引数の値
//------------------------------------------------
int CallCmd::flexVal(PDAT** ppResult)
{
	auto& inv = Invoker::top();

	if ( auto pFlex = inv.getArgs().peekFlex() ) {
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
	auto& inv = Invoker::top();

	if ( auto pFlex = inv.getArgs().peekFlex() ) {
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

#if 0
//------------------------------------------------
// 可変長引数の vector
//------------------------------------------------
int CallCmd::flexVector(PDAT** ppResult)
{
	auto& inv = Invoker::top();
	if ( auto pFlex = inv.getArgs().peekFlex() ) {
		return SetReffuncResult(ppResult, *pFlex);

	} else {
		puterror(HSPERR_ILLEGAL_FUNCTION);
	}
}
#endif

//------------------------------------------------
// 呼び出されたラベル
//------------------------------------------------
int CallCmd::thislb(PDAT** ppResult)
{
	return SetReffuncResult( ppResult, Invoker::top().getFunctor()->getLabel() );
}

int CallCmd::thisfunc(PDAT** ppResult)
{
	return SetReffuncResult( ppResult, Invoker::top().getFunctor() );
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


//------------------------------------------------
// ストリーム呼び出しオブジェクト::生成
//------------------------------------------------
int CallCmd::streamCallerNew( PDAT** ppResult )
{
	stream_t const stream = CStreamCaller::New();

	// 引数処理
	CCaller* const caller = stream->getCaller();
	{
		caller->setFunctor();
	}

	// functor 型として返却する
	return SetReffuncResult( ppResult, functor_t::make(stream) );
}


//------------------------------------------------
// ストリーム呼び出しオブジェクト::追加
//------------------------------------------------
void CallCmd::streamCallerAdd()
{
	functor_t&& functor = code_get_functor();
	stream_t const stream = functor->safeCastTo<stream_t>();

	stream->getCaller()->setArgAll();		// 全ての引数を追加する
	return;
}
#endif

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

		return SetReffuncResult(ppResult, g_vtFunctor);

	} else if ( ppResult && !bSysvar ) {
		// 型変換

		int const chk = code_getprm();
		if ( chk <= PARAM_END ) puterror(HSPERR_NO_DEFAULT);

		*ppResult = g_hvpFunctor->Cnv(mpval->pt, mpval->flag);
		assert(*ppResult == FunctorTraits::asPDAT(&g_resFunctor));
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
#if 0
//------------------------------------------------
// 引数束縛
//------------------------------------------------
int CallCmd::argBind( PDAT** ppResult )
{
	bound_t const bound = CBound::New();

	// 引数処理
	CCaller* const caller = bound->getCaller();
	{
		caller->setFunctor();	// スクリプトから被束縛関数を取り出す
		caller->setArgAll();	// スクリプトから与えられた引数を全て受け取る (不束縛引数も受け付ける)
	}
	bound->bind();

	// functor 型として返却する
	return SetReffuncResult( ppResult, functor_t::make(bound) );
}

//------------------------------------------------
// 束縛解除
//------------------------------------------------
int CallCmd::unBind( PDAT** ppResult )
{
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	if ( mpval->flag != g_vtFunctor ) puterror( HSPERR_TYPE_MISMATCH );

	auto const functor = FunctorTraits::derefValptr(mpval->pt);
	auto const bound   = functor->safeCastTo<bound_t>();

	return SetReffuncResult( ppResult, bound->unbind() );
}

//------------------------------------------------
// ラムダ式
// 
// @ funcexpr(args...) → function() { lambdaBody args... : return }
//------------------------------------------------
int CallCmd::lambda( PDAT** ppResult )
{
	auto const lambda = CLambda::New();

	lambda->code_get();

	return SetReffuncResult( ppResult, functor_t::make(lambda) );
}

//------------------------------------------------
// lambda が内部で用いるコマンド
// 
// @ LambdaBody:
// @	引数を順に取り出し、それぞれを local 変数に代入していく。
// @	最後の引数は返値として受け取る。
// @	ゆえに、この命令の引数は必ず (local 変数の数 + 1) 存在する。
// @ LambdaValue:
// @	idx 番目の local 変数を取り出す。
//------------------------------------------------
void CallCmd::lambdaBody()
{
	auto& inv = Invoker::top();
	size_t const cntLocals = inv.getPrmInfo().cntLocals();

	for ( size_t i = 0; i < cntLocals; ++ i ) {
		int const chk = code_getprm();
		assert(chk > PARAM_END);
		PVal* const pvLocal = inv.getArgs().peekLocalAt(i);
		PVal_assign( pvLocal, mpval->pt, mpval->flag );
	}

	CallCmd::retval();
	return;
}

//------------------------------------------------
// コルーチン::生成
//------------------------------------------------
int CallCmd::coCreate( PDAT** ppResult )
{
	auto coroutine = CCoRoutine::New();

	CCaller* const caller = coroutine->getCaller();
	caller->setFunctor();		// functor を受ける
	caller->setArgAll();

	return SetReffuncResult( ppResult, functor_t::make(coroutine) );
}

//------------------------------------------------
// コルーチン::中断実装
//------------------------------------------------
void CallCmd::coYieldImpl()
{
	CallCmd::retval();		// 返値を受け取る

	// newlab される変数をコルーチンに渡す
	PVal* const pvNextLab = code_get_var();
	CCoRoutine::setNextVar( pvNextLab );	// static 変数に格納する

	return;
}
#endif

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
				if ( stdat->index == STRUCTDAT_INDEX_FUNC || stdat->index == STRUCTDAT_INDEX_CFUNC ) {
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
			return code_labelOfImpl(VtTraits<int>::derefValptr(mpval->pt));

			// label
		} else if ( mpval->flag == HSPVAR_FLAG_LABEL ) {
			return VtTraits<label_t>::derefValptr(mpval->pt);

			// functor
		} else if ( mpval->flag == g_vtFunctor ) {
			return FunctorTraits::derefValptr(mpval->pt)->getLabel();
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
