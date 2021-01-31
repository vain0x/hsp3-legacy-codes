//
//		HSP3.2 ex-runtime SDK main (windows)
//		原版: onion software/onitama 2004/9
//		修正: uedai (2010 10/02)
//

#ifdef HSPEXRT

#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include "hsp3exrt.h"

/*------------------------------------------------------------*/
/*
		system data
*/
/*------------------------------------------------------------*/

namespace HspExPlugin
{

//##############################################################################
//                グローバル変数の定義
//##############################################################################
int p1, p2, p3, p4, p5, p6;
int* type;
int* val;

PVal*      mpval;	// Master PVal pointer
HSPCTX*    ctx;		// Current Context
HSPEXINFO* exinfo;	// Info for Plugins

//##############################################################################
//                グローバル関数の定義
//##############################################################################
void hsp3sdk_init( HSP3TYPEINFO *info )
{
	//		SDK初期化
	//
	ctx    = info->hspctx;
	exinfo = info->hspexinfo;
	type   = exinfo->nptype;
	val    = exinfo->npval;
	return;
}


int code_getprm( void )
{
	//		パラメーターを取得(型は問わない)
	//
	int res = exinfo->HspFunc_prm_get();
	mpval = *exinfo->mpval;
	return res;
}


void bms_send( BMSCR *bm, int x, int y, int sx, int sy )
{
	//		ウインドゥ画面の更新
	//
	HDC hdc;
	HPALETTE opal;
	if ( bm->fl_udraw == 0) return;
	hdc = GetDC( bm->hwnd );
	if ( bm->hpal != NULL ) {
		opal = SelectPalette( hdc, bm->hpal, 0 );
		RealizePalette( hdc );
	}
	BitBlt( hdc, x - bm->viewx, y - bm->viewy, sx, sy, bm->hdc, x, y, SRCCOPY );
	if ( bm->hpal != NULL ) {
		SelectPalette( hdc, opal, 0 );
	}
	ReleaseDC( bm->hwnd,hdc );
	return;
}


}; /* namespace HspExPlugin */

#endif
