program ThreadPool;

uses
  Forms,
  SysUtils,
  Unit1 in 'Unit1.pas' {Form1};

{$APPTYPE CONSOLE}
{$R *.res}

begin
  RandSeed := Round(Now * 24 * 3600);
  Randomize;
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
