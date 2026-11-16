unit lvm;
(*
** Lua virtual machine
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common;

//#if !defined(LUA_NOCVTN2S)
//#define cvt2str(o)    ttisnumber(o)
//#else
//#define cvt2str(o)    0       /* no conversion from numbers to strings */
//#endif
function cvt2str(const o: TValuefields): Boolean;


//#if !defined(LUA_NOCVTS2N)
//#define cvt2num(o)    ttisstring(o)
//#else
//#define cvt2num(o)    0       /* no conversion from strings to numbers */
//#endif
function cvt2num(const o: TValuefields): Boolean;


(*
** You can define LUA_FLOORN2I if you want to convert floats to integers
** by flooring them (instead of raising an error if they are not
** integral values)
*)
//#if !defined(LUA_FLOORN2I)
const
  LUA_FLOORN2I = 0;
//#endif


function tonumber(const o: PTValue; const n: Plua_Number): Integer;

function tointeger(const o: PTValue; const i: Plua_Integer): Integer;

//#define intop(op,v1,v2) l_castU2S(l_castS2U(v1) op l_castS2U(v2))
function intop_add(const v1, v2: lua_Integer): lua_Integer;
function intop_sub(const v1, v2: lua_Integer): lua_Integer;
function intop_mul(const v1, v2: lua_Integer): lua_Integer;
function intop_and(const v1, v2: lua_Integer): lua_Integer;
function intop_or(const v1, v2: lua_Integer): lua_Integer;
function intop_xor(const v1, v2: lua_Integer): lua_Integer;
function intop_shr(const v1, v2: lua_Integer): lua_Integer;
function intop_shl(const v1, v2: lua_Integer): lua_Integer;


function luaV_rawequalobj(const t1, t2: PTValue): Integer;


(*
** fast track for 'gettable': if 't' is a table and 't[k]' is not nil,
** return 1 with 'slot' pointing to 't[k]' (final result).  Otherwise,
** return 0 (meaning it will have to check metamethod) with 'slot'
** pointing to a nil 't[k]' (if 't' is a table) or NULL (otherwise).
** 'f' is the raw get function to use.
*)
//#define luaV_fastget(L,t,k,slot,f) \
//  (!ttistable(t)  \
//   ? (slot = NULL, 0)  /* not a table; 'slot' is NULL and result is 0 */  \
//   : (slot = f(hvalue(t), k),  /* else, do raw access */  \
//      !ttisnil(slot)))  /* result not nil? */
function luaV_fastget_val(const L: Plua_State; const t: PTValue; const k: PTValue;
  out slot: PTValue): Boolean;
function luaV_fastget_int(const L: Plua_State; const t: PTValue; const k: lua_Integer;
  out slot: PTValue): Boolean;
function luaV_fastget_str(const L: Plua_State; const t: PTValue; const k: PTString;
  out slot: PTValue): Boolean;

(*
** standard implementation for 'gettable'
*)
procedure luaV_gettable(const L: Plua_State; const t: PTValue; const k, v: PTValue);

(*
** Fast track for set table. If 't' is a table and 't[k]' is not nil,
** call GC barrier, do a raw 't[k]=v', and return true; otherwise,
** return false with 'slot' equal to NULL (if 't' is not a table) or
** 'nil'. (This is needed by 'luaV_finishget'.) Note that, if the macro
** returns true, there is no need to 'invalidateTMcache', because the
** call is not creating a new entry.
*)
//#define luaV_fastset(L,t,k,slot,f,v) \
//  (!ttistable(t) \
//   ? (slot = NULL, 0) \
//   : (slot = f(hvalue(t), k), \
//     ttisnil(slot) ? 0 \
//     : (luaC_barrierback(L, hvalue(t), v), \
//        setobj2t(L, cast(TValue *,slot), v), \
//        1)))
function luaV_fastset_val(const L: Plua_State; const t: PTValue; const k: PTValue;
  out slot: PTValue; const v: StkId): Boolean;
function luaV_fastset_int(const L: Plua_State; const t: PTValue; const k: lua_Integer;
  out slot: PTValue; const v: StkId): Boolean;
function luaV_fastset_str(const L: Plua_State; const t: PTValue; const k: PTString;
  out slot: PTValue; const v: StkId): Boolean;


function luaV_settable(const L: Plua_State; const t: PTValue; const k: PTValue;
  const v: StkId): Boolean;



//LUAI_FUNC int luaV_equalobj (lua_State *L, const TValue *t1, const TValue *t2);
function luaV_equalobj(const L: Plua_State; const t1, t2: PTValue): Integer;
//LUAI_FUNC int luaV_lessthan (lua_State *L, const TValue *l, const TValue *r);
function luaV_lessthan(const L: Plua_State; const l_, r_: PTValue): Integer;
//LUAI_FUNC int luaV_lessequal (lua_State *L, const TValue *l, const TValue *r);
function luaV_lessequal(const L: Plua_State; const l_, r_: PTValue): Integer;
//LUAI_FUNC int luaV_tonumber_ (const TValue *obj, lua_Number *n);
function luaV_tonumber_(const obj: PTValue; const n: Plua_Number): Integer;
//LUAI_FUNC int luaV_tointeger (const TValue *obj, lua_Integer *p, int mode);
function luaV_tointeger(const obj: PTValue; const p: Plua_Integer; const mode: Integer): Integer;
//LUAI_FUNC void luaV_finishget (lua_State *L, const TValue *t, TValue *key,
//                               StkId val, const TValue *slot);
procedure luaV_finishget(const L: Plua_State; const t, key: PTValue; const val: StkId;
  const slot: PTValue);
//LUAI_FUNC void luaV_finishset (lua_State *L, const TValue *t, TValue *key,
//                               StkId val, const TValue *slot);
procedure luaV_finishset(const L: Plua_State; const t, key: PTValue; const val: StkId;
  const slot: PTValue);
//LUAI_FUNC void luaV_finishOp (lua_State *L);
procedure luaV_finishOp(const L: Plua_State);
//LUAI_FUNC void luaV_execute (lua_State *L);
procedure luaV_execute(const L: Plua_State);
//LUAI_FUNC void luaV_concat (lua_State *L, int total);
procedure luaV_concat(const L: Plua_State; const total: Integer);
//LUAI_FUNC lua_Integer luaV_div (lua_State *L, lua_Integer x, lua_Integer y);
function luaV_div(const L: Plua_State; const x, y: lua_Integer): lua_Integer;
//LUAI_FUNC lua_Integer luaV_mod (lua_State *L, lua_Integer x, lua_Integer y);
function luaV_mod(const L: Plua_State; const x, y: lua_Integer): lua_Integer;
//LUAI_FUNC lua_Integer luaV_shiftl (lua_Integer x, lua_Integer y);
function luaV_shiftl(const x, y: lua_Integer): lua_Integer;
//LUAI_FUNC void luaV_objlen (lua_State *L, StkId ra, const TValue *rb);
procedure luaV_objlen(const L: Plua_State; const ra: StkId; const rb: PTValue);

implementation

uses
  lobject, ltable, lgc;

function cvt2str(const o: TValuefields): Boolean;
begin
  {$ifndef LUA_NOCVTN2S}
  Result := ttisnumber(o);
  {$else}
  Result := False;
  {$endif}
end;

function cvt2num(const o: TValuefields): Boolean;
begin
  {$ifndef LUA_NOCVTS2N}
  Result := ttisstring(o);
  {$else}
  Result := False;
  {$endif}
end;

//#define tonumber(o,n) \
//      (ttisfloat(o) ? (*(n) = fltvalue(o), 1) : luaV_tonumber_(o,n))
function tonumber(const o: PTValue; const n: Plua_Number): Integer;
begin
  if ttisfloat(o^.fields) then
  begin
    n^ := fltvalue(o^.fields);
    Result := 1;
  end
  else
    Result := luaV_tonumber_(o,n);
end;

//#define tointeger(o,i) \
//    (ttisinteger(o) ? (*(i) = ivalue(o), 1) : luaV_tointeger(o,i,LUA_FLOORN2I))
function tointeger(const o: PTValue; const i: Plua_Integer): Integer;
begin
  if ttisinteger(o^.fields) then
  begin
    i^ := ivalue(o^.fields);
    Result := 1;
  end
  else
    Result := luaV_tointeger(o,i,LUA_FLOORN2I);
end;

function intop_add(const v1, v2: lua_Integer): lua_Integer;
begin
  Result := lua_Integer(lua_Unsigned(v1) + lua_Unsigned(v2))
end;

function intop_sub(const v1, v2: lua_Integer): lua_Integer;
begin
  Result := lua_Integer(lua_Unsigned(v1) - lua_Unsigned(v2))
end;

function intop_mul(const v1, v2: lua_Integer): lua_Integer;
begin
  Result := lua_Integer(lua_Unsigned(v1) * lua_Unsigned(v2))
end;

function intop_and(const v1, v2: lua_Integer): lua_Integer;
begin
  Result := lua_Integer(lua_Unsigned(v1) and lua_Unsigned(v2))
end;

function intop_or(const v1, v2: lua_Integer): lua_Integer;
begin
  Result := lua_Integer(lua_Unsigned(v1) or lua_Unsigned(v2))
end;

function intop_xor(const v1, v2: lua_Integer): lua_Integer;
begin
  Result := lua_Integer(lua_Unsigned(v1) xor lua_Unsigned(v2))
end;

function intop_shr(const v1, v2: lua_Integer): lua_Integer;
begin
  Result := lua_Integer(lua_Unsigned(v1) shr lua_Unsigned(v2))
end;

function intop_shl(const v1, v2: lua_Integer): lua_Integer;
begin
  Result := lua_Integer(lua_Unsigned(v1) shl lua_Unsigned(v2))
end;

//#define luaV_rawequalobj(t1,t2)               luaV_equalobj(NULL,t1,t2)
function luaV_rawequalobj(const t1, t2: PTValue): Integer;
begin
  Result := luaV_equalobj(nil,t1,t2);
end;

// f = luaH_get //
function luaV_fastget_val(const L: Plua_State; const t: PTValue; const k: PTValue;
  out slot: PTValue): Boolean;
begin
  if not ttistable(t^.fields) then
  begin //* not a table; 'slot' is NULL and result is 0 */
    slot := nil;
    Result := False;
  end
  else
  begin //* else, do raw access */
    slot := luaH_get(hvalue(t^.fields), k);
    Result := not ttisnil(slot^.fields); //* result not nil? */
  end;
end;

// f = luaH_getint //
function luaV_fastget_int(const L: Plua_State; const t: PTValue; const k: lua_Integer;
  out slot: PTValue): Boolean;
begin
  if not ttistable(t^.fields) then
  begin //* not a table; 'slot' is NULL and result is 0 */
    slot := nil;
    Result := False;
  end
  else
  begin //* else, do raw access */
    slot := luaH_getint(hvalue(t^.fields), k);
    Result := not ttisnil(slot^.fields); //* result not nil? */
  end;
end;

// f = luaH_getstr //
function luaV_fastget_str(const L: Plua_State; const t: PTValue; const k: PTString;
  out slot: PTValue): Boolean;
begin
  if not ttistable(t^.fields) then
  begin //* not a table; 'slot' is NULL and result is 0 */
    slot := nil;
    Result := False;
  end
  else
  begin //* else, do raw access */
    slot := luaH_getstr(hvalue(t^.fields), k);
    Result := not ttisnil(slot^.fields); //* result not nil? */
  end;
end;

//#define luaV_gettable(L,t,k,v) { const TValue *slot; \
//  if (luaV_fastget(L,t,k,slot,luaH_get)) { setobj2s(L, v, slot); } \
//  else luaV_finishget(L,t,k,v,slot); }
procedure luaV_gettable(const L: Plua_State; const t: PTValue; const k, v: PTValue);
var
  slot: PTValue;
begin
  if luaV_fastget_val(L,t,k,slot) then
    setobj2s(L, v^.fields, slot^.fields)
  else
    luaV_finishget(L,t,k,v,slot);
end;

// f = luaH_get //
function luaV_fastset_val(const L: Plua_State; const t: PTValue; const k: PTValue; out
  slot: PTValue; const v: StkId): Boolean;
begin
  if not ttistable(t^.fields) then
  begin
    slot := nil;
    Result := False;
  end
  else
  begin
    slot := luaH_get(hvalue(t^.fields), k);
    if ttisnil(slot^.fields) then
      Result := False
    else
    begin
      luaC_barrierback(L^, hvalue(t^.fields), v^.fields);
      setobj2t(L, slot, v);
      Result := True;
    end;
  end;
end;

function luaV_fastset_int(const L: Plua_State; const t: PTValue; const k: lua_Integer; out
  slot: PTValue; const v: StkId): Boolean;
begin
  if not ttistable(t^.fields) then
  begin
    slot := nil;
    Result := False;
  end
  else
  begin
    slot := luaH_getint(hvalue(t^.fields), k);
    if ttisnil(slot^.fields) then
      Result := False
    else
    begin
      luaC_barrierback(L^, hvalue(t^.fields), v^.fields);
      setobj2t(L, slot, v);
      Result := True;
    end;
  end;
end;

function luaV_fastset_str(const L: Plua_State; const t: PTValue; const k: PTString; out
  slot: PTValue; const v: StkId): Boolean;
begin
  if not ttistable(t^.fields) then
  begin
    slot := nil;
    Result := False;
  end
  else
  begin
    slot := luaH_getstr(hvalue(t^.fields), k);
    if ttisnil(slot^.fields) then
      Result := False
    else
    begin
      luaC_barrierback(L^, hvalue(t^.fields), v^.fields);
      setobj2t(L, slot, v);
      Result := True;
    end;
  end;
end;

//#define luaV_settable(L,t,k,v) { const TValue *slot; \
//  if (!luaV_fastset(L,t,k,slot,luaH_get,v)) \
//    luaV_finishset(L,t,k,v,slot); }
function luaV_settable(const L: Plua_State; const t: PTValue; const k: PTValue;
  const v: StkId): Boolean;
var
  slot: PTValue;
begin
  if not luaV_fastset_val(L,t,k,slot,v) then
    luaV_finishset(L,t,k,v,slot);
end;

function luaV_equalobj(const L: Plua_State; const t1, t2: PTValue): Integer;
begin

end;

function luaV_lessthan(const L: Plua_State; const l_, r_: PTValue): Integer;
begin

end;

function luaV_lessequal(const L: Plua_State; const l_, r_: PTValue): Integer;
begin

end;

function luaV_tonumber_(const obj: PTValue; const n: Plua_Number): Integer;
begin

end;

function luaV_tointeger(const obj: PTValue; const p: Plua_Integer;
  const mode: Integer): Integer;
begin

end;

procedure luaV_finishget(const L: Plua_State; const t, key: PTValue; const val: StkId;
  const slot: PTValue);
begin

end;

procedure luaV_finishset(const L: Plua_State; const t, key: PTValue; const val: StkId;
  const slot: PTValue);
begin

end;

procedure luaV_finishOp(const L: Plua_State);
begin

end;

procedure luaV_execute(const L: Plua_State);
begin

end;

procedure luaV_concat(const L: Plua_State; const total: Integer);
begin

end;

function luaV_div(const L: Plua_State; const x, y: lua_Integer): lua_Integer;
begin

end;

function luaV_mod(const L: Plua_State; const x, y: lua_Integer): lua_Integer;
begin

end;

function luaV_shiftl(const x, y: lua_Integer): lua_Integer;
begin

end;

procedure luaV_objlen(const L: Plua_State; const ra: StkId; const rb: PTValue);
begin

end;

end.

