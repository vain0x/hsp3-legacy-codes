# 変数情報を簡単に取得！ varinfo



## 概要

変数の情報を取得するコマンド **varinfo** を、使用するためのプラグインです。



## 使用方法

### 準備

hsp3.exe があるフォルダに、varinfo.hpi をコピーします。実行ファイルで使用するときは、varinfo.hpi を実行ファイルと同じフォルダの中に入れてください。


ヘッダファイルをインクルードすると使用できます。
```
#include "varinfo.as"

``


### 関数の説明

* varinfo( 変数, 種類 )
  * 種類とは以下の VARINFO_* のいずれかの値です。
  * 種類に応じて、変数の情報を返します。



* VARINFO_LEN0 : 可変長のとき、要素のバッファサイズ

* VARINFO_LEN1 : 一次元目の配列要素数

* VARINFO_LEN2 : 二次元目の配列要素数

* VARINFO_LEN3 : 三次元目の配列要素数

* VARINFO_LEN4 : 四次元目の配列要素数

* VARINFO_FLAG : 型タイプ値 ( vartype と同じ )

* VARINFO_MODE : モード。2 ならクローン変数です。

* VARINFO_PTR  : 実体ポインタ( varptr と同じ )



## 著作権

作者、上大は、このプラグインの著作権を放棄しております。

自由に転用や、配布などを行ってかまいません。



## 参照

* プログラ広場：サポートページ

  [URL](http://prograpark.ninja-web.net/)



* HSPTV!：HSP本家サイト

  HSPSDK はここからダウンロードしてください。

  [URL](http://hsp.tv/)



## 更新履歴

−2009 08/23 (Sun)

* 公開！

