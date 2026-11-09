(*
** Configurable defines
** These defines can also be used in command line
**
** For configurable constants see fplua_common.pas
*)

(*
@@ FPLUA_32BITS enables Lua with 32-bit integers and 32-bit floats.
*)
{-$define FPLUA_32BITS}

(*
@@ FPLUA_INT_{TYPE} defines the type for Lua integers.
@@ FPLUA_FLOAT_{TYPE} defines the type for Lua floats.
** Lua should work fine with any mix of these options.
** The usual configurations are 64-bit integers and 'double' (the default),
** and 32-bit integers and 'float' (for restricted platforms).
**
** Default is defined in fplua_config_check.inc
*)
{-$define FPLUA_INT_64BIT} // default
{-$define FPLUA_INT_32BIT} // default when FPLUA_32BITS is defined
{-$define FPLUA_INT_16BIT} // not implemented

{-$define FPLUA_FLOAT_SINGLE} // default when FPLUA_32BITS is defined
{-$define FPLUA_FLOAT_DOUBLE} // default
{-$define FPLUA_FLOAT_EXTENDED}

(*
@@ LUA_NOCVTN2S/LUA_NOCVTS2N control how Lua performs some
** coercions. Define LUA_NOCVTN2S to turn off automatic coercion from
** numbers to strings. Define LUA_NOCVTS2N to turn off automatic
** coercion from strings to numbers.
*)
{-$define LUA_NOCVTN2S}
{-$define LUA_NOCVTS2N}

(*
@@ FPLUA_ASSERT enable internal assertions for in-house debugging.
** Set fplua_assert callback procedure variable from fplua_common.
*)
{-$define FPLUA_ASSERT}

(*
@@ LUA_USE_APICHECK turns on several consistency checks on the C API.
** Define it as a help when debugging C code.
** Set fplua_apicheck callback procedure variable from fplua_common.
*)
{-$define LUA_USE_APICHECK}

(*
@@ LUA_COMPAT_APIINTCASTS controls the presence of macros for
** manipulating other integer types (lua_pushunsigned, lua_tounsigned,
** luaL_checkint, luaL_checklong, etc.)
*)
{-$define LUA_COMPAT_APIINTCASTS}

{$define FPLUA_EX_LOCK}
{$define FPLUA_EX_THREADYEILD}
{$define FPLUA_EX_THREAD_ACTIONS}






