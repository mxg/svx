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
// physical_constant
//
// A class that represents a physical constant.  One field contains the
// value of the constant and the other a string that represents the
// units.  This is used in the basic example below.
// ----------------------------------------------------------------------
class physical_constant;
  real val;
  string units;
endclass

// Here are some type-specific containers that we will use in the
// polymorphic container example.  While we are using int, real, and
// string as the types in this example, you can make a container with
// any type whatsoever.
//
// Notice that we use the get() function to retrieve the object in the
// container.  The object is declared as local and is not visible in a
// derived class.  The get() function lets us access the object and
// ensures there's no funny business (i.e. the object is not modified in
// this context).

class int_container extends type_container#(int);
  function string convert2string();
    string s;
    $sformat(s, "%0d", get());
    return s;
  endfunction
endclass

class real_container extends type_container#(real);
  function string convert2string();
    string s;
    $sformat(s, "%0g", get());
    return s;
  endfunction
endclass

class string_container extends type_container#(string);
  function string convert2string();
    return get();
  endfunction
endclass

//----------------------------------------------------------------------
// map example
//
// A class that contains some usage examples for map#(T,P)
//----------------------------------------------------------------------
class map_example;

  function void run();
    basic_example();
    polymorphic_example();
  endfunction

  //--------------------------------------------------------------------
  // The basic example demonstrates how to insert things into a map,
  // lookup things in a map, and traverse over all the items in the map.
  // The map maps string names to objects describing various physical
  // constants.  First we create the map and populate it with physical
  // constant objects.  Then we lookup physical constants by name.  The
  // example illustrates a successful and a failed lookup.
  // --------------------------------------------------------------------
  function void basic_example();
    map#(string, physical_constant, class_traits#(physical_constant)) tbl;
    map_fwd_iterator#(string, physical_constant, class_traits#(physical_constant)) iter;
    physical_constant pc;
    string key;

    // Create a table of physical constants
    tbl = new();

    pc = new();
    pc.val = 96485.33289;
    pc.units = "C mol";
    tbl.insert("faraday_constant", pc);
	 
    pc = new();
    pc.val = 6.626070040e-34;
    pc.units = "J s";
    tbl.insert("planck_constant", pc);

    pc = new();
    pc.val = 6.022140857e23;
    pc.units = "mol^-1";
    tbl.insert("avogadro_constant", pc);

    pc = new();
    pc.val = 1.38064852e-23;
    pc.units = "J K^-1";
    tbl.insert("boltzmann_constant", pc);

    pc = new();
    pc.val = 9.10938356e-31;
    pc.units = "kg";
    tbl.insert("electron_mass", pc);

    pc = new();
    pc.val = 1.672621898e-27;
    pc.units = "kg";
    tbl.insert("proton_mass", pc);

    pc = new();
    pc.val = 2.067833831e-15;
    pc.units = "Wb";
    tbl.insert("magnetic_flux_constant", pc); 

    pc = new();
    pc.val = 1.6021766208e-19;
    pc.units = "C";
    tbl.insert("elementary_charge", pc); 

    // ----- END TABLE -----

    // Print the table.  Traverse it and print each item. First, create
    // the iterator and bind it to the table.
    iter = new(tbl);

    $display("------<<< Table of Physical Constants >>>-------");
    iter.first();
    while(!iter.at_end()) begin
      // Using the iterator, retrieve the item from the map container
      pc = iter.get();
      // get_index() returns the key from the current iterator item.
      $display("%25s = %15g %s", iter.get_index(), pc.val, pc.units);
      iter.next();
    end

    // Note: The traversal order of the map, and thus the order in which
    // the table is printed, is not necessarily the same order as the
    // items were inserted.

    // Lookup some items
    key = "proton_mass";
    pc = tbl.get(key);
    if(pc == null)
      $display("Item with key = %s is not in the map", key);
    else
      $display("%s found in the map", key);

    key = "alpha_particle_mass";
    pc = tbl.get(key);
    if(pc == null)
      $display("Item with key = %s is not in the map", key);
    else
      $display("%s found in the map", key);
    
  endfunction

  //--------------------------------------------------------------------
  // polymorphic_example
  //
  // This example demonstrates how, using type containers, we can create
  // a polymorphic map -- that is, store items of different types in the
  // same map.
  // --------------------------------------------------------------------
  function void polymorphic_example();

    // declare a map whose contents are type_containers, which are
    //  polymorphic objects.  Using the polymorphic container, we can
    //  store objects of different types in the same map container.
    map#(string, type_container_base, class_traits#(type_container_base)) poly_map;

    // declare an iterator for the polymorphic map
    map_fwd_iterator#(string, type_container_base, class_traits#(type_container_base)) iter;
    
    int_container ic;
    real_container rc;
    string_container sc;
    type_container_base tcb;

    // Create a map and populate it with polymorphic objects.
    poly_map = new();

    ic = new();
    ic.set(19);
    poly_map.insert("A", ic);

    rc = new();
    rc.set(472.8847);
    poly_map.insert("B", rc);

    sc = new();
    sc.set("hello!");
    poly_map.insert("C", sc);

    // Using an iterator, traverse through the map and print each item.
    // Note that the structure underlying the map#() class is an
    // associative array.  Therefore, the item returned by first() is
    // defined by the SystemVerilog first() method for associative
    // arrays. Similarly, the item returned by next() is defined by the
    // next() function for associative arrays.  First, create the
    // iterator and bind it to the map.
    iter = new(poly_map);
    // Reset the iterator to point to the first object in the map.
    iter.first();
    while(!iter.at_end()) begin
      // Using the iterator, retrieve the item from the map.
      tcb = iter.get();
      // The get_index() function returns the key for the current item.
      $display("%s = %s", iter.get_index(), tcb.convert2string());
      // Advance to the next item in the map.
      iter.next();
    end

    // For some weird reason, if you didn't want to or could not use
    // virtual functions you could still process the polymorphic map
    // using a case statement.  The important point in this part of the
    // example is that we are yusing type handles to identify the type
    // of the object.
    
    iter = new(poly_map);
    iter.first();
    while(!iter.at_end()) begin
      tcb = iter.get();

      // A case statement that switches on the data type in the
      // container.
      case(tcb.get_type_handle())
	(type_handle#(int)::get_type())  :
	  begin
	    type_container#(int) c;
	    $cast(c, tcb);
	    $display("%s = %0d", iter.get_index(), c.get());
	  end

	(type_handle#(real)::get_type())  :
          begin
	    type_container#(real) c;
	    $cast(c, tcb);
	    $display("%s = %0g", iter.get_index(), c.get());
	  end

	(type_handle#(string)::get_type())  :
          begin
	    type_container#(string) c;
	    $cast(c, tcb);
	    $display("%s = %s", iter.get_index(), c.get());
	  end

        endcase			  

      iter.next();
    end
    
  endfunction

endclass
