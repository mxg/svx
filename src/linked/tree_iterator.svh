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
// Copyright 2026 Mark Glasser
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

// //----------------------------------------------------------------------
// // tree_random_iterator
// //----------------------------------------------------------------------
// class tree_random_iterator #(type T=int, type P=void_traits)
//   extends tree_iterator_base #(T,P)
//   implements random_intf#(T,P);

//   list_random_iterator#(tree, class_traits#(tree)) iter;

//   function new(tree t=null);
//     super.new(t);
//     iter = new(m_list);
//   endfunction

//   // The Verilator compiler doesn't seem to be able to find the
//   // implementations in the base class, so we give it a hint.
//   virtual function size_t size();
//     return super.size();
//   endfunction
    
//   virtual function bit is_empty();
//     return super.is_empty();
//   endfunction
  
//   virtual function void bind_tree(tree t=null, order_t order=PREORDER);
//     super.bind_tree(t, order);
//     iter = new(m_list);
//   endfunction  

//   virtual function void set(tree t);
//     // set is not implemented for tree iterators.  It's required here to
//     // satisfy the iterator interface.
//   endfunction

//   virtual function tree get();
//     return iter.get();
//   endfunction

//   //--------------------------------------------------------------------
//   // random_iterator interface functions
//   //--------------------------------------------------------------------

//   virtual function void set_seed(int seed);
//     iter.set_seed(seed);
//   endfunction

//   virtual function void set_default_seed();
//     iter.set_default_seed();
//   endfunction

//   virtual function bit random();
//     return iter.random();
//   endfunction

//   // skip
//   //
//   // The Verilator compiler could not find the skip() implementation
//   // in the base class, so we gave it a hint.
//   virtual function bit skip(signed_index_t distance);
//     return super.skip(distance);
//   endfunction

// endclass

//----------------------------------------------------------------------
// tree_iterator
//----------------------------------------------------------------------
class tree_iterator 
  implements fwd_intf#(tree, class_traits#(tree));

  typedef enum {PREORDER, POSTORDER} order_t;

  local tree m_tree;
  stack#(tree, class_traits#(tree)) stk;

  function new(tree t=null);
    m_tree = t;
    stk = new();
  endfunction

  //--------------------------------------------------------------------
  // size
  //
  // Traverse the tree to count the nodes. Note that this function has
  // the side effect of changing the marks in the tree nodes.
  //--------------------------------------------------------------------
  virtual function size_t size();
    size_t count = 0;
    stack#(tree, class_traits#(tree)) s;
    deque#(tree, class_traits#(tree)) q;
    list_iterator#(tree, class_traits#(tree)) iter;

    if(m_tree == null)
      return 0;

    m_tree.unmark_all();

    s = new();
    s.push(m_tree);
    
    while(!s.is_empty()) begin
      tree t = s.pop();

      if(t.is_marked())
	continue;

      t.mark();
      count++;
      
      // Get the set of children.
      q = t.get_children();
      iter = new(q);
      
      // Push all the children onto the stack.
      void'(iter.first());
      while(!iter.at_end()) begin
	tree t = iter.get();
	s.push(t);
	void'(iter.next());
      end
    end

    return count;
    
  endfunction
  
  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return (m_tree == null) || (size() == 0);
  endfunction
  
  //--------------------------------------------------------------------
  // get
  //
  // Retrieve the current tree node
  //--------------------------------------------------------------------
  virtual function tree get();
    if(is_empty())
      return null;
    return stk.peek();
  endfunction

  //--------------------------------------------------------------------
  // first
  //
  // Reset the iterator for a new traversal
  //--------------------------------------------------------------------
  virtual function bit first();
    if(is_empty())
      return 0;
    stk.clear();
    m_tree.unmark_all();
    stk.push(m_tree);
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // next
  //
  // Advance to the next node
  //--------------------------------------------------------------------
  virtual function bit next();
    tree t;
    deque#(tree, class_traits#(tree)) q;
    list_iterator#(tree, class_traits#(tree)) iter;

    if(at_end())
      return 0;

    t = stk.pop();

    // Get the set of children.
    q = t.get_children();
    iter = new(q);

    // Push all the children onto the stack.
    void'(iter.first());
    while(!iter.at_end()) begin
      tree c = iter.get();
      stk.push(c);
      void'(iter.next());
    end

    return 1;
    
  endfunction
 
  //--------------------------------------------------------------------
  // is_last
  //--------------------------------------------------------------------
  virtual function bit is_last();
    return (stk.size() == 0);
  endfunction

  //--------------------------------------------------------------------
  // at_end
  //--------------------------------------------------------------------
  virtual function bit at_end();
    return (stk.size() == 0);
  endfunction
  
  //--------------------------------------------------------------------
  // skip
  //
  // Skip ahead in the traversal
  //--------------------------------------------------------------------
  virtual function bit skip(signed_index_t distance);
    if(is_empty())
      return 0;
    for(index_t i = 0; i < distance; i++)
      void'(next());
    return 1;
  endfunction

endclass
