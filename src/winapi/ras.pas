unit ras;

interface

uses
  SysUtils, Classes, Windows;

const
  RASBASE = 600;
  ERROR_BUFFER_TOO_SMALL = RASBASE + 3;

const
  UNLEN = 256;
  PWLEN = 256;
  DNLEN = 15;
  NETBIOS_NAME_LEN   = 16;
  RAS_MaxEntryName    =  256;
  RAS_MaxDeviceName   =  128;
  RAS_MaxDeviceType  =  16;
  RAS_MaxParamKey  =  32;
  RAS_MaxParamValue  = 128;
  RAS_MaxPhoneNumber  = 128;
  RAS_MaxCallbackNumber =  RAS_MaxPhoneNumber;
  RAS_MaxIpAddress  = 15;
  RAS_MaxIpxAddress  = 21;
  RAS_MaxAreaCode  = 10;
  RAS_MaxPadType  = 32;
  RAS_MaxX25Address  = 200;
  RAS_MaxFacilities  = 200;
  RAS_MaxUserData  = 200;

type
  _RASENTRYNAME = record
    dwSize: DWORD;
    szEntryName: array [0..RAS_MaxEntryName] of Char;
    dwFlags: DWORD;
    szPhonebookPath: array [0..MAX_PATH] of Char;
  end;

  RASENTRYNAME = _RASENTRYNAME;
  TRasEntryName = _RASENTRYNAME;
  LPRASENTRYNAME = ^_RASENTRYNAME;
  PRasEntryName = ^_RASENTRYNAME;

  _RASDIALPARAMS = record
    dwSize: DWORD;
    szEntryName: array [0..RAS_MaxEntryName] of Char;
    szPhoneNumber: array [0..RAS_MaxPhoneNumber] of Char;
    szCallbackNumber: array [0..RAS_MaxCallbackNumber] of Char;
    szUserName: array [0..UNLEN] of Char;
    szPassword: array [0..PWLEN] of Char;
    szDomain: array [0..DNLEN] of Char;
    dwSubEntry: DWORD;
    dwCallbackId: ULONG_PTR;
    dwIfIndex: DWORD;
  end;
  RASDIALPARAMS = _RASDIALPARAMS;
  LPRASDIALPARAMS = ^_RASDIALPARAMS;

  TRasDialParams = _RASDIALPARAMS;

  tagRASEAPINFO = record
    dwSizeofEapInfo: DWORD;
    pbEapInfo: PByte;
  end;
  RASEAPINFO = tagRASEAPINFO;

  _RASDEVSPECIFICINFO = record
    dwSize: DWORD;
    pbDevSpecificInfo: PByte;
  end;
  RASDEVSPECIFICINFO = _RASDEVSPECIFICINFO;
  PRASDEVSPECIFICINFO = ^_RASDEVSPECIFICINFO;

  _RADIALEXTENSIONS = record
    dwSize: DWORD;
    dwfOptions: DWORD;
    hwndParent: HWND;
    reserved: ULONG_PTR;
    reserved1: ULONG_PTR;
    EapInfo: RASEAPINFO;
    fSkipPppAuth: BOOL;
    DevSpecificInfo: RASDEVSPECIFICINFO;
  end;
  RASDIALEXTENSIONS = _RADIALEXTENSIONS;
  LPRASDIALEXTENSIONS = ^_RADIALEXTENSIONS;

//
// Locally Unique Identifier
//
  PLUID = ^TLUID;
  {$EXTERNALSYM PLUID}
  _LUID = record
    LowPart: DWORD;
    HighPart: DWORD;
  end;
  {$EXTERNALSYM _LUID}
  TLUID = _LUID;
  LUID = _LUID;
  {$EXTERNALSYM LUID}
  
  HRASCONN = Pointer;

  _RASCONN = record
    dwSize: DWORD;
    connection: HRASCONN;
    szEntryName: array [0..RAS_MaxEntryName] of Char;
    szDeviceType: array [0..RAS_MaxDeviceType] of Char;
    szDeviceName: array [0..RAS_MaxDeviceName] of Char;
    szPhonebook: array [0..MAX_PATH-1] of Char;
    dwSubEntry: DWORD;
    guidEntry: TGUID;
    dwFlags: DWORD;
    luid: TLUID;
    guidCorrelationId: TGUID;
  end;
  RASCONN = _RASCONN;
  LPRASCONN = ^_RASCONN;

function RasGetErrorString(uErrorValue: UINT; lpszErrorString: PChar; cBufSize: DWORD): DWORD; stdcall;
function RasEnumEntries(reserved, lpszPhonebook: PChar; pEntryName: LPRASENTRYNAME; lpcb, lpcEntries: LPDWORD): DWORD; stdcall;
function RasGetEntryDialParams(lpszPhonebook: PWideChar; params: LPRASDIALPARAMS; lpfPassword: PBOOL): DWORD; stdcall;

function RasDial(pExtensions: LPRASDIALEXTENSIONS; pszPhonebook: PChar; pDialParams: LPRASDIALPARAMS;
  dwNotifierType: DWORD; lpvNotifier: Pointer; var pRasConn: HRASCONN): DWORD; stdcall;

function RasHangUp(conection: HRASCONN): DWORD; stdcall;

function RasEnumConnections(pConnection: LPRASCONN; lpcb: PDWORD; lpcConnections: LPDWORD): DWORD; stdcall;

function RasDialWith(const EntryName: string): Boolean;
function GetRasEntries(names: TStrings): Boolean;
function GetRasConnections(names: TStrings): Boolean;
function GetRasConnectionHandle(const EntryName: string): HRASCONN;

implementation

function RasGetErrorString; external 'Rasapi32.dll' name 'RasGetErrorStringW';
function RasEnumEntries; external 'Rasapi32.dll' name 'RasEnumEntriesW';
function RasGetEntryDialParams; external 'Rasapi32.dll' name 'RasGetEntryDialParamsW';
function RasDial; external 'Rasapi32.dll' name 'RasDialW';
function RasHangUp; external 'Rasapi32.dll' name 'RasHangUpW';
function RasEnumConnections; external 'Rasapi32.dll' name 'RasEnumConnectionsW';

function GetRasEntries(names: TStrings): Boolean;
var
  i, dwCb, dwRet, dwEntries: DWORD;
  pEntryName, tmp: LPRASENTRYNAME;
begin
  Result := False;
  dwCb := 0;
  dwEntries := 0;
  pEntryName := nil;

  dwRet := RasEnumEntries(nil, nil, pEntryName, @dwCb, @dwEntries);

  if dwRet <> ERROR_BUFFER_TOO_SMALL then Exit;

  pEntryName := LPRASENTRYNAME(System.GetMemory(dwCb));

  try
    pEntryName.dwSize := SizeOf(RASENTRYNAME);
    dwRet := RasEnumEntries(nil, nil, pEntryName, @dwCb, @dwEntries);

    if dwRet = ERROR_SUCCESS then
    begin
      tmp := pEntryName;

      for i := 0 to dwEntries - 1 do
      begin
        names.Add(StrPas(tmp.szEntryName));
        Inc(tmp);
      end;
    end;
  finally
    System.FreeMemory(pEntryName);
  end;
end;

function GetRasConnections(names: TStrings): Boolean;
var
  i, dwCb, dwRet, dwConns: DWORD;
  pConnection, tmp: LPRASCONN;
begin
  Result := False;
  dwCb := 0;
  dwConns := 0;
  pConnection := nil;

  dwRet := RasEnumConnections(pConnection, @dwCb, @dwConns);

  if dwRet <> ERROR_BUFFER_TOO_SMALL then Exit;

  pConnection := LPRASCONN(System.GetMemory(dwCb));

  try
    pConnection.dwSize := SizeOf(RASCONN);
    dwRet := RasEnumConnections(pConnection, @dwCb, @dwConns);

    if dwRet = ERROR_SUCCESS then
    begin
      tmp := pConnection;

      for i := 0 to dwConns - 1 do
      begin
        names.Add(StrPas(tmp.szEntryName));
        Inc(tmp);
      end;
    end;
  finally
    System.FreeMemory(pConnection);
  end;
end;

function GetRasConnectionHandle(const EntryName: string): HRASCONN;
var
  i, dwCb, dwRet, dwConns: DWORD;
  pConnection, tmp: LPRASCONN;
  curname: string;
begin
  Result := nil;
  dwCb := 0;
  dwConns := 0;
  pConnection := nil;

  dwRet := RasEnumConnections(pConnection, @dwCb, @dwConns);

  if dwRet <> ERROR_BUFFER_TOO_SMALL then Exit;

  pConnection := LPRASCONN(System.GetMemory(dwCb));

  try
    pConnection.dwSize := SizeOf(RASCONN);
    dwRet := RasEnumConnections(pConnection, @dwCb, @dwConns);

    if dwRet = ERROR_SUCCESS then
    begin
      tmp := pConnection;

      for i := 0 to dwConns - 1 do
      begin
        curname := tmp.szEntryName;

        if SameText(curname, EntryName) then
        begin
          Result := tmp.connection;
          Break;
        end;

        Inc(tmp);
      end;
    end;
  finally
    System.FreeMemory(pConnection);
  end;
end;

function RasDialWith(const EntryName: string): Boolean;
var
  params: TRasDialParams;
  pfPassword: BOOL;
  code: DWORD;
  conn: HRASCONN;
begin
  Result := False;
  FillChar(params, SizeOf(params), 0);
  params.dwSize := SizeOf(params);
  StrPLCopy(params.szEntryName, EntryName, Length(params.szEntryName));

  pfPassword := True;

  code := RasGetEntryDialParams(nil, @params, @pfPassword);

  if code <> ERROR_SUCCESS then Exit;

  conn := nil;

  Result := RasDial(nil, nil, @params, 0, nil, conn) = ERROR_SUCCESS;
end;

end.
