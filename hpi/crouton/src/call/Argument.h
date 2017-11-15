// Argument for call

#ifndef IG_ARGUMENT_H
#define IG_ARGUMENT_H

#include "hsp3plugin_custom.h"

// nobind(N) に指定できる N の最大値
static int const NobindPriorityMax = std::numeric_limits<unsigned short>::max();

//------------------------------------------------
// my_code_getarg の返値
//
// type ArgData =
//	| ByVal * ((PDAT*) * vartype_t)
//	| ByRef * (PVal*)
//	| ByThismod * (PVal*)
//	| ByFlex * (vector_t)
//	| Default
//	| End
//	| NoBind * int
//------------------------------------------------
struct ArgData
{
	enum class Style : unsigned char {
		ByVal, ByRef, ByThismod, ByFlex,
		Default, End, NoBind,
	};
private:
	Style style_;
	union {
		struct { PDAT const* pdat_; hpimod::vartype_t vtype_; };
		MPVarData vardata_;
		int priority_;
	};
public:
	static ArgData byVal(PDAT const* pdat, hpimod::vartype_t vtype) { return ArgData(pdat, vtype); }
	static ArgData byRef(PVal* pval) { return ArgData(pval, pval->offset, Style::ByRef); }
	static ArgData byThismod(PVal* pval) { return ArgData(pval, pval->offset, Style::ByThismod); }
	//static ArgData byFlex(vector_t const& vec) { return ArgData(vec); }
	static ArgData noBind(int priority) { return ArgData(priority); }
	static ArgData const Default;
	static ArgData const End;

	Style getStyle() const { return style_; }
	PDAT const* getValptr() const{ assert(getStyle() == Style::ByVal); return pdat_; }
	hpimod::vartype_t getVartype() const { assert(getStyle() == Style::ByVal); return vtype_; }
	PVal* getPVal() const { assert(isByRefStyle()); return vardata_.pval; }
	APTR getAptr() const { assert(isByRefStyle()); return vardata_.aptr; }
	int getPriority() const { assert(style_ == Style::NoBind); return priority_; }

private:
	ArgData(Style style) : style_ { style }
	{ }
	ArgData(PVal* pval, APTR aptr, Style style) : style_ { style }, vardata_({ pval, aptr })
	{ assert(style == Style::ByRef || style == Style::ByThismod); }
	ArgData(PDAT const* pdat, hpimod::vartype_t vtype) : style_ { Style::ByVal }, pdat_ { pdat }, vtype_ { vtype }
	{ }
	//ArgData(vector_t const& vec) : style_ { Style::ByFlex }, pdat_ { VtTraits::asPDAT<vtVector>(&vec) }, vtype_ { g_vtVector }
	//{ }
	ArgData(int priority) : style_ { Style::NoBind }, priority_ { priority }
	{ }

public:
	bool isByRefStyle() const { return (style_ == Style::ByRef || style_ == Style::ByThismod); }
};

#endif
