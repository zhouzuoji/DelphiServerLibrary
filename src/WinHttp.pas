unit WinHttp;

interface

uses
  SysUtils, Classes, Windows;

const
  WinHttpDLL = 'winhttp.dll';

  INTERNET_SCHEME_HTTP = 1;
  INTERNET_SCHEME_HTTPS = 2;

  (*Retrieves the static proxy or direct configuration from the registry.
    WINHTTP_ACCESS_TYPE_DEFAULT_PROXY does not inherit browser proxy settings.
    WinHTTP does not share any proxy settings with Internet Explorer.
    The WinHTTP proxy configuration is set by one of these mechanisms.
    The proxycfg.exe utility on Windows XP and Windows Server 2003 or earlier.
    The netsh.exe utility on Windows Vista and Windows Server 2008 or later.
    WinHttpSetDefaultProxyConfiguration on all platforms.*)
  WINHTTP_ACCESS_TYPE_DEFAULT_PROXY = 0;

  //Resolves all host names directly without a proxy.
  WINHTTP_ACCESS_TYPE_NO_PROXY = 1;

  (*Passes requests to the proxy unless a proxy bypass list is supplied and
    the name to be resolved bypasses the proxy. In this case, this function
    uses WINHTTP_ACCESS_TYPE_NAMED_PROXY.*)
  WINHTTP_ACCESS_TYPE_NAMED_PROXY = 3;

  WINHTTP_NO_PROXY_NAME = nil;
  WINHTTP_NO_PROXY_BYPASS = nil;

  WINHTTP_FLAG_ASYNC = $10000000;

  HTTP_STATUS_CONTINUE = 100; // OK to continue with request
  HTTP_STATUS_SWITCH_PROTOCOLS = 101; // server has switched protocols in upgrade header

  HTTP_STATUS_OK = 200; // request completed
  HTTP_STATUS_CREATED = 201; // object created, reason = new URI
  HTTP_STATUS_ACCEPTED = 202; // async completion (TBS)
  HTTP_STATUS_PARTIAL = 203; // partial completion
  HTTP_STATUS_NO_CONTENT = 204; // no info to return
  HTTP_STATUS_RESET_CONTENT = 205; // request completed, but clear form
  HTTP_STATUS_PARTIAL_CONTENT = 206; // partial GET fulfilled
  HTTP_STATUS_WEBDAV_MULTI_STATUS = 207; // WebDAV Multi-Status

  HTTP_STATUS_AMBIGUOUS = 300; // server couldn't decide what to return
  HTTP_STATUS_MOVED = 301; // object permanently moved
  HTTP_STATUS_REDIRECT = 302; // object temporarily moved
  HTTP_STATUS_REDIRECT_METHOD = 303; // redirection w/ new access method
  HTTP_STATUS_NOT_MODIFIED = 304; // if-modified-since was not modified
  HTTP_STATUS_USE_PROXY = 305; // redirection to proxy, location header specifies proxy to use
  HTTP_STATUS_REDIRECT_KEEP_VERB = 307; // HTTP/1.1: keep same verb

  HTTP_STATUS_BAD_REQUEST = 400; // invalid syntax
  HTTP_STATUS_DENIED = 401; // access denied
  HTTP_STATUS_PAYMENT_REQ = 402; // payment required
  HTTP_STATUS_FORBIDDEN = 403; // request forbidden
  HTTP_STATUS_NOT_FOUND = 404; // object not found
  HTTP_STATUS_BAD_METHOD = 405; // method is not allowed
  HTTP_STATUS_NONE_ACCEPTABLE = 406; // no response acceptable to client found
  HTTP_STATUS_PROXY_AUTH_REQ = 407; // proxy authentication required
  HTTP_STATUS_REQUEST_TIMEOUT = 408; // server timed out waiting for request
  HTTP_STATUS_CONFLICT = 409; // user should resubmit with more info
  HTTP_STATUS_GONE = 410; // the resource is no longer available
  HTTP_STATUS_LENGTH_REQUIRED = 411; // the server refused to accept request w/o a length
  HTTP_STATUS_PRECOND_FAILED = 412; // precondition given in request failed
  HTTP_STATUS_REQUEST_TOO_LARGE = 413; // request entity was too large
  HTTP_STATUS_URI_TOO_LONG = 414; // request URI too long
  HTTP_STATUS_UNSUPPORTED_MEDIA = 415; // unsupported media type
  HTTP_STATUS_RETRY_WITH = 449; // retry after doing the appropriate action.

  HTTP_STATUS_SERVER_ERROR = 500; // internal server error
  HTTP_STATUS_NOT_SUPPORTED = 501; // required not supported
  HTTP_STATUS_BAD_GATEWAY = 502; // error response received from gateway
  HTTP_STATUS_SERVICE_UNAVAIL = 503; // temporarily overloaded
  HTTP_STATUS_GATEWAY_TIMEOUT = 504; // timed out waiting for gateway
  HTTP_STATUS_VERSION_NOT_SUP = 505; // HTTP version not supported

  HTTP_STATUS_FIRST = HTTP_STATUS_CONTINUE;
  HTTP_STATUS_LAST = HTTP_STATUS_VERSION_NOT_SUP;


  WINHTTP_ERROR_BASE = 12000;

  ERROR_WINHTTP_OUT_OF_HANDLES = (WINHTTP_ERROR_BASE + 1);
  ERROR_WINHTTP_TIMEOUT = (WINHTTP_ERROR_BASE + 2);
  ERROR_WINHTTP_INTERNAL_ERROR = (WINHTTP_ERROR_BASE + 4);
  ERROR_WINHTTP_INVALID_URL = (WINHTTP_ERROR_BASE + 5);
  ERROR_WINHTTP_UNRECOGNIZED_SCHEME = (WINHTTP_ERROR_BASE + 6);
  ERROR_WINHTTP_NAME_NOT_RESOLVED = (WINHTTP_ERROR_BASE + 7);
  ERROR_WINHTTP_INVALID_OPTION = (WINHTTP_ERROR_BASE + 9);
  ERROR_WINHTTP_OPTION_NOT_SETTABLE = (WINHTTP_ERROR_BASE + 11);
  ERROR_WINHTTP_SHUTDOWN = (WINHTTP_ERROR_BASE + 12);


  ERROR_WINHTTP_LOGIN_FAILURE = (WINHTTP_ERROR_BASE + 15);
  ERROR_WINHTTP_OPERATION_CANCELLED = (WINHTTP_ERROR_BASE + 17);
  ERROR_WINHTTP_INCORRECT_HANDLE_TYPE = (WINHTTP_ERROR_BASE + 18);
  ERROR_WINHTTP_INCORRECT_HANDLE_STATE = (WINHTTP_ERROR_BASE + 19);
  ERROR_WINHTTP_CANNOT_CONNECT = (WINHTTP_ERROR_BASE + 29);
  ERROR_WINHTTP_CONNECTION_ERROR = (WINHTTP_ERROR_BASE + 30);
  ERROR_WINHTTP_RESEND_REQUEST = (WINHTTP_ERROR_BASE + 32);

  ERROR_WINHTTP_CLIENT_AUTH_CERT_NEEDED = (WINHTTP_ERROR_BASE + 44);

  //WinHttpRequest Component errors
  ERROR_WINHTTP_CANNOT_CALL_BEFORE_OPEN = (WINHTTP_ERROR_BASE + 100);
  ERROR_WINHTTP_CANNOT_CALL_BEFORE_SEND = (WINHTTP_ERROR_BASE + 101);
  ERROR_WINHTTP_CANNOT_CALL_AFTER_SEND = (WINHTTP_ERROR_BASE + 102);
  ERROR_WINHTTP_CANNOT_CALL_AFTER_OPEN = (WINHTTP_ERROR_BASE + 103);

  //HTTP API errors
  ERROR_WINHTTP_HEADER_NOT_FOUND = (WINHTTP_ERROR_BASE + 150);
  ERROR_WINHTTP_INVALID_SERVER_RESPONSE = (WINHTTP_ERROR_BASE + 152);
  ERROR_WINHTTP_INVALID_QUERY_REQUEST = (WINHTTP_ERROR_BASE + 154);
  ERROR_WINHTTP_HEADER_ALREADY_EXISTS = (WINHTTP_ERROR_BASE + 155);
  ERROR_WINHTTP_REDIRECT_FAILED = (WINHTTP_ERROR_BASE + 156);



  //additional WinHttp API error codes
  ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR = (WINHTTP_ERROR_BASE + 178);
  ERROR_WINHTTP_BAD_AUTO_PROXY_SCRIPT = (WINHTTP_ERROR_BASE + 166);
  ERROR_WINHTTP_UNABLE_TO_DOWNLOAD_SCRIPT = (WINHTTP_ERROR_BASE + 167);

  ERROR_WINHTTP_NOT_INITIALIZED = (WINHTTP_ERROR_BASE + 172);
  ERROR_WINHTTP_SECURE_FAILURE = (WINHTTP_ERROR_BASE + 175);

//
// Certificate security errors. These are raised only by the WinHttpRequest
// component. The WinHTTP Win32 API will return ERROR_WINHTTP_SECURE_FAILE and
// provide additional information via the WINHTTP_CALLBACK_STATUS_SECURE_FAILURE
// callback notification.
//
  ERROR_WINHTTP_SECURE_CERT_DATE_INVALID = (WINHTTP_ERROR_BASE + 37);
  ERROR_WINHTTP_SECURE_CERT_CN_INVALID = (WINHTTP_ERROR_BASE + 38);
  ERROR_WINHTTP_SECURE_INVALID_CA = (WINHTTP_ERROR_BASE + 45);
  ERROR_WINHTTP_SECURE_CERT_REV_FAILED = (WINHTTP_ERROR_BASE + 57);
  ERROR_WINHTTP_SECURE_CHANNEL_ERROR = (WINHTTP_ERROR_BASE + 157);
  ERROR_WINHTTP_SECURE_INVALID_CERT = (WINHTTP_ERROR_BASE + 169);
  ERROR_WINHTTP_SECURE_CERT_REVOKED = (WINHTTP_ERROR_BASE + 170);
  ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE = (WINHTTP_ERROR_BASE + 179);


  ERROR_WINHTTP_AUTODETECTION_FAILED = (WINHTTP_ERROR_BASE + 180);
  ERROR_WINHTTP_HEADER_COUNT_EXCEEDED = (WINHTTP_ERROR_BASE + 181);
  ERROR_WINHTTP_HEADER_SIZE_OVERFLOW = (WINHTTP_ERROR_BASE + 182);
  ERROR_WINHTTP_CHUNKED_ENCODING_HEADER_SIZE_OVERFLOW = (WINHTTP_ERROR_BASE + 183);
  ERROR_WINHTTP_RESPONSE_DRAIN_OVERFLOW = (WINHTTP_ERROR_BASE + 184);

  WINHTTP_ERROR_LAST = (WINHTTP_ERROR_BASE + 184);

  //This flag provides the same behavior as WINHTTP_FLAG_REFRESH.
  WINHTTP_FLAG_BYPASS_PROXY_CACHE = $00000100;

  (*Unsafe characters in the URL passed in for pwszObjectName
  are not converted to escape sequences.*)
  WINHTTP_FLAG_ESCAPE_DISABLE = $00000040;

  (*Unsafe characters in the query component of the URL passed in for
  pwszObjectName are not converted to escape sequences.*)
  WINHTTP_FLAG_ESCAPE_DISABLE_QUERY = $00000080;

  (*The string passed in for pwszObjectName is converted from an LPCWSTR
  to an LPSTR. All unsafe characters are converted to an escape sequence
  including the percent symbol. By default, all unsafe characters except
  the percent symbol are converted to an escape sequence.*)
  WINHTTP_FLAG_ESCAPE_PERCENT = $00000004;

  (*The string passed in for pwszObjectName is assumed to consist of valid
  ANSI characters represented by WCHAR. No check are done for unsafe characters.
  Windows 7:  This option is obsolete.*)
  WINHTTP_FLAG_NULL_CODEPAGE = $00000008;

  (*Indicates that the request should be forwarded to the originating server
  rather than sending a cached version of a resource from a proxy server.
  When this flag is used, a "Pragma: no-cache" header is added to the
  request handle. When creating an HTTP/1.1 request header,
  a "Cache-Control: no-cache" is also added.*)
  WINHTTP_FLAG_REFRESH = WINHTTP_FLAG_BYPASS_PROXY_CACHE;

  (*Uses secure transaction semantics. This translates to using
  Secure Sockets Layer (SSL)/Transport Layer Security (TLS).*)
  WINHTTP_FLAG_SECURE = $00800000;

  SECURITY_FLAG_IGNORE_UNKNOWN_CA = $00000100;
  SECURITY_FLAG_IGNORE_CERT_DATE_INVALID = $00002000; // expired X509 Cert.
  SECURITY_FLAG_IGNORE_CERT_CN_INVALID = $00001000; // bad common name in X509 Cert.
  SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE = $00000200;

  // query only
  SECURITY_FLAG_SECURE = $00000001; // can query only
  SECURITY_FLAG_STRENGTH_WEAK = $10000000;
  SECURITY_FLAG_STRENGTH_MEDIUM = $40000000;
  SECURITY_FLAG_STRENGTH_STRONG = $20000000;


  WINHTTP_QUERY_MIME_VERSION = 0;
  WINHTTP_QUERY_CONTENT_TYPE = 1;
  WINHTTP_QUERY_CONTENT_TRANSFER_ENCODING = 2;
  WINHTTP_QUERY_CONTENT_ID = 3;
  WINHTTP_QUERY_CONTENT_DESCRIPTION = 4;
  WINHTTP_QUERY_CONTENT_LENGTH = 5;
  WINHTTP_QUERY_CONTENT_LANGUAGE = 6;
  WINHTTP_QUERY_ALLOW = 7;
  WINHTTP_QUERY_PUBLIC = 8;
  WINHTTP_QUERY_DATE = 9;
  WINHTTP_QUERY_EXPIRES = 10;
  WINHTTP_QUERY_LAST_MODIFIED = 11;
  WINHTTP_QUERY_MESSAGE_ID = 12;
  WINHTTP_QUERY_URI = 13;
  WINHTTP_QUERY_DERIVED_FROM = 14;
  WINHTTP_QUERY_COST = 15;
  WINHTTP_QUERY_LINK = 16;
  WINHTTP_QUERY_PRAGMA = 17;
  WINHTTP_QUERY_VERSION = 18; // special: part of status line
  WINHTTP_QUERY_STATUS_CODE = 19; // special: part of status line
  WINHTTP_QUERY_STATUS_TEXT = 20; // special: part of status line
  WINHTTP_QUERY_RAW_HEADERS = 21; // special: all headers as ASCIIZ
  WINHTTP_QUERY_RAW_HEADERS_CRLF = 22; // special: all headers
  WINHTTP_QUERY_CONNECTION = 23;
  WINHTTP_QUERY_ACCEPT = 24;
  WINHTTP_QUERY_ACCEPT_CHARSET = 25;
  WINHTTP_QUERY_ACCEPT_ENCODING = 26;
  WINHTTP_QUERY_ACCEPT_LANGUAGE = 27;
  WINHTTP_QUERY_AUTHORIZATION = 28;
  WINHTTP_QUERY_CONTENT_ENCODING = 29;
  WINHTTP_QUERY_FORWARDED = 30;
  WINHTTP_QUERY_FROM = 31;
  WINHTTP_QUERY_IF_MODIFIED_SINCE = 32;
  WINHTTP_QUERY_LOCATION = 33;
  WINHTTP_QUERY_ORIG_URI = 34;
  WINHTTP_QUERY_REFERER = 35;
  WINHTTP_QUERY_RETRY_AFTER = 36;
  WINHTTP_QUERY_SERVER = 37;
  WINHTTP_QUERY_TITLE = 38;
  WINHTTP_QUERY_USER_AGENT = 39;
  WINHTTP_QUERY_WWW_AUTHENTICATE = 40;
  WINHTTP_QUERY_PROXY_AUTHENTICATE = 41;
  WINHTTP_QUERY_ACCEPT_RANGES = 42;
  WINHTTP_QUERY_SET_COOKIE = 43;
  WINHTTP_QUERY_COOKIE = 44;
  WINHTTP_QUERY_REQUEST_METHOD = 45; // special: GET/POST etc.
  WINHTTP_QUERY_REFRESH = 46;
  WINHTTP_QUERY_CONTENT_DISPOSITION = 47;

  // HTTP 1.1 defined headers
  WINHTTP_QUERY_AGE = 48;
  WINHTTP_QUERY_CACHE_CONTROL = 49;
  WINHTTP_QUERY_CONTENT_BASE = 50;
  WINHTTP_QUERY_CONTENT_LOCATION = 51;
  WINHTTP_QUERY_CONTENT_MD = 5 = 52;
  WINHTTP_QUERY_CONTENT_RANGE = 53;
  WINHTTP_QUERY_ETAG = 54;
  WINHTTP_QUERY_HOST = 55;
  WINHTTP_QUERY_IF_MATCH = 56;
  WINHTTP_QUERY_IF_NONE_MATCH = 57;
  WINHTTP_QUERY_IF_RANGE = 58;
  WINHTTP_QUERY_IF_UNMODIFIED_SINCE = 59;
  WINHTTP_QUERY_MAX_FORWARDS = 60;
  WINHTTP_QUERY_PROXY_AUTHORIZATION = 61;
  WINHTTP_QUERY_RANGE = 62;
  WINHTTP_QUERY_TRANSFER_ENCODING = 63;
  WINHTTP_QUERY_UPGRADE = 64;
  WINHTTP_QUERY_VARY = 65;
  WINHTTP_QUERY_VIA = 66;
  WINHTTP_QUERY_WARNING = 67;
  WINHTTP_QUERY_EXPECT = 68;
  WINHTTP_QUERY_PROXY_CONNECTION = 69;
  WINHTTP_QUERY_UNLESS_MODIFIED_SINCE = 70;



  WINHTTP_QUERY_PROXY_SUPPORT = 75;
  WINHTTP_QUERY_AUTHENTICATION_INFO = 76;
  WINHTTP_QUERY_PASSPORT_URLS = 77;
  WINHTTP_QUERY_PASSPORT_CONFIG = 78;

  WINHTTP_QUERY_MAX = 78;


  (*WINHTTP_QUERY_CUSTOM - if this special value is supplied as the dwInfoLevel
  parameter of WinHttpQueryHeaders() then the lpBuffer parameter contains the name
  of the header we are to query*)
  WINHTTP_QUERY_CUSTOM = 65535;

  (*WINHTTP_QUERY_FLAG_REQUEST_HEADERS - if this bit is set in the dwInfoLevel
  parameter of WinHttpQueryHeaders() then the request headers will be queried for the
  request information*)
  WINHTTP_QUERY_FLAG_REQUEST_HEADERS = $80000000;

  (*WINHTTP_QUERY_FLAG_SYSTEMTIME - if this bit is set in the dwInfoLevel parameter
  of WinHttpQueryHeaders() AND the header being queried contains date information,
  e.g. the "Expires:" header then lpBuffer will contain a SYSTEMTIME structure
  containing the date and time information converted from the header string*)
  WINHTTP_QUERY_FLAG_SYSTEMTIME = $40000000;

  (*WINHTTP_QUERY_FLAG_NUMBER - if this bit is set in the dwInfoLevel parameter of
  HttpQueryHeader(), then the value of the header will be converted to a number
  before being returned to the caller, if applicable*)
  WINHTTP_QUERY_FLAG_NUMBER = $20000000;

  //WinHttpQueryHeaders prettifiers for optional parameters.
  WINHTTP_HEADER_NAME_BY_INDEX = nil;
  WINHTTP_NO_OUTPUT_BUFFER = nil;
  WINHTTP_NO_HEADER_INDEX = nil;



  WINHTTP_OPTION_CALLBACK = 1;
  WINHTTP_OPTION_RESOLVE_TIMEOUT = 2;
  WINHTTP_OPTION_CONNECT_TIMEOUT = 3;
  WINHTTP_OPTION_CONNECT_RETRIES = 4;
  WINHTTP_OPTION_SENDING_TIMEOUT = 5;
  WINHTTP_OPTION_RECEIVE_TIMEOUT = 6;
  WINHTTP_OPTION_RECEIVE_RESPONSE_TIMEOUT = 7;
  WINHTTP_OPTION_HANDLE_TYPE = 9;
  WINHTTP_OPTION_READ_BUFFER_SIZE = 12;
  WINHTTP_OPTION_WRITE_BUFFER_SIZE = 13;
  WINHTTP_OPTION_PARENT_HANDLE = 21;
  WINHTTP_OPTION_EXTENDED_ERROR = 24;
  WINHTTP_OPTION_SECURITY_FLAGS = 31;
  WINHTTP_OPTION_SECURITY_CERTIFICATE_STRUCT = 32;
  WINHTTP_OPTION_URL = 34;
  WINHTTP_OPTION_SECURITY_KEY_BITNESS = 36;
  WINHTTP_OPTION_PROXY = 38;


  WINHTTP_OPTION_USER_AGENT = 41;
  WINHTTP_OPTION_CONTEXT_VALUE = 45;
  WINHTTP_OPTION_CLIENT_CERT_CONTEXT = 47;
  WINHTTP_OPTION_REQUEST_PRIORITY = 58;
  WINHTTP_OPTION_HTTP_VERSION = 59;
  WINHTTP_OPTION_DISABLE_FEATURE = 63;

  WINHTTP_OPTION_CODEPAGE = 68;
  WINHTTP_OPTION_MAX_CONNS_PER_SERVER = 73;
  WINHTTP_OPTION_MAX_CONNS_PER_1_0_SERVER = 74;
  WINHTTP_OPTION_AUTOLOGON_POLICY = 77;
  WINHTTP_OPTION_SERVER_CERT_CONTEXT = 78;
  WINHTTP_OPTION_ENABLE_FEATURE = 79;
  WINHTTP_OPTION_WORKER_THREAD_COUNT = 80;
  WINHTTP_OPTION_PASSPORT_COBRANDING_TEXT = 81;
  WINHTTP_OPTION_PASSPORT_COBRANDING_URL = 82;
  WINHTTP_OPTION_CONFIGURE_PASSPORT_AUTH = 83;
  WINHTTP_OPTION_SECURE_PROTOCOLS = 84;
  WINHTTP_OPTION_ENABLETRACING = 85;
  WINHTTP_OPTION_PASSPORT_SIGN_OUT = 86;
  WINHTTP_OPTION_PASSPORT_RETURN_URL = 87;
  WINHTTP_OPTION_REDIRECT_POLICY = 88;
  WINHTTP_OPTION_MAX_HTTP_AUTOMATIC_REDIRECTS = 89;
  WINHTTP_OPTION_MAX_HTTP_STATUS_CONTINUE = 90;
  WINHTTP_OPTION_MAX_RESPONSE_HEADER_SIZE = 91;
  WINHTTP_OPTION_MAX_RESPONSE_DRAIN_SIZE = 92;

  WINHTTP_FIRST_OPTION = WINHTTP_OPTION_CALLBACK;
  WINHTTP_LAST_OPTION = WINHTTP_OPTION_MAX_RESPONSE_DRAIN_SIZE;

  WINHTTP_OPTION_USERNAME = $1000;
  WINHTTP_OPTION_PASSWORD = $1001;
  WINHTTP_OPTION_PROXY_USERNAME = $1002;
  WINHTTP_OPTION_PROXY_PASSWORD = $1003;


// manifest value for WINHTTP_OPTION_MAX_CONNS_PER_SERVER and WINHTTP_OPTION_MAX_CONNS_PER_1_0_SERVER
  WINHTTP_CONNS_PER_SERVER_UNLIMITED = $FFFFFFFF;


// values for WINHTTP_OPTION_AUTOLOGON_POLICY
  WINHTTP_AUTOLOGON_SECURITY_LEVEL_MEDIUM = 0;
  WINHTTP_AUTOLOGON_SECURITY_LEVEL_LOW = 1;
  WINHTTP_AUTOLOGON_SECURITY_LEVEL_HIGH = 2;

  WINHTTP_AUTOLOGON_SECURITY_LEVEL_DEFAULT = WINHTTP_AUTOLOGON_SECURITY_LEVEL_MEDIUM;

// values for WINHTTP_OPTION_REDIRECT_POLICY
  WINHTTP_OPTION_REDIRECT_POLICY_NEVER = 0;
  WINHTTP_OPTION_REDIRECT_POLICY_DISALLOW_HTTPS_TO_HTTP = 1;
  WINHTTP_OPTION_REDIRECT_POLICY_ALWAYS = 2;

  WINHTTP_OPTION_REDIRECT_POLICY_LAST = WINHTTP_OPTION_REDIRECT_POLICY_ALWAYS;
  WINHTTP_OPTION_REDIRECT_POLICY_DEFAULT = WINHTTP_OPTION_REDIRECT_POLICY_DISALLOW_HTTPS_TO_HTTP;

  WINHTTP_DISABLE_PASSPORT_AUTH = $00000000;
  WINHTTP_ENABLE_PASSPORT_AUTH = $10000000;
  WINHTTP_DISABLE_PASSPORT_KEYRING = $20000000;
  WINHTTP_ENABLE_PASSPORT_KEYRING = $40000000;



  // values for WINHTTP_OPTION_DISABLE_FEATURE
  WINHTTP_DISABLE_COOKIES = $00000001;
  WINHTTP_DISABLE_REDIRECTS = $00000002;
  WINHTTP_DISABLE_AUTHENTICATION = $00000004;
  WINHTTP_DISABLE_KEEP_ALIVE = $00000008;

  // values for WINHTTP_OPTION_ENABLE_FEATURE
  WINHTTP_ENABLE_SSL_REVOCATION = $00000001;
  WINHTTP_ENABLE_SSL_REVERT_IMPERSONATION = $00000002;

  WINHTTP_NO_REFERER = PWideChar(nil);
  WINHTTP_DEFAULT_ACCEPT_TYPES = PLPWSTR(nil);

  WINHTTP_NO_ADDITIONAL_HEADERS = PWideChar(nil);
  WINHTTP_NO_REQUEST_DATA = nil;

  //values for dwModifiers parameter of WinHttpAddrequest_headers()
  WINHTTP_ADDREQ_INDEX_MASK = $0000FFFF;
  WINHTTP_ADDREQ_FLAGS_MASK = $FFFF0000;

  (*WINHTTP_ADDREQ_FLAG_ADD_IF_NEW - the header will only be added
  if it doesn't already exist*)
  WINHTTP_ADDREQ_FLAG_ADD_IF_NEW = $10000000;

  (*WINHTTP_ADDREQ_FLAG_ADD - if WINHTTP_ADDREQ_FLAG_REPLACE is set but the header is
  not found then if this flag is set, the header is added anyway, so long as
  there is a valid header-value*)
  WINHTTP_ADDREQ_FLAG_ADD = $20000000;

  (*WINHTTP_ADDREQ_FLAG_COALESCE - coalesce headers with same name. e.g.
  "Accept: text/*" and "Accept: audio/*" with this flag results in a single
  header: "Accept: text/*, audio/*"*)
  WINHTTP_ADDREQ_FLAG_COALESCE_WITH_COMMA = $40000000;
  WINHTTP_ADDREQ_FLAG_COALESCE_WITH_SEMICOLON = $01000000;
  WINHTTP_ADDREQ_FLAG_COALESCE = WINHTTP_ADDREQ_FLAG_COALESCE_WITH_COMMA;


  (*WINHTTP_ADDREQ_FLAG_REPLACE - replaces the specified header. Only one header can
  be supplied in the buffer. If the header to be replaced is not the first
  in a list of headers with the same name, then the relative index should be
  supplied in the low 8 bits of the dwModifiers parameter. If the header-value
  part is missing, then the header is removed*)
  WINHTTP_ADDREQ_FLAG_REPLACE = $80000000;

type
  HINTERNET = Pointer;
{$EXTERNALSYM HINTERNET}
  PHINTERNET = ^HINTERNET;
  LPHINTERNET = PHINTERNET;
{$EXTERNALSYM LPHINTERNET}

  INTERNET_PORT = Word;
{$EXTERNALSYM INTERNET_PORT}
  PINTERNET_PORT = ^INTERNET_PORT;
  LPINTERNET_PORT = PINTERNET_PORT;
{$EXTERNALSYM LPINTERNET_PORT}

  URL_COMPONENTS = packed record
    dwStructSize: DWORD;
    lpszScheme: PWideChar;
    dwSchemeLength: DWORD;
    nScheme: Integer;
    lpszHostName: PWideChar;
    dwHostNameLength: DWORD;
    nPort: INTERNET_PORT;
    align: Word;
    lpszUserName: PWideChar;
    dwUserNameLength: DWORD;
    lpszPassword: PWideChar;
    dwPasswordLength: DWORD;
    lpszUrlPath: PWideChar;
    dwUrlPathLength: DWORD;
    lpszExtraInfo: PWideChar;
    dwExtraInfoLength: DWORD;
  end;
  LPURL_COMPONENTS = ^URL_COMPONENTS;

  WINHTTP_PROXY_INFO = packed record
    dwAccessType: DWORD;
    lpszProxy: LPWSTR;
    lpszProxyBypass: LPWSTR;
  end;
  LPWINHTTP_PROXY_INFO = ^WINHTTP_PROXY_INFO;

function WinHttpOpen(pwszUserAgent: PWideChar; dwAccessType: DWORD;
  pwszProxyName, pwszProxyBypass: PWideChar;
  dwFlags: DWORD): HINTERNET; stdcall;

function WinHttpConnect(hSession: HINTERNET; pswzServerName: PWideChar;
  nServerPort: INTERNET_PORT; dwReserved: DWORD): HINTERNET; stdcall;

function WinHttpOpenRequest(hConnect: HINTERNET; pwszVerb: PWideChar;
  pwszObjectName: PWideChar; pwszVersion: PWideChar; pwszReferer: PWideChar;
  ppwszAcceptTypes: PLPWSTR; dwFlags: DWORD): HINTERNET; stdcall;

function WinHttpCloseHandle(HINTERNET: HINTERNET): BOOL; stdcall;

function WinHttpAddrequest_headers(hRequest: HINTERNET; pwszHeaders: PWideChar;
  dwHeadersLength: DWORD; dwModifiers: DWORD): BOOL; stdcall;

function WinHttpSendRequest(hRequest: HINTERNET; pwszHeaders: PWideChar;
  dwHeadersLength: DWORD; lpOptional: Pointer; dwOptionalLength: DWORD;
  dwTotalLength: DWORD; dwContext: DWORD): BOOL; stdcall;

function WinHttpReceiveResponse(hRequest: HINTERNET;
  lpReserved: Pointer): BOOL; stdcall;

function WinHttpQueryHeaders(hRequest: HINTERNET; dwInfoLevel: DWORD;
  pwszName: PWideChar; lpBuffer: Pointer; var lpdwBufferLength: DWORD;
  lpdwIndex: PDWORD): BOOL; stdcall;

function WinHttpQueryOption(hInternet: HINTERNET; dwOption: DWORD;
  lpBuffer: Pointer; lpdwBufferLength: LPDWORD): BOOL; stdcall;

function WinHttpReadData(hRequest: HINTERNET; lpBuffer: Pointer;
  BytesToRead: DWORD; var BytesRead: DWORD): BOOL; stdcall;

function WinHttpWriteData(hRequest: HINTERNET;
  lpBuffer: Pointer; dwNumberOfBytesToWrite: DWORD;
  pdwNumberOfBytesWritten: PDWORD): BOOL; stdcall;

function WinHttpSetOption(HINTERNET: HINTERNET; dwOption: DWORD;
  lpBuffer: Pointer; dwBufferLength: DWORD): BOOL; stdcall;

function WinHttpCheckPlatform(): BOOL; stdcall;

function WinHttpSetTimeouts(HINTERNET: HINTERNET;
  dwresolving_timeout, dwconnecting_timeout: DWORD;
  dwsending_timeout, dwReceiveTimeout: DWORD): BOOL; stdcall;

function WinHttpDetectAutoProxyConfigUrl(
  dwAutoDetectFlags: DWORD;
  ppwszAutoConfigUrl: PPWideChar): BOOL; stdcall;


function WinHttpTimeFromSystemTime(const pst: SYSTEMTIME;
  pwszTime: PWideChar): BOOL; stdcall;

function WinHttpTimeToSystemTime(pwszTime: PWideChar;
  out pst: SYSTEMTIME): BOOL; stdcall;

function WinHttpCrackUrl(pwszUrl: PWideChar;
  dwUrlLength, dwFlags: DWORD;
  out lpUrlComponents: URL_COMPONENTS): BOOL; stdcall;

implementation

function WinHttpOpen; stdcall; external WinHttpDLL;

function WinHttpConnect; stdcall; external WinHttpDLL;

function WinHttpOpenRequest; stdcall; external WinHttpDLL;

function WinHttpCloseHandle; stdcall; external WinHttpDLL;

function WinHttpAddrequest_headers; stdcall; external WinHttpDLL;

function WinHttpSendRequest; stdcall; external WinHttpDLL;

function WinHttpReceiveResponse; stdcall; external WinHttpDLL;

function WinHttpQueryHeaders; stdcall; external WinHttpDLL;

function WinHttpReadData; stdcall; external WinHttpDLL;

function WinHttpWriteData; stdcall; external WinHttpDLL;

function WinHttpSetOption; stdcall; external WinHttpDLL;

function WinHttpCheckPlatform; stdcall; external WinHttpDLL;

function WinHttpSetTimeouts; stdcall; external WinHttpDLL;

function WinHttpDetectAutoProxyConfigUrl; stdcall; external WinHttpDLL;

function WinHttpTimeFromSystemTime; stdcall; external WinHttpDLL;

function WinHttpTimeToSystemTime; stdcall; external WinHttpDLL;

function WinHttpCrackUrl; stdcall; external WinHttpDLL;

function WinHttpQueryOption; stdcall; external WinHttpDLL;

end.
