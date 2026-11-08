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
// Copyright 2024-2026 Mark Glasser
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
// transaction
//----------------------------------------------------------------------
class transaction extends uvm_sequence_item;

  typedef enum {NOP, READ, WRITE} op_t;

  rand op_t op;
  rand bit [31:0] addr;
  rand bit [31:0] data;

  constraint align { (addr & 'h3) == 0; };

  function string convert2string();
    string s;

    s = $sformatf(" %5s:", op.name());
    s = {s, $sformatf(" addr = %08x", addr)};
    s = {s, $sformatf(" data = %08x", data)};
    return s;
  endfunction

endclass
