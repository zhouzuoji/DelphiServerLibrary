
unit uCEFUtilFunctions;

interface

uses
  SysUtils,
  Classes,
  StrUtils,
  Generics.Collections,
  Generics.Defaults,
  uCEFTypes,
  uCEFConstants,
  uCEFInterfaces,
  uCEFMiscFunctions,
  uCEFRequestContext,
  uCEFJson,
  superobject;

function ValueToString(const v: ICefValue): string; overload;
function ValueToString(const v: ICefv8Value): string; overload;
function DumpStringMultimap(const m: ICefStringMultimap): string;
function DumpRequest(const r: ICefRequest): string;
function PostDataToString(_PostData: ICefPostData; _ContentType: string): string;
function PostDataToByteArray(_PostData: ICefPostData): RawByteString;
function JsonizeCookieList(_Cookies: TList<TCookie>): ISuperObject;
function LoadCookieFromJson(json: ISuperObject): TList<TCookie>;
procedure CopyCookies(const _Src, _Dest: ICefRequestContext; const _Url: string; _OnComplete: TProc);
procedure GetCookies(const _Ctx: ICefRequestContext; const _Url: string;
  _OnComplete: TProc<TList<TPair<string,string>>>); overload;
procedure GetCookies(const _Ctx: ICefRequestContext; const _Url: string;
  const _Names: array of string; _OnComplete: TProc<TDictionary<string,string>>); overload;
procedure GetCookies(const _Ctx: ICefRequestContext; const _Url: string; _OnComplete: TProc<TList<TCookie>>); overload;
procedure SetCookie(const _Ctx: ICefRequestContext;
  const _Url, _Name, _Value: string; cb: TCefSetCookieCallbackProc = nil;
  const _Path: string = '/'; const _Domain: string = '');
procedure AddCookies(const _Ctx: ICefRequestContext; const _Url: string; _Cookies: TList<TCookie>; _OnComplete: TProc);
procedure CreateRequestContext(const _CachePath: ustring;
  const _AcceptLanguageList: ustring; const _CookieableSchemesList: ustring;
  const _CookieableSchemesExcludeDefaults: Boolean;
  _PersistSessionCookies: Boolean; _PersistUserPreferences: Boolean;
  cb: TProc<ICefRequestContext>);

function IsCEFInitialized: Boolean;
function GlobalRequestContext: ICefRequestContext;
procedure ExecWhenCEFInitiaized(_Proc: TProc);
procedure OnCEFInitiaized;

implementation

uses
  DateUtils,
  uCEFBaseRefCounted,
  uCefStringMultimap,
  uCefRequestContextHandler;

type
  TCustomCookieVisitor = class(TCefBaseRefCountedOwn, ICefCookieVisitor)
  private
    FVisitProc: TCefCookieVisitorProc;
    FOnFinished: TProc;
  protected
    function visit(const name, value, domain, path: ustring; secure, httponly, hasExpires: Boolean; const creation, lastAccess, expires: TDateTime; count, total: Integer; same_site : TCefCookieSameSite; priority : TCefCookiePriority; out deleteCookie: Boolean): Boolean;
  public
    constructor Create(_VisitProc: TCefCookieVisitorProc; _OnFinished: TProc);
    destructor Destroy; override;
  end;

var
  EMPTY_SET_COOKIE_CALLBACK: TCefSetCookieCallbackProc;
  _GlobalReqCtx: ICefRequestContext;
  G_CEFInitCallbacks: TList<TProc>;
  G_CEFInitialized: Boolean;

function IsCEFInitialized: Boolean;
begin
  Result := G_CEFInitialized;
end;

procedure OnCEFInitiaized;
var
  LProc: TProc;
begin
  G_CEFInitialized := True;
  _GlobalReqCtx := TCEFRequestContextRef.Global;
  for LProc in G_CEFInitCallbacks do
    LProc();
end;

procedure ExecWhenCEFInitiaized(_Proc: TProc);
begin
  G_CEFInitCallbacks.Add(_Proc);
end;

function GlobalRequestContext: ICefRequestContext;
begin
  Result := _GlobalReqCtx;
end;

function ValueToString(const v: ICefValue): string;
begin
  Result := '';
  case v.GetType of
    VTYPE_INVALID:
      Result := 'undefined';
    VTYPE_NULL:
      Result := 'null';
    VTYPE_BOOL:
      if v.GetBool then
        Result := 'true'
      else
        Result := 'false';
    VTYPE_INT:
      Result := IntToStr(v.GetInt);
    VTYPE_DOUBLE:
      Result := FloatToStr(v.GetDouble);
    VTYPE_STRING:
      Result := v.GetString;
    VTYPE_BINARY:
      Result := 'binary';
  else
    Result := TCEFJson.Write(v);
  end;
end;

function ValueToString(const v: ICefv8Value): string;
begin
  Result := '';
  if v.IsString then
    Result := v.GetStringValue
  else if v.IsInt then
    Result := IntToStr(v.GetIntValue)
  else if v.IsUInt then
    Result := IntToStr(v.GetUIntValue)
  else if v.IsDouble then
    Result := FloatToStr(v.GetDoubleValue)
  else if v.IsBool then
    Result := BoolToStr(v.GetBoolValue, True)
  else if v.IsDate then
    Result := DateTimeToStr(v.GetDateValue)
  else if v.IsUndefined then
    Result := 'undefined'
  else if v.IsNull then
    Result := 'null'
  else if v.IsObject then
    Result := '{}'
  else if v.IsArray then
    Result := '[]'
  else if v.IsFunction then
    Result := 'function(){}'
  else if v.IsArrayBuffer then
    Result := 'ArrayBuffer}';
end;

function GetHost(const _Url: string): string;
var
  P1, P2: Integer;
begin
  P1 := Pos('://', _Url);
  if P1 <= 0 then
    P1 := 1
  else
    Inc(P1, 3);
  P2 := PosEx('/', _Url, P1);
  if P2 <= 0 then
    P2 := Length(_Url) + 1;
  Result := Copy(_Url, P1, P2 - P1);
end;

procedure SetCookie(const _Ctx: ICefRequestContext;
  const _Url, _Name, _Value: string; cb: TCefSetCookieCallbackProc;
  const _Path, _Domain: string);
var
  LDomain, LPath: string;
begin
  LDomain := _Domain;
  if LDomain = '' then
    LDomain := GetHost(_Url);
  LPath := _Path;
  if LPath = '' then
    LPath := '/';
  if not Assigned(cb) then
    cb := EMPTY_SET_COOKIE_CALLBACK;
  _Ctx.GetCookieManager(nil).SetCookieProc(_Url, _Name, _Value, LDomain,
    LPath, False, False, True, Now, Now, Now + 30,
    CEF_COOKIE_SAME_SITE_STRICT_MODE, 0,
    cb);
end;

procedure AddCookies(const _Ctx: ICefRequestContext; const _Url: string; _Cookies: TList<TCookie>; _OnComplete: TProc);
var
  LCookieMgr: ICefCookieManager;
  LDomain, LPath: string;
  i, n: Integer;
  cb: TCefSetCookieCallbackProc;
begin
  n := 0;
  if Assigned(_OnComplete) then
    cb := procedure(success: Boolean)
      begin
        Inc(n);
        if n = _Cookies.Count then
          _OnComplete()
      end
    else
      cb := EMPTY_SET_COOKIE_CALLBACK;
  LCookieMgr := _Ctx.GetCookieManager(nil);
  for i := 0 to _Cookies.Count - 1 do
  begin
    with _Cookies.List[i] do
    begin
      _Ctx.GetCookieManager(nil).SetCookieProc(_Url, name, value, domain,
        path, False, False, True, Now, Now, Now + 30,
        CEF_COOKIE_SAME_SITE_STRICT_MODE, 0,
        cb);
    end;
  end;
end;

const
  SAME_SITE_STRINGS: array [TCefCookieSameSite] of string =
    ('', 'none', 'Lax', 'Strict');

function JsonizeCookieList(_Cookies: TList<TCookie>): ISuperObject;
var
  arr: TSuperArray;
  o: ISuperObject;
  i: Integer;
begin
  Result := TSuperObject.Create(stArray);
  arr := Result.AsArray;
  for i := 0 to _Cookies.Count - 1 do
  begin
    with _Cookies[i] do
    begin
      o := TSuperObject.Create(stObject);
      o.S['name'] := name;
      o.S['value'] := value;
      o.S['domain'] := domain;
      o.S['path'] := path;
      o.I['expires'] := DateTimeToUnix(expires);
      o.B['httponly'] := httponly;
      o.B['secure'] := secure;
      o.I['same_site'] := Ord(same_site);
      arr.Add(o);
    end;
  end;
end;

function LoadCookieFromJson(json: ISuperObject): TList<TCookie>;
var
  arr: TSuperArray;
  o: ISuperObject;
  i: Integer;
begin
  Result := TList<TCookie>.Create;
  try
    arr := json.AsArray;
    if arr <> nil then
    begin
      Result.Count := arr.Length;
      for i := 0 to arr.Length - 1 do
      begin
        o := arr[i];
        with Result.List[i] do
        begin
          name := o.S['name'];
          value := o.S['value'];
          domain := o.S['domain'];
          path := o.S['path'];
          expires := UnixToDateTime(o.I['expires']);
          httponly := o.B['httponly'];
          secure := o.B['secure'];
          same_site := TCefCookieSameSite(o.I['same_site']);
        end;
      end;
    end;
  except
    FreeAndNil(Result);
  end;
end;

procedure CopyCookies(const _Src, _Dest: ICefRequestContext; const _Url: string; _OnComplete: TProc);
var
  LSrc, LDest: ICefCookieManager;
begin
  (Format('TCustomSiteSsnMgr.NewSession: MoveCookies("%s", "%s")',
    [_Src.CachePath, _Dest.CachePath]));
  LSrc := _Src.GetCookieManager(nil);
  LDest := _Dest.GetCookieManager(nil);
  LSrc.VisitUrlCookies(_Url, True,
    TCustomCookieVisitor.Create(
      function(const name, value, domain, path: ustring;
        secure, httponly, hasExpires: Boolean;
        const creation, lastAccess, expires: TDateTime; count, total: Integer;
        same_site: TCefCookieSameSite; priority: TCefCookiePriority;
        out deleteCookie: Boolean): Boolean
        begin
          LDest.SetCookieProc(_Url, name, value, domain, path, secure, httponly,
            hasExpires, creation, lastAccess, expires, same_site,
            priority, EMPTY_SET_COOKIE_CALLBACK);
          Result := True;
        end,
      _OnComplete
    )
  );
end;

procedure GetCookies(const _Ctx: ICefRequestContext; const _Url: string;
  _OnComplete: TProc<TList<TPair<string,string>>>);
var
  LCookieMgr: ICefCookieManager;
  LCookies: TList<TPair<string, string>>;
begin
  LCookieMgr := _Ctx.GetCookieManager(nil);
  LCookies := TList < TPair < string, string >>.Create;
  LCookieMgr.VisitUrlCookies(_Url, True,
    TCustomCookieVisitor.Create(
      function(const name, value, domain, path: ustring;
        secure, httponly, hasExpires: Boolean;
        const creation, lastAccess, expires: TDateTime; count, total: Integer;
        same_site: TCefCookieSameSite; priority: TCefCookiePriority;
        out deleteCookie: Boolean): Boolean
        begin
          LCookies.Add(TPair<string, string>.Create(name, value));
          Result := True;
        end,
      procedure begin _OnComplete(LCookies); end
    )
  );
end;

procedure GetCookies(const _Ctx: ICefRequestContext; const _Url: string; _OnComplete: TProc<TList<TCookie>>);
var
  LCookieMgr: ICefCookieManager;
  LCookies: TList<TCookie>;
begin
  LCookieMgr := _Ctx.GetCookieManager(nil);
  LCookies := TList<TCookie>.Create;
  LCookieMgr.VisitUrlCookies(_Url, True,
    TCustomCookieVisitor.Create(
      function(const _name, _value, _domain, _path: ustring;
        _secure, _httponly, _hasExpires: Boolean;
        const _creation, _lastAccess, _expires: TDateTime; _count, _total: Integer;
        _same_site: TCefCookieSameSite; _priority: TCefCookiePriority;
        out _deleteCookie: Boolean): Boolean
        begin
          if _count = 0 then
            LCookies.Count := _total;
          with LCookies.List[_count] do
          begin
            name        := _name;
            value       := _value;
            domain      := _domain;
            path        := _path;
            creation    := _creation;
            last_access := _lastAccess;
            expires     := _expires;
            secure      := _secure;
            httponly    := _httponly;
            has_expires := _hasExpires;
            same_site   := _same_site;
            priority    := _priority;
          end;
          Result := True;
        end,
      procedure begin _OnComplete(LCookies); end
    )
  );
end;

procedure GetCookies(const _Ctx: ICefRequestContext; const _Url: string;
  const _Names: array of string; _OnComplete: TProc<TDictionary<string,string>>);
var
  LCookieMgr: ICefCookieManager;
  LCookieMap: TDictionary<string, string>;
  LName: string;
  n: Integer;
begin
  LCookieMap := TDictionary<string, string>.Create;
  for LName in _Names do
    LCookieMap.Add(LName, '');
  LCookieMgr := _Ctx.GetCookieManager(nil);
  LCookieMgr.VisitUrlCookies(_Url, True,
    TCustomCookieVisitor.Create(
      function(const _name, _value, _domain, _path: ustring;
        _secure, _httponly, _hasExpires: Boolean;
        const _creation, _lastAccess, _expires: TDateTime; _count, _total: Integer;
        _same_site: TCefCookieSameSite; _priority: TCefCookiePriority;
        out _deleteCookie: Boolean): Boolean
        begin
          if LCookieMap.ContainsKey(_name) then
          begin
            LCookieMap[_name] := _value;
            Inc(n);
          end;
          Result := n < LCookieMap.count;
        end,
      procedure begin _OnComplete(LCookieMap); end
    )
  );
end;

type
  TCustomRequestContextHandler = class(TCefRequestContextHandlerOwn)
  private
    FOnInit: TProc<ICefRequestContext>;
  protected
    procedure OnRequestContextInitialized(const _Ctx: ICefRequestContext); override;
  public
    constructor Create(const _OnInit: TProc<ICefRequestContext>); reintroduce;
  end;

procedure CreateRequestContext(const _CachePath: ustring;
const _AcceptLanguageList: ustring; const _CookieableSchemesList: ustring;
const _CookieableSchemesExcludeDefaults: Boolean;
_PersistSessionCookies: Boolean; _PersistUserPreferences: Boolean;
cb: TProc<ICefRequestContext>);
var
  LSettings: TCefRequestContextSettings;
begin
  LSettings.size := SizeOf(LSettings);
  LSettings.cache_path := CefString(_CachePath);
  LSettings.persist_session_cookies := Ord(_PersistSessionCookies);
  LSettings.persist_user_preferences := Ord(_PersistUserPreferences);
  LSettings.accept_language_list := CefString(_AcceptLanguageList);
  LSettings.cookieable_schemes_list := CefString(_CookieableSchemesList);
  LSettings.cookieable_schemes_exclude_defaults :=
    Ord(_CookieableSchemesExcludeDefaults);

  TCefRequestContextRef.New(@LSettings, TCustomRequestContextHandler.Create(cb));
end;

function DumpStringMultimap(const m: ICefStringMultimap): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to m.Size - 1 do
    Result := Result + m.Key[i] + ': ' + m.Value[i] + #13#10;
end;

function DumpRequest(const r: ICefRequest): string;
var
  i: Integer;
  LHeaders: ICefStringMultimap;
  LPostData: ICefPostData;
  LElements: TCefPostDataElementArray;
  LElement: ICefPostDataElement;
  u8s: UTF8String;
begin
  LHeaders := TCefStringMultimapOwn.Create;
  r.GetHeaderMap(LHeaders);
  Result := r.Method + ' ' + r.Url;
  for i := 0 to LHeaders.Size - 1 do
    Result := Result + #13#10 + LHeaders.Key[i] + ': ' + LHeaders.Value[i];
  LPostData := r.PostData;
  if LPostData <> nil then
  begin
    LPostData.GetElements(LPostData.GetElementCount, LElements);
    for LElement in LElements do
    begin
      if LElement.GetType = PDE_TYPE_BYTES then
      begin
        SetLength(u8s, LElement.GetBytesCount);
        LElement.GetBytes(Length(u8s), Pointer(u8s));
        Result := Result + #13#10 + UTF8ToString(u8s);
      end;
    end;
  end;
end;

function PostDataToString(_PostData: ICefPostData; _ContentType: string): string;
begin
  Result := UTF8ToString(PostDataToByteArray(_PostData));
end;

function PostDataToByteArray(_PostData: ICefPostData): RawByteString;
var
  LElements: TCefPostDataElementArray;
  LElement: ICefPostDataElement;
  n, LOffset: NativeInt;
begin
  Result := '';
  if _PostData <> nil then
  begin
    n := 0;
    LOffset := 0;
    _PostData.GetElements(_PostData.GetElementCount, LElements);
    for LElement in LElements do
    begin
      if LElement.GetType = PDE_TYPE_BYTES then
        Inc(n, LElement.GetBytesCount)
    end;
    SetLength(Result, n);
    for LElement in LElements do
    begin
      if LElement.GetType = PDE_TYPE_BYTES then
      begin
        LElement.GetBytes(LElement.GetBytesCount, PAnsiChar(Pointer(Result)) + LOffset);
        Inc(LOffset, LElement.GetBytesCount);
      end;
    end;
  end;
end;

{ TCustomRequestContextHandler }

constructor TCustomRequestContextHandler.Create(const _OnInit: TProc<ICefRequestContext>);
begin
  inherited Create;
  FOnInit := _OnInit;
end;

procedure TCustomRequestContextHandler.OnRequestContextInitialized(const _Ctx: ICefRequestContext);
begin
  inherited;
  FOnInit(_Ctx);
end;

{ TCustomCookieVisitor }

function cef_cookie_visitor_visit(self: PCefCookieVisitor; const cookie : PCefCookie;
  count, total: Integer; deleteCookie : PInteger): Integer; stdcall;
var
  delete     : Boolean;
  exp        : TDateTime;
  TempObject : TObject;
begin
  delete     := False;
  Result     := Ord(True);
  TempObject := CefGetObject(self);
  if (cookie^.has_expires <> 0) then
    exp := CefTimeToDateTime(cookie^.expires)
   else
    exp := 0;

  if (TempObject <> nil) and (TempObject is TCustomCookieVisitor) then
    Result := Ord(TCustomCookieVisitor(TempObject).visit(CefString(@cookie^.name),
                                                         CefString(@cookie^.value),
                                                         CefString(@cookie^.domain),
                                                         CefString(@cookie^.path),
                                                         Boolean(cookie^.secure),
                                                         Boolean(cookie^.httponly),
                                                         Boolean(cookie^.has_expires),
                                                         CefTimeToDateTime(cookie^.creation),
                                                         CefTimeToDateTime(cookie^.last_access),
                                                         exp,
                                                         count,
                                                         total,
                                                         cookie^.same_site,
                                                         cookie^.priority,
                                                         delete));

  deleteCookie^ := Ord(delete);
end;

constructor TCustomCookieVisitor.Create(_VisitProc: TCefCookieVisitorProc; _OnFinished: TProc);
begin
  inherited CreateData(SizeOf(TCefCookieVisitor));
  PCefCookieVisitor(FData)^.visit := cef_cookie_visitor_visit;
  FVisitProc := _VisitProc;
  FOnFinished := _OnFinished;
end;

destructor TCustomCookieVisitor.Destroy;
begin
  if Assigned(FOnFinished) then
    FOnFinished();
  inherited;
end;

function TCustomCookieVisitor.visit(const name, value, domain, path: ustring; secure, httponly, hasExpires: Boolean;
  const creation, lastAccess, expires: TDateTime; count, total: Integer; same_site: TCefCookieSameSite;
  priority: TCefCookiePriority; out deleteCookie: Boolean): Boolean;
begin
  Result := FVisitProc(name, value, domain, path, secure, httponly, hasExpires, creation, lastAccess, expires,
    count, total, same_site, priority, deleteCookie);
end;

initialization
  EMPTY_SET_COOKIE_CALLBACK :=  procedure(_: Boolean) begin end;
  G_CEFInitCallbacks := TList<TProc>.Create;

finalization
  G_CEFInitCallbacks.Free;

end.