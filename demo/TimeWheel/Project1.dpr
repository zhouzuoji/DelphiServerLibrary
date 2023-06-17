program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, DateUtils, Windows, DSLUtils, DSLTimer;

var
  StdOutput: THandle;
  i: Integer;
  tw: TTimeWheel;
  xy: Windows._COORD;
  g_exited: Boolean = False;
  g_Terminated: Boolean = False;

type
  TThreadAddTimer = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create;
  end;

procedure timerProc(cbType: TTimerCallbackType);
begin
  (*
  Writeln(IntToStr(Integer(timer.context)) + '  delay ' + IntToStr(driver.getNowJiffies - timer.expire)
    + ' jiffies, repeat ' + IntToStr(timer.execTimes) + ' times');

  if timer.execTimes > 100 then
    timer.disable;
  *)
end;

procedure showDebugInfo(cbType: TTimerCallbackType);
//var
  //xy: Windows._COORD;
  //scrinfo: TConsoleScreenBufferInfo;
begin
  //GetConsoleScreenBufferInfo(StdOutput, scrinfo);
  //xy.X := 0;
  //xy.Y := 0;
  //SetConsoleCursorPosition(StdOutput, xy);
  Writeln(FormatDateTime('yyyy-mm-dd hh:nn:ss zzz', now) + ' '
    + IntToStr(tw.TimerCount) + ' pending, '
    + IntToStr(tw.TriggerCount) + ' executed                  ');
  //SetConsoleCursorPosition(StdOutput, scrinfo.dwCursorPosition);
end;

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
    if tw.TimerCount < 10000 then
    begin
      if Random(2) = 0 then
        tw.Add(Random(10000), 0, timerProc)
      else
        tw.Add(Random(10000), 0, timerProc);
    end;

    Sleep(100);
  end;
end;

begin
  System.ReportMemoryLeaksOnShutdown := True;
  RandSeed := GetTickCount;
  Randomize;
  StdOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  xy.X := 0;
  xy.Y := 1;
  SetConsoleCursorPosition(StdOutput, xy);
  SetConsoleCtrlHandler(@consoleCtrlHandler, True);
  tw := TTimeWheel.Create(10);
  try
    tw.Add(0, 1000, showDebugInfo);
    for i := 1 to 20 do
      TThreadAddTimer.Create;

    while not g_Terminated do
    begin
      tw.MoveOn;
      Sleep(10);
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  tw.MoveOn;
  tw.Clear;
  tw.Free;
  Writeln('press ENTER to exit...');
  Readln;
  g_exited := True;
end.
