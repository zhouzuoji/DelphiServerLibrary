{$PointerMath on}

unit DSLCircularList;

interface

uses
  SysUtils, Classes, Math, DSLCore, DSLArray;

type
  TdslCircularList<T> = record
  public
    type TItemPointer = TdslTypeInfo<T>.TPointer;
  private
    tvItems: array of T;
    tvBaseIndex: Integer;
    tvCount: Integer;
    function GetCapacity: Integer; inline;
    procedure SetCapacity(const avNewCapacity: Integer);
    function GetCount: Integer;
    procedure SetCount(const avNewCount: Integer); inline;
    function GetBaseIndex: Integer;
    procedure SetBaseIndex(avNewBaseIndex: Integer);
    function GetItem(avIndex: Integer): T;
    procedure SetItem(avIndex: Integer; const avValue: T);
    function GetItemNoCheck(avIndex: Integer): T; inline;
    procedure SetItemNoCheck(avIndex: Integer; const avValue: T); inline;
    function GetItemPointer(avIndex: Integer): TItemPointer;

    procedure Grow(avMinCapacity: Integer);
    procedure Rearrange(avOldCapacity: Integer);

    procedure GrowInsert(avIndex: Integer; avItem: TItemPointer; avCount: Integer);

    // move data to a new array of avNewCapacity items
    procedure MakeCopy(avNewCapacity: Integer; avNewBaseIndex: Integer = 0);

    // concatenate two sections, <avIndex1> and <avIndex2> are both absolute index
    procedure Concat(avIndex1, avCount1, avIndex2, avCount2: Integer);

    // move <avCount> items that starts from absolute index <avFrom> to absolute index <avTo>
    procedure ShiftAbs(avFrom, avTo, avCount: Integer);

    // cleanup <avCount> items that starts from absolute index <avIndex>
    procedure Cleanup(avIndex, avCount: Integer);

    // change <avCount> items that starts from absolute index <avIndex> with external array avItem
    procedure StoreAbs(avIndex: Integer; avItem: TItemPointer; avCount: Integer);

    // copy <avCount> items that starts from absolute index <avIndex> to external array avItem
    procedure LoadAbs(avIndex: Integer; avItem: TItemPointer; avCount: Integer);

    // don't call below methods directly
    procedure SetCountManaged(const avNewCount: Integer);
    procedure SetCountPOD(const avNewCount: Integer);
  public
    procedure Clear;
    procedure Add(const v: T); overload;
    procedure Add(const varr: array of T); overload;
    procedure Add(avItem: TItemPointer; avCount: Integer); overload; inline;
    procedure Add(const arr: TdslArray<T>); overload; inline;
    procedure Delete(avIndex: Integer; avCount: Integer = 1);
    procedure Insert(avIndex: Integer; const v: T); overload; inline;
    procedure Insert(avIndex: Integer; const varr: array of T); overload;
    procedure Insert(avIndex: Integer; avItem: TItemPointer; avCount: Integer); overload;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property BaseIndex: Integer read GetBaseIndex write SetBaseIndex;
    property _[avIndex: Integer]: T read GetItemNoCheck write SetItemNoCheck;
    property Items[avIndex: Integer]: T read GetItem write SetItem; default;
    property ItemPointer[avIndex: Integer]: TItemPointer read GetItemPointer;
  end;

implementation

{ TdslCircularList<T> }

procedure TdslCircularList<T>.Add(const varr: array of T);
var
  n: Integer;
begin
  n := Length(varr);
  if n > 0 then
    Self.Insert(GetCount, TItemPointer(@varr[0]), n);
end;

procedure TdslCircularList<T>.Add(const v: T);
begin
  Self.Insert(GetCount, TItemPointer(@v), 1);
end;

procedure TdslCircularList<T>.Add(const arr: TdslArray<T>);
var
  n: Integer;
begin
  n := arr.Count;
  if n > 0 then
    Self.Insert(GetCount, TItemPointer(arr.ItemPointer[0]), n);
end;

procedure TdslCircularList<T>.Add(avItem: TItemPointer; avCount: Integer);
begin
  if avCount > 0 then
    Self.Insert(GetCount, avItem, avCount);
end;

procedure TdslCircularList<T>.Cleanup(avIndex, avCount: Integer);
var
  lvCapacity, lvLast: Integer;
begin
  lvCapacity := GetCapacity;
  avIndex := (avIndex + lvCapacity) mod lvCapacity;
  lvLast := (avIndex + avCount - 1) mod lvCapacity;
  if avIndex <= lvLast then
    TdslArrayUtils<T>.Cleanup(@tvItems[avIndex], @tvItems[lvLast+1])
  else begin
    TdslArrayUtils<T>.Cleanup(@tvItems[avIndex], @tvItems[lvCapacity]);
    TdslArrayUtils<T>.Cleanup(@tvItems[0], @tvItems[lvLast+1]);
  end;
end;

procedure TdslCircularList<T>.Clear;
begin
  SetLength(tvItems, 0);
  tvCount := 0;
  tvBaseIndex := 0;
end;

procedure TdslCircularList<T>.Concat(avIndex1, avCount1, avIndex2, avCount2: Integer);
var
  i, lvOffset, lvCapacity, lvLen1, lvLen2: Integer;
begin
  lvCapacity := Self.GetCapacity;

  if avCount2 < avCount1 then
  begin
    lvOffset := avIndex1 + avCount1;
    lvLen1 := lvCapacity - lvOffset;
    if lvLen1 > avCount2 then
      lvLen1 := avCount2;
    TdslArrayUtils<T>.BatchMove(@tvItems[avIndex2], @tvItems[lvOffset], lvLen1);
    TdslArrayUtils<T>.BatchMove(@tvItems[avIndex2 + lvLen1], @tvItems[0], avCount2 - lvLen1);
  end
  else begin
    lvLen1 := avIndex2;
    if lvLen1 > avCount1 then
      lvLen1 := avCount1;
    TdslArrayUtils<T>.BatchMove(@tvItems[avIndex1 + avCount1 - lvLen1], @tvItems[avIndex2 - lvLen1], lvLen1);
    lvLen2 := avCount1 - lvLen1;
    TdslArrayUtils<T>.BatchMove(@tvItems[avIndex1], @tvItems[lvCapacity - lvLen2], lvLen2);
    tvBaseIndex := (avIndex2 + lvCapacity - avCount1) mod lvCapacity;
  end;
end;

procedure TdslCircularList<T>.Delete(avIndex, avCount: Integer);
var
  lvOldCount, lvCapacity, lvLastIdx, lvIdx1, lvIdx2: Integer;
  i, lvLen1, lvLen2, lvLen3: Integer;
begin
  lvOldCount := GetCount;
  if (avIndex < 0) or (avIndex >= lvOldCount) then
  begin
    InvalidIndexError(avIndex);
    Exit;
  end;

  if avIndex + avCount > lvOldCount then
    avCount := lvOldCount - avIndex;

  if avCount <= 0 then Exit;

  lvCapacity := GetCapacity;
  lvLastIdx := (tvBaseIndex + tvCount - 1) mod lvCapacity;
  lvIdx1 := (tvBaseIndex + avIndex) mod lvCapacity;
  lvIdx2 := (lvIdx1 + avCount - 1) mod lvCapacity;

  if lvIdx1 <= lvIdx2 then
  begin
    if lvIdx1 >= tvBaseIndex then
    begin
      lvLen1 := lvIdx1 - tvBaseIndex;
      if lvLastIdx >= tvBaseIndex then
      begin
        // ...|1|2|X|X|X|6|7|8|9|10|...
        lvLen2 := lvLastIdx - lvIdx2;
        if lvLen1 < lvLen2 then
        begin
          TdslArrayUtils<T>.BatchMove(@tvItems[tvBaseIndex], @tvItems[lvIdx2+1-lvLen1], lvLen1);
          Inc(tvBaseIndex, avCount);
          TdslArrayUtils<T>.Cleanup(@tvItems[lvIdx1], @tvItems[tvBaseIndex]);
        end
        else
          TdslArrayUtils<T>.BatchMove(@tvItems[lvIdx2+1], @tvItems[lvIdx1], lvLen2);
      end
      else begin
        // |8|9|10|...|1|2|3|X|X|X|7|
        lvLen2 := lvCapacity - 1 - lvIdx2;
        lvLen3 := lvLastIdx + 1;
        if lvLen1 < lvLen2 + lvLen3 then
        begin
          TdslArrayUtils<T>.BatchMove(@tvItems[tvBaseIndex], @tvItems[lvIdx2+1-lvLen1], lvLen1);
          Inc(tvBaseIndex, avCount);
          TdslArrayUtils<T>.Cleanup(@tvItems[lvIdx1], @tvItems[tvBaseIndex]);
        end
        else begin
          TdslArrayUtils<T>.BatchMove(@tvItems[lvIdx2+1], @tvItems[lvIdx1], lvLen2);
          TdslArrayUtils<T>.Cleanup(@tvItems[lvIdx1+lvLen2], @tvItems[lvIdx2+1]);
          Self.Concat(tvBaseIndex, lvLen1 + lvLen2, 0, lvLen3);
        end;
      end;
    end
    else begin
      // |4|5|X|X|X|9|10|...|1|2|3|
      lvLen1 := lvCapacity - tvBaseIndex;
      lvLen2 := lvIdx1;
      lvLen3 := lvLastIdx - lvIdx2;
      if lvLen3 < lvLen1 + lvLen2 then
      begin
        TdslArrayUtils<T>.BatchMove(@tvItems[lvIdx2+1], @tvItems[lvIdx1], lvLen3);
        TdslArrayUtils<T>.Cleanup(@tvItems[lvIdx1+lvLen3], @tvItems[lvIdx2+1]);
      end
      else begin
        i := lvIdx2+1-lvLen2;
        TdslArrayUtils<T>.BatchMove(@tvItems[0], @tvItems[i], lvLen2);
        TdslArrayUtils<T>.Cleanup(@tvItems[lvIdx1], @tvItems[i]);
        Self.Concat(tvBaseIndex, lvLen1, i, lvLen2 + lvLen3);
      end;
    end;
  end
  else begin
    // |X|X||7|8|9|10|...|1|2|X|X|
    Self.Concat(tvBaseIndex, lvIdx1 - tvBaseIndex, lvIdx2 + 1, lvLastIdx - lvIdx2);
  end;
  Dec(tvCount, avCount);
end;

procedure TdslCircularList<T>.StoreAbs(avIndex: Integer; avItem: TItemPointer; avCount: Integer);
var
  lvCapacity, lvLast, lvLen1: Integer;
begin
  if avCount > 0 then
  begin
    lvCapacity := GetCapacity;
    avIndex := (avIndex + lvCapacity) mod lvCapacity;
    lvLast := (avIndex + avCount - 1) mod lvCapacity;
    if avIndex <= lvLast then
      TdslArrayUtils<T>.BatchCopy(avItem, @tvItems[avIndex], avCount)
    else begin
      lvLen1 := avCount - lvLast - 1;
      TdslArrayUtils<T>.BatchCopy(avItem, @tvItems[avIndex], lvLen1);
      TdslArrayUtils<T>.BatchCopy(avItem + lvLen1, @tvItems[0], lvLast + 1);
    end;
  end;
end;

function TdslCircularList<T>.GetBaseIndex: Integer;
begin
  if tvItems = nil then
  begin
    tvBaseIndex := 0;
    tvCount := 0;
  end;
  Result := tvBaseIndex;
end;

function TdslCircularList<T>.GetCapacity: Integer;
begin
  Result := Length(tvItems);
end;

function TdslCircularList<T>.GetCount: Integer;
begin
  if tvItems = nil then
  begin
    tvBaseIndex := 0;
    tvCount := 0;
  end;
  Result := tvCount;
end;

function TdslCircularList<T>.GetItem(avIndex: Integer): T;
begin
  if (avIndex >= 0) and (avIndex < GetCount) then
    Result := tvItems[(tvBaseIndex + avIndex) mod GetCapacity]
  else
    InvalidIndexError(avIndex);
end;

function TdslCircularList<T>.GetItemNoCheck(avIndex: Integer): T;
begin
  Result := tvItems[(tvBaseIndex + avIndex) mod GetCapacity];
end;

function TdslCircularList<T>.GetItemPointer(avIndex: Integer): TItemPointer;
begin
  Result := @tvItems[(tvBaseIndex + avIndex) mod GetCapacity];
end;

procedure TdslCircularList<T>.Grow(avMinCapacity: Integer);
var
  lvOldCapacity: Integer;
begin
  lvOldCapacity := GetCapacity;
  if avMinCapacity > lvOldCapacity then
  begin
    SetLength(tvItems, SuggestCapacity(avMinCapacity));
    Rearrange(lvOldCapacity);
  end;
end;

procedure TdslCircularList<T>.GrowInsert(avIndex: Integer; avItem: TItemPointer; avCount: Integer);
var
  lvNewData: array of T;
  lvNewCapacity: Integer;
begin
  lvNewCapacity := SuggestCapacity(tvCount + avCount);
  SetLength(lvNewData, lvNewCapacity);
  LoadAbs(tvBaseIndex, @lvNewData[0], avIndex);
  TdslArrayUtils<T>.BatchCopy(avItem, @lvNewData[avIndex], avCount);
  LoadAbs(tvBaseIndex + avIndex, @lvNewData[avIndex + avCount], tvCount - avIndex);

  tvBaseIndex := 0;
  Inc(tvCount, avCount);
  tvItems := nil;
  Pointer(tvItems) := Pointer(lvNewData);
  Pointer(lvNewData) := nil;
end;

procedure TdslCircularList<T>.Insert(avIndex: Integer; avItem: TItemPointer; avCount: Integer);
var
  lvOldCount, lvToIndex, lvOldCapacity: Integer;
begin
  lvOldCount := GetCount;
  if (avIndex >= 0) and (avIndex <= lvOldCount) then
  begin
    if avCount > 0 then
    begin
      lvOldCapacity := GetCapacity;

      if lvOldCount + avCount <= lvOldCapacity then
      begin
        if avIndex <= lvOldCount - avIndex then
        begin
          lvToIndex := (lvOldCapacity + tvBaseIndex - avCount) mod lvOldCapacity;
          Self.ShiftAbs(tvBaseIndex, lvToIndex, avIndex);
          tvBaseIndex := lvToIndex;
        end
        else begin
          lvToIndex := (tvBaseIndex + avIndex) mod lvOldCapacity;
          Self.ShiftAbs(lvToIndex, (lvToIndex + avCount) mod lvOldCapacity, lvOldCount - avIndex);
        end;
        Self.StoreAbs(tvBaseIndex + avIndex, avItem, avCount) ;
        Inc(tvCount, avCount);
      end
      else
        GrowInsert(avIndex, avItem, avCount);
    end;
  end
  else
    InvalidIndexError(avIndex);
end;

procedure TdslCircularList<T>.LoadAbs(avIndex: Integer; avItem: TItemPointer; avCount: Integer);
var
  lvCapacity, lvLast, lvLen1: Integer;
begin
  if avCount > 0 then
  begin
    lvCapacity := GetCapacity;
    avIndex := (avIndex + lvCapacity) mod lvCapacity;
    lvLast := (avIndex + avCount - 1) mod lvCapacity;
    if avIndex <= lvLast then
      TdslArrayUtils<T>.BatchCopy(@tvItems[avIndex], avItem, avCount)
    else begin
      lvLen1 := avCount - lvLast - 1;
      TdslArrayUtils<T>.BatchCopy(@tvItems[avIndex], avItem, lvLen1);
      TdslArrayUtils<T>.BatchCopy(@tvItems[0], avItem + lvLen1, lvLast + 1);
    end;
  end;
end;

procedure TdslCircularList<T>.Insert(avIndex: Integer; const varr: array of T);
var
  n: Integer;
begin
  n := Length(varr);
  if n > 0 then
    Self.Insert(avIndex, TItemPointer(@varr[0]), n);
end;

procedure TdslCircularList<T>.Insert(avIndex: Integer; const v: T);
begin
  Self.Insert(avIndex, TItemPointer(@v), 1);
end;

procedure TdslCircularList<T>.MakeCopy(avNewCapacity, avNewBaseIndex: Integer);
var
  lvNewItems: array of T;
  lvCapacity, lvFrom1, lvFrom2, lvTo1, lvTo2, lvSrcLen, lvDestLen, lvLen, n: Integer;
begin
  SetLength(lvNewItems, avNewCapacity);
  lvCapacity := GetCapacity;
  lvFrom1 := tvBaseIndex;
  lvFrom2 := (tvBaseIndex + tvCount - 1) mod lvCapacity;
  lvTo1 := avNewBaseIndex;
  lvTo2 := (avNewBaseIndex + tvCount - 1) mod avNewCapacity;
  n := tvCount;
  while n > 0 do
  begin
    if lvFrom1 <= lvFrom2 then
      lvSrcLen := lvFrom2 + 1 - lvFrom1
    else
      lvSrcLen := n - (lvFrom2 + 1);

    if lvTo1 <= lvTo2 then
      lvDestLen := lvTo2 + 1 - lvTo1
    else
      lvDestLen := n - (lvTo2 + 1);

    lvLen := Min(lvSrcLen, lvDestLen);
    TdslArrayUtils<T>.BatchCopy(@tvItems[lvFrom1], @lvNewItems[lvTo1], lvLen);

    lvFrom1 := (lvFrom1 + lvLen) mod lvCapacity;
    lvTo1 := (lvTo1 + lvLen) mod avNewCapacity;
    Dec(n, lvLen);
  end;

  tvItems := nil;
  Pointer(tvItems) := Pointer(lvNewItems);
  Pointer(lvNewItems) := nil;
  tvBaseIndex := avNewBaseIndex;
end;

procedure TdslCircularList<T>.Rearrange(avOldCapacity: Integer);
var
  lvCount1: Integer;
begin
  lvCount1 := avOldCapacity - tvBaseIndex;
  if lvCount1 < tvCount then
    Concat(tvBaseIndex, lvCount1, 0, tvCount - lvCount1);
end;

procedure TdslCircularList<T>.SetBaseIndex(avNewBaseIndex: Integer);
var
  lvCapacity, lvDistance, i: Integer;
  tmp: T;
begin
  lvCapacity := GetCapacity;
  if (avNewBaseIndex >= -lvCapacity) and (avNewBaseIndex < lvCapacity) then
  begin
    avNewBaseIndex := (avNewBaseIndex + lvCapacity) mod lvCapacity;
    if avNewBaseIndex <> GetBaseIndex then
    begin
      lvDistance := Min(
        (avNewBaseIndex + lvCapacity - tvBaseIndex) mod lvCapacity,
        (tvBaseIndex + lvCapacity - avNewBaseIndex) mod lvCapacity
        );

      if lvDistance <= lvCapacity - tvCount then
      begin
        ShiftAbs(tvBaseIndex, avNewBaseIndex, tvCount);
        if (tvBaseIndex + lvCapacity - avNewBaseIndex) mod lvCapacity = lvDistance then
          Self.Cleanup(tvBaseIndex + tvCount - lvDistance, Min(lvDistance, tvCount))
        else
          Self.Cleanup(tvBaseIndex, Min(lvDistance, tvCount));

        tvBaseIndex := avNewBaseIndex;
      end
      else
        MakeCopy(SuggestCapacity(lvCapacity + 1), avNewBaseIndex);
    end;
  end;
end;

procedure TdslCircularList<T>.SetCapacity(const avNewCapacity: Integer);
var
  lvCount, lvOldCapacity: Integer;
begin
  lvCount := GetCount;
  lvOldCapacity := GetCapacity;
  if avNewCapacity > lvOldCapacity then
  begin
    SetLength(tvItems, avNewCapacity);
    ReArrange(lvOldCapacity);
  end
  else if (avNewCapacity < lvOldCapacity) and (avNewCapacity >= lvCount) then
  begin
    if tvBaseIndex + lvCount <= avNewCapacity then
      SetLength(tvItems, avNewCapacity)
    else
      MakeCopy(avNewCapacity);
  end;
end;

procedure TdslCircularList<T>.SetCount(const avNewCount: Integer);
begin
  if TdslTypeInfo<T>.IsManagedType then
    Self.SetCountManaged(avNewCount)
  else
    Self.SetCountPOD(avNewCount);
end;

procedure TdslCircularList<T>.SetCountManaged(const avNewCount: Integer);
var
  lvOldCount, lvCapacity, i: Integer;
begin
  if avNewCount >= 0 then
  begin
    lvOldCount := GetCount;
    if avNewCount > lvOldCount then
      Self.Grow(avNewCount)
    else begin
      lvCapacity := GetCapacity;
      for i := avNewCount to lvOldCount - 1 do
        Finalize(tvItems[(tvBaseIndex + i) mod lvCapacity]);
    end;
    tvCount := avNewCount;
  end;
end;

procedure TdslCircularList<T>.SetCountPOD(const avNewCount: Integer);
begin
  if avNewCount >= 0 then
  begin
    if avNewCount > GetCount then
      Self.Grow(avNewCount);
    tvCount := avNewCount;
  end;
end;

procedure TdslCircularList<T>.SetItem(avIndex: Integer; const avValue: T);
begin
  if (avIndex >= 0) and (avIndex < GetCount) then
    tvItems[(tvBaseIndex + avIndex) mod GetCapacity] := avValue
  else
    InvalidIndexError(avIndex);
end;

procedure TdslCircularList<T>.SetItemNoCheck(avIndex: Integer; const avValue: T);
begin
  tvItems[(tvBaseIndex + avIndex) mod GetCapacity] := avValue
end;

procedure TdslCircularList<T>.ShiftAbs(avFrom, avTo, avCount: Integer);
var
  lvFrom2, lvTo2, lvLen1, lvLen2, lvCapacity: Integer;
begin
  if (avCount <= 0) then Exit;
  lvCapacity := GetCapacity;
  avFrom := (avFrom + lvCapacity) mod lvCapacity;
  avTo := (avTo + lvCapacity) mod lvCapacity;
  if (avFrom = avTo) then Exit;
  lvFrom2 := (avFrom + avCount - 1) mod lvCapacity;
  lvTo2 := (avTo + avCount - 1) mod lvCapacity;

  if avFrom <= lvFrom2 then
  begin
    if avTo <= lvTo2 then
    begin
      // ...||||1|2|3|||||||... => ...||||||1|2|3|||||...
      // or ...||||1|2|3|||||||... => ...||1|2|3|||||||||...
      TdslArrayUtils<T>.BatchCopy(@tvItems[avFrom], @tvItems[avTo], avCount);
    end
    else begin
      lvLen1 := avCount - lvTo2 - 1;
      if avFrom + lvLen1 >= avTo then
      begin
        // ||||||||||1|2|3| =>  |3||||||||||1|2|
        TdslArrayUtils<T>.BatchCopy(@tvItems[avFrom + lvLen1], @tvItems[0], lvTo2 + 1);
        TdslArrayUtils<T>.BatchCopy(@tvItems[avFrom], @tvItems[avTo], lvLen1);
      end
      else begin
        // |1|2|3|||||||||| =>  |3||||||||||1|2|
        TdslArrayUtils<T>.BatchCopy(@tvItems[avFrom], @tvItems[avTo], lvLen1);
        TdslArrayUtils<T>.BatchCopy(@tvItems[avFrom + lvLen1], @tvItems[0], lvTo2 + 1);
      end;
    end;
  end
  else begin
    if avTo <= lvTo2 then
    begin
      lvLen1 := avCount - lvFrom2 - 1;
      if lvFrom2 >= avTo then
      begin
        // |3|4|||||||||1|2| => |1|2|3|4|||||||||
        TdslArrayUtils<T>.BatchCopy(@tvItems[0], @tvItems[avTo+lvLen1], lvFrom2 + 1);
        TdslArrayUtils<T>.BatchCopy(@tvItems[avFrom], @tvItems[avTo], lvLen1);
      end
      else begin
        // |3||||||||||1|2| => ||||1|2|3|||||||
        // or |3||||||||||1|2| => ||||||||||1|2|3|
        TdslArrayUtils<T>.BatchCopy(@tvItems[avFrom], @tvItems[avTo], lvLen1);
        TdslArrayUtils<T>.BatchCopy(@tvItems[0], @tvItems[avTo+lvLen1], lvFrom2 + 1);
      end;
    end
    else if avFrom < avTo then
    begin
      // |4|||||||||1|2|3| => |3|4|||||||||1|2|
      lvLen1 := avCount - lvTo2 - 1;
      // must keep order, to avoid overwriting source items before copying
      ShiftAbs((avFrom + lvLen1) mod lvCapacity, 0, lvTo2 + 1);
      ShiftAbs(avFrom, avTo, lvLen1);
    end
    else begin
      // |3|4|||||||||1|2| => |4|||||||||1|2|3|
      lvLen1 := avCount - lvTo2 - 1;
      // must keep order, to avoid overwriting source items before copying
      ShiftAbs(avFrom, avTo, lvLen1);
      ShiftAbs((avFrom + lvLen1) mod lvCapacity, 0, lvTo2 + 1);
    end;
  end;
end;

end.
