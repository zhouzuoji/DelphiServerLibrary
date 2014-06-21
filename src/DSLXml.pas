unit DSLXml;

interface
	
uses
  SysUtils, Classes, Windows, DSLUtils;

function XMLGetNodeContent(const src, NodeName: RawByteString; start: Integer = 1; limit: Integer = -1): RawByteString;

function XMLDecodeW(s: PWideChar; len: Integer): UnicodeString; overload;

function XMLDecodeW(s: PWideChar): UnicodeString; overload;

function XMLDecodeUStr(const s: UnicodeString): UnicodeString; overload;

function XMLDecodeBStr(const s: WideString): WideString; overload;

implementation

function XMLGetNodeContent(const src, NodeName: RawByteString;
  start: Integer = 1; limit: Integer = -1): RawByteString;
begin
  Result := GetSubstrBetweenA(
    src,
    '<' + NodeName + '>',
    '</' + NodeName + '>',
    start,
    limit);
end;

function XMLDecodeW(s: PWideChar; len: Integer): UnicodeString;
var
  P1, P2: Integer;
  dst: PWideChar;
begin
  {
  &lt; 	< 	小于
  &gt; 	> 	大于
  &amp; 	& 	和号
  &apos; 	' 	省略号
  &quot; 	" 	引号
  }

  SetLength(Result, len);

  dst := PWideChar(Result);

  P1 := 0;

  while True do
  begin
    P2 := P1;
    
    while (P2 < len) and (s[P2] <> '&') do Inc(P2);

    Move(s[P1], dst^, (P2 - P1) * 2);
    Inc(dst, P2 - P1);

    if P2 >= len then Break;

    if BeginWithW(s + P2 + 1, len - P2 - 1, PWideChar(UnicodeString('lt;')), 3) then
    begin
      dst^ := '<'; Inc(dst); Inc(P2, 3);
    end
    else if BeginWithW(s + P2 + 1, len - P2 - 1, PWideChar(UnicodeString('gt;')), 3) then
    begin
      dst^ := '>'; Inc(dst); Inc(P2, 3);
    end
    else if BeginWithW(s + P2 + 1, len - P2 - 1, PWideChar(UnicodeString('amp;')), 4) then
    begin
      dst^ := '&'; Inc(dst); Inc(P2, 4);
    end
    else if BeginWithW(s + P2 + 1, len - P2 - 1, PWideChar(UnicodeString('apos;')), 5) then
    begin
      dst^ := #39; Inc(dst); Inc(P2, 5);
    end
    else if BeginWithW(s + P2 + 1, len - P2 - 1, PWideChar(UnicodeString('quot;')), 5) then
    begin
      dst^ := '"'; Inc(dst); Inc(P2, 5);
    end
    else begin
      dst^ := '&'; Inc(dst);
    end;

    P1 := P2 + 1;
  end;

  SetLength(Result, dst - PWideChar(Result));
end;

function XMLDecodeW(s: PWideChar): UnicodeString;
begin
  Result := XMLDecodeW(s, StrLenW(s));
end;

function XMLDecodeUStr(const s: UnicodeString): UnicodeString;
begin
  Result := XMLDecodeW(PWideChar(s), Length(s));
end;

function XMLDecodeBStr(const s: WideString): WideString;
begin
  Result := XMLDecodeW(PWideChar(s), Length(s));
end;
	
end.