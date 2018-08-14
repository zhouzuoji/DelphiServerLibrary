{$B-,C+,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,U-,V+,W-,X+,Z1}
{$O+}   // optimization on
{$T+}   // typed pointers on
{$POINTERMATH ON}

unit DSLSocketHttp;

interface

uses
  SysUtils, Classes, Windows, DateUtils, SyncObjs, Generics.Collections, Generics.Defaults, Forms,
  DSLWinsock2, ZLibExApi, ZLibEx, DSLUtils, DSLHtml, DSLGenerics, DSLCrypto, DSLSocket, DSLHttp;

type
  THttpConnection = class(TCustomHttpConnection)
  private
    FSocket: TCustomClientSocket;
    FBufferedData: RawByteString;
  public
    constructor Create(const _HostName: THttpString; _port: Word; const _proxy: THttpProxy;
      _IsHttps: Boolean; _socket: TCustomClientSocket);
    destructor Destroy; override;
    property socket: TCustomClientSocket read FSocket;
    property BufferedData: RawByteString read FBufferedData write FBufferedData;
  end;

  THttpIOHandler = class(TCustomHttpIOHandler)
  protected
    function write(const buf; BufLen: Integer; var comerr: TCommunicationError): Integer; override;
    function read(var buf; BufLen: Integer; var comerr: TCommunicationError): Integer; override;
    procedure KeepConnection; override;
  public
    procedure connect(var comerr: TCommunicationError); override;
  end;

  THttpSession = class(TCustomHttpSession)
  protected
    function CreateIOHandler(_request: TBaseHttpRequest; const _BaseOptions: TBaseHttpOptions;
      const _headers: TFrequentlyUsedHttpRequestHeaders; const _proxy: THttpProxy;
      _callback: THttpProgressEvent): TCustomHttpIOHandler; override;
  end;

implementation

var
  g_KeepAliveConnections: TThreadObjectListEx<THttpConnection>;

function GetKeepAlive(_HostName: THttpString; _port: Word; const _proxy: THttpProxy;
  _IsHttps: Boolean): THttpConnection;
const
  _10_SECONDS = 10 * 1000;
var
  i: Integer;
  tmp: THttpConnection;
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
          // ³¬Ê±
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

{ THttpSession }

function THttpSession.CreateIOHandler;
begin
  Result := THttpIOHandler.Create(_request, _BaseOptions, _headers, _proxy, _callback);
end;

{ THttpConnection }

constructor THttpConnection.Create(const _HostName: THttpString; _port: Word; const _proxy: THttpProxy;
  _IsHttps: Boolean; _socket: TCustomClientSocket);
begin
  inherited Create(_HostName, _port, _proxy, _IsHttps);
  _socket.AddRef;
  FSocket := _socket;
end;

destructor THttpConnection.Destroy;
begin
  FSocket.Release;
  inherited;
end;


{ THttpIOHandler }

procedure THttpIOHandler.connect;
var
  ClientSocket: TCustomClientSocket;
  _HostName, _host: RawByteString;
  _port: Word;
  ep: TEndPoint;
  bc, IsHttps: Boolean;
begin
  IsHttps := UStrSameText(request.url.schema, 'https');
  FConnection := GetKeepAlive(request.url.HostName, request.url.port, FProxy, IsHttps);

  if Assigned(FConnection) then Exit;

  if FProxy.HostName <> '' then
  begin
    _HostName := FProxy.HostName;
    _port := FProxy.port;
  end
  else begin
    _HostName := RawByteString(request.url.HostName);
    _port := request.url.port;
  end;

  try
    ep.setAddr(_HostName, _port);
  except
    comerr.code := comerrDNSError;
    Exit;
  end;

  if IsHttps then
    ClientSocket := TsslClientSocket.Create
  else
    ClientSocket := TClientSocket.Create;

  try
    if IsHttps and (FProxy.HostName <> '') then
    begin
      _host := RawByteString(request.url.HostName) + ':' + IntToRBStr(request.url.port);
      bc := TsslClientSocket(ClientSocket).ConnectViaHttpProxy(ep.unknown, ep.bytes,
        _host, FProxy.username, FProxy.password, FBaseOptions.ConnectTimeout, @comerr);
    end
    else
      bc := ClientSocket.connect(ep.unknown, ep.bytes, FBaseOptions.ConnectTimeout, @comerr);

    if bc then
    begin
      if FBaseOptions.RecvTimeout <> 0 then
        ClientSocket.RecvTimeout := FBaseOptions.RecvTimeout;

      if FBaseOptions.SendTimeout <> 0 then
        ClientSocket.SendTimeout := FBaseOptions.SendTimeout;

      FConnection := THttpConnection.Create(THttpString(_HostName), _port, FProxy, IsHttps, ClientSocket);
    end;
  finally
    ClientSocket.Release;
  end;
end;

procedure THttpIOHandler.KeepConnection;
begin
  connection.LatestUse := GetTickCount;
  connection.AddRef;
  g_KeepAliveConnections.Add(THttpConnection(connection));
end;

function THttpIOHandler.read;
begin
  Result := THttpConnection(FConnection).socket.read(buf, BufLen, @comerr);
end;

function THttpIOHandler.write;
begin
  Result := THttpConnection(FConnection).socket.write(buf, BufLen, @comerr);
end;

initialization
  g_KeepAliveConnections := TThreadObjectListEx<THttpConnection>.Create;

finalization
  g_KeepAliveConnections.Free;

end.
