// ストリーム呼び出しクラス

#include "CStreamCaller.h"
#include "mod_makepval.h"

using namespace hpimod;

//------------------------------------------------
// 構築
//------------------------------------------------
CStreamCaller::CStreamCaller(functor_t f)
	: caller_(new Caller { (assert(!!f && !!f->getUsing()), f) })
{ }

//------------------------------------------------
// 呼び出し処理
//------------------------------------------------
void CStreamCaller::call( Caller& callerGiven )
{
	caller_->invoke();
	callerGiven.moveResult(*caller_);
	return;
}

//------------------------------------------------
// 取得系
//------------------------------------------------
label_t CStreamCaller::getLabel() const { return caller_->getFunctor()->getLabel(); }
int     CStreamCaller::getAxCmd() const { return caller_->getFunctor()->getAxCmd(); }
int     CStreamCaller::getUsing() const { return hpimod::HspBool(caller_->getArgs()->hasFinalized()); }

//------------------------------------------------
// 
//------------------------------------------------
