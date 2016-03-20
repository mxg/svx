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
// clk_descriptor
//
// Each instance of a clock descriptor provides information about a
// single clock.

//  name          -- clock name
//  freq          -- clock frequence in Hz
//  duty_cycle    -- A number greater than zero and less than or equal to
//                   1.0.  %time that the clock signal is high in a
//                   single wclock period. The default
//  clk_index     -- The index that represents the position of this clock in
//                   an array of clocks.
//  time_hi       -- time that the clock signal is high (1)
//  time_lo       -- time that the clock signal is low (0) The clock
//                   period is time_hi + time_lo
//  start_event   -- an event that used to start the clocks running.  One
//                  event may be shared by multiple clock_descriptors.
//  ckif          -- The clock interface which can be connected to the DUT.
//  time_scale    -- enum that identifies the scale factor for times.
//
//  initial_delay -- A delay that occurs before the clock starts.  If
//                   winitial delay is zero, the default, then no delta
//                   cycle is consumed bfore starting the clocks.
//  verbose       -- If on, a number of messages print that follow the
//                   operation of the clock.
//
// There are two ways to set time_lo and time_hi.  One is to set them
// directly.  The other is to set frequency and duty cycle.  Time_lo and
// time)hi will be computed from these values.  If duty cycle is not
// supplied then the deault of 0.5 (50%) is used.
//----------------------------------------------------------------------
class clk_descriptor #(int unsigned N=1) extends object;

  typedef enum { MILLISEC, MICROSEC, NANOSEC, PICOSEC, FEMTOSEC} scale_t;

  string name;
  int unsigned clk_index;
  real freq; // Hz
  real duty_cycle; // 0 < duty_cycle <= 1.0
  time time_lo;
  time time_hi;
  event start_event;
  virtual clk_if#(N) ckif;
  scale_t time_scale;
  time initial_delay;
  bit  verbose;

  // set defaults in the constructor
  function new();
    time_scale = NANOSEC;
    initial_delay = 0;
    duty_cycle = 0.5;
    verbose = 0;
    time_lo = 0;
    time_hi = 0;
  endfunction

  // store the virtual clock interface and the index for this clock
  // within the array of clock signals within the interface.
  function void set_vif(virtual clk_if#(N) vif, int unsigned index);
    ckif = vif;
    clk_index = index;
  endfunction

  // store the name of the clock
  function void set_name(string n);
    name = n;
  endfunction

  // store the start event
  function void set_start_event(event e);
    start_event = e;
  endfunction

  // Set the duty cycle.  The duty cycle must be greater than 0 and less
  // than or equal to 1.0.
  function void set_duty_cycle(real dc);
    if ((dc <= 0.0) || (dc > 1.0))
      return;
    duty_cycle = dc;
  endfunction

  // Set the clock frequency
  function void set_freq(real f);
    freq = f;
  endfunction

  // Set the clock high time and clock low time.  The clock period is
  // the sum of time_lo and time_hi.
  function void set_times(time hi, time lo);
    time_lo = lo;
    time_hi = hi;
  endfunction

  function void set_scale(scale_t s);
    time_scale = s;
  endfunction

  function void set_initial_delay(time t);
    initial_delay = t;
  endfunction

  function void set_verbose();
    verbose = 1;
  endfunction

  function void clr_verbose();
    verbose = 0;
  endfunction

  function string scale_str();
    string str;
    case(time_scale)
      MILLISEC: str = "ms";
      MICROSEC: str = "us";
      NANOSEC:  str = "ns";
      PICOSEC:  str = "ps";
      FEMTOSEC: str = "fs";
    endcase
    return str;
  endfunction

  // Validate all the data.  Also, calculae time_lo and time_hi as
  // necessary.  The validation is run once before starting the clock
  // processes.
  function bit validate();
    bit ok = 1;

    // clock interface must be set...
    if(ckif == null) begin
      $display("clock interface is null");
      ok = 0;
    end

    // Clock index must <= N
    if(clk_index >= N) begin
      $display("clock index is out of range");
      ok = 0;
    end

    // start even must be set...
    if(start_event == null) begin
      $display("start event is null");
      ok = 0;
    end

    // Generate a synthetic name if one has not been provided
    if(name == "") begin
      $sformat(name, "anon%0d", clk_index);
    end

    // If time_lo and time_hi were not set then calculate their values
    // from frequency and duty cycle.
    $display("thi = %0t  tlo = %0t", time_hi, time_lo);
    if((time_lo == 0) || (time_hi == 0)) begin

      real time_interval;
      real scale_factor;

      case(time_scale)
	MILLISEC: scale_factor = 1.0e3;
	MICROSEC: scale_factor = 1.0e6;
	NANOSEC:  scale_factor = 1.0e9;
	PICOSEC:  scale_factor = 1.0e12;
	FEMTOSEC: scale_factor = 1.0e15;
      endcase

      if(freq > 0.0) begin
	// convert freq and duty cycle to time_hi and time_lo
	if(!(duty_cycle > 0.0 && duty_cycle <= 1.0)) begin
	  duty_cycle = 0.5; // default
	end

	// convert frequency to time in femtoseconds.
	time_interval = ((scale_factor * 1.0e6) / freq);
	time_hi = $rtoi(time_interval * duty_cycle) / 1.0e6;
	time_lo = $rtoi(time_interval * (1.0 - duty_cycle)) / 1.0e6;
      end
      else begin
	$display("frequency not specified");
	ok = 0;
      end
    end

    return ok;
      
  endfunction

  //====================================================================
  // object utility interface
  //====================================================================

  function string to_str();
    string s;
    string scale = scale_str();
    $sformat(s, "[%0d] %s  lo = %0t%s hi = %0t%s", clk_index,
                                                    name,
                                                    time_lo,
                                                    scale,
                                                    time_hi,
                                                    scale);
    return s;
  endfunction

  function int compare(object obj);
    clk_descriptor cd;

    // cast the input argument to a clk_descriptor
    if(obj == null || !$cast(cd, obj))
      return 1;
    
    // compare indexes so that the descriptors can be ordered by descriptor
    if(clk_index == cd.clk_index)
      return 0;
    else
      if(clk_index < cd.clk_index)
	return 1;
      else
	return -1;
    
  endfunction

  function object copy(object rhs);
    clk_descriptor#(N) cd;

    // cast the input argument to a clk_descriptor
    if(rhs == null || !$cast(cd, rhs))
      return null;

    name	= cd.name;
    clk_index	= cd.clk_index;
    freq	= cd.freq;
    duty_cycle	= cd.duty_cycle;
    time_lo	= cd.time_lo;
    time_hi	= cd.time_hi;
    start_event = cd.start_event;
    ckif	= cd.ckif;
    time_scale	= cd.time_scale;

  endfunction
	
endclass

