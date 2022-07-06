unit DSLSocket;

interface

uses
  SysUtils, Classes, Windows, StrUtils, SyncObjs, DSLWinsock2, MSWSock, WS2tcpip,
  OpenSSLTypes, openssl, DSLUtils, DSLCrypto;

const
  MAX_DOMAINNAME_LENGTH = 64;

type
  TIPAddress = array [0..40] of AnsiChar;
  PIPAddress = ^TIPAddress;

  TSockAddrInHelper = record helper for TSockAddrIn
  public
    constructor Create(ip: UInt32; _port: Word); overload;
    constructor Create(const ip: RawByteString; _port: Word); overload;
    function IP2Str: string;
    function IP2RBStr: RawByteString;
    function IP2UStr: UnicodeString;
    function port: Word;
  end;

  TSockAddrIn6Helper = record helper for TSockAddrIn6
  public
    constructor Create(const ip: array of Byte; _port: Word); overload;
    constructor Create(ip: TIn6Addr; _port: Word); overload;
    constructor Create(const ip: RawByteString; _port: Word); overload;
    function IP2Str(compress: Boolean): string;
    function IP2RBStr(compress: Boolean): RawByteString;
    function IP2UStr(compress: Boolean): UnicodeString;
    function port: Word;
  end;

  TArrayOfInAddr = record
    count: Integer;
    items: array [0..1023] of TInAddr;
  end;
  PArrayOfInAddr = ^TArrayOfInAddr;

  TSocketReadWriteFlag = (iofOutOfBand, iofPeek, iofDontRoute, iofInterrupt, iofPartial);

  TSocketReadWriteFlags = set of TSocketReadWriteFlag;

  TEndPoint = record
    procedure setAddr(const ip: RawByteString; _port: Word); overload;
    procedure setAddr(ip: UInt32; _port: Word); overload;
    procedure setAddr(const ip: array of Byte; _port: Word); overload;
    procedure setAddr(ip: TIn6Addr; _port: Word); overload;
    procedure setAddr(ip: PAnsiChar; _port: Word); overload;
    function IP2Str: string;
    function IP2RBStr: RawByteString;
    function IP2UStr: UnicodeString;
    function family: Integer;
    function port: Word;
    function bytes: Integer;
    function toString: string;
    case Integer of
      0: (unknown: TSockAddr);
      1: (ipv4: TSockAddrIn);
      2: (ipv6: TSockAddrIn6);
      3: (zeros: array[0..SizeOf(TSockAddrIn6) - 1] of AnsiChar);
  end;
  PEndPoint = ^TEndPoint;

  _TEndPointCreator = record
    FuckEmbarcadero: Integer;
    function Create(ip: UInt32; port: Word): TEndPoint; overload;
    function Create(const ip: array of Byte; port: Word): TEndPoint; overload;
    function Create(ip: TIn6Addr; port: Word): TEndPoint; overload;
    function Create(const ip: RawByteString; port: Word): TEndPoint; overload;
    function Create(ip: PAnsiChar; port: Word): TEndPoint; overload;
    function Create(const IP_Port: string; const DefaultIP: RawByteString = '0.0.0.0';
      DefaultPort: Integer = 0): TEndPoint; overload;
  end;

var
  TEndPointCreator: _TEndPointCreator;

type
  { 套接字角色类型 }
  TSocketRole = (
    srDatagram,         { 无连接协议套接字 }
    srStreamListener,   { 流式协议的监听套接字 }
    srStreamServerConnection,   { 流式协议的服务端连接 }
    srStreamClient    { 流式协议的客户端 }
  );
  PSocketRole = ^TSocketRole;

  TSocketOperation = (
    soAccept,      // AcceptEx
    soConnect,     // ConnectEx
    soSend,        // WSASend
    soRecv,        // WSARecv
    soSendTo,      // WSASendTo
    soRecvFrom,    // WSARecvFrom
    soClose,       // closesocket
    soDisconnect); //DisconnectEx
  PSocketOperation = ^TSocketOperation;

  ESocketException = class(Exception)
  private
    fFunctionName: string;
    fErrorCode: Integer;
  public
    constructor Create(err: Integer; const func: string); overload;
    property FunctionName: string read fFunctionName;
    property ErrorCode: Integer read fErrorCode;
  end;

  EInvalidSockAddr = class(ESocketException)
  public
    constructor CreateWith(const Intf: string);
  end;

  EAddrInUse = class(ESocketException)
  private
    FEndPoint: TEndPoint;
  public
    constructor Create(const func: string; const _EndPoint: TEndPoint);
    property EndPoint: TEndPoint read FEndPoint;
  end;

  EAlreadyBound = class(ESocketException);

  EConnectionClosed = class(ESocketException);

  EPortUnreachable = class(ESocketException)
  private
    FEndPoint: TEndPoint;
  public
    constructor Create(const _EndPoint: TEndPoint);
    property EndPoint: TEndPoint read FEndPoint;
  end;

  EWouldBlock = class(ESocketException)
  public
    constructor Create(const func: string);
  end;

  TSocketEvent = (seRead, seWrite, seConnect, seAccept, seClose);
  TSocketEvents = set of TSocketEvent;

function InAddr_IsPrivate(ip: LongWord): Boolean; overload;
function InAddr_IsPrivate(ip: PAnsiChar): Boolean; overload;
function InAddr_IsPrivate(const ip: RawByteString): Boolean; overload;
function IPv4ToStr(ip: LongWord): RawByteString; overload;
function IPv4ToStr(ip: TInAddr): RawByteString; overload;
function StrToIP4(str: PAnsiChar; len: Integer; out ip: UInt32):Boolean;
function isIP4(const str: RawByteString): Boolean; overload;
function isIP4(str: PAnsiChar; len: Integer):Boolean; overload;
function inet6_addr(str: PAnsiChar; len: Integer; var addr: IN6_ADDR): Boolean;
function StrToInAddr6(const Str: RawByteString; var addr: IN6_ADDR): Boolean;
function inet6_ntoa(const addr: IN6_ADDR; buf: PAnsiChar; compress: Boolean): Integer;
function InAddr6ToStr(const addr: IN6_ADDR; compress: Boolean): RawByteString;
function ExtractIP(const binding: TSockAddr): RawByteString;
function getNumberOfIP(host: PAnsiChar; af: Integer = -1):Integer;
function getIPv4AddressCount(host: PAnsiChar): Integer;
function getIPv6AddressCount(host: PAnsiChar): Integer;
function isAddressOfHost(host: PAnsiChar; af: Integer; addr: Pointer): Boolean;
procedure GetAddressList(host: PAnsiChar; ips: TStrings; af: Integer = -1);
procedure GetIPv4AddressList(host: PAnsiChar; ips: TStrings); overload;
procedure GetIPv6AddressList(host: PAnsiChar; ips: TStrings);
function getIPv4AddressList(host: PAnsiChar; addrs: PArrayOfInAddr): Integer; overload;
function getHostIP4(host: PAnsiChar): LongWord;
function getHostIP6(host: PAnsiChar; out addr: TInAddr6): Boolean;
function getHostNameOfIP(const szIP: RawByteString): RawByteString;
function getLocalHostName: RawByteString;

function SocketEvent_SetToMask(Events: TSocketEvents): UInt32;
function convertWinsockError(errcode: Integer): TCommunicationErrorCode;

var
  AcceptEx: LPFN_ACCEPTEX = nil;
  GetAcceptExSockAddrs: LPFN_GETACCEPTEXSOCKADDRS = nil;
  ConnectEx: LPFN_CONNECTEX = nil;
  TransmitFile: LPFN_TRANSMITFILE = nil;
  DisconnectEx: LPFN_DISCONNECTEX = nil;

type
  TCustomSocket = class;
  TDgramSocket = class;
  TConnectionSocket = class;
  TClientSocket = class;
  TServerConnection = class;
  TCustomServerSocket = class;
  TServerConnectionClass = class of TServerConnection;

  EInactiveSocket = class(Exception);
  EActiveSocket = class(Exception);
  EInvalidSocket = class(Exception);
  EValidSocket = class(Exception);

  TCustomSocket = class(TRefCountedObject)
  private
    FHandle: TSocketId;
    function getAddressFamily: Integer;
    procedure setBlocking(const Value: Boolean);
    function getReadableBytes: Integer;
    function isHandleAllocated: Boolean; inline;
    procedure setExclusiveAddr(const Value: Boolean);
    procedure setReuseAddr(value: Boolean);
    function getInputBufferSize: Integer;
    procedure setInputBufferSize(const Value: Integer);
    function getOutputBufferSize: Integer;
    procedure setOutputBufferSize(const Value: Integer);
    function getRecvTimeout: Integer;
    function getSendTimeout: Integer;
    procedure setRecvTimeout(const Value: Integer);
    procedure setSendTimeout(const Value: Integer);
  protected
    procedure throwException(const operation: string; code: Integer);
    procedure bindError(const EndPoint: TEndPoint; code: Integer);
    function reportError(const operation: string; code: Integer; pErrorCode: PInteger): Boolean; overload;
    function reportError(const operation: string; code: Integer; pError: PCommunicationError): Boolean; overload;
  public
    constructor Create;
    destructor Destroy; override;
    function close: Boolean;
    function closeAndRelease: Boolean;
    function allocateHandle(_AddressFamily, SocketType: Integer; pErrorCode: PInteger = nil): Boolean;
    function deallocateHandle: Boolean;
    function bind(const EndPoint: TEndPoint; pErrorCode: PInteger = nil): Boolean;
    function getIntOption(level, option: UInt32; var value: Integer; pErrorCode: PInteger = nil): Boolean;
    function SetIntOption(level: UInt32; option: UInt32; value: Integer; pErrorCode: PInteger = nil): Boolean;
    function getLocalEndPoint: TEndPoint;
    function readable(timeout: UInt32): Boolean;
    function writable(timeout: UInt32): Boolean;
    property handle: TSocketId read FHandle;
    property handleAllocated: Boolean read isHandleAllocated;
    property addressFamily: Integer read getAddressFamily;
    property blocking: Boolean write setBlocking;
    property exclusiveAddr: Boolean write setExclusiveAddr;
    property reuseAddr: Boolean write setReuseAddr;
    property readableBytes: Integer read getReadableBytes;
    property inputBufferSize: Integer read getInputBufferSize write setInputBufferSize;
    property outputBufferSize: Integer read getOutputBufferSize write setOutputBufferSize;
    property sendTimeout: Integer read getSendTimeout write setSendTimeout;
    property recvTimeout: Integer read getRecvTimeout write setRecvTimeout;
  end;

  TUdpDataEvent = procedure(sender: TDgramSocket; const peerAddr: TEndPoint;
    const buf; bufSize: Integer) of object;

  TDgramSocket = class(TCustomSocket)
  public
    procedure open; overload;
    procedure open(EndPoint: TEndPoint); overload;
    procedure EnableBroadcast(const Value: Boolean);

    function sendTo(const target: TEndPoint; const buf; BufLen: DWORD;
      pError: PCommunicationError = nil; flags: DWORD = 0): Boolean;

    procedure writeInt32(const target: TEndPoint; value: UInt32);
    procedure writeWord(const target: TEndPoint; value: Word);
    procedure writeFloat(const target: TEndPoint; value: Double);
    procedure writeBytes(const target: TEndPoint; const s: TBytes);
    procedure writeRBStr(const target: TEndPoint; const s: RawByteString);
    procedure writeUStr(const target: TEndPoint; const s: UnicodeString);
    procedure writeBStr(const target: TEndPoint; const s: WideString);
    procedure broadcast(port: Word; const buf; BufLen: Integer);
    procedure BroadcastRBStr(port: Word; const s: RawByteString);
    procedure BroadcastUStr(port: Word; const s: UnicodeString);

    function recvFrom(var from: TEndPoint; var buf; BufLen: DWORD;
      pError: PCommunicationError = nil; flags: PDWORD = nil): Integer;

    function readRBStr(var from: TEndPoint; flags: PDWORD = nil): RawByteString;
    function readUStr(var from: TEndPoint; flags: PDWORD = nil): UnicodeString;
    function readString(var from: TEndPoint; flags: PDWORD = nil): string;
    function readInt32(var from: TEndPoint; flags: PDWORD = nil): Integer;
    function readWord(var from: TEndPoint; flags: PDWORD = nil): Word;
    function readFloat(var from: TEndPoint; flags: PDWORD = nil): Double;
  end;

  TShutDownType = (sdRead, sdWrite, sdBoth);
  TConnectionSocket = class(TCustomSocket)
  private
    FRemoteEndPoint: TEndPoint;
    FLatestRead: DWORD;
    function getConnectTime: Integer;
    function isConnected: Boolean;
    function getLinger: Boolean;
    function getNagle: Boolean;
    procedure setLinger(const Value: Boolean);
    procedure setNagle(const Value: Boolean);
  protected
    procedure setRemoteEndPoint(const addrData; addrLen: Integer);
    function _write(const buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer;
    function _read(var buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer;
  public
    function write(const buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; virtual; abstract;
    function read(var buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; virtual; abstract;
    function shutDown(ShutType: TShutDownType; pErrorCode: PInteger = nil): Boolean;
    function writeBuffer(const buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Boolean;
    function MultiWrite(const bufs: array of TWsaBuf; pError: PCommunicationError = nil; flags: DWORD = 0): Integer;
    function MultiRead(const bufs: array of TWsaBuf; pError: PCommunicationError = nil; flags: DWORD = 0): Integer;
    procedure readBuffer(var buf; BufLen: DWORD);
    procedure writeInt32(value: UInt32);
    procedure writeWord(value: Word);
    procedure writeFloat(value: Double);
    procedure writeRBStr(const s: RawByteString);
    procedure writeUStr(const s: UnicodeString);
    procedure writeBStr(const s: WideString);
    procedure writeStream(stream: TStream; count: Integer);
    function readRBStr(var str: RawByteString; const TerminalChars: RawByteString = #13#10;
      timeout: DWORD = 0; pError: PCommunicationError = nil): Integer;
    function readUStr(var str: UnicodeString; const TerminalChars: UnicodeString = #13#10;
      timeout: DWORD = 0; pError: PCommunicationError = nil): Integer;
    function readUntil(const c: AnsiChar): RawByteString; overload;
    function readUntil(const chars: array of AnsiChar): RawByteString; overload;
    function readUntil(const c: WideChar): UnicodeString; overload;
    function readUntil(const chars: array of WideChar): UnicodeString; overload;
    function readInteger: Integer;
    function readWord: Word;
    function readDouble: Double;
    function readStream(stream: TStream; count: Integer; buf: Pointer = nil; BufLen: Integer = 0): Integer;
    function readOffset(var buf; BufLen, Offset: Integer): Integer;
    function skip(len: Integer): Integer;
    function getRemoteEndPoint: PEndPoint;
    procedure dataRead(bytesRead: Integer);
  public
    property connectTime: Integer read getConnectTime;
    property connected: Boolean read isConnected;
    property linger: Boolean read getLinger write setLinger;
    property nagle: Boolean read getNagle write setNagle;
    property latestRead: DWORD read FLatestRead;
  end;

  TTcpDataEvent = procedure(connection: TConnectionSocket; const buf; bufSize: Integer) of object;

  TCustomServerSocket = class(TCustomSocket)
  private
    function listen(pErrorCode: PInteger = nil; backlog: Integer = SOMAXCONN): Boolean;
  public
    function open(const EndPoint: TEndPoint; pErrorCode: PInteger = nil): Boolean; overload;
    function open(port: Word; pErrorCode: PInteger = nil): Boolean; overload;
  end;

  TServerSocket = class(TCustomServerSocket)
  public
    function accpet(Connection: TServerConnection; pErrorCode: PInteger = nil): Boolean;
  end;

  TServerConnection = class(TConnectionSocket)
  public
    function write(const buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; override;
    function read(var buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; override;
  end;

  TCustomClientSocket = class(TConnectionSocket)
  protected
    function _connect(const ServerAddr: TSockAddr; AddrLen: Integer; timeout: Integer = 0;
      pError: PCommunicationError = nil): Boolean;
  public
    function connect(const ServerAddr: TSockAddr; AddrLen: Integer; timeout: Integer = 0; pError: PCommunicationError = nil): Boolean; overload; virtual; abstract;
    function connect(const RemoteAddr: RawByteString; RemotePort: Word; timeout: Integer = 0; pError: PCommunicationError = nil): Boolean; overload;
  end;

  TClientSocket = class(TCustomClientSocket)
  public
    function connect(const ServerAddr: TSockAddr; AddrLen: Integer; timeout: Integer = 0;
      pError: PCommunicationError = nil): Boolean; override;
    function write(const buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; override;
    function read(var buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; override;
  end;

  EsslError = class(Exception);

  TsslClientSocket = class(TCustomClientSocket)
  private
    FSSL: POpenSSL_SSL;
    function DoSSLHandshake(pError: PCommunicationError = nil): Boolean;
    function sslReportError(const operation: string; retValue: Integer; pError: PCommunicationError): Boolean;
  public
    function connect(const ServerAddr: TSockAddr; AddrLen: Integer; timeout: Integer = 0;
      pError: PCommunicationError = nil): Boolean; override;

    function ConnectViaHttpProxy(const ServerAddr: TSockAddr; AddrLen: Integer;
      const host, username, password: RawByteString;
      timeout: Integer = 0; pError: PCommunicationError = nil): Boolean;

    function write(const buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; override;
    function read(var buf; BufLen: DWORD; pError: PCommunicationError = nil; flags: DWORD = 0): Integer; override;
    destructor Destroy; override;
  end;

  TServerSocketNotifyEvent = procedure(Sender: TCustomServerSocket; Client: TServerConnection) of object;

  TUDPSocket = class(TDgramSocket)
  private
    procedure setICMPErrorReport(const Value: Boolean);
  public
    property ICMPErrorReport: Boolean write setICMPErrorReport;
  end;

procedure trigger_WSASocket_send_bug;

implementation

uses
  DSLHttp;

function InAddr_IsPrivate(ip: LongWord): Boolean;
begin
  //A类 10.0.0.0--10.255.255.255
  //B类 172.16.0.0--172.31.255.255
  //C类 192.168.0.0--192.168.255.255}
  ip := ntohl(ip);
  Result := ((ip >= $a000000) and (ip <= $affffff)) or
    ((ip >= $ac100000) and (ip <= $ac1fffff)) or
    ((ip >= $c0a80000) and (ip <= $c0a8ffff));
end;

function InAddr_IsPrivate(ip: PAnsiChar): Boolean;
begin
  Result := InAddr_IsPrivate(inet_addr(ip));
end;

function InAddr_IsPrivate(const ip: RawByteString): Boolean; overload;
begin
  Result := InAddr_IsPrivate(inet_addr(PAnsiChar(ip)));
end;

function IPv4ToStr(ip: LongWord): RawByteString;
begin
  Result := inet_ntoa(TInAddr(ip));
end;

function IPv4ToStr(ip: TInAddr): RawByteString;
begin
  Result := inet_ntoa(ip);
end;

function SocketEvent_SetToMask(Events: TSocketEvents): UInt32;
begin
  Result := 0;
  if seRead in Events then Result := Result or FD_READ;
  if seWrite in Events then Result := Result or FD_WRITE;
  if seConnect in Events then Result := Result or FD_CONNECT;
  if seAccept in Events then Result := Result or FD_ACCEPT;
  if seClose in Events then Result := Result or FD_CLOSE;
end;

function convertWinsockError(errcode: Integer): TCommunicationErrorCode;
begin
  case errcode of
    WSAEWOULDBLOCK: Result := comerrWouldBlock;
    WSAETIMEDOUT: Result := comerrTimeout;
    WSAECONNABORTED, WSAECONNRESET: Result := comerrChannelClosed;
    WSAECONNREFUSED: Result := comerrCanNotConnect;
  else
    Result := comerrSysCallFail;
  end;
end;

function convertOpenSSLError(errcode: Integer): TCommunicationErrorCode;
begin
  case errcode of
    SSL_ERROR_NONE: Result := comerrSuccess;
    SSL_ERROR_WANT_READ: Result := comerrCanNotRead;
    SSL_ERROR_WANT_WRITE: Result := comerrCanNotWrite;
  else
    Result := comerrSSLError;
  end;
end;

function getHexCharValue(hc: AnsiChar): Byte;
begin
  if hc in ['0'..'9'] then
    Result := Byte(hc) and $0f
  else if (hc in ['a'..'f']) or
    (hc in ['A'..'F']) then
    Result :=  (Byte(hc) and $0f) + 9
  else Result := $ff;
end;

function WordArrayToStr(buf: PAnsiChar; wa: PWord; cnt: Integer): Integer;
const
  hex_chars: array [0..15] of AnsiChar =
    ('0', '1', '2', '3', '4', '5', '6', '7',
     '8', '9', 'a', 'b', 'c', 'd', 'e', 'f');
var
  i, j, k: Integer;
  w: Word;
  hex: array [0..3] of AnsiChar;
  pwa : PWordArray;
begin
  pwa := PWordArray(wa);
  j := 0;
  for i := 0 to cnt - 1 do
  begin
    w := pwa[i];
    hex[2] := hex_chars[w shr 12];
    hex[3] := hex_chars[(w shr 8) and $000f];
    hex[0] := hex_chars[(w shr 4) and $000f];
    hex[1] := hex_chars[w and $000f];
    k := 0;
    while (hex[k] = '0') and (k < 3) do Inc(k);
    while (k < 4) do
    begin
      buf[j] := hex[k];
      Inc(j);
      Inc(k);
    end;
    buf[j] := ':';
    Inc(j);
  end;

  buf[j - 1] := #0;
  Result := j - 1;
end;

function HexToWord(str: PAnsiChar; var value: Word): Boolean;
var
  i : Integer;
  hc: AnsiChar;
  w: Word;
const
  shr_bits_table: array [0..3] of Integer =
    (12, 8, 4, 0);
begin
  Result := False;
  value := 0;
  for i := 0 to 3 do
  begin
    hc := str[i];
    if hc in ['0'..'9'] then
      w := Byte(hc) and $0f
    else if (hc in ['a'..'f']) or
      (hc in ['A'..'F']) then
      w :=  (Byte(hc) and $0f) + 9
    else Exit;
    value := value or (w shl shr_bits_table[i]);
  end;
  Result := True;
end;

function inet6_addr(str: PAnsiChar; len: Integer; var addr: IN6_ADDR): Boolean;
var
  i, j, k, flag, tl: Integer;
  twoPart: array [0..1] of array [0..7] of Word;
  partLen: array [0..1] of Integer;
  hex: array [0..3] of AnsiChar;
  w: Word;
begin
  Result := False;
  if len <= 1 then Exit;

  i := 0;
  partLen[0] := 0;
  partLen[1] := 0;
  flag := 0;
  while i < len do
  begin
    tl := partLen[0] + partLen[1];
    if (tl >= 8) then Exit;
    j := i;
    while (str[j] <> ':') and (j < len) do Inc(j);

    if (j = i) then
    begin
      if (j = 0) then
      begin
        if str[1] <> ':' then Exit
        else Inc(j);
      end;
      if (flag = 1) then Exit;
      flag := 1;
      Inc(j);
      i := j;
      Continue;
    end;

    if (j >= len) then
    begin
      if (flag = 0) and (tl < 7) then Exit;
    end
    else if (j - i > 4) then Exit;

    tl := 3;
    PInteger(@hex[0])^ := $30303030;
    for k := j - 1 downto i do
    begin
      hex[tl] := str[k];
      Dec(tl);
    end;
    if not HexToWord(hex, w) then Exit;
    w := (w shr 8) or (w shl 8);
    twoPart[flag][partLen[flag]] := w;
    Inc(partLen[flag]);
    Inc(j);
    i := j;
  end;

  if (partLen[0] + partLen[1] < 8) and
    (flag = 0) then Exit;

  for i := 0 to partLen[0] - 1 do
    addr.Word[i] := twoPart[0][i];
  j := partLen[0];
  for i := 0 to (7 - partLen[0] - partLen[1])  do
  begin
    addr.Word[j] := 0;
    Inc(j);
  end;
  for i := 0 to partLen[1] - 1 do
  begin
    addr.Word[j] := twoPart[1][i];
    Inc(j);
  end;

  Result := True;
end;

function StrToInAddr6(const Str: RawByteString; var addr: IN6_ADDR): Boolean;
begin
  Result := inet6_addr(PAnsiChar(Str), Length(Str), addr);
end;

function inet6_ntoa(const addr: IN6_ADDR; buf: PAnsiChar;
  compress: Boolean): Integer;
type
  TContiguousZero = record
    StartIndex: Integer;
    count: Integer;
  end;
var
  current, longest: TContiguousZero;
  i, j, k: Integer;
begin
  longest.count := 0;
  current.count := 0;
  if compress then
  begin
    for i := 0 to 7 do
    begin
      if addr.Word[i] = 0 then
      begin
        Inc(current.count);
        if (current.count = 1) then
          current.StartIndex := i;
      end
      else begin
        if current.count > longest.count then
        begin
          longest.count := current.count;
          longest.StartIndex := current.StartIndex;
        end;
        current.count := 0;
      end;
    end;
  end
  else longest.count := 0;

  if longest.count > 1 then
  begin
    j := 0;
    if longest.StartIndex > 0 then
      Inc(j, WordArrayToStr(buf + j, @addr.Word[0], longest.StartIndex));
    buf[j] := ':';
    Inc(j);
    buf[j] := ':';
    Inc(j);
    k := longest.StartIndex + longest.count;
    if k < 8 then
      Inc(j, WordArrayToStr(buf + j, @addr.Word[k], 8 - k));
  end
  else j := WordArrayToStr(buf, @addr.Word[0], 8);
  Result := j;
end;

function InAddr6ToStr(const addr: IN6_ADDR; compress: Boolean): RawByteString;
var
  buf: array [0..63] of AnsiChar;
begin
  buf[inet6_ntoa(addr, buf, compress)] := #0;
  Result := buf;
end;

function StrToIP4(str: PAnsiChar; len: Integer; out ip: UInt32):Boolean;
var
  i, index, dot: Integer;
  sections: array [0..3] of UInt32;
begin
  Result := False;
  if (str = nil) or (len > 15) or not (str[len - 1] in ['0'..'9']) then Exit;
  Sections[0] := 0;
  Sections[1] := 0;
  sections[2] := 0;
  sections[3] := 0;
  index := 0;
  dot := 0;
  for i := 0 to len - 1 do
  begin
    if str[i] = '.' then
    begin
      if i = dot then Exit;
      if (index >= 3) or (sections[index] > 255) then Exit;
      Inc(index);
      dot := i + 1;
    end
    else if (str[i] in ['0'..'9']) then
      sections[index] := sections[index] * 10 + Byte(str[i]) and $0f
    else Exit;
  end;
  if (index <> 3) or (sections[index] > 255) then Exit;
  ip := (sections[3] shl 24) or (sections[2] shl 16) or
    (sections[1] shl 8) or sections[0];
  Result := True;
end;

function isIP4(str: PAnsiChar; len: Integer):Boolean;
var
  ip: UInt32;
begin
  Result := StrToIP4(str, len, ip);
end;

function isIP4(const str: RawByteString):Boolean;
var
  ip: UInt32;
begin
  Result := StrToIP4(PAnsiChar(str), Length(str), ip);
end;

function ExtractIP(const binding: TSockAddr): RawByteString;
begin
  case binding.sa_family of
    AF_INET: Result := inet_ntoa(TSockAddrIn(binding).sin_addr);
    AF_INET6: Result := InAddr6ToStr(PSockAddrIn6(@binding)^.sin6_addr, True);
    else Result := '';
  end;
end;

function isAddrAny(const binding: TSockAddr): Boolean;
begin
  case binding.sa_family of
    AF_INET: Result := TSockAddrIn(binding).sin_addr.S_addr = 0;
    AF_INET6:
      with PSockAddrIn6(@binding)^.sin6_addr do
        Result := (Dwords[0] = 0) and (Dwords[1] = 0) and
          (Dwords[2] = 0) and (Dwords[3] = 0);
    else Result := False;
  end;
end;

type
  TEnumAddrProc = function(af: Integer; addr, param1, param2: Pointer): Boolean;

function EnumHostAddr(host: PAnsiChar; param1, param2: Pointer; proc: TEnumAddrProc): Boolean;
var
  aip, aiRes: PAddrInfo;
  pent: PHostEnt;
  addrlist: PPAnsiChar;
begin
  if Assigned(getaddrinfo) then
  begin
    if SOCKET_ERROR = getaddrinfo(host, nil, nil, aiRes) then
      raise ESocketException.Create(WSAGetLastError,'getaddrinfo');
    aip := aiRes;
    while aip <> nil do
    begin
      if not proc(aip.ai_family, @aip.ai_addr.sin_zero, param1, param2) then
      begin
        Result := False;
        Exit;
      end;
      aip := aip.ai_next;
    end;
    if Assigned(aiRes) then freeaddrinfo(aiRes);
  end
  else begin
    pent := gethostbyname(host);
    if not Assigned(pent) then
      raise ESocketException.Create(WSAGetLastError, 'gethostbyname');
    addrlist := pent.h_addr_list;
    while Assigned(addrlist^) do
    begin
      if not proc(AF_INET, PInAddr(addrlist^), param1, param2) then
      begin
        Result := False;
        Exit;
      end;
      Inc(addrlist);
    end;
  end;
  Result := True;
end;

function getLocalHostName: RawByteString;
begin
  SetLength(Result, MAX_DOMAINNAME_LENGTH);
  if (SOCKET_ERROR = GetHostName(PAnsiChar(Result), MAX_DOMAINNAME_LENGTH)) then
    SetLength(Result, 0);
end;

function Proc_GetOneIP(af: Integer; addr, param1, param2: Pointer): Boolean;
begin
  if (param2 = Pointer(-1)) or (param2 = Pointer(af)) then
  begin
    Result := False;
    case af of
      AF_INET:
        begin
          //windows7会返回0.0.0.0这个地址
          if (PInAddr(addr).S_addr = 0) {or (ntohl(PInAddr(addr).S_addr) =
            $7f000001)} then Result := True
          else PLongWord(param1)^ := PInAddr(addr).S_addr;
        end;
      AF_INET6: Move(addr^, param1^, SizeOf(TInAddr6));
    end;
  end
  else Result := True;
end;

function getHostIP4(host: PAnsiChar): LongWord;
begin
  if EnumHostAddr(host, @Result, Pointer(AF_INET), Proc_GetOneIP) then
    Result := INADDR_NONE;
end;

function getHostIP6(host: PAnsiChar; out addr: TInAddr6): Boolean;
begin
  Result := not EnumHostAddr(host, @Result, Pointer(AF_INET6), Proc_GetOneIP);
end;

function Proc_GetList(af: Integer; addr, param1, param2: Pointer): Boolean;
begin
  if (param2 = Pointer(-1)) or (param2 = Pointer(af)) then
  begin
    case af of
      AF_INET:
        if PUInt32(addr)^ <> 0 then
          TStrings(param1).Add(string(RawByteString(inet_ntoa(PInAddr(addr)^))));
      AF_INET6: TStrings(param1).Add(string(InAddr6ToStr(PIn6Addr(addr)^, True)));
    end;
  end;
  Result := True;
end;

procedure GetAddressList(host: PAnsiChar; ips: TStrings; af: Integer);
begin
  EnumHostAddr(host, Pointer(ips), Pointer(af), Proc_GetList);
end;

procedure GetIPv4AddressList(host: PAnsiChar; ips: TStrings);
begin
  EnumHostAddr(host, Pointer(ips), Pointer(AF_INET), Proc_GetList);
end;

function Proc_GetList4(af: Integer; addr, param1, param2: Pointer): Boolean;
begin
  if (af = AF_INET) and (pUInt32(addr)^ <> 0) then
  with PArrayOfInAddr(param1)^ do
  begin
    items[count] := PInAddr(addr)^;
    Inc(count);
    if Pointer(count) = param2 then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

function getIPv4AddressList(host: PAnsiChar; addrs: PArrayOfInAddr): Integer;
begin
  Result := addrs^.count;
  addrs^.count := 0;
  EnumHostAddr(host, addrs, Pointer(Result), Proc_GetList4);
  Result := addrs.count;
end;

procedure GetIPv6AddressList(host: PAnsiChar; ips: TStrings);
begin
  EnumHostAddr(host, Pointer(ips), Pointer(AF_INET6), Proc_GetList);
end;

function Proc_CountIP(af: Integer; addr, param1, param2: Pointer): Boolean;
begin
  if (param2 = Pointer(-1)) or (param2 = Pointer(af)) then Inc(PInteger(param1)^);
  Result := True;
end;

function getNumberOfIP(host: PAnsiChar; af: Integer = -1):Integer;
begin
  EnumHostAddr(host, @Result, Pointer(af), Proc_CountIP);
end;

function getIPv4AddressCount(host: PAnsiChar): Integer;
begin
  EnumHostAddr(host, @Result, Pointer(AF_INET), Proc_CountIP);
end;

function getIPv6AddressCount(host: PAnsiChar): Integer;
begin
  EnumHostAddr(host, @Result, Pointer(AF_INET6), Proc_CountIP);
end;

function Proc_SameAddr(af: Integer; addr, param1, param2: Pointer): Boolean;
var
  i, addrLen: Integer;
begin
  if param2 = Pointer(af) then
  begin
    case af of
      AF_INET6: addrLen := SizeOf(TInAddr6);
      else addrLen := SizeOf(TInAddr);
    end;
    Result := False;
    for i := 0 to addrLen - 1 do
    begin
      if PAnsiChar(addr)[i] <> PAnsiChar(param1)[i] then
      begin
        Result := True;
        Exit;
      end;
    end;
  end
  else Result := True;
end;

function isAddressOfHost(host: PAnsiChar; af: Integer; addr: Pointer): Boolean;
begin
  Result := not EnumHostAddr(host, addr, Pointer(af), Proc_SameAddr);
end;

function getHostNameOfIP(const szIP: RawByteString):RawByteString;
var
  sa: TSockAddrIn;
  err: Integer;
begin
  sa.sin_addr.S_addr := inet_addr(PAnsiChar(szIP));
  sa.sin_family := AF_INET;
  sa.sin_port := htons(80);
  SetLength(Result, NI_MAXHOST);
  err := getnameinfo(PSockAddr(@sa), SizeOf(TSockAddrIn), @Result[1],
    NI_MAXHOST, nil, 0, NI_NOFQDN or NI_NOFQDN);
  if (ERROR_SUCCESS <> err) then Result := '';
end;

function socket_SetLinger(fd: TSocketId; wTimeout: Word; flag: Boolean): Boolean;
var
  ling: linger;
begin
  ling.l_linger := wTimeout;
  ling.l_onoff :=  Ord(flag);
  Result:= NO_ERROR = setsockopt(fd, SOL_SOCKET,
    SO_LINGER, PAnsiChar(@ling), SizeOf(ling));
end;

procedure GetExtensionFunction(s: TSocketId; const FuncGuid: TGUID; out FuncAddr: Pointer);
var
  BytesReturned: DWORD;
begin
  if SOCKET_ERROR = WSAIoctl(s, SIO_GET_EXTENSION_FUNCTION_POINTER,
    @FuncGuid, SizeOf(FuncGuid), @FuncAddr, SizeOf(FuncAddr),
    @BytesReturned, nil, nil) then
  begin
  	FuncAddr := nil;
    //raise ESocketException.Create('GetExtensionFunction', WSAGetLastError);
  end;
end;

procedure SocketInitialize;
var
  wsad: TWsaData;
  s: TSocketId;
begin
  if SOCKET_ERROR = WSAStartup($0202, wsad) then Exit;
  s := WSASocket(AF_INET, SOCK_STREAM, 0, nil, 0, 0);
  try
    GetExtensionFunction(s, WSAID_ACCEPTEX, Pointer(@AcceptEx));
    GetExtensionFunction(s, WSAID_GETACCEPTEXSOCKADDRS, Pointer(@GetAcceptExSockAddrs));
    GetExtensionFunction(s, WSAID_CONNECTEX, Pointer(@ConnectEx));
    GetExtensionFunction(s, WSAID_DISCONNECTEX, Pointer(@DisconnectEx));
    GetExtensionFunction(s, WSAID_TRANSMITFILE, Pointer(@TransmitFile));
  finally
	  closesocket(s);
  end;
end;

procedure SocketUnInitialize;
begin
  WSACleanup;
end;

{ ESocketException }

constructor ESocketException.Create(err: Integer; const func: string);
begin
  fFunctionName := func;
  fErrorCode := err;
  CreateFmt('%s error(%d): %s', [fFunctionName, fErrorCode, SysErrorMessage(fErrorCode)]);
end;

{ EInvalidSockAddr }

constructor EInvalidSockAddr.CreateWith(const Intf: string);
begin
  CreateFmt('"%s" is not a valid host name or address.', [Intf]);
end;

{ EWouldBlock }

constructor EWouldBlock.Create(const func: string);
begin
  inherited Create(WSAEWOULDBLOCK, func);
end;

{ EPortUnreachable }

constructor EPortUnreachable.Create(const _EndPoint: TEndPoint);
begin
  FEndPoint := _EndPoint;
  FErrorCode := WSAECONNRESET;
  inherited Create('destination {' + FEndPoint.IP2Str + ':' + IntToStr(FEndPoint.port) + '} is unreachable.');
end;

{ EAddrInUse }

constructor EAddrInUse.Create(const func: string; const _EndPoint: TEndPoint);
begin
  FEndPoint := _EndPoint;
  fErrorCode := WSAEADDRINUSE;
  inherited Create('address {' + FEndPoint.IP2Str + ':' + IntToStr(FEndPoint.port) + '} is in use.');
end;

{ TCustomSocket }

function TCustomSocket.GetAddressFamily: Integer;
var
  ProtoInfo: TWsaProtocolInfo;
  BytesReturned: Integer;
begin
  BytesReturned := SizeOf(ProtoInfo);
  if SOCKET_ERROR = getsockopt(Handle, SOL_SOCKET, SO_PROTOCOL_INFO, PAnsiChar(@ProtoInfo), BytesReturned) then
    raise ESocketException.Create(WSAGetLastError, 'getsockopt')
  else
    Result := ProtoInfo.iAddressFamily;
end;

function TCustomSocket.allocateHandle(_AddressFamily, SocketType: Integer; pErrorCode: PInteger): Boolean;
begin
  if FHandle <> INVALID_SOCKET then
  begin
    Result := True;
    Exit;
  end;

  FHandle := WSASocket(_AddressFamily, SocketType, 0, nil, 0, WSA_FLAG_OVERLAPPED);

  Result := FHandle <> INVALID_SOCKET;
  if not Result then
  begin
    if Assigned(pErrorCode) then pErrorCode^ := WSAGetLastError
    else raise ESocketException.Create(WSAGetLastError, 'WSASocket');
  end;
end;

function TCustomSocket.bind(const EndPoint: TEndPoint; pErrorCode: PInteger): Boolean;
begin
  Result := DSLWinsock2.bind(Handle, @EndPoint.unknown, EndPoint.bytes) <> SOCKET_ERROR;
  if not Result then
  begin
    if Assigned(pErrorCode) then pErrorCode^ := WSAGetLastError
    else BindError(EndPoint, GetLastError);
  end;
end;

procedure TCustomSocket.bindError(const EndPoint: TEndPoint; code: Integer);
begin
  case code of
    WSAEINVAL:
      raise EAlreadyBound.Create(code, 'bind');
    WSAEADDRINUSE:
      raise EAddrInUse.Create('bind', EndPoint);
    else
      raise ESocketException.Create(code, 'bind');
  end;
end;

function TCustomSocket.close: Boolean;
begin
  Result := DeallocateHandle;
end;

function TCustomSocket.closeAndRelease: Boolean;
begin
  Result := deallocateHandle;
  if Result then  
    Self.Release;
end;

constructor TCustomSocket.Create;
begin
  inherited;
  FHandle := INVALID_SOCKET;
end;

function TCustomSocket.deallocateHandle: Boolean;
var
  LastError: Integer;
  hSocket: TSocketId;
begin
  hSocket := InterlockedExchange(Integer(FHandle), Integer(INVALID_SOCKET));
  Result := hSocket <> INVALID_SOCKET;
  if Result then
  begin
    if SOCKET_ERROR = closesocket(hSocket) then
    begin
      LastError := WSAGetLastError;
      raise ESocketException.Create(LastError, 'closesocket');
    end;
  end;
end;

destructor TCustomSocket.Destroy;
begin
  close;
  inherited;
end;

function TCustomSocket.GetReadableBytes: Integer;
var
  tmp: UInt32;
begin
  if ioctlsocket(Handle, FIONREAD, tmp) = SOCKET_ERROR then
    raise ESocketException.Create(WSAGetLastError, 'ioctlsocket')
  else
    Result := Integer(tmp);
end;

function TCustomSocket.GetRecvTimeout: Integer;
begin
  Self.GetIntOption(SOL_SOCKET, SO_RCVTIMEO, Result);
end;

function TCustomSocket.GetSendTimeout: Integer;
begin
  Self.GetIntOption(SOL_SOCKET, SO_SNDTIMEO, Result);
end;

function TCustomSocket.GetLocalEndPoint: TEndPoint;
var
  addrlen: Integer;
begin
  addrlen := SizeOf(Result);

  if getsockname(Handle, PSockAddr(@Result), addrlen) = SOCKET_ERROR then
    raise ESocketException.Create(WSAGetLastError, 'getsockname');
end;

function TCustomSocket.GetOutputBufferSize: Integer;
begin
  Self.GetIntOption(SOL_SOCKET, SO_SNDBUF, Result);
end;

function TCustomSocket.IsHandleAllocated: Boolean;
begin
  Result := Handle <> INVALID_SOCKET;
end;

function TCustomSocket.readable(timeout: UInt32): Boolean;
var
  readfds, exceptfds: TFdSet;
  tos: TTimeVal;
  sr: Integer;
begin
  readfds.fd_count := 1;
  readfds.fd_array[0] := FHandle;
  exceptfds.fd_count := 1;
  exceptfds.fd_array[0] := FHandle;
  tos.tv_sec := timeout div 1000;
  tos.tv_usec := 1000 * (timeout mod 1000);
  sr := select(0, @readfds, nil, @exceptfds, @tos);
  if SOCKET_ERROR = sr then
    raise ESocketException.Create(WSAGetLastError, 'select');
  if sr > 0 then
    Result := readfds.fd_count > 0
  else
    Result := False;
end;

function TCustomSocket.reportError(const operation: string; code: Integer;
  pError: PCommunicationError): Boolean;
begin
  if Assigned(pError) then
  begin
    pError.callee := operation;
    pError.internalErrorCode := code;
    pError.code := convertWinsockError(code);
  end
  else
    throwException(operation, code);

  Result := False;
end;

function TCustomSocket.reportError(const operation: string; code: Integer; pErrorCode: PInteger): Boolean;
begin
  if Assigned(pErrorCode) then
    pErrorCode^ := code
  else
    throwException(operation, code);

  Result := False;
end;

procedure TCustomSocket.SetBlocking(const Value: Boolean);
var
  non_blocking: UInt32;
begin
  non_blocking := Ord(Value) xor 1;
  if SOCKET_ERROR = ioctlsocket(FHandle, FIONBIO, non_blocking) then
    raise ESocketException.Create(WSAGetLastError, 'SetBlocking');
end;

procedure TCustomSocket.SetExclusiveAddr(const Value: Boolean);
begin
  Self.SetIntOption(SOL_SOCKET, SO_EXCLUSIVEADDRUSE, Ord(Value));
end;

function TCustomSocket.SetIntOption(level: UInt32; option: UInt32;
  value: Integer; pErrorCode: PInteger): Boolean;
var
  optlen: Integer;
begin
  optlen := SizeOf(value);

  if NO_ERROR = setsockopt(FHandle, level, option, PAnsiChar(@value), optlen) then
    Result := True
  else
    Result := reportError('winsock2.setsockopt', WSAGetLastError, pErrorCode);
end;

procedure TCustomSocket.SetOutputBufferSize(const Value: Integer);
begin
  Self.SetIntOption(SOL_SOCKET, SO_SNDBUF, Value);
end;

procedure TCustomSocket.SetInputBufferSize(const Value: Integer);
begin
  Self.SetIntOption(SOL_SOCKET, SO_RCVBUF, Value);
end;

procedure TCustomSocket.SetRecvTimeout(const Value: Integer);
begin
  Self.SetIntOption(SOL_SOCKET, SO_RCVTIMEO, Value);
end;

procedure TCustomSocket.SetReuseAddr(value: Boolean);
begin
  Self.SetIntOption(SOL_SOCKET, SO_REUSEADDR, Ord(value));
end;

procedure TCustomSocket.SetSendTimeout(const Value: Integer);
begin
  Self.SetIntOption(SOL_SOCKET, SO_SNDTIMEO, Value);
end;

function TCustomSocket.GetIntOption(level, option: UInt32;
  var value: Integer; pErrorCode: PInteger): Boolean;
var
  optlen: Integer;
begin
  optlen := SizeOf(value);

  if NO_ERROR = getsockopt(FHandle, level, option, PAnsiChar(@value), optlen) then
    Result := True
  else
    Result := reportError('winsock2.getsockopt', WSAGetLastError, pErrorCode);
end;

procedure TCustomSocket.throwException(const operation: string; code: Integer);
begin
  case code of
    WSAECONNABORTED, WSAECONNRESET:
      raise EConnectionClosed.Create(code, operation);
    WSAEWOULDBLOCK:
      raise EWouldBlock.Create(operation);
    else
      raise ESocketException.Create(code, operation);
  end;
end;

function TCustomSocket.writable(timeout: UInt32): Boolean;
var
  writefds, exceptfds: TFdSet;
  tos: TTimeVal;
  sr: Integer;
begin
  writefds.fd_count := 1;
  writefds.fd_array[0] := FHandle;
  exceptfds.fd_count := 1;
  exceptfds.fd_array[0] := FHandle;
  tos.tv_sec := timeout div 1000;
  tos.tv_usec := 1000 * (timeout mod 1000);
  sr := select(0, nil, @writefds, @exceptfds, @tos);
  if SOCKET_ERROR = sr then
    raise ESocketException.Create(WSAGetLastError, 'select');
  if sr > 0 then
    Result := writefds.fd_count > 0
  else
    Result := False;
end;

function TCustomSocket.GetInputBufferSize: Integer;
begin
  Self.GetIntOption(SOL_SOCKET, SO_RCVBUF, Result);
end;

{ TConnectionSocket }

procedure TConnectionSocket.dataRead(bytesRead: Integer);
begin
  FLatestRead := GetTickCount;
end;

function TConnectionSocket.GetConnectTime: Integer;
begin
  Self.GetIntOption(SOL_SOCKET, SO_CONNECT_TIME, Result);
end;

function TConnectionSocket.GetLinger: Boolean;
var
  tmp: Integer;
begin
  Self.GetIntOption(SOL_SOCKET, SO_DONTROUTE, tmp);
  Result := tmp = 0;
end;

function TConnectionSocket.GetNagle: Boolean;
var
  tmp: Integer;
begin
  Self.GetIntOption(IPPROTO_IP, TCP_NODELAY, tmp);
  Result := tmp = 0;
end;

function TConnectionSocket.getRemoteEndPoint: PEndPoint;
var
  len: Integer;
begin
  if FRemoteEndPoint.port = 0 then
  begin
    len := SizeOf(result);

    if getpeername(Handle, PSockAddr(@FRemoteEndPoint), len) = SOCKET_ERROR then
      raise ESocketException.Create(WSAGetLastError, 'getpeername');
  end;

  Result := @FRemoteEndPoint;
end;

function TConnectionSocket.IsConnected: Boolean;
begin
  Result := HandleAllocated and (Self.GetConnectTime >= 0);
end;

function TConnectionSocket.MultiRead;
var
  BytesRead, _flags: DWORD;
  sr: Integer;
begin
  _flags := flags;
  sr := WSARecv(Handle, @bufs[0], Length(bufs), BytesRead, _flags, nil, nil);

  if sr = SOCKET_ERROR then
  begin
    reportError('winsock2.WSARecv', WSAGetLastError, pError);
    Result := -1;
  end
  else if BytesRead = 0 then
  begin
    reportError('winsock2.WSARecv', WSAECONNRESET, pError);
    Result := -1;
  end
  else begin
    Result := BytesRead;
    dataRead(BytesRead);
  end
end;

function TConnectionSocket.MultiWrite;
var
  BytesWritten: DWORD;
  sr: Integer;
begin
  sr := WSASend(Handle, @bufs[0], Length(bufs), BytesWritten, flags, nil, nil);

  if sr < 0 then
  begin
    reportError('winsock2.WSASend', WSAGetLastError, pError);
    Result := -1;
  end
  else if BytesWritten = 0 then
  begin
    reportError('winsock2.WSASend', WSAECONNRESET, pError);
    Result := -1;
  end
  else
    Result := BytesWritten;
end;

procedure TConnectionSocket.ReadBuffer(var buf; BufLen: DWORD);
var
  BytesRead: Integer;
  ptr: PAnsiChar;
begin
  ptr := PAnsiChar(@buf);
  while BufLen > 0 do
  begin
    BytesRead := Self.read(ptr^, BufLen);
    Inc(ptr, BytesRead);
    Dec(BufLen, BytesRead);
  end;
end;

function TConnectionSocket.ReadRBStr;
var
  CharRead, P: Integer;
  tick, elapsed: DWORD;
  L1, L2: Integer;
  s: RawByteString;
  buf: array [0..255] of AnsiChar;
begin
  Result := SOCKET_ERROR;

  s := '';
  L1 := 0;
  tick := GetTickCount;

  while True do
  begin
    if timeout > 0 then
    begin
      elapsed := GetTickCount - tick;
      if elapsed >= timeout then
      begin
        reportError('TConnectionSocket.ReadRBStr', WSAETIMEDOUT, pError);
        Break;
      end;

      if not Self.readable(timeout - elapsed) then
      begin
        reportError('TConnectionSocket.ReadRBStr', WSAETIMEDOUT, pError);
        Break;
      end;
    end;

    CharRead := Self.read(buf, SizeOf(buf), nil, MSG_PEEK);

    if TerminalChars = '' then
    begin
      SetLength(str, CharRead);
      Self.read(Pointer(str)^, CharRead);
      Result := CharRead;
      Break;
    end
    else begin
      L2 := L1 + CharRead;
      SetLength(s, L2);
      Move(buf, PAnsiChar(s)[L1], CharRead);
      P := RBStrPos(TerminalChars, s);

      if P > 0 then
      begin
        SetLength(s, P - 1);
        Result := P - 1 + Length(TerminalChars);
        Self.read(buf, Result - L1);
        str := s;
        Break;
      end
      else begin
        Self.read(buf, CharRead);
        L1 := L2;
      end;
    end;
  end;
end;

function TConnectionSocket.ReadDouble: Double;
begin
  Self.read(Result, SizeOf(Result));
end;

function TConnectionSocket.ReadInteger: Integer;
begin
  Self.read(Result, SizeOf(Result));
  Result := ntohl(Result);
end;

function TConnectionSocket.ReadOffset(var buf; BufLen, Offset: Integer): Integer;
begin
  Result := Self.read((PAnsiChar(@buf) + Offset)^, BufLen);
end;

function TConnectionSocket.ReadStream(stream: TStream;
  count: Integer; buf: Pointer; BufLen: Integer): Integer;
var
  chars: array [0..1024 - 1] of AnsiChar;
  BytesRead: Integer;
  BytesToRead: Integer absolute BytesRead;
begin
  Result := 0;
  if buf = nil then
  begin
    buf := @Chars;
    BufLen := SizeOf(Chars);
  end;
  while Result < count do
  begin
    BytesToRead := BufLen;
    if BytesToRead > count - Result then BytesToRead := count - Result;
    BytesRead := Self.read(buf^, BytesToRead);
    if BytesRead > 0 then
    begin
      Inc(Result, BytesRead);
      stream.write(buf^, BytesRead);
    end;
  end;
end;

function TConnectionSocket.ReadUntil(const chars: array of AnsiChar): RawByteString;
var
  CharRead, L: Integer;
  P: PAnsiChar;
begin
  L := Self.ReadableBytes;
  if L = 0 then Exit;
  SetLength(Result, L);
  CharRead := Self.read(Pointer(Result)^, L, nil, MSG_PEEK);

  if CharRead = 0 then
  begin
    Result := '';
    Exit;
  end;

  P := SeekAnsiChars(PAnsiChar(Result), CharRead, chars);
  if P <> nil then
  begin
    SetLength(Result, P - PAnsiChar(Result));
    Self.read(Pointer(Result)^, Length(Result));
    Self.read(CharRead, SizeOf(AnsiChar));
  end
  else Result := '';
end;

function TConnectionSocket.ReadUntil(const c: AnsiChar): RawByteString;
var
  CharRead, L: Integer;
  P: PAnsiChar;
begin
  L := Self.ReadableBytes;
  if L = 0 then Exit;
  SetLength(Result, L);

  CharRead := Self.read(Pointer(Result)^, L, nil, MSG_PEEK);

  if CharRead = 0 then
  begin
    Result := '';
    Exit;
  end;

  P := SeekAnsiChar(PAnsiChar(Result), CharRead, c);

  if P <> nil then
  begin
    SetLength(Result, P - PAnsiChar(Result));
    Self.read(Pointer(Result)^, Length(Result));
    Self.read(CharRead, SizeOf(c));
  end
  else Result := '';
end;

function TConnectionSocket.ReadUntil(const c: WideChar): UnicodeString;
var
  CharRead, L: Integer;
  P: PWideChar;
begin
  L := Self.ReadableBytes div 2;
  if L = 0 then Exit;
  SetLength(Result, L);
  CharRead := Self.read(Pointer(Result)^, L * 2, nil, MSG_PEEK) div 2;

  if CharRead = 0 then
  begin
    Result := '';
    Exit;
  end;

  P := SeekWideChar(PWideChar(Result), CharRead, c);

  if P <> nil then
  begin
    SetLength(Result, P - PWideChar(Result));
    Self.read(Pointer(Result)^, Length(Result) * 2);
    Self.read(CharRead, SizeOf(c));
  end
  else Result := '';
end;

function TConnectionSocket.ReadUntil(const chars: array of WideChar): UnicodeString;
var
  CharRead, L: Integer;
  P: PWideChar;
begin
  L := Self.ReadableBytes div 2;
  if L = 0 then Exit;
  SetLength(Result, L);
  CharRead := Self.read(Pointer(Result)^, L * 2, nil, MSG_PEEK) div 2;

  if CharRead = 0 then
  begin
    Result := '';
    Exit;
  end;

  P := SeekWideChars(PWideChar(Result), CharRead, chars);

  if P <> nil then
  begin
    SetLength(Result, P - PWideChar(Result));
    Self.read(Pointer(Result)^, Length(Result) * 2);
    Self.read(CharRead, SizeOf(WideChar));
  end
  else Result := '';
end;

function TConnectionSocket.ReadUStr;
var
  CharRead, P, L1, L2, L: Integer;
  tick, elapsed: DWORD;
  s: UnicodeString;
  buf: array [0..255] of Byte;
begin
  Result := SOCKET_ERROR;

  s := '';
  L1 := 0;
  tick := GetTickCount;

  while True do
  begin
    if timeout > 0 then
    begin
      elapsed := GetTickCount - tick;
      if elapsed >= timeout then
      begin
        reportError('TConnectionSocket.ReadUStr', WSAETIMEDOUT, pError);
        Break;
      end;

      if not Self.readable(timeout - elapsed) then
      begin
        reportError('TConnectionSocket.ReadUStr', WSAETIMEDOUT, pError);
        Break;
      end;
    end;

    CharRead := Self.read(buf, SizeOf(buf), nil, MSG_PEEK);

    if TerminalChars = '' then
    begin
      L := CharRead shr 1;
      SetLength(str, L);
      Self.read(Pointer(str)^, L shl 1);
      Result := L shl 1;
      Break;
    end
    else begin
      L := CharRead shr 1;
      L2 := L1 + L;
      SetLength(s, L2);
      Move(buf, PWideChar(s)[L1], L shl 1);
      P := UStrPos(TerminalChars, s);

      if P > 0 then
      begin
        SetLength(s, P - 1);
        Result := (P - 1 + Length(TerminalChars)) shl 1;
        Self.read(buf, Result - L1 shl 1);
        str := s;
        Break;
      end
      else begin
        Self.read(buf, L shl 1);
        L1 := L2;
      end;
    end;
  end;
end;

function TConnectionSocket.ReadWord: Word;
begin
  Self.read(Result, SizeOf(Result));
  Result := ntohs(Result);
end;

function TConnectionSocket._read(var buf; BufLen: DWORD; pError: PCommunicationError; flags: DWORD): Integer;
var
  ws2buf: TWsaBuf;
  BytesRead, _flags: DWORD;
  sr: Integer;
begin
  if BufLen = 0 then Result := 0
  else begin
    ws2buf.buf := PAnsiChar(@buf);
    ws2buf.len := BufLen;
    _flags := flags;
    sr := WSARecv(Handle, @ws2buf, 1, BytesRead, _flags, nil, nil);
    if sr < 0 then
    begin
      reportError('winsock2.WSARecv', WSAGetLastError, pError);
      Result := -1;
    end
    else if BytesRead = 0 then
    begin
      reportError('winsock2.WSARecv', WSAECONNRESET, pError);
      Result := -1;
    end
    else begin
      Result := BytesRead;
      dataRead(BytesRead);
    end;
  end;
end;

function TConnectionSocket._write(const buf; BufLen: DWORD;
  pError: PCommunicationError; flags: DWORD): Integer;
var
  ws2buf: TWsaBuf;
  BytesWritten: DWORD;
  sr: Integer;
begin
  ws2buf.buf := PAnsiChar(@buf);
  ws2buf.len := BufLen;
  sr := WSASend(Handle, @ws2buf, 1, BytesWritten, flags, nil, nil);

  if sr < 0 then
  begin
    Result := -1;
    reportError('winsock2.WSASend', WSAGetLastError, pError);
  end
  else if BytesWritten = 0 then
  begin
    reportError('winsock2.WSASend', WSAECONNRESET, pError);
    Result := -1;
  end
  else
    Result := BytesWritten;
end;

procedure TConnectionSocket.SetLinger(const Value: Boolean);
begin
  Self.SetIntOption(SOL_SOCKET, SO_DONTROUTE, Ord(not Value));
end;

procedure TConnectionSocket.SetNagle(const Value: Boolean);
begin
  Self.SetIntOption(IPPROTO_IP, TCP_NODELAY, Ord(not Value));
end;

procedure TConnectionSocket.setRemoteEndPoint(const addrData; addrLen: Integer);
begin
  Move(addrData, FRemoteEndPoint, addrLen);
end;

function TConnectionSocket.shutDown(ShutType: TShutDownType;
  pErrorCode: PInteger): Boolean;
begin
  Result := NO_ERROR = DSLWinsock2.shutdown(Handle, Ord(ShutType));
  if not Result then reportError('winsock2.shutDown', GetLastError, pErrorCode);
end;

function TConnectionSocket.skip(len: Integer): Integer;
var
  Buffer: array [0..1024 - 1] of Byte;
  BytesRead: Integer;
begin
  Result := 0;
  while len > Result do
  begin
    if len > SizeOf(Buffer) then BytesRead := SizeOf(Buffer)
    else BytesRead := len;
    BytesRead := Self.read(Buffer, BytesRead);
    Inc(Result, BytesRead);
  end;
end;

procedure TConnectionSocket.WriteRBStr(const s: RawByteString);
begin
  Self.WriteBuffer(Pointer(s)^, Length(s));
end;

procedure TConnectionSocket.WriteBStr(const s: WideString);
begin
  Self.write(Pointer(s)^, Length(s) * 2);
end;

function TConnectionSocket.WriteBuffer(const buf; BufLen: DWORD;
  pError: PCommunicationError; flags: DWORD): Boolean;
var
  ws2buf: TWsaBuf;
  BytesWritten, n: DWORD;
begin
  n := 0;
  while n < BufLen do
  begin
    ws2buf.buf := PAnsiChar(@buf) + n;
    ws2buf.len := BufLen - n;
    BytesWritten := Self.write(PAnsiChar(@buf)[n], BufLen - n, pError, flags);

    if BytesWritten <= 0 then
      Break;

    Inc(n, BytesWritten);
  end;

  Result := n = BufLen;
end;

procedure TConnectionSocket.WriteFloat(value: Double);
begin
  Self.write(value, SizeOf(value));
end;

procedure TConnectionSocket.WriteInt32(value: UInt32);
begin
  value := htonl(value);
  Self.write(value, SizeOf(value));
end;

procedure TConnectionSocket.WriteStream(stream: TStream; count: Integer);
var
  buf: array [0..1023] of AnsiChar;
  BytesRead: Integer;
begin
  if count > stream.Size - stream.Position then
    count := stream.Size - stream.Position;

  if stream is TMemoryStream then
    Self.write((PAnsiChar(TMemoryStream(stream).Memory) + stream.Position)^, count)
  else
    while count > 0 do
    begin
      if count < SizeOf(buf) then BytesRead := count
      else BytesRead := SizeOf(buf);
      BytesRead := stream.read(buf, BytesRead);
      Self.write(buf, BytesRead);
      Dec(count, BytesRead);
    end;
end;

procedure TConnectionSocket.WriteUStr(const s: UnicodeString);
begin
  Self.write(Pointer(s)^, Length(s) * 2);
end;

procedure TConnectionSocket.WriteWord(value: Word);
begin
  value := htons(value);
  Self.write(value, SizeOf(value));
end;

{ TDgramSocket }

procedure TDgramSocket.broadcast(port: Word; const buf; BufLen: Integer);
var
  i: Integer;
  Addr: TEndPoint;
  AddrLen: Integer;
  pErrorCode: Integer;
begin
  AddrLen := SizeOf(Addr);
  if getsockname(Handle, PSockAddr(@Addr), AddrLen) = SOCKET_ERROR then
  begin
    pErrorCode := WSAGetLastError;
    if pErrorCode <> WSAEINVAL then
      raise ESocketException.Create(pErrorCode, 'getsockname');
    Self.bind(TEndPointCreator.Create(0, 0));
    if getsockname(Handle, PSockAddr(@Addr), AddrLen) = SOCKET_ERROR then
      raise ESocketException.Create(pErrorCode, 'getsockname');
  end;
  case Addr.unknown.sin_family of
    AF_INET: Addr.ipv4.sin_addr.S_addr := INADDR_BROADCAST;
    AF_INET6:
      for i := 0 to 3 do Addr.ipv6.sin6_addr.Dwords[i] := 0;
    else raise ESocketException.Create(WSAESOCKTNOSUPPORT, 'broadcast');
  end;
  Addr.unknown.sin_port := htons(port);
  Self.SendTo(Addr, buf, BufLen);
end;

procedure TDgramSocket.BroadcastRBStr(port: Word; const s: RawByteString);
begin
  broadcast(port, Pointer(s)^, Length(s));
end;

procedure TDgramSocket.BroadcastUStr(port: Word; const s: UnicodeString);
begin
  broadcast(port, Pointer(s)^, Length(s) * 2);
end;

function TDgramSocket.RecvFrom(var from: TEndPoint; var buf; BufLen: DWORD;
  pError: PCommunicationError; flags: PDWORD): Integer;
var
  BytesRead, RFlags: DWORD;
  WSABuf: TWSABuf;
  FromLen: Integer;
  lastError: Integer;
begin
  //Result := SOCKET_ERROR;
  while True do
  begin
    if Assigned(flags) then RFlags := flags^
    else RFlags := 0;
    WSABuf.buf := @buf;
    WSABuf.len := BufLen;
    FromLen := SizeOf(from);
    Result  := WSARecvFrom(Handle, @WSABuf, 1, BytesRead,
      RFlags, PSockAddr(@from), @FromLen, nil, nil);
    if Result = NO_ERROR then
    begin
      if Assigned(flags) then flags^ := RFlags;
      Result := BytesRead;
      Break;
    end
    else begin
      lastError := WSAGetLastError;
      if lastError <> WSAECONNRESET then
      begin
        reportError('winsock2.recvfrom', WSAGetLastError, pError);
        Break;
      end;
    end;
  end;
end;

function TDgramSocket.ReadRBStr(var from: TEndPoint; flags: PDWORD): RawByteString;
var
  buf: array [0..8192 - 1] of Byte;
begin
  SetLength(Result, Self.RecvFrom(from, buf, SizeOf(buf), nil, flags));
  Move(buf, Pointer(Result)^, Length(Result));
end;

function TDgramSocket.ReadFloat(var from: TEndPoint; flags: PDWORD): Double;
begin
  Self.RecvFrom(from, Result, SizeOf(Result), nil, flags);
end;

function TDgramSocket.ReadInt32(var from: TEndPoint; flags: PDWORD): Integer;
begin
  Self.RecvFrom(from, Result, SizeOf(Result), nil, flags);
  Result := ntohl(Result);
end;

function TDgramSocket.ReadString(var from: TEndPoint; flags: PDWORD): string;
begin
  Result := string(ReadUStr(from, flags));
end;

function TDgramSocket.ReadUStr(var from: TEndPoint; flags: PDWORD): UnicodeString;
var
  buf: array [0..8191] of Byte;
begin
  SetLength(Result, Self.RecvFrom(from, buf, SizeOf(buf), nil, flags) div 2);
  Move(buf, Pointer(Result)^, Length(Result) * 2);
end;

function TDgramSocket.ReadWord(var from: TEndPoint; flags: PDWORD): Word;
begin
  Self.RecvFrom(from, Result, SizeOf(Result), nil, flags);
  Result := ntohs(Result);
end;

procedure TDgramSocket.WriteRBStr(const target: TEndPoint; const s: RawByteString);
begin
  Self.SendTo(target, Pointer(s)^, Length(s));
end;

procedure TDgramSocket.WriteBStr(const target: TEndPoint; const s: WideString);
begin
  Self.SendTo(target, Pointer(s)^, Length(s) * 2);
end;

procedure TDgramSocket.WriteBytes(const target: TEndPoint; const s: TBytes);
begin
  Self.SendTo(target, s[0], Length(s));
end;

procedure TDgramSocket.WriteFloat(const target: TEndPoint; value: Double);
begin
  Self.SendTo(target, value, SizeOf(value));
end;

procedure TDgramSocket.WriteInt32(const target: TEndPoint; value: UInt32);
begin
  value := htonl(value);
  Self.SendTo(target, value, SizeOf(value));
end;

procedure TDgramSocket.WriteUStr(const target: TEndPoint; const s: UnicodeString);
begin
  Self.SendTo(target, Pointer(s)^, Length(s) * 2);
end;

procedure TDgramSocket.WriteWord(const target: TEndPoint; value: Word);
begin
  value := htons(value);
  Self.SendTo(target, value, SizeOf(value));
end;

procedure TDgramSocket.EnableBroadcast(const Value: Boolean);
begin
  if not Self.SetIntOption(SOL_SOCKET, SO_BROADCAST, Ord(Value)) then
    raise ESocketException.Create(WSAGetLastError, 'setsockopt');
end;

procedure TDgramSocket.open(EndPoint: TEndPoint);
begin
  if Handle = INVALID_SOCKET then
    AllocateHandle(EndPoint.family, SOCK_DGRAM);
  bind(EndPoint);
end;

procedure TDgramSocket.open;
begin
  if Handle = INVALID_SOCKET then
    AllocateHandle(AF_INET, SOCK_DGRAM);
end;

function TDgramSocket.SendTo(const target: TEndPoint; const buf; BufLen: DWORD;
  pError: PCommunicationError; flags: DWORD): Boolean;
var
  ws2buf: TWsaBuf;
  BytesWritten: DWORD;
begin
  ws2buf.buf := PAnsiChar(@buf);
  ws2buf.len := BufLen;

  if SOCKET_ERROR = WSASendTo(Handle, @ws2buf, 1, BytesWritten, flags,
    @target.unknown, target.bytes, nil, nil) then
    Result := reportError('winsock2.sendto', WSAGetLastError, pError)
  else
    Result := True;
end;

{ TClientSocket }

function TClientSocket.connect(const ServerAddr: TSockAddr;
  AddrLen, timeout: Integer; pError: PCommunicationError): Boolean;
begin
  Result := Self._connect(ServerAddr, AddrLen, timeout, pError);
end;

function TClientSocket.read(var buf; BufLen: DWORD; pError: PCommunicationError; flags: DWORD): Integer;
begin
  Result := Self._read(buf, BufLen, pError, flags);
end;

function TClientSocket.write(const buf; BufLen: DWORD; pError: PCommunicationError; flags: DWORD): Integer;
begin
  Result := Self._write(buf, BufLen, pError, flags);
end;

{ TCustomServerSocket }

function TCustomServerSocket.listen(pErrorCode: PInteger;
  backlog: Integer): Boolean;
begin
  Result := DSLWinsock2.listen(Handle, SOMAXCONN) = NO_ERROR;
  if not Result then
  begin
    if Assigned(pErrorCode) then pErrorCode^ := WSAGetLastError
    else raise ESocketException.Create(WSAGetLastError, 'listen');
  end;
end;

function TCustomServerSocket.open(port: Word; pErrorCode: PInteger): Boolean;
begin
  Result := open(TEndPointCreator.Create(0, port), pErrorCode);
end;

function TCustomServerSocket.open(const EndPoint: TEndPoint; pErrorCode: PInteger): Boolean;
var
  LastError: Integer;
begin
  Result := False;

  if (Handle = INVALID_SOCKET) and not AllocateHandle(EndPoint.family, SOCK_STREAM, pErrorCode) then Exit;
  if not bind(EndPoint, @LastError) and (LastError <> WSAEINVAL) then
  begin
    if Assigned(pErrorCode) then
    begin
      pErrorCode^ := LastError;
      Exit;
    end;
    if LastError = WSAEADDRINUSE then
      raise EAddrInUse.Create('bind', EndPoint);
    raise ESocketException.Create(LastError, 'bind');
  end;
  Result := Self.listen(pErrorCode);
end;

{ TUDPSocket }

procedure TUDPSocket.SetICMPErrorReport(const Value: Boolean);
var
  BytesReturned: DWORD;
  flag: DWORD;
begin
  flag := Ord(Value);
  if WSAIoctl(Handle, SIO_UDP_CONNRESET, @flag, sizeof(flag),
    nil, 0, @BytesReturned, nil, nil) = SOCKET_ERROR then
    reportError('winsock2.WSAIoctl', WSAGetLastError, PInteger(nil));
end;

{ TSockAddrInHelper }

constructor TSockAddrInHelper.Create(ip: UInt32; _port: Word);
begin
  FillChar(sin_family, SizeOf(Self), 0);
  sin_family := AF_INET;
  sin_port := htons(_port);
  sin_addr.S_addr := ip;
end;

constructor TSockAddrInHelper.Create(const ip: RawByteString; _port: Word);
var
  ip4: UInt32;
begin
  FillChar(sin_family, SizeOf(Self), 0);
  sin_family := AF_INET;
  sin_port := htons(_port);

  if ip = '' then
    sin_addr.S_addr := INADDR_ANY
  else if StrToIP4(PAnsiChar(ip), Length(ip), ip4) then
    sin_addr.S_addr := ip4
  else begin
    ip4 := GetHostIP4(PAnsiChar(ip));

    if ip4 = INADDR_NONE then
      raise EInvalidSockAddr.Create(Ascii2UStr(ip));

    sin_addr.S_addr := ip4;
  end;
end;

function TSockAddrInHelper.IP2RBStr: RawByteString;
begin
  Result := inet_ntoa(sin_addr);
end;

function TSockAddrInHelper.IP2Str: string;
begin
  Result := IP2UStr;
end;

function TSockAddrInHelper.IP2UStr: UnicodeString;
var
  tmp: PAnsiChar;
begin
  tmp := inet_ntoa(sin_addr);
  Result := BufToUnicode(tmp, -1, CP_ACP);
end;

function TSockAddrInHelper.port: Word;
begin
  Result := ntohs(sin_port);
end;

{ TSockAddrIn6Helper }

constructor TSockAddrIn6Helper.Create(const ip: array of Byte; _port: Word);
var
  i: Integer;
begin
  FillChar(sin6_family, SizeOf(Self), 0);
  sin6_family := AF_INET6;
  sin6_port := htons(_port);

  for i := 0 to 15 do
    sin6_addr.s6_bytes[i] := ip[0];
end;

constructor TSockAddrIn6Helper.Create(ip: TIn6Addr; _port: Word);
begin
  FillChar(sin6_family, SizeOf(Self), 0);
  sin6_family := AF_INET6;
  sin6_port := htons(_port);
  Move(ip, sin6_addr, SizeOf(ip));
end;

constructor TSockAddrIn6Helper.Create(const ip: RawByteString; _port: Word);
var
  addr6: in6_addr;
begin
  FillChar(sin6_family, SizeOf(Self), 0);
  sin6_family := AF_INET6;
  sin6_port := htons(_port);

  if inet6_addr(PAnsiChar(ip), Length(ip), addr6) then
    sin6_addr := addr6
  else
    raise EInvalidSockAddr.Create(Ascii2UStr(ip));
end;

function TSockAddrIn6Helper.IP2RBStr(compress: Boolean): RawByteString;
var
  buf: array [0..63] of AnsiChar;
begin
  SetLength(Result, inet6_ntoa(sin6_addr, buf, compress));
  Move(buf, Pointer(Result)^, Length(Result));
end;

function TSockAddrIn6Helper.IP2Str(compress: Boolean): string;
begin
  Result := IP2UStr(compress);
end;

function TSockAddrIn6Helper.IP2UStr(compress: Boolean): UnicodeString;
var
  buf: array [0..63] of AnsiChar;
  len: Integer;
begin
  len := inet6_ntoa(sin6_addr, buf, compress);
  Result := AsciiBuf2UStr(buf, len);
end;

function TSockAddrIn6Helper.port: Word;
begin
  Result := ntohs(sin6_port);
end;

{ TEndPoint }

function TEndPoint.bytes: Integer;
begin
  case unknown.sin_family of
    AF_INET: Result := SizeOf(ipv4);
    AF_INET6: Result := SizeOf(ipv6);
    else Result := SizeOf(ipv4);
  end;
end;

function TEndPoint.IP2RBStr: RawByteString;
begin
  case unknown.sin_family of
    AF_INET: Result := ipv4.IP2RBStr;
    AF_INET6: Result := ipv6.IP2RBStr(True)
    else Result := '';
  end;
end;

function TEndPoint.IP2Str: string;
begin
  case unknown.sin_family of
    AF_INET: Result := ipv4.IP2Str;
    AF_INET6: Result := ipv6.IP2Str(True)
    else Result := '';
  end;
end;

function TEndPoint.IP2UStr: UnicodeString;
begin
  case unknown.sin_family of
    AF_INET: Result := ipv4.IP2UStr;
    AF_INET6: Result := ipv6.IP2UStr(True)
    else Result := '';
  end;
end;

function TEndPoint.port: Word;
begin
  Result := ntohs(unknown.sin_port);
end;

procedure TEndPoint.setAddr(const ip: array of Byte; _port: Word);
var
  i: Integer;
begin
  FillChar(Self, SizeOf(Self), 0);
  Self.ipv6.sin6_family := AF_INET6;
  Self.ipv6.sin6_port := htons(_port);

  for i := 0 to 15 do
    Self.ipv6.sin6_addr.s6_bytes[i] := ip[0];
end;

procedure TEndPoint.setAddr(ip: UInt32; _port: Word);
begin
  FillChar(Self, SizeOf(Self), 0);
  Self.ipv4.sin_family := AF_INET;
  Self.ipv4.sin_port := htons(_port);
  Self.ipv4.sin_addr.S_addr := ip;
end;

procedure TEndPoint.setAddr(ip: PAnsiChar; _port: Word);
var
  addr6: IN6_ADDR;
  ip4: UInt32;
  len: Integer;
begin
  if ip = nil then len := 0
  else len := StrLenA(ip);

  FillChar(Self, SizeOf(Self), 0);
  Self.unknown.sin_port := htons(_port);
  Self.unknown.sa_family := AF_INET;

  if len = 0 then Self.ipv4.sin_addr.S_addr := INADDR_ANY
  else begin
    ip4 := inet_addr(ip);

    if ip4 <> INADDR_NONE then
      Self.ipv4.sin_addr.S_addr := ip4
    else if inet6_addr(ip, len, addr6) then
    begin
      Self.unknown.sa_family := AF_INET6;
      Self.ipv6.sin6_addr := addr6;
    end
    else begin
      ip4 := GetHostIP4(ip);

      if ip4 = INADDR_NONE then
        raise EInvalidSockAddr.Create(Ascii2UStr(ip));

      Self.ipv4.sin_addr.S_addr := ip4;
    end;
  end;
end;

procedure TEndPoint.setAddr(ip: TIn6Addr; _port: Word);
begin
  FillChar(Self, SizeOf(Self), 0);
  Self.ipv6.sin6_family := AF_INET6;
  Self.ipv6.sin6_port := htons(_port);
  Move(ip, Self.ipv6.sin6_addr, SizeOf(ip));
end;

procedure TEndPoint.setAddr(const ip: RawByteString; _port: Word);
begin
  Self.setAddr(PAnsiChar(ip), _port);
end;

function TEndPoint.toString: string;
begin
  Result := Self.IP2Str + ':' + IntToStr(port);
end;

function TEndPoint.family: Integer;
begin
  Result := unknown.sin_family;
end;

{ TEndPointCreator }

function _TEndPointCreator.Create(const ip: array of Byte; port: Word): TEndPoint;
begin
  Result.setAddr(ip, port);
end;

function _TEndPointCreator.Create(ip: UInt32; port: Word): TEndPoint;
begin
  Result.setAddr(ip, port);
end;

function _TEndPointCreator.Create(ip: TIn6Addr; port: Word): TEndPoint;
begin
  Result.setAddr(ip, port);
end;

function _TEndPointCreator.Create(ip: PAnsiChar; port: Word): TEndPoint;
begin
  Result.setAddr(ip, port);
end;

function _TEndPointCreator.Create(const ip: RawByteString; port: Word): TEndPoint;
begin
  Result.setAddr(ip, port);
end;

function _TEndPointCreator.Create(const IP_Port: string; const DefaultIP: RawByteString;
  DefaultPort: Integer): TEndPoint;
var
  sip, sport: string;
  rsip: RawByteString;
  port, code: Integer;
begin
  StrSplit2(IP_Port, ':', sip, sport);
  sip := Trim(sip);
  sport := Trim(sport);

  if sip = '' then
    rsip := DefaultIP
  else
    rsip := RawByteString(sip);

  if sport = '' then port := DefaultPort
  else begin
    code := 0;
    Val(sport, port, code);
    if (code <> 0) or (port < 0) then
      raise EInvalidSockAddr.Create('invalid port number: "' + sport + '"');
  end;
  Result.setAddr(rsip, port);
end;

{ TCustomClientSocket }

function TCustomClientSocket.connect(const RemoteAddr: RawByteString; RemotePort: Word;
  timeout: Integer; pError: PCommunicationError): Boolean;
var
  EndPoint: TEndPoint;
begin
  EndPoint := TEndPointCreator.Create(RemoteAddr, RemotePort);
  Result := Self.connect(EndPoint.unknown, EndPoint.bytes, timeout, pError);
end;

function TCustomClientSocket._connect(const ServerAddr: TSockAddr;
  AddrLen, timeout: Integer; pError: PCommunicationError): Boolean;
var
  iret, errcode: Integer;
begin
  errcode := 0;

  if Handle = INVALID_SOCKET then
  begin
    Result := AllocateHandle(ServerAddr.sin_family, SOCK_STREAM, nil);
    if not Result then Exit;
  end;

  if timeout > 0 then
  begin
    Self.blocking := False;

    try
      iret := DSLWinsock2.connect(Handle, @ServerAddr, AddrLen);

      if iret = SOCKET_ERROR then
      begin
        errcode := WSAGetLastError;

        if (errcode = WSAEWOULDBLOCK) or (errcode = ERROR_IO_PENDING) or (errcode = ERROR_IO_INCOMPLETE) then
        begin
          if Self.writable(timeout) then
          begin
            Result := True;
            errcode := 0;
          end
          else begin
            errcode := WSAETIMEDOUT;
            Result := False;
          end;
        end
        else
          Result := False;
      end
      else
        Result := True;
    finally
      Self.blocking := True;
    end;
  end
  else begin
    Result := DSLWinsock2.connect(Handle, @ServerAddr, AddrLen) <> SOCKET_ERROR;
    if not Result then
      errcode := WSAGetLastError;
  end;

  if not Result then reportError('winsock.connect', errcode, pError);
end;

{ TsslClientSocket }

function TsslClientSocket.connect(const ServerAddr: TSockAddr;
  AddrLen, timeout: Integer; pError: PCommunicationError): Boolean;
begin
  Result := Self._connect(ServerAddr, AddrLen, timeout, pError) and
    Self.DoSSLHandshake(pError);
end;

function TsslClientSocket.ConnectViaHttpProxy(const ServerAddr: TSockAddr; AddrLen: Integer;
  const host, username, password: RawByteString; timeout: Integer; pError: PCommunicationError): Boolean;
var
  ConnectHeaders: RawByteString;
  ResponseHeaders: RawByteString;
  ResponseLine: THttpResponseLine;
begin
  Result := False;

  ConnectHeaders := 'CONNECT ' + host + ' HTTP/1.1'#13#10
    + 'Proxy-Connection: keep-alive'#13#10
    + 'Content-Length: 0'#13#10
    + 'Host: ' + host;

  if username <> '' then
    ConnectHeaders := ConnectHeaders + #13#10'Proxy-Authorization: Basic '
      + Base64Encode(username + ':' + password);

  ConnectHeaders := ConnectHeaders + #13#10#13#10;

  if not Self._connect(ServerAddr, AddrLen, timeout, pError) then Exit;

  Self.write(Pointer(ConnectHeaders)^, Length(ConnectHeaders), pError, 0);

  if (Self.ReadRBStr(ResponseHeaders, #13#10, timeout, pError) > 0)
    and (ResponseLine.parse(TAnsiCharSection.Create(ResponseHeaders))) then
  begin
    if (Self.ReadRBStr(ResponseHeaders, #13#10#13#10, timeout, pError) > 0)
      and (ResponseLine.StatusCode = 200) then
      Result := Self.DoSSLHandshake(pError)
    else
      reportError('TsslClientSocket.ConnectViaHttpProxy', WSAECONNREFUSED, pError);
  end;
end;

destructor TsslClientSocket.Destroy;
begin
  if Assigned(FSSL) then
    SSL_free(FSSL);

  inherited;
end;

function TsslClientSocket.DoSSLHandshake(pError: PCommunicationError): Boolean;
begin
  openssl_loadlib;

  if Assigned(FSSL) then
  begin
    SSL_free(FSSL);
    FSSL := nil;
  end;

  FSSL := SSL_new(getClientSSLCtx(TLSv1_client_method()));

  SSL_set_fd(FSSl, Self.Handle);

  if SSL_connect(FSSL) = -1 then
    Result := sslReportError('openssl.SSL_connect', -1, pError)
  else begin
{$ifdef DBGPRINT_CERT}
    DbgOutput(getX590SubjectName(SSL_get_peer_certificate(FSSL)));
    DbgOutput(getX590IssuerName(SSL_get_peer_certificate(FSSL)));
{$endif}
    Result := True;
  end;
end;

function TsslClientSocket.read(var buf; BufLen: DWORD;
  pError: PCommunicationError; flags: DWORD): Integer;
begin
  if Assigned(FSSL) then
  begin
    Result := SSL_read(FSSL, @buf, BufLen);
    if Result < 0 then
    begin
      sslReportError('openssl.SSL_read', Result, pError);
      Result := -1;
    end;
  end
  else
    Result := Self._read(buf, BufLen, pError, flags);
end;

function TsslClientSocket.sslReportError(const operation: string; retValue: Integer;
  pError: PCommunicationError): Boolean;
var
  sslerr: Integer;
begin
  sslerr := SSL_get_error(FSSL, retValue);
  if sslerr = SSL_ERROR_SYSCALL then
    reportError(operation, WSAGetLastError, pError)
  else begin
    if Assigned(pError) then
    begin
      pError.internalErrorCode := sslerr;
      pError.callee := operation;
      pError.code := convertOpenSSLError(sslerr);
    end
    else
      raise EsslError.Create(operation + ' error: '+ IntToStr(sslerr));
  end;
  Result := False;
end;

function TsslClientSocket.write(const buf; BufLen: DWORD;
  pError: PCommunicationError; flags: DWORD): Integer;
begin
  if Assigned(FSSL) then
  begin
    Result := SSL_write(FSSL, @buf, buflen);
    if Result < 0 then
    begin
      sslReportError('openssl.SSL_write', Result, pError);
      Result := -1;
    end;
  end
  else
    Result := Self._write(buf, BufLen, pError, flags);
end;

{ TServerConnection }

function TServerConnection.read;
begin
  Result := Self._read(buf, buflen, pError, flags);
end;

function TServerConnection.write;
begin
  Result := Self._write(buf, BufLen, pError, flags);
end;

type
  TThread_trigger_WSASocket_send_bug = class(TThread)
  private
    FSocket: TClientSocket;
  protected
    procedure Execute; override;
  public
    constructor Create(_socket: TClientSocket);
    destructor Destroy; override;
  end;

{ TThread_trigger_WSASocket_send_bug }

constructor TThread_trigger_WSASocket_send_bug.Create(_socket: TClientSocket);
begin
  FSocket := _socket;
  Self.FreeOnTerminate := True;
  inherited Create(False);
end;

destructor TThread_trigger_WSASocket_send_bug.Destroy;
begin
  FSocket.Release;
  inherited;
end;

procedure TThread_trigger_WSASocket_send_bug.Execute;
var
  buf: array [0..3] of Byte;
begin
  inherited;
  send(FSocket.Handle, buf, SizeOf(buf), 0);
end;

procedure trigger_WSASocket_send_bug;
var
  socket: TClientSocket;
begin
  socket := TClientSocket.Create;
  socket.connect('www.baidu.com', 80);
  TThread_trigger_WSASocket_send_bug.Create(socket);
end;

{ TServerSocket }

function TServerSocket.accpet(Connection: TServerConnection; pErrorCode: PInteger): Boolean;
var
  SockAddr: TEndPoint;
  AddrLen: Integer;
  S: TSocketId;
begin
  AddrLen := SizeOf(SockAddr);
  S := accept(Handle, PSockAddr(@SockAddr), @AddrLen);
  Result :=  S <> INVALID_SOCKET;
  if Result then Connection.FHandle := S
  else begin
    if Assigned(pErrorCode) then pErrorCode^ := WSAGetLastError
    else throwException('accept', WSAGetLastError);
  end
end;

initialization
  SocketInitialize;

finalization
  SocketUnInitialize;

end.

