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

#------------------------------------------------------------
# Command Verbosity

V               = @
#V               =

MAKE	:= /usr/bin/make -s

.PHONY: core uvm build run clean

all: core uvm

core:
	${V}cd core; ${MAKE}

uvm:
	${V}cd uvm; ${MAKE}

build:
	${V}cd core; ${MAKE} build
	${V}cd uvm; ${MAKE} build

run:
	${V}cd core; ${MAKE} run
	${V}cd uvm; ${MAKE} run

clean:
	${V}cd core; ${MAKE} clean
	${V}cd uvm; ${MAKE} clean
