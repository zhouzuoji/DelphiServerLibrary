unit uSiteSsnMgr;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Generics.Collections,
  Generics.Defaults,
  superobject,
  uCEFTypes,
  uCefTask,
  uCEFInterfaces,
  uCEFMiscFunctions,
  uCEFReqCtxMgr,
  DSLUtils;

const
  USER_NAME_KEY = '__username__';

type
  TOnLoginResult = reference to procedure(const _TmpContext, _ExistingContext, _LoginWith: ICefRequestContext; _UserInfo: ISuperObject);
  TOnCheckUsername = reference to procedure(const _Username: string; _Continue: TProc<ICefRequestContext>);

  TSiteSession = record
  public
    ctx: ICefRequestContext;
    info: ISuperObject;
  end;

  TCustomSiteSsnMgr = class
  private
    FCtxMgr: TCEFReqCtxMgr;
    FSiteKey: string;
    FSsnMap: TDictionary<string, TSiteSession>;
  protected
    // get online userinfo
    procedure UpdateUserInfo(const ctx: ICefRequestContext; cb: TProc<ISuperObject>); virtual; abstract;
    // login
    procedure DoLogin(const _Username: string; const ctx: ICefRequestContext;
      _OnResult: TOnLoginResult; _OnCheckUsername: TOnCheckUsername); virtual; abstract;
    procedure MoveCookies(const _Src, _Target: ICefRequestContext; cb: TProc); virtual; abstract;
  public
    constructor Create(const _SiteKey: string; _CtxMgr: TCEFReqCtxMgr);
    destructor Destroy; override;
    procedure NewSession(cb: TProc<ICefRequestContext, ISuperObject>);
  end;

implementation

{ TCustomSiteSsnMgr }

constructor TCustomSiteSsnMgr.Create(const _SiteKey: string; _CtxMgr: TCEFReqCtxMgr);
begin
  inherited Create;
  FCtxMgr := _CtxMgr;
  FSiteKey := _SiteKey;
  FSsnMap := TDictionary<string, TSiteSession>.Create;
end;

destructor TCustomSiteSsnMgr.Destroy;
begin
  FreeAndNil(FSsnMap);
  inherited;
end;

procedure TCustomSiteSsnMgr.NewSession(cb: TProc<ICefRequestContext, ISuperObject>);
begin
  FCtxMgr.NewTempContext(
    procedure(LTmpContext: ICefRequestContext)
    begin
      DoLogin('', LTmpContext,
        procedure(const _TmpContext, _ExisitingContext, _LoginWith: ICefRequestContext; _UserInfo: ISuperObject)
        var
          LUserName: string;
        begin
          LUserName := _UserInfo.S[USER_NAME_KEY];
          if LUserName = '' then
          begin
            if _LoginWith <> _ExisitingContext then
              FCtxMgr.ReleaseTempContext(_LoginWith);
            Exit;
          end;
          if _LoginWith <> _ExisitingContext then
          begin
            if _ExisitingContext = nil then
              FCtxMgr.RequireContext(FSiteKey, LUserName,
                procedure(_Ctx: ICefRequestContext)
                begin
                  Self.MoveCookies(_LoginWith, _Ctx, procedure begin FCtxMgr.ReleaseTempContext(_LoginWith) end);
                end)
            else
              Self.MoveCookies(_LoginWith, _ExisitingContext, procedure begin FCtxMgr.ReleaseTempContext(_LoginWith) end);
          end;
        end,
        procedure(const _Username: string; _Continue: TProc<ICefRequestContext>)
        begin
          FCtxMgr.FindContext(FSiteKey, _Username, _Continue);
        end
      );
    end
  );
end;

end.
