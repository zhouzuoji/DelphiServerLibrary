unit DSLVclApp;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  Windows,
  Forms,
  DSLUtils,
  Messages;

type
  TMessageHandler = reference to procedure(var _Msg: TMessage);

function RegisterMsgHandler(const _UniqueMsgName: string; _Handler: TMessageHandler): Cardinal;
procedure ExecOnMainThread(_Proc: TProc);

implementation

type
  TVclApp = class
  private
    CM_EXEC_ON_MAIN_THREAD: Cardinal;
    FMsgHandlers: TDictionary<Cardinal, TMessageHandler>;
    procedure OnExecOnMainThread(var _Msg: TMessage);
    function AppMsgFilter(var _Msg: TMessage): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function RegisterMsgHandler(const _UniqueMsgName: string;
      _Handler: TMessageHandler): Cardinal;
    procedure ExecOnMainThread(_Proc: TProc);
  end;

var
  G_App: TVclApp;

function RegisterMsgHandler(const _UniqueMsgName: string; _Handler: TMessageHandler): Cardinal;
begin
  Result := G_App.RegisterMsgHandler(_UniqueMsgName, _Handler);
end;

procedure ExecOnMainThread(_Proc: TProc);
begin
  G_App.ExecOnMainThread(_Proc);
end;

{ TVclApp }

constructor TVclApp.Create;
begin
  inherited Create;
  FMsgHandlers := TDictionary<Cardinal, TMessageHandler>.Create;
  Application.HookMainWindow(Self.AppMsgFilter);
  CM_EXEC_ON_MAIN_THREAD := RegisterMsgHandler('__exec_on_main_thread__', OnExecOnMainThread);
end;

destructor TVclApp.Destroy;
begin
  Application.UnhookMainWindow(Self.AppMsgFilter);
  FMsgHandlers.Free;
  inherited;
end;

procedure TVclApp.ExecOnMainThread(_Proc: TProc);
var
  I: IUnknown absolute _Proc;
begin
  I._AddRef;
  PostMessage(Application.Handle, CM_EXEC_ON_MAIN_THREAD, 0, LPARAM(I));
end;

procedure TVclApp.OnExecOnMainThread(var _Msg: TMessage);
var
  LProc: TProc;
  P: Pointer absolute LProc;
begin
  P := Pointer(_Msg.LParam);
  if Assigned(LProc) then
    LProc();
end;

function TVclApp.RegisterMsgHandler(const _UniqueMsgName: string; _Handler: TMessageHandler): Cardinal;
begin
  Result := RegisterWindowMessage(PChar(_UniqueMsgName));
  if Result = 0 then
    RaiseLastOSError;
  FMsgHandlers.Add(Result, _Handler);
end;

function TVclApp.AppMsgFilter(var _Msg: TMessage): Boolean;
var
  h: TMessageHandler;
begin
  Result := FMsgHandlers.TryGetValue(_Msg.Msg, h);
  if Result then
    h(_Msg);
end;

initialization
  G_App := TVclApp.Create;

finalization
  FreeAndNil(G_App);

end.
