#ifndef IG_STRUCT_COMPLEX_H
#define IG_STRUCT_COMPLEX_H

#include <math.h>

template<class T>
struct basic_complex
{
public:
	T re;
	T im;
	
private:
	typedef T elem_t;
	typedef basic_complex<T> this_t, self_t;
	
public:
	basic_complex( T x = 0, T y = 0 )
		: re( x )
		, im( y )
	{ }
	basic_complex( const this_t& rhs )
		: re( rhs.re )
		, im( rhs.im )
	{ }
	
public:
	T getRe() const { return re; }
	T getIm() const { return im; }
	double getArg() const { return atan2( static_cast<double>(im), re ); }
	double getAbs() const { return sqrt( static_cast<double>(re * re + im * im) ); }
	
	bool isNull  () const { return re == 0 && im == 0; }
	bool isReal  () const { return im == 0; }
	bool isPureIm() const { return re == 0 && im != 0; }
	
	bool isConjugate( const this_t& rhs ) const { return re == rhs.re && im == -rhs.im; }
	
	this_t& operator  = ( const this_t& rhs ) { re  = rhs.re; im  = rhs.im; return *this; }
	this_t& operator += ( const this_t& rhs ) { re += rhs.re; im += rhs.im; return *this; }
	this_t& operator -= ( const this_t& rhs ) { re -= rhs.re; im -= rhs.im; return *this; }
	this_t& operator *= ( const this_t& rhs )
	{
		T re_ = (re * rhs.re) - (im * rhs.im);
		T im_ = (re * rhs.im) + (im * rhs.re);
		re = re_;
		im = im_;
		return *this;
	}
	this_t& operator /= ( const this_t& rhs )
	{
		T denominator = (rhs.re * rhs.re + rhs.im * rhs.im);
		T re_ = ((re * rhs.re) + (im * rhs.im)) / denominator;
		T im_ = ((im * rhs.re) - (re * rhs.im)) / denominator;
		re = re_;
		im = im_;
		return *this;
	}
	this_t& operator %= ( const this_t& rhs )
	{
		this_t q = (dup() / rhs);
		re -= ( (rhs.re * q.re) - (rhs.im * q.im) );
		im -= ( (rhs.re * q.im) + (rhs.im * q.re) );
		return *this;
	}
	
	this_t& opPlusI () { return *this; }
	this_t& opMinusI()
	{
		re *= -1;
		im *= -1;
		return *this;
	}
	this_t& opInvI()
	{
		im *= -1;
		return *this;
	}
	
	this_t operator + ( const this_t& rhs ) const { return dup() += rhs; }
	this_t operator - ( const this_t& rhs ) const { return dup() -= rhs; }
	this_t operator * ( const this_t& rhs ) const { return dup() *= rhs; }
	this_t operator / ( const this_t& rhs ) const { return dup() /= rhs; }
	this_t operator % ( const this_t& rhs ) const { return dup() %= rhs; }
	this_t operator + () const { return dup().opPlusI();  }
	this_t operator - () const { return dup().opMinusI(); }
	this_t operator ~ () const { return dup().opInvI();   }
	
	bool operator ! () const { return isNull(); }
	int         opCmp( const this_t& rhs ) const { return ( (re == rhs.re && im == rhs.im) ? 0 : -1 ); }
	bool operator == ( const this_t& rhs ) const { return !opCmp( rhs ); }
	bool operator != ( const this_t& rhs ) const { return  opCmp( rhs ) ? true : false; }
	
public:
	this_t dup() const { return *this; }
};

//------------------------------------------------
// 構築 (極座標形式)
//------------------------------------------------
template<class T>
inline basic_complex<T> basic_complex_polar( double r, double arg )
{
	return basic_complex<T>( r * cos(arg), r * sin(arg) );
}

#endif
