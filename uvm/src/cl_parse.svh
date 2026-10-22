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
    setval(opt_inst, td);
  endfunction

  //--------------------------------------------------------------------
  // setval
  //
  // Convert the parsed value into an internal value suitable for
  // using in computations. Refine the information in cl_opt_instance
  // using information from the token_descriptor, Cl_opt_instance
  // objects are kept around for fiurther processing,
  // token_descriptors are discarded.
  //
  // The straight-line code in this function is straightfoward, but
  // the code is a bit unwieldy.  Perhaps we can find a more compact
  // way to do the same thing.
  //--------------------------------------------------------------------
  function void setval(cl_opt_instance opt_inst, token_descriptor token_desc);

/* verilator lint_off CASEINCOMPLETE */    
    case(opt_inst.token)

      TOKEN_OFF:
	begin
	  type_container#(bit) val = new();
	  val.set(0);
	  opt_inst.value = val;
	end

      TOKEN_ON:
	begin
	  type_container#(bit) val = new();
	  val.set(1);
	  opt_inst.value = val;
	end
      
      TOKEN_ID:
	begin
	  type_container#(string) val = new();
	  val.set(opt_inst.lexeme);
	  opt_inst.value = val;
	end
      
      TOKEN_INT:
	begin
	  uint32_t size = token_desc.size;
	  if(size == 0)
	    size = 32;
	  case(1)
	    // 8-bint integers
	    size <= 8:
	      begin
		type_container#(int8_t) val = new();
		int8_t n;
		case(token_desc.base)
		  "d": n = int8_t'(token_desc.digits.atoi());
		  "b": n = int8_t'(token_desc.digits.atobin());
		  "o": n = int8_t'(token_desc.digits.atooct());
		  "h": n = int8_t'(token_desc.digits.atohex());
		endcase
		if(token_desc.sign == "-")
		  n = n * -1;
		val.set(n);
		opt_inst.value = val;
	      end

	    // 16-bit integers
	    size > 8 && size <= 16:
              begin
		type_container#(int16_t) val = new();
		int16_t n;
		case(token_desc.base)
		  "d": n = int16_t'(token_desc.digits.atoi());
		  "b": n = int16_t'(token_desc.digits.atobin());
		  "o": n = int16_t'(token_desc.digits.atooct());
		  "h": n = int16_t'(token_desc.digits.atohex());
		endcase
		if(token_desc.sign == "-")
		  n = n * -1;
		val.set(n);
		opt_inst.value = val;
	      end

	    // 32-bit integers
	    size > 16 && size <= 32:
              begin
		type_container#(int32_t) val = new();
		int32_t n;
		case(token_desc.base)
		  "d": n = token_desc.digits.atoi();
		  "b": n = token_desc.digits.atobin();
		  "o": n = token_desc.digits.atooct();
		  "h": n = token_desc.digits.atohex();
		endcase
		if(token_desc.sign == "-")
		  n = n * -1;
		val.set(n);
		opt_inst.value = val;
	      end

	    // 64-bit integer
	    size > 32 && size <= 64:
	      begin
		type_container#(int64_t) val = new();
		int64_t n;
		case(token_desc.base)
		  "d": $sscanf(token_desc.digits, "%d", n);
		  "b": $sscanf(token_desc.digits, "%b", n);
		  "o": $sscanf(token_desc.digits, "%o", n);
		  "h": $sscanf(token_desc.digits, "%x", n);
		endcase
		if(token_desc.sign == "-")
		  n = n * -1;
		val.set(n);
		opt_inst.value = val;
	      end
	    default:
	      begin
	      end
	    
	  endcase
	
	end // TOKEN_INT
      
      TOKEN_FLOAT:
	begin
	  type_container#(real) val = new();
	  real f = token_desc.digits.atoreal();
	  if(token_desc.sign == "-")
	    f = f * -1.0;
	  val.set(f);
	  opt_inst.value = val;
	end
      
      TOKEN_STRING:
	begin
	  type_container#(string) val = new();
	  val.set(opt_inst.lexeme);
	  opt_inst.value = val;
	end
      
      default:
	begin
	  `warning_msg("UNSUPPORTED TYPE", 
		       {"Unsupported data tupe for command line option ", opt_inst.name});
	end
      
    endcase
    
/* verilator lint_on CASEINCOMPLETE */    
  endfunction

endclass

//----------------------------------------------------------------------
// validate_opt
//
// Is a command line option valid?  Validate against the table of
// valid command line options.
//----------------------------------------------------------------------
/* verilator lint_off SIDEEFFECT */
// Dear Verilator team, What does "Expression side effect may be
// mishandled" mean?
class validate_opt extends fcn#(cl_opt_instance);

  function void f(cl_opt_instance t);

    bit err;
    
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
      type_handle#(int8_t)::get(),
      type_handle#(int16_t)::get(),
      type_handle#(int32_t)::get(),
      type_handle#(int64_t)::get(),
      type_handle#(uint8_t)::get(),
      type_handle#(uint16_t)::get(),
      type_handle#(uint32_t)::get(),
      type_handle#(uint64_t)::get():
	begin
	  if(t.token != TOKEN_INT)
	    err = 1;
	end
      
      type_handle#(real)::get():
	begin
	  if(t.token != TOKEN_FLOAT)
	    err = 1;
	end
  
      type_handle#(logic)::get():
	begin
	   if(t.token != TOKEN_LOGIC)
	     err = 1;
	end
      
      type_handle#(bit)::get():
	begin
	  if(t.token != TOKEN_ON && t.token != TOKEN_OFF &&
	     t.token != TOKEN_INT && t.lexeme != null)
	    err = 1;
	end
      
      type_handle#(time)::get():
	begin
	  if(t.token != TOKEN_TIME)
	    err = 1;
	end
      
      type_handle#(string)::get():
	begin
	  if(t.token != TOKEN_STRING && t.token != TOKEN_ID)
	    err = 1;
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
	  uvm_resource_db#(bit)::set("CL::", t.name, value.get());
	end

      // string
      type_handle#(string)::get():
	begin
	  type_container#(string) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to string for ", t.name});
	  uvm_resource_db#(string)::set("CL::", t.name, value.get());
	end

      // int8_t
      type_handle#(int8_t)::get():
	begin
	  type_container#(int8_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to int8_t for ", t.name});
	  uvm_resource_db#(int8_t)::set("CL::", t.name, value.get());
	end

      // int16_t
      type_handle#(int16_t)::get():
	begin
	  type_container#(int16_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to int16_t for ", t.name});
	  uvm_resource_db#(int16_t)::set("CL::", t.name, value.get());
	end

      // int32_t
      type_handle#(int32_t)::get():
	begin
	  type_container#(int32_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to int32_t for ", t.name});
	  uvm_resource_db#(int32_t)::set("CL::", t.name, value.get());
	end

      // int64_t
      type_handle#(int64_t)::get():
	begin
	  type_container#(int64_t) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to int64_t for ", t.name});
	  uvm_resource_db#(int64_t)::set("CL::", t.name, value.get());
	end

      // real
      type_handle#(real)::get():
	begin
	  type_container#(real) value;
	  if(!$cast(value, t.value))
	    `error_msg("CAST", {"Cannot cast command line option to real for ", t.name});
	  uvm_resource_db#(real)::set("CL::", t.name, value.get());
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
    // Third pass. Populate values into the option instances.

    populate = new();
    algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_iter, populate);

    // Print the list of options
    $display("\n--- Parsed Command Line Options  ---");
    print = new();
    algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_iter, print);
    $display("--- END Parsed Command Line Options  ---");

  endfunction

endclass
