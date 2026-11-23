unit lauxlib;
(*
** Auxiliary functions for building Lua libraries
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types, fplua_sysutils;

(* extra error code for 'luaL_loadfilex' *)
const
  LUA_ERRFILE   = (LUA_ERRERR+1);

(* key, in the registry, for table of loaded modules *)
const
  LUA_LOADED_TABLE      = '_LOADED';


(* key, in the registry, for table of preloaded loaders *)
const
  LUA_PRELOAD_TABLE     = '_PRELOAD';


type
  luaL_Reg = record
    name: PChar;
    func: lua_CFunction;
  end;
  PluaL_Reg = ^luaL_Reg;

const
  LUAL_NUMSIZES = (sizeof(lua_Integer)*16 + sizeof(lua_Number));

// TODO
//LUALIB_API void (luaL_checkversion_) (lua_State *L, lua_Number ver, size_t sz);
//procedure luaL_checkversion_(const L: Plua_State; const ver: lua_Number; const sz: SizeUInt);
procedure luaL_checkversion(const L: Plua_State);

//LUALIB_API int (luaL_getmetafield) (lua_State *L, int obj, const char *e);
//LUALIB_API int (luaL_callmeta) (lua_State *L, int obj, const char *e);
//LUALIB_API const char *(luaL_tolstring) (lua_State *L, int idx, size_t *len);
//LUALIB_API int (luaL_argerror) (lua_State *L, int arg, const char *extramsg);
//LUALIB_API const char *(luaL_checklstring) (lua_State *L, int arg,
//                                                          size_t *l);
//LUALIB_API const char *(luaL_optlstring) (lua_State *L, int arg,
//                                          const char *def, size_t *l);
//LUALIB_API lua_Number (luaL_checknumber) (lua_State *L, int arg);
//LUALIB_API lua_Number (luaL_optnumber) (lua_State *L, int arg, lua_Number def);
//
//LUALIB_API lua_Integer (luaL_checkinteger) (lua_State *L, int arg);
//LUALIB_API lua_Integer (luaL_optinteger) (lua_State *L, int arg,
//                                          lua_Integer def);
function luaL_getmetafield(const L: Plua_State; const obj: Integer; const event: PChar): Integer;
function luaL_callmeta(const L: Plua_State; obj: Integer; const event: PChar): lu_int;
function luaL_tolstring(const L: Plua_State; const idx: Integer; const len: PSizeUInt): PChar;
function luaL_argerror(const L: Plua_State; arg: Integer; const extramsg: PChar): Integer;
function luaL_checklstring(const L: Plua_State; const arg: Integer; const len: PSizeUInt): PChar;
function luaL_optlstring(const L: Plua_State; const arg: Integer; const def: PChar;
  const len: PSizeUInt): PChar;
function luaL_checknumber(const L: Plua_State; const arg: Integer): lua_Number;
function luaL_optnumber(const L: Plua_State; const arg: Integer;
  const def: lua_Number): lua_Number;
function luaL_checkinteger(const L: Plua_State; const arg: Integer): lua_Integer;
function luaL_optinteger(const L: Plua_State; const arg: Integer;
  const def: lua_Integer): lua_Integer;

//LUALIB_API void (luaL_checkstack) (lua_State *L, int sz, const char *msg);
//LUALIB_API void (luaL_checktype) (lua_State *L, int arg, int t);
//LUALIB_API void (luaL_checkany) (lua_State *L, int arg);
procedure luaL_checkstack(const L: Plua_State; const space: Integer; const msg: PChar);
procedure luaL_checktype(const L: Plua_State; const arg, t: Integer);
procedure luaL_checkany(const L: Plua_State; const arg: Integer);

//LUALIB_API int   (luaL_newmetatable) (lua_State *L, const char *tname);
//LUALIB_API void  (luaL_setmetatable) (lua_State *L, const char *tname);
//LUALIB_API void *(luaL_testudata) (lua_State *L, int ud, const char *tname);
//LUALIB_API void *(luaL_checkudata) (lua_State *L, int ud, const char *tname);
function luaL_newmetatable(const L: Plua_State; const tname: PChar): Integer;
procedure luaL_setmetatable(const L: Plua_State; const tname: PChar);
function luaL_testudata(const L: Plua_State; const ud: Integer; const tname: PChar): Pointer;
function luaL_checkudata(const L: Plua_State; const ud: Integer; const tname: PChar): Pointer;

//LUALIB_API void (luaL_where) (lua_State *L, int lvl);
//LUALIB_API int (luaL_error) (lua_State *L, const char *fmt, ...);
procedure luaL_where(const L: Plua_State; const level: Integer);
function luaL_error(const L: Plua_State; const fmt: PChar; const args: array of const): Integer; overload;
function luaL_error(const L: Plua_State; const fmt: PChar): Integer; overload;

//LUALIB_API int (luaL_checkoption) (lua_State *L, int arg, const char *def,
//                                   const char *const lst[]);
function luaL_checkoption(const L: Plua_State; const arg: Integer; const def: PChar;
  const lst: array of PChar): Integer;

//LUALIB_API int (luaL_fileresult) (lua_State *L, int stat, const char *fname);
//LUALIB_API int (luaL_execresult) (lua_State *L, int stat);
function luaL_fileresult(const L: Plua_State; const stat: lu_int; const fname: PChar): Integer;
function luaL_execresult(const L: Plua_State; const stat: lu_int): Integer;

(* predefined references *)
const
  LUA_NOREF     = (-2);
  LUA_REFNIL    = (-1);

//LUALIB_API int (luaL_ref) (lua_State *L, int t);
//LUALIB_API void (luaL_unref) (lua_State *L, int t, int ref);
function luaL_ref(const L: Plua_State; t: Integer): Integer;
procedure luaL_unref(const L: Plua_State; t: Integer; const ref: Integer);

//LUALIB_API int (luaL_loadfilex) (lua_State *L, const char *filename,
//                                               const char *mode);
function luaL_loadfilex(const L: Plua_State; const filename, mode: PChar): Integer;

function luaL_loadfile(const L: Plua_State; const f: PChar): Integer;

//LUALIB_API int (luaL_loadbufferx) (lua_State *L, const char *buff, size_t sz,
                                   //const char *name, const char *mode);
//LUALIB_API int (luaL_loadstring) (lua_State *L, const char *s);
function luaL_loadbufferx(const L: Plua_State; const buff: PChar; const size: SizeUInt;
  const name, mode: PChar): Integer;
function luaL_loadstring(const L: Plua_State; const s: PChar): Integer;

//LUALIB_API lua_State *(luaL_newstate) (void);
function luaL_newstate(): Plua_State;

//LUALIB_API lua_Integer (luaL_len) (lua_State *L, int idx);
function luaL_len(const L: Plua_State; const idx: Integer): lua_Integer;

//LUALIB_API const char *(luaL_gsub) (lua_State *L, const char *s, const char *p,
//                                                  const char *r);
function luaL_gsub(const L: Plua_State; s, p, r: PChar): PChar;

//LUALIB_API void (luaL_setfuncs) (lua_State *L, const luaL_Reg *l, int nup);
procedure luaL_setfuncs(const L: Plua_State; ls: PluaL_Reg; const nup: Integer);

//LUALIB_API int (luaL_getsubtable) (lua_State *L, int idx, const char *fname);
function luaL_getsubtable(const L: Plua_State; idx: Integer; const fname: PChar): Integer;

//LUALIB_API void (luaL_traceback) (lua_State *L, lua_State *L1,
//                                  const char *msg, int level);
procedure luaL_traceback(const L, L1: Plua_State; const msg: PChar; level: Integer);

//LUALIB_API void (luaL_requiref) (lua_State *L, const char *modname,
//                                 lua_CFunction openf, int glb);
procedure luaL_requiref(const L: Plua_State; const modname: PChar; const openf: lua_CFunction;
  const glb: Integer);

(*
** ===============================================================
** some useful macros
** ===============================================================
*)


procedure luaL_newlibtable(const L: Plua_State; const l_: array of luaL_Reg);

procedure luaL_newlib(const L: Plua_State; const l_: array of luaL_Reg);

procedure luaL_argcheck(const L: Plua_State; const cond: Boolean; const arg: Integer;
  const extramsg: PChar);
function luaL_checkstring(const L: Plua_State; const n: Integer): PChar;
function luaL_optstring(const L: Plua_State; const n: Integer; const d: PChar): PChar;

function luaL_typename(const L: Plua_State; const i: Integer): PChar;

function luaL_dofile(const L: Plua_State; const fn: PChar): Integer;

function luaL_dostring(const L: Plua_State; const s: PChar): Integer;

function luaL_getmetatable(const L: Plua_State; const n: PChar): Integer;

//#define luaL_opt(L,f,n,d)       (lua_isnoneornil(L,(n)) ? (d) : f(L,(n)))
// TODO this one may be difficult to translate, need to unwrap
procedure luaL_opt(const L: Plua_State; var f, n, d); // stub declaration

function luaL_loadbuffer(const L: Plua_State; const s: PChar; const sz: SizeUInt;
  const n: PChar): Integer;

(*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*)

type
  luaL_Buffer = record
    b: PChar;  //* buffer address */
    size: SizeUInt;  //* buffer size */
    n: SizeUInt;  //* number of characters in buffer */
    L: Plua_State;
    initb: array[0..LUAL_BUFFERSIZE-1] of char;  //* initial buffer */
  end;
  PluaL_Buffer = ^luaL_Buffer;


procedure luaL_addchar(var B: luaL_Buffer; const c: Char);

procedure luaL_addsize(var B: luaL_Buffer; const s: SizeUInt);

//LUALIB_API void (luaL_buffinit) (lua_State *L, luaL_Buffer *B);
//LUALIB_API char *(luaL_prepbuffsize) (luaL_Buffer *B, size_t sz);
//LUALIB_API void (luaL_addlstring) (luaL_Buffer *B, const char *s, size_t l);
//LUALIB_API void (luaL_addstring) (luaL_Buffer *B, const char *s);
//LUALIB_API void (luaL_addvalue) (luaL_Buffer *B);
//LUALIB_API void (luaL_pushresult) (luaL_Buffer *B);
//LUALIB_API void (luaL_pushresultsize) (luaL_Buffer *B, size_t sz);
//LUALIB_API char *(luaL_buffinitsize) (lua_State *L, luaL_Buffer *B, size_t sz);
procedure luaL_buffinit(const L: Plua_State; out B: luaL_Buffer);
function luaL_prepbuffsize(var B: luaL_Buffer; const sz: SizeUInt): PChar;
procedure luaL_addlstring(var B: luaL_Buffer; const s: PChar; const l: SizeUInt);
procedure luaL_addstring(var B: luaL_Buffer; const s: PChar);
procedure luaL_addvalue(var B: luaL_Buffer);
procedure luaL_pushresult(var B: luaL_Buffer);
procedure luaL_pushresultsize(var B: luaL_Buffer; const sz: SizeUInt);
function luaL_buffinitsize(const L: Plua_State; var B: luaL_Buffer; const sz: SizeUInt): PChar;

function luaL_prepbuffer(var B: luaL_Buffer): PChar;

(* }====================================================== *)



(*
** {======================================================
** File handles for IO library
** =======================================================
*)

(*
** A file handle is a userdata with metatable 'LUA_FILEHANDLE' and
** initial structure 'luaL_Stream' (it may contain other fields
** after that initial structure).
*)

const
  LUA_FILEHANDLE        = 'FILE*';


type
  luaL_Stream = record
    f: pFile;  //* stream (NULL for incompletely created streams) */
    closef: lua_CFunction;  //* to close stream (NULL for closed streams) */
  end;

(* }====================================================== *)



(* compatibility with old module system *)
{$ifdef LUA_COMPAT_MODULE}

//LUALIB_API void (luaL_pushmodule) (lua_State *L, const char *modname,
//                                   int sizehint);
//LUALIB_API void (luaL_openlib) (lua_State *L, const char *libname,
//                                const luaL_Reg *l, int nup);
procedure luaL_pushmodule(const L: Plua_State; const modname: PChar; const sizehint: Integer);
procedure luaL_openlib(const L: Plua_State; const libname: PChar; const ls: PluaL_Reg;
  const nup: Integer);

procedure luaL_register(const L: Plua_State; const n: PChar; const ls: PluaL_Reg);

{$endif}


(*
** {==================================================================
** "Abstraction Layer" for basic report of messages and errors
** ===================================================================
*)

(* print a string *)
//#if !defined(lua_writestring)
//#define lua_writestring(s,l)   fwrite((s), sizeof(char), (l), stdout)
//#endif
procedure lua_writestring(const s: PChar; const l: Integer);

(* print a newline and flush the output *)
//#if !defined(lua_writeline)
//#define lua_writeline()        (lua_writestring("\n", 1), fflush(stdout))
//#endif
procedure lua_writeline();

(* print an error message *)
//#if !defined(lua_writestringerror)
//#define lua_writestringerror(s,p) \
//        (fprintf(stderr, (s), (p)), fflush(stderr))
//#endif
procedure lua_writestringerror(const s: PChar; const p: array of const);

(* }================================================================== *)


(*
** {============================================================
** Compatibility with deprecated conversions
** =============================================================
*)
{$ifdef LUA_COMPAT_APIINTCASTS}

function luaL_checkunsigned(const L: Plua_State; const arg: Integer): lua_Unsigned;
function luaL_optunsigned(const L: Plua_State; const arg: Integer;
  const def: lua_Unsigned): lua_Unsigned;

function luaL_checkint(const L: Plua_State; const arg: Integer): Integer;
function luaL_optint(const L: Plua_State; const arg: Integer;
  const def: Integer): Integer;

function luaL_checklong(const L: Plua_State; const arg: Integer): LongInt;
function luaL_optlong(const L: Plua_State; const arg: Integer;
  const def: LongInt): LongInt;

{$endif}
(* }============================================================ *)


implementation

uses
  SysUtils, fp_lua;

type
  (* userdata to box arbitrary data *)
  UBox = record
    box: Pointer;
    bsize: SizeUInt;
  end;
  PUBox = ^UBox;

//static int typeerror (lua_State *L, int arg, const char *tname)
function typeerror(const L: Plua_State; const arg: Integer; const tname: PChar): Integer;
var
  msg,
  typearg: PChar; //* name for the type of the actual argument */
begin
  if (luaL_getmetafield(L, arg, '__name') = LUA_TSTRING) then
    typearg := lua_tostring(L, -1)  //* use the given type name */
  else if (lua_type(L, arg) = LUA_TLIGHTUSERDATA) then
    typearg := 'light userdata'  //* special name for messages */
  else
    typearg := luaL_typename(L, arg);  //* standard name */
  msg := lua_pushfstring(L, '%s expected, got %s', [tname, typearg]);
  Result := luaL_argerror(L, arg, msg);
end;

//static void tag_error (lua_State *L, int arg, int tag)
procedure tag_error(const L: Plua_State; const arg, tag: Integer);
begin
  typeerror(L, arg, lua_typename(L, tag));
end;

(*
** =======================================================
** Traceback
** =======================================================
*)

const
  LEVELS1 = 10;      //* size of the first part of the stack */
  LEVELS2 = 11;      //* size of the second part of the stack */



(*
** search for 'objidx' in table at index -1.
** return 1 + string at top if find a good name.
*)
//static int findfield (lua_State *L, int objidx, int level)
function findfield(const L: Plua_State; const objidx, level: Integer): lu_int;
begin
  if (level = 0) or (not lua_istable(L, -1)) then
    Exit(0);  //* not found */
  lua_pushnil(L);  //* start 'next' loop */
  while (lua_next(L, -2) <> 0) do   //* for each pair in table */
  begin
    if (lua_type(L, -2) = LUA_TSTRING) then   //* ignore non-string keys */
    begin
      if (lua_rawequal(L, objidx, -1)) then  //* found object? */
      begin
        lua_pop(L, 1);  //* remove value (but keep name) */
        Exit(1);
      end
      else if (findfield(L, objidx, level - 1) <> 0) then  //* try recursively */
      begin
        lua_remove(L, -2);  //* remove table (but keep name) */
        lua_pushliteral(L, '.');
        lua_insert(L, -2);  //* place '.' between the two names */
        lua_concat(L, 3);
        Exit(1);
      end;
    end;
    lua_pop(L, 1);  //* remove value */
  end;
  Result := 0;  //* not found */
end;


(*
** Search for a name for a function in all loaded modules
*)
//static int pushglobalfuncname (lua_State *L, lua_Debug *ar)
function pushglobalfuncname(const L: Plua_State; const ar: Plua_Debug): lu_int;
var
  top: Integer;
  name: PChar;
begin
  top := lua_gettop(L);
  lua_getinfo(L, 'f', ar);  //* push function */
  lua_getfield(L, LUA_REGISTRYINDEX, LUA_LOADED_TABLE);
  if (findfield(L, top + 1, 2)) then
  begin
    name := lua_tostring(L, -1);
    if (strlcomp(name, '_G.', 3) = 0) then   //* name start with '_G.'? */
    begin
      lua_pushstring(L, name + 3);  //* push name without prefix */
      lua_remove(L, -2);  //* remove original name */
    end;
    lua_copy(L, -1, top + 1);  //* move name to proper place */
    lua_pop(L, 2);  //* remove pushed values */
    Result := 1;
  end
  else
  begin
    lua_settop(L, top);  //* remove function and global table */
    Result := 0;
  end;
end;


//static void pushfuncname (lua_State *L, lua_Debug *ar)
procedure pushfuncname(const L: Plua_State; const ar: Plua_Debug);
begin
  if (pushglobalfuncname(L, ar)) then  //* try first a global name */
  begin
    lua_pushfstring(L, 'function "%s"', [lua_tostring(L, -1)]);
    lua_remove(L, -2);  //* remove name */
  end
  else if (ar^.namewhat^ <> #0) then //* is there a name from code? */
    lua_pushfstring(L, '%s "%s"', [ar^.namewhat, ar^.name])  //* use it */
  else if (ar^.what^ = 'm') then //* main? */
      lua_pushliteral(L, 'main chunk')
  else if (ar^.what^ <> 'C') then //* for Lua functions, use <file:line> */
    lua_pushfstring(L, 'function <%s:%d>', [ar^.short_src, ar^.linedefined])
  else  //* nothing left... */
    lua_pushliteral(L, '?');
end;


//static int lastlevel (lua_State *L)
function lastlevel(const L: Plua_State): Integer;
var
  ar: lua_Debug;
  li, le, m: Integer;
begin
  li := 1;
  le := 1;
  //* find an upper bound */
  while (lua_getstack(L, le, @ar) <> 0) do
  begin
    li := le;
    le := le * 2;
  end;
  //* do a binary search */
  while (li < le) do
  begin
    m := (li + le) div 2;
    if (lua_getstack(L, m, @ar) <> 0) then
      li := m + 1
    else
      le := m;
  end;
  Result := le - 1;
end;

procedure luaL_checkversion_(const L: Plua_State; const ver: lua_Number; const sz: SizeUInt);
var
  v: Plua_Number;
begin
  v := fp_lua.lua_version(L);
  if (sz <> LUAL_NUMSIZES) then //* check numeric types */
    luaL_error(L, 'core and library have incompatible numeric types');
  if (v <> lua_version(Nil)) then
    luaL_error(L, 'multiple Lua VMs detected')
  else if (v^ <> ver) then
    luaL_error(L, 'version mismatch: app. needs %f, Lua core provides %f',
                  [LUAI_UACNUMBER(ver), LUAI_UACNUMBER(v^)]);
end;

//#define luaL_checkversion(L)  \
//          luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES)
procedure luaL_checkversion(const L: Plua_State);
begin
  luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES);
end;

function luaL_getmetafield(const L: Plua_State; const obj: Integer;
  const event: PChar): Integer;
begin
  if (lua_getmetatable(L, obj) = 0) then //* no metatable? */
    Result := LUA_TNIL
  else
  begin
    //int tt;
    lua_pushstring(L, event);
    Result := lua_rawget(L, -2);
    if (Result = LUA_TNIL) then //* is metafield nil? */
      lua_pop(L, 2)  //* remove metatable and metafield */
    else
      lua_remove(L, -2);  //* remove only metatable */
    //return tt;  //* return metafield type */
  end;
end;

function luaL_callmeta(const L: Plua_State; obj: Integer; const event: PChar): lu_int;
begin
  obj := lua_absindex(L, obj);
  if (luaL_getmetafield(L, obj, event) = LUA_TNIL) then //* no metafield? */
    Exit(0);
  lua_pushvalue(L, obj);
  lua_call(L, 1, 1);
  Result := 1;
end;

function luaL_tolstring(const L: Plua_State; const idx: Integer; const len: PSizeUInt): PChar;
var
  tt: Integer;
  kind: PChar;
begin
  if (luaL_callmeta(L, idx, '__tostring')) then //* metafield? */
  begin
    if (lua_isstring(L, -1) = 0) then
      luaL_error(L, '"__tostring" must return a string');
  end
  else
  begin
    case (lua_type(L, idx)) of
      LUA_TNUMBER: begin
        if (lua_isinteger(L, idx)) then
          lua_pushfstring(L, '%d', [LUAI_UACINT(lua_tointeger(L, idx))])
        else
          lua_pushfstring(L, '%f', [LUAI_UACNUMBER(lua_tonumber(L, idx))]);
      end;
      LUA_TSTRING:
        lua_pushvalue(L, idx);
      LUA_TBOOLEAN: begin
        if lua_toboolean(L, idx) then
          lua_pushstring(L, 'true')
        else
          lua_pushstring(L, 'false');
      end;
      LUA_TNIL:
        lua_pushliteral(L, 'nil');
      else
      begin
        tt := luaL_getmetafield(L, idx, '__name');  //* try name */
        if (tt = LUA_TSTRING) then
          kind := lua_tostring(L, -1)
        else
          kind := luaL_typename(L, idx);
        lua_pushfstring(L, '%s: %p', [kind, lua_topointer(L, idx)]);
        if (tt <> LUA_TNIL) then
          lua_remove(L, -2);  //* remove '__name' */
      end;
    end;
  end;
  Result := lua_tolstring(L, -1, len);
end;

function luaL_argerror(const L: Plua_State; arg: Integer; const extramsg: PChar): Integer;
var
  ar: lua_Debug;
begin
  if (lua_getstack(L, 0, @ar) = 0) then //* no stack frame? */
    Exit( luaL_error(L, 'bad argument #%d (%s)', [arg, extramsg]) );
  lua_getinfo(L, 'n', @ar);
  if (strcomp(ar.namewhat, 'method') = 0) then
  begin
    dec(arg);  //* do not count 'self' */
    if (arg = 0) then //* error is in the self argument itself? */
      Exit( luaL_error(L, 'calling "%s" on bad self (%s)',
                          [ar.name, extramsg]) );
  end;
  if (ar.name = Nil) then
  begin
    if (pushglobalfuncname(L, @ar)) then
      ar.name := lua_tostring(L, -1)
    else
      ar.name := '?';
  end;
  Result := luaL_error(L, 'bad argument #%d to "%s" (%s)',
                          [arg, ar.name, extramsg]);
end;

function luaL_checklstring(const L: Plua_State; const arg: Integer;
  const len: PSizeUInt): PChar;
begin
  Result := lua_tolstring(L, arg, len);
  if (Result = nil) then tag_error(L, arg, LUA_TSTRING);
end;

function luaL_optlstring(const L: Plua_State; const arg: Integer; const def: PChar;
  const len: PSizeUInt): PChar;
begin
  if (lua_isnoneornil(L, arg)) then
  begin
    if (len<>nil) then
    begin
      if def <> nil then
        len^ := strlen(def)
      else
        len^ := 0;
    end;
    Result := def;
  end
  else
    Result := luaL_checklstring(L, arg, len);
end;

function luaL_checknumber(const L: Plua_State; const arg: Integer): lua_Number;
var
  isnum: lu_int;
begin
  Result := lua_tonumberx(L, arg, @isnum);
  if (isnum = 0) then
    tag_error(L, arg, LUA_TNUMBER);
end;

function luaL_optnumber(const L: Plua_State; const arg: Integer;
  const def: lua_Number): lua_Number;
begin
  //luaL_opt(L, luaL_checknumber, arg, def);
  if lua_isnoneornil(L,arg) then
    Result := def
  else
    Result := luaL_checknumber(L, arg);
end;

//static void interror (lua_State *L, int arg)
procedure interror(const L: Plua_State; const arg: Integer);
begin
  if (lua_isnumber(L, arg)) then
    luaL_argerror(L, arg, 'number has no integer representation')
  else
    tag_error(L, arg, LUA_TNUMBER);
end;

function luaL_checkinteger(const L: Plua_State; const arg: Integer): lua_Integer;
var
  isnum: lu_int;
begin
  Result := lua_tointegerx(L, arg, @isnum);
  if (isnum = 0) then
    interror(L, arg);
end;

function luaL_optinteger(const L: Plua_State; const arg: Integer;
  const def: lua_Integer): lua_Integer;
begin
  //return luaL_opt(L, luaL_checkinteger, arg, def);
  if lua_isnoneornil(L,arg) then
    Result := def
  else
    Result := luaL_checkinteger(L, arg);
end;

(*
** Ensures the stack has at least 'space' extra slots, raising an error
** if it cannot fulfill the request. (The error handling needs a few
** extra slots to format the error message. In case of an error without
** this extra space, Lua will generate the same 'stack overflow' error,
** but without 'msg'.)
*)
procedure luaL_checkstack(const L: Plua_State; const space: Integer; const msg: PChar);
begin
  if (not lua_checkstack(L, space)) then
  begin
    if (msg <> nil) then
      luaL_error(L, 'stack overflow (%s)', [msg])
    else
      luaL_error(L, 'stack overflow');
  end;
end;

procedure luaL_checktype(const L: Plua_State; const arg, t: Integer);
begin
  if (lua_type(L, arg) <> t) then
    tag_error(L, arg, t);
end;

procedure luaL_checkany(const L: Plua_State; const arg: Integer);
begin
  if (lua_type(L, arg) = LUA_TNONE) then
    luaL_argerror(L, arg, 'value expected');
end;

function luaL_newmetatable(const L: Plua_State; const tname: PChar): Integer;
begin
  if (luaL_getmetatable(L, tname) <> LUA_TNIL) then //* name already in use? */
    Exit(0);  //* leave previous value on top, but return 0 */
  lua_pop(L, 1);
  lua_createtable(L, 0, 2);  //* create metatable */
  lua_pushstring(L, tname);
  lua_setfield(L, -2, '__name');  //* metatable.__name = tname */
  lua_pushvalue(L, -1);
  lua_setfield(L, LUA_REGISTRYINDEX, tname);  //* registry.name = metatable */
  Result := 1;
end;

procedure luaL_setmetatable(const L: Plua_State; const tname: PChar);
begin
  luaL_getmetatable(L, tname);
  lua_setmetatable(L, -2);
end;

function luaL_testudata(const L: Plua_State; const ud: Integer; const tname: PChar): Pointer;
begin
  Result := lua_touserdata(L, ud);
  if (Result <> Nil) then   //* value is a userdata? */
  begin
    if (lua_getmetatable(L, ud) <> 0) then  //* does it have a metatable? */
    begin
      luaL_getmetatable(L, tname);  //* get correct metatable */
      if (lua_rawequal(L, -1, -2) = 0) then //* not the same? */
        Result := Nil;  //* value is a userdata with wrong metatable */
      lua_pop(L, 2);  //* remove both metatables */
      Exit;
    end;
  end;
  Result := Nil;  //* value is not a userdata with a metatable */
end;

function luaL_checkudata(const L: Plua_State; const ud: Integer; const tname: PChar): Pointer;
begin
  Result := luaL_testudata(L, ud, tname);
  if (Result = Nil) then typeerror(L, ud, tname);
end;

(*
** The use of 'lua_pushfstring' ensures this function does not
** need reserved stack space when called.
*)
procedure luaL_where(const L: Plua_State; const level: Integer);
var
  ar: lua_Debug;
begin
  if (lua_getstack(L, level, @ar)) then //* check function at level */
  begin
    lua_getinfo(L, 'Sl', @ar);  //* get info about it */
    if (ar.currentline > 0) then  //* is there info? */
    begin
      lua_pushfstring(L, '%s:%d: ', [ar.short_src, ar.currentline]);
      Exit;
    end;
  end;
  lua_pushfstring(L, '', []);  //* else, no information available... */
end;

(*
** Again, the use of 'lua_pushvfstring' ensures this function does
** not need reserved stack space when called. (At worst, it generates
** an error with "stack overflow" instead of the given message.)
*)
function luaL_error(const L: Plua_State; const fmt: PChar; const args: array of const): Integer;
begin
  luaL_where(L, 1);
  lua_pushvfstring(L, fmt, args);
  lua_concat(L, 2);
  Result := lua_error(L);
end;

function luaL_error(const L: Plua_State; const fmt: PChar): Integer;
begin
  luaL_where(L, 1);
  lua_pushvfstring(L, fmt, []);
  lua_concat(L, 2);
  Result := lua_error(L);
end;

function luaL_checkoption(const L: Plua_State; const arg: Integer; const def: PChar;
  const lst: array of PChar): Integer;
var
  name: PChar;
  i: Integer;
begin
  if (def <> nil) then
    name := luaL_optstring(L, arg, def)
  else
    name := luaL_checkstring(L, arg);
  //for (i=0; lst[i]; i++)
  i:=0;
  while lst[i] <> nil do
  begin
    if (strcomp(lst[i], name) = 0) then
      Exit(i);
    inc(i);
  end;
  Result := luaL_argerror(L, arg, lua_pushfstring(L, 'invalid option "%s"', [name]));
end;

function luaL_fileresult(const L: Plua_State; const stat: lu_int; const fname: PChar): Integer;
var
  en: Integer;
begin
  en := errno; //* calls to Lua API may change this value */
  if (stat <> 0) then
  begin
    lua_pushboolean(L, 1);
    Result := 1;
  end
  else
  begin
    lua_pushnil(L);
    if (fname <> nil) then
      lua_pushfstring(L, '%s: %s', [fname, strerror(en)])
    else
      lua_pushstring(L, strerror(en));
    lua_pushinteger(L, en);
    Result := 3;
  end;
end;

//#if !defined(l_inspectstat)	/* { TODO */
//
//#if defined(LUA_USE_POSIX)
//
//#include <sys/wait.h>
//
///*
//** use appropriate macros to interpret 'pclose' return status
//*/
//#define l_inspectstat(stat,what)  \
//   if (WIFEXITED(stat)) { stat = WEXITSTATUS(stat); } \
//   else if (WIFSIGNALED(stat)) { stat = WTERMSIG(stat); what = "signal"; }
//
//#else
//
//#define l_inspectstat(stat,what)  /* no op */
//
//#endif
//
//#endif

function luaL_execresult(const L: Plua_State; const stat: lu_int): Integer;
var
  what: PChar;
begin
  what := 'exit';  //* type of termination */
  if (stat = -1) then //* error? */
    Result := luaL_fileresult(L, 0, Nil)
  else
  begin
    //l_inspectstat(stat, what);  //* interpret result */
    if (what^ = 'e') and (stat = 0) then //* successful termination? */
      lua_pushboolean(L, 1)
    else
      lua_pushnil(L);
    lua_pushstring(L, what);
    lua_pushinteger(L, stat);
    Result := 3;  //* return true/nil,what,code */
  end;
end;

(* index of free-list header *)
const
  freelist = 0;


function luaL_ref(const L: Plua_State; t: Integer): Integer;
begin
  //int ref;
  if (lua_isnil(L, -1)) then
  begin
    lua_pop(L, 1);  //* remove from stack */
    Exit(LUA_REFNIL);  //* 'nil' has a unique fixed reference */
  end;
  t := lua_absindex(L, t);
  lua_rawgeti(L, t, freelist);  //* get first free element */
  Result := Integer(lua_tointeger(L, -1));  //* ref = t[freelist] */
  lua_pop(L, 1);  //* remove it from stack */
  if (Result <> 0) then  //* any free element? */
  begin
    lua_rawgeti(L, t, Result);  //* remove it from list */
    lua_rawseti(L, t, freelist);  //* (t[freelist] = t[ref]) */
  end
  else  //* no free elements */
    Result := Integer(lua_rawlen(L, t) + 1);  //* get a new reference */
  lua_rawseti(L, t, Result);
  //return ref;
end;

procedure luaL_unref(const L: Plua_State; t: Integer; const ref: Integer);
begin
  if (ref >= 0) then
  begin
    t := lua_absindex(L, t);
    lua_rawgeti(L, t, freelist);
    lua_rawseti(L, t, ref);  //* t[ref] = t[freelist] */
    lua_pushinteger(L, ref);
    lua_rawseti(L, t, freelist);  //* t[freelist] = ref */
  end;
end;

(*
** =======================================================
** Load functions
** =======================================================
*)
// TODO check that file operation work proerly

type
  LoadF = record
    n: Integer;  //* number of pre-read characters */
    f: pFile;  //* file being read */
    buff: array[0..BUFSIZ-1] of char;  //* area for reading file */
  end;
  PLoadF = ^LoadF;

//static const char *getF (lua_State *L, void *ud, size_t *size)
function getF(const L: Plua_State; const ud: Pointer; var size: SizeUInt): PChar;
var
  lf: PLoadF;
begin
  lf := ud;
  //(void)L;  //* not used */
  if (lf^.n > 0) then  //* are there pre-read characters to be read? */
  begin
    size := lf^.n;  //* return them (chars already in buffer) */
    lf^.n := 0;  //* no more pre-read characters */
  end
  else  //* read a block from file */
  begin
    (* 'fread' can return > 0 *and* set the EOF flag. If next call to
       'getF' called 'fread', it might still wait for user input.
       The next check avoids this problem. *)
    if (fEof(lf^.f)) then Exit(Nil);
    size := fRead(lf^.f, lf^.buff[0], sizeof(lf^.buff)); //* read block */
  end;
  Result := @(lf^.buff[0]);
end;


//static int errfile (lua_State *L, const char *what, int fnameindex)
function errfile(const L: Plua_State; const what: PChar; const fnameindex: Integer): Integer;
var
  serr, filename: PChar;
begin
  serr := strerror(errno);
  filename := lua_tostring(L, fnameindex) + 1;
  lua_pushfstring(L, 'cannot %s %s: %s', [what, filename, serr]);
  lua_remove(L, fnameindex);
  Result := LUA_ERRFILE;
end;


//static int skipBOM (LoadF *lf)
function skipBOM(var lf: LoadF): Integer;
var
  p: PChar;
  c: Integer;
begin
  p := #$EF#$BB#$BF;//"\xEF\xBB\xBF";  /* UTF-8 BOM mark */
  lf.n := 0;
  repeat
    c := getc(lf.f);
    if (c = EOF) or (c <> ord(p^)) then
      Exit(c);
    lf.buff[lf.n] := chr(c);  //* to be read by the parser */
    inc(lf.n);
  until (p^ = #0);
  lf.n := 0;  //* prefix matched; discard it */
  Result := getc(lf.f);  //* return next character */
end;


(*
** reads the first character of file 'f' and skips an optional BOM mark
** in its beginning plus its first line if it starts with '#'. Returns
** true if it skipped the first line.  In any case, '*cp' has the
** first "valid" character of the file (after the optional BOM and
** a first-line comment).
*)
//static int skipcomment (LoadF *lf, int *cp)
function skipcomment(var lf: LoadF; out cp: Integer): Boolean;
var
  c: Integer;
begin
  c := skipBOM(lf);
  cp := c;
  if (c = ord('#')) then  //* first line is a comment (Unix exec. file)? */
  begin
    repeat  //* skip first line */
      c := getc(lf.f);
    until (c = EOF) or (c = 13);
    cp := getc(lf.f);  //* skip end-of-line, if present */
    Result := true;  //* there was a comment */
  end
  else Result := 0;  //* no comment */
end;


function luaL_loadfilex(const L: Plua_State; const filename, mode: PChar): Integer;
var
  lf: LoadF;
  status, readstatus: Integer;
  c: Integer;
  fnameindex: Integer;
begin
  //int status;
  fnameindex := lua_gettop(L) + 1;  //* index of filename on the stack */
  if (filename = Nil) then
  begin
    lua_pushliteral(L, '=stdin');
    lf.f := pStdIn();
  end
  else
  begin
    lua_pushfstring(L, '@%s', [filename]);
    lf.f := fopen(filename, 'r');
    if (lf.f = Nil) then
      exit( errfile(L, 'open', fnameindex) );
  end;
  if (skipcomment(lf, c)) then //* read initial portion */
  begin
    lf.buff[lf.n] := #13;  //* add line to correct line numbers */
    inc(lf.n);
  end;
  if (c = ord(LUA_SIGNATURE[0])) and (filename <> nil) then   //* binary file? */
  begin
    lf.f := freopen(filename, 'rb', lf.f);  //* reopen in binary mode */
    if (lf.f = Nil) then Exit( errfile(L, 'reopen', fnameindex) );
    skipcomment(lf, c);  //* re-read initial portion */
  end;
  if (c <> EOF) then
  begin
    lf.buff[lf.n] := chr(c);  //* 'c' is the first character of the stream */
    inc(lf.n);
  end;
  status := lua_load(L, @getF, @lf, lua_tostring(L, -1), mode);
  readstatus := ferror(lf.f);
  if (filename <> nil) then fclose(lf.f);  //* close file (even in case of errors) */
  if (readstatus <> 0) then
  begin
    lua_settop(L, fnameindex);  //* ignore results from 'lua_load' */
    exit( errfile(L, 'read', fnameindex) );
  end;
  lua_remove(L, fnameindex);
  Result := status;
  //return status;
end;

//#define luaL_loadfile(L,f)      luaL_loadfilex(L,f,NULL)
function luaL_loadfile(const L: Plua_State; const f: PChar): Integer;
begin
  Result := luaL_loadfilex(L,f,nil);
end;

type
  LoadS = record
    s: Pchar;
    size: SizeUInt;
  end;
  PLoadS = ^LoadS;

//static const char *getS (lua_State *L, void *ud, size_t *size)
function getS(const L: Plua_State; const ud: Pointer; var size: SizeUInt): PChar;
var
  ls: PLoadS;
begin
  ls := ud;
  //(void)L;  //* not used */
  if (ls^.size = 0) then
    Exit(Nil);
  size := ls^.size;
  ls^.size := 0;
  Result := ls^.s;
end;

function luaL_loadbufferx(const L: Plua_State; const buff: PChar; const size: SizeUInt;
  const name, mode: PChar): Integer;
var
  ls: LoadS;
begin
  ls.s := buff;
  ls.size := size;
  Result := lua_load(L, @getS, @ls, name, mode);
end;

function luaL_loadstring(const L: Plua_State; const s: PChar): Integer;
begin
  Result := luaL_loadbuffer(L, s, strlen(s), s);
end;

//static void *l_alloc (void *ud, void *ptr, size_t osize, size_t nsize)
function l_alloc(ud: Pointer; ptr: Pointer; osize: SizeUInt; nsize: SizeUInt): Pointer;
var
  newptr: Pointer;
begin
  //(void)ud; (void)osize;  /* not used */
  if (nsize = 0) then
  begin
    Freemem(ptr);
    Result := Nil;
  end
  else   //* cannot fail when shrinking a block */
  begin
    newptr := ReAllocMem(ptr, nsize);
    if (newptr = Nil) and (ptr <> Nil) and (nsize <= osize) then
      Result := ptr  //* keep the original block */
    else  //* no fail or not shrinking */
      Result := newptr;  //* use the new block */
  end;
end;

//static int panic (lua_State *L)
function panic(const L: Plua_State): Integer; cdecl;
begin
  lua_writestringerror('PANIC: unprotected error in call to Lua API (%s)'#13,
                        [lua_tostring(L, -1)]);
  Result := 0;  //* return to Lua to abort */
end;

function luaL_newstate(): Plua_State;
begin
  Result := lua_newstate(@l_alloc, Nil);
  if (Result <> nil) then lua_atpanic(Result, @panic);
end;

function luaL_len(const L: Plua_State; const idx: Integer): lua_Integer;
var
  isnum: lu_int;
begin
  //lua_Integer l;
  lua_len(L, idx);
  Result := lua_tointegerx(L, -1, @isnum);
  if (isnum = 0) then
    luaL_error(L, 'object length is not an integer');
  lua_pop(L, 1);  //* remove object */
  //return l;
end;

function luaL_gsub(const L: Plua_State; s, p, r: PChar): PChar;
var
  wild: PChar;
  len: SizeUInt;
  b: luaL_Buffer;
begin
  len := strlen(p);
  luaL_buffinit(L, b);
  wild := strpos(s, p);
  while (wild <> Nil) do
  begin
    luaL_addlstring(b, s, wild - s);  //* push prefix */
    luaL_addstring(b, r);  //* push replacement in place of pattern */
    s := wild + len;  //* continue after 'p' */
    wild := strpos(s, p);
  end;
  luaL_addstring(b, s);  //* push last suffix */
  luaL_pushresult(b);
  Result := lua_tostring(L, -1);
end;

(*
** set functions from list 'ls' into table at top - 'nup'; each
** function gets the 'nup' elements at the top as upvalues.
** Returns with only the table at the stack.
*)
procedure luaL_setfuncs(const L: Plua_State; ls: PluaL_Reg; const nup: Integer);
var
  i: Integer;
begin
  luaL_checkstack(L, nup, 'too many upvalues');
  while (ls^.name <> Nil) do  //* fill the table with given functions */
  begin
    for i := 0 to nup - 1 do  //* copy upvalues to the top */
      lua_pushvalue(L, -nup);
    lua_pushcclosure(L, ls^.func, nup);  //* closure with those upvalues */
    lua_setfield(L, -(nup + 2), ls^.name);
    inc(ls);
  end;
  lua_pop(L, nup);  //* remove upvalues */
end;

(*
** ensure that stack[idx][fname] has a table and push that table
** into the stack
*)
function luaL_getsubtable(const L: Plua_State; idx: Integer; const fname: PChar): Integer;
begin
  if (lua_getfield(L, idx, fname) = LUA_TTABLE) then
    Result := 1  //* table already there */
  else
  begin
    lua_pop(L, 1);  //* remove previous result */
    idx := lua_absindex(L, idx);
    lua_newtable(L);
    lua_pushvalue(L, -1);  //* copy to be left at top */
    lua_setfield(L, idx, fname);  //* assign new table to field */
    Result := 0;  //* false, because did not find table there */
  end;
end;

procedure luaL_traceback(const L, L1: Plua_State; const msg: PChar; level: Integer);
var
  ar: lua_Debug;
  top, last, n1 : Integer;
begin
  top := lua_gettop(L);
  last := lastlevel(L1);
  if (last - level) > (LEVELS1 + LEVELS2) then
    n1 := LEVELS1
  else
    n1 := -1;
  if (msg <> nil) then
    lua_pushfstring(L, '%s'#13, [msg]);
  luaL_checkstack(L, 10, Nil);
  lua_pushliteral(L, 'stack traceback:');
  while (lua_getstack(L1, level, @ar) <> 0) do
  begin
    inc(level);
    if (n1 = 0) then  //* too many levels? */
    begin
      dec(n1);
      lua_pushliteral(L, #13#9'...');  //* add a '...' */
      level := last - LEVELS2 + 1;  //* and skip to last ones */
    end
    else
    begin
      dec(n1);
      lua_getinfo(L1, 'Slnt', @ar);
      lua_pushfstring(L, #13#9'%s:', [ar.short_src]);
      if (ar.currentline > 0) then
        lua_pushfstring(L, '%d:', [ar.currentline]);
      lua_pushliteral(L, ' in ');
      pushfuncname(L, @ar);
      if (ar.istailcall <> #0) then
        lua_pushliteral(L, #13#9'(...tail calls...)');
      lua_concat(L, lua_gettop(L) - top);
    end;
  end;
  lua_concat(L, lua_gettop(L) - top);
end;

(*
** Stripped-down 'require': After checking "loaded" table, calls 'openf'
** to open a module, registers the result in 'package.loaded' table and,
** if 'glb' is true, also registers the result in the global table.
** Leaves resulting module on the top.
*)
procedure luaL_requiref(const L: Plua_State; const modname: PChar; const openf: lua_CFunction;
  const glb: Integer);
begin
  luaL_getsubtable(L, LUA_REGISTRYINDEX, LUA_LOADED_TABLE);
  lua_getfield(L, -1, modname);  //* LOADED[modname] */
  if (lua_toboolean(L, -1) = 0) then  //* package not already loaded? */
  begin
    lua_pop(L, 1);  //* remove field */
    lua_pushcfunction(L, openf);
    lua_pushstring(L, modname);  //* argument to open function */
    lua_call(L, 1, 1);  //* call 'openf' to open module */
    lua_pushvalue(L, -1);  //* make copy of module (call result) */
    lua_setfield(L, -3, modname);  //* LOADED[modname] = module */
  end;
  lua_remove(L, -2); //* remove LOADED table */
  if (glb <> 0) then
  begin
    lua_pushvalue(L, -1);  //* copy of module */
    lua_setglobal(L, modname);  //* _G[modname] = module */
  end;
end;

//#define luaL_newlibtable(L,l)   \
//  lua_createtable(L, 0, sizeof(l)/sizeof((l)[0]) - 1)
procedure luaL_newlibtable(const L: Plua_State; const l_: array of luaL_Reg);
begin
  //lua_createtable(L, 0, length(l_) - 1);
  lua_createtable(L, 0, high(l_));
end;

//#define luaL_newlib(L,l)  \
//  (luaL_checkversion(L), luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))
procedure luaL_newlib(const L: Plua_State; const l_: array of luaL_Reg);
begin
  luaL_checkversion(L);
  luaL_newlibtable(L,l_);
  luaL_setfuncs(L,l_,0);
end;

//#define luaL_argcheck(L, cond,arg,extramsg)     \
//                ((void)((cond) || luaL_argerror(L, (arg), (extramsg))))
procedure luaL_argcheck(const L: Plua_State; const cond: Boolean; const arg: Integer;
  const extramsg: PChar);
begin
  if cond then
    luaL_argerror(L, arg, extramsg);
end;

//#define luaL_checkstring(L,n)   (luaL_checklstring(L, (n), NULL))
function luaL_checkstring(const L: Plua_State; const n: Integer): PChar;
begin
  Result := luaL_checklstring(L, n, nil);
end;

//#define luaL_optstring(L,n,d)   (luaL_optlstring(L, (n), (d), NULL))
function luaL_optstring(const L: Plua_State; const n: Integer; const d: PChar): PChar;
begin
  Result := luaL_optlstring(L, n, d, nil);
end;

//#define luaL_typename(L,i)      lua_typename(L, lua_type(L,(i)))
function luaL_typename(const L: Plua_State; const i: Integer): PChar;
begin
  Result := lua_typename(L, lua_type(L,i));
end;

//#define luaL_dofile(L, fn) \
//        (luaL_loadfile(L, fn) || lua_pcall(L, 0, LUA_MULTRET, 0))
function luaL_dofile(const L: Plua_State; const fn: PChar): Integer;
begin
  Result := luaL_loadfile(L, fn);
  if Result <> 0 then
    Result := lua_pcall(L, 0, LUA_MULTRET, 0);
end;

//#define luaL_dostring(L, s) \
//        (luaL_loadstring(L, s) || lua_pcall(L, 0, LUA_MULTRET, 0))
function luaL_dostring(const L: Plua_State; const s: PChar): Integer;
begin
  Result := luaL_loadstring(L, s);
  if Result <> 0 then
    Result := lua_pcall(L, 0, LUA_MULTRET, 0);
end;

//#define luaL_getmetatable(L,n)  (lua_getfield(L, LUA_REGISTRYINDEX, (n)))
function luaL_getmetatable(const L: Plua_State; const n: PChar): Integer;
begin
  Result := lua_getfield(L, LUA_REGISTRYINDEX, n);
end;

procedure luaL_opt(const L: Plua_State; var f, n, d);
begin

end;

//#define luaL_loadbuffer(L,s,sz,n)       luaL_loadbufferx(L,s,sz,n,NULL)
function luaL_loadbuffer(const L: Plua_State; const s: PChar; const sz: SizeUInt;
  const n: PChar): Integer;
begin
  Result := luaL_loadbufferx(L,s,sz,n,nil);
end;

//#define luaL_addchar(B,c) \
//  ((void)((B)->n < (B)->size || luaL_prepbuffsize((B), 1)), \
//   ((B)->b[(B)->n++] = (c)))
procedure luaL_addchar(var B: luaL_Buffer; const c: Char);
begin
  if B.n < B.size then
    luaL_prepbuffsize(B, 1);
  B.b[B.n] := c;
  inc(B.n);
end;

//#define luaL_addsize(B,s)       ((B)->n += (s))
procedure luaL_addsize(var B: luaL_Buffer; const s: SizeUInt);
begin
  B.n += s;
end;

procedure luaL_buffinit(const L: Plua_State; out B: luaL_Buffer);
begin
  B.L := L;
  B.b := @B.initb[0];
  B.n := 0;
  B.size := LUAL_BUFFERSIZE;
end;

//static void *resizebox (lua_State *L, int idx, size_t newsize)
function resizebox(const L: Plua_State; const idx: Integer; const newsize: SizeUInt): Pointer;
var
  ud: Pointer;
  allocf: lua_Alloc;
  box: PUBox;
begin
  allocf := lua_getallocf(L, @ud);
  box := lua_touserdata(L, idx);
  Result := allocf(ud, box^.box, box^.bsize, newsize);
  if (Result = Nil) and (newsize > 0) then  //* allocation error? */
  begin
    resizebox(L, idx, 0);  //* free buffer */
    luaL_error(L, 'not enough memory for buffer allocation');
  end;
  box^.box := Result;
  box^.bsize := newsize;
end;


//static int boxgc (lua_State *L)
function boxgc(const L: Plua_State): Integer; cdecl;
begin
  resizebox(L, 1, 0);
  Result := 0;
end;


//static void *newbox (lua_State *L, size_t newsize)
function newbox(const L: Plua_State; const newsize: SizeUInt): Pointer;
var
  box: PUBox;
begin
  box := lua_newuserdata(L, sizeof(UBox));
  box^.box := Nil;
  box^.bsize := 0;
  if (luaL_newmetatable(L, 'LUABOX') <> 0) then //* creating metatable? */
  begin
    lua_pushcfunction(L, @boxgc);
    lua_setfield(L, -2, '__gc');  //* metatable.__gc = boxgc */
  end;
  lua_setmetatable(L, -2);
  Result := resizebox(L, -1, newsize);
end;


(*
** check whether buffer is using a userdata on the stack as a temporary
** buffer
*)
//#define buffonstack(B)	((B)->b != (B)->initb)
function buffonstack(var B: luaL_Buffer): Boolean;
begin
  Result := (B.b <> @(B.initb[0]));
end;

function luaL_prepbuffsize(var B: luaL_Buffer; const sz: SizeUInt): PChar;
var
  L: Plua_State;
  newbuff: PChar;
  newsize: SizeUInt;
begin
  L := B.L;
  if (B.size - B.n) < sz then  //* not enough space? */
  begin
    newsize := B.size * 2;  //* double buffer size */
    if (newsize - B.n) < sz then //* not big enough? */
      newsize := B.n + sz;
    if (newsize < B.n) or ((newsize - B.n) < sz) then
      luaL_error(L, 'buffer too large');
    //* create larger buffer */
    if (buffonstack(B)) then
      newbuff := resizebox(L, -1, newsize)
    else  //* no buffer yet */
    begin
      newbuff := newbox(L, newsize);
      memcpy(newbuff, B.b, B.n * sizeof(char));  //* copy original content */
    end;
    B.b := newbuff;
    B.size := newsize;
  end;
  Result := @(B.b[B.n]);
end;

procedure luaL_addlstring(var B: luaL_Buffer; const s: PChar; const l: SizeUInt);
var
  b_: PChar;
begin
  if (l > 0) then //* avoid 'memcpy' when 's' can be NULL */
  begin
    b_ := luaL_prepbuffsize(B, l);
    memcpy(b_, s, l * sizeof(char));
    luaL_addsize(B, l);
  end;
end;

procedure luaL_addstring(var B: luaL_Buffer; const s: PChar);
begin
  luaL_addlstring(B, s, strlen(s));
end;

procedure luaL_addvalue(var B: luaL_Buffer);
var
  L: Plua_State;
  len: SizeUInt;
  s: PChar;
begin
  L := B.L;
  s := lua_tolstring(L, -1, @len);
  if (buffonstack(B)) then
    lua_insert(L, -2);  //* put value below buffer */
  luaL_addlstring(B, s, len);
  if (buffonstack(B)) then //* remove value */
    lua_remove(L, -2)
  else
    lua_remove(L, -1);
end;

procedure luaL_pushresult(var B: luaL_Buffer);
var
  L: Plua_State;
begin
  L := B.L;
  lua_pushlstring(L, B.b, B.n);
  if (buffonstack(B)) then
  begin
    resizebox(L, -2, 0);  //* delete old buffer */
    lua_remove(L, -2);  //* remove its header from the stack */
  end;
end;

procedure luaL_pushresultsize(var B: luaL_Buffer; const sz: SizeUInt);
begin
  luaL_addsize(B, sz);
  luaL_pushresult(B);
end;

function luaL_buffinitsize(const L: Plua_State; var B: luaL_Buffer; const sz: SizeUInt): PChar;
begin
  luaL_buffinit(L, B);
  Result := luaL_prepbuffsize(B, sz);
end;

//#define luaL_prepbuffer(B)      luaL_prepbuffsize(B, LUAL_BUFFERSIZE)
function luaL_prepbuffer(var B: luaL_Buffer): PChar;
begin
  Result := luaL_prepbuffsize(B, LUAL_BUFFERSIZE);
end;

(*
** =======================================================
** Compatibility with 5.1 module functions
** =======================================================
*)
{$ifdef LUA_COMPAT_MODULE}

//static const char *luaL_findtable (lua_State *L, int idx,
//                                   const char *fname, int szhint)
function luaL_findtable(const L: Plua_State; const idx: Integer;
  fname: PChar; const szhint: Integer): PChar;
var
  e: PChar;
begin
  if (idx <> 0) then lua_pushvalue(L, idx);
  repeat
    e := strscan(fname, '.');
    if (e = Nil) then
      e := fname + strlen(fname);
    lua_pushlstring(L, fname, e - fname);
    if (lua_rawget(L, -2) = LUA_TNIL) then  //* no such field? */
    begin
      lua_pop(L, 1);  //* remove this nil */
      if e^ = '.' then
        lua_createtable(L, 0, 1) //* new table for field */
      else
        lua_createtable(L, 0, szhint); //* new table for field */
      lua_pushlstring(L, fname, e - fname);
      lua_pushvalue(L, -2);
      lua_settable(L, -4);  //* set new table into field */
    end
    else if (not lua_istable(L, -1)) then  //* field has a non-table value? */
    begin
      lua_pop(L, 2);  //* remove table and value */
      Exit(fname);  //* return problematic part of the name */
    end;
    lua_remove(L, -2);  //* remove previous table */
    fname := e + 1;
  until (e^ <> '.');
  Result := nil;
end;


(*
** Count number of elements in a luaL_Reg list.
*)
//static int libsize (const luaL_Reg *l)
function libsize(l: PluaL_Reg): Integer;
begin
  //int size = 0;
  Result := 0;
  while (l<>nil) and (l^.name <> nil) do
  begin
    inc(Result);
    inc(l);
  end;
  //return size;
end;


(*
** Find or create a module table with a given name. The function
** first looks at the LOADED table and, if that fails, try a
** global variable with that name. In any case, leaves on the stack
** the module table.
*)
procedure luaL_pushmodule(const L: Plua_State; const modname: PChar; const sizehint: Integer);
begin
  luaL_findtable(L, LUA_REGISTRYINDEX, LUA_LOADED_TABLE, 1);
  if (lua_getfield(L, -1, modname) <> LUA_TTABLE) then  //* no LOADED[modname]? */
  begin
    lua_pop(L, 1);  //* remove previous result */
    //* try global variable (and create one if it does not exist) */
    lua_pushglobaltable(L);
    if (luaL_findtable(L, 0, modname, sizehint) <> nil) then
      luaL_error(L, 'name conflict for module "%s"', [modname]);
    lua_pushvalue(L, -1);
    lua_setfield(L, -3, modname);  //* LOADED[modname] = new table */
  end;
  lua_remove(L, -2);  //* remove LOADED table */
end;

procedure luaL_openlib(const L: Plua_State; const libname: PChar; const ls: PluaL_Reg;
  const nup: Integer);
begin
  luaL_checkversion(L);
  if (libname <> nil) then
  begin
    luaL_pushmodule(L, libname, libsize(ls));  //* get/create library table */
    lua_insert(L, -(nup + 1));  //* move library table to below upvalues */
  end;
  if (ls <> nil) then
    luaL_setfuncs(L, ls, nup)
  else
    lua_pop(L, nup);  //* remove upvalues */
end;

//#define luaL_register(L,n,l)    (luaL_openlib(L,(n),(l),0))
procedure luaL_register(const L: Plua_State; const n: PChar; const ls: PluaL_Reg);
begin
  luaL_openlib(L,n,ls,0);
end;
{$endif LUA_COMPAT_MODULE}

//#define lua_writestring(s,l)   fwrite((s), sizeof(char), (l), stdout)
procedure lua_writestring(const s: PChar; const l: Integer);
var
  str: String;
begin
  SetLength(str, l);
  Move(s^, str[1], l);
  Write(StdOut, str);
end;

//#define lua_writeline()        (lua_writestring("\n", 1), fflush(stdout))
procedure lua_writeline();
begin
  WriteLn(StdOut);
  Flush(StdOut);
end;

//#define lua_writestringerror(s,p) \
//        (fprintf(stderr, (s), (p)), fflush(stderr))
procedure lua_writestringerror(const s: PChar; const p: array of const);
var
  str: string;
begin
  str := Format(s, p);
  Write(StdErr, str);
  Flush(StdErr);
end;

{$ifdef LUA_COMPAT_APIINTCASTS}
//#define luaL_checkunsigned(L,a) ((lua_Unsigned)luaL_checkinteger(L,a))
function luaL_checkunsigned(const L: Plua_State; const arg: Integer): lua_Unsigned;
begin
  Result := lua_Unsigned(luaL_checkinteger(L,arg));
end;

//#define luaL_optunsigned(L,a,d) \
//        ((lua_Unsigned)luaL_optinteger(L,a,(lua_Integer)(d)))
function luaL_optunsigned(const L: Plua_State; const arg: Integer;
  const def: lua_Unsigned): lua_Unsigned;
begin
  Result := lua_Unsigned(luaL_optinteger(L,arg,lua_Integer(def)));
end;

//#define luaL_checkint(L,n)      ((int)luaL_checkinteger(L, (n)))
function luaL_checkint(const L: Plua_State; const arg: Integer): Integer;
begin
  Result := luaL_checkinteger(L, arg);
end;

//#define luaL_optint(L,n,d)      ((int)luaL_optinteger(L, (n), (d)))
function luaL_optint(const L: Plua_State; const arg: Integer; const def: Integer): Integer;
begin
  Result := luaL_optinteger(L, arg, def);
end;

//#define luaL_checklong(L,n)     ((long)luaL_checkinteger(L, (n)))
function luaL_checklong(const L: Plua_State; const arg: Integer): LongInt;
begin
  Result := luaL_checkinteger(L, arg);
end;

//#define luaL_optlong(L,n,d)     ((long)luaL_optinteger(L, (n), (d)))
function luaL_optlong(const L: Plua_State; const arg: Integer; const def: LongInt): LongInt;
begin
  Result := luaL_optinteger(L, arg, def);
end;
{$endif LUA_COMPAT_APIINTCASTS}

end.

