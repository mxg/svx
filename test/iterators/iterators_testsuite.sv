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

module iterators_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "iterators_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  list_iterators_unit_test list_iterators_ut();
  map_iterators_unit_test map_iterators_ut();
  permute_iterator_unit_test permute_iterator_ut();
  range_unit_test range_ut();


  //===================================
  // Build
  //===================================
  function void build();
    list_iterators_ut.build();
    list_iterators_ut.__register_tests();
    map_iterators_ut.build();
    map_iterators_ut.__register_tests();
    permute_iterator_ut.build();
    permute_iterator_ut.__register_tests();
    range_ut.build();
    range_ut.__register_tests();
    svunit_ts = new(name);
    svunit_ts.add_testcase(list_iterators_ut.svunit_ut);
    svunit_ts.add_testcase(map_iterators_ut.svunit_ut);
    svunit_ts.add_testcase(permute_iterator_ut.svunit_ut);
    svunit_ts.add_testcase(range_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    list_iterators_ut.run();
    map_iterators_ut.run();
    permute_iterator_ut.run();
    range_ut.run();
    svunit_ts.report();
  endtask

endmodule
