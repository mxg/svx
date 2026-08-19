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
// Common stack types
typedef stack#(int8_t,    int8_traits   ) stack_int8;
typedef stack#(uint8_t,   uint8_traits  ) stack_uint8;
typedef stack#(int16_t,   int16_traits  ) stack_int16;
typedef stack#(uint16_t,  uint16_traits ) stack_uint16;
typedef stack#(int32_t,   int32_traits  ) stack_int32;
typedef stack#(uint32_t,  uint32_traits ) stack_uint32;
typedef stack#(int64_t,   int64_traits  ) stack_int64;
typedef stack#(uint64_t,  uint64_traits ) stack_uint64;
typedef stack#(int128_t,  int128_traits ) stack_int128;
typedef stack#(uint128_t, uint128_traits) stack_uint128;
typedef stack#(real,      real_traits   ) stack_real;
typedef stack#(string,    string_traits ) stack_string;

//----------------------------------------------------------------------
// Common deque types
typedef deque#(int8_t,    int8_traits   ) deque_int8;
typedef deque#(uint8_t,   uint8_traits  ) deque_uint8;
typedef deque#(int16_t,   int16_traits  ) deque_int16;
typedef deque#(uint16_t,  uint16_traits ) deque_uint16;
typedef deque#(int32_t,   int32_traits  ) deque_int32;
typedef deque#(uint32_t,  uint32_traits ) deque_uint32;
typedef deque#(int64_t,   int64_traits  ) deque_int64;
typedef deque#(uint64_t,  uint64_traits ) deque_uint64;
typedef deque#(int128_t,  int128_traits ) deque_int128;
typedef deque#(uint128_t, uint128_traits) deque_uint128;
typedef deque#(real,      real_traits   ) deque_real;
typedef deque#(string,    string_traits ) deque_string;

//----------------------------------------------------------------------
// Common queue types
typedef queue#(int8_t,    int8_traits   ) queue_int8;
typedef queue#(uint8_t,   uint8_traits  ) queue_uint8;
typedef queue#(int16_t,   int16_traits  ) queue_int16;
typedef queue#(uint16_t,  uint16_traits ) queue_uint16;
typedef queue#(int32_t,   int32_traits  ) queue_int32;
typedef queue#(uint32_t,  uint32_traits ) queue_uint32;
typedef queue#(int64_t,   int64_traits  ) queue_int64;
typedef queue#(uint64_t,  uint64_traits ) queue_uint64;
typedef queue#(int128_t,  int128_traits ) queue_int128;
typedef queue#(uint128_t, uint128_traits) queue_uint128;
typedef queue#(real,      real_traits   ) queue_real;
typedef queue#(string,    string_traits ) queue_string;

typedef fixed_size_queue#(int8_t,    int8_traits   ) fixed_queue_int8;
typedef fixed_size_queue#(uint8_t,   uint8_traits  ) fixed_queue_uint8;
typedef fixed_size_queue#(int16_t,   int16_traits  ) fixed_queue_int16;
typedef fixed_size_queue#(uint16_t,  uint16_traits ) fixed_queue_uint16;
typedef fixed_size_queue#(int32_t,   int32_traits  ) fixed_queue_int32;
typedef fixed_size_queue#(uint32_t,  uint32_traits ) fixed_queue_uint32;
typedef fixed_size_queue#(int64_t,   int64_traits  ) fixed_queue_int64;
typedef fixed_size_queue#(uint64_t,  uint64_traits ) fixed_queue_uint64;
typedef fixed_size_queue#(int128_t,  int128_traits ) fixed_queue_int128;
typedef fixed_size_queue#(uint128_t, uint128_traits) fixed_queue_uint128;
typedef fixed_size_queue#(real,      real_traits   ) fixed_queue_real;
typedef fixed_size_queue#(string,    string_traits ) fixed_queue_string;

//----------------------------------------------------------------------
// Common vector types
typedef vector#(int8_t,    int8_traits   ) vector_int8;
typedef vector#(uint8_t,   uint8_traits  ) vector_uint8;
typedef vector#(int16_t,   int16_traits  ) vector_int16;
typedef vector#(uint16_t,  uint16_traits ) vector_uint16;
typedef vector#(int32_t,   int32_traits  ) vector_int32;
typedef vector#(uint32_t,  uint32_traits ) vector_uint32;
typedef vector#(int64_t,   int64_traits  ) vector_int64;
typedef vector#(uint64_t,  uint64_traits ) vector_uint64;
typedef vector#(int128_t,  int128_traits ) vector_int128;
typedef vector#(uint128_t, uint128_traits) vector_uint128;
typedef vector#(real,      real_traits   ) vector_real;
typedef vector#(string,    string_traits ) vector_string;

//----------------------------------------------------------------------
// Common range types
//
typedef range#(int8_t,    int8_traits   ) range_int8;
typedef range#(uint8_t,   uint8_traits  ) range_uint8;
typedef range#(int16_t,   int16_traits  ) range_int16;
typedef range#(uint16_t,  uint16_traits ) range_uint16;
typedef range#(int32_t,   int32_traits  ) range_int32;
typedef range#(uint32_t,  uint32_traits ) range_uint32;
typedef range#(int64_t,   int64_traits  ) range_int64;
typedef range#(uint64_t,  uint64_traits ) range_uint64;
typedef range#(int128_t,  int128_traits ) range_int128;
typedef range#(uint128_t, uint128_traits) range_uint128;
typedef range#(real,      real_traits   ) range_real;
typedef range#(string,    string_traits ) range_string;
	       
//----------------------------------------------------------------------
// Common iterator types
//
// Forward iterators
typedef list_fwd_iterator#(int8_t,    int8_traits    ) list_fwd_int8_iterator;
typedef list_fwd_iterator#(uint8_t,   uint8_traits   ) list_fwd_uint8_iterator;
typedef list_fwd_iterator#(int16_t,   int16_traits   ) list_fwd_int16_iterator;
typedef list_fwd_iterator#(uint16_t,  uint16_traits  ) list_fwd_uint16_iterator;
typedef list_fwd_iterator#(int32_t,   int32_traits   ) list_fwd_int32_iterator;
typedef list_fwd_iterator#(uint32_t,  uint32_traits  ) list_fwd_uint32_iterator;
typedef list_fwd_iterator#(int64_t,   int64_traits   ) list_fwd_int64_iterator;
typedef list_fwd_iterator#(uint64_t,  uint64_traits  ) list_fwd_uint64_iterator;
typedef list_fwd_iterator#(int128_t,  int128_traits  ) list_fwd_int128_iterator;
typedef list_fwd_iterator#(uint128_t, uint128_traits ) list_fwd_uint128_iterator;
typedef list_fwd_iterator#(real,      real_traits    ) list_fwd_real_iterator;
typedef list_fwd_iterator#(string,    string_traits  ) list_fwd_string_iterator;

//
// Backward iterators
//
typedef list_bkwd_iterator#(uint8_t,   uint8_traits  ) list_bkwd_uint8_iterator;
typedef list_bkwd_iterator#(int8_t,    int8_traits   ) list_bkwd_int8_iterator;
typedef list_bkwd_iterator#(uint16_t,  uint16_traits ) list_bkwd_uint16_iterator;
typedef list_bkwd_iterator#(int16_t,   int16_traits  ) list_bkwd_int16_iterator;
typedef list_bkwd_iterator#(uint32_t,  uint32_traits ) list_bkwd_uint32_iterator;
typedef list_bkwd_iterator#(int64_t,   int64_traits  ) list_bkwd_int64_iterator;
typedef list_bkwd_iterator#(uint64_t,  uint64_traits ) list_bkwd_uint64_iterator;
typedef list_bkwd_iterator#(int128_t,  int128_traits ) list_bkwd_int128_iterator;
typedef list_bkwd_iterator#(uint128_t, uint128_traits) list_bkwd_uint128_iterator;
typedef list_bkwd_iterator#(real,      real_traits   ) list_bkwd_real_iterator;
typedef list_bkwd_iterator#(string,    string_traits ) list_bkwd_string_iterator;

//
// Bidirectional iterators
//
typedef list_bidir_iterator#(int8_t,    int8_traits   ) list_bidir_int8_iterator;
typedef list_bidir_iterator#(uint8_t,   uint8_traits  ) list_bidir_uint8_iterator;
typedef list_bidir_iterator#(int16_t,   int16_traits  ) list_bidir_int16_iterator;
typedef list_bidir_iterator#(uint16_t,  uint16_traits ) list_bidir_uint16_iterator;
typedef list_bidir_iterator#(int32_t,   int32_traits  ) list_bidir_int32_iterator;
typedef list_bidir_iterator#(uint32_t,  uint32_traits ) list_bidir_uint32_iterator;
typedef list_bidir_iterator#(int64_t,   int64_traits  ) list_bidir_int64_iterator;
typedef list_bidir_iterator#(uint64_t,  uint64_traits ) list_bidir_uint64_iterator;
typedef list_bidir_iterator#(int128_t,  int128_traits ) list_bidir_int128_iterator;
typedef list_bidir_iterator#(uint128_t, uint128_traits) list_bidir_uint128_iterator;
typedef list_bidir_iterator#(real,      real_traits   ) list_bidir_real_iterator;
typedef list_bidir_iterator#(string,    string_traits ) list_bidir_string_iterator;
