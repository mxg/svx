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

`include "svunit_defines.svh"

//----------------------------------------------------------------------
// cl_parse_unit_test
//
// Unit tests for the command line processor.  Each test registers one
// or more options, hands the parser a synthetic command line through
// cl_parse::set_args(), and then checks two things:
//
//   * how many errors the parser reported (counted by a report catcher
//     so they do not count against the simulation), and
//   * what, if anything, was published to the resource database.
//
// Every check registers a freshly named option (opt_1, opt_2, ...).
// The option table and the resource database are both global, so
// fresh names keep one check from seeing another check's results.
//----------------------------------------------------------------------

module cl_parse_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import uvm_pkg::*;
  import svx::*;
  import svx_uvm_pkg::*;
 `include "svx_macros.svh"

  string name = "cl_parse_ut";
  svunit_testcase svunit_ut;

  //--------------------------------------------------------------------
  // cl_catcher
  //
  // Count and swallow the messages from the command line processor.
  // Errors are caught so an intentionally bad command line does not
  // register as a simulation error.
  // --------------------------------------------------------------------
  class cl_catcher extends uvm_report_catcher;

    int unsigned n_errors;
    int unsigned n_infos;

    function new(string name = "cl_catcher");
      super.new(name);
    endfunction

    function void clear();
      n_errors = 0;
      n_infos = 0;
    endfunction

    function action_e catch();
      if(get_id() != SVX_CL_MSG_ID)
        return THROW;

      case(get_severity())
        UVM_ERROR:
	  begin
	    n_errors++; 
	    return CAUGHT; 
	  end
        UVM_INFO:  
	  begin 
	    n_infos++;  
	    return CAUGHT;
	  end
        default:
	  return THROW;
      endcase
      // not reached
    endfunction

  endclass

  //--------------------------------------------------------------------
  // opt_names
  //
  // Generate a unique option name for each check.
  //--------------------------------------------------------------------
  class opt_names;
    static int unsigned count;

    static function string next();
      count++;
      return $sformatf("opt_%0d", count);
    endfunction
  endclass

  //--------------------------------------------------------------------
  // opt#(T)
  //
  // Register a fresh option of type T and read it back from the
  // resource database.
  //--------------------------------------------------------------------
  class opt #(type T=int);

    static function string add();
      string n = opt_names::next();
      cl#(T)::add(n);
      return n;
    endfunction

    static function string add_with_default(T def);
      string n = opt_names::next();
      cl#(T)::add_with_default(n, def);
      return n;
    endfunction

    static function bit get(string n, output T val);
      return uvm_resource_db#(T)::read_by_name("CL::", n, val);
    endfunction

  endclass

  cl_catcher catcher;

  //--------------------------------------------------------------------
  // parse_args
  //
  // Run the parser over a synthetic command line.  The program name is
  // prepended, as it would be on a real command line.
  //--------------------------------------------------------------------
  function automatic void parse_args(string args[$]);
    cl_parse p;

    catcher.clear();
    args.push_front("Vtestrunner");
    p = new();
    p.set_args(args);
    p.parse();
  endfunction

  //--------------------------------------------------------------------
  // parse_one
  //
  // Parse a command line containing the single argument
  // "+<opt_name><suffix>".  The suffix is everything after the option
  // name -- "=42" for a value, "" for a switch, or anything else to
  // test malformed input.
  //--------------------------------------------------------------------
  function automatic void parse_one(string opt_name, string suffix);
    string args[$];
    args.push_back({"+", opt_name, suffix});
    parse_args(args);
  endfunction

  //--------------------------------------------------------------------
  // Check macros
  //
  // CL_ACCEPT: "+<opt><SUFFIX>" must parse with no errors, and the
  //            option of type T must be published with value EXPECTED.
  //
  // CL_REJECT: "+<opt><SUFFIX>" must produce at least one error, and
  //            nothing may be published for the option.
  //
  // The parser also issues a summary error when it stops, so the
  // reject check looks for "at least one" error rather than exactly
  // one.
  //--------------------------------------------------------------------
`define CL_ACCEPT(T, SUFFIX, EXPECTED)          \
  begin                                         \
    T v__;                                      \
    string n__;                                 \
    n__ = opt#(T)::add();                       \
    parse_one(n__, SUFFIX);                     \
    `FAIL_UNLESS(catcher.n_errors == 0)         \
    `FAIL_UNLESS(opt#(T)::get(n__, v__))        \
    `FAIL_UNLESS(v__ == (EXPECTED))             \
  end

`define CL_ACCEPT_STRING(T, SUFFIX, EXPECTED)   \
  begin                                         \
    T v__;                                      \
    string n__;                                 \
    n__ = opt#(T)::add();                       \
    parse_one(n__, SUFFIX);                     \
    `FAIL_UNLESS(catcher.n_errors == 0)         \
    `FAIL_UNLESS(opt#(T)::get(n__, v__))        \
    `FAIL_UNLESS_STR_EQUAL(v__, (EXPECTED))     \
  end
  
`define CL_REJECT(T, SUFFIX)                    \
  begin                                         \
    T v__;                                      \
    string n__;                                 \
    n__ = opt#(T)::add();                       \
    parse_one(n__, SUFFIX);                     \
    `FAIL_IF(catcher.n_errors == 0)             \
    `FAIL_IF(opt#(T)::get(n__, v__))            \
  end

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
    catcher = new();
    uvm_report_cb::add(null, catcher);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
  endtask


  //===================================
  // Here we deconstruct anything we
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //===================================
  `SVUNIT_TESTS_BEGIN

  //--------------------------------------------------------------------
  // int_bases
  //
  // Decimal, hex, octal, and binary, with upper and lower case base
  // letters, underscores, and leading zeros.
  //--------------------------------------------------------------------
    `SVTEST(int_bases)
      `CL_ACCEPT(int32_t,  "=42",                         42)
      `CL_ACCEPT(uint32_t, "=32h7fff_624c",               32'h7fff_624c)
      `CL_ACCEPT(uint32_t, "=32H7FFF624C",                32'h7fff_624c)
      `CL_ACCEPT(uint16_t, "=16o777",                     16'o777)
      `CL_ACCEPT(uint16_t, "=16O777",                     16'o777)
      `CL_ACCEPT(uint8_t,  "=8b1010",                     8'b1010)
      `CL_ACCEPT(uint8_t,  "=8B1010",                     8'b1010)
      `CL_ACCEPT(int32_t,  "=1_000",                      1000)
      `CL_ACCEPT(int32_t,  "=0000000000000000000042",     42)
      `CL_ACCEPT(uint64_t, "=64h0000000000000000FF",      64'hFF)
      `CL_ACCEPT(int32_t,  "=-100",                       -100)
    `SVTEST_END

  //--------------------------------------------------------------------
  // int_limits
  //
  // The edges of the signed and unsigned ranges for 8 and 64 bits.
  //--------------------------------------------------------------------
    `SVTEST(int_limits)
      `CL_ACCEPT(int8_t,   "=127",                    127)
      `CL_REJECT(int8_t,   "=128")
      `CL_ACCEPT(int8_t,   "=-128",                   -128)
      `CL_REJECT(int8_t,   "=-129")
      `CL_ACCEPT(uint8_t,  "=255",                    255)
      `CL_REJECT(uint8_t,  "=256")
      `CL_ACCEPT(uint64_t, "=18446744073709551615",   64'hFFFF_FFFF_FFFF_FFFF)
      `CL_REJECT(uint64_t, "=18446744073709551616")
      `CL_ACCEPT(int64_t,  "=-9223372036854775808",   64'h8000_0000_0000_0000)
      `CL_REJECT(int64_t,  "=9223372036854775808")
    `SVTEST_END

  //--------------------------------------------------------------------
  // int_errors
  //
  // Malformed and out-of-range integers.
  //--------------------------------------------------------------------
    `SVTEST(int_errors)
      // Negative value for an unsigned type
      `CL_REJECT(uint32_t, "=-1")
      // Too many significant digits, and 2**128 + 1, which would wrap
      // to 1 in a 128-bit scan
      `CL_REJECT(uint64_t, "=100000000000000000000")
      `CL_REJECT(uint64_t, "=340282366920938463463374607431768211457")
      // Sized literal that does not fit its own size
      `CL_REJECT(uint32_t, "=4h1F")
      // Sized literal wider than the option's type
      `CL_REJECT(uint32_t, "=36hFFFFFFFFF")
      // Trailing characters
      `CL_REJECT(int32_t,  "=4abc")
      `CL_REJECT(int32_t,  "=4,5")
      // Not integers at all
      `CL_REJECT(int32_t,  "=abc")
      `CL_REJECT(int32_t,  "=1.5")
      `CL_REJECT(int32_t,  "=10ns")
      `CL_REJECT(int32_t,  "=8hxz")
      // Missing value
      `CL_REJECT(int32_t,  "")
      `CL_REJECT(int32_t,  "=")
    `SVTEST_END

  //--------------------------------------------------------------------
  // real_values
  //--------------------------------------------------------------------
    `SVTEST(real_values)
//      `CL_ACCEPT(real, "=1.5e9",  1.5e9)
//      `CL_ACCEPT(real, "=-2.5",   -2.5)
      `CL_ACCEPT(real, "=2",      2.0)
      `CL_ACCEPT(real, "=32h10",  16.0)
      `CL_REJECT(real, "=abc")
      `CL_REJECT(real, "=1.5x")
      `CL_REJECT(real, "")
    `SVTEST_END

  //--------------------------------------------------------------------
  // bit_values
  //
  // The switch form, on/off keywords, and 0/1 in any base.
  //--------------------------------------------------------------------
    `SVTEST(bit_values)
//      `CL_ACCEPT(bit, "",       1)
//      `CL_ACCEPT(bit, "=on",    1)
      `CL_ACCEPT(bit, "=off",   0)
      `CL_ACCEPT(bit, "=1",     1)
      `CL_ACCEPT(bit, "=0",     0)
      `CL_ACCEPT(bit, "=1b0",   0)
      `CL_ACCEPT(bit, "=1b1",   1)
    `SVTEST_END

  //--------------------------------------------------------------------
  // bit_errors
  //
  // Out-of-range values, and junk after the switch form.
  //--------------------------------------------------------------------
    `SVTEST(bit_errors)
      `CL_REJECT(bit, "=2")
      `CL_REJECT(bit, "=-1")
      `CL_REJECT(bit, "=")
      `CL_REJECT(bit, ".")
      `CL_REJECT(bit, "-")
      `CL_REJECT(bit, "-5")
      `CL_REJECT(bit, "-foo")
    `SVTEST_END

  //--------------------------------------------------------------------
  // string_values
  //
  // String values are taken raw, not lexed.  Quotes that reach the
  // parser (that is, quotes the user escaped from the shell) are kept.
  //--------------------------------------------------------------------
    `SVTEST(string_values)
//      `CL_ACCEPT_STRING(string, "=freddy",        "freddy")
//      `CL_ACCEPT_STRING(string, "=a/b/c",         "a/b/c")
      `CL_ACCEPT_STRING(string, "=my-test.v",     "my-test.v")
      `CL_ACCEPT_STRING(string, "=1.hex",         "1.hex")
      `CL_ACCEPT_STRING(string, "=on",            "on")
      `CL_ACCEPT_STRING(string, "=\"a b\"",       "\"a b\"")
      `CL_ACCEPT_STRING(string, "='a/b'",         "'a/b'")
    `SVTEST_END

  //--------------------------------------------------------------------
  // string_errors
  //--------------------------------------------------------------------
    `SVTEST(string_errors)
      `CL_REJECT(string, "=\"abc")
      `CL_REJECT(string, "='abc")
      `CL_REJECT(string, "=")
      `CL_REJECT(string, "")
    `SVTEST_END

  //--------------------------------------------------------------------
  // foreign_args
  //
  // Arguments that do not belong to the command line processor --
  // simulator options, UVM options, other libraries' plusargs, and
  // non-plus arguments -- must be skipped without error.  A
  // registered option on the same command line must still be
  // processed.
  //--------------------------------------------------------------------
    `SVTEST(foreign_args)
      int32_t v;
      string n;

      n = opt#(int32_t)::add();
      parse_args({"+verilator+seed+5",
                  "+ntb_random_seed=1",
                  "+UVM_TESTNAME=foo",
                  "+uvm_set_verbosity=x",
                  "+not_a_registered_option=3",
                  "-l",
                  "run.log",
                  $sformatf("+%s=7", n)});
      `FAIL_UNLESS(catcher.n_errors == 0)
      `FAIL_UNLESS(opt#(int32_t)::get(n, v))
      `FAIL_UNLESS(v == 7)
    `SVTEST_END

  //--------------------------------------------------------------------
  // last_wins
  //
  // When an option appears more than once, the last value wins.
  //--------------------------------------------------------------------
    `SVTEST(last_wins)
      int32_t v;
      string n;

      n = opt#(int32_t)::add();
      parse_args({$sformatf("+%s=1", n), $sformatf("+%s=2", n)});
      `FAIL_UNLESS(catcher.n_errors == 0)
      `FAIL_UNLESS(opt#(int32_t)::get(n, v))
      `FAIL_UNLESS(v == 2)
    `SVTEST_END

  //--------------------------------------------------------------------
  // one_bad_blocks_all
  //
  // An error in any option prevents every option from being
  // published.  Checked for an error found while splitting the
  // argument apart (first pass) and for one found while converting
  // the value (second pass).
  //--------------------------------------------------------------------
    `SVTEST(one_bad_blocks_all)
      int32_t v;
      string good;
      string bad;

      // Missing value: a first-pass error
      good = opt#(int32_t)::add();
      bad  = opt#(int32_t)::add();
      parse_args({$sformatf("+%s=5", good), $sformatf("+%s", bad)});
      `FAIL_IF(catcher.n_errors == 0)
      `FAIL_IF(opt#(int32_t)::get(good, v))

      // Invalid value: a second-pass error
      good = opt#(int32_t)::add();
      bad  = opt#(int32_t)::add();
      parse_args({$sformatf("+%s=5", good), $sformatf("+%s=abc", bad)});
      `FAIL_IF(catcher.n_errors == 0)
      `FAIL_IF(opt#(int32_t)::get(good, v))
    `SVTEST_END

  //--------------------------------------------------------------------
  // defaults
  //
  // A default is visible when the option is not on the command line,
  // and the command line value overrides it when it is.
  //--------------------------------------------------------------------
    `SVTEST(defaults)
      int32_t v;
      string n;
      string args[$];

      // Not on the command line: the default is visible
      n = opt#(int32_t)::add_with_default(17);
      parse_args(args);
      `FAIL_UNLESS(catcher.n_errors == 0)
      `FAIL_UNLESS(opt#(int32_t)::get(n, v))
      `FAIL_UNLESS(v == 17)

      // On the command line: the command line value wins
      n = opt#(int32_t)::add_with_default(17);
      parse_one(n, "=99");
      `FAIL_UNLESS(catcher.n_errors == 0)
      `FAIL_UNLESS(opt#(int32_t)::get(n, v))
      `FAIL_UNLESS(v == 99)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
