unit uCEFHttpClient;

interface

uses
  SysUtils, Classes, Windows, Forms, Generics.Collections, Generics.Defaults,
  uCEFTypes, uCEFInterfaces, uCEFLibFunctions, uCEFMiscFunctions, uCEFRequest, uCEFUrlRequest,
  uCEFBaseRefCounted, uCefUrlRequestClient, uCEFRequestContext, uCEFTask, uCefStringMultimap,
  uCEFConstants, uCEFPostDataElement, uCEFPostData, DSLUtils, DSLHttp, DSLMimeTypes;

type
  THttpResponseHandler = reference to procedure(req: ICefRequest; resp: ICefResponse; RespBody: TStream);
  THttpResponse = record
    resp: ICefResponse;
    body: TMemoryStream;
    function AsUTF16: string;
    function AsUTF8: UTF8String;
    function AsRawBytes: RawByteString;
  end;

function HttpGet(const _url: string; const _referrer: string = ''; ctx: ICefRequestContext = nil): string;
function HttpPost(const _url: string; const _data: IMimeData; const _referrer: string = ''; ctx: ICefRequestContext = nil): string;
procedure HttpGetAsync(const _url: string; handler: THttpResponseHandler; const _referrer: string = ''; ctx: ICefRequestContext = nil);
procedure HttpPostAsync(const _url: string; const _data: IMimeData; handler: THttpResponseHandler;
  const _referrer: string = '';  ctx: ICefRequestContext = nil);

function WaitForRequest(const req: ICefRequest; ctx: ICefRequestContext = nil): THttpResponse;
procedure DoRequestAsync(const req: ICefRequest; RespBody: TStream; handler: THttpResponseHandler; ctx: ICefRequestContext = nil); overload;
procedure DoRequestAsync(const req: ICefRequest; const client: ICefUrlRequestClient; ctx: ICefRequestContext = nil); overload;
function GetRespHeader(resp: ICefResponse): string;
function GetRespText(resp: ICefResponse; body: TStream): string;
function GetRespTextUTF8(resp: ICefResponse; body: TStream): UTF8String;

implementation

uses
  uChromiumForm;

type
  TCefUrlRequestClient = class(TCefUrlRequestClientOwn)
  private
    FRespBody: TStream;
    FOwnedBody: Boolean;
    FHandler: THttpResponseHandler;
    procedure StreamRequired;
    procedure OnRequestComplete(const request: ICefUrlRequest); override;
    procedure OnDownloadData(const request: ICefUrlRequest; data: Pointer; dataLength: NativeUInt); override;
    function  OnGetAuthCredentials(isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean; override;
  public
    constructor Create(_Content: TStream; _Handler: THttpResponseHandler); reintroduce;
    destructor Destroy; override;
  end;

  TCefUrlRequestClientSync = class(TCefUrlRequestClientOwn)
  private
    FRespBody: TStream;
    FOwnedBody: Boolean;
    FSignal: THandle;
    procedure StreamRequired;
    procedure OnRequestComplete(const request: ICefUrlRequest); override;
    procedure OnDownloadData(const request: ICefUrlRequest; data: Pointer; dataLength: NativeUInt); override;
  public
    constructor Create(_Content: TStream; _Signal: THandle); reintroduce;
    destructor Destroy; override;
  end;

function _encodeURLComponent(const s: string): string;
begin
  Result := string(encodeURIComponent(s));
end;

procedure AddChromiumHeaders(r: ICefRequest);
begin
  r.SetHeaderByName('Sec-Fetch-Mode', 'cors', True);
  r.SetHeaderByName('sec-ch-ua', '" Not A;Brand";v="99", "Chromium";v="99", "Microsoft Edge";v="99"', True);
  r.SetHeaderByName('sec-ch-ua-mobile', '?0', True);
  r.SetHeaderByName('sec-ch-ua-platform', '"Windows"', True);
end;

function GetRespHeader(resp: ICefResponse): string;
var
  headers: ICefStringMultimap;
  i: Integer;
begin
  if (resp.Error <> 0) and (resp.Status = 0) then
    Result := 'CEF HTTP error ' + IntToStr(resp.Error)
  else begin
    Result := 'HTTP/1.1 ' + IntToStr(resp.Status) + resp.StatusText;
    headers := TCefStringMultimapOwn.Create;
    resp.GetHeaderMap(headers);
    for i := 0 to headers.Size - 1 do
      Result := Result + #13#10 + headers.Key[i] + ': ' + headers.Value[i];
  end;
end;

function GetRespText(resp: ICefResponse; body: TStream): string;
var
  charset: string;
  cp: Integer;
  s: RawByteString;
begin
  Result := '';
  if (resp.Error <> 0) and (resp.Status = 0) then
    raise Exception.CreateFmt('CEF HTTP error %d', [resp.Error]);
  if body.Size > 0 then
  begin
    charset := resp.Charset;
    if charset = '' then
      cp := CP_UTF8
    else
      cp := CodePageName2ID(AnsiString(charset));
    if body is TMemoryStream then
      Result := BufToUnicode(TMemoryStream(body).Memory, body.Size, cp)
    else begin
      SetLength(s, body.Size);
      body.ReadBuffer(Pointer(s)^, Length(s));
      Result := RBStrToUnicode(s, cp);
    end;
  end;
end;

function GetRespTextUTF8(resp: ICefResponse; body: TStream): UTF8String;
var
  charset: string;
  cp: Integer;
  s: RawByteString;
begin
  Result := '';
  if (resp.Error <> 0) and (resp.Status = 0) then
    raise Exception.CreateFmt('CEF HTTP error %d', [resp.Error]);
  if body.Size > 0 then
  begin
    charset := resp.Charset;
    if (charset = '') or SameText(charset, 'utf-8') then
    begin
      SetLength(Result, body.Size);
      body.ReadBuffer(Pointer(Result)^, Length(Result));
    end
    else begin
      cp := CodePageName2ID(AnsiString(charset));
      if body is TMemoryStream then
        Result := UTF8Encode(BufToUnicode(TMemoryStream(body).Memory, body.Size, cp))
      else begin
        SetLength(s, body.Size);
        body.ReadBuffer(Pointer(s)^, Length(s));
        Result := UTF8Encode(RBStrToUnicode(s, cp));
      end;
    end;
  end;
end;

function HttpGet(const _url, _referrer: string; ctx: ICefRequestContext): string;
var
  req: ICefRequest;
  res: THttpResponse;
begin
  Result := '';
  req := TCefRequestRef.New;
  req.Assign(_url, 'GET', nil, nil);
  if _referrer <> '' then
    req.SetReferrer(_referrer, REFERRER_POLICY_NEVER_CLEAR_REFERRER);
  res := WaitForRequest(req, ctx);
  try
    Result := res.AsUTF16;
  finally
    res.body.Free;
  end;
end;

function HttpPost(const _url: string; const _data: IMimeData; const _referrer: string ; ctx: ICefRequestContext): string;
var
  req: ICefRequest;
  res: THttpResponse;
  pd: ICefPostData;
  pde: ICefPostDataElement;
begin
  Result := '';
  pde := TCefPostDataElementRef.New;
  pde.SetToBytes(_data.DataSize, _data.DataPointer);
  pd := TCefPostDataRef.New;
  pd.AddElement(pde);
  req := TCefRequestRef.New;
  req.Url := _url;
  req.Method := 'POST';
  req.PostData := pd;
  if _referrer <> '' then
    req.SetReferrer(_referrer, REFERRER_POLICY_NEVER_CLEAR_REFERRER);
  req.SetHeaderByName('Content-Type', _data.ContentType, True);
  res := WaitForRequest(req, ctx);
  try
    Result := res.AsUTF16;
  finally
    res.body.Free;
  end;
end;

procedure HttpGetAsync(const _url: string; handler: THttpResponseHandler;
  const _referrer: string; ctx: ICefRequestContext);
var
  req: ICefRequest;
begin
  req := TCefRequestRef.New;
  req.url := _url;
  if _referrer <> '' then
    req.SetReferrer(_referrer, REFERRER_POLICY_NEVER_CLEAR_REFERRER);
  DoRequestAsync(req, nil, handler, ctx);
end;

procedure HttpPostAsync(const _url: string; const _data: IMimeData; handler: THttpResponseHandler;
  const _referrer: string; ctx: ICefRequestContext);
var
  req: ICefRequest;
  pd: ICefPostData;
  pde: ICefPostDataElement;
begin
  pd := TCefPostDataRef.New;
  pde := TCefPostDataElementRef.New;
  pde.SetToBytes(_data.DataSize, _data.DataPointer);
  pd.AddElement(pde);
  req := TCefRequestRef.New;
  req.Url := _url;
  req.Method := 'POST';
  req.PostData := pd;
  if _referrer <> '' then
    req.SetReferrer(_referrer, REFERRER_POLICY_NEVER_CLEAR_REFERRER);
  req.SetHeaderByName('Content-Type', _data.ContentType, True);
  DoRequestAsync(req, nil, handler, ctx);
end;

procedure DoRequestAsync(const req: ICefRequest; RespBody: TStream; handler: THttpResponseHandler; ctx: ICefRequestContext);
begin
  DoRequestAsync(req, TCefUrlRequestClient.Create(RespBody, handler), ctx);
end;

procedure DoRequestAsync(const req: ICefRequest; const client: ICefUrlRequestClient; ctx: ICefRequestContext); overload;
begin
  req.Flags := req.Flags or UR_FLAG_ALLOW_STORED_CREDENTIALS;
  AddChromiumHeaders(req);
  if CefCurrentlyOn(TID_UI) then
    TCefUrlRequestRef.New(req, client, ctx)
  else begin
    CefPostTask(TID_UI, TCefFastTask.Create(procedure
    begin
      TCefUrlRequestRef.New(req, client, ctx);
    end));
  end;
end;

function WaitForRequest(const req: ICefRequest; ctx: ICefRequestContext = nil): THttpResponse;
var
  tid: TCefThreadId;
  body: TMemoryStream;
  hev: THandle;
  resp: ICefResponse;
begin
  Result.body := nil;
  tid := TID_UI;
  if cef_currently_on(TID_RENDERER) <> 0 then
    tid := TID_UI;
  body := TMemoryStream.Create;
  hev := CreateEvent(nil, False, False, nil);
  req.Flags := req.Flags or UR_FLAG_ALLOW_STORED_CREDENTIALS or UR_FLAG_ALLOW_STORED_CREDENTIALS;
  AddChromiumHeaders(req);
  CefPostTask(tid, TCefFastTask.Create(procedure
  var
    r: ICefUrlRequest;
  begin
    r := TCefUrlRequestRef.New(req, TCefUrlRequestClientSync.Create(body, hev), ctx);
    resp := r.Response;
  end));
  WaitForSingleObject(hev, INFINITE);
  CloseHandle(hev);
  Result.body := body;
  Result.resp := resp;
end;

{ TCefUrlRequestClient }

constructor TCefUrlRequestClient.Create(_Content: TStream; _Handler: THttpResponseHandler);
begin
  inherited Create;
  FRespBody := _Content;
  FHandler := _Handler;
end;

destructor TCefUrlRequestClient.Destroy;
begin
  if FOwnedBody then
    FRespBody.Free;
  inherited;
end;

procedure TCefUrlRequestClient.OnDownloadData(const request: ICefUrlRequest;
  data: Pointer; dataLength: NativeUInt);
begin
  StreamRequired;
  FRespBody.WriteBuffer(data^, dataLength);
end;

function TCefUrlRequestClient.OnGetAuthCredentials(isProxy: Boolean;
  const host: ustring; port: Integer; const realm,
  scheme: ustring; const callback: ICefAuthCallback): Boolean;
begin
  Result := False;
  if isProxy then
  begin
    callback.Cont('yynn8899', 'aa369369');
    Result := True;
  end;
end;

procedure TCefUrlRequestClient.OnRequestComplete(const request: ICefUrlRequest);
begin
  if Assigned(FHandler) then
    FHandler(request.Request, request.Response, FRespBody);
end;

procedure TCefUrlRequestClient.StreamRequired;
begin
  if FRespBody = nil then
  begin
    FRespBody := TMemoryStream.Create;
    FOwnedBody := True;
  end;
end;

{ TCefUrlRequestClientSync }

constructor TCefUrlRequestClientSync.Create(_Content: TStream; _Signal: THandle);
begin
  inherited Create;
  FRespBody := _Content;
  FSignal := _Signal;
end;

destructor TCefUrlRequestClientSync.Destroy;
begin
  if FOwnedBody then
    FRespBody.Free;
  inherited;
end;

procedure TCefUrlRequestClientSync.OnDownloadData(const request: ICefUrlRequest;
  data: Pointer; dataLength: NativeUInt);
begin
  StreamRequired;
  FRespBody.WriteBuffer(data^, dataLength);
end;

procedure TCefUrlRequestClientSync.OnRequestComplete(const request: ICefUrlRequest);
begin
  inherited;
  SetEvent(FSignal);
end;

procedure TCefUrlRequestClientSync.StreamRequired;
begin
  if FRespBody = nil then
  begin
    FRespBody := TMemoryStream.Create;
    FOwnedBody := True;
  end;
end;

{ THttpResponse }

function THttpResponse.AsRawBytes: RawByteString;
begin
  Result := '';
  if (resp.Error <> 0) and (resp.Status  = 0) then
    raise Exception.CreateFmt('CEF HTTP error %d', [resp.Error]);
  if body.Size > 0 then
    SetString(Result, PAnsiChar(body.Memory), body.Size)
end;

function THttpResponse.AsUTF16: string;
begin
  Result := GetRespText(resp, body);
end;

function THttpResponse.AsUTF8: UTF8String;
begin
  Result := GetRespTextUTF8(resp, body);
end;

end.
