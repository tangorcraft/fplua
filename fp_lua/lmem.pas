unit lmem;
(*
** Interface to Memory Manager
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common;

(*
** This macro reallocs a vector 'b' from 'on' to 'n' elements, where
** each element has size 'e'. In case of arithmetic overflow of the
** product 'n'*'e', it raises an error (calling 'luaM_toobig'). Because
** 'e' is always constant, it avoids the runtime division MAX_SIZET/(e).
**
** (The macro is somewhat complex to avoid warnings:  The 'sizeof'
** comparison avoids a runtime comparison when overflow cannot occur.
** The compiler should be able to optimize the real test by itself, but
** when it does it, it may give a warning about "comparison is always
** false due to limited range of data type"; the +1 tricks the compiler,
** avoiding this warning but also this optimization.)
*)
function luaM_reallocv(var L: lua_State; const b: Pointer; const o_n, n: Integer; const e: SizeUInt): Pointer;

(*
** Arrays of chars do not need any test
*)
function luaM_reallocvchar(var L: lua_State; const b: Pointer; const o_n, n: Integer): PChar;

procedure luaM_freemem(var L: lua_State; const b: Pointer; const s: SizeUInt);
// TODO this macro need overloading to work for typed pointers
//procedure luaM_free(var L: lua_State; const b: Pointer);
// TODO this macro need overloading to work for typed pointers
//procedure luaM_freearray(var L: lua_State; const b: Pointer; const n: Integer);

// cannot pass type as parameter, since it is not a macro in pascal
// so sizeof(t) should be done at caller
function luaM_malloc(var L: lua_State; const s: SizeUInt): Pointer;
function luaM_new(var L: lua_State; const sizeof_t: SizeUInt): Pointer;
function luaM_newvector(var L: lua_State; const n: Integer; const sizeof_t: SizeUInt): Pointer;


function luaM_newobject(var L: lua_State; const tag: Integer; const s: SizeUInt): Pointer;

procedure luaM_growvector(var L: lua_State; var v: Pointer; const nelems: Integer;
  var size: Integer; const sizeof_t: SizeUInt; const limit: Integer; const e: PChar);

procedure luaM_reallocvector(var L: lua_State; var v: Pointer; const oldn, n: Integer;
  const sizeof_t: SizeUInt);

{ TODO
LUAI_FUNC l_noret luaM_toobig (lua_State *L);
}
procedure luaM_toobig(var L: lua_State);

(* not to be called directly *)
{ TODO
LUAI_FUNC void *luaM_realloc_ (lua_State *L, void *block, size_t oldsize,
                                                          size_t size);
LUAI_FUNC void *luaM_growaux_ (lua_State *L, void *block, int *size,
                               size_t size_elem, int limit,
                               const char *what);

function luaM_realloc_(var L: lua_State; const block: Pointer; const oldsize, size: SizeUInt): Pointer;
function luaM_growaux_(var L: lua_State; const block: Pointer; var size: Integer;
  const size_elem: SizeUInt; const limit: Integer; const what: PChar): Pointer;
}
implementation

function luaM_realloc_(var L: lua_State; const block: Pointer; const oldsize,
  size: SizeUInt): Pointer;
begin

end;

function luaM_growaux_(var L: lua_State; const block: Pointer; var size: Integer;
  const size_elem: SizeUInt; const limit: Integer; const what: PChar): Pointer;
begin

end;
(* not to be called directly END *)


//#define luaM_reallocv(L,b,on,n,e) \
//  (((sizeof(n) >= sizeof(size_t) && cast(size_t, (n)) + 1 > MAX_SIZET/(e)) \
//      ? luaM_toobig(L) : cast_void(0)) , \
//   luaM_realloc_(L, (b), (on)*(e), (n)*(e)))
function luaM_reallocv(var L: lua_State; const b: Pointer; const o_n, n: Integer;
  const e: SizeUInt): Pointer;
begin
  {$if SizeOf(Integer) >= SizeOf(SizeUInt)}
  // TODO optimization for constant e, see original comment about this macro in interface section
  if ((n + 1) > (MAX_SIZET / e)) then
  begin
    luaM_toobig(L);
    Exit(nil);
  end;
  {$endif}
  Result := luaM_realloc_(L, b, o_n*e, n*e);
end;

//#define luaM_reallocvchar(L,b,on,n)  \
//    cast(char *, luaM_realloc_(L, (b), (on)*sizeof(char), (n)*sizeof(char)))
function luaM_reallocvchar(var L: lua_State; const b: Pointer; const o_n, n: Integer): PChar;
begin
  Result := luaM_realloc_(L, b, o_n*sizeof(char), n*sizeof(char));
end;

//#define luaM_freemem(L, b, s)   luaM_realloc_(L, (b), (s), 0)
procedure luaM_freemem(var L: lua_State; const b: Pointer; const s: SizeUInt);
begin
  luaM_realloc_(L, b, s, 0);
end;

//#define luaM_free(L, b)         luaM_realloc_(L, (b), sizeof(*(b)), 0)
procedure luaM_free(var L: lua_State; const b: Pointer);
begin
  // TODO this macro need overloading to work for typed pointers
  luaM_realloc_(L, b, sizeof(b^), 0);
end;

//#define luaM_freearray(L, b, n)   luaM_realloc_(L, (b), (n)*sizeof(*(b)), 0)
procedure luaM_freearray(var L: lua_State; const b: Pointer; const n: Integer);
begin
  // TODO this macro need overloading to work for typed pointers
  luaM_realloc_(L, b, n*sizeof(b^), 0);
end;

//#define luaM_malloc(L,s)        luaM_realloc_(L, NULL, 0, (s))
function luaM_malloc(var L: lua_State; const s: SizeUInt): Pointer;
begin
  Result := luaM_realloc_(L, Nil, 0, s);
end;

//#define luaM_new(L,t)           cast(t *, luaM_malloc(L, sizeof(t)))
function luaM_new(var L: lua_State; const sizeof_t: SizeUInt): Pointer;
begin
  Result := luaM_realloc_(L, Nil, 0, sizeof_t);
end;

//#define luaM_newvector(L,n,t) \
//                cast(t *, luaM_reallocv(L, NULL, 0, n, sizeof(t)))
function luaM_newvector(var L: lua_State; const n: Integer; const sizeof_t: SizeUInt): Pointer;
begin
  Result := luaM_reallocv(L, nil, 0, n, sizeof_t);
end;

//#define luaM_newobject(L,tag,s) luaM_realloc_(L, NULL, tag, (s))
function luaM_newobject(var L: lua_State; const tag: Integer; const s: SizeUInt): Pointer;
begin
  Result := luaM_realloc_(L, nil, tag, s);
end;

//#define luaM_growvector(L,v,nelems,size,t,limit,e) \
//          if ((nelems)+1 > (size)) \
//            ((v)=cast(t *, luaM_growaux_(L,v,&(size),sizeof(t),limit,e)))
procedure luaM_growvector(var L: lua_State; var v: Pointer; const nelems: Integer;
  var size: Integer; const sizeof_t: SizeUInt; const limit: Integer; const e: PChar);
begin
  v := luaM_growaux_(L, v, size, sizeof_t, limit, e);
end;

//#define luaM_reallocvector(L, v,oldn,n,t) \
//   ((v)=cast(t *, luaM_reallocv(L, v, oldn, n, sizeof(t))))
procedure luaM_reallocvector(var L: lua_State; var v: Pointer; const oldn, n: Integer;
  const sizeof_t: SizeUInt);
begin
  v := luaM_reallocv(L, v, oldn, n, sizeof_t);
end;

procedure luaM_toobig(var L: lua_State);
begin

end;

end.

