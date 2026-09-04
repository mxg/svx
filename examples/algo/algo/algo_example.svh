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

class lt_f extends predicate#(uint8_t);
  function bit is_true(uint8_t t);
    return (t < 'h0f);
  endfunction
endclass

class print extends fcn#(uint8_t);
  function void f(uint8_t t);
    $write(" %02x", t);
  endfunction
endclass


//----------------------------------------------------------------------
// algo_example
//----------------------------------------------------------------------

class algo_example extends example;

  vector#(uint8_t, uint8_traits) vec;
  list_bidir_iterator#(uint8_t, uint8_traits) iter;

  uint32_t count;
  bit all;
  bit none;
  bit any;

  //--------------------------------------------------------------------
  // setup
  //--------------------------------------------------------------------
  function void setup();
    // Create a vector and populate it with some values
    vec = vector#(uint8_t, uint8_traits)::create('{'h00, 'hf2, 'hf0, 'h52, 'h07});
    // Create the iterator and bind it to the vector
    iter = new(vec);
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  function void run();
    lt_f p = new();
    print pr = new();
    // Run varioous algorithms on the vector
    all = algo#(uint8_t, uint8_traits)::all_of(iter, p);
    none = algo#(uint8_t, uint8_traits)::none_of(iter, p);
    any = algo#(uint8_t, uint8_traits)::any_of(iter, p);
    count = algo#(uint8_t, uint8_traits)::count(iter, p);
    // print the vector
    $write("vector:");
    algo#(uint8_t, uint8_traits)::for_each(iter, pr);
    $display();
  endfunction

  //--------------------------------------------------------------------
  // show
  //--------------------------------------------------------------------
  function void show();
    $display("The vector has no items < 'h0f: %s", (none?"true":"false"));
    $display("The vector has all items < 'h0f: %s", (all?"true":"false"));
    $display("The vector has at least one item < 'h0f: %s", (any?"true":"false"));
    $display("The vector has %0d items < 'h0f", count);
  endfunction

endclass
