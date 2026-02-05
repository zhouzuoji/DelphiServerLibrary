unit DSLNumberTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, TypInfo, DSLUtils, DSLByteStr, DSLTypeTrait;

type
  TIntegerTrait = class(TCustomTypeTrait)
  private
    FOrdType: TOrdType;
    FMin, FMax: Integer;
    procedure CheckInt64(_N: Int64);
    procedure CheckUint64(_N: Uint64);
    procedure CheckInt32(_N: Integer);
    procedure CheckUint32(_N: Cardinal);
  protected
    procedure SetInt32(_N: Integer; var _Addr); inline;
    procedure SetInt64(_N: Int64; var _Addr); inline;

    procedure Init(_RttiCtx: PRttiContext); override;
    procedure FromNull(var _Addr); override;
    procedure FromBool(_N: Boolean; var _Addr); override;
    procedure FromInt32(_N: Integer; var _Addr); override;
    procedure FromUint32(_N: Cardinal; var _Addr); override;
    procedure FromInt64(_N: Int64; var _Addr); override;
    procedure FromUint64(_N: Uint64; var _Addr); override;

    procedure FromSingle(_N: Single; var _Addr); override;
    procedure FromDouble(_N: Double; var _Addr); override;
    procedure FromExtended(_N: Extended; var _Addr); override;
    procedure FromComp(_N: Comp; var _Addr); override;
    procedure FromCurrency(_N: Currency; var _Addr); override;

    procedure FromByteStr(const _S: TByteStrBuilder; var _Addr); override;
    procedure FromShortString(const _S: ShortString; var _Addr); override;
    procedure FromRawByteStr(const _S: RawByteString; var _Addr); override;
    procedure FromWideString(const _S: WideString; var _Addr); override;
    procedure FromUtf16Str(const _S: UnicodeString; var _Addr); override;
  public
    property OrdType: TOrdType read FOrdType;
    property Min: Integer read FMin;
    property Max: Integer read FMax;
  end;

  TInt8Trait = TIntegerTrait;
  TUint8Trait = TIntegerTrait;
  TInt16Trait = TIntegerTrait;
  TUint16Trait = TIntegerTrait;
  TInt32Trait = TIntegerTrait;
  TUint32Trait = TIntegerTrait;

  TInt64Trait = class(TCustomTypeTrait)
  private
    FMin, FMax: Int64;
  protected
    procedure SetInt64(_N: Int64; var _Addr); inline;

    procedure Init(_RttiCtx: PRttiContext); override;
    procedure FromNull(var _Addr); override;
    procedure FromBool(_N: Boolean; var _Addr); override;

    procedure FromInt32(_N: Integer; var _Addr); override;
    procedure FromUint32(_N: Cardinal; var _Addr); override;
    procedure FromInt64(_N: Int64; var _Addr); override;
    procedure FromUint64(_N: Uint64; var _Addr); override;

    procedure FromSingle(_N: Single; var _Addr); override;
    procedure FromDouble(_N: Double; var _Addr); override;
    procedure FromExtended(_N: Extended; var _Addr); override;
    procedure FromComp(_N: Comp; var _Addr); override;
    procedure FromCurrency(_N: Currency; var _Addr); override;

    procedure FromByteStr(const _S: TByteStrBuilder; var _Addr); override;
    procedure FromShortString(const _S: ShortString; var _Addr); override;
    procedure FromRawByteStr(const _S: RawByteString; var _Addr); override;
    procedure FromWideString(const _S: WideString; var _Addr); override;
    procedure FromUtf16Str(const _S: UnicodeString; var _Addr); override;
  public
    property Min: Int64 read FMin;
    property Max: Int64 read FMax;
  end;

  TUint64Trait = TInt64Trait;

  TFloatTrait = class(TCustomTypeTrait)
  protected
    procedure FromNull(var _Addr); override;
    procedure FromBool(_N: Boolean; var _Addr); override;

    procedure FromInt32(_N: Integer; var _Addr); override;
    procedure FromUint32(_N: Cardinal; var _Addr); override;
    procedure FromInt64(_N: Int64; var _Addr); override;
    procedure FromUint64(_N: Uint64; var _Addr); override;

    procedure FromSingle(_N: Single; var _Addr); override;
    procedure FromDouble(_N: Double; var _Addr); override;
    procedure FromExtended(_N: Extended; var _Addr); override;
    procedure FromComp(_N: Comp; var _Addr); override;
    procedure FromCurrency(_N: Currency; var _Addr); override;

    procedure FromByteStr(const _S: TByteStrBuilder; var _Addr); override;
    procedure FromShortString(const _S: ShortString; var _Addr); override;
    procedure FromRawByteStr(const _S: RawByteString; var _Addr); override;
    procedure FromWideString(const _S: WideString; var _Addr); override;
    procedure FromUtf16Str(const _S: UnicodeString; var _Addr); override;
  end;

  TSingleTrait = TFloatTrait;
  TDoubleTrait = TFloatTrait;
  TExtendedTrait = TFloatTrait;
  TCompTrait = TFloatTrait;
  TCurrencyTrait = TFloatTrait;

implementation

uses
  SysConst, RTLConsts, Math, DSLNumberParse;

{ TIntegerTrait }

procedure TIntegerTrait.CheckInt64(_N: Int64);
begin
  if FOrdType in [otSByte, otSWord, otSLong] then
  begin
    if (_N < FMin) or (_N > FMax) then
      raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  end
  else begin
    if (_N < Cardinal(FMin)) or (_N > Cardinal(FMax)) then
      raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  end;
end;

procedure TIntegerTrait.CheckInt32(_N: Integer);
begin
  if FOrdType in [otSByte, otSWord, otSLong] then
  begin
    if (_N < FMin) or (_N > FMax) then
      raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  end
  else begin
    if (Int64(_N) < Cardinal(FMin)) or (Int64(_N) > Cardinal(FMax)) then
      raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  end;
end;

procedure TIntegerTrait.CheckUint32(_N: Cardinal);
begin
  if FOrdType in [otSByte, otSWord, otSLong] then
  begin
    if (Int64(_N) < Int64(FMin)) or (Int64(_N) > Int64(FMax)) then
      raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  end
  else begin
    if (_N < Cardinal(FMin)) or (_N > Cardinal(FMax)) then
      raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  end;
end;

procedure TIntegerTrait.CheckUint64(_N: Uint64);
begin
  if FOrdType in [otSByte, otSWord, otSLong] then
  begin
    if (FMax < 0) or (_N > Cardinal(FMax)) or ((FMin > 0) and (_N < Cardinal(FMin))) then
      raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  end
  else begin
    if (_N < Cardinal(FMin)) or (_N > Cardinal(FMax)) then
      raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  end;
end;

procedure TIntegerTrait.FromBool(_N: Boolean; var _Addr);
begin
  FromInt32(Ord(_N), _Addr);
end;

procedure TIntegerTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  Self.Assign(_S.ToNumber(), _Addr);
end;

procedure TIntegerTrait.FromComp(_N: Comp; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TIntegerTrait.FromCurrency(_N: Currency; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TIntegerTrait.FromDouble(_N: Double; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TIntegerTrait.FromExtended(_N: Extended; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TIntegerTrait.FromInt32(_N: Integer; var _Addr);
begin
  SetInt32(_N, _Addr);
end;

procedure TIntegerTrait.FromInt64(_N: Int64; var _Addr);
begin
  SetInt64(_N, _Addr);
end;

procedure TIntegerTrait.FromNull(var _Addr);
begin
  case Self.Size of
    1: Byte(_Addr) := 0;
    2: Word(_Addr) := 0;
    4: Cardinal(_Addr) := 0;
  end;
end;

procedure TIntegerTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PAnsiChar(_S), nil), _Addr);
end;

procedure TIntegerTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  Assign(parseNumber(PAnsiChar(@_S) + 1, PByte(@_S)^, nil), _Addr);
end;

procedure TIntegerTrait.FromSingle(_N: Single; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TIntegerTrait.FromUint32(_N: Cardinal; var _Addr);
begin
  Self.CheckUint32(_N);
  case Self.Kind of
    tkxInt8: ShortInt(_Addr) := _N;
    tkxUint8: Byte(_Addr) := _N;
    tkxInt16: SmallInt(_Addr) := _N;
    tkxUint16: Word(_Addr) := _N;
    tkxInt32: Integer(_Addr) := _N;
    tkxUint32: Cardinal(_Addr) := _N;
  end;
end;

procedure TIntegerTrait.FromUint64(_N: Uint64; var _Addr);
begin
  Self.CheckUint64(_N);
  case Self.Kind of
    tkxInt8: ShortInt(_Addr) := _N;
    tkxUint8: Byte(_Addr) := _N;
    tkxInt16: SmallInt(_Addr) := _N;
    tkxUint16: Word(_Addr) := _N;
    tkxInt32: Integer(_Addr) := _N;
    tkxUint32: Cardinal(_Addr) := _N;
  end;
end;

procedure TIntegerTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PWideChar(_S), nil), _Addr);
end;

procedure TIntegerTrait.FromWideString(const _S: WideString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PWideChar(_S), nil), _Addr);
end;

procedure TIntegerTrait.Init(_RttiCtx: PRttiContext);
begin
  inherited;
  FOrdType := TypeData.OrdType;
  FMin := TypeData.MinValue;
  FMax := TypeData.MaxValue;
end;

procedure TIntegerTrait.SetInt32(_N: Integer; var _Addr);
begin
  Self.CheckInt32(_N);
  case Self.Kind of
    tkxInt8: ShortInt(_Addr) := _N;
    tkxUint8: Byte(_Addr) := _N;
    tkxInt16: SmallInt(_Addr) := _N;
    tkxUint16: Word(_Addr) := _N;
    tkxInt32: Integer(_Addr) := _N;
    tkxUint32: Cardinal(_Addr) := _N;
  end;
end;

procedure TIntegerTrait.SetInt64(_N: Int64; var _Addr);
begin
  Self.CheckInt64(_N);
  case Self.Kind of
    tkxInt8: ShortInt(_Addr) := _N;
    tkxUint8: Byte(_Addr) := _N;
    tkxInt16: SmallInt(_Addr) := _N;
    tkxUint16: Word(_Addr) := _N;
    tkxInt32: Integer(_Addr) := _N;
    tkxUint32: Cardinal(_Addr) := _N;
  end;
end;

{ TInt64Trait }

procedure TInt64Trait.FromBool(_N: Boolean; var _Addr);
begin
  SetInt64(Ord(_N), _Addr);
end;

procedure TInt64Trait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  if _S.Len = 0 then
    inherited;
  Self.Assign(_S.ToNumber(), _Addr);
end;

procedure TInt64Trait.FromComp(_N: Comp; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TInt64Trait.FromCurrency(_N: Currency; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TInt64Trait.FromDouble(_N: Double; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TInt64Trait.FromExtended(_N: Extended; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TInt64Trait.FromInt32(_N: Integer; var _Addr);
begin
  Self.SetInt64(Int64(_N), _Addr);
end;

procedure TInt64Trait.FromInt64(_N: Int64; var _Addr);
begin
  if (_N < FMin) or (_N > FMax) then
    raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  Int64(_Addr) := _N;
end;

procedure TInt64Trait.FromNull(var _Addr);
begin
  Int64(_Addr) := 0;
end;

procedure TInt64Trait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PAnsiChar(_S), nil), _Addr);
end;

procedure TInt64Trait.FromShortString(const _S: ShortString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PAnsiChar(@_S) + 1, PByte(@_S)^, nil), _Addr);
end;

procedure TInt64Trait.FromSingle(_N: Single; var _Addr);
begin
  Self.SetInt64(Round(_N), _Addr);
end;

procedure TInt64Trait.FromUint32(_N: Cardinal; var _Addr);
begin
  Self.SetInt64(Int64(_N), _Addr);
end;

procedure TInt64Trait.FromUint64(_N: Uint64; var _Addr);
begin
  Self.SetInt64(Int64(_N), _Addr);
end;

procedure TInt64Trait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PWideChar(_S), nil), _Addr);
end;

procedure TInt64Trait.FromWideString(const _S: WideString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PWideChar(_S), nil), _Addr);
end;

procedure TInt64Trait.Init(_RttiCtx: PRttiContext);
begin
  inherited;
  FMin := TypeData.MinInt64Value;
  FMax := TypeData.MaxInt64Value;
end;

procedure TInt64Trait.SetInt64(_N: Int64; var _Addr);
begin
  if (_N < FMin) or (_N > FMax) then
    raise ERangeError.CreateRes(PResStringRec(@SRangeError));
  Int64(_Addr) := _N;
end;

{ TFloatTrait }

procedure TFloatTrait.FromBool(_N: Boolean; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := Ord(_N);
    tkxDouble: Double(_Addr) := Ord(_N);
    tkxExtended: Extended(_Addr) := Ord(_N);
    tkxComp: Comp(_Addr) := Ord(_N);
    tkxCurr: Currency(_Addr) := Ord(_N);
  end;
end;

procedure TFloatTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  Self.Assign(_S.ToNumber(), _Addr);
end;

procedure TFloatTrait.FromComp(_N: Comp; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := _N;
    tkxDouble: Double(_Addr) := _N;
    tkxExtended: Extended(_Addr) := _N;
    tkxComp: Comp(_Addr) := _N;
    tkxCurr: Currency(_Addr) := _N;
  end;
end;

procedure TFloatTrait.FromCurrency(_N: Currency; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := _N;
    tkxDouble: Double(_Addr) := _N;
    tkxExtended: Extended(_Addr) := _N;
    tkxComp: Comp(_Addr) := _N;
    tkxCurr: Currency(_Addr) := _N;
  end;
end;

procedure TFloatTrait.FromDouble(_N: Double; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := _N;
    tkxDouble: Double(_Addr) := _N;
    tkxExtended: Extended(_Addr) := _N;
    tkxComp: Comp(_Addr) := _N;
    tkxCurr: Currency(_Addr) := _N;
  end;
end;

procedure TFloatTrait.FromExtended(_N: Extended; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := _N;
    tkxDouble: Double(_Addr) := _N;
    tkxExtended: Extended(_Addr) := _N;
    tkxComp: Comp(_Addr) := _N;
    tkxCurr: Currency(_Addr) := _N;
  end;
end;

procedure TFloatTrait.FromInt32(_N: Integer; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := _N;
    tkxDouble: Double(_Addr) := _N;
    tkxExtended: Extended(_Addr) := _N;
    tkxComp: Comp(_Addr) := _N;
    tkxCurr: Currency(_Addr) := _N;
  end;
end;

procedure TFloatTrait.FromInt64(_N: Int64; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := _N;
    tkxDouble: Double(_Addr) := _N;
    tkxExtended: Extended(_Addr) := _N;
    tkxComp: Comp(_Addr) := _N;
    tkxCurr: Currency(_Addr) := _N;
  end;
end;

procedure TFloatTrait.FromNull(var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := 0;
    tkxDouble: Double(_Addr) := 0;
    tkxExtended: Extended(_Addr) := 0;
    tkxComp: Comp(_Addr) := 0;
    tkxCurr: Currency(_Addr) := 0;
  end;
end;

procedure TFloatTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PAnsiChar(_S), nil), _Addr);
end;

procedure TFloatTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  Assign(parseNumber(PAnsiChar(@_S) + 1, PByte(@_S)^, nil), _Addr);
end;

procedure TFloatTrait.FromSingle(_N: Single; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := _N;
    tkxDouble: Double(_Addr) := _N;
    tkxExtended: Extended(_Addr) := _N;
    tkxComp: Comp(_Addr) := _N;
    tkxCurr: Currency(_Addr) := _N;
  end;
end;

procedure TFloatTrait.FromUint32(_N: Cardinal; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := _N;
    tkxDouble: Double(_Addr) := _N;
    tkxExtended: Extended(_Addr) := _N;
    tkxComp: Comp(_Addr) := _N;
    tkxCurr: Currency(_Addr) := _N;
  end;
end;

procedure TFloatTrait.FromUint64(_N: Uint64; var _Addr);
begin
  case Self.Kind of
    tkxSingle: Single(_Addr) := _N;
    tkxDouble: Double(_Addr) := _N;
    tkxExtended: Extended(_Addr) := _N;
    tkxComp: Comp(_Addr) := _N;
    tkxCurr: Currency(_Addr) := _N;
  end;
end;

procedure TFloatTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PWideChar(_S), nil), _Addr);
end;

procedure TFloatTrait.FromWideString(const _S: WideString; var _Addr);
begin
  if _S = '' then
    inherited;
  Assign(parseNumber(PWideChar(_S), nil), _Addr);
end;

end.
