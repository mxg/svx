virtual class typed_iterator #(type T=int, type P=void_traits)
  extends object;

  protected T m_empty;

  function new();
    /* verilator lint_off CASTCONST */
    assert(bit'($cast(m_empty, P::empty)));
    /* verilator lint_on CASTCONST */
  endfunction

  // Set the value of the item at the current index
  pure virtual function void set(T t);

  // Retrieve the iterm at the current index
  pure virtual function T get();

endclass

