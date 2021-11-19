unit DSLIocpHttpServer;

interface

uses
  SysUtils, Classes, DateUtils, Windows, Generics.Collections,
  DSLUtils, DSLTimer, DSLGenerics, DSLWinsock2, DSLHttp, DSLSocket, DSLAsyncSocket, DSLIocp;

type
  TIocpHttpServer = class;

  TIocpHttpServerConnection = class(TAsyncServerConnection)
  private
    FHttpServer: TIocpHttpServer;
    FHeadersParser: THttpRequestHeadersParser;
    FContentLength: Integer;
    FRequestBody: RawByteString;
    FDeadline: DWORD;
    function feedBody(const buf; bufLen: Integer): Integer;
    function bodyCompleted: Boolean; inline;
  public
    constructor Create(_httpServer: TIocpHttpServer);
    destructor Destroy; override;
    function getHeadersParser: PHttpRequestParser; inline;
    function getPath: TAnsiCharSection;
    function getRequestParameter(const name: RawByteString): RawByteString;
    function sendHttpResponse(const body: RawByteString;
      const contentType: RawByteString = 'application/json; charset=UTF-8'; statusCode: Integer = 200;
      const statusText: RawByteString = 'OK'): Boolean; overload;
    function sendHttpResponse(const body; bodyLen: Integer;
      const contentType: RawByteString = 'application/json; charset=UTF-8';
      statusCode: Integer = 200; const statusText: RawByteString = 'OK'): Boolean; overload;
    property httpServer: TIocpHttpServer read FHttpServer;
    property requestBody: RawByteString read FRequestBody;
    property deadline: DWORD read FDeadline write FDeadline;
  end;

  TIocpHttpServerConnectionEvent = procedure(sender: TIocpHttpServer; connection: TIocpHttpServerConnection) of object;

  TIocpHttpServer = class(TAsyncServerSocket)
  private
    FOnRequest: TIocpHttpServerConnectionEvent;
    FOnConnect: TIocpHttpServerConnectionEvent;
    FMaxRequestBodyLength: Integer;
    FTimeWheel: TTimeWheel;
    function getActive: Boolean; inline;
    procedure callOnConnect(connection: TIocpHttpServerConnection); inline;
    procedure callOnRequest(connection: TIocpHttpServerConnection); inline;
  public
    constructor Create(tw: TTimeWheel);
    destructor Destroy; override;
    procedure start(iocp: TIocpIOService; const endPoint: TEndPoint; numAccept: Integer);
    procedure stop;
    procedure checkReadingTimeout(AConnection: TIocpHttpServerConnection);
    property active: Boolean read getActive;
    property onConnect: TIocpHttpServerConnectionEvent read FOnConnect write FOnConnect;
    property onRequest: TIocpHttpServerConnectionEvent read FOnRequest write FOnRequest;
    property maxRequestBodyLength: Integer read FMaxRequestBodyLength write FMaxRequestBodyLength;
  end;

implementation

type
  TTcpAccpetContext = class(TAsyncAcceptContext)
  protected
    procedure doSuccess(socket: TAsyncServerSocket); override;
    procedure doFail(socket: TAsyncServerSocket; errorCode: Integer); override;
  end;

  TTcpRecvContext = class(TStreamSocketAsyncDataContext)
  private
    FReadBuffer: array [0 .. 4095] of AnsiChar;
  protected
    procedure doSuccess(socket: TAsyncConnectionSocket); override;
    procedure doFail(socket: TAsyncConnectionSocket; errorCode: Integer); override;
  public
    constructor Create;
  end;

{ TTcpAccpetContext }

procedure TTcpAccpetContext.doFail(socket: TAsyncServerSocket; errorCode: Integer);
begin
  inherited;

end;

procedure TTcpAccpetContext.doSuccess(socket: TAsyncServerSocket);
var
  conn: TIocpHttpServerConnection;
  httpServer: TIocpHttpServer;
  ctx: TStreamSocketAsyncDataContext;
  errorCode: Integer;
begin
  httpServer := TIocpHttpServer(socket);
  conn := TIocpHttpServerConnection(Self.reuse(TIocpHttpServerConnection.Create(httpServer)));
  Self.AddRef;
  socket.AsyncAccept(Self);

  try
    httpServer.callOnConnect(conn);
  except
    conn.release;
    Exit;
  end;

  if conn.handleAllocated then
  begin
    ctx := TTcpRecvContext.Create;
    if conn.AsyncRecv(ctx, @errorCode) then
    begin
      conn.deadline := 5000;
      httpServer.checkReadingTimeout(conn);
    end
    else begin
      {$IFDEF IOCP_DEBUG}
      DbgOutput(conn.getRemoteEndPoint.toString + ' AsyncRecv: ' + getOSErrorMessage(errorCode));
      {$ENDIF}
      ctx.release;
      conn.release;
    end;
  end;
end;

{ TTcpRecvContext }

constructor TTcpRecvContext.Create;
begin
  inherited Create;
  setSingleBuffer(@FReadBuffer, SizeOf(FReadBuffer));
end;

procedure TTcpRecvContext.doFail(socket: TAsyncConnectionSocket; errorCode: Integer);
begin
  inherited;

  socket.closeAndRelease;
end;

procedure TTcpRecvContext.doSuccess(socket: TAsyncConnectionSocket);
var
  httpConn: TIocpHttpServerConnection;
  headerParser: PHttpRequestParser;
  n: Integer;
  readMore: Boolean;
{.$IFDEF IOCP_DEBUG}
  //sec: TAnsiCharSection;
{.$ENDIF}
begin
  httpConn := socket as TIocpHttpServerConnection;
  headerParser := httpConn.getHeadersParser;

  if bytesTransferred = 0 then
  begin
    httpConn.closeAndRelease;
    Exit;
  end;
(*
{.$IFDEF IOCP_DEBUG}
  sec._begin := FReadBuffer;
  sec._end := @FReadBuffer[bytesTransferred];
  with socket.getRemoteEndPoint do
    RBStrDbgOutput(IP2RBStr + ':' + IntToRBStr(port) + ' => ' + sec.toString + #13#10);
{.$ENDIF}
*)
  n := 0;

  if headerParser.state in [hhsFirstLine, hhsKeyValues] then
  begin
    n := headerParser.feed(FReadBuffer, bytesTransferred);
    if headerParser.state = hhsCompleted then
    begin
      httpConn.FContentLength := headerParser.requestHeaders.getI('Content-Length', -1);
      if httpConn.FContentLength > httpConn.httpServer.maxRequestBodyLength then
        n := -1;
    end;

    if n = -1 then
    begin
      // fail to parsing request headers
      httpConn.closeAndRelease;
      Exit;
    end;
  end;

  readMore := True;
  if headerParser.state = hhsCompleted then
  begin
    if httpConn.FContentLength >= 0 then
      httpConn.feedBody(FReadBuffer[n], bytesTransferred - n);

    if httpConn.bodyCompleted then
    begin
      readMore := False;
      try
        httpConn.httpServer.callOnRequest(httpConn);
        httpConn.AsyncRecv(TTcpFinalRecvContext.Create);
      except
        httpConn.closeAndRelease;
      end;
    end;
  end;

  if readMore then
  begin
    Self.reuse;
    Self.AddRef;
    socket.AsyncRecv(Self);
  end;
end;

{ TIocpHttpServerConnection }

function TIocpHttpServerConnection.bodyCompleted: Boolean;
begin
  Result := Length(FRequestBody) >= FContentLength;
end;

constructor TIocpHttpServerConnection.Create(_httpServer: TIocpHttpServer);
begin
  inherited Create;
  FHttpServer := _httpServer;
  FHeadersParser.init;
end;

destructor TIocpHttpServerConnection.Destroy;
begin
  inherited;
end;

function TIocpHttpServerConnection.feedBody(const buf; bufLen: Integer): Integer;
var
  L: Integer;
begin
  L := Length(FRequestBody);
  if bufLen > FContentLength - L then
    bufLen := FContentLength - L;
  if bufLen > 0 then
  begin
    SetLength(FRequestBody, L + bufLen);
    Move(buf, PAnsiChar(FRequestBody)[L], bufLen);
  end;
  Result := bufLen;
end;

function TIocpHttpServerConnection.getHeadersParser: PHttpRequestParser;
begin
  Result := @FHeadersParser;
end;

function TIocpHttpServerConnection.getPath: TAnsiCharSection;
begin
  Result := FHeadersParser.requestLine.getPath;
end;

function TIocpHttpServerConnection.getRequestParameter(const name: RawByteString): RawByteString;
begin
  Result := FHeadersParser.requestLine.getQueryParam(name);
end;

function TIocpHttpServerConnection.sendHttpResponse(const body, contentType: RawByteString;
  statusCode: Integer; const statusText: RawByteString): Boolean;
begin
  Result := sendHttpResponse(Pointer(body)^, Length(body), contentType, statusCode, statusText);
end;

function TIocpHttpServerConnection.sendHttpResponse(const body; bodyLen: Integer;
  const contentType: RawByteString; statusCode: Integer; const statusText: RawByteString): Boolean;
var
  headers: RawByteString;
  comerr: TCommunicationError;
begin
  headers := 'HTTP/1.1 ' + IntToRBStr(statusCode) + ' ' + statusText + #13#10
    + 'Server: DSLWSLite 1.0'#13#10
    + 'Connection: Close'#13#10
    + 'Content-Type: ' + contentType + #13#10
    + 'Content-Length: ' + IntToRBStr(bodyLen) + #13#10
    + #13#10;

  Self.writeRBStr(headers);

  if bodyLen > 0 then
  begin
    comerr.init;
    Result := Self.write(body, bodyLen, @comerr) <> SOCKET_ERROR;
  end
  else
    Result := True;
end;

{ TIocpHttpServer }

procedure TIocpHttpServer.callOnConnect(connection: TIocpHttpServerConnection);
begin
  if Assigned(FOnConnect) then
    try
      FOnConnect(Self, connection);
    except
      on e: Exception do
        DbgOutputException('TIocpHttpServer.callOnConnect', e);
    end;
end;

procedure TIocpHttpServer.callOnRequest(connection: TIocpHttpServerConnection);
begin
  try
    FOnRequest(Self, connection);
  except
    on e: Exception do
      DbgOutputException('TIocpHttpServer.callOnRequest', e);
  end;
end;

procedure checkConnectionTimeout(driver: TTimeWheel; entry: PTimerItem; cbType: TTimerCallbackType);
var
  httpConn: TIocpHttpServerConnection;
begin
  entry.disable;
  httpConn := TIocpHttpServerConnection(entry.context);

  if cbType = tcbCleanup then
  begin
    httpConn.closeAndRelease;
    httpConn.release;
  end
  else if httpConn.handleAllocated then
  begin
    if GetTickCount - httpConn.latestRead >= httpConn.deadline then
    begin
      httpConn.closeAndRelease;
      httpConn.release;
    end
    else begin
      entry.setInterval(httpConn.deadline - (GetTickCount - httpConn.latestRead));
      entry.enable;
    end
  end
  else
    httpConn.release;
end;

procedure TIocpHttpServer.checkReadingTimeout(AConnection: TIocpHttpServerConnection);
var
  deadline: DWORD;
begin
  deadline := AConnection.deadline;

  if Assigned(FTimeWheel) and (deadline > 0) then
  begin
    AConnection.AddRef;
    FTimeWheel.addTimer(deadline, deadline, AConnection, checkConnectionTimeout);
  end;
end;

constructor TIocpHttpServer.Create(tw: TTimeWheel);
begin
  inherited Create;
  FMaxRequestBodyLength := 4096;
  tw.AddRef;
  FTimeWheel := tw;
end;

destructor TIocpHttpServer.Destroy;
begin
  FTimeWheel.release;
  inherited;
end;

function TIocpHttpServer.getActive: Boolean;
begin
  Result := Self.handleAllocated;
end;

procedure TIocpHttpServer.start(iocp: TIocpIOService; const endPoint: TEndPoint; numAccept: Integer);
var
  i, errorCode: Integer;
  ctx: TTcpAccpetContext;
begin
  stop;
  Self.open(endPoint);
  iocp.bind(Self.handle, Pointer(Self));

  for i := 1 to numAccept do
  begin
    ctx := TTcpAccpetContext.Create(TIocpHttpServerConnection.Create(Self));
    Self.asyncAccept(ctx, @errorCode);
  end;
end;

procedure TIocpHttpServer.stop;
begin
  Self.close;
end;

end.
