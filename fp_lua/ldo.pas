unit ldo;
(*
** Stack and Call structure of Lua
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common, lzio;

(*
** Macro to check stack size and grow stack if needed.  Parameters
** 'pre'/'pos' allow the macro to preserve a pointer into the
** stack across reallocations, doing the work only when needed.
** 'condmovestack' is used in heavy tests to force a stack reallocation
** at every check.
*)
//#define luaD_checkstackaux(L,n,pre,pos)  \
//      if (L->stack_last - L->top <= (n)) \
//        { pre; luaD_growstack(L, n); pos; } else { condmovestack(L,pre,pos); }

(* In general, 'pre'/'pos' are empty (nothing to save) *)
//#define luaD_checkstack(L,n)    luaD_checkstackaux(L,n,(void)0,(void)0)
procedure luaD_checkstack(var L: lua_State; const n: Integer);


function savestack(var L: lua_State; const p: Pointer): PtrInt;
function restorestack(var L: lua_State; const n: PtrInt): PTValue;


(* type of protected functions, to be ran by 'runprotected' *)
//typedef void (*Pfunc) (lua_State *L, void *ud);
type
  Pfunc = procedure (L: Plua_State; ud: Pointer);

{ TODO
LUAI_FUNC int luaD_protectedparser (lua_State *L, ZIO *z, const char *name,
                                                  const char *mode);
LUAI_FUNC void luaD_hook (lua_State *L, int event, int line);
LUAI_FUNC int luaD_precall (lua_State *L, StkId func, int nresults);
LUAI_FUNC void luaD_call (lua_State *L, StkId func, int nResults);
LUAI_FUNC void luaD_callnoyield (lua_State *L, StkId func, int nResults);
LUAI_FUNC int luaD_pcall (lua_State *L, Pfunc func, void *u,
                                        ptrdiff_t oldtop, ptrdiff_t ef);
LUAI_FUNC int luaD_poscall (lua_State *L, CallInfo *ci, StkId firstResult,
                                          int nres);
LUAI_FUNC void luaD_reallocstack (lua_State *L, int newsize);
LUAI_FUNC void luaD_growstack (lua_State *L, int n);
LUAI_FUNC void luaD_shrinkstack (lua_State *L);
LUAI_FUNC void luaD_inctop (lua_State *L);

LUAI_FUNC l_noret luaD_throw (lua_State *L, int errcode);
LUAI_FUNC int luaD_rawrunprotected (lua_State *L, Pfunc f, void *ud);
}
function luaD_protectedparser(var L: lua_State; var z: ZIO; const name, mode: PChar): Integer;
procedure luaD_hook(var L: lua_State; const event, line: Integer);
function luaD_precall(var L: lua_State; const func: StkId; const nresults: Integer): Integer;
procedure luaD_call(var L: lua_State; const func: StkId; const nResults: Integer);
procedure luaD_callnoyield(var L: lua_State; const func: StkId; const nResults: Integer);
function luaD_pcall(var L: lua_State; const func: Pfunc; const u: Pointer;
  const oldtop, ef: PtrInt): Integer;
function luaD_poscall(var L: lua_State; var ci: CallInfo; const firstResult: StkId;
  const nres: Integer): Integer;
procedure luaD_reallocstack(var L: lua_State; const newsize: Integer);
procedure luaD_growstack(var L: lua_State; const n: Integer);
procedure luaD_shrinkstack(var L: lua_State);
procedure luaD_inctop(var L: lua_State);

procedure luaD_throw(var L: lua_State; const errcode: Integer);
function luaD_rawrunprotected(var L: lua_State; const f: Pfunc; const ud: Pointer): Integer;

implementation

//#define luaD_checkstackaux(L,n,pre,pos)  \
//      if (L->stack_last - L->top <= (n)) \
//        { pre; luaD_growstack(L, n); pos; } else { condmovestack(L,pre,pos); }
(* In general, 'pre'/'pos' are empty (nothing to save) *)
//#define luaD_checkstack(L,n)    luaD_checkstackaux(L,n,(void)0,(void)0)
procedure luaD_checkstack(var L: lua_State; const n: Integer);
begin
  if (L.stack_last - L.top) <= n then
    luaD_growstack(L, n)
  else
    condmovestack(L);
end;

//#define savestack(L,p)          ((char *)(p) - (char *)L->stack)
function savestack(var L: lua_State; const p: Pointer): PtrInt;
begin
  Result := p - Pointer(L.stack)
end;

//#define restorestack(L,n)       ((TValue *)((char *)L->stack + (n)))
function restorestack(var L: lua_State; const n: PtrInt): PTValue;
begin
  Result := PTValue(Pointer(L.stack) + n);
end;

function luaD_protectedparser(var L: lua_State; var z: ZIO; const name, mode: PChar): Integer;
begin

end;

procedure luaD_hook(var L: lua_State; const event, line: Integer);
begin

end;

function luaD_precall(var L: lua_State; const func: StkId; const nresults: Integer): Integer;
begin

end;

procedure luaD_call(var L: lua_State; const func: StkId; const nResults: Integer);
begin

end;

procedure luaD_callnoyield(var L: lua_State; const func: StkId; const nResults: Integer);
begin

end;

function luaD_pcall(var L: lua_State; const func: Pfunc; const u: Pointer; const oldtop,
  ef: PtrInt): Integer;
begin

end;

function luaD_poscall(var L: lua_State; var ci: CallInfo; const firstResult: StkId;
  const nres: Integer): Integer;
begin

end;

procedure luaD_reallocstack(var L: lua_State; const newsize: Integer);
begin

end;

procedure luaD_growstack(var L: lua_State; const n: Integer);
begin

end;

procedure luaD_shrinkstack(var L: lua_State);
begin

end;

procedure luaD_inctop(var L: lua_State);
begin

end;

procedure luaD_throw(var L: lua_State; const errcode: Integer);
begin

end;

function luaD_rawrunprotected(var L: lua_State; const f: Pfunc; const ud: Pointer): Integer;
begin

end;

end.

