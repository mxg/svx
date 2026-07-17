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

/* verilator lint_off UNUSEDPARAM */

//----------------------------------------------------------------------
// void_traits
//----------------------------------------------------------------------
class void_traits extends void_t;

  typedef void_t empty_t;
  localparam empty_t empty = null;

  static function bit equal(input void_t a, input void_t b);
    return 1; // void objects are always equivalent
  endfunction

  static function int compare(input void_t a, input void_t b);
    return int'(!equal(a,b));
  endfunction

  static function void sort(ref void_t vec[$]);
  endfunction

endclass

//----------------------------------------------------------------------
// object_traits
//----------------------------------------------------------------------
class object_traits extends void_t;

  typedef object empty_t;
  localparam empty_t empty = null;

  static function bit equal(input object a, input object b);
    return (a.compare(b) == 0);
  endfunction

  static function int compare(input object a, input object b);
    return a.compare(b);
  endfunction

  static function void sort(ref object vec[$]);
  endfunction

endclass

//----------------------------------------------------------------------
// class_traits
//----------------------------------------------------------------------
class class_traits#(type T=int) extends void_t;

  typedef T empty_t;
  localparam empty_t empty = null;

  static function bit equal(input T a, input T b);
    return (a == b);
  endfunction

  static function int compare(input T a, input T b);
    return int'(!equal(a,b));
  endfunction

  static function void sort(ref T vec[$]);
  endfunction

endclass
  
//----------------------------------------------------------------------
// base_int_traits
//----------------------------------------------------------------------
class base_int_traits #(type T=int) extends void_t;

  typedef T empty_t;
  localparam empty_t empty = 0;

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

  static function void sort(ref T vec[$]);
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
// int8_traits
//----------------------------------------------------------------------
class int8_traits extends base_int_traits#(int8_t);
  typedef int8_t empty_t;
  localparam empty_t empty = 0;

  static function bit equal(int8_t a, int8_t b);
    return (a == b);
  endfunction

  static function int compare(int8_t a, int8_t b);
    if(a > b)
      return 1;
    else
      if(a < b)
        return -1;
      else
        return 0;
  endfunction

  static function void sort(ref int8_t vec[$]);
    vec.sort();
  endfunction
endclass

//----------------------------------------------------------------------
// uint8_traits
//----------------------------------------------------------------------
class uint8_traits;
  typedef uint8_t empty_t;
  localparam empty_t empty = 0;

  static function bit equal(uint8_t a, uint8_t b);
    return (a == b);
  endfunction

  static function int compare(uint8_t a, uint8_t b);
    if(a > b)
      return 1;
    else
      if(a < b)
        return -1;
      else
        return 0;
  endfunction

  static function void sort(ref uint8_t vec[$]);
    vec.sort();
  endfunction
endclass

//----------------------------------------------------------------------
// int16_traits
//----------------------------------------------------------------------
class int16_traits extends base_int_traits#(int16_t);
  typedef int16_t empty_t;
  localparam empty_t empty = 0;

  static function bit equal(int16_t a, int16_t b);
    return (a == b);
  endfunction

  static function int compare(int16_t a, int16_t b);
    if(a > b)
      return 1;
    else
      if(a < b)
        return -1;
      else
        return 0;
  endfunction

  static function void sort(ref int16_t vec[$]);
    vec.sort();
  endfunction
endclass

//----------------------------------------------------------------------
// uint16_traits
//----------------------------------------------------------------------
class uint16_traits;
  typedef uint16_t empty_t;
  localparam empty_t empty = 0;

  static function bit equal(uint16_t a, uint16_t b);
    return (a == b);
  endfunction

  static function int compare(uint16_t a, uint16_t b);
    if(a > b)
      return 1;
    else
      if(a < b)
        return -1;
      else
        return 0;
  endfunction

  static function void sort(ref uint16_t vec[$]);
    vec.sort();
  endfunction
endclass

//----------------------------------------------------------------------
// int32_traits
//----------------------------------------------------------------------
class int32_traits extends base_int_traits#(int32_t);
  typedef int32_t empty_t;
  localparam empty_t empty = 0;

  static function bit equal(int32_t a, int32_t b);
    return (a == b);
  endfunction

  static function int compare(int32_t a, int32_t b);
    if(a > b)
      return 1;
    else
      if(a < b)
        return -1;
      else
        return 0;
  endfunction

  static function void sort(ref int32_t vec[$]);
    vec.sort();
  endfunction
endclass

//----------------------------------------------------------------------
// uint32_traits
//----------------------------------------------------------------------
class uint32_traits;
  typedef uint32_t empty_t;
  localparam empty_t empty = 0;

  static function bit equal(uint32_t a, uint32_t b);
    return (a == b);
  endfunction

  static function int compare(uint32_t a, uint32_t b);
    if(a > b)
      return 1;
    else
      if(a < b)
        return -1;
      else
        return 0;
  endfunction

  static function void sort(ref uint32_t vec[$]);
    vec.sort();
  endfunction
endclass

//----------------------------------------------------------------------
// int64_traits
//----------------------------------------------------------------------
class int64_traits extends base_int_traits#(int64_t);
endclass

//----------------------------------------------------------------------
// uint64_t_traits
//----------------------------------------------------------------------
class uint64_traits extends base_int_traits#(uint64_t);
  typedef uint64_t empty_t;
  localparam empty_t empty = 0;

  static function bit equal(uint64_t a, uint64_t b);
    return (a == b);
  endfunction

  static function int compare(uint64_t a, uint64_t b);
    if(a > b)
      return 1;
    else
      if(a < b)
        return -1;
      else
        return 0;
  endfunction

  static function void sort(ref uint64_t vec[$]);
    vec.sort();
  endfunction
endclass

//----------------------------------------------------------------------
// uint128_traits
//----------------------------------------------------------------------
class uint128_traits extends base_int_traits#(uint128_t);
endclass


//----------------------------------------------------------------------
// int128_traits
//----------------------------------------------------------------------
class int128_traits extends base_int_traits#(int128_t);
endclass

//----------------------------------------------------------------------
// bit_vector_traits
//----------------------------------------------------------------------
class bit_vector_traits #(uint32_t N=8)
  extends base_int_traits#(bit[N-1:0]);
endclass

//----------------------------------------------------------------------
// real_traits
//----------------------------------------------------------------------
class real_traits extends void_t;

  typedef real empty_t;
  localparam empty_t empty = 0.0;
  localparam real epsilon = 1.0e-28;

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

  static function void sort(ref real vec[$]);
    vec.sort with (item);
  endfunction

endclass

//----------------------------------------------------------------------
// string_traits
//----------------------------------------------------------------------
class string_traits extends void_t;

  typedef string empty_t;
  localparam empty_t empty = "";

  static function bit equal(string a, string b);
    return (a == b);
  endfunction

  static function int compare(string a, string b);
    return int'(!equal(a,b));
  endfunction

  static function void sort(ref string vec[$]);
    vec.sort with (item);
  endfunction


endclass

/* verilator lint_on UNUSEDPARAM */
