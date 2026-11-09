unit fplua_common;
(*
** Base types, constants and macros turned functions
** Conditional compilation code should be in this file as much as possible
** See fplua_config.inc for confuguring FP-Lua
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

const
  LUA_VERSION_MAJOR    = '5';
  LUA_VERSION_MINOR    = '3';
  LUA_VERSION_NUM      = 503;
  LUA_VERSION_RELEASE  = '6';

  LUA_VERSION   = 'FP-Lua ' + LUA_VERSION_MAJOR + '.' + LUA_VERSION_MINOR;
  LUA_RELEASE   = LUA_VERSION + '.' + LUA_VERSION_RELEASE;

  LUA_COPYRIGHT = LUA_RELEASE + ' Copyright (C) 2026 Markov Ivan (TangorCraft)';

  LUA_AUTHORS   = 'R. Ierusalimschy, L. H. de Figueiredo, W. Celes';
  FPLUA_AUTHORS   = LUA_AUTHORS + ', I. Markov';

  (* mark for precompiled code ('<esc>Lua') *)
  LUA_SIGNATURE = #$1b'Lua';

  (* option for multiple returns in 'lua_pcall' and 'lua_call' *)
  LUA_MULTRET   = (-1);

(* thread status *)
const
  LUA_OK        = 0;
  LUA_YIELD     = 1;
  LUA_ERRRUN    = 2;
  LUA_ERRSYNTAX = 3;
  LUA_ERRMEM    = 4;
  LUA_ERRGCMM   = 5;
  LUA_ERRERR    = 6;


(*
** basic types
*)
const
  LUA_TNONE           = (-1);

  LUA_TNIL            = 0;
  LUA_TBOOLEAN        = 1;
  LUA_TLIGHTUSERDATA  = 2;
  LUA_TNUMBER         = 3;
  LUA_TSTRING         = 4;
  LUA_TTABLE          = 5;
  LUA_TFUNCTION       = 6;
  LUA_TUSERDATA       = 7;
  LUA_TTHREAD         = 8;

  LUA_NUMTAGS         = 9;


(* minimum Lua stack available to a C function *)
const
  LUA_MINSTACK = 20;


(* predefined values in the registry *)
const
  LUA_RIDX_MAINTHREAD = 1;
  LUA_RIDX_GLOBALS    = 2;
  LUA_RIDX_LAST       = LUA_RIDX_GLOBALS;


const
  LUAI_BITSINT = 32; // Integer is always 32 bit in mode objfpc and mode delphi

(*
** LUA_PATH_SEP is the character that separates templates in a path.
** LUA_PATH_MARK is the string that marks the substitution points in a
** template.
** LUA_EXEC_DIR in a Windows path is replaced by the executable's
** directory.
*)
  LUA_PATH_SEP   =  ';';
  LUA_PATH_MARK  =  '?';
  LUA_EXEC_DIR   =  '!';

(*
** LUA_PATH_DEFAULT is the default path that Lua uses to look for
** Lua libraries.
** LUA_CPATH_DEFAULT is the default path that Lua uses to look for
** C libraries.
*)
const
  LUA_VDIR = LUA_VERSION_MAJOR + '.' + LUA_VERSION_MINOR;
{$ifdef WINDOWS}
  LUA_LDIR        = '!\lua\';
  LUA_CDIR        = '!\';
  LUA_SHRDIR      = '!\..\share\lua\' + LUA_VDIR + '\';
  LUA_PATH_DEFAULT =
                LUA_LDIR + '?.lua;' + LUA_LDIR + '?\init.lua;' +
                LUA_CDIR + '?.lua;' + LUA_CDIR + '?\init.lua;' +
                LUA_SHRDIR + '?.lua;' + LUA_SHRDIR + '?\init.lua;' +
                '.\?.lua;' + '.\?\init.lua'
                ;
  LUA_CPATH_DEFAULT =
                LUA_CDIR + '?.dll;' +
                LUA_CDIR + '..\lib\lua\' + LUA_VDIR + '\?.dll;' +
                LUA_CDIR + 'loadall.dll;' + '.\?.dll'
                ;

{$else}

  LUA_ROOT       = '/usr/local/';
  LUA_LDIR       = LUA_ROOT + 'share/lua/' + LUA_VDIR + '/';
  LUA_CDIR       = LUA_ROOT + 'lib/lua/' + LUA_VDIR + '/';
  LUA_PATH_DEFAULT  =
                LUA_LDIR + '?.lua;' + LUA_LDIR + '?/init.lua;' +
                LUA_CDIR + '?.lua;' + LUA_CDIR + '?/init.lua;' +
                './?.lua;' + './?/init.lua'
                ;
  LUA_CPATH_DEFAULT =
                LUA_CDIR + '?.so;' + LUA_CDIR + 'loadall.so;' + './?.so'
                ;
{$endif WINDOWS}

(*
** LUA_DIRSEP is the directory separator (for submodules).
** CHANGE it if your machine does not use "/" as the directory separator
** and is not Windows. (On Windows Lua automatically uses "\".)
*)
{$ifdef WINDOWS}
  LUA_DIRSEP = '\';
{$else}
  LUA_DIRSEP = '/';
{$endif WINDOWS}

(*
** {==================================================================
** Configuration for Numbers.
** Change these definitions if no predefined LUA_FLOAT_* / LUA_INT_*
** satisfy your needs.
** ===================================================================
*)

(*
@@ LUA_NUMBER is the floating-point type used by Lua.
@@ LUAI_UACNUMBER is the result of a 'default argument promotion'
@@ over a floating number.
@@ l_mathlim(x) corrects limit name 'x' to the proper float type
** by prefixing it with one of FLT/DBL/LDBL.
@@ LUA_NUMBER_FRMLEN is the length modifier for writing floats.
@@ LUA_NUMBER_FMT is the format for writing floats.
@@ lua_number2str converts a float to a string.
@@ l_mathop allows the addition of an 'l' or 'f' to all math operations.
@@ l_floor takes the floor of a float.
@@ lua_str2number converts a decimal numeric string to a number.
*)

type
{$ifdef FPLUA_FLOAT_SINGLE}
  FPLUA_NUMBER = Single;
  LUAI_UACNUMBER = Double;
const
  LUA_NUMBER_FMT = '%.7g';
{$else}{$ifdef FPLUA_FLOAT_DOUBLE}
  FPLUA_NUMBER = Double;
  LUAI_UACNUMBER = Double;
const
  LUA_NUMBER_FMT = '%.14g';
{$else}{$ifdef FPLUA_FLOAT_EXTENDED}
  FPLUA_NUMBER = Extended;
  LUAI_UACNUMBER = Extended;
const
  LUA_NUMBER_FMT = '%.19g';
{$else}
  {$error Lua float type is not defined, see fplua_config.inc}
{$endif extended}
{$endif double}
{$endif single}

//TODO
//#define l_floor(x)              (l_mathop(floor)(x))
function l_floor(const x: Single): Single; overload;
function l_floor(const x: Double): Double; overload;
{$ifdef SUPPORT_EXTENDED}
function l_floor(const x: Extended): Extended; overload;
{$endif SUPPORT_EXTENDED}

function lua_str2number(const s: PChar; p: PPChar): ValReal;
// TODO: lua_strx2number lua_number2strx

function lua_number2str(var s: PChar; const sz: SizeUInt; const n: LUAI_UACNUMBER): SizeUInt;

(*
@@ LUA_INTEGER is the integer type used by Lua.
**
@@ LUA_UNSIGNED is the unsigned version of LUA_INTEGER.
**
@@ LUAI_UACINT is the result of a 'default argument promotion'
@@ over a lUA_INTEGER.
@@ LUA_INTEGER_FRMLEN is the length modifier for reading/writing integers.
@@ LUA_INTEGER_FMT is the format for writing integers.
@@ LUA_MAXINTEGER is the maximum value for a LUA_INTEGER.
@@ LUA_MININTEGER is the minimum value for a LUA_INTEGER.
@@ lua_integer2str converts an integer to a string.
*)

type
{$ifdef FPLUA_INT_16BIT}
  //FPLUA_INTEGER = Int16;
  //FPLUA_UNSIGNED = UInt16;
{$else}{$ifdef FPLUA_INT_32BIT}
  FPLUA_INTEGER = Int32;
  FPLUA_UNSIGNED = UInt32;
{$else}{$ifdef FPLUA_INT_64BIT}
  FPLUA_INTEGER = Int64;
  FPLUA_UNSIGNED = UInt64;
{$else}
  {$error Lua integer type is not defined, see fplua_config.inc}
{$endif 64}
{$endif 32}
{$endif 16}
  LUAI_UACINT = FPLUA_INTEGER;

const
  LUA_MAXINTEGER = high(FPLUA_INTEGER);
  LUA_MININTEGER = low(FPLUA_INTEGER);

  LUA_INTEGER_FMT = '%d';

function lua_integer2str(var s: PChar; const sz: SizeUInt; const n: LUAI_UACINT): SizeUInt;

(*
@@ l_sprintf is equivalent to 'snprintf' or 'sprintf' in C89.
** (All uses in Lua have only one format item.)
*)
//#if !defined(LUA_USE_C89)
//#define l_sprintf(s,sz,f,i)	snprintf(s,sz,f,i)
//#else
//#define l_sprintf(s,sz,f,i)	((void)(sz), sprintf(s,f,i))
//#endif
function l_sprintf(var s: PChar; const sz: SizeUInt; const f: PChar; const args: array of const): SizeUInt;
function fpl_sprintf(var s: PChar; const sz: SizeUInt; const f: String; const args: array of const): SizeUInt;

(*
@@ lua_numbertointeger converts a float number to an integer, or
** returns 0 if float is not within the range of a lua_Integer.
** (The range comparisons are tricky because of rounding. The tests
** here assume a two-complement representation, where MININTEGER always
** has an exact representation as a float; MAXINTEGER may not have one,
** and therefore its conversion to float may have an ill-defined value.)
*)
{
#define lua_numbertointeger(n,p) \
  ((n) >= (LUA_NUMBER)(LUA_MININTEGER) && \
   (n) < -(LUA_NUMBER)(LUA_MININTEGER) && \
      (*(p) = (LUA_INTEGER)(n), 1))
}
function lua_numbertointeger(const n: FPLUA_NUMBER; out p: FPLUA_INTEGER): Boolean; inline;

(* }================================================================== *)

(*
@@ lua_pointer2str converts a pointer to a readable string in a
** non-specified way.
*)
function lua_integer2str(var buff: PChar; const sz: SizeUInt; const p: Pointer): SizeUInt;

(*
@@ LUA_KCONTEXT is the type of the context ('ctx') for continuation
** functions.  It must be a numerical type; Lua will use 'intptr_t' if
** available, otherwise it will use 'ptrdiff_t' (the nearest thing to
** 'intptr_t' in C89)
*)
type
  FPLUA_KCONTEXT = PtrInt;


(*
@@ lua_getlocaledecpoint gets the locale "radix character" (decimal point).
** Change that if you do not want to use C locales. (Code using this
** macro must include header 'locale.h'.)
*)
{ TODO
#if !defined(lua_getlocaledecpoint)
#define lua_getlocaledecpoint()         (localeconv()->decimal_point[0])
#endif
}


(*
** {==================================================================
** Macros that affect the API and must be stable (that is, must be the
** same when you compile Lua and when you compile code that links to
** Lua). You probably do not want/need to change them.
** =====================================================================
*)

(*
@@ LUAI_MAXSTACK limits the size of the Lua stack.
** CHANGE it if you need a different limit. This limit is arbitrary;
** its only purpose is to stop Lua from consuming unlimited stack
** space (and to reserve some numbers for pseudo-indices).
*)
//#if LUAI_BITSINT >= 32
const
  LUAI_MAXSTACK = 1000000;
//#else
//#define LUAI_MAXSTACK         15000
//#endif


(*
@@ LUA_EXTRASPACE defines the size of a raw memory area associated with
** a Lua state with very fast access.
** CHANGE it if you need a different size.
*)
const
  LUA_EXTRASPACE = sizeof(Pointer);


(*
@@ LUA_IDSIZE gives the maximum size for the description of the source
@@ of a function in debug information.
** CHANGE it if you want a different size.
*)
const
  LUA_IDSIZE = 60;


(*
@@ LUAL_BUFFERSIZE is the buffer size used by the lauxlib buffer system.
** CHANGE it if it uses too much C-stack space. (For long double,
** 'string.format("%.99f", -1e4932)' needs 5034 bytes, so a
** smaller buffer would force a memory allocation for each call to
** 'string.format'.)
*)
const
{$ifdef FPLUA_FLOAT_EXTENDED}
  LUAL_BUFFERSIZE = 8192;
{$else}
  LUAL_BUFFERSIZE = $80 * sizeof(Pointer) * sizeof(FPLUA_INTEGER);
{$endif}

(* }================================================================== *)

(*
** Pseudo-indices
** (-LUAI_MAXSTACK is the minimum valid index; we keep some free empty
** space after that to help overflow detection)
*)
const
  LUA_REGISTRYINDEX = (-LUAI_MAXSTACK - 1000);
function lua_upvalueindex(const i: Integer): Integer;

type
  lua_Number = type FPLUA_NUMBER;
  lua_Integer = type FPLUA_INTEGER;
  lua_Unsigned = type FPLUA_UNSIGNED;
  lua_KContext = type FPLUA_KCONTEXT;
  Plua_Number = ^lua_Number;
  Plua_Integer = ^lua_Integer;
  Plua_Unsigned = ^lua_Unsigned;
  Plua_KContext = ^lua_KContext;


(*
** Type for memory-allocation functions
*)
//typedef void * (*lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize);
type
  lua_Alloc = function (ud: Pointer; ptr: Pointer; osize: PtrUInt; nsize: PtrUInt): Pointer;

(*
** RCS ident string
*)
//extern const char lua_ident[];
const
  lua_ident =
  '$LuaVersion: ' + LUA_COPYRIGHT + ' $' +
  '$LuaAuthors: ' + LUA_AUTHORS + ' $' +
  '$FPLuaAuthors: ' + FPLUA_AUTHORS + ' $';

(*
** Comparison and arithmetic functions
*)
const
  LUA_OPADD    = 0 ;      //* ORDER TM, ORDER OP */
  LUA_OPSUB    = 1 ;
  LUA_OPMUL    = 2 ;
  LUA_OPMOD    = 3 ;
  LUA_OPPOW    = 4 ;
  LUA_OPDIV    = 5 ;
  LUA_OPIDIV   = 6 ;
  LUA_OPBAND   = 7 ;
  LUA_OPBOR    = 8 ;
  LUA_OPBXOR   = 9 ;
  LUA_OPSHL    = 10;
  LUA_OPSHR    = 11;
  LUA_OPUNM    = 12;
  LUA_OPBNOT   = 13;

const
  LUA_OPEQ      = 0;
  LUA_OPLT      = 1;
  LUA_OPLE      = 2;

(*
** garbage-collection function and options
*)
const
  LUA_GCSTOP            = 0;
  LUA_GCRESTART         = 1;
  LUA_GCCOLLECT         = 2;
  LUA_GCCOUNT           = 3;
  LUA_GCCOUNTB          = 4;
  LUA_GCSTEP            = 5;
  LUA_GCSETPAUSE        = 6;
  LUA_GCSETSTEPMUL      = 7;
  LUA_GCISRUNNING       = 9;


(*
** {======================================================================
** Debug API
** =======================================================================
*)


(*
** Event codes
*)
const
  LUA_HOOKCALL     = 0;
  LUA_HOOKRET      = 1;
  LUA_HOOKLINE     = 2;
  LUA_HOOKCOUNT    = 3;
  LUA_HOOKTAILCALL = 4;


(*
** Event masks
*)
const
  LUA_MASKCALL  = (1 shl LUA_HOOKCALL) ;
  LUA_MASKRET   = (1 shl LUA_HOOKRET)  ;
  LUA_MASKLINE  = (1 shl LUA_HOOKLINE) ;
  LUA_MASKCOUNT = (1 shl LUA_HOOKCOUNT);

{ lua_Debug defined in fplua_types }
{ Debug API functions defined in fplua_utils}

(* }====================================================================== *)



(*
** {==================================================================
** Limits, basic types, and some other 'installation-dependent' definitions
** {==================================================================
*)

(*
** 'lu_mem' and 'l_mem' are unsigned/signed integers big enough to count
** the total memory used by Lua (in bytes). Usually, 'size_t' and
** 'ptrdiff_t' should work, but we use 'long' for 16-bit machines.
*)
//#if LUAI_BITSINT >= 32        /* }{ */
type
  lu_mem = type PtrUInt;
  l_mem = type PtrInt;
//#else  /* 16-bit ints */      /* }{ */
//typedef unsigned long lu_mem;
//typedef long l_mem;
//#endif                                /* } */


(* chars used as small naturals (so that 'char' is reserved for characters) *)
type
  lu_byte = type Byte; // maybe shortint?
  // integer type that can be used in boolean expressions
  lu_int = type Integer;

(* maximum value for size_t *)
const
  MAX_SIZET = high(SizeUInt);

(* maximum size visible for Lua (must be representable in a lua_Integer *)
const
  {$if sizeof(SizeUInt) < sizeof(FPLUA_INTEGER)}
  MAX_SIZE = MAX_SIZET
  {$else}
  MAX_SIZE = SizeUInt(LUA_MAXINTEGER);
  {$endif}

  MAX_LUMEM = high(lu_mem);
  MAX_LMEM = MAX_LUMEM shr 1;

  MAX_INT = MaxInt;

(*
** conversion of pointer to unsigned integer:
** this is for hashing only; there is no problem if the integer
** cannot hold the whole pointer value
*)
function point2uint(const p: Pointer): Cardinal; inline;

(* type to ensure maximum alignment *)
//#if defined(LUAI_USER_ALIGNMENT_T)
//typedef LUAI_USER_ALIGNMENT_T L_Umaxalign;
//#else
type
  L_Umaxalign = record
  case Byte of
  1:(n: lua_Number);
  2:(u: double);
  3:(s: Pointer);
  4:(i: lua_Integer);
  5:(l: LongInt);
  end;
//#endif

(* types of 'usual argument conversions' for lua_Number and lua_Integer *)
type
  l_uacNumber = type LUAI_UACNUMBER;
  l_uacInt = type LUAI_UACINT;

(* type casts (a macro highlights casts in the code) *)
// not sure how to convert #define cast(t, exp) ((t)(exp))
type
  cast_void = Pointer;
  cast_byte = lu_byte;
  cast_num = lua_Number;
  cast_int = Integer;
  cast_uchar = Byte; // unsigned char

(* cast a signed lua_Integer to lua_Unsigned *)
// this one probably can be a type too
function l_castS2U(const i: lua_Integer): lua_Unsigned; inline;

(*
** cast a lua_Unsigned to a signed lua_Integer; this cast is
** not strict ISO C, but two-complement architectures should
** work fine.
*)
function l_castU2S(const i: lua_Unsigned): lua_Integer; inline;

(*
** maximum depth for nested C calls and syntactical nested non-terminals
** in a program. (Value must fit in an unsigned short int.)
*)
const
  LUAI_MAXCCALLS = 200;

(*
** type for virtual-machine instructions;
** must be an unsigned with (at least) 4 bytes (see details in lopcodes.h)
*)
type
  Instruction = type UInt32;
  PInstruction = ^Instruction;

(*
** Maximum length for short strings, that is, strings that are
** internalized. (Cannot be smaller than reserved words or tags for
** metamethods, as these strings must be internalized;
** #("function") = 8, #("__newindex") = 10.)
*)
const
  LUAI_MAXSHORTLEN = 40;

(*
** Initial size for the string table (must be power of 2).
** The Lua core alone registers ~50 strings (reserved words +
** metaevent keys + a few others). Libraries would typically add
** a few dozens more.
*)
const
  MINSTRTABSIZE = 128;

(*
** Size of cache for strings in the API. 'N' is the number of
** sets (better be a prime) and "M" is the size of each set (M == 1
** makes a direct cache.)
*)
const
  STRCACHE_N = 53;
  STRCACHE_M = 2;

(* minimum size for string buffer *)
const
  LUA_MINBUFFER = 32;

(* }================================================================== *)

(*
* WARNING: if you change the order of this enumeration,
* grep "ORDER TM" and "ORDER OP"
*)
type
  TMS = (
    TM_INDEX,
    TM_NEWINDEX,
    TM_GC,
    TM_MODE,
    TM_LEN,
    TM_EQ,  //* last tag method with fast access */
    TM_ADD,
    TM_SUB,
    TM_MUL,
    TM_MOD,
    TM_POW,
    TM_DIV,
    TM_IDIV,
    TM_BAND,
    TM_BOR,
    TM_BXOR,
    TM_SHL,
    TM_SHR,
    TM_UNM,
    TM_BNOT,
    TM_LT,
    TM_LE,
    TM_CONCAT,
    TM_CALL//,
    //TM_N          //* number of elements in the enum */
  );
const
  //TM_N_ = ord(TM_N);

  //* number of elements in the TMS enum */
  TM_N = ord(high(TMS))+1;


(* internal assertions for in-house debugging *)
//#if defined(lua_assert)
//#define check_exp(c,e)          (lua_assert(c), (e))
(* to avoid problems with conditions too long *)
//#define lua_longassert(c)       ((c) ? (void)0 : lua_assert(0))
//#else
//#define lua_assert(c)           ((void)0)
//#define check_exp(c,e)          (e)
//#define lua_longassert(c)       ((void)0)
//#endif
{$ifdef FPLUA_ASSERT}
type
  fplua_assert_fn = procedure (const c: Boolean);
var
  fplua_assert: fplua_assert_fn;
{$endif}
procedure lua_assert(const c: Boolean); inline;
procedure lua_longassert(const c: Boolean); inline; // can probably use normal lua_assert
// this function just return e, need overloading for different types
function check_exp(const c: Boolean; const e: lu_byte): lu_byte; overload;
function check_exp(const c: Boolean; const e: lua_Number): lua_Number; overload;
function check_exp(const c: Boolean; const e: lua_Integer): lua_Integer; overload;
function check_exp(const c: Boolean; const e: lu_int): lu_int; overload;
function check_exp(const c: Boolean; const e: Pointer): Pointer; overload;

operator :=(B: lu_byte): Boolean; inline;
operator :=(I: lu_int): Boolean; inline;
operator :=(B: Boolean): lu_int; inline;

implementation

uses
  SysUtils;

function l_floor(const x: Single): Single;
var
  f: single;
begin
  // I was surprised there is no floor function in fpc that return float, i.e. don't convert to int
  // TODO: I should probably write a proper floor code (translating C code for example)
  f := Frac(x);
  Result := x - f - ord(f<0);
end;

function l_floor(const x: Double): Double;
var
  f: double;
begin
  f := Frac(x);
  Result := x - f - ord(f<0);
end;

{$ifdef SUPPORT_EXTENDED}
function l_floor(const x: Extended): Extended;
var
  f: extended;
begin
  f := Frac(x);
  Result := x - f - ord(f<0);
end;
{$endif SUPPORT_EXTENDED}

function lua_str2number(const s: PChar; p: PPChar): ValReal;
const
  NUMBER_MAX_LEN = 200;
var
  c: PChar;
  i, E: Integer;
  ps: String;
begin
  c := s;
  if p <> nil then
    p^ := c
  else
    p := @c;
  i := 0;
  ps := '';
  while (c[i] <> #0) and (i < NUMBER_MAX_LEN) do
    inc(i);
  SetLength(ps, i);
  move(c^, ps[1], i);
  Val(ps, Result, E);
  if E = 0 then
    p^ := c + i
  else if E > 1 then // error in reading number, but not at first char
  begin
    i := E - 1;
    SetLength(ps, i); // discard error chars and retry
    Val(ps, Result, i);
    if E = 0 then
      p^ := c + i
    else
      Result := 0;
  end
  else
    Result := 0;
end;

//#define lua_number2str(s,sz,n)  \
//        l_sprintf((s), sz, LUA_NUMBER_FMT, (LUAI_UACNUMBER)(n))
function lua_number2str(var s: PChar; const sz: SizeUInt; const n: LUAI_UACNUMBER): SizeUInt;
begin
  Result := fpl_sprintf(s, sz, LUA_NUMBER_FMT, [n]);
end;

//#define lua_integer2str(s,sz,n)  \
//        l_sprintf((s), sz, LUA_INTEGER_FMT, (LUAI_UACINT)(n))
function lua_integer2str(var s: PChar; const sz: SizeUInt; const n: LUAI_UACINT): SizeUInt;
begin
  Result := fpl_sprintf(s, sz, LUA_INTEGER_FMT, [n]);
end;

function l_sprintf(var s: PChar; const sz: SizeUInt; const f: PChar;
  const args: array of const): SizeUInt;
Var
  FS : String;
begin
  FS := Format (F,Args);
  If Cardinal(Length(FS)) < sz then
    Result := Length(FS)
  else
    Result := sz;
  Move(FS[1],s^,Result);
  s[Result] := #0;
end;

function fpl_sprintf(var s: PChar; const sz: SizeUInt; const f: String;
  const args: array of const): SizeUInt;
Var
  FS : String;
begin
  FS := Format (F,Args);
  If Cardinal(Length(FS)) < sz then
    Result := Length(FS)
  else
    Result := sz;
  Move(FS[1],s^,Result);
  s[Result] := #0;
end;

function lua_numbertointeger(const n: FPLUA_NUMBER; out p: FPLUA_INTEGER): Boolean;
begin
  if (n >= FPLUA_NUMBER(LUA_MININTEGER)) and
     (n < -FPLUA_NUMBER(LUA_MININTEGER)) then
  begin
    p := Trunc(n);
    Result := True;
  end
  else
    Result := False;
end;

//#define lua_pointer2str(buff,sz,p)      l_sprintf(buff,sz,"%p",p)
function lua_integer2str(var buff: PChar; const sz: SizeUInt; const p: Pointer): SizeUInt;
begin
  Result := l_sprintf(buff,sz,'%p',[p]);
end;

//#define lua_upvalueindex(i)   (LUA_REGISTRYINDEX - (i))
function lua_upvalueindex(const i: Integer): Integer;
begin
  Result := LUA_REGISTRYINDEX - i;
end;

const
  UINT_MAX = high(Cardinal);

function point2uint(const p: Pointer): Cardinal;
var
  pint: PtrUInt absolute p; // to avoid conversion warning
begin
  Result := Cardinal( pint and UINT_MAX );
end;

function l_castS2U(const i: lua_Integer): lua_Unsigned;
begin
  Result := FPLUA_UNSIGNED( i );
end;

function l_castU2S(const i: lua_Unsigned): lua_Integer;
begin
  Result := FPLUA_INTEGER( i );
end;

procedure lua_assert(const c: Boolean);
begin
  {$ifdef FPLUA_ASSERT}
  if Assigned(fplua_assert) then
    fplua_assert(c);
  {$endif}
end;

procedure lua_longassert(const c: Boolean);
begin
  {$ifdef FPLUA_ASSERT}
  if Assigned(fplua_assert) then
    fplua_assert(c);
  {$endif}
end;

function check_exp(const c: Boolean; const e: lu_byte): lu_byte;
begin
  lua_assert(c);
  Result := e;
end;

function check_exp(const c: Boolean; const e: lua_Number): lua_Number;
begin
  lua_assert(c);
  Result := e;
end;

function check_exp(const c: Boolean; const e: lua_Integer): lua_Integer;
begin
  lua_assert(c);
  Result := e;
end;

function check_exp(const c: Boolean; const e: lu_int): lu_int;
begin
  lua_assert(c);
  Result := e;
end;

function check_exp(const c: Boolean; const e: Pointer): Pointer;
begin
  lua_assert(c);
  Result := e;
end;

operator := (B: lu_byte): Boolean;
begin
  Result := B <> 0;
end;

operator := (I: lu_int): Boolean;
begin
  Result := I <> 0;
end;

operator := (B: Boolean): lu_int;
begin
  Result := ord(B);
end;

end.

