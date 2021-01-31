// exstrf.hpi - public header

#ifndef IG_EXSTRF_HPI_AS
#define IG_EXSTRF_HPI_AS

#regcmd "_hsp3hpi_init@4", "exstrf.hpi"
#cmd exstrf 0x000

// サンプル・スクリプト
#if 1

// %v : 値
// %p : 変数アドレス
// %c : 文字
	
	x = 1 + 2
	mes exstrf( "%v + %v = %v", 1, 2, x )
	mes exstrf( "%vの%vなんて%vで%vさ！", "文字列", "連結", "exstrf", "楽勝" )
	mes exstrf( "%c%c%c%c%c, world%c", 'H', 'e', 'l', 'l', 'o', '!' )
	mes exstrf( "&x = %p = %v", x, varptr(x) )
	mes
	
	// 命令形式で使う
	
	exstrf "%v + %v = %v", 1, 2, 1 + 2
	mes refstr
	exstrf "%vの%vなんて%vで%vさ！", "文字列", "連結", "exstrf", "楽勝"
	mes refstr
	
	stop
	
#endif

#endif
