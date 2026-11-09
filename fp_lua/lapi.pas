unit lapi;
(*
** Auxiliary functions from Lua API
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common;


procedure api_incr_top(var L: lua_State);

procedure adjustresults(var L: lua_State; const nres: Integer);

procedure api_checknelems(var L: lua_State; const n: Integer);


implementation

//#define api_incr_top(L)   {L->top++; api_check(L, L->top <= L->ci->top, \
//                              "stack overflow");}
procedure api_incr_top(var L: lua_State);
begin
  inc(L.top);
  api_check(L, L.top <= L.ci^.top, 'stack overflow');
end;

//#define adjustresults(L,nres) \
//    { if ((nres) == LUA_MULTRET && L->ci->top < L->top) L->ci->top = L->top; }
procedure adjustresults(var L: lua_State; const nres: Integer);
begin
  if (nres = LUA_MULTRET) and (L.ci^.top < L.top) then
    L.ci^.top := L.top;
end;

//#define api_checknelems(L,n)  api_check(L, (n) < (L->top - L->ci->func), \
//                                "not enough elements in the stack")
procedure api_checknelems(var L: lua_State; const n: Integer);
begin
  api_check(L, n < (L.top - L.ci^.func), 'not enough elements in the stack');
end;

end.

