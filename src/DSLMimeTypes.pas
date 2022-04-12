unit DSLMimeTypes;

interface

uses
  SysUtils,
  Classes;

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

end.
