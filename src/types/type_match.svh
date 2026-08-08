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
// parameter is correct in a pasrameterized class.
//----------------------------------------------------------------------
class type_match #(type T1=int, type T2=int);

  static function bit is_match();
    return test_match();
  endfunction

  static function bit is_match_fail();
    if(!test_match())
      begin
	$display("*** Error: Types %s and %s do not match", 
		 $typename(T1), $typename(T2));
	$finish;
      end
    return 1;
  endfunction      

  local static function bit test_match();
    type_handle_base th1 = type_handle#(T1)::get_type();
    type_handle_base th2 = type_handle#(T2)::get_type();
    return (th1 == th2);
  endfunction
  
endclass
