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

//----------------------------------------------------------------------
// list_example
//
// Demonstrate use models for lists
//----------------------------------------------------------------------
class list_example;

  function void run();
    fwd();
  endfunction

  // create a vector and traverse it in in the forward direction.
  function void fwd();

    int unsigned i;
    int n;
    
    // A vector of integers
    vector#(int, int_traits) v;
    
    // An iterator for our list of integers.  Note that the parameters
    // for the iterator are the same as for the vector.
    list_fwd_iterator#(int, int_traits) iter;

    // create the vector container
    v = new();

    // Populate the vector with randomized integers between -999 and
    // 999;
    for(i = 0; i < 20; i++) begin
      n = $random() % 1000;
      // add the new randomized number to the end of the vector
      v.appendc(n);
    end

    // Traverse the vector from front to back using our foward iterator.
    // First, create the iterator and bind it to the vector.
    iter = new(v);

    // Set the iterator to point to the first item in the vector
    iter.first();

    $display("-- unsorted vector --");
    // Visit all the items in the vector
    while(!iter.at_end()) begin
      // Uing the iterator, retrieve the item from the vector container
      n = iter.get();
      // Here we can use the item as we wish.  In this case we'll just
      // print it.
      $display("item = %0d", n);
      // Move to the next item in the vector.
      iter.next();
    end

    // Let's sort the vector
    v.sort();

    // Now, print the vector again, this time in sorted order
    $display("\n-- sorted vector --");
    iter.first();  // reset to the beginning of the vector
    while(!iter.at_end()) begin
      n = iter.get();
      $display("item = %0d", n);
      iter.next();
    end
    
  endfunction
  
endclass
