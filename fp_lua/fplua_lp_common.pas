unit fplua_lp_common;
(*
** Lexical Analyzer and Lua Parser types and constants
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types, lzio;

type
  lu_short = Smallint; // 2 byte int

const
  FIRST_RESERVED = 257;


//#if !defined(LUA_ENV)
const
  LUA_ENV       = '_ENV';
//#endif


(*
* WARNING: if you change the order of this enumeration,
* grep "ORDER RESERVED"
*)
type
  RESERVED = (
    //* terminal symbols denoted by reserved words */
    TK_AND = FIRST_RESERVED, TK_BREAK,
    TK_DO, TK_ELSE, TK_ELSEIF, TK_END, TK_FALSE, TK_FOR, TK_FUNCTION,
    TK_GOTO, TK_IF, TK_IN, TK_LOCAL, TK_NIL, TK_NOT, TK_OR, TK_REPEAT,
    TK_RETURN, TK_THEN, TK_TRUE, TK_UNTIL, TK_WHILE,
    //* other terminal symbols */
    TK_IDIV, TK_CONCAT, TK_DOTS, TK_EQ, TK_GE, TK_LE, TK_NE,
    TK_SHL, TK_SHR,
    TK_DBCOLON, TK_EOS,
    TK_FLT, TK_INT, TK_NAME, TK_STRING
  );

//* number of reserved words */
const
  NUM_RESERVED   = ord(TK_WHILE) - FIRST_RESERVED + 1;

type
  SemInfo = record case byte of
    1:(r: lua_Number);
    2:(i: lua_Integer);
    3:(ts: PTString);
  end;  //* semantics information */

  Token = record
    token: Integer;
    seminfo: SemInfo;
  end;
  PToken = ^Token;

(*
** Expression and variable descriptor.
** Code generation for variables and expressions can be delayed to allow
** optimizations; An 'expdesc' structure describes a potentially-delayed
** variable/expression. It has a description of its "main" value plus a
** list of conditional jumps that can also produce its value (generated
** by short-circuit operators 'and'/'or').
*)

(* kinds of variables/expressions *)
type
  expkind = (
    VVOID,  (* when 'expdesc' describes the last expression a list,
               this kind means an empty list (so, no expression) *)
    VNIL,  //* constant nil */
    VTRUE,  //* constant true */
    VFALSE,  //* constant false */
    VK,  //* constant in 'k'; info = index of constant in 'k' */
    VKFLT,  //* floating constant; nval = numerical float value */
    VKINT,  //* integer constant; nval = numerical integer value */
    VNONRELOC,  (* expression has its value in a fixed register;
                   info = result register *)
    VLOCAL,  //* local variable; info = local register */
    VUPVAL,  //* upvalue variable; info = index of upvalue in 'upvalues' */
    VINDEXED,  (* indexed variable;
                  ind.vt = whether 't' is register or upvalue;
                  ind.t = table register or upvalue;
                  ind.idx = key's R/K index *)
    VJMP,  (* expression is a test/comparison;
              info = pc of corresponding jump instruction *)
    VRELOCABLE,  (* expression can put result in any register;
                    info = instruction pc *)
    VCALL,  //* expression is a function call; info = instruction pc */
    VVARARG  //* vararg expression; info = instruction pc */
  );


function vkisvar(const k: expkind): Boolean;
function vkisinreg(const k: expkind): Boolean;

type
  expdesc_u_ind = record
    idx: lu_short;  //* index (R/K) */
    t: lu_byte;  //* table (register or upvalue) */
    vt: lu_byte;  //* whether 't' is register (VLOCAL) or upvalue (VUPVAL) */
  end;

  expdesc_u = record case Byte of
    1:(ival: lua_Integer); //* for VKINT */
    2:(nval: lua_Number);  //* for VKFLT */
    3:(info: Integer);     //* for generic use */
    4:(ind: expdesc_u_ind); //* for indexed variables (VINDEXED) */
  end;

  expdesc = record
    k: expkind;
    u: expdesc_u;
    t: Integer;  //* patch list of 'exit when true' */
    f: Integer;  //* patch list of 'exit when false' */
  end;
  Pexpdesc = ^expdesc;


(* description of active local variable *)
type
  Vardesc = record
    idx: lu_short;  //* variable index in stack */
  end;
  PVardesc = ^Vardesc;

(* description of pending goto statements and label statements *)
type
  Labeldesc = record
    name: PTString;  //* label identifier */
    pc: Integer;  //* position in code */
    line: Integer;  //* line where it appeared */
    nactvar: lu_byte;  //* local level where it appears in current block */
  end;
  PLabeldesc = ^Labeldesc;

(* list of labels or gotos *)
type
  Labellist = record
    arr: PLabeldesc;  //* array */
    n: Integer;  //* number of entries in use */
    size: Integer;  //* array size */
  end;


(* dynamic structures used by the parser *)
type
  Dyndata_actvar = record //* list of active local variables */
    arr: PVardesc;
    n: Integer;
    size: Integer;
  end;

  Dyndata = record
    actvar: Dyndata_actvar; //* list of active local variables */
    gt: Labellist;  //* list of pending gotos */
    label_: Labellist;   //* list of active labels */
  end;
  PDyndata = ^Dyndata;


(* control of blocks *)
//struct BlockCnt;  //* defined in lparser.c */
type
  PBlockCnt = type Pointer;


{ Types needing forward declarations must be defined inside the same type block }
type
  PLexState = ^LexState;
  PFuncState = ^FuncState;

  (* state of the lexer plus state of the parser when shared by all
     functions *)
  LexState = record
    current: Integer;  //* current character (charint) */
    linenumber: Integer;  //* input line counter */
    lastline: Integer;  //* line of last token 'consumed' */
    t: Token;  //* current token */
    lookahead: Token;  //* look ahead token */
    fs: PFuncState;  //* current function (parser) */
    L: Plua_State;
    z: PZIO;  //* input stream */
    buff: PMbuffer;  //* buffer for tokens */
    h: PTable;  //* to avoid collection/reuse strings */
    dyd: PDyndata;  //* dynamic structures used by the parser */
    source: PTString;  //* current source name */
    envn: PTString;  //* environment variable name */
  end;

  (* state needed to generate code for a given function *)
  FuncState = record
    f: PProto;  //* current function header */
    prev: PFuncState;  //* enclosing function */
    ls: PLexState;  //* lexical state */
    bl: PBlockCnt;  //* chain of current blocks */
    pc: Integer;  //* next position to code (equivalent to 'ncode') */
    lasttarget: Integer;   //* 'label' of last 'jump label' */
    jpc: Integer;  //* list of pending jumps to 'pc' */
    nk: Integer;  //* number of elements in 'k' */
    np: Integer;  //* number of elements in 'p' */
    firstlocal: Integer;  //* index of first local var (in Dyndata array) */
    nlocvars: lu_short;  //* number of elements in 'f->locvars' */
    nactvar: lu_byte;  //* number of active local variables */
    nups: lu_byte;  //* number of upvalues */
    freereg: lu_byte;  //* first free register */
  end;

implementation

//#define vkisvar(k)    (VLOCAL <= (k) && (k) <= VINDEXED)
function vkisvar(const k: expkind): Boolean;
begin
  Result := (VLOCAL <= k) and (k <= VINDEXED);
end;

//#define vkisinreg(k)  ((k) == VNONRELOC || (k) == VLOCAL)
function vkisinreg(const k: expkind): Boolean;
begin
  Result := (k = VNONRELOC) or (k = VLOCAL);
end;

end.

