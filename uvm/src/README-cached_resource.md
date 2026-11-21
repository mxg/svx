Cached Resource
---------------

Looking up an item in the UVM resource database can be expensive. That
expense is minimal when used at the beginning of a simulation to
acquire configuration information.  However the costs grow when the
resource database is accessed frequently during simulation.

Nonetheless, the resource database is an attractive option for storing
and sharing data for many purposes as part of a UVM testbench.  The
cached resource mitigates the cost of frequent look-ups by caching the
resource.  After the initial resource database access, future accesses
of a resource can be done very efficiently via the cache.

The cached resource is parameterized like uvm_resource#():

  cached_resource#(T)

Here is the API:

  function bit is_empty();

  function bit get_the_latest(string scope,
                              string name,
                              inout  T val,
                              input  uvm_object accessor = null);

  function bit read_by_name(string scope,
                            string name,
                            inout  T val,
                            input  uvm_object accessor = null);
    
  function bit read(inout T val, uvm_object accessor = null);
  function void write(T val, uvm_object accessor = null);

** Use Models


The primary function is read_by_name().  It will first look to see if
the cache is empty.  If it is, it will retrieve a new resource from
the resource database.  If not, it will return the value in the cached
resource.  Get_the_latest() forces the cache to be update from the
resource database.  Read() and write() access the cached resource.
Read() will retrieve the value from the cached resource, and write()
will change the value in the cached resource.

Two (or more) cached resources can share the same resource.  Consider
two UVM components, A and B. A instantiate a cached resource an
populates it with a value.  E.g.

  cached_resource#(uint32_t) cr = new();
  if(!cr.read_by_name(get_full_name(), "size", size, this)) ...

B can do the same thing.  The underlying cached resource will be the
same for both cached resource instances. If one issues a write() then
both cached resources will see the same updated value.

The primary use model for a cached resource is for resources whose
value changes. There is no need to cache a resource whose value never
changes.  Because multiple cached resources can share the same UVM
resource object, a cached resource can be used as a means to
communicate information between processes -- a back channel, if you
will.

The following example has two processes, proc1 and proc2.  Proc1 sends
bytes (through some channel) to proc2).  Additionally, it informs
proc2 of how many bytes to expect via a cached resource.  This model
presumes, of course that the value of n_bytes is set by proc1 before
proc2 consume it.

  -- process 1

```
  task proc2();
    uint32_t n_bytes;
    cached_resource#(uint32_t) n_bytes_rsrc = new();

    n_bytes_rsrc.read_by_name(get_full_name(), "bytes", n_bytes, this);

    for(uint32_t idx = 0; idx < 1000; idx++) begin
       n_bytes = $random_range(256, 8);
       n_bytes_rsrc.write(n_bytes, this);
       ...
    end
  endtask
```
  
  -- process 2

```
  task proc2();
    uint32_t n_bytes;
    cached_resource#(uint32_t) n_bytes_rsrc = new();

    forever begin
      n_bytes_rsrc.read_by_name(get_full_name(), "bytes", n_bytes, this);
      for(uint32_t idx = 0; idx < n_bytes, idx++) begin
      ...
    end
  endtask
```

Another use model is similar, but is asynchronous. It relies on the
resource notifying its consumers that a new value is ready.  Proc1 is
the same, but proc2 waits for the changed resource.

  -- process 2

```
  task proc2();
    uint32_t n_bytes;
    cached_resource#(uint32_t) n_bytes_rsrc = new();

    forever begin
      n_bytes_rsrc.wait_for_change();
      n_bytes_rsrc.read_by_name(get_full_name(), "bytes", n_bytes, this);
      for(uint32_t idx = 0; idx < n_bytes, idx++) begin
      ...
    end
  endtask
```

As its name implies, the wait_for_change() task blocks until the
resource changes value.

                              * * * * *



