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
// plugin_opts
//
// Add the "plugin" option to the set of available command line
//options.
//----------------------------------------------------------------------
class plugin_opts;

  static function void add_opts();
    cl#(string)::add("plugin");
  endfunction

endclass

//----------------------------------------------------------------------
// plugins
//
// Retrieve the names of pluygins specified on the command line.  Then
// use the UVM factory to instantiate them as components.
//----------------------------------------------------------------------
class plugins;

  //--------------------------------------------------------------------
  // setup
  //
  // Locate the "+plugin=<name>" command line options.
  //--------------------------------------------------------------------
  static function void setup();

    uvm_resource_base th = uvm_resource#(string)::get_type();
    uvm_resource_pool rp = uvm_resource_pool::get();
    // Obtain a queue of all "plugin" command line options from the
    // resource database.
    uvm_resource_types::rsrc_q_t q = rp.lookup_name("CL::", "plugin", th, 0);

    // Is there at least one plugin specified on the command line?
    if(q.size() == 0) begin
      $display("no plugins available");
      return; // no plugins
    end

    // Traverse the queue of plugins and instantiate each one
    while(q.size() > 0) begin
      uvm_resource#(string) plugin_rsrc;
      uvm_resource_base rsrc = q.pop_front();
      string plugin;
      
      if(!$cast(plugin_rsrc, rsrc))
	$display("cannot cast plugin resource to string");
      else
	install_plugin(plugin_rsrc.read());
    end

  endfunction

  //--------------------------------------------------------------------
  // install_plugin
  //
  // Use the UVM factory to instantiate a plugin.
  //--------------------------------------------------------------------
  static function void install_plugin(string name);

    uvm_component c;
    uvm_factory factory = uvm_factory::get();

    $display("installing plugin %s", name);

    c = factory.create_component_by_name (name, "", name, uvm_top);
    if(c == null) begin
      string msg;
      $sformat(msg, "Unable to instantiate plugin %s", name);
      `uvm_error("SVX/PLUGIN", msg);
    end

  endfunction

endclass
