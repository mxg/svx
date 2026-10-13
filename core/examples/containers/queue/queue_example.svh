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
// packet
//
// For the queue example we use a simnple packet.  It contains a
// destination and a set of bytes.  The bytes are stored in a
// vector. The destination is a single byte with a specific set of
// valid values.  The values are populated into a static structure
// (vector) at setup time.
//----------------------------------------------------------------------
class packet;

  // packet contents
  uint8_t dest;
  vector#(uint8_t, uint8_traits) payload;

  // set of valid destinations
  static vector#(uint8_t, uint8_traits) destinations = new();

  // Static function to create a new packet. The choice of
  // desitnations and the bytes in the payload are randomized.
  static function packet create();
    packet p = new();
    // Choose a randomized deswtination
    index_t ix = index_t'(size_t'($urandom()) % destinations.size());
    p.dest = destinations.read(ix);
    // Create and fill in the payload
    p.payload = new();
    for(ix = 0; ix < 16; ix++) begin
      p.payload.write(ix, int8_t'($urandom() & 'hff));
    end
    return p;
  endfunction

  // Print the contents of a packet
  function void print();
    $write("[%2x]", dest);
    for(index_t ix = 0; ix < 16; ix++) begin
      $write(" %2x", payload.read(ix));
    end
    $display();
  endfunction
  
endclass

//----------------------------------------------------------------------
//queue_example
//----------------------------------------------------------------------
class queue_example extends example;

  queue#(packet, class_traits#(packet)) q;

  //--------------------------------------------------------------------
  // setup
  //--------------------------------------------------------------------
  function void setup();
    q = new();
    // populate destinations with a set of valid destinations.  We do
    // this outside of the packet class because we only want to do it
    // once, not for each packet instance.
    packet::destinations = vector#(uint8_t, uint8_traits)::create({8'h04, 8'hc1, 8'h17, 8'ha4});
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  function void run();
    index_t ix;

    // Put packets into the queue
    for(ix = 0; ix < 10; ix++) begin
      packet p = packet::create();
      $write("putting ");
      p.print();
      q.put(p);
    end

    // Get packets from the queue.
    for(ix = 0; ix < 10; ix++) begin
      packet p = q.get();
      $write("getting ");
      p.print();
    end  endfunction

  //-------------------<-------------------------------------------------
  // show
  //--------------------------------------------------------------------
  function void show();
  endfunction

endclass

      
