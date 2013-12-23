unit DSLTrayIcon;

interface

uses
  SysUtils, Classes, Windows, Graphics, Messages, Forms, Menus;

{ Tray notification definitions }

const
  NIM_ADD         = $00000000;
  NIM_MODIFY      = $00000001;
  NIM_DELETE      = $00000002;
  NIM_SETFOCUS    = $00000003;
  NIM_SETVERSION  = $00000004;

  NIF_MESSAGE     = $00000001;
  NIF_ICON        = $00000002;
  NIF_TIP         = $00000004;
  NIF_STATE       = $00000008;
  NIF_INFO        = $00000010;

  NIIF_NONE       = $00000000;
  NIIF_INFO       = $00000001;
  NIIF_WARNING    = $00000002;
  NIIF_ERROR      = $00000003;
  NIIF_ICON_MASK  = $0000000F;

  NIN_SELECT      = $0400;
  NINF_KEY        =  $1;
  NIN_KEYSELECT   = NIN_SELECT or NINF_KEY;

  NIN_BALLOONSHOW       = $0400 + 2;
  NIN_BALLOONHIDE       = $0400 + 3;
  NIN_BALLOONTIMEOUT    = $0400 + 4;
  NIN_BALLOONUSERCLICK  = $0400 + 5;

type
  TNotifyIconDataA = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of AnsiChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of AnsiChar;
    uTimeout: UINT;
    szInfoTitle: array [0..63] of AnsiChar;
    dwInfoFlags: DWORD;
  end;
  
  TNotifyIconDataW = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of WideChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of WideChar;
    uTimeout: UINT;
    szInfoTitle: array [0..63] of WideChar;
    dwInfoFlags: DWORD;
  end;

  {$ifdef unicode}
  TNotifyIconData = TNotifyIconDataW;
  {$else}
  TNotifyIconData = TNotifyIconDataA;
  {$endif}
  PNotifyIconDataA = ^TNotifyIconDataA;
  PNotifyIconDataW = ^TNotifyIconDataW;
  PNotifyIconData = TNotifyIconData;

  TBalloonFlags = (bfNone = NIIF_NONE, bfInfo = NIIF_INFO,
    bfWarning = NIIF_WARNING, bfError = NIIF_ERROR);
  
  TDSLTrayIcon = class(TComponent)
  private
    fUpdateCount: Integer;
    fVisible: Boolean;
    fHint: string;
    fIcon: TIcon;
    fCurrentVisible: Boolean;
    fOnRightClick: TNotifyEvent;
    fOnDblClick: TNotifyEvent;
    fOnClick: TNotifyEvent;
    fBalloonFlags: TBalloonFlags;
    fBalloonHint: string;
    fBalloonTitle: string;
    fData: TNotifyIconData;
    fPopupMenu: TPopupMenu;
    FDesignPreview: Boolean;
    procedure SetVisible(const Value: Boolean);
    procedure SetIcon(const Value: TIcon);
    procedure SetHint(const Value: string);
    procedure SetBalloonHint(const Value: string);
    function GetBalloonTimeout: Integer;
    procedure SetBalloonTimeout(const Value: Integer);
    procedure SetBalloonTitle(const Value: string);
    procedure SetPopupMenu(const Value: TPopupMenu);
    procedure SetDesignPreview(const Value: Boolean);
  protected
    procedure Update;
    procedure DoClick;
    procedure DoRightClick;
    procedure DoDblClick;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function MainWndMsgHook(var Msg: TMessage): Boolean;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure ShowBalloonHint;
    procedure HideBalloonHint;
  published
    property Icon: TIcon read fIcon write SetIcon;
    property Hint: string read fHint write SetHint;
    property DesignPreview: Boolean read FDesignPreview write SetDesignPreview;
    property Visible: Boolean read fVisible write SetVisible;
    property BalloonHint: string read FBalloonHint write SetBalloonHint;
    property BalloonTitle: string read FBalloonTitle write SetBalloonTitle;
    property BalloonTimeout: Integer read GetBalloonTimeout write SetBalloonTimeout default 3000;
    property BalloonFlags: TBalloonFlags read FBalloonFlags write FBalloonFlags default bfNone;
    property PopupMenu: TPopupMenu read fPopupMenu write SetPopupMenu;
    property OnClick: TNotifyEvent read fOnClick write fOnClick;
    property OnDblClick: TNotifyEvent read fOnDblClick write fOnDblClick;
    property OnRightClick: TNotifyEvent read fOnRightClick write fOnRightClick;
  end;

implementation

const
  TASKBAR_CREATED_MESSAGE = 'TaskbarCreated';
  CM_NOTIFY_ICON = WM_APP + 20;

var
  WM_TASKBAR_CREATED: DWORD;


{$ifdef unicode}
function Shell_NotifyIcon(dwMessage: DWORD; lpData: PNotifyIconDataW): BOOL;
  stdcall; external 'shell32.dll' name 'Shell_NotifyIconW';
{$else}
function Shell_NotifyIcon(dwMessage: DWORD; lpData: PNotifyIconDataA): BOOL;
  stdcall; external 'shell32.dll' name 'Shell_NotifyIconA';
{$endif}

function Shell_NotifyIconW(dwMessage: DWORD; lpData: PNotifyIconDataW): BOOL;
  stdcall; external 'shell32.dll' name 'Shell_NotifyIconW';

function Shell_NotifyIconA(dwMessage: DWORD; lpData: PNotifyIconDataA): BOOL;
  stdcall; external 'shell32.dll' name 'Shell_NotifyIconA';

{ TDSLTrayIcon }

constructor TDSLTrayIcon.Create(AOwner: TComponent);
begin
  inherited;
  fCurrentVisible := False;
  fVisible := False;
  fIcon := TIcon.Create;
  fIcon.Assign(Application.Icon);
  fVisible := False;
  fHint := Application.Title;
  Application.HookMainWindow(Self.MainWndMsgHook);
  FillChar(fData, SizeOf(fData), 0);
  fData.cbSize := SizeOf(fData);
  fData.uID := Integer(Self);
  fData.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
  fData.Wnd := Application.Handle;
  fData.uCallBackMessage := CM_NOTIFY_ICON;
  fData.hIcon := fIcon.Handle;
  fData.uTimeout := 3000;
  StrPCopy(fData.szTip, fHint);
end;

destructor TDSLTrayIcon.Destroy;
begin
  SetVisible(False);
  Application.UnhookMainWindow(Self.MainWndMsgHook);
  fIcon.Free;
  inherited;
end;

procedure TDSLTrayIcon.DoClick;
begin
  if Assigned(fOnClick) then
    fOnClick(Self);
end;

procedure TDSLTrayIcon.DoDblClick;
begin
  if Assigned(fOnDblClick) then
    fOnDblClick(Self);
end;

procedure TDSLTrayIcon.DoRightClick;
var
  pt: TPoint;
begin
  if Assigned(fPopupMenu) then
  begin
    GetCursorPos(pt);
    //GetMsgCursor(pt);
    fPopupMenu.Popup(pt.X, pt.Y);
  end;
  if Assigned(fOnRightClick) then
    fOnRightClick(Self);
end;

function TDSLTrayIcon.MainWndMsgHook(var Msg: TMessage): Boolean;
begin
  if Msg.Msg = WM_TASKBAR_CREATED then
  begin
    Msg.Result := 1;
    fCurrentVisible := False;
    Update;
    Result := True;
  end
  else if (Msg.Msg = CM_NOTIFY_ICON) and (UINT(Msg.WParam) = fData.uID) then
  begin
    case Msg.LParam of
      WM_RBUTTONDOWN: DoRightClick;
      WM_LBUTTONDBLCLK: DoDblClick;
      WM_LBUTTONDOWN: DoClick;
    end;
    Result := True;
  end
  else Result := False;
end;

procedure TDSLTrayIcon.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  if (AOperation = opRemove) and (AComponent = fPopupMenu) then
    fPopupMenu := nil;
  inherited;
end;

function TDSLTrayIcon.GetBalloonTimeout: Integer;
begin
  Result := fData.uTimeout;
end;

procedure TDSLTrayIcon.HideBalloonHint;
begin
  fData.uFlags := fData.uFlags and not NIF_INFO;
  Update;
end;

procedure TDSLTrayIcon.Loaded;
begin
  inherited;
  Update;
end;

procedure TDSLTrayIcon.SetIcon(const Value: TIcon);
begin
  if Value <> fIcon then
  begin
    if Assigned(Value) then
    begin
      fIcon.Assign(Value);
      fData.hIcon := fIcon.Handle;
    end
    else begin
      fData.hIcon := 0;
      fData.uFlags := fData.uFlags and not NIF_ICON;
    end;
    Update;
  end;
end;

procedure TDSLTrayIcon.SetPopupMenu(const Value: TPopupMenu);
begin
  if fPopupMenu <> Value then
  begin
    if Assigned(fPopupMenu) then
      fPopupMenu.RemoveFreeNotification(Self);
    fPopupMenu := Value;
    if Assigned(fPopupMenu) then
      fPopupMenu.FreeNotification(Self);
  end;
end;

procedure TDSLTrayIcon.SetBalloonHint(const Value: string);
begin
  fBalloonHint := Value;
  StrPLCopy(fData.szInfo, fBalloonHint, SizeOf(fData.szInfo) - 1);
end;

procedure TDSLTrayIcon.SetBalloonTimeout(const Value: Integer);
begin
  fData.uTimeout := Value;
end;

procedure TDSLTrayIcon.SetBalloonTitle(const Value: string);
begin
  fBalloonTitle := Value;
  StrPLCopy(FData.szInfoTitle, fBalloonTitle, SizeOf(FData.szInfoTitle) - 1);
end;

procedure TDSLTrayIcon.SetDesignPreview(const Value: Boolean);
begin
  if FDesignPreview <> Value then
  begin
    FDesignPreview := Value;
    if csDesigning in Self.ComponentState then Update;
  end;
end;

procedure TDSLTrayIcon.SetHint(const Value: string);
begin
  if CompareStr(FHint, Value) <> 0 then
  begin
    fHint := Value;
    StrPLCopy(fData.szTip, fHint, SizeOf(fData.szTip) - 1);

    if Length(fHint) > 0 then
      fData.uFlags := fData.uFlags or NIF_TIP
    else
      fData.uFlags := fData.uFlags and not NIF_TIP;

    Update;
  end;
end;

procedure TDSLTrayIcon.SetVisible(const Value: Boolean);
begin
  if fVisible <> Value then
  begin
    fVisible := Value;
    Update;
  end;
end;

procedure TDSLTrayIcon.ShowBalloonHint;
begin
  fData.uFlags := fData.uFlags or NIF_INFO;
  fData.dwInfoFlags := Integer(FBalloonFlags);
  Update;
  fData.uFlags := fData.uFlags and not NIF_INFO;
end;

procedure TDSLTrayIcon.BeginUpdate;
begin
  Inc(fUpdateCount);
end;

procedure TDSLTrayIcon.EndUpdate;
begin
  if fUpdateCount > 0 then
  begin
    Dec(fUpdateCount);
    if fUpdateCount = 0 then Update;
  end;
end;

procedure TDSLTrayIcon.Update;
var
  NewVisible: Boolean;
begin     
  if not (csReading in ComponentState) and (fUpdateCount = 0) then
  begin
    NewVisible := fVisible and (not (csDesigning in ComponentState)
      or FDesignPreview);
    if fCurrentVisible then
    begin
      if NewVisible then
        Shell_NotifyIcon(NIM_MODIFY, @fData)
      else
        Shell_NotifyIcon(NIM_DELETE, @fData);
    end
    else if NewVisible then
      Shell_NotifyIcon(NIM_ADD, @fData);
    fCurrentVisible := NewVisible;
  end;
end;

initialization
  WM_TASKBAR_CREATED := RegisterWindowMessage(TASKBAR_CREATED_MESSAGE);
  
end.
