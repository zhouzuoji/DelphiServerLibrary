unit DSLSQLite3;

interface

uses
  SysUtils, Classes, Windows, sqlite3, DB, DSLUtils ,AnsiStrings;

type
  ESQLiteError = class(Exception)
  private
    FErrorCode: Integer;
  public
    constructor Create(db: TSQLiteHandle; const operation: string; errcode: Integer); overload;
    constructor Create(errcode: Integer; const msg: string); overload;
    property ErrorCode: Integer read FErrorCode;
  end;

  TSQLiteFieldType = (ftUnknown, ftInteger, ftFloat, ftString, ftBlob, ftNull);

  TSQLiteTransMode = (sqliteDeferredTrans, sqliteImmediateTrans, sqliteExclusivTrans);
  
  TSQLiteConnection = record
  private
    FHandle: TSQLiteHandle;
    FCharset: RawByteString;
    FCodePage: Integer;
    procedure SetCharset(const Value: RawByteString);
    procedure SetCodePage(const Value: Integer);
  public
    procedure init;
    procedure Open(FileName: PWideChar);
    procedure Close;
    function ExecSQL(sql: PAnsiChar; throwException: Boolean = True): Integer;
    function ExecSQL16s(const sql: UnicodeString; throwException: Boolean = True): Integer;
    function GetLastInsertRowid: Int64;
    procedure BeginTrans(mode: TSQLiteTransMode = sqliteDeferredTrans);
    procedure CommitTrans;
    procedure RollbackTrans;
    property Handle: TSQLiteHandle read FHandle;
    property CodePage: Integer read FCodePage write SetCodePage;
    property Charset: RawByteString read FCharset write SetCharset;
  end;
  PSQLiteConnection = ^TSQLiteConnection;

  PSQLiteQuery = ^TSQLiteQuery;

  TSQLiteField = record
  private
    FQuery: PSQLiteQuery;
    FIndex: Integer;
    function GetAsAnsiString: AnsiString;
    function GetAsFloat: Double;
    function GetAsInt64: Int64;
    function GetAsInteger: Integer;
    function GetAsRawByte: RawByteString;
    function GetAsString: string;
    function GetAsUnicodeString: UnicodeString;
    function GetFieldType: TSQLiteFieldType;
    function GetFieldName: string;
    function GetFieldTypeName: string;
    function GetBytes: RawByteString;
    function GetStream: TStream;
  public
    function valid: Boolean;
    function IsNull: Boolean;
    procedure SaveToStream(stream: TStream);
    property FieldType: TSQLiteFieldType read GetFieldType;
    property AsInteger: Integer read GetAsInteger;
    property AsInt64: Int64 read GetAsInt64;
    property AsFloat: Double read GetAsFloat;
    property AsString: string read GetAsString;
    property AsRawByte: RawByteString read GetAsRawByte;
    property AsAnsiString: AnsiString read GetAsAnsiString;
    property AsUnicodeString: UnicodeString read GetAsUnicodeString;
    property AsBytes: RawByteString read GetBytes;
    property AsStream: TStream read GetStream;
    property FieldName: string read GetFieldName;
    property FieldTypeName: string read GetFieldTypeName;
  end;

  TSQLiteParameter = record
  private
    FQuery: PSQLiteQuery;
    FIndex: Integer;
  public
    function valid: Boolean;
    procedure BindNull;
    procedure BindAnsiString(const value: AnsiString);
    procedure BindFloat(value: Double);
    procedure BindInt64(value: Int64);
    procedure BindInteger(value: Integer);
    procedure BindRawBytes(const value: RawByteString);
    procedure BindString(const value: string);
    procedure BindUnicodeString(const value: UnicodeString);
    procedure BindBlob(buf: Pointer; len: Integer); overload;
    procedure BindBlob(value: TStream); overload;
    procedure BindBlob(const value: RawByteString); overload;
  end;

  TSQLiteQuery = record
  private
    FConnection: PSQLiteConnection;
    FStatement: TSQLiteHandle;
    FPrepared: Boolean;
    FActive: Boolean;
    FEof: Boolean;
    function GetFields(Index: Integer): TSQLiteField;
    procedure SetConnection(Value: PSQLiteConnection);
    function GetFieldCount: Integer;
    function GetParamCount: Integer;
    function GetParams(index: Integer): TSQLiteParameter;
  public
    procedure init;
    procedure prepare(sql: PAnsiChar);
    procedure prepare16s(const sql: UnicodeString);
    procedure close;
    procedure Free;
    procedure reset;
    procedure open;
    procedure next;
    function ExecSQL: Integer;
    function FindField(const name: RawByteString): TSQLiteField;
    function FieldByName(const name: RawByteString): TSQLiteField;
    function FindParameter(const name: RawByteString): TSQLiteParameter;
    function ParamByName(const name: RawByteString): TSQLiteParameter;
    property Connection: PSQLiteConnection read FConnection write SetConnection;
    property Statement: TSQLiteHandle read FStatement;
    property Fields[index: Integer]: TSQLiteField read GetFields;
    property FieldCount: Integer read GetFieldCount;
    property Params[index: Integer]: TSQLiteParameter read GetParams;
    property ParamCount: Integer read GetParamCount;
    property Active: Boolean read FActive;
    property Prepared: Boolean read FPrepared;
    property Eof: Boolean read FEof;
  end;

implementation

procedure SQLiteCheckErrorCode(db: TSQLiteHandle; const operation: string; code: Integer);
begin
  if (code <> SQLITE_OK) and (code <> SQLITE_MISUSE) then
    raise ESQLiteError.Create(db, operation, code);
end;

{ TSQLiteQuery }

procedure TSQLiteQuery.close;
begin
  if Assigned(FStatement) then
  begin
    sqlite3_finalize(FStatement);
    FStatement := nil;
    FActive := False;
    FPrepared := False;
    FEof := True;
  end;
end;

function TSQLiteQuery.ExecSQL: Integer;
begin
  next;
  Result := sqlite3_changes(FConnection.Handle);
end;

function TSQLiteQuery.FieldByName(const name: RawByteString): TSQLiteField;
begin
  Result := FindField(name);

  if (Result.FQuery = nil) or (Result.FIndex < 0) then
    raise EDatabaseError.Create(Format('Field ''%s'' not found', [name]));
end;

function TSQLiteQuery.FindField(const name: RawByteString): TSQLiteField;
var
  i: Integer;
begin
  Result.FQuery := nil;
  Result.FIndex := -1;

  for i := 0 to Self.FieldCount - 1 do
  begin
    if {$if CompilerVersion > 22}AnsiStrings.{$ifend}StrIComp(PAnsiChar(name), sqlite3_column_name(FStatement, i)) = 0 then
    begin
      Result.FQuery := @Self;
      Result.FIndex := i;
      Break;
    end;
  end;
end;

function TSQLiteQuery.FindParameter(const name: RawByteString): TSQLiteParameter;
begin
  Result.FIndex := sqlite3_bind_parameter_index(FStatement, PAnsiChar(name));

  if Result.FIndex > 0 then Result.FQuery := @Self
  else Result.FQuery := nil;
end;

procedure TSQLiteQuery.Free;
begin
  Self.close;
end;

function TSQLiteQuery.GetFieldCount: Integer;
begin
  Result := sqlite3_column_count(FStatement);
end;

function TSQLiteQuery.GetFields(Index: Integer): TSQLiteField;
begin
  Result.FQuery := @Self;
  Result.FIndex := index;
end;

function TSQLiteQuery.GetParamCount: Integer;
begin
  Result := sqlite3_bind_parameter_count(Self.FStatement);
end;

function TSQLiteQuery.GetParams(index: Integer): TSQLiteParameter;
begin
  Result.FQuery := @Self;
  Result.FIndex := index;
end;

procedure TSQLiteQuery.init;
begin
  FConnection := nil;
  FStatement := nil;
  FActive := False;
  FPrepared := False;
  FEof := True;
end;

procedure TSQLiteQuery.next;
var
  code: Integer;
begin
  if FPrepared and (not FActive or not FEof) then
  begin
    code := sqlite3_step(FStatement);

    if code = SQLITE_ROW then
    begin
      FActive := True;
      FEof := False;
    end
    else if code = SQLITE_DONE then
    begin
      FActive := True;
      FEof := True;
    end
    else if not FActive and (code = SQLITE_ERROR) then
      SQLiteCheckErrorCode(FConnection.Handle, 'sqlite3_step', sqlite3_reset(FStatement))
    else
      raise ESQLiteError.Create(FConnection.Handle, 'sqlite3_step', code);
  end;
end;

procedure TSQLiteQuery.open;
begin
  Self.next;
end;

function TSQLiteQuery.ParamByName(const name: RawByteString): TSQLiteParameter;
begin
  Result.FIndex := sqlite3_bind_parameter_index(FStatement, PAnsiChar(name));

  if Result.FIndex > 0 then Result.FQuery := @Self
  else
    raise EDatabaseError.Create(Format('Parameter ''%s'' not found', [name]));
end;

procedure TSQLiteQuery.prepare(sql: PAnsiChar);
begin
  Close;
  SQLiteCheckErrorCode(FConnection.Handle, 'sqlite3_prepare', sqlite3_prepare(FConnection.Handle, sql, -1, FStatement, nil));
  FPrepared := True;
end;

procedure TSQLiteQuery.prepare16s(const sql: UnicodeString);
begin
  Self.prepare(PAnsiChar(UStrToMultiByte(sql, FConnection.CodePage)));
end;

procedure TSQLiteQuery.reset;
begin
  if FPrepared then
  begin
    SQLiteCheckErrorCode(FConnection.Handle, 'sqlite3_reset', sqlite3_reset(FStatement));
    FActive := False;
    FEof := True;
  end;
end;

procedure TSQLiteQuery.SetConnection(Value: PSQLiteConnection);
begin
  if value <> FConnection then
  begin
    Close;
    FConnection := Value;
  end;
end;

{ TSQLiteConnection }

procedure TSQLiteConnection.BeginTrans(mode: TSQLiteTransMode);
begin
  case mode of
    sqliteDeferredTrans: Self.ExecSQL('BEGIN DEFERRED TRANSACTION;');
    sqliteImmediateTrans: Self.ExecSQL('BEGIN IMMEDIATE TRANSACTION;');
    sqliteExclusivTrans: Self.ExecSQL('BEGIN EXCLUSIVE TRANSACTION;');
  end;
end;

procedure TSQLiteConnection.Close;
begin
  if Assigned(FHandle) then
  begin
    sqlite3_close(FHandle);
    FHandle := nil;
  end;
end;

procedure TSQLiteConnection.CommitTrans;
begin
  Self.ExecSQL('COMMIT');
end;

function TSQLiteConnection.ExecSQL(sql: PAnsiChar; throwException: Boolean): Integer;
var
  errmsg: PAnsiChar;
  s: string;
  code: Integer;
begin
  code := sqlite3_exec(FHandle, sql, nil, nil, errmsg);
  if SQLITE_OK = code then
    Result := sqlite3_changes(Self.Handle)
  else if throwException then
  begin
    if errmsg <> nil then
    begin
      s := 'sqlite3_exec: ' + string(UTF8DecodeCStr(errmsg));
      sqlite3_free(errmsg);
      raise ESQLiteError.Create(code, s);
    end
    else
      raise ESQLiteError.Create(FHandle, 'sqlite3_exec', code);
  end
  else
    Result := -1;
end;

function TSQLiteConnection.ExecSQL16s(const sql: UnicodeString; throwException: Boolean): Integer;
begin
  Result := Self.ExecSQL(PAnsiChar(UStrToMultiByte(sql, Self.CodePage)), throwException);
end;

function TSQLiteConnection.GetLastInsertRowid: Int64;
begin
  Result := sqlite3_last_insert_rowid(Self.Handle);
end;

procedure TSQLiteConnection.init;
begin
  FHandle := nil;
  FCharset := 'cp_acp';
  FCodePage := CP_ACP;
end;

procedure TSQLiteConnection.Open(FileName: PWideChar);
var
  ret: Integer;
begin
  ret := sqlite3_open16(FileName, FHandle);

  if ret <> SQLITE_OK then
    raise ESQLiteError.Create(ret, 'sqlite3_open16 fail: ' + IntToStr(ret));
end;

procedure TSQLiteConnection.RollbackTrans;
begin
  Self.ExecSQL('ROLLBACK');
end;

procedure TSQLiteConnection.SetCharset(const Value: RawByteString);
var
  tmp: Integer;
begin
  tmp := CodePageName2ID(Value);

  if tmp <> -1 then
  begin
    FCharset := Value;
    FCodePage := tmp;
  end;
end;

procedure TSQLiteConnection.SetCodePage(const Value: Integer);
begin
  FCodePage := Value;
  FCharset := CodePageID2Name(FCodePage);
end;

{ ESQLiteError }

constructor ESQLiteError.Create(db: TSQLiteHandle; const operation: string; errcode: Integer);
begin
  FErrorCode := errcode;
  inherited Create(operation + ': ' + string(WinAPI_UTF8Decode(sqlite3_errmsg(db), -1)));
end;

constructor ESQLiteError.Create(errcode: Integer; const msg: string);
begin
  FErrorCode := errcode;
  inherited Create(msg);
end;

{ TSQLiteField }

function TSQLiteField.GetAsAnsiString: AnsiString;
var
  buf: PAnsiChar;
  CodePage: Integer;
begin
  buf := sqlite3_column_text(FQuery.Statement, FIndex);

  if buf = nil then Result := ''
  else begin
    CodePage := FQuery.Connection.CodePage;
    if (CodePage = CP_ACP) or (DWORD(CodePage) = GetACP) then Result := AnsiString(buf)
    else Result := AnsiString(BufToUnicode(buf, -1, CodePage));
  end;
end;

function TSQLiteField.GetAsFloat: Double;
begin
  Result := sqlite3_column_double(FQuery.Statement, FIndex);
end;

function TSQLiteField.GetAsInt64: Int64;
begin
  Result := sqlite3_column_int64(FQuery.Statement, FIndex);
end;

function TSQLiteField.GetAsInteger: Integer;
begin
  Result := sqlite3_column_int64(FQuery.Statement, FIndex);
end;

function TSQLiteField.GetAsRawByte: RawByteString;
begin
  Result := RawByteString(sqlite3_column_text(FQuery.Statement, FIndex));
end;

function TSQLiteField.GetAsString: string;
begin
  Result := GetAsUnicodeString;
end;

function TSQLiteField.GetAsUnicodeString: UnicodeString;
var
  buf: PAnsiChar;
begin
  buf := sqlite3_column_text(FQuery.Statement, FIndex);

  if buf = nil then Result := ''
  else Result := BufToUnicode(buf, -1, FQuery.Connection.CodePage);
end;

function TSQLiteField.GetBytes: RawByteString;
var
  L: Integer;
  pData: Pointer;
begin
  L := sqlite3_column_bytes(FQuery.Statement, FIndex);
  pData := sqlite3_column_blob(FQuery.Statement, FIndex);

  if L = 0 then
    Result := ''
  else begin
    SetLength(Result, L);
    Move(pData^, Pointer(Result)^, L);
  end;
end;

function TSQLiteField.GetFieldName: string;
begin
  Result := string(RawByteString(sqlite3_column_name(FQuery.Statement, FIndex)));
end;

function TSQLiteField.GetFieldType: TSQLiteFieldType;
begin
  case sqlite3_column_type(FQuery.FStatement, FIndex) of
    SQLITE_INTEGER: Result := ftInteger;
    SQLITE_FLOAT: Result := ftFloat;
    SQLITE_TEXT: Result := ftString;
    SQLITE_BLOB: Result := ftBlob;
    SQLITE_NULL: Result := ftNull;
    else Result := ftUnknown;
  end;
end;

function TSQLiteField.GetFieldTypeName: string;
begin
  Result := string(RawByteString(sqlite3_column_decltype(FQuery.Statement, FIndex)));
end;

function TSQLiteField.GetStream: TStream;
var
  L: Integer;
  pData: Pointer;
begin
  L := sqlite3_column_bytes(FQuery.Statement, FIndex);
  pData := sqlite3_column_blob(FQuery.Statement, FIndex);

  if L = 0 then Result := nil
  else begin
    Result := TMemoryStream.Create;
    Result.WriteBuffer(pData^, L);
  end;
end;

function TSQLiteField.IsNull: Boolean;
begin
  Result := Self.FieldType = ftNull;
end;

procedure TSQLiteField.SaveToStream(stream: TStream);
begin
  stream.WriteBuffer(sqlite3_column_blob(FQuery.Statement, FIndex)^, sqlite3_column_bytes(FQuery.Statement, FIndex));
end;

function TSQLiteField.valid: Boolean;
begin
  Result := Assigned(FQuery) and (FIndex >= 0);
end;

{ TSQLiteParameter }

procedure TSQLiteParameter.BindAnsiString(const value: AnsiString);
var
  CodePage: Integer;
  tmp: RawByteString;
begin
  CodePage := FQuery.Connection.CodePage;

  if (CodePage = CP_ACP) or (DWORD(CodePage) = GetACP) then tmp := value
  else tmp := UStrToMultiByte(UnicodeString(value), CodePage);

  sqlite3_bind_text(FQuery.FStatement, FIndex, PAnsiChar(tmp), Length(tmp), nil);
end;

procedure TSQLiteParameter.BindBlob(buf: Pointer; len: Integer);
begin
  sqlite3_bind_blob(FQuery.Statement, FIndex, buf, len, nil);
end;

procedure TSQLiteParameter.BindBlob(value: TStream);
var
  buf: Pointer;
begin
  if value is TCustomMemoryStream then
    sqlite3_bind_blob(FQuery.Statement, FIndex, TCustomMemoryStream(value).Memory, value.Size, nil)
  else begin
    buf := System.GetMemory(value.Size);

    try
      sqlite3_bind_blob(FQuery.Statement, FIndex, buf, value.Size, nil);
    finally
      System.FreeMemory(buf);
    end;
  end;
end;

procedure TSQLiteParameter.BindBlob(const value: RawByteString);
begin
  sqlite3_bind_blob(FQuery.Statement, FIndex, Pointer(value), Length(value), nil);
end;

procedure TSQLiteParameter.BindFloat(value: Double);
begin
  sqlite3_bind_double(FQuery.Statement, FIndex, value);
end;

procedure TSQLiteParameter.BindInt64(value: Int64);
begin
  sqlite3_bind_int64(FQuery.Statement, FIndex, value);
end;

procedure TSQLiteParameter.BindInteger(value: Integer);
begin
  sqlite3_bind_int(FQuery.Statement, FIndex, value);
end;

procedure TSQLiteParameter.BindNull;
begin
  sqlite3_bind_null(FQuery.Statement, FIndex);
end;

procedure TSQLiteParameter.BindRawBytes(const value: RawByteString);
begin
  sqlite3_bind_text(FQuery.FStatement, FIndex, PAnsiChar(value), Length(value), nil);
end;

procedure TSQLiteParameter.BindString(const value: string);
begin
  Self.BindUnicodeString(value);
end;

procedure TSQLiteParameter.BindUnicodeString(const value: UnicodeString);
var
  tmp: RawByteString;
begin
  tmp := UStrToMultiByte(UnicodeString(value), FQuery.Connection.CodePage);
  sqlite3_bind_text(FQuery.FStatement, FIndex, PAnsiChar(tmp), Length(tmp), nil);
end;

function TSQLiteParameter.valid: Boolean;
begin
  Result := Assigned(Self.FQuery) and (Self.FIndex > 0);
end;

end.
