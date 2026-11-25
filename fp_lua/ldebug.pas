unit ldebug;
(*
** Auxiliary functions from Debug Interface module
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types;

function pcRel(const pc: PInstruction; const p: PProto): Integer;

function getfuncline(const f: PProto; const pc: Integer): Integer;

procedure resethookcount(const L: Plua_State);

//LUAI_FUNC l_noret luaG_typeerror (lua_State *L, const TValue *o,
//                                                const char *opname);
procedure luaG_typeerror(const L: Plua_State; const o: PTValue; const opname: PChar);
//LUAI_FUNC l_noret luaG_concaterror (lua_State *L, const TValue *p1,
//                                                  const TValue *p2);
procedure luaG_concaterror(const L: Plua_State; p1, p2: PTValue);
//LUAI_FUNC l_noret luaG_opinterror (lua_State *L, const TValue *p1,
//                                                 const TValue *p2,
//                                                 const char *msg);
procedure luaG_opinterror(const L: Plua_State; p1, p2: PTValue; const msg: PChar);
//LUAI_FUNC l_noret luaG_tointerror (lua_State *L, const TValue *p1,
//                                                 const TValue *p2);
procedure luaG_tointerror(const L: Plua_State; p1, p2: PTValue);
//LUAI_FUNC l_noret luaG_ordererror (lua_State *L, const TValue *p1,
//                                                 const TValue *p2);
procedure luaG_ordererror(const L: Plua_State; const p1, p2: PTValue);
//LUAI_FUNC l_noret luaG_runerror (lua_State *L, const char *fmt, ...);
procedure luaG_runerror(const L: Plua_State; const fmt: PChar; const args: array of const);
//LUAI_FUNC const char *luaG_addinfo (lua_State *L, const char *msg,
//                                                  TString *src, int line);
function luaG_addinfo(const L: Plua_State; const msg: PChar; const src: PTString;
  const line: Integer): PChar;
//LUAI_FUNC l_noret luaG_errormsg (lua_State *L);
procedure luaG_errormsg(const L: Plua_State);
//LUAI_FUNC void luaG_traceexec (lua_State *L);
procedure luaG_traceexec(const L: Plua_State);

// functions declared in lua.h but implemented in ldebug.c
// these are called from fp_lua.pas
function lua_getinfo_(const L: Plua_State; what: PChar; const ar: Plua_Debug): Boolean;
function lua_getlocal_(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;
function lua_setlocal_(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;

implementation

uses
  SysUtils, fp_lua, fplua_lp_common,
  lapi, ldo, lfunc, lgc, lobject, lopcodes, lstate, ltable, ltm, lvm;

//#define noLuaClosure(f)  ((f) == NULL || (f)->c.tt == LUA_TCCL)
function noLuaClosure(const f: PClosure): Boolean;
begin
  Result := (f = nil) or (f^.c.header.header.tt = LUA_TCCL);
end;


(* Active Lua function (given call info) *)
//#define ci_func(ci)             (clLvalue((ci)->func))
function ci_func(const ci: PCallInfo): PLClosure;
begin
  Result := clLvalue(ci^.func);
end;

//static const char *funcnamefromcode (lua_State *L, CallInfo *ci,
//                                    const char **name);
function funcnamefromcode(const L: Plua_State; const ci: PCallInfo; var name: PChar): PChar; forward;

//static int currentpc (CallInfo *ci)
function currentpc(const ci: PCallInfo): Integer;
begin
  lua_assert(isLua(ci));
  Result := pcRel(ci^.u.l_savedpc, ci_func(ci)^.p);
end;


//static int currentline (CallInfo *ci)
function currentline(const ci: PCallInfo): Integer;
begin
  Result := getfuncline(ci_func(ci)^.p, currentpc(ci));
end;


(*
** If function yielded, its 'func' can be in the 'extra' field. The
** next function restores 'func' to its correct value for debugging
** purposes. (It exchanges 'func' and 'extra'; so, when called again,
** after debugging, it also "re-restores" ** 'func' to its altered value.
*)
//static void swapextra (lua_State *L)
procedure swapextra(const L: Plua_State);
var
  ci: PCallInfo;
  temp: StkId;
begin
  if (L^.status = LUA_YIELD) then
  begin
    ci := L^.ci;  //* get function that yielded */
    temp := ci^.func;  //* exchange its 'func' and 'extra' values */
    ci^.func := restorestack(L, ci^.extra);
    ci^.extra := savestack(L, temp);
  end;
end;


//static const char *upvalname (Proto *p, int uv)
function upvalname(const p: PProto; const uv: Integer): PChar;
var
  s: PTString;
begin
  s := check_exp(uv < p^.sizeupvalues, p^.upvalues[uv].name);
  if (s = Nil) then
    Result := '?'
  else
    Result := getstr(s);
end;


//static const char *findvararg (CallInfo *ci, int n, StkId *pos)
function findvararg(const ci: PCallInfo; const n: Integer; var pos: StkId): PChar;
var
  nparams, nvararg: Integer;
begin
  nparams := clLvalue(ci^.func)^.p^.numparams;
  nvararg := cast_int(ci^.u.l_base - ci^.func) - nparams;
  if (n <= -nvararg) then
    Result := Nil  //* no such vararg */
  else
  begin
    pos := ci^.func + nparams - n;
    Result := '(*vararg)';  //* generic name for any vararg */
  end;
end;


//static const char *findlocal (lua_State *L, CallInfo *ci, int n,
//                              StkId *pos)
function findlocal(const L: Plua_State; const ci: PCallInfo; const n: Integer; var pos: StkId): PChar;
var
  name: PChar;
  base, limit: StkId;
begin
  name := Nil;
  if (isLua(ci)) then
  begin
    if (n < 0) then //* access to vararg values? */
      Exit( findvararg(ci, n, pos) )
    else
    begin
      base := ci^.u.l_base;
      name := luaF_getlocalname(ci_func(ci)^.p, n, currentpc(ci));
    end;
  end
  else
    base := ci^.func + 1;
  if (name = Nil) then //* no 'standard' name? */
  begin
    if (ci = L^.ci) then
      limit := L^.top
    else
      limit := ci^.next^.func;
    if ((limit - base) >= n) and (n > 0) then //* is 'n' inside 'ci' stack? */
      name := '(*temporary)'  //* generic name for any valid slot */
    else
      Exit(Nil);  //* no name */
  end;
  pos := base + (n - 1);
  Result := name;
end;


//static void funcinfo (lua_Debug *ar, Closure *cl)
procedure funcinfo(const ar: Plua_Debug; const cl: PClosure);
var
  p: PProto;
begin
  if (noLuaClosure(cl)) then
  begin
    ar^.source := '=[C]';
    ar^.linedefined := -1;
    ar^.lastlinedefined := -1;
    ar^.what := 'C';
  end
  else
  begin
    p := cl^.l.p;
    if p^.source <> nil then
      ar^.source := getstr(p^.source)
    else
      ar^.source := '=?';
    ar^.linedefined := p^.linedefined;
    ar^.lastlinedefined := p^.lastlinedefined;
    if (ar^.linedefined = 0) then
      ar^.what := 'main'
    else
      ar^.what := 'Lua';
  end;
  luaO_chunkid(ar^.short_src, ar^.source, LUA_IDSIZE);
end;


//static void collectvalidlines (lua_State *L, Closure *f)
procedure collectvalidlines(const L: Plua_State; const f: PClosure);
var
  i: Integer;
  v: TValue;
  lineinfo: PInteger;
  t: PTable;
begin
  if (noLuaClosure(f)) then
  begin
    setnilvalue(L^.top);
    api_incr_top(L);
  end
  else
  begin
    lineinfo := f^.l.p^.lineinfo;
    t := luaH_new(L);  //* new table to store active lines */
    sethvalue(L, L^.top, t);  //* push it on stack */
    api_incr_top(L);
    setbvalue(@v, 1);  //* boolean 'true' to be the value of all indices */
    for i := 0 to f^.l.p^.sizelineinfo - 1 do //* for all lines with code */
      luaH_setint(L, t, lineinfo[i], @v);  //* table[line] = true */
  end;
end;


//static const char *getfuncname (lua_State *L, CallInfo *ci, const char **name)
function getfuncname(const L: Plua_State; const ci: PCallInfo; var name: PChar): PChar;
begin
  if (ci = Nil) then //* no 'ci'? */
    Exit(Nil)  //* no info */
  else if (ci^.callstatus and CIST_FIN) <> 0 then  //* is this a finalizer? */
  begin
    name := '__gc';
    Exit('metamethod');  //* report it as such */
  end
  //* calling function is a known Lua function? */
  else if (((ci^.callstatus and CIST_TAIL) = 0) and isLua(ci^.previous)) then
    Result := funcnamefromcode(L, ci^.previous, name)
  else Result := Nil;  //* no way to find a name */
end;


//static int auxgetinfo (lua_State *L, const char *what, lua_Debug *ar,
//                       Closure *f, CallInfo *ci)
function auxgetinfo(const L: Plua_State; what: PChar; const ar: Plua_Debug;
  const f: PClosure; const ci: PCallInfo): Boolean;
begin
  //int status = 1;
  Result := True;
  while (what^ <> #0) do
  begin
    case (what^) of
      'S':
        funcinfo(ar, f);
      'l': begin
        if (ci <> nil) and isLua(ci) then
          ar^.currentline := currentline(ci)
        else
          ar^.currentline := -1;
      end;
      'u': begin
        if (f = Nil) then
          ar^.nups := 0
        else
          ar^.nups := f^.c.header.nupvalues;
        if (noLuaClosure(f)) then
        begin
          ar^.isvararg := 1;
          ar^.nparams := 0;
        end
        else
        begin
          ar^.isvararg := f^.l.p^.is_vararg;
          ar^.nparams := f^.l.p^.numparams;
        end;
      end;
      't': begin
        if (ci <> nil) then
          ar^.istailcall := lu_byte((ci^.callstatus and CIST_TAIL) <> 0)
        else
          ar^.istailcall := 0;
      end;
      'n': begin
        ar^.namewhat := getfuncname(L, ci, ar^.name);
        if (ar^.namewhat = Nil) then
        begin
          ar^.namewhat := '';  //* not found */
          ar^.name := Nil;
        end;
      end;
      'L',
      'f': begin
        //* handled by lua_getinfo */
      end;
      else Result := False;  //* invalid option */
    end;
    inc(what);
  end;
  //return status;
end;

(*
** =======================================================
** Symbolic Execution
** =======================================================
*)

//static const char *getobjname (Proto *p, int lastpc, int reg,
//                               const char **name);
function getobjname(const p: PProto; const lastpc, reg: Integer; var name: PChar): PChar; forward;

(*
** find a "name" for the RK value 'c'
*)
//static void kname (Proto *p, int pc, int c, const char **name)
procedure kname(const p: PProto; const pc, c: Integer; var name: PChar);
var
  kvalue: PTValue;
  what: PChar;
begin
  if (ISK(c)) then  //* is 'c' a constant? */
  begin
    kvalue := @p^.k[INDEXK(c)];
    if (ttisstring(kvalue)) then  //* literal constant? */
    begin
      name := svalue(kvalue);  //* it is its own name */
      Exit;
    end;
    //* else no reasonable name found */
  end
  else  //* 'c' is a register */
  begin
    what := getobjname(p, pc, c, name); //* search for 'c' */
    if (what <> nil) and (what^ = 'c') then //* found a constant name? */
      Exit;  //* 'name' already filled */
    //* else no reasonable name found */
  end;
  name := '?';  //* no reasonable name found */
end;


//static int filterpc (int pc, int jmptarget)
function filterpc(const pc, jmptarget: Integer): Integer;
begin
  if (pc < jmptarget) then //* is code conditional (inside a jump)? */
    Result := -1  //* cannot know who sets that register */
  else Result := pc;  //* current position sets that register */
end;


(*
** try to find last instruction before 'lastpc' that modified register 'reg'
*)
//static int findsetreg (Proto *p, int lastpc, int reg)
function findsetreg(const p: PProto; const lastpc, reg: Integer): Integer;
var
  pc, setreg, jmptarget, a, b, dest: Integer;
  i: Instruction;
  op: OpCode;
begin
  setreg := -1;  //* keep last instruction that changed 'reg' */
  jmptarget := 0;  //* any code before this address is conditional */
  for pc := 0 to lastpc - 1 do
  begin
    i := p^.code[pc];
    op := GET_OPCODE(i);
    a := GETARG_A(i);
    case (op) of
      OP_LOADNIL: begin
        b := GETARG_B(i);
        if (a <= reg) and (reg <= (a + b)) then //* set registers from 'a' to 'a+b' */
          setreg := filterpc(pc, jmptarget);
      end;
      OP_TFORCALL: begin
        if reg >= (a + 2) then //* affect all regs above its base */
          setreg := filterpc(pc, jmptarget);
      end;
      OP_CALL,
      OP_TAILCALL: begin
        if (reg >= a) then //* affect all registers above base */
          setreg := filterpc(pc, jmptarget);
      end;
      OP_JMP: begin
        b := GETARG_sBx(i);
        dest := pc + 1 + b;
        //* jump is forward and do not skip 'lastpc'? */
        if (pc < dest) and (dest <= lastpc) then
        begin
          if (dest > jmptarget) then
            jmptarget := dest;  //* update 'jmptarget' */
        end;
      end;
      else begin
        if testAMode(op) and (reg = a) then //* any instruction that set A */
          setreg := filterpc(pc, jmptarget);
      end;
    end;
  end;
  Result := setreg;
end;


//static const char *getobjname (Proto *p, int lastpc, int reg,
//                               const char **name)
function getobjname(const p: PProto; const lastpc, reg: Integer; var name: PChar): PChar;
var
  pc, b, k, t: Integer;
  i: Instruction;
  op: OpCode;
  vn: PChar;
begin
  name := luaF_getlocalname(p, reg + 1, lastpc);
  if (name <> nil) then //* is a local? */
    Exit('local');
  //* else try symbolic execution */
  pc := findsetreg(p, lastpc, reg);
  if (pc <> -1) then  //* could find instruction? */
  begin
    i := p^.code[pc];
    op := GET_OPCODE(i);
    case (op) of
      OP_MOVE: begin
        b := GETARG_B(i);  //* move from 'b' to 'a' */
        if (b < GETARG_A(i)) then
          Exit( getobjname(p, pc, b, name) );  //* get name for 'b' */
      end;
      OP_GETTABUP,
      OP_GETTABLE: begin
        k := GETARG_C(i);  //* key index */
        t := GETARG_B(i);  //* table index */
        if (op = OP_GETTABLE) then //* name of indexed variable */
          vn := luaF_getlocalname(p, t + 1, pc)
        else
          vn := upvalname(p, t);
        kname(p, pc, k, name);
        if (vn <> nil) and (strcomp(vn, LUA_ENV) = 0) then
          exit('global') else exit('field');
      end;
      OP_GETUPVAL: begin
        name := upvalname(p, GETARG_B(i));
        exit('upvalue');
      end;
      OP_LOADK,
      OP_LOADKX: begin
        if (op = OP_LOADK) then
          b := GETARG_Bx(i)
        else
          b := GETARG_Ax(p^.code[pc + 1]);
        if (ttisstring(@p^.k[b])) then
        begin
          name := svalue(@p^.k[b]);
          exit('constant');
        end;
      end;
      OP_SELF: begin
        k := GETARG_C(i);  //* key index */
        kname(p, pc, k, name);
        exit('method');
      end;
      else begin
        //* go through to return NULL */
      end;
    end;
  end;
  Result := Nil;  //* could not find reasonable name */
end;


(*
** Try to find a name for a function based on the code that called it.
** (Only works when function was called by a Lua function.)
** Returns what the name is (e.g., "for iterator", "method",
** "metamethod") and sets '*name' to point to the name.
*)
//static const char *funcnamefromcode (lua_State *L, CallInfo *ci,
//                                     const char **name)
function funcnamefromcode(const L: Plua_State; const ci: PCallInfo; var name: PChar): PChar;
var
  tm: TMS;
  p: PProto;
  pc, offset: Integer;
  i: Instruction;
begin
  tm := TMS(0);  //* (initial value avoids warnings) */
  p := ci_func(ci)^.p;  //* calling function */
  pc := currentpc(ci);  //* calling instruction index */
  i := p^.code[pc];  //* calling instruction */
  if (ci^.callstatus and CIST_HOOKED) <> 0 then //* was it called inside a hook? */
  begin
    name := '?';
    Exit('hook');
  end;
  case (GET_OPCODE(i)) of
    OP_CALL,
    OP_TAILCALL:
      Exit( getobjname(p, pc, GETARG_A(i), name) );  //* get function name */
    OP_TFORCALL: begin  //* for iterator */
      name := 'for iterator';
      Exit('for iterator');
    end;
    //* other instructions can do calls through metamethods */
    OP_SELF, OP_GETTABUP, OP_GETTABLE:
      tm := TM_INDEX;
    OP_SETTABUP, OP_SETTABLE:
      tm := TM_NEWINDEX;
    OP_ADD, OP_SUB, OP_MUL, OP_MOD,
    OP_POW, OP_DIV, OP_IDIV, OP_BAND,
    OP_BOR, OP_BXOR, OP_SHL, OP_SHR: begin
      offset := ord(GET_OPCODE(i)) - ord(OP_ADD);  //* ORDER OP */
      tm := TMS(offset + ord(TM_ADD));  //* ORDER TM */
    end;
    OP_UNM: tm := TM_UNM;
    OP_BNOT: tm := TM_BNOT;
    OP_LEN: tm := TM_LEN;
    OP_CONCAT: tm := TM_CONCAT;
    OP_EQ: tm := TM_EQ;
    OP_LT: tm := TM_LT;
    OP_LE: tm := TM_LE;
    else
      Exit(Nil);  //* cannot find a reasonable name */
  end;
  name := getstr(G(L)^.tmname[tm]);
  Result := 'metamethod';
end;

(* ====================================================== *)



(*
** The subtraction of two potentially unrelated pointers is
** not ISO C, but it should not crash a program; the subsequent
** checks are ISO C and ensure a correct result.
*)
//static int isinstack (CallInfo *ci, const TValue *o)
function isinstack(const ci: PCallInfo; const o: PTValue): Boolean;
var
  i: PtrInt;
begin
  i := o - ci^.u.l_base;
  Result := (0 <= i) and (i < (ci^.top - ci^.u.l_base)) and ((ci^.u.l_base + i) = o);
end;


(*
** Checks whether value 'o' came from an upvalue. (That can only happen
** with instructions OP_GETTABUP/OP_SETTABUP, which operate directly on
** upvalues.)
*)
//static const char *getupvalname (CallInfo *ci, const TValue *o,
//                                 const char **name)
function getupvalname(const ci: PCallInfo; const o: PTValue; var name: PChar): PChar;
var
  c: PLClosure;
  i: Integer;
begin
  c := ci_func(ci);
  for i := 0 to c^.header.nupvalues - 1 do
  begin
    if (LClosure_upvalsN(c, i)^.v = o) then
    begin
      name := upvalname(c^.p, i);
      Exit('upvalue');
    end;
  end;
  Result := Nil;
end;


//static const char *varinfo (lua_State *L, const TValue *o)
function varinfo(const L: Plua_State; const o: PTValue): PChar;
var
  name, kind: PChar;
  ci: PCallInfo;
begin
  name := Nil;  //* to avoid warnings */
  ci := L^.ci;
  kind := Nil;
  if (isLua(ci)) then
  begin
    kind := getupvalname(ci, o, name);  //* check whether 'o' is an upvalue */
    if (kind = nil) and isinstack(ci, o) then  //* no? try a register */
      kind := getobjname(ci_func(ci)^.p, currentpc(ci),
                        cast_int(o - ci^.u.l_base), name);
  end;
  if (kind <> nil) then
    Result := luaO_pushfstring(L, ' (%s "%s")', [kind, name])
  else
    Result := '';
end;


//#define pcRel(pc, p)  (cast(int, (pc) - (p)->code) - 1)
function pcRel(const pc: PInstruction; const p: PProto): Integer;
begin
  Result := Integer(pc - p^.code) - 1;
end;

//#define getfuncline(f,pc)     (((f)->lineinfo) ? (f)->lineinfo[pc] : -1)
function getfuncline(const f: PProto; const pc: Integer): Integer;
begin
  if f^.lineinfo <> nil then
    Result := f^.lineinfo[pc]
  else
    Result := -1;
end;

//#define resethookcount(L)     (L->hookcount = L->basehookcount)
procedure resethookcount(const L: Plua_State);
begin
  L^.hookcount := L^.basehookcount;
end;

procedure luaG_typeerror(const L: Plua_State; const o: PTValue; const opname: PChar);
var
  t: PChar;
begin
  t := luaT_objtypename(L, o);
  luaG_runerror(L, 'attempt to %s a %s value%s', [opname, t, varinfo(L, o)]);
end;

procedure luaG_concaterror(const L: Plua_State; p1, p2: PTValue);
begin
  if (ttisstring(p1) or cvt2str(p1)) then
    p1 := p2;
  luaG_typeerror(L, p1, 'concatenate');
end;

procedure luaG_opinterror(const L: Plua_State; p1, p2: PTValue; const msg: PChar);
var
  temp: lua_Number;
begin
  if (not tonumber(p1, @temp)) then //* first operand is wrong? */
    p2 := p1;  //* now second is wrong */
  luaG_typeerror(L, p2, msg);
end;

(*
** Error when both values are convertible to numbers, but not to integers
*)
procedure luaG_tointerror(const L: Plua_State; p1, p2: PTValue);
var
  temp: lua_Integer;
begin
  if (not tointeger(p1, @temp)) then
    p2 := p1;
  luaG_runerror(L, 'number%s has no integer representation', [varinfo(L, p2)]);
end;

procedure luaG_ordererror(const L: Plua_State; const p1, p2: PTValue);
var
  t1, t2: PChar;
begin
  t1 := luaT_objtypename(L, p1);
  t2 := luaT_objtypename(L, p2);
  if (strcomp(t1, t2) = 0) then
    luaG_runerror(L, 'attempt to compare two %s values', [t1])
  else
    luaG_runerror(L, 'attempt to compare %s with %s', [t1, t2]);
end;

procedure luaG_runerror(const L: Plua_State; const fmt: PChar; const args: array of const);
var
  ci: PCallInfo;
  msg: PChar;
begin
  ci := L^.ci;
  luaC_checkGC(L);  //* error message uses memory */
  msg := luaO_pushvfstring(L, fmt, args);  //* format message */
  if (isLua(ci)) then //* if Lua function, add source:line information */
    luaG_addinfo(L, msg, ci_func(ci)^.p^.source, currentline(ci));
  luaG_errormsg(L);
end;

function luaG_addinfo(const L: Plua_State; const msg: PChar; const src: PTString;
  const line: Integer): PChar;
var
  buff: array[0..LUA_IDSIZE-1] of char;
begin
  if (src <> nil) then
    luaO_chunkid(@buff[0], getstr(src), LUA_IDSIZE)
  else   //* no source available; use "?" instead */
  begin
    buff[0] := '?';
    buff[1] := #0;
  end;
  Result := luaO_pushfstring(L, '%s:%d: %s', [buff, line, msg]);
end;

procedure luaG_errormsg(const L: Plua_State);
var
  errfunc: StkId;
begin
  if (L^.errfunc <> 0) then //* is there an error handling function? */
  begin
    errfunc := restorestack(L, L^.errfunc);
    setobjs2s(L, L^.top, L^.top - 1);  //* move argument */
    setobjs2s(L, L^.top - 1, errfunc);  //* push function */
    inc(L^.top);  //* assume EXTRA_STACK */
    luaD_callnoyield(L, L^.top - 2, 1);  //* call it */
  end;
  luaD_throw(L, LUA_ERRRUN);
end;

procedure luaG_traceexec(const L: Plua_State);
var
  ci: PCallInfo;
  mask: lu_byte;
  counthook: Boolean;
  p: PProto;
  npc, newline: Integer;
begin
  ci := L^.ci;
  mask := L^.hookmask;
  dec(L^.hookcount);
  counthook := (L^.hookcount = 0) and ((mask and LUA_MASKCOUNT) <> 0);
  if (counthook) then
    resethookcount(L)  //* reset count */
  else if ((mask and LUA_MASKLINE) = 0) then
    Exit;  //* no line hook and count != 0; nothing to be done */
  if (ci^.callstatus and CIST_HOOKYIELD) <> 0 then //* called hook last time? */
  begin
    ci^.callstatus := ci^.callstatus and not CIST_HOOKYIELD;  //* erase mark */
    Exit;  //* do not call hook again (VM yielded, so it did not move) */
  end;
  if (counthook) then
    luaD_hook(L, LUA_HOOKCOUNT, -1);  //* call count hook */
  if (mask and LUA_MASKLINE) <> 0 then
  begin
    p := ci_func(ci)^.p;
    npc := pcRel(ci^.u.l_savedpc, p);
    newline := getfuncline(p, npc);
    if (npc = 0) or  //* call linehook when enter a new function, */
        (ci^.u.l_savedpc <= L^.oldpc) or  //* when jump back (loop), or when */
        (newline <> getfuncline(p, pcRel(L^.oldpc, p))) then //* enter a new line */
      luaD_hook(L, LUA_HOOKLINE, newline);  //* call line hook */
  end;
  L^.oldpc := ci^.u.l_savedpc;
  if (L^.status = LUA_YIELD) then //* did hook yield? */
  begin
    if (counthook) then
      L^.hookcount := 1;  //* undo decrement to zero */
    dec(ci^.u.l_savedpc);  //* undo increment (resume will increment it again) */
    ci^.callstatus := ci^.callstatus or CIST_HOOKYIELD;  //* mark that it yielded */
    ci^.func := L^.top - 1;  //* protect stack below results */
    luaD_throw(L, LUA_YIELD);
  end;
end;

function lua_getinfo_(const L: Plua_State; what: PChar; const ar: Plua_Debug): Boolean;
var
  //status: Integer; // use Result
  cl: PClosure;
  ci: PCallInfo;
  func: StkId;
begin
  lua_lock(L);
  swapextra(L);
  if (what^ = '>') then
  begin
    ci := Nil;
    func := L^.top - 1;
    api_check(L, ttisfunction(func), 'function expected');
    inc(what);  //* skip the '>' */
    dec(L^.top);  //* pop function */
  end
  else
  begin
    ci := ar^.i_ci;
    func := ci^.func;
    lua_assert(ttisfunction(ci^.func));
  end;
  if ttisclosure(func) then
    cl := clvalue(func)
  else
    cl := Nil;
  Result := auxgetinfo(L, what, ar, cl, ci);
  if (strscan(what, 'f') <> nil) then
  begin
    setobjs2s(L, L^.top, func);
    api_incr_top(L);
  end;
  swapextra(L);  //* correct before option 'L', which can raise a mem. error */
  if (strscan(what, 'L') <> nil) then
    collectvalidlines(L, cl);
  lua_unlock(L);
  //return status;
end;

function lua_getlocal_(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;
var
  name: PChar;
  pos: StkId;
begin
  lua_lock(L);
  swapextra(L);
  if (ar = Nil) then  //* information about non-active function? */
  begin
    if (not isLfunction(L^.top - 1)) then //* not a Lua function? */
      name := Nil
    else  //* consider live variables at function start (parameters) */
      name := luaF_getlocalname(clLvalue(L^.top - 1)^.p, n, 0);
  end
  else //* active function; get information through 'ar' */
  begin
    pos := Nil;  //* to avoid warnings */
    name := findlocal(L, ar^.i_ci, n, pos);
    if (name <> nil) then
    begin
      setobj2s(L, L^.top, pos);
      api_incr_top(L);
    end;
  end;
  swapextra(L);
  lua_unlock(L);
  Result := name;
end;

function lua_setlocal_(const L: Plua_State; const ar: Plua_Debug; const n: Integer): PChar;
var
  name: PChar;
  pos: StkId;
begin
  pos := Nil;  //* to avoid warnings */
  lua_lock(L);
  swapextra(L);
  name := findlocal(L, ar^.i_ci, n, pos);
  if (name <> nil) then
  begin
    setobjs2s(L, pos, L^.top - 1);
    dec(L^.top);  ///* pop value */
  end;
  swapextra(L);
  lua_unlock(L);
  Result := name;
end;

end.

