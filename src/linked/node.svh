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
// class: node
//
// A node is a named container.  It inherits from container which
// provides the notion of a type handle.  The node class further
// provides a naming service and marking, which can be used for
// traversals to avoid redundant visits
//----------------------------------------------------------------------
class node extends object;

  local string name;
  local bit m_mark;

  function new(string nm = "");
    set_name(nm);
  endfunction

  function void set_name(string nm);
    name = nm;
  endfunction

  function string get_name();
    return name;
  endfunction

  virtual function void mark();
    m_mark = 1;
  endfunction

  virtual function void unmark();
    m_mark = 0;
  endfunction

  virtual function bit get_mark();
    return m_mark;
  endfunction

endclass

