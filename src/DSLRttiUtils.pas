unit DSLRttiUtils;

interface

uses
  SysUtils, Classes, rtti, TypInfo, Generics.Collections, Generics.Defaults,
  DSLArray;

// get element type of generic TList<T> or TObjectList<T>
function getGenericListElementType(var avContext: TRttiContext;
  avListClass: TClass): TRttiType; overload;
function getGenericListElementType(avListClass: TClass): PTypeInfo; overload;

type
  TdslGenericList = record
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

    { 创建泛型List对象 }
    function NewList: TObject;

    { }
    function Add(avList: TObject; const avNewItem): Integer; overload;

    { 仅用于添加record类型元素, record数据存储于tvValue中 }
    function AddInternal(avList: TObject): Integer; overload;

    { 创建一个class类型的对象, 当元素类型不是class或没有默认构造函数(无参数的构造函数)时, 返回nil }
    function NewObject: TObject;

    { tvValue包含的临时数据元素的地址。元素为record类型时, 建议填充这个临时数据元素,
      然后调用AddInternal添加到泛型List }
    function ValuePointer: Pointer;

    property ElementType: TRttiType read tvElementType;  // 元素类型
    property ElementTypeInfo: PTypeInfo read tvTypeInfo;        // 元素TypeInfo
    property ElementTypeSize: Integer read tvTypeSize;          // SizeOf(元素类型)
  end;

implementation

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

{
构造函数第二个参数flag为标记,
  flag=0时, 第1个参数为已分配的对象地址,
  flag=0时, 第1个参数为ClassType
其它参数就是构造函数原型声明的参数
}
type
  TDefaultConstructor = function(vmt: TClass; flag: Shortint): TObject;
  TObjectListDefaultConstructor = function(vmt: TClass; flag: Shortint; AOwnsObjects: Boolean): TObject;

function TdslGenericList.NewList: TObject;
var
  lvMetaClass: TClass;
begin
  if Assigned(tvListConstructor) then
  begin
    lvMetaClass := TRttiInstanceType(tvListType).MetaclassType;
    if tvIsObjectList then
      Result := TObjectListDefaultConstructor(tvListConstructor)(lvMetaClass, 1, True)
    else
      Result := TDefaultConstructor(tvListConstructor)(lvMetaClass, 1);
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
    Result := TDefaultConstructor(tvConstructors[0].CodeAddress)(lvMetaClass, 1);
  end
  else
    Result := nil;
end;

function TdslGenericList.ValuePointer: Pointer;
begin
  Result := tvValue.GetReferenceToRawData;
end;

end.
