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
// WITHOUT WARRANTIES OR CONDITIOns OF ANY KIND, either express or
// implied.  See the License for the specific language governing
// permissions and limitations under the License.
//======================================================================

//----------------------------------------------------------------------
// test
//
// Top-level component in the UVM component hierarchy
//----------------------------------------------------------------------
class test extends uvm_component;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    cl_parse clp = new();
    
    // populate the command line option table with all possible
    // command line options.
    cl#(uint32_t)::add("size");
    cl#(int16_t)::add("offset");
    cl#(real)::add("freq");
    cl#(bit)::add("x_mode");
    cl#(bit)::add("z_mode");
    cl#(uint32_t)::add_with_default("channels", 4);
    cl#(string)::add_with_default("name", "<none>");
    cl#(int32_t)::add_with_default("bias", 0);
    cl#(uint32_t)::add("base", "%8x");

    // Just for hoots let's see what's in the option table.
    cl_mgr::dump();

    // parse the options.
    clp.parse();

    // Let's look at the resource database It should contain all the
    // parsed options plus all the defaults.
    $display("\n--- Resource Database ---");
    uvm_resource_db#(bit)::dump();
    $display("--- END Resource Database ---");

    
  endfunction

  task run_phase(uvm_phase phase);
    uint32_t size;
    int32_t offset;
    real freq;
    bit	 x_mode;
    bit	 z_mode;
    int32_t channels;
    int32_t bias;
    int32_t base;

    phase.raise_objection(this);

    $display("\n--- Command line options stored in the resource database ---");
    
    // Let's see if everything is in the resoure database.
    if(!uvm_resource_db#(int32_t)::read_by_name("CL::", "size", size, this))
      `uvm_error("NOT FOUND", "Not found in the resource database: size")
    else
      $display("size = %0d", size);

    if(!uvm_resource_db#(int32_t)::read_by_name("CL::", "offset", offset, this))
      `uvm_error("NOT FOUND", "Not found in the resource database: offset")
    else
      $display("offset = %0d", offset);

    if(!uvm_resource_db#(real)::read_by_name("CL::", "freq", freq, this))
      `uvm_error("NOT FOUND", "Not found in the resource database: freq")
    else
      $display("freq = %0g", freq);

    if(!uvm_resource_db#(bit)::read_by_name("CL::", "x_mode", x_mode, this))
      `uvm_error("NOT FOUND", "Not found in the resource database: x_mode")
    else
      $display("x_mode = %s", ((x_mode==1) ? "ON" : "OFF"));

    if(!uvm_resource_db#(bit)::read_by_name("CL::", "z_mode", z_mode, this))
      `uvm_error("NOT FOUND", "Not found in the resource database: z_mode")
    else
      $display("z_mode = %s", ((z_mode==1) ? "ON" : "OFF"));

    if(!uvm_resource_db#(int32_t)::read_by_name("CL::", "channels", channels, this))
      `uvm_error("NOT FOUND", "Not found in the resource database: channels")
    else
      $display("channels = %0d", channels);

    if(!uvm_resource_db#(int32_t)::read_by_name("CL::", "bias", bias, this))
      `uvm_error("NOT FOUND", "Not found in the resource database: bias")
    else
      $display("bias = %0d", bias);

    if(!uvm_resource_db#(int32_t)::read_by_name("CL::", "base", base, this))
      `uvm_error("NOT FOUND", "Not found in the resource database: base")
    else
      $display("base = %8x", base);    

    $display("--- End Command line options ---");
    
    phase.drop_objection(this);
    
  endtask

endclass

    

      
