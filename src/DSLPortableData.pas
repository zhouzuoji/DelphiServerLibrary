unit DSLPortableData;
{$B-,C+,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,U-,V+,W-,X+,Z1}
{$O+}   // optimization on
{$T+}   // typed pointers on
{$POINTERMATH ON}
{$IFDEF VER200}
// Delphi 2009's ErrorInsight parser uses the CompilerVersion's memory address instead of 20.0, failing all the
// IF CompilerVersion compiler directives
{$DEFINE CPUX86}
{$ELSE}
{$IF CompilerVersion >= 24.0} // XE3 or newer
{$LEGACYIFEND ON}
{$IFEND}
{$IF CompilerVersion >= 23.0}
{$DEFINE HAS_UNIT_SCOPE}
{$DEFINE HAS_RETURN_ADDRESS}
{$IFEND}
{$IF CompilerVersion <= 22.0} // XE or older
{$DEFINE CPUX86}
{$IFEND}
{$ENDIF VER200}
// Enables the progress callback feature
{$DEFINE SUPPORT_PROGRESS}
// Sanity checks all array index accesses and raise an EListError exception.
{$DEFINE CHECK_ARRAY_INDEX}
// {$IF CompilerVersion < 28.0} // XE6 or older
// The XE7 compiler is broken. It doesn't collapse duplicate string literals anymore. (RSP-10015)
// But if the string literals are used in loops this optimization still helps.

// Optimizes the following pattern:
// O['Name'][MyPropStr]
// O['Name']['MyProp'].
// where the second O['Name'] is handled very fast by caching the pointer to the 'Name' string literal.
{$DEFINE USE_LAST_NAME_STRING_LITERAL_CACHE}
// {$IFEND}
{$IFDEF MSWINDOWS}
// If defined, the TzSpecificLocalTimeToSystemTime is imported with GetProcAddress and if it is
// not available (Windows 2000) an alternative implementation is used.
{$DEFINE SUPPORT_WINDOWS2000}
{$ENDIF MSWINDOWS}

interface

uses
  SysUtils, Classes, Variants, RTLConsts, TypInfo, Math, SysConst, Windows, DateUtils,
  DSLUtils;

type
  EJsonPathException = class(Exception)
  end;

  TPortableDataType = (
    sdtNone,          // unknown data, functions/procedures should return this type if it fails
    sdtUndefined,     // javascript undefined
    sdtNull,          // javascript null
    sdtNaN,           // javascript NaN
    sdtInfinity,      // javascript Infinity
    sdtBool, sdtInt32, sdtInt64, sdtUInt64,
    sdtFloat, sdtDateTime, sdtUTF8String, sdtUTF16String,
    sdtArray, sdtObject, sdtObjectUtf8);

const
  DataTypeNames: array [TPortableDataType] of string = ('empty', 'undefined', 'null', 'NaN', 'Infinity',
    'Bool', 'Int32', 'Int64', 'UInt64', 'Float', 'DateTime', 'UTF8String', 'UTF16String',
    'Array', 'Object', 'ObjectUtf8');

function VarTypeToPortableDataType(AVarType: TVarType): TPortableDataType;

type
  PPointerLargeArray = ^TPointerLargeArray;
  TPointerLargeArray = array [0 .. MaxInt div SizeOf(Pointer) - 1] of Pointer;
  TPortableObject = class;
  TPortableArray = class;
  TPortableObjectUtf8 = class;

  PPortableValue = ^TPortableValue;

  TPortableValue = record
  private
    function GetString: string;
    function GetInt32: Int32;
    function GetInt64: Int64;
    function GetUInt64: UInt64;
    function GetFloatValue: Double;
    function GetDateTimeValue: TDateTime;
    function GetBoolValue: Boolean;
    function GetArrayValue: TPortableArray;
    function GetObjectValue: TPortableObject;
    function GetVariantValue: Variant;
    function GetUtf8: UTF8String;
    function GetObjectUtf8: TPortableObjectUtf8;
    procedure SetString(const AValue: string);
    procedure SetInt32(AValue: Int32);
    procedure SetInt64Value(AValue: Int64);
    procedure SetUInt64Value(AValue: UInt64);
    procedure SetFloatValue(AValue: Double);
    procedure SetDateTimeValue(AValue: TDateTime);
    procedure SetBoolValue(AValue: Boolean);
    procedure SetArrayValue(AValue: TPortableArray);
    procedure SetObjectValue(AValue: TPortableObject);
    procedure SetVariantValue(const AValue: Variant);
    procedure SetUtf8(const Value: UTF8String);
    procedure SetObjectUtf8(Value: TPortableObjectUtf8);
    function UTF8ToInt32: Int32;
    function UTF8ToInt64: Int64;
    function UTF8ToUInt64: UInt64;
    function UTF8ToFloat: Double;
    function UTF8ToDateTime: TDateTime;
    function UTF8ToBool: Boolean;
    function UnicodeToInt32: Int32;
    function UnicodeToInt64: Int64;
    function UnicodeToUInt64: UInt64;
    function UnicodeToFloat: Double;
    function UnicodeToDateTime: TDateTime;
    function UnicodeToBool: Boolean;
    function UTF8ToUStr: UTF16String;
    function GetTypeName: string; inline;
  public
    function expr: string;
    function CreateObjectIfEmpty: TPortableObject;
    function CreateObjectUtf8IfEmpty: TPortableObjectUtf8;
    function CreateArrayIfEmpty: TPortableArray;
    procedure cleanup(toType: TPortableDataType = sdtNone); inline;
    procedure init(AType: TPortableDataType = sdtNone); overload; inline;
    procedure init(const AValue: string); overload; inline;
    procedure init(const AValue: UTF8String); overload; inline;
    procedure init(AValue: Int32); overload; inline;
    procedure init(AValue: Int64); overload; inline;
    procedure init(AValue: UInt64); overload; inline;
    procedure init(AValue: Double); overload; inline;
    procedure init(AValue: Extended); overload; inline;
    procedure init(AValue: TDateTime); overload; inline;
    procedure init(AValue: Boolean); overload; inline;
    procedure init(AValue: TPortableArray); overload; inline;
    procedure init(AValue: TPortableObject); overload; inline;
    procedure init(AValue: TPortableObjectUtf8); overload; inline;
    property TypeName: string read GetTypeName;
    procedure Assign(number: TNumber);
    property AsUtf8: UTF8String read GetUtf8 write SetUtf8;
    property AsString: string read GetString write SetString;
    property AsInt32: Int32 read GetInt32 write SetInt32;
    property AsInt64: Int64 read GetInt64 write SetInt64Value;
    property AsUInt64: UInt64 read GetUInt64 write SetUInt64Value;
    property AsFloat: Double read GetFloatValue write SetFloatValue;
    property AsDateTime: TDateTime read GetDateTimeValue write SetDateTimeValue;
    property AsBool: Boolean read GetBoolValue write SetBoolValue;
    property AsArray: TPortableArray read GetArrayValue write SetArrayValue;
    property AsObject: TPortableObject read GetObjectValue write SetObjectValue;
    property AsObjectUtf8: TPortableObjectUtf8 read GetObjectUtf8 write SetObjectUtf8;
    property AsVariant: Variant read GetVariantValue write SetVariantValue;
  public
    case dataType: TPortableDataType of
      sdtNone:
        (P: PChar); // helps when debugging
      sdtUTF16String:
        (S: Pointer); // We manage the string ourself. Delphi doesn't allow "string" in a
      // variant record and if we have no string, we don't need to clean
      // it up, anyway.
      sdtInt32:
        (I: Int32);
      sdtInt64:
        (L: Int64);
      sdtUInt64:
        (U: UInt64);
      sdtFloat:
        (F: Double);
      sdtDateTime:
        (D: TDateTime);
      sdtBool:
        (B: Boolean);
      sdtArray, sdtObject, sdtObjectUtf8:
        (O: Pointer); // owned by TPortableValue
  end;

  PPortableValueArray = ^TPortableValueArray;
  TPortableValueArray = array [0 .. MaxInt div SizeOf(TPortableValue) - 1] of TPortableValue;

  TPortableArrayEnumerator = class(TObject)
  private
    FIndex: Integer;
    FArray: TPortableArray;
  public
    constructor Create(AArray: TPortableArray);

    function GetCurrent: PPortableValue; inline;
    function MoveNext: Boolean;
    property Current: PPortableValue read GetCurrent;
  end;

  TPortableArray = class
  private
    FItems: PPortableValueArray;
    FCapacity: Integer;
    FCount: Integer;
    function GetString(Index: Integer): string;
    function GetInt32(Index: Integer): Int32;
    function GetInt64(Index: Integer): Int64;
    function GetUInt64(Index: Integer): UInt64;
    function GetFloat(Index: Integer): Double;
    function GetDateTime(Index: Integer): TDateTime;
    function GetBool(Index: Integer): Boolean;
    function GetArray(Index: Integer): TPortableArray;
    function GetObject(Index: Integer): TPortableObject;
    function GetObjectUtf8(Index: Integer): TPortableObjectUtf8;
    function GetVariant(Index: Integer): Variant;
    function GetUTF8(Index: Integer): UTF8String;

    procedure SetString(Index: Integer; const Value: string);
    procedure SetUTF8(Index: Integer; const Value: UTF8String);
    procedure SetInt32(Index: Integer; Value: Int32);
    procedure SetInt64(Index: Integer; Value: Int64);
    procedure SetUInt64(Index: Integer; Value: UInt64);
    procedure SetFloat(Index: Integer; Value: Double);
    procedure SetDateTime(Index: Integer; Value: TDateTime);
    procedure SetBool(Index: Integer; Value: Boolean);
    procedure SetArray(Index: Integer; Value: TPortableArray);
    procedure SetObject(Index: Integer; Value: TPortableObject);
    procedure SetObjectUtf8(Index: Integer; Value: TPortableObjectUtf8);
    procedure SetVariant(Index: Integer; const Value: Variant);

    function GetItem(Index: Integer): PPortableValue; inline;
    function GetType(Index: Integer): TPortableDataType; inline;

    function _AddItem: PPortableValue;
    function InsertItem(Index: Integer): PPortableValue;

    procedure Grow;
    procedure SetCapacity(const Value: Integer);
    procedure SetCount(const Value: Integer);
  protected
    class procedure RaiseListError(Index: Integer); static;
  public
    destructor Destroy; override;

    procedure Clear;
    procedure Delete(Index: Integer);
    // Extract removes the object/array from the array and transfers the ownership to the caller.
    function Extract(Index: Integer): TObject;
    function ExtractArray(Index: Integer): TPortableArray;
    function ExtractObject(Index: Integer): TPortableObject;
    procedure Assign(ASource: TPortableArray);
    function AddItem: PPortableValue; overload; inline;
    procedure Add(dataType: TPortableDataType); overload; inline;
    procedure Add(const AValue: string); overload; inline;
    procedure Add(const AValue: UTF8String); overload; inline;
    procedure Add(AValue: Int32); overload; inline;
    procedure Add(AValue: Int64); overload; inline;
    procedure Add(AValue: UInt64); overload; inline;
    procedure Add(AValue: Double); overload; inline;
    procedure Add(AValue: TDateTime); overload; inline;
    procedure Add(AValue: Boolean); overload; inline;
    procedure Add(AValue: TPortableArray); overload; inline;
    procedure Add(AValue: TPortableObject); overload; inline;
    procedure Add(const AValue: Variant); overload; inline;
    function AddArray: TPortableArray; inline;
    function AddObject: TPortableObject; inline;

    procedure Insert(Index: Integer; const AValue: string); overload; inline;
    procedure Insert(Index: Integer; const AValue: UTF8String); overload; inline;
    procedure Insert(Index: Integer; AValue: Int32); overload; inline;
    procedure Insert(Index: Integer; AValue: Int64); overload; inline;
    procedure Insert(Index: Integer; AValue: UInt64); overload; inline;
    procedure Insert(Index: Integer; AValue: Double); overload; inline;
    procedure Insert(Index: Integer; AValue: TDateTime); overload; inline;
    procedure Insert(Index: Integer; AValue: Boolean); overload; inline;
    procedure Insert(Index: Integer; AValue: TPortableArray); overload; inline;
    procedure Insert(Index: Integer; AValue: TPortableObject); overload; inline;
    procedure Insert(Index: Integer; const AValue: Variant); overload; inline;
    function InsertArray(Index: Integer): TPortableArray; inline;
    function InsertObject(Index: Integer): TPortableObject; overload; inline;
    procedure InsertObject(Index: Integer; const Value: TPortableObject); overload; inline;

    function GetEnumerator: TPortableArrayEnumerator;

    // Short names
    property UTF8[Index: Integer]: UTF8String read GetUTF8 write SetUTF8;
    property S[Index: Integer]: string read GetString write SetString;
    property I[Index: Integer]: Int32 read GetInt32 write SetInt32;
    property L[Index: Integer]: Int64 read GetInt64 write SetInt64;
    property U[Index: Integer]: UInt64 read GetUInt64 write SetUInt64;
    property F[Index: Integer]: Double read GetFloat write SetFloat;
    property D[Index: Integer]: TDateTime read GetDateTime write SetDateTime;
    property B[Index: Integer]: Boolean read GetBool write SetBool;
    property A[Index: Integer]: TPortableArray read GetArray write SetArray;
    property O[Index: Integer]: TPortableObject read GetObject write SetObject;
    property OUtf8[Index: Integer]: TPortableObjectUtf8 read GetObjectUtf8 write SetObjectUtf8;
    property V[Index: Integer]: Variant read GetVariant write SetVariant;
    property Types[Index: Integer]: TPortableDataType read GetType;
    property Items[Index: Integer]: PPortableValue read GetItem; default;
    property Count: Integer read FCount write SetCount;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  TPortableObjectProperty = record
    Name: string;
    Value: PPortableValue;
  end;

  TPortableObjectEnumerator = class(TObject)
  protected
    FIndex: Integer;
    FObject: TPortableObject;
  public
    constructor Create(AObject: TPortableObject);

    function GetCurrent: TPortableObjectProperty; inline;
    function MoveNext: Boolean;
    property Current: TPortableObjectProperty read GetCurrent;
  end;

  TPortableObject = class
  private
    FItems: PPortableValueArray;
    FNames: PPointerLargeArray; // PUStrLargeArray or PUtf8StrLargeArray
    FCapacity: Integer;
    FCount: Integer;
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
    FLastValueItem: Integer;
    FLastValueItemNamePtr: Pointer;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}
    procedure UpdateLastValueItem(Name: Pointer; ItemIndex: Integer);
    function _FastAddItem(var Name: string): PPortableValue;
    function _AddItem(const Name: string): PPortableValue;
    function AddItemP(NameBegin, NameEnd: PWideChar): PPortableValue;
    function GetString(const Name: string): string;
    function GetBool(const Name: string): Boolean;
    function GetInt32(const Name: string): Int32;
    function GetInt64(const Name: string): Int64;
    function GetUInt64(const Name: string): UInt64;
    function GetFloat(const Name: string): Double;
    function GetDateTime(const Name: string): TDateTime;
    function GetObject(const Name: string): TPortableObject;
    function GetArray(const Name: string): TPortableArray;
    procedure SetString(const Name, Value: string);
    procedure SetBool(const Name: string; Value: Boolean);
    procedure SetInt32(const Name: string; Value: Int32);
    procedure SetInt64(const Name: string; Value: Int64);
    procedure SetUInt64(const Name: string; Value: UInt64);
    procedure SetFloat(const Name: string; Value: Double);
    procedure SetDateTime(const Name: string; Value: TDateTime);
    procedure SetObject(const Name: string; Value: TPortableObject);
    procedure SetArray(const Name: string; Value: TPortableArray);

    function GetType(const Name: string): TPortableDataType;
    function GetName(Index: Integer): UTF16String; inline;
    function GetItem(Index: Integer): PPortableValue; inline;

    procedure Grow;
    procedure SetCapacity(const Value: Integer);
    function GetPath(const NamePath: string): PPortableValue;
    function IndexOfPChar(S: PWideChar; Len: Integer): Integer;
    procedure PathError(P, EndP: PWideChar);
    procedure PathIndexError(P, EndP: PWideChar; Count: Integer);
    function Extract(const Name: string): TObject;
  protected
    procedure PathNullError(P, EndP: PWideChar);
  public
    destructor Destroy; override;
    procedure Assign(ASource: TPortableObject);

    procedure ToSimpleObject(AObject: TObject; ACaseSensitive: Boolean = True);
    procedure FromSimpleObject(AObject: TObject; ALowerCamelCase: Boolean = False);
    function FindItem(const Name: string): PPortableValue;
    function FastAddItem(var Name: string): PPortableValue; inline;
    function AddArray(const Name: string): TPortableArray;
    function AddObject(const Name: string): TPortableObject;
    procedure AddNull(const name: string); inline;
    procedure Add(const name, Value: string); overload;
    procedure Add(const name: string; Value: Int32); overload;
    procedure Add(const name: string; Value: Int64); overload;
    procedure Add(const name: string; Value: UInt64); overload;
    procedure Add(const name: string; Value: TDateTime); overload;
    procedure Add(const name: string; Value: Double); overload;
    procedure Add(const name: string; Value: Boolean); overload;
    procedure Add(const name: string; Value: TPortableArray); overload;
    procedure Add(const name: string; Value: TPortableObject); overload;

    function FastAddArray(var Name: string): TPortableArray;
    function FastAddObject(var Name: string): TPortableObject;
    procedure FastAddNull(var name: string); inline;
    procedure FastAdd(var name, Value: string); overload;
    procedure FastAdd(var name: string; Value: Int32); overload;
    procedure FastAdd(var name: string; Value: Int64); overload;
    procedure FastAdd(var name: string; Value: UInt64); overload;
    procedure FastAdd(var name: string; Value: TDateTime); overload;
    procedure FastAdd(var name: string; Value: Double); overload;
    procedure FastAdd(var name: string; Value: Boolean); overload;
    procedure FastAdd(var name: string; Value: TPortableArray); overload;
    procedure FastAdd(var name: string; Value: TPortableObject); overload;

    procedure Clear;
    procedure Remove(const Name: string);
    procedure Delete(Index: Integer);

    function IndexOf(const Name: UTF16String): Integer; inline;
    function Contains(const Name: UTF16String): Boolean;
    // Extract removes the object/array from the object and transfers the ownership to the caller.
    function ExtractArray(const Name: string): TPortableArray;
    function ExtractObject(const Name: string): TPortableObject;

    function tryGetString(const Name: string; var Value: string): Boolean;
    function tryGetBool(const Name: string; var Value: Boolean): Boolean;
    function tryGetInt32(const Name: string; var Value: Int32): Boolean;
    function tryGetInt64(const Name: string; var Value: Int64): Boolean;
    function tryGetUInt64(const Name: string; var Value: UInt64): Boolean;
    function tryGetFloat(const Name: string; var Value: Double): Boolean;
    function tryGetDateTime(const Name: string; var Value: TDateTime): Boolean;
    function tryGetObject(const Name: string): TPortableObject;
    function tryGetArray(const Name: string): TPortableArray;

    function getStringDef(const Name: string; const defaultValue: string = ''): string;
    function getBoolDef(const Name: string; defaultValue: Boolean = False): Boolean;
    function getInt32Def(const Name: string; defaultValue: Int32 = 0): Int32;
    function getInt64Def(const Name: string; defaultValue: Int64 = 0): Int64;
    function getUInt64Def(const Name: string; defaultValue: UInt64 = 0): UInt64;
    function getFloatDef(const Name: string; defaultValue: Double = 0.0): Double;
    function getDateTimeDef(const Name: string; defaultValue: TDateTime = 0.0): TDateTime;

    function GetEnumerator: TPortableObjectEnumerator;

    property Types[const Name: string]: TPortableDataType read GetType;

    // Short names
    property S[const Name: string]: string read GetString write SetString; // returns '' if property doesn't exist, auto type-cast except for array/object
    property I[const Name: string]: Int32 read GetInt32 write SetInt32; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property L[const Name: string]: Int64 read GetInt64 write SetInt64; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property U[const Name: string]: UInt64 read GetUInt64 write SetUInt64; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property F[const Name: string]: Double read GetFloat write SetFloat; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property D[const Name: string]: TDateTime read GetDateTime write SetDateTime; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property B[const Name: string]: Boolean read GetBool write SetBool; // returns false if property doesn't exist, auto type-cast with "<>'true'" and "<>0" except for array/object
    property A[const Name: string]: TPortableArray read GetArray write SetArray; // auto creates array on first access
    property O[const Name: string]: TPortableObject read GetObject write SetObject;
    // auto creates object on first access

    property Path[const NamePath: string]: PPortableValue read GetPath; default;

    // Indexed access to the named properties
    property Names[Index: Integer]: string read GetName;
    property Items[Index: Integer]: PPortableValue read GetItem;
    property Count: Integer read FCount;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  TPortableObjectUtf8Property = record
    Name: UTF8String;
    Value: PPortableValue;
  end;

  TPortableObjectUtf8Enumerator = class(TObject)
  protected
    FIndex: Integer;
    FObject: TPortableObjectUtf8;
  public
    constructor Create(AObject: TPortableObjectUtf8);

    function GetCurrent: TPortableObjectUtf8Property; inline;
    function MoveNext: Boolean;
    property Current: TPortableObjectUtf8Property read GetCurrent;
  end;

  TPortableObjectUtf8 = class
  private
    FItems: PPortableValueArray;
    FNames: PPointerLargeArray; // PUStrLargeArray or PUtf8StrLargeArray
    FCapacity: Integer;
    FCount: Integer;
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
    FLastValueItem: Integer;
    FLastValueItemNamePtr: Pointer;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}
    procedure UpdateLastValueItem(Name: Pointer; ItemIndex: Integer);
    function _FastAddItem(var Name: UTF8String): PPortableValue;
    function _AddItem(const Name: UTF8String): PPortableValue;
    function AddItemP(NameBegin, NameEnd: PAnsiChar): PPortableValue;
    function GetString(const Name: UTF8String): UTF8String;
    function GetBool(const Name: UTF8String): Boolean;
    function GetInt32(const Name: UTF8String): Int32;
    function GetInt64(const Name: UTF8String): Int64;
    function GetUInt64(const Name: UTF8String): UInt64;
    function GetFloat(const Name: UTF8String): Double;
    function GetDateTime(const Name: UTF8String): TDateTime;
    function GetObject(const Name: UTF8String): TPortableObjectUtf8;
    function GetArray(const Name: UTF8String): TPortableArray;
    procedure SetString(const Name, Value: UTF8String);
    procedure SetBool(const Name: UTF8String; Value: Boolean);
    procedure SetInt32(const Name: UTF8String; Value: Int32);
    procedure SetInt64(const Name: UTF8String; Value: Int64);
    procedure SetUInt64(const Name: UTF8String; Value: UInt64);
    procedure SetFloat(const Name: UTF8String; Value: Double);
    procedure SetDateTime(const Name: UTF8String; Value: TDateTime);
    procedure SetObject(const Name: UTF8String; Value: TPortableObjectUtf8);
    procedure SetArray(const Name: UTF8String; Value: TPortableArray);

    function GetType(const Name: UTF8String): TPortableDataType;
    function GetName(Index: Integer): UTF8String; inline;
    function GetItem(Index: Integer): PPortableValue; inline;

    procedure Grow;
    procedure SetCapacity(const Value: Integer);
    function GetPath(const NamePath: UTF8String): PPortableValue;
    function IndexOfPChar(S: PAnsiChar; Len: Integer): Integer;
    procedure PathError(P, EndP: PAnsiChar); overload;
    procedure PathIndexError(P, EndP: PAnsiChar; Count: Integer);
    function Extract(const Name: UTF8String): TObject;
  protected
    procedure PathNullError(P, EndP: PAnsiChar);
  public
    destructor Destroy; override;
    procedure Assign(ASource: TPortableObjectUtf8);

    procedure ToSimpleObject(AObject: TObject; ACaseSensitive: Boolean = True);
    procedure FromSimpleObject(AObject: TObject; ALowerCamelCase: Boolean = False);
    function FindItem(const Name: UTF8String): PPortableValue;
    function FastAddItem(var Name: UTF8String): PPortableValue; inline;
    function AddArray(const Name: UTF8String): TPortableArray;
    function AddObject(const Name: UTF8String): TPortableObjectUtf8;
    procedure AddNull(const name: UTF8String); inline;
    procedure Add(const name, Value: UTF8String); overload;
    procedure Add(const name: UTF8String; Value: Int32); overload;
    procedure Add(const name: UTF8String; Value: Int64); overload;
    procedure Add(const name: UTF8String; Value: UInt64); overload;
    procedure Add(const name: UTF8String; Value: TDateTime); overload;
    procedure Add(const name: UTF8String; Value: Double); overload;
    procedure Add(const name: UTF8String; Value: Boolean); overload;
    procedure Add(const name: UTF8String; Value: TPortableArray); overload;
    procedure Add(const name: UTF8String; Value: TPortableObjectUtf8); overload;

    function FastAddArray(var Name: UTF8String): TPortableArray;
    function FastAddObject(var Name: UTF8String): TPortableObjectUtf8;
    procedure FastAddNull(var name: UTF8String); inline;
    procedure FastAdd(var name, Value: UTF8String); overload;
    procedure FastAdd(var name: UTF8String; Value: Int32); overload;
    procedure FastAdd(var name: UTF8String; Value: Int64); overload;
    procedure FastAdd(var name: UTF8String; Value: UInt64); overload;
    procedure FastAdd(var name: UTF8String; Value: TDateTime); overload;
    procedure FastAdd(var name: UTF8String; Value: Double); overload;
    procedure FastAdd(var name: UTF8String; Value: Boolean); overload;
    procedure FastAdd(var name: UTF8String; Value: TPortableArray); overload;
    procedure FastAdd(var name: UTF8String; Value: TPortableObjectUtf8); overload;

    procedure Clear;
    procedure Remove(const Name: UTF8String);
    procedure Delete(Index: Integer);

    function IndexOf(const Name: UTF8String): Integer; inline;
    function Contains(const Name: UTF8String): Boolean;
    // Extract removes the object/array from the object and transfers the ownership to the caller.
    function ExtractArray(const Name: UTF8String): TPortableArray;
    function ExtractObject(const Name: UTF8String): TPortableObjectUtf8;

    function tryGetString(const Name: UTF8String; var Value: UTF8String): Boolean;
    function tryGetBool(const Name: UTF8String; var Value: Boolean): Boolean;
    function tryGetInt32(const Name: UTF8String; var Value: Int32): Boolean;
    function tryGetInt64(const Name: UTF8String; var Value: Int64): Boolean;
    function tryGetUInt64(const Name: UTF8String; var Value: UInt64): Boolean;
    function tryGetFloat(const Name: UTF8String; var Value: Double): Boolean;
    function tryGetDateTime(const Name: UTF8String; var Value: TDateTime): Boolean;
    function tryGetObject(const Name: UTF8String): TPortableObjectUtf8;
    function tryGetArray(const Name: UTF8String): TPortableArray;

    function getStringDef(const Name: UTF8String; const defaultValue: UTF8String = ''): UTF8String;
    function getBoolDef(const Name: UTF8String; defaultValue: Boolean = False): Boolean;
    function getInt32Def(const Name: UTF8String; defaultValue: Int32 = 0): Int32;
    function getInt64Def(const Name: UTF8String; defaultValue: Int64 = 0): Int64;
    function getUInt64Def(const Name: UTF8String; defaultValue: UInt64 = 0): UInt64;
    function getFloatDef(const Name: UTF8String; defaultValue: Double = 0.0): Double;
    function getDateTimeDef(const Name: UTF8String; defaultValue: TDateTime = 0.0): TDateTime;

    function GetEnumerator: TPortableObjectUtf8Enumerator;

    property Types[const Name: UTF8String]: TPortableDataType read GetType;

    // Short names
    property S[const Name: UTF8String]: UTF8String read GetString write SetString; // returns '' if property doesn't exist, auto type-cast except for array/object
    property I[const Name: UTF8String]: Int32 read GetInt32 write SetInt32; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property L[const Name: UTF8String]: Int64 read GetInt64 write SetInt64; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property U[const Name: UTF8String]: UInt64 read GetUInt64 write SetUInt64; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property F[const Name: UTF8String]: Double read GetFloat write SetFloat; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property D[const Name: UTF8String]: TDateTime read GetDateTime write SetDateTime; // returns 0 if property doesn't exist, auto type-cast except for array/object
    property B[const Name: UTF8String]: Boolean read GetBool write SetBool; // returns false if property doesn't exist, auto type-cast with "<>'true'" and "<>0" except for array/object
    property A[const Name: UTF8String]: TPortableArray read GetArray write SetArray; // auto creates array on first access
    property O[const Name: UTF8String]: TPortableObjectUtf8 read GetObject write SetObject;
    // auto creates object on first access

    property Path[const NamePath: UTF8String]: PPortableValue read GetPath; default;

    // Indexed access to the named properties
    property Names[Index: Integer]: UTF8String read GetName;
    property Items[Index: Integer]: PPortableValue read GetItem;
    property Count: Integer read FCount;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

type
  TPortableDataSerializationConfig = record
    LineBreak: string;
    IndentChar: string;
    UseUtcTime: Boolean;
    NullConvertsToValueTypes: Boolean;
  end;

var
  PortableSerializationConfig: TPortableDataSerializationConfig = ( // not thread-safe
    LineBreak: #10; IndentChar: #9; UseUtcTime: True; NullConvertsToValueTypes: False; // If True and an object is nil/null, a convertion to String, Int, Long, Float, DateTime, Boolean will return ''/0/False
  );

  JSONFormatSettings: TFormatSettings;

implementation

const
  CMemoryNone = 0;

resourcestring
  RsTypeCastError = 'Cannot cast %s into %s';
  RsUnsupportedFileEncoding = 'File encoding is not supported';
  RsPropTypeCastError = 'Cannot cast %s(type %s) to %s';
  RsMissingClassInfo = 'Class "%s" doesn''t have type information. {$M+} was not specified';
  RsInvalidJsonPath = 'Invalid JSON path "%s"';
  RsJsonPathContainsNullValue = 'JSON path contains null value ("%s")';
  RsJsonPathIndexError = 'JSON path index out of bounds (%d) "%s"';
  RsVarTypeNotSupported = 'VarType %d is not supported';

function UtcDateTimeToLocalDateTime(UtcDateTime: TDateTime): TDateTime;
{$IFDEF MSWINDOWS}
var
  UtcTime, LocalTime: TSystemTime;
begin
  DateTimeToSystemTime(UtcDateTime, UtcTime);
  if SystemTimeToTzSpecificLocalTime(nil, UtcTime, LocalTime) then
    Result := SystemTimeToDateTime(LocalTime)
  else
    Result := UtcDateTime;
end;
{$ELSE}
begin
  Result := TTimeZone.Local.ToLocalTime(UtcDateTime);
end;
{$ENDIF MSWINDOWS}

function ParseDateTimePart(P: PWideChar; var Value: Integer; MaxLen: Integer): PWideChar; overload;
var
  V: Integer;
begin
  Result := P;
  V := 0;
  while WCharInSetFast(Result^, ['0' .. '9']) and (MaxLen > 0) do
  begin
    V := V * 10 + (Ord(Result^) - Ord('0'));
    Inc(Result);
    Dec(MaxLen);
  end;
  Value := V;
end;

function ParseDateTimePart(P: PAnsiChar; var Value: Integer; MaxLen: Integer): PAnsiChar; overload;
var
  V: Integer;
begin
  Result := P;
  V := 0;
  while (Result^ in ['0' .. '9']) and (MaxLen > 0) do
  begin
    V := V * 10 + (Ord(Result^) - Ord('0'));
    Inc(Result);
    Dec(MaxLen);
  end;
  Value := V;
end;

function JSONToDateTime(const Value: string): TDateTime; overload;
var
  P: PChar;
  MSecsSince1970: Int64;
  Year, Month, Day, Hour, Min, Sec, MSec: Integer;
  OffsetHour, OffsetMin: Integer;
  Sign: Double;
begin
  Result := 0;
  if Value = '' then
    Exit;

  P := PChar(Value);
  if (P^ = '/') and (StrLComp('Date(', P + 1, 5) = 0) then // .NET: milliseconds since 1970-01-01
  begin
    Inc(P, 6);
    MSecsSince1970 := 0;
    while (P^ <> #0) and WCharInSetFast(P^, ['0' .. '9']) do
    begin
      MSecsSince1970 := MSecsSince1970 * 10 + (Ord(P^) - Ord('0'));
      Inc(P);
    end;
    if (P^ = '+') or (P^ = '-') then // timezone information
    begin
      Inc(P);
      while (P^ <> #0) and WCharInSetFast(P^, ['0' .. '9']) do
        Inc(P);
    end;
    if (P[0] = ')') and (P[1] = '/') and (P[2] = #0) then
      Result := UtcDateTimeToLocalDateTime(UnixDateDelta + (MSecsSince1970 / MSecsPerDay))
    else
      Result := 0; // invalid format
  end
  else
  begin
    // "2015-02-01T16:08:19.202Z"
    if P^ = '-' then // negative year
      Inc(P);
    P := ParseDateTimePart(P, Year, 4);
    if P^ <> '-' then
      Exit; // invalid format
    P := ParseDateTimePart(P + 1, Month, 2);
    if P^ <> '-' then
      Exit; // invalid format
    P := ParseDateTimePart(P + 1, Day, 2);

    Hour := 0;
    Min := 0;
    Sec := 0;
    MSec := 0;
    Result := EncodeDate(Year, Month, Day);

    if P^ = 'T' then
    begin
      P := ParseDateTimePart(P + 1, Hour, 2);
      if P^ <> ':' then
        Exit; // invalid format
      P := ParseDateTimePart(P + 1, Min, 2);
      if P^ = ':' then
      begin
        P := ParseDateTimePart(P + 1, Sec, 2);
        if P^ = '.' then
          P := ParseDateTimePart(P + 1, MSec, 3);
      end;
      Result := Result + EncodeTime(Hour, Min, Sec, MSec);
      if P^ <> 'Z' then
      begin
        if (P^ = '+') or (P^ = '-') then
        begin
          if P^ = '+' then
            Sign := -1 // +0100 means that the time is 1 hour later than UTC
          else
            Sign := 1;

          P := ParseDateTimePart(P + 1, OffsetHour, 2);
          if P^ = ':' then
            Inc(P);
          ParseDateTimePart(P, OffsetMin, 2);

          Result := Result + (EncodeTime(OffsetHour, OffsetMin, 0, 0) * Sign);
        end
        else
        begin
          Result := 0; // invalid format
          Exit;
        end;
      end;
      Result := UtcDateTimeToLocalDateTime(Result);
    end;
  end;
end;

function JSONToDateTime(const Value: RawByteString): TDateTime; overload;
var
  P: PAnsiChar;
  MSecsSince1970: Int64;
  Year, Month, Day, Hour, Min, Sec, MSec: Integer;
  OffsetHour, OffsetMin: Integer;
  Sign: Double;
begin
  Result := 0;
  if Value = '' then
    Exit;

  P := PAnsiChar(Value);
  if (P^ = '/') and (StrLComp('Date(', P + 1, 5) = 0) then // .NET: milliseconds since 1970-01-01
  begin
    Inc(P, 6);
    MSecsSince1970 := 0;
    while (P^ <> #0) and (P^ in ['0' .. '9']) do
    begin
      MSecsSince1970 := MSecsSince1970 * 10 + (Ord(P^) - Ord('0'));
      Inc(P);
    end;
    if (P^ = '+') or (P^ = '-') then // timezone information
    begin
      Inc(P);
      while (P^ <> #0) and (P^ in ['0' .. '9']) do
        Inc(P);
    end;
    if (P[0] = ')') and (P[1] = '/') and (P[2] = #0) then
      Result := UtcDateTimeToLocalDateTime(UnixDateDelta + (MSecsSince1970 / MSecsPerDay))
    else
      Result := 0; // invalid format
  end
  else
  begin
    // "2015-02-01T16:08:19.202Z"
    if P^ = '-' then // negative year
      Inc(P);
    P := ParseDateTimePart(P, Year, 4);
    if P^ <> '-' then
      Exit; // invalid format
    P := ParseDateTimePart(P + 1, Month, 2);
    if P^ <> '-' then
      Exit; // invalid format
    P := ParseDateTimePart(P + 1, Day, 2);

    Hour := 0;
    Min := 0;
    Sec := 0;
    MSec := 0;
    Result := EncodeDate(Year, Month, Day);

    if P^ = 'T' then
    begin
      P := ParseDateTimePart(P + 1, Hour, 2);
      if P^ <> ':' then
        Exit; // invalid format
      P := ParseDateTimePart(P + 1, Min, 2);
      if P^ = ':' then
      begin
        P := ParseDateTimePart(P + 1, Sec, 2);
        if P^ = '.' then
          P := ParseDateTimePart(P + 1, MSec, 3);
      end;
      Result := Result + EncodeTime(Hour, Min, Sec, MSec);
      if P^ <> 'Z' then
      begin
        if (P^ = '+') or (P^ = '-') then
        begin
          if P^ = '+' then
            Sign := -1 // +0100 means that the time is 1 hour later than UTC
          else
            Sign := 1;

          P := ParseDateTimePart(P + 1, OffsetHour, 2);
          if P^ = ':' then
            Inc(P);
          ParseDateTimePart(P, OffsetMin, 2);

          Result := Result + (EncodeTime(OffsetHour, OffsetMin, 0, 0) * Sign);
        end
        else
        begin
          Result := 0; // invalid format
          Exit;
        end;
      end;
      Result := UtcDateTimeToLocalDateTime(Result);
    end;
  end;
end;


{$IFDEF MSWINDOWS}
{$IFDEF SUPPORT_WINDOWS2000}

var
  TzSpecificLocalTimeToSystemTime: function(lpTimeZoneInformation: PTimeZoneInformation;
    var lpLocalTime, lpUniversalTime: TSystemTime): BOOL;
stdcall;

function TzSpecificLocalTimeToSystemTimeWin2000(lpTimeZoneInformation: PTimeZoneInformation;
  var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall;
var
  TimeZoneInfo: TTimeZoneInformation;
begin
  if lpTimeZoneInformation <> nil then
    TimeZoneInfo := lpTimeZoneInformation^
  else
    GetTimeZoneInformation(TimeZoneInfo);

  // Reverse the bias so that SystemTimeToTzSpecificLocalTime becomes TzSpecificLocalTimeToSystemTime
  TimeZoneInfo.Bias := -TimeZoneInfo.Bias;
  TimeZoneInfo.StandardBias := -TimeZoneInfo.StandardBias;
  TimeZoneInfo.DaylightBias := -TimeZoneInfo.DaylightBias;

  Result := SystemTimeToTzSpecificLocalTime(@TimeZoneInfo, lpLocalTime, lpUniversalTime);
end;
{$ELSE}
function TzSpecificLocalTimeToSystemTime(lpTimeZoneInformation: PTimeZoneInformation;
  var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall;
external kernel32 name 'TzSpecificLocalTimeToSystemTime';
{$ENDIF SUPPORT_WINDOWS2000}
{$ENDIF MSWINDOWS}

function DateTimeToISO8601(Value: TDateTime): string;
{$IFDEF MSWINDOWS}
var
  LocalTime, UtcTime: TSystemTime;
  Offset: TDateTime;
  Hour, Min, Sec, MSec: Word;
begin
  DateTimeToSystemTime(Value, LocalTime);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%d', [LocalTime.wYear, LocalTime.wMonth, LocalTime.wDay,
    LocalTime.wHour, LocalTime.wMinute, LocalTime.wSecond, LocalTime.wMilliseconds]);
  if TzSpecificLocalTimeToSystemTime(nil, LocalTime, UtcTime) then
  begin
    Offset := Value - SystemTimeToDateTime(UtcTime);
    DecodeTime(Offset, Hour, Min, Sec, MSec);
    if Offset < 0 then
      Result := Format('%s-%.2d:%.2d', [Result, Hour, Min])
    else if Offset > 0 then
      Result := Format('%s+%.2d:%.2d', [Result, Hour, Min])
    else
      Result := Result + 'Z';
  end;
end;
{$ELSE}

var
  Offset: TDateTime;
  Year, Month, Day, Hour, Minute, Second, Milliseconds: Word;
begin
  DecodeDate(Value, Year, Month, Day);
  DecodeTime(Value, Hour, Minute, Second, Milliseconds);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%d', [Year, Month, Day, Hour, Minute, Second, Milliseconds]);
  Offset := Value - TTimeZone.Local.ToUniversalTime(Value);
  DecodeTime(Offset, Hour, Minute, Second, Milliseconds);
  if Offset < 0 then
    Result := Format('%s-%.2d:%.2d', [Result, Hour, Minute])
  else if Offset > 0 then
    Result := Format('%s+%.2d:%.2d', [Result, Hour, Minute])
  else
    Result := Result + 'Z';
end;
{$ENDIF MSWINDOWS}

function DateTimeToJSON(const Value: TDateTime; UseUtcTime: Boolean): string;
{$IFDEF MSWINDOWS}
var
  LocalTime, UtcTime: TSystemTime;
begin
  if UseUtcTime then
  begin
    DateTimeToSystemTime(Value, LocalTime);
    if not TzSpecificLocalTimeToSystemTime(nil, LocalTime, UtcTime) then
      UtcTime := LocalTime;
    Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%dZ', [UtcTime.wYear, UtcTime.wMonth, UtcTime.wDay, UtcTime.wHour,
      UtcTime.wMinute, UtcTime.wSecond, UtcTime.wMilliseconds]);
  end
  else
    Result := DateTimeToISO8601(Value);
end;
{$ELSE}

var
  UtcTime: TDateTime;
  Year, Month, Day, Hour, Minute, Second, Milliseconds: Word;
begin
  if UseUtcTime then
  begin
    UtcTime := TTimeZone.Local.ToUniversalTime(Value);
    DecodeDate(UtcTime, Year, Month, Day);
    DecodeTime(UtcTime, Hour, Minute, Second, Milliseconds);
    Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%dZ', [Year, Month, Day, Hour, Minute, Second, Milliseconds]);
  end
  else
    Result := DateTimeToISO8601(Value);
end;
{$ENDIF MSWINDOWS}

function DateTimeToJSON_UTF8(const Value: TDateTime; UseUtcTime: Boolean): RawByteString;
begin
  ///// optimize it
  Result := UTF8String(DateTimeToJSON(Value, UseUtcTime));
end;

procedure TypeCastError(curType, newType: TPortableDataType); overload; inline;
begin
  raise EInvalidCast.CreateResFmt(PResStringRec(@RsTypeCastError), [DataTypeNames[curType], DataTypeNames[newType]]);
end;

procedure TypeCastError(const name: string; curType, newType: TPortableDataType); overload; inline;
begin
  raise EInvalidCast.CreateResFmt(PResStringRec(@RsPropTypeCastError), [name, DataTypeNames[curType], DataTypeNames[newType]]);
end;

procedure TypeCastError(P, EndP: PChar; curType, newType: TPortableDataType); overload; inline;
var
  S: string;
begin
  System.SetString(S, P, EndP - P);
  raise EInvalidCast.CreateResFmt(PResStringRec(@RsPropTypeCastError), [S, DataTypeNames[curType], DataTypeNames[newType]]);
end;

procedure InternInitAndAssignItem(Dest, Source: PPortableValue);
begin
  Dest.dataType := Source.dataType;
  case Source.dataType of
    sdtUTF8String:
      begin
        Dest.P := nil;
        UTF8String(Dest.S) := UTF8String(Source.S);
      end;

    sdtUTF16String:
      begin
        Dest.P := nil;
        string(Dest.S) := string(Source.S);
      end;
    sdtInt32:
      Dest.I := Source.I;
    sdtInt64:
      Dest.L := Source.L;
    sdtUInt64:
      Dest.U := Source.U;
    sdtFloat:
      Dest.F := Source.F;
    sdtDateTime:
      Dest.D := Source.D;
    sdtBool:
      Dest.B := Source.B;
    sdtArray:
      begin
        if Source.O <> nil then
        begin
          TPortableArray(Dest.O) := TPortableArray.Create;
          TPortableArray(Dest.O).Assign(TPortableArray(Source.O));
        end
        else
          Dest.O := nil;
      end;
    sdtObject:
      begin
        if Source.O <> nil then
        begin
          TPortableObject(Dest.O) := TPortableObject.Create;
          TPortableObject(Dest.O).Assign(TPortableObject(Source.O));
        end
        else
          Dest.O := nil;
      end;
    sdtObjectUtf8:
      begin
        if Source.O <> nil then
        begin
          TPortableObjectUtf8(Dest.O) := TPortableObjectUtf8.Create;
          TPortableObjectUtf8(Dest.O).Assign(TPortableObjectUtf8(Source.O));
        end
        else
          Dest.O := nil;
      end;
  end;
end;

procedure ListError(Msg: PResStringRec; Data: Integer);
begin
  raise EStringListError.CreateFmt(LoadResString(Msg), [Data])
{$IFDEF HAS_RETURN_ADDRESS} at ReturnAddress {$ENDIF};
end;

procedure ErrorNoMappingForUnicodeCharacter;
begin
{$IF not declared(SNoMappingForUnicodeCharacter)}
  RaiseLastOSError;
{$ELSE}
  raise EEncodingError.CreateRes(@SNoMappingForUnicodeCharacter)
{$IFDEF HAS_RETURN_ADDRESS} at ReturnAddress {$ENDIF};
{$IFEND}
end;

procedure ErrorUnsupportedVariantType(VarType: TVarType);
begin
  raise EInvalidCast.CreateResFmt(PResStringRec(@RsVarTypeNotSupported), [VarType]);
end;

procedure AnsiLowerCamelCaseString(var S: string);
begin
  S := AnsiLowerCase(PChar(S)^) + Copy(S, 2);
end;
{$IF not declared(TryStrToUInt64)}

function TryStrToUInt64(const S: string; out Value: UInt64): Boolean;
var
  P, EndP: PChar;
  V: UInt64;
  Digit: Integer;
begin
  // No support for hexadecimal strings

  P := PChar(S);
  EndP := P + System.Length(S);
  // skip spaces
  while (P < EndP) and (P^ = ' ') do
    Inc(P);
  if P^ = '-' then
    Result := False // UInt64 cannot be negative
  else
  begin
    V := 0;
    while P < EndP do
    begin
      Digit := Integer(Ord(P^)) - Ord('0');
      if (Cardinal(Digit) >= 10) or (V > High(UInt64) div 10) then
        Break;
      // V := V * 10 + Digit;
      V := (V shl 3) + (V shl 1) + Digit;
      Inc(P);
    end;

    Result := P = EndP;
    if Result then
      Value := V;
  end;
end;
{$IFEND}

function VarTypeToPortableDataType(AVarType: TVarType): TPortableDataType;
begin
  case AVarType of
    varNull:
      Result := sdtNull;
    varEmpty:
      Result := sdtNone;
    varString:
      Result := sdtUTF8String;
    varOleStr, varUString:
      Result := sdtUTF16String;
    varSmallInt, varInteger, varShortInt, varByte, varWord, varLongWord:
      Result := sdtInt32;
    varInt64:
      Result := sdtInt64;
    varUInt64:
      Result := sdtUInt64;
    varSingle, varDouble, varCurrency:
      Result := sdtFloat;
    varDate:
      Result := sdtDateTime;
    varBoolean:
      Result := sdtBool;
  else
    ErrorUnsupportedVariantType(AVarType);
    Result := sdtNone;
  end;
end;

{ TPortableValue }

procedure TPortableValue.Assign(number: TNumber);
begin
  case number._type of
    numNaN: Self.cleanup(sdtNaN);
    numInt32: Self.AsInt32 := number.I32;
    numUInt32: Self.AsInt64 := number.UI32;
    numInt64: Self.AsInt64 := number.I64;
    numUInt64: Self.AsUInt64 := number.UI64;
    numDouble: Self.AsFloat := number.VDouble;
    numExtended: Self.AsFloat := number.VExtended;
    else
      Self.cleanup;
  end;
end;

procedure TPortableValue.cleanup(toType: TPortableDataType);
begin
  case dataType of
    sdtUTF8String:
      UTF8String(S) := '';
    sdtUTF16String:
      string(S) := '';
    sdtArray, sdtObject, sdtObjectUtf8:
      begin
        TObject(O).Free;
        O := nil;
      end;
  end;
  dataType := toType;
end;

function TPortableValue.CreateArrayIfEmpty: TPortableArray;
begin
  if dataType = sdtArray then
    Result := TPortableArray(O)
  else if dataType = sdtNone then
  begin
    Result := TPortableArray.Create;
    Self.dataType := sdtArray;
    TPortableArray(Self.O) := Result;
  end
  else
    TypeCastError(dataType, sdtArray);
end;

function TPortableValue.CreateObjectIfEmpty: TPortableObject;
begin
  if dataType = sdtObject then
    Result := TPortableObject(O)
  else if dataType = sdtNone then
  begin
    Result := TPortableObject.Create;
    Self.dataType := sdtObject;
    TPortableObject(Self.O) := Result;
  end
  else
    TypeCastError(dataType, sdtObject);
end;

function TPortableValue.CreateObjectUtf8IfEmpty: TPortableObjectUtf8;
begin
  if dataType = sdtObjectUtf8 then
    Result := TPortableObjectUtf8(O)
  else if dataType = sdtNone then
  begin
    Result := TPortableObjectUtf8.Create;
    Self.dataType := sdtObjectUtf8;
    TPortableObjectUtf8(Self.O) := Result;
  end
  else
    TypeCastError(dataType, sdtObjectUtf8);
end;

function TPortableValue.GetArrayValue: TPortableArray;
begin
  if dataType = sdtArray then
    Result := TPortableArray(O)
  else
  begin
    TypeCastError(dataType, sdtArray);
    Result := nil;
  end;
end;

procedure TPortableValue.SetArrayValue(AValue: TPortableArray);
begin
  if (dataType <> sdtArray) or (AValue <> O) then
  begin
    cleanup;
    Self.init(AValue);
  end;
end;

function TPortableValue.GetObjectUtf8: TPortableObjectUtf8;
begin
  if dataType = sdtObjectUtf8 then
    Result := TPortableObjectUtf8(O)
  else
  begin
    TypeCastError(dataType, sdtObjectUtf8);
    Result := nil;
  end;
end;

function TPortableValue.GetObjectValue: TPortableObject;
begin
  if dataType = sdtObject then
    Result := TPortableObject(O)
  else
  begin
    TypeCastError(dataType, sdtObject);
    Result := nil;
  end;
end;

procedure TPortableValue.SetObjectUtf8(Value: TPortableObjectUtf8);
begin
  if (dataType <> sdtObjectUtf8) or (Value <> O) then
  begin
    cleanup;
    Self.init(Value);
  end;
end;

procedure TPortableValue.SetObjectValue(AValue: TPortableObject);
begin
  if (dataType <> sdtObject) or (AValue <> O) then
  begin
    cleanup;
    Self.init(AValue);
  end;
end;

function TPortableValue.GetVariantValue: Variant;
begin
  case dataType of
    sdtNone:
      Result := Unassigned;
    sdtUndefined..sdtInfinity:
      Result := Null;
    sdtUTF8String:
      Result := UTF8String(S);
    sdtUTF16String:
      Result := string(S);
    sdtInt32:
      Result := I;
    sdtInt64:
      Result := L;
    sdtUInt64:
      Result := U;
    sdtFloat:
      Result := F;
    sdtDateTime:
      Result := D;
    sdtBool:
      Result := B;
    sdtArray:
      ErrorUnsupportedVariantType(varArray);
    sdtObject, sdtObjectUtf8:
      ErrorUnsupportedVariantType(varObject);
  else
    ErrorUnsupportedVariantType(varAny);
  end;
end;

procedure TPortableValue.init(AValue: Int64);
begin
  dataType := sdtInt64;
  Self.S := nil;
  Self.L := AValue;
end;

procedure TPortableValue.init(AValue: UInt64);
begin
  dataType := sdtUInt64;
  Self.S := nil;
  Self.U := AValue;
end;

procedure TPortableValue.init(const AValue: string);
begin
  dataType := sdtUTF16String;
  Self.S := nil;
  string(Self.S) := AValue;
end;

procedure TPortableValue.init(AValue: Int32);
begin
  dataType := sdtInt32;
  Self.S := nil;
  Self.I := AValue;
end;

procedure TPortableValue.init(AValue: Double);
begin
  dataType := sdtFloat;
  Self.S := nil;
  Self.F := AValue;
end;

procedure TPortableValue.init(AValue: TPortableArray);
begin
  dataType := sdtArray;
  TPortableArray(Self.O) := AValue;
end;

procedure TPortableValue.init(AValue: TPortableObject);
begin
  dataType := sdtObject;
  TPortableObject(Self.O) := AValue;
end;

procedure TPortableValue.init(const AValue: UTF8String);
begin
  dataType := sdtUTF8String;
  Self.S := nil;
  UTF8String(Self.S) := AValue;
end;

procedure TPortableValue.init(AType: TPortableDataType);
begin
  dataType := AType;
  Self.S := nil;
end;

procedure TPortableValue.init(AValue: TDateTime);
begin
  dataType := sdtDateTime;
  Self.S := nil;
  Self.D := AValue;
end;

procedure TPortableValue.init(AValue: Boolean);
begin
  dataType := sdtBool;
  Self.S := nil;
  Self.B := AValue;
end;

procedure TPortableValue.SetVariantValue(const AValue: Variant);
begin
  cleanup;
  dataType := VarTypeToPortableDataType(VarType(AValue));
  case dataType of
    sdtUTF8String:
      RawByteString(S) := RawByteString(AValue);
    sdtUTF16String:
      string(S) := AValue;
    sdtInt32:
      I := AValue;
    sdtInt64:
      L := AValue;
    sdtUInt64:
      U := AValue;
    sdtFloat:
      F := AValue;
    sdtDateTime:
      D := AValue;
    sdtBool:
      B := AValue;
    // else
    // ErrorUnsupportedVariantType; handled by VarTypeToPortableDataType
  end;
end;

function TPortableValue.expr: string;
begin
  case dataType of
    sdtNone:
      Result := '(none)';
    sdtUTF16String:
      Result := '(utf16str): ' + string(S);
    sdtUTF8String:
      Result := '(utf8str): ' + UTF8ToUStr;
    sdtNull:
      Result := '(null)';
    sdtUndefined:
      Result := '(undefined)';
    sdtNaN:
      Result := '(NaN)';
    sdtInfinity:
      Result := '(Infinity)';
    sdtInt32:
      Result := '(int32): ' + IntToStr(I);
    sdtInt64:
      Result := '(int64): ' + IntToStr(L);
    sdtUInt64:
      Result := '(uint64): ' + UIntToStr(U);
    sdtFloat:
      Result := '(int32): ' + FloatToStr(F, JSONFormatSettings);
    sdtDateTime:
      Result := '(datetime): ' + DateTimeToJSON(F, PortableSerializationConfig.UseUtcTime);
    sdtBool:
      if B then
        Result := '(bool): true'
      else
        Result := '(bool): false';
    sdtObject:
      Result := '(object of utf8)';
    sdtObjectUtf8:
      Result := '(object)';
    sdtArray:
      Result := '(array)';
    else
      Result := '(unknown)';
  end;
end;

function TPortableValue.UnicodeToBool: Boolean;
begin
  Result := string(S) = 'true';
end;

function TPortableValue.UnicodeToDateTime: TDateTime;
begin
  Result := JSONToDateTime(string(S));
end;

function TPortableValue.UnicodeToFloat: Double;
begin
  Result := StrToFloat(string(S), JSONFormatSettings)
end;

function TPortableValue.UnicodeToInt32: Int32;
begin
  Result := StrToInt(string(S));
end;

function TPortableValue.UnicodeToInt64: Int64;
begin
  Result := StrToInt64(string(S));
end;

function TPortableValue.UnicodeToUInt64: UInt64;
begin
  Result := StrToInt64(string(S));
end;

function TPortableValue.UTF8ToBool: Boolean;
begin
  Result := RawByteString(S) = 'true';
end;

function TPortableValue.UTF8ToDateTime: TDateTime;
begin
  Result := JSONToDateTime(RawByteString(S));
end;

function TPortableValue.UTF8ToFloat: Double;
begin
  Result := RBStrToFloat(RawByteString(S));
end;

function TPortableValue.UTF8ToInt32: Int32;
begin
  Result := RBStrToInt(RawByteString(S));
end;

function TPortableValue.UTF8ToInt64: Int64;
begin
  Result := RBStrToInt64(RawByteString(S));
end;

function TPortableValue.UTF8ToUInt64: UInt64;
begin
  Result := RBStrToUInt64(RawByteString(S));
end;

function TPortableValue.UTF8ToUStr: UTF16String;
begin
  Result := UTF8ToString(RawByteString(S));
end;

function TPortableValue.GetString: string;
begin
  case dataType of
    sdtNone:
      Result := '';
    sdtUTF16String:
      Result := string(S);
    sdtUTF8String:
      Result := UTF8ToUStr;
    sdtNull:
      Result := 'null';
    sdtUndefined:
      Result := 'undefined';
    sdtNaN:
      Result := 'NaN';
    sdtInfinity:
      Result := 'Infinity';
    sdtInt32:
      Result := IntToStr(I);
    sdtInt64:
      Result := IntToStr(L);
    sdtUInt64:
      Result := UIntToStr(U);
    sdtFloat:
      Result := FloatToStr(F, JSONFormatSettings);
    sdtDateTime:
      Result := DateTimeToJSON(F, PortableSerializationConfig.UseUtcTime);
    sdtBool:
      if B then
        Result := 'true'
      else
        Result := 'false';
    sdtObject, sdtObjectUtf8:
      begin
        if not PortableSerializationConfig.NullConvertsToValueTypes or (O <> nil) then
          TypeCastError(dataType, sdtUTF16String);
        Result := '';
      end;
  else
    TypeCastError(dataType, sdtUTF16String);
  end;
end;

function TPortableValue.GetTypeName: string;
begin
  Result := DataTypeNames[dataType];
end;

procedure TPortableValue.SetString(const AValue: string);
begin
  if dataType <> sdtUTF16String then
  begin
    cleanup;
    dataType := sdtUTF16String;
  end;
  string(S) := AValue;
end;

function TPortableValue.GetInt32: Int32;
begin
  case dataType of
    sdtNone..sdtInfinity:
      Result := 0;
    sdtUTF8String:
      Result := UTF8ToInt32;
    sdtUTF16String:
      Result := UnicodeToInt32;
    sdtInt32:
      Result := I;
    sdtInt64:
      Result := L;
    sdtUInt64:
      Result := U;
    sdtFloat:
      Result := Trunc(F);
    sdtDateTime:
      Result := Trunc(D);
    sdtBool:
      Result := Ord(B);
    sdtObject, sdtObjectUtf8:
      begin
        if not PortableSerializationConfig.NullConvertsToValueTypes or (O <> nil) then
          TypeCastError(dataType, sdtInt32);
        Result := 0;
      end;
  else
    TypeCastError(dataType, sdtInt32);
  end;
end;

procedure TPortableValue.SetInt32(AValue: Int32);
begin
  if dataType <> sdtInt32 then
  begin
    cleanup;
    dataType := sdtInt32;
  end;
  I := AValue;
end;

function TPortableValue.GetInt64: Int64;
begin
  case dataType of
    sdtNone..sdtInfinity:
      Result := 0;
    sdtUTF8String:
      Result := UTF8ToInt64;
    sdtUTF16String:
      Result := UnicodeToInt64;
    sdtInt32:
      Result := I;
    sdtInt64:
      Result := L;
    sdtUInt64:
      Result := U;
    sdtFloat:
      Result := Trunc(F);
    sdtDateTime:
      Result := Trunc(D);
    sdtBool:
      Result := Ord(B);
    sdtObject, sdtObjectUtf8:
      begin
        if not PortableSerializationConfig.NullConvertsToValueTypes or (O <> nil) then
          TypeCastError(dataType, sdtInt64);
        Result := 0;
      end;
  else
    TypeCastError(dataType, sdtInt64);
  end;
end;

procedure TPortableValue.SetInt64Value(AValue: Int64);
begin
  if dataType <> sdtInt64 then
  begin
    cleanup;
    dataType := sdtInt64;
  end;
  L := AValue;
end;

function TPortableValue.GetUInt64: UInt64;
begin
  case dataType of
    sdtNone..sdtInfinity:
      Result := 0;
    sdtUTF8String:
      Result := UTF8ToUInt64;
    sdtUTF16String:
      Result := UnicodeToUInt64;
    sdtInt32:
      Result := I;
    sdtInt64:
      Result := L;
    sdtUInt64:
      Result := U;
    sdtFloat:
      Result := Trunc(F);
    sdtDateTime:
      Result := Trunc(D);
    sdtBool:
      Result := Ord(B);
    sdtObject, sdtObjectUtf8:
      begin
        if not PortableSerializationConfig.NullConvertsToValueTypes or (O <> nil) then
          TypeCastError(dataType, sdtUInt64);
        Result := 0;
      end;
  else
    TypeCastError(dataType, sdtUInt64);
    Result := 0;
  end;
end;

function TPortableValue.GetUtf8: UTF8String;
begin
  if dataType = sdtUtf8String then
    Result := UTF8String(S)
  else if dataType = sdtUTF16String then
    Result := UTF8Encode(string(S))
  else
    case dataType of
      sdtNone:
        Result := '';
      sdtNull:
        Result := 'Null';
      sdtUndefined:
        Result := 'undefined';
      sdtNaN:
        Result := 'NaN';
      sdtInt32:
        Result := IntToRBStr(I);
      sdtInt64:
        Result := IntToRBStr(L);
      sdtUInt64:
        Result := UInt64ToRBStr(U);
      sdtFloat:
        Result := FloatToRBStr(F, JSONFormatSettings);
      sdtDateTime:
        Result := DateTimeToJSON_UTF8(F, PortableSerializationConfig.UseUtcTime);
      sdtBool:
        if B then
          Result := 'true'
        else
          Result := 'false';
      sdtObject, sdtObjectUtf8:
        begin
          if not PortableSerializationConfig.NullConvertsToValueTypes or (O <> nil) then
            TypeCastError(dataType, sdtUTF8String);
          Result := '';
        end;
    else
      TypeCastError(dataType, sdtUTF8String);
    end;
end;

procedure TPortableValue.SetUInt64Value(AValue: UInt64);
begin
  if dataType <> sdtUInt64 then
  begin
    cleanup;
    dataType := sdtUInt64;
  end;
  U := AValue;
end;

procedure TPortableValue.SetUtf8(const Value: UTF8String);
begin
  if dataType <> sdtUTF8String then
  begin
    cleanup;
    dataType := sdtUTF8String;
  end;
  UTF8String(S) := Value;
end;

function TPortableValue.GetFloatValue: Double;
begin
  case dataType of
    sdtNone..sdtInfinity:
      Result := 0.0;
    sdtUTF8String:
      Result := UTF8ToFloat;
    sdtUTF16String:
      Result := UnicodeToFloat;
    sdtInt32:
      Result := I;
    sdtInt64:
      Result := L;
    sdtUInt64:
      Result := U;
    sdtFloat:
      Result := F;
    sdtDateTime:
      Result := D;
    sdtBool:
      Result := Ord(B);
    sdtObject, sdtObjectUtf8:
      begin
        if not PortableSerializationConfig.NullConvertsToValueTypes or (O <> nil) then
          TypeCastError(dataType, sdtFloat);
        Result := 0;
      end;
  else
    TypeCastError(dataType, sdtFloat);
  end;
end;

procedure TPortableValue.SetFloatValue(AValue: Double);
begin
  if dataType <> sdtFloat then
  begin
    cleanup;
    dataType := sdtFloat;
  end;
  F := AValue;
end;

function TPortableValue.GetDateTimeValue: TDateTime;
begin
  case dataType of
    sdtNone..sdtInfinity:
      Result := 0.0;
    sdtUTF8String:
      Result := UTF8ToDateTime;
    sdtUTF16String:
      Result := UnicodeToDateTime;
    sdtInt32:
      Result := I;
    sdtInt64:
      Result := L;
    sdtUInt64:
      Result := U;
    sdtFloat:
      Result := F;
    sdtDateTime:
      Result := D;
    sdtBool:
      Result := Ord(B);
    sdtObject, sdtObjectUtf8:
      begin
        if not PortableSerializationConfig.NullConvertsToValueTypes or (O <> nil) then
          TypeCastError(dataType, sdtDateTime);
        Result := 0;
      end;
  else
    TypeCastError(dataType, sdtDateTime);
  end;
end;

procedure TPortableValue.SetDateTimeValue(AValue: TDateTime);
begin
  if dataType <> sdtDateTime then
  begin
    cleanup;
    dataType := sdtDateTime;
  end;
  D := AValue;
end;

function TPortableValue.GetBoolValue: Boolean;
begin
  case dataType of
    sdtNone..sdtInfinity:
      Result := False;
    sdtBool:
      Result := B;
    sdtUTF8String:
      Result := UTF8ToBool;
    sdtUTF16String:
      Result := UnicodeToBool;
    sdtInt32:
      Result := I <> 0;
    sdtInt64:
      Result := L <> 0;
    sdtUInt64:
      Result := U <> 0;
    sdtFloat:
      Result := F <> 0;
    sdtDateTime:
      Result := D <> 0;
    sdtObject, sdtObjectUtf8:
      begin
        if not PortableSerializationConfig.NullConvertsToValueTypes or (O <> nil) then
          TypeCastError(dataType, sdtBool);
        Result := False;
      end;
  else
    TypeCastError(dataType, sdtBool);
    Result := False;
  end;
end;

procedure TPortableValue.SetBoolValue(AValue: Boolean);
begin
  if dataType <> sdtBool then
  begin
    cleanup;
    dataType := sdtBool;
  end;
  B := AValue;
end;

function DoubleToText(Buffer: PChar; const Value: Extended): Integer; inline;
begin
  Result := FloatToText(Buffer, Value, fvExtended, ffGeneral, 15, 0, JSONFormatSettings);
end;

const
  DoubleDigits: array [0 .. 99] of array [0 .. 1] of Char = ('00', '01', '02', '03', '04', '05', '06', '07', '08',
    '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27',
    '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46',
    '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64', '65',
    '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84',
    '85', '86', '87', '88', '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99');

function InternIntToText(Value: Cardinal; Negative: Boolean; EndP: PChar): PChar;
var
  I, Quotient, K: Cardinal;
begin
  I := Value;
  Result := EndP;
  while I >= 100 do
  begin
    Quotient := I div 100;
    K := Quotient * 100;
    K := I - K;
    I := Quotient;
    Dec(Result, 2);
    PUInt32(Result)^ := UInt32(DoubleDigits[K]);
  end;
  if I >= 10 then
  begin
    Dec(Result, 2);
    PUInt32(Result)^ := UInt32(DoubleDigits[I]);
  end
  else
  begin
    Dec(Result);
    Result^ := Char(I or Ord('0'));
  end;

  if Negative then
  begin
    Dec(Result);
    Result^ := '-';
  end;
end;

function IntToText(Value: Integer; EndP: PChar): PChar; inline;
begin
  if Value < 0 then
    Result := InternIntToText(Cardinal(-Value), True, EndP)
  else
    Result := InternIntToText(Cardinal(Value), False, EndP);
end;

function UInt64ToText(Value: UInt64; EndP: PChar): PChar;
var
  Quotient: UInt64;
  Remainder: Cardinal;
begin
  Result := EndP;

  while Value > High(Integer) do
  begin
    Quotient := Value div 100;
    // Remainder := Value - (Quotient * 100);
    Remainder := Value - (Quotient shl 6 + Quotient shl 5 + Quotient shl 2);
    Value := Quotient;

    Dec(Result, 2);
    PUInt32(Result)^ := UInt32(DoubleDigits[Remainder]);
  end;

  Result := InternIntToText(Cardinal(Value), False, Result);
end;

function Int64ToText(Value: Int64; EndP: PChar): PChar;
var
  Neg: Boolean;
begin
  Neg := Value < 0;
  if Neg then
    Value := -Value;

  Result := UInt64ToText(UInt64(Value), EndP);

  if Neg then
  begin
    Dec(Result);
    Result^ := '-';
  end;
end;

procedure TPortableValue.init(AValue: TPortableObjectUtf8);
begin
  dataType := sdtObjectUtf8;
  TPortableObjectUtf8(Self.O) := AValue;
end;

procedure TPortableValue.init(AValue: Extended);
begin
  dataType := sdtFloat;
  Self.S := nil;
  Self.F := AValue;
end;

{ TPortableArrayEnumerator }

constructor TPortableArrayEnumerator.Create(AArray: TPortableArray);
begin
  inherited Create;
  FIndex := -1;
  FArray := AArray;
end;

function TPortableArrayEnumerator.GetCurrent: PPortableValue;
begin
  Result := FArray[FIndex];
end;

function TPortableArrayEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FArray.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TPortableArray }

destructor TPortableArray.Destroy;
begin
  Clear;
  FreeMem(FItems);
  FItems := nil;
  // inherited Destroy;
end;

procedure TPortableArray.Clear;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    FItems[I].cleanup;
  FCount := 0;
end;

procedure TPortableArray.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    ListError(PResStringRec(@SListIndexError), Index);
  FItems[Index].cleanup;
  Dec(FCount);
  if Index < FCount then
    Move(FItems[Index + 1], FItems[Index], (FCount - Index) * SizeOf(TPortableValue));
end;

function TPortableArray._AddItem: PPortableValue;
begin
  if FCount = FCapacity then
    Grow;
  Result := @FItems[FCount];
  Inc(FCount);
end;

function TPortableArray.InsertItem(Index: Integer): PPortableValue;
begin
  if Cardinal(Index) > Cardinal(FCount) then
    RaiseListError(Index);

  if FCount = FCapacity then
    Grow;
  Result := @FItems[Index];
  if Index < FCount then
    Move(Result^, FItems[Index + 1], (FCount - Index) * SizeOf(TPortableValue));
  Result.init;
  Inc(FCount);
end;

procedure TPortableArray.Grow;
var
  C, Delta: Integer;
begin
  C := FCapacity;
  if C > 64 then
    Delta := C div 4
  else if C > 8 then
    Delta := 16
  else
    Delta := 4;
  SetCapacity(C + Delta);
end;

procedure TPortableArray.SetCapacity(const Value: Integer);
var
  I: Integer;
begin
  if Value <> FCapacity then
  begin
    if FCapacity < FCount then
    begin
      // delete all overlapping items
      for I := FCapacity to FCount - 1 do
        FItems[I].cleanup;
      FCount := FCapacity;
    end;
    FCapacity := Value;
    ReallocMem(Pointer(FItems), FCapacity * SizeOf(TPortableValue));;
  end;
end;

function TPortableArray.Extract(Index: Integer): TObject;
begin
  if Items[Index].dataType in [sdtArray, sdtObject, sdtObjectUtf8] then
  begin
    Result := TObject(FItems[Index].O);
    FItems[Index].O := nil;
  end
  else
    Result := nil;
  Delete(Index);
end;

function TPortableArray.ExtractArray(Index: Integer): TPortableArray;
begin
  Result := Extract(Index) as TPortableArray;
end;

function TPortableArray.ExtractObject(Index: Integer): TPortableObject;
begin
  Result := Extract(Index) as TPortableObject;
end;

function TPortableArray.GetArray(Index: Integer): TPortableArray;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsArray;
end;

function TPortableArray.GetBool(Index: Integer): Boolean;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsBool;
end;

function TPortableArray.GetObject(Index: Integer): TPortableObject;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsObject;
end;

function TPortableArray.GetObjectUtf8(Index: Integer): TPortableObjectUtf8;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsObjectUtf8;
end;

function TPortableArray.GetVariant(Index: Integer): Variant;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsVariant;
end;

function TPortableArray.GetInt32(Index: Integer): Int32;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsInt32;
end;

function TPortableArray.GetInt64(Index: Integer): Int64;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsInt64;
end;

function TPortableArray.GetUInt64(Index: Integer): UInt64;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsUInt64;
end;

function TPortableArray.GetUTF8(Index: Integer): UTF8String;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsUtf8;
end;

function TPortableArray.GetFloat(Index: Integer): Double;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsFloat;
end;

function TPortableArray.GetDateTime(Index: Integer): TDateTime;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsDateTime;
end;

function TPortableArray.GetItem(Index: Integer): PPortableValue;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := @FItems[Index];
end;

function TPortableArray.GetString(Index: Integer): string;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].AsString;
end;

procedure TPortableArray.Add(AValue: TPortableObject);
begin
  _AddItem.init(AValue);
end;

procedure TPortableArray.Add(AValue: TPortableArray);
begin
  _AddItem.init(AValue);
end;

procedure TPortableArray.Add(AValue: Boolean);
begin
  _AddItem.init(AValue);
end;

procedure TPortableArray.Add(AValue: Int32);
begin
  _AddItem.init(AValue);
end;

procedure TPortableArray.Add(AValue: Int64);
begin
  _AddItem.init(AValue);
end;
procedure TPortableArray.Add(AValue: UInt64);
begin
  _AddItem.init(AValue);
end;

procedure TPortableArray.Add(AValue: Double);
begin
  _AddItem.init(AValue);
end;

procedure TPortableArray.Add(AValue: TDateTime);
begin
  _AddItem.init(AValue);
end;

procedure TPortableArray.Add(const AValue: string);
begin
  _AddItem.init(AValue);
end;

procedure TPortableArray.Add(const AValue: Variant);
var
  Item: PPortableValue;
begin
  VarTypeToPortableDataType(VarType(AValue)); // Handle type-check exception before adding the item
  Item := _AddItem;
  Item.init(sdtNone);
  Item.AsVariant := AValue;
end;

procedure TPortableArray.Add(const AValue: UTF8String);
begin
  _AddItem.init(AValue);
end;

function TPortableArray.AddArray: TPortableArray;
begin
  Result := TPortableArray.Create;
  Add(Result);
end;

function TPortableArray.AddItem: PPortableValue;
begin
  Result := _AddItem;
  Result.init(sdtNone);
end;

procedure TPortableArray.Add(dataType: TPortableDataType);
begin
  _AddItem.init(dataType);
end;

function TPortableArray.AddObject: TPortableObject;
begin
  Result := TPortableObject.Create;
  _AddItem.init(Result);
end;

procedure TPortableArray.Insert(Index: Integer; AValue: TPortableObject);
begin
  InsertItem(Index).init(AValue);
end;

procedure TPortableArray.Insert(Index: Integer; AValue: TPortableArray);
begin
  InsertItem(Index).init(AValue);
end;

procedure TPortableArray.Insert(Index: Integer; AValue: Boolean);
begin
  InsertItem(Index).init(AValue);
end;

procedure TPortableArray.Insert(Index: Integer; AValue: Int32);
begin
  InsertItem(Index).init(AValue);
end;

procedure TPortableArray.Insert(Index: Integer; AValue: Int64);
begin
  InsertItem(Index).init(AValue);
end;

procedure TPortableArray.Insert(Index: Integer; AValue: UInt64);
begin
  InsertItem(Index).init(AValue);
end;

procedure TPortableArray.Insert(Index: Integer; AValue: Double);
begin
  InsertItem(Index).init(AValue);
end;

procedure TPortableArray.Insert(Index: Integer; AValue: TDateTime);
begin
  InsertItem(Index).init(AValue);
end;

procedure TPortableArray.Insert(Index: Integer; const AValue: string);
begin
  InsertItem(Index).init(AValue);
end;

procedure TPortableArray.Insert(Index: Integer; const AValue: Variant);
var
  Item: PPortableValue;
begin
  VarTypeToPortableDataType(VarType(AValue)); // Handle type-check exception before inserting the item
  Item := InsertItem(Index);
  Item.AsVariant := AValue;
end;

procedure TPortableArray.Insert(Index: Integer; const AValue: UTF8String);
begin
  InsertItem(Index).init(AValue);
end;

function TPortableArray.InsertArray(Index: Integer): TPortableArray;
begin
  Result := TPortableArray.Create;
  try
    Insert(Index, Result);
  except
    Result.Free;
    raise ;
  end;
end;

function TPortableArray.InsertObject(Index: Integer): TPortableObject;
begin
  Result := TPortableObject.Create;
  try
    Insert(Index, Result);
  except
    Result.Free;
    raise ;
  end;
end;

procedure TPortableArray.InsertObject(Index: Integer; const Value: TPortableObject);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Insert(Index, Value);
end;

function TPortableArray.GetEnumerator: TPortableArrayEnumerator;
begin
  Result := TPortableArrayEnumerator.Create(Self);
end;

procedure TPortableArray.SetString(Index: Integer; const Value: string);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsString := Value;
end;

procedure TPortableArray.SetInt32(Index: Integer; Value: Int32);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsInt32 := Value;
end;

procedure TPortableArray.SetInt64(Index: Integer; Value: Int64);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsInt64 := Value;
end;

procedure TPortableArray.SetUInt64(Index: Integer; Value: UInt64);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsUInt64 := Value;
end;

procedure TPortableArray.SetUTF8(Index: Integer; const Value: UTF8String);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsUtf8 := Value;
end;

procedure TPortableArray.SetFloat(Index: Integer; Value: Double);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsFloat := Value;
end;

procedure TPortableArray.SetDateTime(Index: Integer; Value: TDateTime);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsDateTime := Value;
end;

procedure TPortableArray.SetBool(Index: Integer; Value: Boolean);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsBool := Value;
end;

procedure TPortableArray.SetArray(Index: Integer; Value: TPortableArray);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsArray := Value;
end;

procedure TPortableArray.SetObject(Index: Integer; Value: TPortableObject);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsObject := Value;
end;

procedure TPortableArray.SetObjectUtf8(Index: Integer; Value: TPortableObjectUtf8);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsObjectUtf8 := Value;
end;

procedure TPortableArray.SetVariant(Index: Integer; const Value: Variant);
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  FItems[Index].AsVariant := Value;
end;

function TPortableArray.GetType(Index: Integer): TPortableDataType;
begin
{$IFDEF CHECK_ARRAY_INDEX}
  if Cardinal(Index) >= Cardinal(FCount) then
    RaiseListError(Index);
{$ENDIF CHECK_ARRAY_INDEX}
  Result := FItems[Index].dataType;
end;

procedure TPortableArray.Assign(ASource: TPortableArray);
var
  I: Integer;
begin
  Clear;
  if ASource <> nil then
  begin
    if FCapacity < ASource.Count then
    begin
      FCapacity := ASource.Count;
      ReallocMem(FItems, ASource.Count * SizeOf(TPortableValue));
    end;
    FCount := ASource.Count;
    for I := 0 to ASource.Count - 1 do
      InternInitAndAssignItem(@FItems[I], @ASource.FItems[I]);
  end
  else
  begin
    FreeMem(FItems);
    FCapacity := 0;
  end;
end;

class procedure TPortableArray.RaiseListError(Index: Integer);
begin
  ListError(PResStringRec(@SListIndexError), Index);
end;

procedure TPortableArray.SetCount(const Value: Integer);
var
  I: Integer;
begin
  if Value <> FCount then
  begin
    SetCapacity(Value);
    // Initialize new Items to "null"
    for I := FCount to Value - 1 do
      FItems[I].init;

    FCount := Value;
  end;
end;

{ TPortableObjectEnumerator }

constructor TPortableObjectEnumerator.Create(AObject: TPortableObject);
begin
  inherited Create;
  FIndex := -1;
  FObject := AObject;
end;

function TPortableObjectEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FObject.Count - 1;
  if Result then
    Inc(FIndex);
end;

function TPortableObjectEnumerator.GetCurrent: TPortableObjectProperty;
begin
  Result.Name := FObject.Names[FIndex];
  Result.Value := FObject.Items[FIndex];
end;

{ TPortableObject }

destructor TPortableObject.Destroy;
begin
  Clear;
  FreeMem(FItems);
  FreeMem(FNames);
  // inherited Destroy;
end;

procedure TPortableObject.UpdateLastValueItem(Name: Pointer; ItemIndex: Integer);
begin
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
  if (Name <> nil) and (PInteger(@PByte(Name)[-8])^ = -1) then // string literal
  begin
    FLastValueItem := ItemIndex;
    FLastValueItemNamePtr := Name;
  end;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}
end;

procedure TPortableObject.Grow;
var
  C, Delta: Integer;
begin
  C := FCapacity;
  if C > 64 then
    Delta := C div 4
  else if C > 8 then
    Delta := 16
  else
    Delta := 4;
  SetCapacity(C + Delta);
end;

procedure TPortableObject.SetCapacity(const Value: Integer);
var
  I: Integer;
begin
  if Value <> FCapacity then
  begin
    if FCapacity < FCount then
    begin
      // delete all overlapping items
      for I := FCapacity to FCount - 1 do
      begin
        UTF16String(FNames[I]) := '';
        FItems[I].cleanup;
      end;
      FCount := FCapacity;
    end;
    FCapacity := Value;
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
    FLastValueItem := -1;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}
    ReallocMem(FItems, FCapacity * SizeOf(FItems[0]));
    ReallocMem(FNames, FCapacity * SizeOf(Pointer));
  end;
end;

procedure TPortableObject.Clear;
var
  I: Integer;
begin
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
  FLastValueItem := -1;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}

  for I := 0 to FCount - 1 do
  begin
    UTF16String(FNames[I]) := '';
    FItems[I].cleanup;
  end;

  FCount := 0;
end;

procedure TPortableObject.Remove(const Name: string);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx <> -1 then
    Delete(Idx);
end;

function TPortableObject.Extract(const Name: string): TObject;
var
  Index: Integer;
begin
  Index := IndexOf(Name);
  if Index <> -1 then
  begin
    if FItems[Index].dataType in [sdtArray, sdtObject, sdtObjectUtf8] then
    begin
      Result := TObject(FItems[Index].O);
      TObject(FItems[Index].O) := nil;
    end
    else
      Result := nil;
    Delete(Index);
  end
  else
    Result := nil;
end;

function TPortableObject.ExtractArray(const Name: string): TPortableArray;
begin
  Result := Extract(Name) as TPortableArray;
end;

function TPortableObject.ExtractObject(const Name: string): TPortableObject;
begin
  Result := Extract(Name) as TPortableObject;
end;

function TPortableObject.GetEnumerator: TPortableObjectEnumerator;
begin
  Result := TPortableObjectEnumerator.Create(Self);
end;

procedure TPortableObject.Add(const name: string; Value: Int64);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObject.Add(const name: string; Value: Int32);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObject.Add(const name, Value: string);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObject.Add(const name: string; Value: Double);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObject.Add(const name: string; Value: TDateTime);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObject.Add(const name: string; Value: UInt64);
begin
  _AddItem(Name).init(Value);
end;

function TPortableObject.AddArray(const Name: string): TPortableArray;
begin
  Result := TPortableArray.Create;
  _AddItem(Name).init(Result);
end;

function TPortableObject._AddItem(const Name: string): PPortableValue;
var
  P: PUTF16String;
begin
  if FCount = FCapacity then
    Grow;
  Result := @FItems[FCount];

  P := PUTF16String(@FNames[FCount]);
  Pointer(P^) := nil; // initialize the string
  P^ := Name;

  UpdateLastValueItem(Pointer(Name), FCount);
  Inc(FCount);
end;

function TPortableObject.AddItemP(NameBegin, NameEnd: PWideChar): PPortableValue;
var
  P: PString;
begin
  if FCount = FCapacity then
    Grow;
  Result := @FItems[FCount];

  P := PUTF16String(@FNames[FCount]);
  Pointer(P^) := nil; // initialize the string
  System.SetString(P^, NameBegin, NameEnd - NameBegin);

  Inc(FCount);
end;

procedure TPortableObject.AddNull(const name: string);
begin
  _AddItem(Name).init(sdtNull);
end;

function TPortableObject.AddObject(const Name: string): TPortableObject;
begin
  Result := TPortableObject.Create;
  _AddItem(Name).init(Result);
end;

function TPortableObject.GetArray(const Name: string): TPortableArray;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsArray
  else
  begin
    Result := TPortableArray.Create;
    _AddItem(Name).init(Result);
  end;
end;

function TPortableObject.GetBool(const Name: string): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsBool
  else
    Result := False;
end;

function TPortableObject.getBoolDef(const Name: string; defaultValue: Boolean): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsBool
  else
    Result := defaultValue;
end;

function TPortableObject.GetInt32(const Name: string): Int32;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsInt32
  else
    Result := 0;
end;

function TPortableObject.getInt32Def(const Name: string; defaultValue: Int32): Int32;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsInt32
  else
    Result := defaultValue;
end;

function TPortableObject.GetInt64(const Name: string): Int64;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsInt64
  else
    Result := 0;
end;

function TPortableObject.getInt64Def(const Name: string; defaultValue: Int64): Int64;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsInt64
  else
    Result := defaultValue;
end;

function TPortableObject.GetUInt64(const Name: string): UInt64;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsUInt64
  else
    Result := 0;
end;

function TPortableObject.getUInt64Def(const Name: string; defaultValue: UInt64): UInt64;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsUInt64
  else
    Result := defaultValue;
end;

function TPortableObject.GetFloat(const Name: string): Double;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsFloat
  else
    Result := 0;
end;

function TPortableObject.getFloatDef(const Name: string; defaultValue: Double): Double;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsFloat
  else
    Result := defaultValue;
end;

function TPortableObject.GetDateTime(const Name: string): TDateTime;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsDateTime
  else
    Result := 0;
end;

function TPortableObject.getDateTimeDef(const Name: string; defaultValue: TDateTime): TDateTime;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsDateTime
  else
    Result := defaultValue;
end;

function TPortableObject.GetObject(const Name: string): TPortableObject;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsObject
  else
  begin
    Result := TPortableObject.Create;
    _AddItem(Name).init(Result);
  end;
end;

function TPortableObject.GetString(const Name: string): string;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsString
  else
    Result := '';
end;

function TPortableObject.getStringDef(const Name, defaultValue: string): string;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsString
  else
    Result := defaultValue;
end;

procedure TPortableObject.SetArray(const Name: string; Value: TPortableArray);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsArray := Value
  else
    Add(Name, Value);
end;

procedure TPortableObject.SetBool(const Name: string; Value: Boolean);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsBool := Value
  else
    Add(Name, Value);
end;

procedure TPortableObject.SetInt32(const Name: string; Value: Int32);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsInt32 := Value
  else
    Add(Name, Value);
end;

procedure TPortableObject.SetInt64(const Name: string; Value: Int64);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsInt64 := Value
  else
    Add(Name, Value);
end;

procedure TPortableObject.SetUInt64(const Name: string; Value: UInt64);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsUInt64 := Value
  else
    Add(Name, Value);
end;

procedure TPortableObject.SetFloat(const Name: string; Value: Double);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsFloat := Value
  else
    Add(Name, Value);
end;

procedure TPortableObject.SetDateTime(const Name: string; Value: TDateTime);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsDateTime := Value
  else
    Add(Name, Value);
end;

procedure TPortableObject.SetObject(const Name: string; Value: TPortableObject);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsObject := Value
  else
    Add(Name, Value);
end;

procedure TPortableObject.SetString(const Name, Value: string);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsString := Value
  else
    Add(Name, Value);
end;

function TPortableObject.GetType(const Name: string): TPortableDataType;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.dataType
  else
    Result := sdtNone;
end;

function TPortableObject.Contains(const Name: UTF16String): Boolean;
begin
  Result := IndexOf(Name) <> -1;
end;

function TPortableObject.IndexOfPChar(S: PWideChar; Len: Integer): Integer;
begin
  if Len = 0 then
    Result := -1
  else begin
    for Result := 0 to FCount - 1 do
      if (GetStringLengthFast(FNames[Result]) = Len) and CompareMem(S, FNames[Result], Len * 2) then
        Exit;
    Result := -1;
  end;
end;

function TPortableObject.IndexOf(const Name: UTF16String): Integer;
var
  i: Integer;
begin
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
  { If "Name" is a string literal we can compare the pointer of the last stored value instead of
    searching the list. }
  if Pointer(Name) = FLastValueItemNamePtr then
  begin
    Result := FLastValueItem;
    Exit;
  end;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}

  Result := -1;
  for i := 0 to FCount - 1 do
    if Name = UTF16String(FNames[i]) then
    begin
      Result := i;
      Break;
    end;

  if Result <> -1 then
    UpdateLastValueItem(Pointer(Name), Result);
end;

function TPortableObject.GetName(Index: Integer): UTF16String;
begin
  Result := UTF16String(FNames[Index]);
end;

function TPortableObject.GetItem(Index: Integer): PPortableValue;
begin
  Result := @FItems[Index];
end;

procedure TPortableObject.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    ListError(PResStringRec(@SListIndexError), Index);
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
  if Index = FLastValueItem then
  begin
    FLastValueItem := -1;
    // FLastValueItemNamePtr := nil;
  end;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}

  UTF16String(FNames[Index]) := '';
  FItems[Index].cleanup;
  Dec(FCount);
  if Index < FCount then
  begin
    Move(FItems[Index + 1], FItems[Index], (FCount - Index) * SizeOf(FItems[0]));
    Move(FNames[Index + 1], FNames[Index], (FCount - Index) * SizeOf(Pointer));
  end;
end;

procedure TPortableObject.ToSimpleObject(AObject: TObject; ACaseSensitive: Boolean);
var
  Index, Count: Integer;
  PropList: PPropList;
  PropType: PTypeInfo;
  PropInfo: PPropInfo;
  PropName: string;
  Item: PPortableValue;
  V: Variant;
begin
  if AObject = nil then
    Exit;
  if AObject.ClassInfo = nil then
    raise EInvalidCast.CreateResFmt(PResStringRec(@RsMissingClassInfo), [AObject.ClassName]);

  Count := GetPropList(AObject, PropList);
  if Count > 0 then
  begin
    try
      for Index := 0 to Count - 1 do
      begin
        PropInfo := PropList[Index];
        if (PropInfo.StoredProc = Pointer($1)) or IsStoredProp(AObject, PropInfo) then
        begin
          PropName := UTF8ToString(PropInfo.Name);
          Item := FindItem(PropName);

          if Item <> nil then
          begin
            case PropInfo.PropType^.Kind of
              tkInteger, tkChar, tkWChar:
                SetOrdProp(AObject, PropInfo, Item.AsInt32);

              tkEnumeration:
                SetOrdProp(AObject, PropInfo, Item.AsInt32);

              tkFloat:
                begin
                  PropType := PropInfo.PropType^;
                  if (PropType = TypeInfo(TDateTime)) or (PropType = TypeInfo(TDate)) or (PropType = TypeInfo(TTime))
                    then
                    SetFloatProp(AObject, PropInfo, Item.AsDateTime)
                  else
                    SetFloatProp(AObject, PropInfo, Item.AsFloat);
                end;

              tkInt64:
                SetInt64Prop(AObject, PropInfo, Item.AsInt64);

              tkString, tkLString, tkWString, tkUString:
                SetStrProp(AObject, PropInfo, Item.AsString);

              tkSet:
                SetSetProp(AObject, PropInfo, Item.AsString);

              tkVariant:
                begin
                  case Types[PropName] of
                    sdtNone, sdtNull, sdtObject, sdtObjectUtf8, sdtArray:
                      V := Null;
                    sdtInt32:
                      V := Item.AsInt32;
                    sdtInt64:
                      V := Item.AsInt64;
                    sdtUInt64:
                      V := Item.AsUInt64;
                    sdtFloat:
                      V := Item.AsFloat;
                    sdtDateTime:
                      V := Item.AsDateTime;
                    sdtBool:
                      V := Item.AsBool;
                  else
                    V := Item.AsString;
                  end;
                  SetVariantProp(AObject, PropInfo, V);
                end;
            end;
          end;
        end;
      end;
    finally
      FreeMem(PropList);
    end;
  end;
end;

function TPortableObject.tryGetArray(const Name: string): TPortableArray;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsArray
  else
    Result := nil;
end;

function TPortableObject.tryGetBool(const Name: string; var Value: Boolean): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsBool;
end;

function TPortableObject.tryGetDateTime(const Name: string; var Value: TDateTime): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsDateTime;
end;

function TPortableObject.tryGetFloat(const Name: string; var Value: Double): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsFloat;
end;

function TPortableObject.tryGetInt32(const Name: string; var Value: Int32): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsInt32;
end;

function TPortableObject.tryGetInt64(const Name: string; var Value: Int64): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsInt64;
end;

function TPortableObject.tryGetObject(const Name: string): TPortableObject;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsObject
  else
    Result := nil;
end;

function TPortableObject.tryGetString(const Name: string; var Value: string): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsString;
end;

function TPortableObject.tryGetUInt64(const Name: string; var Value: UInt64): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsUInt64;
end;

procedure TPortableObject.FromSimpleObject(AObject: TObject; ALowerCamelCase: Boolean);
var
  Index, Count: Integer;
  PropList: PPropList;
  PropType: PTypeInfo;
  PropInfo: PPropInfo;
  PropName, sprop: string;
  V: Variant;
  D: Double;
  Ch: Char;
begin
  Clear;
  if AObject = nil then
    Exit;
  if AObject.ClassInfo = nil then
    raise EInvalidCast.CreateResFmt(PResStringRec(@RsMissingClassInfo), [AObject.ClassName]);

  Count := GetPropList(AObject, PropList);
  if Count > 0 then
  begin
    try
      for Index := 0 to Count - 1 do
      begin
        PropInfo := PropList[Index];
        if (PropInfo.StoredProc = Pointer($1)) or IsStoredProp(AObject, PropInfo) then
        begin
          PropName := UTF8ToString(PropInfo.Name);
          if ALowerCamelCase and (PropName <> '') then
          begin
            Ch := PChar(Pointer(PropName))^;
            if Ord(Ch) < 128 then
            begin
              case Ch of
                'A' .. 'Z':
                  PChar(Pointer(PropName))^ := Char(Ord(Ch) xor $20);
              end;
            end
            else // Delphi 2005+ compilers allow unicode identifiers, even if that is a very bad idea
              AnsiLowerCamelCaseString(PropName);
          end;

          case PropInfo.PropType^.Kind of
            tkInteger, tkChar, tkWChar:
              Add(PropName, GetOrdProp(AObject, PropInfo));

            tkEnumeration:
              begin
                PropType := PropInfo.PropType^;
                if (PropType = TypeInfo(Boolean)) or (PropType = TypeInfo(ByteBool)) or (PropType = TypeInfo(WordBool))
                  or (PropType = TypeInfo(LongBool)) then
                  FastAdd(PropName, GetOrdProp(AObject, PropInfo) <> 0)
                else
                  FastAdd(PropName, GetOrdProp(AObject, PropInfo));
              end;

            tkFloat:
              begin
                PropType := PropInfo.PropType^;
                D := GetFloatProp(AObject, PropInfo);
                if (PropType = TypeInfo(TDateTime)) or (PropType = TypeInfo(TDate)) or (PropType = TypeInfo(TTime)) then
                  FastAdd(PropName, TDateTime(D))
                else
                  FastAdd(PropName, D);
              end;

            tkInt64:
              FastAdd(PropName, GetInt64Prop(AObject, PropInfo));

            tkString, tkLString, tkWString, tkUString:
              begin
                sprop := GetStrProp(AObject, PropInfo);
                FastAdd(PropName, sprop);
              end;

            tkSet:
              begin
                sprop := GetSetProp(AObject, PropInfo);
                FastAdd(PropName, sprop);
              end;

            tkVariant:
              begin
                V := GetVariantProp(AObject, PropInfo);
                if VarIsNull(V) then
                  FastAddNull(PropName)
                else if VarIsEmpty(V) then
                  _FastAddItem(PropName).init(sdtNone)
                else
                begin
                  case VarType(V) and varTypeMask of
                    varSingle, varDouble, varCurrency:
                      FastAdd(PropName, Double(V));
                    varShortInt, varSmallInt, varInteger, varByte, varWord:
                      FastAdd(PropName, Integer(V));
                    varLongWord:
                      FastAdd(PropName, Int64(UInt32(V)));
{$IF CompilerVersion >= 23.0} // XE2+
                    varInt64:
                      FastAdd(PropName, Int64(V));
{$IFEND}
                    varBoolean:
                      FastAdd(PropName, Boolean(V));
                  else
                    sprop := VarToStr(V);
                    FastAdd(PropName, sprop);
                  end;
                end;
              end;
          end;
        end;
      end;
    finally
      FreeMem(PropList);
    end;
  end;
end;

procedure TPortableObject.FastAdd(var name: string; Value: UInt64);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObject.FastAdd(var name: string; Value: TDateTime);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObject.FastAdd(var name: string; Value: Int64);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObject.FastAdd(var name, Value: string);
var
  Item: PPortableValue;
begin
  Item := _FastAddItem(Name);
  Item.dataType := sdtUTF16String;
  Item.S := Pointer(Value);
  Pointer(Value) := nil;
end;

procedure TPortableObject.FastAdd(var name: string; Value: Int32);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObject.FastAdd(var name: string; Value: Boolean);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObject.FastAdd(var name: string; Value: Double);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObject.FastAdd(var name: string; Value: TPortableArray);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObject.FastAdd(var name: string; Value: TPortableObject);
begin
  _FastAddItem(Name).init(Value)
end;

function TPortableObject.FastAddArray(var Name: string): TPortableArray;
begin
  Result := TPortableArray.Create;
  _FastAddItem(Name).init(Result);
end;

function TPortableObject.FastAddItem(var Name: string): PPortableValue;
begin
  Result := _FastAddItem(Name);
  Result.init;
end;

function TPortableObject._FastAddItem(var Name: string): PPortableValue;
begin
  if FCount = FCapacity then
    Grow;
  Result := @FItems[FCount];

  UpdateLastValueItem(Pointer(Name), FCount);
  FNames[FCount] := Pointer(Name); // initialize the string
  Pointer(Name) := nil;
  Inc(FCount);
end;

procedure TPortableObject.FastAddNull(var name: string);
begin
  _FastAddItem(Name).init(sdtNull);
end;

function TPortableObject.FastAddObject(var Name: string): TPortableObject;
begin
  Result := TPortableObject.Create;
  _FastAddItem(Name).init(Result);
end;

function TPortableObject.FindItem(const Name: string): PPortableValue;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx <> -1 then
    Result := @FItems[Idx]
  else
    Result := nil;
end;

procedure TPortableObject.Assign(ASource: TPortableObject);
var
  I: Integer;
begin
  Clear;
  if ASource <> nil then
  begin
    SetCapacity(ASource.Count);

    FCount := ASource.Count;
    for I := 0 to ASource.Count - 1 do
    begin
      FNames[I] := nil;
      UTF16String(FNames[I]) := UTF16String(ASource.FNames[I]);
      InternInitAndAssignItem(@FItems[I], @ASource.FItems[I]);
    end;
  end
  else
  begin
    FreeMem(FItems);
    FreeMem(FNames);
    FCapacity := 0;
  end;
end;

procedure TPortableObject.PathError(P, EndP: PChar);
var
  S: string;
begin
  System.SetString(S, P, EndP - P);
  raise EJsonPathException.CreateResFmt(PResStringRec(@RsInvalidJsonPath), [S]);
end;

procedure TPortableObject.PathNullError(P, EndP: PChar);
var
  S: string;
begin
  System.SetString(S, P, EndP - P);
  raise EJsonPathException.CreateResFmt(PResStringRec(@RsJsonPathContainsNullValue), [S]);
end;

procedure TPortableObject.PathIndexError(P, EndP: PWideChar; Count: Integer);
var
  s: UTF16String;
begin
  System.SetString(s, P, EndP - P);
  raise EJsonPathException.CreateResFmt(PResStringRec(@RsJsonPathIndexError), [Count, s]);
end;

function TPortableObject.GetPath(const NamePath: string): PPortableValue;
var
  F, P, EndF: PChar;
  Ch: Char;
  Idx: Integer;
  Obj: TPortableObject;
  Arr: TPortableArray;
  Item: PPortableValue;
begin
  //if FindItem(NamePath, Result) then
    //Exit;

  Result := nil;
  P := PChar(Pointer(NamePath));
  if P^ = #0 then
    Exit;

  Obj := Self;
  Item := nil;

  while True do
  begin
    F := P;

    // fast forward
    Ch := P^;
    // DCC64 generates "bt mem,reg" code
    // while not (Ch in [#0, '[', '.']) do
    // begin
    // Inc(P);
    // Ch := P^;
    // end;
    while True do
      case Ch of
        #0, '.', '[': Break;
      else
        Inc(P);
        Ch := P^;
      end;

    EndF := P;
    if F = EndF then
      PathError(PChar(Pointer(NamePath)), P + 1);

    Inc(P);

    if not Assigned(Obj) then
      Obj := Item.CreateObjectIfEmpty;

    case Ch of
      #0:
        begin
          Idx := Obj.IndexOfPChar(F, EndF - F);
          if Idx <> -1 then
            Result := @Obj.FItems[Idx]
          else begin
            Result := Obj.AddItemP(F, EndF);
            Result.init(sdtNone);
          end;
          Break;
        end;

      '.': // object access
        begin
          Idx := Obj.IndexOfPChar(F, EndF - F);
          if Idx <> -1 then
            Item := @Obj.FItems[Idx]
          else begin
            Item := Obj.AddItemP(F, EndF);
            Item.init(sdtNone);
          end;
          Obj := nil;
        end;

      '[': // array access
        begin
          Idx := Obj.IndexOfPChar(F, EndF - F);
          if Idx <> -1 then
            Arr := Obj.FItems[Idx].CreateArrayIfEmpty
          else begin
            Arr := TPortableArray.Create;
            Obj.AddItemP(F, EndF).init(Arr);
          end;
          Ch := P^;
          // parse array index
          Idx := 0;
          while WCharInSetFast(Ch, ['0' .. '9']) do
          begin
            Idx := Idx * 10 + (Word(Ch) - Ord('0'));
            Inc(P);
            Ch := P^;
          end;

          if P^ <> ']' then
            PathError(PChar(Pointer(NamePath)), P + 1);
          Inc(P);

          if Idx >= Arr.Count then
            PathIndexError(PChar(Pointer(NamePath)), P, Arr.Count);
          Item := @Arr.FItems[Idx];

          if P^ = '.' then
          begin
            Obj := nil;
            Inc(P);
          end
          else if P^ = #0 then
          begin
            Result := Item;
            Break;
          end;
        end;
    end;
  end;
end;

procedure TPortableObject.Add(const name: string; Value: Boolean);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObject.Add(const name: string; Value: TPortableArray);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObject.Add(const name: string; Value: TPortableObject);
begin
  _AddItem(Name).init(Value);
end;

{ TPortableObjectEnumerator }

constructor TPortableObjectUtf8Enumerator.Create(AObject: TPortableObjectUtf8);
begin
  inherited Create;
  FIndex := -1;
  FObject := AObject;
end;

function TPortableObjectUtf8Enumerator.MoveNext: Boolean;
begin
  Result := FIndex < FObject.Count - 1;
  if Result then
    Inc(FIndex);
end;

function TPortableObjectUtf8Enumerator.GetCurrent: TPortableObjectUtf8Property;
begin
  Result.Name := FObject.Names[FIndex];
  Result.Value := FObject.Items[FIndex];
end;


{ TPortableObjectUtf8 }

destructor TPortableObjectUtf8.Destroy;
begin
  Clear;
  FreeMem(FItems);
  FreeMem(FNames);
  // inherited Destroy;
end;

procedure TPortableObjectUtf8.UpdateLastValueItem(Name: Pointer; ItemIndex: Integer);
begin
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
  if (Name <> nil) and (PInteger(@PByte(Name)[-8])^ = -1) then // string literal
  begin
    FLastValueItem := ItemIndex;
    FLastValueItemNamePtr := Name;
  end;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}
end;

function TPortableObjectUtf8.GetName(Index: Integer): UTF8String;
begin
  Result := UTF8String(FNames[Index]);
end;

function TPortableObjectUtf8.GetPath(const NamePath: UTF8String): PPortableValue;
var
  F, P, EndF: PAnsiChar;
  Ch: AnsiChar;
  Idx: Integer;
  Obj: TPortableObjectUtf8;
  Arr: TPortableArray;
  Item: PPortableValue;
begin
  //if FindItem(NamePath, Result) then
    //Exit;

  Result := nil;
  P := PAnsiChar(Pointer(NamePath));
  if P^ = #0 then
    Exit;

  Obj := Self;
  Item := nil;

  while True do
  begin
    F := P;

    // fast forward
    Ch := P^;
    // DCC64 generates "bt mem,reg" code
    // while not (Ch in [#0, '[', '.']) do
    // begin
    // Inc(P);
    // Ch := P^;
    // end;
    while True do
      case Ch of
        #0, '.', '[': Break;
      else
        Inc(P);
        Ch := P^;
      end;

    EndF := P;
    if F = EndF then
      PathError(PAnsiChar(Pointer(NamePath)), P + 1);

    Inc(P);

    if not Assigned(Obj) then
      Obj := Item.CreateObjectUtf8IfEmpty;

    case Ch of
      #0:
        begin
          Idx := Obj.IndexOfPChar(F, EndF - F);
          if Idx <> -1 then
            Result := @Obj.FItems[Idx]
          else begin
            Result := Obj.AddItemP(F, EndF);
            Result.init(sdtNone);
          end;
          Break;
        end;

      '.': // object access
        begin
          Idx := Obj.IndexOfPChar(F, EndF - F);
          if Idx <> -1 then
            Item := @Obj.FItems[Idx]
          else begin
            Item := Obj.AddItemP(F, EndF);
            Item.init(sdtNone);
          end;
          Obj := nil;
        end;

      '[': // array access
        begin
          Idx := Obj.IndexOfPChar(F, EndF - F);
          if Idx <> -1 then
            Arr := Obj.FItems[Idx].CreateArrayIfEmpty
          else begin
            Arr := TPortableArray.Create;
            Obj.AddItemP(F, EndF).init(Arr);
          end;
          Ch := P^;
          // parse array index
          Idx := 0;
          while Ch in ['0' .. '9'] do
          begin
            Idx := Idx * 10 + (Word(Ch) - Ord('0'));
            Inc(P);
            Ch := P^;
          end;

          if P^ <> ']' then
            PathError(PAnsiChar(Pointer(NamePath)), P + 1);
          Inc(P);

          if Idx >= Arr.Count then
            PathIndexError(PAnsiChar(Pointer(NamePath)), P, Arr.Count);
          Item := @Arr.FItems[Idx];

          if P^ = '.' then
          begin
            Obj := nil;
            Inc(P);
          end
          else if P^ = #0 then
          begin
            Result := Item;
            Break;
          end;
        end;
    end;
  end;
end;

procedure TPortableObjectUtf8.Grow;
var
  C, Delta: Integer;
begin
  C := FCapacity;
  if C > 64 then
    Delta := C div 4
  else if C > 8 then
    Delta := 16
  else
    Delta := 4;
  SetCapacity(C + Delta);
end;

procedure TPortableObjectUtf8.SetCapacity(const Value: Integer);
var
  I: Integer;
begin
  if Value <> FCapacity then
  begin
    if FCapacity < FCount then
    begin
      // delete all overlapping items
      for I := FCapacity to FCount - 1 do
      begin
        UTF8String(FNames[I]) := '';
        FItems[I].cleanup;
      end;
      FCount := FCapacity;
    end;
    FCapacity := Value;
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
    FLastValueItem := -1;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}
    ReallocMem(FItems, FCapacity * SizeOf(FItems[0]));
    ReallocMem(FNames, FCapacity * SizeOf(Pointer));
  end;
end;

procedure TPortableObjectUtf8.Clear;
var
  I: Integer;
begin
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
  FLastValueItem := -1;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}

  for I := 0 to FCount - 1 do
  begin
    UTF8String(FNames[I]) := '';
    FItems[I].cleanup;
  end;

  FCount := 0;
end;

procedure TPortableObjectUtf8.Remove(const Name: UTF8String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx <> -1 then
    Delete(Idx);
end;

function TPortableObjectUtf8.Extract(const Name: UTF8String): TObject;
var
  Index: Integer;
begin
  Index := IndexOf(Name);
  if Index <> -1 then
  begin
    if FItems[Index].dataType in [sdtArray, sdtObject, sdtObjectUtf8] then
    begin
      Result := TObject(FItems[Index].O);
      TObject(FItems[Index].O) := nil;
    end
    else
      Result := nil;
    Delete(Index);
  end
  else
    Result := nil;
end;

function TPortableObjectUtf8.ExtractArray(const Name: UTF8String): TPortableArray;
begin
  Result := Extract(Name) as TPortableArray;
end;

function TPortableObjectUtf8.ExtractObject(const Name: UTF8String): TPortableObjectUtf8;
begin
  Result := Extract(Name) as TPortableObjectUtf8;
end;

function TPortableObjectUtf8.GetEnumerator: TPortableObjectUtf8Enumerator;
begin
  Result := TPortableObjectUtf8Enumerator.Create(Self);
end;

procedure TPortableObjectUtf8.Add(const name: UTF8String; Value: Int64);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObjectUtf8.Add(const name: UTF8String; Value: Int32);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObjectUtf8.Add(const name, Value: UTF8String);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObjectUtf8.Add(const name: UTF8String; Value: Double);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObjectUtf8.Add(const name: UTF8String; Value: TDateTime);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObjectUtf8.Add(const name: UTF8String; Value: UInt64);
begin
  _AddItem(Name).init(Value);
end;

function TPortableObjectUtf8.AddArray(const Name: UTF8String): TPortableArray;
begin
  Result := TPortableArray.Create;
  _AddItem(Name).init(Result);
end;

function TPortableObjectUtf8._AddItem(const Name: UTF8String): PPortableValue;
var
  P: PUTF8String;
begin
  if FCount = FCapacity then
    Grow;
  Result := @FItems[FCount];

  P := PUTF8String(@FNames[FCount]);
  Pointer(P^) := nil; // initialize the string
  P^ := Name;

  UpdateLastValueItem(Pointer(Name), FCount);
  Inc(FCount);
end;

function TPortableObjectUtf8.AddItemP(NameBegin, NameEnd: PAnsiChar): PPortableValue;
var
  P: PUTF8String;
begin
  if FCount = FCapacity then
    Grow;
  Result := @FItems[FCount];

  P := PUTF8String(@FNames[FCount]);
  Pointer(P^) := nil; // initialize the string
  System.SetString(P^, NameBegin, NameEnd - NameBegin);

  Inc(FCount);
end;

procedure TPortableObjectUtf8.AddNull(const name: UTF8String);
begin
  _AddItem(Name).init(sdtNull);
end;

function TPortableObjectUtf8.AddObject(const Name: UTF8String): TPortableObjectUtf8;
begin
  Result := TPortableObjectUtf8.Create;
  _AddItem(Name).init(Result);
end;

function TPortableObjectUtf8.GetArray(const Name: UTF8String): TPortableArray;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsArray
  else
  begin
    Result := TPortableArray.Create;
    _AddItem(Name).init(Result);
  end;
end;

function TPortableObjectUtf8.GetBool(const Name: UTF8String): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsBool
  else
    Result := False;
end;

function TPortableObjectUtf8.getBoolDef(const Name: UTF8String; defaultValue: Boolean): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsBool
  else
    Result := defaultValue;
end;

function TPortableObjectUtf8.GetInt32(const Name: UTF8String): Int32;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsInt32
  else
    Result := 0;
end;

function TPortableObjectUtf8.getInt32Def(const Name: UTF8String; defaultValue: Int32): Int32;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsInt32
  else
    Result := defaultValue;
end;

function TPortableObjectUtf8.GetInt64(const Name: UTF8String): Int64;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsInt64
  else
    Result := 0;
end;

function TPortableObjectUtf8.getInt64Def(const Name: UTF8String; defaultValue: Int64): Int64;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsInt64
  else
    Result := defaultValue;
end;

function TPortableObjectUtf8.GetUInt64(const Name: UTF8String): UInt64;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsUInt64
  else
    Result := 0;
end;

function TPortableObjectUtf8.getUInt64Def(const Name: UTF8String; defaultValue: UInt64): UInt64;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsUInt64
  else
    Result := defaultValue;
end;

function TPortableObjectUtf8.GetFloat(const Name: UTF8String): Double;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsFloat
  else
    Result := 0;
end;

function TPortableObjectUtf8.getFloatDef(const Name: UTF8String; defaultValue: Double): Double;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsFloat
  else
    Result := defaultValue;
end;

function TPortableObjectUtf8.GetDateTime(const Name: UTF8String): TDateTime;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsDateTime
  else
    Result := 0;
end;

function TPortableObjectUtf8.getDateTimeDef(const Name: UTF8String; defaultValue: TDateTime): TDateTime;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsDateTime
  else
    Result := defaultValue;
end;

function TPortableObjectUtf8.GetObject(const Name: UTF8String): TPortableObjectUtf8;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsObjectUtf8
  else
  begin
    Result := TPortableObjectUtf8.Create;
    _AddItem(Name).init(Result);
  end;
end;

function TPortableObjectUtf8.GetString(const Name: UTF8String): UTF8String;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsUtf8
  else
    Result := '';
end;

function TPortableObjectUtf8.getStringDef(const Name, defaultValue: UTF8String): UTF8String;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsUtf8
  else
    Result := defaultValue;
end;

procedure TPortableObjectUtf8.SetArray(const Name: UTF8String; Value: TPortableArray);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsArray := Value
  else
    Add(Name, Value);
end;

procedure TPortableObjectUtf8.SetBool(const Name: UTF8String; Value: Boolean);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsBool := Value
  else
    Add(Name, Value);
end;

procedure TPortableObjectUtf8.SetInt32(const Name: UTF8String; Value: Int32);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsInt32 := Value
  else
    Add(Name, Value);
end;

procedure TPortableObjectUtf8.SetInt64(const Name: UTF8String; Value: Int64);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsInt64 := Value
  else
    Add(Name, Value);
end;

procedure TPortableObjectUtf8.SetUInt64(const Name: UTF8String; Value: UInt64);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsUInt64 := Value
  else
    Add(Name, Value);
end;

procedure TPortableObjectUtf8.SetFloat(const Name: UTF8String; Value: Double);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsFloat := Value
  else
    Add(Name, Value);
end;

procedure TPortableObjectUtf8.SetDateTime(const Name: UTF8String; Value: TDateTime);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsDateTime := Value
  else
    Add(Name, Value);
end;

procedure TPortableObjectUtf8.SetObject(const Name: UTF8String; Value: TPortableObjectUtf8);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsObjectUtf8 := Value
  else
    Add(Name, Value);
end;

procedure TPortableObjectUtf8.SetString(const Name, Value: UTF8String);
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Item.AsUtf8 := Value
  else
    Add(Name, Value);
end;

function TPortableObjectUtf8.GetType(const Name: UTF8String): TPortableDataType;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.dataType
  else
    Result := sdtNone;
end;

function TPortableObjectUtf8.Contains(const Name: UTF8String): Boolean;
begin
  Result := IndexOf(Name) <> -1;
end;

function TPortableObjectUtf8.IndexOf(const Name: UTF8String): Integer;
var
  i: Integer;
begin
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
  { If "Name" is a string literal we can compare the pointer of the last stored value instead of
    searching the list. }
  if Pointer(Name) = FLastValueItemNamePtr then
  begin
    Result := FLastValueItem;
    Exit;
  end;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}

  Result := -1;
  for i := 0 to FCount - 1 do
    if AnsiString(Pointer(Name)) = AnsiString(FNames[i]) then
    begin
      Result := i;
      Break;
    end;

  if Result <> -1 then
    UpdateLastValueItem(Pointer(Name), Result);
end;

function TPortableObjectUtf8.IndexOfPChar(S: PAnsiChar; Len: Integer): Integer;
begin
  if Len = 0 then
    Result := -1
  else begin
    for Result := 0 to FCount - 1 do
      if (GetStringLengthFast(FNames[Result]) = Len) and CompareMem(S, FNames[Result], Len) then
        Exit;
    Result := -1;
  end;
end;

function TPortableObjectUtf8.GetItem(Index: Integer): PPortableValue;
begin
  Result := @FItems[Index];
end;

procedure TPortableObjectUtf8.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    ListError(PResStringRec(@SListIndexError), Index);
{$IFDEF USE_LAST_NAME_STRING_LITERAL_CACHE}
  if Index = FLastValueItem then
  begin
    FLastValueItem := -1;
    // FLastValueItemNamePtr := nil;
  end;
{$ENDIF USE_LAST_NAME_STRING_LITERAL_CACHE}

  UTF8String(FNames[Index]) := '';

  FItems[Index].cleanup;
  Dec(FCount);
  if Index < FCount then
  begin
    Move(FItems[Index + 1], FItems[Index], (FCount - Index) * SizeOf(FItems[0]));
    Move(FNames[Index + 1], FNames[Index], (FCount - Index) * SizeOf(Pointer));
  end;
end;

procedure TPortableObjectUtf8.ToSimpleObject(AObject: TObject; ACaseSensitive: Boolean);
var
  Index, Count: Integer;
  PropList: PPropList;
  PropType: PTypeInfo;
  PropInfo: PPropInfo;
  PropName: UTF8String;
  Item: PPortableValue;
  V: Variant;
begin
  if AObject = nil then
    Exit;
  if AObject.ClassInfo = nil then
    raise EInvalidCast.CreateResFmt(PResStringRec(@RsMissingClassInfo), [AObject.ClassName]);

  Count := GetPropList(AObject, PropList);
  if Count > 0 then
  begin
    try
      for Index := 0 to Count - 1 do
      begin
        PropInfo := PropList[Index];
        if (PropInfo.StoredProc = Pointer($1)) or IsStoredProp(AObject, PropInfo) then
        begin
          PropName := UTF8String(PropInfo.Name);
          Item := FindItem(PropName);

          if Item <> nil then
          begin
            case PropInfo.PropType^.Kind of
              tkInteger, tkChar, tkWChar:
                SetOrdProp(AObject, PropInfo, Item.AsInt32);

              tkEnumeration:
                SetOrdProp(AObject, PropInfo, Item.AsInt32);

              tkFloat:
                begin
                  PropType := PropInfo.PropType^;
                  if (PropType = TypeInfo(TDateTime)) or (PropType = TypeInfo(TDate)) or (PropType = TypeInfo(TTime))
                    then
                    SetFloatProp(AObject, PropInfo, Item.AsDateTime)
                  else
                    SetFloatProp(AObject, PropInfo, Item.AsFloat);
                end;

              tkInt64:
                SetInt64Prop(AObject, PropInfo, Item.AsInt64);

              tkString, tkLString, tkWString, tkUString:
                SetStrProp(AObject, PropInfo, Item.AsString);

              tkSet:
                SetSetProp(AObject, PropInfo, Item.AsString);

              tkVariant:
                begin
                  case Types[PropName] of
                    sdtNone, sdtNull, sdtObject, sdtObjectUtf8, sdtArray:
                      V := Null;
                    sdtInt32:
                      V := Item.AsInt32;
                    sdtInt64:
                      V := Item.AsInt64;
                    sdtUInt64:
                      V := Item.AsUInt64;
                    sdtFloat:
                      V := Item.AsFloat;
                    sdtDateTime:
                      V := Item.AsDateTime;
                    sdtBool:
                      V := Item.AsBool;
                  else
                    V := Item.AsString;
                  end;
                  SetVariantProp(AObject, PropInfo, V);
                end;
            end;
          end;
        end;
      end;
    finally
      FreeMem(PropList);
    end;
  end;
end;

function TPortableObjectUtf8.tryGetArray(const Name: UTF8String): TPortableArray;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsArray
  else
    Result := nil;
end;

function TPortableObjectUtf8.tryGetBool(const Name: UTF8String; var Value: Boolean): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsBool;
end;

function TPortableObjectUtf8.tryGetDateTime(const Name: UTF8String; var Value: TDateTime): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsDateTime;
end;

function TPortableObjectUtf8.tryGetFloat(const Name: UTF8String; var Value: Double): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsFloat;
end;

function TPortableObjectUtf8.tryGetInt32(const Name: UTF8String; var Value: Int32): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsInt32;
end;

function TPortableObjectUtf8.tryGetInt64(const Name: UTF8String; var Value: Int64): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsInt64;
end;

function TPortableObjectUtf8.tryGetObject(const Name: UTF8String): TPortableObjectUtf8;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);

  if Assigned(Item) then
    Result := Item.AsObjectUtf8
  else
    Result := nil;
end;

function TPortableObjectUtf8.tryGetString(const Name: UTF8String; var Value: UTF8String): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsUtf8;
end;

function TPortableObjectUtf8.tryGetUInt64(const Name: UTF8String; var Value: UInt64): Boolean;
var
  Item: PPortableValue;
begin
  Item := FindItem(Name);
  Result := Assigned(Item);
  if Result then
    Value := Item.AsUInt64;
end;

procedure TPortableObjectUtf8.FromSimpleObject(AObject: TObject; ALowerCamelCase: Boolean);
var
  Index, Count: Integer;
  PropList: PPropList;
  PropType: PTypeInfo;
  PropInfo: PPropInfo;
  PropName, sprop: UTF8String;
  V: Variant;
  D: Double;
  Ch: AnsiChar;
begin
  Clear;
  if AObject = nil then
    Exit;
  if AObject.ClassInfo = nil then
    raise EInvalidCast.CreateResFmt(PResStringRec(@RsMissingClassInfo), [AObject.ClassName]);

  Count := GetPropList(AObject, PropList);
  if Count > 0 then
  begin
    try
      for Index := 0 to Count - 1 do
      begin
        PropInfo := PropList[Index];
        if (PropInfo.StoredProc = Pointer($1)) or IsStoredProp(AObject, PropInfo) then
        begin
          PropName := UTF8String(PropInfo.Name);
          if ALowerCamelCase and (PropName <> '') then
          begin
            Ch := PAnsiChar(Pointer(PropName))^;
            if Ord(Ch) < 128 then
            begin
              case Ch of
                'A' .. 'Z':
                  PAnsiChar(Pointer(PropName))^ := AnsiChar(Ord(Ch) xor $20);
              end;
            end;
          end;

          case PropInfo.PropType^.Kind of
            tkInteger, tkChar, tkWChar:
              Add(PropName, GetOrdProp(AObject, PropInfo));

            tkEnumeration:
              begin
                PropType := PropInfo.PropType^;
                if (PropType = TypeInfo(Boolean)) or (PropType = TypeInfo(ByteBool)) or (PropType = TypeInfo(WordBool))
                  or (PropType = TypeInfo(LongBool)) then
                  FastAdd(PropName, GetOrdProp(AObject, PropInfo) <> 0)
                else
                  FastAdd(PropName, GetOrdProp(AObject, PropInfo));
              end;

            tkFloat:
              begin
                PropType := PropInfo.PropType^;
                D := GetFloatProp(AObject, PropInfo);
                if (PropType = TypeInfo(TDateTime)) or (PropType = TypeInfo(TDate)) or (PropType = TypeInfo(TTime)) then
                  FastAdd(PropName, TDateTime(D))
                else
                  FastAdd(PropName, D);
              end;

            tkInt64:
              FastAdd(PropName, GetInt64Prop(AObject, PropInfo));

            tkString, tkLString, tkWString, tkUString:
              begin
                sprop := DSLUtils.UStrToMultiByte(GetStrProp(AObject, PropInfo), CP_UTF8);
                FastAdd(PropName, sprop);
              end;

            tkSet:
              begin
                sprop := DSLUtils.UStrToMultiByte(GetSetProp(AObject, PropInfo), CP_UTF8);
                FastAdd(PropName, sprop);
              end;

            tkVariant:
              begin
                V := GetVariantProp(AObject, PropInfo);
                if VarIsNull(V) then
                  FastAddNull(PropName)
                else if VarIsEmpty(V) then
                  _FastAddItem(PropName).init(sdtNone)
                else
                begin
                  case VarType(V) and varTypeMask of
                    varSingle, varDouble, varCurrency:
                      FastAdd(PropName, Double(V));
                    varShortInt, varSmallInt, varInteger, varByte, varWord:
                      FastAdd(PropName, Integer(V));
                    varLongWord:
                      FastAdd(PropName, Int64(UInt32(V)));
{$IF CompilerVersion >= 23.0} // XE2+
                    varInt64:
                      FastAdd(PropName, Int64(V));
{$IFEND}
                    varBoolean:
                      FastAdd(PropName, Boolean(V));
                  else
                    sprop := UTF8String(V);
                    FastAdd(PropName, sprop);
                  end;
                end;
              end;
          end;
        end;
      end;
    finally
      FreeMem(PropList);
    end;
  end;
end;

procedure TPortableObjectUtf8.FastAdd(var name: UTF8String; Value: UInt64);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObjectUtf8.FastAdd(var name: UTF8String; Value: TDateTime);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObjectUtf8.FastAdd(var name: UTF8String; Value: Int64);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObjectUtf8.FastAdd(var name, Value: UTF8String);
var
  Item: PPortableValue;
begin
  Item := _FastAddItem(Name);
  Item.dataType := sdtUTF8String;
  Item.S := Pointer(Value);
  Pointer(Value) := nil;
end;

procedure TPortableObjectUtf8.FastAdd(var name: UTF8String; Value: Int32);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObjectUtf8.FastAdd(var name: UTF8String; Value: Boolean);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObjectUtf8.FastAdd(var name: UTF8String; Value: Double);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObjectUtf8.FastAdd(var name: UTF8String; Value: TPortableArray);
begin
  _FastAddItem(Name).init(Value)
end;

procedure TPortableObjectUtf8.FastAdd(var name: UTF8String; Value: TPortableObjectUtf8);
begin
  _FastAddItem(Name).init(Value)
end;

function TPortableObjectUtf8.FastAddArray(var Name: UTF8String): TPortableArray;
begin
  Result := TPortableArray.Create;
  _FastAddItem(Name).init(Result);
end;

function TPortableObjectUtf8.FastAddItem(var Name: UTF8String): PPortableValue;
begin
  Result := _FastAddItem(Name);
  Result.init;
end;

function TPortableObjectUtf8._FastAddItem(var Name: UTF8String): PPortableValue;
begin
  if FCount = FCapacity then
    Grow;
  Result := @FItems[FCount];

  UpdateLastValueItem(Pointer(Name), FCount);
  FNames[FCount] := Pointer(Name); // initialize the string
  Pointer(Name) := nil;
  Inc(FCount);
end;

procedure TPortableObjectUtf8.FastAddNull(var name: UTF8String);
begin
  _FastAddItem(Name).init(sdtNull);
end;

function TPortableObjectUtf8.FastAddObject(var Name: UTF8String): TPortableObjectUtf8;
begin
  Result := TPortableObjectUtf8.Create;
  _FastAddItem(Name).init(Result);
end;

function TPortableObjectUtf8.FindItem(const Name: UTF8String): PPortableValue;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx <> -1 then
    Result := @FItems[Idx]
  else
    Result := nil;
end;

procedure TPortableObjectUtf8.Assign(ASource: TPortableObjectUtf8);
var
  I: Integer;
begin
  Clear;
  if ASource <> nil then
  begin
    SetCapacity(ASource.Count);

    FCount := ASource.Count;
    for I := 0 to ASource.Count - 1 do
    begin
      FNames[I] := nil;
      UTF8String(FNames[I]) := UTF8String(ASource.FNames[I]);
      InternInitAndAssignItem(@FItems[I], @ASource.FItems[I]);
    end;
  end
  else
  begin
    FreeMem(FItems);
    FreeMem(FNames);
    FCapacity := 0;
  end;
end;
procedure TPortableObjectUtf8.PathError(P, EndP: PAnsiChar);
var
  S: string;
begin
  S := DSLUtils.BufToUnicode(P, EndP - P, CP_UTF8);
  raise EJsonPathException.CreateResFmt(PResStringRec(@RsInvalidJsonPath), [S]);
end;

procedure TPortableObjectUtf8.PathIndexError(P, EndP: PAnsiChar; Count: Integer);
begin
  raise EJsonPathException.CreateResFmt(PResStringRec(@RsJsonPathIndexError),
    [Count, DSLUtils.BufToUnicode(P, EndP - P, CP_UTF8)]);
end;

procedure TPortableObjectUtf8.PathNullError(P, EndP: PAnsiChar);
begin
  raise EJsonPathException.CreateResFmt(PResStringRec(@RsJsonPathContainsNullValue),
    [DSLUtils.BufToUnicode(P, EndP - P, CP_UTF8)]);
end;

procedure TPortableObjectUtf8.Add(const name: UTF8String; Value: Boolean);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObjectUtf8.Add(const name: UTF8String; Value: TPortableArray);
begin
  _AddItem(Name).init(Value);
end;

procedure TPortableObjectUtf8.Add(const name: UTF8String; Value: TPortableObjectUtf8);
begin
  _AddItem(Name).init(Value);
end;

initialization

{$IFDEF MSWINDOWS}
{$IFDEF SUPPORT_WINDOWS2000}
TzSpecificLocalTimeToSystemTime := GetProcAddress(GetModuleHandle(kernel32),
  PAnsiChar('TzSpecificLocalTimeToSystemTime'));
if not Assigned(TzSpecificLocalTimeToSystemTime) then
  TzSpecificLocalTimeToSystemTime := TzSpecificLocalTimeToSystemTimeWin2000;
{$ENDIF SUPPORT_WINDOWS2000}
{$ENDIF MSWINDOWS}
// Make sTrue and sFalse a mutable string (RefCount<>-1) so that UStrAsg doesn't always
// create a new string.
JSONFormatSettings.DecimalSeparator := '.';

end.
