unit lfunc;
(*
** Auxiliary functions to manipulate prototypes and closures
** Some types are defined in fplua_types.pas
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common;

function sizeCclosure(const n: Integer): Integer;

function sizeLclosure(const n: Integer): Integer;


(* test whether thread is in 'twups' list *)
function isintwups(const L: Plua_State): Boolean;


(*
** maximum number of upvalues in a closure (both C and Lua). (Value
** must fit in a VM register.)
*)
const
  MAXUPVAL     = 255;


function upisopen(const up: PUpVal): Boolean;

{ TODO
LUAI_FUNC Proto *luaF_newproto (lua_State *L);
LUAI_FUNC CClosure *luaF_newCclosure (lua_State *L, int nelems);
LUAI_FUNC LClosure *luaF_newLclosure (lua_State *L, int nelems);
LUAI_FUNC void luaF_initupvals (lua_State *L, LClosure *cl);
LUAI_FUNC UpVal *luaF_findupval (lua_State *L, StkId level);
LUAI_FUNC void luaF_close (lua_State *L, StkId level);
LUAI_FUNC void luaF_freeproto (lua_State *L, Proto *f);
LUAI_FUNC const char *luaF_getlocalname (const Proto *func, int local_number,
                                         int pc);
}
function luaF_newproto(const L: Plua_State): PProto;
function luaF_newCclosure(const L: Plua_State; const nelems: Integer): PCClosure;
function luaF_newLclosure(const L: Plua_State; nelems: Integer): PLClosure;
procedure luaF_initupvals(const L: Plua_State; const cl: PLClosure);
function luaF_findupval(const L: Plua_State; const level: StkId): PUpVal;
procedure luaF_close(const L: Plua_State; const level: StkId);
procedure luaF_freeproto(const L: Plua_State; const f: PProto);
function luaF_getlocalname(const func: PProto; local_number: Integer; const pc: Integer): PChar;

implementation

uses
  fp_lua,
  lgc, lmem, lobject, lstate;

//#define sizeCclosure(n)       (cast(int, sizeof(CClosure)) + \
//                         cast(int, sizeof(TValue)*((n)-1)))
function sizeCclosure(const n: Integer): Integer;
begin
  Result := sizeof(CClosure) + sizeof(TValue) * (n - 1);
end;

//#define sizeLclosure(n)       (cast(int, sizeof(LClosure)) + \
//                         cast(int, sizeof(TValue *)*((n)-1)))
function sizeLclosure(const n: Integer): Integer;
begin
  Result := sizeof(LClosure) + sizeof(PTValue) * (n - 1);
end;

//#define isintwups(L)  (L->twups != L)
function isintwups(const L: Plua_State): Boolean;
begin
  Result := (L^.twups <> L);
end;

//#define upisopen(up)    ((up)->v != &(up)->u.value)
function upisopen(const up: PUpVal): Boolean;
begin
  Result := (up^.v <> @(up^.u_value));
end;

function luaF_newproto(const L: Plua_State): PProto;
var
  o: PGCObject;
begin
  o := luaC_newobj(L, LUA_TPROTO, sizeof(Proto));
  Result := gco2p(o);
  Result^.k := Nil;
  Result^.sizek := 0;
  Result^.p := Nil;
  Result^.sizep := 0;
  Result^.code := Nil;
  Result^.cache := Nil;
  Result^.sizecode := 0;
  Result^.lineinfo := Nil;
  Result^.sizelineinfo := 0;
  Result^.upvalues := Nil;
  Result^.sizeupvalues := 0;
  Result^.numparams := 0;
  Result^.is_vararg := 0;
  Result^.maxstacksize := 0;
  Result^.locvars := Nil;
  Result^.sizelocvars := 0;
  Result^.linedefined := 0;
  Result^.lastlinedefined := 0;
  Result^.source := Nil;
end;

function luaF_newCclosure(const L: Plua_State; const nelems: Integer): PCClosure;
var
  o: PGCObject;
begin
  o := luaC_newobj(L, LUA_TCCL, sizeCclosure(nelems));
  Result := gco2ccl(o);
  Result^.header.nupvalues := cast_byte(nelems);
end;

function luaF_newLclosure(const L: Plua_State; nelems: Integer): PLClosure;
var
  o: PGCObject;
begin
  o := luaC_newobj(L, LUA_TLCL, sizeLclosure(nelems));
  Result := gco2lcl(o);
  Result^.p := Nil;
  Result^.header.nupvalues := cast_byte(nelems);
  while (nelems <> 0) do
  begin
    dec(nelems);
    LClosure_upvals(Result)[nelems] := Nil;
  end;
end;

(*
** fill a closure with new closed upvalues
*)
procedure luaF_initupvals(const L: Plua_State; const cl: PLClosure);
var
  i: Integer;
  uv: PUpVal;
begin
  for i := 0 to cl^.header.nupvalues-1 do
  begin
    uv := luaM_new(L, sizeof(UpVal));
    uv^.refcount := 1;
    uv^.v := @uv^.u_value;  //* make it closed */
    setnilvalue(uv^.v);
    LClosure_upvals(cl)[i] := uv;
  end;
end;

function luaF_findupval(const L: Plua_State; const level: StkId): PUpVal;
var
  pp: PPUpVal;
  p, uv: PUpVal;
begin
  pp := @L^.openupval;
  lua_assert(isintwups(L) or (L^.openupval = Nil));
  while (pp^ <> Nil) and ((pp^)^.v >= level) do
  begin
    p := pp^;
    lua_assert(upisopen(p));
    if (p^.v = level) then //* found a corresponding upvalue? */
      Exit(p);  //* return it */
    pp := @p^.u_open_next;
  end;
  //* not found: create a new upvalue */
  uv := luaM_new(L, sizeof(UpVal));
  uv^.refcount := 0;
  uv^.u_open_next := pp^;  //* link it to list of open upvalues */
  uv^.u_open_touched := 1;
  pp^ := uv;
  uv^.v := level;  //* current value lives in the stack */
  if (not isintwups(L)) then  //* thread not in list of threads with upvalues? */
  begin
    L^.twups := G(L)^.twups;  //* link it to the list */
    G(L)^.twups := L;
  end;
  Result := uv;
end;

procedure luaF_close(const L: Plua_State; const level: StkId);
var
  uv: PUpVal;
begin
  while (L^.openupval <> Nil) and (L^.openupval^.v >= level) do
  begin
    uv := L^.openupval;
    lua_assert(upisopen(uv));
    L^.openupval := uv^.u_open_next;  //* remove from 'open' list */
    if (uv^.refcount = 0) then //* no references? */
      luaM_free(L, uv, sizeof(UpVal))  //* free upvalue */
    else
    begin
      setobj(L, @uv^.u_value, uv^.v);  //* move value to upvalue slot */
      uv^.v := @uv^.u_value;  //* now current value lives here */
      luaC_upvalbarrier(L, uv);
    end;
  end;
end;

procedure luaF_freeproto(const L: Plua_State; const f: PProto);
begin
  luaM_freearray(L, f^.code, sizeof(Instruction), f^.sizecode);
  luaM_freearray(L, f^.p, sizeof(PProto), f^.sizep);
  luaM_freearray(L, f^.k, sizeof(TValue), f^.sizek);
  luaM_freearray(L, f^.lineinfo, sizeof(Integer), f^.sizelineinfo);
  luaM_freearray(L, f^.locvars, sizeof(LocVar), f^.sizelocvars);
  luaM_freearray(L, f^.upvalues, sizeof(Upvaldesc), f^.sizeupvalues);
  luaM_free(L, f, sizeof(Proto));
end;

(*
** Look for n-th local variable at line 'line' in function 'func'.
** Returns NULL if not found.
*)
function luaF_getlocalname(const func: PProto; local_number: Integer; const pc: Integer): PChar;
var
  i: Integer;
begin
  i := 0;
  while (i < func^.sizelocvars) and (func^.locvars[i].startpc <= pc) do
  begin
    if (pc < func^.locvars[i].endpc) then  //* is variable active? */
    begin
      dec(local_number);
      if (local_number = 0) then
        Exit( getstr(func^.locvars[i].varname) );
    end;
    Inc(i);
  end;
  Result := Nil;  //* not found */
end;

end.

