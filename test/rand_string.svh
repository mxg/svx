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
// class: rand_string
//
// A class that generates a randomized string
//----------------------------------------------------------------------
class rand_string;

  rand byte c;

  constraint ch { (c >= 48 && c <= 57) ||
                  (c >=65 && c <= 90) ||
                  (c >=97 && c <= 122);
                };

  function string rand_string(int unsigned maxlen = 16);

    string s;
    int unsigned i;
    int unsigned n;

    if(maxlen < 2)
      n = 1;
    else
      n = ($urandom % (maxlen - 1)) + 1;

    for(i = 0; i < n; i++) begin
      assert(randomize());
      s = { s, c };
    end

    return s;

  endfunction

endclass

