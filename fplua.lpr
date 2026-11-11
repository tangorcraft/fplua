program fplua;

(*
** Free pascal implementation of Lua stand-alone interpreter
*)

{$mode objfpc}{$H+}
{$apptype console}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, fp_lua, lopcodes, fplua_common, fplua_types, lobject, lfunc, lstate, ltm, lzio, lmem,
  ldo, lctype, lgc, lapi, lauxlib, llex, fplua_lp_common, lparser, lcode;

begin

end.

