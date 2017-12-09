# Gitで編集しよう

前回のギトギット！ (♪)

0. 作業フォルダを作った！
0. git init して、.git フォルダを作った！
0. ファイル hello.txt を作った！
0. git add と git commit で、ファイルを git に登録した！
0. ファイル hello.txt を消した！
0. git status したら、ファイルが消えていることが分かった！
0. git diff したら、消えたファイルの内容が見れた！
0. git checkout したら、ファイル hello.txt が帰ってきた！

前回はファイルの作成をやってみました。
今回はファイルの編集をやってみましょう！

前回のフォルダでもいいですし、新しくフォルダを作って git init してもいいですが、Git Bash Here で Bash の画面を開きます。

```
$ echo "最初の行！" > four.txt
$ git add four.txt
$ git commit
```

これは前回やったこととほとんど同じです。新しく four.txt というファイルを作って、それを git に登録します。
すると、エディタが起動しますね。ここに前回は「hello.txt を作成」と書きましたが、実は、この文章を **コミットメッセージ** と呼ぶのです。
コミットメッセージとは、変更の **要約文** です。実際、前回やったことは「hello.txt を作成」の1文で表現できていますよね。
今回も同様に、コミットメッセージは「four.txt を作成」とでもしましょう。
1行目に書いて保存し、エディタを閉じます。

では、ここからが今回の本題です。
ファイル four.txt を **編集** します。
メモ帳で開いて……とやってもいいですが、相変わらず私の説明の手間を省くため、Bash の画面から編集をしてみます。

```
$ echo "次の行！" >> four.txt
```

こうすると、 four.txt の中身は次のように2行に増えます。
`>>` は「一番後ろに書き加える」という意味なのです。

```
最初の行！
次の行！
```

再び前回のおさらいのコーナーです。
変更の内容を知るには、git status と git diff が使えるんでしたよね。使ってみましょう。

```
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   four.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

長いですが見るべき場所は1つ！ 真ん中にある ``modified: four.txt`` つまり

```
    modified:  four.txt
    [four.txt が変更されている]
```

という部分です。
変更されているというが、具体的には？
と聞くには、git diff を使うのでした。

```diff
$ git diff
diff --git a/four.txt b/four.txt
index 96b8bde..8f63f52 100644
--- a/four.txt
+++ b/four.txt
@@ -1 +1,2 @@
 最初の行！
+次の行！
```

「次の行！」という1行が追加されたのだ、ということが (+) という記号や緑色で表示されていて、分かりやすいですね。

さて、この変更を git に教えるときが来ました。
使うのはやはり git add と git commit のコンビです。

```
$ git add four.txt
$ git commit
```

コミットメッセージ(変更に関する要約文)を聞かれるので、今回は「2行目を追加」とでもしておきましょう。
すると結果は……:

```
$ git commit
[master a2d4452] 2行目を追加
warning: LF will be replaced by CRLF in four.txt.
The file will have its original line endings in your working directory.
 1 file changed, 1 insertion(+)
```

相変わらず警告がうるさいですが、要するに

```
$ git commit
[master a2d4452] 2行目を追加
警告: (略)
  1 つのファイルが変更され、1 行が追加されました (+)
```

ということです。
こうして、いま git は「four.txt は2行のテキストからなるファイルだ」ということを記憶しました。
git status の結果もこうなります:

```
$ git status
On branch master
nothing to commit, working directory clean
```

和訳すると、

```
$ git status
ブランチ master 上にいる。
コミットするものはありません。作業ディレクトリは汚れていません。
```

という意味です。いや、よく分かりませんが。
ブランチについては後々触れます。
「コミットするもの」や「作業ディレクトリを汚すもの」とは、ようするに git に教えて (git add & git commit をして) いない変更のことです。
作業ディレクトリとは、four.txt などがあるディレクトリ (.git の外側) のことです。

今回は前回のおさらいのようなものなので、最後も前回と同じようなことをしてみましょう。
すなわち、git checkout です。次のコマンドを実行してみてください。

```
$ git checkout HEAD~ -- four.txt
```

すると、four.txt の内容が

```
最初の行！
```

になっています。すなわち、 **1つ前のバージョンに戻った** のです。
先ほどのコマンドをあえて日本語で説明すると、

```
$ git checkout HEAD~ -- four.txt
 バージョン HEAD~ (1つ前のバージョン) のファイル four.txt を git から取り出す(checkout)
```

といった意味になります。この意味が分かりますか？

おめでとうございます。
[序文](README.md) で触れた「昨日のバージョンを取り出す」といったことを、あなたはもうできるようになったのです！

次回は過去のバージョンを閲覧する方法について解説します。
