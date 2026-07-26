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
// algo
//----------------------------------------------------------------------
class algo#(type T=int, type P=void_traits);

  static function uint32_t count(bidir_iterator_base#(T,P) iter, predicate#(T) p);
    uint32_t n = 0;
    void'(iter.first());
    while(!iter.at_end()) begin
      if(p.is_true(iter.get()))
	n++;
      void'(iter.next());
    end
    return n;
  endfunction

  //--------------------------------------------------------------------
  // all_of
  //
  // Return true if the predicate holds (is true) for all of the
  // elements in the list
  //--------------------------------------------------------------------
  static function bit all_of(bidir_iterator_base#(T,P) iter, predicate#(T) p);
    bit ok = 1;
    void'(iter.first());
    while(ok && !iter.at_end()) begin
      ok &= p.is_true(iter.get());
      void'(iter.next());
    end
    return ok;
  endfunction

  //--------------------------------------------------------------------
  // none_of
  //
  // Return true if the predicate does not hold (is false) for all of
  // the elements in the list.
  //--------------------------------------------------------------------
  static function bit none_of(bidir_iterator_base#(T,P) iter, predicate#(T) p);
    bit ok = 0;
    void'(iter.first());
    while(!ok && !iter.at_end()) begin
      ok |= p.is_true(iter.get());
      void'(iter.next());
    end
    return !ok;
  endfunction

  //--------------------------------------------------------------------
  // any of
  //
  // Return true if the predicate holds (is true) for at least one
  // element in the list.
  //--------------------------------------------------------------------
  static function bit any_of(bidir_iterator_base#(T,P) iter, predicate#(T) p);
    return !none_of(iter, p);
  endfunction

  //--------------------------------------------------------------------
  // find
  //
  // Locate the first element in the list for which the predicate
  // holds (is true).  Return the iterator whose current element is
  // the first element for which the predicate is true.
  //--------------------------------------------------------------------
  static function bidir_iterator_base#(T,P) find(bidir_iterator_base#(T,P) iter, predicate#(T) p);
    bit found = 0;
    void'(iter.first());
    while(!found && !iter.at_end()) begin
      found = p.is_true(iter.get());
      if(!found)
	void'(iter.next());
    end
    return iter;
  endfunction
  
endclass

