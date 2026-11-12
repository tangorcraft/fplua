unit ldebug;
(*
** Auxiliary functions from Debug Interface module
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types;

function pcRel(const pc: PInstruction; const p: PProto): Integer;

function getfuncline(const f: PProto; const pc: Integer): Integer;

procedure resethookcount(const L: Plua_State);

//LUAI_FUNC l_noret luaG_typeerror (lua_State *L, const TValue *o,
//                                                const char *opname);
procedure luaG_typeerror(const L: Plua_State; const o: PTValue; const opname: PChar);
//LUAI_FUNC l_noret luaG_concaterror (lua_State *L, const TValue *p1,
//                                                  const TValue *p2);
procedure luaG_concaterror(const L: Plua_State; const p1, p2: PTValue);
//LUAI_FUNC l_noret luaG_opinterror (lua_State *L, const TValue *p1,
//                                                 const TValue *p2,
//                                                 const char *msg);
procedure luaG_opinterror(const L: Plua_State; const p1, p2: PTValue; const msg: PChar);
//LUAI_FUNC l_noret luaG_tointerror (lua_State *L, const TValue *p1,
//                                                 const TValue *p2);
procedure luaG_tointerror(const L: Plua_State; const p1, p2: PTValue);
//LUAI_FUNC l_noret luaG_ordererror (lua_State *L, const TValue *p1,
//                                                 const TValue *p2);
procedure luaG_ordererror(const L: Plua_State; const p1, p2: PTValue);
//LUAI_FUNC l_noret luaG_runerror (lua_State *L, const char *fmt, ...);
procedure luaG_runerror(const L: Plua_State; const fmt: PChar; const args: array of const);
//LUAI_FUNC const char *luaG_addinfo (lua_State *L, const char *msg,
//                                                  TString *src, int line);
function luaG_addinfo(const L: Plua_State; const msg: PChar; const src: PTString;
  const line: Integer): PChar;
//LUAI_FUNC l_noret luaG_errormsg (lua_State *L);
procedure luaG_errormsg(const L: Plua_State);
//LUAI_FUNC void luaG_traceexec (lua_State *L);
procedure luaG_traceexec(const L: Plua_State);

implementation

//#define pcRel(pc, p)  (cast(int, (pc) - (p)->code) - 1)
function pcRel(const pc: PInstruction; const p: PProto): Integer;
begin
  Result := Integer(pc - p^.code) - 1;
end;

//#define getfuncline(f,pc)     (((f)->lineinfo) ? (f)->lineinfo[pc] : -1)
function getfuncline(const f: PProto; const pc: Integer): Integer;
begin
  if f^.lineinfo <> nil then
    Result := f^.lineinfo[pc]
  else
    Result := -1;
end;

//#define resethookcount(L)     (L->hookcount = L->basehookcount)
procedure resethookcount(const L: Plua_State);
begin
  L^.hookcount := L^.basehookcount;
end;

procedure luaG_typeerror(const L: Plua_State; const o: PTValue; const opname: PChar);
begin

end;

procedure luaG_concaterror(const L: Plua_State; const p1, p2: PTValue);
begin

end;

procedure luaG_opinterror(const L: Plua_State; const p1, p2: PTValue; const msg: PChar);
begin

end;

procedure luaG_tointerror(const L: Plua_State; const p1, p2: PTValue);
begin

end;

procedure luaG_ordererror(const L: Plua_State; const p1, p2: PTValue);
begin

end;

procedure luaG_runerror(const L: Plua_State; const fmt: PChar; const args: array of const);
begin

end;

function luaG_addinfo(const L: Plua_State; const msg: PChar; const src: PTString;
  const line: Integer): PChar;
begin

end;

procedure luaG_errormsg(const L: Plua_State);
begin

end;

procedure luaG_traceexec(const L: Plua_State);
begin

end;

end.

