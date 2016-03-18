# Git時空の旅

前回のギトギット！ (♪)

0. コミットオブジェクトという言葉を覚えた！
0. コミットオブジェクトの親を辿っていくことで、バージョンの変更記録を列挙できると知った！
0. HEAD はより正確にいえば、作業ディレクトリが元にしているバージョンのことだった！
0. git commit を行うと、元の HEAD を親とする新しいコミットオブジェクトが作られることを知った！
0. git commit を行うと、新しく作られたコミットオブジェクトが HEAD になることを知った！
0. ~~参考文献を読んだ！~~




## バージョンリープ

いままで、HEAD は常に「最新のバージョン」を表していました。
HEAD の位置を移動させてみましょう。
そのためには、基本的に git checkout を使います。

適当なリポジトリで bash を開き、作業ディレクトリをクリーンにしてから (つまり、git commit していない変更がないようにしてから)、以下のコマンドを実行してみてください。

```
$ git checkout HEAD~
```

※git checkout でファイルを取り出すには「git checkout -- ファイル名」としていましたが、この不自然な「--」は、上述のような「バージョンを取り出す用法」と区別するために必要だったのです。

すると、例えば以下のような表示になります。
長い英文が出てきますが、これは git からの親切な忠告です。無視します。

```
$ git co HEAD~
Note: checking out 'HEAD~'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

HEAD is now at 1720f58... 6 回目の更新
```

ひとまず、第5回で作ったリポジトリで実行してみました。
``HEAD~``＝「6回目の更新後のバージョン」の状態を「取り出し」た、という状況です。
実際、作業ディレクトリは「6回目の更新の後」の状態になっています。
すなわち、 five.txt は7行目がなく、

```
ファイル作成！
1 行目！
2 行目！
3 行目！
4 行目！
5 行目！
6 行目！
```

となります。
単に7行目を消したのではなく、HEAD を移動したので、いま「作業ディレクトリには更新がない」(クリーンである)状態です。
確かめてみます。

```
$ git status
HEAD detached at 1720f58
nothing to commit, working directory clean
```

先ほどの git checkout コマンドにより、作業ディレクトリは「6回目の更新の後のバージョン」を元にしている状態になりました。
git status は HEAD＝「6回目の更新の後のバージョン」といまの作業ディレクトリを比較するので、変更は何もない、ということになります。

こうして、私たちは **擬似タイムトラベル** に成功しました。
すなわち、git checkout を使うことで、「昨日のバージョン」のような過去に作業ディレクトリをタイムスリップさせることができたのです。

## コミットオブジェクトの親子関係

おっと、この状態で新しくコミットオブジェクトを作ったらどうなるのでしょうか？
