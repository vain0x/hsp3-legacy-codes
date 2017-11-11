# hsp_green
HSP3で使えるヘッダファイルの集まり。コンセプトは **いつも定義して使いたい** 。

## 導入方法
0. [最新版](https://github.com/vain0/hsp_green/archive/master.zip) をダウンロードして解凍する。
0. hsp_green フォルダをHSPの common フォルダのなかに入れる。
0. スクリプトの最初のほうに次のように書く。

```hsp
#include "hsp_green/src/all.hsp"
```

* さらに、[hsphelp フォルダ](hsphelp)の中身をHSPの hsphelp フォルダに入れると、F1キーのヘルプから各種コマンドの情報を確認できるようになる。

### 規約
* このリポジトリ内の全ファイルは誰でも自由に使用可能。
  * [NYSL (煮るなり焼くなり好きにしろライセンス)](http://www.kmonos.net/nysl/)

## 機能
* ほぼオーバーヘッドなし
 * リリース時(exe ファイルにしたとき)は、使ったぶんだけしか重くならない。
 * ただしモジュールは最適化で消えても4バイト消費する。ショートコードプログラミングでは注意。

* 標準命令用の名前定数やマクロ
 * ``gsel_show id`` (= ``gsel id, 1``)
 * ``dialog msg, dialog_yesno, cap``
 * などなど。[定義ファイル](src/standard_consts.hsp) を参照。

* 排他的比較文 xswitch
 * swbreak を省略できる switch 文のようなもの。

* こまごまとしたコマンド
 * 2つの数値の大きいほうを返す `major_i()`
 * COLORREF値で色を指定する `color32`
 * など

* 標準的なメタ関数
  * マクロの定義に便利な小物。

* 一時ファイルの自動消去
  * デバッグ実行後、`obj`, `hsptmp` を自動的に削除する。
