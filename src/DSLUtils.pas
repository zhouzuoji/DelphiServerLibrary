{$B-,C+,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,U-,V+,W-,X+,Z1}
{$O+}   // optimization on
{$T+}   // typed pointers on
{$POINTERMATH ON}
{$DEFINE USE_RTL_POW10}
{$DEFINE SIGNEDINT_TO_STR_ASM}
unit DSLUtils;

interface

uses
  AnsiStrings, DSLAnsiFunctions, SysUtils, Classes, Types, SysConst, Windows, MMSystem, WinSvc,
  Generics.Collections, ShellAPI, PsAPI, StrUtils, DateUtils, Controls, RTLConsts, WideStrings, Math,
  Dialogs, Forms, Graphics, ComCtrls, CommCtrl, ComObj, ShlObj, ActiveX, Variants, VarUtils,
  SyncObjs, Contnrs, TlHelp32, ZLibExApi;

type
{$ifndef  unicode}
  UnicodeString = WideString;
  PUnicodeString = PWideString;
  RawByteString = AnsiString;
  PRawByteString = ^AnsiString;
{$endif}
  AsciiString = RawByteString;

{$if not declared(u16string)}
  u16string = UnicodeString;
  pu16string = PUnicodeString;
{$ifend}

  TCharCase = (ccUpper, ccNormal, ccLower);

const
  _0to99A: packed array [0 .. 99] of RawByteString = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12',
    '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31',
    '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',
    '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
    '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88',
    '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99');

  _0to99UStr: packed array [0 .. 99] of u16string = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12',
    '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31',
    '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',
    '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
    '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88',
    '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99');

  CASE_CHAR_TABLE: array [TCharCase] of array [AnsiChar] of AnsiChar = ((#0, #1, #2, #3, #4, #5, #6, #7, #8, #9, #10,
      #11, #12, #13, #14, #15, #16, #17, #18, #19, #20, #21, #22, #23, #24, #25, #26, #27, #28, #29, #30, #31, #32,
      #33, #34, #35, #36, #37, #38, #39, #40, #41, #42, #43, #44, #45, #46, #47, '0', '1', '2', '3', '4', '5', '6',
      '7', '8', '9', #58, #59, #60, #61, #62, #63, #64, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
      'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', #91, #92, #93, #94, #95, #96, 'A', 'B',
      'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
      'Y', 'Z', #122, #123, #124, #125, #126, #127, #128, #129, #130, #131, #132, #133, #134, #135, #136, #137,
      #138, #139, #140, #141, #142, #143, #144, #145, #146, #147, #148, #149, #150, #151, #152, #153, #154, #155,
      #156, #157, #158, #159, #160, #161, #162, #163, #164, #165, #166, #167, #168, #169, #170, #171, #172, #173,
      #174, #175, #176, #177, #178, #179, #180, #181, #182, #183, #184, #185, #186, #187, #188, #189, #190, #191,
      #192, #193, #194, #195, #196, #197, #198, #199, #200, #201, #202, #203, #204, #205, #206, #207, #208, #209,
      #210, #211, #212, #213, #214, #215, #216, #217, #218, #219, #220, #221, #222, #223, #224, #225, #226, #227,
      #228, #229, #230, #231, #233, #234, #235, #236, #237, #238, #239, #240, #241, #242, #243, #244, #245, #246,
      #247, #248, #249, #250, #251, #252, #253, #254, #255), (#0, #1, #2, #3, #4, #5, #6, #7, #8, #9, #10, #11, #12,
      #13, #14, #15, #16, #17, #18, #19, #20, #21, #22, #23, #24, #25, #26, #27, #28, #29, #30, #31, #32, #33, #34,
      #35, #36, #37, #38, #39, #40, #41, #42, #43, #44, #45, #46, #47, '0', '1', '2', '3', '4', '5', '6', '7', '8',
      '9', #58, #59, #60, #61, #62, #63, #64, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
      'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', #91, #92, #93, #94, #95, #96, 'a', 'b', 'c', 'd',
      'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
      #122, #123, #124, #125, #126, #127, #128, #129, #130, #131, #132, #133, #134, #135, #136, #137, #138, #139, #140,
      #141, #142, #143, #144, #145, #146, #147, #148, #149, #150, #151, #152, #153, #154, #155, #156, #157, #158, #159,
      #160, #161, #162, #163, #164, #165, #166, #167, #168, #169, #170, #171, #172, #173, #174, #175, #176, #177, #178,
      #179, #180, #181, #182, #183, #184, #185, #186, #187, #188, #189, #190, #191, #192, #193, #194, #195, #196, #197,
      #198, #199, #200, #201, #202, #203, #204, #205, #206, #207, #208, #209, #210, #211, #212, #213, #214, #215, #216,
      #217, #218, #219, #220, #221, #222, #223, #224, #225, #226, #227, #228, #229, #230, #231, #233, #234, #235, #236,
      #237, #238, #239, #240, #241, #242, #243, #244, #245, #246, #247, #248, #249, #250, #251, #252, #253, #254,
      #255), (#0, #1, #2, #3, #4, #5, #6, #7, #8, #9, #10, #11, #12, #13, #14, #15, #16, #17, #18, #19, #20, #21, #22,
      #23, #24, #25, #26, #27, #28, #29, #30, #31, #32, #33, #34, #35, #36, #37, #38, #39, #40, #41, #42, #43, #44,
      #45, #46, #47, '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', #58, #59, #60, #61, #62, #63, #64, 'a', 'b',
      'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
      'y', 'z', #91, #92, #93, #94, #95, #96, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
      'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', #122, #123, #124, #125, #126, #127, #128, #129,
      #130, #131, #132, #133, #134, #135, #136, #137, #138, #139, #140, #141, #142, #143, #144, #145, #146, #147,
      #148, #149, #150, #151, #152, #153, #154, #155, #156, #157, #158, #159, #160, #161, #162, #163, #164, #165,
      #166, #167, #168, #169, #170, #171, #172, #173, #174, #175, #176, #177, #178, #179, #180, #181, #182, #183,
      #184, #185, #186, #187, #188, #189, #190, #191, #192, #193, #194, #195, #196, #197, #198, #199, #200, #201,
      #202, #203, #204, #205, #206, #207, #208, #209, #210, #211, #212, #213, #214, #215, #216, #217, #218, #219,
      #220, #221, #222, #223, #224, #225, #226, #227, #228, #229, #230, #231, #233, #234, #235, #236, #237, #238,
      #239, #240, #241, #242, #243, #244, #245, #246, #247, #248, #249, #250, #251, #252, #253, #254, #255));

  WEEKDAY_SHORTHANDS: array [0..6] of array [0..2] of Char = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
  MONTH_SHORTHANDS: array [1..12] of array [0..2] of Char = (
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

  RBSBoolTexts: array [Boolean] of RawByteString = ('false', 'true');
  USBoolTexts: array [Boolean] of u16string = ('false', 'true');
  RBSBoolIDs: array [Boolean] of RawByteString = ('0', '1');
  WSBoolIDs: array [Boolean] of WideString = ('0', '1');
  USBoolIDs: array [Boolean] of u16string = ('0', '1');
{$IF not declared(varObject)}
  varObject = $0049;
{$IFEND}

type
  EOperationAborted = class(Exception)

  end;

  TAnsiCharSet = set of AnsiChar;
  TObjectProcedure = procedure of object;

  TRawByteStrings = DSLAnsiFunctions.TRawByteStrings;
  TRawByteStringList = DSLAnsiFunctions.TRawByteStringList;
  TRawByteStringStream = DSLAnsiFunctions.TRawByteStringStream;
  TUnicodeStrings = TStrings;
  Tu16strings = TStrings;
  Tu16stringList = TStringList;
  TUnicodeStringList = TStringList;
  TUnicodeStringStream = TStringStream;
  // UString = u16string;
  // PUString = PUnicodeString;
{$IF not declared(UTF16String)}
  UTF16String = UnicodeString;
  PUTF16String = PUnicodeString;
{$IFEND}
{$IF not declared(Int8)}
  Int8 = ShortInt;
{$IFEND}
{$IF not declared(PInt8)}
  PInt8 = ^Int8;
{$IFEND}
{$IF not declared(UInt8)}
  UInt8 = Byte;
{$IFEND}
{$IF not declared(PUInt8)}
  PUInt8 = ^UInt8;
{$IFEND}
{$IF not declared(Int16)}
  Int16 = SmallInt;
{$IFEND}
{$IF not declared(PInt16)}
  PInt16 = ^Int16;
{$IFEND}
{$IF not declared(UInt16)}
  UInt16 = Word;
{$IFEND}
{$IF not declared(PUInt16)}
  PUInt16 = ^UInt16;
{$IFEND}
{$IF not declared(Int32)}
  Int32 = Integer;
{$IFEND}
{$IF not declared(PInt32)}
  PInt32 = ^Int32;
{$IFEND}
{$IF not declared(UInt32)}
  UInt32 = Cardinal;
{$IFEND}
{$IF not declared(PUInt32)}
  PUInt32 = ^UInt32;
{$IFEND}
{$IF not declared(UInt64)}
  UInt64 = Int64;
{$IFEND}
{$IF not declared(PUInt64)}
  PUInt64 = ^UInt64;
{$IFEND}
{$IF not declared(DWORD)}
  DWORD = Cardinal;
{$IFEND}
{$IF not declared(PDWORD)}
  PDWORD = ^DWORD;
{$IFEND}
{$IF not declared(QWORD)}
  QWORD = UInt64;
{$IFEND}
{$IF not declared(PQWORD)}
  PQWORD = ^QWORD;
{$IFEND}
{$IF not declared(NativeInt)}
{$IF SizeOf(Pointer) = 4}
  NativeInt = Int32;
{$ELSE}
  NativeInt = Int64;
{$IFEND}
{$IFEND}
{$IF not declared(NativeUInt)}
{$IF SizeOf(Pointer) = 4}
  NativeUInt = UInt32;
{$ELSE}
  NativeUInt = UInt64;
{$IFEND}
{$IFEND}
{$IF not declared(size_t)}
  size_t = NativeUInt; {$EXTERNALSYM size_t}
{$IFEND}
{$IF SizeOf(Pointer) = 4}
  TPointerType = Int32;
{$ELSE}
  TPointerType = Int64;
{$IFEND}
{$IF not declared(PtrInt)}
{$IF SizeOf(Pointer) = 4}
  PtrInt = Int32;
{$ELSE}
  PtrInt = Int64;
{$IFEND}
{$IFEND}
{$IF not declared(UPtrInt)}
{$IF SizeOf(Pointer) = 4}
  UPtrInt = UInt32;
{$ELSE}
  UPtrInt = UInt64;
{$IFEND}
{$IFEND}
  TSizeType = NativeUInt;
{$IF not declared(PObject)}
  PObject = ^TObject;
{$IFEND}
  TInt64Array = array of Int64;

  T4UInt32 = array [0 .. 3] of UInt32;
  P4UInt32 = ^T4UInt32;
  T2UInt32 = array [0 .. 1] of UInt32;
  P2UInt32 = ^T2UInt32;
  T16UInt32 = array [0 .. 15] of UInt32;
  P16UInt32 = ^T16UInt32;
  T3Bytes = array [0 .. 2] of Byte;
  P3Bytes = ^T3Bytes;
  T4Bytes = array [0 .. 3] of Byte;
  P4Bytes = ^T4Bytes;
  T16Bytes = array [0 .. 15] of Byte;
  P16Bytes = ^T16Bytes;
  T64Bytes = array [0 .. 63] of Byte;
  P64Bytes = ^T64Bytes;

  TArrayOfUInt32 = array [0 .. 0] of UInt32;
  PArrayOfUInt32 = ^TArrayOfUInt32;

  T32BitBuf = packed record
    case Integer of
      0:
        (bytes: array [0 .. 3] of Byte);
      1:
        (words: array [0 .. 1] of Word);
      2:
        (value: UInt32);
  end;

  P32BitBuf = ^T32BitBuf;

  T64BitBuf = packed record
    case Integer of
      0:
        (bytes: array [0 .. 7] of Byte);
      1:
        (words: array [0 .. 3] of Word);
      2:
        (dwords: array [0 .. 1] of T32BitBuf);
      3:
        (value: UInt64);
  end;

  P64BitBuf = ^T64BitBuf;

  T128BitBuf = packed record
    function toHex(UpperCase: Boolean = True; delimiter: u16string = ''): string;
    case Integer of
      0:
        (bytes: array [0 .. 15] of Byte);
      1:
        (words: array [0 .. 7] of Word);
      2:
        (dwords: array [0 .. 3] of T32BitBuf);
      3:
        (qwords: array [0 .. 1] of T64BitBuf);
  end;

  P128BitBuf = ^T128BitBuf;

  T160BitBuf = record
    case Integer of
      0:
        (bytes: array [0 .. 19] of Byte);
      1:
        (words: array [0 .. 9] of Word);
      2:
        (dwords: array [0 .. 4] of T32BitBuf);
  end;

  P160BitBuf = ^T160BitBuf;

  T192BitBuf = record
    case Integer of
      0:
        (bytes: array [0 .. 23] of Byte);
      1:
        (words: array [0 .. 11] of Word);
      2:
        (dwords: array [0 .. 5] of T32BitBuf);
  end;

  P192BitBuf = ^T192BitBuf;

  T224BitBuf = packed record
    case Integer of
      0:
        (bytes: array [0 .. 27] of Byte);
      1:
        (words: array [0 .. 13] of Word);
      2:
        (dwords: array [0 .. 6] of T32BitBuf);
  end;

  P224BitBuf = ^T224BitBuf;

  T256BitBuf = packed record
    case Integer of
      0:
        (bytes: array [0 .. 31] of Byte);
      1:
        (words: array [0 .. 15] of Word);
      2:
        (dwords: array [0 .. 7] of T32BitBuf);
      3:
        (qwords: array [0 .. 3] of T64BitBuf);
  end;

  P256BitBuf = ^T256BitBuf;

  T384BitBuf = packed record
    case Integer of
      0:
        (bytes: array [0 .. 47] of Byte);
      1:
        (words: array [0 .. 23] of Word);
      2:
        (dwords: array [0 .. 11] of T32BitBuf);
      3:
        (qwords: array [0 .. 5] of T64BitBuf);
  end;

  P384BitBuf = ^T384BitBuf;

  T512BitBuf = packed record
    case Integer of
      0:
        (qwords: array [0 .. 7] of T64BitBuf);
      1:
        (dwords: array [0 .. 15] of T32BitBuf);
      2:
        (words: array [0 .. 31] of Word);
      3:
        (bytes: array [0 .. 63] of Byte);
  end;

  P512BitBuf = ^T512BitBuf;

  T1024BitBuf = packed record
    case Integer of
      0:
        (qwords: array [0 .. 15] of T64BitBuf);
      1:
        (dwords: array [0 .. 31] of T32BitBuf);
      2:
        (words: array [0 .. 63] of Word);
      3:
        (bytes: array [0 .. 127] of Byte);
  end;

  P1024BitBuf = ^T1024BitBuf;

  TBigEndianWord = packed record
    bytes: Word;
    function value: Word; inline;
    procedure setValue(newValue: Word); inline;
  end;

  TBigEndianDword = packed record
    data: T32BitBuf;
    function value: UInt32; inline;
    procedure setValue(newValue: UInt32); inline;
  end;

  TBuffer = record
    size: Integer;
    data: array [0 .. 0] of Byte;
  end;

  PBuffer = ^TBuffer;

  TSex = (sexUnknown, sexMale, sexFemale);

  TPointerCompareProc = function(first, second: Pointer): Integer;
  TPointerProc = procedure(first, second: Pointer);

const
  CP_CHINESE_SIMPLIFIED = 936;
  CP_CHINESE_TRADITIONAL = 950;

function CodePageName2ID(Name: PAnsiChar; NameLen: Integer): Integer; overload;
function CodePageName2ID(const Name: AnsiString): Integer; overload;
function CodePageID2Name(ID: Integer): RawByteString;

type
  TTimeKeeper = record
    _beginTick: DWORD;
    procedure start; inline;
    function stop: DWORD; inline;
  end;

  TActionStatus = record
    executing: Boolean;
    timeBeginExecuting: UInt32;
    timeLatestExecution: UInt32;
    procedure init; inline;
    function shouldTakeAction(interval, timeout: UInt32): Boolean;
    procedure beginExec; inline;
    procedure endExec; inline;
  end;

  TCommunicationErrorCode = (
    comerrSuccess,
    comerrUnknown,
    comerrSysCallFail,
    comerrTimeout,
    comerrWouldBlock,
    comerrDNSError,
    comerrUnreachableDest,
    comerrCanNotConnect,
    comerrCanNotRead,
    comerrCanNotWrite,
    comerrChannelClosed,
    comerrSSLError);

  TCommunicationError = record
    code: TCommunicationErrorCode;
    callee: string;
    internalErrorCode: Integer;
    msg: string;
    procedure init; inline;
    procedure reset; inline;
    procedure clear;
    function isSuccess: Boolean; inline;
  end;
  PCommunicationError = ^TCommunicationError;

  TStringSearchFlag = (ssfCaseSensitive, ssfReverse, ssfIncludePrefix, ssfIncludeSuffix);
  TStringSearchFlags = set of TStringSearchFlag;

  PAnsiCharSection = ^TAnsiCharSection;

  TAnsiCharSection = record
    _begin: PAnsiChar;
    _end: PAnsiChar;
    constructor Create(const s: RawByteString; first: Integer = 1; last: Integer = 0);
    procedure SetStr(const s: RawByteString; first: Integer = 1; last: Integer = 0);
    procedure SetEmpty; inline;
    function IsEmpty: Boolean; inline;
    procedure SetInvalid; inline;
    function IsValid: Boolean; inline;
    function length: Integer; inline;
    function compare(const another: TAnsiCharSection; CaseSensitive: Boolean = True): Integer; overload;
    function compare(const another: RawByteString; CaseSensitive: Boolean = True): Integer; overload; inline;
    function toString: RawByteString;
    function trim: PAnsiCharSection;
    function TrimLeft: PAnsiCharSection;
    function TrimRight: PAnsiCharSection;
    function pos(substr: TAnsiCharSection): PAnsiChar; inline;
    function ipos(substr: TAnsiCharSection): PAnsiChar; inline;
    function rpos(substr: TAnsiCharSection): PAnsiChar; inline;
    function ripos(substr: TAnsiCharSection): PAnsiChar; inline;
    function beginWith(const prefix: TAnsiCharSection): Boolean;
    function iBeginWith(const prefix: TAnsiCharSection): Boolean;
    function endWith(const prefix: TAnsiCharSection): Boolean;
    function iEndWith(const prefix: TAnsiCharSection): Boolean;
    function GetSectionBetween(const prefix, suffix: TAnsiCharSection;
      flags: TStringSearchFlags = []): TAnsiCharSection;
    function GetSectionBetween2(const prefix: TAnsiCharSection; const suffix: array of AnsiChar;
      EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): TAnsiCharSection;
    function TryToInt(var value: Integer): Boolean;
    function ToInt: Integer;
    function TryToInt64(var value: Int64): Boolean;
    function ToInt64: Int64;
    function TryToFloat(var value: Double): Boolean;
    function ToFloat: Double;
  end;

  PWideCharSection = ^TWideCharSection;

  TWideCharSection = record
  public
    _begin: PWideChar;
    _end: PWideChar;
    constructor Create(const s: u16string; first: Integer = 1; last: Integer = 0); overload;
    constructor Create(const s: WideString; first: Integer = 1; last: Integer = 0); overload;
    procedure SetUStr(const s: u16string; first: Integer = 1; last: Integer = 0); overload;
    procedure SetBStr(const s: WideString; first: Integer = 1; last: Integer = 0); overload;
    procedure SetEmpty; inline;
    function IsEmpty: Boolean; inline;
    procedure SetInvalid; inline;
    function IsValid: Boolean; inline;
    function length: Integer; inline;
    function compare(const another: TWideCharSection; CaseSensitive: Boolean = True): Integer; overload;
    function compare(const another: u16string; CaseSensitive: Boolean = True): Integer; overload; inline;
    function ToUStr: u16string;
    function ToBStr: WideString;
    function trim: PWideCharSection;
    function ExtractXmlCDATA: PWideCharSection;
    function TrimLeft: PWideCharSection;
    function TrimRight: PWideCharSection;
    function pos(substr: TWideCharSection): PWideChar; inline;
    function ipos(substr: TWideCharSection): PWideChar; inline;
    function rpos(substr: TWideCharSection): PWideChar; inline;
    function ripos(substr: TWideCharSection): PWideChar; inline;
    function beginWith(const prefix: TWideCharSection): Boolean;
    function iBeginWith(const prefix: TWideCharSection): Boolean;
    function endWith(const prefix: TWideCharSection): Boolean;
    function iEndWith(const prefix: TWideCharSection): Boolean;
    function GetSectionBetween(const prefix, suffix: TWideCharSection;
      flags: TStringSearchFlags = []): TWideCharSection;
    function GetSectionBetween2(const prefix: TWideCharSection; const suffix: array of WideChar;
      EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): TWideCharSection;
    function TryToInt(var value: Integer): Boolean;
    function ToInt: Integer;
    function TryToInt64(var value: Int64): Boolean;
    function ToInt64: Int64;
    function TryToFloat(var value: Double): Boolean;
    function ToFloat: Double;
  end;

  TStreamHelper = class helper for TStream
  public
    procedure WriteByte(value: Byte);
    procedure WriteWord(value: Word);
    procedure WriteDword(value: UInt32);
    procedure WriteAnsiChar(value: AnsiChar);
    procedure WriteWideChar(value: WideChar);
    procedure WriteBytes(const value: TBytes);
    procedure WriteRawByteString(const value: RawByteString);
    procedure WriteUnicodeString(const value: u16string);
    procedure WriteWideString(const value: WideString);
    function ReadByte: Byte;
    function ReadWord: Word;
    function ReadDword: UInt32;
    function ReadAnsiChar: AnsiChar;
    function ReadWideChar: WideChar;
    function ReadBytes(nBytes: Integer): TBytes;
    function ReadRawByteString(nChar: Integer): RawByteString;
    function ReadWideString(nChar: Integer): WideString;
    function ReadUnicodeString(nChar: Integer): u16string;
  end;

function RBStrSection(const s: AnsiString; first: Integer = 1; last: Integer = 0): TAnsiCharSection; inline;
function UStrSection(const s: u16string; first: Integer = 1; last: Integer = 0): TWideCharSection; inline;
function BStrSection(const s: WideString; first: Integer = 1; last: Integer = 0): TWideCharSection; inline;

type
  TCharType = (chAlphaUpperCase, chAlphaLowerCase, chDigit);
  TCharTypes = set of TCharType;

  TOperationResult = (orUnknown, orException, orFail, orSuccess, orPending, orAlready, orRetry, orPartSuccess,
    orCanceled);

  TWebOperationResult = record
  public
    ResponseText: u16string;
    online: Boolean;
    code: TOperationResult;
    errmsg: u16string;
    procedure init;
  end;

  TOperationStatus = record
    Result: TOperationResult;
    errmsg: string;
    SysErrorCode: Integer;
    procedure init;
  end;

  TInterlockSync = record
    _threadId: DWORD;
    _nested: Integer;
    _state: Integer;
{$IFDEF DSLSpinLockDebug}
    _lockBeginTime: DWORD;
{$ENDIF}
    procedure init;
    procedure cleanup;
    procedure acquire(spinCount: Integer = 128);
    procedure release;
  end;

  TSpinLock = TInterlockSync;

  TInterlockSyncObject = class(TSynchroObject)
  private
    internal: TInterlockSync;
  public
    procedure Acquire; override;
    procedure Release; override;
    constructor Create;
  end;

  PDblLinkListEntry = ^TDblLinkListEntry;

  TDblLinkListEntry = record
    prev, next: PDblLinkListEntry;
    function SetEmpty: PDblLinkListEntry;
    procedure insertHead(node: PDblLinkListEntry); inline;
    procedure insertTail(node: PDblLinkListEntry); inline;
  end;

  PLinkListEntry = ^TLinkListEntry;

  TLinkListEntry = record
    next: PLinkListEntry;
    function SetEmpty: PLinkListEntry; inline;
    procedure insertHead(node: PLinkListEntry); inline;
  end;

function StringToPChar(const s: u16string): PWideChar; overload; inline;
function StringToPChar(const s: RawByteString): PAnsiChar; overload; inline;

  // NULL-terminated-C-style-string simulation
function charAt(p, tail: PAnsiChar): AnsiChar; overload; inline;
function charAt(p, tail: PWideChar): WideChar; overload; inline;

function IsEmptyString(p: PAnsiChar): Boolean; overload; inline;
function IsEmptyString(p: PWideChar): Boolean; overload; inline;

procedure _fastAssignStr(var dest: RawByteString; const src: RawByteString); overload; inline;
procedure _fastAssignStr(var dest: u16string; const src: u16string); overload; inline;
procedure _fastAssignStr(var dest: WideString; const src: WideString); overload; inline;
procedure _fastAssignStr(var dest: AnsiString; const src: AnsiString); overload; inline;
procedure _fastAssignStr(var dest: UTF8String; const src: UTF8String); overload; inline;

procedure dslMove(const src; var dest; count: Integer); inline;
procedure FillWordX87(var dest; count: Integer; value: Word);
procedure FillDwordX87(var dest; count: Integer; value: UInt32);

function absoluteValue(v: Integer): Integer; overload; inline;
function absoluteValue(v: Int64): Int64; overload; inline;
function absoluteValue(v: ShortInt): ShortInt; overload; inline;
function absoluteValue(v: SmallInt): SmallInt; overload; inline;

function Get1Bytes(v: Byte): RawByteString;
function Get2Bytes(v: Word): RawByteString;
function Get4Bytes(v: UInt32): RawByteString;
function Get8Bytes(v: Int64): RawByteString;

procedure PaddingRight8(const src; srcLen: Integer; var dst; dstLen: Integer; paddingValue: Byte); overload; inline;
procedure PaddingRight8(const src: RawByteString; var dst; dstLen: Integer; paddingValue: Byte); overload; inline;

procedure xorBuffer(const operand1, operand2; bufLen: Integer; var dst);
procedure andBuffer(const operand1, operand2; bufLen: Integer; var dst);
procedure orBuffer(const operand1, operand2; bufLen: Integer; var dst);

function RotateLeft32(v: UInt32; n: Integer): UInt32; inline;
function RotateRight32(v: UInt32; n: Integer): UInt32; inline;
function RotateLeft64(v: UInt64; n: Integer): UInt64; inline;
function RotateRight64(v: UInt64; n: Integer): UInt64; inline;
{$IFDEF WIN64}
function sar32(value: UInt32; bits: Integer): UInt32; inline;
{$ELSE}
function sar32(value: UInt32; bits: Integer): UInt32;
{$ENDIF}
function sar64(value: Int64; bits: Integer): Int64;
function ReverseByteOrder32(v: UInt32): UInt32; inline;
function ReverseByteOrder64(v: UInt64): UInt64; inline;
function BigEndianToSys(v: UInt32): UInt32; overload; inline;
function SysToBigEndian(v: UInt32): UInt32; overload; inline;
function SysToLittleEndian(v: UInt32): UInt32; overload; inline;
function LittleEndianToSys(v: UInt32): UInt32; overload; inline;
function BigEndianToSys(v: Word): Word; overload; inline;
function SysToBigEndian(v: Word): Word; overload; inline;
function SysToLittleEndian(v: Word): Word; overload; inline;
function LittleEndianToSys(v: Word): Word; overload; inline;
function Power10(const mantissa: Extended; exponent: Integer): Extended;
function IsSameMethod(const method1, method2): Boolean;
function IsEqualFloat(d1, d2: Double): Boolean;

function myhtoll(v: Int64): Int64;

{$REGION '时间日期相关'}
function FormatSysTime(const st: TSystemTime; const fmt: string = ''): string;
function FormatSysTimeNow(const fmt: string = ''): string;
function RBStrNow: RawByteString;
function SameHour(former, later: TDateTime): Boolean;
function SameDay(former, later: TDateTime): Boolean;
function SameMonth(former, later: TDateTime): Boolean;
function SameYear(former, later: TDateTime): Boolean;
procedure SystemTimeIncMilliSeconds(var st: TSystemTime; value: Int64);
procedure SystemTimeIncSeconds(var st: TSystemTime; value: Int64);
procedure SystemTimeIncMinutes(var st: TSystemTime; value: Integer);
procedure SystemTimeIncHours(var st: TSystemTime; value: Integer);
procedure SystemTimeIncDays(var st: TSystemTime; value: Integer);
procedure SystemTimeIncMonths(var st: TSystemTime; value: Integer);
procedure SystemTimeIncYears(var st: TSystemTime; value: Integer);
function UTCNow: TDateTime;
function UTCToLocal(dt: TDateTime): TDateTime;
function LocalToUTC(dt: TDateTime): TDateTime;
function UTCLocalDiff: Integer;
function DateTimeToJava(d: TDateTime): Int64;
function JavaToDateTime(t: Int64): TDateTime;
function getWebTimestamp: Int64;

function GMTStringToDateTime(const s: string): TDateTime; overload;
function GMTStringToDateTime(const s: RawByteString): TDateTime; overload;

function dateTimeToGMTRawBytes(const st: TSystemTime; buf: PAnsiChar; utcbias: Integer = 14400): Integer; overload;
function dateTimeToGMTRawBytes(const st: TSystemTime; utcbias: Integer = 14400): RawByteString; overload;
function dateTimeToGMTRawBytes(dt: TDateTime; utcbias: Integer = 14400): RawByteString; overload

function dateTimeToGMTString(const st: TSystemTime; buf: PWideChar; utcbias: Integer = 14400): Integer; overload;
function dateTimeToGMTString(const st: TSystemTime; utcbias: Integer = 14400): string; overload;
function dateTimeToGMTString(dt: TDateTime; utcbias: Integer = 14400): string; overload;

{$ENDREGION}

function ReplaceIfNotEqual(var dst: RawByteString; const src: RawByteString; pEStayNETrue: PBoolean = nil): Boolean;
  overload;

function ReplaceIfNotEqual(var dst: u16string; const src: u16string; pEStayNETrue: PBoolean = nil): Boolean;
  overload;

function ReplaceIfNotEqual(var dst: Integer; const src: Integer; pEStayNETrue: PBoolean = nil): Boolean; overload;

function ReplaceIfNotEqual(var dst: Int64; const src: Int64; pEStayNETrue: PBoolean = nil): Boolean; overload;

function ReplaceIfNotEqual(var dst: Double; const src: Double; pEStayNETrue: PBoolean = nil): Boolean; overload;

//function ReplaceIfNotEqual(var dst: Real; const src: Real; pEStayNETrue: PBoolean = nil): Boolean; overload;

function ReplaceIfNotEqual(var dst: Boolean; const src: Boolean; pEStayNETrue: PBoolean = nil): Boolean; overload;

function IsPrintable(ch: AnsiChar): Boolean;
function IsPrintableString(const s: RawByteString): Boolean; overload;
function IsPrintableString(const buf; bufLen: Integer): Boolean; overload;
{$REGION 'random data generation'}
function RandomBytes(count: Integer): RawByteString;
function RandomRBStr(CharSet: RawByteString; CharCount: Integer): RawByteString;
function RandomAlphaRBStr(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase]): RawByteString;
function RandomDigitRBStr(CharCount: Integer): RawByteString;

function RandomAlphaDigitRBStr(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase])
  : RawByteString;

var
  RandomStringA: function(CharSet: RawByteString; CharCount: Integer): RawByteString;
  RandomAlphaStringA: function(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase])
    : RawByteString;
  RandomDigitStringA: function(CharCount: Integer): RawByteString;
  RandomAlphaDigitStringA: function(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase])
    : RawByteString;

function RandomUStr(CharSet: u16string; CharCount: Integer): u16string;

function RandomAlphaUStr(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase]): u16string;

function RandomDigitUStr(CharCount: Integer): u16string;

function RandomAlphaDigitUStr(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase])
  : u16string;

var
  RandomStringW: function(CharSet: u16string; CharCount: Integer): u16string;
  RandomAlphaStringw: function(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase])
    : u16string;
  RandomDigitStringW: function(CharCount: Integer): u16string;
  RandomAlphaDigitStringW: function(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase])
    : u16string;

function RandomBStr(CharSet: u16string; CharCount: Integer): WideString;

function RandomAlphaBStr(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase]): WideString;

function RandomDigitBStr(CharCount: Integer): WideString;

function RandomAlphaDigitBStr(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase]): WideString;

function RandomCNMobile: RawByteString;
{$ENDREGION}
{$REGION 'MBCS and unicode convertion'}
function AnsiStrAssignWideChar(dst: PAnsiChar; dstLen: Integer; c: WideChar; CodePage: Integer): Integer;

function AsciiBuf2UStr(buf: PAnsiChar; len: Integer = -1): u16string;
function Ascii2UStr(const s: RawByteString): u16string;

function BufToUnicodeTest(src: PAnsiChar; srcLen: Integer; CodePage: Integer): Integer;

function CheckCodePage(src: PAnsiChar; srcLen: Integer; CodePage: Integer; out dstLen: Integer): Boolean;

function BufToUnicodeTestEx(src: PAnsiChar; srcLen: Integer; const CodePages: array of Integer;
  out RealCodePage: Integer): Integer;

function BufToUnicode(src: PAnsiChar; srcLen: Integer; dst: PWideChar; dstLen, CodePage: Integer): Integer; overload;

function BufToUnicode(src: PAnsiChar; srcLen: Integer; CodePage: Integer): u16string; overload;
function BufToBSTR(src: PAnsiChar; srcLen: Integer; CodePage: Integer): WideString;

function BufToUnicodeEx(src: PAnsiChar; srcLen: Integer; dst: PWideChar; dstLen: Integer;
  const CodePages: array of Integer): Integer; overload;

function BufToUnicodeEx(src: PAnsiChar; srcLen: Integer; const CodePages: array of Integer): u16string; overload;

function RBStrToUnicode(const src: RawByteString; dst: PWideChar; dstLen, CodePage: Integer): Integer; overload;

function RBStrToUnicode(const src: RawByteString; CodePage: Integer): u16string; overload;

function RBStrToUnicodeEx(const src: RawByteString; dst: PWideChar; dstLen: Integer;
  const CodePages: array of Integer): Integer; overload;

function RBStrToUnicodeEx(const src: RawByteString; const CodePages: array of Integer): u16string; overload;
function BufToMultiByteTest(src: PWideChar; srcLen: Integer; CodePage: Integer): Integer;
function BufToMultiByte(src: PWideChar; srcLen: Integer; dst: PAnsiChar; dstLen, CodePage: Integer): Integer; overload;
function BufToMultiByte(src: PWideChar; srcLen: Integer; CodePage: Integer): RawByteString; overload;
function UStrToMultiByte(const src: u16string; dst: PAnsiChar; dstLen, CodePage: Integer): Integer; overload;
function UStrToMultiByte(const src: u16string; CodePage: Integer): RawByteString; overload;
function UTF8EncodeBufferTest(src: PWideChar; srcLen: Integer): Integer;
function UTF8EncodeBuffer(src: PWideChar; srcLen: Integer; dest: PAnsiChar): Integer; overload;
function UTF8EncodeBuffer(src: PWideChar; srcLen: Integer): UTF8String; overload;
function UTF8EncodeCStrTest(src: PWideChar): Integer;
function UTF8EncodeCStr(src: PWideChar; dest: PAnsiChar): Integer; overload;
function UTF8EncodeCStr(src: PWideChar): RawByteString; overload;
function UTF8EncodeUStr(const src: u16string; dest: PAnsiChar): Integer; overload;
function UTF8EncodeUStr(const src: u16string): UTF8String; overload;
function UTF8EncodeBStr(const src: WideString; dest: PAnsiChar): Integer; overload;
function UTF8EncodeBStr(const src: WideString): UTF8String; overload;
function UTF8DecodeBufferTest(src: PAnsiChar; srcLen: Integer; invalid: PPAnsiChar = nil): Integer;

function UTF8DecodeBuffer(src: PAnsiChar; srcLen: Integer; dest: PWideChar;
  invalid: PPAnsiChar = nil): Integer; overload;

function UTF8DecodeBuffer(src: PAnsiChar; srcLen: Integer; invalid: PPAnsiChar = nil): u16string; overload;
function UTF8DecodeCStrTest(src: PAnsiChar; invalid: PPAnsiChar = nil): Integer;
function UTF8DecodeCStr(src: PAnsiChar; dest: PWideChar; invalid: PPAnsiChar = nil): Integer; overload;
function UTF8DecodeCStr(src: PAnsiChar; invalid: PPAnsiChar = nil): u16string; overload;
function UTF8DecodeStr(const src: RawByteString; dest: PWideChar; invalid: PPAnsiChar = nil): Integer; overload;
function UTF8DecodeStr(const src: RawByteString; invalid: PPAnsiChar = nil): u16string; overload;

function WinAPI_UTF8Decode(s: PAnsiChar; len: Integer): u16string; overload;
function WinAPI_UTF8Decode(const s: RawByteString): u16string; overload;
function WinAPI_UTF8Decode_2bstr(const s: RawByteString): WideString;

procedure UTF8EncodeFile(const FileName: string);
procedure UTF8DecodeFile(const FileName: string);
procedure HttpEncodeFile(const FileName: string);
procedure HttpDecodeFile(const FileName: string);
function UTF16Decode(const s: RawByteString): u16string;
{$ENDREGION}

function RBStrIsEmpty(const s: RawByteString): Boolean;
function UStrIsEmpty(const s: u16string): Boolean;
{$REGION '全半角字符转换'}
// 全角: SBC  半角：DBC

procedure SBC2DBCW(str: PWideChar); overload;
procedure SBC2DBCW(str: PWideChar; len: Integer); overload;
function UStrSBC2DBC(const str: u16string): u16string;
function BStrSBC2DBC(const str: WideString): WideString;

procedure DBC2SBCW(str: PWideChar); overload;
procedure DBC2SBCW(str: PWideChar; len: Integer); overload;
function UStrDBC2SBC(const str: u16string): u16string;
function BStrDBC2SBC(const str: WideString): WideString;
{$ENDREGION}
{$REGION 'c语言字符转义解析'}
function cstrUnescapeA(src: PAnsiChar; dst: PAnsiChar; dstLen: Integer; pUnescaped: PInteger): Integer; overload;
function cstrUnescapeA(src: PAnsiChar): RawByteString; overload;
function cstrUnescapeA(src: PAnsiChar; srcLen: Integer; dst: PAnsiChar; dstLen: Integer;
  pUnescaped: PInteger): Integer; overload;
function cstrUnescapeA(src: PAnsiChar; srcLen: Integer): RawByteString; overload;
function cstrUnescape(const s: RawByteString): RawByteString; overload;

function cstrUnescapeW(src: PWideChar; dst: PWideChar; dstLen: Integer; pUnescaped: PInteger): Integer; overload;
function cstrUnescapeW(src: PWideChar): u16string; overload;
function cstrUnescapeW(src: PWideChar; srcLen: Integer; dst: PWideChar; dstLen: Integer;
  pUnescaped: PInteger): Integer; overload;
function cstrUnescapeW(src: PWideChar; srcLen: Integer): u16string; overload;
function cstrUnescape(const s: u16string): u16string; overload;
{$ENDREGION}
{$REGION 'char case converting'}
function StrUpperW(str: PWideChar): PWideChar; overload;
function StrUpperW(str: PWideChar; len: Integer): PWideChar; overload;
procedure UStrUpper(const str: u16string);
procedure BStrUpper(const str: WideString);

function StrLowerW(str: PWideChar): PWideChar; overload;
function StrLowerW(str: PWideChar; len: Integer): PWideChar; overload;
procedure UStrLower(const str: u16string);
procedure BStrLower(const str: WideString);

function StrUpperA(str: PAnsiChar): PAnsiChar; overload;
function StrUpperA(str: PAnsiChar; len: Integer): PAnsiChar; overload;
procedure RBStrUpper(const str: RawByteString);

function StrLowerA(str: PAnsiChar): PAnsiChar; overload;
function StrLowerA(str: PAnsiChar; len: Integer): PAnsiChar; overload;
function RBStrLower(const str: RawByteString): RawByteString;

procedure SetRBStr(var s: RawByteString; _begin, _end: PAnsiChar);
procedure SetUString(var s: u16string; _begin, _end: PWideChar);
{$ENDREGION}
{$REGION 'string <=> number interface'}
const
  INT64_TABLE: array [0 .. 19] of UInt64 = (
    1,
    10,
    100,
    1000,
    10000,
    100000,
    1000000,
    10000000,
    100000000,
    1000000000,
    10000000000,
    100000000000,
    1000000000000,
    10000000000000,
    100000000000000,
    1000000000000000,
    10000000000000000,
    100000000000000000,
    1000000000000000000,
    10000000000000000000
    );

type
  TNumberType = (numNaN, numInt32, numUInt32, numInt64, numUInt64, numDouble, numExtended);

  TNumber = record
    function expr: string;
    function toUTF16Str: UTF16String;
    function toRawBytes: RawByteString;
    function toString: string; inline;
    function valid: Boolean;
    function isInteger: Boolean; inline;
    function isFloat: Boolean; inline;
    function isNegative: Boolean; inline;
    function isPositive: Boolean; inline;
    function toExtended: Extended;
    function asUInt32: UInt32; inline;
    function asInt32: Int32; inline;
    function round: Int64;
    function ceil: Int64;
    function trunc: Int64;
    function tryGetInt(var value: Int64): Boolean;
    procedure setInt32(value: Int32); inline;
    procedure setUInt32(value: UInt32); inline;
    procedure setInt64(value: Int64); inline;
    procedure setUInt64(value: UInt64); inline;
    procedure setDouble(value: Double); inline;
    procedure setExtended(value: Extended); inline;
    procedure clear; inline;
    case _type: TNumberType of
      numInt32:
        (I32: Int32);
      numUInt32:
        (UI32: UInt32);
      numInt64:
        (I64: Int64);
      numUInt64:
        (UI64: UInt64);
      numDouble:
        (VDouble: Double);
      numExtended:
        (VExtended: Extended);
  end;

procedure _calcInt(isNegative: Boolean; s: PAnsiChar; len: Integer; var number: TNumber); overload;
procedure _calcInt(isNegative: Boolean; s: PWideChar; len: Integer; var number: TNumber); overload;

// parseNumber supports both integers and floats
function parseNumber(s: PAnsiChar; endAt: PPAnsiChar = nil): TNumber; overload;
function parseNumber(s: PWideChar; endAt: PPWideChar = nil): TNumber; overload;
function parseNumber(s: PAnsiChar; slen: Integer; endAt: PPAnsiChar = nil): TNumber; overload;
function parseNumber(s: PWideChar; slen: Integer; endAt: PPWideChar = nil): TNumber; overload;

function divBy100(dividend: Int32): Int32;
function StrInt(s: PAnsiChar; value: UInt32): PAnsiChar; overload;
function StrInt(s: PAnsiChar; const value: UInt64): PAnsiChar; overload;
function StrInt(s: PWideChar; value: UInt32): PWideChar; overload;
function StrInt(s: PWideChar; const value: UInt64): PWideChar; overload;

function StrInt(s: PAnsiChar; value: Int32): PAnsiChar; overload;
function StrInt(s: PAnsiChar; const value: Int64): PAnsiChar; overload;
function StrInt(s: PWideChar; value: Int32): PWideChar; overload;
function StrInt(s: PWideChar; const value: Int64): PWideChar; overload;

function IntToStrFast(value: UInt32; s: PAnsiChar): PAnsiChar; overload;
function IntToStrFast(value: Int32; s: PAnsiChar): PAnsiChar; overload;
function IntToStrFast(value: UInt64; s: PAnsiChar): PAnsiChar; overload;
function IntToStrFast(value: Int64; s: PAnsiChar): PAnsiChar; overload;
function IntToStrFast(value: UInt32; s: PWideChar): PWideChar; overload;
function IntToStrFast(value: Int32; s: PWideChar): PWideChar; overload;
function IntToStrFast(value: UInt64; s: PWideChar): PWideChar; overload;
function IntToStrFast(value: Int64; s: PWideChar): PWideChar; overload;

function IntToUTF16Str(value: Int32): UTF16String; overload;
function IntToWideStr(value: Int32): WideString; overload;
function IntToRawBytes(value: Int32): RawByteString; overload;
function IntToStrFast(value: Int32): string; overload; inline;

function IntToUTF16Str(value: UInt32): UTF16String; overload;
function IntToWideStr(value: UInt32): WideString; overload;
function IntToRawBytes(value: UInt32): RawByteString; overload;
function IntToStrFast(value: UInt32): string; overload; inline;

function IntToUTF16Str(value: Int64): UTF16String; overload;
function IntToWideStr(value: Int64): WideString; overload;
function IntToRawBytes(value: Int64): RawByteString; overload;
function IntToStrFast(value: Int64): string; overload; inline;

function IntToUTF16Str(value: UInt64): UTF16String; overload;
function IntToWideStr(value: UInt64): WideString; overload;
function IntToRawBytes(value: UInt64): RawByteString; overload;
function IntToStrFast(value: UInt64): string; overload; inline;

(*************** backward compatible ***************)
function IntToStrBufA(value: Integer; buf: PAnsiChar): Integer; overload; inline;
function IntToStrBufA(value: Int64; buf: PAnsiChar): Integer; overload; inline;
function UInt32ToStrBufA(value: UInt32; buf: PAnsiChar): Integer; inline;
function UInt64ToStrBufA(value: UInt64; buf: PAnsiChar): Integer; inline;
function IntToRBStr(value: Integer): RawByteString; overload; inline;
function IntToRBStr(value: Int64): RawByteString; overload; inline;
function UInt32ToRBStr(value: UInt32): RawByteString; inline;
function UInt64ToRBStr(value: UInt64): RawByteString; inline;

function IntToStrBufW(value: Integer; buf: PWideChar): Integer; overload; inline;
function IntToStrBufW(value: Int64; buf: PWideChar): Integer; overload; inline;
function UInt32ToStrBufW(value: UInt32; buf: PWideChar): Integer; inline;
function UInt64ToStrBufW(value: UInt64; buf: PWideChar): Integer; inline;
function IntToUStr(value: Integer): u16string; overload; inline;
function IntToUStr(value: Int64): u16string; overload; inline;
function UInt32ToUStr(value: UInt32): u16string; inline;
function UInt64ToUStr(value: UInt64): u16string; inline;
function UInt32ToStr(value: UInt32): string; inline;
function UInt64ToStr(value: UInt64): string; inline;

function IntToBStr(value: Integer): WideString; overload; inline;
function IntToBStr(value: Int64): WideString; overload; inline;
function UInt32ToBStr(value: UInt32): WideString; inline;
function UInt64ToBStr(value: UInt64): WideString; inline;

function DecimalToUInt32A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt32;
function HexToUInt32A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt32;
function BufToIntA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Integer;
function RBStrToInt(const str: RawByteString): Integer; inline;
function RBStrToIntDef(const str: RawByteString; def: Integer): Integer; inline;
function BufToUInt32A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt32; inline;
function RBStrToUInt32(const str: RawByteString): UInt32; inline;
function RBStrToUInt32Def(const str: RawByteString; def: UInt32): UInt32; inline;

function DecimalToUInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt64;
function HexToUInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt64;
function BufToInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Int64;
function RBStrToInt64(const str: RawByteString): Int64; inline;
function RBStrToInt64Def(const str: RawByteString; def: Int64): Int64; inline;
function BufToUInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt64;
function RBStrToUInt64(const str: RawByteString): UInt64; inline;
function RBStrToUInt64Def(const str: RawByteString; def: UInt64): UInt64; inline;

function DecimalBufToUInt32W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt32;
function HexBufToUInt32W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt32;
function BufToIntW(buf: PWideChar; len: Integer; invalid: PPWideChar): Integer;
function UStrToInt(const str: u16string): Integer;
function BStrToInt(const str: WideString): Integer;
function dslStrToInt(const str: u16string): Integer; overload;
function dslStrToInt(const str: WideString): Integer; overload;
function UStrToIntDef(const str: u16string; def: Integer): Integer;
function BStrToIntDef(const str: WideString; def: Integer): Integer;
function dslStrToIntDef(const str: u16string; def: Integer): Integer; overload;
function dslStrToIntDef(const str: WideString; def: Integer): Integer; overload;
function BufToUInt32W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt32;
function UStrToUInt32(const str: u16string): UInt32;
function BStrToUInt32(const str: WideString): UInt32;
function dslStrToUInt32(const str: u16string): UInt32; overload;
function dslStrToUInt32(const str: WideString): UInt32; overload;
function UStrToUInt32Def(const str: u16string; def: UInt32): UInt32;
function BStrToUInt32Def(const str: WideString; def: UInt32): UInt32;
function dslStrToUInt32Def(const str: u16string; def: UInt32): UInt32; overload;
function dslStrToUInt32Def(const str: WideString; def: UInt32): UInt32; overload;

function DecimalBufToUInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt64;
function HexBufToUInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt64;
function BufToInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): Int64;
function BStrToInt64(const str: WideString): Int64;
function UStrToInt64(const str: u16string): Int64;
function dslStrToInt64(const str: WideString): Int64; overload;
function dslStrToInt64(const str: u16string): Int64; overload;
function BStrToInt64Def(const str: WideString; def: Int64): Int64;
function UStrToInt64Def(const str: u16string; def: Int64): Int64;
function dslStrToInt64Def(const str: WideString; def: Int64): Int64; overload;
function dslStrToInt64Def(const str: u16string; def: Int64): Int64; overload;
function BufToUInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt64;
function BStrToUInt64(const str: WideString): UInt64;
function UStrToUInt64(const str: u16string): UInt64;
function dslStrToUInt64(const str: WideString): UInt64; overload;
function dslStrToUInt64(const str: u16string): UInt64; overload;
function BStrToUInt64Def(const str: WideString; def: UInt64): UInt64;
function UStrToUInt64Def(const str: u16string; def: UInt64): UInt64;
function dslStrToUInt64Def(const str: WideString; def: UInt64): UInt64; overload;
function dslStrToUInt64Def(const str: u16string; def: UInt64): UInt64; overload;

function parseFloat(str: PAnsiChar; pErr: PPAnsiChar = nil): Extended; overload;
function parseFloat(str: PWideChar; pErr: PPWideChar = nil): Extended; overload;
function BufToFloatA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar = nil): Double;
function RBStrToFloat(const str: RawByteString): Double; inline;
function BufToFloatA2(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar = nil): Double;
function RBStrToFloat2(const str: RawByteString): Double; inline;
function BufToFloatW(buf: PWideChar; len: Integer; invalid: PPWideChar = nil): Double;
function UStrToFloat(const str: u16string): Double;
function BStrToFloat(const str: WideString): Double;

function FloatToUStr(value: Extended): u16string; overload; inline;
function FloatToUStr(value: Extended; const FormatSettings: TFormatSettings): u16string; overload; inline;
function FloatToRBStr(value: Extended): RawByteString; overload;
function FloatToRBStr(value: Extended; const FormatSettings: TFormatSettings): RawByteString; overload;
function FormatFloat_mb(const Format: RawByteString; Value: Extended): RawByteString; overload;
function FormatFloat_mb(const Format: RawByteString; Value: Extended;
  const FormatSettings: TFormatSettings): RawByteString; overload;
{$ENDREGION}

{$REGION 'Variant utils'}
function TryVarToStr(const v: Variant; var s: string): Boolean;
function VarToBool(const v: Variant; var bv: Boolean): Boolean;
function VarToBoolDef(const v: Variant; def: Boolean): Boolean;
function VarToInt(const v: Variant; var bv: Integer): Boolean;
function VarToIntDef(const v: Variant; def: Integer): Integer;
function VarToInt64(const v: Variant; var bv: Int64): Boolean;
function VarToInt64Def(const v: Variant; def: Int64): Int64;
function VarToFloat(const v: Variant; var bv: Double): Boolean;
function VarToFloatDef(const v: Variant; def: Double): Double;
procedure SetNull(var Value: Variant);
{$ENDREGION}

{$REGION 'sub string search'}
function WCharInSet(c: WideChar; cs: TAnsiCharSet): Boolean; inline;
function WCharInSetFast(c: WideChar; cs: TAnsiCharSet): Boolean; inline;
function ByteInSet(c: AnsiChar; cs: TAnsiCharSet): Boolean; inline;

var
  CharInSet: function(c: Char; cs: TAnsiCharSet): Boolean;
{$REGION 'copy from Synapse framework, see http://www.synopse.info/fossil/wiki/Synopse+OpenSource'}
function GotoNextNotSpace(p: PWideChar): PWideChar; overload;
function GotoNextNotSpace(p: PAnsiChar): PAnsiChar; overload;
{$ENDREGION}
function IsSpace(ch: WideChar): Boolean; overload; inline;
function IsCJK(ch: WideChar): Boolean; inline;
function IsSimplifiedChineseCharacter(ch: WideChar): Boolean;
function StrScanA(s: PAnsiChar; len: Integer; c: AnsiChar): PAnsiChar; overload;
function StrScanA(s: PAnsiChar; c: AnsiChar): PAnsiChar; overload;
function RBStrScan(const s: RawByteString; c: AnsiChar; first: Integer = 1; last: Integer = 0): Integer; inline;
function SeekAnsiChar(s: PAnsiChar; len: Integer; what: AnsiChar): PAnsiChar;
function SeekAnsiChars(s: PAnsiChar; len: Integer; const whats: array of AnsiChar): PAnsiChar;

function StrScanW(s: PWideChar; len: Integer; c: WideChar): PWideChar; overload;
function StrScanW(s: PWideChar; c: WideChar): PWideChar; overload;
function UStrScan(const s: u16string; c: WideChar; first: Integer = 1; last: Integer = 0): Integer;
function BStrScan(const s: WideString; c: WideChar; first: Integer = 1; last: Integer = 0): Integer;
function StrScan(const s: string; c: Char): Integer;
function SeekWideChar(s: PWideChar; len: Integer; what: WideChar): PWideChar;
function SeekWideChars(s: PWideChar; len: Integer; const whats: array of WideChar): PWideChar;

{$region 'pattern search'}
{$IFDEF WIN32}
function SysUtils_StrPosW(str, substr: PWideChar): PWideChar;assembler;
function StrPosW(substr, str: PWideChar): PWideChar; overload; inline;
{$ELSE}
function StrPosW(substr, str: PWideChar): PWideChar; overload;
{$ENDIF}

function StrPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;
function UStrPos(const substr, str: u16string; first: Integer = 1; last: Integer = 0): Integer; overload;
function BStrPos(const substr, str: WideString; first: Integer = 1; last: Integer = 0): Integer; overload;

function StrIPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;
function StrIPosW(substr: u16string; str: PWideChar; len: Integer): PWideChar; overload;
function StrIPosW(substr, str: PWideChar): PWideChar; overload;
function UStrIPos(const substr, str: u16string; first: Integer = 1; last: Integer = 0): Integer;
function BStrIPos(const substr, str: WideString; first: Integer = 1; last: Integer = 0): Integer;

function StrRPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;
function StrRPosW(substr, str: PWideChar): PWideChar; overload;
function UStrRPos(const substr, str: u16string; first: Integer = 1; last: Integer = 0): Integer;
function BStrRPos(const substr, str: WideString; first: Integer = 1; last: Integer = 0): Integer;

function StrRIPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;
function StrRIPosW(substr, str: PWideChar): PWideChar; overload;
function UStrRIPos(const substr, str: u16string; first: Integer = 1; last: Integer = 0): Integer;
function BStrRIPos(const substr, str: WideString; first: Integer = 1; last: Integer = 0): Integer;

{$IFDEF WIN32}
function SysUtils_StrPosA(str, substr: PAnsiChar): PAnsiChar; assembler;
{$ENDIF}
function StrPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar; overload;
function StrPosA(substr: TAnsiCharSection; str: TAnsiCharSection): PAnsiChar; overload;
function StrPosA(substr: PAnsiChar; str: PAnsiChar): PAnsiChar; overload; {$IFDEF WIN32} inline; {$ENDIF}
function RBStrPos(const substr, str: RawByteString; first: Integer = 1; last: Integer = 0): Integer;

function StrIPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar; overload;
function StrIPosA(substr, str: PAnsiChar): PAnsiChar; overload;
function RBStrIPos(const substr, str: RawByteString; first: Integer = 1; last: Integer = 0): Integer;

function StrRPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar; overload;
function StrRPosA(substr, str: PAnsiChar): PAnsiChar; overload;
function RBStrRPos(const substr, str: RawByteString; first: Integer = 1; last: Integer = 0): Integer;

function StrRIPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar; overload;
function StrRIPosA(substr, str: PAnsiChar): PAnsiChar; overload;
function RBStrRIPos(const substr, str: RawByteString; first: Integer = 1; last: Integer = 0): Integer;

function BeginWithW(s: PWideChar; len: Integer; sub: PWideChar; sublen: Integer): Boolean; overload;
function BeginWithW(s: PWideChar; len: Integer; const sub: u16string): Boolean; overload;
function BeginWithW(s, sub: PWideChar): Boolean; overload;
function UStrBeginWith(const s, sub: u16string): Boolean;

function IBeginWithW(s: PWideChar; len: Integer; sub: PWideChar; sublen: Integer): Boolean; overload;
function IBeginWithW(s, sub: PWideChar): Boolean; overload;
function UStrIBeginWith(const s, sub: u16string): Boolean;

function EndWithW(str: PWideChar; len: Integer; suffix: PWideChar; suffixLen: Integer): Boolean; overload;
function EndWithW(s, sub: PWideChar): Boolean; overload;
function EndWithW(s: PWideChar; len: Integer; const suffix: u16string): Boolean; overload;
function UStrEndWith(const str, suffix: u16string): Boolean;

function IEndWithW(str: PWideChar; len: Integer; suffix: PWideChar; suffixLen: Integer): Boolean; overload;
function IEndWithW(s, sub: PWideChar): Boolean; overload;
function UStrIEndWith(const str, suffix: u16string): Boolean;

function BeginWithA(s: PAnsiChar; len: Integer; sub: PAnsiChar; sublen: Integer): Boolean; overload;
function BeginWithA(s: PAnsiChar; len: Integer; const sub: RawByteString): Boolean; overload; inline;
function BeginWithA(s, sub: PAnsiChar): Boolean; overload;
function RBStrBeginWith(const s, sub: RawByteString): Boolean;

function IBeginWithA(s: PAnsiChar; len: Integer; sub: PAnsiChar; sublen: Integer): Boolean; overload;
function IBeginWithA(s, sub: PAnsiChar): Boolean; overload;
function RBStrIBeginWith(const s, sub: RawByteString): Boolean;

function EndWithA(str: PAnsiChar; len: Integer; suffix: PAnsiChar; suffixLen: Integer): Boolean; overload;
function EndWithA(s, sub: PAnsiChar): Boolean; overload;
function RBStrEndWith(const str, suffix: RawByteString): Boolean;

function IEndWithA(str: PAnsiChar; len: Integer; suffix: PAnsiChar; suffixLen: Integer): Boolean; overload;
function IEndWithA(s, sub: PAnsiChar): Boolean; overload;
function RBStrIEndWith(const str, suffix: RawByteString): Boolean;

type
  TKMPPatternSearchAnsi = record
  public
    FPattern: RawByteString;
    FShiftTable: array of Integer;
    procedure _BuildShiftTable;
    procedure init(APattern: PAnsiChar; PatternLen: Integer); overload;
    procedure init(APattern: RawByteString); overload;
    procedure cleanup; inline;
    function search(AText: PAnsiChar; TextLen: Integer): PAnsiChar; overload;
    function search(const AText: RawByteString): Integer; overload;
  end;

  TKMPPatternSearchUCS2 = record
  public
    FPattern: u16string;
    FShiftTable: array of Integer;
    procedure _BuildShiftTable;
    procedure init(APattern: PWideChar; PatternLen: Integer); overload;
    procedure init(APattern: u16string); overload; inline;
    procedure cleanup; inline;
    function search(AText: PWideChar; TextLen: Integer): PWideChar; overload;
    function search(const AText: u16string): Integer; overload;
  end;

  //Boyer Moore提出的模式匹配算法
  TBoyerMoorePatternSearchAnsi = record
    FPattern: RawByteString;
    FBadCharShift: array [AnsiChar] of Integer;
    FGoodSuffixShift: array of Integer;
    procedure _CalcGoodSuffixTable;
    procedure _BuildShiftTable;
  public
    procedure init(APattern: PAnsiChar; PatternLen: Integer); overload;
    procedure init(APattern: RawByteString); overload;
    procedure cleanup; inline;
    function search(AText: PAnsiChar; TextLen: Integer): PAnsiChar; overload;
    function search(const AText: RawByteString): Integer; overload;
  end;

{$endregion}

function RBStrReplace(const s, OldPattern, NewPattern: RawByteString; flags: TReplaceFlags): RawByteString;
function UStrReplace(const s, OldPattern, NewPattern: u16string; flags: TReplaceFlags): u16string;
function BStrReplace(const s, OldPattern, NewPattern: WideString; flags: TReplaceFlags): WideString;

function StrReplace(const s, OldPattern, NewPattern: RawByteString; flags: TReplaceFlags): RawByteString; overload;
function StrReplace(const s, OldPattern, NewPattern: u16string; flags: TReplaceFlags): u16string; overload;
function StrReplace(const s, OldPattern, NewPattern: WideString; flags: TReplaceFlags): WideString; overload;
{$ENDREGION}
{$REGION 'string compare'}
function AsciiCompare(s1: PAnsiChar; len1: Integer; s2: PAnsiChar; len2: Integer): Integer; overload;
function RBStrAsciiCompare(const s1, s2: RawByteString): Integer; overload; inline;
function AsciiICompare(s1: PAnsiChar; len1: Integer; s2: PAnsiChar; len2: Integer): Integer; overload;
function AsciiICompare(const s1, s2: RawByteString): Integer; overload; inline;
function RBStrAsciiICompare(const s1, s2: RawByteString): Integer; overload; inline;

function AsciiCompare(s1: PWideChar; len1: Integer; s2: PWideChar; len2: Integer): Integer; overload;
function UStrAsciiCompare(const s1, s2: u16string): Integer;
function AsciiICompare(s1: PWideChar; len1: Integer; s2: PWideChar; len2: Integer): Integer; overload;
function UStrAsciiICompare(const s1, s2: u16string): Integer;

function WordsCompare(s1, s2: PWideChar): Integer;
function WordsICompare(s1, s2: PWideChar): Integer;

function StrCompareW(const s1: PWideChar; L1: Integer; s2: PWideChar; L2: Integer;
  CaseSensitive: Boolean = True): Integer; overload;
function StrCompareW(s1, s2: PWideChar; CaseSensitive: Boolean = True): Integer; overload;
function UStrCompare(const s1, s2: u16string; CaseSensitive: Boolean = True): Integer;
function BStrCompare(const s1, s2: WideString; CaseSensitive: Boolean = True): Integer;

function StrCompareA(str1: PAnsiChar; len1: Integer; str2: PAnsiChar; len2: Integer;
  CaseSensitive: Boolean = True): Integer; overload;
function StrCompareA(const str1, str2: PAnsiChar; CaseSensitive: Boolean = True): Integer; overload;
function RBStrCompare(const str1, str2: RawByteString; CaseSensitive: Boolean = True): Integer; overload;

function StrCompare(const str1, str2: RawByteString; CaseSensitive: Boolean = True): Integer; overload;
function StrCompare(const s1, s2: u16string; CaseSensitive: Boolean = True): Integer; overload;
function StrCompare(const s1: u16string; s2: PWideChar; s2len: Integer;
  CaseSensitive: Boolean = True): Integer; overload;
function StrCompare(const s1, s2: WideString; CaseSensitive: Boolean = True): Integer; overload;
{$ENDREGION}
function UStrCatCStr(const s1: array of u16string; s2: PWideChar): u16string;
{$REGION 'sub string extract'}
function GetSectionBetweenA(s: PAnsiChar; len: Integer; const prefix, suffix: RawByteString;
  out SectionBegin, SectionEnd: PAnsiChar; flags: TStringSearchFlags = []): Boolean;

function RBStrGetSectionBetween(const src, prefix, suffix: RawByteString; out P1, P2: Integer; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function RBStrGetTrimedSectionBetween(const src, prefix, suffix: RawByteString; out P1, P2: Integer;
  first: Integer = 1; last: Integer = 0; flags: TStringSearchFlags = []): Boolean;

function RBStrGetSubstrBetween(const src, prefix, suffix: RawByteString; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): RawByteString; overload;

function RBStrGetTrimedSubstrBetween(const src, prefix, suffix: RawByteString; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): RawByteString; overload;

function RBStrTryGetIntegerBetween(const src, prefix, suffix: RawByteString; out value: Integer; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function RBStrGetIntegerBetween(const src, prefix, suffix: RawByteString; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): Integer; overload;

function RBStrTryGetBoolBetween(const src, prefix, suffix: RawByteString; out value: Boolean; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean;

function RBStrGetBoolBetween(const src, prefix, suffix: RawByteString; def: Boolean; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function RBStrTryGetInt64Between(const src, prefix, suffix: RawByteString; out value: Int64; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function RBStrGetInt64Between(const src, prefix, suffix: RawByteString; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): Int64; overload;

function RBStrTryGetFloatBetween(const src, prefix, suffix: RawByteString; out value: Double; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function RBStrGetFloatBetween(const src, prefix, suffix: RawByteString; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): Double; overload;

function GetSectionBetweenW(s: PWideChar; len: Integer; const prefix, suffix: u16string;
  out SectionBegin, SectionEnd: PWideChar; flags: TStringSearchFlags = []): Boolean;

function UStrGetSectionBetween(const src, prefix, suffix: u16string; out P1, P2: Integer; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function UStrGetTrimedSectionBetween(const src, prefix, suffix: u16string; out P1, P2: Integer; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function UStrGetSubstrBetween(const src, prefix, suffix: u16string; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): u16string; overload;

function UStrGetTrimedSubstrBetween(const src, prefix, suffix: u16string; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): u16string; overload;

function UStrTryGetIntegerBetween(const src, prefix, suffix: u16string; out value: Integer; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean;

function UStrGetIntegerBetween(const src, prefix, suffix: u16string; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): Integer; overload;

function UStrTryGetBoolBetween(const src, prefix, suffix: u16string; out value: Boolean; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean;

function UStrGetBoolBetween(const src, prefix, suffix: u16string; def: Boolean; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function UStrTryGetInt64Between(const src, prefix, suffix: u16string; out value: Int64; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function UStrGetInt64Between(const src, prefix, suffix: u16string; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): Int64; overload;

function UStrTryGetFloatBetween(const src, prefix, suffix: u16string; out value: Double; first: Integer = 1;
  last: Integer = 0; flags: TStringSearchFlags = []): Boolean; overload;

function UStrGetFloatBetween(const src, prefix, suffix: u16string; first: Integer = 1; last: Integer = 0;
  flags: TStringSearchFlags = []): Double; overload;

function GetSectionBetweenA2(s: PAnsiChar; len: Integer; const prefix: RawByteString; const suffix: array of AnsiChar;
  out SectionBegin, SectionEnd: PAnsiChar; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function RBStrGetSectionBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  out P1, P2: Integer; first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True;
  flags: TStringSearchFlags = []): Boolean; overload;

function RBStrGetTrimedSectionBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  out P1, P2: Integer; first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True;
  flags: TStringSearchFlags = []): Boolean; overload;

function RBStrGetSubstrBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; first: Integer = 1;
  last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): RawByteString; overload;

function RBStrGetTrimedSubstrBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True;
  flags: TStringSearchFlags = []): RawByteString; overload;

function RBStrTryGetIntegerBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  out value: Integer; first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True;
  flags: TStringSearchFlags = []): Boolean;

function RBStrGetIntegerBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; first: Integer = 1;
  last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Integer;

function RBStrTryGetBoolBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; out value: Boolean;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function RBStrGetBoolBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; def: Boolean;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function RBStrTryGetInt64Between2(const src, prefix: RawByteString; const suffix: array of AnsiChar; out value: Int64;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function RBStrGetInt64Between2(const src, prefix: RawByteString; const suffix: array of AnsiChar; first: Integer = 1;
  last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Int64;

function RBStrTryGetFloatBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; out value: Double;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function RBStrGetFloatBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; first: Integer = 1;
  last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Double;

// 提取夹在prefix和suffix中任一字符之间的子串
function GetSectionBetweenW2(s: PWideChar; len: Integer; const prefix: u16string; const suffix: array of WideChar;
  out SectionBegin, SectionEnd: PWideChar; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function UStrGetSectionBetween2(const src, prefix: u16string; const suffix: array of WideChar; out P1, P2: Integer;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function UStrGetTrimedSectionBetween2(const src, prefix: u16string; const suffix: array of WideChar;
  out P1, P2: Integer; first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True;
  flags: TStringSearchFlags = []): Boolean;

function UStrGetSubstrBetween2(const src, prefix: u16string; const suffix: array of WideChar; first: Integer = 1;
  last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): u16string; overload;

function UStrGetTrimedSubstrBetween2(const src, prefix: u16string; const suffix: array of WideChar;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True;
  flags: TStringSearchFlags = []): u16string; overload;

function UStrTryGetIntegerBetween2(const src, prefix: u16string; const suffix: array of WideChar;
  out value: Integer; first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True;
  flags: TStringSearchFlags = []): Boolean;

function UStrGetIntegerBetween2(const src, prefix: u16string; const suffix: array of WideChar; first: Integer = 1;
  last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Integer;

function UStrTryGetInt64Between2(const src, prefix: u16string; const suffix: array of WideChar; out value: Int64;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function UStrGetInt64Between2(const src, prefix: u16string; const suffix: array of WideChar; first: Integer = 1;
  last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Int64;

function UStrTryGetBoolBetween2(const src, prefix: u16string; const suffix: array of WideChar; out value: Boolean;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function UStrGetBoolBetween2(const src, prefix: u16string; const suffix: array of WideChar; def: Boolean;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function UStrTryGetFloatBetween2(const src, prefix: u16string; const suffix: array of WideChar; out value: Double;
  first: Integer = 1; last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Boolean;

function UStrGetFloatBetween2(const src, prefix: u16string; const suffix: array of WideChar; first: Integer = 1;
  last: Integer = 0; EndingNoSuffix: Boolean = True; flags: TStringSearchFlags = []): Double; overload;

function UStrCopyUntil(const src: u16string; const suffix: array of WideChar; first, last: Integer;
  EndingNoSuffix: Boolean = True): u16string;

function UStrTrimCopy(const s: u16string; first: Integer = 1; len: Integer = -1): u16string;
function RBStrTrimCopy(const s: RawByteString; first: Integer = 1; len: Integer = -1): RawByteString;
function BStrTrimCopy(const s: WideString; first: Integer = 1; len: Integer = -1): WideString;

function GetTagClosedW(s: PWideChar; len: Integer; BeginTag, EndTag: WideChar; out TagBegin: PWideChar): Integer;

function UStrGetTagClosed(const s: u16string; BeginTag, EndTag: WideChar; first: Integer = 1;
  last: Integer = 0): u16string;

type
  TRBStrSectionProc = function(str: PAnsiChar; len: Integer): Boolean;

function RBStrExtract(const s, ValidChars: RawByteString; callback: TRBStrSectionProc = nil): RawByteString;
function RBStrExtractEmail(const s: RawByteString): RawByteString;
function RBStrExtractQQID(const s: RawByteString): RawByteString;

type
  TUStrSectionProc = function(str: PWideChar; len: Integer): Boolean;

function IsValidPassword(const str: u16string): Boolean;
function UStrExtract(const s, ValidChars: u16string; callback: TUStrSectionProc = nil): u16string;
function UStrExtractEmail(const s: u16string): u16string;
function UStrExtractQQID(const s: u16string): u16string;
function UStrExtractPassword(const s: u16string): u16string;

function ExtractIntegerA(str: PAnsiChar; len: Integer): Int64;
function RBStrExtractInteger(const str: RawByteString; first: Integer = 1; last: Integer = 0): Int64;
function ExtractFloatA(str: PAnsiChar; len: Integer): Double;
function RBStrExtractFloat(const str: RawByteString; first: Integer = 1; last: Integer = 0): Double;

function RBStrExtractIntegers(const str: RawByteString; var numbers: array of Int64): Integer;

function ExtractIntegerW(str: PWideChar; len: Integer): Int64;
function UStrExtractInteger(const str: u16string; first: Integer = 1; last: Integer = 0): Int64;
function BStrExtractInteger(const str: WideString; first: Integer = 1; last: Integer = 0): Int64;
function ExtractFloatW(str: PWideChar; len: Integer): Double;
function UStrExtractFloat(const str: u16string; first: Integer = 1; last: Integer = 0): Double;
function BStrExtractFloat(const str: WideString; first: Integer = 1; last: Integer = 0): Double;

function UStrExtractIntegers(const str: u16string; var numbers: array of Int64): Integer;
function BStrExtractIntegers(const str: WideString; var numbers: array of Int64): Integer;

function GetFloatBeforeA(str: PAnsiChar; len: Integer; substr: PAnsiChar; sublen: Integer; var value: Double): Boolean;
function GetFloatBeforeW(str: PWideChar; len: Integer; substr: PWideChar; sublen: Integer; var value: Double): Boolean;
function RBStrGetFloatBefore(const s, suffix: RawByteString; var value: Double): Boolean;
function UStrGetFloatBefore(const s, suffix: u16string; var value: Double): Boolean;
function BStrGetFloatBefore(const s, suffix: WideString; var value: Double): Boolean;
function GetFloatBefore(const s, suffix: RawByteString; var value: Double): Boolean; overload;
function GetFloatBefore(const s, suffix: u16string; var value: Double): Boolean; overload;
function GetFloatBefore(const s, suffix: WideString; var value: Double): Boolean; overload;

function GetIntegerBeforeA(str: PAnsiChar; len: Integer; substr: PAnsiChar; sublen: Integer;
  var value: Integer): Boolean;
function GetIntegerBeforeW(str: PWideChar; len: Integer; substr: PWideChar; sublen: Integer;
  var value: Integer): Boolean;
function RBStrGetIntegerBefore(const s, suffix: RawByteString; var value: Integer): Boolean;
function UStrGetIntegerBefore(const s, suffix: u16string; var value: Integer): Boolean;
function BStrGetIntegerBefore(const s, suffix: WideString; var value: Integer): Boolean;
function GetIntegerBefore(const s, suffix: RawByteString; var value: Integer): Boolean; overload;
function GetIntegerBefore(const s, suffix: u16string; var value: Integer): Boolean; overload;
function GetIntegerBefore(const s, suffix: WideString; var value: Integer): Boolean; overload;

function ExcludePrefix(const s, prefix: string): string;

{$ENDREGION}
{$REGION '格式验证'}
function PasswordScore(const password: RawByteString): Integer;

function IsIntegerA(str: PAnsiChar; len: Integer): Boolean;
function RBStrIsInteger(const str: RawByteString): Boolean;

function IsIntegerW(str: PWideChar; len: Integer): Boolean;
function UStrIsInteger(const str: u16string): Boolean;
function BStrIsInteger(const str: WideString): Boolean;

var
  isInteger: function(const str: string): Boolean;

function IsValidEmailA(str: PAnsiChar; len: Integer): Boolean;
function RBStrIsValidEmail(const s: RawByteString): Boolean;

function IsValidEmailW(str: PWideChar; len: Integer): Boolean;
function BStrIsValidEmail(const s: WideString): Boolean;
function UStrIsValidEmail(const s: u16string): Boolean;

var
  IsValidEmail: function(const str: string): Boolean;

function RBStrIsCnIDCard(const idc: RawByteString): Boolean;
function UStrIsCnIDCard(const idc: u16string): Boolean;

var
  IsCnIDCard: function(const idc: string): Boolean;

function IsQQA(str: PAnsiChar; len: Integer): Boolean;
function RBStrIsQQ(const str: RawByteString): Boolean;

function IsQQW(str: PWideChar; len: Integer): Boolean;
function UStrIsQQ(const str: u16string): Boolean;

var
  IsQQ: function(const str: string): Boolean;
{$ENDREGION}
function StrSliceA(s: PAnsiChar; len, offset: Integer; num: Integer = -1): RawByteString; overload;

function StrSliceA(const s: RawByteString; offset: Integer; num: Integer = -1): RawByteString; overload;

procedure StrSplit(const str, delimiter: string; list: TStrings);

procedure UStrSplit2(const s, delimiter: u16string; out s1, s2: u16string; BeginIndex: Integer = 1;
  last: Integer = 0);

function UStrGetDelimiteredSection(const s, delimiter: u16string; index: Integer; first: Integer = 1;
  last: Integer = 0): u16string;

function TrimStrings(strs: TStrings): TStrings;
function DeleteBlankItems(strs: TStrings): TStrings;

function RBStrsTrim(strs: TRawByteStrings): TRawByteStrings;
function RBStrsDeleteBlankItems(strs: TRawByteStrings): TRawByteStrings;

function UStrsTrim(strs: TUnicodeStrings): TUnicodeStrings;
function UStrsDeleteBlankItems(strs: TUnicodeStrings): TUnicodeStrings;

function RBStrSplit(const str: RawByteString; const delimiters: array of AnsiChar;
  var strs: array of RawByteString): Integer;

procedure RBStrSplit2(const s, delimiter: RawByteString; out s1, s2: RawByteString; BeginIndex: Integer = 1;
  last: Integer = 0);

var
  StrSplit2: procedure(const s, delimiter: string; out s1, s2: string; BeginIndex: Integer = 1; last: Integer = 0);

function StrToDateTimeA(const s: RawByteString; out dt: TDateTime): Boolean;

function UStrToDateTime(const s: u16string; out dt: TDateTime): Boolean;
{$REGION 'debug output'}
function SafeWriteln(const s: RawByteString): Boolean; overload;
function SafeWriteln(const s: u16string): Boolean; overload;

function PrintArray(const args: array of const ; const separator: string = #32; LineFeed: Boolean = True): Boolean;

function WritelnException(e: Exception): Boolean; overload;
function WritelnException(const func: string; e: Exception): Boolean; overload;

function OutputDebugArray(const args: array of const ; const separator: string = #32;
  LineFeed: Boolean = True): Boolean;

function OutputDebugException(e: Exception): Boolean; overload;
function OutputDebugException(const func: string; e: Exception): Boolean; overload;

procedure MyOutputDebugString(const s: u16string); overload;
procedure MyOutputDebugString(const s: RawByteString); overload;

function RBStrDbgOutput(const msg: RawByteString): Boolean;
function UStrDbgOutput(const msg: u16string): Boolean;
function DbgOutput(const msg: u16string): Boolean; overload;
function DbgOutput(const msg: RawByteString): Boolean; overload;
function DbgOutput(const args: array of const ; const separator: string = #32;
  LineFeed: Boolean = True): Boolean; overload;

function DbgOutputFmtA(const fmt: RawByteString; const args: array of const ): Boolean;
function DbgOutputFmtW(const fmt: u16string; const args: array of const ): Boolean;
function DbgOutputFmt(const fmt: string; const args: array of const ): Boolean;

function DbgOutputException(e: Exception): Boolean; overload;
function DbgOutputException(const func: string; e: Exception): Boolean; overload;

procedure StreamWriteStrA(stream: TStream; const str: RawByteString);
procedure StreamWriteUStr(stream: TStream; const str: u16string);
{$ENDREGION}
{$REGION 'hex transform interface'}
function MemHex(const Buffer; size: Integer; UpperCase: Boolean = True; delimiter: RawByteString = ''): RawByteString;
  overload;
function MemHex(const s: RawByteString; UpperCase: Boolean = True; delimiter: RawByteString = ''): RawByteString;
  overload;
function MemHexUStr(const Buffer; size: Integer; UpperCase: Boolean = True;
  delimiter: u16string = ''): u16string; overload;
function MemHexUStr(const s: RawByteString; UpperCase: Boolean = True; delimiter: u16string = ''): u16string;
  overload;

function hexValue(ch: AnsiChar): Byte; overload; inline;
function hexValue(ch: WideChar): Byte; overload; inline;
function HexDecode(hex: PAnsiChar; hexLen: Integer; var buf): Integer; overload;
function HexDecode(const hex: RawByteString; var buf): Integer; overload;
function HexDecode(hex: PAnsiChar; hexLen: Integer): RawByteString; overload;
function HexDecode(const hex: RawByteString): RawByteString; overload;
function HexDecodeEx(hex: PAnsiChar; hexLen: Integer; var buf): Integer; overload;
function HexDecodeEx(const hex: RawByteString; var buf): Integer; overload;
function HexDecodeEx(hex: PAnsiChar; hexLen: Integer): RawByteString; overload;
function HexDecodeEx(const hex: RawByteString): RawByteString; overload;

function mixedHexDecode(hex: PAnsiChar; hexLen: Integer): RawByteString; overload;
function mixedHexDecode(const hex: RawByteString): RawByteString; overload;
{$ENDREGION}
function CloneList(src: TList): TList;
procedure Move2List(src, dest: TList);

procedure ThreadListInsert(list: TThreadList; index: Integer; item: Pointer);
procedure ThreadListAdd(list: TThreadList; item: Pointer);
procedure ThreadListDelete(list: TThreadList; index: Integer);
procedure ThreadListRemove(list: TThreadList; item: Pointer);
function ThreadListGetItem(list: TThreadList; index: Integer): Pointer;
function ThreadListGetInternalList(list: TThreadList): TList;
function ThreadListGetCount(list: TThreadList): Integer;

procedure RefObject(instance: TObject);
procedure SmartUnrefObject(obj: TObject);
procedure ClearObjectList(objlist: TObject);
procedure ClearObjectListAndFree(objlist: TObject);
{$REGION '文件目录相关'}
procedure EmptyFile(const FileName: string);
procedure SubDirList(const ParentDir: string; strs: TStrings);
function CopyDirecotry(const SrcDir, DstDir: string; recursive: Boolean = False): Integer;
procedure SearchFiles(const ParentDir, filter: string; strs: TStrings);
procedure SafeForceDirectories(const dir: string);
function PathJoin(const s1, s2: string): string;
procedure SaveStreamToFile(const FileName: string; stream: TStream; len: Integer);
function SafeSaveStreamToFile(const FileName: string; stream: TStream; len: Integer): Boolean;
procedure SaveBufToFile(const FileName: string; buf: Pointer; len: Integer);
procedure SaveStrToFile(const FileName: string; const str: RawByteString);
function SafeSaveStrToFile(const FileName: string; const str: RawByteString): Boolean;
procedure SaveUStrToFile(const FileName: string; const str: u16string; CodePage: Integer = CP_ACP);
function SafeSaveUStrToFile(const FileName: string; const str: u16string; CodePage: Integer = CP_ACP): Boolean;
procedure SaveStrsToFile(const FileName: string; const strs: array of RawByteString);
function SafeSaveStrsToFile(const FileName: string; const strs: array of RawByteString): Boolean;
procedure SaveArrayToFile(const FileName: string; const values: array of const );
function SafeSaveArrayToFile(const FileName: string; const values: array of const ): Boolean;
function LoadStrFromFile(const FileName: string): RawByteString;
function Stream2String(stream: TStream): RawByteString;
function getStreamContentType(data: TStream): RawByteString;
{$ENDREGION}

function ControlFindContainer(control: TControl; cls: TClass): TWinControl;
function ControlFindChild(container: TWinControl; cls: TClass): TControl;

procedure InfoBox(const msg: string; _Parent: THandle = 0);
procedure ErrorBox(const msg: string; _Parent: THandle = 0);
procedure WarnBox(const msg: string; _Parent: THandle = 0);
function ConfirmBox(const msg: string; _Parent: THandle = 0): Boolean;

procedure ShowMessageEx(const v: TAnsiCharSection); overload;
procedure ShowMessageEx(const v: string); overload;
procedure ShowMessageEx(const v: RawByteString); overload;
procedure ShowMessageEx(v: Integer); overload;
procedure ShowMessageEx(v: Int64); overload;
procedure ShowMessageEx(v: Double); overload;
procedure ShowMessageEx(v: Extended); overload;
procedure ShowMessageEx(v: Real); overload;
//procedure ShowMessageEx(v: Real48); overload;
procedure ShowMessageEx(v: Boolean); overload;

function ControlVisible(ctrl: TControl): Boolean;
procedure ControlSetFocus(ctrl: TWinControl);
procedure EditSetNumberOnly(edit: TWinControl);
function CtrlDown: Boolean;
procedure CloseForm(form: TCustomForm);
procedure SetModalResult(form: TCustomForm; mr: TModalResult);
procedure ShowForm(form: TCustomForm);

procedure ListViewSetRowCount(ListView: TListView; count: Integer);
{$REGION 'url string utils'}
function RBStrUrlGetParam(const url, name: RawByteString): RawByteString;
function UStrUrlGetParam(const url, name: u16string): u16string;
function BStrUrlGetParam(const url, name: WideString): WideString;
function ExpandUrl(const url: u16string): u16string;

type
  TTextDecoderProc = function(const s: RawByteString): u16string;
  TTextBufDecoderProc = function(s: PAnsiChar; len: Integer): u16string;
  TTextEncoderProc = function(const s: u16string): RawByteString;
  TUrlValues = class(TDictionary<string, TArray<string>>)
  public
    function Get(const _Name: string; _Idx: Integer = 0): string;
    function Encode(_Encoder: TTextEncoderProc): RawByteString;
  end;

type
  TKeyValueCallback = reference to function(_KeyStart, _KeyEnd, _ValueStart, _ValueEnd: PAnsiChar): Boolean;

procedure UrlEncodedFormIterate(_Search: PAnsiChar; _SearchLen: Integer; const _Callback: TKeyValueCallback);
function ParseForm(const _Url: string; _Decoder: TTextDecoderProc): TUrlValues; overload;
function ParseForm(const _Search: RawByteString; _Decoder: TTextBufDecoderProc): TUrlValues; overload;

var
  UrlGetParam: function(const url, name: string): string;

function RBStrUrlGetFileName(const url: RawByteString): RawByteString;
function UStrUrlGetFileName(const url: u16string): u16string;

var
  UrlGetFileName: function(const url: string): string;

function UrlExtractHost(const url: u16string): u16string;
function UrlExtractPathA(const url: RawByteString): RawByteString;
function UrlExtractPathW(const url: u16string): u16string;
function UrlExtractFileNameA(const url: RawByteString): RawByteString;
function UrlExtractFileExt(const url: string): string;
function IsPictureExt(const ext: string): Boolean;
function HttpExpandUrl(const url, schema: u16string; const host: u16string = ''): u16string; overload;
function HttpExpandUrl(const url, schema: RawByteString; const host: RawByteString = ''): RawByteString; overload;
{$ENDREGION}
{$REGION 'string encoding'}
function HttpEncodeCStrTest(str: PAnsiChar; const non_conversions: RawByteString = '*._-'): Integer;

function HttpEncodeCStr2Buf(src, dst: PAnsiChar; const non_conversions: RawByteString = '*._-'): Integer; overload;

function HttpEncodeCStr(src: PAnsiChar; const non_conversions: RawByteString = '*._-'): RawByteString; overload;

function HttpEncodeBufTest(const buf; bufLen: Integer; const non_conversions: RawByteString = '*._-'): Integer;

function HttpEncodeBuf2Buf(const buf; bufLen: Integer; dst: PAnsiChar; const non_conversions: RawByteString = '*._-')
  : Integer;

function HttpEncodeBuf(const src; srcLen: Integer; const non_conversions: RawByteString = '*._-'): RawByteString;

function HttpEncode(const src: RawByteString; const non_conversions: RawByteString = '*._-'): RawByteString;

function HttpDecodeBufTest(const buf; bufLen: Integer; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeStrTest(const str: RawByteString; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeBuf2Buf(const buf; bufLen: Integer; dst: PAnsiChar; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeBuf(const buf; bufLen: Integer; invalid: PPAnsiChar = nil): RawByteString;

function HttpDecode(const src: RawByteString; invalid: PPAnsiChar = nil): RawByteString;

function HttpDecodeCStrTest(src: PAnsiChar; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeCStr2Buf(str, dst: PAnsiChar; invalid: PPAnsiChar = nil): Integer;

function HttpDecodeCStr(str: PAnsiChar; invalid: PPAnsiChar = nil): RawByteString;
function encodeURIComponent(const s: u16string): RawByteString; overload;
function encodeURIComponent(const s: RawByteString): RawByteString; overload;
function decodeURIComponent(const s: RawByteString): u16string;
function encodeURIComponentGBK(const s: u16string): RawByteString;
function decodeURIComponentGBK(_Text: PAnsiChar; _Len: Integer): u16string;

function JsonEscape(const s: u16string): u16string; overload;
function JsonEscape(const s: RawByteString): RawByteString; overload;
function JsonEscape(const s: WideString): WideString; overload;

{$ENDREGION}
function RBStrRepeat(const s: RawByteString; RepeatCount: Integer): RawByteString;
function UStrRepeat(const s: u16string; RepeatCount: Integer): u16string;

var
  StrRepeat: function(const s: string; RepeatCount: Integer): string;

procedure StrZeroAndFree(var s: string);

procedure ZeroStringA(s: PAnsiChar);
procedure RBStrZero(const s: RawByteString);
procedure RBStrZeroAndFree(var s: RawByteString);

procedure ZeroStringW(s: PWideChar);
procedure UStrZero(const s: u16string);
procedure UStrZeroAndFree(var s: u16string);

function GetStringLengthFast(s: Pointer): Integer; inline;

function UStrLen(const s: u16string): Integer;
function BStrLen(const s: WideString): Integer;
function StrLenA(const str: PAnsiChar): Integer;
function StrLenW(s: PWideChar): Integer;

function RBSOf(ch: AnsiChar; len: Integer): RawByteString;
function UStrOf(ch: WideChar; len: Integer): u16string;
function StrOf(buf: PChar; len: Integer): string;

function WCharArrayStrLen(const chars: array of WideChar): Integer;
function Array2WStr(const chars: array of WideChar): WideString;
function Array2UStr(const chars: array of WideChar): u16string;
procedure WStr2Array(var dst: array of WideChar; const src: WideString);
procedure UStr2Array(var dst: array of WideChar; const src: u16string);
function ByteArray2Str(const chars: array of AnsiChar): RawByteString;
function ByteArrayStrLen(const chars: array of AnsiChar): Integer;
procedure RawByteStr2Array(var dst: array of AnsiChar; const src: RawByteString);
function ByteArray2UStr(const chars: array of AnsiChar): u16string;

function UStrPas(const str: PWideChar): u16string;

var
  Array2Str: function(const chars: array of Char): string;

function WCharArrayCat(const arr1, arr2: array of WideChar): u16string; overload;
function WCharArrayCat(const arr1, arr2, arr3: array of WideChar): u16string; overload;
function WCharArrayCat(const arr1, arr2, arr3, arr4: array of WideChar): u16string; overload;
function WCharArrayCat(const arr1, arr2, arr3, arr4, arr5: array of WideChar): u16string; overload;
function RawByteStrInsertAfter(const src, prefix, ToInsert: AnsiString; first: Integer = 1;
  last: Integer = 0): AnsiString;
function UStrInsertAfter(const src, prefix, ToInsert: u16string; first: Integer = 1;
  last: Integer = 0): u16string;

procedure MsgSleep(period: DWORD);

type
  TConfirmDlgButtons = (cdbOK, cdbOKCancel, cdbAbortRetryIgnore, cdbYesNoCancel, cdbYesNo, cdbRetryCancel);

  TConfirmDlgResult = (cdrOK, cdrCancel, cdrAbort, cdrRetry, cdrIgnore, cdrYes, cdrNo, cdrClose, cdrHelp, cdrTryAgain,
    cdrContinue);

function ConfirmDialog(const msg: string; const parent: THandle = 0; const title: string = '';
  const buttons: TConfirmDlgButtons = cdbYesNo): TConfirmDlgResult;

function RunningInMainThread: Boolean;
function StrToBoolA(s: PAnsiChar; len: Integer; def: Boolean): Boolean;
function RBStrToBool(const s: RawByteString; def: Boolean): Boolean;
function StrToBoolW(s: PWideChar; len: Integer; def: Boolean): Boolean;
function UStrToBool(const s: u16string; def: Boolean): Boolean;
function Res2StrA(const ResName: string; const ResType: string): RawByteString;
function Res2RBStrNoBOM(const ResName: string; const ResType: string): RawByteString;
procedure Res2StringList(const ResName: string; const ResType: string; strs: TStrings);
procedure SaveResToFile(const ResName, ResType, SavePath: string);
function LaunchProcess(const ApplicationName, CommandLine, CurrentDirectory: string): Boolean;
function LaunchProcessEx(const ApplicationName, CommandLine, CurrentDirectory: string): THandle;
procedure NavigateWithDefaultBrowser(const url: string);
function RegisterCOMComponet(pFileName: PChar): Boolean;
function GetHumanReadableByteSize(size: DWORD): string;
function IMEIRandomRBStr: RawByteString;
function IMEIRandomUStr: u16string;
function IMSIRandomRBStr: RawByteString;
function IMSIRandomUStr: u16string;
function MacAddressRandomUStr(delimiter: u16string = '-'; fUppercase: Boolean = True): u16string;
function MacAddressRandomRBStr(delimiter: RawByteString = '-'; fUppercase: Boolean = True): RawByteString;
{$REGION 'windows shell utils'}

type
  TSpecialFolderID = (sfiDesktop = $0000, sfiInternet = $0001, sfiPrograms = $0002, sfiControls = $0003,
    sfiPrinters = $0004, sfiPersonal = $0005, sfiFavorites = $0006, sfiStartup = $0007, sfiRecent = $0008,
    sfiSentTo = $0009, sfiBitBucket = $000A, sfiStartMenu = $000B, sfiMyDocuments = $000C, sfiMyMusic = $000D,
    sfiMyVideo = $000E, sfiDesktopDirectory = $0010, sfiDrivers = $0011, sfiNetwork = $0012, sfiNethood = $0013,
    sfiFonts = $0014, sfiTemplates = $0015, sfiCommonStartMenu = $0016, sfiCommonPrograms = $0017,
    sfiCommonStartup = $0018, sfiCommonDesktopDirectory = $0019, sfiAppData = $001A, sfiPrintHood = $001B,
    sfiLocalAppData = $001C, sfiAltStartup = $001D, sfiCommonAltStartup = $001E, sfiCommonFavorites = $001F,
    sfiINTERNET_CACHE = $0020, sfiCookies = $0021, sfiHistory = $0022, sfiCommonAppData = $0023, sfiWindows = $0024,
    sfiSystem = $0025, sfiProgramFiles = $0026, sfiMyPictures = $0027, sfiProfile = $0028, sfiSystemX86 = $0029,
    sfiProgramFilesX86 = $002A, sfiProgramFilesCommon = $002B, sfiProgramFilesCommonX86 = $002C,
    sfiCommonTemplates = $002D, sfiCommonDocuments = $002E, sfiCommonAdminTools = $002F, sfiAdminTools = $0030,
    sfiConnections = $0031, sfiCommonMusic = $0035, sfiCommonPictures = $0036, sfiCommonVideo = $0037,
    sfiResources = $0038, sfiResourcesLocalized = $0039, sfiCommonOemLinks = $003A, sfiCDBurnArea = $003B,
    sfiComputersNearMe = $003D, sfiProfiles = $003E);

function FindChildWindowRecursive(parent: HWND; WndClassName, WndText: PWideChar;
  const ExcludeWindows: array of THandle): HWND;

function SHGetTargetOfShortcut(const LinkFile: string): string;
function SHCreateShortcut(const TargetFile, desc, CreateAt: string): Boolean;
function SHGetSpecialFolderPath(FolderID: TSpecialFolderID): string;
function InternetExplorerGetCookie(const url: u16string; HttpOnly: Boolean): u16string;
{$ENDREGION}
function getProcessorCount: Integer;
function GetEnvVar(const name: string): string;
function SetEnvVar(const name, value: string): Boolean;
function EnvPathAdd(const dir: string): Boolean;
function GetTempFileFullPath: string;
function myLoadLibrary(const paths: array of string; const dllFileName: string): hModule;
function getOSErrorMessage(errorCode: Integer): string;

type
  TEventLogType = (eltSuccess, eltAuditSuccess, eltAuditFailure, eltError, eltInformation, eltWarning);
  TServiceRunningStatus = (srsStopped, srsStartPending, srsStopPending, srsRunning, srsContinuePending,
    srsPausePending, srsPaused);
  TNTServiceType = (stWin32, stDevice, stFileSystem);
  TNTServiceStartType = (sstBoot, sstSystem, sstAuto, sstManual, sstDisabled);
  TErrorSeverity = (esIgnore, esNormal, esSevere, esCritical);

function installNTService(const name, displayName, filePath: string; _type: TNTServiceType;
  startType: TNTServiceStartType; errorSeverity: TErrorSeverity; updateIfExists: Boolean): Integer;

function uninstallNTService(const svcName: string): Integer;
function NTServiceExists(const svcName: string): Boolean;

procedure HeapSort(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc;
  pSwap: TPointerProc);

procedure QuickSort(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc;
  pSwap: TPointerProc);

function BinarySearch(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc;
  const value): Integer;

// 使用二分查找确定要插入的新元素的位置
function BinarySearchInsertPos(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc;
  const value): Integer;

// 顺序查找
function Search(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc; const value): Integer;

function ClassIDExists(const ClassID: TGUID): Boolean;

function GetVariantArg(const param: TVariantArg): Variant;

function DispMethodExists(const disp: IDispatch; _lcid: TLCID; const name: u16string): Boolean;

function CallDispMethod(const disp: IDispatch; _lcid: TLCID; const name: u16string; const params: array of const ;
  res: PVariant): Boolean;

{$region 'graphic utils'}
type
  TPictureFormat = (unknownPictureFormat, pfBitmap, pfJpeg, pfGif, pfPng, pfTiff);
function detectPictureFormat(const buf; bufSize: Integer): TPictureFormat; overload;
function detectPictureFormat(AStream: TStream): TPictureFormat; overload;
{$endregion}

type
  TObjMethod = procedure of object;

  TDynamicArray = array of Pointer;

  TCircularList = class
  private
    FList: TDynamicArray;
    FCapacity: Integer;
    FFirst: Integer;
    FCount: Integer;
    function GetItem(Index: Integer): Pointer;
    procedure SetItem(Index: Integer; const value: Pointer);
    procedure SetCount(const value: Integer);
    procedure SetCapacity(const value: Integer);
  public
    constructor Create(_capacity: Integer);
    destructor Destroy; override;
    procedure grow;
    procedure MoveHead(num: Integer);
    procedure add(item: Pointer); overload;
    function add: Pointer; overload;
    function CircularAdd(item: Pointer): Pointer; overload;
    function CircularAdd: Pointer; overload;
    function IndexOf(item: Pointer): Integer;
    procedure delete(Index: Integer);
    procedure clear;
    function remove(item: Pointer): Integer;
    function GetInternalIndex(Index: Integer): Integer;
    property InternalList: TDynamicArray read FList;
    property capacity: Integer read FCapacity write SetCapacity;
    property first: Integer read FFirst;
    property count: Integer read FCount write SetCount;
    property items[Index: Integer]: Pointer read GetItem write SetItem; default;
  end;

  TRefCountedObject = class
  private
    FRefCount: Integer;
  protected
    function ExtendLife: Boolean; dynamic;
  public
    class function NewInstance: TObject; override;
    function AddRef: Integer;
    function release: Integer;
    property RefCount: Integer read FRefCount;
  end;

  TIdAndName = class(TRefCountedObject)
  public
    ID: u16string;
    name: u16string;
  end;

  IAutoObject = interface
    function GetInstance: TObject;
  end;

  TAutoObject = class(TInterfacedObject)
  private
    fInstance: TObject;
  public
    constructor Create(_instance: TObject);
    destructor Destroy; override;
    function GetInstance: TObject;
    property instance: TObject read fInstance;
  end;

  IProc = interface
    procedure Invoke;
  end;

  IRunnable = interface
    procedure run(context: TObject);
  end;

  TRunnable = class(TRefCountedObject)
  public
    procedure run(context: TObject); virtual; abstract;
  end;

  TDelegatedRunnable = class(TInterfacedObject, IRunnable)
  private
    FProc: SysUtils.TProc;
  public
    procedure run(context: TObject);
    constructor Create(AProc: SysUtils.TProc);
  end;

  TStringVariantPair = record
    key: string;
    value: Variant;
  end;

  TProperties = record
  private
    FItems: array of TStringVariantPair;
    function GetCount: Integer;
    function GetItem(const key: string): Variant;
    procedure SetItem(const key: string; const value: Variant);
    function GetItemAt(Index: Integer): Variant;
    procedure SetItemAt(Index: Integer; const value: Variant);
  public
    procedure clear;
    function IndexOf(const key: string): Integer;
    function exists(const key: string): Boolean;
    function FindOrAdd(const key: string; value: Variant): Integer;
    property count: Integer read GetCount;
    property item[const key: string]: Variant read GetItem write SetItem; default;
    property ItemAt[Index: Integer]: Variant read GetItemAt write SetItemAt;
  end;

  PProperties = ^TProperties;

  TDispProperties = class(TInterfacedObject, IDispatch)
  private
    FItems: TProperties;
    function GetTypeInfoCount(out count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
      stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; flags: Word; var params;
      VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  public
  end;

  PLinkNode = ^TLinkNode;

  TLinkNode = record
    next: PLinkNode;
    data: Pointer;
  end;

  PDblLinkNode = ^TDblLinkNode;

  TDblLinkNode = record
    prev: PDblLinkNode;
    next: PDblLinkNode;
    data: Pointer;
  end;

  TFIFOQueue = class
  private
    FLock: TSpinLock;
    FFirst: PLinkNode;
    fLast: PLinkNode;
    fSize: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure lock; inline;
    procedure unlock; inline;
    procedure clear;
    procedure push(item: Pointer);
    procedure PushFront(item: Pointer);
    function pop: Pointer;
    property size: Integer read fSize;
  end;

  TLIFOQueue = class
  private
    FLock: TSpinLock;
    FFirst: PLinkNode;
  public
    constructor Create;
    destructor Destroy; override;
    procedure clear;
    procedure push(item: Pointer);
    function pop: Pointer;
  end;

  TThreadFileStream = class(TFileStream)
  private
    FLock: TCriticalSection;
  public
    constructor Create(const AFileName: string; Mode: Word); overload;
    constructor Create(const AFileName: string; Mode: Word; Rights: Cardinal); overload;
    destructor Destroy; override;
    procedure lock;
    procedure unlock;
  end;

  TObjectListEx = class(TObjectList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Clone: TObjectListEx;
  end;

  TThreadObjectListEx = class(TObjectListEx)
  private
    FLock: TRTLCriticalSection;
  public
    constructor Create(AOwnsObjects: Boolean = True); overload;
    destructor Destroy; override;
    procedure LockList;
    procedure UnlockList; inline;
  end;

{$region 'log utils'}
type
  TMessageLevel = (mlDebug, mlInformation, mlWarning, mlError);
  TMessageVerbosity = set of TMessageLevel;

const
  TRACE_SEVERITIES_ALL = [mlDebug, mlInformation, mlWarning, mlError];

  SEVERITY_NAMESA: array [TMessageLevel] of RawByteString = ('DEBUG', 'INFO', 'WARN', 'ERROR');
  SEVERITY_NAMESW: array [TMessageLevel] of u16string = ('DEBUG', 'INFO', 'WARN', 'ERROR');

type
  TDateTimePart = (dtpYear, dtpMonth, dtpDay, dtpHour, dtpMinute, dtpSecond);

  TTextEncoding = (teAnsi, teUTF8, teUTF16);

  TMessageTag = (mtServerity, mtTime);
  TMessageTags = set of TMessageTag;

  TLogWritter = class
  protected
    fVerbosity: TMessageVerbosity;
    fOptions: TMessageTags;
    fDateTimeFormat: string;
    procedure SetVerbosity(const value: TMessageVerbosity); dynamic;
    procedure SetOptions(const value: TMessageTags); dynamic;
    procedure SetDateTimeFormat(const value: string); dynamic;
    procedure WriteAnsi(const text: RawByteString); virtual; abstract;
    procedure WriteUnicode(const text: u16string); virtual; abstract;
  public
    constructor Create;
    procedure write(sev: TMessageLevel; const text: RawByteString); overload;
    procedure write(sev: TMessageLevel; const text: u16string); overload;
    procedure Writeln(sev: TMessageLevel; const text: RawByteString); overload;
    procedure Writeln(sev: TMessageLevel; const text: u16string); overload;

    procedure FormatWrite(sev: TMessageLevel; const fmt: RawByteString; const args: array of const ); overload;

    procedure FormatWrite(sev: TMessageLevel; const fmt: u16string; const args: array of const ); overload;

    procedure flush; virtual;
    property Verbosity: TMessageVerbosity read fVerbosity write fVerbosity;
    property options: TMessageTags read fOptions write fOptions;
    property DateTimeFormat: string read fDateTimeFormat write fDateTimeFormat;
  end;

  TFileLogWritter = class(TLogWritter)
  private
    fEncoding: TTextEncoding;
    fFileStream: TFileStream;
    function GetFileSize: Integer;
  protected
    procedure WriteAnsi(const text: RawByteString); override;
    procedure WriteUnicode(const text: u16string); override;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure flush; override;
    property FileSize: Integer read GetFileSize;
    property Encoding: TTextEncoding read fEncoding write fEncoding;
  end;

  TConsoleLogWritter = class(TLogWritter)
  protected
    procedure WriteAnsi(const text: RawByteString); override;
    procedure WriteUnicode(const text: u16string); override;
  end;

  TDebugLogWritter = class(TLogWritter)
  protected
    procedure WriteAnsi(const text: RawByteString); override;
    procedure WriteUnicode(const text: u16string); override;
  end;

  TMultiFileLogWritter = class
  private
    fLogFileDir: string;
    fLastLogTime: TDateTime;
    fLogSeparate: TDateTimePart;
    fWritter: TFileLogWritter;
    fDateTimeFormat: string;
    fVerbosity: TMessageVerbosity;
    fOptions: TMessageTags;
    fEncoding: TTextEncoding;
  protected
    procedure SetVerbosity(const value: TMessageVerbosity);
    procedure SetOptions(const value: TMessageTags);
    procedure SetDateTimeFormat(const value: string);
  protected
    procedure CreateFileTracer(tick: TDateTime);
  public
    constructor Create(const dir: string);
    destructor Destroy; override;

    procedure write(sev: TMessageLevel; const text: RawByteString); overload;
    procedure write(sev: TMessageLevel; const text: u16string); overload;
    procedure Writeln(sev: TMessageLevel; const text: RawByteString); overload;
    procedure Writeln(sev: TMessageLevel; const text: u16string); overload;

    procedure FormatWrite(sev: TMessageLevel; const fmt: RawByteString; const args: array of const ); overload;

    procedure FormatWrite(sev: TMessageLevel; const fmt: u16string; const args: array of const ); overload;

    procedure flush;

    property LogSeparate: TDateTimePart read fLogSeparate write fLogSeparate;
    property severity: TMessageVerbosity read fVerbosity write fVerbosity;
    property options: TMessageTags read fOptions write fOptions;
    property DateTimeFormat: string read fDateTimeFormat write fDateTimeFormat;
    property Encoding: TTextEncoding read fEncoding write fEncoding;
  end;
{$endregion}

  TVersion = class
  private
    fMinor: Integer;
    fRelease: Integer;
    fMajor: Integer;
    fBuild: Integer;
  public
    function compare(Other: TVersion): Integer;
    function ToString: string; override;
    property Major: Integer read fMajor write fMajor;
    property Minor: Integer read fMinor write fMinor;
    property Release: Integer read fRelease write fRelease;
    property Build: Integer read fBuild write fBuild;
  end;

  TFileVersionInfo = class
  private
    FVersionBlock: Pointer;
    FFixedInfo: PVSFixedFileInfo;
    FTransition: Pointer;
    FTransitionSize: UINT;
    FProductVersion: TVersion;
    FFileVersion: TVersion;
    FProductName: string;
    FLegalTrademarks: string;
    FLegalCopyright: string;
    FCompanyName: string;
    FFileDescription: string;
    FProgramID: string;
    FInternalName: string;
    FComments: string;
    FOriginalFilename: string;
    procedure GetFixedInfo;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    function GetStringInfo(const name: string): string;
    property FileVersion: TVersion read FFileVersion;
    property ProductVersion: TVersion read FProductVersion;
    property CompanyName: string read FCompanyName;
    property ProductName: string read FProductName;
    property OriginalFilename: string read FOriginalFilename;
    property FileDescription: string read FFileDescription;
    property InternalName: string read FInternalName;
    property LegalCopyright: string read FLegalCopyright;
    property LegalTrademarks: string read FLegalTrademarks;
    property Comments: string read FComments;
    property ProgramID: string read FProgramID;
  end;

var
  RBStrFormat: function(const Format: AnsiString; const args: array of const ): AnsiString;
  UStrFormat: function(const Format: u16string; const args: array of const ): u16string;
  RBStrCompareText: function(const s1, s2: RawByteString): Integer;
  UStrCompareText: function(const s1, s2: u16string): Integer;
  RBStrSameText: function(const s1, s2: RawByteString): Boolean;
  UStrSameText: function(const s1, s2: u16string): Boolean;
  RBStrFormatFloat: function(const Format: RawByteString; value: Extended): RawByteString;
  UStrFormatFloat: function(const Format: u16string; value: Extended): u16string;
  RBStrTrim: function(const s: RawByteString): RawByteString;
  RBStrTrimLeft: function(const s: RawByteString): RawByteString;
  RBStrTrimRight: function(const s: RawByteString): RawByteString;
  UStrTrim: function(const s: u16string): u16string;
  UStrTrimLeft: function(const s: u16string): u16string;
  UStrTrimRight: function(const s: u16string): u16string;
  InterlockedIncDWORD: function(var Addend: DWORD): DWORD; stdcall;
  InterlockedDecDWORD: function(var Addend: DWORD): DWORD; stdcall;
  InterlockedExchangeDWORD: function(var Target: DWORD; value: DWORD): DWORD; stdcall;
  InterlockedCompareExchangeDWORD: function(var Destination: DWORD; Exchange: DWORD; Comperand: DWORD): DWORD stdcall;
  InterlockedExchangeAddDWORD: function(var Addend: DWORD; value: DWORD): DWORD stdcall;

implementation

uses
  Messages;

const
  MB_ERR_INVALID_CHARS = 8; { error for invalid chars }

var
  JAVA_TIME_START: TDateTime;
  g_SystemInfo: TSystemInfo;

function InterlockedExchangePointer(var Target: Pointer; value: Pointer): Pointer;
begin
{$IFDEF WIN32}
  Result := Pointer(InterlockedExchange(Integer(Target), Integer(value)));
{$ELSE}
  Result := Target;
  Target := value;
{$ENDIF}
end;

procedure MsgSleep(period: DWORD);
var
  tick, remain, ellapse, wr: DWORD;
  events: array [0 .. 0] of THandle;
begin
  if RunningInMainThread then
  begin
    events[0] := CreateEvent(nil, False, False, nil);

    try
      tick := GetTickCount;

      while not Application.Terminated do
      begin
        ellapse := GetTickCount - tick;

        if ellapse >= period then
          Break;

        remain := period - ellapse;

        wr := MsgWaitForMultipleObjects(1, events, False, remain, QS_ALLINPUT);

        if wr = WAIT_TIMEOUT then
          Break;

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
  else
    Windows.Sleep(period);
end;

function GetHumanReadableByteSize(size: DWORD): string;
var
  v: Double;
  _unit: string;
  tmp1, tmp2: string;
begin
  if size > 1024 * 1024 * 1024 then
  begin
    v := size / (1024 * 1024 * 1024);
    _unit := 'GB';
  end
  else if size > 1024 * 1024 then
  begin
    v := size / (1024 * 1024);
    _unit := 'MB';
  end
  else if size > 1024 then
  begin
    v := size / 1024;
    _unit := 'KB';
  end
  else
  begin
    v := size;
    _unit := 'B';
  end;

  tmp1 := FloatToStr(v);
  tmp2 := FormatFloat('0.00', v);

  if length(tmp1) < length(tmp2) then
    Result := tmp1 + _unit
  else
    Result := tmp2 + _unit;
end;

function IMEICheckSumA(s: PAnsiChar): Integer;
var
  sum, i, tmp: Integer;
begin
  sum := 0;

  for i := 0 to 13 do
  begin
    if i mod 2 = 0 then
      Inc(sum, Ord(s[i]) - $30)
    else
    begin
      tmp := (Ord(s[i]) - $30) * 2;
      sum := sum + tmp mod 10 + tmp div 10;
    end;
  end;

  Result := sum mod 10;

  if Result > 0 then
    Result := 10 - Result;
end;

function IMEIRandomRBStr: RawByteString;
var
  i: Integer;
begin
  SetLength(Result, 15);
  PAnsiChar(Result)[0] := AnsiChar(49 + Random(9));

  for i := 1 to 13 do
    PAnsiChar(Result)[i] := AnsiChar(48 + Random(10));

  PAnsiChar(Result)[14] := AnsiChar(48 + IMEICheckSumA(PAnsiChar(Result)));
end;

function IMEICheckSumW(s: PWideChar): Integer;
var
  sum, i, tmp: Integer;
begin
  sum := 0;

  for i := 0 to 13 do
  begin
    if i mod 2 = 0 then
      Inc(sum, Ord(s[i]) - $30)
    else
    begin
      tmp := (Ord(s[i]) - $30) * 2;
      sum := sum + tmp mod 10 + tmp div 10;
    end;
  end;

  Result := sum mod 10;

  if Result > 0 then
    Result := 10 - Result;
end;

function IMEIRandomUStr: u16string;
var
  i: Integer;
begin
  SetLength(Result, 15);
  PWideChar(Result)[0] := WideChar(49 + Random(9));

  for i := 1 to 13 do
    PWideChar(Result)[i] := WideChar(48 + Random(10));

  PWideChar(Result)[14] := WideChar(48 + IMEICheckSumW(PWideChar(Result)));
end;

function IMSIRandomRBStr: RawByteString;
// 中国移动系统使用00、02、07，中国联通GSM系统使用01、06，中国电信CDMA系统使用03、05、电信4G使用11，中国铁通系统使用20
const
  MNCs: array [0 .. 8] of RawByteString = ('00', '01', '02', '03', '05', '06', '07', '11', '20');
var
  mnc: RawByteString;
  i: Integer;
begin
  SetLength(Result, 15);
  PAnsiChar(Result)[0] := '4';
  PAnsiChar(Result)[1] := '6';
  PAnsiChar(Result)[2] := '0';

  mnc := MNCs[Random(length(MNCs))];

  for i := 0 to length(mnc) - 1 do
    PAnsiChar(Result)[3 + i] := PAnsiChar(mnc)[i];

  for i := 3 + length(mnc) to 14 do
    PAnsiChar(Result)[i] := AnsiChar(48 + Random(10));
end;

function IMSIRandomUStr: u16string;
// 中国移动系统使用00、02、07，中国联通GSM系统使用01、06，中国电信CDMA系统使用03、05、电信4G使用11，中国铁通系统使用20
const
  MNCs: array [0 .. 8] of u16string = ('00', '01', '02', '03', '05', '06', '07', '11', '20');
var
  mnc: u16string;
  i: Integer;
begin
  SetLength(Result, 15);
  PWideChar(Result)[0] := '4';
  PWideChar(Result)[1] := '6';
  PWideChar(Result)[2] := '0';

  mnc := MNCs[Random(length(MNCs))];

  for i := 0 to length(mnc) - 1 do
    PWideChar(Result)[3 + i] := PWideChar(mnc)[i];

  for i := 3 + length(mnc) to 14 do
    PWideChar(Result)[i] := WideChar(48 + Random(10));
end;

function MacAddressRandomUStr(delimiter: u16string; fUppercase: Boolean): u16string;
var
  mac: array [0 .. 5] of Byte;
  i: Integer;
begin
  for i := Low(mac) to High(mac) do
    mac[i] := Random($100);

  Result := MemHexUStr(mac, SizeOf(mac), fUppercase, delimiter);
end;

function MacAddressRandomRBStr(delimiter: RawByteString; fUppercase: Boolean): RawByteString;
var
  mac: array [0 .. 5] of Byte;
  i: Integer;
begin
  for i := Low(mac) to High(mac) do
    mac[i] := Random($100);

  Result := MemHex(mac, SizeOf(mac), fUppercase, delimiter);
end;

function RBStrSection(const s: AnsiString; first: Integer = 1; last: Integer = 0): TAnsiCharSection;
begin
  Result._begin := PAnsiChar(s) + first - 1;
  if (last <= 0) or (last > length(s)) then
    last := length(s) + 1;
  Result._end := PAnsiChar(s) + last - 1;
end;

function UStrSection(const s: u16string; first: Integer = 1; last: Integer = 0): TWideCharSection;
begin
  Result._begin := PWideChar(s) + first - 1;
  if (last <= 0) or (last > length(s)) then
    last := length(s) + 1;
  Result._end := PWideChar(s) + last - 1;
end;

function BStrSection(const s: WideString; first: Integer = 1; last: Integer = 0): TWideCharSection;
begin
  Result._begin := PWideChar(s) + first - 1;
  if (last <= 0) or (last > length(s)) then
    last := length(s) + 1;
  Result._end := PWideChar(s) + last - 1;
end;

function StringToPChar(const s: u16string): PWideChar;
begin
  if s = '' then
    Result := nil
  else
    Result := PWideChar(s);
end;

function StringToPChar(const s: RawByteString): PAnsiChar;
begin
  if s = '' then
    Result := nil
  else
    Result := PAnsiChar(s);
end;

function charAt(p, tail: PAnsiChar): AnsiChar;
begin
  if p < tail then
    Result := p^
  else
    Result := #0;
end;

function charAt(p, tail: PWideChar): WideChar;
begin
  if p < tail then
    Result := p^
  else
    Result := #0;
end;

function IsEmptyString(p: PAnsiChar): Boolean;
begin
  Result := (p = nil) or (p^ = #0);
end;

function IsEmptyString(p: PWideChar): Boolean;
begin
  Result := (p = nil) or (p^ = #0);
end;

procedure _fastAssignStr(var dest: RawByteString; const src: RawByteString);
begin
  Pointer(dest) := Pointer(src);
end;

procedure _fastAssignStr(var dest: u16string; const src: u16string);
begin
  Pointer(dest) := Pointer(src);
end;

procedure _fastAssignStr(var dest: WideString; const src: WideString);
begin
  // WideString are not ARC
  dest := src;
end;

procedure _fastAssignStr(var dest: AnsiString; const src: AnsiString);
begin
  Pointer(dest) := Pointer(src);
end;

procedure _fastAssignStr(var dest: UTF8String; const src: UTF8String);
begin
  Pointer(dest) := Pointer(src);
end;

procedure dslMove(const src; var dest; count: Integer);
begin
  if count = 0 then
  begin

  end
  else if count = 1 then
    PByte(@dest)^ := PByte(@src)^
  else if count = 2 then
    PWideChar(@dest)^ := PWideChar(@src)^
  else if count = 3 then
  begin
    PWideChar(@dest)^ := PWideChar(@src)^;
    PAnsiChar(@dest)[2] := PAnsiChar(@src)[2]
  end
  else if count = 4 then
    PInteger(@dest)^ := PInteger(@src)^
  else if count = 8 then
    PInt64(@dest)^ := PInt64(@src)^
  else
    Move(src, dest, count);
end;


procedure FillWordX87(var dest; count: Integer; value: Word);
asm                                  // Size = 153 Bytes
        // EAX: @dest, EDX: count, CX: value
        TEST  EAX, 1
        JE    @2byte_aligned
        MOV   [EAX], CL
        MOV   [EAX+EDX*2-1], CH
        INC   EAX
        DEC   EDX
        ROL   CX, 8
@2byte_aligned:
        SHL   EDX, 1
        CMP   EDX, 32
        JL    @@Small
        MOV   [EAX  ], CX            // Fill First 8 Bytes
        MOV   [EAX+2], CX
        MOV   [EAX+4], CX
        MOV   [EAX+6], CX
        SUB   EDX, 16
        FLD   QWORD PTR [EAX]
        FST   QWORD PTR [EAX+EDX]    // Fill Last 16 Bytes
        FST   QWORD PTR [EAX+EDX+8]
        MOV   ECX, EAX
        AND   ECX, 7                 // ecx = Dest mod 8
        SUB   ECX, 8                 // ecx = Dest mod 8 - 8

        (*
        NativeInt(@Dest) + 8 - NativeInt(@Dest) mod 8
        now Dest is 8-bytes-aligned
        *)
        SUB   EAX, ECX

        ADD   EDX, ECX               // edx = NativeInt(@Dest) - (NativeInt(@Dest) mod 8 + 8) + count - 16
        ADD   EAX, EDX               // eax = NativeInt(@Dest) + count - 16
        NEG   EDX                    // edx =
@@Loop:
        FST   QWORD PTR [EAX+EDX]    // Fill 16 Bytes per Loop
        FST   QWORD PTR [EAX+EDX+8]
        ADD   EDX, 16
        JL    @@Loop
        FFREE ST(0)
        FINCSTP
        RET
@@Small:
        TEST  EDX, EDX
        JLE   @@Done
        NEG   EDX
        LEA   EDX, [@@SmallFill + 60 + EDX * 2]
        JMP   EDX
@@SmallFill:
        MOV   [EAX+28], CX
        MOV   [EAX+26], CX
        MOV   [EAX+24], CX
        MOV   [EAX+22], CX
        MOV   [EAX+20], CX
        MOV   [EAX+18], CX
        MOV   [EAX+16], CX
        MOV   [EAX+14], CX
        MOV   [EAX+12], CX
        MOV   [EAX+10], CX
        MOV   [EAX+ 8], CX
        MOV   [EAX+ 6], CX
        MOV   [EAX+ 4], CX
        MOV   [EAX+ 2], CX
        MOV   [EAX   ], CX
        RET                          // DO NOT REMOVE - This is for Alignment
@@Done:
end;

procedure FillDwordX87(var dest; count: Integer; value: UInt32);
const
  a: array [0..2] of Integer = (1,2,3);
asm     // Size = 153 Bytes
        // EAX: @dest, EDX: count, ECX: value
        TEST  EDX, EDX
        JLE   @@Done
        MOV   [EAX], ECX
        MOV   [EAX+EDX*4-4], ECX
        CMP   EDX, 2
        JLE   @@Done
        TEST  EAX, 3
        JE    @4byte_aligned
        PUSH  EBX
        MOV   EBX, EAX
        AND   EBX, 3
        NEG   EBX
        LEA   EBX, [@adjust_value + 9 + EBX * 2 + EBX]
        JMP   EBX
@adjust_value:
        ROL   ECX, 8
        ROL   ECX, 8
        ROL   ECX, 8
        POP   EBX
        AND   EAX, $fffffffc
        INC   EDX
@4byte_aligned:
        ADD   EAX, 4
        ADD   EDX, -2
        CMP   EDX, 8
        JL    @@Small
        SHL   EDX, 2
        MOV   [EAX  ], ECX            // Fill First 8 Bytes
        MOV   [EAX+4], ECX
        SUB   EDX, 16
        FLD   QWORD PTR [EAX]
        FST   QWORD PTR [EAX+EDX]    // Fill Last 16 Bytes
        FST   QWORD PTR [EAX+EDX+8]
        MOV   ECX, EAX
        AND   ECX, 7                 // ecx = Dest mod 8
        SUB   ECX, 8                 // ecx = Dest mod 8 - 8

        (*
        NativeInt(@Dest) + 8 - NativeInt(@Dest) mod 8
        now Dest is 8-bytes-aligned
        *)
        SUB   EAX, ECX

        ADD   EDX, ECX               // edx = NativeInt(@Dest) - (NativeInt(@Dest) mod 8 + 8) + count - 16
        ADD   EAX, EDX               // eax = NativeInt(@Dest) + count - 16
        NEG   EDX                    // edx =
@@Loop:
        FST   QWORD PTR [EAX+EDX]    // Fill 16 Bytes per Loop
        FST   QWORD PTR [EAX+EDX+8]
        ADD   EDX, 16
        JL    @@Loop
        FFREE ST(0)
        FINCSTP
        RET
@@Small:
        NEG   EDX
        LEA   EDX, [@@SmallFill + 21 + EDX*2 + EDX]
        JMP   EDX
@@SmallFill:
        MOV   [EAX+24], ECX
        MOV   [EAX+ 20], ECX
        MOV   [EAX+ 16], ECX
        MOV   [EAX+ 12], ECX
        MOV   [EAX+ 8], ECX
        MOV   [EAX+ 4], ECX
        MOV   [EAX   ], ECX
        RET                          // DO NOT REMOVE - This is for Alignment
@@Done:
end;

function absoluteValue(v: Integer): Integer;
begin
  if v < 0 then
    Result := -v
  else
    Result := v;
end;

function absoluteValue(v: Int64): Int64;
begin
  if v < 0 then
    Result := -v
  else
    Result := v;
end;

function absoluteValue(v: ShortInt): ShortInt;
begin
  if v < 0 then
    Result := -v
  else
    Result := v;
end;

function absoluteValue(v: SmallInt): SmallInt;
begin
  if v < 0 then
    Result := -v
  else
    Result := v;
end;

function Get1Bytes(v: Byte): RawByteString;
begin
  SetLength(Result, 1);
  PByte(Pointer(Result))^ := v;
end;

function Get2Bytes(v: Word): RawByteString;
begin
  SetLength(Result, 2);
  PWord(Pointer(Result))^ := v;
end;

function Get4Bytes(v: UInt32): RawByteString;
begin
  SetLength(Result, 4);
  PUInt32(Pointer(Result))^ := v;
end;

function Get8Bytes(v: Int64): RawByteString;
begin
  SetLength(Result, 8);
  PInt64(Pointer(Result))^ := v;
end;

procedure PaddingRight8(const src; srcLen: Integer; var dst; dstLen: Integer; paddingValue: Byte);
begin
  if srcLen >= dstLen then
    Move(src, dst, dstLen)
  else
  begin
    Move(src, dst, srcLen);
    FillChar(PAnsiChar(@dst)[srcLen], dstLen - srcLen, paddingValue);
  end;
end;

procedure PaddingRight8(const src: RawByteString; var dst; dstLen: Integer; paddingValue: Byte);
begin
  PaddingRight8(Pointer(src)^, length(src), dst, dstLen, paddingValue);
end;

procedure xorBuffer(const operand1, operand2; bufLen: Integer; var dst);
var
  i: Integer;
begin
  for i := 0 to bufLen - 1 do
    PByte(PAnsiChar(@dst) + i)^ := PByte(PAnsiChar(@operand1) + i)^ xor PByte(PAnsiChar(@operand2) + i)^;
end;

procedure andBuffer(const operand1, operand2; bufLen: Integer; var dst);
var
  i: Integer;
begin
  for i := 0 to bufLen - 1 do
    PByte(PAnsiChar(@dst) + i)^ := PByte(PAnsiChar(@operand1) + i)^ and PByte(PAnsiChar(@operand2) + i)^;
end;

procedure orBuffer(const operand1, operand2; bufLen: Integer; var dst);
var
  i: Integer;
begin
  for i := 0 to bufLen - 1 do
    PByte(PAnsiChar(@dst) + i)^ := PByte(PAnsiChar(@operand1) + i)^ or PByte(PAnsiChar(@operand2) + i)^;
end;

function RotateLeft32(v: UInt32; n: Integer): UInt32;
begin
  n := n mod 32;
  Result := (v shl n) or (v shr (32 - n));
end;

function RotateRight32(v: UInt32; n: Integer): UInt32;
begin
  n := n mod 32;
  Result := (v shr n) or (v shl (32 - n));
end;

function RotateLeft64(v: UInt64; n: Integer): UInt64;
begin
  n := n mod 64;
  Result := (v shl n) or (v shr (64 - n));
end;

function RotateRight64(v: UInt64; n: Integer): UInt64;
begin
  n := n mod 64;
  Result := (v shr n) or (v shl (64 - n));
end;

function sar32(value: UInt32; bits: Integer): UInt32;
{$IFDEF WIN64}
const
  SAR32_MASKS: array [0 .. 1] of Int32 = (0, -1);
var
  idx: Integer;
begin
  bits := bits mod 32;
  idx := ((Int32(1) shl 31) and value) shr 31;
  Result := (value shr bits) or (SAR32_MASKS[idx] shl (32 - bits));
end;
{$ELSE}
asm
  mov ecx, bits
  sar value, cl
end;
{$ENDIF}

function sar64(value: Int64; bits: Integer): Int64;
const
  SAR64_MASKS: array [0 .. 1] of Int64 = (0, -1);
var
  idx: Integer;
begin
  bits := bits mod 64;
  idx := ((Int64(1) shl 63) and value) shr 63;

  Result := (value shr bits) or (SAR64_MASKS[idx] shl (64 - bits));
end;

function ReverseByteOrder32(v: UInt32): UInt32;
begin
  Result := (v shr 24) or ((v shr 8) and $FF00) or (v shl 24) or ((v shl 8) and $FF0000);
end;

function ReverseByteOrder64(v: UInt64): UInt64;
var
  p: PUInt32;
begin
  Result := (v shl 32) or (v shr 32);
  p := PUInt32(@Result);
  p^ := ReverseByteOrder32(p^);
  Inc(p);
  p^ := ReverseByteOrder32(p^);
end;

function BigEndianToSys(v: UInt32): UInt32;
begin
  Result := ReverseByteOrder32(v);
end;

function SysToBigEndian(v: UInt32): UInt32;
begin
  Result := ReverseByteOrder32(v);
end;

function LittleEndianToSys(v: UInt32): UInt32;
begin
  Result := v;
end;

function SysToLittleEndian(v: UInt32): UInt32;
begin
  Result := v;
end;

function ReverseByteOrder16(v: UInt32): UInt32; inline;
begin
  Result := Word(v shl 8) or Word(v shr 8);
end;

function BigEndianToSys(v: Word): Word;
begin
  Result := ReverseByteOrder16(v);
end;

function SysToBigEndian(v: Word): Word;
begin
  Result := ReverseByteOrder16(v);
end;

function LittleEndianToSys(v: Word): Word;
begin
  Result := v;
end;

function SysToLittleEndian(v: Word): Word;
begin
  Result := v;
end;

function IsSameMethod(const method1, method2): Boolean;
begin
  Result := (TMethod(method1).code = TMethod(method2).code) and (TMethod(method1).data = TMethod(method2).data);
end;

function IsEqualFloat(d1, d2: Double): Boolean;
var
  diff: Double;
begin
  diff := d1 - d2;

  if diff >= 0 then
    Result := diff < 0.0001
  else
    Result := -diff < 0.0001;
end;

function myhtoll(v: Int64): Int64;
var
  tmp1: array [0 .. 7] of Byte absolute v;
  tmp2: array [0 .. 7] of Byte absolute Result;
begin
  tmp2[0] := tmp1[7];
  tmp2[1] := tmp1[6];
  tmp2[2] := tmp1[5];
  tmp2[3] := tmp1[4];
  tmp2[4] := tmp1[3];
  tmp2[5] := tmp1[2];
  tmp2[6] := tmp1[1];
  tmp2[7] := tmp1[0];
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
  if IsConsole then
    Writeln(s);
  Result := True;
end;

function SafeWriteln(const s: u16string): Boolean;
begin
  if IsConsole then
    Writeln(s);
  Result := True;
end;

function WritelnException(e: Exception): Boolean;
begin
  Writeln(e.ClassName, ': ', e.Message);
  Result := True;
end;

procedure print_var_rec(const vr: TVarRec);
begin
  case vr.VType of
    vtInteger:
      write(vr.VInteger);
    vtBoolean:
      write(vr.VBoolean);
    vtChar:
      write(vr.VChar);
    vtExtended:
      write(FloatToStr(vr.VExtended^));
    vtString:
      write(vr.VString^);
    vtPointer:
      write(Format('%.8x', [vr.VPointer]));
    vtPChar:
      write(vr.VPChar);
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

    vtWideChar:
      write(vr.VWideChar);
    vtPWideChar:
      write(vr.VPWideChar);
    vtAnsiString:
      write(RawByteString(vr.VAnsiString));
    vtCurrency:
      write(FloatToStr(vr.VCurrency^));
    vtVariant:
      write(vr.VVariant^);
    vtInterface:
      write('interface');
    vtWideString:
      write(WideString(vr.VWideString));
    vtUnicodeString:
      write(u16string(vr.VUnicodeString));
    vtInt64:
      write(vr.VInt64^);
  end;
end;

function PrintArray(const args: array of const ; const separator: string; LineFeed: Boolean): Boolean;
var
  i: Integer;
begin
  if length(args) > 0 then
  begin
    print_var_rec(TVarRec(args[ Low(args)]));

    for i := Low(args) + 1 to High(args) do
    begin
      write(separator);
      print_var_rec(TVarRec(args[i]));
    end;
  end;

  if LineFeed then
    Writeln;

  Result := True;
end;

function WritelnException(const func: string; e: Exception): Boolean;
begin
  Writeln(func, '(', e.ClassName, '): ', e.Message);
  Result := True;
end;

function OutputDebugArray(const args: array of const ; const separator: string; LineFeed: Boolean): Boolean;
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
      vtInteger:
        str := str + IntToStr(vr.VInteger);
      vtBoolean:
        str := str + BoolToStr(vr.VBoolean, True);
      vtChar:
        str := str + string(RawByteString(vr.VChar));
      vtExtended:
        str := str + FloatToStr(vr.VExtended^);
      vtString:
        str := str + string(vr.VString^);
      vtPointer:
        str := Format('%.8x', [NativeInt(vr.VPointer)]);
      vtPChar:
        str := str + string(RawByteString(vr.VPChar));
      vtObject:
        str := str + 'object(' + vr.VObject.ClassName + ')';

      vtClass:
        str := str + 'class(' + vr.VClass.ClassName + ')';
      vtWideChar:
        str := str + vr.VWideChar;
      vtPWideChar:
        str := str + vr.VPWideChar;
      vtAnsiString:
        str := str + string(RawByteString(vr.VAnsiString));
      vtCurrency:
        str := str + FloatToStr(vr.VCurrency^);
      vtVariant:
        str := str + vr.VVariant^;
      vtInterface:
        str := str + 'interface';
      vtUnicodeString:
        str := str + u16string(vr.VUnicodeString);
      vtInt64:
        str := str + IntToStr(vr.VInt64^);
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
  if IsConsole then
    WritelnException(e)
  else
    OutputDebugException(e);
  Result := True;
end;

function DbgOutputException(const func: string; e: Exception): Boolean;
begin
  if IsConsole then
    WritelnException(func, e)
  else
    OutputDebugException(func, e);
  Result := True;
end;

procedure MyOutputDebugString(const s: u16string);
begin
  OutputDebugStringW(PWideChar(s));
end;

procedure MyOutputDebugString(const s: RawByteString);
begin
  OutputDebugStringA(PAnsiChar(s));
end;

function RBStrDbgOutput(const msg: RawByteString): Boolean;
begin
  if IsConsole then
    Writeln(msg)
  else
    OutputDebugStringA(PAnsiChar(msg));
  Result := True;
end;

function UStrDbgOutput(const msg: u16string): Boolean;
begin
  if IsConsole then
    Writeln(msg)
  else
    OutputDebugStringW(PWideChar(msg));
  Result := True;
end;

function DbgOutput(const msg: u16string): Boolean;
begin
  if IsConsole then
    Writeln(msg)
  else
    OutputDebugStringW(PWideChar(msg));
  Result := True;
end;

function DbgOutput(const msg: RawByteString): Boolean;
begin
  if IsConsole then
    Writeln(msg)
  else
    OutputDebugStringA(PAnsiChar(msg));
  Result := True;
end;

function DbgOutput(const args: array of const ; const separator: string = #32;
  LineFeed: Boolean = True): Boolean; overload;
begin
  if IsConsole then
    PrintArray(args, separator, LineFeed)
  else
    OutputDebugArray(args, separator, LineFeed);
  Result := True;
end;

function DbgOutputFmtA(const fmt: RawByteString; const args: array of const ): Boolean;
begin
  if IsConsole then
    Writeln(RBStrFormat(fmt, args))
  else
    OutputDebugStringA(PAnsiChar(RBStrFormat(fmt, args)));
  Result := True;
end;

function DbgOutputFmtW(const fmt: u16string; const args: array of const ): Boolean;
begin
  if IsConsole then
    Writeln(WideFormat(fmt, args))
  else
    OutputDebugStringW(PWideChar(WideFormat(fmt, args)));
  Result := True;
end;

function DbgOutputFmt(const fmt: string; const args: array of const ): Boolean;
begin
  if IsConsole then
    Writeln(Format(fmt, args))
  else
    OutputDebugString(PChar(Format(fmt, args)));
  Result := True;
end;

function AsciiCompare(s1: PAnsiChar; len1: Integer; s2: PAnsiChar; len2: Integer): Integer;
var
  i, len: Integer;
begin
  Result := 0;

  if len1 > len2 then
    len := len2
  else
    len := len1;

  for i := 0 to len - 1 do
  begin
    Result := Ord(s1[i]) - Ord(s2[i]);
    if Result <> 0 then
      Break;
  end;

  if Result = 0 then
    Result := len1 - len2;
end;

function RBStrAsciiCompare(const s1, s2: RawByteString): Integer;
begin
  Result := AsciiCompare(PAnsiChar(s1), length(s1), PAnsiChar(s2), length(s2));
end;

function AsciiICompare(s1: PAnsiChar; len1: Integer; s2: PAnsiChar; len2: Integer): Integer;
var
  i, len: Integer;
  c1, c2: AnsiChar;
begin
  Result := 0;

  if len1 > len2 then
    len := len2
  else
    len := len1;

  for i := 0 to len - 1 do
  begin
    c1 := s1[i];
    c2 := s2[i];

    if c1 in ['A' .. 'Z'] then
      Inc(c1, 32);
    if c2 in ['A' .. 'Z'] then
      Inc(c2, 32);
    Result := Ord(c1) - Ord(c2);
    if Result <> 0 then
      Break;
  end;

  if Result = 0 then
    Result := len1 - len2;
end;

function AsciiICompare(const s1, s2: RawByteString): Integer; overload;
begin
  Result := AsciiICompare(PAnsiChar(s1), length(s1), PAnsiChar(s2), length(s2));
end;

function RBStrAsciiICompare(const s1, s2: RawByteString): Integer;
begin
  Result := AsciiICompare(PAnsiChar(s1), length(s1), PAnsiChar(s2), length(s2));
end;

function AsciiCompare(s1: PWideChar; len1: Integer; s2: PWideChar; len2: Integer): Integer;
var
  i, len: Integer;
begin
  Result := 0;

  if len1 > len2 then
    len := len2
  else
    len := len1;

  for i := 0 to len - 1 do
  begin
    Result := Ord(s1[i]) - Ord(s2[i]);
    if Result <> 0 then
      Break;
  end;

  if Result = 0 then
    Result := len1 - len2;
end;

function UStrAsciiCompare(const s1, s2: u16string): Integer;
begin
  Result := AsciiCompare(PWideChar(s1), length(s1), PWideChar(s2), length(s2));
end;

function AsciiICompare(s1: PWideChar; len1: Integer; s2: PWideChar; len2: Integer): Integer;
var
  i, len: Integer;
  c1, c2: WideChar;
begin
  Result := 0;

  if len1 > len2 then
    len := len2
  else
    len := len1;

  for i := 0 to len - 1 do
  begin
    c1 := s1[i];
    c2 := s2[i];

    if (c1 >= 'A') and (c1 <= 'Z') then
      Inc(c1, 32);
    if (c2 >= 'A') and (c2 <= 'Z') then
      Inc(c2, 32);
    Result := Ord(c1) - Ord(c2);
    if Result <> 0 then
      Break;
  end;

  if Result = 0 then
    Result := len1 - len2;
end;

function UStrAsciiICompare(const s1, s2: u16string): Integer;
begin
  Result := AsciiICompare(PWideChar(s1), length(s1), PWideChar(s2), length(s2));
end;

function AsciiBuf2UStr(buf: PAnsiChar; len: Integer): u16string;
var
  i: Integer;
begin
  if len = -1 then
    len := {$IF CompilerVersion > 22} AnsiStrings.{$IFEND} StrLen(buf);

  SetLength(Result, len);

  for i := 0 to len - 1 do
    PWideChar(Result)[i] := WideChar(buf[i]);
end;

function Ascii2UStr(const s: RawByteString): u16string;
var
  i, len: Integer;
begin
  len := length(s);
  SetLength(Result, len);

  for i := 0 to len - 1 do
    PWideChar(Result)[i] := WideChar(PAnsiChar(s)[i]);
end;

function BufToUnicodeTest(src: PAnsiChar; srcLen: Integer; CodePage: Integer): Integer;
begin
  Result := MultiByteToWideChar(CodePage, 0, src, srcLen, nil, 0);
  if srcLen < 0 then
    Dec(Result);
end;

function CheckCodePage(src: PAnsiChar; srcLen: Integer; CodePage: Integer; out dstLen: Integer): Boolean;
begin
  dstLen := MultiByteToWideChar(CodePage, MB_ERR_INVALID_CHARS, src, srcLen, nil, 0);

  Result := (dstLen > 0) or (GetLastError <> ERROR_NO_UNICODE_TRANSLATION);

  if (dstLen > 0) and (srcLen < 0) then
    Dec(dstLen);
end;

function BufToUnicodeTestEx(src: PAnsiChar; srcLen: Integer; const CodePages: array of Integer;
  out RealCodePage: Integer): Integer;
var
  i, dstLen: Integer;
begin
  Result := -1;

  for i := Low(CodePages) to High(CodePages) do
  begin
    dstLen := MultiByteToWideChar(CodePages[i], MB_ERR_INVALID_CHARS, src, srcLen, nil, 0);

    if dstLen > 0 then
    begin
      if srcLen < 0 then
        Dec(dstLen);
      RealCodePage := CodePages[i];
      Result := dstLen;
      Break;
    end;
  end;
end;

function BufToUnicode(src: PAnsiChar; srcLen: Integer; dst: PWideChar; dstLen, CodePage: Integer): Integer; overload;
begin
  Result := MultiByteToWideChar(CodePage, 0, src, srcLen, dst, dstLen);
end;

function BufToUnicode(src: PAnsiChar; srcLen: Integer; CodePage: Integer): u16string; overload;
var
  L: Integer;
begin
  L := BufToUnicodeTest(src, srcLen, CodePage);
  SetLength(Result, L);
  MultiByteToWideChar(CodePage, 0, src, srcLen, PWideChar(Result), L);
end;

function BufToBSTR(src: PAnsiChar; srcLen: Integer; CodePage: Integer): WideString;
var
  L: Integer;
begin
  L := BufToUnicodeTest(src, srcLen, CodePage);
  SetLength(Result, L);
  MultiByteToWideChar(CodePage, 0, src, srcLen, PWideChar(Result), L);
end;

function BufToUnicodeEx(src: PAnsiChar; srcLen: Integer; dst: PWideChar; dstLen: Integer;
  const CodePages: array of Integer): Integer;
var
  CodePage, L: Integer;
begin
  L := BufToUnicodeTestEx(src, srcLen, CodePages, CodePage);

  if (L <= 0) or (L > dstLen) then
    Result := 0
  else
    Result := MultiByteToWideChar(CodePage, 0, src, srcLen, dst, dstLen);
end;

function BufToUnicodeEx(src: PAnsiChar; srcLen: Integer; const CodePages: array of Integer): u16string;
var
  CodePage, L: Integer;
begin
  L := BufToUnicodeTestEx(src, srcLen, CodePages, CodePage);

  if L <= 0 then
    Result := ''
  else
  begin
    SetLength(Result, L);
    MultiByteToWideChar(CodePage, 0, src, srcLen, PWideChar(Result), L);
  end;
end;

function AnsiStrAssignWideChar(dst: PAnsiChar; dstLen: Integer; c: WideChar; CodePage: Integer): Integer;
begin
  Result := WideCharToMultiByte(CodePage, 0, @c, 1, dst, dstLen, nil, nil);
end;

function BufToMultiByteTest(src: PWideChar; srcLen: Integer; CodePage: Integer): Integer;
begin
  Result := WideCharToMultiByte(CodePage, 0, src, srcLen, nil, 0, nil, nil);
  if srcLen < 0 then
    Dec(Result);
end;

function BufToMultiByte(src: PWideChar; srcLen: Integer; dst: PAnsiChar; dstLen, CodePage: Integer): Integer;
begin
  Result := WideCharToMultiByte(CodePage, 0, src, srcLen, dst, dstLen, nil, nil);
end;

function BufToMultiByte(src: PWideChar; srcLen: Integer; CodePage: Integer): RawByteString;
var
  L: Integer;
begin
  L := BufToMultiByteTest(src, srcLen, CodePage);
  SetLength(Result, L);
  BufToMultiByte(src, srcLen, PAnsiChar(Result), L, CodePage);
end;

function UStrToMultiByte(const src: u16string; dst: PAnsiChar; dstLen, CodePage: Integer): Integer;
begin
  Result := WideCharToMultiByte(CodePage, 0, PWideChar(src), length(src), dst, dstLen, nil, nil);
end;

function UStrToMultiByte(const src: u16string; CodePage: Integer): RawByteString;
var
  L: Integer;
begin
  L := BufToMultiByteTest(PWideChar(src), length(src), CodePage);
  SetLength(Result, L);
  BufToMultiByte(PWideChar(src), length(src), PAnsiChar(Result), L, CodePage);
end;

function RBStrToUnicode(const src: RawByteString; dst: PWideChar; dstLen, CodePage: Integer): Integer; overload;
begin
  Result := MultiByteToWideChar(CodePage, 0, PAnsiChar(src), length(src), dst, dstLen);
end;

function RBStrToUnicode(const src: RawByteString; CodePage: Integer): u16string; overload;
var
  L: Integer;
begin
  L := BufToUnicodeTest(PAnsiChar(src), length(src), CodePage);
  SetLength(Result, L);
  MultiByteToWideChar(CodePage, 0, PAnsiChar(src), length(src), PWideChar(Result), L);
end;

function RBStrToUnicodeEx(const src: RawByteString; dst: PWideChar; dstLen: Integer;
  const CodePages: array of Integer): Integer;
var
  CodePage, L: Integer;
begin
  L := BufToUnicodeTestEx(PAnsiChar(src), length(src), CodePages, CodePage);

  if (L <= 0) or (L > dstLen) then
    Result := 0
  else
    Result := MultiByteToWideChar(CodePage, 0, PAnsiChar(src), length(src), dst, dstLen);
end;

function RBStrToUnicodeEx(const src: RawByteString; const CodePages: array of Integer): u16string;
var
  CodePage, L: Integer;
begin
  L := BufToUnicodeTestEx(PAnsiChar(src), length(src), CodePages, CodePage);

  if L <= 0 then
    Result := ''
  else
  begin
    SetLength(Result, L);
    MultiByteToWideChar(CodePage, 0, PAnsiChar(src), length(src), PWideChar(Result), L);
  end;
end;

function ReplaceIfNotEqual(var dst: RawByteString; const src: RawByteString; pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then
    Result := False
  else
  begin
    dst := src;
    if Assigned(pEStayNETrue) then
      pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: u16string; const src: u16string; pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then
    Result := False
  else
  begin
    dst := src;
    if Assigned(pEStayNETrue) then
      pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: Integer; const src: Integer; pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then
    Result := False
  else
  begin
    dst := src;
    if Assigned(pEStayNETrue) then
      pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: Int64; const src: Int64; pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then
    Result := False
  else
  begin
    dst := src;
    if Assigned(pEStayNETrue) then
      pEStayNETrue^ := True;
    Result := True;
  end;
end;

function ReplaceIfNotEqual(var dst: Double; const src: Double; pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then
    Result := False
  else
  begin
    dst := src;
    if Assigned(pEStayNETrue) then
      pEStayNETrue^ := True;
    Result := True;
  end;
end;

(*
function ReplaceIfNotEqual(var dst: Real; const src: Real; pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then
    Result := False
  else
  begin
    dst := src;
    if Assigned(pEStayNETrue) then
      pEStayNETrue^ := True;
    Result := True;
  end;
end;
*)

function ReplaceIfNotEqual(var dst: Boolean; const src: Boolean; pEStayNETrue: PBoolean): Boolean;
begin
  if dst = src then
    Result := False
  else
  begin
    dst := src;
    if Assigned(pEStayNETrue) then
      pEStayNETrue^ := True;
    Result := True;
  end;
end;

function JsonEscape(const s: u16string): u16string;
begin
  Result := UStrReplace(s, '\', '\\', [rfReplaceAll]);
  Result := UStrReplace(Result, '/', '\/', [rfReplaceAll]);
  Result := UStrReplace(Result, '''', '\''', [rfReplaceAll]);
  Result := UStrReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := UStrReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := UStrReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := UStrReplace(Result, #9, '\t', [rfReplaceAll]);
  Result := UStrReplace(Result, #0, '\0x00', [rfReplaceAll]);
end;

function JsonEscape(const s: WideString): WideString;
begin
  Result := BStrReplace(s, '\', '\\', [rfReplaceAll]);
  Result := BStrReplace(Result, '/', '\/', [rfReplaceAll]);
  Result := BStrReplace(Result, '''', '\''', [rfReplaceAll]);
  Result := BStrReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := BStrReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := BStrReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := BStrReplace(Result, #9, '\t', [rfReplaceAll]);
  Result := BStrReplace(Result, #0, '\0x00', [rfReplaceAll]);
end;

function JsonEscape(const s: RawByteString): RawByteString;
begin
  Result := RBStrReplace(s, '\', '\\', [rfReplaceAll]);
  Result := RBStrReplace(Result, '/', '\/', [rfReplaceAll]);
  Result := RBStrReplace(Result, '''', '\''', [rfReplaceAll]);
  Result := RBStrReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := RBStrReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := RBStrReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := RBStrReplace(Result, #9, '\t', [rfReplaceAll]);
  Result := RBStrReplace(Result, #0, '\0x00', [rfReplaceAll]);
end;

function RBStrRepeat(const s: RawByteString; RepeatCount: Integer): RawByteString;
var
  i, L: Integer;
begin
  if (RepeatCount = 0) or (s = '') then
    Result := ''
  else if RepeatCount = 1 then
    Result := s
  else
  begin
    L := length(s);
    SetLength(Result, L * RepeatCount);

    for i := 0 to RepeatCount - 1 do
      Move(Pointer(s)^, PAnsiChar(Result)[i * L], L);
  end;
end;

function UStrRepeat(const s: u16string; RepeatCount: Integer): u16string;
var
  i, L: Integer;
begin
  if (RepeatCount = 0) or (s = '') then
    Result := ''
  else if RepeatCount = 1 then
    Result := s
  else
  begin
    L := length(s);
    SetLength(Result, L * RepeatCount);

    for i := 0 to RepeatCount - 1 do
      Move(Pointer(s)^, PWideChar(Result)[i * L], L * 2);
  end;
end;

procedure StrZeroAndFree(var s: string);
begin
  if s <> '' then
  begin
    FillChar(Pointer(s)^, length(s) * SizeOf(s[1]), 0);
    s := '';
  end;
end;

procedure ZeroStringA(s: PAnsiChar);
begin
  if Assigned(s) then
    while s^ <> #0 do
      s^ := #0;
end;

procedure RBStrZero(const s: RawByteString);
begin
  if s <> '' then
    FillChar(Pointer(s)^, length(s) * SizeOf(s[1]), 0);
end;

procedure RBStrZeroAndFree(var s: RawByteString);
begin
  if s <> '' then
  begin
    FillChar(Pointer(s)^, length(s) * SizeOf(s[1]), 0);
    s := '';
  end;
end;

procedure ZeroStringW(s: PWideChar);
begin
  if Assigned(s) then
    while s^ <> #0 do
      s^ := #0;
end;

procedure UStrZero(const s: u16string);
begin
  if s <> '' then
    FillChar(Pointer(s)^, length(s) * SizeOf(s[1]), 0);
end;

procedure UStrZeroAndFree(var s: u16string);
begin
  if s <> '' then
  begin
    FillChar(Pointer(s)^, length(s) * SizeOf(s[1]), 0);
    s := '';
  end;
end;

function GetStringLengthFast(s: Pointer): Integer;
begin
  Result := (PInt32(s) - 1)^;
end;

(* copy from Delphi 2010 RTL *)
function StrLenA(const str: PAnsiChar): Integer;
asm
  { Check the first byte }
  cmp byte ptr [eax], 0
  je @ZeroLength
  { Get the negative of the string start in edx }
  mov edx, eax
  neg edx
  { Word align }
  add eax, 1
  and eax, -2
@ScanLoop:
  mov cx, [eax]
  add eax, 2
  test cl, ch
  jnz @ScanLoop
  test cl, cl
  jz @ReturnLess2
  test ch, ch
  jnz @ScanLoop
  lea eax, [eax + edx - 1]
  ret
@ReturnLess2:
  lea eax, [eax + edx - 2]
  ret
@ZeroLength:
  xor eax, eax
end;

(* copy from Delphi 2010 RTL *)
function StrLenW(s: PWideChar): Integer;
asm
  { Check the first byte }
  cmp word ptr [eax], 0
  je @ZeroLength
  { Get the negative of the string start in edx }
  mov edx, eax
  neg edx
@ScanLoop:
  mov cx, word ptr [eax]
  add eax, 2
  test cx, cx
  jnz @ScanLoop
  lea eax, [eax + edx - 2]
  shr eax, 1
  ret
@ZeroLength:
  xor eax, eax
end;

function UStrLen(const s: u16string): Integer;
begin
  Result := System.Length(s);
end;

function BStrLen(const s: WideString): Integer;
begin
  Result := System.Length(s);
end;

function RBSOf(ch: AnsiChar; len: Integer): RawByteString;
var
  i: Integer;
begin
  SetLength(Result, len);

  for i := 0 to len - 1 do
    PAnsiChar(Result)[i] := ch;
end;

function UStrOf(ch: WideChar; len: Integer): u16string;
var
  i: Integer;
begin
  SetLength(Result, len);

  for i := 0 to len - 1 do
    PWideChar(Result)[i] := ch;
end;

function StrOf(buf: PChar; len: Integer): string;
begin
  SetString(Result, buf, len);
end;

function WCharArrayStrLen(const chars: array of WideChar): Integer;
var
  i: Integer;
begin
  Result := length(chars);

  for i := Low(chars) to High(chars) do
  begin
    if chars[i] = #0 then
    begin
      Result := i - Low(chars);
      Break;
    end;
  end;
end;

function ByteArrayStrLen(const chars: array of AnsiChar): Integer;
var
  i: Integer;
begin
  Result := length(chars);

  for i := Low(chars) to High(chars) do
  begin
    if chars[i] = #0 then
    begin
      Result := i - Low(chars);
      Break;
    end;
  end;
end;

function Array2WStr(const chars: array of WideChar): WideString;
var
  L: Integer;
begin
  L := WCharArrayStrLen(chars);

  SetLength(Result, L);

  Move(chars[ Low(chars)], Pointer(Result)^, L shl 1);
end;

function Array2UStr(const chars: array of WideChar): u16string;
var
  L: Integer;
begin
  L := WCharArrayStrLen(chars);

  SetLength(Result, L);

  Move(chars[ Low(chars)], Pointer(Result)^, L shl 1);
end;

procedure WStr2Array(var dst: array of WideChar; const src: WideString);
var
  L: Integer;
begin
  L := length(src);

  if L > length(dst) then
    L := length(dst);

  Move(Pointer(src)^, dst[ Low(dst)], L shl 1);

  if L < length(dst) then
    dst[ Low(dst) + L] := #0;
end;

procedure UStr2Array(var dst: array of WideChar; const src: u16string);
var
  L: Integer;
begin
  L := length(src);

  if L > length(dst) then
    L := length(dst);

  Move(Pointer(src)^, dst[ Low(dst)], L shl 1);

  if L < length(dst) then
    dst[ Low(dst) + L] := #0;
end;

function ByteArray2Str(const chars: array of AnsiChar): RawByteString;
var
  L: Integer;
begin
  L := ByteArrayStrLen(chars);
  SetLength(Result, L);
  Move(chars[ Low(chars)], Pointer(Result)^, L);
end;

function ByteArray2UStr(const chars: array of AnsiChar): u16string;
var
  i, L: Integer;
begin
  L := ByteArrayStrLen(chars);
  SetLength(Result, L);
  for i := 0 to L - 1 do
    PWideChar(Result)[i] := WideChar(chars[i]);
end;

procedure RawByteStr2Array(var dst: array of AnsiChar; const src: RawByteString);
var
  L: Integer;
begin
  L := length(src);

  if L > length(dst) then
    L := length(dst);

  Move(Pointer(src)^, dst[ Low(dst)], L);

  if L < length(dst) then
    dst[ Low(dst) + L] := #0;
end;

function UStrPas(const str: PWideChar): u16string;
begin
  Result := str;
end;

function WCharArrayCat(const arr1, arr2: array of WideChar): u16string;
var
  L1, L2: Integer;
begin
  L1 := WCharArrayStrLen(arr1);
  L2 := WCharArrayStrLen(arr2);

  SetLength(Result, L1 + L2);

  if L1 > 0 then
    Move(arr1[0], Pointer(Result)^, L1 shl 1);

  if L2 > 0 then
    Move(arr2[0], PWideChar(Result)[L1], L2 shl 1);
end;

function WCharArrayCat(const arr1, arr2, arr3: array of WideChar): u16string;
var
  L1, L2, L3: Integer;
begin
  L1 := WCharArrayStrLen(arr1);
  L2 := WCharArrayStrLen(arr2);
  L3 := WCharArrayStrLen(arr3);

  SetLength(Result, L1 + L2 + L3);

  if L1 > 0 then
    Move(arr1[0], Pointer(Result)^, L1 shl 1);

  if L2 > 0 then
    Move(arr2[0], PWideChar(Result)[L1], L2 shl 1);

  if L3 > 0 then
    Move(arr3[0], PWideChar(Result)[L1 + L2], L3 shl 1);
end;

function WCharArrayCat(const arr1, arr2, arr3, arr4: array of WideChar): u16string;
var
  L1, L2, L3, L4: Integer;
begin
  L1 := WCharArrayStrLen(arr1);
  L2 := WCharArrayStrLen(arr2);
  L3 := WCharArrayStrLen(arr3);
  L4 := WCharArrayStrLen(arr4);

  SetLength(Result, L1 + L2 + L3 + L4);

  if L1 > 0 then
    Move(arr1[0], Pointer(Result)^, L1 shl 1);

  if L2 > 0 then
    Move(arr2[0], PWideChar(Result)[L1], L2 shl 1);

  if L3 > 0 then
    Move(arr3[0], PWideChar(Result)[L1 + L2], L3 shl 1);

  if L4 > 0 then
    Move(arr4[0], PWideChar(Result)[L1 + L2 + L3], L4 shl 1);
end;

function WCharArrayCat(const arr1, arr2, arr3, arr4, arr5: array of WideChar): u16string;
var
  L1, L2, L3, L4, L5: Integer;
begin
  L1 := WCharArrayStrLen(arr1);
  L2 := WCharArrayStrLen(arr2);
  L3 := WCharArrayStrLen(arr3);
  L4 := WCharArrayStrLen(arr4);
  L5 := WCharArrayStrLen(arr5);

  SetLength(Result, L1 + L2 + L3 + L4 + L5);

  if L1 > 0 then
    Move(arr1[0], Pointer(Result)^, L1 shl 1);

  if L2 > 0 then
    Move(arr2[0], PWideChar(Result)[L1], L2 shl 1);

  if L3 > 0 then
    Move(arr3[0], PWideChar(Result)[L1 + L2], L3 shl 1);

  if L4 > 0 then
    Move(arr4[0], PWideChar(Result)[L1 + L2 + L3], L4 shl 1);

  if L5 > 0 then
    Move(arr5[0], PWideChar(Result)[L1 + L2 + L3 + L4], L5 shl 1);
end;

function RawByteStrInsertAfter(const src, prefix, ToInsert: AnsiString; first: Integer = 1;
  last: Integer = 0): AnsiString;
var
  p: Integer;
begin
  Result := src;

  if (last > length(src)) or (last <= 0) then
    last := length(src);

  if (first <= 0) or (first >= last) then
    Exit;

  p := RBStrPos(prefix, src, first, last);

  if p <= 0 then
    Exit;

  Result := Copy(src, 1, p + length(prefix) - 1) + ToInsert + Copy(src, p + length(prefix),
    length(src) + 1 - p - length(prefix));
end;

function UStrInsertAfter(const src, prefix, ToInsert: u16string; first: Integer = 1;
  last: Integer = 0): u16string;
var
  p: Integer;
begin
  Result := src;

  if (last > length(src)) or (last <= 0) then
    last := length(src);

  if (first <= 0) or (first >= last) then
    Exit;

  p := UStrPos(prefix, src, first, last);

  if p <= 0 then
    Exit;

  Result := Copy(src, 1, p + length(prefix) - 1) + ToInsert + Copy(src, p + length(prefix),
    length(src) + 1 - p - length(prefix));
end;

function RegisterCOMComponet(pFileName: PChar): Boolean;
var
  hLib: hModule;
  RegProc: function(): BOOL;
stdcall;
begin
  Result := False;
  hLib := LoadLibrary(pFileName);

  if hLib = 0 then
    Exit;

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
  for i := length(url) downto 1 do
  begin
    if url[i] = '/' then
    begin
      Result := Copy(url, i + 1, length(url) - i);
      Break;
    end;
  end;
end;

function UrlExtractFileExt(const url: string): string;
var
  i, L: Integer;
begin
  Result := '';
  L := length(url);
  for i := L downto 1 do
  begin
    if url[i] = '/' then
      Break;

    if url[i] = '.' then
    begin
      Result := Copy(url, i + 1, length(url) - i);
      Break;
    end;
  end;
end;

function IsPictureExt(const ext: string): Boolean;
begin
  Result := SameText(ext, 'jpg') or SameText(ext, 'jpeg') or SameText(ext, 'gif') or SameText(ext, 'png') or SameText
    (ext, 'tiff') or SameText(ext, 'bmp');
end;

function HttpExpandUrl(const url, schema, host: u16string): u16string;
begin
  if url = '' then
    Result := ''
  else if url[1] = ':' then
  begin
    if schema = '' then
      Result := 'http' + url
    else
      Result := schema + url;
  end
  else if url[1] = '/' then
  begin
    if (length(url) > 1) and (url[2] = '/') then
    begin
      if schema = '' then
        Result := 'http:' + url
      else
        Result := schema + ':' + url;
    end
    else
    begin
      if schema = '' then
        Result := 'http://' + host + url
      else
        Result := schema + '://' + host + url;
    end;
  end
  else
    Result := url;
end;

function HttpExpandUrl(const url, schema, host: RawByteString): RawByteString; overload;
begin
  if url = '' then
    Result := ''
  else if url[1] = ':' then
  begin
    if schema = '' then
      Result := 'http' + url
    else
      Result := schema + url;
  end
  else if url[1] = '/' then
  begin
    if (length(url) > 1) and (url[2] = '/') then
    begin
      if schema = '' then
        Result := 'http:' + url
      else
        Result := schema + ':' + url;
    end
    else
    begin
      if schema = '' then
        Result := 'http://' + host + url
      else
        Result := schema + '://' + host + url;
    end;
  end
  else
    Result := url;
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
    if (Sp^ in ['0' .. '9', 'A' .. 'Z', 'a' .. 'z']) then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    found := False;

    for i := 1 to length(non_conversions) do
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
    if (Sp^ in ['0' .. '9', 'A' .. 'Z', 'a' .. 'z']) then
    begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
      Continue;
    end;

    found := False;

    for i := 1 to length(non_conversions) do
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
    Rp[2] := HEX_SYMBOLS[PByte(Sp)^ and $0F + 1];
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

function HttpEncodeBufTest(const buf; bufLen: Integer; const non_conversions: RawByteString): Integer;
const
  HEX_SYMBOLS: RawByteString = '0123456789ABCDEF';
var
  Sp, buf_end: PAnsiChar;
  found: Boolean;
  i: Integer;
begin
  Result := 0;
  Sp := PAnsiChar(@buf);
  buf_end := Sp + bufLen;

  while Sp < buf_end do
  begin
    if (Sp^ in ['0' .. '9', 'A' .. 'Z', 'a' .. 'z']) then
    begin
      Inc(Result);
      Inc(Sp);
      Continue;
    end;

    found := False;

    for i := 1 to length(non_conversions) do
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

function HttpEncodeBuf2Buf(const buf; bufLen: Integer; dst: PAnsiChar; const non_conversions: RawByteString): Integer;
const
  HEX_SYMBOLS: RawByteString = '0123456789ABCDEF';
var
  Sp, Rp, buf_end: PAnsiChar;
  found: Boolean;
  i: Integer;
begin
  Sp := PAnsiChar(@buf);
  buf_end := Sp + bufLen;
  Rp := dst;

  while Sp < buf_end do
  begin
    if (Sp^ in ['0' .. '9', 'A' .. 'Z', 'a' .. 'z']) then
    begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
      Continue;
    end;

    found := False;

    for i := 1 to length(non_conversions) do
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
    Rp[2] := HEX_SYMBOLS[PByte(Sp)^ and $0F + 1];
    Inc(Rp, 3);
    Inc(Sp);
  end;

  Result := Rp - dst;
end;

function HttpEncodeBuf(const src; srcLen: Integer; const non_conversions: RawByteString): RawByteString;
begin
  SetLength(Result, srcLen * 3);

  SetLength(Result, HttpEncodeBuf2Buf(src, srcLen, PAnsiChar(Result), non_conversions));
end;

function HttpEncode(const src, non_conversions: RawByteString): RawByteString;
begin
  SetLength(Result, length(src) * 3);

  SetLength(Result, HttpEncodeBuf2Buf(Pointer(src)^, length(src), PAnsiChar(Result), non_conversions));
end;

function HttpDecodeBufTest(const buf; bufLen: Integer; invalid: PPAnsiChar): Integer;
var
  Sp, Cp, buf_end: PAnsiChar;
begin
  Sp := PAnsiChar(@buf);
  buf_end := Sp + bufLen;
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;

  while Sp < buf_end do
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
        if Assigned(invalid) then
          invalid^ := Sp - 1;
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
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      if not(((Cp^ >= '0') and (Cp^ <= '9')) or ((Cp^ >= 'A') and (Cp^ <= 'Z')) or ((Cp^ >= 'a') and (Cp^ <= 'z'))) then
      begin
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      if not(((Sp^ >= '0') and (Sp^ <= '9')) or ((Sp^ >= 'A') and (Sp^ <= 'Z')) or ((Sp^ >= 'a') and (Sp^ <= 'z'))) then
      begin
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      Inc(Sp);
      Inc(Result);
    end
    else
    begin
      Inc(Result);
      Inc(Sp);
    end;
  end;
end;

function HttpDecodeStrTest(const str: RawByteString; invalid: PPAnsiChar = nil): Integer;
begin
  Result := HttpDecodeBufTest(Pointer(str)^, length(str), invalid);
end;
{$WARNINGS OFF}

function HttpDecodeBuf2Buf(const buf; bufLen: Integer; dst: PAnsiChar; invalid: PPAnsiChar): Integer;
var
  Sp, Rp, Cp, buf_end: PAnsiChar;
  v: Integer;
begin
  Sp := PAnsiChar(@buf);
  buf_end := Sp + bufLen;
  Rp := dst;

  if Assigned(invalid) then
    invalid^ := nil;

  while Sp < buf_end do
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
        if Assigned(invalid) then
          invalid^ := Sp - 1;
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
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      if (Cp^ >= '0') and (Cp^ <= '9') then
        v := (Ord(Cp^) - 48) shl 4
      else if (Cp^ >= 'A') and (Cp^ <= 'Z') then
        v := (Ord(Cp^) - 55) shl 4
      else if (Cp^ >= 'a') and (Cp^ <= 'z') then
        v := (Ord(Cp^) - 87) shl 4
      else
      begin
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      if (Sp^ >= '0') and (Sp^ <= '9') then
        Inc(v, Ord(Sp^) - 48)
      else if (Sp^ >= 'A') and (Sp^ <= 'Z') then
        Inc(v, Ord(Sp^) - 55)
      else if (Sp^ >= 'a') and (Sp^ <= 'z') then
        Inc(v, Ord(Sp^) - 87)
      else
      begin
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      PByte(Rp)^ := v;
      Inc(Sp);
      Inc(Rp);
    end
    else
    begin
      Rp^ := Sp^;
      Inc(Rp);
      Inc(Sp);
    end;
  end;

  Result := Rp - dst;
end;
{$WARNINGS ON}

function HttpDecodeBuf(const buf; bufLen: Integer; invalid: PPAnsiChar): RawByteString;
var
  _invalid: PAnsiChar;
  L: Integer;
begin
  SetLength(Result, bufLen);
  L := HttpDecodeBuf2Buf(buf, bufLen, PAnsiChar(Result), @_invalid);

  if Assigned(invalid) then
    invalid^ := _invalid;

  if Assigned(_invalid) then
    Result := ''
  else
    SetLength(Result, L);
end;

function HttpDecode(const src: RawByteString; invalid: PPAnsiChar): RawByteString;
begin
  Result := HttpDecodeBuf(Pointer(src)^, length(src));
end;

function HttpDecodeCStrTest(src: PAnsiChar; invalid: PPAnsiChar): Integer;
var
  Sp, Cp: PAnsiChar;
begin
  Sp := PAnsiChar(src);
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;

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
        if Assigned(invalid) then
          invalid^ := Sp - 1;
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
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      if not(((Cp^ >= '0') and (Cp^ <= '9')) or ((Cp^ >= 'A') and (Cp^ <= 'Z')) or ((Cp^ >= 'a') and (Cp^ <= 'z'))) then
      begin
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      if not(((Sp^ >= '0') and (Sp^ <= '9')) or ((Sp^ >= 'A') and (Sp^ <= 'Z')) or ((Sp^ >= 'a') and (Sp^ <= 'z'))) then
      begin
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      Inc(Sp);
      Inc(Result);
    end
    else
    begin
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

  if Assigned(invalid) then
    invalid^ := nil;

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
        if Assigned(invalid) then
          invalid^ := Sp - 1;
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
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      if (Cp^ >= '0') and (Cp^ <= '9') then
        v := (Ord(Cp^) - 48) shl 4
      else if (Cp^ >= 'A') and (Cp^ <= 'Z') then
        v := (Ord(Cp^) - 55) shl 4
      else if (Cp^ >= 'a') and (Cp^ <= 'z') then
        v := (Ord(Cp^) - 87) shl 4
      else
      begin
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      if (Sp^ >= '0') and (Sp^ <= '9') then
        Inc(v, Ord(Sp^) - 48)
      else if (Cp^ >= 'A') and (Cp^ <= 'Z') then
        Inc(v, Ord(Sp^) - 55)
      else if (Cp^ >= 'a') and (Cp^ <= 'z') then
        Inc(v, Ord(Sp^) - 87)
      else
      begin
        if Assigned(invalid) then
          invalid^ := Sp - 2;
        Break;
      end;

      PByte(Rp)^ := v;
      Inc(Sp);
      Inc(Rp);
    end
    else
    begin
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

  if Assigned(invalid) then
    invalid^ := _invalid;

  if Assigned(_invalid) then
    Result := ''
  else
  begin
    SetLength(Result, L);
    HttpDecodeCStr2Buf(str, PAnsiChar(Result), nil);
  end;
end;

function encodeURIComponent(const s: u16string): RawByteString;
begin
  Result := HttpEncode(UTF8Encode(s));
end;

function encodeURIComponent(const s: RawByteString): RawByteString;
begin
  Result := HttpEncode(s);
end;

function decodeURIComponent(const s: RawByteString): u16string;
begin
  Result := WinAPI_UTF8Decode(HttpDecode(s));
end;

function decodeURIComponentGBK(_Text: PAnsiChar; _Len: Integer): u16string;
begin
  Result := RBStrToUnicode(HttpDecodeBuf(_Text^, _Len), 936);
end;

function encodeURIComponentGBK(const s: u16string): RawByteString;
begin
  Result := HttpEncode(UStrToMultiByte(s, 936));
end;

{$WARNINGS ON}

function UrlExtractPathA(const url: RawByteString): RawByteString;
var
  p, i: Integer;
begin
  Result := '';
  p := RBStrPos('://', url);

  if p <= 0 then
    p := 1
  else
    Inc(p, 3);

  for i := p to length(url) do
  begin
    if url[i] = '/' then
    begin
      Result := Copy(url, i, length(url) + 1 - i);
      Break;
    end;
  end;
end;

function UrlExtractHost(const url: u16string): u16string;
var
  L, P1, P2: Integer;
begin
  Result := '';
  L := Length(url);
  if L = 0 then Exit;
  if (url[1]) = '/' then Exit;
  P1 := UStrPos('//', url);
  if P1 > 0 then Inc(P1, 2)
  else P1 := 1;

  P2 := P1;
  while (P2<=L) and (url[P2] <> '/') do Inc(P2);

  if (P2-P1=L) then Result := url
  else Result := Copy(url, P1, P2-P1);
end;

function UrlExtractPathW(const url: u16string): u16string;
var
  p, i: Integer;
begin
  Result := '';
  p := UStrPos('://', url);

  if p <= 0 then
    p := 1
  else
    Inc(p, 3);

  for i := p to length(url) do
  begin
    if url[i] = '/' then
    begin
      Result := Copy(url, i, length(url) + 1 - i);
      Break;
    end;
  end;
end;

{ TUrlValues }

function TUrlValues.Encode(_Encoder: TTextEncoderProc): RawByteString;
var
  LPair: TPair<string, TArray<string>>;
  LKey: RawByteString;
  LValue: string;
begin
  Result := '';
  for LPair in Self do
  begin
    LKey := _Encoder(LPair.Key);
    for LValue in LPair.Value do
    begin
      if Result <> '' then
        Result := Result + '&';
      Result := Result + LKey + '=' + _Encoder(LValue)
    end;
  end;
end;

function TUrlValues.Get(const _Name: string; _Idx: Integer): string;
var
  LValues: TArray<string>;
begin
  Self.TryGetValue(_Name, LValues);
  if LValues <> nil then
    Result := LValues[_Idx]
  else
    Result := '';
end;

function ParseForm(const _Url: string; _Decoder: TTextDecoderProc): TUrlValues;
var
  LQuestion, P, i: Integer;
  LQuery, kv, k, v: string;
  LPairs: TStringList;
  LValues: TArray<string>;
begin
  LQuestion := Pos('?', _Url);
  if LQuestion > 0 then
    LQuery := Copy(_Url, LQuestion + 1)
  else
    LQuery := _Url;
  Result := TUrlValues.Create;
  LPairs := TStringList.Create;
  LPairs.StrictDelimiter := True;
  LPairs.Delimiter := '&';
  try
    LPairs.DelimitedText := LQuery;
    for i := 0 to LPairs.Count - 1 do
    begin
      kv := Trim(LPairs[i]);
      P := Pos('=', kv);
      if P > 0 then
      begin
        k := Copy(kv, 1, P - 1);
        v := Copy(kv, P + 1);
        k := _Decoder(RawByteString(k));
        v := _Decoder(RawByteString(v));
        Result.TryGetValue(k, LValues);
        P := Length(LValues);
        SetLength(LValues, P + 1);
        LValues[P] := v;
        Result.AddOrSetValue(k, LValues);
      end;
    end;
  finally
    LPairs.Free;
  end;
end;

procedure UrlEncodedFormIterate(_Search: PAnsiChar; _SearchLen: Integer; const _Callback: TKeyValueCallback);
label
  lbl_k, lbl_kv;
var
  P, LEnd, LNameStart, LNameEnd, LValueStart, LValueEnd: PAnsiChar;
begin
  P := _Search;
  LEnd := P + _SearchLen;
  while (P < LEnd) and (P^ <> '?') do Inc(P);
  if P = LEnd then
    P := PAnsiChar(_Search)
  else
    Inc(P);
  while P < LEnd do
  begin
    LValueStart := P;
    LValueEnd := P;
    LNameStart := P;
    while P < LEnd do
    begin
      case P^ of
        '&':
          begin
            LNameEnd := P;
            goto lbl_kv;
          end;
        '=':
          begin
            LNameEnd := P;
            goto lbl_k;
          end
        else Inc(P);
      end;
    end;
    LNameEnd := P;
    goto lbl_kv;
lbl_k:
    Inc(P);
    LValueStart := P;
    while (P < LEnd) and (P^ <> '&') do Inc(P);
    LValueEnd := P;
lbl_kv:
    Inc(P);
    if LNameEnd <= LNameStart then Continue;
    if _Callback(LNameStart, LNameEnd, LValueStart, LValueEnd) then
      Break;
  end;
end;

function ParseForm(const _Search: RawByteString; _Decoder: TTextBufDecoderProc): TUrlValues;
var
  LResult: TUrlValues;
begin
  LResult := TUrlValues.Create;
  try
    UrlEncodedFormIterate(PAnsiChar(_Search), Length(_Search),
      function(_KeyStart, _KeyEnd, _ValueStart, _ValueEnd: PAnsiChar): Boolean
      var
        LName, LValue: string;
        LValues: TArray<string>;
        L: Integer;
      begin
        LName := _Decoder(_KeyStart, _KeyEnd - _KeyStart);
        if _ValueEnd > _ValueStart then
          LValue := _Decoder(_ValueStart, _ValueEnd - _ValueStart)
        else
          LValue := '';
        LResult.TryGetValue(LName, LValues);
        L := Length(LValues);
        SetLength(LValues, L + 1);
        LValues[L] := LValue;
        LResult.AddOrSetValue(LName, LValues);
        Result := False;
      end
    );
  except
    FreeAndNil(LResult);
    raise;
  end;
  Result := LResult;
end;

function CloneList(src: TList): TList;
begin
  if src = nil then
    Result := nil
  else
  begin
    Result := TList.Create;
    Result.count := src.count;

    if Result.count > 0 then
      Move(src.list[0], Result.list[0], SizeOf(Pointer) * src.count);
  end;
end;

procedure Move2List(src, dest: TList);
begin
  dest.count := src.count;

  if dest.count > 0 then
    Move(src.list[0], dest.list[0], SizeOf(Pointer) * src.count);

  src.clear;
end;

function _LaunchProcess(const ApplicationName, CommandLine, CurrentDirectory: string): TProcessInformation;
var
  StartInfo: TStartupInfo;
  lpApplicationName, lpCommandLine: PChar;
begin
  FillChar(Result, 0, SizeOf(Result));
  FillChar(StartInfo, SizeOf(StartInfo), 0);
  StartInfo.cb := SizeOf(StartInfo);
  StartInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow := SW_NORMAL;
  lpApplicationName := StringToPChar(ApplicationName);
  lpCommandLine := StringToPChar(CommandLine);

  if (lpApplicationName <> nil) or (lpCommandLine <> nil) then
  begin
    (*
    if ApplicationName is empty, lpCommandLine must be writable,
    so we make a copy of CommandLine
    *)
    if lpApplicationName = nil then
      lpCommandLine := StringToPChar(Copy(CommandLine, 1, Length(CommandLine)));

    if not Windows.CreateProcess(lpApplicationName, lpCommandLine, nil, nil, False, 0, nil,
      StringToPChar(CurrentDirectory), StartInfo, Result) then
      FillChar(Result, 0, SizeOf(Result));
  end
  else
    SetLastError(ERROR_INVALID_PARAMETER);
end;

function LaunchProcess(const ApplicationName, CommandLine, CurrentDirectory: string): Boolean;
var
  ProcessInfo: TProcessInformation;
begin
  ProcessInfo := _LaunchProcess(ApplicationName, CommandLine, CurrentDirectory);

  if ProcessInfo.hProcess <> 0 then
  begin
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ProcessInfo.hProcess);
    Result := True;
  end
  else
    Result := False;
end;

function LaunchProcessEx(const ApplicationName, CommandLine, CurrentDirectory: string): THandle;
var
  ProcessInfo: TProcessInformation;
begin
  ProcessInfo := _LaunchProcess(ApplicationName, CommandLine, CurrentDirectory);

  if ProcessInfo.hProcess <> 0 then
  begin
    CloseHandle(ProcessInfo.hThread);
    Result := ProcessInfo.hProcess;
  end
  else
    Result := 0;
end;

procedure NavigateWithDefaultBrowser(const url: string);
begin
  ShellExecute(0, 'open', PChar(url), nil, nil, SW_SHOW) // 弹出对话窗口
end;

function Res2StrA(const ResName: string; const ResType: string): RawByteString;
var
  rs: TResourceStream;
begin
  rs := TResourceStream.Create(HInstance, ResName, PChar(ResType));

  try
    SetLength(Result, rs.size);

    rs.Seek(0, soFromBeginning);

    rs.ReadBuffer(Pointer(Result)^, rs.size);

  finally
    rs.Free;
  end;
end;

function Res2RBStrNoBOM(const ResName: string; const ResType: string): RawByteString;
var
  rs: TResourceStream;
  bom: array [0 .. 3] of Byte;
  L: Integer;
begin
  (*
    UTF-8	0xEF 0xBB 0xBF
    UTF-16 BE	0xFE 0xFF
    UTF-16 LE	0xFF 0xFE
    UTF-32 BE	0x00 0x00 0xFE 0xFF
    UTF-32 LE	0xFF 0xFE 0x00 0x00
    *)
  rs := TResourceStream.Create(HInstance, ResName, PChar(ResType));

  try
    L := rs.size;

    if rs.size >= 3 then
    begin
      rs.Seek(0, soFromBeginning);
      rs.Read(bom, 3);

      // UTF8 BOM EF BB BF
      if (bom[0] = $EF) or (bom[1] = $BB) and (bom[2] = $BF) then
        Dec(L, 3)
      else
        rs.Seek(0, soFromBeginning);
    end;

    SetLength(Result, L);

    rs.ReadBuffer(Pointer(Result)^, L);
  finally
    rs.Free;
  end;
end;

procedure Res2StringList(const ResName: string; const ResType: string; strs: TStrings);
var
  rs: TResourceStream;
begin
  rs := TResourceStream.Create(HInstance, ResName, PChar(ResType));

  try
    rs.Seek(0, soFromBeginning);
    strs.LoadFromStream(rs);
  finally
    rs.Free;
  end;
end;

procedure SaveResToFile(const ResName, ResType, SavePath: string);
// 函数功能：获取图标资源
// 返回类型：TBitmap
// 参数作用：
// resname 资源名称
// restype 资源类型
var
  res: TResourceStream;
begin
  res := TResourceStream.Create(HInstance, PChar(ResName), PChar(ResType));
  try
    res.SaveToFile(SavePath);
  finally
    res.Free;
  end;
end;

function StrToBoolA(s: PAnsiChar; len: Integer; def: Boolean): Boolean;
var
  pwc: PAnsiChar;
  v: Int64;
begin
  v := BufToInt64A(s, len, @pwc);

  if Assigned(pwc) then
  begin
    if (len = 4) and ((s[0] = 'T') or (s[0] = 't')) and ((s[1] = 'R') or (s[1] = 'r')) and
      ((s[2] = 'U') or (s[2] = 'u')) and ((s[3] = 'E') or (s[3] = 'e')) then
      Result := True
    else if (len = 5) and ((s[0] = 'F') or (s[0] = 'f')) and ((s[1] = 'A') or (s[1] = 'a')) and
      ((s[2] = 'L') or (s[2] = 'l')) and ((s[3] = 'S') or (s[3] = 's')) and ((s[4] = 'E') or (s[4] = 'e')) then
      Result := False
    else
      Result := def;
  end
  else
    Result := v <> 0;
end;

function RBStrToBool(const s: RawByteString; def: Boolean): Boolean;
begin
  Result := StrToBoolA(PAnsiChar(s), length(s), def);
end;

function StrToBoolW(s: PWideChar; len: Integer; def: Boolean): Boolean;
var
  pwc: PWideChar;
  v: Int64;
begin
  v := BufToInt64W(s, len, @pwc);

  if Assigned(pwc) then
  begin
    if (len = 4) and ((s[0] = 'T') or (s[0] = 't')) and ((s[1] = 'R') or (s[1] = 'r')) and
      ((s[2] = 'U') or (s[2] = 'u')) and ((s[3] = 'E') or (s[3] = 'e')) then
      Result := True
    else if (len = 5) and ((s[0] = 'F') or (s[0] = 'f')) and ((s[1] = 'A') or (s[1] = 'a')) and
      ((s[2] = 'L') or (s[2] = 'l')) and ((s[3] = 'S') or (s[3] = 's')) and ((s[4] = 'E') or (s[4] = 'e')) then
      Result := False
    else
      Result := def;
  end
  else
    Result := v <> 0;
end;

function UStrToBool(const s: u16string; def: Boolean): Boolean;
begin
  Result := StrToBoolW(PWideChar(s), length(s), def);
end;

function RunningInMainThread: Boolean;
begin
  Result := GetCurrentThreadId = MainThreadID;
end;

// 获取url参数

function RBStrUrlGetParam(const url, name: RawByteString): RawByteString;
var
  p, P2, L: Integer;
begin
  Result := '';

  p := 1;
  L := length(url);

  while p < L do
  begin
    p := RBStrIPos(name, url, p);

    if p <= 0 then
      Break;

    if (p > 1) and (url[p - 1] <> '?') and (url[p - 1] <> '&') then
    begin
      Inc(p, length(name));
      Continue;
    end;

    Inc(p, length(name));

    if (p < L) and (url[p] <> '=') then
      Continue;

    Inc(p);

    if p <= L then
    begin
      P2 := p + 1;
      while (P2 <= L) and (url[P2] <> '&') do
        Inc(P2);
      Result := Copy(url, p, P2 - p);
    end;

    Break;
  end;
end;

function UStrUrlGetParam(const url, name: u16string): u16string;
var
  p, P2, L: Integer;
begin
  Result := '';

  p := 1;
  L := length(url);

  while p < L do
  begin
    p := UStrIPos(name, url, p);

    if p <= 0 then
      Break;

    if (p > 1) and (url[p - 1] <> '?') and (url[p - 1] <> '&') then
    begin
      Inc(p, length(name));
      Continue;
    end;

    Inc(p, length(name));

    if (p < L) and (url[p] <> '=') then
      Continue;

    Inc(p);

    if p <= L then
    begin
      P2 := p + 1;
      while (P2 <= L) and (url[P2] <> '&') do
        Inc(P2);
      Result := Copy(url, p, P2 - p);
    end;

    Break;
  end;
end;

function BStrUrlGetParam(const url, name: WideString): WideString;
var
  p, P2, L: Integer;
begin
  Result := '';

  p := 1;
  L := length(url);

  while p < L do
  begin
    p := BStrPos(name, url, p);

    if p <= 0 then
      Break;

    if (p > 1) and (url[p - 1] <> '?') and (url[p - 1] <> '&') then
    begin
      Inc(p, length(name));
      Continue;
    end;

    Inc(p, length(name));

    if (p < L) and (url[p] <> '=') then
      Continue;

    Inc(p);

    if p <= L then
    begin
      P2 := p + 1;
      while (P2 <= L) and (url[P2] <> '&') do
        Inc(P2);
      Result := Copy(url, p, P2 - p);
    end;

    Break;
  end;
end;

function ExpandUrl(const url: u16string): u16string;
begin
  if UStrIBeginWith(url, 'http:') or UStrIBeginWith(url, 'https:') then
    Result := url
  else if UStrIBeginWith(url, ':') then
    Result := 'http' + url
  else if UStrIBeginWith(url, '//') then
    Result := 'http:' + url
  else
    Result := 'http://' + url;
end;

function RBStrUrlGetFileName(const url: RawByteString): RawByteString;
var
  i: Integer;
begin
  Result := '';

  for i := length(url) downto 1 do
  begin
    if url[i] = '/' then
    begin
      Result := Copy(url, i + 1, length(url) - i);
      Break;
    end;
  end;
end;

function UStrUrlGetFileName(const url: u16string): u16string;
var
  i: Integer;
begin
  Result := '';

  for i := length(url) downto 1 do
  begin
    if url[i] = '/' then
    begin
      Result := Copy(url, i + 1, length(url) - i);
      Break;
    end;
  end;
end;

procedure EmptyFile(const FileName: string);
var
  hFile: THandle;
begin
  hFile := Windows.CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL, 0);

  if hFile <> INVALID_HANDLE_VALUE then
  begin
    Windows.SetEndOfFile(hFile);
    CloseHandle(hFile);
  end;
end;

procedure SubDirList(const ParentDir: string; strs: TStrings);
var
  sr: TSearchRec;
  n: Integer;
  filter: string;
begin
  if ParentDir = '' then
    Exit;

  if ParentDir[length(ParentDir)] = '\' then
    filter := ParentDir + '*.*'
  else
    filter := ParentDir + '\*.*';

  if SysUtils.FindFirst(filter, faAnyFile, sr) <> 0 then
    Exit;

  n := 0;

  repeat
    if (sr.Name <> '.') and (sr.Name <> '..') and (sr.Attr and faDirectory <> 0) then
    begin
      strs.add(sr.Name);
      Inc(n);
    end;
  until (n >= 1000) or (SysUtils.FindNext(sr) <> 0);

  SysUtils.FindClose(sr);
end;

function CopyDirecotry(const SrcDir, DstDir: string; recursive: Boolean): Integer;
var
  hFindFile: THandle;
  FindData: TWin32FindData;
  tmp1, tmp2, filter, FileName: string;
begin
  Result := 0;

  ForceDirectories(DstDir);

  if SrcDir[length(SrcDir)] = '\' then
    tmp1 := SrcDir
  else
    tmp1 := SrcDir + '\';

  filter := tmp1 + '*.*';

  if DstDir[length(DstDir)] = '\' then
    tmp2 := DstDir
  else
    tmp2 := DstDir + '\';

  hFindFile := Windows.FindFirstFile(PChar(filter), FindData);

  if hFindFile = INVALID_HANDLE_VALUE then
    Exit;

  while True do
  begin
    if (StrComp(FindData.cFileName, '.') <> 0) and (StrComp(FindData.cFileName, '..') <> 0) then
    begin
      if FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = FILE_ATTRIBUTE_DIRECTORY then
      begin
        FileName := FindData.cFileName;
        if recursive then
          Inc(Result, CopyDirecotry(tmp1 + FileName, tmp2 + FileName));
      end
      else
      begin
        FileName := FindData.cFileName;

        if Windows.CopyFile(PChar(tmp1 + FileName), PChar(tmp2 + FileName), False) then
          Inc(Result);
      end;
    end;

    if not Windows.FindNextFile(hFindFile, FindData) then
      Break;
  end;
end;

procedure SearchFiles(const ParentDir, filter: string; strs: TStrings);
var
  sr: TSearchRec;
  path: string;
begin
  if ParentDir = '' then
    Exit;

  if ParentDir[length(ParentDir)] = '\' then
    path := ParentDir + filter
  else
    path := ParentDir + '\' + filter;

  if SysUtils.FindFirst(path, faAnyFile, sr) <> 0 then
    Exit;

  while True do
  begin
    if (sr.Name <> '.') and (sr.Name <> '..') and (sr.Attr and faDirectory = 0) then
      strs.add(sr.Name);

    if SysUtils.FindNext(sr) <> 0 then
      Break;
  end;

  SysUtils.FindClose(sr);
end;

procedure SafeForceDirectories(const dir: string);
begin
  try
    ForceDirectories(dir);
  except
  end;
end;

function PathJoin(const s1, s2: string): string;
begin
  if s1 = '' then
    Result := s2
  else if s1[length(s1)] = '\' then
    Result := s1 + s2
  else
    Result := s1 + '\' + s2;
end;

procedure SaveStreamToFile(const FileName: string; stream: TStream; len: Integer);
var
  ms: TMemoryStream;
  fs: TFileStream;
begin
  if stream is TMemoryStream then
  begin
    ms := TMemoryStream(stream);
    SaveBufToFile(FileName, PAnsiChar(ms.Memory) + ms.Position, len);
  end
  else
  begin
    fs := TFileStream.Create(FileName, fmCreate);

    try
      fs.CopyFrom(stream, len);
    finally
      fs.Free;
    end;
  end;
end;

function SafeSaveStreamToFile(const FileName: string; stream: TStream; len: Integer): Boolean;
begin
  try
    SaveStreamToFile(FileName, stream, len);
    Result := True;
  except
    Result := False;
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
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmCreate);
  try
    fs.WriteBuffer(Pointer(str)^, length(str));
  finally
    fs.Free;
  end;
end;

function SafeSaveStrToFile(const FileName: string; const str: RawByteString): Boolean;
begin
  try
    SaveBufToFile(FileName, Pointer(str), length(str));
    Result := True;
  except
    Result := False;
  end;
end;

procedure SaveUStrToFile(const FileName: string; const str: u16string; CodePage: Integer = CP_ACP);
var
  fs: TFileStream;
  rbs: RawByteString;
begin
  rbs := UStrToMultiByte(str, CodePage);

  fs := TFileStream.Create(FileName, fmCreate);
  try
    fs.WriteBuffer(Pointer(rbs)^, length(rbs));
  finally
    fs.Free;
  end;
end;

function SafeSaveUStrToFile(const FileName: string; const str: u16string; CodePage: Integer = CP_ACP): Boolean;
begin
  try
    SaveUStrToFile(FileName, str, CodePage);
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
      fs.WriteBuffer(Pointer(strs[i])^, length(strs[i]));
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

function VarRecToRBS(const vr: TVarRec): RawByteString;
begin
  case vr.VType of
    vtInteger:
      Result := IntToRBStr(vr.VInteger);

    vtBoolean:
      if vr.VBoolean then
        Result := 'true'
      else
        Result := 'false';

    vtChar:
      Result := vr.VChar;
    vtExtended:
      Result := RawByteString(FloatToStr(vr.VExtended^));
    vtString:
      Result := RawByteString(vr.VString^);
    vtPointer:
      Result := RawByteString(Format('%.8x', [vr.VPointer]));
    vtPChar:
      Result := RawByteString(vr.VPChar);
    vtObject:
      Result := 'object(' + RawByteString(vr.VObject.ClassName) + ')';
    vtClass:
      Result := 'class(' + RawByteString(vr.VClass.ClassName) + ')';
    vtWideChar:
      Result := RawByteString(vr.VWideChar);
    vtPWideChar:
      Result := RawByteString((u16string(vr.VPWideChar)));
    vtAnsiString:
      Result := (RawByteString(vr.VAnsiString));
    vtCurrency:
      Result := RawByteString(FloatToStr(vr.VCurrency^));
    vtVariant:
      Result := RawByteString(vr.VVariant^);
    vtInterface:
      Result := 'interface';
    vtWideString:
      Result := RawByteString(WideString(vr.VWideString));
    vtUnicodeString:
      Result := RawByteString(u16string(vr.VUnicodeString));
    vtInt64:
      Result := IntToRBStr(vr.VInt64^);
  end;
end;

procedure SaveArrayToFile(const FileName: string; const values: array of const );
var
  fs: TFileStream;
  i: Integer;
  rbs: RawByteString;
begin
  fs := TFileStream.Create(FileName, fmCreate);
  try
    for i := Low(values) to High(values) do
    begin
      rbs := VarRecToRBS(values[i]);
      fs.WriteBuffer(Pointer(rbs)^, length(rbs));
    end;

  finally
    fs.Free;
  end;
end;

function SafeSaveArrayToFile(const FileName: string; const values: array of const ): Boolean;
begin
  try
    SaveArrayToFile(FileName, values);
    Result := True;
  except
    Result := False;
  end;
end;

function LoadStrFromFile(const FileName: string): RawByteString;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);

  try
    SetLength(Result, fs.size);
    fs.ReadBuffer(Pointer(Result)^, length(Result));
  finally
    fs.Free;
  end;
end;

function getStreamContentType(data: TStream): RawByteString;
var
  bytes: array [0 .. 3] of Byte;
  bookmark: Int64;
begin
  {
    JPEG FFD8FF
    PNG 89504E47
    GIF 47494638
    Bitmap 424D
    }
  Result := 'application/octet-stream';
  bookmark := data.Position;

  if data.Size <= 4 then
    Exit;

  try
    data.ReadBuffer(bytes, SizeOf(bytes));
    data.Position := bookmark;

    if (bytes[0] = $FF) and (bytes[1] = $D8) and (bytes[2] = $FF) then
      Result := 'image/jpeg'
    else if (bytes[0] = $89) and (bytes[1] = $50) and (bytes[2] = $4E) and
      (bytes[3] = $47) then
      Result := 'image/png'
    else if (bytes[0] = $47) and (bytes[1] = $49) and (bytes[2] = $46) and
      (bytes[3] = $38) then
      Result := 'image/gif'
    else if (bytes[0] = $42) and (bytes[1] = $4D) then
      Result := 'image/bmp'
  finally
    data.Position := bookmark;
  end;
end;

function Stream2String(stream: TStream): RawByteString;
begin
  SetLength(Result, stream.size - stream.Position);
  stream.ReadBuffer(Pointer(Result)^, length(Result));
end;

procedure UTF8EncodeFile(const FileName: string);
var
  s: UTF8String;
begin
  s := UTF8EncodeUStr(u16string(LoadStrFromFile(FileName)));
  SaveBufToFile(FileName, Pointer(s), length(s));
end;

procedure UTF8DecodeFile(const FileName: string);
var
  s: u16string;
begin
  s := UTF8DecodeStr(LoadStrFromFile(FileName));
  SaveBufToFile(FileName, Pointer(s), length(s) * 2);
end;

procedure HttpEncodeFile(const FileName: string);
var
  s: RawByteString;
begin
  s := HttpEncode(LoadStrFromFile(FileName));
  SaveStrToFile(FileName, s);
end;

procedure HttpDecodeFile(const FileName: string);
var
  s: RawByteString;
begin
  s := HttpDecode(LoadStrFromFile(FileName));
  SaveStrToFile(FileName, s);
end;

function UTF16Decode(const s: RawByteString): u16string;
var
  i, p, n, L: Integer;
begin
  // \u672a\u5206\u914d\u6216\u8005\u5185\u7f51IP
  n := 0;
  L := length(s);

  SetLength(Result, length(s));

  p := 1;

  while p <= L - 5 do
  begin
    if (s[p] = '\') and ((s[p + 1] = 'u') or (s[p + 1] = 'U')) then
    begin
      Inc(n);
      Word(Result[n]) := HexToUInt32A(PAnsiChar(s) + p + 1, 4, nil);
      Inc(p, 6);
    end
    else
    begin
      Inc(n);
      Result[n] := WideChar(s[p]);
      Inc(p);
    end;
  end;

  for i := p to L do
  begin
    Inc(n);
    Result[n] := WideChar(s[i]);
  end;

  SetLength(Result, n);
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

function RBStrNow: RawByteString;
var
  st: TSystemTime;
begin
  GetLocalTime(st);

  Result := RBStrFormat('%.4d/%.2d/%.2d %.2d:%.2d:%.2d %.3d', [st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute,
    st.wSecond, st.wMilliseconds]);
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

function SameYear(former, later: TDateTime): Boolean;
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
  dt := EncodeDateTime(st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);

  DecodeDateTime(IncMilliSecond(dt, value), st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond,
    st.wMilliseconds);
end;

procedure SystemTimeIncSeconds(var st: TSystemTime; value: Int64);
var
  dt: TDateTime;
begin
  dt := EncodeDateTime(st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);

  DecodeDateTime(IncSecond(dt, value), st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond,
    st.wMilliseconds);
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
    Result := EncodeDate(wYear, wMonth, wDay) + EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
end;

function UTCToLocal(dt: TDateTime): TDateTime;
var
  tzi: TTimeZoneInformation;
begin
  GetTimeZoneInformation(tzi);

  Result := IncMinute(dt, -tzi.Bias);
end;

function LocalToUTC(dt: TDateTime): TDateTime;
var
  tzi: TTimeZoneInformation;
begin
  GetTimeZoneInformation(tzi);

  Result := IncMinute(dt, tzi.Bias);
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
  Result := MilliSecondsBetween(JAVA_TIME_START, d);
end;

function JavaToDateTime(t: Int64): TDateTime;
var
  d1, d2: Double;
begin
  d1 := t;
  d2 := MSecsPerDay;
  Result := JAVA_TIME_START + d1 / d2;
end;

function getWebTimestamp: Int64;
begin
  Result := DateTimeToJava(UTCNow);
end;

function GMTStringToDateTime(const s: RawByteString): TDateTime;
var
  numbers: array [0 .. 5] of Int64;
  n, m: Integer;
begin
  ///// to be optimized !!!!!
  (* set-cookie format
  Fri, 08-Jan-2016 15:42:53 GMT
  Tue, 09-Feb-2016 07:47:51 GMT
  Fri, 30 Jan 2026 15:49:19 GMT
  Mon, 23-Jan-2017 02:26:34 GMT
  *)

  (* JavaScript format
  Mon Jan 23 2017 19:33:54 GMT+0800
  Tue Jul 14 2009 13:32:31 GMT+0800
  *)

  Result := 0.0;

  n := RBStrExtractIntegers(s, numbers);

  if n = 6 then
    Result := EncodeDateTime(numbers[0], numbers[1], numbers[2], numbers[3], numbers[4], numbers[5], 0)
  else begin
    if RBStrIPos('Jan', s) > 0 then m := 1
    else if RBStrIPos('Feb', s) > 0 then m := 2
    else if RBStrIPos('Mar', s) > 0 then m := 3
    else if RBStrIPos('Apr', s) > 0 then m := 4
    else if RBStrIPos('May', s) > 0 then m := 5
    else if RBStrIPos('Jun', s) > 0 then m := 6
    else if RBStrIPos('Jul', s) > 0 then m := 7
    else if RBStrIPos('Aug', s) > 0 then m := 8
    else if RBStrIPos('Sep', s) > 0 then m := 9
    else if RBStrIPos('Oct', s) > 0 then m := 10
    else if RBStrIPos('Nov', s) > 0 then m := 11
    else if RBStrIPos('Dec', s) > 0 then m := 12
    else m := 0;

    if m > 0 then
      Result := EncodeDateTime(numbers[1], m, numbers[0], numbers[2], numbers[3], numbers[4], 0);
  end;
end;

function GMTStringToDateTime(const s: string): TDateTime;
var
  numbers: array [0 .. 5] of Int64;
  n, m: Integer;
begin
  ///// to be optimized !!!!!
  (* set-cookie format
  Fri, 08-Jan-2016 15:42:53 GMT
  Tue, 09-Feb-2016 07:47:51 GMT
  Fri, 30 Jan 2026 15:49:19 GMT
  Mon, 23-Jan-2017 02:26:34 GMT
  *)

  (* JavaScript format
  Mon Jan 23 2017 19:33:54 GMT+0800
  Tue Jul 14 2009 13:32:31 GMT+0800
  *)

  Result := 0.0;

  n := UStrExtractIntegers(s, numbers);

  if n = 6 then
    Result := EncodeDateTime(numbers[0], numbers[1], numbers[2], numbers[3], numbers[4], numbers[5], 0)
  else begin
    if UStrIPos('Jan', s) > 0 then m := 1
    else if UStrIPos('Feb', s) > 0 then m := 2
    else if UStrIPos('Mar', s) > 0 then m := 3
    else if UStrIPos('Apr', s) > 0 then m := 4
    else if UStrIPos('May', s) > 0 then m := 5
    else if UStrIPos('Jun', s) > 0 then m := 6
    else if UStrIPos('Jul', s) > 0 then m := 7
    else if UStrIPos('Aug', s) > 0 then m := 8
    else if UStrIPos('Sep', s) > 0 then m := 9
    else if UStrIPos('Oct', s) > 0 then m := 10
    else if UStrIPos('Nov', s) > 0 then m := 11
    else if UStrIPos('Dec', s) > 0 then m := 12
    else m := 0;

    if m > 0 then
      Result := EncodeDateTime(numbers[1], m, numbers[0], numbers[2], numbers[3], numbers[4], 0);
  end;
end;

function dateTimeToGMTRawBytes(const st: TSystemTime; buf: PAnsiChar; utcbias: Integer): Integer;
var
  hours, minutes: Integer;
begin
  ///// to be optimized !!!!!
  buf[0] := AnsiChar(WEEKDAY_SHORTHANDS[st.wDayOfWeek][0]);
  buf[1] := AnsiChar(WEEKDAY_SHORTHANDS[st.wDayOfWeek][1]);
  buf[2] := AnsiChar(WEEKDAY_SHORTHANDS[st.wDayOfWeek][2]);
  buf[3] := #32;
  buf[4] := AnsiChar(MONTH_SHORTHANDS[st.wMonth][0]);
  buf[5] := AnsiChar(MONTH_SHORTHANDS[st.wMonth][1]);
  buf[6] := AnsiChar(MONTH_SHORTHANDS[st.wMonth][2]);
  buf[7] := #32;

  if st.wDay < 10 then
  begin
    buf[8] := '0';
    buf[9] := AnsiChar(st.wDay + $30);
  end
  else begin
    buf[8] := AnsiChar(st.wDay div 10 + $30);
    buf[9] := AnsiChar(st.wDay mod 10 + $30);;
  end;

  buf[10] := #32;
  StrInt(buf + 15, st.wYear);
  buf[15] := #32;

  if st.wHour < 10 then
  begin
    buf[16] := '0';
    buf[17] := AnsiChar(st.wHour + $30);
  end
  else begin
    buf[16] := AnsiChar(st.wHour div 10 + $30);
    buf[17] := AnsiChar(st.wHour mod 10 + $30);;
  end;
  buf[18] := ':';

  if st.wMinute < 10 then
  begin
    buf[19] := '0';
    buf[20] := AnsiChar(st.wMinute + $30);
  end
  else begin
    buf[19] := AnsiChar(st.wMinute div 10 + $30);
    buf[20] := AnsiChar(st.wMinute mod 10 + $30);;
  end;
  buf[21] := ':';

  if st.wSecond < 10 then
  begin
    buf[22] := '0';
    buf[23] := AnsiChar(st.wSecond + $30);
  end
  else begin
    buf[22] := AnsiChar(st.wSecond div 10 + $30);
    buf[23] := AnsiChar(st.wSecond mod 10 + $30);;
  end;
  buf[24] := #32;
  buf[25] := 'G';
  buf[26] := 'M';
  buf[27] := 'T';
  if utcbias > 1440 then
    utcbias := UTCLocalDiff;

  if utcbias = 0 then
    Result := 28
  else begin
    if utcbias > 0 then
      buf[28] := '+'
    else begin
      buf[28] := '-';
      utcbias := -utcbias;
    end;
    hours := utcbias div 60;
    minutes := utcbias mod 60;
    buf[29] := AnsiChar(hours div 10 + $30);
    buf[30] := AnsiChar(hours mod 10 + $30);
    buf[31] := AnsiChar(minutes div 10 + $30);
    buf[32] := AnsiChar(minutes div 10 + $30);
    Result := 33;
  end;
end;

function dateTimeToGMTRawBytes(const st: TSystemTime; utcbias: Integer): RawByteString;
var
  buf: array [0..32] of AnsiChar;
begin
  SetString(Result, buf, dateTimeToGMTRawBytes(st, buf, utcbias));
end;

function dateTimeToGMTRawBytes(dt: TDateTime; utcbias: Integer): RawByteString;
var
  st: TSystemTime;
begin
  DateTimeToSystemTime(dt, st);
  Result := dateTimeToGMTRawBytes(st, utcbias);
end;

function dateTimeToGMTString(const st: TSystemTime; buf: PWideChar; utcbias: Integer): Integer;
var
  hours, minutes: Integer;
begin
  //Tue Jul 14 2009 13:32:31 GMT+0800
  ///// to be optimized !!!!!
  buf[0] := Char(WEEKDAY_SHORTHANDS[st.wDayOfWeek][0]);
  buf[1] := Char(WEEKDAY_SHORTHANDS[st.wDayOfWeek][1]);
  buf[2] := Char(WEEKDAY_SHORTHANDS[st.wDayOfWeek][2]);
  buf[3] := #32;
  buf[4] := Char(MONTH_SHORTHANDS[st.wMonth][0]);
  buf[5] := Char(MONTH_SHORTHANDS[st.wMonth][1]);
  buf[6] := Char(MONTH_SHORTHANDS[st.wMonth][2]);
  buf[7] := #32;

  if st.wDay < 10 then
  begin
    buf[8] := '0';
    buf[9] := Char(st.wDay + $30);
  end
  else begin
    buf[8] := Char(st.wDay div 10 + $30);
    buf[9] := Char(st.wDay mod 10 + $30);;
  end;

  buf[10] := #32;
  StrInt(buf + 15, st.wYear);
  buf[15] := #32;

  if st.wHour < 10 then
  begin
    buf[16] := '0';
    buf[17] := Char(st.wHour + $30);
  end
  else begin
    buf[16] := Char(st.wHour div 10 + $30);
    buf[17] := Char(st.wHour mod 10 + $30);;
  end;
  buf[18] := ':';

  if st.wMinute < 10 then
  begin
    buf[19] := '0';
    buf[20] := Char(st.wMinute + $30);
  end
  else begin
    buf[19] := Char(st.wMinute div 10 + $30);
    buf[20] := Char(st.wMinute mod 10 + $30);;
  end;
  buf[21] := ':';

  if st.wSecond < 10 then
  begin
    buf[22] := '0';
    buf[23] := Char(st.wSecond + $30);
  end
  else begin
    buf[22] := Char(st.wSecond div 10 + $30);
    buf[23] := Char(st.wSecond mod 10 + $30);;
  end;
  buf[24] := #32;
  buf[25] := 'G';
  buf[26] := 'M';
  buf[27] := 'T';
  if utcbias > 1440 then
    utcbias := UTCLocalDiff;

  if utcbias = 0 then
    Result := 28
  else begin
    if utcbias > 0 then
      buf[28] := '+'
    else begin
      buf[28] := '-';
      utcbias := -utcbias;
    end;
    hours := utcbias div 60;
    minutes := utcbias mod 60;
    buf[29] := Char(hours div 10 + $30);
    buf[30] := Char(hours mod 10 + $30);
    buf[31] := Char(minutes div 10 + $30);
    buf[32] := Char(minutes div 10 + $30);
    Result := 33;
  end;
end;

function dateTimeToGMTString(const st: TSystemTime; utcbias: Integer): string;
var
  buf: array [0..32] of Char;
begin
  SetString(Result, buf, dateTimeToGMTString(st, buf, utcbias));
end;

function dateTimeToGMTString(dt: TDateTime; utcbias: Integer): string;
var
  st: TSystemTime;
begin
  DateTimeToSystemTime(dt, st);
  Result := dateTimeToGMTString(st, utcbias);
end;

function IsPrintable(ch: AnsiChar): Boolean;
begin
  Result := (ch = #13) or (ch = #10) or (ch = #9) or (ch >= #32);
end;

function IsPrintableString(const s: RawByteString): Boolean;
var
  i: Integer;
begin
  Result := True;

  for i := 0 to length(s) - 1 do
  begin
    if not IsPrintable(PAnsiChar(s)[i]) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function IsPrintableString(const buf; bufLen: Integer): Boolean;
var
  i: Integer;
begin
  Result := True;

  for i := 0 to bufLen - 1 do
  begin
    if not IsPrintable(PAnsiChar(@buf)[i]) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function RandomBytes(count: Integer): RawByteString;
var
  i: Integer;
  pch: PAnsiChar;
begin
  SetLength(Result, count);
  pch := PAnsiChar(Result);
  for i := 0 to count - 1 do
    pch[i] := AnsiChar(Random($100));
end;

function RandomRBStr(CharSet: RawByteString; CharCount: Integer): RawByteString;
var
  i: Integer;
  pch: PAnsiChar;
begin
  SetLength(Result, CharCount);
  pch := PAnsiChar(Result);
  for i := 0 to CharCount - 1 do
    pch[i] := CharSet[Random(length(CharSet)) + 1];
end;

function RandomAlphaRBStr(CharCount: Integer; Types: TCharTypes): RawByteString;
var
  CharSet: RawByteString;
begin
  if chAlphaUpperCase in Types then
  begin
    if chAlphaLowerCase in Types then
      CharSet := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    else
      CharSet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  end
  else
    CharSet := 'abcdefghjklmnopqrstuvwxyz';

  Result := RandomRBStr(CharSet, CharCount);
end;

function RandomDigitRBStr(CharCount: Integer): RawByteString;
begin
  Result := RandomRBStr('0123456789', CharCount);
end;

function RandomAlphaDigitRBStr(CharCount: Integer; Types: TCharTypes): RawByteString;
var
  CharSet: RawByteString;
begin
  if chAlphaUpperCase in Types then
  begin
    if chAlphaLowerCase in Types then
      CharSet := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    else
      CharSet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  end
  else
    CharSet := 'abcdefghjklmnopqrstuvwxyz0123456789';

  Result := RandomRBStr(CharSet, CharCount);
end;

function RandomUStr(CharSet: u16string; CharCount: Integer): u16string;
var
  i: Integer;
  pch: PWideChar;
begin
  SetLength(Result, CharCount);
  pch := PWideChar(Result);
  for i := 0 to CharCount - 1 do
    pch[i] := CharSet[Random(length(CharSet)) + 1];
end;

function RandomAlphaUStr(CharCount: Integer; Types: TCharTypes): u16string;
var
  CharSet: u16string;
begin
  if chAlphaUpperCase in Types then
  begin
    if chAlphaLowerCase in Types then
      CharSet := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    else
      CharSet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  end
  else
    CharSet := 'abcdefghjklmnopqrstuvwxyz';

  Result := RandomUStr(CharSet, CharCount);
end;

function RandomDigitUStr(CharCount: Integer): u16string;
begin
  Result := RandomUStr('0123456789', CharCount);
end;

function RandomAlphaDigitUStr(CharCount: Integer; Types: TCharTypes): u16string;
var
  CharSet: u16string;
begin
  if chAlphaUpperCase in Types then
  begin
    if chAlphaLowerCase in Types then
      CharSet := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    else
      CharSet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  end
  else
    CharSet := 'abcdefghjklmnopqrstuvwxyz0123456789';

  Result := RandomUStr(CharSet, CharCount);
end;

function RandomBStr(CharSet: u16string; CharCount: Integer): WideString;
var
  i: Integer;
  pch: PWideChar;
begin
  SetLength(Result, CharCount);
  pch := PWideChar(Result);
  for i := 0 to CharCount - 1 do
    pch[i] := CharSet[Random(length(CharSet)) + 1];
end;

function RandomAlphaBStr(CharCount: Integer; Types: TCharTypes = [chAlphaUpperCase, chAlphaLowerCase]): WideString;
var
  CharSet: u16string;
begin
  if chAlphaUpperCase in Types then
  begin
    if chAlphaLowerCase in Types then
      CharSet := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    else
      CharSet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  end
  else
    CharSet := 'abcdefghjklmnopqrstuvwxyz';

  Result := RandomBStr(CharSet, CharCount);
end;

function RandomDigitBStr(CharCount: Integer): WideString;
begin
  Result := RandomBStr('0123456789', CharCount);
end;

function RandomAlphaDigitBStr(CharCount: Integer; Types: TCharTypes): WideString;
var
  CharSet: u16string;
begin
  if chAlphaUpperCase in Types then
  begin
    if chAlphaLowerCase in Types then
      CharSet := 'abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    else
      CharSet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  end
  else
    CharSet := 'abcdefghjklmnopqrstuvwxyz0123456789';

  Result := RandomBStr(CharSet, CharCount);
end;

function RandomCNMobile: RawByteString;
const
  SAPrefix: array [0 .. 29] of RawByteString = ('134', '135', '136', '137', '138', '139', '147', '150', '151', '152',
    '157', '158', '159', '182', '183', '187', '188', '130', '131', '132', '155', '156', '185', '186', '145', '133',
    '153', '189', '180', '181');
var
  prefix: RawByteString;
  i: Integer;
begin
  prefix := SAPrefix[Random(length(SAPrefix))];
  SetLength(Result, 11);
  PAnsiChar(Result)[0] := prefix[1];
  PAnsiChar(Result)[1] := prefix[2];
  PAnsiChar(Result)[2] := prefix[3];

  for i := 3 to length(Result) - 1 do
    PAnsiChar(Result)[i] := AnsiChar(Ord('0') + Random(10));
end;

function UTF8EncodeBufferTest(src: PWideChar; srcLen: Integer): Integer;
var
  i: Integer;
  c: Word;
begin
  Result := 0;

  if src = nil then
    Exit;

  for i := 0 to srcLen - 1 do
  begin
    c := Word(src[i]);

    if c > $7F then
    begin
      if c > $7FF then
        Inc(Result);
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

  if src = nil then
    Exit;

  while src^ <> #0 do
  begin
    c := Word(src^);

    if c > $7F then
    begin
      if c > $7FF then
        Inc(Result);
      Inc(Result);
    end;

    Inc(Result);

    Inc(src);
  end;
end;

function UTF8EncodeBuffer(src: PWideChar; srcLen: Integer; dest: PAnsiChar): Integer;
var
  i: Integer;
  c: Word;
begin
  Result := 0;

  if src = nil then
    Exit;

  for i := 0 to srcLen - 1 do
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
    else
    begin
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

  if src = nil then
    Exit;

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
    else
    begin
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

function UTF8EncodeBuffer(src: PWideChar; srcLen: Integer): UTF8String;
begin
  SetLength(Result, srcLen * 3);

  SetLength(Result, UTF8EncodeBuffer(src, srcLen, PAnsiChar(Result)));
end;

function UTF8EncodeUStr(const src: u16string; dest: PAnsiChar): Integer;
begin
  Result := UTF8EncodeBuffer(PWideChar(src), length(src), dest);
end;

function UTF8EncodeBStr(const src: WideString; dest: PAnsiChar): Integer;
begin
  Result := UTF8EncodeBuffer(PWideChar(src), length(src), dest);
end;

function UTF8EncodeUStr(const src: u16string): UTF8String;
begin
  SetLength(Result, length(src) * 3);

  SetLength(Result, UTF8EncodeBuffer(PWideChar(src), length(src), PAnsiChar(Result)));
end;

function UTF8EncodeBStr(const src: WideString): UTF8String;
begin
  SetLength(Result, length(src) * 3);

  SetLength(Result, UTF8EncodeBuffer(PWideChar(src), length(src), PAnsiChar(Result)));
end;

function UTF8DecodeBufferTest(src: PAnsiChar; srcLen: Integer; invalid: PPAnsiChar): Integer;
var
  i: Integer;
  c: Byte;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;

  i := 0;

  while i < srcLen do
  begin
    c := PByte(src + i)^;
    Inc(i);

    if c and $80 <> 0 then
    begin
      // incomplete multibyte char
      if i >= srcLen then
      begin
        if Assigned(invalid) then
          invalid^ := src + i - 1;

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
          if Assigned(invalid) then
            invalid^ := src + i - 2;
          Exit;
        end;

        (* incomplete multibyte char *)
        if i >= srcLen then
        begin
          if Assigned(invalid) then
            invalid^ := src + i - 2;
          Exit;
        end;
      end;

      c := PByte(src + i)^;
      Inc(i);

      (* malformed trail byte *)
      if (c and $C0) <> $80 then
      begin
        if Assigned(invalid) then
          invalid^ := src + i - 3;
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
  if Assigned(invalid) then
    invalid^ := nil;

  while src^ <> #0 do
  begin
    c := PByte(src)^;
    Inc(src);

    if c and $80 <> 0 then
    begin
      // incomplete multibyte char
      if src^ = #0 then
      begin
        if Assigned(invalid) then
          invalid^ := src - 1;

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
          if Assigned(invalid) then
            invalid^ := src - 2;
          Exit;
        end;

        (* incomplete multibyte char *)
        if src^ = #0 then
        begin
          if Assigned(invalid) then
            invalid^ := src - 2;
          Exit;
        end;
      end;

      c := PByte(src)^;
      Inc(src);

      (* malformed trail byte *)
      if (c and $C0) <> $80 then
      begin
        if Assigned(invalid) then
          invalid^ := src - 3;
        Exit;
      end;
    end;

    Inc(Result);
  end;
end;

function UTF8DecodeBuffer(src: PAnsiChar; srcLen: Integer; dest: PWideChar; invalid: PPAnsiChar): Integer;
var
  i: Integer;
  c: Byte;
  wc: Word;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;

  i := 0;

  while i < srcLen do
  begin
    wc := PByte(src + i)^;
    Inc(i);

    if wc and $80 <> 0 then
    begin
      (* incomplete multibyte char *)
      if i >= srcLen then
      begin
        if Assigned(invalid) then
          invalid^ := src + i - 1;
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
          if Assigned(invalid) then
            invalid^ := src + i - 2;
          Exit;
        end;

        (* incomplete multibyte char *)
        if i >= srcLen then
        begin
          if Assigned(invalid) then
            invalid^ := src + i - 2;
          Exit;
        end;

        wc := (wc shl 6) or (c and $3F);
      end;

      c := PByte(src + i)^;
      Inc(i);

      if c and $C0 <> $80 then
      begin
        if Assigned(invalid) then
          invalid^ := src + i - 3;
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
  if Assigned(invalid) then
    invalid^ := nil;

  while src^ <> #0 do
  begin
    wc := PByte(src)^;
    Inc(src);

    if wc and $80 <> 0 then
    begin
      (* incomplete multibyte char *)
      if src^ = #0 then
      begin
        if Assigned(invalid) then
          invalid^ := src - 1;
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
          if Assigned(invalid) then
            invalid^ := src - 2;
          Exit;
        end;

        (* incomplete multibyte char *)
        if src^ = #0 then
        begin
          if Assigned(invalid) then
            invalid^ := src - 2;
          Exit;
        end;

        wc := (wc shl 6) or (c and $3F);
      end;

      c := PByte(src)^;
      Inc(src);

      if c and $C0 <> $80 then
      begin
        if Assigned(invalid) then
          invalid^ := src - 3;
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

function UTF8DecodeBuffer(src: PAnsiChar; srcLen: Integer; invalid: PPAnsiChar): u16string;
begin
  SetLength(Result, length(src));
  SetLength(Result, UTF8DecodeBuffer(src, srcLen, PWideChar(Result), invalid));
end;

function UTF8DecodeCStr(src: PAnsiChar; invalid: PPAnsiChar): u16string;
var
  L: Integer;
  _invalid: PAnsiChar;
begin
  L := UTF8DecodeCStrTest(src, @_invalid);

  if Assigned(_invalid) then
  begin
    if Assigned(invalid) then
      invalid^ := _invalid;
    Result := '';
  end
  else
  begin
    SetLength(Result, L);
    SetLength(Result, UTF8DecodeCStr(src, PWideChar(Result), invalid));
  end;
end;

function UTF8DecodeStr(const src: RawByteString; dest: PWideChar; invalid: PPAnsiChar): Integer;
begin
  Result := UTF8DecodeBuffer(PAnsiChar(src), length(src), dest, invalid);
end;

function UTF8DecodeStr(const src: RawByteString; invalid: PPAnsiChar): u16string;
begin
  SetLength(Result, length(src));
  SetLength(Result, UTF8DecodeBuffer(PAnsiChar(src), length(src), PWideChar(Result), invalid));
end;

function WinAPI_UTF8Decode(s: PAnsiChar; len: Integer): u16string;
begin
  Result := BufToUnicode(s, len, CP_UTF8);
end;

function WinAPI_UTF8Decode(const s: RawByteString): u16string;
begin
  Result := BufToUnicode(PAnsiChar(s), length(s), CP_UTF8);
end;

function WinAPI_UTF8Decode_2bstr(const s: RawByteString): WideString;
begin
  Result := BufToBSTR(PAnsiChar(s), length(s), CP_UTF8);
end;

function RBStrIsEmpty(const s: RawByteString): Boolean;
var
  i: Integer;
begin
  Result := True;

  for i := 1 to length(s) do
  begin
    if Ord(s[i]) > 32 then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function UStrIsEmpty(const s: u16string): Boolean;
var
  i: Integer;
begin
  Result := True;

  for i := 1 to length(s) do
  begin
    if Ord(s[i]) > 32 then
    begin
      Result := False;
      Break;
    end;
  end;
end;

procedure SBC2DBCW(str: PWideChar);
begin
  while str^ <> #0 do
  begin
    if PWord(str)^ = 12288 then
      PWord(str)^ := 32
    else if (PWord(str)^ > 65280) and (PWord(str)^ < 65375) then
      PWord(str)^ := PWord(str)^ - 65248;

    Inc(str);
  end;
end;

procedure SBC2DBCW(str: PWideChar; len: Integer);
var
  i: Integer;
begin
  // $ff10 ~ $ff09:  1-9
  // $ff21 ~ $ff3a  A-Z
  // $ff41 ~ $ff5a  a-z
  for i := 0 to len - 1 do
  begin
    if PWord(str + i)^ = $3000 then
      PWord(str + i)^ := 32
    else if (PWord(str + i)^ > $ff00) and (PWord(str + i)^ < $ff5f) then
      PWord(str + i)^ := PWord(str + i)^ - ($ff00-$20);
  end;
end;

function UStrSBC2DBC(const str: u16string): u16string;
var
  i, L: Integer;
  src, dst: PWideChar;
  c: Word;
begin
  L := length(str);
  SetLength(Result, L);
  src := PWideChar(str);
  dst := PWideChar(Result);

  for i := 0 to L - 1 do
  begin
    c := PWord(src + i)^;

    if c = 12288 then
      PWord(dst + i)^ := 32
    else if (c > 65280) and (c < 65375) then
      PWord(dst + i)^ := c - 65248
    else
      PWord(dst + i)^ := c;
  end;
end;

function BStrSBC2DBC(const str: WideString): WideString;
var
  i, L: Integer;
  src, dst: PWideChar;
  c: Word;
begin
  L := length(str);
  SetLength(Result, L);
  src := PWideChar(str);
  dst := PWideChar(Result);

  for i := 0 to L - 1 do
  begin
    c := PWord(src + i)^;

    if c = 12288 then
      PWord(dst + i)^ := 32
    else if (c > 65280) and (c < 65375) then
      PWord(dst + i)^ := c - 65248
    else
      PWord(dst + i)^ := c;
  end;
end;

procedure DBC2SBCW(str: PWideChar);
begin
  while str^ <> #0 do
  begin
    if PWord(str)^ = 32 then
      PWord(str)^ := 12288
    else if (PWord(str)^ > 32) and (PWord(str)^ < 127) then
      PWord(str)^ := PWord(str)^ + 65248;

    Inc(str);
  end;
end;

procedure DBC2SBCW(str: PWideChar; len: Integer);
var
  i: Integer;
begin
  for i := 0 to len - 1 do
  begin
    if PWord(str + i)^ = 32 then
      PWord(str + i)^ := 12288
    else if (PWord(str + i)^ > 32) and (PWord(str + i)^ < 127) then
      PWord(str + i)^ := PWord(str + i)^ + 65248;
  end;
end;

function UStrDBC2SBC(const str: u16string): u16string;
var
  i, L: Integer;
  src, dst: PWideChar;
  c: Word;
begin
  L := length(str);
  SetLength(Result, L);
  src := PWideChar(str);
  dst := PWideChar(Result);

  for i := 0 to L - 1 do
  begin
    c := PWord(src + i)^;

    if c = 32 then
      PWord(dst + i)^ := 12288
    else if (c > 32) and (c < 127) then
      PWord(dst + i)^ := c + 65248
    else
      PWord(dst + i)^ := c;
  end;
end;

function BStrDBC2SBC(const str: WideString): WideString;
var
  i, L: Integer;
  src, dst: PWideChar;
  c: Word;
begin
  L := length(str);
  SetLength(Result, L);
  src := PWideChar(str);
  dst := PWideChar(Result);

  for i := 0 to L - 1 do
  begin
    c := PWord(src + i)^;

    if c = 32 then
      PWord(dst + i)^ := 12288
    else if (c > 32) and (c < 127) then
      PWord(dst + i)^ := c + 65248
    else
      PWord(dst + i)^ := c;
  end;
end;

function GetHexNumberA(c: AnsiChar): Integer; inline;
begin
  case c of
    '0' .. '9':
      Result := Integer(c) - Ord('0');
    'a' .. 'f':
      Result := 10 + Integer(c) - Ord('a');
    'A' .. 'F':
      Result := 10 + Integer(c) - Ord('A');
  else
    Result := -1;
  end;
end;

function cstrUnescapeA(src: PAnsiChar; dst: PAnsiChar; dstLen: Integer; pUnescaped: PInteger): Integer;
var
  p: PAnsiChar;
  b1, b2, b3, nUnescaped: Integer;
  procedure append(c: AnsiChar);
  begin
    if dstLen > Result then
      dst[Result] := c;

    Inc(Result);
  end;

begin
  Result := 0;

  if pUnescaped = nil then
    pUnescaped := @nUnescaped;

  pUnescaped^ := 0;
  p := src;

  while p^ <> #0 do
  begin
    if (p^ = '\') and ((p + 1)^ <> #0) then
    begin
      case (p + 1)^ of
        'a':
          begin
            append(#7);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'b':
          begin
            append(#8);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'f':
          begin
            append(#12);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'n':
          begin
            append(#10);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'r':
          begin
            append(#13);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        't':
          begin
            append(#9);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'v':
          begin
            append(#11);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        '\':
          begin
            append('\');
            Inc(pUnescaped^);
            Inc(p, 2);
          end;

        'x':
          begin
            if (p + 2)^ = #0 then
            begin
              b1 := -1;
              b2 := -1;
            end
            else
            begin
              b1 := GetHexNumberA((p + 2)^);

              if (p + 3)^ = #0 then
                b2 := -1
              else
                b2 := GetHexNumberA((p + 3)^);
            end;

            if b1 < 0 then
            begin
              append('x');
              Inc(pUnescaped^);
              Inc(p, 2);
            end
            else if b2 < 0 then
            begin
              append(AnsiChar(b1));
              Inc(pUnescaped^);
              Inc(p, 3);
            end
            else
            begin
              append(AnsiChar(b1 shl 4 + b2));
              Inc(pUnescaped^);
              Inc(p, 4);
            end;
          end;

        '0' .. '7':
          begin
            b1 := PWord(p + 1)^ - 48;

            if (p + 2)^ = #0 then
            begin
              b2 := -1;
              b3 := -1;
            end
            else
            begin
              if ((p + 2)^ >= '0') and ((p + 2)^ <= '7') then
                b2 := PWord(p + 2)^ - 48
              else
                b2 := -1;

              if (p + 3)^ = #0 then
                b3 := -1
              else if ((p + 3)^ >= '0') and ((p + 3)^ <= '7') then
                b3 := PWord(p + 3)^ - 48
              else
                b3 := -1;
            end;

            if b2 < 0 then
            begin
              append(AnsiChar(b1));
              Inc(pUnescaped^);
              Inc(p, 2);
            end
            else if b3 < 0 then
            begin
              append(AnsiChar(b1 shl 3 + b2));
              Inc(pUnescaped^);
              Inc(p, 3);
            end
            else
            begin
              append(AnsiChar(b1 shl 6 + b2 shl 3 + b3));
              Inc(pUnescaped^);
              Inc(p, 4);
            end;
          end;

      else
        begin
          append((p + 1)^);
          Inc(p, 2);
        end;
      end;
    end
    else
    begin
      append(p^);
      Inc(p);
    end;
  end;
end;

function cstrUnescapeA(src: PAnsiChar): RawByteString;
var
  L, nEscaped: Integer;
begin
  L := cstrUnescapeA(src, nil, 0, @nEscaped);

  if nEscaped = 0 then
    SetString(Result, src, L)
  else
  begin
    SetLength(Result, L);
    cstrUnescapeA(src, PAnsiChar(Result), L, @nEscaped);
  end;
end;

function cstrUnescapeA(src: PAnsiChar; srcLen: Integer; dst: PAnsiChar; dstLen: Integer; pUnescaped: PInteger): Integer;
var
  p, last: PAnsiChar;
  b1, b2, b3, nUnescaped: Integer;
  procedure append(c: AnsiChar);
  begin
    if dstLen > Result then
      dst[Result] := c;

    Inc(Result);
  end;

begin
  Result := 0;
  p := src;
  last := src + srcLen;
  if pUnescaped = nil then
    pUnescaped := @nUnescaped;

  pUnescaped^ := 0;

  while p < last do
  begin
    if (p^ = '\') and (p < last - 1) then
    begin
      case (p + 1)^ of
        'a':
          begin
            append(#7);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'b':
          begin
            append(#8);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'f':
          begin
            append(#12);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'n':
          begin
            append(#10);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'r':
          begin
            append(#13);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        't':
          begin
            append(#9);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'v':
          begin
            append(#11);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        '\':
          begin
            append('\');
            Inc(pUnescaped^);
            Inc(p, 2);
          end;

        'x':
          begin
            if p = last - 2 then
            begin
              b1 := -1;
              b2 := -1;
            end
            else
            begin
              b1 := GetHexNumberA((p + 2)^);

              if p = last - 3 then
                b2 := -1
              else
                b2 := GetHexNumberA((p + 3)^);
            end;

            if b1 < 0 then
            begin
              append('x');
              Inc(pUnescaped^);
              Inc(p, 2);
            end
            else if b2 < 0 then
            begin
              append(AnsiChar(b1));
              Inc(pUnescaped^);
              Inc(p, 3);
            end
            else
            begin
              append(AnsiChar(b1 shl 4 + b2));
              Inc(pUnescaped^);
              Inc(p, 4);
            end;
          end;

        '0' .. '7':
          begin
            b1 := PByte(p + 1)^ - 48;

            if p = last - 2 then
            begin
              b2 := -1;
              b3 := -1;
            end
            else
            begin
              if ((p + 2)^ >= '0') and ((p + 2)^ <= '7') then
                b2 := PByte(p + 2)^ - 48
              else
                b2 := -1;

              if p = last - 3 then
                b3 := -1
              else if ((p + 3)^ >= '0') and ((p + 3)^ <= '7') then
                b3 := PByte(p + 3)^ - 48
              else
                b3 := -1;
            end;

            if b2 < 0 then
            begin
              append(AnsiChar(b1));
              Inc(pUnescaped^);
              Inc(p, 2);
            end
            else if b3 < 0 then
            begin
              append(AnsiChar(b1 shl 3 + b2));
              Inc(pUnescaped^);
              Inc(p, 3);
            end
            else
            begin
              append(AnsiChar(b1 shl 6 + b2 shl 3 + b3));
              Inc(pUnescaped^);
              Inc(p, 4);
            end;
          end;

      else
        begin
          append((p + 1)^);
          Inc(p, 2);
        end;
      end;
    end
    else
    begin
      append(p^);
      Inc(p);
    end;
  end;
end;

function cstrUnescapeA(src: PAnsiChar; srcLen: Integer): RawByteString;
var
  L, nEscaped: Integer;
begin
  L := cstrUnescapeA(src, srcLen, nil, 0, @nEscaped);

  if nEscaped = 0 then
    SetString(Result, src, srcLen)
  else
  begin
    SetLength(Result, L);
    cstrUnescapeA(src, srcLen, PAnsiChar(Result), L, @nEscaped);
  end;
end;

function cstrUnescape(const s: RawByteString): RawByteString;
var
  L, nEscaped: Integer;
begin
  L := cstrUnescapeA(PAnsiChar(s), length(s), nil, 0, @nEscaped);

  if nEscaped = 0 then
    Result := s
  else
  begin
    SetLength(Result, L);
    cstrUnescapeA(PAnsiChar(s), length(s), PAnsiChar(Result), L, @nEscaped);
  end;
end;

function GetHexNumberW(c: WideChar): Integer; inline;
begin
  case c of
    '0' .. '9':
      Result := Integer(c) - Ord('0');
    'a' .. 'f':
      Result := 10 + Integer(c) - Ord('a');
    'A' .. 'F':
      Result := 10 + Integer(c) - Ord('A');
  else
    Result := -1;
  end;
end;

function cstrUnescapeW(src: PWideChar; dst: PWideChar; dstLen: Integer; pUnescaped: PInteger): Integer;
var
  p: PWideChar;
  b1, b2, b3, nUnescaped: Integer;
  procedure append(c: WideChar);
  begin
    if dstLen > Result then
      dst[Result] := c;

    Inc(Result);
  end;

begin
  Result := 0;

  if pUnescaped = nil then
    pUnescaped := @nUnescaped;

  pUnescaped^ := 0;

  p := src;

  while p^ <> #0 do
  begin
    if (p^ = '\') and ((p + 1)^ <> #0) then
    begin
      case (p + 1)^ of
        'a':
          begin
            append(#7);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'b':
          begin
            append(#8);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'f':
          begin
            append(#12);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'n':
          begin
            append(#10);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'r':
          begin
            append(#13);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        't':
          begin
            append(#9);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'v':
          begin
            append(#11);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        '\':
          begin
            append('\');
            Inc(pUnescaped^);
            Inc(p, 2);
          end;

        'x':
          begin
            if (p + 2)^ = #0 then
            begin
              b1 := -1;
              b2 := -1;
            end
            else
            begin
              b1 := GetHexNumberW((p + 2)^);

              if (p + 3)^ = #0 then
                b2 := -1
              else
                b2 := GetHexNumberW((p + 3)^);
            end;

            if b1 < 0 then
            begin
              append('x');
              Inc(pUnescaped^);
              Inc(p, 2);
            end
            else if b2 < 0 then
            begin
              append(WideChar(b1));
              Inc(pUnescaped^);
              Inc(p, 3);
            end
            else
            begin
              append(WideChar(b1 shl 4 + b2));
              Inc(pUnescaped^);
              Inc(p, 4);
            end;
          end;

        '0' .. '7':
          begin
            b1 := PWord(p + 1)^ - 48;

            if (p + 2)^ = #0 then
            begin
              b2 := -1;
              b3 := -1;
            end
            else
            begin
              if ((p + 2)^ >= '0') and ((p + 2)^ <= '7') then
                b2 := PWord(p + 2)^ - 48
              else
                b2 := -1;

              if (p + 3)^ = #0 then
                b3 := -1
              else if ((p + 3)^ >= '0') and ((p + 3)^ <= '7') then
                b3 := PWord(p + 3)^ - 48
              else
                b3 := -1;
            end;

            if b2 < 0 then
            begin
              append(WideChar(b1));
              Inc(pUnescaped^);
              Inc(p, 2);
            end
            else if b3 < 0 then
            begin
              append(WideChar(b1 shl 3 + b2));
              Inc(pUnescaped^);
              Inc(p, 3);
            end
            else
            begin
              append(WideChar(b1 shl 6 + b2 shl 3 + b3));
              Inc(pUnescaped^);
              Inc(p, 4);
            end;
          end;

      else
        begin
          append((p + 1)^);
          Inc(p, 2);
        end;
      end;
    end
    else
    begin
      append(p^);
      Inc(p);
    end;
  end;
end;

function cstrUnescapeW(src: PWideChar): u16string;
var
  L, nUnescaped: Integer;
begin
  L := cstrUnescapeW(src, nil, 0, @nUnescaped);

  if nUnescaped = 0 then
    SetString(Result, src, L)
  else
  begin
    SetLength(Result, L);
    cstrUnescapeW(src, PWideChar(Result), L, @nUnescaped);
  end;
end;

function cstrUnescapeW(src: PWideChar; srcLen: Integer; dst: PWideChar; dstLen: Integer; pUnescaped: PInteger): Integer;
var
  p, last: PWideChar;
  b1, b2, b3, nUnescaped: Integer;
  procedure append(c: WideChar);
  begin
    if dstLen > Result then
      dst[Result] := c;

    Inc(Result);
  end;

begin
  Result := 0;

  if pUnescaped = nil then
    pUnescaped := @nUnescaped;

  pUnescaped^ := 0;

  p := src;
  last := src + srcLen;

  while p < last do
  begin
    if (p^ = '\') and (p < last - 1) then
    begin
      case (p + 1)^ of
        'a':
          begin
            append(#7);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'b':
          begin
            append(#8);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'f':
          begin
            append(#12);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'n':
          begin
            append(#10);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'r':
          begin
            append(#13);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        't':
          begin
            append(#9);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        'v':
          begin
            append(#11);
            Inc(pUnescaped^);
            Inc(p, 2);
          end;
        '\':
          begin
            append('\');
            Inc(pUnescaped^);
            Inc(p, 2);
          end;

        'x':
          begin
            if p = last - 2 then
            begin
              b1 := -1;
              b2 := -1;
            end
            else
            begin
              b1 := GetHexNumberW((p + 2)^);

              if p = last - 3 then
                b2 := -1
              else
                b2 := GetHexNumberW((p + 3)^);
            end;

            if b1 < 0 then
            begin
              append('x');
              Inc(pUnescaped^);
              Inc(p, 2);
            end
            else if b2 < 0 then
            begin
              append(WideChar(b1));
              Inc(pUnescaped^);
              Inc(p, 3);
            end
            else
            begin
              append(WideChar(b1 shl 4 + b2));
              Inc(pUnescaped^);
              Inc(p, 4);
            end;
          end;

        '0' .. '7':
          begin
            b1 := PWord(p + 1)^ - 48;

            if p = last - 2 then
            begin
              b2 := -1;
              b3 := -1;
            end
            else
            begin
              if ((p + 2)^ >= '0') and ((p + 2)^ <= '7') then
                b2 := PWord(p + 2)^ - 48
              else
                b2 := -1;

              if p = last - 3 then
                b3 := -1
              else if ((p + 3)^ >= '0') and ((p + 3)^ <= '7') then
                b3 := PWord(p + 3)^ - 48
              else
                b3 := -1;
            end;

            if b2 < 0 then
            begin
              append(WideChar(b1));
              Inc(pUnescaped^);
              Inc(p, 2);
            end
            else if b3 < 0 then
            begin
              append(WideChar(b1 shl 3 + b2));
              Inc(pUnescaped^);
              Inc(p, 3);
            end
            else
            begin
              append(WideChar(b1 shl 6 + b2 shl 3 + b3));
              Inc(pUnescaped^);
              Inc(p, 4);
            end;
          end;

      else
        begin
          append((p + 1)^);
          Inc(p, 2);
        end;
      end;
    end
    else
    begin
      append(p^);
      Inc(p);
    end;
  end;
end;

function cstrUnescapeW(src: PWideChar; srcLen: Integer): u16string;
var
  L, nEscaped: Integer;
begin
  L := cstrUnescapeW(src, srcLen, nil, 0, @nEscaped);

  if nEscaped = 0 then
    SetString(Result, src, srcLen)
  else
  begin
    SetLength(Result, L);
    cstrUnescapeW(src, srcLen, PWideChar(Result), L, @nEscaped);
  end;
end;

function cstrUnescape(const s: u16string): u16string;
var
  L, nEscaped: Integer;
begin
  L := cstrUnescapeW(PWideChar(s), length(s), nil, 0, @nEscaped);

  if nEscaped = 0 then
    Result := s
  else
  begin
    SetLength(Result, L);
    cstrUnescapeW(PWideChar(s), length(s), PWideChar(Result), L, @nEscaped);
  end;
end;

function StrUpperW(str: PWideChar): PWideChar; overload;
var
  ch: WideChar;
begin
  Result := str;

  while str^ <> #0 do
  begin
    ch := str^;

    if (ch >= 'a') and (ch <= 'z') then
      str^ := WideChar(Ord(ch) - 32);

    Inc(str);
  end;
end;

function StrUpperW(str: PWideChar; len: Integer): PWideChar;
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

  Result := str;
end;

procedure UStrUpper(const str: u16string);
begin
  StrUpperW(PWideChar(str), length(str));
end;

procedure BStrUpper(const str: WideString);
begin
  StrUpperW(PWideChar(str), length(str));
end;

function StrLowerW(str: PWideChar): PWideChar;
var
  ch: WideChar;
begin
  Result := str;

  while str^ <> #0 do
  begin
    ch := str^;

    if (ch >= 'A') and (ch <= 'Z') then
      str^ := WideChar(Ord(ch) + 32);

    Inc(str);
  end;
end;

function StrLowerW(str: PWideChar; len: Integer): PWideChar;
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

  Result := str;
end;

procedure UStrLower(const str: u16string);
begin
  StrLowerW(PWideChar(str), length(str));
end;

procedure BStrLower(const str: WideString);
begin
  StrLowerW(PWideChar(str), length(str));
end;

function StrUpperA(str: PAnsiChar): PAnsiChar;
var
  ch: AnsiChar;
begin
  Result := str;

  while str^ <> #0 do
  begin
    ch := str^;

    if (ch >= 'a') and (ch <= 'z') then
      str^ := AnsiChar(Ord(ch) - 32);

    Inc(str);
  end;
end;

function StrUpperA(str: PAnsiChar; len: Integer): PAnsiChar;
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

  Result := str;
end;

procedure RBStrUpper(const str: RawByteString);
begin
  StrUpperA(PAnsiChar(str), length(str));
end;

function StrLowerA(str: PAnsiChar): PAnsiChar;
var
  ch: AnsiChar;
begin
  Result := str;

  while str^ <> #0 do
  begin
    ch := str^;

    if (ch >= 'A') and (ch <= 'Z') then
      str^ := AnsiChar(Ord(ch) + 32);

    Inc(str);
  end;
end;

function StrLowerA(str: PAnsiChar; len: Integer): PAnsiChar;
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

  Result := str;
end;

function RBStrLower(const str: RawByteString): RawByteString;
begin
  StrLowerA(PAnsiChar(str), length(str));
  Result := str;
end;

procedure SetRBStr(var s: RawByteString; _begin, _end: PAnsiChar);
begin
  if not Assigned(_begin) or not Assigned(_end) or (_end <= _begin) then
    s := ''
  else
    SetString(s, _begin, _end - _begin);
end;

procedure SetUString(var s: u16string; _begin, _end: PWideChar);
begin
  if not Assigned(_begin) or not Assigned(_end) or (_end <= _begin) then
    s := ''
  else
    SetString(s, _begin, _end - _begin);
end;
{$REGION 'hex transfor implementation'}

procedure ByteToHex(v: Byte; dst: PAnsiChar; UpperCase: Boolean); inline;
const
  HEXADECIMAL_CHARS: array [0 .. 31] of AnsiChar = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c',
    'd', 'e', 'f', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  h, L: Byte;
begin
  h := v shr 4;
  L := v and $0F;

  if UpperCase then
  begin
    Inc(h, 16);
    Inc(L, 16);
  end;

  dst^ := HEXADECIMAL_CHARS[h];
  dst[1] := HEXADECIMAL_CHARS[L];
end;

function MemHex(const Buffer; size: Integer; UpperCase: Boolean; delimiter: RawByteString): RawByteString;

var
  i, DelimiterLen: Integer;
  pOutput: PAnsiChar;
  pInput: PByte;
begin
  if size = 0 then
  begin
    Result := '';
    Exit;
  end;

  DelimiterLen := length(delimiter);

  SetLength(Result, size * 2 + DelimiterLen * (size - 1));
  pOutput := PAnsiChar(Result);
  pInput := PByte(@Buffer);
  ByteToHex(pInput^, pOutput, UpperCase);
  Inc(pInput);
  Inc(pOutput, 2);

  for i := 1 to size - 1 do
  begin
    if DelimiterLen > 0 then
    begin
      Move(Pointer(delimiter)^, pOutput^, DelimiterLen);
      Inc(pOutput, DelimiterLen);
    end;

    ByteToHex(pInput^, pOutput, UpperCase);
    Inc(pInput);
    Inc(pOutput, 2);
  end;
end;

function MemHex(const s: RawByteString; UpperCase: Boolean; delimiter: RawByteString): RawByteString; overload;
begin
  Result := MemHex(Pointer(s)^, length(s), UpperCase, delimiter);
end;

procedure ByteToHexW(v: Byte; dst: PWideChar; UpperCase: Boolean); inline;
const
  HEXADECIMAL_CHARS: array [0 .. 31] of WideChar = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c',
    'd', 'e', 'f', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  h, L: Byte;
begin
  h := v shr 4;
  L := v and $0F;

  if UpperCase then
  begin
    Inc(h, 16);
    Inc(L, 16);
  end;

  dst^ := HEXADECIMAL_CHARS[h];
  dst[1] := HEXADECIMAL_CHARS[L];
end;

function MemHexUStr(const Buffer; size: Integer; UpperCase: Boolean; delimiter: u16string): u16string;
const
  HEXADECIMAL_CHARS: array [0 .. 31] of WideChar = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c',
    'd', 'e', 'f', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  i, DelimiterLen: Integer;
  pOutput: PWideChar;
  pInput: PByte;
begin
  if size = 0 then
  begin
    Result := '';
    Exit;
  end;

  DelimiterLen := length(delimiter);

  SetLength(Result, size * 2 + DelimiterLen * (size - 1));
  pOutput := PWideChar(Result);
  pInput := PByte(@Buffer);

  ByteToHexW(pInput^, pOutput, UpperCase);
  Inc(pInput);
  Inc(pOutput, 2);

  for i := 1 to size - 1 do
  begin
    if DelimiterLen > 0 then
    begin
      Move(Pointer(delimiter)^, pOutput^, DelimiterLen * 2);
      Inc(pOutput, DelimiterLen);
    end;

    ByteToHexW(pInput^, pOutput, UpperCase);
    Inc(pInput);
    Inc(pOutput, 2);
  end;
end;

function MemHexUStr(const s: RawByteString; UpperCase: Boolean; delimiter: u16string): u16string;
begin
  Result := MemHexUStr(Pointer(s)^, length(s), UpperCase, delimiter);
end;

function hexValue(ch: AnsiChar): Byte;
begin
  case ch of
    '0' .. '9':
      Result := Byte(ch) and $0F;
    'a' .. 'f', 'A' .. 'F':
      Result := Byte(ch) and $0F + 9;
  else
    Result := $FF;
  end;
end;

function hexValue(ch: WideChar): Byte;
begin
  case ch of
    '0' .. '9':
      Result := Word(ch) and $0F;
    'a' .. 'f', 'A' .. 'F':
      Result := Word(ch) and $0F + 9;
  else
    Result := $FF;
  end;
end;

function isHexSymbol(ch: AnsiChar): Boolean; inline;
begin
  Result := ch in ['0' .. '9', 'A' .. 'Z', 'a' .. 'z'];
end;

function HexDecodeTest(hex: PAnsiChar; hexLen: Integer): Integer; inline;
var
  i: Integer;
begin
  Result := -1;
  if hexLen mod 2 = 0 then
  begin
    for i := 0 to hexLen - 1 do
      if not isHexSymbol(hex[i]) then
        Exit;
    Result := hexLen shr 1;
  end;
end;

function HexDecode(hex: PAnsiChar; hexLen: Integer; var buf): Integer;
var
  i: Integer;
  P1, P2: Byte;
begin
  Result := -1;
  if hexLen mod 2 = 0 then
  begin
    for i := 0 to hexLen shr 1 - 1 do
    begin
      P1 := hexValue(hex[i * 2]);
      if P1 = $FF then
        Exit;
      P2 := hexValue(hex[i * 2 + 1]);
      if P2 = $FF then
        Exit;

      PAnsiChar(@buf)[i] := AnsiChar(P1 shl 4 + P2);
    end;
    Result := hexLen shr 1;
  end;
end;

function HexDecode(const hex: RawByteString; var buf): Integer;
begin
  Result := HexDecode(PAnsiChar(hex), length(hex), buf);
end;

function HexDecode(hex: PAnsiChar; hexLen: Integer): RawByteString;
var
  L: Integer;
begin
  Result := '';
  L := HexDecodeTest(hex, hexLen);

  if L > 0 then
  begin
    SetLength(Result, L);
    HexDecode(hex, hexLen, Pointer(Result)^);
  end;
end;

function HexDecode(const hex: RawByteString): RawByteString;
var
  hexLen, L: Integer;
begin
  Result := '';
  hexLen := length(hex);
  L := HexDecodeTest(PAnsiChar(hex), hexLen);
  if L > 0 then
  begin
    SetLength(Result, L);
    HexDecode(PAnsiChar(hex), hexLen, Pointer(Result)^);
  end;
end;

function HexDecodeExTest(hex: PAnsiChar; hexLen: Integer): Integer; inline;
var
  n: Integer;
  p, end1, end2: PAnsiChar;
begin
  n := 0;
  end1 := hex + hexLen;
  end2 := end1 - 1;
  p := hex;

  while p < end2 do
  begin
    while (p < end2) and not isHexSymbol(p^) do
      Inc(p);

    if (p = end2) or not isHexSymbol(p[1]) then
      Break;
    Inc(n);
    Inc(p, 2);
  end;

  if p = end1 then
    Result := n
  else
    Result := -1;
end;

function HexDecodeEx(hex: PAnsiChar; hexLen: Integer; var buf): Integer;
var
  n: Integer;
  p, end1, end2: PAnsiChar;
  P1, P2: Byte;
begin
  n := 0;
  end1 := hex + hexLen;
  end2 := end1 - 1;
  p := hex;

  while p < end2 do
  begin
    while (p < end2) and not isHexSymbol(p^) do
      Inc(p);

    if (p = end2) or not isHexSymbol(p[1]) then
      Break;

    P1 := hexValue(p[0]);
    P2 := hexValue(p[1]);

    PAnsiChar(@buf)[n] := AnsiChar(P1 shl 4 + P2);

    Inc(n);
    Inc(p, 2);
  end;

  if p = end1 then
    Result := n
  else
    Result := -1;
end;

function HexDecodeEx(const hex: RawByteString; var buf): Integer;
begin
  Result := HexDecodeEx(PAnsiChar(hex), length(hex), buf);
end;

function HexDecodeEx(hex: PAnsiChar; hexLen: Integer): RawByteString;
var
  L: Integer;
begin
  Result := '';
  L := HexDecodeExTest(hex, hexLen);

  if L > 0 then
  begin
    SetLength(Result, L);
    HexDecodeEx(hex, hexLen, Pointer(Result)^);
  end;
end;

function HexDecodeEx(const hex: RawByteString): RawByteString;
var
  hexLen, L: Integer;
begin
  Result := '';
  hexLen := length(hex);
  L := HexDecodeExTest(PAnsiChar(hex), hexLen);
  if L > 0 then
  begin
    SetLength(Result, L);
    HexDecodeEx(PAnsiChar(hex), hexLen, Pointer(Result)^);
  end;
end;

function mixedHexDecode(hex: PAnsiChar; hexLen: Integer): RawByteString;
const
  SHexBegin: array [0 .. 3] of AnsiChar = ('h', 'e', 'x', '<');
  SHexEnd: array [0 .. 0] of AnsiChar = ('>');
var
  sec, prefix, suffix: TAnsiCharSection;
  P1, P2: PAnsiChar;
  tmp: RawByteString;
begin
  Result := '';
  sec._end := hex + hexLen;
  prefix._begin := SHexBegin;
  prefix._end := prefix._begin + Length(SHexBegin);
  suffix._begin := SHexEnd;
  suffix._end := suffix._begin + 1;
  P1 := hex;
  while P1 < sec._end do
  begin
    sec._begin := P1;
    P2 := sec.ipos(prefix);

    if P2 = nil then
    begin
      SetString(tmp, P1, sec._end - P1);
      Result := Result + tmp;
      Break;
    end;

    SetString(tmp, P1, P2 - P1);
    Result := Result + tmp;
    Inc(P2, 4);
    P1 := P2;

    while (P2 < sec._end) and (P2^ <> '>') do
      Inc(P2);

    if P2 = sec._end then
    begin
      Dec(P1, 4);
      SetString(tmp, P1, P2 - P1);
      Result := Result + tmp;
      Break;
    end
    else
    begin
      Result := Result + HexDecodeEx(P1, P2 - P1);
      P1 := P2 + 1;
    end;
  end;
end;

function mixedHexDecode(const hex: RawByteString): RawByteString;
begin
  Result := mixedHexDecode(PAnsiChar(hex), length(hex));
end;
{$ENDREGION}

{$REGION 'string <=> number implementation'}

procedure _calcInt(isNegative: Boolean; s: PAnsiChar; len: Integer; var number: TNumber);
var
  c, c2: UInt32;
  UI64: UInt64;
  len2: Integer;
  function _(pch: PAnsiChar; i: Integer): UInt32; inline;
  begin
    Result := UInt32(pch[i]) and $0F;
  end;

begin
  if len < 10 then
  begin
    number._type := numInt32;
    c := 0;
    case len of
      1:
        c := _(s, 0);
      2:
        c := _(s, 0) * 10 + _(s, 1);
      3:
        c := _(s, 0) * 100 + _(s, 1) * 10 + _(s, 2);
      4:
        c := _(s, 0) * 1000 + _(s, 1) * 100 + _(s, 2) * 10 + _(s, 3);
      5:
        c := _(s, 0) * 10000 + _(s, 1) * 1000 + _(s, 2) * 100 + _(s, 3) * 10 + _(s, 4);
      6:
        c := _(s, 0) * 100000 + _(s, 1) * 10000 + _(s, 2) * 1000 + _(s, 3) * 100 + _(s, 4) * 10 + _(s, 5);
      7:
        c := _(s, 0) * 1000000 + _(s, 1) * 100000 + _(s, 2) * 10000 + _(s, 3) * 1000 + _(s, 4) * 100 + _(s, 5) * 10 + _
          (s, 6);
      8:
        c := _(s, 0) * 10000000 + _(s, 1) * 1000000 + _(s, 2) * 100000 + _(s, 3) * 10000 + _(s, 4) * 1000 + _(s, 5)
          * 100 + _(s, 6) * 10 + _(s, 7);
      9:
        c := _(s, 0) * 100000000 + _(s, 1) * 10000000 + _(s, 2) * 1000000 + _(s, 3) * 100000 + _(s, 4) * 10000 + _(s,
          5) * 1000 + _(s, 6) * 100 + _(s, 7) * 10 + _(s, 8);
    end;
    if isNegative then
      number.I32 := -c
    else
      number.I32 := c;
    Exit;
  end;

  c := _(s, 0) * 100000000 + _(s, 1) * 10000000 + _(s, 2) * 1000000 + _(s, 3) * 100000 + _(s, 4) * 10000 + _(s, 5)
    * 1000 + _(s, 6) * 100 + _(s, 7) * 10 + _(s, 8);

  Inc(s, 9);
  Dec(len, 9);
  if (c < High(UInt32) div 10) or ((c = High(UInt32) div 10) and (s[0] = '5')) then
  begin
    c := c * 10 + _(s, 0);
    Inc(s);
    Dec(len);

    if len = 0 then
    begin
      if isNegative then
      begin
        if c > UInt32( High(Int32)) + 1 then
          number.setInt64(-Int64(c))
        else
          number.setInt32(-c);
      end
      else
        number.setUInt32(c);
      Exit;
    end;
  end;

  UI64 := UInt64(c);
  len2 := len;
  case len of
    0:
      c2 := 0;
    1:
      c2 := _(s, 0);
    2:
      c2 := _(s, 0) * 10 + _(s, 1);
    3:
      c2 := _(s, 0) * 100 + _(s, 1) * 10 + _(s, 2);
    4:
      c2 := _(s, 0) * 1000 + _(s, 1) * 100 + _(s, 2) * 10 + _(s, 3);
    5:
      c2 := _(s, 0) * 10000 + _(s, 1) * 1000 + _(s, 2) * 100 + _(s, 3) * 10 + _(s, 4);
    6:
      c2 := _(s, 0) * 100000 + _(s, 1) * 10000 + _(s, 2) * 1000 + _(s, 3) * 100 + _(s, 4) * 10 + _(s, 5);
    7:
      c2 := _(s, 0) * 1000000 + _(s, 1) * 100000 + _(s, 2) * 10000 + _(s, 3) * 1000 + _(s, 4) * 100 + _(s, 5) * 10 + _
        (s, 6);
    8:
      c2 := _(s, 0) * 10000000 + _(s, 1) * 1000000 + _(s, 2) * 100000 + _(s, 3) * 10000 + _(s, 4) * 1000 + _(s, 5)
        * 100 + _(s, 6) * 10 + _(s, 7);
  else
    c2 := _(s, 0) * 100000000 + _(s, 1) * 10000000 + _(s, 2) * 1000000 + _(s, 3) * 100000 + _(s, 4) * 10000 + _(s, 5)
      * 1000 + _(s, 6) * 100 + _(s, 7) * 10 + _(s, 8);
    len2 := 9;
    if (len > 9) and ((c2 < High(UInt32) div 10) or ((c2 = High(UInt32) div 10) and (s[9] = '5'))) then
    begin
      c2 := c2 * 10 + _(s, 9);
      Inc(len2);
    end;
  end;
  Inc(s, len2);
  Dec(len, len2);
  UI64 := UI64 * INT64_TABLE[len2] + c2;

  if len > 0 then
  begin
    case len of
      1:
        c2 := _(s, 0);
      2:
        c2 := _(s, 0) * 10 + _(s, 1);
    end;
    UI64 := UI64 * INT64_TABLE[len] + c2;
  end;

  if isNegative then
    number.setInt64(-UI64)
  else
    number.setUInt64(UI64);
end;

function parseNumber(s: PAnsiChar; endAt: PPAnsiChar): TNumber;
var
  isNegative, expNegative: Boolean;
  p, firstDigit, pNonZeroFrac, pDigits, intEnd, fracBegin, fracEnd: PAnsiChar;
  maxIntBits, exponent, len, len2, i, n: Integer;
  c: UInt32;
  mantissa: array [0 .. 14] of AnsiChar;
label lbl_exit, lbl_exp, lbl_float, lbl_int, lbl_power;
begin
  Result.clear;

  if s = nil then
  begin
    P := s;
    goto lbl_exit;
  end;

  s := GotoNextNotSpace(s);
  p := s;
  isNegative := False;
  expNegative := False;
  maxIntBits := 20; // UInt64
  exponent := 0;

  if p^ = '+' then
    Inc(p)
  else if p^ = '-' then
  begin
    isNegative := True;
    maxIntBits := 19;
    Inc(p);
  end;

  firstDigit := p;

  while p^ = '0' do
    Inc(p);

  pDigits := p;

  while UInt32(p^) - 48 <= 9 do
    Inc(p);

  intEnd := p;

  if p^ = '.' then
  begin
    Inc(p);
    fracBegin := p;

    while p^ = '0' do
      Inc(p);

    pNonZeroFrac := p;

    while UInt32(p^) - 48 <= 9 do
      Inc(p);
    fracEnd := p;
    if fracEnd = firstDigit + 1 then
      goto lbl_exit;

    if (pNonZeroFrac = fracEnd) and (pDigits = intEnd) then
    begin
      Result.setInt32(0);
      goto lbl_exit;
    end;

    if (p^ = 'e') or (p^ = 'E') then
      goto lbl_exp;
    goto lbl_float;
  end
  else
  begin
    if p = firstDigit then
      goto lbl_exit;
    fracBegin := p;
    fracEnd := p;
    pNonZeroFrac := p;
    if (p^ = 'e') or (p^ = 'E') then
      goto lbl_exp;
    goto lbl_float;
  end;

lbl_exp :
  Inc(p);
  if p^ = '+' then
    Inc(p)
  else if p^ = '-' then
  begin
    expNegative := True;
    Inc(p);
  end;

  while p^ = '0' do
    Inc(p);

  while True do
  begin
    c := UInt32(p^) - 48;
    if c <= 9 then
    begin
      exponent := exponent * 10 + Integer(c);
      Inc(p);
    end
    else
      Break;
  end;

lbl_float :
  len := intEnd - pDigits;
  if (exponent = 0) and (pNonZeroFrac = fracEnd) and (len <= maxIntBits) then
    goto lbl_int;
  if expNegative then
    exponent := -exponent;

  if len > 0 then
  begin
    if len > length(mantissa) then
    begin
      Inc(exponent, len - length(mantissa));
      len := length(mantissa);
    end;
    for i := 0 to len - 1 do
      mantissa[i] := pDigits[i];

    len2 := length(mantissa) - len;

    if len2 > fracEnd - fracBegin then
      len2 := fracEnd - fracBegin;

    for i := 0 to len2 - 1 do
      mantissa[len + i] := fracBegin[i];
    Inc(len, len2);
    Dec(exponent, len2);
  end
  else
  begin
    len := fracEnd - pNonZeroFrac;
    if len > length(mantissa) then
      len := length(mantissa);
    for i := 0 to len - 1 do
      mantissa[i] := pNonZeroFrac[i];
    Dec(exponent, pNonZeroFrac - fracBegin + len);
  end;
  n := len - 1;
  while mantissa[n] = '0' do
    Dec(n);
  Inc(exponent, len - n - 1);

  _calcInt(isNegative, mantissa, n + 1, Result);

  if exponent <> 0 then
    Result.setExtended(Power10(Result.toExtended, exponent));

  goto lbl_exit;

lbl_int :
  _calcInt(isNegative, pDigits, intEnd - pDigits, Result);

lbl_exit :
  if Assigned(endAt) then
    endAt^ := p;
end;

function parseNumber(s: PAnsiChar; slen: Integer; endAt: PPAnsiChar): TNumber;
var
  isNegative, expNegative: Boolean;
  send, p, firstDigit, pNonZeroFrac, pDigits, intEnd, fracBegin, fracEnd: PAnsiChar;
  maxIntBits, exponent, len, len2, i, n: Integer;
  c: UInt32;
  mantissa: array [0 .. 14] of AnsiChar;
label lbl_exit, lbl_exp, lbl_float, lbl_int, lbl_power;
begin
  Result.clear;
  if (s = nil) or (slen <= 0) then
  begin
    P := s;
    goto lbl_exit;
  end;

  send := s + slen;
  while (s < send) and (UInt32(s^) - 1 < 32) do
    Inc(s);
  p := s;
  if s = send then
    goto lbl_exit;

  fracBegin := s;
  fracEnd := s;
  pNonZeroFrac := s;
  isNegative := False;
  expNegative := False;
  maxIntBits := 20; // UInt64
  exponent := 0;

  if p^ = '+' then
    Inc(p)
  else if p^ = '-' then
  begin
    isNegative := True;
    maxIntBits := 19;
    Inc(p);
  end;

  firstDigit := p;

  while (p < send) and (p^ = '0') do
    Inc(p);

  pDigits := p;

  while (p < send) and (UInt32(p^) - 48 <= 9) do
    Inc(p);

  intEnd := p;

  if p = send then
    goto lbl_float;

  if p^ = '.' then
  begin
    Inc(p);
    fracBegin := p;

    while (p < send) and (p^ = '0') do
      Inc(p);

    pNonZeroFrac := p;

    while (p < send) and (UInt32(p^) - 48 <= 9) do
      Inc(p);
    fracEnd := p;
    if fracEnd = firstDigit + 1 then
      goto lbl_exit;

    if (pNonZeroFrac = fracEnd) and (pDigits = intEnd) then
    begin
      Result.setInt32(0);
      goto lbl_exit;
    end;

    if (p < send) and ((p^ = 'e') or (p^ = 'E')) then
      goto lbl_exp;

    goto lbl_float;
  end
  else
  begin
    if p = firstDigit then
      goto lbl_exit;
    if (p^ = 'e') or (p^ = 'E') then
      goto lbl_exp;
    goto lbl_float;
  end;

lbl_exp :
  Inc(p);
  if p = send then
    goto lbl_float;

  if p^ = '+' then
    Inc(p)
  else if p^ = '-' then
  begin
    expNegative := True;
    Inc(p);
  end;

  while (p < send) and (p^ = '0') do
    Inc(p);

  while p < send do
  begin
    c := UInt32(p^) - 48;
    if c <= 9 then
    begin
      exponent := exponent * 10 + Integer(c);
      Inc(p);
    end
    else
      Break;
  end;

lbl_float :
  len := intEnd - pDigits;
  if (exponent = 0) and (pNonZeroFrac = fracEnd) and (len <= maxIntBits) then
    goto lbl_int;

  if expNegative then
    exponent := -exponent;

  if len > 0 then
  begin
    if len > length(mantissa) then
    begin
      Inc(exponent, len - length(mantissa));
      len := length(mantissa);
    end;
    for i := 0 to len - 1 do
      mantissa[i] := pDigits[i];

    len2 := length(mantissa) - len;

    if len2 > fracEnd - fracBegin then
      len2 := fracEnd - fracBegin;

    for i := 0 to len2 - 1 do
      mantissa[len + i] := fracBegin[i];
    Inc(len, len2);
    Dec(exponent, len2);
  end
  else
  begin
    len := fracEnd - pNonZeroFrac;
    if len > length(mantissa) then
      len := length(mantissa);
    for i := 0 to len - 1 do
      mantissa[i] := pNonZeroFrac[i];
    Dec(exponent, pNonZeroFrac - fracBegin + len);
  end;
  n := len - 1;
  while mantissa[n] = '0' do
    Dec(n);
  Inc(exponent, len - n - 1);

  _calcInt(isNegative, mantissa, n + 1, Result);
  if exponent <> 0 then
    Result.setExtended(Power10(Result.toExtended, exponent));
  goto lbl_exit;

lbl_int :
  _calcInt(isNegative, pDigits, intEnd - pDigits, Result);

lbl_exit :
  if Assigned(endAt) then
    endAt^ := p;
end;

procedure _calcInt(isNegative: Boolean; s: PWideChar; len: Integer; var number: TNumber);
var
  c, c2: UInt32;
  UI64: UInt64;
  len2: Integer;
  function _(pch: PWideChar; i: Integer): UInt32; inline;
  begin
    Result := UInt32(pch[i]) and $0F;
  end;

begin
  if len < 10 then
  begin
    number._type := numInt32;
    c := 0;
    case len of
      1:
        c := _(s, 0);
      2:
        c := _(s, 0) * 10 + _(s, 1);
      3:
        c := _(s, 0) * 100 + _(s, 1) * 10 + _(s, 2);
      4:
        c := _(s, 0) * 1000 + _(s, 1) * 100 + _(s, 2) * 10 + _(s, 3);
      5:
        c := _(s, 0) * 10000 + _(s, 1) * 1000 + _(s, 2) * 100 + _(s, 3) * 10 + _(s, 4);
      6:
        c := _(s, 0) * 100000 + _(s, 1) * 10000 + _(s, 2) * 1000 + _(s, 3) * 100 + _(s, 4) * 10 + _(s, 5);
      7:
        c := _(s, 0) * 1000000 + _(s, 1) * 100000 + _(s, 2) * 10000 + _(s, 3) * 1000 + _(s, 4) * 100 + _(s, 5) * 10 + _
          (s, 6);
      8:
        c := _(s, 0) * 10000000 + _(s, 1) * 1000000 + _(s, 2) * 100000 + _(s, 3) * 10000 + _(s, 4) * 1000 + _(s, 5)
          * 100 + _(s, 6) * 10 + _(s, 7);
      9:
        c := _(s, 0) * 100000000 + _(s, 1) * 10000000 + _(s, 2) * 1000000 + _(s, 3) * 100000 + _(s, 4) * 10000 + _(s,
          5) * 1000 + _(s, 6) * 100 + _(s, 7) * 10 + _(s, 8);
    end;
    if isNegative then
      number.I32 := -c
    else
      number.I32 := c;
    Exit;
  end;

  c := _(s, 0) * 100000000 + _(s, 1) * 10000000 + _(s, 2) * 1000000 + _(s, 3) * 100000 + _(s, 4) * 10000 + _(s, 5)
    * 1000 + _(s, 6) * 100 + _(s, 7) * 10 + _(s, 8);

  Inc(s, 9);
  Dec(len, 9);
  if (c < High(UInt32) div 10) or ((c = High(UInt32) div 10) and (s[0] = '5')) then
  begin
    c := c * 10 + _(s, 0);
    Inc(s);
    Dec(len);

    if len = 0 then
    begin
      if isNegative then
      begin
        if c > UInt32( High(Int32)) + 1 then
          number.setInt64(-Int64(c))
        else
          number.setInt32(-c);
      end
      else
        number.setUInt32(c);
      Exit;
    end;
  end;

  UI64 := UInt64(c);
  len2 := len;
  case len of
    0:
      c2 := 0;
    1:
      c2 := _(s, 0);
    2:
      c2 := _(s, 0) * 10 + _(s, 1);
    3:
      c2 := _(s, 0) * 100 + _(s, 1) * 10 + _(s, 2);
    4:
      c2 := _(s, 0) * 1000 + _(s, 1) * 100 + _(s, 2) * 10 + _(s, 3);
    5:
      c2 := _(s, 0) * 10000 + _(s, 1) * 1000 + _(s, 2) * 100 + _(s, 3) * 10 + _(s, 4);
    6:
      c2 := _(s, 0) * 100000 + _(s, 1) * 10000 + _(s, 2) * 1000 + _(s, 3) * 100 + _(s, 4) * 10 + _(s, 5);
    7:
      c2 := _(s, 0) * 1000000 + _(s, 1) * 100000 + _(s, 2) * 10000 + _(s, 3) * 1000 + _(s, 4) * 100 + _(s, 5) * 10 + _
        (s, 6);
    8:
      c2 := _(s, 0) * 10000000 + _(s, 1) * 1000000 + _(s, 2) * 100000 + _(s, 3) * 10000 + _(s, 4) * 1000 + _(s, 5)
        * 100 + _(s, 6) * 10 + _(s, 7);
  else
    c2 := _(s, 0) * 100000000 + _(s, 1) * 10000000 + _(s, 2) * 1000000 + _(s, 3) * 100000 + _(s, 4) * 10000 + _(s, 5)
      * 1000 + _(s, 6) * 100 + _(s, 7) * 10 + _(s, 8);
    len2 := 9;
    if (len > 9) and ((c2 < High(UInt32) div 10) or ((c2 = High(UInt32) div 10) and (s[9] = '5'))) then
    begin
      c2 := c2 * 10 + _(s, 9);
      Inc(len2);
    end;
  end;
  Inc(s, len2);
  Dec(len, len2);
  UI64 := UI64 * INT64_TABLE[len2] + c2;

  if len > 0 then
  begin
    case len of
      1:
        c2 := _(s, 0);
      2:
        c2 := _(s, 0) * 10 + _(s, 1);
    end;
    UI64 := UI64 * INT64_TABLE[len] + c2;
  end;

  if isNegative then
    number.setInt64(-UI64)
  else
    number.setUInt64(UI64);
end;

function parseNumber(s: PWideChar; endAt: PPWideChar): TNumber;
var
  isNegative, expNegative: Boolean;
  p, firstDigit, pNonZeroFrac, pDigits, intEnd, fracBegin, fracEnd: PWideChar;
  maxIntBits, exponent, len, len2, i, n: Integer;
  c: UInt32;
  mantissa: array [0 .. 14] of WideChar;
label lbl_exit, lbl_exp, lbl_float, lbl_int, lbl_power;
begin
  Result.clear;
  if s = nil then
  begin
    P := s;
    goto lbl_exit;
  end;
  s := GotoNextNotSpace(s);
  p := s;
  isNegative := False;
  expNegative := False;
  maxIntBits := 20; // UInt64
  exponent := 0;

  if p^ = '+' then
    Inc(p)
  else if p^ = '-' then
  begin
    isNegative := True;
    maxIntBits := 19;
    Inc(p);
  end;

  firstDigit := p;

  while p^ = '0' do
    Inc(p);

  pDigits := p;

  while UInt32(p^) - 48 <= 9 do
    Inc(p);

  intEnd := p;

  if p^ = '.' then
  begin
    Inc(p);
    fracBegin := p;

    while p^ = '0' do
      Inc(p);

    pNonZeroFrac := p;

    while UInt32(p^) - 48 <= 9 do
      Inc(p);
    fracEnd := p;
    if fracEnd = firstDigit + 1 then
      goto lbl_exit;

    if (pNonZeroFrac = fracEnd) and (pDigits = intEnd) then
    begin
      Result.setInt32(0);
      goto lbl_exit;
    end;

    if (p^ = 'e') or (p^ = 'E') then
      goto lbl_exp;
    goto lbl_float;
  end
  else
  begin
    if p = firstDigit then
      goto lbl_exit;
    fracBegin := p;
    fracEnd := p;
    pNonZeroFrac := p;
    if (p^ = 'e') or (p^ = 'E') then
      goto lbl_exp;
    goto lbl_float;
  end;

lbl_exp :
  Inc(p);
  if p^ = '+' then
    Inc(p)
  else if p^ = '-' then
  begin
    expNegative := True;
    Inc(p);
  end;

  while p^ = '0' do
    Inc(p);

  while True do
  begin
    c := UInt32(p^) - 48;
    if c <= 9 then
    begin
      exponent := exponent * 10 + Integer(c);
      Inc(p);
    end
    else
      Break;
  end;

lbl_float :
  len := intEnd - pDigits;
  if (exponent = 0) and (pNonZeroFrac = fracEnd) and (len <= maxIntBits) then
    goto lbl_int;
  if expNegative then
    exponent := -exponent;

  if len > 0 then
  begin
    if len > length(mantissa) then
    begin
      Inc(exponent, len - length(mantissa));
      len := length(mantissa);
    end;
    for i := 0 to len - 1 do
      mantissa[i] := pDigits[i];

    len2 := length(mantissa) - len;

    if len2 > fracEnd - fracBegin then
      len2 := fracEnd - fracBegin;

    for i := 0 to len2 - 1 do
      mantissa[len + i] := fracBegin[i];
    Inc(len, len2);
    Dec(exponent, len2);
  end
  else
  begin
    len := fracEnd - pNonZeroFrac;
    if len > length(mantissa) then
      len := length(mantissa);
    for i := 0 to len - 1 do
      mantissa[i] := pNonZeroFrac[i];
    Dec(exponent, pNonZeroFrac - fracBegin + len);
  end;
  n := len - 1;
  while mantissa[n] = '0' do
    Dec(n);
  Inc(exponent, len - n - 1);

  _calcInt(isNegative, mantissa, n + 1, Result);
  if exponent <> 0 then
    Result.setExtended(Power10(Result.toExtended, exponent));
  goto lbl_exit;

lbl_int :
  _calcInt(isNegative, pDigits, intEnd - pDigits, Result);

lbl_exit :
  if Assigned(endAt) then
    endAt^ := p;
end;

function parseNumber(s: PWideChar; slen: Integer; endAt: PPWideChar): TNumber;
var
  isNegative, expNegative: Boolean;
  send, p, firstDigit, pNonZeroFrac, pDigits, intEnd, fracBegin, fracEnd: PWideChar;
  maxIntBits, exponent, len, len2, i, n: Integer;
  c: UInt32;
  mantissa: array [0 .. 14] of WideChar;
label lbl_exit, lbl_exp, lbl_float, lbl_int, lbl_power;
begin
  Result.clear;
  if (s = nil) or (slen <= 0) then
  begin
    P := s;
    goto lbl_exit;
  end;
  send := s + slen;
  while (s < send) and (UInt32(s^) - 1 < 32) do
    Inc(s);
  p := s;
  if s = send then
    goto lbl_exit;

  fracBegin := s;
  fracEnd := s;
  pNonZeroFrac := s;
  isNegative := False;
  expNegative := False;
  maxIntBits := 20; // UInt64
  exponent := 0;

  if p^ = '+' then
    Inc(p)
  else if p^ = '-' then
  begin
    isNegative := True;
    maxIntBits := 19;
    Inc(p);
  end;

  firstDigit := p;

  while (p < send) and (p^ = '0') do
    Inc(p);

  pDigits := p;

  while (p < send) and (UInt32(p^) - 48 <= 9) do
    Inc(p);

  intEnd := p;

  if p = send then
    goto lbl_float;

  if p^ = '.' then
  begin
    Inc(p);
    fracBegin := p;

    while (p < send) and (p^ = '0') do
      Inc(p);

    pNonZeroFrac := p;

    while (p < send) and (UInt32(p^) - 48 <= 9) do
      Inc(p);
    fracEnd := p;
    if fracEnd = firstDigit + 1 then
      goto lbl_exit;

    if (pNonZeroFrac = fracEnd) and (pDigits = intEnd) then
    begin
      Result.setInt32(0);
      goto lbl_exit;
    end;

    if (p < send) and ((p^ = 'e') or (p^ = 'E')) then
      goto lbl_exp;

    goto lbl_float;
  end
  else
  begin
    if p = firstDigit then
      goto lbl_exit;
    if (p^ = 'e') or (p^ = 'E') then
      goto lbl_exp;
    goto lbl_float;
  end;

lbl_exp :
  Inc(p);
  if p = send then
    goto lbl_float;

  if p^ = '+' then
    Inc(p)
  else if p^ = '-' then
  begin
    expNegative := True;
    Inc(p);
  end;

  while (p < send) and (p^ = '0') do
    Inc(p);

  while p < send do
  begin
    c := UInt32(p^) - 48;
    if c <= 9 then
    begin
      exponent := exponent * 10 + Integer(c);
      Inc(p);
    end
    else
      Break;
  end;

lbl_float :
  len := intEnd - pDigits;
  if (exponent = 0) and (pNonZeroFrac = fracEnd) and (len <= maxIntBits) then
    goto lbl_int;

  if expNegative then
    exponent := -exponent;

  if len > 0 then
  begin
    if len > length(mantissa) then
    begin
      Inc(exponent, len - length(mantissa));
      len := length(mantissa);
    end;
    for i := 0 to len - 1 do
      mantissa[i] := pDigits[i];

    len2 := length(mantissa) - len;

    if len2 > fracEnd - fracBegin then
      len2 := fracEnd - fracBegin;

    for i := 0 to len2 - 1 do
      mantissa[len + i] := fracBegin[i];
    Inc(len, len2);
    Dec(exponent, len2);
  end
  else
  begin
    len := fracEnd - pNonZeroFrac;
    if len > length(mantissa) then
      len := length(mantissa);
    for i := 0 to len - 1 do
      mantissa[i] := pNonZeroFrac[i];
    Dec(exponent, pNonZeroFrac - fracBegin + len);
  end;
  n := len - 1;
  while mantissa[n] = '0' do
    Dec(n);
  Inc(exponent, len - n - 1);

  _calcInt(isNegative, mantissa, n + 1, Result);
  if exponent <> 0 then
    Result.setExtended(Power10(Result.toExtended, exponent));
  goto lbl_exit;

lbl_int :
  _calcInt(isNegative, pDigits, intEnd - pDigits, Result);

lbl_exit :
  if Assigned(endAt) then
    endAt^ := p;
end;

function IntToStrFast(value: UInt; s: PAnsiChar): PAnsiChar;
var
  buf: array [0..11] of AnsiChar;
  p: PAnsiChar;
  i, len: Integer;
begin
  p := StrInt(buf + High(buf), value);
  len := buf + High(buf) - p;
  for i := 0 to len - 1 do
    s[i] := p[i];
  Result := s + len;
end;
(*
var
  remainder, quotient: UInt32;
begin
  while True do
  begin
    case value of
      0 .. 9:
        begin
          Dec(s);
          s^ := AnsiChar(value + $30);
          Break;
        end;
      10 .. High(_0to99A):
        begin
          Dec(s, 2);
          PWord(s)^ := PWord(_0to99A[value])^;
          Break;
        end;
    end;

    asm
      push eax
      push edx
      mov eax, value
      mov  edx, 1374389535 // use power of two reciprocal to avoid division
      mul  edx
      shr  edx, 5          // now edx=eax div 100
      mov  quotient, edx
      pop edx
      pop eax
    end;

    remainder := value - quotient * 100;

    Dec(s, 2);
    case remainder of
      0 .. 9:
        PWord(s)^ := (remainder + $30) shl 8 + $30;
    else
      PWord(s)^ := PWord(_0to99A[remainder])^;
    end;
    value := quotient;
  end;
  Result := s;
end;
*)

function IntToStrFast(value: Int32; s: PAnsiChar): PAnsiChar;
begin
  if value < 0 then
  begin
    Result := IntToStrFast(UInt32(-value), s + 1);
    s^ := '-';
  end
  else
    Result := IntToStrFast(UInt32(value), s);
end;

function IntToStrFast(value: UInt32; s: PWideChar): PWideChar;
var
  buf: array [0..11] of WideChar;
  p: PWideChar;
  i, len: Integer;
begin
  p := StrInt(buf + High(buf), value);
  len := buf + High(buf) - p;
  for i := 0 to len - 1 do
    s[i] := p[i];
  Result := s + len;
end;

function IntToStrFast(value: Int32; s: PWideChar): PWideChar;
begin
  if value < 0 then
  begin
    Result := IntToStrFast(UInt32(-value), s + 1);
    s^ := '-';
  end
  else
    Result := IntToStrFast(UInt32(value), s);
end;

function IntToStrFast(value: UInt64; s: PAnsiChar): PAnsiChar;
var
  buf: array [0..21] of AnsiChar;
  p: PAnsiChar;
  i, len: Integer;
begin
  p := StrInt(buf + High(buf), value);
  len := buf + High(buf) - p;
  for i := 0 to len - 1 do
    s[i] := p[i];
  Result := s + len;
end;

function IntToStrFast(value: Int64; s: PAnsiChar): PAnsiChar;
begin
  if value < 0 then
  begin
    Result := IntToStrFast(UInt64(-value), s + 1);
    s^ := '-';
  end
  else
    Result := IntToStrFast(UInt64(value), s);
end;

function IntToStrFast(value: UInt64; s: PWideChar): PWideChar;
var
  buf: array [0..21] of WideChar;
  p: PWideChar;
  i, len: Integer;
begin
  p := StrInt(buf + High(buf), value);
  len := buf + High(buf) - p;
  for i := 0 to len - 1 do
    s[i] := p[i];
  Result := s + len;
end;

function IntToStrFast(value: Int64; s: PWideChar): PWideChar;
begin
  if value < 0 then
  begin
    Result := IntToStrFast(UInt64(-value), s + 1);
    s^ := '-';
  end
  else
    Result := IntToStrFast(UInt64(value), s);
end;

function IntToUTF16Str(value: Int32): UTF16String;
var
  buf: array [0..11] of WideChar;
  p: PWideChar;
begin
  if (value >= Low(_0to99UStr)) and (value <= High(_0to99UStr)) then
    _fastAssignStr(Result, _0to99UStr[value])
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToWideStr(value: Int32): WideString;
var
  buf: array [0..11] of WideChar;
  p: PWideChar;
begin
  if (value >= Low(_0to99UStr)) and (value <= High(_0to99UStr)) then
    Result := _0to99UStr[value]  //
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToRawBytes(value: Int32): RawByteString;
var
  buf: array [0..11] of AnsiChar;
  p: PAnsiChar;
begin
  if (value >= Low(_0to99A)) and (value <= High(_0to99A)) then
    _fastAssignStr(Result, _0to99A[value])
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToStrFast(value: Int32): string;
begin
{$IF SizeOf(Char) = 1}
  Result := IntToRawBytes(value);
{$ELSE}
  Result := IntToUTF16Str(value);
{$IFEND}
end;

function IntToUTF16Str(value: UInt32): UTF16String;
var
  buf: array [0..11] of WideChar;
  p: PWideChar;
  L: Integer;
begin
  if value <= High(_0to99UStr) then
    _fastAssignStr(Result, _0to99UStr[value])
  else begin
    p := StrInt(buf+High(buf), value);
    L := buf+High(buf)-p;
    SetString(Result, p, L);
  end;
end;

function IntToWideStr(value: UInt32): WideString;
var
  buf: array [0..11] of WideChar;
  p: PWideChar;
begin
  if value <= High(_0to99UStr) then
    Result := _0to99UStr[value]
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToRawBytes(value: UInt32): RawByteString;
var
  buf: array [0..11] of AnsiChar;
  p: PAnsiChar;
begin
  if value <= High(_0to99A) then
    _fastAssignStr(Result, _0to99A[value])
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToStrFast(value: UInt32): string;
begin
{$IF SizeOf(Char) = 1}
  Result := IntToRawBytes(value);
{$ELSE}
  Result := IntToUTF16Str(value);
{$IFEND}
end;

function IntToUTF16Str(value: Int64): UTF16String;
var
  buf: array [0..21] of WideChar;
  p: PWideChar;
begin
  if (value >= Low(_0to99UStr)) and (value <= High(_0to99UStr)) then
    _fastAssignStr(Result, _0to99UStr[value])
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToWideStr(value: Int64): WideString;
var
  buf: array [0..21] of WideChar;
  p: PWideChar;
begin
  if (value >= Low(_0to99UStr)) and (value <= High(_0to99UStr)) then
    Result := _0to99UStr[value]
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToRawBytes(value: Int64): RawByteString;
var
  buf: array [0..21] of AnsiChar;
  p: PAnsiChar;
begin
  if (value >= Low(_0to99A)) and (value <= High(_0to99A)) then
    _fastAssignStr(Result, _0to99A[value])
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToStrFast(value: Int64): string;
begin
{$IF SizeOf(Char) = 1}
  Result := IntToRawBytes(value);
{$ELSE}
  Result := IntToUTF16Str(value);
{$IFEND}
end;

function IntToUTF16Str(value: UInt64): UTF16String;
var
  buf: array [0..21] of WideChar;
  p: PWideChar;
begin
  if value <= High(_0to99UStr) then
    _fastAssignStr(Result, _0to99UStr[value])
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToWideStr(value: UInt64): WideString;
var
  buf: array [0..21] of WideChar;
  p: PWideChar;
begin
  if value <= High(_0to99UStr) then
    Result := _0to99UStr[value]
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToRawBytes(value: UInt64): RawByteString;
var
  buf: array [0..21] of AnsiChar;
  p: PAnsiChar;
begin
  if value <= High(_0to99UStr) then
    _fastAssignStr(Result, _0to99A[value])
  else begin
    p := StrInt(buf+High(buf), value);
    SetString(Result, p, buf+High(buf)-p);
  end;
end;

function IntToStrFast(value: UInt64): string;
begin
{$IF SizeOf(Char) = 1}
  Result := IntToRawBytes(value);
{$ELSE}
  Result := IntToUTF16Str(value);
{$IFEND}
end;

{$IFDEF USE_RTL_POW10}
function Power10(const mantissa: Extended; exponent: Integer): Extended;
asm
  fld mantissa
  call System.@Pow10
  fstp Result
end;
{$ELSE}
var
  POWER10_TABLE: array [0 .. 4932] of Extended;

procedure initPower10Table;
var
  i: Integer;
  exp: Extended;
begin
  exp := 1;
  POWER10_TABLE[0] := 1;
  for i := Low(POWER10_TABLE) + 1 to High(POWER10_TABLE) do
  begin
    exp := exp * 10;
    POWER10_TABLE[i] := exp;
  end;
end;

function Power10(mantissa: Extended; exponent: Integer): Extended;
begin
  Result := mantissa;
  if exponent > 0 then
  begin
    while exponent > High(POWER10_TABLE) do
    begin
      Result := Result * POWER10_TABLE[ High(POWER10_TABLE)];
      Dec(exponent, High(POWER10_TABLE));
    end;
    if exponent <> 0 then
      Result := Result * POWER10_TABLE[exponent];
  end
  else if exponent < 0 then
  begin
    exponent := -exponent;
    while exponent > High(POWER10_TABLE) do
    begin
      Result := Result / POWER10_TABLE[ High(POWER10_TABLE)];
      Dec(exponent, High(POWER10_TABLE));
    end;
    if exponent <> 0 then
      Result := Result / POWER10_TABLE[exponent];
  end;
end;
{$ENDIF}

{ TNumber }

function TNumber.ceil: Int64;
begin
  case _type of
    numInt32:
      Result := I32;
    numUInt32:
      Result := UI32;
    numInt64:
      Result := I64;
    numUInt64:
      Result := UI64;
    numDouble:
      Result := Math.Ceil(VDouble);
    numExtended:
      Result := Math.Ceil(VExtended);
  else
    Result := 0;
  end;
end;

procedure TNumber.clear;
begin
  _type := numNaN;
end;

function TNumber.expr: string;
begin
  case _type of
    numNaN:
      Result := '(NaN)';
    numInt32:
      Result := '(int32): ' + IntToStrFast(I32);
    numUInt32:
      Result := '(uint32): ' + IntToStrFast(UI32);
    numInt64:
      Result := '(int64): ' + IntToStrFast(I64);
    numUInt64:
      Result := '(uint64): ' + IntToStrFast(UI64);
    numDouble:
      Result := '(float): ' + FloatToStr(VDouble);
    numExtended:
      Result := '(extended): ' + FloatToStr(VExtended);
  else
    Result := '(unknown)';
  end;
end;

function TNumber.isFloat: Boolean;
begin
  Result := _type in [numDouble, numExtended];
end;

function TNumber.isInteger: Boolean;
begin
  Result := _type in [numInt32 .. numUInt64];
end;

function TNumber.isNegative: Boolean;
begin
  case _type of
    numInt32:
      Result := I32 < 0;
    numInt64:
      Result := I64 < 0;
    numDouble:
      Result := VDouble < 0;
    numExtended:
      Result := VExtended < 0;
  else
    Result := False
  end;
end;

function TNumber.isPositive: Boolean;
begin
  case _type of
    numInt32:
      Result := I32 >= 0;
    numInt64:
      Result := I64 >= 0;
    numDouble:
      Result := VDouble >= 0;
    numExtended:
      Result := VExtended >= 0;
    numUInt32, numUInt64:
      Result := True;
  else
    Result := False
  end;
end;

function TNumber.round: Int64;
begin
  case _type of
    numInt32:
      Result := I32;
    numUInt32:
      Result := UI32;
    numInt64:
      Result := I64;
    numUInt64:
      Result := UI64;
    numDouble:
      Result := System.Round(VDouble);
    numExtended:
      Result := System.Round(VExtended);
  else
    Result := 0;
  end;
end;

procedure TNumber.setDouble(value: Double);
begin
  _type := numDouble;
  VDouble := value;
end;

procedure TNumber.setExtended(value: Extended);
begin
  _type := numExtended;
  VExtended := value;
end;

procedure TNumber.setInt32(value: Int32);
begin
  _type := numInt32;
  I32 := value;
end;

procedure TNumber.setInt64(value: Int64);
begin
  _type := numInt64;
  I64 := value;
end;

procedure TNumber.setUInt32(value: UInt32);
begin
  _type := numUInt32;
  UI32 := value;
end;

procedure TNumber.setUInt64(value: UInt64);
begin
  _type := numUInt64;
  UI64 := value;
end;

function TNumber.toExtended: Extended;
begin
  case _type of
    numInt32:
      Result := I32;
    numUInt32:
      Result := UI32;
    numInt64:
      Result := I64;
    numUInt64:
      Result := UI64;
    numDouble:
      Result := VDouble;
    numExtended:
      Result := VExtended;
  else
    Result := 0.0;
  end;
end;

function TNumber.toRawBytes: RawByteString;
begin
  case _type of
    numInt32:
      Result := IntToRawBytes(I32);
    numUInt32:
      Result := IntToRawBytes(UI32);
    numInt64:
      Result := IntToRawBytes(I64);
    numUInt64:
      Result := IntToRawBytes(UI64);
    numDouble:
      Result := FloatToRBStr(VDouble);
    numExtended:
      Result := FloatToRBStr(VExtended);
  else
    Result := 'NaN';
  end;
end;

function TNumber.toString: string;
begin
{$IF SizeOf(Char)=1}
  Result := Self.toRawBytes;
{$ELSE}
  Result := Self.toUTF16Str;
{$IFEND}
end;

function TNumber.asInt32: Int32;
begin
  case _type of
    numInt32:
      Result := I32;
    numUInt32:
      Result := UI32;
    numInt64:
      Result := I64;
    numUInt64:
      Result := UI64;
    numDouble:
      Result := System.Round(VDouble);
    numExtended:
      Result := System.Round(VExtended);
  else
    Result := 0;
  end;
end;

function TNumber.asUInt32: UInt32;
begin
  case _type of
    numInt32:
      Result := I32;
    numUInt32:
      Result := UI32;
    numInt64:
      Result := I64;
    numUInt64:
      Result := UI64;
    numDouble:
      Result := System.Round(VDouble);
    numExtended:
      Result := System.Round(VExtended);
  else
    Result := 0;
  end;
end;

function TNumber.toUTF16Str: UTF16String;
begin
  case _type of
    numInt32:
      Result := IntToUTF16Str(I32);
    numUInt32:
      Result := IntToUTF16Str(UI32);
    numInt64:
      Result := IntToUTF16Str(I64);
    numUInt64:
      Result := IntToUTF16Str(UI64);
    numDouble:
      Result := FloatToUStr(VDouble);
    numExtended:
      Result := FloatToUStr(VExtended);
  else
    Result := 'NaN';
  end;
end;

function TNumber.trunc: Int64;
begin
  case _type of
    numInt32:
      Result := I32;
    numUInt32:
      Result := UI32;
    numInt64:
      Result := I64;
    numUInt64:
      Result := UI64;
    numDouble:
      Result := System.Trunc(VDouble);
    numExtended:
      Result := System.Trunc(VExtended);
  else
    Result := 0;
  end;
end;

function TNumber.tryGetInt(var value: Int64): Boolean;
begin
  Result := True;
  case _type of
    numInt32:
      value := I32;
    numUInt32:
      value := UI32;
    numInt64:
      value := I64;
    numUInt64:
      value := UI64;
  else
    Result := False;
  end;
end;

function TNumber.valid: Boolean;
begin
  Result := _type <> numNaN;
end;

function divBy100(dividend: Int32): Int32;
asm
  mov  edx, 1374389535 // use power of two reciprocal to avoid division
  mul  edx
  shr  edx, 5          // now edx=eax div 100
  mov  eax, edx
end;

function StrInt(s: PAnsiChar; value: UInt32): PAnsiChar;
asm     // eax=P, edx=val
        push    edi
        mov     edi, eax
        mov     eax, edx
        cmp     eax, 10
        jb      @below10
@s:     cmp     eax, 100
        lea     edi, [edi - 2]
        jb      @below100
        mov     ecx, eax
        mov     edx, 1374389535 // use power of two reciprocal to avoid division
        mul     edx
        shr     edx, 5          // now edx=eax div 100
        mov     eax, edx
        imul    edx, -400
        mov     edx, dword ptr[_0to99A + ecx * 4 + edx]
        mov     dx, word ptr [edx]
        test    dx, $ff00
        jnz     @4write2char
        shl     dx, 8
        or      dx, $30
@4write2char:
        mov     [edi], dx
        cmp     eax, 10
        jae     @s
        jmp     @below10
@below100:
        mov     eax, dword ptr[_0to99A + eax * 4]
        mov     ax, word ptr [eax]
        mov     [edi], ax
        jmp     @ret
@below10:
        dec     edi
        or      al, '0'
        mov     [edi], al
@ret:
        mov     eax, edi
        pop     edi
end;

function StrInt(s: PAnsiChar; const value: UInt64): PAnsiChar;
var
  c, c100: UInt64;
  remaider: Int32;
begin
  if Int64Rec(value).Hi = 0 then
    s := StrInt(s, UInt32(Int64Rec(value).Lo))
  else begin
    c := value;
    while True do
    begin
      asm // by-passing the RTL is a good idea here
        push    ebx
        mov     edx, dword ptr[c + 4]
        mov     eax, dword ptr[c]
        mov     ebx, 100
        mov     ecx, eax
        mov     eax, edx
        xor     edx, edx
        div     ebx
        mov     dword ptr[c100 + 4], eax
        xchg    eax, ecx
        div     ebx
        mov     dword ptr[c100], eax
        imul    ebx, ecx
        mov     ecx, 100
        mul     ecx
        add     edx, ebx
        pop     ebx
        sub     dword ptr[c + 4], edx
        sbb     dword ptr[c], eax
      end;
      Dec(s, 2);
      remaider := PInt32(@c)^;

      if remaider < 10 then
        PWord(s)^ := (remaider + $30) shl 8 + $30
      else
        PWord(s)^ := PWord(_0to99A[remaider])^;
      c := c100;
      if Int64Rec(c).Hi = 0 then
      begin
        if Int64Rec(c).Lo <> 0 then
          s := StrInt(s, UInt32(Int64Rec(c).Lo));
        Break;
      end;
    end;
  end;
  Result := s;
end;

function StrInt(s: PWideChar; value: UInt32): PWideChar;
asm     // eax=s, edx=val
        push    edi
        mov     edi, eax
        mov     eax, edx
        cmp     eax, 10
        jb      @below10
@s:     cmp     eax, 100
        lea     edi, [edi - 4]
        jb      @below100
        mov     ecx, eax
        mov     edx, 1374389535 // use power of two reciprocal to avoid division
        mul     edx
        shr     edx, 5          // now edx=eax div 100
        mov     eax, edx
        imul    edx, -400
        mov     edx, dword ptr[_0to99UStr + ecx * 4 + edx]
        mov     edx, dword ptr [edx]
        test    edx, $ffff0000  // 0 to 9, need add a left-padding 0
        jnz     @write2char
        shl     edx, 16
        or      edx, $30
@write2char:
        mov     [edi], edx
        cmp     eax, 10
        jae     @s
        jmp     @below10
@below100:
        mov     eax, dword ptr[_0to99UStr + eax * 4]
        mov     eax, dword ptr [eax]
        mov     [edi], eax
        jmp     @ret
@below10:
        lea     edi, [edi - 2]
        or      ax, '0'
        mov     [edi], ax
@ret:
        mov     eax, edi
        pop     edi
end;

function StrInt(s: PWideChar; const value: UInt64): PWideChar;
var
  c, c100: UInt64;
  remaider: Int32;
begin
  if Int64Rec(value).Hi = 0 then
    s := StrInt(s, UInt32(Int64Rec(value).Lo))
  else begin
    c := value;
    while True do
    begin
      asm // by-passing the RTL is a good idea here
        push    ebx
        mov     edx, dword ptr[c + 4]
        mov     eax, dword ptr[c]
        mov     ebx, 100
        mov     ecx, eax
        mov     eax, edx
        xor     edx, edx
        div     ebx
        mov     dword ptr[c100 + 4], eax
        xchg    eax, ecx
        div     ebx
        mov     dword ptr[c100], eax
        imul    ebx, ecx
        mov     ecx, 100
        mul     ecx
        add     edx, ebx
        pop     ebx
        sub     dword ptr[c + 4], edx
        sbb     dword ptr[c], eax
      end;
      Dec(s, 2);
      remaider := PInt32(@c)^;

      if remaider < 10 then
        PInt32(s)^ := (remaider + $30) shl 16 + $30
      else
        PInt32(s)^ := PInt32(_0to99UStr[remaider])^;
      c := c100;
      if Int64Rec(c).Hi = 0 then
      begin
        if Int64Rec(c).Lo <> 0 then
          s := StrInt(s, UInt32(Int64Rec(c).Lo));
        Break;
      end;
    end;
  end;
  Result := s;
end;

function StrInt(s: PAnsiChar; value: Int32): PAnsiChar;
{$ifndef SIGNEDINT_TO_STR_ASM}
begin
  if value < 0 then
  begin
    Result := StrInt(s, UInt32(-value)) - 1;
    Result^ := '-';
  end
  else
    Result := StrInt(s, UInt32(value));
end;
{$else}
asm     // eax=s, edx=value
        mov     ecx, edx
        sar     ecx, 31         // 0 if val>=0 or -1 if val<0
        xor     edx, ecx
        sub     edx, ecx        // edx=abs(val)
        push    ebx
        push    edi
        mov     edi, eax
        mov     eax, edx
        cmp     edx, 10
        jb      @below10  // direct process of common val<10
@s:     lea     edi, [edi - 2]
        cmp     eax, 100
        jb      @below100
        mov     ebx, eax
        mov     edx, 1374389535 // use power of two reciprocal to avoid division
        mul     edx
        shr     edx, 5          // now edx=eax div 100
        mov     eax, edx
        imul    edx, -400
        mov     edx, dword ptr[_0to99A + ebx * 4 + edx]
        mov     dx, word ptr [edx]
        test    dx, $ff00
        jnz     @write2char
        shl     dx, 8
        or      dx, $30
@write2char:
        mov     [edi], dx
        cmp     eax, 10
        jae     @s
        jmp     @below10
@below100:
        mov     eax, dword ptr[_0to99A + eax * 4]
        mov     ax, word ptr [eax]
        mov     [edi], ax
        jmp     @ret
@below10:
        dec     edi
        or      al, '0'
        mov     [edi], al
@ret:
        test    ecx, ecx
        jz      @notneg
        dec     edi
        mov     byte ptr[edi], '-'
@notneg:
        mov     eax, edi
        pop     edi
        pop     ebx
end;
{$endif}

function StrInt(s: PAnsiChar; const value: Int64): PAnsiChar;
begin
  if value < 0 then
  begin
    Result := StrInt(s, UInt64(-value)) - 1;
    Result^ := '-';
  end
  else
    Result := StrInt(s, UInt64(value));
end;

function StrInt(s: PWideChar; value: Int32): PWideChar; overload;
{$ifndef SIGNEDINT_TO_STR_ASM}
begin
  if value < 0 then
  begin
    Result := StrInt(s, UInt32(-value)) - 1;
    Result^ := '-';
  end
  else
    Result := StrInt(s, UInt32(value));
end;
{$else}
asm     // eax=s, edx=value
        mov     ecx, edx
        sar     ecx, 31         // 0 if val>=0 or -1 if val<0
        xor     edx, ecx
        sub     edx, ecx        // edx=abs(val)
        push    ebx
        push    edi
        mov     edi, eax
        mov     eax, edx
        cmp     edx, 10
        jb      @below10  // direct process of common val<10
@s:     lea     edi, [edi - 4]
        cmp     eax, 100
        jb      @below100
        mov     ebx, eax
        mov     edx, 1374389535 // use power of two reciprocal to avoid division
        mul     edx
        shr     edx, 5          // now edx=eax div 100
        mov     eax, edx
        imul    edx, -400
        mov     edx, dword ptr[_0to99UStr + ebx * 4 + edx]
        mov     edx, dword ptr [edx]
        test    edx, $ffff0000
        jnz     @write2char
        shl     edx, 16
        or      edx, $30
@write2char:
        mov     [edi], edx
        cmp     eax, 10
        jae     @s
        jmp     @below10
@below100:
        mov     eax, dword ptr[_0to99UStr + eax * 4]
        mov     eax, dword ptr [eax]
        mov     [edi], eax
        jmp     @ret
@below10:
        lea     edi, [edi - 2]
        or      ax, '0'
        mov     [edi], ax
@ret:
        test    ecx, ecx
        jz      @notneg
        lea     edi, [edi - 2]
        mov     word ptr[edi], '-'
@notneg:
        mov     eax, edi
        pop     edi
        pop     ebx
end;
{$endif}

function StrInt(s: PWideChar; const value: Int64): PWideChar; overload;
begin
  if value < 0 then
  begin
    Result := StrInt(s, UInt64(-value)) - 1;
    Result^ := '-';
  end
  else
    Result := StrInt(s, UInt64(value));
end;

function IntToStrBufA(value: Integer; buf: PAnsiChar): Integer;
begin
  Result := IntToStrFast(value, buf) - buf;
end;

function IntToRBStr(value: Integer): RawByteString;
begin
  Result := IntToRawBytes(value);
end;

function UInt32ToStrBufA(value: UInt32; buf: PAnsiChar): Integer;
begin
  Result := IntToStrFast(value, buf) - buf;
end;

function IntToStrBufA(value: Int64; buf: PAnsiChar): Integer; overload;
begin
  Result := IntToStrFast(value, buf) - buf;
end;

function IntToRBStr(value: Int64): RawByteString;
begin
  Result := IntToRawBytes(value);
end;

function UInt64ToStrBufA(value: UInt64; buf: PAnsiChar): Integer; overload;
begin
  Result := IntToStrFast(value, buf) - buf;
end;

function UInt32ToRBStr(value: UInt32): RawByteString;
begin
  Result := IntToRawBytes(value);
end;

function UInt64ToRBStr(value: UInt64): RawByteString;
begin
  Result := IntToRawBytes(value);
end;

function IntToStrBufW(value: Integer; buf: PWideChar): Integer;
begin
  Result := IntToStrFast(value, buf) - buf;
end;

function UInt32ToStrBufW(value: UInt32; buf: PWideChar): Integer;
begin
  Result := IntToStrFast(value, buf) - buf;
end;

function IntToUStr(value: Integer): u16string;
begin
  Result := IntToUTF16Str(value);
end;

function IntToBStr(value: Integer): WideString;
begin
  Result := IntToWideStr(value);
end;

function IntToStrBufW(value: Int64; buf: PWideChar): Integer; overload;
begin
  Result := IntToStrFast(value, buf) - buf;
end;

function IntToUStr(value: Int64): u16string;
begin
  Result := IntToUTF16Str(value);
end;

function IntToBStr(value: Int64): WideString;
begin
  Result := IntToWideStr(value);
end;

function UInt64ToStrBufW(value: UInt64; buf: PWideChar): Integer;
begin
  Result := IntToStrFast(value, buf) - buf;
end;

function UInt32ToUStr(value: UInt32): u16string;
begin
  Result := IntToUTF16Str(value);
end;

function UInt64ToUStr(value: UInt64): u16string;
begin
  Result := IntToUTF16Str(value);
end;

function UInt32ToStr(value: UInt32): string;
begin
  Result := IntToUTF16Str(value);
end;

function UInt64ToStr(value: UInt64): string;
begin
  Result := IntToUTF16Str(value);
end;

function UInt32ToBStr(value: UInt32): WideString; overload;
begin
  Result := IntToWideStr(value);
end;

function UInt64ToBStr(value: UInt64): WideString; overload;
begin
  Result := IntToWideStr(value);
end;

function DecimalToUInt32A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt32;
var
  Ptr, tail: PAnsiChar;
  bit: Integer;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;
  tail := buf + len;
  Ptr := buf;

  while Ptr < tail do
  begin
    bit := Ord(Ptr^) - $30;

    if (bit >= 0) and (bit <= 9) then
      Result := Result * 10 + UInt32(bit)
    else
    begin
      if Assigned(invalid) then
        invalid^ := Ptr;
      Break;
    end;

    Inc(Ptr);
  end;
end;

function HexToUInt32A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt32;
var
  Ptr, tail: PAnsiChar;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;
  tail := buf + len;
  Ptr := buf;

  while Ptr < tail do
  begin
    case Ptr^ of
      '0' .. '9':
        Result := Result shl 4 + Ord(Ptr^) - Ord('0');
      'A' .. 'F':
        Result := Result shl 4 + Ord(Ptr^) - Ord('A') + 10;
      'a' .. 'f':
        Result := Result shl 4 + Ord(Ptr^) - Ord('a') + 10;
      ',':
        ;
    else
      begin
        if Assigned(invalid) then
          invalid^ := Ptr;
        Break;
      end;
    end;

    Inc(Ptr);
  end;
end;

function BufToIntA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Integer;
var
  sign: Integer;
begin
  Result := 0;

  if Assigned(invalid) then
    invalid^ := nil;

  if not Assigned(buf) or (len <= 0) then
    Exit;

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

  if len <= 0 then
  begin
    if Assigned(invalid) then
      invalid^ := buf;
    Exit;
  end;

  if buf[0] = '$' then
    Result := sign * Int32(HexToUInt32A(buf + 1, len - 1, invalid))
  else
    Result := sign * Int32(DecimalToUInt32A(buf, len, invalid));
end;

function RBStrToInt(const str: RawByteString): Integer;
var
  c: PAnsiChar;
begin
  Result := BufToIntA(PAnsiChar(str), length(str), @c);
end;

function RBStrToIntDef(const str: RawByteString; def: Integer): Integer;
var
  c: PAnsiChar;
begin
  Result := BufToIntA(PAnsiChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function BufToUInt32A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt32;
var
  sign: Integer;
begin
  Result := 0;

  if Assigned(invalid) then
    invalid^ := nil;

  if not Assigned(buf) or (len <= 0) then
    Exit;

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

  if len <= 0 then
  begin
    if Assigned(invalid) then
      invalid^ := buf;
    Exit;
  end;

  if sign = 1 then
  begin
    if buf[0] = '$' then
      Result := HexToUInt32A(buf + 1, len - 1, invalid)
    else
      Result := DecimalToUInt32A(buf, len, invalid);
  end
  else
  begin
    if buf[0] = '$' then
      Result := UInt32(-Int32(HexToUInt32A(buf + 1, len - 1, invalid)))
    else
      Result := UInt32(-Int32(DecimalToUInt32A(buf + 1, len - 1, invalid)));
  end;
end;

function RBStrToUInt32(const str: RawByteString): UInt32;
var
  c: PAnsiChar;
begin
  Result := BufToUInt32A(PAnsiChar(str), length(str), @c);
end;

function RBStrToUInt32Def(const str: RawByteString; def: UInt32): UInt32;
var
  c: PAnsiChar;
begin
  Result := BufToUInt32A(PAnsiChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function HexToUInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt64;
var
  Ptr, tail: PAnsiChar;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;
  tail := buf + len;
  Ptr := buf;

  while Ptr < tail do
  begin
    case Ptr^ of
      '0' .. '9':
        Result := Result shl 4 + Ord(Ptr^) - Ord('0');
      'A' .. 'F':
        Result := Result shl 4 + Ord(Ptr^) - Ord('A') + 10;
      'a' .. 'f':
        Result := Result shl 4 + Ord(Ptr^) - Ord('a') + 10;
      ',':
        ;
    else
      begin
        if Assigned(invalid) then
          invalid^ := Ptr;
        Break;
      end;
    end;

    Inc(Ptr);
  end;
end;

function DecimalToUInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt64;
var
  Ptr, tail: PAnsiChar;
  bit: Integer;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;
  tail := buf + len;
  Ptr := buf;

  while Ptr < tail do
  begin
    bit := Ord(Ptr^) - $30;

    if (bit >= 0) and (bit <= 9) then
      Result := Result * 10 + UInt64(bit)
    else
    begin
      if Assigned(invalid) then
        invalid^ := Ptr;
      Break;
    end;

    Inc(Ptr);
  end;
end;

function BufToInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Int64;
var
  sign: Int64;
begin
  Result := 0;

  if not Assigned(buf) or (len <= 0) then
    Exit;

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

  if len <= 0 then
  begin
    if Assigned(invalid) then
      invalid^ := buf;
    Exit;
  end;

  if buf[0] = '$' then
    Result := sign * Int64(HexToUInt64A(buf + 1, len - 1, invalid))
  else
    Result := sign * Int64(DecimalToUInt64A(buf, len, invalid));
end;

function RBStrToInt64(const str: RawByteString): Int64;
var
  c: PAnsiChar;
begin
  Result := BufToInt64A(PAnsiChar(str), length(str), @c);
end;

function RBStrToInt64Def(const str: RawByteString; def: Int64): Int64;
var
  c: PAnsiChar;
begin
  Result := BufToInt64A(PAnsiChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function BufToUInt64A(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): UInt64;
var
  sign: Int64;
begin
  Result := 0;

  if not Assigned(buf) or (len <= 0) then
    Exit;

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

  if len <= 0 then
  begin
    if Assigned(invalid) then
      invalid^ := buf;
    Exit;
  end;

  if sign = 1 then
  begin
    if buf[0] = '$' then
      Result := HexToUInt64A(buf + 1, len - 1, invalid)
    else
      Result := DecimalToUInt64A(buf, len, invalid);
  end
  else
  begin
    if buf[0] = '$' then
      Result := UInt64(-Int64(HexToUInt64A(buf + 1, len - 1, invalid)))
    else
      Result := UInt64(-Int64(DecimalToUInt64A(buf, len, invalid)));
  end;
end;

function RBStrToUInt64(const str: RawByteString): UInt64;
var
  c: PAnsiChar;
begin
  Result := BufToUInt64A(PAnsiChar(str), length(str), @c);
end;

function RBStrToUInt64Def(const str: RawByteString; def: UInt64): UInt64;
var
  c: PAnsiChar;
begin
  Result := BufToUInt64A(PAnsiChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function HexBufToUInt32W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt32;
var
  Ptr, tail: PWideChar;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;
  tail := buf + len;
  Ptr := buf;

  while Ptr < tail do
  begin
    case Ptr^ of
      '0' .. '9':
        Result := Result shl 4 + Ord(Ptr^) - Ord('0');
      'A' .. 'F':
        Result := Result shl 4 + Ord(Ptr^) - Ord('A') + 10;
      'a' .. 'f':
        Result := Result shl 4 + Ord(Ptr^) - Ord('a') + 10;
    else

      begin
        if Assigned(invalid) then
          invalid^ := Ptr;
        Break;
      end;
    end;

    Inc(Ptr);
  end;
end;

function DecimalBufToUInt32W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt32;
var
  Ptr, tail: PWideChar;
  bit: Integer;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;
  tail := buf + len;
  Ptr := buf;

  while Ptr < tail do
  begin
    bit := Ord(Ptr^) - $30;

    if (bit >= 0) and (bit <= 9) then
      Result := Result * 10 + UInt32(bit)
    else
    begin
      if Assigned(invalid) then
        invalid^ := Ptr;
      Break;
    end;

    Inc(Ptr);
  end;
end;

function BufToIntW(buf: PWideChar; len: Integer; invalid: PPWideChar): Integer;
var
  sign: Integer;
begin
  Result := 0;

  if Assigned(invalid) then
    invalid^ := nil;

  if not Assigned(buf) or (len <= 0) then
    Exit;

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

  if len <= 0 then
  begin
    if Assigned(invalid) then
      invalid^ := buf;
    Exit;
  end;

  if buf[0] = '$' then
    Result := sign * Int32(HexBufToUInt32W(buf + 1, len - 1, invalid))
  else
    Result := sign * Int32(DecimalBufToUInt32W(buf, len, invalid));
end;

function UStrToInt(const str: u16string): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), length(str), @c);
end;

function BStrToInt(const str: WideString): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), length(str), @c);
end;

function dslStrToInt(const str: u16string): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), length(str), @c);
end;

function dslStrToInt(const str: WideString): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), length(str), @c);
end;

function UStrToIntDef(const str: u16string; def: Integer): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function BStrToIntDef(const str: WideString; def: Integer): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function dslStrToIntDef(const str: u16string; def: Integer): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function dslStrToIntDef(const str: WideString; def: Integer): Integer;
var
  c: PWideChar;
begin
  Result := BufToIntW(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function BufToUInt32W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt32;
var
  sign: Integer;
begin
  Result := 0;

  if Assigned(invalid) then
    invalid^ := nil;

  if not Assigned(buf) or (len <= 0) then
    Exit;

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

  if len <= 0 then
  begin
    if Assigned(invalid) then
      invalid^ := buf;

    Exit;
  end;

  if sign = 1 then
  begin
    if buf[0] = '$' then
      Result := HexBufToUInt32W(buf + 1, len - 1, invalid)
    else
      Result := DecimalBufToUInt32W(buf, len, invalid);
  end
  else
  begin
    if buf[0] = '$' then
      Result := UInt32(-Int32(HexBufToUInt32W(buf + 1, len - 1, invalid)))
    else
      Result := UInt32(-Int32(DecimalBufToUInt32W(buf, len, invalid)));
  end;
end;

function UStrToUInt32(const str: u16string): UInt32;
var
  c: PWideChar;
begin
  Result := BufToUInt32W(PWideChar(str), length(str), @c);
end;

function BStrToUInt32(const str: WideString): UInt32;
var
  c: PWideChar;
begin
  Result := BufToUInt32W(PWideChar(str), length(str), @c);
end;

function dslStrToUInt32(const str: u16string): UInt32;
var
  c: PWideChar;
begin
  Result := BufToUInt32W(PWideChar(str), length(str), @c);
end;

function dslStrToUInt32(const str: WideString): UInt32;
var
  c: PWideChar;
begin
  Result := BufToUInt32W(PWideChar(str), length(str), @c);
end;

function UStrToUInt32Def(const str: u16string; def: UInt32): UInt32;
var
  c: PWideChar;
begin
  Result := BufToUInt32W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function BStrToUInt32Def(const str: WideString; def: UInt32): UInt32;
var
  c: PWideChar;
begin
  Result := BufToUInt32W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function dslStrToUInt32Def(const str: u16string; def: UInt32): UInt32;
var
  c: PWideChar;
begin
  Result := BufToUInt32W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function dslStrToUInt32Def(const str: WideString; def: UInt32): UInt32;
var
  c: PWideChar;
begin
  Result := BufToUInt32W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function HexBufToUInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt64;
var
  Ptr, tail: PWideChar;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;
  tail := buf + len;
  Ptr := buf;

  while Ptr < tail do
  begin
    case Ptr^ of
      '0' .. '9':
        Result := Result shl 4 + Ord(Ptr^) - Ord('0');
      'A' .. 'F':
        Result := Result shl 4 + Ord(Ptr^) - Ord('A') + 10;
      'a' .. 'f':
        Result := Result shl 4 + Ord(Ptr^) - Ord('a') + 10;
    else

      begin
        if Assigned(invalid) then
          invalid^ := Ptr;
        Break;
      end;
    end;

    Inc(Ptr);
  end;
end;

function DecimalBufToUInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt64;
var
  Ptr, tail: PWideChar;
  bit: Integer;
begin
  Result := 0;
  if Assigned(invalid) then
    invalid^ := nil;
  tail := buf + len;
  Ptr := buf;

  while Ptr < tail do
  begin
    bit := Ord(Ptr^) - $30;

    if (bit >= 0) and (bit <= 9) then
      Result := Result * 10 + UInt64(bit)
    else
    begin
      if Assigned(invalid) then
        invalid^ := Ptr;
      Break;
    end;

    Inc(Ptr);
  end;
end;

function BufToInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): Int64;
var
  sign: Int64;
begin
  Result := 0;

  if Assigned(invalid) then
    invalid^ := nil;

  if not Assigned(buf) or (len <= 0) then
    Exit;

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

  if len <= 0 then
  begin
    if Assigned(invalid) then
      invalid^ := buf;
    Exit;
  end;

  if buf[0] = '$' then
    Result := sign * Int64(HexBufToUInt64W(buf + 1, len - 1, invalid))
  else
    Result := sign * Int64(DecimalBufToUInt64W(buf, len, invalid));
end;

function UStrToInt64(const str: u16string): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), length(str), @c);
end;

function BStrToInt64(const str: WideString): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), length(str), @c);
end;

function dslStrToInt64(const str: u16string): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), length(str), @c);
end;

function dslStrToInt64(const str: WideString): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), length(str), @c);
end;

function BStrToInt64Def(const str: WideString; def: Int64): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function UStrToInt64Def(const str: u16string; def: Int64): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function dslStrToInt64Def(const str: WideString; def: Int64): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function dslStrToInt64Def(const str: u16string; def: Int64): Int64;
var
  c: PWideChar;
begin
  Result := BufToInt64W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function BufToUInt64W(buf: PWideChar; len: Integer; invalid: PPWideChar): UInt64;
var
  sign: Int64;
begin
  Result := 0;

  if Assigned(invalid) then
    invalid^ := nil;

  if not Assigned(buf) or (len <= 0) then
    Exit;

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

  if len <= 0 then
  begin
    if Assigned(invalid) then
      invalid^ := buf;
    Exit;
  end;

  if sign = 1 then
  begin
    if buf[0] = '$' then
      Result := HexBufToUInt64W(buf + 1, len - 1, invalid)
    else
      Result := DecimalBufToUInt64W(buf, len, invalid);
  end
  else
  begin
    if buf[0] = '$' then
      Result := UInt64(-Int64(HexBufToUInt64W(buf + 1, len - 1, invalid)))
    else
      Result := UInt64(-Int64(DecimalBufToUInt64W(buf, len, invalid)));
  end
end;

function UStrToUInt64(const str: u16string): UInt64;
var
  c: PWideChar;
begin
  Result := BufToUInt64W(PWideChar(str), length(str), @c);
end;

function BStrToUInt64(const str: WideString): UInt64;
var
  c: PWideChar;
begin
  Result := BufToUInt64W(PWideChar(str), length(str), @c);
end;

function dslStrToUInt64(const str: u16string): UInt64;
var
  c: PWideChar;
begin
  Result := BufToUInt64W(PWideChar(str), length(str), @c);
end;

function dslStrToUInt64(const str: WideString): UInt64;
var
  c: PWideChar;
begin
  Result := BufToUInt64W(PWideChar(str), length(str), @c);
end;

function BStrToUInt64Def(const str: WideString; def: UInt64): UInt64;
var
  c: PWideChar;
begin
  Result := BufToUInt64W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function UStrToUInt64Def(const str: u16string; def: UInt64): UInt64;
var
  c: PWideChar;
begin
  Result := BufToUInt64W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function dslStrToUInt64Def(const str: WideString; def: UInt64): UInt64;
var
  c: PWideChar;
begin
  Result := BufToUInt64W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function dslStrToUInt64Def(const str: u16string; def: UInt64): UInt64;
var
  c: PWideChar;
begin
  Result := BufToUInt64W(PWideChar(str), length(str), @c);

  if Assigned(c) then
    Result := def;
end;

function parseFloat(str: PAnsiChar; pErr: PPAnsiChar): Extended;
const
  TEN: Extended = 10.0;
var
  s: PAnsiChar;
  nDigit: Int32;
  nMantissa: Int32;
  digitValue: UInt32;
asm
  // in: eax=str, edx=pErr  out: result=st(0)

  // if P = nil then
  test    eax, eax
  jz      @nil

  mov     s, str              // save input str
  mov     nDigit, 0
  mov     nMantissa, 0

  // save used registers
  push    ebx
  push    esi
  push    edi

  lea     esi, [eax - 1]       // string pointer
  xor     ebx, ebx
  xor     ecx, ecx            // clear sign flag
  xor     eax, eax            // zero number of decimal places
  xor     edi, edi            // edi used for exponent
  fld     TEN                 // load 10 into fpu
  fldz                        // zero result in fpu

@trim:
  inc     esi
  movzx   ebx, byte ptr[esi]  // strip leading spaces
  cmp     bx, $20             // if bx == #32 then goto @trim
  je      @trim

  // check + or -
  sub     bx, '0'
  cmp     bx, '-' - '0'
  je      @negative
  cmp     bx, '+' - '0'
  je      @integral
  dec     esi
  jmp     @integral
@negative:
  mov     ch, 1               // set sign flag

// integral part
@integral:
  inc     esi
  movzx   ebx, byte ptr[esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @frac               // non-digit
  inc     nDigit
  cmp     nMantissa, 0
  ja      @calc_mantissa_integral
  test    ebx, ebx
  jz      @integral
@calc_mantissa_integral:
  mov     digitValue, ebx     // store for fpu use
  fmul    st(0), st(1)        // multply by 10
  fiadd   digitValue          // add next digit
  inc     nMantissa
  cmp     nMantissa, 15
  jb      @integral

@integral2:
  inc     esi
  movzx   ebx, byte ptr[esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @check_dot               // non-digit
  inc     nDigit
  inc     eax
  jnz     @integral2           // no,get next digit

@frac:
  cmp     bx, '.' - '0'
  jne     @exp                // no decimal point

@fracl:
  inc     esi
  movzx   ebx, byte ptr[esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @exp                // non-digit
  inc     nDigit
  cmp     nMantissa, 0
  ja      @calc_mantissa_frac
  test    ebx, ebx
  jz      @fracl
@calc_mantissa_frac:
  mov     digitValue, ebx
  fmul    st(0), st(1)        // multply by 10
  fiadd   digitValue          // add next digit
  dec     eax                 // -(number of decimal places)
  inc     nMantissa
  cmp     nMantissa, 15
  jb      @fracl
  jmp     @frac2

@check_dot:
  cmp     bx, '.' - '0'
  jne     @exp                // no decimal point

@frac2:
  inc     esi
  movzx   ebx, byte ptr[esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @exp                // non-digit
  inc     nDigit
  jmp     @frac2              // yes, finished (no exponent)

@exp:
  cmp     nDigit, 0
  je      @digitNotFound
  or      bx, $20             // lower case
  cmp     bx, 'e' - '0'
  jne     @exit               // not 'e' or 'e'
  inc     esi
  movzx   ebx, byte ptr[esi]  // get next char
  mov     cl, 0               // clear exponent sign flag
  cmp     bx, '-'
  je      @negative_exp
  cmp     bx, '+'
  je      @expl
  dec     esi
  jmp     @expl
@negative_exp:
  mov     cl, 1               // set exponent sign flag
  jmp     @expl

@expl:
  inc     esi
  movzx   ebx, byte ptr [esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @endexp               // non-digit
  // edi := edi * 10
  lea     edi, [edi+edi*4] // edi = 5 * edi
  add     edi, edi            // edi = edi * 2
  add     edi, ebx            // add next digit
  jmp     @expl               // no, get next digit

@endexp:
  test    cl, cl              // positive exponent?
  jz      @exit               // yes, keep exponent value
  neg     edi                 // no, negate exponent value

@exit:
  cmp     nDigit, 0
  jne     @digitFound
@digitNotFound:
  mov     esi, s
  jmp     @setEndPos

@digitFound:
  add     eax, edi            // exponent value - number of decimal places
  jz      @checksign          // no call to _pow10 needed
  push    ecx
  push    edx
  call    System.@Pow10       // raise to power of 10
  pop     edx
  pop     ecx

@checksign:
  // check sign flag
  test  ch, ch
  jz    @setEndPos
  fchs

@setEndPos:
  test    edx, edx
  jz      @1
  mov     [edx], esi          // set result code
@1:
  ffree   st(1)               // remove ten value from fpu
  pop     edi                 // restore used registers
  pop     esi
  pop     ebx
  jmp     @ret
@nil:
  fldz
  test    edx, edx
  jz      @ret
  mov     [edx], eax          // set result code
@ret:
end;

function parseFloat(str: PWideChar; pErr: PPWideChar): Extended;
const
  TEN: Extended = 10.0;
var
  s: PWideChar;
  nDigit: Int32;
  nMantissa: Int32;
  digitValue: UInt32;
asm
  // in: eax=str, edx=pErr  out: result=st(0)

  // if P = nil then
  test    eax, eax
  jz      @nil

  mov     s, str              // save input str
  mov     nDigit, 0
  mov     nMantissa, 0

  // save used registers
  push    ebx
  push    esi
  push    edi

  lea     esi, [eax - 2]       // string pointer
  xor     ebx, ebx
  xor     ecx, ecx            // clear sign flag
  xor     eax, eax            // zero number of decimal places
  xor     edi, edi            // edi used for exponent
  fld     TEN                 // load 10 into fpu
  fldz                        // zero result in fpu

@trim:
  add     esi, 2
  movzx   ebx, word ptr[esi]  // strip leading spaces
  cmp     bx, $20             // if bx == #32 then goto @trim
  je      @trim

  // check + or -
  sub     bx, '0'
  cmp     bx, '-' - '0'
  je      @negative
  cmp     bx, '+' - '0'
  je      @integral
  add     esi, -2
  jmp     @integral
@negative:
  mov     ch, 1               // set sign flag

// integral part
@integral:
  add     esi, 2
  movzx   ebx, word ptr[esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @frac               // non-digit
  inc     nDigit
  cmp     nMantissa, 0
  ja      @calc_mantissa_integral
  test    ebx, ebx
  jz      @integral
@calc_mantissa_integral:
  mov     digitValue, ebx     // store for fpu use
  fmul    st(0), st(1)        // multply by 10
  fiadd   digitValue          // add next digit
  inc     nMantissa
  cmp     nMantissa, 15
  jb      @integral

@integral2:
  add     esi, 2
  movzx   ebx, word ptr[esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @check_dot               // non-digit
  inc     nDigit
  inc     eax
  jnz     @integral2           // no,get next digit

@frac:
  cmp     bx, '.' - '0'
  jne     @exp                // no decimal point

@fracl:
  add     esi, 2
  movzx   ebx, word ptr[esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @exp                // non-digit
  inc     nDigit
  cmp     nMantissa, 0
  ja      @calc_mantissa_frac
  test    ebx, ebx
  jz      @fracl
@calc_mantissa_frac:
  mov     digitValue, ebx
  fmul    st(0), st(1)        // multply by 10
  fiadd   digitValue          // add next digit
  dec     eax                 // -(number of decimal places)
  inc     nMantissa
  cmp     nMantissa, 15
  jb      @fracl
  jmp     @frac2

@check_dot:
  cmp     bx, '.' - '0'
  jne     @exp                // no decimal point

@frac2:
  add     esi, 2
  movzx   ebx, word ptr[esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @exp                // non-digit
  inc     nDigit
  jmp     @frac2              // yes, finished (no exponent)

@exp:
  cmp     nDigit, 0
  je      @digitNotFound
  or      bx, $20             // lower case
  cmp     bx, 'e' - '0'
  jne     @exit               // not 'e' or 'e'
  add     esi, 2
  movzx   ebx, word ptr[esi]  // get next char
  mov     cl, 0               // clear exponent sign flag
  cmp     bx, '-'
  je      @negative_exp
  cmp     bx, '+'
  je      @expl
  add     esi, -2
  jmp     @expl
@negative_exp:
  mov     cl, 1               // set exponent sign flag
  jmp     @expl

@expl:
  add     esi, 2
  movzx   ebx, word ptr [esi]  // get next char
  sub     bx, '0'
  cmp     bx, 9
  ja      @endexp               // non-digit
  // edi := edi * 10
  lea     edi, [edi+edi*4] // edi = 5 * edi
  add     edi, edi            // edi = edi * 2
  add     edi, ebx            // add next digit
  jmp     @expl               // no, get next digit

@endexp:
  test    cl, cl              // positive exponent?
  jz      @exit               // yes, keep exponent value
  neg     edi                 // no, negate exponent value

@exit:
  cmp     nDigit, 0
  jne     @digitFound
@digitNotFound:
  mov     esi, s
  jmp     @setEndPos

@digitFound:
  add     eax, edi            // exponent value - number of decimal places
  jz      @checksign          // no call to _pow10 needed
  push    ecx
  push    edx
  call    System.@Pow10       // raise to power of 10
  pop     edx
  pop     ecx

@checksign:
  // check sign flag
  test  ch, ch
  jz    @setEndPos
  fchs

@setEndPos:
  test    edx, edx
  jz      @1
  mov     [edx], esi          // set result code
@1:
  ffree   st(1)               // remove ten value from fpu
  pop     edi                 // restore used registers
  pop     esi
  pop     ebx
  jmp     @ret
@nil:
  fldz
  test    edx, edx
  jz      @ret
  mov     [edx], eax          // set result code
@ret:
end;

function BufToFloatA(buf: PAnsiChar; len: Integer; invalid: PPAnsiChar): Double;
var
  i, j, decs: Integer;
  v, ratio, sign: Double;
  dot: Boolean;
begin
  Result := 0;
  v := 0;
  ratio := 1;
  decs := 0;
  dot := False;
  if Assigned(invalid) then
    invalid^ := nil;

  if len <= 0 then
    Exit;

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
  else
  begin
    sign := 1;
    j := 0;
  end;

  for i := j to len - 1 do
  begin
    if (buf[i] >= '0') and (buf[i] <= '9') then
    begin
      Inc(decs);

      if dot then
      begin
        v := v + (Ord(buf[i]) - $30) * ratio;
        ratio := ratio / 10;
      end
      else
        v := v * 10 + Ord(buf[i]) - $30;
    end
    else if buf[i] = '.' then
    begin
      if dot then
      begin
        if decs = 0 then
          invalid^ := buf + i - 1
        else
          invalid^ := buf + i;
        Break;
      end
      else
      begin
        ratio := 0.1;
        dot := True;
        decs := 0;
      end;
    end
    else if buf[i] = ',' then
      Continue
    else
    begin
      if Assigned(invalid) then
      begin
        if (decs = 0) and (i <> j) then
          invalid^ := buf + i - 1
        else
          invalid^ := buf + i;
      end;

      Break;
    end;
  end;

  Result := v * sign;
end;

function RBStrToFloat(const str: RawByteString): Double;
begin
  Result := parseFloat(PAnsiChar(Pointer(str)));
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
  if Assigned(invalid) then
    invalid^ := nil;

  if len <= 0 then
    Exit;

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
  else
  begin
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
    else if buf[i] = '.' then
    begin
      if dot then
      begin
        if Assigned(invalid) then
        begin
          if decs = 0 then
            invalid^ := buf + i - 1
          else
            invalid^ := buf + i;
        end;

        Break;
      end
      else
      begin
        dot := True;
        decs := 0;
      end;
    end
    else
    begin
      if Assigned(invalid) then
      begin
        if (decs = 0) and (i <> j) then
          invalid^ := buf + i - 1
        else
          invalid^ := buf + i;
      end;

      Break;
    end;
  end;

  Result := v * sign;

  if dot then
    for i := 0 to decs - 1 do
      Result := Result / 10;
end;

function RBStrToFloat2(const str: RawByteString): Double;
begin
  Result := parseFloat(PAnsiChar(Pointer(str)));
end;

function BufToFloatW(buf: PWideChar; len: Integer; invalid: PPWideChar): Double;
var
  i, j, decs: Integer;
  v, ratio, sign: Double;
  dot: Boolean;
begin
  Result := 0;
  v := 0;
  decs := 0;
  ratio := 1;
  dot := False;

  if Assigned(invalid) then
    invalid^ := nil;

  if len <= 0 then
    Exit;

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
  else
  begin
    sign := 1;
    j := 0;
  end;

  for i := j to len - 1 do
  begin
    if (buf[i] >= '0') and (buf[i] <= '9') then
    begin
      Inc(decs);

      if dot then
      begin
        v := v + (Ord(buf[i]) - $30) * ratio;
        ratio := ratio / 10;
      end
      else
        v := v * 10 + Ord(buf[i]) - $30;
    end
    else if buf[i] = '.' then
    begin
      if dot then
      begin
        if Assigned(invalid) then
        begin
          if decs = 0 then
            invalid^ := buf + i - 1
          else
            invalid^ := buf + i;
        end;

        Break;
      end
      else
      begin
        ratio := 0.1;
        decs := 0;
        dot := True;
      end;
    end
    else
    begin
      if Assigned(invalid) then
      begin
        if (decs = 0) and (i <> j) then
          invalid^ := buf + i - 1
        else
          invalid^ := buf + i;
      end;

      Break;
    end;
  end;

  Result := v * sign;
end;

function UStrToFloat(const str: u16string): Double;
begin
  Result := parseFloat(PWideChar(Pointer(str)));
end;

function BStrToFloat(const str: WideString): Double;
begin
  Result := parseFloat(PWideChar(Pointer(str)));
end;

function FloatToUStr(value: Extended): u16string;
begin
  Result := FloatToStr(value);
end;

function FloatToUStr(value: Extended; const FormatSettings: TFormatSettings): u16string;
begin
  Result := FloatToStr(value, FormatSettings);
end;

function FloatToRBStr(value: Extended): RawByteString;
var
  Buffer: array [0 .. 63] of AnsiChar;
begin
{$IF CompilerVersion > 22}
  SetString(Result, Buffer,  AnsiStrings.FloatToText(Buffer, value, fvExtended, ffGeneral, 15, 0));
{$ELSE}
  SetString(Result, Buffer, FloatToText(Buffer, value, fvExtended, ffGeneral, 15, 0));
{$IFEND}
end;

function FloatToRBStr(value: Extended; const FormatSettings: TFormatSettings): RawByteString;
var
  Buffer: array [0 .. 63] of AnsiChar;
begin
{$IF CompilerVersion > 22}
  SetString(Result, Buffer,  AnsiStrings.FloatToText(Buffer, value, fvExtended,
    ffGeneral, 15, 0, FormatSettings));
{$ELSE}
  SetString(Result, Buffer,  FloatToText(Buffer, value, fvExtended,
    ffGeneral, 15, 0, FormatSettings));
{$IFEND}
end;

procedure ConvertError(ResString: PResStringRec); local;
begin
  raise EConvertError.CreateRes(ResString);
end;

function FormatFloat_mb(const Format: RawByteString; Value: Extended): RawByteString;
var
  Buffer: array[0..255] of AnsiChar;
begin
  if Length(Format) > Length(Buffer) - 32 then
    ConvertError(PResStringRec(@SFormatTooLong));
  SetString(Result, Buffer, AnsiStrings.FloatToTextFmt(Buffer, Value, fvExtended,
    PAnsiChar(Format)));
end;

function FormatFloat_mb(const Format: RawByteString; Value: Extended;
  const FormatSettings: TFormatSettings): RawByteString;
var
  Buffer: array[0..255] of AnsiChar;
begin
  if Length(Format) > Length(Buffer) - 32 then
    ConvertError(PResStringRec(@SFormatTooLong));
  SetString(Result, Buffer, AnsiStrings.FloatToTextFmt(Buffer, Value, fvExtended,
    PAnsiChar(Format), FormatSettings));
end;

{$ENDREGION 'string <=> number implementation'}

{$REGION 'Variant utils'}

function TryVarToStr(const v: Variant; var s: string): Boolean;
begin
  try
    s := VarToStr(v);
    Result := True;
  except
    Result := False;
  end;
end;

function VarToBool(const v: Variant; var bv: Boolean): Boolean;
begin
  try
    bv := v;
    Result := True;
  except
    Result := False;
  end;
end;

function VarToBoolDef(const v: Variant; def: Boolean): Boolean;
begin
  try
    Result := v;
  except
    Result := def;
  end;
end;

function VarToInt(const v: Variant; var bv: Integer): Boolean;
begin
  try
    bv := v;
    Result := True;
  except
    Result := False;
  end;
end;

function VarToIntDef(const v: Variant; def: Integer): Integer;
begin
  try
    Result := v;
  except
    Result := def;
  end;
end;

function VarToInt64(const v: Variant; var bv: Int64): Boolean;
begin
  try
    bv := v;
    Result := True;
  except
    Result := False;
  end;
end;

function VarToInt64Def(const v: Variant; def: Int64): Int64;
begin
  try
    Result := v;
  except
    Result := def;
  end;
end;

function VarToFloat(const v: Variant; var bv: Double): Boolean;
begin
  try
    bv := v;
    Result := True;
  except
    Result := False;
  end;
end;

function VarToFloatDef(const v: Variant; def: Double): Double;
begin
  try
    Result := v;
  except
    Result := def;
  end;
end;

procedure SetNull(var Value: Variant);
begin
  VarClear(Value);
  TVarData(Value).VType := varNull;
end;

{$ENDREGION}

function WCharInSet(c: WideChar; cs: TAnsiCharSet): Boolean;
begin
  Result := (c < #$0100) and (AnsiChar(c) in cs);
end;

function WCharInSetFast(c: WideChar; cs: TAnsiCharSet): Boolean;
begin
  Result := AnsiChar(c) in cs;
end;

function ByteInSet(c: AnsiChar; cs: TAnsiCharSet): Boolean;
begin
  Result := c in cs;
end;

function GotoNextNotSpace(p: PWideChar): PWideChar;
begin
  if (p^ > #0) and (p^ <= #32) then
    repeat
      Inc(p);
    until (p^ <= #0) or (p^ > #32);
    Result := p;
end;

function GotoNextNotSpace(p: PAnsiChar): PAnsiChar;
begin
  if (p^ > #0) and (p^ <= #32) then
    repeat
      Inc(p);
    until (p^ <= #0) or (p^ > #32);
    Result := p;
end;

function IsSpace(ch: WideChar): Boolean;
begin
  Result := (ch > #0) and (ch <= #32);
end;

function IsCJK(ch: WideChar): Boolean;
begin
  Result := (ch > #$4E00) and (ch <= #$9FFF);
end;

function IsSimplifiedChineseCharacter(ch: WideChar): Boolean;
begin
  Result := (ch > #$4E00) and (ch <= #$9FFF);
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
  while (s^ <> #0) and (s^ <> c) do
    Inc(s);

  if s^ = #0 then
    Result := nil
  else
    Result := s;
end;

function RBStrScan(const s: RawByteString; c: AnsiChar; first, last: Integer): Integer;
var
  i: Integer;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > length(s)) then
    last := length(s) + 1;

  Result := 0;

  for i := first to last - 1 do
  begin
    if s[i] = c then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function SeekAnsiChar(s: PAnsiChar; len: Integer; what: AnsiChar): PAnsiChar;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to len - 1 do
  begin
    if s[i] = what then
    begin
      Result := s + i;
      Break;
    end;
  end;
end;

function SeekAnsiChars(s: PAnsiChar; len: Integer; const whats: array of AnsiChar): PAnsiChar;
var
  i, j: Integer;
  found: Boolean;
  c: AnsiChar;
begin
  Result := nil;

  for i := 0 to len - 1 do
  begin
    c := s[i];
    found := False;

    for j := Low(whats) to High(whats) do
      if whats[j] = c then
      begin
        found := True;
        Break;
      end;

    if found then
    begin
      Result := s + i;
      Break;
    end;
  end;
end;

{$IFDEF WIN32}
function StrPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar;
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
{$ELSE}
var
  i, k, mr: Integer;
  match: Boolean;
  w, w1, w2: Byte;
begin
  Result := nil;

  if (substr = nil) or (str = nil) or (sublen > len) or (sublen <= 0) then
    Exit;

  if substr = str then
  begin
    Result := str;
    Exit;
  end;

  w := PByte(substr)^;

  mr := len - sublen;

  i := 0;

  while True do
  begin
    while i <= mr do
    begin
      w1 := Byte(str[i]);
      if w1 = w then
        Break;
      Inc(i);
    end;

    if i > mr then
      Exit;

    match := True;

    for k := 1 to sublen - 1 do
    begin
      w1 := Byte(str[i + k]);
      w2 := Byte(substr[k]);

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
{$ENDIF}

function StrPosA(substr: TAnsiCharSection; str: TAnsiCharSection): PAnsiChar;
begin
  Result := StrPosA(substr._begin, substr._end - substr._begin, str._begin, str._end - str._begin);
end;

{$IFDEF WIN32}
function SysUtils_StrPosA(str, substr: PAnsiChar): PAnsiChar; assembler;
{ copy from SysUtils }
asm
  PUSH    EDI
  PUSH    ESI
  PUSH    EBX
  OR      EAX,EAX
  JE      @@2
  OR      EDX,EDX
  JE      @@2
  MOV     EBX,EAX
  MOV     EDI,EDX
  XOR     AL,AL
  MOV     ECX,0FFFFFFFFH
  REPNE   SCASB
  NOT     ECX
  DEC     ECX
  JE      @@2
  MOV     ESI,ECX
  MOV     EDI,EBX
  MOV     ECX,0FFFFFFFFH
  REPNE   SCASB
  NOT     ECX
  SUB     ECX,ESI
  JBE     @@2
  MOV     EDI,EBX
  LEA     EBX,[ESI-1]
@@1:    MOV     ESI,EDX
  LODSB
  REPNE   SCASB
  JNE     @@2
  MOV     EAX,ECX
  PUSH    EDI
  MOV     ECX,EBX
  REPE    CMPSB
  POP     EDI
  MOV     ECX,EAX
  JNE     @@1
  LEA     EAX,[EDI-1]
  JMP     @@3
@@2:    XOR     EAX,EAX
@@3:    POP     EBX
  POP     ESI
  POP     EDI
end;

function StrPosA(substr, str: PAnsiChar): PAnsiChar;
begin
  Result := SysUtils_StrPosA(str, substr);
end;
{$ELSE}
function StrPosA(substr, str: PAnsiChar): PAnsiChar;
begin
  Result := StrPosA(substr, SysUtils.StrLen(substr), str, SysUtils.StrLen(str));
end;
{$ENDIF}

function RBStrPos(const substr, str: RawByteString; first: Integer; last: Integer): Integer;
var
  Ptr: PAnsiChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last - first < length(substr) then
    Result := 0
  else if (Pointer(substr) = Pointer(str)) and (first = 1) then
    Result := 1
  else
  begin
    Ptr := StrPosA(PAnsiChar(substr), length(substr), PAnsiChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PAnsiChar(str) + 1;
  end;
end;

function StrIPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar;
var
  i, k, mr: Integer;
  match: Boolean;
  w, w1, w2: Byte;
begin
  Result := nil;

  if (substr = nil) or (str = nil) or (sublen > len) or (sublen <= 0) then
    Exit;

  if substr = str then
  begin
    Result := str;
    Exit;
  end;

  if (substr^ >= 'A') and (substr^ <= 'Z') then
    w := PByte(substr)^ + 32
  else
    w := PByte(substr)^;

  mr := len - sublen;

  i := 0;

  while True do
  begin
    while i <= mr do
    begin
      if (str[i] >= 'A') and (str[i] <= 'Z') then
        w1 := Byte(str[i]) + 32
      else
        w1 := Byte(str[i]);

      if w1 = w then
        Break;

      Inc(i);
    end;

    if i > mr then
      Exit;

    match := True;

    for k := 1 to sublen - 1 do
    begin
      if (str[i + k] >= 'A') and (str[i + k] <= 'Z') then
        w1 := Byte(str[i + k]) + 32
      else
        w1 := Byte(str[i + k]);

      if (substr[k] >= 'A') and (substr[k] <= 'Z') then
        w2 := Byte(substr[k]) + 32
      else
        w2 := Byte(substr[k]);

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

function StrIPosA(substr, str: PAnsiChar): PAnsiChar;
begin
  Result := StrIPosA(substr, StrLenA(substr), str, StrLenA(str));
end;

function RBStrIPos(const substr, str: RawByteString; first: Integer = 1; last: Integer = 0): Integer;
var
  Ptr: PAnsiChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrIPosA(PAnsiChar(substr), length(substr), PAnsiChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PAnsiChar(str) + 1;
  end;
end;

function StrRPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar;
var
  i, k, ML: Integer;
  match: Boolean;
begin
  Result := nil;

  if (substr = nil) or (str = nil) or (sublen > len) or (sublen <= 0) then
    Exit;

  if substr + sublen = str + len then
  begin
    Result := substr;
    Exit;
  end;

  ML := sublen - 1;

  i := len - 1;

  while True do
  begin
    while (i >= ML) and (str[i] <> substr[ML]) do
      Dec(i);

    if i < ML then
      Exit;

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

function StrRPosA(substr, str: PAnsiChar): PAnsiChar;
begin
  Result := StrRPosA(substr, StrLenA(substr), str, StrLenA(str));
end;

function RBStrRPos(const substr, str: RawByteString; first: Integer = 1; last: Integer = 0): Integer;
var
  Ptr: PAnsiChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrRPosA(PAnsiChar(substr), length(substr), PAnsiChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PAnsiChar(str) + 1;
  end;
end;

function StrRIPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar;
var
  i, j, k, ML: Integer;
  match: Boolean;
  w, w1, w2: Word;
begin
  Result := nil;

  if (substr = nil) or (str = nil) or (sublen > len) or (sublen <= 0) then
    Exit;

  if substr + sublen = str + len then
  begin
    Result := substr;
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

    if i < ML then
      Exit;

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

function StrRIPosA(substr, str: PAnsiChar): PAnsiChar;
begin
  Result := StrRIPosA(substr, StrLenA(substr), str, StrLenA(str));
end;

function RBStrRIPos(const substr, str: RawByteString; first, last: Integer): Integer;
var
  Ptr: PAnsiChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrRIPosA(PAnsiChar(substr), length(substr), PAnsiChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PAnsiChar(str) + 1;
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
  while (s^ <> #0) and (s^ <> c) do
    Inc(s);

  if s^ = #0 then
    Result := nil
  else
    Result := s;
end;

function UStrScan(const s: u16string; c: WideChar; first, last: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;

  if first <= 0 then
    Exit;

  if (last <= 0) or (last > length(s)) then
    last := length(s) + 1;

  for i := first to last - 1 do
  begin
    if s[i] = c then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function BStrScan(const s: WideString; c: WideChar; first, last: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;

  if first <= 0 then
    Exit;

  if (last <= 0) or (last > length(s)) then
    last := length(s) + 1;

  for i := first to last - 1 do
  begin
    if s[i] = c then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function StrScan(const s: string; c: Char): Integer;
var
  i: Integer;
begin
  Result := 0;

  for i := 1 to length(s) do
    if s[i] = c then
    begin
      Result := i;
      Break;
    end;
end;

function SeekWideChar(s: PWideChar; len: Integer; what: WideChar): PWideChar;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to len - 1 do
  begin
    if s[i] = what then
    begin
      Result := s + i;
      Break;
    end;
  end;
end;

function SeekWideChars(s: PWideChar; len: Integer; const whats: array of WideChar): PWideChar;
var
  i, j: Integer;
  found: Boolean;
  c: WideChar;
begin
  Result := nil;

  for i := 0 to len - 1 do
  begin
    c := s[i];
    found := False;

    for j := Low(whats) to High(whats) do
      if whats[j] = c then
      begin
        found := True;
        Break;
      end;

    if found then
    begin
      Result := s + i;
      Break;
    end;
  end;
end;

{$region 'pattern search impl'}

{$IFDEF WIN32}

function SysUtils_StrPosW(str, substr: PWideChar): PWideChar; assembler;
{ copy from SysUtils }
asm
  PUSH    EDI
  PUSH    ESI
  PUSH    EBX
  OR      EAX,EAX
  JE      @@2
  OR      EDX,EDX
  JE      @@2
  MOV     EBX,EAX
  MOV     EDI,EDX
  XOR     AX,AX
  MOV     ECX,0FFFFFFFFH
  REPNE   SCASW
  NOT     ECX
  DEC     ECX
  JE      @@2
  MOV     ESI,ECX
  MOV     EDI,EBX
  MOV     ECX,0FFFFFFFFH
  REPNE   SCASW
  NOT     ECX
  SUB     ECX,ESI
  JBE     @@2
  MOV     EDI,EBX
  LEA     EBX,[ESI-1]
@@1:    MOV     ESI,EDX
  LODSW
  REPNE   SCASW
  JNE     @@2
  MOV     EAX,ECX
  PUSH    EDI
  MOV     ECX,EBX
  REPE    CMPSW
  POP     EDI
  MOV     ECX,EAX
  JNE     @@1
  LEA     EAX,[EDI-2]
  JMP     @@3
@@2:    XOR     EAX,EAX
@@3:    POP     EBX
  POP     ESI
  POP     EDI
end;

function StrPosW(substr, str: PWideChar): PWideChar;
begin
  Result := SysUtils_StrPosW(str, substr);
end;
{$ELSE}

function StrPosW(substr, str: PWideChar): PWideChar;
begin
  Result := StrPosW(substr, SysUtils.StrLen(substr), str, SysUtils.StrLen(str));
end;
{$ENDIF}

function StrPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar;
var
  i, k, mr: Integer;
  match: Boolean;
begin
  Result := nil;

  if (substr = nil) or (str = nil) or (sublen > len) or (sublen <= 0) then
    Exit;

  if substr = str then
  begin
    Result := str;
    Exit;
  end;

  mr := len - sublen;

  i := 0;

  while True do
  begin
    while (i <= mr) and (str[i] <> substr[0]) do
      Inc(i);

    if i > mr then
      Exit;

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

function UStrPos(const substr, str: u16string; first, last: Integer): Integer;
var
  Ptr: PWideChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > length(str)) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrPosW(PWideChar(substr), length(substr), PWideChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PWideChar(str) + 1;
  end;
end;

function BStrPos(const substr, str: WideString; first: Integer = 1; last: Integer = 0): Integer;
var
  Ptr: PWideChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > length(str)) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrPosW(PWideChar(substr), length(substr), PWideChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PWideChar(str) + 1;
  end;
end;

function StrIPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar; overload;
var
  i, k, mr: Integer;
  match: Boolean;
  w, w1, w2: Word;
begin
  Result := nil;

  if (substr = nil) or (str = nil) or (sublen > len) or (sublen <= 0) then
    Exit;

  if substr = str then
  begin
    Result := str;
    Exit;
  end;

  if (substr[0] >= 'A') and (substr[0] <= 'Z') then
    w := Ord(substr[0]) + 32
  else
    w := Ord(substr[0]);

  mr := len - sublen;

  i := 0;

  while True do
  begin
    while i <= mr do
    begin
      if (str[i] >= 'A') and (str[i] <= 'Z') then
        w1 := Ord(str[i]) + 32
      else
        w1 := Ord(str[i]);

      if w1 = w then
        Break;

      Inc(i);
    end;

    if i > mr then
      Exit;

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

function StrIPosW(substr: u16string; str: PWideChar; len: Integer): PWideChar;
begin
  Result := StrIPosW(PWideChar(substr), length(substr), str, len);
end;

function StrIPosW(substr, str: PWideChar): PWideChar;
begin
  Result := StrIPosW(substr, StrLenW(substr), str, StrLenW(str));
end;

function UStrIPos(const substr, str: u16string; first, last: Integer): Integer;
var
  Ptr: PWideChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrIPosW(PWideChar(substr), length(substr), PWideChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PWideChar(str) + 1;
  end;
end;

function BStrIPos(const substr, str: WideString; first, last: Integer): Integer;
var
  Ptr: PWideChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrIPosW(PWideChar(substr), length(substr), PWideChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PWideChar(str) + 1;
  end;
end;

function StrRPosW(substr: PWideChar; sublen: Integer; str: PWideChar; len: Integer): PWideChar;
var
  i, k, ML: Integer;
  match: Boolean;
begin
  Result := nil;

  if (substr = nil) or (str = nil) or (sublen > len) or (sublen <= 0) then
    Exit;

  if substr + sublen = str + len then
  begin
    Result := substr;
    Exit;
  end;

  ML := sublen - 1;

  i := len - 1;

  while True do
  begin
    while (i >= ML) and (str[i] <> substr[ML]) do
      Dec(i);

    if i < ML then
      Exit;

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

function StrRPosW(substr, str: PWideChar): PWideChar;
begin
  Result := StrRPosW(substr, StrLenW(substr), str, StrLenW(str));
end;

function UStrRPos(const substr, str: u16string; first, last: Integer): Integer;
var
  Ptr: PWideChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrRPosW(PWideChar(substr), length(substr), PWideChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PWideChar(str) + 1;
  end;
end;

function BStrRPos(const substr, str: WideString; first, last: Integer): Integer;
var
  Ptr: PWideChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrRPosW(PWideChar(substr), length(substr), PWideChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PWideChar(str) + 1;
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
    Exit;

  if substr + sublen = str + len then
  begin
    Result := substr;
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

    if i < ML then
      Exit;

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

function StrRIPosW(substr, str: PWideChar): PWideChar;
begin
  Result := StrRIPosW(substr, StrLenW(substr), str, StrLenW(str));
end;

function UStrRIPos(const substr, str: u16string; first, last: Integer): Integer;
var
  Ptr: PWideChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrRIPosW(PWideChar(substr), length(substr), PWideChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PWideChar(str) + 1;
  end;
end;

function BStrRIPos(const substr, str: WideString; first, last: Integer): Integer;
var
  Ptr: PWideChar;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > Integer(length(str))) then
    last := length(str) + 1;

  if last <= first then
    Result := 0
  else
  begin
    Ptr := StrRIPosW(PWideChar(substr), length(substr), PWideChar(str) + (first - 1), last - first);

    if Ptr = nil then
      Result := 0
    else
      Result := Ptr - PWideChar(str) + 1;
  end;
end;

function RBStrReplace(const s, OldPattern, NewPattern: RawByteString; flags: TReplaceFlags): RawByteString;
var
  offset, p, L: Integer;
begin
  Result := '';
  p := 1;
  L := length(s);

  while p <= L do
  begin
    if rfIgnoreCase in flags then
      offset := RBStrIPos(OldPattern, s, p)
    else
      offset := RBStrPos(OldPattern, s, p);

    if offset <= 0 then
    begin
      if Result = '' then
        Result := s
      else
        Result := Result + Copy(s, p, L + 1 - p);
      Break;
    end;

    Result := Result + Copy(s, p, offset - p) + NewPattern;
    p := offset + length(OldPattern);

    if not(rfReplaceAll in flags) then
    begin
      Result := Result + Copy(s, p, offset - p);
      Break;
    end;
  end;
end;

function UStrReplace(const s, OldPattern, NewPattern: u16string; flags: TReplaceFlags): u16string;
var
  offset, p, L: Integer;
begin
  Result := '';
  p := 1;
  L := length(s);

  while p <= L do
  begin
    if rfIgnoreCase in flags then
      offset := UStrIPos(OldPattern, s, p)
    else
      offset := UStrPos(OldPattern, s, p);

    if offset <= 0 then
    begin
      if Result = '' then
        Result := s
      else
        Result := Result + Copy(s, p, L + 1 - p);

      Break;
    end;

    Result := Result + Copy(s, p, offset - p) + NewPattern;
    p := offset + length(OldPattern);

    if not(rfReplaceAll in flags) then
    begin
      Result := Result + Copy(s, p, L + 1 - p);
      Break;
    end;
  end;
end;

function BStrReplace(const s, OldPattern, NewPattern: WideString; flags: TReplaceFlags): WideString;
var
  offset, p, L: Integer;
begin
  Result := '';
  p := 1;
  L := length(s);

  while p <= L do
  begin
    if rfIgnoreCase in flags then
      offset := BStrIPos(OldPattern, s, p)
    else
      offset := BStrPos(OldPattern, s, p);

    if offset <= 0 then
    begin
      Result := Result + Copy(s, p, L + 1 - p);
      Break;
    end;

    Result := Result + Copy(s, p, offset - p) + NewPattern;
    p := offset + length(OldPattern);

    if not(rfReplaceAll in flags) then
    begin
      Result := Result + Copy(s, p, offset - p);
      Break;
    end;
  end;
end;

function StrReplace(const s, OldPattern, NewPattern: WideString; flags: TReplaceFlags): WideString;
begin
  Result := BStrReplace(s, OldPattern, NewPattern, flags);
end;

function StrReplace(const s, OldPattern, NewPattern: u16string; flags: TReplaceFlags): u16string;
begin
  Result := UStrReplace(s, OldPattern, NewPattern, flags);
end;

function StrReplace(const s, OldPattern, NewPattern: RawByteString; flags: TReplaceFlags): RawByteString;
begin
  Result := RBStrReplace(s, OldPattern, NewPattern, flags);
end;

function WordsCompare(s1, s2: PWideChar): Integer;
var
  diff: Integer;
begin
  Result := 0;

  while s1^ <> #0 do
  begin
    diff := Integer(PWord(s1)^) - Integer(PWord(s2)^);

    if diff <> 0 then
    begin
      Result := diff;
      Break;
    end;

    Inc(s1);
    Inc(s2);
  end;

  if s2^ <> #0 then
    Result := -1;
end;

function WordsICompare(s1, s2: PWideChar): Integer;
var
  diff: Integer;
  c1, c2: WideChar;
begin
  Result := 0;

  while s1^ <> #0 do
  begin
    c1 := s1^;
    c2 := s2^;

    if (c1 >= 'A') and (c1 <= 'Z') then
      Inc(Word(c1), 32);

    if (c2 >= 'A') and (c2 <= 'Z') then
      Inc(Word(c2), 32);

    diff := Ord(c1) - Ord(c2);

    if diff <> 0 then
    begin
      Result := diff;
      Break;
    end;

    Inc(s1);
    Inc(s2);
  end;

  if s2^ <> #0 then
    Result := -1;
end;

function StrCompareW(const s1: PWideChar; L1: Integer; s2: PWideChar; L2: Integer; CaseSensitive: Boolean): Integer;
var
  CmpFlags: DWORD;
begin
  if CaseSensitive then
    CmpFlags := 0
  else
    CmpFlags := NORM_IGNORECASE;

  Result := CompareStringW(LOCALE_USER_DEFAULT, CmpFlags, s1, L1, s2, L2) - 2;
end;

function StrCompareW(s1, s2: PWideChar; CaseSensitive: Boolean = True): Integer;
var
  CmpFlags: DWORD;
begin
  if CaseSensitive then
    CmpFlags := 0
  else
    CmpFlags := NORM_IGNORECASE;

  Result := CompareStringW(LOCALE_USER_DEFAULT, CmpFlags, s1, -1, s2, -1) - 2;
end;

function UStrCompare(const s1, s2: u16string; CaseSensitive: Boolean = True): Integer;
begin
  Result := StrCompareW(PWideChar(s1), length(s1), PWideChar(s2), length(s2), CaseSensitive);
end;

function BStrCompare(const s1, s2: WideString; CaseSensitive: Boolean = True): Integer;
begin
  Result := StrCompareW(PWideChar(s1), length(s1), PWideChar(s2), length(s2), CaseSensitive);
end;

function StrCompare(const s1, s2: u16string; CaseSensitive: Boolean): Integer;
begin
  Result := StrCompareW(PWideChar(s1), length(s1), PWideChar(s2), length(s2), CaseSensitive);
end;

function StrCompare(const s1: u16string; s2: PWideChar; s2len: Integer;
  CaseSensitive: Boolean = True): Integer;
begin
  Result := StrCompareW(PWideChar(s1), length(s1), s2, s2len, CaseSensitive);
end;

function StrCompare(const s1, s2: WideString; CaseSensitive: Boolean): Integer;
begin
  Result := StrCompareW(PWideChar(s1), length(s1), PWideChar(s2), length(s2), CaseSensitive);
end;

function StrCompareA(str1: PAnsiChar; len1: Integer; str2: PAnsiChar; len2: Integer; CaseSensitive: Boolean): Integer;
var
  CmpFlags: DWORD;
begin
  if CaseSensitive then
    CmpFlags := 0
  else
    CmpFlags := NORM_IGNORECASE;

  Result := CompareStringA(LOCALE_USER_DEFAULT, CmpFlags, str1, len1, str2, len2) - 2;
end;

{
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
  }

function StrCompareA(const str1, str2: PAnsiChar; CaseSensitive: Boolean): Integer; overload;
var
  CmpFlags: DWORD;
begin
  if CaseSensitive then
    CmpFlags := 0
  else
    CmpFlags := NORM_IGNORECASE;

  Result := CompareStringA(LOCALE_USER_DEFAULT, CmpFlags, str1, -1, str2, -1) - 2;
end;

function RBStrCompare(const str1, str2: RawByteString; CaseSensitive: Boolean): Integer;
begin
  Result := StrCompareA(PAnsiChar(str1), length(str1), PAnsiChar(str2), length(str2), CaseSensitive);
end;

function StrCompare(const str1, str2: RawByteString; CaseSensitive: Boolean): Integer;
begin
  Result := StrCompareA(PAnsiChar(str1), length(str1), PAnsiChar(str2), length(str2), CaseSensitive);
end;

function UStrCatCStr(const s1: array of u16string; s2: PWideChar): u16string;
var
  i, L1, L2: Integer;
begin
  L1 := 0;

  for i := Low(s1) to High(s1) do
    Inc(L1, length(s1[i]));

  L2 := StrLenW(s2);

  SetLength(Result, L1 + L2);

  L1 := 0;

  for i := Low(s1) to High(s1) do
  begin
    Move(Pointer(s1[i])^, PWideChar(Result)[L1], length(s1[i]) * 2);
    Inc(L1, length(s1[i]));
  end;

  Move(s2^, PWideChar(Result)[L1], L2 * 2);
end;

function GetSectionBetweenA(s: PAnsiChar; len: Integer; const prefix, suffix: RawByteString;
  out SectionBegin, SectionEnd: PAnsiChar; flags: TStringSearchFlags): Boolean;
begin
  Result := False;

  if Assigned(s) and (len > 0) then
  begin
    if ssfReverse in flags then
    begin
      if suffix = '' then
        SectionEnd := s + len
      else if ssfCaseSensitive in flags then
        SectionEnd := StrRPosA(PAnsiChar(suffix), length(suffix), s, len)
      else
        SectionEnd := StrRIPosA(PAnsiChar(suffix), length(suffix), s, len);

      if Assigned(SectionEnd) then
      begin
        if prefix = '' then
          SectionBegin := s
        else if ssfCaseSensitive in flags then
          SectionBegin := StrRPosA(PAnsiChar(prefix), length(prefix), s, SectionEnd - s)
        else
          SectionBegin := StrRIPosA(PAnsiChar(prefix), length(prefix), s, SectionEnd - s);

        if Assigned(SectionBegin) then
        begin
          if not(ssfIncludePrefix in flags) then
            Inc(SectionBegin, length(prefix));

          if ssfIncludeSuffix in flags then
            Inc(SectionEnd, length(suffix));

          Result := True;
        end;
      end;
    end
    else
    begin
      if prefix = '' then
        SectionBegin := s
      else if ssfCaseSensitive in flags then
        SectionBegin := StrPosA(PAnsiChar(prefix), length(prefix), s, len)
      else
        SectionBegin := StrIPosA(PAnsiChar(prefix), length(prefix), s, len);

      if Assigned(SectionBegin) then
      begin
        Inc(SectionBegin, length(prefix));

        if suffix = '' then
          SectionEnd := s + len
        else if ssfCaseSensitive in flags then
          SectionEnd := StrPosA(PAnsiChar(suffix), length(suffix), SectionBegin, s + len - SectionBegin)
        else
          SectionEnd := StrIPosA(PAnsiChar(suffix), length(suffix), SectionBegin, s + len - SectionBegin);

        if Assigned(SectionEnd) then
        begin
          if ssfIncludePrefix in flags then
            Dec(SectionBegin, length(prefix));

          if ssfIncludeSuffix in flags then
            Inc(SectionEnd, length(suffix));

          Result := True;
        end;
      end;
    end;
  end;
end;

function RBStrGetSectionBetween(const src, prefix, suffix: RawByteString; out P1, P2: Integer; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  s, SectionBegin, SectionEnd: PAnsiChar;
begin
  Result := False;

  if src <> '' then
  begin
    s := PAnsiChar(src);

    if last <= 0 then
      last := length(src) + 1;

    Result := GetSectionBetweenA(s + first - 1, last - first, prefix, suffix, SectionBegin, SectionEnd, flags);

    if Result then
    begin
      P1 := SectionBegin + 1 - s;
      P2 := SectionEnd + 1 - s;
    end;
  end;
end;

function RBStrGetTrimedSectionBetween(const src, prefix, suffix: RawByteString; out P1, P2: Integer;
  first, last: Integer; flags: TStringSearchFlags): Boolean;
var
  tmp: Integer;
begin
  Result := RBStrGetSectionBetween(src, prefix, suffix, P1, P2, first, last, flags);

  if Result then
  begin
    while (P1 < P2) and (src[P1] <= #32) do
      Inc(P1);

    tmp := P2 - 1;

    while (tmp >= P1) and (src[tmp] <= #32) do
      Dec(tmp);

    P2 := tmp + 1;
  end;
end;

function RBStrGetSubstrBetween(const src, prefix, suffix: RawByteString; first, last: Integer;
  flags: TStringSearchFlags): RawByteString;
var
  P1, P2: Integer;
begin
  if RBStrGetSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
    Result := Copy(src, P1, P2 - P1)
  else
    Result := '';
end;

function RBStrGetTrimedSubstrBetween(const src, prefix, suffix: RawByteString; first, last: Integer;
  flags: TStringSearchFlags): RawByteString;
var
  P1, P2: Integer;
begin
  if RBStrGetSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
    Result := RBStrTrimCopy(src, P1, P2 - P1)
  else
    Result := '';
end;

function RBStrTryGetInt64Between(const src, prefix, suffix: RawByteString; out value: Int64; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  Result := False;

  if RBStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    value := BufToInt64A(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      value := 0
    else
      Result := True;
  end;
end;

function RBStrGetInt64Between(const src, prefix, suffix: RawByteString; first, last: Integer;
  flags: TStringSearchFlags): Int64;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  if RBStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    Result := BufToInt64A(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0
  end
  else
    Result := 0;
end;

function RBStrTryGetIntegerBetween(const src, prefix, suffix: RawByteString; out value: Integer; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  Result := False;

  if RBStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    value := BufToIntA(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      value := 0
    else
      Result := True;
  end;
end;

function RBStrGetIntegerBetween(const src, prefix, suffix: RawByteString; first, last: Integer;
  flags: TStringSearchFlags): Integer;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  if RBStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    Result := BufToIntA(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0
  end
  else
    Result := 0;
end;

function RBStrGetBoolBetween(const src, prefix, suffix: RawByteString; def: Boolean; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
begin
  if RBStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
    Result := StrToBoolA(PAnsiChar(src) + P1 - 1, P2 - P1, def)
  else
    Result := def;
end;

function RBStrTryGetBoolBetween(const src, prefix, suffix: RawByteString; out value: Boolean; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
begin
  Result := False;

  if RBStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    value := StrToBoolA(PAnsiChar(src) + P1 - 1, P2 - P1, False);
    Result := True;
  end;
end;

function RBStrTryGetFloatBetween(const src, prefix, suffix: RawByteString; out value: Double; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  Result := False;

  value := 0;

  if RBStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    try
      value := BufToFloatA(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

      if not Assigned(c) then
        Result := True;
    except

    end;
  end;
end;

function RBStrGetFloatBetween(const src, prefix, suffix: RawByteString; first, last: Integer;
  flags: TStringSearchFlags): Double;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  if RBStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    Result := BufToFloatA(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0;
  end
  else
    Result := 0;
end;

function GetSectionBetweenW(s: PWideChar; len: Integer; const prefix, suffix: u16string;
  out SectionBegin, SectionEnd: PWideChar; flags: TStringSearchFlags): Boolean;
begin
  Result := False;

  if Assigned(s) and (len > 0) then
  begin
    if ssfReverse in flags then
    begin
      if suffix = '' then
        SectionEnd := s + len
      else if ssfCaseSensitive in flags then
        SectionEnd := StrRPosW(PWideChar(suffix), length(suffix), s, len)
      else
        SectionEnd := StrRIPosW(PWideChar(suffix), length(suffix), s, len);

      if Assigned(SectionEnd) then
      begin
        if prefix = '' then
          SectionBegin := s
        else if ssfCaseSensitive in flags then
          SectionBegin := StrRPosW(PWideChar(prefix), length(prefix), s, SectionEnd - s)
        else
          SectionBegin := StrRIPosW(PWideChar(prefix), length(prefix), s, SectionEnd - s);

        if Assigned(SectionBegin) then
        begin
          if not(ssfIncludePrefix in flags) then
            Inc(SectionBegin, length(prefix));

          if ssfIncludeSuffix in flags then
            Inc(SectionEnd, length(suffix));

          Result := True;
        end;
      end;
    end
    else
    begin
      if prefix = '' then
        SectionBegin := s
      else if ssfCaseSensitive in flags then
        SectionBegin := StrPosW(PWideChar(prefix), length(prefix), s, len)
      else
        SectionBegin := StrIPosW(PWideChar(prefix), length(prefix), s, len);

      if Assigned(SectionBegin) then
      begin
        Inc(SectionBegin, length(prefix));

        if suffix = '' then
          SectionEnd := s + len
        else if ssfCaseSensitive in flags then
          SectionEnd := StrPosW(PWideChar(suffix), length(suffix), SectionBegin, s + len - SectionBegin)
        else
          SectionEnd := StrIPosW(PWideChar(suffix), length(suffix), SectionBegin, s + len - SectionBegin);

        if Assigned(SectionEnd) then
        begin
          if ssfIncludePrefix in flags then
            Dec(SectionBegin, length(prefix));

          if ssfIncludeSuffix in flags then
            Inc(SectionEnd, length(suffix));

          Result := True;
        end;
      end;
    end;
  end;
end;

function UStrGetSectionBetween(const src, prefix, suffix: u16string; out P1, P2: Integer; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  s, SectionBegin, SectionEnd: PWideChar;
begin
  Result := False;

  if src <> '' then
  begin
    s := PWideChar(src);

    if last <= 0 then
      last := length(src) + 1;

    Result := GetSectionBetweenW(s + first - 1, last - first, prefix, suffix, SectionBegin, SectionEnd, flags);

    if Result then
    begin
      P1 := SectionBegin + 1 - s;
      P2 := SectionEnd + 1 - s;
    end;
  end;
end;

function UStrGetTrimedSectionBetween(const src, prefix, suffix: u16string; out P1, P2: Integer;
  first, last: Integer; flags: TStringSearchFlags): Boolean;
var
  tmp: Integer;
begin
  Result := UStrGetSectionBetween(src, prefix, suffix, P1, P2, first, last, flags);

  if Result then
  begin
    while (P1 < P2) and (src[P1] <= #32) do
      Inc(P1);

    tmp := P2 - 1;

    while (tmp >= P1) and (src[tmp] <= #32) do
      Dec(tmp);

    P2 := tmp + 1;
  end;
end;

function UStrGetSubstrBetween(const src, prefix, suffix: u16string; first, last: Integer;
  flags: TStringSearchFlags): u16string;
var
  P1, P2: Integer;
begin
  if UStrGetSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
    Result := Copy(src, P1, P2 - P1)
  else
    Result := '';
end;

function UStrGetTrimedSubstrBetween(const src, prefix, suffix: u16string; first, last: Integer;
  flags: TStringSearchFlags): u16string;
var
  P1, P2: Integer;
begin
  if UStrGetSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
    Result := UStrTrimCopy(src, P1, P2 - P1)
  else
    Result := '';
end;

function UStrTryGetInt64Between(const src, prefix, suffix: u16string; out value: Int64; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  Result := False;

  if UStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    c := nil;
    value := BufToInt64W(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      value := 0
    else
      Result := True;
  end;
end;

function UStrGetInt64Between(const src, prefix, suffix: u16string; first, last: Integer;
  flags: TStringSearchFlags): Int64;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  if UStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    c := nil;

    Result := BufToInt64W(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0;
  end
  else
    Result := 0;
end;

function UStrTryGetIntegerBetween(const src, prefix, suffix: u16string; out value: Integer; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  Result := False;

  if UStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    c := nil;
    value := BufToIntW(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      value := 0
    else
      Result := True;
  end;
end;

function UStrGetIntegerBetween(const src, prefix, suffix: u16string; first, last: Integer;
  flags: TStringSearchFlags): Integer;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  if UStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    c := nil;

    Result := BufToIntW(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0;
  end
  else
    Result := 0;
end;

function UStrGetBoolBetween(const src, prefix, suffix: u16string; def: Boolean; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
begin
  if UStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
    Result := StrToBoolW(PWideChar(src) + P1 - 1, P2 - P1, def)
  else
    Result := def;
end;

function UStrTryGetBoolBetween(const src, prefix, suffix: u16string; out value: Boolean; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
begin
  Result := False;

  if UStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    value := StrToBoolW(PWideChar(src) + P1 - 1, P2 - P1, False);
    Result := True;
  end;
end;

function UStrTryGetFloatBetween(const src, prefix, suffix: u16string; out value: Double; first, last: Integer;
  flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  pwc: PWideChar;
begin
  value := 0;

  if UStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    try
      value := BufToFloatW(PWideChar(src) + P1 - 1, P2 - P1, @pwc);
      Result := not Assigned(pwc);
    except
      Result := False;
    end;
  end
  else
    Result := False;
end;

function UStrGetFloatBetween(const src, prefix, suffix: u16string; first, last: Integer;
  flags: TStringSearchFlags): Double;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  if UStrGetTrimedSectionBetween(src, prefix, suffix, P1, P2, first, last, flags) then
  begin
    Result := BufToFloatW(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0;
  end
  else
    Result := 0;
end;

function BeginWithW(s: PWideChar; len: Integer; sub: PWideChar; sublen: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;

  if len < sublen then
    Exit;

  for i := 0 to sublen - 1 do
    if sub[i] <> s[i] then
      Exit;

  Result := True;
end;

function BeginWithW(s: PWideChar; len: Integer; const sub: u16string): Boolean;
var
  i, sublen: Integer;
  _sub: PWideChar;
begin
  Result := False;

  _sub := PWideChar(sub);
  sublen := length(sub);

  if len < sublen then
    Exit;

  for i := 0 to sublen - 1 do
    if _sub[i] <> s[i] then
      Exit;

  Result := True;
end;

function BeginWithW(s, sub: PWideChar): Boolean;
begin
  while (s^ = sub^) and (sub^ <> #0) do
  begin
    Inc(s);
    Inc(sub);
  end;

  Result := sub^ = #0;
end;

function UStrBeginWith(const s, sub: u16string): Boolean;
begin
  Result := BeginWithW(PWideChar(s), length(s), PWideChar(sub), length(sub));
end;

function UStrIBeginWith(const s, sub: u16string): Boolean;
begin
  Result := IBeginWithW(PWideChar(s), length(s), PWideChar(sub), length(sub));
end;

function IBeginWithW(s: PWideChar; len: Integer; sub: PWideChar; sublen: Integer): Boolean;
var
  i: Integer;
  c1, c2: WideChar;
begin
  Result := False;

  if len < sublen then
    Exit;

  for i := 0 to sublen - 1 do
  begin
    c1 := sub[i];
    c2 := s[i];

    if (c1 >= 'A') and (c1 <= 'Z') then
      Inc(Word(c1), 32);
    if (c2 >= 'A') and (c2 <= 'Z') then
      Inc(Word(c2), 32);

    if c1 <> c2 then
      Exit;
  end;

  Result := True;
end;

function IBeginWithW(s, sub: PWideChar): Boolean; overload;
begin
  if s = nil then
    Result := False
  else if IsEmptyString(sub) then
    Result := True
  else
  begin
    Result := True;
    repeat
      if sub^ <> s^ then
      begin
        Result := False;
        Break;
      end;
      Inc(sub);
      Inc(s);
    until sub^ = #0;
  end;
end;

function EndWithW(str: PWideChar; len: Integer; suffix: PWideChar; suffixLen: Integer): Boolean;
begin
  Result := False;

  if len < suffixLen then
    Exit;

  Dec(suffixLen);
  Dec(len);

  while suffixLen >= 0 do
  begin
    if str[len] <> suffix[suffixLen] then
      Exit;
    Dec(len);
    Dec(suffixLen)
  end;

  Result := True;
end;

function EndWithW(s, sub: PWideChar): Boolean;
begin
  Result := EndWithW(s, StrLenW(s), sub, StrLenW(sub));
end;

function EndWithW(s: PWideChar; len: Integer; const suffix: u16string): Boolean;
begin
  Result := EndWithW(s, len, PWideChar(suffix), length(suffix));
end;

function IEndWithW(str: PWideChar; len: Integer; suffix: PWideChar; suffixLen: Integer): Boolean;
var
  c1, c2: WideChar;
begin
  Result := False;

  if len < suffixLen then
    Exit;

  Dec(suffixLen);
  Dec(len);

  while suffixLen >= 0 do
  begin
    c1 := str[len];
    c2 := suffix[suffixLen];

    if (c1 >= 'A') and (c1 <= 'Z') then
      Inc(Word(c1), 32);
    if (c2 >= 'A') and (c2 <= 'Z') then
      Inc(Word(c2), 32);

    if c1 <> c2 then
      Exit;

    Dec(len);
    Dec(suffixLen)
  end;

  Result := True;
end;

function IEndWithW(s, sub: PWideChar): Boolean;
begin
  Result := IEndWithW(s, StrLenW(s), sub, StrLenW(sub));
end;

function UStrEndWith(const str, suffix: u16string): Boolean;
begin
  Result := EndWithW(PWideChar(str), length(str), PWideChar(suffix), length(suffix));
end;

function UStrIEndWith(const str, suffix: u16string): Boolean;
begin
  Result := IEndWithW(PWideChar(str), length(str), PWideChar(suffix), length(suffix));
end;

function EndWithA(str: PAnsiChar; len: Integer; suffix: PAnsiChar; suffixLen: Integer): Boolean;
begin
  Result := False;

  if len < suffixLen then
    Exit;

  Dec(suffixLen);
  Dec(len);

  while suffixLen >= 0 do
  begin
    if str[len] <> suffix[suffixLen] then
      Exit;
    Dec(len);
    Dec(suffixLen)
  end;

  Result := True;
end;

function EndWithA(s, sub: PAnsiChar): Boolean;
begin
  Result := EndWithA(s, StrLenA(s), sub, StrLenA(sub));
end;

function IEndWithA(str: PAnsiChar; len: Integer; suffix: PAnsiChar; suffixLen: Integer): Boolean;
var
  c1, c2: AnsiChar;
begin
  Result := False;

  if len < suffixLen then
    Exit;

  Dec(suffixLen);
  Dec(len);

  while suffixLen >= 0 do
  begin
    c1 := str[len];
    c2 := suffix[suffixLen];

    if (c1 >= 'A') and (c1 <= 'Z') then
      Inc(Byte(c1), 32);
    if (c2 >= 'A') and (c2 <= 'Z') then
      Inc(Byte(c2), 32);

    if c1 <> c2 then
      Exit;

    Dec(len);
    Dec(suffixLen)
  end;

  Result := True;
end;

function IEndWithA(s, sub: PAnsiChar): Boolean;
begin
  Result := IEndWithA(s, StrLenA(s), sub, StrLenA(sub));
end;

function RBStrEndWith(const str, suffix: RawByteString): Boolean;
begin
  Result := EndWithA(PAnsiChar(str), length(str), PAnsiChar(suffix), length(suffix));
end;

function RBStrIEndWith(const str, suffix: RawByteString): Boolean;
begin
  Result := EndWithA(PAnsiChar(str), length(str), PAnsiChar(suffix), length(suffix));
end;

function BeginWithA(s: PAnsiChar; len: Integer; sub: PAnsiChar; sublen: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;

  if len < sublen then
    Exit;

  for i := 0 to sublen - 1 do
    if sub[i] <> s[i] then
      Exit;

  Result := True;
end;

function BeginWithA(s: PAnsiChar; len: Integer; const sub: RawByteString): Boolean;
begin
  Result := BeginWithA(s, len, PAnsiChar(sub), length(sub));
end;

function BeginWithA(s, sub: PAnsiChar): Boolean;
begin
  if s = nil then
    Result := False
  else if IsEmptyString(sub) then
    Result := True
  else
  begin
    Result := True;
    repeat
      if sub^ <> s^ then
      begin
        Result := False;
        Break;
      end;
      Inc(sub);
      Inc(s);
    until sub^ = #0;
  end;
end;

function IBeginWithA(s: PAnsiChar; len: Integer; sub: PAnsiChar; sublen: Integer): Boolean; overload;
var
  i: Integer;
  c1, c2: AnsiChar;
begin
  Result := False;

  if len < sublen then
    Exit;

  for i := 0 to sublen - 1 do
  begin
    c1 := sub[i];
    c2 := s[i];

    if (c1 >= 'A') and (c1 <= 'Z') then
      Inc(Byte(c1), 32);
    if (c2 >= 'A') and (c2 <= 'Z') then
      Inc(Byte(c2), 32);

    if c1 <> c2 then
      Exit;
  end;

  Result := True;
end;

function IBeginWithA(s, sub: PAnsiChar): Boolean;
var
  c1, c2: AnsiChar;
begin
  if s = nil then
    Result := False
  else if IsEmptyString(sub) then
    Result := True
  else
  begin
    Result := True;
    repeat
      c1 := CASE_CHAR_TABLE[ccUpper][s^];
      c2 := CASE_CHAR_TABLE[ccUpper][sub^];
      if c1 <> c2 then
      begin
        Result := False;
        Break;
      end;
      Inc(sub);
      Inc(s);
    until sub^ = #0;
  end;
end;

function RBStrBeginWith(const s, sub: RawByteString): Boolean;
begin
  Result := BeginWithA(PAnsiChar(s), length(s), PAnsiChar(sub), length(sub));
end;

function RBStrIBeginWith(const s, sub: RawByteString): Boolean;
begin
  Result := IBeginWithA(PAnsiChar(s), length(s), PAnsiChar(sub), length(sub));
end;

{$endregion}

function GetSectionBetweenA2(s: PAnsiChar; len: Integer; const prefix: RawByteString; const suffix: array of AnsiChar;
  out SectionBegin, SectionEnd: PAnsiChar; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  sec, prefixSec, res: TAnsiCharSection;
begin
  sec._begin := s;
  sec._end := s + len;
  prefixSec.SetStr(prefix);
  res := sec.GetSectionBetween2(prefixSec, suffix, EndingNoSuffix, flags);

  if res.length > 0 then
  begin
    SectionBegin := res._begin;
    SectionEnd := res._end;
    Result := True;
  end
  else
    Result := False;
end;

function RBStrGetSectionBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  out P1, P2: Integer; first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  s, SecBegin, SecEnd: PAnsiChar;
begin
  Result := False;

  if src <> '' then
  begin
    s := PAnsiChar(src);

    if last = 0 then
      last := length(src) + 1;

    Result := GetSectionBetweenA2(s + first - 1, last - first, prefix, suffix, SecBegin, SecEnd, EndingNoSuffix, flags);

    if Result then
    begin
      P1 := SecBegin + 1 - s;
      P2 := SecEnd + 1 - s;
    end;
  end;
end;

function RBStrGetTrimedSectionBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  out P1, P2: Integer; first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  tmp: Integer;
begin
  Result := RBStrGetSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags);

  if Result then
  begin
    while (P1 < P2) and (src[P1] <= #32) do
      Inc(P1);

    tmp := P2 - 1;

    while (tmp >= P1) and (src[tmp] <= #32) do
      Dec(tmp);

    P2 := tmp + 1;
  end;
end;

function RBStrGetSubstrBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): RawByteString;
var
  P1, P2: Integer;
begin
  if RBStrGetSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
    Result := Copy(src, P1, P2 - P1)
  else
    Result := '';
end;

function RBStrGetTrimedSubstrBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): RawByteString;
var
  P1, P2: Integer;
begin
  if RBStrGetSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
    Result := RBStrTrimCopy(src, P1, P2 - P1)
  else
    Result := '';
end;

function RBStrTryGetInt64Between2(const src, prefix: RawByteString; const suffix: array of AnsiChar; out value: Int64;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  Result := False;

  if RBStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    value := BufToInt64A(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      value := 0
    else
      Result := True;
  end;
end;

function RBStrGetInt64Between2(const src, prefix: RawByteString; const suffix: array of AnsiChar; first, last: Integer;
  EndingNoSuffix: Boolean; flags: TStringSearchFlags): Int64;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  if RBStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    Result := BufToInt64A(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0
  end
  else
    Result := 0;
end;

function RBStrTryGetIntegerBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  out value: Integer; first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  Result := False;

  if RBStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    value := BufToIntA(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      value := 0
    else
      Result := True;
  end;
end;

function RBStrGetIntegerBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Integer;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  if RBStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    Result := BufToIntA(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0
  end
  else
    Result := 0;
end;

function RBStrTryGetBoolBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; out value: Boolean;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
begin
  if RBStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    value := StrToBoolA(PAnsiChar(src) + P1 - 1, P2 - P1, False);
    Result := True;
  end
  else
    Result := False
end;

function RBStrGetBoolBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; def: Boolean;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean; overload;
var
  P1, P2: Integer;
begin
  if RBStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
    Result := StrToBoolA(PAnsiChar(src) + P1 - 1, P2 - P1, def)
  else
    Result := def;
end;

function RBStrTryGetFloatBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; out value: Double;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  Result := False;

  value := 0;

  if RBStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    try
      value := BufToFloatA(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

      if not Assigned(c) then
        Result := True;
    except

    end;
  end;
end;

function RBStrGetFloatBetween2(const src, prefix: RawByteString; const suffix: array of AnsiChar; first, last: Integer;
  EndingNoSuffix: Boolean; flags: TStringSearchFlags): Double;
var
  P1, P2: Integer;
  c: PAnsiChar;
begin
  if RBStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    Result := BufToFloatA(PAnsiChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0;
  end
  else
    Result := 0;
end;

// 提取夹在prefix和suffix中任一字符之间的子串
function GetSectionBetweenW2(s: PWideChar; len: Integer; const prefix: u16string; const suffix: array of WideChar;
  out SectionBegin, SectionEnd: PWideChar; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  sec, prefixSec, res: TWideCharSection;
begin
  sec._begin := s;
  sec._end := s + len;
  prefixSec.SetUStr(prefix);
  res := sec.GetSectionBetween2(prefixSec, suffix, EndingNoSuffix, flags);

  if res.length > 0 then
  begin
    SectionBegin := res._begin;
    SectionEnd := res._end;
    Result := True;
  end
  else
    Result := False;
end;

function UStrGetSectionBetween2(const src, prefix: u16string; const suffix: array of WideChar; out P1, P2: Integer;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  s, SecBegin, SecEnd: PWideChar;
begin
  Result := False;

  if src <> '' then
  begin
    s := PWideChar(src);

    if last = 0 then
      last := length(src) + 1;

    Result := GetSectionBetweenW2(s + first - 1, last - first, prefix, suffix, SecBegin, SecEnd, EndingNoSuffix, flags);

    if Result then
    begin
      P1 := SecBegin + 1 - s;
      P2 := SecEnd + 1 - s;
    end;
  end;
end;

function UStrGetTrimedSectionBetween2(const src, prefix: u16string; const suffix: array of WideChar;
  out P1, P2: Integer; first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  tmp: Integer;
begin
  Result := UStrGetSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags);

  if Result then
  begin
    while (P1 < P2) and (src[P1] <= #32) do
      Inc(P1);

    tmp := P2 - 1;

    while (tmp >= P1) and (src[tmp] <= #32) do
      Dec(tmp);

    P2 := tmp + 1;
  end;
end;

function UStrGetSubstrBetween2(const src, prefix: u16string; const suffix: array of WideChar; first, last: Integer;
  EndingNoSuffix: Boolean; flags: TStringSearchFlags): u16string;
var
  P1, P2: Integer;
begin
  if UStrGetSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
    Result := Copy(src, P1, P2 - P1)
  else
    Result := '';
end;

function UStrGetTrimedSubstrBetween2(const src, prefix: u16string; const suffix: array of WideChar;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): u16string;
var
  P1, P2: Integer;
begin
  if UStrGetSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
    Result := UStrTrimCopy(src, P1, P2 - P1)
  else
    Result := '';
end;

function UStrTryGetInt64Between2(const src, prefix: u16string; const suffix: array of WideChar; out value: Int64;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  Result := False;

  if UStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    c := nil;
    value := BufToInt64W(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      value := 0
    else
      Result := True;
  end;
end;

function UStrGetInt64Between2(const src, prefix: u16string; const suffix: array of WideChar; first, last: Integer;
  EndingNoSuffix: Boolean; flags: TStringSearchFlags): Int64;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  if UStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    c := nil;

    Result := BufToInt64W(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0;
  end
  else
    Result := 0;
end;

function UStrTryGetIntegerBetween2(const src, prefix: u16string; const suffix: array of WideChar;
  out value: Integer; first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  Result := False;

  if UStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    c := nil;
    value := BufToIntW(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      value := 0
    else
      Result := True;
  end;
end;

function UStrGetIntegerBetween2(const src, prefix: u16string; const suffix: array of WideChar;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Integer;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  if UStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    c := nil;

    Result := BufToIntW(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0;
  end
  else
    Result := 0;
end;

function UStrTryGetBoolBetween2(const src, prefix: u16string; const suffix: array of WideChar; out value: Boolean;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
begin
  if UStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    value := StrToBoolW(PWideChar(src) + P1 - 1, P2 - P1, False);
    Result := True;
  end
  else
    Result := False
end;

function UStrGetBoolBetween2(const src, prefix: u16string; const suffix: array of WideChar; def: Boolean;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
begin
  if UStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
    Result := StrToBoolW(PWideChar(src) + P1 - 1, P2 - P1, def)
  else
    Result := def;
end;

function UStrTryGetFloatBetween2(const src, prefix: u16string; const suffix: array of WideChar; out value: Double;
  first, last: Integer; EndingNoSuffix: Boolean; flags: TStringSearchFlags): Boolean;
var
  P1, P2: Integer;
begin
  value := 0;
  if UStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    try
      value := BufToFloatW(PWideChar(src) + P1 - 1, P2 - P1, nil);
      Result := True;
    except
      Result := False;
    end;
  end
  else
    Result := False;
end;

function UStrGetFloatBetween2(const src, prefix: u16string; const suffix: array of WideChar; first, last: Integer;
  EndingNoSuffix: Boolean; flags: TStringSearchFlags): Double;
var
  P1, P2: Integer;
  c: PWideChar;
begin
  if UStrGetTrimedSectionBetween2(src, prefix, suffix, P1, P2, first, last, EndingNoSuffix, flags) then
  begin
    Result := BufToFloatW(PWideChar(src) + P1 - 1, P2 - P1, @c);

    if Assigned(c) then
      Result := 0;
  end
  else
    Result := 0;
end;

function UStrCopyUntil(const src: u16string; const suffix: array of WideChar; first, last: Integer;
  EndingNoSuffix: Boolean = True): u16string;
var
  i: Integer;
  p: Integer;
begin
  Result := '';
  p := first;
  while p <= last do
  begin
    for i := Low(suffix) to high(suffix) do
    begin
      if src[p] = suffix[i] then
      begin
        Result := Copy(src, first, p - first);
        Exit;
      end;
    end;

    Inc(p);
  end;

  (*
    在字符串结尾允许不带suffix。比如prefix为'ab', suffix为[';', ',']时，
    从'abcde;123'、'abcde'、'abcde,123'三个src中都能提取出'cde'
    *)
  if (p > Integer(length(src))) and EndingNoSuffix then
    Result := Copy(src, first, p - first);
end;

function UStrTrimCopy(const s: u16string; first, len: Integer): u16string;
begin
  if first > length(s) then
    Result := ''
  else
  begin
    if (len < 0) or (len > length(s) + 1 - first) then
      len := length(s) + 1 - first;

    Result := UStrSection(s, first, first + len).trim.ToUStr;
  end;
end;

function RBStrTrimCopy(const s: RawByteString; first, len: Integer): RawByteString;
begin
  if first > length(s) then
    Result := ''
  else
  begin
    if (len < 0) or (len > length(s) + 1 - first) then
      len := length(s) + 1 - first;

    Result := RBStrSection(s, first, first + len).trim.toString;
  end;
end;

function BStrTrimCopy(const s: WideString; first, len: Integer): WideString;
begin
  if first > length(s) then
    Result := ''
  else
  begin
    if (len < 0) or (len > length(s) + 1 - first) then
      len := length(s) + 1 - first;

    Result := BStrSection(s, first, first + len).trim.ToUStr;
  end;
end;

function GetTagClosedW(s: PWideChar; len: Integer; BeginTag, EndTag: WideChar; out TagBegin: PWideChar): Integer;
var
  P1, P2, strend: PWideChar;
  n: Integer;
begin
  TagBegin := nil;
  Result := 0;
  strend := s + len;

  P1 := s;

  while (P1 < strend) and (P1^ <> BeginTag) do
    Inc(P1);

  if P1 >= strend then
    Exit;

  P2 := P1 + 1;

  n := 1;

  while (n > 0) and (P2 < strend) do
  begin
    if P2^ = BeginTag then
      Inc(n)
    else if P2^ = EndTag then
      Dec(n);
    Inc(P2);
  end;

  if n = 0 then
  begin
    TagBegin := P1;
    Result := P2 - P1;
  end;
end;

function UStrGetTagClosed(const s: u16string; BeginTag, EndTag: WideChar; first, last: Integer): u16string;
var
  p: PWideChar;
  len: Integer;
begin
  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > length(s)) then
    last := length(s) + 1;

  if first >= last then
    Result := ''
  else
  begin
    len := GetTagClosedW(PWideChar(s) + first - 1, last - first, BeginTag, EndTag, p);
    SetLength(Result, len);
    Move(p^, Pointer(Result)^, len * 2);
  end;
end;

function IsValidEmailA(str: PAnsiChar; len: Integer): Boolean;
var
  i, _dot, _at: Integer;
begin
  Result := False;

  _dot := -1;
  _at := -1;

  for i := 0 to len - 1 do
  begin
    case str[i] of
      '0' .. '9', 'a' .. 'z', 'A' .. 'Z', '_', '-':
        ;

      '.':
        if  (_at <> -1) and (i>(_at+1)) then
          _dot := i;

      '@':
        begin
          if _at <> -1 then
            Exit;
          _at := i;
        end
      else
        Exit;
    end;
  end;

  Result := (_at > 0) and (_dot > (_at+1)) and ((len-1)>_dot);
end;

function RBStrIsValidEmail(const s: RawByteString): Boolean;
begin
  Result := IsValidEmailA(PAnsiChar(s), length(s));
end;

function IsValidEmailW(str: PWideChar; len: Integer): Boolean;
var
  i, _dot, _at: Integer;
begin
  Result := False;

  _dot := -1;
  _at := -1;

  for i := 0 to len - 1 do
  begin
    case str[i] of
      '0' .. '9', 'a' .. 'z', 'A' .. 'Z', '_', '-':
        ;

      '.':
        if (_at <> -1) and (i>(_at+1)) then
          _dot := i;

      '@':
        begin
          if _at <> -1 then
            Exit;
          _at := i;
        end
      else
        Exit;
    end;
  end;

  Result := (_at > 0) and (_dot > (_at+1)) and ((len-1)>_dot);
end;

function UStrIsValidEmail(const s: u16string): Boolean;
begin
  Result := IsValidEmailW(PWideChar(s), length(s));
end;

function BStrIsValidEmail(const s: WideString): Boolean;
begin
  Result := IsValidEmailW(PWideChar(s), length(s));
end;

function RBStrExtract(const s, ValidChars: RawByteString; callback: TRBStrSectionProc): RawByteString;
var
  i, P1, P2, L: Integer;
  found: Boolean;
begin
  Result := '';

  P1 := 1;
  L := length(s);

  while P1 <= L do
  begin
    while P1 <= L do
    begin
      found := False;

      for i := 1 to length(ValidChars) do
        if ValidChars[i] = s[P1] then
        begin
          found := True;
          Break;
        end;

      if found then
        Break;

      Inc(P1);
    end;

    if P1 > L then
      Exit;

    P2 := P1 + 1;

    while P2 <= L do
    begin
      found := False;

      for i := 1 to length(ValidChars) do
        if ValidChars[i] = s[P2] then
        begin
          found := True;
          Break;
        end;

      if not found then
        Break;

      Inc(P2);
    end;

    if not Assigned(callback) or callback(PAnsiChar(s) + P1 - 1, P2 - P1) then
    begin
      if (P1 = 1) and (P2 = L + 1) then
        Result := s
      else
        Result := Copy(s, P1, P2 - P1);

      Break;
    end
    else
      P1 := P2;
  end;
end;

function RBStrExtractEmail(const s: RawByteString): RawByteString;
begin
  Result := RBStrExtract(s, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.@_-', IsValidEmailA);
end;

function RBStrExtractQQID(const s: RawByteString): RawByteString;
begin
  Result := RBStrExtract(s, '0123456789', IsQQA);
end;

function UStrExtract(const s, ValidChars: u16string; callback: TUStrSectionProc): u16string;
var
  i, P1, P2, L: Integer;
  found: Boolean;
begin
  Result := '';

  P1 := 1;
  L := length(s);

  while P1 <= L do
  begin
    while P1 <= L do
    begin
      found := False;

      for i := 1 to length(ValidChars) do
        if ValidChars[i] = s[P1] then
        begin
          found := True;
          Break;
        end;

      if found then
        Break;

      Inc(P1);
    end;

    if P1 > L then
      Exit;

    P2 := P1 + 1;

    while P2 <= L do
    begin
      found := False;

      for i := 1 to length(ValidChars) do
        if ValidChars[i] = s[P2] then
        begin
          found := True;
          Break;
        end;

      if not found then
        Break;

      Inc(P2);
    end;

    if not Assigned(callback) or callback(PWideChar(s) + P1 - 1, P2 - P1) then
    begin
      if (P1 = 1) and (P2 = L + 1) then
        Result := s
      else
        Result := Copy(s, P1, P2 - P1);

      Break;
    end
    else
      P1 := P2;
  end;
end;

function UStrExtractEmail(const s: u16string): u16string;
begin
  Result := UStrExtract(s, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.@_-', IsValidEmailW);
end;

function UStrExtractQQID(const s: u16string): u16string;
begin
  Result := UStrExtract(s, '0123456789', IsQQW);
end;

var
  g_PasswordChars: u16string;

function IsValidPasswordW(str: PWideChar; len: Integer): Boolean;
begin
  Result := len > 5;
end;

function IsValidPassword(const str: u16string): Boolean;
var
  i: Integer;
begin
  if Length(str) <= 5 then Result := False
  else begin
    Result := True;
    for i := 1 to Length(str) do
      if UStrScan(g_PasswordChars, str[i]) <= 0 then
      begin
        Result := False;
        Break;
      end;
  end;
end;

function UStrExtractPassword(const s: u16string): u16string;
begin
  Result := UStrExtract(s, g_PasswordChars, IsValidPasswordW);
end;

function ExtractIntegerA(str: PAnsiChar; len: Integer): Int64;
var
  P1: Integer;
begin
  Result := 0;

  P1 := 0;

  while (P1 < len) and ((str[P1] < '0') or (str[P1] > '9')) do
    Inc(P1);

  if P1 >= len then
    Exit;

  while (P1 < len) and ((str[P1] >= '0') and (str[P1] <= '9')) do
  begin
    Result := Result * 10 + Ord(str[P1]) - $30;
    Inc(P1);
  end;
end;

function RBStrExtractInteger(const str: RawByteString; first, last: Integer): Int64;
begin
  if first <= 0 then
    first := 1;
  if (last <= 0) or (last > length(str)) then
    last := length(str) + 1;
  Result := ExtractIntegerA(PAnsiChar(str) + first - 1, last - first);
end;

function ExtractFloatA(str: PAnsiChar; len: Integer): Double;
var
  P1: Integer;
begin
  Result := 0;

  P1 := 0;

  while (P1 < len) and ((str[P1] < '0') or (str[P1] > '9')) do
    Inc(P1);

  if P1 >= len then
    Exit;

  Result := BufToFloatA(str + P1, len - P1);
end;

function RBStrExtractFloat(const str: RawByteString; first, last: Integer): Double;
begin
  if first <= 0 then
    first := 1;
  if (last <= 0) or (last > length(str)) then
    last := length(str) + 1;
  Result := ExtractFloatA(PAnsiChar(str) + first - 1, last - first);
end;

function RBStrExtractIntegers(const str: RawByteString; var numbers: array of Int64): Integer;
var
  i, P1: Integer;
  v: Int64;
begin
  Result := 0;

  if length(numbers) = 0 then
    Exit;

  P1 := -1;
  v := 0;

  for i := 1 to length(str) do
  begin
    if (str[i] >= '0') and (str[i] <= '9') then
    begin
      if P1 = -1 then
      begin
        P1 := i;
        v := Ord(str[i]) - $30;
      end
      else
        v := v * 10 + Ord(str[i]) - $30;
    end
    else
    begin
      if P1 <> -1 then
      begin
        P1 := -1;
        numbers[Result] := v;
        Inc(Result);
        if Result >= length(numbers) then
          Break;
      end;
    end;
  end;

  if P1 <> -1 then
  begin
    numbers[Result] := v;
    Inc(Result);
  end;
end;

function ExtractIntegerW(str: PWideChar; len: Integer): Int64;
var
  P1: Integer;
begin
  Result := 0;

  P1 := 0;

  while (P1 < len) and ((str[P1] < '0') or (str[P1] > '9')) do
    Inc(P1);

  if P1 >= len then
    Exit;

  while (P1 < len) and ((str[P1] >= '0') and (str[P1] <= '9')) do
  begin
    Result := Result * 10 + Ord(str[P1]) - $30;
    Inc(P1);
  end;
end;

function UStrExtractInteger(const str: u16string; first, last: Integer): Int64;
begin
  if first <= 0 then
    first := 1;
  if (last <= 0) or (last > length(str)) then
    last := length(str) + 1;
  Result := ExtractIntegerW(PWideChar(str) + first - 1, last - first);
end;

function BStrExtractInteger(const str: WideString; first, last: Integer): Int64;
begin
  if first <= 0 then
    first := 1;
  if (last <= 0) or (last > length(str)) then
    last := length(str) + 1;
  Result := ExtractIntegerW(PWideChar(str) + first - 1, last - first);
end;

function ExtractFloatW(str: PWideChar; len: Integer): Double;
var
  P1: Integer;
begin
  Result := 0;

  P1 := 0;

  while (P1 < len) and ((str[P1] < '0') or (str[P1] > '9')) do
    Inc(P1);

  if P1 >= len then
    Exit;

  Result := BufToFloatW(str + P1, len - P1);
end;

function UStrExtractFloat(const str: u16string; first, last: Integer): Double;
begin
  if first <= 0 then
    first := 1;
  if (last <= 0) or (last > length(str)) then
    last := length(str) + 1;
  Result := ExtractFloatW(PWideChar(str) + first - 1, last - first);
end;

function BStrExtractFloat(const str: WideString; first, last: Integer): Double;
begin
  if first <= 0 then
    first := 1;
  if (last <= 0) or (last > length(str)) then
    last := length(str) + 1;
  Result := ExtractFloatW(PWideChar(str) + first - 1, last - first);
end;

function UStrExtractIntegers(const str: u16string; var numbers: array of Int64): Integer;
var
  i, P1: Integer;
  v: Int64;
begin
  Result := 0;

  if length(numbers) = 0 then
    Exit;

  P1 := -1;
  v := 0;

  for i := 1 to length(str) do
  begin
    if (str[i] >= '0') and (str[i] <= '9') then
    begin
      if P1 = -1 then
      begin
        P1 := i;
        v := Ord(str[i]) - $30;
      end
      else
        v := v * 10 + Ord(str[i]) - $30;
    end
    else
    begin
      if P1 <> -1 then
      begin
        P1 := -1;
        numbers[Result] := v;
        Inc(Result);
        if Result >= length(numbers) then
          Break;
      end;
    end;
  end;

  if P1 <> -1 then
  begin
    numbers[Result] := v;
    Inc(Result);
  end;
end;

function BStrExtractIntegers(const str: WideString; var numbers: array of Int64): Integer;
var
  i, P1: Integer;
  v: Int64;
begin
  Result := 0;

  if length(numbers) = 0 then
    Exit;

  P1 := -1;
  v := 0;

  for i := 1 to length(str) do
  begin
    if (str[i] >= '0') and (str[i] <= '9') then
    begin
      if P1 = -1 then
      begin
        P1 := i;
        v := Ord(str[i]) - $30;
      end
      else
        v := v * 10 + Ord(str[i]) - $30;
    end
    else
    begin
      if P1 <> -1 then
      begin
        P1 := -1;
        numbers[Result] := v;
        Inc(Result);
        if Result >= length(numbers) then
          Break;
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
  if offset < 0 then
    offset := 0;

  max_len := len - offset;

  if max_len < 0 then
    max_len := 0;

  if (num < 0) or (num > max_len) then
    num := max_len;

  SetLength(Result, num);

  if num > 0 then
    Move(PAnsiChar(s)[offset], Pointer(Result)^, num);
end;

function StrSliceA(const s: RawByteString; offset, num: Integer): RawByteString;
begin
  Result := StrSliceA(PAnsiChar(s), length(s), offset, num);
end;

procedure StrSplit(const str, delimiter: string; list: TStrings);
var
  P1, P2: Integer;
  L: Integer;
begin
  P1 := 1;
  L := length(str);

  list.clear;

  while True do
  begin
    while (P1 <= L) and (StrScan(delimiter, str[P1]) > 0) do
      Inc(P1);

    if P1 > L then
      Break;

    P2 := P1 + 1;

    while (P2 <= L) and (StrScan(delimiter, str[P2]) <= 0) do
      Inc(P2);

    list.add(Copy(str, P1, P2 - P1));

    P1 := P2 + 1;
  end;
end;

procedure UStrSplit2(const s, delimiter: u16string; out s1, s2: u16string; BeginIndex, last: Integer);
var
  p: Integer;
begin
  if BeginIndex <= 0 then
    BeginIndex := 1;

  if (last <= 0) or (last > Integer(length(s))) then
    last := length(s) + 1;

  if last <= BeginIndex then
  begin
    s1 := '';
    s2 := '';
  end
  else
  begin
    p := UStrPos(delimiter, s, BeginIndex, last);

    if p <= 0 then
    begin
      s1 := Copy(s, BeginIndex, last - BeginIndex);
      s2 := '';
    end
    else
    begin
      s1 := Copy(s, BeginIndex, p - BeginIndex);
      Inc(p, length(delimiter));
      s2 := Copy(s, p, last - p);
    end;
  end;
end;

function UStrGetDelimiteredSection(const s, delimiter: u16string; index, first, last: Integer): u16string;
var
  P1, P2, n: Integer;
begin
  Result := '';

  if first <= 0 then
    first := 1;

  if (last <= 0) or (last > length(s)) then
    last := length(s) + 1;

  if last <= first then
    Exit;

  P1 := first;
  n := 0;

  while P1 < last do
  begin
    P2 := UStrPos(delimiter, s, P1, last);

    if P2 <= 0 then
      P2 := last;

    if n = index then
    begin
      Result := Copy(s, P1, P2 - P1);
      Break;
    end;

    P1 := P2 + length(delimiter);
    Inc(n);
  end;
end;

function TrimStrings(strs: TStrings): TStrings;
var
  i: Integer;
begin
  strs.BeginUpdate;

  try
    for i := 0 to strs.count - 1 do
      strs[i] := trim(strs[i]);
  finally
    strs.EndUpdate;
  end;

  Result := strs;
end;

function DeleteBlankItems(strs: TStrings): TStrings;
var
  i: Integer;
begin
  strs.BeginUpdate;

  try
    for i := strs.count - 1 downto 0 do
      if strs[i] = '' then
        strs.delete(i);
  finally
    strs.EndUpdate;
  end;

  Result := strs;
end;

function RBStrsTrim(strs: TRawByteStrings): TRawByteStrings;
var
  i: Integer;
begin
  strs.BeginUpdate;

  try
    for i := 0 to strs.count - 1 do
      strs[i] := RBStrTrim(strs[i]);
  finally
    strs.EndUpdate;
  end;

  Result := strs;
end;

function RBStrsDeleteBlankItems(strs: TRawByteStrings): TRawByteStrings;
var
  i: Integer;
begin
  strs.BeginUpdate;

  try
    for i := strs.count - 1 downto 0 do
      if strs[i] = '' then
        strs.delete(i);
  finally
    strs.EndUpdate;
  end;

  Result := strs;
end;

function UStrsTrim(strs: TUnicodeStrings): TUnicodeStrings;
var
  i: Integer;
begin
  strs.BeginUpdate;

  try
    for i := 0 to strs.count - 1 do
      strs[i] := UStrTrim(strs[i]);
  finally
    strs.EndUpdate;
  end;

  Result := strs;
end;

function UStrsDeleteBlankItems(strs: TUnicodeStrings): TUnicodeStrings;
var
  i: Integer;
begin
  strs.BeginUpdate;

  try
    for i := strs.count - 1 downto 0 do
      if strs[i] = '' then
        strs.delete(i);
  finally
    strs.EndUpdate;
  end;

  Result := strs;
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

function RBStrSplit(const str: RawByteString; const delimiters: array of AnsiChar;
  var strs: array of RawByteString): Integer;
var
  P1, P2: Integer;
  L, n: Integer;
begin
  P1 := 1;
  L := length(str);

  n := 0;

  while P1 <= L do
  begin
    while (P1 <= L) and (IndexOfCharA(delimiters, str[P1]) >= 0) do
      Inc(P1);

    if P1 > L then
      Break;

    P2 := P1 + 1;

    while (P2 <= L) and (IndexOfCharA(delimiters, str[P2]) = -1) do
      Inc(P2);

    if length(strs) > n then
    begin
      strs[n] := Copy(str, P1, P2 - P1);
      Inc(n);
    end;

    if n >= length(strs) then
      Break;

    P1 := P2 + 1;
  end;

  Result := n;
end;

procedure RBStrSplit2(const s, delimiter: RawByteString; out s1, s2: RawByteString; BeginIndex: Integer = 1;
  last: Integer = 0);
var
  p: Integer;
begin
  if BeginIndex <= 0 then
    BeginIndex := 1;

  if (last <= 0) or (last > Integer(length(s))) then
    last := length(s) + 1;

  if last <= BeginIndex then
  begin
    s1 := '';
    s2 := '';
  end
  else
  begin
    p := RBStrPos(delimiter, s, BeginIndex, last);

    if p <= 0 then
    begin
      s1 := Copy(s, BeginIndex, last - BeginIndex);
      s2 := '';
    end
    else
    begin
      s1 := Copy(s, BeginIndex, p - BeginIndex);
      Inc(p, length(delimiter));
      s2 := Copy(s, p, last - p);
    end;
  end;
end;

function StrToDateTimeA(const s: RawByteString; out dt: TDateTime): Boolean;
var
  numbers: array [0 .. 6] of Int64;
  i, n: Integer;
begin
  n := RBStrExtractIntegers(s, numbers);

  for i := n to 6 do
    numbers[i] := 0;

  if n >= 3 then
    Result := TryEncodeDateTime(numbers[0], numbers[1], numbers[2], numbers[3], numbers[4], numbers[5], numbers[6], dt)
  else
    Result := False;
end;

function UStrToDateTime(const s: u16string; out dt: TDateTime): Boolean;
var
  numbers: array [0 .. 6] of Int64;
  i, n: Integer;
begin
  n := UStrExtractIntegers(s, numbers);

  for i := n to 6 do
    numbers[i] := 0;

  if n >= 3 then
    Result := TryEncodeDateTime(numbers[0], numbers[1], numbers[2], numbers[3], numbers[4], numbers[5], numbers[6], dt)
  else
    Result := False;
end;

function GetFloatBeforeA(str: PAnsiChar; len: Integer; substr: PAnsiChar; sublen: Integer; var value: Double): Boolean;
var
  p, P1, P2: PAnsiChar;
  dot: Boolean; // 小数点是否已经出现
  ratio: Integer;
  dv: Double;
begin
  Result := False;
  dv := 0;
  p := str + 1;

  while p < str + len - sublen do
  begin
    P1 := StrPosA(substr, sublen, p, str + len - p);

    if P1 = nil then
      Break;

    P2 := P1 - 1;

    if (P2^ >= '0') and (P2^ <= '9') then
    begin
      ratio := 1;
      dv := 0;
      dot := False;
      while P2 >= str do
      begin
        if (P2^ >= '0') and (P2^ <= '9') then
        begin
          dv := dv + (Ord(P2^) and $0F) * ratio;
          ratio := ratio * 10;
        end
        else if P2^ = '.' then
        begin
          if dot then
            Break;

          dot := True;

          dv := dv / ratio;

          ratio := 1;
        end
        else
          Break;

        Dec(P2);
      end;

      Result := True;
      Break;
    end;

    p := P1 + sublen;
  end;

  if Result then
    value := dv;
end;

function GetFloatBeforeW(str: PWideChar; len: Integer; substr: PWideChar; sublen: Integer; var value: Double): Boolean;
var
  p, P1, P2: PWideChar;
  dot: Boolean; // 小数点是否已经出现
  ratio: Integer;
  dv: Double;
begin
  Result := False;
  p := str + 1;
  dv := 0;

  while p < str + len - sublen do
  begin
    P1 := StrPosW(substr, sublen, p, str + len - p);

    if P1 = nil then
      Break;

    P2 := P1 - 1;

    if (P2^ >= '0') and (P2^ <= '9') then
    begin
      ratio := 1;
      dv := 0;
      dot := False;
      while P2 >= str do
      begin
        if (P2^ >= '0') and (P2^ <= '9') then
        begin
          dv := dv + (Ord(P2^) and $0F) * ratio;
          ratio := ratio * 10;
        end
        else if P2^ = '.' then
        begin
          if dot then
            Break;

          dot := True;

          dv := dv / ratio;

          ratio := 1;
        end
        else
          Break;

        Dec(P2);
      end;

      Result := True;
      Break;
    end;

    p := P1 + sublen;
  end;

  if Result then
    value := dv;
end;

function RBStrGetFloatBefore(const s, suffix: RawByteString; var value: Double): Boolean;
begin
  Result := GetFloatBeforeA(PAnsiChar(Pointer(s)), length(s), PAnsiChar(Pointer(suffix)), length(suffix), value);
end;

function UStrGetFloatBefore(const s, suffix: u16string; var value: Double): Boolean;
begin
  Result := GetFloatBeforeW(PWideChar(Pointer(s)), length(s), PWideChar(Pointer(suffix)), length(suffix), value);
end;

function BStrGetFloatBefore(const s, suffix: WideString; var value: Double): Boolean;
begin
  Result := GetFloatBeforeW(PWideChar(Pointer(s)), length(s), PWideChar(Pointer(suffix)), length(suffix), value);
end;

function GetFloatBefore(const s, suffix: RawByteString; var value: Double): Boolean;
begin
  Result := GetFloatBeforeA(PAnsiChar(Pointer(s)), length(s), PAnsiChar(Pointer(suffix)), length(suffix), value);
end;

function GetFloatBefore(const s, suffix: u16string; var value: Double): Boolean;
begin
  Result := GetFloatBeforeW(PWideChar(Pointer(s)), length(s), PWideChar(Pointer(suffix)), length(suffix), value);
end;

function GetFloatBefore(const s, suffix: WideString; var value: Double): Boolean;
begin
  Result := GetFloatBeforeW(PWideChar(Pointer(s)), length(s), PWideChar(Pointer(suffix)), length(suffix), value);
end;

function GetIntegerBeforeA(str: PAnsiChar; len: Integer; substr: PAnsiChar; sublen: Integer;
  var value: Integer): Boolean;
var
  p, P1, P2: PAnsiChar;
  ratio, dv: Integer;
begin
  Result := False;
  dv := 0;
  p := str + 1;

  while p < str + len - sublen do
  begin
    P1 := StrPosA(substr, sublen, p, str + len - p);

    if P1 = nil then
      Break;

    P2 := P1 - 1;

    if (P1 <> str) and (P2^ >= '0') and (P2^ <= '9') then
    begin
      dv := 0;
      ratio := 1;

      while P2 >= str do
      begin
        if (P2^ >= '0') and (P2^ <= '9') then
        begin
          dv := dv + (Ord(P2^) and $0F) * ratio;
          ratio := ratio * 10;
          Dec(P2);
        end
        else
          Break;
      end;

      Result := True;
    end;

    p := P1 + sublen;
  end;

  if Result then
    value := dv;
end;

function GetIntegerBeforeW(str: PWideChar; len: Integer; substr: PWideChar; sublen: Integer;
  var value: Integer): Boolean;
var
  p, P1, P2: PWideChar;
  ratio, dv: Integer;
begin
  Result := False;
  dv := 0;
  p := str + 1;

  while p < str + len - sublen do
  begin
    P1 := StrPosW(substr, sublen, p, str + len - p);

    if P1 = nil then
      Break;

    P2 := P1 - 1;

    if (P1 <> str) and (P2^ >= '0') and (P2^ <= '9') then
    begin
      dv := 0;
      ratio := 1;

      while P2 >= str do
      begin
        if (P2^ >= '0') and (P2^ <= '9') then
        begin
          dv := dv + (Ord(P2^) and $0F) * ratio;
          ratio := ratio * 10;
          Dec(P2);
        end
        else
          Break;
      end;

      Result := True;
    end;

    p := P1 + sublen;
  end;

  if Result then
    value := dv;
end;

function RBStrGetIntegerBefore(const s, suffix: RawByteString; var value: Integer): Boolean;
begin
  Result := GetIntegerBeforeA(PAnsiChar(Pointer(s)), length(s), PAnsiChar(Pointer(suffix)), length(suffix), value);
end;

function UStrGetIntegerBefore(const s, suffix: u16string; var value: Integer): Boolean;
begin
  Result := GetIntegerBeforeW(PWideChar(Pointer(s)), length(s), PWideChar(Pointer(suffix)), length(suffix), value);
end;

function BStrGetIntegerBefore(const s, suffix: WideString; var value: Integer): Boolean;
begin
  Result := GetIntegerBeforeW(PWideChar(Pointer(s)), length(s), PWideChar(Pointer(suffix)), length(suffix), value);
end;

function GetIntegerBefore(const s, suffix: RawByteString; var value: Integer): Boolean;
begin
  Result := GetIntegerBeforeA(PAnsiChar(Pointer(s)), length(s), PAnsiChar(Pointer(suffix)), length(suffix), value);
end;

function GetIntegerBefore(const s, suffix: u16string; var value: Integer): Boolean;
begin
  Result := GetIntegerBeforeW(PWideChar(Pointer(s)), length(s), PWideChar(Pointer(suffix)), length(suffix), value);
end;

function GetIntegerBefore(const s, suffix: WideString; var value: Integer): Boolean;
begin
  Result := GetIntegerBeforeW(PWideChar(Pointer(s)), length(s), PWideChar(Pointer(suffix)), length(suffix), value);
end;

function PasswordCharDiff(ch1, ch2: AnsiChar): Integer;
var
  t1, t2: Integer;
begin
  if ch1 = ch2 then
  begin
    Result := 0;
    Exit;
  end;

  t1 := Ord(ch1);
  t2 := Ord(ch2);

  if ((ch1 in ['a' .. 'z']) or (ch1 in ['A' .. 'Z'])) and ((ch2 in ['a' .. 'z']) or (ch2 in ['A' .. 'Z'])) then
    Result := t2 - t1
  else
  begin
    if ch1 in ['a' .. 'z'] then
      Dec(t1, 32);
    if ch2 in ['a' .. 'z'] then
      Dec(t2, 32);
    Result := t2 - t1;
  end;
end;

function ExcludePrefix(const s, prefix: string): string;
begin
  if s.StartsWith(prefix) then
    Result := Copy(s, Length(prefix) + 1)
  else
    Result := '';
end;

function PasswordScore(const password: RawByteString): Integer;
var
  i, diff, v1, v2: Integer;
  chmin, chmax: AnsiChar;
begin
  Result := 0;

  if password = '' then
    Exit;

  chmin := password[1];
  chmax := password[1];

  v1 := 0;
  v2 := 0;

  for i := 2 to length(password) do
  begin
    if password[i] > chmax then
      chmax := password[i];
    if password[i] < chmin then
      chmin := password[i];

    diff := PasswordCharDiff(password[i], password[i - 1]);

    Inc(v1, diff * diff);

    if i > 2 then
    begin
      diff := PasswordCharDiff(password[i], password[i - 2]);
      Inc(v2, diff * diff);
    end;
  end;

  if v1 > v2 then
    v1 := v2;

  Result := Trunc(sqrt(abs((Ord(chmax) - Ord(chmin))))) + length(password) + Trunc(sqrt(v1));
end;

function IsIntegerA(str: PAnsiChar; len: Integer): Boolean;
var
  i: Integer;
begin
  if len <= 0 then
    Result := False
  else
  begin
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

function RBStrIsInteger(const str: RawByteString): Boolean;
begin
  Result := IsIntegerA(PAnsiChar(str), length(str));
end;

function IsIntegerW(str: PWideChar; len: Integer): Boolean;
var
  i: Integer;
begin
  if len <= 0 then
    Result := False
  else
  begin
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

function UStrIsInteger(const str: u16string): Boolean;
begin
  Result := IsIntegerW(PWideChar(str), length(str));
end;

function BStrIsInteger(const str: WideString): Boolean;
begin
  Result := IsIntegerW(PWideChar(str), length(str));
end;

function IsQQA(str: PAnsiChar; len: Integer): Boolean;
begin
  Result := (len >= 5) and (length(str) <= 12) and IsIntegerA(str, len);
end;

function RBStrIsQQ(const str: RawByteString): Boolean;
// 检测是否有效的QQ号码
begin
  Result := (length(str) >= 5) and (length(str) <= 12) and RBStrIsInteger(str);
end;

function IsQQW(str: PWideChar; len: Integer): Boolean;
begin
  Result := (len >= 5) and (len <= 12) and IsIntegerW(str, len);
end;

function UStrIsQQ(const str: u16string): Boolean;
begin
  Result := (length(str) >= 5) and (length(str) <= 12) and UStrIsInteger(str);
end;

// 是否是18位身份证号码

function RBStrIsCnIDCard18(const idc18: RawByteString): Boolean;
const
  IDCBITS: array [1 .. 18] of Integer = (7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1);
  CHECKSUMBITS: array [0 .. 10] of AnsiChar = ('1', '0', 'x', '9', '8', '7', '6', '5', '4', '3', '2');
var
  checksum, i: Integer;
  ch: AnsiChar;
begin
  Result := False;

  if length(idc18) <> 18 then
    Exit;

  if idc18[18] in ['x', 'X'] then
  begin
    if not IsIntegerA(PAnsiChar(idc18), 17) then
      Exit;
  end
  else if not RBStrIsInteger(idc18) then
    Exit;

  checksum := 0;

  for i := 1 to 17 do
  begin
    ch := idc18[i];
    Inc(checksum, (Byte(ch) and $0F) * IDCBITS[i]);
  end;

  if (idc18[18] = 'X') then
    ch := 'x'
  else
    ch := idc18[18];

  Result := CHECKSUMBITS[checksum mod 11] = ch;
end;

function RBStrIsCnIDCard(const idc: RawByteString): Boolean;
begin
  if (length(idc) = 15) then
    Result := RBStrIsInteger(idc)
  else if (length(idc) = 18) then
    Result := RBStrIsCnIDCard18(idc)
  else
    Result := False;
end;

// 是否是18位身份证号码

function UStrIsCnIDCard18(const idc18: u16string): Boolean;
const
  IDCBITS: array [1 .. 18] of Integer = (7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1);
  CHECKSUMBITS: array [0 .. 10] of WideChar = ('1', '0', 'x', '9', '8', '7', '6', '5', '4', '3', '2');
var
  checksum, i: Integer;
  ch: WideChar;
begin
  Result := False;

  if length(idc18) <> 18 then
    Exit;

  if (idc18[18] = 'x') or (idc18[18] = 'X') then
  begin
    if not IsIntegerW(PWideChar(idc18), 17) then
      Exit;
  end
  else if not UStrIsInteger(idc18) then
    Exit;

  checksum := 0;

  for i := 1 to 17 do
  begin
    ch := idc18[i];
    Inc(checksum, (Word(ch) and $000F) * IDCBITS[i]);
  end;

  if (idc18[18] = 'X') then
    ch := 'x'
  else
    ch := idc18[18];

  Result := CHECKSUMBITS[checksum mod 11] = ch;
end;

function UStrIsCnIDCard(const idc: u16string): Boolean;
begin
  if (length(idc) = 15) then
    Result := UStrIsInteger(idc)
  else if (length(idc) = 18) then
    Result := UStrIsCnIDCard18(idc)
  else
    Result := False;
end;

function IDCard15to18(const idc15: RawByteString; out idc18: RawByteString): Boolean;
const
  IDCBITS: array [1 .. 18] of Integer = (7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1);

  CHECKSUMBITS: array [0 .. 10] of AnsiChar = ('1', '0', 'x', '9', '8', '7', '6', '5', '4', '3', '2');
var
  checksum, i: Integer;
  ch: AnsiChar;
begin
  Result := False;

  if ((length(idc15) <> 15) or not RBStrIsInteger(idc15)) then
    Exit;

  SetLength(idc18, 18);
  for i := 1 to 6 do
    idc18[i] := idc15[i];
  idc18[7] := '1';
  idc18[8] := '9';
  for i := 7 to 15 do
    idc18[i + 2] := idc15[i];
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
    stream.write(Pointer(str)^, length(str));
end;

procedure StreamWriteUStr(stream: TStream; const str: u16string);
begin
  if str <> '' then
    stream.write(Pointer(str)^, length(str) * 2);
end;

procedure ThreadListAdd(list: TThreadList; item: Pointer);
var
  _list: TList;
begin
  _list := list.LockList;
  try
    _list.add(item);
  finally
    list.UnlockList;
  end;
end;

procedure ThreadListDelete(list: TThreadList; index: Integer);
var
  _list: TList;
begin
  _list := list.LockList;
  try
    _list.delete(index);
  finally
    list.UnlockList;
  end;
end;

procedure ThreadListRemove(list: TThreadList; item: Pointer);
var
  _list: TList;
begin
  _list := list.LockList;
  try
    _list.remove(item);
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
    Result := InternalList.count;
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

procedure RefObject(instance: TObject);
begin
  if Assigned(instance) and (instance is TRefCountedObject) then
    TRefCountedObject(instance).AddRef;
end;

procedure SmartUnrefObject(obj: TObject);
begin
  if Assigned(obj) then
  begin
    if obj is TRefCountedObject then
      TRefCountedObject(obj).release
    else
      obj.Free;
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

      for i := 0 to list.count - 1 do
        SmartUnrefObject(TObject(list[i]));

      list.clear;
    end
    else if objlist is TThreadList then
    begin
      list := TThreadList(objlist).LockList;
      try
        for i := 0 to list.count - 1 do
          SmartUnrefObject(TObject(list[i]));

        list.clear;
      finally
        TThreadList(objlist).UnlockList;
      end;
    end
    else if objlist is TCircularList then
    begin
      for i := 0 to TCircularList(objlist).count - 1 do
        SmartUnrefObject(TObject(TCircularList(objlist)[i]));

      TCircularList(objlist).clear;
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
  Result := control.parent;
  while Assigned(Result) do
  begin
    if not Assigned(cls) or (Result is cls) then
      Break;

    Result := Result.parent;
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
    ctrl := ctrl.parent;

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
  SetWindowLong(edit.handle, GWL_STYLE, GetWindowLong(edit.handle, GWL_STYLE) or ES_NUMBER);
end;

function CtrlDown: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_CONTROL] and 128) <> 0);
end;

procedure CloseForm(form: TCustomForm);
begin
  if fsModal in form.FormState then
    form.ModalResult := mrCancel
  else
    form.Close;
end;

procedure SetModalResult(form: TCustomForm; mr: TModalResult);
begin
  if fsModal in form.FormState then
    form.ModalResult := mr
  else
    form.Close;
end;

type
  TWinCtrlHack = class(TWinControl);

procedure ShowForm(form: TCustomForm);
begin
  form.Visible := True;
  if IsIconic(TWinCtrlHack(form).WindowHandle) then
    form.Perform(WM_SYSCOMMAND, SC_RESTORE, 0);
  form.BringToFront;
  SetForegroundWindow(TWinCtrlHack(form).WindowHandle);
end;

procedure ListViewSetRowCount(ListView: TListView; count: Integer);
var
  TopIndex, ItemIndex: Integer;
begin
  if ListView.items.count <> count then
  begin
    try
      TopIndex := ListView_GetTopIndex(ListView.handle);
      ItemIndex := ListView.ItemIndex;
      ListView.items.count := count;

      if TopIndex <> -1 then
      begin
        TopIndex := TopIndex + ListView.VisibleRowCount - 1;

        if TopIndex >= count then
          TopIndex := count - 1;

        if TopIndex <> -1 then
          ListView.items[TopIndex].MakeVisible(False);
      end;

      if ItemIndex >= count then
        ItemIndex := count - 1;

      ListView.ItemIndex := ItemIndex;
    except
    end;
  end;

  ListView.Refresh;
end;

procedure InfoBox(const msg: string; _Parent: THandle);
begin
  Windows.MessageBox(_Parent, PChar(msg), '提示', MB_ICONINFORMATION or MB_OK);
end;

procedure ErrorBox(const msg: string; _Parent: THandle);
begin
  Windows.MessageBox(_Parent, PChar(msg), '错误', MB_ICONERROR or MB_OK);
end;

procedure WarnBox(const msg: string; _Parent: THandle);
begin
  Windows.MessageBox(_Parent, PChar(msg), '警告', MB_ICONEXCLAMATION or MB_OK);
end;

function ConfirmBox(const msg: string; _Parent: THandle = 0): Boolean;
begin
  Result := Windows.MessageBox(_Parent, PChar(msg), '确认', MB_ICONQUESTION or MB_YESNO) = ID_YES;
end;

function ConfirmDialog(const msg: string; const parent: THandle = 0; const title: string = '';
  const buttons: TConfirmDlgButtons = cdbYesNo): TConfirmDlgResult;
var
  _title: string;
begin
  if title = '' then
    _title := '确认'
  else
    _title := title;

  Result := TConfirmDlgResult(Application.MessageBox(PChar(msg), PChar(_title), MB_ICONQUESTION or Ord(buttons)) - 1);
end;

procedure ShowMessageEx(const v: string);
begin
  ShowMessage(v);
end;

procedure ShowMessageEx(const v: RawByteString); overload;
begin
  ShowMessage(string(v));
end;

procedure ShowMessageEx(const v: TAnsiCharSection);
begin
  ShowMessage(string(v.toString));
end;

procedure ShowMessageEx(v: Integer);
begin
  ShowMessage(IntToStr(v));
end;

procedure ShowMessageEx(v: Int64);
begin
  ShowMessage(IntToStr(v));
end;

procedure ShowMessageEx(v: Double);
begin
  ShowMessage(FloatToStr(v));
end;

procedure ShowMessageEx(v: Extended);
begin
  ShowMessage(FloatToStr(v));
end;

procedure ShowMessageEx(v: Real);
begin
  ShowMessage(FloatToStr(v));
end;

(*
procedure ShowMessageEx(v: Real48);
begin
  ShowMessage(FloatToStr(v));
end;
*)

procedure ShowMessageEx(v: Boolean);
begin
  if v then
    ShowMessage('true')
  else
    ShowMessage('false');
end;

const
  IID_IPersistFile: TGUID = '{0000010B-0000-0000-C000-000000000046}';

function SHGetTargetOfShortcut(const LinkFile: string): string;
var
  IntfLink: IShellLink;
  IntfPersist: IPersistFile;
  pfd: _WIN32_FIND_DATA;
  buf: array [0 .. MAX_PATH] of Char;
begin
  Result := '';
  IntfLink := CreateComObject(CLSID_ShellLink) as IShellLink;

  if Assigned(IntfLink) and SUCCEEDED(IntfLink.QueryInterface(IID_IPersistFile, IntfPersist)) and SUCCEEDED
    (IntfPersist.Load(PWideChar(u16string(LinkFile)), STGM_READ)) and SUCCEEDED
    (IntfLink.GetPath(buf, length(buf) - 1, pfd, SLGP_RAWPATH)) then
    Result := Array2Str(buf);
end;

function SHCreateShortcut(const TargetFile, desc, CreateAt: string): Boolean;
var
  IntfLink: IShellLink;
  IntfPersist: IPersistFile;
begin
  Result := False;

  IntfLink := CreateComObject(CLSID_ShellLink) as IShellLink;

  if (IntfLink <> nil) and SUCCEEDED(IntfLink.QueryInterface(IID_IPersistFile, IntfPersist)) and SUCCEEDED
    (IntfLink.SetPath(PChar(TargetFile))) then
  begin
    IntfLink.SetDescription(PChar(desc));
    IntfLink.SetWorkingDirectory(PChar(ExtractFilePath(TargetFile)));

    if SUCCEEDED(IntfPersist.Save(PWideChar(u16string(CreateAt)), True)) then
      Result := True;
  end;
end;

type
  TFNInternetGetCookie = function(lpszUrl, lpszCookieName, lpszCookieData: PWideChar; lpdwSize: PDWORD): BOOL; stdcall;
  TFNInternetGetCookieEx = function(lpszUrl, lpszCookieName, lpszCookieData: PWideChar; lpdwSize: PDWORD;
    dwFlags: DWORD; lpReserved: Pointer): BOOL; stdcall;

function InternetExplorerGetCookie(const url: u16string; HttpOnly: Boolean): u16string;
const
  INTERNET_COOKIE_HTTPONLY = 8192;
var
  hModule: THandle;
  fnInternetGetCookie: TFNInternetGetCookie;
  fnInternetGetCookieEx: TFNInternetGetCookieEx;
  CookieSize: DWORD;
  flags: DWORD;
  LastError: Integer;
  dummy: Integer;
begin
  Result := '';
  hModule := LoadLibrary('wininet.dll');

  if hModule <> 0 then
    try
      fnInternetGetCookieEx := GetProcAddress(hModule, 'InternetGetCookieExW');

      if Assigned(fnInternetGetCookieEx) then
      begin
        if HttpOnly then
          flags := INTERNET_COOKIE_HTTPONLY
        else
          flags := 0;

        CookieSize := 0;

        if not fnInternetGetCookieEx(PWideChar(url), nil, PWideChar(@dummy), Pointer(@CookieSize), flags, nil) then
        begin
          LastError := GetLastError;

          if LastError = ERROR_INSUFFICIENT_BUFFER then
          begin
            SetLength(Result, CookieSize div 2 - 1);

            if not fnInternetGetCookieEx(PWideChar(url), nil, PWideChar(Result), Pointer(@CookieSize), flags, nil) then
              Result := '';
          end;
        end;
      end
      else
      begin
        fnInternetGetCookie := GetProcAddress(hModule, 'InternetGetCookieW');

        if Assigned(fnInternetGetCookie) then
        begin
          CookieSize := 0;

          if not fnInternetGetCookie(PWideChar(url), nil, PWideChar(@dummy), Pointer(@CookieSize)) then
          begin
            LastError := GetLastError;

            if LastError = ERROR_INSUFFICIENT_BUFFER then
            begin
              SetLength(Result, CookieSize div 2 - 1);

              if not fnInternetGetCookie(PWideChar(url), nil, PWideChar(Result), Pointer(@CookieSize)) then
                Result := '';
            end;
          end;
        end;
      end;
    finally
      FreeLibrary(hModule);
    end;
end;

function getProcessorCount: Integer;
begin
  Result := g_SystemInfo.dwNumberOfProcessors;
end;

function GetEnvVar(const name: string): string;
var
  valueLen: Integer;
begin
  valueLen := Windows.GetEnvironmentVariable(PChar(name), nil, 0);
  if valueLen = 0 then
    Result := ''
  else
  begin
    SetLength(Result, valueLen - 1);
    Windows.GetEnvironmentVariable(PChar(name), PChar(Result), valueLen);
  end;
end;

function SetEnvVar(const name, value: string): Boolean;
begin
  Result := Windows.SetEnvironmentVariable(PChar(name), PChar(value));
end;

function EnvPathAdd(const dir: string): Boolean;
var
  strs: TStringList;
  pathList, dir2: string;
begin
  if dir = '' then
    Result := False
  else
  begin
    if dir[length(dir)] = '\' then
      dir2 := Copy(dir, 1, length(dir) - 1)
    else
      dir2 := dir + '\';

    strs := TStringList.Create;
    try
      strs.CaseSensitive := False;
      strs.delimiter := ';';
      strs.StrictDelimiter := True;
      pathList := GetEnvVar('PATH');
      strs.DelimitedText := pathList;
      if (strs.IndexOf(dir) = -1) and (strs.IndexOf(dir2) = -1) then
        Result := SetEnvVar('PATH', dir + ';' + pathList)
      else
        Result := True;
    finally
      strs.Free;
    end;
  end;
end;

function GetTempFileFullPath: string;
var
  tmpath: array [0 .. MAX_PATH] of Char;
begin
  SetString(Result, tmpath, Windows.GetTempPath(MAX_PATH, tmpath));
  Result := PathJoin(Result, RandomAlphaDigitUStr(8));
end;

function myLoadLibrary(const paths: array of string; const dllFileName: string): hModule;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(paths) to High(paths) do
  begin
    Result := Windows.LoadLibrary(PChar(PathJoin(paths[i], dllFileName)));

    if Result <> 0 then
      Break;
  end;

  if Result = 0 then
    Result := Windows.LoadLibrary(PChar(dllFileName));
end;

function getOSErrorMessage(errorCode: Integer): string;
var
  pstr, pResult: PChar;
  len1, len2: Integer;
  buf: array [0 .. 31] of Char;
begin
{$IFDEF UNICODE}
  len1 := IntToStrBufW(errorCode, buf);
{$ELSE}
  len1 := IntToStrBufA(errorCode, buf);
{$ENDIF}
  len2 := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_ARGUMENT_ARRAY or
      FORMAT_MESSAGE_ALLOCATE_BUFFER, nil, errorCode, 0, PChar(@pstr), 256, nil);

  while (len2 > 0) and (((pstr[len2 - 1] >= #0) and (pstr[len2 - 1] < #32)) or (pstr[len2 - 1] = '.') or
      (pstr[len2 - 1] = '。')) do
    Dec(len2);

  if len2 = 0 then
    SetLength(Result, len1 + 6)
  else
    SetLength(Result, len1 + len2 + 8);

  pResult := PChar(Result);
  pResult[0] := 'e';
  pResult[1] := 'r';
  pResult[2] := 'r';
  pResult[3] := 'o';
  pResult[4] := 'r';
  pResult[5] := ' ';
  Move(buf, pResult[6], len1 * SizeOf(Char));

  if len2 > 0 then
  begin
    pResult[len1 + 6] := '(';
    Move(pstr^, pResult[len1 + 7], len2 * SizeOf(Char));
    LocalFree(HLOCAL(pstr));
    pResult[length(Result) - 1] := ')';
  end;
end;

function getNTStartType(st: TNTServiceType; sst: TNTServiceStartType): DWORD;
const
  NTStartType: array [TNTServiceStartType] of Integer = (SERVICE_BOOT_START, SERVICE_SYSTEM_START, SERVICE_AUTO_START,
    SERVICE_DEMAND_START, SERVICE_DISABLED);
begin
  Result := NTStartType[sst];
  if (sst in [sstBoot, sstSystem]) and (st <> stDevice) then
    Result := SERVICE_AUTO_START;
end;

function getNTErrorSeverity(sev: TErrorSeverity): Integer;
const
  NTErrorSeverity: array [TErrorSeverity] of Integer = (SERVICE_ERROR_IGNORE, SERVICE_ERROR_NORMAL,
    SERVICE_ERROR_SEVERE, SERVICE_ERROR_CRITICAL);
begin
  Result := NTErrorSeverity[sev];
end;

function installNTService(const name, displayName, filePath: string; _type: TNTServiceType;
  startType: TNTServiceStartType; errorSeverity: TErrorSeverity; updateIfExists: Boolean): Integer;
var
  TmpTagID: Integer;
  pTag: Pointer;
  SvcMgr, svc: SC_HANDLE;
  loadGroup, pServiceStartName, pPassword: PChar;
begin
  Result := 0;
  SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if SvcMgr = 0 then
  begin
    Result := GetLastError;
    Exit;
  end;

  svc := 0;

  try
    TmpTagID := 0;
    if TmpTagID > 0 then
      pTag := @TmpTagID
    else
      pTag := nil;

    pServiceStartName := nil;
    loadGroup := nil;
    pPassword := nil;

    svc := CreateService(SvcMgr, PChar(name), PChar(displayName), SERVICE_ALL_ACCESS, SERVICE_WIN32_OWN_PROCESS,
      getNTStartType(_type, startType), getNTErrorSeverity(errorSeverity), PChar(filePath), loadGroup, pTag, nil,
      pServiceStartName, pPassword);

    if svc = 0 then
    begin
      Result := GetLastError;

      if updateIfExists then
      begin
        if Result = ERROR_SERVICE_EXISTS then
        begin
          svc := OpenService(SvcMgr, PChar(name), SERVICE_ALL_ACCESS);
          if svc = 0 then
            Result := GetLastError
          else if ChangeServiceConfig(svc, SERVICE_WIN32_OWN_PROCESS or SERVICE_INTERACTIVE_PROCESS,
            getNTStartType(_type, startType), getNTErrorSeverity(errorSeverity), PChar(filePath), loadGroup, pTag,
            nil, pServiceStartName, pPassword, PChar(displayName)) then
            Result := 0
          else
            Result := GetLastError;
        end;
      end;
    end;
  finally
    if svc <> 0 then
      CloseServiceHandle(svc);

    if SvcMgr <> 0 then
      CloseServiceHandle(SvcMgr);
  end;
end;

function uninstallNTService(const svcName: string): Integer;
var
  SvcMgr, svc: SC_HANDLE;
begin
  SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if SvcMgr = 0 then
  begin
    Result := GetLastError;
    Exit;
  end;
  svc := OpenService(SvcMgr, PChar(svcName), SERVICE_ALL_ACCESS);

  if (svc <> 0) and DeleteService(svc) then
    Result := 0
  else
    Result := GetLastError; ;

  if svc <> 0 then
    CloseServiceHandle(svc);

  if SvcMgr <> 0 then
    CloseServiceHandle(SvcMgr);
end;

function NTServiceExists(const svcName: string): Boolean;
var
  SvcMgr, svc: SC_HANDLE;
begin
  Result := False;
  SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if SvcMgr = 0 then
    Exit;
  svc := OpenService(SvcMgr, PChar(svcName), SERVICE_ALL_ACCESS);
  Result := svc <> 0;
  if svc <> 0 then
    CloseServiceHandle(svc);

  if SvcMgr <> 0 then
    CloseServiceHandle(SvcMgr);
end;

function ArrayContails(const ExcludeWindows: array of THandle; h: THandle): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := Low(ExcludeWindows) to High(ExcludeWindows) do
    if ExcludeWindows[i] = h then
    begin
      Result := True;
      Break;
    end;
end;

function FindChildWindowRecursive(parent: HWND; WndClassName, WndText: PWideChar;
  const ExcludeWindows: array of THandle): HWND;
var
  tmp, wnd: HWND;
begin
  Result := 0;

  wnd := FindWindowExW(parent, 0, WndClassName, WndText);

  if (wnd <> 0) and not ArrayContails(ExcludeWindows, wnd) then
    Result := wnd
  else
  begin
    tmp := GetWindow(parent, GW_CHILD);

    while tmp <> 0 do
    begin
      wnd := FindChildWindowRecursive(tmp, WndClassName, WndText, ExcludeWindows);

      if wnd <> 0 then
      begin
        Result := wnd;
        Break;
      end
      else
        tmp := GetWindow(tmp, GW_HWNDNEXT);
    end;
  end;
end;

function SHGetSpecialFolderPath(FolderID: TSpecialFolderID): string;
var
  pidl: PItemIDList;
  buf: array [0 .. MAX_PATH] of Char;
begin
  Result := '';

  if SUCCEEDED(SHGetFolderLocation(0, Ord(FolderID), 0, 0, pidl)) then
  begin
    if SHGetPathFromIDList(pidl, buf) then
      Result := StrPas(buf);
    ILFree(pidl);
  end;
end;

procedure HeapAdjust(pArray: Pointer; nItemSize, nItemCount: LongWord; iRoot: LongWord; pCompare: TPointerCompareProc;
  pSwap: TPointerProc); forward;

procedure HeapSort(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc;
  pSwap: TPointerProc);
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

procedure QuickSort(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc;
  pSwap: TPointerProc);
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
      while pCompare(Pointer(LongWord(pArray) + nItemSize * i), Pivot) < 0 do
        Inc(i);
      while pCompare(Pointer(LongWord(pArray) + nItemSize * j), Pivot) > 0 do
        Dec(j);
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
      else if i = j then
        Inc(i);
    until i >= j;
    if LIndex < j then
      QuickSort(Pointer(LongWord(pArray) + nItemSize * LIndex), nItemSize, j - LIndex + 1, pCompare, pSwap);
    LIndex := i;
  end;
end;

function BinarySearch(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc;
  const value): Integer;
var
  L, R, m, CR: Integer;
  ItemAddr: Pointer;
begin
  L := 0;
  R := nItemCount - 1;
  while L <= R do
  begin
    m := (L + R) shr 1;
    ItemAddr := Pointer(LongWord(pArray) + nItemSize * LongWord(m));
    CR := pCompare(ItemAddr, @value);
    if CR = 0 then
    begin
      Result := m;
      Exit;
    end;
    if CR > 0 then
      R := m - 1
    else
      L := m + 1;
  end;
  Result := -1;
end;

function BinarySearchInsertPos(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc;
  const value): Integer;
var
  L, R, m, CR: Integer;
  ItemAddr: Pointer;
begin
  L := 0;
  R := nItemCount - 1;
  while L <= R do
  begin
    m := (L + R) shr 1;
    ItemAddr := Pointer(LongWord(pArray) + nItemSize * LongWord(m));
    CR := pCompare(ItemAddr, @value);
    if CR = 0 then
    begin
      Result := m;
      Exit;
    end;

    if CR > 0 then
    begin
      if (m = L) or (pCompare(Pointer(LongWord(ItemAddr) - nItemSize), @value) <= 0) then
      begin
        Result := m;
        Exit;
      end;
      R := m - 1;
      Continue;
    end;

    if (m = R) or (pCompare(Pointer(LongWord(ItemAddr) + nItemSize), @value) >= 0) then
    begin
      Result := m + 1;
      Exit;
    end;
    L := m + 1;
  end;
  Result := 0;
end;

function Search(pArray: Pointer; nItemSize, nItemCount: LongWord; pCompare: TPointerCompareProc; const value): Integer;
var
  i: LongWord;
begin
  Result := -1;
  if nItemCount = 0 then
    Exit;
  for i := 0 to nItemCount - 1 do
  begin
    if pCompare(Pointer(LongWord(pArray) + nItemSize * i), @value) = 0 then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure HeapAdjust(pArray: Pointer; nItemSize, nItemCount, iRoot: LongWord; pCompare: TPointerCompareProc;
  pSwap: TPointerProc);
var
  iChild: LongWord;
  parent, Child1, Child2: Pointer;
begin
  iChild := 2 * iRoot + 1;
  while iChild < nItemCount do
  begin
    parent := Pointer(LongWord(pArray) + nItemSize * iRoot);
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
    if pCompare(parent, Child1) < 0 then
    begin
      pSwap(parent, Child1);
      iRoot := iChild;
      iChild := iRoot * 2 + 1;
    end
    else
      Break;
  end;
end;

type
  TCodePageInfo = record
    Name: RawByteString;
    ID: Integer;
  end;

  PCodePageInfo = ^TCodePageInfo;

const
  NAME_SORTED_CODE_PAGES: array [0 .. 144] of TCodePageInfo = ((Name: 'cp_acp'; ID: 0), (Name: 'IBM037'; ID: 37),
    (Name: 'IBM437'; ID: 437), (Name: 'IBM500'; ID: 500), (Name: 'ASMO-708'; ID: 708), (Name: 'ASMO-449+'; ID: 709),
    (Name: 'BCON V4'; ID: 709), (Name: 'Arabic'; ID: 710), (Name: 'DOS-720'; ID: 720), (Name: 'ibm737'; ID: 737),
    (Name: 'ibm775'; ID: 775), (Name: 'ibm850'; ID: 850), (Name: 'ibm852'; ID: 852), (Name: 'IBM855'; ID: 855),
    (Name: 'ibm857'; ID: 857), (Name: 'IBM00858'; ID: 858), (Name: 'IBM860'; ID: 860), (Name: 'ibm861'; ID: 861),
    (Name: 'DOS-862'; ID: 862), (Name: 'IBM863'; ID: 863), (Name: 'IBM864'; ID: 864), (Name: 'IBM865'; ID: 865),
    (Name: 'cp866'; ID: 866), (Name: 'ibm869'; ID: 869), (Name: 'IBM870'; ID: 870), (Name: 'windows-874'; ID: 874),
    (Name: 'cp875'; ID: 875), (Name: 'shift_jis'; ID: 932), (Name: 'gb2312'; ID: 936), (Name: 'GBK'; ID: 936),
    (Name: 'ks_c_5601-1987'; ID: 949), (Name: 'big5'; ID: 950), (Name: 'IBM1026'; ID: 1026), (Name: 'IBM01047';
      ID: 1047), (Name: 'IBM01140'; ID: 1140), (Name: 'IBM01141'; ID: 1141), (Name: 'IBM01142'; ID: 1142),
    (Name: 'IBM01143'; ID: 1143), (Name: 'IBM01144'; ID: 1144), (Name: 'IBM01145'; ID: 1145), (Name: 'IBM01146';
      ID: 1146), (Name: 'IBM01147'; ID: 1147), (Name: 'IBM01148'; ID: 1148), (Name: 'IBM01149'; ID: 1149),
    (Name: 'utf-16'; ID: 1200), (Name: 'unicodeFFFE'; ID: 1201), (Name: 'windows-1250'; ID: 1250),
    (Name: 'windows-1251'; ID: 1251), (Name: 'windows-1252'; ID: 1252), (Name: 'windows-1253'; ID: 1253),
    (Name: 'windows-1254'; ID: 1254), (Name: 'windows-1255'; ID: 1255), (Name: 'windows-1256'; ID: 1256),
    (Name: 'windows-1257'; ID: 1257), (Name: 'windows-1258'; ID: 1258), (Name: 'Johab'; ID: 1361), (Name: 'macintosh';
      ID: 10000), (Name: 'x-mac-japanese'; ID: 10001), (Name: 'x-mac-chinesetrad'; ID: 10002), (Name: 'x-mac-korean';
      ID: 10003), (Name: 'x-mac-arabic'; ID: 10004), (Name: 'x-mac-hebrew'; ID: 10005), (Name: 'x-mac-greek';
      ID: 10006), (Name: 'x-mac-cyrillic'; ID: 10007), (Name: 'x-mac-chinesesimp'; ID: 10008),
    (Name: 'x-mac-romanian'; ID: 10010), (Name: 'x-mac-ukrainian'; ID: 10017), (Name: 'x-mac-thai'; ID: 10021),
    (Name: 'x-mac-ce'; ID: 10029), (Name: 'x-mac-icelandic'; ID: 10079), (Name: 'x-mac-turkish'; ID: 10081),
    (Name: 'x-mac-croatian'; ID: 10082), (Name: 'utf-32'; ID: 12000), (Name: 'utf-32BE'; ID: 12001),
    (Name: 'x-Chinese_CNS'; ID: 20000), (Name: 'x-cp20001'; ID: 20001), (Name: 'x_Chinese-Eten'; ID: 20002),
    (Name: 'x-cp20003'; ID: 20003), (Name: 'x-cp20004'; ID: 20004), (Name: 'x-cp20005'; ID: 20005), (Name: 'x-IA5';
      ID: 20105), (Name: 'x-IA5-German'; ID: 20106), (Name: 'x-IA5-Swedish'; ID: 20107), (Name: 'x-IA5-Norwegian';
      ID: 20108), (Name: 'us-ascii'; ID: 20127), (Name: 'x-cp20261'; ID: 20261), (Name: 'x-cp20269'; ID: 20269),
    (Name: 'IBM273'; ID: 20273), (Name: 'IBM277'; ID: 20277), (Name: 'IBM278'; ID: 20278), (Name: 'IBM280';
      ID: 20280), (Name: 'IBM284'; ID: 20284), (Name: 'IBM285'; ID: 20285), (Name: 'IBM290'; ID: 20290),
    (Name: 'IBM297'; ID: 20297), (Name: 'IBM420'; ID: 20420), (Name: 'IBM423'; ID: 20423), (Name: 'IBM424';
      ID: 20424), (Name: 'x-EBCDIC-KoreanExtended'; ID: 20833), (Name: 'IBM-Thai'; ID: 20838), (Name: 'koi8-r';
      ID: 20866), (Name: 'IBM871'; ID: 20871), (Name: 'IBM880'; ID: 20880), (Name: 'IBM905'; ID: 20905),
    (Name: 'IBM00924'; ID: 20924), (Name: 'EUC-JP'; ID: 20932), (Name: 'x-cp20936'; ID: 20936), (Name: 'x-cp20949';
      ID: 20949), (Name: 'cp1025'; ID: 21025), (Name: 'koi8-u'; ID: 21866), (Name: 'iso-8859-1'; ID: 28591),
    (Name: 'iso-8859-2'; ID: 28592), (Name: 'iso-8859-3'; ID: 28593), (Name: 'iso-8859-4'; ID: 28594),
    (Name: 'iso-8859-5'; ID: 28595), (Name: 'iso-8859-6'; ID: 28596), (Name: 'iso-8859-7'; ID: 28597),
    (Name: 'iso-8859-8'; ID: 28598), (Name: 'iso-8859-9'; ID: 28599), (Name: 'iso-8859-13'; ID: 28603),
    (Name: 'iso-8859-15'; ID: 28605), (Name: 'x-Europa'; ID: 29001), (Name: 'iso-8859-8-i'; ID: 38598),
    (Name: 'iso-2022-jp'; ID: 50220), (Name: 'csISO2022JP'; ID: 50221), (Name: 'iso-2022-jp'; ID: 50222),
    (Name: 'iso-2022-kr'; ID: 50225), (Name: 'x-cp50227'; ID: 50227), (Name: 'euc-jp'; ID: 51932), (Name: 'EUC-CN';
      ID: 51936), (Name: 'euc-kr'; ID: 51949), (Name: 'hz-gb-2312'; ID: 52936), (Name: 'GB18030'; ID: 54936),
    (Name: 'x-iscii-de'; ID: 57002), (Name: 'x-iscii-be'; ID: 57003), (Name: 'x-iscii-ta'; ID: 57004),
    (Name: 'x-iscii-te'; ID: 57005), (Name: 'x-iscii-as'; ID: 57006), (Name: 'x-iscii-or'; ID: 57007),
    (Name: 'x-iscii-ka'; ID: 57008), (Name: 'x-iscii-ma'; ID: 57009), (Name: 'x-iscii-gu'; ID: 57010),
    (Name: 'x-iscii-pa'; ID: 57011), (Name: 'utf-7'; ID: 65000), (Name: 'utf-8'; ID: 65001));

  ID_SORTED_CODE_PAGES: array [0 .. 143] of TCodePageInfo = ((Name: 'cp_acp'; ID: 0), (Name: 'IBM037'; ID: 37),
    (Name: 'IBM437'; ID: 437), (Name: 'IBM500'; ID: 500), (Name: 'ASMO-708'; ID: 708), (Name: 'ASMO-449+'; ID: 709),
    (Name: 'BCON V4'; ID: 709), (Name: 'Arabic'; ID: 710), (Name: 'DOS-720'; ID: 720), (Name: 'ibm737'; ID: 737),
    (Name: 'ibm775'; ID: 775), (Name: 'ibm850'; ID: 850), (Name: 'ibm852'; ID: 852), (Name: 'IBM855'; ID: 855),
    (Name: 'ibm857'; ID: 857), (Name: 'IBM00858'; ID: 858), (Name: 'IBM860'; ID: 860), (Name: 'ibm861'; ID: 861),
    (Name: 'DOS-862'; ID: 862), (Name: 'IBM863'; ID: 863), (Name: 'IBM864'; ID: 864), (Name: 'IBM865'; ID: 865),
    (Name: 'cp866'; ID: 866), (Name: 'ibm869'; ID: 869), (Name: 'IBM870'; ID: 870), (Name: 'windows-874'; ID: 874),
    (Name: 'cp875'; ID: 875), (Name: 'shift_jis'; ID: 932), (Name: 'gb2312'; ID: 936), (Name: 'ks_c_5601-1987';
      ID: 949), (Name: 'big5'; ID: 950), (Name: 'IBM1026'; ID: 1026), (Name: 'IBM01047'; ID: 1047),
    (Name: 'IBM01140'; ID: 1140), (Name: 'IBM01141'; ID: 1141), (Name: 'IBM01142'; ID: 1142),
    (Name: 'IBM01143'; ID: 1143), (Name: 'IBM01144'; ID: 1144), (Name: 'IBM01145'; ID: 1145), (Name: 'IBM01146';
      ID: 1146), (Name: 'IBM01147'; ID: 1147), (Name: 'IBM01148'; ID: 1148), (Name: 'IBM01149'; ID: 1149),
    (Name: 'utf-16'; ID: 1200), (Name: 'unicodeFFFE'; ID: 1201), (Name: 'windows-1250'; ID: 1250),
    (Name: 'windows-1251'; ID: 1251), (Name: 'windows-1252'; ID: 1252), (Name: 'windows-1253'; ID: 1253),
    (Name: 'windows-1254'; ID: 1254), (Name: 'windows-1255'; ID: 1255), (Name: 'windows-1256'; ID: 1256),
    (Name: 'windows-1257'; ID: 1257), (Name: 'windows-1258'; ID: 1258), (Name: 'Johab'; ID: 1361), (Name: 'macintosh';
      ID: 10000), (Name: 'x-mac-japanese'; ID: 10001), (Name: 'x-mac-chinesetrad'; ID: 10002), (Name: 'x-mac-korean';
      ID: 10003), (Name: 'x-mac-arabic'; ID: 10004), (Name: 'x-mac-hebrew'; ID: 10005), (Name: 'x-mac-greek';
      ID: 10006), (Name: 'x-mac-cyrillic'; ID: 10007), (Name: 'x-mac-chinesesimp'; ID: 10008),
    (Name: 'x-mac-romanian'; ID: 10010), (Name: 'x-mac-ukrainian'; ID: 10017), (Name: 'x-mac-thai'; ID: 10021),
    (Name: 'x-mac-ce'; ID: 10029), (Name: 'x-mac-icelandic'; ID: 10079), (Name: 'x-mac-turkish'; ID: 10081),
    (Name: 'x-mac-croatian'; ID: 10082), (Name: 'utf-32'; ID: 12000), (Name: 'utf-32BE'; ID: 12001),
    (Name: 'x-Chinese_CNS'; ID: 20000), (Name: 'x-cp20001'; ID: 20001), (Name: 'x_Chinese-Eten'; ID: 20002),
    (Name: 'x-cp20003'; ID: 20003), (Name: 'x-cp20004'; ID: 20004), (Name: 'x-cp20005'; ID: 20005), (Name: 'x-IA5';
      ID: 20105), (Name: 'x-IA5-German'; ID: 20106), (Name: 'x-IA5-Swedish'; ID: 20107), (Name: 'x-IA5-Norwegian';
      ID: 20108), (Name: 'us-ascii'; ID: 20127), (Name: 'x-cp20261'; ID: 20261), (Name: 'x-cp20269'; ID: 20269),
    (Name: 'IBM273'; ID: 20273), (Name: 'IBM277'; ID: 20277), (Name: 'IBM278'; ID: 20278), (Name: 'IBM280';
      ID: 20280), (Name: 'IBM284'; ID: 20284), (Name: 'IBM285'; ID: 20285), (Name: 'IBM290'; ID: 20290),
    (Name: 'IBM297'; ID: 20297), (Name: 'IBM420'; ID: 20420), (Name: 'IBM423'; ID: 20423), (Name: 'IBM424';
      ID: 20424), (Name: 'x-EBCDIC-KoreanExtended'; ID: 20833), (Name: 'IBM-Thai'; ID: 20838), (Name: 'koi8-r';
      ID: 20866), (Name: 'IBM871'; ID: 20871), (Name: 'IBM880'; ID: 20880), (Name: 'IBM905'; ID: 20905),
    (Name: 'IBM00924'; ID: 20924), (Name: 'EUC-JP'; ID: 20932), (Name: 'x-cp20936'; ID: 20936), (Name: 'x-cp20949';
      ID: 20949), (Name: 'cp1025'; ID: 21025), (Name: 'koi8-u'; ID: 21866), (Name: 'iso-8859-1'; ID: 28591),
    (Name: 'iso-8859-2'; ID: 28592), (Name: 'iso-8859-3'; ID: 28593), (Name: 'iso-8859-4'; ID: 28594),
    (Name: 'iso-8859-5'; ID: 28595), (Name: 'iso-8859-6'; ID: 28596), (Name: 'iso-8859-7'; ID: 28597),
    (Name: 'iso-8859-8'; ID: 28598), (Name: 'iso-8859-9'; ID: 28599), (Name: 'iso-8859-13'; ID: 28603),
    (Name: 'iso-8859-15'; ID: 28605), (Name: 'x-Europa'; ID: 29001), (Name: 'iso-8859-8-i'; ID: 38598),
    (Name: 'iso-2022-jp'; ID: 50220), (Name: 'csISO2022JP'; ID: 50221), (Name: 'iso-2022-jp'; ID: 50222),
    (Name: 'iso-2022-kr'; ID: 50225), (Name: 'x-cp50227'; ID: 50227), (Name: 'euc-jp'; ID: 51932), (Name: 'EUC-CN';
      ID: 51936), (Name: 'euc-kr'; ID: 51949), (Name: 'hz-gb-2312'; ID: 52936), (Name: 'GB18030'; ID: 54936),
    (Name: 'x-iscii-de'; ID: 57002), (Name: 'x-iscii-be'; ID: 57003), (Name: 'x-iscii-ta'; ID: 57004),
    (Name: 'x-iscii-te'; ID: 57005), (Name: 'x-iscii-as'; ID: 57006), (Name: 'x-iscii-or'; ID: 57007),
    (Name: 'x-iscii-ka'; ID: 57008), (Name: 'x-iscii-ma'; ID: 57009), (Name: 'x-iscii-gu'; ID: 57010),
    (Name: 'x-iscii-pa'; ID: 57011), (Name: 'utf-7'; ID: 65000), (Name: 'utf-8'; ID: 65001));

type
  TAnsiStrPtrAndLen = record
    Ptr: PAnsiChar;
    len: Integer;
  end;

  PAnsiStrPtrAndLen = ^TAnsiStrPtrAndLen;

function CodePageNameSearchCmp(first: PCodePageInfo; second: PAnsiStrPtrAndLen): Integer;
begin
  Result := AsciiICompare(PAnsiChar(first^.Name), length(first^.Name), second^.Ptr, second^.len);
end;

function CodePageName2ID(Name: PAnsiChar; NameLen: Integer): Integer;
var
  PtrLen: TAnsiStrPtrAndLen;
begin
  PtrLen.Ptr := Name;
  PtrLen.len := NameLen;
  Result := BinarySearch(@NAME_SORTED_CODE_PAGES, SizeOf(TCodePageInfo), length(NAME_SORTED_CODE_PAGES),
    TPointerCompareProc(@CodePageNameSearchCmp), PtrLen);
  if Result >= 0 then
    Result := NAME_SORTED_CODE_PAGES[Result].ID;
end;

function CodePageName2ID(const Name: AnsiString): Integer;
begin
  Result := CodePageName2ID(PAnsiChar(Name), length(Name));
end;

function CodePageIDSearchCmp(first: PCodePageInfo; second: PInteger): Integer;
begin
  Result := first^.ID - second^;
end;

function CodePageID2Name(ID: Integer): RawByteString;
var
  Index: Integer;
begin
  Index := BinarySearch(@ID_SORTED_CODE_PAGES, SizeOf(TCodePageInfo), length(ID_SORTED_CODE_PAGES),
    TPointerCompareProc(@CodePageIDSearchCmp), ID);
  if Index >= 0 then
    Result := ID_SORTED_CODE_PAGES[Index].Name
  else
    Result := '';
end;

const
  MAX_DISP_ARGS = 64;

function GetVariantArg(const param: TVariantArg): Variant;
begin
  Result := Null;

  case param.vt of
    VT_I4:
      Result := param.lVal;
    VT_BOOL:
      Result := param.vbool;
    VT_DATE:
      Result := param.date;
    VT_BSTR:
      Result := WideString(param.bstrVal);
    VT_R8:
      Result := param.dblVal;
    VT_CY:
      Result := param.cyVal;
    VT_BYREF or VT_VARIANT:
      Result := param.pvarVal^;
    VT_UNKNOWN or VT_BYREF:
      Result := IUnknown(param.byRef);
    VT_I8 or VT_BYREF:
      Result := PInt64(param.byRef)^;
  end;
end;

function AssignVariant(var param: TVariantArg; const value: TVarRec): Boolean;
begin
  Result := True;
  with value do
    case VType of
      vtInteger:
        begin
          param.vt := VT_I4;
          param.lVal := VInteger;
        end;
      vtBoolean:
        begin
          param.vt := VT_BOOL;
          param.vbool := VBoolean;
        end;
      vtChar:
        begin
          param.vt := VT_BSTR;
          param.bstrVal := StringToOleStr(VChar);
        end;
      vtExtended:
        begin
          param.vt := VT_R8;
          param.dblVal := VExtended^;
        end;
      vtString:
        begin
          param.vt := VT_BSTR;
          param.bstrVal := StringToOleStr(VString^);
        end;
      vtPointer:
        if VPointer = nil then
        begin
          param.vt := VT_NULL;
          param.byRef := nil;
        end
        else
        begin
          param.vt := VT_BYREF;
          param.byRef := VPointer;
        end;
      vtPChar:
        begin
          param.vt := VT_BSTR;
          param.bstrVal := StringToOleStr(VPChar);
        end;
      vtObject:
        begin
          param.vt := VT_BYREF;
          param.byRef := VObject;
        end;
      vtClass:
        begin
          param.vt := VT_BYREF;
          param.byRef := VClass;
        end;
      vtWideChar:
        begin
          param.vt := VT_BSTR;
          param.bstrVal := @VWideChar;
        end;
      vtPWideChar:
        begin
          param.vt := VT_BSTR;
          param.bstrVal := VPWideChar;
        end;
      vtAnsiString:
        begin
          param.vt := VT_BSTR;
          param.bstrVal := StringToOleStr(string(VAnsiString));
        end;
      vtCurrency:
        begin
          param.vt := VT_CY;
          param.cyVal := VCurrency^;
        end;
      vtVariant:
        begin
          param.vt := VT_BYREF or VT_VARIANT;
          param.pvarVal := VVariant;
        end;
      vtInterface:
        begin
          param.vt := VT_UNKNOWN or VT_BYREF;
          param.byRef := VInterface;
        end;
      vtWideString:
        begin
          param.vt := VT_BSTR;
          param.bstrVal := VPWideChar;
        end;
      vtInt64:
        begin
          param.vt := VT_I8 or VT_BYREF;
          param.byRef := VInt64;
        end;
      vtUnicodeString:
        begin
          param.vt := VT_BSTR;
          param.bstrVal := StringToOleStr(u16string(VUnicodeString));
        end;
    else
      Result := False;
    end;
end;

function NameToDispID(const disp: IDispatch; const name: WideString; _lcid: TLCID; out _dispID: TDispID): Boolean;
var
  Names: array [0 .. 0] of PWideChar;
begin
  Names[0] := PWideChar(name);
  Result := SUCCEEDED(disp.GetIDsOfNames(GUID_NULL, @Names, 1, _lcid, @_dispID));
end;

function DispMethodExists(const disp: IDispatch; _lcid: TLCID; const name: u16string): Boolean;
var
  Names: array [0 .. 0] of PWideChar;
  ID: TDispID;
begin
  Names[0] := PWideChar(name);
  Result := SUCCEEDED(disp.GetIDsOfNames(GUID_NULL, @Names, 1, _lcid, @ID));
end;

function ClassIDExists(const ClassID: TGUID): Boolean;
var
  p: PWideChar;
begin
  Result := SUCCEEDED(ProgIDFromCLSID(ClassID, p));

  if Result then
    CoTaskMemFree(p);
end;

function CallDispMethod(const disp: IDispatch; _lcid: TLCID; const name: u16string; const params: array of const ;
  res: PVariant): Boolean;
var
  ID: TDispID;
  Names: array [0 .. 0] of PWideChar;
  dispParams: TDispParams;
  argCnt, i, j: Integer;
  args: array [0 .. MAX_DISP_ARGS - 1] of TVariantArg;
  exceptionInfo: TExcepInfo;
  ArgErr: Integer;
  hr: HResult;
begin
  Names[0] := PWideChar(name);

  if (Failed(disp.GetIDsOfNames(GUID_NULL, @Names, 1, _lcid, @ID))) then
  begin
    Result := False;
    Exit;
  end;

  argCnt := length(params);

  if (argCnt > MAX_DISP_ARGS) then
    argCnt := MAX_DISP_ARGS;

  j := 0;

  for i := Low(params) + argCnt - 1 downto Low(params) do
  begin
    AssignVariant(args[j], params[i]);
    Inc(j);
  end;

  if (argCnt = 0) then
    dispParams.rgvarg := nil
  else
    dispParams.rgvarg := PVariantArgList(@args);

  dispParams.rgdispidNamedArgs := nil;
  dispParams.cArgs := argCnt;
  dispParams.cNamedArgs := 0;

  if Assigned(res) then
    VarClear(res^);

  try
    hr := disp.Invoke(ID, GUID_NULL, _lcid, DISPATCH_METHOD, dispParams, res, @exceptionInfo, @ArgErr);
  except
    if Assigned(res) then
      VarClear(res^);
    Result := False;
    Exit;
  end;
  Result := SUCCEEDED(hr);
end;

{$region 'graphic utils'}

function detectPictureFormat(const buf; bufSize: Integer): TPictureFormat;
var
  bytes: P4Bytes;
begin
  {
    JPEG FFD8FF
    PNG 89504E47
    GIF 47494638
    Bitmap 424D
    }
  Result := unknownPictureFormat;
  bytes := P4Bytes(@buf);
  if bufSize >= 4 then
  begin
    if (bytes[0] = $FF) and (bytes[1] = $D8) and (bytes[2] = $FF) then
      Result := pfJpeg
    else if (bytes[0] = $89) and (bytes[1] = $50) and (bytes[2] = $4E) and (bytes[3] = $47) then
      Result := pfPng
    else if (bytes[0] = $47) and (bytes[1] = $49) and (bytes[2] = $46) and (bytes[3] = $38) then
      Result := pfGif
    else if (bytes[0] = $42) and (bytes[1] = $4D) then
      Result := pfBitmap;
  end;
end;

function detectPictureFormat(AStream: TStream): TPictureFormat;
var
  buf: array [0 .. 3] of Byte;
  bookmark: Int64;
  bytesRead: Integer;
begin
  bookmark := AStream.Position;

  try
    bytesRead := AStream.Read(buf, SizeOf(buf));
    Result := detectPictureFormat(buf, bytesRead);
  finally
    AStream.Position := bookmark;
  end;
end;

{$endregion}

{ TRefCountedObject }

function TRefCountedObject.AddRef: Integer;
begin
  if Self <> nil then
    Result := InterlockedIncrement(FRefCount)
  else
    Result := 0;
end;

function TRefCountedObject.ExtendLife: Boolean;
begin
  Result := False;
end;

class function TRefCountedObject.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TRefCountedObject(Result).FRefCount := 1;
end;

function TRefCountedObject.release: Integer;
begin
  if Self <> nil then
  begin
    Result := InterlockedDecrement(FRefCount);
    if (Result = 0) and not ExtendLife then
      Free;
  end
  else
    Result := 0;
end;

{ TCircularList }

procedure TCircularList.add(item: Pointer);
var
  i: Integer;
begin
  if FCount = FCapacity then
    grow;

  // TList.Error(SListCapacityError, FCapacity)

  i := (FFirst + FCount) mod FCapacity;
  FList[i] := item;
  Inc(FCount);
end;

function TCircularList.add: Pointer;
var
  i: Integer;
begin
  if FCount = FCapacity then
    grow;
  // TList.Error(SListCapacityError, FCapacity);

  i := (FFirst + FCount) mod FCapacity;
  Inc(FCount);
  Result := FList[i];
end;

function TCircularList.CircularAdd(item: Pointer): Pointer;
var
  i: Integer;
begin
  if FCapacity = 0 then
    grow;

  if FCount = FCapacity then
  begin
    Result := FList[FFirst];
    FList[FFirst] := item;
    FFirst := (FFirst + 1) mod FCapacity;
  end
  else
  begin
    i := (FFirst + FCount) mod FCapacity;
    Result := FList[i];
    FList[i] := item;
    Inc(FCount);
  end;
end;

function TCircularList.CircularAdd: Pointer;
var
  i: Integer;
begin
  if FCapacity = 0 then
    grow;

  if FCount = FCapacity then
  begin
    Result := FList[FFirst];
    FFirst := (FFirst + 1) mod FCapacity;
  end
  else
  begin
    i := (FFirst + FCount) mod FCapacity;
    Result := FList[i];
    Inc(FCount);
  end;
end;

procedure TCircularList.clear;
begin
  FFirst := 0;
  FCount := 0;
  SetLength(FList, 0);
end;

constructor TCircularList.Create(_capacity: Integer);
begin
  SetLength(FList, _capacity);
  FCapacity := _capacity;
  FCount := 0;
  FFirst := 0;
end;

procedure TCircularList.delete(Index: Integer);
var
  i, j, k: Integer;
begin
  if (Index < 0) or (Index >= FCount) then
    TList.Error(SListIndexError, Index);

  if Index = 0 then
    MoveHead(1)
  else if Index < FCount - 1 then
  begin
    i := FFirst + Index;

    if i >= FCapacity then
    begin
      j := i mod FCapacity;
      k := (FFirst + FCount - 1) mod FCapacity;
      Move(FList[j + 1], FList[j], (k - j) * SizeOf(Pointer));
      Dec(FCount);
    end
    else
    begin
      for k := i - 1 downto FFirst do
        FList[k + 1] := FList[k];

      MoveHead(1);
    end;
  end;
end;

destructor TCircularList.Destroy;
begin
  SetLength(FList, 0);
  inherited;
end;

function TCircularList.GetItem(Index: Integer): Pointer;
begin
  if (Index < 0) or (Index >= FCount) then
    TList.Error(SListIndexError, Index);

  Result := FList[(FFirst + Index) mod FCapacity];
end;

procedure TCircularList.grow;
var
  delta: Integer;
begin
  if FCapacity > 64 then
    delta := FCapacity div 4
  else if FCapacity > 8 then
    delta := 16
  else
    delta := 4;
  SetCapacity(FCapacity + delta);
end;

function TCircularList.GetInternalIndex(Index: Integer): Integer;
begin
  Result := (FFirst + index) mod FCapacity;
end;

function TCircularList.IndexOf(item: Pointer): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to FCount - 1 do
  begin
    if FList[(FFirst + i) mod FCapacity] = item then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TCircularList.MoveHead(num: Integer);
begin
  if num <= FCount then
  begin
    FFirst := (FFirst + num) mod FCapacity;
    Dec(FCount, num);

    if FCount = 0 then
      FFirst := 0;
  end;
end;

function TCircularList.remove(item: Pointer): Integer;
begin
  Result := Self.IndexOf(item);

  if Result >= 0 then
    Self.delete(Result);
end;

procedure TCircularList.SetCapacity(const value: Integer);
var
  NewList: TDynamicArray;
begin
  if (value < FCount) or (value > 1024 * 1024 * 1024) then
    TList.Error(PResStringRec(@SListCapacityError), value);

  if value <> FCapacity then
  begin
    SetLength(NewList, value);

    if FFirst + FCount - 1 < FCapacity then
      Move(FList[FFirst], NewList[0], FCount * SizeOf(Pointer))
    else
    begin
      Move(FList[FFirst], NewList[0], (FCapacity - FFirst) * SizeOf(Pointer));
      Move(FList[0], NewList[FCapacity - FFirst], (FFirst + FCount - FCapacity) * SizeOf(Pointer));
    end;

    FList := NewList;
    FFirst := 0;
    FCapacity := value;
  end;
end;

procedure TCircularList.SetCount(const value: Integer);
begin
  if value > capacity then
    Exit;
  FCount := value;
end;

procedure TCircularList.SetItem(Index: Integer; const value: Pointer);
begin
  if (Index < 0) or (Index >= FCount) then
    TList.Error(SListIndexError, Index);

  FList[(FFirst + Index) mod FCapacity] := value;
end;

{ TFIFOQueue }

procedure TFIFOQueue.clear;
var
  node: PLinkNode;
begin
  FLock.acquire();

  try
    while Assigned(FFirst) do
    begin
      node := FFirst;
      FFirst := FFirst.next;
      Dispose(node);
    end;

    fLast := nil;
    fSize := 0;

  finally
    FLock.release;
  end;
end;

constructor TFIFOQueue.Create;
begin
  FLock.init;
  FFirst := nil;
  fLast := nil;
end;

destructor TFIFOQueue.Destroy;
begin
  Self.clear;
  FLock.cleanup;
  inherited;
end;

procedure TFIFOQueue.lock;
begin
  FLock.acquire();
end;

function TFIFOQueue.pop: Pointer;
var
  node: PLinkNode;
begin
  FLock.acquire();

  try
    node := FFirst;

    if Assigned(FFirst) then
    begin
      Result := node.data;

      FFirst := node.next;

      if not Assigned(FFirst) then
        fLast := nil;

      Dec(fSize);
    end
    else
      Result := nil;
  finally
    FLock.release;
  end;

  if Assigned(node) then
    Dispose(node);
end;

procedure TFIFOQueue.push(item: Pointer);
var
  node: PLinkNode;
begin
  New(node);
  node.data := item;
  node.next := nil;
  FLock.acquire();
  try
    if Assigned(FFirst) then
    begin
      fLast.next := node;
      fLast := node;
    end
    else
    begin
      FFirst := node;
      fLast := node;
    end;

    Inc(fSize);
  finally
    FLock.release;
  end;
end;

procedure TFIFOQueue.PushFront(item: Pointer);
var
  node: PLinkNode;
begin
  New(node);
  node.data := item;
  node.next := nil;

  FLock.acquire();

  try
    node.next := FFirst;
    FFirst := node;

    if not Assigned(node.next) then
      fLast := node;

    Inc(fSize);
  finally
    FLock.release;
  end;
end;

procedure TFIFOQueue.unlock;
begin
  FLock.release;
end;

{ TLIFOQueue }

procedure TLIFOQueue.clear;
var
  node: PLinkNode;
begin
  FLock.acquire();

  try
    while Assigned(FFirst) do
    begin
      node := FFirst;
      FFirst := FFirst.next;
      Dispose(node);
    end;

  finally
    FLock.release;
  end;
end;

constructor TLIFOQueue.Create;
begin
  FFirst := nil;
  FLock.init();
end;

destructor TLIFOQueue.Destroy;
begin
  Self.clear;
  FLock.cleanup;
  inherited;
end;

function TLIFOQueue.pop: Pointer;
var
  node: PLinkNode;
begin
  FLock.acquire();

  try
    node := FFirst;

    if Assigned(FFirst) then
    begin
      FFirst := FFirst.next;
      Result := node.data;
    end
    else
      Result := nil;

  finally
    FLock.release;
  end;

  if Assigned(node) then
    Dispose(node);
end;

procedure TLIFOQueue.push(item: Pointer);
var
  node: PLinkNode;
begin
  New(node);
  node.data := item;
  FLock.acquire();

  try
    node.next := FFirst;
    FFirst := node;
  finally
    FLock.release;
  end;
end;

{ TLogWritter }

procedure TLogWritter.write(sev: TMessageLevel; const text: RawByteString);
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

procedure TLogWritter.write(sev: TMessageLevel; const text: u16string);
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
      WriteUnicode(u16string(FormatDateTime(DateTimeFormat, Now)));
      WriteUnicode(' ');
    end;
    WriteUnicode(text);
  end;
end;

procedure TLogWritter.Writeln(sev: TMessageLevel; const text: RawByteString);
begin
  if sev in fVerbosity then
  begin
    Self.write(sev, text);
    WriteAnsi(#13#10);
  end;
end;

procedure TLogWritter.Writeln(sev: TMessageLevel; const text: u16string);
begin
  if sev in fVerbosity then
  begin
    Self.write(sev, text);
    WriteUnicode(#13#10);
  end;
end;

constructor TLogWritter.Create;
begin
  fDateTimeFormat := 'yyyy-mm-dd hh:nn:ss';
  fVerbosity := TRACE_SEVERITIES_ALL;
  fOptions := [mtServerity, mtTime];
end;

procedure TLogWritter.FormatWrite(sev: TMessageLevel; const fmt: RawByteString; const args: array of const );
begin
  Self.write(sev, RawByteString(Format(string(fmt), args)));
end;

procedure TLogWritter.flush;
begin

end;

procedure TLogWritter.FormatWrite(sev: TMessageLevel; const fmt: u16string; const args: array of const );
begin
  Self.write(sev, Format(fmt, args));
end;

procedure TLogWritter.SetDateTimeFormat(const value: string);
begin
  DateTimeFormat := value;
end;

procedure TLogWritter.SetOptions(const value: TMessageTags);
begin
  options := value;
end;

procedure TLogWritter.SetVerbosity(const value: TMessageVerbosity);
begin
  fVerbosity := value;
end;

{ TFileLogWritter }

constructor TFileLogWritter.Create(const FileName: string);
begin
  inherited Create;

  fEncoding := teAnsi;

  if not FileExists(FileName) then
  begin
    ForceDirectories(ExtractFilePath(FileName));
    FileClose(FileCreate(FileName));
  end;

  fFileStream := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);

  fFileStream.Seek(0, soFromEnd);
end;

destructor TFileLogWritter.Destroy;
begin
  fFileStream.Free;
  inherited;
end;

procedure TFileLogWritter.flush;
begin
  Windows.FlushFileBuffers(fFileStream.handle);
end;

function TFileLogWritter.GetFileSize: Integer;
begin
  Result := fFileStream.size;
end;

procedure TFileLogWritter.WriteAnsi(const text: RawByteString);
var
  utf8str: UTF8String;
  utf16str: u16string;
begin
  if text = '' then Exit;
  case Encoding of
    teAnsi:
      fFileStream.write(text[1], length(text));
    teUTF8:
      begin
        utf8str := UTF8EncodeUStr(u16string(text));
        fFileStream.write(utf8str[1], length(utf8str));
      end;
    teUTF16:
      begin
        utf16str := u16string(text);
        fFileStream.write(utf16str[1], length(utf16str) * 2);
      end;
  end;
end;

procedure TFileLogWritter.WriteUnicode(const text: u16string);
var
  ansistr: RawByteString;
  utf8str: UTF8String;
begin
  if text = '' then Exit;
  case Encoding of
    teAnsi:
      begin
        ansistr := RawByteString(text);
        fFileStream.write(ansistr[1], length(ansistr));
      end;
    teUTF8:
      begin
        utf8str := UTF8Encode(text);
        fFileStream.write(utf8str[1], length(utf8str));
      end;
    teUTF16:
      fFileStream.write(text[1], length(text) * 2);
  end;
end;

{ TConsoleLogWritter }

procedure TConsoleLogWritter.WriteAnsi(const text: RawByteString);
begin
  if text <> '' then
    System.write(text);
end;

procedure TConsoleLogWritter.WriteUnicode(const text: u16string);
begin
  if text <> '' then
    System.write(text);
end;

{ TDebugLogWritter }

procedure TDebugLogWritter.WriteAnsi(const text: RawByteString);
begin
  if text <> '' then
    OutputDebugStringA(PAnsiChar(text));
end;

procedure TDebugLogWritter.WriteUnicode(const text: u16string);
begin
  if text <> '' then
    OutputDebugStringW(PWideChar(text));
end;

{ TSliceLogWritter }

constructor TMultiFileLogWritter.Create(const dir: string);
begin
  inherited Create;
  fDateTimeFormat := 'yyyy-mm-dd hh:nn:ss';
  fVerbosity := TRACE_SEVERITIES_ALL;
  fOptions := [mtServerity, mtTime];
  fLogFileDir := dir;
  fLogSeparate := dtpDay;

  if fLogFileDir[length(fLogFileDir)] <> '\' then
    fLogFileDir := fLogFileDir + '\';
end;

destructor TMultiFileLogWritter.Destroy;
begin
  FreeAndNil(fWritter);
  inherited;
end;

procedure TMultiFileLogWritter.flush;
begin
  if fWritter <> nil then
    fWritter.flush;
end;

procedure TMultiFileLogWritter.FormatWrite(sev: TMessageLevel; const fmt: u16string; const args: array of const );
begin
  Self.write(sev, WideFormat(fmt, args));
end;

procedure TMultiFileLogWritter.FormatWrite(sev: TMessageLevel; const fmt: RawByteString; const args: array of const );
begin
  Self.write(sev, RawByteString(Format(string(fmt), args)));
end;

procedure TMultiFileLogWritter.CreateFileTracer(tick: TDateTime);
var
  FileName: string;
  Changed: Boolean;
begin
  if fWritter = nil then
    Changed := True
  else
  begin
    case fLogSeparate of
      dtpYear:
        Changed := not SameYear(fLastLogTime, tick);
      dtpMonth:
        Changed := not SameMonth(fLastLogTime, tick);
      dtpDay:
        Changed := not SameDay(fLastLogTime, tick);
    else
      Changed := not SameHour(fLastLogTime, tick);
    end;
  end;

  if not Changed then
    Exit;

  fLastLogTime := tick;
  case LogSeparate of
    dtpYear:
      FileName := fLogFileDir + FormatDateTime('yyyy', tick) + '.log';
    dtpMonth:
      FileName := fLogFileDir + FormatDateTime('yyyymm', tick) + '.log';
    dtpDay:
      FileName := fLogFileDir + FormatDateTime('yyyymmdd', tick) + '.log';
  else
    FileName := fLogFileDir + FormatDateTime('yyyymmddhh', tick) + '.log';
  end;
  FreeAndNil(fWritter);
  fWritter := TFileLogWritter.Create(FileName);
  fWritter.Encoding := Encoding;
  fWritter.DateTimeFormat := DateTimeFormat;
  fWritter.options := options;
  fWritter.Verbosity := severity;
end;

procedure TMultiFileLogWritter.SetDateTimeFormat(const value: string);
begin
  DateTimeFormat := value;
  if fWritter <> nil then
    fWritter.DateTimeFormat := value;
end;

procedure TMultiFileLogWritter.SetOptions(const value: TMessageTags);
begin
  options := value;
  if fWritter <> nil then
    fWritter.options := value;
end;

procedure TMultiFileLogWritter.SetVerbosity(const value: TMessageVerbosity);
begin
  severity := value;
  if fWritter <> nil then
    fWritter.Verbosity := value;
end;

procedure TMultiFileLogWritter.write(sev: TMessageLevel; const text: u16string);
begin
  CreateFileTracer(Now);
  fWritter.write(sev, text);
end;

procedure TMultiFileLogWritter.Writeln(sev: TMessageLevel; const text: RawByteString);
begin
  CreateFileTracer(Now);
  fWritter.Writeln(sev, text);
end;

procedure TMultiFileLogWritter.Writeln(sev: TMessageLevel; const text: u16string);
begin
  CreateFileTracer(Now);
  fWritter.Writeln(sev, text);
end;

procedure TMultiFileLogWritter.write(sev: TMessageLevel; const text: RawByteString);
begin
  CreateFileTracer(Now);
  fWritter.write(sev, text);
end;


{ TAutoObject }

constructor TAutoObject.Create(_instance: TObject);
begin
  fInstance := _instance;
end;

destructor TAutoObject.Destroy;
begin
  fInstance.Free;
  inherited;
end;

function TAutoObject.GetInstance: TObject;
begin
  Result := fInstance;
end;

procedure SwapCodePage(first, second: Pointer);
var
  Temp: TCodePageInfo;
begin
  Temp := PCodePageInfo(first)^;
  PCodePageInfo(first)^ := PCodePageInfo(second)^;
  PCodePageInfo(second)^ := Temp;
end;

function CompareCodePageByName(first, second: PCodePageInfo): Integer;
begin
  Result := AsciiICompare(first^.Name, second^.Name);
end;

function CompareCodePageByID(first, second: PCodePageInfo): Integer;
begin
  Result := first^.ID - second^.ID;
end;

{ TThreadFileStream }

constructor TThreadFileStream.Create(const AFileName: string; Mode: Word);
begin
  inherited;
  FLock := TCriticalSection.Create;
end;

constructor TThreadFileStream.Create(const AFileName: string; Mode: Word; Rights: Cardinal);
begin
  inherited;
  FLock := TCriticalSection.Create;
end;

destructor TThreadFileStream.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TThreadFileStream.lock;
begin
  FLock.Enter;
end;

procedure TThreadFileStream.unlock;
begin
  FLock.Leave;
end;

{ TVersion }

function TVersion.compare(Other: TVersion): Integer;
begin
  if Self.Major > Other.Major then
  begin
    Result := 1;
    Exit;
  end;
  if Self.Major < Other.Major then
  begin
    Result := -1;
    Exit;
  end;

  if Self.Minor > Other.Minor then
  begin
    Result := 1;
    Exit;
  end;
  if Self.Minor < Other.Minor then
  begin
    Result := -1;
    Exit;
  end;

  if Self.release > Other.release then
  begin
    Result := 1;
    Exit;
  end;
  if Self.release < Other.release then
  begin
    Result := -1;
    Exit;
  end;

  if Self.Build > Other.Build then
  begin
    Result := 1;
    Exit;
  end;
  if Self.Build < Other.Build then
  begin
    Result := -1;
    Exit;
  end;

  Result := 0;
end;

function TVersion.toString: string;
begin
  Result := Format('%d.%d.%d.%d', [Major, Minor, release, Build]);
end;

type
  TLanguageAndCodePage = packed record
    language: Word;
    CodePage: Word;
  end;

  PLanguageAndCodePage = ^TLanguageAndCodePage;

{ TFileVersionInfo }

constructor TFileVersionInfo.Create(const FileName: string);
var
  cbSize, LHandle: DWORD;
begin
  FFixedInfo := PVSFixedFileInfo(-1);
  FFileVersion := TVersion.Create;
  FProductVersion := TVersion.Create;
  LHandle := 0;
  cbSize := GetFileVersionInfoSize(PChar(FileName), LHandle);
  if cbSize <= 0 then
    Exit;
  FVersionBlock := System.GetMemory(cbSize);
  if not GetFileVersionInfo(PChar(FileName), LHandle, cbSize, FVersionBlock) then
    Exit;
  GetFixedInfo;
  if VerQueryValue(FVersionBlock, '\VarFileInfo\Translation', FTransition, FTransitionSize) then
  begin
    FCompanyName := GetStringInfo('CompanyName');
    FProductName := GetStringInfo('ProductName');
    FFileDescription := GetStringInfo('FileDescription');
    FInternalName := GetStringInfo('InternalName');
    FOriginalFilename := GetStringInfo('OriginalFilename');
    FLegalCopyright := GetStringInfo('LegalCopyright');
    FComments := GetStringInfo('Comments');
    FProgramID := GetStringInfo('ProgramID');
    FLegalTrademarks := GetStringInfo('LegalTrademarks');
  end
  else begin
    FTransition := nil;
    FTransitionSize := 0;
  end;
end;

destructor TFileVersionInfo.Destroy;
begin
  System.FreeMemory(FVersionBlock);
  FreeAndNil(FFileVersion);
  FreeAndNil(FProductVersion);
  inherited;
end;

procedure TFileVersionInfo.GetFixedInfo;
var
  cbSize: DWORD;
begin
  if NativeInt(FFixedInfo) < 0 then
  begin
    if VerQueryValue(FVersionBlock, '\', Pointer(FFixedInfo), cbSize) and (FFixedInfo <> nil) then
    begin
      FFileVersion.Major := FFixedInfo.dwFileVersionMS shr 16;
      FFileVersion.Minor := FFixedInfo.dwFileVersionMS and $FFFF;
      FFileVersion.release := FFixedInfo.dwFileVersionLS shr 16;
      FFileVersion.Build := FFixedInfo.dwFileVersionLS and $FFFF;
      FProductVersion.Major := FFixedInfo.dwProductVersionMS shr 16;
      FProductVersion.Minor := FFixedInfo.dwProductVersionMS and $FFFF;
      FProductVersion.release := FFixedInfo.dwProductVersionLS shr 16;
      FProductVersion.Build := FFixedInfo.dwProductVersionLS and $FFFF;
    end
  end;
end;

function TFileVersionInfo.GetStringInfo(const name: string): string;
var
  LSubBlock: string;
  LBuffer: PChar;
  i: Integer;
  LDataSize: UINT;
  LTransition: PLanguageAndCodePage;
begin
  Result := '';
  if FTransition = nil then
    Exit;
  LTransition := PLanguageAndCodePage(FTransition);
  for i := 0 to FTransitionSize div SizeOf(TLanguageAndCodePage) - 1 do
  begin
    LSubBlock := Format('StringFileInfo\%.4x%.4x\%s', [LTransition.language, LTransition.CodePage, name]);
    if VerQueryValue(FVersionBlock, PChar(LSubBlock), Pointer(LBuffer), LDataSize) then
    begin
      Result := StrPas(LBuffer);
      Break;
    end;
    Inc(LTransition);
  end;
end;

{ TWebOperationResult }

procedure TWebOperationResult.init;
begin
  code := orUnknown;
  online := True;
  errmsg := '';
  ResponseText := '';
end;

{ TAnsiCharSection }

function TAnsiCharSection.beginWith(const prefix: TAnsiCharSection): Boolean;
begin
  if (Self.length = 0) or (prefix.length = 0) then
    Result := False
  else
    Result := BeginWithA(_begin, Self.length, prefix._begin, prefix.length);
end;

function TAnsiCharSection.compare(const another: RawByteString; CaseSensitive: Boolean): Integer;
begin
  Result := Self.compare(TAnsiCharSection.Create(another), CaseSensitive);
end;

function TAnsiCharSection.compare(const another: TAnsiCharSection; CaseSensitive: Boolean): Integer;
begin
  if Self.IsEmpty then
  begin
    if another.IsEmpty then
      Result := 0
    else
      Result := -1;
  end
  else
  begin
    if another.IsEmpty then
      Result := 1
    else
      Result := StrCompareA(_begin, Self.length, another._begin, another.length, CaseSensitive);
  end;
end;

constructor TAnsiCharSection.Create(const s: RawByteString; first, last: Integer);
begin
  SetStr(s, first, last);
end;

function TAnsiCharSection.endWith(const prefix: TAnsiCharSection): Boolean;
begin
  if (Self.length = 0) or (prefix.length = 0) then
    Result := False
  else
    Result := EndWithA(_begin, Self.length, prefix._begin, prefix.length);
end;

function TAnsiCharSection.GetSectionBetween(const prefix, suffix: TAnsiCharSection;
  flags: TStringSearchFlags): TAnsiCharSection;
var
  L, PrefixLen, suffixLen: Integer;
  SectionBegin, SectionEnd: PAnsiChar;
begin
  Result.SetEmpty;
  L := Self.length;
  PrefixLen := prefix.length;
  suffixLen := suffix.length;

  if L > 0 then
  begin
    if ssfReverse in flags then
    begin
      if suffixLen = 0 then
        SectionEnd := Self._end
      else if ssfCaseSensitive in flags then
        SectionEnd := StrRPosA(suffix._begin, suffixLen, Self._begin, L)
      else
        SectionEnd := StrRIPosA(suffix._begin, suffixLen, Self._begin, L);

      if Assigned(SectionEnd) then
      begin
        if PrefixLen = 0 then
          SectionBegin := Self._begin
        else if ssfCaseSensitive in flags then
          SectionBegin := StrRPosA(prefix._begin, PrefixLen, Self._begin, SectionEnd - Self._begin)
        else
          SectionBegin := StrRIPosA(prefix._begin, PrefixLen, Self._begin, SectionEnd - Self._begin);

        if Assigned(SectionBegin) then
        begin
          if not(ssfIncludePrefix in flags) then
            Inc(SectionBegin, PrefixLen);

          if ssfIncludeSuffix in flags then
            Inc(SectionEnd, suffixLen);

          Result._begin := SectionBegin;
          Result._end := SectionEnd;
        end;
      end;
    end
    else
    begin
      if PrefixLen = 0 then
        SectionBegin := Self._begin
      else if ssfCaseSensitive in flags then
        SectionBegin := StrPosA(prefix._begin, PrefixLen, Self._begin, L)
      else
        SectionBegin := StrIPosA(prefix._begin, PrefixLen, Self._begin, L);

      if Assigned(SectionBegin) then
      begin
        Inc(SectionBegin, PrefixLen);

        if suffixLen = 0 then
          SectionEnd := Self._end
        else if ssfCaseSensitive in flags then
          SectionEnd := StrPosA(suffix._begin, suffixLen, SectionBegin, Self._end - SectionBegin)
        else
          SectionEnd := StrIPosA(suffix._begin, suffixLen, SectionBegin, Self._end - SectionBegin);

        if Assigned(SectionEnd) then
        begin
          if ssfIncludePrefix in flags then
            Dec(SectionBegin, PrefixLen);

          if ssfIncludeSuffix in flags then
            Inc(SectionEnd, suffixLen);

          Result._begin := SectionBegin;
          Result._end := SectionEnd;
        end;
      end;
    end;
  end;
end;

function TAnsiCharSection.GetSectionBetween2(const prefix: TAnsiCharSection; const suffix: array of AnsiChar;
  EndingNoSuffix: Boolean; flags: TStringSearchFlags): TAnsiCharSection;
var
  i, L, PrefixLen: Integer;
  SectionBegin, SectionEnd: PAnsiChar;
  found: Boolean;
begin
  Result.SetEmpty;
  L := Self.length;
  PrefixLen := prefix.length;

  if L > 0 then
  begin
    if PrefixLen = 0 then
      SectionBegin := Self._begin
    else if ssfCaseSensitive in flags then
      SectionBegin := StrPosA(prefix._begin, PrefixLen, Self._begin, L)
    else
      SectionBegin := StrIPosA(prefix._begin, PrefixLen, Self._begin, L);

    if Assigned(SectionBegin) then
    begin
      Inc(SectionBegin, PrefixLen);

      if System.length(suffix) = 0 then
      begin
        SectionEnd := Self._end;
        EndingNoSuffix := True;
      end
      else
      begin
        found := False;
        SectionEnd := SectionBegin;

        while SectionEnd < Self._end do
        begin
          for i := Low(suffix) to high(suffix) do
          begin
            if SectionEnd^ = suffix[i] then
            begin
              found := True;
              Break;
            end;
          end;

          if found then
            Break;

          Inc(SectionEnd);
        end;
      end;

      (*
        在字符串结尾允许不带suffix。比如prefix为'ab', suffix为[';', ',']时，
        从'abcde;123'、'abcde'、'abcde,123'三个src中都能提取出'cde'
        *)
      if (SectionEnd < Self._end) or EndingNoSuffix then
      begin
        if ssfIncludePrefix in flags then
          Dec(SectionBegin, PrefixLen);

        if (ssfIncludeSuffix in flags) and (SectionEnd < Self._end) then
          Inc(SectionEnd);

        Result._begin := SectionBegin;
        Result._end := SectionEnd;
      end;
    end;
  end;
end;

function TAnsiCharSection.iBeginWith(const prefix: TAnsiCharSection): Boolean;
begin
  if (Self.length = 0) or (prefix.length = 0) then
    Result := False
  else
    Result := IBeginWithA(_begin, Self.length, prefix._begin, prefix.length);
end;

function TAnsiCharSection.iEndWith(const prefix: TAnsiCharSection): Boolean;
begin
  if (Self.length = 0) or (prefix.length = 0) then
    Result := False
  else
    Result := IEndWithA(_begin, Self.length, prefix._begin, prefix.length);
end;

function TAnsiCharSection.ipos(substr: TAnsiCharSection): PAnsiChar;
begin
  Result := StrIPosA(substr._begin, substr._end - substr._begin, _begin, _end - _begin);
end;

function TAnsiCharSection.IsEmpty: Boolean;
begin
  Result := Self.length = 0;
end;

function TAnsiCharSection.IsValid: Boolean;
begin
  Result := _end >= _begin;
end;

function TAnsiCharSection.length: Integer;
begin
  Result := _end - _begin;

  if Result < 0 then
    Result := 0;
end;

function TAnsiCharSection.pos(substr: TAnsiCharSection): PAnsiChar;
begin
  Result := StrPosA(substr._begin, substr._end - substr._begin, _begin, _end - _begin);
end;

function TAnsiCharSection.ripos(substr: TAnsiCharSection): PAnsiChar;
begin
  Result := StrRIPosA(substr._begin, substr._end - substr._begin, _begin, _end - _begin);
end;

function TAnsiCharSection.rpos(substr: TAnsiCharSection): PAnsiChar;
begin
  Result := StrRPosA(substr._begin, substr._end - substr._begin, _begin, _end - _begin);
end;

procedure TAnsiCharSection.SetEmpty;
begin
  Self._begin := nil;
  Self._end := nil;
end;

procedure TAnsiCharSection.SetInvalid;
begin
  Self._begin := PAnsiChar(1);
  Self._end := nil;
end;

procedure TAnsiCharSection.SetStr(const s: RawByteString; first, last: Integer);
begin
  if s = '' then
    Self.SetEmpty
  else
  begin
    Self._begin := PAnsiChar(s) + first - 1;
    if (last <= 0) or (last > System.length(s)) then
      last := System.length(s) + 1;
    Self._end := PAnsiChar(s) + last - 1;
  end;
end;

function TAnsiCharSection.ToFloat: Double;
var
  L: Integer;
  c: PAnsiChar;
begin
  L := Self.length;
  if L <= 0 then
    Result := 0
  else
    Result := BufToFloatA(_begin, L, @c);
end;

function TAnsiCharSection.ToInt: Integer;
var
  L: Integer;
  c: PAnsiChar;
begin
  L := Self.length;
  if L <= 0 then
    Result := 0
  else
    Result := BufToIntA(_begin, L, @c);
end;

function TAnsiCharSection.ToInt64: Int64;
var
  L: Integer;
  c: PAnsiChar;
begin
  L := Self.length;
  if L <= 0 then
    Result := 0
  else
    Result := BufToInt64A(_begin, L, @c);
end;

function TAnsiCharSection.toString: RawByteString;
var
  L: Integer;
begin
  L := Self.length;

  SetLength(Result, L);

  if L > 0 then
    Move(_begin^, Pointer(Result)^, _end - _begin);
end;

function TAnsiCharSection.trim: PAnsiCharSection;
var
  tmp: PAnsiChar;
begin
  if not IsEmpty and IsValid then
  begin
    while (_begin < _end) and (_begin^ <= #32) do
      Inc(_begin);
    tmp := _end - 1;
    while (tmp >= _begin) and (tmp^ <= #32) do
      Dec(tmp);
    _end := tmp + 1;
  end;

  Result := @Self;
end;

function TAnsiCharSection.TrimLeft: PAnsiCharSection;
begin
  if not IsEmpty and IsValid then
    while (_begin < _end) and (_begin^ <= #32) do
      Inc(_begin);

  Result := @Self;
end;

function TAnsiCharSection.TrimRight: PAnsiCharSection;
var
  tmp: PAnsiChar;
begin
  if not IsEmpty and IsValid then
  begin
    tmp := _end - 1;
    while (tmp >= _begin) and (tmp^ <= #32) do
      Dec(tmp);
    _end := tmp + 1;
  end;
  Result := @Self;
end;

function TAnsiCharSection.TryToFloat(var value: Double): Boolean;
var
  tmp: Double;
  L: Integer;
  c: PAnsiChar;
begin
  L := Self.length;

  if L <= 0 then
    Result := False
  else
  begin
    tmp := BufToFloatA(_begin, L, @c);

    if Assigned(c) then
      Result := False
    else
    begin
      value := tmp;
      Result := True;
    end;
  end;
end;

function TAnsiCharSection.TryToInt(var value: Integer): Boolean;
var
  L, tmp: Integer;
  c: PAnsiChar;
begin
  L := Self.length;

  if L <= 0 then
    Result := False
  else
  begin
    tmp := BufToIntA(_begin, L, @c);

    if Assigned(c) then
      Result := False
    else
    begin
      value := tmp;
      Result := True;
    end;
  end;
end;

function TAnsiCharSection.TryToInt64(var value: Int64): Boolean;
var
  tmp: Int64;
  L: Integer;
  c: PAnsiChar;
begin
  L := Self.length;

  if L <= 0 then
    Result := False
  else
  begin
    tmp := BufToInt64A(_begin, L, @c);

    if Assigned(c) then
      Result := False
    else
    begin
      value := tmp;
      Result := True;
    end;
  end;
end;

{ TWideCharSection }

constructor TWideCharSection.Create(const s: u16string; first, last: Integer);
begin
  SetUStr(s, first, last);
end;

constructor TWideCharSection.Create(const s: WideString; first, last: Integer);
begin
  SetBStr(s, first, last);
end;

function TWideCharSection.compare(const another: TWideCharSection; CaseSensitive: Boolean): Integer;
begin
  if Self.IsEmpty then
  begin
    if another.IsEmpty then
      Result := 0
    else
      Result := -1;
  end
  else
  begin
    if another.IsEmpty then
      Result := 1
    else
      Result := StrCompareW(_begin, Self.length, another._begin, another.length, CaseSensitive);
  end;
end;

function TWideCharSection.beginWith(const prefix: TWideCharSection): Boolean;
begin
  if (Self.length = 0) or (prefix.length = 0) then
    Result := False
  else
    Result := BeginWithW(_begin, Self.length, prefix._begin, prefix.length);
end;

function TWideCharSection.compare(const another: u16string; CaseSensitive: Boolean): Integer;
begin
  Result := Self.compare(TWideCharSection.Create(another), CaseSensitive);
end;

function TWideCharSection.ExtractXmlCDATA: PWideCharSection;
const
  SCDATABeginTag: u16string = '<![CDATA[';
  SCDATAEndTag: u16string = ']]>';
begin
  // <![CDATA[2001]]>

  if (Self.length >= 12) and IBeginWithW(Self._begin, Self.length, PWideChar(SCDATABeginTag),
    System.length(SCDATABeginTag)) and IEndWithW(Self._begin, Self.length, PWideChar(SCDATAEndTag),
    System.length(SCDATAEndTag)) then
  begin
    Inc(Self._begin, 9);
    Dec(Self._end, 3);
  end;

  Result := @Self;
end;

function TWideCharSection.GetSectionBetween(const prefix, suffix: TWideCharSection;
  flags: TStringSearchFlags): TWideCharSection;
var
  L, PrefixLen, suffixLen: Integer;
  SectionBegin, SectionEnd: PWideChar;
begin
  Result.SetEmpty;
  L := Self.length;
  PrefixLen := prefix.length;
  suffixLen := suffix.length;

  if L > 0 then
  begin
    if ssfReverse in flags then
    begin
      if suffixLen = 0 then
        SectionEnd := Self._end
      else if ssfCaseSensitive in flags then
        SectionEnd := StrRPosW(suffix._begin, suffixLen, Self._begin, L)
      else
        SectionEnd := StrRIPosW(suffix._begin, suffixLen, Self._begin, L);

      if Assigned(SectionEnd) then
      begin
        if PrefixLen = 0 then
          SectionBegin := Self._begin
        else if ssfCaseSensitive in flags then
          SectionBegin := StrRPosW(prefix._begin, PrefixLen, Self._begin, SectionEnd - Self._begin)
        else
          SectionBegin := StrRIPosW(prefix._begin, PrefixLen, Self._begin, SectionEnd - Self._begin);

        if Assigned(SectionBegin) then
        begin
          if not(ssfIncludePrefix in flags) then
            Inc(SectionBegin, PrefixLen);

          if ssfIncludeSuffix in flags then
            Inc(SectionEnd, suffixLen);

          Result._begin := SectionBegin;
          Result._end := SectionEnd;
        end;
      end;
    end
    else
    begin
      if PrefixLen = 0 then
        SectionBegin := Self._begin
      else if ssfCaseSensitive in flags then
        SectionBegin := StrPosW(prefix._begin, PrefixLen, Self._begin, L)
      else
        SectionBegin := StrIPosW(prefix._begin, PrefixLen, Self._begin, L);

      if Assigned(SectionBegin) then
      begin
        Inc(SectionBegin, PrefixLen);

        if suffixLen = 0 then
          SectionEnd := Self._end
        else if ssfCaseSensitive in flags then
          SectionEnd := StrPosW(suffix._begin, suffixLen, SectionBegin, Self._end - SectionBegin)
        else
          SectionEnd := StrIPosW(suffix._begin, suffixLen, SectionBegin, Self._end - SectionBegin);

        if Assigned(SectionEnd) then
        begin
          if ssfIncludePrefix in flags then
            Dec(SectionBegin, PrefixLen);

          if ssfIncludeSuffix in flags then
            Inc(SectionEnd, suffixLen);

          Result._begin := SectionBegin;
          Result._end := SectionEnd;
        end;
      end;
    end;
  end;
end;

function TWideCharSection.GetSectionBetween2(const prefix: TWideCharSection; const suffix: array of WideChar;
  EndingNoSuffix: Boolean; flags: TStringSearchFlags): TWideCharSection;
var
  i, L, PrefixLen: Integer;
  SectionBegin, SectionEnd: PWideChar;
  found: Boolean;
begin
  Result.SetEmpty;
  L := Self.length;
  PrefixLen := prefix.length;

  if L > 0 then
  begin
    if PrefixLen = 0 then
      SectionBegin := Self._begin
    else if ssfCaseSensitive in flags then
      SectionBegin := StrPosW(prefix._begin, PrefixLen, Self._begin, L)
    else
      SectionBegin := StrIPosW(prefix._begin, PrefixLen, Self._begin, L);

    if Assigned(SectionBegin) then
    begin
      Inc(SectionBegin, PrefixLen);

      if System.length(suffix) = 0 then
      begin
        SectionEnd := Self._end;
        EndingNoSuffix := True;
      end
      else
      begin
        found := False;
        SectionEnd := SectionBegin;

        while SectionEnd < Self._end do
        begin
          for i := Low(suffix) to high(suffix) do
          begin
            if SectionEnd^ = suffix[i] then
            begin
              found := True;
              Break;
            end;
          end;

          if found then
            Break;

          Inc(SectionEnd);
        end;
      end;

      (*
        在字符串结尾允许不带suffix。比如prefix为'ab', suffix为[';', ',']时，
        从'abcde;123'、'abcde'、'abcde,123'三个src中都能提取出'cde'
        *)
      if (SectionEnd < Self._end) or EndingNoSuffix then
      begin
        if ssfIncludePrefix in flags then
          Dec(SectionBegin, PrefixLen);

        if (ssfIncludeSuffix in flags) and (SectionEnd < Self._end) then
          Inc(SectionEnd);

        Result._begin := SectionBegin;
        Result._end := SectionEnd;
      end;
    end;
  end;
end;

function TWideCharSection.iBeginWith(const prefix: TWideCharSection): Boolean;
begin
  if (Self.length = 0) or (prefix.length = 0) then
    Result := False
  else
    Result := IBeginWithW(_begin, Self.length, prefix._begin, prefix.length);
end;

function TWideCharSection.iEndWith(const prefix: TWideCharSection): Boolean;
begin
  if (Self.length = 0) or (prefix.length = 0) then
    Result := False
  else
    Result := IEndWithW(_begin, Self.length, prefix._begin, prefix.length);
end;

function TWideCharSection.endWith(const prefix: TWideCharSection): Boolean;
begin
  if (Self.length = 0) or (prefix.length = 0) then
    Result := False
  else
    Result := EndWithW(_begin, Self.length, prefix._begin, prefix.length);
end;

function TWideCharSection.ipos(substr: TWideCharSection): PWideChar;
begin
  Result := StrIPosW(substr._begin, substr._end - substr._begin, _begin, _end - _begin);
end;

function TWideCharSection.IsEmpty: Boolean;
begin
  Result := Self.length = 0;
end;

function TWideCharSection.IsValid: Boolean;
begin
  Result := _end >= _begin;
end;

function TWideCharSection.length: Integer;
begin
  Result := _end - _begin;
  if Result < 0 then
    Result := 0;
end;

function TWideCharSection.pos(substr: TWideCharSection): PWideChar;
begin
  Result := StrPosW(substr._begin, substr._end - substr._begin, _begin, _end - _begin);
end;

function TWideCharSection.ripos(substr: TWideCharSection): PWideChar;
begin
  Result := StrRIPosW(substr._begin, substr._end - substr._begin, _begin, _end - _begin);
end;

function TWideCharSection.rpos(substr: TWideCharSection): PWideChar;
begin
  Result := StrRPosW(substr._begin, substr._end - substr._begin, _begin, _end - _begin);
end;

procedure TWideCharSection.SetUStr(const s: u16string; first, last: Integer);
begin
  if s = '' then
    Self.SetEmpty
  else
  begin
    Self._begin := PWideChar(s) + first - 1;
    if (last <= 0) or (last > System.length(s)) then
      last := System.length(s) + 1;
    Self._end := PWideChar(s) + last - 1;
  end;
end;

procedure TWideCharSection.SetBStr(const s: WideString; first, last: Integer);
begin
  if s = '' then
    Self.SetEmpty
  else
  begin
    Self._begin := PWideChar(s) + first - 1;
    if (last <= 0) or (last > System.length(s)) then
      last := System.length(s) + 1;
    Self._end := PWideChar(s) + last - 1;
  end;
end;

procedure TWideCharSection.SetEmpty;
begin
  _begin := nil;
  _end := nil;
end;

procedure TWideCharSection.SetInvalid;
begin
  Self._begin := PWideChar(1);
  Self._end := nil;
end;

function TWideCharSection.ToBStr: WideString;
var
  L: Integer;
begin
  L := Self.length;
  SetLength(Result, L);

  if L > 0 then
    Move(_begin^, Pointer(Result)^, (_end - _begin) shl 1);
end;

function TWideCharSection.ToFloat: Double;
var
  L: Integer;
  c: PWideChar;
begin
  L := Self.length;
  if L <= 0 then
    Result := 0
  else
    Result := BufToFloatW(_begin, L, @c);
end;

function TWideCharSection.ToInt: Integer;
var
  L: Integer;
  c: PWideChar;
begin
  L := Self.length;
  if L <= 0 then
    Result := 0
  else
    Result := BufToIntW(_begin, L, @c);
end;

function TWideCharSection.ToInt64: Int64;
var
  L: Integer;
  c: PWideChar;
begin
  L := Self.length;
  if L <= 0 then
    Result := 0
  else
    Result := BufToInt64W(_begin, L, @c);
end;

function TWideCharSection.ToUStr: u16string;
var
  L: Integer;
begin
  L := Self.length;
  SetLength(Result, L);

  if L > 0 then
    Move(_begin^, Pointer(Result)^, (_end - _begin) shl 1);
end;

function TWideCharSection.trim: PWideCharSection;
var
  tmp: PWideChar;
begin
  if not IsEmpty and IsValid then
  begin
    while (_begin < _end) and (_begin^ <= #32) do
      Inc(_begin);

    tmp := _end - 1;
    while (tmp >= _begin) and (tmp^ <= #32) do
      Dec(tmp);
    _end := tmp + 1;
  end;

  Result := @Self;
end;

function TWideCharSection.TrimLeft: PWideCharSection;
begin
  if not IsEmpty and IsValid then
    while (_begin < _end) and (_begin^ <= #32) do
      Inc(_begin);
  Result := @Self;
end;

function TWideCharSection.TrimRight: PWideCharSection;
var
  tmp: PWideChar;
begin
  if not IsEmpty and IsValid then
  begin
    tmp := _end - 1;
    while (tmp >= _begin) and (tmp^ <= #32) do
      Dec(tmp);
    _end := tmp + 1;
  end;

  Result := @Self;
end;

function TWideCharSection.TryToFloat(var value: Double): Boolean;
var
  tmp: Double;
  L: Integer;
  c: PWideChar;
begin
  L := Self.length;

  if L <= 0 then
    Result := False
  else
  begin
    tmp := BufToFloatW(_begin, L, @c);

    if Assigned(c) then
      Result := False
    else
    begin
      value := tmp;
      Result := True;
    end;
  end;
end;

function TWideCharSection.TryToInt(var value: Integer): Boolean;
var
  L, tmp: Integer;
  c: PWideChar;
begin
  L := Self.length;

  if L <= 0 then
    Result := False
  else
  begin
    tmp := BufToIntW(_begin, L, @c);

    if Assigned(c) then
      Result := False
    else
    begin
      value := tmp;
      Result := True;
    end;
  end;
end;

function TWideCharSection.TryToInt64(var value: Int64): Boolean;
var
  tmp: Int64;
  L: Integer;
  c: PWideChar;
begin
  L := Self.length;

  if L <= 0 then
    Result := False
  else
  begin
    tmp := BufToInt64W(_begin, L, @c);

    if Assigned(c) then
      Result := False
    else
    begin
      value := tmp;
      Result := True;
    end;
  end;
end;

{ TProperties }

function TProperties.FindOrAdd(const key: string; value: Variant): Integer;
var
  i: Integer;
begin
  for i := Low(FItems) to High(FItems) do
  begin
    if SameText(key, FItems[i].key) then
    begin
      Result := i;
      Exit;
    end;
  end;

  SetLength(FItems, length(FItems) + 1);
  Result := High(FItems);
  FItems[Result].key := key;
  FItems[Result].value := value;
end;

procedure TProperties.clear;
begin
  SetLength(FItems, 0);
end;

function TProperties.exists(const key: string): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := Low(FItems) to High(FItems) do
  begin
    if SameText(key, FItems[i].key) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TProperties.GetCount: Integer;
begin
  Result := length(FItems);
end;

function TProperties.GetItem(const key: string): Variant;
var
  i: Integer;
begin
  Result := Null;

  for i := Low(FItems) to High(FItems) do
  begin
    if SameText(key, FItems[i].key) then
    begin
      Result := FItems[i].value;
      Break;
    end;
  end;
end;

function TProperties.GetItemAt(Index: Integer): Variant;
begin
  Result := FItems[Index].value;
end;

function TProperties.IndexOf(const key: string): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := Low(FItems) to High(FItems) do
  begin
    if SameText(key, FItems[i].key) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TProperties.SetItem(const key: string; const value: Variant);
var
  i: Integer;
begin
  for i := Low(FItems) to High(FItems) do
  begin
    if SameText(key, FItems[i].key) then
    begin
      FItems[i].value := value;
      Exit;
    end;
  end;

  SetLength(FItems, length(FItems) + 1);
  i := High(FItems);
  FItems[i].key := key;
  FItems[i].value := value;
end;

procedure TProperties.SetItemAt(Index: Integer; const value: Variant);
begin
  FItems[Index].value := value;
end;

{ TDispProperties }

function TDispProperties.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: Integer;
  DispIDs: Pointer): HResult;
var
  tmp: string;
begin
  if NameCount > 1 then
    Result := E_NOTIMPL
  else
  begin
    tmp := string(u16string(PPWideChar(Names)^));
    PInteger(DispIDs)^ := FItems.FindOrAdd(tmp, Variants.Null);
    Result := S_OK;
  end;
end;

function TDispProperties.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispProperties.GetTypeInfoCount(out count: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispProperties.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; flags: Word; var params;
  VarResult, ExcepInfo, ArgErr: Pointer): HResult;
var
  pParams: PDispParams;
begin
  pParams := @params;

  if (DispID >= 0) and (DispID < FItems.count) then
  begin
    if (flags and DISPATCH_PROPERTYGET <> 0) then
      PVariant(VarResult)^ := FItems.ItemAt[DispID]
    else
      FItems.ItemAt[DispID] := GetVariantArg(pParams.rgvarg^[0]);

    Result := S_OK;
  end
  else
    Result := S_FALSE;
end;

{ TStreamHelper }

function TStreamHelper.ReadAnsiChar: AnsiChar;
begin
  Self.ReadBuffer(Result, SizeOf(Result));
end;

function TStreamHelper.ReadByte: Byte;
begin
  Self.ReadBuffer(Result, SizeOf(Result));
end;

function TStreamHelper.ReadBytes(nBytes: Integer): TBytes;
begin
  SetLength(Result, nBytes);

  if nBytes > 0 then
    Self.ReadBuffer(Result[0], nBytes);
end;

function TStreamHelper.ReadDword: UInt32;
begin
  Self.ReadBuffer(Result, SizeOf(Result));
end;

function TStreamHelper.ReadRawByteString(nChar: Integer): RawByteString;
begin
  SetLength(Result, nChar);

  if nChar > 0 then
    Self.ReadBuffer(Pointer(Result)^, nChar);
end;

function TStreamHelper.ReadUnicodeString(nChar: Integer): u16string;
begin
  SetLength(Result, nChar);

  if nChar > 0 then
    Self.ReadBuffer(Pointer(Result)^, nChar * 2);
end;

function TStreamHelper.ReadWideChar: WideChar;
begin
  Self.ReadBuffer(Result, SizeOf(Result));
end;

function TStreamHelper.ReadWideString(nChar: Integer): WideString;
begin
  SetLength(Result, nChar);

  if nChar > 0 then
    Self.ReadBuffer(Pointer(Result)^, nChar * 2);
end;

function TStreamHelper.ReadWord: Word;
begin
  Self.ReadBuffer(Result, SizeOf(Result));
end;

procedure TStreamHelper.WriteAnsiChar(value: AnsiChar);
begin
  Self.WriteBuffer(value, SizeOf(value));
end;

procedure TStreamHelper.WriteByte(value: Byte);
begin
  Self.WriteBuffer(value, SizeOf(value));
end;

procedure TStreamHelper.WriteBytes(const value: TBytes);
begin
  if length(value) > 0 then
    Self.WriteBuffer(value[0], length(value));
end;

procedure TStreamHelper.WriteDword(value: UInt32);
begin
  Self.WriteBuffer(value, SizeOf(value));
end;

procedure TStreamHelper.WriteRawByteString(const value: RawByteString);
begin
  Self.WriteBuffer(Pointer(value)^, length(value));
end;

procedure TStreamHelper.WriteUnicodeString(const value: u16string);
begin
  Self.WriteBuffer(Pointer(value)^, length(value) shl 1);
end;

procedure TStreamHelper.WriteWideChar(value: WideChar);
begin
  Self.WriteBuffer(value, SizeOf(value));
end;

procedure TStreamHelper.WriteWideString(const value: WideString);
begin
  Self.WriteBuffer(Pointer(value)^, length(value) shl 1);
end;

procedure TStreamHelper.WriteWord(value: Word);
begin
  Self.WriteBuffer(value, SizeOf(value));
end;

{ TObjectListEx }

function TObjectListEx.Clone: TObjectListEx;
var
  i: Integer;
  item: TObject;
begin
  Result := TObjectListEx.Create(OwnsObjects);
  Result.count := Self.count;

  for i := 0 to Self.count - 1 do
  begin
    item := Self.items[i];

    if OwnsObjects then
      RefObject(item);

    Result[i] := item;
  end;
end;

procedure TObjectListEx.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if OwnsObjects and (Action = lnDeleted) then
    SmartUnrefObject(TObject(Ptr));
end;

{ TThreadObjectListEx }

constructor TThreadObjectListEx.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);
  InitializeCriticalSection(FLock);
end;

destructor TThreadObjectListEx.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TThreadObjectListEx.LockList;
begin
  EnterCriticalSection(FLock);
end;

procedure TThreadObjectListEx.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

{ TOperationStatus }

procedure TOperationStatus.init;
begin
  Self.Result := orUnknown;
  Self.errmsg := '';
  Self.SysErrorCode := 0;
end;

{ TActionStatus }

procedure TActionStatus.beginExec;
begin
  executing := True;
  timeBeginExecuting := GetTickCount;
end;

function TActionStatus.shouldTakeAction;
begin
  if executing and (GetTickCount - timeBeginExecuting > timeout) then
    endExec;

  if not executing and (GetTickCount - timeLatestExecution > interval) then
  begin
    beginExec;
    Result := True;
  end
  else
    Result := False;
end;

procedure TActionStatus.endExec;
begin
  executing := False;
  timeLatestExecution := GetTickCount;
end;

procedure TActionStatus.init;
begin
  executing := False;
  timeLatestExecution := 0;
  timeBeginExecuting := 0;
end;

procedure unitInit;
var
  i: Integer;
begin
  SetLength(g_PasswordChars, 126 - 32);
  for i := 0 to Length(g_PasswordChars) - 1 do
    PWideChar(g_PasswordChars)[i] := WideChar(33 + i);

  GetSystemInfo(g_SystemInfo);
  Pointer(@InterlockedIncDWORD) := Pointer(@InterlockedIncrement);
  Pointer(@InterlockedDecDWORD) := Pointer(@InterlockedDecrement);
  Pointer(@InterlockedExchangeDWORD) := Pointer(@InterlockedExchange);
  Pointer(@InterlockedCompareExchangeDWORD) := Pointer(@InterlockedCompareExchange);
  Pointer(@InterlockedExchangeAddDWORD) := Pointer(@InterlockedExchangeAdd);

  RandomStringA := RandomRBStr;
  RandomAlphaStringA := RandomAlphaRBStr;
  RandomDigitStringA := RandomDigitRBStr;
  RandomAlphaDigitStringA := RandomAlphaDigitRBStr;

  RandomStringW := RandomUStr;
  RandomAlphaStringw := RandomAlphaUStr;
  RandomDigitStringW := RandomDigitUStr;
  RandomAlphaDigitStringW := RandomAlphaDigitUStr;

  RBStrFormat := AnsiStrings.Format;
  UStrFormat := SysUtils.Format;
  RBStrCompareText := _RBStrCompareText;
  UStrCompareText := SysUtils.CompareText;
  RBStrSameText := _RBStrSameText;
  UStrSameText := SysUtils.SameText;
  RBStrFormatFloat := _RBStrFormatFloat;
  UStrFormatFloat := SysUtils.FormatFloat;
  RBStrTrim := _RBStrTrim;
  RBStrTrimLeft := _RBStrTrimLeft;
  RBStrTrimRight := _RBStrTrimRight;
  UStrTrim := SysUtils.trim;
  UStrTrimLeft := SysUtils.TrimLeft;
  UStrTrimRight := SysUtils.TrimRight;
  UrlGetParam := UStrUrlGetParam;
  UrlGetFileName := UStrUrlGetFileName;
  CharInSet := WCharInSet;
  isInteger := UStrIsInteger;
  IsValidEmail := UStrIsValidEmail;
  IsQQ := UStrIsQQ;
  IsCnIDCard := UStrIsCnIDCard;
  Array2Str := Array2UStr;
  StrRepeat := UStrRepeat;
  StrSplit2 := UStrSplit2;
  JAVA_TIME_START := EncodeDateTime(1970, 1, 1, 0, 0, 0, 0);

  QuickSort(@NAME_SORTED_CODE_PAGES, SizeOf(TCodePageInfo), length(NAME_SORTED_CODE_PAGES),
    TPointerCompareProc(@CompareCodePageByName), SwapCodePage);

  QuickSort(@ID_SORTED_CODE_PAGES, SizeOf(TCodePageInfo), length(ID_SORTED_CODE_PAGES),
    TPointerCompareProc(@CompareCodePageByID), SwapCodePage);

{$IFDEF POWER10_TABLE}
  initPower10Table;
{$ENDIF}
end;

procedure unitCleanup;
begin
end;

{ TInterlockSync }

procedure TInterlockSync.cleanup;
begin

end;

procedure TInterlockSync.init;
begin
  _state := 0;
  _threadId := 0;
  _nested := 0;
end;

procedure TInterlockSync.acquire(spinCount: Integer);
var
  ctid: DWORD;
  i, n: Integer;
  got: Boolean;
begin
  got := False;
  ctid := GetCurrentThreadId;
  if _threadId = ctid then
    got := True
  else
  begin
    while not got do
    begin
      if InterlockedExchange(_state, 1) = 0 then
      begin
{$IFDEF DSLSpinLockDebug}
        _lockBeginTime := timeGetTime;
{$ENDIF}
        got := True;
        Break;
      end;

      if g_SystemInfo.dwNumberOfProcessors > 1 then
      begin
        n := 1;

        while n < spinCount do
        begin
          for i := 1 to n do
          begin
                  asm
                    PAUSE
                  end;
          end;

          if InterlockedExchange(_state, 1) = 0 then
          begin
{$IFDEF DSLSpinLockDebug}
            _lockBeginTime := timeGetTime;
{$ENDIF}
            got := True;
            Break;
          end;

          n := n shl 1;
        end;
      end;

      if got then
        Break;

      Sleep(1);
    end;
  end;

  if got then
  begin
    _threadId := ctid;
    Inc(_nested);
  end;
end;

procedure TInterlockSync.release;
begin
  if (_threadId = GetCurrentThreadId) and (InterlockedDecrement(_nested) = 0) then
  begin
    _threadId := 0;
    InterlockedExchange(_state, 0);
{$IFDEF DSLSpinLockDebug}
    _lockBeginTime := timeGetTime - _lockBeginTime;
    DbgOutput('spin-lock ' + IntToStr(_lockBeginTime) + ' ms');
{$ENDIF}
  end;
end;

{ TInterlockSyncObject }

procedure TInterlockSyncObject.acquire;
begin
  inherited;
  internal.acquire;
end;

constructor TInterlockSyncObject.Create;
begin
  inherited Create;
  internal.init;
end;

procedure TInterlockSyncObject.release;
begin
  inherited;
  internal.release;
end;

{ TTimeKeeper }

procedure TTimeKeeper.start;
begin
  _beginTick := timeGetTime;
end;

function TTimeKeeper.stop: DWORD;
begin
  Result := timeGetTime - _beginTick;
end;


{ TLinkListEntry }

procedure TLinkListEntry.insertHead(node: PLinkListEntry);
begin
  node.next := Self.next;
  Self.next := node;
end;

function TLinkListEntry.SetEmpty: PLinkListEntry;
begin
  Result := Self.next;
  Self.next := @Self;
end;

{ TDblLinkListEntry }

procedure TDblLinkListEntry.insertHead(node: PDblLinkListEntry);
begin
  Self.next.prev := node;
  node.next := Self.next;
  node.prev := @Self;
  Self.next := node;
end;

procedure TDblLinkListEntry.insertTail(node: PDblLinkListEntry);
begin
  Self.prev.next := node;
  node.prev := Self.prev;
  node.next := @Self;
  Self.prev := node;
end;

function TDblLinkListEntry.SetEmpty: PDblLinkListEntry;
begin
  Result := Self.next;

  Self.prev := @Self;
  Self.next := @Self;
end;

{ T128BitBuf }

function T128BitBuf.toHex(UpperCase: Boolean; delimiter: u16string): string;
begin
  Result := MemHexUStr(Self, SizeOf(Self), UpperCase, delimiter);
end;

{ TCommunicationError }

procedure TCommunicationError.clear;
begin
  code := comerrSuccess;
  callee := '';
  internalErrorCode := 0;
  msg := '';
end;

procedure TCommunicationError.init;
begin
  clear;
end;

function TCommunicationError.isSuccess: Boolean;
begin
  Result := code = comerrSuccess;
end;

procedure TCommunicationError.reset;
begin
  clear;
end;

{ TRunnable }

constructor TDelegatedRunnable.Create(AProc: SysUtils.TProc);
begin
  inherited Create;
  FProc := AProc;
end;

procedure TDelegatedRunnable.run(context: TObject);
begin
  FProc();
end;

{ TKMPPatternSearchAnsi }

procedure TKMPPatternSearchAnsi.cleanup;
begin

end;

function TKMPPatternSearchAnsi.search(AText: PAnsiChar; TextLen: Integer): PAnsiChar;
var
  i, j: Integer;
begin
  j := -1;
  for i := 0 to TextLen - 1 do
  begin
    while True do
    begin
      if PAnsiChar(FPattern)[j + 1] <> AText[i] then
      begin
        if j >= 0 then j := FShiftTable[j]
        else Break;
      end
      else if j = Length(FPattern) - 2 then
      begin
        Result := AText + (i + 1 - Length(FPattern));
        Exit;
      end
      else begin
        Inc(j);
        Break;
      end;
    end;
  end;
  Result := nil;
end;

function TKMPPatternSearchAnsi.search(const AText: RawByteString): Integer;
var
  tmp: PAnsiChar;
begin
  tmp := search(PAnsiChar(AText), Length(AText));

  if tmp = nil then
    Result := 0
  else
    Result := tmp - PAnsiChar(AText) + 1;
end;

procedure TKMPPatternSearchAnsi.init(APattern: RawByteString);
begin
  FPattern := APattern;
  _BuildShiftTable;
end;

procedure TKMPPatternSearchAnsi._BuildShiftTable;
var
  i, j: Integer;
begin
  SetLength(FShiftTable, Length(FPattern));
  FShiftTable[0] := -1;
  j := -1;
  for i := 1 to Length(FPattern) - 1 do
  begin
    while True do
    begin
      if PAnsiChar(FPattern)[j + 1] <> PAnsiChar(FPattern)[i] then
      begin
        if j >= 0 then j := FShiftTable[j]
        else begin
          FShiftTable[i] := -1;
          Break;
        end;
      end
      else begin
        Inc(j);
        FShiftTable[i] := j;
        Break;
      end;
    end;
  end;
end;

procedure TKMPPatternSearchAnsi.init(APattern: PAnsiChar; PatternLen: Integer);
begin
  SetString(FPattern, APattern, PatternLen);
  _BuildShiftTable;
end;


{ TKMPPatternSearchUCS2 }

procedure TKMPPatternSearchUCS2.cleanup;
begin

end;

function TKMPPatternSearchUCS2.search(AText: PWideChar; TextLen: Integer): PWideChar;
var
  i, j: Integer;
begin
  j := -1;
  for i := 0 to TextLen - 1 do
  begin
    while True do
    begin
      if PWideChar(FPattern)[j + 1] <> AText[i] then
      begin
        if j >= 0 then j := FShiftTable[j]
        else Break;
      end
      else if j = Length(FPattern) - 2 then
      begin
        Result := AText + (i + 1 - Length(FPattern));
        Exit;
      end
      else begin
        Inc(j);
        Break;
      end;
    end;
  end;
  Result := nil;
end;

function TKMPPatternSearchUCS2.search(const AText: u16string): Integer;
var
  tmp: PWideChar;
begin
  tmp := search(PWideChar(AText), Length(AText));

  if tmp = nil then
    Result := 0
  else
    Result := tmp - PWideChar(AText) + 1;
end;

procedure TKMPPatternSearchUCS2.init(APattern: u16string);
begin
  FPattern := APattern;
  _BuildShiftTable;
end;

procedure TKMPPatternSearchUCS2._BuildShiftTable;
var
  i, j: Integer;
begin
  SetLength(FShiftTable, Length(FPattern));
  FShiftTable[0] := -1;
  j := -1;
  for i := 1 to Length(FPattern) - 1 do
  begin
    while True do
    begin
      if PWideChar(FPattern)[j + 1] <> PWideChar(FPattern)[i] then
      begin
        if j >= 0 then j := FShiftTable[j]
        else begin
          FShiftTable[i] := -1;
          Break;
        end;
      end
      else begin
        Inc(j);
        FShiftTable[i] := j;
        Break;
      end;
    end;
  end;
end;

procedure TKMPPatternSearchUCS2.init(APattern: PWideChar; PatternLen: Integer);
begin
  SetString(FPattern, APattern, PatternLen);
  _BuildShiftTable;
end;

{ TBoyerMoorePatternSearchAnsi }

procedure TBoyerMoorePatternSearchAnsi.cleanup;
begin

end;

procedure TBoyerMoorePatternSearchAnsi.init(APattern: RawByteString);
begin
  FPattern := APattern;
  _BuildShiftTable;
end;

procedure TBoyerMoorePatternSearchAnsi.init(APattern: PAnsiChar; PatternLen: Integer);
begin
  SetString(FPattern, APattern, PatternLen);
  _BuildShiftTable;
end;

function TBoyerMoorePatternSearchAnsi.search(AText: PAnsiChar; TextLen: Integer): PAnsiChar;
var
  i, j, k, patlen, offset: Integer;
  pat: PAnsiChar;
begin
  Result := nil;
  pat := PAnsiChar(Pointer(FPattern));
  patlen := Length(FPattern);
  if TextLen < patlen then Exit;
  i := patlen - 1;
  j := patlen - 1;
  while True do
  begin
    for k := 0 to patlen - 1 do
    begin
      if AText[i] = pat[j] then
      begin
        Dec(i);
        Dec(j);
      end
      else begin
        offset := FBadCharShift[AText[i]];
        if offset < FGoodSuffixShift[j]  then
          offset := FGoodSuffixShift[j];
        //DbgOutput('offset: ' + IntToStr(offset));
        Inc(i, offset);
        if i >= TextLen then Exit;
        j := patlen - 1;
      end;
    end;
    if j = -1 then
    begin
      Result := AText + i + 1;
      Break;
    end;
  end;
end;

function TBoyerMoorePatternSearchAnsi.search(const AText: RawByteString): Integer;
var
  tmp: PAnsiChar;
begin
  tmp := search(PAnsiChar(AText), Length(AText));

  if tmp = nil then
    Result := 0
  else
    Result := tmp - PAnsiChar(AText) + 1;
end;

procedure TBoyerMoorePatternSearchAnsi._BuildShiftTable;
var
  i, patlen: Integer;
  c: AnsiChar;
begin
  patlen := Length(FPattern);
  for c := Low(FBadCharShift) to High(FBadCharShift) do
    FBadCharShift[c] := patlen;
  for i := 0 to patlen - 1 do
    FBadCharShift[PAnsiChar(FPattern)[i]] := patlen - 1 - i;
  _CalcGoodSuffixTable;
end;

procedure TBoyerMoorePatternSearchAnsi._CalcGoodSuffixTable;
var
  i, j, sublen, len: Integer;
  pat, p1, p2: PAnsiChar;
  last: AnsiChar;
  flag: Boolean;
begin
  pat := PAnsiChar(FPattern);
  len := Length(FPattern);
  SetLength(FGoodSuffixShift, len);
  FGoodSuffixShift[len - 1] := 1;
  last := pat[len - 1];
  for i := len - 2 downto 0 do
  begin
    sublen := len - 1 - i;
    p1 := pat + len - 2;
    while True do
    begin
      while (p1 >= pat) and (p1^ <> last) do Dec(p1);
      p2 := p1 + 1 - sublen;
      if (p2 - 1 >= pat) and ((p2 -1)^ = pat[i]) then
      begin
        Dec(p1);
        Continue;
      end;

      flag := True;
      for j := 0 to sublen - 1 do
      begin
        if ((p2 + j) >= pat) and ((p2 + j)^ <> pat[i + 1 + j]) then
        begin
          Dec(p1);
          flag := False;
          Break;
        end;
      end;

      if flag then
      begin
        FGoodSuffixShift[i] := pat  + len  - p2;
        Break;
      end;
    end;
  end;
end;

{ TBigEndianDword }

procedure TBigEndianDword.setValue(newValue: UInt32);
begin
  data.value := ReverseByteOrder32(newValue);
end;

function TBigEndianDword.value: UInt32;
begin
  Result := ReverseByteOrder32(data.value);
end;

{ TBigEndianWord }

procedure TBigEndianWord.setValue(newValue: Word);
begin
  bytes := ReverseByteOrder16(newValue);
end;

function TBigEndianWord.value: Word;
begin
  Result := ReverseByteOrder16(bytes);
end;

initialization
  unitInit;

finalization
  unitCleanup;

end.

