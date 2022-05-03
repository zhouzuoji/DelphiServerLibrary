unit uRequestTransformer;

interface

uses
  SysUtils,
  Classes,
  Windows,
  uCEFConstants,
  uCEFTypes,
  uCefResourceHandler,
  uCefStringMultimap,
  uCEFInterfaces;

type
  TCustomRequestTransformer = class(TCefResourceHandlerOwn)
  private
    FBrowser: ICefBrowser;
    FFrame: ICefFrame;
    FRequest: ICefRequest;
    FIsCanceled: Boolean;
    FRespHeader: ICefStringMultimap;
    FRespBody: TMemoryStream;
    FResp: ICefResponse;
    FUrlReq: ICefUrlRequest;
    FUrl: string;
  protected
    function open(const _Req: ICefRequest; var _HandleImmediately: Boolean; const _Callback: ICefCallback): Boolean; override;
    procedure GetResponseHeaders(const _Resp: ICefResponse; out _ContentLength: Int64; out redirectUrl: ustring); override;
    function skip(bytes_to_skip: int64; var bytes_skipped: Int64; const callback: ICefResourceSkipCallback): Boolean; override;
    function read(const data_out: Pointer; bytes_to_read: Integer; var bytes_read: Integer; const callback: ICefResourceReadCallback): boolean; override;
    procedure Cancel; override;
    function Tranform(const _Req: ICefRequest; out _Ctx: ICefRequestContext): ICefRequest; virtual; abstract;
    procedure TransformRespHeader(_RespHeaders: ICefStringMultimap; cb: TProc<ICefStringMultimap>); virtual;
  public
    constructor Create(const _browser: ICefBrowser; const _frame: ICefFrame; const _schemeName: ustring; const _request: ICefRequest); override;
    destructor Destroy; override;
    property Browser: ICefBrowser read FBrowser;
    property Frame: ICefFrame read FFrame;
    property Url: string read FUrl;
  end;

implementation

uses
  DSLUtils,
  uCEFUtilFunctions,
  uCEFHttpClient;

{ TCustomRequestTransformer }

procedure TCustomRequestTransformer.Cancel;
begin
  inherited;
  FIsCanceled := True;
  if Assigned(FUrlReq) then
    FUrlReq.Cancel;
  Assert(DbgOutput(Self.ClassName + '.Cancel: ' + FRequest.Url));
end;

constructor TCustomRequestTransformer.Create(const _browser: ICefBrowser; const _frame: ICefFrame; const _schemeName: ustring;
  const _request: ICefRequest);
begin
  inherited;
  FBrowser := _browser;
  FFrame := _frame;
  FRequest := _request;
end;

destructor TCustomRequestTransformer.Destroy;
begin
  FreeAndNil(FRespBody);
  inherited;
end;

procedure TCustomRequestTransformer.GetResponseHeaders(const _Resp: ICefResponse;
  out _ContentLength: Int64; out redirectUrl: ustring);
var
  LHeaders, LNewHeaders: ICefStringMultimap;
begin
  inherited;
  _Resp.Status := FResp.Status;
  _Resp.StatusText := FResp.StatusText;
  _Resp.MimeType := FResp.MimeType;
  _Resp.Charset := FResp.Charset;
  _Resp.Error := FResp.Error;
  _Resp.URL := FResp.URL;
  _ContentLength := FRespBody.Size;
  if FResp.Error = 0 then
    _Resp.SetHeaderMap(FRespHeader);
end;

{
1. To handle the request immediately set |handle_request| to true and return true.
2. To decide at a later time set |handle_request| to false, return true,
  and execute |callback| to continue or cancel the request.
3. To cancel the request immediately set |handle_request| to true and return false.
}
function TCustomRequestTransformer.open(const _Req: ICefRequest; var _HandleImmediately: Boolean; const _Callback: ICefCallback): Boolean;
var
  LReq: TCEFHttpRequest;
begin
  //OutputDebugString(PChar(DumpRequest(request)));
  FRequest := _Req;
  FUrl := _Req.Url;
  LReq.Handle := Tranform(_Req, LReq.Context);
  if LReq.Handle = nil then
  begin
    _HandleImmediately := True;
    Result := False;
    Exit;
  end;
  FRespBody := TMemoryStream.Create;
  Self._AddRef;
  Self._AddRef;
  if (LReq.Context = nil) and (FBrowser <> nil) then
    LReq.Context := FBrowser.Host.RequestContext;
  _HandleImmediately := False;
  Result := True;
  LReq.OnCreated(
    procedure(_UrlReq: ICefUrlRequest)
    begin
      FUrlReq := _UrlReq;
      if FIsCanceled then
        FUrlReq.Cancel;
      Self._Release;
    end
  ).Fetch(FRespBody,
    procedure(const r: THttpRoundtrip)
    var
      LHeaders: ICefStringMultimap;
    begin
      FResp := r.Response;
      FRespBody.Position := 0;
      LHeaders := TCefStringMultimapOwn.Create;
      r.Response.GetHeaderMap(LHeaders);
      TransformRespHeader(LHeaders,
        procedure(_Result: ICefStringMultimap)
        begin
          FRespHeader := _Result;
          _Callback.Cont;
          Self._Release;
        end
      );
    end
  );
end;

{Read response data. If data is available immediately copy up to |bytes_to_read|
bytes into |data_out|, set |bytes_read| to the number of bytes copied,
and return true. To read the data at a later time keep a pointer to |data_out|,
set |bytes_read| to 0, return true and execute |callback| when the data is available
(|data_out| will remain valid until the callback is executed).
To indicate response completion set |bytes_read| to 0 and return false.
To indicate failure set |bytes_read| to < 0 (e.g. -2 for ERR_FAILED) and return false.
}
function TCustomRequestTransformer.read(const data_out: Pointer; bytes_to_read: Integer;
  var bytes_read: Integer; const callback: ICefResourceReadCallback): boolean;
begin
  bytes_read := FRespBody.Read(data_out^, bytes_to_read);
  Result := bytes_read > 0;
end;

{Skip response data when requested by a Range header.
Skip over and discard |bytes_to_skip| bytes of response data.
If data is available immediately set |bytes_skipped| to the number of bytes skipped
and return true. To read the data at a later time set |bytes_skipped| to 0,
return true and execute |callback| when the data is available.
To indicate failure set |bytes_skipped| to < 0 (e.g. -2 for ERR_FAILED) and return false.
}
function TCustomRequestTransformer.skip(bytes_to_skip: int64; var bytes_skipped: Int64;
  const callback: ICefResourceSkipCallback): Boolean;
var
  n: Int64;
begin
  n := FRespBody.Size - FRespBody.Position;
  bytes_skipped := bytes_to_skip;
  if bytes_skipped > n then
    bytes_skipped := n;
  FRespBody.Seek(bytes_skipped, soCurrent);
  Result := True;
end;

procedure TCustomRequestTransformer.TransformRespHeader;
begin
  cb(_RespHeaders);
end;

end.
