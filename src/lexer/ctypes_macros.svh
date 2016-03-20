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
// ctypes
//
// The ctypes API is a collection of macros that emulate the C ctypes
// functions.  These macros ask if a character posseses certain
// characteristics. See ctypes.sv for the characteric definitions for
// each ASCII character.  These macros are modeled after the ctypes
// macros that are part of the C library.
//----------------------------------------------------------------------

`define _U      'h001    // upper case
`define _L      'h002    // lower case
`define _N      'h004    // numeric
`define _S      'h008    // whitespace
`define _P      'h010    // punctuation
`define _C      'h020    // control char
`define _X      'h040    // hexidecimal
`define _B      'h080    // blank
`define _O      'h100    // octal digit
`define _Z      'h200    // logic char

`define cmask   'h7f

`define	isalpha(c)	(((ctypes::_ctype[(c) & `cmask]) & (`_U | `_L)) > 0)
`define	isblank(c)	(((ctypes::_ctype[(c) & `cmask]) & `_B) > 0)
`define	isupper(c)	(((ctypes::_ctype[(c) & `cmask]) & `_U) > 0)
`define	islower(c)	(((ctypes::_ctype[(c) & `cmask]) & `_L) > 0)
`define	isdigit(c)	(((ctypes::_ctype[(c) & `cmask]) & `_N) > 0)
`define	isxdigit(c)	(((ctypes::_ctype[(c) & `cmask]) & (`_X | `_N)) > 0)
`define	isspace(c)	(((ctypes::_ctype[(c) & `cmask]) & `_S) > 0)
`define ispunct(c)	(((ctypes::_ctype[(c) & `cmask]) & `_P) > 0)
`define isalnum(c)	(((ctypes::_ctype[(c) & `cmask]) & (`_U | `_L | `_N)) > 0)
`define isprint(c)	(((ctypes::_ctype[(c) & `cmask]) & (`_P | `_U | `_L | `_N | `_B )) > 0)
`define	isodigit(c)	(((ctypes::_ctype[(c) & `cmask]) & `_O) > 0)
`define	islogic(c)	(((ctypes::_ctype[(c) & `cmask]) & `_Z) > 0)
