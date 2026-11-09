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
// agreement
//
// An agreement is a lightweight synchronization primitve.  It
// provides a means for synchronizing multiple threads.  This is an
// implementation of the agreement class described in the 2017 SNUG
// paper "Shutdown with Agreements in a UVM Testbench" by Mark
// Glasser.
//----------------------------------------------------------------------
class agreement extends uvm_barrier;
  
  typedef enum{AGREE, DISAGREE, WAIT} agree_t;
  
  local static bit debug = 0;
  local static agree_t participants[uvm_object];
  
  function new(string name = "agreement");
    super.new(name);
    set_threshold(1);
  endfunction
  
  static function void set_debug();
    debug = 1;
  endfunction
  
  static function void clr_debug();
    debug = 0;
  endfunction

  //--------------------------------------------------------------------
  // update
  //
  // Update the agreement's state.
  //--------------------------------------------------------------------
  local function void update(uvm_object ptcpnt,
                       agree_t a);

    // If there is no change in vote, then there is nothing to update
    if(participants.exists(ptcpnt) &&
       participants[ptcpnt] == a)
      return;
    
    // Add a new participant and/or change the agreement state.
    participants[ptcpnt] = a;

    // Update the threshold based on the change in state.
    case(a)
      AGREE:    set_threshold(get_threshold() - 1);
      DISAGREE: set_threshold(get_threshold() + 1);
      WAIT:;    // do nothing
    endcase
    
  endfunction
  
  //--------------------------------------------------------------------
  // agree
  //
  // Change the agreement state to "AGREE."
  //--------------------------------------------------------------------
  function void agree(uvm_object obj, int lineno = 0);
    update(obj, AGREE);
    if(debug)
      `uvm_info("AGREE", status_msg(obj, lineno), UVM_NONE);
  endfunction
  
  //--------------------------------------------------------------------
  // disagree
  //
  // Change the agreement state to "DISAGREE."
  //--------------------------------------------------------------------
  function void disagree(uvm_object obj, int lineno = 0);
    update(obj, DISAGREE);
    if(debug)
      `uvm_info("DISAGREE", status_msg(obj, lineno), UVM_NONE);
  endfunction
  
  //--------------------------------------------------------------------
  // wait_for_agreement
  //
  // Block until agreement is reached.
  //--------------------------------------------------------------------
  task wait_for_agreement(uvm_object obj, int lineno = 0);
    wait_for();
    if(debug)
      `uvm_info("ALL IN AGREEMENT", status_msg(obj, lineno), UVM_NONE);
  endtask
  
  //--------------------------------------------------------------------
  // clear
  //
  // Clear the agreement's state.
  //--------------------------------------------------------------------
  function clear(uvm_object obj, int lineno = 0);
    set_threshold(1);
    if(debug)
      `uvm_info("CLEAR", status_msg(obj, lineno), UVM_NONE);
  endfunction
  
  //--------------------------------------------------------------------
  // status_msg
  //
  // Print a message showing the state of the agreement. How manay
  // waiters are still waiting?
  //--------------------------------------------------------------------
  local function string status_msg(uvm_object obj = null,
                                   int lineno = 0);
    string msg;
  
    case(1)
      (obj == null) && (lineno == 0) :
            $sformat(msg, "[%s] threshold = %0d",
                     get_name(), get_threshold());
      (obj == null) && (lineno != 0) : $sformat(msg, "[%s] threshold = %0d @ %0d",
                                                get_name(), get_threshold(), lineno);
      (obj != null) && (lineno == 0) : $sformat(msg, "[%s] %s: threshold = %0d",
                                                get_name(), obj.get_full_name,
                                                get_threshold());
      (obj != null) && (lineno != 0) : $sformat(msg, "[%s] %s: threshold = %0d @ %0d",
                                                get_name(), obj.get_full_name,
                                                get_threshold(), lineno);
    endcase
    
    return msg;
    
  endfunction
  
endclass
