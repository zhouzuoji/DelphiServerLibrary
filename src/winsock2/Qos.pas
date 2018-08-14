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

unit Qos;

interface

uses
  Windows;

type
  ULONG = Cardinal;
  SERVICETYPE = ULONG;
  TServiceType = SERVICETYPE;
  PServiceType = ^TServiceType;

const
  SERVICETYPE_NOTRAFFIC = $00000000; {$EXTERNALSYM SERVICETYPE_NOTRAFFIC}
  SERVICETYPE_BESTEFFORT = $00000001; {$EXTERNALSYM SERVICETYPE_BESTEFFORT} 
  SERVICETYPE_CONTROLLEDLOAD = $00000002; {$EXTERNALSYM SERVICETYPE_CONTROLLEDLOAD} 
  SERVICETYPE_GUARANTEED = $00000003; {$EXTERNALSYM SERVICETYPE_GUARANTEED} 
  SERVICETYPE_NETWORK_UNAVAILABLE = $00000004; {$EXTERNALSYM SERVICETYPE_NETWORK_UNAVAILABLE}
  SERVICETYPE_GENERAL_INFORMATION = $00000005; {$EXTERNALSYM SERVICETYPE_GENERAL_INFORMATION}
  SERVICETYPE_NOCHANGE = $00000006; {$EXTERNALSYM SERVICETYPE_NOCHANGE}
  SERVICETYPE_NONCONFORMING = $00000009; {$EXTERNALSYM SERVICETYPE_NONCONFORMING} 
  SERVICETYPE_NETWORK_CONTROL = $0000000A; {$EXTERNALSYM SERVICETYPE_NETWORK_CONTROL} 
  SERVICETYPE_QUALITATIVE = $0000000D; {$EXTERNALSYM SERVICETYPE_QUALITATIVE} 
  SERVICE_BESTEFFORT = DWORD($80010000);
  SERVICE_CONTROLLEDLOAD = DWORD($80020000);
  SERVICE_GUARANTEED = DWORD($80040000);
  SERVICE_QUALITATIVE = DWORD($80200000);
  SERVICE_NO_TRAFFIC_CONTROL = DWORD($81000000);
  SERVICE_NO_QOS_SIGNALING = $40000000; {$EXTERNALSYM SERVICE_NO_QOS_SIGNALING}

{$EXTERNALSYM SERVICETYPE_NOTRAFFIC}
(*$HPPEMIT '#define SERVICETYPE_NOTRAFFIC 0'*)

{$EXTERNALSYM SERVICETYPE_BESTEFFORT}
(*$HPPEMIT '#define SERVICETYPE_BESTEFFORT 1'*)

{$EXTERNALSYM SERVICETYPE_CONTROLLEDLOAD}
(*$HPPEMIT '#define SERVICETYPE_CONTROLLEDLOAD 2'*)

{$EXTERNALSYM SERVICETYPE_GUARANTEED}
(*$HPPEMIT '#define SERVICETYPE_GUARANTEED 3'*)

{$EXTERNALSYM SERVICETYPE_NETWORK_UNAVAILABLE}
(*$HPPEMIT '#define SERVICETYPE_NETWORK_UNAVAILABLE 4'*)

{$EXTERNALSYM SERVICETYPE_GENERAL_INFORMATION}
(*$HPPEMIT '#define SERVICETYPE_GENERAL_INFORMATION 5'*)

{$EXTERNALSYM SERVICETYPE_NOCHANGE}
(*$HPPEMIT '#define SERVICETYPE_NOCHANGE 6'*)

{$EXTERNALSYM SERVICETYPE_NONCONFORMING}
(*$HPPEMIT '#define SERVICETYPE_NONCONFORMING 9'*)

{$EXTERNALSYM SERVICETYPE_NETWORK_CONTROL}
(*$HPPEMIT '#define SERVICETYPE_NETWORK_CONTROL 10'*)

{$EXTERNALSYM SERVICETYPE_QUALITATIVE}
(*$HPPEMIT '#define SERVICETYPE_QUALITATIVE 0xD'*)

{$EXTERNALSYM SERVICE_BESTEFFORT}
(*$HPPEMIT '#define SERVICE_BESTEFFORT 0x80010000'*)

{$EXTERNALSYM SERVICE_CONTROLLEDLOAD}
(*$HPPEMIT '#define SERVICE_CONTROLLEDLOAD 0x80020000'*)

{$EXTERNALSYM SERVICE_GUARANTEED}
(*$HPPEMIT '#define SERVICE_GUARANTEED 0x80200000'*)

{$EXTERNALSYM SERVICE_QUALITATIVE}
(*$HPPEMIT '#define SERVICE_QUALITATIVE 0x80200000'*)

{$EXTERNALSYM SERVICE_NO_TRAFFIC_CONTROL}
(*$HPPEMIT '#define SERVICE_NO_TRAFFIC_CONTROL 0x81000000'*)

{$EXTERNALSYM SERVICE_NO_QOS_SIGNALING}
(*$HPPEMIT '#define SERVICE_NO_QOS_SIGNALING 0x40000000'*)

{$EXTERNALSYM QOS_NOT_SPECIFIED}
(*$HPPEMIT '#define QOS_NOT_SPECIFIED 0xffffffff'*)

{$EXTERNALSYM POSITIVE_INFINITY_RATE}
(*$HPPEMIT '#define POSITIVE_INFINITY_RATE 0xfffffffe'*)

{$EXTERNALSYM QOS_GENERAL_ID_BASE}
(*$HPPEMIT '#define QOS_GENERAL_ID_BASE 0x7d0'*)

{$EXTERNALSYM QOS_OBJECT_END_OF_LIST}
(*$HPPEMIT '#define QOS_OBJECT_END_OF_LIST 0x7d1'*)

{$EXTERNALSYM QOS_OBJECT_SD_MODE}
(*$HPPEMIT '#define QOS_OBJECT_SD_MODE 0x7d2'*)

{$EXTERNALSYM QOS_OBJECT_SHAPING_RATE}
(*$HPPEMIT '#define QOS_OBJECT_SHAPING_RATE 0x7d3'*)

{$EXTERNALSYM QOS_OBJECT_DESTADDR}
(*$HPPEMIT '#define QOS_OBJECT_DESTADDR 0x7d4'*)

{$EXTERNALSYM TC_NONCONF_BORROW}
(*$HPPEMIT '#define TC_NONCONF_BORROW 0'*)

{$EXTERNALSYM TC_NONCONF_SHAPE}
(*$HPPEMIT '#define TC_NONCONF_SHAPE 1'*)

{$EXTERNALSYM TC_NONCONF_DISCARD}
(*$HPPEMIT '#define TC_NONCONF_DISCARD 2'*)

{$EXTERNALSYM TC_NONCONF_BORROW_PLUS}
(*$HPPEMIT '#define TC_NONCONF_BORROW_PLUS 3'*)

type
  _flowspec = record
    TokenRate: ULONG; 
    TokenBucketSize: ULONG;
    PeakBandwidth: ULONG; 
    Latency: ULONG; 
    DelayVariation: ULONG; 
    ServiceType: SERVICETYPE;
    MaxSduSize: ULONG; 
    MinimumPolicedSize: ULONG; 
  end;

  FLOWSPEC = _flowspec;
  PFLOWSPEC = ^FLOWSPEC;
  LPFLOWSPEC = ^FLOWSPEC;
  TFlowSpec = FLOWSPEC;

const
  QOS_NOT_SPECIFIED = DWORD($FFFFFFFF);
  POSITIVE_INFINITY_RATE = DWORD($FFFFFFFE);

type
  QOS_OBJECT_HDR = record
    ObjectType: ULONG;
    ObjectLength: ULONG; 
  end;
  LPQOS_OBJECT_HDR = ^QOS_OBJECT_HDR;
  TQOSObjectHdr = QOS_OBJECT_HDR;
  PQOSObjectHdr = LPQOS_OBJECT_HDR;

const
  QOS_GENERAL_ID_BASE = 2000; {$EXTERNALSYM QOS_GENERAL_ID_BASE}
  QOS_OBJECT_END_OF_LIST = $00000001 + QOS_GENERAL_ID_BASE;
  QOS_OBJECT_SD_MODE = $00000002 + QOS_GENERAL_ID_BASE;
  QOS_OBJECT_SHAPING_RATE = $00000003 + QOS_GENERAL_ID_BASE;
  QOS_OBJECT_DESTADDR = $00000004 + QOS_GENERAL_ID_BASE;

type
  _QOS_SD_MODE = record
    ObjectHdr: QOS_OBJECT_HDR;
    ShapeDiscardMode: ULONG;
  end;
  QOS_SD_MODE = _QOS_SD_MODE;
  LPQOS_SD_MODE = ^QOS_SD_MODE;
  TQOSSDMode = QOS_SD_MODE;
  PQOSSDMode = LPQOS_SD_MODE;

const
  TC_NONCONF_BORROW = 0; {$EXTERNALSYM TC_NONCONF_BORROW}
  TC_NONCONF_SHAPE = 1; {$EXTERNALSYM TC_NONCONF_SHAPE}
  TC_NONCONF_DISCARD = 2; {$EXTERNALSYM TC_NONCONF_DISCARD}
  TC_NONCONF_BORROW_PLUS = 3; {$EXTERNALSYM TC_NONCONF_BORROW_PLUS} 
  
type
  _QOS_SHAPING_RATE = record
    ObjectHdr: QOS_OBJECT_HDR;
    ShapingRate: ULONG;
  end;
  QOS_SHAPING_RATE = _QOS_SHAPING_RATE;
  LPQOS_SHAPING_RATE = ^QOS_SHAPING_RATE;
  TQOSShapingRate = QOS_SHAPING_RATE;
  PQOSShapingRate = LPQOS_SHAPING_RATE;

implementation

end.







