unit DSLApp;

interface

uses
  SysUtils, Classes, IniFiles, ActiveX, Windows, WinSvc, DSLUtils, DSLThread;

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

function cmdLineParamExists(const param: string): Boolean;
function runningAsService: Boolean;
function getAppFileName: string;
function getAppPath: string;
function getAppName: string;
function getAppDisplayName: string;
function getAppStartTime: TDateTime;
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

procedure initApp(const name: string; const iniFileName: string = ''; const displayName: string = '');
procedure initUser(const username: string);
function getServiceMainThread: TTaskQueue;
procedure RunNTService(handlers: TNTSvcCtrlCmdHandlers);

procedure writeEventLog(const msg: string; EventType: TEventLogType = eltError;
  Category: Word = 0; ID: DWORD = 0);

procedure eventLogSysError(errorCode: Integer; const operation: string = '');
procedure eventLogException(e: Exception; const operation: string ='');
procedure setSerivceStatus(newStatus: TServiceRunningStatus);

var
  g_Terminating: Boolean;

implementation

var
  g_RunningAsService: Boolean = False;
  g_appPath: string = '';
  g_appFileName: string = '';
  g_appName: string = '';
  g_appDisplayName: string = '';
  g_StartTime: TDateTime = 0.0;
  g_appDataDir: string = '';
  g_appIni: TIniFile;
  g_userIni: TIniFile;
  g_eventLogHandle: THandle;
  g_svcStatus: TServiceRunningStatus;
  g_svcStatusHandle: SERVICE_STATUS_HANDLE;
  g_svcHandlers: TNTSvcCtrlCmdHandlers;
  g_startType: TNTServiceStartType = sstAuto;
  g_serviceType: TNTServiceType = stWin32;
  g_errorSeverity: TErrorSeverity = esNormal;
  g_svcMainThread: TTaskQueue;

function getServiceMainThread: TTaskQueue;
begin
  Result := g_svcMainThread;
end;

procedure initApp(const name, iniFileName, displayName: string);
begin
  g_appName := name;

  if displayName = '' then
    g_appDisplayName := name
  else
    g_appDisplayName := displayName;

  if Assigned(g_appIni) then
    g_appIni.Free;

  if iniFileName <> '' then
    g_appIni := TIniFile.Create(iniFileName);
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

function getAppName: string;
begin
  Result := g_appName;
end;

function getAppDisplayName: string;
begin
  Result := g_appDisplayName;
end;

function getAppFileName: string;
begin
  Result := g_appFileName;
end;

function getAppPath: string;
begin
  Result := g_appPath;
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
  d: string;
begin
  d := PathJoin(g_appDataDir, 'users\' + username + '\');
  ForceDirectories(d);
  g_userIni := TIniFile.Create(PathJoin(d, 'config.ini'));
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
        lastError := installNTService(g_appName, g_appDisplayName, g_appFileName, g_serviceType,
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
begin
  g_StartTime := Now;
  g_appFileName := dslGetModuleFileName(0, 0);
  g_appPath := ExtractFilePath(g_appFileName);
  g_appDataDir := g_appPath;
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

  if Assigned(g_appIni) then
    g_appIni.Free;
end;

initialization
  unitInit;

finalization
  unitCleanup;

end.
