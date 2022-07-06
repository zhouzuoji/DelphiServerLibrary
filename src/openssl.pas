unit openssl;

interface

uses
  SysUtils, Classes, AnsiStrings, Windows, OpenSSLTypes, DSLUtils;

type
  TPrototype_CRYPTO_free = procedure(ptr: Pointer); cdecl;
  TPrototype_RIPEMD160 = function(d: Pointer; n: Integer; md: P160BitBuf): P160BitBuf; cdecl;
  TPrototype_BN_new = function: PBigNum; cdecl;
  TPrototype_BN_free = procedure(n: PBigNum); cdecl;
  TPrototype_BN_bin2bn = function(s: Pointer; len: Integer; bn: PBigNum): PBigNum; cdecl;
  TPrototype_BN_bn2bin = function(a: PBigNum; buf: Pointer): Integer; cdecl;
  TPrototype_EC_GROUP_new_by_curve_name = function(nid: Integer): PECGroup; cdecl;
  TPrototype_EC_GROUP_get0_generator = function(group: PECGroup): PECPoint; cdecl;
  TPrototype_EC_GROUP_free = procedure(g: PECGroup); cdecl;
  TPrototype_EC_GROUP_clear_free = procedure(g: PECGroup); cdecl;
  TPrototype_EC_POINT_new = function(group: PECGroup): PECPoint; cdecl;
  TPrototype_EC_POINT_free = procedure(pt: PECPoint); cdecl;
  TPrototype_EC_POINT_mul = function(group: PECGroup; r: PECPoint; n: PBigNum;
    q: PECPoint; m: PBigNum; ctx: PBN_CTX): Integer; cdecl;
  TPrototype_EC_POINT_point2hex = function(group: PECGroup; pt: PECPoint;
    form: TECPointConversionForm; ctx: PBN_CTX): PAnsiChar; cdecl;
  TPrototype_EC_KEY_new = function: PECKey; cdecl;
  TPrototype_EC_KEY_free = procedure(key: PECKey); cdecl;
  TPrototype_EC_KEY_new_by_curve_name = function(nid: Integer): PECKey; cdecl;
  TPrototype_EC_KEY_get0_private_key = function(key: PECKey): PBigNum; cdecl;
  TPrototype_EC_KEY_get0_public_key = function(key: PECKey): PECPoint; cdecl;
  TPrototype_EC_KEY_generate_key = function(key: PECKey): Integer; cdecl;
  TPrototype_EC_KEY_check_key = function(key: PECKey): Integer; cdecl;

  TPrototype_SSL_CTX_new = function(meth: POpenSSL_SSL_METHOD): POpenSSL_SSL_CTX; cdecl;
  TPrototype_SSL_CTX_free = procedure(ctx: POpenSSL_SSL_CTX) cdecl;
  TPrototype_SSL_set_fd = function(s: POpenSSL_SSL; fd: Integer): Integer; cdecl;
  TPrototype_SSL_new = function(ctx: POpenSSL_SSL_CTX): POpenSSL_SSL; cdecl;
  TPrototype_SSL_free = procedure(ssl: POpenSSL_SSL); cdecl;
  TPrototype_SSL_connect = function(ssl: POpenSSL_SSL): Integer; cdecl;
  TPrototype_SSL_accept = function(ssl: POpenSSL_SSL): Integer; cdecl;
  TPrototype_SSL_read = function(ssl: POpenSSL_SSL; buf: Pointer; num: Integer): Integer; cdecl;
  TPrototype_SSL_peek = function(ssl: POpenSSL_SSL; buf: Pointer; num: Integer): Integer; cdecl;
  TPrototype_SSL_write = function(ssl: POpenSSL_SSL; buf: Pointer; num: Integer): Integer; cdecl;
  TPrototype_SSL_shutdown = function(s: POpenSSL_SSL): Integer; cdecl;
  TPrototype_SSL_get_error = function(s: POpenSSL_SSL; ret_code: Integer): Integer; cdecl;
  TPrototype_SSL_set_connect_state = procedure(s: POpenSSL_SSL); cdecl;
  TPrototype_SSL_set_accept_state = procedure(s: POpenSSL_SSL); cdecl;
  TPrototype_SSL_do_handshake = function(s: POpenSSL_SSL): Integer; cdecl;
  TPrototype_SSL_use_RSAPrivateKey_file = function(s: POpenSSL_SSL; FileName: PAnsiChar; _type: Integer): Integer; cdecl;
  TPrototype_SSL_use_PrivateKey_file = function(s: POpenSSL_SSL; FileName: PAnsiChar; _type: Integer): Integer; cdecl;
  TPrototype_SSL_use_certificate_file = function(s: POpenSSL_SSL; FileName: PAnsiChar; _type: Integer): Integer; cdecl;
  TPrototype_SSL_CTX_use_RSAPrivateKey_file = function(ctx: POpenSSL_SSL_CTX; FileName: PAnsiChar; _type: Integer): Integer; cdecl;
  TPrototype_SSL_CTX_use_PrivateKey_file = function(ctx: POpenSSL_SSL_CTX; FileName: PAnsiChar; _type: Integer): Integer; cdecl;
  TPrototype_SSL_CTX_use_certificate_file = function(ctx: POpenSSL_SSL_CTX; FileName: PAnsiChar; _type: Integer): Integer; cdecl;
  TPrototype_SSL_CTX_check_private_key = function(ctx: POpenSSL_SSL_CTX): Integer; cdecl;
  TPrototype_SSL_check_private_key = function(s: POpenSSL_SSL): Integer; cdecl;
  TPrototype_SSL_get_peer_certificate = function(s: POpenSSL_SSL): POpenSSL_X509; cdecl;
  TPrototype_X509_get_subject_name = function(a: POpenSSL_X509): POpenSSL_X509_NAME; cdecl;
  TPrototype_X509_get_issuer_name = function(a: POpenSSL_X509): POpenSSL_X509_NAME; cdecl;
  TPrototype_X509_NAME_oneline = function(a: POpenSSL_X509_NAME; buf: PAnsiChar; size: Integer): PAnsiChar; cdecl;

var
  OPENSSL_free: TPrototype_CRYPTO_free = nil;
  RIPEMD160: TPrototype_RIPEMD160 = nil;
  BN_new: TPrototype_BN_new = nil;
  BN_free: TPrototype_BN_free = nil;
  BN_bin2bn: TPrototype_BN_bin2bn = nil;
  BN_bn2bin: TPrototype_BN_bn2bin = nil;
  EC_GROUP_new_by_curve_name: TPrototype_EC_GROUP_new_by_curve_name = nil;
  EC_GROUP_get0_generator: TPrototype_EC_GROUP_get0_generator = nil;
  EC_GROUP_free: TPrototype_EC_GROUP_free = nil;
  EC_GROUP_clear_free: TPrototype_EC_GROUP_clear_free = nil;
  EC_POINT_new: TPrototype_EC_POINT_new = nil;
  EC_POINT_free: TPrototype_EC_POINT_free = nil;
  EC_POINT_mul: TPrototype_EC_POINT_mul = nil;
  EC_POINT_point2hex: TPrototype_EC_POINT_point2hex = nil;
  EC_KEY_new: TPrototype_EC_KEY_new = nil;
  EC_KEY_free: TPrototype_EC_KEY_free = nil;
  EC_KEY_new_by_curve_name: TPrototype_EC_KEY_new_by_curve_name = nil;
  EC_KEY_get0_private_key: TPrototype_EC_KEY_get0_private_key = nil;
  EC_KEY_get0_public_key: TPrototype_EC_KEY_get0_public_key = nil;
  EC_KEY_generate_key: TPrototype_EC_KEY_generate_key = nil;
  EC_KEY_check_key: TPrototype_EC_KEY_check_key = nil;

  SSL_load_error_strings: procedure; cdecl = nil;
  SSL_library_init: function: Integer; cdecl = nil;
  SSLv2_method: TSSLMethodProvider = nil;
  SSLv2_server_method: TSSLMethodProvider = nil;
  SSLv2_client_method: TSSLMethodProvider = nil;
  SSLv3_method: TSSLMethodProvider = nil;
  SSLv3_server_method: TSSLMethodProvider = nil;
  SSLv3_client_method: TSSLMethodProvider = nil;
  SSLv23_method: TSSLMethodProvider = nil;
  SSLv23_server_method: TSSLMethodProvider = nil;
  SSLv23_client_method: TSSLMethodProvider = nil;
  TLSv1_method: TSSLMethodProvider = nil;
  TLSv1_server_method: TSSLMethodProvider = nil;
  TLSv1_client_method: TSSLMethodProvider = nil;
  TLSv1_1_method: TSSLMethodProvider = nil;
  TLSv1_1_server_method: TSSLMethodProvider = nil;
  TLSv1_1_client_method: TSSLMethodProvider = nil;
  TLSv1_2_method: TSSLMethodProvider = nil;
  TLSv1_2_server_method: TSSLMethodProvider = nil;
  TLSv1_2_client_method: TSSLMethodProvider = nil;
  TLS_method: TSSLMethodProvider = nil;
  TLS_server_method: TSSLMethodProvider = nil;
  TLS_client_method: TSSLMethodProvider = nil;
  DTLS_method: TSSLMethodProvider = nil;
  DTLS_server_method: TSSLMethodProvider = nil;
  DTLS_client_method: TSSLMethodProvider = nil;
  DTLSv1_method: TSSLMethodProvider = nil;
  DTLSv1_server_method: TSSLMethodProvider = nil;
  DTLSv1_client_method: TSSLMethodProvider = nil;
  DTLSv1_2_method: TSSLMethodProvider = nil;
  DTLSv1_2_server_method: TSSLMethodProvider = nil;
  DTLSv1_2_client_method: TSSLMethodProvider = nil;

  SSL_CTX_new: TPrototype_SSL_CTX_new = nil;
  SSL_CTX_free: TPrototype_SSL_CTX_free = nil;
  SSL_set_fd: TPrototype_SSL_set_fd = nil;
  SSL_new: TPrototype_SSL_new = nil;
  SSL_free: TPrototype_SSL_free = nil;
  SSL_connect: TPrototype_SSL_connect = nil;
  SSL_accept: TPrototype_SSL_accept = nil;
  SSL_read: TPrototype_SSL_read = nil;
  SSL_peek: TPrototype_SSL_peek = nil;
  SSL_write: TPrototype_SSL_write = nil;
  SSL_shutdown: TPrototype_SSL_shutdown = nil;
  SSL_get_error: TPrototype_SSL_get_error = nil;
  SSL_set_connect_state: TPrototype_SSL_set_connect_state = nil;
  SSL_set_accept_state: TPrototype_SSL_set_accept_state = nil;
  SSL_do_handshake: TPrototype_SSL_do_handshake = nil;
  SSL_use_RSAPrivateKey_file: TPrototype_SSL_use_RSAPrivateKey_file = nil;
  SSL_use_PrivateKey_file: TPrototype_SSL_use_PrivateKey_file = nil;
  SSL_use_certificate_file: TPrototype_SSL_use_certificate_file = nil;
  SSL_CTX_use_RSAPrivateKey_file: TPrototype_SSL_CTX_use_RSAPrivateKey_file = nil;
  SSL_CTX_use_PrivateKey_file: TPrototype_SSL_CTX_use_PrivateKey_file = nil;
  SSL_CTX_use_certificate_file: TPrototype_SSL_CTX_use_certificate_file = nil;
  SSL_CTX_check_private_key: TPrototype_SSL_CTX_check_private_key = nil;
  SSL_check_private_key: TPrototype_SSL_check_private_key = nil;
  SSL_get_peer_certificate: TPrototype_SSL_get_peer_certificate = nil;
  X509_get_subject_name: TPrototype_X509_get_subject_name = nil;
  X509_get_issuer_name: TPrototype_X509_get_issuer_name = nil;
  X509_NAME_oneline: TPrototype_X509_NAME_oneline = nil;

function openssl_loaded: Boolean; inline;
function openssl_loadlib(const ssleayFile: UnicodeString = 'ssleay32.dll'; const libeayFile: UnicodeString = 'libeay32.dll'): Boolean;
procedure initSSL;
function getX590SubjectName(a: POpenSSL_X509): string;
function getX590IssuerName(a: POpenSSL_X509): string;
function getClientSSLCtx(meth: POpenSSL_SSL_METHOD): POpenSSL_SSL_CTX;

implementation

type
  TPrefetchSSLCtx = record
    meth: POpenSSL_SSL_METHOD;
    ctx: POpenSSL_SSL_CTX;
  end;

var
  g_Module_ssleay32, g_Module_libeay32: HMODULE;
  g_PrefetchSSLCtxs: array [0..9] of TPrefetchSSLCtx;
  g_PrefetchSSLCtxCount: Integer = 0;

function openssl_loaded: Boolean;
begin
  Result := Assigned(@SSL_CTX_new);
end;

procedure unload_lib;
var
  i: Integer;
begin
  for i := 0 to g_PrefetchSSLCtxCount - 1 do
    SSL_CTX_free(g_PrefetchSSLCtxs[i].ctx);
  g_PrefetchSSLCtxCount := 0;

  if g_Module_ssleay32 <> 0 then
  begin
    FreeLibrary(g_Module_ssleay32);
    g_Module_ssleay32 := 0;
    @SSL_CTX_new := nil;
  end;

  if g_Module_libeay32 <> 0 then
  begin
    FreeLibrary(g_Module_libeay32);
    g_Module_libeay32 := 0;
  end;
end;

function getClientSSLCtx(meth: POpenSSL_SSL_METHOD): POpenSSL_SSL_CTX;
var
  i: Integer;
begin
  for i := 0 to g_PrefetchSSLCtxCount - 1 do
  begin
    if g_PrefetchSSLCtxs[i].meth = meth then
    begin
      Result := g_PrefetchSSLCtxs[i].ctx;
      Exit;
    end;
  end;
  Result := nil;
end;

function getX590SubjectName(a: POpenSSL_X509): string;
var
  name: POpenSSL_X509_NAME;
  p: PAnsiChar;
begin
  if not Assigned(X509_get_subject_name) then
  begin
    Result := '';
    Exit;
  end;

  name := X509_get_subject_name(a);
  p := X509_NAME_oneline(name, nil, 0);
  Result := string(AnsiStrings.StrPas(p));
end;

function getX590IssuerName(a: POpenSSL_X509): string;
var
  name: POpenSSL_X509_NAME;
  p: PAnsiChar;
begin
  if not Assigned(X509_get_issuer_name) then
  begin
    Result := '';
    Exit;
  end;

  name := X509_get_issuer_name(a);
  p := X509_NAME_oneline(name, nil, 0);
  Result := string(AnsiStrings.StrPas(p));
end;

function openssl_ExtractDLLFromRes: Boolean;
var
  AppPath, DllPath: string;
begin
  Result := False;
  AppPath := ExtractFilePath(ParamStr(0));
  DllPath := AppPath + 'libeay32.dll';

  if not FileExists(DllPath) then
    try
      SaveResToFile('libeay32', 'DLL', DllPath);
    except
      Exit;
    end;

  DllPath := AppPath + 'ssleay32.dll';

  if not FileExists(DllPath) then
    try
      SaveResToFile('ssleay32', 'DLL', DllPath);
    except
      Exit;
    end;
  Result := True;
end;

{$ifdef WIN32}
function SafeLoadLibraryW(const Filename: UnicodeString; ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE;
var
  OldMode: UINT;
  FPUControlWord: Word;
begin
  OldMode := SetErrorMode(ErrorMode);
  try
    asm
      FNSTCW  FPUControlWord
    end;
    try
      Result := LoadLibraryW(PWChar(Filename));
    finally
      asm
        FNCLEX
        FLDCW FPUControlWord
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;
{$else}
function SafeLoadLibraryW(const Filename: UnicodeString; ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE;
begin
  Result := LoadLibraryW(PWChar(Filename));
end;
{$endif}

function ssleay32_FindProc(const ProcName: PAnsiChar; var ProcAddress): Boolean;
begin
  Pointer(ProcAddress) := GetProcAddress(g_Module_ssleay32, ProcName);
  Result := Assigned(Pointer(ProcAddress));
end;

function libeay32_FindProc(const ProcName: PAnsiChar; var ProcAddress): Boolean;
begin
  Pointer(ProcAddress) := GetProcAddress(g_Module_libeay32, ProcName);
  Result := Assigned(Pointer(ProcAddress));
end;

procedure initSSL;
var
  idx: Integer;
begin
  if not openssl_loaded then Exit;

  SSL_load_error_strings();
  SSL_library_init();
  idx := 0;

  if Assigned(@SSLv2_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := SSLv2_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  if Assigned(@SSLv3_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := SSLv3_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  if Assigned(@SSLv23_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := SSLv23_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  if Assigned(@TLSv1_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := TLSv1_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  if Assigned(@TLSv1_1_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := TLSv1_1_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  if Assigned(@TLSv1_2_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := TLSv1_2_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  if Assigned(@TLS_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := TLS_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  if Assigned(@DTLSv1_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := DTLSv1_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  if Assigned(@DTLSv1_2_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := DTLSv1_2_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  if Assigned(@DTLS_client_method) then
  begin
    g_PrefetchSSLCtxs[idx].meth := DTLS_client_method();
    g_PrefetchSSLCtxs[idx].ctx := SSL_CTX_new(g_PrefetchSSLCtxs[idx].meth);
    Inc(idx);
  end;

  g_PrefetchSSLCtxCount := idx;

  if not Assigned(@SSLv2_method) then
  begin
    @SSLv2_method := @SSLv3_method;
    @SSLv2_server_method := @SSLv3_server_method;
    @SSLv2_client_method := @SSLv3_client_method;
  end;

  if not Assigned(@SSLv23_method) then
  begin
    @SSLv23_method := @SSLv3_method;
    @SSLv23_server_method := @SSLv3_server_method;
    @SSLv23_client_method := @SSLv3_client_method;
  end;

  if not Assigned(@TLS_method) then
  begin
    @TLS_method := @SSLv3_method;
    @TLS_server_method := @SSLv3_server_method;
    @TLS_client_method := @SSLv3_client_method;
  end;

  if not Assigned(@TLSv1_method) then
  begin
    @TLSv1_method := @TLS_method;
    @TLSv1_server_method := @TLS_server_method;
    @TLSv1_client_method := @TLS_client_method;
  end;

  if not Assigned(@TLSv1_1_method) then
  begin
    @TLSv1_1_method := @TLSv1_method;
    @TLSv1_1_server_method := @TLSv1_server_method;
    @TLSv1_1_client_method := @TLSv1_client_method;
  end;

  if not Assigned(@TLSv1_2_method) then
  begin
    @TLSv1_2_method := @TLSv1_1_method;
    @TLSv1_2_server_method := @TLSv1_1_server_method;
    @TLSv1_2_client_method := @TLSv1_1_client_method;
  end;

  if not Assigned(@DTLS_method) then
  begin
    @DTLS_method := @DTLSv1_method;
    @DTLS_server_method := @DTLSv1_server_method;
    @DTLS_client_method := @DTLSv1_client_method;
  end;

  if not Assigned(@DTLSv1_2_method) then
  begin
    @DTLSv1_2_method := @DTLSv1_method;
    @DTLSv1_2_server_method := @DTLSv1_server_method;
    @DTLSv1_2_client_method := @DTLSv1_client_method;
  end;
end;

function openssl_loadlib(const ssleayFile, libeayFile: UnicodeString): Boolean;
var
  _ssleayFile, _libeayFile: UnicodeString;
begin
  if openssl_loaded then
  begin
    Result := True;
    Exit;
  end;

  Result := False;

  if libeayFile = '' then
    _libeayFile := 'libeay32.dll'
  else
    _libeayFile := libeayFile;

  g_Module_libeay32 := SafeLoadLibraryW(_libeayFile);

  if g_Module_libeay32 = 0 then
  begin
    openssl_ExtractDLLFromRes;
    g_Module_libeay32 := SafeLoadLibraryW('libeay32.dll');
  end;

  if g_Module_libeay32 = 0 then Exit;

  if ssleayFile = '' then
    _ssleayFile := 'ssleay32.dll'
  else
    _ssleayFile := ssleayFile;

  g_Module_ssleay32 := SafeLoadLibraryW(_ssleayFile);

  if g_Module_ssleay32 = 0 then
  begin
    openssl_ExtractDLLFromRes;
    g_Module_ssleay32 := SafeLoadLibraryW('ssleay32.dll');
  end;

  if g_Module_ssleay32 = 0 then Exit;

  if ssleay32_FindProc('SSL_load_error_strings', SSL_load_error_strings)
    and ssleay32_FindProc('SSL_library_init', SSL_library_init)
    and ssleay32_FindProc('SSL_new', SSL_new)
    and ssleay32_FindProc('SSL_free', SSL_free)
    and ssleay32_FindProc('SSL_shutdown', SSL_shutdown)
    and ssleay32_FindProc('SSL_connect', SSL_connect)
    and ssleay32_FindProc('SSL_accept', SSL_accept)
    and ssleay32_FindProc('SSL_read', SSL_read)
    and ssleay32_FindProc('SSL_peek', SSL_peek)
    and ssleay32_FindProc('SSL_write', SSL_write)
    and ssleay32_FindProc('SSL_CTX_new', SSL_CTX_new)
    and ssleay32_FindProc('SSL_CTX_free', SSL_CTX_free)
    and ssleay32_FindProc('SSL_set_fd', SSL_set_fd)
    and ssleay32_FindProc('SSL_get_error', SSL_get_error)
    and ssleay32_FindProc('SSL_set_connect_state', SSL_set_connect_state)
    and ssleay32_FindProc('SSL_set_accept_state', SSL_set_accept_state)
    and ssleay32_FindProc('SSL_do_handshake', SSL_do_handshake)
    and ssleay32_FindProc('SSL_use_RSAPrivateKey_file', SSL_use_RSAPrivateKey_file)
    and ssleay32_FindProc('SSL_use_PrivateKey_file', SSL_use_PrivateKey_file)
    and ssleay32_FindProc('SSL_use_certificate_file', SSL_use_certificate_file)
    and ssleay32_FindProc('SSL_CTX_use_RSAPrivateKey_file', SSL_CTX_use_RSAPrivateKey_file)
    and ssleay32_FindProc('SSL_CTX_use_PrivateKey_file', SSL_CTX_use_PrivateKey_file)
    and ssleay32_FindProc('SSL_CTX_use_certificate_file', SSL_CTX_use_certificate_file)
    and ssleay32_FindProc('SSL_CTX_check_private_key', SSL_CTX_check_private_key)
    and ssleay32_FindProc('SSL_check_private_key', SSL_check_private_key)
    then
  begin
    ssleay32_FindProc('SSLv2_method', SSLv2_method);
    ssleay32_FindProc('SSLv2_server_method', SSLv2_server_method);
    ssleay32_FindProc('SSLv2_client_method', SSLv2_client_method);
    ssleay32_FindProc('SSLv3_method', SSLv3_method);
    ssleay32_FindProc('SSLv3_server_method', SSLv3_server_method);
    ssleay32_FindProc('SSLv3_client_method', SSLv3_client_method);
    ssleay32_FindProc('SSLv23_method', SSLv23_method);
    ssleay32_FindProc('SSLv23_server_method',SSLv23_server_method);
    ssleay32_FindProc('SSLv23_client_method', SSLv23_client_method);
    ssleay32_FindProc('TLSv1_method', TLSv1_method);
    ssleay32_FindProc('TLSv1_server_method', TLSv1_server_method);
    ssleay32_FindProc('TLSv1_client_method', TLSv1_client_method);
    ssleay32_FindProc('TLSv1_1_method', TLSv1_1_method);
    ssleay32_FindProc('TLSv1_1_server_method', TLSv1_1_server_method);
    ssleay32_FindProc('TLSv1_1_client_method', TLSv1_1_client_method);
    ssleay32_FindProc('TLSv1_2_method', TLSv1_2_method);
    ssleay32_FindProc('TLSv1_2_server_method', TLSv1_2_server_method);
    ssleay32_FindProc('TLSv1_2_client_method', TLSv1_2_client_method);
    ssleay32_FindProc('TLS_method', TLS_method);
    ssleay32_FindProc('TLS_server_method', TLS_server_method);
    ssleay32_FindProc('TLS_client_method', TLS_client_method);
    ssleay32_FindProc('DTLSv1_method', DTLSv1_method);
    ssleay32_FindProc('DTLSv1_server_method', DTLSv1_server_method);
    ssleay32_FindProc('DTLSv1_client_method', DTLSv1_client_method);
    ssleay32_FindProc('DTLSv1_2_method', DTLSv1_2_method);
    ssleay32_FindProc('DTLSv1_2_server_method', DTLSv1_2_server_method);
    ssleay32_FindProc('DTLSv1_2_client_method', DTLSv1_2_client_method);
    ssleay32_FindProc('DTLS_method', DTLS_method);
    ssleay32_FindProc('DTLS_server_method', DTLS_server_method);
    ssleay32_FindProc('DTLS_client_method', DTLS_client_method);
    ssleay32_FindProc('SSL_get_peer_certificate', SSL_get_peer_certificate);
    libeay32_FindProc('X509_get_subject_name', X509_get_subject_name);
    libeay32_FindProc('X509_get_issuer_name', X509_get_issuer_name);
    libeay32_FindProc('X509_NAME_oneline', X509_NAME_oneline);
    libeay32_FindProc('CRYPTO_free', OPENSSL_free);
    libeay32_FindProc('RIPEMD160', RIPEMD160);
    libeay32_FindProc('BN_new', BN_new);
    libeay32_FindProc('BN_free', BN_free);
    libeay32_FindProc('BN_bin2bn', BN_bin2bn);
    libeay32_FindProc('BN_bn2bin', BN_bn2bin);
    libeay32_FindProc('EC_GROUP_new_by_curve_name', EC_GROUP_new_by_curve_name);
    libeay32_FindProc('EC_GROUP_get0_generator', EC_GROUP_get0_generator);
    libeay32_FindProc('EC_GROUP_free', EC_GROUP_free);
    libeay32_FindProc('EC_GROUP_clear_free', EC_GROUP_clear_free);
    libeay32_FindProc('EC_POINT_new', EC_POINT_new);
    libeay32_FindProc('EC_POINT_free', EC_POINT_free);
    libeay32_FindProc('EC_POINT_mul', EC_POINT_mul);
    libeay32_FindProc('EC_POINT_point2hex', EC_POINT_point2hex);

    libeay32_FindProc('EC_KEY_new', EC_KEY_new);
    libeay32_FindProc('EC_KEY_free', EC_KEY_free);
    libeay32_FindProc('EC_KEY_new_by_curve_name', EC_KEY_new_by_curve_name);
    libeay32_FindProc('EC_KEY_get0_private_key', EC_KEY_get0_private_key);
    libeay32_FindProc('EC_KEY_get0_public_key', EC_KEY_get0_public_key);
    libeay32_FindProc('EC_KEY_generate_key', EC_KEY_generate_key);
    libeay32_FindProc('EC_KEY_check_key', EC_KEY_check_key);
    initSSL();
    Result := True;
  end
  else
    unload_lib;
end;

initialization

finalization
  unload_lib;

end.
