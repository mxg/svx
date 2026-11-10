Agreements
----------

An agreement is a shared synchronization primitive, used to
synchronize threads across components. The agreement class is
specifically designed to synchronize between threads that operate in
different objects (class instances).  One thread, which we'll call the
master thread, blocks until all the other participating threads agree
to unblock.

Each object can vote to agree or disagree to move forward.  A
disagreement means that the thread wishes the master thread to remain
blocked, an agreement means the thread wishes to unblock.  Threads can
change their vote at any time.  When all threads are in agreement then
the master thread will unblock.

Typically, agreements are shared through the resource database.  A
top-level component creates a new agreement object and puts it into
the resource database.  All the other components that will participate
in the voting retrieve it from there.

A common use case is determining when to shutdown the testbench.  A
top-level component, such as the test or the top-level environment,
blocks the run_phase() task.  Other components such as monitors,
scoreboards, sequences, etc. can then use the shared agreement to vote
to shutdown (agree) or not (disagree).

As an example, consider a testbench with a sequence that generates
stimulus and a scoreboard that tracks the DUT's activity.  The
scoreboard has a fifo which collects transactions from a monitor.

The sequence's body() task uses the agreement to signify when the
stimulus generation is complete.

  task body();

    ok_to_shutdown.disagree();
    for(i = 0; i < 1000; i++) begin
      // generate a packet
    end
    ok_to_shutdown.disagree();

  endtask

The scoreboard can monitor the fifo to determine when to agree or
disagree to shutdown.

  task run_phase(uvm_phase phase);
    forever begin
      ok_to_shutdown.agree();
      transaction = fifo.get();
      ok_to_shutdown.disagree();
      process_transaction(transaction);
    end
  endtask

Initially, the scoreboard has nothing to do, so it's allows the
testbench to shutdown.  When a transaction appears from the fifo, then
it's time to do some work.  The scoreboard disallows shutdown by
calling disagree() on ok_to_shutdown.  When it is finished processing
the transaction it again agrees to allow shutdown. The testbench can
shutdown when both the sequence and scoreboard agree to do so.

For a complete example see uvm/examples/agreement.
