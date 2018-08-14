unit DSLIocpTcpServer;

interface

uses
  SysUtils, Classes, DateUtils, Windows, Generics.Collections,
  DSLUtils, DSLGenerics, DSLWinsock2, DSLSocket, DSLAsyncSocket, DSLIocp;

type
  TIocpTcpServer = class;

  TIocpTcpServerConnection = class(TAsyncServerConnection)
  private
    FTcpServer: TIocpTcpServer;
    FDeadline: DWORD;
  public
    constructor Create(_TcpServer: TIocpTcpServer);
    destructor Destroy; override;
    property TcpServer: TIocpTcpServer read FTcpServer;
    property deadline: DWORD read FDeadline write FDeadline;
  end;

  TIocpTcpServerConnectionEvent = procedure(sender: TIocpTcpServer; connection: TIocpTcpServerConnection) of object;

  TIocpTcpServer = class(TAsyncServerSocket)
  private
    FOnRead: TTcpDataEvent;
    FOnConnect: TIocpTcpServerConnectionEvent;
    FOnDisconnect: TIocpTcpServerConnectionEvent;
    FTimeWheel: TTimeWheel;
    function getActive: Boolean; inline;
    procedure callOnConnect(connection: TIocpTcpServerConnection); inline;
    procedure callOnDisconnect(connection: TIocpTcpServerConnection); inline;
  public
    constructor Create(tw: TTimeWheel);
    destructor Destroy; override;
    procedure start(iocp: TIocpIOService; const endPoint: TEndPoint; numAccept: Integer);
    procedure stop;
    procedure checkReadingTimeout(AConnection: TIocpTcpServerConnection);
    property active: Boolean read getActive;
    property onConnect: TIocpTcpServerConnectionEvent read FOnConnect write FOnConnect;
    property onDisconnect: TIocpTcpServerConnectionEvent read FOnDisconnect write FOnDisconnect;
    property OnRead: TTcpDataEvent read FOnRead write FOnRead;
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
  conn: TIocpTcpServerConnection;
  TcpServer: TIocpTcpServer;
  ctx: TStreamSocketAsyncDataContext;
  errorCode: Integer;
begin
  TcpServer := TIocpTcpServer(socket);
  conn := TIocpTcpServerConnection(Self.reuse(TIocpTcpServerConnection.Create(TcpServer)));
  Self.AddRef;
  socket.AsyncAccept(Self);

  try
    TcpServer.callOnConnect(conn);
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
      TcpServer.checkReadingTimeout(conn);
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
  httpConn: TIocpTcpServerConnection;
{.$IFDEF IOCP_DEBUG}
  //sec: TAnsiCharSection;
{.$ENDIF}
  server: TIocpTcpServer;
begin
  httpConn := socket as TIocpTcpServerConnection;
  server := httpConn.TcpServer;

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
  try
    server.OnRead(socket, FReadBuffer, bytesTransferred);
  except

  end;

  Self.reuse;
  Self.AddRef;
  socket.AsyncRecv(Self);
end;

{ TIocpTcpServerConnection }

constructor TIocpTcpServerConnection.Create(_TcpServer: TIocpTcpServer);
begin
  inherited Create;
  FTcpServer := _TcpServer;
end;

destructor TIocpTcpServerConnection.Destroy;
begin
  inherited;
end;

{ TIocpTcpServer }

procedure TIocpTcpServer.callOnConnect(connection: TIocpTcpServerConnection);
begin
  if Assigned(FOnConnect) then
    try
      FOnConnect(Self, connection);
    except
      on e: Exception do
        DbgOutputException('TIocpTcpServer.callOnConnect', e);
    end;
end;

procedure TIocpTcpServer.callOnDisconnect(connection: TIocpTcpServerConnection);
begin
  if Assigned(FOnDisconnect) then
  try
    FOnDisconnect(Self, connection);
  except
    on e: Exception do
      DbgOutputException('TIocpTcpServer.callOnDisconnect', e);
  end;
end;

procedure checkConnectionTimeout(driver: TTimeWheel; entry: PTimerItem; cbType: TTimerCallbackType);
var
  httpConn: TIocpTcpServerConnection;
begin
  entry.disable;
  httpConn := TIocpTcpServerConnection(entry.context);

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

procedure TIocpTcpServer.checkReadingTimeout(AConnection: TIocpTcpServerConnection);
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

constructor TIocpTcpServer.Create(tw: TTimeWheel);
begin
  inherited Create;
  tw.AddRef;
  FTimeWheel := tw;
end;

destructor TIocpTcpServer.Destroy;
begin
  FTimeWheel.release;
  inherited;
end;

function TIocpTcpServer.getActive: Boolean;
begin
  Result := Self.handleAllocated;
end;

procedure TIocpTcpServer.start(iocp: TIocpIOService; const endPoint: TEndPoint; numAccept: Integer);
var
  i, errorCode: Integer;
  ctx: TTcpAccpetContext;
begin
  stop;
  Self.open(endPoint);
  iocp.bind(Self.handle, Pointer(Self));

  for i := 1 to numAccept do
  begin
    ctx := TTcpAccpetContext.Create(TIocpTcpServerConnection.Create(Self));
    Self.asyncAccept(ctx, @errorCode);
  end;
end;

procedure TIocpTcpServer.stop;
begin
  Self.close;
end;

end.
