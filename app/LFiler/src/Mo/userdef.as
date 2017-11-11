// userdef
// "hspdef.as" の末尾で #addition するように変更する

#ifndef        IG_USERDEF_HEADER_AS
#define global IG_USERDEF_HEADER_AS

#define global __userdef__

//標準命令用定数値
#define global ctype mref_param(%1) (%1)
#define global mref_stat 64
#define global mref_refstr 65
#define global mref_vram 66
#define global mref_current_screen 67
#define global mref_ctx 68
#define global mref_palette 69
#define global ctype mref_screen(%1) (96 + (%1))

#define global noteadd_add 0
#define global noteadd_overwrite 1

#define global getpath_filename 1
#define global getpath_ext 2
#define global getpath_exclude_dir 8
#define global getpath_tolower 16
#define global getpath_dir 32

#define global strtrim_head 1
#define global strtrim_tail 2
#define global strtrim_everywhere 3

#define global gsel_hide -1
#define global gsel_none 0
#define global gsel_show 1
#define global gsel_topmost 2

#define global redraw_off 0
#define global redraw_on 1
#define global redraw_nopaint 2

#define global mesbox_disable 0
#define global mesbox_enable 1
#define global mesbox_vscroll 0
#define global mesbox_hscroll 4

#define global exec_normal 0
#define global exec_minimized 2
#define global exec_application 16
#define global exec_print 32

#define global dialog_ok 0
#define global dialog_warn 1
#define global dialog_yesno 2
#define global dialog_open 16
#define global dialog_save 17
#define global dialog_color 32
#define global dialog_colorex 33

#define global hsptv_up_clearscore 0x1000
#define global hsptv_up_anonymous 0x2000

#define global gettime_year gettime(0)
#define global gettime_month gettime(1)
#define global gettime_wday gettime(2)// from struct tm
#define global gettime_mday gettime(3)
#define global gettime_hour gettime(4)
#define global gettime_min gettime(5)
#define global gettime_sec gettime(6)
#define global gettime_millsec gettime(7)

//色設定
#define self
#undef  self
#define which// for opex.hpi
#undef  which
#define what
#undef  what
#define nullmod// for call.hpi
#undef  nullmod
#define global global
#undef  global
#define ctype ctype
#undef  ctype

#define global NULL     0
#ifndef __clhsp__
 #define global true    1
 #define global false   0
 #define global success 1
 #define global failure 0
#endif
#define global MAX_INT  0x7FFFFFFF//  2147483647
#define global MIN_INT  0x80000000// -2147483648
#define global MAX_PATH 260
#define global INFINITY (logf@hsp(0))

//actually helpers
#define global elsif else : if
#define global delfile delete
#define global gradf2(%1 = 0, %2 = 0, %3, %4, %5 = 0, %6, %7) gradf (%1), (%2), (%3) - (%1), (%4) - (%2), (%5), (%6), (%7)
#define global mousex2 (ginfo_mx - (ginfo_wx1 + (ginfo_sizex - ginfo_winx) / 2))
#define global mousey2 (ginfo_my - (ginfo_wy1 + (ginfo_sizey - ginfo_winy) - (ginfo_sizex - ginfo_winx) / 2))

#ifdef _DEBUG
 #define global dir_exe2 dir_exe@__debug
 dir_exe2 = dir_cur
#else //defined(_DEBUG)
 #define global dir_exe2 dir_exe
#endif //defined(_DEBUG)

//others
#define global ctype unless(%1) if ((%1) == 0) : else
#define global do_not if (0)
#define global pseudomodule %t_pseudomodule goto *%i@
#define global pseudoglobal %t_pseudomodule *%o@
#define global _procfunc(%1) __procfunc_result@_userdef = (%1)// do_func
#define global TwoSet(%1,%2=0,%3,%4) %1(%2,0) = %3 : %1(%2,1) = %4// %1(%2, 0) と %1(%2, 1) に %3,%4 を代入する
#define global IntSwap(%1,%2) if((%1)!=(%2)){%1 ^= %2 : %2 ^= %1 : %1 ^= %2}//int型の %1 と %2 を交換する
;#define global PMSwap(%1,%2) if(%1!=%2){%1 += %2 : %2 = %1 - %2 : %1 -= %2}// 加減算で交換する
#define global dupmv(%1,%2) dupptr %1, varptr(%2), 16 * length(%2), vartype("struct")
#define global delmodall(%1) foreach %1 : delmod %1(cnt) : loop
#define global ctype isValidEnum(%1,%2) isInRange(%1, %2_None, %2_Max - 1)
#define global ctype isInRect(%1=RECT,%2=mousex,%3=mousey) ( boxin((%1(0)), (%1(1)), (%1(2)), (%1(3)), (%2), (%3)) )
#define global ctype RectTo4prm(%1) %1(0), %1(1), %1(2), %1(3)// splatRect
#define global SetStyle(%1,%2=-16,%3=0,%4=0) SetWindowLong (%1),(%2),BITOFF(GetWindowLong((%1),(%2)) | (%3), (%4))
#define global ChangeVisible(%1=hwnd,%2=1) SetStyle (%1), -16, 0x10000000 * (%2), 0x10000000 * ((%2) == 0)// Visible 切り替え

// 数値操作マクロ
#define global ctype MAKELONG(%1,%2) (LOWORD(%1) | (LOWORD(%2) << 16))
#define global ctype MAKELONG2(%1=0,%2=0,%3=0,%4=0) MAKELONG(MAKEWORD((%1),(%2)),MAKEWORD((%3),(%4)))
#define global ctype HIWORD(%1) (((%1) >> 16) & 0xFFFF)
#define global ctype LOWORD(%1) ((%1) & 0xFFFF)
#define global ctype BITOFF(%1,%2=0) ((%1) & bturn(%2))
#define global ctype RGB(%1,%2,%3) (LOBYTE(%1) | LOBYTE(%2) << 8 | LOBYTE(%3) << 16)
#define global ctype pow_2(%1) (1 << ((%1) - 1))
;#define global ctype to32b_from16b(%1) cond_i( (%1) & 0x8000, 0 - ((%1) ^ 0xFFFF) - 1, (%1) )
;#define global ctype complementOf2(%1) (bturn(%1) + 1)		// 2 の補数

#define global ctype MAKEWORD(%1,%2) (LOBYTE(%1) | LOBYTE(%2) << 8)
#define global ctype HIBYTE(%1) LOBYTE((%1) >> 8)
#define global ctype LOBYTE(%1) ((%1) & 0xFF)
#define global ctype bturn(%1) ((%1) ^ -1)
#define global ctype byteAt(%1,%2=0) LOBYTE((%1) >> ((%2) * 8))
#define global ctype bitAt(%1,%2=0) (((%1) >> (%2)) & 1)

#define global GetAByte byteAt
#define global GetABit bitAt
#define global GETBYTE LOBYTE
#define global do_not_bgn pseudomodule
#define global do_not_end pseudoglobal

// メタ関数
#define global _empty// empty
#define global ctype _rm(%1)/*%1*/
#define global ctype _cat(%1,%2)%1%2
#define global ctype _cat3(%1,%2,%3)%1%2%3
#define global ctype _cat_scope(%1,%2)_cat3(%1,@,%2)

#define global ctype _list_1(%1 = _empty)                                                                                                         %1
#define global ctype _list_2(%1 = _empty, %2 = _empty)                                                                                            %1, %2
#define global ctype _list_3(%1 = _empty, %2 = _empty, %3 = _empty)                                                                               %1, %2, %3
#define global ctype _list_4(%1 = _empty, %2 = _empty, %3 = _empty, %4 = _empty)                                                                  %1, %2, %3, %4
#define global ctype _list_5(%1 = _empty, %2 = _empty, %3 = _empty, %4 = _empty, %5 = _empty)                                                     %1, %2, %3, %4, %5
#define global ctype _list_6(%1 = _empty, %2 = _empty, %3 = _empty, %4 = _empty, %5 = _empty, %6 = _empty)                                        %1, %2, %3, %4, %5, %6
#define global ctype _list_7(%1 = _empty, %2 = _empty, %3 = _empty, %4 = _empty, %5 = _empty, %6 = _empty, %7 = _empty)                           %1, %2, %3, %4, %5, %6, %7
#define global ctype _list_8(%1 = _empty, %2 = _empty, %3 = _empty, %4 = _empty, %5 = _empty, %6 = _empty, %7 = _empty, %8 = _empty)              %1, %2, %3, %4, %5, %6, %7, %8
#define global ctype _list_9(%1 = _empty, %2 = _empty, %3 = _empty, %4 = _empty, %5 = _empty, %6 = _empty, %7 = _empty, %8 = _empty, %9 = _empty) %1, %2, %3, %4, %5, %6, %7, %8, %9

#define global _comma ,
#define global _colon :

#define global __here__ ("#" + __line__ + " " + __file__)

//---- switch --------------------------------
#undef switch
#undef case
#undef default
#undef swend
#undef swbreak

// %p0: 比較元の値を持つ変数
// %p1: swend へのラベル
// %p2: switch の先頭へのラベル (for: swcontinue)
// %p3: switch の先頭へのラベル (for: swredo)
#define global switch(%1=true) %tswitch %i0 %i0 %i0 %i0  swthis_bgn(%p) swdefault_init : *%p2 : %p = (%1) : *%p3 : if ( 0 ) {
#define global case(%1)     %tswitch %i0 goto *%p } if ( (%p1) == (%1) ) { *%o
#define global case_not(%1) %tswitch %i0 goto *%p } if ( (%p1) != (%1) ) { *%o
#define global case_if(%1)  %tswitch %i0 goto *%p } if ( (%1) ) { *%o
#define global default      %tswitch } swdefault_place_default : if ( 1 ) {
#define global swend        %tswitch } swdefault_place_swend : %o0 *%o %o0 %o0 : swthis_end swdefault_term
#define global swbreak      %tswitch goto *%p1
#define global swcontinue   %tswitch goto *%p2					// 再分岐 (比較値を更新)
#define global swredo       %tswitch goto *%p3					// 再分岐 (比較値は同じ)
#define global go_case(%1)  %tswitch %p = (%1) : swredo			// 比較値を変更して再分岐
#define global go_default   %tswitch goto swdefault_label		// default があればそこに、なければ swend に飛ぶ
//	#define global swthis       %tswitch (%p)

#define global xcase    swbreak : case
#define global xdefault swbreak : default

// swthis を、switch とは別のスタックにも設定しておく
// %p: 比較元の値を持つ変数 (switchから与えられる)
#define global ctype swthis_bgn(%1) %tswitch_this %s1
#define global swthis     %tswitch_this %p
#define global swthis_end %tswitch_this %o0

// default 用のラベルスタック (かなり複雑)
// 生成する2つのユニーク識別子を A, B とする。
// 最初、A, B, A の順にスタックに積まれる ({ %p: A, %p1: B, %p2: A })。
// @ %p2 の A は swdefault_label で参照するため。
// default があるとき:
// @	1. A が default に配置・除去される。B がスタック上に積まれる ({ %p: B, %p1: B, %p2: A })。
// @	2. 一番上の B が swend に配置される。残り2つはそのまま取り除かれる。
// default がないとき: 
// @	1. 一番上の A が swend に配置される。残り2つはそのまま取り除かれる。
// ∴A (swdefault_label) は default があるとき default を、ないときは swend (エラー部分) を指す。
#define global swdefault_init          %tswitch_default %i0 %i0 swdefault_push(%p1)		// [ A, B, A ] を積む
#define global swdefault_term          %tswitch_default %o0 %o0 %o0
#define global swdefault_place_default %tswitch_default *%o : swdefault_push(%p)		// A を配置して除去, B を doubling-push
#define global swdefault_place_swend   %tswitch_default do_not { *%p : logmes@hsp "go_default error: default doesn't exist.\n\t" + __HERE__ : assert@hsp }
#define global swdefault_label         %tswitch_default *%p2

#define global ctype swdefault_push(%1) %tswitch_default %s1

#module  _userdef_cleanup
#ifdef _DEBUG
#deffunc _userdef_cleanup_sttm onexit
	remove_file_if_exists "obj"
	remove_file_if_exists "hsptmp"
 #ifdef __hsp3_uedit__
	remove_file_if_exists "hsptmp-axi.txt"
 #endif
	return
#endif
#deffunc remove_file_if_exists str path
	exist path : if (strsize >= 0) { delfile path }
	return
#global

// 元々マクロだったもの
#module
#define global ctype isInRange(%1,%2=0,%3=MAX_INT) isInRange__userdef(%1,%2,%3)// %1 が区間 [%2, %3) 内か否か
#define global numrg isInRange
#define global isRange isInRange
#defcfunc isInRange__userdef int self, int min_, int max_
	return (min_ <= self && self <= max_)
#global
#module
#define global ctype boxin(%1= 0, %2 = 0, %3 = 640, %4 = 480, %5 = mousex, %6 = mousey) boxin__userdef(%1,%2,%3,%4,%5,%6);( (((%1) <= (%5)) && ((%5) <= (%3))) && (((%2) <= (%6)) && ((%6) <= (%4))) )
#defcfunc boxin__userdef int x1, int y1, int x2, int y2,  int px, int py
	return (x1 <= px && px <= x2) && (y1 <= py && py <= y2)
#global

#module
#defcfunc major_i int lhs, int rhs
	if (lhs < rhs) { return rhs } else { return lhs }
#defcfunc minor_i int lhs, int rhs
	if (lhs > rhs) { return rhs } else { return lhs }
#defcfunc major_d double lhs, double rhs
	if (lhs < rhs) { return rhs } else { return lhs }
#defcfunc minor_d double lhs, double rhs
	if (lhs > rhs) { return rhs } else { return lhs }
#global

#module
///set current color decomposing RGB
#deffunc color32 int cref
	color LOBYTE(cref), LOBYTE(cref >> 8), LOBYTE(cref >> 16)
	return
#global

//[[deprecated]]
#define global GetHigh !!"deprecated: GetHigh -> HIWORD"!!
#define global GetLow  !!"deprecated: GetLow  -> LOWORD "!!
#define global bitnum !!"deprecated: bitnum(n) = (1 << n) = pow_2(n + 1)"!!
#define global cwhich_int !!{"deprecated: #include "Mo/cwhich.as""}!!
#define global IsPositive !!"deprecated: IsPositive(x) = (x > 0)"
#define global IsNegative !!"deprecated: IsNegative(x) = (x < 0)"
#define global Lim !!"deprecated: lim -> numrg"!!
#define exdel !!"deprecated: exdel -> removeFileIfExist"!!
#define global maxval !!"deprecated: maxval -> major_i or major_d"!!
#define global minval !!"deprecated: minval -> minor_d or minor_d"!!
#define global to32b_from16b !!"deprecated"!!
#define global _nowtime !!"deprecated: use benchmark"!!
#define global vtname !!"deprecated: renamed to varTypeName"!!
#define global defvar !!"deprecated: renamed to declvar"!!

#endif // !defined(__userdef__)
