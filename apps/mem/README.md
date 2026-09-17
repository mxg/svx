Sparse Memory
-------------

Mem is a sparse memory model, it uses real memory efficiently.  The
memory is organized as a collection of pages, and each page is a
collection of blocks.  Each block is a small allocation of real memory
that contains words.  Each word is one or more bytes.  The memory
initially has no pages or blocks.  Pages or blocks are only allocated
when a write is posted to an address whose page and/or block is as yet
unallocated.  This allows very large memories to be efficiently
modeled within a SystemVerilog simulation.

The size of the memory and the sizes of pages and blocks is not
fixed. Those things are specified using class parameters.  The class
header, shown below, uses four parameters.

```
class mem#(uint32_t ADDR_BITS = 32,
	   uint32_t PAGE_BITS = 16,
	   uint32_t BLOCK_BITS = 8,
	   uint32_t WORD_SIZE = 4);
```

ADDR_BITS specifies the number of bits in an address.  The total
potential size of the memory is 2^n bytes.  An address is broken into
fields.  PAGE_BITS occupies the leftmost (high-order) bits.  Following
that to the right is BLOCK_BITS, which specifies the number of bits in
a block address.  Using the default values show in the class header
above, ADDR_BITS=32 means the memory can address 2^32 bytes. The
memory is arranged as 2^16 pages, each of which can contain 2^8
blocks.  The rightmost bits, whose length is
(ADDR_BITS-(PAGE_BITS+BLOCK_BITS), represents the size in bytes of
each block.  In our example, the size of a block is 2^(32-16-8) = 2^8
= 256 bytes.

WORD_SIZE identifies the number of bytes (not bits) in a word.  Reads
and writes are done at the word-level.In the example, WORD_SIZE=4
means that each word, i.e., each read and write, is 4 bytes or 32 bits
at a time.

The model supports ADDR_BITS in the range of 64 <= ADDR_BITS <=
8. PAGE_BITS and BLOCK_BITS can be any size such that they fit inside
an address and a block is at least the size of one word..

Additionally, the memory supports a security interface which allows
you to control which pages and blocks can be read or written.

Interface
---------

The primary interface is straightforward:

```
function void
write(addr_t addr, word_t data);
function word_t read(addr_t addr);
function void write_byte(addr_t addr, byte_t data);
function byte_t read_byte(addr_t addr);
```

Write() and read() put data into the memory and retrieve it.  These
two functions operate at the word-level, reading and writing a word at
a time.  Write_byte() and read_byte() read and write a byte at a time.

The security interface is similarly straightforward:

```
  function void set_page_restriction(addr_t addr, restrict_t r);
  function void clear_page_restriction(addr_t addr);

  function void set_block_restriction(addr_t addr, restrict_t r);
  function void clear_block_restriction(addr_t addr);

  function void set_word_restriction(addr_t addr, restrict_t r);
  function void clear_word_restriction(addr_t addr);
```

Restrictions can be set and cleared at the page-level, block-level, or
word-level.  The restrictions can be interrogated by address. The
functions is_readable() and is_writeable() ask if there is a read or
write restriction in the region the address resides -- page, block, or
word.

```
  function bit is_readable(addr_t addr);
  function bit is_writable(addr_t addr);
```

When a security violation occurs, that fact is recorded in a three
fields, last_error, last_addr, and last_operation.  You can determine
if an error occurred by calling get_last_error().  You can get a
human-readable representation of the last operation, including error
information, if one has occurred, by calling get_last_op_string().

Three functions are available to show details of the memory. Show()
show all the address sizes and masks. Dump_security() shows the map of
access restrictions.  Dump() dumps the contents of the memory.

Implementation
--------------

Pages are stored in a map#() whose key is the page address.
Similarly, blocks are stored in each page using a map#().  Memory
blocks are implemented using a vector#().

Both read and write first determine which page is being accessed and
then delegates to the page.  The page, in turn, figures out which
block is being accessed and then delegates to the block.  Finally the
actual access occurs at the block-level