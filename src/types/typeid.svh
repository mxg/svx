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

/* verilator lint_off SIDEEFFECT */

//----------------------------------------------------------------------
// typeid
//
// Determine if a type parameter is the correct type
//----------------------------------------------------------------------
class typeid #(type T=int);

  static function bit is_int();
    return test_int();
  endfunction

  static function bit is_int_fail();
    if(!test_int())
      begin
	$display("*** Error: Type %s is not an integer type", $typename(T));
	$finish;
      end
    return 1;
  endfunction

  static function bit is_two_state();
    return test_two_state();
  endfunction

  static function bit is_two_state_fail();
    if(!test_two_state())
      begin
	$display("*** Error: Type %s is not an two-state type", $typename(T));
	$finish;
      end
    return 1;
  endfunction

  static function bit is_four_state();
    return test_four_state();
  endfunction

  static function bit is_four_state_fail();
    if(!test_four_state())
      begin
	$display("*** Error: Type %s is not an four-state type", $typename(T));
	$finish;
      end
    return 1;
  endfunction  

  static function bit is_string();
    return test_string();
  endfunction

  static function bit is_string_fail();
    if(!test_string())
      begin
	$display("*** Error: Type %s is not string type", $typename(T));
	$finish;
      end
    return 1;
  endfunction

  static function bit is_real();
    return test_real();
  endfunction

  static function bit is_real_fail();
    if(!test_real())
      begin
	$display("*** Error: Type %s is not real type", $typename(T));
	$finish;
      end
    return 1;
  endfunction  

  //--------------------------------------------------------------------
  // test_int
  //
  // is type T an integral type?
  //--------------------------------------------------------------------  
  local static function bit test_int();
  
    type_handle_base th = type_handle#(T)::get_type();

    case(th)
      type_handle#(int)::get_type()              : return 1;
      type_handle#(int unsigned)::get_type()     : return 1;
      type_handle#(longint)::get_type()          : return 1;
      type_handle#(longint unsigned)::get_type() : return 1;
      type_handle#(shortint)::get_type()         : return 1;
      type_handle#(shortint unsigned)::get_type(): return 1;
      type_handle#(byte)::get_type()          	 : return 1;
      type_handle#(byte unsigned)::get_type() 	 : return 1;
      type_handle#(logic)::get_type()            : return 1;
      type_handle#(reg)::get_type()              : return 1;
      type_handle#(integer)::get_type()          : return 1;
      type_handle#(time)::get_type()             : return 1;
      type_handle#(bit)::get_type()              : return 1;
      type_handle#(int8_t)::get_type()        	 : return 1;
      type_handle#(uint8_t)::get_type()       	 : return 1;
      type_handle#(int16_t)::get_type()       	 : return 1;
      type_handle#(uint16_t)::get_type()      	 : return 1;
      type_handle#(int32_t)::get_type()       	 : return 1;
      type_handle#(uint32_t)::get_type()      	 : return 1;
      type_handle#(int64_t)::get_type()       	 : return 1;
      type_handle#(uint64_t)::get_type()      	 : return 1;
      type_handle#(int128_t)::get_type()      	 : return 1;
      type_handle#(uint128_t)::get_type()     	 : return 1;
      default:
	return 0;
    endcase

  endfunction

  //--------------------------------------------------------------------
  // test_four_state
  //
  // is type T a four-state integral type?
  //--------------------------------------------------------------------  
  local static function bit test_four_state();
  
    type_handle_base th = type_handle#(T)::get_type();

    case(th)
      type_handle#(logic)::get_type()            : return 1;
      type_handle#(reg)::get_type()              : return 1;
      type_handle#(integer)::get_type()          : return 1;
      type_handle#(time)::get_type()             : return 1;
      default:
	return 0;
    endcase

  endfunction

  //--------------------------------------------------------------------
  // test_two_state
  //--------------------------------------------------------------------
  local static function bit test_two_state();
    return(test_int() && !test_four_state());
  endfunction
  
  //--------------------------------------------------------------------
  // test_real
  //--------------------------------------------------------------------  
  local static function bit test_real();
    type_handle_base th = type_handle#(T)::get_type();
    return (th == type_handle#(real)::get_type());
  endfunction

  //--------------------------------------------------------------------
  // test_string
  //--------------------------------------------------------------------  
  local static function bit test_string(bit fail=0);
    type_handle_base th = type_handle#(T)::get_type();
    return(th == type_handle#(string)::get_type());
  endfunction    

endclass
/* verilator lint_on SIDEEFFECT */
