unit DSLIocpUdpSocket;

interface

uses
  SysUtils, Classes, DateUtils, Windows, Generics.Collections,
  DSLUtils, DSLGenerics, DSLWinsock2, DSLHttp, DSLSocket, DSLAsyncSocket, DSLIocp;

type
  TIocpUdpSocket = class(TAsyncDgramSocket)
  private
    FOnRead: TUdpDataEvent;
    function getActive: Boolean; inline;
    procedure callOnRead(const peerAddr: TEndPoint; const buf; bufSize: Integer); inline;
  public
    procedure start(iocp: TIocpIOService; const endPoint: TEndPoint; numAsyncRead: Integer);
    procedure stop;
    property active: Boolean read getActive;
    property onRead: TUdpDataEvent read FOnRead write FOnRead;
  end;

implementation

type
  TUdpRecvContext = class(TDgramSocketAsyncDataContext)
  private
    FReadBuffer: array [0 .. 4095] of AnsiChar;
    procedure postAgain(socket: TAsyncDgramSocket); inline;
  protected
    procedure doSuccess(socket: TAsyncDgramSocket); override;
    procedure doFail(socket: TAsyncDgramSocket; errorCode: Integer); override;
  public
    constructor Create;
  end;

{ TUdpRecvContext }

constructor TUdpRecvContext.Create;
begin
  inherited Create;
  setSingleBuffer(@FReadBuffer, SizeOf(FReadBuffer));
end;

procedure TUdpRecvContext.doFail(socket: TAsyncDgramSocket; errorCode: Integer);
begin
  DbgOutput('WSARecvFrom: ' + getOSErrorMessage(errorCode));

  if errorCode <> WSAENOTSOCK then
    postAgain(socket);
end;

procedure TUdpRecvContext.doSuccess(socket: TAsyncDgramSocket);
begin
  TIocpUdpSocket(socket).callOnRead(peerEndPoint, FReadBuffer, bytesTransferred);
  postAgain(socket);
end;

procedure TUdpRecvContext.postAgain(socket: TAsyncDgramSocket);
var
  code: Integer;
begin
  Self.reuse;
  Self.AddRef;

  if not socket.AsyncRecvFrom(Self, @code) then
  begin
    Self.Release;
    DbgOutput('asyncRecvFrom: ' + getOSErrorMessage(code));
  end;
end;

{ TIocpUdpSocket }

procedure TIocpUdpSocket.callOnRead(const peerAddr: TEndPoint; const buf; bufSize: Integer);
begin
  try
    OnRead(Self, peerAddr, buf, bufSize);
  except
    on e: Exception do
      DbgOutputException('TIocpUdpSocket.callOnRead', e);
  end;
end;

function TIocpUdpSocket.getActive: Boolean;
begin
  Result := Self.handleAllocated;
end;

procedure TIocpUdpSocket.start(iocp: TIocpIOService; const endPoint: TEndPoint; numAsyncRead: Integer);
var
  i, errorCode: Integer;
  ctx: TUdpRecvContext;
begin
  stop;
  Self.open(endPoint);
  iocp.bind(Self.handle, Pointer(Self));

  for i := 1 to numAsyncRead do
  begin
    ctx := TUdpRecvContext.Create;
    if not asyncRecvFrom(ctx, @errorCode) then
    begin
      ctx.Release;
      DbgOutput('asyncRecvFrom: ' + getOSErrorMessage(errorCode));
      RaiseLastOSError;
    end;
  end;
end;

procedure TIocpUdpSocket.stop;
begin
  Self.close;
end;

end.
