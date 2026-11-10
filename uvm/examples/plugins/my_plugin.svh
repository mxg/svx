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

class component extends uvm_component;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    $display("building %s", get_name());
  endfunction
  
  task run_phase(uvm_phase phase);
    $display("running %s", get_name());
  endtask

endclass
	     
//----------------------------------------------------------------------
// my_plugin
//
// A trivial example oif a UVM plugin.  A plugin is a component with
// all the rights and responsibilities thereof.  A pluugin can
// instantiate subordinate components.
//----------------------------------------------------------------------
class my_plugin extends uvm_component;

  `uvm_component_utils(my_plugin)

  component c1;
  component c2;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    $display("building %s", get_name());
    c1 = new("c1", this);
    c2 = new("c2", this);
  endfunction

  task run_phase(uvm_phase phase);
    $display("running %s", get_name());
  endtask

  function void phase_started(uvm_phase phase);
    $display("starting %s", phase.convert2string());
  endfunction

  function void phase_ended (uvm_phase phase);  
    $display("ending   %s", phase.convert2string());
  endfunction
  
endclass

