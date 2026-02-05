unit DSLSaxRttiWriter;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, TypInfo, DSLUtils, DSLSax, DSLByteStr, DSLRttiUtils, DSLTypeTrait;

type
  TSaxRttiWriter = class(TInterfacedObject, ISaxHandler)
  public
    class function CreateSaxNode(var v; _Trait: TCustomTypeTrait): TSaxNode; overload; static;
    class function CreateSaxNode<T>(var v: T): TSaxNode; overload; static;
    procedure OnNumber(const _Ctx: PSaxContext; const _Node: TSaxNode; const _Value: TNumber);
    function OnBeforeString(const _Ctx: PSaxContext; const _Node: TSaxNode): Boolean;
    procedure OnString(const _Ctx: PSaxContext; const _Node: TSaxNode; const _Value: TByteStrBuilder);
    procedure OnNull(const _Ctx: PSaxContext; const _Node: TSaxNode);
    function OnArray(const _Ctx: PSaxContext; const _Node: TSaxNode; _SizeHint: Integer): Boolean;
    function OnElem(const _Ctx: PSaxContext; const _Node: TSaxNode; _Idx: Integer): TSaxNode;
    function OnObject(const _Ctx: PSaxContext; const _Node: TSaxNode; _SizeHint: Integer): Boolean;
    function OnField(const _Ctx: PSaxContext; const _Node: TSaxNode; _Idx: Integer; const _FieldName: TByteStrBuilder): TSaxNode;
  end;

implementation

uses
  DSLClassTrait, DSLRecordTrait, DSLGenericListTrait;

{ TSaxRttiWriter }

class function TSaxRttiWriter.CreateSaxNode(var v; _Trait: TCustomTypeTrait): TSaxNode;
begin
  if _Trait <> nil then
  begin
    Result.Addr := @v;
    Result.Trait := _Trait;
  end
  else
    raise Exception.CreateFmt('can''t parse json as "%s"', [_Trait.Name]);
end;

class function TSaxRttiWriter.CreateSaxNode<T>(var v: T): TSaxNode;
begin
  Result := CreateSaxNode(v, TCustomTypeTrait.OfType(TypeInfo(T)));
end;

function TSaxRttiWriter.OnArray(const _Ctx: PSaxContext; const _Node: TSaxNode; _SizeHint: Integer): Boolean;
var
  LTrait: TCustomTypeTrait;
  LListClass: TGenericListTrait absolute LTrait;
begin
  LTrait := TCustomTypeTrait(_Node.Trait);
  if LTrait.ClassParent <> TCustomListTrait then
    Exit(False);
  if LTrait.ClassType = TGenericListTrait then
  begin
    if (PPointer(_Node.Addr)^ = nil) and (_SizeHint <> 0) then
      PPointer(_Node.Addr)^ := LListClass.CreateObject;
  end;
  if _SizeHint > 0 then
    TCustomListTrait(LTrait).SetLen(_Node.Addr^, _SizeHint);
  Result := True;
end;

function TSaxRttiWriter.OnBeforeString(const _Ctx: PSaxContext; const _Node: TSaxNode): Boolean;
begin
  Result := TCustomTypeTrait(_Node.Trait).Kind in [tkxInt8..tkxUtf16Str];
end;

function TSaxRttiWriter.OnElem(const _Ctx: PSaxContext; const _Node: TSaxNode; _Idx: Integer): TSaxNode;
var
  LTrait: TCustomTypeTrait;
  LListClass: TCustomListTrait absolute LTrait;
  LOldLen, LNewLen: NativeInt;
begin
  Result.Addr := nil;
  Result.Trait := nil;
  LTrait := TCustomTypeTrait(_Node.Trait);
  if (LTrait.ClassParent <> TCustomListTrait) or (_Idx >= LTrait.MaxLen) then
    Exit;
  LOldLen := LListClass.GetLen(_Node.Addr^);
  if _Idx >= LOldLen then
  begin
    LNewLen := GrowCollection(LOldLen, _Idx + 1);
    if LNewLen > LTrait.MaxLen then
      LNewLen := LTrait.MaxLen;
    LListClass.SetLen(_Node.Addr^, LNewLen);
  end;
  Result.Addr := LListClass.GetElemPtr(_Node.Addr^, _Idx);
  Result.Trait := LListClass.Elem;
end;

function TSaxRttiWriter.OnField(const _Ctx: PSaxContext; const _Node: TSaxNode; _Idx: Integer;
  const _FieldName: TByteStrBuilder): TSaxNode;
var
  LIdx: Integer;
  LTrait: TCustomTypeTrait;
  LClass: TClassTrait absolute LTrait;
  LRecord: TRecordTrait absolute LTrait;
  LClassType: TClass;
begin
  LTrait := TCustomTypeTrait(_Node.Trait);
  LClassType := LTrait.ClassType;
  if LClassType = TClassTrait then
  begin
    LIdx := LClass.IndexOf(_FieldName.GetData, _FieldName.Len);
    if LIdx <> -1 then
    begin
      Result.Trait := Pointer(LClass.Fields[LIdx].TypeTrait);
      Result.Addr := Pointer(PNativeInt(_Node.Addr)^ + LClass.Fields[LIdx].Offset);
      Exit;
    end;
  end
  else if LClassType = TRecordTrait then
  begin
    LIdx := LRecord.IndexOf(_FieldName.GetData, _FieldName.Len);
    if LIdx <> -1 then
    begin
      Result.Trait := Pointer(LRecord.Fields[LIdx].TypeTrait);
      Result.Addr := Pointer(NativeInt(_Node.Addr) + LRecord.Fields[LIdx].Offset);
      Exit;
    end;
  end;
  Result.Addr := nil;
  Result.Trait := nil;
end;

procedure TSaxRttiWriter.OnNull(const _Ctx: PSaxContext; const _Node: TSaxNode);
begin
  TCustomTypeTrait(_Node.Trait).Assign(_Node.Addr^);
end;

procedure TSaxRttiWriter.OnNumber(const _Ctx: PSaxContext; const _Node: TSaxNode; const _Value: TNumber);
begin
  TCustomTypeTrait(_Node.Trait).Assign(_Value, _Node.Addr^);
end;

function TSaxRttiWriter.OnObject(const _Ctx: PSaxContext; const _Node: TSaxNode; _SizeHint: Integer): Boolean;
var
  LTraitClass: TClass;
begin
  LTraitClass := TCustomTypeTrait(_Node.Trait).ClassType;
  Result := False;
  if LTraitClass = TClassTrait then
  begin
    if PPointer(_Node.Addr)^ = nil then
      PPointer(_Node.Addr)^ := TClassTrait(_Node.Trait).CreateObject;
    Result := True;
  end
  else if LTraitClass = TRecordTrait then
    Result := True;
end;

procedure TSaxRttiWriter.OnString(const _Ctx: PSaxContext; const _Node: TSaxNode; const _Value: TByteStrBuilder);
begin
  TCustomTypeTrait(_Node.Trait).Assign(_Value, _Node.Addr^);
end;

end.
