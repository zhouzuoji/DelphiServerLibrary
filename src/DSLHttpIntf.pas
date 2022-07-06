unit DSLHttpIntf;

interface

uses
  SysUtils,
  Classes;

type
  THttpReqFlag = (hrfSkipCache, hrfOnlyFromCache, hrfDisableCache, hrfCookie, hrfUploadProcess, hrfNoDownload, hrfNoRetryOn5XX, hrfNoRedirect);
  THttpReqFlags = set of THttpReqFlag;

  IHttpRequest = interface
    ['{775E5AA8-23FD-4D50-836B-D30C13182E48}']
    function IsReadOnly: Boolean;
    function  GetUrl: string;
    procedure SetUrl(const _Value: string);
    function  GetMethod: string;
    procedure SetMethod(const _Value: string);
    function  GetReferrer: string;
    procedure SetReferrer(const _Value: string);
    function  GetHeaderArray(const _Name: string): TArray<string>;
    function  GetHeader(const _Name: string): string;
    procedure SetHeader(const _Name, _Value: string; _Overwrite: Boolean);
    function  GetFlags: THttpReqFlags;
    procedure SetFlags(_Flags: THttpReqFlags);

    property Url: string read GetUrl write SetUrl;
    property Method: string read GetMethod write SetMethod;
    property Referrer: string read GetReferrer write SetReferrer;
    property Flags: THttpReqFlags read GetFlags write SetFlags;
  end;

  THttpReqStatus = (
    hrsUnknown = 0,
    hrsSuccess,
    hrsPending,
    hrsCanceled,
    hrsFailed
  );

  THttpReqErrCode = Integer;

  IHttpResponse = interface
    ['{80DACF6B-7BB4-4181-9057-D8FF309D70E0}']
    function  IsReadOnly: Boolean;
    function  GetErrCode: THttpReqErrCode;
    procedure SetErrCode(_Code: THttpReqErrCode);
    function  GetStatus: THttpReqStatus;
    procedure SetStatus(_Status: THttpReqStatus);
    function  GetStatusText: string;
    procedure SetStatusText(const _StatusText: string);
    function  GetMimeType: string;
    procedure SetMimeType(const _MimeType: string);
    function  GetCharset: string;
    procedure SetCharset(const _Charset: string);
    function  GetHeaderArray(const _Name: string): TArray<string>;
    function  GetHeader(const _Name: string): string;
    procedure SetHeader(const _Name, _Value: string; _Overwrite: Boolean);
    function  GetURL: string;
    procedure SetURL(const _Url: string);

    property Status: THttpReqStatus read GetStatus write SetStatus;
    property StatusText: string read GetStatusText  write SetStatusText;
    property MimeType: string read GetMimeType write SetMimeType;
    property Charset: string read GetCharset write SetCharset;
    property ErrCode: THttpReqErrCode read GetErrCode write SetErrCode;
    property URL: string read GetURL write SetURL;
  end;

  IHttpContext = interface
    ['{4CA9C577-7A95-4ED1-AED6-A63B172ED1BC}']
    function  GetRequest: IHttpRequest;
    function  GetStatus: THttpReqStatus;
    function  GetErrCode: THttpReqErrCode;
    function  GetResponse: IHttpResponse;
    procedure Cancel;

    property Request: IHttpRequest read GetRequest;
    property Response: IHttpResponse read GetResponse;
    property Status: THttpReqStatus read GetStatus;
    property ErrCode: THttpReqErrCode read GetErrCode;
  end;

  IHttpBasicAuthCallback = interface
    ['{220A95BB-C5D9-4AC5-BC0B-190D622D2190}']
    procedure Cont(const _Username, _Password: string);
    procedure Cancel;
  end;

  IHttpRequestCallbacks = interface
    ['{F5B0023B-DBE9-427D-BD80-01F4060CC6FB}']
    procedure OnComplete(const _Contex: IHttpContext);
    procedure OnUploadProgress(const _Contex: IHttpContext; _Current, _Total: Int64);
    procedure OnDownloadProgress(const _Contex: IHttpContext; _Current, _Total: Int64);
    procedure OnDownloadData(const _Contex: IHttpContext; _Data: Pointer; _DataLength: Integer);
    function OnGetAuthCredentials(_IsProxy: Boolean; const _Host: string; _Port: Integer;
      const _Realm, _Scheme: string; const _Callback: IHttpBasicAuthCallback): Boolean;
  end;

  IHttpClient = interface
    ['{C8D2B4B3-42F5-4A94-9AF1-3714B2DE4184}']
    procedure DoRequest(const _Req: IHttpRequest; _Callbacks: IHttpRequestCallbacks);
  end;

implementation

end.
