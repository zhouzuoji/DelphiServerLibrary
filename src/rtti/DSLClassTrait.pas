unit DSLClassTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, TypInfo, DSLUtils, DSLTypeTrait;

type
  PClassField = ^TClassField;
  TClassField = record
    Name: string;
    Offset: Integer;
    TypeTrait: TCustomTypeTrait;
  end;

  // class
  TClassTrait = class(TCustomTypeTrait)
  private
    FDefaultCtor: TDefaultConstructor;
    FMetaClass: TClass;
    FFields: TArray<TClassField>;
  protected
    procedure Init(_RttiCtx: PRttiContext); override;
    procedure FromNull(var _Addr); override;
  public
    function CreateObject: TObject;
    function IndexOf(const _Name: string): Integer; overload;
    function IndexOf(const _Name: RawByteString): Integer; overload;
    function IndexOf(_Name: PAnsiChar; _NameLen: Integer): Integer; overload;
    property MetaClass: TClass read FMetaClass;
    property Fields: TArray<TClassField> read FFields;
  end;

implementation

uses
  Rtti;

function GetParamlessConstructor(t: TRttiInstanceType): TDefaultConstructor;
var
  LHasOtherConstructor: Boolean;
  LMethod: TRttiMethod;
  LCtor: Pointer absolute Result;
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
        begin
          LCtor := LMethod.CodeAddress;
          Exit;
        end;
      end;
    end;
    if LHasOtherConstructor then Exit;
    t := t.BaseType;
  end;
end;

{ TClassTrait }

function TClassTrait.CreateObject: TObject;
begin
  if Assigned(FDefaultCtor) then
    Result := FDefaultCtor(FMetaClass, 1)
  else
    Result := nil;
end;

procedure TClassTrait.Init(_RttiCtx: PRttiContext);
var
  LRttiCtx: TRttiContext;
  LType: TRttiType;
  LFields: TArray<TRttiField>;
  i, n: Integer;
begin
  inherited;

  if _RttiCtx = nil then
    _RttiCtx := @LRttiCtx;
  LType := _RttiCtx.GetType(Self.Handle);
  FMetaClass := Self.TypeData.ClassType;
  FDefaultCtor := Pointer(GetParamlessConstructor(LType as TRttiInstanceType));
  LFields := LType.GetFields;
  n := 0;
  for i := Low(LFields) to High(LFields) do
  begin
    if (LFields[i].Visibility = mvPublic) and (LFields[i].FieldType <> nil) then
      Inc(n);
  end;
  SetLength(FFields, n);
  n := 0;
  for i := Low(LFields) to High(LFields) do
  begin
    if (LFields[i].Visibility = mvPublic) and (LFields[i].FieldType <> nil) then
    begin
      FFields[n].Name := LFields[i].Name;
      //Writeln(FFields[n].Name);
      FFields[n].Offset := LFields[i].Offset;
      FFields[n].TypeTrait := TCustomTypeTrait.OfType(LFields[i].FieldType.Handle, _RttiCtx);
      Inc(n);
    end;
  end;
end;

function TClassTrait.IndexOf(const _Name: string): Integer;
var
  i: Integer;
begin
  for i := Low(FFields) to High(FFields) do
  begin
    if Fields[i].Name = _Name then
      Exit(i);
  end;
  Result := -1;
end;

function TClassTrait.IndexOf(const _Name: RawByteString): Integer;
begin
  Result := IndexOf(string(_Name));
end;

procedure TClassTrait.FromNull(var _Addr);
begin
  FreeAndNil(TObject(_Addr))
end;

function TClassTrait.IndexOf(_Name: PAnsiChar; _NameLen: Integer): Integer;
var
  LName: RawByteString;
begin
  SetString(LName, _Name, _NameLen);
  Result := IndexOf(string(LName));
end;

end.
