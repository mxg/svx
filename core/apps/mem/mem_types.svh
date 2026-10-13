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

//----------------------------------------------------------------------
// data types used in the sparse memory nmodel
//----------------------------------------------------------------------

typedef enum {
	      RESTRICT_NONE,
              RESTRICT_READ,
              RESTRICT_WRITE,
              RESTRICT_READ_WRITE
              } restrict_t;

typedef enum {
              ERROR_NONE,
	      ERROR_PARAMETERS_WRONG,
              ERROR_MISALIGNMENT,
	      ERROR_PAGE_SECURITY_VIOLATION,
	      ERROR_BLOCK_SECURITY_VIOLATION,
	      ERROR_WORD_SECURITY_VIOLATION,
	      ERROR_ADDRESS_BOUNDS
	      } error_t;

typedef enum{
	     OP_NONE,
	     OP_READ,
	     OP_WRITE,
	     OP_READ_BYTE,
	     OP_WRITE_BYTE
             } operation_t;

