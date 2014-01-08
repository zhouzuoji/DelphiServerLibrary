unit DSLMD5;

interface

uses
  SysUtils, Classes;

type
  UINT4 = LongWord;

  TArray4UINT4 = array [0..3] of UINT4;
  PArray4UINT4 = ^TArray4UINT4;

  TArray2UINT4 = array [0..1] of UINT4;
  PArray2UINT4 = ^TArray2UINT4;

  TArray16Byte = array [0..15] of Byte;
  PArray16Byte = ^TArray16Byte;

  TArray64Byte = array [0..63] of Byte;
  PArray64Byte = ^TArray64Byte;

  PByteArray = ^TByteArray;
  TByteArray = array [0..0] of Byte;

  TUINT4Array = array [0..0] of UINT4;
  PUINT4Array = ^TUINT4Array;
  
  TMD5Digest = record
    case Integer of
      0:(Dwords: array [0..3] of LongWord);
      1:(Bytes: array [0..15] of Byte);
    end;
  PMD5Digest = ^TMD5Digest;

  TMD5Context = record
   State: TArray4UINT4;
   Count: TArray2UINT4;
   buffer: TArray64Byte;
  end;
  PMD5Context = ^TMD5Context;

procedure MD5ContextInit(var context: TMD5Context);
procedure MD5Update(var context: TMD5Context; Input: PByteArray; InputLen: LongWord); overload;
procedure MD5Update(var context: TMD5Context; const s: RawByteString); overload;
procedure MD5Final(var context: TMD5Context; var digest: TMD5Digest);
procedure MD5Calc(const buffer; Size: Integer; out digest: TMD5Digest); overload;
function MD5Calc(const str: AnsiString; UpperCase: Boolean = True): AnsiString; overload;
function MD5Calc(const str: WideString; UpperCase: Boolean = True): AnsiString; overload;
function MD5String(const str: string; UpperCase: Boolean = True): AnsiString;
procedure MD5Stream(out digest: TMD5Digest; const stream: TStream; Len: Int64 = 0);
procedure MD5File(const FileName: string; out digest: TMD5Digest);

implementation

procedure MemHex(const buffer; Size: LongWord; Hex: PAnsiChar; UpperCase: Boolean = True); overload;
const
  HEXADECIMAL_CHARS: array [Boolean] of array [0..15] of AnsiChar =
    ( ('0', '1', '2', '3', '4', '5', '6', '7',
     '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'),
     ('0', '1', '2', '3', '4', '5', '6', '7',
     '8', '9', 'A', 'B', 'C', 'D', 'E', 'F') );
var
  i: LongWord;
begin
  for i := 0 to Size - 1 do
  begin
    Hex[2 * i] := HEXADECIMAL_CHARS[UpperCase][PByte(Pointer(LongWord(@buffer) + i))^ shr 4];
    Hex[2 * i + 1] := HEXADECIMAL_CHARS[UpperCase][PByte(Pointer(LongWord(@buffer) + i))^ and $0f];
  end;
end;

function MemHex(const buffer; Size: LongWord; UpperCase: Boolean = True): AnsiString; overload;
begin
  SetLength(Result, Size * 2);
  MemHex(buffer, Size, PAnsiChar(Result), UpperCase);
end;

procedure MD5ContextInit(var context: TMD5Context);
begin
  FillChar(context, SizeOf(context), 0);
  context.State[0] := $67452301;
  context.State[1] := $efcdab89;
  context.State[2] := $98badcfe;
  context.State[3] := $10325476;
end;

procedure MD5Transform(State: PArray4UINT4; buffer: PArray64Byte); forward;

procedure MD5Update(var context: TMD5Context; Input: PByteArray; InputLen: LongWord);
var
 i, Index, PartLen: LongWord;
begin
  Index := UINT4((context.Count[0] shr 3) and $3F);
  Inc(context.Count[0], UINT4(InputLen) shl 3);
  if context.Count[0] < UINT4(InputLen) shl 3 then Inc(context.Count[1]);
  Inc(context.Count[1], UINT4(InputLen) shr 29);
  PartLen := 64 - index;
  if InputLen >= PartLen then
  begin
    Move(Input^, context.buffer[Index], PartLen);
    MD5Transform(@context.State, @context.buffer);
    i := PartLen;
    while i + 63 < InputLen do
    begin
      MD5Transform(@context.State, PArray64Byte(@Input[i]));
      Inc(i, 64);
    end;
    Index := 0;
  end
  else i:=0;
  Move(Input[i], context.buffer[Index], InputLen - i);
end;

procedure MD5Update(var context: TMD5Context; const s: RawByteString);
begin
  MD5Update(context, PByteArray(Pointer(s)), Length(s));
end;

procedure MD5Encode(Output: PByteArray; Input: PUINT4Array; Len: LongWord); forward;

procedure MD5Final(var context: TMD5Context; var digest: TMD5Digest);
const
  PADDING: TArray64Byte = ($80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
var
  Bytes: array [0..7] of Byte;
  Index, PadLen: LongWord;
begin
  MD5Encode(PByteArray(@Bytes), PUINT4Array(@context.Count), 8);
  Index := LongWord((context.Count[0] shr 3) and $3F);
  if Index < 56 then PadLen := 56 - Index
  else PadLen := 120 - Index;
  MD5Update(context, PByteArray(@PADDING), PadLen);
  MD5Update(context, PByteArray(@Bytes), 8);
  MD5Encode(PByteArray(@digest), PUINT4Array(@context.State), 16);
  FillChar(context, SizeOf(context), 0);
end;

procedure MD5Calc(const buffer; Size: Integer; out digest: TMD5Digest);
var
  context: TMD5Context;
begin
  MD5ContextInit(context);
  MD5Update(context, PByteArray(@buffer), Size);
  MD5Final(context, digest);
end;

function MD5Calc(const str: AnsiString; UpperCase: Boolean = True): AnsiString;
var
  digest: TMD5Digest;
begin
  MD5Calc(Pointer(str)^, Length(str), digest);
  Result := MemHex(digest, SizeOf(digest), UpperCase);
end;

function MD5Calc(const str: WideString; UpperCase: Boolean = True): AnsiString;
var
  digest: TMD5Digest;
begin
  MD5Calc(Pointer(str)^, Length(str) * 2, digest);
  Result := MemHex(digest, SizeOf(digest), UpperCase);
end;

function MD5String(const str: string; UpperCase: Boolean = True): AnsiString;
var
  digest: TMD5Digest;
begin
  MD5Calc(Pointer(str)^, Length(str) * SizeOf(str[1]), digest);
  Result := MemHex(digest, SizeOf(digest), UpperCase);
end;

procedure MD5Stream(out digest: TMD5Digest; const stream: TStream; Len: Int64);
var
  context: TMD5Context;
  buffer: array [0..4095] of Byte;
  ReadBytes : Integer;
  Bookmark: Int64;
begin
  MD5ContextInit(context);
  Bookmark := stream.Position;
  if (Len <= 0) or (Len > stream.Size - Bookmark) then Len := stream.Size - Bookmark;
  try
    while Len > 0 do
    begin
      ReadBytes := SizeOf(buffer);
      if ReadBytes > Len then ReadBytes := Len;
      ReadBytes := stream.Read(buffer, ReadBytes);
      MD5Update(context, @buffer, ReadBytes);
      Dec(Len, ReadBytes);
    end;
    MD5Final(context, digest);
  finally
    stream.Position := Bookmark; 
  end;
end;

procedure MD5File(const FileName: string; out digest: TMD5Digest);
var
  stream: TFileStream;
begin
  stream := TFileStream.Create(FileName, fmOpenRead);
  try
    MD5Stream(digest, stream);
  finally
    stream.Free;
  end;
end;

function MD5_F(x, y, z: UINT4): UINT4;
begin
 Result :=(((x) and(y)) or((not x) and(z)));
end;

function MD5_G(x, y, z: UINT4): UINT4;
begin
 Result :=(((x) and(z)) or((y) and(not z)));
end;

function MD5_H(x, y, z: UINT4): UINT4;
begin
 Result :=((x) xor(y) xor(z));
end;

function MD5_I(x, y, z: UINT4): UINT4;
begin
 Result :=((y) xor((x) or( not z)));
end;

function MD5_ROTATE_LEFT(x, n: UINT4): UINT4;
begin
 Result :=(((x) shl(n)) or((x) shr(32-(n))));
end;

procedure MD5_FF(var a: UINT4; b, c, d, x, s, ac: UINT4);
begin
  a := a + MD5_F(b, c, d) + x + ac;
  a := MD5_ROTATE_LEFT(a, s);
  a := a + b;
end;

procedure MD5_GG(var a: UINT4; b, c, d, x, s, ac: UINT4);
begin
 a := a + MD5_G(b, c, d) + x + ac;
 a := MD5_ROTATE_LEFT(a, s);
 a := a + b;
end;

procedure MD5_HH(var a: UINT4; b, c, d, x, s, ac: UINT4);
begin
 a := a + MD5_H(b, c, d) + x + ac;
 a := MD5_ROTATE_LEFT(a, s);
 a := a + b;
end;

procedure MD5_II(var a: UINT4; b, c, d, x, s, ac: UINT4);
begin
 a := a + MD5_I(b, c, d) + x + ac;
 a := MD5_ROTATE_LEFT(a, s);
 a := a + b;
end;

procedure MD5Encode(Output: PByteArray; Input: PUINT4Array; Len: LongWord);
var
  i, j: LongWord;
begin
  j:=0;
  i:=0;
  while j < Len do
  begin
    Output[j] := Byte(Input[i] and $ff);
    Output[j+1] := Byte((Input[i] shr 8) and $ff);
    Output[j+2] := Byte((Input[i] shr 16) and $ff);
    Output[j+3] := Byte((Input[i] shr 24) and $ff);
    Inc(j, 4);
    Inc(i);
 end;
end;

procedure MD5Decode(Output: PUINT4Array; Input: PByteArray; Len: LongWord);
var
  i, j: LongWord;
begin
  j := 0;
  i := 0;
  while j < Len do
  begin
    Output[i] := UINT4(Input[j]) or(UINT4(Input[j+1]) shl 8) or
    (UINT4(Input[j+2]) shl 16) or( UINT4(Input[j+3]) shl 24);
    Inc(j, 4);
    Inc(i);
  end;
end;

procedure MD5Transform(State: PArray4UINT4; buffer: PArray64Byte);
const
  S11 = 7;
  S12 = 12;
  S13 = 17;
  S14 = 22;
  S21 = 5;
  S22 = 9;
  S23 = 14;
  S24 = 20;
  S31 = 4;
  S32 = 11;
  S33 = 16;
  S34 = 23;
  S41 = 6;
  S42 = 10;
  S43 = 15;
  S44 = 21;
var
  a, b, c, d: UINT4;
  x : array [0..15] of UINT4;
begin
  a := State[0];
  b := State[1];
  c := State[2];
  d := State[3];
  
  MD5Decode(PUINT4Array(@x), PByteArray(buffer), 64);

  MD5_FF(a, b, c, d, x[0], S11, $d76aa478);
  MD5_FF(d, a, b, c, x[1], S12, $e8c7b756);
  MD5_FF(c, d, a, b, x[2], S13, $242070db);
  MD5_FF(b, c, d, a, x[3], S14, $c1bdceee);
  MD5_FF(a, b, c, d, x[4], S11, $f57c0faf);
  MD5_FF(d, a, b, c, x[5], S12, $4787c62a);
  MD5_FF(c, d, a, b, x[6], S13, $a8304613);
  MD5_FF(b, c, d, a, x[7], S14, $fd469501);
  MD5_FF(a, b, c, d, x[8], S11, $698098d8);
  MD5_FF(d, a, b, c, x[9], S12, $8b44f7af);
  MD5_FF(c, d, a, b, x[10], S13, $FFFF5bb1);
  MD5_FF(b, c, d, a, x[11], S14, $895cd7be);
  MD5_FF(a, b, c, d, x[12], S11, $6b901122);
  MD5_FF(d, a, b, c, x[13], S12, $fd987193);
  MD5_FF(c, d, a, b, x[14], S13, $a679438e);
  MD5_FF(b, c, d, a, x[15], S14, $49b40821);

  MD5_GG(a, b, c, d, x[1], S21, $f61e2562);
  MD5_GG(d, a, b, c, x[6], S22, $c040b340);
  MD5_GG(c, d, a, b, x[11], S23, $265e5a51);
  MD5_GG(b, c, d, a, x[0], S24, $e9b6c7aa);
  MD5_GG(a, b, c, d, x[5], S21, $d62f105d);
  MD5_GG(d, a, b, c, x[10], S22,  $2441453);
  MD5_GG(c, d, a, b, x[15], S23, $d8a1e681);
  MD5_GG(b, c, d, a, x[4], S24, $e7d3fbc8);
  MD5_GG(a, b, c, d, x[9], S21, $21e1cde6);
  MD5_GG(d, a, b, c, x[14], S22, $c33707d6);
  MD5_GG(c, d, a, b, x[3], S23, $f4d50d87);

  MD5_GG(b, c, d, a, x[8], S24, $455a14ed);
  MD5_GG(a, b, c, d, x[13], S21, $a9e3e905);
  MD5_GG(d, a, b, c, x[2], S22, $fcefa3f8);
  MD5_GG(c, d, a, b, x[7], S23, $676f02d9);
  MD5_GG(b, c, d, a, x[12], S24, $8d2a4c8a);

  MD5_HH(a, b, c, d, x[5], S31, $fffa3942);
  MD5_HH(d, a, b, c, x[8], S32, $8771f681);
  MD5_HH(c, d, a, b, x[11], S33, $6d9d6122);
  MD5_HH(b, c, d, a, x[14], S34, $fde5380c);
  MD5_HH(a, b, c, d, x[1], S31, $a4beea44);
  MD5_HH(d, a, b, c, x[4], S32, $4bdecfa9);
  MD5_HH(c, d, a, b, x[7], S33, $f6bb4b60);
  MD5_HH(b, c, d, a, x[10], S34, $bebfbc70);
  MD5_HH(a, b, c, d, x[13], S31, $289b7ec6);
  MD5_HH(d, a, b, c, x[0], S32, $eaa127fa);
  MD5_HH(c, d, a, b, x[3], S33, $d4ef3085);
  MD5_HH(b, c, d, a, x[6], S34,  $4881d05);
  MD5_HH(a, b, c, d, x[9], S31, $d9d4d039);
  MD5_HH(d, a, b, c, x[12], S32, $e6db99e5);
  MD5_HH(c, d, a, b, x[15], S33, $1fa27cf8);
  MD5_HH(b, c, d, a, x[2], S34, $c4ac5665);

  MD5_II(a, b, c, d, x[0], S41, $f4292244);
  MD5_II(d, a, b, c, x[7], S42, $432aff97);
  MD5_II(c, d, a, b, x[14], S43, $ab9423a7);
  MD5_II(b, c, d, a, x[5], S44, $fc93a039);
  MD5_II(a, b, c, d, x[12], S41, $655b59c3);
  MD5_II(d, a, b, c, x[3], S42, $8f0ccc92);
  MD5_II(c, d, a, b, x[10], S43, $ffeff47d);
  MD5_II(b, c, d, a, x[1], S44, $85845dd1);
  MD5_II(a, b, c, d, x[8], S41, $6fa87e4f);
  MD5_II(d, a, b, c, x[15], S42, $fe2ce6e0);
  MD5_II(c, d, a, b, x[6], S43, $a3014314);
  MD5_II(b, c, d, a, x[13], S44, $4e0811a1);
  MD5_II(a, b, c, d, x[4], S41, $f7537e82);
  MD5_II(d, a, b, c, x[11], S42, $bd3af235);
  MD5_II(c, d, a, b, x[2], S43, $2ad7d2bb);
  MD5_II(b, c, d, a, x[9], S44, $eb86d391);

  Inc(State[0], a);
  Inc(State[1], b);
  Inc(State[2], c);
  Inc(State[3], d);

  FillChar(x, SizeOf(x), 0);
end;

end.
