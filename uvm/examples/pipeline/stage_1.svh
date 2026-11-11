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
// stage_1
//----------------------------------------------------------------------
class stage_1 extends pipe_stage_base #(transaction);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    pipeline_done.disagree(this);
  endfunction    

  task run_phase(uvm_phase phase);
    transaction t;

    for(int i = 0; i < 10; i++) begin
      t = new();
      void'(t.randomize());
      process_item(t);
      $display("stage_1: %10t: %s", $time, t.convert2string());
      #2;
    end

    pipeline_done.agree(this);
  endtask

  task process_item(SEQ item);
    sqr.execute_item(item);
  endtask

endclass
