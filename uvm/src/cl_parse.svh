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
    cl_opt_instance_base opt_inst;
    cl_opt_desc_base opt_desc;
    lexer_core lex = new();
    string msg;

    lex.start(opt);
    // Valid options start with '+'.
    token = lex.get_token();
    if(token != TOKEN_PLUS)
      return;

    // Get the option name
    token = lex.get_token();
    if(token != TOKEN_ID) begin
      msg = {"Invalid command line option: ", opt};
      `uvm_error(SVX_CL_MSG_ID, msg)
      has_errors = 1;
      return;
    end

    // Skip UVM options.
    lexeme = lex.get_lexeme();
    if(lexeme.substr(0,3) == "UVM_" || lexeme.substr(0,3) == "uvm_")
      return;

    // Skip unknown options
    opt_desc = cl_mgr::find(lexeme);
    if(opt_desc == cl_opt_traits::empty) begin
      msg = {"Skipping unknown command line option: ", lex.get_lexeme()};
      `uvm_info("SVX/CL/PARSE", msg, UVM_NONE)
      return;
    end

    // Create the option descriptor and begin populating it.  Add it
    // to the option list.
    opt_inst = opt_desc.create_instance(lexeme);
    opt_list.appendc(opt_inst);

    // Get the value

    // If the form of the option is +<name> and NOT +<name>=<value>
    // then the option is a switch. Supplying the switch on the
    // command line without a value means the switch is being turned
    // on.
    token = lex.get_token();
    if(token != TOKEN_EQUAL) begin
      if(opt_desc.get_type_handle() != type_handle#(bit)::get()) begin
	  $sformat(msg, "Missing value for command line option +%s", opt_inst.get_name());
	  `uvm_error(SVX_CL_MSG_ID, msg)
	  has_errors = 1;
	  return;
      end

      // A switch must end right after its name.
      if(token != TOKEN_EOL) begin
	$sformat(msg, "Extraneous characters after command line option +%s", opt_inst.get_name());
	`uvm_error(SVX_CL_MSG_ID, msg)
	has_errors = 1;
	return;
      end

      // No value means the command line option is a switch.
      opt_inst.token = TOKEN_ON;
      opt_inst.lexeme = "ON";
      return;
      
    end

    // Option has the form +<name>=<value>
    // Get the value token after the equal sign
    // Are we looking for a filename?
    if(opt_desc.get_type_handle() == type_handle#(string)::get())
      token = lex.lex_filename();
    else
      token = lex.get_token();

    if(token == TOKEN_ERROR) begin
      $sformat(msg, "Parsing error at command line option +%s", opt_inst.get_name());
      `uvm_error(SVX_CL_MSG_ID, msg)
      has_errors = 1;
      return;
    end

    if(token == TOKEN_EOL) begin
      // Oops -- the value token is missing
      $sformat(msg, "Missing value for command line option +%s", opt_inst.get_name());
      `uvm_error(SVX_CL_MSG_ID, msg)
      has_errors = 1;
      return;
    end

    // Collect up some information from the lexer
    opt_inst.token = token;
    opt_inst.lexeme = lex.get_lexeme();
    td = lex.get_token_descriptor();
    opt_inst.td = td;

    check_for_extra_chars(lex, opt_inst.get_name());
  endfunction

  //--------------------------------------------------------------------
  // check_for_extra_chars
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
    `uvm_error(SVX_CL_MSG_ID, msg)
    has_errors = 1;
  endfunction

endclass

//----------------------------------------------------------------------
// validate_opt
//
// Is a command line option valid?  Validate against the table of
// valid command line options.  Convert lexeme into an internal
// representation.
//----------------------------------------------------------------------
class validate_opt extends accum_fcn#(cl_opt_instance_base, uint32_t);

  function void f(cl_opt_instance_base inst, ref uint32_t errs);

    string msg;
    token_descriptor td = inst.td;
    
    // Look up the command line option
    cl_opt_desc_base opt = cl_mgr::find(inst.get_name());
    // Is it a valid option?
    if(opt == cl_opt_traits::empty) begin
      `uvm_info("SVX/CL/PARSE",
		{"skipping invalid command line option: ", inst.get_name()}, UVM_NONE)
      return;
    end

    // Transfer the fmt from the option descriptor to the option
    // instance.
    inst.fmt = opt.fmt;

    if(!opt.validate_and_convert(inst))
      errs++;

  endfunction
  
endclass

//----------------------------------------------------------------------
// populate_resource_db
//
// A function class that puts each command line option into the
// resource database.
//----------------------------------------------------------------------
class populate_resource_db extends fcn#(cl_opt_instance_base);

  function void f(cl_opt_instance_base inst);

    // Look up the command line option
    cl_opt_desc_base opt = cl_mgr::find(inst.get_name());
    // Is it a valid option?  At this point the lookup should never
    // fail because it was checked during the validate phase, but we
    // check just to be sure.
    if(opt == cl_opt_traits::empty) begin
      `uvm_info("SVX/CL/PARSE",
		{"skipping invalid command line option: ", inst.get_name()}, UVM_NONE)
      return;
    end

    opt.publish(inst);
    
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
    clp = uvm_cmdline_processor::get_inst();
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
    accum#(string, string_traits, opt_vector_t)::accumulate(iter, 
							    parse,
							    opt_vec);

    if(parse.has_errors) begin
      `uvm_error(SVX_CL_MSG_ID,
		 "Errors in the command line prevent further processing of the options.")
      return;
    end
    
    //------------------------------------------------------------------
    // Second pass. Validate the options.

    errs = 0;
    opt_iter = new(opt_vec);
    validate = new();
    accum#(cl_opt_instance_base, cl_opt_inst_traits, uint32_t)::accumulate(opt_iter, 
									   validate, 
									   errs);

    //------------------------------------------------------------------
    // Third pass. Populate values into the resource database
    
    if(errs > 0) begin
      `uvm_error(SVX_CL_MSG_ID,
		 "Errors in the command line prevent further processing of the options.")
      return;
    end

    populate = new();
    algo#(cl_opt_instance_base, cl_opt_inst_traits)::for_each(opt_iter,
							      populate);

    // Print the list of options
    $display("\n--- Parsed Command Line Options  ---");
    print = new();
    algo#(cl_opt_instance_base, cl_opt_inst_traits)::for_each(opt_iter,
							      print);
    $display("--- END Parsed Command Line Options  ---");

  endfunction

endclass

