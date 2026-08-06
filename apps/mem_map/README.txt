MEM MAP
-------

A memory map is a map of addresses to devices and memory
elements. This memory map is organized as a collection of memory
spaces arranged in a tree. The kinds of memory spaces that can be
inserted into the map are:

  * region
  * memory
  * register
  * field
  * view

These spaces are organized hierarchically -- regions contains
memories, registers, other regions, and views. Registers can contain
fields.  Memories and feilds are always leaf nodes in the tree. The
spaces cannot overlap, each represents a unique part of the memory
space. Views on the other hand, are allowed to contain overlapping
subordinate elements.

A map is created hierarchially.  The top-most region contains
subordinate regions, memories and registers. Subordinate regions can
further contain lower level elements, and so forth.

Each element is added to the tree with and offset and a size.  The
offset is the offset from the base address in the containing region.
Upon insertion a check is made to ensure that the new element does not
overlap with any other element (address) in the containing element.
Once the map is complete, the absolute address can be computed for any
element in the map.

Because each element has an address (which is calculable), each
element can be located in the map by address.  Given an address, a
search can be done to locatre all elements in the map that contain
that address.

------------------------------------------------------------------------
