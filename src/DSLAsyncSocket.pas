unit DSLAsyncSocket;

interface

uses
  SysUtils, Classes, Windows, StrUtils, SyncObjs, DSLWinsock2, MSWSock, WS2tcpip,
  DSLUtils, DSLSocket, DSLIocp;

type
  TAsyncConnectionSocket = class;

  TWinsock2AsyncDataContext = class(TIocpIOContext)
  private
    FIOFlags: DWORD;
    FWsaBuf: TWsaBuf;
  protected
    procedure setSingleBuffer(buf: Pointer; len: Integer); inline;
    function getBuffers: PWsaBuf; virtual;
    function getBufferCount: Integer; virtual;
  public
    constructor Create(_IOFlags: DWORD = 0);
    property IOFlags: DWORD read FIOFlags;
  end;

  TStreamSocketAsyncDataContext = class(TWinsock2AsyncDataContext)
  protected
    procedure doSuccess(socket: TAsyncConnectionSocket); virtual; abstract;
    procedure doFail(socket: TAsyncConnectionSocket; errorCode: Integer); virtual; abstract;
    procedure doComplete(iosvc: TIocpIOService; HandleContext: Pointer); override;
  end;

  TTcpFinalRecvContext = class(TWinsock2AsyncDataContext)
  protected
    procedure doComplete(iosvc: TIocpIOService; HandleContext: Pointer); override;
  public
    constructor Create;
  end;

  TAsyncConnectionSocket = class(TConnectionSocket)
  public
    function asyncSend(ctx: TWinsock2AsyncDataContext; pErrCode: PInteger = nil): Boolean;
    function asyncRecv(ctx: TWinsock2AsyncDataContext; pErrCode: PInteger = nil): Boolean;
    function write(const buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; override;
    function read(var buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; override;
  end;

  TAsyncServerConnection = class(TAsyncConnectionSocket)
  public
    procedure updateAcceptContext(ServerSocket: TCustomServerSocket);
    function updateAcceptExEndPoints(acceptExBuffer: Pointer; acceptExReceiveDataLength,
      acceptExLocalAddressLength, acceptExRemoteAddressLength: DWORD): Boolean;
  end;

const
  MIN_ACCEPTEX_BUFFER = 2 * (SizeOf(TEndPoint) + 16);

type
  TAsyncServerSocket = class;

  TAsyncAcceptContext = class(TIocpIOContext)
  private
    FConnection: TAsyncServerConnection;
    FBuffer: array [0 .. MIN_ACCEPTEX_BUFFER - 1] of AnsiChar;
  protected
    procedure doSuccess(socket: TAsyncServerSocket); virtual; abstract;
    procedure doFail(socket: TAsyncServerSocket; errorCode: Integer); virtual; abstract;
    procedure doComplete(iosvc: TIocpIOService; HandleContext: Pointer); override;
  public
    constructor Create; overload;
    constructor Create(conn: TAsyncServerConnection); overload;
    destructor Destroy; override;
    function reuse: TAsyncServerConnection; overload; inline;
    function reuse(newConn: TAsyncServerConnection): TAsyncServerConnection; overload; inline;
    property connection: TAsyncServerConnection read FConnection;
  end;

  TAsyncServerSocket = class(TCustomServerSocket)
  public
    function asyncAccept(ctx: TAsyncAcceptContext; pErrCode: PInteger = nil): Boolean;
  end;

  TAsyncClientSocket = class;

  TAsyncConnectContext = class(TIocpIOContext)
  private
    FServerEndPoint: TEndPoint;
  protected
    procedure doSuccess(socket: TAsyncClientSocket); virtual; abstract;
    procedure doFail(socket: TAsyncClientSocket; errorCode: Integer); virtual; abstract;
    procedure doComplete(iosvc: TIocpIOService; HandleContext: Pointer); override;
  public
    constructor Create(const serverIP: RawByteString; serverPort: Word); overload;
    constructor Create(const serverAddr: TSockAddr; addrLen: Integer); overload;
    property serverEndPoint: TEndPoint read FServerEndPoint;
  end;

  TAsyncClientSocket = class(TAsyncConnectionSocket)
  protected
    function bindZero(pErrCode: PInteger = nil): Boolean;
    procedure updateConnectContext;
  public
    function asyncConnect(ctx: TAsyncConnectContext; pErrCode: PInteger = nil): Boolean;
  end;

  TAsyncDgramSocket = class;

  TDgramSocketAsyncDataContext = class(TWinsock2AsyncDataContext)
  private
    FPeerEndPoint: TEndPoint;
  protected
    procedure doSuccess(socket: TAsyncDgramSocket); virtual; abstract;
    procedure doFail(socket: TAsyncDgramSocket; errorCode: Integer); virtual; abstract;
    procedure doComplete(iosvc: TIocpIOService; HandleContext: Pointer); override;
  public
    constructor Create(const peerAddr: TSockAddr; peerAddrLen: Integer; _flags: DWORD = 0); overload;
    constructor Create(const peerIP: RawByteString; peerPort: Word; _flags: DWORD = 0); overload;
    property peerEndPoint: TEndPoint read FPeerEndPoint;
  end;

  TAsyncDgramSocket = class(TDgramSocket)
  public
    function asyncSendTo(ctx: TDgramSocketAsyncDataContext; pErrCode: PInteger = nil): Boolean;
    function asyncRecvFrom(ctx: TDgramSocketAsyncDataContext; pErrCode: PInteger = nil): Boolean;
  end;

implementation

{ TAsyncClientSocket }

function TAsyncClientSocket.asyncConnect;
var
  bytesSent: DWORD;
  lastError: Integer;
begin
  Result := False;

  if not Assigned(ConnectEx) then
  begin
    ReportError('ConnectEx', WSAEOPNOTSUPP, pErrCode);
    Exit;
  end;

  if (INVALID_SOCKET = Self.Handle) and not allocateHandle(ctx.FServerEndPoint.family, SOCK_STREAM, pErrCode) then
    Exit;

  if not bindZero(pErrCode) then
    Exit;

  Self.AddRef;

  try
    if ConnectEx(Self.Handle, ctx.FServerEndPoint.unknown, ctx.FServerEndPoint.bytes, nil, 0, bytesSent,
      ctx.getSysOverlapped) then
    begin
      Result := True;
    end
    else
    begin
      lastError := WSAGetLastError;

      if WSA_IO_PENDING = lastError then
        Result := True
      else
        ReportError('ConnectEx', lastError, pErrCode);
    end;
  finally
    if not Result then
      Self.Release;
  end;
end;

function TAsyncClientSocket.bindZero(pErrCode: PInteger): Boolean;
var
  LocalAddr: TEndPoint;
  lastError: Integer;
begin
  FillChar(LocalAddr, SizeOf(LocalAddr), 0);
  LocalAddr.unknown.sin_family := Self.AddressFamily;
  LocalAddr.unknown.sin_port := 0;
  Result := Self.bind(LocalAddr, @lastError) or (lastError = WSAEINVAL);

  if not Result then
  begin
    if Assigned(pErrCode) then
      pErrCode^ := lastError
    else
      BindError(LocalAddr, lastError);
  end;
end;

procedure TAsyncClientSocket.updateConnectContext;
begin
  Self.SetIntOption(SOL_SOCKET, SO_UPDATE_CONNECT_CONTEXT, 0);
end;

{ TAsyncServerSocket }

function TAsyncServerSocket.asyncAccept;
var
  bytesTransferred: DWORD;
  lastError: Integer;
begin
  Result := False;

  if not Assigned(AcceptEx) then
  begin
    ReportError('AcceptEx', WSAEOPNOTSUPP, pErrCode);
    Exit;
  end;

  Self.AddRef;

  try
    if ctx.connection.allocateHandle(Self.AddressFamily, SOCK_STREAM, pErrCode) then
    begin
      if AcceptEx(Self.Handle, ctx.connection.Handle, @ctx.FBuffer, 0, SizeOf(TEndPoint) + 16, SizeOf(TEndPoint) + 16,
        @bytesTransferred, ctx.getSysOverlapped) then
      begin
        Result := True
      end
      else
      begin
        lastError := WSAGetLastError;
        if WSA_IO_PENDING = lastError then
          Result := True
        else
          Result := ReportError('AcceptEx', lastError, pErrCode);
      end;
    end;
  finally
    if not Result then
      Self.Release;
  end;
end;

{ TAsyncConnectionSocket }

function TAsyncConnectionSocket.asyncRecv;
var
  bytesRead: DWORD;
  lastError: Integer;
begin
  Result := False;
  Self.AddRef;

  try
    if SOCKET_ERROR <> WSARecv(Self.Handle, ctx.getBuffers, ctx.getBufferCount, bytesRead, ctx.FIOFlags,
      PWsaOverlapped(ctx.getSysOverlapped), nil) then
    begin
      Result := True;
    end
    else
    begin
      lastError := WSAGetLastError;
      if WSA_IO_PENDING = lastError then
        Result := True
      else
        Result := ReportError('WSARecv', lastError, pErrCode);
    end;
  finally
    if not Result then
      Self.Release;
  end;
end;

function TAsyncConnectionSocket.asyncSend;
var
  bytesSent: DWORD;
  lastError: Integer;
begin
  Result := False;
  Self.AddRef;

  try
    if SOCKET_ERROR <> WSASend(Self.Handle, ctx.getBuffers, ctx.getBufferCount, bytesSent, ctx.FIOFlags,
      PWsaOverlapped(ctx.getSysOverlapped), nil) then
    begin
      Result := True;
    end
    else
    begin
      lastError := WSAGetLastError;
      if WSA_IO_PENDING = lastError then
        Result := True
      else
        Result := ReportError('WSASend', lastError, pErrCode);
    end;
  finally
    if not Result then
      Self.Release;
  end;
end;

function TAsyncConnectionSocket.read;
begin
  Result := Self._read(buf, BufLen, pError, flags);
end;

function TAsyncConnectionSocket.write;
begin
  Result := Self._write(buf, BufLen, pError, flags);
end;

{ TAsyncServerConnection }

procedure TAsyncServerConnection.updateAcceptContext(ServerSocket: TCustomServerSocket);
begin
  (*
    使用AcceptEx建立的连接，调用UpdateAcceptContext方法，否则在此连接上调用
    GetPeerName会失败。
    *)
  Self.SetIntOption(SOL_SOCKET, SO_UPDATE_ACCEPT_CONTEXT, ServerSocket.Handle);
end;

function TAsyncServerConnection.updateAcceptExEndPoints(acceptExBuffer: Pointer; acceptExReceiveDataLength,
  acceptExLocalAddressLength, acceptExRemoteAddressLength: DWORD): Boolean;
var
  localAddrLen, remoteAddrLen: Integer;
  pLocal, pRemote: LPSOCKADDR;
begin
  pLocal := nil;
  pRemote := nil;
  localAddrLen := 0;
  remoteAddrLen := 0;
  GetAcceptExSockAddrs(acceptExBuffer, acceptExReceiveDataLength,
    acceptExLocalAddressLength, acceptExRemoteAddressLength,
    pLocal, localAddrLen, pRemote, remoteAddrLen);

  if Assigned(pRemote) and (remoteAddrLen > 0) then
  begin
    Self.setRemoteEndPoint(pRemote^, remoteAddrLen);
    Result := True;
  end
  else
    Result := False;
end;

{ TAsyncAcceptContext }

constructor TAsyncAcceptContext.Create;
begin
  inherited Create;
  FConnection := TAsyncServerConnection.Create;
end;

constructor TAsyncAcceptContext.Create(conn: TAsyncServerConnection);
begin
  inherited Create;
  FConnection := conn;
end;

destructor TAsyncAcceptContext.Destroy;
begin
  FConnection.Release;
  inherited;
end;

procedure TAsyncAcceptContext.doComplete(iosvc: TIocpIOService; HandleContext: Pointer);
var
  ServerSocket: TAsyncServerSocket;
  cb, flags: DWORD;
  errorCode: Integer;
begin
  ServerSocket := TAsyncServerSocket(HandleContext);

  try
    if WSAGetOverlappedResult(ServerSocket.Handle, PWsaOverlapped(Self.getSysOverlapped), cb, False, flags) then
    begin
      FConnection.dataRead(0);
      if not FConnection.updateAcceptExEndPoints(@Self.FBuffer, 0, SizeOf(TEndPoint) + 16,
        SizeOf(TEndPoint) + 16) then
        FConnection.updateAcceptContext(ServerSocket);

      iosvc.bind(FConnection.Handle, FConnection);
{$IFDEF IOCP_DEBUG}
      DbgOutput(FConnection.getRemoteEndPoint.toString + ' connected.');
{$ENDIF}
      Self.doSuccess(ServerSocket);
    end
    else
    begin
      errorCode := WSAGetLastError;
{$IFDEF IOCP_DEBUG}
      DbgOutput('AsyncAccept: ' + getOSErrorMessage(errorCode));
{$ENDIF}
      Self.doFail(ServerSocket, errorCode);
    end;
  finally
    Self.Release;
    ServerSocket.Release;
  end;
end;

function TAsyncAcceptContext.reuse(newConn: TAsyncServerConnection): TAsyncServerConnection;
begin
  inherited reuse;
  Result := FConnection;
  FConnection := newConn;
end;

function TAsyncAcceptContext.reuse: TAsyncServerConnection;
begin
  inherited reuse;
  Result := FConnection;
  FConnection := TAsyncServerConnection.Create;
end;

{ TAsyncDgramSocket }

function TAsyncDgramSocket.asyncSendTo;
var
  bytesSent: DWORD;
  lastError: Integer;
begin
  Result := False;
  Self.AddRef;

  try
    if SOCKET_ERROR <> WSASendTo(Self.Handle, ctx.getBuffers, ctx.getBufferCount, bytesSent, ctx.FIOFlags,
      @ctx.FPeerEndPoint.unknown, ctx.FPeerEndPoint.bytes, PWsaOverlapped(ctx.getSysOverlapped), nil) then
    begin
      Result := True;
    end
    else
    begin
      lastError := WSAGetLastError;
      if WSA_IO_PENDING = lastError then
        Result := True
      else
        Result := ReportError('WSASend', lastError, pErrCode);
    end;
  finally
    if not Result then
      Self.Release;
  end;
end;

function TAsyncDgramSocket.asyncRecvFrom;
var
  bytesRead: DWORD;
  lastError, addrLen: Integer;
begin
  Result := False;
  addrLen := SizeOf(ctx.FPeerEndPoint);
  Self.AddRef;

  try
    if SOCKET_ERROR <> WSARecvFrom(Self.Handle, ctx.getBuffers, ctx.getBufferCount, bytesRead, ctx.FIOFlags,
      @ctx.FPeerEndPoint.unknown, @addrLen, PWsaOverlapped(ctx.getSysOverlapped), nil) then
      Result := True
    else
    begin
      lastError := WSAGetLastError;
      if WSA_IO_PENDING = lastError then
        Result := True
      else
        Result := ReportError('WSARecvFrom', lastError, pErrCode);
    end;
  finally
    if not Result then
      Self.Release;
  end;
end;

{ TDgramSocketAsyncDataContext }

constructor TDgramSocketAsyncDataContext.Create(const peerAddr: TSockAddr; peerAddrLen: Integer; _flags: DWORD);
begin
  inherited Create(_flags);
  Move(peerAddr, FPeerEndPoint, peerAddrLen);
end;

constructor TDgramSocketAsyncDataContext.Create(const peerIP: RawByteString; peerPort: Word; _flags: DWORD);
begin
  inherited Create(_flags);
  FPeerEndPoint.setAddr(peerIP, peerPort);
end;

procedure TDgramSocketAsyncDataContext.doComplete(iosvc: TIocpIOService; HandleContext: Pointer);
var
  socket: TAsyncDgramSocket;
  cb: DWORD;
begin
  socket := TAsyncDgramSocket(HandleContext);

  try
    if WSAGetOverlappedResult(socket.Handle, PWsaOverlapped(Self.getSysOverlapped), cb, False, Self.FIOFlags) then
      Self.doSuccess(socket)
    else
      Self.doFail(socket, WSAGetLastError);
  finally
    Self.Release;
    socket.Release;
  end;
end;

{ TStreamSocketAsyncDataContext }

procedure TStreamSocketAsyncDataContext.doComplete(iosvc: TIocpIOService; HandleContext: Pointer);
var
  conn: TAsyncConnectionSocket;
  cb, flags: DWORD;
  errorCode: Integer;
{$IFDEF IOCP_DEBUG}
  s: RawByteString;
{$ENDIF}
begin
  conn := TAsyncConnectionSocket(HandleContext);

  try
    if WSAGetOverlappedResult(conn.Handle, PWsaOverlapped(Self.getSysOverlapped), cb, False, flags) then
    begin
      FIOFlags := flags;
{$IFDEF IOCP_DEBUG}
      if (bytesTransferred = 0) and (getBuffers.len > 0) then
        DbgOutput(conn.getRemoteEndPoint.toString + ' disconnected gracefully' + #13#10);
{$ENDIF}
      conn.dataRead(bytesTransferred);

{$IFDEF IOCP_DEBUG}
      if IsPrintableString(FWsaBuf.buf^, bytesTransferred) then
        SetString(s, FWsaBuf.buf, bytesTransferred)
      else
        s := MemHex(FWsaBuf.buf^, bytesTransferred, True, #32);
      with conn.getRemoteEndPoint^ do
        RBStrDbgOutput(IP2RBStr + ':' + IntToRBStr(port) + ' => ' + s + #13#10);
{$ENDIF}
      Self.doSuccess(conn);
    end
    else
    begin
      errorCode := WSAGetLastError;
{$IFDEF IOCP_DEBUG}

      try
        DbgOutput(conn.getRemoteEndPoint.toString + ' read fail: ' + getOSErrorMessage(errorCode));
      except
        DbgOutput('0x' + IntToHex(Integer(conn), 8) + ' read fail: ' + getOSErrorMessage(errorCode));
      end;

      //DbgOutput(conn.getRemoteEndPoint.toString + ' disconnected' + #13#10);
{$ENDIF}
      Self.doFail(conn, errorCode);
    end;
  finally
    Self.Release;
    conn.Release;
  end;
end;

{ TAsyncConnectContext }

constructor TAsyncConnectContext.Create(const serverIP: RawByteString; serverPort: Word);
begin
  inherited Create;
  FServerEndPoint.setAddr(serverIP, serverPort);
end;

constructor TAsyncConnectContext.Create(const serverAddr: TSockAddr; addrLen: Integer);
begin
  inherited Create;
  Move(serverAddr, FServerEndPoint, addrLen);
end;

procedure TAsyncConnectContext.doComplete(iosvc: TIocpIOService; HandleContext: Pointer);
var
  socket: TAsyncClientSocket;
  cb, flags: DWORD;
begin
  socket := TAsyncClientSocket(HandleContext);
  flags := 0;
  try
    if WSAGetOverlappedResult(socket.Handle, PWsaOverlapped(Self.getSysOverlapped), cb, False, flags) then
    begin
      socket.updateConnectContext;
      Self.doSuccess(socket);
    end
    else
      Self.doFail(socket, WSAGetLastError);
  finally
    Self.Release;
    socket.Release;
  end;
end;

{ TWinsock2AsyncDataContext }

constructor TWinsock2AsyncDataContext.Create(_IOFlags: DWORD);
begin
  inherited Create;
  Self.FIOFlags := _IOFlags;
end;

function TWinsock2AsyncDataContext.getBufferCount: Integer;
begin
  Result := 1;
end;

function TWinsock2AsyncDataContext.getBuffers: PWsaBuf;
begin
  Result := @FWsaBuf;
end;

procedure TWinsock2AsyncDataContext.setSingleBuffer(buf: Pointer; len: Integer);
begin
  FWsaBuf.buf := PAnsiChar(buf);
  FWsaBuf.len := len;
end;

{ TTcpFinalRecvContext }

constructor TTcpFinalRecvContext.Create;
begin
  inherited Create;
  setSingleBuffer(nil, 0);
end;

procedure TTcpFinalRecvContext.doComplete(iosvc: TIocpIOService; HandleContext: Pointer);
begin
  inherited;
  try
{$IFDEF IOCP_DEBUG}
    DbgOutput(TConnectionSocket(HandleContext).getRemoteEndPoint.toString + ' disconnected' + #13#10);
{$ENDIF}
    TCustomSocket(HandleContext).closeAndRelease;
  finally
    TRefCountedObject(HandleContext).Release;
    Self.Release;
  end;
end;

end.
