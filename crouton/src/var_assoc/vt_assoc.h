// assoc - VarProc header

#ifndef IG_ASSOC_VARPROC_H
#define IG_ASSOC_VARPROC_H

#include <map>
#include <string>

#include "hsp3plugin_custom.h"
#include "HspAllocator.h"
#include "ManagedPVal.h"

extern int g_vtAssoc;
extern HspVarProc* g_hvpAssoc;

namespace hpimod
{
	namespace Detail
	{
		using hspstr_t = std::basic_string<char, std::char_traits<char>, HspAllocator<char>>;

		template<typename TKey, typename TValue>
		using hspmap_t = std::map< TKey, TValue, std::less<TKey> /*, HspAllocator<std::pair<TKey, TValue>>*/ >;
	}
}

using assocKey_t = hpimod::Detail::hspstr_t const;
using assocValue_t = hpimod::ManagedVarData;
using assoc_t = hpimod::Managed<
	hpimod::Detail::hspmap_t<assocKey_t, assocValue_t>,
	false
> ;

// 関数
extern void HspVarAssoc_Init(HspVarProc*);
extern assoc_t code_get_assoc();
extern PVal* code_get_assocInner();
extern int SetReffuncResult(PDAT** ppResult, assoc_t&& assoc);

extern PVal* assocAt(assoc_t self, APTR offset);
extern APTR assocFindDynamic(assoc_t self, assocKey_t const& key);
extern APTR assocFindStatic(assoc_t self, assocKey_t const& key);

// traits
using vtAssoc = hpimod::VtTraits::NativeVartypeTag<assoc_t>;

namespace hpimod
{
	namespace VtTraits
	{

		namespace Impl
		{
			template<> struct master_type<vtAssoc> { using type = PVal*; };
			template<> static vartype_t vartype<vtAssoc>() { return g_vtAssoc; }
		}

#if 1
		// 添字
		// (上位2バイトを assoc の添字として、残りを内部変数を示す添字として使う。)
		// 連続代入の際に添字が加算されるのに合わせておく必要がある。
		// 負数になるとどこかでエラーを吐かれる可能性があるので、最上位ビットは 0 に保つ。
		static size_t assocElementsMax = 0x80;
		static size_t assocIndexInnerMask = 0x00FFFFFF;
		static size_t getIndexOfAssoc(PVal const* pval) {
			return (pval->offset & 0x7F000000) >> 24;
		}
		static size_t getIndexOfAssocInner(PVal const* pval) {
			return (pval->offset & assocIndexInnerMask);
		}
		static size_t makeIndexOfAssoc(APTR assocOffset, APTR innerOffset) {
			assert(0 <= assocOffset && static_cast<size_t>(assocOffset) < assocElementsMax);
			assert(0 <= innerOffset && innerOffset < 0x08000000);
			return (assocOffset << 24 | innerOffset);
		}

		template<> static assoc_t* getValptr<vtAssoc>(PVal* pval)
		{
			return asValptr<vtAssoc>(pval->pt) + getIndexOfAssoc(pval);
		}
		template<> static assoc_t const* getValptr<vtAssoc>(PVal const* pval)
		{
			return asValptr<vtAssoc>(pval->pt) + getIndexOfAssoc(pval);
		}

		static PVal const* getAssocInnerVar(PVal const* pvalAssoc)
		{
			assert(pvalAssoc->flag == g_vtAssoc);
			APTR const aptrInner = getIndexOfAssocInner(pvalAssoc);
			if ( pvalAssoc->arraycnt == 0 || aptrInner == assocIndexInnerMask ) {
				return nullptr;
			} else {
				assoc_t const& self = *getValptr<vtAssoc>(pvalAssoc);
				return assocAt(self, aptrInner);
			}
		}
		static PVal* getAssocInnerVar(PVal* pvalAssoc) { return const_cast<PVal*>(getAssocInnerVar(static_cast<PVal const*>(pvalAssoc))); }
		static int assocIndexFullslice = -100;
#endif
	}
};

#endif
