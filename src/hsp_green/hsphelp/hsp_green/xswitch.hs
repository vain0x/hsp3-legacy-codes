%dll
hsp_green
%group
プログラム制御マクロ



%index
xswitch
排他的比較文の開始
%prm
val
val [true]: 比較元の値
%inst
xswitch-xcase-xswend 構文は、ある値 val に関する条件分岐である。

標準マクロの switch-case-swend に似ているが、異なる点が2つある。
1. xswitch 文はいわゆる「fallthrough」を起こさない。すなわち、xcase 節の最後で自動的に xswend に移動する。fallthrough を行いたいときは、xswfall 命令を使用する。
2. xswitch 文は、必ずいずれかのケースを実行しなければならない。デバッグ実行時においてどのケースにもマッチすることなく xswend に到達したときは、assert_unreachable のエラーを生じる。
%href
xswitch
xcase
xcase_if
xdefault
xswend
xswbreak
xswfall
goto_xcase
goto_xdefault



%index
xswend
排他的比較文の終端
%inst
xswitch 文の終端を指定する。



%index
xcase
排他的比較節 (等号条件)
%prm
val
val: 比較する値
%inst
xswitch 文のなかで、比較元の値(xswthis)が val に等しいときに実行される処理を指定する。この節が実行されたら、これ以降の xcase 節や xdefault 節は実行されない。

比較には等号(==)を使用する。型は xswthis のほうに合わせられる。等号以外の条件を指定するには、xcase_if を使用する。
%href
case
goto_xcase
xswfall



%index
xcase_if
排他的比較節
%prm
cond
cond: 条件式
%inst
xswitch 文のなかで、条件 cond が真であるときに実行される処理を指定する。この節が実行されたら、これ以降の xcase 節や xdefault 節は実行されない。

if 文と似ているが、この条件式は比較元の値 xswthis を使うべきである。
%href
goto_xcase



%index
xdefault
排他的比較節 (その他)
%inst
xswitch 文のなかで、ほかの条件が真でなかったときに実行される処理を指定する。この節が実行されたら、これ以降の xcase 節や xdefault 節は実行されない。

%href
default
goto_xdefault



%index
xswfall
排他的比較文の次の節
%inst
xswitch 文のなかで、次の xcase 節(または xcase_if, xdefault 節)に移動する。最後の節なら、xswbreak と同様、xswend に移動する。



%index
xswberak
排他的比較文から脱出
%inst
xswitch 文から脱出し、次の xswend 命令の直後に移動する。



%index
xswcontinue
排他的比較文をやり直す (更新あり)
%inst
xswitch 文の先頭に戻る。xswitch のパラメータが式なら、その式を再び計算する。
%href
xswredo



%index
xswredo
排他的比較文をやり直す (更新なし)
%inst
xswitch 文の先頭に戻る。比較元の値(xswthis)は変更されない。
%href
xswcontinue



%index
goto_xcase
xcase 節に移動する
%prm
val
%inst
現在の xswitch 文の、値 val に対応する節に移動する。

実際には、比較元の値(xswthis)を val に変更してから、swredo する。xcase だけでなく、xcase_if、xdefault の節に入ることもある。



%index
goto_xdefault
xdefault 節に移動する
%inst
現在の xswitch 文の xdefault 節に移動する。
もし xdefault より前の xcase, xcase_if 節がすべての場合を網羅していたとしても、xdefault 節に入る。

xdefault 節がない場合は、xswend に移動する。デバッグ時には assert_unreachable エラーとなる。



%index
xswthis
排他的比較文の比較元の値
%inst
現在の xswitch 文の比較元の値が入った変数。上書き不可。

主に xcase_if 文のなかで使用する。
