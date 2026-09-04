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

//----------------------------------------------------------------------
// types
//
// Standardized types
//----------------------------------------------------------------------

typedef byte                 int8_t;
typedef byte unsigned        uint8_t;
typedef shortint             int16_t;
typedef shortint unsigned    uint16_t;
typedef int                  int32_t;
typedef int unsigned         uint32_t;
typedef longint              int64_t;
typedef longint unsigned     uint64_t;
typedef bit [127:0]          int128_t;
typedef bit unsigned [127:0] uint128_t;

// represents sizes of various things
typedef uint64_t size_t;

// used for indexes
typedef uint64_t index_t;
typedef int64_t signed_index_t;

// process identifiers
typedef int unsigned pid_t;

// Package-level constants

/* verilator lint_off UNUSEDPARAM */
localparam bit true = 1;
localparam bit false = 0;
/* verilator lint_on UNUSEDPARAM */
