// 引数束縛関数クラス

#ifndef IG_CLASS_BOUND_H
#define IG_CLASS_BOUND_H

#include "hsp3plugin_custom.h"
#include <vector>
#include <memory>

#include "IFunctor.h"
#include "Functor.h"
#include "CPrmInfo.h"
#include "Invoker.h"

class CBound
	: public IFunctor
{
	using prmIdxAssoc_t = std::vector<size_t, hpimod::HspAllocator<size_t>>;

	// 束縛を行い、束縛された実引数を所有する
	ArgBinder binder_;

	// これが受け取るべき、残りの引数からなる仮引数リスト
	std::unique_ptr<CPrmInfo> remainPrms_;

	// 残引数と元引数の引数番号の対応 (各要素: 元引数の引数番号)
	prmIdxAssoc_t prmIdxAssoc_;

public:
	CBound(functor_t f);

	ArgBinder const& getBinder()  const { return binder_; }
	prmIdxAssoc_t const& getPrmIdxAssoc() const { return prmIdxAssoc_; }
	functor_t const& getUnbound() const { return binder_.getFunctor(); }

	// 引数束縛
	void bind();

private:
	// 仮引数の生成
	void createRemainPrms();

	// IFunctor の実装
public:
	CPrmInfo const& getPrmInfo() const override { assert(remainPrms_); return *remainPrms_; }
	hpimod::label_t getLabel() const override { return getUnbound()->getLabel(); }
	int getAxCmd() const override { return getUnbound()->getAxCmd(); }
	int getUsing() const override { return getUnbound()->getUsing(); }

	void call(Caller& caller) override;
};

#endif
