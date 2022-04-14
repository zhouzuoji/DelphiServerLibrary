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
  uSiteSsnMgr;

type
  TPDDSsnMgr = class(TCustomSiteSsnMgr)
  protected
    procedure UpdateUserInfo(const ctx: ICefRequestContext; cb: TProc<ISuperObject>); override;
    procedure DoLogin(const _Username: string; const ctx: ICefRequestContext; _OnResult: TOnLoginResult; _OnCheckUsername: TOnCheckUsername); override;
    procedure MoveCookies(const _Src, _Target: ICefRequestContext; cb: TProc); override;
  end;

implementation

uses
  uCEFUtilFunctions
  ,uPinduoduo
  ,uFrmPDDLogin
  ;

{ TPDDSsnMgr }

procedure TPDDSsnMgr.DoLogin;
begin
  inherited;
  TFrmPDDLogin.LoginPDD(ctx, _Username, _OnResult, _OnCheckUsername);
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
