unit DSLVcl;

interface

uses
  SysUtils, Windows, Messages, Controls, Dialogs, Graphics, Forms, ComCtrls, CommCtrl, ComObj,
  DSLUtils;

procedure MsgSleep(period: DWORD);
function ControlFindContainer(control: TControl; cls: TClass): TWinControl;
function ControlFindChild(container: TWinControl; cls: TClass): TControl;
function ControlVisible(ctrl: TControl): Boolean;
procedure ControlSetFocus(ctrl: TWinControl);
procedure EditSetNumberOnly(edit: TWinControl);
procedure CloseForm(form: TCustomForm);
procedure SetModalResult(form: TCustomForm; mr: TModalResult);
procedure ShowForm(form: TCustomForm);
procedure ListViewSetRowCount(ListView: TListView; count: Integer);

type
  TConfirmDlgButtons = (cdbOK, cdbOKCancel, cdbAbortRetryIgnore, cdbYesNoCancel, cdbYesNo, cdbRetryCancel);

  TConfirmDlgResult = (cdrOK, cdrCancel, cdrAbort, cdrRetry, cdrIgnore, cdrYes, cdrNo, cdrClose, cdrHelp, cdrTryAgain,
    cdrContinue);

function ConfirmDialog(const msg: string; const parent: THandle = 0; const title: string = '';
  const buttons: TConfirmDlgButtons = cdbYesNo): TConfirmDlgResult;

procedure ShowMessageEx(const v: TAnsiCharSection); overload;
procedure ShowMessageEx(const v: string); overload;
procedure ShowMessageEx(const v: RawByteString); overload;
procedure ShowMessageEx(v: Integer); overload;
procedure ShowMessageEx(v: Int64); overload;
procedure ShowMessageEx(v: Double); overload;
procedure ShowMessageEx(v: Extended); overload;
procedure ShowMessageEx(v: Real); overload;
//procedure ShowMessageEx(v: Real48); overload;
procedure ShowMessageEx(v: Boolean); overload;

implementation

procedure MsgSleep(period: DWORD);
var
  tick, remain, ellapse, wr: DWORD;
  events: array [0 .. 0] of THandle;
begin
  if RunningInMainThread then
  begin
    events[0] := CreateEvent(nil, False, False, nil);

    try
      tick := GetTickCount;

      while not Application.Terminated do
      begin
        ellapse := GetTickCount - tick;

        if ellapse >= period then
          Break;

        remain := period - ellapse;

        wr := MsgWaitForMultipleObjects(1, events, False, remain, QS_ALLINPUT);

        if wr = WAIT_TIMEOUT then
          Break;

        if wr = WAIT_OBJECT_0 + 1 then
          try
            Application.ProcessMessages;
          except

          end;
      end;
    finally
      CloseHandle(events[0]);
    end;
  end
  else
    Windows.Sleep(period);
end;


function ControlFindContainer(control: TControl; cls: TClass): TWinControl;
begin
  Result := control.parent;
  while Assigned(Result) do
  begin
    if not Assigned(cls) or (Result is cls) then
      Break;

    Result := Result.parent;
  end;
end;

function ControlFindChild(container: TWinControl; cls: TClass): TControl;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to container.ControlCount - 1 do
  begin
    if container.Controls[i].InheritsFrom(cls) then
    begin
      Result := container.Controls[i];
      Break;
    end;
  end;
end;

function ControlVisible(ctrl: TControl): Boolean;
begin
  while Assigned(ctrl) and ctrl.Visible do
    ctrl := ctrl.parent;

  Result := not Assigned(ctrl);
end;

procedure ControlSetFocus(ctrl: TWinControl);
begin
  try
    if ControlVisible(ctrl) then
      ctrl.SetFocus;
  except

  end;
end;

procedure EditSetNumberOnly(edit: TWinControl);
begin
  SetWindowLong(edit.handle, GWL_STYLE, GetWindowLong(edit.handle, GWL_STYLE) or ES_NUMBER);
end;

procedure CloseForm(form: TCustomForm);
begin
  if fsModal in form.FormState then
    form.ModalResult := mrCancel
  else
    form.Close;
end;

procedure SetModalResult(form: TCustomForm; mr: TModalResult);
begin
  if fsModal in form.FormState then
    form.ModalResult := mr
  else
    form.Close;
end;


type
  TWinCtrlHack = class(TWinControl);

procedure ShowForm(form: TCustomForm);
begin
  form.Visible := True;
  if IsIconic(TWinCtrlHack(form).WindowHandle) then
    form.Perform(WM_SYSCOMMAND, SC_RESTORE, 0);
  form.BringToFront;
  SetForegroundWindow(TWinCtrlHack(form).WindowHandle);
end;

procedure ListViewSetRowCount(ListView: TListView; count: Integer);
var
  TopIndex, ItemIndex: Integer;
begin
  if ListView.items.count <> count then
  begin
    try
      TopIndex := ListView_GetTopIndex(ListView.handle);
      ItemIndex := ListView.ItemIndex;
      ListView.items.count := count;

      if TopIndex <> -1 then
      begin
        TopIndex := TopIndex + ListView.VisibleRowCount - 1;

        if TopIndex >= count then
          TopIndex := count - 1;

        if TopIndex <> -1 then
          ListView.items[TopIndex].MakeVisible(False);
      end;

      if ItemIndex >= count then
        ItemIndex := count - 1;

      ListView.ItemIndex := ItemIndex;
    except
    end;
  end;

  ListView.Refresh;
end;

function ConfirmDialog(const msg: string; const parent: THandle = 0; const title: string = '';
  const buttons: TConfirmDlgButtons = cdbYesNo): TConfirmDlgResult;
var
  _title: string;
begin
  if title = '' then
    _title := 'х╥хо'
  else
    _title := title;

  Result := TConfirmDlgResult(Application.MessageBox(PChar(msg), PChar(_title), MB_ICONQUESTION or Ord(buttons)) - 1);
end;

procedure ShowMessageEx(const v: string);
begin
  ShowMessage(v);
end;

procedure ShowMessageEx(const v: RawByteString); overload;
begin
  ShowMessage(string(v));
end;

procedure ShowMessageEx(const v: TAnsiCharSection);
begin
  ShowMessage(string(v.toString));
end;

procedure ShowMessageEx(v: Integer);
begin
  ShowMessage(IntToStr(v));
end;

procedure ShowMessageEx(v: Int64);
begin
  ShowMessage(IntToStr(v));
end;

procedure ShowMessageEx(v: Double);
begin
  ShowMessage(FloatToStr(v));
end;

procedure ShowMessageEx(v: Extended);
begin
  ShowMessage(FloatToStr(v));
end;

procedure ShowMessageEx(v: Real);
begin
  ShowMessage(FloatToStr(v));
end;

procedure ShowMessageEx(v: Boolean);
begin
  if v then
    ShowMessage('true')
  else
    ShowMessage('false');
end;

end.
