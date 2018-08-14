unit DSLIocp;

interface

uses
  SysUtils, Classes, Windows, dslWinsock2, MSWSock, MSTcpip, WS2tcpip, DSLUtils;

type
  TIocpIOService = class;
  TIocpIOContext = class;

  TIocpIOCallback = procedure(iosvc: TIocpIOService; HandleContext: Pointer; IOContext: TIocpIOContext);

  TIocpIOContext = class(TRefCountedObject)
  private
    type
      TIocpOverlapped = packed record
        internal: TOverlapped;
        context: TIocpIOContext;
      end;
      PIocpOverlapped = ^TIocpOverlapped;
  private
    FOverlapped: TIocpOverlapped;
    FBytesTransferred: Integer;
  protected
    procedure doComplete(iosvc: TIocpIOService; HandleContext: Pointer); virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure reuse; inline;
    function getSysOverlapped: POverlapped;
    property bytesTransferred: Integer read FBytesTransferred;
  end;

  TIocpIOService = class(TRefCountedObject)
  private
    FHandle: THandle;
  public
    constructor Create;
    destructor Destroy; override;
    procedure bind(hFile: THandle; key: Pointer);
    function poll(timeout: DWORD = INFINITE): Boolean;
    procedure run;
    procedure SendQuitSignal(Count: Integer = 1);
    property handle: THandle read FHandle;
  end;

function getAsyncIOCount: Integer;

implementation

const
  kernel32  = 'kernel32.dll';

function CreateIoCompletionPort(FileHandle, ExistingCompletionPort: THandle;
  CompletionKey: ULONG_PTR; NumberOfConcurrentThreads: DWORD): THandle; stdcall;
  external kernel32 name 'CreateIoCompletionPort';

function GetQueuedCompletionStatus(CompletionPort: THandle;
  var lpNumberOfBytesTransferred: DWORD;
  var lpCompletionKey: ULONG_PTR;
  var lpOverlapped: POverlapped; dwMilliseconds: DWORD): BOOL; stdcall;
  external kernel32 name 'GetQueuedCompletionStatus';

function PostQueuedCompletionStatus(CompletionPort: THandle; dwNumberOfBytesTransferred: DWORD;
  dwCompletionKey: ULONG_PTR; lpOverlapped: POverlapped): BOOL; stdcall;
  external kernel32 name 'PostQueuedCompletionStatus';

var
  g_AsyncIOCount: Integer = 0;

function getAsyncIOCount: Integer;
begin
  Result := g_AsyncIOCount;
end;

type
  TIocpWorkThread = class(TThread)
  private
    FIocp: TIocpIOService;
  protected
    procedure Execute; override;
  public
    constructor Create(_iocp: TIocpIOService);
    destructor Destroy; override;
  end;

{ TIocpIOService }

procedure TIocpIOService.bind(hFile: THandle; key: Pointer);
begin
  if CreateIoCompletionPort(hFile, Self.Handle, ULONG_PTR(key), 0) = 0 then
    RaiseLastOSError;
end;

constructor TIocpIOService.Create;
begin
  FHandle := CreateIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 0);
end;

destructor TIocpIOService.Destroy;
begin
  CloseHandle(FHandle);
  FHandle := 0;
  inherited;
end;

function TIocpIOService.poll(timeout: DWORD): Boolean;
var
  ovlp: POverlapped;
  key: ULONG_PTR;
  bytesTransferred: DWORD;
  IOContext: TIocpIOContext;
  ok: Boolean;
begin
  Result := True;
  ovlp := nil;
  key := 0;
  bytesTransferred := 0;
  ok := GetQueuedCompletionStatus(FHandle, bytesTransferred, key, POverlapped(ovlp), timeout);

  if Assigned(ovlp) then
  begin
    Inc(ovlp);
    IOContext := TIocpIOContext(PPointer(ovlp)^);
    IOContext.FBytesTransferred := bytesTransferred;
    try
      IOContext.doComplete(Self, Pointer(key));
    except
      on e: Exception do
        DbgOutputException('IOContext.doComplete', e);
    end;
  end;

  if ok then
  begin
    if (bytesTransferred = 0) and (key = 0) then
    begin
      // signal set with PostQueuedCompletionStatus
      DbgOutput('IOCP WorkThread (id ' + IntToStr(Windows.GetCurrentThreadId) + ') will quit');
      Result := False;
    end
  end
  else if not Assigned(ovlp) then
  begin
    // timeout
  end;
end;

procedure TIocpIOService.run;
begin
  while Self.poll do;
end;

procedure TIocpIOService.SendQuitSignal(Count: Integer);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Windows.PostQueuedCompletionStatus(Handle, 0, 0, nil);
end;

{ TIocpWorkThread }

constructor TIocpWorkThread.Create(_iocp: TIocpIOService);
begin
  _iocp.AddRef;
  FIocp := _iocp;
  inherited Create(False);
end;

destructor TIocpWorkThread.Destroy;
begin
  FIocp.Release;
  inherited;
end;

procedure TIocpWorkThread.Execute;
begin
  FIocp.run;
end;

{ TIocpIOContext }

constructor TIocpIOContext.Create;
begin
  inherited Create;
  FOverlapped.context := Self;
  InterlockedIncrement(g_AsyncIOCount);
end;

destructor TIocpIOContext.Destroy;
begin
  InterlockedDecrement(g_AsyncIOCount);
  inherited;
end;

function TIocpIOContext.getSysOverlapped: POverlapped;
begin
  Result := @FOverlapped.internal;
end;

procedure TIocpIOContext.reuse;
begin
  FillChar(FOverlapped.internal, SizeOf(FOverlapped.internal), 0);
  FBytesTransferred := 0;
end;

end.

