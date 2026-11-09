(*
** Global defines and macros, this file is included in every FP-Lua unit
** Conditional compilation code should be put only in fplua_common.pas file as much as possible
** See fplua_config.inc for confuguring FP-Lua
*)

{$ifndef LUA_DEFINES}
{$define LUA_DEFINES}
{$mode ObjFPC}

{$define DEBUG}
{$define HARDSTACKTESTS}
{$define HARDMEMTESTS}

{$inline on}

{$i fplua_config.inc}
{$i fplua_config_check.inc}

{$endif}
