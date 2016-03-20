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

import clk_gen::*;
import svx::*;

`timescale 1ps / 1ps

//----------------------------------------------------------------------
// clock generator
//----------------------------------------------------------------------
module clock_generator#(int unsigned N=1)(wire clks[N]);

  typedef deque#(clk_descriptor#(N), class_traits#(clk_descriptor#(N))) clk_vec_t;

  clk_if#(N) ckif(clks);

  // Clock start event.  Shared amongst all the clock descriptors
  event start_clocks;

  // Object that runs all the clock processes
  clk_processor#(N) ckgen;

  // Create the vector of clock descriptors
  function clk_vec_t create_clock_descriptors();
    clk_descriptor#(N) cd;

    clk_vec_t vec = new();

    // First clock
    cd = new();
    cd.set_name("master_clock");
    cd.set_freq(10.0e6);
    cd.set_start_event(start_clocks);
    cd.set_vif(ckif, 0);
    cd.set_scale(clk_descriptor#(N)::NANOSEC);
    cd.set_verbose();
    vec.push_back(cd);
    

    // Second clock
    cd = new();
    cd.set_name("slow_clock");
    cd.set_freq(1.0e6);
    cd.set_duty_cycle(0.7);
    cd.set_scale(clk_descriptor#(N)::NANOSEC);
    cd.set_start_event(start_clocks);
    cd.set_vif(ckif, 1);

    cd.set_verbose();
    vec.push_back(cd);

    // Third clock
    cd = new();
    cd.set_name("fast_clock");
    cd.set_freq(67.62e6);
    cd.set_scale(clk_descriptor#(N)::NANOSEC);
    cd.set_start_event(start_clocks);
    cd.set_vif(ckif, 2);
    cd.set_verbose();
    vec.push_back(cd);

    // Fourth clock
    cd = new();
    cd.set_name("heartbeat");
    cd.set_freq(100.0e3);
    cd.set_scale(clk_descriptor#(N)::NANOSEC);
    cd.set_duty_cycle(0.2);
    cd.set_start_event(start_clocks);
    cd.set_vif(ckif, 3);
    cd.set_verbose();
    vec.push_back(cd);

    return vec;

  endfunction
  
  initial begin
    // create a new clock generator
    ckgen = new();

    // create a vector of clock descriptors and bind it to the clock
    // generator
    ckgen.set_vector(create_clock_descriptors());

    // Print the descriptors
    ckgen.print_descriptors();

    // Let's go!
    $display("starting clocks");
    ckgen.exec();
    -> start_clocks;
    #1000000;
    ckgen.suspend();
  end
    
endmodule;
