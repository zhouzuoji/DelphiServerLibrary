unit DSLWinHttp;

interface

uses
  SysUtils, Classes, Windows, WinHttp, DSLHttp, ZLibExApi, DSLUtils;

{$ifndef UNICODE}
type
  UnicodeString = WideString;
  PUnicodeString = ^UnicodeString;
  RawByteString = AnsiString;
  PRawByteString = ^RawByteString;
{$endif}

const
  IE8_USER_AGENT = 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0)';

  DEFAULT_HTTP_HEADERS: UnicodeString =
    'Accept: */*'#13#10 +
    'Accept-Encoding: gzip,deflate'#13#10 +
    'Connection: Close'#13#10 +
    'Accept-Language: *'#13#10 +
    'Cache-Control: no-cache';

  DEFAULT_POST_HTTP_HEADERS: UnicodeString =
    'Accept: */*'#13#10 +
    'Accept-Encoding: gzip,deflate'#13#10 +
    'Connection: Close'#13#10 +
    'Accept-Language: *'#13#10 +
    'Cache-Control: no-cache'#13#10 +
    'Content-Type: application/x-www-form-urlencoded';

type
  TWinHttpException = class(Exception)
  private
    fFunctionName: string;
    fErrorCode: Integer;
  public
    constructor Create(const _func: string; _code: Integer); overload;
    constructor Create(const _func: string; _code: Integer; const msg: string); overload;
    property FunctionName: string read fFunctionName write fFunctionName;
    property ErrorCode: Integer read fErrorCode write fErrorCode;
  end;
  
  TGzipException = class(Exception);
  
  THttpRequestOptions = record
    AutoCookie: Boolean;
    AutoRedirect: Boolean;
    PragmaNoCache: Boolean;
  end;
  PTHttpRequestOptions = ^THttpRequestOptions;

  THttpRequest = record
    schema: PWideChar;
    method: PWideChar;
    host: PWideChar;
    port: Word;
    username: PWideChar;
    password: PWideChar;
    PathWithParams: PWideChar;
    referer: PWideChar;
    param: Pointer;
    ParamLength: DWORD;
    ParamStream: TStream;
    RequestHeaders: PWideChar;
    AutoDecompress: Boolean;
    SendingTimeout: DWORD;
    ReceivingTimeout: DWORD;
    options: THttpRequestOptions;
    procedure init;
    procedure InitWithUrl(url: PWideChar);
  end;

procedure WinHttpParseURI(url: PWideChar; out port: Word; out scheme, host,
  UserName, password, PathWithParams: UnicodeString);

function WinHttpSetDWORDOption(handle: HINTERNET; option, value: DWORD): Boolean;

function WinHttpGetStringHeaderLength(request: HINTERNET; info: DWORD): Integer;

function WinHttpGetStringHeader(request: HINTERNET; info: DWORD; buf: PWideChar): Integer; overload;

function WinHttpGetStringHeader(request: HINTERNET; info: DWORD): UnicodeString; overload;

procedure WinHttpSendBuffer(request: HINTERNET; buffer: Pointer; BufferLength: DWORD);

procedure WinHttpSendStream(request: HINTERNET; stream: TStream);

procedure WinHttpReceiveStream(request: HINTERNET; stream: TStream; AutoDecompress: Boolean);

function XMLGetCharset(content: PAnsiChar; ContentLength: Integer; charset: PAnsiChar): Integer;

function HTMLGetCharset(content: PAnsiChar; ContentLength: Integer; charset: PAnsiChar): Integer;

type
  TWinHttpSession = class
  private
    FHandle: HINTERNET;
  public
    constructor Create(user_agent: PWideChar; access_type: DWORD;
      ProxyName, ProxyBypass: PWideChar; flags: DWORD); overload;

    constructor Create; overload;

    destructor Destroy; override;

    function SetProxy(proxy: PWideChar): Boolean; overload;

    function SetProxy(proxy: UnicodeString): Boolean; overload;

    procedure SetTimeout(ResolvingTimeout, ConnectingTimeout, SendingTimeout, ReceivingTimeout: DWORD);

    procedure DoRequest(const request: THttpRequest; ResponseContent: TStream; pLocation: PUnicodeString = nil); overload;

    function DoRequest(const request: THttpRequest; pLocation: PUnicodeString = nil): RawByteString; overload;

    procedure DoRequest(const request: THttpRequest; ResponseContent: TStream; TimesErrorRetry: DWORD;
      pLocation: PUnicodeString = nil); overload;

    function DoRequest(const request: THttpRequest; TimesErrorRetry: DWORD;
      pLocation: PUnicodeString = nil): RawByteString; overload;

    function DoRequestAndDecode(const request: THttpRequest; pLocation: PUnicodeString = nil): UnicodeString; overload;

    function DoRequestAndDecode(const request: THttpRequest; TimesErrorRetry: DWORD;
      pLocation: PUnicodeString = nil): UnicodeString; overload;

    function DoRequestEx(const request: THttpRequest; ResponseContent: TStream): HINTERNET; overload;

    function DoRequestEx(const request: THttpRequest; out ResponseContent: RawByteString): HINTERNET; overload;

    procedure DoRequest(url, method, referer, RequestHeaders: PWideChar; param: Pointer;
      ParamLength: DWORD; ParamStream: TStream; content: TStream; pOptions: PTHttpRequestOptions = nil;
      pLocation: PUnicodeString = nil; _AutoDecompress: Boolean = True; _TimesErrorRetry: DWORD = 0;
      _SendingTimeout: DWORD = 0; _ReceivingTimeout: DWORD = 0); overload;

    function DoRequest(url, method, referer, RequestHeaders: PWideChar; param: Pointer;
      ParamLength: DWORD; ParamStream: TStream; pOptions: PTHttpRequestOptions = nil;
      pLocation: PUnicodeString = nil; _AutoDecompress: Boolean = True; _TimesErrorRetry: DWORD = 0;
      _SendingTimeout: DWORD = 0; _ReceivingTimeout: DWORD = 0): RawByteString; overload;

    function DoRequestAndDecode(url, method, referer, RequestHeaders: PWideChar; param: Pointer;
      ParamLength: DWORD; ParamStream: TStream; pOptions: PTHttpRequestOptions = nil;
      pLocation: PUnicodeString = nil; _AutoDecompress: Boolean = True; _TimesErrorRetry: DWORD = 0;
      _SendingTimeout: DWORD = 0; _ReceivingTimeout: DWORD = 0): UnicodeString; overload;

    procedure get(url: PWideChar; content: TStream; referer: PWideChar = nil); overload;
    function get(url: PWideChar; referer: PWideChar = nil): RawByteString; overload;
    procedure get(const url: UnicodeString; content: TStream; const referer: UnicodeString = ''); overload;
    function get(const url: UnicodeString; const referer: UnicodeString = ''): RawByteString; overload;
    function GetAndDecode(url: PWideChar; referer: PWideChar = nil): UnicodeString; overload;
    function GetAndDecode(const url: UnicodeString; const referer: UnicodeString = ''): UnicodeString; overload;

    procedure GetWithoutRedirect(url: PWideChar; content: TStream; referer: PWideChar = nil;
      pLocation: PUnicodeString = nil); overload;

    function GetWithoutRedirect(url: PWideChar; referer: PWideChar = nil;
      pLocation: PUnicodeString = nil): RawByteString; overload;

    procedure GetWithoutRedirect(const url: UnicodeString; content: TStream; const referer: UnicodeString = '';
       pLocation: PUnicodeString = nil); overload;

    function GetWithoutRedirect(const url: UnicodeString; const referer: UnicodeString = '';
      pLocation: PUnicodeString = nil): RawByteString; overload;

    function GetWithoutRedirectAndDecode(url: PWideChar; referer: PWideChar = nil;
      pLocation: PUnicodeString = nil): UnicodeString; overload;

    function GetWithoutRedirectAndDecode(const url: UnicodeString; const referer: UnicodeString = '';
      pLocation: PUnicodeString = nil): UnicodeString; overload;

    procedure PostEx(url, referer: PWideChar; param: Pointer; ParamLength: DWORD; ParamStream, content: TStream;
      ParamType: PWideChar = nil; pOptions: PTHttpRequestOptions = nil; pLocation: PUnicodeString = nil); overload;

    function PostEx(url, referer: PWideChar; param: Pointer; ParamLength: DWORD; ParamStream: TStream;
      ParamType: PWideChar = nil; pOptions: PTHttpRequestOptions = nil; pLocation: PUnicodeString = nil): RawByteString; overload;

    function PostAndDecodeEx(url, referer: PWideChar; param: Pointer; ParamLength: DWORD; ParamStream: TStream;
      ParamType: PWideChar = nil; pOptions: PTHttpRequestOptions = nil; pLocation: PUnicodeString = nil): UnicodeString;

    procedure post(url, referer: PWideChar; const param: RawByteString; content: TStream; ParamType: PWideChar = nil); overload;
    function post(url, referer: PWideChar; const param: RawByteString; ParamType: PWideChar = nil): RawByteString; overload;
    procedure post(url, referer: PWideChar; param, content: TStream; ParamType: PWideChar = nil); overload;
    function post(url, referer: PWideChar; param: TStream; ParamType: PWideChar = nil): RawByteString; overload;

    procedure post(const url, referer: UnicodeString; const param: RawByteString; content: TStream; const ParamType: UnicodeString = ''); overload;
    function post(const url, referer: UnicodeString; const param: RawByteString; const ParamType: UnicodeString = ''): RawByteString; overload;
    procedure post(const url, referer: UnicodeString; param, content: TStream; const ParamType: UnicodeString = ''); overload;
    function post(const url, referer: UnicodeString; param: TStream; const ParamType: UnicodeString = ''): RawByteString; overload;

    procedure PostWithoutRedirect(url, referer: PWideChar; const param: RawByteString; content: TStream;
      ParamType: PWideChar = nil; pLoacation: PUnicodeString = nil); overload;

    function PostWithoutRedirect(url, referer: PWideChar; const param: RawByteString; ParamType: PWideChar = nil; pLoacation: PUnicodeString = nil): RawByteString; overload;

    procedure PostWithoutRedirect(url, referer: PWideChar; param, content: TStream; ParamType: PWideChar = nil; pLoacation: PUnicodeString = nil); overload;

    function PostWithoutRedirect(url, referer: PWideChar; param: TStream; ParamType: PWideChar = nil; pLoacation: PUnicodeString = nil): RawByteString; overload;

    procedure PostWithoutRedirect(const url, referer: UnicodeString; const param: RawByteString; content: TStream; const ParamType: UnicodeString = ''; pLoacation: PUnicodeString = nil); overload;
    function PostWithoutRedirect(const url, referer: UnicodeString; const param: RawByteString; const ParamType: UnicodeString = ''; pLoacation: PUnicodeString = nil): RawByteString; overload;
    procedure PostWithoutRedirect(const url, referer: UnicodeString; param, content: TStream; const ParamType: UnicodeString = ''; pLoacation: PUnicodeString = nil); overload;
    function PostWithoutRedirect(const url, referer: UnicodeString; param: TStream; const ParamType: UnicodeString = ''; pLoacation: PUnicodeString = nil): RawByteString; overload;

    function PostAndDecode(url, referer: PWideChar; const param: RawByteString; ParamType: PWideChar = nil): UnicodeString; overload;
    function PostAndDecode(url, referer: PWideChar; param: TStream; ParamType: PWideChar = nil): UnicodeString; overload;
    function PostAndDecode(const url, referer: UnicodeString; const param: RawByteString; const ParamType: UnicodeString = ''): UnicodeString; overload;
    function PostAndDecode(const url, referer: UnicodeString; param: TStream; const ParamType: UnicodeString = ''): UnicodeString; overload;

    function PostWithoutRedirectAndDecode(url, referer: PWideChar; const param: RawByteString; ParamType: PWideChar = nil; pLoacation: PUnicodeString = nil): UnicodeString; overload;
    function PostWithoutRedirectAndDecode(url, referer: PWideChar; param: TStream; ParamType: PWideChar = nil; pLoacation: PUnicodeString = nil): UnicodeString; overload;
    function PostWithoutRedirectAndDecode(const url, referer: UnicodeString; const param: RawByteString; const ParamType: UnicodeString = ''; pLoacation: PUnicodeString = nil): UnicodeString; overload;
    function PostWithoutRedirectAndDecode(const url, referer: UnicodeString; param: TStream; const ParamType: UnicodeString = ''; pLoacation: PUnicodeString = nil): UnicodeString; overload;

    function upload(url, referer: PWideChar; const FileDatas: array of TStream;
      const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of AnsiString;
      const charset: AnsiString = ''): RawByteString; overload;

    procedure upload(url, referer: PWideChar; const FileDatas: array of TStream;
      const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of AnsiString;
      content: TStream; const charset: AnsiString = ''); overload;

    function UploadAndDecode(url, referer: PWideChar; const FileDatas: array of TStream;
      const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of AnsiString;
      const charset: AnsiString = ''): UnicodeString;
      
    property Handle: HINTERNET read FHandle;
  end;

procedure HttpFillUploadStream(
  const boundary: AnsiString;
  const FileKeys: array of AnsiString;
  const FileDatas: array of TStream;
  const FileNames: array of AnsiString;
  const MimeTypes: array of AnsiString;
  ParamNames: array of AnsiString;
  ParamValues: array of AnsiString;
  PostParam: TStream);

implementation

const
  S_GET: PWideChar = 'GET';
  S_POST: PWideChar = 'POST';
  NoRedirectOptions: THttpRequestOptions = (AutoCookie: True; AutoRedirect: False; PragmaNoCache: True);

function wcslen(s: PWideChar): Integer;
var
  term: PWideChar;
begin
  Result := 0;

  if Assigned(s) then
  begin
    term := s;

    while term^ <> #0 do Inc(term);

    Result := term - s;
  end;
end;

function StrCompareW(s1, s2: PWideChar): Integer;
var
  diff: Integer;
begin
  Result := 0;

  while s1^ <> #0 do
  begin
    diff := PWord(s1)^ - PWord(s2)^;

    if diff <> 0 then
    begin
      Result := diff;
      Break;
    end;

    Inc(s1);
    Inc(s2);
  end;

  if s2^ <> #0 then Result := -1;
end;

function StrICompareW(s1, s2: PWideChar): Integer;
var
  diff: Integer;
  c1, c2: WideChar;
begin
  Result := 0;

  while s1^ <> #0 do
  begin
    c1 := s1^;
    c2 := s2^;

    if (c1 >= 'A') and (c1 <= 'Z') then Inc(Word(c1), 32);

    if (c2 >= 'A') and (c2 <= 'Z') then Inc(Word(c2), 32);

    diff := Ord(c1) - Ord(c2);

    if diff <> 0 then
    begin
      Result := diff;
      Break;
    end;

    Inc(s1);
    Inc(s2);
  end;

  if s2^ <> #0 then Result := -1;
end;

procedure HttpFillUploadStream(
  const boundary: AnsiString;
  const FileKeys: array of AnsiString;
  const FileDatas: array of TStream;
  const FileNames: array of AnsiString;
  const MimeTypes: array of AnsiString;
  ParamNames: array of AnsiString;
  ParamValues: array of AnsiString;
  PostParam: TStream);
const
  SContentDisposition: AnsiString = 'Content-Disposition: form-data; name="';
  SFileName: AnsiString = '"; filename="';
  SContentType: AnsiString = '"'#13#10'Content-Type: ';
  STextPlainContentType: AnsiString = '"'#13#10'Content-Type: text/plain'#13#10#13#10;
  SNameTag = 'name';
  SCRLF: AnsiString = #13#10;
  SDoubleMinus: AnsiString = '--';
var
  i, L: Integer;
begin
  L := 0;
  
  for i := Low(ParamNames) to High(ParamNames) do
  begin
    // \r\n--boundary\r\n
    Inc(L, Length(SCRLF) + Length(SDoubleMinus) + Length(boundary) + Length(SCRLF));

    // Content-Disposition: form-data; name="ParamName"\r\nContent-Type:text/plain\r\n\r\n
    Inc(L, Length(SContentDisposition) + Length(ParamNames[i]) + Length(STextPlainContentType));

    // ParamValue
    Inc(L, Length(ParamValues[i]));
  end;

  for i := Low(FileKeys) to High(FileKeys) do
  begin
    // \r\n--boundary\r\n
    Inc(L, Length(SCRLF) + Length(SDoubleMinus) + Length(boundary) + Length(SCRLF));

    // Content-Disposition: form-data; name="tmpname"; filename="FileName"\r\nContent-Type: MimeType\r\n
    Inc(L, Length(SContentDisposition) + Length(FileKeys[i]) + Length(SFileName) + Length(FileNames[i])
      + Length(SContentType) + Length(MimeTypes[i]) + Length(SCRLF) * 2);

    // FileContent
    Inc(L, FileDatas[i].Size);
  end;

  // \r\n--boundary--\r\n
  Inc(L, Length(SCRLF) + Length(SDoubleMinus) + Length(boundary) +
    Length(SDoubleMinus) + Length(SCRLF));

  PostParam.Size := L;

  for i := Low(ParamNames) to High(ParamNames) do
  begin
    // \r\n--boundary\r\n
    StreamWriteStrA(PostParam, SCRLF);
    StreamWriteStrA(PostParam, SDoubleMinus);
    StreamWriteStrA(PostParam, boundary);
    StreamWriteStrA(PostParam, SCRLF);

    // Content-Disposition: form-data; name="ParamName"\r\nContent-Type:text/plain\r\n\r\n
    StreamWriteStrA(PostParam, SContentDisposition);
    StreamWriteStrA(PostParam, ParamNames[i]);
    StreamWriteStrA(PostParam, STextPlainContentType);

    // ParamValue
    StreamWriteStrA(PostParam, ParamValues[i]);
  end;

  for i := Low(FileKeys) to High(FileKeys) do
  begin
    // \r\n--boundary\r\n
    StreamWriteStrA(PostParam, SCRLF);
    StreamWriteStrA(PostParam, SDoubleMinus);
    StreamWriteStrA(PostParam, boundary);
    StreamWriteStrA(PostParam, SCRLF);

    // Content-Disposition: form-data; name="tmpname"; filename="FileName"\r\nContent-Type: MimeType\r\n
    StreamWriteStrA(PostParam, SContentDisposition);
    StreamWriteStrA(PostParam, FileKeys[i]);
    StreamWriteStrA(PostParam, SFileName);
    StreamWriteStrA(PostParam, FileNames[i]);
    StreamWriteStrA(PostParam, SContentType);
    StreamWriteStrA(PostParam, MimeTypes[i]);
    StreamWriteStrA(PostParam, SCRLF);
    StreamWriteStrA(PostParam, SCRLF);

    // FileContent
    PostParam.CopyFrom(FileDatas[i], 0);
  end;

  // \r\n--boundary--\r\n
  StreamWriteStrA(PostParam, SCRLF);
  StreamWriteStrA(PostParam, SDoubleMinus);
  StreamWriteStrA(PostParam, boundary);
  StreamWriteStrA(PostParam, SDoubleMinus);
  StreamWriteStrA(PostParam, SCRLF);
end;

procedure WinHttpParseURI(url: PWideChar; out port: Word; out scheme, host,
  UserName, password, PathWithParams: UnicodeString);
var
  urlcomp: URL_COMPONENTS;
begin
  FillChar(urlcomp, SizeOf(urlcomp), 0);
  urlcomp.dwStructSize := SizeOf(urlcomp);
  urlcomp.dwSchemeLength := DWORD(-1);
  urlcomp.dwHostNameLength := DWORD(-1);
  urlcomp.dwUserNameLength := DWORD(-1);
  urlcomp.dwPasswordLength := DWORD(-1);
  urlcomp.dwUrlPathLength := DWORD(-1);
  urlcomp.dwExtraInfoLength := DWORD(-1);
  urlcomp.align := 0;

  if not WinHttpCrackUrl(url, wcslen(url), 0, urlcomp) then
    raise TWinHttpException.Create('WinHttpCrackUrl', GetLastError);

  SetString(host, urlcomp.lpszHostName, urlcomp.dwHostNameLength);
  SetString(UserName, urlcomp.lpszUserName, urlcomp.dwUserNameLength);
  SetString(password, urlcomp.lpszPassword, urlcomp.dwPasswordLength);

  SetString(PathWithParams, urlcomp.lpszUrlPath, Length(url) -
    (urlcomp.lpszUrlPath - url));

  SetString(scheme, urlcomp.lpszScheme, urlcomp.dwSchemeLength);

  if PathWithParams = '' then PathWithParams := '/';
  port := urlcomp.nPort;
end;

function WinHttpSetDWORDOption(handle: HINTERNET; option, value: DWORD): Boolean;
begin
  Result := WinHttpSetOption(handle, option, @value, SizeOf(value));
end;

function WinHttpGetStringHeaderLength(request: HINTERNET; info: DWORD): Integer;
var
  LastError, BufferLength: DWORD;
begin
  BufferLength := 0;

  //因为提供的buffer为nil，这个调用一定会失败，且如果header存在的话，
  //返回错误码应该是ERROR_INSUFFICIENT_BUFFER
  WinHttpQueryHeaders(request, info, WINHTTP_HEADER_NAME_BY_INDEX,
    WINHTTP_NO_OUTPUT_BUFFER, BufferLength, WINHTTP_NO_HEADER_INDEX);

  LastError := GetLastError;

  if LastError = ERROR_INSUFFICIENT_BUFFER then Result := BufferLength shr 1 - 1
  else if LastError = ERROR_WINHTTP_HEADER_NOT_FOUND then Result := 0
  else Result := -1;
end;

function WinHttpGetStringHeader(request: HINTERNET; info: DWORD): UnicodeString;
var
  LastError, BufferLength: DWORD;
begin
  BufferLength := 0;

  //因为提供的buffer为nil，这个调用一定会失败，且如果header存在的话，
  //返回错误码应该是ERROR_INSUFFICIENT_BUFFER
  WinHttpQueryHeaders(request, info, WINHTTP_HEADER_NAME_BY_INDEX,
    WINHTTP_NO_OUTPUT_BUFFER, BufferLength, WINHTTP_NO_HEADER_INDEX);

  LastError := GetLastError;

  if LastError = ERROR_INSUFFICIENT_BUFFER then
  begin
    SetLength(Result, (BufferLength shr 1) - 1);

    if not WinHttpQueryHeaders(request, info, WINHTTP_HEADER_NAME_BY_INDEX,
      Pointer(Result), BufferLength, WINHTTP_NO_HEADER_INDEX) then
      raise TWinHttpException.Create('WinHttpQueryHeaders', GetLastError);
  end
  else if LastError = ERROR_WINHTTP_HEADER_NOT_FOUND then
    Result := ''
  else
    raise TWinHttpException.Create('WinHttpQueryHeaders', LastError);;
end;

function WinHttpGetStringHeader(request: HINTERNET; info: DWORD; buf: PWideChar): Integer;
var
  LastError, BufferLength: DWORD;
begin
  BufferLength := 1024;

  if WinHttpQueryHeaders(request, info, WINHTTP_HEADER_NAME_BY_INDEX, Pointer(buf), BufferLength,
    WINHTTP_NO_HEADER_INDEX) then Result := (BufferLength shr 1)
  else begin
    LastError := GetLastError;

    if LastError = ERROR_INSUFFICIENT_BUFFER then Result := -1
    else if LastError = ERROR_WINHTTP_HEADER_NOT_FOUND then Result := -2
    else Result := -3;
  end;
end;

procedure WinHttpSendBuffer(request: HINTERNET; buffer: Pointer; BufferLength: DWORD);
var
  ptr: Pointer;
  len, BytesWritten: DWORD;
begin
  ptr := buffer;
  len := BufferLength;
  while len > 0 do
  begin
    if not WinHttpWriteData(request, ptr, len, @BytesWritten) then
      raise TWinHttpException.Create('WinHttpWriteData', GetLastError);

    Dec(len, BytesWritten);
    Inc(PByte(ptr), BytesWritten);
  end;
end;

procedure WinHttpSendStream(request: HINTERNET; stream: TStream);
var
  buffer: array[0..1023] of Byte;
  len: DWORD;
begin
  if stream is TMemoryStream then
    WinHttpSendBuffer(request, TMemoryStream(stream).Memory, stream.Size)
  else begin
    len := stream.Read(buffer, SizeOf(buffer));
    while len > 0 do
    begin
      WinHttpSendBuffer(request, @buffer, len);
      len := stream.Read(buffer, SizeOf(buffer));
    end;
  end;
end;

procedure WinHttpReceiveStream(request: HINTERNET; stream: TStream; AutoDecompress: Boolean);
var
  buffer: array[0..1023] of Byte;
  dest: array[0..1023] of Byte;
  BytesRead: DWORD;
  zlibStrm: TZStreamRec;
  enc: UnicodeString;
  compressed: Boolean;
  zres: Integer;
begin
  compressed := False;
  if AutoDecompress then
  begin
    enc := WinHttpGetStringHeader(request, WINHTTP_QUERY_CONTENT_ENCODING);
    if SameText(enc, 'gzip') then
    begin
      FillChar(zlibStrm, SizeOf(zlibStrm), 0);
      inflateInit2(zlibStrm, 47);
      compressed := True;
    end
    else if SameText(enc, 'deflate') then
    begin
      FillChar(zlibStrm, SizeOf(zlibStrm), 0);
      inflateInit(zlibStrm);
      compressed := True;
    end;
  end;

  while True do
  begin
    if not WinHttpReadData(request, @buffer, SizeOf(buffer), BytesRead) then
      raise TWinHttpException.Create('WinHttpReadData', GetLastError);

    if BytesRead = 0 then
    begin
      if compressed then
        inflateEnd(zlibStrm);
      Break;
    end;

    if not compressed then
      stream.WriteBuffer(buffer, BytesRead)
    else begin
      zlibStrm.next_in := PByte(@buffer);
      zlibStrm.avail_in := BytesRead;
      while zlibStrm.avail_in > 0 do
      begin
        zlibStrm.next_out := PByte(@dest);
        zlibStrm.avail_out := SizeOf(dest);
        zres := inflate(zlibStrm, Z_NO_FLUSH);
        if zres in [Z_OK, Z_STREAM_END] then
          stream.WriteBuffer(dest, SizeOf(dest) - zlibStrm.avail_out)
        else
          raise TGzipException.Create('invalid gzip stream.');
      end;
    end;

  end;
end;

{ THttpRequest }

procedure THttpRequest.init;
begin
  FillChar(Self, sizeof(THttpRequest), 0);
  Self.AutoDecompress := True;
  Self.options.AutoCookie := True;
  Self.options.AutoRedirect := True;
  Self.options.PragmaNoCache := True;
end;

procedure THttpRequest.InitWithUrl(url: PWideChar);
var
  _scheme, _host, _username, _password, _PathWithParams: UnicodeString;
begin
  Self.init;

  WinHttpParseURI(url, port, _scheme, _host, _username, _password, _PathWithParams);

  Self.schema := PWideChar(_scheme);
  Self.host := PWideChar(_host);
  Self.port := port;
  Self.username := PWideChar(_username);
  Self.password := PWideChar(_password);
  Self.PathWithParams := PWideChar(_PathWithParams);
end;

{ TWinHttpException }

constructor TWinHttpException.Create(const _func: string; _code: Integer);
var
  _msg: string;
begin
  fFunctionName := _func;
  fErrorCode := _code;

  _msg := SysErrorMessage(_code);

  if _msg = '' then
    inherited CreateFmt('%s error(%d).', [_func, _code])
  else
    inherited CreateFmt('%s(%d): %s', [_func, _code, _msg]);
end;

constructor TWinHttpException.Create(const _func: string; _code: Integer; const msg: string);
begin
  fFunctionName := _func;
  fErrorCode := _code;
  inherited Create(msg);
end;

{ TWinHttpSession }

constructor TWinHttpSession.Create(user_agent: PWideChar; access_type: DWORD;
  ProxyName, ProxyBypass: PWideChar; flags: DWORD);
begin
  FHandle := WinHttpOpen(user_agent, access_type, ProxyName, ProxyBypass, flags);

  if not Assigned(FHandle) then
    raise TWinHttpException.Create('WinHttpOpen', GetLastError);
end;

constructor TWinHttpSession.Create;
begin
  Create(IE8_USER_AGENT, WINHTTP_ACCESS_TYPE_NO_PROXY, WINHTTP_NO_PROXY_NAME,
    WINHTTP_NO_PROXY_BYPASS, 0);
end;

destructor TWinHttpSession.Destroy;
begin
  if Assigned(FHandle) then
  begin
    WinHttpCloseHandle(FHandle);
    FHandle := nil;
  end;

  inherited;
end;

function TWinHttpSession.SetProxy(proxy: PWideChar): Boolean;
var
  info: WINHTTP_PROXY_INFO;
begin
  if (proxy = nil) or (proxy^ = #0) then
  begin
    info.dwAccessType := WINHTTP_ACCESS_TYPE_NO_PROXY;
    info.lpszProxy := nil;
  end
  else begin
    info.dwAccessType := WINHTTP_ACCESS_TYPE_NAMED_PROXY;
    info.lpszProxy := proxy;
  end;
  info.lpszProxyBypass := nil;

  Result := WinHttpSetOption(Self.Handle, WINHTTP_OPTION_PROXY, @info, SizeOf(info));
end;

function TWinHttpSession.SetProxy(proxy: UnicodeString): Boolean;
begin
  Result := Self.SetProxy(PWideChar(proxy));
end;

procedure TWinHttpSession.SetTimeout(ResolvingTimeout, ConnectingTimeout, SendingTimeout, ReceivingTimeout: DWORD);
begin
  WinHttpSetTimeouts(FHandle, ResolvingTimeout, ConnectingTimeout,
    SendingTimeout, ReceivingTimeout);
end;

function TWinHttpSession.upload(url, referer: PWideChar; const FileDatas: array of TStream; const ParamNames,
  ParamValues, FileKeys, FileNames, MimeTypes: array of AnsiString; const charset: AnsiString): RawByteString;
var
  PostParam: TMemoryStream;
  boundary: RawByteString;
  ContentType: UnicodeString;
begin
  boundary := RandomAlphaDigitStringA(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(boundary, FileKeys, FileDatas, FileNames, MimeTypes, ParamNames, ParamValues, PostParam);

    PostParam.Position := 0;

    Result := Self.PostEx(url, referer, nil, 0, PostParam, PWideChar(ContentType));

  finally
    PostParam.Free;
  end;
end;

procedure TWinHttpSession.upload(url, referer: PWideChar; const FileDatas: array of TStream; const ParamNames,
  ParamValues, FileKeys, FileNames, MimeTypes: array of AnsiString; content: TStream; const charset: AnsiString);
var
  PostParam: TMemoryStream;
  boundary: RawByteString;
  ContentType: UnicodeString;
begin
  boundary := RandomAlphaDigitStringA(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;
  
  try
    HttpFillUploadStream(boundary, FileKeys, FileDatas, FileNames, MimeTypes, ParamNames, ParamValues, PostParam);

    PostParam.Position := 0;

    Self.PostEx(url, referer, nil, 0, PostParam, content, PWideChar(ContentType));
    
  finally
    PostParam.Free;
  end;
end;

function TWinHttpSession.UploadAndDecode(url, referer: PWideChar; const FileDatas: array of TStream;
  const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of AnsiString;
  const charset: AnsiString): UnicodeString;
var
  PostParam: TMemoryStream;
  boundary: RawByteString;
  ContentType: UnicodeString;
begin
  boundary := RandomAlphaDigitStringA(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(boundary, FileKeys, FileDatas, FileNames, MimeTypes, ParamNames, ParamValues, PostParam);

    PostParam.Position := 0;

    Result := Self.PostAndDecodeEx(url, referer, nil, 0, PostParam, PWideChar(ContentType));

  finally
    PostParam.Free;
  end;
end;

function TWinHttpSession.DoRequest(url, method, referer, RequestHeaders: PWideChar;
  param: Pointer; ParamLength: DWORD; ParamStream: TStream; pOptions: PTHttpRequestOptions;
  pLocation: PUnicodeString; _AutoDecompress: Boolean;
  _TimesErrorRetry, _SendingTimeout, _ReceivingTimeout: DWORD): RawByteString;
var
  scheme, host, username, password, PathWithParams: UnicodeString;
  port: Word;
  request: THttpRequest;
begin
  WinHttpParseURI(url, port, scheme, host, username, password, PathWithParams);

  request.init;

  if Assigned(pOptions) then
    request.options := pOptions^;

  request.schema := PWideChar(scheme);
  request.method := method;
  request.host := PWideChar(host);
  request.port := port;
  request.username := PWideChar(username);
  request.password := PWideChar(password);
  request.PathWithParams := PWideChar(PathWithParams);
  request.referer := referer;
  request.param := param;
  request.ParamLength := ParamLength;
  request.ParamStream := ParamStream;
  request.RequestHeaders := RequestHeaders;
  request.AutoDecompress := _AutoDecompress;
  request.SendingTimeout := _SendingTimeout;
  request.ReceivingTimeout := _ReceivingTimeout;
  Result := Self.DoRequest(request, _TimesErrorRetry, pLocation);
end;

function TWinHttpSession.DoRequest(const request: THttpRequest; pLocation: PUnicodeString): RawByteString;
var
  ResponseContent: TMemoryStream;
begin
  ResponseContent := TMemoryStream.Create;

  try
    Self.DoRequest(request, ResponseContent, pLocation);

    SetLength(Result, ResponseContent.Size);

    Move(ResponseContent.Memory^, Pointer(Result)^, Length(Result));
  finally
    ResponseContent.Free;
  end;
end;

procedure TWinHttpSession.DoRequest(url, method, referer, RequestHeaders: PWideChar;
  param: Pointer; ParamLength: DWORD; ParamStream, content: TStream;
  pOptions: PTHttpRequestOptions; pLocation: PUnicodeString;
  _AutoDecompress: Boolean; _TimesErrorRetry, _SendingTimeout, _ReceivingTimeout: DWORD);
var
  scheme, host, username, password, PathWithParams: UnicodeString;
  port: Word;
  request: THttpRequest;
begin
  WinHttpParseURI(url, port, scheme, host, username, password, PathWithParams);

  request.init;

  if Assigned(pOptions) then
    request.options := pOptions^;

  request.schema := PWideChar(scheme);
  request.method := method;
  request.host := PWideChar(host);
  request.port := port;
  request.username := PWideChar(username);
  request.password := PWideChar(password);
  request.PathWithParams := PWideChar(PathWithParams);
  request.referer := referer;
  request.param := param;
  request.ParamLength := ParamLength;
  request.ParamStream := ParamStream;
  request.RequestHeaders := RequestHeaders;
  request.AutoDecompress := _AutoDecompress;
  request.SendingTimeout := _SendingTimeout;
  request.ReceivingTimeout := _ReceivingTimeout;

  Self.DoRequest(request, content, _TimesErrorRetry, pLocation);
end;

function TWinHttpSession.DoRequestEx(const request: THttpRequest;
  out ResponseContent: RawByteString): HINTERNET;
var
  ResponseStream: TMemoryStream;
  ok: Boolean;
begin
  Result := nil;
  ok := False;
  ResponseStream := TMemoryStream.Create;

  try
    Result := Self.DoRequestEx(request, ResponseContent);

    SetLength(ResponseContent, ResponseStream.Size);

    Move(ResponseStream.Memory^, Pointer(ResponseContent)^, Length(ResponseContent));

    ok := True;
  finally
    if not ok then
      WinHttpCloseHandle(Result);

    ResponseStream.Free;
  end;
end;

function HTMLGetCharset(content: PAnsiChar; ContentLength: Integer; charset: PAnsiChar): Integer;
var
  ptr, P1, P2: PAnsiChar;
  L: Integer;
begin
  //<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
  ptr := content;
  charset[0] := #0;
  Result := 0;

  while ContentLength > 0 do
  begin
    P1 := StrPosA('<meta ', 6, ptr, ContentLength);

    if P1 = nil then Break;

    Inc(P1, 6);

    Dec(ContentLength, P1 - ptr);

    ptr := P1;

    P2 := StrPosA('charset=', 8, ptr, ContentLength);

    if P2 <> nil then
    begin
      Inc(P2, 8);

      L := 0;

      while not (P2^ in [#0, '''', '"']) do
      begin
        charset[L] := P2^;
        Inc(L);
        Inc(P2);
      end;

      charset[L] := #0;
      Result := L;
      Break;
    end;

  end;
end;

function XMLGetCharset(content: PAnsiChar; ContentLength: Integer; charset: PAnsiChar): Integer;
var
  ptr, P1, P2: PAnsiChar;
begin
  //<?xml version="1.0" encoding="ISO-8859-1"?>
  charset[0] := #0;
  Result := 0;

  P1 := StrPosA('<?xml ', 6, content, ContentLength);

  if P1 <> nil then
  begin
    Inc(P1, 6);

    Dec(ContentLength, P1 - content);

    P2 := StrPosA('?>', 2, P1, ContentLength);

    if P2 <> nil then
    begin
      ptr := StrPosA('encoding="', 10, P1, P2 - P1);

      if ptr = nil then Exit;

      Inc(ptr, 10);

      P1 := ptr;

      while (ptr < P2) and (ptr^ <> '"') do Inc(ptr);

      if ptr < P2 then
      begin
        while P1 < ptr do
        begin
          charset^ := P1^;
          Inc(charset);
          Inc(P1);
          Inc(Result);
        end;
      end;
    end;
  end;
end;


function TWinHttpSession.DoRequestAndDecode(const request: THttpRequest; TimesErrorRetry: DWORD;
  pLocation: PUnicodeString): UnicodeString;
var
  i: DWORD;
begin
  for i := 0 to TimesErrorRetry do
  begin
    try
      Result := Self.DoRequestAndDecode(request, pLocation);
      Break;
    except
      if i = TimesErrorRetry then
        raise;
    end;
  end;
end;

procedure TWinHttpSession.get(const url: UnicodeString; content: TStream; const referer: UnicodeString);
begin
  Self.DoRequest(PWideChar(url), S_GET, PWideChar(referer), PWideChar(DEFAULT_HTTP_HEADERS), nil, 0, nil, content);
end;

function TWinHttpSession.get(const url, referer: UnicodeString): RawByteString;
begin
  Result := Self.DoRequest(PWideChar(url), S_GET, PWideChar(referer), PWideChar(DEFAULT_HTTP_HEADERS), nil, 0, nil);
end;

function TWinHttpSession.GetAndDecode(url, referer: PWideChar): UnicodeString;
begin
  Result := Self.DoRequestAndDecode(url, S_GET, referer, PWideChar(DEFAULT_HTTP_HEADERS), nil, 0, nil);
end;

function TWinHttpSession.GetAndDecode(const url, referer: UnicodeString): UnicodeString;
begin
  Result := Self.DoRequestAndDecode(PWideChar(url), S_GET, PWideChar(referer), PWideChar(DEFAULT_HTTP_HEADERS), nil, 0, nil);
end;

function TWinHttpSession.GetWithoutRedirect(const url, referer: UnicodeString;
  pLocation: PUnicodeString): RawByteString;
begin
  Result := Self.DoRequest(PWideChar(url), S_GET, PWideChar(referer), PWideChar(DEFAULT_HTTP_HEADERS),
    nil, 0, nil, @NoRedirectOptions, pLocation);
end;

procedure TWinHttpSession.GetWithoutRedirect(const url: UnicodeString; content: TStream;
  const referer: UnicodeString; pLocation: PUnicodeString);
begin
  Self.DoRequest(PWideChar(url), S_GET, PWideChar(referer), PWideChar(DEFAULT_HTTP_HEADERS),
    nil, 0, nil, content, @NoRedirectOptions, pLocation);
end;

procedure TWinHttpSession.GetWithoutRedirect(url: PWideChar; content: TStream; referer: PWideChar;
  pLocation: PUnicodeString);
begin
  Self.DoRequest(url, S_GET, referer, PWideChar(DEFAULT_HTTP_HEADERS), nil, 0, nil, content,
    @NoRedirectOptions, pLocation);
end;

function TWinHttpSession.GetWithoutRedirect(url, referer: PWideChar; pLocation: PUnicodeString): RawByteString;
begin
  Result := Self.DoRequest(url, S_GET, referer, PWideChar(DEFAULT_HTTP_HEADERS), nil, 0, nil,
    @NoRedirectOptions, pLocation);
end;

function TWinHttpSession.GetWithoutRedirectAndDecode(const url, referer: UnicodeString;
  pLocation: PUnicodeString): UnicodeString;
begin
  Result := Self.DoRequestAndDecode(PWideChar(url), S_GET, PWideChar(referer), PWideChar(DEFAULT_HTTP_HEADERS),
    nil, 0, nil, @NoRedirectOptions, pLocation);
end;

function TWinHttpSession.GetWithoutRedirectAndDecode(url, referer: PWideChar;
  pLocation: PUnicodeString): UnicodeString;
begin
  Result := Self.DoRequestAndDecode(url, S_GET, referer, PWideChar(DEFAULT_HTTP_HEADERS),
    nil, 0, nil, @NoRedirectOptions, pLocation);
end;

function TWinHttpSession.post(const url, referer: UnicodeString; const param: RawByteString;
  const ParamType: UnicodeString): RawByteString;
begin
  Result := Self.PostEx(PWideChar(url), PWideChar(referer), Pointer(param), Length(param), nil, PWideChar(ParamType));
end;

procedure TWinHttpSession.post(const url, referer: UnicodeString; const param: RawByteString;
  content: TStream; const ParamType: UnicodeString);
begin
  Self.PostEx(PWideChar(url), PWideChar(referer), Pointer(param), Length(param), nil, PWideChar(ParamType));
end;

function TWinHttpSession.post(const url, referer: UnicodeString; param: TStream;
  const ParamType: UnicodeString): RawByteString;
begin
  Result := Self.PostEx(PWideChar(url), PWideChar(referer), nil, 0, param, PWideChar(ParamType));
end;

function TWinHttpSession.PostAndDecode(url, referer: PWideChar; param: TStream; ParamType: PWideChar): UnicodeString;
begin
  Result := Self.PostAndDecodeEx(url, referer, nil, 0, param, ParamType);
end;

function TWinHttpSession.PostAndDecode(url, referer: PWideChar; const param: RawByteString; ParamType: PWideChar): UnicodeString;
begin
  Result := Self.PostAndDecodeEx(url, referer, Pointer(param), Length(param), nil, ParamType);
end;

function TWinHttpSession.PostAndDecode(const url, referer: UnicodeString; param: TStream; const ParamType: UnicodeString): UnicodeString;
begin
  Result := Self.PostAndDecodeEx(PWideChar(url), PWideChar(referer), nil, 0, param, PWideChar(ParamType));
end;

function TWinHttpSession.PostAndDecodeEx(url, referer: PWideChar; param: Pointer; ParamLength: DWORD; ParamStream: TStream;
  ParamType: PWideChar; pOptions: PTHttpRequestOptions; pLocation: PUnicodeString): UnicodeString;
var
  RequestHeaders: PWideChar;
  _RequestHeaders: UnicodeString;
begin
  if ParamType <> '' then
  begin
    _RequestHeaders := UStrCatCStr([DEFAULT_HTTP_HEADERS, #13#10'Content-Type: '], ParamType);
    RequestHeaders := PWideChar(_RequestHeaders);
  end
  else RequestHeaders := PWideChar(DEFAULT_POST_HTTP_HEADERS);

  Result := Self.DoRequestAndDecode(url, S_POST, referer, RequestHeaders, param, ParamLength, ParamStream, pOptions, pLocation);
end;

function TWinHttpSession.PostAndDecode(const url, referer: UnicodeString; const param: RawByteString;
  const ParamType: UnicodeString): UnicodeString;
begin
  Result := Self.PostAndDecodeEx(PWideChar(url), PWideChar(referer), Pointer(param), Length(param), nil,
    PWideChar(ParamType));
end;

function TWinHttpSession.PostEx(url, referer: PWideChar; param: Pointer; ParamLength: DWORD; ParamStream: TStream;
  ParamType: PWideChar; pOptions: PTHttpRequestOptions; pLocation: PUnicodeString): RawByteString;
var
  RequestHeaders: PWideChar;
  _RequestHeaders: UnicodeString;
begin
  if ParamType <> '' then
  begin
    _RequestHeaders := UStrCatCStr([DEFAULT_HTTP_HEADERS, #13#10'Content-Type: '], ParamType);
    RequestHeaders := PWideChar(_RequestHeaders);
  end
  else RequestHeaders := PWideChar(DEFAULT_POST_HTTP_HEADERS);

  Result := Self.DoRequest(url, S_POST, referer, RequestHeaders, param, ParamLength,
    ParamStream, pOptions, pLocation);
end;

procedure TWinHttpSession.PostWithoutRedirect(url, referer: PWideChar; param, content: TStream; ParamType: PWideChar;
  pLoacation: PUnicodeString);
begin
  Self.PostEx(url, referer, nil, 0, param, ParamType, @NoRedirectOptions, pLoacation);
end;

function TWinHttpSession.PostWithoutRedirect(url, referer: PWideChar; param: TStream; ParamType: PWideChar;
  pLoacation: PUnicodeString): RawByteString;
begin
  Result := Self.PostEx(url, referer, nil, 0, param, ParamType, @NoRedirectOptions, pLoacation);
end;

procedure TWinHttpSession.PostWithoutRedirect(url, referer: PWideChar; const param: RawByteString; content: TStream;
  ParamType: PWideChar; pLoacation: PUnicodeString);
begin
  Self.PostEx(url, referer, Pointer(param), Length(param), nil, ParamType, @NoRedirectOptions, pLoacation);
end;

function TWinHttpSession.PostWithoutRedirect(url, referer: PWideChar; const param: RawByteString;
  ParamType: PWideChar; pLoacation: PUnicodeString): RawByteString;
begin
  Result := Self.PostEx(url, referer, Pointer(param), Length(param), nil, ParamType, @NoRedirectOptions, pLoacation);
end;

procedure TWinHttpSession.PostWithoutRedirect(const url, referer: UnicodeString; param, content: TStream;
  const ParamType: UnicodeString; pLoacation: PUnicodeString);
begin
  Self.PostEx(PWideChar(url), PWideChar(referer), nil, 0, param, PWideChar(ParamType), @NoRedirectOptions, pLoacation);
end;

function TWinHttpSession.PostWithoutRedirect(const url, referer: UnicodeString; param: TStream;
  const ParamType: UnicodeString; pLoacation: PUnicodeString): RawByteString;
begin
  Result := Self.PostEx(PWideChar(url), PWideChar(referer), nil, 0, param, PWideChar(ParamType), @NoRedirectOptions, pLoacation);
end;

function TWinHttpSession.PostWithoutRedirectAndDecode(url, referer: PWideChar; param: TStream; ParamType: PWideChar;
  pLoacation: PUnicodeString): UnicodeString;
begin
  Result := Self.PostAndDecodeEx(url, referer, nil, 0, param, ParamType, @NoRedirectOptions, pLoacation);
end;

function TWinHttpSession.PostWithoutRedirectAndDecode(url, referer: PWideChar; const param: RawByteString;
  ParamType: PWideChar; pLoacation: PUnicodeString): UnicodeString;
begin
  Result := Self.PostAndDecodeEx(url, referer, Pointer(param), Length(param), nil, ParamType, @NoRedirectOptions, pLoacation);
end;

function TWinHttpSession.PostWithoutRedirectAndDecode(const url, referer: UnicodeString; param: TStream;
  const ParamType: UnicodeString; pLoacation: PUnicodeString): UnicodeString;
begin
  Result := Self.PostAndDecodeEx(PWideChar(url), PWideChar(referer), nil, 0, param, PWideChar(ParamType), @NoRedirectOptions, pLoacation);
end;

function TWinHttpSession.PostWithoutRedirectAndDecode(const url, referer: UnicodeString; const param: RawByteString;
  const ParamType: UnicodeString; pLoacation: PUnicodeString): UnicodeString;
begin
  Result := Self.PostAndDecodeEx(PWideChar(url), PWideChar(referer), Pointer(param), Length(param), nil, PWideChar(ParamType), @NoRedirectOptions, pLoacation);
end;

procedure TWinHttpSession.PostWithoutRedirect(const url, referer: UnicodeString; const param: RawByteString;
  content: TStream; const ParamType: UnicodeString; pLoacation: PUnicodeString);
begin
  Self.PostEx(PWideChar(url), PWideChar(referer), Pointer(param), Length(param), nil, PWideChar(ParamType), @NoRedirectOptions, pLoacation);
end;

function TWinHttpSession.PostWithoutRedirect(const url, referer: UnicodeString; const param: RawByteString;
  const ParamType: UnicodeString; pLoacation: PUnicodeString): RawByteString;
begin
  Result := Self.PostEx(PWideChar(url), PWideChar(referer), Pointer(param), Length(param), nil, PWideChar(ParamType), @NoRedirectOptions, pLoacation);
end;

procedure TWinHttpSession.post(const url, referer: UnicodeString; param, content: TStream;
  const ParamType: UnicodeString);
begin
  Self.PostEx(PWideChar(url), PWideChar(referer), nil, 0, param, PWideChar(ParamType));
end;

function TWinHttpSession.get(url, referer: PWideChar): RawByteString;
begin
  Result := Self.DoRequest(url, S_GET, referer, PWideChar(DEFAULT_HTTP_HEADERS), nil, 0, nil);
end;

procedure TWinHttpSession.get(url: PWideChar; content: TStream; referer: PWideChar);
begin
  Self.DoRequest(url, S_GET, referer, PWideChar(DEFAULT_HTTP_HEADERS), nil, 0, nil, content);
end;

procedure TWinHttpSession.post(url, referer: PWideChar; const param: RawByteString;
  content: TStream; ParamType: PWideChar);
begin
  Self.PostEx(url, referer, Pointer(param), Length(param), nil, ParamType);
end;

function TWinHttpSession.post(url, referer: PWideChar; param: TStream; ParamType: PWideChar): RawByteString;
begin
  Result := Self.PostEx(url, referer, nil, 0, param, ParamType);
end;

function TWinHttpSession.post(url, referer: PWideChar; const param: RawByteString;
  ParamType: PWideChar): RawByteString;
begin
  Result := Self.PostEx(url, referer, Pointer(param), Length(param), nil, ParamType);
end;

procedure TWinHttpSession.post(url, referer: PWideChar; param, content: TStream; ParamType: PWideChar);
begin
  Self.DoRequest(url, S_POST, referer, nil, nil, 0, param, content);
  Self.PostEx(url, referer, nil, 0, param, ParamType);
end;

procedure TWinHttpSession.PostEx(url, referer: PWideChar; param: Pointer; ParamLength: DWORD;
  ParamStream, content: TStream; ParamType: PWideChar; pOptions: PTHttpRequestOptions;
  pLocation: PUnicodeString);
var
  RequestHeaders: PWideChar;
  _RequestHeaders: UnicodeString;
begin
  if ParamType <> '' then
  begin
    _RequestHeaders := UStrCatCStr(DEFAULT_HTTP_HEADERS, ParamType);
    RequestHeaders := PWideChar(_RequestHeaders);
  end
  else RequestHeaders := PWideChar(DEFAULT_POST_HTTP_HEADERS);
  
  Self.DoRequest(url, S_POST, referer, RequestHeaders, param, ParamLength, ParamStream, content,
    pOptions, pLocation);
end;

function TWinHttpSession.DoRequestEx(const request: THttpRequest;
  ResponseContent: TStream): HINTERNET;
var
  connection, RequestHandle: HINTERNET;
  TotalInputLength, rflags: DWORD;
  ok: Boolean;
begin
  Result := nil;
  ok := False;

  rflags := WINHTTP_FLAG_NULL_CODEPAGE;

  if request.options.PragmaNoCache then
    rflags := rflags or WINHTTP_FLAG_REFRESH;

  if StrCompareW(request.schema, 'https') = 0 then
    rflags := rflags or WINHTTP_FLAG_SECURE;

  if Assigned(request.ParamStream) then
    TotalInputLength := request.ParamLength + request.ParamStream.Size
  else
    TotalInputLength := request.ParamLength;

  connection := nil;
  RequestHandle := nil;

  try
    connection := WinHttpConnect(Self.FHandle, PWideChar(request.host), request.port, 0);

    if not Assigned(connection) then
      raise TWinHttpException.Create('WinHttpConnect', GetLastError);

    RequestHandle := WinHttpOpenRequest(connection, request.method,
      PWideChar(request.PathWithParams), 'HTTP/1.1',
      request.referer, WINHTTP_DEFAULT_ACCEPT_TYPES, rflags);

    if not Assigned(RequestHandle) then
      raise TWinHttpException.Create('WinHttpOpenRequest', GetLastError);

    if request.SendingTimeout <> 0 then
      WinHttpSetDWORDOption(RequestHandle, WINHTTP_OPTION_SENDING_TIMEOUT, request.SendingTimeout);

    if request.ReceivingTimeout <> 0 then
      WinHttpSetDWORDOption(RequestHandle, WINHTTP_OPTION_RECEIVE_TIMEOUT, request.ReceivingTimeout);

    if not request.options.AutoCookie then
      WinHttpSetDWORDOption(RequestHandle, WINHTTP_OPTION_DISABLE_FEATURE, WINHTTP_DISABLE_COOKIES);

    WinHttpSetDWORDOption(RequestHandle, WINHTTP_OPTION_SECURITY_FLAGS,
      SECURITY_FLAG_IGNORE_CERT_CN_INVALID or
      SECURITY_FLAG_IGNORE_CERT_DATE_INVALID or
      SECURITY_FLAG_IGNORE_UNKNOWN_CA or
      SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE);

    if not request.options.AutoRedirect then
      WinHttpSetDWORDOption(RequestHandle, WINHTTP_OPTION_DISABLE_FEATURE,
        WINHTTP_DISABLE_REDIRECTS);

    if not WinHttpSendRequest(RequestHandle, request.RequestHeaders, DWORD(-1),
      request.param, request.ParamLength, TotalInputLength, 0) then
      raise TWinHttpException.Create('WinHttpSendRequest', GetLastError);

    if Assigned(request.ParamStream) then
    begin
      request.ParamStream.Seek(0, soFromBeginning);
      WinHttpSendStream(RequestHandle, request.ParamStream);
    end;

    if not WinHttpReceiveResponse(RequestHandle, nil) then
      raise TWinHttpException.Create('WinHttpReceiveResponse', GetLastError);

    if Assigned(ResponseContent) then
      WinHttpReceiveStream(RequestHandle, ResponseContent, request.AutoDecompress);

    ok := True;

  finally
    if Assigned(RequestHandle) then
    begin
      if not ok then WinHttpCloseHandle(RequestHandle)
      else Result := RequestHandle;
    end;

    if Assigned(connection) then
      WinHttpCloseHandle(connection);
  end;
end;

procedure TWinHttpSession.DoRequest(const request: THttpRequest; ResponseContent: TStream;
  pLocation: PUnicodeString);
var
  hResponse: HINTERNET;
begin
  hResponse := Self.DoRequestEx(request, ResponseContent);

  try
    if Assigned(pLocation) then
      pLocation^ := WinHttpGetStringHeader(hResponse, WINHTTP_QUERY_LOCATION);
  finally
    WinHttpCloseHandle(hResponse);
  end;
end;

procedure TWinHttpSession.DoRequest(const request: THttpRequest; ResponseContent: TStream;
  TimesErrorRetry: DWORD; pLocation: PUnicodeString);
var
  i: DWORD;
begin
  for i := 0 to TimesErrorRetry do
  begin
    try
      Self.DoRequest(request, ResponseContent, pLocation);
      Break;
    except
      if i = TimesErrorRetry then
        raise;
    end;
  end;
end;

function TWinHttpSession.DoRequest(const request: THttpRequest; TimesErrorRetry: DWORD;
  pLocation: PUnicodeString): RawByteString;
var
  i: DWORD;
begin
  for i := 0 to TimesErrorRetry do
  begin
    try
      Result := Self.DoRequest(request, pLocation);
      Break;
    except
      if i = TimesErrorRetry then
        raise;
    end;
  end;
end;

function TWinHttpSession.DoRequestAndDecode(url, method, referer, RequestHeaders: PWideChar;
  param: Pointer; ParamLength: DWORD; ParamStream: TStream; pOptions: PTHttpRequestOptions;
  pLocation: PUnicodeString; _AutoDecompress: Boolean;
  _TimesErrorRetry, _SendingTimeout, _ReceivingTimeout: DWORD): UnicodeString;
var
  scheme, host, username, password, PathWithParams: UnicodeString;
  port: Word;
  request: THttpRequest;
begin
  WinHttpParseURI(url, port, scheme, host, username, password, PathWithParams);

  request.init;

  if Assigned(pOptions) then
    request.options := pOptions^;

  request.schema := PWideChar(scheme);
  request.method := method;
  request.host := PWideChar(host);
  request.port := port;
  request.username := PWideChar(username);
  request.password := PWideChar(password);
  request.PathWithParams := PWideChar(PathWithParams);
  request.referer := referer;
  request.param := param;
  request.ParamLength := ParamLength;
  request.ParamStream := ParamStream;
  request.RequestHeaders := RequestHeaders;
  request.AutoDecompress := _AutoDecompress;
  request.SendingTimeout := _SendingTimeout;
  request.ReceivingTimeout := _ReceivingTimeout;
  Result := Self.DoRequestAndDecode(request, _TimesErrorRetry, pLocation);
end;

function TWinHttpSession.DoRequestAndDecode(const request: THttpRequest;
  pLocation: PUnicodeString): UnicodeString;
const
  PWCCharsetTag: PWideChar = 'charset=';
  PWCContentTypeHTML: PWideChar = 'text/html';
  PWCContentTypeTextXml: PWideChar = 'text/xml';
  PWCContentTypeApplicationXml: PWideChar = 'application/xml';
var
  hRequest: HINTERNET;
  ContentType: array [0..128] of WideChar;
  hdrlen: Integer;
  ResponseContent: TMemoryStream;
  Codepage, i: Integer;
  charset: PWideChar;
  tmp: array [0..31] of AnsiChar;
begin
  hRequest := nil;
  ResponseContent := TMemoryStream.Create;

  try
    hRequest := Self.DoRequestEx(request, ResponseContent);

    if ResponseContent.Size = 0 then Result := ''
    else begin
      hdrlen := WinHttpGetStringHeader(hRequest, WINHTTP_QUERY_CONTENT_TYPE, ContentType);

      Codepage := CP_ACP;

      if hdrlen > 0 then
      begin
        charset := StrPosW(PWCCharsetTag, 8, ContentType, StrLenW(ContentType));

        if Assigned(charset) then
        begin
          Inc(charset, 8);

          i := 0;

          while charset^ <> #0 do
          begin
            tmp[i] := AnsiChar(charset^);
            Inc(i);
            Inc(charset);
          end;

          Codepage := CodePageName2ID(tmp, i);
        end
        else begin
          if IBeginWithW(PWCContentTypeHTML, ContentType) then
          begin
            HTMLGetCharset(PAnsiChar(ResponseContent.Memory), ResponseContent.Size, tmp);
            if tmp[0] <> #0 then Codepage := CodePageName2ID(tmp, StrLen(tmp));
          end
          else if IBeginWithW(PWCContentTypeTextXml, ContentType) or IBeginWithW(PWCContentTypeApplicationXml, ContentType) then
          begin
            XMLGetCharset(PAnsiChar(ResponseContent.Memory), ResponseContent.Size, tmp);
            if tmp[0] <> #0 then Codepage := CodePageName2ID(tmp, StrLen(tmp));
          end;
        end;
      end;

      Result := BufToUnicode(ResponseContent.Memory, ResponseContent.Size, Codepage);
    end;

    if Assigned(pLocation) then
      pLocation^ := WinHttpGetStringHeader(hRequest, WINHTTP_QUERY_LOCATION);
  finally
    if Assigned(hRequest) then WinHttpCloseHandle(hRequest);
    ResponseContent.Free;
  end;
end;

end.
