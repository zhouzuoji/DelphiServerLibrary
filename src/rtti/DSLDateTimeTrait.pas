unit DSLDateTimeTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, TypInfo, DSLUtils, DSLByteStr, DSLTypeTrait;

type
  TDateTimeTrait = class(TCustomTypeTrait)
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

  TTimeTrait = TDateTimeTrait;
  TDateTrait = TDateTimeTrait;

implementation

{ TDateTimeTrait }

procedure TDateTimeTrait.FromBool(_N: Boolean; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromComp(_N: Comp; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromCurrency(_N: Currency; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromDouble(_N: Double; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromExtended(_N: Extended; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromInt32(_N: Integer; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromInt64(_N: Int64; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromNull(var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromSingle(_N: Single; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromUint32(_N: Cardinal; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromUint64(_N: Uint64; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  inherited;

end;

procedure TDateTimeTrait.FromWideString(const _S: WideString; var _Addr);
begin
  inherited;

end;

end.
