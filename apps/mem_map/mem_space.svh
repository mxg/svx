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
// mem_space
//
// mem_space is a base class for any object that occupies some piece of
// a memory space.  This could be a register, field, memory, or a memory
// region.
//----------------------------------------------------------------------
virtual class mem_space #(int unsigned ADDR_SIZE=32) extends tree;

  typedef mem_space#(ADDR_SIZE) mem_space_t;

  // typedefs for address and size.  Note that size has one more bit
  // than address.  The address field stores addresses from 0 to n-1,
  // where n is the size of the address space.  Size stores sizes from 1
  // - n, which requires one more bit than address.
  
  typedef bit [ADDR_SIZE-1:0] addr_t;
  typedef bit [ADDR_SIZE:0] size_t;
  
  // An enum that represents all of the kinds of memory spaces
  typedef enum {MEMORY, REGISTER, REGION, FIELD, VIEW} mem_space_type_t;

  // These next twp typedefs are conveniences for the user.  The first
  // is the type of the list returned by searches, the second is an
  // iterator for the list.  The expectation is that users can use these
  // in their own code to save a bit of typing.  For example,
  //
  //    mem_space#(16)::list_t list;
  //    mem_space#(16)::fwd_iterator_t iter;
  //
  //    list = top.find_addr_all(addr);
  //    iter = new(list);
  //    iter.first();
  //    ... etc
  
  // A typedef for the list of memory spaces returned by searched.
  typedef deque #(mem_space_t, class_traits#(mem_space_t)) list_t;

  // A typedef for an iterator for traversing the lists returned from
  // searches.
  typedef list_fwd_iterator#(mem_space_t, class_traits#(mem_space_t)) fwd_iterator_t;


  //====================================================================
  // Internal state data
  // hands off!
  //====================================================================

  // Offset from parent.  Offset is in bytes except for FIELDs whose
  // offsets are in bits.
  local addr_t offset;

  // The size of a memory space is expressed in bytes, except for
  // fields.  Field sizes are expressed in bits.
  local size_t size;

  // Identify the type of the memory space.
  local mem_space_type_t mem_space_type;

  // Absolute address of the memory space with respect to its parent.
  // This field is not supplied by the user.  Instead it is calculated
  // after the memory space hierarchy is in place.
  local addr_t addr;

  // Has_error is set if this memory space was determoined to be
  // erroneous for one reason or another.
  local bit has_error;

  // These two fields are used in the construction of the print format
  // to print the memory space.  The sizes are computed based on the
  // ADDR_SIZE parameter.
  local static int unsigned addr_print_len = compute_addr_print_len();
  local static int unsigned size_print_len = compute_size_print_len();
  local static string print_fmt = compute_print_fmt();

  //--------------------------------------------------------------------
  // constructor
  //--------------------------------------------------------------------
  function new(string name, mem_space_t parent, mem_space_type_t _type,
               addr_t _offset, size_t _size);

    super.new(name, parent);
    offset = _offset;
    size = _size;
    mem_space_type = _type;

    // Let's do some error checking to make sure everything is OK as we
    // add a new memory space to the hierarchy.

    if(_size == 0) begin
      $display("*** error: The size of a memory space cannot be zero");
      has_error = 1;
    end
    
    if((parent != null) && (!parent.check_child(this))) begin
      $display("*** error: A %s cannot contain a %s\n           parent = %s, child = %s", parent.get_type_name(), get_type_name(), parent.get_full_name(), get_name());
      has_error = 1;
    end

    // propagate the errors upward
    if(parent != null)
      parent.has_error |= has_error;
  endfunction

  //--------------------------------------------------------------------
  // insert_space
  //
  // Add a new child to this memory space.  The child could be a single
  // memory space object or an entire (sub)tree.
  //--------------------------------------------------------------------
  function void insert_space(mem_space_t space);
    check_child(space);
    insert(space);
  endfunction
  

  static local function int unsigned compute_addr_print_len();
    return (ADDR_SIZE / 4) + (ADDR_SIZE % 4);
  endfunction

  static local function int unsigned compute_size_print_len();
    return ((ADDR_SIZE+1) / 4) + ((ADDR_SIZE+1) % 4);
  endfunction

  static local function string compute_print_fmt();
    string fmt;
      $sformat(fmt, "%%8s  %%1s [%%%0dx:%%%0dx] %%%0dx+%%%0dx: %%s",
             addr_print_len, addr_print_len, addr_print_len, size_print_len);
    return fmt;
  endfunction

  //--------------------------------------------------------------------
  // space identification
  //
  // Each sub-class of mem_space must identify itself as to what kind of
  // space it is.  The function get_type() is used to do this.

  pure virtual function mem_space_type_t get_type();

  // check_child checks to see if a new memory space violates any
  // restrictions.  For exampple, a field can only be a child of a
  // register, and a register cannot be the child of a field.  If any
  // such violations occur in the construction of a new memory space
  // this function must return 1.  If there are no violations it must
  // return 0.
  pure virtual function bit check_child(mem_space_t child);

  //====================================================================
  //
  // Accessors
  //
  //====================================================================

  function addr_t get_offset();
    return offset;
  endfunction

  function size_t get_size();
    return size;
  endfunction

  function addr_t get_addr();
    return addr;
  endfunction

  function addr_t get_end_addr();
    return get_addr() + (get_size() - 1);
  endfunction

  function string get_type_name();
    mem_space_type_t space_type = get_type();
    string s = space_type.name();
    return s;
  endfunction

  function bit get_error();
    return has_error;
  endfunction

  function void clear_error();
    has_error = 0;
  endfunction

  //--------------------------------------------------------------------
  // to_str
  //
  // Convert the memory space to a human readable form suitable for
  // printing. The print format is computed based on the ADDR_SIZE class
  // parameter.  It is computed once and stored in a static variable
  // print_fmt.
  //--------------------------------------------------------------------
  function string to_str();
    string s;
    string fmt;
    mem_space_type_t _type = get_type();

    $sformat(s, print_fmt,
             _type.name(),
	     (get_error()?"*":" "),
             get_addr(),
	     get_end_addr(),
             get_offset(),
             get_size(),
             get_full_name());
    
    return s;
  endfunction  

  //--------------------------------------------------------------------
  // calculate_and_check
  //
  // Initiate calculation of absolute addresses and then perform
  // consistency checks.
  //--------------------------------------------------------------------
  function bit calculate_and_check();
    bit ok;
    
    calculate();
    
    ok = check();
    has_error |= !ok;
    return ok;
    
  endfunction

  //--------------------------------------------------------------------
  // calculate
  //
  // Calculate the absolute address for each memory space
  //--------------------------------------------------------------------
  function void calculate(addr_t base_addr = 0);
    
    deque#(tree, class_traits#(tree)) children;
    list_fwd_iterator#(tree, class_traits#(tree)) iter;
    mem_space_t child;

    // The address is calcluated differently depending on the type of
    // memory space.  The address of a FIELD is just its bit position in
    // the register, which is encoded as the offset.  A VIEW uses the
    // same address as its parent since it offers an alternate view of
    // the same memory space.

    case(get_type())
      FIELD   : addr = get_offset();
      VIEW    : addr = base_addr;
      default : addr = base_addr + get_offset();
    endcase

    children = get_children();
    iter = new(children);

    iter.first();
    while(!iter.at_end()) begin
      assert($cast(child, iter.get()));
      child.calculate(get_addr());
      iter.next();
    end

  endfunction

  //--------------------------------------------------------------------
  // check
  //
  // Perform some consistency checks.  First, check to see if there are
  // any improperly overlapping spaces.  Second check to see if the
  // hierarchy is correctly constructed -- that register contain field,
  // but fields do not contain registers, for example.
  //--------------------------------------------------------------------
  function bit check();
    deque#(tree, class_traits#(tree)) children;
    list_fwd_iterator#(tree, class_traits#(tree)) iter;
    mem_space_t child;

    bit ok = 1;

    ok &= check_overlap();

    children = get_children();
    iter = new(children);

    iter.first();
    while(!iter.at_end()) begin
      assert($cast(child, iter.get()));
      ok &= child.check();
      iter.next();
    end

    return ok;
  endfunction

  //--------------------------------------------------------------------
  // check_overlaps
  //
  // Within a single view, a memory space cannot overlap another memory
  // space.  For example, a register cannot overlap a memory or other
  // registers.  However, memory views can overlap.  The view space
  // provides a means of defining memory regions that do in fact
  // overlap, either partially or completely.
  //
  // Check to see if two memory spaces overlap.  This function checks
  // all the memory spaces that are the children of a parent memory
  // space.  The check continues hierarchically until either an overlap
  // is located or there are no more children to check.
  //
  // The algorithm is O(n^2) with an optimization that reduces it to
  // O((n^2)/2).  Each inner iteration is cut short by the number of
  // outer iterations that have already occurred.  This prevents the
  // same pair of children from being checked twice.
  //--------------------------------------------------------------------
  function bit check_overlap();

    deque#(tree, class_traits#(tree)) children;
    list_fwd_iterator#(tree, class_traits#(tree)) outer_iter;
    list_fwd_iterator#(tree, class_traits#(tree)) inner_iter;

    mem_space_t outer_space;
    mem_space_t inner_space;
    bit ok;
    int unsigned count;

    if((num_children() == 0) || (get_type() == VIEW))
      return 1;

    children = get_children();
    outer_iter = new(children);
    inner_iter = new(children);

    //----------------------------------------
    // outer loop
    ok = 1;
    outer_iter.first();
    while(!outer_iter.at_end()) begin
      assert($cast(outer_space, outer_iter.get()));

      //----------------------------------------
      // inner loop
      inner_iter.first();
      // skip ahead to avoid checking things twice.
      inner_iter.skip(count);
      while(!inner_iter.at_end()) begin
	assert($cast(inner_space, inner_iter.get()));
	
	// do not check a space against itself and do not check to see
	// if views overlap since they are allowed to do so.

	if((inner_space != outer_space) &&
	   (inner_space.get_type() != VIEW) &&
	   (outer_space.get_type() != VIEW)) begin
	  if(overlaps(outer_space, inner_space)) begin
	    outer_space.has_error = 1;
	    inner_space.has_error = 1;
	    $display("*** error: The following two spaces overlap:\n%s\n%s",
		     outer_space.to_str(), inner_space.to_str());
	    ok = 0;
	  end
	end

	inner_iter.next();
      end  // inner loop
      
      count++;
      outer_iter.next();
    end // outer loop

    return ok;
	 
  endfunction

  //--------------------------------------------------------------------
  // overlaps
  //
  // This function does all the math to determine if two memory spaces
  // overlap.  The arguments are two memory spaces -- a reference space
  // and one of its siblings in the memory space hierarchy.
  //
  // A one is returned if the two spaces overlap, a zero if they do not.
  //--------------------------------------------------------------------
  function bit overlaps(mem_space_t space, mem_space_t sibling);

    addr_t start_addr;
    addr_t end_addr;
    addr_t sibling_start_addr;
    addr_t sibling_end_addr;

    if(sibling == null)
      return 0;

    start_addr = space.get_addr();
    end_addr = space.get_end_addr();
    sibling_start_addr = sibling.get_addr();
    sibling_end_addr = sibling.get_end_addr();

    if(sibling_start_addr > end_addr || start_addr > sibling_end_addr)
      return 0;
    
    if(sibling_start_addr < start_addr && sibling_end_addr >= start_addr)
      return 1;
    if(sibling_start_addr >= start_addr && sibling_end_addr <= end_addr)
      return 1;
    if(sibling_start_addr <= end_addr && sibling_end_addr >= end_addr)
      return 1;
    if(sibling_start_addr <= start_addr && sibling_end_addr >= end_addr)
      return 1;

    return 0;  // we should never get here
    
  endfunction

  //====================================================================
  //
  // Searching
  //
  //====================================================================
  
  //--------------------------------------------------------------------
  // find_addr
  //
  // Find all of the leaf objects -- registers and memories in which
  // this address resides.
  //--------------------------------------------------------------------
  function list_t find_addr(addr_t search_addr);
    list_t list = new();
    find_addr_recurse(search_addr, list, 0);
    return list;
  endfunction

  //--------------------------------------------------------------------
  // find_addr_all
  //
  // Find ALL objects in which the search address is contained, leaf
  // item or not.
  //--------------------------------------------------------------------
  function list_t find_addr_all(addr_t search_addr);
    list_t list = new();
    find_addr_recurse(search_addr, list, 1);
    return ((list.size() > 0) ? list : null);
  endfunction

  //--------------------------------------------------------------------
  // find_addr_recurse
  //
  // Recursivly traverse the tree looking for memories spaces in which
  // the search address resides.
  //--------------------------------------------------------------------
  function void find_addr_recurse(addr_t search_addr, ref list_t list,
				  input bit all = 0);
    deque#(tree, class_traits#(tree)) deq;
    list_fwd_iterator#(tree, class_traits#(tree)) iter;
    mem_space_t space;
    tree t;
    bit is_in_space = 0;

    // Is the search address within range of this memory space?
    is_in_space = (search_addr >= get_addr() &&
		   search_addr < (get_addr() + get_size()));

    if(!is_in_space) begin
      // search address is not in the space, no further searching is
      // necessary
      return;
    end

    if(all) begin
      list.push_back(this);
      if(num_children == 0)
	return;
    end
    else
      if(num_children() == 0 || get_type() == REGISTER) begin
	list.push_back(this);
	return;
      end

    deq = get_children();
    iter = new(deq);
    iter.first();
    while(!iter.at_end()) begin
      t = iter.get();
      assert($cast(space, t));
      space.find_addr_recurse(search_addr, list, all);
      iter.next();
    end
    
  endfunction

  //======================================================================
  //
  // Dump
  //
  //======================================================================

  function void dump();
    
    tree t;
    tree_fwd_iterator iter = new(this);

    $display("--- Memory Map Dump for: %s ---", get_full_name());
    
    iter.first();
    while(!iter.at_end()) begin
      t = iter.get();
      $display("%s", t.to_str());
      iter.next();
    end

    $display("--- End Memory Map Dump ---");
  endfunction  

endclass

