unit DSLJsonUtf16;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, DSLUtils, DSLPortableData, DSLGenerics;

type
  TUStringBuilder = record
  private
    _FData: UnicodeString;
    _FPosition: TSizeType;
    _FCapacity: TSizeType;
    _FCounterMode: Boolean;
    procedure growTo(minimal: TSizeType); inline;
    procedure _appendBuffer(buf: PWideChar; BufLen: TSizeType);
  public
    procedure init(counterMode: Boolean);
    function ToString: UnicodeString;
    function getCapacity: TSizeType; inline;
    procedure setCapacity(const newCapacity: TSizeType);
    procedure append(v: Int32); overload;
    procedure append(v: UInt32); overload;
    procedure append(v: Int64); overload;
    procedure append(v: UInt64); overload;
    procedure append(v: Double); overload;
    procedure append(const v: WideChar); overload;
    procedure append(const v: UnicodeString); overload;
  end;

  TJsonUStringBuilder = record
  private
    _FInternalBuilder: TUStringBuilder;
    procedure _writePropName(const name: UnicodeString; index: Integer); inline;
  public
    function ToString: UnicodeString;
    procedure init(counterMode: Boolean); inline;
    function getCapacity: TSizeType; inline;
    procedure setCapacity(const newCapacity: TSizeType); inline;
    procedure beginObject;
    procedure endObject;
    procedure writeProp(const name: UnicodeString; v: Int32; index: Integer = -1); overload;
    procedure writeProp(const name: UnicodeString; v: UInt32; index: Integer = -1); overload;
    procedure writeProp(const name: UnicodeString; v: Int64; index: Integer = -1); overload;
    procedure writeProp(const name: UnicodeString; v: UInt64; index: Integer = -1); overload;
    procedure writeProp(const name: UnicodeString; v: Double; index: Integer = -1); overload;
    procedure writeProp(const name, v: UnicodeString; index: Integer = -1); overload;
    procedure beginObjectProp(const name: UnicodeString; index: Integer = -1);
    procedure endObjectProp(const name: UnicodeString);
    procedure beginArrayProp(const name: UnicodeString; index: Integer = -1);
    procedure endArrayProp(const name: UnicodeString);
    procedure beginArray;
    procedure endArray;
    procedure writeInt32(v: Int32);
    procedure writeUInt32(v: UInt32);
    procedure writeInt64(v: Int64);
    procedure writeUInt64(v: UInt64);
    procedure writeFloat(v: Double);
    procedure writeString(const v: UnicodeString);
  end;

function ParseJsonValue(JSON: PWideChar; var value: TPortableValue): PWideChar; overload;
function ParseJsonValue(const JSON: UnicodeString): TPortableValue; overload;
function ParseJsonRoot(JSON: PWideChar; var value: TPortableValue): PWideChar; overload;
function ParseJson(s: PWideChar; len: Integer): TPortableValue; overload;
function ParseJson(const s: UnicodeString): TPortableValue; overload; inline;
function ParseJson(const s: WideString): TPortableValue; overload; inline;

implementation

uses
  DSLNumberParse;

function ParseJson(s: PWideChar; len: Integer): TPortableValue;
begin
  Result.init;
  ParseJsonRoot(s, Result);
end;

function ParseJson(const s: UnicodeString): TPortableValue;
begin
  Result := ParseJson(PWideChar(Pointer(s)), GetStringLengthFast(Pointer(s)));
end;

function ParseJson(const s: WideString): TPortableValue;
begin
  Result := ParseJson(PWideChar(Pointer(s)), GetStringLengthFast(Pointer(s)));
end;

const
  QUOTECHAR = #39;

function GetJSONPropName(var P: PWideChar): TWideCharSection;
var
  quote: WideChar;
begin
  Result.SetEmpty;
  if P = nil then
    Exit;
  P := GotoNextNotSpace(P);

  case P^ of
    '_', 'A' .. 'Z', 'a' .. 'z', '0' .. '9', '$':
      begin // e.g. '{age:{$gt:18}}'
        Result._begin := P;
        repeat
          Inc(P);
        until (P^ > #122) or not (AnsiChar(P^) in ['_', '0' .. '9', 'a' .. 'z', 'A' .. 'Z', '.', '[', ']']);
        Result._end := P;
        P := GotoNextNotSpace(P);

        // allow both age:18 and age=18 pairs
        if (P^ <> ':') and (P^ <> '=') then
        begin
          Result.SetEmpty;
          Exit;
        end;

        Inc(P);
      end;
    QUOTECHAR, '"':
      begin // single quotes won't handle nested quote character
        quote := P^;
        Inc(P);
        Result._begin := P;
        while P^ <> quote do
          // if P^ < #32 then begin Result.SetEmpty; Exit end else
          Inc(P);
        Result._end := P;
        P := GotoNextNotSpace(P + 1);
        if P^ <> ':' then
        begin
          Result.SetEmpty;
          Exit;
        end;
        Inc(P);
      end;
  end;
end;
{$HINTS OFF}

function GotoJsonStringTail(JSON: PWideChar): PWideChar; overload;
var
  quote: WideChar;
label lbl_exit, slash;
begin
  quote := JSON^;
  Inc(JSON);
  while True do
  begin
    if (JSON^ = #0) or (JSON^ = quote) then
      Break;
    if JSON^ = '\' then
    begin
      Inc(JSON);
      if JSON^ = #0 then
        Break;
    end;
    Inc(JSON);
  end;
  Result := JSON;
end;

function _ParseJsonValue(JSON: PWideChar; var value: TPortableValue): PWideChar; overload;
var
  propNameSection: TWideCharSection;
  PropName: UnicodeString;
  arr: TPortableArray;
  obj: TPortableObject;
  child: PPortableValue;
  pQuote: PWideChar;
  number: TNumber;
label error_clean, return_success;
begin
  if JSON = nil then
    goto error_clean;

  JSON := GotoNextNotSpace(JSON);
  case JSON^ of
    '.', '+', '-', '0' .. '9':
      begin
        number := ParseNumber(JSON, @JSON);
        if not number.valid then
          goto error_clean;
        value.Assign(number);
      end;
    #39, '"':
      begin
        pQuote := JSON;
        JSON := GotoJsonStringTail(JSON);
        if JSON^ <> pQuote^ then
          goto error_clean;
        SetString(PropName, pQuote + 1, JSON - pQuote - 1);
        value.init(PropName);
        Inc(JSON);
      end;
    '[':
      begin
        JSON := GotoNextNotSpace(JSON + 1);
        arr := value.CreateArrayIfEmpty;
        if JSON^ <> ']' then
          while true do
          begin
            child := arr.AddItem;
            JSON := _ParseJsonValue(JSON, child^);
            if child.dataType = sdtNone then
              goto error_clean;
            JSON := GotoNextNotSpace(JSON);
            if JSON^ = ']' then
              break;
            if JSON^ <> ',' then
              goto error_clean;
            Inc(JSON); // skip ,
          end;
        Inc(JSON); // skip ]
      end;
    '{':
      begin
        JSON := GotoNextNotSpace(JSON + 1);
        obj := value.CreateObjectIfEmpty;
        if JSON^ <> '}' then
          while true do
          begin
            propNameSection := GetJSONPropName(JSON);
            if propNameSection.IsEmpty then
              goto error_clean;
            PropName := propNameSection.ToUStr;
            child := obj.FastAddItem(PropName);
            JSON := _ParseJsonValue(JSON, child^);
            if child.dataType = sdtNone then
              goto error_clean;
            JSON := GotoNextNotSpace(JSON);
            if JSON^ = '}' then
              break;
            if JSON^ <> ',' then
              goto error_clean;
            Inc(JSON); // skip ,
          end;
        Inc(JSON); // skip }
      end;

    't':
      if BeginWithW(JSON + 1, 'rue') then
      begin
        value.init(true);
        Inc(JSON, 4);
      end
      else
        goto error_clean;

    'f':
      if BeginWithW(JSON + 1, 'alse') then
      begin
        value.init(False);
        Inc(JSON, 5);
      end
      else
        goto error_clean;

    'N':
      if BeginWithW(JSON + 1, 'aN') then
      begin
        value.init(sdtNaN);
        Inc(JSON, 3);
      end
      else
        goto error_clean;

    'n':
      if BeginWithW(JSON + 1, 'ull') then
      begin
        value.init(sdtNull);
        Inc(JSON, 4);
      end
      else
        goto error_clean;

    'u':
      if BeginWithW(JSON + 1, 'ndefined') then
      begin
        value.init(sdtUndefined);
        Inc(JSON, 9);
      end
      else
        goto error_clean;
  else
    goto error_clean;
  end;
  goto return_success;
error_clean :
  value.cleanup;
return_success :
  Result := JSON;
end;

function ParseJsonRoot(JSON: PWideChar; var value: TPortableValue): PWideChar;
begin
  if JSON = nil then
    Result := nil
  else
  begin
    value.cleanup();
    Result := _ParseJsonValue(JSON, value);
    Result := GotoNextNotSpace(Result);
    if Result^ <> #0 then
      value.cleanup;
  end;
end;

function ParseJsonValue(JSON: PWideChar; var value: TPortableValue): PWideChar; overload;
begin
  Result := _ParseJsonValue(JSON, value);
end;

function ParseJsonValue(const JSON: UnicodeString): TPortableValue;
begin
  Result.init();
  ParseJsonValue(PWideChar(JSON), Result);
end;

{ TJsonUStringBuilder }

procedure TJsonUStringBuilder.beginArray;
begin
  _FInternalBuilder.append('[');
end;

procedure TJsonUStringBuilder.beginArrayProp(const name: UnicodeString; index: Integer);
begin
  Self._writePropName(name, index);
  _FInternalBuilder.append('[');
end;

procedure TJsonUStringBuilder.beginObject;
begin
  _FInternalBuilder.append('{');
end;

procedure TJsonUStringBuilder.beginObjectProp(const name: UnicodeString; index: Integer);
begin
  Self._writePropName(name, index);
  _FInternalBuilder.append('{');
end;

procedure TJsonUStringBuilder.endArray;
begin
  _FInternalBuilder.append(']');
end;

procedure TJsonUStringBuilder.endArrayProp(const name: UnicodeString);
begin
  _FInternalBuilder.append(']');
end;

procedure TJsonUStringBuilder.endObject;
begin
  _FInternalBuilder.append('}');
end;

procedure TJsonUStringBuilder.endObjectProp(const name: UnicodeString);
begin
  _FInternalBuilder.append('}');
end;

function TJsonUStringBuilder.getCapacity: TSizeType;
begin
  Result := _FInternalBuilder.getCapacity;
end;

procedure TJsonUStringBuilder.init(counterMode: Boolean);
begin
  _FInternalBuilder.init(counterMode);
end;

procedure TJsonUStringBuilder.setCapacity(const newCapacity: TSizeType);
begin
  _FInternalBuilder.setCapacity(newCapacity);
end;

function TJsonUStringBuilder.ToString: UnicodeString;
begin
  Result := _FInternalBuilder.ToString;
end;

procedure TJsonUStringBuilder.writeFloat(v: Double);
begin
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeProp(const name: UnicodeString; v: Double; index: Integer);
begin
  Self._writePropName(name, index);
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeInt32(v: Int32);
begin
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeProp(const name: UnicodeString; v: Int32; index: Integer);
begin
  Self._writePropName(name, index);
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeInt64(v: Int64);
begin
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeProp(const name: UnicodeString; v: Int64; index: Integer);
begin
  Self._writePropName(name, index);
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeString(const v: UnicodeString);
begin
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeProp(const name, v: UnicodeString; index: Integer);
var
  i: Integer;
  ch: WideChar;
begin
  Self._writePropName(name, index);
  _FInternalBuilder.append('"');

  for i := 0 to Length(v) - 1 do
  begin
    ch := PWideChar(v)[i];
    case ch of
      '\', '"':
        begin
          _FInternalBuilder.append('\');
          _FInternalBuilder.append(ch);
        end;

      #13:
        _FInternalBuilder.append('\r');

      #10:
        _FInternalBuilder.append('\n');

      #9:
        _FInternalBuilder.append('\t');

    else
      _FInternalBuilder.append(ch);
    end;
  end;

  _FInternalBuilder.append('"');
end;

procedure TJsonUStringBuilder.writeUInt32(v: UInt32);
begin
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeProp(const name: UnicodeString; v: UInt32; index: Integer);
begin
  Self._writePropName(name, index);
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeUInt64(v: UInt64);
begin
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder.writeProp(const name: UnicodeString; v: UInt64; index: Integer);
begin
  Self._writePropName(name, index);
  _FInternalBuilder.append(v);
end;

procedure TJsonUStringBuilder._writePropName(const name: UnicodeString; index: Integer);
begin
  if index = 0 then
    _FInternalBuilder.append('"')
  else
    _FInternalBuilder.append(',"');
  _FInternalBuilder.append(name);
  _FInternalBuilder.append('":');
end;

{ TUStringBuilder }

procedure TUStringBuilder.append(v: Int64);
var
  buf: array [0 .. 21] of WideChar;
  p: PWideChar;
begin
  p := StrInt(buf+High(buf), v);
  _appendBuffer(p, buf+High(buf) - p);
end;

procedure TUStringBuilder.append(v: UInt32);
var
  buf: array [0 .. 11] of WideChar;
  p: PWideChar;
begin
  p := StrInt(buf+High(buf), v);
  _appendBuffer(p, buf+High(buf) - p);
end;

procedure TUStringBuilder.append(v: Int32);
var
  buf: array [0 .. 11] of WideChar;
  p: PWideChar;
begin
  p := StrInt(buf+High(buf), v);
  _appendBuffer(p, buf+High(buf) - p);
end;

procedure TUStringBuilder.append(const v: UnicodeString);
begin
  _appendBuffer(PWideChar(v), Length(v));
end;

procedure TUStringBuilder.append(const v: WideChar);
begin
  _appendBuffer(@v, 1);
end;

procedure TUStringBuilder.append(v: Double);
var
  buf: array [0 .. 63] of WideChar;
begin
  _appendBuffer(buf, FloatToText(buf, v, fvExtended, ffGeneral, 15, 0));
end;

procedure TUStringBuilder.append(v: UInt64);
var
  buf: array [0 .. 21] of WideChar;
  p: PWideChar;
begin
  p := StrInt(buf+High(buf), v);
  _appendBuffer(p, buf+High(buf) - p);
end;

function TUStringBuilder.getCapacity: TSizeType;
begin
  Result := _FCapacity;
end;

procedure TUStringBuilder.growTo(minimal: TSizeType);
begin
  if minimal < 64 then
    minimal := 64
  else if minimal < 128 then
    minimal := 128
  else if minimal < 256 then
    minimal := 256
  else if minimal < 512 then
    minimal := 512
  else
    minimal := minimal + 512;
  setCapacity(minimal);
end;

procedure TUStringBuilder.init(counterMode: Boolean);
begin
  _FData := '';
  _FPosition := 0;
  _FCapacity := 0; ;
  _FCounterMode := counterMode;
end;

procedure TUStringBuilder.setCapacity(const newCapacity: TSizeType);
begin
  if newCapacity > _FPosition then
  begin
    _FCapacity := newCapacity;
    if not _FCounterMode then
      SetLength(_FData, newCapacity);
  end;
end;

function TUStringBuilder.ToString: UnicodeString;
begin
  if _FCounterMode then
    raise EInvalidOperation.Create('fetch result when TUStringBuilder in counter mode');

  if _FPosition = _FCapacity then
    Result := _FData
  else
    Result := Copy(_FData, 1, _FPosition);
end;

procedure TUStringBuilder._appendBuffer(buf: PWideChar; BufLen: TSizeType);
var
  newPos: TSizeType;
begin
  if BufLen = 0 then
    Exit;
  newPos := _FPosition + BufLen;
  if newPos > _FCapacity then
    growTo(newPos);

  if not _FCounterMode then
    dslMove(buf^, PWideChar(_FData)[_FPosition], BufLen * 2);
  _FPosition := newPos;
end;

end.
