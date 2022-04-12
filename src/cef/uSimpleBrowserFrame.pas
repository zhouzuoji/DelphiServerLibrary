unit uSimpleBrowserFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, uCEFWinControl, uCEFWindowParent,
  uCEFChromiumCore, uCEFChromium, Generics.Collections, Generics.Defaults, superobject,
  uCEFTypes, uChromiumForm, uCEFInterfaces;

type
  TSimpleBrowserFrame = class(TFrame)
    CEFWindowParent1: TCEFWindowParent;
    Panel1: TPanel;
    edtURL: TLabeledEdit;
    Button1: TButton;
    Button3: TButton;
    Button2: TButton;
    txtConsole: TMemo;
    txtScript: TMemo;
    Chromium1: TChromium;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Chromium1ConsoleMessage(Sender: TObject; const browser: ICefBrowser;
      level: Cardinal; const msg, source: ustring; line: Integer; out Result: Boolean);
    procedure Chromium1AddressChange(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  StrUtils, uCEFExtPolyfill, uFrmScripts;

{$R *.dfm}

function DbgOutput(const s: string): Boolean;
begin
  if GetCurrentThreadId <> MainThreadID then
    OutputDebugString(PChar('[' + IntToStr(GetCurrentThreadId) + '<>' + IntToStr(MainThreadID) + ']' + s))
  else
    OutputDebugString(PChar(s));
  Result := True;
end;

{ TSimpleBrowserFrame }

procedure TSimpleBrowserFrame.Button1Click(Sender: TObject);
begin
  Chromium1.LoadURL(edtURL.Text);
end;

procedure TSimpleBrowserFrame.Button2Click(Sender: TObject);
var
  pt: TPoint;
begin
  pt.X := 0;
  pt.Y := 100;
  Chromium1.ShowDevTools(pt, nil);
end;

procedure TSimpleBrowserFrame.Button3Click(Sender: TObject);
begin
  Chromium1.ExecuteJavaScript(txtScript.Lines.Text, 'about:blank');
end;

procedure TSimpleBrowserFrame.Chromium1AddressChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
begin
  edtURL.Text := url;
end;

procedure TSimpleBrowserFrame.Chromium1ConsoleMessage;
begin
  DbgOutput('ConsoleMessage: ' + source + ' => ' + msg);
  txtConsole.Lines.Add(msg);
  FilterConsoleMessage(browser, msg);
end;

end.
