unit lstate;
(*
** Global State
** Some types are defined in fplua_types.pas
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  lobject, fplua_types, fplua_common;

(*

** Some notes about garbage-collected objects: All objects in Lua must
** be kept somehow accessible until being freed, so all objects always
** belong to one (and only one) of these lists, using field 'next' of
** the 'CommonHeader' for the link:
**
** 'allgc': all objects not marked for finalization;
** 'finobj': all objects marked for finalization;
** 'tobefnz': all objects ready to be finalized;
** 'fixedgc': all objects that are not to be collected (currently
** only small strings, such as reserved words).
**
** Moreover, there is another set of lists that control gray objects.
** These lists are linked by fields 'gclist'. (All objects that
** can become gray have such a field. The field is not the same
** in all objects, but it always has this name.)  Any gray object
** must belong to one of these lists, and all objects in these lists
** must be gray:
**
** 'gray': regular gray objects, still waiting to be visited.
** 'grayagain': objects that must be revisited at the atomic phase.
**   That includes
**   - black objects got in a write barrier;
**   - all kinds of weak tables during propagation phase;
**   - all threads.
** 'weak': tables with weak values to be cleared;
** 'ephemeron': ephemeron tables with white->white entries;
** 'allweak': tables with weak keys and/or weak values to be cleared.
** The last three lists are used only during the atomic phase.

*)


(* extra stack space to handle TM calls and some other extras *)
const
  EXTRA_STACK = 5;

  BASIC_STACK_SIZE      = (2*LUA_MINSTACK);


(* kinds of Garbage Collection *)
const
  KGC_NORMAL    = 0;
  KGC_EMERGENCY = 1;  //* gc was forced by an allocation failure */


(*
** Bits in CallInfo status
*)
const
  CIST_OAH       = (1 shl 0);  //* original value of 'allowhook' */
  CIST_LUA       = (1 shl 1);  //* call is running a Lua function */
  CIST_HOOKED    = (1 shl 2);  //* call is running a debug hook */
  CIST_FRESH     = (1 shl 3);  //* call is running on a fresh invocation of luaV_execute */
  CIST_YPCALL    = (1 shl 4);  //* call is a yieldable protected call */
  CIST_TAIL      = (1 shl 5);  //* call was tail called */
  CIST_HOOKYIELD = (1 shl 6);  //* last hook called yielded */
  CIST_LEQ       = (1 shl 7);  //* using __lt for __le */
  CIST_FIN       = (1 shl 8);  //* call is running a finalizer */

//#define isLua(ci)       ((ci)->callstatus & CIST_LUA)
function isLua(const ci: CallInfo): Boolean;

(* assume that CIST_OAH has offset 0 and that 'v' is strictly 0/1 *)
//#define setoah(st,v)    ((st) = ((st) & ~CIST_OAH) | (v))
//#define getoah(st)      ((st) & CIST_OAH)
procedure setoah(var st: Word; const v: Integer);
function getoah(const st: Word): Word;


//#define G(L)    (L->l_G)
function G(const L: lua_State): Pglobal_State;

(*
** Union of all collectable objects (only for conversions)
*)
type
  GCUnion = record case Byte of
    1:(gc: GCObject);  //* common header */
    2:(ts: TString);
    3:(u: Udata);
    4:(cl: Closure);
    5:(h: Table);
    6:(p: Proto);
    7:(th: lua_State);  //* thread */
  end;
  PGCUnion = ^GCUnion;

//#define cast_u(o)       cast(union GCUnion *, (o))
type
  cast_u = PGCUnion;

(* macros to convert a GCObject into a specific value *)

function gco2ts(const o: PGCObject): PTString;
function gco2u(const o: PGCObject): PUdata;
function gco2lcl(const o: PGCObject): PLClosure;
function gco2ccl(const o: PGCObject): PCClosure;
function gco2cl(const o: PGCObject): PClosure;
function gco2t(const o: PGCObject): PTable;
function gco2p(const o: PGCObject): PProto;
function gco2th(const o: PGCObject): Plua_State;


(* macro to convert a Lua object into a GCObject *)
function obj2gco(const v: Pointer): PGCObject;

(* actual number of total bytes allocated *)
//#define gettotalbytes(g)        cast(lu_mem, (g)->totalbytes + (g)->GCdebt)
function gettotalbytes(const g: global_State): lu_mem;

{ TODO
LUAI_FUNC void luaE_setdebt (global_State *g, l_mem debt);
LUAI_FUNC void luaE_freethread (lua_State *L, lua_State *L1);
LUAI_FUNC CallInfo *luaE_extendCI (lua_State *L);
LUAI_FUNC void luaE_freeCI (lua_State *L);
LUAI_FUNC void luaE_shrinkCI (lua_State *L);
}
procedure luaE_setdebt(const g: global_State; const debt: l_mem);
procedure luaE_freethread(const L, L1: lua_State);
function luaE_extendCI(const L: lua_State): PCallInfo;
procedure luaE_freeCI(const L: lua_State);
procedure luaE_shrinkCI(const L: lua_State);

implementation

function isLua(const ci: CallInfo): Boolean;
begin
  Result := (ci.callstatus and CIST_LUA) <> 0;
end;

procedure setoah(var st: Word; const v: Integer);
begin
  st := (st and not CIST_OAH) or v;
end;

function getoah(const st: Word): Word;
begin
  Result := st and CIST_OAH;
end;

function G(const L: lua_State): Pglobal_State;
begin
  Result := L.l_G;
end;

//#define gco2ts  \
//        check_exp(novariant((o)->tt) == LUA_TSTRING, &((cast_u(o))->ts))
function gco2ts(const o: PGCObject): PTString;
begin
  Result := check_exp(novariant(o^.header.tt) = LUA_TSTRING, o);
end;

//#define gco2u(o)  check_exp((o)->tt == LUA_TUSERDATA, &((cast_u(o))->u))
function gco2u(const o: PGCObject): PUdata;
begin
  Result := check_exp(o^.header.tt = LUA_TUSERDATA, o);
end;

//#define gco2lcl(o)  check_exp((o)->tt == LUA_TLCL, &((cast_u(o))->cl.l))
function gco2lcl(const o: PGCObject): PLClosure;
begin
  Result := check_exp(o^.header.tt = LUA_TLCL, o);
end;

//#define gco2ccl(o)  check_exp((o)->tt == LUA_TCCL, &((cast_u(o))->cl.c))
function gco2ccl(const o: PGCObject): PCClosure;
begin
  Result := check_exp(o^.header.tt = LUA_TCCL, o);
end;

//#define gco2cl(o)  \
//        check_exp(novariant((o)->tt) == LUA_TFUNCTION, &((cast_u(o))->cl))
function gco2cl(const o: PGCObject): PClosure;
begin
  Result := check_exp(novariant(o^.header.tt) = LUA_TFUNCTION, o);
end;

//#define gco2t(o)  check_exp((o)->tt == LUA_TTABLE, &((cast_u(o))->h))
function gco2t(const o: PGCObject): PTable;
begin
  Result := check_exp(o^.header.tt = LUA_TTABLE, o);
end;

//#define gco2p(o)  check_exp((o)->tt == LUA_TPROTO, &((cast_u(o))->p))
function gco2p(const o: PGCObject): PProto;
begin
  Result := check_exp(o^.header.tt = LUA_TPROTO, o);
end;

//#define gco2th(o)  check_exp((o)->tt == LUA_TTHREAD, &((cast_u(o))->th))
function gco2th(const o: PGCObject): Plua_State;
begin
  Result := check_exp(o^.header.tt = LUA_TTHREAD, o);
end;

//#define obj2gco(v) \
//        check_exp(novariant((v)->tt) < LUA_TDEADKEY, (&(cast_u(v)->gc)))
function obj2gco(const v: Pointer): PGCObject;
begin
  Result := check_exp(cast_u(v)^.gc.header.tt < LUA_TDEADKEY, v);
end;

function gettotalbytes(const g: global_State): lu_mem;
begin
  Result := g.totalbytes + g.GCdebt;
end;

procedure luaE_setdebt(const g: global_State; const debt: l_mem);
begin

end;

procedure luaE_freethread(const L, L1: lua_State);
begin

end;

function luaE_extendCI(const L: lua_State): PCallInfo;
begin

end;

procedure luaE_freeCI(const L: lua_State);
begin

end;

procedure luaE_shrinkCI(const L: lua_State);
begin

end;

end.

