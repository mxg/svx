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
// type_match
//
// Do two types match?  This is useful for deetermining if a type
// parameter is correct in a parameterized class.
//----------------------------------------------------------------------
class type_match #(type T1=int, type T2=int);

  // Do the two types in the paramter list match?

  static function bit is_match(int line = 0, string file = "");
    if(!test_is_match())
      fail_match(line, file);
    return 1;
  endfunction

  static function bit test_is_match();
    type_handle_base th1 = type_handle#(T1)::get_type();
    type_handle_base th2 = type_handle#(T2)::get_type();
    return (th1 == th2);
  endfunction

  static function void fail_match(int line = 0, string file = "");
    if(file == "" && line == 0)
      $fatal(0, "Types %s and %s do not match",  $typename(T1), $typename(T2));
    else
      $fatal(0, "Types %s and %s do not match at %s:%0d",  $typename(T1), $typename(T2), file, line);
  endfunction

  // Is type T1 derived from type T2?

  static function bit is_derived_from(int line = 0, string file = "");
    if(!test_is_derived_from())
      fail_derived(line, file);
    return 1;
  endfunction

  static function bit test_is_derived_from();
    T1 derived;
    T2 base;
    int x;
    /* verilator lint_off CASTCONST */
    x = $cast(derived, base);
    /* verilator lint_on CASTCONST */
    return (x != 0);
  endfunction

  static function void fail_derived(int line = 0, string file = "");
    if(file == "" && line == 0)
      $fatal(0, "Type %s is not derived from type %s", $typename(T1), $typename(T2));
    else
      $fatal(0, "Type %s is not derived from type %s at %s:%0d",
	     $typename(T1), $typename(T2), file, line);
  endfunction  
  
endclass

//----------------------------------------------------------------------
// check_is_derived
//
// A convenience macro for determineing if two types match.
//----------------------------------------------------------------------

`define check_is_derived_from(t1, t2) const local bit x_``t1``_``t2``_derived = type_match#(t1,t2)::is_derived_from(`__LINE__, `__FILE__)
