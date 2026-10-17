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
  `include "svx_macros.svh"  

  import uvm_pkg::*;
  import svx::*;
  import svx_uvm_pkg::*;

  cl_parse clp;

  initial begin
    // populate possible command line options
    cl_mgr::add("abc", ARG_INT);
    cl_mgr::add("def", ARG_INT);
    cl_mgr::add("xyz", ARG_FLOAT);
    cl_mgr::add("fred", ARG_SWITCH);
    cl_mgr::add("ddd", ARG_INT);
    cl_mgr::add("str", ARG_STRING);
    cl_mgr::add("fritz", ARG_ID);

    // Just for hoots let's see what's in the option table.
    // cl_mgr::dump();
    
    clp = new();
    clp.parse();
  end

endmodule
