unit DSLXml;

interface
	
uses
  SysUtils, Classes, Windows, DSLUtils;

function XmlEscape(const s: u16string): u16string; overload;
function XmlEscape(const s: RawByteString): RawByteString; overload;

function XMLGetNodeContent(const src, NodeName: RawByteString; start: Integer = 1; limit: Integer = -1): RawByteString;
function XMLDecodeW(s: PWideChar; len: Integer): UnicodeString; overload;
function XMLDecodeW(s: PWideChar): UnicodeString; overload;
function XMLDecodeUStr(const s: UnicodeString): UnicodeString; overload;
function XMLDecodeBStr(const s: WideString): WideString; overload;

function XMLGetNodeSectionA(const xml: TAnsiCharSection; const NodeName: RawByteString;
  out sec: TAnsiCharSection): Boolean;

function RBStrXmlGetNodeText(const xml: TAnsiCharSection; const NodeName: RawByteString): RawByteString;
function RBStrXmlGetTrimedNodeText(const xml: TAnsiCharSection; const NodeName: RawByteString): RawByteString;

function XmlTryGetInt64NodeA(const xml: TAnsiCharSection; const NodeName: RawByteString; var value: Int64): Boolean;
function XmlGetInt64NodeA(const xml: TAnsiCharSection; const NodeName: RawByteString): Int64;
function XmlTryGetIntegerNodeA(const xml: TAnsiCharSection; const NodeName: RawByteString; var value: Integer): Boolean;
function XmlGetIntegerNodeA(const xml: TAnsiCharSection; const NodeName: RawByteString): Int64;
function XmlTryGetFloatNodeA(const xml: TAnsiCharSection; const NodeName: RawByteString; var value: Double): Boolean;
function XmlGetFloatNodeA(const xml: TAnsiCharSection; const NodeName: RawByteString): Double;

function XMLGetNodeSectionW(const xml: TWideCharSection; const NodeName: UnicodeString;
  out sec: TWideCharSection): Boolean;

function UStrXmlGetNodeText(const xml: TWideCharSection; const NodeName: UnicodeString): UnicodeString;
function UStrXmlGetTrimedNodeText(const xml: TWideCharSection; const NodeName: UnicodeString): UnicodeString;

function XmlTryGetInt64NodeW(const xml: TWideCharSection; const NodeName: UnicodeString; var value: Int64): Boolean;
function XmlGetInt64NodeW(const xml: TWideCharSection; const NodeName: UnicodeString): Int64;
function XmlTryGetIntegerNodeW(const xml: TWideCharSection; const NodeName: UnicodeString; var value: Integer): Boolean;
function XmlGetIntegerNodeW(const xml: TWideCharSection; const NodeName: UnicodeString): Int64;
function XmlTryGetFloatNodeW(const xml: TWideCharSection; const NodeName: UnicodeString; var value: Double): Boolean;
function XmlGetFloatNodeW(const xml: TWideCharSection; const NodeName: UnicodeString): Double;

implementation

(* XML必须转义的字符
  &lt; 	< 	小于
  &gt; 	> 	大于
  &amp; 	& 	和号
  &apos; 	' 	单引号
  &quot; 	" 	双引号
*)

function XmlEscape(const s: u16string): u16string;
begin
  Result := UStrReplace(Result, '&', '&amp;', [rfReplaceAll]);
  Result := UStrReplace(s, '<', '&lt;', [rfReplaceAll]);
  Result := UStrReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := UStrReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := UStrReplace(Result, #39, '&apos;', [rfReplaceAll]);
end;

function XmlEscape(const s: RawByteString): RawByteString;
begin
  Result := RBStrReplace(Result, '&', '&amp;', [rfReplaceAll]);
  Result := RBStrReplace(s, '<', '&lt;', [rfReplaceAll]);
  Result := RBStrReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := RBStrReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := RBStrReplace(Result, #39, '&apos;', [rfReplaceAll]);
end;

function XMLGetNodeContent(const src, NodeName: RawByteString;
  start: Integer = 1; limit: Integer = -1): RawByteString;
begin
  Result := RBStrGetSubstrBetween(src, '<' + NodeName + '>', '</' + NodeName + '>', start, limit);
end;

function XMLDecodeW(s: PWideChar; len: Integer): UnicodeString;
var
  P1, P2: Integer;
  dst: PWideChar;
begin
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
    else if BeginWithW(s + P2 + 1, len - P2 - 1, PWideChar(UnicodeString('mdash;')), 6) then
    begin
      dst^ := UnicodeString('—')[1]; Inc(dst); Inc(P2, 6);
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

function XMLGetNodeSectionA(const xml: TAnsiCharSection; const NodeName: RawByteString;
  out sec: TAnsiCharSection): Boolean;
var
  strend, ptr: PAnsiChar;
begin
  Result := False;

  if xml.length > 0 then
  begin
    strend := xml._end;

    ptr := xml._begin;

    while True do
    begin
      while (ptr < strend) and (ptr^ <> '<') do Inc(ptr);

      if ptr >= strend then Exit;

      Inc(ptr);

      if not IBeginWithA(ptr, strend - ptr, PAnsiChar(NodeName), Length(NodeName)) then Continue;

      Inc(ptr, Length(NodeName));

      if ptr >= strend then Exit;

      if ptr^ <> '>' then Continue;

      sec._begin := ptr + 1;
      Break;
    end;

    ptr := sec._begin;

    while True do
    begin
      ptr := StrIPosA('</', 2, ptr, strend - ptr);

      if not Assigned(ptr) then Exit;

      Inc(ptr, 2);

      if not IBeginWithA(ptr, strend - ptr, PAnsiChar(NodeName), Length(NodeName)) then Continue;

      Inc(ptr, Length(NodeName));

      if ptr >= strend then Exit;

      if ptr^ <> '>' then Continue;

      sec._end := ptr - Length(NodeName) - 2;
      Result := True;
      Break;
    end;
  end;
end;

function RBStrXmlGetNodeText(const xml: TAnsiCharSection; const NodeName: RawByteString): RawByteString;
var
  sec: TAnsiCharSection;
begin
  if XMLGetNodeSectionA(xml, NodeName, sec) then Result := sec.ToString
  else Result := '';
end;

function RBStrXmlGetTrimedNodeText(const xml: TAnsiCharSection; const NodeName: RawByteString): RawByteString;
var
  sec: TAnsiCharSection;
begin
  if XMLGetNodeSectionA(xml, NodeName, sec) then
    Result := sec.trim.ToString
  else
    Result := '';
end;

function XmlTryGetInt64NodeA(const xml: TAnsiCharSection; const NodeName: RawByteString; var value: Int64): Boolean;
var
  sec: TAnsiCharSection;
begin
  if XMLGetNodeSectionA(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.TryToInt64(value);
  end
  else Result := False;
end;

function XmlGetInt64NodeA(const xml: TAnsiCharSection; const NodeName: RawByteString): Int64;
var
  sec: TAnsiCharSection;
begin
  if XMLGetNodeSectionA(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.ToInt64;
  end
  else Result := 0;
end;

function XmlTryGetIntegerNodeA(const xml: TAnsiCharSection; const NodeName: RawByteString; var value: Integer): Boolean;
var
  sec: TAnsiCharSection;
begin
  if XMLGetNodeSectionA(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.TryToInt(value);
  end
  else Result := False;
end;

function XmlGetIntegerNodeA(const xml: TAnsiCharSection; const NodeName: RawByteString): Int64;
var
  sec: TAnsiCharSection;
begin
  if XMLGetNodeSectionA(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.ToInt;
  end
  else Result := 0;
end;

function XmlTryGetFloatNodeA(const xml: TAnsiCharSection; const NodeName: RawByteString; var value: Double): Boolean;
var
  sec: TAnsiCharSection;
begin
  if XMLGetNodeSectionA(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.TryToFloat(value);
  end
  else Result := False;
end;

function XmlGetFloatNodeA(const xml: TAnsiCharSection; const NodeName: RawByteString): Double;
var
  sec: TAnsiCharSection;
begin
  if XMLGetNodeSectionA(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.ToFloat;
  end
  else Result := 0;
end;

function XMLGetNodeSectionW(const xml: TWideCharSection; const NodeName: UnicodeString;
  out sec: TWideCharSection): Boolean;
var
  strend, ptr: PWideChar;
begin
  Result := False;

  if xml.length > 0 then
  begin
    strend := xml._end;

    ptr := xml._begin;

    while True do
    begin
      while (ptr < strend) and (ptr^ <> '<') do Inc(ptr);

      if ptr >= strend then Exit;

      Inc(ptr);

      if not IBeginWithW(ptr, strend - ptr, PWideChar(NodeName), Length(NodeName)) then Continue;

      Inc(ptr, Length(NodeName));

      if ptr >= strend then Exit;

      if ptr^ <> '>' then Continue;

      sec._begin := ptr + 1;
      Break;
    end;

    ptr := sec._begin;

    while True do
    begin
      ptr := StrIPosW('</', ptr, strend - ptr);

      if not Assigned(ptr) then Exit;

      Inc(ptr, 2);

      if not IBeginWithW(ptr, strend - ptr, PWideChar(NodeName), Length(NodeName)) then Continue;

      Inc(ptr, Length(NodeName));

      if ptr >= strend then Exit;

      if ptr^ <> '>' then Continue;

      sec._end := ptr - Length(NodeName) - 2;
      sec.ExtractXmlCDATA;
      Result := True;
      Break;
    end;
  end;
end;

function UStrXmlGetNodeText(const xml: TWideCharSection; const NodeName: UnicodeString): UnicodeString;
var
  sec: TWideCharSection;
begin
  if XMLGetNodeSectionW(xml, NodeName, sec) then Result := sec.ToUStr
  else Result := '';
end;

function UStrXmlGetTrimedNodeText(const xml: TWideCharSection; const NodeName: UnicodeString): UnicodeString;
var
  sec: TWideCharSection;
begin
  if XMLGetNodeSectionW(xml, NodeName, sec) then Result := sec.trim.ToUStr
  else Result := '';
end;

function XmlTryGetInt64NodeW(const xml: TWideCharSection; const NodeName: UnicodeString; var value: Int64): Boolean;
var
  sec: TWideCharSection;
begin
  if XMLGetNodeSectionW(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.TryToInt64(value);
  end
  else Result := False;
end;

function XmlGetInt64NodeW(const xml: TWideCharSection; const NodeName: UnicodeString): Int64;
var
  sec: TWideCharSection;
begin
  if XMLGetNodeSectionW(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.ToInt64;
  end
  else Result := 0;
end;

function XmlTryGetIntegerNodeW(const xml: TWideCharSection; const NodeName: UnicodeString; var value: Integer): Boolean;
var
  sec: TWideCharSection;
begin
  if XMLGetNodeSectionW(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.TryToInt(value);
  end
  else Result := False;
end;

function XmlGetIntegerNodeW(const xml: TWideCharSection; const NodeName: UnicodeString): Int64;
var
  sec: TWideCharSection;
begin
  if XMLGetNodeSectionW(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.ToInt;
  end
  else Result := 0;
end;

function XmlTryGetFloatNodeW(const xml: TWideCharSection; const NodeName: UnicodeString; var value: Double): Boolean;
var
  sec: TWideCharSection;
begin
  if XMLGetNodeSectionW(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.TryToFloat(value);
  end
  else Result := False;
end;

function XmlGetFloatNodeW(const xml: TWideCharSection; const NodeName: UnicodeString): Double;
var
  sec: TWideCharSection;
begin
  if XMLGetNodeSectionW(xml, NodeName, sec) then
  begin
    sec.trim;
    Result := sec.ToFloat;
  end
  else Result := 0;
end;
	
end.