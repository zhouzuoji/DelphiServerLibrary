unit DSLRttiUtils;

interface

uses
  SysUtils,
  Classes,
  Rtti,
  TypInfo,
  Generics.Collections,
  Generics.Defaults,
  DSLArray;

{
���캯���ڶ�������flagΪ���,
  flag=0ʱ, ��1������Ϊ�ѷ���Ķ����ַ,
  flag=0ʱ, ��1������ΪClassType
�����������ǹ��캯��ԭ�������Ĳ���
}
type
  TParamlessConstructor = function(vmt: TClass; flag: Shortint): TObject;
  TObjectListConstructor = function(vmt: TClass; flag: Shortint; AOwnsObjects: Boolean): TObject;
  TListSetCountProc = procedure(_Self: TObject; Value: Integer);
  TListGetListProc = function(_Self: TObject): TArray<Byte>;
{$M+}
type
  TClosure = reference to procedure;
  TClosure<T> = reference to procedure(_:T);
  TClosure<T1, T2> = reference to procedure(_1: T1; _2: T2);
  TClosure<T1, T2, T3> = reference to procedure(_1: T1 ;_2: T2; _3: T3);
  TClosure<T1, T2, T3, T4> = reference to procedure(_1: T1 ;_2: T2; _3: T3; _4: T4);
  TClosure<T1, T2, T3, T4, T5> = reference to procedure(_1: T1 ;_2: T2; _3: T3; _4: T4; _5: T5);
{$M-}

// get element type of generic TList<T> or TObjectList<T>
function getGenericListElementType(var avContext: TRttiContext;
  avListClass: TClass): TRttiType; overload;
function getGenericListElementType(avListClass: TClass): PTypeInfo; overload;
function GetParamlessConstructor(t: TRttiInstanceType): TParamlessConstructor;
function GetObjectListConstructor(t: TRttiInstanceType): TObjectListConstructor;

type
  TRTTIAttributeClass = class of TCustomAttribute;
  CalleeOwnsRetValue = class(TCustomAttribute);
  ITypeTrait = interface
    procedure WriteAsStr(const _S: string; var _Addr);
    function ReadAsStr(const _Addr): string;
  end;

  TIntegerTypeTrait = class(TInterfacedObject, ITypeTrait)
  private
    FOrdType: TOrdType;
    FMinValue, FMaxValue: Integer;
  public
    procedure WriteAsStr(const _S: string; var _Addr);
    function ReadAsStr(const _Addr): string;
    property OrdType: TOrdType read FOrdType;
    property MinValue: Integer read FMinValue;
    property MaxValue: Integer read FMaxValue;
  end;

  TCustomClassTrait = class
  private
    FParamlessCtor: TParamlessConstructor;
    FMetaClass: TClass;
    FTypeInfo: PTypeInfo;
  protected
    procedure Init(t: TRttiStructuredType); virtual;
  public
    constructor Create(_TypeInfo: PTypeInfo); virtual;
    class function CreateTrait(_TypeInfo: PTypeInfo): TCustomClassTrait; static;
    function CreateObject: TObject; virtual;
    property MetaClass: TClass read FMetaClass;
    property TypeInfo_: PTypeInfo read FTypeInfo;
  end;

  TClassField = record
    Name: string;
    Offset: Integer;
    _Type: PTypeInfo;
  end;

  TDataClassTrait = class(TCustomClassTrait)
  private
    FFields: TArray<TClassField>;
  protected
    procedure Init(t: TRttiStructuredType); override;
  public
    property Fields: TArray<TClassField> read FFields;
  end;

  TGenericListTrait = class(TCustomClassTrait)
  private
    FObjectListCtor: TObjectListConstructor;
    FElementType: PTypeInfo;
    FElementTypeData: PTypeData;
    FMethodAdd: Pointer;
    FCountOffset: NativeInt;
    FMethodSetCount: TListSetCountProc;
    FMethodGetList: TListGetListProc;
    FIsObjectList: Boolean;
    procedure FindMethods(t: TRttiType);
    procedure FindProperties(_t: TRttiStructuredType);
  protected
    procedure Init(t: TRttiStructuredType); override;
  public
    function CreateObject: TObject; override;
    procedure SetCount(_List: TObject; _Count: Integer);
    function GetCount(_List: TObject): Integer;
    function GetInternalArray(_List: TObject): TArray<Byte>;
    property IsObjectList: Boolean read FIsObjectList;
    property ElementType: PTypeInfo read FElementType;
    property ElementTypeData: PTypeData read FElementTypeData;
  end;

  TdslGenericList = class
  private
    tvListType: TRttiType;
    tvListConstructor: Pointer;
    tvIsObjectList: Boolean;
    tvElementType: TRttiType;
    tvTypeInfo: PTypeInfo;
    tvTypeSize: Integer;
    tvRttiMethodAdd: TRttiMethod;
    tvMethodAdd: TMethod;
    tvValue: TValue;
    tvConstructors: TdslArray<TRttiMethod>;
  private
    procedure CheckMethodGetItem(avMethod: TRttiMethod);
    procedure CheckMethodAdd(avMethod: TRttiMethod);
    procedure CheckListConstructor(avMethod: TRttiMethod);
    procedure findListMethod;
    procedure findConstructors;
  public
    constructor Create(var avContext: TRttiContext; avListClass: TClass);

    { ��������List���� }
    function NewList: TObject;

    { }
    function Add(avList: TObject; const avNewItem): Integer; overload;

    { ���������record����Ԫ��, record���ݴ洢��tvValue�� }
    function AddInternal(avList: TObject): Integer; overload;

    { ����һ��class���͵Ķ���, ��Ԫ�����Ͳ���class��û��Ĭ�Ϲ��캯��(�޲����Ĺ��캯��)ʱ, ����nil }
    function NewObject: TObject;

    { tvValue��������ʱ����Ԫ�صĵ�ַ��Ԫ��Ϊrecord����ʱ, ������������ʱ����Ԫ��,
      Ȼ�����AddInternal��ӵ�����List }
    function ValuePointer: Pointer;

    property ElementType: TRttiType read tvElementType;  // Ԫ������
    property ElementTypeInfo: PTypeInfo read tvTypeInfo;        // Ԫ��TypeInfo
    property ElementTypeSize: Integer read tvTypeSize;          // SizeOf(Ԫ������)
  end;

function GetClassTrait(_TypeInfo: PTypeInfo): TCustomClassTrait;
function FindRttiAttribute(const _Attrs: TArray<TCustomAttribute>; _AttrClass: TRTTIAttributeClass): TCustomAttribute;

implementation

uses
  SyncObjs;

function FindRttiAttribute(const _Attrs: TArray<TCustomAttribute>; _AttrClass: TRTTIAttributeClass): TCustomAttribute;
var
  LAttr: TCustomAttribute;
begin
  Result := nil;
  for LAttr in _Attrs do
    if LAttr.InheritsFrom(_AttrClass) then
      Exit(LAttr);
end;

var
  G_ClassTraitCacheLock: TSynchroObject;
  G_ClassTraitCache: TDictionary<PTypeInfo, TCustomClassTrait>;

function GetClassTrait(_TypeInfo: PTypeInfo): TCustomClassTrait;
var
  tmp: TCustomClassTrait;
begin
  G_ClassTraitCacheLock.Acquire;
  G_ClassTraitCache.TryGetValue(_TypeInfo, Result);
  G_ClassTraitCacheLock.Release;
  if Result <> nil then
    Exit;
  Result := TCustomClassTrait.CreateTrait(_TypeInfo);
  G_ClassTraitCacheLock.Acquire;
  if G_ClassTraitCache.TryGetValue(_TypeInfo, tmp) then
  begin
    Result.Free;
    Result := tmp;
  end;
    G_ClassTraitCache.Add(_TypeInfo, Result);
  G_ClassTraitCacheLock.Release;
end;

type
  T3Bytes = array [0 .. 2] of Byte;
  T5Bytes = array [0 .. 4] of Byte;
  T6Bytes = array [0 .. 5] of Byte;
  T7Bytes = array [0 .. 6] of Byte;

  TListAddProc1 = function(const x: Byte): Integer of object;
  TListAddProc2 = function(const x: Word): Integer of object;
  TListAddProc3 = function(const x: T3Bytes): Integer of object;
  TListAddProc4 = function(const x: Integer): Integer of object;
  TListAddProc5 = function(const x: T5Bytes): Integer of object;
  TListAddProc6 = function(const x: T6Bytes): Integer of object;
  TListAddProc7 = function(const x: T7Bytes): Integer of object;
  TListAddProc8 = function(const x: Int64): Integer of object;
  TListAddProc4f = function(const x: Single): Integer of object;
  TListAddProc8f = function(const x: Double): Integer of object;
  TListAddProc10f = function(const x: Extended): Integer of object;
  TListAddProc8Pointer = function(const x: Pointer): Integer of object;
  TListAddProcLarge = function(x: Pointer): Integer of object;

function getGenericListElementType(var avContext: TRttiContext;
  avListClass: TClass): TRttiType;
var
  lvType: TRttiType;
  tvMethodAdd: TRttiMethod;
begin
  Result := nil;
  lvType := avContext.GetType(avListClass);
  tvMethodAdd := lvType.GetMethod('GetItem');
  if Assigned(tvMethodAdd) then
    Result := tvMethodAdd.ReturnType;
end;

function getGenericListElementType(avListClass: TClass): PTypeInfo;
var
  lvContext: TRttiContext;
  lvType: TRttiType;
  tvMethodAdd: TRttiMethod;
begin
  Result := nil;
  lvType := lvContext.GetType(avListClass);
  tvMethodAdd := lvType.GetMethod('GetItem');
  if Assigned(tvMethodAdd) then
    Result := tvMethodAdd.ReturnType.Handle;
end;

function GetParamlessConstructor(t: TRttiInstanceType): TParamlessConstructor;
var
  LHasOtherConstructor: Boolean;
  LMethod: TRttiMethod;
begin
  Result := nil;
  while Assigned(t) do
  begin
    LHasOtherConstructor := False;
    for LMethod in t.GetDeclaredMethods do
    begin
      if LMethod.IsConstructor then
      begin
        LHasOtherConstructor := True;
        if LMethod.GetParameters = nil then
          Exit(@TParamlessConstructor(LMethod.CodeAddress));
      end;
    end;
    if LHasOtherConstructor then Exit;
    t := t.BaseType;
  end;
end;

function GetObjectListConstructor(t: TRttiInstanceType): TObjectListConstructor;
var
  LHasOtherConstructor: Boolean;
  LMethod: TRttiMethod;
  LParams: TArray<TRttiParameter>;
begin
  Result := nil;
  while Assigned(t) do
  begin
    LHasOtherConstructor := False;
    for LMethod in t.GetDeclaredMethods do
    begin
      if LMethod.IsConstructor then
      begin
        LHasOtherConstructor := True;
        LParams := LMethod.GetParameters;
        if (Length(LParams) = 1) and (LParams[0].ParamType.Handle = TypeInfo(Boolean)) then
          Exit(@TObjectListConstructor(LMethod.CodeAddress));
      end;
    end;
    if LHasOtherConstructor then Exit;
    t := t.BaseType;
  end;
end;

{ TdslGenericList }

function TdslGenericList.Add(avList: TObject; const avNewItem): Integer;
var
  lvValue, lvResult: TValue;
begin
  tvMethodAdd.Data := avList;
  case tvTypeInfo.Kind of
    tkInteger: Result := TListAddProc4(tvMethodAdd)(Integer(avNewItem));
    tkChar: Result := TListAddProc1(tvMethodAdd)(Byte(avNewItem));
    tkWChar: Result := TListAddProc2(tvMethodAdd)(Word(avNewItem));
    tkEnumeration, tkSet:
      case tvElementType.TypeSize of
        1: Result := TListAddProc1(tvMethodAdd)(Byte(avNewItem));
        2: Result := TListAddProc2(tvMethodAdd)(Word(avNewItem));
        else Result := TListAddProc4(tvMethodAdd)(Integer(avNewItem));
      end;

    tkFloat:
      case tvElementType.TypeSize of
        4: Result := TListAddProc4f(tvMethodAdd)(Single(avNewItem));
        8: Result := TListAddProc8f(tvMethodAdd)(Double(avNewItem));
        else Result := TListAddProc10f(tvMethodAdd)(Extended(avNewItem));
      end;

    tkLString, tkWString, tkUString, tkClass, tkClassRef, tkInterface, tkPointer:
      Result := TListAddProc8Pointer(tvMethodAdd)(Pointer(avNewItem));
    tkInt64:
      Result := TListAddProc8(tvMethodAdd)(Int64(avNewItem));
    else if tvTypeSize > 8 then
      Result := TListAddProcLarge(tvMethodAdd)(@avNewItem)
    else begin
      TValue.Make(@avNewItem, tvTypeInfo, lvValue);
      lvResult := tvRttiMethodAdd.Invoke(avList, [lvValue]);
      Result := lvResult.AsInteger;
    end;
  end;
end;

function TdslGenericList.AddInternal(avList: TObject): Integer;
var
  lvResult: TValue;
begin
  tvMethodAdd.Data := avList;
  lvResult := tvRttiMethodAdd.Invoke(avList, [tvValue]);
  Result := lvResult.AsInteger;
end;

procedure TdslGenericList.CheckListConstructor(avMethod: TRttiMethod);
var
  lvParams: TArray<TRttiParameter>;
begin
  lvParams := avMethod.GetParameters;
  if (Length(lvParams) = 0) or ((Length(lvParams)=1) and (lvParams[0].ParamType.Handle = TypeInfo(Boolean))) then
    tvListConstructor := avMethod.CodeAddress;
end;

procedure TdslGenericList.CheckMethodAdd(avMethod: TRttiMethod);
var
  lvReturnType: TRttiType;
  lvParams: TArray<TRttiParameter>;
begin
  lvReturnType := avMethod.ReturnType;
  if Assigned(lvReturnType) and (lvReturnType.TypeKind in [tkInteger, tkInt64]) then
  begin
    lvParams := avMethod.GetParameters;
    if (Length(lvParams)=1) and (pfConst in lvParams[0].Flags) then
    begin
      tvRttiMethodAdd := avMethod;
      tvMethodAdd.Code := avMethod.CodeAddress;
    end;
  end;
end;

procedure TdslGenericList.CheckMethodGetItem(avMethod: TRttiMethod);
var
  lvReturnType: TRttiType;
  lvParams: TArray<TRttiParameter>;
begin
  lvReturnType := avMethod.ReturnType;
  if Assigned(lvReturnType) then
  begin
    lvParams := avMethod.GetParameters;
    if (Length(lvParams)=1) and (lvParams[0].ParamType.TypeKind in [tkInteger, tkInt64]) then
    begin
      tvElementType := lvReturnType;
      tvTypeInfo := tvElementType.Handle;
      tvTypeSize := tvElementType.TypeSize;
    end;
  end;
end;

constructor TdslGenericList.Create(var avContext: TRttiContext; avListClass: TClass);
var
  lvBuffer: array [0..2] of Double;
  lvRec: Pointer;
  lvListClassName: string;
begin
  tvElementType := nil;
  tvRttiMethodAdd := nil;
  tvListConstructor := nil;
  tvListType := avContext.GetType(avListClass);
  lvListClassName := avListClass.ClassName;
  tvIsObjectList := Pos('TObjectList<',  lvListClassName) = 1;

  findListMethod;

  if not Assigned(tvElementType) or not Assigned(tvRttiMethodAdd) then Exit;
  lvBuffer[0] := 0;
  lvBuffer[1] := 0;
  lvBuffer[2] := 0;
  if tvTypeSize <= SizeOf(lvBuffer) then
    lvRec := @lvBuffer
  else
    lvRec := GetMemory(tvTypeSize);
  if IsManaged(tvTypeInfo) then
  begin
    System.InitializeArray(lvRec, tvTypeInfo, 1);
    TValue.Make(lvRec, tvTypeInfo, tvValue);
    System.FinalizeArray(lvRec, tvTypeInfo, 1);
  end
  else begin
    TValue.Make(lvRec, tvTypeInfo, tvValue);
  end;
  if lvRec <> @lvBuffer then
    FreeMemory(lvRec);

  if tvElementType.TypeKind = tkClass then
    findConstructors;
end;

procedure TdslGenericList.findConstructors;
var
  lvMethods: TArray<TRttiMethod>;
  lvMethod: TRttiMethod;
  lvCurrent: TRttiInstanceType;
begin
  tvConstructors.Add(nil); // default constructor
  lvCurrent := TRttiInstanceType(tvElementType);
  while Assigned(lvCurrent) do
  begin
    lvMethods := lvCurrent.GetDeclaredMethods;

    for lvMethod in lvMethods do
    begin
      if lvMethod.IsConstructor then
      begin
        if Length(lvMethod.GetParameters) = 0 then
          tvConstructors.items[0] := lvMethod
        else
          tvConstructors.Add(lvMethod);
      end;
    end;

    if Assigned(tvConstructors.items[0]) or (tvConstructors.Count > 1) then Break;
    lvCurrent := lvCurrent.BaseType;
  end;
end;

procedure TdslGenericList.findListMethod;
var
  lvMethods: TArray<TRttiMethod>;
  lvMethod: TRttiMethod;
  lvName: string;
  lvCurrent: TRttiInstanceType;
begin
  lvCurrent := TRttiInstanceType(tvListType);

  while Assigned(lvCurrent) do
  begin
    lvMethods := lvCurrent.GetDeclaredMethods;
    for lvMethod in lvMethods do
    begin
      if Assigned(tvElementType) and Assigned(tvRttiMethodAdd)
        and Assigned(tvListConstructor) then Exit;

      if lvMethod.MethodKind = mkFunction then
      begin
        lvName := lvMethod.Name;
        if not Assigned(tvElementType) and SameText('GetItem', lvName) then
          CheckMethodGetItem(lvMethod);

        if not Assigned(tvRttiMethodAdd) and SameText('Add', lvName) then
          CheckMethodAdd(lvMethod);
      end
      else if (lvMethod.MethodKind = mkConstructor) then
      begin
        if not Assigned(tvListConstructor) then
          CheckListConstructor(lvMethod);
      end;
    end;
    lvCurrent := lvCurrent.BaseType;
  end;
end;

function TdslGenericList.NewList: TObject;
var
  lvMetaClass: TClass;
begin
  if Assigned(tvListConstructor) then
  begin
    lvMetaClass := TRttiInstanceType(tvListType).MetaclassType;
    if tvIsObjectList then
      Result := TObjectListConstructor(tvListConstructor)(lvMetaClass, 1, True)
    else
      Result := TParamlessConstructor(tvListConstructor)(lvMetaClass, 1);
  end
  else
    Result := nil;
end;

function TdslGenericList.NewObject: TObject;
var
  lvMetaClass: TClass;
begin
  if (tvConstructors.Count > 0) and Assigned(tvConstructors[0]) then
  begin
    lvMetaClass := TRttiInstanceType(tvElementType).MetaclassType;
    Result := TParamlessConstructor(tvConstructors[0].CodeAddress)(lvMetaClass, 1);
  end
  else
    Result := nil;
end;

function TdslGenericList.ValuePointer: Pointer;
begin
  Result := tvValue.GetReferenceToRawData;
end;

{ TCustomClassTrait }

constructor TCustomClassTrait.Create(_TypeInfo: PTypeInfo);
var
  LRttiCtx: TRttiContext;
  LType: TRttiStructuredType;
begin
  inherited Create;
  FTypeInfo := _TypeInfo;
  LType := LRttiCtx.GetType(_TypeInfo) as TRttiStructuredType;
  if _TypeInfo.Kind = tkClass then
  begin
    FMetaClass := _TypeInfo.TypeData.ClassType;
    FParamlessCtor := GetParamlessConstructor(LType as TRttiInstanceType);
  end;
  Init(LType);
end;

function TCustomClassTrait.CreateObject: TObject;
begin
  if Assigned(FParamlessCtor) then
    Result := FParamlessCtor(FMetaClass, 1)
  else
    Result := nil;
end;

class function TCustomClassTrait.CreateTrait(_TypeInfo: PTypeInfo): TCustomClassTrait;
var
  LClassName: string;
begin
  LClassName := string(_TypeInfo.Name);
  if LClassName.StartsWith('TList<') or LClassName.StartsWith('TObjectList<') then
    Result := TGenericListTrait.Create(_TypeInfo)
  else
    Result := TDataClassTrait.Create(_TypeInfo);
end;

procedure TCustomClassTrait.Init(t: TRttiStructuredType);
begin

end;

{ TDataClassTrait }

procedure TDataClassTrait.Init(t: TRttiStructuredType);
var
  LFields: TArray<TRttiField>;
  i, n: Integer;
begin
  inherited;
  LFields := t.GetFields;
  n := 0;
  SetLength(FFields, Length(LFields));
  for i := Low(LFields) to High(LFields) do
  begin
    if LFields[i].Visibility = mvPublic then
    begin
      FFields[n].Name := LFields[i].Name;
      FFields[n].Offset := LFields[i].Offset;
      FFields[n]._Type := LFields[i].FieldType.Handle;
      Inc(n);
    end;
  end;
  SetLength(FFields, n);
end;

{ TGenericListTrait }

function TGenericListTrait.CreateObject: TObject;
begin
  if Assigned(FObjectListCtor) then
    Result := FObjectListCtor(MetaClass, 1, True)
  else
    Result := inherited CreateObject;
end;

procedure TGenericListTrait.FindMethods(t: TRttiType);
var
  LMethod: TRttiMethod;
  LKind: TMethodKind;
  LHasCtor: Boolean;
  LParams: TArray<TRttiParameter>;
  LRetType: TRttiType;
  LMethodName: string;
begin
  while Assigned(t) do
  begin
    LHasCtor := False;
    for LMethod in t.GetDeclaredMethods do
    begin
      LKind := LMethod.MethodKind;
      if LKind = mkFunction then
      begin
        LMethodName := LMethod.Name;
        if 'Add' = LMethodName then
        begin
          if FElementType = nil then
          begin
            LRetType := LMethod.ReturnType;
            if (LRetType <> nil) and (LRetType.TypeKind in [tkInteger, tkInt64]) then
            begin
              LParams := LMethod.GetParameters;
              if (Length(LParams) = 1) and (pfConst in LParams[0].Flags) then
              begin
                FElementType := LParams[0].ParamType.Handle;
                FElementTypeData := GetTypeData(FElementType);
                FMethodAdd := LMethod.CodeAddress;
              end;
            end;
          end;
        end
      end
      else if (LKind = mkConstructor) and FIsObjectList then
      begin
        LHasCtor := True;
        LParams := LMethod.GetParameters;
        if (Length(LParams) = 1) and (LParams[0].ParamType.Handle = TypeInfo(Boolean)) then
          FObjectListCtor := @TObjectListConstructor(LMethod.CodeAddress);
      end;
    end;
    if FIsObjectList and LHasCtor and not Assigned(FObjectListCtor) then
      raise Exception.CreateFmt('constructor of %s not found', [t.Name]);
    t := t.BaseType;
  end;
end;

procedure TGenericListTrait.FindProperties(_t: TRttiStructuredType);
var
  LProperty: TRttiProperty;
  LPropInfo: PPropInfo;
  t: TRttiInstanceType;
begin
  t := _t as TRttiInstanceType;
  while Assigned(t) and not (Assigned(FMethodSetCount) and Assigned(FMethodGetList)) do
  begin
    for LProperty in t.GetDeclaredProperties do
    begin
      if (LProperty.Name = 'Count') then
      begin
        if LProperty.PropertyType.Handle = TypeInfo(Integer) then
        begin
          LPropInfo := TRttiInstanceProperty(LProperty).PropInfo;
          @FMethodSetCount := LPropInfo.SetProc;
          FCountOffset := NativeInt(LPropInfo.GetProc) and not PROPSLOT_MASK;
        end;
      end
      else if (LProperty.Name = 'List') then
      begin
        if LProperty.PropertyType.Handle.Kind = tkDynArray then
        begin
          LPropInfo := TRttiInstanceProperty(LProperty).PropInfo;
          @FMethodGetList := LPropInfo.GetProc;
        end;
      end;
    end;
    t := t.BaseType;
  end;
end;

function TGenericListTrait.GetCount(_List: TObject): Integer;
begin
  Result := PInteger(PAnsiChar(_List) + FCountOffset)^;
end;

function TGenericListTrait.GetInternalArray(_List: TObject): TArray<Byte>;
begin
  Result := FMethodGetList(_List);
end;

procedure TGenericListTrait.Init(t: TRttiStructuredType);
begin
  inherited;
  FIsObjectList := t.Name.StartsWith('TObjectList<', True);
  FindMethods(t);
  FindProperties(t);
end;

procedure TGenericListTrait.SetCount(_List: TObject; _Count: Integer);
begin
  FMethodSetCount(_List, _Count);
end;

{ TIntegerTypeTrait }

function TIntegerTypeTrait.ReadAsStr(const _Addr): string;
begin

end;

procedure TIntegerTypeTrait.WriteAsStr(const _S: string; var _Addr);
begin

end;

initialization
  G_ClassTraitCacheLock := TCriticalSection.Create;
  G_ClassTraitCache := TDictionary<PTypeInfo, TCustomClassTrait>.Create;

finalization
  G_ClassTraitCache.Free;
  G_ClassTraitCacheLock.Free;

end.
