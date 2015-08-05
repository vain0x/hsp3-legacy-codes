# uedai_userdef
HSP3 で使えるヘッダファイルの集まりです。

## 導入方法
0. [最新版](https://github.com/vain0/uedai_userdef/archive/master.zip) をダウンロードして解凍する。
0. [uedai_userdef フォルダ](uedai_userdef)をHSPの common フォルダのなかに入れる。
0. スクリプトの最初のほうに次のように書く。

```hsp
#addition "uedai_userdef/all.hsp"
```

* スクリプトエディタで F7 キーを押したとき、「#Use file [...]」という表記が並んでいれば読み込めています。

## 機能
* ほぼオーバーヘッドなし
  * リリース時(exe ファイルにしたとき)は、使ったぶんだけしか重くならない。

* 拡張された `switch` 命令。
  * `swthis`: 比較元の値を参照できる。
  * `case_if`:
    * 比較値と関係なく、条件式が真ならこの節に入る。
  * `go_case`, `go_default`: 特定の節にジャンプする。

* 拡張された `logmes` 命令。
  * 指定されたファイルにも保存する。

* 標準命令用の名前定数
  * ``gsel id, gsel_show`` などと書ける。

* 標準的なメタ関数
  * マクロの定義に便利かもしれない。

* 一時ファイルの自動消去
  * `obj`, `hsptmp` を自動的に削除する。
