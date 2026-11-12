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

function sizeCclosure(n: Integer): Integer;

function sizeLclosure(n: Integer): Integer;


(* test whether thread is in 'twups' list *)
function isintwups(const L: Plua_State): Boolean;


(*
** maximum number of upvalues in a closure (both C and Lua). (Value
** must fit in a VM register.)
*)
const
  MAXUPVAL     = 255;


function upisopen(const up: UpVal): Boolean;

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
function luaF_newproto(var L: lua_State): PProto;
function luaF_newCclosure(var L: lua_State; const nelems: Integer): PCClosure;
function luaF_newLclosure(var L: lua_State; const nelems: Integer): PLClosure;
procedure luaF_initupvals(var L: lua_State; var cl: LClosure);
function luaF_findupval(var L: lua_State; const level: StkId): PUpVal;
procedure luaF_close(var L: lua_State; const level: StkId);
procedure luaF_freeproto(var L: lua_State; const f: PProto);
function luaF_getlocalname(const func: PProto; const local_number, pc: Integer): PChar;

implementation

//#define sizeCclosure(n)       (cast(int, sizeof(CClosure)) + \
//                         cast(int, sizeof(TValue)*((n)-1)))
function sizeCclosure(n: Integer): Integer;
begin
  Result := sizeof(CClosure) + sizeof(TValue) * (n - 1);
end;

//#define sizeLclosure(n)       (cast(int, sizeof(LClosure)) + \
//                         cast(int, sizeof(TValue *)*((n)-1)))
function sizeLclosure(n: Integer): Integer;
begin
  Result := sizeof(LClosure) + sizeof(PTValue) * (n - 1);
end;

//#define isintwups(L)  (L->twups != L)
function isintwups(const L: Plua_State): Boolean;
begin
  Result := (L^.twups <> L);
end;

//#define upisopen(up)    ((up)->v != &(up)->u.value)
function upisopen(const up: UpVal): Boolean;
begin
  Result := (up.v <> @(up.value));
end;

function luaF_newproto(var L: lua_State): PProto;
begin

end;

function luaF_newCclosure(var L: lua_State; const nelems: Integer): PCClosure;
begin

end;

function luaF_newLclosure(var L: lua_State; const nelems: Integer): PLClosure;
begin

end;

procedure luaF_initupvals(var L: lua_State; var cl: LClosure);
begin

end;

function luaF_findupval(var L: lua_State; const level: StkId): PUpVal;
begin

end;

procedure luaF_close(var L: lua_State; const level: StkId);
begin

end;

procedure luaF_freeproto(var L: lua_State; const f: PProto);
begin

end;

function luaF_getlocalname(const func: PProto; const local_number, pc: Integer): PChar;
begin

end;

end.

