unit DSLHtml;

interface

uses
  SysUtils, Classes, Windows, DSLUtils;

function HTMLDecodeBufA(s: PAnsiChar; len: Integer): RawByteString;

function HTMLDecodeStrA(const s: RawByteString): RawByteString;

function HTMLDecodeBufW(s: PWideChar; len: Integer): UnicodeString;

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

function _HTMLDecodeBufA(s: PAnsiChar; len: Integer): RawByteString;
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
  &nbsp; 	" 	空格
  'mdash; —
  }
  
  Result := '';
  dst := PAnsiChar(0);

  P1 := 0;

  while True do
  begin
    P2 := P1;

    while (P2 < len) and (s[P2] <> '&') do Inc(P2);
    
    if P2 > P1 then
    begin
      if Result <> '' then  Move(s[P1], dst^, (P2 - P1));
      Inc(dst, P2 - P1);
    end;

    P1 := P2;
    
    if P2 >= len then Break;

    if P2 = len - 1 then
    begin
      if Result <> '' then dst^ := '&';
      Inc(dst);   	  
      Break;
    end;

    Inc(P2);

    if s[P2] = '#' then
    begin
      if P2 = len - 1 then
      begin
        if Result <> '' then 
        begin 
          dst^ := '&';
          dst[1] := '#';
        end;

        Inc(dst, 2);
        Break;
      end;

      Inc(P2);

      if (s[P2] < '0') or (s[P2] > '9') then
      begin
        if Result <> '' then 
        begin 
          dst^ := '&';
          dst[1] := '#';
        end;

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

      if (P2 < len) and (s[P2] = ';') then
      begin
        Inc(P2);
      
        if Result = '' then 
        begin 
          SetLength(Result, len);
          Move(s^, Pointer(Result)^, dst - PAnsiChar(0));
          dst := PAnsiChar(Result) + (dst - PAnsiChar(0));
        end;
      
        if v < $ff then 
        begin      
          PByte(dst)^ := v;
        end
        else begin
          AnsiStrAssignWideChar(dst, WideChar(v), CP_ACP);
          Inc(dst);
        end;
      end
      else begin
        if Result <> '' then Move(s[P1], dst^, P2 - P1);
        Inc(dst, P2 - P1);
        P1 := P2;
        Continue;
      end;
    end
    else if BeginWithA(s + P2, len - P2, 'lt;', 3) then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, dst - PAnsiChar(0));
        dst := PAnsiChar(Result) + (dst - PAnsiChar(0));
      end;
      
      dst^ := '<'; Inc(P2, 3);
    end
    else if BeginWithA(s + P2, len - P2, 'gt;', 3) then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, dst - PAnsiChar(0));
        dst := PAnsiChar(Result) + (dst - PAnsiChar(0));
      end;

      dst^ := '>'; Inc(P2, 3);
    end
    else if BeginWithA(s + P2, len - P2, 'amp;', 4) then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, dst - PAnsiChar(0));
        dst := PAnsiChar(Result) + (dst - PAnsiChar(0));
      end;

      dst^ := '&'; Inc(P2, 4);
    end
    else if BeginWithA(s + P2, len - P2, 'apos;', 5) then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, dst - PAnsiChar(0));
        dst := PAnsiChar(Result) + (dst - PAnsiChar(0));
      end;

      dst^ := #39; Inc(P2, 5);
    end
    else if BeginWithA(s + P2, len - P2, 'quot;', 5) then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, dst - PAnsiChar(0));
        dst := PAnsiChar(Result) + (dst - PAnsiChar(0));
      end;

      dst^ := '"'; Inc(P2, 5);
    end
    else if BeginWithA(s + P2, len - P2, 'nbsp;', 5) then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, dst - PAnsiChar(0));
        dst := PAnsiChar(Result) + (dst - PAnsiChar(0));
      end;

      dst^ := #32; Inc(P2, 5);
    end
    else if BeginWithA(s + P2, len - P2, 'mdash;', 6) then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, dst - PAnsiChar(0));
        dst := PAnsiChar(Result) + (dst - PAnsiChar(0));
      end;
      
      AnsiStrAssignWideChar(dst, WideChar(UnicodeString('—')[1]), CP_ACP);
      Inc(dst); Inc(P2, 6);
    end
    else begin
      if Result <> '' then dst^ := '&';
    end;

    Inc(dst);
    P1 := P2;
  end;

  SetLength(Result, dst - PAnsiChar(Result));
end;

function HTMLDecodeBufA(s: PAnsiChar; len: Integer): RawByteString;
begin
  Result := _HTMLDecodeBufA(s, len);

  if Result = '' then
    SetString(Result, s, len);
end;

function HTMLDecodeStrA(const s: RawByteString): RawByteString;
begin
  Result := HTMLDecodeBufA(PAnsiChar(s), Length(s));
end;

function _HTMLDecodeBufW(s: PWideChar; len: Integer): UnicodeString;
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
  &nbsp; 	" 	空格
  'mdash; —
  }
  
  Result := '';
  dst := PWideChar(0);

  P1 := 0;

  while True do
  begin
    P2 := P1;

    while (P2 < len) and (s[P2] <> '&') do Inc(P2);
    
    if P2 > P1 then
    begin
      if Result <> '' then  Move(s[P1], dst^, (P2 - P1) * 2);
      Inc(dst, P2 - P1);
    end;

    P1 := P2;
    
    if P2 >= len then Break;

    if P2 = len - 1 then
    begin
      if Result <> '' then dst^ := '&';
      Inc(dst);   	  
      Break;
    end;

    Inc(P2);

    if s[P2] = '#' then
    begin
      if P2 = len - 1 then
      begin
        if Result <> '' then 
        begin 
          dst^ := '&';
          dst[1] := '#';
        end;

        Inc(dst, 2);
        Break;
      end;

      Inc(P2);

      if (s[P2] < '0') or (s[P2] > '9') then
      begin
        if Result <> '' then 
        begin 
          dst^ := '&';
          dst[1] := '#';
        end;

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

      if (P2 < len) and (s[P2] = ';') then
      begin
        Inc(P2);
      
        if Result = '' then 
        begin 
          SetLength(Result, len);
          Move(s^, Pointer(Result)^, (dst - PWideChar(0)) * 2);
          dst := PWideChar(Result) + (dst - PWideChar(0));
        end;

        PWord(dst)^ :=  v;
      end
      else begin
        if Result <> '' then Move(s[P1], dst^, (P2 - P1) * 2);
        Inc(dst, P2 - P1);
        P1 := P2;
        Continue;
      end;
    end
    else if BeginWithW(s + P2, len - P2, 'lt;') then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, (dst - PWideChar(0)) * 2);
        dst := PWideChar(Result) + (dst - PWideChar(0));
      end;

      dst^ := '<'; Inc(P2, 3);
    end
    else if BeginWithW(s + P2, len - P2, 'gt;') then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, (dst - PWideChar(0)) * 2);
        dst := PWideChar(Result) + (dst - PWideChar(0));
      end;

      dst^ := '>'; Inc(P2, 3);
    end
    else if BeginWithW(s + P2, len - P2, 'amp;') then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, (dst - PWideChar(0)) * 2);
        dst := PWideChar(Result) + (dst - PWideChar(0));
      end;

      dst^ := '&'; Inc(P2, 4);
    end
    else if BeginWithW(s + P2, len - P2, 'apos;') then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, (dst - PWideChar(0)) * 2);
        dst := PWideChar(Result) + (dst - PWideChar(0));
      end;

      dst^ := #39; Inc(P2, 5);
    end
    else if BeginWithW(s + P2, len - P2, 'quot;') then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, (dst - PWideChar(0)) * 2);
        dst := PWideChar(Result) + (dst - PWideChar(0));
      end;

      dst^ := '"'; Inc(P2, 5);
    end
    else if BeginWithW(s + P2, len - P2, 'nbsp;') then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, (dst - PWideChar(0)) * 2);
        dst := PWideChar(Result) + (dst - PWideChar(0));
      end;

      dst^ := #32; Inc(P2, 5);
    end
    else if BeginWithW(s + P2, len - P2, 'mdash;') then
    begin
      if Result = '' then
      begin
        SetLength(Result, len);
        Move(s^, Pointer(Result)^, (dst - PWideChar(0)) * 2);
        dst := PWideChar(Result) + (dst - PWideChar(0));
      end;
      
      dst^ := UnicodeString('—')[1];
      Inc(dst); Inc(P2, 6);
    end
    else begin
      if Result <> '' then dst^ := '&';
    end;

    Inc(dst);
    P1 := P2;
  end;

  if Result <> '' then
    SetLength(Result, dst - PWideChar(Result));
end;

function HTMLDecodeBufW(s: PWideChar; len: Integer): UnicodeString;
begin
  Result := _HTMLDecodeBufW(s, len);

  if Result = '' then
    SetString(Result, s, len);
end;

function HTMLDecodeUStr(const s: UnicodeString): UnicodeString;
begin
  Result := HTMLDecodeBufW(PWideChar(s), Length(s));
end;

function HTMLDecodeBStr(const s: WideString): WideString;
begin
  Result := HTMLDecodeBufW(PWideChar(s), Length(s));
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