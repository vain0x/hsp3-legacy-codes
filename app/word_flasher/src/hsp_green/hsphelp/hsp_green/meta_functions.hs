%dll
hsp_green

%group
メタ関数

%index
_empty
空のスクリプト



%index
_rm
空のスクリプト (括弧つき)
%prm
(ignored)
%inst
パラメータごと消去され、空のスクリプトに展開される。



%index
_cat
識別子の連結
%prm
(i1, i2)
%inst
識別子 i1, i2 をこの順で連結した識別子に展開される。
スペースがあると失敗する。



%index
_cat_scope
識別子とスコープ解決の連結
%prm
(ident, scope)
%inst
識別子 ident にスコープ scope をつけて、識別子 ident@scope に展開される。
スペースがあると失敗する。



%index
_comma
カンマ (,)



%index
_colon
コロン (:)



%index
_unique_ident
匿名識別子
%prm
([postfix])
postfix [_empty]: 接尾辞
return: 一意な識別子に、postfix を連結したもの
%inst
特殊展開マクロ %n の一般化。



%index
_stringify
式の文字列リテラル化
%prm
(code)
code: スクリプト断片
return: code を文字列リテラルにしたもの
%inst
注意：
1. code のなかで {"..."} は使えない。
2. code のなかの剰余演算子 \\ がエスケープ・シーケンスとして働いてしまう。
3. code のなかのマクロは展開されない。



%index
_replicate2
コードを複製する
%prm
(c)
return: コード片 c を2つ並べたコード
%inst
同様に _replicate7 まで定義済み。
