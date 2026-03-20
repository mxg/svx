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

TOP		= ..
TOP_MODULE	= testrunner

SVUNIT_SRC	:= ${SVUNIT_INSTALL}/svunit_base/svunit_pkg.sv
SVUNIT_INC	:= +incdir+${SVUNIT_INSTALL}/svunit_base
UNIT_TESTS      := ${wildcard */*_unit_test.sv}
TESTSUITES      := ${wildcard */*_testsuite.sv}

SV_SRC		:= test_utils.sv                             \
                   ${SVUNIT_SRC}                             \
                   ${UNIT_TESTS}                             \
                   ${TESTSUITES}                             \
                   testrunner.sv

SV_INC		:= +incdir+.                                 \
                   ${SVUNIT_INC}                             \

include ${TOP}/make/makefile
