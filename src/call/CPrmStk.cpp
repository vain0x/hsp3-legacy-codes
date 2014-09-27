
#include "CPrmStk.h"

#include "Invoker.h"
#include "CBound.h"

using namespace hpimod;

//------------------------------------------------
// private members
//------------------------------------------------
struct CPrmStk::Impl
{
	//CPrmStk* this_;

	CPrmInfo const& prminfo_;

	CPrmStkNative prmstk_;

	// 現在、追加された実引数の個数 (flex は除く)
	size_t cntArgs_;

	// 終端部が追加されたか否か
	bool finalized_;

	// prmstk の前に置かれるヘッダー
	struct header_t {
		CPrmStk* thisPtr;
		unsigned short magicCode;
	};
	static int const MagicCode = 0x55AC;
public:
	static header_t& getHeader(void* prmstk) {
		return reinterpret_cast<header_t*>(prmstk)[-1];
	}

	void* getOwnerPtr() { return &getHeader(prmstk_.get()); }
	void incCntArgs() { ++cntArgs_; }
};

//------------------------------------------------
// こまごました public 関数
//------------------------------------------------
CPrmInfo const& CPrmStk::getPrmInfo() const
{
	return p_->prminfo_;
}

prmtype_t CPrmStk::getNextPrmType() const
{
	return getPrmInfo().getPrmType(cntArgs());
}

CPrmStkNative const& CPrmStk::getPrmStk() const
{
	return p_->prmstk_;
}

void* CPrmStk::getPrmStkPtr()
{
	return getPrmStk().get();
}

size_t CPrmStk::cntArgs() const
{
	return p_->cntArgs_;
}

bool CPrmStk::hasFinalized() const {
	return p_->finalized_;
}

CPrmStk* CPrmStk::ofPrmStkPtr(void* prmstk) {
	auto const& header = Impl::getHeader(prmstk);
	return (header.magicCode == Impl::MagicCode ? header.thisPtr : nullptr);
}

//------------------------------------------------
// 構築
//------------------------------------------------
CPrmStk::CPrmStk(CPrmInfo const& prminfo)
	: p_ { new Impl {
		prminfo,
		{ hspmalloc(prminfo.getStackSize() + sizeof(Impl::header_t)) + sizeof(Impl::header_t),
			prminfo.getStackSize() },
		0,
		false
	} }
{
	std::memset(getPrmStkPtr(), 0x00, getPrmStk().capacity());

	auto& header = Impl::getHeader(getPrmStkPtr());
	header = { this, Impl::MagicCode };
}

//------------------------------------------------
// 単純な値の push
//------------------------------------------------
template<typename VtTag>
void CPrmStk::pushValue(PDAT const* pdat)
{
	assert(!hasFinalized());
	prmtype_t const prmtype = getNextPrmType();
	assert(prmtype == VtTraits::Impl::vartype<VtTag>() && prmtype != HSPVAR_FLAG_STR);

	p_->incCntArgs();
	getPrmStk().pushValue(VtTraits::derefValptr<VtTag>(pdat));
	return;
}

template void CPrmStk::pushValue<vtLabel>(PDAT const* pdat);
template void CPrmStk::pushValue<vtDouble>(PDAT const* pdat);
template void CPrmStk::pushValue<vtInt>(PDAT const* pdat);

//------------------------------------------------
// 文字列値のプッシュ
//
// @ prmstk 用にコピーを取る。破棄時に解放。
//------------------------------------------------
void CPrmStk::pushString(char const* src)
{
	assert(!hasFinalized());
	assert(getNextPrmType() == HSPVAR_FLAG_STR);
	p_->incCntArgs();

	char** const p = getPrmStk().allocValue<char*>();
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

	p_->incCntArgs();
	hpimod::ManagedPVal pval;
	hpimod::PVal_assign(pval.valuePtr(), pdat, vtype);
	getPrmStk().pushPVal({ pval.valuePtr(), 0 });
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

	p_->incCntArgs();
	getPrmStk().pushPVal({ pval, aptr });
	return;
}

//------------------------------------------------
// var, array, thismod
//------------------------------------------------
void CPrmStk::pushPVal(PVal* pval, APTR aptr)
{
	assert(!hasFinalized());
	assert(getNextPrmType() == PrmType::Var);

	p_->incCntArgs();
	getPrmStk().pushPVal({ pval, aptr });
	return;
}

void CPrmStk::pushPVal(PVal* pval)
{
	assert(!hasFinalized());
	assert(getNextPrmType() == PrmType::Array);

	p_->incCntArgs();
	getPrmStk().pushPVal({ pval, 0 });
	return;
}

void CPrmStk::pushThismod(PVal* pval, APTR aptr)
{
	assert(!hasFinalized());

	if ( getNextPrmType() != PrmType::Modvar ) puterror(HSPERR_ILLEGAL_FUNCTION);
	if ( pval->flag != HSPVAR_FLAG_STRUCT ) puterror(HSPERR_TYPE_MISMATCH);

	p_->incCntArgs();
	auto const fv = VtTraits::getValptr<vtStruct>(pval);
	getPrmStk().pushThismod(pval, aptr, FlexValue_getModuleTag(fv)->subid);
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

	p_->incCntArgs();
	auto const ptr = static_cast<unsigned short*>(getPrmStk().allocBlank(size));
	ptr[0] = priority;
	ptr[1] = MagicCodeNoBind;
	return;
}

unsigned short const* CPrmStk::peekArgNoBind(size_t idx) const
{
	assert(idx < cntArgs());
	auto const ptr = reinterpret_cast<unsigned short const*>(getArgPtrAt(idx));
	return (ptr[1] == MagicCodeNoBind ? ptr : nullptr);
}

//------------------------------------------------
// 値渡し引数の参照
//
// @ any は参照渡しでも値を取る。配列なら (0) を返す。
// @ 参照渡し引数は取り出さない。
//------------------------------------------------
PDAT const* CPrmStk::peekValArgAt(size_t idx, vartype_t& vtype) const
{
	int const prmtype = getPrmInfo().getPrmType(idx);
	if ( PrmType::isNativeVartype(prmtype) ) {
		auto const ptr = getArgPtrAt(idx);
		vtype = prmtype;
		return ( prmtype == HSPVAR_FLAG_STR )
			? VtTraits::asPDAT<vtStr>(*reinterpret_cast<char const* const*>(ptr))
			: reinterpret_cast<PDAT const*>(ptr);

	} else if ( PrmType::isExtendedVartype(prmtype) || prmtype == PrmType::Any || prmtype == PrmType::Var ) {
		auto& vardata = getPrmStk().peekPVal( getPrmInfo().getStackOffsetParam(idx) );
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
PVal const* CPrmStk::peekRefArgAt(size_t idx) const
{
	int const prmtype = getPrmInfo().getPrmType(idx);
	switch ( prmtype ) {
		case PrmType::Var:
		case PrmType::Array:
		case PrmType::Any:
		{
			auto& vardata = getPrmStk().peekPVal(getPrmInfo().getStackOffsetParam(idx));
			assert(vardata.aptr >= 0);
			vardata.pval->offset = vardata.aptr;
			return vardata.pval;
		}
		case PrmType::Modvar:
		{
			auto& thismod = getPrmStk().peekThismod(getPrmInfo().getStackOffsetParam(idx));
			assert(thismod.magic == MODVAR_MAGICCODE);
			thismod.pval->offset = thismod.aptr;
			return thismod.pval;
		}
		default: puterror(HSPERR_VARIABLE_REQUIRED);
	}
}

//------------------------------------------------
// その他の引数の参照
//------------------------------------------------
ManagedVarData const CPrmStk::peekAnyAt(size_t idx) const
{
	assert(idx < cntArgs());
	assert(getPrmInfo().getPrmType(idx) == PrmType::Any);
	return hpimod::ManagedVarData { getPrmStk().peekPVal(getPrmInfo().getStackOffsetParam(idx)) };
}

MPVarData const* CPrmStk::peekCaptureAt(size_t idx) const
{
	assert(hasFinalized());
	return &getPrmStk().peekValue<MPVarData>(getPrmInfo().getStackOffsetCapture(idx));
}
PVal const* CPrmStk::peekLocalAt(size_t idx) const
{
	assert(hasFinalized());
	return &getPrmStk().peekValue<PVal>(getPrmInfo().getStackOffsetLocal(idx));
}
vector_t const* CPrmStk::peekFlex() const
{
	return (getPrmInfo().isFlex() && hasFinalized())
		? &getPrmStk().peekValue<vector_t>(getPrmInfo().getStackOffsetFlex())
		: nullptr;
}

//------------------------------------------------
// スタックの参照
//------------------------------------------------
void const* CPrmStk::getOffsetPtr(size_t offset) const
{
	assert(offset <= getPrmStk().stackPos());
	return &reinterpret_cast<char const*>(getPrmStk().get())[offset];
}

void const* CPrmStk::getArgPtrAt(size_t idx) const
{
	assert(idx < cntArgs());
	return getOffsetPtr(getPrmInfo().getStackOffsetParam(idx));
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
	for ( size_t i = cntArgs(); i < getPrmInfo().cntPrms(); ++i ) {
		pushArgByDefault();
	}

	// captures (only allocating)
	for ( size_t i = 0; i < getPrmInfo().cntCaptures(); ++i ) {
		assert(getPrmStk().stackPos() == getPrmInfo().getStackOffsetCapture(i));
		getPrmStk().pushPVal({ nullptr, 0 });
	}

	// locals
	for ( size_t i = 0; i < getPrmInfo().cntLocals(); ++i ) {
		assert(getPrmStk().stackPos() == getPrmInfo().getStackOffsetLocal(i));
		PVal* const pval = getPrmStk().allocLocal();
		hpimod::PVal_init(pval, HSPVAR_FLAG_INT);
	}

	// flex
	if ( getPrmInfo().isFlex() ) {
		assert(getPrmStk().stackPos() == getPrmInfo().getStackOffsetFlex());
		vector_t* const vec = getPrmStk().allocValue<vector_t>();
		new(vec)vector_t {};
	}

	assert(getPrmStk().stackPos() == getPrmInfo().getStackSize());
	p_->finalized_ = true;
	return;
}

//------------------------------------------------
// 解体
//
// @ 実引数の取り出しの途中で死亡することもあるので注意したい。
//------------------------------------------------
void CPrmStk::free()
{
	// moved
	if ( !p_ ) return;

	void* const prmstk = getPrmStkPtr();
	assert(!!prmstk);

	// スタック上の管理されたオブジェクトを解放する
	for ( size_t i = 0; i < cntArgs(); ++i ) {
		int const prmtype = getPrmInfo().getPrmType(i);
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
		for ( size_t i = 0; i < getPrmInfo().cntCaptures(); ++i ) {
			ManagedPVal::ofValptr(peekCaptureAt(i)->pval).decRef();
		}
		for ( size_t i = 0; i < getPrmInfo().cntLocals(); ++i ) {
			PVal* const pval = peekLocalAt(i);
			PVal_free(pval);
		}
		if ( vector_t* const flex = peekFlex() ) {
			flex->decRef();
		}
	}

	hspfree(p_->getOwnerPtr());
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

//------------------------------------------------
// prmstk 上の値の push
//
// for CBound (todo: CBound との分離)
// src の idxSrc 番目の実引数を push する。
// それが nobind なら、対応する実引数を argsManeged から取り出して push する。
//------------------------------------------------
void CPrmStk::pushArgFromPrmStk(CPrmStk const& _src, size_t idxSrc, CBound* boundfunc, CPrmStk* argsMerged)
{
	// (todo: 各 peek 関数の、const へのポインタを返すバージョンを作る)
	CPrmStk& src = const_cast<CPrmStk&>(_src);

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

void CPrmStk::pushFinalsFrom(CPrmStk const& _src)
{
	CPrmStk& src = const_cast<CPrmStk&>(_src);

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
// 実引数列の merge
// 
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
	assert(getPrmInfo().cntCaptures() == captured->size());

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
