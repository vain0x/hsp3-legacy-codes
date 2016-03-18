# Gitのインストール

※本稿はとりあえず Windows しか対応しません。(Mac, Linux 使いの方、申し訳ありません。)

さっそく Windows 用の git をダウンロードしに行きましょう。
ここの "Download" ボタンからダウンロードできます: <https://git-for-windows.github.io/>

ダウンロードしてきたファイル ``Git-*.*.*-64-bit.exe`` (* は何かの数字) を実行すると、インストール作業が始まります。

※執筆時点(2016年3月18日)では Git-2.7.3 です。以下の記述はこのバージョンについてのものになります。

忙しい人向けの3行の説明はこちら:

```
とにかく
ぜんぶ
そのまま
```

まず "GNU General Public License" と題された文章が表示されますが、これは読まなくても大丈夫です。 ``Next>`` を押します。

Git をインストールするフォルダを選択する画面になります。
これは変更しないほうがいいと思います。
このパス (C:/Program Files/Git のはず) は後で使うので、メモしておいてください。(以下、git ディレクトリのパス、と呼びます。)
そして ``Next>`` を押します。

"Select Component" の画面になります。
これも変更する必要はないと思います。
「Git GUI Here」は、使う予定がないので、チェックを外してもいいかもしれません。
「Git Bash Here」はチェックを付けておくことをおすすめします。
(Windows のコマンドプロンプトを使える人は外してもいいです。)
そして ``Next>`` をクリック。

次は "Select Start Menu Folder" です。
「スタートメニューに Git を追加するか？」という話ですが、どっちでもいいと思います。
``Next>`` をクリック。

"Adjusting your PATH environment" になります。
2つ前の画面で「Git Bash Here」にチェックをつけたままにした人は、特に変更せず、1つ目の "Use Git from Git Bash only" でいいです。
チェックを外した人は、2つ目の "Use Git from the Windows Command Prompt" を選んでください。
(いろいろ詳しい人は、3つ目でもいいです。)

「"Configuring the line ending conversions"」
英語が増えてきましたね。
改行コードとは、……と解説したほうがいいのでしょうが、正直知らなくてもなんとかなりそうなので、「気になる人は調べてください」ということにします。
1つ目の "Checkout Windows-style, commit Unix-style line endings." がおすすめです。
``Next>`` 。

「"Configuring the terminal emulator to use with Git Bash"」
これは解説しだすと長くなるやつなので、1つ目をおすすめてしておきます。
``Next>`` 。

「"Configuring extra options"」
最後。git の選択的な機能を使うかどうかという設定です。
特に2つ目は .NET framework v4.5.1 以降が必要です。
よく分からない場合はそのままにしておきましょう。

``Next>`` を押すとインストールが始まります。
プログレスバーが満たされていくのをみた後、 `Finish` を押せば、無事インストール完了です。
お疲れさまでした。

結局ほとんどデフォルトのままなんですが、こういうところを飛ばすと不信感を抱かれそうなので、詳しくやりました。

[次回](chapter2.md) は git の初期設定を行います。
