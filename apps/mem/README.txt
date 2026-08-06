Generic Sparse Memory Model
---------------------------

A memory model for any size memory.  The size of the
memory is determined by the number address bits, and the total number
of address bits is supplied via the class parameter list.

The implementation uses a variety of elements from the SVX library,
including maps, vectors, and iterators.

                       Memory Architecture
                       -------------------

The memory is organized as a sparse collection of pages.  Each page
is a sparse collection of blocks.  Each blocks is a vector of bytes.
The full memory address consists of a page address, a block address,
and a byte address.  The full address identifies a single byte.  The
page address identifies the page on which the byte resides, the block
address identifies the block with the page where we can find the byte
in question, and the byte address is the offset from the beginning of
the block where the byte resides.

Below is a simple diagram that illustrates a memory, mem, that has p
pages.  Each page has b blocks, and each block has n bytes.

 mem
   |
   +-----+
         |
        page[0]
 
        page[1]
        .  |
        .  +----------+----------+----------+----------+
        .  | block[0] | block[1] |    ...   |block[b-1]|
        .  +----------+----------+----------+----------+
        .      |            |                   |
        .      + byte[0]    + byte[0]           + byte[0]   
        .      + byte[1]    + byte[1]           + byte[1]   
        .      + byte[2]    + byte[2]           + byte[2]   
        .      .         .                      .       
        .      .         .                      .       
        .      .         .                      .       
        .      + bytes[n-1] + bytes[n-1]        + bytes[n-1]
        .
        .
        .
        .     
        page[p-1]

Because the memory is sparse, only the pages and blocks that contain
bytes are allocated.  Bytes are allocated semi-sparsely, the size of
the byte array is only as big as the byte with the highest address.
If a block has no bytes, the byte vector will be zero length; if it
has 100 bytes then the byte vector will have 100 bytes.

                       Address Architecture
                       -------------------

The location of each page, block, and byte is coded into the address.
The address contains three fields, the page address, the block
address, and the byte address.  The number of bits each field
consumes is dependent on the parameter values supplied to the class.
The page address is a key to a map that maps page keys to page
objects.  The block address is the position of a block within a
vector of blocks stored in a page.  The byte address is the position
of the byte within a vector of bytes in a blocks.

   +----------+----------+----------+
   |   PAGE   |   BLOCK  |   BYTE   |
   +----------+----------+----------+

The total number of bits in the address is defined by the ADDR_BITS
parameter.  The number of bits within the address used for the page
address is defined by the PAGE_BITS parameter.  The number of bits
for the block address is defined by the BLOCK_BITS parameter.  The
numer of bits for the byte address is obtained by subtacting
PAGE_BITS and BLOCK_BITS from ADDR_BITS.

byte address bits = ADDR_BITS - PAGE_BITS - BLOCK_BITS

For example, a memory defined as mem#(32,16,8,4) models a 32-bit
address space.  Pages are addressed using the lefmost 16 bits.  The
next 8 bits are used to address blocks, and the rightmost 8 bits are
the byte addresses within a block.

                         Bytes and Words
                         ---------------

An address refers to a single byte.  However, you can read and write
the memory using multi-byte words.  The WORD_SIZE parameter defines
the number of bytes contained in a word.  The value of WORD_SIZE must
be a power of two.  Word reads and writes must be aligned to a word
boundary.  Word reads and write cannot space blocks or pages, they
must be contained within a single block.

------------------------------------------------------------------------
