{$B-,C+,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,U-,V+,W-,X+,Z1}
{$O+}   // optimization on
{$T+}   // typed pointers on
{$POINTERMATH ON}
unit DSLJson;

interface

uses
  SysUtils, Classes, DSLUtils, DSLPortableData, DSLGenerics;

function ParseJsonValue(JSON: PAnsiChar; var value: TPortableValue): PAnsiChar; overload;
function ParseJsonValue(const JSON: RawByteString): TPortableValue; overload;
function ParseJsonRoot(JSON: PAnsiChar; var value: TPortableValue): PAnsiChar; overload;
function ParseJsonUtf8(s: PAnsiChar; len: Integer): TPortableValue; overload;
function ParseJsonUtf8(const s: UTF8String): TPortableValue; overload; inline;

implementation

uses
  DSLJsonSAX, DSLNumberParse;

function GetJSONPropName(var P: PAnsiChar): TAnsiCharSection;
var
  quote: AnsiChar;
begin
  Result.SetEmpty;
  if P = nil then
    Exit;
  if P^ in [#1 .. #32] then
  begin
    repeat
      Inc(P)
    until not(P^ in [#1 .. #32]);
  end;

  case P^ of
    '_', 'A' .. 'Z', 'a' .. 'z', '0' .. '9', '$':
      begin // e.g. '{age:{$gt:18}}'
        Result._begin := P;
        repeat
          Inc(P);
        until not(P^ in ['_', '0' .. '9', 'a' .. 'z', 'A' .. 'Z', '.', '[', ']']);
        Result._end := P;
        if P^ in [#1 .. #32] then
        begin
          repeat
            Inc(P)
          until not(P^ in [#1 .. #32]);
        end;

        // allow both age:18 and age=18 pairs
        if not(P^ in [':', '=']) then
        begin
          Result.SetEmpty;
          Exit;
        end;

        Inc(P);
      end;
    #39, '"':
      begin // single quotes won't handle nested quote character
        quote := P^;
        Inc(P);
        Result._begin := P;
        while True do
        begin
          if P^ = quote then
            Break;
          if P^ = #0 then
          begin
            Result.SetEmpty;
            Exit;
          end;

          if P^ = '\' then
          begin
            Inc(P);
            if P^ = #0 then
            begin
              Result.SetEmpty;
              Exit;
            end;
          end;
          Inc(P);
        end;
        Result._end := P;
        Inc(P);
        if P^ in [#1 .. #32] then
        begin
          repeat
            Inc(P)
          until not(P^ in [#1 .. #32]);
        end;
        if P^ <> ':' then
        begin
          Result.SetEmpty;
          Exit;
        end;
        Inc(P);
      end;
  end;
end;

function GotoJsonStringTail(JSON: PAnsiChar): PAnsiChar; overload;
var
  quote: AnsiChar;
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

function ParseJsonUtf8(s: PAnsiChar; len: Integer): TPortableValue;
begin
  Result.init;
  ParseJsonRoot(s, Result);
end;

function ParseJsonUtf8(const s: UTF8String): TPortableValue;
begin
  Result := ParseJsonUtf8(PAnsiChar(s), Length(s));
end;

const
  QUOTECHAR = #39;

function _ParseJsonValue(JSON: PAnsiChar; var value: TPortableValue): PAnsiChar; overload;
var
  propNameSection: TAnsiCharSection;
  PropName: UTF8String;
  arr: TPortableArray;
  obj: TPortableObjectUtf8;
  child: PPortableValue;
  pQuote: PAnsiChar;
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
        obj := value.CreateObjectUtf8IfEmpty;
        if JSON^ <> '}' then
          while true do
          begin
            propNameSection := GetJSONPropName(JSON);
            if propNameSection.IsEmpty then
              goto error_clean;
            PropName := propNameSection.ToString;
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
      if BeginWithA(JSON + 1, 'rue') then
      begin
        value.init(true);
        Inc(JSON, 4);
      end
      else
        goto error_clean;

    'f':
      if BeginWithA(JSON + 1, 'alse') then
      begin
        value.init(False);
        Inc(JSON, 5);
      end
      else
        goto error_clean;

    'N':
      if BeginWithA(JSON + 1, 'aN') then
      begin
        value.init(sdtNaN);
        Inc(JSON, 3);
      end
      else
        goto error_clean;

    'n':
      if BeginWithA(JSON + 1, 'ull') then
      begin
        value.init(sdtNull);
        Inc(JSON, 4);
      end
      else
        goto error_clean;

    'u':
      if BeginWithA(JSON + 1, 'ndefined') then
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

function ParseJsonRoot(JSON: PAnsiChar; var value: TPortableValue): PAnsiChar;
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

function ParseJsonValue(JSON: PAnsiChar; var value: TPortableValue): PAnsiChar;
begin
  Result := _ParseJsonValue(JSON, value);
end;

function ParseJsonValue(const JSON: RawByteString): TPortableValue;
begin
  Result.init();
  ParseJsonValue(PAnsiChar(JSON), Result);
end;

end.
