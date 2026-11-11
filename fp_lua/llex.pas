unit llex;
(*
** Lexical Analyzer
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types, fplua_lp_common, lzio;

// TODO
//LUAI_FUNC void luaX_init (lua_State *L);
//LUAI_FUNC void luaX_setinput (lua_State *L, LexState *ls, ZIO *z,
//                              TString *source, int firstchar);
//LUAI_FUNC TString *luaX_newstring (LexState *ls, const char *str, size_t l);
//LUAI_FUNC void luaX_next (LexState *ls);
//LUAI_FUNC int luaX_lookahead (LexState *ls);
//LUAI_FUNC l_noret luaX_syntaxerror (LexState *ls, const char *s);
//LUAI_FUNC const char *luaX_token2str (LexState *ls, int token);
procedure luaX_init(const L: Plua_State);
procedure luaX_setinput(const L: Plua_State; const ls: PLexState; const z: PZIO;
  const source: PTString; const firstchar: Integer);
function luaX_newstring(const ls: PLexState; const str: PChar; const l_: SizeUInt): PTString;
procedure luaX_next(const ls: PLexState);
function luaX_lookahead(const ls: PLexState): Integer;
procedure luaX_syntaxerror(const ls: PLexState; const s: PChar);
function luaX_token2str(const ls: PLexState; const token: Integer): PChar;

implementation

procedure luaX_init(const L: Plua_State);
begin

end;

procedure luaX_setinput(const L: Plua_State; const ls: PLexState; const z: PZIO;
  const source: PTString; const firstchar: Integer);
begin

end;

function luaX_newstring(const ls: PLexState; const str: PChar; const l_: SizeUInt): PTString;
begin

end;

procedure luaX_next(const ls: PLexState);
begin

end;

function luaX_lookahead(const ls: PLexState): Integer;
begin

end;

procedure luaX_syntaxerror(const ls: PLexState; const s: PChar);
begin

end;

function luaX_token2str(const ls: PLexState; const token: Integer): PChar;
begin

end;

end.

