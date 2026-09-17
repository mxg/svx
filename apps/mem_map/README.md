Memory Map
----------

A memory map maps addresses to memory spaces.  A memory space could be
a register, device, region, or any other memory-mapped space.  This
memory maps supports fields, registers, memories, memory regions, and
memory views.  A region is a contiguous portions of a larger memory
space. A view is a pseudo-object that presents an alternative way to
access a memory space. A view can overlaps other memory spaces. Often
memory spaces represent a physical structure, such as a device.

Memory spaces are organized hierarchically.  Sibling spaces cannot
overlap, except for views.  A view can arbitrarily overlap anyt of its
siblings.  Memory spaces can contain subordinate spaces.  E.g., a
space can contain registers which, in turn, can contain fields.
Registers can only contain fields, and fields cannot contain any
subordinate spaces.  

API
---

You create your own memory spaces by deriving classes from the set of
space types available.  You can create a memory, for example by
deriving from mem_memory.  The hierarchy is built by having each class
creating subordinate spaces.

The constructors for each type of space are the same:

```
  function new(string name, mem_space_t parent, addr_t _offset, mem_size_t _size);
```

The constructor supplies the space's name, parent, offset from the
parent, and size in bytes.  The topmost object, typically a system or
subsystem (but not necessarily), has no parent (i.e., a parent of
null) and an offset of 0.  Each space has a set of add_*() functions
for adding subordinate spaces.

```
  function bit check_child(mem_space_t child);
  function void add_register(string name, addr_t _offset, mem_size_t _size);
  function void add_memory(string name, addr_t _offset, mem_size_t _size);
  function void add_region(string name, addr_t _offset, mem_size_t _size);
  function void add_view(string name, addr_t _offset, mem_size_t _size);
```

Not all spaces have the same set of add_*() functions as some
subordinate spaces are illegal.  E.g., registers can only have
subordinate fields, and fields cannot have subordinate spaces, as
previously mentioned.

Once the hierarchy has been established, call calculate_and_check()
from the topmost space.  This calculates the addresses of each space
based on size and offset information provided by the constructor
arguments.  It also invokes some consistency checking, such as making
sure that there are no inappropriate overlaps.

You can locate the space or spaces where an address resides by calling
find_addr() from the topmost space.  this will traverse the hierarchy
to locate the space that contains the specified address.  It's
possible that one address can be contained in multiple spaces.  The
function find_addr_all() returns a list of zero or more spaces where
the address resides.

Finally, dump() traverses the hierarchy and prints a single line
summary of each space.

Implementation
--------------

Mem_space is derived from svx::tree.  This provides the mem_space
hierarchy will all the funftionality of trees, including nameing,
retrieving children, as well as marking and unmarking. You can locate
a space by pathname using find().

Deque#() is used to represent lists of children. The list of spaces
returned by find_all() is also a deque#().  A typedef is avaiable for
an iterator that can be used to traverse the deques.

```
  mem_space::iterator_t iter;
```


