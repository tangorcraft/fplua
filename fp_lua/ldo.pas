unit ldo;
(*
** Stack and Call structure of Lua
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common, lzio;

(*
** Macro to check stack size and grow stack if needed.  Parameters
** 'pre'/'pos' allow the macro to preserve a pointer into the
** stack across reallocations, doing the work only when needed.
** 'condmovestack' is used in heavy tests to force a stack reallocation
** at every check.
*)
//#define luaD_checkstackaux(L,n,pre,pos)  \
//      if (L->stack_last - L->top <= (n)) \
//        { pre; luaD_growstack(L, n); pos; } else { condmovestack(L,pre,pos); }
procedure luaD_checkstackaux(const L: Plua_State); // stub declaration, this macro need to be unwrapped

(* In general, 'pre'/'pos' are empty (nothing to save) *)
//#define luaD_checkstack(L,n)    luaD_checkstackaux(L,n,(void)0,(void)0)
procedure luaD_checkstack(const L: Plua_State; const n: Integer);


function savestack(const L: Plua_State; const p: Pointer): PtrInt;
function restorestack(const L: Plua_State; const n: PtrInt): PTValue;


(* type of protected functions, to be ran by 'runprotected' *)
//typedef void (*Pfunc) (lua_State *L, void *ud);
type
  Pfunc = procedure (const L: Plua_State; const ud: Pointer);

{ TODO
LUAI_FUNC int luaD_protectedparser (lua_State *L, ZIO *z, const char *name,
                                                  const char *mode);
LUAI_FUNC void luaD_hook (lua_State *L, int event, int line);
LUAI_FUNC int luaD_precall (lua_State *L, StkId func, int nresults);
LUAI_FUNC void luaD_call (lua_State *L, StkId func, int nResults);
LUAI_FUNC void luaD_callnoyield (lua_State *L, StkId func, int nResults);
LUAI_FUNC int luaD_pcall (lua_State *L, Pfunc func, void *u,
                                        ptrdiff_t oldtop, ptrdiff_t ef);
LUAI_FUNC int luaD_poscall (lua_State *L, CallInfo *ci, StkId firstResult,
                                          int nres);
LUAI_FUNC void luaD_reallocstack (lua_State *L, int newsize);
LUAI_FUNC void luaD_growstack (lua_State *L, int n);
LUAI_FUNC void luaD_shrinkstack (lua_State *L);
LUAI_FUNC void luaD_inctop (lua_State *L);

LUAI_FUNC l_noret luaD_throw (lua_State *L, int errcode);
LUAI_FUNC int luaD_rawrunprotected (lua_State *L, Pfunc f, void *ud);
}
function luaD_protectedparser(const L: Plua_State; const z: PZIO; const name, mode: PChar): Integer;
procedure luaD_hook(const L: Plua_State; const event, line: Integer);
function luaD_precall(const L: Plua_State; func: StkId; const nresults: Integer): Boolean;
procedure luaD_call(const L: Plua_State; const func: StkId; const nResults: Integer);
procedure luaD_callnoyield(const L: Plua_State; const func: StkId; const nResults: Integer);
function luaD_pcall(const L: Plua_State; const func: Pfunc; const u: Pointer;
  const old_top, ef: PtrInt): Integer;
function luaD_poscall(const L: Plua_State; const ci: PCallInfo; firstResult: StkId;
  const nres: Integer): Boolean;
procedure luaD_reallocstack(const L: Plua_State; const newsize: Integer);
procedure luaD_growstack(const L: Plua_State; const n: Integer);
procedure luaD_shrinkstack(const L: Plua_State);
procedure luaD_inctop(const L: Plua_State);

procedure luaD_throw(const L: Plua_State; const errcode: Integer);
function luaD_rawrunprotected(const L: Plua_State; const f: Pfunc; const ud: Pointer): Integer;

// functions declared in lua.h, but implemented in ldo.c, called from fp_lua.pas
function lua_yieldk(const L: Plua_State; const nresults: Integer;
  const ctx: lua_KContext; const k: lua_KFunction): Integer;
function lua_resume(const L, from: Plua_State; const nargs: Integer): Integer;
function lua_isyieldable(const L: Plua_State): lu_int;

implementation

uses
  SysUtils, fp_lua, fplua_lp_common,
  lapi, ldebug, lfunc, lgc, lmem, lobject, lopcodes, lparser, lstate, lstring, ltable, ltm, lundump, lvm;


//#define errorstatus(s)  ((s) > LUA_YIELD)
function errorstatus(const s: Integer): Boolean;
begin
  Result := s > LUA_YIELD;
end;

(*
** LUAI_THROW/LUAI_TRY define how Lua does exception handling. By
** default, Lua handles errors with exceptions when compiling as
** C++ code, with _longjmp/_setjmp when asked to use them, and with
** longjmp/setjmp otherwise.
**
** While FPC have longjmp/setjmp Delphi does not, so
** FP-Lua will always use exceptions
*)
type
  ELuaException = class(Exception);

//#define LUAI_THROW(L,c)         throw(c)
procedure LUAI_THROW(const L; const c: Plua_longjmp);
begin
  raise ELuaException.CreateFmt('fp-lua error#%d',[c^.status]) at
  {$IFDEF FPC}
  get_caller_addr(get_frame);
  {$else Delphi}
  ReturnAddress;
  {$endif}
end;

//#define LUAI_TRY(L,c,a) \
//        try { a } catch(...) { if ((c)->status == 0) (c)->status = -1; }
procedure LUAI_TRY(); // dummy function, macros need unwrap
begin
end;

//struct lua_longjmp; defined in fplua_types

//static void seterrorobj (lua_State *L, int errcode, StkId oldtop)
procedure seterrorobj(const L: Plua_State; const errcode: Integer; const oldtop: StkId);
begin
  case (errcode) of
    LUA_ERRMEM:   //* memory error? */
      setsvalue2s(L, oldtop, G(L)^.memerrmsg); //* reuse preregistered msg. */
    LUA_ERRERR:
      setsvalue2s(L, oldtop, luaS_newliteral(L, 'error in error handling'));
    else
      setobjs2s(L, oldtop, L^.top - 1);  //* error message on current top */
  end;
  L^.top := oldtop + 1;
end;


//static void callhook (lua_State *L, CallInfo *ci)
procedure callhook(const L: Plua_State; const ci: PCallInfo);
var
  hook: Integer;
begin
  hook := LUA_HOOKCALL;
  inc(ci^.u.l_savedpc);  //* hooks assume 'pc' is already incremented */
  if isLua(ci^.previous) and
     (GET_OPCODE((ci^.previous^.u.l_savedpc - 1)^) = OP_TAILCALL) then
  begin
    ci^.callstatus := ci^.callstatus or CIST_TAIL;
    hook := LUA_HOOKTAILCALL;
  end;
  luaD_hook(L, hook, -1);
  Dec(ci^.u.l_savedpc);  //* correct 'pc' */
end;


//static StkId adjust_varargs (lua_State *L, Proto *p, int actual)
function adjust_varargs(const L: Plua_State; const p: PProto; const actual: Integer): StkId;
var
  i, nfixargs: Integer;
  base, fixed: StkId;
begin
  nfixargs := p^.numparams;
  //* move fixed parameters to final position */
  fixed := L^.top - actual;  //* first fixed argument */
  base := L^.top;  //* final position of first argument */
  i := 0;
  while (i < nfixargs) and (i < actual) do
  begin
    setobjs2s(L, L^.top, fixed + i);
    inc(L^.top);
    setnilvalue(fixed + i);  //* erase original copy (for GC) */
    inc(i);
  end;
  while (i < nfixargs) do
  begin
    setnilvalue(L^.top);  //* complete missing arguments */
    inc(L^.top);
    inc(i);
  end;
  Result := base;
end;


(*
** Check whether __call metafield of 'func' is a function. If so, put
** it in stack below original 'func' so that 'luaD_precall' can call
** it. Raise an error if __call metafield is not a function.
*)
//static void tryfuncTM (lua_State *L, StkId func)
procedure tryfuncTM(const L: Plua_State; const func: StkId);
var
  tm: PTValue;
  p: StkId;
begin
  tm := luaT_gettmbyobj(L, func, TM_CALL);
  if (not ttisfunction(tm)) then
    luaG_typeerror(L, func, 'call');
  //* Open a hole inside the stack at 'func' */
  p := L^.top;
  while (p > func) do
  begin
    setobjs2s(L, p, p-1);
    Dec(p);
  end;
  Inc(L^.top);  //* slot ensured by caller */
  setobj2s(L, func, tm);  //* tag method is the new function to be called */
end;


(*
** Given 'nres' results at 'firstResult', move 'wanted' of them to 'res'.
** Handle most typical cases (zero results for commands, one result for
** expressions, multiple results for tail calls/single parameters)
** separated.
*)
//static int moveresults (lua_State *L, const TValue *firstResult, StkId res,
//                                      int nres, int wanted)
function moveresults(const L: Plua_State; firstResult: PTValue;
  const res: StkId; const nres, wanted: Integer): Boolean;
var
  i: Integer;
begin
  case (wanted) of  //* handle typical cases separately */
    0: ;  //* nothing to move */
    1: begin  //* one result needed */
      if (nres = 0) then //* no results? */
        firstResult := luaO_nilobject;  //* adjust with nil */
      setobjs2s(L, res, firstResult);  //* move it to proper place */
    end;
    LUA_MULTRET: begin
      for i := 0 to nres-1 do  //* move all results to correct place */
        setobjs2s(L, res + i, firstResult + i);
      L^.top := res + nres;
      Exit(False);  //* wanted == LUA_MULTRET */
    end;
    else begin
      if (wanted <= nres) then  //* enough results? */
      begin
        for i := 0 to wanted-1 do //* move wanted results to correct place */
          setobjs2s(L, res + i, firstResult + i);
      end
      else //* not enough results; use all of them plus nils */
      begin
        i := 0;
        while i < nres do //* move all results to correct place */
        begin
          setobjs2s(L, res + i, firstResult + i);
          inc(i);
        end;
        while (i < wanted) do //* complete wanted number of results */
        begin
          setnilvalue(res + i);
          inc(i);
        end;
      end;
    end;
  end;
  L^.top := res + wanted;  //* top points after the last result */
  Result := True;
end;


//#define next_ci(L) (L->ci = (L->ci->next ? L->ci->next : luaE_extendCI(L)))
function next_ci(const L: Plua_State): PCallInfo;
begin
  if L^.ci^.next <> nil then
    L^.ci := L^.ci^.next
  else
    L^.ci := luaE_extendCI(L);
  Result := L^.ci;
end;

(* macro to check stack size, preserving 'p' *)
//#define checkstackp(L,n,p)  \
//  luaD_checkstackaux(L, n, \
//    ptrdiff_t t__ = savestack(L, p);  /* save 'p' */ \
//    luaC_checkGC(L),  /* stack grow uses memory */ \
//    p = restorestack(L, t__))  /* 'pos' part: restore 'p' */
procedure checkstackp(const L: Plua_State; const n: Integer; var p: StkId);
var
  t__: PtrInt;
  {$ifdef HARDSTACKTESTS}
  sz_: Integer;
  {$endif}
begin
  // unwrap luaD_checkstackaux macro
  if (L^.stack_last - L^.top) <= n then
  begin
    t__ := savestack(L, p);  //* save 'p' */
    luaC_checkGC(L);  //* stack grow uses memory */
    luaD_growstack(L, n);
    p := restorestack(L, t__); //* 'pos' part: restore 'p' */
  end
  // unwrap condmovestack macro
  {$ifdef HARDSTACKTESTS}
  else
  begin
    sz_ := L^.stacksize;
    t__ := savestack(L, p);  //* save 'p' */
    luaC_checkGC(L);  //* stack grow uses memory */
    luaD_reallocstack(L, sz_);
    p := restorestack(L, t__); //* 'pos' part: restore 'p' */
  end
  {$endif}
  ;
end;


(*
** Completes the execution of an interrupted C function, calling its
** continuation function.
*)
//static void finishCcall (lua_State *L, int status)
procedure finishCcall(const L: Plua_State; const status: Integer);
var
  ci: PCallInfo;
  n: Integer;
begin
  ci := L^.ci;
  //* must have a continuation and must be able to call it */
  lua_assert((ci^.u.c_k <> Nil) and (L^.nny = 0));
  //* error status can only happen in a protected call */
  lua_assert(((ci^.callstatus and CIST_YPCALL) <> 0) or (status = LUA_YIELD));
  if (ci^.callstatus and CIST_YPCALL) <> 0 then  //* was inside a pcall? */
  begin
    ci^.callstatus := ci^.callstatus and not CIST_YPCALL;  //* continuation is also inside it */
    L^.errfunc := ci^.u.c_old_errfunc;  //* with the same error function */
  end;
  (* finish 'lua_callk'/'lua_pcall'; CIST_YPCALL and 'errfunc' already
     handled *)
  adjustresults(L, ci^.nresults);
  lua_unlock(L);
  n := ci^.u.c_k(L, status, ci^.u.c_ctx);  //* call continuation function */
  lua_lock(L);
  api_checknelems(L, n);
  luaD_poscall(L, ci, L^.top - n, n);  //* finish 'luaD_precall' */
end;


(*
** Executes "full continuation" (everything in the stack) of a
** previously interrupted coroutine until the stack is empty (or another
** interruption long-jumps out of the loop). If the coroutine is
** recovering from an error, 'ud' points to the error status, which must
** be passed to the first continuation function (otherwise the default
** status is LUA_YIELD).
*)
//static void unroll (lua_State *L, void *ud)
procedure unroll(const L: Plua_State; const ud: Pointer);
begin
  if (ud <> Nil) then //* error status? */
    finishCcall(L, PInteger(ud)^);  //* finish 'lua_pcallk' callee */
  while (L^.ci <> @L^.base_ci) do //* something in the stack */
  begin
    if (not isLua(L^.ci)) then //* C function? */
      finishCcall(L, LUA_YIELD)  //* complete its execution */
    else   //* Lua function */
    begin
      luaV_finishOp(L);  //* finish interrupted instruction */
      luaV_execute(L);  //* execute down to higher C 'boundary' */
    end;
  end;
end;


(*
** Try to find a suspended protected call (a "recover point") for the
** given thread.
*)
//static CallInfo *findpcall (lua_State *L)
function findpcall(const L: Plua_State): PCallInfo;
begin
  //CallInfo *ci; //Result
  Result := L^.ci;
  while (Result <> Nil) do  //* search for a pcall */
  begin
    if (Result^.callstatus and CIST_YPCALL) <> 0 then
      Exit;
    Result := Result^.previous;
  end;
  //Result := Nil;  //* no pending pcall */
end;


(*
** Recovers from an error in a coroutine. Finds a recover point (if
** there is one) and completes the execution of the interrupted
** 'luaD_pcall'. If there is no recover point, returns zero.
*)
//static int recover (lua_State *L, int status)
function recover(const L: Plua_State; const status: Integer): Boolean;
var
  oldtop: StkId;
  ci: PCallInfo;
begin
  ci := findpcall(L);
  if (ci = Nil) then Exit(False);  //* no recovery point */
  //* "finish" luaD_pcall */
  oldtop := restorestack(L, ci^.extra);
  luaF_close(L, oldtop);
  seterrorobj(L, status, oldtop);
  L^.ci := ci;
  L^.allowhook := lu_byte(getoah(ci^.callstatus) <> 0);  //* restore original 'allowhook' */
  L^.nny := 0;  //* should be zero to be yieldable */
  luaD_shrinkstack(L);
  L^.errfunc := ci^.u.c_old_errfunc;
  Result := True;  //* continue running the coroutine */
end;


(*
** Signal an error in the call to 'lua_resume', not in the execution
** of the coroutine itself. (Such errors should not be handled by any
** coroutine error handler and should not kill the coroutine.)
*)
//static int resume_error (lua_State *L, const char *msg, int narg)
function resume_error(const L: Plua_State; const msg: PChar; const narg: Integer): Integer;
begin
  L^.top := L^.top - narg;  //* remove args from the stack */
  setsvalue2s(L, L^.top, luaS_new(L, msg));  //* push error message */
  api_incr_top(L);
  lua_unlock(L);
  Result := LUA_ERRRUN;
end;


(*
** Do the work for 'lua_resume' in protected mode. Most of the work
** depends on the status of the coroutine: initial state, suspended
** inside a hook, or regularly suspended (optionally with a continuation
** function), plus erroneous cases: non-suspended coroutine or dead
** coroutine.
*)
//static void resume (lua_State *L, void *ud)
procedure resume(const L: Plua_State; const ud: Pointer);
var
  n: Integer;
  firstArg: StkId;
  ci: PCallInfo;
begin
  n := PInteger(ud)^;  //* number of arguments */
  firstArg := L^.top - n;  //* first argument */
  ci := L^.ci;
  if (L^.status = LUA_OK) then //* starting a coroutine? */
  begin
    if (not luaD_precall(L, firstArg - 1, LUA_MULTRET)) then //* Lua function? */
      luaV_execute(L);  //* call it */
  end
  else  //* resuming from previous yield */
  begin
    lua_assert(L^.status = LUA_YIELD);
    L^.status := LUA_OK;  //* mark that it is running (again) */
    ci^.func := restorestack(L, ci^.extra);
    if (isLua(ci)) then //* yielded inside a hook? */
      luaV_execute(L)  //* just continue running Lua code */
    else  //* 'common' yield */
    begin
      if (ci^.u.c_k <> Nil) then  //* does it have a continuation function? */
      begin
        lua_unlock(L);
        n := ci^.u.c_k(L, LUA_YIELD, ci^.u.c_ctx); //* call continuation */
        lua_lock(L);
        api_checknelems(L, n);
        firstArg := L^.top - n;  //* yield results come from continuation */
      end;
      luaD_poscall(L, ci, firstArg, n);  //* finish 'luaD_precall' */
    end;
    unroll(L, Nil);  //* run continuation */
  end;
end;

(*
** Execute a protected parser.
*)
type
  SParser = record  //* data to 'f_parser' */
    z: PZIO;
    buff: Mbuffer;  //* dynamic structure used by the scanner */
    dyd: Dyndata;  //* dynamic structures used by the parser */
    mode: PChar;
    name: PChar;
  end;
  PSParser = ^SParser;

//static void checkmode (lua_State *L, const char *mode, const char *x)
procedure checkmode(const L: Plua_State; const mode, x: PChar);
begin
  if (mode <> nil) and (strscan(mode, x[0]) = Nil) then
  begin
    luaO_pushfstring(L,
       'attempt to load a %s chunk (mode is "%s")', [x, mode]);
    luaD_throw(L, LUA_ERRSYNTAX);
  end
end;


//static void f_parser (lua_State *L, void *ud)
procedure f_parser(const L: Plua_State; const ud: Pointer);
var
  cl: PLClosure;
  p: PSParser;
  c: Integer;
begin
  p := PSParser(ud);
  c := zgetc(p^.z^);  //* read first character */
  if (c = ord(LUA_SIGNATURE[0])) then
  begin
    checkmode(L, p^.mode, 'binary');
    cl := luaU_undump(L, p^.z, p^.name);
  end
  else
  begin
    checkmode(L, p^.mode, 'text');
    cl := luaY_parser(L, p^.z, @p^.buff, @p^.dyd, p^.name, c);
  end;
  lua_assert(cl^.header.nupvalues = cl^.p^.sizeupvalues);
  luaF_initupvals(L, cl^);
end;


procedure luaD_checkstackaux(const L: Plua_State);
begin

end;

//#define luaD_checkstackaux(L,n,pre,pos)  \
//      if (L->stack_last - L->top <= (n)) \
//        { pre; luaD_growstack(L, n); pos; } else { condmovestack(L,pre,pos); }
(* In general, 'pre'/'pos' are empty (nothing to save) *)
//#define luaD_checkstack(L,n)    luaD_checkstackaux(L,n,(void)0,(void)0)
procedure luaD_checkstack(const L: Plua_State; const n: Integer);
begin
  if (L^.stack_last - L^.top) <= n then
    luaD_growstack(L, n)
  else
    condmovestack(L);
end;

//#define savestack(L,p)          ((char *)(p) - (char *)L->stack)
function savestack(const L: Plua_State; const p: Pointer): PtrInt;
begin
  Result := p - Pointer(L^.stack)
end;

//#define restorestack(L,n)       ((TValue *)((char *)L->stack + (n)))
function restorestack(const L: Plua_State; const n: PtrInt): PTValue;
begin
  Result := PTValue(Pointer(L^.stack) + n);
end;


function luaD_protectedparser(const L: Plua_State; const z: PZIO; const name,
  mode: PChar): Integer;
var
  p: SParser;
  status: Integer;
begin
  inc(L^.nny);  //* cannot yield during parsing */
  p.z := z; p.name := name; p.mode := mode;
  p.dyd.actvar.arr := Nil; p.dyd.actvar.size := 0;
  p.dyd.gt.arr := Nil; p.dyd.gt.size := 0;
  p.dyd.label_.arr := Nil; p.dyd.label_.size := 0;
  luaZ_initbuffer(L, @p.buff);
  status := luaD_pcall(L, @f_parser, @p, savestack(L, L^.top), L^.errfunc);
  luaZ_freebuffer(L, p.buff);
  luaM_freearray(L, p.dyd.actvar.arr, sizeof(Vardesc), p.dyd.actvar.size);
  luaM_freearray(L, p.dyd.gt.arr, sizeof(Labeldesc), p.dyd.gt.size);
  luaM_freearray(L, p.dyd.label_.arr, sizeof(Labellist), p.dyd.label_.size);
  dec(L^.nny);
  Result := status;
end;

(*
** Call a hook for the given event. Make sure there is a hook to be
** called. (Both 'L->hook' and 'L->hookmask', which triggers this
** function, can be changed asynchronously by signals.)
*)
procedure luaD_hook(const L: Plua_State; const event, line: Integer);
var
  hook: lua_Hook;
  ci: PCallInfo;
  top, ci_top: PtrInt;
  ar: lua_Debug;
begin
  InterlockedExchange(Pointer(hook), Pointer(L^.hook));
  if Assigned(hook) and (L^.allowhook <> 0) then //* make sure there is a hook */
  begin
    ci := L^.ci;
    top := savestack(L, L^.top);
    ci_top := savestack(L, ci^.top);
    ar.event := event;
    ar.currentline := line;
    ar.i_ci := ci;
    luaD_checkstack(L, LUA_MINSTACK);  //* ensure minimum stack size */
    ci^.top := L^.top + LUA_MINSTACK;
    lua_assert(ci^.top <= L^.stack_last);
    L^.allowhook := 0;  //* cannot call hooks inside a hook */
    ci^.callstatus := ci^.callstatus or CIST_HOOKED;
    lua_unlock(L);
    hook(L, @ar);
    lua_lock(L);
    lua_assert(L^.allowhook = 0);
    L^.allowhook := 1;
    ci^.top := restorestack(L, ci_top);
    L^.top := restorestack(L, top);
    ci^.callstatus := ci^.callstatus and not CIST_HOOKED;
  end;
end;

(*
** Prepares a function call: checks the stack, creates a new CallInfo
** entry, fills in the relevant information, calls hook if needed.
** If function is a C function, does the call, too. (Otherwise, leave
** the execution ('luaV_execute') to the caller, to allow stackless
** calls.) Returns true iff function has been executed (C function).
*)
function luaD_precall(const L: Plua_State; func: StkId; const nresults: Integer): Boolean;
label Cfunc;
var
  f: lua_CFunction;
  ci: PCallInfo;
  n, fsize: Integer;
  base: StkId;
  p: PProto;
begin
  case (ttype(func)) of
    LUA_TCCL: begin //* C closure */
      f := clCvalue(func)^.f;
      goto Cfunc;
    end;
    LUA_TLCF: begin //* light C function */
      f := fvalue(func);
Cfunc:
      //int n;  //* number of returns */
      checkstackp(L, LUA_MINSTACK, func);  //* ensure minimum stack size */
      ci := next_ci(L);  //* now 'enter' new function */
      ci^.nresults := nresults;
      ci^.func := func;
      ci^.top := L^.top + LUA_MINSTACK;
      lua_assert(ci^.top <= L^.stack_last);
      ci^.callstatus := 0;
      if (L^.hookmask and LUA_MASKCALL) <> 0 then
        luaD_hook(L, LUA_HOOKCALL, -1);
      lua_unlock(L);
      n := f(L);  //* do the actual call */
      lua_lock(L);
      api_checknelems(L, n);
      luaD_poscall(L, ci, L^.top - n, n);
      Exit(True);
    end;
    LUA_TLCL: begin  //* Lua function: prepare its call */
      p := clLvalue(func)^.p;
      n := cast_int(L^.top - func) - 1;  //* number of real arguments */
      fsize := p^.maxstacksize;  //* frame size */
      checkstackp(L, fsize, func);
      if (p^.is_vararg) then
        base := adjust_varargs(L, p, n)
      else  //* non vararg function */
      begin
        while (n < p^.numparams) do
        begin
          setnilvalue(L^.top);  //* complete missing arguments */
          Inc(L^.top);
          Inc(n);
        end;
        base := func + 1;
      end;
      ci := next_ci(L);  //* now 'enter' new function */
      ci^.nresults := nresults;
      ci^.func := func;
      ci^.u.l_base := base;
      ci^.top := base + fsize;
      L^.top := ci^.top;
      lua_assert(ci^.top <= L^.stack_last);
      ci^.u.l_savedpc := p^.code;  //* starting point */
      ci^.callstatus := CIST_LUA;
      if (L^.hookmask and LUA_MASKCALL) <> 0 then
        callhook(L, ci);
      Exit(False);
    end;
    else begin  //* not a function */
      checkstackp(L, 1, func);  //* ensure space for metamethod */
      tryfuncTM(L, func);  //* try to get '__call' metamethod */
      Result := luaD_precall(L, func, nresults); //* now it must be a function */
    end;
  end;
end;

(*
** Check appropriate error for stack overflow ("regular" overflow or
** overflow while handling stack overflow). If 'nCalls' is larger than
** LUAI_MAXCCALLS (which means it is handling a "regular" overflow) but
** smaller than 9/8 of LUAI_MAXCCALLS, does not report an error (to
** allow overflow handling to work)
*)
//static void stackerror (lua_State *L)
procedure stackerror(const L: Plua_State);
begin
  if (L^.nCcalls = LUAI_MAXCCALLS) then
    luaG_runerror(L, 'C stack overflow')
  else if (L^.nCcalls >= (LUAI_MAXCCALLS + (LUAI_MAXCCALLS shr 3))) then
    luaD_throw(L, LUA_ERRERR);  //* error while handing stack error */
end;

(*
** Call a function (C or Lua). The function to be called is at *func.
** The arguments are on the stack, right after the function.
** When returns, all the results are on the stack, starting at the original
** function position.
*)
procedure luaD_call(const L: Plua_State; const func: StkId; const nResults: Integer);
begin
  inc(L^.nCcalls);
  if (L^.nCcalls >= LUAI_MAXCCALLS) then
    stackerror(L);
  if (not luaD_precall(L, func, nResults)) then //* is a Lua function? */
    luaV_execute(L);  //* call it */
  dec(L^.nCcalls);
end;

(*
** Similar to 'luaD_call', but does not allow yields during the call
*)
procedure luaD_callnoyield(const L: Plua_State; const func: StkId; const nResults: Integer);
begin
  inc(L^.nny);
  luaD_call(L, func, nResults);
  dec(L^.nny);
end;

function luaD_pcall(const L: Plua_State; const func: Pfunc; const u: Pointer; const old_top,
  ef: PtrInt): Integer;
var
  status: Integer;
  old_ci: PCallInfo;
  old_allowhooks: lu_byte;
  old_nny: Word;
  old_errfunc: PtrInt;
  oldtop: StkId;
begin
  old_ci := L^.ci;
  old_allowhooks := L^.allowhook;
  old_nny := L^.nny;
  old_errfunc := L^.errfunc;
  L^.errfunc := ef;
  status := luaD_rawrunprotected(L, func, u);
  if (status <> LUA_OK) then  //* an error occurred? */
  begin
    oldtop := restorestack(L, old_top);
    luaF_close(L, oldtop);  //* close possible pending closures */
    seterrorobj(L, status, oldtop);
    L^.ci := old_ci;
    L^.allowhook := old_allowhooks;
    L^.nny := old_nny;
    luaD_shrinkstack(L);
  end;
  L^.errfunc := old_errfunc;
  Result := status;
end;

(*
** Finishes a function call: calls hook if necessary, removes CallInfo,
** moves current number of results to proper place; returns 0 iff call
** wanted multiple (variable number of) results.
*)
function luaD_poscall(const L: Plua_State; const ci: PCallInfo; firstResult: StkId;
  const nres: Integer): Boolean;
var
  res: StkId;
  wanted: Integer;
  fr: PtrInt;
begin
  wanted := ci^.nresults;
  if (L^.hookmask and (LUA_MASKRET or LUA_MASKLINE)) <> 0 then
  begin
    if (L^.hookmask and LUA_MASKRET) <> 0 then
    begin
      fr := savestack(L, firstResult);  //* hook may change stack */
      luaD_hook(L, LUA_HOOKRET, -1);
      firstResult := restorestack(L, fr);
    end;
    L^.oldpc := ci^.previous^.u.l_savedpc;  //* 'oldpc' for caller function */
  end;
  res := ci^.func;  //* res == final position of 1st result */
  L^.ci := ci^.previous;  //* back to caller */
  //* move results to proper place */
  Result := moveresults(L, firstResult, res, nres, wanted);
end;

(*
** ===================================================================
** Stack reallocation
** ===================================================================
*)
//static void correctstack (lua_State *L, TValue *oldstack)
procedure correctstack(const L: Plua_State; const oldstack: PTValue);
var
  ci: PCallInfo;
  up: PUpVal;
begin
  L^.top := (L^.top - oldstack) + L^.stack;
  up := L^.openupval;
  while (up <> Nil) do
  begin
    up^.v := (up^.v - oldstack) + L^.stack;
    up := up^.u_open_next;
  end;
  ci := L^.ci;
  while (ci <> Nil) do
  begin
    ci^.top := (ci^.top - oldstack) + L^.stack;
    ci^.func := (ci^.func - oldstack) + L^.stack;
    if (isLua(ci)) then
      ci^.u.l_base := (ci^.u.l_base - oldstack) + L^.stack;
    ci := ci^.previous;
  end;
end;

(* some space for error handling *)
const
  ERRORSTACKSIZE = (LUAI_MAXSTACK + 200);

procedure luaD_reallocstack(const L: Plua_State; const newsize: Integer);
var
  oldstack: PTValue;
  lim: Integer;
begin
  oldstack := L^.stack;
  lim := L^.stacksize;
  lua_assert((newsize <= LUAI_MAXSTACK) or (newsize = ERRORSTACKSIZE));
  lua_assert((L^.stack_last - L^.stack) = (L^.stacksize - EXTRA_STACK));
  luaM_reallocvector(L, L^.stack, L^.stacksize, newsize, sizeof(TValue));
  while (lim < newsize) do
  begin
    setnilvalue(L^.stack + lim); //* erase new segment */
    inc(lim);
  end;
  L^.stacksize := newsize;
  L^.stack_last := L^.stack + newsize - EXTRA_STACK;
  correctstack(L, oldstack);
end;

procedure luaD_growstack(const L: Plua_State; const n: Integer);
var
  size, needed, newsize: Integer;
begin
  size := L^.stacksize;
  if (size > LUAI_MAXSTACK) then //* error after extra size? */
    luaD_throw(L, LUA_ERRERR)
  else
  begin
    needed := cast_int(L^.top - L^.stack) + n + EXTRA_STACK;
    newsize := 2 * size;
    if (newsize > LUAI_MAXSTACK) then newsize := LUAI_MAXSTACK;
    if (newsize < needed) then newsize := needed;
    if (newsize > LUAI_MAXSTACK) then //* stack overflow? */
    begin
      luaD_reallocstack(L, ERRORSTACKSIZE);
      luaG_runerror(L, 'stack overflow');
    end
    else
      luaD_reallocstack(L, newsize);
  end;
end;

//static int stackinuse (lua_State *L)
function stackinuse(const L: Plua_State): Integer;
var
  ci: PCallInfo;
  lim: StkId;
begin
  lim := L^.top;
  ci := L^.ci;
  while (ci <> Nil) do
  begin
    if (lim < ci^.top) then lim := ci^.top;
    ci := ci^.previous;
  end;
  lua_assert(lim <= L^.stack_last);
  Result := cast_int(lim - L^.stack) + 1;  //* part of stack in use */
end;

procedure luaD_shrinkstack(const L: Plua_State);
var
  inuse, goodsize: Integer;
begin
  inuse := stackinuse(L);
  goodsize := inuse + (inuse div 8) + 2*EXTRA_STACK;
  if (goodsize > LUAI_MAXSTACK) then
    goodsize := LUAI_MAXSTACK;  //* respect stack limit */
  if (L^.stacksize > LUAI_MAXSTACK) then //* had been handling stack overflow? */
    luaE_freeCI(L)  //* free all CIs (list grew because of an error) */
  else
    luaE_shrinkCI(L);  //* shrink list */
  (* if thread is currently not handling a stack overflow and its
     good size is smaller than current size, shrink its stack *)
  if (inuse <= (LUAI_MAXSTACK - EXTRA_STACK)) and
     (goodsize < L^.stacksize) then
    luaD_reallocstack(L, goodsize)
  else  //* don't change stack */
    condmovestack(L);  //* (change only for debugging) */
end;

procedure luaD_inctop(const L: Plua_State);
begin
  luaD_checkstack(L, 1);
  Inc(L^.top);
end;

(* =================================================================== *)

procedure luaD_throw(const L: Plua_State; const errcode: Integer);
var
  gs: Pglobal_State;
begin
  if (L^.errorJmp <> nil) then  //* thread has an error handler? */
  begin
    L^.errorJmp^.status := errcode;  //* set status */
    LUAI_THROW(L, L^.errorJmp);  //* jump to it */
  end
  else  //* thread has no error handler */
  begin
    gs := G(L);
    L^.status := cast_byte(errcode);  //* mark it as dead */
    if (gs^.mainthread^.errorJmp <> nil) then //* main thread has a handler? */
    begin
      setobjs2s(L, gs^.mainthread^.top, L^.top - 1);  //* copy error obj. */
      inc(gs^.mainthread^.top);
      luaD_throw(gs^.mainthread, errcode);  //* re-throw in main thread */
    end
    else  //* no handler at all; abort */
    begin
      if Assigned(gs^.panic) then //* panic function? */
      begin
        seterrorobj(L, errcode, L^.top);  //* assume EXTRA_STACK */
        if (L^.ci^.top < L^.top) then
          L^.ci^.top := L^.top;  //* pushing msg. can break this invariant */
        lua_unlock(L);
        gs^.panic(L);  //* call panic function (last chance to jump out) */
      end;
      abort();
    end;
  end;
end;

function luaD_rawrunprotected(const L: Plua_State; const f: Pfunc; const ud: Pointer): Integer;
var
  oldnCcalls: Word;
  lj: lua_longjmp;
begin
  oldnCcalls := L^.nCcalls;
  lj.status := LUA_OK;
  lj.previous := L^.errorJmp;  //* chain new error handler */
  L^.errorJmp := @lj;
  //LUAI_TRY();
  try
    f(L, ud);
  except
    if lj.status = 0 then
      lj.status := -1;
  end;
  L^.errorJmp := lj.previous;  //* restore old error handler */
  L^.nCcalls := oldnCcalls;
  Result := lj.status;
end;

function lua_yieldk(const L: Plua_State; const nresults: Integer; const ctx: lua_KContext;
  const k: lua_KFunction): Integer;
var
  ci: PCallInfo;
begin
  ci := L^.ci;
  luai_userstateyield(L, nresults);
  lua_lock(L);
  api_checknelems(L, nresults);
  if (L^.nny > 0) then
  begin
    if (L <> G(L)^.mainthread) then
      luaG_runerror(L, 'attempt to yield across a C-call boundary')
    else
      luaG_runerror(L, 'attempt to yield from outside a coroutine');
  end;
  L^.status := LUA_YIELD;
  ci^.extra := savestack(L, ci^.func);  //* save current 'func' */
  if (isLua(ci)) then  //* inside a hook? */
  begin
    api_check(L, k = Nil, 'hooks cannot continue after yielding');
  end
  else
  begin
    ci^.u.c_k := k;
    if (ci^.u.c_k <> Nil) then //* is there a continuation? */
      ci^.u.c_ctx := ctx;  //* save context */
    ci^.func := L^.top - nresults - 1;  //* protect stack below results */
    luaD_throw(L, LUA_YIELD);
  end;
  lua_assert((ci^.callstatus and CIST_HOOKED) <> 0);  //* must be inside a hook */
  lua_unlock(L);
  Result := 0;  //* return to 'luaD_hook' */
end;

function lua_resume(const L, from: Plua_State; const nargs: Integer): Integer;
var
  status: Integer;
  oldnny: Word;
begin
  oldnny := L^.nny;  //* save "number of non-yieldable" calls */
  lua_lock(L);
  if (L^.status = LUA_OK) then  //* may be starting a coroutine */
  begin
    if (L^.ci <> @L^.base_ci) then  //* not in base level? */
      Exit( resume_error(L, 'cannot resume non-suspended coroutine', nargs) );
  end
  else if (L^.status <> LUA_YIELD) then
    Exit( resume_error(L, 'cannot resume dead coroutine', nargs) );
  if (from <> nil) then
    L^.nCcalls := from^.nCcalls + 1
  else
    L^.nCcalls := 1;
  if (L^.nCcalls >= LUAI_MAXCCALLS) then
    Exit( resume_error(L, 'C stack overflow', nargs) );
  luai_userstateresume(L, nargs);
  L^.nny := 0;  //* allow yields */
  if (L^.status = LUA_OK) then
    api_checknelems(L, nargs + 1)
  else
    api_checknelems(L, nargs);
  status := luaD_rawrunprotected(L, @resume, @nargs);
  if (status = -1) then //* error calling 'lua_resume'? */
    status := LUA_ERRRUN
  else  //* continue running after recoverable errors */
  begin
    while (errorstatus(status) and recover(L, status)) do
    begin
      //* unroll continuation */
      status := luaD_rawrunprotected(L, @unroll, @status);
    end;
    if (errorstatus(status)) then  //* unrecoverable error? */
    begin
      L^.status := cast_byte(status);  //* mark thread as 'dead' */
      seterrorobj(L, status, L^.top);  //* push error message */
      L^.ci^.top := L^.top;
    end
    else lua_assert(status = L^.status);  //* normal end or yield */
  end;
  L^.nny := oldnny;  //* restore 'nny' */
  dec(L^.nCcalls);
  if (from<> nil) then
    lua_assert(L^.nCcalls = from^.nCcalls)
  else
    lua_assert(L^.nCcalls = 0);
  lua_unlock(L);
  Result := status;
end;

function lua_isyieldable(const L: Plua_State): lu_int;
begin
  Result := (L^.nny = 0);
end;

end.

