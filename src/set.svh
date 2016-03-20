//----------------------------------------------------------------------
// class: set
//----------------------------------------------------------------------
class set #(type T=int) extends typed_collection#(T);

  typedef set#(T) this_type;

  local bit m_set[T];

  //--------------------------------------------------------------------
  // group: Set Inclusion
  //--------------------------------------------------------------------

  function void insert(T t);
    if(m_set.exists(t))
      return;
    m_set[t] = 1;
  endfunction

  function void delete(T t);
    if(!m_set.exists(t))
      return;
    m_set.delete(t);

  function bit is_empty();
    return (m_set.size() == 0);
  endfunction

  //--------------------------------------------------------------------
  // group: Algorithms
  //--------------------------------------------------------------------

  function void intersection(this_type s);

    this_type result = new();

    // if either set is empty then intersection empty, so return an
    // empty result;

    if(!first() || !s.first())
      return result;

    do begin
      while(s.curr() < curr()) begin
        s.next();
      end
      if(s.curr
    end
    while(next());

  endfunction

  function void union(this_type);
  endfunction

  function void difference(this_type);
  endfunction

endclass

