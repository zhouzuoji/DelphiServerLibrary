unit DSLTypeTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, Rtti, TypInfo, Generics.Collections, DSLUtils, DSLByteStr;

type
  TTypeKindEx = (
    tkxUnknown,
    tkxVariant,
    tkxRecord,
    tkxClass,
    tkxArray,
    tkxDynArray,
    tkxBool,
    tkxByteBool,
    tkxWordBool,
    tkxLongBool,
    tkxAnsiChar,
    tkxWideChar,
    tkxSet,
    tkxInt8,
    tkxUint8,
    tkxInt16,
    tkxUint16,
    tkxInt32,
    tkxUint32,
    tkxInt64,
    tkxUint64,
    tkxSingle,
    tkxDouble,
    tkxExtended,
    tkxComp,
    tkxCurr,
    tkxShortStr,
    tkxByteStr,
    tkxWideStr,
    tkxUtf16Str,
    tkxInterface,
    tkxMethod,
    tkxClassRef,
    tkxPointer,
    tkxProcedure,
    tkxMRecord
  );

  PRttiContext = ^TRttiContext;

  TTypeDataEx = record
    Handle: PTypeInfo;
    TypeData: PTypeData;
    Kind: TTypeKindEx;
    Name: string;
  end;

{
构造函数第二个参数flag为标记,
  flag=0时, 第1个参数为已分配的对象地址,
  flag=1时, 第1个参数为ClassType
其它参数就是构造函数原型声明的参数
}
  TDefaultConstructor = function(_vmt: TClass; _Flag: Shortint): TObject;
  TObjectListConstructor = function(_vmt: TClass; _Flag: Shortint; _OwnsObjects: Boolean): TObject;
  TListSetCountProc = procedure(_Self: TObject; Value: NativeInt);
  TListGetListProc = function(_Self: TObject): TArray<Byte>;

  TCtorWithCapacity = function(_vmt: TClass; _Flag: Shortint; _Capacity: NativeInt): TObject;
  TObjectDictCtor = function(_vmt: TClass; _Flag: Shortint; _Ownerships: TDictionaryOwnerships; _Capacity: NativeInt): TObject;

  TCustomTypeTrait = class;

  ITypeTraitFactory = interface
    ['{2EB16FAC-E59A-412A-A85B-F932CDE5C6E9}']
    procedure Lock;
    procedure Unlock;
  end;

  TCustomTypeTrait = class
  private type TTypeTraitMap = TObjectDictionary<PTypeInfo, TCustomTypeTrait>;
  private class var FBuiltinTypeTraits: TTypeTraitMap;
  private
    FTypeData: TTypeDataEx;
    FSize: NativeInt;
    FMaxLen: NativeInt;
    constructor Create(const _TypeData: TTypeDataEx; _RttiCtx: PRttiContext);
    class procedure AddBuiltintType<T>(_RttiCtx: PRttiContext); static;
  protected
    procedure Init(_RttiCtx: PRttiContext); virtual;
    procedure Check; virtual;
    procedure FromNull(var _Addr); virtual;
    procedure FromBool(_N: Boolean; var _Addr); virtual;

    procedure FromInt32(_N: Integer; var _Addr); virtual;
    procedure FromUint32(_N: Cardinal; var _Addr); virtual;
    procedure FromInt64(_N: Int64; var _Addr); virtual;
    procedure FromUint64(_N: Uint64; var _Addr); virtual;

    procedure FromSingle(_N: Single; var _Addr); virtual;
    procedure FromDouble(_N: Double; var _Addr); virtual;
    procedure FromExtended(_N: Extended; var _Addr); virtual;
    procedure FromComp(_N: Comp; var _Addr); virtual;
    procedure FromCurrency(_N: Currency; var _Addr); virtual;

    procedure FromByteStr(const _S: TByteStrBuilder; var _Addr); virtual;
    procedure FromShortString(const _S: ShortString; var _Addr); virtual;
    procedure FromRawByteStr(const _S: RawByteString; var _Addr); virtual;
    procedure FromWideString(const _S: WideString; var _Addr); virtual;
    procedure FromUtf16Str(const _S: UnicodeString; var _Addr); virtual;
  public
    class constructor Create;
    class destructor Destroy;
    class function OfType<T>(_RttiCtx: PRttiContext = nil): TCustomTypeTrait; overload; static;
    class function OfType(ti: PTypeInfo; _RttiCtx: PRttiContext = nil): TCustomTypeTrait; overload; static;
    procedure AssignError(const _SourceTypeName: string);
    procedure Assign(const _N: TNumber; var _Addr); overload;
    procedure Assign(var _Addr); overload;

    procedure Assign(_N: Boolean; var _Addr); overload;
    procedure Assign(_N: ShortInt; var _Addr); overload;
    procedure Assign(_N: Byte; var _Addr); overload;
    procedure Assign(_N: SmallInt; var _Addr); overload;
    procedure Assign(_N: Word; var _Addr); overload;
    procedure Assign(_N: Integer; var _Addr); overload;
    procedure Assign(_N: Cardinal; var _Addr); overload;
    procedure Assign(_N: Int64; var _Addr); overload;
    procedure Assign(_N: Uint64; var _Addr); overload;

    procedure Assign(_N: Single; var _Addr); overload;
    procedure Assign(_N: Double; var _Addr); overload;
    procedure Assign(_N: Extended; var _Addr); overload;
    procedure Assign(_N: Comp; var _Addr); overload;
    procedure Assign(_N: Currency; var _Addr); overload;

    procedure Assign(const _S: TByteStrBuilder; var _Addr); overload;
    procedure Assign(const _S: ShortString; var _Addr); overload;
    procedure Assign(const _S: RawByteString; var _Addr); overload;
    procedure Assign(const _S: WideString; var _Addr); overload;
    procedure Assign(const _S: UnicodeString; var _Addr); overload;

    property Handle: PTypeInfo read FTypeData.Handle;
    property TypeData: PTypeData read FTypeData.TypeData;
    property Kind: TTypeKindEx read FTypeData.Kind;
    property Name: string read FTypeData.Name;
    property Size: NativeInt read FSize;
    property MaxLen: NativeInt read FMaxLen;
  end;

  TCustomListTrait = class(TCustomTypeTrait)
  private
    FElem: TCustomTypeTrait;
    FElemSize: NativeInt;
  protected
    procedure Check; override;
    procedure SetElem(_Elem: TCustomTypeTrait);
  public
    function GetLen(const _Addr): Integer; virtual; abstract;
    procedure SetLen(var _Addr; _Len: Integer); virtual; abstract;
    function GetElemPtr(const _Addr; _Idx: Integer): Pointer; virtual; abstract;
    property Elem: TCustomTypeTrait read FElem;
    property ElemSize: NativeInt read FElemSize;
  end;

  TCustomDictTrait = class(TCustomTypeTrait)
  private
    FKey: TCustomTypeTrait;
    FValue: TCustomTypeTrait;
    FKeySize: Integer;
    FValueSize: Integer;
  protected
    procedure Check; override;
    procedure SetKeyValue(_Key, _Value: TCustomTypeTrait);
  public
    function GetLen(const _Dict): Integer; virtual; abstract;
    procedure Add(var _Dict; const _Key; const _Value); virtual; abstract;
    procedure Remove(var _Dict; const _Key); virtual; abstract;
    procedure Clear(var _Dict); virtual; abstract;
    function TryGetValue(const _Dict, _Key; var _Value): Boolean; virtual; abstract;
    procedure AddOrSetValue(var _Dict; const _Key, _Value); virtual; abstract;
    function TryAdd(var _Dict;  const _Key, _Value): Boolean; virtual; abstract;
    function ContainsKey(const _Dict, _Key): Boolean; virtual; abstract;
    function ContainsValue(const _Value): Boolean; virtual; abstract;
    property Key: TCustomTypeTrait read FKey;
    property Value: TCustomTypeTrait read FValue;
    property KeySize: Integer read FKeySize;
    property ValueSize: Integer read FValueSize;
  end;

  TInterfaceTrait = class(TCustomTypeTrait)

  end;

  TTypeTraitClass = class of TCustomTypeTrait;

function TranslateTypeKind(_ti: PTypeInfo): TTypeKindEx;

implementation

uses
  RTLConsts, SyncObjs, DSLBoolTrait, DSLNumberTrait, DSLCharTrait, DSLSetTrait, DSLStringTrait, DSLVariantTrait,
  DSLRecordTrait, DSLClassTrait, DSLGenericListTrait, DSLArrayTrait, DSLDynArrayTrait;

resourcestring
  SAssignIntegerError = 'Cannot assign a %d to a %s';
  SAssignFloatError = 'Cannot assign a %f to a %s';

const TypeClasses: array [TTypeKindEx] of TTypeTraitClass = (
  nil,                // tkxUnknown,
  TVariantTrait,      // tkxVariant,
  TRecordTrait,       // tkxRecord,
  TClassTrait,        // tkxClass,
  TArrayTrait,        // tkxArray,
  TDynArrayTrait,     // tkxDynArray,
  TBoolTrait,         // tkxBool,
  TByteBoolTrait,     // tkxByteBool,
  TWordBoolTrait,     // tkxWordBool,
  TLongBoolTrait,     // tkxLongBool,
  TAnsiCharTrait,     // tkxChar,
  TWideCharTrait,     // tkxWChar,
  TSetTrait,          // tkxSet,
  TInt8Trait,         // tkxInt8,
  TUint8Trait,        // tkxUint8,
  TInt16Trait,        // tkxInt16,
  TUint16Trait,       // tkxUint16,
  TInt32Trait,        // tkxInt32,
  TUint32Trait,       // tkxUint32,
  TInt64Trait,        // tkxInt64,
  TUint64Trait,       // tkxUint64,
  TSingleTrait,       // tkxSingle,
  TDoubleTrait,       // tkxDouble,
  TExtendedTrait,     // tkxExtended,
  TCompTrait,         // tkxComp,
  TCurrencyTrait,     // tkxCurr,
  TShortStrTrait,     // tkxShortStr,
  TByteStrTrait,      // tkxByteStr,
  TWideStrTrait,      // tkxWideStr,
  TUtf16StrTrait,     // tkxUtf16Str,
  TInterfaceTrait,    // tkxInterface,
  nil,                // tkxMethod
  nil,                // tkxClassRef
  nil,                // tkxPointer
  nil,                // tkxProcedure
  nil                 // tkxMRecord
);

var
  G_ClassTraitCacheLock: TSynchroObject;
  G_ClassTraitCtorLock: TSynchroObject;
  G_ClassTraitCache: TCustomTypeTrait.TTypeTraitMap;

function TranslateTypeKind(_ti: PTypeInfo): TTypeKindEx;
const
  OrdTypeKinds: array [TOrdType] of TTypeKindEx = (tkxInt8, tkxUint8, tkxInt16, tkxUint16, tkxInt32, tkxUint32);
  FloatTypeKinds: array [TFloatType] of TTypeKindEx = (tkxSingle, tkxDouble, tkxExtended, tkxComp, tkxCurr);
var
  td: PTypeData;
begin
  td := GetTypeData(_ti);
  case _ti.Kind of
    tkInteger, tkEnumeration:
      begin
        if _ti = TypeInfo(Boolean) then
          Result := tkxBool
        else if _ti = TypeInfo(ByteBool) then
          Result := tkxByteBool
        else if _ti = TypeInfo(WordBool) then
          Result := tkxWordBool
        else if _ti = TypeInfo(LongBool) then
          Result := tkxLongBool
        else
          Result := OrdTypeKinds[td.OrdType];
      end;
    tkChar: Result := tkxAnsiChar;
    tkFloat: Result := FloatTypeKinds[td.FloatType];
    tkString: Result := tkxShortStr;
    tkSet: Result := tkxSet;
    tkClass: Result := tkxClass;
    tkMethod: Result := tkxMethod;
    tkWChar: Result := tkxWideChar;
    tkLString: Result := tkxByteStr;
    tkWString: Result := tkxWideStr;
    tkVariant: Result := tkxVariant;
    tkArray: Result := tkxArray;
    tkRecord: Result := tkxRecord;
    tkInterface: Result := tkxInterface;
    tkInt64:
      if td.MinInt64Value <= td.MaxInt64Value then
        Result := tkxInt64
      else
        Result := tkxUint64;
    tkDynArray: Result := tkxDynArray;
    tkUString: Result := tkxUtf16Str;
    tkClassRef: Result := tkxClassRef;
    tkPointer: Result := tkxPointer;
    tkProcedure: Result := tkxProcedure;
    tkMRecord: Result := tkxRecord;
    else Result := tkxUnknown;
  end;
end;

function CreateTypeTrait(ti: PTypeInfo; _RttiCtx: PRttiContext): TCustomTypeTrait;
var
  LTypeData: TTypeDataEx;
  LClass: TTypeTraitClass;
begin
  Result := nil;
  LTypeData.Handle := ti;
  LTypeData.TypeData := GetTypeData(ti);
  LTypeData.Kind := TranslateTypeKind(ti);
  LTypeData.Name := string(ti.Name);
  LClass := TypeClasses[LTypeData.Kind];
  case LTypeData.Kind of
    tkxUnknown: ;
    tkxVariant: ;
    tkxRecord: ;
    tkxClass:
      if (LTypeData.Name.StartsWith('TList<') or LTypeData.Name.StartsWith('TObjectList<')) then
        LClass := TGenericListTrait;
    tkxArray: ;
    tkxDynArray: ;
    tkxBool: ;
    tkxByteBool: ;
    tkxWordBool: ;
    tkxLongBool: ;
    tkxAnsiChar: ;
    tkxWideChar: ;
    tkxSet: ;
    tkxInt8: ;
    tkxUint8: ;
    tkxInt16: ;
    tkxUint16: ;
    tkxInt32: ;
    tkxUint32: ;
    tkxInt64: ;
    tkxUint64: ;
    tkxSingle: ;
    tkxDouble: ;
    tkxExtended: ;
    tkxComp: ;
    tkxCurr: ;
    tkxShortStr: ;
    tkxByteStr: ;
    tkxWideStr: ;
    tkxUtf16Str: ;
    tkxInterface: ;
    tkxMethod: ;
    tkxClassRef: ;
    tkxPointer: ;
    tkxProcedure: ;
    tkxMRecord: ;
  end;

  if LClass <> nil then
    Result := LClass.Create(LTypeData, _RttiCtx)
  else begin
    G_ClassTraitCacheLock.Acquire;
    G_ClassTraitCache.Add(ti, nil);
    G_ClassTraitCacheLock.Release;
  end;
end;

type
  TFromNumber = procedure(const _N: TNumber; var _Addr) of object;
  TFromInt8 = procedure(_N: ShortInt; var _Addr) of object;
  TFromUint8 = procedure(_N: Byte; var _Addr) of object;
  TFromInt16 = procedure(_N: SmallInt; var _Addr) of object;
  TFromUint16 = procedure(_N: Word; var _Addr) of object;
  TFromInt32 = procedure(_N: Integer; var _Addr) of object;
  TFromUint32 = procedure(_N: Cardinal; var _Addr) of object;
  TFromInt64 = procedure(_N: Int64; var _Addr) of object;
  TFromUint64 = procedure(_N: Uint64; var _Addr) of object;

  TFromSingle = procedure(_N: Single; var _Addr) of object;
  TFromDouble = procedure(_N: Double; var _Addr) of object;
  TFromExtended = procedure(_N: Extended; var _Addr) of object;
  TFromComp = procedure(_N: Comp; var _Addr) of object;
  TFromCurrency = procedure(_N: Currency; var _Addr) of object;

  TFromByteStr = procedure(const _S: TByteStrBuilder; var _Addr) of object;
  TFromShortString = procedure(const _S: ShortString; var _Addr) of object;
  TFromRawByteStr = procedure(const _S: RawByteString; var _Addr) of object;
  TFromWideString = procedure(const _S: WideString; var _Addr) of object;
  TFromUtf16Str = procedure(const _S: UnicodeString; var _Addr) of object;

{ TCustomTypeTrait }

constructor TCustomTypeTrait.Create(const _TypeData: TTypeDataEx; _RttiCtx: PRttiContext);
begin
  inherited Create;
  FTypeData := _TypeData;
  FSize := SizeOf(Pointer);
  FMaxLen := $7FFFFFFF;
  case FTypeData.Kind of
    tkxVariant: FSize := SizeOf(Variant);
    tkxRecord: FSize := _TypeData.TypeData.RecSize;
    tkxArray:
      begin
        FSize := _TypeData.TypeData.ArrayData.Size;
        FMaxLen := _TypeData.TypeData.ArrayData.ElCount;
      end;
    tkxBool: FSize := 1;
    tkxByteBool: FSize := 1;
    tkxWordBool: FSize := 2;
    tkxLongBool: FSize := 4;
    tkxInt8: FSize := 1;
    tkxUint8: FSize := 1;
    tkxInt16: FSize := 2;
    tkxUint16: FSize := 2;
    tkxInt32: FSize := 4;
    tkxUint32: FSize := 4;
    tkxInt64: FSize := 8;
    tkxUint64: FSize := 8;
    tkxSingle: FSize := SizeOf(Single);
    tkxDouble: FSize := SizeOf(Double);
    tkxExtended: FSize := SizeOf(Extended);
    tkxComp: FSize := SizeOf(Comp);
    tkxCurr: FSize := SizeOf(Currency);
    tkxAnsiChar: FSize := SizeOf(AnsiChar);
    tkxWideChar: FSize := SizeOf(WideChar);
    tkxSet: FSize := SizeOfSet(FTypeData.Handle);
    tkxShortStr:
      begin
        FMaxLen := _TypeData.TypeData.MaxLength;
        FSize := _TypeData.TypeData.MaxLength + 1;
      end;
    tkxWideStr: FSize := SizeOf(WideString);
    tkxMethod: FSize := 2 * SizeOf(Pointer);
  end;
  G_ClassTraitCacheLock.Acquire;
  G_ClassTraitCache.Add(Handle, Self);
  G_ClassTraitCacheLock.Release;
  Self.Init(_RttiCtx);
  Self.Check;
end;

class procedure TCustomTypeTrait.AddBuiltintType<T>(_RttiCtx: PRttiContext);
var
  LType: PTypeInfo;
begin
  LType := TypeInfo(T);
  FBuiltinTypeTraits.Add(LType, TCustomTypeTrait.OfType(LType, _RttiCtx));
  LType := TypeInfo(TArray<T>);
  FBuiltinTypeTraits.Add(LType, TCustomTypeTrait.OfType(LType, _RttiCtx));
  LType := TypeInfo(TList<T>);
  FBuiltinTypeTraits.Add(LType, TCustomTypeTrait.OfType(LType, _RttiCtx));
end;

procedure TCustomTypeTrait.Assign(var _Addr);
begin
  Self.FromNull(_Addr);
end;

procedure TCustomTypeTrait.Check;
begin

end;

class constructor TCustomTypeTrait.Create;
var
  LCtx: TRttiContext;
begin
  G_ClassTraitCacheLock := TCriticalSection.Create;
  G_ClassTraitCtorLock := TSynchroObject.Create;
  G_ClassTraitCache := TTypeTraitMap.Create([doOwnsValues], 1023);
  FBuiltinTypeTraits := TTypeTraitMap.Create([], 63);

  AddBuiltintType<Boolean>(@LCtx);
  AddBuiltintType<ByteBool>(@LCtx);
  AddBuiltintType<WordBool>(@LCtx);
  AddBuiltintType<LongBool>(@LCtx);
  AddBuiltintType<AnsiChar>(@LCtx);
  AddBuiltintType<WideChar>(@LCtx);
  AddBuiltintType<ShortString>(@LCtx);
  AddBuiltintType<RawByteString>(@LCtx);
  AddBuiltintType<UTF8String>(@LCtx);
  AddBuiltintType<AnsiString>(@LCtx);
  AddBuiltintType<WideString>(@LCtx);
  AddBuiltintType<UnicodeString>(@LCtx);

  AddBuiltintType<ShortInt>(@LCtx);
  AddBuiltintType<Byte>(@LCtx);
  AddBuiltintType<SmallInt>(@LCtx);
  AddBuiltintType<Word>(@LCtx);
  AddBuiltintType<Integer>(@LCtx);
  AddBuiltintType<Cardinal>(@LCtx);
  AddBuiltintType<Int64>(@LCtx);
  AddBuiltintType<Uint64>(@LCtx);

  AddBuiltintType<Single>(@LCtx);
  AddBuiltintType<Double>(@LCtx);
  AddBuiltintType<Extended>(@LCtx);
  AddBuiltintType<Comp>(@LCtx);
  AddBuiltintType<Currency>(@LCtx);
end;

class destructor TCustomTypeTrait.Destroy;
begin
  G_ClassTraitCache.Free;
  G_ClassTraitCacheLock.Free;
  G_ClassTraitCtorLock.Free;
  FBuiltinTypeTraits.Free;
end;

procedure TCustomTypeTrait.Assign(const _N: TNumber; var _Addr);
begin
  case _N._type of
    numNaN: Self.FromNull(_Addr);
    numInt32: Self.Assign(_N.I32, _Addr);
    numUInt32: Self.Assign(_N.UI32, _Addr);
    numInt64: Self.Assign(_N.I64, _Addr);
    numUInt64: Self.Assign(_N.UI64, _Addr);
    numDouble: Self.Assign(_N.VDouble, _Addr);
    numExtended: Self.Assign(_N.VExtended, _Addr);
  end;
end;

procedure TCustomTypeTrait.Assign(const _S: TByteStrBuilder; var _Addr);
begin
  Self.FromByteStr(_S, _Addr);
end;

procedure TCustomTypeTrait.Init(_RttiCtx: PRttiContext);
begin

end;

class function TCustomTypeTrait.OfType(ti: PTypeInfo; _RttiCtx: PRttiContext): TCustomTypeTrait;
var
  LExists: Boolean;
begin
  if FBuiltinTypeTraits.TryGetValue(ti, Result) then Exit;

  G_ClassTraitCacheLock.Acquire;
  LExists := G_ClassTraitCache.TryGetValue(ti, Result);
  G_ClassTraitCacheLock.Release;
  if LExists then Exit;

  G_ClassTraitCtorLock.Acquire;
  try
    G_ClassTraitCacheLock.Acquire;
    LExists := G_ClassTraitCache.TryGetValue(ti, Result);
    G_ClassTraitCacheLock.Release;
    if LExists then Exit;
    Result := CreateTypeTrait(ti, _RttiCtx);
  finally
    G_ClassTraitCtorLock.Release;
  end;
end;

class function TCustomTypeTrait.OfType<T>(_RttiCtx: PRttiContext): TCustomTypeTrait;
begin
  Result := OfType(TypeInfo(T), _RttiCtx);
end;

procedure TCustomTypeTrait.FromNull(var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignError), ['null', Self.Name]);
end;

procedure TCustomTypeTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignError), [_S, Self.Name]);
end;

procedure TCustomTypeTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignError), [_S, Self.Name]);
end;

procedure TCustomTypeTrait.FromSingle(_N: Single; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignFloatError), [_N, Self.Name]);
end;

procedure TCustomTypeTrait.FromUint32(_N: Cardinal; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignIntegerError), [_N, Self.Name]);
end;

procedure TCustomTypeTrait.FromUint64(_N: Uint64; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignIntegerError), [_N, Self.Name]);
end;

procedure TCustomTypeTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignError), [_S, Self.Name]);
end;

procedure TCustomTypeTrait.FromWideString(const _S: WideString; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignError), [_S, Self.Name]);
end;

procedure TCustomTypeTrait.FromBool(_N: Boolean; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignError), [BoolToStr(_N, True), Self.Name]);
end;

procedure TCustomTypeTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignError), [_S.Once, Self.Name]);
end;

procedure TCustomTypeTrait.FromComp(_N: Comp; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignFloatError), [_N, Self.Name]);
end;

procedure TCustomTypeTrait.FromCurrency(_N: Currency; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignFloatError), [_N, Self.Name]);
end;

procedure TCustomTypeTrait.FromDouble(_N: Double; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignFloatError), [_N, Self.Name]);
end;

procedure TCustomTypeTrait.FromExtended(_N: Extended; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignFloatError), [_N, Self.Name]);
end;

procedure TCustomTypeTrait.FromInt32(_N: Integer; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignIntegerError), [_N, Self.Name]);
end;

procedure TCustomTypeTrait.FromInt64(_N: Int64; var _Addr);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignIntegerError), [_N, Self.Name]);
end;

procedure TCustomTypeTrait.Assign(_N: Uint64; var _Addr);
begin
  Self.FromUint64(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Int64; var _Addr);
begin
  Self.FromInt64(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Comp; var _Addr);
begin
  Self.FromComp(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Extended; var _Addr);
begin
  Self.FromExtended(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Double; var _Addr);
begin
  Self.FromDouble(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: SmallInt; var _Addr);
begin
  Self.FromInt32(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Byte; var _Addr);
begin
  Self.FromUint32(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: ShortInt; var _Addr);
begin
  Self.FromInt32(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Cardinal; var _Addr);
begin
  Self.FromUint32(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Integer; var _Addr);
begin
  Self.FromInt32(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Word; var _Addr);
begin
  Self.FromUint32(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(const _S: UnicodeString; var _Addr);
begin
  Self.FromUtf16Str(_S, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Single; var _Addr);
begin
  Self.FromSingle(_N, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Boolean; var _Addr);
begin
  Self.FromBool(_N, _Addr);
end;

procedure TCustomTypeTrait.AssignError(const _SourceTypeName: string);
begin
  raise EConvertError.CreateResFmt(PResStringRec(@SAssignError), [_SourceTypeName, Self.Name]);
end;

procedure TCustomTypeTrait.Assign(const _S: WideString; var _Addr);
begin
  Self.FromWideString(_S, _Addr);
end;

procedure TCustomTypeTrait.Assign(const _S: RawByteString; var _Addr);
begin
  Self.FromRawByteStr(_S, _Addr);
end;

procedure TCustomTypeTrait.Assign(const _S: ShortString; var _Addr);
begin
  Self.FromShortString(_S, _Addr);
end;

procedure TCustomTypeTrait.Assign(_N: Currency; var _Addr);
begin
  Self.FromCurrency(_N, _Addr);
end;

{ TCustomListTrait }

procedure TCustomListTrait.Check;
begin
  inherited;
  if FElem = nil then
    raise EListError.Create(Self.Name + ' 的数组元素没有类型信息！');
end;

procedure TCustomListTrait.SetElem(_Elem: TCustomTypeTrait);
begin
  if _Elem <> nil then
  begin
    FElem := _Elem;
    FElemSize := _Elem.Size;
  end;
end;

{ TCustomDictTrait }

procedure TCustomDictTrait.Check;
begin
  inherited;

end;

procedure TCustomDictTrait.SetKeyValue(_Key, _Value: TCustomTypeTrait);
begin

end;

end.
