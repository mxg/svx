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

//----------------------------------------------------------------------
// Token Types
//
// enum listing all the possible token types that can be returned by the
// lexer.
//----------------------------------------------------------------------
typedef enum {TOKEN_PLUS,
              TOKEN_MINUS,
	      TOKEN_STAR,
	      TOKEN_SLASH,
	      TOKEN_DOT,
	      TOKEN_BANG,
              TOKEN_ID,
              TOKEN_INT,
              TOKEN_LOGIC,
              TOKEN_FLOAT,
              TOKEN_TIME,
              TOKEN_STRING,
              TOKEN_ON,
              TOKEN_OFF,
              TOKEN_EQUAL,
	      TOKEN_GREATER_THAN,
	      TOKEN_GREATER_EQUAL,
	      TOKEN_LESS_THAN,
	      TOKEN_LESS_EQUAL,
              TOKEN_AT,
	      TOKEN_PERCENT,
	      TOKEN_AMPERSAND,
	      TOKEN_CARAT,
	      TOKEN_TILDE,
	      TOKEN_BACKTICK,
	      TOKEN_DOLLAR,
	      TOKEN_POUND,
	      TOKEN_QUESTION,
              TOKEN_SEMI,
              TOKEN_COLON,
	      TOKEN_LEFT_PAREN,
	      TOKEN_RIGHT_PAREN,
              TOKEN_EOL,
              TOKEN_ERROR
             } token_t;

typedef enum {
              TOKEN_KIND_INT,
              TOKEN_KIND_HEX,
              TOKEN_KIND_OCT,
              TOKEN_KIND_BIN,
              TOKEN_KIND_FLOAT,
              TOKEN_KIND_RAND_INT
             } token_kind_t;

//----------------------------------------------------------------------
// token_traits
//
// A traits class is available so you can put tokens in vectors and
// maps.
//----------------------------------------------------------------------
class token_traits extends void_t;

  typedef token_t empty_t;
  const static empty_t empty = TOKEN_EOL;

  static function bit equal(token_t a, token_t b);
    return (a == b);
  endfunction

  static function int compare(token_t a, token_t b);
    if(a > b)
      return 1;     // a > b
    else
      if(a < b)
        return -1;  // a < b
      else
        return 0;   // a == b
  endfunction

  static function sort(token_t vec[$]);
    vec.sort with (item);
  endfunction

endclass

//----------------------------------------------------------------------
// class token_descriptor
//----------------------------------------------------------------------
class token_descriptor;

  int unsigned size;
  bit is_signed;
  bit is_logic;
  token_kind_t kind;
  real multiplier;

  function new();
    size = 32;
    is_signed = 0;
    is_logic = 0;
    multiplier = 1.0;
  endfunction

endclass


