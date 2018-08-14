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

unit MSTcpIP;

interface

uses
  dslWinsock2;

type
  tcp_keepalive = record
    onoff: UInt32;
    keepalivetime: UInt32;
    keepaliveinterval: UInt32;
  end;
  TTCPKeepAlive = tcp_keepalive;
  PTCPKeepAlive = ^TTCPKeepAlive;

const
  SIO_RCVALL = IOC_IN or IOC_VENDOR or 1;
  SIO_RCVALL_MCAST = IOC_IN or IOC_VENDOR or 2;
  SIO_RCVALL_IGMPMCAST = IOC_IN or IOC_VENDOR or 3;
  SIO_KEEPALIVE_VALS = IOC_IN or IOC_VENDOR or 4;
  SIO_ABSORB_RTRALERT = IOC_IN or IOC_VENDOR or 5;
  SIO_UCAST_IF = IOC_IN or IOC_VENDOR or 6;
  SIO_LIMIT_BROADCASTS = IOC_IN or IOC_VENDOR or 7;
  SIO_INDEX_BIND = IOC_IN or IOC_VENDOR or 8;
  SIO_INDEX_MCASTIF = IOC_IN or IOC_VENDOR or 9;
  SIO_INDEX_ADD_MCAST = IOC_IN or IOC_VENDOR or 10;
  SIO_INDEX_DEL_MCAST = IOC_IN or IOC_VENDOR or 11;
  
  RCVALL_OFF = 0;
  RCVALL_ON = 1;
  RCVALL_SOCKETLEVELONLY = 2;

implementation

end.
