unit DSLTimer;

interface

uses
  SysUtils, Classes, Windows, DSLUtils;

type
  TTimerCallbackType = (tcbExpired, tcbCleanup);
  TTimeWheel = class;

  PTimerItem = ^TTimerItem;

  TTimerProc = procedure(driver: TTimeWheel; entry: PTimerItem; cbType: TTimerCallbackType);

  TTimerItem = record
    list: TLinkListEntry;
    context: Pointer;
    proc: TTimerProc;
    expire: Int64;
    _intervalAndFlags: DWORD;
{$IFDEF DSLTimeWheelDebug}
    execTimes: Integer;
    nextExecTime: TDateTime;
{$ENDIF}
    procedure init; inline;
    procedure release; inline;
    function getInterval: DWORD; inline;
    procedure setInterval(v: DWORD); inline;
    function enabled: Boolean; inline;
    procedure disable; inline;
    procedure enable; inline;
  end;

  TTimerVecRoot = record
    vec: array [0 .. 255] of TLinkListEntry;
  end;

  TTimerVec = record
    vec: array [0 .. 63] of TLinkListEntry;
  end;

  TTimeWheel = class(TRefCountedObject)
  private
    FRollThread: TThread;
    FLock: TInterlockSync;
    FCurrentTick: DWORD;
    FCurrentJiffies: Int64;
    FGradularity: DWORD;
    tv1: TTimerVecRoot;
    tv2, tv3, tv4, tv5: TTimerVec;
    FItemCount: Integer;
{$IFDEF DSLTimeWheelDebug}
    FOverdue: Integer;
    FOverdueThreshold: Integer;
    FExecutedItemCount: Integer;
{$ENDIF}
    function cascade(var tv: TTimerVec; idx: Integer): Integer;
    procedure _addTimer(timer: PTimerItem);
    function clearVec(var vec: array of TLinkListEntry; nowJiffy: Int64): Integer;
  public
    constructor Create(_gradularity: DWORD);
    destructor Destroy; override;
    function addTimer(dueTime: Int64; interval: DWORD; context: Pointer; proc: TTimerProc): PTimerItem;
    procedure checkExpired;
    procedure run;
    procedure stop;
    function clear: Integer;
    function getNowJiffies: Int64;
    property itemCount: Integer read FItemCount;
{$IFDEF DSLTimeWheelDebug}
    property overdue: Integer read FOverdue;
    property overdueThreshold: Integer read FOverdueThreshold write FOverdueThreshold;
    property executedItemCount: Integer read FExecutedItemCount;
{$ENDIF}
  end;

implementation

uses
  DSLThread;

type
  TTimeWheelRollThread = class(TSignalThread)
  private
    FTimeWheel: TTimeWheel;
  protected
    procedure Execute; override;
  public
    constructor Create(tw: TTimeWheel);
  end;

{ TTimeWheel }

procedure initTimerNodes(var tv: array of TLinkListEntry);
var
  i: Integer;
begin
  for i := Low(tv) to High(tv) do
    tv[i].SetEmpty;
end;

function TTimeWheel.addTimer;
var
  diff, expireAt: Int64;
  tmp: DWORD;
  timer: PTimerItem;
begin
  New(timer);
  timer.init;
  timer.proc := proc;
  timer.context := context;
  timer.setInterval(interval);

  FLock.acquire;
  tmp := GetTickCount - FCurrentTick;
  diff := (dueTime + tmp) div FGradularity;

  if diff < 0 then
    diff := 0;

  expireAt := FCurrentJiffies + diff;
  timer.expire := expireAt;
  _addTimer(timer);
  FLock.release;
  Result := timer;
end;

function TTimeWheel.cascade(var tv: TTimerVec; idx: Integer): Integer;
var
  entry, head: PLinkListEntry;
  tmp: PTimerItem;
begin
  Result := FCurrentJiffies shr (8 + idx * 6) and 63;
  head := @tv.vec[Result];
  entry := head.SetEmpty;

  while entry <> head do
  begin
    tmp := PTimerItem(entry);
    entry := entry.next;
    InterlockedDecrement(FItemCount);
    Self._addTimer(tmp);
  end;
end;

function TTimeWheel.clear: Integer;
var
  nowJiffy: Int64;
begin
  Result := 0;
  nowJiffy := Self.getNowJiffies;
  FLock.acquire;

  try
    Inc(Result, clearVec(tv1.vec, nowJiffy));
    Inc(Result, clearVec(tv2.vec, nowJiffy));
    Inc(Result, clearVec(tv3.vec, nowJiffy));
    Inc(Result, clearVec(tv4.vec, nowJiffy));
    Inc(Result, clearVec(tv5.vec, nowJiffy));
  finally
    FLock.release;
  end;
end;

function TTimeWheel.clearVec(var vec: array of TLinkListEntry; nowJiffy: Int64): Integer;
var
  i: Integer;
  entry, pList: PLinkListEntry;
  pTimer: PTimerItem;
{$IFDEF DSLTimeWheelDebug}
  diff: Int64;
{$ENDIF}
begin
  Result := 0;
  for i := Low(vec) to High(vec) do
  begin
    entry := @vec[i];
    pList := entry.SetEmpty;

    while pList <> entry do
    begin
      pTimer := PTimerItem(pList);
      pList := pList.next;

      try
        pTimer.proc(Self, pTimer, tcbCleanup);
      except
        on e: Exception do
          DbgOutputException('TTimeWheel.callTimer', e);
      end;
{$IFDEF DSLTimeWheelDebug}
      diff := pTimer.expire - nowJiffy;
      if diff < FOverdueThreshold then
      begin
        DbgOutput(IntToStr(diff) + ' jiffies');
        Inc(Result);
      end;
{$ENDIF}
      pTimer.release;
      InterlockedDecrement(FItemCount);
    end;
  end;
end;

constructor TTimeWheel.Create(_gradularity: DWORD);
begin
  inherited Create;
  FLock.init;
  initTimerNodes(tv1.vec);
  initTimerNodes(tv2.vec);
  initTimerNodes(tv3.vec);
  initTimerNodes(tv4.vec);
  initTimerNodes(tv5.vec);
  FGradularity := _gradularity;
  FCurrentTick := GetTickCount;
  FCurrentJiffies := 0;
{$IFDEF DSLTimeWheelDebug}
  FOverdue := 0;
  FOverdueThreshold := 5;
{$ENDIF}
end;

destructor TTimeWheel.Destroy;
begin
  stop;
  clear;
  FLock.cleanup;
  inherited;
end;

function TTimeWheel.getNowJiffies: Int64;
var
  nJiffies: DWORD;
begin
  nJiffies := (GetTickCount - FCurrentTick) div FGradularity;
  Result := FCurrentJiffies + nJiffies;
end;

procedure TTimeWheel.run;
begin
  if not Assigned(FRollThread) then
    FRollThread := TTimeWheelRollThread.Create(Self);
end;

procedure TTimeWheel.stop;
begin
  if Assigned(FRollThread) then
  begin
    TSignalThread(FRollThread).StopAndWait;
    FreeAndNil(FRollThread);
  end;
end;

procedure TTimeWheel.checkExpired;
var
  nJiffies, tick, i, interval: DWORD;
  idx: Integer;
  entry, head: PLinkListEntry;
  timer: PTimerItem;
  runningTimers: TLinkListEntry;
{$IFDEF DSLTimeWheelDebug}
  nowJiffy, diff: Int64;
{$ENDIF}
begin
  runningTimers.SetEmpty;
  tick := GetTickCount;
  nJiffies := (tick - FCurrentTick) div FGradularity;

  for i := 1 to nJiffies do
  begin
    idx := FCurrentJiffies and 255;
{$IFDEF DSLTimeWheelDebug}
    nowJiffy := Self.getNowJiffies;
{$ENDIF}
    FLock.acquire;
    if (idx = 0) and (cascade(tv2, 0) = 0) and (cascade(tv3, 1) = 0) and (cascade(tv4, 2) = 0) then
      cascade(tv5, 3);

    Inc(FCurrentJiffies);
    Inc(FCurrentTick, FGradularity);
    head := @tv1.vec[idx];
    entry := head.SetEmpty;
    FLock.release;

    while entry <> head do
    begin
      // runningTimers.insertHead(entry);
      timer := PTimerItem(entry);
      entry := entry.next;

      try
        timer.proc(Self, timer, tcbExpired);
      except
        on e: Exception do
          DbgOutputException('TTimeWheel.callTimer', e);
      end;
{$IFDEF DSLTimeWheelDebug}
      Inc(timer.execTimes);
      InterlockedIncrement(FExecutedItemCount);
      diff := nowJiffy - timer.expire;
      if absoluteValue(diff) > FOverdueThreshold then
      begin
        Inc(FOverdue);
        DbgOutput('overdue ' + IntToStr(diff) + ' jiffies');
      end;
{$ENDIF}
      InterlockedDecrement(FItemCount);
      interval := timer.getInterval;
      if (interval > 0) and timer.enabled then
      begin
        Inc(timer.expire, (interval + FGradularity - 1) div FGradularity);
        FLock.acquire;
        _addTimer(timer);
        FLock.release;
      end
      else
        timer.release;
    end;
  end;
end;

procedure TTimeWheel._addTimer(timer: PTimerItem);
var
  diff, expireAt: Int64;
  entry: PLinkListEntry;
begin
  timer.enable;
  diff := timer.expire - FCurrentJiffies;

  if diff < 0 then
    expireAt := FCurrentJiffies
  else
    expireAt := timer.expire;
{$IFDEF DSLTimeWheelDebug}
  timer.nextExecTime := IncMilliSecond(Now, (expireAt - FCurrentJiffies) * FGradularity);
{$ENDIF}
  if diff < 256 then
    entry := @tv1.vec[expireAt and 255]
  else if diff < 256 * 64 then
    entry := @tv2.vec[expireAt shr 8 and 63]
  else if diff < 256 * 64 * 64 then
    entry := @tv3.vec[expireAt shr 14 and 63]
  else if diff < 256 * 64 * 64 * 64 then
    entry := @tv4.vec[expireAt shr 20 and 63]
  else
    entry := @tv5.vec[expireAt shr 26 and 63];

  entry.insertHead(@timer.list);
  InterlockedIncrement(FItemCount);
end;

{ TTimerItem }

procedure TTimerItem.disable;
begin
  _intervalAndFlags := _intervalAndFlags and $7FFFFFFF;
end;

procedure TTimerItem.enable;
begin
  _intervalAndFlags := _intervalAndFlags or $80000000;
end;

function TTimerItem.enabled: Boolean;
begin
  Result := _intervalAndFlags and $80000000 <> 0;
end;

function TTimerItem.getInterval: DWORD;
begin
  Result := _intervalAndFlags and $FFFFFF;
end;

procedure TTimerItem.init;
begin
  _intervalAndFlags := $80000000;
{$IFDEF DSLTimeWheelDebug}
  execTimes := 0;
  nextExecTime := 0;
{$ENDIF}
end;

procedure TTimerItem.release;
begin
  Dispose(@Self);
end;

procedure TTimerItem.setInterval(v: DWORD);
begin
  _intervalAndFlags := (_intervalAndFlags or $FFFFFF) and (v or $FF000000);
end;


{ TTimeWheelRollThread }

constructor TTimeWheelRollThread.Create(tw: TTimeWheel);
begin
  FTimeWheel := tw;
  inherited Create(False);
end;

procedure TTimeWheelRollThread.Execute;
begin
  inherited;

  while not Self.Terminated do
  begin
    FTimeWheel.checkExpired;
    if Self.WaitForStopSignal(FTimeWheel.FGradularity) then
      Break;
  end;
end;

end.
