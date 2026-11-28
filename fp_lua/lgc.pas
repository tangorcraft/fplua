unit lgc;
(*
** Garbage Collector
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common;

(*
** Collectable objects may have one of three colors: white, which
** means the object is not marked; gray, which means the
** object is marked, but its references may be not marked; and
** black, which means that the object and all its references are marked.
** The main invariant of the garbage collector, while marking objects,
** is that a black object can never point to a white one. Moreover,
** any gray object must be in a "gray list" (gray, grayagain, weak,
** allweak, ephemeron) so that it can be visited again before finishing
** the collection cycle. These lists have no meaning when the invariant
** is not being enforced (e.g., sweep phase).
*)



(* how much to allocate before next GC step *)
//#if !defined(GCSTEPSIZE)
(* ~100 small strings *)
const
  GCSTEPSIZE   = (100 * sizeof(TString));
//#endif


(*
** Possible states of the Garbage Collector
*)
const
  GCSpropagate   = 0;
  GCSatomic      = 1;
  GCSswpallgc    = 2;
  GCSswpfinobj   = 3;
  GCSswptobefnz  = 4;
  GCSswpend      = 5;
  GCScallfin     = 6;
  GCSpause       = 7;

function issweepphase(const g: Pglobal_State): Boolean;

(*
** macro to tell when main invariant (white objects cannot point to black
** ones) must be kept. During a collection, the sweep
** phase may break the invariant, as objects turned white may point to
** still-black objects. The invariant is restored when sweep ends and
** all objects are white again.
*)
function keepinvariant(const g: Pglobal_State): Boolean;


function iswhite(const x: PGCObject): Boolean;
function isblack(const x: PGCObject): Boolean;
//* neither white nor black */
function isgray(const x: PGCObject): Boolean;

function tofinalize(const x: PGCObject): Boolean;

function otherwhite(const g: Pglobal_State): lu_byte;
function isdeadm(const ow, m: lu_byte): Boolean;
function isdead(const g: Pglobal_State; const v: PGCObject): Boolean;

procedure changewhite(var x: GCObject);
procedure gray2black(var x: GCObject);

function luaC_white(const g: Pglobal_State): lu_byte;


(*
** Does one step of collection when debt becomes positive. 'pre'/'pos'
** allows some adjustments to be done only when needed. macro
** 'condchangemem' is used only for heavy tests (forcing a full
** GC cycle on every opportunity)
*)
//#define luaC_condGC(L,pre,pos) \
//        { if (G(L)->GCdebt > 0) { pre; luaC_step(L); pos;}; \
//          condchangemem(L,pre,pos); }
procedure luaC_condGC(); // stub declaration, this macro need to be uwrapped

(* more often than not, 'pre'/'pos' are empty *)
procedure luaC_checkGC(const L: Plua_State);

procedure luaC_barrier(const L: Plua_State; const p: PGCObject; const v: PTValue);

procedure luaC_barrierback(const L: Plua_State; const p: PTable; const v: PTValue);

procedure luaC_objbarrier(const L: Plua_State; const p, o: PGCObject);

procedure luaC_upvalbarrier(const L: Plua_State; const uv: PUpVal);

//TODO
procedure luaC_fix(const L: Plua_State; const o: PGCObject);
procedure luaC_freeallobjects(const L: Plua_State);
procedure luaC_step(const L: Plua_State);
procedure luaC_runtilstate(const L: Plua_State; const statesmask: Integer);
procedure luaC_fullgc(const L: Plua_State; const isemergency: Integer);
function luaC_newobj(const L: Plua_State; const tt: Integer; const sz: SizeUInt): PGCObject;
// these 3 don't need to be exposed in interface
//procedure luaC_barrier_(const L: Plua_State; const o, v: PGCObject);
//procedure luaC_barrierback_(const L: Plua_State; const o: PTable);
//procedure luaC_upvalbarrier_(const L: Plua_State; const uv: PUpVal);

procedure luaC_checkfinalizer(const L: Plua_State; const o: PGCObject; const mt: PTable);
procedure luaC_upvdeccount(const L: Plua_State; const uv: PUpVal);

implementation

uses
  fp_lua,
  ldebug, ldo, lfunc, lmem, lobject, lstate, lstring, ltable, ltm;

(*
** some useful bit tricks
*)
// TODO
//#define resetbits(x,m)          ((x) &= cast(lu_byte, ~(m)))
//#define setbits(x,m)            ((x) |= (m))
//#define testbits(x,m)           ((x) & (m))
//#define bitmask(b)              (1<<(b))
//#define bit2mask(b1,b2)         (bitmask(b1) | bitmask(b2))
//#define l_setbit(x,b)           setbits(x, bitmask(b))
//#define resetbit(x,b)           resetbits(x, bitmask(b))
//#define testbit(x,b)            testbits(x, bitmask(b))


(* Layout for bit use in 'marked' field: *)
const
  WHITE0BIT      = 0;  //* object is white (type 0) */
  WHITE1BIT      = 1;  //* object is white (type 1) */
  BLACKBIT       = 2;  //* object is black */
  FINALIZEDBIT   = 3;  //* object has been marked for finalization */
  (* bit 7 is currently used by tests (luaL_checkmemory) *)
  bitmask_WHITE0BIT    = (1 shl WHITE0BIT);
  bitmask_WHITE1BIT    = (1 shl WHITE1BIT);
  bitmask_BLACKBIT     = (1 shl BLACKBIT);
  bitmask_FINALIZEDBIT = (1 shl FINALIZEDBIT);

  //#define WHITEBITS       bit2mask(WHITE0BIT, WHITE1BIT)
  WHITEBITS            = bitmask_WHITE0BIT or bitmask_WHITE1BIT;

//#define issweepphase(g)  \
//        (GCSswpallgc <= (g)->gcstate && (g)->gcstate <= GCSswpend)
function issweepphase(const g: Pglobal_State): Boolean;
begin
  Result := (GCSswpallgc <= g^.gcstate) and (g^.gcstate <= GCSswpend);
end;

//#define keepinvariant(g)        ((g)->gcstate <= GCSatomic)
function keepinvariant(const g: Pglobal_State): Boolean;
begin
  Result := (g^.gcstate <= GCSatomic);
end;

//#define iswhite(x)      testbits((x)->marked, WHITEBITS)
function iswhite(const x: PGCObject): Boolean;
begin
  Result := (x^.marked and WHITEBITS) <> 0;
end;

//#define isblack(x)      testbit((x)->marked, BLACKBIT)
function isblack(const x: PGCObject): Boolean;
begin
  Result := (x^.marked and bitmask_BLACKBIT) <> 0;
end;

//#define isgray(x)  /* neither white nor black */  \
//        (!testbits((x)->marked, WHITEBITS | bitmask(BLACKBIT)))
function isgray(const x: PGCObject): Boolean;
begin
  Result := (x^.marked and (WHITEBITS or bitmask_BLACKBIT)) = 0;
end;


//#define tofinalize(x)   testbit((x)->marked, FINALIZEDBIT)
function tofinalize(const x: PGCObject): Boolean;
begin
  Result := (x^.marked and bitmask_FINALIZEDBIT) <> 0;
end;

//#define otherwhite(g)   ((g)->currentwhite ^ WHITEBITS)
function otherwhite(const g: Pglobal_State): lu_byte;
begin
  Result := g^.currentwhite xor WHITEBITS;
end;

//#define isdeadm(ow,m)   (!(((m) ^ WHITEBITS) & (ow)))
function isdeadm(const ow, m: lu_byte): Boolean;
begin
  Result := ( ( m xor WHITEBITS) and ow ) = 0;
end;

//#define isdead(g,v)     isdeadm(otherwhite(g), (v)->marked)
function isdead(const g: Pglobal_State; const v: PGCObject): Boolean;
begin
  Result := ( ( v^.marked xor WHITEBITS) and otherwhite(g) ) = 0;
end;

//#define changewhite(x)  ((x)->marked ^= WHITEBITS)
procedure changewhite(var x: GCObject);
begin
  x.marked := x.marked xor WHITEBITS;
end;

//#define gray2black(x)   l_setbit((x)->marked, BLACKBIT)
procedure gray2black(var x: GCObject);
begin
  x.marked := x.marked or bitmask_BLACKBIT;
end;

//#define luaC_white(g)   cast(lu_byte, (g)->currentwhite & WHITEBITS)
function luaC_white(const g: Pglobal_State): lu_byte;
begin
  Result := g^.currentwhite and WHITEBITS;
end;


(*
** internal state for collector while inside the atomic phase. The
** collector should never be in this state while running regular code.
*)
const
  GCSinsideatomic = (GCSpause + 1);

(*
** cost of sweeping one element (the size of a small object divided
** by some adjust for the sweep speed)
*)
const
  GCSWEEPCOST   = ((sizeof(TString) + 4) div 4);

(* maximum number of elements to sweep in each single step *)
const
  GCSWEEPMAX    = (cast_int((GCSTEPSIZE div GCSWEEPCOST) div 4));

(* cost of calling one finalizer *)
const
  GCFINALIZECOST = GCSWEEPCOST;


(*
** macro to adjust 'stepmul': 'stepmul' is actually used like
** 'stepmul / STEPMULADJ' (value chosen by tests)
*)
const
  STEPMULADJ = 200;


(*
** macro to adjust 'pause': 'pause' is actually used like
** 'pause / PAUSEADJ' (value chosen by tests)
*)
const
  PAUSEADJ = 100;


(*
** 'makewhite' erases all color bits then sets only the current white
** bit
*)
//#define maskcolors      (~(bitmask(BLACKBIT) | WHITEBITS))
const
  maskcolors: lu_byte = lu_byte(not (bitmask_BLACKBIT or WHITEBITS));
//#define makewhite(g,x)  \
// (x->marked = cast_byte((x->marked & maskcolors) | luaC_white(g)))
procedure makewhite(const g: Pglobal_State; const x: PGCObject);
begin
  x^.marked := (x^.marked and maskcolors) or luaC_white(g);
end;

//#define white2gray(x)   resetbits(x->marked, WHITEBITS)
procedure white2gray(const x: PGCObject);
begin
  x^.marked := x^.marked and not WHITEBITS;
end;

//#define black2gray(x)   resetbit(x->marked, BLACKBIT)
procedure black2gray(const x: PGCObject);
begin
  x^.marked := x^.marked and not bitmask_BLACKBIT;
end;

//#define valiswhite(x)   (iscollectable(x) && iswhite(gcvalue(x)))
function valiswhite(const x: PTValue): Boolean;
begin
  Result := (iscollectable(x) and iswhite(gcvalue(x)));
end;

//#define checkdeadkey(n) lua_assert(!ttisdeadkey(gkey(n)) || ttisnil(gval(n)))
procedure checkdeadkey(const n: PNode);
begin
  lua_assert(not ttisdeadkey(gkey(n)) or ttisnil(gval(n)));
end;

//#define checkconsistency(obj)  \
//  lua_longassert(!iscollectable(obj) || righttt(obj))
procedure checkconsistency(const obj: PTValue);
begin
  lua_longassert(not iscollectable(obj) or righttt(obj));
end;

//static void reallymarkobject (global_State *g, GCObject *o);
procedure reallymarkobject(const g: Pglobal_State; o: PGCObject); forward;

//#define markvalue(g,o) { checkconsistency(o); \
//  if (valiswhite(o)) reallymarkobject(g,gcvalue(o)); }
procedure markvalue(const g: Pglobal_State; const o: PTValue);
begin
  checkconsistency(o);
  if (valiswhite(o)) then reallymarkobject(g, gcvalue(o));
end;

//#define markobject(g,t) { if (iswhite(t)) reallymarkobject(g, obj2gco(t)); }
procedure markobject(const g: Pglobal_State; const t: Pointer);
begin
  if iswhite(obj2gco(t)) then reallymarkobject(g, t);
end;

(*
** mark an object that can be NULL (either because it is really optional,
** or it was stripped as debug info, or inside an uncompleted structure)
*)
//#define markobjectN(g,t)        { if (t) markobject(g,t); }
procedure markobjectN(const g: Pglobal_State; const t: Pointer);
begin
  if t <> nil then markobject(g,t);
end;


procedure luaC_condGC;
begin

end;

//#define luaC_checkGC(L)         luaC_condGC(L,(void)0,(void)0)
procedure luaC_checkGC(const L: Plua_State);
begin
  if (L^.l_G^.GCdebt > 0) then
    luaC_step(L);
  {$ifdef HARDMEMTESTS}
  //condchangemem(L);
  if (L^.l_G^.gcrunning) then
    luaC_fullgc(L, 0);
  {$endif}
end;

(*
** =======================================================
** Generic functions
** =======================================================
*)


(*
** one after last element in a hash array
*)
//#define gnodelast(h)	gnode(h, cast(size_t, sizenode(h)))
function gnodelast(const h: PTable): PNode;
begin
  Result := gnode(h, sizenode(h^));
end;

(*
** link collectable object 'o' into list pointed by 'p'
*)
//#define linkgclist(o,p)  ((o)->gclist = (p), (p) = obj2gco(o))
procedure linkgclist(const o: PTable; var p: PGCObject); overload;
begin
  o^.gclist := p;
  p := obj2gco(o);
end;
procedure linkgclist(const o: PProto; var p: PGCObject); overload;
begin
  o^.gclist := p;
  p := obj2gco(o);
end;
procedure linkgclist(const o: PClosure; var p: PGCObject); overload;
begin
  o^.header.gclist := p;
  p := obj2gco(o);
end;
procedure linkgclist(const o: PCClosure; var p: PGCObject); overload;
begin
  o^.header.gclist := p;
  p := obj2gco(o);
end;
procedure linkgclist(const o: PLClosure; var p: PGCObject); overload;
begin
  o^.header.gclist := p;
  p := obj2gco(o);
end;
procedure linkgclist(const o: Plua_State; var p: PGCObject); overload;
begin
  o^.gclist := p;
  p := obj2gco(o);
end;

(*
** If key is not marked, mark its entry as dead. This allows key to be
** collected, but keeps its entry in the table.  A dead node is needed
** when Lua looks up for a key (it may be part of a chain) and when
** traversing a weak table (key might be removed from the table during
** traversal). Other places never manipulate dead keys, because its
** associated nil value is enough to signal that the entry is logically
** empty.
*)
//static void removeentry (Node *n)
procedure removeentry(const n: PNode);
begin
  lua_assert(ttisnil(gval(n)));
  if (valiswhite(gkey(n))) then
    setdeadvalue(wgkey(n));  //* unused and unmarked key; remove it */
end;


(*
** tells whether a key or value can be cleared from a weak
** table. Non-collectable objects are never removed from weak
** tables. Strings behave as 'values', so are never removed too. for
** other objects: if really collected, cannot keep them; for objects
** being finalized, keep them in keys, but not in values
*)
//static int iscleared (global_State *g, const TValue *o)
function iscleared(const g: Pglobal_State; const o: PTValue): Boolean;
begin
  if (not iscollectable(o)) then
    Result := False
  else if (ttisstring(o)) then
  begin
    markobject(g, tsvalue(o));  //* strings are 'values', so are never weak */
    Result := False;
  end
  else Result := iswhite(gcvalue(o));
end;

(*
** barrier that moves collector forward, that is, mark the white object
** being pointed by a black object. (If in sweep phase, clear the black
** object to white [sweep it] to avoid other barrier calls for this
** same object.)
*)
procedure luaC_barrier_(const L: Plua_State; const o, v: PGCObject);
var
  gs: Pglobal_State;
begin
  gs := L^.l_G;
  lua_assert(isblack(o) and iswhite(v) and not isdead(gs, v) and not isdead(gs, o));
  if (keepinvariant(gs)) then //* must keep invariant? */
    reallymarkobject(gs, v)  //* restore invariant */
  else  //* sweep phase */
  begin
    lua_assert(issweepphase(gs));
    makewhite(gs, o);  //* mark main obj. as white to avoid other barriers */
  end;
end;

(*
** barrier that moves collector backward, that is, mark the black object
** pointing to a white object as gray again.
*)
procedure luaC_barrierback_(const L: Plua_State; const t: PTable);
var
  gs: Pglobal_State;
  o: PGCObject absolute t;
begin
  gs := L^.l_G;
  lua_assert(isblack(o) and not isdead(gs, o));
  black2gray(o);  //* make table gray (again) */
  linkgclist(t, gs^.grayagain);
end;

(*
** barrier for assignments to closed upvalues. Because upvalues are
** shared among closures, it is impossible to know the color of all
** closures pointing to it. So, we assume that the object being assigned
** must be marked.
*)
procedure luaC_upvalbarrier_(const L: Plua_State; const uv: PUpVal);
var
  gs: Pglobal_State;
  o: PGCObject;
begin
  gs := L^.l_G;
  o := gcvalue(uv^.v);
  lua_assert(not upisopen(uv));  //* ensured by macro luaC_upvalbarrier */
  if (keepinvariant(gs)) then
    markobject(gs, o);
end;

//#define luaC_barrier(L,p,v) (  \
//        (iscollectable(v) && isblack(p) && iswhite(gcvalue(v))) ?  \
//        luaC_barrier_(L,obj2gco(p),gcvalue(v)) : cast_void(0))
procedure luaC_barrier(const L: Plua_State; const p: PGCObject; const v: PTValue);
begin
  if iscollectable(v) and isblack(p) and iswhite(gcvalue(v)) then
    luaC_barrier_(L, p, gcvalue(v));
end;

//#define luaC_barrierback(L,p,v) (  \
//        (iscollectable(v) && isblack(p) && iswhite(gcvalue(v))) ? \
//        luaC_barrierback_(L,p) : cast_void(0))
procedure luaC_barrierback(const L: Plua_State; const p: PTable; const v: PTValue);
begin
  if iscollectable(v) and isblack(PGCObject(p)) and iswhite(gcvalue(v)) then
    luaC_barrierback_(L, p);
end;

//#define luaC_objbarrier(L,p,o) (  \
//        (isblack(p) && iswhite(o)) ? \
//        luaC_barrier_(L,obj2gco(p),obj2gco(o)) : cast_void(0))
procedure luaC_objbarrier(const L: Plua_State; const p, o: PGCObject);
begin
  if isblack(p) and iswhite(o) then
    luaC_barrier_(L, p, o);
end;

//#define luaC_upvalbarrier(L,uv) ( \
//        (iscollectable((uv)->v) && !upisopen(uv)) ? \
//         luaC_upvalbarrier_(L,uv) : cast_void(0))
procedure luaC_upvalbarrier(const L: Plua_State; const uv: PUpVal);
begin
  if iscollectable(uv^.v) and not upisopen(uv) then
    luaC_upvalbarrier_(L,uv);
end;

(*
** =======================================================
** Mark functions
** =======================================================
*)


(*
** mark an object. Userdata, strings, and closed upvalues are visited
** and turned black here. Other objects are marked gray and added
** to appropriate list to be visited (and turned black) later. (Open
** upvalues are already linked in 'headuv' list.)
*)
//static void reallymarkobject (global_State *g, GCObject *o)
procedure reallymarkobject(const g: Pglobal_State; o: PGCObject);
label reentry;
var
  uvalue: TValue;
begin
reentry:

  white2gray(o);
  case (o^.tt) of
    LUA_TSHRSTR: begin
      gray2black(o^);
      g^.GCmemtrav := g^.GCmemtrav + sizelstring(gco2ts(o)^.shrlen);
    end;
    LUA_TLNGSTR: begin
      gray2black(o^);
      g^.GCmemtrav += sizelstring(gco2ts(o)^.u_lnglen);
    end;
    LUA_TUSERDATA: begin
      markobjectN(g, gco2u(o)^.metatable);  //* mark its metatable */
      gray2black(o^);
      g^.GCmemtrav := g^.GCmemtrav + sizeudata(gco2u(o));
      getuservalue(g^.mainthread, gco2u(o), @uvalue);
      if (valiswhite(@uvalue)) then //* markvalue(g, &uvalue); */
      begin
        o := gcvalue(@uvalue);
        goto reentry;
      end;
    end;
    LUA_TLCL:
      linkgclist(gco2lcl(o), g^.gray);

    LUA_TCCL:
      linkgclist(gco2ccl(o), g^.gray);

    LUA_TTABLE:
      linkgclist(gco2t(o), g^.gray);

    LUA_TTHREAD:
      linkgclist(gco2th(o), g^.gray);

    LUA_TPROTO:
      linkgclist(gco2p(o), g^.gray);

    else lua_assert(0);
  end;

end;


(*
** mark metamethods for basic types
*)
//static void markmt (global_State *g)
procedure markmt(const g: Pglobal_State);
var
  i: Integer;
begin
  for i:=0 to LUA_NUMTAGS-1 do
    markobjectN(g, g^.mt[i]);
end;


(*
** mark all objects in list of being-finalized
*)
//static void markbeingfnz (global_State *g)
procedure markbeingfnz(const g: Pglobal_State);
var
  o: PGCObject;
begin
  o := g^.tobefnz;
  while (o <> Nil) do
  begin
    markobject(g, o);
    o := o^.next;
  end;
end;


(*
** Mark all values stored in marked open upvalues from non-marked threads.
** (Values from marked threads were already marked when traversing the
** thread.) Remove from the list threads that no longer have upvalues and
** not-marked threads.
*)
//static void remarkupvals (global_State *g)
procedure remarkupvals(const g: Pglobal_State);
var
  thread: Plua_State;
  p: PPlua_State;
  uv: PUpVal;
begin
  p := @g^.twups;
  while (p^ <> Nil) do
  begin
    thread := p^;
    lua_assert(not isblack(PGCObject(thread)));  //* threads are never black */
    if isgray(PGCObject(thread)) and (thread^.openupval <> Nil) then
      p := @thread^.twups  //* keep marked thread with upvalues in the list */
    else   //* thread is not marked or without upvalues */
    begin
      p^ := thread^.twups;  //* remove thread from the list */
      thread^.twups := thread;  //* mark that it is out of list */
      uv := thread^.openupval;
      while (uv <> Nil) do
      begin
        if (uv^.u_open_touched <> 0) then
        begin
          markvalue(g, uv^.v);  //* remark upvalue's value */
          uv^.u_open_touched := 0;
        end;
        uv := uv^.u_open_next;
      end;
    end;
  end;
end;


(*
** mark root set and reset all gray lists, to start a new collection
*)
//static void restartcollection (global_State *g)
procedure restartcollection(const g: Pglobal_State);
begin
  g^.gray := Nil;
  g^.grayagain := Nil;
  g^.weak := Nil;
  g^.allweak := Nil;
  g^.ephemeron := Nil;
  markobject(g, g^.mainthread);
  markvalue(g, @g^.l_registry);
  markmt(g);
  markbeingfnz(g);  //* mark any finalizing object left from previous cycle */
end;

(* ======================================================= *)


end;

procedure luaC_freeallobjects(const L: Plua_State);
begin

end;

procedure luaC_step(const L: Plua_State);
begin

end;

procedure luaC_runtilstate(const L: Plua_State; const statesmask: Integer);
begin

end;

procedure luaC_fullgc(const L: Plua_State; const isemergency: Integer);
begin

end;

function luaC_newobj(const L: Plua_State; const tt: Integer; const sz: SizeUInt): PGCObject;
begin

end;

procedure luaC_checkfinalizer(const L: Plua_State; const o: PGCObject; const mt: PTable);
begin

end;

procedure luaC_upvdeccount(const L: Plua_State; const uv: PUpVal);
begin

end;


end.

