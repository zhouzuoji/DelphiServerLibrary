program HttpDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, Windows, DSLUtils, DSLHttp, openssl, DSLWinHttp, DSLSocketHttp;

procedure TestHttpProxy;
var
  HttpClient: THttpSession;
  proxy: THttpProxy;
begin
  HttpClient := THttpSession.Create;

  try
    proxy.HostName := '127.0.0.1';
    proxy.port := 8888;
    proxy.username := '1';
    proxy.password := '1';
    //HttpClient.SetProxy(proxy);
    //HttpClient.get('http://www.baidu.com');
    Writeln(HttpClient.getWithoutRedirectAndDecode('https://www.baidu.com'));
  finally
    HttpClient.Release;
  end;
end;

procedure TestWinHttpProxy;
var
  HttpClient: TWinHttpSession;
  proxy: THttpProxy;
begin
  HttpClient := TWinHttpSession.Create;

  try
    proxy.HostName := '127.0.0.1';
    proxy.port := 8888;
    proxy.username := '1';
    proxy.password := '1';
    //HttpClient.SetProxy(proxy);
    HttpClient.get('https://www.baidu.com');
    HttpClient.get('https://www.baidu.com');
  finally
    HttpClient.Release;
  end;
end;

begin
  DSLHttp.g_LogHttp := True;
  try
    //openssl_loadlib;
    //TestHttpProxy;
    //TestWinHttpProxy;
    f1();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  Writeln('press any key to exit...');
  Readln;
end.
