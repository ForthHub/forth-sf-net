(       Title:  Quick and Dirty Structures
         File:  qdstruct.fs
      Version:  1.0.1
       Author:  David.N.Williams@umich.edu
      License:  LGPL
Starting date:  July 29, 1995
Last revision:  June 23, 2000
)
\ Copyright (C) 1999 by David N. Williams
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
 - "cell", equivalent to the phrase "1 CELLS"
 - "cell-", equivalent to the phrase "1 CELLS -"
 - use of the terminology "word" for 2 address units, and "w@", "w!"
 - words containing "$", which correspond to the ^Forth string package,
   just delete those
)

\ All "/" sizes in bytes.

   0 value /members	\ running total offset
cell value /member	\ current member size

: cell-members   ( -- )   cell to /member ;
: 2cell-members  ( -- )   2 cells to /member ;
: -byte-members  ( n -- ) ( n) to /member ;

: create-member  ( "name" -- )
 create /members dup , /member + to /members ;

: same-member  ( -- )  /members /member - to /members ;

: &member:  ( "name" -- )
\ does:  ( struc.addr -- struc.addr+offset )
 create-member does> @ ( offset) + ;

: @member:  ( "name" -- )
\ does:  ( struc.addr -- n )
 create-member does> @ ( offset) + @ ;

: 2@member:  ( "name" -- )
\ does:  ( struc.addr -- n )
 create-member does> @ ( offset) + 2@ ;

: !member:  ( "name" -- )
\ does:	 ( n struc.addr -- )
 create-member does> @ ( offset) + ! ;

: 2!member:  ( "name" -- )
\ does:	 ( n struc.addr -- )
 create-member does> @ ( offset) + 2! ;

: /struct:  ( "name" -- )
\ does:    ( -- size )
 create /members , does> @ ( offset) ;

\ ^FORTH WORDS

: word-members   ( -- )   2 to /member ;

: w@member:  ( "name" -- )
\ does:  ( struc.addr -- n )
 create-member does> @ ( offset) + w@ ;

: $@member:  ( "name" -- )
\ does:  ( struc.addr -- )
\	 ($: -- $ )
 create-member does> @ ( offset) + $@ ;

: w!member:  ( "name" -- )
\ does:	 ( n struc.addr -- )
 create-member does> @ ( offset) + w! ;

: $!member:  ( "name" -- )
\ does:  ( struc.addr -- )
\	 ($: $ -- )
 create-member does> @ ( offset) + $! ;
