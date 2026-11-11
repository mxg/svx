Command Line Processor
----------------------

The Command line processor traverses the list of command line
arguments provided by uvm_cmdline_processor.  It parses each argument,
looks for an associated value, and puts the option into the resource
database.

The set of available command line options is stored in a table managed
by the class cl.  Cl has two static functions for adding new options
to the table -- add() and add_with_default.  Add() adds a new option
to the table and add_with_default() adds a new option along with a
default value.  cl is a parameterized class.  The parameter represents
the type of the option being added to the table.  For example,

  cl#(int)::add("xyz");

adds a new option to the table named "xyz" and has a type of int. The
command line options are _plusargs_, meaning that the command line
processor identifies them by their leading "+" character.  The plus
sign does not need to be supplied as part of the name for cl::add()
and cl::add_with_default().

You can print out the command option table with the following call:

  cl_mgr::dump();

To execute the parsing operation you need to get a handle to the
parser object and call parse().  Get() retrieves the singleton handle
of cl_parse.

  cl_parse clp = cl_parse::get();
  clp.parse();

Parse() parses each plusarg on the command line and validates it
against the table of options.  After all the options and their
arguments have been validated then they are put into the resource
database using the scope "CL::".  E.g.,

  uvm_resource_db#(T)::set("CL::*", name, value);

You can retrieve command line options from the database using the
uvm_resource_db interface.

  int size;
  uvm_resource_db#(int)::read_by_name("CL::", "size", size, this);

The synthetic scope "CL::" ensures that command line options do not
conflict with other items in the resource database.

Populating the option table and parsing the command line should be
done as early as possible to ensure that all the phases have access to
the option values.  We recommend that this be done _before_ calling
run_test().  E.g.,

  module top;

    function static void populate();
      cl_parse clp = cl_parse::get();
      // Add new options to the command line option table.
      cl#(uint32_t)::add_with_default("size", 4);
      ...
      clp.parse();  
    endfunction

    initial begin
      populate();
      run_test();
    end

  endmodule

  The command line parser supports a wide range of scalar and string types:
  
      string
      real
      bit
      byte
      shortint
      longint
      int
      byte unsigned
      shortint unsigned
      int unsigned
      longint unsigned
      int8_t    (type alias for byte signed)
      int16_t   (type alias for shortint)
      int32_t   (type alias for int)
      int64_t   (type alias for longint)
      uint8_t   (type alias for byte unsigned)
      uint16_t  (type alias for shortint unsigned)
      uint32_t  (type alias for int unsigned)
      uint64_t  (type alias for longint unsigned)

On the command line the options can take one of two forms: +<option>
or +<option>=<value>.  In the first form the option represents a
_switch_ whose type is bit.  Without a value the switch is turned on.
For example,

  +x_mode

Turns on the switch x_mode, i.e., sets its value to 1. This is
semantically equivalent to the following command lines:

  +x_mode=1
  +x_mode=ON
  +x_mode=on
  +x_mode=TRUE
  +x_mode=true
  +x_mode=YES
  +x_mode=yes

Similarly, a switch can be turned off with these command lines:

  +x_mode=0
  +x_mode=OFF
  +x_mode=off
  +x_mode=FALSE
  +x_mode=false
  +x_mode=NO
  +x_mode-no

In the second form, +<option>=<value> there cannot be any spaces on
either side of the equal sign.

  +size = 8  !!ILLEGAL!!
  +size=8    Legal

Also, the type of the value must match the type defined when the
option was added to the option table. E.g., let's add "bias" as byte
typed option.

  cl#(byte)::add("bias");

On the command line we can put

  +bias=10

However, a numeric value that does not fit into a byte is illegal:

  +bias=2000  !!ILLEGAL!!

Even though it is syntactically correct, 2000 does not fit into 8 bits
and will be rejected by the parser.

Numeric values can be sized and can be specified in different bases,
much like in SystemVerilog.  Underscores are also lega. E.g.,

   32hf77_7003c
   12b011_000_111_010
   4o6263

Note that there are no ticks in the number.  Command shells use ticks
(single quotes) for their own purposes, so we avoided using them in
command line values. As with unsized values, the value must fit into
the data type specified for the option.

                              * * * * *
