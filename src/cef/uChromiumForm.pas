unit uChromiumForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Contnrs, SyncObjs, Generics.Collections, Generics.Defaults,
  uCEFWinControl, uCEFWindowParent, uCEFChromiumCore, uCEFChromium, uCEFStringMultimap,
  uCEFInterfaces, uCEFTypes, uCEFConstants, uCEFApplication, uCEFRequest, uCEFResponse,
  uCEFRequestContext, uCEFMiscFunctions, uCefv8Value, uCefV8Accessor, uCEFChromiumEvents;

const
  UM_WINDOW_CLOSED = WM_USER + 2;
  UM_CHROMIUM_CLOSED = WM_USER + 3;

  BLANK_URL = 'about:blank';

type
  TCefBrowserState = (cbsNone, cbsCreating, cbsCreated, cbsDestroying, cbsDestroyed);

  TCustomChromiumForm = class;

  TCustomChromiumForm = class(TForm)
  private
    FShowTimes: Integer;
    FChromeInited: Boolean;
    FClosing: Boolean;
    FBrowserList: TList;
    function PrepareClose: Boolean;
    function CloseBrowsers: Boolean;
    procedure InitChrome;
    procedure NotifyMoveOrResizeStarted;
    procedure WMMove(var aMessage : TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage : TMessage); message WM_MOVING;
    procedure WMEnterMenuLoop(var aMessage: TMessage); message WM_ENTERMENULOOP;
    procedure WMExitMenuLoop(var aMessage: TMessage); message WM_EXITMENULOOP;
    procedure UMWindowClosed(var msgr: TMessage); message UM_WINDOW_CLOSED;
    procedure UMChromiumClosed(var msgr: TMessage); message UM_CHROMIUM_CLOSED;
    procedure CEFDestroy(var msgr: TMessage); message CEF_DESTROY;
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure DoShow; override;
    procedure DoFirstShow; virtual;
    procedure DoInitChrome; virtual;
  public
    destructor Destroy; override;
    procedure CreateBrowser(_Chromium: TChromium; _Window: TCEFWindowParent;
      const _WindowName : ustring = '';
      const _Context : ICefRequestContext = nil;
      const _ExtraInfo : ICefDictionaryValue = nil);
  end;

implementation

uses
  uCEFUtilFunctions, DSLVclApp;

type
  TChromiumTab = class
    State: TCefBrowserState;
    Chromium: TChromium;
    Window: TCEFWindowParent;
    Form: TCustomChromiumForm;
    procedure ChromiumAfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure ChromiumClose(Sender: TObject; const browser: ICefBrowser; var aAction: TCefCloseBrowserAction);
    procedure ChromiumBeforeClose(Sender: TObject; const browser: ICefBrowser);
    procedure ChromiumMainFrameChanged(Sender: TObject;
      const browser: ICefBrowser; const old_frame, new_frame: ICefFrame);
    procedure ChromiumAddressChange(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
    procedure ChromiumLoadEnd(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer);
    procedure ChromiumJsdialog(Sender: TObject; const browser: ICefBrowser;
      const originUrl: ustring; dialogType: TCefJsDialogType; const messageText,
      defaultPromptText: ustring; const callback: ICefJsDialogCallback;
      out suppressMessage, Result: Boolean);
    procedure ChromiumConsoleMessage(Sender: TObject;
      const browser: ICefBrowser; level: Cardinal; const msg,
      source: ustring; line: Integer; out Result: Boolean);
    procedure ChromiumFrameDetached(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame);
    procedure ChromiumFrameAttached(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame; reattached: Boolean);
  end;

{ TCustomChromiumForm }

procedure TCustomChromiumForm.CEFDestroy(var msgr: TMessage);
begin
  FreeAndNil(TChromiumTab(msgr.LParam).Window);
end;

function TCustomChromiumForm.CloseBrowsers: Boolean;
var
  i: Integer;
  tab: TChromiumTab;
begin
  Result := True;
  if FBrowserList = nil then Exit;

  for i := 0 to FBrowserList.Count - 1 do
  begin
    tab := TChromiumTab(FBrowserList[i]);
    if not (tab.State in [cbsNone, cbsDestroyed]) then
    begin
      Result := False;
      if tab.State = cbsCreated then
      begin
        tab.State := cbsDestroying;
        tab.Chromium.CloseBrowser(True);
      end;
    end;
  end;
end;

procedure TCustomChromiumForm.CreateBrowser;
var
  tab: TChromiumTab;
begin
  tab := TChromiumTab.Create;
  tab.Chromium := _Chromium;
  tab.Window := _Window;
  tab.Form := Self;
  if FBrowserList = nil then
    FBrowserList := TList.Create;
  FBrowserList.Add(tab);
  _Chromium.OnAfterCreated := tab.ChromiumAfterCreated;
  _Chromium.OnClose := tab.ChromiumClose;
  _Chromium.OnBeforeClose := tab.ChromiumBeforeClose;
  _Chromium.OnFrameDetached := tab.ChromiumFrameDetached;
  tab.State := cbsCreating;
  _Chromium.CreateBrowser(_Window, _WindowName, _Context, _ExtraInfo);
end;

destructor TCustomChromiumForm.Destroy;
begin
  FBrowserList.Free;
  inherited;
end;

procedure TCustomChromiumForm.DoClose(var Action: TCloseAction);
begin
  inherited;

  if Action = caNone then
    Exit;
  if (Application.MainForm = Self) or (Action = caFree) then
  begin
    FClosing := True;
    if not PrepareClose then
    begin
      if fsModal in Self.FormState then
        Action := caHide
      else begin
        Action := caNone;
        Self.Hide;
      end;
    end;
  end;
end;

procedure TCustomChromiumForm.DoFirstShow;
begin

end;

procedure TCustomChromiumForm.DoInitChrome;
begin

end;

procedure TCustomChromiumForm.DoShow;
begin
  inherited;
  Inc(FShowTimes);
  if FShowTimes = 1 then
  begin
    if IsCEFInitialized then
      InitChrome;
    DoFirstShow;
  end;
end;

procedure TCustomChromiumForm.InitChrome;
begin
  if not FChromeInited then
  begin
    FChromeInited := True;
    DoInitChrome;
  end;
end;

procedure TCustomChromiumForm.NotifyMoveOrResizeStarted;
var
  i: Integer;
  tab: TChromiumTab;
begin
  if FBrowserList = nil then Exit;

  for i := 0 to FBrowserList.Count - 1 do
  begin
    tab := TChromiumTab(FBrowserList[i]);
    if tab.State = cbsCreated then
      tab.Chromium.NotifyMoveOrResizeStarted;
  end;
end;

function TCustomChromiumForm.PrepareClose: Boolean;
var
  i: Integer;
  form: TCustomForm;
  ccf: TCustomChromiumForm;
begin
  Result := True;
  if not CloseBrowsers then
    Result := False;
  if Self = Application.MainForm then
  begin
    for i := 0 to Screen.CustomFormCount - 1 do
    begin
      form := Screen.CustomForms[i];
      if form <> Self then
      begin
        form.Hide;
        if form is TCustomChromiumForm then
        begin
          ccf := TCustomChromiumForm(form);
          if not ccf.PrepareClose then
            Result := False;
        end;
      end;
    end;
  end;
end;

procedure TCustomChromiumForm.UMChromiumClosed(var msgr: TMessage);
begin
  if (FClosing or TCustomChromiumForm(Application.MainForm).FClosing) and PrepareClose then
  begin
    if Self = Application.MainForm then
      Application.Terminate
    else
      PostMessage(Application.MainForm.Handle, UM_WINDOW_CLOSED, 0, 0);
  end;
end;

procedure TCustomChromiumForm.UMWindowClosed(var msgr: TMessage);
begin
  if not FClosing then Exit;

  if (Application.MainForm = Self) and PrepareClose then
    Application.Terminate;
end;

procedure TCustomChromiumForm.WMEnterMenuLoop(var aMessage: TMessage);
begin
  inherited;
  if (aMessage.wParam = 0) and (GlobalCEFApp <> nil) then GlobalCEFApp.OsmodalLoop := True;
end;

procedure TCustomChromiumForm.WMExitMenuLoop(var aMessage: TMessage);
begin
  inherited;
  if (aMessage.wParam = 0) and (GlobalCEFApp <> nil) then GlobalCEFApp.OsmodalLoop := False;
end;

procedure TCustomChromiumForm.WMMove(var aMessage: TWMMove);
begin
  inherited;
  NotifyMoveOrResizeStarted;
end;

procedure TCustomChromiumForm.WMMoving(var aMessage: TMessage);
begin
  inherited;
  NotifyMoveOrResizeStarted;
end;

{ TChromiumTab }

procedure TChromiumTab.ChromiumAddressChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
begin

end;

procedure TChromiumTab.ChromiumAfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  State := cbsCreated;
end;

procedure TChromiumTab.ChromiumBeforeClose(Sender: TObject; const browser: ICefBrowser);
begin
  Self.State := cbsDestroyed;
  if Form.FClosing or TCustomChromiumForm(Application.MainForm).FClosing then
    PostMessage(Form.Handle, UM_CHROMIUM_CLOSED, 0, LPARAM(Self));
end;

procedure TChromiumTab.ChromiumClose(Sender: TObject; const browser: ICefBrowser;
  var aAction: TCefCloseBrowserAction);
begin
  PostMessage(Form.Handle, CEF_DESTROY, 0, LPARAM(Self));
  aAction := cbaDelay;
end;

procedure TChromiumTab.ChromiumConsoleMessage(Sender: TObject;
  const browser: ICefBrowser; level: Cardinal; const msg, source: ustring;
  line: Integer; out Result: Boolean);
begin

end;

procedure TChromiumTab.ChromiumFrameAttached(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; reattached: Boolean);
begin

end;

procedure TChromiumTab.ChromiumFrameDetached(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame);
begin

end;

procedure TChromiumTab.ChromiumJsdialog(Sender: TObject;
  const browser: ICefBrowser; const originUrl: ustring;
  dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
  const callback: ICefJsDialogCallback; out suppressMessage, Result: Boolean);
begin

end;

procedure TChromiumTab.ChromiumLoadEnd(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
begin

end;

procedure TChromiumTab.ChromiumMainFrameChanged(Sender: TObject;
  const browser: ICefBrowser; const old_frame, new_frame: ICefFrame);
begin

end;

procedure OnCEFInitialized;
begin
  ExecOnMainThread(
    procedure
    var
      i: Integer;
      f: TCustomForm;
    begin
      for i := 0 to Screen.CustomFormCount - 1 do
      begin
        f := Screen.CustomForms[i];
        if f is TCustomChromiumForm then
          with TCustomChromiumForm(f) do
            if FShowTimes >= 1 then
              InitChrome;
      end;
    end
  );
end;

initialization
  ExecWhenCEFInitiaized(OnCEFInitialized);

end.
