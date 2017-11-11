%dll
hsp_green
%group
ユーザ定義コマンド



%index
is_true
真値か？
%prm
int p: 条件式または整数値
return: p が 0 でなければ真
%inst
p が整数値(int)でなければエラーになる。

一般的に、(p == true) という式は正しく動かない。これはビット演算と論理積 (&&) を組み合わせたときに障害になりやすい (サンプルスクリプトを参照)。
(p != false) と書けばほぼ問題ないが、文字列の "0" も偽であると判定されることに注意。
%sample
	repeat
		stick stick_val, 64

		//良い例
		if ( is_true(stick_val & 64) && is_true(stick_val & 16) ) {
			mes "Ctrl とスペースキーが押されました"
		}

		//悪い例
		if ( (stick_val & 64) && (stick_val & 16) ) {
			mes "この条件式は必ず偽になる"
		}

		wait 1
	loop



%index
is_false
偽値か？
%prm
int p: 条件式または整数値
return: p が 0 なら真
%inst
p が整数値(int)でなければエラーになる。

(p == false) と書いてもほぼ問題ないが、文字列の "0" も偽であると判定されることに注意。
%href
is_true



%index
unless
条件が否定されるときの分岐
%prm
bool cond: 条件式
%inst
条件 cond が成り立たないときに実行される分岐を指定する。if 文とは cond の解釈だけが異なる。

else 節やブロックの記法 { ... } も使用できる。



%index
elsif
else : if
%sample
	if ( 条件1 ) {
		//条件1が真
	} elsif ( 条件2 ) {
		//条件1が偽、かつ条件2が真
	} elsif ( 条件3 ) {
		//条件1,2が偽、かつ条件3が真
	} else {
		//条件1,2,3が偽
	}

%href
if
else



%index
declvar
変数を初期化済みとして宣言する
%prm
v
var v: 未初期化でも問題ない変数
%inst
「未初期化の変数があります」という警告を抑えるために使う。

リリース時には、この文は消滅する。



%index
assert_unreachable
絶対に実行されないことを言明
%inst
assert false と同じ。「この命令は絶対に実行されない」を意味する。default 節や else 節に書くことがしばしばある。

リリース時には、この文は消滅する。



%index
if_init
1回だけ実行される分岐
%inst
最初の1回だけ条件が成立する if 文。すなわち、この命令が最初に実行されるときのみ、後続のブロックを実行する。



%index
mousex2
マウスカーソルのX座標
%inst
mousex と同様だが、マウスがウィンドウの外にあっても正しく計算される。



%index
mousey2
マウスカーソルのY座標
%inst
mousey と同様だが、マウスがウィンドウの外にあっても正しく計算される。



%index
dir_exe2
実行ファイルのディレクトリ
%inst
デバッグ時は、実行されたスクリプトファイル(.hsp)があるフォルダのパス。
リリース時は、実行ファイル(.exe)があるフォルダのパス。(dir_exe と同じ)



%index
delfile
ファイルを削除する
%prm
path
%inst
delete 命令と同じ。



%index
ignore
式を実行する
%prm
(ignored)
ignored: 式
%inst
式を計算する。その値は無視される。



%index
in_interval
数値が半区間内にあるか？
%prm
(x, first, last)
x: 整数値
first: 区間の始点 (端点を含む)
last: 区間の終点 (端点は含まれない)
%inst
(first <= x < last) の略記。



%index
in_rect
点が矩形上にあるか？
%prm
(px, py, x1, y1, x2, y2)
px, py: 点の座標
x1, y1: 矩形の左上座標 (端点を含む)
x2, y2: 矩形の左下座標 (端点を含む)
%inst
矩形の境界はすべて含まれることに注意。



%index
compare_v
値の順序比較
%prm
(lhs, rhs)
var lhs: 左辺の値
var rhs: 右辺の値
return: 比較値
%inst
比較値とは、次のような意味をもつ整数値である。
負 →「左辺(lhs)のほうが右辺(rhs)より小さい」
0  →「左辺は右辺と等しい」
正 →「左辺のほうが大きい」

lhs, rhs は同じ型でなければいけない。また、struct 型、comobj 型の大小関係は比較できない。

int 型は、通常の大小関係で比較される。
double 型も通常の大小関係を使うが、有効数字は8桁である。
label 型は、スクリプトの前方にあるほうが「小さい」とみなす。

その他の型は、(!=) 演算子の結果を使う。



%index
major_s
2つの文字列のうち大きいほう
%prm
(lhs, rhs)
return: lhs, rhs のうち大きいほう
%href
minor_s
major_d
major_i



%index
minor_s
2つの文字列のうち小さいほう
%prm
(lhs, rhs)
return: lhs, rhs のうち小さいほう
%href
major_s
minor_d
minor_i



%index
major_d
2つの小数値のうち大きいほう
%prm
(lhs, rhs)
return: lhs, rhs のうち大きいほう
%href
minor_d
major_s
major_i



%index
minor_d
2つの小数値のうち小さいほう
%prm
(lhs, rhs)
return: lhs, rhs のうち小さいほう
%href
major_d
minor_s
minor_i



%index
major_i
2つの整数のうち大きいほう
%prm
(lhs, rhs)
return: lhs, rhs のうち大きいほう
%href
minor_i
major_s
major_d



%index
minor_i
2つの整数値のうち小さいほう
%prm
(lhs, rhs)
return: lhs, rhs のうち小さいほう
%href
major_i
minor_s
minor_d


%index
cond_s
正格条件演算子 (str)
%prm
(cond, x, y)
%inst
cond_i を参照。



%index
cond_d
正格条件演算子 (double)
%prm
(cond, x, y)
%inst
cond_i を参照。



%index
cond_i
正格条件演算子 (int)
%prm
(cond, x, y)
return: cond が真なら x、偽なら y
%inst
if の式バージョン。

正格とは、cond の値に関係なく、式 x, y の両方が計算されるということ。
%href
cond_s
cond_d
if



%index
ref_expr_tmpl_1
参照式の定形 (1引数)
%prm
(f, p1)
f: 参照式の設定を行う関数
p1: f の第1引数
%inst
変数を返す関数を定義するためのテンプレ。
実際には、「ref(f(p1, ref))」に展開されるマクロ。ただし ref は一意な識別子で表される変数。

関数 f のなかで変数 ref を設定することにより、式 ref_expr_templ_1(...) は擬似的に変数を返却するものとみなせる。
具体的な使いかたは ref_xs 関数の定義などを参照。

f の引数の数を増やした変種に、ref_expr_tmpl_2, ..., ref_expr_tmpl_5, ref_expr_tmpl_8 がある。引数 ref は、常に f の第2引数に渡される。



%index
ref_expr_tmpl_2
参照式の定形 (2引数)
%prm
(f, p1, p2)
%inst
「ref(f(p1, ref, p2))」に展開されるマクロ。ref_expr_tmpl_1 を参照。



%index
ref_expr_tmpl_3
参照式の定形 (3引数)
%inst
ref_expr_tmpl_1 を参照。
%index
ref_expr_tmpl_4
参照式の定形 (4引数)
%inst
ref_expr_tmpl_1 を参照。
%index
ref_expr_tmpl_5
参照式の定形 (5引数)
%inst
ref_expr_tmpl_1 を参照。
%index
ref_expr_tmpl_8
参照式の定形 (8引数)
%inst
ref_expr_tmpl_1 を参照。



%index
ref_xs
文字列値の参照
%prm
(value)
str value: 渡す文字列
return: value が代入された変数
%inst
文字列型の「変数」を受け取る引数に、文字列の「値」 value を渡すときに使う。

この関数は、あくまで変数を受け取る引数にだけ使用できる。この関数が返す「値」を使用してはいけない。
再帰関数のなかなど、これを書いた式が再帰的に呼び出されることがある場合は、使用できない。
%href
ref_xd
ref_xi
ref_expr_tmpl_1



%index
ref_xd
小数値の参照
%prm
(value)
double value: 渡す小数値
return: value が代入された変数
%inst
ref_xs の double 版。



%index
ref_xi
整数値の参照
%prm
(value)
int value: 渡す整数値
return: value が代入された変数
%inst
ref_xs の int 版。



%index
ref_xsa8
文字列値配列(8要素)の参照
%prm
(v0, ..., v7)
str v0, ..., v7 [""]: 渡す文字列値の列
return: v0, ..., v7 が代入された配列変数
%href
ref_xs



%index
ref_xda8
小数値配列(8要素)の参照
%prm
(v0, ..., v7)
double v0, ..., v7 [0]: 渡す小数値の列
return: v0, ..., v7 が代入された配列変数
%href
ref_xs



%index
ref_xia8
整数値配列(8要素)の参照
%prm
(v0, ..., v7)
int v0, ..., v7 [0]: 渡す整数値の列
return: v0, ..., v7 が代入された配列変数
%href
ref_xs



%index
ref_xia_iota
整数値配列(0～n)の参照
%prm
(len)
int len: 要素数
return: 0, ..., (n - 1) が代入された配列変数
%inst
0, ..., (n - 1) がそれぞれ代入された、長さ n の整数値配列への参照を返す。
%href
ref_xs



%index
ref_xva_replicate
同じ値からなる配列の参照
%prm
(value, len)
var value: 値
int len: 要素数
return: value が len 個代入された配列変数
%inst
各値は代入演算子(=)でコピーされる。
HSPの配列の仕様から分かる通り、len は1以上でなければならない。
%href
ref_xs



%index
RGB
輝度からカラーコードを作る
%prm
(r, g, b)
r: 赤の輝度
g: 緑の輝度
b: 青の輝度
return: 指定された色のCOLORREF値(int)
%inst
COLORREF型の値を返す。
%href
color32
ginfo_rgb



%index
color32
カラーコードで色を指定する
%prm
cref
cref: COLORREF値
%inst
色 cref で color 命令を実行する。



%index
ginfo_rgb
現在設定されているカラーコード
%prm

return: RGB(ginfo_r, ginfo_g, ginfo_b)



%index
dir_exists
ディレクトリが存在するか？
%prm
(dir)
dir: ディレクトリへのパス
return: dir が存在すれば true、しなければ false
%href
dirlist



%index
mkdir_unless_exists
ディレクトリを作る (既存なら何もしない)
%prm
dir
dir: 作成するディレクトリ
%inst
mkdir 命令と同様。ただし、dir がすでにある場合は何も起きない。
%href
dir_exists
