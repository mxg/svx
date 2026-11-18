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
// binder
//----------------------------------------------------------------------
module binder();

  import uvm_pkg::*;
  import svx::*;
  `include "uvm_macros.svh"
  `include "svx_macros.svh"

  bind memory configure_if cfg_if (
				   .activate  (activate),
				   .read_only (read_only),
				   .configure (configure),
				   .rst_n     (rst_n),
				   .clk       (clk)
				   );
  
  bind memory mem_channel_if mem_if_0 (
				       .addr	 (addr[0]),
				       .data_in	 (data_in[0]),
				       .data_out (data_out[0]),
				       .rw	 (rw[0]),
				       .en       (en[0]),
				       .rst_n	 (rst_n),
				       .clk	 (clk)
				       );

  bind memory mem_channel_if mem_if_1 (
				       .addr	 (addr[1]),
				       .data_in	 (data_in[1]),
				       .data_out (data_out[1]),
				       .rw	 (rw[1]),
				       .en       (en[1]),
				       .rst_n	 (rst_n),
				       .clk	 (clk)
				       );  

  bind memory mem_channel_if mem_if_2 (
				       .addr	 (addr[2]),
				       .data_in	 (data_in[2]),
				       .data_out (data_out[2]),
				       .rw	 (rw[2]),
				       .en       (en[2]),
				       .rst_n	 (rst_n),
				       .clk	 (clk)
				       );  

  bind memory mem_channel_if mem_if_3 (
				      .addr	 (addr[3]),
				      .data_in	 (data_in[3]),
				      .data_out  (data_out[3]),
				      .rw	 (rw[3]),
				      .en        (en[3]),
				      .rst_n	 (rst_n),
				      .clk	 (clk)
				      );  				     

  initial begin
    // Put the virtual interfaces into the resource database);
    uvm_resource_db#(virtual configure_if)::set("*", "cfg_if",
						top.d.mem.cfg_if, null);
					     
    uvm_resource_db#(virtual mem_channel_if)::set("*", "mem_if_0",
						  top.d.mem.mem_if_0, 
						  null);
    
    uvm_resource_db#(virtual mem_channel_if)::set("*", "mem_if_1",
						  top.d.mem.mem_if_1,
						  null);
    
    uvm_resource_db#(virtual mem_channel_if)::set("*", "mem_if_2",
						  top.d.mem.mem_if_2, 
						  null);
    
    uvm_resource_db#(virtual mem_channel_if)::set("*", "mem_if_3", 
						  top.d.mem.mem_if_3, 
						  null);
  end

endmodule

    
