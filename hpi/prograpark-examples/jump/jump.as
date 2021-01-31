// jump - public header

#ifndef __JUMP_HPI_AS__
#define __JUMP_HPI_AS__

#regcmd "_hsp3hpi_init@4", "jump.hpi"
#cmd jump 0x000

// サンプル・スクリプト
#if 1

	mes "サンプル開始"
	
	lb_a = *a
	lb_b = *b
	
	jump *a
	jump *a, res
	mes      res   +"    "+ refstr
	mes jump(lb_a) +"    "+ refstr
	mes jump(lb_b)
	mes "π ≒ "+ jump(lb_b)
	
	mes "サンプル終了"
	stop
	
*a
	mes "*a"
	return "str : *a's result string."
	
*b
	mes "*b"
	return 3.141592		// 実数もＯＫ
	
#endif

#endif


