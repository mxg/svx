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

V               = @
#V               =

#------------------------------------------------------------
# Tools

VERILATOR       := /usr/local/bin/verilator
SVUNIT_INSTALL	?= /home/mark-glasser/projects/svunit
UVM_HOME	:= /home/mark-glasser/projects/uvm/1800.2-2020.3.2

CXX		:= /usr/bin/c++
CXXFLAGS        := -std=c++17 -O2

#------------------------------------------------------------
# Configuration

TOP_MODULE      ?= top

# Output / build paths
BUILD_DIR       := build_dir
SIM_BIN         := $(BUILD_DIR)/V$(TOP_MODULE)

BUILDLOG	:= build.log
RUNLOG		:= run.log

#------------------------------------------------------------
# Source

TOP		?= .

SVX_SRC		:= ${TOP}/core/src/svx.sv
SVX_INC		:= +incdir+${TOP}/core/src \
		   +incdir+${TOP}/core/src/lexer
APPS		:= ${TOP}/core/apps

APPS_SRC	:= ${wildcard ${APPS}/mem/*.sv}             \
                   ${wildcard ${APPS}/mem_map/*.sv}         \
                   ${wildcard ${APPS}/pri_queue/*.sv}       \
                   ${wildcard ${APPS}/clk_gen/*.sv}         \
                   ${wildcard ${APPS}/cl/*.sv}
APPS_INC	:= +incdir+${APPS}/mem                      \
                   +incdir+${APPS}/mem_map                  \
                   +incdir+${APPS}/pri_queue                \
		   +incdir+${APPS}/clk_gen                  \
                   +incdir+${APPS}/cl

SC_SRC	       +=
SC_INC	       +=

C_SRC	       += main.cpp
C_INC	       +=

UVM_SRC		= ${UVM_HOME}/src/uvm_pkg.sv                \
	          ${UVM_HOME}/src/dpi/uvm_dpi.cc 
UVM_INC		= +incdir+${UVM_HOME}/src -I${UVM_HOME}/src/dpi

SVX_UVM		= ${TOP}/uvm/src
SVX_UVM_SRC	= ${SVX_UVM}/svx_uvm_pkg.sv
SVX_UVM_INC	= +incdir+${SVX_UVM}

# Set UVM in your local makefile if you want to compile in the UVM
# library.  Leave it unset if you do not need UVM.
ifdef UVM
SV_SRC		:= ${SVX_SRC} ${UVM_SRC} ${APPS_SRC} ${SVX_UVM_SRC} ${SV_SRC}
SV_INC		+= +incdir+.              \
                   ${SVX_INC}             \
                   ${APPS_INC}            \
                   ${UVM_INC}             \
                   ${SVX_UVM_INC}
else
SV_SRC		:= ${SVX_SRC} ${APPS_SRC} ${SV_SRC}
SV_INC		+= +incdir+.              \
                   ${SVX_INC}             \
                   ${APPS_INC}
endif

SRC	       := ${SV_SRC} ${SC_SRC} ${C_SRC}
INC	       := ${SV_INC} ${SC_INC} ${C_INC}

#------------------------------------------------------------
# Options and Commands
 
COMPILE_OPTS	:= --cc --exe --build --sv -Mdir $(BUILD_DIR) --vpi
COMPILE_OPTS	+= --top ${TOP_MODULE}
COMPILE_OPTS 	+= -Wall --build-jobs `nproc`
# turn off pedantry
COMPILE_OPTS	+= --Wno-DECLFILENAME -Wno-VARHIDDEN -Wno-UNUSEDSIGNAL -Wno-UNDRIVEN
COMPILE_OPTS	+= --timing
COMPILE_OPTS	+= --autoflush

COMPILE_CMD    := ${VERILATOR} ${COMPILE_OPTS} ${EXTRA_COMPILE_OPTS} ${INC} ${SRC}

UVM_RUN_OPTS   += +UVM_NO_RELNOTES +UVM_TESTNAME=${TEST} 

# Users set RUN_OPTS in local makefiles
RUN_CMD	       := ${SIM_BIN} ${UVM_RUN_OPTS} ${RUN_OPTS}

#------------------------------------------------------------
# Rules

.PHONY: do_build do_run

all: clean build run

# You can disable a test or example from being built by placing and
# empty file called .disable (note the leading dot) in the same
# directory as the makefile.

build: ${SRC}
	@if [ ! -e .disable ]; then \
	  make -s do_build; \
	else \
	  dir=`pwd`; \
	  echo "[BUILD] Example" `basename $$dir` "is disabled."; \
	fi

do_build:
	echo "[BUILD]" `pwd`
	${V}mkdir -p $(BUILD_DIR)
	${V}echo ${COMPILE_CMD} > ${BUILDLOG} 2>&1
	${V}${COMPILE_CMD} >> ${BUILDLOG} 2>&1

# A disabled test or example will not run

run:
	@if [ ! -e .disable ]; then \
	  make -s do_run; \
	else \
	  dir=`pwd`; \
	  echo "[RUN] Example" `basename $$dir` "is disabled."; \
	fi
do_run:
	@echo "[RUN]" `pwd`
	${V}echo ${RUN_CMD} > ${RUNLOG} 2>&1
	${V}${RUN_CMD} >> ${RUNLOG} 2>&1

clean:
	@echo "[CLEAN]" `pwd`
	${V}rm -f ${BUILDLOG} ${RUNLOG}
	${V}rm -f xx* *~ #*
	${V}rm -rf $(BUILD_DIR) *.vcd *.fst
	${V}rm -f *.xml

