unit DSLAsyncWinHttp;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  WinAPI.WinHttp,
  DSLWinHttp,
  DSLHttpIntf;

type
  TWinHttpClient = class(TInterfacedObject, IHttpClient)
  public
    constructor Create(const _UserAgent: string);
    destructor Destroy; override;
    procedure DoRequest(const _Req: IHttpRequest; _Callbacks: IHttpRequestCallbacks);
  end;

implementation

{ TWinHttpClient }

constructor TWinHttpClient.Create(const _UserAgent: string);
begin

end;

destructor TWinHttpClient.Destroy;
begin

  inherited;
end;

procedure TWinHttpClient.DoRequest(const _Req: IHttpRequest; _Callbacks: IHttpRequestCallbacks);
begin

end;

end.
