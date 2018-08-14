unit DSLAnsiFunctions;

interface

uses
  SysUtils, Classes, SysConst, RTLConsts, WideStrings, Windows, AnsiStrings;

type
  TRawByteStrings = class;

  IRawByteStringsAdapter = interface
    ['{25FE0E3B-66CB-48AA-B23B-BCFA67E8F5DA}']
    procedure ReferenceStrings(S: TRawByteStrings);
    procedure ReleaseStrings;
  end;

  { TRawByteStrings class }

  TRawByteStringsEnumerator = class
  private
    FIndex: Integer;
    FStrings: TRawByteStrings;
  public
    constructor Create(AStrings: TRawByteStrings);
    function GetCurrent: RawByteString; inline;
    function MoveNext: Boolean;
    property Current: RawByteString read GetCurrent;
  end;

  TRawByteStrings = class(TPersistent)
  private
    FDefined: TStringsDefined;
    FDelimiter: AnsiChar;
    FLineBreak: RawByteString;
    FQuoteChar: AnsiChar;
    FNameValueSeparator: AnsiChar;
    FStrictDelimiter: Boolean;
    FUpdateCount: Integer;
    FAdapter: IRawByteStringsAdapter;
    FCodePage: Integer;
    function GetCommaText: RawByteString;
    function GetDelimitedText: RawByteString;
    function GetName(Index: Integer): RawByteString;
    function GetValue(const Name: RawByteString): RawByteString;
    procedure ReadData(Reader: TReader);
    procedure SetCommaText(const Value: RawByteString);
    procedure SetDelimitedText(const Value: RawByteString);
    procedure SetStringsAdapter(const Value: IRawByteStringsAdapter);
    procedure SetValue(const Name, Value: RawByteString);
    procedure WriteData(Writer: TWriter);
    function GetDelimiter: AnsiChar;
    procedure SetDelimiter(const Value: AnsiChar);
    function GetLineBreak: RawByteString;
    procedure SetLineBreak(const Value: RawByteString);
    function GetQuoteChar: AnsiChar;
    procedure SetQuoteChar(const Value: AnsiChar);
    function GetNameValueSeparator: AnsiChar;
    procedure SetNameValueSeparator(const Value: AnsiChar);
    function GetStrictDelimiter: Boolean;
    procedure SetStrictDelimiter(const Value: Boolean);
    function GetValueFromIndex(Index: Integer): RawByteString;
    procedure SetValueFromIndex(Index: Integer; const Value: RawByteString);
    procedure SetCharset(const Value: AnsiString);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Error(const Msg: string; Data: Integer); overload;
    procedure Error(Msg: PResStringRec; Data: Integer); overload;
    function ExtractName(const S: RawByteString): RawByteString;
    function Get(Index: Integer): RawByteString; virtual; abstract;
    function GetCapacity: Integer; virtual;
    function GetCount: Integer; virtual; abstract;
    function GetObject(Index: Integer): TObject; virtual;
    function GetTextStr: RawByteString; virtual;
    procedure Put(Index: Integer; const S: RawByteString); virtual;
    procedure PutObject(Index: Integer; AObject: TObject); virtual;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure SetTextStr(const Value: RawByteString); virtual;
    procedure SetUpdateState(Updating: Boolean); virtual;
    property UpdateCount: Integer read FUpdateCount;
    function CompareStrings(const S1, S2: RawByteString): Integer; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const S: RawByteString): Integer; virtual;
    function AddObject(const S: RawByteString; AObject: TObject): Integer; virtual;
    procedure Append(const S: RawByteString);
    procedure AddStrings(Strings: TStrings); overload; virtual;
    procedure AddStrings(Strings: TWideStrings); overload; virtual;
    procedure AddStrings(Strings: TRawByteStrings); overload; virtual;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Clear; virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    procedure EndUpdate;
    function Equals(Strings: TRawByteStrings): Boolean; reintroduce;
    procedure Exchange(Index1, Index2: Integer); virtual;
    function GetEnumerator: TRawByteStringsEnumerator;
    function GetText: PAnsiChar; virtual;
    function IndexOf(const S: RawByteString): Integer; virtual;
    function IndexOfName(const Name: RawByteString): Integer; virtual;
    function IndexOfObject(AObject: TObject): Integer; virtual;
    procedure Insert(Index: Integer; const S: RawByteString); virtual; abstract;
    procedure InsertObject(Index: Integer; const S: RawByteString; AObject: TObject); virtual;
    procedure LoadFromFile(const FileName: string); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    procedure SaveToFile(const FileName: string); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure SetText(Text: PAnsiChar); virtual;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property CommaText: RawByteString read GetCommaText write SetCommaText;
    property Count: Integer read GetCount;
    property Delimiter: AnsiChar read GetDelimiter write SetDelimiter;
    property DelimitedText: RawByteString read GetDelimitedText write
      SetDelimitedText;
    property LineBreak: RawByteString read GetLineBreak write SetLineBreak;
    property Names[Index: Integer]: RawByteString read GetName;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property QuoteChar: AnsiChar read GetQuoteChar write SetQuoteChar;
    property Values[const Name: RawByteString]
      : RawByteString read GetValue write SetValue;
    property ValueFromIndex[Index: Integer]
      : RawByteString read GetValueFromIndex write SetValueFromIndex;
    property NameValueSeparator: AnsiChar read GetNameValueSeparator write
      SetNameValueSeparator;
    property StrictDelimiter: Boolean read GetStrictDelimiter write
      SetStrictDelimiter;
    property Strings[Index: Integer]: RawByteString read Get write Put; default;
    property Text: RawByteString read GetTextStr write SetTextStr;
    property StringsAdapter: IRawByteStringsAdapter read FAdapter write
      SetStringsAdapter;
    property Charset: AnsiString write SetCharset;
    property Codepage: Integer read FCodePage write FCodePage;
  end;

  TRawByteStringList = class;

  PRawByteStringItem = ^TRawByteStringItem;

  TRawByteStringItem = record
    FString: RawByteString;
    FObject: TObject;
  end;

  PRawByteStringItemList = ^TRawByteStringItemList;
  TRawByteStringItemList = array [0 .. 128*1024*1024-1] of TRawByteStringItem;
  TRawByteStringListSortCompare = function(List: TRawByteStringList;
    Index1, Index2: Integer): Integer;

  TRawByteStringList = class(TRawByteStrings)
  private
    FList: PRawByteStringItemList;
    FCount: Integer;
    FCapacity: Integer;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FCaseSensitive: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    FOwnsObject: Boolean;
    procedure ExchangeItems(Index1, Index2: Integer);
    procedure Grow;
    procedure QuickSort(L, R: Integer; SCompare: TRawByteStringListSortCompare);
    procedure SetSorted(Value: Boolean);
    procedure SetCaseSensitive(const Value: Boolean);
  protected
    procedure Changed; virtual;
    procedure Changing; virtual;
    function Get(Index: Integer): RawByteString; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: RawByteString); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetUpdateState(Updating: Boolean); override;
    function CompareStrings(const S1, S2: RawByteString): Integer; override;
    procedure InsertItem(Index: Integer; const S: RawByteString;
      AObject: TObject); virtual;
  public
    constructor Create; overload;
    constructor Create(OwnsObjects: Boolean); overload;
    destructor Destroy; override;
    function Add(const S: RawByteString): Integer; override;
    function AddObject(const S: RawByteString; AObject: TObject): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function Find(const S: RawByteString; var Index: Integer): Boolean; virtual;
    function IndexOf(const S: RawByteString): Integer; override;
    procedure Insert(Index: Integer; const S: RawByteString); override;
    procedure InsertObject(Index: Integer; const S: RawByteString;
      AObject: TObject); override;
    procedure Sort; virtual;
    procedure CustomSort(Compare: TRawByteStringListSortCompare); virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OwnsObjects: Boolean read FOwnsObject write FOwnsObject;
  end;

  TRawByteStringStream = class(TStream)
  private
    FDataString: RawByteString;
    FPosition: Integer;
  protected
    procedure SetSize(NewSize: Longint); override;
  public
    constructor Create(const AString: RawByteString);
    function Read(var Buffer; Count: Longint): Longint; override;
    function ReadString(Count: Longint): RawByteString;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure WriteString(const AString: RawByteString);
    property DataString: RawByteString read FDataString;
  end;

function _RBStrCompareText(const s1, s2: RawByteString): Integer;
function _RBStrSameText(const s1, s2: RawByteString): Boolean;
function _RBStrFormatFloat(const Format: RawByteString; Value: Extended): RawByteString;
function _RBStrTrim(const S: RawByteString): RawByteString;
function _RBStrTrimLeft(const S: RawByteString): RawByteString;
function _RBStrTrimRight(const S: RawByteString): RawByteString;

var
  AnsiStrScan: function(Str: PAnsiChar; Chr: AnsiChar): PAnsiChar;

implementation

procedure ConvertError(ResString: PResStringRec); local;
begin
  raise EConvertError.CreateRes(ResString);
end;

function _RBStrCompareText(const s1, s2: RawByteString): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := CompareStringA(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PAnsiChar(s1), Length(s1),
    PAnsiChar(s2), Length(s2)) - CSTR_EQUAL;
{$ENDIF}
{$IFDEF LINUX}
  Result := strcoll(S1, S2);
{$ENDIF}
end;

function _RBStrSameText(const s1, s2: RawByteString): Boolean;
begin
{$IFDEF MSWINDOWS}
  Result := CompareStringA(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PAnsiChar(s1), Length(s1),
    PAnsiChar(s2), Length(s2)) = CSTR_EQUAL;
{$ENDIF}
{$IFDEF LINUX}
  Result := strcoll(S1, S2) = 0;
{$ENDIF}
end;

function _RBStrFormatFloat(const Format: RawByteString; Value: Extended): RawByteString;
var
  Buffer: array[0..255] of AnsiChar;
begin
  if Length(Format) > Length(Buffer) - 32 then
    ConvertError(PResStringRec(@SFormatTooLong));

  SetString(Result, Buffer, {$if CompilerVersion > 22}AnsiStrings.{$ifend}FloatToTextFmt(Buffer, Value, fvExtended,
    PAnsiChar(Format)));
end;

function _RBStrTrim(const S: RawByteString): RawByteString;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I > L then Result := '' else
  begin
    while S[L] <= ' ' do Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
end;

function _RBStrTrimLeft(const S: RawByteString): RawByteString;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  Result := Copy(S, I, Maxint);
end;

function _RBStrTrimRight(const S: RawByteString): RawByteString;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] <= ' ') do Dec(I);
  Result := Copy(S, 1, I);
end;

function RawByteQuotedStr(const S: RawByteString; Quote: AnsiChar): RawByteString;
var
  P, Src, Dest: PAnsiChar;
  AddCount: Integer;
begin
  AddCount := 0;
  P := AnsiStrScan(PAnsiChar(S), Quote);
  while P <> nil do
  begin
    Inc(P);
    Inc(AddCount);
    P := AnsiStrScan(P, Quote);
  end;
  if AddCount = 0 then
  begin
    Result := Quote + S + Quote;
    Exit;
  end;
  SetLength(Result, Length(S) + AddCount + 2);
  Dest := PAnsiChar(Result);
  Dest^ := Quote;
  Inc(Dest);
  Src := PAnsiChar(S);
  P := AnsiStrScan(Src, Quote);
  repeat
    Inc(P);
    Move(Src^, Dest^, (P - Src));
    Inc(Dest, P - Src);
    Dest^ := Quote;
    Inc(Dest);
    Src := P;
    P := AnsiStrScan(Src, Quote);
  until P = nil;
  P := {$if CompilerVersion > 22}AnsiStrings.{$ifend}StrEnd(Src);
  Move(Src^, Dest^, (P - Src));
  Inc(Dest, P - Src);
  Dest^ := Quote;
end;

{ TRawByteStringsEnumerator }

constructor TRawByteStringsEnumerator.Create(AStrings: TRawByteStrings);
begin
  inherited Create;
  FIndex := -1;
  FStrings := AStrings;
end;

function TRawByteStringsEnumerator.GetCurrent: RawByteString;
begin
  Result := FStrings[FIndex];
end;

function TRawByteStringsEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FStrings.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TRawByteStrings }

destructor TRawByteStrings.Destroy;
begin
  StringsAdapter := nil;
  inherited Destroy;
end;

function TRawByteStrings.Add(const S: RawByteString): Integer;
begin
  Result := GetCount;
  Insert(Result, S);
end;

function TRawByteStrings.AddObject(const S: RawByteString;
  AObject: TObject): Integer;
begin
  Result := Add(S);
  PutObject(Result, AObject);
end;

procedure TRawByteStrings.AddStrings(Strings: TStrings);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Strings.Count - 1 do
      AddObject(RawByteString(Strings[I]), Strings.Objects[I]);
  finally
    EndUpdate;
  end;
end;

procedure TRawByteStrings.AddStrings(Strings: TWideStrings);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Strings.Count - 1 do
      AddObject(RawByteString(Strings[I]), Strings.Objects[I]);
  finally
    EndUpdate;
  end;
end;

procedure TRawByteStrings.AddStrings(Strings: TRawByteStrings);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Strings.Count - 1 do
      AddObject(RawByteString(Strings[I]), Strings.Objects[I]);
  finally
    EndUpdate;
  end;
end;

procedure TRawByteStrings.Append(const S: RawByteString);
begin
  Add(S);
end;

procedure TRawByteStrings.Assign(Source: TPersistent);
begin
  if Source is TRawByteStrings then
  begin
    BeginUpdate;
    try
      Clear;
      FDefined := TRawByteStrings(Source).FDefined;
      FNameValueSeparator := TRawByteStrings(Source).FNameValueSeparator;
      FQuoteChar := TRawByteStrings(Source).FQuoteChar;
      FDelimiter := TRawByteStrings(Source).FDelimiter;
      FLineBreak := TRawByteStrings(Source).FLineBreak;
      FStrictDelimiter := TRawByteStrings(Source).FStrictDelimiter;
      AddStrings(TRawByteStrings(Source));
    finally
      EndUpdate;
    end;
  end
  else if Source is TStrings then
  begin
    BeginUpdate;
    try
      Clear;
      FNameValueSeparator := AnsiChar
        (TStrings(Source).NameValueSeparator);
      FQuoteChar := AnsiChar(TStrings(Source).QuoteChar);
      FDelimiter := AnsiChar(TStrings(Source).Delimiter);
      FLineBreak := RawByteString(TStrings(Source).LineBreak);
      FStrictDelimiter := TStrings(Source).StrictDelimiter;
      AddStrings(TStrings(Source));
    finally
      EndUpdate;
    end;
  end
  else if Source is TWideStrings then
  begin
    BeginUpdate;
    try
      Clear;
      FNameValueSeparator := AnsiChar(TWideStrings(Source).NameValueSeparator);
      FQuoteChar := AnsiChar(TWideStrings(Source).QuoteChar);
      FDelimiter := AnsiChar(TWideStrings(Source).Delimiter);
      FLineBreak := RawByteString(TWideStrings(Source).LineBreak);
      FStrictDelimiter := TWideStrings(Source).StrictDelimiter;
      AddStrings(TWideStrings(Source));
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TRawByteStrings.AssignTo(Dest: TPersistent);
var
  I: Integer;
begin
  if Dest is TRawByteStrings then
    Dest.Assign(Self)
  else if Dest is TStrings then
  begin
    TStrings(Dest).BeginUpdate;
    try
      TStrings(Dest).Clear;
      TStrings(Dest).NameValueSeparator := WideChar(NameValueSeparator);
      TStrings(Dest).QuoteChar := WideChar(QuoteChar);
      TStrings(Dest).Delimiter := WideChar(Delimiter);
      TStrings(Dest).LineBreak := UnicodeString(LineBreak);
      TStrings(Dest).StrictDelimiter := StrictDelimiter;

      for I := 0 to Count - 1 do
        TStrings(Dest).AddObject(UnicodeString(Strings[I]), Objects[I]);
    finally
      TStrings(Dest).EndUpdate;
    end;
  end
  else if Dest is TWideStrings then
  begin
    TWideStrings(Dest).BeginUpdate;
    try
      TWideStrings(Dest).Clear;
      TWideStrings(Dest).NameValueSeparator := WideChar(NameValueSeparator);
      TWideStrings(Dest).QuoteChar := WideChar(QuoteChar);
      TWideStrings(Dest).Delimiter := WideChar(Delimiter);
      TWideStrings(Dest).LineBreak := WideString(LineBreak);
      TWideStrings(Dest).StrictDelimiter := StrictDelimiter;

      for I := 0 to Count - 1 do
        TWideStrings(Dest).AddObject(WideString(Strings[I]), Objects[I]);
    finally
      TWideStrings(Dest).EndUpdate;
    end;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TRawByteStrings.BeginUpdate;
begin
  if FUpdateCount = 0 then
    SetUpdateState(True);
  Inc(FUpdateCount);
end;

procedure TRawByteStrings.DefineProperties(Filer: TFiler);

  function DoWrite: Boolean;
  begin
    if Filer.Ancestor <> nil then
    begin
      Result := True;
      if Filer.Ancestor is TRawByteStrings then
        Result := not Equals(TRawByteStrings(Filer.Ancestor))
    end
    else
      Result := Count > 0;
  end;

begin
  Filer.DefineProperty('Strings', ReadData, WriteData, DoWrite);
end;

procedure TRawByteStrings.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
    SetUpdateState(False);
end;

function TRawByteStrings.Equals(Strings: TRawByteStrings): Boolean;
var
  I, Count: Integer;
begin
  Result := False;
  Count := GetCount;
  if Count <> Strings.GetCount then
    Exit;
  for I := 0 to Count - 1 do
    if Get(I) <> Strings.Get(I) then
      Exit;
  Result := True;
end;

procedure TRawByteStrings.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EStringListError.CreateFmt(Msg, [Data])at ReturnAddr;
end;

procedure TRawByteStrings.Error(Msg: PResStringRec; Data: Integer);
begin
  Error(LoadResString(Msg), Data);
end;

procedure TRawByteStrings.Exchange(Index1, Index2: Integer);
var
  TempObject: TObject;
  TempString: RawByteString;
begin
  BeginUpdate;
  try
    TempString := Strings[Index1];
    TempObject := Objects[Index1];
    Strings[Index1] := Strings[Index2];
    Objects[Index1] := Objects[Index2];
    Strings[Index2] := TempString;
    Objects[Index2] := TempObject;
  finally
    EndUpdate;
  end;
end;

function TRawByteStrings.ExtractName(const S: RawByteString): RawByteString;
var
  P: PAnsiChar;
begin
  P := AnsiStrScan(PAnsiChar(S), NameValueSeparator);

  if Assigned(P) then
    Result := Copy(S, 1, P - PAnsiChar(S))
  else
    Result := '';
end;

function TRawByteStrings.GetCapacity: Integer;
begin
  Result := Count;
end;

function TRawByteStrings.GetCommaText: RawByteString;
var
  LOldDefined: TStringsDefined;
  LOldDelimiter: AnsiChar;
  LOldQuoteChar: AnsiChar;
begin
  LOldDefined := FDefined;
  LOldDelimiter := FDelimiter;
  LOldQuoteChar := FQuoteChar;
  Delimiter := ',';
  QuoteChar := '"';
  try
    Result := GetDelimitedText;
  finally
    FDelimiter := LOldDelimiter;
    FQuoteChar := LOldQuoteChar;
    FDefined := LOldDefined;
  end;
end;

function TRawByteStrings.GetDelimitedText: RawByteString;

  function IsDelimiter(const ch: AnsiChar): Boolean;
  begin
    Result := True;
    if not StrictDelimiter and (ch <= ' ') then
      Exit
    else if ch = QuoteChar then
      Exit
    else if ch = Delimiter then
      Exit
    else if ch = #$00 then
      Exit;
    Result := False;
  end;

var
  S: RawByteString;
  I, J, L, Count: Integer;
begin
  Count := GetCount;
  if (Count = 1) and (Get(0) = '') then
  begin
    SetLength(Result, 2);
    PAnsiChar(Result)[0] := QuoteChar;
    PAnsiChar(Result)[1] := QuoteChar;
  end
  else
  begin
    Result := '';
    for I := 0 to Count - 1 do
    begin
      S := Get(I);
      L := Length(S);
      J := 1;

      while (J <= L) and not IsDelimiter(S[J]) do
        Inc(J);

      if (J <= L) then
        S := RawByteQuotedStr(S, QuoteChar);

      if I < Count - 1 then
        Result := Result + S + Delimiter
      else
        Result := Result + S;
    end;
  end;
end;

function TRawByteStrings.GetEnumerator: TRawByteStringsEnumerator;
begin
  Result := TRawByteStringsEnumerator.Create(Self);
end;

function TRawByteStrings.GetName(Index: Integer): RawByteString;
begin
  Result := ExtractName(Get(Index));
end;

function TRawByteStrings.GetObject(Index: Integer): TObject;
begin
  Result := nil;
end;

function TRawByteStrings.GetText: PAnsiChar;
begin
  Result := {$if CompilerVersion > 22}AnsiStrings.{$ifend}StrNew(PAnsiChar(GetTextStr));
end;

function TRawByteStrings.GetTextStr: RawByteString;
var
  I, L, Size, Count: Integer;
  P: PAnsiChar;
  S, LB: RawByteString;
begin
  Count := GetCount;
  Size := 0;
  LB := sLineBreak;
  for I := 0 to Count - 1 do
    Inc(Size, Length(Get(I)) + Length(LB));
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to Count - 1 do
  begin
    S := Get(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L);
      Inc(P, L);
    end;
    L := Length(LB);
    if L <> 0 then
    begin
      System.Move(Pointer(LB)^, P^, L);
      Inc(P, L);
    end;
  end;
end;

function TRawByteStrings.GetValue(const Name: RawByteString): RawByteString;
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if I >= 0 then
    Result := Copy(Get(I), Length(Name) + 2, MaxInt)
  else
    Result := '';
end;

function TRawByteStrings.IndexOf(const S: RawByteString): Integer;
begin
  for Result := 0 to GetCount - 1 do
    if CompareStrings(Get(Result), S) = 0 then
      Exit;
  Result := -1;
end;

function TRawByteStrings.IndexOfName(const Name: RawByteString): Integer;
var
  S: RawByteString;
begin
  for Result := 0 to GetCount - 1 do
  begin
    S := GetName(Result);
    if (S <> '') and (CompareStrings(S, Name) = 0) then
      Exit;
  end;
  Result := -1;
end;

function TRawByteStrings.IndexOfObject(AObject: TObject): Integer;
begin
  for Result := 0 to GetCount - 1 do
    if GetObject(Result) = AObject then
      Exit;
  Result := -1;
end;

procedure TRawByteStrings.InsertObject(Index: Integer; const S: RawByteString; AObject: TObject);
begin
  Insert(Index, S);
  PutObject(Index, AObject);
end;

procedure TRawByteStrings.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TRawByteStrings.LoadFromStream(Stream: TStream);
var
  Size: Integer;
  S: RawByteString;
begin
  BeginUpdate;
  try
    Size := Stream.Size - Stream.Position;
    SetString(S, nil, Size);
    Stream.Read(Pointer(S)^, Size);
    SetTextStr(S);
  finally
    EndUpdate;
  end;
end;

procedure TRawByteStrings.Move(CurIndex, NewIndex: Integer);
var
  TempObject: TObject;
  TempString: RawByteString;
begin
  if CurIndex <> NewIndex then
  begin
    BeginUpdate;
    try
      TempString := Get(CurIndex);
      TempObject := GetObject(CurIndex);
      Delete(CurIndex);
      InsertObject(NewIndex, TempString, TempObject);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TRawByteStrings.Put(Index: Integer; const S: RawByteString);
var
  TempObject: TObject;
begin
  TempObject := GetObject(Index);
  Delete(Index);
  InsertObject(Index, S, TempObject);
end;

procedure TRawByteStrings.PutObject(Index: Integer; AObject: TObject);
begin
end;

procedure TRawByteStrings.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  BeginUpdate;
  try
    Clear;
    while not Reader.EndOfList do
      Add(RawByteString(Reader.ReadStr));
  finally
    EndUpdate;
  end;
  Reader.ReadListEnd;
end;

procedure TRawByteStrings.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TRawByteStrings.SaveToStream(Stream: TStream);
var
  S: RawByteString;
begin
  S := GetTextStr;
  Stream.WriteBuffer(Pointer(S)^, Length(S) * SizeOf(AnsiChar));
end;

procedure TRawByteStrings.SetCapacity(NewCapacity: Integer);
begin

end;

procedure TRawByteStrings.SetCharset(const Value: AnsiString);
begin

end;

procedure TRawByteStrings.SetCommaText(const Value: RawByteString);
begin
  Delimiter := ',';
  QuoteChar := '"';
  SetDelimitedText(Value);
end;

procedure TRawByteStrings.SetStringsAdapter(const Value: IRawByteStringsAdapter);
begin
  if FAdapter <> nil then
    FAdapter.ReleaseStrings;
  FAdapter := Value;
  if FAdapter <> nil then
    FAdapter.ReferenceStrings(Self);
end;

procedure TRawByteStrings.SetText(Text: PAnsiChar);
begin
  SetTextStr(Text);
end;

procedure TRawByteStrings.SetTextStr(const Value: RawByteString);
var
  P, Start: PAnsiChar;
  S: RawByteString;
begin
  BeginUpdate;
  try
    Clear;
    P := Pointer(Value);
    if P <> nil then
      while P^ <> #0 do
      begin
        Start := P;
        while not(P^ in [AnsiChar(#0), AnsiChar(#10), AnsiChar(#13)]) do
          Inc(P);
        SetString(S, Start, P - Start);
        Add(S);
        if P^ = #13 then
          Inc(P);
        if P^ = #10 then
          Inc(P);
      end;
  finally
    EndUpdate;
  end;
end;

procedure TRawByteStrings.SetUpdateState(Updating: Boolean);
begin
end;

procedure TRawByteStrings.SetValue(const Name, Value: RawByteString);
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if Value <> '' then
  begin
    if I < 0 then I := Add('');
    Put(I, Name + NameValueSeparator + Value);
  end
  else begin
    if I >= 0 then Delete(I);
  end;
end;

procedure TRawByteStrings.WriteData(Writer: TWriter);
var
  I: Integer;
begin
  Writer.WriteListBegin;
  for I := 0 to Count - 1 do
    Writer.WriteStr(Get(I));
  Writer.WriteListEnd;
end;

procedure TRawByteStrings.SetDelimitedText(const Value: RawByteString);
var
  P, P1: PAnsiChar;
  S: RawByteString;
begin
  BeginUpdate;
  try
    Clear;
    P := PAnsiChar(Value);

    if not StrictDelimiter then
      while P^ in [#1..#32] do
        Inc(P);

    while P^ <> #0 do
    begin
      if P^ = QuoteChar then
        S := {$if CompilerVersion > 22}AnsiStrings.{$ifend}AnsiExtractQuotedStr(P, QuoteChar)
      else begin
        P1 := P;

        if FStrictDelimiter then
        begin
          while (P^ > #32) and (P^ <> Delimiter) do
            P := CharNextExA(FCodePage, P, 0);
        end
        else
        begin
          while (P^ <> #0) and (P^ <> Delimiter) do
            P := CharNextExA(FCodePage, P, 0);
        end;

        SetString(S, P1, P - P1);
      end;

      Add(S);

      if P^ = Delimiter then Inc(P);

      if not FStrictDelimiter then
        while P^ in [AnsiChar(#1) .. AnsiChar(' ')] do
          Inc(P);

      if P^ = Delimiter then
      begin
        Add('');
        Inc(P);
      end;
    end;
  finally
    EndUpdate;
  end;
end;

function TRawByteStrings.GetDelimiter: AnsiChar;
begin
  if not(sdDelimiter in FDefined) then
    Delimiter := ',';
  Result := FDelimiter;
end;

function TRawByteStrings.GetLineBreak: RawByteString;
begin
  if not(sdLineBreak in FDefined) then
    LineBreak := sLineBreak;
  Result := FLineBreak;
end;

function TRawByteStrings.GetQuoteChar: AnsiChar;
begin
  if not(sdQuoteChar in FDefined) then
    QuoteChar := '"';
  Result := FQuoteChar;
end;

function TRawByteStrings.GetStrictDelimiter: Boolean;
begin
  if not(sdStrictDelimiter in FDefined) then
    StrictDelimiter := False;
  Result := FStrictDelimiter;
end;

procedure TRawByteStrings.SetDelimiter(const Value: AnsiChar);
begin
  if (FDelimiter <> Value) or not(sdDelimiter in FDefined) then
  begin
    Include(FDefined, sdDelimiter);
    FDelimiter := Value;
  end
end;

procedure TRawByteStrings.SetLineBreak(const Value: RawByteString);
begin
  if (FLineBreak <> Value) or not(sdLineBreak in FDefined) then
  begin
    Include(FDefined, sdLineBreak);
    FLineBreak := Value;
  end
end;

procedure TRawByteStrings.SetQuoteChar(const Value: AnsiChar);
begin
  if (FQuoteChar <> Value) or not(sdQuoteChar in FDefined) then
  begin
    Include(FDefined, sdQuoteChar);
    FQuoteChar := Value;
  end
end;

procedure TRawByteStrings.SetStrictDelimiter(const Value: Boolean);
begin
  if (FStrictDelimiter <> Value) or not(sdStrictDelimiter in FDefined) then
  begin
    Include(FDefined, sdStrictDelimiter);
    FStrictDelimiter := Value;
  end
end;

function TRawByteStrings.CompareStrings(const S1, S2: RawByteString): Integer;
begin
  Result := CompareStringA(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
    PAnsiChar(S1), Length(S1), PAnsiChar(S2), Length(S2)) - CSTR_EQUAL;
end;

constructor TRawByteStrings.Create;
begin
  FCodePage := CP_ACP;
end;

function TRawByteStrings.GetNameValueSeparator: AnsiChar;
begin
  if not(sdNameValueSeparator in FDefined) then
    NameValueSeparator := '=';
  Result := FNameValueSeparator;
end;

procedure TRawByteStrings.SetNameValueSeparator(const Value: AnsiChar);
begin
  if (FNameValueSeparator <> Value) or not(sdNameValueSeparator in FDefined)
    then
  begin
    Include(FDefined, sdNameValueSeparator);
    FNameValueSeparator := Value;
  end
end;

function TRawByteStrings.GetValueFromIndex(Index: Integer): RawByteString;
begin
  if Index >= 0 then
    Result := Copy(Get(Index), Length(Names[Index]) + 2, MaxInt)
  else
    Result := '';
end;

procedure TRawByteStrings.SetValueFromIndex(Index: Integer;
  const Value: RawByteString);
begin
  if Value <> '' then
  begin
    if Index < 0 then Index := Add('');
    Put(Index, Names[Index] + NameValueSeparator + Value);
  end
  else if Index >= 0 then
    Delete(Index);
end;

{ TRawByteStringList }

destructor TRawByteStringList.Destroy;
var
  I: Integer;
begin
  FOnChange := nil;
  FOnChanging := nil;

  // In the event that we own the Objects make sure to free them all when we
  // destroy the stringlist.
  if OwnsObjects then
    for I := 0 to FCount - 1 do
      GetObject(I).Free;

  inherited;

  if FCount <> 0 then
    Finalize(FList^[0], FCount);
  FCount := 0;
  SetCapacity(0);
end;

function TRawByteStringList.Add(const S: RawByteString): Integer;
begin
  Result := AddObject(S, nil);
end;

function TRawByteStringList.AddObject(const S: RawByteString; AObject: TObject): Integer;
begin
  if not Sorted then Result := FCount
  else if Find(S, Result) then
    case Duplicates of
      dupIgnore:  Exit;
      dupError: Error(PResStringRec(@SDuplicateString), 0);
    end;

  InsertItem(Result, S, AObject);
end;

procedure TRawByteStringList.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TRawByteStringList.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure TRawByteStringList.Clear;
var
  I: Integer;
begin
  if FCount <> 0 then
  begin
    Changing;

    if OwnsObjects then
      for I := 0 to FCount - 1 do
        GetObject(I).Free;

    Finalize(FList^[0], FCount);
    FCount := 0;
    SetCapacity(0);
    Changed;
  end;
end;

procedure TRawByteStringList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(PResStringRec(@SListIndexError), Index);
  Changing;

  if OwnsObjects then
    GetObject(Index).Free;

  Finalize(FList^[Index]);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index], (FCount - Index) * SizeOf(TRawByteStringItem));
  Changed;
end;

procedure TRawByteStringList.Exchange(Index1, Index2: Integer);
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    Error(PResStringRec(@SListIndexError), Index1);
  if (Index2 < 0) or (Index2 >= FCount) then
    Error(PResStringRec(@SListIndexError), Index2);
  Changing;
  ExchangeItems(Index1, Index2);
  Changed;
end;

procedure TRawByteStringList.ExchangeItems(Index1, Index2: Integer);
var
  Temp: Pointer;
  Item1, Item2: PRawByteStringItem;
begin
  Item1 := @FList^[Index1];
  Item2 := @FList^[Index2];
  Temp := Pointer(Item1^.FString);
  Pointer(Item1^.FString) := Pointer(Item2^.FString);
  Pointer(Item2^.FString) := Temp;
  Temp := Item1^.FObject;
  Item1^.FObject := Item2^.FObject;
  Item2^.FObject := Temp;
end;

function TRawByteStringList.Find(const S: RawByteString; var Index: Integer): Boolean;
var
  L, H, I, c: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    c := CompareStrings(FList^[I].FString, S);
    if c < 0 then
      L := I + 1
    else
    begin
      H := I - 1;
      if c = 0 then
      begin
        Result := True;
        if Duplicates <> dupAccept then
          L := I;
      end;
    end;
  end;
  Index := L;
end;

function TRawByteStringList.Get(Index: Integer): RawByteString;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(PResStringRec(@SListIndexError), Index);
  Result := FList^[Index].FString;
end;

function TRawByteStringList.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TRawByteStringList.GetCount: Integer;
begin
  Result := FCount;
end;

function TRawByteStringList.GetObject(Index: Integer): TObject;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(PResStringRec(@SListIndexError), Index);
  Result := FList^[Index].FObject;
end;

procedure TRawByteStringList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else if FCapacity > 8 then
    Delta := 16
  else
    Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TRawByteStringList.IndexOf(const S: RawByteString): Integer;
begin
  if not Sorted then
    Result := inherited IndexOf(S)
  else if not Find(S, Result) then
    Result := -1;
end;

procedure TRawByteStringList.Insert(Index: Integer; const S: RawByteString);
begin
  InsertObject(Index, S, nil);
end;

procedure TRawByteStringList.InsertObject(Index: Integer; const S: RawByteString; AObject: TObject);
begin
  if Sorted then
    Error(PResStringRec(@SSortedListError), 0);
  if (Index < 0) or (Index > FCount) then
    Error(PResStringRec(@SListIndexError), Index);
  InsertItem(Index, S, AObject);
end;

procedure TRawByteStringList.InsertItem(Index: Integer;
  const S: RawByteString; AObject: TObject);
begin
  Changing;
  if FCount = FCapacity then
    Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(TRawByteStringItem));
  with FList^[Index] do
  begin
    Pointer(FString) := nil;
    FObject := AObject;
    FString := S;
  end;
  Inc(FCount);
  Changed;
end;

procedure TRawByteStringList.Put(Index: Integer; const S: RawByteString);
begin
  if Sorted then
    Error(PResStringRec(@SSortedListError), 0);
  if (Index < 0) or (Index >= FCount) then
    Error(PResStringRec(@SListIndexError), Index);
  Changing;
  FList^[Index].FString := S;
  Changed;
end;

procedure TRawByteStringList.PutObject(Index: Integer; AObject: TObject);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(PResStringRec(@SListIndexError), Index);
  Changing;
  FList^[Index].FObject := AObject;
  Changed;
end;

procedure TRawByteStringList.QuickSort(L, R: Integer; SCompare: TRawByteStringListSortCompare);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do Inc(I);
      while SCompare(Self, J, P) > 0 do Dec(J);
      if I <= J then
      begin
        ExchangeItems(I, J);
        if P = I then  P := J
        else if P = J then P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;

    if L < J then
      QuickSort(L, J, SCompare);

    L := I;
  until I >= R;
end;

procedure TRawByteStringList.SetCapacity(NewCapacity: Integer);
begin
  ReallocMem(FList, NewCapacity * SizeOf(TRawByteStringItem));
  FCapacity := NewCapacity;
end;

procedure TRawByteStringList.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then
  begin
    if Value then Sort;
    FSorted := Value;
  end;
end;

procedure TRawByteStringList.SetUpdateState(Updating: Boolean);
begin
  if Updating then Changing
  else Changed;
end;

function StringListCompareStrings(List: TRawByteStringList; Index1, Index2: Integer): Integer;
begin
  Result := List.CompareStrings(List.FList^[Index1].FString,
    List.FList^[Index2].FString);
end;

procedure TRawByteStringList.Sort;
begin
  CustomSort(StringListCompareStrings);
end;

procedure TRawByteStringList.CustomSort(Compare: TRawByteStringListSortCompare);
begin
  if not Sorted and (FCount > 1) then
  begin
    Changing;
    QuickSort(0, FCount - 1, Compare);
    Changed;
  end;
end;

function TRawByteStringList.CompareStrings(const S1, S2: RawByteString)
  : Integer;
begin
  if CaseSensitive then
    Result := CompareStringA(LOCALE_USER_DEFAULT, 0, PAnsiChar(S1),
      Length(S1), PAnsiChar(S2), Length(S2)) - CSTR_EQUAL
  else
    Result := CompareStringA(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
      PAnsiChar(S1), Length(S1), PAnsiChar(S2), Length(S2)) - CSTR_EQUAL;
end;

constructor TRawByteStringList.Create;
begin
  inherited;
end;

constructor TRawByteStringList.Create(OwnsObjects: Boolean);
begin
  inherited Create;
  FOwnsObject := OwnsObjects;
end;

procedure TRawByteStringList.SetCaseSensitive(const Value: Boolean);
begin
  if Value <> FCaseSensitive then
  begin
    FCaseSensitive := Value;
    if Sorted then Sort;
  end;
end;

{ TRawByteStringStream }

constructor TRawByteStringStream.Create(const AString: RawByteString);
begin
  inherited Create;
  FDataString := AString;
end;

function TRawByteStringStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := Length(FDataString) - FPosition;
  if Result > Count then Result := Count;
  Move(PAnsiChar(FDataString)[FPosition], Buffer, Result);
  Inc(FPosition, Result);
end;

function TRawByteStringStream.Write(const Buffer; Count: Longint): Longint;
begin
  if FPosition + Count > Length(FDataString) then
    SetLength(FDataString, FPosition + Count);

  Move(Buffer, PAnsiChar(FDataString)[FPosition], Count);
  Inc(FPosition, Count);

  Result := Count;
end;

function TRawByteStringStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: FPosition := FPosition + Offset;
    soFromEnd: FPosition := Length(FDataString) - Offset;
  end;
  if FPosition > Length(FDataString) then FPosition := Length(FDataString)
  else if FPosition < 0 then FPosition := 0;
  Result := FPosition;
end;

function TRawByteStringStream.ReadString(Count: Longint): RawByteString;
var
  Len: Integer;
begin
  Len := Length(FDataString) - FPosition;
  if Len > Count then Len := Count;
  SetString(Result, PAnsiChar(FDataString) + FPosition, Len);
  Inc(FPosition, Len);
end;

procedure TRawByteStringStream.WriteString(const AString: RawByteString);
begin
  Write(Pointer(AString)^, Length(AString));
end;

procedure TRawByteStringStream.SetSize(NewSize: Longint);
begin
  SetLength(FDataString, NewSize);
  if FPosition > NewSize then FPosition := NewSize;
end;

initialization
  {$if CompilerVersion > 22}
  AnsiStrScan := AnsiStrings.AnsiStrScan;
  {$else}
  AnsiStrScan := SysUtils.AnsiStrScan;
  {$ifend}

finalization

end.