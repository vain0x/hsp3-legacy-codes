// 引数取得モジュール

#include "hsp3plugin_custom.h"
#include "mod_argGetter.h"
#include "mod_makepval.h"

//##########################################################
//    宣言
//##########################################################
//static void code_checkarray2( PVal* pval );

//##########################################################
//    引数の取得
//##########################################################
/*
//------------------------------------------------
// 変数を取得する
//------------------------------------------------
bool code_getva_ex(PVal** pval, APTR* aptr)
{
	*pval = &ctx->mem_var[*val];					// グローバル変数のデータから PVal を取り出す
	if ( code_getprm() <= PARAM_END ) return false;	// 違ったら偽
	*aptr = (*pval)->offset;
	return true;
}
//*/

//------------------------------------------------
// 文字列を取得する( hspmalloc で確保する )
// 
// @ 解放義務は呼び出し元にある。
//------------------------------------------------
int code_getds_ex(char** ppStr, const char* defstr)
{
	char* pStr = code_getds(defstr);
	size_t len = strlen(pStr);
	
	*ppStr = hspmalloc( (len + 1) * sizeof(char) );
	strncpy( *ppStr, pStr, len );
	(*ppStr)[len] = '\0';		// NULLで止める
	return len;
}

//------------------------------------------------
// 文字列か数値を取得する
// 
// @ 文字列なら sbAlloc で確保、文字列をコピーする。
// @result = int
//		*ppStr が NULL なら、返値が有効。
//		そうでない場合、*ppStr が有効。
//------------------------------------------------
int code_getsi( char** ppStr )
{
	*ppStr = NULL;
	
	if ( code_getprm() <= PARAM_END ) return 0;
	
	switch ( mpval->flag ) {
		case HSPVAR_FLAG_INT:
			return *(int*)( mpval->pt );
			
		case HSPVAR_FLAG_DOUBLE:
			return static_cast<int>( *(double*)(mpval->pt) );
			
		case HSPVAR_FLAG_STR:
		{
			*ppStr = hspmalloc( PVal_size(mpval) + 1 );
			strcpy( *ppStr, (char*)PVal_getptr(mpval) );
			return 0;
		}
		default:
			puterror( HSPERR_TYPE_MISMATCH );
	}
	return 0;
}

//------------------------------------------------
// 型タイプ値を取得する
// 
// @ 文字列 or 数値
// @ int や str などの関数からも受け付けようとしたが、
// 		exflg とかがよくわからんことになるのでやめ。
// @error 文字列で非型名        => HSPERR_ILLEGAL_FUNCTION
// @error 文字列でも数値でもない => HSPERR_TYPE_MISMATCH
//------------------------------------------------
int code_getvartype( int deftype )
{
	int vflag = HSPVAR_FLAG_NONE;
	
	// 組み込み型変換関数の場合 ( exflg が正しくならないっぽいので削除 )
	/*
	if ( *type == TYPE_INTFUNC ) {
		switch ( *val ) {
			case 0x000: vflag = HSPVAR_FLAG_INT;    break;	// int()
			case 0x100: vflag = HSPVAR_FLAG_STR;    break;	// str()
			case 0x185: vflag = HSPVAR_FLAG_DOUBLE; break;	// double()
			default:
				vflag = HSPVAR_FLAG_NONE; break;
		}
		if ( vflag != HSPVAR_FLAG_NONE ) {
			code_next();
			return vflag;
		}
	}
	//*/
	
	// とりあえずなにか取得する
	int prm = code_getprm();
	if ( prm == PARAM_END || prm == PARAM_ENDSPLIT ) return HSPVAR_FLAG_NONE;
	if ( prm == PARAM_DEFAULT ) return deftype;
	
	switch ( mpval->flag ) {
		// 型タイプ値
		case HSPVAR_FLAG_INT:
			vflag = *(int*)(mpval->pt);
			break;
			
		// 型名
		case HSPVAR_FLAG_STR:
		{
			HspVarProc* vp = SeekHvp( mpval->pt );
			if ( vp == NULL ) {
				puterror( HSPERR_ILLEGAL_FUNCTION );
			}
			
			vflag = vp->flag;
			break;
		}
		default:
			puterror( HSPERR_TYPE_MISMATCH );
			break;
	}
	return vflag;
}

//------------------------------------------------
// 実行ポインタを取得する( ラベル、省略可能 )
//------------------------------------------------
label_t code_getdlb( label_t defLabel )
{
	try {
		return code_getlb();
		
	} catch( HSPERROR err ) {
		if ( err == HSPERR_LABEL_REQUIRED ) {
			return defLabel;
		}
		
		puterror( err );
		throw;
	}
	
	/*
	label_t lb = NULL;
	
	// リテラル( *lb )の場合
	// @ *val にはラベルID ( ctx->mem_ot の要素番号 )が入っている。
	// @ code_getlb() で得られるのはラベルが指す実行ポインタなるもの。
	if ( *type == TYPE_LABEL ) {	// ラベル定数
		
		lb = code_getlb();
		
	// ラベル型変数の場合
	// @ code_getlb() と同じ処理, mpval を更新する。
	// @ 条件 ( *type == TYPE_VAR ) では、ラベル型を返す関数やシステム変数に対応できない。
	} else {
		// ラベルの指す実行ポインタを取得
		if ( code_getprm() <= PARAM_END )         return NULL;
		if ( mpval->flag   != HSPVAR_FLAG_LABEL ) return NULL;
		
		// ラベルのポインタを取得する( 変数の実体から取り出す )
		lb = *(label_t*)( mpval->pt );
	}
	
	return lb;
	//*/
}

//------------------------------------------------
// ラベル実行ポインタを取得する
// @ ???
//------------------------------------------------
//pExec_t code_getlb2(void)
//{
//	pExec_t pLbExec = code_getlb();
//	code_next();
//	*exinfo->npexflg &= ~EXFLG_2;
//	return pLbExec;
//}

//##########################################################
//    配列添字の解決
//##########################################################
static void code_index_impl( PVal* pval, bool bRhs );

//------------------------------------------------
// 配列要素の取り出し (通常配列)
//------------------------------------------------
void code_index_lhs( PVal* pval ) { code_index_impl( pval, false ); }		// code_checkarray2
void code_index_rhs( PVal* pval ) { code_index_impl( pval, true  ); }		// code_checkarray

//------------------------------------------------
// 配列要素の取り出し (通常配列, 左右)
//------------------------------------------------
void code_index_impl( PVal* pval, bool bRhs )
{
	HspVarCoreReset(pval);	// 配列添字の情報を初期化する
	
	if ( *type != TYPE_MARK || *val != '(' ) return;
	
	code_next();
	
	int n = 0;
	PVal tmpPVal;
	
	for (;;) {
		// 添字の状態をチェック
		HspVarCoreCopyArrayInfo( &tmpPVal, pval );
		
		int prm = code_getprm();	// パラメーターを取り出す
		
		// エラーチェック
		if ( prm == PARAM_DEFAULT ) {
			n = 0;
			
		} else if ( prm <= PARAM_END ) {
			puterror( HSPERR_BAD_ARRAY_EXPRESSION );
			
		} else if ( mpval->flag != HSPVAR_FLAG_INT ) {
			puterror( HSPERR_TYPE_MISMATCH );
		}
		
		// 添字の状態をチェック
		HspVarCoreCopyArrayInfo( pval, &tmpPVal );
		
		if ( prm != PARAM_DEFAULT ) {
			n = *(int*)(mpval->pt);
		}
		
		code_index_int( pval, n, bRhs );	// 配列要素指定 (int)
		if ( prm == PARAM_SPLIT ) break;
	}
	
	code_next();	// ')'を読み飛ばす
	return;
}

//------------------------------------------------
// 配列要素の取り出し (連想配列, 左)
// 
// @from: code_checkarray_obj2
//------------------------------------------------
void code_index_obj_lhs( PVal* pval )
{
	HspVarCoreReset( pval );	// 添字状態をリセットする
	
	if ( *type == TYPE_MARK && *val == '(' ) {		// 添字がある場合
		code_next();
		
		GetHvp(pval->flag)->ArrayObject( pval );	// 添字参照
		
		code_next();								// ')'を読み飛ばす
	}
	
	return;
}

//------------------------------------------------
// 配列要素の取り出し (連想配列, 右)
// 
// @from: code_checkarray_obj
// @prm pval   : 添字指定される配列変数
// @prm mptype : 汎用データの型タイプ値を返す
// @result     : 汎用データへのポインタ
//------------------------------------------------
PDAT* code_index_obj_rhs( PVal* pval, int* mptype )
{
	HspVarCoreReset( pval );	// 添字状態をリセットする
	
	// 添字指定がある場合
	if ( *type == TYPE_MARK && *val == '(' ) {
		code_next();
		
		HspVarProc* vp = GetHvp( pval->flag );
		PDAT* pResult = (PDAT*)vp->ArrayObjectRead( pval, mptype );
		code_next();			// ')'を読み飛ばす
		return pResult;
	}
	
	*mptype = pval->flag;
	return PVal_getptr(pval);
}

//------------------------------------------------
// 配列要素の取り出し (中身だけ)
// 
// @ '(' の取り出しは終了しているとする
//------------------------------------------------
void code_expand_index_impl( PVal* pval )
{
	// 連想配列型 => ArrayObject() を呼ぶ
	if ( pval->support & HSPVAR_SUPPORT_ARRAYOBJ ) {
		( exinfo->HspFunc_getproc(pval->flag) )->ArrayObject( pval );
		
	// 通常配列型 => 次元の数だけ要素を取り出す
	} else {
		PVal pvalTemp;
		HspVarCoreReset( pval );
		
		for ( int i = 0; i < ArrayDimCnt && !(*type == TYPE_MARK && *val == ')'); ++ i ) {
			HspVarCoreCopyArrayInfo( &pvalTemp, pval );
			int idx = code_geti();
			HspVarCoreCopyArrayInfo( pval, &pvalTemp );
			
			code_index_int_lhs( pval, idx );
		}
	}
	
	return;
}

//------------------------------------------------
// 配列要素の設定 (通常配列, 1つだけ, 左右)
// 
// @ Reset 後に次元数だけ連続で呼ばれる。
//------------------------------------------------
void code_index_int( PVal* pval, int offset, bool bRhs )
{
	if ( !bRhs ) {
		code_index_int_lhs( pval, offset );			// 自動拡張する
	} else {
		exinfo->HspFunc_array( pval, offset );		// 自動拡張しない
	}
	return;
}

//------------------------------------------------
// 配列要素の設定 (通常配列, 1つだけ, 右)
// 
// @ 通常型 (int) のみ。
// @ Reset 後に次元数だけ連続で呼ばれる。
// @ 自動拡張対応。
//------------------------------------------------
void code_index_int_lhs( PVal* pval, int offset )
{
	if ( pval->arraycnt >= 5 ) puterror( HSPVAR_ERROR_ARRAYOVER );
	if ( pval->arraycnt == 0 ) {
		pval->arraymul = 1;		// 倍率初期値
	} else {
		pval->arraymul *= pval->len[pval->arraycnt];
	}
	pval->arraycnt ++;
	if ( offset < 0 ) puterror( HSPVAR_ERROR_ARRAYOVER );
	if ( offset >= pval->len[pval->arraycnt] ) {						// 配列拡張が必要
		if ( pval->arraycnt >= 4 || pval->len[pval->arraycnt + 1] == 0	// 配列拡張が可能
			&& ( pval->support & HSPVAR_SUPPORT_FLEXARRAY )				// 可変長配列サポート => 配列を拡張する
		) {
			exinfo->HspFunc_redim( pval, pval->arraycnt, offset + 1 );
			pval->offset += offset * pval->arraymul;
			return;
		}
		puterror( HSPVAR_ERROR_ARRAYOVER );
	}
	pval->offset += offset * pval->arraymul;
	return;
}

//------------------------------------------------
// 
//------------------------------------------------

//##########################################################
//    代入処理エミュレート
//##########################################################

//------------------------------------------------
// 連続代入 (通常)
// 
// @ 1つ目の代入は終了しているとする
// @ 代入する値がない => do nothing
//------------------------------------------------
void code_assign_multi( PVal* pval )
{
	if ( !code_isNextArg() ) return;
	
	HspVarProc* pHvp = exinfo->HspFunc_getproc( pval->flag );
	
	int      len1 = pval->len[1];
	APTR     aptr = pval->offset;
	APTR baseaptr = (len1 == 0 ? aptr : aptr % len1);	// aptr = 一次元目の添字 + baseaptr が成立
	
	aptr -= baseaptr;

	while ( code_isNextArg() ) {
		int prm = code_getprm();					// 次に代入する値を取得
		if ( prm != PARAM_OK ) puterror( HSPERR_SYNTAX );
	//	if ( !(pval->support & HSPVAR_SUPPORT_ARRAYOBJ) && pval->flag != mpval->flag ) {
	//		puterror( HSPERR_INVALID_ARRAYSTORE );	// 型変更はできない
	//	}
		
		baseaptr ++;

		pval->arraycnt = 0;							// 配列指定カウンタをリセット
		pval->offset   = aptr;
		code_index_int_lhs( pval, baseaptr );		// 配列チェック

		// 代入
		PVal_assign( pval, mpval->pt, mpval->flag );
	}
	
	return;
}

//##########################################################
//    その他
//##########################################################
//------------------------------------------------
// 引数が続くかどうか
// 
// @ 命令形式、関数形式どちらでもＯＫ
//------------------------------------------------
bool code_isNextArg(void)
{
	return !( *exinfo->npexflg & EXFLG_1 || ( *type == TYPE_MARK && *val == ')' ) );
}

//------------------------------------------------
// 次の引数を読み飛ばす
// 
// @ exflg をなんとかしようとしてみる。
// @ result : PARAM_* (code_getprm と同じ)
//------------------------------------------------
int code_skipprm(void)
{
	int& exflg = *exinfo->npexflg;
	
	// 終了, or 省略
	if ( exflg & EXFLG_1 ) return PARAM_END;	// パラメーター終端
	if ( exflg & EXFLG_2 ) {					// パラメーター区切り(デフォルト時)
		exflg &= ~EXFLG_2;
		return PARAM_DEFAULT;
	}
	
	if ( *type == TYPE_MARK ) {
		// パラメーター省略時('?')
		if ( *val == 63 ) {
			code_next();
			exflg &= ~EXFLG_2;
			return PARAM_DEFAULT;
			
		// 関数内のパラメーター省略時
		} else if ( *val == ')' ) {
			exflg &= ~EXFLG_2;
			return PARAM_ENDSPLIT;
		}
	}
	
	// 引数の読み飛ばし処理
	for ( int lvBracket = 0; ; ) {
		if ( *type == TYPE_MARK ) {
			if ( *val == '(' ) lvBracket ++;
			if ( *val == ')' ) lvBracket --;
		}
		code_next();
		
		if ( lvBracket == 0
			&& ( exflg & EXFLG_1 || exflg & EXFLG_2 || *type == TYPE_MARK && *val == ')' )
		) {
			break;
		}
	}
	
	if ( exflg ) exflg &= ~EXFLG_2;
	
	// 終了
	if ( *type == TYPE_MARK && *val == ')' ) {
		return PARAM_SPLIT;
		
	} else {
		return PARAM_OK;
	}
}

//##########################################################
//    OpenHSP からの引用
//##########################################################
