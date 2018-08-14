program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  DSLWinsock2,
  uSSLTest in 'uSSLTest.pas',
  DSLAES in '..\..\src\DSLAES.pas',
  DSLAnsiFunctions in '..\..\src\DSLAnsiFunctions.pas',
  DSLAsyncSocket in '..\..\src\DSLAsyncSocket.pas',
  DSLCrypto in '..\..\src\DSLCrypto.pas',
  DSLGenerics in '..\..\src\DSLGenerics.pas',
  DSLHashTable in '..\..\src\DSLHashTable.pas',
  DSLHtml in '..\..\src\DSLHtml.pas',
  DSLHttp in '..\..\src\DSLHttp.pas',
  DSLIocp in '..\..\src\DSLIocp.pas',
  DSLSelfProfile in '..\..\src\DSLSelfProfile.pas',
  DSLSocket in '..\..\src\DSLSocket.pas',
  DSLSocketHttp in '..\..\src\DSLSocketHttp.pas',
  DSLSSL in '..\..\src\DSLSSL.pas',
  DSLUtils in '..\..\src\DSLUtils.pas',
  DSLWinHttp in '..\..\src\DSLWinHttp.pas',
  DSLXml in '..\..\src\DSLXml.pas',
  openssl in '..\..\src\openssl.pas',
  ProtoBuffer in '..\..\src\ProtoBuffer.pas';

procedure test_client_socket;
var
  TCPClient: TClientSocket;
  line: RawByteString;
  ss: TRawByteStringStream;
begin
  TCPClient := TClientSocket.Create;
  ss := TRawByteStringStream.Create('');

  try
    TCPClient.connect('www.eastmoney.com', 80);
    TCPClient.WriteRBStr('GET / HTTP/1.1'#13#10);
    TCPClient.WriteRBStr('Accept: */*'#13#10);
    TCPClient.WriteRBStr('Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3'#13#10);
    TCPClient.WriteRBStr('Host: www.eastmoney.com'#13#10);
    TCPClient.WriteRBStr('User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:39.0) Gecko/20100101 Firefox/39.0'#13#10#13#10);

    while True do
    begin
      TCPClient.ReadRBStr(line, #13#10);

      if line <> '' then
        Writeln(line)
      else
        Break;
    end;

    try
      TCPClient.ReadStream(ss, MaxInt);
    except

    end;

    Writeln(ss.DataString);
    
  finally
    TCPClient.Free;
    ss.Free;
  end;
end;

procedure OnHttpProgress(Sender: TObject; step: THttpRequestStep; total, completed: DWORD; var cancel: Boolean);
begin
  case step of
    hrsConnect: Writeln('connecting...');
    hrsSendHeaders: Writeln('sending request headers: ', completed, '/', total);
    hrsSendData: Writeln('posting params: ', completed, '/', total);
    hrsReceiveHeaders: Writeln('reading response headers...');
    hrsReceiveData: Writeln('reading content: ', completed, '/', total);
  end;
end;

function PrintHttpHeader(param: Pointer; const header: THttpHeader): Boolean;
begin
  Writeln(header.name, ': ', header.value);
  Result := True;
end;

procedure test_http_client;
var
  session: TCustomHttpSession;
  req: THttpRequest;
  html: UnicodeString;
  url: THttpString;
  callback: THttpRequestProgressEvent;
  i: Integer;
begin
  TMethod(callback).Code := @OnHttpProgress;
  TMethod(callback).Data := nil;
  session := THttpSession.Create(IE_USER_AGENT);
  req := THttpRequest.Create;
  req.method := 'GET';
  req.RequestHeaders.UserAgent := 'Safari 10.1(OS X Leopard)';
  req.options.AutoRedirect := False;
  req.options.AutoSchemaSwitching := True;

  try
    while True do
    begin
      Readln(url);
      url := Trim(url);
      if url = '' then Break;
      req.url.parse(url);
      req.RequestHeaders.remove('Host');

      if req.RedirectOcuured then
        req.RedirctRequests.Clear;

      req.ResponseHeaders.clear;
      (*
      Writeln('url: ', req.url);
      Writeln('schema: ', req.schema);
      Writeln('host name: ', req.HostName);
      Writeln('port: ', req.port);
      Writeln('host: ', req.host);
      Writeln('path: ', req.PathWithParams);
      Writeln('file name: ', req.FileName);
      *)

      html := session.FetchUnicodeString(req, g_BaseHttpOptions, 0, nil, callback);

      //Writeln(RBStrToUnicodeEx(ss.DataString, [CP_ACP, CP_UTF8]));
      Writeln('0: request headers:');
      Writeln(req.MakeRequestHeader(req.headers, True));
      Writeln('-----------------------------------------------'#13#10);
      Writeln('0: response headers:');
      req.ResponseHeaders.foreach(PrintHttpHeader, nil);

      Writeln('****************************************'#13#10#13#10);

      if req.RedirectOcuured then
      begin
        for i := 0 to req.RedirctRequests.Count - 1 do
        begin
          Writeln(i + 1 , ': request headers:');
          Writeln(req.RedirctRequests[i].MakeRequestHeader(req.headers, True));
          Writeln('-----------------------------------------------'#13#10);
          Writeln(i + 1, ': response headers:');
          req.RedirctRequests[i].ResponseHeaders.foreach(PrintHttpHeader, nil);
          Writeln('****************************************'#13#10#13#10);
        end;
      end;

      //Writeln(html);
      //Writeln(session);
    end;
  finally
    req.Release;
    session.Release;
  end;
end;

procedure test_tcp_timeout(timeout: Integer);
var
  tcpcli: TClientSocket;
  tick: DWORD;
  buf: array [0..31] of Byte;
begin
  tcpcli := TClientSocket.Create;

  try
    tcpcli.AllocateHandle(AF_INET, SOCK_STREAM);
    Writeln('RecvTimeout: ', tcpcli.RecvTimeout);
    tcpcli.RecvTimeout := timeout;
    Writeln('set RecvTimeout=', timeout);
    Writeln('RecvTimeout: ', tcpcli.RecvTimeout);

    tick := GetTickCount;

    try
      tcpcli.connect('www.baidu.com', 444, 2000);
    except
      on e: Exception do
      begin
        Writeln(GetTickCount - tick);
        DbgOutputException(e);
      end;
    end;

    tick := GetTickCount;
    try
      tcpcli.read(buf, SizeOf(buf));
    except
      on e: Exception do
      begin
        Writeln(GetTickCount - tick);
        DbgOutputException(e);
      end;
    end;
  finally
    tcpcli.Release;
  end;
end;

procedure TestWinHttp;
var
  httpcli: TWinHttpSession;
begin
  httpcli := TWinHttpSession.Create;
  try
    Writeln(httpcli.GetAndDecode('http://www.baidu.com'));
  finally
    httpcli.Release;
  end;
end;

procedure TestHttpKeepAlive;
var
  httpcli: TCustomHttpSession;
begin
  httpcli := THttpSession.Create;
  try
    //httpcli.SetProxy('192.168.16.53', 8888);
    Writeln(httpcli.GetAndDecode('http://www.kehuda.com'));
    Writeln(httpcli.GetAndDecode('http://www.sududa.com'));
  finally
    httpcli.Release;
  end;
end;

var
  g_HttpResponse: RawByteString;

type
  TTcpSendStringContext = class(TStreamSocketAsyncDataContext)
  private
    FStr: RawByteString;
    FWsaBuf: TWsaBuf;
  protected
    function getBuffers: PWsaBuf; override;
    procedure doSuccess(socket: TAsyncConnectionSocket); override;
    procedure doFail(socket: TAsyncConnectionSocket; errorCode: Integer); override;
  public
    constructor Create(const sBuffer: RawByteString);
  end;

  TTcpRecvContext = class(TStreamSocketAsyncDataContext)
  private
    FReadBuffer: array [0..4095] of AnsiChar;
    FWsaBuf: TWsaBuf;
  protected
    function getBuffers: PWsaBuf; override;
    procedure doSuccess(socket: TAsyncConnectionSocket); override;
    procedure doFail(socket: TAsyncConnectionSocket; errorCode: Integer); override;
  public
    constructor Create;
  end;

  TTcpAccpetContext = class(TAsyncAcceptContext)
  protected
    procedure doSuccess(socket: TAsyncServerSocket); override;
    procedure doFail(socket: TAsyncServerSocket; errorCode: Integer); override;
  end;

  TTcpConnectContext = class(TAsyncConnectContext)
  protected
    procedure doSuccess(socket: TAsyncClientSocket); override;
    procedure doFail(socket: TAsyncClientSocket; errorCode: Integer); override;
  end;

{ TTcpSendStringContext }

constructor TTcpSendStringContext.Create(const sBuffer: RawByteString);
begin
  inherited Create;
  FStr := sBuffer;
  FWsaBuf.buf := PAnsiChar(FStr);
  FWsaBuf.len := Length(FStr);
end;

procedure TTcpSendStringContext.doFail(socket: TAsyncConnectionSocket; errorCode: Integer);
begin
  inherited;

end;

procedure TTcpSendStringContext.doSuccess(socket: TAsyncConnectionSocket);
begin
  inherited;

end;

function TTcpSendStringContext.getBuffers: PWsaBuf;
begin
  Result := @FWsaBuf;
end;

{ TTcpRecvContext }

constructor TTcpRecvContext.Create;
begin
  inherited Create;
  FWsaBuf.buf := FReadBuffer;
  FWsaBuf.len := SizeOf(FReadBuffer);
end;

procedure TTcpRecvContext.doFail(socket: TAsyncConnectionSocket; errorCode: Integer);
begin
  DbgOutput(socket.GetRemoteEndPoint.ToString + ' read error(' + IntToStr(errorCode) + ')');
  if socket.close then
    socket.Release;
end;

procedure TTcpRecvContext.doSuccess(socket: TAsyncConnectionSocket);
var
  sec: TAnsiCharSection;
  peer: TEndPoint;
begin
  peer := socket.GetRemoteEndPoint;
  if bytesTransferred = 0 then
  begin
    DbgOutput(peer.ToString + ' disconnected' + #13#10);
    if socket.close then
      socket.Release;
  end
  else begin
    sec._begin := FReadBuffer;
    sec._end := @FReadBuffer[bytesTransferred];
    //sec.trim;
    RBStrDbgOutput(peer.IP2RBStr + ':' + IntToRBStr(peer.port) + ' => ' + sec.ToString + #13#10);

    if sec.ipos(TAnsiCharSection.Create(#13#10#13#10)) <> nil then
      socket.AsyncSend(TTcpSendStringContext.Create(g_HttpResponse));

    Self.reuse;
    Self.AddRef;
    socket.AsyncRecv(Self);
  end;
end;

function TTcpRecvContext.getBuffers: PWsaBuf;
begin
  Result := @FWsaBuf;
end;

{ TTcpAccpetContext }

procedure TTcpAccpetContext.doFail(socket: TAsyncServerSocket; errorCode: Integer);
begin
  DbgOutput(IntToStr(errorCode));
end;

procedure TTcpAccpetContext.doSuccess(socket: TAsyncServerSocket);
var
  svrconn: TAsyncServerConnection;
  peer: TEndPoint;
begin
  svrconn := Self.connection;
  peer := svrconn.GetRemoteEndPoint;
  DbgOutput(peer.ToString + ' connected.');
  Self.reuse;
  Self.AddRef;
  socket.AsyncAccept(Self);
  svrconn.AsyncRecv(TTcpRecvContext.Create);
end;

{ TTcpConnectContext }

procedure TTcpConnectContext.doFail(socket: TAsyncClientSocket; errorCode: Integer);
begin
  DbgOutput('connect to ' + Self.serverEndPoint.ToString + ' fail(' + IntToStr(errorCode) + ')');
  if socket.close then
    socket.Release;
end;

procedure TTcpConnectContext.doSuccess(socket: TAsyncClientSocket);
var
  peer: TEndPoint;
begin
  peer := socket.GetRemoteEndPoint;
  DbgOutput('connect to ' + peer.ToString + ' success'#13#10);
  socket.asyncSend(TTcpSendStringContext.Create('GET / HTTP/1.1'#13#10
    + 'User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko'#13#10
    + 'Host: www.baidu.com'#13#10
    + 'Connection: Close'#13#10#13#10));
  socket.AsyncRecv(TTcpRecvContext.Create);
end;

var
  iocpsvc: TIocpIOService;
  tcpsvr: TAsyncServerSocket;

procedure Test_iocp_server;
begin
  iocpsvc := TIocpIOService.Create;
  tcpsvr := TAsyncServerSocket.Create;

  try
    tcpsvr.open(9999, nil, True);
    iocpsvc.bind(tcpsvr.Handle, Pointer(tcpsvr));
    tcpsvr.AsyncAccept(TTcpAccpetContext.Create);
    iocpsvc.run;
  finally
    tcpsvr.Release;
    iocpsvc.Release;
  end;
end;

procedure Test_iocp_client;
var
  ClientSocket: TAsyncClientSocket;
begin
  iocpsvc := TIocpIOService.Create;
  ClientSocket := TAsyncClientSocket.Create;

  try
    ClientSocket.AllocateHandle(AF_INET, SOCK_STREAM, nil, True);
    iocpsvc.bind(ClientSocket.Handle, ClientSocket);
    ClientSocket.AsyncConnect(TTcpConnectContext.Create('www.baidu.com', 80));
    iocpsvc.run;
  finally
    iocpsvc.Release;
  end;
end;

function ConsoleCtrlHandler(Ctrl: DWORD): BOOL; stdcall;
begin
  if Assigned(tcpsvr) then
    tcpsvr.close;
  Sleep(500);
  iocpsvc.SendQuitSignal(1);
  Result := True;
end;

begin
  g_HttpResponse := 'HTTP/1.1 200 OK'#13#10
    + 'Content-Type: text/plain; charset=UTF8'#13#10
    + 'Content-Length: 9'#13#10
    + 'Connection: Close'#13#10
    + 'Server: DSLIocpHttpServer 1.0'#13#10#13#10
    + UTF8Encode('»¶Ó­Äú');
  DSLHttp.g_LogHttp := True;
  RandSeed := GetTickCount;
  Randomize;
  ReportMemoryLeaksOnShutdown := True;
  SetConsoleCtrlHandler(@ConsoleCtrlHandler, True);
  openssl_loadlib('');
  try
    //test_client_socket;
    //test_http_client;
    //test_tcp_timeout(500);
    //TestWinHttp;
    //g_HttpKeepAlive := True;
    //TestHttpKeepAlive;
    //Test_iocp_server;
    Test_iocp_client;
    //OpenSSL_test('https://www.baidu.com');
    //nonblocking_ssl_test();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln('press Enter to exit...');
  Readln;
end.
