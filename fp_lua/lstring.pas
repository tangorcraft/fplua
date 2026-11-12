unit lstring;
(*
** String table (keep all strings handled by Lua)
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types;

function sizelstring(const l: SizeUInt): SizeUInt;

function sizeludata(const l: SizeUInt): SizeUInt;
function sizeudata(const u: PUdata): SizeUInt;

// This routine requires string literal in parameter s
// but it is not possible to ensure this in pascal
function luaS_newliteral(const L: Plua_State; const s: string): PTString;

(*
** test whether a string is a reserved word
*)
function isreserved(const s: PTString): Boolean;

(*
** equality for short strings, which are always internalized
*)
function eqshrstr(const a, b: PTString): Boolean;

//LUAI_FUNC unsigned int luaS_hash (const char *str, size_t l, unsigned int seed);
function luaS_hash(const str: PChar; const l: SizeUInt; const seed: Cardinal): Cardinal;
//LUAI_FUNC unsigned int luaS_hashlongstr (TString *ts);
function luaS_hashlongstr(const ts: PTString): Cardinal;
//LUAI_FUNC int luaS_eqlngstr (TString *a, TString *b);
function luaS_eqlngstr(const a, b: PTString): Integer;
//LUAI_FUNC void luaS_resize (lua_State *L, int newsize);
procedure luaS_resize(const L: Plua_State; const newsize: Integer);
//LUAI_FUNC void luaS_clearcache (global_State *g);
procedure luaS_clearcache(const g: Pglobal_State);
//LUAI_FUNC void luaS_init (lua_State *L);
procedure luaS_init(const L: Plua_State);
//LUAI_FUNC void luaS_remove (lua_State *L, TString *ts);
procedure luaS_remove(const L: Plua_State; const ts: PTString);
//LUAI_FUNC Udata *luaS_newudata (lua_State *L, size_t s);
function luaS_newudata(const L: Plua_State; const s: SizeUInt): PUdata;
//LUAI_FUNC TString *luaS_newlstr (lua_State *L, const char *str, size_t l);
function luaS_newlstr(const L: Plua_State; const str: PChar; const l_: SizeUInt): PTString;
//LUAI_FUNC TString *luaS_new (lua_State *L, const char *str);
function luaS_new(const L: Plua_State; const str: PChar): PTString;
//LUAI_FUNC TString *luaS_createlngstrobj (lua_State *L, size_t l);
function luaS_createlngstrobj(const L: Plua_State; const l_: SizeUInt): PTString;


implementation

uses
  lobject;

//#define sizelstring(l)  (sizeof(union UTString) + ((l) + 1) * sizeof(char))
function sizelstring(const l: SizeUInt): SizeUInt;
begin
  Result := SizeOf(UTString) + (l + 1) * sizeof(Char);
end;

//#define sizeludata(l) (sizeof(union UUdata) + (l))
function sizeludata(const l: SizeUInt): SizeUInt;
begin
  Result := SizeOf(UUdata) + l;
end;

//#define sizeudata(u)  sizeludata((u)->len)
function sizeudata(const u: PUdata): SizeUInt;
begin
  Result := SizeOf(UUdata) + u^.len;
end;

//#define luaS_newliteral(L, s) (luaS_newlstr(L, "" s, \
//                                 (sizeof(s)/sizeof(char))-1))
function luaS_newliteral(const L: Plua_State; const s: string): PTString;
begin
  Result := luaS_newlstr(L, @s[1], length(s));
end;

//#define isreserved(s) ((s)->tt == LUA_TSHRSTR && (s)->extra > 0)
function isreserved(const s: PTString): Boolean;
begin
  Result := (s^.header.tt = LUA_TSHRSTR) and (s^.extra > 0);
end;

//#define eqshrstr(a,b) check_exp((a)->tt == LUA_TSHRSTR, (a) == (b))
function eqshrstr(const a, b: PTString): Boolean;
begin
  Result := check_exp(a^.header.tt = LUA_TSHRSTR, a = b);
end;

function luaS_hash(const str: PChar; const l: SizeUInt; const seed: Cardinal): Cardinal;
begin

end;

function luaS_hashlongstr(const ts: PTString): Cardinal;
begin

end;

function luaS_eqlngstr(const a, b: PTString): Integer;
begin

end;

procedure luaS_resize(const L: Plua_State; const newsize: Integer);
begin

end;

procedure luaS_clearcache(const g: Pglobal_State);
begin

end;

procedure luaS_init(const L: Plua_State);
begin

end;

procedure luaS_remove(const L: Plua_State; const ts: PTString);
begin

end;

function luaS_newudata(const L: Plua_State; const s: SizeUInt): PUdata;
begin

end;

function luaS_newlstr(const L: Plua_State; const str: PChar; const l_: SizeUInt): PTString;
begin

end;

function luaS_new(const L: Plua_State; const str: PChar): PTString;
begin

end;

function luaS_createlngstrobj(const L: Plua_State; const l_: SizeUInt): PTString;
begin

end;

end.

