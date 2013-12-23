unit DSLHttp;

interface

uses
  SysUtils, Classes, Windows, ZLibExApi, DSLUtils;

function HttpCheckHostNameA(host: PAnsiChar; len: Integer): Boolean;

function HttpCheckHostNameW(host: PWideChar; len: Integer): Boolean;

function HttpParseURIA(url: PAnsiChar; out port: Word; out schema_begin, schema_end, host_begin, host_end, port_begin, port_end,
  username_begin, username_end, password_begin, password_end, path_begin, path_end: PAnsiChar): Boolean; overload;

function HttpParseURIA(url: PAnsiChar; out port: Word; out schema, host,
  UserName, password, PathWithParams: RawByteString): Boolean; overload;

function HttpParseURIW(url: PWideChar; out port: Word; out schema_begin, schema_end, host_begin, host_end, port_begin, port_end,
  username_begin, username_end, password_begin, password_end, path_begin, path_end: PWideChar): Boolean; overload;

function HttpParseURIW(url: PWideChar; out port: Word; out schema, host,
  UserName, password, PathWithParams: UnicodeString): Boolean; overload;

type
  DSLHttpRequest = class
    schema: RawByteString;
    method: RawByteString;
    host: RawByteString;
    port: Word;
    username: RawByteString;
    password: RawByteString;
    PathWithParams: RawByteString;
    referer: RawByteString;
    param: Pointer;
    ParamLength: DWORD;
    ParamStream: TStream;
    RequestHeaders: RawByteString;
    AutoDecompress: Boolean;
    SendingTimeout: DWORD;
    ReceivingTimeout: DWORD;
    AutoCookie: Boolean;
    AutoRedirect: Boolean;
    PragmaNoCache: Boolean;
    procedure init;
    procedure InitWithUrl(url: PAnsiChar);
  end;

  DSLCustomHttpSession = class
  public
    procedure DoRequest(const request: DSLHttpRequest; ResponseContent: TStream); virtual; abstract;
  end;

implementation

function HttpCheckHostNameA(host: PAnsiChar; len: Integer): Boolean;
begin
  Result := len > 0;
  // not implemented
end;

function HttpParseURIA(url: PAnsiChar; out port: Word; out schema_begin, schema_end, host_begin, host_end, port_begin, port_end,
  username_begin, username_end, password_begin, password_end, path_begin, path_end: PAnsiChar): Boolean;
var
  port_value: Word;
begin
  Result := False;

  username_begin := nil;
  username_end := nil;
  password_begin := nil;
  password_end := nil;

  schema_begin := url;

  if IBeginWithA(url, 'http://') then
  begin
    schema_end := url + 4;
    port := 80;
    host_begin := url + 7;
  end
  else if IBeginWithA(url, 'https://') then
  begin
    schema_end := url + 5;
    port := 443;
    host_begin := url + 8;
  end
  else Exit;

  host_end := host_begin;

  while (host_end^ <> #0) and (host_end^ <> ':') and (host_end^ <> '/') do Inc(host_end);

  if (host_end = host_begin) or not HttpCheckHostNameA(host_begin, host_end - host_begin) then Exit;

  port_value := 0;
  port_begin := nil;
  port_end := nil;

  path_begin := nil;
  path_end := nil;

  case host_end^ of
    ':':
      begin
        port_begin := host_end + 1;
        port_end := port_begin;

        while (port_end^ <> #0) and (port_end^ <> '/') do
        begin
          if port_end^ in ['0'..'9'] then
            port_value := port_value * 10 + PByte(port_end)^ - $30
          else Exit;

          Inc(port_end);
        end;

        if port_end = port_begin then Exit;

        port := port_value;

        if port_end^ = '/'  then path_begin := port_end;
      end;
    '/': path_begin := host_end;
  end;

  if Assigned(path_begin) then
  begin
    path_end := path_begin;

    while path_end^ <> #0 do Inc(path_end);
  end;

  Result := True;
end;

procedure DSLSetString(var s: RawByteString; _begin, _end: PAnsiChar);
begin
  if not Assigned(_begin) or not Assigned(_end) or (_end = _begin) then s := ''
  else SetString(s, _begin, _end - _begin);
end;

function HttpParseURIA(url: PAnsiChar; out port: Word; out schema, host,
  UserName, password, PathWithParams: RawByteString): Boolean;
var
  schema_begin, schema_end, host_begin, host_end, port_begin, port_end, username_begin, username_end,
  password_begin, password_end, path_begin, path_end: PAnsiChar;
begin
  Result := HttpParseURIA(url, port, schema_begin, schema_end, host_begin, host_end, port_begin, port_end,
    username_begin, username_end, password_begin, password_end, path_begin, path_end);

  if Result then
  begin
    DSLSetString(schema, schema_begin, schema_end);
    DSLSetString(host, host_begin, host_end);
    DSLSetString(UserName, username_begin, username_end);
    DSLSetString(password, password_begin, password_end);
    DSLSetString(PathWithParams, path_begin, path_end);
  end;
end;

function HttpCheckHostNameW(host: PWideChar; len: Integer): Boolean;
begin
  Result := len > 0;
  // not implemented
end;

function HttpParseURIW(url: PWideChar; out port: Word; out schema_begin, schema_end, host_begin, host_end, port_begin, port_end,
  username_begin, username_end, password_begin, password_end, path_begin, path_end: PWideChar): Boolean;
var
  port_value: Word;
begin
  Result := False;

  username_begin := nil;
  username_end := nil;
  password_begin := nil;
  password_end := nil;

  schema_begin := url;

  if IBeginWithW(url, 'http://') then
  begin
    schema_end := url + 4;
    port := 80;
    host_begin := url + 7;
  end
  else if IBeginWithW(url, 'https://') then
  begin
    schema_end := url + 5;
    port := 443;
    host_begin := url + 8;
  end
  else Exit;

  host_end := host_begin;

  while (host_end^ <> #0) and (host_end^ <> ':') and (host_end^ <> '/') do Inc(host_end);

  if (host_end = host_begin) or not HttpCheckHostNameW(host_begin, host_end - host_begin) then Exit;

  port_value := 0;
  port_begin := nil;
  port_end := nil;

  path_begin := nil;
  path_end := nil;

  case host_end^ of
    ':':
      begin
        port_begin := host_end + 1;
        port_end := port_begin;

        while (port_end^ <> #0) and (port_end^ <> '/') do
        begin
          if (port_end^ >= '0') and (port_end^ <= '9') then
            port_value := port_value * 10 + PByte(port_end)^ - $30
          else Exit;

          Inc(port_end);
        end;

        if port_end = port_begin then Exit;

        port := port_value;

        if port_end^ = '/'  then path_begin := port_end;
      end;
    '/': path_begin := host_end;
  end;

  if Assigned(path_begin) then
  begin
    path_end := path_begin;

    while path_end^ <> #0 do Inc(path_end);
  end;

  Result := True;
end;

procedure DSLSetStringW(var s: UnicodeString; _begin, _end: PWideChar);
begin
  if not Assigned(_begin) or not Assigned(_end) or (_end = _begin) then s := ''
  else SetString(s, _begin, _end - _begin);
end;

function HttpParseURIW(url: PWideChar; out port: Word; out schema, host,
  UserName, password, PathWithParams: UnicodeString): Boolean; overload;
var
  schema_begin, schema_end, host_begin, host_end, port_begin, port_end, username_begin, username_end,
  password_begin, password_end, path_begin, path_end: PWideChar;
begin
  Result := HttpParseURIW(url, port, schema_begin, schema_end, host_begin, host_end, port_begin, port_end,
    username_begin, username_end, password_begin, password_end, path_begin, path_end);

  if Result then
  begin
    DSLSetStringW(schema, schema_begin, schema_end);
    DSLSetStringW(host, host_begin, host_end);
    DSLSetStringW(UserName, username_begin, username_end);
    DSLSetStringW(password, password_begin, password_end);
    DSLSetStringW(PathWithParams, path_begin, path_end);
  end;
end;

{ DSLHttpRequest }

procedure DSLHttpRequest.init;
begin
  FillChar(Self, sizeof(DSLHttpRequest), 0);
  Self.AutoDecompress := True;
  Self.AutoCookie := True;
  Self.AutoRedirect := False;
  Self.PragmaNoCache := True;
end;

procedure DSLHttpRequest.InitWithUrl(url: PAnsiChar);
begin
  Self.init;

  HttpParseURIA(url, port, Self.schema, Self.host, Self.username, Self.password, Self.PathWithParams);
end;

end.
