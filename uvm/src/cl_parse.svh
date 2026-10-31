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
// parse_opt
//
// An accumulator function class for parsing an option.  Take apart a
// single option and create an instance object (cl_opt_instance).  Put
// the instance into the vector.
//----------------------------------------------------------------------
class parse_opt extends accum_fcn#(string, opt_vector_t);

  bit has_errors;

  //--------------------------------------------------------------------
  // f
  //
  // Primary function for functor-like class.  Its job is to parse a
  // single command line option.
  //--------------------------------------------------------------------
  virtual function void f(string opt, ref opt_vector_t opt_list);
    token_t token;
    token_descriptor td;
    string lexeme;
    cl_opt_instance opt_inst;
    cl_opt_desc opt_desc;
    lexer_core lex = new();

    lex.start(opt);
    // Valid options start with '+'.
    token = lex.get_token();
    if(token != TOKEN_PLUS)
      return;

    // Get the option name
    token = lex.get_token();
    if(token != TOKEN_ID) begin
      string msg = {"Invalid command line option: ", opt};
      `uvm_error("SVX/CL/PARSE", msg)
      has_errors = 1;
      return;
    end

    // Skip UVM options.
    lexeme = lex.get_lexeme();
    if(lexeme.substr(0,3) == "UVM_" || lexeme.substr(0,3) == "uvm_")
      return;

    // Skip unknown options
    opt_desc = cl_mgr::find(lex.get_lexeme());
    if(opt_desc == cl_opt_traits::empty) begin
      string msg = {"Skipping unknown command line option: ", lex.get_lexeme()};
      `uvm_info("SVX/CL/PARSE", msg, UVM_NONE)
      return;
    end

    // Create the option descriptor and begin populating it.  Add it
    // to the option list.
    opt_inst = new();
    opt_inst.name = lexeme;
    opt_list.appendc(opt_inst);

    // Get the value

    // If the form of the option is +<name> and NOT +<name>=<value>
    // then the option is a switch. Supplying the switch on the
    // command line without a value means the switch is being turned
    // on.
    token = lex.get_token();
    if(token != TOKEN_EQUAL) begin
      if(opt_desc.th != type_handle#(bit)::get()) begin
	  string msg;
	  $sformat(msg, "Missing value for command line option +%s", opt_inst.name);
	  `uvm_error("SVX/CL/PARSE", msg)
	  has_errors = 1;
	  return;
	end

      // No value means the command line option is a switch.
      opt_inst.token = TOKEN_ON;
      opt_inst.lexeme = "ON";

      check_for_extra_chars(lex, opt_inst.name);
      return;
    end

    // Option has the form +<name>=<value>
    // Get the value token after the equal sign
    // Are we looking for a filename?
    if(opt_desc.th == type_handle#(string)::get())
      token = lex.lex_filename();
    else
      token = lex.get_token();

    if(token == TOKEN_ERROR) begin
      string msg;
      $sformat(msg, "Parsing error at command line option +%s", opt_inst.name);
      `uvm_error("SVX/CL/PARSE", msg)
      has_errors = 1;
      return;
    end

    if(token == TOKEN_EOL) begin
      // Oops -- the value token is missing
      string msg;
      $sformat(msg, "Missing value for command line option +%s", opt_inst.name);
      `uvm_error("SVX/CL/PARSE", msg)
      has_errors = 1;
      return;
    end

    // Collect up some information from the lexer
    opt_inst.token = token;
    opt_inst.lexeme = lex.get_lexeme();
    td = lex.get_token_descriptor();
    opt_inst.td = td;

    check_for_extra_chars(lex, opt_inst.name);
  endfunction

  //--------------------------------------------------------------------
  // check_for_exrtra_chars
  //
  // Like the name says...
  //--------------------------------------------------------------------  
  function void check_for_extra_chars(lexer_core lex, string name);

    token_t token;
    string msg;

    token = lex.get_token();
    if(token == TOKEN_EOL)
      return;
    
    $sformat(msg, "Extraneous characters after value for command line option +%s",
	     name);
    `uvm_error("SVX/CL/PARSE", msg)
    has_errors = 1;
  endfunction

endclass

//----------------------------------------------------------------------
// validate_int
//
// Validate integer types -- helper class for validate_opt.  Returns 0
// if the validation fails, 1 otherwise.
//
// For internal use. Not to be instantiated.
//----------------------------------------------------------------------
class validate_int#(type T=int, type P=void_traits);
  
  static function bit validate(cl_opt_desc opt, cl_opt_instance inst);

    const uint32_t W = $bits(T);
    type_container#(T) val = new();
    token_descriptor td = inst.td;
    T n;
    string msg;
    bit [127:0]	mag, limit;  
    integer	err;  

    // Is the argument an integer?
    if(inst.token != TOKEN_INT) begin
      $sformat(msg, "Invalid command line option value for +%s = %s. Expected %s integer",
	       opt.name, inst.lexeme,
	       (P::is_signed) ? "a signed" : "an unsigned");
      `uvm_error("SVX/CL/PARSE", msg)
      return 0;
    end

    // Does the argument fit into the data type?
    if(td.size > W) begin
      $sformat(msg,
	       {"Invalid size of the value for command line option +%s. ",
		"Value must be an integer less than %0d bits"},
	       opt.name, $bits(T));
      `uvm_error("SVX/CL/PARSE", msg)
      return 0;
    end

    err = 1;
    case(td.base)
      "d", "D": err = $sscanf(td.digits, "%d", mag);
      "b", "B": err = $sscanf(td.digits, "%b", mag);
      "o", "O": err = $sscanf(td.digits, "%o", mag);
      "h", "H": err = $sscanf(td.digits, "%h", mag);
      default:
	begin
	  $sformat(msg, "Value of option +%s has an invalid base %s", opt.name, td.base);
	  `uvm_error("SVX/CL/PARSE", msg)
	  return 0;
	end
    endcase

    if(err == 0) begin
      $sformat(msg, "Invalid numerical argument for +%s = %s", 
	       inst.name, inst.lexeme);
      `uvm_error("SVX/CL/PARSE", msg)
      return 0;
    end

    // Note: We only support a max of 64-bit arguments.  So 128 bits
    // is large enough to see if the conversion fits.
    if (P::is_signed == true)
      limit = (128'(1) << (W-1)) - (td.sign == "-" ? 0 : 1);
    else
      limit = (128'(1) << W) - 1;
    if (mag > limit) begin
      $sformat(msg, {"Argument for command line option +%s ",
		     "does not fit into the data type for this option"}, 
	       opt.name);
      `uvm_error("SVX/CL/PARSE", msg)
      return 0;
    end

    // Check the sign
    if(P::is_unsigned == true && td.sign == "-") begin
      $sformat(msg, {"Command line option +%s is unsigned ",
		     "so it cannot have a negative value"}, 
	       opt.name);
      `uvm_error("SVX/CL/PARSE", msg)
      return 0;
    end

    n = T'(mag);
    if(td.sign == "-")
      n = n * -1;    
    val.set(n);
    inst.value = val;

    return 1;
  endfunction
  
endclass

//----------------------------------------------------------------------
// validate_opt
//
// Is a command line option valid?  Validate against the table of
// valid command line options.  Convert lexeme into an internal
// representation.
//----------------------------------------------------------------------
/* verilator lint_off SIDEEFFECT */
// Dear Verilator team, What does "Expression side effect may be
// mishandled" mean?
class validate_opt extends accum_fcn#(cl_opt_instance, uint32_t);

  function void f(cl_opt_instance t, ref uint32_t errs);

    string msg;
    token_descriptor td = t.td;
    
    // Look up the command line option
    cl_opt_desc opt = cl_mgr::find(t.name);
    // Is it a valid option?
    if(opt == cl_opt_traits::empty) begin
      `uvm_info("SVX/CL/PARSE",
		{"skipping invalid command line option: ", t.name}, UVM_NONE)
      return;
    end

    // Transfer the fmt from the option descriptor to the option
    // instance.
    t.fmt = opt.fmt;

    case(opt.th)
      type_handle#(byte)::get():
	if(!validate_int#(byte, byte_traits)::validate(opt, t))
	  errs++;
      
      type_handle#(byte unsigned)::get():
	if(!validate_int#(byte unsigned, byte_unsigned_traits)::validate(opt, t))
	  errs++;
      
      type_handle#(shortint)::get():
	if(!validate_int#(shortint, shortint_traits)::validate(opt, t))
	  errs++;
      
      type_handle#(shortint unsigned)::get():
	if(!validate_int#(shortint unsigned, shortint_unsigned_traits)::validate(opt, t))
	  errs++;
      
      type_handle#(int)::get():
	if(!validate_int#(int, int_traits)::validate(opt, t))
	  errs++;
      
      type_handle#(int unsigned)::get():
	if(!validate_int#(int unsigned, int_unsigned_traits)::validate(opt, t))
	  errs++;
      
      type_handle#(longint)::get():
	if(!validate_int#(longint, longint_traits)::validate(opt, t))
	  errs++;
      
      type_handle#(longint unsigned)::get():
	if(!validate_int#(longint unsigned, longint_unsigned_traits)::validate(opt, t))
	  errs++;
      
      type_handle#(int8_t)::get():
	  if(!validate_int#(int8_t, int8_traits)::validate(opt, t))
	    errs++;

      type_handle#(int16_t)::get():
	  if(!validate_int#(int16_t, int16_traits)::validate(opt, t))
	    errs++;

      type_handle#(int32_t)::get():
	  if(!validate_int#(int32_t, int32_traits)::validate(opt, t))
	    errs++;

      type_handle#(int64_t)::get():
	  if(!validate_int#(int64_t, int64_traits)::validate(opt, t))
	    errs++;
      
      type_handle#(uint8_t)::get():
	  if(!validate_int#(uint8_t, uint8_traits)::validate(opt, t))
	    errs++;

      type_handle#(uint16_t)::get():
	  if(!validate_int#(uint16_t, uint16_traits)::validate(opt, t))
	    errs++;

      type_handle#(uint32_t)::get():
	  if(!validate_int#(uint32_t, uint32_traits)::validate(opt, t))
	    errs++;

      type_handle#(uint64_t)::get():
	  if(!validate_int#(uint64_t, uint64_traits)::validate(opt, t))
	    errs++;
      
      type_handle#(real)::get():
	begin
	  case(t.token)
	    TOKEN_FLOAT:
	      begin
		type_container#(real) val = new();
		real f = td.digits.atoreal();
		if(td.sign == "-")
		  f = -f;
		val.set(f);
		t.value = val;
	      end
	    TOKEN_INT:
	      begin
		type_container#(real) val = new();
		int64_t n;
		$sscanf(td.digits, "%d", n); // assume decimal
		if(td.sign == "-")
		  n = -n;
		val.set($itor(n));
		t.value = val;
	      end
	    default:
	      begin	      
		errs++;
		$sformat(msg, "Command line option +%s must have a floating point value.",
			 opt.name);
		`uvm_error("SVX/CL/PARSE", msg)
	      end
	  endcase
	end
  
      type_handle#(bit)::get():
	begin
	  bit b;
	  type_container#(bit) val = new();

	  if(t.token == TOKEN_ON ||
	     (t.token == TOKEN_INT && (t.lexeme.atoi() == 1)))
	    b = 1;
	  else
	    if(t.token == TOKEN_OFF ||
	     (t.token == TOKEN_INT && (t.lexeme.atoi() == 0)))
	      b = 0;
	  else begin
	    errs++;
	    $sformat(msg, "Command line option +%s must have an ON/OFF value.", opt.name);
	    `uvm_error("SVX/CL/PARSE", msg)
	    return;
	  end

	  val.set(b);
	  t.value = val;
	end
      
      type_handle#(string)::get():
	begin
	  if(t.token != TOKEN_STRING && t.token != TOKEN_ID) begin
	    errs++;
	    $sformat(msg, "Command line option +%s must have a string value.", opt.name);
	    `uvm_error("SVX/CL/PARSE", msg)
	  end
	  else begin
	    type_container#(string) val = new();
	    val.set(t.lexeme);
	    t.value = val;
	  end
	end
      
    endcase

  endfunction
/* verilator lint_on SIDEEFFECT */
  
endclass

//----------------------------------------------------------------------
// populate_resource_db
//
// A function class that puts each command line option into the
// resource database.
//----------------------------------------------------------------------
/* verilator lint_off SIDEEFFECT */
// Dear Verilator team: What the heck is "Mishandling of a side
// effect?"
class populate_resource_db extends fcn#(cl_opt_instance);

  function void f(cl_opt_instance t);

    case(t.value.get_type_handle())
      
      // bit
      type_handle#(bit)::get():
	begin
	  type_container#(bit) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to bit for ", t.name})
	  uvm_resource_db#(bit)::set_override("CL::*", t.name, value.get());
	end

      // string
      type_handle#(string)::get():
	begin
	  type_container#(string) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to string for ", t.name})
	  uvm_resource_db#(string)::set_override("CL::*", t.name, value.get());
	end

      // int8_t
      type_handle#(int8_t)::get():
	begin
	  type_container#(int8_t) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to int8_t for ", t.name})
	  uvm_resource_db#(int8_t)::set_override("CL::*", t.name, value.get());
	end

      // int16_t
      type_handle#(int16_t)::get():
	begin
	  type_container#(int16_t) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to int16_t for ", t.name})
	  uvm_resource_db#(int16_t)::set_override("CL::*", t.name, value.get());
	end

      // int32_t
      type_handle#(int32_t)::get():
	begin
	  type_container#(int32_t) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to int32_t for ", t.name})
	  uvm_resource_db#(int32_t)::set_override("CL::*", t.name, value.get());
	end

      // int64_t
      type_handle#(int64_t)::get():
	begin
	  type_container#(int64_t) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to int64_t for ", t.name})
	  uvm_resource_db#(int64_t)::set_override("CL::*", t.name, value.get());
	end

     // uint8_t
      type_handle#(uint8_t)::get():
	begin
	  type_container#(uint8_t) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE", 
		       {"Cannot cast command line option to uint8_t for ", t.name})
	  uvm_resource_db#(uint8_t)::set_override("CL::*", t.name, value.get());
	end

      // uint16_t
      type_handle#(uint16_t)::get():
	begin
	  type_container#(uint16_t) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to uint16_t for ", t.name})
	  uvm_resource_db#(uint16_t)::set_override("CL::*", t.name, value.get());
	end

      // uint32_t
      type_handle#(uint32_t)::get():
	begin
	  type_container#(uint32_t) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to uint32_t for ", t.name})
	  uvm_resource_db#(uint32_t)::set_override("CL::*", t.name, value.get());
	end

      // uint64_t
      type_handle#(uint64_t)::get():
	begin
	  type_container#(uint64_t) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to uint64_t for ", t.name})
	  uvm_resource_db#(uint64_t)::set_override("CL::*", t.name, value.get());
	end
      
      // real
      type_handle#(real)::get():
	begin
	  type_container#(real) value;
	  if(!$cast(value, t.value))
	    `uvm_error("SVX/CL/PARSE",
		       {"Cannot cast command line option to real for ", t.name})
	  uvm_resource_db#(real)::set_override("CL::*", t.name, value.get());
	end

      default:
	`uvm_error("SVX/CL/PARSE", "Unsupported type: cannot convert command line option value")
    endcase
    
  endfunction
/* verilator lint_on SIDEEFFECT */

endclass

//----------------------------------------------------------------------
// cl_parse
//
// Parse the command line args
//----------------------------------------------------------------------
class cl_parse;

  local uvm_cmdline_processor clp;

  function new();
    clp = new();
  endfunction

  //--------------------------------------------------------------------
  // get_args
  //
  // Retrieve the command line args via the UVM command line
  // processor.
  //--------------------------------------------------------------------
  local function vector_string get_args();
    string args[$];
    vector_string vec;
    
    clp.get_args(args);
    vec = vector_string::create(args);
    return vec;
  endfunction

  //--------------------------------------------------------------------
  // parse
  //
  // Drive the command line parsing process.
  //--------------------------------------------------------------------
  function void parse();

    uint32_t errs;

    // Vectors    
    vector_string vec;    // List of raw option strings
    opt_vector_t opt_vec; // List of option instances

    // Iterators
    list_string_iterator iter;
    opt_iterator_t opt_iter;

    // Function classes
    parse_opt parse;
    print_opt print;
    validate_opt validate;
    populate_resource_db populate;

    //------------------------------------------------------------------
    // First pass.  Pull apart each option and put the result into a
    // list; The vector preserves the order the options appear on the
    // command line.
    
    vec = get_args();  // Retrieve raw args from the command line.
    iter = new(vec);   // Vector of raw args.
    parse = new();     // Parser function obj
    opt_vec = new();   // Vector of parsed arguments
    accum#(string, string_traits, opt_vector_t)::accumulate(iter, parse, opt_vec);

    if(parse.has_errors) begin
      `uvm_error("SVX/CL/PARSE",
		 "Errors in the command line prevent further processing of the options")
      return;
    end
    
    //------------------------------------------------------------------
    // Second pass. Validate the options.

    errs = 0;
    opt_iter = new(opt_vec);
    validate = new();
    accum#(cl_opt_instance, cl_opt_inst_traits, uint32_t)::accumulate(opt_iter, 
								      validate, 
								      errs);

    //------------------------------------------------------------------
    // Third pass. Populate values into the resource database

    if(errs > 0) begin
      `uvm_error("SVX/CL/PARSE",
		 "Errors in the command line prevent further processing of the options")
      return;
    end

    populate = new();
    algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_iter, populate);

    // Print the list of options
    $display("\n--- Parsed Command Line Options  ---");
    print = new();
    algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_iter, print);
    $display("--- END Parsed Command Line Options  ---");

  endfunction

endclass
