unit lobject;
(*
** Type definitions for Lua objects
** Some types are defined in fplua_types.pas
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common;

(*
** Extra tags for non-values
*)
const
  LUA_TPROTO   = LUA_NUMTAGS;             //* function prototypes */
  LUA_TDEADKEY = (LUA_NUMTAGS+1);         //* removed keys in tables */

(*
** number of all possible tags (including LUA_TNONE but excluding DEADKEY)
*)
const
  LUA_TOTALTAGS  = (LUA_TPROTO + 2);


(*
** tags for Tagged Values have the following use of bits:
** bits 0-3: actual tag (a LUA_T* value)
** bits 4-5: variant bits
** bit 6: whether value is collectable
*)


(*
** LUA_TFUNCTION variants:
** 0 - Lua function
** 1 - light C function
** 2 - regular C function (closure)
*)

(* Variant tags for functions *)
const
  LUA_TLCL       = (LUA_TFUNCTION or (0 shl 4));  //* Lua closure */
  LUA_TLCF       = (LUA_TFUNCTION or (1 shl 4));  //* light C function */
  LUA_TCCL       = (LUA_TFUNCTION or (2 shl 4));  //* C closure */


(* Variant tags for strings *)
const
  LUA_TSHRSTR    = (LUA_TSTRING or (0 shl 4));  //* short strings */
  LUA_TLNGSTR    = (LUA_TSTRING or (1 shl 4));  //* long strings */


(* Variant tags for numbers *)
const
  LUA_TNUMFLT    = (LUA_TNUMBER or (0 shl 4));  //* float numbers */
  LUA_TNUMINT    = (LUA_TNUMBER or (1 shl 4));  //* integer numbers */


(* Bit mark for collectable types *)
const
  BIT_ISCOLLECTABLE     = (1 shl 6);

(* mark a tag as collectable *)
function ctb(const t: Integer): Integer;
const
  ctb_LUA_TNIL            = LUA_TNIL or BIT_ISCOLLECTABLE;
  ctb_LUA_TBOOLEAN        = LUA_TBOOLEAN or BIT_ISCOLLECTABLE;
  ctb_LUA_TLIGHTUSERDATA  = LUA_TLIGHTUSERDATA or BIT_ISCOLLECTABLE;
  ctb_LUA_TNUMBER         = LUA_TNUMBER or BIT_ISCOLLECTABLE;
  ctb_LUA_TSTRING         = LUA_TSTRING or BIT_ISCOLLECTABLE;
  ctb_LUA_TTABLE          = LUA_TTABLE or BIT_ISCOLLECTABLE;
  ctb_LUA_TFUNCTION       = LUA_TFUNCTION or BIT_ISCOLLECTABLE;
  ctb_LUA_TUSERDATA       = LUA_TUSERDATA or BIT_ISCOLLECTABLE;
  ctb_LUA_TTHREAD         = LUA_TTHREAD or BIT_ISCOLLECTABLE;
  ctb_LUA_TPROTO   = LUA_TPROTO or BIT_ISCOLLECTABLE;
  ctb_LUA_TDEADKEY = LUA_TDEADKEY or BIT_ISCOLLECTABLE;
  ctb_LUA_TLCL       = LUA_TLCL or BIT_ISCOLLECTABLE;
  ctb_LUA_TLCF       = LUA_TLCF or BIT_ISCOLLECTABLE;
  ctb_LUA_TCCL       = LUA_TCCL or BIT_ISCOLLECTABLE;
  ctb_LUA_TSHRSTR    = LUA_TSHRSTR or BIT_ISCOLLECTABLE;
  ctb_LUA_TLNGSTR    = LUA_TLNGSTR or BIT_ISCOLLECTABLE;
  ctb_LUA_TNUMFLT    = LUA_TNUMFLT or BIT_ISCOLLECTABLE;
  ctb_LUA_TNUMINT    = LUA_TNUMINT or BIT_ISCOLLECTABLE;


(*
** Tagged Values. This is the basic representation of values in Lua,
** an actual value plus a tag with its type.
*)

(*
** Union of all Lua values
** types defined in fplua_types.pas
*)

(* macro defining a nil value *)
const
  NILCONSTANT : lua_TValue = (fields: (value_: (p: nil); tt_: LUA_TNIL));

//#define val_(o)         ((o)->value_)
function val_(const o: TValuefields): Value;

(* raw type tag of a TValue *)
//#define rttype(o)       ((o)->tt_)
function rttype(const o: TValuefields): integer;

(* tag with no variants (bits 0-3) *)
//#define novariant(x)    ((x) & 0x0F)
function novariant(const x: integer): integer;

(* type tag of a TValue (bits 0-3 for tags + variant bits 4-5) *)
//#define ttype(o)        (rttype(o) & 0x3F)
function ttype(const o: TValuefields): integer;

(* type tag of a TValue with no variants (bits 0-3) *)
//#define ttnov(o)        (novariant(rttype(o)))
function ttnov(const o: TValuefields): integer;


(* Macros to test type *)
//#define checktag(o,t)           (rttype(o) == (t))
function checktag(const o: TValuefields; const t: Integer): Boolean;
//#define checktype(o,t)          (ttnov(o) == (t))
function checktype(const o: TValuefields; const t: Integer): Boolean;

function ttisnumber(const o: TValuefields): Boolean;
function ttisfloat(const o: TValuefields): Boolean;
function ttisinteger(const o: TValuefields): Boolean;
function ttisnil(const o: TValuefields): Boolean;
function ttisboolean(const o: TValuefields): Boolean;
function ttislightuserdata(const o: TValuefields): Boolean;
function ttisstring(const o: TValuefields): Boolean;
function ttisshrstring(const o: TValuefields): Boolean;
function ttislngstring(const o: TValuefields): Boolean;
function ttistable(const o: TValuefields): Boolean;
function ttisfunction(const o: TValuefields): Boolean;
function ttisclosure(const o: TValuefields): Boolean;
function ttisCclosure(const o: TValuefields): Boolean;
function ttisLclosure(const o: TValuefields): Boolean;
function ttislcf(const o: TValuefields): Boolean;
function ttisfulluserdata(const o: TValuefields): Boolean;
function ttisthread(const o: TValuefields): Boolean;
function ttisdeadkey(const o: TValuefields): Boolean;


(* Macros to access values *)

function ivalue(const o: TValuefields): lua_Integer;
function fltvalue(const o: TValuefields): lua_Number;
function nvalue(const o: TValuefields): lua_Number;
function gcvalue(const o: TValuefields): PGCObject;
function pvalue(const o: TValuefields): Pointer;
function tsvalue(const o: TValuefields): PTString;
function uvalue(const o: TValuefields): PUdata;
function clvalue(const o: TValuefields): PClosure;
function clLvalue(const o: TValuefields): PLClosure;
function clCvalue(const o: TValuefields): PCClosure;
function fvalue(const o: TValuefields): lua_CFunction;
function hvalue(const o: TValuefields): PTable;
function bvalue(const o: TValuefields): lu_int;
function thvalue(const o: TValuefields): Plua_State;
//* a dead value may get the 'gc' field, but cannot access its contents */
function deadvalue(const o: TValuefields): Pointer;

function l_isfalse(const o: TValuefields): Boolean;

function iscollectable(const o: TValuefields): Boolean;

(* Macros for internal tests *)

function righttt(const obj: TValuefields): Boolean;

procedure checkliveness(const L: Plua_State; const obj: TValuefields);

(* Macros to set values *)

procedure settt_(var o: TValuefields; const t: Integer);

procedure setfltvalue(var o: TValuefields; const x: lua_Number);

procedure chgfltvalue(var o: TValuefields; const x: lua_Number);

procedure setivalue(var o: TValuefields; const x: lua_Integer);

procedure chgivalue(var o: TValuefields; const x: lua_Integer);

procedure setnilvalue(var obj: TValuefields);

procedure setfvalue(var o: TValuefields; const x: lua_CFunction);

procedure setpvalue(var o: TValuefields; const x: Pointer);

procedure setbvalue(var o: TValuefields; const x: lu_int);

procedure setgcovalue(const L: Plua_State; var o: TValuefields; const x: PGCObject);

procedure setsvalue(const L: Plua_State; var o: TValuefields; const x: PTString);

procedure setuvalue(const L: Plua_State; var o: TValuefields; const x: PUdata);

procedure setthvalue(const L: Plua_State; var o: TValuefields; const x: Plua_State);

procedure setclLvalue(const L: Plua_State; var o: TValuefields; const x: PLClosure);

procedure setclCvalue(const L: Plua_State; var o: TValuefields; const x: PCClosure);

procedure sethvalue(const L: Plua_State; var o: TValuefields; const x: PTable);

procedure setdeadvalue(var obj: TValuefields);


// TODO maybe need overloaded versions
procedure setobj(const L: Plua_State; var obj1,obj2: TValuefields);


(*
** different types of assignments, according to destination
*)

(* from stack to (same) stack *)
procedure setobjs2s(const L: Plua_State; var obj1,obj2: TValuefields);
(* to stack (not from same stack) *)
procedure setobj2s(const L: Plua_State; var obj1,obj2: TValuefields);
procedure setsvalue2s(const L: Plua_State; var o: TValuefields; const x: PTString);
procedure sethvalue2s(const L: Plua_State; var o: TValuefields; const x: PTable);
//#define setptvalue2s    setptvalue // no such thing, not use anywhere (╯°□°)╯︵ ┻━┻
(* from table to same table *)
procedure setobjt2t(const L: Plua_State; var obj1,obj2: TValuefields);
(* to new object *)
procedure setobj2n(const L: Plua_State; var obj1,obj2: TValuefields);
procedure setsvalue2n(const L: Plua_State; var o: TValuefields; const x: PTString);

(* to table (define it as an expression to be used in macros) *)
procedure setobj2t(const L: Plua_State; const o1, o2: PTValue);



(*
** {======================================================
** types and prototypes
** =======================================================
*)


(*
** Get the actual string (array of bytes) from a 'TString' (defined in fplua_type.pas).
** (Access to 'extra' ensures that value is really a 'TString'.)
*)
function getstr(const ts: PTString): PChar;

(* get the actual string (array of bytes) from a Lua value *)
function svalue(const o: TValuefields): PChar;

(* get string length from 'TString *s' *)
function tsslen(const s: PTString): SizeUInt;

(* get string length from 'TValue *o' *)
function vslen(const o: TValuefields): SizeUInt;


(*
**  Get the address of memory block inside 'Udata' (defined in fplua_type.pas).
** (Access to 'ttuv_' ensures that value is really a 'Udata'.)
*)
function getudatamem(const u: PUdata): PByte;

procedure setuservalue(const L: Plua_State; const u: PUdata; const o: TValuefields);

procedure getuservalue(const L: Plua_State; const u: PUdata; var o: TValuefields);


(*
** Closures
** types defined in fplua_types.pas
*)

function isLfunction(const o: TValuefields): Boolean;

function getproto(const o: TValuefields): PProto;


(*
** Tables
** types defined in fplua_types.pas
*)

(* copy a value into a key without messing up field 'next' *)
procedure setnodekey(const L: Plua_State; var key: TKey; const obj: TValuefields);

(*
** 'module' operation for hashing (size is always a power of 2)
*)
function lmod(const s, size: Integer): Integer;

function twoto(const x: Integer): Integer;
function sizenode(const t: Table): Integer;

(*
** (address of) a fixed nil value
*)
//#define luaO_nilobject          (&luaO_nilobject_)
const
  luaO_nilobject: PTValue = @NILCONSTANT;

  //LUAI_DDEC const TValue luaO_nilobject_;


(* size of buffer for 'luaO_utf8esc' function *)
const
  UTF8BUFFSZ    = 8;

{ TODO
LUAI_FUNC int luaO_int2fb (unsigned int x);
LUAI_FUNC int luaO_fb2int (int x);
LUAI_FUNC int luaO_utf8esc (char *buff, unsigned long x);
LUAI_FUNC int luaO_ceillog2 (unsigned int x);
LUAI_FUNC void luaO_arith (lua_State *L, int op, const TValue *p1,
                           const TValue *p2, TValue *res);
LUAI_FUNC size_t luaO_str2num (const char *s, TValue *o);
LUAI_FUNC int luaO_hexavalue (int c);
LUAI_FUNC void luaO_tostring (lua_State *L, StkId obj);
LUAI_FUNC const char *luaO_pushvfstring (lua_State *L, const char *fmt,
                                                       va_list argp);
LUAI_FUNC const char *luaO_pushfstring (lua_State *L, const char *fmt, ...);
LUAI_FUNC void luaO_chunkid (char *out, const char *source, size_t len);
}
function luaO_int2fb(const x: Cardinal): Integer;
function luaO_fb2int(const x: Integer): Integer;
function luaO_utf8esc(const buff: PChar; const x: Cardinal): Integer;
function luaO_ceillog2(const x: Cardinal): Integer;
procedure luaO_arith(const L: Plua_State; const op: Integer; const p1, p2, res: PTValue);
function luaO_str2num(const s: PChar; const o: PTValue): SizeUInt;
function luaO_hexavalue(const c: Integer): Integer;
procedure luaO_tostring(const L: Plua_State; const obj: StkId);
function luaO_pushvfstring(const L: Plua_State; const fmt: PChar; argp: array of const): PChar;
function luaO_pushfstring(const L: Plua_State; const fmt: PChar; argp: array of const): PChar;
procedure luaO_chunkid(const out_: PChar; const source: PChar; const len: SizeUInt);

implementation

uses
  lstate, lgc;

//#define ctb(t)                  ((t) | BIT_ISCOLLECTABLE)
function ctb(const t: Integer): Integer;
begin
  Result := t or BIT_ISCOLLECTABLE;
end;

//#define val_(o)         ((o)->value_)
function val_(const o: TValuefields): Value;
begin
  Result := o.value_;
end;

(* raw type tag of a TValue *)
//#define rttype(o)       ((o)->tt_)
function rttype(const o: TValuefields): integer;
begin
  Result := o.tt_;
end;

(* tag with no variants (bits 0-3) *)
//#define novariant(x)    ((x) & 0x0F)
function novariant(const x: integer): integer;
begin
  Result := x and $0F;
end;

(* type tag of a TValue (bits 0-3 for tags + variant bits 4-5) *)
//#define ttype(o)        (rttype(o) & 0x3F)
function ttype(const o: TValuefields): integer;
begin
  Result := o.tt_ and $3F;
end;

(* type tag of a TValue with no variants (bits 0-3) *)
//#define ttnov(o)        (novariant(rttype(o)))
function ttnov(const o: TValuefields): integer;
begin
  Result := o.tt_ and $0F
end;

//#define checktag(o,t)           (rttype(o) == (t))
function checktag(const o: TValuefields; const t: Integer): Boolean;
begin
  Result := (o.tt_ = t);
end;

//#define checktype(o,t)          (ttnov(o) == (t))
function checktype(const o: TValuefields; const t: Integer): Boolean;
begin
  Result := ((o.tt_ and $0F) = t);
end;

//#define ttisnumber(o)           checktype((o), LUA_TNUMBER)
function ttisnumber(const o: TValuefields): Boolean;
begin
  Result := checktype(o, LUA_TNUMBER);
end;

//#define ttisfloat(o)            checktag((o), LUA_TNUMFLT)
function ttisfloat(const o: TValuefields): Boolean;
begin
  Result := checktag(o, LUA_TNUMFLT);
end;

//#define ttisinteger(o)          checktag((o), LUA_TNUMINT)
function ttisinteger(const o: TValuefields): Boolean;
begin
  Result := checktag(o, LUA_TNUMINT);
end;

//#define ttisnil(o)              checktag((o), LUA_TNIL)
function ttisnil(const o: TValuefields): Boolean;
begin
  Result := checktag(o, LUA_TNIL);
end;

//#define ttisboolean(o)          checktag((o), LUA_TBOOLEAN)
function ttisboolean(const o: TValuefields): Boolean;
begin
  Result := checktag(o, LUA_TBOOLEAN);
end;

//#define ttislightuserdata(o)    checktag((o), LUA_TLIGHTUSERDATA)
function ttislightuserdata(const o: TValuefields): Boolean;
begin
  Result := checktag(o, LUA_TLIGHTUSERDATA);
end;

//#define ttisstring(o)           checktype((o), LUA_TSTRING)
function ttisstring(const o: TValuefields): Boolean;
begin
  Result := checktype(o, LUA_TSTRING);
end;

//#define ttisshrstring(o)        checktag((o), ctb(LUA_TSHRSTR))
function ttisshrstring(const o: TValuefields): Boolean;
begin
  Result := checktag(o, ctb_LUA_TSHRSTR);
end;

//#define ttislngstring(o)        checktag((o), ctb(LUA_TLNGSTR))
function ttislngstring(const o: TValuefields): Boolean;
begin
  Result := checktag(o, ctb_LUA_TLNGSTR);
end;

//#define ttistable(o)            checktag((o), ctb(LUA_TTABLE))
function ttistable(const o: TValuefields): Boolean;
begin
  Result := checktag(o, ctb_LUA_TTABLE);
end;

//#define ttisfunction(o)         checktype(o, LUA_TFUNCTION)
function ttisfunction(const o: TValuefields): Boolean;
begin
  Result := checktype(o, LUA_TFUNCTION);
end;

//#define ttisclosure(o)          ((rttype(o) & 0x1F) == LUA_TFUNCTION)
function ttisclosure(const o: TValuefields): Boolean;
begin
  Result := ((rttype(o) and $1F) = LUA_TFUNCTION);
end;

//#define ttisCclosure(o)         checktag((o), ctb(LUA_TCCL))
function ttisCclosure(const o: TValuefields): Boolean;
begin
  Result := checktag(o, ctb_LUA_TCCL);
end;

//#define ttisLclosure(o)         checktag((o), ctb(LUA_TLCL))
function ttisLclosure(const o: TValuefields): Boolean;
begin
  Result := checktag(o, ctb_LUA_TLCL);
end;

//#define ttislcf(o)              checktag((o), LUA_TLCF)
function ttislcf(const o: TValuefields): Boolean;
begin
  Result := checktag(o, LUA_TLCF);
end;

//#define ttisfulluserdata(o)     checktag((o), ctb(LUA_TUSERDATA))
function ttisfulluserdata(const o: TValuefields): Boolean;
begin
  Result := checktag(o, ctb_LUA_TUSERDATA);
end;

//#define ttisthread(o)           checktag((o), ctb(LUA_TTHREAD))
function ttisthread(const o: TValuefields): Boolean;
begin
  Result := checktag(o, ctb_LUA_TTHREAD);
end;

//#define ttisdeadkey(o)          checktag((o), LUA_TDEADKEY)
function ttisdeadkey(const o: TValuefields): Boolean;
begin
  Result := checktag(o, LUA_TDEADKEY);
end;

//#define ivalue(o)       check_exp(ttisinteger(o), val_(o).i)
function ivalue(const o: TValuefields): lua_Integer;
begin
  Result := check_exp(ttisinteger(o), o.value_.i);
end;

//#define fltvalue(o)     check_exp(ttisfloat(o), val_(o).n)
function fltvalue(const o: TValuefields): lua_Number;
begin
  Result := check_exp(ttisfloat(o), o.value_.n);
end;

//#define nvalue(o)       check_exp(ttisnumber(o), \
//        (ttisinteger(o) ? cast_num(ivalue(o)) : fltvalue(o)))
function nvalue(const o: TValuefields): lua_Number;
begin
  check_exp(ttisnumber(o),nil);
  if ttisinteger(o) then
    Result := ivalue(o)
  else
    Result := fltvalue(o);
end;

//#define gcvalue(o)      check_exp(iscollectable(o), val_(o).gc)
function gcvalue(const o: TValuefields): PGCObject;
begin
  Result := check_exp(iscollectable(o), o.value_.gc);
end;

//#define pvalue(o)       check_exp(ttislightuserdata(o), val_(o).p)
function pvalue(const o: TValuefields): Pointer;
begin
  Result := check_exp(ttislightuserdata(o), o.value_.p);
end;

//#define tsvalue(o)      check_exp(ttisstring(o), gco2ts(val_(o).gc))
function tsvalue(const o: TValuefields): PTString;
begin
  Result := check_exp(ttisstring(o), gco2ts(o.value_.gc));
end;

//#define uvalue(o)       check_exp(ttisfulluserdata(o), gco2u(val_(o).gc))
function uvalue(const o: TValuefields): PUdata;
begin
  Result := check_exp(ttisfulluserdata(o), gco2u(o.value_.gc));
end;

//#define clvalue(o)      check_exp(ttisclosure(o), gco2cl(val_(o).gc))
function clvalue(const o: TValuefields): PClosure;
begin
  Result := check_exp(ttisclosure(o), gco2cl(o.value_.gc));
end;

//#define clLvalue(o)     check_exp(ttisLclosure(o), gco2lcl(val_(o).gc))
function clLvalue(const o: TValuefields): PLClosure;
begin
  Result := check_exp(ttisLclosure(o), gco2lcl(o.value_.gc));
end;

//#define clCvalue(o)     check_exp(ttisCclosure(o), gco2ccl(val_(o).gc))
function clCvalue(const o: TValuefields): PCClosure;
begin
  Result := check_exp(ttisCclosure(o), gco2ccl(o.value_.gc));
end;

//#define fvalue(o)       check_exp(ttislcf(o), val_(o).f)
function fvalue(const o: TValuefields): lua_CFunction;
begin
  Result := check_exp(ttislcf(o), o.value_.f);
end;

//#define hvalue(o)       check_exp(ttistable(o), gco2t(val_(o).gc))
function hvalue(const o: TValuefields): PTable;
begin
  Result := check_exp(ttistable(o), gco2t(o.value_.gc));
end;

//#define bvalue(o)       check_exp(ttisboolean(o), val_(o).b)
function bvalue(const o: TValuefields): lu_int;
begin
  Result := check_exp(ttisboolean(o), o.value_.b);
end;

//#define thvalue(o)      check_exp(ttisthread(o), gco2th(val_(o).gc))
function thvalue(const o: TValuefields): Plua_State;
begin
  Result := check_exp(ttisthread(o), gco2th(o.value_.gc));
end;

//#define deadvalue(o)    check_exp(ttisdeadkey(o), cast(void *, val_(o).gc))
function deadvalue(const o: TValuefields): Pointer;
begin
  Result := check_exp(ttisdeadkey(o), o.value_.gc);
end;

//#define l_isfalse(o)    (ttisnil(o) || (ttisboolean(o) && bvalue(o) == 0))
function l_isfalse(const o: TValuefields): Boolean;
begin
  Result := ttisnil(o) or (ttisboolean(o) and (bvalue(o) = 0));
end;

//#define iscollectable(o)        (rttype(o) & BIT_ISCOLLECTABLE)
function iscollectable(const o: TValuefields): Boolean;
begin
  Result := (o.tt_ and BIT_ISCOLLECTABLE) <> 0;
end;

//#define righttt(obj)            (ttype(obj) == gcvalue(obj)->tt)
function righttt(const obj: TValuefields): Boolean;
begin
  Result := ttype(obj) = gcvalue(obj)^.header.tt;
end;

//#define checkliveness(L,obj) \
//        lua_longassert(!iscollectable(obj) || \
//                (righttt(obj) && (L == NULL || !isdead(G(L),gcvalue(obj)))))
procedure checkliveness(const L: Plua_State; const obj: TValuefields);
begin
  lua_longassert(
    not iscollectable(obj) or
    (
      righttt(obj) and
      (
        (L = Nil) or
        not isdead(L^.l_G^, gcvalue(obj)^.header)
      )
    )
  );
end;

//#define settt_(o,t)     ((o)->tt_=(t))
procedure settt_(var o: TValuefields; const t: Integer);
begin
  o.tt_ := t;
end;

//#define setfltvalue(obj,x) \
//  { TValue *io=(obj); val_(io).n=(x); settt_(io, LUA_TNUMFLT); }
procedure setfltvalue(var o: TValuefields; const x: lua_Number);
begin
  o.value_.n := x;
  settt_(o, LUA_TNUMFLT);
end;

//#define chgfltvalue(obj,x) \
//  { TValue *io=(obj); lua_assert(ttisfloat(io)); val_(io).n=(x); }
procedure chgfltvalue(var o: TValuefields; const x: lua_Number);
begin
  lua_assert(ttisfloat(o));
  o.value_.n := x;
end;

//#define setivalue(obj,x) \
//  { TValue *io=(obj); val_(io).i=(x); settt_(io, LUA_TNUMINT); }
procedure setivalue(var o: TValuefields; const x: lua_Integer);
begin
  o.value_.i := x;
  settt_(o, LUA_TNUMINT);
end;

//#define chgivalue(obj,x) \
//  { TValue *io=(obj); lua_assert(ttisinteger(io)); val_(io).i=(x); }
procedure chgivalue(var o: TValuefields; const x: lua_Integer);
begin
  lua_assert(ttisinteger(o));
  o.value_.i := x;
end;

//#define setnilvalue(obj) settt_(obj, LUA_TNIL)
procedure setnilvalue(var obj: TValuefields);
begin
  settt_(obj, LUA_TNIL);
end;

//#define setfvalue(obj,x) \
//  { TValue *io=(obj); val_(io).f=(x); settt_(io, LUA_TLCF); }
procedure setfvalue(var o: TValuefields; const x: lua_CFunction);
begin
  o.value_.f := x;
  settt_(o, LUA_TLCF);
end;

//#define setpvalue(obj,x) \
//  { TValue *io=(obj); val_(io).p=(x); settt_(io, LUA_TLIGHTUSERDATA); }
procedure setpvalue(var o: TValuefields; const x: Pointer);
begin
  o.value_.p := x;
  settt_(o, LUA_TLIGHTUSERDATA);
end;

//#define setbvalue(obj,x) \
//  { TValue *io=(obj); val_(io).b=(x); settt_(io, LUA_TBOOLEAN); }
procedure setbvalue(var o: TValuefields; const x: lu_int);
begin
  o.value_.b := x;
  settt_(o, LUA_TBOOLEAN);
end;

//#define setgcovalue(L,obj,x) \
//  { TValue *io = (obj); GCObject *i_g=(x); \
//    val_(io).gc = i_g; settt_(io, ctb(i_g->tt)); }
procedure setgcovalue(const L: Plua_State; var o: TValuefields; const x: PGCObject);
begin
  o.value_.gc := x;
  settt_(o, ctb(x^.header.tt));
end;

//#define setsvalue(L,obj,x) \
//  { TValue *io = (obj); TString *x_ = (x); \
//    val_(io).gc = obj2gco(x_); settt_(io, ctb(x_->tt)); \
//    checkliveness(L,io); }
procedure setsvalue(const L: Plua_State; var o: TValuefields; const x: PTString);
begin
  o.value_.gc := obj2gco(x);
  settt_(o, x^.header.tt);
  checkliveness(L, o);
end;

//#define setuvalue(L,obj,x) \
//  { TValue *io = (obj); Udata *x_ = (x); \
//    val_(io).gc = obj2gco(x_); settt_(io, ctb(LUA_TUSERDATA)); \
//    checkliveness(L,io); }
procedure setuvalue(const L: Plua_State; var o: TValuefields; const x: PUdata);
begin
  o.value_.gc := obj2gco(x);
  settt_(o, ctb_LUA_TUSERDATA);
  checkliveness(L, o);
end;

//#define setthvalue(L,obj,x) \
//  { TValue *io = (obj); lua_State *x_ = (x); \
//    val_(io).gc = obj2gco(x_); settt_(io, ctb(LUA_TTHREAD)); \
//    checkliveness(L,io); }
procedure setthvalue(const L: Plua_State; var o: TValuefields; const x: Plua_State);
begin
  o.value_.gc := obj2gco(x);
  settt_(o, ctb_LUA_TTHREAD);
  checkliveness(L, o);
end;

//#define setclLvalue(L,obj,x) \
//  { TValue *io = (obj); LClosure *x_ = (x); \
//    val_(io).gc = obj2gco(x_); settt_(io, ctb(LUA_TLCL)); \
//    checkliveness(L,io); }
procedure setclLvalue(const L: Plua_State; var o: TValuefields; const x: PLClosure);
begin
  o.value_.gc := obj2gco(x);
  settt_(o, ctb_LUA_TLCL);
  checkliveness(L, o);
end;

//#define setclCvalue(L,obj,x) \
//  { TValue *io = (obj); CClosure *x_ = (x); \
//    val_(io).gc = obj2gco(x_); settt_(io, ctb(LUA_TCCL)); \
//    checkliveness(L,io); }
procedure setclCvalue(const L: Plua_State; var o: TValuefields; const x: PCClosure);
begin
  o.value_.gc := obj2gco(x);
  settt_(o, ctb_LUA_TCCL);
  checkliveness(L, o);
end;

//#define sethvalue(L,obj,x) \
//  { TValue *io = (obj); Table *x_ = (x); \
//    val_(io).gc = obj2gco(x_); settt_(io, ctb(LUA_TTABLE)); \
//    checkliveness(L,io); }
procedure sethvalue(const L: Plua_State; var o: TValuefields; const x: PTable);
begin
  o.value_.gc := obj2gco(x);
  settt_(o, ctb_LUA_TTABLE);
  checkliveness(L, o);
end;

//#define setdeadvalue(obj)       settt_(obj, LUA_TDEADKEY)
procedure setdeadvalue(var obj: TValuefields);
begin
  settt_(obj, LUA_TDEADKEY);
end;

//#define setobj(L,obj1,obj2) \
//        { TValue *io1=(obj1); *io1 = *(obj2); \
//          (void)L; checkliveness(L,io1); }
procedure setobj(const L: Plua_State; var obj1, obj2: TValuefields);
begin
  obj1 := obj2;
  checkliveness(L, obj1);
end;

//#define setobjs2s       setobj
procedure setobjs2s(const L: Plua_State; var obj1, obj2: TValuefields);
begin
  setobj(L, obj1, obj2);
end;

//#define setobj2s        setobj
procedure setobj2s(const L: Plua_State; var obj1, obj2: TValuefields);
begin
  setobj(L, obj1, obj2);
end;

//#define setsvalue2s     setsvalue
procedure setsvalue2s(const L: Plua_State; var o: TValuefields; const x: PTString);
begin
  setsvalue(L, o, x);
end;

//#define sethvalue2s     sethvalue
procedure sethvalue2s(const L: Plua_State; var o: TValuefields; const x: PTable);
begin
  sethvalue(L, o, x);
end;

//#define setobjt2t       setobj
procedure setobjt2t(const L: Plua_State; var obj1, obj2: TValuefields);
begin
  setobj(L, obj1, obj2);
end;

//#define setobj2n        setobj
procedure setobj2n(const L: Plua_State; var obj1, obj2: TValuefields);
begin
  setobj(L, obj1, obj2);
end;

//#define setsvalue2n     setsvalue
procedure setsvalue2n(const L: Plua_State; var o: TValuefields; const x: PTString);
begin
  setsvalue(L, o, x);
end;

//#define setobj2t(L,o1,o2)  ((void)L, *(o1)=*(o2), checkliveness(L,(o1)))
procedure setobj2t(const L: Plua_State; const o1, o2: PTValue);
begin
  o1^ := o2^;
  checkliveness(L,o1);
end;

//#define getstr(ts)  \
//  check_exp(sizeof((ts)->extra), cast(char *, (ts)) + sizeof(UTString))
function getstr(const ts: PTString): PChar;
begin
  Result := check_exp(sizeof(ts^.extra)<>0, Pointer(ts) + sizeof(UTString));
end;

//#define svalue(o)       getstr(tsvalue(o))
function svalue(const o: TValuefields): PChar;
begin
  Result := getstr(tsvalue(o));
end;

//#define tsslen(s)       ((s)->tt == LUA_TSHRSTR ? (s)->shrlen : (s)->u.lnglen)
function tsslen(const s: PTString): SizeUInt;
begin
  if s^.header.tt = LUA_TSHRSTR then
    Result := s^.shrlen
  else
    Result := s^.u_lnglen;
end;

//#define vslen(o)        tsslen(tsvalue(o))
function vslen(const o: TValuefields): SizeUInt;
begin
  Result := tsslen(tsvalue(o));
end;

//#define getudatamem(u)  \
//  check_exp(sizeof((u)->ttuv_), (cast(char*, (u)) + sizeof(UUdata)))
function getudatamem(const u: PUdata): PByte;
begin
  Result := check_exp(sizeof(u^.ttuv_)<>0, Pointer(u) + sizeof(UUdata));
end;

//#define setuservalue(L,u,o) \
//        { const TValue *io=(o); Udata *iu = (u); \
//          iu->user_ = io->value_; iu->ttuv_ = rttype(io); \
//          checkliveness(L,io); }
procedure setuservalue(const L: Plua_State; const u: PUdata; const o: TValuefields);
begin
  u^.user_ := o.value_;
  u^.ttuv_ := rttype(o);
  checkliveness(L, o);
end;

//#define getuservalue(L,u,o) \
//        { TValue *io=(o); const Udata *iu = (u); \
//          io->value_ = iu->user_; settt_(io, iu->ttuv_); \
//          checkliveness(L,io); }
procedure getuservalue(const L: Plua_State; const u: PUdata; var o: TValuefields);
begin
  o.value_ := u^.user_;
  settt_(o, u^.ttuv_);
  checkliveness(L, o);
end;

//#define isLfunction(o)  ttisLclosure(o)
function isLfunction(const o: TValuefields): Boolean;
begin
  Result := ttisLclosure(o);
end;

//#define getproto(o)     (clLvalue(o)->p)
function getproto(const o: TValuefields): PProto;
begin
  Result := clLvalue(o)^.p;
end;

//#define setnodekey(L,key,obj) \
//        { TKey *k_=(key); const TValue *io_=(obj); \
//          k_->nk.value_ = io_->value_; k_->nk.tt_ = io_->tt_; \
//          (void)L; checkliveness(L,io_); }
procedure setnodekey(const L: Plua_State; var key: TKey; const obj: TValuefields);
begin
  key.nk.fields := obj; // value_ and tt_
  checkliveness(L, obj);
end;

//#define lmod(s,size) \
//        (check_exp((size&(size-1))==0, (cast(int, (s) & ((size)-1)))))
function lmod(const s, size: Integer): Integer;
begin
  Result := check_exp((size and (size-1)) = 0, s and (size-1));
end;

//#define twoto(x)        (1<<(x))
function twoto(const x: Integer): Integer;
begin
  Result := 1 shl x;
end;

//#define sizenode(t)     (twoto((t)->lsizenode))
function sizenode(const t: Table): Integer;
begin
  Result := 1 shl t.lsizenode;
end;

function luaO_int2fb(const x: Cardinal): Integer;
begin

end;

function luaO_fb2int(const x: Integer): Integer;
begin

end;

function luaO_utf8esc(const buff: PChar; const x: Cardinal): Integer;
begin

end;

function luaO_ceillog2(const x: Cardinal): Integer;
begin

end;

procedure luaO_arith(const L: Plua_State; const op: Integer; const p1, p2, res: PTValue);
begin

end;

function luaO_str2num(const s: PChar; const o: PTValue): SizeUInt;
begin

end;

function luaO_hexavalue(const c: Integer): Integer;
begin

end;

procedure luaO_tostring(const L: Plua_State; const obj: StkId);
begin

end;

function luaO_pushvfstring(const L: Plua_State; const fmt: PChar; argp: array of const): PChar;
begin

end;

function luaO_pushfstring(const L: Plua_State; const fmt: PChar; argp: array of const): PChar;
begin

end;

procedure luaO_chunkid(const out_: PChar; const source: PChar; const len: SizeUInt);
begin

end;

end.

