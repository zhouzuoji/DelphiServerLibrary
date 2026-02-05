unit DSLGenericListTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, TypInfo, DSLUtils, DSLTypeTrait;

type
  // TList<T> or TObject<T>
  TGenericListTrait = class(TCustomListTrait)
  private
    FMetaClass: TClass;
    FObjListCtor: TObjectListConstructor;
    FDefCtor: TDefaultConstructor;
    FCountOffset: NativeInt;
    FCountSetter: TListSetCountProc;
    FListGetter: TListGetListProc;
    FIsObjectList: Boolean;
  private
    procedure CheckProperties(_t: TObject; _RttiCtx: PRttiContext);
    procedure CheckMethods(_t: TObject; _RttiCtx: PRttiContext);
  protected
    procedure Init(_RttiCtx: PRttiContext); override;
    procedure FromNull(var _Addr); override;
  public
    function GetLen(const _Addr): Integer; override;
    procedure SetLen(var _Addr; _Len: Integer); override;
    function GetElemPtr(const _Addr; _Idx: Integer): Pointer; override;
    function CreateObject: TObject;
    procedure SetCount(_List: TObject; _Count: Integer); inline;
    function GetCount(_List: TObject): Integer; inline;
    function GetInternalArray(_List: TObject): TArray<Byte>;  inline;
    property MetaClass: TClass read FMetaClass;
    property IsObjectList: Boolean read FIsObjectList;
  end;

implementation

uses
  Rtti;

function IsCountType(ti: PTypeInfo): Boolean;
begin
  Result := TranslateTypeKind(ti) in [tkxInt32, tkxInt64];
end;

function GetElemTypeFromMethodAdd(_Method: TRttiMethod; _RttiCtx: PRttiContext): TCustomTypeTrait;
var
  LRetType: TRttiType;
  LParams: TArray<TRttiParameter>;
begin
  Result := nil;
  LRetType := _Method.ReturnType;
  if (LRetType <> nil) and (LRetType.TypeKind in [tkInteger, tkInt64]) then
  begin
    LParams := _Method.GetParameters;
    if (Length(LParams) = 1) and (pfConst in LParams[0].Flags) then
    begin
      //_MethodAdd := _Method.CodeAddress;
      Result := TCustomTypeTrait.OfType(LParams[0].ParamType.Handle, _RttiCtx);
    end;
  end;
end;

{ TGenericListTrait }

function TGenericListTrait.CreateObject: TObject;
begin
  if Assigned(FObjListCtor) then
    Result := FObjListCtor(MetaClass, 1, True)
  else if Assigned(FDefCtor) then
    Result := FDefCtor(FMetaClass, 1)
  else
    Result := nil;
end;

procedure TGenericListTrait.FromNull(var _Addr);
begin
  Self.SetCount(TObject(_Addr), 0);
end;

procedure TGenericListTrait.CheckMethods(_t: TObject; _RttiCtx: PRttiContext);
var
  LMethod: TRttiMethod;
  LKind: TMethodKind;
  LHasCtor: Boolean;
  LParams: TArray<TRttiParameter>;
  LType: TRttiType absolute _t;
begin
  repeat
    LHasCtor := False;
    for LMethod in LType.GetDeclaredMethods do
    begin
      LKind := LMethod.MethodKind;
      if LKind = mkFunction then
      begin
        if (Elem = nil) and ('Add' = LMethod.Name) then
          SetElem(GetElemTypeFromMethodAdd(LMethod, _RttiCtx));
      end
      else if LMethod.IsConstructor then
      begin
        LHasCtor := True;
        LParams := LMethod.GetParameters;
        if not Assigned(FObjListCtor) and (Length(LParams) = 1) and (LParams[0].ParamType.Handle = TypeInfo(Boolean)) then
          @FObjListCtor := LMethod.CodeAddress
        else if not Assigned(FDefCtor) and (Length(LParams) = 0) then
          @FDefCtor := LMethod.CodeAddress;
      end;
    end;
    if LHasCtor and not Assigned(FObjListCtor) and not Assigned(FDefCtor) then
      raise Exception.CreateFmt('constructor of %s not found', [Self.Name]);
    LType := LType.BaseType;
  until (LType = nil) or ( Assigned(Elem) and (Assigned(FObjListCtor) or Assigned(FDefCtor)) );
end;

procedure TGenericListTrait.CheckProperties(_t: TObject; _RttiCtx: PRttiContext);
var
  LProperty: TRttiProperty;
  LPropInfo: PPropInfo;
  t: TRttiInstanceType;
  LPropName: string;
begin
  t := _t as TRttiInstanceType;
  repeat
    for LProperty in t.GetDeclaredProperties do
    begin
      LPropName := LProperty.Name;
      if LPropName = 'Count' then
      begin
        if IsCountType(LProperty.PropertyType.Handle) then
        begin
          LPropInfo := TRttiInstanceProperty(LProperty).PropInfo;
          @FCountSetter := LPropInfo.SetProc;
          FCountOffset := NativeInt(LPropInfo.GetProc) and not PROPSLOT_MASK;
        end;
      end
      else if LPropName = 'List' then
      begin
        if LProperty.PropertyType.Handle.Kind = tkDynArray then
        begin
          LPropInfo := TRttiInstanceProperty(LProperty).PropInfo;
          @FListGetter := LPropInfo.GetProc;
        end;
      end;
    end;
    t := t.BaseType;
  until not Assigned(t) or ( Assigned(FCountSetter) and Assigned(FListGetter) );
end;

function TGenericListTrait.GetCount(_List: TObject): Integer;
begin
  if _List <> nil then
    Result := PInteger(PAnsiChar(_List) + FCountOffset)^
  else
    Result := 0;
end;

function TGenericListTrait.GetElemPtr(const _Addr; _Idx: Integer): Pointer;
var
  LHack: TArray<Byte> absolute _Addr;
begin
  if _Idx < Self.GetCount(TObject(_Addr)) then
  begin
    Result := Pointer(NativeInt(GetInternalArray(TObject(_Addr))) + _Idx * ElemSize);
  end
  else
    Result := nil;
end;

function TGenericListTrait.GetInternalArray(_List: TObject): TArray<Byte>;
begin
  Result := FListGetter(_List);
end;

function TGenericListTrait.GetLen(const _Addr): Integer;
begin
  Result := Self.GetCount(TObject(_Addr));
end;

procedure TGenericListTrait.Init(_RttiCtx: PRttiContext);
var
  LRttiCtx: TRttiContext;
  LType: TRttiType;
begin
  inherited;
  if _RttiCtx = nil then
    _RttiCtx := @LRttiCtx;
  LType := _RttiCtx.GetType(Self.Handle);
  FMetaClass := Self.TypeData.ClassType;
  FIsObjectList := Self.Name.StartsWith('TObjectList<', True);
  CheckMethods(LType, _RttiCtx);
  CheckProperties(LType, _RttiCtx);
end;

procedure TGenericListTrait.SetCount(_List: TObject; _Count: Integer);
begin
  if _List <> nil then
    FCountSetter(_List, _Count);
end;

procedure TGenericListTrait.SetLen(var _Addr; _Len: Integer);
begin
  if (TObject(_Addr) = nil) and (_Len > 0) then
      TObject(_Addr) := Self.CreateObject;
  FCountSetter(TObject(_Addr), _Len);
end;

end.
