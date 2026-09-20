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

class algo2#(type T1=int, type P1=void_traits, type T2=T1, type P2=P1);

  //-------------------------------------------------------------------
  // zip
  //
  // An algorithm that traverses two iterators simultaneously.
  //--------------------------------------------------------------------
  static function void zip(fwd_intf#(T1,P1) iter1, 
			   fwd_intf#(T2,P2) iter2,
			   fcn2#(T1,T2) fn);

    if(iter1 == null || iter2 == null || fn == null)
      return;

    if(!iter1.first() || !iter2.first())
      return;
    
    while(!iter1.at_end() && !iter2.at_end()) begin
      T1 t1 = iter1.get();
      T2 t2 = iter2.get();
      fn.f(t1, t2);
      void'(iter1.next());
      void'(iter2.next());
    end
  endfunction

endclass

      

