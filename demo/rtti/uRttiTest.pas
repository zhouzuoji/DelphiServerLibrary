unit uRttiTest;

interface

uses
  SysUtils, Classes, rtti, TypInfo, RttiUtils, Generics.Collections, Generics.Defaults;

type
  ORMTag = class(TCustomAttribute)
  public
    index: Integer;
    alias: string;
    constructor Create(avIndex: Integer; const avAlias: string);
  end;

  TGender = (gMale, gFemale);
  T7Int64 = array [1..6] of Int64;  // 静态数组需要定义别名才有rtti信息
  TRequest = record
    [ORMTag(111, 'age')] A: Integer;
    &Type: string;
    C: Double;
    D: array of Integer;
    E: TObject;
    F: TList<Integer>;
    G: Boolean;
    H: TGender;
    I: T7Int64;
    S: string;
    property SP: string read S write S;
  end;

procedure dumpCompositeType(ti: PTypeInfo);
procedure dumpTypeByName(const avTypeName: string);

procedure GenericIntegerListRttiTest;
procedure GenericFloat4ListRttiTest;
procedure GenericFloat8ListRttiTest;
procedure GenericFloatExListRttiTest;
procedure GenericStringListRttiTest;
procedure GenericRecordListRttiTest;
procedure GenericPOD8RecordListRttiTest;
procedure GenericObjectListRttiTest;

implementation

var
  lvCtx: TRttiContext;


function TypeName(avType: TRttiType): string;
var
  lvDynArrayType: TRttiDynamicArrayType absolute avType;
  lvArrayType: TRttiArrayType absolute avType;
begin
  Result := '';
  case avType.TypeKind of
    tkUnknown: ;
    tkInteger: ;
    tkChar: ;
    tkEnumeration: ;
    tkFloat: ;
    tkString: ;
    tkSet: ;
    tkClass: ;
    tkMethod: ;
    tkWChar: ;
    tkLString: ;
    tkWString: ;
    tkVariant: ;
    tkArray: Result := TypeName(lvArrayType.ElementType) + '[' + IntToStr(lvArrayType.TotalElementCount) + ']';
    tkRecord: ;
    tkInterface: ;
    tkInt64: ;
    tkDynArray: Result := 'array of ' + TypeName(lvDynArrayType.ElementType);
    tkUString: ;
    tkClassRef: ;
    tkPointer: ;
    tkProcedure: ;
  end;
  if Result = '' then
    Result := avType.Name;
end;

procedure _dumpCompositeType(lvType: TRttiType);
var
  t: TRttiType;
  lvProperties: TArray<TRttiProperty>;
  lvFields: TArray<TRttiField>;
  lvField: TRttiField;
  lvProperty: TRttiProperty;
  lvAttrs: TArray<TCustomAttribute>;
  lvAttr: TCustomAttribute;
begin
  if not Assigned(lvType) then Exit;

  Writeln('rtti data for ', lvType.Name, ':');
  lvProperties := lvType.GetProperties;
  if Length(lvProperties) > 0 then
  begin
    Writeln('  properties:');
    for lvProperty in lvProperties do
    begin
      t := lvProperty.PropertyType;
      Writeln('    ', lvProperty.Name, ': ', TypeName(t));
    end;
  end;

  lvFields := lvType.GetFields;
  if Length(lvFields) > 0 then
  begin
    Writeln('  fields:');
    for lvField in lvFields do
    begin
      lvAttrs := lvField.GetAttributes;
      for lvAttr in lvAttrs do
      begin
        Writeln(lvAttr.ClassName);
        if lvAttr is ORMTag then
        begin
          with ORMTag(lvAttr) do
            Writeln(Format('ORMTag(%d,%s)', [index, alias]));
        end;
      end;
      t := lvField.FieldType;
      if Assigned(t) then
        Writeln('    ', lvField.Name, ': ', TypeName(t), ', offset: ', lvField.Offset)
      else
        Writeln('    ', lvField.Name, ': ', '(no rtti data)')
    end;
  end;
end;

procedure dumpCompositeType(ti: PTypeInfo);
begin
  _dumpCompositeType(lvCtx.GetType(ti));
end;

procedure dumpTypeByName(const avTypeName: string);
begin
  _dumpCompositeType(lvCtx.FindType(avTypeName));
end;

{ TORMTag }

constructor ORMTag.Create(avIndex: Integer; const avAlias: string);
begin
  index := avIndex;
  alias := avAlias;
end;

procedure GenericStringListRttiTest;
var
  lvList: TList<string>;
  lvHelper: TGenericList;
  lvContext: TRttiContext;
  i: Integer;
  s: string;
begin
  lvList := TList<string>.Create;
  try
    lvHelper := TGenericList.Create(lvContext, lvList.ClassType);
    for i := 0 to 100 do
    begin
      s := IntToStr(i);
      lvHelper.Add(lvList, s);
    end;
    Writeln(lvList.Count);
    Writeln('lvList[7]: ', lvList[7]);
    Writeln('lvList[13]: ', lvList[13]);
    Writeln('lvList.Last: ', lvList.Last);
  finally
    lvList.Free;
  end;
end;

procedure GenericIntegerListRttiTest;
var
  lvIntegerList: TList<Integer>;
  lvHelper: TGenericList;
  lvContext: TRttiContext;
  i: Integer;
begin
  lvIntegerList := TList<Integer>.Create;
  try
    lvHelper := TGenericList.Create(lvContext, lvIntegerList.ClassType);
    for i := 0 to 100 do

      lvHelper.Add(lvIntegerList, i);
    Writeln(lvIntegerList.Count);
    Writeln('lvIntegerList[7]: ', lvIntegerList[7]);
    Writeln('lvIntegerList[13]: ', lvIntegerList[13]);
    Writeln('lvIntegerList.Last: ', lvIntegerList.Last);
  finally
    lvIntegerList.Free;
  end;
end;

procedure GenericFloat4ListRttiTest;
var
  lvList: TList<Single>;
  lvHelper: TGenericList;
  lvContext: TRttiContext;
  i: Integer;
  f4: Single;
begin
  lvList := TList<Single>.Create;
  try
    lvHelper := TGenericList.Create(lvContext, lvList.ClassType);
    for i := 0 to 100 do
    begin
      f4 := i;
      lvHelper.Add(lvList, f4);
    end;
    Writeln(lvList.Count);
    Writeln('lvFloat4List[7]: ', lvList[7]);
    Writeln('lvFloat4List[13]: ', lvList[13]);
    Writeln('lvFloat4List.Last: ', lvList.Last);
  finally
    lvList.Free;
  end;
end;

procedure GenericFloat8ListRttiTest;
var
  lvList: TList<Double>;
  lvHelper: TGenericList;
  lvContext: TRttiContext;
  i: Integer;
  f: Double;
begin
  lvList := TList<Double>.Create;
  try
    lvHelper := TGenericList.Create(lvContext, lvList.ClassType);
    for i := 0 to 100 do
    begin
      f := i;
      lvHelper.Add(lvList, f);
    end;
    Writeln(lvList.Count);
    Writeln('lvFloat8List[7]: ', lvList[7]);
    Writeln('lvFloat8List[13]: ', lvList[13]);
    Writeln('lvFloat8List.Last: ', lvList.Last);
  finally
    lvList.Free;
  end;
end;

procedure GenericFloatExListRttiTest;
var
  lvList: TList<Extended>;
  lvHelper: TGenericList;
  lvContext: TRttiContext;
  i: Integer;
  f: Extended;
begin
  lvList := TList<Extended>.Create;
  try
    lvHelper := TGenericList.Create(lvContext, lvList.ClassType);
    for i := 0 to 100 do
    begin
      f := i;
      lvHelper.Add(lvList, f);
    end;
    Writeln(lvList.Count);
    Writeln('lvFloatExList[7]: ', lvList[7]);
    Writeln('lvFloatExList[13]: ', lvList[13]);
    Writeln('lvFloatExList.Last: ', lvList.Last);
  finally
    lvList.Free;
  end;
end;

type
  TPerson = record
    id: Integer;
    name: string;
    function ToString: string;
  end;

  { TPerson }

function TPerson.ToString: string;
begin
  Result := Format('(%d, %s)', [id, name]);
end;

procedure GenericRecordListRttiTest;
var
  lvList: TList<TPerson>;
  lvHelper: TGenericList;
  lvContext: TRttiContext;
  i: Integer;
  rec: ^TPerson;
begin
  lvList := TList<TPerson>.Create;
  try
    lvHelper := TGenericList.Create(lvContext, lvList.ClassType);
    rec := lvHelper.ValuePointer;
    for i := 0 to 100 do
    begin
      rec.id := i;
      rec.name := 'person ' + IntToStr(i);
      // lvList.Add(rec);
      lvHelper.AddInternal(lvList);
    end;
    Writeln(lvList.Count);
    Writeln('lvList[7]: ', lvList[7].ToString);
    Writeln('lvList[13]: ', lvList[13].ToString);
    Writeln('lvList.Last: ', lvList.Last.ToString);
  finally
    lvList.Free;
  end;
end;

type
  TPOD8 = packed record
    id1: Byte;
    id2: Word;
    id3: Integer;
    id4: Byte;
    function ToString: string;
  end;

{ TPOD8 }

function TPOD8.ToString: string;
begin
  Result := Format('(%d, %d, %d, %d)', [id1, id2, id3, id4]);
end;

procedure AddPOD8(const v: TPOD8);
begin
  Writeln(v.ToString);
end;

procedure AddPOD8_2(v: TPOD8); cdecl;
begin
  Writeln(v.ToString);
end;

procedure GenericPOD8RecordListRttiTest;
var
  lvList: TList<TPOD8>;
  lvHelper: TGenericList;
  lvContext: TRttiContext;
  i: Integer;
  rec: TPOD8;
begin
  lvHelper := TGenericList.Create(lvContext, TList<TPOD8>);
  lvList := TList<TPOD8>(lvHelper.NewList);
  try
    for i := 1 to 100 do
    begin
      rec.id1 := i;
      rec.id2 := i;
      rec.id3 := i;
      rec.id4 := i;
      lvHelper.Add(lvList, rec);
    end;
    Writeln(lvList.Count);
    Writeln('lvList[8]: ', lvList[8].ToString);
    Writeln('lvList[15]: ', lvList[15].ToString);
    Writeln('lvList.Last: ', lvList.Last.ToString);
  finally
    lvList.Free;
  end;
end;

type
  TCustomCompany = class
  public
    constructor Create; virtual;
    procedure func1; virtual;
  end;

  TCompany = class(TCustomCompany)
  private
    tvName: string;
    tvTelephone: Int64;
  public
    constructor Create; overload; override;
    constructor Create(const avName: string); overload;
    constructor Create(const avName: string; avTelephone: Int64); overload;
    destructor Destroy; override;
    function ToString: string; override;
    procedure func1(a: Integer); overload;
    property Name: string read tvName write tvName;
    property Telephone: Int64 read tvTelephone write tvTelephone;
  end;

{ TCustomCompany }

constructor TCustomCompany.Create;
begin

end;

procedure TCustomCompany.func1;
begin

end;

{ TCompany }

constructor TCompany.Create(const avName: string);
begin
  inherited Create;
  tvName := avName;
end;

constructor TCompany.Create(const avName: string; avTelephone: Int64);
begin
  inherited Create;
  tvName := avName;
  tvTelephone := avTelephone;
end;

constructor TCompany.Create;
begin
  //inherited Create;
end;

destructor TCompany.Destroy;
begin
  Writeln('TCompany(', tvName, ') destroyed');
  inherited;
end;

procedure TCompany.func1(a: Integer);
begin

end;

function TCompany.ToString: string;
begin
  Result := Format('TCompany(%s, %d)', [tvName, tvTelephone]);
end;

procedure GenericObjectListRttiTest;
var
  lvList: TObjectList<TCompany>;
  lvHelper: TGenericList;
  lvContext: TRttiContext;
  i: Integer;
  rec: TCompany;
begin
  lvHelper := TGenericList.Create(lvContext, TObjectList<TCompany>);
  lvList := TObjectList<TCompany>(lvHelper.NewList);
  try
    for i := 1 to 100 do
    begin
      rec := TCompany(lvHelper.NewObject);
      rec.Telephone := i;
      rec.Name := 'company' + IntToStr(i);
      lvHelper.Add(lvList, rec);
    end;
    Writeln(lvList.Count);
    Writeln('lvList[8]: ', lvList[8].ToString);
    Writeln('lvList[15]: ', lvList[15].ToString);
    Writeln('lvList.Last: ', lvList.Last.ToString);
    lvList[0].func1;
  finally
    lvList.Free;
  end;
end;

end.
