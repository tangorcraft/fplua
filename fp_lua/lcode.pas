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
  const Bx: Cardinal): Integer;
//LUAI_FUNC int luaK_codeABC (FuncState *fs, OpCode o, int A, int B, int C);
function luaK_codeABC(const fs: PFuncState; const o: OpCode; const A, B, C: Integer): Integer;
//LUAI_FUNC int luaK_codek (FuncState *fs, int reg, int k);
function luaK_codek(const fs: PFuncState; const reg, k: Integer): Integer;
//LUAI_FUNC void luaK_fixline (FuncState *fs, int line);
procedure luaK_fixline(const fs: PFuncState; const line: Integer);
//LUAI_FUNC void luaK_nil (FuncState *fs, int from, int n);
procedure luaK_nil(const fs: PFuncState; const from, n: Integer);
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
procedure luaK_storevar(const fs: PFuncState; const var_, e: Pexpdesc);
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
procedure luaK_patchclose(const fs: PFuncState; const list, level: Integer);
//LUAI_FUNC void luaK_concat (FuncState *fs, int *l1, int l2);
procedure luaK_concat(const fs: PFuncState; const l1: PInteger; const l2: Integer);
//LUAI_FUNC int luaK_getlabel (FuncState *fs);
function luaK_getlabel(const fs: PFuncState): Integer;
//LUAI_FUNC void luaK_prefix (FuncState *fs, UnOpr op, expdesc *v, int line);
procedure luaK_prefix(const fs: PFuncState; const op: UnOpr; const v: Pexpdesc;
  const line: Integer);
//LUAI_FUNC void luaK_infix (FuncState *fs, BinOpr op, expdesc *v);
procedure luaK_infix(const fs: PFuncState; const op: BinOpr; const v: Pexpdesc);
//LUAI_FUNC void luaK_posfix (FuncState *fs, BinOpr op, expdesc *v1,
//                            expdesc *v2, int line);
procedure luaK_posfix(const fs: PFuncState; const op: BinOpr; const v1, v2: Pexpdesc;
  const line: Integer);
//LUAI_FUNC void luaK_setlist (FuncState *fs, int base, int nelems, int tostore);
procedure luaK_setlist(const fs: PFuncState; const base, nelems, tostore: Integer);

implementation

//#define getinstruction(fs,e)  ((fs)->f->code[(e)->u.info])
function getinstruction(const fs: PFuncState; const e: Pexpdesc): PInstruction;
begin
  Result := fs^.f^.code + e^.u.info;
end;

//#define luaK_codeAsBx(fs,o,A,sBx)     luaK_codeABx(fs,o,A,(sBx)+MAXARG_sBx)
function luaK_codeAsBx(const fs: PFuncState; const o: OpCode; const A, sBx: Integer): Integer;
begin
  luaK_codeABx(fs, o, A, sBx + MAXARG_sBx);
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

function luaK_codeABx(const fs: PFuncState; const o: OpCode; const A: Integer;
  const Bx: Cardinal): Integer;
begin

end;

function luaK_codeABC(const fs: PFuncState; const o: OpCode; const A, B, C: Integer): Integer;
begin

end;

function luaK_codek(const fs: PFuncState; const reg, k: Integer): Integer;
begin

end;

procedure luaK_fixline(const fs: PFuncState; const line: Integer);
begin

end;

procedure luaK_nil(const fs: PFuncState; const from, n: Integer);
begin

end;

procedure luaK_reserveregs(const fs: PFuncState; const n: Integer);
begin

end;

procedure luaK_checkstack(const fs: PFuncState; const n: Integer);
begin

end;

function luaK_stringK(const fs: PFuncState; const s: PTString): Integer;
begin

end;

function luaK_intK(const fs: PFuncState; const n: lua_Integer): Integer;
begin

end;

procedure luaK_dischargevars(const fs: PFuncState; const e: Pexpdesc);
begin

end;

function luaK_exp2anyreg(const fs: PFuncState; const e: Pexpdesc): Integer;
begin

end;

procedure luaK_exp2anyregup(const fs: PFuncState; const e: Pexpdesc);
begin

end;

procedure luaK_exp2nextreg(const fs: PFuncState; const e: Pexpdesc);
begin

end;

procedure luaK_exp2val(const fs: PFuncState; const e: Pexpdesc);
begin

end;

function luaK_exp2RK(const fs: PFuncState; const e: Pexpdesc): Integer;
begin

end;

procedure luaK_self(const fs: PFuncState; const e, key: Pexpdesc);
begin

end;

procedure luaK_indexed(const fs: PFuncState; const t, k: Pexpdesc);
begin

end;

procedure luaK_goiftrue(const fs: PFuncState; const e: Pexpdesc);
begin

end;

procedure luaK_goiffalse(const fs: PFuncState; const e: Pexpdesc);
begin

end;

procedure luaK_storevar(const fs: PFuncState; const var_, e: Pexpdesc);
begin

end;

procedure luaK_setreturns(const fs: PFuncState; const e: Pexpdesc; const nresults: Integer);
begin

end;

procedure luaK_setoneret(const fs: PFuncState; const e: Pexpdesc);
begin

end;

function luaK_jump(const fs: PFuncState): Integer;
begin

end;

procedure luaK_ret(const fs: PFuncState; const first, nret: Integer);
begin

end;

procedure luaK_patchlist(const fs: PFuncState; const list, target: Integer);
begin

end;

procedure luaK_patchtohere(const fs: PFuncState; const list: Integer);
begin

end;

procedure luaK_patchclose(const fs: PFuncState; const list, level: Integer);
begin

end;

procedure luaK_concat(const fs: PFuncState; const l1: PInteger; const l2: Integer);
begin

end;

function luaK_getlabel(const fs: PFuncState): Integer;
begin

end;

procedure luaK_prefix(const fs: PFuncState; const op: UnOpr; const v: Pexpdesc;
  const line: Integer);
begin

end;

procedure luaK_infix(const fs: PFuncState; const op: BinOpr; const v: Pexpdesc);
begin

end;

procedure luaK_posfix(const fs: PFuncState; const op: BinOpr; const v1, v2: Pexpdesc;
  const line: Integer);
begin

end;

procedure luaK_setlist(const fs: PFuncState; const base, nelems, tostore: Integer);
begin

end;

end.

