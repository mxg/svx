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
// Polymorphic Object
//----------------------------------------------------------------------
virtual class object;
  pure virtual function string to_string();
endclass

class typed_object#(type T=int) extends object;
  function new(T _t);
    t = _t;
  endfunction

  function string to_string();
    return "";
  endfunction
  
  T t;
endclass

class str_obj extends typed_object#(string);

  function new(string _t);
    super.new(_t);
  endfunction
  
  function string to_string();
    return t;
  endfunction

endclass

class real_obj extends typed_object#(real);

  function new(real _t);
    super.new(_t);
  endfunction

  function string to_string();
    return $sformatf("%8.3g", t);
  endfunction

endclass

class int_obj extends typed_object#(uint32_t);

  function new(uint32_t _t);
    super.new(_t);
  endfunction

  function string to_string();
    return $sformatf("%0d", t);
  endfunction
endclass


//----------------------------------------------------------------------
// map_example
//----------------------------------------------------------------------
class map_example extends example;

  map#(string, object, class_traits#(object)) m;

  //--------------------------------------------------------------------
  // setup
  //--------------------------------------------------------------------
  function void setup();
    // Create new map
    m = new();
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  function void run();

    object obj;

    // Let's create some objects and put them in the map.
    str_obj name = new("fred");
    real_obj freq = new(6.05e-9);
    int_obj size = new(8192);
    
    void'(m.insert("name", name));
    void'(m.insert("freq", freq));
    void'(m.insert("size", size));
    
    // Now, lets find the objects in the map and print them.
    obj = m.get("name");
    $display("name = %s", obj.to_string());

    obj = m.get("freq");
    $display("freq = %s", obj.to_string());

    obj = m.get("size");
    $display("size = %s", obj.to_string());
  endfunction

  //--------------------------------------------------------------------
  // show
  //--------------------------------------------------------------------
  function void show();
    string key;
    $display("--- dump map ----");
    void'(m.first(key));
    do begin
      object obj = m.get(key);
      $display("%s -> %s", key, obj.to_string());
    end
    while(m.next(key));
  endfunction

endclass
