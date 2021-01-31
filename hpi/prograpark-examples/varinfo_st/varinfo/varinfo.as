// varinfo - public header

#ifndef __VARINFO_HPI_AS__
#define __VARINFO_HPI_AS__

#regcmd "_hsp3hpi_init@4", "varinfo.hpi"
#cmd   varinfo 0x000

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

//######## サンプル・スクリプト ########
#if 1
	// 本当はもっと入念にテストしてください (>_<;
	
	a = 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
	varinfo a(1), info
	
	mes "len1 : "+   length(a)   +"\t: "+ info(VARINFO_LEN1) +"\t: "+ varinfo(a(1), VARINFO_LEN1)
	mes "len2 : "+  length2(a)   +"\t: "+ info(VARINFO_LEN2) +"\t: "+ varinfo(a(1), VARINFO_LEN2)
	mes "len3 : "+  length3(a)   +"\t: "+ info(VARINFO_LEN3) +"\t: "+ varinfo(a(1), VARINFO_LEN3)
	mes "len4 : "+  length4(a)   +"\t: "+ info(VARINFO_LEN4) +"\t: "+ varinfo(a(1), VARINFO_LEN4)
	mes "ptr  : "+  varptr(a(1)) +"\t: "+ info(VARINFO_PTR ) +"\t: "+ varinfo(a(1), VARINFO_PTR )
	mes "flag : "+ vartype(a(1)) +"\t: "+ info(VARINFO_FLAG) +"\t: "+ varinfo(a(1), VARINFO_FLAG)
	mes "mode : "+ info(VARINFO_MODE) +"\t: "+ varinfo(a(1), VARINFO_MODE)
	
	stop
	
#endif
