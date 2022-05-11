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

  TVclApp = class
  private
    class var Instance: TVclApp;
  private
    CM_EXEC_ON_MAIN_THREAD: Cardinal;
    FMsgHandlers: TDictionary<Cardinal, TMessageHandler>;
    procedure OnExecOnMainThread(var _Msg: TMessage);
    function AppMsgFilter(var _Msg: TMessage): Boolean;
  public
    class constructor Create;
    class destructor Destroy;
    constructor Create;
    destructor Destroy; override;
    function RegisterMsgHandler(const _UniqueMsgName: string;
      _Handler: TMessageHandler): Cardinal;
    procedure ExecOnMainThread(_Proc: TProc);
    class function DispatchToMainThread<T>(_Callback: TProc<T>): TProc<T>; overload; static;
    class function DispatchToMainThread<T1, T2>(_Callback: TProc<T1, T2>): TProc<T1, T2>; overload;static;
    class function DispatchToMainThread<T1, T2, T3>(_Callback: TProc<T1, T2, T3>): TProc<T1, T2, T3>; overload; static;
    class function DispatchToMainThread<T1, T2, T3, T4>(_Callback: TProc<T1, T2, T3, T4>): TProc<T1, T2, T3, T4>; overload;static;
  end;

function RegisterMsgHandler(const _UniqueMsgName: string; _Handler: TMessageHandler): Cardinal;
procedure ExecOnMainThread(_Proc: TProc);

implementation

function RegisterMsgHandler(const _UniqueMsgName: string; _Handler: TMessageHandler): Cardinal;
begin
  Result := TVclApp.Instance.RegisterMsgHandler(_UniqueMsgName, _Handler);
end;

procedure ExecOnMainThread(_Proc: TProc);
begin
  TVclApp.Instance.ExecOnMainThread(_Proc);
end;

{ TVclApp }

constructor TVclApp.Create;
begin
  inherited Create;
  FMsgHandlers := TDictionary<Cardinal, TMessageHandler>.Create;
  Application.HookMainWindow(Self.AppMsgFilter);
  CM_EXEC_ON_MAIN_THREAD := RegisterMsgHandler('__exec_on_main_thread__', OnExecOnMainThread);
end;

class constructor TVclApp.Create;
begin
  Instance := TVclApp.Create;
end;

destructor TVclApp.Destroy;
begin
  Application.UnhookMainWindow(Self.AppMsgFilter);
  FMsgHandlers.Free;
  inherited;
end;

class destructor TVclApp.Destroy;
begin
  FreeAndNil(Instance);
end;

class function TVclApp.DispatchToMainThread<T1, T2, T3, T4>(_Callback: TProc<T1, T2, T3, T4>): TProc<T1, T2, T3, T4>;
begin
  Result := procedure(_1: T1; _2: T2; _3: T3; _4: T4)
    begin
      TVclApp.Instance.ExecOnMainThread(procedure begin _Callback(_1, _2, _3, _4) end);
    end;
end;

class function TVclApp.DispatchToMainThread<T1, T2, T3>(_Callback: TProc<T1, T2, T3>): TProc<T1, T2, T3>;
begin
  Result := procedure(_1: T1; _2: T2; _3: T3)
    begin
      TVclApp.Instance.ExecOnMainThread(procedure begin _Callback(_1, _2, _3) end);
    end;
end;

class function TVclApp.DispatchToMainThread<T1, T2>(_Callback: TProc<T1, T2>): TProc<T1, T2>;
begin
  Result := procedure(_1: T1; _2: T2)
    begin
      TVclApp.Instance.ExecOnMainThread(procedure begin _Callback(_1, _2) end);
    end;
end;


class function TVclApp.DispatchToMainThread<T>(_Callback: TProc<T>): TProc<T>;
begin
  Result := procedure(_: T)
    begin
      TVclApp.Instance.ExecOnMainThread(procedure begin _Callback(_) end);
    end;
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

end.
