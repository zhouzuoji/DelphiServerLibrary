unit DSLHtml;

interface

uses
  SysUtils, Classes, Contnrs, Windows, Dialogs, DSLUtils, DSLGenerics, Generics.Collections;

type
  THtmlEntity = record
    expr: RawByteString;
    charCode: Word;
  end;
  PHtmlEntity = ^THtmlEntity;

const
  HtmlEntityTable: array [0..240] of THtmlEntity = (
    (expr: '&quot;'; charCode: 34),
    (expr: '&apos;'; charCode: 39),
    (expr: '&amp;'; charCode: 38),
    (expr: '&lt;'; charCode: 60),
    (expr: '&gt;'; charCode: 62),
    (expr: '&nbsp;'; charCode: 160),
    (expr: '&iexcl;'; charCode: 161),
    (expr: '&cent;'; charCode: 162),
    (expr: '&pound;'; charCode: 163),
    (expr: '&curren;'; charCode: 164),
    (expr: '&yen;'; charCode: 165),
    (expr: '&brvbar;'; charCode: 166),
    (expr: '&sect;'; charCode: 167),
    (expr: '&uml;'; charCode: 168),
    (expr: '&copy;'; charCode: 169),
    (expr: '&ordf;'; charCode: 170),
    (expr: '&laquo;'; charCode: 171),
    (expr: '&not;'; charCode: 172),
    (expr: '&shy;'; charCode: 173),
    (expr: '&reg;'; charCode: 174),
    (expr: '&macr;'; charCode: 175),
    (expr: '&deg;'; charCode: 176),
    (expr: '&plusmn;'; charCode: 177),
    (expr: '&sup2;'; charCode: 178),
    (expr: '&sup3;'; charCode: 179),
    (expr: '&acute;'; charCode: 180),
    (expr: '&micro;'; charCode: 181),
    (expr: '&para;'; charCode: 182),
    (expr: '&middot;'; charCode: 183),
    (expr: '&cedil;'; charCode: 184),
    (expr: '&sup1;'; charCode: 185),
    (expr: '&ordm;'; charCode: 186),
    (expr: '&raquo;'; charCode: 187),
    (expr: '&frac14;'; charCode: 188),
    (expr: '&frac12;'; charCode: 189),
    (expr: '&frac34;'; charCode: 190),
    (expr: '&iquest;'; charCode: 191),
    (expr: '&times;'; charCode: 215),
    (expr: '&divide;'; charCode: 247),
    (expr: '&Agrave;'; charCode: 192),
    (expr: '&Aacute;'; charCode: 193),
    (expr: '&Acirc;'; charCode: 194),
    (expr: '&Atilde;'; charCode: 195),
    (expr: '&Auml;'; charCode: 196),
    (expr: '&Aring;'; charCode: 197),
    (expr: '&AElig;'; charCode: 198),
    (expr: '&Ccedil;'; charCode: 199),
    (expr: '&Egrave;'; charCode: 200),
    (expr: '&Eacute;'; charCode: 201),
    (expr: '&Ecirc;'; charCode: 202),
    (expr: '&Euml;'; charCode: 203),
    (expr: '&Igrave;'; charCode: 204),
    (expr: '&Iacute;'; charCode: 205),
    (expr: '&Icirc;'; charCode: 206),
    (expr: '&Iuml;'; charCode: 207),
    (expr: '&ETH;'; charCode: 208),
    (expr: '&Ntilde;'; charCode: 209),
    (expr: '&Ograve;'; charCode: 210),
    (expr: '&Oacute;'; charCode: 211),
    (expr: '&Ocirc;'; charCode: 212),
    (expr: '&Otilde;'; charCode: 213),
    (expr: '&Ouml;'; charCode: 214),
    (expr: '&Oslash;'; charCode: 216),
    (expr: '&Ugrave;'; charCode: 217),
    (expr: '&Uacute;'; charCode: 218),
    (expr: '&Ucirc;'; charCode: 219),
    (expr: '&Uuml;'; charCode: 220),
    (expr: '&Yacute;'; charCode: 221),
    (expr: '&THORN;'; charCode: 222),
    (expr: '&szlig;'; charCode: 223),
    (expr: '&agrave;'; charCode: 224),
    (expr: '&aacute;'; charCode: 225),
    (expr: '&acirc;'; charCode: 226),
    (expr: '&atilde;'; charCode: 227),
    (expr: '&auml;'; charCode: 228),
    (expr: '&aring;'; charCode: 229),
    (expr: '&aelig;'; charCode: 230),
    (expr: '&ccedil;'; charCode: 231),
    (expr: '&egrave;'; charCode: 232),
    (expr: '&eacute;'; charCode: 233),
    (expr: '&ecirc;'; charCode: 234),
    (expr: '&euml;'; charCode: 235),
    (expr: '&igrave;'; charCode: 236),
    (expr: '&iacute;'; charCode: 237),
    (expr: '&icirc;'; charCode: 238),
    (expr: '&iuml;'; charCode: 239),
    (expr: '&eth;'; charCode: 240),
    (expr: '&ntilde;'; charCode: 241),
    (expr: '&ograve;'; charCode: 242),
    (expr: '&oacute;'; charCode: 243),
    (expr: '&ocirc;'; charCode: 244),
    (expr: '&otilde;'; charCode: 245),
    (expr: '&ouml;'; charCode: 246),
    (expr: '&oslash;'; charCode: 248),
    (expr: '&ugrave;'; charCode: 249),
    (expr: '&uacute;'; charCode: 250),
    (expr: '&ucirc;'; charCode: 251),
    (expr: '&uuml;'; charCode: 252),
    (expr: '&yacute;'; charCode: 253),
    (expr: '&thorn;'; charCode: 254),
    (expr: '&yuml;'; charCode: 255),
    (expr: '&forall;'; charCode: 8704),
    (expr: '&part;'; charCode: 8706),
    (expr: '&exists;'; charCode: 8707),
    (expr: '&empty;'; charCode: 8709),
    (expr: '&nabla;'; charCode: 8711),
    (expr: '&isin;'; charCode: 8712),
    (expr: '&notin;'; charCode: 8713),
    (expr: '&ni;'; charCode: 8715),
    (expr: '&prod;'; charCode: 8719),
    (expr: '&sum;'; charCode: 8721),
    (expr: '&minus;'; charCode: 8722),
    (expr: '&lowast;'; charCode: 8727),
    (expr: '&radic;'; charCode: 8730),
    (expr: '&prop;'; charCode: 8733),
    (expr: '&infin;'; charCode: 8734),
    (expr: '&ang;'; charCode: 8736),
    (expr: '&and;'; charCode: 8743),
    (expr: '&or;'; charCode: 8744),
    (expr: '&cap;'; charCode: 8745),
    (expr: '&cup;'; charCode: 8746),
    (expr: '&int;'; charCode: 8747),
    (expr: '&there4;'; charCode: 8756),
    (expr: '&sim;'; charCode: 8764),
    (expr: '&cong;'; charCode: 8773),
    (expr: '&asymp;'; charCode: 8776),
    (expr: '&ne;'; charCode: 8800),
    (expr: '&equiv;'; charCode: 8801),
    (expr: '&le;'; charCode: 8804),
    (expr: '&ge;'; charCode: 8805),
    (expr: '&sub;'; charCode: 8834),
    (expr: '&sup;'; charCode: 8835),
    (expr: '&nsub;'; charCode: 8836),
    (expr: '&sube;'; charCode: 8838),
    (expr: '&supe;'; charCode: 8839),
    (expr: '&oplus;'; charCode: 8853),
    (expr: '&otimes;'; charCode: 8855),
    (expr: '&perp;'; charCode: 8869),
    (expr: '&sdot;'; charCode: 8901),
    (expr: '&Alpha;'; charCode: 913),
    (expr: '&Beta;'; charCode: 914),
    (expr: '&Gamma;'; charCode: 915),
    (expr: '&Delta;'; charCode: 916),
    (expr: '&Epsilon;'; charCode: 917),
    (expr: '&Zeta;'; charCode: 918),
    (expr: '&Eta;'; charCode: 919),
    (expr: '&Theta;'; charCode: 920),
    (expr: '&Iota;'; charCode: 921),
    (expr: '&Kappa;'; charCode: 922),
    (expr: '&Lambda;'; charCode: 923),
    (expr: '&Mu;'; charCode: 924),
    (expr: '&Nu;'; charCode: 925),
    (expr: '&Xi;'; charCode: 926),
    (expr: '&Omicron;'; charCode: 927),
    (expr: '&Pi;'; charCode: 928),
    (expr: '&Rho;'; charCode: 929),
    (expr: '&Sigma;'; charCode: 931),
    (expr: '&Tau;'; charCode: 932),
    (expr: '&Upsilon;'; charCode: 933),
    (expr: '&Phi;'; charCode: 934),
    (expr: '&Chi;'; charCode: 935),
    (expr: '&Psi;'; charCode: 936),
    (expr: '&Omega;'; charCode: 937),
    (expr: '&alpha;'; charCode: 945),
    (expr: '&beta;'; charCode: 946),
    (expr: '&gamma;'; charCode: 947),
    (expr: '&delta;'; charCode: 948),
    (expr: '&epsilon;'; charCode: 949),
    (expr: '&zeta;'; charCode: 950),
    (expr: '&eta;'; charCode: 951),
    (expr: '&theta;'; charCode: 952),
    (expr: '&iota;'; charCode: 953),
    (expr: '&kappa;'; charCode: 954),
    (expr: '&lambda;'; charCode: 923),
    (expr: '&mu;'; charCode: 956),
    (expr: '&nu;'; charCode: 925),
    (expr: '&xi;'; charCode: 958),
    (expr: '&omicron;'; charCode: 959),
    (expr: '&pi;'; charCode: 960),
    (expr: '&rho;'; charCode: 961),
    (expr: '&sigmaf;'; charCode: 962),
    (expr: '&sigma;'; charCode: 963),
    (expr: '&tau;'; charCode: 964),
    (expr: '&upsilon;'; charCode: 965),
    (expr: '&phi;'; charCode: 966),
    (expr: '&chi;'; charCode: 967),
    (expr: '&psi;'; charCode: 968),
    (expr: '&omega;'; charCode: 969),
    (expr: '&thetasym;'; charCode: 977),
    (expr: '&upsih;'; charCode: 978),
    (expr: '&piv;'; charCode: 982),
    (expr: '&OElig;'; charCode: 338),
    (expr: '&oelig;'; charCode: 339),
    (expr: '&Scaron;'; charCode: 352),
    (expr: '&scaron;'; charCode: 353),
    (expr: '&Yuml;'; charCode: 376),
    (expr: '&fnof;'; charCode: 402),
    (expr: '&circ;'; charCode: 710),
    (expr: '&tilde;'; charCode: 732),
    (expr: '&ensp;'; charCode: 8194),
    (expr: '&emsp;'; charCode: 8195),
    (expr: '&thinsp;'; charCode: 8201),
    (expr: '&zwnj;'; charCode: 8204),
    (expr: '&zwj;'; charCode: 8205),
    (expr: '&lrm;'; charCode: 8206),
    (expr: '&rlm;'; charCode: 8207),
    (expr: '&ndash;'; charCode: 8211),
    (expr: '&mdash;'; charCode: 8212),
    (expr: '&lsquo;'; charCode: 8216),
    (expr: '&rsquo;'; charCode: 8217),
    (expr: '&sbquo;'; charCode: 8218),
    (expr: '&ldquo;'; charCode: 8220),
    (expr: '&rdquo;'; charCode: 8221),
    (expr: '&bdquo;'; charCode: 8222),
    (expr: '&dagger;'; charCode: 8224),
    (expr: '&Dagger;'; charCode: 8225),
    (expr: '&bull;'; charCode: 8226),
    (expr: '&hellip;'; charCode: 8230),
    (expr: '&permil;'; charCode: 8240),
    (expr: '&prime;'; charCode: 8242),
    (expr: '&Prime;'; charCode: 8243),
    (expr: '&lsaquo;'; charCode: 8249),
    (expr: '&rsaquo;'; charCode: 8250),
    (expr: '&oline;'; charCode: 8254),
    (expr: '&euro;'; charCode: 8364),
    (expr: '&trade;'; charCode: 8482),
    (expr: '&larr;'; charCode: 8592),
    (expr: '&uarr;'; charCode: 8593),
    (expr: '&rarr;'; charCode: 8594),
    (expr: '&darr;'; charCode: 8595),
    (expr: '&harr;'; charCode: 8596),
    (expr: '&crarr;'; charCode: 8629),
    (expr: '&lceil;'; charCode: 8968),
    (expr: '&rceil;'; charCode: 8969),
    (expr: '&lfloor;'; charCode: 8970),
    (expr: '&rfloor;'; charCode: 8971),
    (expr: '&loz;'; charCode: 9674),
    (expr: '&spades;'; charCode: 9824),
    (expr: '&clubs;'; charCode: 9827),
    (expr: '&hearts;'; charCode: 9829),
    (expr: '&diams;'; charCode: 9830)
  );

type
  THtmlInput = class(TRefCountedObject)
  public
    name: u16string;
    value: u16string;
  end;

  THtmlInputs = class(TObjectListEx<THtmlInput>)
  private
    function GetS(const name: u16string): u16string;
    procedure SetS(const name, Value: u16string);
  public
    function IndexOf(const name: u16string): Integer;
    function exists(const name: u16string): Boolean;
    procedure remove(const name: u16string);
    function MakeForm(CodePage: Integer = CP_UTF8): RawByteString;
    property S[const name: u16string]: u16string read GetS write SetS;
  end;

  THtmlForm = class(TRefCountedObject)
  private
    FInputs: THtmlInputs;
  public
    id: u16string;
    name: u16string;
    action: u16string;
    method: u16string;
    constructor Create;
    destructor Destroy; override;
    property inputs: THtmlInputs read FInputs;
  end;

  THtmlForms = TObjectListEx<THtmlForm>;

procedure HttpParamAppend(var param: RawByteString; const name, value: RawByteString);

function HTMLDecodeBufA(s: PAnsiChar; len: Integer; dst: PAnsiChar; pUnescaped: PInteger): Integer; overload;
function HTMLDecodeBufA(s: PAnsiChar; len: Integer): RawByteString; overload;
function HTMLDecodeRBStr(const s: RawByteString): RawByteString;

function HTMLDecodeBufW(s: PWideChar; len: Integer; dst: PWideChar; pUnescaped: PInteger): Integer; overload;
function HTMLDecodeBufW(s: PWideChar; len: Integer): u16string; overload;
function HTMLDecodeUStr(const s: u16string): u16string;
function HTMLDecodeBStr(const s: WideString): WideString;

function HtmlElementGetPropValue(const html, PropName: TAnsiCharSection): TAnsiCharSection; overload;
function HtmlElementFind(const html, TagName, PropName, PropValue: TAnsiCharSection): TAnsiCharSection; overload;
function HtmlElementFind(const html: TAnsiCharSection; const TagName,
  PropName, PropValue: RawByteString): TAnsiCharSection; overload;
function HtmlGetPropByProp(const html, TagName, SearchPropName, SearchPropValue, PropName: RawByteString;
  first: Integer = 1; last: Integer = 0): RawByteString; overload;
function HtmlGetPropByProp(const html, TagName, SearchPropName, SearchPropValue, PropName: TAnsiCharSection): TAnsiCharSection; overload;

function HtmlElementGetInnerHtml(const elem: TWideCharSection): TWideCharSection;
function HtmlElementGetInnerText(const elem: TWideCharSection): u16string;
function HtmlElementGetPropValue(const html, PropName: TWideCharSection): TWideCharSection; overload;
function HtmlElementFind(const html, TagName, PropName, PropValue: TWideCharSection): TWideCharSection; overload;
function HtmlElementFind(const html: TWideCharSection; const TagName, PropName, PropValue: u16string): TWideCharSection; overload;
function UStrHtmlGetPropByProp(const html, TagName, SearchPropName, SearchPropValue, PropName: u16string;
  first: Integer = 1; last: Integer = 0): u16string;
function HtmlGetPropByProp(const html: TWideCharSection; const TagName, SearchPropName, SearchPropValue,
  PropName: u16string): TWideCharSection; overload;

function _UStrHtmlGetInnerText(first, last: PWideChar): u16string;
function _UStrHtmlGetInnerText2(s: u16string): u16string;

function HtmlFindInnerHtml(const html: TWideCharSection; const TagName, SearchPropName,
  SearchPropValue: u16string): TWideCharSection;

function UStrGetInnerHtml(const html, TagName, SearchPropName, SearchPropValue: u16string;
  const EndTag: u16string = ''; first: Integer = 1; last: Integer = 0): u16string;

function UStrHtmlGetInnerText(const html, TagName, SearchPropName, SearchPropValue: u16string;
  const EndTag: u16string = ''; first: Integer = 1; last: Integer = 0): u16string;

procedure GetHtmlAnchors(const html: u16string; const SuffixList: array of u16string; AnchorList: TUnicodeStrings);

function GetHtmlFormW(const htmlsec: TWideCharSection; const PropName, PropValue: u16string;
  inputs: THtmlInputs): TWideCharSection;

function UStrGetHtmlForm(const html, PropName, PropValue: u16string; inputs: THtmlInputs): Boolean;
function HtmlGetForms(const html, PropName, PropValue: u16string): THtmlForms;
function GetVariableValue(const str: TWideCharSection; const name: u16string): TWideCharSection; overload;
function GetVariableValue(const str: TAnsiCharSection; const name: RawByteString): TAnsiCharSection; overload;
function GetVariableValue(const str, name: u16string): TWideCharSection; overload;
function GetVariableValue(const str: RawByteString; const name: RawByteString): TAnsiCharSection; overload;

implementation

procedure HttpParamAppend(var param: RawByteString; const name, value: RawByteString);
begin
  if param = '' then param := HttpEncode(name) + '='+ HttpEncode(value)
  else param := param + '&' + HttpEncode(name) + '='+ HttpEncode(value);
end;

function DetectHtmlEntityA(s: PAnsiChar; len: Integer): PHtmlEntity;
var
  i, j, L: Integer;
  tmp: PHtmlEntity;
  expr: PAnsiChar;
  matched: Boolean;
begin
  Result := nil;

  for i := Low(HtmlEntityTable) to High(HtmlEntityTable) do
  begin
    tmp := @HtmlEntityTable[i];
    expr := PAnsiChar(tmp^.expr);
    L := Length(tmp^.expr);
    if len + 1 >= L then
    begin
      matched := True;
      for j := 0 to L - 2 do
        if s[j] <> expr[j + 1] then
        begin
          matched := False;
          Break;
        end;
      if matched then
      begin
        Result := tmp;
        Break;
      end;
    end;
  end;
end;

function HTMLDecodeBufA(s: PAnsiChar; len: Integer; dst: PAnsiChar; pUnescaped: PInteger): Integer;
var
  P1, P2, nEscaped: Integer;
  v: DWORD;
  entity: PHtmlEntity;
  procedure CheckStringAllocW(EntityCode: Word);
  var
    L: Integer;
  begin
    if dst = nil then
      L := AnsiStrAssignWideChar(nil, 0, WideChar(EntityCode), CP_ACP)
    else
      L := AnsiStrAssignWideChar(dst + Result, 3, WideChar(EntityCode), CP_ACP);

    Inc(Result, L);
    Inc(pUnescaped^);
  end;

  procedure CheckStringAllocA(entity: AnsiChar);
  begin
    if dst <> nil then
      dst[Result] := entity;
    Inc(Result);
    Inc(pUnescaped^);
  end;
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

  Result := 0;

  if pUnescaped = nil then
    pUnescaped := @nEscaped;

  pUnescaped^ := 0;

  P1 := 0;

  while True do
  begin
    P2 := P1;

    while (P2 < len) and (s[P2] <> '&') do Inc(P2);

    if P2 > P1 then
    begin
      if dst <> nil then
        Move(s[P1], dst[Result], P2 - P1);
      Inc(Result, P2 - P1);
    end;

    P1 := P2;

    if P2 >= len then Break;

    if P2 = len - 1 then
    begin
      if dst <> nil then
        dst[Result] := '&';
      Inc(Result);
      Break;
    end;

    Inc(P2);

    if s[P2] = '#' then
    begin
      if P2 = len - 1 then
      begin
        if dst <> nil then
        begin
          dst[Result] := '&';
          dst[Result + 1] := '#';
        end;

        Inc(Result, 2);
        Break;
      end;

      Inc(P2);

      if (s[P2] < '0') or (s[P2] > '9') then
      begin
        if dst <> nil then
        begin
          dst[Result] := '&';
          dst[Result + 1] := '#';
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
        CheckStringAllocW(v);
      end
      else begin
        if dst <> nil then
          Move(s[P1], dst[Result], (P2 - P1));
        Inc(Result, P2 - P1);
        P1 := P2;
        Continue;
      end;
    end
    else begin
      entity := DetectHtmlEntityA(s + P2, len - P2);

      if Assigned(entity) then
      begin
        CheckStringAllocW(entity^.charCode);
        Inc(P2, Length(entity^.expr) - 1);
      end
      else begin
        if dst <> nil then
          dst[Result] := '&';
        Inc(Result);
      end;
    end;

    P1 := P2;
  end;
end;

function HTMLDecodeBufA(s: PAnsiChar; len: Integer): RawByteString;
var
  nEscaped, L: Integer;
begin
  L := HTMLDecodeBufA(s, len, nil, @nEscaped);

  if nEscaped = 0 then
    SetString(Result, s, len)
  else begin
    SetLength(Result, L);
    HTMLDecodeBufA(s, len, PAnsiChar(Result), @nEscaped);
  end;
end;

function HTMLDecodeRBStr(const s: RawByteString): RawByteString;
var
  nEscaped, L: Integer;
begin
  L := HTMLDecodeBufA(PAnsiChar(s), Length(s), nil, @nEscaped);

  if nEscaped = 0 then
    Result := s
  else begin
    SetLength(Result, L);
    HTMLDecodeBufA(PAnsiChar(s), Length(s), PAnsiChar(Result), @nEscaped);
  end;
end;

function DetectHtmlEntityW(s: PWideChar; len: Integer): PHtmlEntity;
var
  i, j, L: Integer;
  tmp: PHtmlEntity;
  expr: PAnsiChar;
  matched: Boolean;
begin
  Result := nil;

  for i := Low(HtmlEntityTable) to High(HtmlEntityTable) do
  begin
    tmp := @HtmlEntityTable[i];
    expr := PAnsiChar(tmp^.expr);
    L := Length(tmp^.expr);
    if len + 1 >= L then
    begin
      matched := True;
      for j := 0 to L - 2 do
        if Ord(s[j]) <> Ord(expr[j + 1]) then
        begin
          matched := False;
          Break;
        end;
      if matched then
      begin
        Result := tmp;
        Break;
      end;
    end;
  end;
end;

function HTMLDecodeBufW(s: PWideChar; len: Integer; dst: PWideChar; pUnescaped: PInteger): Integer;
var
  P1, P2, nEscaped: Integer;
  v: DWORD;
  entity: PHtmlEntity;
  procedure CheckStringAlloc(EntityCode: Word);
  begin
    if dst <> nil then
      dst[Result] := WideChar(EntityCode);

    Inc(Result);
    Inc(pUnescaped^);
  end;
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

  Result := 0;

  if pUnescaped = nil then
    pUnescaped := @nEscaped;

  pUnescaped^ := 0;
  P1 := 0;

  while True do
  begin
    P2 := P1;

    while (P2 < len) and (s[P2] <> '&') do Inc(P2);
    
    if P2 > P1 then
    begin
      if dst <> nil then
        Move(s[P1], dst[Result], (P2 - P1) * 2);
      Inc(Result, P2 - P1);
    end;

    P1 := P2;
    
    if P2 >= len then Break;

    if P2 = len - 1 then
    begin
      if dst <> nil then
        dst[Result] := '&';
      Inc(Result);
      Break;
    end;

    Inc(P2);

    if s[P2] = '#' then
    begin
      if P2 = len - 1 then
      begin
        if dst <> nil then
        begin
          dst[Result] := '&';
          dst[Result + 1] := '#';
        end;

        Inc(Result, 2);
        Break;
      end;

      Inc(P2);

      if (s[P2] < '0') or (s[P2] > '9') then
      begin
        if dst <> nil then
        begin
          dst[Result] := '&';
          dst[Result + 1] := '#';
        end;

        Inc(Result, 2);

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
        CheckStringAlloc(v);
      end
      else begin
        if dst <> nil then
          Move(s[P1], dst[Result], (P2 - P1) * 2);
        Inc(Result, P2 - P1);
        P1 := P2;
        Continue;
      end;
    end
    else begin
      entity := DetectHtmlEntityW(s + P2, len - P2);

      if Assigned(entity) then
      begin
        CheckStringAlloc(entity^.charCode);
        Inc(P2, Length(entity^.expr) - 1);
      end
      else begin
        if dst <> nil then
          dst[Result] := '&';
        Inc(Result);
      end;
    end;

    P1 := P2;
  end;
end;

function HTMLDecodeBufW(s: PWideChar; len: Integer): u16string;
var
  L, nEscaped: Integer;
begin
  L := HTMLDecodeBufW(s, len, nil, @nEscaped);

  if nEscaped = 0 then
    SetString(Result, s, len)
  else begin
    SetLength(Result, L);
    HTMLDecodeBufW(s, len, PWideChar(Result), @nEscaped);
  end;
end;

function HTMLDecodeUStr(const s: u16string): u16string;
var
  L, nEscaped: Integer;
begin
  L := HTMLDecodeBufW(PWideChar(s), Length(s), nil, @nEscaped);

  if nEscaped = 0 then
    Result := s
  else begin
    SetLength(Result, L);
    HTMLDecodeBufW(PWideChar(s), Length(s), PWideChar(Result), @nEscaped);
  end;
end;

function HTMLDecodeBStr(const s: WideString): WideString;
var
  L, nEscaped: Integer;
begin
  L := HTMLDecodeBufW(PWideChar(s), Length(s), nil, @nEscaped);

  if nEscaped = 0 then
    Result := s
  else begin
    SetLength(Result, L);
    HTMLDecodeBufW(PWideChar(s), Length(s), PWideChar(Result), @nEscaped);
  end;
end;

function FindEndTagA(first, last: PAnsiChar): PAnsiChar;
var
  p: PAnsiChar;
  n: Integer;
begin
  n := 1;
  p := first;
  Result := nil;

  while p < last do
  begin
    if p^ = '<' then
    begin
      Inc(p);

      if p >= last then Exit;

      if p^ = '/' then
      begin
        Dec(n);

        if n = 0 then
        begin
          while (p<last) and (p^<>'>') do Inc(p);
          if p < last then Result := p + 1;
          Exit;
        end;
      end
      else
        Inc(n);
    end
    else if p^ = '>' then
    begin
      if (p-1)^ = '/' then
      begin
        Dec(n);

        if n = 0 then
        begin
          Result := p + 1;
          Exit;
        end;
      end;

      Inc(p);
    end
    else Inc(p);
  end;
end;

function HtmlElementGetPropValue(const html, PropName: TAnsiCharSection): TAnsiCharSection;
var
  P3, P4: PAnsiChar;
  c: AnsiChar;
  tmp: TAnsiCharSection;
begin
  Result.SetInvalid;

  tmp._begin := html._begin;
  tmp._end := html._end;

  while tmp.length > 0 do
  begin
    P3 := tmp.ipos(PropName);

    if P3 = nil then Break;
    P4 := P3;
    Inc(P3, PropName.length);
    if P3 >= tmp._end then Break;

    if (P4 > html._begin) and ((P4-1)^ > #32) then
    begin
      if ((P4-1)^ <> #39) and ((P4-1)^ <> '"') then
      begin
        tmp._begin := P3;
        Continue;
      end
      else if (P4-1)^ <> P3^ then
      begin
        tmp._begin := P3;
        Continue;
      end
      else Inc(P3);
    end;

    while (P3 < tmp._end) and (P3^ <= #32) do Inc(P3);
    if P3 = tmp._end then Break;
    if P3^ <> '=' then
    begin
      tmp._begin := P3;
      Continue;
    end;

    Inc(P3);

    while (P3 < tmp._end) and (P3^ <= #32) do Inc(P3);

    if P3 >= tmp._end then Break;

    if (P3^ <> #39) and (P3^ <> '"') then
    begin
      P4 := P3 + 1;
      while (P4 < tmp._end) and (P4^ > #32) and (P4^ <> '>') do Inc(P4);
      // if P4 >= tmp._end then Break;
      Result._begin := P3;
      Result._end := P4;
      Break;
    end
    else begin
      c := P3^;
      Inc(P3);
      P4 := P3;
      while (P4 < tmp._end) and (P4^ <> c) and (P4^ <> '>') do Inc(P4);

      if P4 >= tmp._end then Break
      else if P4^ <> c then
      begin
        tmp._begin := P4;
        Continue;
      end
      else begin
        Result._begin := P3;
        Result._end := P4;
        Break;
      end;
    end;
  end;
end;

function HtmlElementFind(const html, TagName, PropName, PropValue: TAnsiCharSection): TAnsiCharSection;
var
  P1, strend, elemend: PAnsiChar;
  _BeginTag: array [0..63] of AnsiChar;
  i: Integer;
  tmp, BeginTag, elem, value: TAnsiCharSection;
begin
  Result.SetInvalid;

  _BeginTag[0] := '<';

  for i := 0 to TagName.length - 1 do
    _BeginTag[i + 1] := TagName._begin[i];

  BeginTag._begin := _BeginTag;
  BeginTag._end := @_BeginTag[TagName.length + 1];
  tmp._begin := html._begin;
  tmp._end := html._end;
  strend := html._end;

  while tmp.length > 0 do
  begin
    P1 := tmp.ipos(BeginTag);
    if P1 = nil then Break;
    tmp._begin := P1 + BeginTag.length;

    if (tmp._begin >= strend) or (tmp._begin^ > #32) then Continue;

    Inc(tmp._begin);

    while (tmp._begin < strend) and (tmp._begin^ <> '>') do Inc(tmp._begin);

    if tmp._begin >= strend then Break;

    Inc(tmp._begin);

    elem._begin := P1;
    elem._end := tmp._begin;

    if PropName.IsEmpty then
    begin
      Result._begin := P1;
      // Result._end := tmp._begin;
      elemend := FindEndTagA(tmp._begin - 1, tmp._end);

      if elemend = nil then Result._end := tmp._end
      else Result._end := elemend;

      Break;
    end
    else begin
      value := HtmlElementGetPropValue(elem, PropName);
      if value.compare(PropValue) = 0 then
      begin
        Result._begin := P1;
        //Result._end := tmp._begin;
        elemend := FindEndTagA(tmp._begin - 1, tmp._end);

        if elemend = nil then Result._end := tmp._end
        else Result._end := elemend;
        Break;
      end
      else
        Continue;
    end;
  end;
end;

function HtmlElementFind(const html: TAnsiCharSection; const TagName,
  PropName, PropValue: RawByteString): TAnsiCharSection;
begin
  Result := HtmlElementFind(html, TAnsiCharSection.Create(TagName),
    TAnsiCharSection.Create(PropName),
    TAnsiCharSection.Create(PropValue));
end;

function HtmlGetPropByProp(const html, TagName, SearchPropName, SearchPropValue, PropName: RawByteString;
  first, last: Integer): RawByteString;
var
  elem, PropValue: TAnsiCharSection;
begin
  elem := HtmlElementFind(TAnsiCharSection.Create(html, first, last), TAnsiCharSection.Create(TagName),
    TAnsiCharSection.Create(SearchPropName), TAnsiCharSection.Create(SearchPropValue));

  if not elem.IsValid then Result := ''
  else begin
    PropValue := HtmlElementGetPropValue(elem, TAnsiCharSection.Create(PropName));
    Result := PropValue.ToString;
  end;
end;

function HtmlGetPropByProp(const html, TagName, SearchPropName, SearchPropValue, PropName: TAnsiCharSection): TAnsiCharSection;
var
  elem: TAnsiCharSection;
begin
  elem := HtmlElementFind(html, TagName, SearchPropName, SearchPropValue);

  if not elem.IsValid then
    Result.SetInvalid
  else
    Result := HtmlElementGetPropValue(elem, PropName);
end;


function FindEndTagW(first, last: PWideChar): PWideChar;
var
  p: PWideChar;
  n: Integer;
begin
  n := 1;
  p := first;
  Result := nil;

  while p < last do
  begin
    if p^ = '<' then
    begin
      Inc(p);

      if p >= last then Exit;

      if p^ = '/' then
      begin
        Dec(n);

        if n = 0 then
        begin
          while (p<last) and (p^<>'>') do Inc(p);
          if p < last then Result := p + 1;
          Exit;
        end;
      end
      else
        Inc(n);
    end
    else if p^ = '>' then
    begin
      if (p-1)^ = '/' then
      begin
        Dec(n);

        if n = 0 then
        begin
          Result := p + 1;
          Exit;
        end;
      end;

      Inc(p);
    end
    else Inc(p);
  end;
end;

function HtmlElementGetPropValue(const html, PropName: TWideCharSection): TWideCharSection;
var
  P3, P4: PWideChar;
  c: WideChar;
  tmp: TWideCharSection;
begin
  Result.SetInvalid;

  tmp._begin := html._begin;
  tmp._end := html._end;

  while tmp.length > 0 do
  begin
    P3 := tmp.ipos(PropName);
    if P3 = nil then Break;
    P4 := P3;
    Inc(P3, PropName.length);
    if P3 >= tmp._end then Break;
    
    if (P4 > html._begin) and ((P4-1)^ > #32) then
    begin
      if ((P4-1)^ <> #39) and ((P4-1)^ <> '"') then
      begin
        tmp._begin := P3;
        Continue;
      end
      else if (P4-1)^ <> P3^ then
      begin
        tmp._begin := P3;
        Continue;
      end
      else Inc(P3);
    end;

    while (P3 < tmp._end) and (P3^ <= #32) do Inc(P3);
    if P3 = tmp._end then Break;
    if P3^ <> '=' then
    begin
      tmp._begin := P3;
      Continue;
    end;

    Inc(P3);

    while (P3 < tmp._end) and (P3^ <= #32) do Inc(P3);

    if P3 >= tmp._end then Break;

    if (P3^ <> #39) and (P3^ <> '"') then
    begin
      P4 := P3 + 1;
      while (P4 < tmp._end) and (P4^ > #32) and (P4^ <> '>') do Inc(P4);
      // if P4 >= tmp._end then Break;
      Result._begin := P3;
      Result._end := P4;
      Break;
    end
    else begin
      c := P3^;
      Inc(P3);
      P4 := P3;
      while (P4 < tmp._end) and (P4^ <> c) and (P4^ <> '>') do Inc(P4);

      if P4 >= tmp._end then Break
      else if P4^ <> c then
      begin
        tmp._begin := P4;
        Continue;
      end
      else begin
        Result._begin := P3;
        Result._end := P4;
        Break;
      end;
    end;
  end;
end;

function HtmlElementFind(const html, TagName, PropName, PropValue: TWideCharSection): TWideCharSection;
var
  P1, strend, elemend: PWideChar;
  _BeginTag: array [0..63] of WideChar;
  i: Integer;
  tmp, BeginTag, elem, value: TWideCharSection;
begin
  Result.SetInvalid;

  _BeginTag[0] := '<';

  for i := 0 to TagName.length - 1 do
    _BeginTag[i + 1] := TagName._begin[i];

  BeginTag._begin := _BeginTag;
  BeginTag._end := @_BeginTag[TagName.length + 1];
  tmp._begin := html._begin;
  tmp._end := html._end;
  strend := html._end;

  while tmp.length > 0 do
  begin
    P1 := tmp.ipos(BeginTag);
    if P1 = nil then Break;
    tmp._begin := P1 + BeginTag.length;

    if (tmp._begin >= strend) then Break;
    if (tmp._begin^ > #32) then Continue;

    Inc(tmp._begin);

    while (tmp._begin < strend) and (tmp._begin^ <> '>') do Inc(tmp._begin);

    if tmp._begin = strend then Break;

    elem._begin := P1;
    elem._end := tmp._begin + 1;

    if not PropName.IsEmpty then
    begin
      value := HtmlElementGetPropValue(elem, PropName);
      if value.compare(PropValue) <> 0 then Continue;
    end;

    Result._begin := P1;
    elemend := FindEndTagW(tmp._begin, tmp._end);
    if elemend = nil then Result._end := strend
    else Result._end := elemend;
    Break;
  end;
end;

function HtmlElementFind(const html: TWideCharSection; const TagName, PropName, PropValue: u16string): TWideCharSection;
begin
  Result := HtmlElementFind(html, TWideCharSection.Create(TagName),
    TWideCharSection.Create(PropName), TWideCharSection.Create(PropValue));
end;

function UStrHtmlGetPropByProp(const html, TagName, SearchPropName, SearchPropValue, PropName: u16string;
  first, last: Integer): u16string;
var
  elem, PropValue: TWideCharSection;
begin
  elem := HtmlElementFind(TWideCharSection.Create(html, first, last), TWideCharSection.Create(TagName),
    TWideCharSection.Create(SearchPropName), TWideCharSection.Create(SearchPropValue));

  if not elem.IsValid then Result := ''
  else begin
    PropValue := HtmlElementGetPropValue(elem, TWideCharSection.Create(PropName));
    Result := PropValue.ToUStr;
  end;
end;

function HtmlGetPropByProp(const html: TWideCharSection; const TagName, SearchPropName, SearchPropValue,
  PropName: u16string): TWideCharSection;
var
  elem: TWideCharSection;
begin
  elem := HtmlElementFind(html, TagName, SearchPropName,SearchPropValue);

  if not elem.IsValid then
    Result.SetInvalid
  else
    Result := HtmlElementGetPropValue(elem, TWideCharSection.Create(PropName));
end;

function HtmlGetInnerTextLengthW(first, last: PWideChar): Integer;
var
  p: PWideChar;
  IsText: Boolean;
begin
  p := first;
  Result := 0;
  IsText := True;

  while p < last do
  begin
    if p^ = '<' then IsText := False
    else if p^ = '>' then IsText := True
    else if IsText and (p^ > #32) then Inc(Result);
    Inc(p);
  end;
end;

function HtmlGetInnerTextW(first, last, buf: PWideChar): Integer;
var
  p: PWideChar;
  IsText: Boolean;
begin
  p := first;
  Result := 0;
  IsText := True;

  while p < last do
  begin
    if p^ = '<' then IsText := False
    else if p^ = '>' then IsText := True
    else if IsText and (p^ > #32) then
    begin
      buf^ := p^;
      Inc(buf);
      Inc(Result);
    end;

    Inc(p);
  end;
end;

function _UStrHtmlGetInnerText(first, last: PWideChar): u16string;
var
  L: Integer;
begin
  L := HtmlGetInnerTextLengthW(first, last);
  SetLength(Result, L);
  HtmlGetInnerTextW(first, last, PWideChar(Result));
end;

function _UStrHtmlGetInnerText2(s: u16string): u16string;
var
  L: Integer;
begin
  L := HtmlGetInnerTextLengthW(PWideChar(s), PWideChar(s) + Length(s));
  SetLength(Result, L);
  HtmlGetInnerTextW(PWideChar(s), PWideChar(s) + Length(s), PWideChar(Result));
end;

function HtmlElementGetInnerText(const elem: TWideCharSection): u16string;
var
  L: Integer;
begin
  L := HtmlGetInnerTextLengthW(elem._begin, elem._end);
  SetLength(Result, L);
  HtmlGetInnerTextW(elem._begin, elem._end, PWideChar(Result));
end;

function HtmlElementGetInnerHtml(const elem: TWideCharSection): TWideCharSection;
var
  P1, P2: PWideChar;
begin
  if elem.length = 0 then Result.SetEmpty
  else begin
    P1 := elem._begin;
    while (P1 < elem._end) and (P1^ <> '>') do Inc(P1);

    if P1 >= elem._end - 1 then Result.SetEmpty
    else begin
      Inc(P1);
      P2 := elem._end - 1;
      while (P2 > P1) and (P2^ <> '<') do Dec(P2);
      Result._begin := P1;
      Result._end := P2;
    end;
  end;
end;

function HtmlFindInnerHtml(const html: TWideCharSection; const TagName, SearchPropName,
  SearchPropValue: u16string): TWideCharSection;
begin
  if html.length > 0 then
    Result := HtmlElementGetInnerHtml(HtmlElementFind(html, TWideCharSection.Create(TagName),
      TWideCharSection.Create(SearchPropName),
      TWideCharSection.Create(SearchPropValue)))
  else
    Result.SetInvalid;
end;

function UStrGetInnerHtml(const html, TagName, SearchPropName, SearchPropValue: u16string;
  const EndTag: u16string; first, last: Integer): u16string;
var
  htmlsec: TWideCharSection;
begin
  htmlsec.SetUStr(html, first, last);

  if htmlsec.length > 0 then
    Result := HtmlElementGetInnerHtml(HtmlElementFind(htmlsec, TWideCharSection.Create(TagName),
      TWideCharSection.Create(SearchPropName),
      TWideCharSection.Create(SearchPropValue))).ToUStr
  else
    Result := '';
end;

function UStrHtmlGetInnerText(const html, TagName, SearchPropName, SearchPropValue: u16string;
  const EndTag: u16string; first, last: Integer): u16string;
var
  htmlsec, elem: TWideCharSection;
begin
  htmlsec.SetUStr(html, first, last);

  if htmlsec.length > 0 then
  begin
    elem := HtmlElementFind(htmlsec, TWideCharSection.Create(TagName),
      TWideCharSection.Create(SearchPropName),
      TWideCharSection.Create(SearchPropValue));

    if elem.IsEmpty then Result := ''
    else Result := _UStrHtmlGetInnerText(elem._begin, elem._end);
  end
  else Result := ''
end;

procedure GetHtmlAnchors(const html: u16string; const SuffixList: array of u16string; AnchorList: TUnicodeStrings);
var
  i, P, P1, P2, tmp, urlLen, L: Integer;
  url: u16string;
begin
  L := Length(html);
  
  P := 1;

  while P < L do
  begin
    if not UStrGetSectionBetween2(html, '"http://', ['"'], P1, P2, P, L) then Break;

    Dec(P1, 7);

    url := Copy(html, P1, P2 - P1);

    if AnchorList.IndexOf(url) = -1 then
    begin
      tmp := 1;
      urlLen := Length(url);

      while (tmp <= urlLen) and (url[tmp] <> '?') do Inc(tmp);

      for i := Low(SuffixList) to High(SuffixList) do
      begin
        if EndWithW(PWideChar(url), tmp - 1, SuffixList[i]) then
        begin
          AnchorList.Add(url);
          Break;
        end;
      end;
    end;

    P := P2 + 1;
  end;

  P := 1;

  while P < L do
  begin
    if not UStrGetSectionBetween2(html, '"https://', ['"'], P1, P2, P, L) then Break;

    Dec(P1, 8);

    url := Copy(html, P1, P2 - P1);

    if AnchorList.IndexOf(url) = -1 then
    begin
      tmp := 1;
      urlLen := Length(url);

      while (tmp <= urlLen) and (url[tmp] <> '?') do Inc(tmp);

      for i := Low(SuffixList) to High(SuffixList) do
      begin
        if EndWithW(PWideChar(url), tmp - 1, SuffixList[i]) then
        begin
          AnchorList.Add(url);
          Break;
        end;
      end;
    end;

    P := P2 + 1;
  end;
end;

function FindElement(inputs: THtmlInputs; const name: TWideCharSection): THtmlInput;
var
  i: Integer;
  tmp: THtmlInput;
begin
  Result := nil;

  for i := 0 to inputs.Count - 1 do
  begin
    tmp := THtmlInput(inputs[i]);

    if StrCompareW(PWideChar(tmp.name), Length(tmp.name), name._begin, name.length, False) = 0 then
    begin
      Result := tmp;
      Break;
    end;
  end;
end;

procedure ParseHtmlForm(const formsec: TWideCharSection; inputs: THtmlInputs);
const
  SInputBeginTag: u16string = '<input';
  STextAreaBeginTag: u16string = '<textarea';
  SOptionsBeginTag: u16string = '<select';
var
  pFormEnd, P1, P2: PWideChar;
  element: THtmlInput;
  elem, namesec, valuesec, typesec: TWideCharSection;
begin
  P1 := formsec._begin;
  pFormEnd := formsec._end;

  while P1 < pFormEnd do
  begin
    P1 := StrIPosW(PWideChar(SInputBeginTag), Length(SInputBeginTag), P1, pFormEnd - P1);

    if P1 = nil then Break;

    Inc(P1, Length(SInputBeginTag));

    P2 := P1;

    while (P2 < pFormEnd) and (P2^ <> '>') do Inc(P2);

    if P2 >= pFormEnd then Break;

    Inc(P2);

    elem._begin := P1;
    elem._end := P2;

    namesec := HtmlElementGetPropValue(elem, TWideCharSection.Create('name'));

    if namesec.length > 0 then
    begin
      valuesec := HtmlElementGetPropValue(elem, TWideCharSection.Create('value'));

      if Assigned(FindElement(inputs, namesec)) then
      begin
        typesec := HtmlElementGetPropValue(elem, TWideCharSection.Create('type'));

        if typesec.compare('radio') <> 0 then
        begin
          element := THtmlInput.Create;
          namesec.trim;
          element.name := HTMLDecodeBufW(namesec._begin, namesec.length);
          valuesec.trim;
          element.value := HTMLDecodeBufW(valuesec._begin, valuesec.length);
          inputs.Add(element);
        end;
      end
      else begin
        element := THtmlInput.Create;
        namesec.trim;
        element.name := HTMLDecodeBufW(namesec._begin, namesec.length);
        valuesec.trim;
        element.value := HTMLDecodeBufW(valuesec._begin, valuesec.length);
        inputs.Add(element);
      end;
    end;

    P1 := P2;
  end;

  P1 := formsec._begin;

  while P1 < pFormEnd do
  begin
    P1 := StrIPosW(PWideChar(STextAreaBeginTag), Length(STextAreaBeginTag), P1, pFormEnd - P1);

    if P1 = nil then Break;

    Inc(P1, Length(STextAreaBeginTag));

    P2 := P1;

    while (P2 < pFormEnd) and (P2^ <> '>') do Inc(P2);

    if P2 >= pFormEnd then Break;

    Inc(P2);

    elem._begin := P1;
    elem._end := P2;

    namesec := HtmlElementGetPropValue(elem, TWideCharSection.Create('name'));

    if namesec.length > 0 then
    begin
      valuesec := HtmlElementGetPropValue(elem, TWideCharSection.Create('value'));

      if not Assigned(FindElement(inputs, namesec)) then
      begin
        element := THtmlInput.Create;
        namesec.trim;
        element.name := HTMLDecodeBufW(namesec._begin, namesec.length);
        valuesec.trim;
        element.value := HTMLDecodeBufW(valuesec._begin, valuesec.length);
        inputs.Add(element);
      end;
    end;

    P1 := P2;
  end;

  P1 := formsec._begin;

  while P1 < pFormEnd do
  begin
    P1 := StrIPosW(PWideChar(SOptionsBeginTag), Length(SOptionsBeginTag), P1, pFormEnd - P1);

    if P1 = nil then Break;

    Inc(P1, Length(SOptionsBeginTag));

    P2 := P1;

    while (P2 < pFormEnd) and (P2^ <> '>') do Inc(P2);

    if P2 >= pFormEnd then Break;

    Inc(P2);

    elem._begin := P1;
    elem._end := P2;

    namesec := HtmlElementGetPropValue(elem, TWideCharSection.Create('name'));

    if namesec.length > 0 then
    begin
      if not Assigned(FindElement(inputs, namesec)) then
      begin
        element := THtmlInput.Create;
        namesec.trim;
        element.name := HTMLDecodeBufW(namesec._begin, namesec.length);
        inputs.Add(element);
      end;
    end;

    P1 := P2;
  end;
end;

function GetHtmlFormW(const htmlsec: TWideCharSection; const PropName, PropValue: u16string;
  inputs: THtmlInputs): TWideCharSection;
const
  SFormEndTag: u16string = '</form>';
  SInputBeginTag: u16string = '<input';
  STextAreaBeginTag: u16string = '<textarea';
  SOptionsBeginTag: u16string = '<select';
var
  pFormStart, pFormEnd: PWideChar;
begin
  Result := HtmlElementFind(htmlsec, TWideCharSection.Create('form'),
    TWideCharSection.Create(PropName), TWideCharSection.Create(PropValue));

  if Result.length > 0 then
  begin
    pFormStart := Result._begin;
    Inc(pFormStart, 6);
    while (pFormStart^ <> #0) and (pFormStart^ <> '>') do Inc(pFormStart);

    if pFormStart^ = #0 then Result.SetEmpty
    else begin
      Inc(pFormStart);
      pFormEnd := StrIPosW(PWideChar(SFormEndTag), Length(SFormEndTag), pFormStart, htmlsec._end - pFormStart);

      if pFormEnd = nil then
        pFormEnd := htmlsec._end;

      Result._end := pFormEnd;

      if Assigned(inputs) then
        ParseHtmlForm(Result, inputs);
    end;
  end;
end;

function UStrGetHtmlForm(const html, PropName, PropValue: u16string; inputs: THtmlInputs): Boolean;
begin
  Result := GetHtmlFormW(TWideCharSection.Create(html), PropName, PropValue, inputs).length > 0;
end;

function HtmlGetFormsW(const htmlsec: TWideCharSection; const PropName, PropValue: u16string): THtmlForms;
var
  vhtmlsec, formsec: TWideCharSection;
  form: THtmlForm;
  ok: Boolean;
begin
  Result := nil;
  ok := False;
  vhtmlsec := htmlsec;

  try
    while vhtmlsec.length > 0 do
    begin
      formsec := GetHtmlFormW(vhtmlsec, PropName, PropValue, nil);

      if formsec.length > 0 then
      begin
        if not Assigned(Result) then
          Result := THtmlForms.Create;

        form := THtmlForm.Create;
        form.name := HtmlElementGetPropValue(formsec, TWideCharSection.Create('name')).ToUStr;
        form.id := HtmlElementGetPropValue(formsec, TWideCharSection.Create('id')).ToUStr;
        form.method := HtmlElementGetPropValue(formsec, TWideCharSection.Create('method')).ToUStr;
        form.action := HtmlElementGetPropValue(formsec, TWideCharSection.Create('action')).ToUStr;
        Result.Add(form);
        ParseHtmlForm(formsec, form.inputs);
        vhtmlsec._begin := formsec._end;
      end
      else
        Break;
    end;

    ok := True;
  finally
    if not ok then
      FreeAndNil(Result);
  end;
end;

function HtmlGetForms(const html, PropName, PropValue: u16string): THtmlForms;
begin
  Result := HtmlGetFormsW(TWideCharSection.Create(html), PropName, PropValue);
end;

type
  TNameValueSeparator = set of (
    nvsColon,       // :
    nvsEqualSign    // =
  );

  TPairSeparator = set of (
    psSemicolon,        // ;
    psRightBrace,       // }
    psAmp,               // &
    psComma,            // ,
    psBlank,            // #0..#32
    psGreatThen,         // >
    psQuote,            // '
    psDoubleQuote       // "
  );

function GetVariableValue(const str: TWideCharSection; const name: u16string): TWideCharSection;
var
  P1, P2, p, pName: PWideChar;
  L: Integer;
  subs, s: TWideCharSection;
  fValid, optionalQuoter: Boolean;
  nvs: TNameValueSeparator;
  ps: TPairSeparator;
  quoter: WideChar;

  function isNameValueSeparator(ch: WideChar): Boolean;
  begin
    case ch of
      '=': Result := nvsEqualSign in nvs;
      ':': Result := nvsColon in nvs;
      else Result := False;
    end;
  end;

  function isValueEnd(ch: WideChar): Boolean;
  begin
    case ch of
      ';': Result := psSemicolon in ps;
      '}': Result := psRightBrace in ps;
      '&': Result := psAmp in ps;
      ',': Result := psComma in ps;
      #0..#32: Result := psBlank in ps;
      '>': Result := psGreatThen in ps;
      #39: Result := psQuote in ps;
      '"': Result := psDoubleQuote in ps;
      else Result := False;
    end;
  end;
begin
  Result.SetInvalid;
  subs.SetUStr(name);
  s._begin := str._begin;
  s._end := str._end;
  L := Length(name);

  while s.length > 0 do
  begin
    P1 := s.ipos(subs);
    if P1=nil then Break;
    pName := P1;
    fValid := True;
    optionalQuoter := False;
    nvs := [nvsColon, nvsEqualSign];
    ps := [psSemicolon, psRightBrace, psAmp, psComma];
    p:=p1-1;
    quoter := #0;
    if (p>=s._begin) and ((p^='"') or (p^=#39)) then
    begin
      pName := p;
      quoter := p^;
      Dec(p);
    end;

    while (p>=s._begin) and (p^<=#32) do Dec(p);
    if p>=s._begin then
    begin
      case p^ of
        '=':
          begin
            ps := [psSemicolon, psAmp, psComma];
            if p=pName-1 then
            begin
              // = is just before name
              if quoter = #0 then fValid := False
              else begin
                // =[$1="|']name[=|:]value[&|;|,|$1]
                quoter:=#0;
                if p^ = #39 then Include(ps, psQuote)
                else Include(ps, psDoubleQuote);
              end;
            end
            else optionalQuoter := True;
          end;

        // [$1=&|;]name[=|:]value[$1|"|']
        '&': ps := [psAmp, psQuote, psDoubleQuote];
        ';': ps := [psSemicolon, psQuote, psDoubleQuote];

        // [{|,]name[=|:]value[}|,]
        '{', ',': ps := [psRightBrace, psComma];

        else if p<pName-1 then ps := [psBlank, psGreatThen]
        else fValid := False;
      end;
    end;

    Inc(P1, L);

    if not fValid then
    begin
      s._begin := P1;
      Continue;
    end;
    
    while (P1<s._end) and (P1^<=#32) do Inc(P1);
    if P1 >= s._end then Break;

    if quoter <> #0 then
    begin
      if quoter <> P1^ then
      begin
        if optionalQuoter then
        begin
          if quoter = #39 then Include(ps, psQuote)
          else Include(ps, psDoubleQuote);
        end
        else begin
          s._begin := P1;
          Continue;
        end;
      end
      else begin
        Inc(P1); // skip name-close-quote
        while (P1<s._end) and (P1^<=#32) do Inc(P1);
        if P1 >= s._end then Break;
      end;
    end;

    if not isNameValueSeparator(P1^) then
    begin
      s._begin := P1;
      Continue;
    end;
    Inc(P1); // skip NameValueSeparator

    if not (psBlank in ps) then
      while (P1 < s._end) and (P1^ <= #32) do Inc(P1);

    if (P1 >= s._end) or (isValueEnd(P1^)) then
    begin
      Result.SetEmpty;
      Break;
    end;

    if (P1^=#39) or (P1^='"') then
    begin
      quoter := P1^;
      Inc(P1);
      P2 := P1;
      while (P2<s._end) and (P2^<>quoter) do
      begin
        case P2^ of
          '\': Inc(P2, 2);
          else Inc(P2);
        end;
      end;
      if P2 > s._end then
        P2 := s._end;
    end
    else begin
      P2 := P1;
      while (P2<s._end) and not isValueEnd(P2^) do Inc(P2);
    end;

    Result._begin := P1;
    Result._end := P2;
    Break;
  end;
end;

function GetVariableValue(const str, name: u16string): TWideCharSection; overload;
var
  sec: TWideCharSection;
begin
  sec.SetUStr(str);
  Result := GetVariableValue(sec, name);
end;

function GetVariableValue(const str: TAnsiCharSection; const name: RawByteString): TAnsiCharSection;
var
  P1, P2, p, pName: PAnsiChar;
  L: Integer;
  subs, s: TAnsiCharSection;
  fValid, optionalQuoter: Boolean;
  nvs: TNameValueSeparator;
  ps: TPairSeparator;
  quoter: AnsiChar;

  function isNameValueSeparator(ch: AnsiChar): Boolean;
  begin
    case ch of
      '=': Result := nvsEqualSign in nvs;
      ':': Result := nvsColon in nvs;
      else Result := False;
    end;
  end;

  function isValueEnd(ch: AnsiChar): Boolean;
  begin
    case ch of
      ';': Result := psSemicolon in ps;
      '}': Result := psRightBrace in ps;
      '&': Result := psAmp in ps;
      ',': Result := psComma in ps;
      #0..#32: Result := psBlank in ps;
      '>': Result := psGreatThen in ps;
      #39: Result := psQuote in ps;
      '"': Result := psDoubleQuote in ps;
      else Result := False;
    end;
  end;
begin
  Result.SetInvalid;
  subs.SetStr(name);
  s._begin := str._begin;
  s._end := str._end;
  L := Length(name);

  while s.length > 0 do
  begin
    P1 := s.ipos(subs);
    if P1=nil then Break;
    pName := P1;
    fValid := True;
    optionalQuoter := False;
    nvs := [nvsColon, nvsEqualSign];
    ps := [psSemicolon, psRightBrace, psAmp, psComma];
    p:=p1-1;
    quoter := #0;
    if (p>=s._begin) and ((p^='"') or (p^=#39)) then
    begin
      pName := p;
      quoter := p^;
      Dec(p);
    end;

    while (p>=s._begin) and (p^<=#32) do Dec(p);
    if p>=s._begin then
    begin
      case p^ of
        '=':
          begin
            ps := [psSemicolon, psAmp, psComma];
            if p=pName-1 then
            begin
              // = is just before name
              if quoter = #0 then fValid := False
              else begin
                // =[$1="|']name[=|:]value[&|;|,|$1]
                quoter:=#0;
                if p^ = #39 then Include(ps, psQuote)
                else Include(ps, psDoubleQuote);
              end;
            end
            else optionalQuoter := True;
          end;

        // [$1=&|;]name[=|:]value[$1|"|']
        '&': ps := [psAmp, psQuote, psDoubleQuote];
        ';': ps := [psSemicolon, psQuote, psDoubleQuote];

        // [{|,]name[=|:]value[}|,]
        '{', ',': ps := [psRightBrace, psComma];

        else if p<pName-1 then ps := [psBlank, psGreatThen]
        else fValid := False;
      end;
    end;

    Inc(P1, L);

    if not fValid then
    begin
      s._begin := P1;
      Continue;
    end;

    while (P1<s._end) and (P1^<=#32) do Inc(P1);
    if P1 >= s._end then Break;

    if quoter <> #0 then
    begin
      if quoter <> P1^ then
      begin
        if optionalQuoter then
        begin
          if quoter = #39 then Include(ps, psQuote)
          else Include(ps, psDoubleQuote);
        end
        else begin
          s._begin := P1;
          Continue;
        end;
      end
      else begin
        Inc(P1); // skip name-close-quote
        while (P1<s._end) and (P1^<=#32) do Inc(P1);
        if P1 >= s._end then Break;
      end;
    end;

    if not isNameValueSeparator(P1^) then
    begin
      s._begin := P1;
      Continue;
    end;
    Inc(P1); // skip NameValueSeparator

    if not (psBlank in ps) then
      while (P1 < s._end) and (P1^ <= #32) do Inc(P1);

    if (P1 >= s._end) or (isValueEnd(P1^)) then
    begin
      Result.SetEmpty;
      Break;
    end;

    if (P1^=#39) or (P1^='"') then
    begin
      quoter := P1^;
      Inc(P1);
      P2 := P1;
      while (P2<s._end) and (P2^<>quoter) do
      begin
        case P2^ of
          '\': Inc(P2, 2);
          else Inc(P2);
        end;
      end;
      if P2 > s._end then
        P2 := s._end;
    end
    else begin
      P2 := P1;
      while (P2<s._end) and not isValueEnd(P2^) do Inc(P2);
    end;

    Result._begin := P1;
    Result._end := P2;
    Break;
  end;
end;

function GetVariableValue(const str: RawByteString; const name: RawByteString): TAnsiCharSection; overload;
var
  sec: TAnsiCharSection;
begin
  sec.SetStr(str);
  Result := GetVariableValue(sec, name);
end;

procedure TestHtmlForm;
var
  s: u16string;
  inputs: THtmlInputs;
  i: Integer;
begin
  //ShowMessage(HtmlElementGetPropValue(TWideCharSection.Create('<a "name="111"><a "name''="222"><a "name"="333">'), TWideCharSection.Create('name')).ToUStr);
  //ShowMessage(UStrHtmlGetPropByProp('<a "name="111"><a "name''="222"><a "name"="333" value="123">',
    //'a', 'name', '333', 'value'));
  (*ShowMessage(HtmlElementGetInnerHtml(HtmlElementFind(TWideCharSection.Create(
    '<div id="abc"><a "name="111"><a "name''="222"><a "name"="333" value="123" href="http://www.baidu.com">百度</a>'
      + '</div>'),
    'div', 'id', 'abc')).ToUStr);*)
  s := string(LoadStrFromFile('D:\workspace\淘宝封包研究\淘宝登录\login.htm'));

  inputs := THtmlInputs.Create;

  try
    if UStrGetHtmlForm(s, 'id', 'J_StaticForm', inputs) then
      for i := 0 to inputs.Count - 1 do
        ShowMessage(inputs[i].name + '=' + inputs[i].value);
  finally
    inputs.Free;
  end;
end;

{ THtmlInputs }

function THtmlInputs.exists(const name: u16string): Boolean;
begin
  Result := Self.IndexOf(name) >= 0;
end;

function THtmlInputs.GetS(const name: u16string): u16string;
var
  idx: Integer;
begin
  idx := Self.IndexOf(name);

  if idx >= 0 then
    Result := THtmlInput(Self.Items[idx]).value
  else
    Result := '';
end;

function THtmlInputs.IndexOf(const name: u16string): Integer;
var
  i: Integer;
  input: THtmlInput;
begin
  Result := -1;

  for i := 0 to Self.Count - 1 do
  begin
    input := THtmlInput(Self.Items[i]);

    if UStrSameText(input.name, name) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function THtmlInputs.MakeForm(CodePage: Integer): RawByteString;
var
  i: Integer;
  input: THtmlInput;
  param: RawByteString;
begin
  param := '';

  for i := 0 to Self.Count - 1 do
  begin
    input := THtmlInput(Self.Items[i]);
    HttpParamAppend(param, UStrToMultiByte(input.name, CodePage), UStrToMultiByte(input.value, CodePage))
  end;

  Result := param;
end;

procedure THtmlInputs.remove(const name: u16string);
var
  idx: Integer;
begin
  idx := Self.IndexOf(name);

  if idx >= 0 then
    Self.Delete(idx);
end;

procedure THtmlInputs.SetS(const name, Value: u16string);
var
  idx: Integer;
begin
  idx := Self.IndexOf(name);

  if idx >= 0 then
    THtmlInput(Self.Items[idx]).value := Value;
end;

{ THtmlForm }

constructor THtmlForm.Create;
begin
  FInputs := THtmlInputs.Create;
end;

destructor THtmlForm.Destroy;
begin
  FInputs.Free;
end;

procedure unit_test;
var
  html: u16string;
  forms: THtmlForms;
  form: THtmlForm;
  i, j: Integer;
begin
  html := WinAPI_UTF8Decode(LoadStrFromFile('D:\workspace\淘宝封包研究\android手机抓包\IE登录\login_check.htm'));
  forms := HtmlGetForms(html, '', '');

  if Assigned(forms) then
    try
      for i := 0 to forms.Count - 1 do
      begin
        form := forms[i];
        DbgOutput(form.name + ', ' + form.method + ', ' + form.action);
        for j := 0 to form.inputs.Count - 1 do
          DbgOutput(form.inputs[j].name + '=' + form.inputs[j].value);
      end;
    finally
      forms.Free;
    end;
end;

initialization
  //unit_test;

end.