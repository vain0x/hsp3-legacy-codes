// 引数束縛関数クラス

#include <map>
#include <vector>
#include <queue>

#include "CBound.h"

using namespace hpimod;

//------------------------------------------------
// 構築
//------------------------------------------------
CBound::CBound(functor_t f)
	: binder_(std::move(f))
	, remainPrms_(nullptr)
	, prmIdxAssoc_()
{}

//------------------------------------------------
// 束縛設定
//------------------------------------------------
void CBound::bind()
{
	binder_.code_get_arguments();
	createRemainPrms();
	return;
}

//------------------------------------------------
// 束縛関数の仮引数リストを生成する
// 
// @ 前からのみ束縛できる。
//------------------------------------------------
void CBound::createRemainPrms()
{
	assert(!remainPrms_);

	CPrmInfo const& srcPrms = getUnbound()->getPrmInfo();
	arguments_t& args = binder_.getArgs();
	assert(args.hasFinalized());

	size_t const cntPrms = srcPrms.cntPrms();
	size_t const cntArgs = args.cntArgs();
	//dbgout("(prms, args) = (%d, %d) -> %d", cntPrms, cntArgs, cntPrms - cntArgs );

	CPrmInfo::prmlist_t prmlist;

	// 元の仮引数 [i] を残引数として追加する関数
	auto const addRemainPrm = [&]( size_t i ) {
		prmIdxAssoc_.push_back( i );
		prmlist.push_back( srcPrms.getPrmType(i) );
	};

	{
/*
ややこしいので詳細メモ

目的：
argbind() の引数で不束縛引数 nobind が指定されているもの、および実引数が与えられなかったものを検索し、
それらを指定された「優先値」が小さい順に並べ替える。
優先値が等しいものは、元の仮引数における引数番号が小さい方を前にする。
//*/
		// { 優先値, 元の仮引数における位置 }
		using pair_t = std::tuple<unsigned int, size_t>;

		// 不束縛引数リスト
		// Remark: priority_queue は「優先度」降順で pop される。
		// ここでは pair_t が(辞書式順序で)小さいものを先に得たいので、順序を operator >= で定める。
		// todo: std::vector に入れて sort した方が速い？
		std::priority_queue< pair_t, std::vector<pair_t>, std::greater_equal<pair_t>  > argsNobind;

		for ( size_t i = 0; i < cntArgs; ++ i ) {
			if ( auto const p = args.peekArgNoBind(i) ) {
				argsNobind.push(std::make_tuple(*p, i));
				//dbgout("nobind-arg; push (%d, %d)", (int)*p, i);
			}
		}

		while ( !argsNobind.empty() ) {
			//dbgout("nobind-arg; pop (%d, %d)", std::get<0>(argsNobind.top()), std::get<1>(argsNobind.top()));
			addRemainPrm( std::get<1>(argsNobind.top()) );
			argsNobind.pop();
		}
	}

	// メンバ変数に設定する
	remainPrms_.reset(new CPrmInfo(std::move(prmlist)));
	//dbgout("argbind: remain %d prms", remainPrms_->cntPrms());
	return;
};

//------------------------------------------------
// 呼び出し処理
// 
// @ 束縛された引数と、与えられた引数をマージして、被束縛関数を呼び出す。
//------------------------------------------------
void CBound::call(Caller& callerRemain)
{
	Caller caller { getUnbound() };

	// 実引数のマージ
	caller.getArgs().merge(binder_.getArgs(), *this, callerRemain.getArgs());

	auto& args = caller.getArgs();

	// 呼び出す
	caller.invoke();

	callerRemain.moveResult(caller);
	return;
}
