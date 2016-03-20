//----------------------------------------------------------------------
// Data Type Traits
//
// These traits classes supply some constants and methods for use by the
// containers.  Each traits class provides an empty type and an empty
// object.  It also provides equal() and compare() methods.  Equal()
// returns a bit -- either the two values are equal or not.  Compare()
// potentially returns one of three values -- 0 if the two objects are
// equal, some value > 0 if a > b, or some value < 0 if a < b.  Some
// data types only can be compared for equality and not for > or <.  In
// those cases compare() must be implemented appropriately to return
// only 0 or a value > 0.
//
// This set of traits classes is not necessarily complete. This is just
// a set of traits for common data types. Users can provide additional
// traits classes for user-defined types.  Each new traits must include
// an empty type, an empty object, an equal() method, and a compare()
// method.
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// void_traits
//----------------------------------------------------------------------
class void_traits extends void_t;

  typedef void_t empty_t;
  const static empty_t empty = null;

  static function bit equal(input void_t a, input void_t b);
    return 1; // void objects are always equivalent
  endfunction

  static function int compare(input void_t a, input void_t b);
    return !equal(a,b);
  endfunction

  static function sort(ref void_t vec[$]);
  endfunction

endclass

//----------------------------------------------------------------------
// object_traits
//----------------------------------------------------------------------
class object_traits extends void_t;

  typedef object empty_t;
  const static empty_t empty = null;

  static function bit equal(input object a, input object b);
    return (a.compare(b) == 0);
  endfunction

  static function int compare(input object a, input object b);
    return a.compare(b);
  endfunction

  static function sort(ref object vec[$]);
  endfunction

endclass

//----------------------------------------------------------------------
// class_traits
//----------------------------------------------------------------------
class class_traits#(type T=int) extends void_t;

  typedef T empty_t;
  const static empty_t empty = null;

  static function bit equal(input T a, input T b);
    return (a == b);
  endfunction

  static function int compare(input T a, input T b);
    return !equal(a,b);
  endfunction

  static function sort(ref T vec[$]);
  endfunction

endclass
  
//----------------------------------------------------------------------
// base_int_traits
//----------------------------------------------------------------------
class base_int_traits #(type T=int) extends void_t;

  typedef T empty_t;
  const static empty_t empty = 0;

  static function bit equal(T a, T b);
    return (a == b);
  endfunction

  static function int compare(T a, T b);
    if(a > b)
      return 1;
    else
      if(a < b)
        return -1;
      else
        return 0;
  endfunction

  static function sort(ref T vec[$]);
    vec.sort();
  endfunction

endclass

//----------------------------------------------------------------------
// byte_traits
//----------------------------------------------------------------------
class byte_traits extends base_int_traits#(byte);
endclass

//----------------------------------------------------------------------
// byte_unsigned_traits
//----------------------------------------------------------------------
class byte_unsigned_traits extends base_int_traits#(byte unsigned);
endclass

//----------------------------------------------------------------------
// int_traits
//----------------------------------------------------------------------
class int_traits extends base_int_traits#(int);
endclass

//----------------------------------------------------------------------
// int_unsigned_traits
//----------------------------------------------------------------------
class int_unsigned_traits extends base_int_traits#(int unsigned);
endclass

//----------------------------------------------------------------------
// longint_traits
//----------------------------------------------------------------------
class longint_traits extends base_int_traits#(longint);
endclass

//----------------------------------------------------------------------
// longint_unsigned_traits
//----------------------------------------------------------------------
class longint_unsigned_traits extends base_int_traits#(longint unsigned);
endclass

//----------------------------------------------------------------------
// long_long_int_traits
//----------------------------------------------------------------------
class long_long_int_traits extends base_int_traits#(long_long_int_t);
endclass

//----------------------------------------------------------------------
// bit_vector_traits
//----------------------------------------------------------------------
class bit_vector_traits #(int unsigned N=8)
  extends base_int_traits#(bit[N-1:0]);
endclass

//----------------------------------------------------------------------
// real_traits
//----------------------------------------------------------------------
class real_traits extends void_t;

  typedef real empty_t;
  const static empty_t empty = 0.0;
  const static real epsilon = 1.0e-28;

  static function bit equal(real a, real b);
    real diff = (a - b);
    return (diff >= -epsilon && diff <= epsilon);
  endfunction

  static function int compare(real a, real b);
    if((a > b) && !equal(a, b))
      return 1;
    else
      if((a < b) && !equal(a, b))
        return -1;
      else
        return 0;
  endfunction

  static function sort(ref real vec[$]);
    vec.sort with (item);
  endfunction

endclass

//----------------------------------------------------------------------
// string_traits
//----------------------------------------------------------------------
class string_traits extends void_t;

  typedef string empty_t;
  const static empty_t empty = "";

  static function bit equal(string a, string b);
    return (a == b);
  endfunction

  static function int compare(string a, string b);
    return (!equal(a,b));
  endfunction

  static function sort(ref string vec[$]);
    vec.sort with (item);
  endfunction


endclass

