unit DSLThread;

interface

uses
  SysUtils, Classes, Windows, DSLUtils, Generics.Collections;

type
  TSignalThread = class(TThread)
  private
    fStopSignal: THandle;
    function GetTerminating: Boolean;
  protected
    function WaitForStopSignal(timeout: DWORD = INFINITE): Boolean;
    function WaitForMultiObjects(handles: array of THandle; timeout: DWORD = INFINITE): DWORD;
    function WaitForSingleObject(handle: THandle; timeout: DWORD = INFINITE): DWORD;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    procedure SendStopSignal;
    procedure StopAndWait;
    property Terminating: Boolean read GetTerminating;
  end;

  TAsyncWorkSyncResultTask = class(TRunnable)
  private
    FWindowHandle: THandle;
    FMsgId: DWORD;
  protected
    procedure AsyncWork; virtual; abstract;
  public
    constructor Create(_MsgId: DWORD; _WindowHandle: THandle = 0);
    procedure run(context: TObject); override;
    procedure HandleResult; virtual; abstract;
  end;

  TAsyncWorkSyncResultThread = class(TSignalThread)
  private
    FWindowHandle: THandle;
    FMsgId: DWORD;
    FExceptionRaised: Boolean;
    FStatusCode: Integer;
    FStatusText: string;
  protected
    procedure AsyncWork; virtual; abstract;
    procedure Execute; override;
  public
    constructor Create(_MsgId: DWORD = 0; _WindowHandle: THandle = 0);
    procedure HandleResult; virtual;
    property ExceptionRaised: Boolean read FExceptionRaised;
    property StatusCode: Integer read FStatusCode write FStatusCode;
    property StatusText: string read FStatusText write FStatusText;
  end;

  TMyAnonymousThread = class;

  TMyAnonymousCallbackMethod = procedure(thread: TMyAnonymousThread) of object;
  TMyAnonymousCallbackProc = procedure(thread: TMyAnonymousThread);

  TMyAnonymousThread = class(TAsyncWorkSyncResultThread)
  private
    FWorkMethod: TMyAnonymousCallbackMethod;
    FResultMethod: TMyAnonymousCallbackMethod;
    FWorkProc: TMyAnonymousCallbackProc;
    FResultProc: TMyAnonymousCallbackProc;
    FAnonymousWorkProc: SysUtils.TProc;
    FAnonymousResultProc: SysUtils.TProc;
  protected
    procedure AsyncWork; override;
  public
    PropInt64: Int64;
    PropInt: Integer;
    PropUStr: u16string;
    PropRBS: RawByteString;
    PropFloat: Double;
    PropBool: Boolean;
    PropPointer: Pointer;
    context: TProperties;
    constructor Create(AWorkMethod: TMyAnonymousCallbackMethod; AResultMethod: TMyAnonymousCallbackMethod = nil;
      _MsgId: DWORD = 0; _WindowHandle: THandle = 0); overload;
    constructor Create(AWorkProc: TMyAnonymousCallbackProc; AResultProc: TMyAnonymousCallbackProc = nil;
      _MsgId: DWORD = 0; _WindowHandle: THandle = 0); overload;
    constructor Create(AWorkProc: SysUtils.TProc; AResultProc: SysUtils.TProc = nil; _MsgId: DWORD = 0;
      _WindowHandle: THandle = 0); overload;
    procedure HandleResult; override;
  end;

  TTaskQueue = class
  private
    FTaskSemaphore: THandle;
    FTaskQueue: TFIFOQueue;
    FAlreadyRunCount: Integer;
    FWaitingTimeout: DWORD;
    FTerminated: Boolean;
    FOnIdle: TProcedure;
    FThreadId: DWORD;
    function getPendingRunnableCount: Integer;
  protected
    procedure DoIdle; virtual;
    procedure BeforeRun; virtual;
    procedure AfterRun; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure clear;
    function queue(task: IRunnable): Boolean;
    function queueAsFirst(task: IRunnable): Boolean;
    function queueBatch(runnables: TList): Boolean;
    function queueProc(proc: SysUtils.TProc): Boolean;
    function queueProcAsFirst(proc: SysUtils.TProc): Boolean;
    procedure run;
    procedure Terminate;
    property WaitingTimeout: DWORD read FWaitingTimeout write FWaitingTimeout;
    property PendingRunnableCount: Integer read getPendingRunnableCount;
    property AlreadyRunCount: Integer read FAlreadyRunCount;
    property Terminated: Boolean read FTerminated;
    property OnIdle: TProcedure read FOnIdle write FOnIdle;
  end;

  TBaseWorkThread = class(TSignalThread)
  private
    function GetPendingTaskCount: Integer;
  protected
    fTaskSemaphore: THandle;
    fTaskQueue: TFIFOQueue;
    fWaitingForTask: Boolean;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    function QueueTask(task: Pointer): Boolean;
    function QueueTaskFirst(task: Pointer): Boolean;
    function QueueTasks(tasks: TList): Boolean;
    property PendingTaskCount: Integer read GetPendingTaskCount;
    property WaitingForTask: Boolean read fWaitingForTask;
  end;

  TWorkThread = class(TBaseWorkThread)
  private
    fCompletedTaskCount: Integer;
    fCurrentTaskName: string;
    FCurrentTaskStartTime: TDateTime;
  protected
    procedure DoIdle; virtual;
    procedure BeforeExecute; virtual;
    procedure AfterExecute; virtual;
    procedure Execute; override;
  public
    destructor Destroy; override;
    procedure ClearTask;
    property CompletedTaskCount: Integer read fCompletedTaskCount;
    property CurrentTaskName: string read fCurrentTaskName;
    property CurrentTaskStartTime: TDateTime read FCurrentTaskStartTime;
  end;

  TWorkThreadClass = class of TWorkThread;

  PDelayRunnable = ^TDelayRunnable;

  TDelayRunnable = record
    next: PDelayRunnable;
    runtime: TDateTime;
    task: TRunnable;
  end;

  TDelayTaskQueue = class
  private
    fFirstTask: PDelayRunnable;
    fLockState: Integer;
    fSize: Integer;
  public
    destructor Destroy; override;
    procedure clear;
    function push(task: TRunnable; DelayMS: Int64): Boolean; overload;
    function push(task: TRunnable; runtime: TDateTime): Boolean; overload;
    function pop(var delay: DWORD): TRunnable;
    property size: Integer read fSize;
  end;

  TDelayTaskExecutor = class(TSignalThread)
  private
    fTaskEvent: THandle;
    fTaskQueue: TDelayTaskQueue;
    fCompletedTaskCount: Integer;
    function GetPendingTaskCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    function QueueTask(task: TRunnable; DelayMS: Int64): Boolean; overload;
    function QueueTask(task: TRunnable; runtime: TDateTime): Boolean; overload;
    property PendingTaskCount: Integer read GetPendingTaskCount;
    property CompletedTaskCount: Integer read fCompletedTaskCount;
  end;

  TWorkThreadPool = class
  private
    fThreads: TList;
    fActive: Boolean;
    fThreadCount: Integer;
    fThreadClass: TWorkThreadClass;
    procedure SetActive(const value: Boolean);
    procedure SetThreadCount(const value: Integer);
  protected
    procedure start;
    procedure stop;
  public
    constructor Create;
    destructor Destroy; override;
    function QueueTask(task: TRunnable): Boolean;
    property Active: Boolean read fActive write SetActive;
    property ThreadCount: Integer read fThreadCount write SetThreadCount;
    property ThreadClass: TWorkThreadClass read fThreadClass write fThreadClass;
  end;

  TPoolOverflowStrategy = (posDiscard, posFreeTask, posEnQueue);
  TThreadPool = class(TRefCountedObject)
  private
    class var FGlobal: TThreadPool;
  private
    FRunningThreadCount: Integer;
    FIdleThreadsLock: Integer;
    FIdleThreads: TThread;
    FIdleThreadCount: Integer;
    FMaxThreadCount: Integer;
    fCompletedTaskCount: Integer;
    fTaskQueue: TFIFOQueue;
    FReserveThreadCount: Integer;
    procedure LockIdle;
    procedure UnlockIdle;
    procedure ReleaseThreads(n: Integer);
    procedure ClearThreads;
    procedure ClearTask;
    procedure SetMaxThreadCount(const value: Integer);
    function GetThreadCount: Integer;
    procedure SetReserveThreadCount(const value: Integer);
    function GetTaskCountInQueue: Integer;
  protected
    function GetIdleThread: TThread;
    procedure return(thread: TThread);
  public
    class constructor Create;
    constructor Create;
    destructor Destroy; override;
    procedure stop;
    function ExecProc(AProc: TProc): Boolean; overload;
    function Execute(task: IRunnable; OverflowStrategy: TPoolOverflowStrategy = posEnQueue): Boolean;
    property MaxThreadCount: Integer read FMaxThreadCount write SetMaxThreadCount;
    property ReserveThreadCount: Integer read FReserveThreadCount write SetReserveThreadCount;
    property RunningThreadCount: Integer read FRunningThreadCount;
    property IdleThreadCount: Integer read FIdleThreadCount;
    property ThreadCount: Integer read GetThreadCount;
    property CompletedTaskCount: Integer read fCompletedTaskCount;
    property TaskCountInQueue: Integer read GetTaskCountInQueue;
    class property Global: TThreadPool read FGlobal;
  end;

procedure StopAndWaitForThread(thread: TThread);
procedure WaitForThreads(const threads: array of TThread);
procedure StopAndWaitForThreads(threads: TList); overload;
procedure StopAndWaitForThreads(threads: TObjectList<TThread>); overload;

implementation

uses
  DateUtils, Forms;

procedure StopAndWaitForThread(thread: TThread);
var
  threads: array [0 .. 0] of TThread;
begin
  if Assigned(thread) then
  begin
    threads[0] := thread;
    WaitForThreads(threads);
  end;
end;

procedure WaitForThreads(const threads: array of TThread);
var
  handles: array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of THandle;
  P1, P2, i, n: Integer;
begin
  for i := Low(threads) to High(threads) do
  begin
    threads[i].Terminate;
    if threads[i] is TSignalThread then
      TSignalThread(threads[i]).SendStopSignal;
  end;

  P1 := Low(threads);

  while P1 <= High(threads) do
  begin
    P2 := High(threads);

    if P2 + 1 - P1 > length(handles) then
      P2 := P1 + length(handles) - 1;

    for i := P1 to P2 do
      handles[i - P1] := threads[i].handle;

    n := P2 + 1 - P1;

    if RunningInMainThread then
    begin
      while MsgWaitForMultipleObjects(n, PWOHandleArray(@handles)^, True, INFINITE, QS_ALLINPUT) = DWORD
        (n + WAIT_OBJECT_0) do
        Application.ProcessMessages;
    end
    else
      WaitForMultipleObjects(n, PWOHandleArray(@handles), True, INFINITE);

    P1 := P2 + 1;
  end;
end;

procedure StopAndWaitForThreads(threads: TList);
var
  handles: array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of THandle;
  P1, P2, i, n: Integer;
begin
  for i := 0 to threads.count - 1 do
  begin
    TThread(threads[i]).Terminate;

    if TThread(threads[i]) is TSignalThread then
      TSignalThread(threads[i]).SendStopSignal;
  end;

  P1 := 0;

  while P1 < threads.count do
  begin
    P2 := threads.count - 1;

    if P2 - P1 + 1 > length(handles) then
      P2 := P1 + length(handles) - 1;

    for i := P1 to P2 do
      handles[i - P1] := TThread(threads[i]).handle;

    n := P2 + 1 - P1;

    if RunningInMainThread then
    begin
      while MsgWaitForMultipleObjects(n, handles, True, INFINITE, QS_ALLINPUT) = DWORD(n + WAIT_OBJECT_0) do
        Application.ProcessMessages;
    end
    else
      WaitForMultipleObjects(n, PWOHandleArray(@handles), True, INFINITE);

    P1 := P2 + 1;
  end;

  for i := 0 to threads.count - 1 do
    TObject(threads[i]).Free;

  threads.clear;
end;

procedure StopAndWaitForThreads(threads: TObjectList<TThread>); overload;
var
  handles: array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of THandle;
  P1, P2, i, n: Integer;
begin
  for i := 0 to threads.count - 1 do
  begin
    threads[i].Terminate;

    if threads[i] is TSignalThread then
      TSignalThread(threads[i]).SendStopSignal;
  end;

  P1 := 0;

  while P1 < threads.count do
  begin
    P2 := threads.count - 1;

    if P2 - P1 + 1 > length(handles) then
      P2 := P1 + length(handles) - 1;

    for i := P1 to P2 do
      handles[i - P1] := threads[i].handle;

    n := P2 + 1 - P1;

    if RunningInMainThread then
    begin
      while MsgWaitForMultipleObjects(n, handles, True, INFINITE, QS_ALLINPUT) = DWORD(n + WAIT_OBJECT_0) do
        Application.ProcessMessages;
    end
    else
      WaitForMultipleObjects(n, PWOHandleArray(@handles), True, INFINITE);

    P1 := P2 + 1;
  end;

  threads.clear;
end;

type
  TPoolThread = class(TSignalThread)
  private
    FNext: TPoolThread;
    FPool: TThreadPool;
    FExecSignal: THandle;
    FTask: IRunnable;
  protected
    procedure Execute; override;
  public
    constructor Create(_pool: TThreadPool);
    destructor Destroy; override;
    procedure run(_task: IRunnable);
    property Pool: TThreadPool read FPool;
  end;

{ TBaseWorkThread }

constructor TBaseWorkThread.Create(CreateSuspended: Boolean);
begin
  fTaskSemaphore := CreateEvent(nil, False, False, nil);
  fTaskQueue := TFIFOQueue.Create;
  inherited Create(CreateSuspended);
end;

destructor TBaseWorkThread.Destroy;
begin
  fTaskQueue.Free;
  CloseHandle(fTaskSemaphore);
  inherited;
end;

function TBaseWorkThread.GetPendingTaskCount: Integer;
begin
  Result := fTaskQueue.size;
end;

function TBaseWorkThread.QueueTask(task: Pointer): Boolean;
begin
  fTaskQueue.push(task);
  SetEvent(fTaskSemaphore);
  Result := True;
end;

function TBaseWorkThread.QueueTaskFirst(task: Pointer): Boolean;
begin
  fTaskQueue.PushFront(task);
  SetEvent(fTaskSemaphore);
  Result := True;
end;

function TBaseWorkThread.QueueTasks(tasks: TList): Boolean;
var
  i: Integer;
begin
  for i := 0 to tasks.count - 1 do
    fTaskQueue.push(tasks[i]);
  SetEvent(fTaskSemaphore);
  Result := True;
end;

type
  TTerminateRunnableQueue = class(TInterfacedObject, IRunnable)
    procedure run(context: TObject);
  end;

procedure TTerminateRunnableQueue.run(context: TObject);
begin
  TTaskQueue(context).Terminate;
end;

{ TTaskQueue }

procedure TTaskQueue.AfterRun;
begin

end;

procedure TTaskQueue.BeforeRun;
begin

end;

procedure TTaskQueue.clear;
var
  runnable: TRunnable;
begin
  FTaskQueue.lock;

  try
    while True do
    begin
      runnable := TRunnable(FTaskQueue.pop);

      if Assigned(runnable) then
        runnable.release
      else
        Break;
    end;
  finally
    FTaskQueue.unlock;
  end;
end;

constructor TTaskQueue.Create;
begin
  inherited Create;
  FTerminated := False;
  FWaitingTimeout := 500;
  FTaskSemaphore := CreateEvent(nil, False, False, nil);
  FTaskQueue := TFIFOQueue.Create;
  FThreadId := 0;
end;

destructor TTaskQueue.Destroy;
begin
  Self.clear;
  FTaskQueue.Free;
  CloseHandle(FTaskSemaphore);
  inherited;
end;

procedure TTaskQueue.DoIdle;
begin
  if Assigned(FOnIdle) then
    FOnIdle();
end;

function TTaskQueue.getPendingRunnableCount: Integer;
begin
  Result := FTaskQueue.size;
end;

function TTaskQueue.queue(task: IRunnable): Boolean;
begin
  task._AddRef;
  FTaskQueue.push(Pointer(task));
  SetEvent(FTaskSemaphore);
  Result := True;
end;

function TTaskQueue.queueAsFirst(task: IRunnable): Boolean;
begin
  task._AddRef;
  FTaskQueue.PushFront(Pointer(task));
  SetEvent(FTaskSemaphore);
  Result := True;
end;

function TTaskQueue.queueBatch;
var
  i: Integer;
begin
  for i := 0 to runnables.count - 1 do
    FTaskQueue.push(runnables[i]);
  SetEvent(FTaskSemaphore);
  Result := True;
end;

function TTaskQueue.queueProc(proc: SysUtils.TProc): Boolean;
begin
  Result := Self.queue(TDelegatedRunnable.Create(proc));
end;

function TTaskQueue.queueProcAsFirst(proc: SysUtils.TProc): Boolean;
begin
  Result := Self.queueAsFirst(TDelegatedRunnable.Create(proc));
end;

procedure TTaskQueue.run;
var
  runnable: TRunnable;
  wr: DWORD;
begin
  FTerminated := False;
  FThreadId := GetCurrentThreadId;
  Self.BeforeRun;

  try
    while not Self.Terminated do
    begin
      try
        wr := Windows.WaitForSingleObject(FTaskSemaphore, FWaitingTimeout);
        if wr <> WAIT_OBJECT_0 then
        begin
          if wr = WAIT_TIMEOUT then
            Self.DoIdle;
          Continue;
        end;

        while not Self.Terminated do
        begin
          runnable := TRunnable(FTaskQueue.pop);

          if not Assigned(runnable) then
            Break;

          Inc(FAlreadyRunCount);

          try
            runnable.run(Self);
          except
            on e: Exception do
              DbgOutput(TRunnable.ClassName + '.run: ' + e.Message);
          end;

          runnable.release;
        end;
      except
        on e: Exception do
          DbgOutputException('TTaskQueue.run', e);
      end;
    end;
  finally
    Self.AfterRun;
    Self.FThreadId := 0;
  end;
end;

procedure TTaskQueue.Terminate;
begin
  Self.FTerminated := True;
  if (FThreadId <> 0) and (GetCurrentThreadId <> FThreadId) then
    Self.queueAsFirst(TTerminateRunnableQueue.Create);
end;

{ TWorkThread }

procedure TWorkThread.AfterExecute;
begin

end;

procedure TWorkThread.BeforeExecute;
begin

end;

procedure TWorkThread.ClearTask;
var
  task: TRunnable;
begin
  while True do
  begin
    task := TRunnable(fTaskQueue.pop);

    if Assigned(task) then
      task.release
    else
      Break;
  end;
end;

destructor TWorkThread.Destroy;
begin
  Self.ClearTask;
  inherited;
end;

procedure TWorkThread.DoIdle;
begin

end;

procedure TWorkThread.Execute;
var
  task: TRunnable;
begin
  inherited;

  Self.BeforeExecute;

  try
    while not Self.Terminated do
    begin
      try
        fWaitingForTask := True;

        if Self.WaitForSingleObject(fTaskSemaphore) <> WAIT_OBJECT_0 then
          Continue;

        fWaitingForTask := False;

        while not Self.Terminated do
        begin
          task := TRunnable(fTaskQueue.pop);

          if not Assigned(task) then
            Break;

          Inc(fCompletedTaskCount);

          FCurrentTaskStartTime := Now;

          try
            fCurrentTaskName := task.ClassName;
            task.run(Self);
          except
            on e: Exception do
              DbgOutput(TRunnable.ClassName + '.run: ' + e.Message);
          end;

          FCurrentTaskStartTime := 0;
          fCurrentTaskName := '';

          task.release;
        end;
      except
        on e: Exception do
          DbgOutputException('TWorkThread.Execute', e);
      end;
    end;
  finally
    Self.AfterExecute;
  end;
end;

{ TDelayTaskQueue }

procedure TDelayTaskQueue.clear;
var
  tmp: PDelayRunnable;
begin
  while InterlockedExchange(fLockState, 1) = 1 do
    ;

  try
    while Assigned(fFirstTask) do
    begin
      tmp := fFirstTask;
      fFirstTask := fFirstTask.next;
      tmp.task.release;
      Dispose(tmp);
    end;

    fFirstTask := nil;
    fSize := 0;
  finally
    InterlockedExchange(fLockState, 0)
  end;
end;

function TDelayTaskQueue.pop(var delay: DWORD): TRunnable;
var
  node: PDelayRunnable;
  dt: TDateTime;
  flag: Boolean;
begin
  while InterlockedExchange(fLockState, 1) = 1 do
    ;

  flag := False;

  try
    node := fFirstTask;

    if not Assigned(node) then
    begin
      delay := INFINITE;
      Result := nil;
    end
    else
    begin
      dt := Now;

      if node.runtime <= dt then
      begin
        Result := node.task;
        fFirstTask := node.next;
        Dec(fSize);
        flag := True;
      end
      else
      begin
        delay := MilliSecondsBetween(dt, node.runtime);
        Result := nil;
      end;
    end;

  finally
    InterlockedExchange(fLockState, 0);
  end;

  if flag then
    Dispose(node);
end;

destructor TDelayTaskQueue.Destroy;
begin
  Self.clear;
  inherited;
end;

function TDelayTaskQueue.push(task: TRunnable; DelayMS: Int64): Boolean;
var
  dt: TDateTime;
begin
  dt := IncMilliSecond(Now, DelayMS);
  Result := Self.push(task, dt);
end;

function TDelayTaskQueue.push(task: TRunnable; runtime: TDateTime): Boolean;
var
  n1, n2, node: PDelayRunnable;
begin
  New(node);
  node.task := task;
  node.runtime := runtime;

  while InterlockedExchange(fLockState, 1) = 1 do
    ;

  try
    n1 := nil;
    n2 := fFirstTask;

    while Assigned(n2) and (n2.runtime < runtime) do
    begin
      n1 := n2;
      n2 := n2.next;
    end;

    node.next := n2;

    if Assigned(n1) then
      n1.next := node
    else
      fFirstTask := node;

    Inc(fSize);

    Result := True;
  finally
    InterlockedExchange(fLockState, 0)
  end;
end;

{ TDelayTaskExecutor }

constructor TDelayTaskExecutor.Create(CreateSuspended: Boolean);
begin
  fTaskQueue := TDelayTaskQueue.Create;
  fTaskEvent := CreateEvent(nil, False, False, nil);
  inherited Create(CreateSuspended);
end;

destructor TDelayTaskExecutor.Destroy;
begin
  fTaskQueue.Free;
  CloseHandle(fTaskEvent);
  inherited;
end;

procedure TDelayTaskExecutor.Execute;
var
  task: TRunnable;
  delay: DWORD;
begin
  inherited;

  while not Self.Terminated do
  begin
    try
      task := fTaskQueue.pop(delay);

      if Assigned(task) then
      begin
        try
          task.run(Self);
        except
          on e: Exception do
            DbgOutput(TRunnable.ClassName + '.run: ' + e.Message);
        end;

        Inc(fCompletedTaskCount);

        task.release;
      end
      else
        Self.WaitForSingleObject(fTaskEvent, delay);
    except
      on e: Exception do
        DbgOutput('TDelayTaskExecutor.loop: ' + e.Message);
    end;
  end;
end;

function TDelayTaskExecutor.GetPendingTaskCount: Integer;
begin
  Result := fTaskQueue.size;
end;

function TDelayTaskExecutor.QueueTask(task: TRunnable; DelayMS: Int64): Boolean;
begin
  Result := fTaskQueue.push(task, DelayMS);

  if Result then
    SetEvent(fTaskEvent);
end;

function TDelayTaskExecutor.QueueTask(task: TRunnable; runtime: TDateTime): Boolean;
begin
  Result := fTaskQueue.push(task, runtime);

  if Result then
    SetEvent(fTaskEvent);
end;

{ TWorkThreadPool }

constructor TWorkThreadPool.Create;
begin
  fActive := False;
  fThreads := TList.Create;
  fThreadCount := 1;
end;

destructor TWorkThreadPool.Destroy;
begin
  Active := False;
  fThreads.Free;
  inherited;
end;

function TWorkThreadPool.QueueTask(task: TRunnable): Boolean;
begin
  if fActive then
    Result := TWorkThread(fThreads[Random(fThreads.count)]).QueueTask(task)
  else
    Result := False;
end;

procedure TWorkThreadPool.SetActive(const value: Boolean);
begin
  if fActive <> value then
  begin
    fActive := value;
    if fActive then
      start
    else
      Self.stop;
  end;
end;

procedure TWorkThreadPool.SetThreadCount(const value: Integer);
begin
  if not fActive then
  begin
    fThreadCount := value;

    if fThreadCount <= 0 then
      fThreadCount := 1;
  end;
end;

procedure TWorkThreadPool.start;
var
  i: Integer;
begin
  fThreads.count := fThreadCount;

  for i := 0 to fThreads.count - 1 do
    fThreads[i] := ThreadClass.Create(False);
end;

procedure TWorkThreadPool.stop;
begin
  StopAndWaitForThreads(fThreads);
end;

{ TPoolThread }

constructor TPoolThread.Create(_pool: TThreadPool);
begin
  FExecSignal := CreateEvent(nil, False, False, nil);
  _pool.AddRef;
  FPool := _pool;
  inherited Create(False);
end;

destructor TPoolThread.Destroy;
begin
  CloseHandle(FExecSignal);
  FPool.release;
  inherited;
end;

procedure TPoolThread.Execute;
var
  task: IRunnable;
begin
  inherited;

  while not Self.Terminated do
  begin
    if Self.WaitForSingleObject(FExecSignal) <> WAIT_OBJECT_0 then
      Break;

    task := FTask;
    FTask := nil;

    if Assigned(task) then
    begin
      try
        task.run(Self);
      except
        on e: Exception do
          DbgOutputException(e);
      end;
    end;

    FPool.return(Self);
  end;
end;

procedure TPoolThread.run(_task: IRunnable);
begin
  FTask := _task;
  SetEvent(FExecSignal);
end;

{ TThreadPool }

procedure TThreadPool.ClearTask;
var
  task: IRunnable;
begin
  while True do
  begin
    Pointer(task) := fTaskQueue.pop;
    task := nil;
    if task <> nil then
      task := nil
    else
      Break;
  end;
end;

procedure TThreadPool.ClearThreads;
begin
  ReleaseThreads(0);
end;

class constructor TThreadPool.Create;
begin
  FGlobal := TThreadPool.Create;
  FGlobal.MaxThreadCount := 100;
  FGlobal.ReserveThreadCount := 10;
end;

constructor TThreadPool.Create;
begin
  inherited Create;
  fTaskQueue := TFIFOQueue.Create;
end;

destructor TThreadPool.Destroy;
begin
  stop;
  fTaskQueue.Free;
  inherited;
end;

function TThreadPool.ExecProc(AProc: TProc): Boolean;
begin
  Result := Self.Execute(TDelegatedRunnable.Create(AProc));
end;

function TThreadPool.Execute(task: IRunnable; OverflowStrategy: TPoolOverflowStrategy): Boolean;
var
  thread: TPoolThread;
begin
  try
    thread := TPoolThread(GetIdleThread);
  except
    case OverflowStrategy of
      posFreeTask: ;
      posEnQueue:
        begin
          task._AddRef;
          fTaskQueue.push(Pointer(task));
        end;
    end;

    raise ;
  end;

  Result := Assigned(thread);

  if Result then
    thread.run(task)
  else
  begin
    case OverflowStrategy of
      posFreeTask:;
      posEnQueue:
        begin
          task._AddRef;
          fTaskQueue.push(Pointer(task));
        end;
    end;
  end;
end;

function TThreadPool.GetIdleThread: TThread;
var
  thread: TPoolThread;
  CreateNew: Boolean;
begin
  thread := nil;
  CreateNew := False;

  LockIdle;

  try
    if FIdleThreadCount > 0 then
    begin
      thread := TPoolThread(FIdleThreads);
      FIdleThreads := thread.FNext;
      InterlockedDecrement(FIdleThreadCount);
      InterlockedIncrement(FRunningThreadCount);
    end
    else if (FMaxThreadCount <= 0) or (ThreadCount < FMaxThreadCount) then
    begin
      InterlockedIncrement(FRunningThreadCount);
      CreateNew := True;
    end;
  finally
    UnlockIdle;
  end;

  if CreateNew then
    thread := TPoolThread.Create(Self);

  Result := thread;
end;

function TThreadPool.GetTaskCountInQueue: Integer;
begin
  Result := fTaskQueue.size;
end;

function TThreadPool.GetThreadCount: Integer;
begin
  Result := FRunningThreadCount + FIdleThreadCount;
end;

procedure TThreadPool.LockIdle;
begin
  while InterlockedExchange(FIdleThreadsLock, 1) = 1 do
    ;
end;

procedure TThreadPool.ReleaseThreads(n: Integer);
var
  threads: TList;
begin
  LockIdle;
  threads := TList.Create;
  try
    while Assigned(FIdleThreads) do
    begin
      threads.add(FIdleThreads);
      FIdleThreads := TPoolThread(FIdleThreads).FNext;
    end;
    FIdleThreadCount := 0;
    StopAndWaitForThreads(threads);
  finally
    UnlockIdle;
    threads.Free;
  end;
end;

procedure TThreadPool.return(thread: TThread);
var
  task: IRunnable;
begin
  InterlockedIncrement(fCompletedTaskCount);
  Pointer(task) := fTaskQueue.pop;

  if Assigned(task) then
  begin
{$IFDEF debug}
    DbgOutput('ThreadPool: execute queued task( ' + 'task.ClassName' + ' )');
{$ENDIF}
    TPoolThread(thread).run(task);
  end
  else
  begin
    InterlockedDecrement(FRunningThreadCount);

    if ((FMaxThreadCount <= 0) and (FReserveThreadCount > 0) and (ThreadCount > FReserveThreadCount)) or
      ((FMaxThreadCount > 0) and (ThreadCount > FMaxThreadCount)) then
    begin
      thread.FreeOnTerminate := True;
      TPoolThread(thread).SendStopSignal;
      thread.Terminate;
    end
    else
    begin
      LockIdle;
      try
        InterlockedIncrement(FIdleThreadCount);
        TPoolThread(thread).FNext := TPoolThread(FIdleThreads);
        FIdleThreads := thread;
      finally
        UnlockIdle;
      end
    end;
  end;
end;

procedure TThreadPool.SetMaxThreadCount(const value: Integer);
begin
  FMaxThreadCount := value;
end;

procedure TThreadPool.SetReserveThreadCount(const value: Integer);
begin
  FReserveThreadCount := value;
end;

procedure TThreadPool.stop;
begin
  ClearTask;
  ClearThreads;
end;

procedure TThreadPool.UnlockIdle;
begin
  InterlockedExchange(FIdleThreadsLock, 0);
end;

{ TSignalThread }

constructor TSignalThread.Create(CreateSuspended: Boolean);
begin
  fStopSignal := CreateEvent(nil, False, False, nil);
  inherited Create(Suspended);
end;

destructor TSignalThread.Destroy;
begin
  CloseHandle(fStopSignal);
  inherited;
end;

function TSignalThread.GetTerminating: Boolean;
begin
  Result := Self.Terminated;
end;

procedure TSignalThread.SendStopSignal;
begin
  SetEvent(fStopSignal);
end;

procedure TSignalThread.StopAndWait;
begin
  Self.Terminate;
  Self.SendStopSignal;
  Self.WaitFor;
end;

function TSignalThread.WaitForMultiObjects(handles: array of THandle; timeout: DWORD): DWORD;
var
  WaitHandles: TWOHandleArray;
  i, j: DWORD;
  wr: DWORD;
begin
  WaitHandles[0] := Self.fStopSignal;

  j := 1;

  for i := Low(handles) to High(handles) do
  begin
    WaitHandles[j] := handles[i];
    Inc(j);
  end;

  wr := WaitForMultipleObjectsEx(j, @WaitHandles, False, timeout, True);

  if wr = WAIT_OBJECT_0 then
    Result := WAIT_TIMEOUT
  else if (wr > WAIT_OBJECT_0) and (wr < WAIT_OBJECT_0 + j) then
    Result := wr - 1
  else
    Result := wr;
end;

function TSignalThread.WaitForSingleObject(handle: THandle; timeout: DWORD): DWORD;
var
  handles: array [0 .. 0] of THandle;
begin
  handles[0] := handle;
  Result := Self.WaitForMultiObjects(handles, timeout);
end;

function TSignalThread.WaitForStopSignal(timeout: DWORD): Boolean;
begin
  Result := WaitForSingleObjectEx(fStopSignal, timeout, True) = WAIT_OBJECT_0;
end;

{ TAsyncWorkSyncResultTask }

constructor TAsyncWorkSyncResultTask.Create(_MsgId: DWORD; _WindowHandle: THandle);
begin
  inherited Create;
  FWindowHandle := _WindowHandle;
  FMsgId := _MsgId;
end;

procedure TAsyncWorkSyncResultTask.run(context: TObject);
var
  MsgWnd: THandle;
begin
  try
    Self.AsyncWork;
  except

  end;

  Self.AddRef;

  if FWindowHandle <> 0 then
    MsgWnd := FWindowHandle
  else
    MsgWnd := Application.handle;

  PostMessage(MsgWnd, FMsgId, 0, LPARAM(Self));
end;


{ TAsyncWorkSyncResultThread }

constructor TAsyncWorkSyncResultThread.Create(_MsgId: DWORD; _WindowHandle: THandle);
begin
  FWindowHandle := _WindowHandle;
  FMsgId := _MsgId;
  inherited Create(False);
end;

procedure TAsyncWorkSyncResultThread.Execute;
var
  MsgWnd: THandle;
begin
  inherited;

  FExceptionRaised := False;

  try
    Self.AsyncWork;
  except
    on e: Exception do
    begin
      FExceptionRaised := True;
      StatusCode := 0;
      StatusText := e.Message;
    end;
  end;

  if FMsgId <> 0 then
  begin
    if FWindowHandle <> 0 then
      MsgWnd := FWindowHandle
    else
      MsgWnd := Application.handle;

    PostMessage(MsgWnd, FMsgId, 0, LPARAM(Self));
  end;
end;

procedure TAsyncWorkSyncResultThread.HandleResult;
begin

end;

{ TMyAnonymousThread }

procedure TMyAnonymousThread.AsyncWork;
begin
  inherited;

  if Assigned(FWorkMethod) then
    FWorkMethod(Self)
  else if Assigned(FWorkProc) then
    FWorkProc(Self)
  else if Assigned(FAnonymousWorkProc) then
    FAnonymousWorkProc();
end;

constructor TMyAnonymousThread.Create(AWorkMethod, AResultMethod: TMyAnonymousCallbackMethod; _MsgId: DWORD;
  _WindowHandle: THandle);
begin
  FWorkProc := nil;
  FResultProc := nil;
  FAnonymousWorkProc := nil;
  FAnonymousResultProc := nil;
  FWorkMethod := AWorkMethod;
  FResultMethod := AResultMethod;
  inherited Create(_MsgId, _WindowHandle);
end;

constructor TMyAnonymousThread.Create(AWorkProc, AResultProc: TMyAnonymousCallbackProc; _MsgId: DWORD;
  _WindowHandle: THandle);
begin
  FWorkMethod := nil;
  FResultMethod := nil;
  FAnonymousWorkProc := nil;
  FAnonymousResultProc := nil;
  FWorkProc := AWorkProc;
  FResultProc := AResultProc;
  inherited Create(_MsgId, _WindowHandle);
end;

constructor TMyAnonymousThread.Create(AWorkProc, AResultProc: SysUtils.TProc; _MsgId: DWORD; _WindowHandle: THandle);
begin
  FWorkMethod := nil;
  FResultMethod := nil;
  FWorkProc := nil;
  FResultProc := nil;
  FAnonymousWorkProc := AWorkProc;
  FAnonymousResultProc := AResultProc;
  inherited Create(_MsgId, _WindowHandle);
end;

procedure TMyAnonymousThread.HandleResult;
begin
  inherited;

  if Assigned(FResultMethod) then
    FResultMethod(Self)
  else if Assigned(FResultProc) then
    FResultProc(Self)
  else if Assigned(FAnonymousResultProc) then
    FAnonymousResultProc();
end;

end.
