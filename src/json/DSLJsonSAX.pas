unit DSLJsonSAX;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, DSLUtils, DSLByteStr, DSLSax;

type
  TDecodeJsonErrCode = (
    djecSuccess,
    djecUnexpectedEOF,
    djecUnknownValue,
    djecInvalidNumber,
    djecMissingColon,
    djecInvalidFieldName,
    djecUnClosedArray,
    djecUnClosedObject,
    djecLast
  );

  TDecodeResult = record
    Next: PAnsiChar;
    ErrCode: TDecodeJsonErrCode;
    function Ok: Boolean; inline;
  end;

  PSAXJsonDecoder = ^TSAXJsonDecoder;
  TSAXJsonDecoder = record
  private
    FCtx: TSaxContext;
    FFieldName: TByteStrBuilder;
    FFieldValue: TByteStrBuilder;
{$ifdef SAX_JSON_PATH}
  FPathBuffer: array [0..2047] of AnsiChar;
{$endif}
    FFieldNameBuffer: array [0..1023] of AnsiChar;
    FFieldValueBuffer: array [0..2047] of AnsiChar;
    function DecodeRecord(P: PAnsiChar; const _Handler: ISaxHandler; const _Node: TSaxNode): TDecodeResult;
    function DecodeArray(P: PAnsiChar; const _Handler: ISaxHandler; const _Node: TSaxNode): TDecodeResult;
    function DoDecode(P: PAnsiChar; const _Handler: ISaxHandler; const _Node: TSaxNode): TDecodeResult;
    function GetPath: RawByteString;
  public
    function Decode(const _Json: RawByteString; const _Handler: ISaxHandler; const _Node: TSaxNode): TDecodeResult; overload;
    function Decode(_Json: PAnsiChar; const _Handler: ISaxHandler; const _Node: TSaxNode; _CodePage: Word = CP_UTF8): TDecodeResult; overload;
    property Depth: Integer read FCtx.Depth;
    property Path: RawByteString read GetPath;
  end;

implementation

uses
  Math, DSLNumberParse;

const
  S_TRUE: RawByteString = 'true';
  S_NULL: RawByteString = 'null';
  S_ALSE: RawByteString = 'alse';
  S_NAN: RawByteString = 'aN';
  S_ndefined: RawByteString = 'ndefined';

// decode json object field name
function DecodeJSONString(P: PAnsiChar; var _Target: TByteStrBuilder; _DoUnescape: Boolean): TDecodeResult;
var
  LQuote: AnsiChar;
  LBegin: PAnsiChar;
label
  no_unescape, do_unescape;
begin
  _Target.Reset;
  Result.ErrCode := djecUnexpectedEOF;
  Result.Next := P;
  if P = nil then
  begin
    Exit;
  end;
  LQuote := P^;
  Inc(P);
  LBegin := P;

  while not (P^ in [LQuote, '\', #0]) do Inc(P);
  _Target.SetExternal(LBegin, P-LBegin);
  if P^ = LQuote then
  begin
    Result.ErrCode := djecSuccess;
    Result.Next := P + 1;
    Exit;
  end;

  if P^ = #0 then
  begin
    Result.Next := P - 1;
    Exit;
  end;

  if _DoUnescape then
    goto do_unescape
  else
    goto no_unescape;

no_unescape:
  while not (P^ in [LQuote, '\', #0]) do Inc(P);
  if P^ = LQuote then
  begin
    _Target.SetExternal(LBegin, P-LBegin);
    Result.ErrCode := djecSuccess;
    Result.Next := P + 1;
    Exit;
  end;

  if P^ = '\' then
    Inc(P);

  if P^ = #0 then
  begin
    Result.Next := P - 1;
    Exit;
  end;

  Inc(P);
  goto no_unescape;

do_unescape:
  while not (P^ in [LQuote, '\', #0]) do Inc(P);
  if P^ = LQuote then
  begin
    _Target.SetExternal(LBegin, P-LBegin);
    Result.ErrCode := djecSuccess;
    Result.Next := P + 1;
    Exit;
  end;

  if P^ = '\' then
    Inc(P);

  if P^ = #0 then
  begin
    Result.Next := P - 1;
    Exit;
  end;

  Inc(P);
  goto do_unescape;
end;

// decode json object field name
function DecodeFieldName(P: PAnsiChar; var _Target: TByteStrBuilder; _DoUnescape: Boolean): TDecodeResult;
var
  LBegin, LEnd: PAnsiChar;
begin
  _Target.Reset;
  Result.ErrCode := djecUnexpectedEOF;
  Result.Next := P;
  if P = nil then
  begin
    Exit;
  end;
  while P^ in [#1 .. #32] do Inc(P);
  Result.Next := P;
  case P^ of
    #0: ;
    '_', 'A' .. 'Z', 'a' .. 'z', '0' .. '9', '$':
      begin // e.g. '{age:{$gt:18}}'
        LBegin := P;
        repeat
          Inc(P);
        until not (P^ in ['_', '$', '0' .. '9', 'a' .. 'z', 'A' .. 'Z', '.', '[', ']']);
        LEnd := P;
        while P^ in [#1 .. #32] do Inc(P);

        // allow both age:18 and age=18 pairs
        if P^ in [':', '='] then
        begin
          _Target.SetExternal(LBegin, LEnd - LBegin);
          Result.Next := P + 1;
          Result.ErrCode := djecSuccess;
        end
        else begin
          Result.Next := LBegin;
          Result.ErrCode := djecMissingColon;
        end;
      end;
    #39, '"':
      begin
        LBegin := P;
        Result := DecodeJSONString(P, _Target, _DoUnescape);
        if Result.ErrCode = djecSuccess then
        begin
          P := Result.Next;
          while P^ in [#1 .. #32] do Inc(P);
          // allow both "age":18 and "age"=18 pairs
          if P^ in [':', '='] then
            Result.Next := P + 1
          else begin
            Result.Next := LBegin;
            Result.ErrCode := djecMissingColon;
          end;
        end;
      end
    else
      Result.ErrCode := djecInvalidFieldName;
  end;
end;

function SkipJsonValue(P: PAnsiChar): TDecodeResult;
var
  LStr: TByteStrBuilder;
  LNumber: TNumber;
  LQuote: AnsiChar;
begin
  LStr := TByteStrBuilder.Create(LQuote, 1);
  Result.ErrCode := djecUnexpectedEOF;
  Result.Next := P;
  if P = nil then
    Exit;

  while P^ in [#1 .. #32] do Inc(P);
  Result.Next := P;
  case P^ of
    '.', '+', '-', '0' .. '9':
      begin
        LNumber := ParseNumber(P, @P);
        if LNumber.valid then
        begin
          Result.ErrCode := djecSuccess;
          Result.Next := P;
        end
        else
          Result.ErrCode := djecInvalidNumber;
      end;
    #39, '"': Result := DecodeJSONString(P, LStr, False);
    '[':
      begin
        repeat Inc(P); until not (P^ in [#1 .. #32]);
        if P^ <> ']' then
        begin
          while True do
          begin
            Result := SkipJsonValue(P);
            if Result.ErrCode <> djecSuccess then
              Exit;
            P := Result.Next;
            while P^ in [#1 .. #32] do Inc(P);
            if P^ = ']' then
              Break;
            if P^ <> ',' then
            begin
              Result.ErrCode := djecUnClosedArray;
              Exit;
            end;
            Inc(P); // skip ','
          end;
        end;
        Result.Next := P + 1; // skip ']'
        Result.ErrCode := djecSuccess;
      end;
    '{':
      begin
        repeat Inc(P); until not (P^ in [#1 .. #32]);
        if P^ <> '}' then
        begin
          while True do
          begin
            Result := DecodeFieldName(P, LStr, False);
            if Result.ErrCode <> djecSuccess then
              Exit;
            Result := SkipJsonValue(Result.Next);
            if Result.ErrCode <> djecSuccess then
              Exit;
            P := Result.Next;
            while P^ in [#1 .. #32] do Inc(P);
            if P^ = '}' then
              Break;
            if P^ <> ',' then
            begin
              Result.ErrCode := djecUnClosedObject;
              Exit;
            end;
            Inc(P); // skip ','
          end;
        end;
        Result.Next := P + 1; // skip '}'
        Result.ErrCode := djecSuccess;
      end;

    't':
      if PCardinal(P)^ = PCardinal(S_TRUE)^ then
      begin
        Result.Next := P + 4;
        Result.ErrCode := djecSuccess;
      end
      else
       Result.ErrCode := djecUnknownValue;

    'f':
      if PCardinal(P + 1)^ = PCardinal(S_ALSE)^ then
      begin
        Result.Next := P + 5;
        Result.ErrCode := djecSuccess;
      end
      else
        Result.ErrCode := djecUnknownValue;

    'N':
      if PWord(P + 1)^ = PWord(S_NAN)^ then
      begin
        Result.Next := P + 3;
        Result.ErrCode := djecSuccess;
      end
      else
        Result.ErrCode := djecUnknownValue;

    'n':
      if PCardinal(P)^ = PCardinal(S_NULL)^ then
      begin
        Result.Next := P + 4;
        Result.ErrCode := djecSuccess;
      end
      else
        Result.ErrCode := djecUnknownValue;

    'u':
      if PInt64(P + 1)^ = PInt64(S_ndefined)^ then
      begin
        Result.Next := P + 9;
        Result.ErrCode := djecSuccess;
      end
      else
        Result.ErrCode := djecUnknownValue;
    #0: ;
  else
    Result.ErrCode := djecUnknownValue;
  end;
end;

{ TSAXJsonDecoder }


function TSAXJsonDecoder.Decode(_Json: PAnsiChar; const _Handler: ISaxHandler; const _Node: TSaxNode; _CodePage: Word): TDecodeResult;
begin
  {$ifdef SAX_JSON_PATH}
  FCtx.Path := TByteStrBuilder.Create(FPathBuffer, SizeOf(FPathBuffer), _CodePage);
  {$else}
  FCtx.Path := TByteStrBuilder.Create(FFieldValueBuffer, 0, _CodePage);
  {$endif}
  FFieldName := TByteStrBuilder.Create(FFieldNameBuffer, SizeOf(FFieldNameBuffer), _CodePage);
  FFieldValue := TByteStrBuilder.Create(FFieldValueBuffer, SizeOf(FFieldValueBuffer), _CodePage);
  Result := Self.DoDecode(_Json, _Handler, _Node);
end;

function TSAXJsonDecoder.DecodeArray(P: PAnsiChar; const _Handler: ISaxHandler; const _Node: TSaxNode): TDecodeResult;
var
  LIdx: Integer;
  LChildNode: TSaxNode;
{$ifdef SAX_JSON_PATH}
  LPathPos: Integer;
{$endif}
label
  next_elem, skip_next, end_array;
begin
  if not _Handler.OnArray(@Self.FCtx, _Node, -1) then
  begin
    Result := SkipJsonValue(P);
    Exit;
  end;
  Result.ErrCode := djecUnexpectedEOF;
  Result.Next := P;

  repeat Inc(P); until not (P^ in [#1 .. #32]);
  {$ifdef SAX_JSON_PATH}
  LPathPos := FCtx.Path.Len;
  {$endif}
  if P^ <> ']' then
  begin
    LIdx := 0;
    Inc(FCtx.Depth);
    {$ifdef SAX_JSON_PATH}
    FCtx.Path.AppendChar('[');
    {$endif}
next_elem:
    {$ifdef SAX_JSON_PATH}
    FCtx.Path.Truncate(LPathPos + 1);
    FCtx.Path.Append(LIdx);
    FCtx.Path.AppendChar(']');
    {$endif}
    Self.FCtx.ChildIndex := LIdx;
    LChildNode := _Handler.OnElem(@Self.FCtx, _Node, LIdx);
    if LChildNode.Addr = nil then
      goto skip_next;
    Result := DoDecode(P, _Handler, LChildNode);
    if Result.ErrCode <> djecSuccess then
      Exit;
    P := Result.Next;
    while P^ in [#1 .. #32] do Inc(P);
    if P^ = ']' then
      goto end_array;
    if P^ <> ',' then
    begin
      Result.ErrCode := djecUnClosedArray;
      Exit;
    end;
    Inc(P); // skip ','
    Inc(LIdx);
    goto next_elem;
skip_next:
    Result := SkipJsonValue(P);
    if Result.ErrCode <> djecSuccess then
      Exit;
    P := Result.Next;
    while P^ in [#1 .. #32] do Inc(P);
    if P^ = ']' then
      goto end_array;
    if P^ <> ',' then
    begin
      Result.ErrCode := djecUnClosedArray;
      Exit;
    end;
    Inc(P); // skip ','
    goto skip_next;
end_array:
    Dec(FCtx.Depth);
  end
  else begin
    _Handler.OnArray(@Self.FCtx, _Node, 0);
  end;
  {$ifdef SAX_JSON_PATH}
  FCtx.Path.Truncate(LPathPos);
  {$endif}
  Result.Next := P + 1; // skip ']'
  Result.ErrCode := djecSuccess;
end;

function TSAXJsonDecoder.DecodeRecord(P: PAnsiChar; const _Handler: ISaxHandler; const _Node: TSaxNode): TDecodeResult;
var
  LIdx: Integer;
  LChildNode: TSaxNode;
{$ifdef SAX_JSON_PATH}
  LPathPos: Integer;
{$endif}
begin
  if not _Handler.OnObject(@Self.FCtx, _Node, -1) then
  begin
    Result := SkipJsonValue(P);
    Exit;
  end;
  Result.ErrCode := djecUnexpectedEOF;
  Result.Next := P;

  repeat Inc(P); until not (P^ in [#1 .. #32]);
  {$ifdef SAX_JSON_PATH}
  LPathPos := FCtx.Path.Len;
  {$endif}
  if P^ <> '}' then
  begin
    LIdx := 0;
    Inc(FCtx.Depth);
    {$ifdef SAX_JSON_PATH}
    FCtx.Path.AppendChar('.');
    {$endif}
    while True do
    begin
      Result := DecodeFieldName(P, FFieldName, True);
      if Result.ErrCode <> djecSuccess then
        Exit;
      {$ifdef SAX_JSON_PATH}
      FCtx.Path.Truncate(LPathPos + 1);
      FCtx.Path.Append(FFieldName.GetData, FFieldName.Len);
      {$endif}
      FCtx.ChildIndex := LIdx;
      LChildNode := _Handler.OnField(@Self.FCtx, _Node, FCtx.ChildIndex, FFieldName);
      if LChildNode.Addr <> nil then
        Result := DoDecode(Result.Next, _Handler, LChildNode)
      else
        Result := SkipJsonValue(Result.Next);

      if Result.ErrCode <> djecSuccess then
        Exit;
      P := Result.Next;
      while P^ in [#1 .. #32] do Inc(P);
      if P^ = '}' then
        Break;
      if P^ <> ',' then
      begin
        Result.ErrCode := djecUnClosedObject;
        Exit;
      end;
      Inc(P); // skip ','
      Inc(LIdx);
    end;
    Dec(FCtx.Depth);
  end
  else begin
    _Handler.OnObject(@Self.FCtx, _Node, 0);
  end;
  {$ifdef SAX_JSON_PATH}
  FCtx.Path.Truncate(LPathPos);
  {$endif}
  Result.Next := P + 1; // skip '}'
  Result.ErrCode := djecSuccess;
end;

function TSAXJsonDecoder.DoDecode(P: PAnsiChar; const _Handler: ISaxHandler; const _Node: TSaxNode): TDecodeResult;
var
  LNumber: TNumber;
begin
  Result.ErrCode := djecUnexpectedEOF;
  Result.Next := P;
  if P = nil then
    Exit;

  while P^ in [#1 .. #32] do Inc(P);
  Result.Next := P;
  case P^ of
    '.', '+', '-', '0' .. '9':
      begin
        LNumber := ParseNumber(P, @P);
        if LNumber.valid then
        begin
          Result.ErrCode := djecSuccess;
          Result.Next := P;
          _Handler.OnNumber(@Self.FCtx, _Node, LNumber)
        end
        else
          Result.ErrCode := djecInvalidNumber;
      end;
    #39, '"':
      begin
        Result := DecodeJSONString(P, FFieldValue, True);
        if Result.Ok then
          _Handler.OnString(@Self.FCtx, _Node, FFieldValue);
      end;
    '[': Result := Self.DecodeArray(P, _Handler, _Node);
    '{': Result := Self.DecodeRecord(P, _Handler, _Node);
    't':
      if PCardinal(P)^ = PCardinal(S_TRUE)^ then
      begin
        LNumber._type := numInt32;
        LNumber.I32 := 1;
        _Handler.OnNumber(@Self.FCtx, _Node, LNumber);
        Result.Next := P + 4;
        Result.ErrCode := djecSuccess;
      end
      else
       Result.ErrCode := djecUnknownValue;

    'f':
      if PCardinal(P + 1)^ = PCardinal(S_ALSE)^ then
      begin
        LNumber._type := numInt32;
        LNumber.I32 := 0;
        _Handler.OnNumber(@Self.FCtx, _Node, LNumber);
        Result.Next := P + 5;
        Result.ErrCode := djecSuccess;
      end
      else
        Result.ErrCode := djecUnknownValue;

    'N':
      if PWord(P + 1)^ = PWord(S_NAN)^ then
      begin
        LNumber._type := numDouble;
        LNumber.VDouble := Math.NaN;
        _Handler.OnNumber(@Self.FCtx, _Node, LNumber);
        Result.Next := P + 3;
        Result.ErrCode := djecSuccess;
      end
      else
        Result.ErrCode := djecUnknownValue;

    'n':
      if PCardinal(P)^ = PCardinal(S_NULL)^ then
      begin
        _Handler.OnNull(@Self.FCtx, _Node);
        Result.Next := P + 4;
        Result.ErrCode := djecSuccess;
      end
      else
        Result.ErrCode := djecUnknownValue;

    'u':
      if PInt64(P + 1)^ = PInt64(S_ndefined)^ then
      begin
        _Handler.OnNull(@Self.FCtx, _Node);
        Result.Next := P + 9;
        Result.ErrCode := djecSuccess;
      end
      else
        Result.ErrCode := djecUnknownValue;
    #0: ;
  else
    Result.ErrCode := djecUnknownValue;
  end;
end;

function TSAXJsonDecoder.Decode(const _Json: RawByteString; const _Handler: ISaxHandler; const _Node: TSaxNode): TDecodeResult;
begin
  Result := Self.Decode(PAnsiChar(Pointer(_Json)), _Handler, _Node, StringCodePage(_Json));
end;

function TSAXJsonDecoder.GetPath: RawByteString;
begin
  Result := FCtx.Path.Once;
end;

{ TDecodeResult }

function TDecodeResult.Ok: Boolean;
begin
  Result := ErrCode = djecSuccess;
end;

end.
