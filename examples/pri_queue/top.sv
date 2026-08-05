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

module top;

  import svx::*;
  `include "svx_macros.svh"
    
  import pri_queue_pkg::*;

  pri_queue#(string, string_traits) q;

  //----------------------------------------------------------------------
  // Add jobs to the queue
  //----------------------------------------------------------------------
  initial begin
    queue#(string, string_traits) jobs;
    string job;
    uint32_t pri;

    jobs = new();
    q = new();

    // pre-load jobs queue with a bunch of jobs
    jobs.put("A");
    jobs.put("B");
    jobs.put("C");
    jobs.put("D");
    jobs.put("E");
    jobs.put("F");
    jobs.put("G");
    jobs.put("H");
    jobs.put("I");
    jobs.put("J");
    jobs.put("K");
    jobs.put("L");
    jobs.put("M");
    jobs.put("N");
    jobs.put("O");
    jobs.put("P");

    // Populate the priority queue with jobs.  The job priorities are
    // randomized.
    while(!jobs.is_empty()) begin
      pri = $urandom() % 10;
      job = jobs.get();
      void'(q.insert(pri, job));
      $display("%6t: inserting job %s with pri = %0d", $time, job, pri);
      #2;
    end

  end

  //----------------------------------------------------------------------
  // Pull jobs from the queue
  //----------------------------------------------------------------------
  initial begin
    #0; // let the other thread start first
    // Pull jobs in priority order
    forever begin
      wait (!q.is_empty());
      #5;
      $display("%6t: executing job = %s", $time, q.pull());
    end
  end
endmodule


    
