unit iphlpapi;

interface

uses
  SysUtils, Classes, Windows, dslWinsock2, DSLUtils;

const
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
  MAX_ADAPTER_NAME_LENGTH = 256;
  MAX_ADAPTER_ADDRESS_LENGTH = 8;
  DEFAULT_MINIMUM_ENTITIES = 32;
  MAX_HOSTNAME_LEN = 128;
  MAX_DOMAIN_NAME_LEN = 128;
  MAX_SCOPE_ID_LEN = 256;

  ERROR_NO_DATA: LongInt = 232;
  ERROR_NOT_SUPPORTED: LongInt = 50;
  ERROR_INVALID_PARAMETER: LongInt = 87;
  ERROR_BUFFER_OVERFLOW: LongInt = 111;

  MIB_IF_TYPE_OTHER = 1;            //Some other type of network interface.
  MIB_IF_TYPE_ETHERNET = 6;         //An Ethernet network interface.
  IF_TYPE_ISO88025_TOKENRING = 9;   //MIB_IF_TYPE_TOKENRING
  MIB_IF_TYPE_PPP = 23;             //A PPP network interface.
  MIB_IF_TYPE_LOOPBACK = 24;        //A software loopback network interface.
  MIB_IF_TYPE_SLIP = 28;            //An ATM network interface.
  IF_TYPE_IEEE80211 = 71;           //An IEEE 802.11 wireless network interface.

type
  time_t = Integer;

  TIPAddressString = packed record
    str: array[0..15] of AnsiChar;
  end;
  PIPAddressString = ^TIPAddressString;

  PIPAddrString = ^TIPAddrString;
  TIPAddrString = packed record
    next: PIPAddrString;
    IpAddress: TIPAddressString;
    IpMask: TIPAddressString;
    Context: DWORD;
  end;

  TIPMaskString = TIPAddressString;
  PIPMaskString = ^TIPMaskString;

  PIPAdapterInfo = ^TIPAdapterInfo;

  TIPAdapterInfo = packed record
    Next: PIPAdapterInfo;   //下一个节点的指针
    ComboIndex: DWORD;

    //适配器名称
    AdapterName: array[0..MAX_ADAPTER_NAME_LENGTH + 3] of AnsiChar;

    //适配器描述信息
    Description: array[0..MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of AnsiChar;

    AddressLength: UINT;

    //适配器MAC地址
    Address: array[0..MAX_ADAPTER_ADDRESS_LENGTH - 1] of Byte;

    Index: DWORD;
    uType: UINT;
    DhcpEnabled: UINT;
    CurrentIpAddress: PIPAddrString;
    IpAddressList: TIPAddrString;
    GatewayList: TIPAddrString;
    DhcpServer: TIPAddrString;
    HaveWins: BOOL;
    PrimaryWinsServer: TIPAddrString;
    SecondaryWinsServer: TIPAddrString;
    LeaseObtained: time_t;
    LeaseExpires: time_t;
  end;

  //MIB = Management Information Base
  TMibIpForwardRow = record
    dwForwardDest: DWORD;
    dwForwardMask: DWORD;
    dwForwardPolicy: DWORD;
    dwForwardNextHop: DWORD;
    dwForwardIfIndex: DWORD;
    dwForwardType: DWORD;
    dwForwardProto: DWORD;
    dwForwardAge: DWORD;
    dwForwardNextHopAS: DWORD;
    dwForwardMetric1: DWORD;
    dwForwardMetric2: DWORD;
    dwForwardMetric3: DWORD;
    dwForwardMetric4: DWORD;
    dwForwardMetric5: DWORD;
  end;
  PMibIpForwardRow = ^TMibIpForwardRow;
  
   IP_OPTION_INFORMATION = packed record
    Ttl: UCHAR;
    Tos: UCHAR;
    Flags: UCHAR;
    OptionsSize: UCHAR;
    OptionsData: PUCHAR;
  end;

  TIPOptionInformation = IP_OPTION_INFORMATION;
  PIPOptionInformation = ^TIPOptionInformation;
  PIP_OPTION_INFORMATION = ^IP_OPTION_INFORMATION;

  ICMP_ECHO_REPLY = packed record
    Address: TInAddr;
    Status: ULONG;
    RoundTripTime: ULONG;
    DataSize: Word;
    Reserved: Word;
    Data: Pointer;
    Options: TIPOptionInformation;
  end;

  PICMP_ECHO_REPLY = ^ICMP_ECHO_REPLY;
  TIcmpEchoReply = ICMP_ECHO_REPLY;
  PIcmpEchoReply = ^TIcmpEchoReply;

function GetBestRoute(dwDestAddr, dwSourceAddr: DWORD;out BestRoute: TMibIpForwardRow): DWORD; stdcall;
function GetAdaptersInfo(Buf: PIPAdapterInfo; var BufLen: ULONG): DWORD; stdcall;
function IcmpCreateFile: THandle; stdcall;
function IcmpCloseHandle(IcmpHandle: THandle): BOOL; stdcall;

function IcmpSendEcho(IcmpHandle: THandle; DestinationAddress: DWORD; RequestData: Pointer; RequestSize: Word;
  RequestOptions: PIPOptionInformation; ReplyBuffer: Pointer; ReplySize: DWORD; Timeout: DWORD): DWORD; stdcall;
  
type
  TEnumResult = (erNoItem, erFound, erNotFound);
  TEnumAdapterProc = function(adapter: PIPAdapterInfo;
    param: Integer): Boolean;

function EnumAdapters(proc: TEnumAdapterProc; param: Integer): Boolean;
function IsNetworkHardware(const name: string): Boolean;
procedure GetMacs(macs: TStrings; const delimiter: string = '-'; UpperCase: Boolean = False);
function GetOneMacRaw: TBytes;
function GetOneMac(const delimiter: string = '-'; UpperCase: Boolean = False): string;
function GetBestRouteIfAddress(dwDestAddr, dwSourceAddr: DWORD): DWORD;
function RandomMac(DelimiterChar: Char = '-'; UpperCase: Boolean = False): string;

implementation

const
  iphlpapi_dll = 'iphlpapi.dll';

function IcmpCreateFile; external iphlpapi_dll name 'IcmpCreateFile';
function IcmpCloseHandle; external iphlpapi_dll name 'IcmpCloseHandle';
function IcmpSendEcho; external iphlpapi_dll name 'IcmpSendEcho'; 
function GetAdaptersInfo; external iphlpapi_dll;
function GetBestRoute; external iphlpapi_dll;

function EnumAdapters(proc: TEnumAdapterProc; param: Integer): Boolean;
var
  adapters, iterator: PIPAdapterInfo;
  BufSize, RetValue: DWORD;
begin
  Result := False;
  BufSize := 0;
  RetValue := GetAdaptersInfo(nil, BufSize);
  if RetValue <> DWORD(ERROR_BUFFER_OVERFLOW) then Exit;

  adapters := PIPAdapterInfo(GetMemory(BufSize));
  try
    if GetAdaptersInfo(adapters, BufSize) <> ERROR_SUCCESS then Exit;
    iterator := adapters;
    while Assigned(iterator) do
    begin
      if proc(iterator, param) then iterator := iterator.Next
      else Exit;
    end;
    Result := True;
  finally
    FreeMemory(adapters);
  end;
end;

function RandomMac(DelimiterChar: Char = '-'; UpperCase: Boolean = False): string;
begin
end;

type
  TGetOneMacParam = record
    uType: UINT;
    AddressLength: UINT;
    Address: array[0..MAX_ADAPTER_ADDRESS_LENGTH - 1] of Byte;
  end;
  PGetOneMacParam = ^TGetOneMacParam;

function Proc_GetOneMac(adapter: PIPAdapterInfo; param: Integer): Boolean;
var
  i: Integer;
begin
  if (adapter.uType = PGetOneMacParam(param).uType) and
    IsNetworkHardware(string(RawByteString(adapter.AdapterName))) then
  begin
    PGetOneMacParam(param).AddressLength := adapter.AddressLength;
    for i := 0 to adapter.AddressLength - 1 do
      PGetOneMacParam(param).Address[i] := adapter.Address[i];
    Result := False;
  end
  else Result := True;
end;

function GetOneMacRaw: TBytes;
var
  param: TGetOneMacParam;
  found: Boolean;
  i: Integer;
begin
  SetLength(Result, 0);
  param.uType := MIB_IF_TYPE_ETHERNET;
  if EnumAdapters(Proc_GetOneMac, Integer(@param)) then
  begin
    param.uType := IF_TYPE_IEEE80211;
    found := not EnumAdapters(Proc_GetOneMac, Integer(@param));
  end
  else found := True;

  if found then
  begin
    SetLength(Result, param.AddressLength);

    for i := 0 to param.AddressLength - 1 do
      Result[i] := param.Address[i];
  end;
end;

function GetOneMac(const delimiter: string; UpperCase: Boolean): string;
var
  mac: TBytes;
begin
  mac := GetOneMacRaw;

  if Length(mac) = 0 then Result := ''
  else Result := MemHexUStr(mac[0], Length(mac), UpperCase, delimiter);
end;

type
  TGetMacsParam = record
    uType: UINT;
    strs: TStrings;
    delimiter: string;
    UpperCase: Boolean;
  end;
  PGetMacsParam = ^TGetMacsParam;

function Proc_GetMacs(adapter: PIPAdapterInfo; param: Integer): Boolean;
begin
  if IsNetworkHardware(string(RawByteString(adapter.AdapterName))) then
    with PGetMacsParam(param)^ do
      strs.Add(MemHexUStr(adapter.Address, adapter.AddressLength, UpperCase, delimiter));

  Result := True;
end;

procedure GetMacs(macs: TStrings; const delimiter: string; UpperCase: Boolean);
var
  param: PGetMacsParam;
begin
  param.uType := MIB_IF_TYPE_ETHERNET;
  param.strs := macs;
  param.delimiter := delimiter;
  param.UpperCase := UpperCase;

  EnumAdapters(Proc_GetMacs, Integer(@param));
end;

type
  TGetAddrByIfIndex_Param = record
    IfIndex: DWORD;
    ip: DWORD;
  end;
  PGetAddrByIfIndex_Param = ^TGetAddrByIfIndex_Param;

function Proc_GetAddrByIfIndex(adapter: PIPAdapterInfo;
  param: Integer): Boolean;
begin
  if (adapter.Index = PGetAddrByIfIndex_Param(param).IfIndex) then
  begin
    PGetAddrByIfIndex_Param(param).ip :=
      inet_addr(adapter.IpAddressList.IpAddress.str);
    Result := False;
  end
  else Result := True;
end;

function GetBestRouteIfAddress(dwDestAddr, dwSourceAddr: DWORD): DWORD;
var
  row: TMibIpForwardRow;
  param: TGetAddrByIfIndex_Param;
begin
  Result := 0;
  if GetBestRoute(dwDestAddr, dwSourceAddr, row) = NO_ERROR then
  begin
    if row.dwForwardNextHop = DWORD(inet_addr('127.0.0.1')) then
      Result := dwDestAddr
    else begin
      param.IfIndex := row.dwForwardIfIndex;
      param.ip := 0;
      if not EnumAdapters(Proc_GetAddrByIfIndex, Integer(@param)) then
        Result := param.ip;
    end;
  end;
end;

function IsNetworkHardware(const name: string): Boolean;
const
  NETWORK_REG_KEY = 'System\CurrentControlSet\Control\\Network\' +
    '{4D36E972-E325-11CE-BFC1-08002BE10318}\';
var
  key: HKEY;
  //MediaType: DWORD
  KeyType, ValueLen: DWORD;
  PnpInstanceID: array [0..1023] of Char;
begin
  Result := False;
  if ERROR_SUCCESS = RegOpenKeyEx(HKEY_LOCAL_MACHINE,
    PChar(NETWORK_REG_KEY + name + '\Connection'),
    0, KEY_READ, key) then
  try
    {KeyType := REG_DWORD;
    ValueLen := SizeOf(MediaType);
    if ERROR_SUCCESS <> RegQueryValueEx(key, 'MediaSubType', nil, @KeyType,
      PByte(@MediaType), @ValueLen) then Exit;}
    KeyType := REG_SZ;
    ValueLen := SizeOf(PnpInstanceID);
    if ERROR_SUCCESS <> RegQueryValueEx(key, 'PnpInstanceID', nil, @KeyType,
      PByte(@PnpInstanceID), @ValueLen) then Exit;
    Result := ((PnpInstanceID[0] = 'P') and (PnpInstanceID[1] = 'C') and
      (PnpInstanceID[2] = 'I') and (PnpInstanceID[3] = '\')) or
      ((PnpInstanceID[0] = 'U') and (PnpInstanceID[1] = 'S') and
      (PnpInstanceID[2] = 'B') and (PnpInstanceID[3] = '\'));
  finally
    RegCloseKey(key);
  end;
end;

end.

