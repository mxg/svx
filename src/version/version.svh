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
// Version
//----------------------------------------------------------------------

class ver;
  static function int unsigned get_major_version();
    return `SVX_MAJOR_VERSION;
  endfunction

  static function int unsigned get_minor_version();
    return `SVX_MINOR_VERSION;
  endfunction

  static function string get_release_mode();
    return `STRINGIFY(`SVX_RELEASE_MODE);
  endfunction

  static function int unsigned get_fix_version();
    return `SVX_FIX_VERSION;
  endfunction

  static function string get_version_string();
    return `SVX_VERSION ;
  endfunction

  static function void print_banner();
    $display("----------------------------------------------------------------------");
    $display("SystemVerilog Extension Library");
    $display("%s", get_version_string());
    $display("----------------------------------------------------------------------");
  endfunction
  
endclass
