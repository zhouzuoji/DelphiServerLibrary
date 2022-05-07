unit uPinduoduo;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  StrUtils,
  Classes,
  Contnrs,
  SyncObjs,
  Generics.Collections,
  Generics.Defaults,
  superobject,
  uCEFRequest,
  uCefPostData,
  uCefPostDataElement,
  uCEFRequestContext,
  uCEFInterfaces,
  uCEFTypes,
  uCEFConstants,
  uCEFApplication,
  uCEFHttpClient,
  DSLUtils,
  DSLMimeTypes;

const
  PDD_ORIGIN = 'https://mobile.yangkeduo.com';

type
  TContentType = (ctWWWFormUrlEncoded, ctJson);

  TPinduoduoCookie = class
  public
    api_uid: string;
  end;

  TReceiveAddress = record
    address: string;
    province: string;
    city: string;
    district: string;
    mobile: string;
    name: string;
    isDefault: Boolean;
  end;

procedure PDDAPIInvoke(
  const _Url, _Referer: string;
  _Params: TList<TPair<string, string>>;
  _ContentType: TContentType;
  cb: TProc<ISuperObject>;
  const _ctx: ICefRequestContext = nil);

procedure PDDAPIGetUesrInfo(cb: TProc<ISuperObject>; const _ctx: ICefRequestContext = nil);

procedure PDDAPIAddReceiveAddress(
  const ra: TReceiveAddress;
  cb: TProc<string, string>;
  const _ctx: ICefRequestContext = nil);

procedure PDDAPIDeleteReceiveAddress(
  const _AddressID: string;
  cb: TProc<Boolean, string>;
  const _ctx: ICefRequestContext = nil);

procedure GetItemJSON(const id: string; cb: TProc<ISuperObject>; const ctx: ICefRequestContext = nil);
function ExtractRawDataFromHTML(const html: string): ISuperObject;
procedure GetChildCategories(const ParentCatID: string; cb: TProc<ISuperObject>);

implementation

uses
  uCEFUtilFunctions;

var
  API_RESPONSE_OFFLINE: ISuperObject;

function ExtractRawDataFromHTML(const html: string): ISuperObject;
var
  P: Integer;
  json: string;
begin
  Result := nil;
  P := Pos('window.rawData', html);
  if P <= 0 then Exit;
  P := PosEx('=', html, P);
  json := Copy(html, P + 1);
  Result := SO(json);
end;

procedure GetItemJSON(const id: string; cb: TProc<ISuperObject>; const ctx: ICefRequestContext);
var
  url: string;
begin
  url := 'https://mobile.yangkeduo.com/goods.html?goods_id=' + id
    + '&is_spike=0&page_from=101&page_el_sn=296024&refer_page_name=order_detail&refer_page_id=10038_'
    + IntToStr(getWebTimestamp)+ '_gpbbnud77u&refer_page_sn=10038&refer_page_el_sn=296024';
  TCEFHttpRequest.Create(url).Referer('https://mobile.yangkeduo.com/').WithContext(ctx).Fetch(nil,
    procedure(const r: THttpRoundtrip)
    begin
      if r.Response.Status = 200 then
        cb(ExtractRawDataFromHTML(r.AsUTF16));
    end
  );
end;

procedure GetChildCategories(const ParentCatID: string; cb: TProc<ISuperObject>);
begin
  TCEFHttpRequest.Create('https://mms.pinduoduo.com/vodka/v2/mms/categories?parentId=' + ParentCatID)
    .Referer('https://mms.pinduoduo.com/goods/category')
    .Fetch(nil,
      procedure(const r: THttpRoundtrip)
      begin
        if r.Response.Status = 200 then
        begin
          cb(SO(r.AsUTF16));
        end;
      end
  );
end;

function EncodeForm(_Params: TList<TPair<string, string>>): RawByteString;
var
  kv: TPair<string, string>;
begin
  Result := '';
  for kv in _Params do
  begin
    if Result <> '' then
      Result := Result + '&';
    Result := Result + encodeURIComponent(kv.Key) + '=' + encodeURIComponent(kv.Value);
  end;
end;

procedure PDDAPIInvokeWithCookie(
  const _Url, _Referer: string;
  _Params: TList<TPair<string, string>>;
  _ContentType: TContentType;
  cb: TProc<ISuperObject>;
  const _ctx: ICefRequestContext;
  const PDDAccessToken, pdd_user_id: string);
var
  LUrl, LContentType: string;
  LPostData: RawByteString;
  pd: ICefPostData;
  pde: ICefPostDataElement;
  LReq: TCEFHttpRequest;
  LJson: ISuperObject;
begin
  if pdd_user_id <> '' then
  begin
    if(Pos('?', _Url) > 0) then
      LUrl := PDD_ORIGIN + _Url + '&pdd_user_id=' + pdd_user_id
    else
      LUrl := PDD_ORIGIN + _Url + '?pdd_user_id=' + pdd_user_id;
  end
  else
    LUrl := PDD_ORIGIN + _Url;
  LReq := TCEFHttpRequest.Create(LUrl).WithContext(_ctx).Referer(PDD_ORIGIN + _Referer);
  if _Params <> nil then
  begin
    LReq.Method('POST');
    if _ContentType = ctWWWFormUrlEncoded then
    begin
      LContentType := CONTENT_TYPE_URLENCODED_FORM_UTF8;
      LReq.ContentType(CONTENT_TYPE_URLENCODED_FORM_UTF8);
      LPostData := 'pdd_user_id=' + RawByteString(pdd_user_id) + '&' + EncodeForm(_Params);
    end
    else begin
      LContentType := CONTENT_TYPE_JSON_UTF8;
      LJson := nil;
      LPostData := UTF8Encode(LJson.AsJSon(False, False));
    end;
    pd := TCefPostDataRef.New;
    pde := TCefPostDataElementRef.New;
    pde.SetToBytes(Length(LPostData), Pointer(LPostData));
    pd.AddElement(pde);
    LReq.PostData(pd, LContentType);
  end;
  LReq.AddHeader('accesstoken', PDDAccessToken);
  LReq.AddHeader('accept', 'application/json, text/plain, */*');
  LReq.Fetch(nil, procedure(const r: THttpRoundtrip)
    begin
      cb(SO(r.AsUTF16));
    end
  );
end;

procedure PDDAPIInvoke(
  const _Url, _Referer: string;
  _Params: TList<TPair<string, string>>;
  _ContentType: TContentType;
  cb: TProc<ISuperObject>;
  const _ctx: ICefRequestContext);
var
  LCtx: ICefRequestContext;
begin
  LCtx := _ctx;
  if _ctx = nil then
    LCtx := GlobalRequestContext;
  GetCookies(LCtx, PDD_ORIGIN, ['PDDAccessToken', 'pdd_user_id'],
    procedure(_Cookies: TDictionary<string, string>)
    var
      PDDAccessToken, pdd_user_id: string;
    begin
      _Cookies.TryGetValue('PDDAccessToken', PDDAccessToken);
      _Cookies.TryGetValue('pdd_user_id', pdd_user_id);
      if (PDDAccessToken = '') or (pdd_user_id = '') then
        cb(API_RESPONSE_OFFLINE)
      else
        PDDAPIInvokeWithCookie(_Url, _Referer, _Params, _ContentType, cb, LCtx, PDDAccessToken, pdd_user_id);
    end
  );
end;

procedure PDDAPIGetUesrInfo(cb: TProc<ISuperObject>; const _ctx: ICefRequestContext);
begin
  PDDAPIInvoke('/proxy/api/api/apollo/v3/user/me', '', nil, ctWWWFormUrlEncoded, cb, _ctx);
end;

procedure PDDAPIAddReceiveAddress(
  const ra: TReceiveAddress;
  cb: TProc<string, string>;
  const _ctx: ICefRequestContext);
begin
end;

procedure PDDAPIDeleteReceiveAddress(
  const _AddressID: string;
  cb: TProc<Boolean, string>;
  const _ctx: ICefRequestContext);
begin
end;

initialization
  API_RESPONSE_OFFLINE := SO('{"error_code":40001,"error_msg":""}');

end.
