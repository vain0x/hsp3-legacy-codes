// varinfo dllhpi

#include <windows.h>
#include "hsp3plugin.h"
#include "varinfo.h"

//------------------------------------------------
// 変数情報の取得
//------------------------------------------------
EXPORT int WINAPI varinfo(PVal *pvTarget, int type, HSPEXINFO *pExinfo)
{
	::exinfo = pExinfo;
	
	switch ( type ) {
		case VARINFO_LEN0: return pvTarget->len[0];
		case VARINFO_LEN1: return pvTarget->len[1];
		case VARINFO_LEN2: return pvTarget->len[2];
		case VARINFO_LEN3: return pvTarget->len[3];
		case VARINFO_LEN4: return pvTarget->len[4];
		case VARINFO_FLAG: return pvTarget->flag;
		case VARINFO_MODE: return pvTarget->mode;
		case VARINFO_PTR: {
			HspVarProc *phvp = getproc( pvTarget->flag );
			return reinterpret_cast<int>( phvp->GetPtr(pvTarget) );
		}
		default:
			puterror( HSPERR_ILLEGAL_FUNCTION );

			//puterror が例外を投げるのでこれ以降は実行されない。
			//「値を返さない実行経路がある」という警告を抑制する。
			throw;
	}
}
