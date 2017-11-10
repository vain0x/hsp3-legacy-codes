// call - for sample header

// サンプルのためのヘッダ

#ifndef        IG_CALL_FOR_SAMPLE_AS
#define global IG_CALL_FOR_SAMPLE_AS

#include "call.as"
#include "call_modcls.as"

// マクロ
#ifndef __userdef__
	#define global do_not if ( 0 )
	#define global assert_sentinel logmes "assert sentinel " + __HERE__ : assert : end
	
	// デバッグ用
	#ifdef  _DEBUG
	 #define global DbgBox(%1) dialog (%1), 2, ("DbgBox Line\t= " + __LINE__ + "\nFILE\t = " + __FILE__) : if ( stat == 7 ) { dialog "停止しました" : assert 0 }
	 #define global ctype dbgstr(%1) ({"%1 = "} + (%1))
	 #define global ctype dbgpair(%1,%2) ({"(%1,%2) = ("} + (%1) + ", " + (%2) + ")")
	 #define global ctype dbghex(%1) strf({"%1 = 0x%%08X"}, (%1))
	 #define global ctype dbgchar(%1) strf({"%1 = '%%c'"}, (%1))
	 #define global ctype dbgcode(%1 = _empty, %2 = _empty) (%1)
	#else
	 #define global DbgBox(%1) :
	 #define global ctype dbgstr(%1) ""
	 #define global ctype dbgpair(%1,%2) ""
	 #define global ctype dbghex(%1) ""
	 #define global ctype dbgchar(%1) ""
	 #define global ctype dbgcode(%1 = _empty, %2 = _empty) (%2)
	#endif
	
	#define global __HERE__ (__FILE__ + " (#" + __LINE__ + ")")
	#define global true    1	// 非0
	#define global false   0	//   0
#endif

// サンプルクラス
// 値 value を持つ。name, bDup は分かりやすくするため。
#module Test value,  name, bDup

#modinit int _value, str _name, int _bDup
	bDup = _bDup
	name = _name
	if ( _name == "" ) { name = "instance" }
	test_set thismod, _value
	
	mes "new >> " + name + ": " + value + " $" + bDup
	return
	
#modterm
	mes "del << " +  name + ": " + value + " $" + bDup
	wait 60
	return
	
#modfunc test_set int x
	value = x
	return
	
#modcfunc test_get
	return value
	
#modcfunc test_getName
	return name
	
// 複製関数
// @ 変数 x を thismod の複製にする。
// @ つまり、同じ値を持つ ( == が成り立つ ) ようなインスタンスを新たに作ればよい。
#modfunc test_dup_fact var x
	newmod x, Test@, value, name + "'", true
	return
	
// 演算関数
// @ thismod を、それと入力変数を演算して得られる値にする。
// @ 「+=」などのときに、対応する関数が呼ばれる。
// @ 「+」などの複号代入でない二項演算を行うには、複製関数が定義されている必要がある。
// @ (「a + b」は「a2 = dupmod(a) : a2 += b : return a2」として処理される。)
#modfunc test_add var x
	mes strf("add: %d(%s) + %d(%s)", value, name, test_get(x), test_getName(x))
	value += test_get(x)
	return
	
#modfunc test_mul var x
	mes strf("mul: %d(%s) * %d(%s)", value, name, test_get(x), test_getName(x))
	value *= test_get(x)
	return
	
#modfunc test_pow var x
	mes strf("pow: %d(%s) ^ %d(%s)", value, name, test_get(x), test_getName(x))
	value = int( powf( value, test_get(x) ) )
	return
	
// 比較関数
// thismod と x の大小を調べて、対応する整数値(int)を返却する。
// 0. thismod == x → 0
// 1. thismod <  x → 負
// 2. thismod >  x → 正
// opId は、実際に比較に使われる演算子の opId 。opId_Lt(<) など。
// 絶対に x は nullmod でない。
#modcfunc test_cmp var x, int opId
	mes strf("cmp: %d(%s) <> %d(%s)", value, name, test_get(x), test_getName(x))
	return value - test_get(x)
	
// 型変換関数
#modcfunc test_toInt int flag
	return int(value)
	
#modcfunc test_toStr int flag
	return str(value)
	
#modcfunc test_toDouble int flag
	return double(value)
	
// メソッド分散関数
// thismod->method a, b, c, ... というメソッド呼び出しの際に呼ばれる。
// @ 与えられた文字列 method に対応する関数子を返却する。
// @ → そうしたら、そのメソッドに引数 thismod, a, b, c, ... が与えられて呼び出される。
// @ 無効な値を返した場合は、その文字列に対応するメソッドがなかったということにする。
#modfunc test_method str method
	switch ( method )
		case "print": return axcmdOf( test_method_print )
		case "times": call_return *test_method_times
	swend
	return 0
	
// メソッド実行関数
// @ #modfunc でなければいけない。
// @ ラベルを使うには、第一引数を PRM_TYPE_MODVAR で宣言しなければいけない。
#modfunc test_method_print
	mes name + " = " + value
	return
	
#modfunc test_method_times__ int n, var proc
*test_method_times
	assert( vartype(proc) == functor || vartype(proc) == vartype("label") || vartype(proc) == vartype("int") )
	repeat n
		call proc
	loop
	return
	
// 登録
#deffunc test_init
	modcls_register Test, OpId_Add, test_add		// +
	modcls_register Test, OpId_Mul, test_mul		// *
	modcls_register Test, OpId_Xor, test_pow		// ^
	
	modcls_register Test, OpId_Dup, test_dup_fact	// 複製関数
	modcls_register Test, OpId_Cmp, test_cmp		// 比較関数
	
	modcls_register Test, OpId_ToStr,    test_toStr		// str()
	modcls_register Test, OpId_ToDouble, test_toDouble	// double()
	modcls_register Test, OpId_ToInt,    test_toInt		// int()
	
	modcls_register Test, OpId_Method, test_method	// メソッド分散関数
	
	// その他の宣言
	call_dec *test_method_times, PRM_TYPE_MODVAR, "int", "any"		// cf. ex10, ex11
	return
	
#global
	test_init
	
#endif
