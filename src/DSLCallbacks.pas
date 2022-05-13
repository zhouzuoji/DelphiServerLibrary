unit DSLCallbacks;

interface

uses
  SysUtils;

procedure ChainCallbacks(const _Callbacks: array of TProc<TProc>; _Then: TProc);
procedure ConcurrentCallbacks(const _Callbacks: array of TProc<TProc>; _Then: TProc);

implementation

procedure _ChainCallbacks(_Callbacks: TArray<TProc<TProc>>; _Then: TProc);
var
  LCurrent: TProc<TProc>;
begin
  LCurrent := _Callbacks[High(_Callbacks)];
  if Length(_Callbacks) = 1 then
  begin
    LCurrent(_Then);
    Exit;
  end;
  SetLength(_Callbacks, High(_Callbacks));
  LCurrent(procedure begin _ChainCallbacks(_Callbacks, _Then); end);
end;

procedure ChainCallbacks(const _Callbacks: array of TProc<TProc>; _Then: TProc);
var
  LCallbacks: TArray<TProc<TProc>>;
  i: Integer;
begin
  if Length(_Callbacks) = 1 then
  begin
    _Callbacks[0](_Then);
    Exit;
  end;

  SetLength(LCallbacks, Length(_Callbacks));
  for i := 0 to Length(_Callbacks) - 1 do
    LCallbacks[i] := _Callbacks[Length(_Callbacks) - 1 - i];
  _ChainCallbacks(LCallbacks, _Then);
end;

procedure ConcurrentCallbacks(const _Callbacks: array of TProc<TProc>; _Then: TProc);
var
  LCount, LDone, i: Integer;
  LCounter: TProc;
begin
  LCount := Length(_Callbacks);
  LDone := 0;
  LCounter := procedure
    begin
      if (AtomicIncrement(LDone) = LCount) and Assigned(_Then) then
        _Then();
    end;
  for i := Low(_Callbacks) to High(_Callbacks) do
    _Callbacks[i](LCounter);
end;

end.
