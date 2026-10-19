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
// cl_opt_instance
//
// Holds parsed information about a command line option
//----------------------------------------------------------------------
class cl_opt_instance;
  string name;
  string lexeme;
  token_t token;
  type_container_base value;

  function void print();
    if(value == null)
      $display("opt: %s = %s (%s)", name, lexeme, token.name());
    else
      $display("opt: %s = %s (%s)", name, value.val2str(), token.name());
  endfunction

endclass

//----------------------------------------------------------------------
// print_opt
//
// A function object for printing option instances
//----------------------------------------------------------------------
class print_opt extends fcn#(cl_opt_instance);
  function void f(cl_opt_instance opt);
    opt.print();
  endfunction
endclass

// A convenience typedef representing traits for cl_opt_instance.
typedef class_traits#(cl_opt_instance) cl_opt_inst_traits;

// A type representing a vector of cl_opt_instances.  The intermediate
// represention of the command line is a vector of command line
// descriptors.  The vector is used to generate internal configuration
// information.
typedef vector#(cl_opt_instance, cl_opt_inst_traits) opt_vector_t;
typedef list_iterator#(cl_opt_instance, cl_opt_inst_traits) opt_iterator_t;

//----------------------------------------------------------------------
// val_string
//----------------------------------------------------------------------
class val_string extends type_container#(string);
  // fmt is ignored for strings
  virtual function string val2str(string fmt="");
    return get();
  endfunction
endclass

//----------------------------------------------------------------------
// val_bit
//----------------------------------------------------------------------
class val_bit extends type_container#(bit);
  function new();
    set_default_fmt("%0b");
  endfunction
endclass

//----------------------------------------------------------------------
// val_int
//----------------------------------------------------------------------
class val_int#(type T=int) extends type_container#(T);
  function new();
    set_default_fmt("%0d");
  endfunction
endclass

typedef val_int#(int8_t)  val_int8;
typedef val_int#(int16_t) val_int16;
typedef val_int#(int32_t) val_int32;
typedef val_int#(int64_t) val_int64;

typedef val_int#(uint8_t)  val_uint8;
typedef val_int#(uint16_t) val_uint16;
typedef val_int#(uint32_t) val_uint32;
typedef val_int#(uint64_t) val_uint64;

//----------------------------------------------------------------------
// val_real
//----------------------------------------------------------------------
class val_real extends type_container#(real);
  function new();
    set_default_fmt("%g");
  endfunction
endclass
