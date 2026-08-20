`include "svx_macros.svh"

package accum_utils;

  import svx::*;

  class add extends accum_fcn#(uint32_t, uint32_t);
    function void f(uint32_t t, ref uint32_t a);
      a += t;
    endfunction
  endclass

  class stats;

    function new();
      sum = 0;
      count = 0;
      var_sum = 0.0;
      mean = 0.0;
      std_dev = 0.0;
;
    endfunction
    
    uint32_t sum;
    uint32_t count;
    real var_sum;
    real mean;
    real std_dev;
    
  endclass

  class mean extends accum_fcn#(uint32_t, stats);
    function void f(uint32_t t, ref stats s);
      s.sum += t;
      s.count++;
      s.mean = $itor(s.sum) / $itor(s.count);
    endfunction
  endclass

  class std_dev extends accum_fcn#(uint32_t, stats);
    function void f(uint32_t t, ref stats s);
      real variance = t - s.mean;
      s.var_sum += (variance * variance);
      s.std_dev = $sqrt(s.var_sum / $itor(s.count));
    endfunction
  endclass

endpackage

module accum_unit_test;
  `include "svunit_defines.svh"
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
  import accum_utils::*;  

  string name = "accum_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

  //--------------------------------------------------------------------
  // basic_accum
  //--------------------------------------------------------------------
    `SVTEST(basic_accum_test)

      uint32_t a;
      uint32_t b;
      vector_uint32 v = new();
      list_bidir_uint32_iterator iter = new(v);
      add f = new();

      // populate vector with
      for(index_t ix = 0; ix < 100; ix++) begin
	uint32_t n = $urandom() % 100;
	v.appendc(n);
      end

      // Let's compute the sum so we can compare with the value
      // computed by accum#()::accumulate()
      b = 0;
      void'(iter.first());
      do begin
	b += iter.get();
        void'(iter.next());
      end while(!iter.at_end());  

      a = 0;
      accum#(uint32_t, uint32_traits, uint32_t)::accumulate(iter, f, a);

      `FAIL_UNLESS(a == b);

    `SVTEST_END

  //--------------------------------------------------------------------
  // mean
  //--------------------------------------------------------------------
    `SVTEST(mean_test)
      uint32_t count;
      uint32_t sum;
     real variance;
      real var_sum;
      real mean;
      real std_dev;
  
      stats s = new();
      vector_uint32 v = new();
      list_bidir_uint32_iterator iter = new(v);
      mean f_mean = new();
      std_dev f_std_dev = new();

      // populate vector with
      for(index_t ix = 0; ix < 100; ix++) begin
	uint32_t n = $urandom() % 1000;
	v.appendc(n);
      end

      // copmute mean
      count = 0;
      sum = 0;
      void'(iter.first());
      while(!iter.at_end()) begin
	sum += iter.get();
	count++;
	void'(iter.next());
      end
      mean = $itor(sum) / $itor(count);

      // compute standard deviation
      void'(iter.first());
      while(!iter.at_end()) begin
        variance = iter.get - mean;
	var_sum += (variance * variance);
	void'(iter.next());
      end
      std_dev = $sqrt(var_sum / $itor(count));      
  
  
      // compute mean
      accum#(uint32_t, uint32_traits, stats)::accumulate(iter, f_mean, s);
      // compute standard deviation
      accum#(uint32_t, uint32_traits, stats)::accumulate(iter, f_std_dev, s);

      `FAIL_UNLESS(mean == s.mean);
      `FAIL_UNLESS(std_dev == s.std_dev);

      // $display("count   = %0d", s.count);
      // $display("sum     = %0d", s.sum);
      // $display("mean    = %6.2f", s.mean);
      // $display("std_dev = %6.2f", s.std_dev);
      
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
