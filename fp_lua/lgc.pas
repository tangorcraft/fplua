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

function issweepphase(const g: global_State): Boolean;

(*
** macro to tell when main invariant (white objects cannot point to black
** ones) must be kept. During a collection, the sweep
** phase may break the invariant, as objects turned white may point to
** still-black objects. The invariant is restored when sweep ends and
** all objects are white again.
*)
function keepinvariant(const g: global_State): Boolean;


function iswhite(const x: CommonHeader): Boolean;
function isblack(const x: CommonHeader): Boolean;
//* neither white nor black */
function isgray(const x: CommonHeader): Boolean;

function tofinalize(const x: CommonHeader): Boolean;

function otherwhite(const g: global_State): lu_byte;
function isdeadm(const ow, m: lu_byte): Boolean;
function isdead(const g: global_State; const v: CommonHeader): Boolean;

procedure changewhite(var x: CommonHeader);
procedure gray2black(var x: CommonHeader);

function luaC_white(const g: global_State): lu_byte;


(*
** Does one step of collection when debt becomes positive. 'pre'/'pos'
** allows some adjustments to be done only when needed. macro
** 'condchangemem' is used only for heavy tests (forcing a full
** GC cycle on every opportunity)
*)
//#define luaC_condGC(L,pre,pos) \
//        { if (G(L)->GCdebt > 0) { pre; luaC_step(L); pos;}; \
//          condchangemem(L,pre,pos); }
procedure luaC_condGC(var L: lua_State); // stub declaration, this macro need to be uwrapped

(* more often than not, 'pre'/'pos' are empty *)
procedure luaC_checkGC(var L: lua_State);

procedure luaC_barrier(var L: lua_State; const p: PGCObject; const v: TValuefields);

procedure luaC_barrierback(var L: lua_State; const p: PTable; const v: TValuefields);

procedure luaC_objbarrier(var L: lua_State; const p, o: PGCObject);

procedure luaC_upvalbarrier(var L: lua_State; const uv: PUpVal);

//TODO
procedure luaC_fix(var L: lua_State; const o: PGCObject);
procedure luaC_freeallobjects(var L: lua_State);
procedure luaC_step(var L: lua_State);
procedure luaC_runtilstate(var L: lua_State; const statesmask: Integer);
procedure luaC_fullgc(var L: lua_State; const isemergency: Integer);
function luaC_newobj(var L: lua_State; const tt: Integer; const sz: SizeUInt): PGCObject;
// these 3 don't need to be exposed in interface
//procedure luaC_barrier_(var L: lua_State; const o, v: PGCObject);
//procedure luaC_barrierback_(var L: lua_State; const o: PTable);
//procedure luaC_upvalbarrier_(var L: lua_State; const uv: PUpVal);
procedure luaC_checkfinalizer(var L: lua_State; const o: PGCObject; const mt: PTable);
procedure luaC_upvdeccount(var L: lua_State; const uv: PUpVal);

implementation

uses
  lobject, lfunc;

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
function issweepphase(const g: global_State): Boolean;
begin
  Result := (GCSswpallgc <= g.gcstate) and (g.gcstate <= GCSswpend);
end;

//#define keepinvariant(g)        ((g)->gcstate <= GCSatomic)
function keepinvariant(const g: global_State): Boolean;
begin
  Result := (g.gcstate <= GCSatomic);
end;

//#define iswhite(x)      testbits((x)->marked, WHITEBITS)
function iswhite(const x: CommonHeader): Boolean;
begin
  Result := (x.marked and WHITEBITS) <> 0;
end;

//#define isblack(x)      testbit((x)->marked, BLACKBIT)
function isblack(const x: CommonHeader): Boolean;
begin
  Result := (x.marked and bitmask_BLACKBIT) <> 0;
end;

//#define isgray(x)  /* neither white nor black */  \
//        (!testbits((x)->marked, WHITEBITS | bitmask(BLACKBIT)))
function isgray(const x: CommonHeader): Boolean;
begin
  Result := (x.marked and (WHITEBITS or bitmask_BLACKBIT)) = 0;
end;


//#define tofinalize(x)   testbit((x)->marked, FINALIZEDBIT)
function tofinalize(const x: CommonHeader): Boolean;
begin
  Result := (x.marked and bitmask_FINALIZEDBIT) <> 0;
end;

//#define otherwhite(g)   ((g)->currentwhite ^ WHITEBITS)
function otherwhite(const g: global_State): lu_byte;
begin
  Result := g.currentwhite xor WHITEBITS;
end;

//#define isdeadm(ow,m)   (!(((m) ^ WHITEBITS) & (ow)))
function isdeadm(const ow, m: lu_byte): Boolean;
begin
  Result := ( ( m xor WHITEBITS) and ow ) = 0;
end;

//#define isdead(g,v)     isdeadm(otherwhite(g), (v)->marked)
function isdead(const g: global_State; const v: CommonHeader): Boolean;
begin
  Result := ( ( v.marked xor WHITEBITS) and otherwhite(g) ) = 0;
end;

//#define changewhite(x)  ((x)->marked ^= WHITEBITS)
procedure changewhite(var x: CommonHeader);
begin
  x.marked := x.marked xor WHITEBITS;
end;

//#define gray2black(x)   l_setbit((x)->marked, BLACKBIT)
procedure gray2black(var x: CommonHeader);
begin
  x.marked := x.marked or bitmask_BLACKBIT;
end;

//#define luaC_white(g)   cast(lu_byte, (g)->currentwhite & WHITEBITS)
function luaC_white(const g: global_State): lu_byte;
begin
  Result := g.currentwhite and WHITEBITS;
end;

procedure luaC_condGC(var L: lua_State);
begin

end;

//#define luaC_checkGC(L)         luaC_condGC(L,(void)0,(void)0)
procedure luaC_checkGC(var L: lua_State);
begin
  if (L.l_G^.GCdebt > 0) then
    luaC_step(L);
  {$ifdef HARDMEMTESTS}
  //condchangemem(L);
  if (L.l_G^.gcrunning) then
    luaC_fullgc(L, 0);
  {$endif}
end;

procedure luaC_barrier_(var L: lua_State; const o, v: PGCObject);
begin

end;

procedure luaC_barrierback_(var L: lua_State; const o: PTable);
begin

end;

procedure luaC_upvalbarrier_(var L: lua_State; const uv: PUpVal);
begin

end;

//#define luaC_barrier(L,p,v) (  \
//        (iscollectable(v) && isblack(p) && iswhite(gcvalue(v))) ?  \
//        luaC_barrier_(L,obj2gco(p),gcvalue(v)) : cast_void(0))
procedure luaC_barrier(var L: lua_State; const p: PGCObject; const v: TValuefields);
begin
  if iscollectable(v) and isblack(p^.header) and iswhite(gcvalue(v)^.header) then
    luaC_barrier_(L, p, gcvalue(v));
end;

//#define luaC_barrierback(L,p,v) (  \
//        (iscollectable(v) && isblack(p) && iswhite(gcvalue(v))) ? \
//        luaC_barrierback_(L,p) : cast_void(0))
procedure luaC_barrierback(var L: lua_State; const p: PTable; const v: TValuefields);
begin
  if iscollectable(v) and isblack(p^.header) and iswhite(gcvalue(v)^.header) then
    luaC_barrierback_(L, p);
end;

//#define luaC_objbarrier(L,p,o) (  \
//        (isblack(p) && iswhite(o)) ? \
//        luaC_barrier_(L,obj2gco(p),obj2gco(o)) : cast_void(0))
procedure luaC_objbarrier(var L: lua_State; const p, o: PGCObject);
begin
  if isblack(p^.header) and iswhite(o^.header) then
    luaC_barrier_(L, p, o);
end;

//#define luaC_upvalbarrier(L,uv) ( \
//        (iscollectable((uv)->v) && !upisopen(uv)) ? \
//         luaC_upvalbarrier_(L,uv) : cast_void(0))
procedure luaC_upvalbarrier(var L: lua_State; const uv: PUpVal);
begin
  if iscollectable(uv^.v^.fields) and not upisopen(uv^) then
    luaC_upvalbarrier_(L,uv);
end;

procedure luaC_fix(var L: lua_State; const o: PGCObject);
begin

end;

procedure luaC_freeallobjects(var L: lua_State);
begin

end;

procedure luaC_step(var L: lua_State);
begin

end;

procedure luaC_runtilstate(var L: lua_State; const statesmask: Integer);
begin

end;

procedure luaC_fullgc(var L: lua_State; const isemergency: Integer);
begin

end;

function luaC_newobj(var L: lua_State; const tt: Integer; const sz: SizeUInt): PGCObject;
begin

end;

procedure luaC_checkfinalizer(var L: lua_State; const o: PGCObject; const mt: PTable);
begin

end;

procedure luaC_upvdeccount(var L: lua_State; const uv: PUpVal);
begin

end;


end.

