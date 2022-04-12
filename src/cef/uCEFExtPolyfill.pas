unit uCEFExtPolyfill;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Clipbrd,
  Contnrs, SyncObjs, Generics.Collections, Generics.Defaults,
  superobject, uCEFWinControl, uCEFWindowParent, uCEFChromiumCore, uCEFChromium,
  uCEFInterfaces, uCEFTypes, uCEFConstants, uCEFApplication, uCEFMiscFunctions,
  uCEFTask;

type
  TPageMsgHandler = reference to procedure(const browser: ICefBrowser; const frame: ICefFrame; const msg: ISuperObject);
  TPageRespHandler = reference to procedure(const browser: ICefBrowser; const frame: ICefFrame; errCode: Integer; const resp: ISuperObject);

procedure FrameLoadEnd(const frame: ICefFrame);
procedure FrameDetached(const frame: ICefFrame);
function FilterConsoleMessage(const browser: ICefBrowser; const msg: string): Boolean;
procedure SendResponse(pageID, reqID: Integer; const resp: ISuperObject); overload;
procedure SendResponse(const req, resp: ISuperObject); overload;
procedure SendRequest(const frame: ICefFrame; const req: ISuperObject; const handler: TPageRespHandler);
procedure NotifyPage(pageID: Integer; const msg: ISuperObject);

var
  OnPage2ExtMsg: TPageMsgHandler;
  OnPageNotify: TPageMsgHandler;
  OnPageResp: TPageRespHandler;

implementation

uses
  StrUtils;

var
  PageID: Integer;
  FramePageMapLock: TCriticalSection;
  PageID2Frame: TDictionary<Integer, ICefFrame>;
  FrameID2PageID: TDictionary<Int64, Integer>;
  PageRespHandlers: TDictionary<Integer, TPageRespHandler>;
  ReqIDSedd: Integer;

procedure FrameLoadEnd(const frame: ICefFrame);
var
  curPageID: Integer;
  frameID: Int64;
begin
  frameID := frame.Identifier;
  curPageID := InterlockedIncrement(PageID);
  FramePageMapLock.Enter;
  try
    PageID2Frame.Add(curPageID, frame);
    FrameID2PageID.AddOrSetValue(frameID, curPageID);
  finally
    FramePageMapLock.Leave;
  end;
  frame.ExecuteJavaScript('window.__pageId__=' + IntToStr(curPageID), '', 0);
end;

procedure FrameDetached(const frame: ICefFrame);
var
  pageID: Integer;
  frameID: Int64;
begin
  frameID := frame.Identifier;
  FramePageMapLock.Enter;
  try
    if FrameID2PageID.TryGetValue(frameID, pageID) then
    begin
      FrameID2PageID.Remove(frameID);
      PageID2Frame.Remove(pageID);
    end;
  finally
    FramePageMapLock.Leave;
  end;
end;

function FilterConsoleMessage(const browser: ICefBrowser; const msg: string): Boolean;
const
  MSG_TAG = '__request_from_page__';
  RESP_FROM_PAGE = '__response_from_page__';
  NOTIFICATION_FROM_PAGE = '__notification_from_page__';
var
  json: string;
  jo: ISuperObject;
  pageID, reqId: Integer;
  frame: ICefFrame;
  handler: TPageRespHandler;
begin
  Result := StartsStr(MSG_TAG, msg);
  if Result then
  begin
    json := Copy(msg, Length(MSG_TAG) + 1, MaxInt);
    jo := SO(json);
    pageID := jo.I['pageId'];
    if PageID2Frame.TryGetValue(pageID, frame) and frame.IsValid and Assigned(OnPage2ExtMsg) then
      OnPage2ExtMsg(browser, frame, jo);
    Exit;
  end;

  Result := StartsStr(RESP_FROM_PAGE, msg);
  if Result then
  begin
    json := Copy(msg, Length(RESP_FROM_PAGE) + 1, MaxInt);
    jo := SO(json);
    pageID := jo.I['pageId'];
    reqId := jo.I['reqId'];
    if PageID2Frame.TryGetValue(pageID, frame) and frame.IsValid and PageRespHandlers.TryGetValue(reqId, handler) then
      handler(browser, frame, jo.I['code'], jo.O['resp']);
    Exit;
  end;

  Result := StartsStr(NOTIFICATION_FROM_PAGE, msg);
  if Result then
  begin
    json := Copy(msg, Length(RESP_FROM_PAGE) + 1, MaxInt);
    jo := SO(json);
    pageID := jo.I['pageId'];
    if PageID2Frame.TryGetValue(pageID, frame) and frame.IsValid and Assigned(OnPageNotify) then
      OnPageNotify(browser, frame, jo.O['msg']);
    Exit;
  end;
end;

procedure SendRequest(const frame: ICefFrame; const req: ISuperObject; const handler: TPageRespHandler);
begin
  if frame.IsValid then
  begin
    CefPostTask(TID_UI, TCefFastTask.Create(procedure
    var
      script: string;
      s: ISuperObject;
      reqID: Integer;
    begin
      reqID := InterlockedIncrement(ReqIDSedd);
      PageRespHandlers.AddOrSetValue(reqID, handler);
      s := TSuperObject.Create(req.AsJSon(False, False));
      script := Format('window._messenger_.sendToPage(%d, JSON.parse(%s))', [reqID, s.AsJSon]);
      frame.ExecuteJavaScript(script, '', 0);
    end));
  end;
end;

procedure NotifyPage(pageID: Integer; const msg: ISuperObject);
var
  script: string;
  s: ISuperObject;
  frame: ICefFrame;
begin
  if PageID2Frame.TryGetValue(pageID, frame) and frame.IsValid then
  begin
    s := TSuperObject.Create(msg.AsJSon(False, False));
    script := Format('window._messenger_.notifyToPage(%d, JSON.parse(%s))', [pageID, s.AsJSon]);
    frame.ExecuteJavaScript(script, '', 0);
  end;
end;

procedure SendResponse(pageID, reqID: Integer; const resp: ISuperObject);
begin
  CefPostTask(TID_UI, TCefFastTask.Create(procedure
  var
    script: string;
    frame: ICefFrame;
    s: ISuperObject;
  begin
    if PageID2Frame.TryGetValue(pageID, frame) and frame.IsValid then
    begin
      if resp = nil then
        script := Format('window._messenger_.recv(%d, %d)', [pageID, reqID])
      else begin
        s := TSuperObject.Create(resp.AsJSon(False, False));
        script := Format('window._messenger_.recv(%d, %d, JSON.parse(%s))', [pageID, reqID, s.AsJSon]);
      end;
      frame.ExecuteJavaScript(script, '', 0);
    end;
  end));
end;

procedure SendResponse(const req, resp: ISuperObject); overload;
begin
  SendResponse(req.I['pageId'], req.I['reqId'], resp);
end;

initialization
  FramePageMapLock := TCriticalSection.Create;
  PageID2Frame := TDictionary<Integer, ICefFrame>.Create;
  FrameID2PageID := TDictionary<Int64, Integer>.Create;
  PageRespHandlers := TDictionary<Integer, TPageRespHandler>.Create;

finalization
  PageID2Frame.Free;
  FrameID2PageID.Free;
  FramePageMapLock.Free;
  PageRespHandlers.Free;

end.
