unit uCEFHttpClient;

interface

uses
  SysUtils,
  Classes,
  Windows,
  Generics.Collections,
  Generics.Defaults,
  uCEFTypes,
  uCEFInterfaces,
  uCEFLibFunctions,
  uCEFMiscFunctions,
  uCEFRequest,
  uCEFUrlRequest,
  uCEFBaseRefCounted,
  uCefUrlRequestClient,
  uCEFRequestContext,
  uCEFTask,
  uCefStringMultimap,
  uCEFConstants,
  uCEFPostDataElement,
  uCEFPostData,
  DSLUtils,
  DSLHttp,
  DSLMimeTypes;

type
  THttpRoundtrip = record
    Request: ICefRequest;
    Response: ICefResponse;
    Content: TStream;
    function AsUTF16: string;
    function AsUTF8: UTF8String;
    function AsRawBytes: RawByteString;
  end;
  THttpResponseHandler = reference to procedure(const _Roundtrip: THttpRoundtrip);

  TCEFHttpRequest = record
    Context: ICefRequestContext;
    Handle: ICefRequest;
    Headers: ICefStringMultimap;
    FOnCreated: TProc<ICefUrlRequest>;
    constructor Create(const url: string);
    function RequireHeaders: ICefStringMultimap;
    function WithContext(const c: ICefRequestContext): TCEFHttpRequest;
    function Method(const m: string): TCEFHttpRequest;
    function Referer(const _Referer: string): TCEFHttpRequest;
    function PostData(const _data: IMimeData): TCEFHttpRequest; overload;
    function PostData(const _data: ICefPostData; const _ContentType: string): TCEFHttpRequest; overload;
    function AddHeader(const _Name, _Value: string): TCEFHttpRequest;
    function ContentType(const _ContentType: string): TCEFHttpRequest;
    function NoRedirect: TCEFHttpRequest;
    function NoRetryOn5xx: TCEFHttpRequest;
    function NoCookie: TCEFHttpRequest;
    function DisableCache: TCEFHttpRequest;
    function OnCreated(cb: TProc<ICefUrlRequest>): TCEFHttpRequest;
    procedure Fetch(_Content: TStream;  _OnResult: THttpResponseHandler);
  end;

function GetRespHeader(resp: ICefResponse): string;
function GetRespText(resp: ICefResponse; body: TStream): string;
function GetRespTextUTF8(resp: ICefResponse; body: TStream): UTF8String;
function GetRespTextRaw(resp: ICefResponse; body: TStream): RawByteString;

implementation

uses
  uChromiumForm;

type
  TCefUrlRequestClient = class(TCefUrlRequestClientOwn)
  private
    FRespBody: TStream;
    FOwnedBody: Boolean;
    FOnResult: THttpResponseHandler;
    procedure StreamRequired;
    procedure OnRequestComplete(const _UrlReq: ICefUrlRequest); override;
    procedure OnDownloadData(const request: ICefUrlRequest; data: Pointer; dataLength: NativeUInt); override;
  public
    constructor Create(_Content: TStream; _OnResult: THttpResponseHandler); reintroduce;
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

procedure AddChromiumHeaders(r: ICefRequest); overload;
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

function GetRespTextRaw(resp: ICefResponse; body: TStream): RawByteString;
begin
  Result := '';
  if (resp.Error <> 0) and (resp.Status = 0) then
    raise Exception.CreateFmt('CEF HTTP error %d', [resp.Error]);
  if body.Size > 0 then
  begin
    SetLength(Result, body.Size);
    body.ReadBuffer(Pointer(Result)^, Length(Result));
  end;
end;

{ TCefUrlRequestClient }

constructor TCefUrlRequestClient.Create(_Content: TStream; _OnResult: THttpResponseHandler);
begin
  inherited Create;
  FRespBody := _Content;
  FOnResult := _OnResult;
end;

destructor TCefUrlRequestClient.Destroy;
begin
  if FOwnedBody then
    FreeAndNil(FRespBody);
  inherited;
end;

procedure TCefUrlRequestClient.OnDownloadData(const request: ICefUrlRequest;
  data: Pointer; dataLength: NativeUInt);
begin
  StreamRequired;
  FRespBody.WriteBuffer(data^, dataLength);
end;

procedure TCefUrlRequestClient.OnRequestComplete(const _UrlReq: ICefUrlRequest);
var
  LRoundtrip: THttpRoundtrip;
begin
  LRoundtrip.Request := _UrlReq.Request;
  LRoundtrip.Response := _UrlReq.Response;
  LRoundtrip.Content := FRespBody;
  if Assigned(FOnResult) then
    FOnResult(LRoundtrip);
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

function THttpRoundtrip.AsRawBytes: RawByteString;
begin
  Result := GetRespTextRaw(Response, Content);
end;

function THttpRoundtrip.AsUTF16: string;
begin
  Result := GetRespText(Response, Content);
end;

function THttpRoundtrip.AsUTF8: UTF8String;
begin
  Result := GetRespTextUTF8(Response, Content);
end;

{ TCEFHttpRequest }

function TCEFHttpRequest.AddHeader(const _Name, _Value: string): TCEFHttpRequest;
begin
  RequireHeaders.Append(_Name, _Value);
  Result := Self;
end;

function TCEFHttpRequest.ContentType(const _ContentType: string): TCEFHttpRequest;
begin
  RequireHeaders.Append('Content-Type', _ContentType);
  Result := Self;
end;

constructor TCEFHttpRequest.Create(const url: string);
begin
  Handle := TCefRequestRef.New;
  Handle.Url := url;
  Handle.Flags := UR_FLAG_ALLOW_STORED_CREDENTIALS;
end;

function TCEFHttpRequest.DisableCache: TCEFHttpRequest;
begin
  Handle.Flags := Handle.Flags or UR_FLAG_DISABLE_CACHE;
  Result := Self;
end;

procedure TCEFHttpRequest.Fetch(_Content: TStream;  _OnResult: THttpResponseHandler);
var
  LClient: ICefUrlRequestClient;
  LReq: ICefUrlRequest;
  LContext: ICefRequestContext;
  LHandle: ICefRequest;
  LOnCreated: TProc<ICefUrlRequest>;
begin
  LClient := TCefUrlRequestClient.Create(_Content, _OnResult);
  if Headers <> nil then
    Handle.SetHeaderMap(Headers);
  AddChromiumHeaders(Handle);
  if CefCurrentlyOn(TID_IO) then
  begin
    LReq := TCefUrlRequestRef.New(Handle, LClient, Context);
    if Assigned(FOnCreated) then
      FOnCreated(LReq);
  end
  else begin
    LContext := Self.Context;
    LHandle := Self.Handle;
    LOnCreated := Self.FOnCreated;
    CefPostTask(TID_IO, TCefFastTask.Create(procedure
    var
      r: ICefUrlRequest;
    begin
      r := TCefUrlRequestRef.New(LHandle, LClient, LContext);
      if Assigned(LOnCreated) then
        LOnCreated(r);
    end));
  end;
end;

function TCEFHttpRequest.Method(const m: string): TCEFHttpRequest;
begin
  Handle.Method := m;
  Result := Self;
end;

function TCEFHttpRequest.NoCookie: TCEFHttpRequest;
begin
  Handle.Flags := Handle.Flags and not UR_FLAG_ALLOW_STORED_CREDENTIALS;
  Result := Self;
end;

function TCEFHttpRequest.NoRedirect: TCEFHttpRequest;
begin
  Handle.Flags := Handle.Flags or UR_FLAG_STOP_ON_REDIRECT;
  Result := Self;
end;

function TCEFHttpRequest.NoRetryOn5xx: TCEFHttpRequest;
begin
  Handle.Flags := Handle.Flags or UR_FLAG_NO_RETRY_ON_5XX;
  Result := Self;
end;

function TCEFHttpRequest.OnCreated(cb: TProc<ICefUrlRequest>): TCEFHttpRequest;
begin
  FOnCreated := cb;
  Result := Self;
end;

function TCEFHttpRequest.PostData(const _data: ICefPostData; const _ContentType: string): TCEFHttpRequest;
begin
  Handle.Method := 'POST';
  Handle.PostData := _data;
  if _ContentType <> '' then
    ContentType(_ContentType);
  Result := Self;
end;

function TCEFHttpRequest.PostData(const _data: IMimeData): TCEFHttpRequest;
var
  pd: ICefPostData;
  pde: ICefPostDataElement;
begin
  Handle.Method := 'POST';
  pde := TCefPostDataElementRef.New;
  pde.SetToBytes(_data.DataSize, _data.DataPointer);
  pd := TCefPostDataRef.New;
  pd.AddElement(pde);
  Handle.PostData := pd;
  ContentType( _data.ContentType);
  Result := Self;
end;

function TCEFHttpRequest.Referer(const _Referer: string): TCEFHttpRequest;
begin
  Handle.SetReferrer(_Referer, REFERRER_POLICY_NEVER_CLEAR_REFERRER);
  Result := Self;
end;

function TCEFHttpRequest.RequireHeaders: ICefStringMultimap;
begin
  if Headers = nil then
    Headers := TCefCustomStringMultimap.Create;
  Result := Headers;
end;

function TCEFHttpRequest.WithContext(const c: ICefRequestContext): TCEFHttpRequest;
begin
  Context := c;
  Result := Self;
end;

end.
