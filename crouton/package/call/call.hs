;--------------------------------------------------
; HSP help source (hs)
; default

%dll
call.hpi

%ver
1.21

%date
;2008 11/9 (Sun)
;2008 11/10 (Mon)
;2008 12/11 (Thu)
;2008 12/30 (Tue)
;2009 08/10 (Mon)
;2009 08/16 (Sun)
;2009 08/18 (Tue)
2010 05/22 (Sat)

%author
uedai

%url
http://prograpark.ninja-web.net/

%note
%type
HSP3.2拡張プラグイン

%port
Win

%portinfo
WindowsXPでのみ動作確認

;-----------------------------
%index
call
ラベル命令呼び出し

%prm
lbDst, ...
label lbDst	: ジャンプ先ラベル
any   ...	: ラベル命令の引数リスト

%inst
ラベルに、引数付きでサブルーチン呼び出しを行います。

引数は、基本的に値渡しですが、byref() に囲まれた変数は参照渡しします。
個別に指定するには、call より前に call_decprm を使用して、引数の情報を設定しておきます。
※参照渡しとは、変数自体を引数に渡すことです。つまり、命令側が引数に値を代入すると、呼び出し先の変数の値も変化します。( #deffunc でいうところの var 相当です。 )
　対して、値渡しでは値のコピーを渡すため、呼び出し先が引数に代入したとしても、呼び出し元には影響は全くありません。

引数の数と種類は自由です。仮引数宣言がない場合は、引数の型や数のチェックなどは行いません ( 正しい型、数を知らせる方法がありません )。ただし、ラベル側が str 型と信じて引数を使用している可能性はあります。ご注意ください。
省略された引数には、int(0) が渡されます。ただし、#deffunc を使用している場合は、省略された引数のエイリアスは無効になります。

#deffunc をラベルの前に置くことで、エイリアス機能を使用することが可能です。
これにより、引数を静的な変数で管理する必要がなくなります。当然、これらの引数に argv などで参照することも可能です。この場合、引数の型にはすべて var か array を使用してください。定数( 変数以外 )は var です。配列変数を受け取る場合は array にします。
※このプラグインは、内部で扱う値をすべて、HSPの変数と同じ方法で管理しているため、このような仕様になっています。
※この #deffunc で定義された命令は直接呼び出すことができますが、安全性は保証しません。
※local は使用できません。
ただし、call_dec によって仮引数が宣言済みである場合は、var ではなく、通常のタイプを使用してください (int, str, var, array など)。

また、call のもう一つの機能として、label の代わりに、defidOf() で取得した値を指定することが可能です。この場合、呼び出されるのはラベル命令・関数ではなくユーザ定命令・関数になります。

%sample

%href
call
call_dec

defidOf

%group
拡張プログラム制御命令

;-----------------------------
%index
call
ラベル関数呼び出し

%prm
(dst, ...)
label dst	: ジャンプ先ラベル
any   ...	: ラベル関数の引数リスト

%inst
ラベルに、引数付きでサブルーチン呼び出しを行います。

関数(call)の返値は、通常通り return で返すことが可能です。return ができない label 型を返したい場合は、call_retval 命令を使用し、returnで何も返さないでください。また、直前の call の戻り値は call_result() で取得することができます。

それ以外は、命令形式の call と同様です。そちらも参照してください。

なお、HSP3.1正式版以前では、引数に直接ラベル名を書き込むとプリプロセッサに弾かれてしまうため、ラベル型変数にラベルを代入してから、引数に指定する必要があります。
※ HSP3.2 以降では問題ありません。

%sample

%href
call
call_retval
call_result

%group
拡張プログラム制御命令

;-----------------------------
%index
call_dec
ラベル命令・関数の仮引数宣言

%prm
*lbDst, ...
label   lbDst : 呼び出し先ラベル
prmtype ...   : 仮引数リスト

%inst
ラベル命令・関数の仮引数宣言を行います。
仮引数が宣言されている場合、以下の点が、通常と異なります。

・引数の省略時に既定値が補われます。
  str(""), double(0.0), int(0) です。他は省略できません。
・str 型も省略できます。既定値は空文字列("")です。
・型チェックをします。ただし、int <-> double の型変換は行いません。
・#deffunc のエイリアスに、var ではなく int や str を使用します。

使える仮引数タイプは、以下の通りです。型名は "" でくくり、文字列にしてください。
特殊仮引数は、PRM_TYPE_* という定数です。VAR, ARRAY, ANY, FLEX が使用できます。
html{
<table>
	<thead>
		<tr>
			<th>定数</th>
			<th>名称</th>
			<th>意味</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>PRM_TYPE_LABEL</td>
			<td>"label"</td>
			<td>label型。省略できません。</td>
		</tr><tr>
			<td>PRM_TYPE_STR</td>
			<td>"str"</td>
			<td>str型。既定値 ""。</td>
		</tr><tr>
			<td>PRM_TYPE_DOUBLE</td>
			<td>"double"</td>
			<td>double型。既定値 0.0。</td>
		</tr><tr>
			<td>PRM_TYPE_INT</td>
			<td>"int"</td>
			<td>int型。既定値 0。</td>
		</tr><tr>
			<td>PRM_TYPE_VAR</td>
			<td>"var"</td>
			<td>配列でない変数を受け取ります。</td>
		</tr><tr>
			<td>PRM_TYPE_ARRAY</td>
			<td>"array"</td>
			<td>配列変数を受け取ります。</td>
		</tr><tr>
			<td>PRM_TYPE_ANY</td>
			<td>"any"</td>
			<td>なんでも受け取ります。基本は値渡しです。byref を使うと、変数を参照渡しします。<br>
				つまり、仮引数宣言していないラベル命令の引数と同じ扱いです。
			</td>
		</tr><tr>
			<td>PRM_TYPE_FLEX</td>
			<td>"..."</td>
			<td>可変長引数を表します。引数リストの最後にのみ指定できます。<br>
				可変長の部分の引数タイプは、すべて any です。
			</td>
		</tr>
	</tbody>
</table>
}html
定数でも、文字列を用いても同じです。

%href
call

method_add

%group
拡張プログラム制御命令

;-----------------------------
%index
call_alias
引数のエイリアスを作成する

%prm
vAlias, idxArg = 0
var vAlias : エイリアス化する変数
int	idxArg : 引数の番号( 0 ～ )

%inst
変数 vAlias を、(idxArg + 1) 番目の引数のエイリアスにします。基本的に、#deffunc のエイリアスと同じと考えてもらってもかまいません。
※第一引数が 0、第二引数は 1 ……という具合です。
※参照渡しの場合は、var 相当。

指定した番号の引数に値が渡されていなかった場合、既定値である int(0) になります。
指定した変数が別の場所で call_alias された場合、上書きされてしまいます。そのような危険があり、かつそれで困る場合は、argv() や refarg() を使用する方が賢明です。

※HSP2.xx の mref 命令と似たようなものです。

%sample

%href
call
;call_alias
call_aliasAll

%group
拡張メモリ管理命令

;-----------------------------
%index
call_aliasAll
引数のエイリアスを作成する( 一括 )

%prm
...
var ... : エイリアス化する変数リスト

%inst
すべての変数を、引数と同じ順番でエイリアスにします。不要な引数は省略してもかまいません。また、渡されていない引数は既定値として int(0) になります。

要するに、call_alias を一気に行う命令です。

引数の数( argc )より多くの変数を渡した場合の動作は、未定義です。

%sample

%href
call
call_alias
;call_aliasAll

%group
拡張メモリ管理命令

;-----------------------------
%index
call_retval
ラベル関数の返値を設定

%prm
result
any result : 返値

%inst
実行中のラベル関数の返値を設定します。この場合は、return 命令の引数を省略して
ください ( return の方が優先されるため )。
また、call_retval を使えば、ラベル型を返すことが可能です。

%sample

%href
call
;call_retval
call_result

%group
拡張メモリ管理命令

;-----------------------------
%index
call_result
ラベル関数の返値を得る

%prm

%inst
直前のラベル関数の返値を返します。

ラベル命令の返値は返せないので注意してください。

%sample

%href
call
call_retval
;call_result

%group
拡張メモリ管理関数

;-----------------------------
%index
call_arginfo
引数の情報を得る

%prm
(p1, p2 = -1)
p1 = int	: 情報ID ( ARGINFOID_* )
p2 = int	: 引数の番号( 0 ～ )

%inst
＋誘導 → arginfo

%sample
%href
arginfo
argc
argv
refarg

%group
拡張メモリ管理関数

;-----------------------------
%index
arginfo
引数の情報を得る

%prm
(idInfo, idxArg = -1)
int idInfo	: 情報ID ( ARGINFOID_* )
int idxArg	: 引数の番号( 0 ～ )

%inst
ラベル命令・関数に渡された引数の情報を取得します。
引数の番号 idxArg が負数( または省略 )の場合、引数全体の情報を取得します。

個別の情報には、以下の種類があります。

ARGINFOID_FLAG	: vartype
ARGINFOID_MODE	: 変数モード( 0 = 無効, 1 = 通常, 2 = クローン )
ARGINFOID_LEN1	: 一次元目要素数
ARGINFOID_LEN2	: 二次元目要素数
ARGINFOID_LEN3	: 三次元目要素数
ARGINFOID_LEN4	: 四次元目要素数
ARGINFOID_SIZE	: 全体のバイト数
ARGINFOID_PTR	: 実体へのポインタ
ARGINFOID_BYREF	: 参照渡し(byref)か否か

※これ以外に、取得出来るようにして欲しいものがあれば、URLのサイトの掲示板で依頼
してください。( 不可能な場合もあります。 )

全体の情報は、現在「引数の数 (argc)」のみです。

%sample

%href
;arginfo
argc
argv
refarg

%group
拡張メモリ管理関数

;-----------------------------
%index
argcount
引数の数

%prm

%inst
＋誘導 → argc

%sample

%href
arginfo
argc
argv
refarg

%group
ユーザ定義システム変数

;-----------------------------
%index
argc
引数の数

%prm

%inst
call に渡された実引数の数を返します。

%sample

%href
arginfo
;argc
argv
refarg

%group
ユーザ定義システム変数

;-----------------------------
%index
call_argv
引数の値を取得する

%prm
(idxArg = 0)
int idxArg : 引数の番号( 0 ～ )

%inst
＋誘導 → argv

%sample

%href
arginfo
argc
argv
refarg

%group
拡張メモリ管理関数

;-----------------------------
%index
argv
引数の値を取得する

%prm
(idxArg = 0)
int idxArg	: 引数の番号( 0 ～ )

%inst
指定した番号の引数の値を取得します。
引数が参照渡しでも、値のみを取り出します。( → refarg() )

再帰など、ラベル命令・関数の中でさらに call する場合は、call_alias などの命令ではなく、この関数で値を取得するようにしてください。
( エイリアスになっている変数が上書きされる危険があるため )。

%sample

%href
arginfo
argc
argv
refarg

%group
拡張メモリ管理関数

;-----------------------------
%index
refarg
参照渡しの引数を取得する

%prm
(idxArg = 0)
int idxArg	: 引数の番号( 0 ～ )

%inst
参照渡しの引数に、値を代入するときに使用します。必ず代入文の左辺に書いてください。
( argv とは違います。 )

これの他に、call_alias を使用する方法もあります。

%sample
*SetRange
	repeat argv(1) - argv(0), argv(0)
		refarg(cnt) = cnt
	loop
	
%href
call_alias
call_aliasAll
argv
;refarg

%group
拡張メモリ管理関数

;-----------------------------
%index
call_thislb
呼び出し先ラベル

%prm

%inst
＋誘導 → thislb

%sample

%href
call
thislb

%group
ユーザ定義システム変数

;-----------------------------
%index
thislb
呼び出し先ラベル

%prm

%inst
call命令・関数で呼び出されたラベルを返します。再帰での処理を行いたいときなどに、使用すると便利かもしれません。

%sample
// 階乗を求める関数 ( なぜか再帰させます )
*fact_f
	if ( 0 != argv(0) ) {
		return call( thislb, (argv(0) - 1) ) * argv(0)
	} else {
		return 1.0
	}
	return
	
%href
call
;thislb

%group
ユーザ定義システム変数


;###########################################################
;        stream 呼び出し
;###########################################################
%index
call_stream_begin
stream call 開始

%prm
[dst]
label dst : ジャンプ先

%inst
ストリーム呼び出しの開始を表します。ついでに、ジャンプ先のラベルの設定もできます。

ストリーム呼び出しとは、引数を動的な個数で追加するための機能です。この call_stream_begin 命令から始まり、call_stream_add で引数を追加し、最後に追加されたすべての引数を持って、call_stream でラベル命令・関数を呼び出します。
これにより、可変長引数の個数をループで決める、などが可能になります。

%sample
#include "call.as"

	randomize
	call_stream_begin *textcat
	call_stream_add "var x $list := {", "\n\t"
	repeat rnd(10)
		call_stream_add strf("%3d, ", rnd(100))
	loop
	call_stream_add "\n};"
	mes call_stream()		// 関数形式
	stop
	
// 文字列を全部繋げる関数
*textcat
	sdim stmp
	repeat argc
		stmp += argv(cnt)
	loop
	return stmp
	
%href
call_stream_begin
call_stream_label
call_stream_add
call_stream

%group
ユーザ拡張命令

;-----------------------------
%index
call_stream_label
stream call ラベル設定

%prm
dst
label dst : ジャンプ先ラベル

%inst
ストリーム呼び出しにおいて、ジャンプ先のラベルを設定します。すでに設定済みの場合も、何度でも上書きすることが可能です。

ラベルが設定されていない場合、call_stream は失敗します。

%href
call_stream_begin
call_stream_label
call_stream_add
call_stream

%group
ユーザ拡張命令

;-----------------------------
%index
call_stream_add
stream call 引数の追加

%prm
[...]
any ... : 実引数リスト

%inst
ストリーム呼び出しの実引数を追加します。この命令は何度でも実行できます。呼び出すときの引数の順番は、追加された順と同じになります。

%sample

%href
call_stream_begin
call_stream_label
call_stream_add
call_stream

%group
ユーザ拡張命令

;-----------------------------
%index
call_stream
stream call 実行

%prm

%inst
ストリーム呼び出しの実行処理をします。call_stream_add で追加された引数を持って、call_stream_begin または call_stream_label で設定されたラベルにジャンプします。

※ call_stream_end でも同一の処理が可能です。

%sample

%href
call_stream_begin
call_stream_label
call_stream_add
call_stream

%group
拡張プログラム制御命令


;###########################################################
;        method
;###########################################################
;-----------------------------
%index
method_replace
メソッド機構の掠奪

%prm
vt
vartype vt : 型タイプ値 or 型名

%inst
型が持つメソッド呼び出し機構を奪い取ります。これで奪い取った場合、method_add でメソッドを独自に追加できるようになります。既に奪っている場合は、なにもしません。

HSP3.2 では、comobj 以外の型にはメソッド呼び出し機構が備わっていないため、奪って問題ありません。
※奪い取った呼び出し機構は元に戻せません。
	→ 戻せるようにもできますので、需要があるなら掲示板などで要望してください。

%sample
#include "call.as"
	
	method_replace "int"	// int 型のメソッド呼び出し機構を奪う
	
%href
method_replace
method_add

%group
ユーザ拡張命令

;-----------------------------
%index
method_add
メソッドの追加

%prm
vt, "name", dst, ...
vartype vt     : 型タイプ値 or 型名
str     method : メソッド名
label   dst    : メソッドの定義があるラベル
any     ...    : 仮引数リスト

%inst
vt の型にメソッドを追加します。この型には、あらかじめ method_replace 命令を使っておく必要があります。

仮引数リストは、call_dec のそれと同じです。call_dec を参照してください。

%sample
#include "call.as"
	
	method_replace "int"	// int 型のメソッド呼び出し機構を奪う
	method_add     "int", "print", *method_int_print, "int"
	
	n = 0x0077FF00
	n->"print" 16	// 16 進数で表示
	stop
	
#deffunc _method_int_print var this
*method_int_print
	call_alias radix, 1
	if ( radix < 0 || radix > 32 ) { radix = 10 }
	
	if ( radix == 10 ) {
		mes this
	} else : if ( radix == 16 ) {
		mes strf("0x%08X", this)
	} else {
		// 基数変換処理などばっさり略
		mes this	// 10 進数のままで表示
	}
	return
	
%href
method_replace
method_add

call_dec

%group
ユーザ拡張命令


;###########################################################
;        call-cmd
;###########################################################
;-----------------------------
%index
callcs
コマンド呼び出し (命令形式)

%prm
 (id) ...
defid id      : コマンドId
...   arglist : 実引数リスト

%inst
id の示すコマンドを、命令として呼び出します。

%sample
#include "call.hpi"

	callcs( defidOf(mes) ) "Hello, world!"
	
%href
;callcs
callcf

defidOf

%group
拡張プログラム制御命令

;-----------------------------
%index
callcf
コマンド呼び出し (関数形式)

%prm
(id [, (...)])
defid id    : コマンドId
... arglist : 実引数リスト

%inst
id が示すコマンドを、関数またはシステム変数として呼び出します。

第二引数の (...) を省略した場合は、システム変数呼び出しです。

%sample
#include "call.hpi"

#module

#defcfunc opAdd int lhs, int rhs
	return lhs + rhs
	
#global

	cmd_opBin = defidOf(opAdd)	// id 値は変数に格納できる
	lhs =  2943
	rhs = 18782
	val = callcf( cmd_opBin, (lhs, rhs) )
	
	mes strf( "%d + %d = %d", lhs, rhs, val )
	mes "stat = " + callcf( defidOf(stat) )
	
	// 変数のコマンドID (代入は不可)
	mes "lhs = " + callcf( defidOf(lhs) )
	
	stop
	
%href
callcs
;callcf

defid

%group
拡張プログラム制御命令


;###########################################################
;        deff
;###########################################################
;-----------------------------
%index
defidOf
コマンドの defid の取得

%prm
(cmd)
cmd p1 : コマンド

%inst
コマンドから id 値を取得します。

コマンドとは、命令や関数のキーワード、変数、定数、など、スクリプトを構成する1つ1つのものです (ただし記号は除く)。
この関数は、それを id 値にしたものを返します。id 値は int 型です。

特に p1 にユーザ定義命令・関数を指定して得た id 値を ModcmdId と呼びます。isModcmdId(id) が真を返すとき、id は ModcmdId です。
この値は、call コマンドなどの「ジャンプ先」に、ラベルの代わりとして使用できます。

その他のコマンドをスクリプトとして実行するには、(callcs, callcf) を使用してください。

%sample

%href
call
callcs
callcf

isModcmdId

#deffunc
#defcfunc
#modfunc
#modcfunc

%group
ユーザ拡張関数

;-----------------------------
%index
isModcmdId
ModcmdId かどうか

%prm
(defid)
int defid : defidOf() で得た値

%inst
引数の値が、defidOf でユーザ定義命令・関数から得た値かどうかを返します。

%sample
%href
call
defidOf

%group
ユーザ拡張関数

;-----------------------------
%index
labelOf
ユーザ定義命令・関数のラベルを得る

%prm
(p1)
(some) p1 : ユーザ定義命令・関数

%inst
p1 には、ユーザ定義命令・関数、ラベル、defidOf()の値、のいずれかを指定し、それが定義されている位置のラベルを返します。

%sample
#include "call.as"

	method_replace "int"
	method_add     "int", "mes", labelOf(method_mes)
	
	// サンプル
	n = 72
	n->"mes"
	stop
	
#deffunc method_mes var this
	mes this
	return
	
%href
call
defidOf

%group
ユーザ拡張関数

;-----------------------------
%index
byref
参照渡し

%prm
(p1)
var p1 : 変数

%inst
変数を参照渡しするキーワードです。
call の引数の中でのみ使用できます。

ただし、call_dec などにより参照渡しすることが決まっている場合は、byref を使ってはいけません。

%sample
#include "call.as"

	// サンプル
	a = 1
	
	call *LAssign, byref(b), byref(a)
	
	mes b	//=> 1
	stop
	
*LAssign
	refarg(0) = argv(1)
	return
	
%href
call

%group
ユーザ拡張キーワード

;-----------------------------
