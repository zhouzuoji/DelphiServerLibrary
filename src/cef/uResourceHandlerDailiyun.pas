unit uResourceHandlerDailiyun;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  Windows,
  superobject,
  uCEFConstants,
  uCEFTypes,
  uCefStringMultimap,
  uCEFApplication,
  uCefSchemeRegistrar,
  uCEFInterfaces,
  uCEFResourceHandler,
  uCEFMiscFunctions,
  uCEFRequest,
  uCEFUrlRequest,
  uCEFPostDataElement,
  uCEFPostData,
  uCefUrlRequestClient,
  uCEFRequestContext;

type
  TResourceHandlerDailiyun = class(TCefResourceHandlerOwn)
    private
      FBrowser: ICefBrowser;
      FFrame: ICefFrame;
      FRequest: ICefRequest;
      FProxy, FCity: string;
      FStream: TMemoryStream;
      FResp: ICefResponse;
      FRespHeaders: ICefStringMultimap;
    private
      procedure TranslateCookies(const _Url: string; _Resp: ICefResponse; cb: TProc);
    protected
      function open(const request: ICefRequest; var handle_request: boolean; const callback: ICefCallback): Boolean; override;
      procedure GetResponseHeaders(const response: ICefResponse; out responseLength: Int64; out redirectUrl: ustring); override;
      function skip(bytes_to_skip: int64; var bytes_skipped: Int64; const callback: ICefResourceSkipCallback): Boolean; override;
      function read(const data_out: Pointer; bytes_to_read: Integer; var bytes_read: Integer; const callback: ICefResourceReadCallback): boolean; override;
      procedure Cancel; override;
    public
      constructor Create(const browser: ICefBrowser; const frame: ICefFrame; const request: ICefRequest;
        const _Proxy, _City: string); reintroduce;
      destructor Destroy; override;
  end;

implementation

uses
  DSLUtils,
  DSLMimeTypes,
  uCEFUtilFunctions,
  uCEFHttpClient;

{ TResourceHandlerDailiyun }

procedure TResourceHandlerDailiyun.Cancel;
begin
  inherited;
  DbgOutput('CancelRequest: ' + FRequest.Url);
end;

constructor TResourceHandlerDailiyun.Create(const browser: ICefBrowser; const frame: ICefFrame; const request: ICefRequest;
  const _Proxy, _City: string);
begin
  inherited Create(browser, frame, '', request);
  FBrowser := browser;
  FFrame := frame;
  FRequest := request;
  FProxy := _Proxy;
  FCity := _City;
end;

destructor TResourceHandlerDailiyun.Destroy;
begin

  inherited;
end;

procedure TResourceHandlerDailiyun.GetResponseHeaders(const response: ICefResponse;
  out responseLength: Int64; out redirectUrl: ustring);
var
  i: Integer;
  LKey, LValue: string;
begin
  inherited;
  response.Error := FResp.Error;
  response.Status := FResp.Status;
  response.StatusText := FResp.StatusText;
  response.MimeType := FResp.MimeType;
  response.Charset := FResp.Charset;
  response.URL := FResp.URL;
  responseLength := FStream.Size;
  if response.Error = 0 then
  begin
    //OutputDebugString(PChar(DumpStringMultimap(FRespHeaders)));
    for i := 0 to FRespHeaders.Size - 1 do
    begin
      LKey := FRespHeaders.Key[i];
      LValue := FRespHeaders.Value[i];
      if not SameText(LKey, 'set-cookiex') then
        response.SetHeaderByName(LKey, LValue, True);
    end;
  end;
end;

{
1. To handle the request immediately set |handle_request| to true and return true.
2. To decide at a later time set |handle_request| to false, return true,
  and execute |callback| to continue or cancel the request.
3. To cancel the request immediately set |handle_request| to true and return false.
}
function TResourceHandlerDailiyun.open(const request: ICefRequest; var handle_request: boolean;
  const callback: ICefCallback): Boolean;
var
  req: ICefRequest;
  LUrl, LReferer, LCookie: string;
  LHeaders: ICefStringMultimap;
begin
  handle_request := False;
  Result := True;
  LCookie := request.GetHeaderByName('cookie');
  LHeaders := TCefStringMultimapOwn.Create;
  request.GetHeaderMap(LHeaders);
  if LCookie <> '' then
    LHeaders.Append('Cookiex', LCookie);
  req := TCefRequestRef.New;
  req.SetHeaderMap(LHeaders);
  LUrl := request.Url;
  req.Url := FProxy + '/?url=' + string(encodeURIComponent(LUrl)) + '&city=' + string(encodeURIComponent(FCity));
  req.Method := request.Method;
  req.PostData := request.PostData;
  req.Flags := request.Flags or UR_FLAG_STOP_ON_REDIRECT;
  LReferer := request.ReferrerUrl;
  if LReferer <> '' then
    req.SetReferrer(LReferer, REFERRER_POLICY_NEVER_CLEAR_REFERRER);
  FStream := TMemoryStream.Create;
  Self._AddRef;
  DoRequestAsync(req, FStream, procedure(req: ICefRequest; resp: ICefResponse; RespBody: TStream)
    begin
      FResp := resp;
      FStream.Position := 0;
      if FResp.Error = 0 then
      begin
        TranslateCookies(LUrl, resp, procedure
          begin
            callback.Cont;
            Self._Release;
          end
        );
      end
      else begin
        callback.Cont;
        Self._Release;
      end;
    end, TmpRequestContext);
end;

{Read response data. If data is available immediately copy up to |bytes_to_read|
bytes into |data_out|, set |bytes_read| to the number of bytes copied,
and return true. To read the data at a later time keep a pointer to |data_out|,
set |bytes_read| to 0, return true and execute |callback| when the data is available
(|data_out| will remain valid until the callback is executed).
To indicate response completion set |bytes_read| to 0 and return false.
To indicate failure set |bytes_read| to < 0 (e.g. -2 for ERR_FAILED) and return false.
}
function TResourceHandlerDailiyun.read(const data_out: Pointer; bytes_to_read: Integer;
  var bytes_read: Integer; const callback: ICefResourceReadCallback): boolean;
begin
  bytes_read := FStream.Read(data_out^, bytes_to_read);
  Result := bytes_read > 0;
end;

procedure TResourceHandlerDailiyun.TranslateCookies(const _Url: string; _Resp: ICefResponse; cb: TProc);
var
  i, n: Integer;
  LSetCookie: string;
  LCookies: TList<TCookie>;
begin
  FRespHeaders := TCefStringMultimapOwn.Create;
  _Resp.GetHeaderMap(FRespHeaders);
  n := FRespHeaders.FindCount('set-cookiex');
  if n = 0 then
  begin
    cb();
    Exit;
  end;
  LCookies := TList<TCookie>.Create;
  LCookies.Count := n;
  for i := 0 to n - 1 do
  begin
    LSetCookie := FRespHeaders.Enumerate['set-cookiex', i];
    LCookies[i] := ParseSetCookie(LSetCookie);
  end;
  AddCookies(FBrowser.Host.RequestContext, _Url, LCookies, cb);
end;

{Skip response data when requested by a Range header.
Skip over and discard |bytes_to_skip| bytes of response data.
If data is available immediately set |bytes_skipped| to the number of bytes skipped
and return true. To read the data at a later time set |bytes_skipped| to 0,
return true and execute |callback| when the data is available.
To indicate failure set |bytes_skipped| to < 0 (e.g. -2 for ERR_FAILED) and return false.
}
function TResourceHandlerDailiyun.skip(bytes_to_skip: int64; var bytes_skipped: Int64;
  const callback: ICefResourceSkipCallback): Boolean;
var
  n: Int64;
begin
  n := FStream.Size - FStream.Position;
  if bytes_skipped > n then
    bytes_skipped := n;
  FStream.Seek(bytes_to_skip, soCurrent);
  Result := True;
end;

end.
