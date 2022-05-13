unit DSLMimeTypes;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections;

const
  CONTENT_TYPE_URLENCODED_FORM = 'application/x-www-form-urlencoded';
  CONTENT_TYPE_URLENCODED_FORM_UTF8 = 'application/x-www-form-urlencoded; charset=utf-8';
  CONTENT_TYPE_JSON = 'application/json';
  CONTENT_TYPE_JSON_UTF8 = 'application/json; charset=utf-8';
  CONTENT_TYPE_TEXT = 'text/plain';
  CONTENT_TYPE_UTF8_TEXT = 'text/plain; charset=utf-8';

type
  IMimeData = interface
    function ContentType: string;
    function DataPointer: Pointer;
    function DataSize: Integer;
  end;

  IPairs<K, V> = interface
    function GetCount: Integer;
    procedure Append(const _Key: K; const _Value: V);
    function GetItem(const _Index: Integer): TPair<K, V>;
  end;

  TTextData = class(TInterfacedObject, IMimeData)
  private
    FContentType: string;
    FData: RawByteString;
    function ContentType: string;
    function DataPointer: Pointer;
    function DataSize: Integer;
  public
    constructor Create(const _Text: string; const _ContentType: string = CONTENT_TYPE_TEXT); overload;
    constructor Create(const _Text: RawByteString; const _ContentType: string = CONTENT_TYPE_TEXT); overload;
  end;

  TPairs<K, V> = class(TInterfacedObject, IPairs<K, V>)
  private
    FItems: TList<TPair<K, V>>;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCount: Integer;
    procedure Append(const _Key: K; const _Value: V);
    function GetItem(const _Index: Integer): TPair<K, V>;
  end;

implementation

{ TTextData }

function TTextData.ContentType: string;
begin
  Result := FContentType;
end;

constructor TTextData.Create(const _Text, _ContentType: string);
begin
  if (_ContentType = '') or (_ContentType = CONTENT_TYPE_TEXT) then
    FContentType := CONTENT_TYPE_UTF8_TEXT
  else
    FContentType := _ContentType + '; charset=utf-8';
  FData := UTF8Encode(_Text);
end;

constructor TTextData.Create(const _Text: RawByteString; const _ContentType: string);
begin
  if _ContentType = ''  then
    FContentType := CONTENT_TYPE_UTF8_TEXT
  else
    FContentType := _ContentType;
  FData := _Text;
end;

function TTextData.DataPointer: Pointer;
begin
  Result := Pointer(FData);
end;

function TTextData.DataSize: Integer;
begin
  Result := Length(FData);
end;

{ TPairs<K, V> }

procedure TPairs<K, V>.Append(const _Key: K; const _Value: V);
begin
  FItems.Add(TPair<K,V>.Create(_Key, _Value));
end;

constructor TPairs<K, V>.Create;
begin
  inherited Create;
  FItems := TList<TPair<K, V>>.Create;
end;

destructor TPairs<K, V>.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

function TPairs<K, V>.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TPairs<K, V>.GetItem(const _Index: Integer): TPair<K, V>;
begin
  Result := FItems[_Index];
end;

end.
