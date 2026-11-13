unit ltable;
(*
** Lua tables (hash)
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types;


function gnode(const t: PTable; const i: Integer): PNode;
function gval(const n: PNode): PTValue;
function gnext(const n: PNode): Integer;


(* 'const' to avoid wrong writings that can mess up field 'next' *)
function gkey(const n: PNode): TValuefields;

(*
** writable version of 'gkey'; allows updates to individual fields,
** but not to the whole (which has incompatible type)
*)
function wgkey(const n: PNode): PTValue;

procedure invalidateTMcache(var t: Table);

(* true when 't' is using 'dummynode' as its hash part *)
function isdummy(const t: PTable): Boolean;

(* allocated size for hash nodes *)
function allocsizenode(const t: PTable): Integer;

(* returns the key, given the value of a table entry *)
function keyfromval(const v: PTValue): TValuefields;

//LUAI_FUNC const TValue *luaH_getint (Table *t, lua_Integer key);
function luaH_getint(const t: PTable; const key: lua_Integer): PTValue;
//LUAI_FUNC void luaH_setint (lua_State *L, Table *t, lua_Integer key,
//                                                    TValue *value);
procedure luaH_setint(const L: Plua_State; const t: PTable;
  const key: lua_Integer; const value: PTValue);
//LUAI_FUNC const TValue *luaH_getshortstr (Table *t, TString *key);
function luaH_getshortstr(const t: PTable; const key: PTString): PTValue;
//LUAI_FUNC const TValue *luaH_getstr (Table *t, TString *key);
function luaH_getstr(const t: PTable; const key: PTString): PTValue;
//LUAI_FUNC const TValue *luaH_get (Table *t, const TValue *key);
function luaH_get(const t: PTable; const key: PTValue): PTValue;
//LUAI_FUNC TValue *luaH_newkey (lua_State *L, Table *t, const TValue *key);
function luaH_newkey(const L: Plua_State; const t: PTable; const key: PTValue): PTValue;
//LUAI_FUNC TValue *luaH_set (lua_State *L, Table *t, const TValue *key);
function luaH_set(const L: Plua_State; const t: PTable; const key: PTValue): PTValue;
//LUAI_FUNC Table *luaH_new (lua_State *L);
function luaH_new(const L: Plua_State): PTable;
//LUAI_FUNC void luaH_resize (lua_State *L, Table *t, unsigned int nasize,
//                                                    unsigned int nhsize);
procedure luaH_resize(const L: Plua_State; const t: PTable; const nasize, nhsize: Cardinal);
//LUAI_FUNC void luaH_resizearray (lua_State *L, Table *t, unsigned int nasize);
procedure luaH_resizearray(const L: Plua_State; const t: PTable; const nasize: Cardinal);
//LUAI_FUNC void luaH_free (lua_State *L, Table *t);
procedure luaH_free(const L: Plua_State; const t: PTable);
//LUAI_FUNC int luaH_next (lua_State *L, Table *t, StkId key);
function luaH_next(const L: Plua_State; const t: PTable; const key: StkId): Integer;
//LUAI_FUNC lua_Unsigned luaH_getn (Table *t);
function luaH_getn(const t: PTable): lua_Unsigned;

{$ifdef LUA_DEBUG}
//LUAI_FUNC Node *luaH_mainposition (const Table *t, const TValue *key);
function luaH_mainposition(const t: PTable; const key: PTValue): PNode;
//LUAI_FUNC int luaH_isdummy (const Table *t);
function luaH_isdummy(const t: PTable): Integer;
{$endif}

implementation

uses
  lobject;

//#define gnode(t,i)    (&(t)->node[i])
function gnode(const t: PTable; const i: Integer): PNode;
begin
  Result := t^.node_ + i;
end;

//#define gval(n)               (&(n)->i_val)
function gval(const n: PNode): PTValue;
begin
  Result := @(n^.i_val);
end;

//#define gnext(n)      ((n)->i_key.nk.next)
function gnext(const n: PNode): Integer;
begin
  Result := n^.i_key.nk.next;
end;

//#define gkey(n)               cast(const TValue*, (&(n)->i_key.tvk))
function gkey(const n: PNode): TValuefields;
begin
  Result := n^.i_key.tvk.fields;
end;

//#define wgkey(n)              (&(n)->i_key.nk)
function wgkey(const n: PNode): PTValue;
begin
  Result := @(n^.i_key.nk);
end;

//#define invalidateTMcache(t)  ((t)->flags = 0)
procedure invalidateTMcache(var t: Table);
begin
  t.flags := 0;
end;

//#define isdummy(t)            ((t)->lastfree == NULL)
function isdummy(const t: PTable): Boolean;
begin
  Result := (t^.lastfree = nil);
end;

//#define allocsizenode(t)      (isdummy(t) ? 0 : sizenode(t))
function allocsizenode(const t: PTable): Integer;
begin
  if (t^.lastfree = nil) then
    Result := 0
  else
    //Result := sizenode(t^);
    Result := 1 shl t^.lsizenode;
end;

//#define keyfromval(v) \
//  (gkey(cast(Node *, cast(char *, (v)) - offsetof(Node, i_val))))
function keyfromval(const v: PTValue): TValuefields;
const
  offsetof_Node_i_val = PtrInt(@(Node(nil^).i_val));
begin
  Result := PNode( Pointer(v) - offsetof_Node_i_val )^.i_key.tvk.fields;
end;

function luaH_getint(const t: PTable; const key: lua_Integer): PTValue;
begin

end;

procedure luaH_setint(const L: Plua_State; const t: PTable; const key: lua_Integer;
  const value: PTValue);
begin

end;

function luaH_getshortstr(const t: PTable; const key: PTString): PTValue;
begin

end;

function luaH_getstr(const t: PTable; const key: PTString): PTValue;
begin

end;

function luaH_get(const t: PTable; const key: PTValue): PTValue;
begin

end;

function luaH_newkey(const L: Plua_State; const t: PTable; const key: PTValue): PTValue;
begin

end;

function luaH_set(const L: Plua_State; const t: PTable; const key: PTValue): PTValue;
begin

end;

function luaH_new(const L: Plua_State): PTable;
begin

end;

procedure luaH_resize(const L: Plua_State; const t: PTable; const nasize, nhsize: Cardinal);
begin

end;

procedure luaH_resizearray(const L: Plua_State; const t: PTable; const nasize: Cardinal);
begin

end;

procedure luaH_free(const L: Plua_State; const t: PTable);
begin

end;

function luaH_next(const L: Plua_State; const t: PTable; const key: StkId): Integer;
begin

end;

function luaH_getn(const t: PTable): lua_Unsigned;
begin

end;

{$ifdef LUA_DEBUG}
function luaH_mainposition(const t: PTable; const key: PTValue): PNode;
begin

end;

function luaH_isdummy(const t: PTable): Integer;
begin

end;
{$endif}

end.

