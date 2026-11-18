Sequencer Aggregator
--------------------

A sequencer aggregator is a container used to store sequencer handles
so they can be retrieved by virtual sequences. You can learn more
about them from the book "Next Level Testbenches: Design Patterns in
SystemVerilog and UVM" by Mark Glasser.  There is also a discussion
about them in the DVCon 2025 paper "Sequencer Containers - A Unified
and Simple Technique to Execute Both Sequences and Virtual Sequences"
by Cliff Cummings and Mark Glasser.

A virtual sequence is a sequence launched without being bound to a
sequencer.  For example:

  seq1.start(sqr);  // normal
  seq2.start(null); // virtual

Seq1 is a normal sequence.  It is bound to the sequencer sqr as it's
being launched.  Seq1 can send sequence items to the driver via the
sequencer sqr.  Sqr2 has no bound sequencer, making it a virtual
sequence. It is responsible for locating a sequencer handle (or
handles) to send sequence items.

The purpose of a virtual sequence is to allow a sequence to not be
committed to only one sequencer.  It may send transactions through
multiple sequencers to coordinate stimulus through multiple
interfaces.

Virtual sequences are on their own to obtain sequencer handles.  UVM
does not really address this issue.  Many testbenches employ so-called
virtual sequencers. These are fraught with many issues as explained in
the DVCon paper.

A sequencer aggregator is a container that holds sequencer handles.
It is stored in the resource database.  The testbench adds sequencer
handles to the aggregator as each sequencer is instantiated.
Typically this is done in the agent or environment.  Virtual
sequencers can retrieve the aggregator from the resource database and
then lookup sequencer handles.

Sequencer handles are stored in the aggregator by name, path, and
kind. Name is an arbitrary string that identifies the sequencer.  Path
is the path in the UVM component hierarchy to the sequencer, and kind
is an arbitrary string that identifies the kind of sequencer --
e.g. an AXI interface or a memory interface. Names and paths must be
unique. More than one sequencer handle can have the same kind.  The
sequencer aggregator stores all the sequencers with the same kind in a
list.  You can retrieve the list to get all the sequencers of the same
kind.

The example at uvm/examples/sqr_aggregator demonstrates how to use a
sequencer aggregator to provide sequencer handles to virtual
sequences.

