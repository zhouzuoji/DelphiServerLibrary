{$B-,C+,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,U-,V+,W-,X+,Z1}
{$O+}   // optimization on
{$T+}   // typed pointers on
{$POINTERMATH ON}
unit DSLByteStr;

interface

uses
  SysUtils, Classes, DSLUtils;

type
  PStrRec = ^TStrRec;
  TStrRec = packed record
  {$IF defined(CPU64BITS)}
    _Padding: Integer; // Make 16 byte align for payload..
  {$ENDIF}
    codePage: Word;
    elemSize: Word;
    refCnt: Integer;
    length: Integer;
  end;

  TMemType = (
    mtStack,
    mtHeap,
    mtExternal,
    mtString
  );
  PByteStrBuilder = ^TByteStrBuilder;
  TByteStrBuilder = record
  private
    FType: TMemType;
    FCodePage: Word;
    FBuffer: PAnsiChar;
    FBufCap: Integer;
    FHeap: array of AnsiChar;
    FExternal: PAnsiChar;
    FLength: Integer;
    FStr: RawByteString;
    function Grow(_Delta: Integer): PByteStrBuilder;
    function DoAppend(_Buf: PAnsiChar; _Len: Integer): PByteStrBuilder;
  public
    constructor Create(var _Buf; _BufSize: Integer; _CodePage: Word = CP_UTF8);
    function Cleanup: PByteStrBuilder;
    function Reset: PByteStrBuilder;
    function SetExternal(_Buf: PAnsiChar; _Len: Integer): PByteStrBuilder;
    function SetByteStr(const _S: RawByteString): PByteStrBuilder;
    function Append(_Buf: PAnsiChar; _Len: Integer): PByteStrBuilder; overload;
    function Append(const _S: RawByteString): PByteStrBuilder; overload;
    function AppendChar(_Ch: AnsiChar): PByteStrBuilder;
    function Append(_Val: Int64): PByteStrBuilder; overload;
    function Append(_Val: Extended): PByteStrBuilder; overload;
    function Truncate(_Len: Integer): PByteStrBuilder;
    function ToNumber(_EndAt: PPAnsiChar = nil): TNumber;
    function GetData: PAnsiChar;
    function Once: RawByteString;
    function Clone: RawByteString;
    property Len: Integer read FLength;
    property MemType: TMemType read FType;
  end;

function CalcCapacity(MinSize: Integer): Integer;

implementation

uses
  AnsiStrings, DSLNumberParse;

function CalcCapacity(MinSize: Integer): Integer;
begin
  if MinSize < 64 then
    Result := 64
  else if MinSize < 128 then
    Result := 128
  else if MinSize < 256 then
    Result := 256
  else if MinSize < 512 then
    Result := 512
  else if MinSize < 1024 then
    Result := 1024
  else
    Result := (MinSize + 1023) div 1024 *1024;
end;

{ Internal<BufferType> }

function TByteStrBuilder.Append(_Buf: PAnsiChar; _Len: Integer): PByteStrBuilder;
begin
  if _Len > 0 then
    Self.DoAppend(_Buf, _Len);
  Result := @Self;
end;

function TByteStrBuilder.AppendChar(_Ch: AnsiChar): PByteStrBuilder;
var
  P: PAnsiChar;
begin
  Self.Grow(1);
  P := nil;
  case FType of
    mtStack: P := FBuffer;
    mtHeap: P := @FHeap[0];
  end;
  P[SizeOf(TStrRec) + FLength] := _Ch;
  Inc(FLength);
  PStrRec(P).length := FLength;
  P[SizeOf(TStrRec) + FLength] := #0;
  Result := @Self;
end;

function TByteStrBuilder.Append(_Val: Extended): PByteStrBuilder;
var
  LBuf: array [0 .. 63] of AnsiChar;
begin
  Result := Self.DoAppend(LBuf, AnsiStrings.FloatToText(LBuf, _Val, fvExtended, ffGeneral, 15, 0));
end;

function TByteStrBuilder.Append(_Val: Int64): PByteStrBuilder;
var
  LBuf: array [0..31] of AnsiChar;
  P: PAnsiChar;
begin
  P := DSLUtils.StrInt(PAnsiChar(@LBuf[31]), _Val);
  Result := Self.DoAppend(P, PAnsiChar(@LBuf[31]) - P);
end;

function TByteStrBuilder.Append(const _S: RawByteString): PByteStrBuilder;
begin
  if FLength = 0 then
    Self.SetByteStr(_S)
  else if _S <> '' then
    Self.DoAppend(PAnsiChar(_S), Length(_S));
  Result := @Self;
end;

function TByteStrBuilder.Cleanup: PByteStrBuilder;
begin
  FExternal := nil;
  FStr := '';
  FLength := 0;
  FHeap := nil;
  FType := mtStack;
  Result := @Self;
end;

function TByteStrBuilder.Clone: RawByteString;
var
  P: PAnsiChar;
begin
  if FLength = 0 then
    Exit('');
  P := nil;
  case FType of
    mtStack: P := FBuffer + SizeOf(TStrRec);
    mtHeap: P := @FHeap[SizeOf(TStrRec)];
    mtExternal: P := FExternal;
    mtString: Exit(FStr);
  end;
  SetString(Result, P, FLength);
end;

constructor TByteStrBuilder.Create(var _Buf; _BufSize: Integer; _CodePage: Word);
begin
  FCodePage := _CodePage;
  FExternal := nil;
  FLength := 0;
  FType := mtStack;
  FBuffer := PAnsiChar(@_Buf);
  FBufCap := _BufSize;

  if _BufSize > SizeOf(TStrRec) then
  begin
    FBuffer[SizeOf(TStrRec)] := #0;
    PStrRec(FBuffer).codePage := _CodePage;
    PStrRec(FBuffer).elemSize := 1;
    PStrRec(FBuffer).refCnt := -1;
    PStrRec(FBuffer).length := 0;
  end;
end;

function TByteStrBuilder.DoAppend(_Buf: PAnsiChar; _Len: Integer): PByteStrBuilder;
var
  P: PAnsiChar;
begin
  Self.Grow(_Len);
  P := nil;
  case FType of
    mtStack: P := FBuffer;
    mtHeap: P := @FHeap[0];
  end;
  Move(_Buf^, P[SizeOf(TStrRec) + FLength], _Len);
  Inc(FLength, _Len);
  PStrRec(P).length := FLength;
  P[SizeOf(TStrRec) + FLength] := #0;
  Result := @Self;
end;

function TByteStrBuilder.GetData: PAnsiChar;
begin
  Result := nil;
  if FLength > 0 then
    case FType of
      mtStack: Result := FBuffer + SizeOf(TStrRec);
      mtHeap: Result := @FHeap[SizeOf(TStrRec)];
      mtExternal: Result := FExternal;
      mtString: Pointer(Result) := Pointer(FStr);
    end;
end;

function TByteStrBuilder.Grow(_Delta: Integer): PByteStrBuilder;
var
  LMin: Integer;
  P: PAnsiChar;
  LOldType: TMemType;
label
  lbl_stack, lbl_heap, lbl_external;
begin
  LMin := _Delta + FLength + SizeOf(TStrRec) + 1;
  LOldType := FType;
  case LOldType of
    mtStack:
      if FBufCap < LMin then
      begin
        SetLength(FHeap, CalcCapacity(LMin));
        if FLength > 0 then
          Move(FBuffer^, FHeap[0], FLength + SizeOf(TStrRec) + 1)
        else begin
          PStrRec(FHeap).codePage := FCodePage;
          PStrRec(FHeap).elemSize := 1;
          PStrRec(FHeap).refCnt := -1;
          PStrRec(FHeap).length := 0;
          FHeap[SizeOf(TStrRec)] := #0;
        end;
        FType := mtHeap;
      end;
    mtHeap:
      if Length(FHeap) < LMin then
        SetLength(FHeap, CalcCapacity(LMin));
    mtExternal, mtString:
      begin
        if FBufCap >= LMin then
        begin
          P := FBuffer;
          FType := mtStack;
        end
        else begin
          if Length(FHeap) < LMin then
          begin
            SetLength(FHeap, CalcCapacity(LMin));
            PStrRec(FHeap).codePage := FCodePage;
            PStrRec(FHeap).elemSize := 1;
            PStrRec(FHeap).refCnt := -1;
          end;
          P := @FHeap[0];
          FType := mtHeap;
        end;
        PStrRec(P).length := FLength;
        if FLength > 0 then
        begin
          if LOldType = mtExternal then
            Move(FExternal^, P[SizeOf(TStrRec)], FLength)
          else
            Move(FStr[1], P[SizeOf(TStrRec)], FLength)
        end;
        P[SizeOf(TStrRec) + FLength] := #0;
        FExternal := nil;
        FStr := '';
      end;
  end;
  Result := @Self;
end;

function TByteStrBuilder.Once: RawByteString;
begin
  if FLength = 0 then
    Exit('');
  case FType of
    mtStack: Result := RawByteString(Pointer(FBuffer + SizeOf(TStrRec)));
    mtHeap: Result := RawByteString(Pointer(@FHeap[SizeOf(TStrRec)]));
    mtExternal: SetString(Result, FExternal, FLength);
    mtString: Result := FStr;
  end;
end;

function TByteStrBuilder.Reset: PByteStrBuilder;
begin
  FExternal := nil;
  FLength := 0;
  FStr := '';
  if Length(FHeap) > FBufCap then
    FType := mtHeap
  else
    FType := mtStack;
  Result := @Self;
end;

function TByteStrBuilder.SetExternal(_Buf: PAnsiChar; _Len: Integer): PByteStrBuilder;
begin
  FExternal := _Buf;
  FLength := _Len;
  FType := mtExternal;
  Result := @Self;
end;

function TByteStrBuilder.SetByteStr(const _S: RawByteString): PByteStrBuilder;
begin
  FStr := _S;
  FType := mtString;
  FLength := Length(_S);
  Result := @Self;
end;

function TByteStrBuilder.ToNumber(_EndAt: PPAnsiChar): TNumber;
var
  P: PAnsiChar;
begin
  if FLength = 0 then
    Result._type := numNaN
  else begin
    P := GetData;
    if P[FLength] = #0 then
      Result := parseNumber(P, _EndAt)
    else
      Result := parseNumber(P, FLength, _EndAt);
  end;
end;

function TByteStrBuilder.Truncate(_Len: Integer): PByteStrBuilder;
begin
  if _Len < 0 then
    _Len := 0;
  if _Len < FLength then
  begin
    FLength := _Len;
    case FType of
      mtStack:
        begin
          PStrRec(FBuffer).length := _Len;
          FBuffer[SizeOf(TStrRec) + _Len] := #0;
        end;
      mtHeap:
        begin
          PStrRec(FHeap).length := _Len;
          FHeap[SizeOf(TStrRec) + _Len] := #0;
        end
      else
    end;
  end;
  Result := @Self;
end;

end.
