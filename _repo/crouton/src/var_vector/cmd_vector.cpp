// vector - Command code

#include <functional>

#include "vt_vector.h"
#include "cmd_vector.h"
#include "sub_vector.h"

#include "mod_makepval.h"
#include "mod_argGetter.h"
#include "reffuncResult.h"
#include "mod_varutil.h"

using namespace hpimod;

static vector_t g_pResultVector { nullptr };

static void VectorContainerProcImpl(vector_t& self, int cmd);

//------------------------------------------------
// vector 型の値を返却する
// 
// @ そのまま返却するとスタックに乗る。
//------------------------------------------------
int SetReffuncResult( PDAT** ppResult, vector_t const& self )
{
	g_pResultVector = self;
	*ppResult = VtTraits::asPDAT<vtVector>(&g_pResultVector);
	return g_vtVector;
}

int SetReffuncResult( PDAT** ppResult, vector_t&& self )
{
	g_pResultVector = std::move(self);
	*ppResult = VtTraits::asPDAT<vtVector>(&g_pResultVector);
	return g_vtVector;
}

//------------------------------------------------
// vector 型の値を受け取る
//------------------------------------------------
vector_t code_get_vector()
{
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	if ( mpval->flag != g_vtVector ) puterror( HSPERR_TYPE_MISMATCH );
	return std::move(VtTraits::getMaster<vtVector>(mpval));
}

//------------------------------------------------
// vector の内部変数を受け取る
//------------------------------------------------
PVal* code_get_vectorInner()
{
	PVal* const pval = code_get_var();
	if ( pval->flag != g_vtVector ) puterror( HSPERR_TYPE_MISMATCH );

	PVal* const pvInner = getInnerPVal( pval );
	if ( !pvInner ) puterror( HSPERR_VARIABLE_REQUIRED );
	return pvInner;
}

//------------------------------------------------
// vector の範囲を取り出す
//------------------------------------------------
std::pair<size_t, size_t> code_get_vectorRange(vector_t const& self)
{
	bool const bNull = self.isNull();

	int const iBgn = code_getdi(0);
	int const iEnd = code_getdi((!bNull ? self->size() : 0));
	if ( (!bNull && !isValidRange(self, iBgn, iEnd))
		|| (bNull && (iBgn != 0 || iEnd != 0)) ) puterror(HSPERR_ILLEGAL_FUNCTION);
	return { iBgn, iEnd };
}

static size_t code_get_vectorIndex(vector_t const& self)
{
	int const idx = code_geti();
	if ( !(0 <= idx && static_cast<size_t>(idx) < self->size()) ) puterror(HSPERR_ILLEGAL_FUNCTION);
	return static_cast<size_t>(idx);
}

//#########################################################
//        命令
//#########################################################
//------------------------------------------------
// 破棄
//------------------------------------------------
void VectorDelete()
{
	PVal* const pval = code_get_var();
	if ( pval->flag != g_vtVector ) puterror(HSPERR_TYPE_MISMATCH);

	VtTraits::getMaster<vtVector>(pval).reset();
	return;
}

//------------------------------------------------
// リテラル式生成
//------------------------------------------------
int VectorMake(PDAT** ppResult)
{
	auto&& self = vector_t::make();

	for ( size_t i = 0; code_isNextArg(); ++i ) {
		int const chk = code_getprm();
		assert(chk != PARAM_END && chk != PARAM_ENDSPLIT);

		self->resize(i + 1);
		if ( chk != PARAM_DEFAULT ) {
			PVal* const pvInner = self->at(i).getVar();
			PVal_assign(pvInner, mpval->pt, mpval->flag);
		}
		// else: 初期値のまま
	}

	return SetReffuncResult(ppResult, std::move(self.beTmpObj()));
}

//------------------------------------------------
// スライス
//------------------------------------------------
int VectorSlice(PDAT** ppResult)
{
	auto&& self = code_get_vector();
	auto const&& range = code_get_vectorRange(self);

	auto&& result = vector_t::make();
	chainShallow(result, self, range);
	return SetReffuncResult(ppResult, std::move(result.beTmpObj()));
}

//------------------------------------------------
// スライス・アウト
//------------------------------------------------
int VectorSliceOut(PDAT** ppResult)
{
	auto&& self = code_get_vector();
	auto const&& range = code_get_vectorRange(self);

	size_t const len = self->size();
	size_t const lenRange = range.second - range.first;

	auto&& result = vector_t::make();
	if ( len > lenRange ) {
		result->reserve(len - lenRange);
		chainShallow(result, self, { 0, range.first });
		chainShallow(result, self, { range.second, len });
	}
	return SetReffuncResult(ppResult, std::move(result.beTmpObj()));
}

//------------------------------------------------
// 複製
//------------------------------------------------
int VectorDup(PDAT** ppResult)
{
	auto&& src = code_get_vector();
	auto&& range = code_get_vectorRange(src);

	// PVal の値を複製して vector をもう一つ作る
	auto&& self = vector_t::make();

	chainDeep(self, src, range);
	return SetReffuncResult(ppResult, std::move(self.beTmpObj()));
}

//------------------------------------------------
// vector の情報
//------------------------------------------------
int VectorIsNull(PDAT** ppResult)
{
	auto&& self = code_get_vector();
	return SetReffuncResult(ppResult, HspBool(!!self));
}

int VectorSize(PDAT** ppResult)
{
	auto&& self = code_get_vector();
	assert(!!self);

	return SetReffuncResult(ppResult, static_cast<int>(self->size()));
}

//------------------------------------------------
// 内部変数へのあれこれ
//------------------------------------------------
void VectorDimtype()
{
	PVal* const pvInner = code_get_vectorInner();
	code_dimtype(pvInner, code_get_vartype());
	return;
}

void VectorClone()
{
	PVal* const pvalSrc = code_get_vectorInner();
	PVal* const pvalDst = code_getpval();

	PVal_cloneVar( pvalDst, pvalSrc );
	return;
}

int VectorVarinfo(PDAT** ppResult)
{
	PVal* const pvInner = code_get_vectorInner();
	return SetReffuncResult(ppResult, code_varinfo(pvInner));
}

//------------------------------------------------
// vector 返却関数
//------------------------------------------------
static int const VectorResultExprMagicNumber = 0x31EC100A;

int VectorResult(PDAT** ppResult)
{
	g_pResultVector = code_get_vector();

	return SetReffuncResult(ppResult, VectorResultExprMagicNumber);
}

int VectorExpr(PDAT** ppResult)
{
	// ここで VectorResult() が実行されるはず
	if ( code_geti() != VectorResultExprMagicNumber ) puterror(HSPERR_ILLEGAL_FUNCTION);

	return (g_pResultVector.isTmpObj()
		? SetReffuncResult(ppResult, std::move(g_pResultVector))
		: SetReffuncResult(ppResult, g_pResultVector));
}

//------------------------------------------------
// 文字列結合(Join)
//------------------------------------------------
int VectorJoin(PDAT** ppResult)
{
	auto&& self = code_get_vector();

	// todo: use sdt::string?

	char const* const _splitter = code_getds(", ");
	char splitter[0x80];
	strcpy_s(splitter, _splitter);
	size_t const lenSplitter = std::strlen(splitter);

	char const* const _leftBracket = code_getds("");
	char leftBracket[0x10];
	strcpy_s(leftBracket, _leftBracket);
	size_t const lenLeftBracket = std::strlen(leftBracket);

	char const* const _rightBracket = code_getds("");
	char rightBracket[0x10];
	strcpy_s(rightBracket, _rightBracket);
	size_t const lenRightBracket = std::strlen(rightBracket);

	// 文字列化処理
	std::function<void(vector_t&, char*, int, size_t&)> impl
		= [&](vector_t const& self, char* buf, int bufsize, size_t& idx)
	{
		strcpy_s(&buf[idx], bufsize - idx, leftBracket); idx += lenLeftBracket;

		// foreach
		for ( size_t i = 0; i < self->size(); ++i ) {
			if ( i != 0 ) {
				// 区切り文字
				strcpy_s(&buf[idx], bufsize - idx, splitter); idx += lenSplitter;
			}

			PVal* const pvdat = self->at(i).getVar();

			if ( pvdat->flag == g_vtVector ) {
				impl(VtTraits::getMaster<vtVector>(pvdat), buf, bufsize, idx);

			} else {
				// 文字列化して連結
				char const* const pStr = (char const*)Valptr_cnvTo(PVal_getptr(pvdat), pvdat->flag, HSPVAR_FLAG_STR);
				size_t const lenStr = std::strlen(pStr);
				strcpy_s(&buf[idx], bufsize - idx, pStr); idx += lenStr;
			}
		}

		strcpy_s(&buf[idx], bufsize - idx, rightBracket); idx += lenRightBracket;
	};

	auto const lambda = [&self, &impl](char* buf, int bufsize) {
		size_t idx = 0;				// 結合後の文字列の長さ
		impl(self, buf, bufsize, idx);
		buf[idx++] = '\0';
	};

	return SetReffuncResultString(ppResult, lambda);
}

//------------------------------------------------
// 添字関数
//------------------------------------------------
int VectorAt(PDAT** ppResult)
{
	auto&& self = code_get_vector();

	int vtype;
	if ( PDAT* const pResult = Vector_indexRhs(self, &vtype) ) {
		*ppResult = pResult;
		return vtype;
	} else {
		return SetReffuncResult(ppResult, self);
	}
}

//#########################################################
//        コンテナ操作
//#########################################################
//------------------------------------------------
// 連結
//------------------------------------------------
void VectorChain(bool bClear)
{
	auto&& dst = code_get_vector();
	auto&& src = code_get_vector();

	if ( bClear ) dst->clear();

	auto const&& range = code_get_vectorRange(src);
	chainDeep(dst, src, range);
	return;
}

//------------------------------------------------
// コンテナ操作処理テンプレート
//------------------------------------------------
// 難しい

//------------------------------------------------
// 要素順序
//------------------------------------------------
void VectorContainerProc(int cmd)
{
	PVal* const pval = code_get_var();
	if ( pval->flag != g_vtVector ) puterror( HSPERR_TYPE_MISMATCH );

	auto& self = VtTraits::getMaster<vtVector>(pval);
	if ( !self ) puterror(HSPERR_ILLEGAL_FUNCTION);

	VectorContainerProcImpl(self, cmd);
	return;
}

int VectorContainerProcFunc(PDAT** ppResult, int cmd)
{
	auto&& src = code_get_vector();
	if ( !src ) puterror(HSPERR_ILLEGAL_FUNCTION);

	// 全区間スライス
	auto&& result = vector_t::make();
	{
		chainShallow(result, src, { 0, src->size() });
		VectorContainerProcImpl(result, cmd);
	}
	return SetReffuncResult(ppResult, std::move(result.beTmpObj()));
}

static void VectorContainerProcImpl(vector_t& self, int cmd)
{
	switch ( cmd ) {
		case VectorCmdId::Insert:
		{
			// 区間
			// iEnd の側は現在の size を無視できる。
			size_t const iBgn = code_get_vectorIndex(self);
			int const iEnd = code_geti();
			if ( iEnd <= static_cast<int>(iBgn) ) puterror(HSPERR_ILLEGAL_FUNCTION);

			size_t const cntRange = iEnd - iBgn;

			// 初期値リスト
			vector_t ins {}; ins->reserve(cntRange);
			for ( size_t i = 0; i < cntRange; ++i ) {
				int const chk = code_getprm();
				ins->push_back((chk <= PARAM_END)
					? ManagedVarData {}
					: ManagedVarData { mpval->pt, static_cast<vartype_t>(mpval->flag) }
				);
			}

			self->insert(self->begin() + iBgn, ins->begin(), ins->end());
			break;
		}
		case VectorCmdId::Remove:
		{
			auto&& range = code_get_vectorRange(self);
			self->erase(self->begin() + range.first, self->begin() + range.second);
			break;
		}
		case VectorCmdId::InsertOne:
		case VectorCmdId::PushFront:
		case VectorCmdId::PushBack:
		case VectorCmdId::RemoveOne:
		case VectorCmdId::PopFront:
		case VectorCmdId::PopBack:
		{
			// 添字
			int idx;
			switch ( cmd ) {
				case VectorCmdId::InsertOne:
				{
					idx = code_geti();

					// idx == end まで許される
					if ( !(0 <= idx && static_cast<size_t>(idx) <= self->size()) ) {
						puterror(HSPERR_ILLEGAL_FUNCTION);
					}
					break;
				}
				case VectorCmdId::RemoveOne: idx = code_get_vectorIndex(self); break;
				case VectorCmdId::PushFront: //
				case VectorCmdId::PopFront:  idx = 0; break;
				case VectorCmdId::PushBack:  idx = self->size(); break;
				case VectorCmdId::PopBack:   idx = self->size() - 1; break;
				default: assert(false);
			}

			switch ( cmd ) {
				case VectorCmdId::InsertOne:
				case VectorCmdId::PushFront:
				case VectorCmdId::PushBack:
				{
					// 初期値
					int const chk = code_getprm();
					auto vardata = (chk <= PARAM_END
						? ManagedVarData {}
						: ManagedVarData { mpval->pt, static_cast<vartype_t>(mpval->flag) }
					);

					self->insert(self->begin() + idx, std::move(vardata));
					break;
				}
				case VectorCmdId::RemoveOne:
				case VectorCmdId::PopFront:
				case VectorCmdId::PopBack:
					self->erase(self->begin() + idx);
					break;

				default: assert(false);
			}
			break;
		}
		case VectorCmdId::Replace:
		{
			auto&& range = code_get_vectorRange(self);
			auto&& src = code_get_vector();

			size_t const cntRange = range.second - range.first;
			auto&& result = vector_t::make();
			result->reserve(self->size() - cntRange + src->size());

			chainShallow(result, self, { 0, range.first });
			chainShallow(result, src, { 0, src->size() });
			chainShallow(result, self, { range.second, self->size() });

			self = std::move(result);
			break;
		}
		case VectorCmdId::Swap:
		{
			size_t const idx1 = code_get_vectorIndex(self);
			size_t const idx2 = code_get_vectorIndex(self);

			std::iter_swap(self->begin() + idx1, self->begin() + idx2);
			break;
		}
		case VectorCmdId::Rotate:
		{
			int const step = code_getdi(1);

			size_t const size = self->size();
			if ( size > 1 ) {
				// regularize step (use positive-minimum modulo)
				size_t const stepReg
					//= step % size
					= ((step % size) + size) % size;

				std::rotate(self->begin() , self->begin() + stepReg, self->end());
			}
			break;
		}
		case VectorCmdId::Reverse:
		{
			auto&& range = code_get_vectorRange(self);
			std::reverse(self->begin() + range.first, self->begin() + range.second);
			break;
		}
		case VectorCmdId::Relocate:
		{
			size_t const idxDst = code_get_vectorIndex(self);
			size_t const idxSrc = code_get_vectorIndex(self);
			if ( idxSrc != idxDst ) {
				auto srcElem = self->at(idxSrc);

				auto&& bak = vector_t::make();
				if ( idxSrc < idxDst ) {
					chainShallow(bak, self, { idxSrc + 1, idxDst + 1 });
					std::move(
						bak->begin(),
						bak->end(),
						self->begin() + idxSrc
					);
				} else {
					chainShallow(bak, self, { idxDst, idxSrc });
					std::move(
						bak->begin(),
						bak->end(),
						self->begin() + idxDst + 1
					);
				}
				self->at(idxDst) = std::move(srcElem);
			}
			break;
		}
		default: assert(false);
	}
	return;
}

//#########################################################
//        関数
//#########################################################
//------------------------------------------------
// 内部変数の情報を得る
//------------------------------------------------


//------------------------------------------------
// 終了時
//------------------------------------------------
void VectorCmdTerminate()
{
	g_pResultVector.nullify();
	return;
}
