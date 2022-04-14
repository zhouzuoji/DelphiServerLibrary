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
function PDDItem2DoudianItem(PDDItem: ISuperObject): ISuperObject;

implementation

uses
  uCEFUtilFunctions, uDouDianItem;

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

function ConvertItemImages(imgList: TSuperArray): ISuperObject;
var
  i: Integer;
  urls: TSuperArray;
begin
  Result := TSuperObject.Create(stArray);
  urls := Result.AsArray;
  for i := 0 to imgList.Length - 1 do
    urls.Add(imgList[i].S['url']);
end;

function ConvertSaleProperties(_Properties: TSuperArray): ISuperObject;
var
  i: Integer;
  arr: TSuperArray;
  p, p2: ISuperObject;
begin
  Result := TSuperObject.Create(stArray);
  arr := Result.AsArray;
  for i := 0 to _Properties.Length - 1 do
  begin
    p := _Properties[i];
    p2 := TSuperObject.Create(stObject);
    p2.S['key'] := p.S['key'];
    p2.O['values'] := p.O['values'];
    arr.Add(p2);
  end;
end;

procedure ConvertSKU(pdd: ISuperObject; dd: ISuperObject);
var
  SpecPics: TDictionary<string, string>;
  ddSKUListObj, pddSKU, ddSKU, specsObj, SpecPicsObj, SpecPic, pddSpec, ddSpec,
    specidsObj, ddSpecValue: ISuperObject;
  ddSKUList, pddSKUList, specs, SpecPicsArr, pddSpecs, specids, ddSpecValues: TSuperArray;
  i, j, k: Integer;
  kv: TPair<string, string>;
  ddSpecs: TList<ISuperObject>;
begin
  pddSKUList := pdd.A['skus'];
  if pddSKUList.Length = 0 then
    Exit;
  SpecPics := TDictionary<string, string>.Create;
  ddSpecs := TList<ISuperObject>.Create;
  ddSKUListObj := TSuperObject.Create(stArray);
  ddSKUList := ddSKUListObj.AsArray;
  pddSKUList := pdd.A['skus'];
  try
    pddSKU := pddSKUList[0];
    pddSpecs := pddSKU.A['specs'];
    for i := 0 to pddSpecs.Length - 1 do
    begin
      pddSpec := pddSpecs[i];
      ddSpec := TSuperObject.Create(stObject);
      ddSpec.S['id'] := pddSpec.S['spec_key_id'];
      ddSpec.S['name'] := pddSpec.S['spec_key'];
      ddSpec['values'] := TSuperObject.Create(stArray);
      ddSpecs.Add(ddSpec);
    end;

    for i := 0 to pddSKUList.Length - 1 do
    begin
      pddSKU := pddSKUList[i];
      pddSpecs := pddSKU.A['specs'];
      ddSKU := TSuperObject.Create(stObject);
      ddSKU.S['sku_id'] := pddSKU.S['skuId'];
      ddSKU.S['stock_num'] := pddSKU.S['quantity'];
      ddSKU.I['price'] := Round(pddSKU.D['groupPrice'] * 100);  // 售价 (单位 分)
      specidsObj := TSuperObject.Create(stArray);
      specids := specidsObj.AsArray;
      pddSpec := pddSpecs[0];
      kv.Key := pddSpec.S['spec_value_id'];
      kv.Value := pddSKU.S['thumbUrl'];
      if (kv.Value <> '') and not SpecPics.ContainsKey(kv.Key) then
        SpecPics.Add(kv.Key, kv.Value );
      for k := 0 to pddSpecs.Length - 1 do
      begin
        pddSpec := pddSpecs[k];
        kv.Key := pddSpec.S['spec_key_id'];
        kv.Value := pddSpec.S['spec_value_id'];
        specids.Add(kv.Value);
        ddSpec := ddSpecs[k];
        if ddSpec.S['id'] <> kv.Key then
        begin
          for j := 0 to ddSpecs.Count - 1 do
          begin
            ddSpec := ddSpecs[j];
            if ddSpec.S['id'] = kv.Key then
              Break;
          end;
        end;
        ddSpecValues := ddSpec.A['values'];
        ddSpecValue := nil;
        for j := 0 to ddSpecValues.Length - 1 do
        begin
          if ddSpecValues[j].S['id'] = kv.Value then
          begin
            ddSpecValue := ddSpecValues[j];
            Break;
          end;
        end;
        if ddSpecValue = nil then
        begin
          ddSpecValue := TSuperObject.Create(stObject);
          ddSpecValue.S['id'] := kv.Value;
          ddSpecValue.S['name'] := pddSpec.S['spec_value'];
          ddSpecValues.Add(ddSpecValue);
        end;
      end;
      ddSKU['spec_detail_ids'] := specidsObj;
      ddSKUList.Add(ddSKU);
    end;
    specsObj := TSuperObject.Create(stArray);
    specs := specsObj.AsArray;
    for i := 0 to ddSpecs.Count - 1 do
      specs.Add(ddSpecs[i]);
    dd['specs'] := specsObj;
    dd['spec_prices'] := ddSKUListObj;
    SpecPicsObj := TSuperObject.Create(stArray);
    SpecPicsArr := SpecPicsObj.AsArray;
    for kv in SpecPics do
    begin
      SpecPic := TSuperObject.Create(stObject);
      SpecPic.S['spec_detail_id'] := kv.Key;
      SpecPic.S['pic'] := kv.Value;
      SpecPicsArr.Add(SpecPic);
    end;
    dd['spec_pics'] := SpecPicsObj;
  finally
    SpecPics.Free;
    ddSpecs.Free;
  end;
end;

function PDDItem2DoudianItem(PDDItem: ISuperObject): ISuperObject;
var
  initDataObj, mall, mall2, goods, categoryDetail: ISuperObject;
begin
  Result := PDDItem;
  initDataObj := PDDItem.O['store.initDataObj'];
  if initDataObj = nil then
    Exit;
  goods := initDataObj.O['goods'];
  if goods = nil then
    Exit;
  Result := TSuperObject.Create(stObject);
  Result.I['reviewNum'] := initDataObj.I['oakData.review.reviewNum'];

  mall := initDataObj.O['mall'];
  mall2 := TSuperObject.Create(stObject);
  mall2.S['id'] := mall.S['mallId'];
  mall2.S['name'] := mall.S['mallName'];
  mall2.S['_type'] := 'pdd';
  Result.O['mall'] := mall2;

  //Result.I['salesVolume'] := extractSalesVolume(goods.S['sideSalesTip']);

  categoryDetail := TSuperObject.Create(stObject);
  categoryDetail.S['first_cid'] := goods.S['catID1'];
  categoryDetail.S['second_cid'] := goods.S['catID2'];
  categoryDetail.S['third_cid'] := goods.S['catID3'];
  categoryDetail.S['fourth_cid'] := goods.S['catID4'];
  Result.O['category_detail'] := categoryDetail;


  Result.I['start_sale_type'] := 0; // 审核通过后上架售卖时间配置:0-立即上架售卖 1-放入仓库
  Result.I['product_type'] := 0; // 0-普通，3-虚拟，6玉石闪购，7云闪购
  Result.I['reduce_type'] := 1; // 1 减库存类型：1-拍下减库存 2-付款减库存
  Result.S['category_leaf_id'] := goods.S['catID']; // 叶子类目ID通过/shop/getShopCategory接口获取
  Result.S['product_id'] := goods.S['goodsID'];
  Result.S['name'] := goods.S['goodsName'];
  Result.I['status'] := Ord(not goods.B['isOnSale']); // 商品上下架状态：0上架 1下架 2已删除
  Result.I['pay_type'] := 1; // 支付方式，0货到付款 1在线支付，2，货到付款+在线支付



  Result.I['delivery_delay_day'] := 2; // 承诺发货时间，单位是天,不传则默认为2天
  Result.I['presell_type'] := 0; // 发货模式，0-现货发货，1-预售发货，2-阶梯发货，默认0
  Result.I['supply_7day_return'] := 1; //是否支持7天无理由，0不支持，1支持，2支持（拆封后不支持）
  Result.O['pic'] := ConvertItemImages(goods.A['topGallery']); // 商品轮播图，多张图片用 \"|\" 分开，第一张图为主图，最多5张，至少600x600，大小不超过1M
  Result.O['desc_pics'] := ConvertItemImages(goods.A['detailGallery']); // 商品描述不支持文字
  Result.O['goodsProperty'] := ConvertSaleProperties(goods.A['goodsProperty']);
  ConvertSKU(goods, Result);
end;

procedure GetItemJSON(const id: string; cb: TProc<ISuperObject>; const ctx: ICefRequestContext);
var
  url: string;
begin
  url := 'https://mobile.yangkeduo.com/goods.html?goods_id=' + id
    + '&is_spike=0&page_from=101&page_el_sn=296024&refer_page_name=order_detail&refer_page_id=10038_'
    + IntToStr(getWebTimestamp)+ '_gpbbnud77u&refer_page_sn=10038&refer_page_el_sn=296024';
  HttpGetAsync(url, procedure(req: ICefRequest; resp: ICefResponse; RespBody: TStream)
  var
    html: string;
  begin
    if resp.Status = 200 then
    begin
      html := GetRespText(resp, RespBody);
      cb(ExtractRawDataFromHTML(html));
    end;
  end, 'https://mobile.yangkeduo.com/', ctx);
end;

procedure GetChildCategories(const ParentCatID: string; cb: TProc<ISuperObject>);
var
  url: string;
begin
  url := 'https://mms.pinduoduo.com/vodka/v2/mms/categories?parentId=' + ParentCatID;
  HttpGetAsync(url, procedure(req: ICefRequest; resp: ICefResponse; RespBody: TStream)
  var
    json: string;
  begin
    if resp.Status = 200 then
    begin
      json := GetRespText(resp, RespBody);
      cb(SO(json));
    end;
  end, 'https://mms.pinduoduo.com/goods/category');
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
  req: ICefRequest;
  url: string;
  LPostData: RawByteString;
  pd: ICefPostData;
  pde: ICefPostDataElement;
begin
  req := TCefRequestRef.New;
  if Pos('?', _Url) > 0 then
    url := PDD_ORIGIN + _Url + '&pdd_user_id=' + pdd_user_id
  else
    url := PDD_ORIGIN + _Url + '?pdd_user_id=' + pdd_user_id;
  req.Url := url;
  req.SetReferrer(PDD_ORIGIN + _Referer, REFERRER_POLICY_NEVER_CLEAR_REFERRER);
  if _Params <> nil then
  begin
    req.Method := 'POST';
    if _ContentType = ctWWWFormUrlEncoded then
    begin
      req.SetHeaderByName('content-type', CONTENT_TYPE_URLENCODED_FORM_UTF8, True);
      LPostData := 'pdd_user_id=' + RawByteString(pdd_user_id) + '&' + EncodeForm(_Params);
    end
    else begin
      req.SetHeaderByName('content-type', CONTENT_TYPE_JSON_UTF8, True);
    end;
    pd := TCefPostDataRef.New;
    pde := TCefPostDataElementRef.New;
    pde.SetToBytes(Length(LPostData), Pointer(LPostData));
    pd.AddElement(pde);
    req.PostData := pd;
  end;

  req.SetHeaderByName('accesstoken', PDDAccessToken, True);
  req.SetHeaderByName('accept', 'application/json, text/plain, */*', True);
  DoRequestAsync(req, nil, procedure(req: ICefRequest; resp: ICefResponse; RespBody: TStream)
    var
      LText: string;
    begin
      LText := GetRespText(resp, RespBody);
      cb(SO(LText));
    end, _ctx);
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
    LCtx := TCefRequestContextRef.Global;
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
