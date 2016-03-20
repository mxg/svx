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
// sorter
//
// Implementation of quicksort.  Based on algorithm defined in
// "Algorithms in C" by Robert Sedgewick, Addison-Wesley, 1990
// ----------------------------------------------------------------------
class sorter#(type T=int, type P=int);

  static function void sort(ref T vec[$]);
    if(vec.size() == 0)
      return;
    qsort(vec, 0, vec.size() - 1);
  endfunction

  static function void qsort(ref T vec[$], input int l, input int r);
    
    int i;
    int j;
    T v;
    T t;
    
    if(r <= l)
      return;

    v = vec[r];
    i = l-1;
    j = r;

    // partition
    forever begin
      do t = vec[++i]; while(i < vec.size() && P::compare(t, v) < 0);
      do t = vec[--j]; while(j >= 0         && P::compare(t, v) > 0);
      if(i >= j) break;
      
      // swap  vec[i] <--> vec[j]
      t = vec[i];
      vec[i] = vec[j];
      vec[j] = t;
    end
    
    t = vec[i];
    vec[i] = vec[r];
    vec[r] = t;
    
    qsort(vec, l, i-1);
    qsort(vec, i+1, r);
    
  endfunction
  
endclass
