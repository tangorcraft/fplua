unit fplua_sysutils;
(*
** OS specific untility functions (file I/O, etc)
** See Copyright Notice in fp_lua.pas
*)
{$i defines.inc}

interface

uses
  fplua_common, fplua_types;

const
  BUFSIZ = 8192;
  EOF = -1;

procedure memcpy(const dest, source: Pointer; const count: SizeUInt); inline;
function strerror(const err: integer): PChar;
function errno: Integer;

type
  fplua_Handle_Type = (ht_invalid, ht_file, ht_console, ht_pipe, ht_socket, ht_unk);
  fplua_FileRec = record
    h: THandle;
    htype: fplua_Handle_Type;
    last_err: Integer;
    index: Integer;
    flags: Cardinal;
  end;
  pFile = ^fplua_FileRec;

function pStdIn: pFile;
function pStdOut: pFile;
function pStdErr: pFile;

function getc(const f: pFile): Integer;
function fEof(const f: pFile): Boolean;
function fRead(const f: pFile; var Buf; const count: Integer): Integer;
function fopen(const fn, mode: PChar): pFile;
function freopen(const fn, mode: PChar; var f: pFile): pFile;
procedure fclose(var f: pFile);
function ferror(const f: pFile): Integer;

implementation

uses
  {$ifdef MSWINDOWS}Windows,{$endif}
  SysUtils;

procedure memcpy(const dest, source: Pointer; const count: SizeUInt);
begin
  Move(source^, dest^, count);
end;

{$ifdef FPC_HAS_FEATURE_THREADING}
ThreadVar
{$else FPC_HAS_FEATURE_THREADING}
Var
{$endif FPC_HAS_FEATURE_THREADING}
  last_error: String;
  fpStdIn, fpStdOut, fpStdErr: fplua_FileRec;

function strerror(const err: integer): PChar;
begin
  last_error := SysErrorMessage(err) + #0;
  Result := @last_error[1];
end;

function errno: Integer;
begin
  Result := GetLastOSError;
end;

const
  pFile_arr_step = 8;

  pFile_MODE_BINARY = $01;
  pFile_MODE_APPEND = $02;
  pFile_STD_HANDLE  = $04;

var
  pFile_list: array of pFile;
  pFile_list_CS: system.TRTLCriticalSection;
  pFile_count,
  pFile_capacity: Integer;

function HandleType(const h: THandle): fplua_Handle_Type;
begin
  {$ifdef MSWINDOWS}
  case GetFileType(h) of
    FILE_TYPE_UNKNOWN: begin
      if GetLastError = NO_ERROR then
        Exit(ht_unk)
      else
        Exit(ht_invalid);
    end;
    FILE_TYPE_DISK: Exit(ht_file);
    FILE_TYPE_CHAR: Exit(ht_console);
    FILE_TYPE_PIPE: Exit(ht_pipe);
  end;
  {$endif}
  Result := ht_invalid;
end;

function pStdIn: pFile;
begin
  fpStdIn.h := StdInputHandle;
  fpStdIn.htype := HandleType(fpStdIn.h);
  fpStdIn.last_err := 0;
  fpStdIn.flags := pFile_STD_HANDLE;
  Result := @fpStdIn;
end;

function pStdOut: pFile;
begin
  fpStdOut.h := StdOutputHandle;
  fpStdOut.htype := HandleType(fpStdIn.h);
  fpStdOut.last_err := 0;
  fpStdOut.flags := pFile_STD_HANDLE;
  Result := @fpStdOut;
end;

function pStdErr: pFile;
begin
  fpStdErr.h := StdErrorHandle;
  fpStdErr.htype := HandleType(fpStdIn.h);
  fpStdErr.last_err := 0;
  fpStdErr.flags := pFile_STD_HANDLE;
  Result := @fpStdErr;
end;

function getc(const f: pFile): Integer;
var
  c: Char;
begin
  if fEof(f) then
    Exit(EOF);
  Result := fread(f, c, sizeof(c));
  if Result = 0 then
    Exit(EOF);
  Result := ord(c);
end;

{$ifdef MSWINDOWS}
const
  kernel32 = 'kernel32.dll';
  advapi32 = 'advapi32.dll';
function SetFilePointerEx(hFile: HANDLE; liDistanceToMove: TLargeInteger;
  lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD): BOOL; stdcall; external kernel32 name 'SetFilePointerEx';
{$EXTERNALSYM SetFilePointerEx}
function GetFileSizeEx(hFile: HANDLE; var lpFileSize: TLargeInteger): BOOL; stdcall; external kernel32 name 'GetFileSizeEx';
{$EXTERNALSYM GetFileSizeEx}

function peek_file_eof(var f: fplua_FileRec): Boolean;
var
  curr, size: Int64;
begin
  if SetFilePointerEx(f.h, 0, @curr, FILE_CURRENT) and GetFileSizeEx(f.h, size) then
    Exit (curr >= size);
  f.last_err := GetLastError();
  Result := True;
end;

function peek_console_eof(var f: fplua_FileRec): Boolean;
var
  nr: DWORD;
  ir: INPUT_RECORD;
begin
  while PeekConsoleInput(f.h, ir, 1, nr) do
  begin
    if nr = 0 then
      Exit(True);
    if ir.EventType = KEY_EVENT then
      Exit(False)
    else
      ReadConsoleInput(f.h, ir, 1, nr); // discard non-key events
  end;
  f.last_err := GetLastError();
  Result := True;
end;

function peek_pipe_eof(var f: fplua_FileRec): Boolean;
var
  total: DWORD;
begin
  if PeekNamedPipe(f.h, nil, 0, nil, @total, nil) then
    Exit(total = 0);
  f.last_err := GetLastError();
  Result := True;
end;
{$endif MSWINDOWS}

function fEof(const f: pFile): Boolean;
begin
  {$ifdef MSWINDOWS}
  case f^.htype of
    ht_file: Result := peek_file_eof(f^);
    ht_console: Result := peek_console_eof(f^);
    ht_pipe: Result := peek_pipe_eof(f^);
    else
      Result := True;
  end;
  {$endif}
end;

function fRead(const f: pFile; var Buf; const count: Integer): Integer;
{$ifdef MSWINDOWS}
var
  nr: DWORD;
{$endif}
begin
  {$ifdef MSWINDOWS}
  if f^.last_err <> 0 then
    Exit(0);
  if ReadFile(f^.h, Buf, count, nr, nil) then
  begin
    if nr > 0 then
      f^.last_err := 0
    else // readfile return true but bytes read = 0 means EOF
      f^.last_err := ERROR_HANDLE_EOF;
    Result := nr;
  end
  else
  begin
    Result := 0;
    f^.last_err := GetLastError();
  end;
  {$endif}
end;

procedure pfile_lock();
begin
  system.EnterCriticalSection(pFile_list_CS);
end;

procedure pfile_unlock();
begin
  system.LeaveCriticalSection(pFile_list_CS);
end;

function new_pfile(): pFile;
begin
  pfile_lock();
  New(Result);
  if Result <> nil then
  begin
    if pFile_capacity <= (pFile_count + 1) then
    begin
      inc(pFile_capacity, pFile_arr_step);
      SetLength(pFile_list, pFile_capacity);
    end;
    Result^.h := feInvalidHandle;
    Result^.htype := ht_invalid;
    Result^.last_err := 0;
    Result^.index := pFile_count;
    Result^.flags := 0;
    pFile_list[pFile_count] := Result;
    inc(pFile_count);
  end;
  pfile_unlock();
end;

function find_pfile_index(const f: pFile): Integer;
var
  i: Integer;
begin
  for i := 0 to pFile_count - 1 do
    if pFile_list[i] = f then
      Exit(i);
  Result := -1;
end;

procedure dispose_pfile(var f: pFile);
var
  idx: Integer;
begin
  pfile_lock();
  idx := f^.index;
  if (idx >= pFile_count) or (pFile_list[idx] <> f) then // should never happen, but check anyway
    idx := find_pfile_index(f);
  if idx <> -1 then
  begin
    dec(pFile_count);
    if idx <> pFile_count then // move last entry to idx
    begin
      pFile_list[idx] := pFile_list[pFile_count];
      pFile_list[idx]^.index := idx;
    end;
  end;
  pfile_unlock();
  Dispose(f);
  f := nil;
end;

function fopen(const fn, mode: PChar): pFile;
var
  {$ifdef MSWINDOWS}
  h: HANDLE;
  acc, disp: DWORD;
  {$endif}
  flags: Cardinal;
begin
  if mode = nil then
    exit(nil);
  {$ifdef MSWINDOWS}
  case mode[0] of
    'r','R':begin
      acc := GENERIC_READ;
      disp := OPEN_EXISTING;
      flags := 0;
    end;
    'w','W':begin
      acc := GENERIC_WRITE;
      disp := CREATE_ALWAYS;
      flags := 0;
    end;
    'a','A':begin
      acc := GENERIC_WRITE;
      disp := OPEN_ALWAYS;
      flags := pFile_MODE_APPEND;
      // TODO implement append behavior
    end;
    else exit(nil);
  end;
  if mode[1] = '+' then
    acc := GENERIC_READ or GENERIC_WRITE;
  if (mode[1] = 'b') or ((mode[1] <> #0) and (mode[2]='b')) then
    flags := flags or pFile_MODE_BINARY;
    // TODO implement text mode behavior

  h := CreateFile(fn, acc, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, disp, FILE_ATTRIBUTE_NORMAL, 0);
  if h <> INVALID_HANDLE_VALUE then
  begin
    Result := new_pfile();
    Result^.h := h;
    Result^.htype := HandleType(h);
    Result^.flags := flags;
  end
  else
    Result := nil;
  {$endif}
end;

function freopen(const fn, mode: PChar; var f: pFile): pFile;
begin
  // TODO in-place reopen; std handle redirects
  fclose(f);
  f := fopen(fn, mode);
  Result := f;
end;

procedure fclose(var f: pFile);
begin
  if (f^.flags and pFile_STD_HANDLE) <> 0 then
  begin // do not close/dispose stdin/out/err handles
    f := nil;
    Exit;
  end;
  {$ifdef MSWINDOWS}
  CloseHandle(f^.h);
  {$endif}
  dispose_pfile(f);
end;

function ferror(const f: pFile): Integer;
begin
  Result := f^.last_err;
end;

initialization
  pFile_count := 0;
  pFile_capacity := pFile_arr_step;
  SetLength(pFile_list, pFile_count);
  InitCriticalSection(pFile_list_CS);
finalization
  DoneCriticalSection(pFile_list_CS);
  while pFile_count > 0 do
  begin
    Dec(pFile_count);
    Dispose(pFile_list[pFile_count]);
  end;
end.

