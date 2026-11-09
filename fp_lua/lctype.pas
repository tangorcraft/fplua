unit lctype;
(*
** 'ctype' functions for Lua
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

//uses
//  fplua_common;

(*
** WARNING: the functions defined here do not necessarily correspond
** to the similar functions in the standard C ctype.h. They are
** optimized for the specific needs of Lua
*)

{ TODO using Character unit? does fpc even support non-ascii in some way?
#if !defined(LUA_USE_CTYPE)

#if 'A' == 65 && '0' == 48
/* ASCII case: can use its own tables; faster and fixed */
#define LUA_USE_CTYPE   0
#else
/* must use standard C ctype */
#define LUA_USE_CTYPE   1
#endif

#endif}


//#if !LUA_USE_CTYPE    /* { */

(*
** add 1 to char to allow index -1 (EOZ)
*)
//#define testprop(c,p)   (luai_ctype_[(c)+1] & (p))
//function testprop(const c: Integer; const p: byte): Boolean;

(*
** 'lalpha' (Lua alphabetic) and 'lalnum' (Lua alphanumeric) both include '_'
*)

function lislalpha(const c: Integer): Boolean;
function lislalnum(const c: Integer): Boolean;
function lisdigit(const c: Integer): Boolean;
function lisspace(const c: Integer): Boolean;
function lisprint(const c: Integer): Boolean;
function lisxdigit(const c: Integer): Boolean;

(*
** this 'ltolower' only works for alphabetic characters
*)
//#define ltolower(c)     ((c) | ('A' ^ 'a'))
function ltolower(const c: char): char;


//#else                   /* }{ */

(*
** use standard C ctypes
*)
{ TODO does fpc has something like this?
#include <ctype.h>


#define lislalpha(c)    (isalpha(c) || (c) == '_')
#define lislalnum(c)    (isalnum(c) || (c) == '_')
#define lisdigit(c)     (isdigit(c))
#define lisspace(c)     (isspace(c))
#define lisprint(c)     (isprint(c))
#define lisxdigit(c)    (isxdigit(c))

#define ltolower(c)     (tolower(c))
}
//#endif                  /* } */

implementation

//uses
//  Character; // TODO for non-ascii case

const
  ALPHABIT      = 0;
  DIGITBIT      = 1;
  PRINTBIT      = 2;
  SPACEBIT      = 3;
  XDIGITBIT     = 4;


//#define MASK(B)         (1 << (B))
  MASK_ALPHABIT      = 1 shl ALPHABIT;
  MASK_DIGITBIT      = 1 shl DIGITBIT;
  MASK_PRINTBIT      = 1 shl PRINTBIT;
  MASK_SPACEBIT      = 1 shl SPACEBIT;
  MASK_XDIGITBIT     = 1 shl XDIGITBIT;

  UCHAR_MAX = 255;
  (* two more entries for 0 and -1 (EOZ) *)
  luai_ctype_: array[0..UCHAR_MAX+1] of Byte = (
  $00,  //* EOZ */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* 0. */
  $00,  $08,  $08,  $08,  $08,  $08,  $00,  $00,
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* 1. */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,
  $0c,  $04,  $04,  $04,  $04,  $04,  $04,  $04,	//* 2. */
  $04,  $04,  $04,  $04,  $04,  $04,  $04,  $04,
  $16,  $16,  $16,  $16,  $16,  $16,  $16,  $16,	//* 3. */
  $16,  $16,  $04,  $04,  $04,  $04,  $04,  $04,
  $04,  $15,  $15,  $15,  $15,  $15,  $15,  $05,	//* 4. */
  $05,  $05,  $05,  $05,  $05,  $05,  $05,  $05,
  $05,  $05,  $05,  $05,  $05,  $05,  $05,  $05,	//* 5. */
  $05,  $05,  $05,  $04,  $04,  $04,  $04,  $05,
  $04,  $15,  $15,  $15,  $15,  $15,  $15,  $05,	//* 6. */
  $05,  $05,  $05,  $05,  $05,  $05,  $05,  $05,
  $05,  $05,  $05,  $05,  $05,  $05,  $05,  $05,	//* 7. */
  $05,  $05,  $05,  $04,  $04,  $04,  $04,  $00,
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* 8. */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* 9. */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* a. */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* b. */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* c. */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* d. */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* e. */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,	//* f. */
  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00
);

//function testprop(const c: Integer; const p: byte): Boolean;
//begin
//  Result := (luai_ctype_[(c)+1] and (p)) <> 0;
//end;

//#define lislalpha(c)    testprop(c, MASK(ALPHABIT))
function lislalpha(const c: Integer): Boolean;
begin
  Result := (luai_ctype_[(c)+1] and MASK_ALPHABIT) <> 0;
end;

//#define lislalnum(c)    testprop(c, (MASK(ALPHABIT) | MASK(DIGITBIT)))
function lislalnum(const c: Integer): Boolean;
begin
  Result := (luai_ctype_[(c)+1] and (MASK_ALPHABIT or MASK_DIGITBIT)) <> 0;
end;

//#define lisdigit(c)     testprop(c, MASK(DIGITBIT))
function lisdigit(const c: Integer): Boolean;
begin
  Result := (luai_ctype_[(c)+1] and MASK_DIGITBIT) <> 0;
end;

//#define lisspace(c)     testprop(c, MASK(SPACEBIT))
function lisspace(const c: Integer): Boolean;
begin
  Result := (luai_ctype_[(c)+1] and MASK_SPACEBIT) <> 0;
end;

//#define lisprint(c)     testprop(c, MASK(PRINTBIT))
function lisprint(const c: Integer): Boolean;
begin
  Result := (luai_ctype_[(c)+1] and MASK_PRINTBIT) <> 0;
end;

//#define lisxdigit(c)    testprop(c, MASK(XDIGITBIT))
function lisxdigit(const c: Integer): Boolean;
begin
  Result := (luai_ctype_[(c)+1] and MASK_XDIGITBIT) <> 0;
end;

//#define ltolower(c)     ((c) | ('A' ^ 'a'))
function ltolower(const c: char): char;
const
  xorA = ord('A') xor ord('a');
begin
  Result := Chr(ord(c) or xorA);
end;

end.

