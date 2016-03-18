# Git をはじめよう

まず好きな場所に新しいフォルダを作成し、エクスプローラで開きます。
右クリックしてメニューを出し、「Git Bash Here」を選択します。
すると、黒い画面が表示されます。(以下、Bash の画面と呼ぶことにします。)

※「Git Bash Here」項目を作らないと選択した人は、Shiftキーを押しながらフォルダを右クリックし、「コマンドプロンプトを開く」を選んでください。また、以下の $ を「ディレクトリ>」に読み替えてください。

Bash の画面の最後の行は「$ 」になっているはずです。
このドル記号は、「この右にコマンドを入力してください」という意味です。
では、さっそく git の「コマンド」を入力しましょう！

```
$ git init
```

Bash の画面と同様に、$ 記号を書いていますが、
読者のみなさんが入力するのは「git init」だけです。
Enter キーを押すと、次のようなメッセージが表示されます

```
$ git init
Initialized empty Git repository in D:/repo/GitIntro/.git/
```

英語ですが、和訳すると

```
空の git リポジトリが D:/repo/GitIntro/.git/ に初期化されました
```

です。よく分かりませんね。
「.git」という名前のフォルダが作成されたということだけ、おさえておいてください。
※.git フォルダは「隠しフォルダ」なので、エクスプローラの画面には表示されないかもしれません。

git init コマンドを使って、.git フォルダを作ることで、このフォルダのファイルを git でバージョン管理できるようになります。
すなわち、git にファイルを保存することが可能になります。

では次に、git にファイルを記録させてみましょう。
ひとまずファイルを作成します。
エクスプローラで右クリックして「新規ファイル作成」、としてもいいのですが、ここでは Bash の画面に次のように入力してください。
($ は入力しなくていいです。)

```
$ echo hello, git world! > hello.txt
```

これで、「hello, git world!」と書かれた、hello.txt という名前のテキストファイルが作成されます。
このように1行書いて実行するだけなので、(私の説明の)手間が省けました。やったね。

このファイルを git に記録させるには、以下のように2つのコマンドを実行します。
(繰り返しになりますが、$ は入力しなくていいです。)

```
$ git add hello.txt
$ git commit
```

すると、テキストエディタ (GreenPad など) が表示されますね。
「# なんとかかんとか」がテキストエディタにたくさん書いてあると思いますが、これは git からの親切な説明なので、読まなくていいです。
ここでの `#` は HSP でいうところの `;` や `//` みたいな意味で、コメント文になります。
最初の行を以下のように変更してみましょうか。

```
hello.txt を作成

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
# On branch master
#
# Initial commit
#
# Changes to be committed:
#	new file:   hello.txt
#
```

これを保存してエディタを閉じると、Bash の画面に次のような出力が現れます。

```
$ git a hello.txt
warning: LF will be replaced by CRLF in hello.txt.
The file will have its original line endings in your working directory.

$ git commit
[master ab258b1] hello.txt を作成
warning: LF will be replaced by CRLF in hello.txt.
The file will have its original line endings in your working directory.
 1 file changed, 1 insertion(+)
 create mode 100644 hello.txt
```

warning (警告) が2つ出ているうえに、commit の結果がややおそろしげな英文ですね。
でも大丈夫！
この警告は無視していいやつですし、内容は大したことありません。
おおむねこういう意味です。

```
$ git commit
[master ab258b1] hello.txt を作成
警告: (省略)
  1 つのファイルが変更され、1 行が追加されました (+)
  作成 100644 hello.txt
```

100644 が相変わらず意味不明ですが、これは無視してください……

さてさて。
長くなりましたが、これでようやく「git にファイルを保存する」ことができました！
実際に記録されているか見てみましょう。
とりあえず、先ほどの hello.txt を消してみます。
ファイルの削除は、エクスプローラからやってもいいですが、いちおう Bash の画面を使って消すにはこうします：

```
$ rm hello.txt
```

git で管理されたフォルダの「現在の状況」を見るコマンドはいくつかあり、
よく使うのは status と diff です。まず git status から使ってみましょう。

```
$ git status
On branch master
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        deleted:    hello.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

長い……
長いですが、ようするに

```
  delete: hello.txt
  (hello.txt が削除されている)
```

ということが分かりました。
git status はこのように、git に管理されているファイルの「現在の状況」を
大まかに知ることができるコマンドなのです。

次に git diff をしてみましょう。これは「現在どのように編集されているか」を
詳細に知ることができるコマンドです。

```diff
diff --git a/hello.txt b/hello.txt
deleted file mode 100644
index 76f2ae3..0000000
--- a/hello.txt
+++ /dev/null
@@ -1 +0,0 @@
-hello, git world!
```

長い……
長いですが、日本語を補って読むと

```
--- [変更前のファイル名は] a/hello.txt
+++ [変更後のファイル名は] /dev/null [※これはファイルがなくなったという意味]
@@ -1 +0,0 @@
-hello, git world!
[「hello, git world!」という行が削除された]
```

ということです。

消してしまったファイルを戻すには、いくつかの方法が考えられますが、ここでは git checkout というコマンドを使います。
以下のコマンドを実行してみてください ($ は入力しなくていい):

```
$ git checkout -- hello.txt
```

すると、見事に hello.txt が帰ってくるのが分かります。

ふう、いろいろと長かったですが、今回はこのくらいにしましょうかね。
1回ではよく分からなかったかもしれませんが、上述のことが使いこなせるようになると「git を使える人」といえると思いますよ！

最後にまとめを置いて終わります。
また [次回](chapter4.md) ！

```
$ git init
フォルダに .git フォルダを作成して、git が使えるようにする。

$ git add ファイル名
$ git commit
作成したファイルを git に登録するのに使いました。
これについて、詳しくは次回説明します。

$ git status
git で管理されたファイルの、現在の状況を大まかに知るためのコマンド。

$ git diff
git で管理されたファイルが、現在どのように編集されているかを知るためのコマンド。
git diff を使うことを、差分を取る、といいます。

$ git checkout -- ファイル名
git に登録されたファイルを取り出すのに使いました。
```
