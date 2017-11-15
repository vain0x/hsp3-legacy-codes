%dll
StrBuilder.hsp

%port
Win

%group
文字列操作命令

;--------------------
%index
StrBuilder_new
StrBuilder構築

%prm
self, def_capa
array self: StrBuilder インスタンスが入る配列変数
int def_capa [4096]: 初期キャパシティ

%inst
StrBuilder クラスのインスタンスを作る。内部的には newmod 命令。

def_capa については StrBuilder_capacity を参照。

;--------------------
%index
StrBuilder_set
文字列を上書きする

%prm
self, s
str s: 上書き後の文字列

%inst
StrBuilder が持っていた元の文字列を消去して、s を書き込む。

;--------------------
%index
StrBuilder_append
文字列を末尾に追記する

%prm
self, src, src_len
str src: 書き込む文字列
int src_len: src の長さ (省略可)

%inst
StrBuilder インスタンスが持っている文字列の末尾に、src を付け加える。

src の長さがあらかじめ分かっている場合は、src_len を指定することで ``strlen(src)`` の実行を回避できる。

;--------------------
%index
StrBuilder_append_v
文字列を末尾に追記する

%prm
self, src, src_len

var src: 書き込む文字列が入った変数 
int src_len: src の長さ (省略可)

%inst
StrBuilder_append と同じ。こちらのほうが実行効率がいい。

;--------------------
%index
StrBuilder_strsize
最後のappendの長さ

%prm
()

%inst
直前に呼ばれた StrBuilder_append, StrBuilder_append_v 関数で書き込まれた文字数を返す。

それらの命令がどのインスタンスに対して呼ばれたかは関係ない。
StrBuilder_append_char などのほかの命令の影響は受けない。

;--------------------
%index
StrBuilder_append_char
1文字を末尾に書き加える

%prm
self, c
int c: 書き込む文字

%href
StrBuilder_append

;--------------------
%index
StrBuilder_erase_back
末尾の文字を削除する

%prm
self, len
int len: 削除する文字数

%inst
文字列の後ろの len バイトを削除する。

len が文字列の長さより大きいときは、全て削除される。

;--------------------
%index
StrBuilder_ensure_capacity
キャパシティを一定以上にする

%prm
self, new_capa
int new_capa: 要求するキャパシティ

%inst
StrBuilder のバッファが new_capa 以上のキャパシティを持つように要求する。

new_capa が現在のキャパシティより大きいときにのみバッファ拡張が生じる。

%href
StrBuilder_capacity

;--------------------
%index
StrBuilder_copy_to
文字列をバッファに書き込む

%prm
self, buf
var buf: 文字列バッファ

%inst
StrBuilder が持っている文字列を、buf に転写する。

;--------------------
%index
StrBuilder_length
文字列の長さ

%prm
(self)

%href
strlen

;--------------------
%index
StrBuilder_capacity
確保済みキャパシティの大きさ

%prm
(self)

%inst
StrBuilder が内部的に確保しているキャパシティの大きさを返す。

キャパシティとは、StrBuilder が持つことができる文字列の長さの最大値である。(バイト単位。終端文字を含まない。)

StrBuilder_append 命令などで文字列が長くなるとき、もしキャパシティが足りずに書き込むことができなければ、自動的にキャパシティを大きくする。

;--------------------
;%index
;StrBuilder_str
;文字列を文字列型の値で返す
;
;%prm
;(self)
;;
;%inst
;非推奨

;--------------------
%index
StrBuilder_data_ptr
文字列バッファへのポインタ

%prm
(self)

%inst
StrBuilder が内部的に保存している文字列へのポインタを返す。

dupptr などで使用できる。通常使用する必要はない。

;--------------------
%index
StrBuilder_dup
文字列バッファのクローン変数を作る

%prm
(self)

%inst
StrBuilder が内部的に保存している文字列変数のクローンを作る。内部的には dup 命令。

中身を文字列型の変数として扱いたいときに使用できる。
ただし、文字列を変更する操作をしてはいけない。

クローン変数は、次に self に StrBuilder_append のような文字列を長くする命令を使ったときに壊れる。

;--------------------
%index
StrBuilder_clear
文字列を空にする

%prm
self

%inst
StrBuilder が保存している文字列をすべて削除する。

キャパシティは縮まない。

;--------------------
%index
StrBuilder_chain
文字列を末尾に加える

%prm
self, src
StrBuilder src: 書き込む文字列を持つStrBuilderインスタンス

%inst
src が持っている文字列を、self の末尾に書き加える。

%href
StrBuilder_append

;--------------------
%index
StrBuilder_copy
文字列を転写する

%prm
self, src
StrBuilder src: 書き込む文字列を持つStrBuilderインスタンス

%inst
src が持っている文字列を、self に転写する。self が元々持っていた文字列は消える。
