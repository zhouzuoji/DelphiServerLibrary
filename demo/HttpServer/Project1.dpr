program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, Windows, DSLUtils, DSLWinsock2, DSLSocket, DSLIocp, DSLIocpHttpServer;

type
  TConsoleApp = class
  public
    procedure processHttpRequeset(sender: TIocpHttpServer; connection: TIocpHttpServerConnection);
  end;

{ TConsoleApp }

procedure TConsoleApp.processHttpRequeset(sender: TIocpHttpServer; connection: TIocpHttpServerConnection);
var
  s: RawByteString;
begin
  with connection.getHeadersParser.requestLine do
    s := method + ' ' + pathWithParam + ' HTTP/' + IntToRBStr(majorVersion) + '.' + IntToRBStr(minorVersion)
      + #13#10 + connection.getHeadersParser.requestHeaders.all + #13#10 + connection.requestBody;

  connection.sendHttpResponse(s, 'text/plain; charset=UTF-8');
end;

var
  g_app: TConsoleApp;
  g_iocp: TIocpIOService;
  g_httpServer: TIocpHttpServer;
  g_timeWheel: TTimeWheel;
  g_Terminated: Boolean = False;

function HandlerRoutine(dwCtrlType: DWORD): BOOL; stdcall;
begin
  g_httpServer.close;
  Sleep(1000);
  g_iocp.SendQuitSignal;
  Result := True;
end;

begin
  System.ReportMemoryLeaksOnShutdown := True;
  SetConsoleCtrlHandler(@HandlerRoutine, True);
  g_app := TConsoleApp.Create;
  g_iocp := TIocpIOService.Create;
  g_timeWheel := TTimeWheel.Create(100);
  g_httpServer := TIocpHttpServer.Create(g_timeWheel);
  g_httpServer.onRequest := g_app.processHttpRequeset;

  try
    g_httpServer.start(g_iocp, TEndPointCreator.Create(0, 9999), 5);
    g_timeWheel.run;
    g_iocp.run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  g_iocp.Free;
  g_app.Free;
  g_httpServer.release;
  g_timeWheel.release;
  Writeln(getAsyncIOCount, ' requests pending');
  Writeln('press ENTER to exit...');
  Readln;
end.
