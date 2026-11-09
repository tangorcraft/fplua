unit fplua_types;
(*
** Complex types, that may need cross-referencing
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common;

{ Types needing forward declarations must be defined inside the same type block }
type
  { All pointer forward declarations }
  PGCObject = ^GCObject;
  PPGCObject = ^PGCObject;

  PUpVal = ^UpVal;

  PTValue = ^TValue;
  Plua_TValue = ^lua_TValue;

  PTKey = ^TKey;
  PNode = ^Node;
  PTable = ^Table;

  PTString = ^TString;
  PPTstring = ^PTString;
  PUdata = ^Udata;
  PUpvaldesc = ^Upvaldesc;
  PLocVar = ^LocVar;

  PProto = ^Proto;
  PPProto = ^PProto;

  PCClosure = ^CClosure;
  PLClosure = ^LClosure;
  PClosure = ^Closure;

  Pglobal_State = ^global_State;
  Plua_State = ^lua_State;

  Plua_longjmp = ^lua_longjmp;

  Plua_Debug = ^lua_Debug; //* activation record */

  (*
  ** Type for C functions registered with Lua
  *)
  // TODO cdecl?
  //typedef int (*lua_CFunction) (lua_State *L);
  lua_CFunction = function (L: Plua_State): Integer;

  (*
  ** Type for continuation functions
  *)
  //typedef int (*lua_KFunction) (lua_State *L, int status, lua_KContext ctx);
  lua_KFunction = function (L: Plua_State; status: Integer; ctx: lua_KContext): Integer;

  (*
  ** Type for functions that read/write blocks when loading/dumping Lua chunks
  *)
  //typedef const char * (*lua_Reader) (lua_State *L, void *ud, size_t *sz);
  lua_Reader = function (L: Plua_State; ud: Pointer; sz: PPtrUInt): PChar;

  //typedef int (*lua_Writer) (lua_State *L, const void *p, size_t sz, void *ud);
  lua_Writer = function (L: Plua_State; p: Pointer; sz: PPtrUInt; ud: Pointer): Integer;

  (* Functions to be called by the debugger in specific events *)
  //typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);
  lua_Hook = procedure (L: Plua_State; ar: Plua_Debug);

  (*
  ** Common Header for all collectable objects (in macro form, to be
  ** included in other objects)
  *)
  CommonHeader = record
    next: PGCObject;
    tt: lu_byte;
    marked: lu_byte;
  end;

  (*
  ** Common type for all collectable objects
  ** Common type has only the common header
  *)
  GCObject = record
    header: CommonHeader;
  end;

  Value = record case Byte of
    1:(gc: PGCObject);    //* collectable objects */
    2:(p: Pointer);       //* light userdata */
    3:(b: lu_int);        //* booleans */ ?? TODO maybe LongBool, or Boolean32
    4:(f: lua_CFunction); //* light C functions */
    5:(i: lua_Integer);   //* integer numbers */
    6:(n: lua_Number);    //* float numbers */
  end;

//#define TValuefields    Value value_; int tt_
  TValuefields = record
    value_: Value;
    tt_: Integer;
  end;

  TValue = record
    fields: TValuefields;
  end;
  lua_TValue = TValue;

  //typedef TValue *StkId;  (* index to stack elements *)
  StkId = type PTValue;

  (*
  ** Upvalues for Lua closures
  *)
  UpVal = record
    v: PTValue; //* points to stack or to its own value */
    refcount: lu_mem; //* reference counter */
    case Byte of
    1:( //* (when open) */
      next: PUpVal; //* linked list */
      touched: Integer; //* mark to avoid cycles with dead threads */
    );
    2:(value: TValue) //* the value (when closed) */
  end;

  TKey_nk = record
    fields: TValuefields;
    next: Integer; //* for chaining (offset for next node) */
  end;

  TKey = record
    nk: TKey_nk;
    tvk: TValue;
  end;

  Node = record
    i_val: TValue;
    i_key: TKey;
  end;

  Table = record
    header: CommonHeader;
    flags: lu_byte;  //* 1<<p means tagmethod(p) is not present */
    lsizenode: lu_byte;  //* log2 of size of 'node' array */
    sizearray: Cardinal;  //* size of 'array' array */
    array_: PTValue;  //* array part */
    node_: PNode;
    lastfree: PNode;  //* any free position is before this position */
    metatable: PTable;
    gclist: PGCObject;
  end;

  (*
  ** Header for string value; string bytes follow the end of this structure
  ** (aligned according to 'UTString'; see next).
  *)
  TString = record
    header: CommonHeader;
    extra: lu_byte;  //* reserved words for short strings; "has hash" for longs */
    shrlen: lu_byte;  //* length for short strings */
    hash: Cardinal;
    case Byte of
      1:(u_lnglen: SizeUInt);  //* length for long strings */
      2:(u_hnext: PTString);  //* linked list for hash table */
  end;
  (*
  ** Ensures that address after this type is always fully aligned.
  *)
  UTString = record case Byte of
    1:(dummy: L_Umaxalign);  //* ensures maximum alignment for strings */
    2:(tsv: TString);
  end;

  (*
  ** Header for userdata; memory area follows the end of this structure
  ** (aligned according to 'UUdata'; see next).
  *)
  Udata = record
    header: CommonHeader;
    ttuv_: lu_byte;  //* user value's tag */
    metatable: PTable;
    len: size_t;  //* number of bytes */
    user_: Value;  //* user value */
  end;

  (*
  ** Ensures that address after this type is always fully aligned.
  *)
  UUdata = record case Byte of
    1:(dummy: L_Umaxalign);  ///* ensures maximum alignment for 'local' udata */
    2:(uv: Udata);
  end;

  (*
  ** Description of an upvalue for function prototypes
  *)
  Upvaldesc = record
    name: PTString;  //* upvalue name (for debug information) */
    instack: lu_byte;  //* whether it is in stack (register) */
    idx: lu_byte;  //* index of upvalue (in stack or in outer function's list) */
  end;

  (*
  ** Description of a local variable for function prototypes
  ** (used for debug information)
  *)
  LocVar = record
    varname: PTString;
    startpc: Integer;  //* first point where variable is active */
    endpc: Integer;    //* first point where variable is dead */
  end;

  (*
  ** Function Prototypes
  *)
  Proto = record
    header: CommonHeader;
    numparams: lu_byte;  //* number of fixed parameters */
    is_vararg: lu_byte;
    maxstacksize: lu_byte;  //* number of registers needed by this function */
    sizeupvalues: Integer;  //* size of 'upvalues' */
    sizek: Integer;  //* size of 'k' */
    sizecode: Integer;
    sizelineinfo: Integer;
    sizep: Integer;  //* size of 'p' */
    sizelocvars: Integer;
    linedefined: Integer;  //* debug information  */
    lastlinedefined: Integer;  //* debug information  */
    k: PTValue;  //* constants used by the function */
    code: PInstruction;  //* opcodes */
    p: PPProto;  //* functions defined inside the function */
    lineinfo: PInteger;  //* map from opcodes to source lines (debug information) */
    locvars: PLocVar;  //* information about local variables (debug information) */
    upvalues: PUpvaldesc;  //* upvalue information */
    cache: PLClosure;  //* last-created closure with this prototype */
    source: PTString;  //* used for debug information */
    gclist: PGCObject;
  end;

  //#define ClosureHeader \
  //        CommonHeader; lu_byte nupvalues; GCObject *gclist
  ClosureHeader = record
    header: CommonHeader;
    nupvalues: lu_byte;
    gclist: PGCObject;
  end;

  CClosure = record
    header: ClosureHeader;
    f: lua_CFunction;
    //upvalue[1] TValue;  //* list of upvalues */ TODO x2
  end;

  LClosure = record
    header: ClosureHeader;
    p: PProto;
    //*upvals[1] UpVal;  //* list of upvalues */
  end;

  Closure = record case Byte of
    1:(c: CClosure);
    2:(l: LClosure);
  end;

  stringtable = record
    hash: PPTString;
    nuse: Integer; //* number of elements */
    size: Integer;
  end;
  Pstringtable = ^stringtable;

  (*
  ** Information about a call.
  ** When a thread yields, 'func' is adjusted to pretend that the
  ** top function has only the yielded values in its stack; in that
  ** case, the actual 'func' value is saved in field 'extra'.
  ** When a function calls another with a continuation, 'extra' keeps
  ** the function index so that, in case of errors, the continuation
  ** function can be called with the correct top.
  *)
  CallInfo_union = record case Byte of
  1:( //* only for Lua functions */
    base: StkId; //* base for this function */
    savedpc: PInstruction;
  );
  2:( //* only for C functions */
    k: lua_KFunction; //* continuation in case of yields */
    old_errfunc: PtrInt;
    ctx: lua_KContext; //* context info. in case of yields */
  );
  end;

  PCallInfo = ^CallInfo;
  CallInfo = record
    func: StkId; //* function index in the stack */
    top: StkId;  //* top for this function */
    previous, next: PCallInfo; //* dynamic call link */
    u: CallInfo_union;
    extra: PtrInt;
    nresults: ShortInt; //* expected number of results from this function */
    callstatus: Word;
  end;

  (*
  ** 'global state', shared by all threads of this state
  *)
  global_State = record
    frealloc: lua_Alloc; //* function to reallocate memory */
    ud: Pointer; //* auxiliary data to 'frealloc' */
    totalbytes: l_mem; //* number of bytes currently allocated - GCdebt */
    GCdebt: l_mem;  //* bytes allocated not yet compensated by the collector */
    GCmemtrav: lu_mem;  //* memory traversed by the GC */
    GCestimate: lu_mem;  //* an estimate of the non-garbage memory in use */
    strt: stringtable;  //* hash table for strings */
    l_registry: TValue;
    seed: Cardinal;  //* randomized seed for hashes */
    currentwhite: lu_byte;
    gcstate: lu_byte;  //* state of garbage collector */
    gckind: lu_byte;  //* kind of GC running */
    gcrunning: lu_byte;  //* true if GC is running */
    allgc: PGCObject;  //* list of all collectable objects */
    sweepgc: PPGCObject;  //* current position of sweep in list */
    finobj: PGCObject;  //* list of collectable objects with finalizers */
    gray: PGCObject;  //* list of gray objects */
    grayagain: PGCObject;  //* list of objects to be traversed atomically */
    weak: PGCObject;  //* list of tables with weak values */
    ephemeron: PGCObject;  //* list of ephemeron tables (weak keys) */
    allweak: PGCObject;  //* list of all-weak tables */
    tobefnz: PGCObject;  //* list of userdata to be GC */
    fixedgc: PGCObject;  //* list of objects not to be collected */
    twups: Plua_State;  //* list of threads with open upvalues */
    gcfinnum: Cardinal;  //* number of finalizers to call in each GC step */
    gcpause: Integer;  //* size of pause between successive GCs */
    gcstepmul: Integer;  //* GC 'granularity' */
    panic: lua_CFunction;  //* to be called in unprotected errors */
    mainthread: Plua_State;
    version: Plua_Number;  //* pointer to version number */
    memerrmsg: PTString;  //* memory-error message */
    //tmname: array[0..TM_N-1] of PTString;  //* array with tag-method names */
    tmname: array[TMS] of PTString;  //* array with tag-method names */
    mt: array[0..LUA_NUMTAGS-1] of PTable;  //* metatables for basic types */
    strcache: array[0..STRCACHE_N-1, 0..STRCACHE_M-1] of PTString;  //* cache for strings in API */
  end;

  (*
  ** Atomic type (relative to signals) to better ensure that 'lua_sethook'
  ** is thread safe
  *)
  //#if !defined(l_signalT)
  //#include <signal.h>
  //#define l_signalT     sig_atomic_t
  //#endif
  l_signalT = Cardinal;

  (*
  ** 'per thread' state
  *)
  lua_State = record
    header: CommonHeader;
    nci: Word;  //* number of items in 'ci' list */
    status: lu_byte;
    top: StkId;  //* first free slot in the stack */
    l_G: Pglobal_State;
    ci: PCallInfo;  //* call info for current function */
    oldpc: PInstruction;  //* last pc traced */
    stack_last: StkId;  //* last free slot in the stack */
    stack: StkId;  //* stack base */
    openupval: PUpVal;  //* list of open upvalues in this stack */
    gclist: PGCObject;
    twups: Plua_State;  //* list of threads with open upvalues */
    errorJmp: Plua_longjmp;  //* current error recover point */
    base_ci: CallInfo;  //* CallInfo for first level (C calling Lua) */
    // TODO hook: volatile lua_Hook;
    errfunc: PtrInt;  //* current error handling function (stack index) */
    stacksize: Integer;
    basehookcount: Integer;
    hookcount: Integer;
    nny: Word;  //* number of non-yieldable calls in stack */
    nCcalls: Word;  //* number of nested C calls */
    hookmask: l_signalT;
    allowhook: lu_byte;
  end;

  // TODO
  //struct lua_longjmp;  /* defined in ldo.c */
  lua_longjmp = record
    TODO: Pointer;
  end;

  (* activation record *)
  lua_Debug = record
    event: Integer;
    name: pchar;               //* (n) */
    namewhat: pchar;           //* (n) 'global', 'local', 'field', 'method' */
    what: pchar;               //* (S) 'Lua', 'C', 'main', 'tail' */
    source: pchar;             //* (S) */
    currentline: Integer;      //* (l) */
    linedefined: Integer;      //* (S) */
    lastlinedefined: Integer;  //* (S) */
    nups: Byte;                //* (u) number of upvalues */
    nparams: Byte;             //* (u) number of parameters */
    isvararg: char;            //* (u) */ ? number? char?
    istailcall: char;          //* (t) */ ? bytebool? char?
    short_src: array[0..LUA_IDSIZE-1] of char; //* (S) */
    //* private part */
    i_ci: PCallInfo;  //* active function */
  end;

(*
** assertion for checking API calls
*)
//#if !defined(luai_apicheck)
//#define luai_apicheck(l,e)      lua_assert(e)
//#endif

//#define api_check(l,e,msg)      luai_apicheck(l,(e) && msg)
{$ifdef LUA_USE_APICHECK}
type
  fplua_apicheck_fn = procedure (const L: lua_State; const e: Boolean; const msg: PChar);
var
  fplua_apicheck: fplua_apicheck_fn;
{$endif}
procedure api_check(const L: lua_State; const e: Boolean; const msg: PChar); inline;

function check_exp(const c: Boolean; const e: lua_CFunction): lua_CFunction;

(*
** macro to control inclusion of some hard tests on stack reallocation
*)
//TODO these macros need unwrapping where they are used with pre/pos
//#if !defined(HARDSTACKTESTS)
//#define condmovestack(L,pre,pos)        ((void)0)
//#else
///* realloc stack keeping its size */
//#define condmovestack(L,pre,pos)  \
//        { int sz_ = (L)->stacksize; pre; luaD_reallocstack((L), sz_); pos; }
//#endif
{$ifdef HARDSTACKTESTS}
// a "common" version without pre/pos
procedure condmovestack(var L: lua_State);
{$endif}

//#if !defined(HARDMEMTESTS)
//#define condchangemem(L,pre,pos)        ((void)0)
//#else
//#define condchangemem(L,pre,pos)  \
//        { if (G(L)->gcrunning) { pre; luaC_fullgc(L, 0); pos; } }
//#endif
{$ifdef HARDMEMTESTS}
// a "common" version without pre/pos
procedure condchangemem(var L: lua_State);
{$endif}


implementation

uses
  lgc, ldo;

procedure api_check(const L: lua_State; const e: Boolean; const msg: PChar);
begin
  {$ifdef LUA_USE_APICHECK}

  if Assigned(fplua_apicheck) then
    fplua_apicheck(L, e, msg)
  {$ifdef FPLUA_ASSERT}
  else if Assigned(fplua_assert) then
    fplua_assert(e);
  {$endif}

  {$else not LUA_USE_APICHECK}

  {$ifdef FPLUA_ASSERT}
  if Assigned(fplua_assert) then
    fplua_assert(e);
  {$endif}

  {$endif LUA_USE_APICHECK}
end;

function check_exp(const c: Boolean; const e: lua_CFunction): lua_CFunction;
begin
  lua_assert(c);
  Result := e;
end;

///* realloc stack keeping its size */
//#define condmovestack(L,pre,pos)  \
//        { int sz_ = (L)->stacksize; pre; luaD_reallocstack((L), sz_); pos; }
procedure condmovestack(var L: lua_State);
var
  sz_: Integer;
begin
  sz_ := L.stacksize;
  luaD_reallocstack(L, sz_);
end;

//#define condchangemem(L,pre,pos)  \
//        { if (G(L)->gcrunning) { pre; luaC_fullgc(L, 0); pos; } }
procedure condchangemem(var L: lua_State);
begin
  if L.l_G^.gcrunning then
    luaC_fullgc(L, 0);
end;

end.

