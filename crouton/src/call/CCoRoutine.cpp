// コルーチンクラス

#include "CCoRoutine.h"

#include "Invoker.h"
#include "Functor.h"
#include "CPrmInfo.h"

using namespace hpimod;

arguments_t CCoRoutine::stt_args { nullptr };
PVal const* CCoRoutine::stt_pvalResume { nullptr };

//------------------------------------------------
// 構築
//------------------------------------------------
CCoRoutine::CCoRoutine(functor_t f)
	: callerFirst_ { new Caller(std::move(f)) }
	, resumeLabel_ { nullptr }
	, resumeArgs_ { nullptr }
{ }

//------------------------------------------------
// 呼び出し処理
// 
// @ 関数を呼び出す or 実行を再開する。
//------------------------------------------------
void CCoRoutine::call( Caller& callerGiven )
{
	if ( !resumeLabel_ ) {
		// 既に終了している
		if ( !callerFirst_ ) puterror(HSPERR_INVALID_ARRAY);

		// 1回目

		callerFirst_->invoke();
		callerGiven.moveResult(*callerFirst_);

		callerFirst_.reset(nullptr);
	} else {
		// 2回目

		// caller スタックを使わずに label を呼ぶ
		PVal* const pval = callLabelWithPrmStk(resumeLabel_, resumeArgs_->getPrmStkPtr());
		assert(!pval && callerGiven.hasResult());
	}

	// 次の呼び出し先を再設定する
	if ( stt_pvalResume ) {
		if ( stt_pvalResume->flag != HSPVAR_FLAG_LABEL ) puterror(HSPERR_TYPE_MISMATCH);

		resumeLabel_ = VtTraits::derefValptr<vtLabel>(stt_pvalResume->pt);
		resumeArgs_ = std::move(stt_args);

		stt_pvalResume = nullptr;
	}
	return;
}

//------------------------------------------------
// 
//------------------------------------------------
