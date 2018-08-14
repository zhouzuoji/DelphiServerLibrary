unit DSLUnicodeFunctions;

interface

uses
  SysUtils, Classes;

type
  UnicodeString = WideString;
  PUnicodeString = ^UnicodeString;
  RawByteString = AnsiString;
  PRawByteString = ^RawByteString;

  TUnicodeStringStream = class(TStream)
  private
    FDataString: UnicodeString;
    FSize: Integer;
    FPosition: Integer;
  protected
    procedure SetSize(NewSize: Longint); override;
  public
    constructor Create(const AString: UnicodeString);
    function Read(var Buffer; Count: Longint): Longint; override;
    function ReadString(Count: Longint): UnicodeString;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure WriteString(const AString: UnicodeString);
    property DataString: UnicodeString read FDataString;
  end;
 
function _UStrFormatFloat(const Format: UnicodeString; Value: Extended): UnicodeString;
 
implementation

function _UStrFormatFloat(const Format: UnicodeString; Value: Extended): UnicodeString;
begin
  Result := FormatFloat(Format, Value);
end;

{ TUnicodeStringStream }

constructor TUnicodeStringStream.Create(const AString: UnicodeString);
begin
  inherited Create;
  FDataString := AString;
  FSize := Length(FDataString) * 2;
end;

function TUnicodeStringStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := FSize - FPosition;
  if Result > Count then Result := Count;
  Move(PAnsiChar(Pointer(FDataString))[FPosition], Buffer, Result);
  Inc(FPosition, Result);
end;

function TUnicodeStringStream.Write(const Buffer; Count: Longint): Longint;
begin
  if FPosition + Count > FSize then SetSize(FPosition + Count);
  SetSize(FPosition + Count);
  Move(Buffer, PAnsiChar(Pointer(FDataString))[FPosition], Count);
  Inc(FPosition, Count);
  Result := Count;
end;

function TUnicodeStringStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: FPosition := FPosition + Offset;
    soFromEnd: FPosition := FSize - Offset;
  end;
  
  if FPosition > FSize then FPosition := FSize
  else if FPosition < 0 then FPosition := 0;
  Result := FPosition;
end;

function TUnicodeStringStream.ReadString(Count: Longint): UnicodeString;
var
  Len: Integer;
begin
  Len := FSize - FPosition;
  if Len > Count * 2 then Len := Count * 2;
  Len := Len and not 1;
  
  SetString(Result, PWideChar(PAnsiChar(Pointer(FDataString)) + FPosition), Len div 2);
  Inc(FPosition, Len);
end;

procedure TUnicodeStringStream.WriteString(const AString: UnicodeString);
begin
  Write(Pointer(AString)^, Length(AString) * SizeOf(WideChar));
end;

procedure TUnicodeStringStream.SetSize(NewSize: Longint);
begin
  FSize := NewSize;
  SetLength(FDataString, (FSize + 1) div 2);
  if FPosition > NewSize then FPosition := NewSize;
end;
	
end.