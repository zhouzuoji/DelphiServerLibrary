unit uChromiumForm;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  Windows,
  Messages,
  Variants,
  Controls,
  Forms,
  uCEFWinControl,
  uCEFWindowParent,
  uCEFChromiumCore,
  uCEFChromium,
  uCEFInterfaces,
  uCEFTypes,
  uCEFConstants,
  uCEFApplication,
  uCEFRequest,
  uCEFRequestContext,
  superobject;

const
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
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure DoShow; override;
    procedure DoFirstShow; virtual;
    procedure DoInitChrome; virtual;
  public
    destructor Destroy; override;
    procedure CreateBrowser(_Chromium: TChromium; _Window: TCEFWindowParent;
      const _TagData: UTF8String = '';
      const _WindowName : ustring = '';
      const _Context : ICefRequestContext = nil;
      const _ExtraInfo : ICefDictionaryValue = nil);
    procedure CloseBrowser(_Chromium: TChromium);
  end;

function GetBrowserTagData(const _Browser: ICefBrowser): UTF8String;
procedure SetBrowserTagData(const _Browser: ICefBrowser; const _TagData: UTF8String);

implementation

uses
  SyncObjs,
  DSLVclApp,
  uCEFUtilFunctions;

var
  G_TagDataLock: TSynchroObject;
  G_TagDataMap: TDictionary<Integer, UTF8String>;

type
  TChromiumTab = class
    State: TCefBrowserState;
    Chromium: TChromium;
    Window: TCEFWindowParent;
    Form: TCustomChromiumForm;
    TagData: UTF8String;
    procedure ChromiumAfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure ChromiumClose(Sender: TObject; const browser: ICefBrowser; var aAction: TCefCloseBrowserAction);
    procedure ChromiumBeforeClose(Sender: TObject; const browser: ICefBrowser);
  end;

function GetBrowserTagData(const _Browser: ICefBrowser): UTF8String;
begin
  G_TagDataLock.Acquire;
  try
    G_TagDataMap.TryGetValue(_Browser.Identifier, Result);
  finally
    G_TagDataLock.Release;
  end;
  if Result = '' then
    Result := 'null';
end;

procedure SetBrowserTagData(const _Browser: ICefBrowser; const _TagData: UTF8String);
begin
  G_TagDataLock.Acquire;
  try
    G_TagDataMap.AddOrSetValue(_Browser.Identifier, _TagData);
  finally
    G_TagDataLock.Release;
  end;
end;

{ TCustomChromiumForm }

procedure TCustomChromiumForm.CloseBrowser(_Chromium: TChromium);
var
  i: Integer;
  tab: TChromiumTab;
begin
  if FBrowserList = nil then Exit;

  for i := 0 to FBrowserList.Count - 1 do
  begin
    tab := TChromiumTab(FBrowserList[i]);
    if tab.Chromium = _Chromium then
    begin
      if tab.State = cbsCreated then
      begin
        tab.State := cbsDestroying;
        _Chromium.CloseBrowser(True);
      end;
      Break;
    end;
  end;
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
  tab.TagData := _TagData;
  if FBrowserList = nil then
    FBrowserList := TList.Create;
  FBrowserList.Add(tab);
  _Chromium.OnAfterCreated := tab.ChromiumAfterCreated;
  _Chromium.OnClose := tab.ChromiumClose;
  _Chromium.OnBeforeClose := tab.ChromiumBeforeClose;
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

procedure TChromiumTab.ChromiumAfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  G_TagDataLock.Acquire;
  try
    G_TagDataMap.Add(browser.Identifier, TagData);
  finally
    G_TagDataLock.Release;
  end;
  State := cbsCreated;
end;

procedure OnBrowserClosed(_Form: TCustomChromiumForm; _Tab: TChromiumTab; const _Browser: ICefBrowser);
var
  i: Integer;
  LMainForm: TCustomChromiumForm;
begin
  G_TagDataLock.Acquire;
  try
    G_TagDataMap.Remove(_Browser.Identifier);
  finally
    G_TagDataLock.Release;
  end;

  for i := 0 to _Form.FBrowserList.Count - 1 do
  begin
    if _Form.FBrowserList[i] = _Tab then
    begin
      _Tab.Chromium.OnAfterCreated := nil;
      _Tab.Chromium.OnClose := nil;
      _Tab.Chromium.OnBeforeClose := nil;
      _Form.FBrowserList.Delete(i);
      _Tab.Free;
      Break;
    end;
  end;

  LMainForm := Application.MainForm as TCustomChromiumForm;
  if (_Form.FClosing or LMainForm.FClosing) and _Form.PrepareClose then
  begin
    if _Form = LMainForm then
      Application.Terminate
    else if LMainForm.FClosing and LMainForm.PrepareClose then
      Application.Terminate;
  end;
end;

procedure TChromiumTab.ChromiumBeforeClose(Sender: TObject; const browser: ICefBrowser);
begin
  Self.State := cbsDestroyed;
  ExecOnMainThread(
    procedure
    begin
      OnBrowserClosed(Form, Self, browser);
    end
  );
end;

procedure TChromiumTab.ChromiumClose(Sender: TObject; const browser: ICefBrowser;
  var aAction: TCefCloseBrowserAction);
begin
  if Self.Window <> nil then
    aAction := cbaDelay;
  ExecOnMainThread(
    procedure
    begin
      if Self.Window = nil then
        OnBrowserClosed(Form, Self, browser)
      else
        FreeAndNil(Self.Window);
    end
  );
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
  G_TagDataLock := TCriticalSection.Create;
  G_TagDataMap := TDictionary<Integer, UTF8String>.Create;

finalization
  G_TagDataMap.Free;
  G_TagDataLock.Free;

end.
