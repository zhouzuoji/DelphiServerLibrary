unit DSLVclApp;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  Windows,
  Forms,
  Messages,
  DSLUtils,
  superobject;

type
  TMessageHandler = reference to procedure(var _Msg: TMessage);
  TEventHandler = reference to procedure(const _EventName: string; const _Data: ISuperObject);

  TVclApp = class
  private
    class var Instance: TVclApp;
  private
    CM_EXEC_ON_MAIN_THREAD: Cardinal;
    FMsgHandlers: TDictionary<Cardinal, TMessageHandler>;
    FEventHandlers: TDictionary<string, TList<TEventHandler>>;
    procedure OnExecOnMainThread(var _Msg: TMessage);
    function AppMsgFilter(var _Msg: TMessage): Boolean;
  private
    procedure _DispatchEvent(const _EventName: string; const _Data: ISuperObject);
    procedure _AddEventListener(const _EventName: string; const _Handler: TEventHandler);
    procedure _RemoveEventListener(const _EventName: string; const _Handler: TEventHandler);
  public
    class constructor Create;
    class destructor Destroy;
    constructor Create;
    destructor Destroy; override;
    class procedure AddEventListener(const _EventName: string; const _Handler: TEventHandler); static;
    class procedure RemoveEventListener(const _EventName: string; const _Handler: TEventHandler); static;
    class procedure DispatchEvent(const _EventName: string; const _Data: ISuperObject); static;
    function RegisterMsgHandler(const _UniqueMsgName: string;
      _Handler: TMessageHandler): Cardinal;
    procedure ExecOnMainThread(_Proc: TProc);
    class procedure ExecOnMainThreadDelayed(_Delay: Int64; _Proc: TProc); static;
    class procedure ShowMessage(const _Msg: string); static;
    class function DispatchToMainThread<T>(_Callback: TProc<T>): TProc<T>; overload; static;
    class function DispatchToMainThread<T1, T2>(_Callback: TProc<T1, T2>): TProc<T1, T2>; overload;static;
    class function DispatchToMainThread<T1, T2, T3>(_Callback: TProc<T1, T2, T3>): TProc<T1, T2, T3>; overload; static;
    class function DispatchToMainThread<T1, T2, T3, T4>(_Callback: TProc<T1, T2, T3, T4>): TProc<T1, T2, T3, T4>; overload;static;
  end;

function RegisterMsgHandler(const _UniqueMsgName: string; _Handler: TMessageHandler): Cardinal;
procedure ExecOnMainThread(_Proc: TProc);

implementation

uses
  uCEFTypes,
  uCEFTask,
  Dialogs;

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
  FEventHandlers := TDictionary<string, TList<TEventHandler>>.Create;
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
  FreeAndNil(FMsgHandlers);
  FreeAndNil(FEventHandlers);
  inherited;
end;

class destructor TVclApp.Destroy;
begin
  FreeAndNil(Instance);
end;

class procedure TVclApp.DispatchEvent(const _EventName: string; const _Data: ISuperObject);
begin
  if RunningInMainThread then
    Instance._DispatchEvent(_EventName, _Data)
  else
    Instance.ExecOnMainThread(
      procedure
      begin
        Instance._DispatchEvent(_EventName, _Data);
      end
    );
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

class procedure TVclApp.ExecOnMainThreadDelayed(_Delay: Int64; _Proc: TProc);
begin
  TCefFastTask.NewDelayed(TID_UI, _Delay,
    procedure
    begin
      Instance.ExecOnMainThread(_Proc)
    end
  );
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

class procedure TVclApp.RemoveEventListener(const _EventName: string; const _Handler: TEventHandler);
begin
  if RunningInMainThread then
    Instance._RemoveEventListener(_EventName, _Handler)
  else
    Instance.ExecOnMainThread(
      procedure
      begin
        Instance._RemoveEventListener(_EventName, _Handler);
      end
    );
end;

class procedure TVclApp.ShowMessage(const _Msg: string);
begin
  TVclApp.Instance.ExecOnMainThread(procedure begin Dialogs.ShowMessage(_Msg); end);
end;

procedure TVclApp._AddEventListener(const _EventName: string; const _Handler: TEventHandler);
var
  LHandlers: TList<TEventHandler>;
begin
  if not FEventHandlers.TryGetValue(_EventName, LHandlers) then
  begin
    LHandlers := TList<TEventHandler>.Create;
    FEventHandlers.Add(_EventName, LHandlers);
  end;
  if LHandlers.IndexOf(_Handler) = -1 then
    LHandlers.Add(_Handler);
end;

procedure TVclApp._DispatchEvent(const _EventName: string; const _Data: ISuperObject);
var
  LHandlers: TList<TEventHandler>;
  LHandler: TEventHandler;
begin
  if FEventHandlers.TryGetValue(_EventName, LHandlers) then
  begin
    for LHandler in LHandlers do
      try
        LHandler(_EventName, _Data);
      except

      end;
  end;
end;

procedure TVclApp._RemoveEventListener(const _EventName: string; const _Handler: TEventHandler);
var
  LHandlers: TList<TEventHandler>;
begin
  if FEventHandlers.TryGetValue(_EventName, LHandlers) then
    LHandlers.Remove(_Handler);
end;

class procedure TVclApp.AddEventListener(const _EventName: string; const _Handler: TEventHandler);
begin
  if RunningInMainThread then
    Instance._AddEventListener(_EventName, _Handler)
  else
    Instance.ExecOnMainThread(
      procedure
      begin
        Instance._AddEventListener(_EventName, _Handler);
      end
    );
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
