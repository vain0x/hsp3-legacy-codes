
#include "CPrmStk.h"

#include "Invoker.h"
#include "CBound.h"

using namespace hpimod;

//------------------------------------------------
// 構築
//------------------------------------------------
CPrmStk::CPrmStk(CPrmInfo const& prminfo)
	: super_t(hspmalloc(prminfo.getStackSize() + headerSize) + headerSize, prminfo.getStackSize() + headerSize)
	, prminfo_ { prminfo }
	, cntArgs_ { 0 }
	, finalized_ { false }
{
	std::memset(getptr(), 0x00, capacity());

	getHeader(super_t::getptr()).magicCode = MagicCode;
}

//------------------------------------------------
// 文字列値のプッシュ
//
// @ prmstk 用にコピーを取る。破棄時に解放。
//------------------------------------------------
void CPrmStk::pushString(char const* src)
{
	assert(!hasFinalized());
	assert(getNextPrmType() == HSPVAR_FLAG_STR);
	incCntArgs();

	char** const p = allocValue<char*>();
	size_t const len = std::strlen(src);
	size_t const size = len * sizeof(char) + 1;
	*p = hspmalloc(size);
	strcpy_s(*p, size, src);
	return;
}

//------------------------------------------------
// 値渡しの any (PVal* に保存する)
//------------------------------------------------
void CPrmStk::pushAnyByVal(PDAT const* pdat, vartype_t vtype)
{
	assert(!hasFinalized());

	int const prmtype = getNextPrmType();
	assert(prmtype == PrmType::Any || PrmType::isExtendedVartype(prmtype));

	incCntArgs();
	hpimod::ManagedPVal pval;
	hpimod::PVal_assign(pval.valuePtr(), pdat, vtype);
	super_t::pushPVal(pval.valuePtr(), 0);
	pval.incRef();	// prmstk による所有
	return;
}

//------------------------------------------------
// 参照渡しの any (管理の必要はない)
//------------------------------------------------
void CPrmStk::pushAnyByRef(PVal* pval, APTR aptr)
{
	assert(!hasFinalized());
	assert(getNextPrmType() == PrmType::Any);

	incCntArgs();
	super_t::pushPVal(pval, aptr);
	return;
}

//------------------------------------------------
// var, array, thismod
//------------------------------------------------
void CPrmStk::pushPVal(PVal* pval, APTR aptr)
{
	assert(!hasFinalized());
	assert(getNextPrmType() == PrmType::Var);

	incCntArgs();
	super_t::pushPVal(pval, aptr);
	return;
}

void CPrmStk::pushPVal(PVal* pval)
{
	assert(!hasFinalized());
	assert(getNextPrmType() == PrmType::Array);

	incCntArgs();
	super_t::pushPVal(pval, 0);
	return;
}

void CPrmStk::pushThismod(PVal* pval, APTR aptr)
{
	assert(!hasFinalized());

	if ( getNextPrmType() != PrmType::Modvar ) puterror(HSPERR_ILLEGAL_FUNCTION);
	if ( pval->flag != HSPVAR_FLAG_STRUCT ) puterror(HSPERR_TYPE_MISMATCH);

	incCntArgs();
	auto const fv = VtTraits::getValptr<vtStruct>(pval);
	super_t::pushThismod(pval, aptr, FlexValue_getModuleTag(fv)->subid);
	return;
}

//------------------------------------------------
// 一般、値渡し
//------------------------------------------------
void CPrmStk::pushArgByVal(PDAT const* pdat, vartype_t vtype)
{
	int const prmtype = getNextPrmType();
	if ( PrmType::isNativeVartype(prmtype) ) {
		if ( vtype != prmtype ) puterror(HSPERR_TYPE_MISMATCH);
			switch ( prmtype ) {
			case HSPVAR_FLAG_LABEL:  return pushValue<vtLabel>(pdat);
			case HSPVAR_FLAG_DOUBLE: return pushValue<vtDouble>(pdat);
			case HSPVAR_FLAG_INT:    return pushValue<vtInt>(pdat);
			case HSPVAR_FLAG_STR:    return pushString(VtTraits::asValptr<vtStr>(pdat));
			default: assert(false);
		}

	} else if ( prmtype == PrmType::Any ) {
		return pushAnyByVal(pdat, vtype);

	} else {
		// 拡張型 => 型チェック付き any
		if ( PrmType::isExtendedVartype(prmtype) ) {
			if ( vtype != prmtype ) puterror(HSPERR_TYPE_MISMATCH);
			return pushAnyByVal(pdat, vtype);
		}
		puterror((PrmType::isRef(prmtype) ? HSPERR_VARIABLE_REQUIRED : HSPERR_ILLEGAL_FUNCTION));
	}
}

//------------------------------------------------
// 一般、参照渡し
//------------------------------------------------
void CPrmStk::pushArgByRef(PVal* pval, APTR aptr)
{
	int const prmtype = getNextPrmType();

	switch ( prmtype ) {
		case PrmType::Var:    pushPVal(pval, aptr); break;
		case PrmType::Array:  pushPVal(pval); break;
		case PrmType::Any:    pushAnyByRef(pval, aptr); break;
		case PrmType::Modvar: pushThismod(pval, aptr); break;
		default:
			puterror(HSPERR_ILLEGAL_FUNCTION);
	}
}

//------------------------------------------------
// 一般、引数省略
//------------------------------------------------
void CPrmStk::pushArgByDefault()
{
	int const prmtype = getNextPrmType();

	switch ( prmtype ) {
		case HSPVAR_FLAG_LABEL:  puterror(HSPERR_LABEL_REQUIRED);
		case HSPVAR_FLAG_STRUCT: puterror(HSPERR_STRUCT_REQUIRED);

		case HSPVAR_FLAG_INT:
		case PrmType::Any:
		{
			static int const zero = 0;
			pushArgByVal(VtTraits::asPDAT<vtInt>(&zero), HSPVAR_FLAG_INT);
			break;
		}
		default:
#if 0
			// 型タイプ値の引数 => その型の既定値
			if ( PrmType::isVartype(prmtype) ) {
				PVal* const pvalDefault = hpimod::PVal_getDefault(prmtype);
				pushArgByVal(pvalDefault->pt, pvalDefault->flag);
				break;
			}
#endif
			;
	}
	puterror((PrmType::isRef(prmtype) ? HSPERR_VARIABLE_REQUIRED : HSPERR_NO_DEFAULT));
}

//------------------------------------------------
// 不束縛引数のプッシュ
//
// @ unsigned short[2] として扱う。
//------------------------------------------------
void CPrmStk::allocArgNoBind(unsigned short priority)
{
	int const prmtype = getNextPrmType();
	size_t const size = PrmType::sizeOf(prmtype);
	assert(size >= sizeof(unsigned short[2]));

	incCntArgs();
	auto const p = static_cast<unsigned short*>(allocBlank(size));
	p[0] = priority;
	p[1] = MagicCodeNoBind;
	return;
}

unsigned short* CPrmStk::peekArgNoBind(size_t idx) const
{
	assert(idx < cntArgs());
	auto const p = reinterpret_cast<unsigned short*>(getArgPtrAt(idx));
	return (p[1] == MagicCodeNoBind ? p : nullptr);
}

//------------------------------------------------
// 値渡し引数の参照
//
// @ any は参照渡しでも値を取る。配列なら (0) を返す。
// @ 参照渡し引数は取り出さない。
//------------------------------------------------
PDAT* CPrmStk::peekValArgAt(size_t idx, vartype_t& vtype) const
{
	int const prmtype = prminfo_.getPrmType(idx);
	auto const ptr = getArgPtrAt(idx);
	if ( PrmType::isNativeVartype(prmtype) ) {
		vtype = prmtype;
		return ( prmtype == HSPVAR_FLAG_STR )
			? VtTraits::asPDAT<vtStr>(*reinterpret_cast<char**>(ptr))
			: reinterpret_cast<PDAT*>(ptr);

	} else if ( PrmType::isExtendedVartype(prmtype) || prmtype == PrmType::Any || prmtype == PrmType::Var ) {
		auto& vardata = *reinterpret_cast<MPVarData*>(getArgPtrAt(idx));
		assert(vardata.aptr <= 0);
		vtype = vardata.pval->flag;
		return vardata.pval->pt;

	} else {
		puterror(HSPERR_TYPE_MISMATCH);
	}
}

//------------------------------------------------
// 参照渡し引数の参照
//------------------------------------------------
PVal* CPrmStk::peekRefArgAt(size_t idx) const
{
	int const prmtype = prminfo_.getPrmType(idx);
	switch ( prmtype ) {
		case PrmType::Var:
		case PrmType::Array:
		case PrmType::Any:
		{
			auto& vardata = *reinterpret_cast<MPVarData*>(getArgPtrAt(idx));
			assert(vardata.aptr >= 0);
			vardata.pval->offset = vardata.aptr;
			return vardata.pval;
		}
		case PrmType::Modvar:
		{
			auto& thismod = *reinterpret_cast<MPModVarData*>(getArgPtrAt(idx));
			assert(thismod.magic == MODVAR_MAGICCODE);
			thismod.pval->offset = thismod.aptr;
			return thismod.pval;
		}
		default: puterror(HSPERR_VARIABLE_REQUIRED);
	}
}

//------------------------------------------------
// finalize
// 
// @ prmstk を最後まで確保する。
//------------------------------------------------
void CPrmStk::finalize()
{
	assert(!hasFinalized());

	// 残りの数だけ既定引数を積む
	for ( size_t i = cntArgs(); i < prminfo_.cntPrms(); ++i ) {
		pushArgByDefault();
	}

	// captures (only allocating)
	for ( size_t i = 0; i < prminfo_.cntCaptures(); ++i ) {
		assert(super_t::size() == getPrmInfo().getStackOffsetCapture(i));
		super_t::pushPVal(nullptr, 0);
	}

	// locals
	for ( size_t i = 0; i < prminfo_.cntLocals(); ++i ) {
		assert(super_t::size() == getPrmInfo().getStackOffsetLocal(i));
			PVal* const pval = super_t::allocLocal();
		hpimod::PVal_init(pval, HSPVAR_FLAG_INT);
	}

	// flex
	if ( prminfo_.isFlex() ) {
		assert(super_t::size() == getPrmInfo().getStackOffsetFlex());
		vector_t* const vec = allocValue<vector_t>();
		new(vec)vector_t {};
	}

	assert(super_t::size() == getPrmInfo().getStackSize());
	finalized_ = true;
	return;
}

//------------------------------------------------
// 解体
//
// @ 実引数の取り出しの途中で死亡することもあるので注意したい。
//------------------------------------------------
void CPrmStk::free()
{
	void* const prmstk = getPrmStkPtr();
	assert(!!prmstk);

	// スタック上の管理されたオブジェクトを解放する
	for ( size_t i = 0; i < cntArgs(); ++i ) {
		int const prmtype = prminfo_.getPrmType(i);
			switch ( prmtype ) {
			case HSPVAR_FLAG_STR:
			{
				vartype_t vtype;
				auto const p = VtTraits::asValptr<vtStr>(peekValArgAt(i, vtype));
				assert(!!p && vtype == HSPVAR_FLAG_STR);
				hspfree(p);
				break;
			}
			case PrmType::Any:
			{
				auto&& pval = ManagedPVal::ofValptr(peekRefArgAt(i));
				pval.decRef();
				break;
			}
		}
	}

	if ( hasFinalized() ) {
		for ( size_t i = 0; i < prminfo_.cntCaptures(); ++i ) {
			ManagedPVal::ofValptr(peekCaptureAt(i)->pval).decRef();
		}
		for ( size_t i = 0; i < prminfo_.cntLocals(); ++i ) {
			PVal* const pval = peekLocalAt(i);
			PVal_free(pval);
		}
		if ( vector_t* const flex = peekFlex() ) {
			flex->decRef();
		}
	}

	hspfree(getOwnerPtr());
}

//------------------------------------------------
// 複製
//------------------------------------------------
CPrmStk::CPrmStk(CPrmStk const& src)
	: CPrmStk(src.getPrmInfo())
{
	for ( size_t i = 0; i < src.cntArgs(); ++i ) {
		pushArgFromPrmStk(src, i);
	}
	assert(cntArgs() == src.cntArgs());

	pushFinalsFrom(src);
	return;
}

CPrmStk::CPrmStk(CPrmStk&& src)
	: prminfo_(src.getPrmInfo())
	, CPrmStkCreator(std::move(src))
{ }

//------------------------------------------------
// prmstk 上の値の push
//
// for CBound (todo: CBound との分離)
// src の idxSrc 番目の実引数を push する。
// それが nobind なら、対応する実引数を argsManeged から取り出して push する。
//------------------------------------------------
void CPrmStk::pushArgFromPrmStk(CPrmStk const& src, size_t idxSrc, CBound* boundfunc, CPrmStk* argsMerged)
{
	auto const prmtype = getNextPrmType();
	auto const srcPrmtype = src.getPrmInfo().getPrmType(idxSrc);

	if ( auto const p = src.peekArgNoBind(idxSrc) ) {
		if ( !boundfunc ) {
			allocArgNoBind(*p);

		} else {
			// merge 処理

			assert(argsMerged);

			// 対応する添字の検索
			// prmIdxAssoc: (idxMerged: 束縛関数 f への実引数の添字) -> (idxNext: unbind(f) の束縛されていない引数の添字)
			auto const& prmIdxAssoc = boundfunc->getPrmIdxAssoc();
			size_t const idxNext = cntArgs();
			auto const iter = std::find(prmIdxAssoc.begin(), prmIdxAssoc.end(), idxNext);
			assert(iter != prmIdxAssoc.end());
			size_t const idxMerged = std::distance(prmIdxAssoc.begin(), iter);
			assert(prmIdxAssoc[idxMerged] == idxNext);

			//dbgout("merge: %d <- merged[%d]", idxNext, idxMerged);

			pushArgFromPrmStk(*argsMerged, idxMerged, nullptr);
		}

	} else if ( PrmType::isRef(prmtype)
		|| (prmtype == PrmType::Any && (PrmType::isRef(srcPrmtype) || srcPrmtype == PrmType::Any))
		) {
		auto const ref = src.peekRefArgAt(idxSrc);
		pushArgByRef(ref, ref->offset);

	} else {
		vartype_t vtype;
		auto const pdat = src.peekValArgAt(idxSrc, vtype);
		pushArgByVal(pdat, vtype);
	}
	return;
}

void CPrmStk::pushFinalsFrom(CPrmStk const& src)
{
	if ( src.hasFinalized() ) {
		finalize();

		auto& prms = src.getPrmInfo();

		// captures : 未実装
		assert(prms.cntCaptures() == 0);

		// locals
		for ( size_t i = 0; i < prms.cntLocals(); ++i ) {
			PVal_copy(peekLocalAt(i), src.peekLocalAt(i));
		}

		// flex
		if ( auto const flex = peekFlex() ) {
			auto const srcFlex = src.peekFlex();
			assert(srcFlex);

			*flex = *srcFlex;
		}
	}
	return;
}

//------------------------------------------------
// for CBound
//------------------------------------------------
void CPrmStk::merge(CPrmStk const& src, CBound& boundfunc, CPrmStk& argsMerged)
{
	//dbgout("this.cntArgs = %d, this.cntPrms = %d, src.cntArgs = %d, src.cntPrms = %d", cntArgs(), getPrmInfo().cntPrms(), src.cntArgs(), src.getPrmInfo().cntPrms());
	for ( size_t i = 0; i < src.cntArgs(); ++i ) {
		pushArgFromPrmStk(src, i, &boundfunc, &argsMerged);
	}
	assert(cntArgs() == src.cntArgs());
	
	pushFinalsFrom(src);
	return;
}

//------------------------------------------------
// キャプチャ引数
//
// ラムダ関数が内部的に持つキャプチャリストを流し込む
// prmstk はこれらの ManagedVarData を所有しない
//
// for CLambda
//------------------------------------------------
void CPrmStk::importCaptures(vector_t const& captured)
{
	assert(hasFinalized());
	assert(prminfo_.cntCaptures() == captured->size());

	for ( size_t i = 0; i < captured->size(); ++i ) {
		auto const vardata = peekCaptureAt(i);
		auto const& iter = captured->at(i);

		assert(!vardata->pval);
		*vardata = { iter.getPVal(), iter.getAptr() };
	}
	return;
}

//------------------------------------------------
// 
//------------------------------------------------
