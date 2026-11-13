unit lualib;
(*
** Lua standard libraries
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common;

(* version suffix for environment variable names *)
const
  LUA_VERSUFFIX       = '_' + LUA_VERSION_MAJOR + '_' + LUA_VERSION_MINOR;


//LUAMOD_API int (luaopen_base) (lua_State *L);
function luaopen_base(const L: Plua_State): Integer;

const LUA_COLIBNAME = 'coroutine';
//LUAMOD_API int (luaopen_coroutine) (lua_State *L);
function luaopen_coroutine(const L: Plua_State): Integer;

const LUA_TABLIBNAME = 'table';
//LUAMOD_API int (luaopen_table) (lua_State *L);
function luaopen_table(const L: Plua_State): Integer;

const LUA_IOLIBNAME = 'io';
//LUAMOD_API int (luaopen_io) (lua_State *L);
function luaopen_io(const L: Plua_State): Integer;

const LUA_OSLIBNAME = 'os';
//LUAMOD_API int (luaopen_os) (lua_State *L);
function luaopen_os(const L: Plua_State): Integer;

const LUA_STRLIBNAME = 'string';
//LUAMOD_API int (luaopen_string) (lua_State *L);
function luaopen_string(const L: Plua_State): Integer;

const LUA_UTF8LIBNAME = 'utf8';
//LUAMOD_API int (luaopen_utf8) (lua_State *L);
function luaopen_utf8(const L: Plua_State): Integer;

const LUA_BITLIBNAME = 'bit32';
//LUAMOD_API int (luaopen_bit32) (lua_State *L);
function luaopen_bit32(const L: Plua_State): Integer;

const LUA_MATHLIBNAME = 'math';
//LUAMOD_API int (luaopen_math) (lua_State *L);
function luaopen_math(const L: Plua_State): Integer;

const LUA_DBLIBNAME = 'debug';
//LUAMOD_API int (luaopen_debug) (lua_State *L);
function luaopen_debug(const L: Plua_State): Integer;

const LUA_LOADLIBNAME = 'package';
//LUAMOD_API int (luaopen_package) (lua_State *L);
function luaopen_package(const L: Plua_State): Integer;


///* open all previous libraries */
//LUALIB_API void (luaL_openlibs) (lua_State *L);
procedure luaL_openlibs(const L: Plua_State);


//#if !defined(lua_assert)
//#define lua_assert(x) ((void)0)
//#endif

implementation

function luaopen_base(const L: Plua_State): Integer;
begin

end;

function luaopen_coroutine(const L: Plua_State): Integer;
begin

end;

function luaopen_table(const L: Plua_State): Integer;
begin

end;

function luaopen_io(const L: Plua_State): Integer;
begin

end;

function luaopen_os(const L: Plua_State): Integer;
begin

end;

function luaopen_string(const L: Plua_State): Integer;
begin

end;

function luaopen_utf8(const L: Plua_State): Integer;
begin

end;

function luaopen_bit32(const L: Plua_State): Integer;
begin

end;

function luaopen_math(const L: Plua_State): Integer;
begin

end;

function luaopen_debug(const L: Plua_State): Integer;
begin

end;

function luaopen_package(const L: Plua_State): Integer;
begin

end;

procedure luaL_openlibs(const L: Plua_State);
begin

end;

end.

