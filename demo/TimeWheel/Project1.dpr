program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, DateUtils, Windows, DSLUtils;

var
  StdOutput: THandle;

type
  TThreadAddTimer = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create;
  end;

procedure timerProc(driver: TTimeWheel; timer: PTimerItem; cbType: TTimerCallbackType);
begin
  (*
  Writeln(IntToStr(Integer(timer.context)) + '  delay ' + IntToStr(driver.getNowJiffies - timer.expire)
    + ' jiffies, repeat ' + IntToStr(timer.execTimes) + ' times');

  if timer.execTimes > 100 then
    timer.disable;
  *)
end;

procedure showDebugInfo(driver: TTimeWheel; timer: PTimerItem; cbType: TTimerCallbackType);
var
  xy: Windows._COORD;
  scrinfo: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(StdOutput, scrinfo);
  xy.X := 0;
  xy.Y := 0;
  SetConsoleCursorPosition(StdOutput, xy);
  Writeln(FormatDateTime('yyyy-mm-dd hh:nn:ss zzz', now) + ' '
    + IntToStr(driver.itemCount) + ' pending, '
    + IntToStr(driver.overdue) + ' overdue, '
    + IntToStr(driver.executedItemCount) + ' executed                  ');
  SetConsoleCursorPosition(StdOutput, scrinfo.dwCursorPosition);
end;

var
  i: Integer;
  tw: TTimeWheel;
  g_exited: Boolean = False;
  g_Terminated: Boolean = False;

function consoleCtrlHandler(cmd: DWORD): BOOL; stdcall;
begin
  g_Terminated := True;
  Result := True;
  while not g_exited do
    Sleep(100);
end;

{ TThreadAddTimer }

constructor TThreadAddTimer.Create;
begin
  Self.FreeOnTerminate := True;
  inherited Create(False);
end;

procedure TThreadAddTimer.Execute;
begin
  inherited;

  while not g_Terminated do
  begin
    if tw.itemCount < 10000 then
    begin
      if Random(2) = 0 then
        tw.addTimer(Random($7fffffff), 0, nil, timerProc)
      else
        tw.addTimer(Random(10000), 0, nil, timerProc);
    end;

    Sleep(100);
  end;
end;

var
  xy: Windows._COORD;

begin
  System.ReportMemoryLeaksOnShutdown := True;
  RandSeed := GetTickCount;
  Randomize;
  StdOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  xy.X := 0;
  xy.Y := 1;
  SetConsoleCursorPosition(StdOutput, xy);
  SetConsoleCtrlHandler(@consoleCtrlHandler, True);
  tw := TTimeWheel.Create(100);
  tw.overdueThreshold := 1;
  try
    tw.addTimer(0, 1000, Pointer(999999), showDebugInfo);
    for i := 1 to 20 do
      TThreadAddTimer.Create;

    while not g_Terminated do
    begin
      tw.checkExpired;
      Sleep(10);
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  tw.checkExpired;
  Writeln(IntToStr(tw.clear) + ' timers overdue');
  tw.Free;
  Writeln('press ENTER to exit...');
  Readln;
  g_exited := True;
end.
