%dll
hsp_green
%group
定数



%index
null
NULL値 (ゼロ)



%index
true
真値
%inst
等号 (==) や論理積 (&&) などの条件式の計算結果として、その式が「正しい」ときに得られる値。反対は false。

実際には、0 ではない整数値(int)によって表される。ある整数値が true であることを確認するには、is_true 関数を使うこと。



%index
false
偽値
%inst
等号 (==) や論理積 (&&) などの条件式の計算結果として、その式が「誤り」であるときに得られる値。反対は true。

実際には整数値の 0 に等しい。ある整数値が false であることを確認するときは is_false 関数を使うのが望ましい。



%index
__HERE__
スクリプト位置の文字列リテラル
%inst
__HERE__ マクロが書かれた位置を表す。「#行番号 ファイル名」という形式の文字列リテラルに展開される。
%href
__LINE__
__FILE__



%index
vartype_label
label型の型タイプ値
%inst
vartype("label") の値



%index
vartype_double
double型の型タイプ値
%inst
vartype("double") の値



%index
vartype_int
int型の型タイプ値
%inst
vartype("int") の値



%index
vartype_struct
struct型の型タイプ値
%inst
vartype("struct") の値



%index
vartype_comobj
comobj型の型タイプ値
%inst
vartype("comobj") の値


