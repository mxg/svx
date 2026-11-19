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

               +---------------------------------------+
               |    SystemVerilog Extension Library    |
               |                  SVX                  |
               +---------------------------------------+

                          Author: Mark Glasser

SVX has two parts: the core library and UVM utilities.

The SVX core library is an experiment in generic programming in
SystemVerilog.  It's loosely modeled on C++'s STL. Originally built in
2016, its purpose is twofold: One is to provide tools for writing
generic programs -- programs that can be easily reused; the other is
to provide building blocks for creating programs at higher levels of
abstraction -- that is, abstract away low-level details of containers.
Because SystemVerilog only partially supports multiple inheritance and
does not support function overloading and partial template
specialization many things found in STL cannot be replicated in
SystemVerilog.  However, there is still plenty of opportunity to build
generic elements. While using STL as an inspiration, SVX has its own
language-specific flavor.

The UVM utilities are a set of tools for building sophisticated UVM
testbenches.  These utilities are built on top of or along side UVM
and do not interfere with UVM itself.  Many of the utilities are
written in a generic style and rely on the core library.

This version has been ported to Verilator, an increasingly important
open source SystemVerilog compiler and simulator.  Recently, through
the work of a lot of smart and talented engineers, Verilator is now
able to run UVM code.  By porting SVX to Verilator, we've demonstrated
that Verilator supports sophisticated parameterized classes beyond
what UVM uses.

PACKAGE CONTENTS
----------------

The SVX library distribution is organized into a set of directories.

-- top-level --

core     - The core library

uvm     - uvm utilities

make    - a common makefile used in building all the tests and
          examples.
	  
doc     - contains the documentation PDF files as well as the
          documentation source.

-- Core Library --

core/src      - contains the core library source code.

core/test     - contains a comprehensive test suite.

core/examples - contains use model examples.

core apps     - A collection of SystemVerilog utilities built with
                SVX.

-- UVM utilities

uvm/src       - contains the source for the UVM utilities.

uvm/examples  - contains a collection of usage examples of the UVM
                utilities.

test          - contains a test suite for the UVM utilities.

INSTALLATION
------------

Simply unpack the tar kit in a convenient location.  Nothing else is
required to install the package.

BUILDING
--------

To use the SVX library in your own work You will have to compile and
link the SVX library along with other SystemVerilog code in the usual

location where you installed the SVX library.  E.g.,

% setenv SVX_HOME /home/tools/svx-2.1.3-beta

In your make file add the svx and svx_uvm_pkg package files to the
list of source files:

SRC += ${SVX_HOME}/core/src/svx.sv ${SVX_HOME}/uvm/src/svx_uvm_pkg.sv

Make sure that the SVX source directories is in your include path.

INC += +incdir+${SVX_HOME}/core/src +incdir+${SVX_HOME}/uvm/src

Because Verilator compiles SystemVerilog into C++, building any
Verilator code requires a C++ compiler.  For our development and
testing we used C++-17 with the gcc 15.2.0 compiler.

USAGE
-----

The library has two package files, one for each major component of
the library. Both must be imported to use all the features of SVX.

import svx::*
import svx_uvm_pkg::*;
`include "svx_macros.svh"

You can use the SVX core library without the UVM utilities.  To do so,
just remove the "import svx_uvm_pkg::*" line.  The UVM utilities have
a dependency on the core library, so you must import the core library
to use the UVM utilities.

This will provide access to all of the SVX library features in your
SystemVerilog programs.

DOCUMENTATION
-------------

The documentation for the SystemVerilog Extension library is delivered
as three PDF files in the doc directory.

  * svx_catalog_src.pdf --A catalog of all of the elements in the core
    library and UVM utilities.

  * svx_catalog_apps.pdf -- A catalog of the apps in the core library.

  * svx_catalog_examples.pdf -- A catalog of examples that illustrate
    how to use the core library and the UVM utilities.

TEST SUITE
----------

The SVX library is delivered with a comprehensive test suite and a set
of working examples.  The suite lives in the directory test and the
examples are in the directory examples.  The test suite is built using
SVUnit, an open source testing framework built by Bryan Morris and
Neil Johnson and now maintained by Tudor Timisescu (aka the
Verification Gentleman).  You can download a copy from Github from the
repository svunit/svunit.


To run the tests and examples, simply execute the makefile: 

% make

To remove all of files generated during the execution of the test suite,
type

% make clean

The create.sh script builds the individual test suites and the test
runner for the test suite.  If you add tests update create.sh to include
your new unit tests and run the script to re-build the testing
infrastructure.  Consult the SVUnit documentation for details on how
test suites are constructed.


--------------------------------------------------------------------------------
