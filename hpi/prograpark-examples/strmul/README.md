# 文字列反復関数 strmul



## 概要

文字列反復を行う strmul を使用するためのプラグインです。



## 対象

HSP3.1正式版で動作を確認しました。



## 使用方法
### 準備

hsp3.exe があるフォルダに、strmul.hpi をコピーします。実行ファイルで使用するときは、strmul.hpi を実行ファイルと同じフォルダの中に入れてください。


スクリプトでヘッダファイルをインクルードします。
```hsp
#include "strmul.as"

```


### 命令の説明

* strmul str p1, int p2

  * p1 を p2 回反復した文字列を、refstr に格納します。

* strmul( str p1, int p2 )

  * p1 を p2 回反復した文字列を返します。

  * 例えば、``strmul("xyz", 3)`` なら `xyzxyzxyz` が文字列として返ります。
  * 回数が 0 以下なら、空文字列 `""` になります。



## 参照

* プログラ広場：サポートページ

  [URL](http://prograpark.ninja-web.net/)



* HSPTV!：HSP本家サイト

  HSPSDK はここからダウンロードしてください。

  [URL](http://hsp.tv/)



## 更新履歴

−2008 12/25 (Thu)

* 公開！

