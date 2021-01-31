

「GetVarinfo」


## 概要

変数のあらゆる情報を一度に取得する命令 **GetVarinfo** を使用できるプラグインです。



## 対象

HSP3.1正式版で動作を確認しました。



## 使用方法

### 準備

HSPのフォルダ(hsp3.exe があるフォルダ)に、**getvarinfo.hpi** をコピーします。


スクリプトの始めにヘッダファイルを結合すると、そのスクリプトでプラグインが使用できます。

```
#include "getvarinfo.as"

```


実行形式(exe)にするときは、getvarinfo.hpi を実行ファイルと同じフォルダの中に入れてください。



### 命令の説明

* GetVarinfo 変数, 配列変数



変数の情報を、二つ目の配列変数に格納します。配列は int 型に、自動的に初期化されます。


各要素が一つ一つの情報を持っており、種類は以下の通りです。



* VARINFO_LEN0 : 可変長のとき、要素のバッファサイズ

* VARINFO_LEN1 : 一次元目の配列要素数

* VARINFO_LEN2 : 二次元目の配列要素数

* VARINFO_LEN3 : 三次元目の配列要素数

* VARINFO_LEN4 : 四次元目の配列要素数

* VARINFO_FLAG : 型タイプ値 ( vartype と同じ )

* VARINFO_MODE : モード。2 ならクローン変数です。

* VARINFO_PTR  : 実体ポインタ( varptr と同じ )

* VARINFO_MAX  : この配列の要素数



## ソースコード

コンパイルには別途 HSPSDK が必要です。



## 参照

* プログラ広場：サポートページ

  [URL](http://prograpark.ninja-web.net/)



* HSPTV!：HSP本家サイト

  HSPSDK はここからダウンロードしてください。

  [URL](http://hsp.tv/)



## 更新履歴

−2008 12/24 (Wed)

* readme の誤字・脱字を訂正。



−2008 12/23 (Tue)

* 公開！

