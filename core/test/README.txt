======================================================================

               .oooooo..o oooooo     oooo ooooooo  ooooo     
              d8P'    `Y8  `888.     .8'   `8888    d8'      
              Y88bo.        `888.   .8'      Y888..8P        
               `"Y8888o.     `888. .8'        `8888'         
                   `"Y88b     `888.8'        .8PY888.        
              oo     .d8P      `888'        d8'  `888b       
              8""88888P'        `8'       o888o  o88888o

                  SystemVerilog Extension Library


 Copyright 2016 NVIDIA Corporation

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 implied.  See the License for the specific language governing
 permissions and limitations under the License.
======================================================================

			  T E S T   S U I T E

----------------------------------------------------------------------

The SVX test suite is based on SVUnit 3.6.  You can find out more about
SVUnit and download kits at:

http://www.agilesoc.com/open-source-projects/svunit/

To run the tests you must set the environment variable SVUNIT_INSTALL to
point to your installation of SVUnit.  Also set SVX_HOME to point to
your installation of the SVX library.

%make

will compiile and run all of the tests in the suite.

----------------------------------------------------------------------

-> Add a new test in an existing test file

* Put the new test code between the `SVTEST() and `SVTEST_END macros.
  Be sure to assign the new test a unique name in the `SVTEST macro.

* Tests must all be self-checking.  Each must determine its own
  pass/fail status.  SVUnit has macros for doing this.  Consult the
  SVUnit documentation and examples.

----------------------------------------------------------------------

-> Add a new unit test file

* Create a new unit test file with the suffix _unit_test.sv.  We
  recommend that you use the script create_unit_test.pl that is part of
  the SVUnit kit.

* Edit the file to add your tests.  We have found that things work best
  if you edit the header so it looks similar to the following.  Of
  course use a value for string_name that is appropriate to your tests.

    module container_unit_test;
      import svunit_pkg::svunit_testcase;

      // The library we are testing
      import svx::*;
      `include "svx_macros.svh"

      string name = "container_ut";
      svunit_testcase svunit_ut;

* Add the new file to the create.sh script in the appropriate test
  runner.

----------------------------------------------------------------------

-> Add a new test category

* Create a new directory under test

* Create one or more test suite files using the instructions from the
  previous section.

* Create a new test runner. Use the SVUnit script create_testrunner.pl

* Add the test runner to the create.sh script

    - invoke create_testsuite.pl
    - use one or more -add command line options to add the individual
      unit test files
    - use the -out option to create the testsuite with the suffix
      _testsuite.sv

* Use the existing create.sh as an example of how to add new tests and
  testsuites.

----------------------------------------------------------------------



