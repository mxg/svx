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
// test
//
// Top-level component in the UVM component hierarchy
//----------------------------------------------------------------------
class test extends uvm_component;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //--------------------------------------------------------------------
  // build_phase
  //
  // Demonstrate that all the command line options are available in
  // the resource database.
  //--------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    string name;
    uint32_t size;
    int16_t offset;
    real freq;
    bit	 x_mode;
    bit	 z_mode;
    uint32_t channels;
    int32_t bias;
    uint32_t base;
    string file;
    uint64_t data;
    int64_t bignum;
    int8_t smallnum;

    bit ok;
    uint32_t n;
    uint32_t idx;

    $display("\n--- Command Line Options stored in the resource database ---");
   // Let's see if everything is in the resource database.

    ok = cl#(string)::get("name", name, this);
    $display("name = %s", name);

    ok = cl#(uint32_t)::get("size", size, this);
    $display("size = %0d", size);

    ok = cl#(int16_t)::get("offset", offset, this);
    $display("offset = %0d", offset);

    ok = cl#(real)::get("freq", freq, this);
    $display("freq = %0g", freq);

    ok = cl#(bit)::get("x_mode", x_mode, this);
    $display("x_mode = %s", ((x_mode==1) ? "ON" : "OFF"));

    ok = cl#(bit)::get("z_mode", z_mode, this);
    $display("z_mode = %s", ((z_mode==1) ? "ON" : "OFF"));

    ok = cl#(uint32_t)::get("channels", channels, this);
    $display("channels = %0d", channels);

    ok = cl#(int32_t)::get("bias", bias, this);
    $display("bias = %0d", bias);

    ok = cl#(uint32_t)::get("base", base, this);
    $display("base = %8x", base);    

    // File allows multiple instances on the command line, so
    // let's look at all of them.
    n = cl#(string)::get_num_opts("file");
    $display("file:");
    for(idx = 0; idx < n; idx++) begin
      string val;
      bit ok =  cl#(string)::get_nth("file", idx, val, this);
      $display("  %2d: %s", idx, val);
    end

    ok = cl#(uint64_t)::get("data", data, this);
    $display("data = %x", data);    

    ok = cl#(int64_t)::get("bignum", bignum, this);
    $display("bignum = %0d", bignum);        

    // Smallnum allows multiple instances on the command line, so
    // let's look at all of them.
    n = cl#(int8_t)::get_num_opts("smallnum");
    $display("smallnum:");
    for(idx = 0; idx < n; idx++) begin
      int8_t val;
      bit ok = cl#(int8_t)::get_nth("smallnum", idx, val, this);
      $display("  %2d: %3d", idx, val);
    end
    
    // ok = cl#(int8_t)::get("smallnum", smallnum, this);
    // $display("smallnum = %0d", smallnum);        
    
    $display("--- End Command Line Options ---");

  endfunction

endclass

    

      
