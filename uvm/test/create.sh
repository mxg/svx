#!/bin/sh
#=======================================================================
#
#               .oooooo..o oooooo     oooo ooooooo  ooooo     
#              d8P'    `Y8  `888.     .8'   `8888    d8'      
#              Y88bo.        `888.   .8'      Y888..8P        
#               `"Y8888o.     `888. .8'        `8888'         
#                   `"Y88b     `888.8'        .8PY888.        
#              oo     .d8P      `888'        d8'  `888b       
#              8""88888P'        `8'       o888o  o88888o
#
#                  SystemVerilog Extension Library
#
#
# Copyright 2016 NVIDIA Corporation
# Copyright 2026 Mark Glasser
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#=======================================================================


#######################################################################
# testsuite creation
#
# Create a set of test suites composed of unit tests.  Then compose the
# test suites into a single testrunner.
#######################################################################

# create command line processor test suite
echo
echo "*** Create command line processor test suite"
create_testsuite.pl -add cl/cl_parse_unit_test.sv                     \
                    -out cl/cl_testsuite.sv                           \
                    -overwrite

# create agreement test suite
echo
echo "*** Create agreement test suite"
create_testsuite.pl -add agreement/agreement_unit_test.sv             \
                    -out agreement/agreement_testsuite.sv             \
                    -overwrite

# create sequencer aggregator test suite
echo
echo "*** Create sequencer aggregator test suite"
create_testsuite.pl -add sqr_aggregator/sqr_aggregator_unit_test.sv   \
                    -out sqr_aggregator/sqr_aggregator_testsuite.sv   \
                    -overwrite

# create cached resource test suite
echo
echo "*** Create cached resource test suite"
create_testsuite.pl -add cached_resource/cached_resource_unit_test.sv \
                    -out cached_resource/cached_resource_testsuite.sv \
                    -overwrite

# create plugins test suite
echo
echo "*** Create plugins test suite"
create_testsuite.pl -add plugins/plugins_unit_test.sv                 \
                    -out plugins/plugins_testsuite.sv                 \
                    -overwrite

# create testrunner
echo
echo "*** Create top-level test runner"
create_testrunner.pl -add cl/cl_testsuite.sv                          \
                     -add agreement/agreement_testsuite.sv            \
                     -add sqr_aggregator/sqr_aggregator_testsuite.sv  \
                     -add cached_resource/cached_resource_testsuite.sv \
                     -add plugins/plugins_testsuite.sv                \
                     -out testrunner.sv                               \
                     -overwrite
