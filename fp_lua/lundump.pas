unit lundump;
(*
** load precompiled Lua chunks
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common, lzio;

(* data to catch conversion errors *)
const
  LUAC_DATA     = #$19#$93#10#13#$1A#13; //"\x19\x93\r\n\x1a\n"

  LUAC_INT      = $5678;
  LUAC_NUM      = cast_num(370.5);

//#define MYINT(s)  (s[0]-'0')
function MYINT(const s: PChar): lu_int;

const
  LUAC_VERSION  = (ord(LUA_VERSION_MAJOR) - ord('0'))*16 + (ord(LUA_VERSION_MINOR) - ord('0'));
  LUAC_FORMAT   = 0;       //* this is the official format */

(* load one chunk; from lundump.c *)
//LUAI_FUNC LClosure* luaU_undump (lua_State* L, ZIO* Z, const char* name);
function luaU_undump(const L: Plua_State; const z: PZio; const name: PChar): PLClosure;

(* dump one chunk; from ldump.c *)
//LUAI_FUNC int luaU_dump (lua_State* L, const Proto* f, lua_Writer w,
//                         void* data, int strip);
function luaU_dump(const L: Plua_State; const f: PProto; const w: lua_Writer;
  const data: Pointer; const strip: Integer): Integer;


implementation

uses
  fp_lua, fplua_sysutils,
  ldo, lfunc, lgc, lmem, lobject, lstring, lstate;

{$i ldump.inc}
{$i lundump.inc}

function MYINT(const s: PChar): lu_int;
begin
  Result := ord(s[0]) - ord('0');
end;

(*
** load precompiled chunk
*)
function luaU_undump(const L: Plua_State; const z: PZio; const name: PChar): PLClosure;
var
  S: LoadState;
  cl: PLClosure;
begin
  if (name^ = '@') or (name^ = '=') then
    S.name := name + 1
  else if (name^ = LUA_SIGNATURE[0]) then
    S.name := 'binary string'
  else
    S.name := name;
  S.L := L;
  S.Z := Z;
  checkHeader(S);
  cl := luaF_newLclosure(L, LoadByte(S));
  setclLvalue(L, L^.top, cl);
  luaD_inctop(L);
  cl^.p := luaF_newproto(L);
  luaC_objbarrier(L, obj2gco(cl), obj2gco(cl^.p));
  LoadFunction(S, cl^.p, Nil);
  lua_assert(cl^.header.nupvalues = cl^.p^.sizeupvalues);
  // luai_verifycode is defined as '/* empty */' in lundump.c
  // What is supposed to be 'buff' here?
  //luai_verifycode(L, buff, cl^.p);
  // Implement it in lundump.inc if needed
  Result := cl;
end;

function luaU_dump(const L: Plua_State; const f: PProto; const w: lua_Writer;
  const data: Pointer; const strip: Integer): Integer;
var
  D: DumpState;
begin
  D.L := L;
  D.writer := w;
  D.data := data;
  D.strip := strip;
  D.status := 0;
  DumpHeader(D);
  DumpByte(f^.sizeupvalues, D);
  DumpFunction(f, Nil, D);
  Result := D.status;
end;

end.

