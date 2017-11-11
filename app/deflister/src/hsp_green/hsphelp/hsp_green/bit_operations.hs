%dll
hsp_green
%group
ビット演算


%index
MAKELONG
2つの16ビット値から32ビット値を作る
%prm
(lo, hi)
lo: 下位ワード
hi: 上位ワード



%index
MAKELONG4
4つの8ビット値から32ビット値を作る
%prm
(lolo, lohi, hilo, hihi)
lolo: 下位ワードの下位バイト
lohi: 下位ワードの上位バイト
hilo: 上位ワードの下位バイト
hihi: 上位ワードの上位バイト



%index
HIWORD
上位ワード
%prm
(l)
l: 32ビット値
return: l の上位16ビットの値



%index
LOWORD
下位ワード
%prm
(l)
l: 32ビット値
return: l の下位16ビットの値



%index
MAKEWORD
2つの8ビット値から16ビット値を作る
%prm
(lo, hi)
lo: 下位バイト
hi: 上位バイト



%index
HIBYTE
上位バイト
%prm
(w)
w: 16ビット値



%index
LOBYTE
下位バイト
%prm
(w)
w: 16ビット値




%index
byte_at
整数値から1バイトを取り出す
%prm
(l, i)
return: l の下から i 番目の1バイトの値



%index
pow_2
2の冪乗
%prm
(i)
i: 指数
return: 2のi乗 (2^i)



%index
bit_sub
ビットごとの差
%prm
(lhs, rhs)
lhs, rhs: int
%inst
lhs から、rhs の立っているビットに対応するビットを取り除いたものを返す。

例：bit_sub(0b1100, 0b1010) = 0b0100




%index
bit_complement
ビットごとの補
%prm
(bs)
bs: int
%inst
bs の立っているビットを下ろし、下りているビットを立てたものを返す。

例：bit_complement(0b11110101) = 0b00001010



%index
bit_at
整数値から1ビット取り出す
%prm
(l, i)
return: l の下から i 番目のビット



%index
int_from_signed_short
符号つき16ビット整数値をintに変換する
%prm
(ss)
return: ss を32ビットに拡張した整数値
%inst
符号ビットを保つ。
