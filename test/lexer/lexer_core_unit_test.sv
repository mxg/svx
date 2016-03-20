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
// Copyright 2016 NVIDIA Corporation
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

module lexer_core_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  import test_utils::*;  

  string name = "lexer_core_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */
  endtask

  //--------------------------------------------------------------------
  // Look for a series of the same token (with different lexemes, of
  // course) followed by an EOL.  Return the count of the number of
  // tokens recognized.
  //--------------------------------------------------------------------

  task parse_token(input token_t compare_token,
                   input string s,
                   output int unsigned count);

    token_t token;
    lexer_core lex;

    lex = new();
    lex.start(s);

    count = 0;
    do begin
      token = lex.get_token();
      if(token != TOKEN_EOL) begin
        `FAIL_IF(token != compare_token)
        count++;
      end
    end while(token != TOKEN_EOL);

  endtask

  //--------------------------------------------------------------------
  // match a sequence of tokens stored in a queue
  //--------------------------------------------------------------------
  task match_token_sequence(input string s,
                            input queue#(token_t, token_traits) q);

    token_t token;
    lexer_core lex = new();

    lex.start(s);

    do begin
      token = lex.get_token();
      `FAIL_IF(token != q.get())
    end
    while(token != TOKEN_EOL);

  endtask

  //--------------------------------------------------------------------
  // Match a token and a lexeme
  //--------------------------------------------------------------------

  task match_token(input lexer_core lex,
                   input token_t compare_token,
                   input string compare_lexeme = "");

    token_t token;
    string lexeme;

    token = lex.get_token();
    lexeme = lex.get_lexeme();
    `FAIL_IF(token != compare_token)
    if(compare_lexeme != "")
      `FAIL_UNLESS_STR_EQUAL(lexeme, compare_lexeme)
    
  endtask

  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN
  //--------------------------------------------------------------------
  // id
  //--------------------------------------------------------------------
    `SVTEST(id)
      string s;
      token_t token;
      lexer_core lex = new();

      // Recognize a simple id
      s = "hello";
      lex.start(s);
      match_token(lex, TOKEN_ID, "hello");
      match_token(lex, TOKEN_EOL);

      // Recognize ids that have underscores in them.  
      s = "_first last_ in_between mult___iple _a__ll_ m_42_77 _06ff";
      lex.start(s);

      match_token(lex, TOKEN_ID, "_first");
      match_token(lex, TOKEN_ID, "last_");
      match_token(lex, TOKEN_ID, "in_between");
      match_token(lex, TOKEN_ID, "mult___iple");
      match_token(lex, TOKEN_ID, "_a__ll_");
      match_token(lex, TOKEN_ID, "m_42_77");
      match_token(lex, TOKEN_ID, "_06ff");

    `SVTEST_END

  //--------------------------------------------------------------------
  // pathname
  //--------------------------------------------------------------------
    `SVTEST(pathname)
      string s;
      queue#(token_t, token_traits) q = new();

      // parse a simple pathname
      s = "a.b.c";
      q.put(TOKEN_ID);
      q.put(TOKEN_DOT);
      q.put(TOKEN_ID);
      q.put(TOKEN_DOT);
      q.put(TOKEN_ID);
      match_token_sequence(s, q);

      // Do it again with a somewhat more complicated pathname
      q.clear();
      s = "top.u1_a.m17.__y__.QWERTY";
      q.put(TOKEN_ID);
      q.put(TOKEN_DOT);
      q.put(TOKEN_ID);
      q.put(TOKEN_DOT);
      q.put(TOKEN_ID);
      q.put(TOKEN_DOT);
      q.put(TOKEN_ID);
      q.put(TOKEN_DOT);
      q.put(TOKEN_ID);
      match_token_sequence(s, q);

    `SVTEST_END

  //--------------------------------------------------------------------
  // integers
  //--------------------------------------------------------------------
    `SVTEST(integers)

      string s;
      int unsigned count;
      queue#(token_t, token_traits) q = new();

      // A string with a collection of signed and unsigned integers
      s = "42  108  -13  +19 -12578 0987654 22";

      parse_token(TOKEN_INT, s, count);
      `FAIL_IF(count != 7)

      // Here is another string with a variety of signed and unsigned
      // integers as well as signs.  Lex the string to recognize all the
      // tokens.  We put the expected tokens in a queue and then match
      // them in the "parse" loop.

      s = "+ +0 - -0 +1 1+1 0-0 123_456 +";
      q.put(TOKEN_PLUS);
      q.put(TOKEN_INT);
      q.put(TOKEN_MINUS);
      q.put(TOKEN_INT);     
      q.put(TOKEN_INT);
      q.put(TOKEN_INT);
      q.put(TOKEN_INT);
      q.put(TOKEN_INT);
      q.put(TOKEN_INT);
      q.put(TOKEN_INT);
      q.put(TOKEN_PLUS);
      q.put(TOKEN_EOL);

      match_token_sequence(s, q);
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // floats
  //--------------------------------------------------------------------
    `SVTEST(floats)

      string s;
      int unsigned count;

      // A string with a collection of signed and unsigned integers
      s = "42.0 0.0 1.1 8.99999 -13.66 +82.479990";
      parse_token(TOKEN_FLOAT, s, count);
      `FAIL_IF(count != 6)

      // some more floats, this time with exponents
      s = "1.0e1 23.44e-3 0.3e+444 023E023 0E0 1e1 -1e+1 +6000.000e000";
      parse_token(TOKEN_FLOAT, s, count);
      `FAIL_IF(count != 8)

    `SVTEST_END

  //--------------------------------------------------------------------
  // single_char_tokens
  //--------------------------------------------------------------------
    `SVTEST(single_char_tokens)

      queue#(token_t, token_traits) q = new();
      string s;

      s = "@#$%^&*<>?<=>=.!;:=~`()*";

      q.put(TOKEN_AT);
      q.put(TOKEN_POUND);
      q.put(TOKEN_DOLLAR);
      q.put(TOKEN_PERCENT);
      q.put(TOKEN_CARAT);
      q.put(TOKEN_AMPERSAND);
      q.put(TOKEN_STAR);
      q.put(TOKEN_LESS_THAN);
      q.put(TOKEN_GREATER_THAN);
      q.put(TOKEN_QUESTION);
      q.put(TOKEN_LESS_EQUAL);
      q.put(TOKEN_GREATER_EQUAL);
      q.put(TOKEN_DOT);
      q.put(TOKEN_BANG);
      q.put(TOKEN_SEMI);
      q.put(TOKEN_COLON);
      q.put(TOKEN_EQUAL);
      q.put(TOKEN_TILDE);
      q.put(TOKEN_BACKTICK);
      q.put(TOKEN_LEFT_PAREN);
      q.put(TOKEN_RIGHT_PAREN);
      q.put(TOKEN_STAR);
      q.put(TOKEN_EOL);

      match_token_sequence(s, q);

    `SVTEST_END

  //--------------------------------------------------------------------
  // alternate_radix
  //--------------------------------------------------------------------
//    `SVTEST(alternate_radix)
//
//      queue#(token_t, token_traits) q = new();
//      string s;
//
//      s = "hfff7ab";
//
//      q.put(TOKEN_INT);
//      match_token_sequence(s, q);
//
//    `SVTEST_END
     
  `SVUNIT_TESTS_END

endmodule
