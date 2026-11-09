(*
** See Copyright Notice in fp_lua.pas
*)

{$ifdef FPLUA_FLOAT_SINGLE}
  {$ifdef FPLUA_FLOAT_DOUBLE}
    {$warning FPLUA_FLOAT_SINGLE is defined, FPLUA_FLOAT_DOUBLE is ignored}
    {$undef FPLUA_FLOAT_DOUBLE}
  {$endif double}
  {$ifdef FPLUA_FLOAT_EXTENDED}
    {$warning FPLUA_FLOAT_SINGLE is defined, FPLUA_FLOAT_EXTENDED is ignored}
    {$undef FPLUA_FLOAT_EXTENDED}
  {$endif extended}
{$else}{$ifdef FPLUA_FLOAT_DOUBLE}
  {$ifdef FPLUA_FLOAT_EXTENDED}
    {$warning FPLUA_FLOAT_DOUBLE is defined, FPLUA_FLOAT_EXTENDED is ignored}
    {$undef FPLUA_FLOAT_EXTENDED}
  {$endif extended}
{$else}{$ifndef FPLUA_FLOAT_EXTENDED} // none of the types are defined

  {$ifdef FPLUA_32BITS}
    {$define FPLUA_FLOAT_SINGLE}
  {$else}
    {$define FPLUA_FLOAT_DOUBLE}
  {$endif 32bits}

  {$else}
  {$ifndef SUPPORT_EXTENDED}
    {$warning Extended type is not supported and defined as double or single}
  {$endif not SUPPORT_EXTENDED}
  {$endif not FPLUA_FLOAT_EXTENDED}
{$endif double}
{$endif single}

{$ifdef FPLUA_INT_16BIT}
  {$error Not implemented}
{$else}{$ifdef FPLUA_INT_32BIT}
  {$ifdef FPLUA_INT_64BIT}
    {$warning FPLUA_INT_32BIT is defined, FPLUA_INT_64BIT is ignored}
    {$undef FPLUA_INT_64BIT}
  {$endif extended}
{$else}{$ifndef FPLUA_INT_64BIT} // none of the types are defined
  {$ifdef FPLUA_32BITS}
    {$define FPLUA_INT_32BIT}
  {$else}
    {$define FPLUA_INT_64BIT}
  {$endif 32bits}
  {$endif not FPLUA_INT_64BIT}
{$endif 32}
{$endif 16}

