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

               +---------------------------------------+
               |    SystemVerilog Extension Library    |
               |                  SVX                  |
               +---------------------------------------+

                          Author: Mark Glasser
                       email: mglasser@nvidia.com

The SystemVerilog Extension library is a library of utilities that
extend the functionality of SystemVerilog.  The utilities include data
structure and process management facilities that enhance the
capabilities already available in SystemVerilog, making it easier to
write and debug compled programs.

PACKAGE CONTENTS
----------------

The SVX library distribution is organized into a set of directories

src      - contains the library source code

doc      - contains the documentation PDF files as well as the
           documentation source.

test     - contains a comprehensive test suite

examples - contains use model examples

apps     - A collection of SystemVerilog utilities that are built using SVX.


INSTALLATION
------------

Simply unpack the tar kit in a convenient location.  Nothing else is
required to install the package.


COMPILING
---------

To use the SVX library in your own work You will have to compile and
link the SVX library along with other SystemVerilog code in the usual
way.  Create an environment variable SVX_HOME which points to the
location where you installed the SVX library.  E.g

% setenv SVX_HOME /home/tools/svx-1.0.0

In your make file add the svx package file to the list of source files

SRC += ${SVX_HOME}/src/svx.sv

Make sure that the SVX source directory is in your include path.

INC += +incdir+${SVX_HOME}/src


USAGE
-----

To use the library import the SVX package and include the file of macro
definitions in your SystemVerilog source.  E.g.

import svx::*;
`include "svx_macros.svh"

This will provide access to all of the SVX library features in your
SystemVerilog programs.


DOCUMENTATION
-------------

The documentation for the SystemVerilog Extension library is delivered
as a single PDF file, doc/svx.pdf.

The documentation was written using LaTeX, a text-based document markup
language, and dot, a text-based language for describing graphs.  A
Makefile is included in the doc directory for re-building the PDF.

To build the documentation, cd to the doc directory and run the
Makefile.

% make

To remove all of the generated files type

% make clean

To remove all the generated files, leaving the final PDF file(s), type

% make dist_clean

You may have to adjust the make file to account for the locations of
latex, dot, and related programs in your environment.


TEST SUITE
----------

The SVX library is delivered with a comprehensive test suite.  The suite
lives in the test directory.  The suite is built using svunit, an open
source testing framework built by Bryan Morris and Neil Johnson.  You
can download a copy from SourceForge at sourceforge.net/projects/svunit.

To run the test suite, simply execute the makefile

% make

To remove all of files generated during the execution of the test suite,
type

% make clean

The create.sh script builds the individual test suites and the test
runner for the test suite.  If you add tests update create.sh to include
your new unit tests and run the script to re-build the testing
infrastructure.  Consult the svunit documentation for details on how
test suites are constructed.
