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
// Sample Address Map
//----------------------------------------------------------------------
/* verilator lint_off IMPORTSTAR */
import svx::*;
`include "svx_macros.svh"

import mem_map::*;
/* verilator lint_on IMPORTSTAR */

`define ASIZE 32

typedef mem_space#(`ASIZE) space_t;

//----------------------------------------------------------------------
// erroneous
//----------------------------------------------------------------------
class erroneous extends mem_field #(`ASIZE);

  function new(string name, space_t parent, space_t::addr_t _offset, space_t::mem_size_t _size);
    super.new(name, parent, _offset, _size);
  endfunction

endclass

//----------------------------------------------------------------------
// start_stop
//----------------------------------------------------------------------
class start_stop extends mem_field #(`ASIZE);

  erroneous e;

  function new(string name, space_t parent, space_t::addr_t _offset, space_t::mem_size_t _size);
    super.new(name, parent, _offset, _size);

//    e = new("erroneous", this, 12, 100);
  endfunction
  
endclass

//----------------------------------------------------------------------
// status
//----------------------------------------------------------------------
class status extends mem_field #(`ASIZE);

  function new(string name, space_t parent, space_t::addr_t _offset, space_t::mem_size_t _size);
    super.new(name, parent, _offset, _size);
  endfunction

endclass

//----------------------------------------------------------------------
// csr
//----------------------------------------------------------------------
class csr extends mem_register #(`ASIZE);

  start_stop s;
  status t;

  function new(string name, space_t parent, space_t::addr_t _offset, space_t::mem_size_t _size);
    super.new(name, parent, _offset, _size);

    s = new("start_stop", this, 0, 4);
    t = new("status", this, 4, 4);
    
  endfunction

endclass

//----------------------------------------------------------------------
// timer
//----------------------------------------------------------------------
class timer extends mem_region #(`ASIZE);

  csr c;

  function new(string name, space_t parent, space_t::addr_t _offset, space_t::mem_size_t _size);
    super.new(name, parent, _offset, _size);

    c = new("csr", this, 8, 1);
    add_register("seconds", space_t::addr_t'(0), space_t::mem_size_t'(4));
    add_register("milliseconds", space_t::addr_t'(4), space_t::mem_size_t'(4));
  endfunction

endclass

//----------------------------------------------------------------------
// uart
//----------------------------------------------------------------------
class uart extends mem_region #(`ASIZE);

  function new(string name, space_t parent, space_t::addr_t _offset, space_t::mem_size_t _size);
    super.new(name, parent, _offset, _size);

    add_register("read_buf", space_t::addr_t'(0), space_t::mem_size_t'(1));
    add_register("write_buf", space_t::addr_t'(1), space_t::mem_size_t'(1));
    add_register("ctrl", space_t::addr_t'(2), space_t::mem_size_t'(1));
  endfunction

endclass

//----------------------------------------------------------------------
// io_bus
//----------------------------------------------------------------------
class io_bus extends mem_region #(`ASIZE);

  uart u;

  function new(string name, space_t parent, space_t::addr_t _offset, space_t::mem_size_t _size);
    super.new(name, parent, _offset, _size);

    u = new("uart1", this, space_t::addr_t'('h00), space_t::mem_size_t'(8));
    u = new("uart2", this, space_t::addr_t'('h08), space_t::mem_size_t'(8));

  endfunction
  
endclass

//----------------------------------------------------------------------
// sys_bus
//
//----------------------------------------------------------------------
class sys_bus extends mem_view #(`ASIZE);

  timer t;
  mem_memory#(`ASIZE) m;

  function new(string name, space_t parent, space_t::addr_t _offset, space_t::mem_size_t _size);
    super.new(name, parent, _offset, _size);

    t = new("timer", this, space_t::addr_t'(0), space_t::mem_size_t'(8));
    m = new("mem1", this, space_t::addr_t'('h0080), space_t::mem_size_t'('h400));
    m = new("mem2", this, space_t::addr_t'('h00c0), space_t::mem_size_t'('h400));

  endfunction
  
endclass

//----------------------------------------------------------------------
// An alternate view of the system bus
//
// This does not add any memory or register elements.  It provides a
// different way of accessing them
//----------------------------------------------------------------------
class sys_bus_2 extends mem_view #(`ASIZE);

  mem_memory#(`ASIZE) m;

  function new(string name, space_t parent, space_t::addr_t _offset,
    space_t::mem_size_t _size); super.new(name, parent, _offset, _size);

      m = new("mem", this, space_t::addr_t'('h0000), space_t::mem_size_t'('h100));
  endfunction

endclass

//----------------------------------------------------------------------
// system
//
// Top-level of the memory/register space
//----------------------------------------------------------------------
class system extends mem_region #(`ASIZE);

  io_bus io;
  sys_bus s;
  sys_bus_2 s2;

  function new(string name, space_t parent, space_t::addr_t _offset, space_t::mem_size_t _size);
    super.new(name, parent, _offset, _size);

    io = new("io_bus", this, space_t::addr_t'('hff00), space_t::mem_size_t'('h100));
    // Note that s and s2 occupy the same memory space.  Each
    // represents a different view of the same set of memories and
    // registers.
    s =  new("sys_bus", this, space_t::addr_t'('h0000), space_t::mem_size_t'('h100));
    s2 = new("sys_bus_2", this, space_t::addr_t'('h0000), space_t::mem_size_t'('h100));

  endfunction

endclass

//----------------------------------------------------------------------
// test
//----------------------------------------------------------------------
class test;

  system sys;

  function new();
    sys = new("system", null, 0, 'h10000);
    if(sys.calculate_and_check())
      $display("*** error: memory space %s has errors within its hierarchy", sys.get_full_name());
  endfunction

  function void dump();
    sys.dump();
  endfunction
  
  function void lookup_paths();
    tree t;
    string path;
    string paths[$] = {"io_bus", "io_bus.uart1.ctrl", "sys_bus.mem1"};

    $display("\n--- lookup paths ---");

    foreach (paths[i]) begin
      path = paths[i];
      $display("\nlooking up %s", path);
      t = sys.find(path);
      if(t == null)
	$display("%s not found", path);
      else
	$display("path found: %s", path);
    end

  endfunction

  function void lookup_addrs();
    space_t::addr_t addrs[$] = {'h00000000, 'h8, 'hf0, 'hff00, 'hff01, 'hff04};
    space_t::list_t list;
    space_t::iterator_t iter;
    space_t space;

    $display("\n--- lookup addrs ---");

    iter = new();
    
    foreach (addrs[i]) begin
      $display("\nlooking up %8x", addrs[i]);
      list = sys.find_addr_all(addrs[i]);
      if(list != null && list.size() > 0) begin
	iter.bind_list(list);
	void'(iter.first());
	while(!iter.at_end()) begin
	  space = iter.get();
	  $display(space.to_str());
	  void'(iter.next());
	end
      end
      else
	$display("addr %x not found", addrs[i]);
    end
    
  endfunction
    
endclass

//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

  test t;

  initial begin
    t = new();
    t.dump();
    t.lookup_paths();
    t.lookup_addrs();
  end
  
endmodule

    


