program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, Windows, DSLUtils;

procedure showTime; inline;
begin
  Writeln(DateTimeToStr(Now));
end;

var
  spinLocker: TSpinLock;

type
  TThread1 = class(TThread)
  protected
    procedure Execute; override;
  end;

{ TThread }

procedure TThread1.Execute;
begin
  inherited;
  spinLocker.acquire;
  Writeln('thread1: ' + DateTimeToStr(Now));
  spinLocker.release;
end;

begin
  spinLocker.init;
  try
    showTime;
    spinLocker.acquire;
    TThread1.Create(False);
    Sleep(1000);
    showTime;

    spinLocker.acquire;
    Sleep(2000);
    showTime;

    spinLocker.release;
    Sleep(3000);
    showTime;

    spinLocker.release;
    Sleep(4000);
    showTime;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  spinLocker.cleanup;
  Readln;
end.
