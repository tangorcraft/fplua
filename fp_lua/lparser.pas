unit lparser;
(*
** Lua Parser
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types, fplua_lp_common, lzio;


// TODO
//LUAI_FUNC LClosure *luaY_parser (lua_State *L, ZIO *z, Mbuffer *buff,
//                                 Dyndata *dyd, const char *name, int firstchar);
function luaY_parser(const L: Plua_State; const z: PZIO; const buff: PMbuffer;
  const dyd: PDyndata; const name: PChar; const firstchar: Integer): LClosure;

implementation

function luaY_parser(const L: Plua_State; const z: PZIO; const buff: PMbuffer;
  const dyd: PDyndata; const name: PChar; const firstchar: Integer): LClosure;
begin

end;

end.

