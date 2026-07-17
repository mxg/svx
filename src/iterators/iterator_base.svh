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
// typed_iterator
//
// The base class for all iterators. It specifies the type of the
// objects in the container bound to the iterator.  It also contains
// the empty element.
//----------------------------------------------------------------------
interface class typed_iterator #(type T=int, type P=void_traits);

  /* verilator lint_off UNUSEDPARAM */
  localparam P::empty_t m_empty = P::empty;
  /* verilator lint_on UNUSEDPARAM */

  // Set the value of the item at the current index
  pure virtual function void set(T t);

  // Retrieve the iterm at the current index
  pure virtual function T get();

endclass

interface class bidir_iterator_base #(type T=int, type P=void_traits)
  extends bidir_intf
  implements typed_iterator#(T,P);

  pure virtual function void set(T t);
  pure virtual function T get();
  
endclass
  
