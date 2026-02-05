unit DSLCharTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, DSLUtils, DSLByteStr, DSLTypeTrait, DSLNumberTrait;

type
  TCharTrait = class(TIntegerTrait)
  protected
    procedure FromBool(_N: Boolean; var _Addr); override;
    procedure FromByteStr(const _S: TByteStrBuilder; var _Addr); override;
    procedure FromShortString(const _S: ShortString; var _Addr); override;
    procedure FromRawByteStr(const _S: RawByteString; var _Addr); override;
    procedure FromWideString(const _S: WideString; var _Addr); override;
    procedure FromUtf16Str(const _S: UnicodeString; var _Addr); override;
  end;

  TAnsiCharTrait = TCharTrait;
  TWideCharTrait = TCharTrait;

implementation

{ TCharTrait }

procedure TCharTrait.FromBool(_N: Boolean; var _Addr);
begin
  if _N then
    SetInt32($31, _Addr)
  else
    SetInt32($30, _Addr);
end;

procedure TCharTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
var
  LVal: Integer;
begin
  LVal := 0;
  if _S.Len > 0 then
    LVal := PByte(_S.GetData)^;
  SetInt32(LVal, _Addr);
end;

procedure TCharTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
var
  LVal: Integer;
begin
  LVal := 0;
  if _S <> '' then
    LVal := PByte(_S)^;
  SetInt32(LVal, _Addr);
end;

procedure TCharTrait.FromShortString(const _S: ShortString; var _Addr);
var
  LVal: Integer;
begin
  LVal := 0;
  if _S <> '' then
    LVal := PByte(@_S)[1];
  SetInt32(LVal, _Addr);
end;

procedure TCharTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
var
  LVal: Integer;
begin
  LVal := 0;
  if _S <> '' then
    LVal := PWord(_S)^;
  SetInt32(LVal, _Addr);
end;

procedure TCharTrait.FromWideString(const _S: WideString; var _Addr);
var
  LVal: Integer;
begin
  LVal := 0;
  if _S <> '' then
    LVal := PWord(_S)^;
  SetInt32(LVal, _Addr);
end;

end.
