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
// An agreement is a lightweight synchronization primitive.  It
// provides a means for synchronizing multiple threads.  This is an
// implementation of the agreement class described in the 2017 SNUG
// paper "Shutdown with Agreements in a UVM Testbench" by Mark
// Glasser.
//----------------------------------------------------------------------
class agreement extends uvm_object;
  
  typedef enum{AGREE, DISAGREE} agree_t;
  
  local static bit debug_all = 0;
  local bit debug;
  local agree_t votes[uvm_object];
  local uint32_t disagreements;
  
  function new(string name = "agreement");
    super.new(name);
  endfunction
  
  function void set_debug();
    debug = 1;
  endfunction
  
  function void clr_debug();
    debug = 0;
  endfunction

  static function void set_debug_all();
    debug_all = 1;
  endfunction
  
  static function void clr_debug_all();
    debug_all = 0;
  endfunction

  //--------------------------------------------------------------------
  // update
  //
  // Update the agreement's state.
  //--------------------------------------------------------------------
  local function void update(uvm_object p, agree_t a);
    agree_t old = votes.exists(p) ? votes[p] : AGREE;
    votes[p] = a;
    if (old != DISAGREE && a == DISAGREE) disagreements++;
    if (old == DISAGREE && a != DISAGREE) disagreements--;
  endfunction  

  //--------------------------------------------------------------------
  // agree
  //
  // Change the agreement state to "AGREE."
  //--------------------------------------------------------------------
  function void agree(uvm_object obj, int lineno = 0);
    update(obj, AGREE);
    if(debug | debug_all)
      `uvm_info("SVX/AGREE", status_msg(obj, lineno), UVM_NONE)
  endfunction
  
  //--------------------------------------------------------------------
  // disagree
  //
  // Change the agreement state to "DISAGREE."
  //--------------------------------------------------------------------
  function void disagree(uvm_object obj, int lineno = 0);
    update(obj, DISAGREE);
    if(debug | debug_all)
      `uvm_info("SVX/DISAGREE", status_msg(obj, lineno), UVM_NONE)
  endfunction
  
  //--------------------------------------------------------------------
  // wait_for_agreement
  //
  // Block until agreement is reached.
  //--------------------------------------------------------------------
  task wait_for_agreement(uvm_object obj, int lineno = 0);
    // Make sure all processes start executing before we wait for
    // agreement.
    #0;
    wait(disagreements == 0);
    if(debug | debug_all)
      `uvm_info("SVX/ALL_IN_AGREEMENT", status_msg(obj, lineno), UVM_NONE)
  endtask
  
  //--------------------------------------------------------------------
  // clear
  //
  // Clear the agreement's state.
  //--------------------------------------------------------------------
  function void clear(uvm_object obj, int lineno = 0);
    votes.delete();
    disagreements = 0;
    if(debug | debug_all)
      `uvm_info("SVX/CLEAR", status_msg(obj, lineno), UVM_NONE)
  endfunction

  //--------------------------------------------------------------------
  // num_disagreements
  //
  // How many disagreements are outstanding?
  //--------------------------------------------------------------------
  function uint32_t num_disagreements();
    return disagreements;
  endfunction
  
  //--------------------------------------------------------------------
  // status_msg
  //
  // Print a message showing the state of the agreement. How many
  // waiters are still waiting?
  //--------------------------------------------------------------------
  local function string status_msg(uvm_object obj = null,
                             int lineno = 0);
    string msg;
    
    case(1)
      (obj == null) && (lineno == 0) :
            $sformat(msg, "[%s] disagreements = %0d",
                     get_name(), num_disagreements());
      (obj == null) && (lineno != 0) : $sformat(msg, "[%s] disagreements = %0d @ %0d",
                                                get_name(), num_disagreements(), lineno);
      (obj != null) && (lineno == 0) : $sformat(msg, "[%s] %s: disagreements = %0d",
                                                get_name(), obj.get_full_name,
                                                num_disagreements());
      (obj != null) && (lineno != 0) : $sformat(msg, "[%s] %s: disagreements = %0d @ %0d",
                                                get_name(), obj.get_full_name,
                                                num_disagreements(), lineno);
    endcase
    
    return msg;
    
  endfunction
  
endclass
