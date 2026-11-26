type
  DumpState = record
    L: Plua_State;
    writer: lua_Writer;
    data: Pointer;
    strip: Boolean;
    status: Integer;
  end;
  PDumpState = ^DumpState;



//static void DumpBlock (const void *b, size_t size, DumpState *D)
procedure DumpBlock(const b: Pointer; const size: SizeUInt; var D: DumpState);
begin
  if (D.status = 0) and (size > 0) then
  begin
    lua_unlock(D.L);
    D.status := D.writer(D.L, b, size, D.data);
    lua_lock(D.L);
  end;
end;

(*
** All high-level dumps go through DumpVector; you can change it to
** change the endianness of the result
*)
//#define DumpVector(v,n,D) DumpBlock(v,(n)*sizeof((v)[0]),D)
procedure DumpVector(const v: Pointer; const n: Integer; const sizeof_v: SizeUInt; var D: DumpState);
begin
  DumpBlock(v, n*sizeof_v, D);
end;

//#define DumpLiteral(s,D) DumpBlock(s, sizeof(s) - sizeof(char), D)
procedure DumpLiteral(const s: String; var D: DumpState);
begin
  DumpBlock(@s[1], length(s), D);
end;

//#define DumpVar(x,D) DumpVector(&x,1,D)


//static void DumpByte (int y, DumpState *D)
procedure DumpByte(const x: lu_byte; var D: DumpState);
begin
  DumpVector(@x, 1, sizeof(lu_byte), D);
end;


//static void DumpInt (int x, DumpState *D)
procedure DumpInt(const x: Integer; var D: DumpState);
begin
  DumpVector(@x, 1, sizeof(Integer), D);
end;


//static void DumpNumber (lua_Number x, DumpState *D)
procedure DumpNumber(const x: lua_Number; var D: DumpState);
begin
  DumpVector(@x, 1, sizeof(lua_Number), D);
end;


//static void DumpInteger (lua_Integer x, DumpState *D)
procedure DumpInteger(const x: lua_Integer; var D: DumpState);
begin
  DumpVector(@x, 1, sizeof(lua_Integer), D);
end;


//static void DumpString (const TString *s, DumpState *D)
procedure DumpString(const s: PTString; var D: DumpState);
var
  size: SizeUInt;
  str: PChar;
begin
  if (s = Nil) then
    DumpByte(0, D)
  else
  begin
    size := tsslen(s) + 1;  //* include trailing '\0' */
    str := getstr(s);
    if (size < $FF) then
      DumpByte(size, D)
    else
    begin
      DumpByte($FF, D);
      DumpVector(@size, 1, sizeof(SizeUInt), D);
    end;
    DumpVector(str, size - 1, SizeOf(Char), D);  //* no need to save '\0' */
  end;
end;


//static void DumpCode (const Proto *f, DumpState *D)
procedure DumpCode(const f: PProto; var D: DumpState);
begin
  DumpInt(f^.sizecode, D);
  DumpVector(f^.code, f^.sizecode, sizeof(Instruction), D);
end;


//static void DumpFunction(const Proto *f, TString *psource, DumpState *D);
procedure DumpFunction(const f: PProto; const psource: PTString; var D: DumpState); forward;

//static void DumpConstants (const Proto *f, DumpState *D)
procedure DumpConstants(const f: PProto; var D: DumpState);
var
  i, n: Integer;
  o: PTValue;
begin
  n := f^.sizek;
  DumpInt(n, D);
  for i := 0 to n-1 do
  begin
    o := @f^.k[i];
    DumpByte(ttype(o), D);
    case (ttype(o)) of
    LUA_TNIL:
      ;
    LUA_TBOOLEAN:
      DumpByte(bvalue(o), D);
    LUA_TNUMFLT:
      DumpNumber(fltvalue(o), D);
    LUA_TNUMINT:
      DumpInteger(ivalue(o), D);
    LUA_TSHRSTR,
    LUA_TLNGSTR:
      DumpString(tsvalue(o), D);
    else
      lua_assert(0);
    end;
  end;
end;


//static void DumpProtos (const Proto *f, DumpState *D)
procedure DumpProtos(const f: PProto; var D: DumpState);
var
  i, n: Integer;
begin
  n := f^.sizep;
  DumpInt(n, D);
  for i := 0 to n-1 do
    DumpFunction(f^.p[i], f^.source, D);
end;


//static void DumpUpvalues (const Proto *f, DumpState *D)
procedure DumpUpvalues(const f: PProto; var D: DumpState);
var
  i, n: Integer;
begin
  n := f^.sizeupvalues;
  DumpInt(n, D);
  for i := 0 to n-1 do
  begin
    DumpByte(f^.upvalues[i].instack, D);
    DumpByte(f^.upvalues[i].idx, D);
  end;
end;


//static void DumpDebug (const Proto *f, DumpState *D)
procedure DumpDebug(const f: PProto; var D: DumpState);
var
  i, n: Integer;
begin
  if (D.strip) then
    n := 0
  else
    n := f^.sizelineinfo;
  DumpInt(n, D);
  DumpVector(f^.lineinfo, n, sizeof(Integer), D);
  if (D.strip) then
    n := 0
  else
    n := f^.sizelocvars;
  DumpInt(n, D);
  for i := 0 to n-1 do
  begin
    DumpString(f^.locvars[i].varname, D);
    DumpInt(f^.locvars[i].startpc, D);
    DumpInt(f^.locvars[i].endpc, D);
  end;
  if (D.strip) then
    n := 0
  else
    n := f^.sizeupvalues;
  DumpInt(n, D);
  for i := 0 to n-1 do
    DumpString(f^.upvalues[i].name, D);
end;


//static void DumpFunction (const Proto *f, TString *psource, DumpState *D)
procedure DumpFunction(const f: PProto; const psource: PTString; var D: DumpState);
begin
  if D.strip or (f^.source = psource) then
    DumpString(Nil, D)  //* no debug info or same source as its parent */
  else
    DumpString(f^.source, D);
  DumpInt(f^.linedefined, D);
  DumpInt(f^.lastlinedefined, D);
  DumpByte(f^.numparams, D);
  DumpByte(f^.is_vararg, D);
  DumpByte(f^.maxstacksize, D);
  DumpCode(f, D);
  DumpConstants(f, D);
  DumpUpvalues(f, D);
  DumpProtos(f, D);
  DumpDebug(f, D);
end;


//static void DumpHeader (DumpState *D)
procedure DumpHeader(var D: DumpState);
begin
  DumpLiteral(LUA_SIGNATURE, D);
  DumpByte(LUAC_VERSION, D);
  DumpByte(LUAC_FORMAT, D);
  DumpLiteral(LUAC_DATA, D);
  DumpByte(sizeof(Integer), D);
  DumpByte(sizeof(SizeUInt), D);
  DumpByte(sizeof(Instruction), D);
  DumpByte(sizeof(lua_Integer), D);
  DumpByte(sizeof(lua_Number), D);
  DumpInteger(LUAC_INT, D);
  DumpNumber(LUAC_NUM, D);
end;


