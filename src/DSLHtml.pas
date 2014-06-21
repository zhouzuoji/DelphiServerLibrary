unit DSLHtml;

interface

uses
  SysUtils, Classes, Windows, DSLUtils;

function HTMLDecodeBufA(s: PAnsiChar; len: Integer): RawByteString;

function HTMLDecodeStrA(const s: RawByteString): RawByteString;

function HTMLDecodeBufferW(s: PWideChar; len: Integer): UnicodeString;

function HTMLDecodeUStr(const s: UnicodeString): UnicodeString;

function HTMLDecodeBStr(const s: WideString): WideString;

function GetInputPropW(str: PWideChar; len: Integer; const name: UnicodeString; out P1, P2: PWideChar): Boolean; overload;

function GetInputPropW(str: PWideChar; len: Integer; const name: UnicodeString; out value: UnicodeString): Boolean; overload;

function GetInputValueW(str: PWideChar; len: Integer; const name: UnicodeString; out value: UnicodeString): Boolean; overload;

function GetInputValueW(const str: UnicodeString; const name: UnicodeString; out value: UnicodeString;
  StartIndex: Integer = 1; EndIndex: Integer = 0): Boolean; overload;

function GetInputPropA(str: PAnsiChar; len: Integer; const name: RawByteString; out value: RawByteString): Boolean; overload;

function GetInputPropA(str: PAnsiChar; len: Integer; const name: RawByteString; out P1, P2: PAnsiChar): Boolean; overload;

function GetInputValueA(str: PAnsiChar; len: Integer; const name: RawByteString; out value: RawByteString): Boolean;

implementation

function HTMLDecodeBufA(s: PAnsiChar; len: Integer): RawByteString;
var
  P1, P2: Integer;
  dst: PAnsiChar;
  v: DWORD;
begin
  {
  &lt; 	< 	小于
  &gt; 	> 	大于
  &amp; 	& 	和号
  &apos; 	' 	省略号
  &quot; 	" 	引号
  'mdash; —
  }

  SetLength(Result, len);

  dst := PAnsiChar(Result);

  P1 := 0;

  while True do
  begin
    P2 := P1;

    while (P2 < len) and (s[P2] <> '&') do Inc(P2);

    if P2 > P1 then
    begin
      Move(s[P1], dst^, (P2 - P1) * 2);
      Inc(dst, P2 - P1);
    end;

    if P2 >= len then Break;

    if P2 = len - 1 then
    begin
      dst^ := '&';
      Inc(dst);
      Break;
    end;

    Inc(P2);

    if s[P2] = '#' then
    begin
      if P2 = len - 1 then
      begin
        dst^ := '&';
        dst[1] := '#';
        Inc(dst, 2);
        Break;
      end;

      Inc(P2);

      if (s[P2] < '0') or (s[P2] > '9') then
      begin
        dst^ := '&';
        dst[1] := '#';
        Inc(dst, 2);
        P1 := P2;
        Continue;
      end;

      v := Ord(s[P2]) - 48;
      Inc(P2);

      while (P2 < len) and (s[P2] >= '0') and (s[P2] <= '9') do
      begin
        v := v * 10 + Ord(s[P2]) - 48;
        Inc(P2);
      end;

      if v < $ff then PByte(dst)^ := v
      else begin
        AnsiStrAssignWideChar(dst, WideChar(v), CP_ACP);
        Inc(dst);
      end;

      if (P2 < len) and (s[P2] = ';') then
        Inc(P2);
    end
    else if BeginWithA(s + P2, len - P2, 'lt;', 3) then
    begin
      dst^ := '<'; Inc(P2, 3);
    end
    else if BeginWithA(s + P2, len - P2, 'gt;', 3) then
    begin
      dst^ := '>'; Inc(P2, 3);
    end
    else if BeginWithA(s + P2, len - P2, 'amp;', 4) then
    begin
      dst^ := '&'; Inc(P2, 4);
    end
    else if BeginWithA(s + P2, len - P2, 'apos;', 5) then
    begin
      dst^ := #39; Inc(P2, 5);
    end
    else if BeginWithA(s + P2, len - P2, 'quot;', 5) then
    begin
      dst^ := '"'; Inc(P2, 5);
    end
    else if BeginWithA(s + P2, len - P2, 'mdash;', 6) then
    begin
      StrCopy(dst, '—'); Inc(dst); Inc(P2, 6);
    end
    else begin
      dst^ := '&'; Inc(P2);
    end;

    Inc(dst);
    P1 := P2;
  end;

  SetLength(Result, dst - PAnsiChar(Result));
end;

function HTMLDecodeStrA(const s: RawByteString): RawByteString;
begin
  Result := HTMLDecodeBufA(PAnsiChar(s), Length(s));
end;

function HTMLDecodeBufferW(s: PWideChar; len: Integer): UnicodeString;
var
  P1, P2: Integer;
  dst: PWideChar;
  v: DWORD;
begin
  {
  &lt; 	< 	小于
  &gt; 	> 	大于
  &amp; 	& 	和号
  &apos; 	' 	省略号
  &quot; 	" 	引号
  'mdash; —
  }

  SetLength(Result, len);

  dst := PWideChar(Result);

  P1 := 0;

  while True do
  begin
    P2 := P1;

    while (P2 < len) and (s[P2] <> '&') do Inc(P2);

    if P2 > P1 then
    begin
      Move(s[P1], dst^, (P2 - P1) * 2);
      Inc(dst, P2 - P1);
    end;

    if P2 >= len then Break;

    if P2 = len - 1 then
    begin
      dst^ := '&';
      Inc(dst);
      Break;
    end;

    Inc(P2);

    if s[P2] = '#' then
    begin
      if P2 = len - 1 then
      begin
        dst^ := '&';
        dst[1] := '#';
        Inc(dst, 2);
        Break;
      end;

      Inc(P2);

      if (s[P2] < '0') or (s[P2] > '9') then
      begin
        dst^ := '&';
        dst[1] := '#';
        Inc(dst, 2);
        P1 := P2;
        Continue;
      end;

      v := Ord(s[P2]) - 48;
      Inc(P2);

      while (P2 < len) and (s[P2] >= '0') and (s[P2] <= '9') do
      begin
        v := v * 10 + Ord(s[P2]) - 48;
        Inc(P2);
      end;

      PWord(dst)^ := v;

      if (P2 < len) and (s[P2] = ';') then
        Inc(P2);
    end
    else if BeginWithW(s + P2, len - P2, PWideChar(UnicodeString('lt;')), 3) then
    begin
      dst^ := '<'; Inc(P2, 3);
    end
    else if BeginWithW(s + P2, len - P2, PWideChar(UnicodeString('gt;')), 3) then
    begin
      dst^ := '>'; Inc(P2, 3);
    end
    else if BeginWithW(s + P2, len - P2, PWideChar(UnicodeString('amp;')), 4) then
    begin
      dst^ := '&'; Inc(P2, 4);
    end
    else if BeginWithW(s + P2, len - P2, PWideChar(UnicodeString('apos;')), 5) then
    begin
      dst^ := #39; Inc(P2, 5);
    end
    else if BeginWithW(s + P2, len - P2, PWideChar(UnicodeString('quot;')), 5) then
    begin
      dst^ := '"'; Inc(P2, 5);
    end
    else if BeginWithW(s + P2, len - P2, PWideChar(UnicodeString('mdash;')), 6) then
    begin
      dst^ := UnicodeString('—')[1]; Inc(P2, 6);
    end
    else begin
      dst^ := '&'; Inc(P2);
    end;

    Inc(dst);
    P1 := P2;
  end;

  SetLength(Result, dst - PWideChar(Result));
end;

function HTMLDecodeUStr(const s: UnicodeString): UnicodeString;
begin
  Result := HTMLDecodeBufferW(PWideChar(s), Length(s));
end;

function HTMLDecodeBStr(const s: WideString): WideString;
begin
  Result := HTMLDecodeBufferW(PWideChar(s), Length(s));
end;

function GetInputPropW(str: PWideChar; len: Integer; const name: UnicodeString; out P1, P2: PWideChar): Boolean; overload;
var
  P3, P4, strend: PWideChar;
  c: WideChar;
begin
  Result := False;
  strend := str + len;

  P3 := str;

  while P3 < strend do
  begin
    P3 := StrPosW(PWideChar(name), Length(name), str, len);

    if P3 = nil then Exit;

    if (P3 > str) and  ((P3-1)^ <> #32) and ((P3-1)^ <> #39) and ((P3-1)^ = '"') then
    begin
      Inc(P3, Length(name));
      Continue;
    end;

    Inc(P3, Length(name));

    while (P3 < strend) and (P3^ = #32) do Inc(P3);

    if P3 = strend then Break;

    if P3^ <> '=' then Continue;

    Inc(P3);

    while (P3 < strend) and (P3^ = #32) do Inc(P3);

    if P3 = strend then Break;

    if (P3^ <> #39) and (P3^ <> '"') then Continue;

    c := P3^;

    Inc(P3);

    P4 := P3;

    while (P4 < strend) and (P4^ <> c) do Inc(P4);

    if P4 = strend then Break;

    P1 := P3;
    P2 := P4;
    Result := True;
    Break;
  end;
end;

function GetInputPropW(str: PWideChar; len: Integer; const name: UnicodeString; out value: UnicodeString): Boolean;
var
  P1, P2: PWideChar;
begin
  Result := GetInputPropW(str, len, name, P1, P2);

  if Result then SetString(value, P1, P2 - P1);
end;

function GetInputValueW(str: PWideChar; len: Integer; const name: UnicodeString; out value: UnicodeString): Boolean;
var
  P3, P4, P5, P6, strend: PWideChar;
begin
  Result := False;

  P3 := str;
  strend := str + len;

  while P3 < strend do
  begin
    P3 := StrPosW(PWideChar(UnicodeString('<input')), 6, P3, strend - P3);

    if P3 = nil then Break;

    Inc(P3, 6);

    P4 := P3;

    while (P4 < strend) and (P4^ <> '>') do Inc(P4);

    if P4 = strend then Break;

    if GetInputPropW(P3, P4 - P3, 'name', P5, P6) and (StrCompareW(P5, P6 - P5, PWideChar(name), Length(name)) = 0) then
    begin
      Result := True;
      GetInputPropW(P3, P4-P3, 'value', value);
      Break;
    end;

    P3 := P4 + 1;
  end;
end;

function GetInputValueW(const str: UnicodeString; const name: UnicodeString; out value: UnicodeString;
  StartIndex: Integer = 1; EndIndex: Integer = 0): Boolean; overload;
begin
  if (EndIndex <= 0) or (EndIndex > Length(str)) then EndIndex := Length(str);

  if (StartIndex <= 0) or (StartIndex > EndIndex) then
  begin
    Result := False;
    Exit;
  end;

  Result := GetInputValueW(PWideChar(str) + StartIndex - 1, EndIndex + 1 - StartIndex, name, value);
end;

function GetInputPropA(str: PAnsiChar; len: Integer; const name: RawByteString; out P1, P2: PAnsiChar): Boolean;
var
  P3, P4, strend: PAnsiChar;
  c: AnsiChar;
begin
  Result := False;
  strend := str + len;

  P3 := str;

  while P3 < strend do
  begin
    P3 := StrPosA(PAnsiChar(name), Length(name), str, len);

    if P3 = nil then Exit;

    if (P3 > str) and  ((P3-1)^ <> #32) and ((P3-1)^ <> #39) and ((P3-1)^ = '"') then
    begin
      Inc(P3, Length(name));
      Continue;
    end;

    Inc(P3, Length(name));

    while (P3 < strend) and (P3^ = #32) do Inc(P3);

    if P3 = strend then Break;

    if P3^ <> '=' then Continue;

    Inc(P3);

    while (P3 < strend) and (P3^ = #32) do Inc(P3);

    if P3 = strend then Break;

    if (P3^ <> #39) and (P3^ <> '"') then Continue;

    c := P3^;

    Inc(P3);

    P4 := P3;

    while (P4 < strend) and (P4^ <> c) do Inc(P4);

    if P4 = strend then Break;

    P1 := P3;
    P2 := P4;

    Result := True;
    Break;
  end;
end;

function GetInputPropA(str: PAnsiChar; len: Integer; const name: RawByteString; out value: RawByteString): Boolean;
var
  P1, P2: PAnsiChar;
begin
  Result := GetInputPropA(str, len, name, P1, P2);

  if Result then SetString(value, P1, P2 - P1);
end;

function GetInputValueA(str: PAnsiChar; len: Integer; const name: RawByteString; out value: RawByteString): Boolean;
var
  P3, P4, P5, P6, strend: PAnsiChar;
begin
  Result := False;

  P3 := str;
  strend := str + len;

  while P3 < strend do
  begin
    P3 := StrPosA('<input', 6, P3, strend - P3);

    if P3 = nil then Break;

    Inc(P3, 6);

    P4 := P3;

    while (P4 < strend) and (P4^ <> '>') do Inc(P4);

    if P4 = strend then Break;

    if GetInputPropA(P3, P4 - P3, 'name', P5, P6) and (StrCompareA(P5, P6 - P5, PAnsiChar(name), Length(name)) = 0) then
    begin
      Result := True;
      GetInputPropA(P3, P4-P3, 'value', value);
      Break;
    end;

    P3 := P4 + 1;
  end;
end;
	
end.