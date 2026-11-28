# Agreements

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

## API

```
void agree(uvm_object obj, int lineno = 0);
void disagree(uvm_object obj, int lineno = 0);
```

`Agree()` and `disagree()` are called by components to signify they
agree it's OK to let the waiting process unblock or disagree.  Only
when all participating processes agree can the waiting process
unblock.  A single process can change their vote as circumstances
change.

```
task wait_for_agreement(uvm_object obj, int lineno = 0);
```

A blocking task that waits for all participating processes to agree.
`Wait_for_agreement() must be called from a process other than the
participating processes that vote to agree or disagree.

```
void clear(uvm_object obj, int lineno = 0);
```

`Clear()` clears the state of the agreement, thus allowing the waiting
process to unblock.  This can be used as a fail safe to prevent
deadlock.

```
uint32_t num_disagreements();
```

Retuns the number of participating currently voting to disagree.
Typically, this is used for debugging.

```
void set_debug()
void clr_debug()
void set_debug_all()
void clr_debug_all()
```

The debug interface lets you turn on or off debugging features for one
agreement or all agreements.  `Set_debug()` and `clr_debug()` turn on
and off debugging for one agreement, and set_debug_all() and
clr_debug_all() turn on and off debugging for all agreements.

## Use Models

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

    ok_to_shutdown.disagree(this);
    for(i = 0; i < 1000; i++) begin
      // generate a packet
    end
    ok_to_shutdown.agree(this);

  endtask

The scoreboard can monitor the fifo to determine when to agree or
disagree to shutdown.

  task run_phase(uvm_phase phase);
    forever begin
      ok_to_shutdown.agree(this);
      transaction = fifo.get();
      ok_to_shutdown.disagree(this);
      process_transaction(transaction);
    end
  endtask

Initially, the scoreboard has nothing to do, so it allows the
testbench to shutdown.  When a transaction appears from the FIFO, then
it's time to do some work.  The scoreboard disallows shutdown by
calling disagree() on ok_to_shutdown.  When it is finished processing
the transaction it again agrees to allow shutdown. The testbench can
shutdown when both the sequence and scoreboard agree to do so.

For a complete example see uvm/examples/agreement.