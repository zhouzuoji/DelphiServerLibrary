unit DSLStringTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, DSLUtils, DSLByteStr, DSLTypeTrait;

type
  TShortStrTrait = class(TCustomTypeTrait)
  private
    procedure SetBytes(_Buf: PAnsiChar; _Len: Integer; var _Addr);
  protected
    procedure FromNull(var _Addr); override;
    procedure FromBool(_N: Boolean; var _Addr); override;
    procedure FromInt32(_N: Integer; var _Addr); override;
    procedure FromUint32(_N: Cardinal; var _Addr); override;
    procedure FromInt64(_N: Int64; var _Addr); override;
    procedure FromUint64(_N: Uint64; var _Addr); override;

    procedure FromSingle(_N: Single; var _Addr); override;
    procedure FromDouble(_N: Double; var _Addr); override;
    procedure FromExtended(_N: Extended; var _Addr); override;
    procedure FromComp(_N: Comp; var _Addr); override;
    procedure FromCurrency(_N: Currency; var _Addr); override;

    procedure FromByteStr(const _S: TByteStrBuilder; var _Addr); override;
    procedure FromShortString(const _S: ShortString; var _Addr); override;
    procedure FromRawByteStr(const _S: RawByteString; var _Addr); override;
    procedure FromWideString(const _S: WideString; var _Addr); override;
    procedure FromUtf16Str(const _S: UnicodeString; var _Addr); override;
  end;

  TByteStrTrait = class(TCustomTypeTrait)
  private
    procedure SetBytes(_Buf: PAnsiChar; _Len: Integer; var _Addr);
  protected
    procedure FromNull(var _Addr); override;
    procedure FromBool(_N: Boolean; var _Addr); override;
    procedure FromInt32(_N: Integer; var _Addr); override;
    procedure FromUint32(_N: Cardinal; var _Addr); override;
    procedure FromInt64(_N: Int64; var _Addr); override;
    procedure FromUint64(_N: Uint64; var _Addr); override;

    procedure FromSingle(_N: Single; var _Addr); override;
    procedure FromDouble(_N: Double; var _Addr); override;
    procedure FromExtended(_N: Extended; var _Addr); override;
    procedure FromComp(_N: Comp; var _Addr); override;
    procedure FromCurrency(_N: Currency; var _Addr); override;

    procedure FromByteStr(const _S: TByteStrBuilder; var _Addr); override;
    procedure FromShortString(const _S: ShortString; var _Addr); override;
    procedure FromRawByteStr(const _S: RawByteString; var _Addr); override;
    procedure FromWideString(const _S: WideString; var _Addr); override;
    procedure FromUtf16Str(const _S: UnicodeString; var _Addr); override;
  end;

  TWideStrTrait = class(TCustomTypeTrait)
  private
    procedure SetChars(_Buf: PWideChar; _Len: Integer; var _Addr);
  protected
    procedure FromNull(var _Addr); override;
    procedure FromBool(_N: Boolean; var _Addr); override;
    procedure FromInt32(_N: Integer; var _Addr); override;
    procedure FromUint32(_N: Cardinal; var _Addr); override;
    procedure FromInt64(_N: Int64; var _Addr); override;
    procedure FromUint64(_N: Uint64; var _Addr); override;

    procedure FromSingle(_N: Single; var _Addr); override;
    procedure FromDouble(_N: Double; var _Addr); override;
    procedure FromExtended(_N: Extended; var _Addr); override;
    procedure FromComp(_N: Comp; var _Addr); override;
    procedure FromCurrency(_N: Currency; var _Addr); override;

    procedure FromByteStr(const _S: TByteStrBuilder; var _Addr); override;
    procedure FromShortString(const _S: ShortString; var _Addr); override;
    procedure FromRawByteStr(const _S: RawByteString; var _Addr); override;
    procedure FromWideString(const _S: WideString; var _Addr); override;
    procedure FromUtf16Str(const _S: UnicodeString; var _Addr); override;
  end;

  TUtf16StrTrait = class(TCustomTypeTrait)
  private
    procedure SetChars(_Buf: PWideChar; _Len: Integer; var _Addr);
  protected
    procedure FromNull(var _Addr); override;
    procedure FromBool(_N: Boolean; var _Addr); override;
    procedure FromInt32(_N: Integer; var _Addr); override;
    procedure FromUint32(_N: Cardinal; var _Addr); override;
    procedure FromInt64(_N: Int64; var _Addr); override;
    procedure FromUint64(_N: Uint64; var _Addr); override;

    procedure FromSingle(_N: Single; var _Addr); override;
    procedure FromDouble(_N: Double; var _Addr); override;
    procedure FromExtended(_N: Extended; var _Addr); override;
    procedure FromComp(_N: Comp; var _Addr); override;
    procedure FromCurrency(_N: Currency; var _Addr); override;

    procedure FromByteStr(const _S: TByteStrBuilder; var _Addr); override;
    procedure FromShortString(const _S: ShortString; var _Addr); override;
    procedure FromRawByteStr(const _S: RawByteString; var _Addr); override;
    procedure FromWideString(const _S: WideString; var _Addr); override;
    procedure FromUtf16Str(const _S: UnicodeString; var _Addr); override;
  end;

implementation

uses
  AnsiStrings;

{ TShortStrTrait }

procedure TShortStrTrait.FromBool(_N: Boolean; var _Addr);
begin
  if _N then
  begin
    if MaxLen >= 4 then
      SetBytes('true', 4, _Addr)
    else
      SetBytes('1', 1, _Addr);
  end
  else begin
    if MaxLen >= 5 then
      SetBytes('false', 5, _Addr)
    else
      SetBytes('0', 1, _Addr);
  end;
end;

procedure TShortStrTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  SetBytes(_S.GetData, _S.Len, _Addr);
end;

procedure TShortStrTrait.FromComp(_N: Comp; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LExtended: Extended;
  LLen: Integer;
begin
  LExtended := _N;
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TShortStrTrait.FromCurrency(_N: Currency; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LLen: Integer;
begin
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, _N, fvCurrency, ffGeneral, 0, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, _N, fvCurrency, ffGeneral, 0, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TShortStrTrait.FromDouble(_N: Double; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LExtended: Extended;
  LLen: Integer;
begin
  LExtended := _N;
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TShortStrTrait.FromExtended(_N: Extended; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LLen: Integer;
begin
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, _N, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TShortStrTrait.FromInt32(_N: Integer; var _Addr);
var
  LBuf: array [0..31] of AnsiChar;
  P: PAnsiChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetBytes(P, @LBuf[31] - P, _Addr);
end;

procedure TShortStrTrait.FromInt64(_N: Int64; var _Addr);
var
  LBuf: array [0..31] of AnsiChar;
  P: PAnsiChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetBytes(P, @LBuf[31] - P, _Addr);
end;

procedure TShortStrTrait.FromNull(var _Addr);
begin
  PByte(@_Addr)^ := 0;
  PAnsiChar(@_Addr)[1] := #0;
end;

procedure TShortStrTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  SetBytes(PAnsiChar(_S), Length(_S), _Addr);
end;

procedure TShortStrTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  SetBytes(PAnsiChar(@_S) + 1, PByte(@_S)^, _Addr);
end;

procedure TShortStrTrait.FromSingle(_N: Single; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LExtended: Extended;
  LLen: Integer;
begin
  LExtended := _N;
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TShortStrTrait.FromUint32(_N: Cardinal; var _Addr);
var
  LBuf: array [0..31] of AnsiChar;
  P: PAnsiChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetBytes(P, @LBuf[31] - P, _Addr);
end;

procedure TShortStrTrait.FromUint64(_N: Uint64; var _Addr);
var
  LBuf: array [0..31] of AnsiChar;
  P: PAnsiChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetBytes(P, @LBuf[31] - P, _Addr);
end;

procedure TShortStrTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  FromRawByteStr(UTF8Encode(_S), _Addr);
end;

procedure TShortStrTrait.FromWideString(const _S: WideString; var _Addr);
begin
  FromRawByteStr(UTF8Encode(_S), _Addr);
end;

procedure TShortStrTrait.SetBytes(_Buf: PAnsiChar; _Len: Integer; var _Addr);
begin
  if _Len > Self.MaxLen then
    _Len := Self.MaxLen;
  PByte(@_Addr)^ := _Len;
  if _Len > 0 then
    Move(_Buf^, PAnsiChar(@_Addr)[1], _Len);
  //PAnsiChar(@_Addr)[_Len + 1] := #0;
end;

{ TByteStrTrait }

procedure TByteStrTrait.FromBool(_N: Boolean; var _Addr);
const
  SBoolStrs: array [Boolean] of RawByteString = ('false', 'true');
begin
  RawByteString(_Addr) := SBoolStrs[_N];
end;

procedure TByteStrTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  RawByteString(_Addr) := _S.Clone;
end;

procedure TByteStrTrait.FromComp(_N: Comp; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LExtended: Extended;
  LLen: Integer;
begin
  LExtended := _N;
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TByteStrTrait.FromCurrency(_N: Currency; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LLen: Integer;
begin
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, _N, fvCurrency, ffGeneral, 0, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, _N, fvCurrency, ffGeneral, 0, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TByteStrTrait.FromDouble(_N: Double; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LExtended: Extended;
  LLen: Integer;
begin
  LExtended := _N;
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TByteStrTrait.FromExtended(_N: Extended; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LLen: Integer;
begin
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, _N, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TByteStrTrait.FromInt32(_N: Integer; var _Addr);
var
  LBuf: array [0..31] of AnsiChar;
  P: PAnsiChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetBytes(P, @LBuf[31] - P, _Addr);
end;

procedure TByteStrTrait.FromInt64(_N: Int64; var _Addr);
var
  LBuf: array [0..31] of AnsiChar;
  P: PAnsiChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetBytes(P, @LBuf[31] - P, _Addr);
end;

procedure TByteStrTrait.FromNull(var _Addr);
begin
  RawByteString(_Addr) := '';
end;

procedure TByteStrTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  RawByteString(_Addr) := _S;
end;

procedure TByteStrTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  SetBytes(PAnsiChar(@_S) + 1, PByte(@_S)^, _Addr);
end;

procedure TByteStrTrait.FromSingle(_N: Single; var _Addr);
var
  LBuf: array [0 .. 127] of AnsiChar;
  LExtended: Extended;
  LLen: Integer;
begin
  LExtended := _N;
{$IF CompilerVersion > 22}
  LLen := AnsiStrings.FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$ELSE}
  LLen := FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings);
{$IFEND}
  SetBytes(LBuf, LLen, _Addr);
end;

procedure TByteStrTrait.FromUint32(_N: Cardinal; var _Addr);
var
  LBuf: array [0..31] of AnsiChar;
  P: PAnsiChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetBytes(P, @LBuf[31] - P, _Addr);
end;

procedure TByteStrTrait.FromUint64(_N: Uint64; var _Addr);
var
  LBuf: array [0..31] of AnsiChar;
  P: PAnsiChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetBytes(P, @LBuf[31] - P, _Addr);
end;

procedure TByteStrTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  RawByteString(_Addr) := UTF8Encode(_S);
end;

procedure TByteStrTrait.FromWideString(const _S: WideString; var _Addr);
begin
  RawByteString(_Addr) := UTF8Encode(_S);
end;

procedure TByteStrTrait.SetBytes(_Buf: PAnsiChar; _Len: Integer; var _Addr);
begin
  SetString(RawByteString(_Addr), _Buf, _Len);
end;

{ TWideStrTrait }

procedure TWideStrTrait.FromBool(_N: Boolean; var _Addr);
const
  SBoolStrs: array [Boolean] of WideString = ('false', 'true');
begin
  WideString(_Addr) := SBoolStrs[_N];
end;

procedure TWideStrTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  WideString(_Addr) := WideString(_S.Once);
end;

procedure TWideStrTrait.FromComp(_N: Comp; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
  LExtended: Extended;
begin
  LExtended := _N;
  SetChars(LBuf, FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings), _Addr);
end;

procedure TWideStrTrait.FromCurrency(_N: Currency; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
begin
  SetChars(LBuf, FloatToText(LBuf, _N, fvCurrency, ffGeneral, 0, 0, FormatSettings), _Addr);
end;

procedure TWideStrTrait.FromDouble(_N: Double; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
  LExtended: Extended;
begin
  LExtended := _N;
  SetChars(LBuf, FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings), _Addr);
end;

procedure TWideStrTrait.FromExtended(_N: Extended; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
begin
  SetChars(LBuf, FloatToText(LBuf, _N, fvExtended, ffGeneral, 15, 0, FormatSettings), _Addr);
end;

procedure TWideStrTrait.FromInt32(_N: Integer; var _Addr);
var
  LBuf: array [0..31] of WideChar;
  P: PWideChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetChars(P, @LBuf[31] - P, _Addr);
end;

procedure TWideStrTrait.FromInt64(_N: Int64; var _Addr);
var
  LBuf: array [0..31] of WideChar;
  P: PWideChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetChars(P, @LBuf[31] - P, _Addr);
end;

procedure TWideStrTrait.FromNull(var _Addr);
begin
  WideString(_Addr) := '';
end;

procedure TWideStrTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  WideString(_Addr) := WideString(_S);
end;

procedure TWideStrTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  WideString(_Addr) := WideString(_S);
end;

procedure TWideStrTrait.FromSingle(_N: Single; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
  LExtended: Extended;
begin
  LExtended := _N;
  SetChars(LBuf, FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings), _Addr);
end;

procedure TWideStrTrait.FromUint32(_N: Cardinal; var _Addr);
var
  LBuf: array [0..31] of WideChar;
  P: PWideChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetChars(P, @LBuf[31] - P, _Addr);
end;

procedure TWideStrTrait.FromUint64(_N: Uint64; var _Addr);
var
  LBuf: array [0..31] of WideChar;
  P: PWideChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetChars(P, @LBuf[31] - P, _Addr);
end;

procedure TWideStrTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  WideString(_Addr) := _S;
end;

procedure TWideStrTrait.FromWideString(const _S: WideString; var _Addr);
begin
  WideString(_Addr) := _S;
end;

procedure TWideStrTrait.SetChars(_Buf: PWideChar; _Len: Integer; var _Addr);
begin
  SetString(WideString(_Addr), _Buf, _Len);
end;

{ TUtf16StrTrait }

procedure TUtf16StrTrait.FromBool(_N: Boolean; var _Addr);
const
  SBoolStrs: array [Boolean] of UnicodeString = ('false', 'true');
begin
  UnicodeString(_Addr) := SBoolStrs[_N];
end;

procedure TUtf16StrTrait.FromByteStr(const _S: TByteStrBuilder; var _Addr);
begin
  UnicodeString(_Addr) := UnicodeString(_S.Once);
end;

procedure TUtf16StrTrait.FromComp(_N: Comp; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
  LExtended: Extended;
begin
  LExtended := _N;
  SetChars(LBuf, FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings), _Addr);
end;

procedure TUtf16StrTrait.FromCurrency(_N: Currency; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
begin
  SetChars(LBuf, FloatToText(LBuf, _N, fvCurrency, ffGeneral, 0, 0, FormatSettings), _Addr);
end;

procedure TUtf16StrTrait.FromDouble(_N: Double; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
  LExtended: Extended;
begin
  LExtended := _N;
  SetChars(LBuf, FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings), _Addr);
end;

procedure TUtf16StrTrait.FromExtended(_N: Extended; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
begin
  SetChars(LBuf, FloatToText(LBuf, _N, fvExtended, ffGeneral, 15, 0, FormatSettings), _Addr);
end;

procedure TUtf16StrTrait.FromInt32(_N: Integer; var _Addr);
var
  LBuf: array [0..31] of WideChar;
  P: PWideChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetChars(P, @LBuf[31] - P, _Addr);
end;

procedure TUtf16StrTrait.FromInt64(_N: Int64; var _Addr);
var
  LBuf: array [0..31] of WideChar;
  P: PWideChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetChars(P, @LBuf[31] - P, _Addr);
end;

procedure TUtf16StrTrait.FromNull(var _Addr);
begin
  UnicodeString(_Addr) := '';
end;

procedure TUtf16StrTrait.FromRawByteStr(const _S: RawByteString; var _Addr);
begin
  UnicodeString(_Addr) := UnicodeString(_S);
end;

procedure TUtf16StrTrait.FromShortString(const _S: ShortString; var _Addr);
begin
  UnicodeString(_Addr) := UnicodeString(_S);
end;

procedure TUtf16StrTrait.FromSingle(_N: Single; var _Addr);
var
  LBuf: array [0 .. 127] of WideChar;
  LExtended: Extended;
begin
  LExtended := _N;
  SetChars(LBuf, FloatToText(LBuf, LExtended, fvExtended, ffGeneral, 15, 0, FormatSettings), _Addr);
end;

procedure TUtf16StrTrait.FromUint32(_N: Cardinal; var _Addr);
var
  LBuf: array [0..31] of WideChar;
  P: PWideChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetChars(P, @LBuf[31] - P, _Addr);
end;

procedure TUtf16StrTrait.FromUint64(_N: Uint64; var _Addr);
var
  LBuf: array [0..31] of WideChar;
  P: PWideChar;
begin
  P := DSLUtils.StrInt(@LBuf[31], _N);
  SetChars(P, @LBuf[31] - P, _Addr);
end;

procedure TUtf16StrTrait.FromUtf16Str(const _S: UnicodeString; var _Addr);
begin
  UnicodeString(_Addr) := _S;
end;

procedure TUtf16StrTrait.FromWideString(const _S: WideString; var _Addr);
begin
  UnicodeString(_Addr) := _S;
end;

procedure TUtf16StrTrait.SetChars(_Buf: PWideChar; _Len: Integer; var _Addr);
begin
  SetString(UnicodeString(_Addr), _Buf, _Len);
end;

end.
