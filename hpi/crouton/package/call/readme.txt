﻿
	call

【  名  称  】call
【  種  別  】HSP3.2拡張プラグイン
【  作  者  】上大
【 取り扱い 】フリーソフトウェア
【 開発環境 】Windows XP HomeEdition SP3
【 動作確認 】Windows XP
【  開発元  】http://prograpark.ninja-web.net/

＠目次
・概要
・導入
・除去
・パッケージ
・機能
・ソースコード
・著作権
・参照

＠概要
	ラベルを引数付きで呼び出すことを可能にする拡張プラグインです。
	非公式の方法をいくつか使用しているので、HSP3.2正式版以外での動作は、一切保証
	できません。
	
＠導入
	ダウンロードした圧縮ファイルを、適当なところに解凍してください。
	他に特別な手続きは必要ありません。
	
＠除去
	関係のあるファイルやフォルダをそのまま削除してください。
	レジストリなどは弄りません。
	「＠パッケージ」参照。
	
＠パッケージ
　　[call]
　　　　┣ [src]      …… HPIのソースコード (C++; VC++)
　　　　┣ call.as    …… 専用ヘッダ
　　　　┣ call.hpi   …… プラグイン
　　　　┣ call.hs    …… ヘルプ・ファイル
　　　　┣ ex*.hsp    …… サンプル・スクリプト
　　　　┗ readme.txt …… このファイル。取扱説明書
　　　　
＠機能
・準備
	ランタイム( hsp3.exe )と hspcmp.dll があるフォルダに call.hpi を、
	hsphelp フォルダに call.hs を、それぞれコピーしてください ( 後者は任意 )。
	
・基本的な使用法
	同梱されている call.as を、スクリプトの最初の方で #include
	してください。Like this:
		#include "call.as"
	
	ラベルで定義した命令を「ラベル命令」、関数を「ラベル関数」と呼びます。
	命令の場合:
		call ラベル, 引数...
		call *sttm, 10, 20		// こんな感じ
	関数の場合:
		call(ラベル, 引数...)
		call(*func, 10, 20)		// こんな感じ。
	このように呼び出します。
	
	定義するときは、サブルーチンを記述する感覚で、命令の処理を書いていき、終了す
	るときは return 命令を用います。Like this:
		*sttm
			mes "Hello, world!"
			return
	
	引数を使用するには、call_aliasAll 命令および call_alias 命令で、変数を引数の
	エイリアスにできます。argv() で直接参照することも可能です。また、refarg()で
	引数に書き込むことも可能です。Like this:
		*assign
			refarg(0) = argv(1)
			return
	
	これは、「call *assign, byref(a), b」で、b の値を a に代入します。つまり、
	代入 = とほぼ同じ動作です ( refarg() はクローンを作るので、型を変えることが
	できませんが )。
	
	引数は値渡しと参照渡しの二通りあります。call 命令で呼び出すときに、定数値が
	書かれている場合は、その値がコピーされます (値渡し)。定数値ではなく変数・
	配列変数が指定されている場合は、同じく値渡しですが、byref() で囲って指定する
	と、参照渡しします。前述の通り refarg() でその変数への代入もできます。
	
	関数を定義する場合も同様です。ラベルは関数形式でも命令形式でも呼び出せます。
	Like this:
		*function
			mes "Hello, world!"
			return 3.14159		// 以下略
	
	戻り値には、通常通り str, double, int の3つが使用可能です。また、call_retval
	命令を使用することによって、ラベル型も返せるようになっています。
	
	また、#deffunc のパラメータのエイリアス名をラベル命令にも使用できます。
	Like this:
		#deffunc lbf_add var p1, var p2
		*add
			return p1 + p2
	
	引数の型には、var と array のみ使用可能です。定数や変数を受け取る場合は必ず
	var にし、配列変数を受け取る場合のみ array にします。local は使用できません。
	#defcfuncでも同じことが可能です。もちろん、呼び出す方法は変わりません。
	ローカル変数( local タイプ )は使用できませんので、ご注意ください。
	※使い方は ex04_deffunc.hsp を参照。
	
・仮引数宣言つき
	call_dec 命令で、ラベル命令・関数を宣言できます。Like this:
		call_dec *add, "int", "int"
	
	あくまでも call_dec は命令であることに注意してください。つまり、実行するまで
	有効ではありません。
	
	第一引数が宣言するラベルで、第二引数以降は、仮引数リストです。次のモノが使用
	できます：
		label, str, double, int, var, array
		
	呼び出し側は同じですが、仮引数タイプが型名と同じ場合、引数を省略できます。省
	略値には、その型の既定値が渡されます ( 既定値がない場合はエラーになります )。
	Like this:
		call_dec *add, "int", "int"
		mes call( *add )	// call( *add, int(0), int(0) ) とされる
		
		*add
			return argv(0) + argv(1)
		
	#deffunc のエイリアスを使用する場合は、var, array だけでなく、通常の int や 
	str を利用します。Like this:
		#deffunc lbf_add int p1, int p2
		*add
			return p1 + p2
	
	定数を var, array にした場合の動作は未定義ですので、気を付けてください。
	
・サンプル
	同梱されている ex*_*.hsp というファイルは、すべてサンプルです。
	
	※これらは NYSL (煮るなり焼くなり好きにしろライセンス) Version 0.9982 です。
	
＠ソースコード
	[src]フォルダの内部のファイルすべてです。不要な場合は、フォルダごと削除して
	もかまいません。
	
	VisualC++ 2008 Express Edition (9.0)を使用しています。言語はC++です。バグや
	間違いを見つけましたら、報告していただけると非常にありがたいです。
	( 「＠参照」を参照 )
	
	また、コンパイルするには hspsdk が必要です。「＠参照」の「HSPTV!」から入手し
	てください。
	
＠著作権
	著作権は作者である上大が持っていますが、プログラムの転用・改変、hpi の配布は
	許可します。上大にそれを報告する義務はありません。
	
＠参照
	・プログラ広場 ( http://prograpark.ninja-web.net/ )
		サポートページです。意見や要望、バグ報告などはここの掲示板までお願いしま
		す。また、最新版のダウンロードはここの「たまり場」から行えます。
		HSPプラグイン講座もあります。
		
	・HSPTV! ( http://hsp.tv/ )
		HSP3の公式サイトです。
		
	・HSP開発wiki ( http://hspdev-wiki.net/ )
		→ ::SideMenu::TOPICS::プラグイン::その他::プラグイン作成ガイド
		Ｃ＋＋でのプラグイン作成講座があります。上大がお世話になったところです。
		
＠更新履歴
2010 05/22 (Sat)
	・更新 (ver: 1.21)。
	
2009 08/10 (Mon)
	・method.hpi と統合。
	
2009 05/05 (Tue)
	・やっと公開。
	
2009 01/29 (Thu)
	・やっと公開に踏み切った。
	　と思ったら公開するの忘れてた。(2009 5/5)
	  
Copyright(C) uedai 2008 - 2010.
