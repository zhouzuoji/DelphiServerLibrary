{$PointerMath on}

unit DSLArray;

interface

uses
  SysUtils, Classes, DSLCore;

type
  TdslArray<T> = record
  public
    type TItemPointer = TdslTypeInfo<T>.TPointer;
  private
    tvItems: array of T;
    tvCount: Integer;
    function GetCapacity: Integer; inline;
    procedure SetCount(const avNewCount: Integer);
    procedure SetCapacity(const avNewCapacity: Integer);
    function GetCount: Integer;
    function GetItem(avIndex: Integer): T; inline;
    procedure SetItem(avIndex: Integer; const avValue: T); inline;
    function GetItemNoCheck(avIndex: Integer): T;
    procedure SetItemNoCheck(avIndex: Integer; const avValue: T);
    function GetItemPointer(avIndex: Integer): TItemPointer; inline;
    procedure Grow(avMinCapacity: Integer);
  public
    procedure Clear;
    procedure Add(const v: T); overload;
    procedure Add(const varr: array of T); overload;
    procedure Add(avItem: TItemPointer; avCount: Integer); overload;
    procedure Add(const arr: TdslArray<T>); overload;
    procedure Delete(avIndex: Integer; avCount: Integer = 1);
    procedure Insert(avIndex: Integer; const v: T); overload;
    procedure Insert(avIndex: Integer; avItem: TItemPointer; avCount: Integer); overload;
    procedure Insert(avIndex: Integer; const varr: array of T); overload;
    class operator Add(const a, b: TdslArray<T>): TdslArray<T>;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property _[avIndex: Integer]: T read GetItemNoCheck write SetItemNoCheck;
    property Items[avIndex: Integer]: T read GetItem write SetItem; default;
    property ItemPointer[avIndex: Integer]: TItemPointer read GetItemPointer;
  end;

  TdslArrayUtils<T> = record
  public
    type TItemPointer = TdslTypeInfo<T>.TPointer;
  private
    class procedure BatchMoveManaged(avSrc, avDest: TItemPointer; avLength: Integer); static;
    class procedure BatchMovePOD(avSrc, avDest: TItemPointer; avLength: Integer); static; inline;
    class procedure BatchCopyManaged(avSrc, avDest: TItemPointer; avLength: Integer); static;
    class procedure BatchCopyPOD(avSrc, avDest: TItemPointer; avLength: Integer); static; inline;
    class procedure CleanupManaged(avFrom, avTo: TItemPointer); static;
  public
    class constructor Create;
    class procedure Append(var arr: TArray<T>; const v: T); overload; static;
    class procedure Append(var arr: TArray<T>; const avItems: array of T); overload; static;
    class function Delete(avBase: TItemPointer; avLength: Integer; avIndex:
      Integer; avCount: Integer = 1): Integer; static;
    class procedure Insert(var arr: TArray<T>; avIndex: Integer; const v: T); overload; static;
    class procedure Insert(var arr: TArray<T>; avIndex: Integer; const avItems: array of T); overload; static;
    class procedure Insert(var arr: TArray<T>; avIndex: Integer; avItem: TItemPointer; avCount: Integer); overload; static;

    class procedure BatchMove(avSrc, avDest: TItemPointer; avLength: Integer); static; inline;
    class procedure BatchCopy(avSrc, avDest: TItemPointer; avLength: Integer); static; inline;
    class procedure Cleanup(avFrom, avTo: TItemPointer); static; inline;
  end;

function SuggestCapacity(avMinimal: Integer; avTypeSize: Integer = 0): Integer;

procedure InvalidIndexError(avIndex: Integer); inline;

implementation

function SuggestCapacity(avMinimal, avTypeSize: Integer): Integer;
const
  MAX_DELTA = 256;
  CAP_TABLE: array [0..32] of Integer = (
    8, 8, 16, 32, 32, 64, 64, 64, 64,
    128, 128, 128, 128, 128, 128, 128, 128,
    256, 256, 256, 256, 256, 256, 256, 256,
    256, 256, 256, 256, 256, 256, 256, 256
  );
begin
  if avMinimal > MAX_DELTA then
    avMinimal := ((avMinimal + 255) and not Integer(255))
  else
    avMinimal := CAP_TABLE[(avMinimal + 7) shr 3];
  Result := avMinimal;
end;

procedure InvalidIndexError(avIndex: Integer);
begin

end;

{ TdslArray<T> }

procedure TdslArray<T>.Add(const v: T);
begin
  Self.Grow(GetCount+1);
  tvItems[tvCount] := v;
  Inc(tvCount);
end;

procedure TdslArray<T>.Add(const varr: array of T);
var
  n: Integer;
begin
  n := Length(varr);
  if n > 0 then
  begin
    Self.Grow(GetCount+n);
    TdslArrayUtils<T>.BatchCopy(@varr[0], @tvItems[tvCount], n);
    Inc(tvCount, n);
  end;
end;

class operator TdslArray<T>.Add(const a, b: TdslArray<T>): TdslArray<T>;
var
  len1, len2: Integer;
begin
  len1 := a.Count;
  len2 := b.Count;
  Result.SetCapacity(len1 + len2);
  if len1 > 0 then
    TdslArrayUtils<T>.BatchCopy(@a.tvItems[0], @Result.tvItems[0], len1);
  if len2 > 0 then
    TdslArrayUtils<T>.BatchCopy(@b.tvItems[0], @Result.tvItems[len1], len2);
  Result.tvCount := len1 + len2;
end;

procedure TdslArray<T>.Add(avItem: TItemPointer; avCount: Integer);
begin
  if avCount > 0 then
  begin
    Self.Grow(GetCount+avCount);
    TdslArrayUtils<T>.BatchCopy(avItem, @tvItems[tvCount], avCount);
    Inc(tvCount, avCount);
  end;
end;

procedure TdslArray<T>.Clear;
begin
  SetLength(tvItems, 0);
  tvCount := 0;
end;

procedure TdslArray<T>.Add(const arr: TdslArray<T>);
begin
  Self.Grow(GetCount+arr.Count);
end;

procedure TdslArray<T>.Delete(avIndex, avCount: Integer);
var
  lvOldCount: Integer;
begin
  lvOldCount := Self.GetCount;

  if (avIndex >= 0) and (avIndex < lvOldCount) then
  begin
    if avIndex + avCount > lvOldCount then
      avCount := lvOldCount - avIndex;
    TdslArrayUtils<T>.BatchCopy(@tvItems[avIndex + avCount], @tvItems[avIndex], lvOldCount-avIndex-avCount);
    TdslArrayUtils<T>.Cleanup(@tvItems[lvOldCount - avCount], @tvItems[lvOldCount]);
    Dec(tvCount, avCount);
  end
  else
    InvalidIndexError(avIndex);
end;

function TdslArray<T>.GetCapacity: Integer;
begin
  Result := Length(tvItems);
end;

function TdslArray<T>.GetCount: Integer;
begin
  if tvItems = nil then
    tvCount := 0;
  Result := tvCount;
end;

function TdslArray<T>.GetItem(avIndex: Integer): T;
begin
  if (avIndex >= 0) and (avIndex < GetCount) then
    Result := tvItems[avIndex]
  else
    InvalidIndexError(avIndex);
end;

function TdslArray<T>.GetItemNoCheck(avIndex: Integer): T;
begin
  Result := tvItems[avIndex];
end;

function TdslArray<T>.GetItemPointer(avIndex: Integer): TItemPointer;
begin
  Result := @tvItems[avIndex];
end;

procedure TdslArray<T>.Grow(avMinCapacity: Integer);
var
  lvOldCapacity: Integer;
begin
  lvOldCapacity := Length(tvItems);
  if avMinCapacity > lvOldCapacity then
    SetLength(tvItems, SuggestCapacity(avMinCapacity));
end;

procedure TdslArray<T>.Insert(avIndex: Integer; const v: T);
begin
  if (avIndex >= 0) and (avIndex <= GetCount) then
  begin
    Self.Grow(tvCount+1);
    if avIndex < tvCount then
      TdslArrayUtils<T>.BatchCopy(@tvItems[avIndex], @tvItems[avIndex + 1], tvCount - avIndex);
    tvItems[tvCount] := v;
    Inc(tvCount);
  end
  else
    InvalidIndexError(avIndex);
end;

procedure TdslArray<T>.Insert(avIndex: Integer; const varr: array of T);
var
  n: Integer;
begin
  n := Length(varr);
  if n > 0 then
    Self.Insert(avIndex, TItemPointer(@varr[0]), n);
end;

procedure TdslArray<T>.Insert(avIndex: Integer; avItem: TItemPointer; avCount: Integer);
begin
  if avCount > 0 then
  begin
    if (avIndex >= 0) and (avIndex <= tvCount) then
    begin
      Self.Grow(GetCount+avCount);
      if avIndex < tvCount then
        TdslArrayUtils<T>.BatchCopy(@tvItems[avIndex], @tvItems[avIndex + avCount], tvCount - avIndex);
      TdslArrayUtils<T>.BatchCopy(avItem, @tvItems[avIndex], avCount);
      Inc(tvCount, avCount);
    end
    else
      InvalidIndexError(avIndex);
  end;
end;

procedure TdslArray<T>.SetCapacity(const avNewCapacity: Integer);
begin
  if avNewCapacity >= Count then
    SetLength(tvItems, avNewCapacity);
end;

procedure TdslArray<T>.SetCount(const avNewCount: Integer);
var
  i: Integer;
begin
  if avNewCount > Count then
  begin
    if avNewCount > Length(tvItems) then
      SetLength(tvItems, avNewCount);
  end
  else begin
    if TdslTypeInfo<T>.IsManagedType then
    begin
      for i := avNewCount to tvCount - 1 do
        Finalize(tvItems[i]);
    end;
  end;
  
  tvCount := avNewCount;
end;

procedure TdslArray<T>.SetItem(avIndex: Integer; const avValue: T);
begin
  if (avIndex >= 0) and (avIndex < GetCount) then
    tvItems[avIndex] := avValue
  else
    InvalidIndexError(avIndex);
end;

procedure TdslArray<T>.SetItemNoCheck(avIndex: Integer; const avValue: T);
begin
  tvItems[avIndex] := avValue;
end;

{ TdslArrayUtils<T> }

class procedure TdslArrayUtils<T>.Append(var arr: TArray<T>; const v: T);
var
  n: Integer;
begin
  n := Length(arr);
  SetLength(arr, n+1);
  arr[n] := v;
end;

class procedure TdslArrayUtils<T>.Append(var arr: TArray<T>; const avItems: array of T);
var
  n, n2: Integer;
begin
  n := Length(arr);
  n2 := Length(avItems);
  if n2 > 0 then
  begin
    SetLength(arr, n+n2);
    BatchCopy(@avItems[0], @arr[n], n2);
  end;
end;

class function TdslArrayUtils<T>.Delete(avBase: TItemPointer; avLength, avIndex, avCount: Integer): Integer;
begin
  if (avIndex >= 0) and (avIndex < avLength) then
  begin
    if avIndex + avCount > avLength then
      avCount := avLength - avIndex;
    BatchCopy(avBase + avIndex + avCount, avBase + avIndex, avLength-avIndex-avCount);
    Cleanup(avBase + avLength - avCount, avBase + avLength);
    Result := avCount;
  end
  else begin
    Result := 0;
    InvalidIndexError(avIndex);
  end;
end;

class procedure TdslArrayUtils<T>.Insert(var arr: TArray<T>; avIndex: Integer;
  avItem: TItemPointer; avCount: Integer);
var
  lvOldLen: Integer;
begin
  if avCount > 0 then
  begin
    lvOldLen := Length(arr);
    if (avIndex >= 0) and (avIndex <= lvOldLen) then
    begin
      SetLength(arr, lvOldLen + avCount);
      if avIndex < lvOldLen then
        TdslArrayUtils<T>.BatchCopy(@arr[avIndex], @arr[avIndex + avCount], lvOldLen - avIndex);
      TdslArrayUtils<T>.BatchCopy(avItem, @arr[avIndex], avCount);
    end
    else
      InvalidIndexError(avIndex);
  end;
end;

class procedure TdslArrayUtils<T>.Insert(var arr: TArray<T>; avIndex: Integer; const v: T);
var
  lvOldLen: Integer;
begin
  lvOldLen := Length(arr);
  if (avIndex >= 0) and (avIndex <= lvOldLen) then
  begin
    if avIndex < lvOldLen then
      TdslArrayUtils<T>.BatchCopy(@arr[avIndex], @arr[avIndex + 1], lvOldLen - avIndex);
    arr[avIndex] := v;
  end
  else
    InvalidIndexError(avIndex);
end;

class procedure TdslArrayUtils<T>.Insert(var arr: TArray<T>; avIndex: Integer; const avItems: array of T);
var
  n: Integer;
begin
  n := Length(avItems);
  if n > 0 then
    Insert(arr, avIndex, TItemPointer(@avItems[0]), n);
end;

class procedure TdslArrayUtils<T>.BatchCopy(avSrc, avDest: TItemPointer; avLength: Integer);
begin
  if TdslTypeInfo<T>.IsManagedType then
    BatchCopyManaged(avSrc, avDest, avLength)
  else
    BatchCopyPOD(avSrc, avDest, avLength);
end;

class procedure TdslArrayUtils<T>.BatchCopyManaged(avSrc, avDest: TItemPointer; avLength: Integer);
var
  i: Integer;
begin
  if avDest < avSrc then
  begin
    for i := 0 to avLength - 1 do
      avDest[i] := avSrc[i];
  end
  else if avDest > avSrc then
  begin
    for i := avLength - 1 downto 0 do
      avDest[i] := avSrc[i];
  end;
end;

class procedure TdslArrayUtils<T>.BatchCopyPOD(avSrc, avDest: TItemPointer; avLength: Integer);
begin
  Move(avSrc^, avDest^, avLength * SizeOf(T));
end;

class procedure TdslArrayUtils<T>.BatchMove(avSrc, avDest: TItemPointer; avLength: Integer);
begin
  if TdslTypeInfo<T>.IsManagedType then
    BatchMoveManaged(avSrc, avDest, avLength)
  else
    BatchMovePOD(avSrc, avDest, avLength);
end;

class procedure TdslArrayUtils<T>.BatchMoveManaged(avSrc, avDest: TItemPointer; avLength: Integer);
var
  i: Integer;
begin
  if avDest < avSrc then
  begin
    for i := 0 to avLength - 1 do
      avDest[i] := avSrc[i];
    Inc(avDest, avLength);
    if avDest < avSrc then
      avDest := avSrc;
    Inc(avSrc, avLength);
    while avDest < avSrc do
    begin
      Finalize(avDest^);
      Inc(avDest);
    end;
  end
  else if avDest > avSrc then
  begin
    for i := avLength - 1 downto 0 do
      avDest[i] := avSrc[i];
    if avDest > avSrc + avLength then
      avDest := avSrc + avLength;
    while avSrc < avDest do
    begin
      Finalize(avSrc^);
      Inc(avSrc);
    end;
  end;
end;

class procedure TdslArrayUtils<T>.BatchMovePOD(avSrc, avDest: TItemPointer; avLength: Integer);
begin
  Move(avSrc^, avDest^, avLength * SizeOf(T));
end;

class procedure TdslArrayUtils<T>.Cleanup(avFrom, avTo: TItemPointer);
begin
  if TdslTypeInfo<T>.IsManagedType then
    CleanupManaged(avFrom,avTo);
end;

class procedure TdslArrayUtils<T>.CleanupManaged(avFrom, avTo: TItemPointer);
begin
  while avFrom < avTo do
  begin
    Finalize(avFrom^);
    Inc(avFrom);
  end;
end;

class constructor TdslArrayUtils<T>.Create;
begin

end;

end.
