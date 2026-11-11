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
      `uvm_info(SVX_CL_MSG_ID, msg, UVM_NONE)
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
      if(!opt_desc.is_switch()) begin
	  $sformat(msg, "Missing value for command line option +%s", 
		   opt_inst.get_name());
	  `uvm_error(SVX_CL_MSG_ID, msg)
	  has_errors = 1;
	  return;
      end

      // A switch must end right after its name.
      if(token != TOKEN_EOL) begin
	$sformat(msg, "Extraneous characters after command line option +%s", 
		 opt_inst.get_name());
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
    token = opt_desc.lex_value(lex);
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
    if(!inst.opt_desc.validate_and_convert(inst))
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
    cl_opt_desc_base opt = inst.opt_desc;
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
  local static cl_parse inst;

  // Arguments supplied by set_args().  When use_supplied_args is set,
  // these are parsed instead of the real command line.
  local string supplied_args[$];
  local bit use_supplied_args;

  local function new();
    clp = uvm_cmdline_processor::get_inst();
    add_builtin_options();
  endfunction

  //--------------------------------------------------------------------
  // add_builtin_options
  //
  // These options come with the SVX library package
  //--------------------------------------------------------------------
  local function void add_builtin_options();
    cl#(bit)::add_with_default("svx_cl_dump", 0, "Dump the command line option table");
    cl#(string)::add("plugin", "Specify a plugin to be installed and activated");
    cl#(bit)::add("svx_help", "Dump the command line option table and then exit");
  endfunction
  
  //--------------------------------------------------------------------
  // get
  //
  // Return singleton instance of cl_parse
  //--------------------------------------------------------------------
  static function cl_parse get();
    if(inst == null)
      inst = new();
    return inst;
  endfunction

  //--------------------------------------------------------------------
  // set_args
  //
  // Supply the arguments to parse instead of reading them from the
  // simulator command line.  This is primarily for testing: a unit
  // test can hand the parser any command line it likes and check the
  // results.  As with the real command line, args[0] is expected to be
  // the program name and is ignored because it does not begin with '+'.
  //--------------------------------------------------------------------
  function void set_args(string args[$]);
    supplied_args = args;
    use_supplied_args = 1;
  endfunction

  //--------------------------------------------------------------------
  // get_args
  //
  // Retrieve the command line args, either those supplied by
  // set_args() or, by default, those from the UVM command line
  // processor.
  //--------------------------------------------------------------------
  local function vector_string get_args();
    string args[$];
    vector_string vec;

    if(use_supplied_args)
      args = supplied_args;
    else
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
    bit svx_cl_dump;

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

    // Users can specify +svx_help to get a dump of the command line
    // option table along with some other useful help information.
    if($test$plusargs("svx_help")) begin
      print_help();
    end

    // Have we already done this?  If so, we don't want to do it
    // again.
    if(cl_mgr::has_been_parsed()) begin
      `uvm_warning(SVX_CL_MSG_ID, {"The command line has already been parsed, ",
				   "we cannot do it again."})
      return;
    end

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
		 {"Errors in the command line prevent ",
		  "further processing of the options."})
      cl_mgr::set_parse_flag();
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
		 {"Errors in the command line prevent ",
		  "further processing of the options."})
      cl_mgr::set_parse_flag();
      return;
    end

    populate = new();
    algo#(cl_opt_instance_base, cl_opt_inst_traits)::for_each(opt_iter,
							      populate);

    // Print the list of options.  Use this for debugging the command
    // line parser.
    // $display("\n--- Parsed Command Line Options  ---");
    // print = new();
    // algo#(cl_opt_instance_base, cl_opt_inst_traits)::for_each(opt_iter,
    // 							      print);
    // $display("--- END Parsed Command Line Options  ---");

    // All done
    cl_mgr::set_parse_flag();

    if(uvm_resource_db#(bit)::read_by_name("CL::",
					   "svx_cl_dump", 
					   svx_cl_dump, null)) begin
      if(svx_cl_dump)
	cl_mgr::dump();
    end
    else
      `uvm_error(SVX_CL_MSG_ID,
		 "Missing svx_cl_dump option value in the resource database")

  endfunction

  //--------------------------------------------------------------------
  // print_help
  //
  // Print help information and then terminate.
  //--------------------------------------------------------------------
  function void print_help();
    ver::print_banner();
    cl_mgr::dump();
    $display();
    $display("command line syntax:");
    $display("  option  = +<option_name> |");
    $display("            +<option_name>=<value>");
    $display("  <value> = string |");
    $display("            floating point value |");
    $display("            decimal integer |");
    $display("            <size>h<hex_digits> |");
    $display("            <size>o<octal_digits> |");
    $display("            <size>b<binary_digits>");
    $display("  <size>  = decimal integer");
    $finish();
  endfunction
  

endclass
