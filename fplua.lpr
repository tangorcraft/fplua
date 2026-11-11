program fplua;

(*
** Free pascal implementation of Lua stand-alone interpreter
*)

{$mode objfpc}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, fp_lua, lopcodes, fplua_common, fplua_types, lobject, lfunc, lstate, ltm, lzio, lmem,
  ldo, lctype, lgc, lapi, lauxlib;

begin

end.

