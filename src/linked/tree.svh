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
//  TREE
//
// Classic tree data structure.  Each node has exactly one parent,
// except for the root node that has zero parents.  Each node is a
// container that can hold an object of arbitrary type. Each node has a
// name which allows the tree to represent hierarchies.  Hierarchical
// path names are supported, using the dot (.) as the hierarchy
// separator.
//----------------------------------------------------------------------


//----------------------------------------------------------------------
// class: tree
//----------------------------------------------------------------------
class tree extends node;

  local string full_name;
  local tree parent;
  local map#(string, tree, void_traits) m_children;

  //--------------------------------------------------------------------
  // Constructor
  //
  // Create a new tree node with a name.  Construct the full path name
  // to this node and store it in m_full_name.  The constructor inserts
  // the new node as a child of the parent, thus linking the new node
  // into the tree.
  // --------------------------------------------------------------------
  function new(string nm, tree p);

    set_name(nm);
    parent = p;

    // If we have a parent then we need to hook ourselves in as a child
    // of the parent and assemble our full name
    if(parent != null) begin
      parent.insert(this);
      full_name = { parent.get_full_name(), ".", get_name() };
    end
    else begin
      // no parent means we are at the top -- name and full name are the
      // same.
      full_name = get_name();
    end

    m_children = new();
  endfunction

  // function: insert
  //
  // insert a new node into the tree.

  //--------------------------------------------------------------------
  // function: insert
  //
  // insert a new node into the tree as a child of the current node.
  // The name must be unique amongst all its siblings.
  //
  // TODO: Remove $display; Use return code instead
  //--------------------------------------------------------------------
  function void insert(tree t);
    
    if(t == null)
      return;

    if(!m_children.insert(t.get_name(), t))
      $display("*error* A child whose name is %s is already a child of this node",
	       t.get_name());
    
  endfunction

  //--------------------------------------------------------------------
  // group: Accessors
  //--------------------------------------------------------------------

  // return a handle to this node's parent

  function tree get_parent();
    return parent;
  endfunction

  // Return the fully qualified hierarchical name
  
  function string get_full_name();
    return full_name;
  endfunction

  // function: first_child
  //
  // Obtain the index (name) of the first child in the set of children
  // for this tree node.  If there are no children then the return value
  // is zero.
 
  function bit first_child(ref string nm);
    if(m_children == null)
      return 0;
    return m_children.first(nm);
  endfunction

  // function: next_child
  //
  // Obtain the index (name) of the next child in the set of children
  // for this tree node.  If there is no next child return 0;

  function bit next_child(ref string nm);
    if(m_children == null)
      return 0;
    return m_children.next(nm);
  endfunction

  // Return the number of children of the current node.

  function int unsigned num_children();
    if(m_children == null)
      return 0;
    return m_children.size();
  endfunction

  //--------------------------------------------------------------------
  // function: get_children
  //
  // Return the set of children owned by this node.  In order to avoid
  // any tampering with the m_children list, m_children is local and
  // this function returns a queue of the entries in the m_children
  // associative array.
  //
  // The children are put into a deque structure and handed back through
  // the function call return.  If there are no children the deque
  // structure is not created and null is returned.
  // --------------------------------------------------------------------

  function deque#(tree, class_traits#(tree)) get_children();

    deque#(tree, class_traits#(tree)) deq;
    tree t;
    string nm;

    if(!first_child(nm))
      return null;

    deq = new();

    do begin
      deq.push_back(get_child(nm));
    end
    while(next_child(nm));

    return deq;

  endfunction

  //--------------------------------------------------------------------
  // function: child
  //
  // Given the name of a child, return the handle to the child node.  If
  // the child doesn't exist for this node then return null.
  //--------------------------------------------------------------------

  function tree get_child(string nm);
    return m_children.get(nm);
  endfunction

  //======================================================================
  //
  // Searching
  //
  //======================================================================


  //----------------------------------------------------------------------
  // Find a node by its path name.  The path name is parsed into an
  // ordered set of name elements and each element is put into a
  // queue. The queue is passed to the find_recurse routine which gets
  // the first item from the queue and searches the children to see if a
  // child with that name exists.  If so, then it continues the search
  // with the located child. This continues recursively until either the
  // tree node is located or a leaf is reached and the search can
  // proceed no further.
  //----------------------------------------------------------------------
  function tree find(string path);
    
    queue#(string, string_traits) q = new();
    lexer_core lex = new();
    token_t token;
    string id;
    
    // parse path name. The path name must be a set of name elements
    // separated by dots.  A name element is a string that begins with a
    // letter or underbar and contains only letters, numbers, and
    // underbars.
    
    lex.start(path);
    do begin
      token = lex.get_token();
      if(token != TOKEN_ID)
	break;
      id = lex.get_lexeme();
      q.put(id);
      token = lex.get_token();
      if(token != TOKEN_DOT && token != TOKEN_EOL)
	break;
    end while(token != TOKEN_EOL);

    return find_recurse(this, q);

  endfunction

  local function tree find_recurse(tree t, ref queue#(string, string_traits) q);

    string id;
    tree c;

    if(t == null || q == null)
      return null;

    if(q.is_empty())
      return t;
    
    id = q.get();
    c = t.get_child(id);

    return find_recurse(c, q);

  endfunction
  
  //====================================================================
  // group: Marking
  //
  // Various algorithms may need to mark and unmark nodes in the tree.
  // Here is a function interface that supports that.
  //====================================================================

  // Mark all the nodes in the tree.  Traverse the tree and call mark()
  // on every node

  function void mark_all();

    string nm;
    tree c;

    mark();

    if(!first_child(nm))
      return;

    do begin
      c = get_child(nm);
      c.mark_all();
    end
    while(next_child(nm));

  endfunction

  // Unmark all the nodes in the tree.  Traverse the tree and call
  // unmark() on every node.

  function void unmark_all();

    string nm;
    tree c;

    unmark();

    if(!first_child(nm))
      return;

    do begin
      c = get_child(nm);
      c.unmark_all();
    end
    while(next_child(nm));

  endfunction

endclass
