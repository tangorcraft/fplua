unit fp_lua;
(*
** FP-Lua: Free pascal implementation of Lua - A Scripting Language
** See Copyright Notice at the end of this file
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types;

(*
** state manipulation
*)
{ TODO
LUA_API lua_State *(lua_newstate) (lua_Alloc f, void *ud);
LUA_API void       (lua_close) (lua_State *L);
LUA_API lua_State *(lua_newthread) (lua_State *L);

LUA_API lua_CFunction (lua_atpanic) (lua_State *L, lua_CFunction panicf);


LUA_API const lua_Number *(lua_version) (lua_State *L);
}
function lua_newstate(const f: lua_Alloc; const ud: Pointer): Plua_State;
procedure lua_close(const L: Plua_State);
function lua_newthread(const L: Plua_State): Plua_State;

function lua_atpanic(const L: Plua_State; const panicf: lua_CFunction): lua_CFunction;

function lua_version(const L: Plua_State): Plua_Number;


(*
** basic stack manipulation
*)
{ TODO
LUA_API int   (lua_absindex) (lua_State *L, int idx);
LUA_API int   (lua_gettop) (lua_State *L);
LUA_API void  (lua_settop) (lua_State *L, int idx);
LUA_API void  (lua_pushvalue) (lua_State *L, int idx);
LUA_API void  (lua_rotate) (lua_State *L, int idx, int n);
LUA_API void  (lua_copy) (lua_State *L, int fromidx, int toidx);
LUA_API int   (lua_checkstack) (lua_State *L, int n);

LUA_API void  (lua_xmove) (lua_State *from, lua_State *to, int n);
}
function lua_absindex(const L: Plua_State; const idx: Integer): Integer;
function lua_gettop(const L: Plua_State): Integer;
procedure lua_settop(const L: Plua_State; const idx: Integer);
procedure lua_pushvalue(const L: Plua_State; const idx: Integer);
procedure lua_rotate(const L: Plua_State; const idx, n: Integer);
procedure lua_copy(const L: Plua_State; const fromidx, toidx: Integer);
function lua_checkstack(const L: Plua_State; const n: Integer): Integer;

procedure lua_xmove(const from, to_: Plua_State; const n: Integer);

(*
** access functions (stack -> C)
*)
{ TODO
LUA_API int             (lua_isnumber) (lua_State *L, int idx);
LUA_API int             (lua_isstring) (lua_State *L, int idx);
LUA_API int             (lua_iscfunction) (lua_State *L, int idx);
LUA_API int             (lua_isinteger) (lua_State *L, int idx);
LUA_API int             (lua_isuserdata) (lua_State *L, int idx);
LUA_API int             (lua_type) (lua_State *L, int idx);
LUA_API const char     *(lua_typename) (lua_State *L, int tp);

LUA_API lua_Number      (lua_tonumberx) (lua_State *L, int idx, int *isnum);
LUA_API lua_Integer     (lua_tointegerx) (lua_State *L, int idx, int *isnum);
LUA_API int             (lua_toboolean) (lua_State *L, int idx);
LUA_API const char     *(lua_tolstring) (lua_State *L, int idx, size_t *len);
LUA_API size_t          (lua_rawlen) (lua_State *L, int idx);
LUA_API lua_CFunction   (lua_tocfunction) (lua_State *L, int idx);
LUA_API void           *(lua_touserdata) (lua_State *L, int idx);
LUA_API lua_State      *(lua_tothread) (lua_State *L, int idx);
LUA_API const void     *(lua_topointer) (lua_State *L, int idx);
}
function lua_isnumber(const L: Plua_State; const idx: Integer): lu_int;
function lua_isstring(const L: Plua_State; const idx: Integer): lu_int;
function lua_iscfunction(const L: Plua_State; const idx: Integer): lu_int;
function lua_isinteger(const L: Plua_State; const idx: Integer): lu_int;
function lua_isuserdata(const L: Plua_State; const idx: Integer): lu_int;
function lua_type(const L: Plua_State; const idx: Integer): lu_int;
function lua_typename(const L: Plua_State; const tp: Integer): PChar;

function lua_tonumberx(const L: Plua_State; const idx: Integer; const isnum: PInteger): lua_Number;
function lua_tointegerx(const L: Plua_State; const idx: Integer; const isnum: PInteger): lua_Integer;
function lua_toboolean(const L: Plua_State; const idx: Integer): lu_int;
function lua_tolstring(const L: Plua_State; const idx: Integer; const len: PSizeUInt): PChar;
function lua_rawlen(const L: Plua_State; const idx: Integer): SizeUInt;
function lua_tocfunction(const L: Plua_State; const idx: Integer): lua_CFunction;
function lua_touserdata(const L: Plua_State; const idx: Integer): Pointer;
function lua_tothread(const L: Plua_State; const idx: Integer): Plua_State;
function lua_topointer(const L: Plua_State; const idx: Integer): Pointer;

(*
** Comparison and arithmetic functions
*)
// TODO
//LUA_API void  (lua_arith) (lua_State *L, int op);
procedure lua_arith(const L: Plua_State; const op: Integer);

{ TODO
LUA_API int   (lua_rawequal) (lua_State *L, int idx1, int idx2);
LUA_API int   (lua_compare) (lua_State *L, int idx1, int idx2, int op);
}
function lua_rawequal(const L: Plua_State; const idx1, idx2: Integer): lu_int;
function lua_compare(const L: Plua_State; const idx1, idx2, op: Integer): lu_int;

(*
** push functions (C -> stack)
*)
{ TODO
LUA_API void        (lua_pushnil) (lua_State *L);
LUA_API void        (lua_pushnumber) (lua_State *L, lua_Number n);
LUA_API void        (lua_pushinteger) (lua_State *L, lua_Integer n);
LUA_API const char *(lua_pushlstring) (lua_State *L, const char *s, size_t len);
LUA_API const char *(lua_pushstring) (lua_State *L, const char *s);
LUA_API const char *(lua_pushvfstring) (lua_State *L, const char *fmt,
                                                      va_list argp);
LUA_API const char *(lua_pushfstring) (lua_State *L, const char *fmt, ...);
LUA_API void  (lua_pushcclosure) (lua_State *L, lua_CFunction fn, int n);
LUA_API void  (lua_pushboolean) (lua_State *L, int b);
LUA_API void  (lua_pushlightuserdata) (lua_State *L, void *p);
LUA_API int   (lua_pushthread) (lua_State *L);
}
procedure lua_pushnil(const L: Plua_State);
procedure lua_pushnumber(const L: Plua_State; const n: lua_Number);
procedure lua_pushinteger(const L: Plua_State; const n: lua_Integer);
function lua_pushlstring(const L: Plua_State; const s: PChar; const len: SizeUInt): PChar;
function lua_pushstring(const L: Plua_State; const s: PChar): PChar;
function lua_pushvfstring(const L: Plua_State; const fmt: PChar; const argp: array of const): PChar;
function lua_pushfstring(const L: Plua_State; const fmt: PChar; const args: array of const): PChar;
procedure lua_pushcclosure(const L: Plua_State; const fn: lua_CFunction; const n: Integer);
procedure lua_pushboolean(const L: Plua_State; const b: lu_int);
procedure lua_pushlightuserdata(const L: Plua_State; const p: Pointer);
function lua_pushthread(const L: Plua_State): Integer;

(*
** get functions (Lua -> stack)
*)
{ TODO
LUA_API int (lua_getglobal) (lua_State *L, const char *name);
LUA_API int (lua_gettable) (lua_State *L, int idx);
LUA_API int (lua_getfield) (lua_State *L, int idx, const char *k);
LUA_API int (lua_geti) (lua_State *L, int idx, lua_Integer n);
LUA_API int (lua_rawget) (lua_State *L, int idx);
LUA_API int (lua_rawgeti) (lua_State *L, int idx, lua_Integer n);
LUA_API int (lua_rawgetp) (lua_State *L, int idx, const void *p);

LUA_API void  (lua_createtable) (lua_State *L, int narr, int nrec);
LUA_API void *(lua_newuserdata) (lua_State *L, size_t sz);
LUA_API int   (lua_getmetatable) (lua_State *L, int objindex);
LUA_API int  (lua_getuservalue) (lua_State *L, int idx);
}
function lua_getglobal(const L: Plua_State; const name: PChar): Integer;
function lua_gettable(const L: Plua_State; const idx: Integer): Integer;
function lua_getfield(const L: Plua_State; const idx: Integer; const k: PChar): Integer;
function lua_geti(const L: Plua_State; const idx: Integer; const n: lua_Integer): Integer;
function lua_rawget(const L: Plua_State; const idx: Integer): Integer;
function lua_rawgeti(const L: Plua_State; const idx: Integer; const n: lua_Integer): Integer;
function lua_rawgetp(const L: Plua_State; const idx: Integer; const p: Pointer): Integer;

procedure lua_createtable(const L: Plua_State; const narr, nrec: Integer);
function lua_newuserdata(const L: Plua_State; const sz: SizeUInt): Pointer;
function lua_getmetatable(const L: Plua_State; const objindex: Integer): Integer;
function lua_getuservalue(const L: Plua_State; const idx: Integer): Integer;

(*
** set functions (stack -> Lua)
*)
{ TODO
LUA_API void  (lua_setglobal) (lua_State *L, const char *name);
LUA_API void  (lua_settable) (lua_State *L, int idx);
LUA_API void  (lua_setfield) (lua_State *L, int idx, const char *k);
LUA_API void  (lua_seti) (lua_State *L, int idx, lua_Integer n);
LUA_API void  (lua_rawset) (lua_State *L, int idx);
LUA_API void  (lua_rawseti) (lua_State *L, int idx, lua_Integer n);
LUA_API void  (lua_rawsetp) (lua_State *L, int idx, const void *p);
LUA_API int   (lua_setmetatable) (lua_State *L, int objindex);
LUA_API void  (lua_setuservalue) (lua_State *L, int idx);
}
procedure lua_setglobal(const L: Plua_State; const name: PChar);
procedure lua_settable(const L: Plua_State; const idx: Integer);
procedure lua_setfield(const L: Plua_State; const idx: Integer; const k: PChar);
procedure lua_seti(const L: Plua_State; const idx: Integer; const n: lua_Integer);
procedure lua_rawset(const L: Plua_State; const idx: Integer);
procedure lua_rawseti(const L: Plua_State; const idx: Integer; const n: lua_Integer);
procedure lua_rawsetp(const L: Plua_State; const idx: Integer; const p: Pointer);
function lua_setmetatable(const L: Plua_State; const objindex: Integer): Integer;
procedure lua_setuservalue(const L: Plua_State; const idx: Integer);

(*
** 'load' and 'call' functions (load and run Lua code)
*)
// TODO
//LUA_API void  (lua_callk) (lua_State *L, int nargs, int nresults,
//                           lua_KContext ctx, lua_KFunction k);
procedure lua_callk(const L: Plua_State; const nargs, nresults: Integer;
  const ctx: lua_KContext; const k: lua_KFunction);
procedure lua_call(const L: Plua_State; const n, r: Integer);

//LUA_API int   (lua_pcallk) (lua_State *L, int nargs, int nresults, int errfunc,
//                            lua_KContext ctx, lua_KFunction k);
function lua_pcallk(const L: Plua_State; const nargs, nresults, errfunc: Integer;
  const ctx: lua_KContext; const k: lua_KFunction): Integer;
function lua_pcall(const L: Plua_State; const n, r, f: Integer): Integer;

//LUA_API int   (lua_load) (lua_State *L, lua_Reader reader, void *dt,
//                          const char *chunkname, const char *mode);
function lua_load(const L: Plua_State; const reader: lua_Reader; const dt: Pointer;
  const chunkname, mode: PChar): Integer;

//LUA_API int (lua_dump) (lua_State *L, lua_Writer writer, void *data, int strip);
function lua_dump(const L: Plua_State; const writer: lua_Writer; const data: Pointer;
  const strip: Integer): Integer;

(*
** coroutine functions
*)
{ TODO
LUA_API int  (lua_yieldk)     (lua_State *L, int nresults, lua_KContext ctx,
                               lua_KFunction k);
LUA_API int  (lua_resume)     (lua_State *L, lua_State *from, int narg);
LUA_API int  (lua_status)     (lua_State *L);
LUA_API int (lua_isyieldable) (lua_State *L);
}
function lua_yieldk(const L: Plua_State; const nresults: Integer;
  const ctx: lua_KContext; const k: lua_KFunction): Integer;
function lua_resume(const L, from: Plua_State; const narg: Integer): Integer;
function lua_status(const L: Plua_State): Integer;
function lua_isyieldable(const L: Plua_State): lu_int;

function lua_yield(const L: Plua_State; const n: Integer): Integer;

(*
** garbage-collection function
*)
// TODO
//LUA_API int (lua_gc) (lua_State *L, int what, int data);
function lua_gc(const L: Plua_State; const what, data: Integer): Integer;

(*
** miscellaneous functions
*)
// TODO
//LUA_API int   (lua_error) (lua_State *L);
function lua_error(const L: Plua_State): Integer;

//LUA_API int   (lua_next) (lua_State *L, int idx);
function lua_next(const L: Plua_State; const idx: Integer): Integer;

//LUA_API void  (lua_concat) (lua_State *L, int n);
//LUA_API void  (lua_len)    (lua_State *L, int idx);
procedure lua_concat(const L: Plua_State; const n: Integer);
procedure lua_len(const L: Plua_State; const idx: Integer);

//LUA_API size_t   (lua_stringtonumber) (lua_State *L, const char *s);
function lua_stringtonumber(const L: Plua_State; const s: PChar): SizeUInt;

//LUA_API lua_Alloc (lua_getallocf) (lua_State *L, void **ud);
//LUA_API void      (lua_setallocf) (lua_State *L, lua_Alloc f, void *ud);
function lua_getallocf(const L: Plua_State; const ud: PPointer): lua_Alloc;
procedure lua_setallocf(const L: Plua_State; const f:lua_Alloc; const ud: Pointer);

(*
** ===============================================================
** some useful macros
** ===============================================================
*)
// TODO
function lua_getextraspace(const L: Plua_State): Pointer;

function lua_tonumber(const L: Plua_State; const i: Integer): lua_Number;
function lua_tointeger(const L: Plua_State; const i: Integer): lua_Integer;

procedure lua_pop(const L: Plua_State; const n: Integer);

procedure lua_newtable(const L: Plua_State);

procedure lua_register(const L: Plua_State; const n: PChar; const f: lua_CFunction);

procedure lua_pushcfunction(const L: Plua_State; const f: lua_CFunction);

function lua_isfunction(const L: Plua_State; const n: Integer): Boolean;
function lua_istable(const L: Plua_State; const n: Integer): Boolean;
function lua_islightuserdata(const L: Plua_State; const n: Integer): Boolean;
function lua_isnil(const L: Plua_State; const n: Integer): Boolean;
function lua_isboolean(const L: Plua_State; const n: Integer): Boolean;
function lua_isthread(const L: Plua_State; const n: Integer): Boolean;
function lua_isnone(const L: Plua_State; const n: Integer): Boolean;
function lua_isnoneornil(const L: Plua_State; const n: Integer): Boolean;

(*
** This macro exists to make sure that value passed to lua_pushstring is string literal
** This cannot be replicated in free pascal, passing non-literal value may result in crash
*)
function lua_pushliteral(const L: Plua_State; const s: PChar): PChar;

procedure lua_pushglobaltable(const L: Plua_State);

function lua_tostring(const L: Plua_State; const i: Integer): PChar;

procedure lua_insert(const L: Plua_State; const idx: Integer);

procedure lua_remove(const L: Plua_State; const idx: Integer);

procedure lua_replace(const L: Plua_State; const idx: Integer);

(* =============================================================== *)


(*
** {==============================================================
** compatibility macros for unsigned conversions
** ===============================================================
*)
{$ifdef LUA_COMPAT_APIINTCASTS}
procedure lua_pushunsigned(const L: Plua_State; const n: lua_Unsigned);
function lua_tounsignedx(const L: Plua_State; const idx: Integer; const isnum: PInteger): lua_Unsigned;
function lua_tounsigned(const L: Plua_State; const idx: Integer): lua_Unsigned;
{$endif}
(* }============================================================== *)

type
  fplua_procL = procedure (const L: Plua_State);
  fplua_procLn = procedure (const L: Plua_State; const n: Integer);
  fplua_procLL1 = procedure (const L, L1: Plua_State);

(*
** macros that are executed whenever program enters the Lua core
** ('lua_lock') and leaves the core ('lua_unlock')
*)
{$ifdef FPLUA_EX_LOCK}
var
  fplua_lock_: fplua_procL;
  fplua_unlock_: fplua_procL;
//#define lua_lock(L)   ((void) 0)
//#define lua_unlock(L) ((void) 0)
{$endif}
procedure lua_lock(const L: Plua_State);
procedure lua_unlock(const L: Plua_State);

(*
** macro executed during Lua functions at points where the
** function can yield.
*)
{$ifdef FPLUA_EX_THREADYEILD}
var
  fpluai_threadyield_: fplua_procL;
//#define luai_threadyield(L)   {lua_unlock(L); lua_lock(L);}
{$endif}
procedure luai_threadyield(const L: Plua_State);

(*
** these macros allow user-specific actions on threads when you defined
** LUAI_EXTRASPACE and need to do something extra when a thread is
** created/deleted/resumed/yielded.
*)
{$ifdef FPLUA_EX_THREAD_ACTIONS}
var
  fpluai_userstateopen_: fplua_procL;
  fpluai_userstateclose_: fplua_procL;
  fpluai_userstatethread_: fplua_procLL1;
  fpluai_userstatefree_: fplua_procLL1;
  fpluai_userstateresume_: fplua_procLn;
  fpluai_userstateyield_: fplua_procLn;
{$endif}

procedure luai_userstateopen(const L: Plua_State);

procedure luai_userstateclose(const L: Plua_State);

procedure luai_userstatethread(const L, L1: Plua_State);

procedure luai_userstatefree(const L, L1: Plua_State);

procedure luai_userstateresume(const L: Plua_State; const n: Integer);

procedure luai_userstateyield(const L: Plua_State; const n: Integer);

(*
** The luai_num* macros define the primitive operations over numbers.
*)

(* floor division (defined as 'floor(a/b)') *)
//#if !defined(luai_numidiv)
//#define luai_numidiv(L,a,b)     ((void)L, l_floor(luai_numdiv(L,a,b)))
//#endif
function luai_numidiv(var L: lua_State; const a, b: lua_Number): lua_Number;

(* float division *)
// TODO
//#if !defined(luai_numdiv)
//#define luai_numdiv(L,a,b)      ((a)/(b))
//#endif
function luai_numdiv(var L: lua_State; const a, b: lua_Number): lua_Number;

(*
** modulo: defined as 'a - floor(a/b)*b'; this definition gives NaN when
** 'b' is huge, but the result should be 'a'. 'fmod' gives the result of
** 'a - trunc(a/b)*b', and therefore must be corrected when 'trunc(a/b)
** ~= floor(a/b)'. That happens when the division has a non-integer
** negative result, which is equivalent to the test below.
*)
// TODO
//#if !defined(luai_nummod)
//#define luai_nummod(L,a,b,m)  \
  { (m) = l_mathop(fmod)(a,b); if ((m)*(b) < 0) (m) += (b); }
//#endif
procedure luai_nummod(var L: lua_State; const a, b: lua_Number; var m: lua_Number);

(* exponentiation *)
//#if !defined(luai_numpow)
//#define luai_numpow(L,a,b)      ((void)L, l_mathop(pow)(a,b))
//#endif
function luai_numpow(var L: lua_State; const a, b: lua_Number): lua_Number;

(* the others are quite standard operations *)
{#if !defined(luai_numadd)
#define luai_numadd(L,a,b)      ((a)+(b))
#define luai_numsub(L,a,b)      ((a)-(b))
#define luai_nummul(L,a,b)      ((a)*(b))
#define luai_numunm(L,a)        (-(a))
#define luai_numeq(a,b)         ((a)==(b))
#define luai_numlt(a,b)         ((a)<(b))
#define luai_numle(a,b)         ((a)<=(b))
#define luai_numisnan(a)        (!luai_numeq((a), (a)))
#endif}
function luai_numadd(var L: lua_State; const a, b: lua_Number): lua_Number;
function luai_numsub(var L: lua_State; const a, b: lua_Number): lua_Number;
function luai_nummul(var L: lua_State; const a, b: lua_Number): lua_Number;
function luai_numunm(var L: lua_State; const a: lua_Number): lua_Number;
function luai_numeq(const a, b: lua_Number): Boolean;
function luai_numlt(const a, b: lua_Number): Boolean;
function luai_numle(const a, b: lua_Number): Boolean;
function luai_numisnan(const a: lua_Number): Boolean;

// Debug API
// TODO
//LUA_API int (lua_getstack) (lua_State *L, int level, lua_Debug *ar);
//LUA_API int (lua_getinfo) (lua_State *L, const char *what, lua_Debug *ar);
//LUA_API const char *(lua_getlocal) (lua_State *L, const lua_Debug *ar, int n);
//LUA_API const char *(lua_setlocal) (lua_State *L, const lua_Debug *ar, int n);
//LUA_API const char *(lua_getupvalue) (lua_State *L, int funcindex, int n);
//LUA_API const char *(lua_setupvalue) (lua_State *L, int funcindex, int n);
function lua_getstack(const L: Plua_State; const level: Integer; const ar: Plua_Debug): Integer;
function lua_getinfo(const L: Plua_State; const what: PChar; const ar: Plua_Debug): Integer;
function lua_getlocal(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;
function lua_setlocal(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;
function lua_getupvalue(const L: Plua_State; const funcindex, n: Integer): PChar;
function lua_setupvalue(const L: Plua_State; const funcindex, n: Integer): PChar;

//LUA_API void *(lua_upvalueid) (lua_State *L, int fidx, int n);
//LUA_API void  (lua_upvaluejoin) (lua_State *L, int fidx1, int n1,
//                                               int fidx2, int n2);
function lua_upvalueid(const L: Plua_State; const fidx, n: Integer): Pointer;
procedure lua_upvaluejoin(const L: Plua_State; const fidx1, n1, fidx2, n2: Integer);

//LUA_API void (lua_sethook) (lua_State *L, lua_Hook func, int mask, int count);
//LUA_API lua_Hook (lua_gethook) (lua_State *L);
//LUA_API int (lua_gethookmask) (lua_State *L);
//LUA_API int (lua_gethookcount) (lua_State *L);
procedure lua_sethook(const L: Plua_State; const func: lua_Hook; const mask, count: Integer);
function lua_gethook(const L: Plua_State): lua_Hook;
function lua_gethookmask(const L: Plua_State): Integer;
function lua_gethookcount(const L: Plua_State): Integer;

implementation

uses
  Math;

function lua_newstate(const f: lua_Alloc; const ud: Pointer): Plua_State;
begin

end;

procedure lua_close(const L: Plua_State);
begin

end;

function lua_newthread(const L: Plua_State): Plua_State;
begin

end;

function lua_atpanic(const L: Plua_State; const panicf: lua_CFunction): lua_CFunction;
begin

end;

function lua_version(const L: Plua_State): Plua_Number;
begin

end;

function lua_absindex(const L: Plua_State; const idx: Integer): Integer;
begin

end;

function lua_gettop(const L: Plua_State): Integer;
begin

end;

procedure lua_settop(const L: Plua_State; const idx: Integer);
begin

end;

procedure lua_pushvalue(const L: Plua_State; const idx: Integer);
begin

end;

procedure lua_rotate(const L: Plua_State; const idx, n: Integer);
begin

end;

procedure lua_copy(const L: Plua_State; const fromidx, toidx: Integer);
begin

end;

function lua_checkstack(const L: Plua_State; const n: Integer): Integer;
begin

end;

procedure lua_xmove(const from, to_: Plua_State; const n: Integer);
begin

end;

function lua_isnumber(const L: Plua_State; const idx: Integer): lu_int;
begin

end;

function lua_isstring(const L: Plua_State; const idx: Integer): lu_int;
begin

end;

function lua_iscfunction(const L: Plua_State; const idx: Integer): lu_int;
begin

end;

function lua_isinteger(const L: Plua_State; const idx: Integer): lu_int;
begin

end;

function lua_isuserdata(const L: Plua_State; const idx: Integer): lu_int;
begin

end;

function lua_type(const L: Plua_State; const idx: Integer): lu_int;
begin

end;

function lua_typename(const L: Plua_State; const tp: Integer): PChar;
begin

end;

function lua_tonumberx(const L: Plua_State; const idx: Integer;
  const isnum: PInteger): lua_Number;
begin

end;

function lua_tointegerx(const L: Plua_State; const idx: Integer;
  const isnum: PInteger): lua_Integer;
begin

end;

function lua_toboolean(const L: Plua_State; const idx: Integer): lu_int;
begin

end;

function lua_tolstring(const L: Plua_State; const idx: Integer; const len: PSizeUInt): PChar;
begin

end;

function lua_rawlen(const L: Plua_State; const idx: Integer): SizeUInt;
begin

end;

function lua_tocfunction(const L: Plua_State; const idx: Integer): lua_CFunction;
begin

end;

function lua_touserdata(const L: Plua_State; const idx: Integer): Pointer;
begin

end;

function lua_tothread(const L: Plua_State; const idx: Integer): Plua_State;
begin

end;

function lua_topointer(const L: Plua_State; const idx: Integer): Pointer;
begin

end;

procedure lua_arith(const L: Plua_State; const op: Integer);
begin

end;

function lua_rawequal(const L: Plua_State; const idx1, idx2: Integer): lu_int;
begin

end;

function lua_compare(const L: Plua_State; const idx1, idx2, op: Integer): lu_int;
begin

end;

procedure lua_pushnil(const L: Plua_State);
begin

end;

procedure lua_pushnumber(const L: Plua_State; const n: lua_Number);
begin

end;

procedure lua_pushinteger(const L: Plua_State; const n: lua_Integer);
begin

end;

function lua_pushlstring(const L: Plua_State; const s: PChar; const len: SizeUInt): PChar;
begin

end;

function lua_pushstring(const L: Plua_State; const s: PChar): PChar;
begin

end;

function lua_pushvfstring(const L: Plua_State; const fmt: PChar;
  const argp: array of const): PChar;
begin

end;

function lua_pushfstring(const L: Plua_State; const fmt: PChar;
  const args: array of const): PChar;
begin

end;

procedure lua_pushcclosure(const L: Plua_State; const fn: lua_CFunction; const n: Integer);
begin

end;

procedure lua_pushboolean(const L: Plua_State; const b: lu_int);
begin

end;

procedure lua_pushlightuserdata(const L: Plua_State; const p: Pointer);
begin

end;

function lua_pushthread(const L: Plua_State): Integer;
begin

end;

function lua_getglobal(const L: Plua_State; const name: PChar): Integer;
begin

end;

function lua_gettable(const L: Plua_State; const idx: Integer): Integer;
begin

end;

function lua_getfield(const L: Plua_State; const idx: Integer; const k: PChar): Integer;
begin

end;

function lua_geti(const L: Plua_State; const idx: Integer; const n: lua_Integer): Integer;
begin

end;

function lua_rawget(const L: Plua_State; const idx: Integer): Integer;
begin

end;

function lua_rawgeti(const L: Plua_State; const idx: Integer; const n: lua_Integer): Integer;
begin

end;

function lua_rawgetp(const L: Plua_State; const idx: Integer; const p: Pointer): Integer;
begin

end;

procedure lua_createtable(const L: Plua_State; const narr, nrec: Integer);
begin

end;

function lua_newuserdata(const L: Plua_State; const sz: SizeUInt): Pointer;
begin

end;

function lua_getmetatable(const L: Plua_State; const objindex: Integer): Integer;
begin

end;

function lua_getuservalue(const L: Plua_State; const idx: Integer): Integer;
begin

end;

procedure lua_setglobal(const L: Plua_State; const name: PChar);
begin

end;

procedure lua_settable(const L: Plua_State; const idx: Integer);
begin

end;

procedure lua_setfield(const L: Plua_State; const idx: Integer; const k: PChar);
begin

end;

procedure lua_seti(const L: Plua_State; const idx: Integer; const n: lua_Integer);
begin

end;

procedure lua_rawset(const L: Plua_State; const idx: Integer);
begin

end;

procedure lua_rawseti(const L: Plua_State; const idx: Integer; const n: lua_Integer);
begin

end;

procedure lua_rawsetp(const L: Plua_State; const idx: Integer; const p: Pointer);
begin

end;

function lua_setmetatable(const L: Plua_State; const objindex: Integer): Integer;
begin

end;

procedure lua_setuservalue(const L: Plua_State; const idx: Integer);
begin

end;

procedure lua_callk(const L: Plua_State; const nargs, nresults: Integer;
  const ctx: lua_KContext; const k: lua_KFunction);
begin

end;

//#define lua_call(L,n,r)         lua_callk(L, (n), (r), 0, NULL)
procedure lua_call(const L: Plua_State; const n, r: Integer);
begin
  lua_callk(L, n, r, 0, Nil);
end;

function lua_pcallk(const L: Plua_State; const nargs, nresults, errfunc: Integer;
  const ctx: lua_KContext; const k: lua_KFunction): Integer;
begin

end;

//#define lua_pcall(L,n,r,f)      lua_pcallk(L, (n), (r), (f), 0, NULL)
function lua_pcall(const L: Plua_State; const n, r, f: Integer): Integer;
begin
  lua_pcallk(L, n, r, f, 0, Nil);
end;

function lua_load(const L: Plua_State; const reader: lua_Reader; const dt: Pointer;
  const chunkname, mode: PChar): Integer;
begin

end;

function lua_dump(const L: Plua_State; const writer: lua_Writer; const data: Pointer;
  const strip: Integer): Integer;
begin

end;

function lua_yieldk(const L: Plua_State; const nresults: Integer; const ctx: lua_KContext;
  const k: lua_KFunction): Integer;
begin

end;

function lua_resume(const L, from: Plua_State; const narg: Integer): Integer;
begin

end;

function lua_status(const L: Plua_State): Integer;
begin

end;

function lua_isyieldable(const L: Plua_State): lu_int;
begin

end;

//#define lua_yield(L,n)          lua_yieldk(L, (n), 0, NULL)
function lua_yield(const L: Plua_State; const n: Integer): Integer;
begin
  lua_yieldk(L, n, 0, Nil);
end;

function lua_gc(const L: Plua_State; const what, data: Integer): Integer;
begin

end;

function lua_error(const L: Plua_State): Integer;
begin

end;

function lua_next(const L: Plua_State; const idx: Integer): Integer;
begin

end;

procedure lua_concat(const L: Plua_State; const n: Integer);
begin

end;

procedure lua_len(const L: Plua_State; const idx: Integer);
begin

end;

function lua_stringtonumber(const L: Plua_State; const s: PChar): SizeUInt;
begin

end;

function lua_getallocf(const L: Plua_State; const ud: PPointer): lua_Alloc;
begin

end;

procedure lua_setallocf(const L: Plua_State; const f: lua_Alloc; const ud: Pointer);
begin

end;

//#define lua_getextraspace(L)    ((void *)((char *)(L) - LUA_EXTRASPACE))
function lua_getextraspace(const L: Plua_State): Pointer;
begin
  Result := Pointer(L) - LUA_EXTRASPACE;
end;

//#define lua_tonumber(L,i)       lua_tonumberx(L,(i),NULL)
function lua_tonumber(const L: Plua_State; const i: Integer): lua_Number;
begin
  Result := lua_tonumberx(L, i, nil);
end;

//#define lua_tointeger(L,i)      lua_tointegerx(L,(i),NULL)
function lua_tointeger(const L: Plua_State; const i: Integer): lua_Integer;
begin
  Result := lua_tointegerx(L,i,nil);
end;

//#define lua_pop(L,n)            lua_settop(L, -(n)-1)
procedure lua_pop(const L: Plua_State; const n: Integer);
begin
  lua_settop(L, -(n)-1);
end;

//#define lua_newtable(L)         lua_createtable(L, 0, 0)
procedure lua_newtable(const L: Plua_State);
begin
  lua_createtable(L, 0, 0);
end;

//#define lua_register(L,n,f) (lua_pushcfunction(L, (f)), lua_setglobal(L, (n)))
procedure lua_register(const L: Plua_State; const n: PChar; const f: lua_CFunction);
begin
  lua_pushcfunction(L, f);
  lua_setglobal(L, n);
end;

//#define lua_pushcfunction(L,f)  lua_pushcclosure(L, (f), 0)
procedure lua_pushcfunction(const L: Plua_State; const f: lua_CFunction);
begin
  lua_pushcclosure(L, f, 0);
end;

//#define lua_isfunction(L,n)     (lua_type(L, (n)) == LUA_TFUNCTION)
function lua_isfunction(const L: Plua_State; const n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TFUNCTION);
end;

//#define lua_istable(L,n)        (lua_type(L, (n)) == LUA_TTABLE)
function lua_istable(const L: Plua_State; const n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TTABLE);
end;

//#define lua_islightuserdata(L,n)        (lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
function lua_islightuserdata(const L: Plua_State; const n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TLIGHTUSERDATA);
end;

//#define lua_isnil(L,n)          (lua_type(L, (n)) == LUA_TNIL)
function lua_isnil(const L: Plua_State; const n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TNIL);
end;

//#define lua_isboolean(L,n)      (lua_type(L, (n)) == LUA_TBOOLEAN)
function lua_isboolean(const L: Plua_State; const n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TBOOLEAN);
end;

//#define lua_isthread(L,n)       (lua_type(L, (n)) == LUA_TTHREAD)
function lua_isthread(const L: Plua_State; const n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TTHREAD);
end;

//#define lua_isnone(L,n)         (lua_type(L, (n)) == LUA_TNONE)
function lua_isnone(const L: Plua_State; const n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TNONE);
end;

//#define lua_isnoneornil(L, n)   (lua_type(L, (n)) <= 0)
function lua_isnoneornil(const L: Plua_State; const n: Integer): Boolean;
begin
  Result := (lua_type(L, n) <= 0);
end;

//#define lua_pushliteral(L, s)   lua_pushstring(L, "" s)
function lua_pushliteral(const L: Plua_State; const s: PChar): PChar;
begin
  Result := lua_pushstring(L, s);
end;

//#define lua_pushglobaltable(L)  \
//        ((void)lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS))
procedure lua_pushglobaltable(const L: Plua_State);
begin
  lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
end;

//#define lua_tostring(L,i)       lua_tolstring(L, (i), NULL)
function lua_tostring(const L: Plua_State; const i: Integer): PChar;
begin
  Result := lua_tolstring(L, i, nil);
end;

//#define lua_insert(L,idx)       lua_rotate(L, (idx), 1)
procedure lua_insert(const L: Plua_State; const idx: Integer);
begin
  lua_rotate(L, idx, 1);
end;

//#define lua_remove(L,idx)       (lua_rotate(L, (idx), -1), lua_pop(L, 1))
procedure lua_remove(const L: Plua_State; const idx: Integer);
begin
  lua_rotate(L, idx, -1);
  //lua_pop(L, 1); // = lua_settop(L, -(n)-1)
  lua_settop(L, -2)
end;

//#define lua_replace(L,idx)      (lua_copy(L, -1, (idx)), lua_pop(L, 1))
procedure lua_replace(const L: Plua_State; const idx: Integer);
begin
  lua_copy(L, -1, idx);
  //lua_pop(L, 1); // = lua_settop(L, -(n)-1)
  lua_settop(L, -2)
end;

{$ifdef LUA_COMPAT_APIINTCASTS}
//#define lua_pushunsigned(L,n)   lua_pushinteger(L, (lua_Integer)(n))
procedure lua_pushunsigned(const L: Plua_State; const n: lua_Unsigned);
begin
  lua_pushinteger(L, lua_Integer(n));
end;

//#define lua_tounsignedx(L,i,is) ((lua_Unsigned)lua_tointegerx(L,i,is))
function lua_tounsignedx(const L: Plua_State; const idx: Integer;
  const isnum: PInteger): lua_Unsigned;
begin
  Result := lua_Unsigned(lua_tointegerx(L,idx,isnum))
end;

//#define lua_tounsigned(L,i)     lua_tounsignedx(L,(i),NULL)
function lua_tounsigned(const L: Plua_State; const idx: Integer): lua_Unsigned;
begin
  Result := lua_Unsigned(lua_tointegerx(L,idx,nil))
end;
{$endif}

procedure lua_lock(const L: Plua_State);
begin
  {$ifdef FPLUA_EX_LOCK}
  if Assigned(fplua_lock_) then
    fplua_lock_(L);
  {$endif}
end;

procedure lua_unlock(const L: Plua_State);
begin
  {$ifdef FPLUA_EX_LOCK}
  if Assigned(fplua_unlock_) then
    fplua_unlock_(L);
  {$endif}
end;

procedure luai_threadyield(const L: Plua_State);
begin
  {$ifdef FPLUA_EX_THREADYEILD}
  if Assigned(fpluai_threadyield_) then
    fpluai_threadyield_(L);
  {$else}
  lua_lock(L);
  lua_unlock(L);
  {$endif}
end;

//#if !defined(luai_userstateopen)
//#define luai_userstateopen(L)           ((void)L)
//#endif
procedure luai_userstateopen(const L: Plua_State);
begin
  {$ifdef FPLUA_EX_THREAD_ACTIONS}
  if Assigned(fpluai_userstateopen_) then
    fpluai_userstateopen_(L);
  {$endif}
end;

//#if !defined(luai_userstateclose)
//#define luai_userstateclose(L)          ((void)L)
//#endif
procedure luai_userstateclose(const L: Plua_State);
begin
  {$ifdef FPLUA_EX_THREAD_ACTIONS}
  if Assigned(fpluai_userstateclose_) then
    fpluai_userstateclose_(L);
  {$endif}
end;

//#if !defined(luai_userstatethread)
//#define luai_userstatethread(L,L1)      ((void)L)
//#endif
procedure luai_userstatethread(const L, L1: Plua_State);
begin
  {$ifdef FPLUA_EX_THREAD_ACTIONS}
  if Assigned(fpluai_userstatethread_) then
    fpluai_userstatethread_(L, L1);
  {$endif}
end;

//#if !defined(luai_userstatefree)
//#define luai_userstatefree(L,L1)        ((void)L)
//#endif
procedure luai_userstatefree(const L, L1: Plua_State);
begin
  {$ifdef FPLUA_EX_THREAD_ACTIONS}
  if Assigned(fpluai_userstatefree_) then
    fpluai_userstatefree_(L, L1);
  {$endif}
end;

//#if !defined(luai_userstateresume)
//#define luai_userstateresume(L,n)       ((void)L)
//#endif
procedure luai_userstateresume(const L: Plua_State; const n: Integer);
begin
  {$ifdef FPLUA_EX_THREAD_ACTIONS}
  if Assigned(fpluai_userstateresume_) then
    fpluai_userstateresume_(L,n);
  {$endif}
end;

//#if !defined(luai_userstateyield)
//#define luai_userstateyield(L,n)        ((void)L)
//#endif
procedure luai_userstateyield(const L: Plua_State; const n: Integer);
begin
  {$ifdef FPLUA_EX_THREAD_ACTIONS}
  if Assigned(fpluai_userstateyield_) then
    fpluai_userstateyield_(L,n);
  {$endif}
end;

//#define luai_numidiv(L,a,b)     ((void)L, l_floor(luai_numdiv(L,a,b)))
function luai_numidiv(var L: lua_State; const a, b: lua_Number): lua_Number;
begin
  Result := l_floor(a / b);
end;

//#define luai_numdiv(L,a,b)      ((a)/(b))
function luai_numdiv(var L: lua_State; const a, b: lua_Number): lua_Number;
begin
  Result := a / b;
end;

//#define luai_nummod(L,a,b,m)  \
  { (m) = l_mathop(fmod)(a,b); if ((m)*(b) < 0) (m) += (b); }
procedure luai_nummod(var L: lua_State; const a, b: lua_Number; var m: lua_Number);
begin
  m := FMod(a, b);
  if (m * b) < 0 then
    m := m + b;
end;

//#define luai_numpow(L,a,b)      ((void)L, l_mathop(pow)(a,b))
function luai_numpow(var L: lua_State; const a, b: lua_Number): lua_Number;
begin
  Result := Power(a, b);
end;

function luai_numadd(var L: lua_State; const a, b: lua_Number): lua_Number;
begin
  Result := a + b;
end;

function luai_numsub(var L: lua_State; const a, b: lua_Number): lua_Number;
begin
  Result := a - b;
end;

function luai_nummul(var L: lua_State; const a, b: lua_Number): lua_Number;
begin
  Result := a * b;
end;

function luai_numunm(var L: lua_State; const a: lua_Number): lua_Number;
begin
  Result := -a;
end;

function luai_numeq(const a, b: lua_Number): Boolean;
begin
  Result := (a = b);
end;

function luai_numlt(const a, b: lua_Number): Boolean;
begin
  Result := (a < b);
end;

function luai_numle(const a, b: lua_Number): Boolean;
begin
  Result := (a <= b);
end;

function luai_numisnan(const a: lua_Number): Boolean;
begin
  Result := not (a = a);
end;

function lua_getstack(const L: Plua_State; const level: Integer; const ar: Plua_Debug): Integer;
begin

end;

function lua_getinfo(const L: Plua_State; const what: PChar; const ar: Plua_Debug): Integer;
begin

end;

function lua_getlocal(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;
begin

end;

function lua_setlocal(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;
begin

end;

function lua_getupvalue(const L: Plua_State; const funcindex, n: Integer): PChar;
begin

end;

function lua_setupvalue(const L: Plua_State; const funcindex, n: Integer): PChar;
begin

end;

function lua_upvalueid(const L: Plua_State; const fidx, n: Integer): Pointer;
begin

end;

procedure lua_upvaluejoin(const L: Plua_State; const fidx1, n1, fidx2, n2: Integer);
begin

end;

procedure lua_sethook(const L: Plua_State; const func: lua_Hook; const mask, count: Integer);
begin

end;

function lua_gethook(const L: Plua_State): lua_Hook;
begin

end;

function lua_gethookmask(const L: Plua_State): Integer;
begin

end;

function lua_gethookcount(const L: Plua_State): Integer;
begin

end;

(*
** Copyright (C) 2026  Ivan Markov (TangorCraft)
**
** Permission is hereby granted, free of charge, to any person obtaining
** a copy of this software and associated documentation files (the “Software”),
** to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense,
** and/or sell copies of the Software, and to permit persons to whom
** the Software is furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included
** in all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
** THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)
end.

