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
// top
//----------------------------------------------------------------------
module top;

`include "uvm_macros.svh"
  import uvm_pkg::*;
  import test_pkg::*;
  import svx::*;
  import svx_uvm_pkg::*;
  `include "svx_macros.svh"  

  //--------------------------------------------------------------------
  // populate
  //
  // Populate the command line option table with all possible
  // command line options.
  //--------------------------------------------------------------------
  function static void populate();

    cl_parse clp = new();
    
    cl#(uint32_t)::add_with_default("size", 4);
    cl#(int16_t)::add("offset");
    cl#(real)::add_with_default("freq", 2.875e9);
    cl#(bit)::add_with_default("x_mode", 0);
    cl#(bit)::add_with_default("z_mode", 0);
    cl#(uint32_t)::add_with_default("channels", 4);
    cl#(string)::add_with_default("name", "<none>");
    cl#(int32_t)::add_with_default("bias", 0);
    cl#(uint32_t)::add("base", "%8x");
    cl#(uint64_t)::add("data", "%16x");
    cl#(int64_t)::add("bignum");
    cl#(int8_t)::add("smallnum");
    cl#(string)::add("file");
    
    // parse the options.
    clp.parse();  
  endfunction

  initial begin
    populate();
    run_test();
  end

endmodule

