// jump - command

#include "cmd.h"

extern bool jump_core(LABEL lb, PVal *pval);

// jump命令のコア
static bool jump_core(LABEL lb, PVal *pval)
{
	int old_sublev;
	
	old_sublev = ctx->sublev;	// sublev を記憶しておく
	
	code_call( lb );			// ジャンプ
	
	 // 戻り値あり？
	if (ctx->retval_level == (old_sublev + 1) ) {
		PVal *pretval = *exinfo->mpval;
		
		if ( pval != NULL ) {
			HspVarProc *phvp = exinfo->HspFunc_getproc( pretval->flag );
			code_setva( pval, pval->offset, pretval->flag, phvp->GetPtr(pretval) );
		}
		
		return true;
	}
	
	return false;	// 戻り値なし
}

//##########################################################
//        命令形式コマンド関数
//##########################################################
void jump_st(void)
{
	LABEL label;
	PVal *pval = NULL;
	APTR aptr;
	
	label = code_getlb();
	if ( (*exinfo->npexflg & EXFLG_1) == false ) {	// まだ引数があるなら
		aptr         = code_getva( &pval );
		pval->offset = aptr;
	}
	
	// 通常のサブルーチンコール？
	if ( pval == NULL ) {
		code_call( label );
		
	// 戻り値付きコール？
	} else {
		ctx->stat = ( jump_core( label, pval ) ? 1 : 0 );
	}
	return;
}

//##########################################################
//        関数形式コマンド関数
//##########################################################
int jump_f(void **ppResult)
{
	static PVal *stt_retvar = NULL;
	LABEL label;
	
	// 初回呼び出しか？
	if ( stt_retvar == NULL ) {
		stt_retvar         = (PVal *)hspmalloc( sizeof(PVal) );
		stt_retvar->flag   = HSPVAR_FLAG_INT;
		stt_retvar->mode   = HSPVAR_MODE_NONE;
		stt_retvar->offset = 0;
		
		HspVarProc *phvp;
		phvp = exinfo->HspFunc_getproc(HSPVAR_FLAG_INT);
		phvp->Alloc(stt_retvar, NULL);
	}
	
	// サブルーチン呼び出し
	label = code_getlb();
	
	// 戻り値がある？
	if ( jump_core( label, stt_retvar ) ) {
		HspVarProc *phvp;
		
		phvp      = exinfo->HspFunc_getproc( stt_retvar->flag );
		*ppResult = phvp->GetPtr( stt_retvar );
		
	} else {
		puterror( HSPERR_NORETVAL );
	}
	
	return stt_retvar->flag;
}

//##########################################################
//        システム変数形式コマンド関数
//##########################################################
