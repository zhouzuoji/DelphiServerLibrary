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
  uCEFChromiumEvents,
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

  TChromiumMgr = class
  private
    FForm: TCustomChromiumForm;
    FBrowserList: TList;
    FClosing: Boolean;
    function CloseBrowsers: Boolean;
  public
    constructor Create(_Form: TCustomChromiumForm);
    destructor Destroy; override;
    procedure NotifyMoveOrResizeStarted;
    procedure CreateBrowser(_Chromium: TChromium; _Window: TCEFWindowParent;
      const _TagData: UTF8String = '';
      const _WindowName : ustring = '';
      const _Context : ICefRequestContext = nil;
      const _ExtraInfo : ICefDictionaryValue = nil);
    procedure CloseBrowser(_Chromium: TChromium);
    function PrepareClose: Boolean;
  end;

  TCustomChromiumForm = class(TForm)
  private
    FShowTimes: Integer;
    FChromeInited: Boolean;
    FClosing: Boolean;
    FChromiumMgr: TChromiumMgr;
    procedure InitChrome;
    procedure WMMove(var aMessage : TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage : TMessage); message WM_MOVING;
    procedure WMEnterMenuLoop(var aMessage: TMessage); message WM_ENTERMENULOOP;
    procedure WMExitMenuLoop(var aMessage: TMessage); message WM_EXITMENULOOP;
    function GetChromiumMgr: TChromiumMgr;
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
    property ChromiumMgr: TChromiumMgr read GetChromiumMgr;
  end;

function GetBrowserTagData(const _Browser: ICefBrowser): UTF8String;
procedure SetBrowserTagData(const _Browser: ICefBrowser; const _TagData: UTF8String);

var
  WndlessChromiumMgr: TChromiumMgr;

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
    Owner: TChromiumMgr;
    State: TCefBrowserState;
    Chromium: TChromium;
    Window: TCEFWindowParent;
    TagData: UTF8String;
    Url: string;
    procedure ChromiumAfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure ChromiumClose(Sender: TObject; const browser: ICefBrowser; var aAction: TCefCloseBrowserAction);
    procedure ChromiumBeforeClose(Sender: TObject; const browser: ICefBrowser);
    procedure ChromiumBeforePopup(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame; const targetUrl,
      targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean; const popupFeatures: TCefPopupFeatures;
      var windowInfo: TCefWindowInfo; var client: ICefClient;
      var settings: TCefBrowserSettings; var extra_info: ICefDictionaryValue;
      var noJavascriptAccess, Result: Boolean);
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

procedure TCustomChromiumForm.CreateBrowser(_Chromium: TChromium; _Window: TCEFWindowParent; const _TagData: UTF8String;
  const _WindowName: ustring; const _Context: ICefRequestContext; const _ExtraInfo: ICefDictionaryValue);
begin
  ChromiumMgr.CreateBrowser(_Chromium, _Window, _TagData, _WindowName, _Context, _ExtraInfo);
end;

destructor TCustomChromiumForm.Destroy;
begin
  FChromiumMgr.Free;
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
    if not FChromiumMgr.PrepareClose then
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

function TCustomChromiumForm.GetChromiumMgr: TChromiumMgr;
begin
  if FChromiumMgr = nil then
    FChromiumMgr := TChromiumMgr.Create(Self);
  Result := FChromiumMgr;
end;

procedure TCustomChromiumForm.InitChrome;
begin
  if not FChromeInited then
  begin
    FChromeInited := True;
    DoInitChrome;
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
  FChromiumMgr.NotifyMoveOrResizeStarted;
end;

procedure TCustomChromiumForm.WMMoving(var aMessage: TMessage);
begin
  inherited;
  FChromiumMgr.NotifyMoveOrResizeStarted;
end;

{ TChromiumTab }

procedure TChromiumTab.ChromiumAfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  State := cbsCreated;
  G_TagDataLock.Acquire;
  try
    G_TagDataMap.Add(browser.Identifier, TagData);
  finally
    G_TagDataLock.Release;
  end;
end;

procedure OnBrowserClosed(_Tab: TChromiumTab; const _Browser: ICefBrowser);
var
  i: Integer;
  LOwnerForm, LMainForm: TCustomChromiumForm;
  LMgr: TChromiumMgr;
  tmp: TOnBeforePopup;
begin
  _Tab.State := cbsDestroyed;
  OutputDebugString(PChar(Format('OnBrowserClosed: %p, %s',  [Pointer(_Tab), _Tab.Url])));
  G_TagDataLock.Acquire;
  try
    G_TagDataMap.Remove(_Browser.Identifier);
  finally
    G_TagDataLock.Release;
  end;
  LMgr := _Tab.Owner;
  for i := 0 to LMgr.FBrowserList.Count - 1 do
  begin
    if LMgr.FBrowserList[i] = _Tab then
    begin
      _Tab.Chromium.OnAfterCreated := nil;
      _Tab.Chromium.OnClose := nil;
      _Tab.Chromium.OnBeforeClose := nil;
      tmp := _Tab.ChromiumBeforePopup;
      if @_Tab.Chromium.OnBeforePopup = @tmp then
        _Tab.Chromium.OnBeforePopup := nil;
      if _Tab.Chromium.Owner = nil then
        FreeAndNil(_Tab.Chromium);
      LMgr.FBrowserList.Delete(i);
      _Tab.Free;
      Break;
    end;
  end;

  LOwnerForm := LMgr.FForm;
  LMainForm := Application.MainForm as TCustomChromiumForm;

  if (LMgr.FClosing or LMainForm.FClosing) and LMgr.PrepareClose then
  begin
    if LMgr.FClosing and (LOwnerForm <> nil) and (LOwnerForm <> LMainForm) then
      FreeAndNil(LMgr.FForm);

    if (LOwnerForm = LMainForm) or (LMainForm.FClosing and LMainForm.FChromiumMgr.PrepareClose) then
      Application.Terminate;
  end;
end;

procedure TChromiumTab.ChromiumBeforeClose(Sender: TObject; const browser: ICefBrowser);
begin
  OutputDebugString(PChar(Format('ChromiumBeforeClose: %p, %s',  [Pointer(Self), Url])));
  ExecOnMainThread(
    procedure
    begin
      OnBrowserClosed(Self, browser);
    end
  );
end;

procedure TChromiumTab.ChromiumBeforePopup(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
  const targetUrl, targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
  const popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo; var client: ICefClient;
  var settings: TCefBrowserSettings; var extra_info: ICefDictionaryValue; var noJavascriptAccess, Result: Boolean);
begin
  Result := (targetDisposition in [WOD_NEW_FOREGROUND_TAB, WOD_NEW_BACKGROUND_TAB, WOD_NEW_POPUP, WOD_NEW_WINDOW]);
end;

procedure TChromiumTab.ChromiumClose(Sender: TObject; const browser: ICefBrowser;
  var aAction: TCefCloseBrowserAction);
begin
  if Self.Window <> nil then
    aAction := cbaDelay;
  Self.State := cbsDestroying;
  ExecOnMainThread(
    procedure
    begin
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

{ TChromiumMgr }

procedure TChromiumMgr.CloseBrowser(_Chromium: TChromium);
begin
  ExecOnMainThread(
    procedure
    var
      i: Integer;
      tab: TChromiumTab;
    begin
      for i := 0 to FBrowserList.Count - 1 do
      begin
        tab := TChromiumTab(FBrowserList[i]);
        if tab.Chromium = _Chromium then
        begin
          if tab.State = cbsCreated then
          begin
            tab.Url := _Chromium.Browser.MainFrame.Url;
            tab.State := cbsDestroying;
            _Chromium.CloseBrowser(True);
          end;
          Break;
        end;
      end;
    end
  );
end;

function TChromiumMgr.CloseBrowsers: Boolean;
var
  i: Integer;
  tab: TChromiumTab;
begin
  Result := True;

  for i := 0 to FBrowserList.Count - 1 do
  begin
    tab := TChromiumTab(FBrowserList[i]);
    if not (tab.State in [cbsNone, cbsDestroyed]) then
    begin
      Result := False;
      if tab.State = cbsCreated then
      begin
        tab.Url := tab.Chromium.Browser.MainFrame.Url;
        tab.State := cbsDestroying;
        tab.Chromium.CloseBrowser(True);
      end;
    end;
  end;
end;

constructor TChromiumMgr.Create(_Form: TCustomChromiumForm);
begin
  inherited Create;
  FForm := _Form;
  FBrowserList := TList.Create;
end;

procedure TChromiumMgr.CreateBrowser(_Chromium: TChromium; _Window: TCEFWindowParent; const _TagData: UTF8String;
  const _WindowName: ustring; const _Context: ICefRequestContext; const _ExtraInfo: ICefDictionaryValue);
begin
  ExecOnMainThread(
    procedure
    var
      tab: TChromiumTab;
    begin
      tab := TChromiumTab.Create;
      tab.Chromium := _Chromium;
      tab.Window := _Window;
      tab.Owner := Self;
      tab.TagData := _TagData;
      FBrowserList.Add(tab);
      _Chromium.OnAfterCreated := tab.ChromiumAfterCreated;
      _Chromium.OnClose := tab.ChromiumClose;
      _Chromium.OnBeforeClose := tab.ChromiumBeforeClose;
      if not Assigned(_Chromium.OnBeforePopup) then
        _Chromium.OnBeforePopup := tab.ChromiumBeforePopup;
      tab.State := cbsCreating;
      _Chromium.CreateBrowser(_Window, _WindowName, _Context, _ExtraInfo);
    end
  );
end;

destructor TChromiumMgr.Destroy;
begin
  FBrowserList.Free;
  inherited;
end;

procedure TChromiumMgr.NotifyMoveOrResizeStarted;
var
  i: Integer;
  tab: TChromiumTab;
begin
  if Self <> nil then
  begin
    for i := 0 to FBrowserList.Count - 1 do
    begin
      tab := TChromiumTab(FBrowserList[i]);
      if tab.State = cbsCreated then
        tab.Chromium.NotifyMoveOrResizeStarted;
    end;
  end;
end;

function TChromiumMgr.PrepareClose: Boolean;
var
  i: Integer;
  form: TCustomForm;
begin
  if Self = nil then
  begin
    Result := True;
    Exit;
  end;
  FClosing := True;
  Result := Self.CloseBrowsers;
  if FForm = Application.MainForm then
  begin
    for i := 0 to Screen.CustomFormCount - 1 do
    begin
      form := Screen.CustomForms[i];
      if form <> FForm then
      begin
        form.Hide;
        if form is TCustomChromiumForm then
        begin
          if not TCustomChromiumForm(form).FChromiumMgr.PrepareClose then
            Result := False;
        end;
      end;
    end;
    if not WndlessChromiumMgr.PrepareClose then
      Result := False;
  end;
  OutputDebugString(PChar(Format('PrepareClose: %s', [BoolToStr(Result, True)])));
end;

initialization
  ExecWhenCEFInitiaized(OnCEFInitialized);
  G_TagDataLock := TCriticalSection.Create;
  G_TagDataMap := TDictionary<Integer, UTF8String>.Create;
  WndlessChromiumMgr := TChromiumMgr.Create(nil);

finalization
  G_TagDataMap.Free;
  G_TagDataLock.Free;
  WndlessChromiumMgr.Free;

end.
