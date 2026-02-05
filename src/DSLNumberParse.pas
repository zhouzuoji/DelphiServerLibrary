unit DSLNumberParse;

{$I ./DSLDefine.inc}

interface

uses
  SysUtils, Classes, DSLUtils;

// ParseNumber supports both integers and floats
function ParseNumber(s: PAnsiChar; endAt: PPAnsiChar = nil): TNumber; overload;
function ParseNumber(s: PWideChar; endAt: PPWideChar = nil): TNumber; overload;
function ParseNumber(s: PAnsiChar; slen: Integer; endAt: PPAnsiChar = nil): TNumber; overload;
function ParseNumber(s: PWideChar; slen: Integer; endAt: PPWideChar = nil): TNumber; overload;

implementation

uses
  Math, Variants;

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

procedure _calcInt(isNegative: Boolean; s: PAnsiChar; len: Integer; var number: TNumber); overload;
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

function ParseNumber(s: PAnsiChar; endAt: PPAnsiChar): TNumber;
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

function ParseNumber(s: PAnsiChar; slen: Integer; endAt: PPAnsiChar): TNumber;
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

procedure _calcInt(isNegative: Boolean; s: PWideChar; len: Integer; var number: TNumber); overload;
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

function ParseNumber(s: PWideChar; endAt: PPWideChar): TNumber;
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

function ParseNumber(s: PWideChar; slen: Integer; endAt: PPWideChar): TNumber;
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

end.
