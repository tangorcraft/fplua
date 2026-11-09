unit lzio;
(*
** Buffered streams
** See Copyright Notice in lua.h
*)
{$i defines.inc}

interface

uses
  fplua_types, fplua_common;

const
  EOZ    = (-1);     //* end of stream */

type
  PZio = ^Zio;
  Zio = record
    n: SizeUInt;             //* bytes still unread */
    p: PChar;                //* current position in buffer */
    reader: lua_Reader;      //* reader function */
    data: Pointer;           //* additional data */
    L: Plua_State;           //* Lua state (for reader) */
  end;

function zgetc(var z: Zio): lu_int;

type
  PMbuffer = ^Mbuffer;
  Mbuffer = record
    buffer: PChar;
    n: SizeUInt;
    buffsize: SizeUInt;
  end;

procedure luaZ_initbuffer(const L: Plua_State; const buff: PMbuffer);

function luaZ_buffer(const buff: PMbuffer): PChar;
function luaZ_sizebuffer(const buff: PMbuffer): SizeUInt;
function luaZ_bufflen(const buff: PMbuffer): SizeUInt;

procedure luaZ_buffremove(const buff: PMbuffer; const i: SizeUInt);
procedure luaZ_resetbuffer(const buff: PMbuffer);


procedure luaZ_resizebuffer(var L: lua_State; var buff: Mbuffer; const size: SizeUInt);

procedure luaZ_freebuffer(var L: lua_State; var buff: Mbuffer);


{  TODO
LUAI_FUNC void luaZ_init (lua_State *L, ZIO *z, lua_Reader reader,
                                        void *data);
LUAI_FUNC size_t luaZ_read (ZIO* z, void *b, size_t n); /* read next n bytes */
}
procedure luaZ_init(var L: lua_State; var z: Zio; const reader: lua_Reader; const data: Pointer);
function luaZ_read(var z: Zio; const b: Pointer; const n: SizeUInt): SizeUInt;

//* --------- Private Part ------------------ */

{ TODO
LUAI_FUNC int luaZ_fill (ZIO *z);
}
function luaZ_fill(var z: Zio): Integer;

implementation

uses
  lmem;

//#define zgetc(z)  (((z)->n--)>0 ?  cast_uchar(*(z)->p++) : luaZ_fill(z))
function zgetc(var z: Zio): lu_int;
begin
  if z.n > 0 then
  begin
    dec(z.n);
    Result := PByte(z.p)^;
    inc(z.p);
  end
  else
  begin
    dec(z.n);
    Result := luaZ_fill(z);
  end;
end;

//#define luaZ_initbuffer(L, buff) ((buff)->buffer = NULL, (buff)->buffsize = 0)
procedure luaZ_initbuffer(const L: Plua_State; const buff: PMbuffer);
begin
  buff^.buffer := nil;
  buff^.buffsize := 0;
end;

//#define luaZ_buffer(buff)       ((buff)->buffer)
function luaZ_buffer(const buff: PMbuffer): PChar;
begin
  Result := buff^.buffer;
end;

//#define luaZ_sizebuffer(buff)   ((buff)->buffsize)
function luaZ_sizebuffer(const buff: PMbuffer): SizeUInt;
begin
  Result := buff^.buffsize;
end;

//#define luaZ_bufflen(buff)      ((buff)->n)
function luaZ_bufflen(const buff: PMbuffer): SizeUInt;
begin
  Result := buff^.n;
end;

//#define luaZ_buffremove(buff,i) ((buff)->n -= (i))
procedure luaZ_buffremove(const buff: PMbuffer; const i: SizeUInt);
begin
  buff^.n -= i;
  //Result := buff^.n;
end;

//#define luaZ_resetbuffer(buff) ((buff)->n = 0)
procedure luaZ_resetbuffer(const buff: PMbuffer);
begin
  buff^.n := 0;
end;

//#define luaZ_resizebuffer(L, buff, size) \
//        ((buff)->buffer = luaM_reallocvchar(L, (buff)->buffer, \
//                                (buff)->buffsize, size), \
//        (buff)->buffsize = size)
procedure luaZ_resizebuffer(var L: lua_State; var buff: Mbuffer; const size: SizeUInt);
begin
  buff.buffer := luaM_reallocvchar(L, buff.buffer, buff.buffsize, size);
  buff.buffsize := size;
end;

//#define luaZ_freebuffer(L, buff)        luaZ_resizebuffer(L, buff, 0)
procedure luaZ_freebuffer(var L: lua_State; var buff: Mbuffer);
begin
  luaZ_resizebuffer(L, buff, 0);
end;

procedure luaZ_init(var L: lua_State; var z: Zio; const reader: lua_Reader;
  const data: Pointer);
begin

end;

function luaZ_read(var z: Zio; const b: Pointer; const n: SizeUInt): SizeUInt;
begin

end;

function luaZ_fill(var z: Zio): Integer;
begin

end;

end.

