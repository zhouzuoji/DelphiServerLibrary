unit DSLHashUtils;

interface

uses
  SysUtils, Classes, AnsiStrings, Generics.Defaults;


function RSHash32(buf: PAnsiChar; len: Integer): Integer;
function JSHash32(buf: PAnsiChar; len: Integer): Integer;
function PJWHash32(buf: PAnsiChar; len: Integer): Integer;
function ELFHash32(buf: PAnsiChar; len: Integer): Integer;
function BKDRHash32(buf: PAnsiChar; len: Integer): Integer;
function SDBMHash32(buf: PAnsiChar; len: Integer): Integer;
function DJBHash32(buf: PAnsiChar; len: Integer): Integer;
function APHash32(buf: PAnsiChar; len: Integer): Integer;

function GetCaseInsensitiveUnicodeComparer: IEqualityComparer<UnicodeString>;
function GetCaseInsensitiveMbcsComparer: IEqualityComparer<RawByteString>;

implementation


function RSHash32(buf: PAnsiChar; len: Integer): Integer;
var
  a, b, hash: Integer;
  i: Integer;
begin
  b := 378551;
  a := 63689;
  hash := 0;
  for i := 0 to len - 1 do
  begin
    hash := hash * a + Byte(buf[i]);
    a := a * b;
  end;
  Result := hash and $7FFFFFFF;
end;

function JSHash32(buf: PAnsiChar; len: Integer): Integer;
var
  hash: Integer;
  i: Integer;
begin
  hash := 1315423911;
  for i := 0 to len - 1 do
    hash := hash xor ((hash shl 5) + Byte(buf[i]) + (hash shr 2));
  Result := hash and $7FFFFFFF;
end;

function PJWHash32(buf: PAnsiChar; len: Integer): Integer;
const
  BitsInUnignedInt = SizeOf(Integer) * 8;
  ThreeQuarters = (BitsInUnignedInt * 3) div 4;
  OneEighth = BitsInUnignedInt div 8;
  HighBits = $FFFFFFFF shl (BitsInUnignedInt - OneEighth);
var
  hash, flag: Integer;
  i: Integer;
begin
  hash := 0;
  for i := 0 to len - 1 do
  begin
    hash := (hash shl OneEighth) + Byte(buf[i]);
    flag := hash and HighBits;
    if (flag <> 0) then
      hash := ((hash xor (flag shr ThreeQuarters)) and (not HighBits));
  end;
  Result := hash and $7FFFFFFF;
end;

function ELFHash32(buf: PAnsiChar; len: Integer): Integer;
var
  hash, x: Integer;
  i: Integer;
begin
  hash := 0;
  for i := 0 to len - 1 do
  begin
    hash := (hash shl 4) + Byte(buf[i]);
    x := hash and $F0000000;
    if x <> 0 then
    begin
      hash := hash xor (x shr 24);
      hash := hash and not x;
    end;
  end;
  Result := hash and $7FFFFFFF;
end;

function BKDRHash32(buf: PAnsiChar; len: Integer): Integer;
var
  hash, seed: Integer;
  i: Integer;
begin
  seed := 131; // 31 131 1313 13131 131313 etc..
  hash := 0;
  for i := 0 to len - 1 do
    hash := hash * seed + Byte(buf[i]);
  Result := hash and $7FFFFFFF;
end;

function SDBMHash32(buf: PAnsiChar; len: Integer): Integer;
var
  hash: Integer;
  i: Integer;
begin
  hash := 0;
  for i := 0 to len - 1 do
    hash := Byte(buf[i]) + (hash shl 6) + (hash shl 16) - hash;
  Result := hash and $7FFFFFFF;
end;

function DJBHash32(buf: PAnsiChar; len: Integer): Integer;
var
  hash: Integer;
  i: Integer;
begin
  hash := 5381;
  for i := 0 to len - 1 do
    hash := hash + (hash shl 5) + Byte(buf[i]);
  Result := hash and $7FFFFFFF;
end;

function APHash32(buf: PAnsiChar; len: Integer): Integer;
var
  hash: Integer;
  i: Integer;
begin
  hash := 0;
  for i := 0 to len - 1 do
  begin
    if ((i and 1) = 0) then
      hash := hash xor ((hash shl 7) xor Byte(buf[i]) xor (hash shr 3))
    else
      hash := hash xor (not((hash shl 11) xor Byte(buf[i]) xor (hash shr 5)));
  end;
  Result := hash and $7FFFFFFF;
end;

type
  TRBStrEqualityComparer = class(TInterfacedObject, IEqualityComparer<RawByteString>)
  public
    function Equals(const avLeft, avRight: RawByteString): Boolean; reintroduce; overload;
    function GetHashCode(const avValue: RawByteString): Integer; reintroduce; overload;
  end;

  TUStrEqualityComparer = class(TInterfacedObject, IEqualityComparer<UnicodeString>)
  public
    function Equals(const avLeft, avRight: UnicodeString): Boolean; reintroduce; overload;
    function GetHashCode(const avValue: UnicodeString): Integer; reintroduce; overload;
  end;

var
  g_RBStrEqualityComparer: IEqualityComparer<RawByteString>;
  g_UStrEqualityComparer: IEqualityComparer<UnicodeString>;

function GetCaseInsensitiveUnicodeComparer: IEqualityComparer<UnicodeString>;
begin
  Result := g_UStrEqualityComparer;
end;

function GetCaseInsensitiveMbcsComparer: IEqualityComparer<RawByteString>;
begin
  Result := g_RBStrEqualityComparer;
end;


{ TRBStrEqualityComparer }

function TRBStrEqualityComparer.Equals(const avLeft, avRight: RawByteString): Boolean;
begin
  Result := AnsiStrings.SameStr(avLeft, avRight);
end;

function TRBStrEqualityComparer.GetHashCode(const avValue: RawByteString): Integer;
begin
  Result := ELFHash32(PAnsiChar(avValue), Length(avValue));
end;

{ TUStrEqualityComparer }

function TUStrEqualityComparer.Equals(const avLeft, avRight: UnicodeString): Boolean;
begin
  Result := avLeft = avRight;
end;

function TUStrEqualityComparer.GetHashCode(const avValue: UnicodeString): Integer;
begin
  Result := ELFHash32(PAnsiChar(Pointer(avValue)), Length(avValue) * 2);
end;

end.
