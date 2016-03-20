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
// lexer_core
//
// lexical analyzer.  Breaks a string into lexical tokens
//
// The collection of functions that is the user interface includes:
//
//  start() -- Initializes the lexer with a user-supplied string to be
//             analyzed.  The other functions can only be called after
//             start() has been called.
//  get_token() -- return the next token in the input stream
//  get_lexeme() -- return the string associated with the last token.
//  get_token_descriptor() -- return a descriptor that provides detailed
//                            information about the token.  This is
//                            available for numeric tokens
//
// To use the lexer instantiate lexer_core, call start() with a string
// and then make a series of calls to get_token().  Get_lexeme() and
// get_token_descriptor() may be used optionally if more information is
// needed about a particular token.
//
// Note: This lexer does not handle comments.  Perhaps that's a
// capability to be added.
//
// The lexer core contains a variety of utility functions that are used
// in performing a lexical analysis of a string.  They are all local
// functions and are not part of the user interface. These include:
//
//  getc()  -- return the next character in the string
//  puts()  -- put the last chacaracter retrieved back into the string
//  more()  -- answers the question "are there more characters left to
//             analyze in the string?"
//  mark_lexeme() -- Mark the beginning location of the next lexeme
//  get_int_size() -- A special lexer utility that looks for the digits
//                    that represent the size of a sized integer
//                    constant.
//----------------------------------------------------------------------
class lexer_core;

  // variable: input character stream
  local string s;

  // variable: pointer (index) to the current character in the stream
  local int unsigned p;

  // variable: pointer (index) to the beginning of the current lexeme
  local int unsigned lexp;

  // variable: class object that contains additional information about
  // each lexeme.  Mainly used for numeric tokens
  local token_descriptor token_desc;

  //+==================================================================+
  //+                                                                  +
  //+                            USER INTERFACE                        +
  //+                                                                  +
  //+==================================================================+

  //--------------------------------------------------------------------
  // start
  // initialize the string to be analyzed
  //--------------------------------------------------------------------
  function void start(string _s);
    s = _s;
    p = 0;
    lexp = 0;
  endfunction

  //--------------------------------------------------------------------
  // function: get_lexeme
  //
  // Return the current lexeme.  This is the string between the mark
  // (lexp) and the current character pointed to by p.
  //--------------------------------------------------------------------
  function string get_lexeme();
    string lexeme = "";
    lexeme = s.substr(lexp, p-1);
    return lexeme; 
  endfunction

  //--------------------------------------------------------------------
  // function: get_token
  //
  // Retrieve the next token from the input stream.
  //--------------------------------------------------------------------
  function token_t get_token();

    byte c;

    // skip whitespace
    for(c = getc(); `isspace(c); c = getc() );

    mark_lexeme();

    // if we have an alphabetic character then the next token is an id.
    // An id can begin with a letter or an underbar and contains
    // letters, numbers, and underbars.
    if(`isalpha(c) || c == "_") begin
      putc();
      for(c = getc(); `isalnum(c) || (c == "_"); c = getc());
      if(c != 0)
        putc();
      case(get_lexeme())
        "off"   : return TOKEN_OFF;
        "OFF"   : return TOKEN_OFF;
        "on"    : return TOKEN_ON;
        "ON"    : return TOKEN_ON;
        "true"  : return TOKEN_ON;
        "TRUE"  : return TOKEN_ON;
        "false" : return TOKEN_OFF;
        "FALSE" : return TOKEN_OFF;
        default : return TOKEN_ID;
      endcase
      // We should not reach this point
    end

    // A double quote indicates the beginning of a string.  Gobble up
    // all characters until then next double quote
    if(c == "\"") begin
      for(c = getc(); c != "\""; c = getc());
      return TOKEN_STRING;
    end

    // Single quoted string
    if(c == "\'") begin
      for(c = getc(); c != "\'"; c = getc());
      return TOKEN_STRING;
    end

    // if we have a digit or a dot then the
    // next token is a number
    if(`isdigit(c) || c == "-" || c == "+") begin
      putc();
      return lex_num();
    end

    // Look for >, >=, <, and <= tokens
    case (c)
      "<" : begin
    	      c = getc();
              if( c == "=")
                return TOKEN_LESS_EQUAL;
              else begin
                putc();
                return TOKEN_LESS_THAN;
              end
	    end
      ">" : begin
    	      c = getc();
              if( c == "=")
                return TOKEN_GREATER_EQUAL;
              else begin
                putc();
                return TOKEN_GREATER_THAN;
              end
	    end
      endcase
                  
    // Look for single character tokens
    case (c)
      0        : return TOKEN_EOL;
      "+"      : return TOKEN_PLUS;
      "="      : return TOKEN_EQUAL;
      "*"      : return TOKEN_STAR;
      "/"      : return TOKEN_SLASH;
      "."      : return TOKEN_DOT;
      "@"      : return TOKEN_AT;
      "%"      : return TOKEN_PERCENT;
      "&"      : return TOKEN_AMPERSAND;
      "^"      : return TOKEN_CARAT;
      "~"      : return TOKEN_TILDE;
      "`"      : return TOKEN_BACKTICK;
      "$"      : return TOKEN_DOLLAR;
      "#"      : return TOKEN_POUND;
      "?"      : return TOKEN_QUESTION;
      ":"      : return TOKEN_COLON;
      ";"      : return TOKEN_SEMI;
      "!"      : return TOKEN_BANG;
      "("      : return TOKEN_LEFT_PAREN;
      ")"      : return TOKEN_RIGHT_PAREN;
      default  : return TOKEN_ERROR;
    endcase
  endfunction

  //--------------------------------------------------------------------
  // function get_token_descriptor
  //--------------------------------------------------------------------
  function token_descriptor get_token_descriptor();
    return token_desc;
  endfunction

  //--------------------------------------------------------------------
  // get_loc
  // return the location of the last lexeme
  //--------------------------------------------------------------------
  function int unsigned get_loc();
    return lexp;
  endfunction

  //+==================================================================+
  //+                                                                  +
  //+                     INTERNAL UTILITY FUNCTIONS                   +
  //+                                                                  +
  //+==================================================================+

  //--------------------------------------------------------------------
  // function: getc
  //
  // return the next character from the input stream
  //--------------------------------------------------------------------
  local function byte getc();
    byte b;

    if(s.len() > 0 && p < s.len()) begin
      b = s[p];
      p++;
      return b;
    end

    return 0; // 0 is end-of-line (EOL)

  endfunction

  //--------------------------------------------------------------------
  // function: putc
  //
  // Return the last character back to the input stream.  It will be the
  // next character returned but getc().
  //--------------------------------------------------------------------
  local function void putc();
    if(p > 0) begin
      if(p < s.len())
        p--;
      else
        p = s.len() - 1;
    end
  endfunction

  //--------------------------------------------------------------------
  // function: more
  //
  // Answers the question: Are there more characters left in the 
  // input stream?
  //--------------------------------------------------------------------
  local function bit more();
    return (p < s.len()); 
  endfunction

  //--------------------------------------------------------------------
  // function: mark_lexeme
  //
  // Mark the beginnning of a lexeme by setting the lexp pointer.  Take
  // care not to go past the end of the input string.
  //--------------------------------------------------------------------
  local function void mark_lexeme();
    lexp = p;
    if(p > 0)
      lexp--;
  endfunction

  //--------------------------------------------------------------------
  // function: get_int_size
  //
  // Returns the size component of a sized integer.  This is a special
  // convenience function to be called only from lex_num().  This is not
  // a general purpose function.
  //--------------------------------------------------------------------
  local function int unsigned get_int_size();
    string lexeme = s.substr(lexp, p-2);
    return lexeme.atoi();
  endfunction

  //--------------------------------------------------------------------
  // lex_num
  //
  // The next token is some sort of numeric constant. Do the lexical
  // analysis to find out what it is.  Update the token descriptor with
  // detailed information about the numeric token.
  //--------------------------------------------------------------------
  local function token_t lex_num();

    // Enum that represents the various states of our numeric constant
    // recognizer state machine.  It's entirely local to this function.
    typedef enum {
                  STATE_START,
                  STATE_SIGN,
                  STATE_DIGIT,
                  STATE_UNDERBAR,
                  STATE_DECIMAL_POINT,
                  STATE_DECIMAL,
                  STATE_DECIMAL_UNDERBAR,
                  STATE_EXPONENT,
                  STATE_EXP_SIGN,
                  STATE_EXP_DIGIT,
                  STATE_S,
                  STATE_TIME,
                  STATE_SIGNED,
                  STATE_HEX,
                  STATE_HEX_DIGIT,
                  STATE_OCT,
                  STATE_OCT_DIGIT,
                  STATE_BIN,
                  STATE_BIN_DIGIT
                 } state_t;

    byte c;
    state_t state = STATE_START;
    string lexeme;
    byte sign;

    token_desc = new();

    // The lexer loops runs until a token is recognized or an error is
    // encountered.  In either case the loop is terminated by a return
    // statement.

    forever begin
 
      c = getc();

      // This is a useful statement for debugging, so we'll leave it
      // here.  Uncomment when you want to see the state transitions the
      // lexer goes through.
//      $display("state = %s : c = %s", state.name(), ((c==0)?"EOL":c));

      case(state)
        STATE_START:
          // Initial state of the FSM
          begin
            sign = "";
            if(c == "-" || c == "+") begin
              sign = c;
              state = STATE_SIGN;
            end
            else
              if(`isdigit(c))
                state = STATE_DIGIT;
              else
                return TOKEN_ERROR;
          end

        STATE_SIGN:
          // We've seen a + or - so perhaps we are at the beginning of a
          // signed constant.
          begin
            // If the next character is a digit then definitely we are
            // at the beginning of a signed constant.
            if(`isdigit(c))
              state = STATE_DIGIT;
            else begin
              // Nope, no signed constant, just a sign character.
              case (sign)
                "+" : return TOKEN_PLUS;
                "-" : return TOKEN_MINUS;
                default: return TOKEN_ERROR; // uh oh, something has gone wrong
              endcase
            end
          end

        STATE_DIGIT:
          // At this point we are expecting a string of digits.
          // However, SystemVerilog syntax (which we are trying to
          // emulate here) allows for a number of things preceeding a
          // string of digits.  This includes a letter indicating the
          // radix of the constant and a size (in bits) of the constant.
          // At the ned of the constant could be a units indicator which
          // is used in time constants.
          begin
            case(c)  
              "." : state = STATE_DECIMAL_POINT;
              "e" : state = STATE_EXPONENT;
              "E" : state = STATE_EXPONENT;
              "_" : state = STATE_UNDERBAR;
              "h" :
                begin
                  token_desc.size = get_int_size();
                  state = STATE_HEX;
                end
              "H" :
                begin
                  token_desc.size = get_int_size();
                  state = STATE_HEX;
                end
              "o" :
                begin
                  token_desc.size = get_int_size();
                  state = STATE_OCT;
                end
              "O" :
                begin
                  token_desc.size = get_int_size();
                  state = STATE_OCT;
                end
              "b" :
                begin
                  token_desc.size = get_int_size();
                  state = STATE_BIN;
                end
              "B" :
                begin
                  token_desc.size = get_int_size();
                  state = STATE_BIN;
                end
              "S" : 
                begin
                  token_desc.is_signed = 1;
                  state = STATE_SIGNED;
                end
              "s" : state = STATE_S;
              "m" : state = STATE_TIME;
              "u" : state = STATE_TIME;
              "n" : state = STATE_TIME;
              "p" : state = STATE_TIME;
              "f" : state = STATE_TIME;
              default :
                begin
                  if(!`isdigit(c)) begin
                    if(c != 0) putc();
                    token_desc.kind = TOKEN_KIND_INT;
                    return TOKEN_INT;
                  end
                end
            endcase
          end

        STATE_S:
          begin
            case(c)
              "h" : state = STATE_HEX;
              "H" : state = STATE_HEX;
              "o" : state = STATE_OCT;
              "O" : state = STATE_OCT;
              "b" : state = STATE_BIN;
              "B" : state = STATE_BIN;
              default:
                begin
                  if(c != 0)
                    putc();
                  return TOKEN_TIME;
                end
            endcase
          end

        STATE_UNDERBAR:
          // In SystemVerilog syntax numeric constants can have
          // underbars in them.  Continue looking for digits. We may
          // also find an exponent marker or a units marker.
          begin
            case(c)
              "." : state = STATE_DECIMAL_POINT;
              "e" : state = STATE_EXPONENT;
              "E" : state = STATE_EXPONENT;
              "m" : state = STATE_TIME;
              "u" : state = STATE_TIME;
              "n" : state = STATE_TIME;
              "p" : state = STATE_TIME;
              "f" : state = STATE_TIME;
              "s" : 
                begin
                  state = STATE_TIME;
                  putc();
                end
              default:
                begin
                  if(!`isdigit(c) && c != "_") begin
                    if(c != 0) putc();
                    token_desc.kind = TOKEN_KIND_INT;
                    return TOKEN_INT;
                  end
                 end
             endcase
          end

        STATE_DECIMAL_POINT:
          begin
            if(`isdigit(c))
              state = STATE_DECIMAL;
            else
              return TOKEN_ERROR;
          end

        STATE_DECIMAL:
          // OK, we found a decimal point.  Ater the decimal point we
          // can expect more digits or an exponent or units marker.
          // Perhaps there is an underbar in the string of digits
          // following the decimal point.
          begin
            case(c)
              "e": state = STATE_EXPONENT;
              "E": state = STATE_EXPONENT;
              "_": state = STATE_DECIMAL_UNDERBAR;
              "m": state = STATE_TIME;
              "u": state = STATE_TIME;
              "n": state = STATE_TIME;
              "p": state = STATE_TIME;
              "f": state = STATE_TIME;
              "s": 
                begin
                  return TOKEN_TIME;
                end
              default:
                begin
                  if(!`isdigit(c)) begin
                    return TOKEN_FLOAT;
                  end
                end
            endcase
          end

        STATE_DECIMAL_UNDERBAR:
          // Underbar found after the decimal point.  Continue looking
          // for digits after the decimal point, exponent markers, units
          // markers, and another underbar.
          begin
            case(c)
              "e": state = STATE_EXPONENT;
              "E": state = STATE_EXPONENT;
              "_": state = STATE_DECIMAL_UNDERBAR;
              "m": state = STATE_TIME;
              "u": state = STATE_TIME;
              "n": state = STATE_TIME;
              "p": state = STATE_TIME;
              "f": state = STATE_TIME;
              "s": 
                begin
                  return TOKEN_TIME;
                end
              default:
                begin
                  if(!`isdigit(c))
                    return TOKEN_FLOAT;
                end
            endcase
          end

        STATE_EXPONENT:
          // We encountered an exponent marker.  Let's get the exponent
          // digits.  Byt the way, and exponent may be signed.
          begin
            if(c == "+" || c == "-")
              state = STATE_EXP_SIGN;
            else
              if(`isdigit(c))
                state = STATE_EXP_DIGIT;
              else
                return TOKEN_ERROR;
          end

        STATE_EXP_SIGN:
          // The exponent is signed.  The only things that can follow an
          // exponent marker and sign is more digits and perhaps a units
          // marker.
          begin
            if(`isdigit(c))
              state = STATE_EXP_DIGIT;
            else
              return TOKEN_ERROR;
          end

        STATE_EXP_DIGIT:
          // Keep looking for exponent digits and maybe a units marker
          begin
            case(c)
              "m": state = STATE_TIME;
              "u": state = STATE_TIME;
              "n": state = STATE_TIME;
              "p": state = STATE_TIME;
              "f": state = STATE_TIME;
              "s": 
                begin
                  state = STATE_TIME;
                  putc();
                end
              default:
                begin
                  if(!`isdigit(c)) begin
                    return TOKEN_FLOAT;
                  end
                end
            endcase
          end

        STATE_TIME:
          // OK, we found a units marker.  Let's figure out what the
          // unit is.
          begin
            if(c != "s")
              return TOKEN_ERROR;

            putc();
            putc();
            c = getc();
            case(c)
              "m": token_desc.multiplier = 1.0e-3;
              "u": token_desc.multiplier = 1.0e-6;
              "n": token_desc.multiplier = 1.0e-9;
              "p": token_desc.multiplier = 1.0e-12;
              "f": token_desc.multiplier = 1.0e-15;
              default: return TOKEN_ERROR;
            endcase
            c = getc();
            return TOKEN_TIME;
          end

        STATE_SIGNED:
          begin
            case(c)
              "h" : state = STATE_HEX;
              "H" : state = STATE_HEX;
              "o" : state = STATE_OCT;
              "O" : state = STATE_OCT;
              "b" : state = STATE_BIN;
              "B" : state = STATE_BIN;
              default:
                begin
                  putc();
                  return TOKEN_TIME;
                end
            endcase
          end

        STATE_HEX:
          // We found a HEX maker, now let's start looking for HEX
          // digits
          begin
            if(`isxdigit(c) || `islogic(c)) begin
              mark_lexeme();
              token_desc.is_logic |= `islogic(c);
              state = STATE_HEX_DIGIT;
            end
            else
              return TOKEN_ERROR;
          end

        STATE_HEX_DIGIT:
          // Keep looking for HEX digits
          begin
            if( !`isxdigit(c) && c != "_" && !`islogic(c)) begin
              if(c != 0) putc();
              token_desc.kind = TOKEN_KIND_HEX;
              return token_desc.is_logic ? TOKEN_LOGIC : TOKEN_INT;
            end
            token_desc.is_logic |= `islogic(c);
          end

        STATE_OCT:
          // We found an OCT marker, look for OCT digits
          begin
            if(`isodigit(c) || `islogic(c)) begin
              mark_lexeme();
              token_desc.is_logic |= `islogic(c);
              state = STATE_OCT_DIGIT;
            end
            else
              return TOKEN_ERROR;
          end

        STATE_OCT_DIGIT:
          // Let's keep looking for OCT digits
          begin
            if( !`isodigit(c) && c !== "_" && !`islogic(c)) begin
              if(c != 0) putc();
              lexeme = get_lexeme();
              token_desc.kind = TOKEN_KIND_OCT;
              return token_desc.is_logic ? TOKEN_LOGIC : TOKEN_INT;
            end
            token_desc.is_logic |= `islogic(c);
          end

        STATE_BIN:
          // We found a BIN marker, look for binary digits
          begin
            if(c == "0" || c == "1"  || `islogic(c)) begin
              mark_lexeme();
              token_desc.is_logic |= `islogic(c);
              state = STATE_BIN_DIGIT;
            end
            else
              return TOKEN_ERROR;
          end

        STATE_BIN_DIGIT:
          // Keep looking for binary digits
          begin
            if(! (c == "0" || c == "1")  && !`islogic(c)) begin
              if(c != 0) putc();
              token_desc.kind = TOKEN_KIND_BIN;
              return token_desc.is_logic ? TOKEN_LOGIC : TOKEN_INT;
            end
            token_desc.is_logic |= `islogic(c);
          end

      endcase

    end  // forever

  endfunction

endclass
