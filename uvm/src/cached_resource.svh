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
// cached_resoure_base
//----------------------------------------------------------------------
virtual class cached_resource_base;
  pure virtual function bit is_empty();
endclass


//----------------------------------------------------------------------
// cached_resource
//----------------------------------------------------------------------
class cached_resource#(type T=int) extends cached_resource_base;

  typedef uvm_resource#(T) rsrc_t;
  local rsrc_t rsrc;

  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return (rsrc == null);
  endfunction

  //--------------------------------------------------------------------
  // get_the_latest
  //
  // Force the resource cache to be updated from the resource
  // database.
  //--------------------------------------------------------------------
  function bit get_the_latest(string scope,
			      string name,
			      inout  T val,
			      input  uvm_object accessor = null);
    
    uvm_resource_pool rp = uvm_resource_pool::get();
    uvm_resource_base rsrc_base;

    rsrc_base = rp.get_by_name(scope, name, rsrc_t::get_type(), 0);

    // Did we find the resource?
    if(rsrc_base == null)
      return 0;
      
    if(!$cast(rsrc, rsrc_base)) begin
      // This failure should never happen.
      `uvm_error("SVX/CACHED_RSRC", "Cast failure.")
      return 0;
    end 

    val = rsrc.read(accessor);
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // read_by_name
  //
  // Read the value of the cached resource.  If the cache is empty
  // retrieve the resource from the resource database.
  //--------------------------------------------------------------------
  function bit read_by_name(string scope,
			    string name,
			    inout  T val,
			    input  uvm_object accessor);
    
    if(rsrc == null) begin
      return get_the_latest(scope, name, val, accessor);
    end

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
    if(rsrc == null)
      return 0;
    val = rsrc.read(accessor);
    return 1;    
  endfunction    

  //--------------------------------------------------------------------
  // write
  //
  // Update the value of the resource.
  //--------------------------------------------------------------------
  function void write(T val, input uvm_object accessor);
    if(rsrc == null)
      return;
    rsrc.write(val, accessor);
  endfunction

  //--------------------------------------------------------------------
  // wait_for_change
  //--------------------------------------------------------------------
  task wait_for_change();
    time t = $time;

    if(is_empty())
      return;

    rsrc.wait_modified();
    uvm_wait_for_nba_region();
    if(t == $time)
      rsrc.wait_modified();
    
  endtask
  
endclass


  
