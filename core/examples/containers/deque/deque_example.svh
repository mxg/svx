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
// deque_example
//----------------------------------------------------------------------
class deque_example extends example;

  deque#(int32_t, int32_traits) dq;

  //--------------------------------------------------------------------
  // setup
  //--------------------------------------------------------------------
  function void setup();
    dq = new();
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  function void run();

    index_t ix;

    // Populate the dequeu from the back.
    for(ix = 0; ix < 5; ix++) begin
      int32_t n = $random() % 1000;
      $display("push back: %0d", n);
      dq.push_back(n);
    end

    // Populate the deque from the front.
    for(ix = 0; ix < 5; ix++) begin
      int32_t n = $random() % 1000;
      $display("push front: %0d", n);
      dq.push_front(n);
    end

    // Retrieve the dequue entries from the front.
    for(ix = 0; ix < 10; ix++) begin
      int32_t n = dq.pop_front();
      $display("pop front: %0d", n);
    end

    $display("\nNew List");
    // Let's put some more stuff in the deque
    for(ix = 0; ix < 5; ix++) begin
      int32_t n = $random() % 1000;
      $display("push back: %0d", n);
      dq.push_back(n);
    end

    // Print it out...
    // We can use the read() function even though it is not a member
    // of the deque API because it is a member of the vector#() base
    // class.
    $display("\nList");
    for(ix = 0; ix < 5; ix++) begin
      int32_t n = dq.read(ix);
      $display("[%0d] %0d", ix, n);
    end

    // Reverse the list...
    dq.reverse();

    // Print it out again.
    $display("\nReverse List");
    for(ix = 0; ix < 5; ix++) begin
      int32_t n = dq.read(ix);
      $display("[%0d] %0d", ix, n);
    end
    
  endfunction

  //--------------------------------------------------------------------
  // show
  //--------------------------------------------------------------------
  function void show();
  endfunction

endclass
