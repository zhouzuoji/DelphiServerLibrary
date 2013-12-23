unit DSLBase64;

interface

const
  BASE64_ALPHABETS: array[0..64] of AnsiChar =
  ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3',
    '4', '5', '6', '7', '8', '9', '+', '/', '=');

  BASE64_ALPHABET_INDEXES: array[43..122] of Byte =
  (62, 255, 255, 255, 63, 52, 53, 54,
    55, 56, 57, 58, 59, 60, 61, 255,
    255, 255, 64, 255, 255, 255, 0, 1,
    2, 3, 4, 5, 6, 7, 8, 9,
    10, 11, 12, 13, 14, 15, 16, 17,
    18, 19, 20, 21, 22, 23, 24, 25,
    255, 255, 255, 255, 255, 255, 26, 27,
    28, 29, 30, 31, 32, 33, 34, 35,
    36, 37, 38, 39, 40, 41, 42, 43,
    44, 45, 46, 47, 48, 49, 50, 51);

function Base64Encode(Input: Pointer; InputSize: Integer; Output: Pointer): Integer; overload;
function Base64Encode(Input: Pointer; InputSize: Integer): AnsiString; overload;
function Base64Encode(const Input: AnsiString): AnsiString; overload;

function Base64Decode(Input: Pointer; InputSize: Integer; Output: Pointer): Integer; overload;
function Base64Decode(const Input: AnsiString; Output: Pointer): Integer; overload;
function Base64Decode(const Input: AnsiString): AnsiString; overload;

implementation

type
  FourBytes = array[0..3] of Byte;
  ThreeBytes = array[0..2] of Byte;
  PFourBytes = ^FourBytes;
  PThreeBytes = ^ThreeBytes;

function Base64Encode(Input: Pointer; InputSize: Integer;
  Output: Pointer): Integer;
var
  IPtr: PThreeBytes;
  OPtr: PFourBytes;
  IEnd: LongInt;
begin
  Result := (InputSize + 2) div 3 * 4;
  if Output = nil then Exit;
  IPtr := PThreeBytes(Input);
  OPtr := PFourBytes(Output);
  IEnd := LongInt(Input) + InputSize;
  while IEnd > Integer(IPtr) do
  begin
    OPtr[0] := IPtr[0] shr 2;
    OPtr[1] := (IPtr[0] shl 4) and $30;
    if IEnd - Integer(IPtr) > 2 then
    begin
      OPtr[1] := OPtr[1] or (IPtr[1] shr 4);
      OPtr[2] := (IPtr[1] shl 2) and $3F;
      OPtr[2] := OPtr[2] or IPtr[2] shr 6;
      OPtr[3] := IPtr[2] and $3F;
    end
    else if IEnd - Integer(IPtr) > 1 then
    begin
      OPtr[1] := OPtr[1] or (IPtr[1] shr 4);
      OPtr[2] := (IPtr[1] shl 2) and $3F;
      OPtr[3] := 64;
    end
    else begin
      OPtr[2] := 64;
      OPtr[3] := 64;
    end;

    OPtr[0] := Ord(BASE64_ALPHABETS[OPtr[0]]);
    OPtr[1] := Ord(BASE64_ALPHABETS[OPtr[1]]);
    OPtr[2] := Ord(BASE64_ALPHABETS[OPtr[2]]);
    OPtr[3] := Ord(BASE64_ALPHABETS[OPtr[3]]);

    Inc(IPtr);
    Inc(OPtr);
  end;
end;

function Base64Encode(Input: Pointer; InputSize: Integer): AnsiString; overload;
begin
  SetLength(Result, (InputSize + 2) div 3 * 4);
  Base64Encode(Input, InputSize, Pointer(Result));
end;

function Base64Encode(const Input: AnsiString): AnsiString; overload;
begin
  SetLength(Result, (Length(Input) + 2) div 3 * 4);
  Base64Encode(Pointer(Input), Length(Input), Pointer(Result));
end;

function Base64Decode(Input: Pointer; InputSize: Integer;
  Output: Pointer): Integer;
var
  IPtr: PFourBytes;
  OPtr: PThreeBytes;
  i: Integer;
begin
  Result := (InputSize div 4) * 3;
  if PAnsiChar(Input)[InputSize - 2] = '=' then Dec(Result, 2)
  else if PAnsiChar(Input)[InputSize - 1] = '=' then Dec(Result);
  if Output = nil then Exit;
  IPtr := PFourBytes(Input);
  OPtr := PThreeBytes(Output);
  for i := 1 to InputSize div 4 do
  begin
    IPtr[0] := BASE64_ALPHABET_INDEXES[IPtr[0]];
    IPtr[1] := BASE64_ALPHABET_INDEXES[IPtr[1]];
    IPtr[2] := BASE64_ALPHABET_INDEXES[IPtr[2]];
    IPtr[3] := BASE64_ALPHABET_INDEXES[IPtr[3]];
    OPtr[0] := (IPtr[0] shl 2) or (IPtr[1] shr 4);
    if (IPtr[2] <> 64) then
    begin
      OPtr[1] := (IPtr[1] shl 4) or (IPtr[2] shr 2);
    end;

    if (IPtr[3] <> 64) then
    begin
      OPtr[2] := (IPtr[2] shl 6) or IPtr[3];
    end;

    Inc(IPtr);
    Inc(OPtr);
  end;
end;

function Base64Decode(const Input: AnsiString;
  Output: Pointer): Integer; overload;
begin
  Result := Base64Decode(Pointer(Input), Length(Input), Output);
end;

function Base64Decode(const Input: AnsiString): AnsiString; overload;
var
  InputSize: Integer;
  OutputSize: Integer;
begin
  InputSize := Length(Input);
  if Input[InputSize] = #0 then Dec(InputSize);
  OutputSize := (InputSize div 4) * 3;
  if Input[InputSize - 1] = '=' then Dec(OutputSize, 2)
  else if Input[InputSize] = '=' then Dec(OutputSize);
  SetLength(Result, OutputSize);
  Base64Decode(Pointer(Input), InputSize, Pointer(Result));
end;

end.
