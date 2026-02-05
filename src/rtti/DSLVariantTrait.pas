unit DSLVariantTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, TypInfo, DSLUtils, DSLByteStr, DSLTypeTrait;

type
  TVariantTrait = class(TCustomTypeTrait)
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

uses
  Variants, Math;

{ TVariantTrait }

procedure TVariantTrait.FromBool(_N: Boolean; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  Variant(_Addr) := _S.Clone;
end;

procedure TVariantTrait.FromComp(_N: Comp; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromCurrency(_N: Currency; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromDouble(_N: Double; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromExtended(_N: Extended; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromInt32(_N: Integer; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromInt64(_N: Int64; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromNull(var _Addr);
begin
  Variant(_Addr) := Null;
end;

procedure TVariantTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  Variant(_Addr) := _S;
end;

procedure TVariantTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  Variant(_Addr) := _S;
end;

procedure TVariantTrait.FromSingle(_N: Single; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromUint32(_N: Cardinal; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromUint64(_N: Uint64; var _Addr);
begin
  Variant(_Addr) := _N;
end;

procedure TVariantTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  Variant(_Addr) := _S;
end;

procedure TVariantTrait.FromWideString(const _S: WideString; var _Addr);
begin
  Variant(_Addr) := _S;
end;

end.
