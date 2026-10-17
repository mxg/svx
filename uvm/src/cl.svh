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

typedef enum uint32_t { ARG_INT,
			ARG_FLOAT,
			ARG_LOGIC,
			ARG_SWITCH,
			ARG_TIME,
			ARG_NUM,
			ARG_STRING,
			ARG_ID
		      } arg_t;

// Define traits for the arg_t enum
typedef base_unsigned_int_traits#(arg_t)  arg_traits;

//----------------------------------------------------------------------
// cl_opt_desc
//
// A command line option descriptor contains information about a
// command line option that could appear.
//----------------------------------------------------------------------
class cl_opt_desc;
  string name;
  arg_t arg_type;
  bit multiple;

  function void print();
    $write("%12s: %s", name, arg_type.name());
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
//----------------------------------------------------------------------
class print_cl_opt extends fcn#(cl_opt_desc);
  function void f(cl_opt_desc opt);
    opt.print();
  endfunction
endclass

//----------------------------------------------------------------------
// cl_mgr
//
// Command Line option manager contains the map of command line option
// descriptors.  This is the set of all possible command line options
// that are available.
//----------------------------------------------------------------------
class cl_mgr;

  typedef map_iterator #(string, cl_opt_desc, cl_opt_traits) map_iter_t;

  local static cl_mgr inst;
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
  // get
  //
  // Retrieve a handle to the singleton instance
  //--------------------------------------------------------------------
  static function cl_mgr get();
    if(inst == null)
      inst = new();
    return inst;
  endfunction
  
  //--------------------------------------------------------------------
  // add
  //
  // Add a new command line option to the list of options
  //--------------------------------------------------------------------
  static function void add(string name, arg_t arg_type, bit multi = 0);
    cl_opt_desc opt = new();
    opt.name = name;
    opt.arg_type = arg_type;
    opt.multiple = multi;
    
    if(opt_map == null)
      opt_map = new();
    void'(opt_map.insert(name, opt));
  endfunction

  //--------------------------------------------------------------------
  // find
  //--------------------------------------------------------------------
  static function cl_opt_desc find(string name);
    return opt_map.get(name);
  endfunction

  //--------------------------------------------------------------------
  // dump
  //
  // Dump the list of command line options
  //--------------------------------------------------------------------
  static function void dump();
    map_iter_t iter = new(opt_map);
    print_cl_opt print = new();
    algo#(cl_opt_desc, cl_opt_traits)::for_each(iter, print);
  endfunction

endclass
