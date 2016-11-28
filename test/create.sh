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

# create containers test suite
echo "*** Create containters test suite"
create_testsuite.pl -add containers/container_unit_test.sv            \
                    -add containers/type_handle_unit_test.sv          \
                    -add containers/vector_unit_test.sv               \
                    -add containers/map_unit_test.sv                  \
                    -add containers/queue_unit_test.sv                \
                    -add containers/deque_unit_test.sv                \
                    -add containers/stack_unit_test.sv                \
                    -add containers/sorter_unit_test.sv               \
                    -add containers/dictionary_unit_test.sv           \
                    -out containers/containers_testsuite.sv           \
                    -overwrite

# create iterators test suite
echo
echo "*** Create iterators test suite"
create_testsuite.pl -add iterators/list_iterators_unit_test.sv        \
                    -add iterators/map_iterators_unit_test.sv         \
                    -add iterators/permute_iterators_unit_test.sv     \
                    -out iterators/iterators_testsuite.sv             \
                    -overwrite

#create linked test suite
echo
echo "*** Create linked test suite"
create_testsuite.pl -add linked/node_unit_test.sv                     \
                    -add linked/tree_unit_test.sv                     \
                    -add linked/tree_iterator_unit_test.sv            \
                    -out linked/linked_testsuite.sv                   \
                    -overwrite

# create lexer test suite
echo
echo "*** Create lexer test suite"
create_testsuite.pl -add lexer/ctypes_unit_test.sv                    \
                    -add lexer/lexer_core_unit_test.sv                \
                    -out lexer/lexer_testsuite.sv                     \
                    -overwrite

# create apps test suite
echo
echo "*** Create apps test suite"
create_testsuite.pl -add apps/mem_unit_test.sv                        \
                    -add apps/mem_map_unit_test.sv                    \
                    -add apps/mem_bounded_unit_test.sv                \
                    -out apps/apps_testsuite.sv                       \
                    -overwrite

# create behaviors test suite
echo
echo "*** Create behaviors test suite"
create_testsuite.pl -add behaviors/behavior_unit_test.sv              \
                    -add behaviors/concurrency_unit_test.sv           \
                    -add behaviors/mapper_unit_test.sv                \
                    -out behaviors/behaviors_testsuite.sv             \
                    -overwrite

# create testrunner
echo
echo "*** Create top-level test runner"
create_testrunner.pl -add containers/containers_testsuite.sv          \
                     -add iterators/iterators_testsuite.sv            \
                     -add linked/linked_testsuite.sv                  \
                     -add lexer/lexer_testsuite.sv                    \
                     -add apps/apps_testsuite.sv                      \
                     -add behaviors/behaviors_testsuite.sv            \
                     -out testrunner.sv                               \
                     -overwrite
