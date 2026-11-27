//#if !defined(luai_verifycode)
//#define luai_verifycode(L,b,f)  /* empty */
//#endif


type
  LoadState = record
    L: Plua_State;
    Z: PZIO;
    name: PChar;
  end;


//static l_noret error(LoadState *S, const char *why)
procedure error(var S: LoadState; const why: PChar);
begin
  luaO_pushfstring(S.L, '%s: %s precompiled chunk', [S.name, why]);
  luaD_throw(S.L, LUA_ERRSYNTAX);
end;

//static void LoadBlock (LoadState *S, void *b, size_t size)
procedure LoadBlock(var S: LoadState; const b: Pointer; const size: SizeUInt);
begin
  if (luaZ_read(S.Z^, b, size) <> 0) then
    error(S, 'truncated');
end;

(*
** All high-level loads go through LoadVector; you can change it to
** adapt to the endianness of the input
*)
//#define LoadVector(S,b,n)  LoadBlock(S,b,(n)*sizeof((b)[0]))
procedure LoadVector(var S: LoadState; const b: Pointer; const sizeof_b: SizeUInt; const n: Integer);
begin
  LoadBlock(S,b,n*sizeof_b);
end;

//#define LoadVar(S,x)  LoadVector(S,&x,1)
procedure LoadVar(var S: LoadState; out x: lu_byte); overload;
begin
  LoadVector(S, @x, sizeof(x), 1);
end;
procedure LoadVar(var S: LoadState; out x: Integer); overload;
begin
  LoadVector(S, @x, sizeof(x), 1);
end;
procedure LoadVar(var S: LoadState; out x: lua_Number); overload;
begin
  LoadVector(S, @x, sizeof(x), 1);
end;
procedure LoadVar(var S: LoadState; out x: lua_Integer); overload;
begin
  LoadVector(S, @x, sizeof(x), 1);
end;
procedure LoadVar(var S: LoadState; out x: SizeUInt); overload;
begin
  LoadVector(S, @x, sizeof(x), 1);
end;

//static lu_byte LoadByte (LoadState *S)
function LoadByte(var S: LoadState): lu_byte;
begin
  LoadVar(S, Result);
end;


//static int LoadInt (LoadState *S)
function LoadInt(var S: LoadState): Integer;
begin
  LoadVar(S, Result);
end;


//static lua_Number LoadNumber (LoadState *S)
function LoadNumber(var S: LoadState): lua_Number;
begin
  LoadVar(S, Result);
end;


//static lua_Integer LoadInteger (LoadState *S)
function LoadInteger(var S: LoadState): lua_Integer;
begin
  LoadVar(S, Result);
end;


//static TString *LoadString (LoadState *S, Proto *p)
function LoadString(var S: LoadState; const p: PProto): PTString;
var
  L: Plua_State;
  size: SizeUInt;
  ts: PTString;
  buff: array[0..LUAI_MAXSHORTLEN-1] of char;
begin
  L := S.L;
  size := LoadByte(S);
  if (size = $FF) then
    LoadVar(S, size);
  if (size = 0) then
    Exit(nil)
  else if (size-1) <= LUAI_MAXSHORTLEN then  //* short string? */
  begin
    Dec(size);
    LoadVector(S, @buff[0], sizeof(char), size);
    ts := luaS_newlstr(L, @buff[0], size);
  end
  else  //* long string */
  begin
    ts := luaS_createlngstrobj(L, size);
    setsvalue2s(L, L^.top, ts);  //* anchor it ('loadVector' can GC) */
    luaD_inctop(L);
    LoadVector(S, getstr(ts), sizeof(char), size);  //* load directly in final place */
    dec(L^.top);  //* pop string */
  end;
  luaC_objbarrier(L, obj2gco(p), obj2gco(ts));
  Result := ts;
end;


//static void LoadCode (LoadState *S, Proto *f)
procedure LoadCode(var S: LoadState; const f: PProto);
var
  n: Integer;
begin
  n := LoadInt(S);
  f^.code := luaM_newvector(S.L, n, sizeof(Instruction));
  f^.sizecode := n;
  LoadVector(S, f^.code, sizeof(Instruction), n);
end;


//static void LoadFunction(LoadState *S, Proto *f, TString *psource);
procedure LoadFunction(var S: LoadState; const f: PProto; const psource: PTString); forward;


//static void LoadConstants (LoadState *S, Proto *f)
procedure LoadConstants(var S: LoadState; const f: PProto);
var
  i, n, t: Integer;
  o: PTValue;
begin
  n := LoadInt(S);
  f^.k := luaM_newvector(S.L, n, sizeof(TValue));
  f^.sizek := n;
  for i := 0 to n-1 do
    setnilvalue(@f^.k[i]);
  for i := 0 to n-1 do
  begin
    o := @f^.k[i];
    t := LoadByte(S);
    case (t) of
    LUA_TNIL:
      setnilvalue(o);
    LUA_TBOOLEAN:
      setbvalue(o, LoadByte(S));
    LUA_TNUMFLT:
      setfltvalue(o, LoadNumber(S));
    LUA_TNUMINT:
      setivalue(o, LoadInteger(S));
    LUA_TSHRSTR,
    LUA_TLNGSTR:
      setsvalue2n(S.L, o, LoadString(S, f));
    else
      lua_assert(0);
    end
  end;
end;


//static void LoadProtos (LoadState *S, Proto *f)
procedure LoadProtos(var S: LoadState; const f: PProto);
var
  i, n: Integer;
begin
  n := LoadInt(S);
  f^.p := luaM_newvector(S.L, n, sizeof(PProto));
  f^.sizep := n;
  for i := 0 to n-1 do
    f^.p[i] := Nil;
  for i := 0 to n-1 do
  begin
    f^.p[i] := luaF_newproto(S.L);
    luaC_objbarrier(S.L, obj2gco(f), obj2gco(f^.p[i]));
    LoadFunction(S, f^.p[i], f^.source);
  end;
end;


//static void LoadUpvalues (LoadState *S, Proto *f)
procedure LoadUpvalues(var S: LoadState; const f: PProto);
var
  i, n: Integer;
begin
  n := LoadInt(S);
  f^.upvalues := luaM_newvector(S.L, n, sizeof(Upvaldesc));
  f^.sizeupvalues := n;
  for i := 0 to n-1 do
    f^.upvalues[i].name := Nil;
  for i := 0 to n-1 do
  begin
    f^.upvalues[i].instack := LoadByte(S);
    f^.upvalues[i].idx := LoadByte(S);
  end;
end;


//static void LoadDebug (LoadState *S, Proto *f)
procedure LoadDebug(var S: LoadState; const f: PProto);
var
  i, n: Integer;
begin
  n := LoadInt(S);
  f^.lineinfo := luaM_newvector(S.L, n, sizeof(Integer));
  f^.sizelineinfo := n;
  LoadVector(S, f^.lineinfo, sizeof(Integer), n);
  n := LoadInt(S);
  f^.locvars := luaM_newvector(S.L, n, sizeof(LocVar));
  f^.sizelocvars := n;
  for i := 0 to n-1 do
    f^.locvars[i].varname := Nil;
  for i := 0 to n-1 do
  begin
    f^.locvars[i].varname := LoadString(S, f);
    f^.locvars[i].startpc := LoadInt(S);
    f^.locvars[i].endpc := LoadInt(S);
  end;
  n := LoadInt(S);
  for i := 0 to n-1 do
    f^.upvalues[i].name := LoadString(S, f);
end;


//static void LoadFunction (LoadState *S, Proto *f, TString *psource)
procedure LoadFunction(var S: LoadState; const f: PProto; const psource: PTString);
begin
  f^.source := LoadString(S, f);
  if (f^.source = Nil) then //* no source in dump? */
    f^.source := psource;  //* reuse parent's source */
  f^.linedefined := LoadInt(S);
  f^.lastlinedefined := LoadInt(S);
  f^.numparams := LoadByte(S);
  f^.is_vararg := LoadByte(S);
  f^.maxstacksize := LoadByte(S);
  LoadCode(S, f);
  LoadConstants(S, f);
  LoadUpvalues(S, f);
  LoadProtos(S, f);
  LoadDebug(S, f);
end;


//static void checkliteral (LoadState *S, const char *s, const char *msg)
procedure checkliteral(var S: LoadState; const str, msg: PChar);
const
  buff_size__ = length(LUA_SIGNATURE) + length(LUAC_DATA);
var
  buff: array[0..buff_size__] of char; //* larger than both */
  len: SizeUInt;
begin
  len := strlen(str);
  LoadVector(S, @buff[0], sizeof(char), len);
  if memcmp(str, @buff[0], len) then
    error(S, msg);
end;


//static void fchecksize (LoadState *S, size_t size, const char *tname)
procedure fchecksize(var S: LoadState; const size: SizeUInt; const tname: PChar);
begin
  if (LoadByte(S) <> size) then
    error(S, luaO_pushfstring(S.L, '%s size mismatch in', [tname]));
end;


//#define checksize(S,t)  fchecksize(S,sizeof(t),#t)

//static void checkHeader (LoadState *S)
procedure checkHeader(var S: LoadState);
begin
  checkliteral(S, PChar(LUA_SIGNATURE) + 1, 'not a');  //* 1st char already checked */
  if (LoadByte(S) <> LUAC_VERSION) then
    error(S, 'version mismatch in');
  if (LoadByte(S) <> LUAC_FORMAT) then
    error(S, 'format mismatch in');
  checkliteral(S, LUAC_DATA, 'corrupted');
  fchecksize(S, sizeof(Integer), 'Integer');
  fchecksize(S, sizeof(SizeUInt), 'SizeUInt');
  fchecksize(S, sizeof(Instruction), 'Instruction');
  fchecksize(S, sizeof(lua_Integer), 'lua_Integer');
  fchecksize(S, sizeof(lua_Number), 'lua_Number');
  if (LoadInteger(S) <> LUAC_INT) then
    error(S, 'endianness mismatch in');
  if (LoadNumber(S) <> LUAC_NUM) then
    error(S, 'float format mismatch in');
end;


