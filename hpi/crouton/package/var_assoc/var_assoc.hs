;--------------------------------------------------
; default

%dll
var_assoc.hpi

%ver
1.0

%date
2012.09/23 (Mon)	# Assoc(Result, Expr) 追加、AssocClone 修正
2011.12/25 (Sun)	# Assoc(Chain, Copy, Dup) 追加
2011.07/28 (Thu)	# multi → assoc
2011.07/23 (Sat)
2011.06/23 (Thu)
2008.12/16 (Tue)

%author
uedai

%url
http://prograpark.ninja-web.net/

%note

%type
変数型拡張プラグイン

%port
Win

%index
assoc
assoc型変数を作成

%prm
p1, p2 = 1, p3 = 0, p4 = 0, p5 = 0
p1 = array	: assoc型にする変数
p2 = int	: 一次元目要素数
p3 = int	: 二次元目要素数
p4 = int	: 三次元目要素数
p5 = int	: 四次元目要素数

%inst
assoc型の変数を作成します。dim命令と同じようなものなので、命令の使い方はそちらを参照してください。

作成後は、なんらかのキーをつけて参照したときに実体が確保されます。

%sample
#include "var_assoc.as"

#module

#deffunc drawRect array p1	// 必ず array で受け取る必要あり
	boxf p1("left"), p1("top"), p1("right"), p1("bottom")
	return
	
#global

	assoc rect
	
	color 255
	rect("left")   = 10		// 最初に ("") で参照したので確保される
	rect("top")    = 10
	rect("right")  = 120
	rect("bottom") = 120
	drawRect rect
	stop
	
%href
sdim
ddim
dim
dimtype

%group
メモリ管理命令

%index
AssocDelete
assocを破棄する

%prm
p1
p1 = var	: assoc

%inst
assoc オブジェクトを破棄し、AssocNull を代入します。

%sample
%href
%group
メモリ管理命令

%index
AssocClear
assocのキーを全て除去する

%prm
p1
p1 = var	: assoc

%inst
assocから全てのキーを削除します。

%sample
%href
AssocChain
AssocCopy
AssocDup

%group
メモリ管理命令

%index
AssocChain
assoc を連結する

%prm
p1, p2
p1 = var	: assoc
p2 = var	: assoc

%inst
p2 が持つすべてのキーを、p1 に複製して追加します。
同じキーの要素がある場合、上書きされ、p2 の要素の複製となります。

%sample
%href
AssocClear
AssocCopy
AssocDup

%group
メモリ管理命令

%index
AssocCopy
assoc を複写する

%prm
p1, p2
p1 = var	: assoc
p2 = var	: assoc

%inst
p1 を p2 の複製にします。つまり、p2 が持つ全ての要素を複製して p1 に追加します。
p1 が持っていた要素は全て除去されます。

%sample
%href
AssocClear
AssocChain
;AssocCopy
AssocDup

%group
メモリ管理命令

%index
AssocDup
assoc の複製を得る

%prm
p1
p1 = var	: assoc

%inst
p1 が持つすべての要素の複製を持つ assoc を生成し、返却します。

%sample
%href
AssocClear
AssocChain
AssocCopy
;AssocDup

%group
メモリ管理命令

%index
AssocInsert
assoc キーを挿入する

%prm
p1, p2 [, p3]
p1 = var	: assoc
p2 = str	: キー
p3 = any	: 初期値

%inst
assoc に指定キーを挿入します。
普通に代入するのとほぼ同じです。

%sample
	assoc a
	AssocInsert a, "name", "a"
;	a("name") = "a"
	
%href
AssocRemove

%group
メモリ管理命令

%index
AssocRemove
assocのキーを除去する

%prm
p1, p2
p1 = var	: assoc
p2 = str	: キー

%inst
assocからキーを削除します。削除されたキーは、初期化されていないものとして扱われます。

%sample
%href
AssocInsert

%group
メモリ管理命令

%index
AssocDim
assoc内部変数を配列にする

%prm
p1("キー"), p2=vartype("int"), p3=1, p4=0, p5=0, p6=0
p1 = var	: assoc 内部変数
p2 = int	: 型タイプ値
p3 = int	: 一次元目要素数
p4 = int	: 二次元目要素数
p5 = int	: 三次元目要素数
p6 = int	: 四次元目要素数

%inst
assoc の内部変数を配列として宣言します。型タイプ値は、vartype 関数が返す値です。

これを使用すると、この内部変数が持っていたデータがすべて削除されるので、注意してください。

※要素数は AssocLen 関数で取得します。

%sample
#include "var_assoc.as"
	assoc m
	AssocDim m("x"), vartype("int"), 4
	    m("x", 3) = 333
	mes m("x", 3)
	stop
	
%href
AssocLen

sdim
ddim
dim
dimtype

%group
メモリ管理命令

%index
AssocClone
assocの内部変数をクローンする

%prm
p1("キー"), p2
p1 = var	: assoc 内部変数
p2 = var	: クローンにする変数

%inst
p2 を、assoc の内部変数のクローンにします。
標準の dup 命令のように働きます。

%sample
#include "assoc.as"

	assoc m
	AssocDim m("a"), vartype("int"), 3
	m("a", 2) = 3
	AssocClone m("a", 2), x	// クローン
	mes x
	
	x = 12		// 書き換える
	mes m("a", 2)	// 元のデータも書き換わります
	stop

%href
dup
dupptr

%group
特殊代入命令

%index
AssocNewCom
assocの内部変数をcomobjにする

%prm
p1("キー"), p2, p3=0, p4=0
p1 = var	: assoc 内部変数
p2 = str	: インターフェース名、またはクラスID
p3 = int	: 作成モード(オプション)
p4 = int	: 参照元ポインタ(オプション)

%inst
assocの内部変数に対して、newcom 命令を行います。

※マクロ

%sample
#include "var_assoc.as"

	assoc m
	AssocNewCom m("com"), "WScript.Shell"	// newcom と同じ使い方
	
	mcall m("com"), "Run", dirinfo(3) +"/notepad.exe"	// メモ帳を起動する
	
	AssocDelCom m("com")	// 破棄
	stop

%href
#usecom
#comfunc
newcom
delcom
comres
mcall

;AssocNewCom
AssocDelCom

%group
COMオブジェクト操作命令

%index
AssocDelCom
assocの内部変数のcomobjを破棄

%prm
p1("キー")
p1 = var	: assoc 内部変数

%inst
AssocNewComで作成した comobj を破棄します。delcom 命令と同じ
使い方なので、そちらを参照してください。

※マクロ

%sample
%href
newcom
delcom

AssocNewCom
;AssocDelCom

%group
COMオブジェクト操作命令

%index
AssocVarinfo
assocの内部変数の情報を取得

%prm
(p1("キー"), type=0, option=0)
p1 = var	: assoc型変数

%inst
assocの内部変数の各種情報を取得します。これは、通常のvarptr()
関数や、vartype()関数などが正常に動作できないために代替として
用意された関数です。通常の関数で取得できない部分まで取得可能
となっています。

html{
<table border="1">
	<thead>
		<tr>
			<th>type</th>
			<th>option</th>
			<th>return value</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>VARINFO_FLAG</td>
			<td>---</td>
			<td>型タイプ値( vartype() )</td>
		</tr><tr>
			<td>VARINFO_MODE</td>
			<td>---</td>
			<td>変数モード( 通常は使用しない )</td>
		</tr><tr>
			<td>VARINFO_LEN</td>
			<td>次元 - 1</td>
			<td>配列の要素数( length() )</td>
		</tr><!--<tr>
			<td>VARINFO_SIZE</td>
			<td>---</td>
			<td>バッファサイズ( 通常は使用しない )</td>
		</tr>--><tr>
			<td>VARINFO_PT</td>
			<td>---</td>
			<td>変数へのポインタ( varptr() )</td>
		</tr><tr>
			<td>VARINFO_MASTER</td>
			<td>---</td>
			<td>PVal::masterの値( 通常は使用しない )</td>
		</tr>
	</tbody>
</table>
}html

他の関数は、AssocRef()を使用してください。

%sample
%href
vartype
varptr
length

%group
拡張入出力関数

%index
AssocSize
assoc 要素数

%prm
(p1)
p1 = var	: assoc

%inst
assoc が持つキーと値のペアの数 (要素数) を返します。

%sample
%group
拡張入出力関数

%index
AssocExists
assoc キーが存在するか

%prm
(p1, "キー")
p1 = var	: assoc
p2 = str	: キー

%inst
assoc が指定キーの要素を持つとき真を返します。

%sample
%group
拡張入出力関数

%index
AssocRef
assocの内部変数を参照する

%prm
(p1("キー"))
p1 = var	: assoc 内部変数

%inst
assoc の内部変数のクローンを返します。変数と同様に扱ってください。

クローンが無効になる、dimなどの命令や型変換などを行っても無意味なので気を付けてください。

%sample
%href
%group
参照関数

%index
assoc
assoc型の型タイプ値

%inst
vartype( AssocTypeName ) の値を返します。

%sample
%href

%group
ユーザー定義システム変数

%index
AssocVtName
assoc型の型名

%inst
assoc の正式な型名の文字列を取得します。"assoc" ではありません。

%sample
%href
assoc

%group
ユーザー定義システム変数

%index
AssocNull
assoc null

%inst
assoc の null 値です。

%sample
%href
%group
ユーザ定義システム変数
