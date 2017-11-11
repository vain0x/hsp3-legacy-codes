// 巡回乱数 ( 排他的 乱数列 )

#ifndef IG_MODULE_EXCLUSIVE_RAND_AS
#define IG_MODULE_EXCLUSIVE_RAND_AS

#module mod_xrnd

#deffunc swap@mod_xrnd var lhs, var rhs,  local tmp
	tmp = lhs
	lhs = rhs
	rhs = tmp
	return
	
//------------------------------------------------
// 巡回乱数を得る
// 
// @ 巡回乱数 := 同じ値の元がただ1つずつしかない、
// @	順序が無作為な数列。造語 (by kz3さん)。
// @ [0, cntPtn) の整数を、任意の順序に並べる。
// @alg: 押し出し法
//------------------------------------------------
#deffunc xrnd array rndtbl, int cntPtn
	dim rndtbl, cntPtn
	repeat cntPtn
		rndtbl(cnt) = cnt
	loop
	
	prnd   = cntPtn
	repcnt = 0
	
	// 混ぜる
	repeat
		n = rnd(prnd)
		prnd --
		if ( prnd == 0 ) {
			prnd = cntPtn
			break
		}
		
		if ( n != prnd ) {
			swap rndtbl(n), rndtbl(prnd)
		}
	loop
	
	return
	
#global

	randomize
	
#endif
