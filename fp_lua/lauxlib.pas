unit lauxlib;
(*
** Opcodes for Lua virtual machine
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types;

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
function luaL_getmetafield(const L: Plua_State; const obj: Integer; const e: PChar): Integer;
function luaL_callmeta(const L: Plua_State; const obj: Integer; const e: PChar): Integer;
function luaL_tolstring(const L: Plua_State; const idx: Integer; const len: PSizeUInt): PChar;
function luaL_argerror(const L: Plua_State; const arg: Integer; const extramsg: PChar): Integer;
function luaL_checklstring(const L: Plua_State; const arg: Integer; const l_: PSizeUInt): PChar;
function luaL_optlstring(const L: Plua_State; const arg: Integer; const def: PChar;
  const l_: PSizeUInt): PChar;
function luaL_checknumber(const L: Plua_State; const arg: Integer): lua_Number;
function luaL_optnumber(const L: Plua_State; const arg: Integer;
  const def: lua_Number): lua_Number;
function luaL_checkinteger(const L: Plua_State; const arg: Integer): lua_Integer;
function luaL_optinteger(const L: Plua_State; const arg: Integer;
  const def: lua_Integer): lua_Integer;

//LUALIB_API void (luaL_checkstack) (lua_State *L, int sz, const char *msg);
//LUALIB_API void (luaL_checktype) (lua_State *L, int arg, int t);
//LUALIB_API void (luaL_checkany) (lua_State *L, int arg);
procedure luaL_checkstack(const L: Plua_State; const sz: Integer; const msg: PChar);
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
procedure luaL_where(const L: Plua_State; const lvl: Integer);
function luaL_error(const L: Plua_State; const fmt: PChar; const args: array of const): Integer;

//LUALIB_API int (luaL_checkoption) (lua_State *L, int arg, const char *def,
//                                   const char *const lst[]);
function luaL_checkoption(const L: Plua_State; const arg: Integer; const def: PChar;
  const lst: array of PChar): Integer;

//LUALIB_API int (luaL_fileresult) (lua_State *L, int stat, const char *fname);
//LUALIB_API int (luaL_execresult) (lua_State *L, int stat);
function luaL_fileresult(const L: Plua_State; const stat: Integer; const fname: PChar): Integer;
function luaL_execresult(const L: Plua_State; const stat: Integer): Integer;

(* predefined references *)
const
  LUA_NOREF     = (-2);
  LUA_REFNIL    = (-1);

//LUALIB_API int (luaL_ref) (lua_State *L, int t);
//LUALIB_API void (luaL_unref) (lua_State *L, int t, int ref);
function luaL_ref(const L: Plua_State; const t: Integer): Integer;
procedure luaL_unref(const L: Plua_State; const t, ref: Integer);

//LUALIB_API int (luaL_loadfilex) (lua_State *L, const char *filename,
//                                               const char *mode);
function luaL_loadfilex(const L: Plua_State; const filename, mode: PChar): Integer;

function luaL_loadfile(const L: Plua_State; const f: PChar): Integer;

//LUALIB_API int (luaL_loadbufferx) (lua_State *L, const char *buff, size_t sz,
                                   //const char *name, const char *mode);
//LUALIB_API int (luaL_loadstring) (lua_State *L, const char *s);
function luaL_loadbufferx(const L: Plua_State; const buff: PChar; const sz: SizeUInt;
  const name, mode: PChar): Integer;
function luaL_loadstring(const L: Plua_State; const s: PChar): Integer;

//LUALIB_API lua_State *(luaL_newstate) (void);
function luaL_newstate(): Plua_State;

//LUALIB_API lua_Integer (luaL_len) (lua_State *L, int idx);
function luaL_len(const L: Plua_State; const idx: Integer): lua_Integer;

//LUALIB_API const char *(luaL_gsub) (lua_State *L, const char *s, const char *p,
//                                                  const char *r);
function luaL_gsub(const L: Plua_State; const s, p, r: PChar): PChar;

//LUALIB_API void (luaL_setfuncs) (lua_State *L, const luaL_Reg *l, int nup);
procedure luaL_setfuncs(const L: Plua_State; const l_: PluaL_Reg; const nup: Integer);

//LUALIB_API int (luaL_getsubtable) (lua_State *L, int idx, const char *fname);
function luaL_getsubtable(const L: Plua_State; const idx: Integer; const fname: PChar): Integer;

//LUALIB_API void (luaL_traceback) (lua_State *L, lua_State *L1,
//                                  const char *msg, int level);
procedure luaL_traceback(const L, L1: Plua_State; const msg: PChar; const level: Integer);

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
procedure luaL_opt(const L: Plua_State); // stub declaration

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
procedure luaL_buffinit(const L: Plua_State; var B: luaL_Buffer);
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
  fplua_pFile = ^file;
  luaL_Stream = record
    f: fplua_pFile;  //* stream (NULL for incompletely created streams) */
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
procedure luaL_openlib(const L: Plua_State; const libname: PChar; const l_: PluaL_Reg;
  const nup: Integer);

procedure luaL_register(const L: Plua_State; const n: PChar; const l_: PluaL_Reg);

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

procedure luaL_checkversion_(const L: Plua_State; const ver: lua_Number; const sz: SizeUInt);
begin

end;

//#define luaL_checkversion(L)  \
//          luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES)
procedure luaL_checkversion(const L: Plua_State);
begin
  luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES);
end;

function luaL_getmetafield(const L: Plua_State; const obj: Integer; const e: PChar): Integer;
begin

end;

function luaL_callmeta(const L: Plua_State; const obj: Integer; const e: PChar): Integer;
begin

end;

function luaL_tolstring(const L: Plua_State; const idx: Integer; const len: PSizeUInt): PChar;
begin

end;

function luaL_argerror(const L: Plua_State; const arg: Integer; const extramsg: PChar): Integer;
begin

end;

function luaL_checklstring(const L: Plua_State; const arg: Integer; const l_: PSizeUInt): PChar;
begin

end;

function luaL_optlstring(const L: Plua_State; const arg: Integer; const def: PChar;
  const l_: PSizeUInt): PChar;
begin

end;

function luaL_checknumber(const L: Plua_State; const arg: Integer): lua_Number;
begin

end;

function luaL_optnumber(const L: Plua_State; const arg: Integer;
  const def: lua_Number): lua_Number;
begin

end;

function luaL_checkinteger(const L: Plua_State; const arg: Integer): lua_Integer;
begin

end;

function luaL_optinteger(const L: Plua_State; const arg: Integer;
  const def: lua_Integer): lua_Integer;
begin

end;

procedure luaL_checkstack(const L: Plua_State; const sz: Integer; const msg: PChar);
begin

end;

procedure luaL_checktype(const L: Plua_State; const arg, t: Integer);
begin

end;

procedure luaL_checkany(const L: Plua_State; const arg: Integer);
begin

end;

function luaL_newmetatable(const L: Plua_State; const tname: PChar): Integer;
begin

end;

procedure luaL_setmetatable(const L: Plua_State; const tname: PChar);
begin

end;

function luaL_testudata(const L: Plua_State; const ud: Integer; const tname: PChar): Pointer;
begin

end;

function luaL_checkudata(const L: Plua_State; const ud: Integer; const tname: PChar): Pointer;
begin

end;

procedure luaL_where(const L: Plua_State; const lvl: Integer);
begin

end;

function luaL_error(const L: Plua_State; const fmt: PChar; const args: array of const): Integer;
begin

end;

function luaL_checkoption(const L: Plua_State; const arg: Integer; const def: PChar;
  const lst: array of PChar): Integer;
begin

end;

function luaL_fileresult(const L: Plua_State; const stat: Integer; const fname: PChar): Integer;
begin

end;

function luaL_execresult(const L: Plua_State; const stat: Integer): Integer;
begin

end;

function luaL_ref(const L: Plua_State; const t: Integer): Integer;
begin

end;

procedure luaL_unref(const L: Plua_State; const t, ref: Integer);
begin

end;

function luaL_loadfilex(const L: Plua_State; const filename, mode: PChar): Integer;
begin

end;

//#define luaL_loadfile(L,f)      luaL_loadfilex(L,f,NULL)
function luaL_loadfile(const L: Plua_State; const f: PChar): Integer;
begin
  Result := luaL_loadfilex(L,f,nil);
end;

function luaL_loadbufferx(const L: Plua_State; const buff: PChar; const sz: SizeUInt;
  const name, mode: PChar): Integer;
begin

end;

function luaL_loadstring(const L: Plua_State; const s: PChar): Integer;
begin

end;

function luaL_newstate(): Plua_State;
begin

end;

function luaL_len(const L: Plua_State; const idx: Integer): lua_Integer;
begin

end;

function luaL_gsub(const L: Plua_State; const s, p, r: PChar): PChar;
begin

end;

procedure luaL_setfuncs(const L: Plua_State; const l_: PluaL_Reg; const nup: Integer);
begin

end;

function luaL_getsubtable(const L: Plua_State; const idx: Integer; const fname: PChar): Integer;
begin

end;

procedure luaL_traceback(const L, L1: Plua_State; const msg: PChar; const level: Integer);
begin

end;

procedure luaL_requiref(const L: Plua_State; const modname: PChar; const openf: lua_CFunction;
  const glb: Integer);
begin

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

procedure luaL_opt(const L: Plua_State);
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
  B.b[B.n] = c;
  inc(B.n);
end;

//#define luaL_addsize(B,s)       ((B)->n += (s))
procedure luaL_addsize(var B: luaL_Buffer; const s: SizeUInt);
begin
  B.n += s;
end;

procedure luaL_buffinit(const L: Plua_State; var B: luaL_Buffer);
begin

end;

function luaL_prepbuffsize(var B: luaL_Buffer; const sz: SizeUInt): PChar;
begin

end;

procedure luaL_addlstring(var B: luaL_Buffer; const s: PChar; const l: SizeUInt);
begin

end;

procedure luaL_addstring(var B: luaL_Buffer; const s: PChar);
begin

end;

procedure luaL_addvalue(var B: luaL_Buffer);
begin

end;

procedure luaL_pushresult(var B: luaL_Buffer);
begin

end;

procedure luaL_pushresultsize(var B: luaL_Buffer; const sz: SizeUInt);
begin

end;

function luaL_buffinitsize(const L: Plua_State; var B: luaL_Buffer; const sz: SizeUInt): PChar;
begin

end;

//#define luaL_prepbuffer(B)      luaL_prepbuffsize(B, LUAL_BUFFERSIZE)
function luaL_prepbuffer(var B: luaL_Buffer): PChar;
begin
  Result := luaL_prepbuffsize(B, LUAL_BUFFERSIZE);
end;

{$ifdef LUA_COMPAT_MODULE}
procedure luaL_pushmodule(const L: Plua_State; const modname: PChar; const sizehint: Integer);
begin

end;

procedure luaL_openlib(const L: Plua_State; const libname: PChar; const l_: PluaL_Reg;
  const nup: Integer);
begin

end;

//#define luaL_register(L,n,l)    (luaL_openlib(L,(n),(l),0))
procedure luaL_register(const L: Plua_State; const n: PChar; const l_: PluaL_Reg);
begin
  luaL_openlib(L,n,l_,0);
end;
{$endif}

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
{$endif}

end.

