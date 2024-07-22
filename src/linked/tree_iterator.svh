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
// tree_iterator
//----------------------------------------------------------------------
virtual class tree_iterator_base
  extends typed_iterator#(tree, void_traits);

  typedef enum {PREORDER, POSTORDER} order_t;

  typedef deque#(tree, class_traits#(tree)) list_t;

  protected tree m_tree;
  protected list_t m_list;

  function new(tree t=null, order_t order=PREORDER);
    super.new();
    bind_tree(t, order);
  endfunction

  virtual function void bind_tree(tree t=null, order_t order=PREORDER);
    m_tree = t;
    generate_list(order);
  endfunction

  virtual function tree get();
    return null;
  endfunction

  virtual function void set(tree t);
    // set is not implemented for tree iterators.  It's required here to
    // satisfy the iterator interface.
  endfunction

  virtual function bit skip(signed_index_t distance);
    return 0;
  endfunction

  //--------------------------------------------------------------------
  // generate_list
  //--------------------------------------------------------------------
  protected function void generate_list(order_t order);
    
    if(m_tree == null)
      return;

    m_list = new();

    case(order)
      PREORDER:    preorder_recurse(m_tree);
      POSTORDER:   postorder_recurse(m_tree);
    endcase

  endfunction

  protected function void preorder_recurse(tree t);

    string name;
    tree c;

    m_list.push_back(t);

    if(!t.first_child(name))
      return;

    do begin
      c = t.get_child(name);
      preorder_recurse(c);
    end
    while(t.next_child(name));

  endfunction    

  protected function void postorder_recurse(tree t);

    string name;
    tree c;

    if(t.first_child(name)) begin
      do begin
        c = t.get_child(name);
        postorder_recurse(c);
      end
      while(t.next_child(name));
    end

    m_list.push_back(t); 

  endfunction

endclass

//----------------------------------------------------------------------
// tree_fwd_iterator
//----------------------------------------------------------------------
class tree_fwd_iterator extends tree_iterator_base
  implements fwd_iterator;

  list_fwd_iterator#(tree, class_traits#(tree)) iter;

  function new(tree t=null);
    super.new(t);
    iter = new(m_list);
  endfunction

  virtual function void bind_tree(tree t=null, order_t order=PREORDER);
    super.bind_tree(t, order);
    iter = new(m_list);
  endfunction  

  virtual function tree get();
    return iter.get();
  endfunction

  virtual function bit skip(signed_index_t distance);
    return iter.skip(distance);
  endfunction
  
  virtual function bit first();
    if(iter == null)
      return 0;
    return iter.first();
  endfunction

  virtual function bit next();
    return iter.next();
  endfunction

  virtual function bit is_last();
    return iter.is_last();
  endfunction

  virtual function bit at_end();
    return iter.at_end();
  endfunction

endclass  

//----------------------------------------------------------------------
// class: tree_bkwd_iterator
//----------------------------------------------------------------------
class tree_bkwd_iterator extends tree_iterator_base
  implements bkwd_iterator;

  list_bkwd_iterator#(tree, class_traits#(tree)) iter;

  function new(tree t=null);
    super.new(t);
    iter = new(m_list);
  endfunction

  virtual function void bind_tree(tree t=null, order_t order=PREORDER);
    super.bind_tree(t, order);
    iter = new(m_list);
  endfunction  

  virtual function tree get();
    return iter.get();
  endfunction

  //--------------------------------------------------------------------
  // bkwd_iterator interface functions
  //--------------------------------------------------------------------

  virtual function bit skip(signed_index_t distance);
    return iter.skip(distance);
  endfunction

  virtual function bit last();
    return iter.last();
  endfunction

  virtual function bit prev();
    return iter.prev();
  endfunction
  
  virtual function bit is_first();
    return iter.is_first();
  endfunction

  virtual function bit at_beginning();
    return iter.at_beginning();
  endfunction

endclass

//----------------------------------------------------------------------
// tree_random_iterator
//----------------------------------------------------------------------
class tree_random_iterator extends tree_iterator_base
  implements random_iterator;

  list_random_iterator#(tree, class_traits#(tree)) iter;

  function new(tree t=null);
    super.new(t);
    iter = new(m_list);
  endfunction

  virtual function void bind_tree(tree t=null, order_t order=PREORDER);
    super.bind_tree(t, order);
    iter = new(m_list);
  endfunction  

  virtual function tree get();
    return iter.get();
  endfunction

  //--------------------------------------------------------------------
  // random_iterator interface functions
  //--------------------------------------------------------------------

  virtual function void set_seed(int seed);
    iter.set_seed(seed);
  endfunction

  virtual function void set_default_seed();
    iter.set_default_seed();
  endfunction

  virtual function bit random();
    return iter.random();
  endfunction

endclass

//----------------------------------------------------------------------
// tree_bidir_iterator
//----------------------------------------------------------------------
class tree_bidir_iterator extends tree_iterator_base
  implements fwd_iterator, bkwd_iterator;

  list_bidir_iterator#(tree, class_traits#(tree)) iter;

  function new(tree t=null);
    super.new(t);
    iter = new(m_list);
  endfunction

  virtual function void bind_tree(tree t=null, order_t order=PREORDER);
    super.bind_tree(t, order);
    iter = new(m_list);
  endfunction  

  virtual function tree get();
    return iter.get();
  endfunction


  //--------------------------------------------------------------------
  // fwd_iterator and bkwd_iterator interface functions
  //--------------------------------------------------------------------
  
  virtual function bit first();
    return iter.first();
  endfunction

  virtual function bit next();
    return iter.next();
  endfunction

  virtual function bit is_last();
    return iter.is_last();
  endfunction

  virtual function bit at_end();
    return iter.at_end();
  endfunction
  
  virtual function bit last();
    return iter.last();
  endfunction

  virtual function bit prev();
    return iter.prev();
  endfunction
  
  virtual function bit is_first();
    return iter.is_first();
  endfunction

  virtual function bit at_beginning();
    return iter.at_beginning();
  endfunction

endclass
