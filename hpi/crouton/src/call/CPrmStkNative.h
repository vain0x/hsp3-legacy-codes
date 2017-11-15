// prmstack
// HSP由来のもの

#ifndef IG_CLASS_PARAMETER_STACK_NATIVE_H
#define IG_CLASS_PARAMETER_STACK_NATIVE_H

/**
@summary:
prmstk と同じ形式でデータを格納する処理のインターフェースとなるクラス。
**/

#include <cassert>
#include <type_traits>
#include "hsp3plugin.h"

class CPrmStk;

class CPrmStkNative
{
private:
	// スタックの先頭へのポインタとサイズ
	void* ptr_;
	size_t bufSize_;

	// 使用されたサイズ
	size_t usingSize_;

public:
	CPrmStkNative(void* prmstk, size_t size)
		: ptr_ { prmstk }
		, bufSize_ { size }
		, usingSize_ { 0 }
	{ }

	// 取得
	void* get() const { return ptr_; }
	size_t capacity() const { return bufSize_; }
	size_t stackPos() const { return usingSize_; }

private:
	void* begin() const { return ptr_; }
	void* end() const { return reinterpret_cast<char*>(ptr_) + usingSize_; }

public:
	// push

	template<typename T> void pushValue( T&& value );
	
	// 領域だけ確保、初期化はしない
	template<typename T> T* allocValue();

	void pushPVal(MPVarData const& vardata) {
		pushValue(vardata);
	}
	void pushThismod(PVal* pval, APTR aptr, int idStDat) {
		pushValue(MPModVarData { idStDat, MODVAR_MAGICCODE, pval, aptr });
	}
	PVal* allocLocal() { return allocValue<PVal>(); }

private:
	// 使用するサイズの宣言
	void needAdditionalSize( size_t sizeAdditional ) {
		if ( bufSize_ < (usingSize_ + sizeAdditional) ) {
			puterror( HSPERR_OUT_OF_MEMORY );
		}
	}

private:
	// for CPrmStk
	void* allocBlank(size_t size) {
		needAdditionalSize(size);
		void* const p = end();
		usingSize_ += size;
		return p;
	}

	friend CPrmStk;

public:
	// peek

	template<typename T> T const& peekValue(size_t offset) const;
	char const* const& peekString(size_t offset) const { return peekValue<char const*>(offset); }
	MPVarData const& peekPVal(size_t offset) const { return peekValue<MPVarData const>(offset); }
	MPModVarData const& peekThismod(size_t offset) const {
		auto& modvar = peekValue<MPModVarData const>(offset);
		assert(modvar.magic == MODVAR_MAGICCODE);
		return modvar;
	}

private:
	void const* peekOffsetAt(size_t offset) const {
		assert(offset < capacity());
		return reinterpret_cast<char const*>(ptr_) + offset;
	}
};

//------------------------------------------------
// 単純に値をプッシュする
//------------------------------------------------
template<typename T>
void CPrmStkNative::pushValue(T&& value)
{
	using value_type = std::decay_t<T>;

	value_type* const p = allocValue<value_type>();
	*p = std::forward<T>(value);
	return;
}

template<typename T>
T* CPrmStkNative::allocValue()
{
	return reinterpret_cast<T*>(allocBlank(sizeof(T)));
}

template<typename T> T const& CPrmStkNative::peekValue(size_t offset) const
{
	static_assert(!std::is_same<std::remove_const_t<T>, char>::value, "suggestion: [T = char*]?");
	return *reinterpret_cast<T const*>(peekOffsetAt(offset));
}

#endif
