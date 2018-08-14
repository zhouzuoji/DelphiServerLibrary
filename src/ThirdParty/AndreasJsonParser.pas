(*****************************************************************************
The MIT License (MIT)

Copyright (c) 2015-2016 Andreas Hausladen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*****************************************************************************)

{$POINTERMATH ON}

unit AndreasJsonParser;

{$IFDEF VER200}
  // Delphi 2009's ErrorInsight parser uses the CompilerVersion's memory address instead of 20.0, failing all the
  // IF CompilerVersion compiler directives
  {$DEFINE CPUX86}
{$ELSE}
  {$IF CompilerVersion >= 24.0} // XE3 or newer
    {$LEGACYIFEND ON}
  {$IFEND}
  {$IF CompilerVersion <= 22.0} // XE or older
    {$DEFINE CPUX86}
  {$IFEND}
{$ENDIF VER200}


// Enables the progress callback feature
{$DEFINE SUPPORT_PROGRESS}

{$IFDEF MSWINDOWS}
  // Reading a large file >64 MB from a network drive in Windows 2003 Server or older can lead to
  // an INSUFFICIENT RESOURCES error. By enabling this switch, large files are read in 20 MB blocks.
  {$DEFINE WORKAROUND_NETWORK_FILE_INSUFFICIENT_RESOURCES}

  // If defined, the TzSpecificLocalTimeToSystemTime is imported with GetProcAddress and if it is
  // not available (Windows 2000) an alternative implementation is used.
  {$DEFINE SUPPORT_WINDOWS2000}

{$ENDIF MSWINDOWS}

interface

uses
  SysUtils, Classes, DSLUtils, DSLPortableData;

type
  EJsonException = class(Exception);
  EJsonCastException = class(EJsonException);
  EJsonPathException = class(EJsonException);

  // TEncodingStrictAccess gives us access to the strict protected functions which are much easier
  // to use with TJsonStringBuilder than converting FData to a dynamic TCharArray.
  TEncodingStrictAccess = class(TEncoding)
  public
    function GetByteCountEx(Chars: PChar; CharCount: Integer): Integer; inline;
    function GetBytesEx(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer; inline;
    function GetCharCountEx(Bytes: PByte; ByteCount: Integer): Integer; inline;
    function GetCharsEx(Bytes: PByte; ByteCount: Integer; Chars: PChar; CharCount: Integer): Integer; inline;
  end;

  EJsonParserException = class(EJsonException)
  private
    FColumn: NativeInt;
    FPosition: NativeInt;
    FLineNum: NativeInt;
  public
    constructor CreateResFmt(ResStringRec: PResStringRec; const Args: array of const; ALineNum, AColumn, APosition: NativeInt);
    constructor CreateRes(ResStringRec: PResStringRec; ALineNum, AColumn, APosition: NativeInt);

    property LineNum: NativeInt read FLineNum;   // base 1
    property Column: NativeInt read FColumn;     // base 1
    property Position: NativeInt read FPosition; // base 0  Utf8Char/WideChar index
  end;

  {$IFDEF SUPPORT_PROGRESS}
  TJsonReaderProgressProc = procedure(Data: Pointer; Percentage: Integer; Position, Size: NativeInt);

  PJsonReaderProgressRec = ^TJsonReaderProgressRec;
  TJsonReaderProgressRec = record
    Data: Pointer;        // used for the first Progress() parameter
    Threshold: NativeInt; // 0: Call only if percentage changed; greater than 0: call after n processed bytes
    Progress: TJsonReaderProgressProc;

    function Init(AProgress: TJsonReaderProgressProc; AData: Pointer = nil; AThreshold: NativeInt = 0): PJsonReaderProgressRec;
  end;
  {$ENDIF SUPPORT_PROGRESS}

  TJsonSerializationConfig = record
    LineBreak: string;
    IndentChar: string;
    UseUtcTime: Boolean;
    NullConvertsToValueTypes: Boolean;
  end;

var
  JsonSerializationConfig: TJsonSerializationConfig = ( // not thread-safe
    LineBreak: #10;
    IndentChar: #9;
    UseUtcTime: True;
    NullConvertsToValueTypes: False;  // If True and an object is nil/null, a convertion to String, Int, Long, Float, DateTime, Boolean will return ''/0/False
  );

procedure FromJson(var body: TPortableValue; S: PWideChar; Len: Integer
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}
  ); overload;

procedure FromJson(var body: TPortableValue; const S: UnicodeString
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}
  ); overload; inline;

function ParseJson(S: PWideChar; Len: Integer
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}
  ): TPortableValue; overload;

function ParseJson(const S: UnicodeString
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}
  ): TPortableValue; overload; inline;

function ParseJson(const Bytes: TBytes; Encoding: TEncoding; ByteIndex: Integer;
  ByteCount: Integer{$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}
  ): TPortableValue; overload;

procedure FromJsonUtf8(var body: TPortableValue; S: PByte; Len: Integer
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}); overload;

procedure FromJsonUtf8(var body: TPortableValue; const s: RawByteString
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}); overload; inline;

function ParseJsonUtf8(S: PByte; Len: Integer
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}
  ): TPortableValue; overload;

function ParseJsonUtf8(const s: RawByteString
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}
  ): TPortableValue; overload; inline;

function ParseJsonStream(Stream: TStream; Encoding: TEncoding; Utf8WithoutBOM: Boolean
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}): TPortableValue;

procedure LoadFromStream(var body: TPortableValue; Stream: TStream; Encoding: TEncoding; Utf8WithoutBOM: Boolean
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF});

function ParseFromFile(const FileName: string; Utf8WithoutBOM: Boolean
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}
  ): TPortableValue;

procedure LoadFromFile(var body: TPortableValue; const FileName: string; Utf8WithoutBOM: Boolean
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec = nil{$ENDIF}
  );

implementation

uses
  {$IFDEF HAS_UNIT_SCOPE}
    {$IFDEF MSWINDOWS}
  Winapi.Windows,
    {$ELSE}
  System.DateUtils,
    {$ENDIF MSWINDOWS}
  System.Variants, System.RTLConsts, System.TypInfo, System.Math, System.SysConst;
  {$ELSE}
    {$IFDEF MSWINDOWS}
  Windows,
    {$ELSE}
  DateUtils,
    {$ENDIF MSWINDOWS}
  Variants, RTLConsts, TypInfo, Math, SysConst;
  {$ENDIF HAS_UNIT_SCOPE}

resourcestring
  RsUnsupportedFileEncoding = 'File encoding is not supported';
  RsUnexpectedEndOfFile = 'Unexpected end of file where %s was expected';
  RsUnexpectedToken = 'Expected %s but found %s';
  RsInvalidStringCharacter = 'Invalid character in string';
  RsStringNotClosed = 'String not closed';
  RsInvalidHexNumber = 'Invalid hex number "%s"';
  RsTypeCastError = 'Cannot cast %s into %s';
  RsMissingClassInfo = 'Class "%s" doesn''t have type information. {$M+} was not specified';
  RsInvalidJsonPath = 'Invalid Json path "%s"';
  RsJsonPathContainsNullValue = 'Json path contains null value ("%s")';
  RsJsonPathIndexError = 'Json path index out of bounds (%d) "%s"';
  RsVarTypeNotSupported = 'VarType %d is not supported';

type
  TJsonTokenKind = (
    jtkEof, jtkInvalidSymbol,
    jtkLBrace, jtkRBrace, jtkLBracket, jtkRBracket, jtkComma, jtkColon,
    jtkIdent,
    jtkValue, jtkString, jtkInt, jtkLong, jtkULong, jtkFloat, jtkTrue, jtkFalse, jtkNull
  );

const
  JsonTokenKindToStr: array[TJsonTokenKind] of string = (
    'end of file', 'invalid symbol',
    '"{"', '"}"', '"["', '"]"', '","', '":"',
    'identifier',
    'value', 'value', 'value', 'value', 'value', 'value', 'value', 'value', 'value'
  );

  Power10: array[0..18] of Double = (
    1E0, 1E1, 1E2, 1E3, 1E4, 1E5, 1E6, 1E7, 1E8, 1E9,
    1E10, 1E11, 1E12, 1E13, 1E14, 1E15, 1E16, 1E17, 1E18
  );

  //sNull = 'null';
  //sQuoteChar = '"';

  {$IF not declared(varObject)}
  varObject = $0049;
  {$IFEND}

type
  TJsonToken = record
    Kind: TJsonTokenKind;
    S: string; // jtkIdent/jtkString
    case Integer of
      0: (I: Integer; HI: Integer);
      1: (L: Int64);
      2: (U: UInt64);
      3: (F: Double);
  end;

  TJsonReader = class(TObject)
  private
    FPropName: string;
    procedure Accept(TokenKind: TJsonTokenKind);
    procedure ParseObjectBody(const Data: TPortableObject);
    procedure ParseObjectProperty(const Data: TPortableObject);
    procedure ParseObjectPropertyValue(const Data: TPortableObject);
    procedure ParseArrayBody(const Data: TPortableArray);
    procedure ParseArrayPropertyValue(const Data: TPortableArray);
    procedure AcceptFailed(TokenKind: TJsonTokenKind);
  protected
    FLook: TJsonToken;
    FLineNum: Integer;
    FStart: Pointer;
    FLineStart: Pointer;
    {$IFDEF SUPPORT_PROGRESS}
    FLastProgressValue: NativeInt;
    FSize: NativeInt;
    FProgress: PJsonReaderProgressRec;
    procedure CheckProgress(Position: Pointer);
    {$ENDIF SUPPORT_PROGRESS}
    function GetLineColumn: NativeInt;
    function GetPosition: NativeInt;
    function GetCharOffset(StartPos: Pointer): NativeInt; virtual; abstract;
    function Next: Boolean; virtual; abstract;

    class procedure InvalidStringCharacterError(const Reader: TJsonReader); static;
    class procedure StringNotClosedError(const Reader: TJsonReader); static;
    class procedure JsonStrToStr(P, EndP: PChar; FirstEscapeIndex: Integer; var S: string;
      const Reader: TJsonReader); static;
    class procedure JsonUtf8StrToStr(P, EndP: PByte; FirstEscapeIndex: Integer; var S: string;
      const Reader: TJsonReader); static;
  public
    constructor Create(AStart: Pointer{$IFDEF SUPPORT_PROGRESS}; ASize: NativeInt; AProgress: PJsonReaderProgressRec{$ENDIF});
    destructor Destroy; override;
    procedure Parse(var Data: TPortableValue);
  end;

  TUtf8JsonReader = class sealed(TJsonReader)
  private
    FText: PByte;
    FTextEnd: PByte;
  protected
    function GetCharOffset(StartPos: Pointer): NativeInt; override; final;
    function Next: Boolean; override; final;
    // ARM optimization: Next() already has EndP in a local variable so don't use the slow indirect
    // access to FTextEnd.
    procedure LexString(P: PByte{$IFDEF CPUARM}; EndP: PByte{$ENDIF});
    procedure LexNumber(P: PByte{$IFDEF CPUARM}; EndP: PByte{$ENDIF});
    procedure LexIdent(P: PByte{$IFDEF CPUARM}; EndP: PByte{$ENDIF});
  public
    constructor Create(S: PByte; Len: NativeInt{$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF});
  end;

  TStringJsonReader = class sealed(TJsonReader)
  private
    FText: PChar;
    FTextEnd: PChar;
  protected
    function GetCharOffset(StartPos: Pointer): NativeInt; override; final;
    function Next: Boolean; override; final;
    // ARM optimization: Next() already has EndP in a local variable so don't use the slow indirect
    // access to FTextEnd.
    procedure LexString(P: PChar{$IFDEF CPUARM}; EndP: PChar{$ENDIF});
    procedure LexNumber(P: PChar{$IFDEF CPUARM}; EndP: PChar{$ENDIF});
    procedure LexIdent(P: PChar{$IFDEF CPUARM}; EndP: PChar{$ENDIF});
  public
    constructor Create(S: PChar; Len: Integer{$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF});
  end;

  TMemoryStreamAccess = class(TMemoryStream);


var
  JsonFormatSettings: TFormatSettings;

{$IFDEF MSWINDOWS}

  {$IFDEF SUPPORT_WINDOWS2000}
var
  TzSpecificLocalTimeToSystemTime: function(lpTimeZoneInformation: PTimeZoneInformation;
    var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall;

function TzSpecificLocalTimeToSystemTimeWin2000(lpTimeZoneInformation: PTimeZoneInformation;
  var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall;
var
  TimeZoneInfo: TTimeZoneInformation;
begin
  if lpTimeZoneInformation <> nil then
    TimeZoneInfo := lpTimeZoneInformation^
  else
    GetTimeZoneInformation(TimeZoneInfo);

  // Reverse the bias so that SystemTimeToTzSpecificLocalTime becomes TzSpecificLocalTimeToSystemTime
  TimeZoneInfo.Bias := -TimeZoneInfo.Bias;
  TimeZoneInfo.StandardBias := -TimeZoneInfo.StandardBias;
  TimeZoneInfo.DaylightBias := -TimeZoneInfo.DaylightBias;

  Result := SystemTimeToTzSpecificLocalTime(@TimeZoneInfo, lpLocalTime, lpUniversalTime);
end;
  {$ELSE}
function TzSpecificLocalTimeToSystemTime(lpTimeZoneInformation: PTimeZoneInformation;
  var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall;
  external kernel32 name 'TzSpecificLocalTimeToSystemTime';
  {$ENDIF SUPPORT_WINDOWS2000}

{$ENDIF MSWINDOWS}

{$IFDEF USE_NAME_STRING_LITERAL}
procedure InitializeJsonMemInfo;
var
  MemInfo: TMemoryBasicInformation;
begin
  JsonMemInfoInitialized := True;
  if VirtualQuery(PByte(HInstance + $1000), MemInfo, SizeOf(MemInfo)) = SizeOf(MemInfo) then
  begin
    JsonMemInfoBlockStart := MemInfo.AllocationBase;
    JsonMemInfoBlockEnd := JsonMemInfoBlockStart + MemInfo.RegionSize;
  end;
  if HInstance <> MainInstance then
  begin
    if VirtualQuery(PByte(MainInstance + $1000), MemInfo, SizeOf(MemInfo)) = SizeOf(MemInfo) then
    begin
      JsonMemInfoMainBlockStart := MemInfo.AllocationBase;
      JsonMemInfoMainBlockEnd := JsonMemInfoBlockStart + MemInfo.RegionSize;
    end;
  end;
end;
{$ENDIF USE_NAME_STRING_LITERAL}

{ EJsonParserSyntaxException }

constructor EJsonParserException.CreateResFmt(ResStringRec: PResStringRec; const Args: array of const;
  ALineNum, AColumn, APosition: NativeInt);
begin
  inherited CreateResFmt(ResStringRec, Args);
  FLineNum := ALineNum;
  FColumn := AColumn;
  FPosition := APosition;
  if FLineNum > 0 then
    Message := Format('%s (%d, %d)', [Message, FLineNum, FColumn]);
end;

constructor EJsonParserException.CreateRes(ResStringRec: PResStringRec; ALineNum, AColumn, APosition: NativeInt);
begin
  inherited CreateRes(ResStringRec);
  FLineNum := ALineNum;
  FColumn := AColumn;
  FPosition := APosition;
  if FLineNum > 0 then
    Message := Format('%s (%d, %d)', [Message, FLineNum, FColumn]);
end;

procedure ListError(Msg: PResStringRec; Data: Integer);
begin
  raise EStringListError.CreateFmt(LoadResString(Msg), [Data])
        {$IFDEF HAS_RETURN_ADDRESS} at ReturnAddress{$ENDIF};
end;

procedure ErrorNoMappingForUnicodeCharacter;
begin
  {$IF not declared(SNoMappingForUnicodeCharacter)}
  RaiseLastOSError;
  {$ELSE}
  raise EEncodingError.CreateRes(@SNoMappingForUnicodeCharacter)
        {$IFDEF HAS_RETURN_ADDRESS} at ReturnAddress{$ENDIF};
  {$IFEND}
end;

procedure ErrorUnsupportedVariantType(VarType: TVarType);
begin
  raise EJsonCastException.CreateResFmt(@RsVarTypeNotSupported, [VarType]);
end;

{$IFDEF USE_NAME_STRING_LITERAL}
procedure AsgString(var Dest: string; const Source: string); inline;
begin
  if (Pointer(Source) <> nil) and (PInteger(@PByte(Source)[-8])^ = -1) and // string literal
     (((PByte(Source) < JsonMemInfoBlockEnd) and (PByte(Source) >= JsonMemInfoBlockStart)) or
      ((PByte(Source) < JsonMemInfoMainBlockEnd) and (PByte(Source) >= JsonMemInfoMainBlockStart))) then
  begin
    // Save memory by just using the string literal but only if it is in the EXE's or this DLL's
    // code segment. Otherwise the memory could be released by a FreeLibrary call without us knowning.
    Pointer(Dest) := Pointer(Source);
  end
  else
    Dest := Source;
end;
{$ENDIF USE_NAME_STRING_LITERAL}

{$IFDEF USE_FAST_STRASG_FOR_INTERNAL_STRINGS}
  {$IFDEF DEBUG}
//procedure InternAsgStringUsageError;
//begin
//  raise EJsonException.CreateRes(@RsInternAsgStringUsageError);
//end;
  {$ENDIF DEBUG}
{$ENDIF USE_FAST_STRASG_FOR_INTERNAL_STRINGS}

procedure AnsiLowerCamelCaseString(var S: string);
begin
  S := AnsiLowerCase(PChar(S)^) + Copy(S, 2);
end;

{$IF not declared(TryStrToUInt64)}
function TryStrToUInt64(const S: string; out Value: UInt64): Boolean;
var
  P, EndP: PChar;
  V: UInt64;
  Digit: Integer;
begin
  // No support for hexadecimal strings

  P := PChar(S);
  EndP := P + Length(S);
  // skip spaces
  while (P < EndP) and (P^ = ' ') do
    Inc(P);
  if P^ = '-' then
    Result := False // UInt64 cannot be negative
  else
  begin
    V := 0;
    while P < EndP do
    begin
      Digit := Integer(Ord(P^)) - Ord('0');
      if (Cardinal(Digit) >= 10) or (V > High(UInt64) div 10) then
        Break;
      //V := V * 10 + Digit;
      V := (V shl 3) + (V shl 1) + Digit;
      Inc(P);
    end;

    Result := P = EndP;
    if Result then
      Value := V;
  end;
end;
{$IFEND}

function GetHexDigitsUtf8(P: PByte; Count: Integer; const Reader: TJsonReader): UInt32;
var
  Ch: Byte;
begin
  Result := 0;
  while Count > 0 do
  begin
    Ch := P^;
    case P^ of
      Ord('0')..Ord('9'): Result := (Result shl 4) or UInt32(Ch - Ord('0'));
      Ord('A')..Ord('F'): Result := (Result shl 4) or UInt32(Ch - (Ord('A') - 10));
      Ord('a')..Ord('f'): Result := (Result shl 4) or UInt32(Ch - (Ord('a') - 10));
    else
      Break;
    end;
    Inc(P);
    Dec(Count);
  end;
  if Count > 0 then
    raise EJsonParserException.CreateResFmt(@RsInvalidHexNumber, [P^], Reader.FLineNum, Reader.GetLineColumn, Reader.GetPosition);
end;

function GetHexDigits(P: PChar; Count: Integer; const Reader: TJsonReader): UInt32;
var
  Ch: Char;
begin
  Result := 0;
  while Count > 0 do
  begin
    Ch := P^;
    case P^ of
      '0'..'9': Result := (Result shl 4) or UInt32(Ord(Ch) - Ord('0'));
      'A'..'F': Result := (Result shl 4) or UInt32(Ord(Ch) - (Ord('A') - 10));
      'a'..'f': Result := (Result shl 4) or UInt32(Ord(Ch) - (Ord('a') - 10));
    else
      Break;
    end;
    Inc(P);
    Dec(Count);
  end;
  if Count > 0 then
    raise EJsonParserException.CreateResFmt(@RsInvalidHexNumber, [P^], Reader.FLineNum, Reader.GetLineColumn, Reader.GetPosition);
end;

function UtcDateTimeToLocalDateTime(UtcDateTime: TDateTime): TDateTime;
{$IFDEF MSWINDOWS}
var
  UtcTime, LocalTime: TSystemTime;
begin
  DateTimeToSystemTime(UtcDateTime, UtcTime);
  if SystemTimeToTzSpecificLocalTime(nil, UtcTime, LocalTime) then
    Result := SystemTimeToDateTime(LocalTime)
  else
    Result := UtcDateTime;
end;
{$ELSE}
begin
  Result := TTimeZone.Local.ToLocalTime(UtcDateTime);
end;
{$ENDIF MSWINDOWS}

function DateTimeToISO8601(Value: TDateTime): string;
{$IFDEF MSWINDOWS}
var
  LocalTime, UtcTime: TSystemTime;
  Offset: TDateTime;
  Hour, Min, Sec, MSec: Word;
begin
  DateTimeToSystemTime(Value, LocalTime);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%d',
    [LocalTime.wYear, LocalTime.wMonth, LocalTime.wDay,
     LocalTime.wHour, LocalTime.wMinute, LocalTime.wSecond, LocalTime.wMilliseconds]);
  if TzSpecificLocalTimeToSystemTime(nil, LocalTime, UtcTime) then
  begin
    Offset := Value - SystemTimeToDateTime(UtcTime);
    DecodeTime(Offset, Hour, Min, Sec, MSec);
    if Offset < 0 then
      Result := Format('%s-%.2d:%.2d', [Result, Hour, Min])
    else if Offset > 0 then
      Result := Format('%s+%.2d:%.2d', [Result, Hour, Min])
    else
      Result := Result + 'Z';
  end;
end;
{$ELSE}
var
  Offset: TDateTime;
  Year, Month, Day, Hour, Minute, Second, Milliseconds: Word;
begin
  DecodeDate(Value, Year, Month, Day);
  DecodeTime(Value, Hour, Minute, Second, MilliSeconds);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%d', [Year, Month, Day, Hour, Minute, Second, Milliseconds]);
  Offset := Value - TTimeZone.Local.ToUniversalTime(Value);
  DecodeTime(Offset, Hour, Minute, Second, MilliSeconds);
  if Offset < 0 then
    Result := Format('%s-%.2d:%.2d', [Result, Hour, Minute])
  else if Offset > 0 then
    Result := Format('%s+%.2d:%.2d', [Result, Hour, Minute])
  else
    Result := Result + 'Z';
end;
{$ENDIF MSWINDOWS}

function DateTimeToJson(const Value: TDateTime; UseUtcTime: Boolean): string;
{$IFDEF MSWINDOWS}
var
  LocalTime, UtcTime: TSystemTime;
begin
  if UseUtcTime then
  begin
    DateTimeToSystemTime(Value, LocalTime);
    if not TzSpecificLocalTimeToSystemTime(nil, LocalTime, UtcTime) then
      UtcTime := LocalTime;
    Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%dZ',
      [UtcTime.wYear, UtcTime.wMonth, UtcTime.wDay,
       UtcTime.wHour, UtcTime.wMinute, UtcTime.wSecond, UtcTime.wMilliseconds]);
  end
  else
    Result := DateTimeToISO8601(Value);
end;
{$ELSE}
var
  UtcTime: TDateTime;
  Year, Month, Day, Hour, Minute, Second, Milliseconds: Word;
begin
  if UseUtcTime then
  begin
    UtcTime := TTimeZone.Local.ToUniversalTime(Value);
    DecodeDate(UtcTime, Year, Month, Day);
    DecodeTime(UtcTime, Hour, Minute, Second, MilliSeconds);
    Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%dZ', [Year, Month, Day, Hour, Minute, Second, Milliseconds]);
  end
  else
    Result := DateTimeToISO8601(Value);
end;
{$ENDIF MSWINDOWS}

function ParseDateTimePart(P: PChar; var Value: Integer; MaxLen: Integer): PChar;
var
  V: Integer;
begin
  Result := P;
  V := 0;
  while WCharInSetFast(Result^, ['0'..'9']) and (MaxLen > 0) do
  begin
    V := V * 10 + (Ord(Result^) - Ord('0'));
    Inc(Result);
    Dec(MaxLen);
  end;
  Value := V;
end;

function JsonToDateTime(const Value: string): TDateTime;
var
  P: PChar;
  MSecsSince1970: Int64;
  Year, Month, Day, Hour, Min, Sec, MSec: Integer;
  OffsetHour, OffsetMin: Integer;
  Sign: Double;
begin
  Result := 0;
  if Value = '' then
    Exit;

  P := PChar(Value);
  if (P^ = '/') and (StrLComp('Date(', P + 1, 5) = 0) then  // .NET: milliseconds since 1970-01-01
  begin
    Inc(P, 6);
    MSecsSince1970 := 0;
    while (P^ <> #0) and WCharInSetFast(P^, ['0'..'9']) do
    begin
      MSecsSince1970 := MSecsSince1970 * 10 + (Ord(P^) - Ord('0'));
      Inc(P);
    end;
    if (P^ = '+') or (P^ = '-') then // timezone information
    begin
      Inc(P);
      while (P^ <> #0) and WCharInSetFast(P^, ['0'..'9']) do
        Inc(P);
    end;
    if (P[0] = ')') and (P[1] = '/') and (P[2] = #0) then
      Result := UtcDateTimeToLocalDateTime(UnixDateDelta + (MSecsSince1970 / MSecsPerDay))
    else
      Result := 0; // invalid format
  end
  else
  begin
    // "2015-02-01T16:08:19.202Z"
    if P^ = '-' then // negative year
      Inc(P);
    P := ParseDateTimePart(P, Year, 4);
    if P^ <> '-' then
      Exit; // invalid format
    P := ParseDateTimePart(P + 1, Month, 2);
    if P^ <> '-' then
      Exit; // invalid format
    P := ParseDateTimePart(P + 1, Day, 2);

    Hour := 0;
    Min := 0;
    Sec := 0;
    MSec := 0;
    Result := EncodeDate(Year, Month, Day);

    if P^ = 'T' then
    begin
      P := ParseDateTimePart(P + 1, Hour, 2);
      if P^ <> ':' then
        Exit; // invalid format
      P := ParseDateTimePart(P + 1, Min, 2);
      if P^ = ':' then
      begin
        P := ParseDateTimePart(P + 1, Sec, 2);
        if P^ = '.' then
          P := ParseDateTimePart(P + 1, MSec, 3);
      end;
      Result := Result + EncodeTime(Hour, Min, Sec, MSec);
      if P^ <> 'Z' then
      begin
        if (P^ = '+') or (P^ = '-') then
        begin
          if P^ = '+' then
            Sign := -1 //  +0100 means that the time is 1 hour later than UTC
          else
            Sign := 1;

          P := ParseDateTimePart(P + 1, OffsetHour, 2);
          if P^ = ':' then
            Inc(P);
          ParseDateTimePart(P, OffsetMin, 2);

          Result := Result + (EncodeTime(OffsetHour, OffsetMin, 0, 0) * Sign);
        end
        else
        begin
          Result := 0; // invalid format
          Exit;
        end;
      end;
      Result := UtcDateTimeToLocalDateTime(Result);
    end;
  end;
end;

{$IFDEF NEXTGEN}
function Utf8StrLen(P: PByte): Integer;
begin
  Result := 0;
  if P <> nil then
    while P[Result] <> 0 do
      Inc(Result);
end;
{$ENDIF NEXTGEN}

procedure SetStringUtf8(var S: string; P: PByte; Len: Integer);
var
  L: Integer;
begin
  if S <> '' then
    S := '';
  if (P = nil) or (Len = 0) then
    Exit;
  SetLength(S, Len);

  L := Utf8ToUnicode(PWideChar(Pointer(S)), Len + 1, PAnsiChar(P), Len);
  if L > 0 then
  begin
    if L - 1 <> Len then
      SetLength(S, L - 1);
  end
  else
    S := '';
end;

procedure AppendString(var S: string; P: PChar; Len: Integer);
var
  OldLen: Integer;
begin
  if (P = nil) or (Len = 0) then
    Exit;
  OldLen := Length(S);
  SetLength(S, OldLen + Len);
  Move(P^, PChar(Pointer(S))[OldLen], Len * SizeOf(Char));
end;

procedure AppendStringUtf8(var S: string; P: PByte; Len: Integer);
var
  L, OldLen: Integer;
begin
  if (P = nil) or (Len = 0) then
    Exit;
  OldLen := Length(S);
  SetLength(S, OldLen + Len);

  L := Utf8ToUnicode(PWideChar(Pointer(S)) + OldLen, Len + 1, PAnsiChar(P), Len);
  if L > 0 then
  begin
    if L - 1 <> Len then
      SetLength(S, OldLen + L - 1);
  end
  else
    SetLength(S, OldLen);
end;

{$IFDEF SUPPORT_PROGRESS}
{ TJsonReaderProgressRec }

function TJsonReaderProgressRec.Init(AProgress: TJsonReaderProgressProc; AData: Pointer = nil; AThreshold: NativeInt = 0): PJsonReaderProgressRec;
begin
  Self.Data := AData;
  Self.Threshold := AThreshold;
  Self.Progress := AProgress;
  Result := @Self;
end;
{$ENDIF SUPPORT_PROGRESS}

{ TJsonReader }

constructor TJsonReader.Create(AStart: Pointer{$IFDEF SUPPORT_PROGRESS}; ASize: NativeInt; AProgress: PJsonReaderProgressRec{$ENDIF});
begin
  //inherited Create;

  FStart := AStart;
  FLineNum := 1; // base 1
  FLineStart := nil;

  {$IFDEF SUPPORT_PROGRESS}
  FSize := ASize;
  FProgress := AProgress;
  FLastProgressValue := 0; // class is not zero-filled
  if (FProgress <> nil) and Assigned(FProgress.Progress) then
    FProgress.Progress(FProgress.Data, 0, 0, FSize);
  {$ENDIF SUPPORT_PROGRESS}
end;

destructor TJsonReader.Destroy;
begin
  {$IFDEF SUPPORT_PROGRESS}
  if (FLook.Kind = jtkEof) and (FProgress <> nil) and Assigned(FProgress.Progress) then
    FProgress.Progress(FProgress.Data, 100, FSize, FSize);
  {$ENDIF SUPPORT_PROGRESS}
  //inherited Destroy;
end;

{$IFDEF SUPPORT_PROGRESS}
procedure TJsonReader.CheckProgress(Position: Pointer);
var
  NewPercentage: NativeInt;
  Ps: NativeInt;
begin
  if {(FProgress <> nil) and} Assigned(FProgress.Progress) then
  begin
    Ps := PByte(Position) - PByte(FStart);
    if FProgress.Threshold = 0 then
    begin
      NewPercentage := Ps * 100 div FSize;
      if NewPercentage <> FLastProgressValue then
      begin
        FLastProgressValue := NewPercentage;
        FProgress.Progress(FProgress.Data, NewPercentage, Ps, FSize);
      end;
    end
    else if FProgress.Threshold > 0 then
    begin
      if Ps - FLastProgressValue >= FProgress.Threshold then
      begin
        FLastProgressValue := Ps;
        NewPercentage := 0;
        if FSize > 0 then
          NewPercentage := Ps * 100 div FSize;
        FProgress.Progress(FProgress.Data, NewPercentage, Ps, FSize);
      end;
    end;
  end;
end;
{$ENDIF SUPPORT_PROGRESS}

function TJsonReader.GetLineColumn: NativeInt;
begin
  if FLineStart = nil then
    FLineStart := FStart;
  Result := GetCharOffset(FLineStart) + 1; // base 1
end;

function TJsonReader.GetPosition: NativeInt;
begin
  Result := GetCharOffset(FStart);
end;

class procedure TJsonReader.InvalidStringCharacterError(const Reader: TJsonReader);
begin
  raise EJsonParserException.CreateRes(@RsInvalidStringCharacter,
    Reader.FLineNum, Reader.GetLineColumn, Reader.GetPosition);
end;

class procedure TJsonReader.StringNotClosedError(const Reader: TJsonReader);
begin
  raise EJsonParserException.CreateRes(@RsStringNotClosed,
    Reader.FLineNum, Reader.GetLineColumn, Reader.GetPosition);
end;

class procedure TJsonReader.JsonStrToStr(P, EndP: PChar; FirstEscapeIndex: Integer; var S: string;
  const Reader: TJsonReader);
const
  MaxBufPos = 127;
var
  Buf: array[0..MaxBufPos] of Char;
  F: PChar;
  BufPos, Len: Integer;
begin
  Dec(FirstEscapeIndex);

  if FirstEscapeIndex > 0 then
  begin
    SetString(S, P, FirstEscapeIndex);
    Inc(P, FirstEscapeIndex);
  end
  else
    S := '';

  while True do
  begin
    BufPos := 0;
    while (P < EndP) and (P^ = '\') do
    begin
      Inc(P);
      if P = EndP then // broken escaped character
        Break;
      case P^ of
        '"': Buf[BufPos] := '"';
        '\': Buf[BufPos] := '\';
        '/': Buf[BufPos] := '/';
        'b': Buf[BufPos] := #8;
        'f': Buf[BufPos] := #12;
        'n': Buf[BufPos] := #10;
        'r': Buf[BufPos] := #13;
        't': Buf[BufPos] := #9;
        'u':
          begin
            Inc(P);
            if P + 3 >= EndP then
              Break;
            Buf[BufPos] := Char(GetHexDigits(P, 4, TJsonReader(Reader)));
            Inc(P, 3);
          end;
      else
        Break;
      end;
      Inc(P);

      Inc(BufPos);
      if BufPos > MaxBufPos then
      begin
        Len := Length(S);
        SetLength(S, Len + BufPos);
        Move(Buf[0], PChar(Pointer(S))[Len], BufPos * SizeOf(Char));
        BufPos := 0;
      end;
    end;
    // append remaining buffer
    if BufPos > 0 then
    begin
      Len := Length(S);
      SetLength(S, Len + BufPos);
      Move(Buf[0], PChar(Pointer(S))[Len], BufPos * SizeOf(Char));
    end;

    // fast forward
    F := P;
    while (P < EndP) and (P^ <> '\') do
      Inc(P);
    if P > F then
      AppendString(S, F, P - F);
    if P >= EndP then
      Break;
  end;
end;

class procedure TJsonReader.JsonUtf8StrToStr(P, EndP: PByte; FirstEscapeIndex: Integer; var S: string;
  const Reader: TJsonReader);
const
  MaxBufPos = 127;
var
  Buf: array[0..MaxBufPos] of Char;
  F: PByte;
  BufPos, Len: Integer;
begin
  Dec(FirstEscapeIndex);

  if FirstEscapeIndex > 0 then
  begin
    SetStringUtf8(S, P, FirstEscapeIndex);
    Inc(P, FirstEscapeIndex);
  end
  else
    S := '';

  while True do
  begin
    BufPos := 0;
    while (P < EndP) and (P^ = Byte(Ord('\'))) do
    begin
      Inc(P);
      if P = EndP then // broken escaped character
        Break;
      case P^ of
        Ord('"'): Buf[BufPos] := '"';
        Ord('\'): Buf[BufPos] := '\';
        Ord('/'): Buf[BufPos] := '/';
        Ord('b'): Buf[BufPos] := #8;
        Ord('f'): Buf[BufPos] := #12;
        Ord('n'): Buf[BufPos] := #10;
        Ord('r'): Buf[BufPos] := #13;
        Ord('t'): Buf[BufPos] := #9;
        Ord('u'):
          begin
            Inc(P);
            if P + 3 >= EndP then
              Break;
            Buf[BufPos] := Char(GetHexDigitsUtf8(P, 4, TJsonReader(Reader)));
            Inc(P, 3);
          end;
      else
        Break;
      end;
      Inc(P);

      Inc(BufPos);
      if BufPos > MaxBufPos then
      begin
        Len := Length(S);
        SetLength(S, Len + BufPos);
        Move(Buf[0], PChar(Pointer(S))[Len], BufPos * SizeOf(Char));
        BufPos := 0;
      end;
    end;
    // append remaining buffer
    if BufPos > 0 then
    begin
      Len := Length(S);
      SetLength(S, Len + BufPos);
      Move(Buf[0], PChar(Pointer(S))[Len], BufPos * SizeOf(Char));
    end;

    // fast forward
    F := P;
    while (P < EndP) and (P^ <> Byte(Ord('\'))) do
      Inc(P);
    if P > F then
      AppendStringUtf8(S, F, P - F);
    if P >= EndP then
      Break;
  end;
end;

procedure TJsonReader.Parse(var Data: TPortableValue);
begin
  if Data.dataType = sdtObject then
  begin
    Data.AsObject.Clear;
    Next; // initialize Lexer
    Accept(jtkLBrace);
    ParseObjectBody(Data.AsObject);
    Accept(jtkRBrace);
  end
  else if Data.dataType = sdtArray then
  begin
    Data.AsArray.Clear;
    Next; // initialize Lexer
    Accept(jtkLBracket);
    ParseArrayBody(Data.AsArray);
    Accept(jtkRBracket)
  end;
end;

procedure TJsonReader.ParseObjectBody(const Data: TPortableObject);
// ObjectBody ::= [ ObjectProperty [ "," ObjectProperty ]* ]
begin
  if FLook.Kind <> jtkRBrace then
  begin
    while FLook.Kind <> jtkEof do
    begin
      ParseObjectProperty(Data);
      if FLook.Kind = jtkRBrace then
        Break;
      Accept(jtkComma);
    end;
  end;
end;

procedure TJsonReader.ParseObjectProperty(const Data: TPortableObject);
// Property ::= IDENT ":" ObjectPropertyValue
begin
  if FLook.Kind >= jtkIdent then // correct Json would be "tkString" only
  begin
    FPropName := '';
    // transfer the string without going through UStrAsg and UStrClr
    Pointer(FPropName) := Pointer(FLook.S);
    Pointer(FLook.S) := nil;
    Next;
  end
  else
    Accept(jtkString);

  Accept(jtkColon);
  ParseObjectPropertyValue(Data);
end;

procedure TJsonReader.ParseObjectPropertyValue(const Data: TPortableObject);
// ObjectPropertyValue ::= Object | Array | Value
begin
  case FLook.Kind of
    jtkLBrace:
      begin
        Accept(jtkLBrace);
        ParseObjectBody(Data.FastAddObject(FPropName));
        Accept(jtkRBrace);
      end;

    jtkLBracket:
      begin
        Accept(jtkLBracket);
        ParseArrayBody(Data.FastAddArray(FPropName));
        Accept(jtkRBracket);
      end;

    jtkNull:
      begin
        Data.FastAddNull(FPropName);
        Next;
      end;

    jtkIdent,
    jtkString:
      begin
        Data.FastAdd(FPropName, FLook.S);
        Next;
      end;

    jtkInt:
      begin
        Data.FastAdd(FPropName, FLook.I);
        Next;
      end;

    jtkLong:
      begin
        Data.FastAdd(FPropName, FLook.L);
        Next;
      end;

    jtkULong:
      begin
        Data.FastAdd(FPropName, FLook.U);
        Next;
      end;

    jtkFloat:
      begin
        Data.FastAdd(FPropName, FLook.F);
        Next;
      end;

    jtkTrue:
      begin
        Data.FastAdd(FPropName, True);
        Next;
      end;

    jtkFalse:
      begin
        Data.FastAdd(FPropName, False);
        Next;
      end
  else
    Accept(jtkValue);
  end;
end;

procedure TJsonReader.ParseArrayBody(const Data: TPortableArray);
// ArrayBody ::= [ ArrayPropertyValue [ "," ArrayPropertyValue ]* ]
begin
  if FLook.Kind <> jtkRBracket then
  begin
    while FLook.Kind <> jtkEof do
    begin
      ParseArrayPropertyValue(Data);
      if FLook.Kind = jtkRBracket then
        Break;
      Accept(jtkComma);
    end;
  end;
end;

procedure TJsonReader.ParseArrayPropertyValue(const Data: TPortableArray);
// ArrayPropertyValue ::= Object | Array | Value
begin
  case FLook.Kind of
    jtkLBrace:
      begin
        Accept(jtkLBrace);
        ParseObjectBody(Data.AddObject);
        Accept(jtkRBrace);
      end;

    jtkLBracket:
      begin
        Accept(jtkLBracket);
        ParseArrayBody(Data.AddArray);
        Accept(jtkRBracket);
      end;

    jtkNull:
      begin
        Data.Add(TPortableObject(nil));
        Next;
      end;

    jtkIdent,
    jtkString:
      begin
        Data.Add(FLook.S);
        Next;
      end;

    jtkInt:
      begin
        Data.Add(FLook.I);
        Next;
      end;

    jtkLong:
      begin
        Data.Add(FLook.L);
        Next;
      end;

    jtkULong:
      begin
        Data.Add(FLook.U);
        Next;
      end;

    jtkFloat:
      begin
        Data.Add(FLook.F);
        Next;
      end;

    jtkTrue:
      begin
        Data.Add(True);
        Next;
      end;

    jtkFalse:
      begin
        Data.Add(False);
        Next;
      end;
  else
    Accept(jtkValue);
  end;
end;

procedure TJsonReader.AcceptFailed(TokenKind: TJsonTokenKind);
var
  Col, Position: NativeInt;
begin
  Col := GetLineColumn;
  Position := GetPosition;
  if FLook.Kind = jtkEof then
    raise EJsonParserException.CreateResFmt(@RsUnexpectedEndOfFile, [JsonTokenKindToStr[TokenKind]], FLineNum, Col, Position);
  raise EJsonParserException.CreateResFmt(@RsUnexpectedToken, [JsonTokenKindToStr[TokenKind], JsonTokenKindToStr[FLook.Kind]], FLineNum, Col, Position);
end;

procedure TJsonReader.Accept(TokenKind: TJsonTokenKind);
begin
  if FLook.Kind <> TokenKind then
    AcceptFailed(TokenKind);
  Next;
end;

function DoubleToText(Buffer: PChar; const Value: Extended): Integer; inline;
begin
  Result := FloatToText(Buffer, Value, fvExtended, ffGeneral, 15, 0, JsonFormatSettings);
end;

const
  DoubleDigits: array[0..99] of array[0..1] of Char = (
    '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
    '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
    '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
    '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
    '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
    '70', '71', '72', '73', '74', '75', '76', '77', '78', '79',
    '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99'
  );

function InternIntToText(Value: Cardinal; Negative: Boolean; EndP: PChar): PChar;
var
  I, Quotient, K: Cardinal;
begin
  I := Value;
  Result := EndP;
  while I >= 100 do
  begin
    Quotient := I div 100;
    K := Quotient * 100;
    K := I - K;
    I := Quotient;
    Dec(Result, 2);
    PUInt32(Result)^ := UInt32(DoubleDigits[K]);
  end;
  if I >= 10 then
  begin
    Dec(Result, 2);
    PUInt32(Result)^ := UInt32(DoubleDigits[I]);
  end
  else
  begin
    Dec(Result);
    Result^ := Char(I or Ord('0'));
  end;

  if Negative then
  begin
    Dec(Result);
    Result^ := '-';
  end;
end;

function IntToText(Value: Integer; EndP: PChar): PChar; inline;
begin
  if Value < 0 then
    Result := InternIntToText(Cardinal(-Value), True, EndP)
  else
    Result := InternIntToText(Cardinal(Value), False, EndP);
end;

function UInt64ToText(Value: UInt64; EndP: PChar): PChar;
var
  Quotient: UInt64;
  Remainder: Cardinal;
begin
  Result := EndP;

  while Value > High(Integer) do
  begin
    Quotient := Value div 100;
    //Remainder := Value - (Quotient * 100);
    Remainder := Value - (Quotient shl 6 + Quotient shl 5 + Quotient shl 2);
    Value := Quotient;

    Dec(Result, 2);
    PUInt32(Result)^ := UInt32(DoubleDigits[Remainder]);
  end;

  Result := InternIntToText(Cardinal(Value), False, Result);
end;

function Int64ToText(Value: Int64; EndP: PChar): PChar;
var
  Neg: Boolean;
begin
  Neg := Value < 0;
  if Neg then
    Value := -Value;

  Result := UInt64ToText(UInt64(Value), EndP);

  if Neg then
  begin
    Dec(Result);
    Result^ := '-';
  end;
end;

procedure FromJsonUtf8(var body: TPortableValue; S: PByte; Len: Integer
{$IFDEF SUPPORT_PROGRESS};AProgress: PJsonReaderProgressRec{$ENDIF});
var
  Reader: TJsonReader;
begin
  if Len < 0 then
    Len := StrLen(PAnsiChar(S));

  Reader := TUtf8JsonReader.Create(S, Len{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
  try
    Reader.Parse(body);
  finally
    Reader.Free;
  end;
end;

procedure FromJsonUtf8(var body: TPortableValue; const s: RawByteString
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF});
begin
  FromJsonUtf8(body, PByte(s), Length(s) {$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
end;

function ParseJsonUtf8(S: PByte; Len: Integer
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF}): TPortableValue;
var
  P: PByte;
  L: Integer;
begin
  Result.init;
  if (S <> nil) and (Len > 0) then
  begin
    if Len < 0 then
    begin
      {$IFDEF NEXTGEN}
      Len := Utf8StrLen(S);
      {$ELSE}
      Len := StrLen(PAnsiChar(S));
      {$ENDIF NEXTGEN}
    end;
    P := S;
    L := Len;
    while (L > 0) and (P^ <= 32) do
    begin
      Inc(P);
      Dec(L);
    end;
    if L > 0 then
    begin
      if (L > 0) and (P^ = Byte(Ord('['))) then
      begin
        Result.CreateArrayIfEmpty;
      end
      else begin
        Result.CreateObjectIfEmpty;
      end;

      {$IFDEF AUTOREFCOUNT}
      FromJsonUtf8(Result, S, Len{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
      {$ELSE}
      try
        FromJsonUtf8(Result, S, Len{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
      except
        Result.cleanup;
        raise;
      end;
      {$ENDIF AUTOREFCOUNT}
    end;
  end;
end;

function ParseJsonUtf8(const s: RawByteString
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF}
  ): TPortableValue;
begin
  Result := ParseJsonUtf8(PByte(s), Length(s){$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
end;

procedure FromJson(var body: TPortableValue; S: PWideChar; Len: Integer
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF});
var
  Reader: TJsonReader;
begin
  if Len < 0 then
    Len := StrLen(S);
  Reader := TStringJsonReader.Create(S, Len{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
  try
    Reader.Parse(body);
  finally
    Reader.Free;
  end;
end;

procedure FromJson(var body: TPortableValue; const S: UnicodeString
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF});
begin
  FromJson(body, PWideChar(S), Length(S){$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
end;

function ParseJson(S: PWideChar; Len: Integer
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF}
  ): TPortableValue;
var
  P: PWideChar;
  L: Integer;
begin
  Result.init;
  if (S <> nil) and (Len > 0) then
  begin
    if Len < 0 then
      Len := StrLen(S);
    P := S;
    L := Len;
    while (L > 0) and (P^ <= #32) do
    begin
      Inc(P);
      Dec(L);
    end;
    if L > 0 then
    begin
      if (L > 0) and (P^ = '[') then
        Result.CreateArrayIfEmpty
      else
        Result.CreateObjectIfEmpty;

      try
        FromJson(Result, S, Len{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
      except
        Result.cleanup;
        raise;
      end;
    end;
  end;
end;

{$IFDEF SUPPORTS_UTF8STRING}
function ParseUtf8(const S: UTF8String
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF}
  ): TPortableValue; overload;
begin
  Result := ParseJsonUtf8(PByte(S), Length(S){$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
end;
{$ENDIF SUPPORTS_UTF8STRING}

function ParseJson(const S: UnicodeString
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF}
  ): TPortableValue;
begin
  Result := ParseJson(PWideChar(Pointer(S)), Length(S){$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
end;

function ParseJson(const Bytes: TBytes; Encoding: TEncoding; ByteIndex: Integer;
  ByteCount: Integer{$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF}
  ): TPortableValue;
var
  L: Integer;
begin
  Result.init;
  L := Length(Bytes);
  if ByteCount = -1 then
    ByteCount := L - ByteIndex;
  if (ByteCount < 0) and (ByteIndex + ByteCount <= L) then
  begin
    if (Encoding = TEncoding.UTF8) or (Encoding = nil) then
      Result := ParseJsonUtf8(PByte(@Bytes[ByteIndex]), ByteCount
      {$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF})
    else if Encoding = TEncoding.Unicode then
      Result := ParseJson(PWideChar(@Bytes[ByteIndex]), ByteCount div SizeOf(WideChar)
        {$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF})
    else
      Result := ParseJson(Encoding.GetString(Bytes, ByteIndex, ByteCount)
      {$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
  end;
end;

type
  TStreamInfo = record
    Buffer: PByte;
    Size: NativeInt;
    AllocationBase: Pointer;
  end;

procedure GetStreamBytes(Stream: TStream; var Encoding: TEncoding; Utf8WithoutBOM: Boolean;
  var StreamInfo: TStreamInfo);
{$IFDEF WORKAROUND_NETWORK_FILE_INSUFFICIENT_RESOURCES}
const
  MaxBufSize = 20 * 1024 * 1024;
var
  ReadCount, ReadBufSize: NativeInt;
{$ENDIF WORKAROUND_NETWORK_FILE_INSUFFICIENT_RESOURCES}
var
  Position: Int64;
  Size: NativeInt;
  Bytes: PByte;
  BufStart: Integer;
begin
  BufStart := 0;
  Position := Stream.Position;
  Size := Stream.Size - Position;

  StreamInfo.Buffer := nil;
  StreamInfo.Size := 0;
  StreamInfo.AllocationBase := nil;
  try
    Bytes := nil;
    if Size > 0 then
    begin
      if Stream is TCustomMemoryStream then
      begin
        Bytes := TCustomMemoryStream(Stream).Memory;
        TCustomMemoryStream(Stream).Position := Position + Size;
        Inc(Bytes, Position);
      end
      else
      begin
        GetMem(StreamInfo.AllocationBase, Size);
        Bytes := StreamInfo.AllocationBase;
        {$IFDEF WORKAROUND_NETWORK_FILE_INSUFFICIENT_RESOURCES}
        if (Stream is THandleStream) and (Size > MaxBufSize) then
        begin
          ReadCount := Size;
          // Read in 20 MB blocks to work around a network limitation in Windows 2003 or older (INSUFFICIENT RESOURCES)
          while ReadCount > 0 do
          begin
            ReadBufSize := ReadCount;
            if ReadBufSize > MaxBufSize then
              ReadBufSize := MaxBufSize;
            Stream.ReadBuffer(Bytes[Size - ReadCount], ReadBufSize);
            Dec(ReadCount, ReadBufSize);
          end;
        end
        else
        {$ENDIF WORKAROUND_NETWORK_FILE_INSUFFICIENT_RESOURCES}
          Stream.ReadBuffer(StreamInfo.AllocationBase^, Size);
      end;
    end;

    if Encoding = nil then
    begin
      // Determine the encoding from the BOM
      if Utf8WithoutBOM then
        Encoding := TEncoding.UTF8
      else
        Encoding := TEncoding.Default;

      if Size >= 2 then
      begin
        if (Bytes[0] = $EF) and (Bytes[1] = $BB) then
        begin
          if Bytes[2] = $BF then
          begin
            Encoding := TEncoding.UTF8;
            BufStart := 3;
          end;
        end
        else if (Bytes[0] = $FF) and (Bytes[1] = $FE) then
        begin
          if (Bytes[2] = 0) and (Bytes[3] = 0) then
          begin
            raise EJsonException.CreateRes(@RsUnsupportedFileEncoding);
            //Result := bomUtf32LE;
            //BufStart := 4;
          end
          else
          begin
            Encoding := TEncoding.Unicode;
            BufStart := 2;
          end;
        end
        else if (Bytes[0] = $FE) and (Bytes[1] = $FF) then
        begin
          Encoding := TEncoding.BigEndianUnicode;
          BufStart := 2;
        end
        else if (Bytes[0] = 0) and (Bytes[1] = 0) and (Size >= 4) then
        begin
          if (Bytes[2] = $FE) and (Bytes[3] = $FF) then
          begin
            raise EJsonException.CreateRes(@RsUnsupportedFileEncoding);
            //Result := bomUtf32BE;
            //BufStart := 4;
          end;
        end;
      end;
    end;
    Inc(Bytes, BufStart);
    StreamInfo.Buffer := Bytes;
    StreamInfo.Size := Size - BufStart;
  except
    FreeMem(StreamInfo.AllocationBase);
    raise;
  end;
end;

function ParseJsonStream(Stream: TStream; Encoding: TEncoding; Utf8WithoutBOM: Boolean
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF}): TPortableValue; overload;
var
  StreamInfo: TStreamInfo;
  S: string;
  L: Integer;
begin
  GetStreamBytes(Stream, Encoding, Utf8WithoutBOM, StreamInfo);
  try
    if Encoding = TEncoding.UTF8 then
      Result := ParseJsonUtf8(StreamInfo.Buffer, StreamInfo.Size{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF})
    else if Encoding = TEncoding.Unicode then
      Result := ParseJson(PWideChar(Pointer(StreamInfo.Buffer)), StreamInfo.Size div SizeOf(WideChar){$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF})
    else
    begin
      L := TEncodingStrictAccess(Encoding).GetCharCountEx(StreamInfo.Buffer, StreamInfo.Size);
      SetLength(S, L);
      if L > 0 then
        TEncodingStrictAccess(Encoding).GetCharsEx(StreamInfo.Buffer, StreamInfo.Size, PChar(Pointer(S)), L)
      else if StreamInfo.Size > 0 then
        ErrorNoMappingForUnicodeCharacter;

      // release memory
      FreeMem(StreamInfo.AllocationBase);
      StreamInfo.AllocationBase := nil;

      Result := ParseJson(S{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
    end;
  finally
    FreeMem(StreamInfo.AllocationBase);
  end;
end;

function ParseFromFile(const FileName: string; Utf8WithoutBOM: Boolean
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF}
  ): TPortableValue; overload;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := ParseJsonStream(Stream, nil, Utf8WithoutBOM{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
  finally
    Stream.Free;
  end;
end;

procedure LoadFromStream(var body: TPortableValue; Stream: TStream; Encoding: TEncoding; Utf8WithoutBOM: Boolean
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF});
var
  StreamInfo: TStreamInfo;
  S: string;
  L: Integer;
begin
  GetStreamBytes(Stream, Encoding, Utf8WithoutBOM, StreamInfo);
  try
    if Encoding = TEncoding.UTF8 then
      FromJsonUtf8(body, StreamInfo.Buffer, StreamInfo.Size{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF})
    else if Encoding = TEncoding.Unicode then
      FromJson(body, PWideChar(Pointer(StreamInfo.Buffer)), StreamInfo.Size div SizeOf(WideChar){$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF})
    else
    begin
      L := TEncodingStrictAccess(Encoding).GetCharCountEx(StreamInfo.Buffer, StreamInfo.Size);
      SetLength(S, L);
      if L > 0 then
        TEncodingStrictAccess(Encoding).GetCharsEx(StreamInfo.Buffer, StreamInfo.Size, PChar(Pointer(S)), L)
      else if StreamInfo.Size > 0 then
        ErrorNoMappingForUnicodeCharacter;

      // release memory
      FreeMem(StreamInfo.AllocationBase);
      StreamInfo.AllocationBase := nil;

      FromJson(body, S{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
    end;
  finally
    FreeMem(StreamInfo.AllocationBase);
  end;
end;

procedure LoadFromFile(var body: TPortableValue; const FileName: string; Utf8WithoutBOM: Boolean
  {$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF}
  );
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(body, Stream, nil, Utf8WithoutBOM{$IFDEF SUPPORT_PROGRESS}, AProgress{$ENDIF});
  finally
    Stream.Free;
  end;
end;

{ TUtf8JsonReader }

constructor TUtf8JsonReader.Create(S: PByte; Len: NativeInt{$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF});
begin
  inherited Create(S{$IFDEF SUPPORT_PROGRESS}, Len * SizeOf(Byte), AProgress{$ENDIF});
  FText := S;
  FTextEnd := S + Len;
end;

function TUtf8JsonReader.GetCharOffset(StartPos: Pointer): NativeInt;
begin
  Result := FText - PByte(StartPos);
end;

function TUtf8JsonReader.Next: Boolean;
label
  EndReached;
var
  P, EndP: PByte;
  Ch: Byte;
begin
  P := FText;
  EndP := FTextEnd;
  {$IF CompilerVersion <= 30.0} // Delphi 10 Seattle or older
    {$IFNDEF CPUX64}
  Ch := 0; // silence compiler warning
    {$ENDIF ~CPUX64}
  {$IFEND}
  while True do
  begin
    while True do
    begin
      if P = EndP then
        goto EndReached; // use GOTO to eliminate doing the "P = EndP", "P < EndP" 3 times - wish there was a "Break loop-label;"
      Ch := P^;
      if Ch > 32 then
        Break;
      if not (Ch in [9, 32]) then
        Break;
      Inc(P);
    end;

    case Ch of
      10:
        begin
          FLineStart := P + 1;
          Inc(FLineNum);
        end;
      13:
        begin
          Inc(FLineNum);
          if (P + 1 < EndP) and (P[1] = 10) then
            Inc(P);
          FLineStart := P + 1;
        end;
    else
      Break;
    end;
    Inc(P);
  end;

EndReached:
  if P < EndP then
  begin
    case P^ of
      Ord('{'):
        begin
          FLook.Kind := jtkLBrace;
          FText := P + 1;
        end;
      Ord('}'):
        begin
          FLook.Kind := jtkRBrace;
          FText := P + 1;
        end;
      Ord('['):
        begin
          FLook.Kind := jtkLBracket;
          FText := P + 1;
        end;
      Ord(']'):
        begin
          FLook.Kind := jtkRBracket;
          FText := P + 1;
        end;
      Ord(':'):
        begin
          FLook.Kind := jtkColon;
          FText := P + 1;
        end;
      Ord(','):
        begin
          FLook.Kind := jtkComma;
          FText := P + 1;
        end;
      Ord('"'): // String
        begin
          LexString(P{$IFDEF CPUARM}, EndP{$ENDIF});
          {$IFDEF SUPPORT_PROGRESS}
          if FProgress <> nil then
            CheckProgress(FText);
          {$ENDIF SUPPORT_PROGRESS}
        end;
      Ord('-'), Ord('0')..Ord('9'), Ord('.'): // Number
        begin
          LexNumber(P{$IFDEF CPUARM}, EndP{$ENDIF});
          {$IFDEF SUPPORT_PROGRESS}
          if FProgress <> nil then
            CheckProgress(FText);
          {$ENDIF SUPPORT_PROGRESS}
        end
    else
      LexIdent(P{$IFDEF CPUARM}, EndP{$ENDIF}); // Ident/Bool/NULL
      {$IFDEF SUPPORT_PROGRESS}
      if FProgress <> nil then
        CheckProgress(FText);
      {$ENDIF SUPPORT_PROGRESS}
    end;
    Result := True;
  end
  else
  begin
    FText := EndP;
    FLook.Kind := jtkEof;
    Result := False;
  end;
end;

procedure TUtf8JsonReader.LexString(P: PByte{$IFDEF CPUARM}; EndP: PByte{$ENDIF});
var
  {$IFNDEF CPUARM}
  EndP: PByte;
  {$ENDIF ~CPUARM}
  EscapeSequences: PByte;
  Ch: Byte;
  Idx: Integer;
begin
  Inc(P); // skip initiating '"'
  {$IFNDEF CPUARM}
  EndP := FTextEnd;
  {$ENDIF ~CPUARM}
  EscapeSequences := nil;
  Ch := 0;
  Idx := P - EndP;

  // find the string end
  repeat
    if Idx = 0 then
      Break;
    Ch := EndP[Idx];
    if (Ch = Byte(Ord('"'))) or (Ch = 10) or (Ch = 13) then
      Break;
    Inc(Idx);
    if Ch <> Byte(Ord('\')) then
      Continue;
    if Idx = 0 then // Eof reached in an escaped char => broken Json string
      Break;
    if EscapeSequences = nil then
      EscapeSequences := @EndP[Idx];
    Inc(Idx);
  until False;

  if Idx = 0 then
  begin
    FText := P - 1;
    TJsonReader.StringNotClosedError(Self);
  end;

  EndP := @EndP[Idx];
  if EscapeSequences = nil then
    SetStringUtf8(FLook.S, P, EndP - P)
  else
    TUtf8JsonReader.JsonUtf8StrToStr(P, EndP, EscapeSequences - P, FLook.S, Self);

  if Ch = Byte(Ord('"')) then
    Inc(EndP);
  FLook.Kind := jtkString;
  FText := EndP;

  if Ch in [10, 13] then
    TJsonReader.InvalidStringCharacterError(Self);
end;

{$IFDEF CPUX64}
function ParseUInt64Utf8(P, EndP: PByte): UInt64;
// RCX = P
// RDX = EndP
asm
  cmp rcx, rdx
  jge @@LeaveFail

  mov r8, rdx
  sub rcx, r8
  // r8+rcx = EndP + NegOffset = P => NegOffset can be incremented and checked for zero

  movzx rax, BYTE PTR [r8+rcx]
  sub al, '0'
  add rcx, 1
  jz @@Leave

@@Loop:
  add rax, rax
  // rax = 2*Result
  lea rax, [rax+rax*4]
  // rax = (2*Result)*4 + (2*Result) = 10*Result

  movzx rdx, BYTE PTR [r8+rcx]
  sub dl, '0'
  add rax, rdx

  add rcx, 1
  jnz @@Loop

@@Leave:
  ret
@@LeaveFail:
  xor rax, rax
end;
{$ELSE}
  {$IFDEF CPUX86}
function ParseUInt64Utf8(P, EndP: PByte): UInt64;
asm
  cmp eax, edx
  jge @@LeaveFail

  push esi
  push edi
  push ebx

  mov esi, edx
  mov edi, eax
  sub edi, edx
  // esi+edi = EndP + NegOffset = P => NegOffset can be incremented and checked for zero

  xor edx, edx
  movzx eax, BYTE PTR [esi+edi]
  sub al, '0'
  add edi, 1
  jz @@PopLeave

@@Loop:
  add eax, eax
  adc edx, edx
  // eax:edx = 2*Result
  mov ebx, eax
  mov ecx, edx
  // ebx:ecx = 2*Result
  shld edx, eax, 2
  shl eax, 2
  // eax:edx = (2*Result)*4
  add eax, ebx
  adc edx, ecx
  // eax:edx = (2*Result)*4 + (2*Result) = 10*Result

  movzx ecx, BYTE PTR [esi+edi]
  sub cl, '0'
  add eax, ecx
  adc edx, 0

  add edi, 1
  jnz @@Loop

@@PopLeave:
  pop ebx
  pop edi
  pop esi
@@Leave:
  ret
@@LeaveFail:
  xor eax, eax
  xor edx, edx
end;
  {$ELSE}
function ParseUInt64Utf8(P, EndP: PByte): UInt64;
begin
  if P = EndP then
    Result := 0
  else
  begin
    Result := P^ - Byte(Ord('0'));
    Inc(P);
    while P < EndP do
    begin
      Result := Result * 10 + (P^ - Byte(Ord('0')));
      Inc(P);
    end;
  end;
end;
  {$ENDIF CPUX86}
{$ENDIF CPUX64}

function ParseAsDoubleUtf8(F, P: PByte): Double;
begin
  Result := 0.0;
  while F < P do
  begin
    Result := Result * 10 + (F^ - Byte(Ord('0')));
    Inc(F);
  end;
end;

procedure TUtf8JsonReader.LexNumber(P: PByte{$IFDEF CPUARM}; EndP: PByte{$ENDIF});
var
  F: PByte;
  {$IFNDEF CPUARM}
  EndP: PByte;
  {$ENDIF ~CPUARM}
  EndInt64P: PByte;
  Ch: Byte;
  Value, Scale: Double;
  Exponent, IntValue: Integer;
  Neg, NegE: Boolean;
  DigitCount: Integer;
begin
  {$IFNDEF CPUARM}
  EndP := FTextEnd;
  {$ENDIF ~CPUARM}
  Neg := False;

  Ch := P^;
  if Ch = Byte(Ord('-')) then
  begin
    Inc(P);
    if P >= EndP then
    begin
      FLook.Kind := jtkInvalidSymbol;
      FText := P;
      Exit;
    end;
    Neg := True;
    Ch := P^;
  end;
  F := P;

  Inc(P);
  if Ch <> Byte(Ord('0')) then
  begin
    if Ch in [Ord('1')..Ord('9')] then
    begin
      while (P < EndP) and (P^ in [Ord('0')..Ord('9')]) do
        Inc(P);
    end
    else
    begin
      FLook.Kind := jtkInvalidSymbol;
      FText := P;
      Exit;
    end;
  end;

  DigitCount := P - F;
  if DigitCount <= 9 then // Int32 fits 9 digits
  begin
    IntValue := 0;
    while F < P do
    begin
      IntValue := IntValue * 10 + (F^ - Byte(Ord('0')));
      Inc(F);
    end;
    FLook.HI := 0;
    FLook.I := IntValue;
    FLook.Kind := jtkInt;
    if not (P^ in [Ord('.'), Ord('E'), Ord('e')]) then
    begin
      // just an integer
      if Neg then
        FLook.I := -FLook.I;
      FText := P;
      Exit;
    end;
    Value := FLook.I;
  end
  else if DigitCount <= 20 then // UInt64 fits 20 digits (not all)
  begin
    FLook.U := ParseUInt64Utf8(F, P);
    if (DigitCount = 20) and (FLook.U mod 10 <> PByte(P - 1)^ - Byte(Ord('0'))) then // overflow => too large
      Value := ParseAsDoubleUtf8(F, P)
    else if Neg and ((DigitCount = 20) or ((DigitCount = 19) and (FLook.HI and $80000000 <> 0))) then
      // "negative UInt64" doesn't fit into UInt64/Int64 => use Double
      Value := FLook.U
    else
    begin
      FLook.Kind := jtkLong;
      case DigitCount of
        19:
         if FLook.HI and $80000000 <> 0 then // can't be negative because we cached that case already
           FLook.Kind := jtkULong;
        20:
          FLook.Kind := jtkULong;
      end;

      if not (P^ in [Ord('.'), Ord('E'), Ord('e')]) then
      begin
        // just an integer
        if Neg then
        begin
          if (FLook.HI = 0) and (FLook.I >= 0) then // 32bit Integer
          begin
            FLook.I := -FLook.I;
            FLook.Kind := jtkInt;
          end
          else                 // 64bit Integer
            FLook.L := -FLook.L;
        end;
        FText := P;
        Exit;
      end;
      Value := FLook.U;
    end;
  end
  else
    Value := ParseAsDoubleUtf8(F, P);

  // decimal digits
  if (P + 1 < EndP) and (P^ = Byte(Ord('.'))) then
  begin
    Inc(P);
    F := P;
    EndInt64P := F + 18;
    if EndInt64P > EndP then
      EndInt64P := EndP;
    while (P < EndInt64P) and (P^ in [Ord('0')..Ord('9')]) do
      Inc(P);
    Value := Value + ParseUInt64Utf8(F, P) / Power10[P - F];

    // "Double" can't handle that many digits
    while (P < EndP) and (P^ in [Ord('0')..Ord('9')]) do
      Inc(P);
  end;

  // exponent
  if (P < EndP) and (P^ in [Ord('e'), Ord('E')]) then
  begin
    Inc(P);
    NegE := False;
    if (P < EndP) then
    begin
      case P^ of
        Ord('-'):
          begin
            NegE := True;
            Inc(P);
          end;
        Ord('+'):
          Inc(P);
      end;
      Exponent := 0;
      F := P;
      while (P < EndP) and (P^ in [Ord('0')..Ord('9')]) do
      begin
        Exponent := Exponent * 10 + (P^ - Byte(Ord('0')));
        Inc(P);
      end;
      if P = F then
      begin
        // no exponent
        FLook.Kind := jtkInvalidSymbol;
        FText := P;
        Exit;
      end;

      if Exponent > 308 then
        Exponent := 308;

      Scale := 1.0;
      while Exponent >= 50 do
      begin
        Scale := Scale * 1E50;
        Dec(Exponent, 50);
      end;
      while Exponent >= 18 do
      begin
        Scale := Scale * 1E18;
        Dec(Exponent, 18);
      end;
      Scale := Scale * Power10[Exponent];

      if NegE then
        Value := Value / Scale
      else
        Value := Value * Scale;
    end
    else
    begin
      FLook.Kind := jtkInvalidSymbol;
      FText := P;
      Exit;
    end;
  end;

  if Neg then
    FLook.F := -Value
  else
    FLook.F := Value;
  FLook.Kind := jtkFloat;
  FText := P;
end;

procedure TUtf8JsonReader.LexIdent(P: PByte{$IFDEF CPUARM}; EndP: PByte{$ENDIF});
const
  {$IFDEF BIGENDIAN}
  // Big Endian
  NullStr = UInt32((Ord('n') shl 24) or (Ord('u') shl 16) or (Ord('l') shl 8) or Ord('l'));
  TrueStr = UInt32((Ord('t') shl 24) or (Ord('r') shl 16) or (Ord('u') shl 8) or Ord('e'));
  FalseStr = UInt32((Ord('a') shl 24) or (Ord('l') shl 16) or (Ord('s') shl 8) or Ord('e'));
  {$ELSE}
  // Little Endian
  NullStr = UInt32(Ord('n') or (Ord('u') shl 8) or (Ord('l') shl 16) or (Ord('l') shl 24));
  TrueStr = UInt32(Ord('t') or (Ord('r') shl 8) or (Ord('u') shl 16) or (Ord('e') shl 24));
  FalseStr = UInt32(Ord('a') or (Ord('l') shl 8) or (Ord('s') shl 16) or (Ord('e') shl 24));
  {$ENDIF BIGENDIAN}
var
  F: PByte;
  {$IFNDEF CPUARM}
  EndP: PByte;
  {$ENDIF ~CPUARM}
  L: UInt32;
begin
  F := P;
  {$IFNDEF CPUARM}
  EndP := FTextEnd;
  {$ENDIF ~CPUARM}
  case P^ of
    Ord('A')..Ord('Z'), Ord('a')..Ord('z'), Ord('_'), Ord('$'):
      begin
        Inc(P);
//        DCC64 generates "bt mem,reg" code
//        while (P < EndP) and (P^ in [Ord('A')..Ord('Z'), Ord('a')..Ord('z'), Ord('_'), Ord('0')..Ord('9')]) do
//          Inc(P);
        while P < EndP do
          case P^ of
            Ord('A')..Ord('Z'), Ord('a')..Ord('z'), Ord('_'), Ord('0')..Ord('9'): Inc(P);
          else
            Break;
          end;

        L := P - F;
        if L = 4 then
        begin
          L := PUInt32(F)^;
          if L = NullStr then
            FLook.Kind := jtkNull
          else if L = TrueStr then
            FLook.Kind := jtkTrue
          else
          begin
            SetStringUtf8(FLook.S, F, P - F);
            FLook.Kind := jtkIdent;
          end;
        end
        else if (L = 5) and (F^ = Ord('f')) and (PUInt32(F + 1)^ = FalseStr) then
          FLook.Kind := jtkFalse
        else
        begin
          SetStringUtf8(FLook.S, F, P - F);
          FLook.Kind := jtkIdent;
        end;
      end;
  else
    FLook.Kind := jtkInvalidSymbol;
    Inc(P);
  end;
  FText := P;
end;

{ TStringJsonReader }

constructor TStringJsonReader.Create(S: PChar; Len: Integer{$IFDEF SUPPORT_PROGRESS}; AProgress: PJsonReaderProgressRec{$ENDIF});
begin
  inherited Create(S{$IFDEF SUPPORT_PROGRESS}, Len * SizeOf(WideChar), AProgress{$ENDIF});
  FText := S;
  FTextEnd := S + Len;
end;

function TStringJsonReader.GetCharOffset(StartPos: Pointer): NativeInt;
begin
  Result := FText - PChar(StartPos);
end;

function TStringJsonReader.Next: Boolean;
var
  P, EndP: PChar;
begin
  P := FText;
  EndP := FTextEnd;
  while (P < EndP) and (P^ <= #32) do
    Inc(P);

  if P < EndP then
  begin
    case P^ of
      '{':
        begin
          FLook.Kind := jtkLBrace;
          FText := P + 1;
        end;
      '}':
        begin
          FLook.Kind := jtkRBrace;
          FText := P + 1;
        end;
      '[':
        begin
          FLook.Kind := jtkLBracket;
          FText := P + 1;
        end;
      ']':
        begin
          FLook.Kind := jtkRBracket;
          FText := P + 1;
        end;
      ':':
        begin
          FLook.Kind := jtkColon;
          FText := P + 1;
        end;
      ',':
        begin
          FLook.Kind := jtkComma;
          FText := P + 1;
        end;
      '"': // String
        begin
          LexString(P{$IFDEF CPUARM}, EndP{$ENDIF});
          {$IFDEF SUPPORT_PROGRESS}
          if FProgress <> nil then
            CheckProgress(FText);
          {$ENDIF SUPPORT_PROGRESS}
        end;
      '-', '0'..'9', '.': // Number
        begin
          LexNumber(P{$IFDEF CPUARM}, EndP{$ENDIF});
          {$IFDEF SUPPORT_PROGRESS}
          if FProgress <> nil then
            CheckProgress(FText);
          {$ENDIF SUPPORT_PROGRESS}
        end
    else
      LexIdent(P{$IFDEF CPUARM}, EndP{$ENDIF}); // Ident/Bool/NULL
      {$IFDEF SUPPORT_PROGRESS}
      if FProgress <> nil then
        CheckProgress(FText);
      {$ENDIF SUPPORT_PROGRESS}
    end;
    Result := True;
  end
  else
  begin
    FText := EndP;
    FLook.Kind := jtkEof;
    Result := False;
  end;
end;

procedure TStringJsonReader.LexString(P: PChar{$IFDEF CPUARM}; EndP: PChar{$ENDIF});
var
  {$IFNDEF CPUARM}
  EndP: PChar;
  {$ENDIF ~CPUARM}
  EscapeSequences: PChar;
  Ch: Char;
  Idx: Integer;
begin
  Inc(P); // skip initiating '"'
  {$IFNDEF CPUARM}
  EndP := FTextEnd;
  {$ENDIF ~CPUARM}
  EscapeSequences := nil;
  Ch := #0;
  Idx := P - EndP;

  // find the string end
  repeat
    if Idx = 0 then
      Break;
    Ch := EndP[Idx];
    if (Ch = '"') or (Ch = #10) or (Ch = #13) then
      Break;
    Inc(Idx);
    if Ch <> '\' then
      Continue;
    if Idx = 0 then // Eof reached in an escaped char => broken Json string
      Break;
    if EscapeSequences = nil then
      EscapeSequences := @EndP[Idx];
    Inc(Idx);
  until False;

  if Idx = 0 then
  begin
    FText := P - 1;
    TJsonReader.StringNotClosedError(Self);
  end;

  EndP := @EndP[Idx];
  if EscapeSequences = nil then
    SetString(FLook.S, P, EndP - P)
  else
    TJsonReader.JsonStrToStr(P, EndP, EscapeSequences - P, FLook.S, Self);

  if Ch = '"' then
    Inc(EndP);
  FLook.Kind := jtkString;
  FText := EndP;

  if WCharInSetFast(Ch, [#10, #13]) then
    TJsonReader.InvalidStringCharacterError(Self);
end;

{$IFDEF CPUX64}
function ParseUInt64(P, EndP: PWideChar): UInt64;
// RCX = P
// RDX = EndP
asm
  cmp rcx, rdx
  jge @@LeaveFail

  mov r8, rdx
  sub rcx, r8
  // r8+rcx = EndP + NegOffset = P => NegOffset can be incremented and checked for zero

  movzx rax, WORD PTR [r8+rcx]
  sub ax, '0'
  add rcx, 2
  jz @@Leave

@@Loop:
  add rax, rax
  // rax = 2*Result
  lea rax, [rax+rax*4]
  // rax = (2*Result)*4 + (2*Result) = 10*Result

  movzx rdx, WORD PTR [r8+rcx]
  sub dx, '0'
  add rax, rdx

  add rcx, 2
  jnz @@Loop

@@Leave:
  ret
@@LeaveFail:
  xor rax, rax
end;
{$ELSE}
  {$IFDEF CPUX86}
function ParseUInt64(P, EndP: PWideChar): UInt64;
asm
  cmp eax, edx
  jge @@LeaveFail

  push esi
  push edi
  push ebx

  mov esi, edx
  mov edi, eax
  sub edi, edx
  // esi+edi = EndP + NegOffset = P => NegOffset can be incremented and checked for zero

  xor edx, edx
  movzx eax, WORD PTR [esi+edi]
  sub ax, '0'
  add edi, 2
  jz @@PopLeave

@@Loop:
  add eax, eax
  adc edx, edx
  // eax:edx = 2*Result
  mov ebx, eax
  mov ecx, edx
  // ebx:ecx = 2*Result
  shld edx, eax, 2
  shl eax, 2
  // eax:edx = (2*Result)*4
  add eax, ebx
  adc edx, ecx
  // eax:edx = (2*Result)*4 + (2*Result) = 10*Result

  movzx ecx, WORD PTR [esi+edi]
  sub cx, '0'
  add eax, ecx
  adc edx, 0

  add edi, 2
  jnz @@Loop

@@PopLeave:
  pop ebx
  pop edi
  pop esi
@@Leave:
  ret
@@LeaveFail:
  xor eax, eax
  xor edx, edx
end;
  {$ELSE}
function ParseUInt64(P, EndP: PWideChar): UInt64;
begin
  if P = EndP then
    Result := 0
  else
  begin
    Result := Ord(P^) - Ord('0');
    Inc(P);
    while P < EndP do
    begin
      Result := Result * 10 + (Ord(P^) - Ord('0'));
      Inc(P);
    end;
  end;
end;
  {$ENDIF CPUX86}
{$ENDIF CPUX64}

function ParseAsDouble(F, P: PWideChar): Double;
begin
  Result := 0.0;
  while F < P do
  begin
    Result := Result * 10 + (Ord(F^) - Ord('0'));
    Inc(F);
  end;
end;

procedure TStringJsonReader.LexNumber(P: PChar{$IFDEF CPUARM}; EndP: PChar{$ENDIF});
var
  F: PChar;
  {$IFNDEF CPUARM}
  EndP: PChar;
  {$ENDIF ~CPUARM}
  EndInt64P: PChar;
  Ch: Char;
  Value, Scale: Double;
  Exponent, IntValue: Integer;
  Neg, NegE: Boolean;
  DigitCount: Integer;
begin
  {$IFNDEF CPUARM}
  EndP := FTextEnd;
  {$ENDIF ~CPUARM}
  Neg := False;

  Ch := P^;
  if Ch = '-' then
  begin
    Inc(P);
    if P >= EndP then
    begin
      FLook.Kind := jtkInvalidSymbol;
      FText := P;
      Exit;
    end;
    Neg := True;
    Ch := P^;
  end;
  F := P;

  Inc(P);
  if Ch <> '0' then
  begin
    if WCharInSetFast(Ch, ['1'..'9']) then
    begin
      while (P < EndP) and WCharInSetFast(P^, ['0'..'9']) do
        Inc(P);
    end
    else
    begin
      FLook.Kind := jtkInvalidSymbol;
      FText := P;
      Exit;
    end;
  end;

  DigitCount := P - F;
  if DigitCount <= 9 then // Int32 fits 9 digits
  begin
    IntValue := 0;
    while F < P do
    begin
      IntValue := IntValue * 10 + (Ord(F^) - Ord('0'));
      Inc(F);
    end;
    FLook.HI := 0;
    FLook.I := IntValue;
    FLook.Kind := jtkInt;
    if not WCharInSetFast(P^, ['.', 'E', 'e']) then
    begin
      // just an integer
      if Neg then
        FLook.I := -FLook.I;
      FText := P;
      Exit;
    end;
    Value := FLook.I;
  end
  else if DigitCount <= 20 then // UInt64 fits 20 digits (not all)
  begin
    FLook.U := ParseUInt64(F, P);
    if (DigitCount = 20) and (FLook.U mod 10 <> Ord(PWideChar(P - 1)^) - Ord('0')) then // overflow => too large
      Value := ParseAsDouble(F, P)
    else if Neg and ((DigitCount = 20) or ((DigitCount = 19) and (FLook.HI and $80000000 <> 0))) then
      // "negative UInt64" doesn't fit into UInt64/Int64 => use Double
      Value := FLook.U
    else
    begin
      FLook.Kind := jtkLong;
      case DigitCount of
        19:
         if FLook.HI and $80000000 <> 0 then // can't be negative because we cached that case already
           FLook.Kind := jtkULong;
        20:
          FLook.Kind := jtkULong;
      end;

      if not WCharInSetFast(P^, ['.', 'E', 'e']) then
      begin
        // just an integer
        if Neg then
        begin
          if (FLook.HI = 0) and (FLook.I >= 0) then // 32bit Integer
          begin
            FLook.I := -FLook.I;
            FLook.Kind := jtkInt;
          end
          else                 // 64bit Integer
            FLook.L := -FLook.L;
        end;
        FText := P;
        Exit;
      end;
      Value := FLook.U;
    end;
  end
  else
    Value := ParseAsDouble(F, P);

  // decimal digits
  if (P + 1 < EndP) and (P^ = '.') then
  begin
    Inc(P);
    F := P;
    EndInt64P := F + 18;
    if EndInt64P > EndP then
      EndInt64P := EndP;
    while (P < EndInt64P) and WCharInSetFast(P^, ['0'..'9']) do
      Inc(P);
    Value := Value + ParseUInt64(F, P) / Power10[P - F];

    // "Double" can't handle that many digits
    while (P < EndP) and WCharInSetFast(P^, ['0'..'9']) do
      Inc(P);
  end;

  // exponent
  if (P < EndP) and ((P^ = 'e') or (P^ = 'E')) then
  begin
    Inc(P);
    NegE := False;
    if (P < EndP) then
    begin
      case P^ of
        '-':
          begin
            NegE := True;
            Inc(P);
          end;
        '+':
          Inc(P);
      end;
      Exponent := 0;
      F := P;
      while (P < EndP) and WCharInSetFast(P^, ['0'..'9']) do
      begin
        Exponent := Exponent * 10 + (Ord(P^) - Ord('0'));
        Inc(P);
      end;
      if P = F then
      begin
        // no exponent
        FLook.Kind := jtkInvalidSymbol;
        FText := P;
        Exit;
      end;

      if Exponent > 308 then
        Exponent := 308;

      Scale := 1.0;
      while Exponent >= 50 do
      begin
        Scale := Scale * 1E50;
        Dec(Exponent, 50);
      end;
      while Exponent >= 18 do
      begin
        Scale := Scale * 1E18;
        Dec(Exponent, 18);
      end;
      Scale := Scale * Power10[Exponent];

      if NegE then
        Value := Value / Scale
      else
        Value := Value * Scale;
    end
    else
    begin
      FLook.Kind := jtkInvalidSymbol;
      FText := P;
      Exit;
    end;
  end;

  if Neg then
    FLook.F := -Value
  else
    FLook.F := Value;
  FLook.Kind := jtkFloat;
  FText := P;
end;

procedure TStringJsonReader.LexIdent(P: PChar{$IFDEF CPUARM}; EndP: PChar{$ENDIF});
const
  {$IFDEF BIGENDIAN}
  // Big Endian
  NullStr1 = UInt32((Ord('n') shl 16) or Ord('u'));
  NullStr2 = UInt32((Ord('l') shl 16) or Ord('l'));
  TrueStr1 = UInt32((Ord('t') shl 16) or Ord('r'));
  TrueStr2 = UInt32((Ord('u') shl 16) or Ord('e'));
  FalseStr1 = UInt32((Ord('a') shl 16) or Ord('l'));
  FalseStr2 = UInt32((Ord('s') shl 16) or Ord('e'));
  {$ELSE}
  // Little Endian
  NullStr1 = UInt32(Ord('n') or (Ord('u') shl 16));
  NullStr2 = UInt32(Ord('l') or (Ord('l') shl 16));
  TrueStr1 = UInt32(Ord('t') or (Ord('r') shl 16));
  TrueStr2 = UInt32(Ord('u') or (Ord('e') shl 16));
  FalseStr1 = UInt32(Ord('a') or (Ord('l') shl 16));
  FalseStr2 = UInt32(Ord('s') or (Ord('e') shl 16));
  {$ENDIF BIGENDIAN}
var
  F: PChar;
  {$IFNDEF CPUARM}
  EndP: PChar;
  {$ENDIF ~CPUARM}
  L: UInt32;
begin
  F := P;
  {$IFNDEF CPUARM}
  EndP := FTextEnd;
  {$ENDIF ~CPUARM}
  case P^ of
    'A'..'Z', 'a'..'z', '_', '$':
      begin
        Inc(P);
//        DCC64 generates "bt mem,reg" code
//        while (P < EndP) and (P^ in ['A'..'Z', 'a'..'z', '_', '0'..'9']) do
//          Inc(P);
        while P < EndP do
          case P^ of
            'A'..'Z', 'a'..'z', '_', '0'..'9': Inc(P);
          else
            Break;
          end;

        L := P - F;
        if L = 4 then
        begin
          L := PUInt32(F)^;
          if (L = NullStr1) and (PUInt32(F + 2)^ = NullStr2) then
            FLook.Kind := jtkNull
          else if (L = TrueStr1) and (PUInt32(F + 2)^ = TrueStr2) then
            FLook.Kind := jtkTrue
          else
          begin
            SetString(FLook.S, F, P - F);
            FLook.Kind := jtkIdent;
          end;
        end
        else if (L = 5) and (F^ = 'f') and (PUInt32(F + 1)^ = FalseStr1) and (PUInt32(F + 3)^ = FalseStr2) then
          FLook.Kind := jtkFalse
        else
        begin
          SetString(FLook.S, F, P - F);
          FLook.Kind := jtkIdent;
        end;
      end;
  else
    FLook.Kind := jtkInvalidSymbol;
    Inc(P);
  end;
  FText := P;
end;

{ TEncodingStrictAccess }

function TEncodingStrictAccess.GetByteCountEx(Chars: PChar; CharCount: Integer): Integer;
begin
  Result := GetByteCount(Chars, CharCount);
end;

function TEncodingStrictAccess.GetBytesEx(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer;
begin
  Result := GetBytes(Chars, CharCount, Bytes, ByteCount);
end;

function TEncodingStrictAccess.GetCharCountEx(Bytes: PByte; ByteCount: Integer): Integer;
begin
  Result := GetCharCount(Bytes, ByteCount);
end;

function TEncodingStrictAccess.GetCharsEx(Bytes: PByte; ByteCount: Integer; Chars: PChar; CharCount: Integer): Integer;
begin
  Result := GetChars(Bytes, ByteCount, Chars, CharCount);
end;

initialization
  {$IFDEF USE_NAME_STRING_LITERAL}
  InitializeJsonMemInfo;
  {$ENDIF USE_NAME_STRING_LITERAL}
  {$IFDEF MSWINDOWS}
    {$IFDEF SUPPORT_WINDOWS2000}
  TzSpecificLocalTimeToSystemTime := GetProcAddress(GetModuleHandle(kernel32), PAnsiChar('TzSpecificLocalTimeToSystemTime'));
  if not Assigned(TzSpecificLocalTimeToSystemTime) then
    TzSpecificLocalTimeToSystemTime := TzSpecificLocalTimeToSystemTimeWin2000;
    {$ENDIF SUPPORT_WINDOWS2000}
  {$ENDIF MSWINDOWS}
  // Make sTrue and sFalse a mutable string (RefCount<>-1) so that UStrAsg doesn't always
  // create a new string.
  JsonFormatSettings.DecimalSeparator := '.';

end.
