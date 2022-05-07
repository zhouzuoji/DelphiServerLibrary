unit uSimpleBrowserFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, uCEFWinControl, uCEFWindowParent,
  uCEFChromiumCore, uCEFChromium, Generics.Collections, Generics.Defaults, superobject,
  uCEFConstants, uCEFTypes, uChromiumForm, uCEFInterfaces;

type
  TSimpleBrowserFrame = class(TFrame)
    Window: TCEFWindowParent;
    Panel1: TPanel;
    edtURL: TLabeledEdit;
    Button1: TButton;
    Button3: TButton;
    Button2: TButton;
    txtConsole: TMemo;
    txtScript: TMemo;
    Browser: TChromium;
    Button4: TButton;
    Button5: TButton;
    BrowserContainer: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure BrowserConsoleMessage(Sender: TObject; const browser: ICefBrowser;
      level: Cardinal; const msg, source: ustring; line: Integer; out Result: Boolean);
    procedure BrowserAddressChange(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  StrUtils,
  DSLVclApp;

{$R *.dfm}

{ TSimpleBrowserFrame }

procedure TSimpleBrowserFrame.Button1Click(Sender: TObject);
begin
  Browser.DecZoomStep;
end;

procedure TSimpleBrowserFrame.Button2Click(Sender: TObject);
var
  pt: TPoint;
begin
  pt.X := 0;
  pt.Y := 100;
  Browser.ShowDevTools(pt, nil);
end;

procedure TSimpleBrowserFrame.Button3Click(Sender: TObject);
begin
  Browser.ExecuteJavaScript(txtScript.Lines.Text, 'about:blank');
end;

procedure TSimpleBrowserFrame.Button4Click(Sender: TObject);
begin
  Browser.LoadURL(edtURL.Text);
end;

procedure TSimpleBrowserFrame.Button5Click(Sender: TObject);
begin
  Browser.IncZoomStep;
end;

procedure TSimpleBrowserFrame.BrowserAddressChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
begin
  ExecOnMainThread(procedure begin edtURL.Text := url; end);
end;

procedure TSimpleBrowserFrame.BrowserConsoleMessage;
begin
  ExecOnMainThread(procedure begin txtConsole.Lines.Add(msg); end);
end;

end.
