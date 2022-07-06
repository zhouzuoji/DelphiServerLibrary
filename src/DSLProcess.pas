unit DSLProcess;

interface

uses
  SysUtils,
  Classes,
  Windows,
  DSLUtils;

type
  TMobuleInfo = record
    ModuleId: DWORD;
    ModuleName: string;
    ModulePath: string;
  end;

function GetProcessList: TArray<TMobuleInfo>;
function GetModuleList(_pid: DWORD): TArray<TMobuleInfo>;
function getParentProcessId: DWORD;
function dslGetModuleFileName(hProcess, hModule: THandle): string;
function GetModulePath(const _pid: DWORD; const _ModuleName: string): string;
function getProcessFilePath(const pid: DWORD; const _ModuleName: string = ''): string;
function isLaunchedByExplorer: Boolean;

implementation

uses
  TlHelp32,
  PsAPI;

function getParentProcessId: DWORD;
var
  hSnapshot: THandle;
  procEntry: TProcessEntry32;
  myid: DWORD;
begin
  Result := 0;
  myid := GetCurrentProcessId;
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hSnapshot <> INVALID_HANDLE_VALUE then
    try
      procEntry.dwSize := SizeOf(TProcessEntry32);
      if Process32First(hSnapshot, procEntry) then
      begin
        repeat
          if procEntry.th32ProcessID = myid then
          begin
            Result := procEntry.th32ParentProcessID;
            Break;
          end;
        until not Process32Next(hSnapshot, procEntry);
      end;
    finally
      CloseHandle(hSnapshot);
    end;
end;

function getProcessFilePath_tlhlp32(const pid: DWORD): string; forward;

function dslGetModuleFileName(hProcess, hModule: THandle): string;
var
  buf: array [0 .. MAX_PATH] of Char;
  L: Integer;
begin
  Result := '';
  buf[0] := #0;
  if hProcess = 0 then
  begin
    L := Windows.GetModuleFileName(hModule, buf, MAX_PATH);
    if L > 0 then
      SetString(Result, buf, L);
  end
  else
  begin
    L := PsAPI.GetModuleFileNameEx(hProcess, hModule, buf, MAX_PATH);
    if L > 0 then
      SetString(Result, buf, L);
  end;
end;

function GetModulePath(const _pid: DWORD; const _ModuleName: string): string;
var
  LSnapshot: THandle;
  LEntry: TModuleEntry32;
begin
  Result := '';
  LSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, _pid);
  if LSnapshot = INVALID_HANDLE_VALUE then
    Exit;
  LEntry.dwSize := SizeOf(LEntry);
  try
    if Module32First(LSnapshot, LEntry) then
      repeat
        if StrIComp(LEntry.szModule, PChar(_ModuleName)) = 0 then
          Exit(StrPas(LEntry.szExePath));
      until not Module32Next(LSnapshot, LEntry);
  finally
    CloseHandle(LSnapshot);
  end;
end;

function getProcessFilePath(const pid: DWORD; const _ModuleName: string): string;
var
  hProcess: THandle;
begin
  if pid = 0 then
    Exit('');
  if pid = GetCurrentProcessId then
    Result := dslGetModuleFileName(0, 0)
  else begin
    Result := '';
    hProcess := OpenProcess(PROCESS_VM_READ or PROCESS_QUERY_INFORMATION, False, pid);
    if hProcess <> 0 then
    begin
      Result := dslGetModuleFileName(hProcess, 0);
      CloseHandle(hProcess);
    end;
  end;
  if (Result = '') and (_ModuleName <> '') then
    Result := GetModulePath(pid, _ModuleName);
end;

function isLaunchedByExplorer: Boolean;
var
  s: string;
begin
  s := ExtractFileName(getProcessFilePath(getParentProcessId));
  Result := SameText('explorer.exe', s);
end;

function GetProcessList: TArray<TMobuleInfo>;
var
  LSnapshot: THandle;
  LEntry: TProcessEntry32;
  LCount: Integer;
begin
  Result := nil;
  LSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if LSnapshot = INVALID_HANDLE_VALUE then
    Exit;
  LCount := 0;
  LEntry.dwSize := SizeOf(LEntry);
  try
    if Process32First(LSnapshot, LEntry) then
      repeat
        SetLength(Result, LCount + 1);
        Result[LCount].ModuleId := LEntry.th32ProcessID;
        Result[LCount].ModuleName := LEntry.szExeFile;
        Result[LCount].ModulePath :=  getProcessFilePath(LEntry.th32ProcessID, Result[LCount].ModuleName);
        Inc(LCount);
      until not Process32Next(LSnapshot, LEntry);
  finally
    CloseHandle(LSnapshot);
  end;
end;

function GetModuleList(_pid: DWORD): TArray<TMobuleInfo>;
var
  LSnapshot: THandle;
  LEntry: TModuleEntry32;
  LCount: Integer;
begin
  Result := nil;
  LSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, _pid);
  if LSnapshot = INVALID_HANDLE_VALUE then
    Exit;
  LCount := 0;
  LEntry.dwSize := SizeOf(LEntry);
  try
    if Module32First(LSnapshot, LEntry) then
      repeat
        SetLength(Result, LCount + 1);
        Result[LCount].ModuleId := LEntry.th32ModuleID;
        Result[LCount].ModuleName := LEntry.szModule;
        Result[LCount].ModulePath := LEntry.szExePath;
        Inc(LCount);
      until not Module32Next(LSnapshot, LEntry);
  finally
    CloseHandle(LSnapshot);
  end;
end;

function getProcessFilePath_tlhlp32(const pid: DWORD): string;
var
  hSnapshot: THandle;
  procEntry: TProcessEntry32;
begin
  Result := '';
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hSnapshot <> INVALID_HANDLE_VALUE then
    try
      procEntry.dwSize := SizeOf(TProcessEntry32);
      if Process32First(hSnapshot, procEntry) then
      begin
        repeat
          if procEntry.th32ProcessID = pid then
          begin
            Result := procEntry.szExeFile;
            Break;
          end;
        until not Process32Next(hSnapshot, procEntry);
      end;
    finally
      CloseHandle(hSnapshot);
    end;
end;

end.
