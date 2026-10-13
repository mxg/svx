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
// vector_example
//----------------------------------------------------------------------
class vector_example extends example;

  vector#(int32_t, int32_traits) vec;

  //--------------------------------------------------------------------
  // setup
  //--------------------------------------------------------------------
  function void setup();
    // Create a new empty vector.
    vec = new();
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  function void run();

    int32_t n;
    
    // Populate vector with randomized values.  There are two ways to
    // add new slots to a vector.  First, if you write past the end
    // new slots will automatically be added.
    for(index_t ix = 0; ix < 10; ix++) begin
      n = $random() % 1000;
      vec.write(ix, n);
    end

    // The other way is to use appendc() to add new data to the end of
    // the vector, also increasing the vector's size.  We'll add some
    // new items to the vector.
    for(index_t ix = 0; ix < 10; ix++) begin
      n = $random() % 1000;
      vec.appendc(n);
    end

    // We can access the in random access mode as well as
    // sequentially.
    n = vec.read(7);
    n = vec.read(2);
    vec.write(3, 42);

  endfunction

  //--------------------------------------------------------------------
  // show
  //--------------------------------------------------------------------
  function void show();
    
    // Let's look at the contents of the vector We'll traverse the
    // vector sequentially, printing each value along the way.
    $display("vector size: %0d", vec.size());
    for(index_t ix = 0; ix < vec.size(); ix++) begin
      $display("[%0d] -> %0d", ix, vec.read(ix));
    end
    
  endfunction
  
endclass
