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

typedef multimap#(string, cl_opt_instance, cl_opt_inst_traits) opt_map_t;
typedef multimap_iterator#(string, cl_opt_instance, cl_opt_inst_traits) opt_map_iter_t;
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
    if(token != TOKEN_EQUAL) begin
      lex.put_token(lex.get_lexeme());
      opt_inst.token = TOKEN_ON;
      opt_inst.lexeme = "ON";
    end
    else begin
      token = lex.get_token();
      opt_inst.token = token;
      opt_inst.lexeme = lex.get_lexeme();
      td = lex.get_token_descriptor();
    end
    setval(opt_inst, td);
  endfunction

  //--------------------------------------------------------------------
  // setval
  //
  // Conver the parsed value into an internal value suitable for using
  // in computations. Regine the information in cl_opt_instance using
  // information from the token_descriptor, Cl_opt_instance objects
  // are kept around for fiurther processing, token_descriptors are
  // discarded.
  //
  // The straight-line code in this function is straightfoward, but
  // the code is a bit unwieldy.  Perhaps we can find a more compact
  // way to do the same thing.
  //--------------------------------------------------------------------
  function void setval(cl_opt_instance opt_inst, token_descriptor token_desc);

/* verilator lint_off CASEINCOMPLETE */    
    case(opt_inst.token)
      TOKEN_ID:
	begin
	  val_string val = new();
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
		val_int8 val = new();
		int8_t n;
		case(token_desc.base)
		  "d":
		    begin
		      n = int8_t'(token_desc.digits.atoi());
		      val.set_default_fmt("%0d");
		    end
		  "b":
		    begin
		      n = int8_t'(token_desc.digits.atobin());
		      val.set_default_fmt("b%08b");
		    end
		  "o":
		    begin
		      n = int8_t'(token_desc.digits.atooct());
		      val.set_default_fmt("o%03o");
		    end
		  "h":
		    begin
		      n = int8_t'(token_desc.digits.atohex());
		      val.set_default_fmt("h%02x");
		    end
		endcase
		if(token_desc.sign == "-")
		  n = n * -1;
		val.set(n);
		opt_inst.value = val;
	      end

	    // 16-bit integers
	    size > 8 && size <= 16:
              begin
		val_int16 val = new();
		int16_t n;
		case(token_desc.base)
		  "d":
		    begin
		      n = int16_t'(token_desc.digits.atoi());
		      val.set_default_fmt("%0d");
		    end
		  "b":
		    begin
		      n = int16_t'(token_desc.digits.atobin());
		      val.set_default_fmt("b%016b");
		    end
		  "o": 
		    begin
		      n = int16_t'(token_desc.digits.atooct());
		      val.set_default_fmt("o%06o");
		    end
		  "h": 
		    begin
		      n = int16_t'(token_desc.digits.atohex());
		      val.set_default_fmt("h%04x");
		    end
		endcase
		if(token_desc.sign == "-")
		  n = n * -1;
		val.set(n);
		opt_inst.value = val;
	      end

	    // 32-bit integers
	    size > 16 && size <= 32:
              begin
		val_int32 val = new();
		int32_t n;
		case(token_desc.base)
		  "d": 
		    begin
		      n = token_desc.digits.atoi();
		      val.set_default_fmt("%0d");
		    end
		  "b":
		    begin
		      n = token_desc.digits.atobin();
		      val.set_default_fmt("b%032b");
		    end
		  "o":
		    begin
		      n = token_desc.digits.atooct();
		      val.set_default_fmt("o%012o");
		    end
		  "h": 
		    begin
		      n = token_desc.digits.atohex();
		      val.set_default_fmt("h%08x");
		    end
		endcase
		if(token_desc.sign == "-")
		  n = n * -1;
		val.set(n);
		opt_inst.value = val;
	      end

	    // 64-bit integer
	    size > 32 && size <= 64:
	      begin
		val_int64 val = new();
		int64_t n;
		case(token_desc.base)
		  "d":
		    begin
		      n = int64_t'(token_desc.digits.atoi());
		      val.set_default_fmt("%0d");
		    end
		  "b":
		    begin
		      n = int64_t'(token_desc.digits.atobin());
		      val.set_default_fmt("b%064b");
		    end
		  "o": 
		    begin
		      n = int64_t'(token_desc.digits.atooct());
		      val.set_default_fmt("o%024o");
		    end
		  "h":
		    begin
		      n = int64_t'(token_desc.digits.atohex());
		      val.set_default_fmt("h%016x");
		    end
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
	
	end
      
      TOKEN_FLOAT:
	begin
	  val_real val = new();
	  real f = token_desc.digits.atoreal();
	  if(token_desc.sign == "-")
	    f = f * -1.0;
	  val.set(f);
	  opt_inst.value = val;
	end
      
      TOKEN_STRING:
	begin
	  val_string val = new();
	  val.set(opt_inst.lexeme);
	  opt_inst.value = val;
	end
      
      default:
	begin
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
class validate_opt extends fcn#(cl_opt_instance);

  function void f(cl_opt_instance t);

    bit err;
    
    // Look up the command line option
    cl_opt_desc opt = cl_mgr::find(t.name);

    // Is it a valid option?
    if(opt == cl_opt_traits::empty) begin
      `error_msg("INVALID OPT", {"Invalid command line option: ", t.name});
    end

    err = 0;
    case(opt.arg_type)
      ARG_INT:
	begin
	  if(t.token != TOKEN_INT)
	    err = 1;
	end
      
      ARG_FLOAT:
	begin
	  if(t.token != TOKEN_FLOAT)
	    err = 1;
	end
  
      ARG_LOGIC:
	begin
	   if(t.token != TOKEN_LOGIC)
	     err = 1;
	end
      
      ARG_SWITCH:
	begin
	  if(t.token != TOKEN_ON && t.token != TOKEN_OFF &&
	     t.token != TOKEN_INT && t.lexeme != null)
	    err = 1;
	end
      
      ARG_TIME:
	begin
	  if(t.token != TOKEN_TIME)
	    err = 1;
	end
      
      ARG_NUM:
	begin
	  if(t.token != TOKEN_INT || t.token != TOKEN_FLOAT)
	    err = 1;
	end
      
      ARG_STRING:
	begin
	  if(t.token != TOKEN_STRING)
	    err = 1;
	end
      
      ARG_ID:
	begin
	  if(t.token != TOKEN_ID)
	    err = 1;
	end       
    endcase

    if(err) begin
      string msg = $sformatf("Invalid argument for command line option: +%s%s",
			     t.name, ((t.lexeme == null) ? "" : {" = ", t.lexeme}));
      `error_msg("INVALID ARGUMENT", msg);
    end
    
  endfunction
  
endclass

//----------------------------------------------------------------------
// map_opt
//
// Put an cl_opt_instance into the multimap
//----------------------------------------------------------------------
class map_opt extends accum_fcn#(cl_opt_instance, opt_map_t);
  virtual function void f(cl_opt_instance opt, ref opt_map_t map);
    map.insert(opt.name, opt);
  endfunction
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
    
    vector_string vec;
    list_string_iterator iter;
    parse_opt parse;
    opt_vector_t opt_vec;
    
    opt_iterator_t opt_iter;
    print_opt print;

    opt_map_t opt_map;
    map_opt putmap;
    opt_map_iter_t opt_map_iter;

    validate_opt validate;

    //------------------------------------------------------------------
    // First pass.  Pull apart each option and put the result into a
    // list; The vector preserves the order the options appear on the
    // command line.
    
    vec = get_args();  // Retrieve raw args from the command line.
    iter = new(vec);   // Vector of raw args.
    parse = new();     // Parser function obj
    opt_vec = new();   // Vector of parsed arguments
    accum#(string, string_traits, opt_vector_t)::accumulate(iter, parse, opt_vec);

    // Save these lines for debugging.  They traverse the vector of
    // option instances to print each one.
    opt_iter = new(opt_vec);
    print = new();
    // $display("--> pass 1: parse");
    // algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_iter, print);

    //------------------------------------------------------------------
    // Second pass. Validate the options.
    
    validate = new();
    //$display("\n--> pass 2: validate");
    algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_iter, validate);

    //------------------------------------------------------------------
    // Third pass. Put all the parsed args into a multimap.  The map
    // does not preserve overall order of command line options, but it
    // does preserve the order of appearance of options with the same
    // name.  The multimap is searchable.
    
    opt_map = new();
    putmap = new();
    opt_map_iter = new(opt_map);
    accum#(cl_opt_instance, cl_opt_inst_traits, opt_map_t)::accumulate(opt_iter,
								       putmap,
								       opt_map);

    // Save these lines for debugging.  They print the parsed and
    // validated args from the multimap.
    //$display("\n--> pass 3: map");
    algo#(cl_opt_instance, cl_opt_inst_traits)::for_each(opt_map_iter, print);

  endfunction

endclass
