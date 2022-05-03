unit uResourceHandlerDailiyun;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  uCEFConstants,
  uCEFTypes,
  uCefStringMultimap,
  uCEFInterfaces,
  uCEFResourceHandler,
  uCEFRequest,
  uRequestTransformer;

type
  TResourceHandlerDailiyun = class(TCustomRequestTransformer)
  private
    FProxy, FCity, FSessionId: string;
  protected
    function Tranform(const _Req: ICefRequest; out _Ctx: ICefRequestContext): ICefRequest; override;
    procedure TransformRespHeader(_RespHeaders: ICefStringMultimap; cb: TProc<ICefStringMultimap>); override;
  public
    constructor Create(const browser: ICefBrowser; const frame: ICefFrame; const request: ICefRequest;
      const _Proxy, _City, _SessionId: string); reintroduce;
  end;

implementation

uses
  DSLUtils,
  DSLMimeTypes,
  uCEFUtilFunctions,
  uCEFHttpClient;

var
  G_HeaderKeyMap: TDictionary<string, string>;

{ TResourceHandlerDailiyun }

constructor TResourceHandlerDailiyun.Create(const browser: ICefBrowser; const frame: ICefFrame; const request: ICefRequest;
  const _Proxy, _City, _SessionId: string);
begin
  inherited Create(browser, frame, '', request);
  FProxy := _Proxy;
  FCity := _City;
  FSessionId := _SessionId;
end;

function TResourceHandlerDailiyun.Tranform(const _Req: ICefRequest; out _Ctx: ICefRequestContext): ICefRequest;
var
  LReq: ICefRequest;
  LUrl, LReferer, LCookie, LKey: string;
  LOldHeaders, LNewHeaders: ICefStringMultimap;
  i, j: NativeUInt;
begin
  LOldHeaders := TCefStringMultimapOwn.Create;
  _Req.GetHeaderMap(LOldHeaders);
  LNewHeaders := LOldHeaders;
  LCookie := _Req.GetHeaderByName('cookie');
  if LCookie <> '' then
  begin
    LNewHeaders := TCefStringMultimapOwn.Create;
    for i := 0 to LOldHeaders.Size - 1 do
    begin
      LKey := LOldHeaders.Key[i];
      if not SameText(LKey, 'cookie') then
        for j := 0 to LOldHeaders.FindCount(LKey) - 1 do
          LNewHeaders.Append(LKey, LOldHeaders.Enumerate[LKey, j]);
    end;
    LNewHeaders.Append('Cookiex', LCookie);
  end;
  Result := TCefRequestRef.New;
  Result.SetHeaderMap(LNewHeaders);
  LUrl := Self.Url;
  Result.Url := FProxy + '/?url=' + string(encodeURIComponent(LUrl)) + '&city=' + string(encodeURIComponent(FCity)) + '&ssnid=' + string(encodeURIComponent(FSessionId));
  Result.Method := _Req.Method;
  Result.PostData := _Req.PostData;
  Result.Flags := _Req.Flags or UR_FLAG_STOP_ON_REDIRECT;
  LReferer := _Req.ReferrerUrl;
  if LReferer <> '' then
    Result.SetReferrer(LReferer, REFERRER_POLICY_NEVER_CLEAR_REFERRER);
  _Ctx := TmpRequestContext;
end;

procedure TResourceHandlerDailiyun.TransformRespHeader(_RespHeaders: ICefStringMultimap; cb: TProc<ICefStringMultimap>);
var
  LSetCookie: string;
  i, n: Integer;
  LCookies: TList<TCookie>;
begin
  n := _RespHeaders.FindCount('set-cookiex');
  if n = 0 then
  begin
    cb(_RespHeaders);
    Exit;
  end;
  LCookies := TList<TCookie>.Create;
  LCookies.Count := n;
  for i := 0 to n - 1 do
  begin
    LSetCookie := _RespHeaders.Enumerate['set-cookiex', i];
    LCookies[i] := ParseSetCookie(LSetCookie);
  end;
  AddCookies(Browser.Host.RequestContext, Self.Url, LCookies,
    procedure
    begin
      cb(TransformStringMultimap(_RespHeaders, G_HeaderKeyMap))
    end
  );
end;

initialization
  G_HeaderKeyMap := TDictionary<string, string>.Create;
  G_HeaderKeyMap.Add('set-cookiex', '');

finalization
  G_HeaderKeyMap.Free;

end.
