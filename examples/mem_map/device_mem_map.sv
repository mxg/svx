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

//----------------------------------------------------------------------
// Sample Address Map
//----------------------------------------------------------------------
import svx::*;
`include "svx_macros.svh"

import mem_map::*;

//----------------------------------------------------------------------
// erroneous
//----------------------------------------------------------------------
class erroneous extends mem_field #(16);

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);
  endfunction

endclass

//----------------------------------------------------------------------
// start_stop
//----------------------------------------------------------------------
class start_stop extends mem_field #(16);

  erroneous e;

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);

//    e = new("erroneous", this, 12, 100);
  endfunction
  
endclass

//----------------------------------------------------------------------
// status
//----------------------------------------------------------------------
class status extends mem_field #(16);

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);
  endfunction

endclass

//----------------------------------------------------------------------
// csr
//----------------------------------------------------------------------
class csr extends mem_register #(16);

  start_stop s;
  status t;

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);

    s = new("start_stop", this, 0, 4);
    t = new("status", this, 4, 4);
    
  endfunction

endclass

//----------------------------------------------------------------------
// timer
//----------------------------------------------------------------------
class timer extends mem_region #(16);

  csr c;

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);

    c = new("csr", this, 8, 1);
    add_register("seconds", 0, 4);
    add_register("milliseconds", 4, 4);
  endfunction

endclass

//----------------------------------------------------------------------
// uart
//----------------------------------------------------------------------
class uart extends mem_region #(16);

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);

    add_register("read_buf", 0, 1);
    add_register("write_buf", 1, 1);
    add_register("ctrl", 2, 1);
  endfunction

endclass

//----------------------------------------------------------------------
// io_bus
//----------------------------------------------------------------------
class io_bus extends mem_region #(16);

  uart u;

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);

    u = new("uart1", this, 'h00, 8);
    u = new("uart2", this, 'h08, 8);

  endfunction
  
endclass

//----------------------------------------------------------------------
// sys_bus
//----------------------------------------------------------------------
class sys_bus extends mem_view #(16);

  timer t;
  mem_memory#(16) m;

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);

    t = new("timer", this, 0, 8);
    m = new("mem1", this, 'h0080, 'h400);
    m = new("mem2", this, 'h00c0, 'h400);

  endfunction
  
endclass

//----------------------------------------------------------------------
// An alternate view of the system bus
//----------------------------------------------------------------------
class sys_bus_2 extends mem_view #(16);

  mem_memory#(16) m;

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);

      m = new("mem", this, 'h0000, 'h100);
  endfunction

endclass

//----------------------------------------------------------------------
// system
//----------------------------------------------------------------------
class system extends mem_region #(16);

  io_bus io;
  sys_bus s;
  sys_bus_2 s2;

  function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);

    io = new("io_bus", this, 'hff00, 'h100);
    s =  new("sys_bus", this, 'h0000, 'h100);
    s2 = new("sys_bus_2", this, 'h0000, 'h100);

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
	$display("%s", t.convert2string());
    end

  endfunction

  function void lookup_addrs();
    mem_space#(16)::addr_t addrs[$] = {'h00000000, 'h8, 'hf0, 'hff00, 'hff01, 'hff04};
    mem_space#(16)::list_t list;
    mem_space#(16)::fwd_iterator_t iter;
    mem_space#(16) space;

    $display("\n--- lookup addrs ---");

    iter = new();
    
    foreach (addrs[i]) begin
      $display("\nlooking up %8x", addrs[i]);
      list = sys.find_addr_all(addrs[i]);
      if(list != null && list.size() > 0) begin
	iter.bind_list(list);
	iter.first();
	while(!iter.at_end()) begin
	  space = iter.get();
	  $display("%s", space.convert2string());
	  iter.next();
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

  initial begin
    test t = new();
    t.dump();
    t.lookup_paths();
    t.lookup_addrs();
  end
  
endmodule

    


