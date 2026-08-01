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
// algo_example
//----------------------------------------------------------------------

// A predidcate that asks if a value is greater or equal to 50.
class greater_equal_50 extends predicate#(uint16_t);
  function bit is_true(uint16_t t);
    return (t >= 50);
  endfunction
endclass

// A function that prints the value passed in as an argument
class print extends fcn#(uint16_t);
  function void f(uint16_t t);
    $write(" %0d", t);
  endfunction
endclass
  
class algo_example;

  uint16_vector vec = new();
  list_bidir_uint16_iterator iter = new(vec);
  greater_equal_50 ge50 = new();
  print p = new();
  range_uint16 rg;
  
  size_t vector_size;
  size_t upper_bound;
  size_t lower_bound;
  uint32_t count;
  bit is_true;

  function void run();
    $display("\n** Algorithm Example");

    // Populate vector
    vector_size = size_t'($urandom()) % 100;
    for(size_t idx = 0; idx < vector_size; idx++) begin
      vec.appendc(uint16_t'($urandom() % 100));
    end

    upper_bound = size_t'($urandom()) % size_t'(vector_size);
    lower_bound = size_t'($urandom()) % size_t'(upper_bound);
    rg = new(iter, lower_bound, upper_bound);

    // Print the entire vector
    $write("vector:");
    algo#(uint16_t, uint16_traits)::for_each(iter, p);
    $display();
    
    // print all the elements in the range
    $write("range: [%0d:%0d] ", rg.get_lower_bound(), rg.get_upper_bound());
    algo#(uint16_t, uint16_traits)::for_each(rg, p);
    $display();

    // How many elements are >= 50 within the range?
    count = algo#(uint16_t, uint16_traits)::count(rg, ge50);
    $display("range has %0d element(s) >= 50", count);

    // Are all the elements in the range >= 50?
     if(algo#(uint16_t, uint16_traits)::all_of(rg, ge50))
       $display("All range elements are >= 50.");
     else
       $display("Not all range elements are >= 50.");

  endfunction

endclass
