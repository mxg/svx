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

  `include "svx_types.svh"

  `include "version/version.svh"
  `include "containers/containers.svh"
  `include "iterators/iterators.svh"
  `include "lexer/lexer.svh"
  `include "linked/linked.svh"
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
