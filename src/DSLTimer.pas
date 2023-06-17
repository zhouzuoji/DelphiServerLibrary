unit DSLTimer;

interface

uses
  SysUtils,
  Classes,
  Windows,
  DSLUtils;

{$DEFINE TIME_WHEEL_DEBUG}

type
  TTimerCallbackType = (tcbExpired, tcbCleanup);
  TTimerProc = reference to procedure(cbType: TTimerCallbackType);
  TTimerId = Cardinal;

  ITimer = interface
    function Add(_DelayMSecs: Int64; _Interval: DWORD; _Callback: TTimerProc): TTimerId;
    procedure Delete(_TimerId: TTimerId);
    procedure Clear;
    procedure MoveOn;
  end;

  TTimeWheel = class(TInterfacedObject, ITimer)
  private
    FAddingTimerList: TLinkListEntry;
    FLastTick: DWORD;
    FLastJiffy: Int64;
    FMSecsPerJiffy: DWORD;
    tv1: array [0 .. 255] of TLinkListEntry;
    tv2, tv3, tv4, tv5: array [0 .. 63] of TLinkListEntry;
    FTimerCount, FTriggerCount: Integer;
    function cascade(var tv: array of TLinkListEntry; idx: Integer): Integer;
    procedure DoAddTimer(_Timer: Pointer);
    procedure DoClear(_Type: TTimerCallbackType);
    procedure clearVec(var vec: array of TLinkListEntry);
    procedure ProcessAddingTimers;
    procedure DoCallback(_Timer: Pointer; _Type: TTimerCallbackType);
  public
    constructor Create(_MSecsPerJiffy: DWORD);
    destructor Destroy; override;
    function Add(_DelayMSecs: Int64; _Interval: DWORD; _Callback: TTimerProc): TTimerId;
    procedure Delete(_TimerId: TTimerId);
    procedure Clear;
    procedure MoveOn;
    property TimerCount: Integer read FTimerCount;
    property TriggerCount: Integer read FTriggerCount;
  end;

implementation

uses
  MMSystem,
  DateUtils,
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

  PTimerItem = ^TTimerItem;

  TTimerItem = record
    ListNode: TLinkListEntry;
    Callback: TTimerProc;
    Deadline: Int64;
    _IntervalAndFlags: DWORD;
    {$IFDEF TIME_WHEEL_DEBUG}
    ExpireTime: TDateTime;
    {$ENDIF}
    procedure init; inline;
    procedure release; inline;
    function getInterval: DWORD; inline;
    procedure setInterval(v: DWORD); inline;
    function enabled: Boolean; inline;
    procedure disable; inline;
    procedure enable; inline;
  end;

{ TTimeWheel }

procedure initTimerNodes(var tv: array of TLinkListEntry);
var
  i: Integer;
begin
  for i := Low(tv) to High(tv) do
    tv[i].SetEmpty;
end;

function TTimeWheel.Add(_DelayMSecs: Int64; _Interval: DWORD; _Callback: TTimerProc): TTimerId;
var
  LTimer: PTimerItem;
begin
  if _DelayMSecs < 0 then
    _DelayMSecs := 0;
  New(LTimer);
  LTimer.init;
  LTimer.Callback := _Callback;
  LTimer.setInterval(_Interval);
  LTimer.Deadline := _DelayMSecs;
  {$IFDEF TIME_WHEEL_DEBUG}
  LTimer.ExpireTime := IncMilliSecond(Now, _DelayMSecs);
  {$ENDIF}

  TMonitor.Enter(Self);
  try
    FAddingTimerList.insertHead(@LTimer.ListNode);
  finally
    TMonitor.Exit(Self);
  end;
  Result := 0;
end;

function TTimeWheel.cascade(var tv: array of TLinkListEntry; idx: Integer): Integer;
var
  entry, head: PLinkListEntry;
  tmp: PTimerItem;
begin
  Result := FLastJiffy shr (8 + idx * 6) and 63;
  head := @tv[Result];
  entry := head.SetEmpty;

  while entry <> head do
  begin
    tmp := PTimerItem(entry);
    entry := entry.next;
    Dec(FTimerCount);
    Self.DoAddTimer(tmp);
  end;
end;

procedure TTimeWheel.Clear;
begin
  Self.Add(0, 0, Self.DoClear)
end;

procedure TTimeWheel.clearVec(var vec: array of TLinkListEntry);
var
  i: Integer;
  LNode: PLinkListEntry;
  LTimer: PTimerItem;
begin
  for i := Low(vec) to High(vec) do
  begin
    LNode := vec[i].SetEmpty;
    while LNode <> @vec[i] do
    begin
      LTimer := PTimerItem(LNode);
      LNode := LNode.next;
      DoCallback(LTimer, tcbCleanup);
    end;
  end;
end;

constructor TTimeWheel.Create(_MSecsPerJiffy: DWORD);
begin
  inherited Create;
  initTimerNodes(tv1);
  initTimerNodes(tv2);
  initTimerNodes(tv3);
  initTimerNodes(tv4);
  initTimerNodes(tv5);
  FAddingTimerList.SetEmpty;
  FMSecsPerJiffy := _MSecsPerJiffy;
  FLastTick := timeGetTime;
  FLastJiffy := 0;
end;

procedure TTimeWheel.Delete(_TimerId: TTimerId);
begin

end;

destructor TTimeWheel.Destroy;
begin
  DoClear(tcbExpired);
  inherited;
end;

procedure TTimeWheel.DoCallback(_Timer: Pointer; _Type: TTimerCallbackType);
var
  LTimer: PTimerItem absolute _Timer;
  LInterval: DWORD;
begin
  {$IFDEF TIME_WHEEL_DEBUG}
  if MilliSecondsBetween(LTimer.ExpireTime, Now) > FMSecsPerJiffy * 2 then
    Writeln(Int64(_Timer), ' ', FormatDateTime('HH:NN:SS.zzz', LTimer.ExpireTime), ', ', FormatDateTime('HH:NN:SS.zzz', Now));
  {$ENDIF}
  try
    LTimer.Callback(_Type);
  except
    on e: Exception do
      DbgOutputException('TTimeWheel.DoCallback', e);
  end;
  Dec(FTimerCount);
  Inc(FTriggerCount);
  LInterval := LTimer.getInterval;
  if (_Type = tcbExpired) and (LInterval > 0) and LTimer.enabled then
  begin
    // 定时触发的任务重新加入队列
    Inc(LTimer.Deadline, (LInterval + FMSecsPerJiffy - 1) div FMSecsPerJiffy);
    {$IFDEF TIME_WHEEL_DEBUG}
    LTimer.ExpireTime := IncMilliSecond(LTimer.ExpireTime, LInterval);
    {$ENDIF}
    DoAddTimer(LTimer);
  end
  else
    LTimer.release;
end;

procedure TTimeWheel.DoClear;
begin
  clearVec(tv1);
  clearVec(tv2);
  clearVec(tv3);
  clearVec(tv4);
  clearVec(tv5);
end;

procedure TTimeWheel.MoveOn;
var
  idx: Integer;
  LNode: PLinkListEntry;
  LTimer: PTimerItem;
begin
  ProcessAddingTimers;

  while timeGetTime - FLastTick >= FMSecsPerJiffy do
  begin
    idx := FLastJiffy and 255;
    if (idx = 0) and (cascade(tv2, 0) = 0) and (cascade(tv3, 1) = 0) and (cascade(tv4, 2) = 0) then
      cascade(tv5, 3);
    Inc(FLastJiffy);
    Inc(FLastTick, FMSecsPerJiffy);
    LNode := tv1[idx].SetEmpty;
    while LNode <> @tv1[idx] do
    begin
      LTimer := PTimerItem(LNode);
      LNode := LNode.next;
      DoCallback(LTimer, tcbExpired);
    end;
  end;
end;

procedure TTimeWheel.ProcessAddingTimers;
var
  LNode: PLinkListEntry;
  LTimer: PTimerItem;
  LCurrentTick, tmp: DWORD;
  LDelayMS: Int64;
begin
  LCurrentTick := timeGetTime;
  TMonitor.Enter(Self);
  try
    LNode := FAddingTimerList.SetEmpty;
  finally
    TMonitor.Exit(Self);
  end;
  while LNode <> @FAddingTimerList do
  begin
    LTimer := PTimerItem(LNode);
    LNode := LNode.next;
    tmp := LCurrentTick - FLastTick;
    LDelayMS := LTimer.Deadline;
    LTimer.Deadline := FLastJiffy + (LDelayMS + tmp + FMSecsPerJiffy - 1)  div FMSecsPerJiffy;
    if LDelayMS <= 0 then
    begin
      Inc(FTimerCount);
      DoCallback(LTimer, tcbExpired);
    end
    else
      DoAddTimer(LTimer);
  end;
end;

procedure TTimeWheel.DoAddTimer(_Timer: Pointer);
var
  LDuration: Int64;
  entry: PLinkListEntry;
  LTimer: PTimerItem absolute _Timer;
begin
  LTimer.enable;
  LDuration := LTimer.Deadline - FLastJiffy;

  if LDuration <= 0 then
  begin
    Inc(FTimerCount);
    DoCallback(LTimer, tcbExpired);
    Exit;
  end;

  if LDuration < 256 then
    entry := @tv1[LTimer.Deadline and 255]
  else if LDuration < 256 * 64 then
    entry := @tv2[LTimer.Deadline shr 8 and 63]
  else if LDuration < 256 * 64 * 64 then
    entry := @tv3[LTimer.Deadline shr 14 and 63]
  else if LDuration < 256 * 64 * 64 * 64 then
    entry := @tv4[LTimer.Deadline shr 20 and 63]
  else
    entry := @tv5[LTimer.Deadline shr 26 and 63];

  entry.insertHead(@LTimer.ListNode);
  Inc(FTimerCount);
end;

{ TTimerItem }

procedure TTimerItem.disable;
begin
  _IntervalAndFlags := _IntervalAndFlags and $7FFFFFFF;
end;

procedure TTimerItem.enable;
begin
  _IntervalAndFlags := _IntervalAndFlags or $80000000;
end;

function TTimerItem.enabled: Boolean;
begin
  Result := _IntervalAndFlags and $80000000 <> 0;
end;

function TTimerItem.getInterval: DWORD;
begin
  Result := _IntervalAndFlags and $FFFFFF;
end;

procedure TTimerItem.init;
begin
  _IntervalAndFlags := $80000000;
end;

procedure TTimerItem.release;
begin
  Dispose(@Self);
end;

procedure TTimerItem.setInterval(v: DWORD);
begin
  _IntervalAndFlags := (_IntervalAndFlags and $FF000000) or (v and $FFFFFF);
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
    FTimeWheel.MoveOn;
    if Self.WaitForStopSignal(FTimeWheel.FMSecsPerJiffy) then
      Break;
  end;
end;

end.
