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
function lua_checkstack(const L: Plua_State; const n: Integer): Boolean;

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

function lua_tonumberx(const L: Plua_State; const idx: Integer; const pisnum: Plu_int): lua_Number;
function lua_tointegerx(const L: Plua_State; const idx: Integer; const pisnum: Plu_int): lua_Integer;
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
procedure lua_pushcclosure(const L: Plua_State; const fn: lua_CFunction; n: Integer);
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
function lua_newuserdata(const L: Plua_State; const size: SizeUInt): Pointer;
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
function lua_load(const L: Plua_State; const reader: lua_Reader; const data: Pointer;
  chunkname: PChar; const  mode: PChar): Integer;

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

// lua_yield -> lua_yield0 because there is LUA_YIELD constant (pascal is case insensitive)
function lua_yield0(const L: Plua_State; const n: Integer): Integer;

(*
** garbage-collection function
*)
// TODO
//LUA_API int (lua_gc) (lua_State *L, int what, int data);
function lua_gc(const L: Plua_State; const what: Integer; data: Integer): Integer;

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
function luai_numidiv(const L: Plua_State; const a, b: lua_Number): lua_Number;

(* float division *)
// TODO
//#if !defined(luai_numdiv)
//#define luai_numdiv(L,a,b)      ((a)/(b))
//#endif
function luai_numdiv(const L: Plua_State; const a, b: lua_Number): lua_Number;

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
procedure luai_nummod(const L: Plua_State; const a, b: lua_Number; var m: lua_Number);

(* exponentiation *)
//#if !defined(luai_numpow)
//#define luai_numpow(L,a,b)      ((void)L, l_mathop(pow)(a,b))
//#endif
function luai_numpow(const L: Plua_State; const a, b: lua_Number): lua_Number;

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
function luai_numadd(const L: Plua_State; const a, b: lua_Number): lua_Number;
function luai_numsub(const L: Plua_State; const a, b: lua_Number): lua_Number;
function luai_nummul(const L: Plua_State; const a, b: lua_Number): lua_Number;
function luai_numunm(const L: Plua_State; const a: lua_Number): lua_Number;
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
function lua_getstack(const L: Plua_State; level: Integer; const ar: Plua_Debug): Integer;
function lua_getinfo(const L: Plua_State; what: PChar; const ar: Plua_Debug): Boolean; inline;
function lua_getlocal(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar; inline;
function lua_setlocal(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar; inline;
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
procedure lua_sethook(const L: Plua_State; func: lua_Hook; mask, count: Integer);
function lua_gethook(const L: Plua_State): lua_Hook;
function lua_gethookmask(const L: Plua_State): Integer;
function lua_gethookcount(const L: Plua_State): Integer;

implementation

uses
  Math,
  lapi, ldebug, ldo, lfunc, lgc, lmem, lobject, lstate, lstring, ltable, ltm, lundump, lvm, lzio;

(* value at a non-valid index *)
//#define NONVALIDVALUE         cast(TValue *, luaO_nilobject)
const
  NONVALIDVALUE: PTValue = @NILCONSTANT;

(* corresponding test *)
//#define isvalid(o)    ((o) != luaO_nilobject)
function isvalid(const o: PTValue): Boolean;
begin
  Result := (o <> luaO_nilobject);
end;

(* test for pseudo index *)
//#define ispseudo(i)           ((i) <= LUA_REGISTRYINDEX)
function ispseudo(const i: Integer): Boolean;
begin
  Result := (i <= LUA_REGISTRYINDEX);
end;

(* test for upvalue *)
//#define isupvalue(i)          ((i) < LUA_REGISTRYINDEX)
function isupvalue(const i: Integer): Boolean;
begin
  Result := (i < LUA_REGISTRYINDEX);
end;

(* test for valid but not pseudo index *)
//#define isstackindex(i, o)    (isvalid(o) && !ispseudo(i))
function isstackindex(const i: Integer; const o: PTValue): Boolean;
begin
  Result := (isvalid(o) and not ispseudo(i));
end;

//#define api_checkvalidindex(l,o)  api_check(l, isvalid(o), "invalid index")
procedure api_checkvalidindex(const L: Plua_State; const o: PTValue);
begin
  api_check(L, isvalid(o), 'invalid index');
end;

//#define api_checkstackindex(l, i, o)  \
//      api_check(l, isstackindex(i, o), "index not in the stack")
procedure api_checkstackindex(const L: Plua_State; const i: Integer; const o: PTValue);
begin
  api_check(L, isstackindex(i, o), 'index not in the stack');
end;

//static TValue *index2addr (lua_State *L, int idx)
function index2addr(const L: Plua_State; idx: Integer): PTValue;
var
  ci: PCallInfo;
  o: PTValue;
  func: PCClosure;
begin
  ci := L^.ci;
  if (idx > 0) then
  begin
    o := ci^.func + idx;
    api_check(L, idx <= (ci^.top - (ci^.func + 1)), 'unacceptable index');
    if (o >= L^.top) then
      Result := NONVALIDVALUE
    else
      Result := o;
  end
  else if (not ispseudo(idx)) then  //* negative index */
  begin
    api_check(L, (idx <> 0) and (-idx <= (L^.top - (ci^.func + 1))), 'invalid index');
    Exit(L^.top + idx);
  end
  else if (idx = LUA_REGISTRYINDEX) then
    exit(@(L^.l_G^.l_registry))
  else //* upvalues */
  begin
    idx := LUA_REGISTRYINDEX - idx;
    api_check(L, (idx <= MAXUPVAL + 1), 'upvalue index too large');
    if (ttislcf(ci^.func)) then //* light C function? */
      Exit(NONVALIDVALUE)  //* it has no upvalues */
    else
    begin
      func := clCvalue(ci^.func);
      if (idx <= func^.header.nupvalues) then
        Result := @(CClosure_upvalue(func)[idx-1])
      else
        Result := NONVALIDVALUE;
    end;
  end;
end;


(*
** to be called by 'lua_checkstack' in protected mode, to grow stack
** capturing memory errors
*)
//static void growstack (lua_State *L, void *ud)
procedure growstack(const L: Plua_State; const ud: Pointer);
var
  size: Integer;
begin
  size := PInteger(ud)^;
  luaD_growstack(L, size);
end;

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
  lua_lock(L);
  Result := G(L)^.panic;
  G(L)^.panic := panicf;
  lua_unlock(L);
end;

function lua_version(const L: Plua_State): Plua_Number;
const
  version: lua_Number = LUA_VERSION_NUM;
begin
  if (L = Nil) then
    Result := @version
  else
    Result := G(L)^.version;
end;

(*
** convert an acceptable stack index into an absolute index
*)
function lua_absindex(const L: Plua_State; const idx: Integer): Integer;
begin
  if (idx > 0) or ispseudo(idx) then
    Result := idx
  else
    Result := cast_int(L^.top - L^.ci^.func) + idx;
end;

function lua_gettop(const L: Plua_State): Integer;
begin
  Result := cast_int(L^.top - (L^.ci^.func + 1));
end;

procedure lua_settop(const L: Plua_State; const idx: Integer);
var
  func: StkId;
begin
  func := L^.ci^.func;
  lua_lock(L);
  if (idx >= 0) then
  begin
    api_check(L, idx <= (L^.stack_last - (func + 1)), 'new top too large');
    while L^.top < ((func + 1) + idx) do
    begin
      setnilvalue(L^.top);
      inc(L^.top);
    end;
    L^.top := (func + 1) + idx;
  end
  else
  begin
    api_check(L, -(idx+1) <= (L^.top - (func + 1)), 'invalid new top');
    L^.top := L^.top + (idx+1);  //* 'subtract' index (index is negative) */
  end;
  lua_unlock(L);
end;

procedure lua_pushvalue(const L: Plua_State; const idx: Integer);
begin
  lua_lock(L);
  setobj2s(L, L^.top, index2addr(L, idx));
  api_incr_top(L);
  lua_unlock(L);
end;

(*
** Reverse the stack segment from 'from' to 'to'
** (auxiliary to 'lua_rotate')
*)
//static void reverse (lua_State *L, StkId from, StkId )
procedure reverse(const L: Plua_State; from, to_: StkId);
var
  temp: TValue;
begin
  while from < to_ do
  begin
    setobj(L, @temp, from);
    setobjs2s(L, from, to_);
    setobj2s(L, to_, @temp);
    inc(from);
    dec(to_);
  end;
end;


(*
** Let x = AB, where A is a prefix of length 'n'. Then,
** rotate x n == BA. But BA == (A^r . B^r)^r.
*)
procedure lua_rotate(const L: Plua_State; const idx, n: Integer);
var
  p, t, m: StkId;
begin
  lua_lock(L);
  t := L^.top - 1;  //* end of stack segment being rotated */
  p := index2addr(L, idx);  //* start of segment */
  api_checkstackindex(L, idx, p);
  if n >= 0 then
  begin
    api_check(L, n <= (t - p + 1), 'invalid "n"');
    m := t - n; //* end of prefix */
  end
  else
  begin
    api_check(L, -n <= (t - p + 1), 'invalid "n"');
    m := p - n - 1; //* end of prefix */
  end;
  reverse(L, p, m);  //* reverse the prefix with length 'n' */
  reverse(L, m + 1, t);  //* reverse the suffix */
  reverse(L, p, t); //* reverse the entire segment */
  lua_unlock(L);
end;

procedure lua_copy(const L: Plua_State; const fromidx, toidx: Integer);
var
  fr, to_: PTValue;
begin
  lua_lock(L);
  fr := index2addr(L, fromidx);
  to_:= index2addr(L, toidx);
  api_checkvalidindex(L, to_);
  setobj(L, to_, fr);
  if (isupvalue(toidx)) then //* function upvalue? */
    luaC_barrier(L, obj2gco(clCvalue(L^.ci^.func)), fr);
  (* LUA_REGISTRYINDEX does not need gc barrier
     (collector revisits it before finishing collection) *)
  lua_unlock(L);
end;

function lua_checkstack(const L: Plua_State; const n: Integer): Boolean;
var
  ci: PCallInfo;
  inuse: Integer;
begin
  ci := L^.ci;
  lua_lock(L);
  api_check(L, (n >= 0), 'negative "n"');
  if (L^.stack_last - L^.top) > n then //* stack large enough? */
    Result := True  //* yes; check is OK */
  else //* no; need to grow stack */
  begin
    inuse := cast_int(L^.top - L^.stack) + EXTRA_STACK;
    if inuse > (LUAI_MAXSTACK - n) then //* can grow without overflow? */
      Result := False  //* no */
    else  //* try to grow stack */
      Result := (luaD_rawrunprotected(L, @growstack, @n) = LUA_OK);
  end;
  if Result and (ci^.top < (L^.top + n)) then
    ci^.top := L^.top + n;  //* adjust frame top */
  lua_unlock(L);
end;

procedure lua_xmove(const from, to_: Plua_State; const n: Integer);
var
  i: Integer;
begin
  if (from = to_) then Exit;
  lua_lock(to_);
  api_checknelems(from, n);
  api_check(from, G(from) = G(to_), 'moving among independent states');
  api_check(from, (to_^.ci^.top - to_^.top) >= n, 'stack overflow');
  from^.top := from^.top - n;
  for i := 0 to n-1 do
  begin
    setobj2s(to_, to_^.top, from^.top + i);
    inc(to_^.top);  //* stack already checked by previous 'api_check' */
  end;
  lua_unlock(to_);
end;

function lua_isnumber(const L: Plua_State; const idx: Integer): lu_int;
var
  n: lua_Number;
  o: PTValue;
begin
  o := index2addr(L, idx);
  Result := tonumber(o, @n);
end;

function lua_isstring(const L: Plua_State; const idx: Integer): lu_int;
var
  o: PTValue;
begin
  o := index2addr(L, idx);
  Result := (ttisstring(o) or cvt2str(o));
end;

function lua_iscfunction(const L: Plua_State; const idx: Integer): lu_int;
var
  o: StkId;
begin
  o := index2addr(L, idx);
  Result := (ttislcf(o) or ttisCclosure(o));
end;

function lua_isinteger(const L: Plua_State; const idx: Integer): lu_int;
var
  o: StkId;
begin
  o := index2addr(L, idx);
  Result := ttisinteger(o);
end;

function lua_isuserdata(const L: Plua_State; const idx: Integer): lu_int;
var
  o: PTValue;
begin
  o := index2addr(L, idx);
  Result := (ttisfulluserdata(o) or ttislightuserdata(o));
end;

function lua_type(const L: Plua_State; const idx: Integer): lu_int;
var
  o: StkId;
begin
  o := index2addr(L, idx);
  if isvalid(o) then
    Result := ttnov(o)
  else
    Result := LUA_TNONE;
end;

function lua_typename(const L: Plua_State; const tp: Integer): PChar;
begin
  //UNUSED(L);
  api_check(L, (LUA_TNONE <= tp) and (tp < LUA_NUMTAGS), 'invalid tag');
  Result := ttypename(tp);
end;

function lua_tonumberx(const L: Plua_State; const idx: Integer;
  const pisnum: Plu_int): lua_Number;
var
  o: PTValue;
  isnum: Integer;
begin
  o := index2addr(L, idx);
  isnum := tonumber(o, @Result);
  if (isnum = 0) then
    Result := 0;  //* call to 'tonumber' may change 'n' even if it fails */
  if (pisnum <> nil) then
    pisnum^ := isnum;
end;

function lua_tointegerx(const L: Plua_State; const idx: Integer;
  const pisnum: Plu_int): lua_Integer;
var
  o: PTValue;
  isnum: Integer;
begin
  o := index2addr(L, idx);
  isnum := tointeger(o, @Result);
  if (isnum = 0) then
    Result := 0;  //* call to 'tointeger' may change 'n' even if it fails */
  if (pisnum <> nil) then
    pisnum^ := isnum;
end;

function lua_toboolean(const L: Plua_State; const idx: Integer): lu_int;
var
  o: PTValue;
begin
  o := index2addr(L, idx);
  Result := not l_isfalse(o);
end;

function lua_tolstring(const L: Plua_State; const idx: Integer; const len: PSizeUInt): PChar;
var
  o: StkId;
begin
  o := index2addr(L, idx);
  if (not ttisstring(o)) then begin
    if (not cvt2str(o)) then
    begin  //* not convertible? */
      if (len <> nil) then
        len^ := 0;
      Exit(Nil);
    end;
    lua_lock(L);  //* 'luaO_tostring' may create a new string */
    luaO_tostring(L, o);
    luaC_checkGC(L);
    o := index2addr(L, idx);  //* previous call may reallocate the stack */
    lua_unlock(L);
  end;
  if (len <> Nil) then
    len^ := vslen(o);
  Result := svalue(o);
end;

function lua_rawlen(const L: Plua_State; const idx: Integer): SizeUInt;
var
  o: StkId;
begin
  o := index2addr(L, idx);
  case (ttype(o)) of
    LUA_TSHRSTR: Result := tsvalue(o)^.shrlen;
    LUA_TLNGSTR: Result := tsvalue(o)^.u_lnglen;
    LUA_TUSERDATA: Result := uvalue(o)^.len;
    LUA_TTABLE: Result := luaH_getn(hvalue(o));
    else Result := 0;
  end;
end;

function lua_tocfunction(const L: Plua_State; const idx: Integer): lua_CFunction;
var
  o: StkId;
begin
  o := index2addr(L, idx);
  if (ttislcf(o)) then
    Result := fvalue(o)
  else if (ttisCclosure(o)) then
    Result := clCvalue(o)^.f
  else
    Result := Nil;  //* not a C function */
end;

function lua_touserdata(const L: Plua_State; const idx: Integer): Pointer;
var
  o: StkId;
begin
  o := index2addr(L, idx);
  case (ttnov(o)) of
    LUA_TUSERDATA: Result := getudatamem(uvalue(o));
    LUA_TLIGHTUSERDATA: Result := pvalue(o);
    else Result := Nil;
  end;
end;

function lua_tothread(const L: Plua_State; const idx: Integer): Plua_State;
var
  o: StkId;
begin
  o := index2addr(L, idx);
  if (not ttisthread(o)) then
    Result := Nil
  else
    Result := thvalue(o);
end;

function lua_topointer(const L: Plua_State; const idx: Integer): Pointer;
var
  o: StkId;
begin
  o := index2addr(L, idx);
  case (ttype(o)) of
    LUA_TTABLE: Result := hvalue(o);
    LUA_TLCL: Result := clLvalue(o);
    LUA_TCCL: Result := clCvalue(o);
    LUA_TLCF: Result := Pointer( fvalue(o) );
    LUA_TTHREAD: Result := thvalue(o);
    LUA_TUSERDATA: Result := getudatamem(uvalue(o));
    LUA_TLIGHTUSERDATA: Result := pvalue(o);
    else Result := Nil;
  end;
end;

procedure lua_arith(const L: Plua_State; const op: Integer);
begin
  lua_lock(L);
  if (op <> LUA_OPUNM) and (op <> LUA_OPBNOT) then
    api_checknelems(L, 2)  //* all other operations expect two operands */
  else
  begin //* for unary operations, add fake 2nd operand */
    api_checknelems(L, 1);
    setobjs2s(L, L^.top, L^.top - 1);
    api_incr_top(L);
  end;
  //* first operand at top - 2, second at top - 1; result go to top - 2 */
  luaO_arith(L, op, L^.top - 2, L^.top - 1, L^.top - 2);
  dec(L^.top);  //* remove second operand */
  lua_unlock(L);
end;

function lua_rawequal(const L: Plua_State; const idx1, idx2: Integer): lu_int;
var
  o1, o2: StkId;
begin
  o1 := index2addr(L, idx1);
  o2 := index2addr(L, idx2);
  if (isvalid(o1) and isvalid(o2)) then
    Result := luaV_rawequalobj(o1, o2)
  else
    Result := 0;
end;

function lua_compare(const L: Plua_State; const idx1, idx2, op: Integer): lu_int;
var
  o1, o2: StkId;
begin
  Result := 0;
  lua_lock(L);  //* may call tag method */
  o1 := index2addr(L, idx1);
  o2 := index2addr(L, idx2);
  if (isvalid(o1) and isvalid(o2)) then
  case (op) of
    LUA_OPEQ: Result := luaV_equalobj(L, o1, o2);
    LUA_OPLT: Result := luaV_lessthan(L, o1, o2);
    LUA_OPLE: Result := luaV_lessequal(L, o1, o2);
    else api_check(L, false, 'invalid option');
  end;
  lua_unlock(L);
end;

procedure lua_pushnil(const L: Plua_State);
begin
  lua_lock(L);
  setnilvalue(L^.top);
  api_incr_top(L);
  lua_unlock(L);
end;

procedure lua_pushnumber(const L: Plua_State; const n: lua_Number);
begin
  lua_lock(L);
  setfltvalue(L^.top, n);
  api_incr_top(L);
  lua_unlock(L);
end;

procedure lua_pushinteger(const L: Plua_State; const n: lua_Integer);
begin
  lua_lock(L);
  setivalue(L^.top, n);
  api_incr_top(L);
  lua_unlock(L);
end;

(*
** Pushes on the stack a string with given length. Avoid using 's' when
** 'len' == 0 (as 's' can be NULL in that case), due to later use of
** 'memcmp' and 'memcpy'.
*)
function lua_pushlstring(const L: Plua_State; const s: PChar; const len: SizeUInt): PChar;
var
  ts: PTString;
begin
  lua_lock(L);
  if (len = 0) then
    ts := luaS_new(L, '')
  else
    ts := luaS_newlstr(L, s, len);
  setsvalue2s(L, L^.top, ts);
  api_incr_top(L);
  luaC_checkGC(L);
  lua_unlock(L);
  Result := getstr(ts);
end;

function lua_pushstring(const L: Plua_State; const s: PChar): PChar;
var
  ts: PTString;
begin
  lua_lock(L);
  if (s = Nil) then
  begin
    setnilvalue(L^.top);
    Result := s;
  end
  else
  begin
    ts := luaS_new(L, s);
    setsvalue2s(L, L^.top, ts);
    Result := getstr(ts);  //* internal copy's address */
  end;
  api_incr_top(L);
  luaC_checkGC(L);
  lua_unlock(L);
end;

function lua_pushvfstring(const L: Plua_State; const fmt: PChar;
  const argp: array of const): PChar;
begin
  lua_lock(L);
  Result := luaO_pushvfstring(L, fmt, argp);
  luaC_checkGC(L);
  lua_unlock(L);
end;

function lua_pushfstring(const L: Plua_State; const fmt: PChar;
  const args: array of const): PChar;
begin
  lua_lock(L);
  Result := luaO_pushvfstring(L, fmt, args);
  luaC_checkGC(L);
  lua_unlock(L);
end;

procedure lua_pushcclosure(const L: Plua_State; const fn: lua_CFunction; n: Integer);
var
  cl: PCClosure;
begin
  lua_lock(L);
  if (n = 0) then
  begin
    setfvalue(L^.top, fn);
    api_incr_top(L);
  end
  else
  begin
    api_checknelems(L, n);
    api_check(L, n <= MAXUPVAL, 'upvalue index too large');
    cl := luaF_newCclosure(L, n);
    cl^.f := fn;
    L^.top := L^.top - n;
    while (n<>0) do
    begin
      dec(n);
      setobj2n(L, CClosure_upvalueN(cl,n), L^.top + n);
      //* does not need barrier because closure is white */
    end;
    setclCvalue(L, L^.top, cl);
    api_incr_top(L);
    luaC_checkGC(L);
  end;
  lua_unlock(L);
end;

procedure lua_pushboolean(const L: Plua_State; const b: lu_int);
begin
  lua_lock(L);
  setbvalue(L^.top, lu_int(b <> 0));  //* ensure that true is 1 */
  api_incr_top(L);
  lua_unlock(L);
end;

procedure lua_pushlightuserdata(const L: Plua_State; const p: Pointer);
begin
  lua_lock(L);
  setpvalue(L^.top, p);
  api_incr_top(L);
  lua_unlock(L);
end;

function lua_pushthread(const L: Plua_State): Integer;
begin
  lua_lock(L);
  setthvalue(L, L^.top, L);
  api_incr_top(L);
  lua_unlock(L);
  Result := lu_int(G(L)^.mainthread = L);
end;

//static int auxgetstr (lua_State *L, const TValue *t, const char *k)
function auxgetstr(const L: Plua_State; const t: PTValue; const k: PChar): Integer;
var
  slot: PTValue;
  str: PTString;
begin
  str := luaS_new(L, k);
  if luaV_fastget_str(L, t, str, slot) then
  begin
    setobj2s(L, L^.top, slot);
    api_incr_top(L);
  end
  else
  begin
    setsvalue2s(L, L^.top, str);
    api_incr_top(L);
    luaV_finishget(L, t, L^.top - 1, L^.top - 1, slot);
  end;
  lua_unlock(L); //* lock done by caller */
  Result := ttnov(L^.top - 1);
end;

function lua_getglobal(const L: Plua_State; const name: PChar): Integer;
var
  reg: PTable;
begin
  reg := hvalue(@(G(L)^.l_registry));
  lua_lock(L);
  Result := auxgetstr(L, luaH_getint(reg, LUA_RIDX_GLOBALS), name);
end;

function lua_gettable(const L: Plua_State; const idx: Integer): Integer;
var
  t: StkId;
begin
  lua_lock(L);
  t := index2addr(L, idx);
  luaV_gettable(L, t, L^.top - 1, L^.top - 1);
  lua_unlock(L);
  Result := ttnov(L^.top - 1);
end;

function lua_getfield(const L: Plua_State; const idx: Integer; const k: PChar): Integer;
begin
  lua_lock(L);
  Result := auxgetstr(L, index2addr(L, idx), k);
end;

function lua_geti(const L: Plua_State; const idx: Integer; const n: lua_Integer): Integer;
var
  t: StkId;
  slot: PTValue;
begin
  lua_lock(L);
  t := index2addr(L, idx);
  if (luaV_fastget_int(L, t, n, slot)) then
  begin
    setobj2s(L, L^.top, slot);
    api_incr_top(L);
  end
  else
  begin
    setivalue(L^.top, n);
    api_incr_top(L);
    luaV_finishget(L, t, L^.top - 1, L^.top - 1, slot);
  end;
  lua_unlock(L);
  Result := ttnov(L^.top - 1);
end;

function lua_rawget(const L: Plua_State; const idx: Integer): Integer;
var
  t: StkId;
begin
  lua_lock(L);
  t := index2addr(L, idx);
  api_check(L, ttistable(t), 'table expected');
  setobj2s(L, L^.top - 1, luaH_get(hvalue(t), L^.top - 1));
  lua_unlock(L);
  Result := ttnov(L^.top - 1);
end;

function lua_rawgeti(const L: Plua_State; const idx: Integer; const n: lua_Integer): Integer;
var
  t: StkId;
begin
  lua_lock(L);
  t := index2addr(L, idx);
  api_check(L, ttistable(t), 'table expected');
  setobj2s(L, L^.top, luaH_getint(hvalue(t), n));
  api_incr_top(L);
  lua_unlock(L);
  Result := ttnov(L^.top - 1);
end;

function lua_rawgetp(const L: Plua_State; const idx: Integer; const p: Pointer): Integer;
var
  t: StkId;
  k: TValue;
begin
  lua_lock(L);
  t := index2addr(L, idx);
  api_check(L, ttistable(t), 'table expected');
  setpvalue(@k, p);
  setobj2s(L, L^.top, luaH_get(hvalue(t), @k));
  api_incr_top(L);
  lua_unlock(L);
  Result := ttnov(L^.top - 1);
end;

procedure lua_createtable(const L: Plua_State; const narr, nrec: Integer);
var
  t: PTable;
begin
  lua_lock(L);
  t := luaH_new(L);
  sethvalue(L, L^.top, t);
  api_incr_top(L);
  if (narr > 0) or (nrec > 0) then
    luaH_resize(L, t, narr, nrec);
  luaC_checkGC(L);
  lua_unlock(L);
end;

function lua_newuserdata(const L: Plua_State; const size: SizeUInt): Pointer;
var
  u: PUdata;
begin
  lua_lock(L);
  u := luaS_newudata(L, size);
  setuvalue(L, L^.top, u);
  api_incr_top(L);
  luaC_checkGC(L);
  lua_unlock(L);
  Result := getudatamem(u);
end;

function lua_getmetatable(const L: Plua_State; const objindex: Integer): Integer;
var
  obj: PTValue;
  mt: PTable;
begin
  Result := 0;
  lua_lock(L);
  obj := index2addr(L, objindex);
  case (ttnov(obj)) of
    LUA_TTABLE:
      mt := hvalue(obj)^.metatable;
    LUA_TUSERDATA:
      mt := uvalue(obj)^.metatable;
    else
      mt := G(L)^.mt[ttnov(obj)];
  end;
  if (mt <> Nil) then
  begin
    sethvalue(L, L^.top, mt);
    api_incr_top(L);
    Result := 1;
  end;
  lua_unlock(L);
end;

function lua_getuservalue(const L: Plua_State; const idx: Integer): Integer;
var
  o: StkId;
begin
  lua_lock(L);
  o := index2addr(L, idx);
  api_check(L, ttisfulluserdata(o), 'full userdata expected');
  getuservalue(L, uvalue(o), L^.top);
  api_incr_top(L);
  lua_unlock(L);
  Result := ttnov(L^.top - 1);
end;

(*
** t[k] = value at the top of the stack (where 'k' is a string)
*)
//static void auxsetstr (lua_State *L, const TValue *t, const char *k)
procedure auxsetstr(const L: Plua_State; const t: PTValue; const k: PChar);
var
  slot: PTValue;
  str: PTString;
begin
  str := luaS_new(L, k);
  api_checknelems(L, 1);
  if (luaV_fastset_str(L, t, str, slot, L^.top - 1)) then
    dec(L^.top)  //* pop value */
  else
  begin
    setsvalue2s(L, L^.top, str);  //* push 'str' (to make it a TValue) */
    api_incr_top(L);
    luaV_finishset(L, t, L^.top - 1, L^.top - 2, slot);
    L^.top := L^.top - 2;  //* pop value and key */
  end;
  lua_unlock(L); //* lock done by caller */
end;

procedure lua_setglobal(const L: Plua_State; const name: PChar);
var
  reg: PTable;
begin
  reg := hvalue(@(G(L)^.l_registry));
  lua_lock(L);  //* unlock done in 'auxsetstr' */
  auxsetstr(L, luaH_getint(reg, LUA_RIDX_GLOBALS), name);
end;

procedure lua_settable(const L: Plua_State; const idx: Integer);
var
  t: StkId;
begin
  lua_lock(L);
  api_checknelems(L, 2);
  t := index2addr(L, idx);
  luaV_settable(L, t, L^.top - 2, L^.top - 1);
  L^.top := L^.top - 2;  //* pop index and value */
  lua_unlock(L);
end;

procedure lua_setfield(const L: Plua_State; const idx: Integer; const k: PChar);
begin
  lua_lock(L);  //* unlock done in 'auxsetstr' */
  auxsetstr(L, index2addr(L, idx), k);
end;

procedure lua_seti(const L: Plua_State; const idx: Integer; const n: lua_Integer);
var
  t: StkId;
  slot: PTValue;
begin
  lua_lock(L);
  api_checknelems(L, 1);
  t := index2addr(L, idx);
  if (luaV_fastset_int(L, t, n, slot, L^.top - 1)) then
    dec(L^.top)  //* pop value */
  else
  begin
    setivalue(L^.top, n);
    api_incr_top(L);
    luaV_finishset(L, t, L^.top - 1, L^.top - 2, slot);
    L^.top := L^.top - 2;  //* pop value and key */
  end;
  lua_unlock(L);
end;

procedure lua_rawset(const L: Plua_State; const idx: Integer);
var
  o: StkId;
  slot: PTValue;
begin
  lua_lock(L);
  api_checknelems(L, 2);
  o := index2addr(L, idx);
  api_check(L, ttistable(o), 'table expected');
  slot := luaH_set(L, hvalue(o), L^.top - 2);
  setobj2t(L, slot, L^.top - 1);
  invalidateTMcache(hvalue(o));
  luaC_barrierback(L, hvalue(o), L^.top-1);
  L^.top := L^.top - 2;
  lua_unlock(L);
end;

procedure lua_rawseti(const L: Plua_State; const idx: Integer; const n: lua_Integer);
var
  o: StkId;
begin
  lua_lock(L);
  api_checknelems(L, 1);
  o := index2addr(L, idx);
  api_check(L, ttistable(o), 'table expected');
  luaH_setint(L, hvalue(o), n, L^.top - 1);
  luaC_barrierback(L, hvalue(o), L^.top-1);
  dec(L^.top);
  lua_unlock(L);
end;

procedure lua_rawsetp(const L: Plua_State; const idx: Integer; const p: Pointer);
var
  o: StkId;
  slot: PTValue;
  k: TValue;
begin
  lua_lock(L);
  api_checknelems(L, 1);
  o := index2addr(L, idx);
  api_check(L, ttistable(o), 'table expected');
  setpvalue(@k, p);
  slot := luaH_set(L, hvalue(o), @k);
  setobj2t(L, slot, L^.top - 1);
  luaC_barrierback(L, hvalue(o), L^.top - 1);
  dec(L^.top);
  lua_unlock(L);
end;

function lua_setmetatable(const L: Plua_State; const objindex: Integer): Integer;
var
  obj: PTValue;
  mt: PTable;
begin
  lua_lock(L);
  api_checknelems(L, 1);
  obj := index2addr(L, objindex);
  if (ttisnil(L^.top - 1)) then
    mt := Nil
  else
  begin
    api_check(L, ttistable(L^.top - 1), 'table expected');
    mt := hvalue(L^.top - 1);
  end;
  case (ttnov(obj)) of
    LUA_TTABLE: begin
      hvalue(obj)^.metatable := mt;
      if (mt <> nil) then
      begin
        luaC_objbarrier(L, gcvalue(obj), obj2gco(mt));
        luaC_checkfinalizer(L, gcvalue(obj), mt);
      end;
    end;
    LUA_TUSERDATA: begin
      uvalue(obj)^.metatable := mt;
      if (mt <> nil) then
      begin
        luaC_objbarrier(L, obj2gco(uvalue(obj)), obj2gco(mt));
        luaC_checkfinalizer(L, gcvalue(obj), mt);
      end;
    end;
    else begin
      G(L)^.mt[ttnov(obj)] := mt;
    end;
  end;
  dec(L^.top);
  lua_unlock(L);
  Result := 1;
end;

procedure lua_setuservalue(const L: Plua_State; const idx: Integer);
var
  o: StkId;
begin
  lua_lock(L);
  api_checknelems(L, 1);
  o := index2addr(L, idx);
  api_check(L, ttisfulluserdata(o), 'full userdata expected');
  setuservalue(L, uvalue(o), L^.top - 1);
  luaC_barrier(L, gcvalue(o), L^.top - 1);
  dec(L^.top);
  lua_unlock(L);
end;

//#define checkresults(L,na,nr) \
//     api_check(L, (nr) == LUA_MULTRET || (L->ci->top - L->top >= (nr) - (na)), \
//	"results from function overflow current stack size")
procedure checkresults(const L: Plua_State; const na, nr: Integer);
begin
  api_check(L, (nr = LUA_MULTRET) or ((L^.ci^.top - L^.top) >= (nr - na)),
            'results from function overflow current stack size');
end;

procedure lua_callk(const L: Plua_State; const nargs, nresults: Integer;
  const ctx: lua_KContext; const k: lua_KFunction);
var
  func: StkId;
begin
  lua_lock(L);
  api_check(L, (k = Nil) or (not isLua(L^.ci)),
    'cannot use continuations inside hooks');
  api_checknelems(L, nargs+1);
  api_check(L, L^.status = LUA_OK, 'cannot do calls on non-normal thread');
  checkresults(L, nargs, nresults);
  func := L^.top - (nargs+1);
  if (k <> Nil) and (L^.nny = 0) then
  begin  //* need to prepare continuation? */
    L^.ci^.u.c_k := k;  //* save continuation */
    L^.ci^.u.c_ctx := ctx;  //* save context */
    luaD_call(L, func, nresults);  //* do the call */
  end
  else  //* no continuation or no yieldable */
    luaD_callnoyield(L, func, nresults);  //* just do the call */
  adjustresults(L, nresults);
  lua_unlock(L);
end;

//#define lua_call(L,n,r)         lua_callk(L, (n), (r), 0, NULL)
procedure lua_call(const L: Plua_State; const n, r: Integer);
begin
  lua_callk(L, n, r, 0, Nil);
end;

(*
** Execute a protected call.
*)
type
  CallS = record  //* data to 'f_call' */
    func: StkId;
    nresults: Integer;
  end;
  PCallS = ^CallS;


//static void f_call (lua_State *L, void *ud)
procedure f_call(const L: Plua_State; const ud: Pointer);
var
  c: PCallS;
begin
  c := ud;
  luaD_callnoyield(L, c^.func, c^.nresults);
end;

function lua_pcallk(const L: Plua_State; const nargs, nresults, errfunc: Integer;
  const ctx: lua_KContext; const k: lua_KFunction): Integer;
var
  c: CallS;
  func: PtrInt;
  o: StkId;
  ci: PCallInfo;
begin
  lua_lock(L);
  api_check(L, (k = Nil) or (not isLua(L^.ci)),
    'cannot use continuations inside hooks');
  api_checknelems(L, nargs+1);
  api_check(L, L^.status = LUA_OK, 'cannot do calls on non-normal thread');
  checkresults(L, nargs, nresults);
  if (errfunc = 0) then
    func := 0
  else
  begin
    o := index2addr(L, errfunc);
    api_checkstackindex(L, errfunc, o);
    func := savestack(L, o);
  end;
  c.func := L^.top - (nargs+1);  //* function to be called */
  if (k = Nil) or (L^.nny > 0) then
  begin  //* no continuation or no yieldable? */
    c.nresults := nresults;  //* do a 'conventional' protected call */
    Result := luaD_pcall(L, @f_call, @c, savestack(L, c.func), func);
  end
  else
  begin  //* prepare continuation (call is already protected by 'resume') */
    ci := L^.ci;
    ci^.u.c_k := k;  //* save continuation */
    ci^.u.c_ctx := ctx;  //* save context */
    //* save information for error recovery */
    ci^.extra := savestack(L, c.func);
    ci^.u.c_old_errfunc := L^.errfunc;
    L^.errfunc := func;
    setoah(ci^.callstatus, L^.allowhook);  //* save value of 'allowhook' */
    ci^.callstatus := ci^.callstatus or CIST_YPCALL;  //* function can do error recovery */
    luaD_call(L, c.func, nresults);  //* do the call */
    ci^.callstatus := ci^.callstatus and not CIST_YPCALL;
    L^.errfunc := ci^.u.c_old_errfunc;
    Result := LUA_OK;  //* if it is here, there were no errors */
  end;
  adjustresults(L, nresults);
  lua_unlock(L);
end;

//#define lua_pcall(L,n,r,f)      lua_pcallk(L, (n), (r), (f), 0, NULL)
function lua_pcall(const L: Plua_State; const n, r, f: Integer): Integer;
begin
  Result := lua_pcallk(L, n, r, f, 0, Nil);
end;

function lua_load(const L: Plua_State; const reader: lua_Reader; const data: Pointer;
  chunkname: PChar; const mode: PChar): Integer;
var
  z: Zio;
  f: PLClosure;
  reg: PTable;
  gt: PTValue;
begin
  lua_lock(L);
  if (chunkname = nil) then
    chunkname := '?';
  luaZ_init(L, z, reader, data);
  Result := luaD_protectedparser(L, z, chunkname, mode);
  if (Result = LUA_OK) then
  begin  //* no errors? */
    f := clLvalue(L^.top - 1);  //* get newly created function */
    if (f^.header.nupvalues >= 1) then
    begin  //* does it have an upvalue? */
      //* get global table from registry */
      reg := hvalue(@(G(L)^.l_registry));
      gt := luaH_getint(reg, LUA_RIDX_GLOBALS);
      //* set global table as 1st upvalue of 'f' (may be LUA_ENV) */
      setobj(L, f^.upvals_0^.v, gt);
      luaC_upvalbarrier(L, f^.upvals_0);
    end;
  end;
  lua_unlock(L);
end;

function lua_dump(const L: Plua_State; const writer: lua_Writer; const data: Pointer;
  const strip: Integer): Integer;
var
  o: PTValue;
begin
  lua_lock(L);
  api_checknelems(L, 1);
  o := L^.top - 1;
  if (isLfunction(o)) then
    Result := luaU_dump(L, getproto(o), writer, data, strip)
  else
    Result := 1;
  lua_unlock(L);
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
  Result := L^.status;
end;

function lua_isyieldable(const L: Plua_State): lu_int;
begin

end;

//#define lua_yield(L,n)          lua_yieldk(L, (n), 0, NULL)
function lua_yield0(const L: Plua_State; const n: Integer): Integer;
begin
  Result := lua_yieldk(L, n, 0, Nil);
end;

function lua_gc(const L: Plua_State; const what: Integer; data: Integer): Integer;
var
  g: Pglobal_State;
  debt: l_mem;
  oldrunning: lu_byte;
begin
  Result := 0;
  lua_lock(L);
  g := L^.l_G;
  case (what) of
    LUA_GCSTOP:
      g^.gcrunning := 0;
    LUA_GCRESTART:
    begin
      luaE_setdebt(g, 0);
      g^.gcrunning := 1;
    end;
    LUA_GCCOLLECT:
      luaC_fullgc(L, 0);
    LUA_GCCOUNT:
      //* GC values are expressed in Kbytes: #bytes/2^10 */
      Result := cast_int(gettotalbytes(g) shr 10);
    LUA_GCCOUNTB:
      Result := cast_int(gettotalbytes(g) and $03ff);
    LUA_GCSTEP:
    begin
      debt := 1;  //* =1 to signal that it did an actual step */
      oldrunning := g^.gcrunning;
      g^.gcrunning := 1;  //* allow GC to run */
      if (data = 0) then
      begin
        luaE_setdebt(g, -GCSTEPSIZE);  //* to do a "small" step */
        luaC_step(L);
      end
      else
      begin //* add 'data' to total debt */
        debt := l_mem(data) * 1024 + g^.GCdebt;
        luaE_setdebt(g, debt);
        luaC_checkGC(L);
      end;
      g^.gcrunning := oldrunning;  //* restore previous state */
      if (debt > 0) and (g^.gcstate = GCSpause) then //* end of cycle? */
        Result := 1;  //* signal it */
    end;
    LUA_GCSETPAUSE:
    begin
      Result := g^.gcpause;
      g^.gcpause := data;
    end;
    LUA_GCSETSTEPMUL:
    begin
      Result := g^.gcstepmul;
      if (data < 40) then data := 40;  //* avoid ridiculous low values (and 0) */
      g^.gcstepmul := data;
    end;
    LUA_GCISRUNNING:
      Result := g^.gcrunning;
    else
      Result := -1;  //* invalid option */
  end;
  lua_unlock(L);
end;

function lua_error(const L: Plua_State): Integer;
begin
  lua_lock(L);
  api_checknelems(L, 1);
  luaG_errormsg(L);
  //* code unreachable; will unlock when control actually leaves the kernel */
  Result := 0;  //* to avoid warnings */
end;

function lua_next(const L: Plua_State; const idx: Integer): Integer;
var
  t: StkId;
  more: Integer;
begin
  lua_lock(L);
  t := index2addr(L, idx);
  api_check(L, ttistable(t), 'table expected');
  more := luaH_next(L, hvalue(t), L^.top - 1);
  if (more <> 0) then
    api_incr_top(L)
  else  //* no more elements */
    L^.top := L^.top - 1;  //* remove key */
  lua_unlock(L);
  Result := more;
end;

procedure lua_concat(const L: Plua_State; const n: Integer);
begin
  lua_lock(L);
  api_checknelems(L, n);
  if (n >= 2) then
    luaV_concat(L, n)
  else if (n = 0) then
  begin  //* push empty string */
    setsvalue2s(L, L^.top, luaS_newlstr(L, '', 0));
    api_incr_top(L);
  end;
  //* else n == 1; nothing to do */
  luaC_checkGC(L);
  lua_unlock(L);
end;

procedure lua_len(const L: Plua_State; const idx: Integer);
var
  t: StkId;
begin
  lua_lock(L);
  t := index2addr(L, idx);
  luaV_objlen(L, L^.top, t);
  api_incr_top(L);
  lua_unlock(L);
end;

function lua_stringtonumber(const L: Plua_State; const s: PChar): SizeUInt;
begin
  Result := luaO_str2num(s, L^.top);
  if (Result <> 0) then
    api_incr_top(L);
end;

function lua_getallocf(const L: Plua_State; const ud: PPointer): lua_Alloc;
begin
  lua_lock(L);
  if (ud <> nil) then ud^ := G(L)^.ud;
  Result := G(L)^.frealloc;
  lua_unlock(L);
end;

procedure lua_setallocf(const L: Plua_State; const f: lua_Alloc; const ud: Pointer);
begin
  lua_lock(L);
  G(L)^.ud := ud;
  G(L)^.frealloc := f;
  lua_unlock(L);
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
function luai_numidiv(const L: Plua_State; const a, b: lua_Number): lua_Number;
begin
  Result := l_floor(a / b);
end;

//#define luai_numdiv(L,a,b)      ((a)/(b))
function luai_numdiv(const L: Plua_State; const a, b: lua_Number): lua_Number;
begin
  Result := a / b;
end;

//#define luai_nummod(L,a,b,m)  \
  { (m) = l_mathop(fmod)(a,b); if ((m)*(b) < 0) (m) += (b); }
procedure luai_nummod(const L: Plua_State; const a, b: lua_Number; var m: lua_Number);
begin
  m := FMod(a, b);
  if (m * b) < 0 then
    m := m + b;
end;

//#define luai_numpow(L,a,b)      ((void)L, l_mathop(pow)(a,b))
function luai_numpow(const L: Plua_State; const a, b: lua_Number): lua_Number;
begin
  Result := Power(a, b);
end;

function luai_numadd(const L: Plua_State; const a, b: lua_Number): lua_Number;
begin
  Result := a + b;
end;

function luai_numsub(const L: Plua_State; const a, b: lua_Number): lua_Number;
begin
  Result := a - b;
end;

function luai_nummul(const L: Plua_State; const a, b: lua_Number): lua_Number;
begin
  Result := a * b;
end;

function luai_numunm(const L: Plua_State; const a: lua_Number): lua_Number;
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

function lua_getstack(const L: Plua_State; level: Integer; const ar: Plua_Debug): Integer;
var
  status: Integer;
  ci: PCallInfo;
begin
  if (level < 0) then Exit(0);  //* invalid (negative) level */
  lua_lock(L);
  ci := L^.ci;
  while (level > 0) and (ci <> @L^.base_ci) do
  begin
    dec(level);
    ci := ci^.previous;
  end;
  if (level = 0) and (ci <> @L^.base_ci) then //* level found? */
  begin
    status := 1;
    ar^.i_ci := ci;
  end
  else status := 0;  //* no such level */
  lua_unlock(L);
  Result := status;
end;

function lua_getinfo(const L: Plua_State; what: PChar; const ar: Plua_Debug): Boolean;
begin
  Result := lua_getinfo_(L, what, ar);
end;

function lua_getlocal(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;
begin
  Result := lua_getlocal_(L, ar, n);
end;

function lua_setlocal(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;
begin
  Result := lua_setlocal_(L, ar, n);
end;

//static const char *aux_upvalue (StkId fi, int n, TValue **val,
//                                CClosure **owner, UpVal **uv)
function aux_upvalue(const fi: StkId; const n: Integer; out val: PTValue;
  const owner: PPCClosure; const uv: PPUpVal): PChar;
var
  fc: PCClosure;
  fl: PLClosure;
  name: PTString;
  p: PProto;
begin
  case (ttype(fi)) of
    LUA_TCCL: begin  //* C closure */
      fc := clCvalue(fi);
      if not((1 <= n) and (n <= fc^.header.nupvalues)) then
        Exit(nil);
      val := CClosure_upvalueN(fc, n-1);
      if (owner <> nil) then
        owner^ := fc;
      Result := '';
    end;
    LUA_TLCL: begin  //* Lua closure */
      fl := clLvalue(fi);
      p := fl^.p;
      if not((1 <= n) and (n <= p^.sizeupvalues)) then
        Exit(nil);
      val := LClosure_upvalsN(fl, n-1)^.v;
      if (uv <> nil) then
        uv^ := LClosure_upvalsN(fl, n - 1);
      name := p^.upvalues[n-1].name;
      if (name = Nil) then
        Result := '(*no name)'
      else
        Result := getstr(name);
    end;
    else
      Result := Nil;  //* not a closure */
  end;
end;


function lua_getupvalue(const L: Plua_State; const funcindex, n: Integer): PChar;
var
  val: PTValue;
begin
  //val := Nil;  //* to avoid warnings */
  lua_lock(L);
  Result := aux_upvalue(index2addr(L, funcindex), n, val, Nil, Nil);
  if (Result <> nil) then
  begin
    setobj2s(L, L^.top, val);
    api_incr_top(L);
  end;
  lua_unlock(L);
end;

function lua_setupvalue(const L: Plua_State; const funcindex, n: Integer): PChar;
var
  val: PTValue;
  owner: PCClosure;
  uv: PUpVal;
  fi: StkId;
begin
  //val := Nil;  //* to avoid warnings */
  owner := Nil;
  uv := Nil;
  lua_lock(L);
  fi := index2addr(L, funcindex);
  api_checknelems(L, 1);
  Result := aux_upvalue(fi, n, val, @owner, @uv);
  if (Result <> nil) then
  begin
    dec(L^.top);
    setobj(L, val, L^.top);
    if (owner <> nil) then
      luaC_barrier(L, obj2gco(owner), L^.top)
    else if (uv <> nil) then
      luaC_upvalbarrier(L, uv);
  end;
  lua_unlock(L);
end;

//static UpVal **getupvalref (lua_State *L, int fidx, int n)
function getupvalref(const L: Plua_State; const fidx, n: Integer): PPUpVal;
var
  f: PLClosure;
  fi: StkId;
begin
  fi := index2addr(L, fidx);
  api_check(L, ttisLclosure(fi), 'Lua function expected');
  f := clLvalue(fi);
  api_check(L, (1 <= n) and (n <= f^.p^.sizeupvalues), 'invalid upvalue index');
  Result := LClosure_upvals(f) + (n - 1);  //* get its upvalue pointer */
end;

function lua_upvalueid(const L: Plua_State; const fidx, n: Integer): Pointer;
var
  fi: StkId;
  f: PCClosure;
begin
  fi := index2addr(L, fidx);
  case (ttype(fi)) of
    LUA_TLCL:  //* lua closure */
      Result := getupvalref(L, fidx, n)^;
    LUA_TCCL:  //* C closure */
    begin
      f := clCvalue(fi);
      api_check(L, (1 <= n) and (n <= f^.header.nupvalues), 'invalid upvalue index');
      Result := CClosure_upvalueN(f, n - 1);
    end;
    else
    begin
      api_check(L, 0, 'closure expected');
      Result := Nil;
    end;
  end;
end;

procedure lua_upvaluejoin(const L: Plua_State; const fidx1, n1, fidx2, n2: Integer);
var
  up1, up2: PPUpVal;
begin
  up1 := getupvalref(L, fidx1, n1);
  up2 := getupvalref(L, fidx2, n2);
  if (up1^ = up2^) then
    Exit;
  luaC_upvdeccount(L, up1^);
  up1^ := up2^;
  inc((up1^)^.refcount);
  if (upisopen(up1^)) then
    (up1^)^.u_open_touched := 1;
  luaC_upvalbarrier(L, up1^);
end;

(*
** This function can be called asynchronously (e.g. during a signal).
** Fields 'oldpc', 'basehookcount', and 'hookcount' (set by
** 'resethookcount') are for debug only, and it is no problem if they
** get arbitrary values (causes at most one wrong hook call). 'hookmask'
** is an atomic value. We assume that pointers are atomic too (e.g., gcc
** ensures that for all platforms where it runs). Moreover, 'hook' is
** always checked before being called (see 'luaD_hook').
*)
procedure lua_sethook(const L: Plua_State; func: lua_Hook; mask, count: Integer);
begin
  if (func = Nil) or (mask = 0) then  //* turn off hooks? */
  begin
    mask := 0;
    func := Nil;
  end;
  if (isLua(L^.ci)) then
    L^.oldpc := L^.ci^.u.l_savedpc;
  // no 'volatile' in pascal, so using interlocked to set variable
  InterlockedExchange(Pointer(L^.hook), Pointer(func));
  L^.basehookcount := count;
  resethookcount(L);
  L^.hookmask := cast_byte(mask);
end;

function lua_gethook(const L: Plua_State): lua_Hook;
begin
  InterlockedExchange(Pointer(Result), Pointer(L^.hook));
end;

function lua_gethookmask(const L: Plua_State): Integer;
begin
  Result := L^.hookmask;
end;

function lua_gethookcount(const L: Plua_State): Integer;
begin
  Result := L^.basehookcount;
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

