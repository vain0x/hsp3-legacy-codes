// ラムダ関数クラス

#include <map>
#include <vector>

#include "CHspCode.h"
#include "mod_argGetter.h"

#include "Invoker.h"
#include "Functor.h"
#include "CLambda.h"

#include "iface_call.h"
#include "cmd_sub.h"

using namespace hpimod;

static void* GetReferedPrmstk(stprm_t pStPrm);

//------------------------------------------------
// 構築
//------------------------------------------------
CLambda::CLambda()
	: IFunctor()
	, body_ { new CHspCode() }
	, prms_(nullptr)
	, capturer_ {}
{
	code_get();
}

//------------------------------------------------
// 仮引数リストを取得する
//------------------------------------------------
CPrmInfo const& CLambda::getPrmInfo() const
{
	assert(prms_);
	return *prms_;
}

//------------------------------------------------
// ラベルを取得する
// 
// @ コードを追加すると、ラベルが変更されるかもしれない。
//------------------------------------------------
label_t CLambda::getLabel() const
{
	assert(body_);
	return body_->getlb();
}

//------------------------------------------------
// 呼び出し処理
// 
// @ 関数を呼び出す or 実行を再開する。
//------------------------------------------------
void CLambda::call( Caller& callerGiven )
{
	auto const lbDst = getLabel();
//	auto& prminfo = getPrmInfo();

#if 0
	{// 本体コードの列挙
		label_t mcs = lbDst;
		int _t, _v, _e;

		for ( int i = 0; ; ++ i ) {
			unsigned short a = *(mcs ++);
			_e = a & (EXFLG_0 | EXFLG_1 | EXFLG_2);
			_t = a & CSTYPE;
			if ( a & 0x8000 ) {
				_v = *(int*)mcs;
				mcs += 2;
			} else {
				_v = (int)*(mcs ++);
			}

			dbgout("code #%d (%d, %d, %X)", i, _t, _v, _e );
			if ( _t == TYPE_STRUCT ) {
				stprm_t const prm = &ctx->mem_minfo[_v];
				dbgout( "subid id: %d, mptype: %d", (int)prm->subid, (int)prm->mptype );
			}
			if ( i != 0 && (_e & EXFLG_1) ) break;
		}
	}
#endif

	Caller callerInternal { Functor::New(lbDst) };
	auto& args = callerInternal.getArgs();
	args = std::move(callerGiven.getArgs());
	args.importCaptures(capturer_);

	callerInternal.invoke();
	
	assert( callerInternal.hasResult() );
	callerGiven.moveResult(callerInternal);
	return;

#if 0
	callerGiven.setFunctor( lbDst );

	// 保存された引数列を追加する
	if ( mpArgCloser ) {
		auto& callCloser = mpArgCloser->getCall();
		for ( size_t i = 0; i < callCloser.getCntArg(); ++ i ) {
			callerGiven.addArgByRef( callCloser.getArgPVal(i), callCloser.getArgAptr(i) );
		}
	}
	// 呼び出す
	callerGiven.call();
#endif
}

//------------------------------------------------
// スクリプトから lambda を初期化
// 
// @ 引数式の中間コードを複写。
// @ 引数エイリアスは参照できるようにする。
// @ ( 初期化処理なのでメンバ関数にしたが、ここでいいのかと )
// @ 実行される匿名関数の prmstk は
// @	(lambda関数の引数列), (キャプチャされた変数の列), (中間計算値を持つローカル変数列)
// @ という列になる。
//------------------------------------------------
void CLambda::code_get()
{
	CHspCode& body = *body_;
	int& exflg = *exinfo->npexflg;

	// 仮引数、ローカル変数の個数
	size_t cntPrms   = 0;		
	size_t cntLocals = 0;
	
	// 「キャプチャされた変数」を参照するコードの位置 (後で修整するために位置を記憶する)
	std::vector<std::pair<stprm_t, size_t>> outerArgs;

	// 専用の命令コマンドを配置
	body.put( g_pluginType_call, FunctorCmd::Id::lambdaBody_, EXFLG_1 );
	
	// 式をコピーする
	for ( int lvBracket = 0; ; ) {		
		if ( *type == TYPE_MARK ) {
			if ( *val == '(' ) lvBracket ++;
			if ( *val == ')' ) lvBracket --;
			if ( lvBracket < 0 ) break;
		}

		// 関数本体の式に追加する
		if ( lvBracket == 0 && exflg & EXFLG_2 ) {
			cntLocals++;	// 次も引数がある、つまりこの引数式は中間計算値
		}
	//	dbgout("put (%d, %d, %X)", *type, *val, exflg );

		if ( *type == TYPE_STRUCT ) {
			// 構造体パラメータが実際に指している値をコードに追加する
			auto const stprm = getSTRUCTPRM(*val);
			void* const prmstk = GetReferedPrmstk(stprm);

			// 引数を展開
			{
				void* const ptr = hpimod::Prmstack_getMemberPtr(prmstk, stprm);
				int const mptype = stprm->mptype;

				switch ( mptype ) {
					case MPTYPE_ARRAYVAR:
						body.putVar( reinterpret_cast<MPVarData*>(ptr)->pval );
						break;

					case MPTYPE_LABEL: body.putVal( *reinterpret_cast<label_t*>(ptr) ); break;
					case MPTYPE_LOCALSTRING: body.putVal( *reinterpret_cast<char**>(ptr) ); break;
					case MPTYPE_DNUM: body.putVal( *reinterpret_cast<double*>(ptr) ); break;
					case MPTYPE_INUM: body.putVal( *reinterpret_cast<int*>(ptr) ); break;

					case MPTYPE_SINGLEVAR:
					case MPTYPE_LOCALVAR:
					{
						// 変数要素は、リテラル値で記述できないので、lambda関数の prmstk に乗せるためにキャプチャする
						if ( mptype == MPTYPE_SINGLEVAR ) {
							auto const vardata = reinterpret_cast<MPVarData*>(ptr);
							capturer_->push_back({ vardata->pval, vardata->aptr });

						// ローカル変数は、実行中に消滅するかもなのでコピーを取る
						} else {
							auto const pval = reinterpret_cast<PVal*>(ptr);
							auto&& vardata = ManagedVarData::duplicate(pval);
							//dbgout("local copy: vardata->ref = %d", ManagedPVal::ofValptr(vardata.getPVal()).cntRefers());
							capturer_->push_back(std::move(vardata));
						}

						// キャプチャしたものを記録しておく
						// このエイリアスの offset 値は、元々のものと異なるので、自作した STRUCTPRM を用意する。
						// 仮引数の数が確定するまで offset が分からないので、ダミー値 (-1) を書いておき、後で書き換える。
						// short では収まらない値かもなので、(-1 にして) int サイズを確保する。
						outerArgs.push_back({ stprm, body.getCurrentOffset() });
						body.put( TYPE_STRUCT, -1, exflg );
						break;
					}
					default: dbgout("mptype = %d", mptype ); break;
				}
			}
			code_next();

		} else if ( *type == g_pluginType_call && *val == CallCmd::Id::call_prmOf_ ) {
			// 仮引数プレースホルダ [ call_prmof ( (引数番号) ) ]

			int const exflg_here = exflg;

			code_next();
			if ( !code_next_expect( TYPE_MARK, '(' ) ) puterror( HSPERR_SYNTAX );

			int const iPrm = code_geti();
			if ( iPrm < 0 ) puterror(HSPERR_ILLEGAL_FUNCTION);

			if ( !code_next_expect( TYPE_MARK, ')' ) ) puterror( HSPERR_SYNTAX );

			// 仮引数の数を確保
			cntPrms = std::max<size_t>(cntPrms, iPrm + 1);

			// 対応する実引数を取り出すコード「argv(n)」を出力
			body.put( g_pluginType_call, CallCmd::Id::argVal, exflg_here );
			body.put( TYPE_MARK, '(', 0 );
			body.putVal( iPrm, EXFLG_0 );
			body.put( TYPE_MARK, ')', 0 );

		} else if ( *type == g_pluginType_call && *val == FunctorCmd::Id::lambda ) {
			// lambda 関数
			// @ これの内側にある構造体パラメータや仮引数プレースホルダを今は無視するために、引数式を単純複写する

			body.put( *type, *val, exflg );
			code_next();

			if ( *type == TYPE_MARK && *val == '(' ) {
				for ( int lvBracket = 0; ; ) {
					if ( *type == TYPE_MARK ) {
						if ( *val == '(' ) lvBracket ++;
						if ( *val == ')' ) lvBracket --;
					}
					body.put( *type, *val, exflg );
					code_next();
					if ( lvBracket == 0 ) break;
				}
			}

		} else {
			// (その他)
			body.put( *type, *val, exflg );
			code_next();
		}
	}

//	if ( exflg & EXFLG_2 ) puterror( HSPERR_TOO_MANY_PARAMETERS );

	// コードの先読みによるオーバーランを防ぐための番兵
	body.putReturn();	
	body.putReturn();

	// 仮引数リストの構築
	// lambda 関数が呼ばれるときと、lambda の内部から実際のラベルにジャンプするときで、共用する。
	{
		// 仮引数形式：「lambda引数(__pN) + キャプチャ変数 + ローカル変数(__vN)」

		CPrmInfo::prmlist_t prmlist;
		prmlist.resize(cntPrms + outerArgs.size() + cntLocals);

		// lamda 引数
		std::fill(prmlist.begin(), prmlist.begin() + cntPrms, PrmType::Any);

		// キャプチャ値
		for ( size_t i = 0; i < outerArgs.size(); ++i ) {
			prmlist[cntPrms + i] = (
				PrmType::Capture
#if 0
				(outerArgs[cntPrms + i].first->mptype == MPTYPE_SINGLEVAR)
				? PrmType::Var
				: PrmType::Array
#endif
			);
		}

		// ローカル変数
		std::fill(prmlist.end() - cntLocals, prmlist.end(), PrmType::Local);

		assert(!prms_);
		prms_ = std::make_unique<CPrmInfo>(std::move(prmlist));

		dbgout("(prms, caps, locals) = (%d, %d, %d)", cntPrms, outerArgs.size(), cntLocals);
	}

	// ラムダ式中に含まれる、「キャプチャ変数を参照している TYPE_STRUCT コード」の code 値を補完する
	{
		label_t const lbBody = getLabel();

		for ( size_t i = 0; i < outerArgs.size(); ++ i ) {
			int const idxPrm = body.putDsStPrm({
				((outerArgs[i].first->mptype) == MPTYPE_SINGLEVAR ? MPTYPE_SINGLEVAR : MPTYPE_ARRAYVAR),
				STRUCTPRM_SUBID_STACK,
				prms_->getStackOffsetCapture(i)
			});

			auto const p = const_cast<unsigned short*>(lbBody) + outerArgs[i].second;
			assert((*p & CSTYPE) == TYPE_STRUCT && *reinterpret_cast<int*>(p + 1) == -1);
			*reinterpret_cast<int*>(p + 1) = idxPrm;
		}
	}
	return;
}

//------------------------------------------------
// 構造体パラメータが参照している prmstk を(現在の情報から)取得する
// 
// @result: prmstk 領域へのポインタ (失敗 => nullptr)
//------------------------------------------------
void* GetReferedPrmstk(stprm_t stprm)
{
	void* const cur_prmstk = ctx->prmstack;
	if ( !cur_prmstk ) return nullptr;

	if ( stprm->subid == STRUCTPRM_SUBID_STACK ) {
		// コマンドの引数
		return cur_prmstk;

	} else if ( stprm->subid >= 0 ) {
		// メンバ変数
		auto const thismod = reinterpret_cast<MPModVarData*>(cur_prmstk);
		if ( thismod->pval->flag != HSPVAR_FLAG_STRUCT ) puterror(HSPERR_TYPE_MISMATCH);
		return VtTraits::asValptr<vtStruct>(PVal_getPtr(thismod->pval, thismod->aptr))->ptr;
	}

	return nullptr;
}
//------------------------------------------------
// 
//------------------------------------------------

//------------------------------------------------
// 
//------------------------------------------------
