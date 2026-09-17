Priority Queue
--------------

The priority queue has two primary operations -- push and pop.  In
addition to the data item to be added to the queue, push() also takes
a priority value.  Pop() removes the next item with the highest
priority value.  Items with the same priority are popped in FIFO
order.

```
  function void push(pri_t pri, T item);
  function T pop();
```

The utility interface is the same as for other containers derived from
typed_container#(T,P).

```
  virtual function bit is_empty();
  virtual function size_t size();
  virtual function void clear();
```

Implementation
--------------

The priority queue is based on a map#(). Each map entry is a queue,
and the key is the priority value.  Entries that have the same
priority value are pushed into the same queue.

The map has a function last(), which gets the last item in the map
based on sort order.  Because the priority value is an integer, the
last map entry is the highest priority value.  Retrieving the highest
priority item is simply a matter of getting the last item in the
map#().