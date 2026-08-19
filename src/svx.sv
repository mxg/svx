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
//
//    S y s t e m V e r i l o g   E x t e n s i o n   L i b r a r y
//
//----------------------------------------------------------------------

`include "svx_macros.svh"

//----------------------------------------------------------------------
// ctypes
//----------------------------------------------------------------------
`include "lexer/ctypes.svh"

//----------------------------------------------------------------------
// svx package
//----------------------------------------------------------------------
package svx;

  `include "types/types.svh"
  `include "version/version.svh"
  `include "containers/containers.svh"
  `include "iterators/iterators.svh"
  `include "algorithms/algorithms.svh"
  `include "lexer/lexer.svh"
  `include "linked/linked.svh"
  `include "convenience_typedefs.svh"
  `include "behaviors/behaviors.svh"


endpackage


//----------------------------------------------------------------------
// svx_anchor
//
// A top-level module we can use to anchor things that need to be in a
// module.
//----------------------------------------------------------------------
module svx_anchor;
  
  import svx::*;
  
  initial begin
    void'(ver::print_banner());
  end

endmodule
