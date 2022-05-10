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
  uRequestTransformer,
  uCEFHttpClient;

type
  TResourceHandlerDailiyun = class(TCustomRequestTransformer)
  private
    FProxy, FCity, FSessionId: string;
  protected
    function Tranform(const _Req: ICefRequest): TCEFHttpRequest; override;
    procedure TransformRespHeader(_RespHeaders: ICefStringMultimap; cb: TProc<ICefStringMultimap>); override;
  public
    constructor Create(const browser: ICefBrowser; const frame: ICefFrame; const request: ICefRequest;
      const _Proxy, _City, _SessionId: string); reintroduce;
  end;

implementation

uses
  DSLUtils,
  DSLMimeTypes,
  uCEFUtilFunctions;

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

function TResourceHandlerDailiyun.Tranform(const _Req: ICefRequest): TCEFHttpRequest;
var
  LUrl, LNewUrl, LCookie, LKey: string;
  LOldHeaders: ICefStringMultimap;
  i, j: NativeUInt;
begin
  Result.Clear;
  LUrl := Self.Url;
  LNewUrl := FProxy + '/?url=' + string(encodeURIComponent(LUrl)) + '&city=' + string(encodeURIComponent(FCity)) + '&ssnid=' + string(encodeURIComponent(FSessionId));
  Result := TCEFHttpRequest.Create(LNewUrl).Method(_Req.Method).NoRedirect.Referer(_Req.ReferrerUrl).WithContext(TmpRequestContext);
  LOldHeaders := TCefStringMultimapOwn.Create;
  _Req.GetHeaderMap(LOldHeaders);
  LCookie := _Req.GetHeaderByName('cookie');
  if LCookie <> '' then
  begin
    for i := 0 to LOldHeaders.Size - 1 do
    begin
      LKey := LOldHeaders.Key[i];
      if not SameText(LKey, 'cookie') then
        for j := 0 to LOldHeaders.FindCount(LKey) - 1 do
          Result.AddHeader(LKey, LOldHeaders.Enumerate[LKey, j]);
    end;
    Result.AddHeader('Cookiex', LCookie);
  end
  else
    Result.Headers := LOldHeaders;
  Result.PostData(_Req.PostData, '');
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
