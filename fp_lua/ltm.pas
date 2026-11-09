unit ltm;
(*
** Tag methods
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common;

{ TMS enum defined in fplua_common }

function gfasttm(const g: global_State; const et: PTable; const e: TMS): PTValue;

function fasttm(const l: lua_State; const et: PTable; const e: TMS): PTValue;

function ttypename(const x: Integer): PChar;

{ TODO
LUAI_FUNC const char *luaT_objtypename (lua_State *L, const TValue *o);

LUAI_FUNC const TValue *luaT_gettm (Table *events, TMS event, TString *ename);
LUAI_FUNC const TValue *luaT_gettmbyobj (lua_State *L, const TValue *o,
                                                       TMS event);
LUAI_FUNC void luaT_init (lua_State *L);

LUAI_FUNC void luaT_callTM (lua_State *L, const TValue *f, const TValue *p1,
                            const TValue *p2, TValue *p3, int hasres);
LUAI_FUNC int luaT_callbinTM (lua_State *L, const TValue *p1, const TValue *p2,
                              StkId res, TMS event);
LUAI_FUNC void luaT_trybinTM (lua_State *L, const TValue *p1, const TValue *p2,
                              StkId res, TMS event);
LUAI_FUNC int luaT_callorderTM (lua_State *L, const TValue *p1,
                                const TValue *p2, TMS event);
}
function luaT_objtypename(const L: Plua_State; const o: PTValue): PChar;

function luaT_gettm(const events: PTable; const event: TMS; const ename: PTString): PTValue;
function luaT_gettmbyobj(const L: Plua_State; const o: PTValue; const event: TMS): PChar;

procedure luaT_init(var L: lua_State);

procedure luaT_callTM(var L: lua_State; const f, p1, p2, p3: PTValue; const hasres: lu_int);
function luaT_callbinTM(var L: lua_State; const p1, p2: PTValue; const res: StkId; const event: TMS): Integer;
procedure luaT_trybinTM(var L: lua_State; const p1, p2: PTValue; const res: StkId; const event: TMS);
function luaT_callorderTM(var L: lua_State; const p1, p2: PTValue; const event: TMS): Integer;

implementation

uses
  lobject;

//LUAI_DDEC const char *const luaT_typenames_[LUA_TOTALTAGS];
const
  udatatypename = 'userdata';
  luaT_typenames_: array[0..LUA_TOTALTAGS-1] of PChar = (
    'no value',
    'nil', 'boolean', udatatypename, 'number',
    'string', 'table', 'function', udatatypename, 'thread',
    'proto' //* this last case is used for tests only */
  );

//#define gfasttm(g,et,e) ((et) == NULL ? NULL : \
//  ((et)->flags & (1u<<(e))) ? NULL : luaT_gettm(et, e, (g)->tmname[e]))
function gfasttm(const g: global_State; const et: PTable; const e: TMS): PTValue;
begin
  if et = nil then Exit(nil);
  if (et^.flags and (1 shl ord(e))) <> 0 then Exit(nil);
  Result := luaT_gettm(et, e, g.tmname[e]);
end;

//#define fasttm(l,et,e)  gfasttm(G(l), et, e)
function fasttm(const l: lua_State; const et: PTable; const e: TMS): PTValue;
begin
  Result := gfasttm(l.l_G^, et, e);
end;

//#define ttypename(x)    luaT_typenames_[(x) + 1]
function ttypename(const x: Integer): PChar;
begin
  Result := luaT_typenames_[x + 1];
end;

function luaT_objtypename(const L: Plua_State; const o: PTValue): PChar;
begin

end;

function luaT_gettm(const events: PTable; const event: TMS; const ename: PTString): PTValue;
begin

end;

function luaT_gettmbyobj(const L: Plua_State; const o: PTValue; const event: TMS): PChar;
begin

end;

procedure luaT_init(var L: lua_State);
begin

end;

procedure luaT_callTM(var L: lua_State; const f, p1, p2, p3: PTValue; const hasres: lu_int);
begin

end;

function luaT_callbinTM(var L: lua_State; const p1, p2: PTValue; const res: StkId;
  const event: TMS): Integer;
begin

end;

procedure luaT_trybinTM(var L: lua_State; const p1, p2: PTValue; const res: StkId;
  const event: TMS);
begin

end;

function luaT_callorderTM(var L: lua_State; const p1, p2: PTValue; const event: TMS): Integer;
begin

end;

end.

