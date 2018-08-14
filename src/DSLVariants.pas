unit DSLVariants;
{$I Synopse.inc}

interface

uses
  SysUtils, Classes, Contnrs, TypInfo, Variants, VarUtils, DSLUtils;

{$IF not declared(varDeepData)}
const
  varDeepData = $BFE8;
{$IFEND}

type
  TVarObjectOption = (voNameCaseSensitive, voCheckForDuplicatedNames, voReturnNullForUnknownProperty,
    voValueCopiedByReference);

  TVarObjectOptions = set of TVarObjectOption;

  PDocVariantOptions = ^TVarObjectOptions;

const
  JSON_OPTIONS_FAST = [voReturnNullForUnknownProperty, voValueCopiedByReference];

type
  EVarObject = class(Exception);

  TVarObjectKind = (vokUndefined, vokObject);
  TStringDynArray = array of string;
  TVariantDynArray = array of Variant;

  PVarObject = ^TVarObject;
{$IFDEF UNICODE}
  TVarObject = record
  private
{$ELSE}
    TVarObject = object protected
{$ENDIF}
    FType: TVarType;
    FOptions: TVarObjectOptions;
    FKind: TVarObjectKind;
    FNames: TStringDynArray;
    FValues: TVariantDynArray;
    FCount: Integer;

    procedure SetCapacity(aValue: Integer);
    function GetCapacity: Integer; {$IFDEF HASINLINE} inline; {$ENDIF}

    function ForceItemIndex(const aName: string): Integer;
    function ForceItemData(const aName: string): PVariant;
    function GetItemData(const aName: string): PVariant;
    function GetString(const aName: string): string;
    procedure SetString(const aName: string; const aValue: string);
    function GetInt64(const aName: string): Int64;
    procedure SetInt64(const aName: string; const aValue: Int64);
    function GetBoolean(const aName: string): Boolean;
    procedure SetBoolean(const aName: string; aValue: Boolean);
    function GetDouble(const aName: string): Double;
    procedure SetDouble(const aName: string; const aValue: Double);
    procedure Exchange(v1, v2: Integer);
  public
    procedure Init(aOptions: TVarObjectOptions = []; aKind: TVarObjectKind = vokUndefined);
    procedure InitFast; overload;
    procedure InitFast(InitialCapacity: Integer; aKind: TVarObjectKind); overload;
    procedure Clear;
    procedure Reset;
    procedure SetCount(aCount: Integer);
    function InternalAdd(const aName: string): Integer;
    function IndexOf(const aName: string): Integer; overload;
    function IndexOf(aName: PChar; aNameLen: Integer): Integer; overload;
    function GetValueOrRaiseException(const aName: string): Variant;
    function GetValueOrDefault(const aName: string; const aDefault: Variant): Variant;
    function GetValueOrNull(const aName: string): Variant;
    function GetValueOrEmpty(const aName: string): Variant;
    function GetVarData(const aName: string; var aValue: TVarData): Boolean; overload;
    function GetVarData(const aName: string): PVarData; overload;
    function GetAsBoolean(const aName: string; out aValue: Boolean): Boolean;
    function GetAsInteger(const aName: string; out aValue: Integer): Boolean;
    function GetAsInt64(const aName: string; out aValue: Int64): Boolean;
    function GetAsDouble(const aName: string; out aValue: double): Boolean;
    function GetAsString(const aName: string; out aValue: string): Boolean;
    function GetAsDocVariant(const aName: string; out aValue: PVarObject): Boolean; overload;
    function GetAsDocVariantSafe(const aName: string): PVarObject;
    function GetAsPVariant(const aName: string; out aValue: PVariant): Boolean;
    procedure RetrieveValueOrRaiseException(aName: PChar; aNameLen: Integer; var Dest: Variant); overload;
    procedure RetrieveValueOrRaiseException(const aName: string; var Dest: Variant); overload;
    procedure RetrieveValueOrRaiseException(Index: Integer; var Dest: Variant); overload;
    procedure RetrieveNameOrRaiseException(Index: Integer; var Dest: string);
    procedure SetValueOrRaiseException(Index: Integer; const NewValue: Variant);
    function AddValue(const aName: string; const aValue: Variant): Integer; overload;
    function AddOrUpdate(const aName: string; const aValue: Variant; wasAdded: PBoolean = nil;
      OnlyAddMissing: Boolean = False): Integer;

    procedure AddOrUpdateObject(const NewValues: Variant; OnlyAddMissing: Boolean = False);
    procedure AddItems(const aValue: array of const );
    procedure AddFrom(const src: Variant);
    function Delete(Index: Integer): Boolean; overload;
    function Delete(const aName: string): Boolean; overload;
    procedure Sort;

    property Options: TVarObjectOptions read FOptions write FOptions;
    property Kind: TVarObjectKind read FKind;
    property VarType: Word read FType;
    property Count: Integer read FCount;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Names: TStringDynArray read FNames;
    property Values: TVariantDynArray read FValues;
    property S[const aName: string]: string read GetString write SetString;
    property I[const aName: string]: Int64 read GetInt64 write SetInt64;
    property B[const aName: string]: Boolean read GetBoolean write SetBoolean;
    property D[const aName: string]: Double read GetDouble write SetDouble;
  end;
{$A+}

  ISynVarInvokeable = interface
    ['{8ADFBCC5-AEC0-4B01-A5F8-94565B8924EE}']
    function DoFunction(var Dest: TVarData; const V: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean;
    function DoProcedure(const V: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean;
    function GetProperty(var Dest: TVarData; const V: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean;
    function SetProperty(const V: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean;
  end;

  TInvokableVarType = class(TCustomVariantType, ISynVarInvokeable)
  private
{$IFDEF FPC_VARIANTSETVAR}
    function _SetProperty(var V: TVarData; const Name: string; const Value: TVarData): Boolean;
{$ELSE}
    function _SetProperty(const V: TVarData; const Name: string; const Value: TVarData): Boolean;
{$ENDIF}
  protected
{$IFNDEF FPC}
{$IFNDEF DELPHI6OROLDER}

    function FixupIdent(const AText: string): string;
{$ENDIF}
{$ENDIF}
    procedure DispInvoke(Dest: PVarData; const Source: TVarData; CallDesc: PCallDesc; Params: Pointer); override;

    procedure IntGet(var Dest: TVarData; const V: TVarData; const Name: string); virtual; abstract;
    procedure IntSet(const V, Value: TVarData; const Name: string); virtual; abstract;
    procedure IntGetSubscript(var Dest: TVarData; const V: TVarData; const Name: string;
      const Arguments: TVarDataArray); virtual;
    procedure IntSetSubscript(const V: TVarData; const Name: string; const Arguments: TVarDataArray); virtual;
  public

    function GetProperty(var Dest: TVarData; const V: TVarData; const Name: String;
      const Arguments: TVarDataArray): Boolean;

{$IFDEF FPC_VARIANTSETVAR}
    function SetProperty(var V: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean;
{$ELSE}
    function SetProperty(const V: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean;
{$ENDIF}
    function DoFunction(var Dest: TVarData; const V: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean; virtual;

    function DoProcedure(const V: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean; virtual;

    procedure Clear(var V: TVarData); override;

    procedure Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean); override;

    procedure CopyByValue(var Dest: TVarData; const Source: TVarData); virtual;

    function IterateCount(const V: TVarData): Integer; virtual;

    procedure Iterate(var Dest: TVarData; const V: TVarData; Index: Integer); virtual;

  end;

  TSynInvokeableVariantTypeClass = class of TInvokableVarType;

  TVarObjType = class(TInvokableVarType)
  protected

    procedure IntGet(var Dest: TVarData; const V: TVarData; const Name: string); override;
    procedure IntSet(const V, Value: TVarData; const Name: string); override;
  public

    class procedure New(out aValue: Variant; aOptions: TVarObjectOptions = []); overload;
{$IFDEF HASINLINE} inline; {$ENDIF}

    class procedure NewFast(out aValue: Variant); overload;
{$IFDEF HASINLINE} inline; {$ENDIF}

    class procedure NewFast(const aValues: array of PVarObject); overload;

    class function New(Options: TVarObjectOptions = []): Variant; overload;
{$IFDEF HASINLINE} inline; {$ENDIF}
    class procedure GetSingleOrDefault(const docVariantArray, default: Variant; var Result: Variant);

    function DoFunction(var Dest: TVarData; const V: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean; override;

    procedure Clear(var V: TVarData); override;

    procedure Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean); override;

    procedure CopyByValue(var Dest: TVarData; const Source: TVarData); override;

    procedure Cast(var Dest: TVarData; const Source: TVarData); override;

    procedure CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType); override;

  end;

function SynRegisterCustomVariantType(aClass: TSynInvokeableVariantTypeClass): TInvokableVarType;

procedure VariantToJson(var S: AnsiString; const V: TVarData);
procedure ZeroFill(Value: PVarData); {$IFDEF HASINLINE} inline; {$ENDIF}
function SetVariantUnRefSimpleValue(const Source: Variant; var Dest: TVarData): Boolean;

implementation

var
  VarObjectHandler: TInvokableVarType = nil;
  VarObjectVarType: Integer = -1;

procedure ZeroFill(Value: PVarData);
var
  p: PInt64;
begin

  p := PInt64(Value);
  P^ := 0;
  Inc(p);
  p^ := 0;
{$IFDEF CPU64}

  Inc(p);
  p^ := 0;
{$ENDIF}
end;

function SetVariantUnRefSimpleValue(const Source: Variant; var Dest: TVarData): Boolean;
var
  typ: Word;
begin
  if TVarData(Source).VType and varByRef <> 0 then
  begin
    typ := TVarData(Source).VType and not varByRef;
    case typ of
      varVariant:
        if PVarData(TVarData(Source).VPointer)^.VType in [varEmpty .. varDate, varBoolean,
          varShortInt .. varUInt64] then
        begin
          Dest := PVarData(TVarData(Source).VPointer)^;
          Result := True;
        end
        else
          Result := False;
      varEmpty .. varDate, varBoolean, varShortInt .. varUInt64:
        begin
          Dest.VType := typ;
          Dest.VInt64 := PInt64(TVarData(Source).VAny)^;
          Result := True;
        end;
    else
      Result := False;
    end;
  end
  else
    Result := False;
end;

function CurrToWStrViaOS(const AValue: Currency): WideString;
begin
  VarResultCheck(VarBStrFromCy(AValue, VAR_LOCALE_USER_DEFAULT, 0, Result), varCurrency, varOleStr);
end;

function DateToWStrViaOS(const AValue: TDateTime): WideString;
begin
  VarResultCheck(VarBStrFromDate(AValue, VAR_LOCALE_USER_DEFAULT, 0, Result), varDate, varOleStr);
end;

function BoolToWStrViaOS(const AValue: WordBool): WideString;
begin
  VarResultCheck(VarBStrFromBool(AValue, VAR_LOCALE_USER_DEFAULT, 0, Result), varBoolean, varOleStr);
  case BooleanToStringRule of
    bsrAsIs:
      ;
    bsrLower:
      Result := Lowercase(Result);
    bsrUpper:
      Result := Uppercase(Result);
  else
    VarInvalidOp;
  end;
end;

function VarToLStrViaOS(const V: TVarData): string;
var
  LTemp: TVarData;
begin
  VariantInit(LTemp);
  try
    VarResultCheck(VariantChangeTypeEx(LTemp, V, VAR_LOCALE_USER_DEFAULT, 0, varOleStr), V.VType, varString);
    Result := Copy(LTemp.VOleStr, 1, MaxInt);
  finally
    System.VarClearProc(LTemp);
  end;
end;

function VarToLStrCustom(const V: TVarData; out AValue: AnsiString): Boolean;
var
  LHandler: TCustomVariantType;
  LTemp: TVarData;
begin
  Result := FindCustomVariantType(V.VType, LHandler);
  if Result then
  begin
    VariantInit(LTemp);
    try
      LHandler.CastTo(LTemp, V, varString);
      AValue := AnsiString(LTemp.VString);
    finally
      System.VarClearProc(LTemp);
    end;
  end;
end;

procedure _VariantToJson(var S: AnsiString; const V: TVarData; QuoteStr: Boolean); forward;

function VarToLStrAny(const V: TVarData; QuoteStr: Boolean): AnsiString;
var
  LTemp: TVarData;
begin
  VariantInit(LTemp);
  try
    System.VarCopyProc(LTemp, V);
    ChangeAnyProc(LTemp);
    _VariantToJson(Result, LTemp, QuoteStr);
  finally
    System.VarClearProc(LTemp);
  end;
end;

procedure SynVarArrayToLStr(var S: AnsiString; const V: Variant);
var
  i, first, last: Integer;
  tmp: AnsiString;
begin
  first := VarArrayLowBound(v, 1);
  last := VarArrayHighBound(v, 1);
  if first > last then
    S := '[]'
  else
  begin
    _VariantToJson(tmp, TVarData(V[first]), True);
    S := '[' + tmp;
    for i := first + 1 to last do
    begin
      tmp := '';
      _VariantToJson(tmp, TVarData(V[i]), True);
      S := S + ',' + tmp;
    end;
    S := S + ']';
  end;
end;

procedure _VariantToJson(var S: AnsiString; const V: TVarData; QuoteStr: Boolean);
  procedure returnString(const value: AnsiString); overload;
  begin
    if QuoteStr then
      S := '"' + value + '"'
    else
      S := value;
  end;

  procedure returnString(const value: WideString); overload;
  begin
    if QuoteStr then
      S := AnsiString('"' + value + '"')
    else
      S := AnsiString(value);
  end;

  procedure returnString(const value: UnicodeString); overload;
  begin
    if QuoteStr then
      S := AnsiString('"' + value + '"')
    else
      S := AnsiString(value);
  end;

  procedure processRef;
  begin
    case V.VType and not varByRef of
      varSmallInt:
        S := IntToRBStr(PSmallInt(V.VPointer)^);
      varInteger:
        S := IntToRBStr(PInteger(V.VPointer)^);
      varSingle:
        S := FloatToRBStr(PSingle(V.VPointer)^);
      varDouble:
        S := FloatToRBStr(PDouble(V.VPointer)^);
      varCurrency:
        returnString(CurrToWStrViaOS(PCurrency(V.VPointer)^));
      varDate:
        returnString(DateToWStrViaOS(PDate(V.VPointer)^));
      varOleStr:
        returnString(JsonEscape(WideString(V.VPointer^)));
      varBoolean:
        if PWordBool(V.VPointer)^ then
          S := 'True'
        else
          S := 'False';
      varShortInt:
        S := IntToRBStr(PShortInt(V.VPointer)^);
      varByte:
        S := IntToRBStr(PByte(V.VPointer)^);
      varWord:
        S := IntToRBStr(PWord(V.VPointer)^);
      varLongWord:
        S := IntToRBStr(PLongWord(V.VPointer)^);
      varInt64:
        S := IntToRBStr(PInt64(V.VPointer)^);
      varUInt64:
        S := UInt64ToRBStr(PUInt64(V.VPointer)^);
      varString:
        returnString(JsonEscape(AnsiString(V.VPointer^)));
      varUString:
        returnString(JsonEscape(UnicodeString(V.VPointer^)));

      varVariant:
        _VariantToJson(S, PVarData(V.VPointer)^, QuoteStr);
    else
      returnString(VarToLStrViaOS(V));
    end;
  end;

begin
  case V.VType of
    varEmpty:
      returnString('');
    varNull:
      S := 'null';
    varSmallInt:
      S := IntToRBStr(V.VSmallInt);
    varInteger:
      S := IntToRBStr(V.VInteger);
    varSingle:
      S := FloatToRBStr(V.VSingle);
    varDouble:
      S := FloatToRBStr(V.VDouble);
    varCurrency:
      returnString(CurrToWStrViaOS(V.VCurrency));
    varDate:
      returnString(DateToWStrViaOS(V.VDate));
    varOleStr:
      returnString(JsonEscape(WideString(Pointer(V.VOleStr))));
    varBoolean:
      if v.VBoolean then
        S := 'True'
      else
        S := 'False';
    varShortInt:
      S := IntToRBStr(V.VShortInt);
    varByte:
      S := IntToRBStr(V.VByte);
    varWord:
      S := IntToRBStr(V.VWord);
    varLongWord:
      S := IntToRBStr(V.VLongWord);
    varInt64:
      S := IntToRBStr(V.VInt64);
    varUInt64:
      S := UInt64ToRBStr(V.VUInt64);

    varVariant:
      _VariantToJson(S, PVarData(V.VPointer)^, QuoteStr);

    varDispatch, varUnknown:
      returnString(VarToLStrViaOS(V));
    varString:
      returnString(JsonEscape(AnsiString(V.VString)));
    varUString:
      returnString(JsonEscape(UnicodeString(V.VUString)));
    varAny:
      S := VarToLStrAny(V, QuoteStr);
  else
    if V.VType and varByRef <> 0 then
      processRef
    else if v.VType and varArray <> 0 then
      SynVarArrayToLStr(S, Variant(V))
    else if not VarToLStrCustom(V, S) then
      returnString(VarToLStrViaOS(V));
  end;
end;

procedure VariantToJson(var S: AnsiString; const V: TVarData);
begin
  _VariantToJson(S, V, False);
end;

var
  SynVariantTypes: TObjectList = nil;

function FindSynVariantType(aVarType: Word; out CustomType: TInvokableVarType): Boolean;
var
  i: Integer;
begin
  if SynVariantTypes <> nil then
  begin
    for i := 0 to SynVariantTypes.Count - 1 do
      if TInvokableVarType(SynVariantTypes.List[i]).VarType = aVarType then
      begin
        CustomType := TInvokableVarType(SynVariantTypes.List[i]);
        Result := True;
        exit;
      end;
  end;
  Result := False;
end;

function SynRegisterCustomVariantType(aClass: TSynInvokeableVariantTypeClass): TInvokableVarType;
var
  i: Integer;
{$IFDEF DOPATCHDISPINVOKE}
{$IFDEF NOVARCOPYPROC}
  VarMgr: TVariantManager;
{$ENDIF}
{$ENDIF}
begin
  if SynVariantTypes = nil then
  begin
{$IFNDEF FPC}
{$IFDEF DOPATCHDISPINVOKE}
{$IFNDEF CPU64}
    if DebugHook = 0 then
{$ENDIF}begin
{$IFDEF NOVARCOPYPROC}
      GetVariantManager(VarMgr);
      VarMgr.DispInvoke := @SynVarDispProc;
      SetVariantManager(VarMgr);
{$ELSE}
      RedirectCode(VariantsDispInvokeAddress, @SynVarDispProc);
{$ENDIF NOVARCOPYPROC}
    end;
{$ENDIF DOPATCHDISPINVOKE}
{$ENDIF FPC}

  end
  else
    for i := 0 to SynVariantTypes.Count - 1 do
      if PPointer(SynVariantTypes.List[i])^ = pointer(aClass) then
      begin
        Result := SynVariantTypes.List[i];
        exit;
      end;
  Result := aClass.Create;
  SynVariantTypes.Add(Result);
  if aClass = TVarObjType then
    VarObjectVarType := Result.VarType;
end;

procedure TVarObject.Init(aOptions: TVarObjectOptions; aKind: TVarObjectKind);
begin
  if VarObjectHandler = nil then
    VarObjectHandler := SynRegisterCustomVariantType(TVarObjType);
  ZeroFill(PVarData(@Self));
  FType := VarObjectVarType;
  FOptions := aOptions;
  FKind := aKind;
end;

procedure TVarObject.InitFast;
begin
  if VarObjectHandler = nil then
    VarObjectHandler := SynRegisterCustomVariantType(TVarObjType);
  FillChar(Self, SizeOf(Self), 0);
  FType := VarObjectVarType;
  FOptions := JSON_OPTIONS_FAST;
end;

procedure TVarObject.InitFast(InitialCapacity: Integer; aKind: TVarObjectKind);
begin
  InitFast;
  FKind := aKind;
  if aKind = vokObject then
    SetLength(FNames, InitialCapacity);
  SetLength(FValues, InitialCapacity);
end;

const
  VarObjectDataFake: TVarObject = (FType: 1; FOptions: [voReturnNullForUnknownProperty]);

function _Safe(const v: Variant): PVarObject;
var
  p: PVarData;
begin
  p := @TVarData(v);
  while p.VType = varByRef or varVariant do
    p := PVarData(p.VPointer);

  if p.VType = Word(VarObjectVarType) then
    Result := PVarObject(p)
  else
    Result := @VarObjectDataFake;
end;

procedure TVarObject.AddOrUpdateObject(const NewValues: Variant; OnlyAddMissing: Boolean);
var
  n: Integer;
  new: PVarObject;
begin
  new := _Safe(NewValues);
  for n := 0 to new^.Count - 1 do
    AddOrUpdate(new^.Names[n], new^.Values[n], nil, OnlyAddMissing);
end;

procedure TVarObject.Clear;
begin
  if VarType = VarObjectVarType then
    VarObjectHandler.Clear(TVarData(Self))
  else
    VarClear(Variant(Self));
end;

procedure TVarObject.Reset;
var
  opt: TVarObjectOptions;
begin
  opt := FOptions;
  VarObjectHandler.Clear(TVarData(Self));
  FType := VarObjectVarType;
  FOptions := opt;
end;

procedure TVarObject.SetCount(aCount: Integer);
begin
  FCount := aCount;
end;

function TVarObject.InternalAdd(const aName: string): Integer;
var
  len: Integer;
begin
  if aName = '' then
    raise EVarObject.Create('Unexpected array item added to an object');

  Result := -1;

  if FKind = vokUndefined then
  begin
    FType := VarObjectVarType;
    FKind := vokObject;
  end;

  if FValues = nil then
    SetLength(FValues, 16)
  else if FCount >= Length(FValues) then
    SetLength(FValues, FCount + FCount shr 3 + 32);

  len := Length(FValues);
  if Length(FNames) <> len then
    SetLength(FNames, len);
  FNames[FCount] := aName;

  Result := FCount;
  Inc(FCount);
end;

procedure TVarObject.SetCapacity(aValue: Integer);
begin
  if FKind = vokObject then
  begin
    SetLength(FNames, aValue);
    SetLength(FValues, aValue);
  end;
end;

function TVarObject.GetCapacity: Integer;
begin
  Result := Length(FValues);
end;

function TVarObject.AddValue(const aName: string; const aValue: Variant): Integer;
var
  i: Integer;
begin
  if voCheckForDuplicatedNames in FOptions then
  begin
    i := IndexOf(aName);
    if i >= 0 then
      raise EVarObject.CreateFmt('Duplicated "%s" name', [aName]);
  end;
  Result := InternalAdd(aName);
  FValues[Result] := aValue;
end;

procedure TVarObject.AddFrom(const src: Variant);
var
  psrc: PVarObject;
  i: Integer;
begin
  psrc := _Safe(src);

  if (psrc.VarType = VarObjectVarType) and (psrc.Count > 0) then
    for i := 0 to psrc^.Count - 1 do
      AddValue(psrc^.FNames[i], psrc^.FValues[i]);
end;

procedure VarRecToVariant(const V: TVarRec; var Result: Variant);
begin
  if TVarData(Result).VType and varDeepData = 0 then
    TVarData(Result).VType := varEmpty
  else
    VarClear(Result);
  with TVarData(Result) do
    case V.VType of
      vtPointer:
        VType := varNull;
      vtBoolean:
        begin
          VType := varBoolean;
          VBoolean := V.VBoolean;
        end;
      vtInteger:
        begin
          VType := varInteger;
          VInteger := V.VInteger;
        end;
      vtInt64:
        begin
          VType := varInt64;
          VInt64 := V.VInt64^;
        end;
      vtCurrency:
        begin
          VType := varCurrency;
          VCurrency := V.VCurrency^;
        end;
      vtExtended:
        begin
          VType := varDouble;
          VDouble := V.VExtended^;
        end;
      vtVariant:
        Result := V.VVariant^;
      vtAnsiString:
        begin
          VType := varString;
          VAny := nil;
          RawByteString(VAny) := RawByteString(V.VAnsiString);
        end;
      vtString, vtUnicodeString, vtPChar, vtChar, vtWideChar, vtWideString, vtClass:
        begin
          VType := varString;
          VAny := nil;

        end;
      vtObject:

      else
        raise Exception.CreateFmt('Unhandled TVarRec.VType=%d', [V.VType]);
    end;
end;

procedure TVarObject.AddItems(const aValue: array of const );
var
  idx, added: Integer;
begin
  for idx := 0 to high(aValue) do
  begin
    added := InternalAdd('');
    VarRecToVariant(aValue[idx], FValues[added]);
  end;
end;

procedure TVarObject.Sort;
begin
  if (FKind <> vokObject) or (FCount = 0) then
    Exit;

end;

procedure TVarObject.Exchange(v1, v2: Integer);
var
  n: Pointer;
  v: TVarData;
begin
  if v1 = v2 then
    Exit;
  if FNames <> nil then
  begin
    n := Pointer(FNames[v2]);
    Pointer(FNames[v2]) := Pointer(FNames[v1]);
    PPointerArray(FNames)[v1] := n;
  end;
  v := TVarData(FValues[v2]);
  TVarData(FValues[v2]) := TVarData(FValues[v1]);
  TVarData(FValues[v1]) := v;
end;

function TVarObject.Delete(Index: Integer): Boolean;
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Result := False
  else
  begin
    dec(FCount);
    if FNames <> nil then
      FNames[Index] := '';
    VarClear(FValues[Index]);
    if Index < FCount then
    begin
      if FNames <> nil then
      begin
        Move(FNames[Index + 1], FNames[Index], (FCount - Index) * sizeof(Pointer));
        Pointer(FNames[FCount]) := nil;
      end;
      Move(FValues[Index + 1], FValues[Index], (FCount - Index) * sizeof(Variant));
      TVarData(FValues[FCount]).VType := varEmpty;
    end;
    Result := True;
  end;
end;

function TVarObject.Delete(const aName: string): Boolean;
begin
  Result := Delete(IndexOf(aName));
end;

function TVarObject.IndexOf(aName: PChar; aNameLen: Integer): Integer;
var
  LName: string;
  function getName: string;
  begin
    System.SetString(Result, aName, aNameLen);
  end;
begin
  if Self.VarType = VarObjectVarType then
  begin
    if voNameCaseSensitive in Self.Options then
    begin
      for Result := 0 to Self.Count - 1 do
      begin
        LName := FNames[Result];
        if (Length(LName) = aNameLen) and CompareMem(Pointer(LName), aName, SizeOf(Char) * aNameLen) then Exit;
      end;
    end
    else
      for Result := 0 to FCount - 1 do
        if StrCompare(FNames[Result], aName, aNameLen) = 0 then
          Exit;
  end;
  Result := -1;
end;

function TVarObject.IndexOf(const aName: string): Integer;
begin
  if (Kind = vokObject) and (VarType = VarObjectVarType) then
  begin
    if voNameCaseSensitive in FOptions then
    begin
      for Result := 0 to FCount - 1 do
        if FNames[Result] = aName then
          Exit;
    end
    else
    begin
      for Result := 0 to FCount - 1 do
        if SameText(FNames[Result], aName) then
          Exit;
    end;
  end;
  Result := -1;
end;

function TVarObject.GetValueOrRaiseException(const aName: string): Variant;
begin
  RetrieveValueOrRaiseException(aName, Result);
end;

function TVarObject.GetValueOrDefault(const aName: string; const aDefault: Variant): Variant;
var
  idx: Integer;
begin
  if (FType <> VarObjectVarType) or (Kind <> vokObject) then
    Result := aDefault
  else
  begin
    idx := IndexOf(aName);
    if idx >= 0 then
      Result := FValues[idx]
    else
      Result := aDefault;
  end;
end;

function TVarObject.GetValueOrNull(const aName: string): Variant;
var
  idx: Integer;
begin
  if (FType <> VarObjectVarType) or (Kind <> vokObject) then
    SetNull(Result)
  else
  begin
    idx := IndexOf(aName);
    if idx >= 0 then
      Result := FValues[idx]
    else
      SetNull(Result);
  end;
end;

function TVarObject.GetValueOrEmpty(const aName: string): Variant;
var
  idx: Integer;
begin
  VarClear(Result);
  if (FType = VarObjectVarType) and (Kind = vokObject) then
  begin
    idx := IndexOf(aName);
    if idx >= 0 then
      Result := FValues[idx];
  end;
end;

function TVarObject.GetAsBoolean(const aName: string; out aValue: Boolean): Boolean;
var
  found: PVarData;
begin
  found := GetVarData(aName);
  if found = nil then
    Result := False
  else
    Result := VarToBool(PVariant(found)^, aValue);
end;

function TVarObject.GetAsInteger(const aName: string; out aValue: Integer): Boolean;
var
  found: PVarData;
begin
  found := GetVarData(aName);
  if found = nil then
    Result := False
  else
    Result := VarToInt(PVariant(found)^, aValue)
end;

function TVarObject.GetAsInt64(const aName: string; out aValue: Int64): Boolean;
var
  found: PVarData;
begin
  found := GetVarData(aName);
  if found = nil then
    Result := False
  else
    Result := VarToInt64(PVariant(found)^, aValue)
end;

function TVarObject.GetAsDouble(const aName: string; out aValue: double): Boolean;
var
  found: PVarData;
begin
  found := GetVarData(aName);
  if found = nil then
    Result := False
  else
    Result := VarToFloat(PVariant(found)^, aValue);
end;

function TVarObject.GetAsString(const aName: string; out aValue: string): Boolean;
var
  found: PVarData;
begin
  found := GetVarData(aName);
  if found = nil then
    Result := False
  else
  begin
    aValue := VarToStr(PVariant(found)^);
    Result := True;
  end;
end;

function TVarObject.GetAsDocVariant(const aName: string; out aValue: PVarObject): Boolean;
var
  found: PVarData;
begin
  found := GetVarData(aName);
  if found = nil then
    Result := False
  else
  begin
    aValue := _Safe(PVariant(found)^);
    Result := aValue <> @VarObjectDataFake;
  end;
end;

function TVarObject.GetAsDocVariantSafe(const aName: string): PVarObject;
var
  pvd: PVarData;
begin
  pvd := GetVarData(aName);
  if pvd = nil then
    Result := @VarObjectDataFake
  else
    Result := _Safe(PVariant(pvd)^);
end;

function TVarObject.GetAsPVariant(const aName: string; out aValue: PVariant): Boolean;
begin
  aValue := Pointer(GetVarData(aName));
  Result := aValue <> nil;
end;

function TVarObject.GetVarData(const aName: string; var aValue: TVarData): Boolean;
var
  found: PVarData;
begin
  found := GetVarData(aName);
  if found = nil then
    Result := False
  else
  begin
    aValue := found^;
    Result := True;
  end;
end;

function TVarObject.GetVarData(const aName: string): PVarData;
var
  i: Integer;
begin
  Result := nil;
  if (FType = VarObjectVarType) and (Kind = vokObject) and (FCount > 0) then
    for i := 0 to FCount - 1 do
    begin
      if 0 = StrCompare(aName, FNames[i], voNameCaseSensitive in FOptions) then
      begin
        Result := @FValues[i];
        Break;
      end;
    end;
end;

procedure TVarObject.SetValueOrRaiseException(Index: Integer; const NewValue: Variant);
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    raise EVarObject.CreateFmt('Out of range Values[%d] (count=%d)', [Index, FCount])
  else
    FValues[Index] := NewValue;
end;

procedure TVarObject.RetrieveNameOrRaiseException(Index: Integer; var Dest: string);
begin
  if (Cardinal(Index) >= Cardinal(FCount)) or (FNames = nil) then
    if voReturnNullForUnknownProperty in FOptions then
      Dest := ''
    else
      raise EVarObject.CreateFmt('Out of range Names[%d] (count=%d)', [Index, FCount])
    else
      Dest := FNames[Index];
end;

procedure TVarObject.RetrieveValueOrRaiseException(Index: Integer; var Dest: Variant);
var
  Source: PVariant;
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    if voReturnNullForUnknownProperty in FOptions then
      SetNull(Dest)
    else
      raise EVarObject.CreateFmt('Out of range Values[%d] (count=%d)', [Index, FCount])
    else
    begin
      Source := @FValues[Index];
      while PVarData(Source)^.VType = varVariant or varByRef do
        Source := PVarData(Source)^.VPointer;
      Dest := Source^;
    end;
end;

procedure TVarObject.RetrieveValueOrRaiseException(aName: PChar; aNameLen: Integer; var Dest: Variant);
var
  idx: Integer;
begin
  idx := IndexOf(aName, aNameLen);
  if idx < 0 then
    if voReturnNullForUnknownProperty in FOptions then
      SetNull(Dest)
    else
      raise EVarObject.CreateFmt('Unexpected "%s" property', [StrOf(aName, aNameLen)])
    else
      RetrieveValueOrRaiseException(idx, Dest);
end;

procedure TVarObject.RetrieveValueOrRaiseException(const aName: string; var Dest: Variant);
var
  idx: Integer;
begin
  idx := IndexOf(aName);
  if idx < 0 then
    if voReturnNullForUnknownProperty in FOptions then
      SetNull(Dest)
    else
      raise EVarObject.CreateFmt('Unexpected "%s" property', [aName])
    else
      RetrieveValueOrRaiseException(idx, Dest);
end;

function TVarObject.AddOrUpdate(const aName: string; const aValue: Variant; wasAdded: PBoolean;
  OnlyAddMissing: Boolean): Integer;
begin
  Result := IndexOf(aName);
  if Result < 0 then
  begin
    Result := InternalAdd(aName);
    if wasAdded <> nil then
      wasAdded^ := True;
  end
  else
  begin
    if wasAdded <> nil then
      wasAdded^ := False;
    if OnlyAddMissing then
      Exit;
  end;
  FValues[Result] := aValue;
end;

function TVarObject.ForceItemIndex(const aName: string): Integer;
begin
  Result := IndexOf(aName);
  if Result < 0 then
    Result := InternalAdd(aName);
end;

function TVarObject.ForceItemData(const aName: string): PVariant;
var
  idx: Integer;
begin
  idx := IndexOf(aName);
  if idx < 0 then
    idx := InternalAdd(aName);
  Result := @FValues[idx];
end;

function TVarObject.GetItemData(const aName: string): PVariant;
var
  i: Integer;
begin
  i := IndexOf(aName);
  if i < 0 then
  begin
    if voReturnNullForUnknownProperty in FOptions then
      Result := @VarObjectDataFake
    else
      raise EVarObject.CreateFmt('Unexpected "%s" property', [aName]);
  end
  else
    Result := @FValues[i];
end;

function TVarObject.GetInt64(const aName: string): Int64;
begin
  if not VarToInt64(GetItemData(aName)^, Result) then
    Result := 0;
end;

function TVarObject.GetString(const aName: string): string;
begin
  Result := VarToStr(GetItemData(aName)^);
end;

procedure TVarObject.SetInt64(const aName: string; const aValue: Int64);
begin
  ForceItemData(aName)^ := aValue;
end;

procedure TVarObject.SetString(const aName: string; const aValue: string);
begin
  ForceItemData(aName)^ := aValue;
end;

function TVarObject.GetBoolean(const aName: string): Boolean;
begin
  if not VarToBool(GetItemData(aName)^, Result) then
    Result := False;
end;

procedure TVarObject.SetBoolean(const aName: string; aValue: Boolean);
begin
  ForceItemData(aName)^ := aValue;
end;

function TVarObject.GetDouble(const aName: string): Double;
begin
  if not VarToFloat(GetItemData(aName)^, Result) then
    Result := 0;
end;

procedure TVarObject.SetDouble(const aName: string; const aValue: Double);
begin
  ForceItemData(aName)^ := aValue;
end;

function TInvokableVarType.IterateCount(const V: TVarData): Integer;
begin
  Result := -1;
end;

procedure TInvokableVarType.Iterate(var Dest: TVarData; const V: TVarData; Index: Integer);
begin
end;
{$IFNDEF FPC}
{$IFNDEF DELPHI6OROLDER}

function TInvokableVarType.FixupIdent(const AText: string): string;
begin
  Result := AText;
end;
{$ENDIF DELPHI6OROLDER}
{$ENDIF FPC}

procedure TInvokableVarType.IntGetSubscript(var Dest: TVarData; const V: TVarData; const Name: string;
  const Arguments: TVarDataArray);
begin
  RaiseDispError;
end;

procedure TInvokableVarType.IntSetSubscript(const V: TVarData; const Name: string; const Arguments: TVarDataArray);
begin
  RaiseDispError;
end;

function TInvokableVarType.GetProperty(var Dest: TVarData; const V: TVarData;
  const Name: string; const Arguments: TVarDataArray): Boolean;
var
  i: Integer;
  pDest: PVarData;
  indices: array of Integer;
begin
  Result := False;
  IntGet(Dest, V, Name);
  if Length(Arguments) = 0 then
    Result := True
  else if VarIsArray(Variant(Dest), True) then
  begin
    pDest := FindVarData(Variant(Dest));
    SetLength(Indices, Length(Arguments));
    for i := 0 to High(Arguments) do
      if not VarToInt(Variant(Arguments[i]), indices[i]) then
        Exit;

    Variant(Dest) := VarArrayGet(Variant(pDest^), indices);
    Result := True;
  end;
end;

function TInvokableVarType.SetProperty;
var
  Dest: TVarData;
  i, LArgCount: Integer;
  pDest: PVarData;
  indices: array of Integer;
begin
  LArgCount := Length(Arguments);
  if LArgCount = 1 then
  begin
    Result := Self._SetProperty(V, Name, Arguments[0]);
    Exit;
  end;
  IntGet(Dest, V, Name);

  Result := False;

  if VarIsArray(Variant(Dest), True) then
  begin
    pDest := FindVarData(Variant(Dest));
    SetLength(indices, LArgCount - 1);
    for i := 0 to LArgCount - 2 do
      if not VarToInt(Variant(Arguments[i]), indices[i]) then
        Exit;

    VarArrayPut(Variant(pDest^), Variant(Arguments[LArgCount - 1]), indices);
    Result := True;
  end;
end;

function TInvokableVarType.DoFunction(var Dest: TVarData; const V: TVarData; const Name: string;
  const Arguments: TVarDataArray): Boolean;
begin
  Result := False;
end;

function TInvokableVarType.DoProcedure(const V: TVarData; const Name: string;
  const Arguments: TVarDataArray): Boolean;
begin
  Result := False;
end;

function TInvokableVarType._SetProperty;
var
  ValueSet: TVarData;
  PropName: PChar;
begin
  PropName := PChar(Name);
  ValueSet.VString := nil;
  if SetVariantUnRefSimpleValue(Variant(Value), ValueSet) then
  begin
    IntSet(V, ValueSet, PropName);
    Result := True;
    exit;
  end
  else
  begin
    IntSet(V, Value, PropName);
    Result := True;
    exit;
  end;
  try
    ValueSet.VType := varString;
    IntSet(V, ValueSet, PropName);
  finally
    string(ValueSet.VString) := '';
  end;
  Result := True;
end;

procedure TInvokableVarType.Clear(var V: TVarData);
begin
  ZeroFill(@V);
end;

procedure TInvokableVarType.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean);
begin
  if Indirect then
    SimplisticCopy(Dest, Source, True)
  else
  begin
    if Dest.VType and varDeepData <> 0 then
      VarClear(Variant(Dest));
    Dest := Source;
  end;
end;

procedure TInvokableVarType.CopyByValue(var Dest: TVarData; const Source: TVarData);
begin
  Copy(Dest, Source, False);
end;

procedure SetVarAsError(var V: TVarData; AResult: HRESULT);
begin
  VarClear(Variant(V));
  V.VType := varError;
  V.VError := AResult;
end;

procedure SetClearVarToEmptyParam(var V: TVarData);
begin
  SetVarAsError(V, VAR_PARAMNOTFOUND);
end;

procedure TInvokableVarType.DispInvoke(Dest: PVarData; const Source: TVarData; CallDesc: PCallDesc;
  Params: Pointer);
type
  PParamRec = ^TParamRec;
  TParamRec = array [0 .. 3] of LongInt;

  TStringDesc = record
    BStr: WideString;
    PStr: PAnsiString;
  end;
const
  CDoMethod = $01;
  CPropertyGet = $02;
  CPropertySet = $04;
var
  LArguments: TVarDataArray;
  LStrings: array of TStringDesc;
  LStrCount: Integer;
  LParamPtr: Pointer;

  procedure ParseParam(I: Integer);
  const
    CArgTypeMask = $7F;
    CArgByRef = $80;
  var
    LArgType: Integer;
    LArgByRef: Boolean;
  begin
    LArgType := CallDesc^.ArgTypes[I] and CArgTypeMask;
    LArgByRef := (CallDesc^.ArgTypes[I] and CArgByRef) <> 0;

    if LArgType = varError then
      SetClearVarToEmptyParam(LArguments[I])

    else if LArgType = varStrArg then
    begin
      with LStrings[LStrCount] do
        if LArgByRef then
        begin

          BStr := WideString(System.Copy(PAnsiString(LParamPtr^)^, 1, MaxInt));
          PStr := PAnsiString(LParamPtr^);
          LArguments[I].VType := varOleStr or varByRef;
          LArguments[I].VOleStr := @BStr;
        end
        else
        begin

          BStr := WideString(System.Copy(PAnsiString(LParamPtr)^, 1, MaxInt));
          PStr := nil;
          LArguments[I].VType := varOleStr;
          LArguments[I].VOleStr := PWideChar(BStr);
        end;
      Inc(LStrCount);
    end

    else if LArgByRef then
    begin
      if (LArgType = varVariant) and ((PVarData(LParamPtr^)^.VType = varString) or
          (PVarData(LParamPtr^)^.VType = varUString)) then

        VarDataCastTo(PVarData(LParamPtr^)^, PVarData(LParamPtr^)^, varOleStr);
      LArguments[I].VType := LArgType or varByRef;
      LArguments[I].VPointer := Pointer(LParamPtr^);
    end

    else if LArgType = varVariant then
      if (PVarData(LParamPtr)^.VType = varString) or (PVarData(LParamPtr)^.VType = varUString) then
      begin
        with LStrings[LStrCount] do
        begin

          if (PVarData(LParamPtr)^.VType = varString) then
            BStr := WideString(System.Copy(AnsiString(PVarData(LParamPtr)^.VString), 1, MaxInt))
          else
            BStr := WideString(System.Copy(UnicodeString(PVarData(LParamPtr)^.VUString), 1, MaxInt));
          PStr := nil;
          LArguments[I].VType := varOleStr;
          LArguments[I].VOleStr := PWideChar(BStr);
        end;
        Inc(LStrCount);
      end
      else
      begin
        LArguments[I] := PVarData(LParamPtr)^;
        Inc(Integer(LParamPtr), SizeOf(TVarData) - SizeOf(Pointer));
      end
      else
      begin
        LArguments[I].VType := LArgType;
        case CVarTypeToElementInfo[LArgType].Size of
          1, 2, 4:
            begin
              LArguments[I].VLongs[1] := PParamRec(LParamPtr)^[0];
            end;
          8:
            begin
              LArguments[I].VLongs[1] := PParamRec(LParamPtr)^[0];
              LArguments[I].VLongs[2] := PParamRec(LParamPtr)^[1];
              Inc(Integer(LParamPtr), 8 - SizeOf(Pointer));
            end;
        else
          RaiseDispError;
        end;
      end;
    Inc(Integer(LParamPtr), SizeOf(Pointer));
  end;

var
  I, LArgCount: Integer;
  LIdent: string;
  LTemp: TVarData;
begin

  LArgCount := CallDesc^.ArgCount;
  LIdent := FixupIdent(string(AnsiString(PAnsiChar(@CallDesc^.ArgTypes[LArgCount]))));

  LParamPtr := Params;
  SetLength(LArguments, LArgCount);
  LStrCount := 0;
  SetLength(LStrings, LArgCount);
  for I := 0 to LArgCount - 1 do
    ParseParam(I);

  case CallDesc^.CallType of
    CDoMethod:

      if Dest = nil then
      begin
        if not DoProcedure(Source, LIdent, LArguments) then
        begin

          VarDataInit(LTemp);
          try

            SetClearVarToEmptyParam(LTemp);

            if not DoFunction(LTemp, Source, LIdent, LArguments) then
              RaiseDispError;
          finally
            VarDataClear(LTemp);
          end;
        end
      end

      else if LArgCount = 0 then
      begin
        if not GetProperty(Dest^, Source, LIdent, LArguments) and not DoFunction(Dest^, Source, LIdent, LArguments) then
          RaiseDispError;
      end

      else if not DoFunction(Dest^, Source, LIdent, LArguments) then
        RaiseDispError;

    CPropertyGet:
      if not Assigned(Dest)
        or not GetProperty(Dest^, Source, LIdent, LArguments) then
        RaiseDispError;

    CPropertySet:
      if Assigned(Dest)
        or (LArgCount = 0) or not SetProperty(Source, LIdent, LArguments) then
        RaiseDispError;
  else
    RaiseDispError;
  end;

  I := LStrCount;
  while I <> 0 do
  begin
    Dec(I);
    with LStrings[I] do
      if Assigned(PStr) then
        PStr^ := AnsiString(System.Copy(BStr, 1, MaxInt));
  end;
end;

procedure TVarObjType.IntGet(var Dest: TVarData; const V: TVarData; const Name: string);
label normal;
var
  NameLen: Integer;
begin
  NameLen := Length(Name);

  if (NameLen > 4) and (Name[1] = '_') then
  begin
    if AsciiCompare(PChar(Name) + 1, NameLen - 1, 'count', 5) = 0 then
      Variant(Dest) := TVarObject(V).Count
    else if AsciiCompare(PChar(Name) + 1, NameLen - 1, 'kind', 4) = 0 then
      Variant(Dest) := Ord(TVarObject(V).Kind)
    else if AsciiCompare(PChar(Name) + 1, NameLen - 1, 'json', 4) = 0 then
      Variant(Dest) := VarToStr(Variant(V))
    else
      goto normal;
  end;

normal :
  TVarObject(V).RetrieveValueOrRaiseException(Name, Variant(Dest));
end;

procedure TVarObjType.IntSet(const V, Value: TVarData; const Name: string);
var
  i: Integer;
  d: TVarObject absolute V;
begin
  i := d.IndexOf(Name);
  if i < 0 then
    i := d.InternalAdd(Name);
  d.FValues[i] := Variant(Value);
end;

function TVarObjType.DoFunction(var Dest: TVarData; const V: TVarData;
  const Name: string; const Arguments: TVarDataArray): Boolean;
var
  i: Integer;
  d: TVarObject absolute V;
  temp: string;
  procedure SetTempFromFirstArgument;
  begin
    temp := Variant(Arguments[0]);
  end;
begin
  Result := True;
  case Length(Arguments) of
    0:
      if SameText(Name, 'Clear') then
      begin
        Clear(Dest);
        Exit;
      end;
    1:
      if SameText(Name, 'Delete') then
      begin
        SetTempFromFirstArgument;
        d.Delete(d.IndexOf(temp));
        exit;
      end
      else if SameText(Name, 'Exists') then
      begin
        SetTempFromFirstArgument;
        Variant(Dest) := d.IndexOf(temp) >= 0;
        exit;
      end;
    2:
      if SameText(Name, 'Add') then
      begin
        SetTempFromFirstArgument;
        i := d.InternalAdd(temp);
        d.FValues[i] := Variant(Arguments[1]);
        exit;
      end;
  end;
  Result := False;
end;

procedure TVarObjType.Clear(var V: TVarData);
begin

  TVarObject(V).FValues := nil;
  TVarObject(V).FNames := nil;
  ZeroFill(@V);
end;

procedure TVarObjType.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean);
begin

  if Indirect then
    SimplisticCopy(Dest, Source, True)
  else if voValueCopiedByReference in TVarObject(Source).Options then
  begin
    if Dest.VType and varDeepData <> 0 then
      VarClear(Variant(Dest));
    pointer(TVarObject(Dest).FNames) := nil;
    pointer(TVarObject(Dest).FValues) := nil;
    TVarObject(Dest) := TVarObject(Source);
  end
  else
    CopyByValue(Dest, Source);
end;

procedure TVarObjType.CopyByValue(var Dest: TVarData; const Source: TVarData);
var
  S: TVarObject absolute Source;
  D: TVarObject absolute Dest;
  i: Integer;
begin

  if Dest.VType and varDeepData <> 0 then
    VarClear(Variant(Dest));
  D.FType := S.FType;
  D.FOptions := S.FOptions;
  D.FKind := S.FKind;
  D.FCount := S.FCount;
  pointer(D.FNames) := nil;
  pointer(D.FValues) := nil;
  if S.FCount = 0 then
    exit;
  D.FNames := S.FNames;

  SetLength(D.FValues, S.FCount);
  for i := 0 to S.FCount - 1 do
    D.FValues[i] := S.FValues[i];
end;

procedure TVarObjType.Cast(var Dest: TVarData; const Source: TVarData);
begin
  CastTo(Dest, Source, VarType);
end;

procedure TVarObjType.CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType);
begin
  if AVarType = VarType then
  begin
    if Source.VType = VarType then
    begin

    end
    else
    begin
      if Dest.VType and varDeepData <> 0 then
        VarClear(Variant(Dest));

      exit;
    end;
    RaiseCastError;
  end
  else
  begin

    RaiseCastError;
  end;
end;

class procedure TVarObjType.New(out aValue: Variant; aOptions: TVarObjectOptions);
begin
  TVarObject(aValue).Init(aOptions);
end;

class procedure TVarObjType.NewFast(out aValue: Variant);
begin
  TVarObject(aValue).InitFast;
end;

class procedure TVarObjType.NewFast(const aValues: array of PVarObject);
var
  i: Integer;
begin
  for i := 0 to high(aValues) do
    aValues[i]^.InitFast;
end;

class function TVarObjType.New(Options: TVarObjectOptions): Variant;
begin
  if TVarData(Result).VType and varDeepData <> 0 then
    VarClear(Result);
  TVarObject(Result).Init(Options);
end;

class procedure TVarObjType.GetSingleOrDefault(const docVariantArray, default: Variant; var Result: Variant);
begin
  if TVarData(DocVariantArray).VType = varByRef or varVariant then
    GetSingleOrDefault(PVariant(TVarData(DocVariantArray).VPointer)^, default, Result)
  else if (TVarData(DocVariantArray).VType <> VarObjectVarType) or
    (TVarObject(DocVariantArray).Count <> 1) then
    Result := default
  else
    Result := TVarObject(DocVariantArray).Values[0];
end;

initialization

end.

