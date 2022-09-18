unit DSLApp;

interface

uses
  SysUtils,
  Classes,
  IniFiles,
  Registry,
  ActiveX,
  Windows,
  WinSvc,
  DSLUtils,
  DSLProcess,
  DSLThread;

type
  TNTSvcCtrlHandler = function: Boolean;
  TNTSvcCtrlCmdHandlers = record
    onRun: TNTSvcCtrlHandler;
    onPause: TNTSvcCtrlHandler;
    onResume: TNTSvcCtrlHandler;
    onStop: TProcedure;
    onShutdown: TProcedure;
    onIdle: TProcedure;
  end;

type
  TAppInfo = class
  private
    FAppId, FName: string;
    FDisplayName: string;
    FDataPath: string;
    FIniFileName: string;
    FRegistryEntry: string;
    procedure DoBuild;
  public
    function Id(const _Id: string): TAppInfo;
    function Name(const _Name: string): TAppInfo;
    function DisplayName(const _DisplayName: string): TAppInfo;
    function DataPath(const _DataPath: string): TAppInfo;
    function IniFileName(const _IniFileName: string): TAppInfo;
    function RegistryEntry(const _RegistryEntry: string): TAppInfo;
    procedure Build;
  end;

function cmdLineParamExists(const param: string): Boolean;
function runningAsService: Boolean;
function GetAppVerInfo: TFileVersionInfo;
function getAppExeFullName: string;
function getAppFileName: string;
function GetAppFileNameWithoutExt: string;
function getAppPath: string;
function getAppId: string;
function getAppName: string;
function getAppDisplayName: string;
function getAppStartTime: TDateTime;
function getAppDataPath: string;
function getAppUserPath: string;
function ResolvePath(const _Path: string): string;
function iniReadInteger(const section, name: string; def: Integer = 0): Integer;
function iniReadFloat(const section, name: string; def: Double = 0.0): Double;
function iniReadBool(const section, name: string; def: Boolean = False): Boolean;
function iniReadString(const section, name: string; const def: string = ''): string;
procedure iniWriteInteger(const section, name: string; value: Integer);
procedure iniWriteFloat(const section, name: string; value: Double);
procedure iniWriteBool(const section, name: string; value: Boolean);
procedure iniWriteString(const section, name, value: string);
function userIniReadInteger(const section, key: string; DefaultValue: Integer): Integer;
function userIniReadFloat(const section, key: string; DefaultValue: Double): Double;
procedure userIniWriteBool(const section, key: string; value: Boolean);
function userIniReadString(const section, key, DefaultValue: string): string;
procedure userIniWriteInteger(const section, key: string; value: Integer);
procedure userIniWriteFloat(const section, key: string; value: Double);
function userIniReadBool(const section, key: string; DefaultValue: Boolean): Boolean;
procedure userIniWriteString(const section, key, value: string);

procedure RegistrySetString(const key, value: string);
function RegistryGetString(const key: string; const def: string = ''): string;
procedure RegistrySetInteger(const key: string; value: Integer);
function RegistryGetInteger(const key: string; def: Integer = 0): Integer;
procedure RegistrySetBool(const key: string; value: Boolean);
function RegistryGetBool(const key: string; def: Boolean = False): Boolean;
procedure RegistrySetFloat(const key: string; value: Double);
function RegistryGetFloat(const key: string; def: Double = 0.0): Double;

procedure initUser(const username: string);
function getServiceMainThread: TTaskQueue;
procedure RunNTService(handlers: TNTSvcCtrlCmdHandlers);

procedure writeEventLog(const msg: string; EventType: TEventLogType = eltError;
  Category: Word = 0; ID: DWORD = 0);

procedure eventLogSysError(errorCode: Integer; const operation: string = '');
procedure eventLogException(e: Exception; const operation: string ='');
procedure setSerivceStatus(newStatus: TServiceRunningStatus);
procedure ExecOnAppStart(_Proc: TProc);
procedure ExecOnUserLogin(_Proc: TProc);

var
  g_Terminating: Boolean;

implementation

uses
  Generics.Collections;

var
  g_appVerInfo: TFileVersionInfo;
  g_RunningAsService: Boolean;
  g_appPath: string;
  g_appImagePath: string;
  g_appFileName: string;
  g_appFileNameWithoutExt: string;
  g_appId: string;
  g_appName: string;
  g_appDisplayName: string;
  g_StartTime: TDateTime;
  g_appDataDir: string;
  g_appUserPath: string;
  g_appIni: TIniFile;
  g_userIni: TIniFile;
  G_appRegRoot: TRegistry;
  g_eventLogHandle: THandle;
  g_svcStatus: TServiceRunningStatus;
  g_svcStatusHandle: SERVICE_STATUS_HANDLE;
  g_svcHandlers: TNTSvcCtrlCmdHandlers;
  g_startType: TNTServiceStartType = sstAuto;
  g_serviceType: TNTServiceType = stWin32;
  g_errorSeverity: TErrorSeverity = esNormal;
  g_svcMainThread: TTaskQueue;

  g_AppInitProcs, g_UserLoginCallbacks: TList<TProc>;

procedure ExecOnAppStart(_Proc: TProc);
begin
  g_AppInitProcs.Add(_Proc);
end;

procedure ExecOnUserLogin(_Proc: TProc);
begin
  g_UserLoginCallbacks.Add(_Proc);
end;

function getServiceMainThread: TTaskQueue;
begin
  Result := g_svcMainThread;
end;

function cmdLineParamExists(const param: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to ParamCount do
  begin
    if SameText(ParamStr(i), param) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function runningAsService: Boolean;
begin
  Result := g_RunningAsService;
end;

function getAppId: string;
begin
  Result := g_appId;
end;

function getAppName: string;
begin
  Result := g_appName;
end;

function getAppDisplayName: string;
begin
  Result := g_appDisplayName;
end;

function getAppExeFullName: string;
begin
  Result := g_appImagePath;
end;

function getAppPath: string;
begin
  Result := g_appPath;
end;

function getAppFileName: string;
begin
  Result := g_appFileName;
end;

function GetAppFileNameWithoutExt: string;
begin
  Result := g_appFileNameWithoutExt;
end;

function GetAppVerInfo: TFileVersionInfo;
begin
  Result := g_appVerInfo;
end;

function getAppDataPath: string;
begin
  Result := g_appDataDir;
end;

function getAppUserPath: string;
begin
  Result := g_appUserPath;
end;

var
  G_LocalAppDataLocal, G_AppDataRoaming, G_CommonAppData: string;

function ResolvePath(const _Path: string): string;
begin
  Result := StringReplace(_Path, '/', '\', [rfIgnoreCase, rfReplaceAll]);
  Result := StringReplace(Result, '{app_data_local}', G_LocalAppDataLocal, [rfIgnoreCase, rfReplaceAll]);
  Result := StringReplace(Result, '{app_data_roaming}', G_AppDataRoaming, [rfIgnoreCase, rfReplaceAll]);
  Result := StringReplace(Result, '{common_app_data}', G_CommonAppData, [rfIgnoreCase, rfReplaceAll]);
  Result := StringReplace(Result, '{app_id}', g_appId, [rfIgnoreCase, rfReplaceAll]);
  if Pos(':', Result) <= 0 then
    Result := PathJoin(g_appPath, Result);
end;

function getAppStartTime: TDateTime;
begin
  Result := g_StartTime;
end;

function iniReadInteger(const section, name: string; def: Integer): Integer;
begin
  Result := g_appIni.ReadInteger(section, name, def);
end;

function iniReadFloat(const section, name: string; def: Double): Double;
begin
  Result := g_appIni.ReadFloat(section, name, def);
end;

function iniReadBool(const section, name: string; def: Boolean): Boolean;
begin
  Result := g_appIni.ReadBool(section, name, def);
end;

function iniReadString(const section, name: string; const def: string): string;
begin
  Result := g_appIni.ReadString(section, name, def);
end;

procedure iniWriteInteger(const section, name: string; value: Integer);
begin
  g_appIni.WriteInteger(section, name, value);
end;

procedure iniWriteFloat(const section, name: string; value: Double);
begin
  g_appIni.WriteFloat(section, name, value);
end;

procedure iniWriteBool(const section, name: string; value: Boolean);
begin
  g_appIni.WriteBool(section, name, value);
end;

procedure iniWriteString(const section, name, value: string);
begin
  g_appIni.WriteString(section, name, value);
end;

procedure initUser(const username: string);
var
  LProc: TProc;
begin
  g_appUserPath := PathJoin(g_appDataDir, 'users\' + username + '\');
  ForceDirectories(g_appUserPath);
  g_userIni := TIniFile.Create(g_appUserPath + 'config.ini');
  for LProc in g_UserLoginCallbacks do
    LProc();
end;

procedure userIniWriteString(const section, key, value: string);
begin
  g_userIni.WriteString(Section, key, value);
end;

function userIniReadString(const section, key, DefaultValue: string): string;
begin
  Result := g_userIni.ReadString(section, key, DefaultValue);
end;

procedure userIniWriteInteger(const section, key: string; value: Integer);
begin
  g_userIni.WriteInteger(section, key, value);
end;

function userIniReadInteger(const section, key: string; DefaultValue: Integer): Integer;
begin
  Result := g_userIni.ReadInteger(section, key, DefaultValue);
end;

procedure userIniWriteBool(const section, key: string; value: Boolean);
begin
  g_userIni.WriteBool(section, key, value);
end;

function userIniReadBool(const section, key: string; DefaultValue: Boolean): Boolean;
begin
  Result := g_userIni.ReadBool(section, key, DefaultValue);
end;

procedure userIniWriteFloat(const section, key: string; value: Double);
begin
  g_userIni.WriteFloat(section, key, value);
end;

function userIniReadFloat(const section, key: string; DefaultValue: Double): Double;
begin
  Result := g_userIni.ReadFloat(section, key, DefaultValue);
end;

procedure RegistrySetString(const key, value: string);
begin
  try
    G_appRegRoot.WriteString(key, value);
  except
    on e: Exception do ;
  end;
end;

function RegistryGetString(const key, def: string): string;
begin
  try
    Result := G_appRegRoot.ReadString(key);
  except
    on e: Exception do
    begin
      Result := def;
    end;
  end;
end;

procedure RegistrySetInteger(const key: string; value: Integer);
begin
  try
    G_appRegRoot.WriteInteger(key, value);
  except
    on e: Exception do ;
  end;
end;

function RegistryGetInteger(const key: string; def: Integer): Integer;
begin
  try
    Result := G_appRegRoot.ReadInteger(key);
  except
    on e: Exception do
    begin
      Result := def;
    end;
  end;
end;

procedure RegistrySetBool(const key: string; value: Boolean);
begin
  try
    G_appRegRoot.WriteBool(key, value);
  except
    on e: Exception do ;
  end;
end;

function RegistryGetBool(const key: string; def: Boolean): Boolean;
begin
  try
    Result := G_appRegRoot.ReadBool(key);
  except
    on e: Exception do
    begin
      Result := def;
    end;
  end;
end;

procedure RegistrySetFloat(const key: string; value: Double);
begin
  try
    G_appRegRoot.WriteFloat(key, value);
  except
    on e: Exception do ;
  end;
end;

function RegistryGetFloat(const key: string; def: Double): Double;
begin
  try
    Result := G_appRegRoot.ReadFloat(key);
  except
    on e: Exception do
    begin
      Result := def;
    end;
  end;
end;

type
  PPCharArray = ^TPCharArray;
  TPCharArray = array [0 .. 1024] of PChar;

procedure dumpServiceParam(argc: DWORD; argv: PLPSTR); inline;
var
  i: Integer;
begin
  DbgOutput('argc: ' + IntToStr(Argc));
  for i := 0 to argc - 1 do
    DbgOutput('argv[' + IntToStr(i) + ']: ' + PPCharArray(argv)[i]);
end;

function callHandler(handler: TNTSvcCtrlHandler): Boolean;
begin
  try
    Result := handler();
  except
    on e: Exception do
    begin
      eventLogException(e, 'ServiceControlHandler');
      Result := False;
    end;
  end;
end;

procedure beginService;
const
  ON_STOP_SIGNAL = WAIT_OBJECT_0;
  ON_PAUSE_SIGNAL = WAIT_OBJECT_0 + 1;
  ON_RESUME_SIGNAL = WAIT_OBJECT_0 + 2;
begin
  g_svcMainThread := TTaskQueue.Create;
  if Assigned(g_svcHandlers.onIdle) then
  begin
    g_svcMainThread.WaitingTimeout := 500;
    g_svcMainThread.OnIdle := g_svcHandlers.onIdle;
  end
  else
    g_svcMainThread.WaitingTimeout := INFINITE;

  if not callHandler(g_svcHandlers.onRun) then Exit;

  setSerivceStatus(srsRunning);
  g_svcMainThread.run;
end;

{$J+}
procedure reportServiceStatus;
const
  LastStatus: TServiceRunningStatus = srsStartPending;
  NTServiceStatus: array[TServiceRunningStatus] of Integer = (SERVICE_STOPPED,
    SERVICE_START_PENDING, SERVICE_STOP_PENDING, SERVICE_RUNNING,
    SERVICE_CONTINUE_PENDING, SERVICE_PAUSE_PENDING, SERVICE_PAUSED);
  PendingStatus: set of TServiceRunningStatus = [srsStartPending, srsStopPending,
    srsContinuePending, srsPausePending];
var
  ServiceStatus: TServiceStatus;
begin
  with ServiceStatus do
  begin
    dwWaitHint := 5000;
    dwServiceType := SERVICE_WIN32_OWN_PROCESS;
    dwControlsAccepted := 0;
    if g_svcStatus <> srsStartPending then
    begin
      dwControlsAccepted := SERVICE_ACCEPT_SHUTDOWN;

      if Assigned(g_svcHandlers.onPause) then
        dwControlsAccepted := dwControlsAccepted or SERVICE_ACCEPT_PAUSE_CONTINUE;

      if Assigned(g_svcHandlers.onStop) then
        dwControlsAccepted := dwControlsAccepted or SERVICE_ACCEPT_STOP;
    end;

    if (g_svcStatus in PendingStatus) and (g_svcStatus = LastStatus) then
      Inc(dwCheckPoint)
    else
      dwCheckPoint := 0;

    LastStatus := g_svcStatus;
    dwCurrentState := NTServiceStatus[g_svcStatus];
    dwWin32ExitCode := 0;
    dwServiceSpecificExitCode := 0;
    if dwServiceSpecificExitCode <> 0 then
      dwWin32ExitCode := ERROR_SERVICE_SPECIFIC_ERROR;
    if not SetServiceStatus(g_svcStatusHandle, ServiceStatus) then
      eventLogSysError(GetLastError);
  end;
end;
{$J-}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  case CtrlCode of
    SERVICE_CONTROL_STOP, SERVICE_CONTROL_SHUTDOWN:
      g_svcMainThread.queueProcAsFirst(
        procedure
        begin
          setSerivceStatus(srsStopPending);
          g_svcHandlers.onStop();
          g_svcMainThread.Terminate;
        end);
    SERVICE_CONTROL_PAUSE:
      g_svcMainThread.queueProcAsFirst(
        procedure
        begin
          setSerivceStatus(srsPausePending);
          if callHandler(g_svcHandlers.onPause) then
            setSerivceStatus(srsPaused)
          else begin
            g_svcHandlers.onStop();
            g_svcMainThread.Terminate;
          end;
        end);
    SERVICE_CONTROL_CONTINUE:
      g_svcMainThread.queueProcAsFirst(
        procedure
        begin
          setSerivceStatus(srsContinuePending);
          if callHandler(g_svcHandlers.onResume) then
            setSerivceStatus(srsRunning)
          else
            g_svcMainThread.Terminate;
        end);
    SERVICE_CONTROL_INTERROGATE:
      reportServiceStatus;
  end;
end;

procedure ServiceMain(argc: DWORD; argv: PLPSTR); stdcall;
begin
  g_RunningAsService := True;
  CoInitialize(nil);
  // dumpServiceParam(argc, argv);
  try
    g_svcStatusHandle := RegisterServiceCtrlHandler(PChar(g_appName), @ServiceController);
    if g_svcStatusHandle <> 0 then
    begin
      setSerivceStatus(srsStartPending);
      beginService;
    end
    else
      eventLogSysError(GetLastError);
  except
    on e: Exception do
      eventLogException(e, 'ServiceMain');
  end;

  setSerivceStatus(srsStopped);
  CoUninitialize;
end;

procedure RunNTService(handlers: TNTSvcCtrlCmdHandlers);
const
  ERROR_FAILED_SERVICE_CONTROLLER_CONNECT = 1063; // not running as service
var
  serviceStartTable: array [0 .. 1] of TServiceTableEntry;
  lastError: Integer;
  silent: Boolean;
begin
  g_svcHandlers := handlers;
  serviceStartTable[0].lpServiceName := PChar(g_appName);
  serviceStartTable[0].lpServiceProc := @ServiceMain;
  serviceStartTable[1].lpServiceName := nil;
  serviceStartTable[1].lpServiceProc := nil;

  if not StartServiceCtrlDispatcher(serviceStartTable[0]) then
  begin
    lastError := GetLastError;
    if lastError = ERROR_FAILED_SERVICE_CONTROLLER_CONNECT then
    begin
      if cmdLineParamExists('/install') or cmdLineParamExists('-install') then
      begin
        silent := cmdLineParamExists('/silent') or cmdLineParamExists('-silent');
        lastError := installNTService(g_appName, g_appDisplayName, g_appImagePath, g_serviceType,
          g_startType, g_errorSeverity, True);
        if lastError = 0 then
        begin
          if not silent then
            Windows.MessageBox(0, PChar('服务 "' + g_appDisplayName +  '" 安装成功！'),
              '系统服务管理', MB_ICONINFORMATION or MB_OK);
        end
        else begin
          if not silent then
            Windows.MessageBox(0, PChar('服务 "' + g_appDisplayName
              + '" 安装失败：' + getOSErrorMessage(lastError)),
              '系统服务管理', MB_ICONERROR or MB_OK);
        end;
      end
      else if cmdLineParamExists('/uninstall') or cmdLineParamExists('-uninstall') then
      begin
        silent := cmdLineParamExists('/silent') or cmdLineParamExists('-silent');
        lastError := uninstallNTService(g_appName);

        if lastError = 0 then
        begin
          if not silent then
            Windows.MessageBox(0, PChar('服务 "' + g_appDisplayName +  '" 已删除！'),
              '系统服务管理', MB_ICONINFORMATION or MB_OK);
        end
        else begin
          if not silent then
            Windows.MessageBox(0, PChar('服务 "' + g_appDisplayName +
              '" 删除失败: ' + getOSErrorMessage(lastError)),
              '系统服务管理', MB_ICONERROR or MB_OK);
        end;
      end;
    end
    else
      eventLogSysError(lastError);
  end;
end;

procedure setSerivceStatus(newStatus: TServiceRunningStatus);
begin
  g_svcStatus := newStatus;
  if RunningAsService then
    reportServiceStatus;
end;

procedure writeEventLog(const msg: string; EventType: TEventLogType; Category: Word; ID: DWORD);
const
  EVENT_TYPE_IDS: array [TEventLogType] of DWORD =
    (EVENTLOG_SUCCESS, EVENTLOG_AUDIT_SUCCESS, EVENTLOG_AUDIT_FAILURE,
    EVENTLOG_ERROR_TYPE, EVENTLOG_INFORMATION_TYPE, EVENTLOG_WARNING_TYPE);
var
  P: Pointer;
begin
  if msg <> '' then
  begin
    if g_RunningAsService then
    begin
      P := PChar(msg);
      if g_eventLogHandle = 0 then
        g_eventLogHandle := RegisterEventSource(nil, PChar(g_appName));

      if g_eventLogHandle <> 0 then
        Windows.ReportEvent(g_eventLogHandle, EVENT_TYPE_IDS[EventType], Category,
          ID, nil, 1, 0, @P, nil);
    end
    else
      DbgOutput(msg);
  end;
end;

procedure eventLogSysError(errorCode: Integer; const operation: string);
var
  s: string;
begin
  if operation = '' then
    s := getOSErrorMessage(errorCode)
  else
    s := operation + ' fail: ' + getOSErrorMessage(errorCode);

  if RunningAsService then
    writeEventLog(s, eltError)
  else
    DbgOutput(s);
end;

procedure eventLogException(e: Exception; const operation: string);
var
  s: string;
begin
  if operation = '' then
    s := e.ClassName + '(' + e.Message + ')'
  else
    s := operation + ' fail: ' + e.ClassName + '(' + e.Message + ')';

  if RunningAsService then
    writeEventLog(s, eltError)
  else
    DbgOutput(s);
end;

procedure unitInit;
var
  i: Integer;
begin
  G_AppDataRoaming := ExcludeTrailingPathDelimiter(SHGetSpecialFolderPath(sfiAppData));
  G_LocalAppDataLocal := ExcludeTrailingPathDelimiter(SHGetSpecialFolderPath(sfiLocalAppData));
  G_CommonAppData := ExcludeTrailingPathDelimiter(SHGetSpecialFolderPath(sfiCommonAppData));
  g_StartTime := Now;
  g_appImagePath := dslGetModuleFileName(0, 0);
  g_appPath := ExtractFilePath(g_appImagePath);
  g_appFileName := ExtractFileName(g_appImagePath);
  for i := Length(g_appFileName) downto 1 do
    if g_appFileName[i] = '.' then
    begin
      g_appFileNameWithoutExt := Copy(g_appFileName, 1, i - 1);
      Break;
    end;
  g_appDataDir := g_appPath;
  g_appUserPath := g_appPath;
  g_appVerInfo := TFileVersionInfo.Create(g_appImagePath);
  g_appName := g_appVerInfo.ProductName;
  if g_appName = '' then
    g_appName := g_appFileNameWithoutExt;
  g_appDisplayName := g_appVerInfo.FileDescription;
  if g_appDisplayName = '' then
    g_appDisplayName := g_appName;
  g_appId := g_appVerInfo.ProgramID;
  if g_appId = '' then
    g_appId := g_appFileNameWithoutExt;
  g_AppInitProcs := TList<TProc>.Create;
  g_UserLoginCallbacks := TList<TProc>.Create;
end;

procedure unitCleanup;
begin
  if Assigned(g_svcMainThread) then
    g_svcMainThread.Terminate;
  g_svcMainThread.Free;

  if g_eventLogHandle <> 0 then
  begin
    DeregisterEventSource(g_eventLogHandle);
    g_eventLogHandle := 0;
  end;

  FreeAndNil(g_appIni);
  FreeAndNil(G_appRegRoot);
  FreeAndNil(g_AppInitProcs);
  FreeAndNil(g_UserLoginCallbacks);
end;

{ TAppInfo }

procedure TAppInfo.Build;
var
  LProc: TProc;
begin
  try
    DoBuild;
    for LProc in g_AppInitProcs do
      LProc();
  finally
    Self.Free;
  end;
end;

function TAppInfo.DataPath(const _DataPath: string): TAppInfo;
begin
  FDataPath := _DataPath;
  Result := Self;
end;

function TAppInfo.DisplayName(const _DisplayName: string): TAppInfo;
begin
  FDisplayName := _DisplayName;
  Result := Self;
end;

procedure TAppInfo.DoBuild;
begin
  if FAppId <> '' then
    g_appId := FAppId;
  if FName <> '' then
    g_appName := FName;
  if FDisplayName <> '' then
    g_appDisplayName := FDisplayName;

  if FDataPath <> '' then
  begin
    FDataPath := ResolvePath(FDataPath);
    if Pos(':', FDataPath) > 0 then
      g_appDataDir := FDataPath
    else
      g_appDataDir := g_appPath + FDataPath;
    g_appDataDir := IncludeTrailingPathDelimiter(g_appDataDir);
  end;
  ForceDirectories(g_appDataDir);
  if FIniFileName <> '' then
    g_appIni := TIniFile.Create(g_appDataDir + FIniFileName);

  if FRegistryEntry <> '' then
  begin
    G_appRegRoot := TRegistry.Create;
    G_appRegRoot.RootKey := HKEY_CURRENT_USER;
    G_appRegRoot.OpenKey(FRegistryEntry, True);
  end;
end;

function TAppInfo.Id(const _Id: string): TAppInfo;
begin
  FAppId := _Id;
  Result := Self;
end;

function TAppInfo.IniFileName(const _IniFileName: string): TAppInfo;
begin
  FIniFileName := _IniFileName;
  Result := Self;
end;

function TAppInfo.Name(const _Name: string): TAppInfo;
begin
  FName := _Name;
  Result := Self;
end;

function TAppInfo.RegistryEntry(const _RegistryEntry: string): TAppInfo;
begin
  FRegistryEntry := _RegistryEntry;
  Result := Self;
end;

initialization
  unitInit;

finalization
  unitCleanup;

end.
