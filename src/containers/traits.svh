//======================================================================
//
//               .oooooo..o oooooo     oooo ooooooo  ooooo     
//              d8P'    `Y8  `888.     .8'   `8888    d8'      
//              Y88bo.        `888.   .8'      Y888..8P        
//               `"Y8888o.     `888. .8'        `8888'         
//                   `"Y88b     `888.8'        .8PY888.        
//              oo     .d8P      `888'        d8'  `888b       
//              8""88888P'        `8'       o888o  o88888o
//
//                  SystemVerilog Extension Library
//
//
// Copyright 2016 NVIDIA Corporation
// Copyright 2026 Mark Glasser
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
// implied.  See the License for the specific language governing
// permissions and limitations under the License.
//======================================================================

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

// A macro to check type traits invariants
`define check_trait(t, trait, expect) begin                                \
                                        const bit x = t::trait;            \
                                        if(x != expect)                    \
                                          t::fail(`__LINE__, `__FILE__);   \
                                      end

//----------------------------------------------------------------------
// void_traits
//
// All traits classes should be derived from void_traits
//----------------------------------------------------------------------
class void_traits extends void_t;

  typedef void_t empty_t;
  localparam empty_t empty = null;

  localparam bit is_void	= true;
  localparam bit is_integral	= false;
  localparam bit is_signed	= false;
  localparam bit is_unsigned	= false;
  localparam bit is_two_state	= false;
  localparam bit is_four_state	= false;
  localparam bit is_real	= false;
  localparam bit is_arithmetic	= false;
  localparam bit is_string	= false;
  localparam bit is_scalar	= false;
  localparam bit is_class	= false;
  localparam bit is_array	= false;
  localparam bit is_struct	= false;
  localparam bit is_packed	= false;
  localparam bit is_union	= false;

  static function bit equal(input void_t a, input void_t b);
    return 1; // void objects are always equivalent
  endfunction

  static function int32_t compare(input void_t a, input void_t b);
    return int'(!equal(a,b));
  endfunction

  static function void sort(ref void_t vec[$]);
  endfunction

  // fail() is a utilitiy function that can be used to induce a
  // failure if a traits invariant is voilated.
  static function void fail(int line = 0, string file = "");
    if(file == "" && line == 0)
      $fatal(0, "Traits failure.");
    else
      $fatal(0, "Traits failure at %s:%0d", file, line);
  endfunction

endclass

//----------------------------------------------------------------------
// object_traits
//----------------------------------------------------------------------
class object_traits extends void_traits;

  typedef object empty_t;
  localparam empty_t empty = null;

  localparam bit is_void  = false;
  localparam bit is_class = true;

  static function bit equal(input object a, input object b);
    return (a.compare(b) == 0);
  endfunction

  static function int32_t compare(input object a, input object b);
    return a.compare(b);
  endfunction

  static function void sort(ref object vec[$]);
  endfunction

endclass

//----------------------------------------------------------------------
// class_traits
//----------------------------------------------------------------------
class class_traits#(type T=int) extends void_traits;

  typedef T empty_t;
  localparam empty_t empty = null;

  localparam bit is_void  = false;
  localparam bit is_class = true;
  
  static function bit equal(input T a, input T b);
    return (a == b);
  endfunction

  static function int32_t compare(input T a, input T b);
    return int'(!equal(a,b));
  endfunction

  static function void sort(ref T vec[$]);
  endfunction

endclass
  
//----------------------------------------------------------------------
// base_int_traits
//
// base class for all of the integral data types
//----------------------------------------------------------------------
class base_int_traits #(type T=int) extends void_traits;

  typedef T empty_t;
  localparam empty_t empty = T'(0);

  localparam bit is_void	= false;
  localparam bit is_integral	= true;
  localparam bit is_signed	= false;
  localparam bit is_unsigned	= false;
  localparam bit is_two_state	= true;
  localparam bit is_four_state	= false;
  localparam bit is_arithmetic	= true;
  localparam bit is_scalar	= true;
  
  static function bit equal(T a, T b);
    return (a == b);
  endfunction

  static function int32_t compare(T a, T b);
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

class base_unsigned_int_traits #(type T=int) extends base_int_traits#(T);

  localparam bit is_signed   = false;
  localparam bit is_unsigned = true;
  
endclass

class base_signed_int_traits #(type T=int) extends base_int_traits#(T);

  localparam bit is_signed = true;
  localparam bit is_unsigned = false;
  
endclass

typedef base_unsigned_int_traits#(bit)               bit_traits;

typedef base_unsigned_int_traits#(byte unsigned)     byte_unsigned_traits;
typedef base_unsigned_int_traits#(shortint unsigned) shortint_unsigned_traits;
typedef base_unsigned_int_traits#(int unsigned)      int_unsigned_traits;
typedef base_unsigned_int_traits#(longint unsigned)  longint_unsigned_traits;

typedef base_unsigned_int_traits#(uint8_t)           uint8_traits;
typedef base_unsigned_int_traits#(uint16_t)          uint16_traits;
typedef base_unsigned_int_traits#(uint32_t)          uint32_traits;
typedef base_unsigned_int_traits#(uint64_t)          uint64_traits;
typedef base_unsigned_int_traits#(uint128_t)         uint128_traits;

typedef base_signed_int_traits#(byte)                byte_traits;
typedef base_signed_int_traits#(shortint)            shortint_traits;
typedef base_signed_int_traits#(int)                 int_traits;
typedef base_signed_int_traits#(longint)             longint_traits;

typedef base_signed_int_traits#(int8_t)              int8_traits;
typedef base_signed_int_traits#(int16_t)             int16_traits;
typedef base_signed_int_traits#(int32_t)             int32_traits;
typedef base_signed_int_traits#(int64_t)             int64_traits;
typedef base_signed_int_traits#(int128_t)            int128_traits;

class base_four_state_traits #(type T=int) extends base_int_traits#(T);

  localparam bit is_two_state  = false;
  localparam bit is_four_state = true;

endclass

class integer_traits extends base_four_state_traits#(integer);

  localparam bit is_signed   = true;
  localparam bit is_unsigned = false;

endclass

// reg_traits, lkogic_traits, and timne_traits are all the same.

class reg_traits extends base_four_state_traits#(reg);

  localparam bit is_signed   = false;
  localparam bit is_unsigned = true;

endclass

typedef reg_traits logic_traits;
typedef reg_traits time_traits;

//----------------------------------------------------------------------
// bit_vector_traits
//----------------------------------------------------------------------
class bit_vector_traits #(uint32_t N=8)
  extends base_int_traits#(bit[N-1:0]);

  localparam bit is_void	= false;
  localparam bit is_integral	= true;
  localparam bit is_signed	= false;
  localparam bit is_unsigned	= false;
  localparam bit is_two_state	= false;
  localparam bit is_four_state	= false;
  localparam bit is_real	= false;
  localparam bit is_string	= false;
  localparam bit is_arithmetic	= true;
  localparam bit is_scalar	= false;
  localparam bit is_class	= false;
  localparam bit is_array	= true;
  localparam bit is_struct	= false;
  localparam bit is_packed	= false;
  localparam bit is_union	= false;
  
endclass

//----------------------------------------------------------------------
// real_base_traits
//----------------------------------------------------------------------
class real_base_traits #(type T=int) extends void_traits;

  typedef T empty_t;
  localparam empty_t empty = T'(0.0);
  localparam T epsilon = T'(1.0e-28);

  localparam bit is_void	= false;
  localparam bit is_integral	= false;
  localparam bit is_signed	= true;
  localparam bit is_unsigned	= false;
  localparam bit is_real	= true;
  localparam bit is_arithmetic	= true;
  localparam bit is_scalar	= true;

  static function bit equal(T a, T b);
    T diff = (a - b);
    return (diff >= -epsilon && diff <= epsilon);
  endfunction

  static function int32_t compare(T a, T b);
    if((a > b) && !equal(a, b))
      return 1;
    else
      if((a < b) && !equal(a, b))
        return -1;
      else
        return 0;
  endfunction

  static function void sort(ref T vec[$]);
    vec.sort with (item);
  endfunction

endclass

typedef real_base_traits#(real) real_traits;
//typedef real_base_traits#(shortreal) shortreal_traits;

//----------------------------------------------------------------------
// string_traits
//----------------------------------------------------------------------
class string_traits extends void_traits;

  typedef string empty_t;
  localparam empty_t empty = "";

  localparam bit is_void   = false;
  localparam bit is_string = true;
  localparam bit is_array  = true;

  static function bit equal(string a, string b);
    return (a == b);
  endfunction

  static function int32_t compare(string a, string b);
    if(a > b)
      return 1;
    else
      if(a < b)
        return -1;
      else
        return 0;
  endfunction

  static function void sort(ref string vec[$]);
    vec.sort with (item);
  endfunction

endclass

/* verilator lint_on UNUSEDPARAM */
