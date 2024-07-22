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
// class: pair
//----------------------------------------------------------------------
class pair#(type T1=int, type T2=int) extends void_t;

  T1 t1;
  T2 t2;

  function new(T1 a, T2 b);
    t1 = a;
    t2 = b;
  endfunction

  function T1 first();
    return t1;
  endfunction

  function T2 second();
    return t2;
  endfunction

  function void set_first(T1 t);
    t1 = t;
  endfunction

  function void set_second(T2 t);
    t2 = t;
  endfunction
    
endclass

//----------------------------------------------------------------------
// triple
//----------------------------------------------------------------------
class triple#(type T1=int, type T2=int, type T3=int)
  extends pair#(T1,T2);

  T3 t3;

  function new(T1 a, T2 b, T3 c);
    super.new(a,b);
    t3 = c;
  endfunction

  function T3 third();
    return t3;
  endfunction

  function void set_third(T3 t);
    t3 = t;
  endfunction
  
endclass

//----------------------------------------------------------------------
// quadruple
//----------------------------------------------------------------------
class quadruple#(type T1=int, type T2=int, type T3=int, T4=int)
  extends triple#(T1,T2,T3);

  T4 t4;

  function new(T1 a, T2 b, T3 c, T4 d);
    super.new(a, b, c);
    t4 = d;
  endfunction

  function T4 fourth();
    return t4;
  endfunction

  function void set_fourth(T4 t);
    t4 = t;
  endfunction
  
endclass



// use void_traits when putting pair#() in a container
