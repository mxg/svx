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
// These classes are the option descriptors.  When a new option is
// created by cl::add() or cl::add_with_default() a new options
// descriptor is created that is used to validate option instances.
//
// The descriptors are organized using a three-level inheritance
// hierarchy.  The top-level, the base class, is used to
// polymorphically manage the descriptors.  The next level,
// cl_opt_desc#(T), provides the data type of the option, and the
// lowest leaf level provides type-specific implementation of the
// virtual functions.
//
// The primary virtual functions are:
//
// create_instance() -- Creates a new options instance object based on
// the descriptor type.  Some information from the descriptor is
// transferred to the instance.
//
// validate_and_convert() -- Validates the option value string from
// the command line and converts it to an internal representation.
//
// publish() -- puts the validated option and value into the UVM
// resource database.
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// cl_opt_desc_base
//
// Base class for command line option descriptors
//----------------------------------------------------------------------
virtual class cl_opt_desc_base;
  
  protected string name;
  string fmt;
  bit  multiple;

  function new(string _name);
    name = _name;
  endfunction

  pure virtual function cl_opt_instance_base create_instance(string name);
  pure virtual function bit validate_and_convert(cl_opt_instance_base inst);
  pure virtual function void publish(cl_opt_instance_base inst);
  pure virtual function type_container_base get_default_value();
  pure virtual function string get_typename();
  pure virtual function type_handle_base get_type_handle();

  virtual function string get_name();
    return name;
  endfunction

  virtual function bit is_switch();
    return 0;
  endfunction

  virtual function token_t lex_value(lexer_core lex);
      return lex.get_token();
  endfunction

  function void print();
    
    type_container_base def = get_default_value();
    
    $write("%12s: %s (fmt=%s)", name, get_typename(), fmt);
    if(def != null)
      $write(" = %s", def.val2str(fmt));
    if(multiple)
      $display(" (multiple ok)");
    else
      $display();
    
  endfunction  
  
endclass

// Convenience typedef for cl_opt_desc traits
typedef class_traits#(cl_opt_desc_base) cl_opt_traits;

//----------------------------------------------------------------------
// print_cl_opt
//
// A function class for printing cl_opt_desc objects.
//----------------------------------------------------------------------
class print_cl_opt extends fcn#(cl_opt_desc_base);
  function void f(cl_opt_desc_base opt);
    opt.print();
  endfunction
endclass

//----------------------------------------------------------------------
// cl_opt_desc
//----------------------------------------------------------------------
virtual class cl_opt_desc#(type T=int) extends cl_opt_desc_base;

  type_container#(T) default_value;

  function new(string _name);
    super.new(_name);
  endfunction

  virtual function cl_opt_instance_base create_instance(string name);
    cl_opt_instance#(T) opt_inst = new(name);
    // Bind the option descriptor to the instance
    opt_inst.opt_desc = this;
    // Transfer the fmt from the option descriptor to the option
    // instance.
    opt_inst.fmt = fmt;
    return opt_inst;
  endfunction

  pure virtual function bit validate_and_convert(cl_opt_instance_base inst);

  virtual function void publish(cl_opt_instance_base inst);
    type_container#(T) v;
    if ($cast(v, inst.get_value()))
      uvm_resource_db#(T)::set_override("CL::*", inst.get_name(), v.get());
  endfunction

  virtual function type_container_base get_default_value();
    return default_value;
  endfunction

  virtual function type_handle_base get_type_handle();
    return type_handle#(T)::get();
  endfunction

  virtual function string get_typename();
    return $typename(T);
  endfunction
  
endclass

//----------------------------------------------------------------------
// validate_int
//
// Validate integer types -- Contains common code used by all integer
// types.  Checks to see if the integer lexeme is properly formed and
// if the resulting integer fits into the type. Returns 0 if the
// validation fails, 1 otherwise.
//
// For internal use. Not to be instantiated nor called by user code.
//----------------------------------------------------------------------
class validate_int#(type T=int, type P);
  
  static function bit validate(cl_opt_instance_base inst, output T n);

    const uint32_t W = $bits(T);
    token_descriptor td = inst.td;
    string msg;
    uint128_t mag;
    uint128_t limit;  
    bit num_ok;
    int32_t len;
    bit too_long;
    uint32_t size = (td.size == 0) ? W : td.size;    

    // Is the argument an integer?
    if(inst.token != TOKEN_INT) begin
      $sformat(msg, "Invalid command line option value for +%s = %s. Expected %s integer.",
               inst.get_name(), inst.lexeme,
               (P::is_signed) ? "a signed" : "an unsigned");
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end

    // Does the argument fit into the data type?
    if(size > W) begin
      $sformat(msg,
               {"Invalid size of the value for command line option +%s. ",
                "Value must be an integer whose size is no more than %0d bits."},
               inst.get_name(), $bits(T));
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end

    // Did the user supply too many digits?  Count the digits without
    // the underbars. Also, skip leading 0s.
    len = 0;
    foreach (td.digits[i])
      if(td.digits[i] != "_" && (len > 0 || td.digits[i] != "0"))
        len++;
    case(td.base)
      "d", "D": too_long = (len > 20);
      "b", "B": too_long = (len > 64);
      "o", "O": too_long = (len > 22);
      "h", "H": too_long = (len > 16);
      default:  too_long = (len > 20);
    endcase
    if(too_long) begin
      $sformat(msg, {"Too many digits for option +%s. ",
                     "Integers can be a maximum of 64 bits."},
               inst.get_name());
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end

    // Convert digit string to an internal representation.
    case(td.base)
      "d", "D": num_ok = str_to_uint(td.digits, 10, mag);
      "b", "B": num_ok = str_to_uint(td.digits,  2, mag);
      "o", "O": num_ok = str_to_uint(td.digits,  8, mag);
      "h", "H": num_ok = str_to_uint(td.digits, 16, mag);
      default:
        begin
          $sformat(msg, "Value of option +%s has an invalid base %s.", 
		   inst.get_name(), td.base);
          `uvm_error(SVX_CL_MSG_ID, msg)
          return 0;
        end
    endcase

    if(!num_ok) begin
      $sformat(msg, "Invalid numerical argument for +%s = %s.", 
               inst.get_name(), inst.lexeme);
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end

    // Does the value fit in its stated size?
    if((mag >> size) != 0)  begin
      $sformat(msg, "The value for +%s doesn't fit into %0d bits.",
               inst.get_name(), size);
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end

    // Note: We only support a max of 64-bit arguments.  So 128 bits
    // is large enough to see if the conversion fits.
    if (P::is_signed)
      limit = (128'(1) << (W-1)) - (td.sign == "-" ? 0 : 1);
    else
      limit = (128'(1) << W) - 1;
    if (mag > limit) begin
      $sformat(msg, {"Argument for command line option +%s ",
                     "does not fit into the data type for this option."}, 
               inst.get_name());
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end

    // Check the sign
    if(P::is_unsigned && td.sign == "-") begin
      $sformat(msg, {"Command line option +%s is unsigned ",
                     "so it cannot have a negative value"}, 
               inst.get_name());
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end

    n = T'(mag);
    if(td.sign == "-")
      n = -n;
    // n is the final value returned through the output arg.
    return 1;
  endfunction

  //----------------------------------------------------------------------
  // str_to_uint
  //
  // Convert a string of digits in the given radix to a 128-bit
  // unsigned integer representing magnitude.  Underscores are
  // skipped.  Returns 0 if any other character is not a valid digit
  // in the radix.  The caller's digit-count check guarantees the
  // result fits in 128 bits.
  //----------------------------------------------------------------------
  static function bit str_to_uint(string digits, uint32_t radix,
                                  output uint128_t mag);
    uint32_t digit;

    mag = 0;
    foreach (digits[i]) begin
      uint32_t c = uint32_t'(digits[i]);

      // Skip underscores
      if (c == "_")
	continue;

      case(1)
	(c >= "0" && c <= "9"): digit = c - "0";
	(c >= "a" && c <= "f"): digit = c - "a" + 10;
	(c >= "A" && c <= "F"): digit = c - "A" + 10;
	default: return 0;
      endcase

      // Is the digit valid for the specified radix?
      if (digit >= radix)
	return 0;

      mag = mag * uint128_t'(radix) + uint128_t'(digit);
    end
    
    return 1;
    
  endfunction
  
endclass

//----------------------------------------------------------------------
// cl_opt_int_desc
//
// For all integer types.
//----------------------------------------------------------------------
class cl_opt_int_desc#(type T=int, type P) extends cl_opt_desc#(T);
  
  function new(string _name);
    super.new(_name);
    fmt = "%0d";
  endfunction

  virtual function bit validate_and_convert(cl_opt_instance_base inst);
    T n;
    cl_opt_instance#(T) opt_inst;
    type_container#(T) val;
    string msg;
    
    if(!$cast(opt_inst, inst)) begin
      $sformat(msg, "Cannot convert command line option +%s to %s", 
	       inst.get_name(),
	       $typename(T));
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end
    
    if(!validate_int#(T,P)::validate(inst, n)) begin
      return 0;
    end
    
    val = new();
    val.set(n);
    opt_inst.value = val;
    return 1;
    
  endfunction

endclass

//----------------------------------------------------------------------
// cl_opt_real_desc
//----------------------------------------------------------------------
class cl_opt_real_desc extends cl_opt_desc#(real);
  
  function new(string _name);
    super.new(_name);
    fmt = "%g";
  endfunction

  virtual function bit validate_and_convert(cl_opt_instance_base inst);

    type_container#(real) realval;
    cl_opt_instance#(real) opt_inst;
    string msg;

    if(!$cast(opt_inst, inst)) begin
      $sformat(msg, "Cannot convert command line option +%s to real", inst.get_name());
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end

    case(inst.token)
      TOKEN_FLOAT:
        begin
          real f = inst.td.digits.atoreal();
          if(inst.td.sign == "-")
            f = -f;
          realval = new();
          realval.set(f);
          opt_inst.value = realval;
	  return 1;
        end
      
      TOKEN_INT:
        // For an integer argument, convert it to a 64-bit int
        // and then convert that to a real.
        begin
          int64_t n;
          // Validate the integer value
          if(!validate_int#(int64_t, int64_traits)::validate(inst, n))
            return 0;
          // Convert 64-bit integer to real
          realval = new();
          realval.set($itor(n));
          opt_inst.value = realval;
	  return 1;
        end
      
      default:
        begin         
          $sformat(msg, "Command line option +%s must have a floating point value.",
                   name);
          `uvm_error(SVX_CL_MSG_ID, msg)
          return 0;
        end
    endcase

    // Not reached.
    
  endfunction

endclass

//----------------------------------------------------------------------
// cl_opt_string_desc
//----------------------------------------------------------------------
class cl_opt_string_desc extends cl_opt_desc#(string);
  
  function new(string _name);
    super.new(_name);
    fmt = "%s";
  endfunction

  virtual function bit validate_and_convert(cl_opt_instance_base inst);
    
    type_container#(string) stringval;
    cl_opt_instance#(string) opt_inst;
    string msg;

    if(!$cast(opt_inst, inst)) begin
      $sformat(msg, "Cannot convert command line option +%s to string", inst.get_name());
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end
    
    if(inst.token != TOKEN_STRING) begin
      $sformat(msg, "Command line option +%s must have a string value.", name);
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end
    stringval = new();
    stringval.set(inst.lexeme);
    opt_inst.value = stringval;
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // lex_value
  //
  // Strings are retrieved from the lexer using lex_filename.  This
  // looks at the characters on the command line a bit differently
  // than when looking for an indetifier.  Lex_filename() consumes
  // all characters up to the end of the input string (typically a
  // single option).  This allows us to grab filenames that may have
  // characters other than numbers, letters, and underbars.
  //--------------------------------------------------------------------
  virtual function token_t lex_value(lexer_core lex);
      return lex.lex_filename();
  endfunction

endclass  

//----------------------------------------------------------------------
// cl_opt_bit_desc
//----------------------------------------------------------------------
class cl_opt_bit_desc extends cl_opt_desc#(bit);
  
  function new(string _name);
    super.new(_name);
    fmt = "%b";
  endfunction

  virtual function bit validate_and_convert(cl_opt_instance_base inst);
    bit   b;
    type_container#(bit) val;
    cl_opt_instance#(bit) opt_inst;
    string msg;
    
    case(inst.token)
      TOKEN_ON:   b = 1;
      TOKEN_OFF : b = 0;
      TOKEN_INT:
        begin
          if(!validate_int#(bit, bit_traits)::validate(inst, b))
	    return 0;
        end
      default:
        begin
          $sformat(msg, "Command line option +%s must have an ON/OFF value.",
                   name);
          `uvm_error(SVX_CL_MSG_ID, msg)
          return 0;
        end
    endcase

    if(!$cast(opt_inst, inst)) begin
      $sformat(msg, "Cannot convert command line option +%s to bit", inst.get_name());
      `uvm_error(SVX_CL_MSG_ID, msg)
      return 0;
    end
    
    val = new();
    val.set(b);
    opt_inst.value = val;
    return 1;

  endfunction

  function bit is_switch();
    return 1;
  endfunction
  
  
endclass  
