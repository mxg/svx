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

  typedef map_iterator #(string, cl_opt_desc_base, cl_opt_traits) map_iter_t;

  local static map#(string, cl_opt_desc_base, cl_opt_traits) opt_map;
  local static bit parse_flag;

  //--------------------------------------------------------------------
  // constructor
  //
  // Constructor is local so it can only be called from within this
  // class.
  //--------------------------------------------------------------------
  local function new();
  endfunction


  // Keep track of whether the parser has been called once.
  static function void set_parse_flag();
    parse_flag = 1;
  endfunction

  static function bit has_been_parsed();
    return parse_flag;
  endfunction

  // Clearing the parse flag is necessary for testing
  static function void clr_parse_flag();
    parse_flag = 0;
  endfunction

  //--------------------------------------------------------------------
  // add
  //
  // Add a new command line option to the list of options
  //--------------------------------------------------------------------
  static function bit add(string name, cl_opt_desc_base opt);
    if(opt_map == null)
      opt_map = new();
    
    if(opt_map.exists(name)) begin
      string msg;
      $sformat(msg, "Command line option %s already exists, cannot be added again",
	       name);
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end
    
    void'(opt_map.insert(name, opt));
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // find
  //--------------------------------------------------------------------
  static function cl_opt_desc_base find(string name);
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
      `uvm_warning(SVX_CL_MSG_ID, "Option map is empty")
      return;
    end
    
    iter = new(opt_map);
    print = new();
    
    $display("\n--- Command Line Option Table ---");
    $display("     name           type       fmt   default value   description");
    $display("------------- ---------------- ---- ---------------- --------------------------------");    
    algo#(cl_opt_desc_base, cl_opt_traits)::for_each(iter, print);
    $display("--- END Command Line Option Table ---");
  endfunction

endclass

//----------------------------------------------------------------------
// opt_factory
//
// Factory for creating option descriptors of various types.
//
// The factory contains some type aliases that SHOULD have the same
// type handle -- e.g., int and int32_t.  It's possible that some
// compilers may not considers these the same type for the purposes of
// creating type_handles.  The extra types are here as a precaution.
//----------------------------------------------------------------------
/* verilator lint_off SIDEEFFECT */
class opt_factory;

  static function cl_opt_desc_base create(type_handle_base th, string name);
    case(th)
      type_handle#(string)::get():
	begin
	  cl_opt_string_desc opt = new(name);
	  return opt;
	end
      
      type_handle#(real)::get():
	begin
	  cl_opt_real_desc opt = new(name);
	  return opt;
	end
   
      type_handle#(bit)::get():
	begin
	  cl_opt_bit_desc opt = new(name);
	  return opt;
	end
   
      type_handle#(int8_t)::get():
	begin
	  cl_opt_int_desc#(int8_t, int8_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(int16_t)::get():
	begin
	  cl_opt_int_desc#(int16_t, int16_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(int32_t)::get():
	begin
	  cl_opt_int_desc#(int32_t, int32_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(int64_t)::get():
	begin
	  cl_opt_int_desc#(int64_t, int64_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(uint8_t)::get():
	begin
	  cl_opt_int_desc#(uint8_t, uint8_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(uint16_t)::get():
	begin
	  cl_opt_int_desc#(uint16_t, uint16_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(uint32_t)::get():
	begin
	  cl_opt_int_desc#(uint32_t, uint32_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(uint64_t)::get():
	begin
	  cl_opt_int_desc#(uint64_t, uint64_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(byte)::get():
	begin
	  cl_opt_int_desc#(byte, byte_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(shortint)::get():
	begin
	  cl_opt_int_desc#(shortint, shortint_traits) opt = new(name);
	  return opt;
	end
      
      type_handle#(longint)::get():
	begin
	  cl_opt_int_desc#(longint, longint_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(int)::get():
	begin
	  cl_opt_int_desc#(int, int_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(byte unsigned)::get():
	begin
	  cl_opt_int_desc#(byte unsigned, byte_unsigned_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(shortint unsigned)::get():
	begin
	  cl_opt_int_desc#(shortint unsigned, shortint_unsigned_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(int unsigned)::get():
	begin
	  cl_opt_int_desc#(int unsigned, int_unsigned_traits) opt = new(name);
	  return opt;
	end
   
      type_handle#(longint unsigned)::get():
	begin
	  cl_opt_int_desc#(longint unsigned, longint_unsigned_traits) opt = new(name);
	  return opt;
	end
   
      default:
	begin
	  string msg;
	  $sformat(msg, "Type %s is not supported by the command line parser",
		   th.get_typename());
	  `uvm_error(SVX_CL_MSG_ID, msg)
	  return null;
	end
      
    endcase

    // We should never get here, but this makes the compiler happy
    return null;
    
  endfunction

endclass
/* verilator lint_on SIDEEFFECT */

//----------------------------------------------------------------------
// cl
//
// User interface for configuring the command line parser. Add() and
// add_with_default() provide a means to tell the parser what command
// line options to look for, what their data types are, and whether or
// not they have a default value.
//----------------------------------------------------------------------
class cl #(type T=int);

  //--------------------------------------------------------------------
  // add
  //--------------------------------------------------------------------
  static function void add(string name,
			   string desc="",
			   string fmt="");

    cl_opt_desc_base opt;

    if(cl_mgr::has_been_parsed()) begin
      string msg;
      $sformat(msg, {"New options cannot be added after ",
		     "the command line has already been parsed. ",
		     "Option %s is ignored"}, name);
      `uvm_warning(SVX_CL_MSG_ID, msg)
      return;
    end

    opt = opt_factory::create(type_handle#(T)::get(), name);
    if(opt == null)
      return;
    
    if(fmt != "")
      opt.fmt = fmt;
    opt.desc = desc;
    
    void'(cl_mgr::add(name, opt));
    
  endfunction

  //--------------------------------------------------------------------
  // add_with_default
  //--------------------------------------------------------------------
  static function void add_with_default(string name, T def, 
					string desc="", 
					string fmt="");

    cl_opt_desc_base opt;
    cl_opt_desc#(T) opt_desc;
    type_container#(T) val;

    if(cl_mgr::has_been_parsed()) begin
      string msg;
      $sformat(msg, {"New options cannot be added after ",
		     "the command line has already been parsed. ",
		     "Option %s is ignored"}, name);
      `uvm_warning(SVX_CL_MSG_ID, msg)
      return;
    end

    opt = opt_factory::create(type_handle#(T)::get(), name);
    if(opt == null)
      return;    

    if(fmt != "")
      opt.fmt = fmt;
    opt.desc = desc;

    if(!$cast(opt_desc, opt)) begin
      string msg;
      $sformat(msg,
	       "Something went wrong in creating the descriptor for option %s", 
	       name);
      `uvm_error(SVX_CL_MSG_ID, msg)
      return;
    end

    val = new();
    val.set(def);
    val.set_default_fmt(opt.fmt);
    opt_desc.default_value = val;

    // Add the option into the table and put the default value into
    // the resource database.
    if(cl_mgr::add(name, opt))
      uvm_resource_db#(T)::set("CL::*", name, def, null);
    
  endfunction

endclass
