Sequencer Aggregator
--------------------

A sequencer aggregator is a container used to store sequencer handles
so they can be retrieved by virtual sequences. You can learn more
about them from the book "Next Level Testbenches: Design Patterns in
SystemVerilog and UVM" by Mark Glasser.  There is also a discussion
about them in the DVCon US 2025 paper "Sequencer Containers - A
Unified and Simple Technique to Execute Both Sequences and Virtual
Sequences" by Cliff Cummings and Mark Glasser, and the DVCon India
2025 paper "A Summary and Examination of UVM Virtual Sequence
Techniques" by Cliff Cummings, Smita Kulkarni, and Mark Glasser.

A virtual sequence is a sequence launched without being bound to a
sequencer.  For example:

  seq1.start(sqr);  // normal
  seq2.start(null); // virtual

Seq1 is a normal sequence.  It is bound to the sequencer sqr as it's
being launched.  Seq1 can send sequence items to the driver via the
sequencer sqr.  Seq2 has no bound sequencer, making it a virtual
sequence. It is responsible for locating a sequencer handle (or
handles) to send sequence items.

The purpose of a virtual sequence is to allow a sequence to not be
committed to only one sequencer.  It may send transactions through
multiple sequencers to coordinate stimulus through multiple
interfaces.

Virtual sequences are on their own to obtain sequencer handles.  UVM
does not really address this issue.  Many testbenches employ so-called
virtual sequencers. These are fraught with many issues as explained in
the DVCon papers.

A sequencer aggregator is a container that holds sequencer handles.
It is stored in the resource database.  The testbench adds sequencer
handles to the aggregator after each sequencer is instantiated.
Typically the aggregator is populated in the agent or environment
during either the build or connect phase.  Often the connect phase is
preferable because you can be sure that the sequencer has been
instantiated.  Virtual sequence

Sequencer handles are stored in the aggregator by name, path, and
kind. Name is an arbitrary string that identifies the sequencer.  Path
is the path in the UVM component hierarchy to the sequencer, and kind
is an arbitrary string that identifies the kind of sequencer --
e.g. an AXI interface or a memory interface. Names and paths must be
unique. Adding a new sequencer handle with the same name as an
existing handle will overwrite the previous one. More than one
sequencer handle can have the same kind.  The sequencer aggregator
stores all the sequencers with the same kind in a list.  You can
retrieve the list to get all the sequencers of the same kind.

The API for a sequencer aggregator is:

  * add(sqr, name, kind)

    Adds a new sequencer handle to the sequencer aggregator container.
    The new handle is stored by name, path, and kind.

  * lookup_name(name)

    Find a sequencer handle by its name. Returns null if no sequencer
    handle is found.

  * lookup_path(path)

    Find a sequencer handle by its path in the UVM component
    hierarchy. Returns null if no sequencer handle is found.

  * lookup_path_regex(regex)

    Find one or more sequencer handles using a regular expression that
    matches paths.  The regex string must conform to the POSIX
    definition of a regular expression.

  * lookup_kind(kind)

    Find one or more sequencer handles by kind.

  * dump()

    Dumps the contents of the sequencer aggregator for debugging
    purposes.

Lookup_path_regex() and lookup_kind() return a deque#() containing the
located sequencer handles.  If there are no handles found then the
deque will be empty (i.e., size() == 0)

The example at uvm/examples/sqr_aggregator demonstrates how to use a
sequencer aggregator to provide sequencer handles to virtual
sequences.

