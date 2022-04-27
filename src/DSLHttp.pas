{$B-,C+,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,U-,V+,W-,X+,Z1}
{$O+}   // optimization on
{$T+}   // typed pointers on
{$POINTERMATH ON}

unit DSLHttp;

interface

uses
  SysUtils, Classes, Windows, DateUtils, SyncObjs, Generics.Collections, Generics.Defaults, Forms,
  DSLWinsock2, ZLibExApi, ZLibEx, DSLUtils, DSLHtml, DSLGenerics, DSLCrypto;

const
{$region 'http status codes'}
  HTTP_STATUS_CONTINUE = 100; {$EXTERNALSYM HTTP_STATUS_CONTINUE} // OK to continue with request
  HTTP_STATUS_SWITCH_PROTOCOLS = 101; {$EXTERNALSYM HTTP_STATUS_SWITCH_PROTOCOLS} // server has switched protocols in upgrade header

  HTTP_STATUS_OK = 200; {$EXTERNALSYM HTTP_STATUS_OK} // request completed
  HTTP_STATUS_CREATED = 201; {$EXTERNALSYM HTTP_STATUS_CREATED} // object created, reason = new URI
  HTTP_STATUS_ACCEPTED = 202; {$EXTERNALSYM HTTP_STATUS_ACCEPTED}  // async completion (TBS)
  HTTP_STATUS_PARTIAL = 203; {$EXTERNALSYM HTTP_STATUS_PARTIAL} // partial completion
  HTTP_STATUS_NO_CONTENT = 204; {$EXTERNALSYM HTTP_STATUS_NO_CONTENT} // no info to return
  HTTP_STATUS_RESET_CONTENT = 205; {$EXTERNALSYM HTTP_STATUS_RESET_CONTENT} // request completed, but clear form
  HTTP_STATUS_PARTIAL_CONTENT = 206; {$EXTERNALSYM HTTP_STATUS_PARTIAL_CONTENT} // partial GET fulfilled
  HTTP_STATUS_WEBDAV_MULTI_STATUS = 207; {$EXTERNALSYM HTTP_STATUS_WEBDAV_MULTI_STATUS} // WebDAV Multi-Status

  HTTP_STATUS_AMBIGUOUS = 300; {$EXTERNALSYM HTTP_STATUS_AMBIGUOUS} // server couldn't decide what to return
  HTTP_STATUS_MOVED = 301; {$EXTERNALSYM HTTP_STATUS_MOVED} // object permanently moved
  HTTP_STATUS_REDIRECT = 302; {$EXTERNALSYM HTTP_STATUS_REDIRECT} // object temporarily moved
  HTTP_STATUS_REDIRECT_METHOD = 303; {$EXTERNALSYM HTTP_STATUS_REDIRECT_METHOD} // redirection w/ new access method
  HTTP_STATUS_NOT_MODIFIED = 304; {$EXTERNALSYM HTTP_STATUS_NOT_MODIFIED} // if-modified-since was not modified
  HTTP_STATUS_USE_PROXY = 305; {$EXTERNALSYM HTTP_STATUS_USE_PROXY} // redirection to proxy, location header specifies proxy to use
  HTTP_STATUS_REDIRECT_KEEP_VERB = 307; {$EXTERNALSYM HTTP_STATUS_REDIRECT_KEEP_VERB} // HTTP/1.1: keep same verb

  HTTP_STATUS_BAD_REQUEST = 400; {$EXTERNALSYM HTTP_STATUS_BAD_REQUEST} // invalid syntax
  HTTP_STATUS_DENIED = 401; {$EXTERNALSYM HTTP_STATUS_DENIED} // access denied
  HTTP_STATUS_PAYMENT_REQ = 402; {$EXTERNALSYM HTTP_STATUS_PAYMENT_REQ} // payment required
  HTTP_STATUS_FORBIDDEN = 403; {$EXTERNALSYM HTTP_STATUS_FORBIDDEN} // request forbidden
  HTTP_STATUS_NOT_FOUND = 404; {$EXTERNALSYM HTTP_STATUS_NOT_FOUND} // object not found
  HTTP_STATUS_BAD_METHOD = 405; {$EXTERNALSYM HTTP_STATUS_BAD_METHOD} // method is not allowed
  HTTP_STATUS_NONE_ACCEPTABLE = 406; {$EXTERNALSYM HTTP_STATUS_NONE_ACCEPTABLE} // no response acceptable to client found
  HTTP_STATUS_PROXY_AUTH_REQ = 407; {$EXTERNALSYM HTTP_STATUS_PROXY_AUTH_REQ} // proxy authentication required
  HTTP_STATUS_REQUEST_TIMEOUT = 408; {$EXTERNALSYM HTTP_STATUS_REQUEST_TIMEOUT} // server timed out waiting for request
  HTTP_STATUS_CONFLICT = 409; {$EXTERNALSYM HTTP_STATUS_CONFLICT} // user should resubmit with more info
  HTTP_STATUS_GONE = 410; {$EXTERNALSYM HTTP_STATUS_GONE} // the resource is no longer available
  HTTP_STATUS_LENGTH_REQUIRED = 411; {$EXTERNALSYM HTTP_STATUS_LENGTH_REQUIRED} // the server refused to accept request w/o a length
  HTTP_STATUS_PRECOND_FAILED = 412; {$EXTERNALSYM HTTP_STATUS_PRECOND_FAILED} // precondition given in request failed
  HTTP_STATUS_REQUEST_TOO_LARGE = 413; {$EXTERNALSYM HTTP_STATUS_REQUEST_TOO_LARGE} // request entity was too large
  HTTP_STATUS_URI_TOO_LONG = 414; {$EXTERNALSYM HTTP_STATUS_URI_TOO_LONG} // request URI too long
  HTTP_STATUS_UNSUPPORTED_MEDIA = 415; {$EXTERNALSYM HTTP_STATUS_UNSUPPORTED_MEDIA} // unsupported media type
  HTTP_STATUS_RETRY_WITH = 449; {$EXTERNALSYM HTTP_STATUS_RETRY_WITH} // retry after doing the appropriate action.

  HTTP_STATUS_SERVER_ERROR = 500; {$EXTERNALSYM HTTP_STATUS_SERVER_ERROR} // internal server error
  HTTP_STATUS_NOT_SUPPORTED = 501; {$EXTERNALSYM HTTP_STATUS_NOT_SUPPORTED} // required not supported
  HTTP_STATUS_BAD_GATEWAY = 502; {$EXTERNALSYM HTTP_STATUS_BAD_GATEWAY} // error response received from gateway
  HTTP_STATUS_SERVICE_UNAVAIL = 503; {$EXTERNALSYM HTTP_STATUS_SERVICE_UNAVAIL} // temporarily overloaded
  HTTP_STATUS_GATEWAY_TIMEOUT = 504; {$EXTERNALSYM HTTP_STATUS_GATEWAY_TIMEOUT} // timed out waiting for gateway
  HTTP_STATUS_VERSION_NOT_SUP = 505; {$EXTERNALSYM HTTP_STATUS_VERSION_NOT_SUP} // HTTP version not supported

  HTTP_STATUS_FIRST = HTTP_STATUS_CONTINUE; {$EXTERNALSYM HTTP_STATUS_FIRST}
  HTTP_STATUS_LAST = HTTP_STATUS_VERSION_NOT_SUP; {$EXTERNALSYM HTTP_STATUS_LAST}
{$endregion}

  PORT_HTTP = 80;  {$EXTERNALSYM PORT_HTTP}
  PORT_HTTPS = 443; {$EXTERNALSYM PORT_HTTPS}

  MAX_REDIRECT = 10; {$EXTERNALSYM MAX_REDIRECT}
  HTTP_FAIL_RETRY_TIMES = 3; {$EXTERNALSYM HTTP_FAIL_RETRY_TIMES}
  HTTP_FAIL_RETRY_INTERVAL = 100; {$EXTERNALSYM HTTP_FAIL_RETRY_INTERVAL}

  USE_STACK_BUFFER = 0; {$EXTERNALSYM USE_STACK_BUFFER}

type
  THttpChar = WideChar;
  THttpString = UnicodeString;
  TUrlString = UnicodeString;
  PHttpString = PUnicodeString;
  PHttpChar = PWideChar;
  THttpCharSection = TWideCharSection;
  THttpStrings = TUnicodeStrings;
  THttpStringList = TUnicodeStringList;
  TWebBrowserFamily = (wbfInternetExplorer, wbfFirefox, wbfChrome);
var
  IE_USER_AGENT: THttpString = 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 3.0.4506.2152;'
    + ' .NET CLR 3.5.30729; .NET CLR 2.0.50727)';
  FIREFOX_WIN32_USER_AGENT: THttpString = 'Mozilla/5.0 (Windows NT 6.1; rv:45.0) Gecko/20100101 Firefox/45.0';
  CHROME_WIN32_USER_AGENT: THttpString = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36';

type
  THttpHeaderState = (hhsFirstLine, hhsInvalid, hhsCompleted, hhsKeyValues);
  THttpStep = (hrsConnect, hrsSendHeaders, hrsSendData, hrsReceiveHeaders, hrsReceiveData);
  THttpRequestStep = THttpStep;

  THttpProgressEvent = procedure(step: THttpStep; total, completed: DWORD; var cancel: Boolean) of object;
  THttpRequestProgressEvent = THttpProgressEvent;

  THttpErrorCode = (
    httpSuccess,
    httperrUnknown,
    httperrAborted,
    httpRtlException,
    httperrSysCallFail,
    httperrInvalidUrl,
    httperrDNSError,
    httperrCanNotConnect,
    httperrConnectionClosed,
    httperrInvalidCert,
    httperrSSLFailure,
    httperrTimeout,
    httperrInvalidHeaders,
    httperrInvalidResponse,
    httperrTooManyRedirects);

  THttpError = record
    code: THttpErrorCode;
    callee: string;
    internalErrorCode: Integer;
    msg: string;
    function isSuccess: Boolean; inline;
    function description: string;
    procedure init; inline;
    procedure reset; inline;
    procedure clear;
    procedure fromCommunicateError(step: THttpStep; comerr: TCommunicationError);
  end;
  PHttpError = ^THttpError;

  THttpResult = record
    CurrentStep: THttpStep;
    error: THttpError;
    procedure init;
    function isSuccess: Boolean; inline;
  end;
  PHttpResult = ^THttpResult;

  THttpContentEncoding = (encNone, encGzip, encDeflate);

function HttpCheckHostNameA(host: PAnsiChar; len: Integer): Boolean;
function HttpCheckHostNameW(host: PWideChar; len: Integer): Boolean;

function HttpParseURIA(url: PAnsiChar; out port: Word; out schema_begin, schema_end, host_begin, host_end, port_begin,
  port_end, username_begin, username_end, password_begin, password_end, path_begin, path_end: PAnsiChar): Boolean;

function HttpParseURIW(url: PWideChar; out port: Word; out schema_begin, schema_end, host_begin, host_end, port_begin,
  port_end, username_begin, username_end, password_begin, password_end, path_begin, path_end: PWideChar): Boolean;
  overload;

type
  EHttpUnknownError = class(Exception);

  EHttpException = class(Exception)
  private
    FError: THttpError;
  public
    constructor Create(const _error: THttpError; const _func: string); overload;
    constructor Create(const _error: THttpError; const _func: string; const msg: string); overload;
    property error: THttpError read FError write FError;
  end;

  THttpQueryString = class
  private
    FParams: TList<TPair<string, string>>;
  public
    constructor Create; overload;
    constructor Create(const queryString: string); overload;
    procedure parse(const queryString: string);
    destructor Destroy; override;
    function getParam(const name: string): string;
    property Params: TList<TPair<string, string>> read FParams;
  end;

  TCookie = class
  private
    next: TCookie;
  public
    name: THttpString;
    value: THttpString;
    expires: TDateTime;
    secure: Boolean;
  end;

  TCookieDomain = class
  private
    next: TCookieDomain;
    FCookieList: TCookie;
  public
    domain: THttpString;
    path: THttpString;
    destructor Destroy; override;
    function MatchHost(const host, path: THttpString): Boolean;
    function MatchHost2(host, path: PHttpChar): Boolean;
    function FindItem(const name: THttpString): TCookie;
    function getCookie(const name: THttpString): THttpString;
    function getCookies(https: Boolean): THttpString;
    function SetCookie(const name, value: THttpString; expires: TDateTime; secure: Boolean): TCookie;
    procedure SaveReadableCookies(strs: THttpStrings);
    procedure clear;
  end;

  TCookieManager = class(TRefCountedObject)
  private
    FDomainList: TCookieDomain;
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    function FindDomain(const domain, path: THttpString): TCookieDomain;
    function FindCookie(const host, path, name: THttpString): TCookie;
    function getCookie(const name: THttpString; const host: THttpString = ''; const path: THttpString = ''): THttpString;
    function getCookies(const host, path: THttpString; https: Boolean): THttpString;
    function getCookies2(host, path: PHttpChar; https: Boolean): THttpString;
    function ParseResponseCookie(const set_cookie, host: THttpString): TCookie;
    function SetCookie(const domain, path, name, value: THttpString; secure: Integer = 2;
      expires: TDateTime = 0): TCookie;
    procedure ParseRequestCookies(const domain, cookies: THttpString);
    procedure clear(const host: THttpString = ''; const path: THttpString = '');
    procedure SaveReadableCookies(strs: THttpStrings);
    procedure LoadReadableCookies(strs: THttpStrings);
    procedure SaveToFile(const fileName: string);
    procedure LoadFromFile(const fileName: string);
  end;

  EInvalidURI = class(Exception)
  private
    FUrl: THttpString;
  public
    constructor Create(_url: THttpString);
    property url: THttpString read FUrl;
  end;

  TUrl = record
  private
    function getSchema: THttpString;
    function getHost: THttpString;
    function getFileName: THttpString;
    function getPort: Word;
    function getPathWithParams: THttpString;
  public
    FSchema: THttpString;
    FHostName: THttpString;
    FPort: Word;
    FUsername: THttpString;
    FPassword: THttpString;
    FPathWithParams: THttpString;
    procedure parse(const value: THttpString);
    function SameExceptSchema(const other: TUrl): Boolean;
    function getUrl: THttpString;
    property schema: THttpString read GetSchema write FSchema;
    property HostName: THttpString read FHostName write FHostName;
    property port: Word read GetPort write FPort;
    property username: THttpString read FUsername write FUsername;
    property password: THttpString read FPassword write FPassword;
    property PathWithParams: THttpString read GetPathWithParams write FPathWithParams;
    property host: THttpString read GetHost;
    property FileName: THttpString read GetFileName;
  end;
  PUrl = ^TUrl;

  TReadonlyHeaders = record
  private
    FHeaders: RawByteString;
  public
    function all: RawByteString; inline;
    procedure reset(const _headers: RawByteString);
    function getS(const name: RawByteString): TAnsiCharSection;
    function getI(const name: RawByteString; default: Int64 = -1): Int64;
  end;

  THttpRequestLine = record
    method: RawByteString;
    pathWithParam: RawByteString;
    majorVersion: Byte;
    minorVersion: Byte;
    procedure init;
    function toString: RawByteString;
    function getPath: TAnsiCharSection;
    function getQueryParam(const name: RawByteString): RawByteString; inline;
    function parse(const line: TAnsiCharSection): Boolean; overload;
    function parse(const line: RawByteString): Boolean; overload;
  end;

  THttpRequestHeadersParser = record
    requestLine: THttpRequestLine;
    requestHeaders: TReadonlyHeaders;
    state: THttpHeaderState;
    _bufferdHeaders: RawByteString;
  private
    function _completeRequestLine(const s: TAnsiCharSection): Boolean; inline;
    procedure _completeKeyValues(const s: RawByteString); inline;
    function _combineRequestLine(const buf; bufLen: Integer): Integer;
    function _combineKeyValuesTail(const buf; bufLen: Integer): Integer;
    function _combineKeyValues(const buf; bufLen: Integer): Integer;
    procedure _addToBuffer(const buf; bufLen: Integer);
    function _parseRequestLine(const buf; bufLen: Integer): Integer;
    function _parseKeyValues(const buf; bufLen: Integer): Integer;
  public
    procedure init; inline;
    function feed(const buf; bufLen: Integer): Integer;
  end;
  PHttpRequestParser = ^THttpRequestHeadersParser;

  THttpHeader = record
  public
    name: THttpString;
    value: THttpString;
  end;

  THttpHeaderProc = function(param: Pointer; const header: THttpHeader): Boolean;

  THttpHeaders = class(TRefCountedObject)
  private
    FItems: TList<THttpHeader>;
    function find(const name: THttpString; var idx: Integer): THttpHeader;
    function getS(const name: THttpString): THttpString;
    procedure setS(const name, value: THttpString);
    function getI(const name: THttpString): Int64;
    procedure setI(const name: THttpString; const value: Int64);
    function getConnection: THttpString;
    function getContentLengthAsInt: Int64;
    function getContentType: THttpString;
    procedure setConnection(const value: THttpString);
    procedure setContentLengthAsInt(const value: Int64);
    procedure setContentType(const value: THttpString);
    function getAccept: THttpString;
    function getAcceptEncoding: THttpString;
    function getHost: THttpString;
    function getReferer: THttpString;
    function getUserAgent: THttpString;
    procedure setAccept(const value: THttpString);
    procedure setAcceptEncoding(const value: THttpString);
    procedure setHost(const value: THttpString);
    procedure setReferer(const value: THttpString);
    procedure setUserAgent(const value: THttpString);
    function getContentEncoding: THttpString;
    function getTransferEncoding: THttpString;
    procedure setContentEncoding(const value: THttpString);
    procedure setTransferEncoding(const value: THttpString);
    function getLocation: THttpString;
    procedure setLocation(const Value: THttpString);
    function getXRequestedWith: THttpString;
    procedure setXRequestedWith(const Value: THttpString);
    function getAcceptCharset: THttpString;
    function getAcceptLanguage: THttpString;
    procedure setAcceptCharset(const Value: THttpString);
    procedure setAcceptLanguage(const Value: THttpString);
    function getCookie: THttpString;
    procedure setCookie(const Value: THttpString);
    function getOrigin: THttpString;
    procedure setOrigin(const Value: THttpString);
    function getAuthorization: THttpString;
    procedure setAuthorization(const Value: THttpString);
    function getContentLength: THttpString;
    procedure setContentLength(const Value: THttpString);
  public
    constructor Create;
    destructor Destroy; override;
    procedure clear;
    function all: THttpString;
    procedure ParseOne(const s: TAnsiCharSection); overload;
    procedure ParseOne(const s: TWideCharSection); overload;
    function get(const name: THttpString): THttpString;
    function foreach(const name: THttpString; callback: THttpHeaderProc; param: Pointer): Boolean; overload;
    function foreach(callback: THttpHeaderProc; param: Pointer): Boolean; overload;
    procedure add(const name, value: THttpString);
    procedure remove(const name: THttpString);
    function exists(const name: THttpString): Boolean;
    property Items: TList<THttpHeader> read FItems;
    property S[const name: THttpString]: THttpString read GetS write SetS; default;
    property I[const name: THttpString]: Int64 read GetI write SetI;
    property ContentType: THttpString read GetContentType write SetContentType;
    property connection: THttpString read GetConnection write SetConnection;
    property ContentLength: THttpString read GetContentLength write SetContentLength;
    property ContentLengthAsInt: Int64 read GetContentLengthAsInt write SetContentLengthAsInt;
    property UserAgent: THttpString read GetUserAgent write SetUserAgent;
    property host: THttpString read GetHost write SetHost;
    property accept: THttpString read GetAccept write SetAccept;
    property AcceptEncoding: THttpString read GetAcceptEncoding write SetAcceptEncoding;
    property AcceptLanguage: THttpString read GetAcceptLanguage write SetAcceptLanguage;
    property AcceptCharset: THttpString read GetAcceptCharset write SetAcceptCharset;
    property referer: THttpString read GetReferer write SetReferer;
    property origin: THttpString read GetOrigin write SetOrigin;
    property ContentEncoding: THttpString read GetContentEncoding write SetContentEncoding;
    property TransferEncoding: THttpString read GetTransferEncoding write SetTransferEncoding;
    property location: THttpString read GetLocation write SetLocation;
    property XRequestedWith: THttpString read GetXRequestedWith write SetXRequestedWith;
    property cookie: THttpString read GetCookie write SetCookie;
    property authorization: THttpString read GetAuthorization write SetAuthorization;
  end;

  THttpRequestHeaders = class(THttpHeaders)
  public
    procedure parse(const s: TWideCharSection); overload;
    procedure parse(const s: TAnsiCharSection); overload;
  end;

  THttpResponseLine = record
    version: RawByteString;
    StatusCode: Integer;
    StatusText: RawByteString;
    function parse(const line: TAnsiCharSection): Boolean; overload;
    function parse(const line: TWideCharSection): Boolean; overload;
  end;

  THttpResponseHeaders = class(THttpHeaders)
  public
    ResponseLine: THttpResponseLine;
    procedure parse(const s: TWideCharSection); overload;
    procedure parse(const s: TAnsiCharSection); overload;
  end;

  TBaseHttpOptions = record
    ConnectTimeout: DWORD;
    SendTimeout: DWORD;
    RecvTimeout: DWORD;
    AutoDecompress: Boolean;
  end;

  (*
    常见的、几乎每个请求都会发送的请求头项
    列出来单独设置，可以省去创建 TBaseHttpRequest.FRequestHeaders 对象
  *)
  TFrequentlyUsedHttpRequestHeaders = record
    UserAgent: THttpString;
    referer: THttpString;
    origin: THttpString;
    ContentType: THttpString;
    cookie: THttpString;
    accept: THttpString;
    connection: THttpString;
    XRequestedWith: THttpString;
    AcceptEncoding: THttpString;
    AcceptLanguage: THttpString;
    AcceptCharset: THttpString;
  end;
  PFrequentlyUsedHttpRequestHeaders = ^TFrequentlyUsedHttpRequestHeaders;

const
  DefHeader: TFrequentlyUsedHttpRequestHeaders = ();

type
  TInternalHttpRequestHeaders = record
    ProxyAuthorization: THttpString;
    ProxyConnection: THttpString;
  end;
  PInternalHttpRequestHeaders = ^TInternalHttpRequestHeaders;

  TBaseHttpRequest = class(TRefCountedObject)
  private
    FMethod: THttpString;
    FRequestHeaders: THttpRequestHeaders;
    FResponseHeaders: THttpResponseHeaders;
    function getRequestHeaders: THttpRequestHeaders;
    function getResponseHeaders: THttpResponseHeaders;
  public
    url: TUrl;
    param: Pointer;
    ParamLength: Integer;
    ParamStream: TStream;
    constructor Create;
    destructor Destroy; override;
    procedure ClearResponseHeaders;
    function MakeRequestHeader(const headers: TFrequentlyUsedHttpRequestHeaders; IncludeRequestLine: Boolean;
      pInternalHeaders: PInternalHttpRequestHeaders = nil): THttpString;
    property method: THttpString read FMethod write FMethod;
    property RequestHeaders: THttpRequestHeaders read GetRequestHeaders;
    property ResponseHeaders: THttpResponseHeaders read GetResponseHeaders;
  end;

  THttpOptions = record
    AutoCookie: Boolean;
    AutoRedirect: Boolean;
    AutoSchemaSwitching: Boolean;
  end;
  PHttpOptions = ^THttpOptions;

  THttpRequest = class(TBaseHttpRequest)
  private
    FRedirctRequests: TObjectListEx<TBaseHttpRequest>;
    function getRedirctRequests: TObjectListEx<TBaseHttpRequest>;
  public
    options: THttpOptions;
    headers: TFrequentlyUsedHttpRequestHeaders;
    constructor Create;
    destructor Destroy; override;
    function getLatestRequest: TBaseHttpRequest;
    procedure ClearRedirects;
    function RedirectOcuured: Boolean;
    property RedirctRequests: TObjectListEx<TBaseHttpRequest> read GetRedirctRequests;
  end;

  TCustomHttpSession = class;

  THttpProxy = record
    HostName: RawByteString;
    port: Word;
    username: RawByteString;
    password: RawByteString;
    bypass: RawByteString;
  end;

  TCustomHttpConnection = class(TRefCountedObject)
  private
    FHostName: THttpString;
    FPort: Word;
    FProxy: THttpProxy;
    FIsHttps: Boolean;
  public
    LatestUse: DWORD;
    constructor Create(const _HostName: THttpString; _port: Word; const _proxy: THttpProxy; _IsHttps: Boolean);
    function match(const _HostName: THttpString; _port: Word; const _proxy: THttpProxy; _IsHttps: Boolean): Boolean;
  end;

  TCustomHttpIOHandler = class
  private
    FStep: THttpStep;
    FRequest: TBaseHttpRequest;
    FContentStream: TStream;
    FContentEncoding: THttpContentEncoding;
    FChunked: Boolean;
    FTotalRead: Int64;
    FAlreadyRead: Int64;
    FTotalWrite: Int64;
    FAlreadyWrite: Int64;
    FIOBufferSize: Integer;
    FIOBuffer: Pointer;
    FStaticIOBuffer: array [0..10240-1] of Byte;
    FIOBufferBytesRead: Integer;
    FIOBufferUsed: Integer;
    FRequestBeginAt: DWORD;
  protected
    FConnection: TCustomHttpConnection;
    FProxy: THttpProxy;
  private
  (********************************* read response headers **************************************)
    FResponseLineGot: Boolean;
    FResponseHeadersHot: Boolean;
    FRespHeaderBuf: array [0 .. 1023] of AnsiChar;
    FRespHdrBufLen: Integer;
    FInternalHeaders: TInternalHttpRequestHeaders;
    function ParseHeaderLine(buf: PAnsiChar; len: TSizeType): Boolean;
    procedure BufferHeaderLine(buf: PAnsiChar; len: Integer);
    function ParseHeader(buf: PAnsiChar; len: Integer): Integer;
    procedure CompleteHeader;
    procedure _ReadHeaders(var httperr: THttpError);
  private
    (********************************* parse chunked data **************************************)
    FChunkHeader: AnsiChar;
    FCurChunkSize: Integer;
    FReceivedChunkSize: Integer;
    FF: Integer;
    function ParseChunkSize(buf: PAnsiChar; len: Integer): Integer;
  protected
    function _ParseChunked(buf: PAnsiChar; len: Integer): Integer;
(********************************* read response content **************************************)
    procedure _ReadBody(target: TStream; var httperr: THttpError);
    procedure CompleteResponseBody;
    function WriteContent(buf: PAnsiChar; len: Integer): Integer;
    procedure connected;
    procedure HeaderSent;
    procedure DataSent;
    procedure HeaderRecved;
    procedure DataRecved;
  private
    procedure _WriteHeaders(var httperr: THttpError);
  protected
    FBaseOptions: TBaseHttpOptions;
    FCallback: THttpProgressEvent;
    FFrequentlyUsedHeaders: TFrequentlyUsedHttpRequestHeaders;
    isFirstByte: Boolean;
    zlibInited: Boolean;
    zlibStrm: TZStreamRec;
    function write(const buf; BufLen: Integer; var comerr: TCommunicationError): Integer; virtual; abstract;
    function read(var buf; BufLen: Integer; var comerr: TCommunicationError): Integer; virtual; abstract;
    procedure SendHeaders(var httperr: THttpError); virtual;
    procedure RecevieHeaders(var httperr: THttpError); virtual;
    function ParseChunked(buf: PAnsiChar; len: Integer): Integer; virtual;
    procedure KeepConnection; virtual; abstract;
  public
    constructor Create(_request: TBaseHttpRequest; const _BaseOptions: TBaseHttpOptions;
      const _headers: TFrequentlyUsedHttpRequestHeaders;
      const _proxy: THttpProxy; _callback: THttpProgressEvent);

    destructor Destroy; override;
    procedure connect(var comerr: TCommunicationError); virtual; abstract;
    procedure WriteBuffer(const buf; BufSize: Integer; var httperr: THttpError);
    procedure WriteStream(stream: TStream; var httperr: THttpError);
    procedure WriteHeaders(var httperr: THttpError);
    procedure WriteBody(var httperr: THttpError);
    procedure ReadHeaders(var httperr: THttpError);
    procedure ReadBody(target: TStream; var httperr: THttpError);
    property request: TBaseHttpRequest read FRequest;
    property connection: TCustomHttpConnection read FConnection;
    property step: THttpStep read FStep;
  end;

  TNetworkHost = class(TRefCountedObject)
  private
    FLockState: Integer;
    FTripTimeRemainder: DWORD;
  public
    DisplayName: string;
    HostName: THttpString;
    port: Word;
    priority: Integer;
    LatestAccessTime: DWORD;
    AccessTimes: DWORD;
    EverageTripTime: DWORD;
    LatestFailureTime: DWORD;
    IsLatestFailure: Boolean;
    nContiguousFailure: DWORD;
    function getDisplayName: string;
    function NeverUsed: Boolean;
    function getHost: THttpString;
    procedure lock;
    procedure unlock;
    procedure SaveAccess(TripTime: DWORD);
    procedure SaveFailure;
  end;

  TNetworkHostComparer = class(TInterfacedObject, IComparer<TNetworkHost>)
  protected
    function Compare(const Left, Right: TNetworkHost): Integer;
  end;

  TMultiHostManager = class(TRefCountedObject)
  private
    FHostList: TObjectListEx<TNetworkHost>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddServerHost(const hostname: THttpString; port: Word); overload;
    procedure AddServerHost(const host: THttpString); overload;
    procedure clearHosts;
    procedure AddServerHosts(const hosts: string; delimiter: char = ',');
    function IndexOfHost(const hostname: THttpString; port: Word): Integer;
    function OptimizeServerHosts: TObjectListEx<TNetworkHost>;
    function DoRequest(HttpClient: TCustomHttpSession; request: THttpRequest; content: TStream): UnicodeString;
    function FetchRawBytes(HttpClient: TCustomHttpSession; request: THttpRequest): RawByteString;
    property HostList: TObjectListEx<TNetworkHost> read FHostList;
  end;

  TCustomHttpSession = class(TRefCountedObject)
  private
    FUserAgent: THttpString;
    FCookieManager: TCookieManager;
    FAsync: Boolean;

    function _SendRequestAndReadHeaders(request: TBaseHttpRequest;
      const headers: TFrequentlyUsedHttpRequestHeaders;
      const BaseOptions: TBaseHttpOptions;
      callback: THttpProgressEvent;
      var IOHandler: TCustomHttpIOHandler): THttpResult;

    function SendRequestAndReadHeaders(request: TBaseHttpRequest;
      const headers: TFrequentlyUsedHttpRequestHeaders;
      const BaseOptions: TBaseHttpOptions;
      TimesErrorRetry: Integer;
      callback: THttpProgressEvent;
      var IOHandler: TCustomHttpIOHandler): THttpResult;
    procedure setCookieManager(const Value: TCookieManager);
  protected
    FProxy: THttpProxy;
    (* 此函数不处理重定向、schema切换 *)
    function _DoRawRequest(request: TBaseHttpRequest; const headers: TFrequentlyUsedHttpRequestHeaders;
      const options: TBaseHttpOptions; ResponseContent: TStream;
      TimesErrorRetry: Integer = 0;
      callback: THttpProgressEvent = nil;
      AutoCookie: Boolean = True): THttpResult;

    (* 此函数根据请求选项处理重定向、schema切换 *)
    function _DoRequest(request: THttpRequest; const options: TBaseHttpOptions; ResponseContent: TStream;
      TimesErrorRetry: Integer = 0; callback: THttpProgressEvent = nil): THttpResult;

    function CreateIOHandler(_request: TBaseHttpRequest; const _BaseOptions: TBaseHttpOptions;
      const _headers: TFrequentlyUsedHttpRequestHeaders; const _proxy: THttpProxy;
      _callback: THttpProgressEvent): TCustomHttpIOHandler; virtual; abstract;
  public
    constructor Create(_UserAgent: THttpString = ''; _CookieManager: TCookieManager = nil); overload;
    destructor Destroy; override;
    function getProxy: THttpProxy;
    procedure setProxy(const proxy: THttpProxy); overload;

    procedure setProxy(const HostName: RawByteString; port: Word;
      const username: RawByteString = '';
      const password: RawByteString = '';
      bypass: RawByteString = ''); overload;

    procedure ParseSetCookie(const SetCookie, host: THttpString);

    (* 此函数不处理重定向、schema切换 *)
    function DoRawRequest(request: TBaseHttpRequest; const headers: TFrequentlyUsedHttpRequestHeaders;
      const options: TBaseHttpOptions; ResponseContent: TStream;
      TimesErrorRetry: Integer = 0;
      callback: THttpProgressEvent = nil;
      AutoCookie: Boolean = True): THttpResult;

    (* 此函数根据请求选项处理重定向、schema切换 *)
    function DoRequest(
      request: THttpRequest;
      const options: TBaseHttpOptions;
      ResponseContent: TStream;
      TimesErrorRetry: Integer = 0;
      callback: THttpProgressEvent = nil): THttpResult; virtual;

    function DoRequest_AutoThread(request: THttpRequest; const options: TBaseHttpOptions; ResponseContent: TStream;
      TimesErrorRetry: Integer = 0;
      pLocation : PHttpString = nil;
      callback: THttpProgressEvent = nil): THttpResult;

    function FetchRawBytes(request: THttpRequest; const options: TBaseHttpOptions;
      TimesErrorRetry: Integer = 0;
      pLocation : PHttpString = nil;
      callback: THttpProgressEvent = nil): RawByteString;

    function FetchUnicodeString(request: THttpRequest; const options: TBaseHttpOptions;
      TimesErrorRetry: Integer = 0; pLocation : PHttpString = nil;
      callback: THttpProgressEvent = nil): UnicodeString;

    function DoUrl(const url, method: THttpString;
      const headers: TFrequentlyUsedHttpRequestHeaders;
      const param: RawByteString = '';
      ParamStream: TStream = nil;
      content: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _AutoDecompress: Boolean = True;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): THttpResult; overload;

    function DoUrl(const url, method, referer: THttpString;
      const headers: THttpString = '';
      const ContentType: THttpString = '';
      param: Pointer = nil;
      ParamLength: DWORD = 0;
      ParamStream: TStream = nil;
      content: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _AutoDecompress: Boolean = True;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): THttpResult; overload;

    function DoUrl_RawBytes(const url, method: THttpString;
      const headers: TFrequentlyUsedHttpRequestHeaders;
      const param: RawByteString = '';
      ParamStream: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _AutoDecompress: Boolean = True;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): RawByteString; overload;

    function DoUrl_RawBytes(const url, method, referer: THttpString;
      const headers: THttpString = '';
      const ContentType: THttpString = '';
      param: Pointer = nil;
      ParamLength: DWORD = 0;
      ParamStream: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _AutoDecompress: Boolean = True;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): RawByteString; overload;

    function DoUrlAndDecode(const url, method: THttpString;
      const headers: TFrequentlyUsedHttpRequestHeaders;
      const param: RawByteString = '';
      ParamStream: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): UnicodeString; overload;

    function DoUrlAndDecode(const url, method, referer: THttpString;
      const headers: THttpString = '';
      const ContentType: THttpString = '';
      param: Pointer = nil;
      ParamLength: DWORD = 0;
      ParamStream: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): UnicodeString; overload;

(******************************************************************************)
    function DoPath(mhm: TMultiHostManager;
      const path: THttpString;
      const method: THttpString = 'GET';
      const param: RawByteString = '';
      const schema: THttpString = 'http';
      pHeaders: PFrequentlyUsedHttpRequestHeaders = nil;
      ParamStream: TStream = nil;
      content: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _AutoDecompress: Boolean = True;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): THttpResult; overload;

    function DoPath(mhm: TMultiHostManager;
      const path: THttpString;
      const method: THttpString = 'GET';
      const schema: THttpString = 'http';
      const referer: THttpString = '';
      const headers: THttpString = '';
      const ContentType: THttpString = '';
      param: Pointer = nil;
      ParamLength: DWORD = 0;
      ParamStream: TStream = nil;
      content: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _AutoDecompress: Boolean = True;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): THttpResult; overload;

    function DoPath_RawBytes(mhm: TMultiHostManager;
      const path: THttpString;
      const method: THttpString = 'GET';
      const param: RawByteString = '';
      const schema: THttpString = 'http';
      pHeaders: PFrequentlyUsedHttpRequestHeaders = nil;
      ParamStream: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _AutoDecompress: Boolean = True;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): RawByteString; overload;

    function DoPath_RawBytes(mhm: TMultiHostManager;
      const path: THttpString;
      const method: THttpString = 'GET';
      const schema: THttpString = 'http';
      const referer: THttpString = '';
      const headers: THttpString = '';
      const ContentType: THttpString = '';
      param: Pointer = nil;
      ParamLength: DWORD = 0;
      ParamStream: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _AutoDecompress: Boolean = True;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): RawByteString; overload;

    function DoPathAndDecode(mhm: TMultiHostManager;
      const path: THttpString;
      const method: THttpString = 'GET';
      const param: RawByteString = '';
      const schema: THttpString = 'http';
      pHeaders: PFrequentlyUsedHttpRequestHeaders = nil;
      ParamStream: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): UnicodeString; overload;

    function getAndDecode(mhm: TMultiHostManager;
      const path: THttpString;
      const schema: THttpString = 'http';
      pHeaders: PFrequentlyUsedHttpRequestHeaders = nil;
      ParamStream: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): UnicodeString; overload;

    function DoPathAndDecode(mhm: TMultiHostManager;
      const path: THttpString;
      const method: THttpString = 'GET';
      const schema: THttpString = 'http';
      const referer: THttpString = '';
      const headers: THttpString = '';
      const ContentType: THttpString = '';
      param: Pointer = nil;
      ParamLength: DWORD = 0;
      ParamStream: TStream = nil;
      pOptions: PHttpOptions = nil;
      pLocation: PHttpString = nil;
      _TimesErrorRetry: Integer = 0;
      _ConnectTimeout: DWORD = 0;
      _SendTimeout: DWORD = 0;
      _RecvTimeout: DWORD = 0;
      callback: THttpProgressEvent = nil): UnicodeString; overload;

(******************************************************************************)

    procedure get(const url: THttpString; content: TStream; const referer: THttpString = '';
      pCurrentLocation: PHttpString = nil); overload;

    function get(const url: THttpString; const referer: THttpString = '';
      pCurrentLocation: PHttpString = nil): RawByteString; overload;

    function getAndDecode(const url: THttpString; const referer: THttpString = '';
      pCurrentLocation: PHttpString = nil): UnicodeString; overload;

    procedure GetWithoutRedirect(const url: THttpString; content: TStream; const referer: THttpString = '';
      pRedir: PHttpString = nil); overload;

    function getWithoutRedirect(const url: THttpString; const referer: THttpString = '';
      pRedir: PHttpString = nil): RawByteString; overload;

    function getWithoutRedirectAndDecode(const url: THttpString; const referer: THttpString = '';
      pRedir: PHttpString = nil): UnicodeString; overload;

    procedure post(const url, referer: THttpString; const param: RawByteString; content: TStream;
      const ParamType: THttpString = ''; pCurrentLocation: PHttpString = nil); overload;

    function post(const url, referer: THttpString; const param: RawByteString; const ParamType: THttpString = '';
      pCurrentLocation: PHttpString = nil): RawByteString; overload;

    procedure post(const url, referer: THttpString; param, content: TStream; const ParamType: THttpString = '';
      pCurrentLocation: PHttpString = nil); overload;

    function post(const url, referer: THttpString; param: TStream; const ParamType: THttpString = '';
      pCurrentLocation: PHttpString = nil): RawByteString; overload;

    procedure PostWithoutRedirect(const url, referer: THttpString; const param: RawByteString; content: TStream;
      const ParamType: THttpString = ''; pLocation: PHttpString = nil); overload;

    function PostWithoutRedirect(const url, referer: THttpString; const param: RawByteString;
      const ParamType: THttpString = ''; pLocation: PHttpString = nil): RawByteString; overload;

    procedure PostWithoutRedirect(const url, referer: THttpString; param, content: TStream;
      const ParamType: THttpString = ''; pLocation: PHttpString = nil); overload;

    function PostWithoutRedirect(const url, referer: THttpString; param: TStream;
      const ParamType: THttpString = ''; pLocation: PHttpString = nil): RawByteString; overload;

    function PostAndDecode(const url, referer: THttpString; const param: RawByteString; const ParamType: THttpString = '';
      pCurrentLocation: PHttpString = nil): UnicodeString; overload;

    function PostAndDecode(const url, referer: THttpString; param: TStream; const ParamType: THttpString = '';
      pCurrentLocation: PHttpString = nil): UnicodeString; overload;

    function PostWithoutRedirectAndDecode(const url, referer: THttpString; const param: RawByteString;
      const ParamType: THttpString = ''; pLocation: PHttpString = nil): UnicodeString; overload;

    function PostWithoutRedirectAndDecode(const url, referer: THttpString; param: TStream;
      const ParamType: THttpString = ''; pLocation: PHttpString = nil): UnicodeString; overload;

    function upload(const url, referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of RawByteString;
      FileDatas: array of TStream; const charset: THttpString = ''): RawByteString; overload;

    function UploadWithoutRedirect(const url, referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of RawByteString;
      FileDatas: array of TStream; const charset: THttpString = ''; pLocation: PHttpString = nil): RawByteString; overload;

    function upload2(const url, referer: THttpString; ParamNames, ParamValues: TRawByteStrings; const FileKeys, FileNames, MimeTypes: array of RawByteString;
      const FileDatas: array of TStream; const charset: THttpString = ''): RawByteString;

    function UploadWithoutRedirect2(const url, referer: THttpString; ParamNames, ParamValues: TRawByteStrings; const FileKeys, FileNames, MimeTypes: array of RawByteString;
      const FileDatas: array of TStream; const charset: THttpString = ''; pLocation: PHttpString = nil): RawByteString;

    procedure upload(const url, referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of RawByteString;
      const FileDatas: array of TStream; content: TStream; const charset: THttpString = ''); overload;

    procedure UploadWithoutRedirect(const url, referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of RawByteString;
      const FileDatas: array of TStream; content: TStream; const charset: THttpString = ''; pLocation: PHttpString = nil); overload;

    function UploadAndDecode(const url, referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of RawByteString;
      const FileDatas: array of TStream; const charset: THttpString = '';
      callback: THttpProgressEvent = nil): UnicodeString;

    function UploadWithoutRedirectAndDecode(const url, referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of RawByteString;
      const FileDatas: array of TStream; const charset: THttpString = ''; pLocation: PHttpString = nil): UnicodeString;

    function UploadAndDecode2(const url, referer: THttpString; ParamNames, ParamValues: TRawByteStrings; const FileKeys, FileNames, MimeTypes: array of RawByteString;
      const FileDatas: array of TStream; const charset: THttpString = ''): UnicodeString;

    function UploadWithoutRedirectAndDecode2(const url, referer: THttpString; ParamNames, ParamValues: TRawByteStrings; const FileKeys, FileNames, MimeTypes: array of RawByteString;
      const FileDatas: array of TStream; const charset: THttpString = ''; pLocation: PHttpString = nil): UnicodeString;

    property UserAgent: THttpString read FUserAgent;
    property CookieManager: TCookieManager read FCookieManager write SetCookieManager;
    property Async: Boolean read FAsync write FAsync;
  end;

  EHttpTimeout = class(Exception);
  EHttpErrorResponse = class(Exception);

function isParentDomain(child: PWideChar; childLen: Integer; parent: PWideChar; parentLen: Integer): Boolean; overload;
function isParentDomain(const child, parent: UnicodeString): Boolean; overload;
function isParentDomain(child: PAnsiChar; childLen: Integer; parent: PAnsiChar; parentLen: Integer): Boolean; overload;
function isParentDomain(const child, parent: RawByteString): Boolean; overload;

procedure HttpFillUploadStream(const boundary: RawByteString; const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of RawByteString;
  const FileDatas: array of TStream; PostParam: TStream); overload;

procedure HttpFillUploadStream(const boundary: RawByteString; ParamNames, ParamValues: TRawByteStrings;
  const FileKeys, FileNames, MimeTypes: array of RawByteString;
  const FileDatas: array of TStream; PostParam: TStream); overload;

procedure setHttpLogFileName(const FileName: string);
procedure setHttpLogResponseDir(const path: string);
procedure HttpLogCloseFile;

function WinHttpDecodeResponseText(request: TBaseHttpRequest; ResponseContent: TStream; ContentLength: Integer;
  out CodePage: Integer): UnicodeString;

function GetUrlExt(const url: string): string;

var
  g_DbgOutputRedirect: Boolean;
  g_LogHttp: Boolean;
  g_LogHttpDecodeFail: Boolean;
  g_LogHttpMaxContentLength: DWORD = 512;
  g_LogFilterHosts: THttpStrings;
  g_LogHttpResponseToSingleFile: Boolean;
  g_DbgOutputRequestTime: Boolean;
  g_NetworkHostComparer: IComparer<TNetworkHost>;
  g_DefaultConnectTimeout: DWORD = 0;
  g_DefaultSendTimeout: DWORD = 0;
  g_DefaultRecvTimeout: DWORD = 0;
  g_HttpKeepAlive: Boolean = False;
  g_BaseHttpOptions: TBaseHttpOptions =
    (ConnectTimeout: 0; SendTimeout: 0; RecvTimeout: 0; AutoDecompress: True);

implementation

const
  INVALID_LENGTH: TSizeType = TSizeType(-1);
  g_NoRedirectOptions: THttpOptions = (AutoCookie: True; AutoRedirect: False; AutoSchemaSwitching: True);

var
  HttpLogFileName: string;
  HttpLogResponseDir: string;
  HttpLogCS: TCriticalSection;
  HttpLogStream: TFileStream;

const
  SLineEnd: array [0..2] of AnsiChar = (#13, #10, #0);
  SHeadersEnd: array [0..4] of AnsiChar = (#13, #10, #13, #10, #0);

var
  g_lineEnd: TAnsiCharSection;
  g_headersEnd: TAnsiCharSection;

function GetUrlExt(const url: string): string;
var
  P, L: Integer;
begin
  Result := '';
  L := Pos('?', url);
  if L <= 0 then
    L := Length(url) + 1;
  P := L;
  while P > 2 do
  begin
    case url[P - 1] of
      '/':
        Break;
      '.':
        begin
          Result := Copy(url, P, L - P);
          Break;
        end;
    else
      Dec(P);
    end;
  end;
end;

function CheckLogFilter(request: TBaseHttpRequest): Boolean;
var
  i: Integer;
  tmp: THttpString;
begin
  if g_LogFilterHosts.Count = 0 then
  begin
    Result := True;
    Exit;
  end;

  Result := False;

  for i := 0 to g_LogFilterHosts.Count - 1 do
  begin
    tmp := g_LogFilterHosts[i];

    if UStrEndWith(request.url.host, tmp) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure setHttpLogResponseDir(const path: string);
begin
  ForceDirectories(path);
  HttpLogResponseDir := path;
end;

procedure setHttpLogFileName(const FileName: string);
begin
  SafeForceDirectories(ExtractFilePath(FileName));

  HttpLogCS.Enter;

  try
    if Assigned(HttpLogStream) then
      FreeAndNil(HttpLogStream);

    HttpLogFileName := FileName;
  finally
    HttpLogCS.Leave;
  end;
end;

function LockHttpLog: Boolean;
var
  DefLogPath: string;
begin
  Result := False;

  HttpLogCS.Enter;

  if Assigned(HttpLogStream) then
  begin
    Result := True;
    Exit;
  end;

  try
    if HttpLogFileName = '' then
    begin
      DefLogPath := ExtractFilePath(ParamStr(0)) + '\logs\http\';
      ForceDirectories(DefLogPath);
      HttpLogFileName := DefLogPath + 'http.log';
    end;

    if FileExists(HttpLogFileName) then
    begin
      HttpLogStream := TFileStream.Create(HttpLogFileName, fmOpenWrite or fmShareDenyWrite);
      HttpLogStream.Seek(0, soFromEnd);
    end
    else
      HttpLogStream := TFileStream.Create(HttpLogFileName, fmCreate or fmShareDenyWrite);

    Result := True;
  except
    on e: Exception do
    begin
      DbgOutputException('LockHttpLog', e);
      HttpLogCS.Leave;
    end;
  end;
end;

procedure UnLockHttpLog;
begin
  HttpLogCS.Leave;
end;

procedure HttpLogCloseFile;
begin
  HttpLogCS.Enter;

  try
    if Assigned(HttpLogStream) then
      FreeAndNil(HttpLogStream);

  finally
    HttpLogCS.Leave;
  end;
end;

function HttpCheckHostNameA(host: PAnsiChar; len: Integer): Boolean;
begin
  Result := len > 0;
  // not implemented
end;

function HttpParseURIA(url: PAnsiChar; out port: Word; out schema_begin, schema_end, host_begin, host_end, port_begin,
  port_end, username_begin, username_end, password_begin, password_end, path_begin, path_end: PAnsiChar): Boolean;
begin
  Result := False;

  username_begin := nil;
  username_end := nil;
  password_begin := nil;
  password_end := nil;

  schema_begin := url;

  if IBeginWithA(url, 'http://') then
  begin
    schema_end := url + 4;
    port := 80;
    host_begin := url + 7;
  end
  else if IBeginWithA(url, 'https://') then
  begin
    schema_end := url + 5;
    port := 443;
    host_begin := url + 8;
  end
  else if IBeginWithA(url, '//') then
  begin
    schema_end := url;
    host_begin := url + 2;
    port := 0;
  end
  else
  begin
    schema_end := nil;
    host_begin := url;
    port := 0;
  end;

  host_end := host_begin;

  while (host_end^ <> #0) and (host_end^ <> ':') and (host_end^ <> '/') do
    Inc(host_end);

  if (host_end > host_begin) and not HttpCheckHostNameA(host_begin, host_end - host_begin) then
    Exit;

  port_begin := nil;
  port_end := nil;
  path_begin := nil;
  path_end := nil;

  case host_end^ of
    ':':
      begin
        port_begin := host_end + 1;
        port_end := port_begin;
        port := 0;
        while (port_end^ <> #0) and (port_end^ <> '/') do
        begin
          if (port_end^ >= '0') and (port_end^ <= '9') then
            port := port * 10 + PByte(port_end)^ - $30
          else
            Exit;

          Inc(port_end);
        end;

        if port_end = port_begin then
          Exit;

        path_begin := port_end;
      end;
    '/':
      path_begin := host_end;
  end;

  if Assigned(path_begin) then
  begin
    path_end := path_begin;

    while path_end^ <> #0 do
      Inc(path_end);
  end;

  Result := True;
end;

function HttpCheckHostNameW(host: PWideChar; len: Integer): Boolean;
begin
  Result := len > 0;
  // not implemented
end;

function isParentDomain(child: PWideChar; childLen: Integer;
  parent: PWideChar; parentLen: Integer): Boolean;
begin
  if (childLen = 0) or (parentLen = 0) then
    Result := False
  else if parent[0] = '.' then
    Result := IEndWithW(child, childLen, parent, parentLen)
      or (StrCompareW(child, childLen, parent + 1, parentLen - 1) = 0)
  else
    Result := (StrCompareW(child, childLen, parent, parentLen) = 0)
      or ( IEndWithW(child, childLen, parent, parentLen)
      and (child[childLen - 1 - parentLen] = '.') );
end;

function isParentDomain(const child, parent: UnicodeString): Boolean;
begin
  Result := isParentDomain(PWideChar(child), Length(child), PWideChar(parent), Length(parent));
end;

function isParentDomain(child: PAnsiChar; childLen: Integer;
  parent: PAnsiChar; parentLen: Integer): Boolean;
begin
  if (childLen = 0) or (parentLen = 0) then
    Result := False
  else if parent[0] = '.' then
    Result := IEndWithA(child, childLen, parent, parentLen)
      or (StrCompareA(child, childLen, parent + 1, parentLen - 1) = 0)
  else
    Result := (StrCompareA(child, childLen, parent, parentLen) = 0)
      or ( IEndWithA(child, childLen, parent, parentLen)
      and (child[childLen - 1 - parentLen] = '.') );
end;

function isParentDomain(const child, parent: RawByteString): Boolean;
begin
  Result := isParentDomain(PAnsiChar(child), Length(child), PAnsiChar(parent), Length(parent));
end;

procedure HttpFillUploadStream(const boundary: RawByteString; const ParamNames, ParamValues, FileKeys, FileNames, MimeTypes: array of RawByteString;
  const FileDatas: array of TStream; PostParam: TStream); overload;
const
  SContentDisposition: RawByteString = 'Content-Disposition: form-data; name="';
  SFileName: RawByteString = '"; filename="';
  SContentType: RawByteString = '"'#13#10'Content-Type: ';
  STextPlainContentType: RawByteString = '"'#13#10'Content-Type: text/plain'#13#10#13#10;
  SNameTag = 'name';
  SCRLF: RawByteString = #13#10;
  SDoubleMinus: RawByteString = '--';
var
  i, L: Integer;
  fileName: RawByteString;
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
    fileName := FileNames[i];
    if fileName = '' then
      fileName := RandomAlphaDigitRBStr(32);
    StreamWriteStrA(PostParam, fileName);
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

procedure HttpFillUploadStream(const boundary: RawByteString; ParamNames, ParamValues: TRawByteStrings;
  const FileKeys, FileNames, MimeTypes: array of RawByteString;
  const FileDatas: array of TStream; PostParam: TStream); overload;
const
  SContentDisposition: RawByteString = 'Content-Disposition: form-data; name="';
  SFileName: RawByteString = '"; filename="';
  SContentType: RawByteString = '"'#13#10'Content-Type: ';
  STextPlainContentType: RawByteString = '"'#13#10'Content-Type: text/plain'#13#10#13#10;
  SNameTag = 'name';
  SCRLF: RawByteString = #13#10;
  SDoubleMinus: RawByteString = '--';
var
  i, L: Integer;
  fileName: RawByteString;
begin
  L := 0;

  for i := 0 to ParamNames.Count - 1 do
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

  for i := 0 to ParamNames.Count - 1 do
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
    fileName := FileNames[i];
    if fileName = '' then
      fileName := RandomAlphaDigitRBStr(32);
    StreamWriteStrA(PostParam, fileName);
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

function HttpParseURIW(url: PWideChar; out port: Word; out schema_begin, schema_end, host_begin, host_end, port_begin,
  port_end, username_begin, username_end, password_begin, password_end, path_begin, path_end: PWideChar): Boolean;
const
  SHttpUrlBegin: PWideChar = 'http://';
  SHttpsUrlBegin: PWideChar = 'https://';
  SNoSchemaUrlBegin: PWideChar = '//';
begin
  Result := False;

  username_begin := nil;
  username_end := nil;
  password_begin := nil;
  password_end := nil;

  schema_begin := url;

  if IBeginWithW(url, SHttpUrlBegin) then
  begin
    schema_end := url + 4;
    port := 80;
    host_begin := url + 7;
  end
  else if IBeginWithW(url, SHttpsUrlBegin) then
  begin
    schema_end := url + 5;
    port := 443;
    host_begin := url + 8;
  end
  else if IBeginWithW(url, SNoSchemaUrlBegin) then
  begin
    port := 0;
    schema_end := url;
    host_begin := url + 2;
  end
  else
  begin
    port := 0;
    schema_end := nil;
    host_begin := url;
  end;

  host_end := host_begin;

  while (host_end^ <> #0) and (host_end^ <> ':') and (host_end^ <> '/') do
    Inc(host_end);

  if (host_end > host_begin) and not HttpCheckHostNameW(host_begin, host_end - host_begin) then
    Exit;

  port_begin := nil;
  port_end := nil;
  path_begin := nil;
  path_end := nil;

  case host_end^ of
    ':':
      begin
        port_begin := host_end + 1;
        port_end := port_begin;
        port := 0;
        while (port_end^ <> #0) and (port_end^ <> '/') do
        begin
          if (port_end^ >= '0') and (port_end^ <= '9') then
            port := port * 10 + PWord(port_end)^ - $30
          else
            Exit;

          Inc(port_end);
        end;

        if port_end = port_begin then
          Exit;

        path_begin := port_end;
      end;
    '/':
      path_begin := host_end;
  end;

  if Assigned(path_begin) then
  begin
    path_end := path_begin;

    while path_end^ <> #0 do
      Inc(path_end);
  end;

  Result := True;
end;

function HTMLGetCharset(content: PAnsiChar; ContentLength: Integer; var charset: PAnsiChar): Integer;
var
  p1, p2: PAnsiChar;
  ContentType, sec: TAnsiCharSection;
begin
  sec._begin := content;
  sec._end := content + ContentLength;

  ContentType := HtmlGetPropByProp(sec, TAnsiCharSection.Create('meta'), TAnsiCharSection.Create('http-equiv'),
    TAnsiCharSection.Create('Content-Type'), TAnsiCharSection.Create('content'));

  if (ContentType.length > 0) and GetSectionBetweenA2(ContentType._begin, ContentType.length,
    'charset=', [#0, ';', #32, #39, #9], p1, p2) then
  begin
    charset := p1;
    Result := p2 - p1;
  end
  else Result := 0;
end;

function XMLGetCharset(content: PAnsiChar; ContentLength: Integer; var charset: PAnsiChar): Integer;
var
  encoding, sec: TAnsiCharSection;
begin
  sec._begin := content;
  sec._end := content + ContentLength;

  encoding := HtmlGetPropByProp(sec, TAnsiCharSection.Create('?xml'), TAnsiCharSection.Create(''),
    TAnsiCharSection.Create(''), TAnsiCharSection.Create('encoding'));

  charset := encoding._begin;
  Result := encoding.length;
end;

function _WinHttpDecodeResponseText(ContentType: PHttpChar; ContentTypeLen: Integer;
  ResponseContent: TMemoryStream; ContentLength: Integer;
  out CodePage: Integer): UnicodeString;
const
  PWCCharsetTag: PHttpChar = 'charset=';
  PWCHtmlName: PHttpChar = 'html';
  PWCXmlName: PHttpChar = 'xml';
var
  n: Integer;
  RespHdrCharset: PHttpChar;
  ContentCharset: PAnsiChar;
  tmp: array [0..63] of AnsiChar;
begin
  Result := '';

  Codepage := -1;
  RespHdrCharset := StrIPosW(PWCCharsetTag, 8, ContentType, ContentTypeLen);

  if Assigned(RespHdrCharset) then
  begin
    Inc(RespHdrCharset, 8);

    n := 0;

    while (RespHdrCharset^ <> #0) and (RespHdrCharset^ <> ';') do
    begin
      tmp[n] := AnsiChar(RespHdrCharset^);
      Inc(n);
      Inc(RespHdrCharset);
    end;

    tmp[n] := #0;

    Codepage := CodePageName2ID(tmp, n);
  end
  else begin
    if Assigned(StrIPosW(PWCHtmlName, 4, ContentType, ContentTypeLen))then
    begin
      n := HTMLGetCharset(PAnsiChar(ResponseContent.Memory) + ResponseContent.Position, ContentLength, ContentCharset);
      if n > 0 then Codepage := CodePageName2ID(ContentCharset, n);
    end
    else if Assigned(StrIPosW(PWCXmlName, 3, ContentType, ContentTypeLen)) then
    begin
      n := XMLGetCharset(PAnsiChar(ResponseContent.Memory) + ResponseContent.Position, ContentLength, ContentCharset);
      if n > 0 then Codepage := CodePageName2ID(ContentCharset, n);
    end;
  end;

  if CodePage < 0 then
    Result := BufToUnicodeEx(PAnsiChar(ResponseContent.Memory) + ResponseContent.Position, ContentLength, [CP_UTF8, CP_ACP, 950, 936, 52936, 54936, CP_UTF7])
  else
    Result := BufToUnicode(PAnsiChar(ResponseContent.Memory) + ResponseContent.Position, ContentLength, Codepage);
end;

function WinHttpDecodeResponseText(request: TBaseHttpRequest; ResponseContent: TStream; ContentLength: Integer;
  out CodePage: Integer): UnicodeString;
const
  PWCCharsetTag: THttpString = 'charset=';
  PWCTextTag: THttpString = 'text/';
  PWCXmlTag: THttpString = 'xml/';
  PWCHtmlTag: THttpString = 'text/';
  USContentType: THttpString = 'application/x-www-form-urlencoded';
var
  ContentType: THttpString;
  ms: TMemoryStream;
begin
  Result := '';
  CodePage := CP_ACP;
  ContentType:= request.ResponseHeaders.ContentType;

  if (ContentType <> '') and ( (UStrIPos(PWCTextTag, ContentType) > 0)
    or (UStrIPos(PWCHtmlTag, ContentType) > 0)
    or (UStrIPos(PWCXmlTag, ContentType) > 0)
    or (UStrIPos(USContentType, ContentType) > 0)
    or (UStrIPos(PWCCharsetTag, ContentType) > 0) ) then
  begin
    if ResponseContent is TMemoryStream then
      Result := _WinHttpDecodeResponseText(PHttpChar(ContentType), Length(ContentType),
        TMemoryStream(ResponseContent), ContentLength, CodePage)
    else begin
      ms := TMemoryStream.Create;

      try
        ms.CopyFrom(ResponseContent, ContentLength);
        ms.Seek(0, soFromBeginning);
        Result := _WinHttpDecodeResponseText(PHttpChar(ContentType), Length(ContentType), ms, ContentLength, CodePage);
      finally
        ms.Free;
      end;
    end;
  end
  else begin
    if ResponseContent is TMemoryStream then
      Result := BufToUnicodeEx(PAnsiChar(TMemoryStream(ResponseContent).Memory) + ResponseContent.Position,
        ContentLength, [CP_UTF8, CP_ACP, 950, 936, 52936, 54936, CP_UTF7])
    else begin
      ms := TMemoryStream.Create;

      try
        ms.CopyFrom(ResponseContent, ContentLength);
        ms.Seek(0, soFromBeginning);
        Result := BufToUnicodeEx(PAnsiChar(ms.Memory), ContentLength, [CP_UTF8, CP_ACP, 950, 936, 52936, 54936, CP_UTF7])
      finally
        ms.Free;
      end;
    end;
  end;
end;

function ContentType_2_ext(const ContentType: THttpString): string;
begin
  if UStrPos('/html', ContentType) > 0 then
    Result := '.htm'
  else if UStrPos('/plain', ContentType) > 0 then
    Result := '.txt'
  else if UStrPos('/xml', ContentType) > 0 then
    Result := '.xml'
  else if UStrPos('/json', ContentType) > 0 then
    Result := '.json'
  else if UStrPos('/jpeg', ContentType) > 0 then
    Result := '.jpg'
  else if UStrPos('/png', ContentType) > 0 then
    Result := '.png'
  else if UStrPos('/jpg', ContentType) > 0 then
    Result := '.jpg'
  else if UStrPos('/gif', ContentType) > 0 then
    Result := '.gif'
  else
    Result := '';
end;

procedure DoLogHttp(const request: TBaseHttpRequest; const headers: TFrequentlyUsedHttpRequestHeaders;
  pInternalHeaders: PInternalHttpRequestHeaders; ContentStream: TStream; ContentLength: Integer);
var
  RequestHeaders: THttpString;
  ResponseText: UnicodeString;
  ContentDir, srnd, FileName, HttpFile: string;
  curpos: Int64;
  i, CodePage: Integer;
  HeaderList: THttpHeaders;
  header: THttpHeader;
begin
  if LockHttpLog then
  begin
    srnd := RandomAlphaDigitUStr(8);

    try
      RequestHeaders := request.MakeRequestHeader(headers, True, pInternalHeaders);

      StreamWriteStrA(HttpLogStream, RBStrNow);
      StreamWriteStrA(HttpLogStream, #13#10);
      StreamWriteStrA(HttpLogStream, RawByteString(request.url.GetUrl));
      StreamWriteStrA(HttpLogStream, #13#10);
      StreamWriteStrA(HttpLogStream, RawByteString(RequestHeaders));

      if Assigned(request.param) then HttpLogStream.WriteBuffer(request.param^, request.ParamLength);
      if Assigned(request.ParamStream) then HttpLogStream.CopyFrom(request.ParamStream, 0);

      if Assigned(request.param) or Assigned(request.ParamStream) then
        StreamWriteStrA(HttpLogStream, #13#10#13#10);

      StreamWriteStrA(HttpLogStream, RawByteString(request.ResponseHeaders.ResponseLine.version) + ' ');
      StreamWriteStrA(HttpLogStream, IntToRBStr(request.ResponseHeaders.ResponseLine.StatusCode));
      StreamWriteStrA(HttpLogStream, ' ');
      StreamWriteStrA(HttpLogStream, RawByteString(request.ResponseHeaders.ResponseLine.StatusText));
      StreamWriteStrA(HttpLogStream, #13#10);

      HeaderList := request.ResponseHeaders;

      for i := 0 to HeaderList.Items.Count - 1 do
      begin
        header := HeaderList.Items[i];
        StreamWriteStrA(HttpLogStream, RawByteString(header.name));
        StreamWriteStrA(HttpLogStream, ': ');
        StreamWriteStrA(HttpLogStream, RawByteString(header.value));
        StreamWriteStrA(HttpLogStream, #13#10);
      end;

      StreamWriteStrA(HttpLogStream, #13#10);

      if Assigned(ContentStream) and (ContentLength > 0) then
      begin
        if HttpLogResponseDir = '' then
        begin
          ContentDir := ExtractFilePath(ParamStr(0)) + 'logs\http\files\';
          ForceDirectories(ContentDir);
        end
        else
          ContentDir := HttpLogResponseDir;

        if ContentDir[Length(ContentDir)] <> '\'  then
          ContentDir := ContentDir + '\';

        HttpFile := string(request.url.FileName);

        if DWORD(ContentLength) > g_LogHttpMaxContentLength then
        begin
          FileName :=  ContentDir + srnd + '_' + HttpFile;
          //UStrDbgOutput(FileName);

          FileName := ChangeFileExt(FileName, ContentType_2_ext(request.ResponseHeaders.ContentType));
          curpos := ContentStream.Position;
          SafeSaveStreamToFile(FileName, ContentStream, ContentLength);
          ContentStream.Position := curpos;

          StreamWriteStrA(HttpLogStream, 'content: ');
          StreamWriteStrA(HttpLogStream, RawByteString(FileName));
        end
        else begin
          curpos := ContentStream.Position;
          ResponseText := WinHttpDecodeResponseText(request, ContentStream, ContentLength, CodePage);
          ContentStream.Position := curpos;

          if ResponseText = '' then
          begin
            FileName := ContentDir + srnd + '_' + HttpFile;
            //UStrDbgOutput(FileName);

            curpos := ContentStream.Position;
            SafeSaveStreamToFile(FileName, ContentStream, ContentLength);
            ContentStream.Position := curpos;

            StreamWriteStrA(HttpLogStream, 'content: ');
            StreamWriteStrA(HttpLogStream, RawByteString(FileName));
          end
          else
            StreamWriteStrA(HttpLogStream, RawByteString(ResponseText));
        end;
      end;

      StreamWriteStrA(HttpLogStream, #13#10'*******************************************************'#13#10#13#10);
    finally
      UnLockHttpLog;
    end;
  end;
end;

type
  TSetCookie = record
    domain, path, name, value: THttpString;
    expires: TDateTime;
    secure: Boolean;
  end;

function CookieGetSection(const s, name: THttpString; pExist: PBoolean = nil): THttpString;
var
  P1, P2, L: Integer;
begin
  Result := '';
  if Assigned(pExist) then
    pExist^ := False;

  P1 := 1;
  L := Length(s);

  while P1 <= L do
  begin
    P1 := UStrIPos(name, s, P1);

    if P1 <= 0 then
      Break;

    if (P1 > 1) and (s[P1 - 1] > #32) and (s[P1 - 1] <> ';') then
    begin
      Inc(P1, Length(name));
      Continue;
    end;

    P2 := P1 + Length(name);

    if (P2 > L) or (s[P2] = ';') then
    begin
      if Assigned(pExist) then
        pExist^ := True;
      Break;
    end;

    if S[P2] <> '=' then
    begin
      P1 := P2;
      Continue;
    end;

    P1 := P2 + 1;
    P2 := P1;

    while (P2 <= L) and (s[P2] <> ';') do
      Inc(P2);

    Result := UStrTrimCopy(s, P1, P2 - P1);
    if Assigned(pExist) then
      pExist^ := True;
    Break;
  end;
end;

function ParseSetCookie(const s: THttpString; out info: TSetCookie): Boolean;
var
  NameBegin, NameEnd, ValueBegin, ValueEnd, L: Integer;
  tmp: THttpString;
  b: Boolean;
begin
  // Set-Cookie：customer=huangxp; path=/foo; domain=.ibm.com; expires=Wednesday, 19-OCT-05 23:12:40 GMT; [secure]

  // UStrDbgOutput(s);

  Result := False;
  NameEnd := 1;
  L := Length(s);

  while (NameEnd <= L) and (s[NameEnd] <> '=') do
    Inc(NameEnd);

  NameBegin := NameEnd - 1;

  while (NameBegin >= 1) and (s[NameBegin] > #32) and (s[NameBegin] <> ':') do
    Dec(NameBegin);

  if NameBegin = 0 then
    NameBegin := 1;

  if NameEnd > L then
    Exit;

  ValueEnd := NameEnd + 1;

  while (ValueEnd <= L) and (s[ValueEnd] <> ';') do
    Inc(ValueEnd);

  if ValueEnd > L then
    Exit;

  ValueBegin := NameEnd + 1;

  info.name := UStrTrimCopy(s, NameBegin, NameEnd - NameBegin);
  info.value := UStrTrimCopy(s, ValueBegin, ValueEnd - ValueBegin);

  info.domain := CookieGetSection(s, 'domain');
  info.path := CookieGetSection(s, 'path');

  tmp := CookieGetSection(s, 'expires');

  if tmp = '' then
    info.expires := 0
  else
    info.expires := GMTStringToDateTime(tmp);

  tmp := CookieGetSection(s, 'secure', @b);
  info.secure := b and (tmp = '');

  // UStrDbgOutput(info.domain + ', ' + info.path + ', ' + info.name + ', ' + info.value + ', ' +DateTimeToStr(info.expires));

  Result := True;
end;

{ TCookieDomain }

procedure TCookieDomain.clear;
var
  tmp: TCookie;
begin
  while Assigned(FCookieList) do
  begin
    tmp := FCookieList;
    FCookieList := FCookieList.next;
    tmp.Free;
  end;
end;

destructor TCookieDomain.Destroy;
begin
  clear;
  inherited;
end;

function TCookieDomain.FindItem(const name: THttpString): TCookie;
var
  tmp: TCookie;
begin
  Result := nil;

  tmp := FCookieList;

  while Assigned(tmp) do
  begin
    if UStrSameText(tmp.name, name) then
    begin
      Result := tmp;
      Break;
    end;

    tmp := tmp.next;
  end;
end;

function TCookieDomain.GetCookie(const name: THttpString): THttpString;
var
  item: TCookie;
begin
  item := FindItem(name);

  if Assigned(item) then
    Result := item.value
  else
    Result := '';
end;

function TCookieDomain.GetCookies(https: Boolean): THttpString;
var
  tmp: TCookie;
begin
  Result := '';

  tmp := FCookieList;

  while Assigned(tmp) do
  begin
    if (https or not tmp.secure) and (tmp.value <> '') then
    begin
      if Result = '' then
        Result := tmp.name + '=' + tmp.value
      else
        Result := Result + '; ' + tmp.name + '=' + tmp.value;
    end;

    tmp := tmp.next;
  end;
end;

procedure TCookieDomain.SaveReadableCookies(strs: THttpStrings);
var
  tmp: TCookie;
  s: THttpString;
begin
  // Set-Cookie：customer=huangxp; path=/foo; domain=.ibm.com; expires=Wednesday, 19-OCT-05 23:12:40 GMT; [secure]
  tmp := FCookieList;

  while Assigned(tmp) do
  begin
    s := 'Set-Cookie: ' + tmp.name + '=' + tmp.value + '; Domain=' + domain + '; Path=' + path;

    if tmp.expires > 1 then
      s := s + '; expires=' + THttpString(FormatDateTime('yyyy-MM-dd hh:nn:ss', tmp.expires));

    if tmp.secure then
      s := s + '; secure';

    strs.add(s);
    tmp := tmp.next;
  end;
end;

function TCookieDomain.MatchHost(const host, path: THttpString): Boolean;
begin
  Result := isParentDomain(host, Self.domain) and ((path = '') or UStrBeginWith(path, Self.path));
end;

function TCookieDomain.MatchHost2(host, path: PHttpChar): Boolean;
begin
  Result := isParentDomain(host, StrLenW(host), PHttpChar(Self.domain), Length(Self.domain)) and
    (not Assigned(path) or (path[0] = #0) or BeginWithW(path, PHttpChar(Self.path)));
end;

function TCookieDomain.SetCookie(const name, value: THttpString; expires: TDateTime; secure: Boolean): TCookie;
var
  item: TCookie;
begin
  item := FindItem(name);

  if not Assigned(item) then
  begin
    item := TCookie.Create;
    item.name := name;
    item.next := FCookieList;
    FCookieList := item;
  end;

  item.value := value;
  item.secure := secure;

  if expires > 1 then
    item.expires := expires;

  Result := item;
end;

{ TCookieManager }

procedure TCookieManager.clear(const host, path: THttpString);
var
  prev, tmp, next: TCookieDomain;
begin
  FLock.Enter;

  try
    tmp := FDomainList;
    prev := nil;

    while Assigned(tmp) do
    begin
      next := tmp.next;
      if ( (host = '') or UStrSameText(tmp.domain, host) ) and ( (path = '') or UStrSameText(tmp.path, path) ) then
      begin
        tmp.Free;
        tmp := next;

        if prev <> nil then
          prev.next := next
        else
          FDomainList := next;
      end
      else begin
        prev := tmp;
        tmp := next;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

constructor TCookieManager.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
end;

destructor TCookieManager.Destroy;
begin
  clear;
  FLock.Free;
  inherited;
end;

function TCookieManager.FindCookie(const host, path, name: THttpString): TCookie;
var
  tmp: TCookieDomain;
  cookie: TCookie;
begin
  Result := nil;
  tmp := FDomainList;

  FLock.Enter;

  try
    while Assigned(tmp) do
    begin
      if (host = '') or tmp.MatchHost(host, path) then
      begin
        cookie := tmp.FindItem(name);

        if Assigned(cookie) then
        begin
          Result := cookie;
          Break;
        end;
      end;

      tmp := tmp.next;
    end;
  finally
    FLock.Leave;
  end;
end;

function TCookieManager.FindDomain(const domain, path: THttpString): TCookieDomain;
var
  tmp: TCookieDomain;
  _path: THttpString;
begin
  Result := nil;
  tmp := FDomainList;

  if path = '' then
    _path := '/'
  else
    _path := path;

  FLock.Enter;

  try
    while Assigned(tmp) do
    begin
      if UStrSameText(tmp.domain, domain) and  UStrSameText(tmp.path, _path) then
      begin
        Result := tmp;
        Break;
      end;

      tmp := tmp.next;
    end;
  finally
    FLock.Leave;
  end;
end;

function TCookieManager.GetCookie(const name, host, path: THttpString): THttpString;
var
  item: TCookie;
begin
  item := FindCookie(host, path, name);

  if Assigned(item) then
    Result := item.value
  else
    Result := '';
end;

function TCookieManager.GetCookies(const host, path: THttpString; https: Boolean): THttpString;
var
  tmp: TCookieDomain;
  s: THttpString;
begin
  Result := '';
  tmp := FDomainList;

  FLock.Enter;

  try
    while Assigned(tmp) do
    begin
      if (host = '') or tmp.MatchHost(host, path) then
      begin
        s := tmp.GetCookies(https);

        if s <> '' then
        begin
          if Result = '' then
            Result := s
          else
            Result := Result + '; ' + s;
        end;
      end;

      tmp := tmp.next;
    end;
  finally
    FLock.Leave;
  end;
end;

function TCookieManager.GetCookies2(host, path: PHttpChar; https: Boolean): THttpString;
var
  tmp: TCookieDomain;
  s: THttpString;
begin
  Result := '';
  tmp := FDomainList;

  FLock.Enter;

  try
    while Assigned(tmp) do
    begin
      if (host = nil) or (host[0] = #0) or tmp.MatchHost2(host, path) then
      begin
        s := tmp.GetCookies(https);

        if s <> '' then
        begin
          if Result = '' then
            Result := s
          else
            Result := Result + '; ' + s;
        end;
      end;

      tmp := tmp.next;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TCookieManager.LoadFromFile(const fileName: string);
var
  strs: TStringList;
begin
  strs := TStringList.Create;

  try
    strs.LoadFromFile(fileName);
    Self.LoadReadableCookies(strs);
  finally
    strs.Free;
  end;
end;

procedure TCookieManager.LoadReadableCookies(strs: THttpStrings);
var
  I: Integer;
  s: THttpString;
begin
  FLock.Enter;
  try
    for I := 0 to strs.Count - 1 do
    begin
      s := UStrTrim(strs[I]);

      if s <> '' then
        ParseResponseCookie(s, '');
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TCookieManager.SaveReadableCookies(strs: THttpStrings);
var
  tmp: TCookieDomain;
begin
  FLock.Enter;

  try
    tmp := FDomainList;

    while Assigned(tmp) do
    begin
      tmp.SaveReadableCookies(strs);
      tmp := tmp.next;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TCookieManager.SaveToFile(const fileName: string);
var
  strs: TStringList;
begin
  strs := TStringList.Create;

  try
    Self.SaveReadableCookies(strs);
    strs.SaveToFile(fileName);
  finally
    strs.Free;
  end;
end;

function TCookieManager.SetCookie(const domain, path, name, value: THttpString; secure: Integer;
  expires: TDateTime): TCookie;
var
  container: TCookieDomain;
  cookie: TCookie;
begin
  FLock.Enter;

  try
    if domain = '' then
    begin
      cookie := Self.FindCookie('', '', name);
      if Assigned(cookie) then
      begin
        cookie.value := value;

        if secure = 0 then
          cookie.secure := False
        else if secure = 1 then
          cookie.secure := True;

        if expires > 1 then
          cookie.expires := expires;

        Result := cookie;
      end
      else
        Result := nil;
    end
    else
    begin
      container := FindDomain(domain, path);

      if not Assigned(container) then
      begin
        container := TCookieDomain.Create;
        container.domain := domain;

        if path = '' then
          container.path := '/'
        else
          container.path := path;

        container.next := FDomainList;
        FDomainList := container;
      end;

      Result := container.SetCookie(name, value, expires, secure = 1);
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TCookieManager.ParseRequestCookies(const domain, cookies: THttpString);
var
  container: TCookieDomain;
  cookiesec: THttpCharSection;
  sptr, send, pequal: PHttpChar;
  name, value: THttpString;
begin
  sptr := PHttpChar(cookies);
  send := sptr + Length(cookies);

  FLock.Enter;

  try
    container := FindDomain(domain, '/');

    if not Assigned(container) then
    begin
      container := TCookieDomain.Create;
      container.domain := domain;
      container.path := '/';
      container.next := FDomainList;
      FDomainList := container;
    end;

    while sptr < send do
    begin
      cookiesec._begin := sptr;
      cookiesec._end := sptr;

      while (cookiesec._end < send) and (cookiesec._end^ <> ';') do
        Inc(cookiesec._end);

      sptr := cookiesec._end + 1;

      cookiesec.trim;

      if cookiesec.length > 0 then
      begin
        pequal := cookiesec._begin;
        while (pequal < cookiesec._end) and (pequal^ <> '=') do
          Inc(pequal);

        if pequal > cookiesec._begin then
        begin
          SetUString(name, cookiesec._begin, pequal);
          SetUString(value, pequal + 1, cookiesec._end);
          container.SetCookie(name, value, UTCNow + 365, False);
        end;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function TCookieManager.ParseResponseCookie(const set_cookie, host: THttpString): TCookie;
var
  info: TSetCookie;
begin
  if not ParseSetCookie(set_cookie, info) then
    Result := nil
  else begin
    if info.domain = '' then
      info.domain := host;
    Result := Self.SetCookie(info.domain, info.path, info.name, info.value, Ord(info.secure), info.expires);
  end;
end;

{ THttpHeaders }

procedure THttpHeaders.add(const name, value: THttpString);
var
  header: THttpHeader;
  idx: Integer;
begin
  header := Self.find(name, idx);

  if idx >= 0 then
  begin
    if (UStrAsciiICompare(header.name, 'Set-Cookie') = 0) and (UStrAsciiICompare(header.value, value) <> 0) then
    begin
      header.name := name;
      header.value := value;
      FItems.Add(header);
    end;
  end
  else
  begin
    header.name := name;
    header.value := value;
    FItems.Add(header);
  end;
end;

function THttpHeaders.all: THttpString;
var
  i: Integer;
begin
  if Self.FItems.Count > 0 then
  begin
    Result := Self.FItems[0].name + ': ' + Self.FItems[0].value;

    for i := 1 to Self.FItems.Count - 1 do
      Result := Result + #13#10 + Self.FItems[i].name + ': ' + Self.FItems[i].value;
  end;
end;

procedure THttpHeaders.clear;
begin
  FItems.Clear;
end;

constructor THttpHeaders.Create;
begin
  inherited Create;
  FItems := TList<THttpHeader>.Create;
end;

destructor THttpHeaders.Destroy;
begin
  FItems.Free;
  inherited;
end;

function THttpHeaders.exists(const name: THttpString): Boolean;
var
  idx: Integer;
begin
  Result := find(name, idx).name <> '';
end;

function THttpHeaders.find(const name: THttpString; var idx: Integer): THttpHeader;
var
  I: Integer;
  tmp: THttpHeader;
begin
  Result.name := '';
  idx := -1;
  for I := 0 to FItems.Count - 1 do
  begin
    tmp := THttpHeader(FItems[I]);

    if UStrAsciiICompare(tmp.name, name) = 0 then
    begin
      idx := I;
      Result := tmp;
      Break;
    end;
  end;
end;

function THttpHeaders.foreach(callback: THttpHeaderProc; param: Pointer): Boolean;
var
  I: Integer;
  tmp: THttpHeader;
begin
  Result := True;

  for I := 0 to FItems.Count - 1 do
  begin
    tmp := THttpHeader(FItems[I]);

    if not callback(param, tmp) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function THttpHeaders.foreach(const name: THttpString; callback: THttpHeaderProc; param: Pointer): Boolean;
var
  I: Integer;
  tmp: THttpHeader;
begin
  Result := True;

  for I := 0 to FItems.Count - 1 do
  begin
    tmp := THttpHeader(FItems[I]);

    if (UStrAsciiICompare(tmp.name, name) = 0) and not callback(param, tmp) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function THttpHeaders.get(const name: THttpString): THttpString;
var
  I: Integer;
  tmp: THttpHeader;
begin
  Result := '';

  for I := 0 to FItems.Count - 1 do
  begin
    tmp := THttpHeader(FItems[I]);

    if UStrAsciiICompare(tmp.name, name) = 0 then
    begin
      Result := tmp.value;
      Break;
    end;
  end;
end;

function THttpHeaders.GetConnection: THttpString;
begin
  Result := Self.GetS('Connection');
end;

function THttpHeaders.GetContentEncoding: THttpString;
begin
  Result := Self.GetS('Content-Encoding');
end;

function THttpHeaders.GetContentLength: THttpString;
begin
  Result := Self.GetS('Content-Length');
end;

function THttpHeaders.GetContentLengthAsInt: Int64;
begin
  Result := Self.GetI('Content-Length');
end;

function THttpHeaders.GetContentType: THttpString;
begin
  Result := Self.GetS('Content-Type');
end;

function THttpHeaders.GetCookie: THttpString;
begin
  Result := Self.GetS('Cookie');
end;

function THttpHeaders.GetI(const name: THttpString): Int64;
var
  header: THttpHeader;
  idx: Integer;
begin
  header := Self.find(name, idx);

  if (header.name <> '') and (header.value <> '') then
    Result := UStrToInt64(header.value)
  else
    Result := -1;
end;

function THttpHeaders.GetLocation: THttpString;
begin
  Result := Self.GetS('Location');
end;

function THttpHeaders.GetOrigin: THttpString;
begin
  Result := Self.GetS('Origin');
end;

function THttpHeaders.GetS(const name: THttpString): THttpString;
var
  header: THttpHeader;
  idx: Integer;
begin
  header := Self.find(name, idx);

  if idx >= 0 then
    Result := header.value
  else
    Result := '';
end;

function THttpHeaders.GetTransferEncoding: THttpString;
begin
  Result := Self.GetS('Transfer-Encoding');
end;

procedure THttpHeaders.SetConnection(const value: THttpString);
begin
  Self.SetS('Connection', value);
end;

procedure THttpHeaders.SetContentEncoding(const value: THttpString);
begin
  Self.SetS('Content-Encoding', value);
end;

procedure THttpHeaders.SetContentLength(const Value: THttpString);
begin
  Self.SetS('Content-Length', value);
end;

procedure THttpHeaders.SetContentLengthAsInt(const value: Int64);
begin
  Self.SetI('Content-Length', value);
end;

procedure THttpHeaders.SetContentType(const value: THttpString);
begin
  Self.SetS('Content-Type', value);
end;

procedure THttpHeaders.SetCookie(const Value: THttpString);
begin
  Self.SetS('Cookie', value);
end;

procedure TBaseHttpRequest.ClearResponseHeaders;
begin
  if Assigned(FResponseHeaders) then
    FResponseHeaders.clear;
end;

constructor TBaseHttpRequest.Create;
begin
  inherited Create;
end;

destructor TBaseHttpRequest.Destroy;
begin
  FRequestHeaders.Release;
  FResponseHeaders.Release;
  inherited;
end;

function THttpHeaders.GetAccept: THttpString;
begin
  Result := S['Accept'];
end;

function THttpHeaders.GetAcceptCharset: THttpString;
begin
  Result := S['Accept-Charset'];
end;

function THttpHeaders.GetAcceptEncoding: THttpString;
begin
  Result := S['Accept-Encoding'];
end;

function THttpHeaders.GetAcceptLanguage: THttpString;
begin
  Result := S['Accept-Language'];
end;

function THttpHeaders.GetAuthorization: THttpString;
begin
  Result := S['Authorization'];
end;

function THttpHeaders.GetHost: THttpString;
begin
  Result := S['Host'];
end;

function THttpHeaders.GetReferer: THttpString;
begin
  Result := S['Referer'];
end;

function THttpHeaders.GetUserAgent: THttpString;
begin
  Result := S['User-Agent'];
end;

function THttpHeaders.GetXRequestedWith: THttpString;
begin
  Result := S['X-Requested-With'];
end;

procedure THttpHeaders.ParseOne(const s: TAnsiCharSection);
var
  P1: PAnsiChar;
  sec, sec2: TAnsiCharSection;
begin
  P1 := s._begin;
  while (P1 < s._end) and (P1^ <> ':') do Inc(P1);
  sec._begin := s._begin;
  sec._end := P1;
  sec.trim;
  sec2._begin := P1 + 1;
  sec2._end := s._end;
  sec2.trim;

  Self.add(THttpString(sec.ToString), THttpString(sec2.ToString));
end;

procedure THttpHeaders.ParseOne(const s: TWideCharSection);
var
  P1: PWideChar;
  sec, sec2: TWideCharSection;
begin
  P1 := s._begin;
  while (P1 < s._end) and (P1^ <> ':') do Inc(P1);
  sec._begin := s._begin;
  sec._end := P1;
  sec.trim;
  sec2._begin := P1 + 1;
  sec2._end := s._end;
  sec2.trim;

  Self.add(sec.ToUStr, sec2.ToUStr);
end;

procedure THttpHeaders.remove(const name: THttpString);
var
  I: Integer;
  tmp: THttpHeader;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    tmp := THttpHeader(FItems[I]);

    if UStrAsciiICompare(tmp.name, name) = 0 then
    begin
      FItems.Delete(I);
      Break;
    end;
  end;
end;

procedure THttpHeaders.SetAccept(const value: THttpString);
begin
  S['Accept'] := value;
end;

procedure THttpHeaders.SetAcceptCharset(const Value: THttpString);
begin
  S['Accept-Charset'] := value;
end;

procedure THttpHeaders.SetAcceptEncoding(const value: THttpString);
begin
  S['Accept-Encoding'] := value;
end;

procedure THttpHeaders.SetAcceptLanguage(const Value: THttpString);
begin
  S['Accept-Language'] := value;
end;

procedure THttpHeaders.SetAuthorization(const Value: THttpString);
begin
  S['Authorization'] := value;
end;

procedure THttpHeaders.SetHost(const value: THttpString);
begin
  S['Host'] := value;
end;

procedure THttpHeaders.SetReferer(const value: THttpString);
begin
  S['Referer'] := value;
end;

procedure THttpHeaders.SetUserAgent(const value: THttpString);
begin
  S['User-Agent'] := value;
end;

procedure THttpHeaders.SetXRequestedWith(const Value: THttpString);
begin
  S['X-Requested-With'] := Value;
end;

procedure THttpHeaders.SetI(const name: THttpString; const value: Int64);
var
  header: THttpHeader;
  idx: Integer;
begin
  header := Self.find(name, idx);

  if header.name <> '' then
  begin
    header.value := IntToUStr(value);
    fItems[idx] := header;
  end
  else
  begin
    header.name := name;
    header.value := IntToUStr(value);
    FItems.Add(header);
  end;
end;

procedure THttpHeaders.SetLocation(const Value: THttpString);
begin
  Self.SetS('Location', Value);
end;

procedure THttpHeaders.SetOrigin(const Value: THttpString);
begin
  Self.SetS('Origin', Value);
end;

procedure THttpHeaders.SetS(const name, value: THttpString);
var
  header: THttpHeader;
  idx: Integer;
begin
  header := Self.find(name, idx);

  if idx >= 0 then
  begin
    header.value := value;
    FItems[idx] := header;
  end
  else
  begin
    header.name := name;
    header.value := value;
    FItems.Add(header);
  end;
end;

procedure THttpHeaders.SetTransferEncoding(const value: THttpString);
begin
  Self.SetS('Transfer-Encoding', value);
end;

{ TCustomHttpSession }

constructor TCustomHttpSession.Create(_UserAgent: THttpString; _CookieManager: TCookieManager);
begin
  inherited Create;
  FAsync := True;
  FUserAgent := _UserAgent;

  if Assigned(_CookieManager) then
  begin
    _CookieManager.AddRef;
    FCookieManager := _CookieManager;
  end
  else
    FCookieManager := TCookieManager.Create;
end;

destructor TCustomHttpSession.Destroy;
begin
  FCookieManager.Release;
  inherited;
end;

type
  PParseCookiesContext = ^TParseCookiesContext;

  TParseCookiesContext = record
    session: TCustomHttpSession;
    request: TBaseHttpRequest;
  end;

function EnumHeadersProc_ParseCookies(param: Pointer; const header: THttpHeader): Boolean;
begin
  PParseCookiesContext(param).session.ParseSetCookie(header.value, PParseCookiesContext(param).request.url.host);
  Result := True;
end;

function TCustomHttpSession._DoRawRequest(
  request: TBaseHttpRequest;
  const headers: TFrequentlyUsedHttpRequestHeaders;
  const options: TBaseHttpOptions;
  ResponseContent: TStream;
  TimesErrorRetry: Integer;
  callback: THttpProgressEvent;
  AutoCookie: Boolean): THttpResult;
var
  Realheaders: TFrequentlyUsedHttpRequestHeaders;
  ParseCookiesContext: TParseCookiesContext;
  IOHandler: TCustomHttpIOHandler;
begin
  Realheaders := headers;

  if Realheaders.UserAgent = '' then
    Realheaders.UserAgent := FUserAgent;

  if AutoCookie then
    Realheaders.cookie := FCookieManager.GetCookies(request.url.host, request.url.PathWithParams,
      UStrSameText(request.url.schema, 'https'));

  Result := SendRequestAndReadHeaders(request, headers, options, TimesErrorRetry, callback, IOHandler);

  if Result.error.isSuccess then
  try
    if AutoCookie then
    begin
      ParseCookiesContext.session := Self;
      ParseCookiesContext.request := request;
      request.ResponseHeaders.foreach('Set-Cookie', EnumHeadersProc_ParseCookies, @ParseCookiesContext);
    end;

    Result.CurrentStep := hrsReceiveData;
    IOHandler.ReadBody(ResponseContent, Result.error);
  finally
    IOHandler.Free;
  end;
end;

function TCustomHttpSession._DoRequest(request: THttpRequest; const options: TBaseHttpOptions;
  ResponseContent: TStream; TimesErrorRetry: Integer; callback: THttpProgressEvent): THttpResult;
var
  redir: THttpString;
  cureq, newreq: TBaseHttpRequest;
  url: TUrl;
  Realheaders: TFrequentlyUsedHttpRequestHeaders;
  IOHandler: TCustomHttpIOHandler;
  ParseCookiesContext: TParseCookiesContext;
  n, flag: Integer;
  httperr: THttpError;
begin
  Result.init;

  cureq := request.GetLatestRequest;
  if request.RedirectOcuured then n := request.RedirctRequests.Count
  else n := 0;

  while n <= MAX_REDIRECT do
  begin
    Realheaders := request.headers;

    if Realheaders.UserAgent = '' then
      Realheaders.UserAgent := FUserAgent;

    if request.options.AutoCookie then
      Realheaders.cookie := FCookieManager.GetCookies(cureq.url.host, cureq.url.PathWithParams,
        UStrSameText(cureq.url.schema, 'https'));

    Result := SendRequestAndReadHeaders(cureq, Realheaders, options, TimesErrorRetry, callback, IOHandler);

    if not Result.error.isSuccess then
      Break;

    try
      if request.options.AutoCookie then
      begin
        ParseCookiesContext.session := Self;
        ParseCookiesContext.request := cureq;
        cureq.ResponseHeaders.foreach('Set-Cookie', EnumHeadersProc_ParseCookies, @ParseCookiesContext);
      end;

      if n = MAX_REDIRECT then flag := 0
      else begin
        redir := cureq.ResponseHeaders.location;
        if redir = '' then
          flag := 0
        else if request.options.AutoRedirect then
          flag := 1
        else if request.options.AutoSchemaSwitching then
        begin
          redir := HttpExpandUrl(redir, cureq.url.schema, cureq.url.host);
          url.parse(redir);
          if url.SameExceptSchema(cureq.url) then flag := 2
          else flag := 0;
        end
        else flag := 0;
      end;

      if flag = 0 then
      begin
        Result.CurrentStep := hrsReceiveData;
        IOHandler.ReadBody(ResponseContent, Result.error);
        Break;
      end
      else begin
        try
          IOHandler.ReadBody(nil, httperr);
        except

        end;

        newreq := TBaseHttpRequest.Create;
        newreq.method := 'GET';

        if flag = 2 then
          newreq.url := url
        else
          newreq.url.parse(redir);

        cureq.FRequestHeaders.AddRef;
        newreq.FRequestHeaders := cureq.FRequestHeaders;
        request.RedirctRequests.Add(newreq);
        cureq := newreq;
        Inc(n);
      end;
    finally
      IOHandler.Free;
    end;
  end;
end;

type
  THttpThread = class(TThread)
  private
    FRunning: Boolean;
    FOptions: TBaseHttpOptions;
    FSession: TCustomHttpSession;
    FRequest: THttpRequest;
    FContent: TStream;
    FCallback: THttpProgressEvent;
    FTimesErrorRetry: Integer;
  protected
    procedure Execute; override;
  public
    ReturnInfo: THttpResult;

    constructor Create(_session: TCustomHttpSession; _request: THttpRequest; const _options: TBaseHttpOptions;
      _content: TStream; _callback: THttpProgressEvent; _TimesErrorRetry: Integer);

    destructor Destroy; override;
    property running: Boolean read FRunning;
  end;

function TCustomHttpSession.PostWithoutRedirect(const url,
  referer: THttpString; param: TStream; const ParamType: THttpString;
  pLocation: PHttpString): RawByteString;
begin
  Result := Self.DoUrl_RawBytes(url, 'POST', referer, '', ParamType, nil, 0, param, @g_NoRedirectOptions, pLocation);
end;

function TCustomHttpSession.DoPath(mhm: TMultiHostManager;
  const path, method, schema, referer, headers, ContentType: THttpString;
  param: Pointer; ParamLength: DWORD; ParamStream, content: TStream; pOptions: PHttpOptions; pLocation: PHttpString;
  _AutoDecompress: Boolean; _TimesErrorRetry: Integer; _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD;
  callback: THttpProgressEvent): THttpResult;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
  i: Integer;
  SortedServerList: TObjectListEx<TNetworkHost>;
  sh: TNetworkHost;
  t: DWORD;
begin
  request := THttpRequest.Create;
  SortedServerList := mhm.OptimizeServerHosts;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.FSchema := schema;
    request.url.FPathWithParams := path;
    request.method := method;
    request.headers.referer := referer;
    request.headers.ContentType := ContentType;

    if headers <> '' then
      request.RequestHeaders.parse(TWideCharSection.Create(headers));

    request.param := param;
    request.ParamLength := ParamLength;
    request.ParamStream := ParamStream;
    options.AutoDecompress := _AutoDecompress;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;

    for i := 0 to SortedServerList.Count - 1 do
    begin
      sh := SortedServerList[i];

      request.url.HostName := THttpString(sh.HostName);
      request.url.port := sh.port;
      request.ClearResponseHeaders;
      request.ClearRedirects;

      try
        t := GetTickCount;
        Result := Self.DoRequest_AutoThread(request, options, content, _TimesErrorRetry, pLocation, callback);
        sh.SaveAccess(GetTickCount - t);
        Break;
      except
        if request.RedirectOcuured or (i = SortedServerList.Count - 1) then raise;
      end;
    end;
  finally
    request.Release;
    SortedServerList.Free;
  end;
end;

function TCustomHttpSession.DoPath(mhm: TMultiHostManager; const path, method: THttpString;
  const param: RawByteString; const schema: THttpString;
  pHeaders: PFrequentlyUsedHttpRequestHeaders; ParamStream, content: TStream;
  pOptions: PHttpOptions; pLocation: PHttpString; _AutoDecompress: Boolean; _TimesErrorRetry: Integer; _ConnectTimeout,
  _SendTimeout, _RecvTimeout: DWORD; callback: THttpProgressEvent): THttpResult;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
  i: Integer;
  SortedServerList: TObjectListEx<TNetworkHost>;
  sh: TNetworkHost;
  t: DWORD;
begin
  request := THttpRequest.Create;
  SortedServerList := mhm.OptimizeServerHosts;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.FSchema := schema;
    request.url.FPathWithParams := path;
    request.method := method;
    if Assigned(pHeaders) then
      request.headers := pHeaders^;
    request.param := Pointer(param);
    request.ParamLength := Length(param);
    request.ParamStream := ParamStream;
    options.AutoDecompress := _AutoDecompress;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;

    for i := 0 to SortedServerList.Count - 1 do
    begin
      sh := SortedServerList[i];

      request.url.HostName := THttpString(sh.HostName);
      request.url.port := sh.port;
      request.ClearResponseHeaders;
      request.ClearRedirects;

      try
        t := GetTickCount;
        Result := Self.DoRequest_AutoThread(request, options, content, _TimesErrorRetry, pLocation, callback);
        sh.SaveAccess(GetTickCount - t);
        Break;
      except
        if request.RedirectOcuured or (i = SortedServerList.Count - 1) then raise;
      end;
    end;
  finally
    request.Release;
    SortedServerList.Free;
  end;
end;

function TCustomHttpSession.DoPathAndDecode(mhm: TMultiHostManager;
  const path, method, schema, referer, headers, ContentType: THttpString;
  param: Pointer; ParamLength: DWORD; ParamStream: TStream; pOptions: PHttpOptions; pLocation: PHttpString;
  _TimesErrorRetry: Integer; _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD;
  callback: THttpProgressEvent): UnicodeString;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
  i: Integer;
  SortedServerList: TObjectListEx<TNetworkHost>;
  sh: TNetworkHost;
  t: DWORD;
begin
  request := THttpRequest.Create;
  SortedServerList := mhm.OptimizeServerHosts;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.FSchema := schema;
    request.url.FPathWithParams := path;
    request.method := method;
    request.headers.referer := referer;
    request.headers.ContentType := ContentType;

    if headers <> '' then
      request.RequestHeaders.parse(TWideCharSection.Create(headers));

    request.param := param;
    request.ParamLength := ParamLength;
    request.ParamStream := ParamStream;
    options.AutoDecompress := True;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;

    for i := 0 to SortedServerList.Count - 1 do
    begin
      sh := SortedServerList[i];

      request.url.HostName := THttpString(sh.HostName);
      request.url.port := sh.port;
      request.ClearResponseHeaders;
      request.ClearRedirects;

      try
        t := GetTickCount;
        Result := Self.FetchUnicodeString(request, options, _TimesErrorRetry, pLocation, callback);
        sh.SaveAccess(GetTickCount - t);
        Break;
      except
        if request.RedirectOcuured or (i = SortedServerList.Count - 1) then raise;
      end;
    end;
  finally
    request.Release;
    SortedServerList.Free;
  end;
end;

function TCustomHttpSession.DoPathAndDecode(mhm: TMultiHostManager; const path, method: THttpString;
  const param: RawByteString; const schema: THttpString;
  pHeaders: PFrequentlyUsedHttpRequestHeaders; ParamStream: TStream;
  pOptions: PHttpOptions; pLocation: PHttpString; _TimesErrorRetry: Integer; _ConnectTimeout, _SendTimeout,
  _RecvTimeout: DWORD; callback: THttpProgressEvent): UnicodeString;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
  i: Integer;
  SortedServerList: TObjectListEx<TNetworkHost>;
  sh: TNetworkHost;
  t: DWORD;
begin
  request := THttpRequest.Create;
  SortedServerList := mhm.OptimizeServerHosts;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.FSchema := schema;
    request.url.FPathWithParams := path;
    request.method := method;

    if Assigned(pHeaders) then
      request.headers := pHeaders^;

    request.param := Pointer(param);
    request.ParamLength := Length(param);
    request.ParamStream := ParamStream;
    options.AutoDecompress := True;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;

    for i := 0 to SortedServerList.Count - 1 do
    begin
      sh := SortedServerList[i];

      request.url.HostName := THttpString(sh.HostName);
      request.url.port := sh.port;
      request.ClearResponseHeaders;
      request.ClearRedirects;

      try
        t := GetTickCount;
        Result := Self.FetchUnicodeString(request, options, _TimesErrorRetry, pLocation, callback);
        sh.SaveAccess(GetTickCount - t);
        Break;
      except
        if request.RedirectOcuured or (i = SortedServerList.Count - 1) then raise;
      end;
    end;
  finally
    request.Release;
    SortedServerList.Free;
  end;
end;

function TCustomHttpSession.DoPath_RawBytes(mhm: TMultiHostManager; const path, method: THttpString;
  const param: RawByteString; const schema: THttpString;
  pHeaders: PFrequentlyUsedHttpRequestHeaders; ParamStream: TStream;
  pOptions: PHttpOptions; pLocation: PHttpString; _AutoDecompress: Boolean; _TimesErrorRetry: Integer; _ConnectTimeout,
  _SendTimeout, _RecvTimeout: DWORD; callback: THttpProgressEvent): RawByteString;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
  i: Integer;
  SortedServerList: TObjectListEx<TNetworkHost>;
  sh: TNetworkHost;
  t: DWORD;
begin
  request := THttpRequest.Create;
  SortedServerList := mhm.OptimizeServerHosts;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.FSchema := schema;
    request.url.FPathWithParams := path;
    request.method := method;

    if Assigned(pHeaders) then
      request.headers := pHeaders^;

    request.param := Pointer(param);
    request.ParamLength := Length(param);
    request.ParamStream := ParamStream;
    options.AutoDecompress := _AutoDecompress;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;

    for i := 0 to SortedServerList.Count - 1 do
    begin
      sh := SortedServerList[i];

      request.url.HostName := THttpString(sh.HostName);
      request.url.port := sh.port;
      request.ClearResponseHeaders;
      request.ClearRedirects;

      try
        t := GetTickCount;
        Result := Self.FetchRawBytes(request, options, _TimesErrorRetry, pLocation, callback);
        sh.SaveAccess(GetTickCount - t);
        Break;
      except
        if request.RedirectOcuured or (i = SortedServerList.Count - 1) then raise;
      end;
    end;
  finally
    request.Release;
    SortedServerList.Free;
  end;
end;

function TCustomHttpSession.DoPath_RawBytes(mhm: TMultiHostManager;
  const path, method, schema, referer, headers, ContentType: THttpString;
  param: Pointer; ParamLength: DWORD; ParamStream: TStream; pOptions: PHttpOptions; pLocation: PHttpString;
  _AutoDecompress: Boolean; _TimesErrorRetry: Integer; _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD;
  callback: THttpProgressEvent): RawByteString;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
  i: Integer;
  SortedServerList: TObjectListEx<TNetworkHost>;
  sh: TNetworkHost;
  t: DWORD;
begin
  request := THttpRequest.Create;
  SortedServerList := mhm.OptimizeServerHosts;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.FSchema := schema;
    request.url.FPathWithParams := path;
    request.method := method;
    request.headers.referer := referer;
    request.headers.ContentType := ContentType;

    if headers <> '' then
      request.RequestHeaders.parse(TWideCharSection.Create(headers));

    request.param := param;
    request.ParamLength := ParamLength;
    request.ParamStream := ParamStream;
    options.AutoDecompress := _AutoDecompress;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;

    for i := 0 to SortedServerList.Count - 1 do
    begin
      sh := SortedServerList[i];

      request.url.HostName := THttpString(sh.HostName);
      request.url.port := sh.port;
      request.ClearResponseHeaders;
      request.ClearRedirects;

      try
        t := GetTickCount;
        Result := Self.FetchRawBytes(request, options, _TimesErrorRetry, pLocation, callback);
        sh.SaveAccess(GetTickCount - t);
        Break;
      except
        if request.RedirectOcuured or (i = SortedServerList.Count - 1) then raise;
      end;
    end;
  finally
    request.Release;
    SortedServerList.Free;
  end;
end;

{ THttpThread }

constructor THttpThread.Create(_session: TCustomHttpSession; _request: THttpRequest;
  const _options: TBaseHttpOptions; _content: TStream; _callback: THttpProgressEvent;
  _TimesErrorRetry: Integer);
begin
  _session.AddRef;
  FSession := _session;
  _request.AddRef;
  FRequest := _request;
  FContent := _content;
  FCallback := _callback;
  FOptions := _options;
  FTimesErrorRetry := _TimesErrorRetry;
  FRunning := True;
  ReturnInfo.init;
  inherited Create(False);
end;

destructor THttpThread.Destroy;
begin
  FSession.Release;
  FRequest.Release;
  inherited;
end;

procedure THttpThread.Execute;
begin
  inherited;

  try
    ReturnInfo := FSession.DoRequest(FRequest, FOptions, FContent, FTimesErrorRetry, FCallback);
  except
    on e: Exception do
    begin
      ReturnInfo.error.code := httpRtlException;
      ReturnInfo.error.msg := e.Message;
    end;
  end;

  FRunning := False;
end;

function TCustomHttpSession.DoRawRequest(request: TBaseHttpRequest;
  const headers: TFrequentlyUsedHttpRequestHeaders;
  const options: TBaseHttpOptions; ResponseContent: TStream;
  TimesErrorRetry: Integer; callback: THttpProgressEvent;
  AutoCookie: Boolean): THttpResult;
begin
  Result := Self._DoRawRequest(request, headers, options, ResponseContent,
    TimesErrorRetry, callback, AutoCookie);
end;

function TCustomHttpSession.DoRequest(request: THttpRequest;
  const options: TBaseHttpOptions; ResponseContent: TStream;
  TimesErrorRetry: Integer; callback: THttpProgressEvent): THttpResult;
begin
  Result := Self._DoRequest(request, options, ResponseContent, TimesErrorRetry, callback);
end;

function TCustomHttpSession.DoRequest_AutoThread(request: THttpRequest; const options: TBaseHttpOptions;
  ResponseContent: TStream; TimesErrorRetry: Integer; pLocation : PHttpString;
  callback: THttpProgressEvent): THttpResult;
var
  thread: THttpThread;
  LatestRequest: TBaseHttpRequest;
const
  FUNC_NAMES: array [THttpStep] of string =
    ('连接服务器', '发送请求头', '发送请求数据', '读取响应头', '读取响应数据');
begin
  if Self.Async and Assigned(Application.MainForm) and RunningInMainThread then
  begin
    thread := THttpThread.Create(Self, request, options, ResponseContent, callback, TimesErrorRetry);

    while thread.Running do
      Application.HandleMessage;

    thread.WaitFor;
    Result := thread.ReturnInfo;
    thread.Free;
  end
  else
    Result := Self.DoRequest(request, options, ResponseContent, TimesErrorRetry, callback);

  if Result.error.code = httperrAborted then
    Exit;

  if Result.error.isSuccess then
  begin
    if Assigned(pLocation) then
    begin
      LatestRequest := request.GetLatestRequest;

      if request.options.AutoRedirect then
        pLocation^ := LatestRequest.url.GetUrl
      else
        pLocation^ := LatestRequest.ResponseHeaders.location;
    end;
  end
  else
    raise EHttpException.Create(Result.error, FUNC_NAMES[Result.CurrentStep]);
end;

function TCustomHttpSession.DoUrl(const url, method, referer, headers, ContentType: THttpString;
  param: Pointer; ParamLength: DWORD; ParamStream, content: TStream; pOptions: PHttpOptions;
  pLocation: PHttpString; _AutoDecompress: Boolean; _TimesErrorRetry: Integer;
  _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD; callback: THttpProgressEvent): THttpResult;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
begin
  request := THttpRequest.Create;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.parse(url);
    request.method := method;
    request.headers.referer := referer;
    request.headers.ContentType := ContentType;

    if headers <> '' then
      request.RequestHeaders.parse(TWideCharSection.Create(headers));

    request.param := param;
    request.ParamLength := ParamLength;
    request.ParamStream := ParamStream;
    options.AutoDecompress := _AutoDecompress;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;
    Result := Self.DoRequest_AutoThread(request, options, content, _TimesErrorRetry, pLocation, callback);
  finally
    request.Release;
  end;
end;

function TCustomHttpSession.DoUrlAndDecode(const url, method: THttpString;
  const headers: TFrequentlyUsedHttpRequestHeaders;
  const param: RawByteString; ParamStream: TStream;
  pOptions: PHttpOptions; pLocation: PHttpString;
  _TimesErrorRetry: Integer; _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD;
  callback: THttpProgressEvent): UnicodeString;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
begin
  request := THttpRequest.Create;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.parse(url);
    request.method := method;
    request.headers := headers;
    request.param := Pointer(param);
    request.ParamLength := Length(param);
    request.ParamStream := ParamStream;
    options.AutoDecompress := True;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;
    Result := Self.FetchUnicodeString(request, options, _TimesErrorRetry, pLocation, callback);
  finally
    request.Release;
  end;
end;

function TCustomHttpSession.DoUrl(const url, method: THttpString; const headers: TFrequentlyUsedHttpRequestHeaders;
  const param: RawByteString; ParamStream, content: TStream; pOptions: PHttpOptions; pLocation: PHttpString;
  _AutoDecompress: Boolean; _TimesErrorRetry: Integer; _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD;
  callback: THttpProgressEvent): THttpResult;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
begin
  request := THttpRequest.Create;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.parse(url);
    request.method := method;
    request.headers := headers;
    request.param := Pointer(param);
    request.ParamLength := Length(param);
    request.ParamStream := ParamStream;
    options.AutoDecompress := _AutoDecompress;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;
    Result := Self.DoRequest_AutoThread(request, options, content, _TimesErrorRetry, pLocation, callback);
  finally
    request.Release;
  end;
end;

function TCustomHttpSession.DoUrlAndDecode(const url, method, referer,
  headers, ContentType: THttpString; param: Pointer; ParamLength: DWORD;
  ParamStream: TStream; pOptions: PHttpOptions; pLocation: PHttpString;
   _TimesErrorRetry: Integer; _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD;
  callback: THttpProgressEvent): UnicodeString;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
begin
  request := THttpRequest.Create;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.parse(url);
    request.method := method;
    request.headers.referer := referer;
    request.headers.ContentType := ContentType;
    if headers <> '' then
      request.RequestHeaders.parse(TWideCharSection.Create(headers));
    request.param := param;
    request.ParamLength := ParamLength;
    request.ParamStream := ParamStream;
    options.AutoDecompress := True;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;
    Result := Self.FetchUnicodeString(request, options, _TimesErrorRetry, pLocation, callback);
  finally
    request.Release;
  end;
end;

function TCustomHttpSession.DoUrl_RawBytes(const url, method: THttpString;
  const headers: TFrequentlyUsedHttpRequestHeaders;
  const param: RawByteString; ParamStream: TStream; pOptions: PHttpOptions; pLocation: PHttpString;
  _AutoDecompress: Boolean; _TimesErrorRetry: Integer; _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD;
  callback: THttpProgressEvent): RawByteString;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
begin
  request := THttpRequest.Create;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.parse(url);
    request.method := method;
    request.headers := headers;
    request.param := Pointer(param);
    request.ParamLength := Length(param);
    request.ParamStream := ParamStream;
    options.AutoDecompress := _AutoDecompress;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;
    Result := Self.FetchRawBytes(request, options, _TimesErrorRetry, pLocation, callback);
  finally
    request.Release;
  end;
end;

function TCustomHttpSession.DoUrl_RawBytes(const url, method, referer,
  headers, ContentType: THttpString; param: Pointer; ParamLength: DWORD;
  ParamStream: TStream; pOptions: PHttpOptions; pLocation: PHttpString;
  _AutoDecompress: Boolean; _TimesErrorRetry: Integer;
  _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD;
  callback: THttpProgressEvent): RawByteString;
var
  request: THttpRequest;
  options: TBaseHttpOptions;
begin
  request := THttpRequest.Create;

  try
    if Assigned(pOptions) then
      request.options := pOptions^;

    request.url.parse(url);
    request.method := method;
    request.headers.referer := referer;
    request.headers.ContentType := ContentType;
    if headers <> '' then
      request.RequestHeaders.parse(TWideCharSection.Create(headers));
    request.param := param;
    request.ParamLength := ParamLength;
    request.ParamStream := ParamStream;
    options.AutoDecompress := _AutoDecompress;
    options.ConnectTimeout := _ConnectTimeout;
    options.SendTimeout := _SendTimeout;
    options.RecvTimeout := _RecvTimeout;
    Result := Self.FetchRawBytes(request, options, _TimesErrorRetry, pLocation, callback);
  finally
    request.Release;
  end;
end;

function TCustomHttpSession.FetchRawBytes(request: THttpRequest; const options: TBaseHttpOptions;
  TimesErrorRetry: Integer; pLocation : PHttpString; callback: THttpProgressEvent): RawByteString;
var
  ResponseContent: TMemoryStream;
  res: THttpResult;
begin
  ResponseContent := TMemoryStream.Create;

  try
    res := Self.DoRequest_AutoThread(request, options, ResponseContent, TimesErrorRetry, pLocation, callback);

    if res.isSuccess then
    begin
      SetLength(Result, ResponseContent.Size);
      Move(ResponseContent.Memory^, Pointer(Result)^, Length(Result));
    end
    else Result := '';
  finally
    ResponseContent.Free;
  end;
end;

function TCustomHttpSession.FetchUnicodeString(request: THttpRequest; const options: TBaseHttpOptions;
  TimesErrorRetry: Integer; pLocation : PHttpString; callback: THttpProgressEvent): UnicodeString;
var
  res: THttpResult;
  ResponseContent: TMemoryStream;
  CodePage: Integer;
begin
  Result := '';
  ResponseContent := TMemoryStream.Create;

  try
    res := Self.DoRequest_AutoThread(request, options, ResponseContent, TimesErrorRetry, pLocation, callback);

    if res.isSuccess then
    begin
      if ResponseContent.Size > 0 then
      begin
        ResponseContent.Seek(0, soFromBeginning);
        Result := WinHttpDecodeResponseText(request.GetLatestRequest, ResponseContent, ResponseContent.Size, CodePage);
      end;
    end
    else begin

    end;
  finally
    ResponseContent.Free;
  end;
end;

function TCustomHttpSession.get(const url, referer: THttpString; pCurrentLocation: PHttpString): RawByteString;
begin
  Result := Self.DoUrl_RawBytes(url, 'GET', referer, '', '', nil, 0, nil, nil, pCurrentLocation);
end;

function TCustomHttpSession.GetAndDecode(const url, referer: THttpString; pCurrentLocation: PHttpString): UnicodeString;
begin
  Result := Self.DoUrlAndDecode(url, 'GET', referer, '', '', nil, 0, nil, nil, pCurrentLocation);
end;

function TCustomHttpSession.GetAndDecode(mhm: TMultiHostManager; const path, schema: THttpString;
  pHeaders: PFrequentlyUsedHttpRequestHeaders; ParamStream: TStream; pOptions: PHttpOptions; pLocation: PHttpString;
  _TimesErrorRetry: Integer; _ConnectTimeout, _SendTimeout, _RecvTimeout: DWORD;
  callback: THttpProgressEvent): UnicodeString;
begin
  Result := DoPathAndDecode(mhm, path, 'GET', '', schema, pHeaders, ParamStream, pOptions,
    pLocation, _TimesErrorRetry, _ConnectTimeout, _SendTimeout, _RecvTimeout, callback);
end;

function TCustomHttpSession.GetProxy: THttpProxy;
begin
  Result := FProxy;
end;

procedure TCustomHttpSession.GetWithoutRedirect(const url: THttpString; content: TStream; const referer: THttpString;
  pRedir: PHttpString);
begin
  Self.DoUrl(url, 'GET', referer, '', '', nil, 0, nil, content, @g_NoRedirectOptions, pRedir);
end;

function TCustomHttpSession.GetWithoutRedirect(const url, referer: THttpString; pRedir: PHttpString): RawByteString;
begin
  Result := Self.DoUrl_RawBytes(url, 'GET', referer, '', '', nil, 0, nil, @g_NoRedirectOptions, pRedir);
end;

function TCustomHttpSession.GetWithoutRedirectAndDecode(const url,
  referer: THttpString; pRedir: PHttpString): UnicodeString;
begin
  Result := Self.DoUrlAndDecode(url, 'GET', referer, '', '', nil, 0, nil, @g_NoRedirectOptions, pRedir);
end;

procedure TCustomHttpSession.get(const url: THttpString; content: TStream;
  const referer: THttpString; pCurrentLocation: PHttpString);
begin
  Self.DoUrl(url, 'GET', referer, '', '', nil, 0, nil, content, nil, pCurrentLocation);
end;

procedure TCustomHttpSession.ParseSetCookie(const SetCookie, host: THttpString);
begin
  FCookieManager.ParseResponseCookie(SetCookie, host);
end;

procedure TCustomHttpSession.post(const url, referer: THttpString; param,
  content: TStream; const ParamType: THttpString;
  pCurrentLocation: PHttpString);
begin
  Self.DoUrl(url, 'POST', referer, '', ParamType, nil, 0, param, content, nil, pCurrentLocation);
end;

function TCustomHttpSession.post(const url, referer: THttpString;
  param: TStream; const ParamType: THttpString;
  pCurrentLocation: PHttpString): RawByteString;
begin
  Result := Self.DoUrl_RawBytes(url, 'POST', referer, '', ParamType, nil, 0, param, nil, pCurrentLocation);
end;

procedure TCustomHttpSession.post(const url, referer: THttpString;
  const param: RawByteString; content: TStream;
  const ParamType: THttpString; pCurrentLocation: PHttpString);
begin
  Self.DoUrl(url, 'POST', referer, '', ParamType, PAnsiChar(param), Length(param), nil, content, nil, pCurrentLocation);
end;

function TCustomHttpSession.post(const url, referer: THttpString;
  const param: RawByteString; const ParamType: THttpString;
  pCurrentLocation: PHttpString): RawByteString;
begin
  Result := Self.DoUrl_RawBytes(url, 'POST', referer, '', ParamType, PAnsiChar(param), Length(param), nil, nil, pCurrentLocation);
end;

function TCustomHttpSession.PostAndDecode(const url, referer: THttpString;
  const param: RawByteString; const ParamType: THttpString;
  pCurrentLocation: PHttpString): UnicodeString;
begin
  Result := Self.DoUrlAndDecode(url, 'POST', referer, '', ParamType, Pointer(param), Length(param), nil, nil, pCurrentLocation);
end;

function TCustomHttpSession.PostAndDecode(const url, referer: THttpString;
  param: TStream; const ParamType: THttpString;
  pCurrentLocation: PHttpString): UnicodeString;
begin
  Result := Self.DoUrlAndDecode(url, 'POST', referer, '', ParamType, nil, 0, param, nil, pCurrentLocation);
end;

procedure TCustomHttpSession.PostWithoutRedirect(const url,
  referer: THttpString; param, content: TStream;
  const ParamType: THttpString; pLocation: PHttpString);
begin
  Self.DoUrl(url, 'POST', referer, '', ParamType, nil, 0, param, content, @g_NoRedirectOptions, pLocation);
end;

function TCustomHttpSession.PostWithoutRedirect(const url,
  referer: THttpString; const param: RawByteString;
  const ParamType: THttpString; pLocation: PHttpString): RawByteString;
begin
  Result := Self.DoUrl_RawBytes(url, 'POST', referer, '', ParamType, PAnsiChar(param), Length(param), nil, @g_NoRedirectOptions, pLocation);
end;

procedure TCustomHttpSession.PostWithoutRedirect(const url,
  referer: THttpString; const param: RawByteString; content: TStream;
  const ParamType: THttpString; pLocation: PHttpString);
begin
  Self.DoUrl(url, 'POST', referer, '', ParamType, PAnsiChar(param), Length(param), nil, content, @g_NoRedirectOptions, pLocation);
end;

function TCustomHttpSession.PostWithoutRedirectAndDecode(const url,
  referer: THttpString; param: TStream; const ParamType: THttpString;
  pLocation: PHttpString): UnicodeString;
begin
  Result := Self.DoUrlAndDecode(url, 'POST', referer, '', ParamType, nil, 0, param, @g_NoRedirectOptions, pLocation);
end;

function TCustomHttpSession.SendRequestAndReadHeaders(
  request: TBaseHttpRequest;
  const headers: TFrequentlyUsedHttpRequestHeaders;
  const BaseOptions: TBaseHttpOptions;
  TimesErrorRetry: Integer;
  callback: THttpProgressEvent;
  var IOHandler: TCustomHttpIOHandler): THttpResult;
var
  i: Integer;
begin
  Result.init;

  for i := 0 to TimesErrorRetry do
  begin
    request.ClearResponseHeaders;

    Result := _SendRequestAndReadHeaders(request, headers, BaseOptions, callback, IOHandler);

    if Result.isSuccess then
      Break;
  end;
end;

procedure TCustomHttpSession.SetCookieManager(const Value: TCookieManager);
begin
  Value.AddRef;
  FCookieManager.Release;
  FCookieManager := Value;
end;

procedure TCustomHttpSession.SetProxy(const HostName: RawByteString; port: Word; const username,
  password: RawByteString; bypass: RawByteString);
begin
  FProxy.HostName := HostName;
  FProxy.port := port;
  FProxy.username := username;
  FProxy.password := password;
  FProxy.bypass := bypass;
end;

procedure TCustomHttpSession.SetProxy(const proxy: THttpProxy);
begin
  FProxy := proxy;
end;

procedure TCustomHttpSession.upload(const url, referer: THttpString;
  const ParamNames, ParamValues, FileKeys, FileNames,
  MimeTypes: array of RawByteString; const FileDatas: array of TStream;
  content: TStream; const charset: THttpString);
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), ParamNames, ParamValues, FileKeys, FileNames, MimeTypes, FileDatas, PostParam);

    PostParam.Position := 0;

    Self.DoUrl(url, 'POST', referer, '', ContentType, nil, 0, PostParam, content);

  finally
    PostParam.Free;
  end;
end;

function TCustomHttpSession.upload(const url, referer: THttpString;
  const ParamNames, ParamValues, FileKeys, FileNames,
  MimeTypes: array of RawByteString; FileDatas: array of TStream;
  const charset: THttpString): RawByteString;
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), FileKeys, FileNames, MimeTypes, ParamNames, ParamValues, FileDatas, PostParam);
    PostParam.Position := 0;
    Result := Self.DoUrl_RawBytes(url, 'POST', referer, '', ContentType, nil, 0, PostParam);

  finally
    PostParam.Free;
  end;
end;

function TCustomHttpSession.upload2(const url, referer: THttpString;
  ParamNames, ParamValues: TRawByteStrings; const FileKeys, FileNames,
  MimeTypes: array of RawByteString; const FileDatas: array of TStream;
  const charset: THttpString): RawByteString;
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), ParamNames, ParamValues, FileKeys, FileNames, MimeTypes, FileDatas, PostParam);

    PostParam.Position := 0;

    Result := Self.DoUrl_RawBytes(url, 'POST', referer, '', ContentType, nil, 0, PostParam);

  finally
    PostParam.Free;
  end;
end;

function TCustomHttpSession.UploadAndDecode(const url,
  referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames,
  MimeTypes: array of RawByteString; const FileDatas: array of TStream;
  const charset: THttpString; callback: THttpProgressEvent): UnicodeString;
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), ParamNames, ParamValues, FileKeys, FileNames, MimeTypes, FileDatas, PostParam);

    PostParam.Position := 0;

    Result := Self.DoUrlAndDecode(url, 'POST', referer, '', ContentType, nil, 0, PostParam, nil, nil, 0, 0, 0, 0, callback);

  finally
    PostParam.Free;
  end;
end;

function TCustomHttpSession.UploadAndDecode2(const url, referer: THttpString;
  ParamNames, ParamValues: TRawByteStrings; const FileKeys, FileNames,
  MimeTypes: array of RawByteString; const FileDatas: array of TStream;
  const charset: THttpString): UnicodeString;
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), ParamNames, ParamValues, FileKeys, FileNames, MimeTypes, FileDatas, PostParam);

    PostParam.Position := 0;

    Result := Self.DoUrlAndDecode(url, 'POST', referer, '', ContentType, nil, 0, PostParam);

  finally
    PostParam.Free;
  end;
end;

function TCustomHttpSession.UploadWithoutRedirect(const url,
  referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames,
  MimeTypes: array of RawByteString; FileDatas: array of TStream;
  const charset: THttpString; pLocation: PHttpString): RawByteString;
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), FileKeys, FileNames, MimeTypes, ParamNames, ParamValues, FileDatas, PostParam);

    PostParam.Position := 0;

    Result := Self.DoUrl_RawBytes(url, 'POST', referer, '', ContentType, nil, 0, PostParam, @g_NoRedirectOptions, pLocation);

  finally
    PostParam.Free;
  end;
end;

procedure TCustomHttpSession.UploadWithoutRedirect(const url,
  referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames,
  MimeTypes: array of RawByteString; const FileDatas: array of TStream;
  content: TStream; const charset: THttpString; pLocation: PHttpString);
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), ParamNames, ParamValues, FileKeys, FileNames, MimeTypes, FileDatas, PostParam);

    PostParam.Position := 0;

    Self.DoUrl(url, 'POST', referer, '', ContentType, nil, 0, PostParam, content, @g_NoRedirectOptions, pLocation);

  finally
    PostParam.Free;
  end;
end;

function TCustomHttpSession.UploadWithoutRedirect2(const url,
  referer: THttpString; ParamNames, ParamValues: TRawByteStrings;
  const FileKeys, FileNames, MimeTypes: array of RawByteString;
  const FileDatas: array of TStream; const charset: THttpString;
  pLocation: PHttpString): RawByteString;
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), ParamNames, ParamValues, FileKeys, FileNames, MimeTypes, FileDatas, PostParam);

    PostParam.Position := 0;

    Result := Self.DoUrl_RawBytes(url, 'POST', referer, '', ContentType, nil, 0, PostParam, @g_NoRedirectOptions, pLocation);

  finally
    PostParam.Free;
  end;
end;

function TCustomHttpSession.UploadWithoutRedirectAndDecode(const url,
  referer: THttpString; const ParamNames, ParamValues, FileKeys, FileNames,
  MimeTypes: array of RawByteString; const FileDatas: array of TStream;
  const charset: THttpString; pLocation: PHttpString): UnicodeString;
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), ParamNames, ParamValues, FileKeys, FileNames, MimeTypes, FileDatas, PostParam);

    PostParam.Position := 0;

    Result := Self.DoUrlAndDecode(url, 'POST', referer, '', ContentType, nil, 0, PostParam);

  finally
    PostParam.Free;
  end;
end;

function TCustomHttpSession.UploadWithoutRedirectAndDecode2(const url,
  referer: THttpString; ParamNames, ParamValues: TRawByteStrings;
  const FileKeys, FileNames, MimeTypes: array of RawByteString;
  const FileDatas: array of TStream; const charset: THttpString;
  pLocation: PHttpString): UnicodeString;
var
  PostParam: TMemoryStream;
  boundary, ContentType: THttpString;
begin
  boundary := RandomAlphaDigitUStr(38, [chAlphaLowerCase]);
  PostParam := TMemoryStream.Create;

  if charset = '' then ContentType := 'multipart/form-data; boundary=' + boundary
  else ContentType := 'multipart/form-data; charset=' + charset + '; boundary=' + boundary;

  try
    HttpFillUploadStream(RawByteString(boundary), ParamNames, ParamValues, FileKeys, FileNames, MimeTypes, FileDatas, PostParam);

    PostParam.Position := 0;

    Result := Self.DoUrlAndDecode(url, 'POST', referer, '', ContentType, nil, 0, PostParam, @g_NoRedirectOptions, pLocation);

  finally
    PostParam.Free;
  end;
end;

function TCustomHttpSession.PostWithoutRedirectAndDecode(const url,
  referer: THttpString; const param: RawByteString;
  const ParamType: THttpString; pLocation: PHttpString): UnicodeString;
begin
  Result := Self.DoUrlAndDecode(url, 'POST', referer, '', ParamType, Pointer(param), Length(param),
    nil, @g_NoRedirectOptions, pLocation);
end;

function TCustomHttpSession._SendRequestAndReadHeaders(
  request: TBaseHttpRequest;
  const headers: TFrequentlyUsedHttpRequestHeaders;
  const BaseOptions: TBaseHttpOptions;
  callback: THttpProgressEvent;
  var IOHandler: TCustomHttpIOHandler): THttpResult;
var
  ok: Boolean;
  comerr: TCommunicationError;
begin
  ok := False;
  Result.error.clear;
  Result.CurrentStep := hrsConnect;
  IOHandler := CreateIOHandler(request, BaseOptions, headers, FProxy, callback);
  comerr.init;
  try
    IOHandler.connect(comerr);

    if not comerr.isSuccess then
    begin
      Result.error.fromCommunicateError(hrsConnect, comerr);
      Exit;
    end;

    Result.CurrentStep := hrsSendHeaders;
    IOHandler.WriteHeaders(Result.error);

    if Result.isSuccess then
    begin
      Result.CurrentStep := hrsSendData;
      IOHandler.WriteBody(Result.error);
    end;

    if Result.isSuccess then
    begin
      Result.CurrentStep := hrsReceiveHeaders;
      IOHandler.ReadHeaders(Result.error);
    end;

    if Result.isSuccess then
      ok := True;
  finally
    if not ok then
    begin
      IOHandler.Free;
      IOHandler := nil;
    end;
  end;
end;

{ TBaseHttpRequest }

function TBaseHttpRequest.GetRequestHeaders: THttpRequestHeaders;
begin
  if not Assigned(FRequestHeaders) then
    FRequestHeaders := THttpRequestHeaders.Create;

  Result := FRequestHeaders;
end;

function TBaseHttpRequest.GetResponseHeaders: THttpResponseHeaders;
begin
  if not Assigned(FResponseHeaders) then
    FResponseHeaders := THttpResponseHeaders.Create;

  Result := FResponseHeaders;
end;

procedure HttpStringAppendAndMoveToEnd(var s: PHttpChar; const tail: THttpString);
var
  L: Integer;
begin
  L := Length(tail);
  Move(Pointer(tail)^, s^, L * SizeOf(THttpChar));
  Inc(s, L);
end;

function TBaseHttpRequest.MakeRequestHeader(const headers: TFrequentlyUsedHttpRequestHeaders;
  IncludeRequestLine: Boolean; pInternalHeaders: PInternalHttpRequestHeaders): THttpString;
const
  SHttpVer: THttpString = 'HTTP/1.1';
var
  header: THttpHeader;
  _host, _UserAgent, _Authorization, _UrlPath, _ContentLength, _ContentType, _referer, _cookie: THttpString;
  _connection, _accept, _XRequestedWith, _AcceptEncoding, _AcceptLanguage, _AcceptCharset, _origin: THttpString;
  I, TotalInputLength, RequestHeaderLen: Integer;
  pRequestHeader: PHttpChar;

  procedure AccumHeaderLen(const HeaderName, HeaderValue: THttpString);
  begin
    if HeaderValue <> '' then
      Inc(RequestHeaderLen, Length(HeaderName) + Length(HeaderValue) + 4);
  end;

  procedure AppendHeader(const HeaderName, HeaderValue: THttpString);
  begin
    if HeaderValue <> '' then
    begin
      HttpStringAppendAndMoveToEnd(pRequestHeader, HeaderName);
      HttpStringAppendAndMoveToEnd(pRequestHeader, ': ');
      HttpStringAppendAndMoveToEnd(pRequestHeader, HeaderValue);
      HttpStringAppendAndMoveToEnd(pRequestHeader, #13#10);
    end;
  end;
begin
  if Assigned(ParamStream) then
    TotalInputLength := ParamLength + ParamStream.Size
  else
    TotalInputLength := ParamLength;

  if Assigned(FRequestHeaders) then
  begin
    _UserAgent := FRequestHeaders.UserAgent;
    _host := FRequestHeaders.host;
    _referer := FRequestHeaders.Referer;
    _origin := FRequestHeaders.origin;
    _ContentType := FRequestHeaders.ContentType;
    _Authorization := FRequestHeaders.authorization;
    _ContentLength := FRequestHeaders.ContentLength;
    _cookie := FRequestHeaders.cookie;
    _connection := FRequestHeaders.Connection;
    _accept := FRequestHeaders.accept;
    _XRequestedWith := FRequestHeaders.XRequestedWith;
    _AcceptEncoding := FRequestHeaders.AcceptEncoding;
    _AcceptLanguage := FRequestHeaders.AcceptLanguage;
    _AcceptCharset := FRequestHeaders.AcceptCharset;
  end
  else
  begin
    _UserAgent := '';
    _host := '';
    _referer := '';
    _origin := '';
    _ContentType := '';
    _Authorization := '';
    _ContentLength := '';
    _cookie := '';
    _connection := '';
    _accept := '';
    _XRequestedWith := '';
    _AcceptEncoding := '';
    _AcceptLanguage := '';
    _AcceptCharset := '';
  end;

  if _UserAgent = '' then
  begin
    _UserAgent := headers.UserAgent;
    if _UserAgent = '' then
      _UserAgent := CHROME_WIN32_USER_AGENT;
  end
  else
    _UserAgent := '';

  if _host = '' then
    _host := Self.url.host
  else
    _host := '';

  if _referer = '' then
    _referer := headers.referer
  else
    _referer := '';

  if _origin = '' then
    _origin := headers.origin
  else
    _origin := '';

  if _cookie = '' then
    _cookie := headers.cookie
  else
    _cookie := '';

  if _ContentType = '' then
  begin
    _ContentType := headers.ContentType;

    if (_ContentType = '') and (TotalInputLength > 0) then
      _ContentType := 'application/x-www-form-urlencoded';
  end
  else
    _ContentType := '';

  if _connection = '' then
  begin
    _connection := headers.connection;

    if _connection = '' then
    begin
      if g_HttpKeepAlive then
        _connection := 'Keep-Alive'
      else
        _connection := 'Close';
    end;
  end
  else
    _connection := '';

  if _accept = '' then
  begin
    _accept := headers.accept;

    if _accept = '' then
      _accept := 'text/html,application/xhtml+xml,*/*';
  end
  else
    _accept := '';

  if _XRequestedWith = '' then
    _XRequestedWith := headers.XRequestedWith
  else
    _XRequestedWith := '';

  if _AcceptEncoding = '' then
  begin
    _AcceptEncoding := headers.AcceptEncoding;

    if _AcceptEncoding = '' then
      _AcceptEncoding := 'gzip,deflate';
  end
  else
    _AcceptEncoding := '';

  if _AcceptLanguage = '' then
  begin
    _AcceptLanguage := headers.AcceptLanguage;

    if _AcceptLanguage = '' then
      _AcceptLanguage := 'zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3';
  end
  else
    _AcceptLanguage := '';

  if _AcceptCharset = '' then
  begin
    _AcceptCharset := headers.AcceptCharset;

    if _AcceptCharset = '' then
      _AcceptCharset := 'utf-8, iso-8859-1, utf-16, *;q=0.7';
  end
  else
    _AcceptCharset := '';

  if _Authorization = '' then
  begin
    if url.username <> '' then
      _Authorization := 'Basic ' + THttpString(Base64Encode(UTF8Encode(url.username))) + ':' + url.password;
  end
  else
    _Authorization := '';

  if _ContentLength = '' then
  begin
    if (TotalInputLength > 0) or (UStrSameText(method, 'POST')) then
      _ContentLength := IntToUStr(TotalInputLength);
  end
  else
    _ContentLength := '';

  if url.PathWithParams = '' then
    _UrlPath := '/'
  else
    _UrlPath := url.PathWithParams;

  if IncludeRequestLine then
    RequestHeaderLen := Length(method) + 1 + Length(_UrlPath) + 1 + Length(SHttpVer) + 2
  else
    RequestHeaderLen := 0;

  AccumHeaderLen('Host', _host);
  AccumHeaderLen('User-Agent', _UserAgent);
  AccumHeaderLen('Referer', _referer);
  AccumHeaderLen('Origin', _origin);
  AccumHeaderLen('X-Requested-With', _XRequestedWith);
  AccumHeaderLen('Accept', _accept);
  AccumHeaderLen('Accept-Language', _AcceptLanguage);
  AccumHeaderLen('Accept-Encoding', _AcceptEncoding);
  AccumHeaderLen('Accept-Charset', _AcceptCharset);
  AccumHeaderLen('Content-Type', _ContentType);
  AccumHeaderLen('Authorization', _Authorization);
  AccumHeaderLen('Content-Length', _ContentLength);
  AccumHeaderLen('Cookie', _cookie);
  AccumHeaderLen('Connection', _connection);

  if Assigned(pInternalHeaders) then
  begin
    AccumHeaderLen('Proxy-Authorization', pInternalHeaders.ProxyAuthorization);
    AccumHeaderLen('Proxy-Connection', pInternalHeaders.ProxyConnection);
  end;

  if Assigned(FRequestHeaders) then
  begin
    for I := 0 to FRequestHeaders.FItems.Count - 1 do
    begin
      header := FRequestHeaders.FItems[I];
      AccumHeaderLen(header.name, header.value);
    end;
  end;

  SetLength(Result, RequestHeaderLen + 2);
  pRequestHeader := PHttpChar(Result);

  if IncludeRequestLine then
  begin
    HttpStringAppendAndMoveToEnd(pRequestHeader, method);
    pRequestHeader^ := #32;
    Inc(pRequestHeader);
    HttpStringAppendAndMoveToEnd(pRequestHeader, _UrlPath);
    pRequestHeader^ := #32;
    Inc(pRequestHeader);
    HttpStringAppendAndMoveToEnd(pRequestHeader, SHttpVer);
    HttpStringAppendAndMoveToEnd(pRequestHeader, #13#10);
  end;

  AppendHeader('Host', _host);
  AppendHeader('User-Agent', _UserAgent);
  AppendHeader('Referer', _referer);
  AppendHeader('Origin', _origin);
  AppendHeader('X-Requested-With', _XRequestedWith);
  AppendHeader('Accept', _accept);
  AppendHeader('Accept-Language', _AcceptLanguage);
  AppendHeader('Accept-Encoding', _AcceptEncoding);
  AppendHeader('Accept-Charset', _AcceptCharset);
  AppendHeader('Content-Type', _ContentType);
  AppendHeader('Authorization', _Authorization);
  AppendHeader('Content-Length', _ContentLength);
  AppendHeader('Cookie', _cookie);
  AppendHeader('Connection', _connection);

  if Assigned(pInternalHeaders) then
  begin
    AppendHeader('Proxy-Authorization', pInternalHeaders.ProxyAuthorization);
    AppendHeader('Proxy-Connection', pInternalHeaders.ProxyConnection);
  end;

  if Assigned(FRequestHeaders) then
  begin
    for I := 0 to FRequestHeaders.FItems.Count - 1 do
    begin
      header := FRequestHeaders.FItems[I];
      AppendHeader(header.name, header.value);
    end;
  end;

  HttpStringAppendAndMoveToEnd(pRequestHeader, #13#10);
end;

{ EInvalidURI }

constructor EInvalidURI.Create(_url: THttpString);
begin
  FUrl := _url;
  inherited Create('"' + string(_url) + '"' + ' is not a valid url !');
end;

function TUrl.GetFileName: THttpString;
var
  pwc, bp: PHttpChar;
begin
  Result := '';

  if FPathWithParams <> '' then
  begin
    pwc := PWideChar(FPathWithParams);
    bp := nil;

    if Assigned(pwc) then
    begin
      while (pwc^ <> #0) and (pwc^ <> '?') and (pwc^ <> '#') do
      begin
        if pwc^ = '/' then
          bp := pwc;
        Inc(pwc);
      end;

      SetUString(Result, bp + 1, pwc);
    end;
  end;
end;

function TUrl.GetHost: THttpString;
begin
  Result := FHostName;

  if Result <> '' then
  begin
    if UStrAsciiICompare(FSchema, 'https') = 0 then
    begin
      if (FPort <> PORT_HTTPS) and (FPort <> 0) then
        Result := Result + ':' + IntToUStr(FPort);
    end
    else if UStrAsciiICompare(FSchema, 'http') = 0 then
    begin
      if (FPort <> PORT_HTTP) and (FPort <> 0) then
        Result := Result + ':' + IntToUStr(FPort);
    end
    else if FPort <> 0 then
      Result := Result + ':' + IntToUStr(FPort);
  end;
end;

function TUrl.GetPathWithParams: THttpString;
begin
  if FPathWithParams = '' then
    Result := '/'
  else
    Result := FPathWithParams;
end;

function TUrl.GetPort: Word;
begin
  if FPort = 0 then
  begin
    if UStrAsciiICompare('http', schema) = 0 then
      Result := PORT_HTTP
    else if UStrAsciiICompare('https', schema) = 0 then
      Result := PORT_HTTPS
    else
      Result := 0;
  end
  else
    Result := FPort;
end;

function TUrl.GetSchema: THttpString;
begin
  if FSchema = '' then Result := 'http'
  else Result := FSchema;
end;

function TUrl.GetUrl: THttpString;
begin
  if FSchema <> '' then
    Result := FSchema + '://' + GetHost + FPathWithParams
  else
    Result := GetHost + FPathWithParams;
end;

procedure TUrl.parse(const value: THttpString);
var
  schema_begin, schema_end, host_begin, host_end, port_begin, port_end: PHttpChar;
  username_begin, username_end, password_begin, password_end, path_begin, path_end: PHttpChar;
begin
  if HttpParseURIW(PHttpChar(value), FPort, schema_begin, schema_end, host_begin, host_end, port_begin, port_end,
    username_begin, username_end, password_begin, password_end, path_begin, path_end) then
  begin
    SetUString(FSchema, schema_begin, schema_end);
    SetUString(FHostName, host_begin, host_end);
    SetUString(FUsername, username_begin, username_end);
    SetUString(FPassword, password_begin, password_end);
    SetUString(FPathWithParams, path_begin, path_end);
  end
  else
    raise EInvalidURI.Create(value);
end;

function TUrl.SameExceptSchema(const other: TUrl): Boolean;
begin
  Result := not UStrSameText(Self.schema, other.schema)
    and UStrSameText(Self.host, other.host)
    and UStrSameText(Self.PathWithParams, other.PathWithParams)
end;

{ TCustomHttpConnection }

constructor TCustomHttpConnection.Create(const _HostName: THttpString; _port: Word;
  const _proxy: THttpProxy; _IsHttps: Boolean);
begin
  inherited Create;
  FProxy := _proxy;
  FHostName := _HostName;
  FPort := _port;
  FIsHttps := _IsHttps;
end;

function TCustomHttpConnection.match(const _HostName: THttpString; _port: Word;
  const _proxy: THttpProxy; _IsHttps: Boolean): Boolean;
var
  IsSameProxy: Boolean;
  IsSameHost: Boolean;
begin
  if _IsHttps <> FIsHttps then Result := False
  else begin
    if (FProxy.HostName = '') and (_proxy.HostName = '') then
      IsSameProxy := True
    else
      IsSameProxy := RBStrSameText(FProxy.HostName, _proxy.HostName) and (FProxy.port = _proxy.port);

    IsSameHost := UStrSameText(_HostName, FHostName) and (FPort = _port);

    if not FIsHttps and (FProxy.HostName <> '') and IsSameProxy then
      Result := True
    else
      Result := IsSameProxy and IsSameHost;
  end;
end;

{ THttpRequest }

destructor THttpRequest.Destroy;
begin
  FRedirctRequests.Free;
  inherited;
end;

function THttpRequest.GetLatestRequest: TBaseHttpRequest;
begin
  if RedirectOcuured then
    Result := FRedirctRequests[FRedirctRequests.Count - 1]
  else
    Result := Self;
end;

function THttpRequest.GetRedirctRequests: TObjectListEx<TBaseHttpRequest>;
begin
  if not Assigned(FRedirctRequests) then
    FRedirctRequests := TObjectListEx<TBaseHttpRequest>.Create;

  Result := FRedirctRequests;
end;

function THttpRequest.RedirectOcuured: Boolean;
begin
  Result := Assigned(FRedirctRequests) and (FRedirctRequests.Count > 0);
end;

procedure THttpRequest.ClearRedirects;
begin
  if Assigned(FRedirctRequests) then
    FRedirctRequests.Clear;
end;

constructor THttpRequest.Create;
begin
  inherited Create;
  options.AutoCookie := True;
  options.AutoRedirect := True;
  options.AutoSchemaSwitching := True;
end;

{ THttpResult }

procedure THttpResult.init;
begin
  CurrentStep := hrsConnect;
  error.init;
end;

function THttpResult.isSuccess: Boolean;
begin
  Result := error.isSuccess;
end;

{ EHttpException }

constructor EHttpException.Create(const _error: THttpError; const _func: string);
var
  _msg: string;
begin
  FError := _error;
  _msg := FError.description;
  inherited Create(_func + '失败：' + _msg);
end;

constructor EHttpException.Create(const _error: THttpError; const _func: string; const msg: string);
begin
  FError := _error;
  inherited Create(msg);
end;

{ TNetworkHost }

function TNetworkHost.getDisplayName: string;
begin
  if DisplayName = '' then
    Result := getHost
  else
    Result := DisplayName;
end;

function TNetworkHost.GetHost: THttpString;
begin
  if Self.port = 80 then Result := Self.HostName
  else Result := Self.HostName + ':' + IntToUStr(Self.port);
end;

procedure TNetworkHost.lock;
begin
  while InterlockedExchange(FLockState, 1) = 1 do ;
end;

function TNetworkHost.NeverUsed: Boolean;
begin
  Result := not IsLatestFailure and (AccessTimes = 0);
end;

procedure TNetworkHost.unlock;
begin
  InterlockedExchange(FLockState, 0);
end;

procedure TNetworkHost.SaveAccess(TripTime: DWORD);
var
  tmp: DWORD;
begin
  //UStrDbgOutput(HostName + ':' + IntToStr(port) + ' ' + IntToStr(TripTime) + 'ms');
  lock;
  LatestAccessTime := GetTickCount;
  TripTime := TripTime + FTripTimeRemainder;
  FTripTimeRemainder := 0;
  Inc(AccessTimes);

  if AccessTimes = 1 then
    EverageTripTime := TripTime
  else if TripTime >= EverageTripTime then
  begin
    tmp := TripTime - EverageTripTime;
    EverageTripTime := EverageTripTime + tmp div AccessTimes;
    FTripTimeRemainder := tmp mod AccessTimes;
  end
  else begin
    tmp := (EverageTripTime - TripTime) * (AccessTimes - 1);
    EverageTripTime := TripTime + tmp div AccessTimes;
    FTripTimeRemainder := tmp mod AccessTimes;
  end;

  IsLatestFailure := False;
  nContiguousFailure := 0;

  unlock;
end;

procedure TNetworkHost.SaveFailure;
begin
  lock;
  LatestFailureTime := GetTickCount;
  IsLatestFailure := True;
  Inc(nContiguousFailure);
  unlock;
end;

{ TMultiHostManager }

procedure TMultiHostManager.AddServerHost(const hostname: THttpString; port: Word);
var
  host: TNetworkHost;
begin
  if IndexOfHost(hostname, port) = -1 then
  begin
    host := TNetworkHost.Create;
    host.HostName := hostname;
    host.port := port;
    FHostList.Add(host);
  end;
end;

procedure TMultiHostManager.AddServerHost(const host: THttpString);
var
  name, port: THttpString;
  iPort: Integer;
begin
  if host <> '' then
  begin
    UStrSplit2(host, ':', name, port);

    if port = '' then AddServerHost(name, 80)
    else begin
      iPort := UStrToInt(port);
      if iPort > 0 then AddServerHost(name, iPort)
    end;
  end;
end;

procedure TMultiHostManager.AddServerHosts(const hosts: string; delimiter: Char);
var
  strs: TStringList;
  i: Integer;
begin
  if hosts <> '' then
  begin
    strs := TStringList.Create;
    try
      strs.Delimiter := delimiter;
      strs.StrictDelimiter := True;
      strs.DelimitedText := hosts;
      for i := 0 to strs.Count - 1 do
        AddServerHost(Trim(strs[i]));
    finally
      strs.Free;
    end;
  end;
end;

procedure TMultiHostManager.clearHosts;
begin
  FHostList.Clear;
end;

constructor TMultiHostManager.Create;
begin
  inherited Create;
  FHostList := TObjectListEx<TNetworkHost>.Create(True);
end;

destructor TMultiHostManager.Destroy;
begin
  FHostList.Free;
  inherited;
end;

function TMultiHostManager.DoRequest(HttpClient: TCustomHttpSession; request: THttpRequest; content: TStream): UnicodeString;
var
  i, nErrorRetry: Integer;
  SortedServerList: TObjectListEx<TNetworkHost>;
  sh: TNetworkHost;
  t: DWORD;
begin
  Result := '';

  SortedServerList := OptimizeServerHosts;

  if SortedServerList.Count > 1 then
    nErrorRetry := 0
  else
    nErrorRetry := 3;

  try
    for i := 0 to SortedServerList.Count - 1 do
    begin
      sh := SortedServerList[i];

      request.url.HostName := THttpString(sh.HostName);
      request.url.port := sh.port;
      request.ClearResponseHeaders;
      request.ClearRedirects;

      try
        t := GetTickCount;

        if Assigned(content) then
          HttpClient.DoRequest(request, g_BaseHttpOptions, content, nErrorRetry)
        else
          Result := HttpClient.FetchUnicodeString(request, g_BaseHttpOptions, nErrorRetry);

        sh.SaveAccess(GetTickCount - t);
        Break;
      except
        if i = SortedServerList.Count - 1 then raise;
      end;
    end;
  finally
    SortedServerList.Free;
  end;
end;

function TMultiHostManager.FetchRawBytes(HttpClient: TCustomHttpSession; request: THttpRequest): RawByteString;
var
  i, nErrorRetry: Integer;
  SortedServerList: TObjectListEx<TNetworkHost>;
  sh: TNetworkHost;
  t: DWORD;
begin
  Result := '';

  SortedServerList := OptimizeServerHosts;

  if SortedServerList.Count > 1 then
    nErrorRetry := 0
  else
    nErrorRetry := 3;

  try
    for i := 0 to SortedServerList.Count - 1 do
    begin
      sh := SortedServerList[i];

      request.url.HostName := THttpString(sh.HostName);
      request.url.port := sh.port;
      request.ClearResponseHeaders;
      request.ClearRedirects;

      try
        t := GetTickCount;
        Result := HttpClient.FetchRawBytes(request, g_BaseHttpOptions, nErrorRetry);
        sh.SaveAccess(GetTickCount - t);
        Break;
      except
        if i = SortedServerList.Count - 1 then raise;
      end;
    end;
  finally
    SortedServerList.Free;
  end;
end;

function TMultiHostManager.IndexOfHost(const hostname: THttpString; port: Word): Integer;
var
  i: Integer;
  host: TNetworkHost;
begin
  Result := -1;

  for i := 0 to FHostList.Count - 1 do
  begin
    host := FHostList[i];
    if UStrSameText(host.HostName, hostname) and (host.port = port) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TMultiHostManager.OptimizeServerHosts: TObjectListEx<TNetworkHost>;
begin
  Result := FHostList.Clone;
  Result.Sort(g_NetworkHostComparer);
end;

{ TNetworkHostComparer }

function TNetworkHostComparer.Compare(const Left, Right: TNetworkHost): Integer;
begin
  if Left.NeverUsed and Right.NeverUsed then
    Result := 0
  else if Left.NeverUsed then
    Result := -1
  else if Right.NeverUsed then
    Result := 1
  else if Left.IsLatestFailure then
  begin
    if Right.IsLatestFailure then Result := Left.nContiguousFailure - Right.nContiguousFailure
    else Result := 1;
  end
  else begin
    if Right.IsLatestFailure then Result := -1
    else Result := Left.EverageTripTime - Right.EverageTripTime;
  end;
end;

{ TCustomHttpIOHandler }

procedure TCustomHttpIOHandler.BufferHeaderLine(buf: PAnsiChar; len: Integer);
begin
  Move(buf^, FRespHeaderBuf[FRespHdrBufLen], len);
  Inc(FRespHdrBufLen, len);
end;

procedure TCustomHttpIOHandler.CompleteHeader;
var
  enc: THttpString;
begin
  FTotalRead := request.ResponseHeaders.ContentLengthAsInt;
  FAlreadyRead := 0;
  FChunked := UStrIPos('chunked', request.ResponseHeaders.TransferEncoding) > 0;
  enc := request.ResponseHeaders.ContentEncoding;

  if UStrAsciiICompare(enc, 'gzip') = 0 then
    FContentEncoding := encGzip
  else if UStrAsciiICompare(enc, 'deflate') = 0 then
    FContentEncoding := encDeflate
  else
    FContentEncoding := encNone;

  if FChunked then
  begin
    FF := 0;
    FChunkHeader := 'a';
    FCurChunkSize := 0;
  end;
end;

procedure TCustomHttpIOHandler.CompleteResponseBody;
var
  cancel: Boolean;
begin
  if zlibInited then
  begin
    zlibStrm.next_in := nil;
    zlibStrm.avail_in := 0;
    zlibStrm.next_out := PByte(FIOBuffer);
    zlibStrm.avail_out := FIOBufferSize;
    inflate(zlibStrm, Z_FINISH);
    FContentStream.WriteBuffer(FIOBuffer^, FIOBufferSize - Integer(zlibStrm.avail_out));
  end;

  FTotalRead := FAlreadyRead;
  cancel := False;
  if Assigned(FCallback) then
    FCallback(FStep, 100, 100, cancel);
end;

procedure TCustomHttpIOHandler.connected;
begin
  // DbgOutput('connected: ' + IntToStr(GetTickCount - FRequestBeginAt) + ' ms');
end;

constructor TCustomHttpIOHandler.Create;
begin
  isFirstByte := True;
  _request.AddRef;
  FRequest := _request;

  FBaseOptions := _BaseOptions;

  if FBaseOptions.ConnectTimeout = 0 then
    FBaseOptions.ConnectTimeout := g_DefaultConnectTimeout;

  if FBaseOptions.SendTimeout = 0 then
    FBaseOptions.SendTimeout := g_DefaultSendTimeout;

  if FBaseOptions.RecvTimeout = 0 then
    FBaseOptions.RecvTimeout := g_DefaultRecvTimeout;

  FCallback := _callback;
  FFrequentlyUsedHeaders := _headers;
  FProxy := _proxy;

  if FIOBufferSize <= SizeOf(FStaticIOBuffer) then
  begin
    FIOBuffer := @FStaticIOBuffer;
    FIOBufferSize := SizeOf(FStaticIOBuffer);
  end
  else
    FIOBuffer := System.GetMemory(FIOBufferSize);

  FRequestBeginAt := GetTickCount;
end;

procedure TCustomHttpIOHandler.DataRecved;
begin
  // DbgOutput('DataRecved: ' + IntToStr(GetTickCount - FRequestBeginAt) + ' ms');
end;

procedure TCustomHttpIOHandler.DataSent;
begin
  // DbgOutput('DataSent: ' + IntToStr(GetTickCount - FRequestBeginAt) + ' ms');
end;

destructor TCustomHttpIOHandler.Destroy;
begin
  FRequest.Release;
  FConnection.Release;

  if zlibInited then
  begin
    inflateEnd(zlibStrm);
    zlibInited := False;
  end;

  if FIOBuffer <> @FStaticIOBuffer then
    System.FreeMemory(FIOBuffer);

  inherited;
end;

procedure TCustomHttpIOHandler.HeaderRecved;
begin
  // DbgOutput('HeaderRecved: ' + IntToStr(GetTickCount - FRequestBeginAt) + ' ms');
end;

procedure TCustomHttpIOHandler.HeaderSent;
begin
  // DbgOutput('HeaderSent: ' + IntToStr(GetTickCount - FRequestBeginAt) + ' ms');
end;

function TCustomHttpIOHandler.ParseChunked(buf: PAnsiChar; len: Integer): Integer;
begin
  Result := Self._ParseChunked(buf, len);
end;

function TCustomHttpIOHandler.ParseChunkSize(buf: PAnsiChar; len: Integer): Integer;
var
  I: Integer;
  ptr, BufEnd: PAnsiChar;
begin
  Result := -1;
  BufEnd := buf + len;
  ptr := buf;
  if FChunkHeader = 'a' then
  begin
    while (ptr < BufEnd) and not(ptr^ in [#13, ';']) do
      Inc(ptr);
    for I := 0 to ptr - buf - 1 do
    begin
      case buf[I] of
        '0' .. '9':
          FCurChunkSize := FCurChunkSize shl 4 + PByte(buf + I)^ and $0F;
        'a' .. 'f', 'A' .. 'F':
          FCurChunkSize := FCurChunkSize shl 4 + PByte(buf + I)^ and $0F + 9;
        #32:
          ;
      else
        Exit;
      end;
    end;

    if ptr = BufEnd then
    begin
      Result := len;
      Exit;
    end
    else if ptr^ = ';' then
      FChunkHeader := 'b'
    else
      FChunkHeader := 'c';
  end;

  if FChunkHeader = 'b' then
  begin
    Inc(ptr);
    while (ptr < BufEnd) and (ptr^ <> #13) do
      Inc(ptr);
    if ptr = BufEnd then
    begin
      Result := len;
      Exit;
    end
    else
      FChunkHeader := 'c';
  end;

  if FChunkHeader = 'c' then
  begin
    Inc(ptr);

    if ptr = BufEnd then
    begin
      Result := len;
      Exit;
    end;

    if ptr^ <> #10 then
      Exit;

    Result := ptr - buf + 1;
    FChunkHeader := 'z';
    Exit;
  end;
end;

function TCustomHttpIOHandler.ParseHeader(buf: PAnsiChar; len: Integer): Integer;
var
  tmp, ptr, BufEnd: PAnsiChar;
begin
  Result := -1;
  ptr := buf;
  BufEnd := buf + len;
  while ptr < BufEnd do
  begin
    tmp := ptr;

    if (FRespHdrBufLen > 0) and (FRespHeaderBuf[FRespHdrBufLen - 1] = #13) then
    begin
      // #10 expected
      if ptr^ <> #10 then
        Exit;
      Inc(ptr);
      if FRespHdrBufLen = 1 then
      begin
        // 行尾
        FRespHdrBufLen := 0;
      end
      else
      begin
        // headers尾
        FRespHdrBufLen := 0;
        FResponseHeadersHot := True;
        Break;
      end;
    end
    else begin
      while (ptr < BufEnd) and (ptr^ <> #13) do
        Inc(ptr);

      if ptr = BufEnd then
      begin
        // 没有读到行尾
        BufferHeaderLine(tmp, ptr - tmp);
        Break;
      end
      else begin
        if FRespHdrBufLen = 0 then
        begin
          if ptr = tmp then
          begin
            // 读到了headers尾部 #13#10#13 处
            FRespHeaderBuf[0] := #13;
            FRespHeaderBuf[1] := #10;
            FRespHeaderBuf[2] := #13;
            FRespHdrBufLen := 3;
            Inc(ptr);
          end
          else begin
            // 读到了行尾
            ParseHeaderLine(tmp, ptr - tmp);
            Inc(ptr);
            FRespHeaderBuf[0] := #13;
            FRespHdrBufLen := 1;
          end;
        end
        else begin
          BufferHeaderLine(tmp, ptr - tmp);
          ParseHeaderLine(FRespHeaderBuf, FRespHdrBufLen);
          Inc(ptr);
          FRespHeaderBuf[0] := #13;
          FRespHdrBufLen := 1;
        end;
      end;
    end;
  end;
  Result := ptr - buf;
end;

function MakeHttpString(_begin, _end: PAnsiChar): THttpString;
var
  i: Integer;
begin
  SetLength(Result, _end - _begin);

  for i := 0 to Length(Result) - 1 do
    PHttpChar(Result)[i] := THttpChar(_begin[i]);
end;

function TCustomHttpIOHandler.ParseHeaderLine(buf: PAnsiChar; len: TSizeType): Boolean;
var
  tmp, ptr, BufEnd: PAnsiChar;
  name, value: THttpString;
  StatusCode: Integer;
begin
  Result := False;
  ptr := buf;
  BufEnd := buf + len;

  if FResponseLineGot then
  begin
    while (ptr < BufEnd) and (ptr^ <> ':') do
      Inc(ptr);
    if ptr = BufEnd then
      Exit;
    tmp := ptr;
    Inc(ptr);
    while (ptr < BufEnd) and (ptr^ <= #32) do
      Inc(ptr);
    name := MakeHttpString(buf, tmp);
    value := MakeHttpString(ptr, BufEnd);
    request.ResponseHeaders.add(name, value);
  end
  else begin
    // HTTP/1.1 200 OK 还没读到
    while (ptr < BufEnd) and (ptr^ > #32) do
      Inc(ptr);
    if ptr = BufEnd then
      Exit;
    while (ptr < BufEnd) and (ptr^ <= #32) do
      Inc(ptr);
    if ptr = BufEnd then
      Exit;
    StatusCode := 0;
    while ptr < BufEnd do
    begin
      if ptr^ in ['0' .. '9'] then
        StatusCode := StatusCode * 10 + PByte(ptr)^ and $0F
      else if ptr^ <= #32 then
        Break
      else
        Exit;
      Inc(ptr);
    end;
    request.ResponseHeaders.ResponseLine.StatusCode := StatusCode;
    while (ptr < BufEnd) and (ptr^ <= #32) do
      Inc(ptr);
    SetRBStr(request.ResponseHeaders.ResponseLine.StatusText, ptr, BufEnd);
    FResponseLineGot := True;
  end;

  Result := True;
end;

procedure TCustomHttpIOHandler.ReadBody;
var
  OriginStreamPos, ContentLength, NewPos: Int64;
begin
  FStep := hrsReceiveData;

  if Assigned(target) then
    OriginStreamPos := target.Position
  else
    OriginStreamPos := -1;

  Self._ReadBody(target, httperr);

  if httperr.isSuccess then
  begin
    if g_HttpKeepAlive and ( (FProxy.HostName <> '')
      or not UStrSameText(FRequest.ResponseHeaders.connection, 'Close') ) then
      Self.KeepConnection;

    if g_LogHttp and CheckLogFilter(request) then
    begin
      if Assigned(target) then
      begin
        NewPos := target.Position;
        ContentLength := NewPos - OriginStreamPos;
        target.Position := OriginStreamPos;
      end
      else begin
        ContentLength := 0;
        NewPos := -1;
      end;

      try
        DoLogHttp(request, FFrequentlyUsedHeaders, @FInternalHeaders, target, ContentLength);
      except

      end;

      if Assigned(target) then
        target.Position := NewPos;
    end;
  end;

  Self.DataRecved;
end;

procedure TCustomHttpIOHandler.ReadHeaders;
var
  cancel: Boolean;
begin
  FStep := hrsReceiveHeaders;
  cancel := False;

  if Assigned(FCallback) then
    FCallback(FStep, 100, 0, cancel);

  if cancel then
    httperr.code := httperrAborted
  else begin
    Self.RecevieHeaders(httperr);

    if httperr.code = httperrAborted then
    begin
      /////
      (*
        RecevieHeaders 返回httperrAborted表示
      *)
      httperr.clear;
      _ReadHeaders(httperr);
    end;

    if httperr.isSuccess then
    begin
      CompleteHeader;
      if Assigned(FCallback) then
        FCallback(FStep, 100, 100, cancel);

      if cancel then
        httperr.code := httperrAborted;
    end;
  end;
  Self.HeaderRecved;
end;

procedure TCustomHttpIOHandler.RecevieHeaders;
begin
  httperr.code := httperrAborted;
end;

procedure TCustomHttpIOHandler.SendHeaders;
begin
  httperr.code := httperrAborted;
end;

procedure TCustomHttpIOHandler.WriteStream;
var
  len: Integer;
begin
  while True do
  begin
    len := stream.Read(FIOBuffer^, FIOBufferSize);
    if len = 0 then Break;
    Self.WriteBuffer(FIOBuffer^, len, httperr);
    if not httperr.isSuccess then
      Break;
  end;
end;

function TCustomHttpIOHandler._ParseChunked(buf: PAnsiChar; len: Integer): Integer;
var
  ptr: PAnsiChar;
  used, n: Integer;
begin
  Result := -1;
  ptr := buf;

  while len > 0 do
  begin
    // #13#10 after every chunk data
    if FF = 1 then
    begin
      if ptr^ <> #13 then Exit;
      Inc(ptr);
      Dec(len);
      FF := 2;
      Continue;
    end
    else if FF = 2 then
    begin
      if ptr^ <> #10 then Exit;
      Inc(ptr);
      Dec(len);
      FF := 0;
      Continue;
    end;

    if FChunkHeader <> 'z' then
    begin
      used := ParseChunkSize(ptr, len);
      if used = -1 then
        Exit;
      Inc(ptr, used);
      Dec(len, used);
      if (FChunkHeader = 'z') and (FCurChunkSize = 0) then
      begin
        FTotalRead := FAlreadyRead;
        Break;
      end;
    end;

    if (FChunkHeader = 'z') and (len > 0) then
    begin
      if FCurChunkSize - FReceivedChunkSize > len then
      begin
        if WriteContent(ptr, len) < 0 then Exit;
        Inc(FReceivedChunkSize, len);
        Inc(ptr, len);
        Break;
      end
      else
      begin
        n := FCurChunkSize - FReceivedChunkSize;
        if WriteContent(ptr, n) < 0 then Exit;
        Inc(ptr, n);
        Dec(len, n);
        FChunkHeader := 'a';
        FCurChunkSize := 0;
        FReceivedChunkSize := 0;
        FF := 1;
      end;
    end;
  end;

  Result := ptr - buf;
end;

procedure TCustomHttpIOHandler._ReadBody;
var
  buf: Pointer;
  len, used, BufLen: Integer;
  cancel: Boolean;
  comerr: TCommunicationError;
begin
  if FTotalRead = 0 then
  begin
    CompleteResponseBody;
    Exit;
  end;

  FContentStream := target;

  if FBaseOptions.AutoDecompress and Assigned(FContentStream) then
  begin
    case FContentEncoding of
      encGzip:
        begin
          FillChar(zlibStrm, SizeOf(zlibStrm), 0);
          inflateInit2(zlibStrm, 47);
          zlibInited := True;
        end;

      encDeflate:
        begin
          FillChar(zlibStrm, SizeOf(zlibStrm), 0);
          inflateInit(zlibStrm);
          zlibInited := True;
        end;
    end;
  end;

  cancel := False;
  comerr.init;
  while True do
  begin
    buf := FIOBuffer;

    if FIOBufferBytesRead > FIOBufferUsed then
    begin
      Inc(PByte(buf), FIOBufferUsed);
      len := FIOBufferBytesRead - FIOBufferUsed;
      FIOBufferBytesRead := FIOBufferUsed;
    end
    else begin
      if FTotalRead > 0 then
      begin
        BufLen := FTotalRead - FAlreadyRead;
        if BufLen > FIOBufferSize then
          BufLen := FIOBufferSize;
      end
      else
        BufLen := FIOBufferSize;

      len := Self.read(FIOBuffer^, BufLen, comerr);

      if not comerr.isSuccess then
        httperr.fromCommunicateError(FStep, comerr);

      if len < 0 then
      begin
        if (FTotalRead < 0) and (httperr.code = httperrConnectionClosed) then
        begin
          (*
          no Content-Length in response headers, assume response content completed when connection close.
          *)
          httperr.clear;
          CompleteResponseBody;
        end;

        Break;
      end;
    end;

    if FChunked then
      used := Self.ParseChunked(buf, len)
    else
      used := Self.WriteContent(buf, len);

    if used < 0 then
    begin
      httperr.code := httperrInvalidResponse;
      Break;
    end;

    if Assigned(FCallback) then
    begin
      FCallback(hrsReceiveData, FTotalRead, FAlreadyRead, cancel);

      if cancel then
      begin
        httperr.code := httperrAborted;
        Break;
      end;
    end;

    if FTotalRead = FAlreadyRead then
    begin
      CompleteResponseBody;
      Break;
    end;
  end;
end;

procedure TCustomHttpIOHandler._ReadHeaders;
var
  comerr: TCommunicationError;
begin
  comerr.clear;
  while True do
  begin
    FIOBufferBytesRead := Self.read(FIOBuffer^, FIOBufferSize, comerr);

    if FIOBufferBytesRead < 0 then
    begin
      httperr.fromCommunicateError(FStep, comerr);
      Break;
    end;

    FIOBufferUsed := Self.ParseHeader(PAnsiChar(FIOBuffer), FIOBufferBytesRead);

    if FIOBufferUsed < 0 then
    begin
      httperr.code := httperrInvalidHeaders;
      Break;
    end;

    if FResponseHeadersHot then
      Break;
  end;
end;

procedure TCustomHttpIOHandler._WriteHeaders;
var
  RequestHeader: THttpString;
  rbs: RawByteString;
begin
  if UStrSameText(request.url.schema, 'http') and (FProxy.HostName <> '') then
  begin
    FInternalHeaders.ProxyConnection := 'Keep-Alive';

    if (FProxy.username <> '') then
      FInternalHeaders.ProxyAuthorization :=
        'Basic ' + THttpString(Base64Encode(FProxy.username + ':' + FProxy.password));
  end;

  RequestHeader := request.MakeRequestHeader(FFrequentlyUsedHeaders, True, @FInternalHeaders);
  rbs := RawByteString(RequestHeader);
  FTotalWrite := Length(rbs);
  FAlreadyWrite := 0;
  Self.WriteBuffer(Pointer(rbs)^, FTotalWrite, httperr);
end;

procedure TCustomHttpIOHandler.WriteBody;
var
  cancel: Boolean;
begin
  FStep := hrsSendData;
  FTotalWrite := request.ParamLength;
  if Assigned(request.ParamStream) then
    Inc(FTotalWrite, request.ParamStream.Size - request.ParamStream.Position);

  if FTotalWrite > 0 then
  begin
    FAlreadyWrite := 0;

    cancel := False;

    if Assigned(FCallback) then
      FCallback(FStep, FTotalWrite, FAlreadyWrite, cancel);

    if cancel then httperr.code := httperrAborted
    else begin
      if request.ParamLength > 0 then
        Self.WriteBuffer(request.param^, request.ParamLength, httperr);

      if httperr.isSuccess and Assigned(request.ParamStream) then
        Self.WriteStream(request.ParamStream, httperr);
    end;
  end;

  Self.DataSent;
end;

procedure TCustomHttpIOHandler.WriteBuffer;
var
  ptr: Pointer;
  len, BytesWritten: Integer;
  cancel: Boolean;
  comerr: TCommunicationError;
begin
  ptr := @buf;
  len := BufSize;
  cancel := False;
  comerr.init;
  while len > 0 do
  begin
    BytesWritten := Self.write(ptr^, len, comerr);

    if BytesWritten < 0 then
    begin
      httperr.fromCommunicateError(FStep, comerr);
      Break;
    end;

    Dec(len, BytesWritten);
    Inc(PByte(ptr), BytesWritten);
    Inc(FAlreadyWrite, BytesWritten);

    if Assigned(FCallback) then
    begin
      FCallback(FStep, FTotalWrite, FAlreadyWrite, cancel);

      if cancel then
      begin
        httperr.code := httperrAborted;
        Break;
      end;
    end;
  end;
end;

function TCustomHttpIOHandler.WriteContent(buf: PAnsiChar; len: Integer): Integer;
const
  deflate_dummy_header: array [0..1] of Byte = (120, 1);
var
  dest: array [0 .. 4095] of Byte;
  ret: Integer;
begin
  if FTotalRead >= 0 then
  begin
    Result := FTotalRead - FAlreadyRead;

    if Result > len then
      Result := len;
  end
  else
    Result := len;

  if not zlibInited then
  begin
    if Assigned(FContentStream) then
      FContentStream.WriteBuffer(buf^, Result);
  end
  else begin
    zlibStrm.next_in := PByte(buf);
    zlibStrm.avail_in := len;
    while zlibStrm.avail_in > 0 do
    begin
      zlibStrm.next_out := PByte(@dest);
      zlibStrm.avail_out := SizeOf(dest);
      ret := inflate(zlibStrm, Z_NO_FLUSH);

      if ret in [Z_OK, Z_STREAM_END] then
        isFirstByte := False
      else if (ret = Z_DATA_ERROR) and isFirstByte then
      begin
        inflateReset(zlibStrm);
        zlibStrm.next_in := @deflate_dummy_header[0];
        zlibStrm.avail_in := SizeOf(deflate_dummy_header);
        zlibStrm.next_out := PByte(@dest);
        zlibStrm.avail_out := SizeOf(dest);
        ret := inflate(zlibStrm, Z_NO_FLUSH);

        if ret = Z_OK then
        begin
          zlibStrm.next_in := PByte(buf);
          zlibStrm.avail_in := len;
          ret := inflate(zlibStrm, Z_NO_FLUSH);
        end;
      end;

      if ret in [Z_OK, Z_STREAM_END] then
        FContentStream.WriteBuffer(dest, SizeOf(dest) - zlibStrm.avail_out)
      else begin
        Result := -1;
        Break;
      end
    end;
  end;

  if Result > 0 then
    Inc(FAlreadyRead, Result);
end;

procedure TCustomHttpIOHandler.WriteHeaders;
var
  cancel: Boolean;
begin
  FStep := hrsSendHeaders;
  cancel := False;

  if Assigned(FCallback) then
    FCallback(hrsSendHeaders, 0, 100, cancel);

  if cancel then
    httperr.code := httperrAborted
  else begin
    Self.SendHeaders(httperr);

    if httperr.code = httperrAborted then
    begin
      /////
      (*
        SendHeaders returns httperrAborted
      *)
      httperr.clear;
      Self._WriteHeaders(httperr);
    end;

    if httperr.isSuccess then
    begin
      if Assigned(FCallback) then
        FCallback(FStep, 100, 100, cancel);

      if cancel then
        httperr.code := httperrAborted;
    end;
  end;

  Self.HeaderSent;
end;

{ THttpResponseLine }

function THttpResponseLine.parse(const line: TAnsiCharSection): Boolean;
var
  P1, P2: PAnsiChar;
  sec: TAnsiCharSection;
begin
  Result := False;

  if IBeginWithA(line._begin, line.length, 'HTTP/', 5) then
  begin
    P1 := line._begin + 5;

    while (P1 < line._end) and (P1^ > #32) do Inc(P1);

    if P1 >= line._end then Exit;
    sec._begin := line._begin;
    sec._end := P1;
    Self.version := sec.ToString;

    Inc(P1);
    while (P1 < line._end) and (P1^ <= #32) do Inc(P1);
    if P1 >= line._end then Exit;

    P2 := P1 + 1;
    while (P2 < line._end) and (P2^ > #32) do Inc(P2);

    if not IsIntegerA(P1, P2 - P1) then Exit;

    Self.StatusCode := BufToIntA(P1, P2 - P1, nil);

    P1 := P2 + 1;
    while (P1 < line._end) and (P1^ <= #32) do Inc(P1);
    if P1 >= line._end then Exit;
    sec._begin := P1;
    sec._end := line._end;
    Self.StatusText := sec.trim.ToString;
    Result := True;
  end;
end;

function THttpResponseLine.parse(const line: TWideCharSection): Boolean;
var
  P1, P2: PWideChar;
  sec: TWideCharSection;
begin
  Result := False;

  if IBeginWithW(line._begin, line.length, 'HTTP/', 5) then
  begin
    P1 := line._begin + 5;

    while (P1 < line._end) and (P1^ > #32) do Inc(P1);

    if P1 >= line._end then Exit;
    sec._begin := line._begin;
    sec._end := P1;
    Self.version := RawByteString(sec.ToUStr);

    Inc(P1);
    while (P1 < line._end) and (P1^ <= #32) do Inc(P1);
    if P1 >= line._end then Exit;

    P2 := P1 + 1;
    while (P2 < line._end) and (P2^ > #32) do Inc(P2);

    if not IsIntegerW(P1, P2 - P1) then Exit;

    Self.StatusCode := BufToIntW(P1, P2 - P1, nil);

    P1 := P2 + 1;
    while (P1 < line._end) and (P1^ <= #32) do Inc(P1);
    if P1 >= line._end then Exit;
    sec._begin := P1;
    sec._end := line._end;
    Self.StatusText := RawByteString(sec.trim.ToUStr);
    Result := True;
  end;
end;

{ THttpResponseHeaders }

procedure THttpResponseHeaders.parse(const s: TWideCharSection);
var
  P1, P2: PWideChar;
  sec: TWideCharSection;
begin
  P1 := s._begin;

  while True do
  begin
    while (P1 < s._end) and ( (P1^ = #13) or (P1^ = #10) ) do Inc(P1);
    if P1 >= s._end then Break;

    P2 := P1;
    while (P2 < s._end) and (P2^ <> #13) and (P2^ <> #10) do Inc(P2);
    sec._begin := P1;
    sec._end := P2;

    if IBeginWithW(P1, P2 - P1, 'HTTP/', 5) then
      ResponseLine.parse(sec)
    else
      ParseOne(sec);

    P1 := P2 + 1;
  end;
end;

procedure THttpResponseHeaders.parse(const s: TAnsiCharSection);
var
  P1, P2: PAnsiChar;
  sec: TAnsiCharSection;
begin
  P1 := s._begin;

  while True do
  begin
    while (P1 < s._end) and ( (P1^ = #13) or (P1^ = #10) ) do Inc(P1);
    if P1 >= s._end then Break;

    P2 := P1;
    while (P2 < s._end) and (P2^ <> #13) and (P2^ <> #10) do Inc(P2);
    sec._begin := P1;
    sec._end := P2;

    if IBeginWithA(P1, P2 - P1, 'HTTP/', 5) then
      ResponseLine.parse(sec)
    else
      ParseOne(sec);

    P1 := P2 + 1;
  end;
end;

{ THttpRequestHeaders }

procedure THttpRequestHeaders.parse(const s: TWideCharSection);
var
  P1, P2: PWideChar;
  sec: TWideCharSection;
begin
  P1 := s._begin;

  while True do
  begin
    while (P1 < s._end) and ( (P1^ = #13) or (P1^ = #10) ) do Inc(P1);
    if P1 >= s._end then Break;

    P2 := P1;
    while (P2 < s._end) and (P2^ <> #13) and (P2^ <> #10) do Inc(P2);
    sec._begin := P1;
    sec._end := P2;
    ParseOne(sec);
    P1 := P2 + 1;
  end;
end;

procedure THttpRequestHeaders.parse(const s: TAnsiCharSection);
var
  P1, P2: PAnsiChar;
  sec: TAnsiCharSection;
begin
  P1 := s._begin;

  while True do
  begin
    while (P1 < s._end) and ( (P1^ = #13) or (P1^ = #10) ) do Inc(P1);
    if P1 >= s._end then Break;

    P2 := P1;
    while (P2 < s._end) and (P2^ <> #13) and (P2^ <> #10) do Inc(P2);
    sec._begin := P1;
    sec._end := P2;
    ParseOne(sec);
    P1 := P2 + 1;
  end;
end;

procedure GenerateUserAgent;
var
  viex: TOSVersionInfoExW;
  vers: string;
begin
  viex.dwOSVersionInfoSize := SizeOf(viex);
  if Windows.GetVersionExW(viex) then
  begin
    vers := IntToStr(viex.dwMajorVersion) + '.' + IntToStr(viex.dwMinorVersion);

    if viex.dwMajorVersion > 5 then
      IE_USER_AGENT := 'Mozilla/5.0 (Windows NT ' + vers + '; WOW64; Trident/7.0; SLCC2; .NET CLR 2.0.50727;'
        + ' .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET4.0C; .NET4.0E; GWX:RESERVED; GWX:QUALIFIED; rv:11.0)'
    else
      IE_USER_AGENT := 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT ' + vers
        + '; Trident/4.0; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 2.0.50727)';

    FIREFOX_WIN32_USER_AGENT := 'Mozilla/5.0 (Windows NT ' + vers + '; rv:45.0) Gecko/20100101 Firefox/45.0';
    CHROME_WIN32_USER_AGENT := 'Mozilla/5.0 (Windows NT ' + vers + ') AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36';
  end;
end;

{ THttpQueryString }

constructor THttpQueryString.Create(const queryString: string);
begin
  FParams := TList<TPair<string, string>>.Create;
  parse(queryString);
end;

constructor THttpQueryString.Create;
begin
  FParams := TList<TPair<string, string>>.Create;
end;

destructor THttpQueryString.Destroy;
begin
  FParams.Free;
  inherited;
end;

function THttpQueryString.getParam(const name: string): string;
var
  i: Integer;
  param: TPair<string, string>;
begin
  Result := '';

  for i := 0 to FParams.Count - 1 do
  begin
    param := FParams[i];

    if SameText(param.Key, name) then
    begin
      Result := param.Value;
      Break;
    end;
  end;
end;

procedure THttpQueryString.parse(const queryString: string);
var
  strs: TStringList;
  i: Integer;
  param: TPair<string, string>;
begin
  strs := TStringList.Create;

  try
    strs.Delimiter := '&';
    strs.StrictDelimiter := True;
    strs.DelimitedText := queryString;
    for i := 0 to strs.Count - 1 do
    begin
      param.Key := decodeURIComponent(RawByteString(strs.Names[i]));
      param.Value := decodeURIComponent(RawByteString(strs.ValueFromIndex[i]));
      FParams.Add(param);
    end;
  finally
    strs.Free;
  end;
end;

{ TReadonlyHeaders }

function TReadonlyHeaders.all: RawByteString;
begin
  Result := FHeaders;
end;

function TReadonlyHeaders.getI(const name: RawByteString; default: Int64): Int64;
var
  s: TAnsiCharSection;
begin
  Result := default;
  s := Self.getS(name);

  if s.length > 0 then
    s.TryToInt64(Result);
end;

function TReadonlyHeaders.getS(const name: RawByteString): TAnsiCharSection;
var
  P, P2, L: Integer;
begin
  Result.SetEmpty;
  P := 1;
  L := Length(Self.FHeaders);
  while P <= L do
  begin
    P := RBStrIPos(name, FHeaders, P);

    if (P <= 0) then Break;

    P2 := P + Length(name);

    if (P = 1) or (FHeaders[P - 1] = #10) then
    begin
      if (P2 <= L) and (FHeaders[P2] = ':') then
      begin
        P := P2;
        while (P <= L) and (FHeaders[P] <> #13) do Inc(P);
        Result._begin := PAnsiChar(FHeaders) + P2;
        Result._end := PAnsiChar(FHeaders) + P - 1;
        Result.trim;
      end;
    end;

    P := P2;
  end;
end;

procedure TReadonlyHeaders.reset(const _headers: RawByteString);
begin
  Self.FHeaders := _headers;
end;

{ THttpRequestLine }

function THttpRequestLine.getPath: TAnsiCharSection;
begin
  Result.SetStr(pathWithParam, 1, RBStrScan(pathWithParam, '?'));
end;

function THttpRequestLine.getQueryParam(const name: RawByteString): RawByteString;
begin
  Result := RBStrUrlGetParam(pathWithParam, name);
end;

procedure THttpRequestLine.init;
begin
  majorVersion := 0;
  minorVersion := 0;
end;

function parseHttpVersion(const ver: TAnsiCharSection; var major, minor: Byte): Boolean;
begin
  if (ver.length <> 8) or (ver._begin[6] <> '.')
    or not (ver._begin[5] in ['0'..'9'])
    or not (ver._begin[7] in ['0'..'9'])
    or not ver.iBeginWith(TAnsiCharSection.Create('HTTP/')) then
    Result := False
  else begin
    major := Byte(ver._begin[5]) and $0f;
    minor := Byte(ver._begin[7]) and $0f;
    Result := True;
  end;
end;

function THttpRequestLine.parse(const line: TAnsiCharSection): Boolean;
var
  p1, p2: PAnsiChar;
  major, minor: Byte;
  methSec, verSec, pathSec: TAnsiCharSection;
begin
  Result := False;

  p1 := line._end - 1;

  while (p1 >= line._begin + 5) and (p1^ > #32 ) do Dec(p1);

  if p1 < line._begin + 5 then Exit;

  verSec._begin := p1 + 1;
  verSec._end := line._end;

  if not parseHttpVersion(verSec, major, minor) then Exit;

  Dec(p1);
  while (p1 >= line._begin + 4) and (p1^ <= #32 ) do Dec(p1);

  if p1 < line._begin + 4 then Exit;

  p2 := p1 + 1;
  Dec(p1);

  while (p1 >= line._begin + 3) and (p1^ > #32 ) do Dec(p1);
  if p1 < line._begin + 3 then Exit;

  pathSec._begin := p1 + 1;
  pathSec._end := p2;

  methSec._begin := line._begin;
  methSec._end := p1;

  methSec.trim;

  if methSec.length > 0 then
  begin
    Self.method := methSec.ToString;
    Self.pathWithParam := pathSec.ToString;
    Self.majorVersion := major;
    Self.minorVersion := minor;
    Result := True;
  end;
end;

function THttpRequestLine.parse(const line: RawByteString): Boolean;
var
  sec: TAnsiCharSection;
begin
  sec._begin := PAnsiChar(line);
  sec._end := sec._begin + Length(line);
  Result := Self.parse(sec);
end;

function THttpRequestLine.toString: RawByteString;
begin
  Result := Self.method + ' ' + Self.pathWithParam + ' HTTP/' + IntToRBStr(majorVersion) + '.' + IntToRBStr(minorVersion);
end;

{ THttpRequestHeadersParser }

function THttpRequestHeadersParser.feed(const buf; bufLen: Integer): Integer;
var
  n, n2: Integer;
begin
  if state = hhsInvalid then
    Result := -1
  else if state = hhsCompleted then
    Result := 0
  else begin
    if state = hhsFirstLine  then
      n := Self._parseRequestLine(buf, bufLen)
    else
      n := 0;

    if (n >= 0) and (n < bufLen) then
    begin
      n2 := Self._parseKeyValues(PAnsiChar(@buf)[n], bufLen - n);

      if n2 = -1 then
        Result := -1
      else
        Result := n + n2;
    end
    else
      Result := n;
  end;
end;

procedure THttpRequestHeadersParser.init;
begin
  state := hhsFirstLine;
  requestLine.init;
  _bufferdHeaders := '';
end;

function THttpRequestHeadersParser._parseKeyValues(const buf; bufLen: Integer): Integer;
var
  sec: TAnsiCharSection;
  pLineEnd: PAnsiChar;
begin
  if _bufferdHeaders <> '' then
    Result := _combineKeyValues(buf, BufLen)
  else begin
    sec._begin := PAnsiChar(@buf);
    sec._end := sec._begin + bufLen;

    pLineEnd := sec.pos(g_headersEnd);

    if pLineEnd = nil then
    begin
      _addToBuffer(buf, bufLen);
      Result := bufLen;
    end
    else begin
      sec._end := pLineEnd;
      _completeKeyValues(sec.ToString);
      Result := sec.length + 4;
    end;
  end;
end;

function THttpRequestHeadersParser._parseRequestLine(const buf; bufLen: Integer): Integer;
var
  sec: TAnsiCharSection;
  pLineEnd: PAnsiChar;
begin
  if _bufferdHeaders <> '' then
    Result := _combineRequestLine(buf, BufLen)
  else begin
    sec._begin := PAnsiChar(@buf);
    sec._end := sec._begin + bufLen;

    pLineEnd := sec.pos(g_lineEnd);

    if pLineEnd = nil then
    begin
      _addToBuffer(buf, bufLen);
      Result := bufLen;
    end
    else begin
      sec._end := pLineEnd;
      if _completeRequestLine(sec) then
        Result := sec.length + 2
      else
        Result := -1;
    end;
  end;
end;

function THttpRequestHeadersParser._combineKeyValues(const buf; bufLen: Integer): Integer;
var
  sec: TAnsiCharSection;
  pLineEnd: PAnsiChar;
begin
  Result := _combineKeyValuesTail(buf, bufLen);

  if Result = 0 then
  begin
    sec._begin := PAnsiChar(@buf);
    sec._end := sec._begin + bufLen;

    pLineEnd := sec.pos(g_headersEnd);

    if pLineEnd = nil then
    begin
      _addToBuffer(buf, bufLen);
      Result := bufLen;
    end
    else begin
      if pLineEnd <> sec._begin then
        _addToBuffer(buf, pLineEnd - sec._begin);

      _completeKeyValues(_bufferdHeaders);
      Result := pLineEnd - PAnsiChar(@buf) + 4;
    end;
  end;
end;

function THttpRequestHeadersParser._combineKeyValuesTail(const buf; bufLen: Integer): Integer;
var
  sec: TAnsiCharSection;
  L: Integer;
begin
  Result := 0;
  sec._begin := PAnsiChar(@buf);
  sec._end := sec._begin + bufLen;
  L := Length(_bufferdHeaders);

  if (L >= 3) and (_bufferdHeaders[L - 2] = #13) and (_bufferdHeaders[L - 1] = #10) and (_bufferdHeaders[L] = #13) then
  begin
    if sec._begin = #10 then
    begin
      _completeKeyValues(_bufferdHeaders);
      Result := 1;
    end
    else
      Result := -1;
  end
  else if (L >= 2) and (_bufferdHeaders[L - 1] = #13) and (_bufferdHeaders[L] = #10)
    and (sec._begin^ = #13) and (bufLen >= 2) then
  begin
    if sec._begin[1] = #10 then
    begin
      _completeKeyValues(_bufferdHeaders);
      Result := 1;
    end
    else
      Result := -1;
  end
  else if (_bufferdHeaders[L] = #13) and (sec._begin^ = #10) and (bufLen >= 3) and
    (sec._begin[1] = #13) then
  begin
    if sec._begin[2] = #10 then
    begin
      _completeKeyValues(_bufferdHeaders);
      Result := 1;
    end
    else
      Result := -1;
  end
end;

function THttpRequestHeadersParser._combineRequestLine(const buf; bufLen: Integer): Integer;
var
  sec: TAnsiCharSection;
  pLineEnd: PAnsiChar;
begin
  Result := -1;
  sec._begin := PAnsiChar(@buf);
  sec._end := sec._begin + bufLen;
  if _bufferdHeaders[Length(_bufferdHeaders)] = #13 then
  begin
    if sec._begin = #10 then
    begin
      sec._begin := PAnsiChar(_bufferdHeaders);
      sec._end := sec._begin + Length(_bufferdHeaders) - 1;
      if _completeRequestLine(sec) then
        Result := 1;
    end;
  end
  else begin
    pLineEnd := sec.pos(g_lineEnd);

    if pLineEnd = nil then
    begin
      _addToBuffer(buf, bufLen);
      Result := bufLen;
    end
    else begin
      if pLineEnd <> sec._begin then
        _addToBuffer(buf, pLineEnd - sec._begin);
      sec._begin := PAnsiChar(_bufferdHeaders);
      sec._end := sec._begin + Length(_bufferdHeaders);
      if _completeRequestLine(sec) then
        Result := pLineEnd - PAnsiChar(@buf) + 2;
    end;
  end;
end;

procedure THttpRequestHeadersParser._completeKeyValues(const s: RawByteString);
begin
  requestHeaders.reset(s);
  state := hhsCompleted;
end;

function THttpRequestHeadersParser._completeRequestLine(const s: TAnsiCharSection): Boolean;
begin
  Result := requestLine.parse(s);
  if Result then
    state := hhsKeyValues;
end;

procedure THttpRequestHeadersParser._addToBuffer(const buf; bufLen: Integer);
var
  oldLen: Integer;
begin
  oldLen := Length(_bufferdHeaders);
  SetLength(_bufferdHeaders, oldLen + bufLen);
  Move(buf, PAnsiChar(_bufferdHeaders)[oldLen], bufLen);
end;

{ THttpError }

procedure THttpError.clear;
begin
  code := httpSuccess;
  callee := '';
  internalErrorCode := 0;
  msg := '';
end;

function THttpError.description: string;
begin
  if msg <> '' then
    Result := msg
  else
    case code of
      httpSuccess: Result := '操作成功';
      httperrAborted: Result := '用户取消';
      httpRtlException: Result := '运行时异常';
      httperrSysCallFail:
        begin
          if callee = '' then
            Result := '系统调用失败'
          else
            Result := callee + ' failed with error ' + IntToStr(internalErrorCode);
        end;
      httperrInvalidUrl: Result := '错误的url';
      httperrDNSError: Result := '域名解析失败';
      httperrCanNotConnect: Result := '连接服务器失败';
      httperrTimeout: Result := '操作超时';
      httperrConnectionClosed: Result := '连接断开';
      httperrInvalidCert: Result := '证书错误';
      httperrSSLFailure: Result := 'SSL错误';
      httperrInvalidHeaders: Result := 'response header格式错误';
      httperrInvalidResponse: Result := 'response body格式错误';
      httperrTooManyRedirects: Result := '重定向次数超限';
    else
        Result := '未知错误';
    end;
end;

procedure THttpError.fromCommunicateError(step: THttpStep; comerr: TCommunicationError);
begin
  callee := comerr.callee;
  internalErrorCode := comerr.internalErrorCode;
  msg := comerr.msg;
  code := httperrUnknown;
  case comerr.code of
    comerrSuccess: code := httpSuccess;
    comerrSysCallFail: code := httperrSysCallFail;
    comerrTimeout, comerrCanNotRead, comerrCanNotWrite: code := httperrTimeout;
    comerrDNSError: code := httperrDNSError;
    comerrUnreachableDest, comerrCanNotConnect: code := httperrCanNotConnect;
    comerrChannelClosed: code := httperrConnectionClosed;
    comerrSSLError: code := httperrSSLFailure;
  end;
end;

procedure THttpError.init;
begin
  clear;
end;

function THttpError.isSuccess: Boolean;
begin
  Result := Self.code = httpSuccess;
end;

procedure THttpError.reset;
begin
  clear;
end;

initialization
  g_lineEnd._begin := SLineEnd;
  g_lineEnd._end := @SLineEnd[2];
  g_headersEnd._begin := SHeadersEnd;
  g_headersEnd._end := @SHeadersEnd[4];
  GenerateUserAgent;
  HttpLogCS := TCriticalSection.Create;
  g_LogFilterHosts := THttpStringList.Create;
  g_NetworkHostComparer := TNetworkHostComparer.Create;

finalization
  HttpLogStream.Free;
  HttpLogCS.Free;
  g_LogFilterHosts.Free;

end.
