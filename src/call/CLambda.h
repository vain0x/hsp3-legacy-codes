// ラムダ関数クラス

#ifndef IG_CLASS_LAMBDA_FUNC_H
#define IG_CLASS_LAMBDA_FUNC_H

#include "hsp3plugin_custom.h"
#include <vector>
#include <memory>

#include "Invoker.h"
#include "CHspCode.h"
#include "CPrmInfo.h"
#include "IFunctor.h"

class CLambda
	: public IFunctor
{
	// メンバ変数
private:
	// 自作関数の本体コード、仮引数
	std::unique_ptr<CHspCode> body_;		
	std::unique_ptr<CPrmInfo> prms_;

	// 生成環境の実引数を保存するもの
	vector_t capturer_;

	// 構築
public:
	CLambda();

	CHspCode const& getBody() const { assert(body_); return *body_; }
	CPrmInfo const& getPrmInfo() const override;
	hpimod::label_t getLabel() const override;

	int getUsing() const override { return 1; }

	void call( Caller& caller ) override;

private:
	void code_get();
};

#endif
