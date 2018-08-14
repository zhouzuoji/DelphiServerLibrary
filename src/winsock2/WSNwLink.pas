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

unit WSNwLink;

interface

uses
  dslWinsock2, Windows;

const
  IPX_PTYPE = $4000;
  IPX_FILTERPTYPE = $4001;
  IPX_STOPFILTERPTYPE = $4003;
  IPX_DSTYPE = $4002;
  IPX_EXTENDED_ADDRESS = $4004;
  IPX_RECVHDR = $4005;
  IPX_MAXSIZE = $4006;
  IPX_ADDRESS = $4007;
  
type
  _IPX_ADDRESS_DATA = record
    adapternum: Integer; 
    netnum: array[0..3] of UCHAR; 
    nodenum: array[0..5] of UCHAR;
    wan: Boolean; 
    status: Boolean; 
    maxpkt: Integer; 
    linkspeed: ULONG;
  end;
  IPX_ADDRESS_DATA = _IPX_ADDRESS_DATA;
  PIPX_ADDRESS_DATA = ^IPX_ADDRESS_DATA;
  TIpxAddressData = IPX_ADDRESS_DATA;
  PIpxAddressData = PIPX_ADDRESS_DATA;

const
  IPX_GETNETINFO = $4008;

type
  _IPX_NETNUM_DATA = record
    netnum: array[0..3] of UCHAR;
    hopcount: Word; 
    netdelay: Word; 
    cardnum: Integer;
    router: array[0..5] of UCHAR;
  end;
  IPX_NETNUM_DATA = _IPX_NETNUM_DATA;
  PIPX_NETNUM_DATA = ^IPX_NETNUM_DATA;
  TIpxNetNumData = IPX_NETNUM_DATA;
  PIpxNetNumData = PIPX_NETNUM_DATA;

const
  IPX_GETNETINFO_NORIP = $4009;
  IPX_SPXGETCONNECTIONSTATUS = $400B;
  
type
  _IPX_SPXCONNSTATUS_DATA = record
    ConnectionState: UCHAR;
    WatchDogActive: UCHAR;
    LocalConnectionId: Word;
    RemoteConnectionId: Word;
    LocalSequenceNumber: Word;
    LocalAckNumber: Word;
    LocalAllocNumber: Word;
    RemoteAckNumber: Word;
    RemoteAllocNumber: Word;
    LocalSocket: Word;
    ImmediateAddress: array[0..5] of UCHAR;
    RemoteNetwork: array[0..3] of UCHAR;
    RemoteNode: array[0..5] of UCHAR;
    RemoteSocket: Word;
    RetransmissionCount: Word;
    EstimatedRoundTripDelay: Word;
    RetransmittedPackets: Word;
    SuppressedPacket: Word;
  end;
  IPX_SPXCONNSTATUS_DATA = _IPX_SPXCONNSTATUS_DATA;
  PIPX_SPXCONNSTATUS_DATA = ^IPX_SPXCONNSTATUS_DATA;
  TIpxSpcConnStatusData = IPX_SPXCONNSTATUS_DATA;
  PIpxSpcConnStatusData = PIPX_SPXCONNSTATUS_DATA;

const
  IPX_ADDRESS_NOTIFY = $400C;
  IPX_MAX_ADAPTER_NUM = $400D;
  IPX_RERIPNETNUMBER = $400E;
  IPX_RECEIVE_BROADCAST = $400F;
  IPX_IMMEDIATESPXACK = $4010;
  
implementation

end.

