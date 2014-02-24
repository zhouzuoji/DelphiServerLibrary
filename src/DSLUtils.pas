unit DSLUtils;

interface

uses
  SysUtils, Classes, AnsiStrings, Windows, ShellAPI, StrUtils, DateUtils, Controls, RTLConsts,
  Dialogs, Forms, Graphics, ComCtrls, CommCtrl, ComObj, ShlObj, ActiveX, SyncObjs;

type

{$ifndef UNICODE}
  UnicodeString = WideString;
  RawByteString = AnsiString;
{$endif}

  DSLPointerCompareProc = function(first, second: Pointer): Integer;
  DSLPointerProc = procedure(first, second: Pointer);

  DSLCodePageInfo = record
    Name: AnsiString;
    ID: integer;
  end;
  PCodePage = ^DSLCodePageInfo;

const
  NAME_SORTED_CODE_PAGES: array[0..143] of DSLCodePageInfo =
  (
    (Name: 'IBM037'; ID: 37),
    (Name: 'IBM437'; ID: 437),
    (Name: 'IBM500'; ID: 500),
    (Name: 'ASMO-708'; ID: 708),
    (Name: 'ASMO-449+'; ID: 709),
    (Name: 'BCON V4'; ID: 709),
    (Name: 'Arabic'; ID: 710),
    (Name: 'DOS-720'; ID: 720),
    (Name: 'ibm737'; ID: 737),
    (Name: 'ibm775'; ID: 775),
    (Name: 'ibm850'; ID: 850),
    (Name: 'ibm852'; ID: 852),
    (Name: 'IBM855'; ID: 855),
    (Name: 'ibm857'; ID: 857),
    (Name: 'IBM00858'; ID: 858),
    (Name: 'IBM860'; ID: 860),
    (Name: 'ibm861'; ID: 861),
    (Name: 'DOS-862'; ID: 862),
    (Name: 'IBM863'; ID: 863),
    (Name: 'IBM864'; ID: 864),
    (Name: 'IBM865'; ID: 865),
    (Name: 'cp866'; ID: 866),
    (Name: 'ibm869'; ID: 869),
    (Name: 'IBM870'; ID: 870),
    (Name: 'windows-874'; ID: 874),
    (Name: 'cp875'; ID: 875),
    (Name: 'shift_jis'; ID: 932),
    (Name: 'gb2312'; ID: 936),
    (Name: 'GBK'; ID: 936),
    (Name: 'ks_c_5601-1987'; ID: 949),
    (Name: 'big5'; ID: 950),
    (Name: 'IBM1026'; ID: 1026),
    (Name: 'IBM01047'; ID: 1047),
    (Name: 'IBM01140'; ID: 1140),
    (Name: 'IBM01141'; ID: 1141),
    (Name: 'IBM01142'; ID: 1142),
    (Name: 'IBM01143'; ID: 1143),
    (Name: 'IBM01144'; ID: 1144),
    (Name: 'IBM01145'; ID: 1145),
    (Name: 'IBM01146'; ID: 1146),
    (Name: 'IBM01147'; ID: 1147),
    (Name: 'IBM01148'; ID: 1148),
    (Name: 'IBM01149'; ID: 1149),
    (Name: 'utf-16'; ID: 1200),
    (Name: 'unicodeFFFE'; ID: 1201),
    (Name: 'windows-1250'; ID: 1250),
    (Name: 'windows-1251'; ID: 1251),
    (Name: 'windows-1252'; ID: 1252),
    (Name: 'windows-1253'; ID: 1253),
    (Name: 'windows-1254'; ID: 1254),
    (Name: 'windows-1255'; ID: 1255),
    (Name: 'windows-1256'; ID: 1256),
    (Name: 'windows-1257'; ID: 1257),
    (Name: 'windows-1258'; ID: 1258),
    (Name: 'Johab'; ID: 1361),
    (Name: 'macintosh'; ID: 10000),
    (Name: 'x-mac-japanese'; ID: 10001),
    (Name: 'x-mac-chinesetrad'; ID: 10002),
    (Name: 'x-mac-korean'; ID: 10003),
    (Name: 'x-mac-arabic'; ID: 10004),
    (Name: 'x-mac-hebrew'; ID: 10005),
    (Name: 'x-mac-greek'; ID: 10006),
    (Name: 'x-mac-cyrillic'; ID: 10007),
    (Name: 'x-mac-chinesesimp'; ID: 10008),
    (Name: 'x-mac-romanian'; ID: 10010),
    (Name: 'x-mac-ukrainian'; ID: 10017),
    (Name: 'x-mac-thai'; ID: 10021),
    (Name: 'x-mac-ce'; ID: 10029),
    (Name: 'x-mac-icelandic'; ID: 10079),
    (Name: 'x-mac-turkish'; ID: 10081),
    (Name: 'x-mac-croatian'; ID: 10082),
    (Name: 'utf-32'; ID: 12000),
    (Name: 'utf-32BE'; ID: 12001),
    (Name: 'x-Chinese_CNS'; ID: 20000),
    (Name: 'x-cp20001'; ID: 20001),
    (Name: 'x_Chinese-Eten'; ID: 20002),
    (Name: 'x-cp20003'; ID: 20003),
    (Name: 'x-cp20004'; ID: 20004),
    (Name: 'x-cp20005'; ID: 20005),
    (Name: 'x-IA5'; ID: 20105),
    (Name: 'x-IA5-German'; ID: 20106),
    (Name: 'x-IA5-Swedish'; ID: 20107),
    (Name: 'x-IA5-Norwegian'; ID: 20108),
    (Name: 'us-ascii'; ID: 20127),
    (Name: 'x-cp20261'; ID: 20261),
    (Name: 'x-cp20269'; ID: 20269),
    (Name: 'IBM273'; ID: 20273),
    (Name: 'IBM277'; ID: 20277),
    (Name: 'IBM278'; ID: 20278),
    (Name: 'IBM280'; ID: 20280),
    (Name: 'IBM284'; ID: 20284),
    (Name: 'IBM285'; ID: 20285),
    (Name: 'IBM290'; ID: 20290),
    (Name: 'IBM297'; ID: 20297),
    (Name: 'IBM420'; ID: 20420),
    (Name: 'IBM423'; ID: 20423),
    (Name: 'IBM424'; ID: 20424),
    (Name: 'x-EBCDIC-KoreanExtended'; ID: 20833),
    (Name: 'IBM-Thai'; ID: 20838),
    (Name: 'koi8-r'; ID: 20866),
    (Name: 'IBM871'; ID: 20871),
    (Name: 'IBM880'; ID: 20880),
    (Name: 'IBM905'; ID: 20905),
    (Name: 'IBM00924'; ID: 20924),
    (Name: 'EUC-JP'; ID: 20932),
    (Name: 'x-cp20936'; ID: 20936),
    (Name: 'x-cp20949'; ID: 20949),
    (Name: 'cp1025'; ID: 21025),
    (Name: 'koi8-u'; ID: 21866),
    (Name: 'iso-8859-1'; ID: 28591),
    (Name: 'iso-8859-2'; ID: 28592),
    (Name: 'iso-8859-3'; ID: 28593),
    (Name: 'iso-8859-4'; ID: 28594),
    (Name: 'iso-8859-5'; ID: 28595),
    (Name: 'iso-8859-6'; ID: 28596),
    (Name: 'iso-8859-7'; ID: 28597),
    (Name: 'iso-8859-8'; ID: 28598),
    (Name: 'iso-8859-9'; ID: 28599),
    (Name: 'iso-8859-13'; ID: 28603),
    (Name: 'iso-8859-15'; ID: 28605),
    (Name: 'x-Europa'; ID: 29001),
    (Name: 'iso-8859-8-i'; ID: 38598),
    (Name: 'iso-2022-jp'; ID: 50220),
    (Name: 'csISO2022JP'; ID: 50221),
    (Name: 'iso-2022-jp'; ID: 50222),
    (Name: 'iso-2022-kr'; ID: 50225),
    (Name: 'x-cp50227'; ID: 50227),
    (Name: 'euc-jp'; ID: 51932),
    (Name: 'EUC-CN'; ID: 51936),
    (Name: 'euc-kr'; ID: 51949),
    (Name: 'hz-gb-2312'; ID: 52936),
    (Name: 'GB18030'; ID: 54936),
    (Name: 'x-iscii-de'; ID: 57002),
    (Name: 'x-iscii-be'; ID: 57003),
    (Name: 'x-iscii-ta'; ID: 57004),
    (Name: 'x-iscii-te'; ID: 57005),
    (Name: 'x-iscii-as'; ID: 57006),
    (Name: 'x-iscii-or'; ID: 57007),
    (Name: 'x-iscii-ka'; ID: 57008),
    (Name: 'x-iscii-ma'; ID: 57009),
    (Name: 'x-iscii-gu'; ID: 57010),
    (Name: 'x-iscii-pa'; ID: 57011),
    (Name: 'utf-7'; ID: 65000),
    (Name: 'utf-8'; ID: 65001)
  );

  ID_SORTED_CODE_PAGES: array[0..142] of DSLCodePageInfo =
  (
    (Name: 'IBM037'; ID: 37),
    (Name: 'IBM437'; ID: 437),
    (Name: 'IBM500'; ID: 500),
    (Name: 'ASMO-708'; ID: 708),
    (Name: 'ASMO-449+'; ID: 709),
    (Name: 'BCON V4'; ID: 709),
    (Name: 'Arabic'; ID: 710),
    (Name: 'DOS-720'; ID: 720),
    (Name: 'ibm737'; ID: 737),
    (Name: 'ibm775'; ID: 775),
    (Name: 'ibm850'; ID: 850),
    (Name: 'ibm852'; ID: 852),
    (Name: 'IBM855'; ID: 855),
    (Name: 'ibm857'; ID: 857),
    (Name: 'IBM00858'; ID: 858),
    (Name: 'IBM860'; ID: 860),
    (Name: 'ibm861'; ID: 861),
    (Name: 'DOS-862'; ID: 862),
    (Name: 'IBM863'; ID: 863),
    (Name: 'IBM864'; ID: 864),
    (Name: 'IBM865'; ID: 865),
    (Name: 'cp866'; ID: 866),
    (Name: 'ibm869'; ID: 869),
    (Name: 'IBM870'; ID: 870),
    (Name: 'windows-874'; ID: 874),
    (Name: 'cp875'; ID: 875),
    (Name: 'shift_jis'; ID: 932),
    (Name: 'gb2312'; ID: 936),
    (Name: 'ks_c_5601-1987'; ID: 949),
    (Name: 'big5'; ID: 950),
    (Name: 'IBM1026'; ID: 1026),
    (Name: 'IBM01047'; ID: 1047),
    (Name: 'IBM01140'; ID: 1140),
    (Name: 'IBM01141'; ID: 1141),
    (Name: 'IBM01142'; ID: 1142),
    (Name: 'IBM01143'; ID: 1143),
    (Name: 'IBM01144'; ID: 1144),
    (Name: 'IBM01145'; ID: 1145),
    (Name: 'IBM01146'; ID: 1146),
    (Name: 'IBM01147'; ID: 1147),
    (Name: 'IBM01148'; ID: 1148),
    (Name: 'IBM01149'; ID: 1149),
    (Name: 'utf-16'; ID: 1200),
    (Name: 'unicodeFFFE'; ID: 1201),
    (Name: 'windows-1250'; ID: 1250),
    (Name: 'windows-1251'; ID: 1251),
    (Name: 'windows-1252'; ID: 1252),
    (Name: 'windows-1253'; ID: 1253),
    (Name: 'windows-1254'; ID: 1254),
    (Name: 'windows-1255'; ID: 1255),
    (Name: 'windows-1256'; ID: 1256),
    (Name: 'windows-1257'; ID: 1257),
    (Name: 'windows-1258'; ID: 1258),
    (Name: 'Johab'; ID: 1361),
    (Name: 'macintosh'; ID: 10000),
    (Name: 'x-mac-japanese'; ID: 10001),
    (Name: 'x-mac-chinesetrad'; ID: 10002),
    (Name: 'x-mac-korean'; ID: 10003),
    (Name: 'x-mac-arabic'; ID: 10004),
    (Name: 'x-mac-hebrew'; ID: 10005),
    (Name: 'x-mac-greek'; ID: 10006),
    (Name: 'x-mac-cyrillic'; ID: 10007),
    (Name: 'x-mac-chinesesimp'; ID: 10008),
    (Name: 'x-mac-romanian'; ID: 10010),
    (Name: 'x-mac-ukrainian'; ID: 10017),
    (Name: 'x-mac-thai'; ID: 10021),
    (Name: 'x-mac-ce'; ID: 10029),
    (Name: 'x-mac-icelandic'; ID: 10079),
    (Name: 'x-mac-turkish'; ID: 10081),
    (Name: 'x-mac-croatian'; ID: 10082),
    (Name: 'utf-32'; ID: 12000),
    (Name: 'utf-32BE'; ID: 12001),
    (Name: 'x-Chinese_CNS'; ID: 20000),
    (Name: 'x-cp20001'; ID: 20001),
    (Name: 'x_Chinese-Eten'; ID: 20002),
    (Name: 'x-cp20003'; ID: 20003),
    (Name: 'x-cp20004'; ID: 20004),
    (Name: 'x-cp20005'; ID: 20005),
    (Name: 'x-IA5'; ID: 20105),
    (Name: 'x-IA5-German'; ID: 20106),
    (Name: 'x-IA5-Swedish'; ID: 20107),
    (Name: 'x-IA5-Norwegian'; ID: 20108),
    (Name: 'us-ascii'; ID: 20127),
    (Name: 'x-cp20261'; ID: 20261),
    (Name: 'x-cp20269'; ID: 20269),
    (Name: 'IBM273'; ID: 20273),
    (Name: 'IBM277'; ID: 20277),
    (Name: 'IBM278'; ID: 20278),
    (Name: 'IBM280'; ID: 20280),
    (Name: 'IBM284'; ID: 20284),
    (Name: 'IBM285'; ID: 20285),
    (Name: 'IBM290'; ID: 20290),
    (Name: 'IBM297'; ID: 20297),
    (Name: 'IBM420'; ID: 20420),
    (Name: 'IBM423'; ID: 20423),
    (Name: 'IBM424'; ID: 20424),
    (Name: 'x-EBCDIC-KoreanExtended'; ID: 20833),
    (Name: 'IBM-Thai'; ID: 20838),
    (Name: 'koi8-r'; ID: 20866),
    (Name: 'IBM871'; ID: 20871),
    (Name: 'IBM880'; ID: 20880),
    (Name: 'IBM905'; ID: 20905),
    (Name: 'IBM00924'; ID: 20924),
    (Name: 'EUC-JP'; ID: 20932),
    (Name: 'x-cp20936'; ID: 20936),
    (Name: 'x-cp20949'; ID: 20949),
    (Name: 'cp1025'; ID: 21025),
    (Name: 'koi8-u'; ID: 21866),
    (Name: 'iso-8859-1'; ID: 28591),
    (Name: 'iso-8859-2'; ID: 28592),
    (Name: 'iso-8859-3'; ID: 28593),
    (Name: 'iso-8859-4'; ID: 28594),
    (Name: 'iso-8859-5'; ID: 28595),
    (Name: 'iso-8859-6'; ID: 28596),
    (Name: 'iso-8859-7'; ID: 28597),
    (Name: 'iso-8859-8'; ID: 28598),
    (Name: 'iso-8859-9'; ID: 28599),
    (Name: 'iso-8859-13'; ID: 28603),
    (Name: 'iso-8859-15'; ID: 28605),
    (Name: 'x-Europa'; ID: 29001),
    (Name: 'iso-8859-8-i'; ID: 38598),
    (Name: 'iso-2022-jp'; ID: 50220),
    (Name: 'csISO2022JP'; ID: 50221),
    (Name: 'iso-2022-jp'; ID: 50222),
    (Name: 'iso-2022-kr'; ID: 50225),
    (Name: 'x-cp50227'; ID: 50227),
    (Name: 'euc-jp'; ID: 51932),
    (Name: 'EUC-CN'; ID: 51936),
    (Name: 'euc-kr'; ID: 51949),
    (Name: 'hz-gb-2312'; ID: 52936),
    (Name: 'GB18030'; ID: 54936),
    (Name: 'x-iscii-de'; ID: 57002),
    (Name: 'x-iscii-be'; ID: 57003),
    (Name: 'x-iscii-ta'; ID: 57004),
    (Name: 'x-iscii-te'; ID: 57005),
    (Name: 'x-iscii-as'; ID: 57006),
    (Name: 'x-iscii-or'; ID: 57007),
    (Name: 'x-iscii-ka'; ID: 57008),
    (Name: 'x-iscii-ma'; ID: 57009),
    (Name: 'x-iscii-gu'; ID: 57010),
    (Name: 'x-iscii-pa'; ID: 57011),
    (Name: 'utf-7'; ID: 65000),
    (Name: 'utf-8'; ID: 65001)
  );

function CodePageName2ID(Name: PAnsiChar; NameLen: Integer): Integer; overload;
function CodePageName2ID(const Name: AnsiString): Integer; overload;
function CodePageID2Name(ID: Integer): AnsiString; overload;

type
  DSLPointerType = Cardinal;

  DSLCharType = (chAlphaUpperCase, chAlphaLowerCase, chDigit);
  DSLCharTypes = set of DSLCharType;

  DSLOperationResult = (orUnknown, orException, orFail, orSuccess, orPending, orAlready, orRetry);

function IsEqualFloat(d1, d2: Double): Boolean;

(*************************************时间日期相关************************************)

function FormatSysTime(const st: TSystemTime; const fmt: string = ''): string;

function FormatSysTimeNow(const fmt: string = ''): string;

function SameHour(former, later: TDateTime): Boolean;

function SameDay(former, later: TDateTime): Boolean;

function SameMonth(former, later: TDateTime): Boolean;

function SameYear(former, Later: TDateTime): Boolean;

procedure SystemTimeIncMilliSeconds(var st: TSystemTime; value: Int64);

procedure SystemTimeIncSeconds(var st: TSystemTime; value: Int64);

procedure SystemTimeIncMinutes(var st: TSystemTime; value: Integer);

procedure SystemTimeIncHours(var st: TSystemTime; value: Integer);

procedure SystemTimeIncDays(var st: TSystemTime; value: Integer);

procedure SystemTimeIncMonths(var st: TSystemTime; value: Integer);

procedure SystemTimeIncYears(var st: TSystemTime; value: Integer);

function UTCNow: TDateTime;

function UTCToLocal(dt: TDateTime): TDateTime;

function UTCLocalDiff: Integer;

function DateTimeToJava(d: TDateTime): Int64;

function JavaToDateTime(t: Int64): TDateTime;

function ReplaceIfNotEqual(var dst: RawByteString; const src: RawByteString;
  pEStayNETrue: PBoolean = nil): Boolean; overload;

function ReplaceIfNotEqual(var dst: UnicodeString; const src: UnicodeString;
  pEStayNETrue: PBoolean = nil): Boolean; overload;

function ReplaceIfNotEqual(var dst: Integer; const src: Integer;
  pEStayNETrue: PBoolean = nil): Boolean; overload;

function ReplaceIfNotEqual(var dst: Int64; const src: Int64;
  pEStayNETrue: PBoolean = nil): Boolean; overload;

function ReplaceIfNotEqual(var dst: Double; const src: Double;
  pEStayNETrue: PBoolean = nil): Boolean; overload;

function ReplaceIfNotEqual(var dst: Real; const src: Real;
  pEStayNETrue: PBoolean = nil): Boolean; overload;

function ReplaceIfNotEqual(var dst: Boolean; const src: Boolean;
  pEStayNETrue: PBoolean = nil): Boolean; overload;

function RandomStringA(CharSet: RawByteString; CharCount: Integer): RawByteString;

function RandomAlphaStringA(CharCount: Integer; types: DSLCharTypes = [chAlphaUpperCase, chAlphaLowerCase]): RawByteString;

function RandomDigitStringA(CharCount: Integer): RawByteString;

function RandomAlphaDigitStringA(CharCount: Integer;
  types: DSLCharTypes = [chAlphaUpperCase, chAlphaLowerCase]): RawByteString;

function RandomStringW(CharSet: UnicodeString; CharCount: Integer): UnicodeString;

function RandomAlphaStringW(CharCount: Integer;
  types: DSLCharTypes = [chAlphaUpperCase, chAlphaLowerCase]): UnicodeString;

function RandomDigitStringW(CharCount: Integer): UnicodeString;

function RandomAlphaDigitStringW(CharCount: Integer;
  types: DSLCharTypes = [chAlphaUpperCase, chAlphaLowerCase]): UnicodeString;

function RandomCNMobile: RawByteString;

procedure AnsiStrAssignWideChar(dst: PAnsiChar; c: WideChar; CodePage: Integer);

function BufToUnicodeTest(src: PAnsiChar; srclen: DWORD; CodePage: Integer): Integer;

function BufToUnicode(src: PAnsiChar; srclen: DWORD; dst: PWideChar; CodePage: Integer): Integer; overload;

function BufToUnicode(src: PAnsiChar; srclen: DWORD; CodePage: Integer): UnicodeString; overload;


function BufToMultiByteTest(src: PWideChar; srclen: DWORD; CodePage: Integer): Integer;

function BufToMultiByte(src: PWideChar; srclen: DWORD; dst: PAnsiChar; CodePage: Integer): Integer; overload;

function BufToMultiByte(src: PWideChar; srclen: DWORD; CodePage: Integer): RawByteString; overload;

function UStrToMultiByte(const src: UnicodeString; dst: PAnsiChar; CodePage: Integer): Integer; overload;

function UStrToMultiByte(const src: UnicodeString; CodePage: Integer): RawByteString; overload;

function UTF8EncodeBufferTest(src: PWideChar; srclen: Integer): Integer;

function UTF8EncodeBuffer(src: PWideChar; srclen: Integer; dest: PAnsiChar): Integer; overload;

function UTF8EncodeBuffer(src: PWideChar; srclen: Integer): UTF8String; overload;

function UTF8EncodeCStrTest(src: PWideChar): Integer;

function UTF8EncodeCStr(src: PWideChar; dest: PAnsiChar): Integer; overload;

function UTF8EncodeCStr(src: PWideChar): RawByteString; overload;

function UTF8EncodeUStr(const src: UnicodeString; dest: PAnsiChar): Integer; overload;

function UTF8EncodeUStr(const src: UnicodeString): UTF8String; overload;

function UTF8EncodeBStr(const src: WideString; dest: PAnsiChar): Integer; overload;

function UTF8EncodeBStr(const src: WideString): UTF8String; overload;

function UTF8DecodeBufferTest(src: PAnsiChar; srclen: Integer; invalid: PPAnsiChar = nil): Integer;

function UTF8DecodeBuffer(src: PAnsiChar; srclen: Integer; dest: PWideChar; invalid: PPAnsiChar = nil): Integer; overload;

function UTF8DecodeBuffer(src: PAnsiChar; srclen: Integer; invalid: PPAnsiChar = nil): UnicodeString; overload;

function UTF8DecodeCStrTest(src: PAnsiChar; invalid: PPAnsiChar = nil): Integer;

function UTF8DecodeCStr(src: PAnsiChar; dest: PWideChar; invalid: PPAnsiChar = nil): Integer; overload;

function UTF8DecodeCStr(src: PAnsiChar; invalid: PPAnsiChar = nil): UnicodeString; overload;

function UTF8DecodeStr(const src: RawByteString; dest: PWideChar; invalid: PPAnsiChar = nil): Integer; overload;

function UTF8DecodeStr(const src: RawByteString; invalid: PPAnsiChar = nil): UnicodeString; overload;

procedure UTF8EncodeFile(const FileName: string);

procedure UTF8DecodeFile(const FileName: string);

procedure HttpEncodeFile(const FileName: string);

procedure HttpDecodeFile(const FileName: string);

function HTMLDecodeBufA(s: PAnsiChar; len: Integer): RawByteString;

function HTMLDecodeStrA(const s: RawByteString): RawByteString;

function HTMLDecodeBufferW(s: PWideChar; len: Integer): UnicodeString;

function HTMLDecodeUStr(const s: UnicodeString): UnicodeString;

function HTMLDecodeBStr(const s: WideString): WideString;

function GetInputPropW(str: PWideChar; len: Integer; const name: UnicodeString; out P1, P2: PWideChar): Boolean; overload;

function GetInputPropW(str: PWideChar; len: Integer; const name: UnicodeString; out value: UnicodeString): Boolean; overload;

function GetInputValueW(str: PWideChar; len: Integer; const name: UnicodeString; out value: UnicodeString): Boolean;

function GetInputPropA(str: PAnsiChar; len: Integer; const name: RawByteString; out value: RawByteString): Boolean; overload;

function GetInputPropA(str: PAnsiChar; len: Integer; const name: RawByteString; out P1, P2: PAnsiChar): Boolean; overload;

function GetInputValueA(str: PAnsiChar; len: Integer; const name: RawByteString; out value: RawByteString): Boolean;

function StrIsEmptyA(const s: RawByteString): Boolean;

function UStrIsEmpty(const s: UnicodeString): Boolean;

(***********************char case converting*********************************)

procedure StrUpperW(str: PWideChar; len: Integer); overload;

procedure UStrUpper(const str: UnicodeString);

procedure BStrUpper(const str: WideString);

procedure StrLowerW(str: PWideChar; len: Integer);

procedure UStrLower(const str: UnicodeString);

procedure BStrLower(const str: WideString);

procedure StrUpperA(str: PAnsiChar; len: Integer); overload;

procedure StrUpperA(const str: RawByteString); overload;

procedure StrLowerA(str: PAnsiChar; len: Integer); overload;

procedure StrLowerA(const str: RawByteString); overload;

procedure DSLSetStringA(var s: RawByteString; _begin, _end: PAnsiChar);

procedure DSLSetStringW(var s: UnicodeString; _begin, _end: PWideChar);

(*************************string to integer****************************)


function DecimalStrToIntA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Integer;

function HexStrToIntA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Integer;

function BufToIntA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Integer;

function StrToIntA(const str: RawByteString): Integer;

function DecimalStrToInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Int64;

function HexStrToInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Int64;

function BufToInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Int64;

function StrToInt64A(const str: RawByteString): Int64;

function DecimalBufToIntW(buf: PWideChar; len: Integer; invalid: PPWideChar): Integer;

function HexBufToIntW(buf: PWideChar; len: Integer; invalid: PPWideChar): Integer;

function BufToIntW(buf: PWideChar; len: Integer; invalid: PPWideChar): Integer;

function UStrToInt(const str: UnicodeString): Integer;

function BStrToInt(const str: WideString): Integer;

function DecimalBufToInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): Int64;

function HexBufToInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): Int64;

function BufToInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): Int64;

function BStrToInt64(const str: WideString): Int64;

function UStrToInt64(const str: UnicodeString): Int64;

(*************************string to float****************************)

function BufToFloatA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Double;

function StrToFloatA(const str: RawByteString): Double;

function BufToFloatA2(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Double;

function StrToFloatA2(const str: RawByteString): Double;

function BufToFloatW(buf: PWideChar; len: Integer; invalid: PPWideChar): Double;

function UStrToFloat(const str: UnicodeString): Double;

function BStrToFloat(const str: WideString): Double;

(*************************sub string search****************************)

function StrScanA(s: PAnsiChar; len: Integer; c: AnsiChar): PAnsiChar; overload;

function StrScanA(s: PAnsiChar; c: AnsiChar): PAnsiChar; overload;

function StrScanA(const s: RawByteString; c: AnsiChar): Integer; overload;

function StrScanW(s: PWideChar; len: Integer; c: WideChar): PWideChar; overload;

function StrScanW(s: PWideChar; c: WideChar): PWideChar; overload;

function UStrScan(const s: UnicodeString; c: WideChar): Integer; overload;

function BStrScan(const s: WideString; c: WideChar): Integer; overload;

function StrScan(const s: string; c: Char): Integer;

function StrPosW(substr, str: PWideChar): PWideChar; overload;

function StrPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;

function UStrPos(const substr, str: UnicodeString; StartIndex: Integer = 1; EndIndex: Integer = 0): Integer; overload;

function BStrPos(const substr, str: WideString; StartIndex: Integer = 1; EndIndex: Integer = 0): Integer; overload;

function StrIPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;

function UStrIPos(const substr, str: UnicodeString; StartIndex: Integer = 1; EndIndex: Integer = 0): Integer;

function BStrIPos(const substr, str: WideString; StartIndex, EndIndex: Integer): Integer;

function StrRPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;

function UStrRPos(const substr, str: UnicodeString; StartIndex: Integer = 1; EndIndex: Integer = 0): Integer;

function BStrRPos(const substr, str: WideString; StartIndex: Integer = 1; EndIndex: Integer = 0): Integer;

function StrRIPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;

function UStrRIPos(const substr, str: UnicodeString; StartIndex: Integer = 1; EndIndex: Integer = 0): Integer;

function BStrRIPos(const substr, str: WideString; StartIndex: Integer = 1; EndIndex: Integer = 0): Integer;

function StrPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar; overload;

function StrPosA(substr: PAnsiChar; str: PAnsiChar): PAnsiChar; overload;

function StrPosA(const substr, str: RawByteString; StartIndex: Integer = 1; EndIndex: Integer = 0): Integer; overload;

function BeginWithW(s: PWideChar; len: Integer; sub: PWideChar; sublen: Integer): Boolean; overload;

function BeginWithW(s, sub: PWideChar): Boolean; overload;

function IBeginWithW(s, sub: PWideChar): Boolean; overload;

function BeginWithA(s: PAnsiChar; len: Integer; sub: PAnsiChar; sublen: Integer): Boolean; overload;

function BeginWithA(s, sub: PAnsiChar): Boolean; overload;

function IBeginWithA(s, sub: PAnsiChar): Boolean; overload;

function StrReplaceA(const S, OldPattern, NewPattern: RawByteString; Flags: TReplaceFlags): RawByteString;

function UStrReplace(const S, OldPattern, NewPattern: UnicodeString; Flags: TReplaceFlags): UnicodeString;

function BStrReplace(const S, OldPattern, NewPattern: WideString; Flags: TReplaceFlags): WideString;

(******************************string compare******************************)

function StrCompareW(const S1: PWideChar; L1: Integer; S2: PWideChar; L2: Integer; CaseSensitive: Boolean = True): Integer; overload;

function StrCompareW(S1, S2: PWideChar; CaseSensitive: Boolean = True): Integer; overload;

function UStrCompare(S1, S2: UnicodeString; CaseSensitive: Boolean = True): Integer;

function BStrCompare(S1, S2: WideString; CaseSensitive: Boolean = True): Integer;

function StrCompareA(str1: PAnsiChar; len1: Integer; str2: PAnsiChar; len2: Integer; CaseSensitive: Boolean = True): Integer; overload;

function StrCompareA(const Str1, Str2: RawByteString; CaseSensitive: Boolean): Integer; overload;

function UStrCatCStr(const s1: array of UnicodeString; s2: PWideChar): UnicodeString;

(******************************sub string extract******************************)

function GetSectionBetweenA(const src, prefix, suffix: RawByteString; out P1, P2: Integer;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;

function GetTrimedSectionBetweenA(const src, prefix, suffix: RawByteString; out P1, P2: Integer;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;

function GetSubstrBetweenA(const src, prefix, suffix: RawByteString;
  start: Integer = 1; limit: Integer = 0): RawByteString; overload;

function GetTrimedSubstrBetweenA(const src, prefix, suffix: RawByteString;
  start: Integer = 1; limit: Integer = 0): RawByteString; overload;

function GetIntegerBetweenA(const src, prefix, suffix: RawByteString;
  out value: Int64; start: Integer = 1; limit: Integer = 0): Boolean; overload;

function GetIntegerBetweenA(const src, prefix, suffix: RawByteString;
  start: Integer = 1; limit: Integer = 0): Int64; overload;

function GetFloatBetweenA(const src, prefix, suffix: RawByteString; out value: Double;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;

function GetFloatBetweenA(const src, prefix, suffix: RawByteString;
  start: Integer = 1; limit: Integer = 0): Double; overload;

function GetSectionBetweenW(const src, prefix, suffix: UnicodeString; out P1, P2: Integer;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;

function GetTrimedSectionBetweenW(const src, prefix, suffix: UnicodeString; out P1, P2: Integer;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;

function GetSubstrBetweenW(const src, prefix, suffix: UnicodeString;
  start: Integer = 1; limit: Integer = 0): UnicodeString; overload;

function GetTrimedSubstrBetweenW(const src, prefix, suffix: UnicodeString;
  start: Integer = 1; limit: Integer = 0): UnicodeString; overload;

function GetIntegerBetweenW(const src, prefix, suffix: UnicodeString; out value: Int64;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;

function GetIntegerBetweenW(const src, prefix, suffix: UnicodeString;
  start: Integer = 1; limit: Integer = 0): Int64; overload;

function GetFloatBetweenW(const src, prefix, suffix: UnicodeString; out value: Double;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;

function GetFloatBetweenW(const src, prefix, suffix: UnicodeString;
  start: Integer = 1; limit: Integer = 0): Double; overload;

function XMLGetNodeContent(const src, NodeName: RawByteString; start: Integer = 1; limit: Integer = -1): RawByteString;
  
function XMLDecodeW(s: PWideChar; len: Integer): UnicodeString; overload;

function XMLDecodeW(s: PWideChar): UnicodeString; overload;

function XMLDecodeUStr(const s: UnicodeString): UnicodeString; overload;

function XMLDecodeBStr(const s: WideString): WideString; overload;

function GetSectionBetweenA(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  out P1, P2: Integer; start: Integer = 1; limit: Integer = 0;
  EndingNoSuffix: Boolean = True): Boolean; overload;

function GetSubstrBetweenA(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  start: Integer = 1; limit: Integer = 0; EndingNoSuffix: Boolean = True): RawByteString; overload;

function GetTrimedSubstrBetweenA(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  start: Integer = 1; limit: Integer = 0; EndingNoSuffix: Boolean = True): RawByteString; overload;

function GetSectionBetweenW(const src, prefix: UnicodeString; const suffix: array of WideChar;
  out P1, P2: Integer; start: Integer = 1; limit: Integer = 0;
  EndingNoSuffix: Boolean = True): Boolean;  overload;

function GetSubstrBetweenW(const src, prefix: UnicodeString; const suffix: array of WideChar;
  start: Integer = 1; limit: Integer = 0; EndingNoSuffix: Boolean = True): UnicodeString; overload;

function GetTrimedSubstrBetweenW(const src, prefix: UnicodeString; const suffix: array of WideChar;
  start: Integer = 1; limit: Integer = 0; EndingNoSuffix: Boolean = True): UnicodeString; overload;

function UStrCopyUntil(const src: UnicodeString; const suffix: array of WideChar;
  StartIndex, EndIndex: Integer; EndingNoSuffix: Boolean = True): UnicodeString;

function TrimCopyU(const s: UnicodeString; start, len: Integer): UnicodeString;
function TrimCopyA(const s: RawByteString; start, len: Integer): RawByteString;
function TrimCopyW(const s: WideString; start, len: Integer): WideString;

function ExtractIntegerA(const str: RawByteString): Integer;

function ExtractIntegersA(const str: RawByteString; var numbers: array of Int64): Integer;

function UStrExtractInteger(const str: UnicodeString): Integer;

function UStrExtractIntegers(const str: UnicodeString; var numbers: array of Int64): Integer;

function BStrExtractInteger(const str: WideString): Integer;

function BStrExtractIntegers(const str: WideString; var numbers: array of Int64): Integer;

function GetFloatBeforeA(str: PAnsiChar; len: Integer; substr: PAnsiChar; sublen: Integer; 
  out number: Double): Boolean; overload;

function GetFloatBeforeW(str: PWideChar; len: Integer; substr: PWideChar; sublen: Integer; 
  out number: Double): Boolean;

function GetFloatBeforeA(const s, suffix: RawByteString; out number: Double): Boolean; overload;

function UStrGetFloatBefore(const s, suffix: UnicodeString; out number: Double): Boolean;

function BStrGetFloatBefore(const s, suffix: WideString; out number: Double): Boolean;

(*************************格式验证*********************************)

function IsIntegerA(str: PAnsiChar; len: Integer): Boolean; overload;

function IsIntegerA(const str: RawByteString): Boolean; overload;

function IsIntegerW(str: PWideChar; len: Integer): Boolean; overload;

function UStrIsInteger(const str: UnicodeString): Boolean;

function BStrIsInteger(const str: WideString): Boolean;

function IsChinaIDCardNoA(const idc: RawByteString): Boolean;

function UStrIsChinaIDCardNo(const idc: UnicodeString): Boolean;

function BStrIsChinaIDCardNo(const idc: WideString): Boolean;

function IsTencentQQIDA(const str: RawByteString): Boolean;

function StrSliceA(s: PAnsiChar; len, offset: Integer; num: Integer = -1): RawByteString; overload;

function StrSliceA(const s: RawByteString; offset: Integer; num: Integer = -1): RawByteString; overload;

procedure StrSplit(const str, delimiter: string; list: TStrings);

function StrSplitA(const str: RawByteString; const delimiters: array of AnsiChar;
  var strs: array of RawByteString): Integer;

function StrToDateTimeA(const s: RawByteString; out dt: TDateTime): Boolean;

function UStrToDateTime(const s: UnicodeString; out dt: TDateTime): Boolean;

(*****************************************debug output********************************************)
function SafeWriteln(const s: RawByteString): Boolean; overload;
function SafeWriteln(const s: UnicodeString): Boolean; overload;

function PrintArray(const args: array of const; const separator: string = #32;
  LineFeed: Boolean = True): Boolean;

function WritelnException(e: Exception): Boolean; overload;
function WritelnException(const func: string; e: Exception): Boolean; overload;

function OutputDebugArray(const args: array of const; const separator: string = #32;
  LineFeed: Boolean = True): Boolean;

function OutputDebugException(e: Exception): Boolean; overload;
function OutputDebugException(const func: string; e: Exception): Boolean; overload;

function DbgOutputA(const msg: RawByteString): Boolean;
function DbgOutputW(const msg: UnicodeString): Boolean;
function DbgOutput(const msg: string): Boolean;

function DbgOutputArray(const args: array of const; const separator: string = #32;
  LineFeed: Boolean = True): Boolean;

function DbgOutputFmtA(const fmt: RawByteString; const args: array of const): Boolean;
function DbgOutputFmtW(const fmt: UnicodeString; const args: array of const): Boolean;
function DbgOutputFmt(const fmt: string; const args: array of const): Boolean;

function DbgOutputException(e: Exception): Boolean; overload;
function DbgOutputException(const func: string; e: Exception): Boolean; overload;

procedure StopAndWaitForThread(threads: TList);

procedure StreamWriteStrA(stream: TStream; const str: RawByteString);

function MemHex(const Buffer; Size: Integer; UpperCase: Boolean = True): RawByteString;

function CloneList(src: TList): TList;

procedure ThreadListInsert(list: TThreadList; index: Integer; item: Pointer);

procedure ThreadListAdd(list: TThreadList; item: Pointer);

function ThreadListGetItem(list: TThreadList; index: Integer): Pointer;

function ThreadListGetInternalList(list: TThreadList): TList;

function ThreadListGetCount(list: TThreadList): Integer;

procedure ClearObjectList(objlist: TObject);

procedure ClearObjectListAndFree(objlist: TObject);

(**********************************文件目录相关********************************)

procedure dir_list(const ParentDir: string; strs: TStrings);

procedure SafeForceDirectories(const dir: string);

procedure SaveBufToFile(const FileName: string; buf: Pointer; len: Integer);

procedure SaveStrToFile(const FileName: string; const str: RawByteString);
function SafeSaveStrToFile(const FileName: string; const str: RawByteString): Boolean;

procedure SaveStrsToFile(const FileName: string; const strs: array of RawByteString);
function SafeSaveStrsToFile(const FileName: string; const strs: array of RawByteString): Boolean;

function LoadStrFromFile(const FileName: string): RawByteString;

function Stream2String(stream: TStream): RawByteString;

function ControlFindContainer(control: TControl; cls: TClass): TWinControl;

function ControlFindChild(container: TWinControl; cls: TClass): TControl;

procedure ShowInfoDialog(const msg: string; hwnd: THandle = 0);

procedure ShowErrorDialog(const msg: string; hwnd: THandle = 0);

procedure ShowWarnDialog(const msg: string; hwnd: THandle = 0);

function ControlVisible(ctrl: TControl): Boolean;

procedure ControlSetFocus(ctrl: TWinControl);

procedure EditSetNumberOnly(edit: TWinControl);

procedure CloseForm(form: TCustomForm);

procedure ListViewSetRowCount(ListView: TListView; count: Integer);

function UrlExtractPathA(const url: RawByteString): RawByteString;

function UrlExtractPathW(const url: UnicodeString): UnicodeString;

function UrlExtractFileNameA(const url: RawByteString): RawByteString;

function HttpEncodeCStrTest(str: PAnsiChar; const non_conversions: RawByteString = '*._-'): Integer;

function HttpEncodeCStr2Buf(src, dst: PAnsiChar; const non_conversions: RawByteString = '*._-'): Integer; overload;

function HttpEncodeCStr(src: PAnsiChar; const non_conversions: RawByteString = '*._-'): RawByteString; overload;

function HttpEncodeBufTest(const buf; buflen: Integer; const non_conversions: RawByteString = '*._-'): Integer;

function HttpEncodeBuf2Buf(const buf; buflen: Integer; dst: PAnsiChar; const non_conversions: RawByteString = '*._-'): Integer;

function HttpEncodeBuf(const src; srclen: Integer; const non_conversions: RawByteString = '*._-'): RawByteString;

function DSLHttpEncode(const src: RawByteString; const non_conversions: RawByteString = '*._-'): RawByteString;

function HttpDecodeBufTest(const buf; buflen: Integer; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeStrTest(const str: RawByteString; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeBuf2Buf(const buf; buflen: Integer; dst: PAnsiChar; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeBuf(const buf; buflen: Integer; invalid: PPAnsiChar = nil): RawByteString;

function DSLHttpDecode(const src: RawByteString; invalid: PPAnsiChar = nil): RawByteString;

function HttpDecodeCStrTest(src: PAnsiChar; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeCStr2Buf(str, dst: PAnsiChar; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeCStr(str: PAnsiChar; invalid: PPAnsiChar = nil): RawByteString;

function UStrLen(const s: UnicodeString): Integer;

function BStrLen(const s: WideString): Integer;

function StrLenW(s: PWideChar): Integer; overload;

procedure MsgSleep(period: DWORD);

type
  DSLConfirmDlgButtons = (
    cdbOK,
    cdbOKCancel,
    cdbAbortRetryIgnore,
    cdbYesNoCancel,
    cdbYesNo,
    cdbRetryCancel);

  DSLConfirmDlgResult = (
    cdrOK,
    cdrCancel,
    cdrAbort,
    cdrRetry,
    cdrIgnore,
    cdrYes,
    cdrNo,
    cdrClose,
    cdrHelp,
    cdrTryAgain,
    cdrContinue);

function ConfirmDialog(const msg: string; const parent: THandle = 0; const title: string = '';
  const buttons: DSLConfirmDlgButtons = cdbYesNo): DSLConfirmDlgResult;

function UrlGetParamA(const url, name: RawByteString): RawByteString;

function UStrUrlGetParam(const url, name: UnicodeString): UnicodeString;

function BStrUrlGetParam(const url, name: WideString): WideString;

function RunningInMainThread: Boolean;

function StrToBoolA(const s: string; def: Boolean): Boolean;

function Res2StrA(const ResName: string; const ResType: string): RawByteString;

procedure SaveResToFile(const ResName, ResType, SavePath: string);

procedure NavigateWithDefaultBrowser(const url: string);

function InternetExplorerGetCookie(const url: PAnsiChar; HttpOnly: Boolean): RawByteString;

function RegisterCOMComponet(pFileName: PChar): Boolean;

(*******************************windows shell utils**************************)

type
  TSpecialFolderID = (
    sfiDesktop  = $0000,
    sfiInternet = $0001,
    sfiPrograms = $0002,
    sfiControls = $0003,
    sfiPrinters = $0004,
    sfiPersonal = $0005,
    sfiFavorites = $0006,
    sfiStartup = $0007,
    sfiRecent = $0008,
    sfiSentTo = $0009,
    sfiBitBucket = $000a,
    sfiStartMenu = $000b,
    sfiMyDocuments = $000c,
    sfiMyMusic = $000d,
    sfiMyVideo = $000e,
    sfiDesktopDirectory = $0010,
    sfiDrivers = $0011,
    sfiNetwork = $0012,
    sfiNethood = $0013,
    sfiFonts = $0014,
    sfiTemplates = $0015,
    sfiCommonStartMenu = $0016,
    sfiCommonPrograms = $0017,
    sfiCommonStartup = $0018,
    sfiCommonDesktopDirectory = $0019,
    sfiAppData = $001a,
    sfiPrintHood = $001b,
    sfiLocalAppData = $001c,
    sfiAltStartup = $001d,
    sfiCommonAltStartup = $001e,
    sfiCommonFavorites = $001f,
    sfiINTERNET_CACHE = $0020,
    sfiCookies = $0021,
    sfiHistory = $0022,
    sfiCommonAppData = $0023,
    sfiWindows = $0024,
    sfiSystem = $0025,
    sfiProgramFiles = $0026,
    sfiMyPictures = $0027,
    sfiProfile = $0028,
    sfiSystemX86 = $0029,
    sfiProgramFilesX86 = $002a,
    sfiProgramFilesCommon = $002b,
    sfiProgramFilesCommonX86 = $002c,
    sfiCommonTemplates = $002d,
    sfiCommonDocuments = $002e,
    sfiCommonAdminTools = $002f,
    sfiAdminTools = $0030,
    sfiConnections = $0031,
    sfiCommonMusic = $0035,
    sfiCommonPictures = $0036,
    sfiCommonVideo = $0037,
    sfiResources = $0038,
    sfiResourcesLocalized = $0039,
    sfiCommonOemLinks = $003a,
    sfiCDBurnArea = $003b,
    sfiComputersNearMe = $003d,
    sfiProfiles = $003e);

function FindChildWindowRecursive(parent: HWND; WndClassName, WndText: PWideChar): HWND;

function SHGetTargetOfShortcut(const LinkFile: string): string;

function SHCreateShortcut(const TargetFile, desc, CreateAt: string): Boolean;

function SHGetSpecialFolderPath(FolderID: TSpecialFolderID): string;

procedure HeapSort(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; pSwap: DSLPointerProc);

procedure QuickSort(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; pSwap: DSLPointerProc);

function BinarySearch(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; const Value): Integer;

//使用二分查找确定要插入的新元素的位置
function BinarySearchInsertPos(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; const Value): Integer;

//顺序查找
function Search(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; const Value): Integer;

type
  DSLDynamicArray = array of Pointer;

  DSLCircularList= class
  private
    fList: DSLDynamicArray;
    fCapacity: Integer;
    fFirst: Integer;
    fCount: Integer;
    function GetItem(Index: Integer): Pointer;
    procedure SetItem(Index: Integer; const Value: Pointer);
    procedure SetCount(const Value: Integer);
  public
    constructor Create(_capacity: Integer);
    destructor Destroy; override;
    procedure MoveHead(num: Integer);
    procedure add(Item: Pointer); overload;
    function add: Pointer; overload;
    function IndexOf(Item: Pointer): Integer;
    procedure delete(Index: Integer);
    procedure clear;
    function remove(Item: Pointer): Integer;
    function GetInternalIndex(Index: Integer): Integer;
    property InternalList: DSLDynamicArray read fList;
    property capacity: Integer read fCapacity;
    property first: Integer read fFirst;
    property count: Integer read fCount write SetCount;
    property items[Index: Integer]: Pointer read GetItem write SetItem; default;
  end;

  DSLRefCountedObject = class
  private
    fRefCount: Integer;
  public
    constructor Create; reintroduce; virtual;
    function AddRef: Integer;
    function Release: Integer;
    property RefCount: Integer read fRefCount;
  end;

  IDSLAutoObject = interface
    function GetInstance: TObject;
  end;

  DSLAutoObject = class(TInterfacedObject)
  private
    fInstance: TObject;
  public
    constructor Create(_instance: TObject);
    destructor Destroy; override;
    function GetInstance: TObject;
    property Instance: TObject read fInstance;
  end;

  DSLRunnable = class(DSLRefCountedObject)
  protected
    fStatusCode: Integer;
    fStatusText: UnicodeString;
  public
    procedure run(context: TObject); virtual; aBStract;
    property StatusCode: Integer read fStatusCode;
    property StatusText: UnicodeString read fStatusText;
  end;

  DSLSignalThread = class(TThread)
  private
    fStopSignal: THandle;
  protected
    function WaitForStopSignal(timeout: DWORD = INFINITE): Boolean;
    function WaitForMultiObjects(handles: array of THandle; timeout: DWORD = INFINITE): DWORD;
    function WaitForSingleObject(handle: THandle; timeout: DWORD = INFINITE): DWORD;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    procedure SendStopSignal;
    procedure StopAndWait;
  end;

  PDSLLinkNode = ^DSLLinkNode;
  DSLLinkNode = record
    next: PDSLLinkNode;
    data: Pointer;
  end;

  PDSLDblLinkNode = ^DSLDblLinkNode;
  DSLDblLinkNode = record
    prev: PDSLDblLinkNode;
    next: PDSLDblLinkNode;
    data: Pointer;
  end;

  DSLFIFOQueue = class
  private
    fLockState: Integer;
    fFirst: PDSLLinkNode;
    fLast: PDSLLinkNode;
    fSize: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure clear;
    procedure push(item: Pointer);
    procedure PushFront(item: Pointer);
    function pop: Pointer;
    property size: Integer read fSize;
  end;

  DSLLIFOQueue = class
  private
    fLockState: Integer;
    fFirst: PDSLLinkNode;
  public
    constructor Create;
    destructor Destroy; override;
    procedure clear;
    procedure push(item: Pointer);
    function pop: Pointer;
  end;

  DSLWorkThread = class(DSLSignalThread)
  private
    fTaskSemaphore: THandle;
    fTaskQueue: DSLFIFOQueue;
    fCompletedTaskCount: Integer;
    fWaitingForTask: Boolean;
    fCurrentTaskName: string;
    function GetPendingTaskCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    procedure ClearTask;
    function QueueTask(task: DSLRunnable): Boolean;
    function QueueTaskFirst(task: DSLRunnable): Boolean;
    property CompletedTaskCount: Integer read fCompletedTaskCount;
    property PendingTaskCount: Integer read GetPendingTaskCount;
    property WaitingForTask: Boolean read fWaitingForTask;
    property CurrentTaskName: string read fCurrentTaskName;
  end;

  DSLWorkThreadClass = class of DSLWorkThread;

  PDSLDelayRunnable = ^DSLDelayRunnable;
  DSLDelayRunnable = record
    next: PDSLDelayRunnable;
    runtime: TDateTime;
    task: DSLRunnable;
  end;

  DSLDelayRunnableQueue = class
  private
    fFirstTask: PDSLDelayRunnable;
    fLock: TRTLCriticalSection;
    fSize: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure clear;
    function push(task: DSLRunnable; DelayMS: Int64): Boolean; overload;
    function push(task: DSLRunnable; runtime: TDateTime): Boolean; overload;
    function pop(var delay: DWORD): DSLRunnable;
    property size: Integer read fSize;
  end;

  DSLDelayRunnableThread = class(DSLSignalThread)
  private
    fTaskEvent: THandle;
    fTaskQueue: DSLDelayRunnableQueue;
    fCompletedTaskCount: Integer;
    function GetPendingTaskCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    function QueueTask(task: DSLRunnable; DelayMS: Int64): Boolean; overload;
    function QueueTask(task: DSLRunnable; runtime: TDateTime): Boolean; overload;
    property PendingTaskCount: Integer read GetPendingTaskCount;
    property CompletedTaskCount: Integer read fCompletedTaskCount;
  end;

  DSLWorkThreadPool = class
  private
    fThreads: TList;
    fActive: Boolean;
    fThreadCount: Integer;
    fThreadClass: DSLWorkThreadClass;
    procedure SetActive(const Value: Boolean);
    procedure SetThreadCount(const Value: Integer);
  protected
    procedure start;
    procedure stop;
  public
    constructor Create;
    destructor Destroy; override;
    function QueueTask(task: DSLRunnable): Boolean;
    property Active: Boolean read fActive write SetActive;
    property ThreadCount: Integer read fThreadCount write SetThreadCount;
    property ThreadClass: DSLWorkThreadClass read fThreadClass write fThreadClass;
  end;

  DSLFileStream = class(TFileStream)
  private
    fLock: TCriticalSection;
  public
    constructor Create(const AFileName: string; Mode: Word); overload;
    constructor Create(const AFileName: string; Mode: Word; Rights: Cardinal); overload;
    destructor Destroy; override;
    procedure lock;
    procedure unlock;
  end;

(****************************trace utils***************************************)

type
  DSLMessageLevel = (mlDebug, mlInformation, mlWarning, mlError);
  DSLMessageVerbosity = set of DSLMessageLevel;

const
  TRACE_SEVERITIES_ALL = [mlDebug, mlInformation, mlWarning, mlError];

  SEVERITY_NAMESA: array [DSLMessageLevel] of RawByteString =
  ('DEBUG', 'INFO', 'WARN', 'ERROR');
  SEVERITY_NAMESW: array [DSLMessageLevel] of UnicodeString =
  ('DEBUG', 'INFO', 'WARN', 'ERROR');

type
  DSLDateTimePart = (dtpYear, dtpMonth, dtpDay, dtpHour, dtpMinute, dtpSecond);
  
  DSLTextEncoding = (teAnsi, teUTF8, teUTF16);
  
  DSLMessageTag = (mtServerity, mtTime);
  DSLMessageTags = set of DSLMessageTag;

  DSLLogWritter = class
  protected
    fVerbosity: DSLMessageVerbosity;
    fOptions: DSLMessageTags;
    fDateTimeFormat: string;
    procedure SetVerbosity(const value: DSLMessageVerbosity); dynamic;
    procedure SetOptions(const value: DSLMessageTags); dynamic;
    procedure SetDateTimeFormat(const value: string); dynamic;
    procedure WriteAnsi(const text: RawByteString); virtual; aBStract;
    procedure WriteUnicode(const text: UnicodeString); virtual; aBStract;
  public
    constructor Create;
    procedure write(sev: DSLMessageLevel; const text: RawByteString); overload;
    procedure write(sev: DSLMessageLevel; const text: UnicodeString); overload;
    procedure writeln(sev: DSLMessageLevel; const text: RawByteString); overload;
    procedure writeln(sev: DSLMessageLevel; const text: UnicodeString); overload;

    procedure FormatWrite(sev: DSLMessageLevel; const fmt: RawByteString;
      const args: array of const); overload;

    procedure FormatWrite(sev: DSLMessageLevel; const fmt: UnicodeString;
      const args: array of const); overload;
      
    procedure flush; virtual; 
    property Verbosity: DSLMessageVerbosity read fVerbosity write fVerbosity;
    property options: DSLMessageTags read fOptions write fOptions;
    property DateTimeFormat: string read fDateTimeFormat write fDateTimeFormat;
  end;

  DSLFileLogWritter = class(DSLLogWritter)
  private
    fEncoding: DSLTextEncoding;
    fFileStream: TFileStream;
    function GetFileSize: Integer;
  protected
    procedure WriteAnsi(const text: RawByteString); override;
    procedure WriteUnicode(const text: UnicodeString); override;
  public
    constructor Create(const fileName: string);
    destructor Destroy; override;
    procedure flush; override;
    property FileSize: Integer read GetFileSize;
    property Encoding: DSLTextEncoding read fEncoding write fEncoding;
  end;

  DSLConsoleLogWritter = class(DSLLogWritter)
  protected
    procedure WriteAnsi(const text: RawByteString); override;
    procedure WriteUnicode(const text: UnicodeString); override;
  end;

  DSLDebugLogWritter = class(DSLLogWritter)
  protected
    procedure WriteAnsi(const text: RawByteString); override;
    procedure WriteUnicode(const text: UnicodeString); override;
  end;

  DSLMultiFileLogWritter = class
  private
    fLogFileDir: string;
    fLastLogTime: TDateTime;
    fLogSeparate: DSLDateTimePart;
    fWritter: DSLFileLogWritter;
    fDateTimeFormat: string;
    fVerbosity: DSLMessageVerbosity;
    fOptions: DSLMessageTags;
    fEncoding: DSLTextEncoding;
  protected
    procedure SetVerbosity(const Value: DSLMessageVerbosity);
    procedure SetOptions(const Value: DSLMessageTags);
    procedure SetDateTimeFormat(const Value: string);
  protected
    procedure CreateFileTracer(Tick: TDateTime);
  public
    constructor Create(const dir: string);
    destructor Destroy; override;

    procedure write(sev: DSLMessageLevel; const Text: RawByteString); overload;
    procedure write(sev: DSLMessageLevel; const Text: UnicodeString); overload;
    procedure writeln(sev: DSLMessageLevel; const Text: RawByteString); overload;
    procedure writeln(sev: DSLMessageLevel; const Text: UnicodeString); overload;

    procedure FormatWrite(sev: DSLMessageLevel; const fmt: RawByteString;
      const args: array of const); overload;

    procedure FormatWrite(sev: DSLMessageLevel; const fmt: UnicodeString;
      const args: array of const); overload;

    procedure flush;

    property LogSeparate: DSLDateTimePart read fLogSeparate write fLogSeparate;
    property severity: DSLMessageVerbosity read fVerbosity write fVerbosity;
    property options: DSLMessageTags read fOptions write fOptions;
    property DateTimeFormat: string read fDateTimeFormat write fDateTimeFormat;
    property encoding: DSLTextEncoding read fEncoding write fEncoding;
  end;

implementation

var
  JAVA_TIME_START: TDateTime;

procedure MsgSleep(period: DWORD);
var
  tick, remain, ellapse, wr: DWORD;
  events: array [0..0] of THandle;
begin
  if RunningInMainThread then
  begin
    events[0] := CreateEvent(nil, False, False, nil);

    try
      tick := GetTickCount;

      while not Application.Terminated do
      begin
        ellapse := GetTickCount - tick;

        if ellapse >= period then Break;

        remain := period - ellapse;
        
        wr := MsgWaitForMultipleObjects(1, events, False, remain, QS_ALLINPUT);

        if wr = WAIT_TIMEOUT then Break;

        if wr = WAIT_OBJECT_0 + 1 then
        try
          Application.ProcessMessages;
        except

        end;
      end;
    finally
      CloseHandle(events[0]);
    end;
  end
  else Windows.Sleep(period);
end;

function IsEqualFloat(d1, d2: Double): Boolean;
var
  diff: Double;
begin
  diff := d1 - d2;

  if diff >= 0 then Result := diff < 0.0001
  else Result := -diff < 0.0001;
end;

function ConsoleExists: Boolean;
var
  v: THandle;
begin
  v := GetStdHandle(STD_OUTPUT_HANDLE);
  Result := (v <> INVALID_HANDLE_VALUE) and (v <> 0);
end;

function SafeWriteln(const s: RawByteString): Boolean;
begin
  if IsConsole then writeln(s);
  Result := True;
end;

function SafeWriteln(const s: UnicodeString): Boolean;
begin
  if IsConsole then writeln(s);
  Result := True;
end;

function WritelnException(e: Exception): Boolean;
begin
  writeln(e.ClassName, ': ', e.Message);
  Result := True;
end;

procedure print_var_rec(const vr: TVarRec);
begin
  case vr.VType of
    vtInteger:    write(vr.VInteger);
    vtBoolean:    write(vr.VBoolean);
    vtChar:       write(vr.VChar);
    vtExtended:   write(FloatToStr(vr.VExtended^));
    vtString:     write(vr.VString^);
    vtPointer:    write(Format('%.8x', [vr.VPointer]));
    vtPChar:      write(vr.VPChar);
    vtObject:
      begin
        write('object(');
        write(vr.VObject.ClassName);
        write(')');
      end;

    vtClass:
      begin
        write('class(');
        write(vr.VClass.ClassName);
        write(')');
      end;

    vtWideChar:     write(vr.VWideChar);
    vtPWideChar:    write(vr.VPWideChar);
    vtAnsiString:   write(RawByteString(vr.VAnsiString));
    vtCurrency:     write(FloatToStr(vr.VCurrency^));
    vtVariant:      write(vr.VVariant^);
    vtInterface:    write('interface');
    vtUnicodeString:   write(UnicodeString(vr.VUnicodeString));
    vtInt64:        write(vr.VInt64^);
  end;
end;

function PrintArray(const args: array of const; const separator: string;
  LineFeed: Boolean): Boolean;
var
  i: Integer;
begin
  if Length(args) > 0 then 
  begin
    print_var_rec(TVarRec(args[Low(args)]));

    for i := Low(args) + 1 to High(args) do
    begin
      write(separator);
      print_var_rec(TVarRec(args[i]));
    end;
  end;

  if LineFeed then writeln;

  Result := True;
end;

function WritelnException(const func: string; e: Exception): Boolean;
begin
  writeln(func, '(', e.ClassName, '): ', e.Message);
  Result := True;
end;

function OutputDebugArray(const args: array of const; const separator: string;
  LineFeed: Boolean): Boolean;
var
  str: string;
  i: Integer;
  vr: TVarRec;
begin
  str := '';

  for i := Low(args) to High(args) do
  begin
    vr := TVarRec(args[i]);

    if i > Low(args) then
      str := str + separator;

    case vr.VType of
      vtInteger:    str := str + IntToStr(vr.VInteger);
      vtBoolean:    str := str + BoolToStr(vr.VBoolean, True);
      vtChar:       str := str + string(RawByteString(vr.VChar));
      vtExtended:   str := str + FloatToStr(vr.VExtended^);
      vtString:     str := str + string(vr.VString^);
      vtPointer:    str := Format('%.8x', [vr.VPointer]);
      vtPChar:      str := str + string(RawByteString(vr.VPChar));
      vtObject:     str := str + 'object(' + vr.VObject.ClassName + ')';

      vtClass:      str := str + 'class(' + vr.VClass.ClassName + ')';
      vtWideChar:   str := str + vr.VWideChar;
      vtPWideChar:  str := str + vr.VPWideChar;
      vtAnsiString: str := str + string(RawByteString(vr.VAnsiString));
      vtCurrency:   str := str + FloatToStr(vr.VCurrency^);
      vtVariant:    str := str + vr.VVariant^;
      vtInterface:  str := str + 'interface';
      vtUnicodeString: str := str + UnicodeString(vr.VUnicodeString);
      vtInt64:      str := str + IntToStr(vr.VInt64^);
    end;
  end;

  OutputDebugString(PChar(str));
  Result := True;
end;

function OutputDebugException(e: Exception): Boolean;
begin
  OutputDebugString(PChar(e.ClassName + ': ' + e.Message));
  Result := True;
end;

function OutputDebugException(const func: string; e: Exception): Boolean;
begin
  OutputDebugString(PChar(func + '(' + e.ClassName + '): ' + e.Message));
  Result := True;
end;

function DbgOutputException(e: Exception): Boolean;
begin
  if IsConsole then WritelnException(e)
  else OutputDebugException(e);
  Result := True;
end;

function DbgOutputException(const func: string; e: Exception): Boolean;
begin
  if IsConsole then  WritelnException(func, e)
  else OutputDebugException(func, e);
  Result := True;
end;

function DbgOutputA(const msg: RawByteString): Boolean;
begin
  if IsConsole then writeln(msg)
  else OutputDebugStringA(PAnsiChar(msg));
  Result := True;
end;

function DbgOutputW(const msg: UnicodeString): Boolean;
begin
  if IsConsole then writeln(msg)
  else OutputDebugStringW(PWideChar(msg));
  Result := True;
end;

function DbgOutput(const msg: string): Boolean;
begin
  if IsConsole then writeln(msg)
  else OutputDebugString(PChar(msg));
  Result := True;
end;

function DbgOutputArray(const args: array of const;
  const separator: string; LineFeed: Boolean): Boolean;
begin
  if IsConsole then PrintArray(args, separator, LineFeed)
  else OutputDebugArray(args, separator, LineFeed);
  Result := True;
end;

function DbgOutputFmtA(const fmt: RawByteString; const args: array of const): Boolean;
begin
  if IsConsole then writeln(AnsiStrings.Format(fmt, args))
  else OutputDebugStringA(PAnsiChar(AnsiStrings.Format(fmt, args)));
  Result := True;
end;

function DbgOutputFmtW(const fmt: UnicodeString; const args: array of const): Boolean;
begin
  if IsConsole then writeln(WideFormat(fmt, args))
  else OutputDebugStringW(PWideChar(WideFormat(fmt, args)));
  Result := True;
end;

function DbgOutputFmt(const fmt: string; const args: array of const): Boolean;
begin
  if IsConsole then writeln(Format(fmt, args))
  else OutputDebugString(PChar(Format(fmt, args)));
  Result := True;
end;

function BufToUnicodeTest(src: PAnsiChar; srclen: DWORD; CodePage: Integer): Integer;
begin
  Result := MultiByteToWideChar(CodePage, 0, src, srclen, nil, 0) - 1;
end;

function BufToUnicode(src: PAnsiChar; srclen: DWORD; dst: PWideChar; CodePage: Integer): Integer; overload;
begin
  Result := MultiByteToWideChar(CodePage, 0, src, srclen, dst, MaxInt) - 1;
end;

function BufToUnicode(src: PAnsiChar; srclen: DWORD; CodePage: Integer): UnicodeString; overload;
var
  L: Integer;
begin
  L := BufToUnicodeTest(src, srclen, CodePage);
  SetLength(Result, L);
  MultiByteToWideChar(CodePage, 0, src, srclen, PWideChar(Result), L + 1);
end;

procedure AnsiStrAssignWideChar(dst: PAnsiChar; c: WideChar; CodePage: Integer);
begin
  WideCharToMultiByte(CodePage, 0, @c, 1, dst, 3, nil, nil);
end;

function BufToMultiByteTest(src: PWideChar; srclen: DWORD; CodePage: Integer): Integer;
begin
  Result := WideCharToMultiByte(CodePage, 0, src, srclen, nil, 0, nil, nil);
end;

function BufToMultiByte(src: PWideChar; srclen: DWORD; dst: PAnsiChar; CodePage: Integer): Integer;
begin
  Result := WideCharToMultiByte(CodePage, 0, src, srclen, dst, srclen * 3, nil, nil);
end;

function BufToMultiByte(src: PWideChar; srclen: DWORD; CodePage: Integer): RawByteString;
begin
  SetLength(Result, srclen * 3);
  SetLength(Result, BufToMultiByte(src, srclen, PAnsiChar(Result), CodePage));
end;

function UStrToMultiByte(const src: UnicodeString; dst: PAnsiChar; CodePage: Integer): Integer;
begin
  Result := WideCharToMultiByte(CodePage, 0, PWideChar(src), Length(src), dst, Length(src) * 3, nil, nil);
end;

function UStrToMultiByte(const src: UnicodeString; CodePage: Integer): RawByteString;
begin
  SetLength(Result, Length(src) * 3);
  SetLength(Result, BufToMultiByte(PWideChar(src), Length(src), PAnsiChar(Result), CodePage));
end;

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
    else if BeginWithW(s + P2, len - P2, 'lt;', 3) then
    begin
      dst^ := '<'; Inc(P2, 3);
    end
    else if BeginWithW(s + P2, len - P2, 'gt;', 3) then
    begin
      dst^ := '>'; Inc(P2, 3);
    end
    else if BeginWithW(s + P2, len - P2, 'amp;', 4) then
    begin
      dst^ := '&'; Inc(P2, 4);
    end
    else if BeginWithW(s + P2, len - P2, 'apos;', 5) then
    begin
      dst^ := #39; Inc(P2, 5);
    end
    else if BeginWithW(s + P2, len - P2, 'quot;', 5) then
    begin
      dst^ := '"'; Inc(P2, 5);
    end
    else if BeginWithW(s + P2, len - P2, 'mdash;', 6) then
    begin
      dst^ := '—'; Inc(P2, 6);
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
    P3 := StrPosW('<input', 6, P3, strend - P3);

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

function ReplaceIfNotEqual(var dst: RawByteString; const src: RawByteString;
  pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then Result := False
  else begin
    dst := src;
    if Assigned(pEStayNETrue) then pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: UnicodeString; const src: UnicodeString;
  pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then Result := False
  else begin
    dst := src;
    if Assigned(pEStayNETrue) then pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: Integer; const src: Integer;
  pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then Result := False
  else begin
    dst := src;
    if Assigned(pEStayNETrue) then pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: Int64; const src: Int64;
  pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then Result := False
  else begin
    dst := src;
    if Assigned(pEStayNETrue) then pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: Double; const src: Double;
  pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then Result := False
  else begin
    dst := src;
    if Assigned(pEStayNETrue) then pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: Real; const src: Real;
  pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then Result := False
  else begin
    dst := src;
    if Assigned(pEStayNETrue) then pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: Boolean; const src: Boolean;
  pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then Result := False
  else begin
    dst := src;
    if Assigned(pEStayNETrue) then pEStayNETrue^ := True;
    Result := True;
  end;
end;

function UStrLen(const s: UnicodeString): Integer;
begin
  Result := Length(s);
end;

function BStrLen(const s: WideString): Integer;
begin
  Result := Length(s);
end;

function StrLenW(s: PWideChar): Integer;
begin
  Result := 0;

  if Assigned(s) then
  begin
    while (s^ <> #0) do
    begin
      Inc(Result);
      Inc(s);
    end;
  end;
end;

function RegisterCOMComponet(pFileName: PChar): Boolean;
var
  hLib: HMODULE;
  RegProc: function(): BOOL; stdcall;
begin
  Result := False;
  hLib := LoadLibrary(pFileName);

  if hLib = 0 then Exit;

  try
    RegProc := GetProcAddress(hLib, 'DllRegisterServer');

    if Assigned(RegProc) then
      RegProc;

    Result := True;
  finally
    FreeLibrary(hLib);
  end;
end;

function UrlExtractFileNameA(const url: RawByteString): RawByteString;
var
  i: Integer;
begin
  Result := '';
  for i := Length(url) downto 1 do
  begin
    if url[i] = '/' then
    begin
      Result := Copy(url, i + 1, Length(url) - i);
      Break;
    end;
  end;
end;

function HttpEncodeCStrTest(str: PAnsiChar; const non_conversions: RawByteString): Integer;
const
  HEX_SYMBOLS: RawByteString = '0123456789ABCDEF';
var
  Sp: PAnsiChar;
  found: Boolean;
  i: Integer;
begin
  Result := 0;
  Sp := str;

  while Sp^ <> #0 do
  begin
    if (Sp^ in ['0'..'9', 'A'..'Z', 'a'..'z']) then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    found := False;

    for i := 1 to Length(non_conversions) do
      if non_conversions[i] = Sp^ then
      begin
        found := True;
        Break;
      end;

    if found then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    if Sp^ = #32 then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    Inc(Sp);
    Inc(Result, 3);
  end;
end;

function HttpEncodeCStr2Buf(src, dst: PAnsiChar; const non_conversions: RawByteString): Integer;
const
  HEX_SYMBOLS: RawByteString = '0123456789ABCDEF';
var
  Sp, Rp: PAnsiChar;
  found: Boolean;
  i: Integer;
begin
  Sp := src;
  Rp := dst;

  while Sp^ <> #0 do
  begin
    if (Sp^ in ['0'..'9', 'A'..'Z', 'a'..'z']) then
    begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
      Continue;
    end;

    found := False;

    for i := 1 to Length(non_conversions) do
      if non_conversions[i] = Sp^ then
      begin
        found := True;
        Break;
      end;

    if found then
    begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
      Continue;
    end;

    if Sp^ = #32 then
    begin
      Rp^ := '+';
      Inc(Sp);
      Inc(Rp, 1);
      Continue;
    end;

    Rp[0] := '%';
    Rp[1] := HEX_SYMBOLS[PByte(Sp)^ shr 4 + 1];
    Rp[2] := HEX_SYMBOLS[PByte(Sp)^ and $0f + 1];
    Inc(Rp, 3);
    Inc(Sp);
  end;

  Result := Rp - dst;
end;

function HttpEncodeCStr(src: PAnsiChar; const non_conversions: RawByteString): RawByteString;
begin
  SetLength(Result, HttpEncodeCStrTest(src, non_conversions));
  HttpEncodeCStr2Buf(src, PAnsiChar(Result), non_conversions);
end;

function HttpEncodeBufTest(const buf; buflen: Integer;
  const non_conversions: RawByteString): Integer;
const
  HEX_SYMBOLS: RawByteString = '0123456789ABCDEF';
var
  Sp, buf_end: PAnsiChar;
  found: Boolean;
  i: Integer;
begin
  Result := 0;  
  Sp := PAnsiChar(@buf);
  buf_end := Sp + buflen;

  while Sp < buf_end do
  begin
    if (Sp^ in ['0'..'9', 'A'..'Z', 'a'..'z']) then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    found := False;

    for i := 1 to Length(non_conversions) do
      if non_conversions[i] = Sp^ then
      begin
        found := True;
        Break;
      end;

    if found then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    if Sp^ = #32 then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    Inc(Sp);
    Inc(Result, 3);
  end;
end;

function HttpEncodeBuf2Buf(const buf; buflen: Integer; dst: PAnsiChar;
  const non_conversions: RawByteString): Integer;
const
  HEX_SYMBOLS: RawByteString = '0123456789ABCDEF';
var
  Sp, Rp, buf_end: PAnsiChar;
  found: Boolean;
  i: Integer;
begin
  Sp := PAnsiChar(@buf);
  buf_end := Sp + buflen;
  Rp := dst;

  while Sp < buf_end do
  begin
    if (Sp^ in ['0'..'9', 'A'..'Z', 'a'..'z']) then
    begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
      Continue;
    end;

    found := False;

    for i := 1 to Length(non_conversions) do
      if non_conversions[i] = Sp^ then
      begin
        found := True;
        Break;
      end;

    if found then
    begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
      Continue;
    end;

    if Sp^ = #32 then
    begin
      Rp^ := '+';
      Inc(Sp);
      Inc(Rp, 1);
      Continue;
    end;

    Rp[0] := '%';
    Rp[1] := HEX_SYMBOLS[PByte(Sp)^ shr 4 + 1];
    Rp[2] := HEX_SYMBOLS[PByte(Sp)^ and $0f + 1];
    Inc(Rp, 3);
    Inc(Sp);
  end;

  Result := Rp - dst;
end;

function HttpEncodeBuf(const src; srclen: Integer;
  const non_conversions: RawByteString): RawByteString;
begin
  SetLength(Result, srclen * 3);

  SetLength(Result, HttpEncodeBuf2Buf(src, srclen, PAnsiChar(Result), non_conversions));
end;

function DSLHttpEncode(const src, non_conversions: RawByteString): RawByteString;
begin
  SetLength(Result, Length(src) * 3);

  SetLength(Result, HttpEncodeBuf2Buf(Pointer(src)^, Length(src),
    PAnsiChar(Result), non_conversions));
end;

function HttpDecodeBufTest(const buf; buflen: Integer; invalid: PPAnsiChar): Integer;
var
  Sp, Cp, buf_end: PAnsiChar;
begin
  Sp := PAnsiChar(@buf);
  buf_end := Sp + buflen;
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;


  while Sp <  buf_end do
  begin
    if Sp^ = '+' then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    if Sp^ = '%' then
    begin
      Inc(Sp);

      if Sp >= buf_end then
      begin
        if Assigned(invalid) then invalid^ := Sp - 1;
        Break;
      end;

      if Sp^ = '%' then
      begin
        Inc(Sp);
        Inc(Result);
        Continue;
      end;

      Cp := Sp;
      Inc(Sp);

      if Sp >= buf_end then
      begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      if not ( ( (Cp^ >= '0') and (Cp^ <= '9') ) or
        ( (Cp^ >= 'A') and (Cp^ <= 'Z') ) or
        ( (Cp^ >= 'a') and (Cp^ <= 'z') ) ) then
      begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      if not ( ( (Sp^ >= '0') and (Sp^ <= '9') ) or
        ( (Sp^ >= 'A') and (Sp^ <= 'Z') ) or
        ( (Sp^ >= 'a') and (Sp^ <= 'z') ) ) then
      begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      Inc(Sp);
      Inc(Result);
    end
    else begin
      Inc(Result);
      Inc(Sp);
    end;
  end;
end;

function HttpDecodeStrTest(const str: RawByteString; invalid: PPAnsiChar = nil): Integer;
begin
  Result := HttpDecodeBufTest(Pointer(str)^, Length(str), invalid);
end;

{$WARNINGS OFF}

function HttpDecodeBuf2Buf(const buf; buflen: Integer;
  dst: PAnsiChar; invalid: PPAnsiChar): Integer;
var
  Sp, Rp, Cp, buf_end: PAnsiChar;
  v: Integer;
begin
  Sp := PAnsiChar(@buf);
  buf_end := Sp + buflen;
  Rp := dst;
  
  if Assigned(invalid) then invalid^ := nil;

  while Sp <  buf_end do
  begin
    if Sp^ = '+' then
    begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
      Continue;
    end;

    if Sp^ = '%' then
    begin
      Inc(Sp);

      if Sp >= buf_end then
      begin
        if Assigned(invalid) then invalid^ := Sp - 1;
        Break;
      end;

      if Sp^ = '%' then
      begin
        Rp^ := '%';
        Inc(Sp);
        Inc(Rp);
        Continue;
      end;

      Cp := Sp;
      Inc(Sp);

      if Sp >= buf_end then
      begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;
      
      if (Cp^ >= '0') and (Cp^ <= '9') then v := (Ord(Cp^) - 48) shl 4
      else if (Cp^ >= 'A') and (Cp^ <= 'Z') then v := (Ord(Cp^) - 55) shl 4
      else if (Cp^ >= 'a') and (Cp^ <= 'z') then v := (Ord(Cp^) - 87) shl 4
      else begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      if (Sp^ >= '0') and (Sp^ <= '9') then Inc(v, Ord(Sp^) - 48)
      else if (Cp^ >= 'A') and (Cp^ <= 'Z') then Inc(v, Ord(Sp^) - 55)
      else if (Cp^ >= 'a') and (Cp^ <= 'z') then Inc(v, Ord(Sp^) - 87)
      else begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      PByte(Rp)^ := v;
      Inc(Sp);
      Inc(Rp);
    end
    else begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
    end;
  end;

  Result := Rp - dst;
end;

{$WARNINGS ON}

function HttpDecodeBuf(const buf; buflen: Integer; invalid: PPAnsiChar): RawByteString;
var
  _invalid: PAnsiChar;
  L: Integer;
begin
  SetLength(Result, buflen);
  L := HttpDecodeBuf2Buf(buf, buflen, PAnsiChar(Result), @_invalid);

  if Assigned(invalid) then invalid^ := _invalid;

  if Assigned(_invalid) then Result := ''
  else SetLength(Result, L);
end;

function DSLHttpDecode(const src: RawByteString; invalid: PPAnsiChar): RawByteString;
begin
  Result := HttpDecodeBuf(Pointer(src)^, Length(src));
end;

function HttpDecodeCStrTest(src: PAnsiChar; invalid: PPAnsiChar): Integer;
var
  Sp, Cp: PAnsiChar;
begin
  Sp := PAnsiChar(src);
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;


  while Sp^ <> #0 do
  begin
    if Sp^ = '+' then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    if Sp^ = '%' then
    begin
      Inc(Sp);

      if Sp^ = #0 then
      begin
        if Assigned(invalid) then invalid^ := Sp - 1;
        Break;
      end;

      if Sp^ = '%' then
      begin
        Inc(Sp);
        Inc(Result);
        Continue;
      end;

      Cp := Sp;
      Inc(Sp);

      if Sp^ = #0 then
      begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      if not ( ( (Cp^ >= '0') and (Cp^ <= '9') ) or
        ( (Cp^ >= 'A') and (Cp^ <= 'Z') ) or
        ( (Cp^ >= 'a') and (Cp^ <= 'z') ) ) then
      begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      if not ( ( (Sp^ >= '0') and (Sp^ <= '9') ) or
        ( (Sp^ >= 'A') and (Sp^ <= 'Z') ) or
        ( (Sp^ >= 'a') and (Sp^ <= 'z') ) ) then
      begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      Inc(Sp);
      Inc(Result);
    end
    else begin
      Inc(Result);
      Inc(Sp);
    end;
  end;
end;

{$WARNINGS OFF}

function HttpDecodeCStr2Buf(str, dst: PAnsiChar; invalid: PPAnsiChar): Integer;
var
  Sp, Rp, Cp: PAnsiChar;
  v: Integer;
begin
  Sp := PAnsiChar(str);
  Rp := dst;
  
  if Assigned(invalid) then invalid^ := nil;

  while Sp^ <> #0 do
  begin
    if Sp^ = '+' then
    begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
      Continue;
    end;

    if Sp^ = '%' then
    begin
      Inc(Sp);

      if Sp^ = #0 then
      begin
        if Assigned(invalid) then invalid^ := Sp - 1;
        Break;
      end;

      if Sp^ = '%' then
      begin
        Rp^ := '%';
        Inc(Sp);
        Inc(Rp);
        Continue;
      end;

      Cp := Sp;
      Inc(Sp);

      if Sp^ = #0 then
      begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;
      
      if (Cp^ >= '0') and (Cp^ <= '9') then v := (Ord(Cp^) - 48) shl 4
      else if (Cp^ >= 'A') and (Cp^ <= 'Z') then v := (Ord(Cp^) - 55) shl 4
      else if (Cp^ >= 'a') and (Cp^ <= 'z') then v := (Ord(Cp^) - 87) shl 4
      else begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      if (Sp^ >= '0') and (Sp^ <= '9') then Inc(v, Ord(Sp^) - 48)
      else if (Cp^ >= 'A') and (Cp^ <= 'Z') then Inc(v, Ord(Sp^) - 55)
      else if (Cp^ >= 'a') and (Cp^ <= 'z') then Inc(v, Ord(Sp^) - 87)
      else begin
        if Assigned(invalid) then invalid^ := Sp - 2;
        Break;
      end;

      PByte(Rp)^ := v;
      Inc(Sp);
      Inc(Rp);
    end
    else begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
    end;
  end;

  Result := Rp - dst;
end;

function HttpDecodeCStr(str: PAnsiChar; invalid: PPAnsiChar = nil): RawByteString;
var
  _invalid: PAnsiChar;
  L: Integer;
begin
  L := HttpDecodeCStrTest(str, @_invalid);

  if Assigned(invalid) then invalid^ := _invalid;

  if Assigned(_invalid) then Result := ''
  else begin
    SetLength(Result, L);
    HttpDecodeCStr2Buf(str, PAnsiChar(Result), nil);
  end;
end;

{$WARNINGS ON}

function UrlExtractPathA(const url: RawByteString): RawByteString;
var
  p, i: Integer;
begin
  Result := '';
  p := StrPosA('://', url);

  if p <= 0 then
    p := 1
  else
    Inc(p, 3);

  for i := p to Length(url) do
  begin
    if url[i] = '/' then
    begin
      Result := Copy(url, i, Length(url) + 1 - i);
      Break;
    end;
  end;
end;

function UrlExtractPathW(const url: UnicodeString): UnicodeString;
var
  p, i: Integer;
begin
  Result := '';
  p := UStrPos('://', url);

  if p <= 0 then
    p := 1
  else
    Inc(p, 3);

  for i := p to Length(url) do
  begin
    if url[i] = '/' then
    begin
      Result := Copy(url, i, Length(url) + 1 - i);
      Break;
    end;
  end;
end;

function CloneList(src: TList): TList;
begin
  if src = nil then
    Result := nil
  else begin
    Result := TList.Create;
    Result.Count := src.Count;

    if Result.Count > 0 then
      Move(src.List[0], Result.List[0], SizeOf(Pointer) * src.Count);
  end;
end;

procedure NavigateWithDefaultBrowser(const url: string);
begin
  ShellExecute(0, 'open', PChar(url), nil, nil, SW_SHOW) //弹出对话窗口
end;

function Res2StrA(const ResName: string; const ResType: string): RawByteString;
var
  rs: TResourceStream;
begin
  rs := TResourceStream.Create(HInstance, ResName, PChar(ResType));

  try
    SetLength(Result, rs.Size);

    rs.Seek(0, soFromBeginning);

    rs.ReadBuffer(Pointer(Result)^, rs.Size);

  finally
    rs.Free;
  end;
end;

procedure SaveResToFile(const ResName, ResType, SavePath: string);
//函数功能：获取图标资源
//返回类型：TBitmap
//参数作用：
//         resname 资源名称
//         restype 资源类型
var
  Res: TResourceStream;
begin
  res := TResourceStream.Create(HInstance, PChar(ResName), PChar(ResType));
  try
    Res.SaveToFile(SavePath);
  finally
    res.Free;
  end;
end;

function StrToBoolA(const s: string; def: Boolean): Boolean;
begin
  if SameText(s, 'false') or (s = '0') then
    Result := False
  else if SameText(s, 'true') or (s = '1') then
    Result := True
  else
    Result := def;
end;

function RunningInMainThread: Boolean;
begin
  Result := GetCurrentThreadId = MainThreadID;
end;

//获取url参数

function UrlGetParamA(const url, name: RawByteString): RawByteString;
begin
  Result := GetSubstrBetweenA(url, '?' + name + '=', ['&']);

  if Result = '' then
    Result := GetSubstrBetweenA(url, '&' + name + '=', ['&']);
end;

function UStrUrlGetParam(const url, name: UnicodeString): UnicodeString;
begin
  Result := GetSubstrBetweenW(url, '?' + name + '=', ['&']);

  if Result = '' then
    Result := GetSubstrBetweenW(url, '&' + name + '=', ['&']);
end;

function BStrUrlGetParam(const url, name: WideString): WideString;
begin
  Result := GetSubstrBetweenW(url, '?' + name + '=', ['&']);

  if Result = '' then
    Result := GetSubstrBetweenW(url, '&' + name + '=', ['&']);
end;

procedure dir_list(const ParentDir: string; strs: TStrings);
var
  sr: TSearchRec;
  n: Integer;
  filter: string;
begin
  if ParentDir = '' then Exit;

  if ParentDir[Length(ParentDir)] = '\' then filter := ParentDir + '*.*'
  else filter := ParentDir + '\*.*';

  if SysUtils.FindFirst(filter, faAnyFile, sr) <> 0 then Exit;

  n := 0;

  repeat
    if (sr.Name <> '.') and (sr.Name <> '..') and (SR.Attr and faDirectory <> 0) then
    begin
      strs.Add(sr.Name);
      Inc(n);
    end;
  until (n >= 1000) or (SysUtils.FindNext(sr) <> 0);

  SysUtils.FindClose(sr);
end;

procedure SafeForceDirectories(const dir: string);
begin
  try
    ForceDirectories(dir);
  except
  end;
end;

procedure SaveBufToFile(const FileName: string; buf: Pointer; len: Integer);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmCreate);
  try
    fs.WriteBuffer(buf^, len);
  finally
    fs.Free;
  end;
end;

procedure SaveStrToFile(const FileName: string; const str: RawByteString);
begin
  SaveBufToFile(FileName, Pointer(str), Length(str));
end;

function SafeSaveStrToFile(const FileName: string; const str: RawByteString): Boolean;
begin
  try
    SaveBufToFile(FileName, Pointer(str), Length(str));
    Result := True;
  except
    Result := False;
  end;
end;

procedure SaveStrsToFile(const FileName: string; const strs: array of RawByteString);
var
  fs: TFileStream;
  i: Integer;
begin
  fs := TFileStream.Create(FileName, fmCreate);
  try
    for i := Low(strs) to High(strs) do
      fs.WriteBuffer(Pointer(strs[i])^, Length(strs[i]));
  finally
    fs.Free;
  end;
end;

function SafeSaveStrsToFile(const FileName: string; const strs: array of RawByteString): Boolean;
begin
  try
    SaveStrsToFile(FileName, strs);
    Result := True;
  except
    Result := False;
  end;
end;

function LoadStrFromFile(const FileName: string): RawByteString;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmOpenRead);

  try
    SetLength(Result, fs.Size);
    fs.ReadBuffer(Pointer(Result)^, Length(Result));
  finally
    fs.Free;
  end;
end;

function Stream2String(stream: TStream): RawByteString;
begin
  SetLength(Result, stream.Size - stream.Position);
  stream.ReadBuffer(Pointer(Result)^, Length(Result));
end;

procedure UTF8EncodeFile(const FileName: string);
var
  s: UTF8String;
begin
  s := UTF8EncodeUStr(UnicodeString(LoadStrFromFile(FileName)));
  SaveBufToFile(FileName, Pointer(s), Length(s));
end;

procedure UTF8DecodeFile(const FileName: string);
var
  s: UnicodeString;
begin
  s := UTF8DecodeStr(LoadStrFromFile(FileName));
  SaveBufToFile(FileName, Pointer(s), Length(s) * 2);
end;

procedure HttpEncodeFile(const FileName: string);
var
  s: RawByteString;
begin
  s := DSLHttpEncode(LoadStrFromFile(FileName));
  SaveStrToFile(FileName, s);
end;

procedure HttpDecodeFile(const FileName: string);
var
  s: RawByteString;
begin
  s := DSLHttpDecode(LoadStrFromFile(FileName));
  SaveStrToFile(FileName, s);
end;

function FormatSysTime(const st: TSystemTime; const fmt: string): string;
begin
  Result := Format('%d_%d_%d_%d_%d_%d', [st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond]); 
end;

function FormatSysTimeNow(const fmt: string): string;
var
  st: TSystemTime;
begin 
  GetLocalTime(st);
  Result := FormatSysTime(st, fmt);
end;

function SameHour(former, later: TDateTime): Boolean;
begin
  Result := Trunc(later * HoursPerDay) = Trunc(former * HoursPerDay);
end;

function SameDay(former, later: TDateTime): Boolean;
begin
  Result := Trunc(later) = Trunc(former);
end;

function SameMonth(former, later: TDateTime): Boolean;
var
  year, month, day, hour, minute, second, msec, year2, month2: Word;
begin
  DecodeDateTime(former, year, month, day, hour, minute, second, msec);
  DecodeDateTime(later, year2, month2, day, hour, minute, second, msec);
  Result := (year = year2) and (month = month2);
end;

function SameYear(former, Later: TDateTime): Boolean;
var
  year, month, day, hour, minute, second, msec, year2: Word;
begin
  DecodeDateTime(former, year, month, day, hour, minute, second, msec);
  DecodeDateTime(later, year2, month, day, hour, minute, second, msec);
  Result := (year = year2);
end;

procedure SystemTimeIncMilliSeconds(var st: TSystemTime; value: Int64);
var
  dt: TDateTime;
begin
  dt := EncodeDateTime(st.wYear, st.wMonth, st.wDay, st.wHour,
    st.wMinute, st.wSecond, st.wMilliseconds);

  DecodeDateTime(IncMilliSecond(dt, value), st.wYear, st.wMonth, st.wDay,
    st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);
end;

procedure SystemTimeIncSeconds(var st: TSystemTime; value: Int64);
var
  dt: TDateTime;
begin
  dt := EncodeDateTime(st.wYear, st.wMonth, st.wDay, st.wHour,
    st.wMinute, st.wSecond, st.wMilliseconds);

  DecodeDateTime(IncSecond(dt, value), st.wYear, st.wMonth, st.wDay,
    st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);
end;

procedure SystemTimeIncMinutes(var st: TSystemTime; value: Integer);
begin
end;

procedure SystemTimeIncHours(var st: TSystemTime; value: Integer);
begin
end;

procedure SystemTimeIncDays(var st: TSystemTime; value: Integer);
begin
end;

procedure SystemTimeIncMonths(var st: TSystemTime; value: Integer);
begin
end;

procedure SystemTimeIncYears(var st: TSystemTime; value: Integer);
begin

end;

function UTCNow: TDateTime;
var
  utcdt: TSystemTime;
begin
  GetSystemTime(utcdt);
  with utcdt do
    Result := EncodeDate(wYear, wMonth, wDay) +
      EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
end;

function UTCToLocal(dt: TDateTime): TDateTime;
var
  tzi: TTimeZoneInformation;
begin
  GetTimeZoneInformation(tzi);

  Result := IncMinute(dt, -tzi.Bias);
end;

function UTCLocalDiff: Integer;
var
  tzi: TTimeZoneInformation;
begin
  GetTimeZoneInformation(tzi);
  Result := -tzi.Bias;
end;

function DateTimeToJava(d: TDateTime): Int64;
begin
  Result := MilliSecondsBetween(d, JAVA_TIME_START);
end;

function JavaToDateTime(t: Int64): TDateTime;
var
  d1, d2: Double;
begin
  d1 := t;
  d2 := MSecsPerDay;
  Result := JAVA_TIME_START + d1 / d2;
end;

function RandomStringA(CharSet: RawByteString; CharCount: Integer): RawByteString;
var
  I: Integer;
  pch: PAnsiChar;
begin
  SetLength(Result, CharCount);
  pch := PAnsiChar(Result);
  for I := 0 to CharCount - 1 do
    pch[I] := CharSet[Random(Length(CharSet)) + 1];
end;

function RandomAlphaStringA(CharCount: Integer; types: DSLCharTypes): RawByteString;
var
  charset: RawByteString;
begin
  if chAlphaUpperCase in types then
  begin
    if chAlphaLowerCase in types then
      charset := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    else
      charset := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  end
  else
    charset := 'abcdefghjklmnopqrstuvwxyz';

  Result := RandomStringA(charset, CharCount);
end;

function RandomDigitStringA(CharCount: Integer): RawByteString;
begin
  Result := RandomStringA('0123456789', CharCount);
end;

function RandomAlphaDigitStringA(CharCount: Integer; types: DSLCharTypes): RawByteString;
var
  charset: RawByteString;
begin
  if chAlphaUpperCase in types then
  begin
    if chAlphaLowerCase in types then
      charset := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    else
      charset := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  end
  else
    charset := 'abcdefghjklmnopqrstuvwxyz0123456789';

  Result := RandomStringA(charset, CharCount);
end;

function RandomStringW(CharSet: UnicodeString; CharCount: Integer): UnicodeString;
var
  I: Integer;
  pch: PWideChar;
begin
  SetLength(Result, CharCount);
  pch := PWideChar(Result);
  for I := 0 to CharCount - 1 do
    pch[I] := CharSet[Random(Length(CharSet)) + 1];
end;

function RandomAlphaStringW(CharCount: Integer; types: DSLCharTypes): UnicodeString;
var
  charset: UnicodeString;
begin
  if chAlphaUpperCase in types then
  begin
    if chAlphaLowerCase in types then
      charset := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    else
      charset := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  end
  else
    charset := 'abcdefghjklmnopqrstuvwxyz';

  Result := RandomStringW(charset, CharCount);
end;

function RandomDigitStringW(CharCount: Integer): UnicodeString;
begin
  Result := RandomStringW('0123456789', CharCount);
end;

function RandomAlphaDigitStringW(CharCount: Integer; types: DSLCharTypes): UnicodeString;
var
  charset: UnicodeString;
begin
  if chAlphaUpperCase in types then
  begin
    if chAlphaLowerCase in types then
      charset := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    else
      charset := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  end
  else
    charset := 'abcdefghjklmnopqrstuvwxyz0123456789';

  Result := RandomStringW(charset, CharCount);
end;

function RandomCNMobile: RawByteString;
const
  SAPrefix: array[0..29] of RawByteString = ('134', '135', '136', '137', '138',
    '139', '147', '150', '151', '152', '157', '158', '159', '182', '183',
    '187', '188', '130', '131', '132', '155', '156', '185', '186', '145',
    '133', '153', '189', '180', '181');
var
  prefix: RawByteString;
  i: Integer;
begin
  prefix := SAPrefix[Random(Length(SAPrefix))];
  SetLength(Result, 11);
  PAnsiChar(Result)[0] := prefix[1];
  PAnsiChar(Result)[1] := prefix[2];
  PAnsiChar(Result)[2] := prefix[3];

  for i := 3 to Length(Result) - 1 do
    PAnsiChar(Result)[i] := AnsiChar(Ord('0') + Random(10));
end;

function UTF8EncodeBufferTest(src: PWideChar; srclen: Integer): Integer;
var
  i: Integer;
  c: Word;
begin
  Result := 0;

  if src = nil then Exit;

  for i := 0 to srclen - 1 do
  begin
    c := Word(src[i]);

    if c > $7F then
    begin
      if c > $7FF then Inc(Result);
      Inc(Result);
    end;

    Inc(Result);
  end;
end;

function UTF8EncodeCStrTest(src: PWideChar): Integer;
var
  c: Word;
begin
  Result := 0;

  if src = nil then Exit;

  while src^ <> #0 do
  begin
    c := Word(src^);

    if c > $7F then
    begin
      if c > $7FF then Inc(Result);
      Inc(Result);
    end;

    Inc(Result);

    Inc(src);
  end;
end;

function UTF8EncodeBuffer(src: PWideChar; srclen: Integer; dest: PAnsiChar): Integer;
var
  i: Integer;
  c: Word;
begin
  Result := 0;

  if src = nil then Exit;

  for i := 0 to srclen - 1 do
  begin
    c := Word(src[i]);

    if c <= $7F then
    begin
      dest[Result] := AnsiChar(c);
      Inc(Result);
    end
    else if c > $7FF then
    begin
      dest[Result] := AnsiChar($E0 or (c shr 12));
      dest[Result + 1] := AnsiChar($80 or ((c shr 6) and $3F));
      dest[Result + 2] := AnsiChar($80 or (c and $3F));
      Inc(Result, 3);
    end
    else begin
      dest[Result] := AnsiChar($C0 or (c shr 6));
      dest[Result + 1] := AnsiChar($80 or (c and $3F));
      Inc(Result, 2);
    end;
  end;
end;

function UTF8EncodeCStr(src: PWideChar; dest: PAnsiChar): Integer;
var
  c: Word;
begin
  Result := 0;

  if src = nil then Exit;

  while src^ <> #0 do
  begin
    c := Word(src^);

    if c <= $7F then
    begin
      dest[Result] := AnsiChar(c);
      Inc(Result);
    end
    else if c > $7FF then
    begin
      dest[Result] := AnsiChar($E0 or (c shr 12));
      dest[Result + 1] := AnsiChar($80 or ((c shr 6) and $3F));
      dest[Result + 2] := AnsiChar($80 or (c and $3F));
      Inc(Result, 3);
    end
    else begin
      dest[Result] := AnsiChar($C0 or (c shr 6));
      dest[Result + 1] := AnsiChar($80 or (c and $3F));
      Inc(Result, 2);
    end;

    Inc(src);
  end;
end;

function UTF8EncodeCStr(src: PWideChar): RawByteString; overload;
var
  L: Integer;
begin
  L := UTF8EncodeCStrTest(src);

  SetLength(Result, L);

  UTF8EncodeCStr(src, PAnsiChar(Result));
end;

function UTF8EncodeBuffer(src: PWideChar; srclen: Integer): UTF8String;
begin
  SetLength(Result, srclen * 3);

  SetLength(Result, UTF8EncodeBuffer(src, srclen, PAnsiChar(Result)));
end;

function UTF8EncodeUStr(const src: UnicodeString; dest: PAnsiChar): Integer;
begin
  Result := UTF8EncodeBuffer(PWideChar(src), Length(src), dest);
end;

function UTF8EncodeBStr(const src: WideString; dest: PAnsiChar): Integer;
begin
  Result := UTF8EncodeBuffer(PWideChar(src), Length(src), dest);
end;

function UTF8EncodeUStr(const src: UnicodeString): UTF8String;
begin
  SetLength(Result, Length(src) * 3);

  SetLength(Result, UTF8EncodeBuffer(PWideChar(src), Length(src), PAnsiChar(Result)));
end;

function UTF8EncodeBStr(const src: WideString): UTF8String;
begin
  SetLength(Result, Length(src) * 3);

  SetLength(Result, UTF8EncodeBuffer(PWideChar(src), Length(src), PAnsiChar(Result)));
end;

function UTF8DecodeBufferTest(src: PAnsiChar; srclen: Integer; invalid: PPAnsiChar): Integer;
var
  i: Integer;
  c: Byte;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;

  i := 0;

  while i < srclen do
  begin
    c := PByte(src + i)^;
    Inc(i);

    if c and $80 <> 0 then
    begin
      // incomplete multibyte char
      if i >= srclen then
      begin
        if Assigned(invalid) then invalid^ := src + i - 1;

        Exit;
      end;

      c := c and $3F;

      if c and $20 <> 0 then
      begin
        c := PByte(src + i)^;
        Inc(i);

        (* malformed trail byte or out of range char *)
        if c and $C0 <> $80 then
        begin
          if Assigned(invalid) then invalid^ := src + i - 2;
          Exit;
        end;

        (* incomplete multibyte char *)
        if i >= srclen then
        begin
          if Assigned(invalid) then invalid^ := src + i - 2;
          Exit;
        end;
      end;

      c := PByte(src + i)^;
      Inc(i);

      (* malformed trail byte *)
      if (c and $C0) <> $80 then
      begin
        if Assigned(invalid) then invalid^ := src + i - 3;
        Exit;
      end;
    end;

    Inc(Result);
  end;
end;

function UTF8DecodeCStrTest(src: PAnsiChar; invalid: PPAnsiChar): Integer;
var
  c: Byte;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;

  while src^ <> #0 do
  begin
    c := PByte(src)^;
    Inc(src);

    if c and $80 <> 0 then
    begin
      // incomplete multibyte char
      if src^ = #0 then
      begin
        if Assigned(invalid) then invalid^ := src - 1;

        Exit;
      end;

      c := c and $3F;

      if c and $20 <> 0 then
      begin
        c := PByte(src)^;
        Inc(src);

        (* malformed trail byte or out of range char *)
        if c and $C0 <> $80 then
        begin
          if Assigned(invalid) then invalid^ := src - 2;
          Exit;
        end;

        (* incomplete multibyte char *)
        if src^ = #0 then
        begin
          if Assigned(invalid) then invalid^ := src - 2;
          Exit;
        end;
      end;

      c := PByte(src)^;
      Inc(src);

      (* malformed trail byte *)
      if (c and $C0) <> $80 then
      begin
        if Assigned(invalid) then invalid^ := src - 3;
        Exit;
      end;
    end;

    Inc(Result);
  end;
end;

function UTF8DecodeBuffer(src: PAnsiChar; srclen: Integer; dest: PWideChar;
  invalid: PPAnsiChar): Integer;
var
  i: Integer;
  c: Byte;
  wc: Word;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;

  i := 0;

  while i < srclen  do
  begin
    wc := PByte(src + i)^;
    Inc(i);

    if wc and $80 <> 0 then
    begin
      (* incomplete multibyte char *)
      if i >= SrcLen then
      begin
        if Assigned(invalid) then invalid^ := src + i - 1;
        Exit;
      end;

      wc := wc and $3F;

      if wc and $20 <> 0 then
      begin
        c := PByte(src + i)^;
        Inc(i);

        (* malformed trail byte or out of range char *)
        if c and $C0 <> $80 then
        begin
          if Assigned(invalid) then invalid^ := src + i - 2;
          Exit;
        end;

        (* incomplete multibyte char *)
        if i >= srclen then
        begin
          if Assigned(invalid) then invalid^ := src + i - 2;
          Exit;
        end;

        wc := (wc shl 6) or (c and $3F);
      end;

      c := PByte(src + i)^;
      Inc(i);

      if c and $C0 <> $80 then
      begin
        if Assigned(invalid) then invalid^ := src + i - 3;
        Exit;
      end;

      (* malformed trail byte *)
      dest[Result] := WideChar((wc shl 6) or (c and $3F));
    end
    else
      dest[Result] := WideChar(wc);

    Inc(Result);
  end;
end;

function UTF8DecodeCStr(src: PAnsiChar; dest: PWideChar; invalid: PPAnsiChar): Integer;
var
  c: Byte;
  wc: Word;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;

  while src^ <> #0 do
  begin
    wc := PByte(src)^;
    Inc(src);

    if wc and $80 <> 0 then
    begin
      (* incomplete multibyte char *)
      if src^ = #0 then
      begin
        if Assigned(invalid) then invalid^ := src - 1;
        Exit;
      end;

      wc := wc and $3F;

      if wc and $20 <> 0 then
      begin
        c := PByte(src)^;
        Inc(src);

        (* malformed trail byte or out of range char *)
        if c and $C0 <> $80 then
        begin
          if Assigned(invalid) then invalid^ := src - 2;
          Exit;
        end;

        (* incomplete multibyte char *)
        if src^ = #0 then
        begin
          if Assigned(invalid) then invalid^ := src - 2;
          Exit;
        end;

        wc := (wc shl 6) or (c and $3F);
      end;

      c := PByte(src)^;
      Inc(src);

      if c and $C0 <> $80 then
      begin
        if Assigned(invalid) then invalid^ := src - 3;
        Exit;
      end;

      (* malformed trail byte *)
      dest[Result] := WideChar((wc shl 6) or (c and $3F));
    end
    else
      dest[Result] := WideChar(wc);

    Inc(Result);
  end;
end;

function UTF8DecodeBuffer(src: PAnsiChar; srclen: Integer; invalid: PPAnsiChar): UnicodeString;
begin
  SetLength(Result, Length(src));
  SetLength(Result, UTF8DecodeBuffer(src, srclen, PWideChar(Result), invalid));
end;

function UTF8DecodeCStr(src: PAnsiChar; invalid: PPAnsiChar): UnicodeString;
var
  L: Integer;
  _invalid: PAnsiChar;
begin
  L := UTF8DecodeCStrTest(src, @_invalid);

  if Assigned(_invalid) then
  begin
    if Assigned(invalid) then invalid^ := _invalid;
    Result := '';
  end
  else begin
    SetLength(Result, L);
    SetLength(Result, UTF8DecodeCStr(src, PWideChar(Result), invalid));
  end;
end;

function UTF8DecodeStr(const src: RawByteString; dest: PWideChar; invalid: PPAnsiChar): Integer;
begin
  Result := UTF8DecodeBuffer(PAnsiChar(src), Length(src), dest, invalid);
end;

function UTF8DecodeStr(const src: RawByteString; invalid: PPAnsiChar): UnicodeString;
begin
  SetLength(Result, Length(src));
  SetLength(Result, UTF8DecodeBuffer(PAnsiChar(src), Length(src), PWideChar(Result), invalid));
end;

function StrIsEmptyA(const s: RawByteString): Boolean;
var
  i: Integer;
begin
  Result := True;

  for i := 1 to Length(s) do
  begin
    if Ord(s[i]) > 32 then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function UStrIsEmpty(const s: UnicodeString): Boolean;
var
  i: Integer;
begin
  Result := True;

  for i := 1 to Length(s) do
  begin
    if Ord(s[i]) > 32 then
    begin
      Result := False;
      Break;
    end;
  end;
end;

procedure StrUpperW(str: PWideChar; len: Integer);
var
  i: Integer;
  ch: WideChar;
begin
  for i := 0 to len - 1 do
  begin
    ch := str[i];

    if (ch >= 'a') and (ch <= 'z') then
      str[i] := WideChar(Ord(ch) - 32);
  end;
end;

procedure UStrUpper(const str: UnicodeString);
begin
  StrUpperW(PWideChar(str), Length(str));
end;

procedure BStrUpper(const str: WideString);
begin
  StrUpperW(PWideChar(str), Length(str));
end;

procedure StrLowerW(str: PWideChar; len: Integer);
var
  i: Integer;
  ch: WideChar;
begin
  for i := 0 to len - 1 do
  begin
    ch := str[i];

    if (ch >= 'A') and (ch <= 'Z') then
      str[i] := WideChar(Ord(ch) + 32);
  end;
end;

procedure UStrLower(const str: UnicodeString);
begin
  StrLowerW(PWideChar(str), Length(str));
end;

procedure BStrLower(const str: WideString);
begin
  StrLowerW(PWideChar(str), Length(str));
end;

procedure StrUpperA(str: PAnsiChar; len: Integer);
var
  i: Integer;
  ch: AnsiChar;
begin
  for i := 0 to len - 1 do
  begin
    ch := str[i];

    if (ch >= 'a') and (ch <= 'z') then
      str[i] := AnsiChar(Ord(ch) - 32);
  end;
end;

procedure StrUpperA(const str: RawByteString); overload;
begin
  StrUpperA(PAnsiChar(str), Length(str));
end;

procedure StrLowerA(str: PAnsiChar; len: Integer);
var
  i: Integer;
  ch: AnsiChar;
begin
  for i := 0 to len - 1 do
  begin
    ch := str[i];

    if (ch >= 'A') and (ch <= 'Z') then
      str[i] := AnsiChar(Ord(ch) + 32);
  end;
end;

procedure StrLowerA(const str: RawByteString);
begin
  StrLowerA(PAnsiChar(str), Length(str));
end;

procedure DSLSetStringA(var s: RawByteString; _begin, _end: PAnsiChar);
begin
  if not Assigned(_begin) or not Assigned(_end) or (_end = _begin) then s := ''
  else SetString(s, _begin, _end - _begin);
end;

procedure DSLSetStringW(var s: UnicodeString; _begin, _end: PWideChar);
begin
  if not Assigned(_begin) or not Assigned(_end) or (_end = _begin) then s := ''
  else SetString(s, _begin, _end - _begin);
end;

function MemHex(const Buffer; Size: Integer; UpperCase: Boolean): RawByteString;
const
  HEXADECIMAL_CHARS: array[0..31] of AnsiChar =
  ('0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  i: LongWord;
  h, l: Byte;
begin
  SetLength(Result, Size * 2);

  for i := 0 to Size - 1 do
  begin
    h := PByte(Pointer(LongWord(@Buffer) + i))^ shr 4;
    l := PByte(Pointer(LongWord(@Buffer) + i))^ and $0F;

    if UpperCase then
    begin
      Inc(h, 16);
      Inc(l, 16);
    end;

    PAnsiChar(Result)[2 * i] := HEXADECIMAL_CHARS[h];

    PAnsiChar(Result)[2 * i + 1] := HEXADECIMAL_CHARS[l];
  end;
end;

function HexStrToIntA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Integer;
var
  ptr, tail: PAnsiChar;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;
  tail := buf + len;
  ptr := Buf;

  while ptr < tail do
  begin
    case ptr^ of
      '0'..'9': Result := Result shl 4 + Ord(ptr^) - Ord('0');
      'A'..'F': Result := Result shl 4 + Ord(ptr^) - Ord('A') + 10;
      'a'..'f': Result := Result shl 4 + Ord(ptr^) - Ord('a') + 10;
      ',':;
    else begin
        if Assigned(invalid) then invalid^ := ptr;
        Break;
      end;
    end;

    Inc(ptr);
  end;
end;

function DecimalStrToIntA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Integer;
var
  ptr, tail: PAnsiChar;
  bit: Integer;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;
  tail := buf + len;
  ptr := Buf;

  while ptr < tail do
  begin
    bit := Ord(ptr^) - $30;

    if (bit >= 0) and (bit <= 9) then
      Result := Result * 10 + bit
    else begin
      if Assigned(invalid) then invalid^ := ptr;
      Break;
    end;

    Inc(ptr);
  end;
end;

function BufToIntA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Integer;
var
  sign: Integer;
begin
  Result := 0;

  if Assigned(invalid) then invalid^ := nil;

  if not Assigned(buf) or (len = 0) then Exit;

  sign := 1;

  if buf[0] = '-' then
  begin
    sign := -1;
    Inc(buf);
    Dec(len);
  end
  else if buf[0] = '+' then
  begin
    Inc(buf);
    Dec(len);
  end;

  if len <= 0 then Exit;

  if buf[0] = '$' then
    Result := sign * HexStrToIntA(buf + 1, len - 1, invalid)
  else
    Result := sign * DecimalStrToIntA(buf, len, invalid);
end;

function StrToIntA(const str: RawByteString): Integer;
var
  c: PAnsiChar;
begin
  Result := BufToIntA(PAnsiChar(str), Length(str), @c);
end;

function HexStrToInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Int64;
var
  ptr, tail: PAnsiChar;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;
  tail := buf + len;
  ptr := Buf;

  while ptr < tail do
  begin
    case ptr^ of
      '0'..'9': Result := Result shl 4 + Ord(ptr^) - Ord('0');
      'A'..'F': Result := Result shl 4 + Ord(ptr^) - Ord('A') + 10;
      'a'..'f': Result := Result shl 4 + Ord(ptr^) - Ord('a') + 10;
      ',': ;
    else begin
        if Assigned(invalid) then invalid^ := ptr;
        Break;
      end;
    end;

    Inc(ptr);
  end;
end;

function DecimalStrToInt64A(buf: PAnsiChar; len: Integer;
  invalid: PPAnsiChar): Int64;
var
  ptr, tail: PAnsiChar;
  bit: Integer;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;
  tail := buf + len;
  ptr := Buf;

  while ptr < tail do
  begin
    bit := Ord(ptr^) - $30;

    if (bit >= 0) and (bit <= 9) then
      Result := Result * 10 + bit
    else begin
      if Assigned(invalid) then invalid^ := ptr;
      Break;
    end;

    Inc(ptr);
  end;
end;

function BufToInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Int64;
var
  sign: Int64;
begin
  Result := 0;

  if not Assigned(buf) or (len = 0) then Exit;

  sign := 1;

  if buf[0] = '-' then
  begin
    sign := -1;
    Inc(buf);
    Dec(len);
  end
  else if buf[0] = '+' then
  begin
    Inc(buf);
    Dec(len);
  end;

  if len <= 0 then Exit;

  if buf[0] = '$' then
    Result := sign * HexStrToInt64A(buf + 1, len - 1, invalid)
  else
    Result := sign * DecimalStrToInt64A(buf, len, invalid);
end;

function StrToInt64A(const str: RawByteString): Int64;
var
  c: PAnsiChar;
begin
  Result := BufToInt64A(PAnsiChar(str), Length(str), @c);
end;

function HexBufToIntW(buf: PWideChar; len: Integer; invalid: PPWideChar): Integer;
var
  ptr, tail: PWideChar;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;
  tail := buf + len;
  ptr := Buf;

  while ptr < tail do
  begin
    case ptr^ of
      '0'..'9': Result := Result shl 4 + Ord(ptr^) - Ord('0');
      'A'..'F': Result := Result shl 4 + Ord(ptr^) - Ord('A') + 10;
      'a'..'f': Result := Result shl 4 + Ord(ptr^) - Ord('a') + 10;
    else begin
        if Assigned(invalid) then invalid^ := ptr;
        Break;
      end;
    end;

    Inc(ptr);
  end;
end;

function DecimalBufToIntW(buf: PWideChar; len: Integer;
  invalid: PPWideChar): Integer;
var
  ptr, tail: PWideChar;
  bit: Integer;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;
  tail := buf + len;
  ptr := Buf;

  while ptr < tail do
  begin
    bit := Ord(ptr^) - $30;

    if (bit >= 0) and (bit <= 9) then
      Result := Result * 10 + bit
    else begin
      if Assigned(invalid) then invalid^ := ptr;
      Break;
    end;

    Inc(ptr);
  end;
end;

function BufToIntW(buf: PWideChar; len: Integer; invalid: PPWideChar): Integer;
var
  sign: Integer;
begin
  Result := 0;

  if Assigned(invalid) then invalid^ := nil;
  
  if not Assigned(buf) or (len = 0) then Exit;

  sign := 1;

  if buf[0] = '-' then
  begin
    sign := -1;
    Inc(buf);
    Dec(len);
  end
  else if buf[0] = '+' then
  begin
    Inc(buf);
    Dec(len);
  end;

  if len <= 0 then Exit;

  if buf[0] = '$' then
    Result := sign * HexBufToIntW(buf + 1, len - 1, invalid)
  else
    Result := sign * DecimalBufToIntW(buf, len, invalid);
end;

function UStrToInt(const str: UnicodeString): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), Length(str), @c);
end;

function BStrToInt(const str: WideString): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), Length(str), @c);
end;


function HexBufToInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): Int64;
var
  ptr, tail: PWideChar;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;
  tail := buf + len;
  ptr := Buf;

  while ptr < tail do
  begin
    case ptr^ of
      '0'..'9': Result := Result shl 4 + Ord(ptr^) - Ord('0');
      'A'..'F': Result := Result shl 4 + Ord(ptr^) - Ord('A') + 10;
      'a'..'f': Result := Result shl 4 + Ord(ptr^) - Ord('a') + 10;
    else begin
        if Assigned(invalid) then invalid^ := ptr;
        Break;
      end;
    end;

    Inc(ptr);
  end;
end;

function DecimalBufToInt64W(buf: PWideChar; len: Integer;
  invalid: PPWideChar): Int64;
var
  ptr, tail: PWideChar;
  bit: Integer;
begin
  Result := 0;
  if Assigned(invalid) then invalid^ := nil;
  tail := buf + len;
  ptr := Buf;

  while ptr < tail do
  begin
    bit := Ord(ptr^) - $30;

    if (bit >= 0) and (bit <= 9) then
      Result := Result * 10 + bit
    else begin
      if Assigned(invalid) then invalid^ := ptr;
      Break;
    end;

    Inc(ptr);
  end;
end;

function BufToInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): Int64;
var
  sign: Int64;
begin
  Result := 0;

  if Assigned(invalid) then invalid^ := nil;

  if not Assigned(buf) or (len = 0) then Exit;

  sign := 1;

  if buf[0] = '-' then
  begin
    sign := -1;
    Inc(buf);
    Dec(len);
  end
  else if buf[0] = '+' then
  begin
    Inc(buf);
    Dec(len);
  end;

  if len <= 0 then Exit;

  if buf[0] = '$' then
    Result := sign * HexBufToInt64W(buf + 1, len - 1, invalid)
  else
    Result := sign * DecimalBufToInt64W(buf, len, invalid);
end;

function UStrToInt64(const str: UnicodeString): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), Length(str), @c);
end;

function BStrToInt64(const str: WideString): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), Length(str), @c);
end;

function BufToFloatA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Double;
var
  i, j: Integer;
  v, ratio, sign: Double;
  dot: Boolean;
begin
  Result := 0;
  v := 0;
  ratio := 1;
  dot := False;
  if Assigned(invalid) then invalid^ := nil;

  if len = 0 then Exit;

  if buf[0] = '-' then
  begin
    sign := -1;
    j := 1;
  end
  else if buf[0] = '+' then
  begin
    sign := 1;
    j := 1;
  end
  else begin
    sign := 1;
    j := 0;
  end;

  for i := j to len - 1 do
  begin
    if (buf[i] >= '0') and (buf[i] <= '9') then
    begin
      if dot then
      begin
        v := v + (Ord(buf[i]) - $30) * ratio;
        ratio := ratio/10;
      end
      else
        v := v * 10 + Ord(buf[i]) - $30;
    end
    else if buf[i] = '.' then begin
      if dot then
      begin
        if Assigned(invalid) then invalid^ := buf + i;
        Break;
      end
      else begin
        ratio := 0.1;
        dot := True;
      end;
    end
    else if buf[i] = ',' then Continue
    else begin
      if Assigned(invalid) then invalid^ := buf + i;
      Break;
    end;
  end;

  Result := v * sign;
end;

function StrToFloatA(const str: RawByteString): Double;
begin
  Result := BufToFloatA(PAnsiChar(str), Length(str), nil);
end;

function BufToFloatA2(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Double;
var
  i, j, decs: Integer;
  dot: Boolean;
  v: Int64;
  sign: Double;
begin
  Result := 0;
  v := 0;
  decs := 0;
  dot := False;
  if Assigned(invalid) then invalid^ := nil;

  if len = 0 then Exit;

  if buf[0] = '-' then
  begin
    sign := -1;
    j := 1;
  end
  else if buf[0] = '+' then
  begin
    sign := 1;
    j := 1;
  end
  else begin
    sign := 1;
    j := 0;
  end;

  for i := j to len - 1 do
  begin
    if (buf[i] >= '0') and (buf[i] <= '9') then
    begin
      v := v * 10 + Ord(buf[i]) - $30;

      Inc(decs);
    end
    else if buf[i] = '.' then begin
      if dot then
      begin
        if Assigned(invalid) then invalid^ := buf + i;
        Break;
      end
      else begin
        dot := True;
        decs := 0;
      end;
    end
    else begin
      if Assigned(invalid) then invalid^ := buf + i;
      Break;
    end;
  end;

  Result := v * sign;

  if dot then
    for i := 0 to decs - 1 do
      Result := Result / 10;
end;

function StrToFloatA2(const str: RawByteString): Double;
begin
  Result := BufToFloatA(PAnsiChar(str), Length(str), nil);
end;

function BufToFloatW(buf: PWideChar; len: Integer; invalid: PPWideChar): Double;
var
  i, j: Integer;
  v, ratio, sign: Double;
  dot: Boolean;
begin
  Result := 0;
  v := 0;
  ratio := 1;
  dot := False;

  if Assigned(invalid) then invalid^ := nil;


  if len = 0 then Exit;

  if buf[0] = '-' then
  begin
    sign := -1;
    j := 1;
  end
  else if buf[0] = '+' then
  begin
    sign := 1;
    j := 1;
  end
  else begin
    sign := 1;
    j := 0;
  end;

  for i := j to len - 1 do
  begin
    if (buf[i] >= '0') and (buf[i] <= '9') then
    begin
      if dot then
      begin
        v := v + (Ord(buf[i]) - $30) * ratio;
        ratio := ratio/10;
      end
      else
        v := v * 10 + Ord(buf[i]) - $30;
    end
    else if buf[i] = '.' then begin
      if dot then
      begin
        if Assigned(invalid) then invalid^ := buf + i;
        Break;
      end
      else begin
        ratio := 0.1;
        dot := True;
      end;
    end
    else begin
      if Assigned(invalid) then invalid^ := buf + i;
      Break;
    end;
  end;

  Result := v * sign;
end;

function UStrToFloat(const str: UnicodeString): Double;
begin
  Result := BufToFloatW(PWideChar(str), Length(str), nil);
end;

function BStrToFloat(const str: WideString): Double;
begin
  Result := BufToFloatW(PWideChar(str), Length(str), nil);
end;


function StrScanA(s: PAnsiChar; len: Integer; c: AnsiChar): PAnsiChar;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to len - 1 do
  begin
    if s[i] = c then
    begin
      Result := s + i;
      Break;
    end;
  end;
end;

function StrScanA(s: PAnsiChar; c: AnsiChar): PAnsiChar;
begin
  while (s^ <> #0) and (s^ <> c) do Inc(s);

  if s^ = #0 then Result := nil
  else Result := s;
end;

function StrScanA(const s: RawByteString; c: AnsiChar): Integer;
var
  p: PAnsiChar;
begin
  p := StrScanA(PAnsiChar(s), Length(s), c);

  if p = nil then Result := 0
  else Result := p - PAnsiChar(s) + 1;
end;

function StrPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar; overload;
asm
      test  eax,eax
      je    @noWork
      test  ecx,ecx
      je    @retNil
      test  edx, edx
      jle   @retNil
      cmp   edx, len
      jg    @retNil
      push  ebx
      push  esi
      mov   ebx, sublen
      mov   edx, str
      add   esp, -16
      mov   esi, len
      dec   ebx
      add   esi, edx
      add   edx, ebx
      mov   [esp+8], esi
      add   eax, ebx
      mov   [esp+4], edx
      neg   ebx
      movzx ecx, byte ptr [eax]
      mov   [esp], ebx
      jnz   @FindString

      sub   esi, 2
      mov   [esp+12], esi

@FindChar2:
      cmp   cl, [edx]
      jz    @Matched0ch
      cmp   cl, [edx+1]
      jz    @Matched1ch
      add   edx, 2
      cmp   edx, [esp+12]
      jb    @FindChar4
      cmp   edx, [esp+8]
      jb    @FindChar2
      xor    eax,eax
      jmp    @exit;

@FindChar4:
      cmp   cl, [edx]
      jz    @Matched0ch
      cmp   cl, [edx+1]
      jz    @Matched1ch
      cmp   cl, [edx+2]
      jz    @Matched2ch
      cmp   cl, [edx+3]
      jz    @Matched3ch
      add   edx, 4
      cmp   edx, [esp+12]
      jb    @FindChar4
      cmp   edx, [esp+8]
      jb    @FindChar2
      xor   eax, eax
      jmp   @exit

@Matched2ch:
      add   edx, 2

@Matched0ch:
      inc   edx
      mov   eax, edx
      add   eax, [esp]
      dec eax
      jmp   @exit

@Matched3ch:
      add   edx, 2

@Matched1ch:
      add   edx, 2
      xor   eax, eax
      cmp   edx, [esp+8]
      ja    @exit
      mov   eax, edx
      add   eax, [esp]
      dec eax
      jmp    @exit

@FindString4:
      cmp   cl, [edx]
      jz    @Test0
      cmp   cl, [edx+1]
      jz    @Test1
      cmp   cl, [edx+2]
      jz    @Test2
      cmp   cl, [edx+3]
      jz    @Test3
      add   edx, 4
      cmp   edx, [esp+12]
      jb    @FindString4
      cmp   edx, [esp+8]
      jb    @FindString2
      xor   eax, eax
      jmp   @exit

@FindString:
      sub   esi, 2
      mov   [esp+12], esi

@FindString2:
      cmp   cl, [edx]
      jz    @Test0

@AfterTest0:
      cmp   cl, [edx+1]
      jz    @Test1

@AfterTest1:
      add   edx, 2
      cmp   edx, [esp+12]
      jb    @FindString4
      cmp   edx, [esp+8]
      jb    @FindString2
      xor   eax, eax
      jmp   @exit

@Test3:
      add   edx, 2

@Test1:
      mov   esi, [esp]

@Loop1:
      movzx ebx, word ptr [esi+eax]
      cmp   bx, word ptr [esi+edx+1]
      jnz   @AfterTest1
      add   esi, 2
      jl    @Loop1
      add   edx, 2
      xor   eax, eax
      cmp   edx, [esp+8]
      ja    @exit

@RetCode1:
      mov   eax, edx
      add   eax, [esp]
      dec eax
      jmp   @exit

@Test2:
      add   edx,2

@Test0:
      mov   esi, [esp]

@Loop0:
      movzx ebx, word ptr [esi+eax]
      cmp   bx, word ptr [esi+edx]
      jnz   @AfterTest0
      add   esi, 2
      jl    @Loop0
      inc   edx
@RetCode0:
      mov   eax, edx
      add   eax, [esp]
      dec eax

@exit:
      add   esp, 16
      pop   esi
      pop   ebx
      jmp  @noWork

@retNil:
      xor eax, eax

@noWork:
end;

function StrPosA(substr: PAnsiChar; str: PAnsiChar): PAnsiChar; overload;
begin
  Result := StrPosA(substr, StrLen(substr), str, StrLen(str));
end;

function StrPosA(const substr, str: RawByteString; StartIndex: Integer; EndIndex: Integer): Integer;
var
  ptr: PAnsiChar;
begin
  if StartIndex <= 0 then
    StartIndex := 1;

  if (EndIndex <= 0) or (EndIndex > Integer(Length(str))) then
    EndIndex := Length(str);

  if EndIndex < StartIndex then
    Result := 0
  else begin
    ptr := StrPosA(PAnsiChar(substr), Length(substr),
      PAnsiChar(str) + (StartIndex - 1),
      EndIndex + 1 - StartIndex);

    if ptr = nil then
      Result := 0
    else
      Result := ptr - PAnsiChar(str) + 1;
  end;
end;

function StrScanW(s: PWideChar; len: Integer; c: WideChar): PWideChar;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to len - 1 do
  begin
    if s[i] = c then
    begin
      Result := s + i;
      Break;
    end;
  end;
end;

function StrScanW(s: PWideChar; c: WideChar): PWideChar;
begin
  while (s^ <> #0) and (s^ <> c) do Inc(s);

  if s^ = #0 then Result := nil
  else Result := s;
end;

function UStrScan(const s: UnicodeString; c: WideChar): Integer;
var
  p: PWideChar;
begin
  p := StrScanW(PWideChar(s), Length(s), c);

  if p = nil then Result := 0
  else Result := p - PWideChar(s) + 1;
end;

function BStrScan(const s: WideString; c: WideChar): Integer;
var
  p: PWideChar;
begin
  p := StrScanW(PWideChar(s), Length(s), c);

  if p = nil then Result := 0
  else Result := p - PWideChar(s) + 1;
end;

function StrScan(const s: string; c: Char): Integer;
var
  i: Integer;
begin 
  Result := 0;
  
  for i := 1 to Length(s) do 
    if s[i] = c then 
    begin
      Result := i;
      Break; 
    end;
end;

function StrPosW(substr, str: PWideChar): PWideChar; overload;
begin
  Result := StrPosW(substr, StrLenW(substr), str, StrLen(str));
end;

function StrPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar;
var
  i, k, MR: Integer;
  match: Boolean;
begin
  Result := nil;
  if (substr = nil) or (str = nil) or (sublen > len) or (sublen = 0) then
  begin
    Exit;
  end;

  MR := len - sublen;

  i := 0;

  while True do
  begin
    while (i <= MR) and (str[i] <> substr[0]) do Inc(i);

    if i > MR then Exit;

    match := True;

    for k := 1 to sublen - 1 do
    begin
      if substr[k] <> str[i + k] then
      begin
        match := False;
        Break;
      end;
    end;

    if match then
    begin
      Result := str + i;
      Break;
    end;

    Inc(i);
  end;
end;

function UStrPos(const substr, str: UnicodeString; StartIndex, EndIndex: Integer): Integer;
var
  ptr: PWideChar;
begin
  if StartIndex <= 0 then
    StartIndex := 1;

  if (EndIndex <= 0) or (EndIndex > Integer(Length(str))) then
    EndIndex := Length(str);

  if EndIndex < StartIndex then
    Result := 0
  else begin
    ptr := StrPosW(PWideChar(substr), Length(substr),
      PWideChar(str) + (StartIndex - 1),
      EndIndex + 1 - StartIndex);

    if ptr = nil then
      Result := 0
    else
      Result := (PAnsiChar(Pointer(ptr)) - PAnsiChar(Pointer(str))) shr 1 + 1;
  end;
end;

function BStrPos(const substr, str: WideString; StartIndex: Integer = 1; EndIndex: Integer = 0): Integer;
var
  ptr: PWideChar;
begin
  if StartIndex <= 0 then
    StartIndex := 1;

  if (EndIndex <= 0) or (EndIndex > Integer(Length(str))) then
    EndIndex := Length(str);

  if EndIndex < StartIndex then
    Result := 0
  else begin
    ptr := StrPosW(PWideChar(substr), Length(substr),
      PWideChar(str) + (StartIndex - 1),
      EndIndex + 1 - StartIndex);

    if ptr = nil then
      Result := 0
    else
      Result := (PAnsiChar(Pointer(ptr)) - PAnsiChar(Pointer(str))) shr 1 + 1;
  end;
end;

function StrIPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;
var
  i, k, MR: Integer;
  match: Boolean;
  w, w1, w2: Word;
begin
  Result := nil;
  if (substr = nil) or (str = nil) or (sublen > len) or (sublen = 0) then
  begin
    Exit;
  end;

  if (substr[0] >= 'A') and (substr[0] <= 'Z') then
    w := Ord(substr[0]) + 32
  else
    w := Ord(substr[0]);

  MR := len - sublen;

  i := 0;

  while True do
  begin
    while i <= MR do
    begin
      if (str[i] >= 'A') and (str[i] <= 'Z') then
        w1 := Ord(str[i]) + 32
      else
        w1 := Ord(str[i]);

      if w1 = w then
        Break;

      Inc(i);
    end;

    if i > MR then Exit;

    match := True;

    for k := 1 to sublen - 1 do
    begin
      if (str[i + k] >= 'A') and (str[i + k] <= 'Z') then
        w1 := Ord(str[i + k]) + 32
      else
        w1 := Ord(str[i + k]);

      if (substr[k] >= 'A') and (substr[k] <= 'Z') then
        w2 := Ord(substr[k]) + 32
      else
        w2 := Ord(substr[k]);

      if w1 <> w2 then
      begin
        match := False;
        Break;
      end;
    end;

    if match then
    begin
      Result := str + i;
      Break;
    end;

    Inc(i);
  end;
end;

function UStrIPos(const substr, str: UnicodeString; StartIndex, EndIndex: Integer): Integer;
var
  ptr: PWideChar;
begin
  if StartIndex <= 0 then
    StartIndex := 1;

  if (EndIndex <= 0) or (EndIndex > Integer(Length(str))) then
    EndIndex := Length(str);

  if EndIndex < StartIndex then
    Result := 0
  else begin
    ptr := StrIPosW(PWideChar(substr), Length(substr),
      PWideChar(str) + (StartIndex - 1),
      EndIndex + 1 - StartIndex);

    if ptr = nil then
      Result := 0
    else
      Result := (PAnsiChar(Pointer(ptr)) - PAnsiChar(Pointer(str))) shr 1 + 1;
  end;
end;

function BStrIPos(const substr, str: WideString; StartIndex, EndIndex: Integer): Integer;
var
  ptr: PWideChar;
begin
  if StartIndex <= 0 then
    StartIndex := 1;

  if (EndIndex <= 0) or (EndIndex > Integer(Length(str))) then
    EndIndex := Length(str);

  if EndIndex < StartIndex then
    Result := 0
  else begin
    ptr := StrIPosW(PWideChar(substr), Length(substr),
      PWideChar(str) + (StartIndex - 1),
      EndIndex + 1 - StartIndex);

    if ptr = nil then
      Result := 0
    else
      Result := (PAnsiChar(Pointer(ptr)) - PAnsiChar(Pointer(str))) shr 1 + 1;
  end;
end;

function StrRPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar;
var
  i, k, ML: Integer;
  match: Boolean;
begin
  Result := nil;

  if (substr = nil) or (str = nil) or (sublen > len) or (sublen = 0) then
  begin
    Exit;
  end;

  ML := sublen - 1;

  i := len - 1;

  while True do
  begin
    while (i >= ML) and (str[i] <> substr[ML]) do Dec(i);

    if i < ML then Exit;

    match := True;

    for k := sublen - 2 downto 0 do
    begin
      if substr[k] <> str[i - (sublen - 1 - k)] then
      begin
        match := False;
        Break;
      end;
    end;

    if match then
    begin
      Result := str + (i - (sublen - 1));
      Break;
    end;

    Dec(i);
  end;
end;

function UStrRPos(const substr, str: UnicodeString; StartIndex, EndIndex: Integer): Integer;
var
  ptr: PWideChar;
begin
  if StartIndex <= 0 then
    StartIndex := 1;

  if (EndIndex <= 0) or (EndIndex > Integer(Length(str))) then
    EndIndex := Length(str);

  if EndIndex < StartIndex then
    Result := 0
  else begin
    ptr := StrRPosW(PWideChar(substr), Length(substr),
      PWideChar(str) + (StartIndex - 1),
      EndIndex + 1 - StartIndex);

    if ptr = nil then
      Result := 0
    else
      Result := (PAnsiChar(Pointer(ptr)) - PAnsiChar(Pointer(str))) shr 1 + 1;
  end;
end;

function BStrRPos(const substr, str: WideString; StartIndex, EndIndex: Integer): Integer;
var
  ptr: PWideChar;
begin
  if StartIndex <= 0 then
    StartIndex := 1;

  if (EndIndex <= 0) or (EndIndex > Integer(Length(str))) then
    EndIndex := Length(str);

  if EndIndex < StartIndex then
    Result := 0
  else begin
    ptr := StrRPosW(PWideChar(substr), Length(substr),
      PWideChar(str) + (StartIndex - 1),
      EndIndex + 1 - StartIndex);

    if ptr = nil then
      Result := 0
    else
      Result := (PAnsiChar(Pointer(ptr)) - PAnsiChar(Pointer(str))) shr 1 + 1;
  end;
end;

function StrRIPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar;
var
  i, j, k, ML: Integer;
  match: Boolean;
  w, w1, w2: Word;
begin
  Result := nil;

  if (substr = nil) or (str = nil) or (sublen > len) or (sublen <= 0) then
  begin
    Exit;
  end;

  ML := sublen - 1;

  if (substr[ML] >= 'A') and (substr[ML] <= 'Z') then
    w := Ord(substr[ML]) + 32
  else
    w := Ord(substr[ML]);

  i := len - 1;

  while True do
  begin
    while i >= ML do
    begin
      if (str[i] >= 'A') and (str[i] <= 'Z') then
        w1 := Ord(str[i]) + 32
      else
        w1 := Ord(str[i]);

      if w1 = w then
        Break;

      Dec(i);
    end;

    if i < ML then Exit;

    match := True;

    for k := sublen - 2 downto 0 do
    begin
      j := i - (sublen - 1 - k);
      if (str[j] >= 'A') and (str[j] <= 'Z') then
        w1 := Ord(str[j]) + 32
      else
        w1 := Ord(str[j]);

      if (substr[k] >= 'A') and (substr[k] <= 'Z') then
        w2 := Ord(substr[k]) + 32
      else
        w2 := Ord(substr[k]);

      if w1 <> w2 then
      begin
        match := False;
        Break;
      end;
    end;

    if match then
    begin
      Result := str + (i - (sublen - 1));
      Break;
    end;

    Dec(i);
  end;
end;

function UStrRIPos(const substr, str: UnicodeString; StartIndex, EndIndex: Integer): Integer;
var
  ptr: PWideChar;
begin
  if StartIndex <= 0 then
    StartIndex := 1;

  if (EndIndex <= 0) or (EndIndex > Integer(Length(str))) then
    EndIndex := Length(str);

  if EndIndex < StartIndex then
    Result := 0
  else begin
    ptr := StrIPosW(PWideChar(substr), Length(substr),
      PWideChar(str) + (StartIndex - 1),
      EndIndex + 1 - StartIndex);

    if ptr = nil then
      Result := 0
    else
      Result := (PAnsiChar(Pointer(ptr)) - PAnsiChar(Pointer(str))) shr 1 + 1;
  end;
end;

function BStrRIPos(const substr, str: WideString; StartIndex, EndIndex: Integer): Integer;
var
  ptr: PWideChar;
begin
  if StartIndex <= 0 then
    StartIndex := 1;

  if (EndIndex <= 0) or (EndIndex > Integer(Length(str))) then
    EndIndex := Length(str);

  if EndIndex < StartIndex then
    Result := 0
  else begin
    ptr := StrIPosW(PWideChar(substr), Length(substr),
      PWideChar(str) + (StartIndex - 1),
      EndIndex + 1 - StartIndex);

    if ptr = nil then
      Result := 0
    else
      Result := (PAnsiChar(Pointer(ptr)) - PAnsiChar(Pointer(str))) shr 1 + 1;
  end;
end;

function StrReplaceA(const S, OldPattern, NewPattern: RawByteString; Flags: TReplaceFlags): RawByteString;
begin
  Result := StringReplace(S, OldPattern, NewPattern, Flags);
end;

function UStrReplace(const S, OldPattern, NewPattern: UnicodeString; Flags: TReplaceFlags): UnicodeString;
begin
  Result := StringReplace(S, OldPattern, NewPattern, Flags);
end;

function BStrReplace(const S, OldPattern, NewPattern: WideString; Flags: TReplaceFlags): WideString;
begin
  Result := StringReplace(S, OldPattern, NewPattern, Flags);
end;

function StrCompareW(const S1: PWideChar; L1: Integer;
  S2: PWideChar; L2: Integer; CaseSensitive: Boolean): Integer;
var
  CmpFlags: DWORD;
begin
  if CaseSensitive then CmpFlags := 0
  else CmpFlags := NORM_IGNORECASE;

  Result := CompareStringW(LOCALE_USER_DEFAULT, CmpFlags, S1, L1, S2, L2) - 2;
end;

function StrCompareW(S1, S2: PWideChar; CaseSensitive: Boolean = True): Integer;
begin
  Result := StrCompareW(S1, StrLenW(S1), S2, StrLenW(S2), CaseSensitive);
end;

function UStrCompare(S1, S2: UnicodeString; CaseSensitive: Boolean = True): Integer;
begin 
  Result := StrCompareW(PWideChar(S1), Length(S1), PWideChar(S2), Length(S2), CaseSensitive);
end;

function BStrCompare(S1, S2: WideString; CaseSensitive: Boolean = True): Integer;
begin
  Result := StrCompareW(PWideChar(S1), Length(S1), PWideChar(S2), Length(S2), CaseSensitive);
end;

function StrCompareA(str1: PAnsiChar; len1: Integer; str2: PAnsiChar; len2: Integer; CaseSensitive: Boolean): Integer;
var
  i: Integer;
  ch1, ch2: AnsiChar;
begin
  Result := len1 - len2;
  if Result = 0 then
  begin
    for i := 0 to len1 - 1 do
    begin
      ch1 := str1[i];
      ch2 := str2[i];
      if ch1 = ch2 then Continue;
      if not CaseSensitive and ((ch1 in ['A'..'Z']) or (ch1 in ['a'..'z'])) and
        ((ch2 in ['A'..'Z']) or (ch2 in ['a'..'z'])) then
      begin
        ch1 := AnsiChar(PByte(str1 + i)^ or 32);
        ch2 := AnsiChar(PByte(str2 + i)^ or 32);
      end;
      if ch1 <> ch2 then
      begin
        Result := Ord(ch1) - Ord(ch2);
        Break;
      end;
    end;
  end;
end;

function StrCompareA(const Str1, Str2: RawByteString; CaseSensitive: Boolean): Integer;
begin
  Result := StrCompareA(PAnsiChar(str1), Length(str1),
    PAnsiChar(Str2), Length(str2), CaseSensitive);
end;

function UStrCatCStr(const s1: array of UnicodeString; s2: PWideChar): UnicodeString;
var
  i, L1, L2: Integer;
begin
  L1 := 0;

  for i := Low(s1) to High(s1) do
    Inc(L1, Length(s1[i]));

  L2 := StrLenW(s2);

  SetLength(Result, L1 + L2);

  L1 := 0;

  for i := Low(s1) to High(s1) do
  begin
    Move(Pointer(s1[i])^, PWideChar(Result)[L1], Length(s1[i]) * 2);
    Inc(L1, Length(s1[i]));
  end;

  Move(s2^, PWideChar(Result)[L1], L2 * 2);
end;

function GetSectionBetweenA(const src, prefix, suffix: RawByteString; out P1, P2: Integer;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;
begin
  Result := False;

  if src <> '' then
  begin
    if limit <= 0 then
      limit := Length(src);

    p1 := StrPosA(prefix, src, start, limit);

    if p1 > 0 then
    begin
      Inc(p1, Integer(Length(prefix)));
      p2 := StrPosA(suffix, src, p1, limit);

      Result := p2 > 0;
    end;
  end;
end;

function GetTrimedSectionBetweenA(const src, prefix, suffix: RawByteString; out P1, P2: Integer;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;
begin
  Result := GetSectionBetweenA(src, prefix, suffix, P1, P2, start, limit);

  if Result then
  begin
    while (P1 < P2) and (src[P1] <= #32) do Inc(P1);
    while (P2 > P1) and (src[P2] <= #32) do Dec(P2);
  end;
end;

function GetSubstrBetweenA(const src, prefix, suffix: RawByteString;
  start: Integer = 1; limit: Integer = 0): RawByteString;
var
  P1, P2: Integer;
begin
  if GetSectionBetweenA(src, prefix, suffix, P1, P2, start, limit) then
    Result := Copy(src, P1, P2 - P1)
  else
    Result := '';
end;

function GetTrimedSubstrBetweenA(const src, prefix, suffix: RawByteString;
  start: Integer = 1; limit: Integer = 0): RawByteString; overload;
var
  P1, P2: Integer;
begin
  if GetSectionBetweenA(src, prefix, suffix, P1, P2, start, limit) then
    Result := TrimCopyA(src, P1, P2 - P1)
  else
    Result := '';
end;

function GetIntegerBetweenA(const src, prefix, suffix: RawByteString;
  out value: Int64; start: Integer = 1; limit: Integer = 0): Boolean;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  Result := False;

  if GetTrimedSectionBetweenA(src, prefix, suffix, P1, P2, start, limit) then
  begin
    value := BufToInt64A(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then value := 0
    else Result := True;
  end;
end;

function GetIntegerBetweenA(const src, prefix, suffix: RawByteString;
  start: Integer = 1; limit: Integer = 0): Int64;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  if GetTrimedSectionBetweenA(src, prefix, suffix, P1, P2, start, limit) then
  begin
    Result := BufToInt64A(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then Result := 0
  end
  else Result := 0;
end;

function GetFloatBetweenA(const src, prefix, suffix: RawByteString; out value: Double;
  start: Integer = 1; limit: Integer = 0): Boolean;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  Result := False;

  value := 0;
  if GetTrimedSectionBetweenA(src, prefix, suffix, P1, P2, start, limit) then
  begin
    try
      value := BufToFloatA(PAnsiChar(src) +  P1 - 1, P2 - P1, @c);

      if not Assigned(c) then
        Result := True;
    except

    end;
  end;
end;

function GetFloatBetweenA(const src, prefix, suffix: RawByteString;
  start: Integer = 1; limit: Integer = 0): Double;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  if GetTrimedSectionBetweenA(src, prefix, suffix, P1, P2, start, limit) then
  begin
    Result := BufToFloatA(PAnsiChar(src) +  P1 - 1, P2 - P1, @c);

    if Assigned(c) then Result := 0;
  end
  else Result := 0;
end;

function GetSectionBetweenW(const src, prefix, suffix: UnicodeString; out P1, P2: Integer;
  start: Integer = 1; limit: Integer = 0): Boolean;
begin
  Result := False;

  if src <> '' then
  begin
    if limit <= 0 then
      limit := Length(src);

    p1 := UStrPos(prefix, src, start, limit);

    if p1 > 0 then
    begin
      Inc(p1, Integer(Length(prefix)));
      p2 := UStrPos(suffix, src, p1, limit);

      Result := p2 > 0;
    end;
  end;
end;

function GetTrimedSectionBetweenW(const src, prefix, suffix: UnicodeString; out P1, P2: Integer;
  start: Integer = 1; limit: Integer = 0): Boolean; overload;
begin
  Result := GetSectionBetweenW(src, prefix, suffix, P1, P2, start, limit);

  if Result then
  begin
    while (P1 < P2) and (src[P1] <= #32) do Inc(P1);
    while (P2 > P1) and (src[P2] <= #32) do Dec(P2);
  end;
end;

function GetSubstrBetweenW(const src, prefix, suffix: UnicodeString;
  start: Integer = 1; limit: Integer = 0): UnicodeString;
var
  P1, P2: Integer;
begin
  if GetSectionBetweenW(src, prefix, suffix, P1, P2, start, limit) then
    Result := Copy(src, P1, P2 - P1)
  else
    Result := '';
end;

function GetTrimedSubstrBetweenW(const src, prefix, suffix: UnicodeString;
  start: Integer = 1; limit: Integer = 0): UnicodeString;
var
  P1, P2: Integer;
begin
  if GetSectionBetweenW(src, prefix, suffix, P1, P2, start, limit) then
    Result := TrimCopyU(src, P1, P2 - P1)
  else
    Result := '';
end;

function GetIntegerBetweenW(const src, prefix, suffix: UnicodeString; out value: Int64;
  start: Integer = 1; limit: Integer = 0): Boolean;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  Result := False;

  if GetTrimedSectionBetweenW(src, prefix, suffix, P1, P2, start, limit) then
  begin
    c:= nil;
    value := BufToInt64W(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then value := 0
    else Result := True;
  end;
end;

function GetIntegerBetweenW(const src, prefix, suffix: UnicodeString;
  start: Integer = 1; limit: Integer = 0): Int64; overload;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  if GetTrimedSectionBetweenW(src, prefix, suffix, P1, P2, start, limit) then
  begin
    c:= nil;
    
    Result := BufToInt64W(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then Result := 0;
  end
  else Result := 0;
end;

function GetFloatBetweenW(const src, prefix, suffix: UnicodeString; out value: Double;
  start: Integer = 1; limit: Integer = 0): Boolean;
var
  P1, P2: Integer;
begin
  value := 0;
  if GetTrimedSectionBetweenW(src, prefix, suffix, P1, P2, start, limit) then
  begin
    try
      value := BufToFloatW(PWideChar(src) +  P1 - 1, P2 - P1, nil);
      Result := True;
    except
      Result := False;
    end;
  end
  else Result := False;
end;

function GetFloatBetweenW(const src, prefix, suffix: UnicodeString;
  start: Integer = 1; limit: Integer = 0): Double;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  if GetTrimedSectionBetweenW(src, prefix, suffix, P1, P2, start, limit) then
  begin
    Result := BufToFloatW(PWideChar(src) +  P1 - 1, P2 - P1, @c);

    if Assigned(c) then Result := 0;
  end
  else Result := 0;
end;

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

function BeginWithW(s: PWideChar; len: Integer; sub: PWideChar; sublen: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  
  if len < sublen then Exit;

  for i := 0 to sublen - 1 do
    if sub[i] <> s[i] then Exit;

  Result := True;
end;

function BeginWithW(s, sub: PWideChar): Boolean;
begin
  while (s^ = sub^) and (sub^ <> #0) do
  begin
    Inc(s); Inc(sub);
  end;

  Result := sub^ = #0;
end;

function IBeginWithW(s, sub: PWideChar): Boolean; overload;
var
  c1, c2: WideChar;
begin
  c2 := #0;

  while True do
  begin
    c1 := s^; c2 := sub^;

    if (c1 >= 'A') and (c1 <= 'Z') then Inc(Word(c1), 32);
    if (c2 >= 'A') and (c2 <= 'Z') then Inc(Word(c2), 32);

    if (c1 <> c2) or (c2 = #0) then Break;

    Inc(s); Inc(sub);
  end;

  Result := c2 = #0;
end;

function BeginWithA(s: PAnsiChar; len: Integer; sub: PAnsiChar; sublen: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;

  if len < sublen then Exit;

  for i := 0 to sublen - 1 do
    if sub[i] <> s[i] then Exit;

  Result := True;
end;

function BeginWithA(s, sub: PAnsiChar): Boolean;
begin
  while (s^ = sub^) and (sub^ <> #0) do
  begin
    Inc(s); Inc(sub);
  end;

  Result := sub^ = #0;
end;

function IBeginWithA(s, sub: PAnsiChar): Boolean;
var
  c1, c2: AnsiChar;
begin
  c2 := #0;

  while True do
  begin
    c1 := s^; c2 := sub^;

    if (c1 >= 'A') and (c1 <= 'Z') then Inc(Byte(c1), 32);
    if (c2 >= 'A') and (c2 <= 'Z') then Inc(Byte(c2), 32);

    if (c1 <> c2) or (c2 = #0) then Break;

    Inc(s); Inc(sub);
  end;

  Result := c2 = #0;
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

    if BeginWithW(s + P2 + 1, len - P2 - 1, 'lt;', 3) then
    begin
      dst^ := '<'; Inc(dst); Inc(P2, 3);
    end
    else if BeginWithW(s + P2 + 1, len - P2 - 1, 'gt;', 3) then
    begin
      dst^ := '>'; Inc(dst); Inc(P2, 3);
    end
    else if BeginWithW(s + P2 + 1, len - P2 - 1, 'amp;', 4) then
    begin
      dst^ := '&'; Inc(dst); Inc(P2, 4);
    end
    else if BeginWithW(s + P2 + 1, len - P2 - 1, 'apos;', 5) then
    begin
      dst^ := #39; Inc(dst); Inc(P2, 5);
    end
    else if BeginWithW(s + P2 + 1, len - P2 - 1, 'quot;', 5) then
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

function GetSectionBetweenA(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  out P1, P2: Integer; start: Integer = 1; limit: Integer = 0;
  EndingNoSuffix: Boolean = True): Boolean;
var
  i: Integer;
begin
  Result := False;

  if src <> '' then
  begin
    if limit = 0 then
      limit := Length(src);

    p1 := StrPosA(prefix, src, start, limit);

    if p1 > 0 then
    begin
      Inc(p1, Length(prefix));
      p2 := p1;
      while p2 <= limit do
      begin
        for i := Low(suffix) to high(suffix) do
        begin
          if src[p2] = suffix[i] then
          begin
            Result := True;
            Exit;
          end;
        end;

        Inc(p2);
      end;

      (*
      在字符串结尾允许不带suffix。比如prefix为'ab', suffix为[';', ',']时，
      从'abcde;123'、'abcde'、'abcde,123'三个src中都能提取出'cde'
      *)
      if (p2 > Integer(Length(src))) and EndingNoSuffix then
        Result := True;
    end;
  end;
end;

function GetSubstrBetweenA(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  start: Integer = 1; limit: Integer = 0; EndingNoSuffix: Boolean = True): RawByteString;
var
  P1, P2: Integer;
begin
  if GetSectionBetweenA(src, prefix, suffix, P1, P2, start, limit, EndingNoSuffix) then
    Result := Copy(src, P1, P2 - P1)
  else
    Result := '';
end;

function GetTrimedSubstrBetweenA(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  start: Integer = 1; limit: Integer = 0; EndingNoSuffix: Boolean = True): RawByteString;
var
  P1, P2: Integer;
begin
  if GetSectionBetweenA(src, prefix, suffix, P1, P2, start, limit, EndingNoSuffix) then
    Result := TrimCopyA(src, P1, P2 - P1)
  else
    Result := '';
end;

//提取夹在prefix和suffix中任一字符之间的子串

function GetSectionBetweenW(const src, prefix: UnicodeString; const suffix: array of WideChar;
  out P1, P2: Integer; start, limit: Integer; EndingNoSuffix: Boolean): Boolean;
var
  i: Integer;
begin
  Result := False;

  if src <> '' then
  begin
    if limit = 0 then
      limit := Length(src);

    p1 := UStrPos(prefix, src, start, limit);

    if p1 > 0 then
    begin
      Inc(p1, Length(prefix));
      p2 := p1;
      while p2 <= limit do
      begin
        for i := Low(suffix) to high(suffix) do
        begin
          if src[p2] = suffix[i] then
          begin
            Result := True;
            Exit;
          end;
        end;

        Inc(p2);
      end;

      (*
      在字符串结尾允许不带suffix。比如prefix为'ab', suffix为[';', ',']时，
      从'abcde;123'、'abcde'、'abcde,123'三个src中都能提取出'cde'
      *)
      if (p2 > Integer(Length(src))) and EndingNoSuffix then
        Result := True;
    end;
  end;
end;

function GetSubstrBetweenW(const src, prefix: UnicodeString; const suffix: array of WideChar;
  start, limit: Integer; EndingNoSuffix: Boolean): UnicodeString;
var
  P1, P2: Integer;
begin
  if GetSectionBetweenW(src, prefix, suffix, P1, P2, start, limit, EndingNoSuffix) then
    Result := Copy(src, P1, P2 - P1)
  else
    Result := '';
end;

function GetTrimedSubstrBetweenW(const src, prefix: UnicodeString; const suffix: array of WideChar;
  start: Integer = 1; limit: Integer = 0; EndingNoSuffix: Boolean = True): UnicodeString;
var
  P1, P2: Integer;
begin
  if GetSectionBetweenW(src, prefix, suffix, P1, P2, start, limit, EndingNoSuffix) then
    Result := TrimCopyU(src, P1, P2 - P1)
  else
    Result := '';
end;

function UStrCopyUntil(const src: UnicodeString; const suffix: array of WideChar;
  StartIndex, EndIndex: Integer; EndingNoSuffix: Boolean = True): UnicodeString;
var
  i: Integer;
  P: Integer;
begin
  Result := '';
  P := StartIndex;
  while P <= EndIndex do
  begin
    for i := Low(suffix) to high(suffix) do
    begin
      if src[P] = suffix[i] then
      begin
        Result := Copy(src, StartIndex, P - StartIndex);
        Exit;
      end;
    end;

    Inc(P);
  end;

      (*
      在字符串结尾允许不带suffix。比如prefix为'ab', suffix为[';', ',']时，
      从'abcde;123'、'abcde'、'abcde,123'三个src中都能提取出'cde'
      *)
  if (P > Integer(Length(src))) and EndingNoSuffix then
    Result := Copy(src, StartIndex, P - StartIndex);
end;

function TrimCopyU(const s: UnicodeString; start, len: Integer): UnicodeString;
var
  P1, P2: Integer;
begin
  Result := '';

  P1 := start;

  if P1 <= 0 then P1 := 1;

  P2 := P1 + len - 1;

  if P2 > Length(s) then P2 := Length(s);

  if P1 <= Length(s) then
  begin
    while (P1 <= P2) and (s[P1] <= #32) do Inc(P1);
    while (P2 >= P1) and (s[P2] <= #32) do Dec(P2);

    if P2 >= P1 then Result := Copy(s, P1, P2 + 1 - P1);
  end;
end;

function TrimCopyA(const s: RawByteString; start, len: Integer): RawByteString;
var
  P1, P2: Integer;
begin
  Result := '';

  P1 := start;

  if P1 <= 0 then P1 := 1;

  P2 := P1 + len - 1;

  if P2 > Length(s) then P2 := Length(s);

  if P1 <= Length(s) then
  begin
    while (P1 <= P2) and (s[P1] <= #32) do Inc(P1);
    while (P2 >= P1) and (s[P2] <= #32) do Dec(P2);

    if P2 >= P1 then Result := Copy(s, P1, P2 + 1 - P1);
  end;
end;

function TrimCopyW(const s: WideString; start, len: Integer): WideString;
var
  P1, P2: Integer;
begin
  Result := '';

  P1 := start;

  if P1 <= 0 then P1 := 1;

  P2 := P1 + len - 1;

  if P2 > Length(s) then P2 := Length(s);

  if P1 <= Length(s) then
  begin
    while (P1 <= P2) and (s[P1] <= #32) do Inc(P1);
    while (P2 >= P1) and (s[P2] <= #32) do Dec(P2);

    if P2 >= P1 then Result := Copy(s, P1, P2 + 1 - P1);
  end;
end;

function CheckMail(const s: string): Boolean;
//检测是否邮箱帐号
var
  i, _dot, _at: Integer;
begin
  Result := False;

  _dot := 0;
  _at := 0;

  if Length(s) <= 5 then Exit;

  for i := 1 to Length(s) do
  begin
    case s[i] of
      '0'..'9', 'a'..'z', 'A'..'Z', '_', '-': ;
      '.': _dot := i; 
      '@': _at := i;
      else Exit;
    end;
  end;
  
  Result := (_dot <> 0) and (_at <> 0);
end;

function ExtractIntegerA(const str: RawByteString): Integer;
var
  P1: Integer;
begin
  Result := 0;

  P1 := 1;

  while (P1 <= Length(str)) and ((str[P1] < '0') or (str[P1] > '9')) do Inc(P1);

  if P1 > Length(str) then Exit;

  while (P1 <= Length(str)) and ((str[P1] >= '0') and (str[P1] <= '9')) do
  begin
    Result := Result * 10 + Ord(str[P1]) - $30;
    Inc(P1);
  end;
end;

function ExtractIntegersA(const str: RawByteString; var numbers: array of Int64): Integer;
var
  I, P1: Integer;
  v: Int64;
begin
  Result := 0;

  if Length(numbers) = 0 then Exit;

  P1 := -1;
  v := 0;

  for I := 1 to Length(str) do
  begin
    if (str[I] >= '0') and (str[I] <= '9') then
    begin
      if P1 = -1 then
      begin
        P1 := I;
        v := Ord(str[i]) - $30;
      end
      else
        v := v * 10 + Ord(str[i]) - $30;
    end
    else begin
      if P1 <> -1 then
      begin
        P1 := -1;
        numbers[Result] := v;
        Inc(Result);
        if Result >= Length(numbers) then Break;
      end;
    end;
  end;

  if P1 <> -1 then
  begin
    numbers[Result] := v;
    Inc(Result);
  end;
end;

function UStrExtractInteger(const str: UnicodeString): Integer;
var
  P1: Integer;
begin
  Result := 0;

  P1 := 1;

  while (P1 <= Length(str)) and ((str[P1] < '0') or (str[P1] > '9')) do Inc(P1);

  if P1 > Length(str) then Exit;

  while (P1 <= Length(str)) and ((str[P1] >= '0') and (str[P1] <= '9')) do
  begin
    Result := Result * 10 + Ord(str[P1]) - $30;
    Inc(P1);
  end;
end;

function UStrExtractIntegers(const str: UnicodeString; var numbers: array of Int64): Integer;
var
  I, P1: Integer;
  v: Int64;
begin
  Result := 0;

  if Length(numbers) = 0 then Exit;

  P1 := -1;
  v := 0;

  for I := 1 to Length(str) do
  begin
    if (str[I] >= '0') and (str[I] <= '9') then
    begin
      if P1 = -1 then
      begin
        P1 := I;
        v := Ord(str[i]) - $30;
      end
      else
        v := v * 10 + Ord(str[i]) - $30;
    end
    else begin
      if P1 <> -1 then
      begin
        P1 := -1;
        numbers[Result] := v;
        Inc(Result);
        if Result >= Length(numbers) then Break;
      end;
    end;
  end;

  if P1 <> -1 then
  begin
    numbers[Result] := v;
    Inc(Result);
  end;
end;

function BStrExtractInteger(const str: WideString): Integer;
var
  P1: Integer;
begin
  Result := 0;

  P1 := 1;

  while (P1 <= Length(str)) and ((str[P1] < '0') or (str[P1] > '9')) do Inc(P1);

  if P1 > Length(str) then Exit;

  while (P1 <= Length(str)) and ((str[P1] >= '0') and (str[P1] <= '9')) do
  begin
    Result := Result * 10 + Ord(str[P1]) - $30;
    Inc(P1);
  end;
end;

function BStrExtractIntegers(const str: WideString; var numbers: array of Int64): Integer;
var
  I, P1: Integer;
  v: Int64;
begin
  Result := 0;

  if Length(numbers) = 0 then Exit;

  P1 := -1;
  v := 0;

  for I := 1 to Length(str) do
  begin
    if (str[I] >= '0') and (str[I] <= '9') then
    begin
      if P1 = -1 then
      begin
        P1 := I;
        v := Ord(str[i]) - $30;
      end
      else
        v := v * 10 + Ord(str[i]) - $30;
    end
    else begin
      if P1 <> -1 then
      begin
        P1 := -1;
        numbers[Result] := v;
        Inc(Result);
        if Result >= Length(numbers) then Break;
      end;
    end;
  end;

  if P1 <> -1 then
  begin
    numbers[Result] := v;
    Inc(Result);
  end;
end;

function StrSliceA(s: PAnsiChar; len, offset, num: Integer): RawByteString;
var
  max_len: Integer;
begin
  if offset < 0 then offset := 0;

  max_len := len - offset;

  if max_len < 0 then max_len := 0;

  if (num < 0) or (num > max_len) then num := max_len;

  SetLength(Result, num);

  if num > 0 then
    Move(PAnsiChar(s)[offset], Pointer(Result)^, num);
end;

function StrSliceA(const s: RawByteString; offset, num: Integer): RawByteString;
begin
  Result := StrSliceA(PAnsiChar(s), Length(s), offset, num);
end;

procedure StrSplit(const str, delimiter: string; list: TStrings);
var
  P1, P2: Integer;
  L: Integer;
begin
  P1 := 1;
  L := Length(str);

  list.Clear;

  while True do
  begin
    while (P1 <= L) and (StrScan(delimiter, str[P1]) > 0) do Inc(P1);

    if P1 > L then Break;

    P2 := P1 + 1;

    while (P2 <= L) and (StrScan(delimiter, str[P2]) <= 0) do Inc(P2);

    list.Add(Copy(str, P1, P2 - P1));

    P1 := P2 + 1;
  end;
end;

function IndexOfCharA(const arr: array of AnsiChar; c: AnsiChar): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := Low(arr) to High(arr) do
  begin
    if arr[i] = c then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function StrSplitA(const str: RawByteString; const delimiters: array of AnsiChar;
  var strs: array of RawByteString): Integer;
var
  P1, P2: Integer;
  L, n: Integer;
begin
  P1 := 1;
  L := Length(str);

  n := 0;

  while P1 <= L do
  begin
    while (P1 <= L) and (IndexOfCharA(delimiters, str[P1]) >= 0) do Inc(P1);

    if P1 > L then Break;

    P2 := P1 + 1;

    while (P2 <= L) and (IndexOfCharA(delimiters, str[P2]) = -1) do Inc(P2);

    if Length(strs) > n then
    begin
      strs[n] := Copy(str, P1, P2 - P1);
      Inc(n);
    end;

    if n >= Length(strs) then Break;

    P1 := P2 + 1;
  end;

  Result := n;
end;

function StrToDateTimeA(const s: RawByteString; out dt: TDateTime): Boolean;
var
  numbers: array[0..5] of Int64;
  i, n: Integer;
begin
  n := ExtractIntegersA(s, numbers);

  for i := n to 5 do numbers[i] := 0;

  if n >= 3 then
    Result := TryEncodeDateTime(numbers[0], numbers[1], numbers[2],
      numbers[3], numbers[4], numbers[5], 0, dt)
  else
    Result := False;
end;

function UStrToDateTime(const s: UnicodeString; out dt: TDateTime): Boolean;
var
  numbers: array[0..5] of Int64;
  i, n: Integer;
begin
  n := UStrExtractIntegers(s, numbers);

  for i := n to 5 do numbers[i] := 0;

  if n >= 3 then
    Result := TryEncodeDateTime(numbers[0], numbers[1], numbers[2],
      numbers[3], numbers[4], numbers[5], 0, dt)
  else
    Result := False;
end;

procedure WaitForThreads(const threads: array of TThread);
var
  handles: array[0..MAXIMUM_WAIT_OBJECTS - 1] of THandle;
  P1, P2, I: Integer;
begin
  P1 := Low(threads);

  while P1 <= High(threads) do
  begin
    P2 := High(threads);

    if P2 + 1 - P1 > Length(handles) then
      P2 := P1 + Length(handles) - 1;

    for I := P1 to P2 do
      handles[I - P1] := threads[I].Handle;

    WaitForMultipleObjects(P2 + 1 - P1, PWOHandleArray(@handles), True, INFINITE);

    P1 := P2 + 1;
  end;
end;

procedure StopAndWaitForThread(threads: TList);
var
  handles: array[0..MAXIMUM_WAIT_OBJECTS - 1] of THandle;
  P1, P2, I, n: Integer;
begin
  for I := 0 to threads.Count - 1 do
  begin
    TThread(threads[I]).Terminate;

    if TThread(threads[I]) is DSLSignalThread then
      DSLSignalThread(threads[I]).SendStopSignal;
  end;

  P1 := 0;

  while P1 < threads.Count do
  begin
    P2 := threads.Count - 1;

    if P2 - P1 + 1 > Length(handles) then
      P2 := P1 + Length(handles) - 1;

    for I := P1 to P2 do
      handles[I - P1] := TThread(threads[I]).Handle;

    n := P2 + 1 - P1;

    if RunningInMainThread then
    begin
      while MsgWaitForMultipleObjects(n, handles, True, INFINITE, QS_ALLINPUT) =
        DWORD(n + WAIT_OBJECT_0) do
        Application.ProcessMessages;
    end
    else
      WaitForMultipleObjects(n, PWOHandleArray(@handles), True, INFINITE);

    P1 := P2 + 1;
  end;

  for I := 0 to threads.Count - 1 do
    TObject(threads[I]).Free;

  threads.Clear;
end;

function GetFloatBeforeA(str: PAnsiChar; len: Integer; substr: PAnsiChar;
  sublen: Integer; out number: Double): Boolean;
var
  P, P1, P2: PAnsiChar;
  dot: Boolean; //小数点是否已经出现
  ratio: Integer;
begin
  Result := False;
  P := str + 1;

  while P < str + len - sublen do
  begin
    P1 := StrPosA(substr, sublen, P, str + len - P);

    if P1 = nil then Break;

    P2 := P1 - 1;

    if (P2^ >= '0') and (P2^ <= '9') then
    begin
      ratio := 1;
      number := 0;
      dot := False;
      while P2 >= str do
      begin
        if (P2^ >= '0') and (P2^ <= '9') then
        begin
          number := number + (Ord(P2^) and $0F) * ratio;
          ratio := ratio * 10;
        end
        else if P2^ = '.' then
        begin
          if dot then Break;

          dot := True;

          number := number / ratio;

          ratio := 1;
        end
        else Break;

        Dec(P2);
      end;

      Result := True;
      Break;
    end;

    P := P1 + sublen;
  end;

  if not Result then
    number := 0;
end;

function GetFloatBeforeW(str: PWideChar; len: Integer; substr: PWideChar; sublen: Integer; out number: Double): Boolean;
var
  P, P1, P2: PWideChar;
  dot: Boolean; //小数点是否已经出现
  ratio: Integer;
begin
  Result := False;
  P := str + 1;

  while P < str + len - sublen do
  begin
    P1 := StrPosW(substr, sublen, P, str + len - P);

    if P1 = nil then Break;

    P2 := P1 - 1;

    if (P2^ >= '0') and (P2^ <= '9') then
    begin
      ratio := 1;
      number := 0;
      dot := False;
      while P2 >= str do
      begin
        if (P2^ >= '0') and (P2^ <= '9') then
        begin
          number := number + (Ord(P2^) and $0F) * ratio;
          ratio := ratio * 10;
        end
        else if P2^ = '.' then
        begin
          if dot then Break;

          dot := True;

          number := number / ratio;

          ratio := 1;
        end
        else Break;

        Dec(P2);
      end;

      Result := True;
      Break;
    end;

    P := P1 + sublen;
  end;

  if not Result then
    number := 0;
end;

function GetFloatBeforeA(const s, suffix: RawByteString;
  out number: Double): Boolean;
begin
  Result := GetFloatBeforeA(PAnsiChar(Pointer(s)), Length(s),
    PAnsiChar(Pointer(suffix)), Length(suffix), number);
end;

function UStrGetFloatBefore(const s, suffix: UnicodeString; out number: Double): Boolean;
begin
  Result := GetFloatBeforeW(PWideChar(Pointer(s)), Length(s),
    PWideChar(Pointer(suffix)), Length(suffix), number);
end;

function BStrGetFloatBefore(const s, suffix: WideString; out number: Double): Boolean;
begin
  Result := GetFloatBeforeW(PWideChar(Pointer(s)), Length(s),
    PWideChar(Pointer(suffix)), Length(suffix), number);
end;

function IsIntegerA(str: PAnsiChar; len: Integer): Boolean;
var
  i: Integer;
begin
  if len = 0 then Result := False
  else begin
    Result := True;

    for i := 0 to len - 1 do
    begin
      if (str[i] < '0') or (str[i] > '9') then
      begin
        Result := False;
        Break;
      end;
    end; 
  end;
end;

function IsIntegerA(const str: RawByteString): Boolean;
begin
  Result := IsIntegerA(PAnsiChar(str), Length(str));
end;


function IsIntegerW(str: PWideChar; len: Integer): Boolean;
var
  i: Integer;
begin
  if len = 0 then Result := False
  else begin
    Result := True;

    for i := 0 to len - 1 do
    begin
      if (str[i] < '0') or (str[i] > '9') then
      begin
        Result := False;
        Break;
      end;
    end; 
  end;
end;

function UStrIsInteger(const str: UnicodeString): Boolean;
begin
  Result := IsIntegerW(PWideChar(str), Length(str));
end;

function BStrIsInteger(const str: WideString): Boolean;
begin
  Result := IsIntegerW(PWideChar(str), Length(str));
end;

function CheckAccount(const str: RawByteString): Boolean;
//检测是否帐号，可以是邮箱
var
  i, Len: integer;
begin
  Result := False;

  Len := Length(str);

  if Len < 5 then Exit;

  for i := 1 to Len do
  begin
    if not (str[i] in ['0'..'9', 'a'..'z', 'A'..'Z', '@', '_', '.', '-']) then
      Exit;
  end;

  Result := True;
end;

function IsTencentQQIDA(const str: RawByteString): Boolean;
//检测是否有效的QQ号码
begin
  Result := (Length(str) >= 5) and (Length(str) <= 12) and IsIntegerA(str);
end;

//是否是18位身份证号码

function IsChinaIDCardNoA18(const idc18: RawByteString): Boolean;
const
  IDCBITS: array[1..18] of Integer =
  (7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1);
  CHECKSUMBITS: array[0..10] of AnsiChar =
  ('1', '0', 'x', '9', '8', '7', '6', '5', '4', '3', '2');
var
  checksum, i: Integer;
  ch: AnsiChar;
begin
  Result := False;

  if Length(idc18) <> 18 then Exit;

  if idc18[18] in ['x', 'X'] then
  begin
    if not IsIntegerA(PAnsiChar(idc18), 17) then Exit;
  end
  else if not IsIntegerA(idc18) then Exit;
  checksum := 0;
  for i := 1 to 17 do
  begin
    ch := idc18[i];
    Inc(checksum, (Byte(ch) and $0F) * IDCBITS[i]);
  end;
  if (idc18[18] = 'X') then ch := 'x'
  else ch := idc18[18];
  Result := CHECKSUMBITS[checksum mod 11] = ch;
end;

function IsChinaIDCardNoA(const idc: RawByteString): Boolean;
begin
  if (Length(idc) = 15) then Result := IsIntegerA(idc)
  else if (Length(idc) = 18) then Result := IsChinaIDCardNoA18(idc)
  else Result := False;
end;

function UStrIsChinaIDCardNo(const idc: UnicodeString): Boolean;
begin
  Result := False; 
end;

function BStrIsChinaIDCardNo(const idc: WideString): Boolean;
begin
  Result := False; 
end;

function IDCard15to18(const idc15: RawByteString; out idc18: RawByteString): Boolean;
const
  IDCBITS: array[1..18] of Integer =
    (7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1);

  CHECKSUMBITS: array[0..10] of AnsiChar =
    ('1', '0', 'x', '9', '8', '7', '6', '5', '4', '3', '2');
var
  checksum, i: Integer;
  ch: AnsiChar;
begin
  Result := False;
  if ((Length(idc15) <> 15) or not IsIntegerA(idc15)) then Exit;
  SetLength(idc18, 18);
  for i := 1 to 6 do idc18[i] := idc15[i];
  idc18[7] := '1';
  idc18[8] := '9';
  for i := 7 to 15 do idc18[i + 2] := idc15[i];
  checksum := 0;
  for i := 1 to 17 do
  begin
    ch := idc18[i];
    Inc(checksum, (Byte(ch) and $0F) * IDCBITS[i]);
  end;
  idc18[18] := CHECKSUMBITS[checksum mod 11];
  Result := True;
end;

procedure StreamWriteStrA(stream: TStream; const str: RawByteString);
begin
  if str <> '' then
    stream.write(Pointer(str)^, Length(str));
end;

procedure ThreadListAdd(list: TThreadList; item: Pointer);
var
  _list: TList;
begin
  _list := list.LockList;
  try
    _list.Add(item);
  finally
    list.UnlockList;
  end;
end;

function ThreadListGetItem(list: TThreadList; index: Integer): Pointer;
var
  _list: TList;
begin
  _list := list.LockList;
  try
    Result := _list[index];
  finally
    list.UnlockList;
  end;
end;

function ThreadListGetInternalList(list: TThreadList): TList;
begin
  Result := list.LockList;
  list.UnlockList;
end;

function ThreadListGetCount(list: TThreadList): Integer;
var
  InternalList: TList;
begin
  InternalList := list.LockList;

  try
    Result := InternalList.Count;
  finally
    list.UnlockList;
  end;
end;

procedure ThreadListInsert(list: TThreadList; index: Integer; item: Pointer);
var
  _list: TList;
begin
  _list := list.LockList;

  try
    _list.Insert(index, item);
  finally
    list.UnlockList;
  end;
end;

procedure ClearObjectList(objlist: TObject);
var
  i: Integer;
  list: TList;
begin
  if Assigned(objlist) then
  begin
    if objlist is TList then
    begin
      list := TList(objlist);

      for i := 0 to list.Count - 1 do
        TObject(list[i]).Free;

      list.Clear;
    end
    else if objlist is TThreadList then
    begin
      list := TThreadList(objlist).LockList;
      try
        for i := 0 to list.Count - 1 do
          TObject(list[i]).Free;

        list.Clear;
      finally
        TThreadList(objlist).UnlockList;
      end;
    end
    else if objlist is DSLCircularList then
    begin
      for i := 0 to DSLCircularList(objlist).Count - 1 do
        TObject(DSLCircularList(objlist)[i]).Free;

      DSLCircularList(objlist).Clear;
    end;
  end;
end;

procedure ClearObjectListAndFree(objlist: TObject);
begin
  if Assigned(objlist) then
  begin
    ClearObjectList(objlist);
    objlist.Free;
  end;
end;

function ControlFindContainer(control: TControl; cls: TClass): TWinControl;
begin
  Result := control.Parent;
  while Assigned(Result) do
  begin
    if not Assigned(cls) or (Result is cls) then
      Break;

    Result := Result.Parent;
  end;
end;

function ControlFindChild(container: TWinControl; cls: TClass): TControl;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to container.ControlCount - 1 do
  begin
    if container.Controls[i].InheritsFrom(cls) then
    begin
      Result := container.Controls[i];
      Break;
    end;
  end;
end;

function ControlVisible(ctrl: TControl): Boolean;
begin
  while Assigned(ctrl) and ctrl.Visible do
    ctrl := ctrl.Parent;

  Result := not Assigned(ctrl);
end;

procedure ControlSetFocus(ctrl: TWinControl);
begin
  try
    if ControlVisible(ctrl) then
      ctrl.SetFocus;
  except

  end;
end;

procedure EditSetNumberOnly(edit: TWinControl);
begin
  SetWindowLong(edit.Handle, GWL_STYLE, GetWindowLong(edit.Handle, GWL_STYLE) or ES_NUMBER);
end;

procedure CloseForm(form: TCustomForm);
begin
  if fsModal in form.FormState then
    form.ModalResult := mrCancel
  else
    form.Close;
end;

procedure ListViewSetRowCount(ListView: TListView; count: Integer);
var
  TopIndex, ItemIndex: Integer;
begin
  try
    TopIndex := ListView_GetTopIndex(ListView.Handle);
    ItemIndex := ListView.ItemIndex;
    ListView.Items.Count := count;

    if TopIndex <> -1 then
    begin
      TopIndex := TopIndex + ListView.VisibleRowCount - 1;

      if TopIndex >= count then
        TopIndex := count - 1;

      if TopIndex <> -1 then
        ListView.Items[TopIndex].MakeVisible(False);
    end;

    if ItemIndex >= count then ItemIndex := count - 1;

    ListView.ItemIndex := ItemIndex;

    ListView.Refresh;
  except
  end;
end;

//弹出提示对话框

procedure ShowInfoDialog(const msg: string; hwnd: THandle);
begin
  Application.MessageBox(PChar(Msg), '提示', MB_ICONINFORMATION or MB_OK);
end;

//弹出错误对话框

procedure ShowErrorDialog(const msg: string; hwnd: THandle);
begin
  Application.MessageBox(PChar(Msg), '错误', MB_ICONERROR or MB_OK);
end;

procedure ShowWarnDialog(const msg: string; hwnd: THandle = 0);
begin
  Application.MessageBox(PChar(Msg), '警告', MB_ICONEXCLAMATION or MB_OK);
end;

function ConfirmDialog(const msg: string; const parent: THandle = 0; const title: string = '';
  const buttons: DSLConfirmDlgButtons = cdbYesNo): DSLConfirmDlgResult;
var
  _title: string;
begin
  if title = '' then _title := '确认'
  else _title := title;

  Result := DSLConfirmDlgResult(Application.MessageBox(PChar(msg), PChar(_title),
    MB_ICONQUESTION or Ord(buttons)) - 1);
end;

function InternetExplorerGetCookie(const url: PAnsiChar; HttpOnly: Boolean): RawByteString;
const
  INTERNET_COOKIE_HTTPONLY = 8192;
var
  hModule: THandle;

  fnInternetGetCookie: function(lpszUrl, lpszCookieName, lpszCookieData: PAnsiChar;
    lpdwSize: PDWORD): BOOL; stdcall;

  fnInternetGetCookieEx: function(lpszUrl, lpszCookieName, lpszCookieData: PAnsiChar;
    lpdwSize: PDWORD; dwFlags: DWORD; lpReserved: Pointer): BOOL; stdcall;

  CookieSize: DWORD;
  flags: DWORD;
  LastError: Integer;
  dummy: Integer;
begin
  Result := '';
  hModule := LoadLibrary('wininet.dll');

  if hModule <> 0 then
  try
    fnInternetGetCookieEx := GetProcAddress(hModule, 'InternetGetCookieExA');

    if Assigned(fnInternetGetCookieEx) then
    begin
      if HttpOnly then flags := INTERNET_COOKIE_HTTPONLY
      else flags := 0;

      CookieSize := 0;

      if not fnInternetGetCookieEx(url, nil, PAnsiChar(@dummy), @CookieSize, flags, nil) then
      begin
        LastError := GetLastError;

        if LastError = ERROR_INSUFFICIENT_BUFFER then
        begin
          SetLength(Result, CookieSize);

          if not fnInternetGetCookieEx(url, nil, PAnsiChar(Result), @CookieSize, flags, nil) then
            Result := '';
        end;
      end;
    end
    else begin
      fnInternetGetCookie := GetProcAddress(hModule, 'InternetGetCookieA');

      if Assigned(fnInternetGetCookie) then
      begin

        CookieSize := 0;

        if not fnInternetGetCookie(url, nil, PAnsiChar(@dummy), @CookieSize) then
        begin
          LastError := GetLastError;

          if LastError = ERROR_INSUFFICIENT_BUFFER then
          begin
            SetLength(Result, CookieSize);

            if not fnInternetGetCookie(url, nil, PAnsiChar(Result), @CookieSize) then
              Result := '';
          end;
        end;
      end;
    end;
  finally
    FreeLibrary(hModule);
  end;
end;

function SHCreateShortcut(const TargetFile, desc, CreateAt: string): Boolean;
const
  IID_IPersistFile: TGUID = '{0000010B-0000-0000-C000-000000000046}';
var
  intfLink: IShellLink;
  IntfPersist: IPersistFile;
begin
  Result := False;
  
  IntfLink := CreateComObject(CLSID_ShellLink) as IShellLink;

  if (IntfLink <> nil) and SUCCEEDED(
    IntfLink.QueryInterface(IID_IPersistFile, IntfPersist)) and
    SUCCEEDED(intfLink.SetPath(PChar(TargetFile))) then
  begin
    intfLink.SetDescription(PChar(desc));

    if SUCCEEDED(IntfPersist.Save(PWideChar(UnicodeString(CreateAt)), True)) then
      Result := True;
  end;
end;

function FindChildWindowRecursive(parent: HWND; WndClassName, WndText: PWideChar): HWND;
var
  tmp, wnd: HWND;
begin
  Result := 0;

  wnd := FindWindowExW(parent, 0, WndClassName, WndText);

  if wnd <> 0 then Result := wnd
  else begin
    tmp := GetWindow(parent, GW_CHILD);

    while tmp <> 0 do
    begin
      wnd := FindChildWindowRecursive(tmp, WndClassName, WndText);

      if wnd <> 0 then
      begin
        Result := wnd;
        Break;
      end
      else tmp := GetWindow(tmp, GW_HWNDNEXT);
    end;
  end;
end;

function SHGetTargetOfShortcut(const LinkFile: string): string;
const
  IID_IPersistFile: TGUID = '{0000010B-0000-0000-C000-000000000046}';
var
  intfLink: IShellLink;
  IntfPersist: IPersistFile;
  pfd: _WIN32_FIND_DATA;
  bSuccess: Boolean;
begin
  Result := '';
  IntfLink := CreateComObject(CLSID_ShellLink) as IShellLink;
  SetString(Result, nil, MAX_PATH);

  bSuccess := (IntfLink <> nil) and SUCCEEDED(
    IntfLink.QueryInterface(IID_IPersistFile, IntfPersist))
    and SUCCEEDED(IntfPersist.Load(PWideChar(UnicodeString(LinkFile)), STGM_READ)) and
    SUCCEEDED(intfLink.GetPath(PChar(Result), MAX_PATH, pfd, SLGP_RAWPATH));

  if not bSuccess then Result := '';
end;

function SHGetSpecialFolderPath(FolderID: TSpecialFolderID): string;
var
  pidl: PItemIDList;
  buf: array [0..MAX_PATH] of Char;
begin
  Result := '';

  if Succeeded(SHGetSpecialFolderLocation(0, Ord(FolderID), pidl)) then
  begin
    if SHGetPathFromIDList(PIDL, buf) then
      Result := StrPas(buf);
      
    CoTaskMemFree(pidl);
  end;
end;

procedure HeapAdjust(pArray: Pointer; nItemSize, nItemCount: LongWord;
  iRoot: LongWord; pCompare: DSLPointerCompareProc; pSwap: DSLPointerProc); forward;

procedure HeapSort(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; pSwap: DSLPointerProc);
var
  i: LongWord;
begin
  for i := nItemCount shr 1 - 1 downto 0 do
  begin
    HeapAdjust(pArray, nItemSize, nItemCount, i, pCompare, pSwap);
  end;
  for i := nItemCount - 1 downto 1 do
  begin
    pSwap(pArray, Pointer(LongWord(pArray) + nItemSize * i));
    HeapAdjust(pArray, nItemSize, i, 0, pCompare, pSwap);
  end;
end;

procedure QuickSort(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; pSwap: DSLPointerProc);
var
  i, j, pidx: LongWord;
  LItem, RItem, Pivot: Pointer;
  LIndex, RIndex: LongWord;
begin
  LIndex := 0;
  RIndex := nItemCount - 1;
  while LIndex < RIndex do
  begin
    i := LIndex;
    j := RIndex;
    pidx := (i + j) shr 1;
    Pivot := Pointer(LongWord(pArray) + nItemSize * pidx);
    repeat
      while pCompare(Pointer(LongWord(pArray) + nItemSize * i), Pivot) < 0 do Inc(i);
      while pCompare(Pointer(LongWord(pArray) + nItemSize * j), Pivot) > 0 do Dec(j);
      if i < j then
      begin
        LItem := Pointer(LongWord(pArray) + nItemSize * i);
        RItem := Pointer(LongWord(pArray) + nItemSize * j);
        pSwap(LItem, RItem);
        if i = pidx then
        begin
          pidx := j;
          Pivot := RItem;
        end
        else if j = pidx then
        begin
          pidx := i;
          Pivot := LItem;
        end;
        Inc(i);
        Dec(j);
      end
      else if i = j then Inc(i);
    until i >= j;
    if LIndex < j then
      QuickSort(Pointer(LongWord(pArray) + nItemSize * LIndex),
        nItemSize, j - LIndex + 1, pCompare, pSwap);
    LIndex := i;
  end;
end;

function BinarySearch(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; const Value): Integer;
var
  L, R, M, CR: Integer;
  ItemAddr: Pointer;
begin
  L := 0;
  R := nItemCount - 1;
  while L <= R do
  begin
    M := (L + R) shr 1;
    ItemAddr := Pointer(LongWord(pArray) + nItemSize * LongWord(M));
    CR := pCompare(ItemAddr, @Value);
    if CR = 0 then
    begin
      Result := M;
      Exit;
    end;
    if CR > 0 then R := M - 1
    else L := M + 1;
  end;
  Result := -1;
end;

function BinarySearchInsertPos(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; const Value): Integer;
var
  L, R, M, CR: Integer;
  ItemAddr: Pointer;
begin
  L := 0;
  R := nItemCount - 1;
  while L <= R do
  begin
    M := (L + R) shr 1;
    ItemAddr := Pointer(LongWord(pArray) + nItemSize * LongWord(M));
    CR := pCompare(ItemAddr, @Value);
    if CR = 0 then
    begin
      Result := M;
      Exit;
    end;

    if CR > 0 then
    begin
      if (M = L) or (pCompare(Pointer(LongWord(ItemAddr) - nItemSize), @Value) <= 0) then
      begin
        Result := M;
        Exit;
      end;
      R := M - 1;
      Continue;
    end;

    if (M = R) or (pCompare(Pointer(LongWord(ItemAddr) + nItemSize), @Value) >= 0) then
    begin
      Result := M + 1;
      Exit;
    end;
    L := M + 1;
  end;
  Result := 0;
end;

function Search(pArray: Pointer; nItemSize, nItemCount: LongWord;
  pCompare: DSLPointerCompareProc; const Value): Integer;
var
  i: LongWord;
begin
  Result := -1;
  if nItemCount = 0 then Exit;
  for i := 0 to nItemCount - 1 do
  begin
    if pCompare(Pointer(LongWord(pArray) + nItemSize * i), @Value) = 0 then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure HeapAdjust(pArray: Pointer; nItemSize, nItemCount, iRoot: LongWord;
  pCompare: DSLPointerCompareProc; pSwap: DSLPointerProc);
var
  iChild: LongWord;
  Parent, Child1, Child2: Pointer;
begin
  iChild := 2 * iRoot + 1;
  while iChild < nItemCount do
  begin
    Parent := Pointer(LongWord(pArray) + nItemSize * iRoot);
    Child1 := Pointer(LongWord(pArray) + nItemSize * iChild);
    if iChild < nItemCount - 1 then
    begin
      Child2 := Pointer(LongWord(Child1) + nItemSize);
      if pCompare(Child1, Child2) < 0 then
      begin
        Child1 := Child2;
        Inc(iChild);
      end;
    end;
    if pCompare(Parent, Child1) < 0 then
    begin
      pSwap(Parent, Child1);
      iRoot := iChild;
      iChild := iRoot * 2 + 1;
    end
    else Break;
  end;
end;

function CompareCodePageName(Name1, Name2: PAnsiChar;
  Len1, Len2: Integer): Integer; overload;
var
  i: Integer;
  C1, C2: AnsiChar;
begin
  if Len1 > Len2 then Result := 1
  else if Len1 < Len2 then Result := -1
  else begin
    for i := Len1 - 1 downto 0 do
    begin
      C1 := Name1[i];
      if C1 in ['A'..'Z'] then C1 := AnsiChar(Byte(C1) or $20);
      C2 := Name2[i];
      if C2 in ['A'..'Z'] then C2 := AnsiChar(Byte(C2) or $20);
      if C1 = C2 then Continue;
      if C1 > C2 then Result := 1
      else Result := -1;
      Exit;
    end;
    Result := 0;
  end;
end;

function CompareCodePageName(const Name1, Name2: AnsiString): Integer; overload;
begin
  Result := CompareCodePageName(PAnsiChar(Name1), PAnsiChar(Name2),
    Length(Name1), Length(Name2));
end;

type
  TAnsiStrPtrAndLen = record
    Ptr: PAnsiChar;
    Len: Integer;
  end;
  PAnsiStrPtrAndLen = ^TAnsiStrPtrAndLen;

function CodePageNameSearchCmp(First: PCodePage; Second: PAnsiStrPtrAndLen): Integer;
begin
  Result := CompareCodePageName(PAnsiChar(First^.Name), Second^.Ptr,
    Length(First^.Name), Second^.Len);
end;

function CodePageName2ID(Name: PAnsiChar; NameLen: Integer): Integer;
var
  PtrLen: TAnsiStrPtrAndLen;
begin
  PtrLen.Ptr := Name; PtrLen.Len := NameLen;
  Result := BinarySearch(@NAME_SORTED_CODE_PAGES, SizeOf(DSLCodePageInfo),
    Length(NAME_SORTED_CODE_PAGES), @CodePageNameSearchCmp, PtrLen);
  if Result >= 0 then Result := NAME_SORTED_CODE_PAGES[Result].ID;
end;

function CodePageName2ID(const Name: AnsiString): Integer;
begin
  Result := CodePageName2ID(PAnsiChar(Name), Length(Name));
end;

function CodePageIDSearchCmp(First: PCodePage; Second: PInteger): Integer;
begin
  Result := First^.ID - Second^;
end;

function CodePageID2Name(ID: Integer): AnsiString; overload;
var
  Index: Integer;
begin
  Index := BinarySearch(@ID_SORTED_CODE_PAGES, SizeOf(DSLCodePageInfo),
    Length(ID_SORTED_CODE_PAGES), @CodePageIDSearchCmp, ID);
  if Index >= 0 then Result := ID_SORTED_CODE_PAGES[Index].Name
  else Result := '';
end;

{ DSLRefCountedObject }

function DSLRefCountedObject.AddRef: Integer;
begin
  if Self <> nil then
    Result := InterlockedIncrement(fRefCount)
  else
    Result := 0;
end;

constructor DSLRefCountedObject.Create;
begin
  fRefCount := 1;
end;

function DSLRefCountedObject.Release: Integer;
begin
  if Self <> nil then
  begin
    Result := InterlockedDecrement(fRefCount);

    if Result = 0 then
      Destroy;
  end
  else Result := 0;
end;

{ DSLSignalThread }

constructor DSLSignalThread.Create(CreateSuspended: Boolean);
begin
  fStopSignal := CreateEvent(nil, False, False, nil);
  inherited Create(Suspended);
end;

destructor DSLSignalThread.Destroy;
begin
  CloseHandle(fStopSignal);
  inherited;
end;

procedure DSLSignalThread.SendStopSignal;
begin
  SetEvent(fStopSignal);
end;

procedure DSLSignalThread.StopAndWait;
begin
  Self.Terminate;
  Self.SendStopSignal;
  Self.WaitFor;
end;

function DSLSignalThread.WaitForMultiObjects(handles: array of THandle; timeout: DWORD): DWORD;
var
  WaitHandles: TWOHandleArray;
  i, j: DWORD;
  wr: DWORD;
begin
  WaitHandles[0] := Self.fStopSignal;

  j := 1;

  for i := Low(handles) to High(handles) do
  begin
    WaitHandles[j] := handles[i];
    Inc(j);
  end;

  wr := WaitForMultipleObjectsEx(j, @WaitHandles, False, timeout, True);

  if wr = WAIT_OBJECT_0 then Result := WAIT_TIMEOUT
  else if (wr > WAIT_OBJECT_0) and (wr < WAIT_OBJECT_0 + j) then
    Result := wr - 1
  else Result := wr;
end;

function DSLSignalThread.WaitForSingleObject(handle: THandle; timeout: DWORD): DWORD;
var
  handles: array [0..0] of THandle;
begin
  handles[0] := handle;
  Result := Self.WaitForMultiObjects(handles, timeout);
end;

function DSLSignalThread.WaitForStopSignal(timeout: DWORD): Boolean;
begin
  Result := WaitForSingleObjectEx(fStopSignal, timeout, True) = WAIT_OBJECT_0;
end;

{ DSLWorkThread }

procedure DSLWorkThread.ClearTask;
var
  task: DSLRunnable;
begin
  while True do
  begin
    task := DSLRunnable(fTaskQueue.pop);

    if Assigned(task) then task.Release
    else Break;
  end;
end;

constructor DSLWorkThread.Create(CreateSuspended: Boolean);
begin
  fTaskSemaphore := CreateEvent(nil, False, False, nil); 
  fTaskQueue := DSLFIFOQueue.Create;
  inherited Create(CreateSuspended);
end;

destructor DSLWorkThread.Destroy;
begin
  Self.ClearTask;
  fTaskQueue.Free;
  CloseHandle(fTaskSemaphore);
  inherited;
end;

procedure DSLWorkThread.Execute;
var
  task: DSLRunnable;
begin
  inherited;

  while not Self.Terminated  do
  begin
    try
      fWaitingForTask := True;

      if Self.WaitForSingleObject(fTaskSemaphore) <> WAIT_OBJECT_0 then Continue;

      fWaitingForTask := False;

      while not Self.Terminated do
      begin      
        task := DSLRunnable(fTaskQueue.pop);

        if not Assigned(task) then Break;

        Inc(fCompletedTaskCount);

        try
          fCurrentTaskName := task.ClassName;
          task.run(Self);
        except
          on e: Exception do
            DbgOutput(DSLRunnable.ClassName + '.run: ' + e.Message);
        end;

        fCurrentTaskName := '';

        task.Release;
      end;
    except
      on e: Exception do
        DbgOutputException('DSLWorkThread.Execute', e);
    end;
  end;
end;

function DSLWorkThread.GetPendingTaskCount: Integer;
begin
  Result := fTaskQueue.size;
end;

function DSLWorkThread.QueueTask(task: DSLRunnable): Boolean;
begin
  fTaskQueue.push(task);

  SetEvent(fTaskSemaphore);

  Result := True;
end;

function DSLWorkThread.QueueTaskFirst(task: DSLRunnable): Boolean;
begin
  fTaskQueue.PushFront(task);

  SetEvent(fTaskSemaphore);

  Result := True;
end;

{ DSLDelayRunnableThread }


constructor DSLDelayRunnableThread.Create(CreateSuspended: Boolean);
begin
  fTaskQueue := DSLDelayRunnableQueue.Create;
  fTaskEvent := CreateEvent(nil, False, False, nil);
  inherited Create(CreateSuspended);
end;

destructor DSLDelayRunnableThread.Destroy;
begin
  fTaskQueue.Free;
  CloseHandle(fTaskEvent);
  inherited;
end;

procedure DSLDelayRunnableThread.Execute;
var
  task: DSLRunnable;
  delay: DWORD;
begin
  inherited;

  while not Self.Terminated do
  begin
    try
      task := fTaskQueue.pop(delay);

      if Assigned(task) then
      begin
        try
          task.run(Self);
        except
          on e: Exception do
            DbgOutput(DSLRunnable.ClassName + '.run: ' + e.Message);
        end;

        Inc(fCompletedTaskCount);

        task.Release;
      end
      else Self.WaitForSingleObject(fTaskEvent, delay);
    except
      on e: Exception do
        DbgOutput('DSLDelayRunnableThread.loop: ' + e.Message);
    end;
  end;
end;

function DSLDelayRunnableThread.GetPendingTaskCount: Integer;
begin
  Result := fTaskQueue.size;
end;

function DSLDelayRunnableThread.QueueTask(task: DSLRunnable; DelayMS: Int64): Boolean;
begin
  Result := fTaskQueue.push(task, DelayMS);

  if Result then SetEvent(fTaskEvent);
end;

function DSLDelayRunnableThread.QueueTask(task: DSLRunnable; runtime: TDateTime): Boolean;
begin
  Result := fTaskQueue.push(task, runtime);

  if Result then SetEvent(fTaskEvent);
end;

{ DSLWorkThreadPool }

constructor DSLWorkThreadPool.Create;
begin
  fActive := False;
  fThreads := TList.Create;
  fThreadCount := 1;
end;

destructor DSLWorkThreadPool.Destroy;
begin
  Active := False;
  fThreads.Free;
  inherited;
end;

function DSLWorkThreadPool.QueueTask(task: DSLRunnable): Boolean;
begin
  if fActive then
    Result := DSLWorkThread(fThreads[Random(fThreads.Count)]).QueueTask(task)
  else
    Result := False;
end;

procedure DSLWorkThreadPool.SetActive(const Value: Boolean);
begin
  if fActive <> Value then
  begin
    fActive := Value;
    if fActive then start
    else Self.stop;
  end;
end;

procedure DSLWorkThreadPool.SetThreadCount(const Value: Integer);
begin
  if not fActive then
  begin
    fThreadCount := Value;

    if fThreadCount <= 0 then
      fThreadCount := 1;
  end;
end;

procedure DSLWorkThreadPool.start;
var
  i: Integer;
begin
  fThreads.Count := fThreadCount;

  for i := 0 to fThreads.Count - 1 do
    fThreads[i] := ThreadClass.Create(False);
end;

procedure DSLWorkThreadPool.stop;
begin
  StopAndWaitForThread(fThreads);
end;

{ DSLCircularList }

procedure DSLCircularList.add(Item: Pointer);
var
  i: Integer;
begin
  if fCount = fCapacity then
    TList.Error(SListCapacityError, fCapacity)
  else begin
    i := (fFirst + fCount) mod fCapacity;
    fList[i] := Item;
    Inc(fCount);
  end;
end;

function DSLCircularList.add: Pointer;
var
  i: Integer;
begin
  if fCount = fCapacity then
    TList.Error(SListCapacityError, fCapacity);

  i := (fFirst + fCount) mod fCapacity;
  Inc(fCount);
  Result := fList[i];
end;

procedure DSLCircularList.clear;
begin
  fFirst := 0;
  fCount := 0;
end;

constructor DSLCircularList.Create(_capacity: Integer);
begin
  SetLength(fList, _capacity);
  fCapacity := _capacity;
  fCount := 0;
  fFirst := 0;
end;

procedure DSLCircularList.delete(Index: Integer);
var
  I, J, K: Integer;
begin
  if (Index < 0) or (Index >= fCount) then
    TList.Error(SListIndexError, Index);

  if Index = 0 then MoveHead(1)
  else if Index < fCount - 1 then
  begin
    I := fFirst + Index;

    if I >= fCapacity then
    begin
      J := I mod fCapacity;

      K := (fFirst + fCount - 1) mod fCapacity;

      Move(fList[J + 1], fList[J], (K - J) * SizeOf(Pointer));
    end
    else begin
      for K := I - 1 downto fFirst do
        fList[K + 1] := fList[K];

      MoveHead(1);
    end;
  end;

  Dec(fCount);
end;

destructor DSLCircularList.Destroy;
begin
  SetLength(fList, 0);
  inherited;
end;

function DSLCircularList.GetItem(Index: Integer): Pointer;
begin
  if (Index < 0) or (Index >= fCount) then
    TList.Error(SListIndexError, Index);

  Result := fList[(fFirst + Index) mod fCapacity];
end;

function DSLCircularList.GetInternalIndex(Index: Integer): Integer;
begin
  Result := (fFirst + index) mod fCapacity;
end;

function DSLCircularList.IndexOf(Item: Pointer): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to fCount - 1 do
  begin
    if fList[(fFirst + i) mod fCapacity] = Item then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure DSLCircularList.MoveHead(num: Integer);
begin
  if num <= fCount then
  begin
    fFirst := (fFirst + num) mod fCapacity;
    Dec(fCount, num);

    if fCount = 0 then
      fFirst := 0;
  end;
end;

function DSLCircularList.remove(Item: Pointer): Integer;
begin
  Result := Self.IndexOf(Item);

  if Result >= 0 then
    Self.Delete(Result);
end;

procedure DSLCircularList.SetCount(const Value: Integer);
begin
  if Value > Capacity then Exit;

  fCount := Value;
end;

procedure DSLCircularList.SetItem(Index: Integer; const Value: Pointer);
begin
  if (Index < 0) or (Index >= fCount) then
    TList.Error(SListIndexError, Index);

  fList[(fFirst + Index) mod fCapacity] := Value;
end;

{ DSLFIFOQueue }

procedure DSLFIFOQueue.clear;
var
  node: PDSLLinkNode;
begin
  while InterlockedExchange(fLockState, 1) = 1 do;

  try
    while Assigned(fFirst) do
    begin
      node := fFirst;
      fFirst := fFirst.next;
      Dispose(node);
    end;

    fLast := nil;
    fSize := 0;
       
  finally
    InterlockedExchange(fLockState, 0);
  end;
end;

constructor DSLFIFOQueue.Create;
begin
  fLockState := 0;
  fFirst := nil;
  fLast := nil;
end;

destructor DSLFIFOQueue.Destroy;
begin
  Self.clear;
  inherited;
end;

function DSLFIFOQueue.pop: Pointer;
var
  node: PDSLLinkNode;
begin

  while InterlockedExchange(fLockState, 1) = 1 do;

  try
    node := fFirst;

    if Assigned(fFirst) then
    begin
      Result := node.data;

      fFirst := node.next;

      if not Assigned(fFirst) then
        fLast := nil;

      Dec(fSize);
    end
    else Result := nil;
  finally
    InterlockedExchange(fLockState, 0);
  end;

  if Assigned(node) then Dispose(node);
end;

procedure DSLFIFOQueue.push(item: Pointer);
var
  node: PDSLLinkNode;
begin
  New(node);
  node.data := item;
  node.next := nil;

  while InterlockedExchange(fLockState, 1) = 1 do;

  try
    if Assigned(fFirst) then
    begin
      fLast.next := node;
      fLast := node;
    end
    else begin
      fFirst := node;
      fLast := node;
    end;

    Inc(fSize);
  finally
    InterlockedExchange(fLockState, 0);
  end;
end;

procedure DSLFIFOQueue.PushFront(item: Pointer);
var
  node: PDSLLinkNode;
begin
  New(node);
  node.data := item;
  node.next := nil;

  while InterlockedExchange(fLockState, 1) = 1 do;

  try
    node.next := fFirst;
    fFirst := node;

    if not Assigned(node.next) then fLast := node;

    Inc(fSize);
  finally
    InterlockedExchange(fLockState, 0);
  end;
end;

{ DSLLIFOQueue }

procedure DSLLIFOQueue.clear;
var
  node: PDSLLinkNode;
begin
  while InterlockedExchange(fLockState, 1) = 1 do;

  try
    while Assigned(fFirst) do
    begin
      node := fFirst;
      fFirst := fFirst.next;
      Dispose(node);
    end;
       
  finally
    InterlockedExchange(fLockState, 0);
  end;
end;

constructor DSLLIFOQueue.Create;
begin
  fFirst := nil;
  fLockState := 0;
end;

destructor DSLLIFOQueue.Destroy;
begin
  Self.clear;
  inherited;
end;

function DSLLIFOQueue.pop: Pointer;
var
  node: PDSLLinkNode;
begin
  while InterlockedExchange(fLockState, 1) = 1 do;

  try
    node := fFirst;

    if Assigned(fFirst) then
    begin
      fFirst := fFirst.next;
      Result := node.data;
    end
    else Result := nil;
    
  finally
    InterlockedExchange(fLockState, 0);
  end;

  if Assigned(node) then Dispose(node);
end;

procedure DSLLIFOQueue.push(item: Pointer);
var
  node: PDSLLinkNode;
begin
  New(node);
  node.data := item;

  while InterlockedExchange(fLockState, 1) = 1 do;

  try
    node.next := fFirst;
    fFirst := node;
  finally
    InterlockedExchange(fLockState, 0);
  end;
end;

{ DSLLogWritter }

procedure DSLLogWritter.write(sev: DSLMessageLevel; const text: RawByteString);
begin
  if sev in fVerbosity then
  begin
    if mtServerity in options then 
    begin 
      WriteAnsi(SEVERITY_NAMESA[sev]);
      WriteAnsi(':: ')
    end;
    if mtTime in options then
    begin
      WriteAnsi(RawByteString(FormatDateTime(DateTimeFormat, Now)));
      WriteAnsi(' ');
    end;
    WriteAnsi(text);
  end;
end;

procedure DSLLogWritter.write(sev: DSLMessageLevel; const text: UnicodeString);
begin
  if sev in fVerbosity then
  begin
    if mtServerity in options then 
    begin 
      WriteUnicode(SEVERITY_NAMESW[sev]);
      WriteAnsi(':: ')
    end;
    if mtTime in options then
    begin
      WriteUnicode(UnicodeString(FormatDateTime(DateTimeFormat, Now)));
      WriteUnicode(' ');
    end;
    WriteUnicode(text);
  end;
end;

procedure DSLLogWritter.writeln(sev: DSLMessageLevel; const text: RawByteString);
begin
  if sev in fVerbosity then
  begin
    if mtServerity in options then 
    begin 
      WriteAnsi(SEVERITY_NAMESA[sev]);
      WriteAnsi(':: ')
    end;
    
    if mtTime in options then
    begin
      WriteAnsi(RawByteString(FormatDateTime(DateTimeFormat, Now)));
      WriteAnsi(' ');
    end;
    WriteAnsi(text);
    WriteAnsi(#13#10);
  end;
end;

procedure DSLLogWritter.writeln(sev: DSLMessageLevel; const text: UnicodeString);
begin
  if sev in fVerbosity then
  begin
    if mtServerity in options then 
    begin 
      WriteUnicode(SEVERITY_NAMESW[sev]);
      WriteAnsi(':: ');
    end;
    if mtTime in options then
    begin
      WriteUnicode(UnicodeString(FormatDateTime(DateTimeFormat, Now)));
      WriteUnicode(' ');
    end;
    WriteUnicode(text);
    WriteUnicode(#13#10);
  end;
end;

constructor DSLLogWritter.Create;
begin
  fDateTimeFormat := 'yyyy-mm-dd hh:nn:ss';
  fVerbosity := TRACE_SEVERITIES_ALL;
  fOptions := [mtServerity, mtTime];
end;

procedure DSLLogWritter.FormatWrite(sev: DSLMessageLevel; const fmt: RawByteString;
  const args: array of const);
begin
  Self.write(sev, RawByteString(Format(string(fmt), args)));
end;

procedure DSLLogWritter.flush;
begin

end;

procedure DSLLogWritter.FormatWrite(sev: DSLMessageLevel; const fmt: UnicodeString;
  const args: array of const);
begin
  Self.write(sev, WideFormat(fmt, args));
end;

procedure DSLLogWritter.SetDateTimeFormat(const value: string);
begin
  DateTimeFormat := value;
end;

procedure DSLLogWritter.SetOptions(const value: DSLMessageTags);
begin
  options := value;
end;

procedure DSLLogWritter.SetVerbosity(const value: DSLMessageVerbosity);
begin
  fVerbosity := value;
end;

{ DSLFileLogWritter }

constructor DSLFileLogWritter.Create(const fileName: string);
begin
  inherited Create;

  fEncoding := teAnsi;

  if not FileExists(fileName) then
  begin
    ForceDirectories(ExtractFilePath(fileName));
    FileClose(FileCreate(fileName));
  end;

  fFileStream := TFileStream.Create(fileName, fmOpenReadWrite or fmShareDenyWrite);

  fFileStream.Seek(0, soFromEnd);
end;

destructor DSLFileLogWritter.Destroy;
begin
  fFileStream.Free;
  inherited;
end;

procedure DSLFileLogWritter.flush;
begin
  Windows.FlushFileBuffers(fFileStream.Handle);
end;

function DSLFileLogWritter.GetFileSize: Integer;
begin
  Result := fFileStream.Size;
end;

procedure DSLFileLogWritter.WriteAnsi(const text: RawByteString);
var
  utf8str: UTF8String;
  utf16str: UnicodeString;
begin
  case Encoding of
    teAnsi: fFileStream.write(text[1], Length(text));
    teUTF8:
      begin
        utf8str := UTF8EncodeUStr(UnicodeString(text));
        fFileStream.write(utf8str[1], Length(utf8str));
      end;
    teUTF16:
      begin
        utf16str := UnicodeString(text);
        fFileStream.write(utf16str[1], Length(utf16str) * 2);
      end;
  end;
end;

procedure DSLFileLogWritter.WriteUnicode(const text: UnicodeString);
var
  ansistr: RawByteString;
  utf8str: UTF8String;
begin
  case Encoding of
    teAnsi:
      begin
        ansistr := RawByteString(text);
        fFileStream.write(ansistr[1], Length(ansistr));
      end;
    teUTF8:
      begin
        utf8str := Utf8Encode(text);
        fFileStream.write(utf8str[1], Length(utf8str));
      end;
    teUTF16: fFileStream.write(text[1], Length(text) * 2);
  end;
end;

{ DSLConsoleLogWritter }

procedure DSLConsoleLogWritter.WriteAnsi(const text: RawByteString);
begin
  System.write(text);
end;

procedure DSLConsoleLogWritter.WriteUnicode(const text: UnicodeString);
begin
  System.write(text);
end;

{ DSLDebugLogWritter }

procedure DSLDebugLogWritter.WriteAnsi(const text: RawByteString);
begin
  OutputDebugStringA(PAnsiChar(text));
end;

procedure DSLDebugLogWritter.WriteUnicode(const text: UnicodeString);
begin
  OutputDebugStringW(PWideChar(text));
end;

{ TSliceLogWritter }

constructor DSLMultiFileLogWritter.Create(const dir: string);
begin
  inherited Create;
  fDateTimeFormat := 'yyyy-mm-dd hh:nn:ss';
  fVerbosity := TRACE_SEVERITIES_ALL;
  fOptions := [mtServerity, mtTime];
  fLogFileDir := dir;
  fLogSeparate := dtpDay;
  
  if fLogFileDir[Length(fLogFileDir)] <> '\' then
    fLogFileDir := fLogFileDir + '\';
end;

destructor DSLMultiFileLogWritter.Destroy;
begin
  fWritter.Free;
  inherited;
end;

procedure DSLMultiFileLogWritter.flush;
begin
  fWritter.flush;  
end;

procedure DSLMultiFileLogWritter.FormatWrite(sev: DSLMessageLevel;
  const fmt: UnicodeString; const args: array of const);
begin
  Self.write(sev, WideFormat(fmt, args));
end;

procedure DSLMultiFileLogWritter.FormatWrite(sev: DSLMessageLevel;
  const fmt: RawByteString; const args: array of const);
begin
  Self.write(sev, RawByteString(Format(string(fmt), args)));
end;

procedure DSLMultiFileLogWritter.CreateFileTracer(Tick: TDateTime);
var
  FileName: string;
  Changed: Boolean;
begin
  if fWritter = nil then Changed := True
  else begin
    case fLogSeparate of
      dtpYear: Changed := not SameYear(fLastLogTime, Tick);
      dtpMonth: Changed := not SameMonth(fLastLogTime, Tick);
      dtpDay: Changed := not SameDay(fLastLogTime, Tick);
      else Changed := not SameHour(fLastLogTime, Tick);
    end;
  end;

  if not Changed then Exit;

  fLastLogTime := Tick;
  case LogSeparate of
    dtpYear:FileName := fLogFileDir + FormatDateTime('yyyy', Tick) + '.log';
    dtpMonth:FileName := fLogFileDir + FormatDateTime('yyyymm', Tick) + '.log';
    dtpDay:FileName := fLogFileDir + FormatDateTime('yyyymmdd', Tick) + '.log';
    else FileName := fLogFileDir + FormatDateTime('yyyymmddhh', Tick) + '.log';
  end;

  fWritter := DSLFileLogWritter.Create(FileName);
  fWritter.Encoding := Encoding;
  fWritter.DateTimeFormat := DateTimeFormat;
  fWritter.options := options;
  fWritter.Verbosity := severity;
end;

procedure DSLMultiFileLogWritter.SetDateTimeFormat(const Value: string);
begin
  DateTimeFormat := Value;
  if fWritter <> nil then fWritter.DateTimeFormat := Value;
end;

procedure DSLMultiFileLogWritter.SetOptions(const Value: DSLMessageTags);
begin
  options := Value;
  if fWritter <> nil then fWritter.options := Value;
end;

procedure DSLMultiFileLogWritter.SetVerbosity(const Value: DSLMessageVerbosity);
begin
  severity := Value;
  if fWritter <> nil then fWritter.Verbosity := Value;
end;

procedure DSLMultiFileLogWritter.write(sev: DSLMessageLevel;
  const Text: UnicodeString);
begin
  CreateFileTracer(Now);
  fWritter.write(sev, Text);
end;

procedure DSLMultiFileLogWritter.writeln(sev: DSLMessageLevel; const Text: RawByteString);
begin
  CreateFileTracer(Now);
  fWritter.writeln(sev, Text);
end;

procedure DSLMultiFileLogWritter.writeln(sev: DSLMessageLevel; const Text: UnicodeString);
begin
  CreateFileTracer(Now);
  fWritter.writeln(sev, Text);
end;

procedure DSLMultiFileLogWritter.write(sev: DSLMessageLevel;
  const Text: RawByteString);
begin
  CreateFileTracer(Now);
  fWritter.write(sev, Text);
end;

{ DSLDelayRunnableQueue }

procedure DSLDelayRunnableQueue.clear;
var
  tmp: PDSLDelayRunnable;
begin
  EnterCriticalSection(fLock);

  try
    while Assigned(fFirstTask) do
    begin
      tmp := fFirstTask;
      fFirstTask := fFirstTask.next;
      tmp.task.Release;
      Dispose(tmp);
    end;

    fFirstTask := nil;
    fSize := 0;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

constructor DSLDelayRunnableQueue.Create;
begin
  InitializeCriticalSection(fLock);
end;

function DSLDelayRunnableQueue.pop(var delay: DWORD): DSLRunnable;
var
  node: PDSLDelayRunnable;
  dt: TDateTime;
  flag: Boolean;
begin
  EnterCriticalSection(fLock);

  flag := False;

  try
    node := fFirstTask;

    if not Assigned(node) then
    begin
      delay := INFINITE;
      Result := nil;
    end
    else begin
      dt := Now;

      if node.runtime <= dt then
      begin
        Result := node.task;
        FFirstTask := node.next;
        Dec(fSize);
        flag := True;
      end
      else begin
        delay := MilliSecondsBetween(dt, node.runtime);
        Result := nil;
      end;
    end;

  finally
    LeaveCriticalSection(fLock);
  end;

  if flag then
    Dispose(node);
end;

destructor DSLDelayRunnableQueue.Destroy;
begin
  Self.clear;
  DeleteCriticalSection(fLock);
  inherited;
end;

function DSLDelayRunnableQueue.push(task: DSLRunnable; DelayMS: Int64): Boolean;
var
  dt: TDateTime;
begin
  dt := IncMilliSecond(Now, DelayMS);
  Result := Self.push(task, dt);
end;

function DSLDelayRunnableQueue.push(task: DSLRunnable; runtime: TDateTime): Boolean;
var
  n1, n2, node: PDSLDelayRunnable;
begin
  New(node);
  node.task := task;
  node.Runtime := Runtime;

  EnterCriticalSection(fLock);
  try
    n1 := nil;
    n2 := fFirstTask;

    while Assigned(n2) and (n2.runtime < runtime) do
    begin
      n1 := n2;
      n2 := n2.next;
    end;

    node.next := n2;

    if Assigned(n1) then n1.next := node
    else begin
      fFirstTask := node;
    end;

    Inc(fSize);

    Result := True;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ DSLAutoObject }

constructor DSLAutoObject.Create(_instance: TObject);
begin
  fInstance := _instance;
end;

destructor DSLAutoObject.Destroy;
begin
  fInstance.Free;
  inherited;
end;

function DSLAutoObject.GetInstance: TObject;
begin
  Result := fInstance;
end;

procedure SwapCodePage(First, Second: PCodePage);
var
  Temp: DSLCodePageInfo;
begin
  Temp := First^;
  First^ := Second^;
  Second^ := Temp;
end;

function CompareCodePageByName(First, Second: PCodePage): Integer;
begin
  Result := CompareCodePageName(First^.Name, Second^.Name);
end;

function CompareCodePageByID(First, Second: PCodePage): Integer;
begin
  Result := First^.ID - Second^.ID;
end;

{ DSLFileStream }

constructor DSLFileStream.Create(const AFileName: string; Mode: Word);
begin
  inherited;
  fLock := TCriticalSection.Create;
end;

constructor DSLFileStream.Create(const AFileName: string; Mode: Word; Rights: Cardinal);
begin
  inherited;
  fLock := TCriticalSection.Create;
end;

destructor DSLFileStream.Destroy;
begin
  fLock.Free;
  inherited;
end;

procedure DSLFileStream.lock;
begin
  fLock.Enter;
end;

procedure DSLFileStream.unlock;
begin
  fLock.Leave;
end;

initialization
  JAVA_TIME_START := EncodeDateTime(1970, 1, 1, 0, 0, 0, 0);

  QuickSort(@NAME_SORTED_CODE_PAGES, SizeOf(DSLCodePageInfo), Length(NAME_SORTED_CODE_PAGES),
    @CompareCodePageByName, @SwapCodePage);

  QuickSort(@ID_SORTED_CODE_PAGES, SizeOf(DSLCodePageInfo), Length(ID_SORTED_CODE_PAGES),
    @CompareCodePageByID, @SwapCodePage);

end.

