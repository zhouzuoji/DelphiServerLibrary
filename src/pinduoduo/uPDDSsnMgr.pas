unit uPDDSsnMgr;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Generics.Collections,
  Generics.Defaults,
  superobject,
  uCEFInterfaces,
  uCEFReqCtxMgr,
  DSLUtils,
  uContentScriptMgr,
  uSiteSsnMgr;

type
  TPDDSsnMgr = class(TCustomSiteSsnMgr)
  private
    FScriptMgr: IContentScriptMgr;
  protected
    procedure UpdateUserInfo(const ctx: ICefRequestContext; cb: TProc<ISuperObject>); override;
    procedure DoLogin(const _Username: string; const ctx: ICefRequestContext; _OnResult: TOnLoginResult); override;
    procedure MoveCookies(const _Src, _Target: ICefRequestContext; cb: TProc); override;
  public
    constructor Create(_CtxMgr: TCEFReqCtxMgr; const _ScriptMgr: IContentScriptMgr);
  end;

implementation

uses
  uCEFUtilFunctions
  ,uPinduoduo
  ,uFrmPDDLogin
  ;

{ TPDDSsnMgr }

constructor TPDDSsnMgr.Create(_CtxMgr: TCEFReqCtxMgr; const _ScriptMgr: IContentScriptMgr);
begin
  inherited Create('pinduoduo', _CtxMgr);
  FScriptMgr := _ScriptMgr;
end;

procedure TPDDSsnMgr.DoLogin;
begin
  inherited;
  TFrmPDDLogin.LoginPDD(ctx, FScriptMgr, _Username, _OnResult);
end;

procedure TPDDSsnMgr.MoveCookies;
begin
  inherited;
  CopyCookies(_Src, _Target, 'https://mobile.yangkeduo.com/personal.html', cb);
end;

procedure TPDDSsnMgr.UpdateUserInfo(const ctx: ICefRequestContext; cb: TProc<ISuperObject>);
begin
  inherited;
  PDDAPIGetUesrInfo(cb, ctx);
end;

end.
