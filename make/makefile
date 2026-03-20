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

#------------------------------------------------------------
# Command Verbosity

#V               = @
V               =

#------------------------------------------------------------
# Tools

VERILATOR       := /usr/local/bin/verilator
SVUNIT_INSTALL	?= /home/mark-glasser/projects/svunit

CXX		:= /usr/bin/c++
CXXFLAGS        := -std=c++17 -O2

#------------------------------------------------------------
# Source

TOP		?= .

SVX_SRC		:= ${TOP}/src/svx.sv
SVX_INC		:= +incdir+${TOP}/src
APPS		:= ${TOP}/apps

APPS_SRC	:= ${wildcard ${APPS}/mem/*.sv}             \
                   ${wildcard ${APPS}/mem_map/*.sv}
APPS_INC	:= +incdir+${APPS}/mem                      \
                   +incdir+${APPS}/mem_map

SV_SRC		:= ${SVX_SRC} ${APPS_SRC} ${SV_SRC}

SV_INC		+= +incdir+.              \
                   ${SVX_INC}             \
                   ${APPS_INC}

SC_SRC	       +=
SC_INC	       +=

C_SRC	       += main.cpp
C_INC	       +=

SRC	       := ${SV_SRC} ${SC_SRC} ${C_SRC}
INC	       := ${SV_INC} ${SC_INC} ${C_INC}

#------------------------------------------------------------
# Configuration

TOP_MODULE      ?= top

# Output / build paths
BUILD_DIR       := build_dir
SIM_BIN         := $(BUILD_DIR)/V$(TOP_MODULE)

BUILDLOG	:= build.log
RUNLOG		:= run.log

#------------------------------------------------------------
# Commands
 
COMPILE_OPTS	:= --cc --exe --build --sv -Mdir $(BUILD_DIR)
COMPILE_OPTS	+= --top ${TOP_MODULE}
COMPILE_OPTS 	+= -Wall
# turn off pedantry
COMPILE_OPTS	+= --Wno-DECLFILENAME -Wno-VARHIDDEN -Wno-UNUSEDSIGNAL -Wno-UNDRIVEN
COMPILE_OPTS	+= --timing
COMPILE_OPTS	+= --autoflush

COMPILE_CMD    := ${VERILATOR} ${COMPILE_OPTS} ${INC} ${SRC}

RUN_OPTS       := +UVM_NO_RELNOTES +UVM_TESTNAME=${TEST} 

RUN_CMD	       := ${SIM_BIN} ${RUN_OPTS}

#------------------------------------------------------------
# Rules

all: clean build run
 
build: ${SRC}
	@echo "[BUILD]" `pwd`
	${V}mkdir -p $(BUILD_DIR)	
	${V}echo ${COMPILE_CMD} > ${BUILDLOG} 2>&1
	${V}${COMPILE_CMD} >> ${BUILDLOG} 2>&1

run:
	@echo "[RUN]" `pwd`
	${V}echo ${RUN_CMD} > ${RUNLOG} 2>&1
	${V}${RUN_CMD} >> ${RUNLOG} 2>&1
 
clean:
	@echo "[CLEAN]" `pwd`
	${V}rm -f ${BUILDLOG} ${RUNLOG}
	${V}rm -f xx* *~ #*
	${V}rm -rf $(BUILD_DIR) *.vcd *.fst
	${V}rm -f *.xml
 
