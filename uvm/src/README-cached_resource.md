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

  * new(string _scope, string _name, bit leave_unbound = 0);

    Constructor for a cached_resource.  If leave_unbound is 1 then do
    not bind the name and scope to a UVM resource.  If it is 0 then
    attempt to bind to a resource.
    
  * bit is_empty();

    Is the cached_resource bound to a resource?  If not, returns 1, 0
    otherwise.
    
  * void refresh();

    Update the cache.  If unbound, then bind to a resource.

  * bit get_the_latest(inout T val,
	               input  uvm_object accessor = null);

    Update the cache and return the latest value through the val
    argument.
   
  * bit read(inout T val, input uvm_object accessor);

    Return the value stored in the bound resource.
    
  * void write(T val, input uvm_object accessor);

    Write a new value to the bound resource.
    
  * task wait_for_change();

    blocking task that unblocks when the bound resource changes value
    through write() on any cached_resource bound to it.  Writing the
    same value does not unblock it.  Changes made through the
    uvm_resource or uvm_resource_db API do not unblock it at all.

** Use Models

A name and a scope represent a resource in the resource database.
When a new cached_resource is created and the leave_unbound
constructor argument is 0 then the constructor does a search in the
UVM resource database to retrieve the resource with the matching name
and scope. If the cached_resource is left unbound it can be bound to a
resource later by calling refresh().

Two (or more) cached resources can share the same resource.  Consider
two UVM components, A and B. A instantiates a cached resource and
populates it with a value.  E.g.

  cached_resource#(uint32_t) cr = new(get_full_name(),  name);
  if(!cr.read(size, this)) begin
    ...
  end

B can do the same thing.  The underlying cached resource will be the
same for both cached resource instances. If one issues a write() then
both cached resources will see the same updated value.

The primary use model for a cached resource is for resources whose
value changes. There is no need to cache a resource whose value never
changes.  Because multiple cached resources can share the same UVM
resource object, a cached resource can be used as a means to
communicate information between processes -- a back channel, if you
will.

You can change the value of a cached resource by calling
write(). Other cached_resources that have cached the same resource
will see the new value the next time they call read().  You can also
use the blocking task wait_for_change() to unblock when the underlying
resource changes value.  It will not unblock if the new value is the
same as the old value.  You can have multiple waiters. All will
unblock when the value changes.

The following example has two processes, proc1 and proc2.  Proc1 sends
bytes (through some channel) to proc2.  Additionally, it informs proc2
of how many bytes to expect via a cached resource.  This model
presumes, of course, that the value of n_bytes is set by proc1 before
proc2 consumes it. Of course, proc2 requires some blocking statement,
such as a blocking get to retrieve bytes or a clock control to prevent
the loop from spinning endlessly.

  -- process 1

```
  task proc1();
    uint32_t n_bytes;
    cached_resource#(uint32_t) n_bytes_rsrc = new(get_full_name(), "bytes");

    n_bytes_rsrc.read(n_bytes, this);

    for(uint32_t idx = 0; idx < 1000; idx++) begin
      n_bytes = $urandom_range(256, 8);
      n_bytes_rsrc.write(n_bytes, this);
      ... // send bytes through channel
    end
  endtask
```
  
  -- process 2

```
  task proc2();
    uint32_t n_bytes;
    cached_resource#(uint32_t) n_bytes_rsrc = new(get_full_name(), "bytes");

    forever begin
      n_bytes_rsrc.read(n_bytes, this);
      for(uint32_t idx = 0; idx < n_bytes; idx++) begin
        ... // retrieve bytes from channel
      end
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
    cached_resource#(uint32_t) n_bytes_rsrc = new(get_full_name(), "bytes");

    forever begin
      n_bytes_rsrc.wait_for_change();
      n_bytes_rsrc.read(n_bytes, this);
      for(uint32_t idx = 0; idx < n_bytes, idx++) begin
        ...
      end
    end
  endtask
```

As its name implies, the wait_for_change() task blocks until the
resource changes value.

To ensure that wait_for_change triggers correctly, the cached_resource
tracks changes.  However, it can only track changes made through the
cached_resource interface.  If a resource's value is changed by other
means then wait_for_change will noit unblock waiters. Calling refresh
will go back to the resource database to obtain the latest resource
matching the name and scope provided to the cached_resource.

Note that read() and write() are atomic and ordering is not enforced.
Wait_for_change() will only make the change in the NBA region, after
all changes have settled for the current time step.

                              * * * * *



