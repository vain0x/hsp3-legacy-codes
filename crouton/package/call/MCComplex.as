// 複素数クラス

#ifndef IG_MODULECLASS_COMPLEX_AS
#define IG_MODULECLASS_COMPLEX_AS

#include "call_modcls.as"

#module MCComplex mSize, mArg

#define VAR_TEMP _stt_temp@MCComplex

#const  M_PI2 (M_PI * 2)
#define ctype RegularizeArg(%1) (((%1) \ M_PI2 + M_PI2) \ M_PI2)

//##########################################################
//                構築・解体
//##########################################################
//------------------------------------------------
// 構築
// 
// @ 初期値 (0.0, 0.0)
//------------------------------------------------
#deffunc complex_New array self
	newmod self, MCComplex@, 0, 0
	return
	
#modinit double size, double arg
	complex_SetArg  thismod, arg
	complex_SetSize thismod, size
	return
	
#deffunc complex_NewPoint array self, double size, double arg
	newmod self, MCComplex@, size, arg
	return
	
// 実数軸上
#deffunc complex_NewReal array self, double size
	complex_NewPoint self, size, 0.0
	return
	
// 単位円上
#deffunc complex_NewUnit array self, double arg
	complex_NewPoint self, 1, arg
	return
	
//------------------------------------------------
// 破棄
//------------------------------------------------
#deffunc complex_Delete var self
	delmod self
	return
	
//##########################################################
//                検索
//##########################################################

//##########################################################
//                取得
//##########################################################

//------------------------------------------------
// メンバの値の取得
//------------------------------------------------
// 極形式
#modcfunc complex_size
	return mSize
	
#modcfunc complex_arg
	return mArg
	
#modfunc complex_GetPolar var _size, var _arg
	_size = mSize
	_arg  = mArg
	return
	
// 直交座標
#modcfunc complex_re
	return cos(mArg) * mSize
	
#modcfunc complex_im  local tmp
	return sin(mArg) * mSize
	
#modfunc complex_GetRect var re, var im,  local size, local arg
	re = complex_re(thismod)
	im = complex_im(thismod)
	return
	
//------------------------------------------------
// メンバへの代入
//------------------------------------------------
#modfunc complex_SetSize  double size_,  local size, local vt
	
	if ( size_ == 0 ) {
		complex_Clear thismod
		return
		
	} elsif ( size_ < 0 ) {
		size = -size_			// 正
		complex_Minus thismod	// 負符号処理
		
	} else {
		size = size_
	}
	
	mSize = size
	return
	
#modfunc complex_SetArg double arg
	mArg = RegularizeArg(arg)
	return
	
#modfunc complex_SetRe double re
	complex_SetRect thismod, re, complex_im(thismod)
	return
	
#modfunc complex_SetIm double im
	complex_SetRect thismod, complex_re(thismod), im
	return
	
#modfunc complex_SetPolar double size, double arg
	if ( size == 0 ) {
		complex_Clear thismod
	} else {
		complex_SetSize thismod, size
		complex_SetArg  thismod, arg
	}
	return
	
#modfunc complex_SetRect double re, double im
	complex_SetPolar thismod, sqrt( re * re + im * im ), argof( re, im )
	return
	
//------------------------------------------------
// 偏角
//
// @ 原点から点 (x, y) に引いた有向線分の偏角
// @	ただし (x, y) = (0, 0) のとき 0.0
// @result: double [rad], 値域 [0, 2π)
//------------------------------------------------
#defcfunc argof@MCComplex double x, double y
	switch ( sgn(x) )		// x の符号で分岐
		case  0:
			switch ( sgn(y) )	// y の符号で分岐
				case 0:  return 0.0				// ・: 0
				case  1: return M_PI / 2		// ↑: (1/2)π
				case -1: return M_PI * 1.5		// ↓: (3/2)π
			swend
		case  1: return atan( y, x )
		case -1: return atan( y, -x ) + M_PI
	swend
	return
	
//------------------------------------------------
// 判定
//------------------------------------------------
#modcfunc complex_IsRe
	return ( mArg \ M_PI == 0 )
	
#modcfunc complex_IsIm
	return ( mArg \ M_PI != 0 )
	
//------------------------------------------------
// 型変換
//------------------------------------------------
#modcfunc complex_ToDouble
	if ( complex_IsRe(thismod) ) {
		return complex_re(thismod)
	} else {
		mSize(1) = ""	// 型不一致エラーを出させる
	}
	
#modcfunc complex_ToInt
	return int( complex_ToDouble(thismod) )
	
//##########################################################
//                演算
//##########################################################
//------------------------------------------------
// 負符号
//------------------------------------------------
#modfunc complex_Minus
	mArg = RegularizeArg( mArg + M_PI )
	return
	
//------------------------------------------------
// 平方根
// 
// @ //z = (r・e^(iθ))^(1/2) = (√r)・e^(i(θ/2))
//------------------------------------------------
#modfunc complex_Sqrt
	mSize = sqrt(mSize)		// 型が int -> double になる可能性があるためクローンしない
	mArg /= 2				// mArg/2 ∈ [0, 2π) より RegularizeArg 不要
	return
	
//------------------------------------------------
// 逆数(^-1)
// 
// @ /z = (r・e^(iθ))^(-1) = (r^-1)・e^(i(-θ))
//------------------------------------------------
#modfunc complex_Inv
	complex_SetSize   thismod, 1.0 / mSize
	complex_Conjugate thismod
	return
	
//------------------------------------------------
// 共役
//------------------------------------------------
#modfunc complex_Conjugate
	mArg = RegularizeArg( -mArg )
	return
	
//------------------------------------------------
// 加減
//------------------------------------------------
#modfunc complex_Add var rhs,  local lhsPair, local rhsPair
	ddim lhsPair, 2
	ddim rhsPair, 2
	complex_GetRect thismod, lhsPair(0), lhsPair(1)
	complex_GetRect rhs,     rhsPair(0), rhsPair(1)
	complex_SetRect thismod, lhsPair(0) + rhsPair(0), lhsPair(1) + rhsPair(1)
	return
	
#modfunc complex_Sub var rhs,  local lhsPair, local rhsPair
	ddim lhsPair, 2
	ddim rhsPair, 2
	complex_GetRect thismod, lhsPair(0), lhsPair(1)
	complex_GetRect rhs,     rhsPair(0), rhsPair(1)
	complex_SetRect thismod, lhsPair(0) - rhsPair(0), lhsPair(1) - rhsPair(1)
	return
	
//------------------------------------------------
// 乗除
//------------------------------------------------
#modfunc complex_MulWithReal double r		// 実数倍
	mSize = r * mSize
	return
	
#modfunc complex_Mul var rhs
	mSize = double( mSize ) * complex_size(rhs)
	mArg  = RegularizeArg( mArg + complex_arg(rhs) )
	return
	
#modfunc complex_Div var rhs
	mSize = double( mSize ) / complex_size(rhs)
	mArg = RegularizeArg( mArg - complex_arg(rhs) )
	return
	
//------------------------------------------------
// 冪
//------------------------------------------------
#modfunc complex_Pow var rhs,  local r, local t, local a, local b
	complex_GetPolar thismod, r, t
	complex_GetRect  rhs,     a, b
	
	complex_PowImpl thismod, r, t, a, b
	return
	
#modfunc complex_PowWithReal double x,  local r, local t
	complex_GetPolar thismod, r, t
	complex_PowImpl  thismod, r, t, x, 0	// 実数乗
	return
	
#modfunc complex_PowImpl double r, double t, double a, double b
	if ( r == 0 ) {
		if ( a == 0 && b == 0 ) {
			complex_SetPolar thismod, 1, 0
		} else {
			complex_Clear thismod
		}
	} else {
		complex_SetPolar thismod, ( powf(r, a) / expf(b * t) ), ( b * logf(r) + a * t )
	}
	return
	
#modfunc complex_Exp  local a, local b
	complex_GetRect  thismod, a, b
	complex_SetPolar thismod, expf(a), b	// e^(a + i b) = (e^a) * e^(i b)
	return
	
//------------------------------------------------
// 冪根
// 
// @ [lhs]√rhs = rhs^(/lhs) ということにする。
//------------------------------------------------
#modfunc complex_Root int rhs,  local r, local t, local a, local b, local s
	complex_GetPolar thismod, r, t
	complex_GetRect  rhs,  a, b
	
	// (a + ib) の逆数をとる
	s = (a * a + b * b)
	complex_PowImpl thismod, r, t, a / s, -b / s
	return
	
#modfunc complex_RootWithReal double x
	complex_PowWithReal thismod, 1.0 / x
	return
	
//------------------------------------------------
// 対数
//------------------------------------------------
#modcfunc complex_Log var base
	complex_SetRect thismod, logf(mSize - base), mArg / logf(base)
	return
	
#modcfunc complex_Ln double base
	complex_SetRect thismod, logf(mSize), mArg
	return
	
#modcfunc complex_LogWithReal double base
	complex_SetRect thismod, logf(mSize - base), mArg / logf(base)
	return
	
//------------------------------------------------
// 三角関数
// 
// @ tan x = (sin x) / (cos x)
//------------------------------------------------
#modfunc complex_Sin  local x, local y
	complex_GetRect thismod, x, y
	complex_SetRect thismod, sin(x) * cosh(y), cos(x) * sinh(y)
	return
	
#modfunc complex_Cos  local x, local y
	complex_GetRect thismod, x, y
	complex_SetRect thismod, cos(x) * cosh(y), - sin(x) * sinh(y)
	return
	
#modfunc complex_Tan  local x
	dupmod      thismod, x
	complex_Cos x
	complex_Sin thismod
	complex_Div thismod, x
	return
	
#defcfunc sinh@MCComplex double x
	return ( expf(x) - expf(-x) ) / 2
	
#defcfunc cosh@MCComplex double x
	return ( expf(x) + expf(-x) ) / 2
	
//------------------------------------------------
// 比較
// 
// @ テキトーに定める
// @result: 比較値
//------------------------------------------------
#modcfunc complex_Cmp var rhs, int opId
	return sgn(mSize - complex_size(rhs)) * 2 + sgn(mArg - complex_arg(rhs))
	
#defcfunc sgn@MCComplex double x
	return (x > 0) - (x < 0)
	
//##########################################################
//                コンテナ
//##########################################################
//------------------------------------------------
// 初期化
//------------------------------------------------
#modfunc complex_Clear
	mSize = 0
	mArg  = 0.0
	return
	
//------------------------------------------------
// 複製 Factory
//------------------------------------------------
#modfunc complex_DupFact var obj
	complex_New      obj
	complex_SetPolar obj, mSize, mArg
	return
	
//------------------------------------------------
// 登録
//------------------------------------------------
#deffunc complex_Register
	modcls_register MCComplex, OpId_Add, complex_Add
	modcls_register MCComplex, OpId_Sub, complex_Sub
	modcls_register MCComplex, OpId_Mul, complex_Mul
	modcls_register MCComplex, OpId_Div, complex_Div
;	modcls_register MCComplex, OpId_Mod, complex_Mod
	
	modcls_register MCComplex, OpId_Dup, complex_DupFact
	modcls_register MCComplex, OpId_Cmp, complex_Cmp
	
	modcls_register MCComplex, OpId_ToInt,    complex_ToInt
	modcls_register MCComplex, OpId_ToDouble, complex_ToDouble
	
	// 定数
	complex_NewUnit complex_i@, M_PI / 2		// 虚数単位
	complex_j@ = dupmod_of(complex_i@)
	
	return
	
#global

	complex_Register
	
#if 1

	i = complex_i
	
	// 計算
	mes int(i * i)	//=> -1 (i^2)
	
	stop

#endif

#endif

