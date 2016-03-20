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

// Include the various macros from the SVX library and bring in the SVX
// library package. The example code depends on the SVX library so we
// have to do this first before the example code.
`include "svx_macros.svh"
import svx::*;

// include our example code
`include "list_example.svh"
`include "map_example.svh"


//----------------------------------------------------------------------
// use_model_examplse
//
// You can run all the examples or comment out the ones that are not of
// interest.
//----------------------------------------------------------------------
class use_model_examples;

  list_example list_ex;
  map_example map_ex;

  function void run();
    
    list_ex = new();
    list_ex.run();

    map_ex = new();
    map_ex.run();
  endfunction
    
endclass

//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

  use_model_examples ex;

  initial begin
    ex = new();
    ex.run();
  end

endmodule
