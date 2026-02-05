unit DSLArrayTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, TypInfo, DSLUtils, DSLTypeTrait;

type
  TArrayTrait = class(TCustomListTrait)
  protected
    procedure Init(_RttiCtx: PRttiContext); override;
    procedure FromNull(var _Addr); override;
  public
    function GetLen(const _Addr): Integer; override;
    procedure SetLen(var _Addr; _Len: Integer); override;
    function GetElemPtr(const _Addr; _Idx: Integer): Pointer; override;
  end;

implementation

{ TArrayTrait }

procedure TArrayTrait.FromNull(var _Addr);
begin
  FinalizeArray(@_Addr, Self.Elem.Handle, Self.MaxLen);
  FillChar(_Addr, Self.Size, 0);
end;

function TArrayTrait.GetElemPtr(const _Addr; _Idx: Integer): Pointer;
begin
  if _Idx < Self.MaxLen then
    Result := Pointer(NativeInt(@_Addr) + _Idx * ElemSize)
  else
    Result := nil;
end;

function TArrayTrait.GetLen(const _Addr): Integer;
begin
  Result := Self.MaxLen;
end;

procedure TArrayTrait.Init(_RttiCtx: PRttiContext);
var
  ti: PTypeInfo;
begin
  inherited;
  ti := nil;
  if TypeData.ArrayData.ElType <> nil then
    ti := TypeData.ArrayData.ElType^;
  if ti <> nil then
    SetElem(TCustomTypeTrait.OfType(ti, _RttiCtx));
end;

procedure TArrayTrait.SetLen(var _Addr; _Len: Integer);
begin

end;

end.
