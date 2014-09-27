// call.hpi - import header

#ifndef        IG_IMPORT_HEADER_CALL_AS
#define global IG_IMPORT_HEADER_CALL_AS

#define HPI_CALL_VERSION 1.3	// last update: 

;#define IF_CALL_HPI_RELEASE

#ifndef STR_CALL_HPI_PATH
 #ifdef IF_CALL_HPI_RELEASE
  #define STR_CALL_HPI_PATH "call.hpi"
 #else
  #define STR_CALL_HPI_PATH "C:/Users/Owner/Source/Repos/call/Debug/call.hpi";"D:/Docs/prg/cpp/MakeHPI/call/Debug/call.hpi"
 #endif
#endif

//##############################################################################
//                コマンド定義
//##############################################################################
#define       HpiCmdlistBegin //
#define       HpiCmdlistEnd //
#define ctype HpiCmdlistSectionBegin(%1) //
#define       HpiCmdlistSectionEnd //
#define ctype HpiCmd___(%1, %2) #cmd %2@ %1
#define ctype HpiCmdS__(%1, %2) #cmd %2@ %1
#define ctype HpiCmd_F_(%1, %2) #cmd %2@ %1
#define ctype HpiCmdSF_(%1, %2) #cmd %2@ %1
#define ctype HpiCmd__V(%1, %2) #cmd %2@ %1
#define ctype HpiCmdS_V(%1, %2) #cmd %2@ %1
#define ctype HpiCmd_FV(%1, %2) #cmd %2@ %1
#define ctype HpiCmdSFV(%1, %2) #cmd %2@ %1

#regcmd "_hsp3typeinfo_call@4", STR_CALL_HPI_PATH, 1

#include "callcmd.cmdlist.txt"

// call core
/*
#cmd call              0x000	// ラベル命令・関数を呼び出す
#cmd call_alias        0x001	// 変数を引数のエイリアスにする
#cmd call_aliasAll     0x002	// 〃( 一括 )
#cmd call_retval       0x003	// ラベル関数の戻り値を設定
#cmd call_dec          0x004	// ラベル命令・関数の仮引数宣言

#cmd call_arginfo      0x100	// 引数情報を取得する( 以下の ARGINFOID_* 参照 )
#cmd call_argv         0x101	// 引数の値と取得する
#cmd call_getlocal     0x102	// local 変数の値を取得する
#cmd call_result       0x103	// 直前のラベル関数で返却された値を取得する

#cmd call_thislb       0x200	// 呼び出されたラベル

// call extra
#cmd functor           0x030	// functor 型変数の宣言、型変換、型タイプ値
#cmd functor_prminfo   0x130	// functor の仮引数情報

#cmd argbind           0x120	// 引数束縛・部分適用
#cmd unbind            0x121	// 束縛解除 (被束縛関数の取得)
#cmd call_funcexpr     0x12A	// 式からの関数生成

#cmd call_stream_begin 0x010	// ストリーム呼び出し::準備
#cmd call_stream_label 0x011	// ストリーム呼び出し::ジャンプ先ラベルの設定
#cmd call_stream_add   0x012	// ストリーム呼び出し::引数の追加
#cmd call_stream_end   0x013	// ストリーム呼び出し::呼び出し処理
#cmd call_stream       0x013	// 〃
#cmd stream_call_new   0x126	// ストリーム呼び出しオブジェクトの生成
#cmd stream_call_add   0x014	// ストリーム呼び出しオブジェクト::引数追加

#cmd co_begin          0x060	// (予約)
#cmd co_end            0x061	// (予約)
;#cmd co_yield         0x062	// 中断
#cmd co_yield_impl     0x063	// 
;#cmd co_exit          0x064	// 終了
#cmd co_create         0x140	// 新しい coroutine を生成する

// method jack
#cmd method_replace    0x020	// メソッド呼び出し関数を掠奪する
#cmd method_add        0x021	// メソッド追加
#cmd method_cloneThis  0x022	// this 変数をクローン

// modcls jack
#cmd modcls_init       0x050	// modcls 機能の初期化
#cmd modcls_term       0x051	// modcls 機能の終了処理
#cmd modcls_register_  0x052	// 演算関数の登録
#cmd modcls_newmod     0x053	// newmod
#cmd modcls_delmod     0x054	// delmod
#cmd modcls_nullmod    0x054	// nullmod
#cmd modcls_dupmod     0x055	// dupmod (複製関数)
#cmd modcls_identity   0x150	// クラス識別
#cmd modcls_name       0x151	// クラス名
#cmd modinst_cls       0x15A	// クラス識別
#cmd modinst_clsname   0x15B	// クラス名
#cmd modinst_identify  0x15C	// 参照同一性比較
#cmd modcls_thismod    0x250	// thismod (右辺値用)

#cmd call_byref        0x210	// (kw-prefix) 変数の参照渡しを明示する
;#cmd call_bythismod    0x211	// (kw-prefix) 〃 modvar 引数と明示する
#cmd call_bydef        0x212	// (extra-arg) 省略引数であると明示する
#cmd call_nobind       0x213	// (extra-arg) 束縛しないことを明示する (for argbind)
#cmd call_prmof        0x214	// (extra-val) 受け取る仮引数を明示する (for funcexpr)
#cmd call_valof        0x215	// (extra-val) 内部でおいた値を参照する (for funcexpr)
#cmd call_nocall       0x216	// (extra-idx) functor で、添字をつけたが呼び出しをしないことを示す
#cmd call_byflex       0x217	// (extra-arg) 可変長引数への連結を明示する

#cmd call_test         0x0FF	// テスト

// utility for call
#cmd axcmdOf           0x110	// コマンドを数値化する
#cmd labelOf           0x111	// ユーザ定義命令・関数からラベルを得る

// extra commands
#cmd callcmd           0x0FF	// コマンド呼び出し

//*/


//##########################################################
//    マクロ
//##########################################################
#define global __call_empty__// empty

// キーワード
#define global byref     call_byref_     ||	// 参照渡し引数 (明示)
#define global bythismod call_bythismod_ ||	// thismod 渡し (明示)
/*
#define global arginfo   call_arginfo
#define global thislb    call_thislb
#define global bydef     call_bydef			// 省略引数     (明示)
#define global nobind    call_nobind		// 不束縛引数   (明示)
#define global nocall    call_nocall		// 呼び出しなし (フラグ)
//*/

#define global argcount arginfo(-1)		// 実引数の数
#define global argc argcount
//#define global argv argVal

#define global call_return(%1) call_setResult_@ (%1) : return

// ラムダ式
#define global __p0 ( call_prmof_@(0) )
#define global __p1 ( call_prmof_@(1) )
#define global __p2 ( call_prmof_@(2) )
#define global __p3 ( call_prmof_@(3) )
#define global __p4 ( call_prmof_@(4) )
#define global __p5 ( call_prmof_@(5) )
#define global __p6 ( call_prmof_@(6) )
#define global __p7 ( call_prmof_@(7) )

#define global __v0 ( lambdaValue_@(0) )
#define global __v1 ( lambdaValue_@(1) )
#define global __v2 ( lambdaValue_@(2) )
#define global __v3 ( lambdaValue_@(3) )
#define global __v4 ( lambdaValue_@(4) )
#define global __v5 ( lambdaValue_@(5) )
#define global __v6 ( lambdaValue_@(6) )
#define global __v7 ( lambdaValue_@(7) )

#define global functor_id axcmdOf( _functor_id@__callmod )	// 恒等写像; 後ろで定義している

// コマンド
#define global ctype callcs(%1) callcmd(%1) : call_byref@	// call_byref はダミー(なんでもいいから1つ必要)
#define global ctype callcf(%1, %2 = __call_empty__) callcmd(%1, call_byref@ %2)	// 〃

#define global insub %tinsub *%i : if(0) : %o :

// コルーチン
#define global coYield(%1) \
	coYield_@ (%1), co_next_label@__callmod :\
	newlab co_next_label@__callmod, 1 :\
	return :

#define global coExit return

//##############################################################################
//                定数を定義
//##############################################################################
#define global functor_vtname "functor_k"
#enum global FuncType_None = 0
#enum global FuncType_Label
#enum global FuncType_AxCmd
#enum global FuncType_Ex
#enum global FuncType_MAX

// arginfo dataID
#enum global ARGINFOID_FLAG = 0	// vartype
#enum global ARGINFOID_MODE		// 変数モード( 0 = 未初期化, 1 = 通常, 2 = クローン )
#enum global ARGINFOID_LEN1		// 一次元目要素数
#enum global ARGINFOID_LEN2		// 二次元目要素数
#enum global ARGINFOID_LEN3		// 三次元目要素数
#enum global ARGINFOID_LEN4		// 四次元目要素数
#enum global ARGINFOID_SIZE		// 全体のバイト数
#enum global ARGINFOID_PTR		// 実体へのポインタ
#enum global ARGINFOID_BYREF	// 参照渡しか
#enum global ARGINFOID_MAX

// 仮引数タイプ
#define global PrmType_None    0
#define global PrmType_Var     (-2)	// 変数参照の要求
#define global PrmType_Array   (-3)	// 配列参照の要求
#define global PrmType_Modvar  (-4)	// modvar 引数
#define global PrmType_Any     (-5)	// 任意の引数
#define global PrmType_Capture (-6)
#define global PrmType_Local   (-7)	// ローカル変数 ( 実引数不要 )
#define global PrmType_Flex    (-1)	// 可変長引数の許可

#define global PrmType_Label  1	// 型タイプ値
#define global PrmType_Str    2
#define global PrmType_Double 3
#define global PrmType_Int    4
#define global PrmType_Struct 5
#define global PrmType_Functor (functor)

// マジックコード
#const global MagicCode_AxCmd     0x20000000
;#const global MagicCode_ModcmdId (0x000C0000 | MagicCode_AxCmd)

;#define global ctype isModcmdId(%1) ( ((%1) & 0xFFFF0000) == MagicCode_ModcmdId )

//##############################################################################
//                モジュール
//##############################################################################
#module __callmod

dim co_next_label@__callmod

// 初期化
;#deffunc local _init
;	return

//------------------------------------------------	
// 引数への参照
// 
// @ 右辺値として使用できない。
//   すなわち、必ず代入文の左辺にすること。
//------------------------------------------------
#define global ctype refarg(%1=0) refarg_var@__callmod(refarg_core(%1))
#defcfunc refarg_core int iArg
	call_alias refarg_var, iArg
	return 0
	
/*
//------------------------------------------------	
// メソッド呼び出し元変数への参照
// 
// @ 右辺値として使用できない。
//------------------------------------------------	
//#define global thisref thisref_var@__callmod(thisref_core())
#defcfunc thisref_core
	method_clonethis thisref_var
	return 0
	
//------------------------------------------------
// メソッド呼び出し元変数の値
// 
// @ 左辺値ではない。
//------------------------------------------------
#define global getthis getthis_core()
#defcfunc getthis_core
	method_clonethis thisref_var
	return           thisref_var
	
//*/

#global
;_init@__callmod

#module

#deffunc _functor_id@__callmod var x
	call_return x

#global

// 後方互換用

#define global funcexpr lambda
#define global argv argVal
#define global call_alias argClone
#define global call_aliasAll argPeekAll
#define global call_setprm(%1, %2) \
dupptr %1, \
	arginfo(ARGINFOID_PTR,  (%2) + 1), \
	arginfo(ARGINFOID_SIZE, (%2) + 1), \
	arginfo(ARGINFOID_FLAG, (%2) + 1)  :
#define global defidOf !!"replace 'defidOf' to 'axcmdOf'"!!

// 仮引数タイプ
#define global PRM_TYPE_NONE    PrmType_None
#define global PRM_TYPE_FLEX    PrmType_Flex
#define global PRM_TYPE_VAR     PrmType_Var
#define global PRM_TYPE_ARRAY   PrmType_Array
#define global PRM_TYPE_MODVAR  PrmType_Modvar
#define global PRM_TYPE_ANY     PrmType_Any
#define global PRM_TYPE_LOCAL   PrmType_Local

#define global PRM_TYPE_LABEL  PrmType_Label
#define global PRM_TYPE_STR    PrmType_Str
#define global PRM_TYPE_DOUBLE PrmType_Double
#define global PRM_TYPE_INT    PrmType_Int
#define global PRM_TYPE_STRUCT PrmType_Struct

	// label 型の比較演算を定義
	call_defineLabelComparison

#endif
