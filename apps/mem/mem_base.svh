//----------------------------------------------------------------------
// Generic Sparse Memory Model
//
// A memory model for effectively any size memory.  The size of the
// memory is determined by the number address bits, and the total number
// of address bits is supplied via the class parameter list.
//
//                        Memory Architecture
//                        -------------------
//
// The memory is organized as a sparse collection of pages.  Each page
// is a sparse collection of blocks.  Each blocks is a vector of bytes.
// The full memory address consists of a page address, a block address,
// and a byte address.  The full address identifies a single byte.  The
// page address identifies the page on which the byte resides, the block
// address identifies the block with the page where we can find the byte
// in question, and the byte address is the offset from the beginning of
// the block where the byte resides.
//
// Below is a simple diagram that illustrates a memory, mem, that has p
// pages.  Each page has b blocks, and each block has n bytes.
//
//  mem
//    |
//    +-----+
//          |
//         page[0]
//  
//         page[1]
//         .  |
//         .  +----------+----------+----------+----------+
//         .  | block[0] | block[1] |    ...   |block[b-1]|
//         .  +----------+----------+----------+----------+
//         .      |            |                   |
//         .      + byte[0]    + byte[0]           + byte[0]   
//         .      + byte[1]    + byte[1]           + byte[1]   
//         .      + byte[2]    + byte[2]           + byte[2]   
//         .      .         .                      .       
//         .      .         .                      .       
//         .      .         .                      .       
//         .      + bytes[n-1] + bytes[n-1]        + bytes[n-1]
//         .
//         .
//         .
//         .     
//         page[p-1]
//
// Because the memory is sparse, only the pages and blocks that contain
// bytes are allocated.  Bytes are allocated semi-sparsely, the size of
// the byte array is only as big as the byte with the highest address.
// If a block has no bytes, the byte vector will be zero length; if it
// has 100 bytes then the byte vector will have 100 bytes.
//
//                        Address Architecture
//                        -------------------
//
// The location of each page, block, and byte is coded into the address.
// The address contains three fields, the page address, the block
// address, and the byte address.  The number of bits each field
// consumes is dependent on the parameter values supplied to the class.
// The page address is a key to a map that maps page keys to page
// objects.  The block address is the position of a block within a
// vector of blocks stored in a page.  The byte address is the position
// of the byte within a vector of bytes in a blocks.
//
//    +----------+----------+----------+
//    |   PAGE   |   BLOCK  |   BYTE   |
//    +----------+----------+----------+
//
// The total number of bits in the address is defined by the ADDR_BITS
// parameter.  The number of bits within the address used for the page
// address is defined by the PAGE_BITS parameter.  The number of bits
// for the block address is defined by the BLOCK_BITS parameter.  The
// numer of bits for the byte address is obtained by subtacting
// PAGE_BITS and BLOCK_BITS from ADDR_BITS.
//
// byte address bits = ADDR_BITS - PAGE_BITS - BLOCK_BITS
//
// For example, a memory defined as mem#(32,16,8,4) models a 32-bit
// address space.  Pages are addressed using the lefmost 16 bits.  The
// next 8 bits are used to address blocks, and the rightmost 8 bits are
// the byte addresses within a block.
//
//                          Bytes and Words
//                          ---------------
//
// An address refers to a single byte.  However, you can read and write
// the memory using multi-byte words.  The WORD_SIZE parameter defines
// the number of bytes contained in a word.  The value of WORD_SIZE must
// be a power of two.  Word reads and writes must be aligned to a word
// boundary.  Word reads and write cannot space blocks or pages, they
// must be contained within a single block.
//
//----------------------------------------------------------------------

typedef class mem;

virtual class mem_base#(int unsigned ADDR_BITS = 32,
                 int unsigned PAGE_BITS = 16,
                 int unsigned BLOCK_BITS = 8,
                 int unsigned WORD_SIZE = 4)
  extends object;

  typedef mem#(ADDR_BITS, PAGE_BITS, BLOCK_BITS, WORD_SIZE) mem_t;
  typedef bit [ADDR_BITS-1:0] addr_t;
  typedef bit [(WORD_SIZE*8)-1:0] word_t;
  typedef byte unsigned byte_t;

  // Address of a page
  typedef bit [PAGE_BITS-1:0] page_key_t;

  // Address of a block within a page
  typedef bit [BLOCK_BITS-1:0] block_addr_t;

  // Address of a byte within a block
  typedef bit [ADDR_BITS-PAGE_BITS-BLOCK_BITS-1:0] byte_addr_t;

  // Masks for retrieving the various parts of the address
  static const addr_t page_addr_mask  = ((addr_t'('1)) >> (ADDR_BITS - PAGE_BITS));
  static const addr_t block_addr_mask = ((addr_t'('1)) >> (ADDR_BITS - BLOCK_BITS));
  static const addr_t byte_addr_mask  = ((addr_t'('1)) >> (PAGE_BITS + BLOCK_BITS));
  static const addr_t word_addr_mask  = ((addr_t'('1)) >> (ADDR_BITS - $clog2(WORD_SIZE)));

  // Handle to the top memory object.  This is used for error reporting only.
  protected mem_t mem_root;

  // Security map -- maps addresses to restrictions
  protected map#(addr_t, restrict_t, restrict_traits) security_map;

  //--------------------------------------------------------------------
  // constructor
  //--------------------------------------------------------------------
  function new(mem_t root);
    mem_root = root;
    if(!check_parameters())
      set_error(ERROR_PARAMETERS_WRONG);
    security_map = new();
  endfunction

  //--------------------------------------------------------------------
  // function to do error checking on the class parameters.  Let's make
  // sure they are within the correct ranges and their values are
  // mutually consistent.
  // --------------------------------------------------------------------
  local function bit check_parameters();

    int unsigned word_bits;
    int unsigned one_bits;
    int unsigned word_size;
    bit ok = 1;

    ok &= ((ADDR_BITS > 0) && (PAGE_BITS > 0) && (BLOCK_BITS > 0) &&(WORD_SIZE > 0));

    // Count the number of 1 bits in WORD_SIZE.  There can only be one
    // if the value is indeed a power of 2.
    word_size = WORD_SIZE;
    while(word_size > 0) begin
      one_bits += word_size & 'h1;  // the low order bit
      word_size >>= 1;
    end

    ok &= (one_bits == 1);

    word_bits = $clog2(WORD_SIZE);
    ok &= (ADDR_BITS > (PAGE_BITS + BLOCK_BITS + word_bits));

    ok &= ( (ADDR_BITS - PAGE_BITS - BLOCK_BITS) > word_bits );

    return ok;
    
  endfunction

  //--------------------------------------------------------------------
  // Address part calculation interface
  //--------------------------------------------------------------------
  function page_key_t get_page_key(addr_t addr);
    return (addr >> (ADDR_BITS - PAGE_BITS)) & page_addr_mask;
  endfunction

  function block_addr_t get_block_addr(addr_t addr);
    return (addr >> (ADDR_BITS - BLOCK_BITS - PAGE_BITS)) & block_addr_mask;
  endfunction

  function byte_addr_t get_byte_addr(addr_t addr);
    return (addr & byte_addr_mask);
  endfunction

  function byte_addr_t get_aligned_byte_addr(addr_t addr);
    return (addr & byte_addr_mask & ~word_addr_mask);
  endfunction

  function bit is_word_aligned(addr_t addr);
    return ((addr & word_addr_mask) == 0);
  endfunction

  function addr_t construct_addr(page_key_t page_key,
                                           block_addr_t block_addr,
                                           byte_addr_t byte_addr);
    return ((page_key << (ADDR_BITS - PAGE_BITS)) |
            (block_addr << (ADDR_BITS - PAGE_BITS - BLOCK_BITS)) |
            (byte_addr));
  endfunction

  //====================================================================
  //
  // memory access interface
  //
  //====================================================================
  
  pure virtual function word_t read(addr_t addr);
  pure virtual function void write(addr_t addr, word_t data);
  pure virtual function byte_t read_byte(addr_t addr);
  pure virtual function void write_byte(addr_t addr, byte_t data);

  //--------------------------------------------------------------------
  // error reporting interface
  //--------------------------------------------------------------------
  function void set_error(error_t err);
    mem_root.set_last_error(err);
  endfunction

  //====================================================================
  //
  // Security Interface
  //
  // Every memory component has a security map that maps addresses to
  // restrictions.  The scope of the resiction is dependent on the type
  // of component.  The security map in the top-level component
  // restricts pages; the security map in the page component restricts
  // blocks; and the security map in the block component restricts
  // words.  The structure of the map is the same in each component
  // which is why we put the map and the access functions in the base
  // class.
  //
  //====================================================================

  //  set a security restriction in the local component secuirity map
  virtual function void set_restriction(addr_t addr, restrict_t r);
    void'(security_map.insert(addr, r));
  endfunction

  // Retrieve the security restriction in the local component security
  // map, if there is one.  Because the data structure of the security
  // map is map#() we know that if an entry does not exist for the
  // requested address then the empty element will be returned.  In this
  // case, using restrict traits, the empty element is RESTRICT_NONE.
  virtual function restrict_t get_restriction(addr_t addr);
    return security_map.get(addr);
  endfunction

  // clear the security restirction in the local component security map,
  // if there is one.
  virtual function void clear_restriction(addr_t addr);
    void'(security_map.delete(addr));
  endfunction

  // For a given address, return any security restriction associated
  // with that address, whether it comes from the page-, block-, or
  // word-level.  Each memory component is expected to provide this
  // function.  Users should only call the one in the top-level memory
  // component (i.e. mem#()) and not use the ones in the lower-level
  // components.
  pure virtual function restrict_t get_addr_restriction(addr_t addr);

  //====================================================================
  //
  // Dump Interface
  //
  // Each memory component is expected to dump its memory contents and
  // its security map.  The pure virtual functions provide the interface
  // for these operations. Only the function in the top-level component
  // should be called by the user.
  //====================================================================

  pure virtual function void dump_security(addr_t addr = 0);
  pure virtual function void dump(addr_t addr = 0);

  //====================================================================
  //
  // Debugging Interface
  //
  //====================================================================

  //--------------------------------------------------------------------
  // show the components of an address
  //--------------------------------------------------------------------
  function void show_addr(addr_t addr);
    $display("addr  = %b %x", addr, addr);
    $display("page  = %b %x", get_page_key(addr), get_page_key(addr));
    $display("block = %b %x", get_block_addr(addr), get_block_addr(addr));
    $display("byte  = %b %x", get_byte_addr(addr), get_byte_addr(addr));
  endfunction

  //--------------------------------------------------------------------
  // Show the memory organization. 
  //--------------------------------------------------------------------
  function void show();
    $display("address   = %0d bits", ADDR_BITS);
    $display("page      = %0d bits", PAGE_BITS);
    $display("block     = %0d bits", BLOCK_BITS);
    $display("byte addr = %0d bits", ADDR_BITS - PAGE_BITS - BLOCK_BITS);
    $display("word size = %0d bytes", WORD_SIZE);
    $display("page addr  mask = %b", page_addr_mask);
    $display("block addr mask = %b", block_addr_mask);
    $display("byte  addr mask = %b", byte_addr_mask);
    $display("word  addr mask = %b", word_addr_mask);
  endfunction
  
endclass
