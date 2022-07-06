unit DSLWinHttp;

interface

uses
  SysUtils, Classes, Forms, Windows, SyncObjs, WinAPI.WinHttp, ZLibExApi, DSLUtils, DSLHtml, DSLHttp,
  Generics.Collections, Generics.Defaults, DSLGenerics;

function WinHttpSetDWORDOption(handle: HINTERNET; option, value: DWORD): Boolean;
function WinHttpSetStringOption(handle: HINTERNET; option: DWORD; const value: UnicodeString): Boolean;

function WinHttpGetStringHeaderLength(request: HINTERNET; info: DWORD): Integer;

function WinHttpGetStringHeaderBuf(request: HINTERNET; info: DWORD; buf: PWideChar; len: Integer): Integer;

function WinHttpGetStringHeader(request: HINTERNET; info: DWORD; name: PWideChar = WINHTTP_HEADER_NAME_BY_INDEX; pIndex: PDWORD = WINHTTP_NO_HEADER_INDEX): UnicodeString;

function WinHttpGetDwordHeader(request: HINTERNET; info: DWORD; var value: DWORD): Boolean;

type
  TWinHttpConnection = class(TCustomHttpConnection)
  private
    FConnectionHandle: HINTERNET;
  public
    constructor Create(const _HostName: THttpString; _port: Word; const _proxy: ThttpProxy;
      _IsHttps: Boolean; hConn: HINTERNET);
    destructor Destroy; override;
    property ConnectionHandle: HINTERNET read FConnectionHandle;
  end;

  TWinHttpIOHandler = class(TCustomHttpIOHandler)
  private
    FWinHttpRequest: HINTERNET;
  protected
    function write(const buf; BufLen: Integer; var comerr: TCommunicationError): Integer; override;
    function read(var buf; BufLen: Integer; var comerr: TCommunicationError): Integer; override;
    procedure SendHeaders(var httperr: THttpError); override;
    procedure RecevieHeaders(var httperr: THttpError); override;
    function ParseChunked(buf: PAnsiChar; len: Integer): Integer; override;
    procedure KeepConnection; override;
  public
    procedure connect(var comerr: TCommunicationError); override;
    destructor Destroy; override;
  end;

  TWinHttpSession = class(TCustomHttpSession)
  protected
    function CreateIOHandler(_request: TBaseHttpRequest; const _BaseOptions: TBaseHttpOptions;
      const _headers: TFrequentlyUsedHttpRequestHeaders; const _proxy: THttpProxy;
      _callback: THttpProgressEvent): TCustomHttpIOHandler; override;
  public
    (* 此函数根据请求选项处理重定向、schema切换 *)
    function DoRequest(request: THttpRequest; const options: TBaseHttpOptions; ResponseContent: TStream;
      TimesErrorRetry: Integer = 0; callback: THttpProgressEvent = nil): THttpResult; override;
  end;

var
  g_UseWinHttp: Boolean = True;

function CreateHttpSession(const UserAgent: THttpString = ''): TCustomHttpSession;

implementation

uses
  DSLSocketHttp;

var
  g_hWinHttpSession: HINTERNET;
  g_KeepAliveConnections: TThreadObjectListEx<TWinHttpConnection>;

function GetKeepAlive(_HostName: THttpString; _port: Word; const _proxy: THttpProxy;
  _IsHttps: Boolean): TWinHttpConnection;
const
  _10_SECONDS = 10 * 1000;
var
  i: Integer;
  tmp: TWinHttpConnection;
begin
  Result := nil;
  if g_KeepAliveConnections.Count > 0 then
  begin
    g_KeepAliveConnections.LockList;

    try
      for i := g_KeepAliveConnections.Count - 1 downto 0 do
      begin
        tmp := g_KeepAliveConnections[i];

        if GetTickCount - tmp.LatestUse > _10_SECONDS then
        begin
          // 超时
          g_KeepAliveConnections.Delete(i);
          Continue;
        end;

        if not tmp.match(_HostName, _port, _proxy, _IsHttps) then Continue;

        tmp.AddRef;
        Result := tmp;
        g_KeepAliveConnections.Delete(i);
        Break;
      end;
    finally
      g_KeepAliveConnections.UnlockList;
    end;
  end;
end;

function CreateHttpSession(const UserAgent: THttpString = ''): TCustomHttpSession;
begin
  if g_UseWinHttp then
    Result := TWinHttpSession.Create(UserAgent)
  else
    Result := THttpSession.Create(UserAgent);
end;

function WinHttpSetDWORDOption(handle: HINTERNET; option, value: DWORD): Boolean;
begin
  Result := WinHttpSetOption(handle, option, @value, SizeOf(value));
end;

function WinHttpSetStringOption(handle: HINTERNET; option: DWORD; const value: UnicodeString): Boolean;
begin
  Result := WinHttpSetOption(handle, option, PWideChar(value), Length(value));
end;

function WinHttpGetStringHeaderLength(request: HINTERNET; info: DWORD): Integer;
var
  LastError, BufferLength: DWORD;
begin
  BufferLength := 0;

  //因为提供的buffer为nil，这个调用一定会失败，且如果header存在的话，
  //返回错误码应该是ERROR_INSUFFICIENT_BUFFER
  WinHttpQueryHeaders(request, info, WINHTTP_HEADER_NAME_BY_INDEX,
    WINHTTP_NO_OUTPUT_BUFFER, BufferLength, WINHTTP_NO_HEADER_INDEX);

  LastError := GetLastError;

  if LastError = ERROR_INSUFFICIENT_BUFFER then Result := BufferLength shr 1 - 1
  else if LastError = ERROR_WINHTTP_HEADER_NOT_FOUND then Result := 0
  else Result := -1;
end;

function WinHttpGetStringHeader(request: HINTERNET; info: DWORD; name: PWideChar; pIndex: PDWORD): UnicodeString;
var
  LastError, BufferLength, hdridx: DWORD;
begin
  BufferLength := 0;
  hdridx := 0;

  if Assigned(pIndex) then hdridx := pIndex^;

  //因为提供的buffer为nil，这个调用一定会失败，且如果header存在的话，
  //返回错误码应该是ERROR_INSUFFICIENT_BUFFER
  WinHttpQueryHeaders(request, info, name,
    WINHTTP_NO_OUTPUT_BUFFER, BufferLength, pIndex);

  LastError := GetLastError;

  if LastError = ERROR_INSUFFICIENT_BUFFER then
  begin
    SetLength(Result, (BufferLength shr 1) - 1);
    if Assigned(pIndex) then pIndex^ := hdridx;
    WinHttpQueryHeaders(request, info, name, Pointer(Result), BufferLength, pIndex)

    (*
    if not WinHttpQueryHeaders(request, info, name,
      Pointer(Result), BufferLength, pIndex) then
      raise EWinHttpException.Create(GetLastError, 'WinHttpQueryHeaders');
      *)
  end
  else begin
    if Assigned(pIndex) then pIndex^ := ERROR_WINHTTP_HEADER_NOT_FOUND ;
    if LastError = ERROR_WINHTTP_HEADER_NOT_FOUND then Result := '';
    //else raise EWinHttpException.Create(LastError, 'WinHttpQueryHeaders');
  end;
end;

function WinHttpGetStringHeaderBuf(request: HINTERNET; info: DWORD; buf: PWideChar; len: Integer): Integer;
var
  LastError, BufferLength: DWORD;
begin
  BufferLength := len shl 1;

  if WinHttpQueryHeaders(request, info, WINHTTP_HEADER_NAME_BY_INDEX, Pointer(buf), BufferLength,
    WINHTTP_NO_HEADER_INDEX) then Result := (BufferLength shr 1) - 1
  else begin
    LastError := GetLastError;
    DbgOutput('WinHttpQueryHeaders: error ' + IntToStr(LastError));

    if LastError = ERROR_INSUFFICIENT_BUFFER then Result := -1
    else if LastError = ERROR_WINHTTP_HEADER_NOT_FOUND then Result := -2
    else Result := -3;
  end;
end;

function WinHttpGetDwordHeader(request: HINTERNET; info: DWORD; var value: DWORD): Boolean;
var
  BufferLength: DWORD;
begin
  BufferLength := SizeOf(value);

  Result := WinHttpQueryHeaders(request, info or WINHTTP_QUERY_FLAG_NUMBER, WINHTTP_HEADER_NAME_BY_INDEX,
    @value, BufferLength, WINHTTP_NO_HEADER_INDEX);
end;

procedure DumpSetCookie(hRequest: HINTERNET);
var
  hdridx: DWORD;
  cookie: UnicodeString;
begin
  hdridx := 0;

  while hdridx <> ERROR_WINHTTP_HEADER_NOT_FOUND do
  begin
    cookie := WinHttpGetStringHeader(hRequest, WINHTTP_QUERY_SET_COOKIE, nil, @hdridx);
    if cookie <> '' then UStrDbgOutput(cookie);
  end;
end;

{ TWinHttpSession }

function TWinHttpSession.CreateIOHandler;
begin
  Result := TWinHttpIOHandler.Create(_request, _BaseOptions, _headers, _proxy, _callback);
end;

function TWinHttpSession.DoRequest(request: THttpRequest;
  const options: TBaseHttpOptions; ResponseContent: TStream;
  TimesErrorRetry: Integer; callback: THttpProgressEvent): THttpResult;
var
  session: THttpSession;
begin
  Result := Self._DoRequest(request, options, ResponseContent, TimesErrorRetry, callback);

  if Result.error.code = httperrInvalidCert then
  begin
    request.GetLatestRequest.ClearResponseHeaders;
    session := THttpSession.Create(Self.UserAgent, Self.CookieManager);
    session.SetProxy(Self.FProxy);
    session.Async := Self.Async;
    try
      Result := session.DoRequest(request, options, ResponseContent, TimesErrorRetry, callback);
    finally
      session.Release;
    end;
  end;
end;

{ TWinHttpConnection }

constructor TWinHttpConnection.Create(const _HostName: THttpString; _port: Word;
  const _proxy: ThttpProxy; _IsHttps: Boolean; hConn: HINTERNET);
begin
  inherited Create(_HostName, _port, _proxy, _IsHttps);
  FConnectionHandle := hConn;
end;

destructor TWinHttpConnection.Destroy;
begin
  WinHttpCloseHandle(FConnectionHandle);
  inherited;
end;

{ TWinHttpIOHandler }

procedure convertWinHttpError(step: THttpStep; const callee: string; errcode: Integer;
  var httperr: THttpError); overload;
begin
  httperr.callee := 'winhttp';
  httperr.internalErrorCode := errcode;
  httperr.code := httperrSysCallFail;

  case errcode of
    ERROR_WINHTTP_TIMEOUT: httperr.code := httperrTimeout;
    ERROR_WINHTTP_CANNOT_CONNECT: httperr.code := httperrCanNotConnect;
    ERROR_WINHTTP_CONNECTION_ERROR: httperr.code := httperrConnectionClosed;
    ERROR_WINHTTP_NAME_NOT_RESOLVED: httperr.code := httperrDNSError;
    ERROR_WINHTTP_SECURE_CERT_DATE_INVALID,
    ERROR_WINHTTP_SECURE_CERT_CN_INVALID,
    ERROR_WINHTTP_SECURE_INVALID_CA,
    ERROR_WINHTTP_SECURE_CERT_REV_FAILED,
    ERROR_WINHTTP_SECURE_CHANNEL_ERROR,
    ERROR_WINHTTP_SECURE_INVALID_CERT,
    ERROR_WINHTTP_SECURE_CERT_REVOKED,
    ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE: httperr.code := httperrInvalidCert;
  end;
end;

procedure convertWinHttpError(const callee: string; errcode: Integer; var comerr: TCommunicationError); overload;
begin
  comerr.callee := callee;
  comerr.internalErrorCode := errcode;
  comerr.code := comerrSysCallFail;
  case errcode of
    ERROR_WINHTTP_CANNOT_CONNECT: comerr.code := comerrCanNotConnect;
    ERROR_WINHTTP_TIMEOUT: comerr.code := comerrTimeout;
    ERROR_WINHTTP_CONNECTION_ERROR: comerr.code := comerrChannelClosed;
    ERROR_WINHTTP_NAME_NOT_RESOLVED: comerr.code := comerrDNSError;
    ERROR_WINHTTP_SECURE_CERT_DATE_INVALID,
    ERROR_WINHTTP_SECURE_CERT_CN_INVALID,
    ERROR_WINHTTP_SECURE_INVALID_CA,
    ERROR_WINHTTP_SECURE_CERT_REV_FAILED,
    ERROR_WINHTTP_SECURE_CHANNEL_ERROR,
    ERROR_WINHTTP_SECURE_INVALID_CERT,
    ERROR_WINHTTP_SECURE_CERT_REVOKED,
    ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE: comerr.code := comerrSSLError;
  end;
end;

procedure TWinHttpIOHandler.connect;
var
  hConn: HINTERNET;
  TotalInputLength, rflags: DWORD;
  RequestHeaders: UnicodeString;
  proxy: THttpProxy;
  info: WINHTTP_PROXY_INFO;
  IsHttps: Boolean;
begin
  IsHttps := UStrSameText(request.url.schema, 'https');
  FConnection := GetKeepAlive(request.url.HostName, request.url.port, FProxy, IsHttps);

  if Assigned(FConnection) then
    hConn := TWinHttpConnection(FConnection).ConnectionHandle
  else begin
    hConn := WinHttpConnect(g_hWinHttpSession, PWideChar(UnicodeString(request.url.HostName)), request.url.port, 0);

    if not Assigned(hConn) then
    begin
      convertWinHttpError('winhttp.WinHttpConnect', GetLastError, comerr);
      Exit;
    end;
  end;

  FWinHttpRequest := nil;

  try
    proxy := FProxy;

    rflags := WINHTTP_FLAG_NULL_CODEPAGE or WINHTTP_FLAG_ESCAPE_DISABLE;

    if IsHttps then
      rflags := rflags or WINHTTP_FLAG_SECURE;

    if Assigned(request.ParamStream) then
      TotalInputLength := request.ParamLength + request.ParamStream.Size
    else
      TotalInputLength := request.ParamLength;

    FWinHttpRequest := WinHttpOpenRequest(hConn, PWideChar(request.method),
      PWideChar(request.url.PathWithParams), 'HTTP/1.1', nil,
      WINHTTP_DEFAULT_ACCEPT_TYPES, rflags);

    if not Assigned(FWinHttpRequest) then
    begin
      convertWinHttpError('winhttp.WinHttpOpenRequest', GetLastError, comerr);
      Exit;
    end;

    if proxy.HostName = '' then
    begin
      info.dwAccessType := WINHTTP_ACCESS_TYPE_NO_PROXY;
      info.lpszProxy := nil;
      info.lpszProxyBypass := nil;
    end
    else begin
      info.dwAccessType := WINHTTP_ACCESS_TYPE_NAMED_PROXY;
      info.lpszProxy := PWideChar(UnicodeString(proxy.HostName) + ':' + IntToUStr(proxy.port));
      info.lpszProxyBypass := PWideChar(UnicodeString(proxy.bypass));
    end;

    if not WinHttpSetOption(FWinHttpRequest, WINHTTP_OPTION_PROXY, @info, SizeOf(info)) then
    begin
      convertWinHttpError('winhttp.WinHttpSetOption', GetLastError, comerr);
      Exit;
    end;

    if FBaseOptions.SendTimeout <> 0 then
      WinHttpSetDWORDOption(FWinHttpRequest, WINHTTP_OPTION_SEND_TIMEOUT, FBaseOptions.SendTimeout);

    if FBaseOptions.ConnectTimeout <> 0 then
      WinHttpSetDWORDOption(FWinHttpRequest, WINHTTP_OPTION_CONNECT_TIMEOUT, FBaseOptions.ConnectTimeout);

    WinHttpSetStringOption(FWinHttpRequest, WINHTTP_OPTION_PROXY_USERNAME, UnicodeString(FProxy.username));
    WinHttpSetStringOption(FWinHttpRequest, WINHTTP_OPTION_PROXY_PASSWORD, UnicodeString(FProxy.password));

    WinHttpSetDWORDOption(FWinHttpRequest, WINHTTP_OPTION_SECURITY_FLAGS,
      SECURITY_FLAG_IGNORE_CERT_CN_INVALID or
      SECURITY_FLAG_IGNORE_CERT_DATE_INVALID or
      SECURITY_FLAG_IGNORE_UNKNOWN_CA or
      SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE);

    WinHttpSetDWORDOption(FWinHttpRequest, WINHTTP_OPTION_DISABLE_FEATURE, WINHTTP_DISABLE_REDIRECTS);
    WinHttpSetDWORDOption(FWinHttpRequest, WINHTTP_OPTION_DISABLE_FEATURE, WINHTTP_DISABLE_COOKIES);

    RequestHeaders := request.MakeRequestHeader(FFrequentlyUsedHeaders, False);

    (*
    WinHttpConnect and WinHttpOpenRequest do not try to connect server,
    but WinHttpSendRequest does
    *)
    if WinHttpSendRequest(FWinHttpRequest, PWideChar(RequestHeaders), Length(RequestHeaders),
      nil, 0, TotalInputLength, 0) then
    begin
      if FBaseOptions.RecvTimeout <> 0 then
      begin
        WinHttpSetDWORDOption(FWinHttpRequest, WINHTTP_OPTION_RECEIVE_RESPONSE_TIMEOUT, FBaseOptions.RecvTimeout);
        WinHttpSetDWORDOption(FWinHttpRequest, WINHTTP_OPTION_RECEIVE_TIMEOUT, FBaseOptions.RecvTimeout);
      end;

      if not Assigned(FConnection) then
        FConnection := TWinHttpConnection.Create(request.url.HostName, request.url.port, proxy, IsHttps, hConn);
      Self.HeaderSent;
    end
    else
      convertWinHttpError('winhttp.WinHttpSendRequest', GetLastError, comerr);
  finally
    if not comerr.isSuccess then
      WinHttpCloseHandle(hConn);
  end;
end;

destructor TWinHttpIOHandler.Destroy;
begin
  if Assigned(FWinHttpRequest) then
    WinHttpCloseHandle(FWinHttpRequest);
  inherited;
end;

procedure TWinHttpIOHandler.KeepConnection;
begin
  inherited;
  connection.LatestUse := GetTickCount;
  connection.AddRef;
  g_KeepAliveConnections.Add(TWinHttpConnection(connection));
end;

function TWinHttpIOHandler.ParseChunked(buf: PAnsiChar; len: Integer): Integer;
begin
  Result := Self.WriteContent(buf, len);
end;

function TWinHttpIOHandler.read;
var
  BytesWritten: DWORD;
begin
  if WinHttpReadData(FWinHttpRequest, buf, BufLen, @BytesWritten) then
  begin
    if BytesWritten = 0 then
    begin
      comerr.code := comerrChannelClosed;
      Result := -1;
    end
    else
      Result := Integer(BytesWritten)
  end
  else begin
    convertWinHttpError('winhttp.WinHttpReadData', GetLastError, comerr);
    Result := -1;
  end;
end;

procedure TWinHttpIOHandler.RecevieHeaders;
begin
  if WinHttpReceiveResponse(FWinHttpRequest, nil) then
  begin
    request.ResponseHeaders.parse(TWideCharSection.Create(WinHttpGetStringHeader(FWinHttpRequest,
      WINHTTP_QUERY_RAW_HEADERS_CRLF)));
  end
  else
    convertWinHttpError(hrsReceiveHeaders, 'winhttp.WinHttpReceiveResponse', GetLastError, httperr);

  Self.HeaderRecved;
end;

procedure TWinHttpIOHandler.SendHeaders;
begin

end;

function TWinHttpIOHandler.write;
var
  BytesWritten: DWORD;
begin
  if WinHttpWriteData(FWinHttpRequest, buf, BufLen, @BytesWritten) then
    Result := Integer(BytesWritten)
  else begin
    convertWinHttpError('winhttp.WinHttpWriteData', GetLastError, comerr);
    Result := -1;
  end;
end;

initialization
  g_hWinHttpSession := WinHttpOpen(nil, WINHTTP_ACCESS_TYPE_NO_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
  //WinHttpSetDWORDOption(g_hWinHttpSession, WINHTTP_OPTION_SECURE_PROTOCOLS,
    //WINHTTP_FLAG_SECURE_PROTOCOL_ALL);

  //WinHttpSetDWORDOption(g_hWinHttpSession, WINHTTP_OPTION_SECURE_PROTOCOLS,
    //WINHTTP_FLAG_SECURE_PROTOCOL_TLS1 or WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_1
    //or WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2);
  g_KeepAliveConnections := TThreadObjectListEx<TWinHttpConnection>.Create;

finalization
  WinHttpCloseHandle(g_hWinHttpSession);
  g_KeepAliveConnections.Free;

end.
