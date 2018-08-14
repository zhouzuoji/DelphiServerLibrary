unit uSSLTest;

interface

uses
  openssl, DSLSocket, DSLSocketHttp;

procedure OpenSSL_test(const url: string);
procedure nonblocking_ssl_test;

implementation

procedure nonblocking_ssl_test;
var
  ctx: PSSL_CTX;
  ssl: PSSL;
  s: TClientSocket;
  sslret: Integer;
begin
  ctx := SSL_CTX_new(TLS_method());

  if not Assigned(ctx) then
  begin
    Exit;
  end;

  ssl := nil;
  s := nil;

  try
    if SSL_CTX_use_certificate_file(ctx, 'F:\MyDesktop\openssl\cert.pem', SSL_FILETYPE_PEM) <= 0 then
    begin
      Writeln('SSL_CTX_use_certificate_file fail');
      Exit;
    end;

    if SSL_CTX_use_PrivateKey_file(ctx, 'F:\MyDesktop\openssl\key.pem', SSL_FILETYPE_PEM) <= 0 then
    begin
      Writeln('SSL_CTX_use_PrivateKey_file fail');
      Exit;
    end;

    if SSL_CTX_check_private_key(ctx) <= 0 then
    begin
      Writeln('SSL_CTX_check_private_key fail');
      Exit;
    end;

    s := TClientSocket.Create;
    s.connect('www.baidu.com', 80);
    s.blocking := False;

    ssl := SSL_new(ctx);
    SSL_set_fd(ssl, s.Handle);
    SSL_set_accept_state(ssl);

    sslret := SSL_do_handshake(ssl);
    Writeln('SSL_do_handshake returns ', sslret);
    Writeln('SSL_get_error returns ', SSL_get_error(ssl, sslret));

  finally
    if Assigned(s) then
      s.Free;

    if Assigned(ssl) then
      SSL_free(ssl);

    SSL_CTX_free(ctx);
  end;
end;

procedure OpenSSL_test(const url: string);
var
  httpcli: THttpSession;
begin
  httpcli := THttpSession.Create;
  try
    Writeln(httpcli.GetAndDecode(url));
  finally
    httpcli.Release;
  end;
end;

end.
