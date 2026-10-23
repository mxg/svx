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

  //--------------------------------------------------------------------
  // f
  //
  // Primary function for functor-like class.  Its job is to parse a
  // single command line opotion.
  //--------------------------------------------------------------------
  virtual function void f(string opt, ref opt_vector_t opt_list);
    token_t token;
    token_descriptor td;
    string lexeme;
    cl_opt_instance opt_inst;
    lexer_core lex = new();

    lex.start(opt);
    // Valid options start with '+'.
    token = lex.get_token();
    // Uncomment the following statement for debugging the command
    // line parser.
    if(token != TOKEN_PLUS)
      return;

    // Get the option name
    token = lex.get_token();
    if(token != TOKEN_ID) begin
      string msg = {"Invalid command line option: ", opt};
      `error_msg("INVALID OPT", msg);
      return;
    end

    // Skip UVM options.
    lexeme = lex.get_lexeme();
    if(lexeme.substr(0,3) == "UVM_" || lexeme.substr(0,3) == "uvm_")
      return;

    // Create the option descriptor and begin populating it.  Add it
    // to the option list.
    opt_inst = new();
    opt_inst.name = lexeme;
    opt_list.appendc(opt_inst);

    // The value of an option is separated from the name with an '='.
    token = lex.get_token();

    // Get the value

    // If the form of the option is +<name> and NOT +<name>=<value>
    // then the option is a switch. Supplying the switch on the
    // comnmand line without a value means the switch is being turned
    // on.
    if(token != TOKEN_EQUAL) begin
      lex.put_token(lex.get_lexeme());
      opt_inst.token = TOKEN_ON;
      opt_inst.lexeme = "ON";
    end
    else begin
      // Option has the form +<name>=<value>
      token = lex.get_token();
      opt_inst.token = token;
      opt_inst.lexeme = lex.get_lexeme();
    end
    td = lex.get_token_descriptor();
    opt_inst.td = td;
  endfunction

endclass

//----------------------------------------------------------------------
// validate_int
//
// Validate integer types -- helper class for validate_opt.  For
// internal use. Not to be instantiated.
//----------------------------------------------------------------------
class validate_int#(type T=int);
  
  static function bit validate(cl_opt_desc opt, cl_opt_instance inst);

    bit err;
    type_container#(T) val = new();
    token_descriptor td = inst.td;
    T n;
    
    if(inst.token != TOKEN_INT) begin
      err = 1;
      `error_msg("INVALID VALUE", "Invalid command line option value");
    end
    if(td.size > $bits(T)) begin
      err = 1;    
      `error_msg("INVALID SIZE", "Invalid size of command line option value");
    end

/* verilator lint_off CASEINCOMPLETE */
    case(td.base)
      "d": n = T'(td.digits.atoi());
      "b": n = T'(td.digits.atobin());
      "o": n = T'(td.digits.atooct());
      "h": n = T'(td.digits.atohex());
    endcase  
/* verilator lint_on CASEINCOMPLETE */
    
    if(td.sign == "-")
      n = n * -1;    
    val.set(n);
    inst.value = val;

    return err;
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
class validate_opt extends fcn#(cl_opt_instance);

  function void f(cl_opt_instance t);

    bit err;
    token_descriptor td = t.td;
    
    // Look up the command line option
    cl_opt_desc opt = cl_mgr::find(t.name);
    // Transfer the fmt from the option descriptor to the option
    // instance.
    t.fmt = opt.fmt;

    // Is it a valid option?
    if(opt == cl_opt_traits::empty) begin
      `error_msg("INVALID OPT", {"Invalid command line option: ", t.name});
    end

    err = 0;
    case(opt.th)
      type_handle#(byte)::get():
	err = validate_int#(byte)::validate(opt, t);
      
      type_handle#(byte unsigned)::get():
	err = validate_int#(byte)::validate(opt, t);
      
      type_handle#(shortint)::get():
	err = validate_int#(shortint)::validate(opt, t);
      
      type_handle#(shortint unsigned)::get():
	err = validate_int#(shortint unsigned)::validate(opt, t);
      
      type_handle#(int)::get():
	err = validate_int#(int)::validate(opt, t);
      
      type_handle#(int unsigned)::get():
	err = validate_int#(int unsigned)::validate(opt, t);
      
      type_handle#(longint)::get():
	err = validate_int#(longint)::validate(opt, t);
      
      type_handle#(longint unsigned)::get():
	err = validate_int#(longint unsigned)::validate(opt, t);
      
      type_handle#(int8_t)::get():
	  err = validate_int#(int8_t)::validate(opt, t);

      type_handle#(int16_t)::get():
	  err = validate_int#(int16_t)::validate(opt, t);

      type_handle#(int32_t)::get():
	  err = validate_int#(int32_t)::validate(opt, t);

      type_handle#(int64_t)::get():
	  err = validate_int#(int64_t)::validate(opt, t);
      
      type_handle#(uint8_t)::get():
	  err = validate_int#(uint8_t)::validate(opt, t);

      type_handle#(uint16_t)::get():
	  err = validate_int#(uint16_t)::validate(opt, t);

      type_handle#(uint32_t)::get():
	  err = validate_int#(uint32_t)::validate(opt, t);

      type_handle#(uint64_t)::get():
	  err = validate_int#(uint64_t)::validate(opt, t);
      
      type_handle#(real)::get():
	begin
	  if(t.token != TOKEN_FLOAT)
	    err = 1;
	  else begin
	    type_container#(real) val = new();
	    real f = td.digits.atoreal();
	    if(td.sign == "-")
	      f = f * -1.0;
	    val.set(f);
	    t.value = val;
	  end
	end
  
      type_handle#(bit)::get():
	begin
	  bit b;
	  if(t.token != TOKEN_ON && t.token != TOKEN_OFF &&
	     t.token != TOKEN_INT && t.lexeme != null)
	    err = 1;
	  else begin
	    type_container#(bit) val = new();
	    if(t.token == TOKEN_ON || t.lexeme == null)
	      b = 1;
	    else
	      b = 0;
	    val.set(b);
	    t.value = val;
	  end
	end
      
      type_handle#(string)::get():
	begin
	  if(t.token != TOKEN_STRING && t.token != TOKEN_ID)
	    err = 1;
	  else begin
	    type_container#(string) val = new();
	    val.set(t.lexeme);
	    t.value = val;
	  end
	end
      
    endcase

    if(err) begin
      string msg = $sformatf("Invalid argument for command line option: +%s%s",
			     t.name, ((t.lexeme == null) ? "" : {" = ", t.lexeme}));
      `error_msg("INVALID ARGUMENT", msg);
    end
    
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
	    `error_msg("CAST", {"Cannot cast command line option to bit for ", t.name});
	  uvm_resource_db#(bit)::set_override("CL::*", t.name, value.get());
	end

      // string
      type_handle#(string)::get():
	begin
	  type_container#(string) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to string for ", t.name});
	  uvm_resource_db#(string)::set_override("CL::*", t.name, value.get());
	end

      // int8_t
      type_handle#(int8_t)::get():
	begin
	  type_container#(int8_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to int8_t for ", t.name});
	  uvm_resource_db#(int8_t)::set_override("CL::*", t.name, value.get());
	end

      // int16_t
      type_handle#(int16_t)::get():
	begin
	  type_container#(int16_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to int16_t for ", t.name});
	  uvm_resource_db#(int16_t)::set_override("CL::*", t.name, value.get());
	end

      // int32_t
      type_handle#(int32_t)::get():
	begin
	  type_container#(int32_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to int32_t for ", t.name});
	  uvm_resource_db#(int32_t)::set_override("CL::*", t.name, value.get());
	end

      // int64_t
      type_handle#(int64_t)::get():
	begin
	  type_container#(int64_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to int64_t for ", t.name});
	  uvm_resource_db#(int64_t)::set_override("CL::*", t.name, value.get());
	end

     // uint8_t
      type_handle#(uint8_t)::get():
	begin
	  type_container#(uint8_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to uint8_t for ", t.name});
	  uvm_resource_db#(uint8_t)::set_override("CL::*", t.name, value.get());
	end

      // uint16_t
      type_handle#(uint16_t)::get():
	begin
	  type_container#(uint16_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to uint16_t for ", t.name});
	  uvm_resource_db#(uint16_t)::set_override("CL::*", t.name, value.get());
	end

      // uint32_t
      type_handle#(uint32_t)::get():
	begin
	  type_container#(uint32_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to uint32_t for ", t.name});
	  uvm_resource_db#(uint32_t)::set_override("CL::*", t.name, value.get());
	end

      // uint64_t
      type_handle#(uint64_t)::get():
	begin
	  type_container#(uint64_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to uint64_t for ", t.name});
	  uvm_resource_db#(uint64_t)::set_override("CL::*", t.name, value.get());
	end
      
      // real
      type_handle#(real)::get():
	begin
	  type_container#(real) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to real for ", t.name});
	  uvm_resource_db#(real)::set_override("CL::*", t.name, value.get());
	end

      default:
	`error_msg("UNSUPPORTED TYPE", "Cannot convert command line option value");

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

    //------------------------------------------------------------------
    // Second pass. Validate the options.

    opt_iter = new(opt_vec);
    validate = new();
    algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_iter, validate);

    //------------------------------------------------------------------
    // Third pass. Populate values into the resource database

    populate = new();
    algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_iter, populate);

    // Print the list of options
    $display("\n--- Parsed Command Line Options  ---");
    print = new();
    algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_iter, print);
    $display("--- END Parsed Command Line Options  ---");

  endfunction

endclass
