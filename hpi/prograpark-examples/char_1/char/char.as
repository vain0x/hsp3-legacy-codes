// char - public header

#ifndef __CHAR_HPI_AS__
#define __CHAR_HPI_AS__

#regcmd "_hsp3hpi_init@4", "char.hpi", 1
#cmd char 0x000

// サンプル・スクリプト
#if 0

;	char c(14)		// char c[14];
	char c, 14		// dim 的用法
	
	c = char('x')	// 'x' は int 型なので、変換して代入する
	mes c			// char('1')->str("1") に自動変換
	
	c(0) = char( 72), char(101), char(108), char(108), char(111), char(44), char(32), char(119)
	c(8) = char(111), char(114), char(108), char(100), char(33)
	sdim s
	foreach c
		s += c(cnt)	// char -> str に変換してから s に連結
	loop
	mes s
	
	stop
	
#endif

#endif
