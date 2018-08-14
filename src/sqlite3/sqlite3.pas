unit sqlite3;

interface

uses
  SysUtils, Classes, Windows;

const
  SQLITE_ISO8859 = 1; {$EXTERNALSYM SQLITE_ISO8859}
  MASTER_NAME = 'sqlite_master'; {$EXTERNALSYM MASTER_NAME}
  TEMP_MASTER_NAME = 'sqlite_temp_master'; {$EXTERNALSYM TEMP_MASTER_NAME}

  // Return values for sqlite_exec() and sqlite_step()
  SQLITE_OK = 0; {$EXTERNALSYM SQLITE_OK} // Successful result
  SQLITE_ERROR = 1; {$EXTERNALSYM SQLITE_ERROR} // SQL error or missing database
  SQLITE_INTERNAL = 2; {$EXTERNALSYM SQLITE_INTERNAL} // An internal logic error in SQLite
  SQLITE_PERM = 3; {$EXTERNALSYM SQLITE_PERM} // Access permission denied
  SQLITE_ABORT = 4; {$EXTERNALSYM SQLITE_ABORT} // Callback routine requested an abort
  SQLITE_BUSY = 5; {$EXTERNALSYM SQLITE_BUSY} // The database file is locked
  SQLITE_LOCKED = 6; {$EXTERNALSYM SQLITE_LOCKED} // A table in the database is locked
  SQLITE_NOMEM = 7; {$EXTERNALSYM SQLITE_NOMEM} // A malloc() failed
  SQLITE_READONLY = 8; {$EXTERNALSYM SQLITE_READONLY} // Attempt to write a readonly database
  _SQLITE_INTERRUPT = 9; {$EXTERNALSYM _SQLITE_INTERRUPT} // Operation terminated by sqlite_interrupt()
  SQLITE_IOERR = 10; {$EXTERNALSYM SQLITE_IOERR} // Some kind of disk I/O error occurred
  SQLITE_CORRUPT = 11; {$EXTERNALSYM SQLITE_CORRUPT} // The database disk image is malformed
  SQLITE_NOTFOUND = 12; {$EXTERNALSYM SQLITE_NOTFOUND} // (Internal Only) Table or record not found
  SQLITE_FULL = 13; {$EXTERNALSYM SQLITE_FULL} // Insertion failed because database is full
  SQLITE_CANTOPEN = 14; {$EXTERNALSYM SQLITE_CANTOPEN} // Unable to open the database file
  SQLITE_PROTOCOL = 15; {$EXTERNALSYM SQLITE_PROTOCOL} // Database lock protocol error
  SQLITE_EMPTY = 16; {$EXTERNALSYM SQLITE_EMPTY} // (Internal Only) Database table is empty
  SQLITE_SCHEMA = 17; {$EXTERNALSYM SQLITE_SCHEMA} // The database schema changed
  SQLITE_TOOBIG = 18; {$EXTERNALSYM SQLITE_TOOBIG} // Too much data for one row of a table
  SQLITE_CONSTRAINT = 19; {$EXTERNALSYM SQLITE_CONSTRAINT} // Abort due to contraint violation
  SQLITE_MISMATCH = 20; {$EXTERNALSYM SQLITE_MISMATCH} // Data type mismatch
  SQLITE_MISUSE = 21; {$EXTERNALSYM SQLITE_MISUSE} // Library used incorrectly
  SQLITE_NOLFS = 22; {$EXTERNALSYM SQLITE_NOLFS} // Uses OS features not supported on host
  SQLITE_AUTH = 23; {$EXTERNALSYM SQLITE_AUTH} // Authorization denied
  SQLITE_FORMAT = 24; {$EXTERNALSYM SQLITE_FORMAT} // Auxiliary database format error
  SQLITE_RANGE = 25; {$EXTERNALSYM SQLITE_RANGE} // 2nd parameter to sqlite_bind out of range
  SQLITE_NOTADB = 26; {$EXTERNALSYM SQLITE_NOTADB} // File opened that is not a database file
  SQLITE_ROW = 100; {$EXTERNALSYM SQLITE_ROW} // sqlite_step() has another row ready
  SQLITE_DONE = 101; {$EXTERNALSYM SQLITE_DONE} // sqlite_step() has finished executing

  {
    The second parameter to the access authorization function above will
    be one of the values below.  These values signify what kind of operation
    is to be authorized.  The 3rd and 4th parameters to the authorization
    function will be parameters or NULL depending on which of the following
    codes is used as the second parameter.  The 5th parameter is the name
    of the database ("main", "temp", etc.) if applicable.  The 6th parameter
    is the name of the inner-most trigger or view that is responsible for
    the access attempt or NULL if this access attempt is directly from
    input SQL code.

    Arg-3           Arg-4
    }
  SQLITE_COPY = 0; {$EXTERNALSYM SQLITE_COPY} // Table Name      File Name
  SQLITE_CREATE_INDEX = 1; {$EXTERNALSYM SQLITE_CREATE_INDEX} // Index Name      Table Name
  SQLITE_CREATE_TABLE = 2; {$EXTERNALSYM SQLITE_CREATE_TABLE} // Table Name      NULL
  SQLITE_CREATE_TEMP_INDEX = 3; {$EXTERNALSYM SQLITE_CREATE_TEMP_INDEX} // Index Name      Table Name
  SQLITE_CREATE_TEMP_TABLE = 4; {$EXTERNALSYM SQLITE_CREATE_TEMP_TABLE} // Table Name      NULL
  SQLITE_CREATE_TEMP_TRIGGER = 5; {$EXTERNALSYM SQLITE_CREATE_TEMP_TRIGGER} // Trigger Name    Table Name
  SQLITE_CREATE_TEMP_VIEW = 6; {$EXTERNALSYM SQLITE_CREATE_TEMP_VIEW} // View Name       NULL
  SQLITE_CREATE_TRIGGER = 7; {$EXTERNALSYM SQLITE_CREATE_TRIGGER} // Trigger Name    Table Name
  SQLITE_CREATE_VIEW = 8; {$EXTERNALSYM SQLITE_CREATE_VIEW} // View Name       NULL
  SQLITE_DELETE = 9; {$EXTERNALSYM SQLITE_DELETE} // Table Name      NULL
  SQLITE_DROP_INDEX = 10; {$EXTERNALSYM SQLITE_DROP_INDEX} // Index Name      Table Name
  SQLITE_DROP_TABLE = 11; {$EXTERNALSYM SQLITE_DROP_TABLE} // Table Name      NULL
  SQLITE_DROP_TEMP_INDEX = 12; {$EXTERNALSYM SQLITE_DROP_TEMP_INDEX} // Index Name      Table Name
  SQLITE_DROP_TEMP_TABLE = 13; {$EXTERNALSYM SQLITE_DROP_TEMP_TABLE} // Table Name      NULL
  SQLITE_DROP_TEMP_TRIGGER = 14; {$EXTERNALSYM SQLITE_DROP_TEMP_TRIGGER} // Trigger Name    Table Name
  SQLITE_DROP_TEMP_VIEW = 15; {$EXTERNALSYM SQLITE_DROP_TEMP_VIEW} // View Name       NULL
  SQLITE_DROP_TRIGGER = 16; {$EXTERNALSYM SQLITE_DROP_TRIGGER} // Trigger Name    Table Name
  SQLITE_DROP_VIEW = 17; {$EXTERNALSYM SQLITE_DROP_VIEW} // View Name       NULL
  SQLITE_INSERT = 18; {$EXTERNALSYM SQLITE_INSERT} // Table Name      NULL
  SQLITE_PRAGMA = 19; {$EXTERNALSYM SQLITE_PRAGMA} // Pragma Name     1st arg or NULL
  SQLITE_READ = 20; {$EXTERNALSYM SQLITE_READ} // Table Name      Column Name
  SQLITE_SELECT = 21; {$EXTERNALSYM SQLITE_SELECT} // NULL            NULL
  SQLITE_TRANSACTION = 22; {$EXTERNALSYM SQLITE_TRANSACTION} // NULL            NULL
  SQLITE_UPDATE = 23; {$EXTERNALSYM SQLITE_UPDATE} // Table Name      Column Name
  SQLITE_ATTACH = 24; {$EXTERNALSYM SQLITE_ATTACH} // Filename        NULL
  SQLITE_DETACH = 25; {$EXTERNALSYM SQLITE_DETACH} // Database Name   NULL

  { The return value of the authorization function should be one of the
    following constants: }
  SQLITE_DENY = 1; {$EXTERNALSYM SQLITE_DENY} // Abort the SQL statement with an error
  SQLITE_IGNORE = 2; {$EXTERNALSYM SQLITE_IGNORE} // Don't allow access, but don't generate an error

  SQLITE_INTEGER = 1; {$EXTERNALSYM SQLITE_INTEGER}
  SQLITE_FLOAT = 2; {$EXTERNALSYM SQLITE_FLOAT}
  SQLITE_TEXT = 3; {$EXTERNALSYM SQLITE_TEXT}
  SQLITE_BLOB = 4; {$EXTERNALSYM SQLITE_BLOB}
  SQLITE_NULL = 5; {$EXTERNALSYM SQLITE_NULL}

type
  TSQLiteHandle = Pointer;
  Psqlite_func = Pointer;
  Psqlite_vm = Pointer;

  TPrototype_sqlite3_destructor_type = procedure(user: Pointer); cdecl;
  SQLITE_STATIC = procedure(user: Pointer = nil); cdecl;
  SQLITE_TRANSIENT = procedure(user: Pointer = Pointer(-1)); cdecl;
  Tsqlite_callback = function(p1: Pointer; p2: Integer; var p3: PAnsiChar; var p4: PAnsiChar): Integer; cdecl;
  Tsqlite_simple_callback = function(p1: Pointer): Integer; cdecl;
  Tsqlite_simple_callback0 = function(p1: Pointer): Pointer; cdecl;
  Tsqlite_busy_callback = function(p1: Pointer; const p2: PAnsiChar; p3: Integer): Integer; cdecl;
  Tsqlite_function_callback = procedure(p1: Psqlite_func; p2: Integer; const p3: PPAnsiChar); cdecl;
  Tsqlite_finalize_callback = procedure(p1: Psqlite_func); cdecl;
  Tsqlite_auth_callback = function(p1: Pointer; p2: Integer; const p3: PAnsiChar; const p4: PAnsiChar;
    const p5: PAnsiChar; const p6: PAnsiChar): Integer; cdecl;
  Tsqlite_trace_callback = procedure(p1: Pointer; const p2: PAnsiChar); cdecl;
  TPrototype_sqlite3_open = function(const filename: PAnsiChar; var connection: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_open16 = function(const filename: PWideChar; var connection: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_close = function(db: TSQLiteHandle): Integer; cdecl;

  { prepared statment api }
  TPrototype_sqlite3_prepare = function(db: TSQLiteHandle; // Database handle
    const zSql: PAnsiChar; // SQL statement, UTF-8 encoded
    nBytes: Integer; // Maximum length of zSql in bytes. -1 = null terminated
    out ppStmt: TSQLiteHandle; // OUT: Statement handle
    pzTail: PPAnsiChar // OUT: Pointer to unused portion of zSql
    ): Integer; cdecl;

  TPrototype_sqlite3_prepare_v2 = function(db: TSQLiteHandle; // Database handle
    const zSql: PAnsiChar; // SQL statement, UTF-8 encoded
    nBytes: Integer; // Maximum length of zSql in bytes. -1 = null terminated
    out ppStmt: TSQLiteHandle; // OUT: Statement handle
    pzTail: PPAnsiChar // OUT: Pointer to unused portion of zSql
    ): Integer; cdecl;

  TPrototype_sqlite3_prepare16 = function(db: TSQLiteHandle; // Database handle
    const zSql: PWideChar; // SQL statement, UTF-16 encoded
    nBytes: Integer; // Maximum length of zSql in bytes. -1 = null terminated
    out ppStmt: TSQLiteHandle; // OUT: Statement handle
    pzTail: PPWideChar // OUT: Pointer to unused portion of zSql
    ): Integer; cdecl;

  TPrototype_sqlite3_prepare16_v2 = function(db: TSQLiteHandle; // Database handle
    const zSql: PWideChar; // SQL statement, UTF-16 encoded
    nBytes: Integer; // Maximum length of zSql in bytes. -1 = null terminated
    out ppStmt: TSQLiteHandle; // OUT: Statement handle
    pzTail: PPWideChar // OUT: Pointer to unused portion of zSql
    ): Integer; cdecl;

  TPrototype_sqlite3_bind_parameter_count = function(pStmt: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_bind_parameter_name = function(pStmt: TSQLiteHandle; ParamIndex: Integer): PAnsiChar; cdecl;
  TPrototype_sqlite3_bind_parameter_index = function(pStmt: TSQLiteHandle; const zName: PAnsiChar): Integer; cdecl;
  TPrototype_sqlite3_clear_bindings = function(pStmt: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_column_count = function(pStmt: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_column_name = function(pStmt: TSQLiteHandle; iCol: Integer): PAnsiChar; cdecl;
  TPrototype_sqlite3_column_name16 = function(pStmt: TSQLiteHandle; iCol: Integer): PWideChar; cdecl;
  TPrototype_sqlite3_column_database_name = function(pStmt: TSQLiteHandle; iCol: Integer): PAnsiChar; cdecl;
  TPrototype_sqlite3_column_database_name16 = function(pStmt: TSQLiteHandle; iCol: Integer): PWideChar; cdecl;
  TPrototype_sqlite3_column_table_name = function(pStmt: TSQLiteHandle; iCol: Integer): PAnsiChar; cdecl;
  TPrototype_sqlite3_column_table_name16 = function(pStmt: TSQLiteHandle; iCol: Integer): PWideChar; cdecl;
  TPrototype_sqlite3_column_origin_name = function(pStmt: TSQLiteHandle; iCol: Integer): PAnsiChar; cdecl;
  TPrototype_sqlite3_column_origin_name16 = function(pStmt: TSQLiteHandle; iCol: Integer): PWideChar; cdecl;
  TPrototype_sqlite3_column_decltype = function(pStmt: TSQLiteHandle; iCol: Integer): PAnsiChar; cdecl;
  TPrototype_sqlite3_column_decltype16 = function(pStmt: TSQLiteHandle; iCol: Integer): PWideChar; cdecl;
  TPrototype_sqlite3_step = function(pStmt: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_data_count = function(pStmt: TSQLiteHandle): Integer; cdecl;

  TPrototype_sqlite3_bind_blob = function(pStmt: TSQLiteHandle; ParamIndex: Integer; const Buffer: Pointer;
    N: Integer; ValDestructor: TPrototype_sqlite3_destructor_type): Integer; cdecl;

  TPrototype_sqlite3_bind_double = function(pStmt: TSQLiteHandle; ParamIndex: Integer; Value: Double): Integer; cdecl;
  TPrototype_sqlite3_bind_int = function(pStmt: TSQLiteHandle; ParamIndex: Integer; Value: Integer): Integer; cdecl;
  TPrototype_sqlite3_bind_int64 = function(pStmt: TSQLiteHandle; ParamIndex: Integer; Value: Int64): Integer; cdecl;
  TPrototype_sqlite3_bind_null = function(pStmt: TSQLiteHandle; ParamIndex: Integer): Integer; cdecl;
  TPrototype_sqlite3_bind_text = function(pStmt: TSQLiteHandle; ParamIndex: Integer; const Text: PAnsiChar; N: Integer;
    ValDestructor: TPrototype_sqlite3_destructor_type): Integer; cdecl;

  TPrototype_sqlite3_bind_text16 = function(pStmt: TSQLiteHandle; ParamIndex: Integer; const Text: PWideChar; N: Integer;
    ValDestructor: TPrototype_sqlite3_destructor_type): Integer; cdecl;

  TPrototype_sqlite3_bind_value = function(pStmt: TSQLiteHandle; ParamIndex: Integer;
    const Value: TSQLiteHandle): Integer; cdecl;

  TPrototype_sqlite3_bind_zeroblob = function(pStmt: TSQLiteHandle; ParamIndex: Integer; N: Integer): Integer; cdecl;
  TPrototype_sqlite3_finalize = function(pStmt: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_reset = function(pStmt: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_column_blob = function(Stmt: TSQLiteHandle; iCol: Integer): Pointer; cdecl;
  TPrototype_sqlite3_column_bytes = function(Stmt: TSQLiteHandle; iCol: Integer): Integer; cdecl;
  TPrototype_sqlite3_column_bytes16 = function(Stmt: TSQLiteHandle; iCol: Integer): Integer; cdecl;
  TPrototype_sqlite3_column_double = function(Stmt: TSQLiteHandle; iCol: Integer): Double; cdecl;
  TPrototype_sqlite3_column_int = function(Stmt: TSQLiteHandle; iCol: Integer): Integer; cdecl;
  TPrototype_sqlite3_column_int64 = function(Stmt: TSQLiteHandle; iCol: Integer): Int64; cdecl;
  TPrototype_sqlite3_column_text = function(Stmt: TSQLiteHandle; iCol: Integer): PAnsiChar; cdecl;
  TPrototype_sqlite3_column_text16 = function(Stmt: TSQLiteHandle; iCol: Integer): PWideChar; cdecl;
  TPrototype_sqlite3_column_type = function(Stmt: TSQLiteHandle; iCol: Integer): Integer; cdecl;
  TPrototype_sqlite3_column_value = function(Stmt: TSQLiteHandle; iCol: Integer): TSQLiteHandle; cdecl;
  TPrototype_sqlite3_last_insert_rowid = function(db: TSQLiteHandle): Int64; cdecl;
  TPrototype_sqlite3_exec = function(db: TSQLiteHandle; const sql: PAnsiChar; sqlite3_callback: Tsqlite_callback;
    arg: Pointer; var errmsg: PAnsiChar): Integer; cdecl;

  TPrototype_sqlite3_errmsg = function(db: TSQLiteHandle): PAnsiChar; cdecl;
  TPrototype_sqlite3_errcode = function(db: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_extended_errcode = function(db: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_errstr = function(code: Integer): PAnsiChar; cdecl;
  TPrototype_sqlite3_changes = function(db: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_last_statement_changes = function(db: TSQLiteHandle): Integer; cdecl;
  TPrototype_sqlite3_interrupt = procedure(db: TSQLiteHandle); cdecl;

  TPrototype_sqlite3_complete = function(const sql: PAnsiChar): Integer; cdecl;
  TPrototype_sqlite3_busy_handler = procedure(db: TSQLiteHandle; callback: Tsqlite_busy_callback; ptr: Pointer); cdecl;
  TPrototype_sqlite3_busy_timeout = procedure(db: TSQLiteHandle; ms: Integer); cdecl;

  TPrototype_sqlite3_get_table = function(db: TSQLiteHandle; const sql: PAnsiChar; var resultp: PPAnsiChar; var nrow: Integer;
    var ncolumn: Integer; var errmsg: PAnsiChar): Integer; cdecl;

  TPrototype_sqlite3_free_table = procedure(var result: PAnsiChar); cdecl;
  TPrototype_sqlite3_free = procedure(ptr: Pointer); cdecl;
  TPrototype_sqlite3_libversion = function: PAnsiChar; cdecl;
  TPrototype_sqlite3_libencoding = function: PAnsiChar; cdecl;

  TPrototype_sqlite3_create_function = function(db: TSQLiteHandle; const zName: PAnsiChar; nArg: Integer;
    callback: Tsqlite_function_callback; pUserData: Pointer): Integer; cdecl;

  TPrototype_sqlite3_create_aggregate = function(db: TSQLiteHandle; const zName: PAnsiChar; nArg: Integer;
    callback: Tsqlite_function_callback; finalize: Tsqlite_finalize_callback; pUserData: Pointer): Integer; cdecl;

  TPrototype_sqlite3_function_type = function(db: TSQLiteHandle; const zName: PAnsiChar; datatype: Integer): Integer; cdecl;

  TPrototype_sqlite3_set_result_string = function(func: Psqlite_func; const arg: PAnsiChar; len: Integer;
    UN: Tsqlite_simple_callback): PAnsiChar; cdecl;

  TPrototype_sqlite3_set_result_int = procedure(func: Psqlite_func; arg: Integer); cdecl;
  TPrototype_sqlite3_set_result_double = procedure(func: Psqlite_func; arg: Double); cdecl;

  TPrototype_sqlite3_set_result_error = procedure(func: Psqlite_func; const arg: PAnsiChar; len: Integer); cdecl;

  TPrototype_sqlite3_user_data = function(func: Psqlite_func): Pointer; cdecl;
  TPrototype_sqlite3_aggregate_context = function(func: Psqlite_func; nBytes: Integer): Pointer; cdecl;

  TPrototype_sqlite3_aggregate_count = function(func: Psqlite_func): Integer; cdecl;

  TPrototype_sqlite3_set_authorizer = function(db: TSQLiteHandle; callback: Tsqlite_auth_callback;
    pUserData: Pointer): Integer; cdecl;

  TPrototype_sqlite3_trace = function(db: TSQLiteHandle; callback: Tsqlite_trace_callback;
    ptr: Pointer): Pointer; cdecl;

  TPrototype_sqlite3_progress_handler = procedure(db: TSQLiteHandle; p1: Integer; callback: Tsqlite_simple_callback;
    ptr: Pointer); cdecl;

  TPrototype_sqlite3_commit_hook = function(db: TSQLiteHandle; callback: Tsqlite_simple_callback;
    ptr: Pointer): Pointer; cdecl;

  TPrototype_sqlite3_open_encrypted = function(const zFilename: PAnsiChar; const pKey: PAnsiChar; nKey: Integer;
    var pErrcode: Integer; var pzErrmsg: PAnsiChar): TSQLiteHandle; cdecl;

  TPrototype_sqlite3_rekey = function(db: TSQLiteHandle; const pKey: Pointer; nKey: Integer): Integer; cdecl;
  TPrototype_sqlite3_key = function(db: TSQLiteHandle; const pKey: Pointer; nKey: Integer): Integer; cdecl;

var
  sqlite3_open: TPrototype_sqlite3_open;
  _sqlite3_open16: TPrototype_sqlite3_open16;
  sqlite3_close: TPrototype_sqlite3_close;

  { prepared statement api }
  sqlite3_prepare: TPrototype_sqlite3_prepare;
  sqlite3_prepare_v2: TPrototype_sqlite3_prepare_v2;
  sqlite3_prepare16: TPrototype_sqlite3_prepare16;
  sqlite3_prepare16_v2: TPrototype_sqlite3_prepare16_v2;

  sqlite3_bind_parameter_count: TPrototype_sqlite3_bind_parameter_count;
  sqlite3_bind_parameter_name: TPrototype_sqlite3_bind_parameter_name;
  sqlite3_bind_parameter_index: TPrototype_sqlite3_bind_parameter_index;

  sqlite3_clear_bindings: TPrototype_sqlite3_clear_bindings;
  sqlite3_column_count: TPrototype_sqlite3_column_count;
  sqlite3_column_name: TPrototype_sqlite3_column_name;
  sqlite3_column_name16: TPrototype_sqlite3_column_name16;

  sqlite3_column_database_name: TPrototype_sqlite3_column_database_name;
  sqlite3_column_database_name16: TPrototype_sqlite3_column_database_name16;
  sqlite3_column_table_name: TPrototype_sqlite3_column_table_name;
  sqlite3_column_table_name16: TPrototype_sqlite3_column_table_name16;
  sqlite3_column_origin_name: TPrototype_sqlite3_column_origin_name;
  sqlite3_column_origin_name16: TPrototype_sqlite3_column_origin_name16;

  sqlite3_column_decltype: TPrototype_sqlite3_column_decltype;
  sqlite3_column_decltype16: TPrototype_sqlite3_column_decltype16;

  sqlite3_step: TPrototype_sqlite3_step;
  sqlite3_data_count: TPrototype_sqlite3_data_count;

  sqlite3_bind_blob: TPrototype_sqlite3_bind_blob;
  sqlite3_bind_double: TPrototype_sqlite3_bind_double;
  sqlite3_bind_int: TPrototype_sqlite3_bind_int;
  sqlite3_bind_int64: TPrototype_sqlite3_bind_int64;
  sqlite3_bind_null: TPrototype_sqlite3_bind_null;
  sqlite3_bind_text: TPrototype_sqlite3_bind_text;
  sqlite3_bind_text16: TPrototype_sqlite3_bind_text16;
  sqlite3_bind_value: TPrototype_sqlite3_bind_value;
  sqlite3_bind_zeroblob: TPrototype_sqlite3_bind_zeroblob;

  sqlite3_finalize: TPrototype_sqlite3_finalize;
  sqlite3_reset: TPrototype_sqlite3_reset;

  sqlite3_column_blob: TPrototype_sqlite3_column_blob;
  sqlite3_column_bytes: TPrototype_sqlite3_column_bytes;
  sqlite3_column_bytes16: TPrototype_sqlite3_column_bytes16;
  sqlite3_column_double: TPrototype_sqlite3_column_double;
  sqlite3_column_int: TPrototype_sqlite3_column_int;
  sqlite3_column_int64: TPrototype_sqlite3_column_int64;
  sqlite3_column_text: TPrototype_sqlite3_column_text;
  sqlite3_column_text16: TPrototype_sqlite3_column_text16;
  sqlite3_column_type: TPrototype_sqlite3_column_type;
  sqlite3_column_value: TPrototype_sqlite3_column_value;

  sqlite3_exec: TPrototype_sqlite3_exec;
  sqlite3_errmsg: TPrototype_sqlite3_errmsg;
  _sqlite3_errstr: TPrototype_sqlite3_errstr;
  sqlite3_errcode: TPrototype_sqlite3_errcode;
  sqlite3_extended_errcode: TPrototype_sqlite3_extended_errcode;
  sqlite3_last_insert_rowid: TPrototype_sqlite3_last_insert_rowid;
  sqlite3_changes: TPrototype_sqlite3_changes;
  sqlite3_last_statement_changes: TPrototype_sqlite3_last_statement_changes;
  sqlite3_interrupt: TPrototype_sqlite3_interrupt;
  sqlite3_complete: TPrototype_sqlite3_complete;
  sqlite3_busy_handler: TPrototype_sqlite3_busy_handler;
  sqlite3_busy_timeout: TPrototype_sqlite3_busy_timeout;
  sqlite3_get_table: TPrototype_sqlite3_get_table;
  sqlite3_free_table: TPrototype_sqlite3_free_table;
  sqlite3_free: TPrototype_sqlite3_free;
  sqlite3_libversion: TPrototype_sqlite3_libversion;
  sqlite3_libencoding: TPrototype_sqlite3_libencoding;
  sqlite3_create_function: TPrototype_sqlite3_create_function;
  sqlite3_create_aggregate: TPrototype_sqlite3_create_aggregate;
  sqlite3_function_type: TPrototype_sqlite3_function_type;
  sqlite3_set_result_string: TPrototype_sqlite3_set_result_string;
  sqlite3_set_result_int: TPrototype_sqlite3_set_result_int;
  sqlite3_set_result_double: TPrototype_sqlite3_set_result_double;
  sqlite3_set_result_error: TPrototype_sqlite3_set_result_error;
  sqlite3_user_data: TPrototype_sqlite3_user_data;
  sqlite3_aggregate_context: TPrototype_sqlite3_aggregate_context;
  sqlite3_aggregate_count: TPrototype_sqlite3_aggregate_count;
  sqlite3_set_authorizer: TPrototype_sqlite3_set_authorizer;
  sqlite3_trace: TPrototype_sqlite3_trace;
  sqlite3_progress_handler: TPrototype_sqlite3_progress_handler;
  sqlite3_commit_hook: TPrototype_sqlite3_commit_hook;
  sqlite3_open_encrypted: TPrototype_sqlite3_open_encrypted;
  sqlite3_rekey: TPrototype_sqlite3_rekey;
  sqlite3_key: TPrototype_sqlite3_key;

function sqlite3_loaded: Boolean; inline;
function sqlite3_load_library(s: PWideChar): Boolean;
function sqlite3_open16(const filename: PWideChar; var connection: TSQLiteHandle): Integer;
function sqlite3_errstr(connection: TSQLiteHandle; code: Integer): string;

implementation

var
  g_sqlite3_lib: HMODULE;

procedure unload_sqlite3;
begin
  if g_sqlite3_lib <> 0 then
  begin
    Windows.FreeLibrary(g_sqlite3_lib);
    @sqlite3_open := nil;
  end;
end;

function sqlite3_loaded: Boolean;
begin
  Result := Assigned(@sqlite3_open);
end;

function sqlite3_errstr(connection: TSQLiteHandle; code: Integer): string;
var
  ErrorMessagePointer: PAnsiChar;
  ErrorMessage: String;
  ErrorString: String;
begin
  if code = SQLITE_OK then
  begin
    result := 'not an error';
    Exit;
  end;

  if code = SQLITE_NOMEM then
  begin
    result := 'out of memory';
    Exit;
  end;

  if not Assigned(connection) or not Assigned(_sqlite3_errstr) then
  begin
    case code of
      SQLITE_OK:
        result := 'not an error';
      SQLITE_ERROR:
        result := 'SQL logic error or missing database';
      SQLITE_INTERNAL:
        result := 'internal SQLite implementation flaw';
      SQLITE_PERM:
        result := 'access permission denied';
      SQLITE_ABORT:
        result := 'callback requested query abort';
      SQLITE_BUSY:
        result := 'database is locked';
      SQLITE_LOCKED:
        result := 'database table is locked';
      SQLITE_NOMEM:
        result := 'out of memory';
      SQLITE_READONLY:
        result := 'attempt to write a readonly database';
      _SQLITE_INTERRUPT:
        result := 'interrupted';
      SQLITE_IOERR:
        result := 'disk I/O error';
      SQLITE_CORRUPT:
        result := 'database disk image is malformed';
      SQLITE_NOTFOUND:
        result := 'table or record not found';
      SQLITE_FULL:
        result := 'database is full';
      SQLITE_CANTOPEN:
        result := 'unable to open database file';
      SQLITE_PROTOCOL:
        result := 'database locking protocol failure';
      SQLITE_EMPTY:
        result := 'table contains no data';
      SQLITE_SCHEMA:
        result := 'database schema has changed';
      SQLITE_TOOBIG:
        result := 'too much data for one table row';
      SQLITE_CONSTRAINT:
        result := 'constraint failed';
      SQLITE_MISMATCH:
        result := 'datatype mismatch';
      SQLITE_MISUSE:
        result := 'library routine called out of sequence';
      SQLITE_NOLFS:
        result := 'kernel lacks large file support';
      SQLITE_AUTH:
        result := 'authorization denied';
      SQLITE_FORMAT:
        result := 'auxiliary database format error';
      SQLITE_RANGE:
        result := 'bind index out of range';
      SQLITE_NOTADB:
        result := 'file is encrypted or is not a database';
    else
      result := 'unknown error';
    end;

    Exit;
  end
  else
  begin
    ErrorMessagePointer := _sqlite3_errstr(code);
    ErrorString := Trim(UTF8ToUnicodeString(ErrorMessagePointer));
    ErrorMessagePointer := sqlite3_errmsg(connection);
    ErrorMessage := Trim(UTF8ToUnicodeString(ErrorMessagePointer));
    result := ErrorString + ': ' + ErrorMessage;
  end;
end;

function sqlite3_open16(const filename: PWideChar; var connection: TSQLiteHandle): Integer;
begin
  if Assigned(_sqlite3_open16) then
    Result := _sqlite3_open16(filename, connection)
  else
    Result := sqlite3_open(PAnsiChar(UTF8Encode(filename)), connection);
end;

function sqlite3_load_library(s: PWideChar): Boolean;
begin
  if sqlite3_loaded then
  begin
    Result := True;
    Exit;
  end;

  Result := False;

  if (s = nil) or (s[0] = #0) then
    s := 'sqlite3.dll';

  g_sqlite3_lib := LoadLibraryW(s);

  if g_sqlite3_lib = 0 then
    Exit;

  sqlite3_open := GetProcAddress(g_sqlite3_lib, 'sqlite3_open');

  if not Assigned(sqlite3_open) then
    Exit;

  _sqlite3_open16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_open16');
  sqlite3_close := GetProcAddress(g_sqlite3_lib, 'sqlite3_close');
  sqlite3_prepare := GetProcAddress(g_sqlite3_lib, 'sqlite3_prepare');
  sqlite3_prepare_v2 := GetProcAddress(g_sqlite3_lib, 'sqlite3_prepare_v2');
  sqlite3_prepare16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_prepare16');
  sqlite3_prepare16_v2 := GetProcAddress(g_sqlite3_lib, 'sqlite3_prepare16_v2');
  sqlite3_bind_parameter_count := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_parameter_count');
  sqlite3_bind_parameter_name := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_parameter_name');
  sqlite3_bind_parameter_index := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_parameter_index');
  sqlite3_clear_bindings := GetProcAddress(g_sqlite3_lib, 'sqlite3_clear_bindings');
  sqlite3_column_count := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_count');
  sqlite3_column_bytes := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_bytes');
  sqlite3_column_bytes16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_bytes16');
  sqlite3_column_blob := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_blob');
  sqlite3_column_double := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_double');
  sqlite3_column_int := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_int');
  sqlite3_column_int64 := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_int64');
  sqlite3_column_text := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_text');
  sqlite3_column_text16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_text16');
  sqlite3_column_type := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_type');
  sqlite3_column_value := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_value');
  sqlite3_column_name := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_name');
  sqlite3_column_name16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_name16');
  sqlite3_column_database_name := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_database_name');
  sqlite3_column_database_name16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_database_name16');
  sqlite3_column_table_name := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_table_name');
  sqlite3_column_table_name16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_table_name16');
  sqlite3_column_origin_name := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_origin_name');
  sqlite3_column_origin_name16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_origin_name16');
  sqlite3_column_decltype := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_decltype');
  sqlite3_column_decltype16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_column_decltype16');
  sqlite3_step := GetProcAddress(g_sqlite3_lib, 'sqlite3_step');
  sqlite3_data_count := GetProcAddress(g_sqlite3_lib, 'sqlite3_data_count');
  sqlite3_bind_blob := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_blob');
  sqlite3_bind_double := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_double');
  sqlite3_bind_int := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_int');
  sqlite3_bind_int64 := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_int64');
  sqlite3_bind_null := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_null');
  sqlite3_bind_text := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_text');
  sqlite3_bind_text16 := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_text16');
  sqlite3_bind_value := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_value');
  sqlite3_bind_zeroblob := GetProcAddress(g_sqlite3_lib, 'sqlite3_bind_zeroblob');
  sqlite3_finalize := GetProcAddress(g_sqlite3_lib, 'sqlite3_finalize');
  sqlite3_reset := GetProcAddress(g_sqlite3_lib, 'sqlite3_reset');
  sqlite3_exec := GetProcAddress(g_sqlite3_lib, 'sqlite3_exec');
  sqlite3_last_insert_rowid := GetProcAddress(g_sqlite3_lib, 'sqlite3_last_insert_rowid');
  sqlite3_changes := GetProcAddress(g_sqlite3_lib, 'sqlite3_changes');
  sqlite3_last_statement_changes := GetProcAddress(g_sqlite3_lib, 'sqlite3_last_statement_changes');
  sqlite3_errmsg := GetProcAddress(g_sqlite3_lib, 'sqlite3_errmsg');
  _sqlite3_errstr := GetProcAddress(g_sqlite3_lib, 'sqlite3_errstr');
  sqlite3_errcode := GetProcAddress(g_sqlite3_lib, 'sqlite3_errcode');
  sqlite3_extended_errcode := GetProcAddress(g_sqlite3_lib, 'sqlite3_extended_errcode');
  sqlite3_interrupt := GetProcAddress(g_sqlite3_lib, 'sqlite3_interrupt');
  sqlite3_complete := GetProcAddress(g_sqlite3_lib, 'sqlite3_complete');
  sqlite3_busy_handler := GetProcAddress(g_sqlite3_lib, 'sqlite3_busy_handler');
  sqlite3_busy_timeout := GetProcAddress(g_sqlite3_lib, 'sqlite3_busy_timeout');
  sqlite3_get_table := GetProcAddress(g_sqlite3_lib, 'sqlite3_get_table');
  sqlite3_free_table := GetProcAddress(g_sqlite3_lib, 'sqlite3_free_table');
  sqlite3_free := GetProcAddress(g_sqlite3_lib, 'sqlite3_free');
  sqlite3_libversion := GetProcAddress(g_sqlite3_lib, 'sqlite3_libversion');
  sqlite3_libencoding := GetProcAddress(g_sqlite3_lib, 'sqlite3_libencoding');
  sqlite3_create_function := GetProcAddress(g_sqlite3_lib, 'sqlite3_create_function');
  sqlite3_create_aggregate := GetProcAddress(g_sqlite3_lib, 'sqlite3_create_aggregate');
  sqlite3_function_type := GetProcAddress(g_sqlite3_lib, 'sqlite3_function_type');
  sqlite3_set_result_string := GetProcAddress(g_sqlite3_lib, 'sqlite3_result_string');
  sqlite3_set_result_int := GetProcAddress(g_sqlite3_lib, 'sqlite3_result_int');
  sqlite3_set_result_double := GetProcAddress(g_sqlite3_lib, 'sqlite3_result_double');
  sqlite3_set_result_error := GetProcAddress(g_sqlite3_lib, 'sqlite3_result_error');
  sqlite3_user_data := GetProcAddress(g_sqlite3_lib, 'sqlite3_user_data');
  sqlite3_aggregate_context := GetProcAddress(g_sqlite3_lib, 'sqlite3_aggregate_context');
  sqlite3_aggregate_count := GetProcAddress(g_sqlite3_lib, 'sqlite3_aggregate_count');
  sqlite3_set_authorizer := GetProcAddress(g_sqlite3_lib, 'sqlite3_set_authorizer');
  sqlite3_trace := GetProcAddress(g_sqlite3_lib, 'sqlite3_trace');
  sqlite3_progress_handler := GetProcAddress(g_sqlite3_lib, 'sqlite3_progress_handler');
  sqlite3_commit_hook := GetProcAddress(g_sqlite3_lib, 'sqlite3_commit_hook');
  sqlite3_open_encrypted := GetProcAddress(g_sqlite3_lib, 'sqlite3_open_encrypted');
  sqlite3_rekey := GetProcAddress(g_sqlite3_lib, 'sqlite3_rekey');
  sqlite3_key := GetProcAddress(g_sqlite3_lib, 'sqlite3_key');
  Result := True;
end;

initialization

finalization
  unload_sqlite3;

end.
