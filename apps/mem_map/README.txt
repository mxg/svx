Memory Map
----------

A memory map is a map of addresses to devices and memory elements. The
library models a memory map as a tree hierarchy of typed
spaces. Everything inherits from the abstract base class mem_space,
which holds an offset, size, and computed absolute address. The five
concrete types are:

  * REGION — a container. Can hold registers, memories, sub-regions,
    and views. This is typically your root node and represents a
   contiguous address range.

  * REGISTER — a fixed-size register at a byte offset within its
    parent. Can only contain FIELDs.

  * FIELD — a bit range within a register. Its offset and size are in
    bits, not bytes. Leaf node — no children.

  * MEMORY — a raw memory block at a byte offset. Leaf node — no
    children.

  * VIEW — like a region, but it intentionally shares its parent's
    base address. Two views at the same level are allowed to overlap
    each other, which is how you model aliased or banked address
    spaces.

Address Calculation
-------------------

When you call calculate_and_check() on the root, it walks the tree and
computes each node's absolute address:

FIELD: addr = offset (bit position, not byte)
VIEW: addr = parent's base addr (same as parent — that's the whole point)
Everything else: addr = parent_base + offset

It then runs overlap checks — siblings cannot overlap unless they're VIEWs.

Basic Usage Pattern
systemverilog

1. Create a root region

mem_region #(32) root = new("chip", null, 0, 'h1_0000_0000);

2. Add sub-regions

root.add_region("periph", 'hFF00_0000, 'h0100_0000);
root.add_memory("dram",   'h0000_0000, 'h8000_0000);

3. Add registers inside a region

mem_region #(32) periph = ...; // get handle to periph
periph.add_register("ctrl", 'h00, 4);
periph.add_register("status", 'h04, 4);

4. Add fields inside a register

mem_register #(32) ctrl = ...; // get handle to ctrl
ctrl.add_field("enable", 0, 1);   // bit 0
ctrl.add_field("mode",   1, 3);   // bits 3:1

5. Calculate addresses and validate

root.calculate_and_check();

6. Search by address

mem_space#(32)::list_t hits = root.find_addr('hFF00_0004);
mem_space#(32)::fwd_iterator_t iter = new(hits);
iter.first();
while (!iter.at_end()) begin
  $display("%s", iter.get().to_str());
  iter.next();
end

7. Dump the whole map (for debugging)
root.dump();


Key Design Points
-----------------

The base class mem_space is derived from tree in the SVX library.
SVX's tree provides all the hierarchy operations.

The ADDR_SIZE parameter represents the number of bits in the addresses
for all addresses in this address space.

The list of childre for each tree node is stored in a deque#()
structure, which is a generalied queue.

Find_addr() returns only leaf objects (registers and memories). This
is useful when you want to know exactly what is at an
address. Find_addr_all() returns every node in the hierarchy that
contains the address, from root down to leaf — useful for
understanding the full context.

The size type mem_size_t is one bit wider than addr_t intentionally —
so a space can express a size of 2^ADDR_SIZE (the full address space)
without overflow.

Error conditions (zero-size spaces, wrong parent/child types,
overlapping siblings) are caught at construction and during
calculate_and_check(), and flagged with has_error. Errors propagate
upward to the parent automatically.

------------------------------------------------------------------------
