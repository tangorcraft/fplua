unit lcode;
(*
** Code generator for Lua
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types, fplua_lp_common, lopcodes;

(*
** Marks the end of a patch list. It is an invalid value both as an absolute
** address, and as a list link (would link an element to itself).
*)
const
  NO_JUMP = (-1);


(*
** grep "ORDER OPR" if you change these enums  (ORDER OP)
*)
type
  BinOpr = (
    OPR_ADD, OPR_SUB, OPR_MUL, OPR_MOD, OPR_POW,
    OPR_DIV,
    OPR_IDIV,
    OPR_BAND, OPR_BOR, OPR_BXOR,
    OPR_SHL, OPR_SHR,
    OPR_CONCAT,
    OPR_EQ, OPR_LT, OPR_LE,
    OPR_NE, OPR_GT, OPR_GE,
    OPR_AND, OPR_OR,
    OPR_NOBINOPR
  );


type
  UnOpr = ( OPR_MINUS, OPR_BNOT, OPR_NOT, OPR_LEN, OPR_NOUNOPR );


(* get (pointer to) instruction of given 'expdesc' *)
function getinstruction(const fs: PFuncState; const e: Pexpdesc): PInstruction;

function luaK_codeAsBx(const fs: PFuncState; const o: OpCode; const A, sBx: Integer): Integer;

procedure luaK_setmultret(const fs: PFuncState; const e: Pexpdesc);

procedure luaK_jumpto(const fs: PFuncState; const target: Integer);

//LUAI_FUNC int luaK_codeABx (FuncState *fs, OpCode o, int A, unsigned int Bx);
function luaK_codeABx(const fs: PFuncState; const o: OpCode; const A: Integer;
  const Bc: Cardinal): Integer;
//LUAI_FUNC int luaK_codeABC (FuncState *fs, OpCode o, int A, int B, int C);
function luaK_codeABC(const fs: PFuncState; const o: OpCode; const A, B, C: Integer): Integer;
//LUAI_FUNC int luaK_codek (FuncState *fs, int reg, int k);
function luaK_codek(const fs: PFuncState; const reg, k: Integer): Integer;
//LUAI_FUNC void luaK_fixline (FuncState *fs, int line);
procedure luaK_fixline(const fs: PFuncState; const line: Integer);
//LUAI_FUNC void luaK_nil (FuncState *fs, int from, int n);
procedure luaK_nil(const fs: PFuncState; from: Integer; const n: Integer);
//LUAI_FUNC void luaK_reserveregs (FuncState *fs, int n);
procedure luaK_reserveregs(const fs: PFuncState; const n: Integer);
//LUAI_FUNC void luaK_checkstack (FuncState *fs, int n);
procedure luaK_checkstack(const fs: PFuncState; const n: Integer);
//LUAI_FUNC int luaK_stringK (FuncState *fs, TString *s);
function luaK_stringK(const fs: PFuncState; const s: PTString): Integer;
//LUAI_FUNC int luaK_intK (FuncState *fs, lua_Integer n);
function luaK_intK(const fs: PFuncState; const n: lua_Integer): Integer;
//LUAI_FUNC void luaK_dischargevars (FuncState *fs, expdesc *e);
procedure luaK_dischargevars(const fs: PFuncState; const e: Pexpdesc);
//LUAI_FUNC int luaK_exp2anyreg (FuncState *fs, expdesc *e);
function luaK_exp2anyreg(const fs: PFuncState; const e: Pexpdesc): Integer;
//LUAI_FUNC void luaK_exp2anyregup (FuncState *fs, expdesc *e);
procedure luaK_exp2anyregup(const fs: PFuncState; const e: Pexpdesc);
//LUAI_FUNC void luaK_exp2nextreg (FuncState *fs, expdesc *e);
procedure luaK_exp2nextreg(const fs: PFuncState; const e: Pexpdesc);
//LUAI_FUNC void luaK_exp2val (FuncState *fs, expdesc *e);
procedure luaK_exp2val(const fs: PFuncState; const e: Pexpdesc);
//LUAI_FUNC int luaK_exp2RK (FuncState *fs, expdesc *e);
function luaK_exp2RK(const fs: PFuncState; const e: Pexpdesc): Integer;
//LUAI_FUNC void luaK_self (FuncState *fs, expdesc *e, expdesc *key);
procedure luaK_self(const fs: PFuncState; const e, key: Pexpdesc);
//LUAI_FUNC void luaK_indexed (FuncState *fs, expdesc *t, expdesc *k);
procedure luaK_indexed(const fs: PFuncState; const t, k: Pexpdesc);
//LUAI_FUNC void luaK_goiftrue (FuncState *fs, expdesc *e);
procedure luaK_goiftrue(const fs: PFuncState; const e: Pexpdesc);
//LUAI_FUNC void luaK_goiffalse (FuncState *fs, expdesc *e);
procedure luaK_goiffalse(const fs: PFuncState; const e: Pexpdesc);
//LUAI_FUNC void luaK_storevar (FuncState *fs, expdesc *var, expdesc *e);
procedure luaK_storevar(const fs: PFuncState; const var_, ex: Pexpdesc);
//LUAI_FUNC void luaK_setreturns (FuncState *fs, expdesc *e, int nresults);
procedure luaK_setreturns(const fs: PFuncState; const e: Pexpdesc; const nresults: Integer);
//LUAI_FUNC void luaK_setoneret (FuncState *fs, expdesc *e);
procedure luaK_setoneret(const fs: PFuncState; const e: Pexpdesc);
//LUAI_FUNC int luaK_jump (FuncState *fs);
function luaK_jump(const fs: PFuncState): Integer;
//LUAI_FUNC void luaK_ret (FuncState *fs, int first, int nret);
procedure luaK_ret(const fs: PFuncState; const first, nret: Integer);
//LUAI_FUNC void luaK_patchlist (FuncState *fs, int list, int target);
procedure luaK_patchlist(const fs: PFuncState; const list, target: Integer);
//LUAI_FUNC void luaK_patchtohere (FuncState *fs, int list);
procedure luaK_patchtohere(const fs: PFuncState; const list: Integer);
//LUAI_FUNC void luaK_patchclose (FuncState *fs, int list, int level);
procedure luaK_patchclose(const fs: PFuncState; list, level: Integer);
//LUAI_FUNC void luaK_concat (FuncState *fs, int *l1, int l2);
procedure luaK_concat(const fs: PFuncState; const l1: PInteger; const l2: Integer);
//LUAI_FUNC int luaK_getlabel (FuncState *fs);
function luaK_getlabel(const fs: PFuncState): Integer;
//LUAI_FUNC void luaK_prefix (FuncState *fs, UnOpr op, expdesc *v, int line);
procedure luaK_prefix(const fs: PFuncState; const op: UnOpr; const e: Pexpdesc;
  const line: Integer);
//LUAI_FUNC void luaK_infix (FuncState *fs, BinOpr op, expdesc *v);
procedure luaK_infix(const fs: PFuncState; const op: BinOpr; const v: Pexpdesc);
//LUAI_FUNC void luaK_posfix (FuncState *fs, BinOpr op, expdesc *v1,
//                            expdesc *v2, int line);
procedure luaK_posfix(const fs: PFuncState; const op: BinOpr; const e1, e2: Pexpdesc;
  const line: Integer);
//LUAI_FUNC void luaK_setlist (FuncState *fs, int base, int nelems, int tostore);
procedure luaK_setlist(const fs: PFuncState; const base, nelems, tostore: Integer);

implementation

uses
  fp_lua,
  lgc, llex, lmem, lobject, lstate, ltable, lvm;

(* Maximum number of registers in a Lua function (must fit in 8 bits) *)
const
  MAXREGS = 255;

//#define hasjumps(e) ((e)->t != (e)->f)
function hasjumps(const e: Pexpdesc): Boolean;
begin
  Result := (e^.t <> e^.f);
end;

(*
** If expression is a numeric constant, fills 'v' with its value
** and returns 1. Otherwise, returns 0.
*)
//static int tonumeral(const expdesc *e, TValue *v)
function tonumeral(const e: Pexpdesc; const v: PTValue): Boolean;
begin
  if (hasjumps(e)) then
    Exit(false);  //* not a numeral */
  case (e^.k) of
    VKINT: begin
      if (v<>nil) then setivalue(v, e^.u.ival);
      Result := True;
    end;
    VKFLT: begin
      if (v<>nil) then setfltvalue(v, e^.u.nval);
      Result := True;
    end;
    else
      Result := False;
  end;
end;

(*
** Gets the destination address of a jump instruction. Used to traverse
** a list of jumps.
*)
//static int getjump (FuncState *fs, int pc)
function getjump(const fs: PFuncState; const pc: Integer): Integer;
var
  offset: Integer;
begin
  offset := GETARG_sBx(fs^.f^.code[pc]);
  if (offset = NO_JUMP) then //* point to itself represents end of list */
    Result := NO_JUMP  //* end of list */
  else
    Result := (pc+1)+offset;  //* turn offset into absolute position */
end;


(*
** Fix jump instruction at position 'pc' to jump to 'dest'.
** (Jump addresses are relative in Lua)
*)
//static void fixjump (FuncState *fs, int pc, int dest)
procedure fixjump(const fs: PFuncState; const pc, dest: Integer);
var
  jmp: PInstruction;
  offset: Integer;
begin
  jmp := @(fs^.f^.code[pc]);
  offset := dest - (pc + 1);
  lua_assert(dest <> NO_JUMP);
  if (abs(offset) > MAXARG_sBx) then
    luaX_syntaxerror(fs^.ls, 'control structure too long');
  SETARG_sBx(jmp^, offset);
end;


(*
** Code a "conditional jump", that is, a test or comparison opcode
** followed by a jump. Return jump position.
*)
//static int condjump (FuncState *fs, OpCode op, int A, int B, int C)
function condjump(const fs: PFuncState; const op: OpCode; const A, B, C: Integer): Integer;
begin
  luaK_codeABC(fs, op, A, B, C);
  Result := luaK_jump(fs);
end;


(*
** Returns the position of the instruction "controlling" a given
** jump (that is, its condition), or the jump itself if it is
** unconditional.
*)
//static Instruction *getjumpcontrol (FuncState *fs, int pc)
function getjumpcontrol(const fs: PFuncState; const pc: Integer): PInstruction;
begin
  Result := @(fs^.f^.code[pc]);
  if (pc >= 1) and testTMode(GET_OPCODE((Result-1)^)) then
    Result := Result - 1;
end;


(*
** Patch destination register for a TESTSET instruction.
** If instruction in position 'node' is not a TESTSET, return 0 ("fails").
** Otherwise, if 'reg' is not 'NO_REG', set it as the destination
** register. Otherwise, change instruction to a simple 'TEST' (produces
** no register value)
*)
//static int patchtestreg (FuncState *fs, int node, int reg)
function patchtestreg(const fs: PFuncState; const node, reg: Integer): Boolean;
var
  i: PInstruction;
begin
  i := getjumpcontrol(fs, node);
  if (GET_OPCODE(i^) <> OP_TESTSET) then
    Exit(False);  //* cannot patch other instructions */
  if (reg <> NO_REG) and (reg <> GETARG_B(i^)) then
    SETARG_A(i^, reg)
  else
  begin
     (* no register to put value or register already has the value;
        change instruction to simple test *)
    i^ := CREATE_ABC(OP_TEST, GETARG_B(i^), 0, GETARG_C(i^));
  end;
  Result := True;
end;


(*
** Traverse a list of tests ensuring no one produces a value
*)
//static void removevalues (FuncState *fs, int list)
procedure removevalues(const fs: PFuncState; list: Integer);
begin
  while (list <> NO_JUMP) do
  begin
    patchtestreg(fs, list, NO_REG);
    list := getjump(fs, list);
  end;
end;


(*
** Traverse a list of tests, patching their destination address and
** registers: tests producing values jump to 'vtarget' (and put their
** values in 'reg'), other tests jump to 'dtarget'.
*)
//static void patchlistaux (FuncState *fs, int list, int vtarget, int reg,
//                          int dtarget)
procedure patchlistaux(const fs: PFuncState; list: Integer;
  const vtarget, reg, dtarget: Integer);
var
  next: Integer;
begin
  while (list <> NO_JUMP) do
  begin
    next := getjump(fs, list);
    if (patchtestreg(fs, list, reg)) then
      fixjump(fs, list, vtarget)
    else
      fixjump(fs, list, dtarget);  //* jump to default target */
    list := next;
  end;
end;


(*
** Ensure all pending jumps to current position are fixed (jumping
** to current position with no values) and reset list of pending
** jumps
*)
//static void dischargejpc (FuncState *fs)
procedure dischargejpc(const fs: PFuncState);
begin
  patchlistaux(fs, fs^.jpc, fs^.pc, NO_REG, fs^.pc);
  fs^.jpc := NO_JUMP;
end;


(*
** Emit instruction 'i', checking for array sizes and saving also its
** line information. Return 'i' position.
*)
//static int luaK_code (FuncState *fs, Instruction i)
function luaK_code(const fs: PFuncState; const i: Instruction): Integer;
var
  f: PProto;
begin
  f := fs^.f;
  dischargejpc(fs);  //* 'pc' will change */
  //* put new instruction in code array */
  luaM_growvector(fs^.ls^.L, f^.code, fs^.pc, f^.sizecode, sizeof(Instruction),
                  MAX_INT, 'opcodes');
  f^.code[fs^.pc] := i;
  //* save corresponding line information */
  luaM_growvector(fs^.ls^.L, f^.lineinfo, fs^.pc, f^.sizelineinfo, sizeof(Integer),
                  MAX_INT, 'opcodes');
  f^.lineinfo[fs^.pc] := fs^.ls^.lastline;
  Result := fs^.pc;
  inc(fs^.pc);
end;


(*
** Free register 'reg', if it is neither a constant index nor
** a local variable.
*)
//static void freereg (FuncState *fs, int reg)
procedure freereg(const fs: PFuncState; const reg: Integer);
begin
  if (not ISK(reg)) and (reg >= fs^.nactvar) then
  begin
    dec(fs^.freereg);
    lua_assert(reg = fs^.freereg);
  end;
end;


(*
** Free register used by expression 'e' (if any)
*)
//static void freeexp (FuncState *fs, expdesc *e)
procedure freeexp(const fs: PFuncState; const e: Pexpdesc);
begin
  if (e^.k = VNONRELOC) then
    freereg(fs, e^.u.info);
end;


(*
** Free registers used by expressions 'e1' and 'e2' (if any) in proper
** order.
*)
//static void freeexps (FuncState *fs, expdesc *e1, expdesc *e2)
procedure freeexps(const fs: PFuncState; const e1, e2: Pexpdesc);
var
  r1, r2: Integer;
begin
  if (e1^.k = VNONRELOC) then
    r1 := e1^.u.info
  else
    r1 := -1;

  if (e2^.k = VNONRELOC) then
    r2 := e2^.u.info
  else
    r2 := -1;

  if (r1 > r2) then
  begin
    freereg(fs, r1);
    freereg(fs, r2);
  end
  else
  begin
    freereg(fs, r2);
    freereg(fs, r1);
  end;
end;


(*
** Add constant 'v' to prototype's list of constants (field 'k').
** Use scanner's table to cache position of constants in constant list
** and try to reuse constants. Because some values should not be used
** as keys (nil cannot be a key, integer keys can collapse with float
** keys), the caller must provide a useful 'key' for indexing the cache.
*)
//static int addk (FuncState *fs, TValue *key, TValue *v)
function addk(const fs: PFuncState; const key, v: PTValue): Integer;
var
  L: Plua_State;
  f: PProto;
  idx: PTValue;
  k, oldsize: Integer;
begin
  L := fs^.ls^.L;
  f := fs^.f;
  idx := luaH_set(L, fs^.ls^.h, key);  //* index scanner table */
  if (ttisinteger(idx)) then //* is there an index there? */
  begin
    k := cast_int(ivalue(idx));
    //* correct value? (warning: must distinguish floats from integers!) */
    if (k < fs^.nk) and (ttype(@f^.k[k]) = ttype(v)) and
                      (luaV_rawequalobj(@f^.k[k], v) <> 0) then
      Exit(k);  //* reuse index */
  end;
  //* constant not found; create a new entry */
  oldsize := f^.sizek;
  k := fs^.nk;
  (* numerical value does not need GC barrier;
     table has no metatable, so it does not need to invalidate cache *)
  setivalue(idx, k);
  luaM_growvector(L, f^.k, k, f^.sizek, sizeof(TValue), MAXARG_Ax, 'constants');
  while (oldsize < f^.sizek) do
  begin
    setnilvalue(@f^.k[oldsize]);
    inc(oldsize);
  end;
  setobj(L, @f^.k[k], v);
  inc(fs^.nk);
  luaC_barrier(L, obj2gco(f), v);
  Result := k;
end;


(*
** Emit an "extra argument" instruction (format 'iAx')
*)
//static int codeextraarg (FuncState *fs, int a)
function codeextraarg(const fs: PFuncState; const a: Integer): Integer;
begin
  lua_assert(a <= MAXARG_Ax);
  Result := luaK_code(fs, CREATE_Ax(OP_EXTRAARG, a));
end;


(*
** Add a float to list of constants and return its index.
*)
//static int luaK_numberK (FuncState *fs, lua_Number r)
function luaK_numberK(const fs: PFuncState; const r: lua_Number): Integer;
var
  o: TValue;
begin
  setfltvalue(@o, r);
  Result := addk(fs, @o, @o);  //* use number itself as key */
end;


(*
** Add a boolean to list of constants and return its index.
*)
//static int boolK (FuncState *fs, int b)
function boolK(const fs: PFuncState; const b: lu_int): Integer;
var
  o: TValue;
begin
  setbvalue(@o, b);
  Result := addk(fs, @o, @o);  //* use boolean itself as key */
end;


(*
** Add nil to list of constants and return its index.
*)
//static int nilK (FuncState *fs)
function nilK(const fs: PFuncState): Integer;
var
  k, v: TValue;
begin
  setnilvalue(@v);
  //* cannot use nil as key; instead use table itself to represent nil */
  sethvalue(fs^.ls^.L, @k, fs^.ls^.h);
  Result := addk(fs, @k, @v);
end;


(*
** Ensures expression value is in register 'reg' (and therefore
** 'e' will become a non-relocatable expression).
*)
//static void discharge2reg (FuncState *fs, expdesc *e, int reg)
procedure discharge2reg(const fs: PFuncState; const e: Pexpdesc; const reg: Integer);
var
  pc: PInstruction;
begin
  luaK_dischargevars(fs, e);
  case (e^.k) of
    VNIL:
      luaK_nil(fs, reg, 1);
    VFALSE, VTRUE:
      luaK_codeABC(fs, OP_LOADBOOL, reg, lu_int(e^.k = VTRUE), 0);
    VK:
      luaK_codek(fs, reg, e^.u.info);
    VKFLT:
      luaK_codek(fs, reg, luaK_numberK(fs, e^.u.nval));
    VKINT:
      luaK_codek(fs, reg, luaK_intK(fs, e^.u.ival));
    VRELOCABLE: begin
      pc := getinstruction(fs, e);
      SETARG_A(pc^, reg);  //* instruction will put result in 'reg' */
    end;
    VNONRELOC: begin
      if (reg <> e^.u.info) then
        luaK_codeABC(fs, OP_MOVE, reg, e^.u.info, 0);
    end;
    else begin
      lua_assert(e^.k = VJMP);
      Exit;  //* nothing to do... */
    end;
  end;
  e^.u.info := reg;
  e^.k := VNONRELOC;
end;


(*
** Ensures expression value is in any register.
*)
//static void discharge2anyreg (FuncState *fs, expdesc *e)
procedure discharge2anyreg(const fs: PFuncState; const e: Pexpdesc);
begin
  if (e^.k <> VNONRELOC) then //* no fixed register yet? */
  begin
    luaK_reserveregs(fs, 1);  //* get a register */
    discharge2reg(fs, e, fs^.freereg-1);  //* put value there */
  end;
end;


//static int code_loadbool (FuncState *fs, int A, int b, int jump)
function code_loadbool(const fs: PFuncState; const A, b, jump: Integer): Integer;
begin
  luaK_getlabel(fs);  //* those instructions may be jump targets */
  Result := luaK_codeABC(fs, OP_LOADBOOL, A, b, jump);
end;


(*
** check whether list has any jump that do not produce a value
** or produce an inverted value
*)
//static int need_value (FuncState *fs, int list)
function need_value(const fs: PFuncState; list: Integer): Boolean;
var
  i: Instruction;
begin
  while (list <> NO_JUMP) do
  begin
    i := getjumpcontrol(fs, list)^;
    if (GET_OPCODE(i) <> OP_TESTSET) then
      Exit(True);
    list := getjump(fs, list);
  end;
  Result := False;  //* not found */
end;


(*
** Ensures final expression result (including results from its jump
** lists) is in register 'reg'.
** If expression has jumps, need to patch these jumps either to
** its final position or to "load" instructions (for those tests
** that do not produce values).
*)
//static void exp2reg (FuncState *fs, expdesc *e, int reg)
procedure exp2reg(const fs: PFuncState; const e: Pexpdesc; const reg: Integer);
var
  final, p_f, p_t, fj: Integer;
begin
  discharge2reg(fs, e, reg);
  if (e^.k = VJMP) then //* expression itself is a test? */
    luaK_concat(fs, @e^.t, e^.u.info);  //* put this jump in 't' list */
  if (hasjumps(e)) then
  begin
    //int final;  //* position after whole expression */
    p_f := NO_JUMP;  //* position of an eventual LOAD false */
    p_t := NO_JUMP;  //* position of an eventual LOAD true */
    if (need_value(fs, e^.t) or need_value(fs, e^.f)) then
    begin
      if (e^.k = VJMP) then
        fj := NO_JUMP
      else
        fj := luaK_jump(fs);
      p_f := code_loadbool(fs, reg, 0, 1);
      p_t := code_loadbool(fs, reg, 1, 0);
      luaK_patchtohere(fs, fj);
    end;
    final := luaK_getlabel(fs);
    patchlistaux(fs, e^.f, final, reg, p_f);
    patchlistaux(fs, e^.t, final, reg, p_t);
  end;
  e^.f := NO_JUMP;
  e^.t := NO_JUMP;
  e^.u.info := reg;
  e^.k := VNONRELOC;
end;

(*
** Negate condition 'e' (where 'e' is a comparison).
*)
//static void negatecondition (FuncState *fs, expdesc *e)
procedure negatecondition(const fs: PFuncState; const e: Pexpdesc);
var
  pc: PInstruction;
  a: Boolean;
begin
  pc := getjumpcontrol(fs, e^.u.info);
  lua_assert(testTMode(GET_OPCODE(pc^)) and (GET_OPCODE(pc^) <> OP_TESTSET) and
                                            (GET_OPCODE(pc^) <> OP_TEST));
  a := GETARG_A(pc^) = 0; // negate argA
  SETARG_A(pc^, lu_int(a));
end;


(*
** Emit instruction to jump if 'e' is 'cond' (that is, if 'cond'
** is true, code will jump if 'e' is true.) Return jump position.
** Optimize when 'e' is 'not' something, inverting the condition
** and removing the 'not'.
*)
//static int jumponcond (FuncState *fs, expdesc *e, int cond)
function jumponcond(const fs: PFuncState; const e: Pexpdesc; const cond: Integer): Integer;
var
  ie: Instruction;
begin
  if (e^.k = VRELOCABLE) then
  begin
    ie := getinstruction(fs, e)^;
    if (GET_OPCODE(ie) = OP_NOT) then
    begin
      dec(fs^.pc);  //* remove previous OP_NOT */
      Result := condjump(fs, OP_TEST, GETARG_B(ie), 0, lu_int(cond = 0));
    end;
    //* else go through */
  end;
  discharge2anyreg(fs, e);
  freeexp(fs, e);
  Result := condjump(fs, OP_TESTSET, NO_REG, e^.u.info, cond);
end;


(*
** Code 'not e', doing constant folding.
*)
//static void codenot (FuncState *fs, expdesc *e)
procedure codenot(const fs: PFuncState; const e: Pexpdesc);
var
  temp: Integer;
begin
  luaK_dischargevars(fs, e);
  case (e^.k) of
    VNIL, VFALSE:
      e^.k := VTRUE;  //* true == not nil == not false */
    VK, VKFLT, VKINT, VTRUE:
      e^.k := VFALSE;  //* false == not "x" == not 0.5 == not 1 == not true */
    VJMP:
      negatecondition(fs, e);
    VRELOCABLE,
    VNONRELOC: begin
      discharge2anyreg(fs, e);
      freeexp(fs, e);
      e^.u.info := luaK_codeABC(fs, OP_NOT, 0, e^.u.info, 0);
      e^.k := VRELOCABLE;
    end;
    else lua_assert(0);  //* cannot happen */
  end;
  //* interchange true and false lists */
  //{
  temp := e^.f;
  e^.f := e^.t;
  e^.t := temp;
  //}
  removevalues(fs, e^.f);  //* values are useless when negated */
  removevalues(fs, e^.t);
end;


(*
** Return false if folding can raise an error.
** Bitwise operations need operands convertible to integers; division
** operations cannot have 0 as divisor.
*)
//static int validop (int op, TValue *v1, TValue *v2)
function validop(const op: Integer; const v1, v2: PTValue): Boolean;
var
  i: lua_Integer;
begin
  case (op) of
    LUA_OPBAND, LUA_OPBOR, LUA_OPBXOR,
    LUA_OPSHL, LUA_OPSHR, LUA_OPBNOT: //* conversion errors */
      Result := (tointeger(v1, @i) and tointeger(v2, @i));

    LUA_OPDIV, LUA_OPIDIV, LUA_OPMOD:  //* division by 0 */
      Result := (nvalue(v2) <> 0);
    else Result := True;  //* everything else is valid */
  end;
end;


(*
** Try to "constant-fold" an operation; return 1 iff successful.
** (In this case, 'e1' has the final result.)
*)
//static int constfolding (FuncState *fs, int op, expdesc *e1,
//                                                const expdesc *e2)
function constfolding(const fs: PFuncState; const op: Integer; const e1, e2: Pexpdesc): Boolean;
var
  v1, v2, res: TValue;
  n: lua_Number;
begin
  if (not tonumeral(e1, @v1) or not tonumeral(e2, @v2) or not validop(op, @v1, @v2)) then
    Exit(False);  //* non-numeric operands or not safe to fold */
  luaO_arith(fs^.ls^.L, op, @v1, @v2, @res);  //* does operation */
  if (ttisinteger(@res)) then
  begin
    e1^.k := VKINT;
    e1^.u.ival := ivalue(@res);
  end
  else  //* folds neither NaN nor 0.0 (to avoid problems with -0.0) */
  begin
    n := fltvalue(@res);
    if luai_numisnan(n) or (n = 0) then
      Exit(False);
    e1^.k := VKFLT;
    e1^.u.nval := n;
  end;
  Result := True;
end;


(*
** Emit code for unary expressions that "produce values"
** (everything but 'not').
** Expression to produce final result will be encoded in 'e'.
*)
//static void codeunexpval (FuncState *fs, OpCode op, expdesc *e, int line)
procedure codeunexpval(const fs: PFuncState; const op: OpCode; const e: Pexpdesc;
  const line: Integer);
var
  r: Integer;
begin
  r := luaK_exp2anyreg(fs, e);  //* opcodes operate only on registers */
  freeexp(fs, e);
  e^.u.info := luaK_codeABC(fs, op, 0, r, 0);  //* generate opcode */
  e^.k := VRELOCABLE;  //* all those operations are relocatable */
  luaK_fixline(fs, line);
end;


(*
** Emit code for binary expressions that "produce values"
** (everything but logical operators 'and'/'or' and comparison
** operators).
** Expression to produce final result will be encoded in 'e1'.
** Because 'luaK_exp2RK' can free registers, its calls must be
** in "stack order" (that is, first on 'e2', which may have more
** recent registers to be released).
*)
//static void codebinexpval (FuncState *fs, OpCode op,
//                           expdesc *e1, expdesc *e2, int line)
procedure codebinexpval(const fs: PFuncState; const op: OpCode; const e1, e2: Pexpdesc;
  const line: Integer);
var
  rk1, rk2: Integer;
begin
  rk2 := luaK_exp2RK(fs, e2);  //* both operands are "RK" */
  rk1 := luaK_exp2RK(fs, e1);
  freeexps(fs, e1, e2);
  e1^.u.info := luaK_codeABC(fs, op, 0, rk1, rk2);  //* generate opcode */
  e1^.k := VRELOCABLE;  //* all those operations are relocatable */
  luaK_fixline(fs, line);
end;


(*
** Emit code for comparisons.
** 'e1' was already put in R/K form by 'luaK_infix'.
*)
//static void codecomp (FuncState *fs, BinOpr opr, expdesc *e1, expdesc *e2)
procedure codecomp(const fs: PFuncState; const opr: BinOpr; const e1, e2: Pexpdesc);
var
  rk1, rk2: Integer;
  op: OpCode;
begin
  if (e1^.k = VK) then
    rk1 := RKASK(e1^.u.info)
  else
    rk1 := check_exp(e1^.k = VNONRELOC, e1^.u.info);
  rk2 := luaK_exp2RK(fs, e2);
  freeexps(fs, e1, e2);
  case (opr) of
    OPR_NE:   //* '(a ~= b)' ==> 'not (a == b)' */
      e1^.u.info := condjump(fs, OP_EQ, 0, rk1, rk2);
    OPR_GT, OPR_GE: begin
      //* '(a > b)' ==> '(b < a)';  '(a >= b)' ==> '(b <= a)' */
      op := OpCode((ord(opr) - ord(OPR_NE)) + ord(OP_EQ));
      e1^.u.info := condjump(fs, op, 1, rk2, rk1);  //* invert operands */
    end;
    else begin  //* '==', '<', '<=' use their own opcodes */
      op := OpCode((ord(opr) - ord(OPR_EQ)) + ord(OP_EQ));
      e1^.u.info := condjump(fs, op, 1, rk1, rk2);
    end;
  end;
  e1^.k := VJMP;
end;


//#define getinstruction(fs,e)  ((fs)->f->code[(e)->u.info])
function getinstruction(const fs: PFuncState; const e: Pexpdesc): PInstruction;
begin
  Result := fs^.f^.code + e^.u.info;
end;

//#define luaK_codeAsBx(fs,o,A,sBx)     luaK_codeABx(fs,o,A,(sBx)+MAXARG_sBx)
function luaK_codeAsBx(const fs: PFuncState; const o: OpCode; const A, sBx: Integer): Integer;
begin
  Result := luaK_codeABx(fs, o, A, sBx + MAXARG_sBx);
end;

//#define luaK_setmultret(fs,e) luaK_setreturns(fs, e, LUA_MULTRET)
procedure luaK_setmultret(const fs: PFuncState; const e: Pexpdesc);
begin
  luaK_setreturns(fs, e, LUA_MULTRET);
end;

//#define luaK_jumpto(fs,t)     luaK_patchlist(fs, luaK_jump(fs), t)
procedure luaK_jumpto(const fs: PFuncState; const target: Integer);
begin
  luaK_patchlist(fs, luaK_jump(fs), target);
end;

(*
** Format and emit an 'iABx' instruction.
*)
function luaK_codeABx(const fs: PFuncState; const o: OpCode; const A: Integer;
  const Bc: Cardinal): Integer;
begin
  lua_assert((getOpMode(o) = iABx) or (getOpMode(o) = iAsBx));
  lua_assert(getCMode(o) = OpArgN);
  lua_assert((a <= MAXARG_A) and (bc <= MAXARG_Bx));
  Result := luaK_code(fs, CREATE_ABx(o, a, bc));
end;

(*
** Format and emit an 'iABC' instruction. (Assertions check consistency
** of parameters versus opcode.)
*)
function luaK_codeABC(const fs: PFuncState; const o: OpCode; const A, B, C: Integer): Integer;
begin
  lua_assert(getOpMode(o) = iABC);
  lua_assert((getBMode(o) <> OpArgN) or (b = 0));
  lua_assert((getCMode(o) <> OpArgN) or (c = 0));
  lua_assert((a <= MAXARG_A) and (b <= MAXARG_B) and (c <= MAXARG_C));
  Result := luaK_code(fs, CREATE_ABC(o, a, b, c));
end;

(*
** Emit a "load constant" instruction, using either 'OP_LOADK'
** (if constant index 'k' fits in 18 bits) or an 'OP_LOADKX'
** instruction with "extra argument".
*)
function luaK_codek(const fs: PFuncState; const reg, k: Integer): Integer;
begin
  if (k <= MAXARG_Bx) then
    Result := luaK_codeABx(fs, OP_LOADK, reg, k)
  else
  begin
    Result := luaK_codeABx(fs, OP_LOADKX, reg, 0);
    codeextraarg(fs, k);
  end;
end;

(*
** Change line information associated with current position.
*)
procedure luaK_fixline(const fs: PFuncState; const line: Integer);
begin
  fs^.f^.lineinfo[fs^.pc - 1] := line;
end;

(*
** Create a OP_LOADNIL instruction, but try to optimize: if the previous
** instruction is also OP_LOADNIL and ranges are compatible, adjust
** range of previous instruction instead of emitting a new one. (For
** instance, 'local a; local b' will generate a single opcode.)
*)
procedure luaK_nil(const fs: PFuncState; from: Integer; const n: Integer);
var
  previous: PInstruction;
  l, pfrom, pl: Integer;
begin
  l := from + n - 1;  //* last register to set nil */
  if (fs^.pc > fs^.lasttarget) then  //* no jumps to current position? */
  begin
    previous := @(fs^.f^.code[fs^.pc-1]);
    if (GET_OPCODE(previous^) = OP_LOADNIL) then  //* previous is LOADNIL? */
    begin
      pfrom := GETARG_A(previous^);  //* get previous range */
      pl := pfrom + GETARG_B(previous^);
      if ( (pfrom <= from) and (from <= (pl + 1)) ) or
         ( (from <= pfrom) and (pfrom <= (l + 1)) ) then  //* can connect both? */
      begin
        if (pfrom < from) then from := pfrom;  //* from = min(from, pfrom) */
        if (pl > l) then l := pl;  //* l = max(l, pl) */
        SETARG_A(previous^, from);
        SETARG_B(previous^, l - from);
        Exit;
      end;
    end;  //* else go through */
  end;
  luaK_codeABC(fs, OP_LOADNIL, from, n - 1, 0);  //* else no optimization */
end;

(*
** Reserve 'n' registers in register stack
*)
procedure luaK_reserveregs(const fs: PFuncState; const n: Integer);
begin
  luaK_checkstack(fs, n);
  fs^.freereg := fs^.freereg + n;
end;

(*
** Check register-stack level, keeping track of its maximum size
** in field 'maxstacksize'
*)
procedure luaK_checkstack(const fs: PFuncState; const n: Integer);
var
  newstack: Integer;
begin
  newstack := fs^.freereg + n;
  if (newstack > fs^.f^.maxstacksize) then
  begin
    if (newstack >= MAXREGS) then
      luaX_syntaxerror(fs^.ls,
        'function or expression needs too many registers');
    fs^.f^.maxstacksize := cast_byte(newstack);
  end;
end;

(*
** Add a string to list of constants and return its index.
*)
function luaK_stringK(const fs: PFuncState; const s: PTString): Integer;
var
  o: TValue;
begin
  setsvalue(fs^.ls^.L, @o, s);
  Result := addk(fs, @o, @o);  //* use string itself as key */
end;

(*
** Add an integer to list of constants and return its index.
** Integers use userdata as keys to avoid collision with floats with
** same value; conversion to 'void*' is used only for hashing, so there
** are no "precision" problems.
*)
function luaK_intK(const fs: PFuncState; const n: lua_Integer): Integer;
var
  k, o: TValue;
begin
  setpvalue(@k, Pointer(SizeUInt(n)));
  setivalue(@o, n);
  Result := addk(fs, @k, @o);
end;

(*
** Ensure that expression 'e' is not a variable.
*)
procedure luaK_dischargevars(const fs: PFuncState; const e: Pexpdesc);
var
  op: OpCode;
begin
  case (e^.k) of
    VLOCAL: begin  //* already in a register */
      e^.k := VNONRELOC;  //* becomes a non-relocatable value */
    end;
    VUPVAL: begin //* move value to some (pending) register */
      e^.u.info := luaK_codeABC(fs, OP_GETUPVAL, 0, e^.u.info, 0);
      e^.k := VRELOCABLE;
    end;
    VINDEXED: begin
      freereg(fs, e^.u.ind.idx);
      if (e^.u.ind.vt = ord(VLOCAL)) then  //* is 't' in a register? */
      begin
        freereg(fs, e^.u.ind.t);
        op := OP_GETTABLE;
      end
      else
      begin
        lua_assert(e^.u.ind.vt = ord(VUPVAL));
        op := OP_GETTABUP;  //* 't' is in an upvalue */
      end;
      e^.u.info := luaK_codeABC(fs, op, 0, e^.u.ind.t, e^.u.ind.idx);
      e^.k := VRELOCABLE;
    end;
    VVARARG, VCALL:
      luaK_setoneret(fs, e);
    //else break;  //* there is one value available (somewhere) */
  end;
end;

(*
** Ensures final expression result (including results from its jump
** lists) is in some (any) register and return that register.
*)
function luaK_exp2anyreg(const fs: PFuncState; const e: Pexpdesc): Integer;
begin
  luaK_dischargevars(fs, e);
  if (e^.k = VNONRELOC) then //* expression already has a register? */
  begin
    if (not hasjumps(e)) then //* no jumps? */
      Exit(e^.u.info);  //* result is already in a register */
    if (e^.u.info >= fs^.nactvar) then //* reg. is not a local? */
    begin
      exp2reg(fs, e, e^.u.info);  //* put final result in it */
      exit(e^.u.info);
    end;
  end;
  luaK_exp2nextreg(fs, e);  //* otherwise, use next available register */
  Result := e^.u.info;
end;

(*
** Ensures final expression result is either in a register or in an
** upvalue.
*)
procedure luaK_exp2anyregup(const fs: PFuncState; const e: Pexpdesc);
begin
  if (e^.k <> VUPVAL) or hasjumps(e) then
    luaK_exp2anyreg(fs, e);
end;

(*
** Ensures final expression result (including results from its jump
** lists) is in next available register.
*)
procedure luaK_exp2nextreg(const fs: PFuncState; const e: Pexpdesc);
begin
  luaK_dischargevars(fs, e);
  freeexp(fs, e);
  luaK_reserveregs(fs, 1);
  exp2reg(fs, e, fs^.freereg - 1);
end;

(*
** Ensures final expression result is either in a register or it is
** a constant.
*)
procedure luaK_exp2val(const fs: PFuncState; const e: Pexpdesc);
begin
  if (hasjumps(e)) then
    luaK_exp2anyreg(fs, e)
  else
    luaK_dischargevars(fs, e);
end;

(*
** Ensures final expression result is in a valid R/K index
** (that is, it is either in a register or in 'k' with an index
** in the range of R/K indices).
** Returns R/K index.
*)
function luaK_exp2RK(const fs: PFuncState; const e: Pexpdesc): Integer;
label case_vk;
begin
  luaK_exp2val(fs, e);
  case (e^.k) of //* move constants to 'k' */
    VTRUE: begin e^.u.info := boolK(fs, 1); goto case_vk; end;
    VFALSE: begin e^.u.info := boolK(fs, 0); goto case_vk; end;
    VNIL: begin e^.u.info := nilK(fs); goto case_vk; end;
    VKINT: begin e^.u.info := luaK_intK(fs, e^.u.ival); goto case_vk; end;
    VKFLT: begin e^.u.info := luaK_numberK(fs, e^.u.nval); goto case_vk; end;
    VK: begin
case_vk:
      e^.k := VK;
      if (e^.u.info <= MAXINDEXRK) then //* constant fits in 'argC'? */
        Exit( RKASK(e^.u.info) );
    end;
  end;
  //* not a constant in the right range: put it in a register */
  Result := luaK_exp2anyreg(fs, e);
end;

(*
** Emit SELF instruction (convert expression 'e' into 'e:key(e,').
*)
procedure luaK_self(const fs: PFuncState; const e, key: Pexpdesc);
var
  ereg: Integer;
begin
  luaK_exp2anyreg(fs, e);
  ereg := e^.u.info;  //* register where 'e' was placed */
  freeexp(fs, e);
  e^.u.info := fs^.freereg;  //* base register for op_self */
  e^.k := VNONRELOC;  //* self expression has a fixed register */
  luaK_reserveregs(fs, 2);  //* function and 'self' produced by op_self */
  luaK_codeABC(fs, OP_SELF, e^.u.info, ereg, luaK_exp2RK(fs, key));
  freeexp(fs, key);
end;

(*
** Create expression 't[k]'. 't' must have its final result already in a
** register or upvalue.
*)
procedure luaK_indexed(const fs: PFuncState; const t, k: Pexpdesc);
begin
  lua_assert((not hasjumps(t) and vkisinreg(t^.k)) or (t^.k = VUPVAL));
  t^.u.ind.t := t^.u.info;  //* register or upvalue index */
  t^.u.ind.idx := luaK_exp2RK(fs, k);  //* R/K index for key */
  if (t^.k = VUPVAL) then
    t^.u.ind.vt := ord(VUPVAL)
  else
    t^.u.ind.vt := ord(VLOCAL);
  t^.k := VINDEXED;
end;

(*
** Emit code to go through if 'e' is true, jump otherwise.
*)
procedure luaK_goiftrue(const fs: PFuncState; const e: Pexpdesc);
var
  pc: Integer;
begin
  //int pc;  //* pc of new jump */
  luaK_dischargevars(fs, e);
  case (e^.k) of
    VJMP: begin  //* condition? */
      negatecondition(fs, e);  //* jump when it is false */
      pc := e^.u.info;  //* save jump position */
    end;
    VK, VKFLT, VKINT, VTRUE: begin
      pc := NO_JUMP;  //* always true; do nothing */
    end;
    else begin
      pc := jumponcond(fs, e, 0);  //* jump when false */
    end;
  end;
  luaK_concat(fs, @e^.f, pc);  //* insert new jump in false list */
  luaK_patchtohere(fs, e^.t);  //* true list jumps to here (to go through) */
  e^.t := NO_JUMP;
end;

(*
** Emit code to go through if 'e' is false, jump otherwise.
*)
procedure luaK_goiffalse(const fs: PFuncState; const e: Pexpdesc);
var
  pc: Integer;
begin
  //int pc;  //* pc of new jump */
  luaK_dischargevars(fs, e);
  case (e^.k) of
    VJMP:
      pc := e^.u.info;  //* already jump if true */
    VNIL, VFALSE:
      pc := NO_JUMP;  //* always false; do nothing */
    else
      pc := jumponcond(fs, e, 1);  //* jump if true */
  end;
  luaK_concat(fs, @e^.t, pc);  //* insert new jump in 't' list */
  luaK_patchtohere(fs, e^.f);  //* false list jumps to here (to go through) */
  e^.f := NO_JUMP;
end;

(*
** Generate code to store result of expression 'ex' into variable 'var'.
*)
procedure luaK_storevar(const fs: PFuncState; const var_, ex: Pexpdesc);
var
  e: Integer;
  op: OpCode;
begin
  case (var_^.k) of
    VLOCAL: begin
      freeexp(fs, ex);
      exp2reg(fs, ex, var_^.u.info);  //* compute 'ex' into proper place */
      exit;
    end;
    VUPVAL: begin
      e := luaK_exp2anyreg(fs, ex);
      luaK_codeABC(fs, OP_SETUPVAL, e, var_^.u.info, 0);
    end;
    VINDEXED: begin
      if (var_^.u.ind.vt = ord(VLOCAL)) then
        op := OP_SETTABLE
      else
        op := OP_SETTABUP;
      e := luaK_exp2RK(fs, ex);
      luaK_codeABC(fs, op, var_^.u.ind.t, var_^.u.ind.idx, e);
    end;
    else lua_assert(0);  //* invalid var kind to store */
  end;
  freeexp(fs, ex);
end;

(*
** Fix an expression to return the number of results 'nresults'.
** Either 'e' is a multi-ret expression (function call or vararg)
** or 'nresults' is LUA_MULTRET (as any expression can satisfy that).
*)
procedure luaK_setreturns(const fs: PFuncState; const e: Pexpdesc; const nresults: Integer);
var
  pc: PInstruction;
begin
  if (e^.k = VCALL) then  //* expression is an open function call? */
  begin
    SETARG_C(getinstruction(fs, e)^, nresults + 1);
  end
  else if (e^.k = VVARARG) then
  begin
    pc := getinstruction(fs, e);
    SETARG_B(pc^, nresults + 1);
    SETARG_A(pc^, fs^.freereg);
    luaK_reserveregs(fs, 1);
  end
  else lua_assert(nresults = LUA_MULTRET);
end;

(*
** Fix an expression to return one result.
** If expression is not a multi-ret expression (function call or
** vararg), it already returns one result, so nothing needs to be done.
** Function calls become VNONRELOC expressions (as its result comes
** fixed in the base register of the call), while vararg expressions
** become VRELOCABLE (as OP_VARARG puts its results where it wants).
** (Calls are created returning one result, so that does not need
** to be fixed.)
*)
procedure luaK_setoneret(const fs: PFuncState; const e: Pexpdesc);
begin
  if (e^.k = VCALL) then  //* expression is an open function call? */
  begin
    //* already returns 1 value */
    lua_assert(GETARG_C(getinstruction(fs, e)^) = 2);
    e^.k := VNONRELOC;  //* result has fixed position */
    e^.u.info := GETARG_A(getinstruction(fs, e)^);
  end
  else if (e^.k = VVARARG) then
  begin
    SETARG_B(getinstruction(fs, e)^, 2);
    e^.k := VRELOCABLE;  //* can relocate its simple result */
  end;
end;

(*
** Create a jump instruction and return its position, so its destination
** can be fixed later (with 'fixjump'). If there are jumps to
** this position (kept in 'jpc'), link them all together so that
** 'patchlistaux' will fix all them directly to the final destination.
*)
function luaK_jump(const fs: PFuncState): Integer;
var
  jpc: Integer;
begin
  jpc := fs^.jpc;  //* save list of jumps to here */
  //int j;
  fs^.jpc := NO_JUMP;  //* no more jumps to here */
  Result := luaK_codeAsBx(fs, OP_JMP, 0, NO_JUMP);
  luaK_concat(fs, @Result, jpc);  //* keep them on hold */
  //return j;
end;

(*
** Code a 'return' instruction
*)
procedure luaK_ret(const fs: PFuncState; const first, nret: Integer);
begin
  luaK_codeABC(fs, OP_RETURN, first, nret+1, 0);
end;

(*
** Path all jumps in 'list' to jump to 'target'.
** (The assert means that we cannot fix a jump to a forward address
** because we only know addresses once code is generated.)
*)
procedure luaK_patchlist(const fs: PFuncState; const list, target: Integer);
begin
  if (target = fs^.pc) then //* 'target' is current position? */
    luaK_patchtohere(fs, list)  //* add list to pending jumps */
  else
  begin
    lua_assert(target < fs^.pc);
    patchlistaux(fs, list, target, NO_REG, target);
  end;
end;

(*
** Add elements in 'list' to list of pending jumps to "here"
** (current position)
*)
procedure luaK_patchtohere(const fs: PFuncState; const list: Integer);
begin
  luaK_getlabel(fs);  //* mark "here" as a jump target */
  luaK_concat(fs, @fs^.jpc, list);
end;

(*
** Path all jumps in 'list' to close upvalues up to given 'level'
** (The assertion checks that jumps either were closing nothing
** or were closing higher levels, from inner blocks.)
*)
procedure luaK_patchclose(const fs: PFuncState; list, level: Integer);
begin
  inc(level);  //* argument is +1 to reserve 0 as non-op */
  while (list <> NO_JUMP) do
  begin
    lua_assert((GET_OPCODE(fs^.f^.code[list]) = OP_JMP) and
               ( (GETARG_A(fs^.f^.code[list]) = 0) or
                 (GETARG_A(fs^.f^.code[list]) >= level) ));
    SETARG_A(fs^.f^.code[list], level);
    list := getjump(fs, list);
  end;
end;

(*
** Concatenate jump-list 'l2' into jump-list 'l1'
*)
procedure luaK_concat(const fs: PFuncState; const l1: PInteger; const l2: Integer);
var
  list, next: integer;
begin
  if (l2 = NO_JUMP) then //* nothing to concatenate? */
    Exit
  else if (l1^ = NO_JUMP) then //* no original list? */
    l1^ := l2  //* 'l1' points to 'l2' */
  else
  begin
    list := l1^;
    next := getjump(fs, list);
    while (next <> NO_JUMP) do //* find last element */
    begin
      list := next;
      next := getjump(fs, list);
    end;
    fixjump(fs, list, l2);  //* last element links to 'l2' */
  end;
end;

(*
** returns current 'pc' and marks it as a jump target (to avoid wrong
** optimizations with consecutive instructions not in the same basic block).
*)
function luaK_getlabel(const fs: PFuncState): Integer;
begin
  fs^.lasttarget := fs^.pc;
  Result := fs^.pc;
end;

(*
** Apply prefix operation 'op' to expression 'e'.
*)
procedure luaK_prefix(const fs: PFuncState; const op: UnOpr; const e: Pexpdesc;
  const line: Integer);
label
  case_len;
const
  ef: expdesc = (k: VKINT; u:(ival: 0); t: NO_JUMP; f: NO_JUMP);
begin
  case (op) of
    OPR_MINUS, OPR_BNOT: begin //* use 'ef' as fake 2nd operand */
      if (constfolding(fs, ord(op) + LUA_OPUNM, e, @ef)) then
        Exit;
      //* FALLTHROUGH */
      goto case_len;
    end;
    OPR_LEN: begin
case_len:
      codeunexpval(fs, OpCode(ord(op) + ord(OP_UNM)), e, line);
    end;
    OPR_NOT:
      codenot(fs, e);
    else lua_assert(0);
  end;
end;

(*
** Process 1st operand 'v' of binary operation 'op' before reading
** 2nd operand.
*)
procedure luaK_infix(const fs: PFuncState; const op: BinOpr; const v: Pexpdesc);
begin
  case (op) of
    OPR_AND:
      luaK_goiftrue(fs, v);  //* go ahead only if 'v' is true */
    OPR_OR:
      luaK_goiffalse(fs, v);  //* go ahead only if 'v' is false */
    OPR_CONCAT:
      luaK_exp2nextreg(fs, v);  //* operand must be on the 'stack' */
    OPR_ADD, OPR_SUB,
    OPR_MUL, OPR_DIV, OPR_IDIV,
    OPR_MOD, OPR_POW,
    OPR_BAND, OPR_BOR, OPR_BXOR,
    OPR_SHL, OPR_SHR: begin
      if (not tonumeral(v, Nil)) then
        luaK_exp2RK(fs, v);
      //* else keep numeral, which may be folded with 2nd operand */
    end;
    else
      luaK_exp2RK(fs, v);
  end;
end;

(*
** Finalize code for binary operation, after reading 2nd operand.
** For '(a .. b .. c)' (which is '(a .. (b .. c))', because
** concatenation is right associative), merge second CONCAT into first
** one.
*)
procedure luaK_posfix(const fs: PFuncState; const op: BinOpr; const e1, e2: Pexpdesc;
  const line: Integer);
begin
  case (op) of
    OPR_AND: begin
      lua_assert(e1^.t = NO_JUMP);  //* list closed by 'luK_infix' */
      luaK_dischargevars(fs, e2);
      luaK_concat(fs, @e2^.f, e1^.f);
      e1^ := e2^;
    end;
    OPR_OR: begin
      lua_assert(e1^.f = NO_JUMP);  //* list closed by 'luK_infix' */
      luaK_dischargevars(fs, e2);
      luaK_concat(fs, @e2^.t, e1^.t);
      e1^ := e2^;
    end;
    OPR_CONCAT: begin
      luaK_exp2val(fs, e2);
      if (e2^.k = VRELOCABLE) and
         (GET_OPCODE(getinstruction(fs, e2)^) = OP_CONCAT) then
      begin
        lua_assert(e1^.u.info = GETARG_B(getinstruction(fs, e2)^)-1);
        freeexp(fs, e1);
        SETARG_B(getinstruction(fs, e2)^, e1^.u.info);
        e1^.k := VRELOCABLE;
        e1^.u.info := e2^.u.info;
      end
      else
      begin
        luaK_exp2nextreg(fs, e2);  //* operand must be on the 'stack' */
        codebinexpval(fs, OP_CONCAT, e1, e2, line);
      end;
    end;
    OPR_ADD, OPR_SUB, OPR_MUL, OPR_DIV,
    OPR_IDIV, OPR_MOD, OPR_POW,
    OPR_BAND, OPR_BOR, OPR_BXOR,
    OPR_SHL, OPR_SHR: begin
      if (not constfolding(fs, ord(op) + LUA_OPADD, e1, e2)) then
        codebinexpval(fs, OpCode(ord(op) + ord(OP_ADD)), e1, e2, line);
    end;
    OPR_EQ, OPR_LT, OPR_LE,
    OPR_NE, OPR_GT, OPR_GE:
      codecomp(fs, op, e1, e2);
    else lua_assert(0);
  end;
end;

(*
** Emit a SETLIST instruction.
** 'base' is register that keeps table;
** 'nelems' is #table plus those to be stored now;
** 'tostore' is number of values (in registers 'base + 1',...) to add to
** table (or LUA_MULTRET to add up to stack top).
*)
procedure luaK_setlist(const fs: PFuncState; const base, nelems, tostore: Integer);
var
  c, b: Integer;
begin
  c := (nelems - 1) div LFIELDS_PER_FLUSH + 1;
  if (tostore = LUA_MULTRET) then
    b := 0
  else
    b := tostore;
  lua_assert((tostore <> 0) and (tostore <= LFIELDS_PER_FLUSH));
  if (c <= MAXARG_C) then
    luaK_codeABC(fs, OP_SETLIST, base, b, c)
  else if (c <= MAXARG_Ax) then
  begin
    luaK_codeABC(fs, OP_SETLIST, base, b, 0);
    codeextraarg(fs, c);
  end
  else
    luaX_syntaxerror(fs^.ls, 'constructor too long');
  fs^.freereg := base + 1;  //* free registers with list values */
end;

end.

