# バージョン管理とは？

はじめまして、ue_dai です。
この場をお借りして、「git」というツールがいかにHSPユーザにとって役立つかを解説し、布教したいと思います。

コンセプトは「タイムマシンがあったら、数年前の自分に教えたいこと」。

さて、題に **バージョン管理** とありますが、これは何でしょうか？
平たくいえば、 **バックアップツールのすごいやつ** です。
みなさんが今まで頑張って書いてきた＆今書いているHSPのスクリプト、消えたら困りますよね？
そこで、どこか別のところ (クラウドストレージとか) にコピーを置いていると思います。
でもコピーするのは多少なりとも時間がかかりますよね。
git があれば **3秒で** バックアップがとれるようになります。

そして、git はただのバックアップツールではありません。
「バージョン管理」とはすなわち、「ファイルへの変更を全部記録する」ものです。
例えば、

```
「このスクリプト、昨日は動いたのに、今日書き換えたら動かなくなった……」
```

といった場面で、「昨日のスクリプト」をバックアップから手軽に取り出せるようにできます。

さらにいえば、「昨日のスクリプト」と「今日のスクリプト」の違いを比較することで、

```
なぜ動かなくなってしまったのか？
```

に関する重要な情報を得ることができます。

```
(あ、今日追加したこの行で、この変数の値を書き換えたからだ……！)
みたいな
```

つまり、git はデバッグにも役立つのです。

git の利点はまだまだありますが (並行的開発とか)、
前置きが長いのもあれなので、序文はここで終わりにします。
[次回](chapter1.md) からさっそく、実際に git を使ってみましょう。
