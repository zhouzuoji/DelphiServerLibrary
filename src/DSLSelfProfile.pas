unit DSLSelfProfile;

interface

uses
  SysUtils, Windows, DSLUtils;

procedure sar32_profile;
procedure sar64_profile;
procedure ReverseByteOrder32_profile;

implementation

function sar32_2(value: UInt32; bits: Integer): UInt32;
const
  SAR32_MASKS: array [0..1] of UInt32 = (0, UInt32(-1));
var
  idx: Integer;
begin
  bits := bits mod 32;
  idx := ((UInt32(1) shl 31) and value) shr 31;

  Result := (value shr bits) or (SAR32_MASKS[idx] shl (32 - bits));
end;

procedure sar32_profile;
var
  i: Integer;
  tick: DWORD;
  v, v2: UInt32;
begin
  v := $80000000;
  DbgOutput(IntToHex(v, 8));
  DbgOutput(IntToHex(sar32(v, 16), 8));
  DbgOutput(IntToHex(sar32_2(v, 16), 8));
  v2 := 0;

  tick := GetTickCount;
  for i := 0 to 500000000 - 1 do
    v2 := v2 + sar32(v, 16);
  tick := GetTickCount - tick;
  DbgOutput(IntToStr(tick) + ' ms');

  tick := GetTickCount;
  for i := 0 to 500000000 - 1 do
    v2 := v2 + sar32_2(v, 16);
  tick := GetTickCount - tick;
  DbgOutput(IntToStr(tick) + ' ms');

  DbgOutput(IntToHex(v2, 8));
end;

function sar64_2(value: Int64; bits: Integer): Int64;
const
  SAR64_MASKS: array [0..1] of Int64 = (0, -1);
var
  idx: Integer;
begin
  bits := bits mod 64;
  idx := ((Int64(1) shl 63) and value) shr 63;

  Result := (value shr bits) or (SAR64_MASKS[idx] shl (64 - bits));
end;

procedure sar64_profile;
var
  i: Integer;
  tick: DWORD;
  v, v2: Int64;
begin
  v := $8000000000000000;
  DbgOutput(IntToHex(v, 16));
  DbgOutput(IntToHex(sar64(v, 32), 16));
  DbgOutput(IntToHex(sar64_2(v, 32), 16));
  v2 := 0;
  tick := GetTickCount;
  for i := 0 to 500000000 - 1 do
    v2 := v2 + sar64(v, 32);
  tick := GetTickCount - tick;
  DbgOutput(IntToStr(tick) + ' ms');

  tick := GetTickCount;
  for i := 0 to 500000000 - 1 do
    v2 := v2 + sar64_2(v, 32);
  tick := GetTickCount - tick;
  DbgOutput(IntToStr(tick) + ' ms');

  DbgOutput(IntToHex(v2, 16));
end;

procedure shr64(var a: T64BitBuf; const b: Byte);
var
  c: Byte;
begin
  if b = 0 then
    Exit;

  if b >= 64 then
  begin
    a.dwords[0].value := 0;
    a.dwords[1].value := 0;
  end
  else if b < 32 then
  begin
    c := 32 - b;
    a.dwords[0].value := (a.dwords[0].value shr b) or (a.dwords[1].value shl c);
    a.dwords[1].value := a.dwords[1].value shr b;
  end
  else
  begin
    c := b - 32;
    a.dwords[0].value := a.dwords[1].value shr c;
    a.dwords[1].value := 0;
  end;
end;

procedure Reverse64Bit(var buf);
var
  buf2: T64BitBuf;
begin
  Int64(buf2) := Int64(buf);

  with T64BitBuf(buf) do
  begin
    bytes[0] := buf2.bytes[7];
    bytes[1] := buf2.bytes[6];
    bytes[2] := buf2.bytes[5];
    bytes[3] := buf2.bytes[4];
    bytes[4] := buf2.bytes[3];
    bytes[5] := buf2.bytes[2];
    bytes[6] := buf2.bytes[1];
    bytes[7] := buf2.bytes[0];
  end;
end;

function ReverseByteOrder32_1(V: UInt32): UInt32;
begin
  Result := (V shr 24) or ((V shr 8) and $ff00) or
    (V shl 24) or ((V shl 8) and $ff0000);
end;

function ReverseByteOrder32_2(V: UInt32): UInt32;
begin
  with T32BitBuf(Result) do
  begin
    bytes[0] := T32BitBuf(V).bytes[3];
    bytes[1] := T32BitBuf(V).bytes[2];
    bytes[2] := T32BitBuf(V).bytes[1];
    bytes[3] := T32BitBuf(V).bytes[0];
  end;
end;

procedure ReverseByteOrder32_profile;
var
  i: Integer;
  tick: DWORD;
  v, v2: UInt32;
begin
  v := Random($7fffffff);
  DbgOutput(IntToHex(v, 8));
  DbgOutput(IntToHex(ReverseByteOrder32(v), 8));
  DbgOutput(IntToHex(ReverseByteOrder32_1(v), 8));
  DbgOutput(IntToHex(ReverseByteOrder32_2(v), 8));
  v2 := 0;

  tick := GetTickCount;
  for i := 0 to 100000000 - 1 do
    v2 := v2 + ReverseByteOrder32(v);
  tick := GetTickCount - tick;
  DbgOutput('ReverseByteOrder32(shift bits inline): ' + IntToStr(tick) + ' ms');

  tick := GetTickCount;
  for i := 0 to 100000000 - 1 do
    v2 := v2 + ReverseByteOrder32_1(v);
  tick := GetTickCount - tick;
  DbgOutput('ReverseByteOrder32(shift bits): ' + IntToStr(tick) + ' ms');

  tick := GetTickCount;
  for i := 0 to 100000000 - 1 do
    v2 := v2 + ReverseByteOrder32_2(v);
  tick := GetTickCount - tick;
  DbgOutput('ReverseByteOrder32(byte assign): ' + IntToStr(tick) + ' ms');

  DbgOutput(IntToHex(v2, 8));
end;

end.
