(       Title:  Double Linked Lists
         File:  dlists.fs
       Author:  David.N.Williams@umich.edu
      License:  LGPL
Starting date:  July 29, 1995
Last revision:  August 20, 1996

Note: This code was the starting point for our single/double lists,
version 1.0.1.  Besides the fact that it treats only double lists and is
more sparsely documented, it differs from the more recent code by keeping
space for nodes in each list instance, rather than putting node spaces into
separate structures.  The simpler scheme used here is perfectly adequate
when it makes sense for each list instance to have a dedicated node space.
)
\ Copyright (C) 1996 by David N. Williams
(
This library is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or at your
option any later version.

This library is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
for more details.

You should have received a copy of the GNU Lesser General Public License
along with this library; if not, write to the Free Software Foundation,
Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.

Please see the file POLITENESS included with this file.
)
(
ANS Forth compatible except for:
 - case sensitivity
 - the word "0$unused" is for ^Forth strings, and can otherwise be removed
 - "NIF", equivalent to the phrase "0= IF"
 - "cell", equivalent to the phrase "1 CELLS"
 - "cell-", equivalent to the phrase "1 CELLS -"
 - use of the terminology "word" for 2 address units, and "w@", "w!"
   These appear only qdstruc.fs, loaded by this file, and are not actually
   used here.  They can be removed from qdstruc.fs, along with any "$"
   words there.
 - the word "needs" loads Forth source if it's not already loaded
   See below for portable replacement.

Uses LOCALS| from the Locals Extensions word set.

The notation in the following is that "list" and "node" in stack comments
and locals names are addresses of list and node structure instances. The
term "node" includes both the node header and data, and "item" refers to
the node data field.  We also use "." for compound names in stack comments
and locals where "-" might normally appear.
)

needs qdstruc.fs
\ s" qdstruct.fs" included  \  ANS replacement

\ Linked list header structure:
( The list of occupied nodes may be traversed in either direction.  The
unused node list can be accessed *only* from last to first.  Do not
rearrange this definition without rearranging MAKE-LIST.
)
0 to /members
	    @member:  /node@       \ node size includes links and data
	    @member:  #nodes@      \ includes both used and unused
	    @member:  /node-data@  \ node data field size
	    @member:  first-used@  \ null if no nodes are used, else
same-member !member:  first-used!  \  points to first used node
	    @member:  last-used@   \ null if no nodes are used, else
same-member !member:  last-used!   \  points to last used node
	    @member:  last-unused@ \ null if all nodes are used, else
same-member !member:  last-unused! \  points to last unused node
	    /struct  /list-header
	    &member:  first-node

\ List node structure:
0 to /members
	    &member:  prevnode	  \ previous node link,
same-member @member:  prevnode@	  \  holds null if first
same-member !member:  prevnode!
	    &member:  nxnode	  \ next node link,
same-member @member:  nxnode@	  \  holds null if last
same-member !member:  nxnode!
	    /struct  /node-header
	    &member:  nodedata	  \ node data addr

: node-item ( -- )
(
Begin item continuation of node structure.
)
  /node-header to /members ;

: /item  ( "name" -- )
\ does:    ( -- size )
 create /elems /node-header - , does> @ ( item.size) ;

: cl-list  ( list -- )
(
Link all nodes in the list instance into its unused list.
)
 dup >r /node@ ( /node)
 r@ #nodes@ ( #nodes)
 r@ first-node ( node)
 r> ( list)
 locals| list node #nodes /node |
 0 list first-used! 0 list last-used!
 #nodes 0 DO
  node /node - node prevnode!
  node /node + dup node nxnode!
  to node
 LOOP
 0 list first-node prevnode!
 node /node - ( prev.node)
 0 over nxnode!
 ( prev.node) list last-unused! ;

: 0unused  ( list -- )
(
Zero the bytes in the data fields of all unused nodes.  The expected use is
just after MAKE-LIST, when all nodes are unused.
)
 dup /node-data@ swap last-unused@
 locals| node /node.data |
 BEGIN node WHILE
  node nodedata /node.data 0 fill
  node prevnode@ to node
 REPEAT ;

: 0$unused  ( list -- )
(
Assume the data consists of ^Forth strings.  Set the data in all unused
nodes to the empty string.  The expected use is just after MAKE-LIST, when
all nodes are unused.
)
 dup /node-data@ swap last-unused@
 locals| node /node.data |
 BEGIN node WHILE
  node nodedata /node.data +	\ after data
  node nodedata			\ begin data
  DO empty$pfa i ! cell +LOOP
  node prevnode@ to node
 REPEAT ;

: make-list  ( /node.data #nodes -- list )
(
Make a list instance corresponding to the list header structure.  It must
be aligned, and there is no check for that.  Initialize to all nodes
unused.  Data fields are not cleared, because the data type is unknown.
)
 align here locals| list #nodes /node.data |
 /node-header /node.data + ( /node) ,
 #nodes , /node.data ,
 0 ( first-used) , 0 ( last-used) , 0 ( last-unused) ,
 /node-header /node.data + #nodes * allot
 list cl-list list ;

: get-node ( list -- node )
(
Unlink one node from the end of the unused chain, and return its address,
or zero if none is available.  This node has zero in its nxnode field.
)
 ( list) dup last-unused@ ( node)
 ?dup NIF ( list) drop zero EXIT THEN
 ( node) dup prevnode@  ( list node prev.unused)
 locals| prev.unused node list |
 prev.unused list last-unused!
 prev.unused IF		\ there is a preceding unused node,
  0 prev.unused nxnode!	\  make it the last unused
 THEN
 node ;

: insert-node  ( list before.node -- node )
(
Unlink a node from the end of the unused chain and insert it into the used
chain following before.node.  Return the node address, or zero if none is
available.  It is an unchecked error if before.node is not in the used
chain or null.  If before.node is null, the new node becomes the first in
the used chain.
)
 over ( list) get-node
 ( node) ?dup NIF ( list before.node) 2drop zero EXIT THEN
 ( list before.node node) over
 ( before.node) dup IF nxnode@ THEN ( after.node|null)
 locals| after.node node before.node list |
 before.node node prevnode!	\ point node at before.node or null
 before.node NIF  \ node is first
  node list first-used!
 ELSE  \ node is not first
  node before.node nxnode!	\ point before.node at node
 THEN
 after.node IF
  node after.node prevnode!	\ point after.node at node
  after.node node nxnode!	\ point node at after.node
 ELSE  \ node goes last and already points at null after.node
  node list last-used!
 THEN node ;

: add-node  ( list -- node )
(
Unlink one node from the end of the list unused chain, and link it onto the
end of its used chain, leaving the node address, or zero if there are no
unused nodes.
)
 dup last-used@ insert-node ;

: delete-node  ( list node -- )
(
Unlink node from used list and link into unused list.
)
 dup nxnode@	 	( list node nx.used)
 over prevnode@		( list node nx.used prev.used)
 locals| prev.used nx.used node list |
\ Unlink node from used list.
 prev.used IF
  nx.used prev.used nxnode!
 THEN
 nx.used IF
  prev.used nx.used prevnode!
 THEN
 list last-used@ node =
 IF  \ node was last used, previous node or none becomes last used
  node prevnode@ list last-used!
 THEN
 list first-used@ node =
 IF  \ node was first used, next node or none becomes first used
  node nxnode@ list first-used!
 THEN
\ Link node into unused list.
 list last-unused@ IF
  node list last-unused@ nxnode!	\ node follows last unused
 THEN
 list last-unused@ node prevnode!	\ last unused precedes node
 0 node nxnode!				\ nothing follows node
 node list last-unused! ;		\ node now last unused
