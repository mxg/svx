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
// opt_descriptor
//
// Holds parsed information about a command line option
//----------------------------------------------------------------------
class opt_descriptor;
  string name;
  string value;
  token_t token;

  function void print();
    $write("opt: %s", name);
    if(value != null)
      $display(" %s (%s)", value, token.name());
    else
      $display();
  endfunction

endclass

//----------------------------------------------------------------------
// print_opt
//
// A function object for printing option descriptors
//----------------------------------------------------------------------
class print_opt extends fcn#(opt_descriptor);
  function void f(opt_descriptor opt);
    opt.print();
  endfunction
endclass

typedef vector#(opt_descriptor, class_traits#(opt_descriptor)) opt_vector_t;
typedef list_iterator#(opt_descriptor, class_traits#(opt_descriptor)) opt_iterator_t;

//----------------------------------------------------------------------
// parse_opt
//
// An accumulator function ckass for parsing an option
//----------------------------------------------------------------------
class parse_opt extends accum_fcn#(string, opt_vector_t);

    virtual function void f(string opt, ref opt_vector_t opt_list);
      token_t token;
      string lexeme;
      opt_descriptor opt_desc;
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
      // to the optioh list.
      opt_desc = new();
      opt_desc.name = lexeme;
      opt_list.appendc(opt_desc);

      // The value of an option is separated from the name with an '='.
      token = lex.get_token();
      if(token != TOKEN_EQUAL)
	return;

      // Get the value
      token = lex.get_token();
      opt_desc.token = token;
      opt_desc.value = lex.get_lexeme();
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
  function vector_string get_args();
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
    vector_string vec = get_args();
    list_string_iterator iter = new(vec);
    opt_vector_t opt_vec = new();
    opt_iterator_t opt_iter = new(opt_vec);
    parse_opt parse = new();
    print_opt print = new();

    // First pass parse.  Pull apart each option and put the result into a list;
    accum#(string, string_traits, opt_vector_t)::accumulate(iter, parse, opt_vec);

    // Print the list of opt_descriptors
    algo#(opt_descriptor, class_traits#(opt_descriptor))::for_each(opt_iter, print);

  endfunction

endclass

