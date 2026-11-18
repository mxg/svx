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
// mem_channel
//----------------------------------------------------------------------
module mem_channel (input  logic [31:0] addr,
                    input  logic [31:0] data_in,
                    output logic [31:0] data_out,
                    input  logic        rw,  // 0 = read, 1 = write
                    input  logic        en,
                    input  logic        rst_n,
                    input  logic        clk);

  import mem_pkg::*;
  import svx::*;

  typedef mem#(32,16,8,4) mem_t;
  mem_t mem_model;
  semaphore sem;

  
  function void set_mem(mem_t m, semaphore s);
    mem_model = m;
    sem = s;
  endfunction

  // Execute the transaction
  always @(posedge clk) begin
    bit [31:0] addr2;
    bit [31:0] data2;

    // Is the device enabled?
    if(en == 1) begin

      // write
      if(rw == 1) begin
        sem.get();
        addr2 = addr;
        data2 = data_in;
        $display("%10t: mem_channel: write addr = %8x  data = %8x", $time, addr2, data2);
        mem_model.write(addr2, data2);
        sem.put();
      end

      else
        // read
        if(rw == 0) begin
          sem.get();
          addr2 = addr;
          data2 = mem_model.read(addr2);
          data_out <= data2;
          $display("%10t: mem_channel: read  addr = %8x  data = %8x", $time, addr2, data2);
          sem.put();
        end
      // else... no transaction
    end  // device enabled?
  end
  
endmodule
    
//----------------------------------------------------------------------
// memory
//----------------------------------------------------------------------
module memory (input logic clk,
               input logic rst_n
               );

  wire [31:0]  addr[3:0];
  wire [31:0]  data_in[3:0];
  wire [31:0]  data_out[3:0];
  wire [3:0]   rw;
  wire [3:0]   en;
  wire [3:0]   activate;
  wire [3:0]   read_only;
  wire         configure;

  import mem_pkg::*;
  typedef mem#(32,16,8,4) mem_t;
  mem_t mem_model;
  semaphore sem;

  // Create the memory model and make it available to all the channels.
  reg [3:0] activate_reg;
  reg [3:0] read_only_reg;
  reg [3:0] rw_reg;
  reg [3:0] en_reg;

  // Asynchronous reset
  always @(posedge clk) begin
    if(rst_n == 1'b0) begin
      activate_reg[3:0]  <= 4'b0;
      read_only_reg[3:0] <= 4'b1; // default to read_only
      @(negedge clk);
    end
  end

  // Configure
  always @(posedge clk) begin
    if((rst_n == 1'b1) &&  (configure == 1'b1)) begin
      $display("configure: activate = %4b read_only = %4b", activate, read_only);
      activate_reg  <= activate;
      read_only_reg <= read_only;
    end
  end

  assign activate_reg = activate;
  assign rw_reg = ~read_only & rw;
  assign en_reg = activate_reg & en;

  initial begin
    mem_model = new();
    sem = new(1);
    u_mem_channel_0.set_mem(mem_model, sem);
    u_mem_channel_1.set_mem(mem_model, sem);
    u_mem_channel_2.set_mem(mem_model, sem);
    u_mem_channel_3.set_mem(mem_model, sem);
  end
  
  mem_channel u_mem_channel_0 (
                               .addr     (addr[0]),
                               .data_in  (data_in[0]),
                               .data_out (data_out[0]),
                               .rw       (rw[0]),
                               .en       (en_reg[0]),
                               .rst_n    (rst_n),
                               .clk      (clk)
                               );

  mem_channel u_mem_channel_1 (
                               .addr     (addr[1]),
                               .data_in  (data_in[1]),
                               .data_out (data_out[1]),
                               .rw       (rw[1]),
                               .en       (en_reg[1]),
                               .rst_n    (rst_n),
                               .clk      (clk)
                               );  
  
  mem_channel u_mem_channel_2 (
                               .addr     (addr[2]),
                               .data_in  (data_in[2]),
                               .data_out (data_out[2]),
                               .rw       (rw[2]),
                               .en       (en_reg[2]),
                               .rst_n    (rst_n),
                               .clk      (clk)
                               );  
  
  mem_channel u_mem_channel_3 (
                               .addr     (addr[3]),
                               .data_in  (data_in[3]),
                               .data_out (data_out[3]),
                               .rw       (rw[3]),
                               .en       (en_reg[3]),
                               .rst_n    (rst_n),
                               .clk      (clk)
                               );  
  
endmodule
  
