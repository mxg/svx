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

//---------------------------------------------------------------------
// RPN CALCULATOR
//----------------------------------------------------------------------
typedef triple#(token_t, int, real) item_t;

class calc;

  local item_t last_result;
  local lexer_core lex;
  local stack#(item_t, class_traits#(item_t)) stk;

  function new();
    lex = new();
    stk = new();
  endfunction

  function item_t get_last_result();
    return last_result;
  endfunction

  function void print_item(item_t t);
    case(t.first())
      TOKEN_INT:   $display("%0d", t.second());
      TOKEN_FLOAT: $display("%g",  t.third());
      default:     $display("invlaid token");
    endcase
  endfunction  

  // Parse the input RPN string and perform the specified calculation.
  // Return 1 if the evaluation was successful, a 0 if there was an
  // error.
  
  function bit calculate(string s);

    token_t tkn;
    item_t a;
    item_t b;
    item_t c;
    
    stk.clear(); // make sure the stack is empty
    lex.start(s);
    last_result = null;

    forever begin

      // Retrierve the next token from the input stream
      tkn = lex.get_token();

      // Are we at the end of the input?
      if(tkn == TOKEN_EOL) begin
	if(!stk.is_empty()) begin
	  last_result = stk.pop();
	end
	break;
      end

      // Push operands on the stack; For operators pop the required
      // number of operands and execute the operation.

      case(tkn)

	// int operand
	TOKEN_INT: begin
	  string lexeme = lex.get_lexeme();
	  int i= lexeme.atoi();
	  a = new(TOKEN_INT, i, 0.0);
	  stk.push(a);
	end

	// float operand
	TOKEN_FLOAT: begin
	  string lexeme = lex.get_lexeme();
	  real f = lexeme.atoreal();
	  a = new(TOKEN_FLOAT, 0, f);
	  stk.push(a);
	end
	
	// addition
	TOKEN_PLUS:
	  begin
	    if(!get_two_operands(a, b)) // error?
	      return 0;
	    c = new(TOKEN_INT, 0, 0.0);
	    if(a.first == TOKEN_INT) begin
	      // integer arithmetic
	      c.set_first(TOKEN_INT);
	      c.set_second(a.second() + b.second());
	    end
	    else begin
	      // realing point arithmetic
	      c.set_first(TOKEN_FLOAT);
	      c.set_third(a.third() + b.third());
	    end
	    stk.push(c);
	  end	

	// subraction
	TOKEN_MINUS:
	  begin
	    if(!get_two_operands(a, b)) // error?
	      return 0;
	    c = new(TOKEN_INT, 0, 0.0);
	    if(a.first == TOKEN_INT) begin
	      // integer arithmetic
	      c.set_first(TOKEN_INT);
	      c.set_second(b.second() - a.second());
	    end
	    else begin
	      // realing point arithmetic
	      c.set_first(TOKEN_FLOAT);
	      c.set_third(b.third() - a.third());
	    end
	    stk.push(c);
	  end	

	// multiplication
	TOKEN_STAR:
	  begin
	    if(!get_two_operands(a, b)) // error?
	      return 0;
	    c = new(TOKEN_INT, 0, 0.0);
	    if(a.first == TOKEN_INT) begin
	      // integer arithmetic
	      c.set_first(TOKEN_INT);
	      c.set_second(a.second() * b.second());
	    end
	    else begin
	      // realing point arithmetic
	      c.set_first(TOKEN_FLOAT);
	      c.set_third(a.third() * b.third());
	    end
	    stk.push(c);
	  end	

	// division
	TOKEN_SLASH:
	  begin
	    if(!get_two_operands(a, b)) // error?
	      return 0;
	    c = new(TOKEN_INT, 0, 0.0);
	    if(a.first == TOKEN_INT) begin
	      // integer arithmetic
	      c.set_first(TOKEN_INT);
	      c.set_second(b.second() / a.second());
	    end
	    else begin
	      // realing point arithmetic
	      c.set_first(TOKEN_FLOAT);
	      c.set_third(b.third() / a.third());
	    end
	    stk.push(c);
	  end

	default:
	  begin
	    $display("invalid input token - \'%s\'", lex.get_lexeme());
	    return 0;
	  end

      endcase
      
    end

    if(last_result == null)
      return 0;

    print_item(last_result);
    return 1; // success

  endfunction

  //--------------------------------------------------------------------
  // get_two_operands
  //
  // Retrieve two operands from the stack.  Ensure that both operands
  // are the same type, either both ints or both reals.  Return 1 if
  // everything is OK, a zero if there is a problem.
  //--------------------------------------------------------------------
  local function bit get_two_operands(output item_t op_a, output item_t op_b);

    // pop first operand    
    if(stk.is_empty()) begin
      $display("stack underflow");
      return 0;
    end
    op_a = stk.pop();

    // pop second operand
    if(stk.is_empty()) begin
      $display("stack underflow");
      return 0;
    end
    op_b = stk.pop();

    // Normalize the operands so they are either both ints or both
    // reals.
    
    if(op_a.first() == TOKEN_INT) begin
      if(op_b.first == TOKEN_INT)
	return 1;
      if(op_b.first() == TOKEN_FLOAT) begin
	// convert ob_a to real
	op_a.set_first(TOKEN_FLOAT);
	op_a.set_third(op_a.second() + 0.0);
	return 1;
      end
      else begin
	$display("invalid token on the stack");
	return 0;
      end
    end

    if(op_a.first() == TOKEN_FLOAT) begin
      if(op_b.first() == TOKEN_FLOAT)
	return 1;
      if(op_b.first() == TOKEN_INT) begin
	// convert op_b to real
	op_b.set_first(TOKEN_FLOAT);
	op_b.set_third(op_b.second() + 0.0);
	return 1;
      end
      else begin
	$display("invalid token on the stack - %s", lex.get_lexeme());
	return 0;
      end
    end

      // If we get here there's a problem with the first operand
      $display("invalid token on the stack");
      return 0;
    
  endfunction

endclass
