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

//----------------------------------------------------------------------
// void_traits
//----------------------------------------------------------------------
class void_traits extends void_t;

  typedef void_t empty_t;
  localparam empty_t empty = null;

  static function bit equal(input void_t a, input void_t b);
    return 1; // void objects are always equivalent
  endfunction

  static function int32_t compare(input void_t a, input void_t b);
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

  static function int32_t compare(input object a, input object b);
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

  static function int32_t compare(input T a, input T b);
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

typedef  base_int_traits#(byte)              byte_traits;
typedef  base_int_traits#(byte unsigned)     byte_unsigned_traits;
typedef  base_int_traits#(shortint)          shortint_traits;
typedef  base_int_traits#(shortint unsigned) shortint_unsigned_traits;
typedef  base_int_traits#(int)               int_traits;
typedef  base_int_traits#(int unsigned)      int_unsigned_traits;
typedef  base_int_traits#(longint)           longint_traits;
typedef  base_int_traits#(longint unsigned)  longint_unsigned_traits;

typedef  base_int_traits#(int8_t)            int8_traits;
typedef  base_int_traits#(uint8_t)           uint8_traits;
typedef  base_int_traits#(int16_t)           int16_traits;
typedef  base_int_traits#(uint16_t)          uint16_traits;
typedef  base_int_traits#(int32_t)           int32_traits;
typedef  base_int_traits#(uint32_t)          uint32_traits;
typedef  base_int_traits#(int64_t)           int64_traits;
typedef  base_int_traits#(uint64_t)          uint64_traits;
typedef  base_int_traits#(int128_t)          int128_traits;
typedef  base_int_traits#(uint128_t)         uint128_traits;

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

  static function int32_t compare(real a, real b);
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
