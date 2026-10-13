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

virtual class fcn_base;
endclass

//----------------------------------------------------------------------
// fcn
//
// A class that contains a function that takes a single argument.
//----------------------------------------------------------------------
virtual class fcn#(type T=int) extends fcn_base;

  pure virtual function void f(T t);
  
endclass

//----------------------------------------------------------------------
// fcn2
//
// A class that contains a function that takes two arguments.
//----------------------------------------------------------------------
virtual class fcn2#(type T1=int, type T2=T1) extends fcn_base;

  pure virtual function void f(T1 t1, T2 t2);
  
endclass

//----------------------------------------------------------------------
// accum_fcn
//
// A class that contains a function that takes one argument. The
// seconnd argument is a ref argument used to accumulate or aggregate
// information across calls
//----------------------------------------------------------------------
virtual class accum_fcn#(type T=int, type A=int) extends fcn_base;

  pure virtual function void f(T t, ref A a);

endclass

//----------------------------------------------------------------------
// accum_fcn2
//
// A class that contains a function that takes two arguments and a
// third ref argument for accumulation.
//---------------------------------------------------------------------
virtual class accum_fcn2#(type T1=int, type T2=int, type A=int) 
  extends fcn_base;

  pure virtual function void f(T1 t1, T2 t2, ref A a);

endclass

