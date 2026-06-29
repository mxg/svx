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
// range
//----------------------------------------------------------------------

class range#(type T=int, type P=void_traits)
  extends list_bidir_iterator#(T,P);

  // x Verilator seems to have trouble findibng typedefs in a base
  // class, so we replicate ones we need here.
  typedef vector#(T,P) list_t;  

  local index_t ub; // upper bound
  local index_t lb; // lower cound

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  function new(list_t list_inst = null, index_t lower_bound, index_t upper_bound);
    super.new(list_inst);
    lb = lower_bound;
    ub = upper_bound;

    // Make sure upper and lower bounds are within range of the
    // vector.
    if(lb >= m_list.size())
      lb = m_list.size() - 1;
    if(ub >= m_list.size())
      ub = m_list.size();
    if(lb > ub) begin
      index_t tmp;
      tmp = lb;
      ub = lb;
      lb = tmp;
    end
  endfunction

  virtual function bit first();
    idx = lb;
    return (m_list != null && m_list.size() > 0);
  endfunction

  virtual function bit next();
    if((m_list == null) || (m_list.size() == 0) ||
       ((idx > lb) && (idx > ub)))
      return 0;
    if(idx <= ub)
      idx++;
    return 1;
  endfunction    

  virtual function bit is_last();
    return ((m_list != null) && (m_list.size() > 0) && (idx >= ub));
  endfunction

  virtual function bit at_end();
    if(m_list == null || m_list.size() == 0)
      return 1;
    return (idx > ub);    
  endfunction

  virtual function bit last();
    if(m_list == null)
      return 0;
    idx = ub;
    return (m_list.size() > 0);
  endfunction

  virtual function bit prev();
    if(m_list == null || m_list.size() == 0 || idx < 0)
      return 0;
    if(idx >= lb)
      idx--;
    return 1;
  endfunction

  virtual function bit is_first();
    return ((m_list != null) && ((m_list.size() > 0) && (idx == lb)));
  endfunction

  virtual function bit at_beginning();
    if(m_list == null || m_list.size() == 0)
      return 1;
    return (idx < lb);
  endfunction  

endclass

