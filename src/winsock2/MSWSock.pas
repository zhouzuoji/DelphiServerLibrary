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

unit MSWSock;

interface

uses
  Windows, DSLWinsock2;

const
  SO_CONNDATA = $7000; {$EXTERNALSYM SO_CONNDATA}
  SO_CONNOPT = $7001; {$EXTERNALSYM SO_CONNOPT}
  SO_DISCDATA = $7002; {$EXTERNALSYM SO_DISCDATA}
  SO_DISCOPT = $7003; {$EXTERNALSYM SO_DISCOPT}
  SO_CONNDATALEN = $7004; {$EXTERNALSYM SO_CONNDATALEN}
  SO_CONNOPTLEN = $7005; {$EXTERNALSYM SO_CONNOPTLEN}
  SO_DISCDATALEN = $7006; {$EXTERNALSYM SO_DISCDATALEN}
  SO_DISCOPTLEN = $7007; {$EXTERNALSYM SO_DISCOPTLEN}

const
  SO_OPENTYPE = $7008; {$EXTERNALSYM SO_OPENTYPE}
  SO_SYNCHRONOUS_ALERT = $10; {$EXTERNALSYM SO_SYNCHRONOUS_ALERT}
  SO_SYNCHRONOUS_NONALERT = $20; {$EXTERNALSYM SO_SYNCHRONOUS_NONALERT}

const
  SO_MAXDG = $7009; {$EXTERNALSYM SO_MAXDG}
  SO_MAXPATHDG = $700A; {$EXTERNALSYM SO_MAXPATHDG}
  SO_UPDATE_ACCEPT_CONTEXT = $700B; {$EXTERNALSYM SO_UPDATE_ACCEPT_CONTEXT}
  SO_CONNECT_TIME = $700C; {$EXTERNALSYM SO_CONNECT_TIME}
  SO_UPDATE_CONNECT_CONTEXT = $7010; {$EXTERNALSYM SO_UPDATE_CONNECT_CONTEXT}

const
  TCP_BSDURGENT = $7000; {$EXTERNALSYM TCP_BSDURGENT}
  SIO_UDP_CONNRESET = IOC_IN or IOC_VENDOR or 12;

function WSARecvEx(s: TSocketId; buf: PAnsiChar; len: Integer; var flags: Integer): Integer; stdcall;

type
  _TRANSMIT_FILE_BUFFERS = record
    Head: Pointer;
    HeadLength: DWORD;
    Tail: Pointer;
    TailLength: DWORD;
  end;
  TRANSMIT_FILE_BUFFERS = _TRANSMIT_FILE_BUFFERS;
  PTRANSMIT_FILE_BUFFERS = ^TRANSMIT_FILE_BUFFERS;
  LPTRANSMIT_FILE_BUFFERS = ^TRANSMIT_FILE_BUFFERS;
  TTransmitFileBuffers = TRANSMIT_FILE_BUFFERS;
  PTransmitFileBuffers = LPTRANSMIT_FILE_BUFFERS;

const
  TF_DISCONNECT = $01; {$EXTERNALSYM TF_DISCONNECT}
  TF_REUSE_SOCKET = $02; {$EXTERNALSYM TF_REUSE_SOCKET}
  TF_WRITE_BEHIND = $04; {$EXTERNALSYM TF_WRITE_BEHIND}
  TF_USE_DEFAULT_WORKER = $00; {$EXTERNALSYM TF_USE_DEFAULT_WORKER}
  TF_USE_SYSTEM_THREAD = $10; {$EXTERNALSYM TF_USE_SYSTEM_THREAD}
  TF_USE_KERNEL_APC = $20; {$EXTERNALSYM TF_USE_KERNEL_APC}

(*
function TransmitFile(hSocket: TSocketId; hFile: THandle; nNumberOfBytesToWrite,
  nNumberOfBytesPerSend: DWORD; lpOverlapped: POVERLAPPED;
  lpTransmitBuffers: LPTRANSMIT_FILE_BUFFERS; dwReserved: DWORD): BOOL; stdcall;
function AcceptEx(sListenSocket, sAcceptSocket: TSocketId; lpOutputBuffer:
  Pointer;
  dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD;
  var lpdwBytesReceived: DWORD; lpOverlapped: POVERLAPPED): BOOL; stdcall;
procedure GetAcceptExSockaddrs(lpOutputBuffer: Pointer; dwReceiveDataLength,
  dwLocalAddressLength, dwRemoteAddressLength: DWORD; var LocalSockaddr: LPSOCKADDR;
  var LocalSockaddrLength: Integer; var RemoteSockaddr: LPSOCKADDR;
  var RemoteSockaddrLength: Integer); stdcall;
*)

type
  LPFN_TRANSMITFILE = function(hSocket: TSocketId; hFile: THandle;
    nNumberOfBytesToWrite,
    nNumberOfBytesPerSend: DWORD; lpOverlapped: POVERLAPPED;
    lpTransmitBuffers: LPTRANSMIT_FILE_BUFFERS; dwReserved: DWORD): BOOL; stdcall;
  TFnTransmitFile = LPFN_TRANSMITFILE;

const
  WSAID_TRANSMITFILE: TGUID = (
    D1: $B5367DF0; D2: $CBAC; D3: $11CF; D4: ($95, $CA, $00, $80, $5F, $48, $A1, $92));

type
  LPFN_ACCEPTEX = function(sListenSocket, sAcceptSocket: TSocketId;
    lpOutputBuffer: Pointer;
    dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD;
    lpdwBytesReceived: PCardinal; lpOverlapped: POVERLAPPED): BOOL; stdcall;
  TFnAcceptEx = LPFN_ACCEPTEX;

const
  WSAID_ACCEPTEX: TGUID = (
    D1: $B5367DF1; D2: $CBAC; D3: $11CF; D4: ($95, $CA, $00, $80, $5F, $48, $A1, $92));

type
  LPFN_GETACCEPTEXSOCKADDRS = procedure(lpOutputBuffer: Pointer;
    dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD; 
    var LocalSockaddr: LPSOCKADDR;
    var LocalSockaddrLength: Integer; var RemoteSockaddr: LPSOCKADDR;
    var RemoteSockaddrLength: Integer); stdcall;
  TFnGetAcceptExSockAddrs = LPFN_GETACCEPTEXSOCKADDRS;

const
  WSAID_GETACCEPTEXSOCKADDRS: TGUID = (
    D1: $B5367DF2; D2: $CBAC; D3: $11CF; D4: ($95, $CA, $00, $80, $5F, $48, $A1, $92));
    
  TP_ELEMENT_MEMORY = 1; {$EXTERNALSYM TP_ELEMENT_MEMORY}
  TP_ELEMENT_FILE = 2; {$EXTERNALSYM TP_ELEMENT_FILE}
  TP_ELEMENT_EOP = 4; {$EXTERNALSYM TP_ELEMENT_EOP}

type
  _TRANSMIT_PACKETS_ELEMENT = record
    dwElFlags: ULONG;
    cLength: ULONG;
    case Integer of
      0: (
        nFileOffset: LARGE_INTEGER;
        hFile: THandle);
      1: (
        pBuffer: Pointer);
  end;

  TRANSMIT_PACKETS_ELEMENT = _TRANSMIT_PACKETS_ELEMENT;
  PTRANSMIT_PACKETS_ELEMENT = ^TRANSMIT_PACKETS_ELEMENT;
  LPTRANSMIT_PACKETS_ELEMENT = ^TRANSMIT_PACKETS_ELEMENT;
  TTransmitPacketElement = TRANSMIT_PACKETS_ELEMENT;
  PTransmitPacketElement = PTRANSMIT_PACKETS_ELEMENT;

const
  TP_DISCONNECT = TF_DISCONNECT;
  TP_REUSE_SOCKET = TF_REUSE_SOCKET;
  TP_USE_DEFAULT_WORKER = TF_USE_DEFAULT_WORKER;
  TP_USE_SYSTEM_THREAD = TF_USE_SYSTEM_THREAD;
  TP_USE_KERNEL_APC = TF_USE_KERNEL_APC;

type
  LPFN_TRANSMITPACKETS = function(Socket: TSocketId; lpPacketArray:
    LPTRANSMIT_PACKETS_ELEMENT; ElementCount: DWORD;
    nSendSize: DWORD; lpOverlapped: POVERLAPPED; dwFlags: DWORD): BOOL; stdcall;
    
const
  WSAID_TRANSMITPACKETS: TGUID = (
    D1: $D9689DA0; D2: $1F90; D3: $11D3; D4: ($99, $71, $00, $C0, $4F, $68, $C8, $76));
type
  LPFN_CONNECTEX = function(s: TSocketId; const name: SockAddr; namelen: Integer;
    lpSendBuffer: Pointer; dwSendDataLength: DWORD;
    var lpdwBytesSent: DWORD; lpOverlapped: POVERLAPPED): BOOL; stdcall;

const
  WSAID_CONNECTEX: TGUID = (
    D1: $25A207B9; D2: $DDF3; D3: $4660; D4: ($8E, $E9, $76, $E5, $8C, $74, $06, $3E));
type
  LPFN_DISCONNECTEX = function(s: TSocketId; lpOverlapped: POVERLAPPED; dwFlags:
    DWORD; dwReserved: DWORD): BOOL; stdcall;
    
const
  WSAID_DISCONNECTEX: TGUID = (
    D1: $7FDA2E11; D2: $8630; D3: $436F; D4: ($A0, $31, $F5, $36, $A6, $EE, $C1, $57));
  DE_REUSE_SOCKET = TF_REUSE_SOCKET;
  NLA_NAMESPACE_GUID: TGUID = (
    D1: $6642243A; D2: $3BA8; D3: $4AA6; D4: ($BA, $A5, $2E, $0B, $D7, $1F, $DD, $83));
  NLA_SERVICE_CLASS_GUID: TGUID = (
    D1: $37E515; D2: $B5C9; D3: $4A43; D4: ($BA, $DA, $8B, $48, $A8, $7A, $D2, $39));

  NLA_ALLUSERS_NETWORK = $00000001; {$EXTERNALSYM NLA_ALLUSERS_NETWORK}
  NLA_FRIENDLY_NAME = $00000002; {$EXTERNALSYM NLA_FRIENDLY_NAME}

type
  _NLA_BLOB_DATA_TYPE = (
    NLA_RAW_DATA,
    NLA_INTERFACE,
    NLA_802_1X_LOCATION,
    NLA_CONNECTIVITY,
    NLA_ICS);

  NLA_BLOB_DATA_TYPE = _NLA_BLOB_DATA_TYPE;
  PNLA_BLOB_DATA_TYPE = ^NLA_BLOB_DATA_TYPE;
  TNlaBlobDataType = NLA_BLOB_DATA_TYPE;
  PNlaBlobDataType = PNLA_BLOB_DATA_TYPE;

  _NLA_CONNECTIVITY_TYPE = (
    NLA_NETWORK_AD_HOC,
    NLA_NETWORK_MANAGED,
    NLA_NETWORK_UNMANAGED,
    NLA_NETWORK_UNKNOWN);
  NLA_CONNECTIVITY_TYPE = _NLA_CONNECTIVITY_TYPE;
  PNLA_CONNECTIVITY_TYPE = ^NLA_CONNECTIVITY_TYPE;
  TNlaConnectivityType = NLA_CONNECTIVITY_TYPE;
  PNlaConnectivityType = PNLA_CONNECTIVITY_TYPE;
  
  _NLA_INTERNET = (
    NLA_INTERNET_UNKNOWN,
    NLA_INTERNET_NO,
    NLA_INTERNET_YES);
  NLA_INTERNET = _NLA_INTERNET;
  PNLA_INTERNET = ^NLA_INTERNET;
  TNlaInternet = NLA_INTERNET;
  PNlaInternet = PNLA_INTERNET;

  _NLA_BLOB = record
    header: record
      type_: NLA_BLOB_DATA_TYPE;
      dwSize: DWORD;
      nextOffset: DWORD;
    end;
    case Integer of
      0: (
        // header.type = NLA_RAW_DATA
        rawData: array[0..0] of AnsiChar);
      1: (
        // header.type = NLA_INTERFACE
        dwType: DWORD;
        dwSpeed: DWORD;
        adapterName: array[0..0] of AnsiChar);
      2: (
        // header.type = NLA_802_1X_LOCATION
        information: array[0..0] of AnsiChar);
      3: (
        type_: NLA_CONNECTIVITY_TYPE;
        internet: NLA_INTERNET);
      4: (
        remote: record
          speed: DWORD;
          type_: DWORD;
          state: DWORD;
          machineName: array[0..255] of WCHAR;
          sharedAdapterName: array[0..255] of WCHAR;
        end);
  end;

  NLA_BLOB = _NLA_BLOB;
  PNLA_BLOB = ^NLA_BLOB;
  LPNLA_BLOB = ^NLA_BLOB;
  TNlaBlob = NLA_BLOB;
  PNlaBlob = PNLA_BLOB;

  _WSAMSG = record
    name: LPSOCKADDR; 
    namelen: Integer; 
    lpBuffers: PWsaBuf;
    dwBufferCount: DWORD; 
    Control: TWsaBuf;
    dwFlags: DWORD;
  end;

  WSAMSG = _WSAMSG;
  PWSAMSG = ^WSAMSG;
  LPWSAMSG = ^WSAMSG;
  TWsaMsg = WSAMSG;

  _WSACMSGHDR = record
    cmsg_len: DWORD;
    cmsg_level: Integer;
    cmsg_type: Integer;
    // followed by UCHAR cmsg_data[]
  end;

  WSACMSGHDR = _WSACMSGHDR;
  PWSACMSGHDR = ^WSACMSGHDR;
  LPWSACMSGHDR = ^WSACMSGHDR;
  TWsaCMsgHdr = WSACMSGHDR;

const
  MSG_TRUNC = $0100; {$EXTERNALSYM MSG_TRUNC}
  MSG_CTRUNC = $0200; {$EXTERNALSYM MSG_CTRUNC}
  MSG_BCAST = $0400; {$EXTERNALSYM MSG_BCAST}
  MSG_MCAST = $0800; {$EXTERNALSYM MSG_MCAST}

type
  LPFN_WSARECVMSG = function(s: TSocketId; lpMsg: LPWSAMSG;
    lpdwNumberOfBytesRecvd: LPDWORD; lpOverlapped:  PWsaOverlapped;
    lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE): Integer; stdcall;
    
const
  WSAID_WSARECVMSG: TGUID = (
    D1: $F689D7C8; D2: $6F1F; D3: $436B; D4: ($8A, $53, $E5, $4F, $E3, $51, $C3, $22));
      
implementation

const
  mswsocklib = 'mswsock.dll';

function WSARecvEx; external mswsocklib name 'WSARecvEx';
(*
function TransmitFile; external mswsocklib name 'TransmitFile';
function AcceptEx; external mswsocklib name 'AcceptEx';
procedure GetAcceptExSockaddrs; external mswsocklib name 'GetAcceptExSockaddrs';
*)

end.

