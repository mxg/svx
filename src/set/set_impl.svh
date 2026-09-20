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
// set
//----------------------------------------------------------------------
class set #(type T=int, type P=void_traits)
  extends typed_container #(T,P);

  typedef set#(T,P) set_t;
  typedef map#(T, uint32_t, uint32_traits) map_t;
  typedef map_iterator#(T, uint32_t, uint32_traits) iter_t;
  typedef vector#(T,P) vector_t;

  map#(T, uint32_t, uint32_traits) smap;

  function new();
    smap = new();
  endfunction

  //--------------------------------------------------------------------
  // size
  //--------------------------------------------------------------------
  virtual function size_t size();
    return smap.size();
  endfunction

  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return smap.is_empty();
  endfunction

  //--------------------------------------------------------------------
  // clear
  //--------------------------------------------------------------------
  virtual function void clear();
    smap.clear();
  endfunction

  //--------------------------------------------------------------------
  // insert
  //
  // Add a new memb3r to the set
  //--------------------------------------------------------------------
  virtual function void insert(T item);
    void'(smap.insert(item, 0));
  endfunction

  virtual function bit contains(T item);
    return smap.exists(item);
  endfunction

  //--------------------------------------------------------------------
  // intersection
  //
  // Compute the intersection of this set with another set.
  //--------------------------------------------------------------------
  virtual function set_t intersection(set_t s);
    
    set_t result = new();
    iter_t iter1;
    iter_t iter2;

    if(s == null || s.is_empty())
      return result;

    iter1 = new(smap);
    iter2 = new(s.smap);

    void'(iter1.first());
    void'(iter2.first());

    // Traverse both sets.  If an item is a member of both sets then
    // add it to the result set.
    while(!iter1.at_end() && !iter2.at_end()) begin
      int32_t cmp = P::compare(iter1.get_index(), iter2.get_index());
      if(cmp == 0) begin
	result.insert(iter1.get_index());
	void'(iter1.next());
	void'(iter2.next());
      end else
	if(cmp < 0)
	  void'(iter1.next());
	else
	  void'(iter2.next());
    end

    return result;
	
  endfunction

  //--------------------------------------------------------------------
  // set_union
  //
  // Compute the union of this set with another set.  We call this
  // function set_union instead of plain "union" because union is a
  // SystemVerilog keyword.
  //--------------------------------------------------------------------
  virtual function set_t set_union(set_t s);

    set_t result;
    iter_t iter1;
    iter_t iter2;

    if(s == null || s.is_empty())
      return this;

    result = new();
    iter1 = new(smap);
    iter2 = new(s.smap);

    void'(iter1.first());
    while(!iter1.at_end()) begin
      if(!result.contains(iter1.get_index()))
	result.insert(iter1.get_index());
      void'(iter1.next());
    end

    void'(iter2.first());
    while(!iter2.at_end()) begin
      if(!result.contains(iter2.get_index()))
	result.insert(iter2.get_index());
      void'(iter2.next());
    end

    return result;
    
  endfunction

  //--------------------------------------------------------------------
  // difference
  //
  // Compute the difference of this set with another set.
  //--------------------------------------------------------------------
  virtual function set_t difference(set_t s);

    set_t result;
    iter_t iter1;

    if(s == null || s.is_empty())
      return this;
    
    result = new();
    iter1 = new(smap);
    
    void'(iter1.first());
    while(!iter1.at_end()) begin
      if(!s.contains(iter1.get_index()))
	result.insert(iter1.get_index());
      void'(iter1.next());
    end

    return result;

  endfunction

  //--------------------------------------------------------------------
  // to_vector
  //
  // Create a vector of all the set members.
  //--------------------------------------------------------------------
  virtual function vector_t to_vector();

    vector_t vec = new();
    iter_t iter = new(smap);
    
    void'(iter.first());
    while(!iter.at_end()) begin
      T t = iter.get_index();
      vec.appendc(t);
      void'(iter.next());
    end

    return vec;
    
  endfunction

  //--------------------------------------------------------------------
  // from_vector
  //
  // Insert all the items in the vector int the set.
  //--------------------------------------------------------------------
  virtual function void from_vector(vector_t vec);

    list_iterator#(T,P) iter;

    if(vec == null || vec.is_empty())
      return;
    
    iter = new(vec);
    
    void'(iter.first());
    while(!iter.at_end()) begin
      T t = iter.get();
      if(!contains(t))
	insert(t);
      void'(iter.next());
    end
  endfunction

endclass

  

    
