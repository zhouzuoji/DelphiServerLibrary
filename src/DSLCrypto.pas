unit DSLCrypto;

{$POINTERMATH ON}
interface

uses
  SysUtils, Classes, DSLUtils;

{$REGION 'crc32 interface'}

procedure CRC32_Update(buf: Pointer; Size: Integer; var crc: LongWord);
function CRC32(buf: Pointer; Size: Integer): LongWord; overload;
function CRC32(const str: RawByteString): LongWord; overload;
function CRC32(Stream: TStream; len: Int64 = 0): LongWord; overload;
function CRC32File(const FileName: string): LongWord;

{$ENDREGION}
{$REGION 'base64 interface'}

type
  EBase64DecodeError = class(Exception);

const
  BASE64_ALPHABETS_STD = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

function Base64DecodeResultLen(input: Pointer; InputSize: Integer): Integer;
function Base64Encode(input: Pointer; InputSize: Integer; output: Pointer;
  const CharTable: RawByteString = BASE64_ALPHABETS_STD): Integer; overload;
function Base64Encode(input: Pointer; InputSize: Integer): RawByteString; overload;
function Base64Encode(const input: RawByteString; const CharTable: RawByteString = BASE64_ALPHABETS_STD): RawByteString; overload;
function Base64Decode(input: Pointer; InputSize: Integer; output: Pointer;
  const CharTable: RawByteString = BASE64_ALPHABETS_STD): Integer; overload;
function Base64Decode(const input: RawByteString; output: Pointer): Integer; overload;
function Base64Decode(const input: RawByteString): RawByteString; overload;

{$ENDREGION}

{$REGION 'base58 interface'}
type
  EBase58DecodeError = class(Exception);
const
  BASE58_ALPHABETS_BITCOIN = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
function Base58Encode(input: Pointer; InputSize: Integer; output: PAnsiChar;
  const CharTable: RawByteString = BASE58_ALPHABETS_BITCOIN): PAnsiChar; overload;
function Base58Encode(input: Pointer; InputSize: Integer;
  const CharTable: RawByteString = BASE58_ALPHABETS_BITCOIN): RawByteString; overload;
function Base58Decode(input: PAnsiChar; InputSize: Integer; output: PByte;
  const CharTable: RawByteString = BASE58_ALPHABETS_BITCOIN): PByte; overload;
function Base58Decode(const input: RawByteString; output: PByte;
  const CharTable: RawByteString = BASE58_ALPHABETS_BITCOIN): PByte; overload;
function Base58Decode(const input: RawByteString;
  const CharTable: RawByteString = BASE58_ALPHABETS_BITCOIN): RawByteString; overload;
{$ENDREGION}

{$REGION 'md5 interface'}

type
  TMD5Digest = T128BitBuf;
  PMD5Digest = ^TMD5Digest;

  TMD5Context = record
    digest: TMD5Digest;
    BufLen: Integer;
    TotalLen: Int64;
    buffer: T512BitBuf;
    procedure init;
    procedure update(const buf; BufSize: Integer); overload;
    procedure update(const str: RawByteString); overload;
    procedure finish;
  end;

  PMD5Context = ^TMD5Context;

function MD5(const buffer; Size: Integer): TMD5Digest; overload;
function MD5(const data: RawByteString): TMD5Digest; overload;
function MD5CalcRBStr(const str: RawByteString; UpperCase: Boolean = True): RawByteString;
function MD5CalcBStr(const str: WideString; UpperCase: Boolean = True): RawByteString;
function MD5CalcUStr(const str: UnicodeString; UpperCase: Boolean = True): RawByteString;
function MD5String(const str: string; UpperCase: Boolean = True): RawByteString;
function MD5Stream(const Stream: TStream; len: Int64 = 0): TMD5Digest;
function MD5File(const FileName: string): TMD5Digest;

{$ENDREGION}
{$REGION 'hmac_md5 interface'}

type
  THMAC_MD5Context = record
    hashctx: TMD5Context;
    keyBlock: T512BitBuf;
    procedure init(const key; const keyLen: Integer);
    procedure reset;
    procedure update(const buf; BufLen: Integer); overload;
    procedure update(const buf: RawByteString); overload;
    function finish: TMD5Digest;
  end;

  PHMAC_MD5Context = ^THMAC_MD5Context;

function HMAC_MD5(const key; keyLen: Integer; const buf; BufLen: Integer): TMD5Digest; overload;
function HMAC_MD5(const key, data: RawByteString): TMD5Digest; overload;

{$ENDREGION}
{$REGION 'sha1 interface'}

type
  TSHA1Digest = T160BitBuf;

  TSHA1Context = record
    digest: TSHA1Digest;
    BufLen: Integer;
    TotalLen: Int64;
    buffer: T512BitBuf;
    procedure init;
    procedure update(const buf; BufSize: Integer);
    procedure finish;
  end;

  PSHA1Context = ^TSHA1Context;

function SHA1(const buf; BufSize: Integer): TSHA1Digest;
overload function SHA1(const str: RawByteString): TSHA1Digest;
overload;
function SHA1Stream(const Stream: TStream; len: Int64 = 0): TSHA1Digest;
function SHA1File(const FileName: string): TSHA1Digest;

{$ENDREGION}
{$REGION 'hmac_sha1 interface'}

type
  THMAC_SHA1Context = record
    hashctx: TSHA1Context;
    keyBlock: T512BitBuf;
    procedure init(const key; const keyLen: Integer);
    procedure reset;
    procedure update(const buf; BufLen: Integer);
    function finish: TSHA1Digest;
  end;

  PHMAC_SHA1Context = ^THMAC_SHA1Context;

function HMAC_SHA1(const key; keyLen: Integer; const buf; BufLen: Integer): TSHA1Digest; overload;
function HMAC_SHA1(const key, data: RawByteString): TSHA1Digest; overload;

{$ENDREGION}
{$REGION 'sha256 interface'}

type
  TSHA256Digest = T256BitBuf;

  TSHA256Context = record
    digest: TSHA256Digest;
    BufLen: Integer;
    TotalLen: Int64;
    buffer: T512BitBuf;
    procedure init;
    procedure update(const buf; BufSize: Integer);
    procedure finish;
  end;

  PSHA256Context = ^TSHA256Context;

function SHA256(const buf; BufSize: Integer): TSHA256Digest; overload;
function SHA256(const str: RawByteString): TSHA256Digest; overload;
function SHA256Stream(const Stream: TStream; len: Int64 = 0): TSHA256Digest;
function SHA256File(const FileName: string): TSHA256Digest;

{$ENDREGION}
{$REGION 'hmac_sha256 interface'}

type
  THMAC_SHA256Context = record
    hashctx: TSHA256Context;
    keyBlock: T512BitBuf;
    procedure init(const key; const keyLen: Integer);
    procedure reset;
    procedure update(const buf; BufSize: Integer);
    function finish: TSHA256Digest;
  end;

  PHMAC_SHA256Context = ^THMAC_SHA256Context;

function HMAC_SHA256(const key; keyLen: Integer; const buf; BufSize: Integer): TSHA256Digest; overload;
function HMAC_SHA256(const key, data: RawByteString): TSHA256Digest; overload;

{$ENDREGION}
{$REGION 'sha224 interface'}

type
  TSHA224Digest = T224BitBuf;

  TSHA224Context = record
    _256: TSHA256Context;
    digest: TSHA224Digest;
    procedure init;
    procedure update(const buf; BufSize: Integer);
    procedure finish;
  end;

  PSHA224Context = ^TSHA224Context;

function SHA224(const buf; BufSize: Integer): TSHA224Digest; overload;
function SHA224(const str: RawByteString): TSHA224Digest; overload;
function SHA224Stream(const Stream: TStream; len: Int64 = 0): TSHA224Digest;
function SHA224File(const FileName: string): TSHA224Digest;

{$ENDREGION}
{$REGION 'sha512 interface'}

type
  TSHA512Digest = T512BitBuf;

  TSHA512Context = record
    digest: TSHA512Digest;
    BufLen: Integer;
    TotalLen: Int64;
    buffer: T1024BitBuf;
    procedure init;
    procedure update(const buf; BufSize: Integer);
    procedure finish;
  end;

  PSHA512Context = ^TSHA512Context;

function SHA512(const buf; BufSize: Integer): TSHA512Digest; overload;
function SHA512(const str: RawByteString): TSHA512Digest; overload;
function SHA512Stream(const Stream: TStream; len: Int64 = 0): TSHA512Digest;
function SHA512File(const FileName: string): TSHA512Digest;

{$ENDREGION}
{$REGION 'hmac_sha256 interface'}

type
  THMAC_SHA512Context = record
    hashctx: TSHA512Context;
    keyBlock: T1024BitBuf;
    procedure init(const key; const keyLen: Integer);
    procedure reset;
    procedure update(const buf; BufSize: Integer);
    function finish: TSHA512Digest;
  end;

  PHMAC_SHA512Context = ^THMAC_SHA512Context;

function HMAC_SHA512(const key; keyLen: Integer; const buf; BufSize: Integer): TSHA512Digest; overload;
function HMAC_SHA512(const key, data: RawByteString): TSHA512Digest; overload;

{$ENDREGION}
{$REGION 'sha384 interface'}

type
  TSHA384Digest = T384BitBuf;

  TSHA384Context = record
    _512: TSHA512Context;
    digest: TSHA384Digest;
    procedure init;
    procedure update(const buf; BufSize: Integer);
    procedure finish;
  end;

  PSHA384Context = ^TSHA384Context;

function SHA384(const buf; BufSize: Integer): TSHA384Digest; overload;
function SHA384(const str: RawByteString): TSHA384Digest; overload;
function SHA384Stream(const Stream: TStream; len: Int64 = 0): TSHA384Digest;
function SHA384File(const FileName: string): TSHA384Digest;

{$ENDREGION}

implementation

procedure xor_32bit_array(const src; var dst; v: UInt32; num: Integer); inline;
var
  i: Integer;
  psrc, pdst: PUInt32;
begin
  psrc := PUInt32(@src);
  pdst := PUInt32(@dst);
  for i := 1 to num do
  begin
    pdst^ := psrc^ xor v;
    Inc(psrc);
    Inc(pdst);
  end;
end;

{$REGION 'crc32 implementation'}

var
  CRC32_TABLE: array [0 .. 255] of LongWord;

procedure CRC32_Update(buf: Pointer; Size: Integer; var crc: LongWord);
var
  i, j: Integer;
  b: LongWord;
begin
  for i := 0 to Size - 1 do
  begin
    j := Byte(crc xor Ord(PChar(buf)[i]));
    b := CRC32_TABLE[j];
    crc := b xor (crc shr 8) and $FFFFFF;
  end;
end;

function CRC32(buf: Pointer; Size: Integer): LongWord;
begin
  Result := $FFFFFFFF;
  CRC32_Update(buf, Size, Result);
  Result := not Result;
end;

function CRC32(const str: RawByteString): LongWord;
begin
  Result := CRC32(Pointer(str), Length(str));
end;

function CRC32(Stream: TStream; len: Int64): LongWord;
var
  buf: array [0 .. 255] of Byte;
  BufLen: Integer;
begin
  Result := $FFFFFFFF;
  if Stream is TMemoryStream then
  begin
    BufLen := Stream.Size - Stream.Position;
    if (len <= 0) or (len > BufLen) then
      len := BufLen;
    CRC32_Update(Pointer(LongInt(TMemoryStream(Stream).Memory) + Stream.Position), len, Result);
  end
  else
  begin
    if (len <= 0) or (len > Stream.Size - Stream.Position) then
      len := Stream.Size - Stream.Position;
    while len > 0 do
    begin
      if len < SizeOf(buf) then
        BufLen := len
      else
        BufLen := SizeOf(buf);
      BufLen := Stream.Read(buf, BufLen);
      CRC32_Update(@buf, BufLen, Result);
      Dec(len, BufLen);
    end;
  end;
  Result := not Result;
end;

function CRC32File(const FileName: string): LongWord;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := CRC32(Stream);
  finally
    Stream.Free;
  end;
end;

procedure CRC32_InitTable;
var
  crc, i, j: LongWord;
begin
  for i := 0 to 255 do
  begin
    crc := i;
    for j := 0 to 7 do
    begin
      if crc and 1 = 1 then
        crc := (crc shr 1) xor $EDB88320
      else
        crc := crc shr 1;
    end;
    CRC32_TABLE[i] := crc;
  end;
end;

{$ENDREGION}
{$REGION 'md5 implementation'}

procedure MD5Transform(var digest; const buffer); forward;

{ TMD5Context }

procedure TMD5Context.finish;
var
  _totalLen: Int64;
begin
  _totalLen := Self.TotalLen * 8;

  Self.buffer.bytes[Self.BufLen] := $80;
  Inc(Self.BufLen);

  if Self.BufLen <= 56 then
  begin
    FillChar(Self.buffer.bytes[Self.BufLen], 56 - Self.BufLen, 0);
    Move(_totalLen, Self.buffer.bytes[56], 8);
    MD5Transform(Self.digest, Self.buffer);
  end
  else
  begin
    FillChar(Self.buffer.bytes[Self.BufLen], 64 - Self.BufLen, 0);
    MD5Transform(Self.digest, Self.buffer);

    Self.buffer.qwords[0].value := 0;
    Self.buffer.qwords[1].value := 0;
    Self.buffer.qwords[2].value := 0;
    Self.buffer.qwords[3].value := 0;
    Self.buffer.qwords[4].value := 0;
    Self.buffer.qwords[5].value := 0;
    Self.buffer.qwords[6].value := 0;
    Self.buffer.qwords[7].value := _totalLen;

    MD5Transform(Self.digest, Self.buffer);
  end;
end;

procedure TMD5Context.init;
begin
  digest.dwords[0].value := $67452301;
  digest.dwords[1].value := $EFCDAB89;
  digest.dwords[2].value := $98BADCFE;
  digest.dwords[3].value := $10325476;
  BufLen := 0;
  TotalLen := 0;
end;

procedure TMD5Context.update(const str: RawByteString);
begin
  Self.update(Pointer(str)^, Length(str));
end;

procedure TMD5Context.update(const buf; BufSize: Integer);
var
  P: PByte;
  i, j, M: Integer;
begin
  if BufSize <= 0 then
    Exit;
  Inc(Self.TotalLen, BufSize);
  P := PByte(@buf);

  if Self.BufLen > 0 then
  begin
    M := 64 - Self.BufLen;
    if M > BufSize then
    begin
      Move(P^, Self.buffer.bytes[Self.BufLen], BufSize);
      Inc(Self.BufLen, BufSize);
      Exit;
    end
    else
    begin
      Move(P^, Self.buffer.bytes[Self.BufLen], M);
      MD5Transform(Self.digest, Self.buffer);
      Self.BufLen := 0;
      Inc(P, M);
      Dec(BufSize, M);
      if BufSize = 0 then
        Exit;
    end;
  end;

  j := BufSize shr 6; // BufSize div 64;

  for i := 1 to j do
  begin
    MD5Transform(Self.digest, P^);
    Inc(P, 64);
  end;

  j := BufSize and $3F; // BufSize mod 64

  if j <> 0 then
  begin
    Move(P^, Self.buffer, j);
    Self.BufLen := j;
  end;
end;

function MD5(const buffer; Size: Integer): TMD5Digest;
var
  context: TMD5Context;
begin
  context.init;
  context.update(buffer, Size);
  context.finish;
  Result := context.digest;
end;

function MD5(const data: RawByteString): TMD5Digest;
var
  context: TMD5Context;
begin
  context.init;
  context.update(Pointer(data)^, Length(data));
  context.finish;
  Result := context.digest;
end;

function MD5CalcRBStr(const str: RawByteString; UpperCase: Boolean = True): RawByteString;
var
  context: TMD5Context;
begin
  context.init;
  context.update(Pointer(str)^, Length(str));
  context.finish;
  Result := MemHex(context.digest, SizeOf(context.digest), UpperCase);
end;

function MD5CalcBStr(const str: WideString; UpperCase: Boolean = True): RawByteString;
var
  context: TMD5Context;
begin
  context.init;
  context.update(Pointer(str)^, Length(str) * 2);
  context.finish;
  Result := MemHex(context.digest, SizeOf(context.digest), UpperCase);
end;

function MD5CalcUStr(const str: UnicodeString; UpperCase: Boolean = True): RawByteString;
var
  context: TMD5Context;
begin
  context.init;
  context.update(Pointer(str)^, Length(str) * 2);
  context.finish;
  Result := MemHex(context.digest, SizeOf(context.digest), UpperCase);
end;

function MD5String(const str: string; UpperCase: Boolean = True): RawByteString;
var
  context: TMD5Context;
begin
  context.init;
  context.update(Pointer(str)^, Length(str) * SizeOf(Char));
  context.finish;
  Result := MemHex(context.digest, SizeOf(context.digest), UpperCase);
end;

function MD5Stream(const Stream: TStream; len: Int64 = 0): TMD5Digest;
var
  context: TMD5Context;
  buffer: array [0 .. 4095] of Byte;
  ReadBytes: Integer;
  Bookmark: Int64;
begin
  context.init;
  Bookmark := Stream.Position;
  if (len <= 0) or (len > Stream.Size - Bookmark) then
    len := Stream.Size - Bookmark;
  try
    while len > 0 do
    begin
      ReadBytes := SizeOf(buffer);
      if ReadBytes > len then
        ReadBytes := len;
      ReadBytes := Stream.Read(buffer, ReadBytes);
      context.update(buffer, ReadBytes);
      Dec(len, ReadBytes);
    end;
    context.finish;
    Result := context.digest;
  finally
    Stream.Position := Bookmark;
  end;
end;

function MD5File(const FileName: string): TMD5Digest;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := MD5Stream(Stream);
  finally
    Stream.Free;
  end;
end;

function MD5_F(x, y, z: UInt32): UInt32;
begin
  Result := (((x) and (y)) or ((not x) and (z)));
end;

function MD5_G(x, y, z: UInt32): UInt32;
begin
  Result := (((x) and (z)) or ((y) and (not z)));
end;

function MD5_H(x, y, z: UInt32): UInt32;
begin
  Result := ((x) xor (y) xor (z));
end;

function MD5_I(x, y, z: UInt32): UInt32;
begin
  Result := ((y) xor ((x) or (not z)));
end;

function MD5_ROTATE_LEFT(x, n: UInt32): UInt32;
begin
  Result := (((x) shl (n)) or ((x) shr (32 - (n))));
end;

procedure MD5_FF(var a: UInt32; b, c, d, x, s, ac: UInt32);
begin
  a := a + MD5_F(b, c, d) + x + ac;
  a := MD5_ROTATE_LEFT(a, s);
  a := a + b;
end;

procedure MD5_GG(var a: UInt32; b, c, d, x, s, ac: UInt32);
begin
  a := a + MD5_G(b, c, d) + x + ac;
  a := MD5_ROTATE_LEFT(a, s);
  a := a + b;
end;

procedure MD5_HH(var a: UInt32; b, c, d, x, s, ac: UInt32);
begin
  a := a + MD5_H(b, c, d) + x + ac;
  a := MD5_ROTATE_LEFT(a, s);
  a := a + b;
end;

procedure MD5_II(var a: UInt32; b, c, d, x, s, ac: UInt32);
begin
  a := a + MD5_I(b, c, d) + x + ac;
  a := MD5_ROTATE_LEFT(a, s);
  a := a + b;
end;

procedure MD5Decode(output: PArrayOfUInt32; input: PByteArray; len: LongWord);
var
  i, j: LongWord;
begin
  j := 0;
  i := 0;
  while j < len do
  begin
    output[i] := UInt32(input[j]) or (UInt32(input[j + 1]) shl 8) or (UInt32(input[j + 2]) shl 16) or
      (UInt32(input[j + 3]) shl 24);
    Inc(j, 4);
    Inc(i);
  end;
end;

procedure MD5Transform(var digest; const buffer);
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
  a, b, c, d: UInt32;
  x: array [0 .. 15] of UInt32;
  State: P4UInt32;
begin
  State := P4UInt32(@digest);
  a := State[0];
  b := State[1];
  c := State[2];
  d := State[3];

  MD5Decode(PArrayOfUInt32(@x), PByteArray(@buffer), 64);

  MD5_FF(a, b, c, d, x[0], S11, $D76AA478);
  MD5_FF(d, a, b, c, x[1], S12, $E8C7B756);
  MD5_FF(c, d, a, b, x[2], S13, $242070DB);
  MD5_FF(b, c, d, a, x[3], S14, $C1BDCEEE);
  MD5_FF(a, b, c, d, x[4], S11, $F57C0FAF);
  MD5_FF(d, a, b, c, x[5], S12, $4787C62A);
  MD5_FF(c, d, a, b, x[6], S13, $A8304613);
  MD5_FF(b, c, d, a, x[7], S14, $FD469501);
  MD5_FF(a, b, c, d, x[8], S11, $698098D8);
  MD5_FF(d, a, b, c, x[9], S12, $8B44F7AF);
  MD5_FF(c, d, a, b, x[10], S13, $FFFF5BB1);
  MD5_FF(b, c, d, a, x[11], S14, $895CD7BE);
  MD5_FF(a, b, c, d, x[12], S11, $6B901122);
  MD5_FF(d, a, b, c, x[13], S12, $FD987193);
  MD5_FF(c, d, a, b, x[14], S13, $A679438E);
  MD5_FF(b, c, d, a, x[15], S14, $49B40821);

  MD5_GG(a, b, c, d, x[1], S21, $F61E2562);
  MD5_GG(d, a, b, c, x[6], S22, $C040B340);
  MD5_GG(c, d, a, b, x[11], S23, $265E5A51);
  MD5_GG(b, c, d, a, x[0], S24, $E9B6C7AA);
  MD5_GG(a, b, c, d, x[5], S21, $D62F105D);
  MD5_GG(d, a, b, c, x[10], S22, $2441453);
  MD5_GG(c, d, a, b, x[15], S23, $D8A1E681);
  MD5_GG(b, c, d, a, x[4], S24, $E7D3FBC8);
  MD5_GG(a, b, c, d, x[9], S21, $21E1CDE6);
  MD5_GG(d, a, b, c, x[14], S22, $C33707D6);
  MD5_GG(c, d, a, b, x[3], S23, $F4D50D87);

  MD5_GG(b, c, d, a, x[8], S24, $455A14ED);
  MD5_GG(a, b, c, d, x[13], S21, $A9E3E905);
  MD5_GG(d, a, b, c, x[2], S22, $FCEFA3F8);
  MD5_GG(c, d, a, b, x[7], S23, $676F02D9);
  MD5_GG(b, c, d, a, x[12], S24, $8D2A4C8A);

  MD5_HH(a, b, c, d, x[5], S31, $FFFA3942);
  MD5_HH(d, a, b, c, x[8], S32, $8771F681);
  MD5_HH(c, d, a, b, x[11], S33, $6D9D6122);
  MD5_HH(b, c, d, a, x[14], S34, $FDE5380C);
  MD5_HH(a, b, c, d, x[1], S31, $A4BEEA44);
  MD5_HH(d, a, b, c, x[4], S32, $4BDECFA9);
  MD5_HH(c, d, a, b, x[7], S33, $F6BB4B60);
  MD5_HH(b, c, d, a, x[10], S34, $BEBFBC70);
  MD5_HH(a, b, c, d, x[13], S31, $289B7EC6);
  MD5_HH(d, a, b, c, x[0], S32, $EAA127FA);
  MD5_HH(c, d, a, b, x[3], S33, $D4EF3085);
  MD5_HH(b, c, d, a, x[6], S34, $4881D05);
  MD5_HH(a, b, c, d, x[9], S31, $D9D4D039);
  MD5_HH(d, a, b, c, x[12], S32, $E6DB99E5);
  MD5_HH(c, d, a, b, x[15], S33, $1FA27CF8);
  MD5_HH(b, c, d, a, x[2], S34, $C4AC5665);

  MD5_II(a, b, c, d, x[0], S41, $F4292244);
  MD5_II(d, a, b, c, x[7], S42, $432AFF97);
  MD5_II(c, d, a, b, x[14], S43, $AB9423A7);
  MD5_II(b, c, d, a, x[5], S44, $FC93A039);
  MD5_II(a, b, c, d, x[12], S41, $655B59C3);
  MD5_II(d, a, b, c, x[3], S42, $8F0CCC92);
  MD5_II(c, d, a, b, x[10], S43, $FFEFF47D);
  MD5_II(b, c, d, a, x[1], S44, $85845DD1);
  MD5_II(a, b, c, d, x[8], S41, $6FA87E4F);
  MD5_II(d, a, b, c, x[15], S42, $FE2CE6E0);
  MD5_II(c, d, a, b, x[6], S43, $A3014314);
  MD5_II(b, c, d, a, x[13], S44, $4E0811A1);
  MD5_II(a, b, c, d, x[4], S41, $F7537E82);
  MD5_II(d, a, b, c, x[11], S42, $BD3AF235);
  MD5_II(c, d, a, b, x[2], S43, $2AD7D2BB);
  MD5_II(b, c, d, a, x[9], S44, $EB86D391);

  Inc(State[0], a);
  Inc(State[1], b);
  Inc(State[2], c);
  Inc(State[3], d);

  FillChar(x, SizeOf(x), 0);
end;

{$ENDREGION}
{$REGION 'hmac_md5 implementation'}

{ THMAC_MD5Context }

function THMAC_MD5Context.finish: TMD5Digest;
var
  ctx: TMD5Context;
  outerPadding: T512BitBuf;
begin
  hashctx.finish;

  xor_32bit_array(keyBlock, outerPadding, $5C5C5C5C, Length(keyBlock.dwords));

  ctx.init;
  ctx.update(outerPadding, SizeOf(outerPadding));
  ctx.update(hashctx.digest, SizeOf(hashctx.digest));
  ctx.finish;
  Result := ctx.digest;
end;

procedure THMAC_MD5Context.init(const key; const keyLen: Integer);
var
  innerPadding: T512BitBuf;
  kd: TMD5Digest;
begin
  hashctx.init;
  FillChar(Self.keyBlock, SizeOf(Self.keyBlock), 0);

  if keyLen > 64 then
  begin
    kd := MD5(key, keyLen);
    Move(kd, keyBlock, SizeOf(kd));
  end
  else
    Move(key, keyBlock, keyLen);

  xor_32bit_array(keyBlock, innerPadding, $36363636, Length(keyBlock.dwords));
  hashctx.update(innerPadding, SizeOf(innerPadding));
end;

procedure THMAC_MD5Context.reset;
var
  innerPadding: T512BitBuf;
begin
  hashctx.init;
  xor_32bit_array(keyBlock, innerPadding, $36363636, Length((keyBlock.dwords)));
  hashctx.update(innerPadding, SizeOf(innerPadding));
end;

procedure THMAC_MD5Context.update(const buf: RawByteString);
begin
  hashctx.update(Pointer(buf)^, Length(buf));
end;

procedure THMAC_MD5Context.update(const buf; BufLen: Integer);
begin
  hashctx.update(buf, BufLen);
end;

function HMAC_MD5(const key; keyLen: Integer; const buf; BufLen: Integer): TMD5Digest;
var
  ctx: THMAC_MD5Context;
begin
  ctx.init(key, keyLen);
  ctx.update(buf, BufLen);
  Result := ctx.finish;
end;

function HMAC_MD5(const key, data: RawByteString): TMD5Digest;
var
  ctx: THMAC_MD5Context;
begin
  ctx.init(Pointer(key)^, Length(key));
  ctx.update(Pointer(data)^, Length(data));
  Result := ctx.finish;
end;

{$ENDREGION}

{$REGION 'BASE58 implementation}
function Base58Encode(input: Pointer; InputSize: Integer; output: PAnsiChar;
  const CharTable: RawByteString): PAnsiChar;
var
  pbegin, pend, it: PAnsiChar;
  i, zeroes, len, size, carry: Integer;
begin
  pbegin := PAnsiChar(input);
  pend := pbegin + InputSize;
  // Skip & count leading zeroes.
  zeroes := 0;
  len := 0;
  while (pbegin <> pend) and (pbegin^ = #0) do
  begin
    Inc(pbegin);
    Inc(zeroes);
  end;
  // Allocate enough space in big-endian base58 representation.
  size := (pend - pbegin) * 138 div 100 + 1; // log(256) / log(58), rounded up.

  if output = nil then
  begin
    Result := output - (zeroes + size);
    Exit;
  end;

  it := output - size;
  FillChar(it^, size, 0);
  // Process the bytes.
  while (pbegin <> pend) do
  begin
    carry := Ord(pbegin^);
    i := 0;
    // Apply "b58 = b58 * 256 + ch".
    it := output - 1;
    while (carry <> 0) or (i < len) do
    begin
      Inc(carry, 256 * Byte(it^));
      Byte(it^) := carry mod 58;
      carry := carry div 58;
      Dec(it);
      Inc(i);
    end;
    len := i;
    Inc(pbegin);
  end;
  // Skip leading zeroes in base58 result.
  it := output - len;
  while (it <> output) and (it^ = #0) do Inc(it);
  // Translate the result into a string.
  for i := 1 to zeroes do
    it[-i] := '1';
  for i := 0 to output - it - 1 do
    it[i] := PAnsiChar(CharTable)[Byte(it[i])];
  Result := it - zeroes;
end;

function Base58Encode(input: Pointer; InputSize: Integer;
  const CharTable: RawByteString): RawByteString;
var
  pbegin, pend: PAnsiChar;
  zeroes, size: Integer;
begin
  pbegin := PAnsiChar(input);
  pend := pbegin + InputSize;
  // Skip & count leading zeroes.
  zeroes := 0;
  while (pbegin <> pend) and (pbegin^ = #0) do
  begin
    Inc(pbegin);
    Inc(zeroes);
  end;
  // Allocate enough space in big-endian base58 representation.
  size := (pend - pbegin) * 138 div 100 + 1; // log(256) / log(58), rounded up.
  SetLength(Result, zeroes + size);
  pend := PAnsiChar(Pointer(Result)) + zeroes + size;
  pbegin := Base58Encode(input, InputSize, pend, CharTable);
  if pbegin <> Pointer(Result) then
    SetString(Result, pbegin, pend - pbegin);
end;

procedure Base58DecodeError;
begin
  raise EBase58DecodeError.Create('invalid base58 input !');
end;

function Base58Decode(input: PAnsiChar; InputSize: Integer; output: PByte;
  const CharTable: RawByteString): PByte;
var
  i, zeroes, len, size, carry: Integer;
  IndexTable: array [AnsiChar] of Byte;
  pend: PAnsiChar;
  idx: Byte;
  it: PByte;
begin
  FillChar(IndexTable, SizeOf(IndexTable), 255);
  for i := 1 to Length(CharTable) do
    IndexTable[CharTable[i]] := i - 1;
  pend := input + InputSize;

  while (input <> pend) and (input^ in [#1..#32]) do Inc(input); // Skip leading spaces.

  // Skip and count leading '1's.
  zeroes := 0;
  len := 0;
  while (input <> pend) and (input^ = '1') do
  begin
    Inc(zeroes);
    Inc(input);
  end;

  // Allocate enough space in big-endian base256 representation.
  size := (pend - input) * 733 div 1000 + 1; // log(58) / log(256), rounded up.

  if output = nil then
  begin
    Result := output - (size + zeroes);
    Exit;
  end;
  it := output - size;
  FillChar(it^, size, 0);
  // Process the characters.
  while (input <> pend) and (input^ > #32) do
  begin
    // Decode base58 character
    idx := IndexTable[input^];
    if idx > 57 then
      Base58DecodeError;
    // Apply "b256 = b256 * 58 + ch".
    carry := idx;
    i := 0;
    it := output - 1;
    while (carry <> 0) or (i < len) do
    begin
      Inc(carry, 58 * it^);
      it^ := carry mod 256;
      carry := carry div 256;
      Dec(it);
      Inc(i);
    end;
    len := i;
    Inc(input);
  end;
  // Skip trailing spaces.
  while (input <> pend) and (input^ in [#1..#32]) do Inc(input); // Skip leading spaces.
  if (input <> pend) then
    Base58DecodeError;
  // Skip leading zeroes in b256.
  it := output - len;
  while (it <> output) and (it^ = 0) do Inc(it);
  // Copy result into output vector.
  for i := 1 to zeroes do
    it[-i] := 0;
  Result := it - zeroes;
end;

function Base58Decode(const input: RawByteString; output: PByte;
  const CharTable: RawByteString): PByte;
begin
  Result := Base58Decode(Pointer(input), Length(input), output, CharTable);
end;

function Base58Decode(const input, CharTable: RawByteString): RawByteString;
var
  zeroes, size: Integer;
  LInputPtr, pbegin, pend: PAnsiChar;
begin
  LInputPtr := PAnsiChar(Pointer(input));
  pend := LInputPtr + Length(input);
  while (LInputPtr <> pend) and (LInputPtr^ in [#1..#32]) do Inc(LInputPtr); // Skip leading spaces.
  // Skip and count leading '1's.
  zeroes := 0;
  while (LInputPtr <> pend) and (LInputPtr^ = '1') do
  begin
    Inc(zeroes);
    Inc(LInputPtr);
  end;

  // Allocate enough space in big-endian base256 representation.
  size := (pend - LInputPtr) * 733 div 1000 + 1; // log(58) / log(256), rounded up.
  SetLength(Result, zeroes + size);
  pend := PAnsiChar(Pointer(Result)) + (zeroes + size);
  pbegin := PAnsiChar(Base58Decode(PAnsiChar(Pointer(input)), Length(input), PByte(pend), CharTable));

  if pbegin <> PAnsiChar(Pointer(Result)) then
    SetString(Result, pbegin, pend - pbegin);
end;

{$ENDREGION}

{$REGION 'base64 implementation'}

function Base64Encode(input: Pointer; InputSize: Integer; output: Pointer; const CharTable: RawByteString): Integer;
var
  IPtr: P3Bytes;
  OPtr: P4Bytes;
  IEnd: PAnsiChar;
begin
  Result := (InputSize + 2) div 3 * 4;
  if output = nil then
    Exit;
  IPtr := P3Bytes(input);
  OPtr := P4Bytes(output);
  IEnd := PAnsiChar(input) + InputSize;

  while IEnd > PAnsiChar(IPtr) do
  begin
    OPtr[0] := IPtr[0] shr 2;
    OPtr[1] := (IPtr[0] shl 4) and $30;
    if IEnd - PAnsiChar(IPtr) > 2 then
    begin
      OPtr[1] := OPtr[1] or (IPtr[1] shr 4);
      OPtr[2] := (IPtr[1] shl 2) and $3F;
      OPtr[2] := OPtr[2] or IPtr[2] shr 6;
      OPtr[3] := IPtr[2] and $3F;
    end
    else if IEnd - PAnsiChar(IPtr) > 1 then
    begin
      OPtr[1] := OPtr[1] or (IPtr[1] shr 4);
      OPtr[2] := (IPtr[1] shl 2) and $3F;
      OPtr[3] := 64;
    end
    else
    begin
      OPtr[2] := 64;
      OPtr[3] := 64;
    end;

    OPtr[0] := Ord(CharTable[OPtr[0] + 1]);
    OPtr[1] := Ord(CharTable[OPtr[1] + 1]);
    OPtr[2] := Ord(CharTable[OPtr[2] + 1]);
    OPtr[3] := Ord(CharTable[OPtr[3] + 1]);

    Inc(IPtr);
    Inc(OPtr);
  end;
end;

function Base64Encode(input: Pointer; InputSize: Integer): RawByteString; overload;
begin
  SetLength(Result, (InputSize + 2) div 3 * 4);
  Base64Encode(input, InputSize, Pointer(Result));
end;

function Base64Encode(const input: RawByteString; const CharTable: RawByteString): RawByteString; overload;
begin
  SetLength(Result, (Length(input) + 2) div 3 * 4);
  Base64Encode(Pointer(input), Length(input), Pointer(Result), CharTable);
end;

function Base64DecodeResultLen(input: Pointer; InputSize: Integer): Integer;
var
  r: Integer;
begin
  Result := ((InputSize + 3) div 4) * 3;

  r := InputSize mod 4;

  case r of
    0:
      if PAnsiChar(input)[InputSize - 2] = '=' then
        Dec(Result, 2)
      else if PAnsiChar(input)[InputSize - 1] = '=' then
        Dec(Result);
    1:
      raise EBase64DecodeError.Create('invalid base64 input !');
    2:
      Dec(Result, 2);
  else
    Dec(Result);
  end;
end;

function Base64Decode(input: Pointer; InputSize: Integer; output: Pointer; const CharTable: RawByteString): Integer;
var
  IPtr: P4Bytes;
  tmp: T4Bytes;
  OPtr: P3Bytes;
  i, r: Integer;
  IndexTable: array [Byte] of Byte;
begin
  if InputSize = 0 then
  begin
    Result := 0;
    Exit;
  end;

  Result := ((InputSize + 3) div 4) * 3;

  r := InputSize mod 4;

  case r of
    0:
      if PAnsiChar(input)[InputSize - 2] = '=' then
        Dec(Result, 2)
      else if PAnsiChar(input)[InputSize - 1] = '=' then
        Dec(Result);
    1:
      raise EBase64DecodeError.Create('invalid base64 input !');
    2:
      Dec(Result, 2);
  else
    Dec(Result);
  end;

  if output = nil then
    Exit;
  FillChar(IndexTable, SizeOf(IndexTable), 255);

  for i := 1 to Length(CharTable) do
    IndexTable[Ord(CharTable[i])] := i - 1;

  IPtr := P4Bytes(input);
  OPtr := P3Bytes(output);

  for i := 1 to InputSize div 4 do
  begin
    tmp[0] := IndexTable[IPtr[0]];
    if tmp[0] > 64 then
      raise EBase64DecodeError.Create('invalid base64 input !');

    tmp[1] := IndexTable[IPtr[1]];
    if tmp[1] > 64 then
      raise EBase64DecodeError.Create('invalid base64 input !');

    tmp[2] := IndexTable[IPtr[2]];
    if tmp[2] > 64 then
      raise EBase64DecodeError.Create('invalid base64 input !');

    tmp[3] := IndexTable[IPtr[3]];
    if tmp[3] > 64 then
      raise EBase64DecodeError.Create('invalid base64 input !');

    OPtr[0] := (tmp[0] shl 2) or (tmp[1] shr 4);

    if (tmp[2] <> 64) then
      OPtr[1] := (tmp[1] shl 4) or (tmp[2] shr 2);

    if (tmp[3] <> 64) then
      OPtr[2] := (tmp[2] shl 6) or tmp[3];

    Inc(IPtr);
    Inc(OPtr);
  end;

  if r = 2 then
  begin
    tmp[0] := IndexTable[IPtr[0]];
    if tmp[0] > 64 then
      raise EBase64DecodeError.Create('invalid base64 input !');

    tmp[1] := IndexTable[IPtr[1]];
    if tmp[1] > 64 then
      raise EBase64DecodeError.Create('invalid base64 input !');
    OPtr[0] := (tmp[0] shl 2) or (tmp[1] shr 4);
  end
  else if r = 3 then
  begin
    tmp[0] := IndexTable[IPtr[0]];
    if tmp[0] > 64 then
      raise EBase64DecodeError.Create('invalid base64 input !');

    tmp[1] := IndexTable[IPtr[1]];
    if tmp[1] > 64 then
      raise EBase64DecodeError.Create('invalid base64 input !');

    tmp[2] := IndexTable[IPtr[2]];
    if tmp[2] > 64 then
      raise EBase64DecodeError.Create('invalid base64 input !');

    OPtr[0] := (tmp[0] shl 2) or (tmp[1] shr 4);
    OPtr[1] := (tmp[1] shl 4) or (tmp[2] shr 2);
  end;
end;

function Base64Decode(const input: RawByteString; output: Pointer): Integer; overload;
begin
  Result := Base64Decode(Pointer(input), Length(input), output);
end;

function Base64Decode(const input: RawByteString): RawByteString; overload;
var
  InputSize: Integer;
  OutputSize: Integer;
begin
  InputSize := Length(input);
  OutputSize := Base64DecodeResultLen(Pointer(input), InputSize);
  SetLength(Result, OutputSize);
  Base64Decode(Pointer(input), InputSize, Pointer(Result));
end;

{$ENDREGION}
{$REGION 'sha1 implementation'}

{ TSHA1Context }

function KT(t: Integer): UInt32; inline;
const
  NO_NAME: array [0 .. 3] of UInt32 = ($5A827999, $6ED9EBA1, $8F1BBCDC, $CA62C1D6);
begin
  Result := NO_NAME[t div 20];
end;

function FT(t: Integer; b, c, d: UInt32): UInt32;
begin
  case t div 20 of
    0:
      Result := (b and c) or ((not b) and d);
    1, 3:
      Result := b xor c xor d;
  else
    Result := (b and c) or (b and d) or (c and d);
  end;
end;

procedure SHA1CalcBlock(var digest: TSHA1Digest; const block: T512BitBuf);
var
  W: array [0 .. 79] of UInt32;
  t: Integer;
  a, b, c, d, E, Temp: UInt32;
begin
  for t := 0 to 15 do
    W[t] := SysToBigEndian(block.dwords[t].value);
  for t := 16 to 79 do
    W[t] := RotateLeft32(W[t - 3] xor W[t - 8] xor W[t - 14] xor W[t - 16], 1);
  a := digest.dwords[0].value;
  b := digest.dwords[1].value;
  c := digest.dwords[2].value;
  d := digest.dwords[3].value;
  E := digest.dwords[4].value;
  for t := 0 to 79 do
  begin
    Temp := RotateLeft32(a, 5) + FT(t, b, c, d) + E + W[t] + KT(t);
    E := d;
    d := c;
    c := RotateLeft32(b, 30);
    b := a;
    a := Temp;
  end;
  Inc(digest.dwords[0].value, a);
  Inc(digest.dwords[1].value, b);
  Inc(digest.dwords[2].value, c);
  Inc(digest.dwords[3].value, d);
  Inc(digest.dwords[4].value, E);
end;

procedure TSHA1Context.finish;
var
  _totalLen: Int64;
begin
  _totalLen := Self.TotalLen * 8;
  //Reverse64Bit(_totalLen);
  _totalLen := ReverseByteOrder64(_totalLen);

  Self.buffer.bytes[Self.BufLen] := $80;
  Inc(Self.BufLen);

  if Self.BufLen <= 56 then
  begin
    FillChar(Self.buffer.bytes[Self.BufLen], 56 - Self.BufLen, 0);
    Self.buffer.qwords[7].value := _totalLen;
    SHA1CalcBlock(Self.digest, Self.buffer);
  end
  else
  begin
    FillChar(Self.buffer.bytes[Self.BufLen], 64 - Self.BufLen, 0);
    SHA1CalcBlock(Self.digest, Self.buffer);

    Self.buffer.qwords[0].value := 0;
    Self.buffer.qwords[1].value := 0;
    Self.buffer.qwords[2].value := 0;
    Self.buffer.qwords[3].value := 0;
    Self.buffer.qwords[4].value := 0;
    Self.buffer.qwords[5].value := 0;
    Self.buffer.qwords[6].value := 0;
    Self.buffer.qwords[7].value := _totalLen;

    SHA1CalcBlock(Self.digest, Self.buffer);
  end;

  with Self.digest do
  begin
    dwords[0].value := ReverseByteOrder32(dwords[0].value);
    dwords[1].value := ReverseByteOrder32(dwords[1].value);
    dwords[2].value := ReverseByteOrder32(dwords[2].value);
    dwords[3].value := ReverseByteOrder32(dwords[3].value);
    dwords[4].value := ReverseByteOrder32(dwords[4].value);
  end;
end;

procedure TSHA1Context.init;
begin
  digest.dwords[0].value := $67452301;
  digest.dwords[1].value := $EFCDAB89;
  digest.dwords[2].value := $98BADCFE;
  digest.dwords[3].value := $10325476;
  digest.dwords[4].value := $C3D2E1F0;
  BufLen := 0;
  TotalLen := 0;
end;

procedure TSHA1Context.update(const buf; BufSize: Integer);
var
  P: P512BitBuf;
  M, i, j: Integer;
begin
  if BufSize <= 0 then
    Exit;

  Inc(Self.TotalLen, BufSize);
  P := P512BitBuf(@buf);

  if Self.BufLen > 0 then
  begin
    M := 64 - Self.BufLen;

    if M > BufSize then
    begin
      Move(buf, Self.buffer.bytes[Self.BufLen], BufSize);
      Inc(Self.BufLen, BufSize);
      Exit;
    end;

    Move(buf, Self.buffer.bytes[Self.BufLen], M);
    SHA1CalcBlock(Self.digest, Self.buffer);
    Inc(PByte(P), M);
    Dec(BufSize, M);
  end;

  j := BufSize shr 6;

  for i := 1 to j do
  begin
    SHA1CalcBlock(Self.digest, P^);
    Inc(P);
  end;

  j := BufSize and $3F;

  if j > 0 then
  begin
    Self.BufLen := j;
    Move(P^, Self.buffer, j);
  end;
end;

function SHA1(const buf; BufSize: Integer): TSHA1Digest;
var
  context: TSHA1Context;
begin
  context.init;
  context.update(buf, BufSize);
  context.finish;
  Result := context.digest;
end;

function SHA1(const str: RawByteString): TSHA1Digest;
var
  context: TSHA1Context;
begin
  context.init;
  context.update(Pointer(str)^, Length(str));
  context.finish;
  Result := context.digest;
end;

function SHA1Stream(const Stream: TStream; len: Int64): TSHA1Digest;
var
  context: TSHA1Context;
  buffer: array [0 .. 4095] of Byte;
  ReadBytes: Integer;
  Bookmark: Int64;
begin
  context.init;
  Bookmark := Stream.Position;
  if (len <= 0) or (len > Stream.Size - Bookmark) then
    len := Stream.Size - Bookmark;
  try
    while len > 0 do
    begin
      ReadBytes := SizeOf(buffer);
      if ReadBytes > len then
        ReadBytes := len;
      ReadBytes := Stream.Read(buffer, ReadBytes);
      context.update(buffer, ReadBytes);
      Dec(len, ReadBytes);
    end;
    context.finish;
    Result := context.digest;
  finally
    Stream.Position := Bookmark;
  end;
end;

function SHA1File(const FileName: string): TSHA1Digest;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := SHA1Stream(Stream);
  finally
    Stream.Free;
  end;
end;

{$ENDREGION}
{$REGION 'hmac_sha1 implementation'}

{ THMAC_SHA1Context }

function THMAC_SHA1Context.finish: TSHA1Digest;
var
  ctx: TSHA1Context;
  outerPadding: T512BitBuf;
begin
  hashctx.finish;
  xor_32bit_array(keyBlock, outerPadding, $5C5C5C5C, Length(keyBlock.dwords));
  ctx.init;
  ctx.update(outerPadding, SizeOf(outerPadding));
  ctx.update(hashctx.digest, SizeOf(hashctx.digest));
  ctx.finish;
  Result := ctx.digest;
end;

procedure THMAC_SHA1Context.init(const key; const keyLen: Integer);
var
  innerPadding: T512BitBuf;
  kd: TSHA1Digest;
begin
  hashctx.init;
  FillChar(Self.keyBlock, SizeOf(Self.keyBlock), 0);

  if keyLen > 64 then
  begin
    kd := SHA1(key, keyLen);
    Move(kd, keyBlock, SizeOf(kd));
  end
  else
    Move(key, keyBlock, keyLen);

  xor_32bit_array(keyBlock, innerPadding, $36363636, Length(keyBlock.dwords));
  hashctx.update(innerPadding, SizeOf(innerPadding));
end;

procedure THMAC_SHA1Context.reset;
var
  innerPadding: T512BitBuf;
begin
  hashctx.init;
  xor_32bit_array(keyBlock, innerPadding, $36363636, Length((keyBlock.dwords)));
  hashctx.update(innerPadding, SizeOf(innerPadding));
end;

procedure THMAC_SHA1Context.update(const buf; BufLen: Integer);
begin
  hashctx.update(buf, BufLen);
end;

function HMAC_SHA1(const key; keyLen: Integer; const buf; BufLen: Integer): TSHA1Digest;
var
  ctx: THMAC_SHA1Context;
begin
  ctx.init(key, keyLen);
  ctx.update(buf, BufLen);
  Result := ctx.finish;
end;

function HMAC_SHA1(const key, data: RawByteString): TSHA1Digest;
var
  ctx: THMAC_SHA1Context;
begin
  ctx.init(Pointer(key)^, Length(key));
  ctx.update(Pointer(data)^, Length(data));
  Result := ctx.finish;
end;

{$ENDREGION}
{$REGION 'sha256 implementation'}

function SHA256Transform1(a: UInt32): UInt32;
begin
  Result := RotateRight32(a, 7) xor RotateRight32(a, 18) xor (a shr 3);
end;

function SHA256Transform2(a: UInt32): UInt32;
begin
  Result := RotateRight32(a, 17) xor RotateRight32(a, 19) xor (a shr 10);
end;

function SHA256Transform3(a: UInt32): UInt32;
begin
  Result := RotateRight32(a, 2) xor RotateRight32(a, 13) xor RotateRight32(a, 22);
end;

function SHA256Transform4(a: UInt32): UInt32;
begin
  Result := RotateRight32(a, 6) xor RotateRight32(a, 11) xor RotateRight32(a, 25);
end;

const
  // first 32 bits of the fractional parts of the cube roots of the first 64 primes 2..311
  SHA256K: array [0 .. 63] of UInt32 = ($428A2F98, $71374491, $B5C0FBCF, $E9B5DBA5, $3956C25B, $59F111F1, $923F82A4,
    $AB1C5ED5, $D807AA98, $12835B01, $243185BE, $550C7DC3, $72BE5D74, $80DEB1FE, $9BDC06A7, $C19BF174, $E49B69C1,
    $EFBE4786, $0FC19DC6, $240CA1CC, $2DE92C6F, $4A7484AA, $5CB0A9DC, $76F988DA, $983E5152, $A831C66D, $B00327C8,
    $BF597FC7, $C6E00BF3, $D5A79147, $06CA6351, $14292967, $27B70A85, $2E1B2138, $4D2C6DFC, $53380D13, $650A7354,
    $766A0ABB, $81C2C92E, $92722C85, $A2BFE8A1, $A81A664B, $C24B8B70, $C76C51A3, $D192E819, $D6990624, $F40E3585,
    $106AA070, $19A4C116, $1E376C08, $2748774C, $34B0BCB5, $391C0CB3, $4ED8AA4A, $5B9CCA4F, $682E6FF3, $748F82EE,
    $78A5636F, $84C87814, $8CC70208, $90BEFFFA, $A4506CEB, $BEF9A3F7, $C67178F2);

  {$IFOPT Q+}{$DEFINE QOn}{$Q-}{$ELSE}{$UNDEF QOn}{$ENDIF}

procedure TransformSHA256(var digest: TSHA256Digest; const buf);
var
  i: Integer;
  W: array [0 .. 63] of UInt32;
  P: PUint32;
  S0, S1, Maj, T1, T2, Ch: UInt32;
  H: array [0 .. 7] of UInt32;
begin
  P := @buf;
  for i := 0 to 15 do
  begin
    W[i] := P^;
    W[i] := ReverseByteOrder32(W[i]);
    Inc(P);
  end;
  for i := 16 to 63 do
  begin
    S0 := SHA256Transform1(W[i - 15]);
    S1 := SHA256Transform2(W[i - 2]);
    W[i] := W[i - 16] + S0 + W[i - 7] + S1;
  end;
  for i := 0 to 7 do
    H[i] := digest.dwords[i].value;
  for i := 0 to 63 do
  begin
    S0 := SHA256Transform3(H[0]);
    Maj := (H[0] and H[1]) xor (H[0] and H[2]) xor (H[1] and H[2]);
    T2 := S0 + Maj;
    S1 := SHA256Transform4(H[4]);
    Ch := (H[4] and H[5]) xor ((not H[4]) and H[6]);
    T1 := H[7] + S1 + Ch + SHA256K[i] + W[i];
    H[7] := H[6];
    H[6] := H[5];
    H[5] := H[4];
    H[4] := H[3] + T1;
    H[3] := H[2];
    H[2] := H[1];
    H[1] := H[0];
    H[0] := T1 + T2;
  end;
  for i := 0 to 7 do
    Inc(digest.dwords[i].value, H[i]);
end;

{$IFDEF QOn}{$Q+}{$ENDIF}

{ TSHA256Context }

procedure TSHA256Context.finish;
var
  _totalLen: Int64;
begin
  _totalLen := Self.TotalLen * 8;
  //Reverse64Bit(_totalLen);
  _totalLen := ReverseByteOrder64(_totalLen);

  Self.buffer.bytes[Self.BufLen] := $80;
  Inc(Self.BufLen);

  if Self.BufLen <= 56 then
  begin
    FillChar(Self.buffer.bytes[Self.BufLen], 56 - Self.BufLen, 0);
    Self.buffer.qwords[7].value := _totalLen;
    TransformSHA256(Self.digest, Self.buffer);
  end
  else
  begin
    FillChar(Self.buffer.bytes[Self.BufLen], 64 - Self.BufLen, 0);
    TransformSHA256(Self.digest, Self.buffer);

    Self.buffer.qwords[0].value := 0;
    Self.buffer.qwords[1].value := 0;
    Self.buffer.qwords[2].value := 0;
    Self.buffer.qwords[3].value := 0;
    Self.buffer.qwords[4].value := 0;
    Self.buffer.qwords[5].value := 0;
    Self.buffer.qwords[6].value := 0;
    Self.buffer.qwords[7].value := _totalLen;

    TransformSHA256(Self.digest, Self.buffer);
  end;

  with Self.digest do
  begin
    dwords[0].value := ReverseByteOrder32(dwords[0].value);
    dwords[1].value := ReverseByteOrder32(dwords[1].value);
    dwords[2].value := ReverseByteOrder32(dwords[2].value);
    dwords[3].value := ReverseByteOrder32(dwords[3].value);
    dwords[4].value := ReverseByteOrder32(dwords[4].value);
    dwords[5].value := ReverseByteOrder32(dwords[5].value);
    dwords[6].value := ReverseByteOrder32(dwords[6].value);
    dwords[7].value := ReverseByteOrder32(dwords[7].value);
  end;
end;

procedure TSHA256Context.init;
begin
  TotalLen := 0;
  BufLen := 0;
  digest.dwords[0].value := $6A09E667;
  digest.dwords[1].value := $BB67AE85;
  digest.dwords[2].value := $3C6EF372;
  digest.dwords[3].value := $A54FF53A;
  digest.dwords[4].value := $510E527F;
  digest.dwords[5].value := $9B05688C;
  digest.dwords[6].value := $1F83D9AB;
  digest.dwords[7].value := $5BE0CD19;
end;

procedure TSHA256Context.update(const buf; BufSize: Integer);
var
  P: PByte;
  i, j, M: Integer;
begin
  if BufSize <= 0 then
    Exit;

  Inc(Self.TotalLen, BufSize);
  P := PByte(@buf);

  if Self.BufLen > 0 then
  begin
    M := SizeOf(Self.buffer) - Self.BufLen;
    if M > BufSize then
    begin
      Move(P^, Self.buffer.bytes[Self.BufLen], BufSize);
      Inc(Self.BufLen, BufSize);
      Exit;
    end
    else
    begin
      Move(P^, Self.buffer.bytes[Self.BufLen], M);
      TransformSHA256(Self.digest, Self.buffer);
      Self.BufLen := 0;
      Inc(P, M);
      Dec(BufSize, M);
      if BufSize = 0 then
        Exit;
    end;
  end;

  j := BufSize shr 6; // BufSize div 64;

  for i := 0 to j - 1 do
  begin
    TransformSHA256(Self.digest, P^);
    Inc(P, SizeOf(Self.buffer));
  end;

  j := BufSize and $3F;

  if j <> 0 then
  begin
    Move(P^, Self.buffer, j);
    Self.BufLen := j;
  end;
end;

function SHA256(const buf; BufSize: Integer): TSHA256Digest;
var
  ctx: TSHA256Context;
begin
  ctx.init;
  ctx.update(buf, BufSize);
  ctx.finish;
  Result := ctx.digest;
end;

function SHA256(const str: RawByteString): TSHA256Digest;
var
  ctx: TSHA256Context;
begin
  ctx.init;
  ctx.update(Pointer(str)^, Length(str));
  ctx.finish;
  Result := ctx.digest;
end;

function SHA256Stream(const Stream: TStream; len: Int64): TSHA256Digest;
var
  context: TSHA256Context;
  buffer: array [0 .. 4095] of Byte;
  ReadBytes: Integer;
  Bookmark: Int64;
begin
  context.init;
  Bookmark := Stream.Position;
  if (len <= 0) or (len > Stream.Size - Bookmark) then
    len := Stream.Size - Bookmark;
  try
    while len > 0 do
    begin
      ReadBytes := SizeOf(buffer);
      if ReadBytes > len then
        ReadBytes := len;
      ReadBytes := Stream.Read(buffer, ReadBytes);
      context.update(buffer, ReadBytes);
      Dec(len, ReadBytes);
    end;
    context.finish;
    Result := context.digest;
  finally
    Stream.Position := Bookmark;
  end;
end;

function SHA256File(const FileName: string): TSHA256Digest;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := SHA256Stream(Stream);
  finally
    Stream.Free;
  end;
end;

{$ENDREGION}
{$REGION 'sha224 implementation'}

{ TSHA224Context }

procedure TSHA224Context.finish;
begin
  _256.finish;
  Move(_256.digest, Self.digest, SizeOf(Self.digest));
end;

procedure TSHA224Context.init;
begin
  _256.TotalLen := 0;
  _256.BufLen := 0;
  _256.digest.dwords[0].value := $C1059ED8;
  _256.digest.dwords[1].value := $367CD507;
  _256.digest.dwords[2].value := $3070DD17;
  _256.digest.dwords[3].value := $F70E5939;
  _256.digest.dwords[4].value := $FFC00B31;
  _256.digest.dwords[5].value := $68581511;
  _256.digest.dwords[6].value := $64F98FA7;
  _256.digest.dwords[7].value := $BEFA4FA4;
end;

procedure TSHA224Context.update(const buf; BufSize: Integer);
begin
  _256.update(buf, BufSize);
end;

function SHA224(const buf; BufSize: Integer): TSHA224Digest;
var
  ctx: TSHA224Context;
begin
  ctx.init;
  ctx.update(buf, BufSize);
  ctx.finish;
  Result := ctx.digest;
end;

function SHA224(const str: RawByteString): TSHA224Digest;
var
  ctx: TSHA224Context;
begin
  ctx.init;
  ctx.update(Pointer(str)^, Length(str));
  ctx.finish;
  Result := ctx.digest;
end;

function SHA224Stream(const Stream: TStream; len: Int64): TSHA224Digest;
var
  context: TSHA224Context;
  buffer: array [0 .. 4095] of Byte;
  ReadBytes: Integer;
  Bookmark: Int64;
begin
  context.init;
  Bookmark := Stream.Position;
  if (len <= 0) or (len > Stream.Size - Bookmark) then
    len := Stream.Size - Bookmark;
  try
    while len > 0 do
    begin
      ReadBytes := SizeOf(buffer);
      if ReadBytes > len then
        ReadBytes := len;
      ReadBytes := Stream.Read(buffer, ReadBytes);
      context.update(buffer, ReadBytes);
      Dec(len, ReadBytes);
    end;
    context.finish;
    Result := context.digest;
  finally
    Stream.Position := Bookmark;
  end;
end;

function SHA224File(const FileName: string): TSHA224Digest;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := SHA224Stream(Stream);
  finally
    Stream.Free;
  end;
end;

{$ENDREGION}
{$REGION 'sha512 implementation'}

{ TSHA512Context }

// BSIG0(x) = ROTR^28(x) XOR ROTR^34(x) XOR ROTR^39(x)

function SHA512Transform1(const a: T64BitBuf): T64BitBuf;
begin
  Result.value := RotateRight64(a.value, 28) xor RotateRight64(a.value, 34) xor RotateRight64(a.value, 39);
end;

// BSIG1(x) = ROTR^14(x) XOR ROTR^18(x) XOR ROTR^41(x)

function SHA512Transform2(const a: T64BitBuf): T64BitBuf;
begin
  Result.value := RotateRight64(a.value, 14) xor RotateRight64(a.value, 18) xor RotateRight64(a.value, 41);
end;

// SSIG0(x) = ROTR^1(x) XOR ROTR^8(x) XOR SHR^7(x)

function SHA512Transform3(const a: T64BitBuf): T64BitBuf;
begin
  Result.value := RotateRight64(a.value, 1) xor RotateRight64(a.value, 8) xor (a.value shr 7);
end;

// SSIG1(x) = ROTR^19(x) XOR ROTR^61(x) XOR SHR^6(x)

function SHA512Transform4(const a: T64BitBuf): T64BitBuf;
begin
  Result.value := RotateRight64(a.value, 19) xor RotateRight64(a.value, 61) xor (a.value shr 6);
end;

// CH( x, y, z) = (x AND y) XOR ( (NOT x) AND z)

function SHA512Transform5(const x, y, z: UInt64): UInt64;
begin
  Result := (x and y) xor ((not x) and z);
end;

// MAJ( x, y, z) = (x AND y) XOR (x AND z) XOR (y AND z)

function SHA512Transform6(const x, y, z: UInt64): UInt64;
var
  T1, T2, T3: UInt64;
begin
  T1 := x and y;
  T2 := x and z;
  T3 := y and z;
  T1 := T1 xor T2;
  Result := T1 xor T3;
end;

const
  // first 64 bits of the fractional parts of the cube roots of the first eighty prime numbers
  // (stored High LongWord first then Low LongWord)

  SHA512K: array [0 .. 159] of UInt32 = ($428A2F98, $D728AE22, $71374491, $23EF65CD, $B5C0FBCF, $EC4D3B2F, $E9B5DBA5,
    $8189DBBC, $3956C25B, $F348B538, $59F111F1, $B605D019, $923F82A4, $AF194F9B, $AB1C5ED5, $DA6D8118, $D807AA98,
    $A3030242, $12835B01, $45706FBE, $243185BE, $4EE4B28C, $550C7DC3, $D5FFB4E2, $72BE5D74, $F27B896F, $80DEB1FE,
    $3B1696B1, $9BDC06A7, $25C71235, $C19BF174, $CF692694, $E49B69C1, $9EF14AD2, $EFBE4786, $384F25E3, $0FC19DC6,
    $8B8CD5B5, $240CA1CC, $77AC9C65, $2DE92C6F, $592B0275, $4A7484AA, $6EA6E483, $5CB0A9DC, $BD41FBD4, $76F988DA,
    $831153B5, $983E5152, $EE66DFAB, $A831C66D, $2DB43210, $B00327C8, $98FB213F, $BF597FC7, $BEEF0EE4, $C6E00BF3,
    $3DA88FC2, $D5A79147, $930AA725, $06CA6351, $E003826F, $14292967, $0A0E6E70, $27B70A85, $46D22FFC, $2E1B2138,
    $5C26C926, $4D2C6DFC, $5AC42AED, $53380D13, $9D95B3DF, $650A7354, $8BAF63DE, $766A0ABB, $3C77B2A8, $81C2C92E,
    $47EDAEE6, $92722C85, $1482353B, $A2BFE8A1, $4CF10364, $A81A664B, $BC423001, $C24B8B70, $D0F89791, $C76C51A3,
    $0654BE30, $D192E819, $D6EF5218, $D6990624, $5565A910, $F40E3585, $5771202A, $106AA070, $32BBD1B8, $19A4C116,
    $B8D2D0C8, $1E376C08, $5141AB53, $2748774C, $DF8EEB99, $34B0BCB5, $E19B48A8, $391C0CB3, $C5C95A63, $4ED8AA4A,
    $E3418ACB, $5B9CCA4F, $7763E373, $682E6FF3, $D6B2B8A3, $748F82EE, $5DEFB2FC, $78A5636F, $43172F60, $84C87814,
    $A1F0AB72, $8CC70208, $1A6439EC, $90BEFFFA, $23631E28, $A4506CEB, $DE82BDE9, $BEF9A3F7, $B2C67915, $C67178F2,
    $E372532B, $CA273ECE, $EA26619C, $D186B8C7, $21C0C207, $EADA7DD6, $CDE0EB1E, $F57D4F7F, $EE6ED178, $06F067AA,
    $72176FBA, $0A637DC5, $A2C898A6, $113F9804, $BEF90DAE, $1B710B35, $131C471B, $28DB77F5, $23047D84, $32CAAB7B,
    $40C72493, $3C9EBE0A, $15C9BEBC, $431D67C4, $9C100D4C, $4CC5D4BE, $CB3E42B6, $597F299C, $FC657E2A, $5FCB6FAB,
    $3AD6FAEC, $6C44198C, $4A475817);

  {$IFOPT Q+}{$DEFINE QOn}{$Q-}{$ELSE}{$UNDEF QOn}{$ENDIF}

procedure TransformSHA512(var digest: T512BitBuf; const buf);
var
  i: Integer;
  P: P64BitBuf;
  W: array [0 .. 79] of T64BitBuf;
  T1, T2, T3, T4, K: T64BitBuf;
  H: array [0 .. 7] of T64BitBuf;
begin
  P := @buf;
  for i := 0 to 15 do
  begin
    W[i].value := ReverseByteOrder64(P.value);;
    Inc(P);
  end;

  for i := 16 to 79 do
  begin
    T1 := SHA512Transform4(W[i - 2]);
    T2 := W[i - 7];
    T3 := SHA512Transform3(W[i - 15]); // bug in RFC (specifies I-5 instead of W[I-5])
    T4 := W[i - 16];
    Inc(T1.value, T2.value);
    Inc(T1.value, T3.value);
    Inc(T1.value, T4.value);
    W[i] := T1;
  end;

  for i := 0 to 7 do
    H[i] := digest.qwords[i];
  for i := 0 to 79 do
  begin
    // T1 = h + BSIG1(e) + CH(e,f,g) + Kt + Wt
    T1 := H[7];
    Inc(T1.value, SHA512Transform2(H[4]).value);
    Inc(T1.value, SHA512Transform5(H[4].value, H[5].value, H[6].value));
    K.dwords[0].value := SHA512K[i * 2 + 1];
    K.dwords[1].value := SHA512K[i * 2];
    Inc(T1.value, K.value);
    Inc(T1.value, W[i].value);
    // T2 = BSIG0(a) + MAJ(a,b,c)
    T2 := SHA512Transform1(H[0]);
    Inc(T2.value, SHA512Transform6(H[0].value, H[1].value, H[2].value));
    // h = g    g = f
    // f = e    e = d + T1
    // d = c    c = b
    // b = a    a = T1 + T2
    H[7] := H[6];
    H[6] := H[5];
    H[5] := H[4];
    H[4] := H[3];
    Inc(H[4].value, T1.value);
    H[3] := H[2];
    H[2] := H[1];
    H[1] := H[0];
    H[0] := T1;
    Inc(H[0].value, T2.value);
  end;
  for i := 0 to 7 do
    Inc(digest.qwords[i].value, H[i].value);
end;

{$IFDEF QOn}{$Q+}{$ENDIF}

procedure TSHA512Context.finish;
var
  _totalLen: Int64;
begin
  _totalLen := ReverseByteOrder64(Self.TotalLen * 8);

  Self.buffer.bytes[Self.BufLen] := $80;
  Inc(Self.BufLen);

  if Self.BufLen <= 112 then
  begin
    FillChar(Self.buffer.bytes[Self.BufLen], 120 - Self.BufLen, 0);
    Move(_totalLen, Self.buffer.bytes[120], 8);
    TransformSHA512(Self.digest, Self.buffer);
  end
  else
  begin
    FillChar(Self.buffer.bytes[Self.BufLen], 128 - Self.BufLen, 0);
    TransformSHA512(Self.digest, Self.buffer);

    Self.buffer.qwords[0].value := 0;
    Self.buffer.qwords[1].value := 0;
    Self.buffer.qwords[2].value := 0;
    Self.buffer.qwords[3].value := 0;
    Self.buffer.qwords[4].value := 0;
    Self.buffer.qwords[5].value := 0;
    Self.buffer.qwords[6].value := 0;
    Self.buffer.qwords[7].value := 0;
    Self.buffer.qwords[8].value := 0;
    Self.buffer.qwords[9].value := 0;
    Self.buffer.qwords[10].value := 0;
    Self.buffer.qwords[11].value := 0;
    Self.buffer.qwords[12].value := 0;
    Self.buffer.qwords[13].value := 0;
    Self.buffer.qwords[14].value := 0;
    Self.buffer.qwords[15].value := _totalLen;

    TransformSHA512(Self.digest, Self.buffer);
  end;

  with Self.digest do
  begin
    qwords[0].value := ReverseByteOrder64(qwords[0].value);
    qwords[1].value := ReverseByteOrder64(qwords[1].value);
    qwords[2].value := ReverseByteOrder64(qwords[2].value);
    qwords[3].value := ReverseByteOrder64(qwords[3].value);
    qwords[4].value := ReverseByteOrder64(qwords[4].value);
    qwords[5].value := ReverseByteOrder64(qwords[5].value);
    qwords[6].value := ReverseByteOrder64(qwords[6].value);
    qwords[7].value := ReverseByteOrder64(qwords[7].value);
  end;
end;

procedure TSHA512Context.init;
begin
  digest.dwords[0].value := $F3BCC908;
  digest.dwords[1].value := $6A09E667;
  digest.dwords[2].value := $84CAA73B;
  digest.dwords[3].value := $BB67AE85;
  digest.dwords[4].value := $FE94F82B;
  digest.dwords[5].value := $3C6EF372;
  digest.dwords[6].value := $5F1D36F1;
  digest.dwords[7].value := $A54FF53A;
  digest.dwords[8].value := $ADE682D1;
  digest.dwords[9].value := $510E527F;
  digest.dwords[10].value := $2B3E6C1F;
  digest.dwords[11].value := $9B05688C;
  digest.dwords[12].value := $FB41BD6B;
  digest.dwords[13].value := $1F83D9AB;
  digest.dwords[14].value := $137E2179;
  digest.dwords[15].value := $5BE0CD19;
  Self.BufLen := 0;
  Self.TotalLen := 0;
end;

procedure TSHA512Context.update(const buf; BufSize: Integer);
var
  P: PByte;
  i, j, M: Integer;
begin
  if BufSize <= 0 then
    Exit;

  Inc(Self.TotalLen, BufSize);
  P := PByte(@buf);

  if Self.BufLen > 0 then
  begin
    M := 128 - Self.BufLen;
    if M > BufSize then
    begin
      Move(P^, Self.buffer.bytes[Self.BufLen], BufSize);
      Inc(Self.BufLen, BufSize);
      Exit;
    end
    else
    begin
      Move(P^, Self.buffer.bytes[Self.BufLen], M);
      TransformSHA512(Self.digest, Self.buffer);
      Self.BufLen := 0;
      Inc(P, M);
      Dec(BufSize, M);
      if BufSize = 0 then
        Exit;
    end;
  end;

  j := BufSize shr 7; // BufSize div 128;

  for i := 0 to j - 1 do
  begin
    TransformSHA512(Self.digest, P^);
    Inc(P, 128);
  end;

  j := BufSize and $7F;

  if j <> 0 then
  begin
    Move(P^, Self.buffer, j);
    Self.BufLen := j;
  end;
end;

function SHA512(const buf; BufSize: Integer): TSHA512Digest;
var
  ctx: TSHA512Context;
begin
  ctx.init;
  ctx.update(buf, BufSize);
  ctx.finish;
  Result := ctx.digest;
end;

function SHA512(const str: RawByteString): TSHA512Digest;
var
  ctx: TSHA512Context;
begin
  ctx.init;
  ctx.update(Pointer(str)^, Length(str));
  ctx.finish;
  Result := ctx.digest;
end;

function SHA512Stream(const Stream: TStream; len: Int64): TSHA512Digest;
var
  context: TSHA512Context;
  buffer: array [0 .. 4095] of Byte;
  ReadBytes: Integer;
  Bookmark: Int64;
begin
  context.init;
  Bookmark := Stream.Position;
  if (len <= 0) or (len > Stream.Size - Bookmark) then
    len := Stream.Size - Bookmark;
  try
    while len > 0 do
    begin
      ReadBytes := SizeOf(buffer);
      if ReadBytes > len then
        ReadBytes := len;
      ReadBytes := Stream.Read(buffer, ReadBytes);
      context.update(buffer, ReadBytes);
      Dec(len, ReadBytes);
    end;
    context.finish;
    Result := context.digest;
  finally
    Stream.Position := Bookmark;
  end;
end;

function SHA512File(const FileName: string): TSHA512Digest;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := SHA512Stream(Stream);
  finally
    Stream.Free;
  end;
end;

{$ENDREGION}
{$REGION 'sha384 implementation'}

{ TSHA384Context }

procedure TSHA384Context.finish;
begin
  _512.finish;
  Move(_512.digest, Self.digest, SizeOf(Self.digest));
end;

procedure TSHA384Context.init;
begin
  _512.digest.dwords[0].value := $C1059ED8;
  _512.digest.dwords[1].value := $CBBB9D5D;
  _512.digest.dwords[2].value := $367CD507;
  _512.digest.dwords[3].value := $629A292A;
  _512.digest.dwords[4].value := $3070DD17;
  _512.digest.dwords[5].value := $9159015A;
  _512.digest.dwords[6].value := $F70E5939;
  _512.digest.dwords[7].value := $152FECD8;
  _512.digest.dwords[8].value := $FFC00B31;
  _512.digest.dwords[9].value := $67332667;
  _512.digest.dwords[10].value := $68581511;
  _512.digest.dwords[11].value := $8EB44A87;
  _512.digest.dwords[12].value := $64F98FA7;
  _512.digest.dwords[13].value := $DB0C2E0D;
  _512.digest.dwords[14].value := $BEFA4FA4;
  _512.digest.dwords[15].value := $47B5481D;
  _512.BufLen := 0;
  _512.TotalLen := 0;
end;

procedure TSHA384Context.update(const buf; BufSize: Integer);
begin
  _512.update(buf, BufSize);
end;

function SHA384(const buf; BufSize: Integer): TSHA384Digest;
var
  ctx: TSHA384Context;
begin
  ctx.init;
  ctx.update(buf, BufSize);
  ctx.finish;
  Result := ctx.digest;
end;

function SHA384(const str: RawByteString): TSHA384Digest;
var
  ctx: TSHA384Context;
begin
  ctx.init;
  ctx.update(Pointer(str)^, Length(str));
  ctx.finish;
  Result := ctx.digest;
end;

function SHA384Stream(const Stream: TStream; len: Int64): TSHA384Digest;
var
  context: TSHA384Context;
  buffer: array [0 .. 4095] of Byte;
  ReadBytes: Integer;
  Bookmark: Int64;
begin
  context.init;
  Bookmark := Stream.Position;
  if (len <= 0) or (len > Stream.Size - Bookmark) then
    len := Stream.Size - Bookmark;
  try
    while len > 0 do
    begin
      ReadBytes := SizeOf(buffer);
      if ReadBytes > len then
        ReadBytes := len;
      ReadBytes := Stream.Read(buffer, ReadBytes);
      context.update(buffer, ReadBytes);
      Dec(len, ReadBytes);
    end;
    context.finish;
    Result := context.digest;
  finally
    Stream.Position := Bookmark;
  end;
end;

function SHA384File(const FileName: string): TSHA384Digest;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := SHA384Stream(Stream);
  finally
    Stream.Free;
  end;
end;

{$ENDREGION}
{$REGION 'hmac_sha256 implementation'}

{ THMAC_SHA256Context }

function THMAC_SHA256Context.finish: TSHA256Digest;
var
  ctx: TSHA256Context;
  outerPadding: T512BitBuf;
begin
  hashctx.finish;
  xor_32bit_array(keyBlock, outerPadding, $5C5C5C5C, Length(keyBlock.dwords));
  ctx.init;
  ctx.update(keyBlock, SizeOf(keyBlock));
  ctx.update(hashctx.digest, SizeOf(hashctx.digest));
  ctx.finish;
  Result := ctx.digest;
end;

procedure THMAC_SHA256Context.init(const key; const keyLen: Integer);
var
  innerPadding: T512BitBuf;
  kd: TSHA256Digest;
begin
  hashctx.init;
  FillChar(Self.keyBlock, SizeOf(Self.keyBlock), 0);

  if keyLen > 64 then
  begin
    kd := SHA256(key, keyLen);
    Move(kd, keyBlock, SizeOf(kd));
  end
  else
    Move(key, keyBlock, keyLen);

  xor_32bit_array(keyBlock, innerPadding, $36363636, Length(keyBlock.dwords));
  hashctx.update(innerPadding, SizeOf(innerPadding));
end;

procedure THMAC_SHA256Context.reset;
var
  innerPadding: T512BitBuf;
begin
  hashctx.init;
  xor_32bit_array(keyBlock, innerPadding, $36363636, Length((keyBlock.dwords)));
  hashctx.update(innerPadding, SizeOf(innerPadding));
end;

procedure THMAC_SHA256Context.update(const buf; BufSize: Integer);
begin
  hashctx.update(buf, BufSize);
end;

function HMAC_SHA256(const key; keyLen: Integer; const buf; BufSize: Integer): TSHA256Digest;
var
  ctx: THMAC_SHA256Context;
begin
  ctx.init(key, keyLen);
  ctx.update(buf, BufSize);
  Result := ctx.finish;
end;

function HMAC_SHA256(const key, data: RawByteString): TSHA256Digest; overload;
var
  ctx: THMAC_SHA256Context;
begin
  ctx.init(Pointer(key)^, Length(key));
  ctx.update(Pointer(data)^, Length(data));
  Result := ctx.finish;
end;

{$ENDREGION}
{$REGION 'hmac_sha512 implementation'}

{ THMAC_SHA512Context }

function THMAC_SHA512Context.finish: TSHA512Digest;
var
  ctx: TSHA512Context;
  outerPadding: T1024BitBuf;
begin
  hashctx.finish;
  xor_32bit_array(keyBlock, outerPadding, $5C5C5C5C, Length((keyBlock.dwords)));
  ctx.init;
  ctx.update(keyBlock, SizeOf(keyBlock));
  ctx.update(hashctx.digest, SizeOf(hashctx.digest));
  ctx.finish;
  Result := ctx.digest;
end;

procedure THMAC_SHA512Context.init(const key; const keyLen: Integer);
var
  innerPadding: T1024BitBuf;
  kd: TSHA512Digest;
begin
  hashctx.init;
  FillChar(Self.keyBlock, SizeOf(Self.keyBlock), 0);

  if keyLen > SizeOf(Self.keyBlock) then
  begin
    kd := SHA512(key, keyLen);
    Move(kd, keyBlock, SizeOf(kd));
  end
  else
    Move(key, keyBlock, keyLen);

  xor_32bit_array(keyBlock, innerPadding, $36363636, Length((keyBlock.dwords)));
  hashctx.update(innerPadding, SizeOf(innerPadding));
end;

procedure THMAC_SHA512Context.reset;
var
  innerPadding: T1024BitBuf;
begin
  hashctx.init;
  xor_32bit_array(keyBlock, innerPadding, $36363636, Length((keyBlock.dwords)));
  hashctx.update(innerPadding, SizeOf(innerPadding));
end;

procedure THMAC_SHA512Context.update(const buf; BufSize: Integer);
begin
  hashctx.update(buf, BufSize);
end;

function HMAC_SHA512(const key; keyLen: Integer; const buf; BufSize: Integer): TSHA512Digest;
var
  ctx: THMAC_SHA512Context;
begin
  ctx.init(key, keyLen);
  ctx.update(buf, BufSize);
  Result := ctx.finish;
end;

function HMAC_SHA512(const key, data: RawByteString): TSHA512Digest; overload;
var
  ctx: THMAC_SHA512Context;
begin
  ctx.init(Pointer(key)^, Length(key));
  ctx.update(Pointer(data)^, Length(data));
  Result := ctx.finish;
end;

{$REGION}

initialization

CRC32_InitTable;

end.
