[DEFINED] REQUIRED [IF]
	S" CORE-EXT" REQUIRED
[THEN]

: STRUCTURE  ( "name" -- xx offset )
  CREATE
    HERE     ( leave the address of the following sizeof-comma )
    0 DUP ,  ( initial size is zero and left on the stack )
  DOES>      ( has the address of the sizeof-comma )
    CREATE   ( make a variable )
    @ ALLOT  ( and make the variable that long )
;

: ENDSTRUCTURE ( xx offset -- )
  SWAP !    ( store the last endoffset into the sizeof-comma )
;

: SIZEOF ( "name" -- size )
  ' [DEFINED] >BODY.>DOES [IF] >BODY.>DOES [ELSE] >BODY [THEN]
    STATE @ IF [COMPILE] LITERAL THEN
; IMMEDIATE

: FIELD: ( offset fieldsize "name" -- offset+fieldsize )
  CREATE
    OVER , ( store the current end_offset )
    +      ( increase the end_offset by the fieldsize )
  DOES>
    @ +    ( add the memorized offset of the field)
;

: STRUCT: ( offset fieldsize "name" -- offset' )
  SWAP ALIGNED SWAP FIELD:
;

: CHARS: CHARS FIELD: ;
: CELLS: CELLS STRUCT: ;

: CHAR: 1 CHARS: ;
: CELL: 1 CELLS: ;

: 2CHARS: 2* CHARS FIELD: ;    ( not w-aligned! )
: 2CELLS: 2* CELLS STRUCT: ;   ( not x-aligned! )

: 2CHAR: 2 CHARS: ;
: 2CELL: 2 CELLS: ;

[DEFINED] WCHARS [IF]
: WCHAR:  WALIGNED 1 WCHARS FIELD: ;
: WCHARS: SWAP WALIGNED SWAP WCHARS FIELD: ;
[THEN]

[DEFINED] XCELLS [IF]
: XCELL:  XALIGNED 1 XCELLS FIELD: ;
: XCELLS: SWAP XALIGNED SWAP XCELLS FIELD: ;
[THEN]

[DEFINED] FLOATS [IF]
: FLOAT:  FALIGNED 1 FLOATS FIELD: ;
: FLOATS: SWAP FALIGNED SWAP FLOATS FIELD: ;
[THE]

[DEFINED] DFLOATS [IF]
: FLOAT:  DFALIGNED 1 DFLOATS FIELD: ;
: FLOATS: SWAP DFALIGNED SWAP DFLOATS FIELD: ;
[THE]

[DEFINED] PROVIDED [IF]
	S" STRUCTURE-FIELD" PROVIDED
[THEN]
