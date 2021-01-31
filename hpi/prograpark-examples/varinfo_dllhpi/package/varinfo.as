// varinfo - public header

#ifndef __VARINFO_HPI_AS__
#define __VARINFO_HPI_AS__

#uselib "varinfo.hpi"
#cfunc global varinfo "_varinfo@12" pval,int,  pexinfo

// 定数
#enum global VARINFO_LEN0 = 0
#enum global VARINFO_LEN1
#enum global VARINFO_LEN2
#enum global VARINFO_LEN3
#enum global VARINFO_LEN4
#enum global VARINFO_FLAG
#enum global VARINFO_MODE
#enum global VARINFO_PTR
#enum global VARINFO_MAX

// サンプル・スクリプト
#if 1
	// 本当はもっと入念にテストしてください (>_<;
	
	a = 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
	
	mes "len1 : "+   length(a)   +"\t: "+ varinfo(a(1), VARINFO_LEN1)
	mes "len2 : "+  length2(a)   +"\t: "+ varinfo(a(1), VARINFO_LEN2)
	mes "len3 : "+  length3(a)   +"\t: "+ varinfo(a(1), VARINFO_LEN3)
	mes "len4 : "+  length4(a)   +"\t: "+ varinfo(a(1), VARINFO_LEN4)
	mes "ptr  : "+  varptr(a(1)) +"\t: "+ varinfo(a(1), VARINFO_PTR )
	mes "flag : "+ vartype(a(1)) +"\t: "+ varinfo(a(1), VARINFO_FLAG)
	mes "mode : "+ "----"        +"\t: "+ varinfo(a(1), VARINFO_MODE)
	
	stop
	
#endif
