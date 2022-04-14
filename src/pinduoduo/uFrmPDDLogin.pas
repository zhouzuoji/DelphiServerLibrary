unit uFrmPDDLogin;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Generics.Collections,
  Generics.Defaults,
  superobject,
  uCEFTypes,
  uCEFInterfaces,
  uCEFWinControl,
  uCEFWindowParent,
  uCEFChromiumCore,
  uCEFChromium,
  uChromiumForm,
  uSiteSsnMgr;

const
  CM_LoginWithContext = WM_USER + 1;

type
  TFrmPDDLogin = class(TCustomChromiumForm)
    CEFWindowParent1: TCEFWindowParent;
    Chromium1: TChromium;
    procedure Chromium1LoadEnd(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer);
    procedure Chromium1ConsoleMessage(Sender: TObject; const browser: ICefBrowser; level: Cardinal;
      const msg, source: ustring; line: Integer; out Result: Boolean);
    procedure Chromium1BeforeBrowse(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; user_gesture, isRedirect: Boolean; out Result: Boolean);
  private
    FUsername: string;
    FContext: ICefRequestContext;
    FExistingContext: ICefRequestContext;
    FOnResult: TOnLoginResult;
    FUsernameChecker: TOnCheckUsername;
    procedure CheckLoginState(_Ctx: ICefRequestContext);
    procedure ContinueLogin;
    procedure LoginWithContext(ctx: ICefRequestContext; _UserInfo: ISuperObject);
    procedure CheckUsername(const _Username: string);
    procedure CMLoginWithContext(var msgr: TMessage); message CM_LoginWithContext;
  protected
    procedure DoInitChrome; override;
  public
    class procedure LoginPDD(_ctx: ICefRequestContext; const _Username: string;
      _OnResult: TOnLoginResult; _OnCheckUsername: TOnCheckUsername);
  end;

implementation

{$R *.dfm}

uses
  DSLUtils, uFrmScripts, uPinduoduo;

{ TFrmPDDLogin }

procedure TFrmPDDLogin.CheckLoginState(_Ctx: ICefRequestContext);
begin
  PDDAPIGetUesrInfo(procedure(_UserInfo: ISuperObject)
    begin
      DbgOutput('TFrmPDDLogin.CheckLoginState' + _UserInfo.AsJSon(False, False));
      _Ctx._AddRef;
      _UserInfo._AddRef;
      PostMessage(Self.WindowHandle, CM_LoginWithContext, WPARAM(_Ctx), LPARAM(_UserInfo));
    end,
    _Ctx);
end;

procedure TFrmPDDLogin.CheckUsername(const _Username: string);
begin
  if not Assigned(FUsernameChecker) then
    ContinueLogin
  else
    DbgOutput(Format('TFrmPDDLogin.CheckUsername("%s")', [_Username]));
    FUsernameChecker(_Username, procedure(_Ctx: ICefRequestContext)
      begin
        DbgOutput(Format('TFrmPDDLogin.CheckUsername: ExistingContext=%p', [Pointer(_Ctx)]));
        FExistingContext := _Ctx;
        if _Ctx = nil then
          PostMessage(Self.WindowHandle, CM_LoginWithContext, 0, 0)
        else
          CheckLoginState(_Ctx);
      end
  );
end;

procedure TFrmPDDLogin.Chromium1BeforeBrowse(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; user_gesture, isRedirect: Boolean; out Result: Boolean);
begin
  if Pos('://mobile.yangkeduo.com/personal.html', request.Url) > 0  then
  begin
    CheckLoginState(FContext);
    Result := True;
  end;
end;

procedure TFrmPDDLogin.Chromium1ConsoleMessage(Sender: TObject; const browser: ICefBrowser;
  level: Cardinal; const msg, source: ustring; line: Integer; out Result: Boolean);
var
  LUsername: string;
begin
  LUsername := ExcludePrefix(msg, '__pinduoduo_username__');
  if LUsername <> '' then
  begin
    FUsername := LUsername;
    CheckUsername(LUsername);
    Exit;
  end;
end;

procedure TFrmPDDLogin.Chromium1LoadEnd(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
var
  url: string;
begin
  url := frame.Url;
  if (Pos('://mobile.yangkeduo.com/login.html', URL) > 0) or
    (Pos('://mobile.pinduoduo.com/login.html', URL) > 0) then
  begin
    frame.ExecuteJavaScript(ScriptPDDLogin, '', 0);
    frame.ExecuteJavaScript(Format('main("%s")', [FUsername]), '', 0);
  end;
end;

procedure TFrmPDDLogin.CMLoginWithContext(var msgr: TMessage);
var
  LCtx: ICefRequestContext;
  LUserInfo: ISuperObject;
begin
  WPARAM(LCtx) := msgr.WParam;
  LPARAM(LUserInfo) := msgr.LParam;
  LoginWithContext(LCtx, LUserInfo);
end;

procedure TFrmPDDLogin.ContinueLogin;
begin
  Chromium1.ExecuteJavaScript('allowLogin()', '');
end;

procedure TFrmPDDLogin.DoInitChrome;
begin
  if FUsername = '' then
    Self.Caption := '拼多多登录'
  else
    Self.Caption := '拼多多登录 - ' + FUsername;
  Chromium1.DefaultUrl := 'https://mobile.yangkeduo.com/login.html?from=http%3A%2F%2Fmobile.yangkeduo.com%2Fpersonal.html%3Frefer_page_name%3Dindex%26refer_page_id%3D10002_1649643580314_n3hetyc9cc%26refer_page_sn%3D10002&refer_page_name=personal'
    + '&refer_page_id=10001_1649643581939_kaqlz7rtwk&refer_page_sn=10001';
  CreateBrowser(Chromium1, CEFWindowParent1, '', FContext);
end;

class procedure TFrmPDDLogin.LoginPDD(_ctx: ICefRequestContext; const _Username: string;
  _OnResult: TOnLoginResult; _OnCheckUsername: TOnCheckUsername);
begin
  with TFrmPDDLogin.Create(Application) do
  begin
    FUsername := _Username;
    FContext := _ctx;
    FOnResult := _OnResult;
    FUsernameChecker := _OnCheckUsername;
    Show;
  end;
end;

procedure TFrmPDDLogin.LoginWithContext(ctx: ICefRequestContext; _UserInfo: ISuperObject);
begin
  if ctx = nil then
    ContinueLogin
  else begin
    if _UserInfo.S['nickname'] <> '' then
    begin
      _UserInfo.S[USER_NAME_KEY] := FUsername;
      FOnResult(FContext, FExistingContext, ctx, _UserInfo);
      Self.Close;
    end
    else
      ContinueLogin;
  end;
end;

initialization

finalization

end.

