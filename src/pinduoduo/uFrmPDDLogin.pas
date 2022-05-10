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
  uContentScriptMgr,
  uSiteSsnMgr;

type
  TFrmPDDLogin = class(TCustomChromiumForm)
    CEFWindowParent1: TCEFWindowParent;
    Chromium1: TChromium;
    procedure Chromium1LoadEnd(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer);
    procedure Chromium1BeforeBrowse(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; user_gesture, isRedirect: Boolean; out Result: Boolean);
    procedure Chromium1ConsoleMessage(Sender: TObject; const browser: ICefBrowser; level: Cardinal;
      const msg, source: ustring; line: Integer; out Result: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FUsername: string;
    FScriptMgr: IContentScriptMgr;
    FContext: ICefRequestContext;
    FOnResult: TOnLoginResult;
    FSuccess: Boolean;
    procedure CheckLoginState;
  protected
    procedure CreateParams(var _Params: TCreateParams); override;
    procedure DoInitChrome; override;
  public
    class procedure LoginPDD(const _ctx: ICefRequestContext; const _ScriptMgr: IContentScriptMgr;
      const _Username: string; _OnResult: TOnLoginResult); static;
  end;

implementation

{$R *.dfm}

uses
  DSLUtils,
  DSLVclApp,
  uPinduoduo;

const
  LOGIN_URL = 'https://mobile.yangkeduo.com/login.html?from=http%3A%2F%2Fmobile.yangkeduo.com%2Fpersonal.html%3Frefer_page_name%3Dindex%26refer_page_id%3D10002_1649643580314_n3hetyc9cc%26refer_page_sn%3D10002&refer_page_name=personal'
      + '&refer_page_id=10001_1649643581939_kaqlz7rtwk&refer_page_sn=10001';

{ TFrmPDDLogin }

procedure TFrmPDDLogin.CheckLoginState;
begin
  PDDAPIGetUesrInfo(
    procedure(_UserInfo: ISuperObject)
    begin
      DbgOutput('TFrmPDDLogin.CheckLoginState: ' + _UserInfo.AsJSon(False, False));
      ExecOnMainThread(
        procedure
        begin
          if _UserInfo.S['nickname'] <> '' then
          begin
            FSuccess := True;
            _UserInfo.S[USER_NAME_KEY] := FUsername;
            FOnResult(FContext, _UserInfo);
            Self.Close;
          end
          else
            Chromium1.LoadURL(LOGIN_URL);
        end
      );
    end,
    FContext);
end;

procedure TFrmPDDLogin.Chromium1BeforeBrowse(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; user_gesture, isRedirect: Boolean; out Result: Boolean);
begin
  Result := False;
  if Pos('://mobile.yangkeduo.com/personal.html', LowerCase(request.Url)) > 0  then
  begin
    Result := True;
    CheckLoginState;
  end;
end;

procedure TFrmPDDLogin.Chromium1ConsoleMessage(Sender: TObject; const browser: ICefBrowser; level: Cardinal;
  const msg, source: ustring; line: Integer; out Result: Boolean);
var
  LUsername: string;
begin
  DbgOutput(msg);
  LUsername := ExcludePrefix(msg, '__pinduoduo_username__');
  if LUsername <> '' then
    FUsername := LUsername;
end;

procedure TFrmPDDLogin.Chromium1LoadEnd(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
var
  LUrl, LCode: string;
begin
  LUrl := LowerCase(frame.Url);
  for LCode in FScriptMgr.GetScripts(LUrl, frame.IsMain) do
    if LCode <> '' then
      frame.ExecuteJavaScript(LCode, '', 0);
  if Pos('://mobile.yangkeduo.com/login.html', LUrl) > 0 then
    frame.ExecuteJavaScript('main("' + FUsername + '")', '', 0);
end;

procedure TFrmPDDLogin.CreateParams(var _Params: TCreateParams);
begin
  inherited;
  _Params.WndParent := 0;
end;

procedure TFrmPDDLogin.DoInitChrome;
begin
  if FUsername = '' then
    Self.Caption := '拼多多登录'
  else
    Self.Caption := '拼多多登录 - ' + FUsername;
  CreateBrowser(Chromium1, CEFWindowParent1, nil, '', FContext);
end;

procedure TFrmPDDLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not FSuccess then
    FOnResult(nil, nil);
  Action := caFree;
end;

class procedure TFrmPDDLogin.LoginPDD(const _ctx: ICefRequestContext; const _ScriptMgr: IContentScriptMgr;
  const _Username: string; _OnResult: TOnLoginResult);
begin
  with TFrmPDDLogin.Create(nil) do
  begin
    FUsername := _Username;
    FContext := _ctx;
    FScriptMgr := _ScriptMgr;
    FOnResult := _OnResult;
    Chromium1.DefaultUrl := LOGIN_URL;
    Show;
  end;
end;

end.

