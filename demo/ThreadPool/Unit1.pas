unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DSLUtils, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FThreadPool: TThreadPool;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

type
  TTestRunnable = class(TRunnable)
  private
    FSleepSeconds: DWORD;
  public
    constructor Create(_SleepSeconds: DWORD);
    procedure run(context: TObject); override;
  end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FThreadPool := TThreadPool.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FThreadPool.Free;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Edit1.Text := IntToStr(FThreadPool.RunningCount);
  Edit2.Text := IntToStr(FThreadPool.FreeCount);
  Edit3.Text := IntToStr(FThreadPool.TaskCount);
  FThreadPool.execute(TTestRunnable.Create(Random(10)));
end;

{ TTestRunnable }

constructor TTestRunnable.Create(_SleepSeconds: DWORD);
begin
  inherited Create;
  FSleepSeconds := _SleepSeconds;
end;

procedure TTestRunnable.run(context: TObject);
begin
  inherited;
  Writeln('sleep ', FSleepSeconds , ' seconds...');
  Sleep(FSleepSeconds * 1000);
  Writeln(FSleepSeconds , ' seconds sleep over.');
end;

end.
