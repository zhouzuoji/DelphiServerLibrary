unit DSLDynArrayTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, TypInfo, DSLUtils, DSLTypeTrait;

type
  TDynArrayTrait = class(TCustomListTrait)
  protected
    procedure Init(_RttiCtx: PRttiContext); override;
    procedure FromNull(var _Addr); override;
  public
    function GetLen(const _Addr): Integer; override;
    procedure SetLen(var _Addr; _Len: Integer); override;
    function GetElemPtr(const _Addr; _Idx: Integer): Pointer; override;
  end;

implementation

{ TDynArrayTrait }

procedure TDynArrayTrait.FromNull(var _Addr);
begin
  DynArrayClear(Pointer(_Addr), Self.Handle);
end;

function TDynArrayTrait.GetElemPtr(const _Addr; _Idx: Integer): Pointer;
var
  LHack: TArray<Byte> absolute _Addr;
begin
  if _Idx < Length(LHack) then
    Result := Pointer(NativeInt(_Addr) + _Idx * ElemSize)
  else
    Result := nil;
end;

function TDynArrayTrait.GetLen(const _Addr): Integer;
var
  LHack: TArray<Byte> absolute _Addr;
begin
  Result := Length(LHack);
end;

procedure TDynArrayTrait.Init(_RttiCtx: PRttiContext);
var
  ti: PTypeInfo;
begin
  inherited;
  ti := nil;
  if Self.TypeData.elType2 <> nil then
    ti := Self.TypeData.elType2^;
  if ti <> nil then
    SetElem(TCustomTypeTrait.OfType(ti, _RttiCtx));
end;

procedure TDynArrayTrait.SetLen(var _Addr; _Len: Integer);
var
  LLen: NativeInt;
begin
  inherited;
  LLen := _Len;
  DynArraySetLength(Pointer(_Addr), Self.Handle, 1, @LLen);
end;

end.
