unit ProtoBuffer;

interface

uses
  SysUtils, Classes, Windows, Contnrs, DSLUtils, Generics.Collections, DSLGenerics;

const
  PB_VARINT_MAX_BYTES = 10;

  ERROR_PB_HUNGRY = -1;
  ERROR_PB_VARINT_OVERFLOW = -2;
  ERROR_PB_INVALID_WIRE_TYPE = -3;
  ERROR_PB_INVALID_FIELD_ID = -4;

  SErr_BufferTooSmall = 'Buffer too small';
  SErr_Overflow = 'Overflow';
  SErr_InvalidVarInt = 'Invalid VarInt';
  SErr_InvalidBuffer = 'Invalid buffer';
  SErr_InvalidStringField = 'Invalid string field';
  SErr_InvalidWireType = 'Invalid wire type';

type
  TpbWireType = (pwtVarInt = 0, pwt64Bit = 1, pwtVarBytes = 2,
    pwtStartGroup = 3, // deprecated
    pwtEndGroup = 4, // deprecated
    pwt32Bit = 5, pwtNotUsed6 = 6, pwtNotUsed7 = 7);

  EpbException = class(Exception)
  private
    FErrorCode: Integer;
  public
    constructor Create(AErrorCode: Integer);
    property ErrorCode: Integer read FErrorCode;
  end;

  EpbVarIntError = class(Exception);
  EpbEncodeError = class(Exception);
  EpbDecodeError = class(Exception);

  TpbVarInt = record
    used: Integer;
    bytes: array [0 .. PB_VARINT_MAX_BYTES - 1] of Byte;
    procedure SetInvalid;
    function valid: Boolean;
    function IsZero: Boolean;
    function equals(const another: TpbVarInt): Boolean;
    procedure zero;
    procedure init(const Buf; BufSize: Integer);
    procedure EncodeUInt32(const value: UInt32);
    procedure EncodeInt32(const value: Int32);
    procedure EncodeUInt64(const value: UInt64);
    procedure EncodeInt64(const value: Int64);
    function ReadBuffer(const Buf; BufSize: Integer): Integer;
    function WriteBuffer(var Buf; BufSize: Integer): Integer; inline;
    function ReadStream(stream: TStream; MaxRead: Integer = 0): Integer;
    function WriteStream(stream: TStream): Integer; inline;
    procedure decode(var Buf; BufSize: Integer);
    function ToUInt32: UInt32;
    function ToInt32: Int32;
    function ToUInt64: UInt64;
    function ToInt64: Int64;
    function GetBytes: RawByteString;
  end;

(* ZigZag conversion *)

function zigzagEncode32(value: Int32): UInt32;
function zigzagDecode32(value: UInt32): Int32;
function zigzagEncode64(value: Int64): UInt64;
function zigzagDecode64(value: UInt64): Int64;

function EncodeFieldHeader(const FieldNumber: UInt32; const WireType: TpbWireType): UInt32;
function DecodeFieldHeader(const A: UInt32; var FieldNumber: UInt32; var WireType: TpbWireType): Boolean;

type
  TProtoBufferEncoder = record
    buf: PAnsiChar;
    len: Integer;
    ptr: PAnsiChar;
    procedure SetBuffer(_buf: PAnsiChar; _len: Integer); inline;
    procedure SetStringBuffer(const s: RawByteString); inline;
    procedure reset;
    function AvailableBytes: Integer; inline;
    function GetDataLength: Integer; inline;
    procedure CheckOverflow; inline;
    procedure WriteHeader(FieldId: UInt32; WireType: TpbWireType); inline;
    procedure WriteVarBytesHeader(FieldId, NumOfBytes: UInt32); inline;
    procedure WriteInt32(FieldId: UInt32; value: Int32);
    procedure WriteUInt32(FieldId: UInt32; value: UInt32);
    procedure WriteInt64(FieldId: UInt32; value: Int64);
    procedure WriteUInt64(FieldId: UInt32; value: UInt64);
    procedure WriteVarInt(FieldId: UInt32; const value: TpbVarInt);
    procedure WriteSingle(FieldId: UInt32; value: Single);
    procedure WriteDouble(FieldId: UInt32; value: Double);
    procedure WriteBytes(FieldId: UInt32; const _buf; _len: Integer);
    procedure WriteRawByteString(FieldId: UInt32; const value: RawByteString); inline;
    procedure WriteUnicodeString(FieldId: UInt32; const value: UnicodeString); inline;
    procedure WriteRecord(FieldId: UInt32; const value: TProtoBufferEncoder); inline;
  end;

  TProtoBufferStreamEncoder = record
    stream: TStream;
    StartPos: Int64;
    CurPos: Int64;
    procedure SetStream(s: TStream); inline;
    procedure reset;
    function GetDataLength: Int64; inline;
    procedure WriteHeader(FieldId: UInt32; WireType: TpbWireType); inline;
    procedure WriteVarBytesHeader(FieldId, NumOfBytes: UInt32); inline;
    procedure WriteInt32(FieldId: UInt32; value: Int32);
    procedure WriteUInt32(FieldId: UInt32; value: UInt32);
    procedure WriteInt64(FieldId: UInt32; value: Int64);
    procedure WriteUInt64(FieldId: UInt32; value: UInt64);
    procedure WriteVarInt(FieldId: UInt32; const value: TpbVarInt);
    procedure WriteSingle(FieldId: UInt32; value: Single);
    procedure WriteDouble(FieldId: UInt32; value: Double);
    procedure WriteBytes(FieldId: UInt32; const _buf; _len: Integer);
    procedure WriteRawByteString(FieldId: UInt32; const value: RawByteString);
    procedure WriteUnicodeString(FieldId: UInt32; const value: UnicodeString);
    procedure WriteRecord(FieldId: UInt32; const value: TProtoBufferStreamEncoder);
  end;

function pbFieldAsInt32(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: Int32): Boolean;
function pbFieldAsUInt32(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: UInt32): Boolean;
function pbFieldAsInt64(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: Int64): Boolean;
function pbFieldAsUInt64(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: UInt64): Boolean;
function pbFieldAsSingle(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: Single): Boolean;
function pbFieldAsDouble(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: Double): Boolean;
function pbFieldAsRBStr(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: RawByteString): Boolean;
function pbFieldAsUStr(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: UnicodeString): Boolean;

type
  TProtoBufferDecoder = record
    buf: PAnsiChar;
    len: Integer;
    function FindField(FieldId: UInt32; var FieldType: TpbWireType): PAnsiChar;
    procedure SetBuffer(_buf: PAnsiChar; _len: Integer); inline;
    procedure SetStringBuffer(const s: RawByteString); inline;
    function TryGetInt32(FieldId: UInt32; var value: Int32): Boolean;
    function TryGetUInt32(FieldId: UInt32; var value: UInt32): Boolean;
    function TryGetInt64(FieldId: UInt32; var value: Int64): Boolean;
    function TryGetUInt64(FieldId: UInt32; var value: UInt64): Boolean;
    function TryGetSingle(FieldId: UInt32; var value: Single): Boolean;
    function TryGetDouble(FieldId: UInt32; var value: Double): Boolean;
    function TryGetRawByteString(FieldId: UInt32; var value: RawByteString): Boolean;
    function TryGetUnicodeString(FieldId: UInt32; var value: UnicodeString): Boolean;
    function TryGetRecord(FieldId: UInt32; var value: TProtoBufferDecoder): Boolean;
    function GetInt32(FieldId: UInt32): Int32;
    function GetUInt32(FieldId: UInt32): UInt32;
    function GetInt64(FieldId: UInt32): Int64;
    function GetUInt64(FieldId: UInt32): UInt64;
    function GetSingle(FieldId: UInt32): Single;
    function GetDouble(FieldId: UInt32): Double;
    function GetRawByteString(FieldId: UInt32): RawByteString;
    function GetUnicodeString(FieldId: UInt32): UnicodeString;
    function GetRecord(FieldId: UInt32): TProtoBufferDecoder;
  end;

function pbFieldAsRecord(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: TProtoBufferDecoder): Boolean;

function pbStreamFieldAsInt32(stream: TStream; _type: TpbWireType; var value: Int32; len: Int64 = 0): Boolean;
function pbStreamFieldAsUInt32(stream: TStream; _type: TpbWireType; var value: UInt32; len: Int64 = 0): Boolean;
function pbStreamFieldAsInt64(stream: TStream; _type: TpbWireType; var value: Int64; len: Int64 = 0): Boolean;
function pbStreamFieldAsUInt64(stream: TStream; _type: TpbWireType; var value: UInt64; len: Int64 = 0): Boolean;
function pbStreamFieldAsSingle(stream: TStream; _type: TpbWireType; var value: Single; len: Int64 = 0): Boolean;
function pbStreamFieldAsDouble(stream: TStream; _type: TpbWireType; var value: Double; len: Int64 = 0): Boolean;
function pbStreamFieldAsRBStr(stream: TStream; _type: TpbWireType; var value: RawByteString; len: Int64 = 0): Boolean;
function pbStreamFieldAsUStr(stream: TStream; _type: TpbWireType; var value: UnicodeString; len: Int64 = 0): Boolean;

type
  TProtoBufferStreamDecoder = record
    stream: TStream;
    StartPos: Int64;
    ObjectSize: Int64;
    function FindField(FieldId: UInt32; var FieldType: TpbWireType): Boolean;
    procedure SetStream(s: TStream; _len: Int64 = 0); inline;
    function GetRemainBytes: Integer; inline;
    function TryGetInt32(FieldId: UInt32; var value: Int32): Boolean;
    function TryGetUInt32(FieldId: UInt32; var value: UInt32): Boolean;
    function TryGetInt64(FieldId: UInt32; var value: Int64): Boolean;
    function TryGetUInt64(FieldId: UInt32; var value: UInt64): Boolean;
    function TryGetSingle(FieldId: UInt32; var value: Single): Boolean;
    function TryGetDouble(FieldId: UInt32; var value: Double): Boolean;
    function TryGetRawByteString(FieldId: UInt32; var value: RawByteString): Boolean;
    function TryGetUnicodeString(FieldId: UInt32; var value: UnicodeString): Boolean;
    function TryGetRecord(FieldId: UInt32; var value: TProtoBufferStreamDecoder): Boolean;
    function GetInt32(FieldId: UInt32): Int32;
    function GetUInt32(FieldId: UInt32): UInt32;
    function GetInt64(FieldId: UInt32): Int64;
    function GetUInt64(FieldId: UInt32): UInt64;
    function GetSingle(FieldId: UInt32): Single;
    function GetDouble(FieldId: UInt32): Double;
    function GetRawByteString(FieldId: UInt32): RawByteString;
    function GetUnicodeString(FieldId: UInt32): UnicodeString;
    function GetRecord(FieldId: UInt32): TProtoBufferStreamDecoder;
  end;

function pbStreamFieldAsRecord(stream: TStream; _type: TpbWireType; var value: TProtoBufferStreamDecoder;
  len: Int64 = 0): Boolean;

type
  TpbValueType = (pbvtInt32, pbvtUInt32, pbvtInt64, pbvtUInt64, pbvtVarInt,
    pbvtRawByteString, pbvtUnicodeString, pbvtSingle, pbvtDouble, pbvtArray,
    pbvtRecord);

  TpbObject = class(TRefCountedObject)
  private
    FID: Integer;
    FName: string;
  protected
    function GetValueType: TpbValueType; virtual; abstract;
  public
    function clone: TpbObject; virtual; abstract;
    property ValueType: TpbValueType read GetValueType;
    property ID: Integer read FID write FID;
    property Name: string read FName write FName;
  end;

  TpbValueObject = class(TpbObject)
  protected
    function GetAsInt32: Int32; virtual; abstract;
    function GetAsInt64: Int64; virtual; abstract;
    function GetAsUInt64: UInt64; virtual; abstract;
    function GetAsRawByteString: RawByteString; virtual; abstract;
    function GetAsUInt32: UInt32; virtual; abstract;
    function GetAsUnicodeString: UnicodeString; virtual; abstract;
    procedure SetAsInt32(const value: Integer); virtual; abstract;
    procedure SetAsInt64(const value: Int64); virtual; abstract;
    procedure SetAsUInt64(const value: UInt64); virtual; abstract;
    procedure SetAsRawByteString(const value: RawByteString); virtual; abstract;
    procedure SetAsUInt32(const value: Cardinal); virtual; abstract;
    procedure SetAsUnicodeString(const value: UnicodeString); virtual; abstract;
    function GetAsFloat: Double; virtual; abstract;
    procedure SetAsFloat(const value: Double); virtual; abstract;
  public
    property AsInt32: Integer read GetAsInt32 write SetAsInt32;
    property AsUInt32: UInt32 read GetAsUInt32 write SetAsUInt32;
    property AsInt64: Int64 read GetAsInt64 write SetAsInt64;
    property AsUInt64: UInt64 read GetAsUInt64 write SetAsUInt64;
    property AsRawByteString: RawByteString read GetAsRawByteString write
      SetAsRawByteString;
    property AsUnicodeString: UnicodeString read GetAsUnicodeString write
      SetAsUnicodeString;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
  end;

  TpbVarIntObject = class(TpbValueObject)
  private
    FValue: TpbVarInt;
  protected
    function GetValueType: TpbValueType; override;
    function GetAsInt32: Int32; override;
    function GetAsInt64: Int64; override;
    function GetAsUInt64: UInt64; override;
    procedure SetAsUInt64(const value: UInt64); override;
    function GetAsRawByteString: RawByteString; override;
    function GetAsUInt32: UInt32; override;
    function GetAsUnicodeString: UnicodeString; override;
    procedure SetAsInt32(const value: Integer); override;
    procedure SetAsInt64(const value: Int64); override;
    procedure SetAsRawByteString(const value: RawByteString); override;
    procedure SetAsUInt32(const value: Cardinal); override;
    procedure SetAsUnicodeString(const value: UnicodeString); override;
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const value: Double); override;
  public
    function clone: TpbObject; override;
  end;

  TpbInt32 = class(TpbValueObject)
  private
    FValue: Integer;
  protected
    function GetValueType: TpbValueType; override;
    function GetAsInt32: Int32; override;
    function GetAsInt64: Int64; override;
    function GetAsRawByteString: RawByteString; override;
    function GetAsUInt32: UInt32; override;
    function GetAsUnicodeString: UnicodeString; override;
    procedure SetAsInt32(const value: Integer); override;
    procedure SetAsInt64(const value: Int64); override;
    procedure SetAsRawByteString(const value: RawByteString); override;
    procedure SetAsUInt32(const value: Cardinal); override;
    procedure SetAsUnicodeString(const value: UnicodeString); override;
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const value: Double); override;
    function GetAsUInt64: UInt64; override;
    procedure SetAsUInt64(const value: UInt64); override;
  public
    function clone: TpbObject; override;
  end;

  TpbSingle = class(TpbValueObject)
  private
    FValue: Single;
  protected
    function GetValueType: TpbValueType; override;
    function GetAsInt32: Int32; override;
    function GetAsInt64: Int64; override;
    function GetAsRawByteString: RawByteString; override;
    function GetAsUInt32: UInt32; override;
    function GetAsUnicodeString: UnicodeString; override;
    procedure SetAsInt32(const value: Integer); override;
    procedure SetAsInt64(const value: Int64); override;
    procedure SetAsRawByteString(const value: RawByteString); override;
    procedure SetAsUInt32(const value: Cardinal); override;
    procedure SetAsUnicodeString(const value: UnicodeString); override;
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const value: Double); override;
    function GetAsUInt64: UInt64; override;
    procedure SetAsUInt64(const value: UInt64); override;
  public
    function clone: TpbObject; override;
  end;

  TpbDouble = class(TpbValueObject)
  private
    FValue: Double;
  protected
    function GetValueType: TpbValueType; override;
    function GetAsInt32: Int32; override;
    function GetAsInt64: Int64; override;
    function GetAsRawByteString: RawByteString; override;
    function GetAsUInt32: UInt32; override;
    function GetAsUnicodeString: UnicodeString; override;
    procedure SetAsInt32(const value: Integer); override;
    procedure SetAsInt64(const value: Int64); override;
    procedure SetAsRawByteString(const value: RawByteString); override;
    procedure SetAsUInt32(const value: Cardinal); override;
    procedure SetAsUnicodeString(const value: UnicodeString); override;
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const value: Double); override;
    function GetAsUInt64: UInt64; override;
    procedure SetAsUInt64(const value: UInt64); override;
  public
    function clone: TpbObject; override;
  end;

  TpbUInt32 = class(TpbValueObject)
  private
    FValue: Cardinal;
  protected
    function GetValueType: TpbValueType; override;
    function GetAsInt32: Int32; override;
    function GetAsInt64: Int64; override;
    function GetAsRawByteString: RawByteString; override;
    function GetAsUInt32: UInt32; override;
    function GetAsUnicodeString: UnicodeString; override;
    procedure SetAsInt32(const value: Integer); override;
    procedure SetAsInt64(const value: Int64); override;
    procedure SetAsRawByteString(const value: RawByteString); override;
    procedure SetAsUInt32(const value: Cardinal); override;
    procedure SetAsUnicodeString(const value: UnicodeString); override;
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const value: Double); override;
    function GetAsUInt64: UInt64; override;
    procedure SetAsUInt64(const value: UInt64); override;
  public
    function clone: TpbObject; override;
  end;

  TpbInt64 = class(TpbValueObject)
  private
    FValue: Int64;
  protected
    function GetValueType: TpbValueType; override;
    function GetAsInt32: Int32; override;
    function GetAsInt64: Int64; override;
    function GetAsRawByteString: RawByteString; override;
    function GetAsUInt32: UInt32; override;
    function GetAsUnicodeString: UnicodeString; override;
    procedure SetAsInt32(const value: Integer); override;
    procedure SetAsInt64(const value: Int64); override;
    procedure SetAsRawByteString(const value: RawByteString); override;
    procedure SetAsUInt32(const value: Cardinal); override;
    procedure SetAsUnicodeString(const value: UnicodeString); override;
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const value: Double); override;
    function GetAsUInt64: UInt64; override;
    procedure SetAsUInt64(const value: UInt64); override;
  public
    function clone: TpbObject; override;
  end;

  TpbUInt64 = class(TpbValueObject)
  private
    FValue: Int64;
  protected
    function GetValueType: TpbValueType; override;
    function GetAsInt32: Int32; override;
    function GetAsInt64: Int64; override;
    function GetAsRawByteString: RawByteString; override;
    function GetAsUInt32: UInt32; override;
    function GetAsUnicodeString: UnicodeString; override;
    procedure SetAsInt32(const value: Integer); override;
    procedure SetAsInt64(const value: Int64); override;
    procedure SetAsRawByteString(const value: RawByteString); override;
    procedure SetAsUInt32(const value: Cardinal); override;
    procedure SetAsUnicodeString(const value: UnicodeString); override;
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const value: Double); override;
    function GetAsUInt64: UInt64; override;
    procedure SetAsUInt64(const value: UInt64); override;
  public
    function clone: TpbObject; override;
  end;

  TpbRawByteString = class(TpbValueObject)
  private
    FValue: RawByteString;
  protected
    function GetValueType: TpbValueType; override;
    function GetAsInt32: Int32; override;
    function GetAsInt64: Int64; override;
    function GetAsRawByteString: RawByteString; override;
    function GetAsUInt32: UInt32; override;
    function GetAsUnicodeString: UnicodeString; override;
    procedure SetAsInt32(const value: Integer); override;
    procedure SetAsInt64(const value: Int64); override;
    procedure SetAsRawByteString(const value: RawByteString); override;
    procedure SetAsUInt32(const value: Cardinal); override;
    procedure SetAsUnicodeString(const value: UnicodeString); override;
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const value: Double); override;
    function GetAsUInt64: UInt64; override;
    procedure SetAsUInt64(const value: UInt64); override;
  public
    function clone: TpbObject; override;
  end;

  TpbUnicodeString = class(TpbValueObject)
  private
    FValue: UnicodeString;
  protected
    function GetValueType: TpbValueType; override;
    function GetAsInt32: Int32; override;
    function GetAsInt64: Int64; override;
    function GetAsRawByteString: RawByteString; override;
    function GetAsUInt32: UInt32; override;
    function GetAsUnicodeString: UnicodeString; override;
    procedure SetAsInt32(const value: Integer); override;
    procedure SetAsInt64(const value: Int64); override;
    procedure SetAsRawByteString(const value: RawByteString); override;
    procedure SetAsUInt32(const value: Cardinal); override;
    procedure SetAsUnicodeString(const value: UnicodeString); override;
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const value: Double); override;
    function GetAsUInt64: UInt64; override;
    procedure SetAsUInt64(const value: UInt64); override;
  public
    function clone: TpbObject; override;
  end;

  TpbRecord = class;

  TpbArray = class(TpbObject)
  private
    FItems: TObjectListEx<TpbObject>;
    function GetRecord(Index: Integer): TpbRecord;
    function GetValue(Index: Integer): TpbValueObject;
    function GetCount: Integer;
    function GetArray(Index: Integer): TpbArray;
  protected
    function GetValueType: TpbValueType; override;
  public
    constructor Create;
    destructor Destroy; override;
    function clone: TpbObject; override;
    procedure Clear;
    function encode(stream: TStream): Integer;
    function ToJson(level: Integer = 0; const indent: UnicodeString = #32#32): UnicodeString;
    function AddSingle(AID: Integer; v: Single): TpbSingle;
    function AddDouble(AID: Integer; v: Double): TpbDouble;
    function AddInt32(v: Integer): TpbInt32;
    function AddUInt32(v: Cardinal): TpbUInt32;
    function AddInt64(v: Int64): TpbInt64;
    function AddUInt64(v: UInt64): TpbUInt64;
    function AddVarInt(const v: TpbVarInt): TpbVarIntObject;
    function AddRawByteString(const v: RawByteString): TpbRawByteString;
    function AddUnicodeString(const v: UnicodeString): TpbUnicodeString;
    procedure Add(obj: TpbObject);
    function AddRecord: TpbRecord; overload;
    procedure AddRecord(v: TpbRecord); overload;
    property Items: TObjectListEx<TpbObject>read FItems;
    property Count: Integer read GetCount;
    property value[Index: Integer]: TpbValueObject read GetValue;
    property R[Index: Integer]: TpbRecord read GetRecord;
    property _Array[Index: Integer]: TpbArray read GetArray;
  end;

  TpbRecord = class(TpbObject)
  private
    FFields: TObjectListEx<TpbObject>;
    function IndexOfField(AID: Integer): Integer;
    function ForceValueType(AID: Integer; AValueType: TpbValueType; const name: string): TpbObject;
    function GetValue(AID: Integer): TpbValueObject;
    function GetRecord(AID: Integer): TpbRecord;
    function GetArray(AID: Integer): TpbArray;
    function GetArrayOf(const name: string): TpbArray;
    function GetROf(const name: string): TpbRecord;
    function GetValueOf(const name: string): TpbValueObject;
    function GetI32(AID: Integer): Int32;
    function GetI32Of(const name: string): Int32;
    function GetI64(AID: Integer): Int64;
    function GetI64Of(const name: string): Int64;
    function GetRBStr(AID: Integer): RawByteString;
    function GetRBStrOf(const name: string): RawByteString;
    function GetUI32(AID: Integer): UInt32;
    function GetUI32Of(const name: string): UInt32;
    function GetUStr(AID: Integer): UnicodeString;
    function GetUStrOf(const name: string): UnicodeString;
    procedure SetI32(AID: Integer; const value: Int32);
    procedure SetI32Of(const name: string; const value: Int32);
    procedure SetI64(AID: Integer; const value: Int64);
    procedure SetI64Of(const name: string; const value: Int64);
    procedure SetRBStr(AID: Integer; const value: RawByteString);
    procedure SetRBStrOf(const name: string; const value: RawByteString);
    procedure SetUI32(AID: Integer; const value: UInt32);
    procedure SetUI32Of(const name: string; const value: UInt32);
    procedure SetUStr(AID: Integer; const value: UnicodeString);
    procedure SetUStrOf(const name: string; const value: UnicodeString);
    function GetUI64(AID: Integer): UInt64;
    procedure SetUI64(AID: Integer; const value: UInt64);
    function GetUI64Of(const name: string): UInt64;
    procedure SetUI64Of(const name: string; const value: UInt64);
    function GetFloat32(AID: Integer): Single;
    procedure SetFloat32(AID: Integer; const Value: Single);
    function GetFloat64(AID: Integer): Double;
    procedure SetFloat64(AID: Integer; const Value: Double);
  protected
    function GetValueType: TpbValueType; override;
    function IndexOfName(const name: string): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function encode(stream: TStream): Integer; overload;
    function encode: RawByteString; overload;
    procedure decode(const s: RawByteString); overload;
    procedure decode(stream: TStream); overload;
    function clone: TpbObject; override;
    function ToJson(level: Integer = 0; const indent: UnicodeString = #32#32)
      : UnicodeString;
    function AddSingle(AID: Integer; v: Single;
      const name: string = ''): TpbSingle;
    function AddDouble(AID: Integer; v: Double;
      const name: string = ''): TpbDouble;
    function AddInt32(AID: Integer; v: Integer;
      const name: string = ''): TpbInt32;
    function AddUInt32(AID: Integer; v: Cardinal;
      const name: string = ''): TpbUInt32;
    function AddInt64(AID: Integer; v: Int64;
      const name: string = ''): TpbInt64;
    function AddUInt64(AID: Integer; v: UInt64;
      const name: string = ''): TpbUInt64;
    function AddVarInt(AID: Integer; const v: TpbVarInt;
      const name: string = ''): TpbVarIntObject;
    function AddRawByteString(AID: Integer; const v: RawByteString;
      const name: string = ''): TpbRawByteString;
    function AddUnicodeString(AID: Integer; const v: UnicodeString;
      const name: string = ''): TpbUnicodeString;
    function AddRecord(AID: Integer; const name: string = ''): TpbRecord;
    procedure Add(v: TpbObject);
    procedure Clear;
    function AddRBStrRecord(AID: Integer; const s: RawByteString): TpbRecord;
    function AddUStrRecord(AID: Integer; const s: UnicodeString): TpbRecord;
    function GetRBStrEx(AID: Integer): RawByteString;
    function GetUStrEx(AID: Integer): UnicodeString;
    function AddBufferRecord(AID: Integer; const s: RawByteString): TpbRecord;
    function FindField(AID: Integer): TpbObject;
    function FindName(const name: string): TpbObject;
    property value[AID: Integer]: TpbValueObject read GetValue;
    property R[AID: Integer]: TpbRecord read GetRecord;
    property ValueOf[const name: string]: TpbValueObject read GetValueOf;
    property ROf[const name: string]: TpbRecord read GetROf;
    property _Array[AID: Integer]: TpbArray read GetArray;
    property _ArrayOf[const name: string]: TpbArray read GetArrayOf;
    property I32[AID: Integer]: Int32 read GetI32 write SetI32;
    property I64[AID: Integer]: Int64 read GetI64 write SetI64;
    property UI32[AID: Integer]: UInt32 read GetUI32 write SetUI32;
    property UI64[AID: Integer]: UInt64 read GetUI64 write SetUI64;
    property Float32[AID: Integer]: Single read GetFloat32 write SetFloat32;
    property Float64[AID: Integer]: Double read GetFloat64 write SetFloat64;
    property RBStr[AID: Integer]: RawByteString read GetRBStr write SetRBStr;
    property UStr[AID: Integer]: UnicodeString read GetUStr write SetUStr;
    property I32Of[const name: string]: Int32 read GetI32Of write SetI32Of;
    property I64Of[const name: string]: Int64 read GetI64Of write SetI64Of;
    property UI32Of[const name: string]: UInt32 read GetUI32Of write SetUI32Of;
    property UI64Of[const name: string]: UInt64 read GetUI64Of write SetUI64Of;
    property RBStrOf[const name: string]
      : RawByteString read GetRBStrOf write SetRBStrOf;
    property UStrOf[const name: string]
      : UnicodeString read GetUStrOf write SetUStrOf;
  end;

function pbDecode(const Buf; BufSize: Integer): TpbRecord; overload;
function pbDecode_s(const s: RawByteString): TpbRecord; overload;
function pbDecodeStream(pbs: TStream; pblen: Int64 = 0): TpbRecord;

procedure SelfTest;

implementation

{$ifdef WIN32}
function zigzagEncode32(value: Int32): UInt32;
var
  tmp: Int32;
begin
  tmp := value;
  asm
    sar value, 31
    shl tmp, 1
  end;

  Result := value xor tmp;
end;
{$else}
function zigzagEncode32(value: Int32): UInt32;
var
  tmp: Int32;
begin
  tmp := value;
  value := value shr 31;
  if tmp < 0 then
    value := value or $fffffffe;
  tmp := tmp shl 1;
  Result := value xor tmp;
end;
{$endif}

function zigzagDecode32(value: UInt32): Int32;
var
  tmp, tmp2: UInt32;
begin
  tmp := value shl 31;
  tmp2 := value shr 1;

  if tmp > 0 then
    Result := (tmp2 xor not tmp) or tmp
  else
    Result := tmp2;
end;

function zigzagEncode64(value: Int64): UInt64;
begin
  Result := (value shl 1) xor sar64(value, 63);
end;

function zigzagDecode64(value: UInt64): Int64;
var
  tmp, tmp2: UInt64;
begin
  tmp := value shl 63;
  tmp2 := value shr 1;

  if tmp > 0 then
    Result := (tmp2 xor not tmp) or tmp
  else
    Result := tmp2;
end;

function EncodeFieldHeader(const FieldNumber: UInt32; const WireType: TpbWireType): UInt32;
begin
  Result := UInt32(WireType) or (FieldNumber shl 3);
end;

function DecodeFieldHeader(const A: UInt32; var FieldNumber: UInt32; var WireType: TpbWireType): Boolean;
var
  tmp: UInt32;
begin
  FieldNumber := A shr 3;
  tmp := A and 7;
  WireType := TpbWireType(tmp);
  Result := tmp < 8;
end;

function CheckString(s: PAnsiChar; len: Integer): Boolean;
var
  I: Integer;
begin
  Result := True;

  for I := 0 to len - 1 do
    if (s[I] > #0) and (s[I] < #32) then
    begin
      Result := False;
      Break;
    end;
end;

function _pbDecode(const Buf; BufSize: Integer; obj: TpbRecord): Integer; forward;

function pbDecodeVarBytes_obj(obj: TpbRecord; FieldId: UInt32;
  bytes: PAnsiChar; len: Integer): Integer;
var
  R: TpbRecord;
  dstlen: Integer;
  ok: Boolean;
begin
  Result := len;

  if len = 0 then
    obj.AddUnicodeString(FieldId, '')
  else begin
    if CheckString(bytes, len) then
    begin
      if CheckCodePage(bytes, len, CP_UTF8, dstlen) then
        obj.AddUnicodeString(FieldId, WinAPI_UTF8Decode(bytes, len))
      else
        obj.AddRawByteString(FieldId, '0x' + MemHex(bytes^, len));
    end
    else begin
      R := TpbRecord.Create;
      R.ID := FieldId;

      try
        ok := _pbDecode(bytes^, len, R) = len;
      except
        ok := False;
      end;

      if ok then obj.Add(R)
      else begin
        R.Free;
        if CheckCodePage(bytes, len, CP_UTF8, dstlen) then
          obj.AddUnicodeString(FieldId, WinAPI_UTF8Decode(bytes, len))
        else
          obj.AddRawByteString(FieldId, '0x' + MemHex(bytes^, len));
      end;
    end;
  end;
end;

function _pbDecode(const Buf; BufSize: Integer; obj: TpbRecord): Integer;
var
  P: PByte;
  L, BytesRead: Integer;
  A: TpbVarInt;
  WireType: TpbWireType;
  FieldId, len: UInt32;
begin
  Result := BufSize;

  if BufSize = 0 then Exit;

  P := @Buf;
  L := BufSize;

  while L > 0 do
  begin
    BytesRead := A.ReadBuffer(P^, L);

    if BytesRead <= 0 then
    begin
      Result := BytesRead;
      Break;
    end;

    Inc(P, BytesRead);
    Dec(L, BytesRead);

    DecodeFieldHeader(A.ToUInt32, FieldId, WireType);

    if FieldId <= 0 then
    begin
      Result := ERROR_PB_INVALID_FIELD_ID;
      Break;
    end;

    case WireType of
      pwt32Bit:
        begin
          if 4 > L then
          begin
            Result := ERROR_PB_HUNGRY;
            Break;
          end
          else begin
            obj.AddSingle(FieldId, PSingle(P)^);
            Inc(P, 4);
            Dec(L, 4);
          end;
        end;

      pwt64Bit:
        begin
          if 8 > L then
          begin
            Result := ERROR_PB_HUNGRY;
            Break;
          end
          else begin
            obj.AddDouble(FieldId, PDouble(P)^);
            Inc(P, 8);
            Dec(L, 8);
          end;
        end;

      pwtVarInt:
        begin
          BytesRead := A.ReadBuffer(P^, L);

          if BytesRead <= 0 then
          begin
            Result := BytesRead;
            Break;
          end
          else begin
            Inc(P, BytesRead);
            Dec(L, BytesRead);
            obj.AddVarInt(FieldId, A);
          end;
        end;

      pwtVarBytes:
        begin
          BytesRead := A.ReadBuffer(P^, L);

          if BytesRead <= 0 then
          begin
            Result := BytesRead;
            Break;
          end
          else begin
            Inc(P, BytesRead);
            Dec(L, BytesRead);
            len := A.ToUInt32;

            if len = 0 then
              obj.AddUnicodeString(FieldId, '')
            else if Integer(len) > L then
            begin
              Result := ERROR_PB_HUNGRY;
              Break;
            end
            else begin
              BytesRead := pbDecodeVarBytes_obj(obj, FieldId, PAnsiChar(P), len);

              if BytesRead <> Integer(len) then
              begin
                Result := BytesRead;
                Break;
              end
            end;

            Inc(P, len);
            Dec(L, len);
          end;
        end
      else begin
        // unrecognised wire type
        Result := ERROR_PB_INVALID_WIRE_TYPE;
        Break;
      end;
    end;
  end;
end;

function pbDecode(const Buf; BufSize: Integer): TpbRecord;
var
  ok: Boolean;
begin
  ok := False;
  Result := TpbRecord.Create;

  try
    ok := _pbDecode(Buf, BufSize, Result) = BufSize;
  finally
    if not ok then
      FreeAndNil(Result);
  end;
end;

function pbDecode_s(const s: RawByteString): TpbRecord;
begin
  Result := pbDecode(Pointer(s)^, Length(s));
end;

function pbDecodeVarBytesFromStream(obj: TpbRecord; FieldId: UInt32;
  pbs: TStream; len: Integer): Integer;
var
  bytes: PAnsiChar;
begin
  if len = 0 then
  begin
    obj.AddUnicodeString(FieldId, '');
    Result := 0;
  end
  else begin
    bytes := PAnsiChar(System.GetMemory(len));
    try
      if pbs.Read(bytes^, len) < len then
        Result := ERROR_PB_HUNGRY
      else
        Result := pbDecodeVarBytes_obj(obj, FieldId, bytes, len);
    finally
      System.FreeMemory(bytes);
    end;
  end;
end;
{$WARNINGS off}
{$HINTS off}

function _pbDecodeStream(pbs: TStream; pbr: TpbRecord; pblen: Int64 = 0): Integer;
var
  BytesRead: Integer;
  A: TpbVarInt;
  WireType: TpbWireType;
  FieldId: UInt32;
  len: UInt32;
  Buf: array [0 .. 7] of AnsiChar;
  StartPos: Int64;
begin
  Result := 0;
  StartPos := pbs.Position;

  if pblen <= 0 then
    pblen := pbs.Size - pbs.Position;

  while Result < pblen do
  begin
    BytesRead := A.ReadStream(pbs, pblen - Result);

    if BytesRead < 0 then
    begin
      Result := BytesRead;
      Break;
    end;

    Inc(Result, BytesRead);

    if BytesRead = 0 then
      Break;
    
    DecodeFieldHeader(A.ToUInt32, FieldId, WireType);

    if FieldId <= 0 then
    begin
      Result := ERROR_PB_INVALID_FIELD_ID;
      Break;
    end;

    case WireType of
      pwt32Bit:
        begin
          if 4 > pbs.Read(Buf, 4) then
          begin
            Result := ERROR_PB_HUNGRY;
            Break;
          end
          else begin
            Inc(Result, 4);
            pbr.AddSingle(FieldId, PSingle(@Buf)^);
          end;
        end;

      pwt64Bit:
        begin
          if 8 > pbs.Read(Buf, 8) then
          begin
            Result := ERROR_PB_HUNGRY;
            Break;
          end
          else begin
            Inc(Result, 8);
            pbr.AddDouble(FieldId, PDouble(@Buf)^);
          end;
        end;

      pwtVarInt:
        begin
          BytesRead := A.ReadStream(pbs);

          if BytesRead <= 0 then
          begin
            Result := BytesRead;
            Break;
          end
          else begin
            Inc(Result, BytesRead);
            pbr.AddVarInt(FieldId, A);
          end;
        end;

      pwtVarBytes:
        begin
          BytesRead := A.ReadStream(pbs);

          if BytesRead <= 0 then
          begin
            Result := BytesRead;
            Break;
          end
          else begin
            Inc(Result, BytesRead);
            len := A.ToUInt32;

            if len = 0 then
              pbr.AddUnicodeString(FieldId, '')
            else begin
              BytesRead := pbDecodeVarBytesFromStream(pbr, FieldId, pbs, len);

              if BytesRead <> Integer(len) then
              begin
                Result := BytesRead;
                Break;
              end
              else begin
                Inc(Result, len);
              end;
            end;
          end;
        end
      else begin
        Result := ERROR_PB_INVALID_WIRE_TYPE;
        Break;
      end;
    end;
  end;
end;
{$WARNINGS on}
{$HINTS on}

function pbDecodeStream(pbs: TStream; pblen: Int64): TpbRecord;
var
  ms: TCustomMemoryStream;
  ok: Boolean;
begin
  if pbs is TCustomMemoryStream then
  begin
    ms := TCustomMemoryStream(pbs);
    Result := pbDecode(PAnsiChar(ms.Memory)[ms.Position], ms.Size - ms.Position);
  end
  else begin
    if pblen <= 0 then
      pblen := pbs.Size - pbs.Position;

    ok := False;
    Result := TpbRecord.Create;
    try
      ok := _pbDecodeStream(pbs, Result, pblen) = pblen;
    finally
      if not ok then
        FreeAndNil(Result);
    end;
  end;
end;

procedure Test2;
var
  pbr: TpbRecord;
  pb, pb2: TProtoBufferDecoder;
  pbs, pbs2: TProtoBufferStreamDecoder;
  stream: TStream;
begin
  pbr := TpbRecord.Create;
  stream := TMemoryStream.Create;

  try
    pbr.AddInt32(1, Random($7fffffff));
    pbr.AddUInt32(2, Random($7fffffff));
    pbr.AddInt64(3, Random($7fffffff));
    pbr.AddUInt64(4, Random($7fffffff));
    pbr.AddSingle(5, Random($7fffffff)/Random($7fffffff));
    pbr.AddDouble(6, Random($7fffffff)/Random($7fffffff));
    pbr.AddRawByteString(7, RandomAlphaDigitRBStr(Random(100)));
    pbr.AddUnicodeString(8, RandomAlphaDigitUStr(Random(100)));

    with pbr.AddRecord(9) do
    begin
      AddInt32(1, Random($7fffffff));
      AddUInt32(2, Random($7fffffff));
      AddInt64(3, Random($7fffffff));
      AddUInt64(4, Random($7fffffff));
      AddSingle(5, Random($7fffffff)/Random($7fffffff));
      AddDouble(6, Random($7fffffff)/Random($7fffffff));
      AddRawByteString(7, RandomAlphaDigitRBStr(Random(100)));
      AddUnicodeString(8, RandomAlphaDigitUStr(Random(100)));
      AddInt32(9, Random($7fffffff));
    end;

    pbr.AddInt32(10, Random($7fffffff));

    pb.SetStringBuffer(pbr.encode);
    Assert(pbr.I32[1] = pb.GetInt32(1));
    Assert(pbr.UI64[4] = pb.GetUInt64(4));
    Assert(pbr.UI32[2] = pb.GetUInt32(2));
    Assert(pbr.Float64[6] = pb.GetDouble(6));
    Assert(pbr.I64[3] = pb.GetInt64(3));
    Assert(pbr.Float32[5] = pb.GetSingle(5));
    Assert(pbr.RBStr[7] = pb.GetRawByteString(7));
    Assert(pbr.UStr[8] = pb.GetUnicodeString(8));
    Assert(pbr.I32[10] = pb.GetInt32(10));

    pb2 := pb.GetRecord(9);

    Assert(pbr.R[9].I32[1] = pb2.GetInt32(1));
    Assert(pbr.R[9].UI64[4] = pb2.GetUInt64(4));
    Assert(pbr.R[9].UI32[2] = pb2.GetUInt32(2));
    Assert(pbr.R[9].Float64[6] = pb2.GetDouble(6));
    Assert(pbr.R[9].I64[3] = pb2.GetInt64(3));
    Assert(pbr.R[9].Float32[5] = pb2.GetSingle(5));
    Assert(pbr.R[9].RBStr[7] = pb2.GetRawByteString(7));
    Assert(pbr.R[9].UStr[8] = pb2.GetUnicodeString(8));
    Assert(pbr.R[9].I32[9] = pb2.GetInt32(9));

    pbr.encode(stream);
    stream.Position := 0;

    pbs.SetStream(stream, stream.Size);
    Assert(pbr.I32[1] = pbs.GetInt32(1));
    Assert(pbr.UI64[4] = pbs.GetUInt64(4));
    Assert(pbr.UI32[2] = pbs.GetUInt32(2));
    Assert(pbr.Float64[6] = pbs.GetDouble(6));
    Assert(pbr.I64[3] = pbs.GetInt64(3));
    Assert(pbr.Float32[5] = pbs.GetSingle(5));
    Assert(pbr.RBStr[7] = pbs.GetRawByteString(7));
    Assert(pbr.UStr[8] = pbs.GetUnicodeString(8));
    Assert(pbr.I32[10] = pbs.GetInt32(10));

    pbs2 := pbs.GetRecord(9);

    Assert(pbr.R[9].I32[1] = pbs2.GetInt32(1));
    Assert(pbr.R[9].UI64[4] = pbs2.GetUInt64(4));
    Assert(pbr.R[9].UI32[2] = pbs2.GetUInt32(2));
    Assert(pbr.R[9].Float64[6] = pbs2.GetDouble(6));
    Assert(pbr.R[9].I64[3] = pbs2.GetInt64(3));
    Assert(pbr.R[9].Float32[5] = pbs2.GetSingle(5));
    Assert(pbr.R[9].RBStr[7] = pbs2.GetRawByteString(7));
    Assert(pbr.R[9].UStr[8] = pbs2.GetUnicodeString(8));
    Assert(pbr.R[9].I32[9] = pbs2.GetInt32(9));

  finally
    pbr.Free;
    stream.Free;
  end;
end;

procedure Test3;
var
  pbe: TProtoBufferEncoder;
  pbse: TProtoBufferStreamEncoder;
  pbs: TProtoBufferStreamDecoder;
  pb: TProtoBufferDecoder;
  stream: TStream;
  f1, f10: Int32;
  f2: UInt32;
  f3: Int64;
  f4: UInt64;
  f5: Single;
  f6: Double;
  f7: RawByteString;
  f8: UnicodeString;
  buf: PAnsiChar;
  BufLen: Integer;
begin
  stream := TMemoryStream.Create;
  try
    f1 := Random($7fffffff);
    f2 := Random($7fffffff);
    f3 := Random($7fffffff);
    f4 := Random($7fffffff);
    f10 := Random($7fffffff);
    f5 := Random($7fffffff)/Random($7fffffff);
    f6 := Random($7fffffff)/Random($7fffffff);
    f7 := RandomAlphaDigitRBStr(Random(100));
    f8 := RandomAlphaDigitUStr(Random(100));

    pbe.SetBuffer(nil, 0);
    pbe.WriteInt32(1, f1);
    pbe.WriteUInt32(2, f2);
    pbe.WriteInt64(3, f3);
    pbe.WriteUInt64(4, f4);
    pbe.WriteSingle(5, f5);
    pbe.WriteDouble(6, f6);
    pbe.WriteRawByteString(7, f7);
    pbe.WriteUnicodeString(8, f8);
    pbe.WriteInt32(10, f10);

    BufLen := pbe.GetDataLength;
    buf := System.GetMemory(BufLen);
    pbe.SetBuffer(buf, BufLen);

    pbe.WriteInt32(1, f1);
    pbe.WriteUInt32(2, f2);
    pbe.WriteInt64(3, f3);
    pbe.WriteUInt64(4, f4);
    pbe.WriteSingle(5, f5);
    pbe.WriteDouble(6, f6);
    pbe.WriteRawByteString(7, f7);
    pbe.WriteUnicodeString(8, f8);
    pbe.WriteInt32(10, f10);

    pb.SetBuffer(buf, pbe.GetDataLength);

    Assert(f1 = pb.GetInt32(1));
    Assert(f4 = pb.GetUInt64(4));
    Assert(f2 = pb.GetUInt32(2));
    Assert(f6 = pb.GetDouble(6));
    Assert(f3 = pb.GetInt64(3));
    Assert(f5 = pb.GetSingle(5));
    Assert(f8 = pb.GetUnicodeString(8));
    Assert(f7 = pb.GetRawByteString(7));
    Assert(f10 = pb.GetInt32(10));

    pbse.SetStream(stream);
    pbse.WriteInt32(1, f1);
    pbse.WriteUInt32(2, f2);
    pbse.WriteInt64(3, f3);
    pbse.WriteUInt64(4, f4);
    pbse.WriteSingle(5, f5);
    pbse.WriteDouble(6, f6);
    pbse.WriteRawByteString(7, f7);
    pbse.WriteUnicodeString(8, f8);
    //pbse.WriteInt32(10, f10);

    stream.Position := 0;
    pbs.SetStream(stream, 0);
    Assert(f1 = pbs.GetInt32(1));
    Assert(f4 = pbs.GetUInt64(4));
    Assert(f2 = pbs.GetUInt32(2));
    Assert(f6 = pbs.GetDouble(6));
    Assert(f3 = pbs.GetInt64(3));
    Assert(f5 = pbs.GetSingle(5));
    Assert(f8 = pbs.GetUnicodeString(8));
    Assert(f7 = pbs.GetRawByteString(7));
    //Assert(f10 = pbs.GetInt32(10));
  finally
    stream.Free;
    System.FreeMemory(pb.buf);
  end;
end;

procedure SelfTest;
begin
  Test2;
  Test3;
end;

{ TpbInt32 }

function TpbInt32.clone: TpbObject;
begin
  Result := TpbInt32.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  TpbInt32(Result).FValue := Self.FValue;
end;

function TpbInt32.GetAsFloat: Double;
begin
  Result := FValue;
end;

function TpbInt32.GetAsInt32: Int32;
begin
  Result := FValue;
end;

function TpbInt32.GetAsInt64: Int64;
begin
  Result := FValue;
end;

function TpbInt32.GetAsRawByteString: RawByteString;
begin
  Result := IntToRBStr(FValue);
end;

function TpbInt32.GetAsUInt32: UInt32;
begin
  Result := Cardinal(FValue);
end;

function TpbInt32.GetAsUInt64: UInt64;
begin
  Result := FValue;
end;

function TpbInt32.GetAsUnicodeString: UnicodeString;
begin
  Result := IntToStr(FValue);
end;

function TpbInt32.GetValueType: TpbValueType;
begin
  Result := pbvtInt32;
end;

procedure TpbInt32.SetAsFloat(const value: Double);
begin
  FValue := Round(value);
end;

procedure TpbInt32.SetAsInt32(const value: Integer);
begin
  inherited;
  FValue := value;
end;

procedure TpbInt32.SetAsInt64(const value: Int64);
begin
  inherited;
  FValue := value;
end;

procedure TpbInt32.SetAsRawByteString(const value: RawByteString);
begin
  inherited;
  FValue := RBStrToInt(value);
end;

procedure TpbInt32.SetAsUInt32(const value: Cardinal);
begin
  inherited;
  FValue := Integer(value);
end;

procedure TpbInt32.SetAsUInt64(const value: UInt64);
begin
  FValue := value;
end;

procedure TpbInt32.SetAsUnicodeString(const value: UnicodeString);
begin
  inherited;
  FValue := StrToInt(value);
end;

{ TpbUInt32 }

function TpbUInt32.clone: TpbObject;
begin
  Result := TpbUInt32.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  TpbUInt32(Result).FValue := Self.FValue;
end;

function TpbUInt32.GetAsFloat: Double;
begin
  Result := FValue;
end;

function TpbUInt32.GetAsInt32: Int32;
begin
  Result := Integer(FValue);
end;

function TpbUInt32.GetAsInt64: Int64;
begin
  Result := FValue;
end;

function TpbUInt32.GetAsRawByteString: RawByteString;
begin
  Result := IntToRBStr(Int64(FValue));
end;

function TpbUInt32.GetAsUInt32: UInt32;
begin
  Result := FValue;
end;

function TpbUInt32.GetAsUInt64: UInt64;
begin
  Result := FValue;
end;

function TpbUInt32.GetAsUnicodeString: UnicodeString;
begin
  Result := IntToStr(Int64(FValue));
end;

function TpbUInt32.GetValueType: TpbValueType;
begin
  Result := pbvtUInt32;
end;

procedure TpbUInt32.SetAsFloat(const value: Double);
begin
  FValue := Round(value);
end;

procedure TpbUInt32.SetAsInt32(const value: Integer);
begin
  FValue := Cardinal(value);
end;

procedure TpbUInt32.SetAsInt64(const value: Int64);
begin
  FValue := value;
end;

procedure TpbUInt32.SetAsRawByteString(const value: RawByteString);
begin
  FValue := RBStrToInt64(value);
end;

procedure TpbUInt32.SetAsUInt32(const value: Cardinal);
begin
  FValue := value;
end;

procedure TpbUInt32.SetAsUInt64(const value: UInt64);
begin
  FValue := value;
end;

procedure TpbUInt32.SetAsUnicodeString(const value: UnicodeString);
begin
  FValue := StrToInt64(value);
end;

{ TpbInt64 }

function TpbInt64.clone: TpbObject;
begin
  Result := TpbInt64.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  TpbInt64(Result).FValue := Self.FValue;
end;

function TpbInt64.GetAsFloat: Double;
begin
  Result := FValue;
end;

function TpbInt64.GetAsInt32: Int32;
begin
  Result := FValue;
end;

function TpbInt64.GetAsInt64: Int64;
begin
  Result := FValue;
end;

function TpbInt64.GetAsRawByteString: RawByteString;
begin
  Result := IntToRBStr(FValue);
end;

function TpbInt64.GetAsUInt32: UInt32;
begin
  Result := FValue;
end;

function TpbInt64.GetAsUInt64: UInt64;
begin
  Result := FValue;
end;

function TpbInt64.GetAsUnicodeString: UnicodeString;
begin
  Result := IntToStr(FValue);
end;

function TpbInt64.GetValueType: TpbValueType;
begin
  Result := pbvtInt64;
end;

procedure TpbInt64.SetAsFloat(const value: Double);
begin
  FValue := Round(value);
end;

procedure TpbInt64.SetAsInt32(const value: Integer);
begin
  FValue := value;
end;

procedure TpbInt64.SetAsInt64(const value: Int64);
begin
  FValue := value;
end;

procedure TpbInt64.SetAsRawByteString(const value: RawByteString);
begin
  FValue := RBStrToInt64(value);
end;

procedure TpbInt64.SetAsUInt32(const value: Cardinal);
begin
  FValue := value;
end;

procedure TpbInt64.SetAsUInt64(const value: UInt64);
begin
  FValue := value;
end;

procedure TpbInt64.SetAsUnicodeString(const value: UnicodeString);
begin
  FValue := StrToInt64(value);
end;

{ TpbRawByteString }

function TpbRawByteString.clone: TpbObject;
begin
  Result := TpbRawByteString.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  TpbRawByteString(Result).FValue := Self.FValue;
end;

function TpbRawByteString.GetAsFloat: Double;
begin
  Result := RBStrToFloat(FValue);
end;

function TpbRawByteString.GetAsInt32: Int32;
begin
  Result := RBStrToInt(FValue);
end;

function TpbRawByteString.GetAsInt64: Int64;
begin
  Result := RBStrToInt64(FValue);
end;

function TpbRawByteString.GetAsRawByteString: RawByteString;
begin
  Result := FValue;
end;

function TpbRawByteString.GetAsUInt32: UInt32;
begin
  Result := RBStrToInt64(FValue);
end;

function TpbRawByteString.GetAsUInt64: UInt64;
begin
  Result := RBStrToInt64(FValue);
end;

function TpbRawByteString.GetAsUnicodeString: UnicodeString;
begin
  Result := UnicodeString(FValue);
end;

function TpbRawByteString.GetValueType: TpbValueType;
begin
  Result := pbvtRawByteString;
end;

procedure TpbRawByteString.SetAsFloat(const value: Double);
begin
  FValue := RawByteString(FloatToStr(value));
end;

procedure TpbRawByteString.SetAsInt32(const value: Integer);
begin
  FValue := IntToRBStr(value);
end;

procedure TpbRawByteString.SetAsInt64(const value: Int64);
begin
  FValue := IntToRBStr(value);
end;

procedure TpbRawByteString.SetAsRawByteString(const value: RawByteString);
begin
  FValue := value;
end;

procedure TpbRawByteString.SetAsUInt32(const value: Cardinal);
begin
  FValue := IntToRBStr(Int64(value));
end;

procedure TpbRawByteString.SetAsUInt64(const value: UInt64);
begin
  FValue := IntToRBStr(value);
end;

procedure TpbRawByteString.SetAsUnicodeString(const value: UnicodeString);
begin
  FValue := RawByteString(value);
end;

{ TpbUnicodeString }

function TpbUnicodeString.clone: TpbObject;
begin
  Result := TpbUnicodeString.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  TpbUnicodeString(Result).FValue := Self.FValue;
end;

function TpbUnicodeString.GetAsFloat: Double;
begin
  Result := StrToFloat(FValue);
end;

function TpbUnicodeString.GetAsInt32: Int32;
begin
  Result := StrToInt(FValue);
end;

function TpbUnicodeString.GetAsInt64: Int64;
begin
  Result := StrToInt64(FValue);
end;

function TpbUnicodeString.GetAsRawByteString: RawByteString;
begin
  Result := RawByteString(FValue);
end;

function TpbUnicodeString.GetAsUInt32: UInt32;
begin
  Result := StrToInt64(FValue);
end;

function TpbUnicodeString.GetAsUInt64: UInt64;
begin
  Result := UStrToInt64(FValue);
end;

function TpbUnicodeString.GetAsUnicodeString: UnicodeString;
begin
  Result := FValue;
end;

function TpbUnicodeString.GetValueType: TpbValueType;
begin
  Result := pbvtUnicodeString;
end;

procedure TpbUnicodeString.SetAsFloat(const value: Double);
begin
  FValue := UnicodeString(FloatToStr(value));
end;

procedure TpbUnicodeString.SetAsInt32(const value: Integer);
begin
  FValue := IntToStr(value);
end;

procedure TpbUnicodeString.SetAsInt64(const value: Int64);
begin
  FValue := IntToStr(value);
end;

procedure TpbUnicodeString.SetAsRawByteString(const value: RawByteString);
begin
  FValue := UnicodeString(value);
end;

procedure TpbUnicodeString.SetAsUInt32(const value: Cardinal);
begin
  FValue := IntToStr(Int64(value));
end;

procedure TpbUnicodeString.SetAsUInt64(const value: UInt64);
begin
  FValue := IntToUStr(value);
end;

procedure TpbUnicodeString.SetAsUnicodeString(const value: UnicodeString);
begin
  FValue := value;
end;

{ TpbRecord }

function TpbRecord.AddBufferRecord(AID: Integer;
  const s: RawByteString): TpbRecord;
begin
  Result := Self.AddRecord(AID);
  Result.AddUInt32(1, Length(s));
  Result.AddRawByteString(2, s);
end;

function TpbRecord.AddDouble(AID: Integer; v: Double;
  const name: string): TpbDouble;
begin
  Result := TpbDouble(ForceValueType(AID, pbvtDouble, name));
  Result.AsFloat := v;
end;

function TpbRecord.AddInt32(AID, v: Integer; const name: string): TpbInt32;
begin
  Result := TpbInt32(ForceValueType(AID, pbvtInt32, name));
  Result.AsInt32 := v;
end;

function TpbRecord.AddInt64(AID: Integer; v: Int64;
  const name: string): TpbInt64;
begin
  Result := TpbInt64(ForceValueType(AID, pbvtInt64, name));
  Result.AsInt64 := v;
end;

procedure TpbRecord.Add(v: TpbObject);
var
  idx: Integer;
  obj: TpbObject;
  arr: TpbArray;
begin
  idx := IndexOfField(v.ID);

  if idx = -1 then
  begin
    FFields.Add(v);
  end
  else
  begin
    obj := TpbObject(FFields[idx]);

    if obj.ValueType <> pbvtArray then
    begin
      arr := TpbArray.Create;
      arr.ID := v.ID;
      FFields.Extract(obj);
      arr.Add(obj);
      FFields.Add(arr);
    end
    else
      arr := TpbArray(obj);

    arr.Add(v);
  end;
end;

function TpbRecord.AddRecord(AID: Integer; const name: string): TpbRecord;
begin
  Result := TpbRecord(ForceValueType(AID, pbvtRecord, name));
end;

function TpbRecord.AddRawByteString(AID: Integer; const v: RawByteString;
  const name: string): TpbRawByteString;
begin
  Result := TpbRawByteString(ForceValueType(AID, pbvtRawByteString, name));
  Result.AsRawByteString := v;
end;

function TpbRecord.AddRBStrRecord(AID: Integer;
  const s: RawByteString): TpbRecord;
begin
  Result := Self.AddRecord(AID);
  Result.AddRawByteString(1, s);
end;

function TpbRecord.AddSingle(AID: Integer; v: Single;
  const name: string): TpbSingle;
begin
  Result := TpbSingle(ForceValueType(AID, pbvtSingle, name));
  Result.AsFloat := v;
end;

function TpbRecord.AddUInt32(AID: Integer; v: Cardinal;
  const name: string): TpbUInt32;
begin
  Result := TpbUInt32(ForceValueType(AID, pbvtUInt32, name));
  Result.AsUInt32 := v;
end;

function TpbRecord.AddUInt64(AID: Integer; v: UInt64;
  const name: string): TpbUInt64;
begin
  Result := TpbUInt64(ForceValueType(AID, pbvtUInt64, name));
  Result.AsUInt64 := v;
end;

function TpbRecord.AddUnicodeString(AID: Integer; const v: UnicodeString;
  const name: string): TpbUnicodeString;
begin
  Result := TpbUnicodeString(ForceValueType(AID, pbvtUnicodeString, name));
  Result.AsUnicodeString := v;
end;

function TpbRecord.AddUStrRecord(AID: Integer;
  const s: UnicodeString): TpbRecord;
begin
  Result := Self.AddRecord(AID);
  Result.AddUnicodeString(1, s);
end;

function TpbRecord.AddVarInt(AID: Integer; const v: TpbVarInt;
  const name: string): TpbVarIntObject;
begin
  Result := TpbVarIntObject(ForceValueType(AID, pbvtVarInt, name));
  Result.FValue := v;
end;

procedure TpbRecord.Clear;
begin
  FFields.Clear;
end;

function TpbRecord.clone: TpbObject;
var
  I: Integer;
begin
  Result := TpbRecord.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  for I := 0 to FFields.Count - 1 do
    TpbRecord(Result).FFields.Add(TpbObject(FFields[I]).clone);
end;

constructor TpbRecord.Create;
begin
  inherited Create;
  FFields := TObjectListEx<TpbObject>.Create(True);
end;

procedure TpbRecord.decode(stream: TStream);
begin
  Self.Clear;
  _pbDecodeStream(stream, Self);
end;

procedure TpbRecord.decode(const s: RawByteString);
begin
  Self.Clear;
  _pbDecode(Pointer(s)^, Length(s), Self);
end;

destructor TpbRecord.Destroy;
begin
  FFields.Free;
  inherited;
end;

function TpbRecord.encode: RawByteString;
var
  ms: TRawByteStringStream;
begin
  ms := TRawByteStringStream.Create('');

  try
    Self.encode(ms);
    Result := ms.DataString;
  finally
    ms.Free;
  end;
end;

function TpbRecord.encode(stream: TStream): Integer;
var
  I: Integer;
  Field: TpbObject;
  encoder: TProtoBufferStreamEncoder;
begin
  encoder.SetStream(stream);

  for I := 0 to FFields.Count - 1 do
  begin
    Field := TpbObject(FFields[I]);

    case Field.GetValueType of
      pbvtSingle: encoder.WriteSingle(Field.ID, TpbSingle(Field).FValue);
      pbvtDouble: encoder.WriteDouble(Field.ID, TpbDouble(Field).FValue);
      pbvtInt32: encoder.WriteInt32(Field.ID, TpbInt32(Field).FValue);
      pbvtUInt32: encoder.WriteUInt32(Field.ID, TpbUInt32(Field).FValue);
      pbvtInt64: encoder.WriteInt64(Field.ID, TpbInt64(Field).FValue);
      pbvtUInt64: encoder.WriteUInt64(Field.ID,  TpbUInt64(Field).FValue);
      pbvtVarInt: encoder.WriteVarInt(Field.ID, TpbVarIntObject(Field).FValue);
      pbvtRawByteString: encoder.WriteRawByteString(Field.ID, TpbRawByteString(Field).FValue);
      pbvtUnicodeString: encoder.WriteUnicodeString(Field.ID, TpbUnicodeString(Field).FValue);
      pbvtArray: TpbArray(Field).encode(stream);

      pbvtRecord:
        begin
          encoder.WriteVarBytesHeader(Field.ID, TpbRecord(Field).encode(nil));
          Inc(encoder.CurPos, TpbRecord(Field).encode(stream));
        end;
    end;
  end;

  Result := encoder.GetDataLength;
end;

function TpbRecord.FindField(AID: Integer): TpbObject;
var
  I: Integer;
  tmp: TpbObject;
begin
  Result := nil;

  for I := 0 to FFields.Count - 1 do
  begin
    tmp := TpbObject(FFields[I]);

    if tmp.ID = AID then
    begin
      Result := tmp;
      Break;
    end;
  end;
end;

function TpbRecord.FindName(const name: string): TpbObject;
var
  I: Integer;
  tmp: TpbObject;
begin
  Result := nil;

  for I := 0 to FFields.Count - 1 do
  begin
    tmp := TpbObject(FFields[I]);

    if SameText(tmp.Name, name) then
    begin
      Result := tmp;
      Break;
    end;
  end;
end;

function pbCreateObject(AValueType: TpbValueType): TpbObject;
begin
  case AValueType of
    pbvtSingle:
      Result := TpbSingle.Create;
    pbvtDouble:
      Result := TpbDouble.Create;
    pbvtInt32:
      Result := TpbInt32.Create;
    pbvtUInt32:
      Result := TpbUInt32.Create;
    pbvtInt64:
      Result := TpbInt64.Create;
    pbvtUInt64:
      Result := TpbUInt64.Create;
    pbvtVarInt:
      Result := TpbVarIntObject.Create;
    pbvtRawByteString:
      Result := TpbRawByteString.Create;
    pbvtUnicodeString:
      Result := TpbUnicodeString.Create;
    pbvtRecord:
      Result := TpbRecord.Create;
  else
    Result := nil;
  end;
end;

function TpbRecord.ForceValueType(AID: Integer; AValueType: TpbValueType;
  const name: string): TpbObject;
begin
  Result := pbCreateObject(AValueType);
  Result.ID := AID;
  Result.Name := name;
  Self.Add(Result);
end;

function TpbRecord.GetArray(AID: Integer): TpbArray;
begin
  Result := TpbArray(FindField(AID));
end;

function TpbRecord.GetArrayOf(const name: string): TpbArray;
begin
  Result := TpbArray(FindName(name));
end;

function TpbRecord.GetFloat32(AID: Integer): Single;
var
  tmp: TpbObject;
begin
  tmp := FindField(AID);

  if Assigned(tmp) and (tmp is TpbValueObject) then
    Result := TpbValueObject(tmp).AsFloat
  else
    Result := 0;
end;

function TpbRecord.GetFloat64(AID: Integer): Double;
var
  tmp: TpbObject;
begin
  tmp := FindField(AID);

  if Assigned(tmp) and (tmp is TpbValueObject) then
    Result := TpbValueObject(tmp).AsFloat
  else
    Result := 0;
end;

function TpbRecord.GetI32(AID: Integer): Int32;
var
  tmp: TpbObject;
begin
  tmp := FindField(AID);

  if Assigned(tmp) then
    Result := TpbValueObject(tmp).AsInt32
  else
    Result := 0;
end;

function TpbRecord.GetI32Of(const name: string): Int32;
var
  tmp: TpbObject;
begin
  tmp := FindName(name);

  if Assigned(tmp) then
    Result := TpbValueObject(tmp).AsInt32
  else
    Result := 0;
end;

function TpbRecord.GetI64(AID: Integer): Int64;
var
  tmp: TpbObject;
begin
  tmp := FindField(AID);

  if Assigned(tmp) then
    Result := TpbValueObject(tmp).AsInt64
  else
    Result := 0;
end;

function TpbRecord.GetI64Of(const name: string): Int64;
var
  tmp: TpbObject;
begin
  tmp := FindName(name);

  if Assigned(tmp) then
    Result := TpbValueObject(tmp).AsInt64
  else
    Result := 0;
end;

function TpbRecord.GetRecord(AID: Integer): TpbRecord;
begin
  Result := TpbRecord(FindField(AID));
end;

function TpbRecord.GetROf(const name: string): TpbRecord;
begin
  Result := TpbRecord(FindName(name));
end;

function TpbRecord.GetRBStr(AID: Integer): RawByteString;
var
  pbo: TpbValueObject;
begin
  pbo := TpbValueObject(FindField(AID));

  if Assigned(pbo) then
    Result := pbo.AsRawByteString
  else
    Result := '';
end;

function TpbRecord.GetRBStrEx(AID: Integer): RawByteString;
var
  tmp: TpbObject;
begin
  tmp := Self.FindField(AID);

  if Assigned(tmp) then
  begin
    if tmp is TpbValueObject then
      Result := TpbValueObject(tmp).AsRawByteString
    else if tmp is TpbRecord then
      Result := TpbRecord(tmp).GetRBStrEx(1)
    else
      Result := '';
  end
  else
    Result := '';
end;

function TpbRecord.GetRBStrOf(const name: string): RawByteString;
var
  tmp: TpbObject;
begin
  tmp := FindName(name);

  if Assigned(tmp) and (tmp is TpbValueObject) then
    Result := TpbValueObject(tmp).AsRawByteString
  else
    Result := '';
end;

function TpbRecord.GetUI32(AID: Integer): UInt32;
var
  tmp: TpbObject;
begin
  tmp := FindField(AID);

  if Assigned(tmp) and (tmp is TpbValueObject) then
    Result := TpbValueObject(tmp).AsUInt32
  else
    Result := 0;
end;

function TpbRecord.GetUI32Of(const name: string): UInt32;
var
  tmp: TpbObject;
begin
  tmp := FindName(name);

  if Assigned(tmp) and (tmp is TpbValueObject) then
    Result := TpbValueObject(tmp).AsUInt32
  else
    Result := 0;
end;

function TpbRecord.GetUI64(AID: Integer): UInt64;
var
  tmp: TpbObject;
begin
  tmp := FindField(AID);

  if Assigned(tmp) then
    Result := TpbValueObject(tmp).AsUInt64
  else
    Result := 0;
end;

function TpbRecord.GetUI64Of(const name: string): UInt64;
var
  tmp: TpbObject;
begin
  tmp := FindName(name);

  if Assigned(tmp) and (tmp is TpbValueObject) then
    Result := TpbValueObject(tmp).AsUInt64
  else
    Result := 0;
end;

function TpbRecord.GetUStr(AID: Integer): UnicodeString;
var
  tmp: TpbObject;
begin
  tmp := FindField(AID);

  if Assigned(tmp) and (tmp is TpbValueObject) then
    Result := TpbValueObject(tmp).AsUnicodeString
  else
    Result := '';
end;

function TpbRecord.GetUStrEx(AID: Integer): UnicodeString;
var
  tmp: TpbObject;
begin
  tmp := Self.FindField(AID);

  if Assigned(tmp) then
  begin
    if tmp is TpbValueObject then
      Result := TpbValueObject(tmp).AsUnicodeString
    else if tmp is TpbRecord then
      Result := TpbRecord(tmp).GetUStrEx(1)
    else
      Result := '';
  end
  else
    Result := '';
end;

function TpbRecord.GetUStrOf(const name: string): UnicodeString;
var
  tmp: TpbObject;
begin
  tmp := FindName(name);

  if Assigned(tmp) and (tmp is TpbValueObject) then
    Result := TpbValueObject(tmp).AsUnicodeString
  else
    Result := '';
end;

function TpbRecord.GetValue(AID: Integer): TpbValueObject;
begin
  Result := TpbValueObject(FindField(AID));
end;

function TpbRecord.GetValueOf(const name: string): TpbValueObject;
begin
  Result := TpbValueObject(FindName(name));
end;

function TpbRecord.GetValueType: TpbValueType;
begin
  Result := pbvtRecord;
end;

function TpbRecord.IndexOfField(AID: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to FFields.Count - 1 do
    if TpbObject(FFields[I]).ID = AID then
    begin
      Result := I;
      Break;
    end;
end;

function TpbRecord.IndexOfName(const name: string): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to FFields.Count - 1 do
    if SameText(TpbObject(FFields[I]).Name, name) then
    begin
      Result := I;
      Break;
    end;
end;

procedure TpbRecord.SetFloat32(AID: Integer; const Value: Single);
var
  vo: TpbObject;
begin
  vo := FindName(name);

  if Assigned(vo) then
    TpbValueObject(vo).AsFloat := value
  else
    Self.AddSingle(AID, Value);
end;

procedure TpbRecord.SetFloat64(AID: Integer; const Value: Double);
var
  vo: TpbObject;
begin
  vo := FindName(name);

  if Assigned(vo) then
    TpbValueObject(vo).AsFloat := value
  else
    Self.AddDouble(AID, Value);
end;

procedure TpbRecord.SetI32(AID: Integer; const value: Int32);
var
  vo: TpbObject;
begin
  vo := FindField(AID);

  if Assigned(vo) then
    TpbValueObject(vo).AsInt32 := value
  else
    Self.AddInt32(AID, value);
end;

procedure TpbRecord.SetI32Of(const name: string; const value: Int32);
var
  vo: TpbObject;
begin
  vo := FindName(name);
  if Assigned(vo) then
    TpbValueObject(vo).AsInt32 := value;
end;

procedure TpbRecord.SetI64(AID: Integer; const value: Int64);
var
  vo: TpbObject;
begin
  vo := FindField(AID);

  if Assigned(vo) then
    TpbValueObject(vo).AsInt64 := value
  else
    Self.AddInt64(AID, value);
end;

procedure TpbRecord.SetI64Of(const name: string; const value: Int64);
var
  vo: TpbObject;
begin
  vo := FindName(name);

  if Assigned(vo) then
    TpbValueObject(vo).AsInt64 := value;
end;

procedure TpbRecord.SetRBStr(AID: Integer; const value: RawByteString);
var
  vo: TpbObject;
begin
  vo := FindField(AID);

  if Assigned(vo) then
    TpbValueObject(vo).AsRawByteString := value
  else
    Self.AddRawByteString(AID, value);
end;

procedure TpbRecord.SetRBStrOf(const name: string; const value: RawByteString);
var
  vo: TpbObject;
begin
  vo := FindName(name);

  if Assigned(vo) then
    TpbValueObject(vo).AsRawByteString := value;
end;

procedure TpbRecord.SetUI32(AID: Integer; const value: UInt32);
var
  vo: TpbObject;
begin
  vo := FindField(AID);

  if Assigned(vo) then
    TpbValueObject(vo).AsUInt32 := value
  else
    Self.AddUInt32(AID, value);
end;

procedure TpbRecord.SetUI32Of(const name: string; const value: UInt32);
var
  vo: TpbObject;
begin
  vo := FindName(name);

  if Assigned(vo) then
    TpbValueObject(vo).AsUInt32 := value;
end;

procedure TpbRecord.SetUI64(AID: Integer; const value: UInt64);
var
  vo: TpbObject;
begin
  vo := FindField(AID);

  if Assigned(vo) then
    TpbValueObject(vo).AsUInt64 := value
  else
    Self.AddUInt64(AID, value);
end;

procedure TpbRecord.SetUI64Of(const name: string; const value: UInt64);
var
  vo: TpbObject;
begin
  vo := FindName(name);

  if Assigned(vo) then
    TpbValueObject(vo).AsUInt64 := value;
end;

procedure TpbRecord.SetUStr(AID: Integer; const value: UnicodeString);
var
  vo: TpbObject;
begin
  vo := FindField(AID);

  if Assigned(vo) then
    TpbValueObject(vo).AsUnicodeString := value
  else
    Self.AddUnicodeString(AID, value);
end;

procedure TpbRecord.SetUStrOf(const name: string; const value: UnicodeString);
var
  vo: TpbObject;
begin
  vo := FindName(name);

  if Assigned(vo) then
    TpbValueObject(vo).AsUnicodeString := value;
end;

function TpbRecord.ToJson(level: Integer; const indent: UnicodeString)
  : UnicodeString;
var
  I: Integer;
  obj: TpbObject;
  indent1: UnicodeString;
begin
  Result := '{';

  if indent = '' then
    indent1 := ''
  else
    indent1 := #13#10 + UStrRepeat(indent, level + 1);

  for I := 0 to FFields.Count - 1 do
  begin
    obj := TpbObject(FFields[I]);

    case obj.ValueType of
      pbvtSingle:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbSingle(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbSingle(obj).AsUnicodeString;

      pbvtDouble:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbDouble(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbDouble(obj).AsUnicodeString;

      pbvtInt32:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbInt32(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbInt32(obj).AsUnicodeString;

      pbvtUInt32:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbUInt32(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbUInt32(obj).AsUnicodeString;

      pbvtInt64:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbInt64(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbInt64(obj).AsUnicodeString;

      pbvtUInt64:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbUInt64(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbUInt64(obj).AsUnicodeString;

      pbvtVarInt:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbVarIntObject(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbVarIntObject(obj).AsUnicodeString;

      pbvtRawByteString:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':"' + JsonEscape(TpbRawByteString(obj).AsUnicodeString) + '"'
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':"' + JsonEscape(TpbRawByteString(obj).AsUnicodeString) + '"';

      pbvtUnicodeString:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':"' + JsonEscape(TpbUnicodeString(obj).AsUnicodeString) + '"'
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':"' + JsonEscape(TpbUnicodeString(obj).AsUnicodeString) + '"';

      pbvtRecord:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbRecord(obj).ToJson(level + 1, indent)
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbRecord(obj).ToJson(level + 1, indent);

      pbvtArray:
        if I = 0 then
          Result := Result + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbArray(obj).ToJson(level + 1, indent)
        else
          Result := Result + ',' + indent1 + 'field' + IntToStr(obj.ID)
            + ':' + TpbArray(obj).ToJson(level + 1, indent);
    end;
  end;

  if indent = '' then
    Result := Result + '}'
  else
    Result := Result + #13#10 + UStrRepeat(indent, level) + '}';
end;

{ TpbArray }

procedure TpbArray.Add(obj: TpbObject);
begin
  FItems.Add(obj);
end;

function TpbArray.AddDouble(AID: Integer; v: Double): TpbDouble;
begin
  Result := TpbDouble.Create;
  Result.FValue := v;
  FItems.Add(Result);
end;

function TpbArray.AddInt32(v: Integer): TpbInt32;
begin
  Result := TpbInt32.Create;
  Result.FValue := v;
  FItems.Add(Result);
end;

function TpbArray.AddInt64(v: Int64): TpbInt64;
begin
  Result := TpbInt64.Create;
  Result.FValue := v;
  FItems.Add(Result);
end;

function TpbArray.AddRecord: TpbRecord;
begin
  Result := TpbRecord.Create;
  FItems.Add(Result);
end;

procedure TpbArray.AddRecord(v: TpbRecord);
begin
  FItems.Add(v);
end;

function TpbArray.AddRawByteString(const v: RawByteString): TpbRawByteString;
begin
  Result := TpbRawByteString.Create;
  Result.FValue := v;
  FItems.Add(Result);
end;

function TpbArray.AddSingle(AID: Integer; v: Single): TpbSingle;
begin
  Result := TpbSingle.Create;
  Result.FValue := v;
  FItems.Add(Result);
end;

function TpbArray.AddUInt32(v: Cardinal): TpbUInt32;
begin
  Result := TpbUInt32.Create;
  Result.FValue := v;
  FItems.Add(Result);
end;

function TpbArray.AddUInt64(v: UInt64): TpbUInt64;
begin
  Result := TpbUInt64.Create;
  Result.FValue := v;
  FItems.Add(Result);
end;

function TpbArray.AddUnicodeString(const v: UnicodeString): TpbUnicodeString;
begin
  Result := TpbUnicodeString.Create;
  Result.FValue := v;
  FItems.Add(Result);
end;

function TpbArray.AddVarInt(const v: TpbVarInt): TpbVarIntObject;
begin
  Result := TpbVarIntObject.Create;
  Result.FValue := v;
  FItems.Add(Result);
end;

procedure TpbArray.Clear;
begin
  FItems.Clear;
end;

function TpbArray.clone: TpbObject;
var
  I: Integer;
begin
  Result := TpbArray.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;

  for I := 0 to FItems.Count - 1 do
    TpbArray(Result).FItems.Add(TpbObject(FItems[I]).clone);
end;

constructor TpbArray.Create;
begin
  inherited Create;
  FItems := TObjectListEx<TpbObject>.Create(True);
end;

destructor TpbArray.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TpbArray.encode(stream: TStream): Integer;
var
  I: Integer;
  Field: TpbObject;
  encoder: TProtoBufferStreamEncoder;
begin
  encoder.SetStream(stream);

  for I := 0 to FItems.Count - 1 do
  begin
    Field := TpbObject(FItems[I]);

    case Field.GetValueType of
      pbvtSingle: encoder.WriteSingle(Self.ID, TpbSingle(Field).FValue);
      pbvtDouble: encoder.WriteDouble(Self.ID, TpbDouble(Field).FValue);
      pbvtInt32: encoder.WriteInt32(Self.ID, TpbInt32(Field).FValue);
      pbvtUInt32: encoder.WriteUInt32(Self.ID, TpbUInt32(Field).FValue);
      pbvtInt64: encoder.WriteInt64(Self.ID, TpbInt64(Field).FValue);
      pbvtUInt64: encoder.WriteUInt64(Self.ID, TpbUInt64(Field).FValue);
      pbvtVarInt: encoder.WriteVarInt(Self.ID, TpbVarIntObject(Field).FValue);
      pbvtRawByteString: encoder.WriteRawByteString(Self.ID, TpbRawByteString(Field).FValue);
      pbvtUnicodeString: encoder.WriteUnicodeString(Self.ID, TpbUnicodeString(Field).FValue);
      pbvtArray: TpbArray(Field).encode(stream);
      pbvtRecord:
        begin
          encoder.WriteVarBytesHeader(Self.ID, TpbRecord(Field).encode(nil));
          Inc(encoder.CurPos, TpbRecord(Field).encode(stream));
        end;
    end;
  end;

  Result := encoder.GetDataLength;
end;

function TpbArray.GetArray(Index: Integer): TpbArray;
begin
  Result := TpbArray(FItems[Index]);
end;

function TpbArray.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TpbArray.GetRecord(Index: Integer): TpbRecord;
begin
  Result := TpbRecord(FItems[Index]);
end;

function TpbArray.GetValue(Index: Integer): TpbValueObject;
begin
  Result := TpbValueObject(FItems[Index]);
end;

function TpbArray.GetValueType: TpbValueType;
begin
  Result := pbvtArray;
end;

function TpbArray.ToJson(level: Integer; const indent: UnicodeString)
  : UnicodeString;
var
  I: Integer;
  obj: TpbObject;
  indent1: UnicodeString;
begin
  Result := '[';

  if indent = '' then
    indent1 := ''
  else
    indent1 := #13#10 + UStrRepeat(indent, level + 1);

  for I := 0 to FItems.Count - 1 do
  begin
    obj := TpbObject(FItems[I]);

    case obj.ValueType of
      pbvtSingle:
        if I = 0 then
          Result := Result + indent1 + TpbSingle(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + TpbSingle(obj).AsUnicodeString;

      pbvtDouble:
        if I = 0 then
          Result := Result + indent1 + TpbDouble(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + TpbDouble(obj).AsUnicodeString;

      pbvtInt32:
        if I = 0 then
          Result := Result + indent1 + TpbInt32(obj).AsUnicodeString
        else
          Result := Result + ',' + indent1 + TpbInt32(obj).AsUnicodeString;

      pbvtUInt32:
        if I = 0 then
          Result := Result + indent1 + TpbUInt32(obj).AsUnicodeString
        else
          Result := Result + ', ' + indent1 + TpbUInt32(obj).AsUnicodeString;

      pbvtInt64:
        if I = 0 then
          Result := Result + indent1 + TpbInt64(obj).AsUnicodeString
        else
          Result := Result + ', ' + indent1 + TpbInt64(obj).AsUnicodeString;

      pbvtUInt64:
        if I = 0 then
          Result := Result + indent1 + TpbUInt64(obj).AsUnicodeString
        else
          Result := Result + ', ' + indent1 + TpbUInt64(obj).AsUnicodeString;

      pbvtVarInt:
        if I = 0 then
          Result := Result + indent1 + TpbVarIntObject(obj).AsUnicodeString
        else
          Result := Result + ', ' + indent1 + TpbVarIntObject(obj)
            .AsUnicodeString;

      pbvtRawByteString:
        if I = 0 then
          Result := Result + indent1 + JsonEscape
            (TpbRawByteString(obj).AsUnicodeString) + '"'
        else
          Result := Result + ',' + indent1 + JsonEscape
            (TpbRawByteString(obj).AsUnicodeString) + '"';

      pbvtUnicodeString:
        if I = 0 then
          Result := Result + indent1 + JsonEscape
            (TpbUnicodeString(obj).AsUnicodeString) + '"'
        else
          Result := Result + ',' + indent1 + JsonEscape
            (TpbUnicodeString(obj).AsUnicodeString) + '"';

      pbvtRecord:
        if I = 0 then
          Result := Result + indent1 + TpbRecord(obj).ToJson(level + 1, indent)
        else
          Result := Result + ',' + indent1 + TpbRecord(obj).ToJson(level + 1,
            indent);

      pbvtArray:
        if I = 0 then
          Result := Result + indent1 + TpbArray(obj).ToJson(level + 1, indent)
        else
          Result := Result + ',' + indent1 + TpbArray(obj).ToJson(level + 1,
            indent);
    end;
  end;

  if indent = '' then
    Result := Result + ']'
  else
    Result := Result + #13#10 + UStrRepeat(indent, level) + ']';
end;

{ TpbSingle }

function TpbSingle.clone: TpbObject;
begin
  Result := TpbSingle.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  TpbSingle(Result).FValue := Self.FValue;
end;

function TpbSingle.GetAsFloat: Double;
begin
  Result := FValue;
end;

function TpbSingle.GetAsInt32: Int32;
begin
  Result := Round(FValue);
end;

function TpbSingle.GetAsInt64: Int64;
begin
  Result := Round(FValue);
end;

function TpbSingle.GetAsRawByteString: RawByteString;
begin
  Result := RawByteString(FloatToStr(FValue));
end;

function TpbSingle.GetAsUInt32: UInt32;
begin
  Result := Round(FValue);
end;

function TpbSingle.GetAsUInt64: UInt64;
begin
  Result := Trunc(FValue);
end;

function TpbSingle.GetAsUnicodeString: UnicodeString;
begin
  Result := UnicodeString(FloatToStr(FValue));
end;

function TpbSingle.GetValueType: TpbValueType;
begin
  Result := pbvtSingle;
end;

procedure TpbSingle.SetAsFloat(const value: Double);
begin
  FValue := value;
end;

procedure TpbSingle.SetAsInt32(const value: Integer);
begin
  FValue := value;
end;

procedure TpbSingle.SetAsInt64(const value: Int64);
begin
  FValue := value;
end;

procedure TpbSingle.SetAsRawByteString(const value: RawByteString);
begin
  FValue := RBStrToFloat(value);
end;

procedure TpbSingle.SetAsUInt32(const value: Cardinal);
begin
  FValue := value;
end;

procedure TpbSingle.SetAsUInt64(const value: UInt64);
begin
  FValue := value;
end;

procedure TpbSingle.SetAsUnicodeString(const value: UnicodeString);
begin
  FValue := UStrToFloat(value);
end;

{ TpbDouble }

function TpbDouble.clone: TpbObject;
begin
  Result := TpbDouble.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  TpbDouble(Result).FValue := Self.FValue;
end;

function TpbDouble.GetAsFloat: Double;
begin
  Result := FValue;
end;

function TpbDouble.GetAsInt32: Int32;
begin
  Result := Round(FValue);
end;

function TpbDouble.GetAsInt64: Int64;
begin
  Result := Round(FValue);
end;

function TpbDouble.GetAsRawByteString: RawByteString;
begin
  Result := RawByteString(FloatToStr(FValue));
end;

function TpbDouble.GetAsUInt32: UInt32;
begin
  Result := Round(FValue);
end;

function TpbDouble.GetAsUInt64: UInt64;
begin
  Result := Trunc(FValue);
end;

function TpbDouble.GetAsUnicodeString: UnicodeString;
begin
  Result := UnicodeString(FloatToStr(FValue));
end;

function TpbDouble.GetValueType: TpbValueType;
begin
  Result := pbvtDouble;
end;

procedure TpbDouble.SetAsFloat(const value: Double);
begin
  FValue := value;
end;

procedure TpbDouble.SetAsInt32(const value: Integer);
begin
  FValue := value;
end;

procedure TpbDouble.SetAsInt64(const value: Int64);
begin
  FValue := value;
end;

procedure TpbDouble.SetAsRawByteString(const value: RawByteString);
begin
  FValue := RBStrToFloat(value);
end;

procedure TpbDouble.SetAsUInt32(const value: Cardinal);
begin
  FValue := value;
end;

procedure TpbDouble.SetAsUInt64(const value: UInt64);
begin
  FValue := value;
end;

procedure TpbDouble.SetAsUnicodeString(const value: UnicodeString);
begin
  FValue := UStrToFloat(value);
end;

{ TpbVarInt }

procedure TpbVarInt.decode(var Buf; BufSize: Integer);
var
  I, nBufferedBits: Integer;
  ptr: PByte;
  CurByte: Byte;
  BitsBuffer: Word;

  procedure DecodeBuffer;
  var
    CurDecodedByte: Byte;
  begin
    CurDecodedByte := Byte(BitsBuffer and $FF);

    if PAnsiChar(ptr) < PAnsiChar(@Buf) + BufSize then
      ptr^ := CurDecodedByte;

    Inc(ptr);

    BitsBuffer := BitsBuffer shr 8;

    if nBufferedBits >= 8 then
      Dec(nBufferedBits, 8)
    else
      nBufferedBits := 0;
  end;

begin
  if BufSize <= 0 then
    raise EpbVarIntError.Create(SErr_Overflow);

  ptr := @Buf;
  BitsBuffer := 0;
  nBufferedBits := 0;

  for I := 0 to Self.used - 2 do
  begin
    CurByte := bytes[I];

    if CurByte and $80 = 0 then
      raise EpbVarIntError.Create(SErr_InvalidVarInt);

    BitsBuffer := BitsBuffer or (Word(CurByte and $7F) shl nBufferedBits);
    Inc(nBufferedBits, 7);
    if nBufferedBits >= 8 then
      DecodeBuffer;
  end;

  CurByte := Self.bytes[used - 1];

  if CurByte and $80 <> 0 then
    raise EpbVarIntError.Create(SErr_InvalidVarInt);

  BitsBuffer := BitsBuffer or (Word(CurByte and $7F) shl nBufferedBits);
  Inc(nBufferedBits, 7);
  if nBufferedBits >= 8 then
    DecodeBuffer;

  if nBufferedBits > 0 then
    DecodeBuffer;

  for I := 0 to PAnsiChar(@Buf) + BufSize - PAnsiChar(ptr) - 1 do
    PAnsiChar(ptr)[I] := #0;
end;

function TpbVarInt.equals(const another: TpbVarInt): Boolean;
var
  I: Integer;
begin
  if Self.used = another.used then
  begin
    Result := True;
    for I := 0 to Self.used - 1 do
      if Self.bytes[I] <> another.bytes[I] then
      begin
        Result := False;
        Break;
      end;
  end
  else
    Result := False;
end;

function TpbVarInt.GetBytes: RawByteString;
begin
  SetLength(Result, Self.used);
  Move(Self.bytes, Pointer(Result)^, Self.used);
end;

procedure TpbVarInt.init(const Buf; BufSize: Integer);
var
  P: PByte;
  I: Integer;
  BinBuf: Word;
  BinByte, N, nBufferedBits: Byte;

  procedure EncodeFromBuffer;
  var
    v: Byte;
  begin
    v := Byte(BinBuf and $7F);
    Self.bytes[N] := v;
    Inc(N);
    BinBuf := BinBuf shr 7;
    Dec(nBufferedBits, 7);
  end;

begin
  if BufSize <= 0 then
  begin
    Self.zero;
    Exit;
  end;

  P := @Buf;
  Inc(P, BufSize - 1);

  while (BufSize > 0) and (P^ = 0) do
  begin
    Dec(P);
    Dec(BufSize);
  end;

  if BufSize <= 0 then
  begin
    Self.zero;
    Exit;
  end;

  P := @Buf;
  N := Low(bytes);
  BinBuf := 0;
  nBufferedBits := 0;

  for I := 0 to BufSize - 1 do
  begin
    BinByte := P^;
    BinBuf := BinBuf or (Word(BinByte) shl nBufferedBits);
    Inc(nBufferedBits, 8);
    Inc(P);
    EncodeFromBuffer;

    if nBufferedBits >= 7 then
      EncodeFromBuffer;
  end;

  if nBufferedBits > 0 then
    EncodeFromBuffer;

  while (N > 1) and (Self.bytes[N - 1] = 0) do
    Dec(N);

  used := N;

  for I := 0 to N - 2 do
    bytes[I] := bytes[I] or $80;
end;

procedure TpbVarInt.EncodeInt32(const value: Int32);
begin
  Self.EncodeUInt32(zigzagEncode32(value));
end;

procedure TpbVarInt.EncodeInt64(const value: Int64);
begin
  Self.EncodeUInt64(zigzagEncode64(value));
end;

procedure TpbVarInt.EncodeUInt32(const value: UInt32);
begin
  if value < $80 then
  begin
    Self.used := 1;
    Self.bytes[0] := Byte(value);
  end
  else if value < $4000 then
  begin
    Self.used := 2;
    Self.bytes[0] := Byte(value and $7F) or $80;
    Self.bytes[1] := Byte(value shr 7);
  end
  else if value < $200000 then
  begin
    Self.used := 3;
    Self.bytes[0] := Byte(value and $7F) or $80;
    Self.bytes[1] := Byte((value shr 7) and $7F) or $80;
    Self.bytes[2] := Byte(value shr 14);
  end
  else if value < $10000000 then
  begin
    Self.used := 4;
    Self.bytes[0] := Byte(value and $7F) or $80;
    Self.bytes[1] := Byte((value shr 7) and $7F) or $80;
    Self.bytes[2] := Byte((value shr 14) and $7F) or $80;
    Self.bytes[3] := Byte(value shr 21);
  end
  else
  begin
    Self.used := 5;
    Self.bytes[0] := Byte(value and $7F) or $80;
    Self.bytes[1] := Byte((value shr 7) and $7F) or $80;
    Self.bytes[2] := Byte((value shr 14) and $7F) or $80;
    Self.bytes[3] := Byte((value shr 21) and $7F) or $80;
    Self.bytes[4] := Byte(value shr 28);
  end;
end;

procedure TpbVarInt.EncodeUInt64(const value: UInt64);
begin
  Self.init(value, SizeOf(value));
end;

function TpbVarInt.IsZero: Boolean;
begin
  Result := (Self.used = 1) and (Self.bytes[0] = 0);
end;

function TpbVarInt.ReadBuffer(const Buf; BufSize: Integer): Integer;
var
  N: Integer;
  P: PByte;
  C: Byte;
begin
  N := 0;
  P := @Buf;

  while N < BufSize do
  begin
    if N >= PB_VARINT_MAX_BYTES then
    begin
      N := ERROR_PB_VARINT_OVERFLOW;
      Break;
    end;

    C := P^;
    Self.bytes[N] := C;

    Inc(N);
    Inc(P);

    if C and $80 = 0 then
      Break;
  end;

  if (N >= BufSize) and (BufSize > 0) and (Self.bytes[N-1] and $80 <> 0) then
    N := ERROR_PB_HUNGRY;

  if N <= 0 then Self.SetInvalid
  else Self.used := N;

  Result := N;
end;

function TpbVarInt.ReadStream(stream: TStream; MaxRead: Integer): Integer;
var
  N: Integer;
  C: Byte;
begin
  N := 0;

  if MaxRead <= 0 then
    MaxRead := stream.Size - stream.Position;

  while N < MaxRead do
  begin
    if N >= PB_VARINT_MAX_BYTES then
    begin
      N := ERROR_PB_VARINT_OVERFLOW;
      Break;
    end;

    if stream.Read(C, 1) < 1 then
    begin
      if N > 0 then
        N := ERROR_PB_HUNGRY;

      Break;
    end;

    Self.bytes[N] := C;
    Inc(N);

    if C and $80 = 0 then
      Break;
  end;

  if (N >= MaxRead) and (MaxRead > 0) and (Self.bytes[N-1] and $80 <> 0) then
    N := ERROR_PB_HUNGRY;

  if N <= 0 then Self.SetInvalid
  else Self.used := N;

  Result := N;
end;

procedure TpbVarInt.SetInvalid;
begin
  Self.used := 0;
end;

function TpbVarInt.ToInt32: Int32;
var
  tmp: UInt32;
begin
  Self.decode(tmp, SizeOf(tmp));
  Result := zigzagDecode32(tmp);
end;

function TpbVarInt.ToInt64: Int64;
var
  tmp: UInt64;
begin
  Self.decode(tmp, SizeOf(tmp));
  Result := zigzagDecode64(tmp);
end;

function TpbVarInt.ToUInt32: UInt32;
begin
  Self.decode(Result, SizeOf(Result));
end;

function TpbVarInt.ToUInt64: UInt64;
begin
  Self.decode(Result, SizeOf(Result));
end;

function TpbVarInt.valid: Boolean;
var
  i: Integer;
begin
  if (used > Length(bytes)) or (used <= 0) then Result := False
  else if bytes[used - 1] and $80 <> 0 then Result := False
  else begin
    Result := True;

    for i := 0 to used - 2 do
    begin
      if bytes[i] and $80 = 0 then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;

function TpbVarInt.WriteBuffer(var Buf; BufSize: Integer): Integer;
begin
  if BufSize >= used then
  begin
    Move(bytes[0], Buf, used);
    Result := used;
  end
  else if BufSize > 0 then
    Result := ERROR_PB_HUNGRY
  else
    Result := used;
end;

function TpbVarInt.WriteStream(stream: TStream): Integer;
begin
  if Assigned(stream) then
    stream.WriteBuffer(bytes, used);

  Result := used;
end;

procedure TpbVarInt.zero;
begin
  Self.used := 1;
  Self.bytes[0] := 0;
end;

{ TpbVarIntObject }

function TpbVarIntObject.clone: TpbObject;
begin
  Result := TpbVarIntObject.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  TpbVarIntObject(Result).FValue := Self.FValue;
end;

function TpbVarIntObject.GetAsFloat: Double;
begin
  Result := FValue.ToUInt64;
end;

function TpbVarIntObject.GetAsInt32: Int32;
begin
  Result := FValue.ToInt32;
end;

function TpbVarIntObject.GetAsInt64: Int64;
begin
  Result := FValue.ToInt64;
end;

function TpbVarIntObject.GetAsRawByteString: RawByteString;
begin
  Result := IntToRBStr(FValue.ToUInt64);
end;

function TpbVarIntObject.GetAsUInt32: UInt32;
begin
  Result := FValue.ToUInt32;
end;

function TpbVarIntObject.GetAsUInt64: UInt64;
begin
  Result := FValue.ToUInt64;
end;

function TpbVarIntObject.GetAsUnicodeString: UnicodeString;
begin
  Result := IntToUStr(FValue.ToUInt64);
end;

function TpbVarIntObject.GetValueType: TpbValueType;
begin
  Result := pbvtVarInt;
end;

procedure TpbVarIntObject.SetAsFloat(const value: Double);
begin
  FValue.EncodeInt64(Trunc(value));
end;

procedure TpbVarIntObject.SetAsInt32(const value: Integer);
begin
  FValue.EncodeInt32(value);
end;

procedure TpbVarIntObject.SetAsInt64(const value: Int64);
begin
  FValue.EncodeInt64(value);
end;

procedure TpbVarIntObject.SetAsRawByteString(const value: RawByteString);
begin
  FValue.EncodeInt64(RBStrToInt64(value));
end;

procedure TpbVarIntObject.SetAsUInt32(const value: Cardinal);
begin
  FValue.EncodeUInt32(value);
end;

procedure TpbVarIntObject.SetAsUInt64(const value: UInt64);
begin
  FValue.EncodeUInt64(value);
end;

procedure TpbVarIntObject.SetAsUnicodeString(const value: UnicodeString);
begin
  FValue.EncodeInt64(UStrToInt64(value));
end;

{ TpbUInt64 }

function TpbUInt64.clone: TpbObject;
begin
  Result := TpbUInt64.Create;
  Result.FID := Self.FID;
  Result.FName := Self.FName;
  TpbUInt64(Result).FValue := Self.FValue;
end;

function TpbUInt64.GetAsFloat: Double;
begin
  Result := FValue;
end;

function TpbUInt64.GetAsInt32: Int32;
begin
  Result := Int32(FValue);
end;

function TpbUInt64.GetAsInt64: Int64;
begin
  Result := Int64(FValue);
end;

function TpbUInt64.GetAsRawByteString: RawByteString;
begin
  Result := IntToRBStr(FValue);
end;

function TpbUInt64.GetAsUInt32: UInt32;
begin
  Result := UInt32(FValue);
end;

function TpbUInt64.GetAsUInt64: UInt64;
begin
  Result := FValue;
end;

function TpbUInt64.GetAsUnicodeString: UnicodeString;
begin
  Result := IntToUStr(FValue);
end;

function TpbUInt64.GetValueType: TpbValueType;
begin
  Result := pbvtUInt64;
end;

procedure TpbUInt64.SetAsFloat(const value: Double);
begin
  FValue := Trunc(value);
end;

procedure TpbUInt64.SetAsInt32(const value: Integer);
begin
  FValue := value;
end;

procedure TpbUInt64.SetAsInt64(const value: Int64);
begin
  FValue := value;
end;

procedure TpbUInt64.SetAsRawByteString(const value: RawByteString);
begin
  FValue := RBStrToInt64(value);
end;

procedure TpbUInt64.SetAsUInt32(const value: Cardinal);
begin
  FValue := value;
end;

procedure TpbUInt64.SetAsUInt64(const value: UInt64);
begin
  FValue := value;
end;

procedure TpbUInt64.SetAsUnicodeString(const value: UnicodeString);
begin
  FValue := UStrToInt64(value);
end;

{ TProtoBufferDecoder }

function pbFieldAsInt32(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: Int32): Boolean;
var
  va: TpbVarInt;
  BytesRead, vblen, tmp: Integer;
  dummy: PAnsiChar;
begin
  case _type of
    pwtVarInt:
      begin
        va.ReadBuffer(buf^, len);
        value := va.ToInt32;
        Result := True;
      end;

    pwt64Bit:
      begin
        if len >= 8 then
        begin
          value := PInt64(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadBuffer(buf^, len);
        vblen := va.ToUInt32;
        Inc(buf, BytesRead);
        Dec(len, BytesRead);

        if (vblen = 0) or (len < vblen) then Result := False
        else begin
          tmp := BufToIntA(buf, vblen, @dummy);

          if Assigned(dummy) then Result := False
          else begin
            value := tmp;
            Result := True;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if len >= 4 then
        begin
          value := PInt32(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbFieldAsUInt32(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: UInt32): Boolean;
var
  va: TpbVarInt;
  BytesRead, vblen: Integer;
  tmp: UInt32;
  dummy: PAnsiChar;
begin
  case _type of
    pwtVarInt:
      begin
        va.ReadBuffer(buf^, len);
        value := va.ToUInt32;
        Result := True;
      end;

    pwt64Bit:
      begin
        if len >= 8 then
        begin
          value := PUInt64(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadBuffer(buf^, len);
        vblen := va.ToUInt32;
        Inc(buf, BytesRead);
        Dec(len, BytesRead);

        if (vblen = 0) or (len < vblen) then Result := False
        else begin
          tmp := BufToUInt32A(buf, vblen, @dummy);

          if Assigned(dummy) then Result := False
          else begin
            value := tmp;
            Result := True;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if len >= 4 then
        begin
          value := PUInt32(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbFieldAsInt64(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: Int64): Boolean;
var
  va: TpbVarInt;
  BytesRead, vblen: Integer;
  tmp: Int64;
  dummy: PAnsiChar;
begin
  case _type of
    pwtVarInt:
      begin
        va.ReadBuffer(buf^, len);
        value := va.ToInt64;
        Result := True;
      end;

    pwt64Bit:
      begin
        if len >= 8 then
        begin
          value := PInt64(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadBuffer(buf^, len);
        vblen := va.ToUInt32;
        Inc(buf, BytesRead);
        Dec(len, BytesRead);

        if (vblen = 0) or (len < vblen) then Result := False
        else begin
          tmp := BufToInt64A(buf, vblen, @dummy);

          if Assigned(dummy) then Result := False
          else begin
            value := tmp;
            Result := True;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if len >= 4 then
        begin
          value := PUInt32(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbFieldAsUInt64(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: UInt64): Boolean;
var
  va: TpbVarInt;
  BytesRead, vblen: Integer;
  tmp: UInt64;
  dummy: PAnsiChar;
begin
  case _type of
    pwtVarInt:
      begin
        va.ReadBuffer(buf^, len);
        value := va.ToUInt64;
        Result := True;
      end;

    pwt64Bit:
      begin
        if len >= 8 then
        begin
          value := PUInt64(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadBuffer(buf^, len);
        vblen := va.ToUInt32;
        Inc(buf, BytesRead);
        Dec(len, BytesRead);

        if (vblen = 0) or (len < vblen) then Result := False
        else begin
          tmp := BufToUInt64A(buf, vblen, @dummy);

          if Assigned(dummy) then Result := False
          else begin
            value := tmp;
            Result := True;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if len >= 4 then
        begin
          value := PUInt32(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbFieldAsSingle(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: Single): Boolean;
var
  va: TpbVarInt;
  BytesRead, vblen: Integer;
  tmp: Double;
  dummy: PAnsiChar;
begin
  case _type of
    pwtVarInt:
      begin
        va.ReadBuffer(buf^, len);
        value := va.ToUInt64;
        Result := True;
      end;

    pwt64Bit:
      begin
        if len >= 8 then
        begin
          value := PDouble(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadBuffer(buf^, len);
        vblen := va.ToUInt32;
        Inc(buf, BytesRead);
        Dec(len, BytesRead);

        if (vblen = 0) or (len < vblen) then Result := False
        else begin
          tmp := BufToFloatA(buf, vblen, @dummy);

          if Assigned(dummy) then Result := False
          else begin
            value := tmp;
            Result := True;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if len >= 4 then
        begin
          value := PSingle(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbFieldAsDouble(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: Double): Boolean;
var
  va: TpbVarInt;
  BytesRead, vblen: Integer;
  tmp: Double;
  dummy: PAnsiChar;
begin
  case _type of
    pwtVarInt:
      begin
        va.ReadBuffer(buf^, len);
        value := va.ToUInt64;
        Result := True;
      end;

    pwt64Bit:
      begin
        if len >= 8 then
        begin
          value := PDouble(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadBuffer(buf^, len);
        vblen := va.ToUInt32;
        Inc(buf, BytesRead);
        Dec(len, BytesRead);

        if (vblen = 0) or (len < vblen) then Result := False
        else begin
          tmp := BufToFloatA(buf, vblen, @dummy);

          if Assigned(dummy) then Result := False
          else begin
            value := tmp;
            Result := True;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if len >= 4 then
        begin
          value := PSingle(buf)^;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbFieldAsRBStr(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: RawByteString): Boolean;
var
  va: TpbVarInt;
  BytesRead, vblen: Integer;
begin
  case _type of
    pwtVarInt:
      begin
        va.ReadBuffer(buf^, len);
        value := UInt64ToRBStr(va.ToUInt64);
        Result := True;
      end;

    pwt64Bit:
      begin
        if len >= 8 then
        begin
          value := FloatToRBStr(PDouble(buf)^);
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadBuffer(buf^, len);
        vblen := va.ToUInt32;
        Inc(buf, BytesRead);
        Dec(len, BytesRead);

        if len < vblen then Result := False
        else begin
          SetString(value, buf, vblen);
          Result := True;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if len >= 4 then
        begin
          value := FloatToRBStr(PSingle(buf)^);
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbFieldAsUStr(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: UnicodeString): Boolean;
var
  va: TpbVarInt;
  BytesRead, vblen: Integer;
begin
  case _type of
    pwtVarInt:
      begin
        va.ReadBuffer(buf^, len);
        value := UInt64ToUStr(va.ToUInt64);
        Result := True;
      end;

    pwt64Bit:
      begin
        if len >= 8 then
        begin
          value := FloatToUStr(PDouble(buf)^);
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadBuffer(buf^, len);
        vblen := va.ToUInt32;
        Inc(buf, BytesRead);
        Dec(len, BytesRead);
        if len < vblen then Result := False
        else begin
          value := BufToUnicodeEx(buf, vblen, [CP_UTF8]);
          Result := True;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if len >= 4 then
        begin
          value := FloatToUStr(PSingle(buf)^);
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbFieldAsRecord(buf: PAnsiChar; len: Integer; _type: TpbWireType; var value: TProtoBufferDecoder): Boolean;
var
  va: TpbVarInt;
  BytesRead, vblen: Integer;
begin
  if _type = pwtVarBytes then
  begin
    BytesRead := va.ReadBuffer(buf^, len);
    vblen := va.ToUInt32;
    Inc(buf, BytesRead);
    Dec(len, BytesRead);
    if len < vblen then Result := False
    else begin
      value.SetBuffer(buf, vblen);
      Result := True;
    end;
  end
  else Result := False;
end;

function TProtoBufferDecoder.FindField(FieldId: UInt32; var FieldType: TpbWireType): PAnsiChar;
var
  ptr: PAnsiChar;
  L, BytesRead: Integer;
  va: TpbVarInt;
  id, vblen: UInt32;
  _type: TpbWireType;
begin
  Result := nil;
  ptr := Self.buf;
  L := Self.len;

  while L > 0 do
  begin
    BytesRead := va.ReadBuffer(ptr^, L);
    Inc(ptr, BytesRead);
    Dec(L, BytesRead);

    if not DecodeFieldHeader(va.ToUInt32, id, _type) then Break;

    if id = FieldId then
    begin
      FieldType := _type;
      Result := ptr;
      Break;
    end;

    case _type of
      pwtVarInt:
        begin
          BytesRead := va.ReadBuffer(ptr^, L);
          Inc(ptr, BytesRead);
          Dec(L, BytesRead);
        end;

      pwt32Bit:
        begin
          Inc(ptr, 4);
          Dec(L, 4);
        end;

      pwt64Bit:
        begin
          Inc(ptr, 8);
          Dec(L, 8);
        end;

      pwtVarBytes:
        begin
          BytesRead := va.ReadBuffer(ptr^, L);
          Inc(ptr, BytesRead);
          Dec(L, BytesRead);
          vblen := va.ToUInt32;
          Inc(ptr, vblen);
          Dec(L, vblen);
        end;

      pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: ;
    end;
  end;
end;

function TProtoBufferDecoder.GetDouble(FieldId: UInt32): Double;
begin
  if not TryGetDouble(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferDecoder.GetInt32(FieldId: UInt32): Int32;
begin
  if not TryGetInt32(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferDecoder.GetInt64(FieldId: UInt32): Int64;
begin
  if not TryGetInt64(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferDecoder.GetRawByteString(FieldId: UInt32): RawByteString;
begin
  if not TryGetRawByteString(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferDecoder.GetRecord(FieldId: UInt32): TProtoBufferDecoder;
begin
  if not TryGetRecord(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferDecoder.GetSingle(FieldId: UInt32): Single;
begin
  if not TryGetSingle(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferDecoder.GetUInt32(FieldId: UInt32): UInt32;
begin
  if not TryGetUInt32(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferDecoder.GetUInt64(FieldId: UInt32): UInt64;
begin
  if not TryGetUInt64(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferDecoder.GetUnicodeString(FieldId: UInt32): UnicodeString;
begin
  if not TryGetUnicodeString(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

procedure TProtoBufferDecoder.SetBuffer(_buf: PAnsiChar; _len: Integer);
begin
  buf := _buf;
  len := _len;
end;

procedure TProtoBufferDecoder.SetStringBuffer(const s: RawByteString);
begin
  buf := PAnsiChar(s);
  len := Length(s);
end;

function TProtoBufferDecoder.TryGetDouble(FieldId: UInt32; var value: Double): Boolean;
var
  _type: TpbWireType;
  data: PAnsiChar;
begin
  data := FindField(FieldId, _type);
  Result := Assigned(data) and pbFieldAsDouble(data, buf + len - data, _type, value);
end;

function TProtoBufferDecoder.TryGetInt32(FieldId: UInt32; var value: Int32): Boolean;
var
  _type: TpbWireType;
  data: PAnsiChar;
begin
  data := FindField(FieldId, _type);
  Result := Assigned(data) and pbFieldAsInt32(data, buf + len - data, _type, value);
end;

function TProtoBufferDecoder.TryGetInt64(FieldId: UInt32; var value: Int64): Boolean;
var
  _type: TpbWireType;
  data: PAnsiChar;
begin
  data := FindField(FieldId, _type);
  Result := Assigned(data) and pbFieldAsInt64(data, buf + len - data, _type, value);
end;

function TProtoBufferDecoder.TryGetRawByteString(FieldId: UInt32; var value: RawByteString): Boolean;
var
  _type: TpbWireType;
  data: PAnsiChar;
begin
  data := FindField(FieldId, _type);
  Result := Assigned(data) and pbFieldAsRBStr(data, buf + len - data, _type, value);
end;

function TProtoBufferDecoder.TryGetRecord(FieldId: UInt32; var value: TProtoBufferDecoder): Boolean;
var
  _type: TpbWireType;
  data: PAnsiChar;
begin
  data := FindField(FieldId, _type);
  Result := Assigned(data) and pbFieldAsRecord(data, buf + len - data, _type, value);
end;

function TProtoBufferDecoder.TryGetSingle(FieldId: UInt32; var value: Single): Boolean;
var
  _type: TpbWireType;
  data: PAnsiChar;
begin
  data := FindField(FieldId, _type);
  Result := Assigned(data) and pbFieldAsSingle(data, buf + len - data, _type, value);
end;

function TProtoBufferDecoder.TryGetUInt32(FieldId: UInt32; var value: UInt32): Boolean;
var
  _type: TpbWireType;
  data: PAnsiChar;
begin
  data := FindField(FieldId, _type);
  Result := Assigned(data) and pbFieldAsUInt32(data, buf + len - data, _type, value);
end;

function TProtoBufferDecoder.TryGetUInt64(FieldId: UInt32; var value: UInt64): Boolean;
var
  _type: TpbWireType;
  data: PAnsiChar;
begin
  data := FindField(FieldId, _type);
  Result := Assigned(data) and pbFieldAsUInt64(data, buf + len - data, _type, value);
end;

function TProtoBufferDecoder.TryGetUnicodeString(FieldId: UInt32; var value: UnicodeString): Boolean;
var
  _type: TpbWireType;
  data: PAnsiChar;
begin
  data := FindField(FieldId, _type);
  Result := Assigned(data) and pbFieldAsUStr(data, buf + len - data, _type, value);
end;

{ TProtoBufferStreamDecoder }

function pbStreamFieldAsInt32(stream: TStream; _type: TpbWireType; var value: Int32; len: Int64): Boolean;
var
  va: TpbVarInt;
  vblen, tmp: Integer;
  dummy, buf: PAnsiChar;
  i64: Int64;
  BytesRead: Integer;
begin
  if len <= 0 then
    len := stream.Size - stream.Position;

  case _type of
    pwtVarInt:
      begin
        if va.ReadStream(stream, len) > 0 then
        begin
          value := va.ToInt32;
          Result := True;
        end
        else Result := False;
      end;

    pwt64Bit:
      begin
        if (len >= 8) and (stream.Read(i64, 8) = 8) then
        begin
          value := i64;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadStream(stream, len);

        if BytesRead <= 0 then Result := False
        else begin
          Dec(len, BytesRead);
          vblen := va.ToUInt32;

          if (vblen <= 0) or (vblen > len) then Result := False
          else begin
            buf := PAnsiChar(System.GetMemory(vblen));

            try
              if stream.Read(buf^, vblen) < vblen then Result := False
              else begin
                tmp := BufToIntA(buf, vblen, @dummy);

                if Assigned(dummy) then Result := False
                else begin
                  value := tmp;
                  Result := True;
                end;
              end;
            finally
              System.FreeMemory(buf);
            end;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if (len >= 4) and (stream.Read(tmp, 4) = 4) then
        begin
          value := tmp;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbStreamFieldAsUInt32(stream: TStream; _type: TpbWireType; var value: UInt32; len: Int64): Boolean;
var
  va: TpbVarInt;
  vblen, BytesRead: Integer;
  tmp: UInt32;
  dummy, buf: PAnsiChar;
  i64: UInt64;
begin
  if len <= 0 then
    len := stream.Size - stream.Position;

  case _type of
    pwtVarInt:
      begin
        if va.ReadStream(stream, len) > 0 then
        begin
          value := va.ToUInt32;
          Result := True;
        end
        else Result := False;
      end;

    pwt64Bit:
      begin
        if (len >= 8) and (stream.Read(i64, 8) = 8) then
        begin
          value := i64;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadStream(stream, len);

        if BytesRead <= 0 then Result := False
        else begin
          Dec(len, BytesRead);
          vblen := va.ToUInt32;

          if (vblen <= 0) or (vblen > len) then Result := False
          else begin
            buf := PAnsiChar(System.GetMemory(vblen));

            try
              if stream.Read(buf^, vblen) < vblen then Result := False
              else begin
                tmp := BufToUInt32A(buf, vblen, @dummy);

                if Assigned(dummy) then Result := False
                else begin
                  value := tmp;
                  Result := True;
                end;
              end;
            finally
              System.FreeMemory(buf);
            end;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if (len >= 4) and (stream.Read(tmp, 4) = 4) then
        begin
          value := tmp;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbStreamFieldAsInt64(stream: TStream; _type: TpbWireType; var value: Int64; len: Int64): Boolean;
var
  va: TpbVarInt;
  vblen, BytesRead: Integer;
  tmp: Int64;
  dummy, buf: PAnsiChar;
  i32: Int32;
begin
  if len <= 0 then
    len := stream.Size - stream.Position;

  case _type of
    pwtVarInt:
      begin
        if va.ReadStream(stream, len) > 0 then
        begin
          value := va.ToInt64;
          Result := True;
        end
        else Result := False;
      end;

    pwt64Bit:
      begin
        if (len >= 8) and (stream.Read(tmp, 8) = 8) then
        begin
          value := tmp;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadStream(stream, len);

        if BytesRead <= 0 then Result := False
        else begin
          Dec(len, BytesRead);
          vblen := va.ToUInt32;

          if (vblen = 0) or (vblen > len)then Result := False
          else begin
            buf := PAnsiChar(System.GetMemory(vblen));

            try
              if stream.Read(buf^, vblen) < vblen then Result := False
              else begin
                tmp := BufToInt64A(buf, vblen, @dummy);

                if Assigned(dummy) then Result := False
                else begin
                  value := tmp;
                  Result := True;
                end;
              end;
            finally
              System.FreeMemory(buf);
            end;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if (len >= 4) and (stream.Read(i32, 4) = 4) then
        begin
          value := i32;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbStreamFieldAsUInt64(stream: TStream; _type: TpbWireType; var value: UInt64; len: Int64): Boolean;
var
  va: TpbVarInt;
  vblen, BytesRead: Integer;
  tmp: UInt64;
  dummy, buf: PAnsiChar;
  i32: UInt32;
begin
  if len <= 0 then
    len := stream.Size - stream.Position;

  case _type of
    pwtVarInt:
      begin
        if va.ReadStream(stream, len) > 0 then
        begin
          value := va.ToUInt64;
          Result := True;
        end
        else Result := False;
      end;

    pwt64Bit:
      begin
        if (len >= 8) and (stream.Read(tmp, 8) = 8) then
        begin
          value := tmp;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadStream(stream, len);

        if BytesRead <= 0 then Result := False
        else begin
          Dec(len, BytesRead);
          vblen := va.ToUInt32;

          if (vblen = 0) or (vblen > len) then Result := False
          else begin
            buf := PAnsiChar(System.GetMemory(vblen));

            try
              if stream.Read(buf^, vblen) < vblen then Result := False
              else begin
                tmp := BufToUInt64A(buf, vblen, @dummy);

                if Assigned(dummy) then Result := False
                else begin
                  value := tmp;
                  Result := True;
                end;
              end;
            finally
              System.FreeMemory(buf);
            end;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if (len >= 4) and (stream.Read(i32, 4) = 4) then
        begin
          value := i32;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbStreamFieldAsSingle(stream: TStream; _type: TpbWireType; var value: Single; len: Int64): Boolean;
var
  va: TpbVarInt;
  vblen, BytesRead: Integer;
  tmp: Double;
  dummy, buf: PAnsiChar;
  f32: Single;
begin
  if len <= 0 then
    len := stream.Size - stream.Position;

  case _type of
    pwtVarInt:
      begin
        if va.ReadStream(stream, len) > 0 then
        begin
          value := va.ToUInt64;
          Result := True;
        end
        else
          Result := False;
      end;

    pwt64Bit:
      begin
        if (len >= 8) and (stream.Read(tmp, 8) = 8) then
        begin
          value := tmp;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadStream(stream, len);

        if BytesRead <= 0 then Result := False
        else begin
          Dec(len, BytesRead);
          vblen := va.ToUInt32;

          if (vblen = 0) or (vblen > len) then Result := False
          else begin
            buf := PAnsiChar(System.GetMemory(vblen));

            try
              if stream.Read(buf^, vblen) < vblen then Result := False
              else begin
                tmp := BufToFloatA(buf, vblen, @dummy);

                if Assigned(dummy) then Result := False
                else begin
                  value := tmp;
                  Result := True;
                end;
              end;
            finally
              System.FreeMemory(buf);
            end;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if (len >= 4) and (stream.Read(f32, 4) = 4) then
        begin
          value := f32;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbStreamFieldAsDouble(stream: TStream; _type: TpbWireType; var value: Double; len: Int64): Boolean;
var
  va: TpbVarInt;
  vblen, BytesRead: Integer;
  tmp: Double;
  dummy, buf: PAnsiChar;
  f32: Single;
begin
  if len <= 0 then
    len := stream.Size - stream.Position;

  case _type of
    pwtVarInt:
      begin
        if va.ReadStream(stream, len) > 0 then
        begin
          value := va.ToUInt64;
          Result := True;
        end
        else Result := False;
      end;

    pwt64Bit:
      begin
        if (len >= 8) and (stream.Read(tmp, 8) = 8) then
        begin
          value := tmp;
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadStream(stream);

        if BytesRead <= 0 then Result := False
        else begin
          Dec(len, BytesRead);
          vblen := va.ToUInt32;

          if (vblen = 0) or (vblen > len) then Result := False
          else begin
            buf := PAnsiChar(System.GetMemory(vblen));

            try
              if stream.Read(buf^, vblen) < vblen then Result := False
              else begin
                tmp := BufToFloatA(buf, vblen, @dummy);

                if Assigned(dummy) then Result := False
                else begin
                  value := tmp;
                  Result := True;
                end;
              end;
            finally
              System.FreeMemory(buf);
            end;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if (len >= 4) and (stream.Read(f32, 4) = 4) then
        begin
          value := f32;
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbStreamFieldAsRBStr(stream: TStream; _type: TpbWireType; var value: RawByteString; len: Int64): Boolean;
var
  va: TpbVarInt;
  vblen, BytesRead: Integer;
  f64: Double;
  f32: Single;
  tmp: RawByteString;
begin
  if len <= 0 then
    len := stream.Size - stream.Position;

  case _type of
    pwtVarInt:
      begin
        if va.ReadStream(stream, len) > 0 then
        begin
          value := UInt64ToRBStr(va.ToUInt64);
          Result := True;
        end
        else Result := False;
      end;

    pwt64Bit:
      begin
        if (len >= 8) and (stream.Read(f64, 8) = 8) then
        begin
          value := FloatToRBStr(f64);
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadStream(stream, len);

        if BytesRead <= 0 then Result := False
        else begin
          Dec(len, BytesRead);
          vblen := va.ToUInt32;

          if vblen > len then Result := False
          else if vblen = 0 then
          begin
            value := '';
            Result := True;
          end
          else begin
            SetLength(tmp, vblen);
            if stream.Read(Pointer(tmp)^, vblen) = vblen then
            begin
              value := tmp;
              Result := True;
            end
            else Result := False;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if (len >= 4) and (stream.Read(f32, 4) = 4) then
        begin
          value := FloatToRBStr(f32);
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbStreamFieldAsUStr(stream: TStream; _type: TpbWireType; var value: UnicodeString; len: Int64): Boolean;
var
  va: TpbVarInt;
  vblen, BytesRead: Integer;
  f64: Double;
  f32: Single;
  tmp: RawByteString;
begin
  if len <= 0 then
    len := stream.Size - stream.Position;

  case _type of
    pwtVarInt:
      begin
        if va.ReadStream(stream, len) > 0 then
        begin
          value := UInt64ToUStr(va.ToUInt64);
          Result := True;
        end
        else
          Result := False;
      end;

    pwt64Bit:
      begin
        if (len >= 8) and (stream.Read(f64, 8) = 8) then
        begin
          value := FloatToUStr(f64);
          Result := True;
        end
        else Result := False;
      end;

    pwtVarBytes:
      begin
        BytesRead := va.ReadStream(stream, len);

        if BytesRead <= 0 then Result := False
        else begin
          Dec(len, BytesRead);
          vblen := va.ToUInt32;

          if vblen > len then Result := False
          else if vblen = 0 then
          begin
            value := '';
            Result := True;
          end
          else begin
            SetLength(tmp, vblen);
            if stream.Read(Pointer(tmp)^, vblen) = vblen then
            begin
              value := RBStrToUnicodeEx(tmp, [CP_UTF8]);
              Result := True;
            end
            else Result := False;
          end;
        end;
      end;

    pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Result := False;

    pwt32Bit:
      begin
        if (len >= 4) and (stream.Read(f32, 4) = 4) then
        begin
          value := FloatToUStr(f32);
          Result := True;
        end
        else Result := False;
      end;

    else
      Result := False;
  end;
end;

function pbStreamFieldAsRecord(stream: TStream; _type: TpbWireType; var value: TProtoBufferStreamDecoder;
  len: Int64): Boolean;
var
  va: TpbVarInt;
  vblen, BytesRead: Integer;
begin
  if len <= 0 then
    len := stream.Size - stream.Position;

  if _type = pwtVarBytes then
  begin
    BytesRead := va.ReadStream(stream, len);

    if BytesRead <= 0 then Result := False
    else begin
      Dec(len, BytesRead);
      vblen := va.ToUInt32;

      if vblen > len then Result := False
      else begin
        value.stream := stream;
        value.StartPos := stream.Position;
        value.ObjectSize := vblen;
        Result := True;
      end;
    end;
  end
  else Result := False;
end;

function TProtoBufferStreamDecoder.FindField(FieldId: UInt32; var FieldType: TpbWireType): Boolean;
var
  BytesRead, vblen: Integer;
  va: TpbVarInt;
  id: UInt32;
  _type: TpbWireType;
  bm, TotalRead: Int64;
begin
  Result := False;
  stream.Position := StartPos;
  TotalRead := 0;

  while TotalRead < ObjectSize do
  begin
    BytesRead := va.ReadStream(stream, ObjectSize - TotalRead);

    if BytesRead <= 0 then Break;

    Inc(TotalRead, BytesRead);

    if not DecodeFieldHeader(va.ToUInt32, id, _type) then Break;

    if id = FieldId then
    begin
      FieldType := _type;
      Result := True;
      Break;
    end;

    case _type of
      pwtVarInt:
        begin
          BytesRead := va.ReadStream(stream, ObjectSize - TotalRead);
          if BytesRead <= 0 then Break;
          Inc(TotalRead, BytesRead);
        end;

      pwt32Bit:
        begin
          if 4 > ObjectSize - TotalRead then Break;
          BytesRead := stream.Read(va, 4);
          if BytesRead <> 4 then Break;
          Inc(TotalRead, BytesRead);
        end;

      pwt64Bit:
        begin
          if 8 > ObjectSize - TotalRead then Break;
          BytesRead := stream.Read(va, 8);
          if BytesRead <> 8 then Break;
          Inc(TotalRead, BytesRead);
        end;

      pwtVarBytes:
        begin
          BytesRead := va.ReadStream(stream, ObjectSize - TotalRead);
          if BytesRead <= 0 then Break;
          Inc(TotalRead, BytesRead);
          vblen := va.ToUInt32;
          if vblen > ObjectSize - TotalRead then Break;
          bm := stream.Position;
          if stream.Seek(vblen, soFromCurrent) <> bm + vblen then Break;
          Inc(TotalRead, vblen);
        end;

      pwtStartGroup, pwtEndGroup, pwtNotUsed6, pwtNotUsed7: Break;
    end;
  end;
end;

function TProtoBufferStreamDecoder.GetDouble(FieldId: UInt32): Double;
begin
  if not TryGetDouble(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferStreamDecoder.GetInt32(FieldId: UInt32): Int32;
begin
  if not TryGetInt32(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferStreamDecoder.GetInt64(FieldId: UInt32): Int64;
begin
  if not TryGetInt64(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferStreamDecoder.GetRawByteString(FieldId: UInt32): RawByteString;
begin
  if not TryGetRawByteString(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferStreamDecoder.GetRecord(FieldId: UInt32): TProtoBufferStreamDecoder;
begin
  if not TryGetRecord(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferStreamDecoder.GetRemainBytes: Integer;
begin
  Result := ObjectSize - (stream.Position - StartPos);
end;

function TProtoBufferStreamDecoder.GetSingle(FieldId: UInt32): Single;
begin
  if not TryGetSingle(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferStreamDecoder.GetUInt32(FieldId: UInt32): UInt32;
begin
  if not TryGetUInt32(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferStreamDecoder.GetUInt64(FieldId: UInt32): UInt64;
begin
  if not TryGetUInt64(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

function TProtoBufferStreamDecoder.GetUnicodeString(FieldId: UInt32): UnicodeString;
begin
  if not TryGetUnicodeString(FieldId, Result) then
    raise EpbDecodeError.Create(SErr_InvalidBuffer);
end;

procedure TProtoBufferStreamDecoder.SetStream(s: TStream; _len: Int64);
begin
  stream := s;
  StartPos := s.Position;

  if _len > 0 then ObjectSize := _len
  else ObjectSize := s.Size - StartPos;
end;

function TProtoBufferStreamDecoder.TryGetDouble(FieldId: UInt32;var value: Double): Boolean;
var
  _type: TpbWireType;
begin
  Result := FindField(FieldId, _type) and pbStreamFieldAsDouble(stream, _type, value, GetRemainBytes);
end;

function TProtoBufferStreamDecoder.TryGetInt32(FieldId: UInt32; var value: Int32): Boolean;
var
  _type: TpbWireType;
begin
  Result := FindField(FieldId, _type) and pbStreamFieldAsInt32(stream, _type, value, GetRemainBytes);
end;

function TProtoBufferStreamDecoder.TryGetInt64(FieldId: UInt32; var value: Int64): Boolean;
var
  _type: TpbWireType;
begin
  Result := FindField(FieldId, _type) and pbStreamFieldAsInt64(stream, _type, value, GetRemainBytes);
end;

function TProtoBufferStreamDecoder.TryGetRawByteString(FieldId: UInt32;var value: RawByteString): Boolean;
var
  _type: TpbWireType;
begin
  Result := FindField(FieldId, _type) and pbStreamFieldAsRBStr(stream, _type, value, GetRemainBytes);
end;

function TProtoBufferStreamDecoder.TryGetRecord(FieldId: UInt32;var value: TProtoBufferStreamDecoder): Boolean;
var
  _type: TpbWireType;
begin
  Result := FindField(FieldId, _type) and pbStreamFieldAsRecord(stream, _type, value, GetRemainBytes);
end;

function TProtoBufferStreamDecoder.TryGetSingle(FieldId: UInt32; var value: Single): Boolean;
var
  _type: TpbWireType;
begin
  Result := FindField(FieldId, _type) and pbStreamFieldAsSingle(stream, _type, value, GetRemainBytes);
end;

function TProtoBufferStreamDecoder.TryGetUInt32(FieldId: UInt32; var value: UInt32): Boolean;
var
  _type: TpbWireType;
begin
  Result := FindField(FieldId, _type) and pbStreamFieldAsUInt32(stream, _type, value, GetRemainBytes);
end;

function TProtoBufferStreamDecoder.TryGetUInt64(FieldId: UInt32; var value: UInt64): Boolean;
var
  _type: TpbWireType;
begin
  Result := FindField(FieldId, _type) and pbStreamFieldAsUInt64(stream, _type, value, GetRemainBytes);
end;

function TProtoBufferStreamDecoder.TryGetUnicodeString(FieldId: UInt32; var value: UnicodeString): Boolean;
var
  _type: TpbWireType;
begin
  Result := FindField(FieldId, _type) and pbStreamFieldAsUStr(stream, _type, value, GetRemainBytes);
end;

{ TProtoBufferEncoder }

function TProtoBufferEncoder.AvailableBytes: Integer;
begin
  Result := buf + len - ptr;
end;

procedure TProtoBufferEncoder.CheckOverflow;
begin
  if Assigned(buf) and (ptr > buf + len) then
    raise EpbEncodeError.Create(SErr_Overflow);
end;

function TProtoBufferEncoder.GetDataLength: Integer;
begin
  Result := ptr - buf;
end;

procedure TProtoBufferEncoder.reset;
begin
  ptr := buf;
end;

procedure TProtoBufferEncoder.SetBuffer(_buf: PAnsiChar; _len: Integer);
begin
  buf := _buf;
  len := _len;
  ptr := buf;
end;

procedure TProtoBufferEncoder.SetStringBuffer(const s: RawByteString);
begin
  buf := PAnsiChar(s);
  len := Length(s);
  ptr := buf;
end;

procedure TProtoBufferEncoder.WriteBytes(FieldId: UInt32; const _buf; _len: Integer);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarBytes);
  vi.EncodeUInt32(_len);
  Inc(ptr, vi.WriteBuffer(ptr^, AvailableBytes));

  if (_len > 0) and (AvailableBytes >= _len) then
    Move(_buf, ptr^, _len);

  Inc(ptr, _len);
  CheckOverflow;
end;

procedure TProtoBufferEncoder.WriteDouble(FieldId: UInt32; value: Double);
begin
  Self.WriteHeader(FieldId, pwt64Bit);

  if AvailableBytes >= 8 then
    PDouble(ptr)^ := value;

  Inc(ptr, 8);
  CheckOverflow;
end;

procedure TProtoBufferEncoder.WriteHeader(FieldId: UInt32; WireType: TpbWireType);
var
  vi: TpbVarInt;
begin
  vi.EncodeUInt32(EncodeFieldHeader(FieldId, WireType));
  Inc(ptr, vi.WriteBuffer(ptr^, AvailableBytes));
  CheckOverflow;
end;

procedure TProtoBufferEncoder.WriteInt32(FieldId: UInt32; value: Int32);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  vi.EncodeInt32(value);
  Inc(ptr, vi.WriteBuffer(ptr^, AvailableBytes));
  CheckOverflow
end;

procedure TProtoBufferEncoder.WriteInt64(FieldId: UInt32; value: Int64);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  vi.EncodeInt64(value);
  Inc(ptr, vi.WriteBuffer(ptr^, AvailableBytes));
  CheckOverflow
end;

procedure TProtoBufferEncoder.WriteRawByteString(FieldId: UInt32; const value: RawByteString);
begin
  Self.WriteBytes(FieldId, Pointer(value)^, Length(value));
end;

procedure TProtoBufferEncoder.WriteRecord(FieldId: UInt32; const value: TProtoBufferEncoder);
begin
  Self.WriteBytes(FieldId, value.buf^, value.GetDataLength);
end;

procedure TProtoBufferEncoder.WriteSingle(FieldId: UInt32; value: Single);
begin
  Self.WriteHeader(FieldId, pwt32Bit);

  if AvailableBytes >= 4 then
    PSingle(ptr)^ := value;

  Inc(ptr, 4);
  CheckOverflow;
end;

procedure TProtoBufferEncoder.WriteUInt32(FieldId, value: UInt32);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  vi.EncodeUInt32(value);
  Inc(ptr, vi.WriteBuffer(ptr^, AvailableBytes));
  CheckOverflow
end;

procedure TProtoBufferEncoder.WriteUInt64(FieldId: UInt32; value: UInt64);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  vi.EncodeUInt64(value);
  Inc(ptr, vi.WriteBuffer(ptr^, AvailableBytes));
  CheckOverflow;
end;

procedure TProtoBufferEncoder.WriteUnicodeString(FieldId: UInt32; const value: UnicodeString);
var
  tmp: RawByteString;
begin
  if Assigned(buf) then
  begin
    tmp := UTF8Encode(value);
    Self.WriteBytes(FieldId, Pointer(tmp)^, Length(tmp));
    CheckOverflow;
  end
  else
    Self.WriteBytes(FieldId, tmp, BufToMultiByteTest(PWideChar(value), Length(value), CP_UTF8));
end;

procedure TProtoBufferEncoder.WriteVarBytesHeader(FieldId, NumOfBytes: UInt32);
var
  vi: TpbVarInt;
begin
  vi.EncodeUInt32(EncodeFieldHeader(FieldId, pwtVarBytes));
  Inc(ptr, vi.WriteBuffer(ptr^, AvailableBytes));
  CheckOverflow;
  vi.EncodeUInt32(NumOfBytes);
  Inc(ptr, vi.WriteBuffer(ptr^, AvailableBytes));
  CheckOverflow;
end;

procedure TProtoBufferEncoder.WriteVarInt(FieldId: UInt32; const value: TpbVarInt);
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  Inc(ptr, value.WriteBuffer(ptr^, AvailableBytes));
  CheckOverflow;
end;

{ TProtoBufferStreamEncoder }

function TProtoBufferStreamEncoder.GetDataLength: Int64;
begin
  Result := CurPos - StartPos;
end;

procedure TProtoBufferStreamEncoder.reset;
begin
  if Assigned(stream) then
    stream.Position := StartPos;

  CurPos := StartPos;
end;

procedure TProtoBufferStreamEncoder.SetStream(s: TStream);
begin
  stream := s;

  if Assigned(s) then
    StartPos := s.Position
  else
    StartPos := 0;

  CurPos := StartPos;
end;

procedure TProtoBufferStreamEncoder.WriteBytes(FieldId: UInt32; const _buf; _len: Integer);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarBytes);
  vi.EncodeUInt32(_len);
  Inc(CurPos, vi.WriteStream(stream));

  if (_len > 0) and Assigned(stream) then
    stream.WriteBuffer(_buf,  _len);

  Inc(CurPos, _len);
end;

procedure TProtoBufferStreamEncoder.WriteDouble(FieldId: UInt32; value: Double);
begin
  Self.WriteHeader(FieldId, pwt64Bit);

  if Assigned(stream) then
    stream.WriteBuffer(value, SizeOf(value));

  Inc(CurPos, 8);
end;

procedure TProtoBufferStreamEncoder.WriteHeader(FieldId: UInt32; WireType: TpbWireType);
var
  vi: TpbVarInt;
begin
  vi.EncodeUInt32(EncodeFieldHeader(FieldId, WireType));
  Inc(CurPos, vi.WriteStream(stream));
end;

procedure TProtoBufferStreamEncoder.WriteInt32(FieldId: UInt32; value: Int32);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  vi.EncodeInt32(value);
  Inc(CurPos, vi.WriteStream(stream));
end;

procedure TProtoBufferStreamEncoder.WriteInt64(FieldId: UInt32; value: Int64);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  vi.EncodeInt64(value);
  Inc(CurPos, vi.WriteStream(stream));
end;

procedure TProtoBufferStreamEncoder.WriteRawByteString(FieldId: UInt32; const value: RawByteString);
begin
  Self.WriteBytes(FieldId, Pointer(value)^, Length(value));
end;

procedure TProtoBufferStreamEncoder.WriteRecord(FieldId: UInt32; const value: TProtoBufferStreamEncoder);
var
  vi: TpbVarInt;
  _len: Int64;
begin
  Self.WriteHeader(FieldId, pwtVarBytes);
  _len := value.GetDataLength;
  vi.EncodeUInt64(_len);
  Inc(CurPos, vi.WriteStream(stream));

  if (_len > 0) and Assigned(stream) then
  begin
    value.stream.Position := value.StartPos;
    stream.CopyFrom(value.stream, _len);
  end;

  Inc(CurPos, _len);
end;

procedure TProtoBufferStreamEncoder.WriteSingle(FieldId: UInt32; value: Single);
begin
  Self.WriteHeader(FieldId, pwt32Bit);

  if Assigned(stream) then
    stream.WriteBuffer(value, SizeOf(value));

  Inc(CurPos, 4);
end;

procedure TProtoBufferStreamEncoder.WriteUInt32(FieldId, value: UInt32);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  vi.EncodeUInt32(value);
  Inc(CurPos, vi.WriteStream(stream));
end;

procedure TProtoBufferStreamEncoder.WriteUInt64(FieldId: UInt32; value: UInt64);
var
  vi: TpbVarInt;
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  vi.EncodeUInt64(value);
  Inc(CurPos, vi.WriteStream(stream));
end;

procedure TProtoBufferStreamEncoder.WriteUnicodeString(FieldId: UInt32; const value: UnicodeString);
var
  tmp: RawByteString;
begin
  if Assigned(stream) then
  begin
    tmp := UTF8Encode(value);
    Self.WriteBytes(FieldId, Pointer(tmp)^, Length(tmp));
  end
  else
    Self.WriteBytes(FieldId, tmp, BufToMultiByteTest(PWideChar(value), Length(value), CP_UTF8));
end;

procedure TProtoBufferStreamEncoder.WriteVarBytesHeader(FieldId, NumOfBytes: UInt32);
var
  vi: TpbVarInt;
begin
  vi.EncodeUInt32(EncodeFieldHeader(FieldId, pwtVarBytes));
  Inc(CurPos, vi.WriteStream(stream));
  vi.EncodeUInt32(NumOfBytes);
  Inc(CurPos, vi.WriteStream(stream));
end;

procedure TProtoBufferStreamEncoder.WriteVarInt(FieldId: UInt32; const value: TpbVarInt);
begin
  Self.WriteHeader(FieldId, pwtVarInt);
  Inc(CurPos, value.WriteStream(stream));
end;

{ EpbException }

constructor EpbException.Create(AErrorCode: Integer);
begin
  FErrorCode := AErrorCode;
  inherited Create('');
end;

initialization

if IsDebuggerPresent then
  SelfTest;

end.
