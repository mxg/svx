//======================================================================
//
//               .oooooo..o oooooo     oooo ooooooo  ooooo     
//              d8P'    `Y8  `888.     .8'   `8888    d8'      
//              Y88bo.        `888.   .8'      Y888..8P        
//               `"Y8888o.     `888. .8'        `8888'         
//                   `"Y88b     `888.8'        .8PY888.        
//              oo     .d8P      `888'        d8'  `888b       
//              8""88888P'        `8'       o888o  o88888o
//
//                  SystemVerilog Extension Library
//
//
// Copyright 2016 NVIDIA Corporation
// Copyright 2016 Mark Glasser
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
// implied.  See the License for the specific language governing
// permissions and limitations under the License.
//======================================================================

//----------------------------------------------------------------------
// Permutation Iterators
//
// A permutation is an ordering of elements in a list.  The permutation
// iterators allow you to retrieve elements of a list in various
// permutations.  Like the other iterators in this library, the
// permutation iterator binds to a container, in this case a vector.
// The permutation iterator generates a permutation and then makes it
// available externally.  The bound vector is not modified in any way.
// The ordering of the bound vector represents permutation 0.  All other
// permutations are based on this initial ordering.
//
// The permutation iterators store the iterations in an internal vector,
// the permutation vector, pv.  This vector contains a list of integers
// from 0 .. n-1, where n is the number of elements in the bound vector.
// Each pv entry represents an index into the bound vector.  For
// example, let's say the bound vector contains the strings {"A", "B",
// "C", "D"} (in that order).  Permutation 0 is {0, 1, 2, 3} which
// represents the original order of the bound vector.  A vector of
// length 4 has 24 permutations.  Permutation 8, to pick one as an
// example, is the ordering {"B", "C", "A", "D"}.  For permutation 8, pv
// would contain {1, 2, 0, 3}.
//
// Two functions are used to generate permutations -- next_permutation()
// and set_permutation().  Both of these functions manipulate the
// contents of the permutation vector.  Next_permutation finds the next
// sequential permutation given a current one.  Set_permutation() takes
// an integer n in the range if 0 .. (k!-1) and generates the nth
// permutation in the sequence of permutations.
//
// The permutation iterators do not implement set() and get() in the
// iterator base class like the other iterators.  These functions do not
// really have any meaning for the permutation iterator.  Instead, you
// retrieve the permutations in two different ways.  The function
// get_nth() returns the nth element in the permutation, where n is the
// index into the permutation vector.  Using our example above,
// get_nth(0) would return "B", get_nth(1) would return "C", and so
// forth.  The second way is to get a copy of the permutation vector by
// calling get_permutation_vector().  It returns an object of type
// vector#(int, int_traits) that contains the current permutation.
// Additionally, you can retrieve the permutation index by calling
// get_permutation_index().
//
// Once a vector is bound to a permutation iterator care should be take
// not to modify the vector.  Doing so will disturb the results
// presented by the permutation iterator.  If it's necessary to modify a
// vector and restart the permutations, then you can call initialize()
// to reset the permutation vector.
// ----------------------------------------------------------------------

// An in-line macro to swap two unsigned integers. This is used in the
// permutation algorithms. Using a macro in this case makes the code
// look a little cleaner.

`define SWAP(a, b) begin index_t t = a; a = b; b = t; end

//----------------------------------------------------------------------
// permute_iterator_base
//
// Base class for permutation iterators.
//----------------------------------------------------------------------
class permute_iterator_base #(type T=int, type P=void_traits);

  localparam T m_empty = P::empty;

  typedef vector#(T,P) vec_t;
  protected vec_t m_vec;

  // This is the vector that holds the permutations.  It is an ordered
  // list of indexes into the bound vector.  It is the same size as the
  // bound vector, so every element in the bound vector is represented
  // in the permutation vector (pv).
  protected index_t pv[];

  // This is somewhat arbitrary. Computing the factorial of numbers
  // larger than 34 results in a value that is too large to hold
  // in a variable of type longint unsigned.
  local const int unsigned max_fact = 34;

  // permutation index
  protected signed_index_t pix;

  // A precomputed factorial
  local index_t fact;

  // Largest permutation for a given list
  protected signed_index_t max_pix;

  // Has the iterator been initialized?
  protected bit initialized;

  // Usual constructor. If a vector argument is supplied then it is
  // bound to the iterator.  Otherwise, if the vector argument is
  // omitted then the iterator is unbound.  You can later use
  // bind_vector to bind a vector.

  function new(vec_t v = null);
    bind_vector(v);
  endfunction

  //--------------------------------------------------------------------
  // bind_vector
  //--------------------------------------------------------------------
  virtual function void bind_vector(vec_t v);
    if(v == null)
      return;
    m_vec = v;
    initialize();
  endfunction

  //--------------------------------------------------------------------
  // size
  //--------------------------------------------------------------------
  virtual function size_t size();
    return m_vec.size();
  endfunction

  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return (m_vec == null) || (size() == 0);
  endfunction
  
  //--------------------------------------------------------------------
  // factorial
  //
  // A little utility to compute n!
  //--------------------------------------------------------------------
  protected function longint unsigned factorial(longint unsigned n);
    return (n <= 2)
      ? n
      : (n * factorial(n-1));
  endfunction

  //--------------------------------------------------------------------
  // initialize
  //--------------------------------------------------------------------
  protected function void initialize();
    index_t i;

    pv = new [int'(m_vec.size())];

    // create a list of small integers from 0 to n-1.
    for (i = 0; i < m_vec.size(); i++) begin
      pv[i] = i;
    end

    // pre-compute factorials once so we don't have to do
    // it for each permutation operation
    fact = (m_vec.size < 2)
                ? m_vec.size()
                : factorial(m_vec.size()-1);
    max_pix = fact * m_vec.size();
    pix = 0;

    initialized = 1;
    
  endfunction
  
  //--------------------------------------------------------------------
  // set
  //
  // set() is not implemented for the permute iterators
  //--------------------------------------------------------------------
  virtual function void set(T t);
    // intentionally not implemented
  endfunction
  
  //--------------------------------------------------------------------
  // get
  //
  // get() is not implemented for the permute iterators
  //--------------------------------------------------------------------
  virtual function T get();
    // intentionally not implemented
    return m_empty;
  endfunction

  //--------------------------------------------------------------------
  // get_nth
  //
  // Return the nth item for the current permutation.
  //--------------------------------------------------------------------
  virtual function T get_nth(index_t n);

    index_t idx;

    if((m_vec == null) || (m_vec.size() == 0) || (n >= m_vec.size()))
      return m_empty;
    idx = pv[n];
    return m_vec.read(idx);

  endfunction

  //--------------------------------------------------------------------
  // get_permutation_index
  //
  // Return the current value of pix, the permutation index
  //--------------------------------------------------------------------
  virtual function longint get_permutation_index();
    return pix;
  endfunction

  //--------------------------------------------------------------------
  // get_permutation_vector
  //
  // Return a copy of the current permutation vector.  The permutation
  // vector contains the ordering of the elements for the current
  // permutation.
  // --------------------------------------------------------------------
  virtual function vector#(index_t, uint64_traits)get_permutation_vector();
    index_t i;
    vector#(index_t, uint64_traits) v = new();

    for(i = 0; i < index_t'(pv.size()); i++)
      v.appendc(pv[i]);

    return v;
    
  endfunction

  //--------------------------------------------------------------------
  // skip
  //
  // Skip iterations, either forward or backward.  When distance > 0
  // then skipping is done in the forward direction, when distance is <
  // 0 then skipping is done in the reverse direction.  Skipping will
  // not leave the iterator in an unstable state.  That is, you cannot
  // skip forward beyond the last iteration or backwards less than 0.
  //--------------------------------------------------------------------
  virtual function bit skip(signed_index_t distance);

    signed_index_t tmp_idx;

    // Increment or decrement the index using the distance.  Distance
    // may be less than zero.
    tmp_idx = pix + distance;

    // Is the new (computed) index within range of the current list?
    if ((m_vec == null) || (tmp_idx < 0) || (tmp_idx >= max_pix))
      return 0;

    // New index is in the valid range, 
    pix = tmp_idx;
    return 1;

  endfunction

  //====================================================================
  //  Permutation functions
  //
  // These are for computing permutations and are not part of the user
  // interface.  They are used by the permutation iterator classes.
  //====================================================================


  //--------------------------------------------------------------------
  // set_permutation
  //
  // Return permutation n, where n is in the range of [0,(s! - 1)]. s is
  // the size of the permutation vector
  // --------------------------------------------------------------------
  protected function bit set_permutation(index_t n);

    index_t i;
    index_t j;
    index_t tempi;
    index_t temp;
    index_t len;
    index_t f;

    // If the iterator has not been initialized then there is nothing we
    // can do.
    if(!initialized) begin
      return 0;
    end

    len = index_t'(pv.size());
    f = fact; // sets f to the pre-computed value of len! (i.e. factorial of len).

    // reset pv vector
    for (i = 0; i < m_vec.size(); i++) begin
      pv[i] = i;
    end

    for(i = 0; i < len - 1; i++) begin

      tempi = (n / f) % (len - i);
      temp = pv[i + tempi];

      for(j = i + tempi; j > i ; j--)
        pv[j] = pv[j-1];

      pv[i] = temp;
 
      f /= (len - i - 1);
 
    end 

    pix = n;
    return 1;

  endfunction

  //--------------------------------------------------------------------
  // next_permutation
  //
  // Given the current permutation, compute the next one
  // lexicographically.
  //--------------------------------------------------------------------
  protected function bit next_permutation();

    signed_index_t i;
    signed_index_t j;
    signed_index_t k;
    signed_index_t n;

    if(!initialized) begin
      return 0;
    end

    n = signed_index_t'(pv.size());
    for(i = n - 2; (i >= 0) && (pv[i] > pv[i + 1]); i--);
  
    // If i is smaller than 0, then there are no more permutations,
    // so we return 0.
    if (i < 0) begin  
      pix++;
      return 0;
    end
  
    // Find the largest element after pv[i] but not larger than pv[i]
    for(k = n - 1; pv[i] > pv[k]; k--);
    `SWAP(pv[i], pv[k]);   
  
    // Swap the last n - i elements.
    k = 0;   
    for (j = i + 1; j < (n + i) / 2 + 1; ++j) begin
      `SWAP(pv[j], pv[n - k - 1]);
      k++;
    end

    pix++;
    return 1;
    
  endfunction

  //--------------------------------------------------------------------
  // print
  //
  // Print the current permutation
  //--------------------------------------------------------------------
  function void print();

    index_t i;

    if(!initialized) begin
      $display("<uninitialized>");
      return;
    end

    $write("%0d:", pix);

    for(i = 0; i < index_t'(pv.size()); i++) begin
      $write(" %0d", pv[i]);
    end
    $display();
  endfunction
  
endclass

//----------------------------------------------------------------------
// permute_random_iterator
//
// Jump to a randomly chosen iterator.
//----------------------------------------------------------------------
class permute_random_iterator#(type T=int, type P=void_traits)
  extends permute_iterator_base#(T,P)
  implements random_intf#(T,P);

  local const int default_seed = 1;

  // constructor
  //
  // Optionally, bind a vector to the iterator.
  function new(vec_t vec = null);
    super.new(vec);
    set_default_seed();
  endfunction

  // The Verilatorcompiler doesn't seem to be able to find the
  // implementations in the base class, so we give it a hint.
  virtual function size_t size();
    return super.size();
  endfunction
    
  virtual function bit is_empty();
    return super.is_empty();
  endfunction

  // set_seed
  //
  // Set a new random seed.
  virtual function void set_seed(int seed);
    int n = $urandom(seed);
  endfunction

  // set_default_seed
  //
  // Return the seed to the default
  virtual function void set_default_seed();
    set_seed(default_seed);
  endfunction

  // random
  //
  // Jump to a randomly chosen permutation.
  virtual function bit random();
    signed_index_t tmp_pix;

    // Check for error conditions.
    if((m_vec == null) || (m_vec.size() == 0))
      return 0;

    tmp_pix = signed_index_t'($urandom()) % max_pix;
    pix = tmp_pix;
    void'(set_permutation(pix));
    return 1;
  endfunction

  // skip
  //
  // The Verilator compiler could not find the skip() implementation
  // in the base class, so we gave it a hint.
  virtual function bit skip(signed_index_t distance);
    return super.skip(distance);    
  endfunction

endclass

//----------------------------------------------------------------------
// permute_iterator
//
// Traverse the set of permutations both forwards and backwards.
// ----------------------------------------------------------------------
class permute_iterator#(type T=int, type P=void_traits)
  extends permute_iterator_base#(T,P)
  implements fwd_intf#(T,P), bkwd_intf#(T,P);

  function new(vec_t vec = null);
    super.new(vec);
  endfunction
  
  // The Verilator compiler doesn't seem to be able to find the
  // implementations in the base class, so we give it a hint.
  virtual function size_t size();
    return super.size();
  endfunction
    
  virtual function bit is_empty();
    return super.is_empty();
  endfunction

  virtual function void set(T t);
    // intentionally not implemented
  endfunction

  virtual function T get();
    // intentionally not implemented
    return m_empty;
  endfunction
  
  virtual function bit first();
    if((m_vec == null) || (m_vec.size() == 0))
      return 0;
    initialize();
    void'(set_permutation(0));
    return 1;
  endfunction

  virtual function bit next();
    if((m_vec == null) || !initialized)
      return 0;
    return next_permutation();
  endfunction

  virtual function bit is_last();
    return ((m_vec != null) && (m_vec.size() > 0) && (pix >= max_pix - 1));
  endfunction

  virtual function bit at_end();
    if(m_vec == null || m_vec.size() == 0)
      return 1;
    return (pix >= max_pix);
  endfunction

  virtual function bit last();
    if(m_vec == null)
      return 0;
    pix = max_pix - 1;
    void'(set_permutation(pix));
    return 1;
  endfunction

  virtual function bit prev();
    if(m_vec == null || m_vec.size() == 0 || pix < 0)
      return 0;
    pix--;
    void'(set_permutation(pix));
    return 1;
  endfunction
  
  virtual function bit is_first();
    return ((m_vec != null) && ((m_vec.size() > 0) && (pix == 0)));
  endfunction

  virtual function bit at_beginning();
    if(m_vec == null || m_vec.size() == 0)
      return 1;
    return (pix < 0);
  endfunction

  // skip
  //
  // The Verilator compiler could not find the skip() implementation
  // in the base class, so we gave it a hint.
  virtual function bit skip(signed_index_t distance);
    return super.skip(distance);
  endfunction
  

endclass
