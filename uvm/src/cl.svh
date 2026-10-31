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

localparam string SVX_CL_MSG_ID= "SVX/CL/PARSE";

//----------------------------------------------------------------------
// cl_opt_desc
//
// A command line option descriptor contains information about a
// command line option that could appear.
//----------------------------------------------------------------------
class cl_opt_desc;
  string name;
  type_handle_base th;
  bit multiple;
  type_container_base default_value;
  string fmt;

  function void print();
    $write("%12s: %s (fmt=%s)", name, th.get_typename(), fmt);
    if(default_value != null)
      $write(" = %s", default_value.val2str());
    if(multiple)
      $display(" (multiple ok)");
    else
      $display();
  endfunction
  
endclass

// Convenience typedef for cl_opt_desc traits
typedef class_traits#(cl_opt_desc) cl_opt_traits;

//----------------------------------------------------------------------
// print_cl_opt
//
// A function class for printing cl_opt_desc objects.
//----------------------------------------------------------------------
class print_cl_opt extends fcn#(cl_opt_desc);
  function void f(cl_opt_desc opt);
    opt.print();
  endfunction
endclass

//----------------------------------------------------------------------
// fmt_table
//
// A table of format strings used to print values of various data
// types. In addition to holding format strings, this table serves as
// the list of data types supported by the command line processor.
//
// The class should not be instantiated. For internal use only.
// ----------------------------------------------------------------------
class fmt_table;

  static local map#(type_handle_base, string, string_traits) fmt_map;

  // Populate the table at static initialization time (before time 0).
  static local bit is_populated = populate_table();

  // Constructor is local because this class should never be
  // instantiated.
  local function new();
  endfunction

  static function bit populate_table();
    fmt_map = new();
    void'(fmt_map.insert(type_handle#(string)::get(), "%s"));
    void'(fmt_map.insert(type_handle#(real)::get(), "%g"));
    void'(fmt_map.insert(type_handle#(bit)::get(), "%b"));
    void'(fmt_map.insert(type_handle#(int8_t)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(int16_t)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(int32_t)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(int64_t)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(uint8_t)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(uint16_t)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(uint32_t)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(uint64_t)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(byte)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(shortint)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(longint)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(int)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(byte unsigned)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(shortint unsigned)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(int unsigned)::get(), "%0d"));
    void'(fmt_map.insert(type_handle#(longint unsigned)::get(), "%0d"));
    return 1;
  endfunction

  // Retrieve a format string based on data type.
  static function string get_fmt(type_handle_base th);
    string fmt = fmt_map.get(th);
    return fmt;
  endfunction

endclass
  
//----------------------------------------------------------------------
// cl_mgr
//
// Command Line option manager contains the map of command line option
// descriptors.  This is the set of all possible command line options
// that are available.
//
// All the functions and data structures are static so there's no need
// to instantiate this class.
//----------------------------------------------------------------------
class cl_mgr;

  typedef map_iterator #(string, cl_opt_desc, cl_opt_traits) map_iter_t;

  local static map#(string, cl_opt_desc, cl_opt_traits) opt_map;

  //--------------------------------------------------------------------
  // constructor
  //
  // Constructor is local so it can only be called from within this
  // class.
  //--------------------------------------------------------------------
  local function new();
  endfunction

  //--------------------------------------------------------------------
  // add
  //
  // Add a new command line option to the list of options
  //--------------------------------------------------------------------
  static function void add(string name, cl_opt_desc opt);
    if(opt_map == null)
      opt_map = new();
    void'(opt_map.insert(name, opt));
  endfunction

  //--------------------------------------------------------------------
  // find
  //--------------------------------------------------------------------
  static function cl_opt_desc find(string name);
    return (opt_map == null) ? cl_opt_traits::empty : opt_map.get(name);
  endfunction

  //--------------------------------------------------------------------
  // dump
  //
  // Dump the list of command line options
  //--------------------------------------------------------------------
  static function void dump();
    map_iter_t iter;
    print_cl_opt print;
    
    if(opt_map == null) begin
      `uvm_warning("SVX//PARSE", "Option map is empty");
      return;
    end
    
    iter = new(opt_map);
    print = new();
    
    $display("\n--- Command Line Option Table ---");
    algo#(cl_opt_desc, cl_opt_traits)::for_each(iter, print);
    $display("--- END Command Line Option Table ---");
  endfunction

endclass

//----------------------------------------------------------------------
// cl
//
// A convenience layer for adding new items to the cl_mgr.
//----------------------------------------------------------------------
class cl #(type T=int);

  //--------------------------------------------------------------------
  // add
  //--------------------------------------------------------------------
  static function void add(string name, string fmt="");

    string new_fmt;
    
    cl_opt_desc opt = new();
    opt.name = name;
    opt.th = type_handle#(T)::get();
    
    new_fmt = fmt_table::get_fmt(opt.th);
    if(new_fmt == string_traits::empty) begin
      string msg;
      $sformat(msg, "Unsupported command line option data type: %s",
	       opt.th.get_typename());
      `uvm_error(SVX_CL_MSG_ID, msg);
      return;
    end

    opt.fmt = (fmt == "") ? new_fmt : fmt;
    cl_mgr::add(name, opt);
  endfunction

  //--------------------------------------------------------------------
  // add_with_default
  //--------------------------------------------------------------------
  static function void add_with_default(string name, T def, string fmt="");

    string new_fmt;

    cl_opt_desc opt = new();
    type_container#(T) val = new();

    opt.name = name;
    opt.th = type_handle#(T)::get();

    new_fmt = fmt_table::get_fmt(opt.th);
    if(new_fmt == string_traits::empty) begin
      string msg;
      $sformat(msg, "Unsupported command line option data type: %s",
	       opt.th.get_typename());
      `uvm_error(SVX_CL_MSG_ID, msg);
      return;
    end
    
    opt.fmt = (fmt == "") ? new_fmt : fmt;
    val.set(def);
    val.set_default_fmt(opt.fmt);
    opt.default_value = val;
    cl_mgr::add(name, opt);

    // Put the default value into the resource database
    uvm_resource_db#(T)::set("CL::*", name, def, null);
  endfunction

endclass
