// 関数子インターフェース

// 「呼び出せるもの」を表すために、プラグイン側で作成するクラスたちの基底クラス。
// 例えば、CLabelFunc, CBound, CLambda などに継承されている。

// Managed<> に入れて functor_t として使われる。

#ifndef IG_INTERFACE_FUNCTOR_H
#define IG_INTERFACE_FUNCTOR_H

#include "hsp3plugin_custom.h"

class CPrmInfo;
class CPrmStk;
class Caller;

//------------------------------------------------
// 関数子を表すクラス
// 
// @ 継承して使う。
// @ ここでは既定動作を定義している。
//------------------------------------------------
class IFunctor
{
public:
	virtual ~IFunctor() { }

	// 取得
	virtual hpimod::label_t getLabel() const { return nullptr; }
	virtual int getAxCmd() const { return 0; }

	virtual int getUsing() const { return 0; }			// 使用状況 (0: 無効, 1: 有効, 2: クローン)
	virtual CPrmInfo const& getPrmInfo() const = 0;		// 仮引数

	// キャスト
	template<typename T> T*           castTo()       { return static_cast<T*>(this); }
	template<typename T> T const*     castTo() const { return static_cast<T const*>(this); }
	template<typename T> T*       safeCastTo()       { return dynamic_cast<T*>(this); }
	template<typename T> T const* safeCastTo() const { return dynamic_cast<T const*>(this); }

	// 動作
	virtual void call(Caller&) = 0;

	// 形式的比較
	virtual int compare(IFunctor const& obj) const { return this - &obj; }
};

#endif
