// exstrf - command

#include <cstdio>
#include <cstring>
#include <string>
#include "cmd.h"

//------------------------------------------------
// HSPの値を文字列に変換する
//------------------------------------------------
static char const * ConvertToStr(PDAT const *pt, int flag) {
	// 文字列型の場合
	if ( flag == HSPVAR_FLAG_STR ) {
		return reinterpret_cast<char const *>(pt);

	// 組み込み型の場合
	// str の HspVarProc::Cnv で変換する
	} else if ( flag < HSPVAR_FLAG_USERDEF ) {
		HspVarProc* vp = exinfo->HspFunc_getproc(HSPVAR_FLAG_STR);
		return reinterpret_cast<char const*>( vp->Cnv(pt, flag) );

	// プラグインによる拡張型
	// HspVarProc::CnvCustom で変換する
	} else {
		HspVarProc *vp = exinfo->HspFunc_getproc(flag);
		return reinterpret_cast<char const*>(vpSrc->CnvCustom(pt, HSPVAR_FLAG_STR));
	}
}

//------------------------------------------------
// フォーマット解析
// 
// return     : 書き込んだ文字数 [byte]
// psResult   : 書き込み先
// formatChar : フォーマット指定文字
//------------------------------------------------
static int ParseFormat( char *psResult, const char formatChar )
{
	switch ( formatChar ) {
		// "%%"
		// 1つの "%" に変換する
		case '%':
			psResult[0] = '%';
			return 1;

		// 値
		case 'v':
		{
			// 次のパラメーターを任意の型で取得する
			int const prm = code_getprm();
			if ( prm <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );

			// 受け取った値を str 型に変換する
			char const *str = ConvertToStr(reinterpret_cast<PDAT*>(mpval->pt), mpval->flag);

			// バッファに書き込む
			int len = strlen( str );
			strncpy( psResult, str, len );
			return len;
		}

		// 変数アドレス
		case 'p':
		{
			// 変数を受け取る
			PVal *pval;
			code_getva( &pval );

			// 変数のポインタを取得 (varptr と同じ)
			HspVarProc *vp = exinfo->HspFunc_getproc( pval->flag );
			void *ptr = vp->GetPtr( pval );

			// 書き込む
			return sprintf( psResult, "%p", ptr );
		}

		// 文字
		case 'c':
			psResult[0] = code_getdi(0);
			return 1;

		// エラー (無視！)
		default:
			return 0;
	}
}

//------------------------------------------------
// exstrf 関数
//------------------------------------------------
char *exstrf(void)
{
	// 返却する文字列用のバッファ
	static char *stt_psResult = nullptr;
	if ( !stt_psResult ) {
		stt_psResult = (char *)hspmalloc( HSPCTX_REFSTR_MAX * sizeof(char) );
	}

	// 第一引数(文字列のフォーマット)を取得
	std::string strFormat = code_gets();

	// フォーマットを解析
	int iWrote = 0; // stt_psResult に書き込んだ数
	for ( int i = 0; ; ++i ) {
		char c = strFormat[i];
		if ( c == '%' ) {
			i ++;

			// % の後ろを解析する
			iWrote += ParseFormat( &stt_psResult[iWrote], strFormat[i] );

		} else {
			stt_psResult[iWrote] = c;
			iWrote ++;
			if ( c == '\0' ) break;
		}
	}
	return stt_psResult;
}
