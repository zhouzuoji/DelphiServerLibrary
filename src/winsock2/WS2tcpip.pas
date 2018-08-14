{******************************************************************************}
{                                                                              }
{ Winsock2 API interface Unit for Object Pascal                                }
{                                                                              }
{ Portions created by Microsoft are Copyright (C) 1995-2001 Microsoft          }
{ Corporation. All Rights Reserved.                                            }
{                                                                              }
{ The original file is: winsock2.h, released June 2000. The original Pascal    }
{ code is: WinSock2.pas, released December 2000. The initial developer of the  }
{ Pascal code is Marcel van Brakel (brakelm att chello dott nl).               }
{                                                                              }
{ Portions created by Marcel van Brakel are Copyright (C) 1999-2001            }
{ Marcel van Brakel. All Rights Reserved.                                      }
{                                                                              }
{ Obtained through: Joint Endeavour of Delphi Innovators (Project JEDI)        }
{                                                                              }
{ You may retrieve the latest version of this file at the Project JEDI         }
{ APILIB home page, located at http://jedi-apilib.sourceforge.net              }
{                                                                              }
{ The contents of this file are used with permission, subject to the Mozilla   }
{ Public License Version 1.1 (the "License"); you may not use this file except }
{ in compliance with the License. You may obtain a copy of the License at      }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                      }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ Alternatively, the contents of this file may be used under the terms of the  }
{ GNU Lesser General Public License (the  "LGPL License"), in which case the   }
{ provisions of the LGPL License are applicable instead of those above.        }
{ If you wish to allow use of your version of this file only under the terms   }
{ of the LGPL License and not to allow others to use your version of this file }
{ under the MPL, indicate your decision by deleting  the provisions above and  }
{ replace  them with the notice and other provisions required by the LGPL      }
{ License.  If you do not delete the provisions above, a recipient may use     }
{ your version of this file under either the MPL or the LGPL License.          }
{                                                                              }
{ For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html }
{                                                                              }
{******************************************************************************}

unit WS2tcpip;

interface

uses
  SysUtils, Windows, dslWinsock2;

type
  ip_mreq = record
    imr_multiaddr: in_addr;
    imr_interface: in_addr; 
  end;
  TIPMReq = ip_mreq;
  PIPMReq = ^ip_mreq;

  ip_mreq_source = record
    imr_multiaddr: in_addr;
    imr_sourceaddr: in_addr;
    imr_interface: in_addr;
  end;
  TIpMreqSource = ip_mreq_source;
  PIpMreqSource = ^ip_mreq_source;

  ip_msfilter = record
    imsf_multiaddr: in_addr;
    imsf_interface: in_addr;
    imsf_fmode: UInt32;
    imsf_numsrc: UInt32;
    imsf_slist: array[0..0] of in_addr;
  end;
  TIpMsFilter = ip_msfilter;
  PIpMsFilter = ^ip_msfilter;

function IP_MSFILTER_SIZE(numsrc: Integer): Integer;

const
  MCAST_INCLUDE = 0; {$EXTERNALSYM MCAST_INCLUDE}
  MCAST_EXCLUDE = 1; {$EXTERNALSYM MCAST_EXCLUDE}

const
  SIO_GET_INTERFACE_LIST = IOC_OUT or ((4 and IOCPARM_MASK) shl 16) or
    ((Ord('t')) shl 8) or (127);
  SIO_GET_INTERFACE_LIST_EX = IOC_OUT or ((4 and IOCPARM_MASK) shl 16) or
    ((Ord('t')) shl 8) or (126);
  SIO_SET_MULTICAST_FILTER = DWORD(IOC_IN or ((SizeOf(UInt32) and IOCPARM_MASK)
    shl 16) or (Ord('t') shl 8) or 125);
  SIO_GET_MULTICAST_FILTER = DWORD(IOC_IN or ((SizeOf(UInt32) and IOCPARM_MASK)
    shl 16) or (Ord('t') shl 8) or 124 or IOC_IN);

const
  IP_OPTIONS = 1; {$EXTERNALSYM IP_OPTIONS} 
  IP_HDRINCL = 2; {$EXTERNALSYM IP_HDRINCL}
  IP_TOS = 3; {$EXTERNALSYM IP_TOS}
  IP_TTL = 4; {$EXTERNALSYM IP_TTL}
  IP_MULTICAST_IF = 9; {$EXTERNALSYM IP_MULTICAST_IF}
  IP_MULTICAST_TTL = 10; {$EXTERNALSYM IP_MULTICAST_TTL}
  IP_MULTICAST_LOOP = 11; {$EXTERNALSYM IP_MULTICAST_LOOP}
  IP_ADD_MEMBERSHIP = 12; {$EXTERNALSYM IP_ADD_MEMBERSHIP}
  IP_DROP_MEMBERSHIP = 13; {$EXTERNALSYM IP_DROP_MEMBERSHIP}
  IP_DONTFRAGMENT = 14; {$EXTERNALSYM IP_DONTFRAGMENT}
  IP_ADD_SOURCE_MEMBERSHIP = 15; {$EXTERNALSYM IP_ADD_SOURCE_MEMBERSHIP}
  IP_DROP_SOURCE_MEMBERSHIP = 16; {$EXTERNALSYM IP_DROP_SOURCE_MEMBERSHIP}
  IP_BLOCK_SOURCE = 17; {$EXTERNALSYM IP_BLOCK_SOURCE}
  IP_UNBLOCK_SOURCE = 18; {$EXTERNALSYM IP_UNBLOCK_SOURCE}
  IP_PKTINFO = 19; {$EXTERNALSYM IP_PKTINFO}

  IPV6_HDRINCL = 2; {$EXTERNALSYM IPV6_HDRINCL}
  IPV6_UNICAST_HOPS = 4; {$EXTERNALSYM IPV6_UNICAST_HOPS}
  IPV6_MULTICAST_IF = 9; {$EXTERNALSYM IPV6_MULTICAST_IF}
  IPV6_MULTICAST_HOPS = 10; {$EXTERNALSYM IPV6_MULTICAST_HOPS}
  IPV6_MULTICAST_LOOP = 11; {$EXTERNALSYM IPV6_MULTICAST_LOOP}
  IPV6_ADD_MEMBERSHIP = 12; {$EXTERNALSYM IPV6_ADD_MEMBERSHIP}
  IPV6_DROP_MEMBERSHIP = 13; {$EXTERNALSYM IPV6_DROP_MEMBERSHIP}
  IPV6_JOIN_GROUP = IPV6_ADD_MEMBERSHIP;
  IPV6_LEAVE_GROUP = IPV6_DROP_MEMBERSHIP;
  IPV6_PKTINFO = 19; {$EXTERNALSYM IPV6_PKTINFO}

  UDP_NOCHECKSUM = 1; {$EXTERNALSYM UDP_NOCHECKSUM}
  UDP_CHECKSUM_COVERAGE = 20; {$EXTERNALSYM UDP_CHECKSUM_COVERAGE} 
  TCP_EXPEDITED_1122 = $0002; {$EXTERNALSYM TCP_EXPEDITED_1122}

type
  in6_addr = record
    case Integer of
      0: (Byte: array[0..15] of Byte);
      1: (Word: array[0..7] of Word);
      2: (s6_bytes: array[0..15] of Byte);
      3: (s6_addr: array[0..15] of Byte);
      4: (s6_words: array[0..7] of Word);
      5: (Dwords: array [0..3] of UInt32);
  end;
  TIn6Addr = in6_addr;
  PIn6Addr = ^in6_addr;

type
  ipv6_mreq = record
    ipv6mr_multiaddr: in6_addr;
    ipv6mr_interface: Cardinal;
  end;
  TIpV6MReq = ipv6_mreq;
  PIpV6MReq = ^ipv6_mreq;

type
  in_addr6 = record
    s6_addr: array[0..15] of Byte;
  end;
  TInAddr6 = in_addr6;
  PInAddr6 = ^in_addr6;

type
  sockaddr_in6_old = record
    sin6_family: short;
    sin6_port: Word;
    sin6_flowinfo: UInt32;
    sin6_addr: in6_addr;
  end;
  TSockAddrIn6Old = sockaddr_in6_old;
  PSockAddrIn6Old = ^sockaddr_in6_old;

  SOCKADDR_IN6 = record
    sin6_family: short;
    sin6_port: Word;
    sin6_flowinfo: UInt32;
    sin6_addr: in6_addr;
    sin6_scope_id: UInt32;
  end;
  PSOCKADDR_IN6 = ^SOCKADDR_IN6;
  LPSOCKADDR_IN6 = ^SOCKADDR_IN6;
  TSockAddrIn6 = SOCKADDR_IN6;
  PSockAddrIn6 = LPSOCKADDR_IN6;

function SS_PORT(ssp: Pointer): Word;

const
  IN6ADDR_ANY_INIT: in6_addr = (Word: (0, 0, 0, 0, 0, 0, 0, 0));
  IN6ADDR_LOOPBACK_INIT: in6_addr = (Byte: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 1));
  in6addr_any: in6_addr = (Word: (0, 0, 0, 0, 0, 0, 0, 0));
  in6addr_loopback: in6_addr = (Byte: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1));

procedure IN6ADDR_SETANY(var x: TSockAddrIn6);
procedure IN6ADDR_SETLOOPBACK(var x: TSockAddrIn6);
function IN6ADDR_ISANY(const x: TSockAddrIn6): Boolean;
function IN6ADDR_ISLOOPBACK(const x: TSockAddrIn6): Boolean;
function IN6_ADDR_EQUAL(const a, b: in6_addr): Boolean;
function IN6_IS_ADDR_UNSPECIFIED(const a: in6_addr): boolean;
function IN6_IS_ADDR_LOOPBACK(const a: in6_addr): Boolean;
function IN6_IS_ADDR_MULTICAST(const a: in6_addr): Boolean;
function IN6_IS_ADDR_LINKLOCAL(const a: in6_addr): Boolean;
function IN6_IS_ADDR_SITELOCAL(const a: in6_addr): Boolean;
function IN6_IS_ADDR_V4MAPPED(const a: in6_addr): Boolean;
function IN6_IS_ADDR_V4COMPAT(const a: in6_addr): Boolean;
function IN6_IS_ADDR_MC_NODELOCAL(const a: in6_addr): Boolean;
function IN6_IS_ADDR_MC_LINKLOCAL(const a: in6_addr): Boolean;
function IN6_IS_ADDR_MC_SITELOCAL(const a: in6_addr): Boolean;
function IN6_IS_ADDR_MC_ORGLOCAL(const a: in6_addr): Boolean;
function IN6_IS_ADDR_MC_GLOBAL(const a: in6_addr): Boolean;

type
  sockaddr_gen = record
    case Integer of
      0: (Address: sockaddr);
      1: (AddressIn: sockaddr_in);
      2: (AddressIn6: sockaddr_in6_old);
  end;
  TSockAddrGen = sockaddr_gen;
  PSockAddrGen = ^sockaddr_gen;

  _INTERFACE_INFO = record
    iiFlags: UInt32;
    iiAddress: sockaddr_gen;
    iiBroadcastAddress: sockaddr_gen;
    iiNetmask: sockaddr_gen;
  end;
  INTERFACE_INFO = _INTERFACE_INFO;
  LPINTERFACE_INFO = ^INTERFACE_INFO;
  TInterfaceInfo = INTERFACE_INFO;
  PInterfaceInfo = LPINTERFACE_INFO;

  _INTERFACE_INFO_EX = record
    iiFlags: UInt32;
    iiAddress: SOCKET_ADDRESS;
    iiBroadcastAddress: SOCKET_ADDRESS;
    iiNetmask: SOCKET_ADDRESS;
  end;
  INTERFACE_INFO_EX = _INTERFACE_INFO_EX;
  LPINTERFACE_INFO_EX = ^INTERFACE_INFO_EX;
  TInterfaceInfoEx = INTERFACE_INFO_EX;
  PInterfaceInfoEx = LPINTERFACE_INFO_EX;

const
  IFF_UP = $00000001; {$EXTERNALSYM IFF_UP}
  IFF_BROADCAST = $00000002; {$EXTERNALSYM IFF_BROADCAST}
  IFF_LOOPBACK = $00000004; {$EXTERNALSYM IFF_LOOPBACK}
  IFF_POINTTOPOINT = $00000008; {$EXTERNALSYM IFF_POINTTOPOINT}
  IFF_MULTICAST = $00000010; {$EXTERNALSYM IFF_MULTICAST} 

type
  in_pktinfo = record
    ipi_addr: IN_ADDR;
    ipi_ifindex: UINT;
  end;
  TInPktInfo = in_pktinfo;
  PInPktInfo = ^in_pktinfo;

  in6_pktinfo = record
    ipi6_addr: IN6_ADDR;
    ipi6_ifindex: UINT;
  end;
  TIn6PktInfo = in6_pktinfo;
  PIn6PktInfo = ^in6_pktinfo;

const
  EAI_AGAIN = WSATRY_AGAIN;
  EAI_BADFLAGS = WSAEINVAL;
  EAI_FAIL = WSANO_RECOVERY;
  EAI_FAMILY = WSAEAFNOSUPPORT;
  EAI_MEMORY = WSA_NOT_ENOUGH_MEMORY;
  EAI_NONAME = WSAHOST_NOT_FOUND;
  EAI_SERVICE = WSATYPE_NOT_FOUND;
  EAI_SOCKTYPE = WSAESOCKTNOSUPPORT;
  EAI_NODATA = EAI_NONAME;

type
  LPADDRINFO = ^addrinfo;
  addrinfo = record
    ai_flags: Integer;
    ai_family: Integer;
    ai_socktype: Integer;
    ai_protocol: Integer;
    ai_addrlen: Cardinal;
    ai_canonname: PAnsiChar;
    ai_addr: PSockAddr;
    ai_next: LPADDRINFO;
  end;
  TAddrInfo = addrinfo;
  PAddrInfo = LPADDRINFO;

const
  AI_PASSIVE = $1; {$EXTERNALSYM AI_PASSIVE}
  AI_CANONNAME = $2; {$EXTERNALSYM AI_CANONNAME}
  AI_NUMERICHOST = $4; {$EXTERNALSYM AI_NUMERICHOST}

type
  socklen_t = Integer;
  TFNGetNameInfo = function(sa: PSockAddr; salen: socklen_t; host: PAnsiChar;
    hostlen: DWORD; serv: PAnsiChar; servlen: DWORD; flags: Integer): Integer; stdcall;
  TFNGetAddrInfo = function(nodename, servname: PAnsiChar; hints: PAddrInfo;
    var res: PAddrInfo): Integer; stdcall;
  TFNFreeAddrInfo = procedure(ai: PAddrInfo); stdcall;

var
  getaddrinfo: TFNGetAddrInfo;
  freeaddrinfo: TFNFreeAddrInfo;
  getnameinfo: TFNGetNameInfo;

const
  GAI_STRERROR_BUFFER_SIZE = 1024; {$EXTERNALSYM GAI_STRERROR_BUFFER_SIZE}

function gai_strerrorA(ecode: Integer): PAnsiChar;
function gai_strerrorW(ecode: Integer): PWideChar;
{$IFDEF UNICODE}
function gai_strerror(ecode: Integer): PWideChar;
{$ELSE}
function gai_strerror(ecode: Integer): PAnsiChar;
{$ENDIF}

const
  NI_MAXHOST = 1025; {$EXTERNALSYM NI_MAXHOST} // Max size of a fully-qualified domain name
  NI_MAXSERV = 32; {$EXTERNALSYM NI_MAXSERV} // Max size of a service name
  
  INET_ADDRSTRLEN = 16; {$EXTERNALSYM INET_ADDRSTRLEN} // Max size of numeric form of IPv4 address
  INET6_ADDRSTRLEN = 46; {$EXTERNALSYM INET6_ADDRSTRLEN} // Max size of numeric form of IPv6 address

  NI_NOFQDN = $01; {$EXTERNALSYM NI_NOFQDN}
  NI_NUMERICHOST = $02; {$EXTERNALSYM NI_NUMERICHOST}
  NI_NAMEREQD = $04; {$EXTERNALSYM NI_NAMEREQD}
  NI_NUMERICSERV = $08; {$EXTERNALSYM NI_NUMERICSERV}
  NI_DGRAM = $10; {$EXTERNALSYM NI_DGRAM}

implementation

function IP_MSFILTER_SIZE(numsrc: Integer): Integer;
begin
  Result := SizeOf(ip_msfilter) - SizeOf(in_addr) + (numsrc * SizeOf(in_addr));
end;

function SS_PORT(ssp: Pointer): Word;
begin
  Result := PSockAddrIn(ssp)^.sin_port;
end;

procedure IN6ADDR_SETANY(var x: TSockAddrIn6);
var
  I: Integer;
begin
  x.sin6_family := AF_INET6;
  x.sin6_port := 0;
  x.sin6_flowinfo := 0;
  for I := 0 to 15 do
    x.sin6_addr.s6_addr[I] := 0;
end;

procedure IN6ADDR_SETLOOPBACK(var x: TSockAddrIn6);
var
  I: Integer;
begin
  x.sin6_family := AF_INET6;
  x.sin6_port := 0;
  x.sin6_flowinfo := 0;
  for I := 0 to 14 do
    x.sin6_addr.s6_addr[I] := 0;
  x.sin6_addr.s6_addr[15] := 1;
end;

function IN6ADDR_ISANY(const x: TSockAddrIn6): Boolean;
var
  I: Integer;
begin
  Result := x.sin6_family = AF_INET6;
  for I := 0 to 15 do
    Result := Result and (x.sin6_addr.s6_addr[I] = 0);
end;

function IN6ADDR_ISLOOPBACK(const x: TSockAddrIn6): Boolean;
var
  I: Integer;
begin
  Result := x.sin6_family = AF_INET6;
  for I := 0 to 14 do
    Result := Result and (x.sin6_addr.s6_addr[I] = 0);
  Result := Result and (x.sin6_addr.s6_addr[15] = 1);
end;

function IN6_ADDR_EQUAL(const a, b: in6_addr): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := Low(a.Word) to High(a.Word) do
    Result := (a.Word[I] = b.Word[I]) and Result;
end;

function IN6_IS_ADDR_UNSPECIFIED(const a: in6_addr): boolean;
begin
  Result := IN6_ADDR_EQUAL(a, in6addr_any);
end;

function IN6_IS_ADDR_LOOPBACK(const a: in6_addr): Boolean;
begin
  Result := IN6_ADDR_EQUAL(a, in6addr_loopback);
end;

function IN6_IS_ADDR_MULTICAST(const a: in6_addr): Boolean;
begin
  Result := (a.s6_bytes[0] = $FF);
end;

function IN6_IS_ADDR_LINKLOCAL(const a: in6_addr): Boolean;
begin
  Result := ((a.s6_bytes[0] = $FE) and ((a.s6_bytes[1] and $C0) = $80));
end;

function IN6_IS_ADDR_SITELOCAL(const a: in6_addr): Boolean;
begin
  Result := ((a.s6_bytes[0] = $FE) and ((a.s6_bytes[1] and $C0) = $C0));
end;

function IN6_IS_ADDR_V4MAPPED(const a: in6_addr): Boolean;
begin
  Result := ((a.s6_words[0] = 0) and (a.s6_words[1] = 0) and (a.s6_words[2] = 0)
    and
    (a.s6_words[3] = 0) and (a.s6_words[4] = 0) and (a.s6_words[5] = $FFFF));
end;

function IN6_IS_ADDR_V4COMPAT(const a: in6_addr): Boolean;
begin
  Result :=
    ((a.s6_words[0] = 0) and
    (a.s6_words[1] = 0) and
    (a.s6_words[2] = 0) and
    (a.s6_words[3] = 0) and
    (a.s6_words[4] = 0) and
    (a.s6_words[5] = 0) and
    not ((a.s6_words[6] = 0) and
    (a.s6_addr[14] = 0) and
    ((a.s6_addr[15] = 0) or (a.s6_addr[15] = 1))));
end;

function IN6_IS_ADDR_MC_NODELOCAL(const a: in6_addr): Boolean;
begin
  Result := IN6_IS_ADDR_MULTICAST(a) and ((a.s6_bytes[1] and $F) = 1);
end;

function IN6_IS_ADDR_MC_LINKLOCAL(const a: in6_addr): Boolean;
begin
  Result := IN6_IS_ADDR_MULTICAST(a) and ((a.s6_bytes[1] and $F) = 2);
end;

function IN6_IS_ADDR_MC_SITELOCAL(const a: in6_addr): Boolean;
begin
  Result := IN6_IS_ADDR_MULTICAST(a) and ((a.s6_bytes[1] and $F) = 5);
end;

function IN6_IS_ADDR_MC_ORGLOCAL(const a: in6_addr): Boolean;
begin
  Result := IN6_IS_ADDR_MULTICAST(a) and ((a.s6_bytes[1] and $F) = 8);
end;

function IN6_IS_ADDR_MC_GLOBAL(const a: in6_addr): Boolean;
begin
  Result := IN6_IS_ADDR_MULTICAST(a) and ((a.s6_bytes[1] and $F) = $E);
end;

var
  gai_strerror_buffA: array[0..GAI_STRERROR_BUFFER_SIZE - 1] of AnsiChar;
  gai_strerror_buffW: array[0..GAI_STRERROR_BUFFER_SIZE - 1] of WideChar;

function MAKELANGID(PrimaryLang, SubLang: WORD): WORD;
begin
  Result := (SubLang shl 10) or PrimaryLang;
end;

function gai_strerrorA(ecode: Integer): PAnsiChar;
var
  dwMsgLen: DWORD;
begin
  dwMsgLen := FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM or
    FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_MAX_WIDTH_MASK,
    nil, ecode, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
      PAnsiChar(@gai_strerror_buffA[0]), GAI_STRERROR_BUFFER_SIZE, nil);
  if dwMsgLen = 0 then
    Result := nil
  else
    Result := PAnsiChar(@gai_strerror_buffA[0]);
end;

function gai_strerrorW(ecode: Integer): PWideChar;
var
  dwMsgLen: DWORD;
begin
  dwMsgLen := FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM or
    FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_MAX_WIDTH_MASK,
    nil, ecode, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
      PWideChar(@gai_strerror_buffW[0]), GAI_STRERROR_BUFFER_SIZE, nil);
  if dwMsgLen = 0 then
    Result := nil
  else
    Result := PWideChar(@gai_strerror_buffW[0]);
end;

{$IFDEF UNICODE}
function gai_strerror(ecode: Integer): PWideChar;
begin
  Result := gai_strerrorW(ecode);
end;
{$ELSE}

function gai_strerror(ecode: Integer): PAnsiChar;
begin
  Result := gai_strerrorA(ecode);
end;
{$ENDIF}

const
  ws2tcpip_dll = 'ws2_32.dll';

var
  Winsock2Lib: THandle;

procedure LoadLib;
begin
  Winsock2Lib := LoadLibrary(ws2tcpip_dll);
  getaddrinfo := GetProcAddress(Winsock2Lib, 'getaddrinfo');
  freeaddrinfo := GetProcAddress(Winsock2Lib, 'freeaddrinfo');
  getnameinfo := GetProcAddress(Winsock2Lib, 'getnameinfo');
end;

procedure UnloadLib;
begin
  getaddrinfo := nil;
  freeaddrinfo := nil;
  getnameinfo := nil;
  FreeLibrary(Winsock2Lib);
end;

initialization
  LoadLib;

finalization
  UnloadLib;
  
end.

