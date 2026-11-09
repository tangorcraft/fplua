unit lopcodes;
(*
** Opcodes for Lua virtual machine
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common;

(*===========================================================================
  We assume that instructions are unsigned numbers.
  All instructions have an opcode in the first 6 bits.
  Instructions can have the following fields:
	'A' : 8 bits
	'B' : 9 bits
	'C' : 9 bits
	'Ax' : 26 bits ('A', 'B', and 'C' together)
	'Bx' : 18 bits ('B' and 'C' together)
	'sBx' : signed Bx

  A signed argument is represented in excess K; that is, the number
  value is the unsigned value minus K. K is exactly the maximum value
  for that argument (so that -max is represented by 0, and +max is
  represented by 2*max), which is half the maximum for the corresponding
  unsigned argument.
===========================================================================*)

type
  OpMode = (iABC, iABx, iAsBx, iAx); (* basic instruction format *)

(*
** size and position of opcode arguments.
*)
const
  SIZE_C        = 9;
  SIZE_B        = 9;
  SIZE_Bx       = (SIZE_C + SIZE_B);
  SIZE_A        = 8;
  SIZE_Ax       = (SIZE_C + SIZE_B + SIZE_A);

  SIZE_OP       = 6;

  POS_OP        = 0;
  POS_A         = (POS_OP + SIZE_OP);
  POS_C         = (POS_A + SIZE_A);
  POS_B         = (POS_C + SIZE_C);
  POS_Bx        = POS_C;
  POS_Ax        = POS_A;


(*
** limits for opcode arguments.
** we use (signed) int to manipulate most arguments,
** so they must fit in LUAI_BITSINT-1 bits (-1 for sign)
*)
const
//{$if SIZE_Bx < (LUAI_BITSINT - 1)}
  MAXARG_Bx      = ((1 shl SIZE_Bx) - 1);
  MAXARG_sBx     = (MAXARG_Bx shr 1);   (* 'sBx' is signed *)
//{$else}
//  MAXARG_Bx      = MAX_INT;
//  MAXARG_sBx     = MAX_INT;
//{$endif}

//#if SIZE_Ax < LUAI_BITSINT-1
  MAXARG_Ax     = ((1 shl SIZE_Ax)-1);
//#else
//  MAXARG_Ax   = MAX_INT;
//#endif

  MAXARG_A      = ((1 shl SIZE_A)-1);
  MAXARG_B      = ((1 shl SIZE_B)-1);
  MAXARG_C      = ((1 shl SIZE_C)-1);


(*
** Macros to operate RK indices
*)

(* this bit 1 means constant (0 means register) *)
const
  BITRK         = (1 shl (SIZE_B - 1));

(* test whether value is a constant *)
//#define ISK(x)          ((x) & BITRK)
function ISK(const x: Cardinal): Boolean;

(* gets the index of the constant *)
//#define INDEXK(r)       ((int)(r) & ~BITRK)
function INDEXK(const r: Cardinal): Integer;

//#if !defined(MAXINDEXRK)  /* (for debugging only) */
const
  MAXINDEXRK = (BITRK - 1);
//#endif

(* code a constant index as a RK value *)
//#define RKASK(x)        ((x) | BITRK)
function RKASK(const x: Integer): Cardinal;

(*
** invalid register that fits in 8 bits
*)
const
  NO_REG        = MAXARG_A;


(*
** R(x) - register
** Kst(x) - constant (in constant table)
** RK(x) == if ISK(x) then Kst(INDEXK(x)) else R(x)
*)


(*
** grep "ORDER OP" if you change these enums
*)

type
  OpCode = (
(*----------------------------------------------------------------------
name             args    description
------------------------------------------------------------------------*)
OP_MOVE,//*      A B     R(A) := R(B)                                    */
OP_LOADK,//*     A Bx    R(A) := Kst(Bx)                                 */
OP_LOADKX,//*    A       R(A) := Kst(extra arg)                          */
OP_LOADBOOL,//*  A B C   R(A) := (Bool)B; if (C) pc++                    */
OP_LOADNIL,//*   A B     R(A), R(A+1), ..., R(A+B) := nil                */
OP_GETUPVAL,//*  A B     R(A) := UpValue[B]                              */

OP_GETTABUP,//*  A B C   R(A) := UpValue[B][RK(C)]                       */
OP_GETTABLE,//*  A B C   R(A) := R(B)[RK(C)]                             */

OP_SETTABUP,//*  A B C   UpValue[A][RK(B)] := RK(C)                      */
OP_SETUPVAL,//*  A B     UpValue[B] := R(A)                              */
OP_SETTABLE,//*  A B C   R(A)[RK(B)] := RK(C)                            */

OP_NEWTABLE,//*  A B C   R(A) := {} (size = B,C)                         */

OP_SELF,//*      A B C   R(A+1) := R(B); R(A) := R(B)[RK(C)]             */

OP_ADD,//*       A B C   R(A) := RK(B) + RK(C)                           */
OP_SUB,//*       A B C   R(A) := RK(B) - RK(C)                           */
OP_MUL,//*       A B C   R(A) := RK(B) * RK(C)                           */
OP_MOD,//*       A B C   R(A) := RK(B) % RK(C)                           */
OP_POW,//*       A B C   R(A) := RK(B) ^ RK(C)                           */
OP_DIV,//*       A B C   R(A) := RK(B) / RK(C)                           */
OP_IDIV,//*      A B C   R(A) := RK(B) // RK(C)                          */
OP_BAND,//*      A B C   R(A) := RK(B) & RK(C)                           */
OP_BOR,//*       A B C   R(A) := RK(B) | RK(C)                           */
OP_BXOR,//*      A B C   R(A) := RK(B) ~ RK(C)                           */
OP_SHL,//*       A B C   R(A) := RK(B) << RK(C)                          */
OP_SHR,//*       A B C   R(A) := RK(B) >> RK(C)                          */
OP_UNM,//*       A B     R(A) := -R(B)                                   */
OP_BNOT,//*      A B     R(A) := ~R(B)                                   */
OP_NOT,//*       A B     R(A) := not R(B)                                */
OP_LEN,//*       A B     R(A) := length of R(B)                          */

OP_CONCAT,//*    A B C   R(A) := R(B).. ... ..R(C)                       */

OP_JMP,//*       A sBx   pc+=sBx; if (A) close all upvalues >= R(A - 1)  */
OP_EQ,//*        A B C   if ((RK(B) == RK(C)) ~= A) then pc++            */
OP_LT,//*        A B C   if ((RK(B) <  RK(C)) ~= A) then pc++            */
OP_LE,//*        A B C   if ((RK(B) <= RK(C)) ~= A) then pc++            */

OP_TEST,//*      A C     if not (R(A) <=> C) then pc++                   */
OP_TESTSET,//*   A B C   if (R(B) <=> C) then R(A) := R(B) else pc++     */

OP_CALL,//*      A B C   R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1)) */
OP_TAILCALL,//*  A B C   return R(A)(R(A+1), ... ,R(A+B-1))              */
OP_RETURN,//*    A B     return R(A), ... ,R(A+B-2)      (see note)      */

OP_FORLOOP,//*   A sBx   R(A)+=R(A+2);
           //           if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) }*/
OP_FORPREP,//*   A sBx   R(A)-=R(A+2); pc+=sBx                           */

OP_TFORCALL,//*  A C     R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));  */
OP_TFORLOOP,//*  A sBx   if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }*/

OP_SETLIST,//*   A B C   R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B        */

OP_CLOSURE,//*   A Bx    R(A) := closure(KPROTO[Bx])                     */

OP_VARARG,//*    A B     R(A), R(A+1), ..., R(A+B-2) = vararg            */

OP_EXTRAARG//*   Ax      extra (larger) argument for previous opcode     */
);

const
  NUM_OPCODES = ord(OP_EXTRAARG) + 1;

(* creates a mask with 'n' 1 bits at position 'p' *)
//#define MASK1(n,p)      ((~((~(Instruction)0)<<(n)))<<(p))
function MASK1(const n, p: Integer): Instruction;

(* creates a mask with 'n' 0 bits at position 'p' *)
//#define MASK0(n,p)      (~MASK1(n,p))
function MASK0(const n, p: Integer): Instruction;

(*
** the following macros help to manipulate instructions
*)
function GET_OPCODE(const i: Instruction): OpCode;
procedure SET_OPCODE(var i: Instruction; const o: OpCode);

function getarg(const i: Instruction; const pos, size: Integer): Cardinal;
procedure setarg(var i: Instruction; const v: Cardinal; const pos, size: Integer);

function GETARG_A(const i: Instruction): Cardinal;
procedure SETARG_A(var i: Instruction; const v: Cardinal);

function GETARG_B(const i: Instruction): Cardinal;
procedure SETARG_B(var i: Instruction; const v: Cardinal);

function GETARG_C(const i: Instruction): Cardinal;
procedure SETARG_C(var i: Instruction; const v: Cardinal);

function GETARG_Bx(const i: Instruction): Cardinal;
procedure SETARG_Bx(var i: Instruction; const v: Cardinal);

function GETARG_Ax(const i: Instruction): Cardinal;
procedure SETARG_Ax(var i: Instruction; const v: Cardinal);

function GETARG_sBx(const i: Instruction): Integer;
procedure SETARG_sBx(var i: Instruction; const b: Integer);

function CREATE_ABC(const o: OpCode; const a, b, c: Cardinal): Instruction;
function CREATE_ABx(const o: OpCode; const a, bc: Cardinal): Instruction;
function CREATE_Ax(const o: OpCode; const a: Cardinal): Instruction;


{*===========================================================================
  Notes:
  (*) In OP_CALL, if (B == 0) then B = top. If (C == 0), then 'top' is
  set to last_result+1, so next open instruction (OP_CALL, OP_RETURN,
  OP_SETLIST) may use 'top'.

  (* ) In OP_VARARG, if (B == 0) then use actual number of varargs and
  set top (like in OP_CALL with C == 0).

  (* ) In OP_RETURN, if (B == 0) then return up to 'top'.

  (*) In OP_SETLIST, if (B == 0) then B = 'top'; if (C == 0) then next
  'instruction' is EXTRAARG(real C).

  (*) In OP_LOADKX, the next 'instruction' is always EXTRAARG.

  (*) For comparisons, A specifies what condition the test should accept
  (true or false).

  (*) All 'skips' (pc++) assume that next instruction is a jump.

===========================================================================*}


(*
** masks for instruction properties. The format is:
** bits 0-1: op mode
** bits 2-3: C arg mode
** bits 4-5: B arg mode
** bit 6: instruction set register A
** bit 7: operator is a test (next instruction must be a jump)
*)

type
  OpArgMask  = (
  OpArgN,  //* argument is not used */
  OpArgU,  //* argument is used */
  OpArgR,  //* argument is a register or a jump offset */
  OpArgK   //* argument is a constant or register/constant */
);

function getOpMode(const o: OpCode): OpMode;
function getBMode(const o: OpCode): OpArgMask;
function getCMode(const o: OpCode): OpArgMask;
function testAMode(const o: OpCode): Boolean;
function testTMode(const o: OpCode): Boolean;


(* opcode names *)
const
  luaP_opnames : array[0..NUM_OPCODES] of PChar = (
  'MOVE',
  'LOADK',
  'LOADKX',
  'LOADBOOL',
  'LOADNIL',
  'GETUPVAL',
  'GETTABUP',
  'GETTABLE',
  'SETTABUP',
  'SETUPVAL',
  'SETTABLE',
  'NEWTABLE',
  'SELF',
  'ADD',
  'SUB',
  'MUL',
  'MOD',
  'POW',
  'DIV',
  'IDIV',
  'BAND',
  'BOR',
  'BXOR',
  'SHL',
  'SHR',
  'UNM',
  'BNOT',
  'NOT',
  'LEN',
  'CONCAT',
  'JMP',
  'EQ',
  'LT',
  'LE',
  'TEST',
  'TESTSET',
  'CALL',
  'TAILCALL',
  'RETURN',
  'FORLOOP',
  'FORPREP',
  'TFORCALL',
  'TFORLOOP',
  'SETLIST',
  'CLOSURE',
  'VARARG',
  'EXTRAARG',
  nil
  );

(* number of list items to accumulate before a SETLIST instruction *)
const
  LFIELDS_PER_FLUSH     = 50;


implementation

function ISK(const x: Cardinal): Boolean;
begin
  Result := (x and BITRK) <> 0;
end;

function INDEXK(const r: Cardinal): Integer;
begin
  Result := Integer(r) and not BITRK;
end;

function RKASK(const x: Integer): Cardinal;
begin
  Result := x or BITRK;
end;

function MASK1(const n, p: Integer): Instruction;
begin
  Result :=
    (
      not( (not Instruction(0)) shl (n) )
    )
    shl
    (
      p
    )
  ;
end;

function MASK0(const n, p: Integer): Instruction;
begin
  Result := not // MASK1(n,p)
    (
      not( (not Instruction(0)) shl (n) )
    )
    shl
    (
      p
    )
  ;
end;

//#define GET_OPCODE(i)   (cast(OpCode, ((i)>>POS_OP) & MASK1(SIZE_OP,0)))
//#define SET_OPCODE(i,o) ((i) = (((i)&MASK0(SIZE_OP,POS_OP)) | \
//                ((cast(Instruction, o)<<POS_OP)&MASK1(SIZE_OP,POS_OP))))
function GET_OPCODE(const i: Instruction): OpCode;
begin
  Result := OpCode((i shr POS_OP) and MASK1(SIZE_OP, 0));
end;

procedure SET_OPCODE(var i: Instruction; const o: OpCode);
begin
  i := (i and MASK0(SIZE_OP, POS_OP)) or (Instruction(ord(o) shl POS_OP) and MASK1(SIZE_OP, POS_OP));
end;

//#define getarg(i,pos,size)      (cast(int, ((i)>>pos) & MASK1(size,0)))
//#define setarg(i,v,pos,size)    ((i) = (((i)&MASK0(size,pos)) | \
//                ((cast(Instruction, v)<<pos)&MASK1(size,pos))))
function getarg(const i: Instruction; const pos, size: Integer): Cardinal;
begin
  Result := Cardinal((i shr pos) and MASK1(size, 0));
end;

procedure setarg(var i: Instruction; const v: Cardinal; const pos, size: Integer);
begin
  i := (i and MASK0(size, pos)) or (Instruction(v shl pos) and MASK1(size, pos));
end;

//#define GETARG_A(i)     getarg(i, POS_A, SIZE_A)
//#define SETARG_A(i,v)   setarg(i, v, POS_A, SIZE_A)
function GETARG_A(const i: Instruction): Cardinal;
begin
  Result := getarg(i, POS_A, SIZE_A);
end;

procedure SETARG_A(var i: Instruction; const v: Cardinal);
begin
  setarg(i, v, POS_A, SIZE_A);
end;

//#define GETARG_B(i)     getarg(i, POS_B, SIZE_B)
//#define SETARG_B(i,v)   setarg(i, v, POS_B, SIZE_B)
function GETARG_B(const i: Instruction): Cardinal;
begin
  Result := getarg(i, POS_B, SIZE_B);
end;

procedure SETARG_B(var i: Instruction; const v: Cardinal);
begin
  setarg(i, v, POS_B, SIZE_B);
end;

//#define GETARG_C(i)     getarg(i, POS_C, SIZE_C)
//#define SETARG_C(i,v)   setarg(i, v, POS_C, SIZE_C)
function GETARG_C(const i: Instruction): Cardinal;
begin
  Result := getarg(i, POS_C, SIZE_C);
end;

procedure SETARG_C(var i: Instruction; const v: Cardinal);
begin
  setarg(i, v, POS_C, SIZE_C);
end;

//#define GETARG_Bx(i)    getarg(i, POS_Bx, SIZE_Bx)
//#define SETARG_Bx(i,v)  setarg(i, v, POS_Bx, SIZE_Bx)
function GETARG_Bx(const i: Instruction): Cardinal;
begin
  Result := getarg(i, POS_Bx, SIZE_Bx);
end;

procedure SETARG_Bx(var i: Instruction; const v: Cardinal);
begin
  setarg(i, v, POS_Bx, SIZE_Bx);
end;

//#define GETARG_Ax(i)    getarg(i, POS_Ax, SIZE_Ax)
//#define SETARG_Ax(i,v)  setarg(i, v, POS_Ax, SIZE_Ax)
function GETARG_Ax(const i: Instruction): Cardinal;
begin
  Result := getarg(i, POS_Ax, SIZE_Ax);
end;

procedure SETARG_Ax(var i: Instruction; const v: Cardinal);
begin
  setarg(i, v, POS_Ax, SIZE_Ax);
end;

//#define GETARG_sBx(i)   (GETARG_Bx(i)-MAXARG_sBx)
//#define SETARG_sBx(i,b) SETARG_Bx((i),cast(unsigned int, (b)+MAXARG_sBx))
function GETARG_sBx(const i: Instruction): Integer;
begin
  Result := GETARG_Bx(i) - MAXARG_sBx;
end;

procedure SETARG_sBx(var i: Instruction; const b: Integer);
begin
  SETARG_Bx(i, Cardinal(b + MAXARG_sBx));
end;

{
#define CREATE_ABC(o,a,b,c)     ((cast(Instruction, o)<<POS_OP) \
                        | (cast(Instruction, a)<<POS_A) \
                        | (cast(Instruction, b)<<POS_B) \
                        | (cast(Instruction, c)<<POS_C))

#define CREATE_ABx(o,a,bc)      ((cast(Instruction, o)<<POS_OP) \
                        | (cast(Instruction, a)<<POS_A) \
                        | (cast(Instruction, bc)<<POS_Bx))

#define CREATE_Ax(o,a)          ((cast(Instruction, o)<<POS_OP) \
                        | (cast(Instruction, a)<<POS_Ax))
}
function CREATE_ABC(const o: OpCode; const a, b, c: Cardinal): Instruction;
begin
  Result := (ord(o) shl POS_OP)
         or (a shl POS_A)
         or (b shl POS_B)
         or (c shl POS_C);
end;

function CREATE_ABx(const o: OpCode; const a, bc: Cardinal): Instruction;
begin
  Result := (ord(o) shl POS_OP)
         or (a shl POS_A)
         or (bc shl POS_Bx);
end;

function CREATE_Ax(const o: OpCode; const a: Cardinal): Instruction;
begin
  Result := (ord(o) shl POS_OP)
         or (a shl POS_Ax);
end;

var
  luaP_opmodes_: array[OpCode] of lu_byte;

//#define getOpMode(m)    (cast(enum OpMode, luaP_opmodes[m] & 3))
function getOpMode(const o: OpCode): OpMode;
begin
  Result := OpMode(luaP_opmodes_[o] and 3);
end;

//#define getBMode(m)     (cast(enum OpArgMask, (luaP_opmodes[m] >> 4) & 3))
function getBMode(const o: OpCode): OpArgMask;
begin
  Result := OpArgMask((luaP_opmodes_[o] shr 4) and 3);
end;

//#define getCMode(m)     (cast(enum OpArgMask, (luaP_opmodes[m] >> 2) & 3))
function getCMode(const o: OpCode): OpArgMask;
begin
  Result := OpArgMask((luaP_opmodes_[o] shr 2) and 3);
end;

//#define testAMode(m)    (luaP_opmodes[m] & (1 << 6))
function testAMode(const o: OpCode): Boolean;
begin
  Result := (luaP_opmodes_[o] and (1 shl 6)) <> 0;
end;

//#define testTMode(m)    (luaP_opmodes[m] & (1 << 7))
function testTMode(const o: OpCode): Boolean;
begin
  Result := (luaP_opmodes_[o] and (1 shl 7)) <> 0;
end;

procedure InitOpModes;
var
  idx: OpCode;

  //#define opmode(t,a,b,c,m) (((t)<<7) | ((a)<<6) | ((b)<<4) | ((c)<<2) | (m))
  procedure opmode_(const t,a: lu_byte; const b,c: OpArgMask; const m: OpMode);
  begin
    luaP_opmodes_[idx] := ((t shl 7) or (a shl 6) or (ord(b) shl 4) or (ord(c) shl 2) or ord(m));
    inc(idx);
  end;

begin
  idx := low(OpCode);
//*       T  A    B       C     mode                opcode       */
  opmode_(0, 1, OpArgR, OpArgN, iABC)  ;        //* OP_MOVE */
  opmode_(0, 1, OpArgK, OpArgN, iABx)  ;        //* OP_LOADK */
  opmode_(0, 1, OpArgN, OpArgN, iABx)  ;        //* OP_LOADKX */
  opmode_(0, 1, OpArgU, OpArgU, iABC)  ;        //* OP_LOADBOOL */
  opmode_(0, 1, OpArgU, OpArgN, iABC)  ;        //* OP_LOADNIL */
  opmode_(0, 1, OpArgU, OpArgN, iABC)  ;        //* OP_GETUPVAL */
  opmode_(0, 1, OpArgU, OpArgK, iABC)  ;        //* OP_GETTABUP */
  opmode_(0, 1, OpArgR, OpArgK, iABC)  ;        //* OP_GETTABLE */
  opmode_(0, 0, OpArgK, OpArgK, iABC)  ;        //* OP_SETTABUP */
  opmode_(0, 0, OpArgU, OpArgN, iABC)  ;        //* OP_SETUPVAL */
  opmode_(0, 0, OpArgK, OpArgK, iABC)  ;        //* OP_SETTABLE */
  opmode_(0, 1, OpArgU, OpArgU, iABC)  ;        //* OP_NEWTABLE */
  opmode_(0, 1, OpArgR, OpArgK, iABC)  ;        //* OP_SELF */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_ADD */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_SUB */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_MUL */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_MOD */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_POW */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_DIV */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_IDIV */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_BAND */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_BOR */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_BXOR */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_SHL */
  opmode_(0, 1, OpArgK, OpArgK, iABC)  ;        //* OP_SHR */
  opmode_(0, 1, OpArgR, OpArgN, iABC)  ;        //* OP_UNM */
  opmode_(0, 1, OpArgR, OpArgN, iABC)  ;        //* OP_BNOT */
  opmode_(0, 1, OpArgR, OpArgN, iABC)  ;        //* OP_NOT */
  opmode_(0, 1, OpArgR, OpArgN, iABC)  ;        //* OP_LEN */
  opmode_(0, 1, OpArgR, OpArgR, iABC)  ;        //* OP_CONCAT */
  opmode_(0, 0, OpArgR, OpArgN, iAsBx) ;        //* OP_JMP */
  opmode_(1, 0, OpArgK, OpArgK, iABC)  ;        //* OP_EQ */
  opmode_(1, 0, OpArgK, OpArgK, iABC)  ;        //* OP_LT */
  opmode_(1, 0, OpArgK, OpArgK, iABC)  ;        //* OP_LE */
  opmode_(1, 0, OpArgN, OpArgU, iABC)  ;        //* OP_TEST */
  opmode_(1, 1, OpArgR, OpArgU, iABC)  ;        //* OP_TESTSET */
  opmode_(0, 1, OpArgU, OpArgU, iABC)  ;        //* OP_CALL */
  opmode_(0, 1, OpArgU, OpArgU, iABC)  ;        //* OP_TAILCALL */
  opmode_(0, 0, OpArgU, OpArgN, iABC)  ;        //* OP_RETURN */
  opmode_(0, 1, OpArgR, OpArgN, iAsBx) ;        //* OP_FORLOOP */
  opmode_(0, 1, OpArgR, OpArgN, iAsBx) ;        //* OP_FORPREP */
  opmode_(0, 0, OpArgN, OpArgU, iABC)  ;        //* OP_TFORCALL */
  opmode_(0, 1, OpArgR, OpArgN, iAsBx) ;        //* OP_TFORLOOP */
  opmode_(0, 0, OpArgU, OpArgU, iABC)  ;        //* OP_SETLIST */
  opmode_(0, 1, OpArgU, OpArgN, iABx)  ;        //* OP_CLOSURE */
  opmode_(0, 1, OpArgU, OpArgN, iABC)  ;        //* OP_VARARG */
  opmode_(0, 0, OpArgU, OpArgU, iAx)   ;        //* OP_EXTRAARG */
end;

initialization
  InitOpModes;
end.

