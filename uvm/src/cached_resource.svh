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
// Copyright 2024-2026 Mark Glasser
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
// cached_resource_base
//
// Non-parameterized base class for cached resources.
//----------------------------------------------------------------------
virtual class cached_resource_base;

  protected string name;
  protected string scope;

  pure virtual function bit is_empty();
  pure virtual function void refresh();

  protected function string id();
    return {"Resource ", name, " @ ", scope, ": "};
  endfunction

  function void print();
    $display("cached resource: scope = %s, name = %s", scope, name);
  endfunction
  
endclass

//----------------------------------------------------------------------
// cached_resource
//----------------------------------------------------------------------
class cached_resource#(type T=int) extends cached_resource_base;

  typedef uvm_resource#(T) rsrc_t;
  local rsrc_t rsrc;
  local T last_value;
  
  //--------------------------------------------------------------------
  // constructor
  //
  // If leave_unbound is set then do not attempt to bind the
  // cached_resource to a resource.  Binding can be done later by
  // calling refresh().
  //--------------------------------------------------------------------
  function new(string _scope, string _name, bit leave_unbound = 0);
    name = _name;
    scope = _scope;
    if(!leave_unbound)
      refresh();
  endfunction

  //--------------------------------------------------------------------
  // update_cache
  //
  // Update the cached resource.  May or may not change the rsrc
  // handle.
  //--------------------------------------------------------------------
  local virtual function bit update_cache(string _scope, string _name);
    
    uvm_resource_pool rp = uvm_resource_pool::get();
    uvm_resource_base rsrc_base;
    
    rsrc_base = rp.get_by_name(_scope, _name, rsrc_t::get_type(), 0);
    
    // Did we find the resource?
    if(rsrc_base == null) begin
      `uvm_error("SVX/CACHED_RSRC/UPDATE",
		{id(), " not found in the resource database."})
      return 0;
    end
    
    if(!$cast(rsrc, rsrc_base)) begin
      // This failure should never happen.
      `uvm_error("SVX/CACHED_RSRC/UPDATE", "Cast failure.")
      return 0;
    end
    
    return 1;
    
  endfunction

  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return (rsrc == null);
  endfunction

  //--------------------------------------------------------------------
  // refresh
  //
  // Refresh the cache.
  //--------------------------------------------------------------------
  function void refresh();
    void'(update_cache(scope, name));
  endfunction

  //--------------------------------------------------------------------
  // get_the_latest
  //
  // Force the resource cache to be updated from the resource
  // database. This may result in caching a new resource.
  //--------------------------------------------------------------------
  function bit get_the_latest(inout  T val,
			      input  uvm_object accessor = null);

    if(!update_cache(scope, name))
      return 0;
    
    val = rsrc.read(accessor);
    return 1;
    
  endfunction
  
  //--------------------------------------------------------------------
  // read
  //
  // Read the value of the cached resource.  No update if the cache is
  // empty.
  // --------------------------------------------------------------------
  function bit read(inout T val, input uvm_object accessor);
    if(rsrc == null) begin
      `uvm_error("SVX/CACHED_RSRC/READ",
		 {id(), "cache is empty, cannot complete read."})
      return 0;
    end

    val = rsrc.read(accessor);
    return 1;    
  endfunction    

  //--------------------------------------------------------------------
  // write
  //
  // Update the value of the resource.  Note that writing the same
  // value does not trigger wait_for_change().
  //--------------------------------------------------------------------
  function void write(T val, input uvm_object accessor);
    if(rsrc == null) begin
      `uvm_error("SVX/CACHED_RSRC/WRITE",
		 {id(), "cache is empty, cannot complete write."})
      return;
    end
    rsrc.write(val, accessor);
  endfunction

  //--------------------------------------------------------------------
  // wait_for_change
  //--------------------------------------------------------------------
  task wait_for_change();
    T val;
    
    if(is_empty()) begin
      `uvm_error("SVX/CACHED_RSRC/WAIT",
		 {id(), "cache is empty, nothing to wait for."})      
      return;
    end

    last_value = rsrc.read(null);

    forever begin
      rsrc.wait_modified();
      val = rsrc.read(null);
      // Has the value actually changed?
      if (val != last_value)
	break;
    end
    last_value = val;    
    
  endtask
  
endclass


  
