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
  TOnLoginResult = reference to procedure(const _TmpContext: ICefRequestContext; _UserInfo: ISuperObject);

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
    procedure DoLogin(const _Username: string; const ctx: ICefRequestContext; _OnResult: TOnLoginResult); virtual; abstract;
    procedure MoveCookies(const _Src, _Target: ICefRequestContext; cb: TProc); virtual; abstract;
  public
    constructor Create(const _SiteKey: string; _CtxMgr: TCEFReqCtxMgr);
    destructor Destroy; override;
    procedure NewSession(const _Username: string; cb: TProc<ICefRequestContext, ISuperObject>);
  end;

implementation

uses
  DSLVclApp,
  uCEFUtilFunctions;

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

procedure TCustomSiteSsnMgr.NewSession(const _Username: string; cb: TProc<ICefRequestContext, ISuperObject>);
begin
  CreateTempRequestContext(
    procedure(LTmpContext: ICefRequestContext)
    begin
      ExecOnMainThread(
        procedure
        begin
          DoLogin(_Username, LTmpContext,
            procedure(const _: ICefRequestContext; _UserInfo: ISuperObject)
            var
              LUserName: string;
            begin
              if _UserInfo = nil then
                cb(nil, nil)
              else begin
                LUserName := _UserInfo.S[USER_NAME_KEY];
                if LUserName <> '' then
                  FCtxMgr.RequireContext(FSiteKey, LUserName,
                    procedure(_Ctx: ICefRequestContext)
                    begin
                      Self.MoveCookies(LTmpContext, _Ctx, procedure begin cb(_Ctx, _UserInfo); end);
                    end
                  )
                else
                  cb(nil, nil);
              end;
            end
          );
        end
      )
    end
  );
end;

end.
