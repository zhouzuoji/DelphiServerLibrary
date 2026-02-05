unit DSLBoolTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, TypInfo, DSLUtils, DSLByteStr, DSLTypeTrait;

type
  TBoolTrait = class(TCustomTypeTrait)
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

  TByteBoolTrait = class(TCustomTypeTrait)
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

  TWordBoolTrait = class(TCustomTypeTrait)
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

  TLongBoolTrait = class(TCustomTypeTrait)
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

implementation

{ TBoolTrait }

procedure TBoolTrait.FromBool(_N: Boolean; var _Addr);
begin
  Boolean(_Addr) := _N;
end;

procedure TBoolTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  inherited;

end;

procedure TBoolTrait.FromComp(_N: Comp; var _Addr);
begin
  Boolean(_Addr) := _N <> 0;
end;

procedure TBoolTrait.FromCurrency(_N: Currency; var _Addr);
begin
  Boolean(_Addr) := _N <> 0;
end;

procedure TBoolTrait.FromDouble(_N: Double; var _Addr);
begin
  Boolean(_Addr) := _N <> 0;
end;

procedure TBoolTrait.FromExtended(_N: Extended; var _Addr);
begin
  Boolean(_Addr) := _N <> 0;
end;

procedure TBoolTrait.FromInt32(_N: Integer; var _Addr);
begin
  Boolean(_Addr) := _N <> 0;
end;

procedure TBoolTrait.FromInt64(_N: Int64; var _Addr);
begin
  Boolean(_Addr) := _N <> 0;
end;

procedure TBoolTrait.FromNull(var _Addr);
begin
  Boolean(_Addr) := False;
end;

procedure TBoolTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin

end;

procedure TBoolTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  inherited;

end;

procedure TBoolTrait.FromSingle(_N: Single; var _Addr);
begin
  Boolean(_Addr) := _N <> 0;
end;

procedure TBoolTrait.FromUint32(_N: Cardinal; var _Addr);
begin
  Boolean(_Addr) := _N <> 0;
end;

procedure TBoolTrait.FromUint64(_N: Uint64; var _Addr);
begin
  Boolean(_Addr) := _N <> 0;
end;

procedure TBoolTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  inherited;

end;

procedure TBoolTrait.FromWideString(const _S: WideString; var _Addr);
begin
  inherited;

end;

{ TByteBoolTrait }

procedure TByteBoolTrait.FromBool(_N: Boolean; var _Addr);
begin
  ByteBool(_Addr) := _N;
end;

procedure TByteBoolTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  inherited;

end;

procedure TByteBoolTrait.FromComp(_N: Comp; var _Addr);
begin
  ByteBool(_Addr) := _N <> 0;
end;

procedure TByteBoolTrait.FromCurrency(_N: Currency; var _Addr);
begin
  ByteBool(_Addr) := _N <> 0;
end;

procedure TByteBoolTrait.FromDouble(_N: Double; var _Addr);
begin
  ByteBool(_Addr) := _N <> 0;
end;

procedure TByteBoolTrait.FromExtended(_N: Extended; var _Addr);
begin
  ByteBool(_Addr) := _N <> 0;
end;

procedure TByteBoolTrait.FromInt32(_N: Integer; var _Addr);
begin
  ByteBool(_Addr) := _N <> 0;
end;

procedure TByteBoolTrait.FromInt64(_N: Int64; var _Addr);
begin
  ByteBool(_Addr) := _N <> 0;
end;

procedure TByteBoolTrait.FromNull(var _Addr);
begin
  ByteBool(_Addr) := False;
end;

procedure TByteBoolTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  inherited;

end;

procedure TByteBoolTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  inherited;

end;

procedure TByteBoolTrait.FromSingle(_N: Single; var _Addr);
begin
  ByteBool(_Addr) := _N <> 0;
end;

procedure TByteBoolTrait.FromUint32(_N: Cardinal; var _Addr);
begin
  ByteBool(_Addr) := _N <> 0;
end;

procedure TByteBoolTrait.FromUint64(_N: Uint64; var _Addr);
begin
  ByteBool(_Addr) := _N <> 0;
end;

procedure TByteBoolTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  inherited;

end;

procedure TByteBoolTrait.FromWideString(const _S: WideString; var _Addr);
begin
  inherited;

end;

{ TWordBoolTrait }

procedure TWordBoolTrait.FromBool(_N: Boolean; var _Addr);
begin
  WordBool(_Addr) := _N;
end;

procedure TWordBoolTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  inherited;

end;

procedure TWordBoolTrait.FromComp(_N: Comp; var _Addr);
begin
  WordBool(_Addr) := _N <> 0;
end;

procedure TWordBoolTrait.FromCurrency(_N: Currency; var _Addr);
begin
  WordBool(_Addr) := _N <> 0;
end;

procedure TWordBoolTrait.FromDouble(_N: Double; var _Addr);
begin
  WordBool(_Addr) := _N <> 0;
end;

procedure TWordBoolTrait.FromExtended(_N: Extended; var _Addr);
begin
  WordBool(_Addr) := _N <> 0;
end;

procedure TWordBoolTrait.FromInt32(_N: Integer; var _Addr);
begin
  WordBool(_Addr) := _N <> 0;
end;

procedure TWordBoolTrait.FromInt64(_N: Int64; var _Addr);
begin
  WordBool(_Addr) := _N <> 0;
end;

procedure TWordBoolTrait.FromNull(var _Addr);
begin
  WordBool(_Addr) := False;
end;

procedure TWordBoolTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  inherited;

end;

procedure TWordBoolTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  inherited;

end;

procedure TWordBoolTrait.FromSingle(_N: Single; var _Addr);
begin
  WordBool(_Addr) := _N <> 0;
end;

procedure TWordBoolTrait.FromUint32(_N: Cardinal; var _Addr);
begin
  WordBool(_Addr) := _N <> 0;
end;

procedure TWordBoolTrait.FromUint64(_N: Uint64; var _Addr);
begin
  WordBool(_Addr) := _N <> 0;
end;

procedure TWordBoolTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  inherited;

end;

procedure TWordBoolTrait.FromWideString(const _S: WideString; var _Addr);
begin
  inherited;

end;

{ TLongBoolTrait }

procedure TLongBoolTrait.FromBool(_N: Boolean; var _Addr);
begin
  LongBool(_Addr) := _N;
end;

procedure TLongBoolTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  inherited;

end;

procedure TLongBoolTrait.FromComp(_N: Comp; var _Addr);
begin
  LongBool(_Addr) := _N <> 0;
end;

procedure TLongBoolTrait.FromCurrency(_N: Currency; var _Addr);
begin
  LongBool(_Addr) := _N <> 0;
end;

procedure TLongBoolTrait.FromDouble(_N: Double; var _Addr);
begin
  LongBool(_Addr) := _N <> 0;
end;

procedure TLongBoolTrait.FromExtended(_N: Extended; var _Addr);
begin
  LongBool(_Addr) := _N <> 0;
end;

procedure TLongBoolTrait.FromInt32(_N: Integer; var _Addr);
begin
  LongBool(_Addr) := _N <> 0;
end;

procedure TLongBoolTrait.FromInt64(_N: Int64; var _Addr);
begin
  LongBool(_Addr) := _N <> 0;
end;

procedure TLongBoolTrait.FromNull(var _Addr);
begin
  LongBool(_Addr) := False;
end;

procedure TLongBoolTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  inherited;

end;

procedure TLongBoolTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  inherited;

end;

procedure TLongBoolTrait.FromSingle(_N: Single; var _Addr);
begin
  LongBool(_Addr) := _N <> 0;
end;

procedure TLongBoolTrait.FromUint32(_N: Cardinal; var _Addr);
begin
  LongBool(_Addr) := _N <> 0;
end;

procedure TLongBoolTrait.FromUint64(_N: Uint64; var _Addr);
begin
  LongBool(_Addr) := _N <> 0;
end;

procedure TLongBoolTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  inherited;

end;

procedure TLongBoolTrait.FromWideString(const _S: WideString; var _Addr);
begin
  inherited;

end;

end.
