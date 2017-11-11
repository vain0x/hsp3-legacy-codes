// Header - TreeView

#ifndef IG_HEADER_TREEVIEW_AS
#define IG_HEADER_TREEVIEW_AS

#define global WC_TREEVIEWA	"SysTreeView32"
#define global WC_TREEVIEW	WC_TREEVIEWA

#define global TVM_INSERTITEM			0x1100		// 新しいアイテムを追加
#define global TVM_DELETEITEM			0x1101		// アイテムを削除
#define global TVM_EXPAND				0x1102		// アイテムを開く・閉じる
#define global TVM_GETITEMRECT			0x1104		// 指定項目のRECTを取得
#define global TVM_GETCOUNT				0x1105		// アイテム数の取得
#define global TVM_GETINDENT			0x1106		// 親項目に対する相対的なインデントを取得
#define global TVM_SETINDENT			0x1107		// インデントを設定する
#define global TVM_GETIMAGELIST			0x1108		// イメージリストを取得
#define global TVM_SETIMAGELIST			0x1109		// イメージリストを設定
#define global TVM_GETNEXTITEM			0x110A		// 指定されたアイテムを取得
#define global TVM_SELECTITEM			0x110B		// アイテムを選択する
#define global TVM_GETITEM				0x110C		// アイテムの属性を取得
#define global TVM_SETITEM				0x110D		// アイテムの属性を設定
#define global TVM_EDITLABEL			0x110E		// 
#define global TVM_GETEDITCONTROL		0x110F		// 編集に使用されているEditControlのハンドルを得る
#define global TVM_GETVISIBLECOUNT		0x1110		// 表示可能なアイテム数の取得
#define global TVM_HITTEST				0x1111		// ヒットテスト
#define global TVM_CREATEDRAGIMAGE		0x1112		// 
#define global TVM_SORTCHILDREN			0x1113		// 子アイテムのソート
#define global TVM_ENSUREVISIBLE		0x1114		// 
#define global TVM_SORTCHILDRENCB		0x1115		// 
#define global TVM_ENDEDITLABELNOW		0x1116		// 
#define global TVM_GETISEARCHSTRING		0x1117		// 
#define global TVM_SETTOOLTIPS			0x1118		// 
#define global TVM_GETTOOLTIPS			0x1119		// 
#define global TVM_SETINSERTMARK		0x111A		// 
#define global TVM_SETITEMHILIGHT		0x111B		// 
#define global TVM_GETITEMHILIGHT		0x111C		// 
#define global TVM_SETBKCOLOR			0x111D		// 背景色を設定
#define global TVM_SETTEXTCOLOR			0x111E		// 文字色を設定
#define global TVM_GETBKCOLOR			0x111F		// 背景色を取得
#define global TVM_GETTEXTCOLOR			0x1120		// 文字色を取得
#define global TVM_SETSCROLLTIME		0x1121		// 
#define global TVM_GETSCROLLTIME		0x1122		// 
#define global TVM_SETINSERTMARKCOLOR	0x1125		// 
#define global TVM_GETINSERTMARKCOLOR	0x1126		// 
#define global TVM_GETITEMSTATE			0x1127		// 項目の状態を取得する
#define global TVM_SETLINECOLOR			0x1128		// 
#define global TVM_GETLINECOLOR			0x1129		// 

// ～A メッセージ
#define global TVM_INSERTITEMA			TVM_INSERTITEM
#define global TVM_GETITEMA				TVM_GETITEM
#define global TVM_SETITEMA				TVM_SETITEM
#define global TVM_GETISEARCHSTRINGA	TVM_GETISEARCHSTRING
#define global TVM_EDITLABELA			TVM_EDITLABEL

// ～W メッセージ
#define global TVM_INSERTITEMW			0x1132
#define global TVM_GETITEMW				0x113E
#define global TVM_SETITEMW				0x113F
#define global TVM_GETISEARCHSTRINGW	0x1140
#define global TVM_EDITLABELW			0x1141

// ツリービューのスタイル
#define global TVS_HASBUTTON			0x0001		// ○ +-ボタン
#define global TVS_HASLINES				0x0002		// アイテムを線でつなぐ
#define global TVS_LINESATROOT			0x0004		// 一番上のアイテムに線を付ける。要 TVS_HASLINES
#define global TVS_EDITLABELS			0x0008		// ○アイテム編集
#define global TVS_DISABLEDRAGDROP		0x0010		// ×ドラッグドロップ
#define global TVS_SHOWSELALWAYS		0x0020		// フォーカスなしでも選択
#define global TVS_RTLREADING			0x0040		// 右から左に文字を表示(中東の言語のみ)
#define global TVS_NOTOOLTIPS			0x0080		// ×ツールチップ
#define global TVS_CHECKBOXES			0x0100		// ○チェックボックス
#define global TVS_TRACKSELECT			0x0200		// ○ホット状態の下線
#define global TVS_SINGLEEXPAND			0x0400		// Ｓクリックで他をすべて閉じた上で天界
#define global TVS_INFOTIP				0x0800		// ややこいことをする(ツールチップ情報を得る為、親Windowに TVN_GETINFOTIP 通知メッセージを送りつける。)
#define global TVS_FULLROWSELECT		0x1000		// 列で選択 ( TVS_HASLINES と共用不可 )
#define global TVS_NOSCROLL				0x2000		// ×スクロール
#define global TVS_NONEVENHEIGHT		0x4000		// TVM_SETITEMHEIGHT で、アイテムの高さを設定可能。(デフォルトでは均等)
#define global TVS_NOHSCROLL			0x8000		// TVS_NOSCROLL overrides this

// 通知コード
#define global TVN_SELCHANGING			(-401)		// 選択項目が変わろうとしている
#define global TVN_SELCHANGED			(-402)		// 選択項目が変わった
#define global TVN_GETDISPINFO			(-403)		// 
#define global TVN_SETDISPINFO			(-404)		// 
#define global TVN_ITEMEXPANDING		(-405)		// 開こうとしている
#define global TVN_ITEMEXPANDED			(-406)		// 開いた
#define global TVN_BEGINDRAG			(-407)		// 項目のドラッグが開始された
#define global TVN_BEGINRDRAG			(-408)		// 
#define global TVN_DELETEITEM			(-409)		// アイテムが削除される
#define global TVN_BEGINLABELEDIT		(-410)		// テキストの編集が始まった
#define global TVN_ENDLABELEDIT			(-411)		// テキストの編集が終了した
#define global TVN_KEYDOWN				(-412)		// キーが入力された

// Wide 版通知コード
#define global TVN_SELCHANGINGW			(-450)
#define global TVN_SELCHANGEDW			(-451)
#define global TVN_GETDISPINFOW			(-452)
#define global TVN_ITEMEXPANDINGW		(-454)
#define global TVN_SETDISPINFOW			(-453)
#define global TVN_ITEMEXPANDEDW		(-455)
#define global TVN_BEGINDRAGW			(-456)
#define global TVN_BEGINRDRAGW			(-457)
#define global TVN_DELETEITEMW			(-458)
#define global TVN_BEGINLABELEDITW		(-459)
#define global TVN_ENDLABELEDITW		(-460)

// 項目の状態( ItemStatus )
#define global TVIS_SELECTED			0x0002		// 選択されている
#define global TVIS_CUT					0x0004		// 
#define global TVIS_DROPHILITED			0x0008		// ハイライトされている
#define global TVIS_BOLD				0x0010		// 強調されている
#define global TVIS_EXPANDED			0x0020		// 開いている
#define global TVIS_EXPANDEDONCE		0x0040		// 
#define global TVIS_EXPANDPARTIAL		0x0080		// 
#define global TVIS_OVERLAYMASK			0x0F00		// 
#define global TVIS_STATEIMAGEMASK		0xF000		// 
#define global TVIS_USERMASK			0xF000		// 

// TVITEM 構造体の mask
#define global TVIF_TEXT				0x0001		// 
#define global TVIF_IMAGE				0x0002		// 
#define global TVIF_PARAM				0x0004		// 
#define global TVIF_STATE				0x0008		// 
#define global TVIF_HANDLE				0x0010		// 
#define global TVIF_SELECTEDIMAGE		0x0020		// 
#define global TVIF_CHILDREN			0x0040		// 
#define global TVIF_INTEGRAL			0x0080		// 

// 項目のインデックス
#define global TVI_ROOT					0xFFFF0000	// ルート要素のとき、hParent に指定する
#define global TVI_FIRST				0xFFFF0001	// リストの先頭に追加する
#define global TVI_LAST					0xFFFF0002	// リストの最後に追加する
#define global TVI_SORT					0xFFFF0003	// 文字列でソートして追加する

#define global I_CHILDRENCALLBACK			1		// 子要素を親が描画する

// TVM_EXPAND の定数
#define global TVE_COLLAPSE				0x0001		// 閉じる
#define global TVE_EXPAND				0x0002		// 開く
#define global TVE_TOGGLE				0x0003		// 開閉切り替え
#define global TVE_EXPANDPARTIAL		0x4000		// ( | TVE_EXPAND   ) 一部のみを開く
#define global TVE_COLLAPSERESET		0x8000		// ( | TVE_COLLAPSE ) 閉じて削除

// イメージリストの定数
#define global TVSIL_NORMAL				0x0000		// 項目の選択状態と非選択状態のイメージを持つ
#define global TVSIL_STATE				0x0002		// ユーザー定義の特殊なイメージを持つ

// TVM_GETNEXTITEM の定数
#define global TVGN_ROOT				0x0000		// 根ノード
#define global TVGN_NEXT				0x0001		// 兄ノード
#define global TVGN_PREVIOUS			0x0002		// 弟ノード
#define global TVGN_PARENT				0x0003		// 親ノード
#define global TVGN_CHILD				0x0004		// 子ノードの先頭
#define global TVGN_FIRSTVISIBLE		0x0005		// 可視状態の最初のノード
#define global TVGN_NEXTVISIBLE			0x0006		// 指定ノードの次に見えているノード( 指定ノードは見えている必要あり )
#define global TVGN_PREVIOUSVISIBLE		0x0007		// 指定ノードの前に見えているノード( 指定ノードは見えている必要あり )
#define global TVGN_DROPHILITE			0x0008		// Ｄ＆Ｄの対象になっているノード
#define global TVGN_CARET				0x0009		// 選択されているノード
#define global TVGN_LASTVISIBLE			0x000A		// 最後に開かれたノード

// ヒットテストの定数 ( HitTest )
#define global TVHT_NOWHERE				0x0001		// ツリービュー上ではない
#define global TVHT_ONITEMICON			0x0002		// 項目のアイコン
#define global TVHT_ONITEMLABEL			0x0004		// 項目のラベル
#define global TVHT_ONITEMINDENT		0x0008		// 枝
#define global TVHT_ONITEMBUTTON		0x0010		// +- ボタン
#define global TVHT_ONITEMRIGHT			0x0020		// 項目の右にある空白
#define global TVHT_ONITEMSTATEICON		0x0040		// 
#define global TVHT_ONITEM		(TVHT_ONITEMICON | TVHT_ONITEMLABEL | TVHT_ONITEMSTATEICON)
#define global TVHT_ABOVE				0x0100		// 
#define global TVHT_BELOW				0x0200		// 
#define global TVHT_TORIGHT				0x0400		// 
#define global TVHT_TOLEFT				0x0800		// 

// 変更の原因 ( Change )
#define global TVC_UNKNOWN				0x0000		// なにか
#define global TVC_BYMOUSE				0x0001		// マウス操作
#define global TVC_BYKEYBOARD			0x0002		// キーボード入力

// ???
#define global TVNRET_DEFAULT				0		// 
#define global TVNRET_SKIPOLD				1		// 
#define global TVNRET_SKIPNEW				2		// 

#endif
