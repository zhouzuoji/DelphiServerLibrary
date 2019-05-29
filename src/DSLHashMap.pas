unit DSLHashMap;

interface

uses
  SysUtils, Classes, RTLConsts, AnsiStrings, Generics.Collections, Generics.Defaults, DSLArray;

type
  TCollectionSize = UInt32;
  THashIndex = UInt32;

const
  INVALID_HASH_INDEX = THashIndex(-1);

type
  TdslHashMap<TKey, TValue> = class
  public
    type
      TValuePointer = ^TValue;
      TSentinelBucket = packed record
        prior: THashIndex;
        next: THashIndex;
      end;

      PBucket = ^TBucket;
      TBucket = packed record
        prior: THashIndex;
        next: THashIndex;
        hash: THashIndex;
        data: TPair<TKey, TValue>;
        function IsEmpty: Boolean; inline;
        procedure SetEmpty; inline;
      end;

    TEnumerator = record
    private
      tvCollection: TdslHashMap<TKey, TValue>;
      tvCurrent: PBucket;
      function DoGetCurrent: TPair<TKey, TValue>;
    public
      property Current: TPair<TKey, TValue> read DoGetCurrent;
      function MoveNext: Boolean;
    end;
  private
    tvComparer: IEqualityComparer<TKey>;
    tvCollision: TCollectionSize;
    tvCapacity, tvCount: TCollectionSize;
    tvBuckets: array of TBucket;
    procedure SetItem(const avKey: TKey; const avValue: TValue);
    function GetItem(const key: TKey): TValue;
    function GetItemPointer(const key: TKey): TValuePointer;
    procedure SetCapacity(const avNewCapacity: TCollectionSize);


    function GetEmptySentinal: THashIndex; inline;
    function GetUsedSentinal: THashIndex; inline;
    procedure ExtractBucket(avIndex: THashIndex); inline;
    function GetBucket(avIndex: THashIndex): PBucket; inline;
    procedure LinkBefore(avIndex, avNext: THashIndex); inline;
    procedure MoveBucket(avSrc, avDest: THashIndex); inline;
    procedure AddCollision(avCollision: Integer); inline;
    procedure DecCollision(avCollision: Integer); inline;
    procedure SetAllBucketsEmpty;
    function GetEmptyBucket: THashIndex; inline;
    procedure SetBucketEmpty(avIndex: THashIndex); inline;

    procedure Grow; inline;
    procedure InitTable(ACapacity: TCollectionSize);
    procedure Cleanup;
    function IndexOf(const avKey: TKey; avHash: THashIndex): THashIndex; overload;
    function IndexOf(const avKey: TKey): THashIndex; overload; inline;
    function HashOfKey(const key: TKey): TCollectionSize; inline;
    function InsertCollision(const avKey: TKey; avHash: THashIndex): TValuePointer; inline;
    function DoInsert(const avKey: TKey; avHash: THashIndex; avReplace: Boolean = True): TValuePointer;


    // remove an item at the avIndex_th bucket
    function DeleteBucket(avIndex: THashIndex): THashIndex;
  public
    constructor Create(ACapacity: TCollectionSize; AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    procedure Clear;
    function Remove(const avKey: TKey): Boolean;
    function Insert(const avKey: TKey; avReplace: Boolean = True): TValuePointer; inline;
    procedure Add(const avKey: TKey; const avValue: TValue);
    function TryGetValue(const avKey: TKey; out avValue: TValue): Boolean;
    function ContainsKey(const avKey: TKey): Boolean;
    procedure AddOrSetValue(const avKey: TKey; const avValue: TValue);
    procedure Assign(const avSrc: TdslHashMap<TKey, TValue>);
    function GetEnumerator: TEnumerator;
  public
    property Capacity: TCollectionSize read tvCapacity write SetCapacity;
    property Collision: TCollectionSize read tvCollision;
    property Count: TCollectionSize read tvCount;
    property Items[const avKey: TKey]: TValue read GetItem write SetItem; default;
    property ItemPointer[const avKey: TKey]: TValuePointer read GetItemPointer;
  end;

function suitableHashTableSize(avElementCount: TCollectionSize): TCollectionSize;

implementation

const
  PRIME_TABLE: array [0 .. 27] of TCollectionSize = (
    17, 37, 79, 163, 331, 673, 1361, 2729, 5471, 10949, 21911, 43853, 87719, 175447,
    350899, 701819, 1403641, 2807303, 5614657, 11229331, 22458671, 44917381,
    89834777, 179669557, 359339171, 718678369, 1437356741, 2147483647);

function suitableHashTableSize(avElementCount: TCollectionSize): TCollectionSize;
var
  i: Integer;
  cnt: TCollectionSize;
begin
  cnt := (avElementCount * 3) div 2;
  for i := Low(PRIME_TABLE) to High(PRIME_TABLE) do
  begin
    if PRIME_TABLE[i] >= cnt then
    begin
      cnt := PRIME_TABLE[i];
      Break;
    end;
  end;
  Result := cnt;
end;

{ TdslHashMap<TKey, TValue> }

function TdslHashMap<TKey, TValue>.HashOfKey(const key: TKey): TCollectionSize;
begin
  Result := TCollectionSize(tvComparer.GetHashCode(key));
end;

function TdslHashMap<TKey, TValue>.GetUsedSentinal: THashIndex;
begin
  Result := tvCapacity + 1;
end;

procedure TdslHashMap<TKey, TValue>.Cleanup;
begin
  SetLength(tvBuckets, 0);
  tvCollision := 0;
  tvCount := 0;
end;

procedure TdslHashMap<TKey, TValue>.Clear;
var
  lvCurrent, tmp: THashIndex;
  lvBucket: PBucket;
begin
  lvCurrent := GetBucket(GetUsedSentinal).next;
  if tvCount * 2 < tvCapacity then
  begin
    while lvCurrent <> GetUsedSentinal do
    begin
      tmp := lvCurrent;
      lvCurrent := GetBucket(lvCurrent).next;
      SetBucketEmpty(tmp);
    end;
    GetBucket(GetUsedSentinal).prior := GetUsedSentinal;
    GetBucket(GetUsedSentinal).next := GetUsedSentinal;
  end
  else begin
    while lvCurrent <> GetUsedSentinal do
    begin
      lvBucket := GetBucket(lvCurrent);
      lvCurrent := lvBucket.next;
      System.Finalize(lvBucket^);
    end;
    SetAllBucketsEmpty;
  end;
end;

procedure TdslHashMap<TKey, TValue>.Add(const avKey: TKey; const avValue: TValue);
var
  p: TValuePointer;
begin
  p := Self.Insert(avKey, False);
  if Assigned(p) then
    p^ := avValue
  else
    raise EListError.CreateRes(@SGenericDuplicateItem);
end;

function TdslHashMap<TKey, TValue>.ContainsKey(const avKey: TKey): Boolean;
begin
  Result := IndexOf(avKey) <> INVALID_HASH_INDEX;
end;

procedure TdslHashMap<TKey, TValue>.AddCollision(avCollision: Integer);
begin

end;

procedure TdslHashMap<TKey, TValue>.AddOrSetValue(const avKey: TKey; const avValue: TValue);
var
  p: TValuePointer;
begin
  p := Self.Insert(avKey, True);
  p^ := avValue;
end;

procedure TdslHashMap<TKey, TValue>.Assign(const avSrc: TdslHashMap<TKey, TValue>);
var
  lvCurrent: THashIndex;
  lvBucket: PBucket;
begin
  Self.Clear;
  lvCurrent := avSrc.GetBucket(avSrc.GetUsedSentinal).next;
  while lvCurrent <> avSrc.GetUsedSentinal do
  begin
    lvBucket := avSrc.GetBucket(lvCurrent);
    Self.DoInsert(lvBucket.data.key, lvBucket.hash, True)^ := lvBucket.data.value;
    lvCurrent := lvBucket.next;
  end;
end;

constructor TdslHashMap<TKey, TValue>.Create(ACapacity: TCollectionSize; AComparer: IEqualityComparer<TKey>);
begin
  tvComparer := AComparer;

  if tvComparer = nil then
    tvComparer := TEqualityComparer<TKey>.Default;

  Self.InitTable(suitableHashTableSize(ACapacity));
end;

procedure TdslHashMap<TKey, TValue>.DecCollision(avCollision: Integer);
begin

end;

function TdslHashMap<TKey, TValue>.Remove(const avKey: TKey): Boolean;
var
  lvIndex: THashIndex;
begin
  lvIndex := IndexOf(avKey);
  if lvIndex <> INVALID_HASH_INDEX then
  begin
    DeleteBucket(lvIndex);
    Result := True;
  end
  else
    Result := False;
end;

function TdslHashMap<TKey, TValue>.DeleteBucket(avIndex: THashIndex): THashIndex;
var
  lvPrior, lvNext: THashIndex;
  lvBucket, lvPriorBucket, lvNextBucket: PBucket;
begin
  lvBucket := GetBucket(avIndex);
  lvPrior := lvBucket.prior;
  lvNext := lvBucket.next;
  lvPriorBucket := GetBucket(lvPrior);
  lvNextBucket := GetBucket(lvNext);
  if (lvPriorBucket.hash mod Self.Capacity <> avIndex)
    and (lvNextBucket.hash mod Self.Capacity = avIndex) then
  begin
    (* there are more than one items whose hash is equal to
      the item to be deleted£¬ and it's the first in the
      link-list. in this case, we move the next item to
      the deleted slot
    *)
    lvBucket.data := lvNextBucket.data;
    lvBucket.hash := lvNextBucket.hash;
    lvBucket.next := lvNextBucket.next;
    GetBucket(lvBucket.next).prior := avIndex;
    SetBucketEmpty(lvNext);
    Result := avIndex;
  end
  else begin
    lvPriorBucket.next := lvNext;
    lvNextBucket.prior := lvPrior;
    SetBucketEmpty(avIndex);
    Result := lvNext;
  end;

  Dec(tvCount);
end;

destructor TdslHashMap<TKey, TValue>.Destroy;
begin
  Cleanup;
  inherited;
end;

function TdslHashMap<TKey, TValue>.DoInsert(const avKey: TKey; avHash: THashIndex; avReplace: Boolean): TValuePointer;
var
  lvIndex, lvPrior, lvNext: THashIndex;
  lvBucket, newSlot: PBucket;
begin
  Result := nil;
  lvIndex := IndexOf(avKey, avHash);
  if lvIndex <> INVALID_HASH_INDEX then
  begin
    if avReplace then
      Result := @GetBucket(lvIndex).data.value;
  end
  else begin
    if Self.Count >= Self.Capacity then
      Self.Grow;
    lvIndex := avHash mod Self.Capacity;
    lvBucket := GetBucket(lvIndex);

    if lvBucket.hash = INVALID_HASH_INDEX then
    begin
      ExtractBucket(lvIndex);
      lvBucket.hash := avHash;
      lvBucket.data.key := avKey;
      LinkBefore(lvIndex, GetUsedSentinal);
      Result := @lvBucket.data.value;
    end
    else
      Result := InsertCollision(avKey, avHash);

    Inc(tvCount);
  end;
end;

function TdslHashMap<TKey, TValue>.IndexOf(const avKey: TKey): THashIndex;
begin
  Result := IndexOf(avKey, HashOfKey(avKey));
end;

function TdslHashMap<TKey, TValue>.GetBucket(avIndex: THashIndex): PBucket;
begin
  Result := @tvBuckets[avIndex];
end;

procedure TdslHashMap<TKey, TValue>.ExtractBucket(avIndex: THashIndex);
var
  lvPrior, lvNext: THashIndex;
begin
  lvPrior := GetBucket(avIndex).prior;
  lvNext := GetBucket(avIndex).next;
  GetBucket(lvPrior).next := lvNext;
  GetBucket(lvNext).prior := lvPrior;
end;

function TdslHashMap<TKey, TValue>.Insert(const avKey: TKey; avReplace: Boolean): TValuePointer;
begin
  Result := DoInsert(avKey, HashOfKey(avKey), avReplace);
end;

function TdslHashMap<TKey, TValue>.InsertCollision(const avKey: TKey; avHash: TCollectionSize): TValuePointer;
var
  lvIndex, lvAlternateIndex: THashIndex;
  lvBest, lvAlternate: PBucket;
begin
  lvIndex := avHash mod Self.Capacity;
  lvAlternateIndex := GetEmptyBucket;
  lvAlternate := GetBucket(lvAlternateIndex);
  lvBest := GetBucket(lvIndex);
  if lvBest.hash mod Self.Capacity = lvIndex then
  begin
    Inc(tvCollision);

    lvAlternate.hash := avHash;
    lvAlternate.data.key := avKey;

    lvAlternate.next := lvBest.next;
    lvAlternate.prior := lvIndex;

    GetBucket(lvAlternate.next).prior := lvAlternateIndex;
    lvBest.next := lvAlternateIndex;
    Result := @lvAlternate.data.value;
  end
  else begin
    MoveBucket(lvIndex, lvAlternateIndex);
    GetBucket(lvAlternate.prior).next := lvAlternateIndex;
    GetBucket(lvAlternate.next).prior := lvAlternateIndex;

    lvBest.data.key := avKey;
    lvBest.hash := avHash;
    LinkBefore(lvIndex, GetUsedSentinal);
    Result := @lvBest.data.value;
  end;
end;

procedure TdslHashMap<TKey, TValue>.LinkBefore(avIndex, avNext: THashIndex);
var
  lvPrior: THashIndex;
begin
  lvPrior := GetBucket(avNext).prior;
  GetBucket(lvPrior).next := avIndex;
  GetBucket(avIndex).prior := lvPrior;
  GetBucket(avNext).prior := avIndex;
  GetBucket(avIndex).next := avNext;
end;

procedure TdslHashMap<TKey, TValue>.MoveBucket(avSrc, avDest: THashIndex);
begin
  tvBuckets[avDest] := tvBuckets[avSrc];
  System.Finalize(tvBuckets[avSrc]);
end;

procedure TdslHashMap<TKey, TValue>.SetCapacity(const avNewCapacity: TCollectionSize);
var
  newTable: TdslHashMap<TKey, TValue>;
  lvActualCap: THashIndex;
begin
  lvActualCap := suitableHashTableSize(avNewCapacity);
  if (lvActualCap <> Self.Capacity) and (lvActualCap >= Self.Count) then
  begin
    newTable := TdslHashMap<TKey, TValue>.Create(avNewCapacity, tvComparer);
    newTable.Assign(Self);
    Self.Cleanup;
    tvBuckets := newTable.tvBuckets;
    tvCount := newTable.tvCount;
    tvCollision := newTable.tvCollision;
    tvCapacity := newTable.tvCapacity;
    newTable.tvBuckets := nil;
    newTable.tvCount := 0;
    newTable.tvCapacity := 0;
    newTable.tvCollision := 0;
    newTable.Free;
  end;
end;

procedure TdslHashMap<TKey, TValue>.SetItem(const avKey: TKey; const avValue: TValue);
var
  lvIndex: THashIndex;
begin
  lvIndex := IndexOf(avKey);
  if lvIndex <> INVALID_HASH_INDEX then
    GetBucket(lvIndex).data.value := avValue
  else
    raise EListError.CreateRes(@SGenericItemNotFound);
end;

procedure TdslHashMap<TKey, TValue>.SetBucketEmpty(avIndex: THashIndex);
begin
  System.Finalize(GetBucket(avIndex)^);
  GetBucket(avIndex)^.hash := INVALID_HASH_INDEX;
  LinkBefore(avIndex, GetEmptySentinal);
end;

function TdslHashMap<TKey, TValue>.TryGetValue(const avKey: TKey; out avValue: TValue): Boolean;
var
  lvIndex: THashIndex;
begin
  lvIndex := IndexOf(avKey);
  if lvIndex <> INVALID_HASH_INDEX then
  begin
    avValue := GetBucket(lvIndex).data.value;
    Result := True;
  end
  else
    Result := False;
end;

procedure TdslHashMap<TKey, TValue>.Grow;
begin
  SetCapacity(Self.Capacity);
end;

function TdslHashMap<TKey, TValue>.GetEmptySentinal: THashIndex;
begin
  Result := tvCapacity;
end;

function TdslHashMap<TKey, TValue>.GetEmptyBucket: THashIndex;
begin
  Result := GetBucket(GetEmptySentinal).next;
  GetBucket(GetEmptySentinal).next := GetBucket(Result).next;
  GetBucket(GetBucket(Result).next).prior := GetEmptySentinal;
end;

function TdslHashMap<TKey, TValue>.GetEnumerator: TEnumerator;
begin
  Result.tvCollection := Self;
  Result.tvCurrent := GetBucket(GetUsedSentinal);
end;

function TdslHashMap<TKey, TValue>.GetItem(const key: TKey): TValue;
var
  lvIndex: THashIndex;
begin
  lvIndex := IndexOf(key);

  if lvIndex = INVALID_HASH_INDEX then
    Result := Default(TValue)
  else
    Result := GetBucket(lvIndex).data.value;
end;

function TdslHashMap<TKey, TValue>.GetItemPointer(const key: TKey): TValuePointer;
var
  lvIndex: THashIndex;
begin
  lvIndex := IndexOf(key);

  if lvIndex <> INVALID_HASH_INDEX then
    Result := @GetBucket(lvIndex).data.value
  else
    Result := nil;
end;

function TdslHashMap<TKey, TValue>.IndexOf(const avKey: TKey; avHash: THashIndex): THashIndex;
var
  lvCurrent, lvBest: THashIndex;
  i: Integer;
  lvBucket: PBucket;
begin
  Result := INVALID_HASH_INDEX;
  lvBest := avHash mod Self.Capacity;
  lvCurrent := lvBest;
  lvBucket := GetBucket(lvCurrent);
  while True do
  begin
    if (avHash = lvBucket.hash) and tvComparer.Equals(avKey, lvBucket.data.key) then
    begin
      Result := lvCurrent;
      Break;
    end;

    if lvBucket.hash mod Self.Capacity <> lvBest then Break;

    lvCurrent := lvBucket.next;
    lvBucket := GetBucket(lvCurrent);
  end;
end;

procedure TdslHashMap<TKey, TValue>.InitTable(ACapacity: TCollectionSize);
begin
  tvCapacity := ACapacity;
  SetLength(tvBuckets, tvCapacity + 2);
  SetAllBucketsEmpty;
end;

procedure TdslHashMap<TKey, TValue>.SetAllBucketsEmpty;
var
  i: Integer;
begin
  if tvCapacity > 0 then
  begin
    tvCount := 0;
    tvCollision := 0;
    tvBuckets[GetEmptySentinal].SetEmpty;
    tvBuckets[GetEmptySentinal].next := 0;
    tvBuckets[0].prior := GetEmptySentinal;
    for i := 0 to tvCapacity - 2 do
    begin
      tvBuckets[i].SetEmpty;
      tvBuckets[i + 1].prior := i;
      tvBuckets[i].next := i + 1;
    end;
    tvBuckets[GetEmptySentinal].prior := tvCapacity - 1;
    tvBuckets[tvCapacity-1].next := GetEmptySentinal;

    tvBuckets[GetUsedSentinal].SetEmpty;
    tvBuckets[GetUsedSentinal].prior := GetUsedSentinal;
    tvBuckets[GetUsedSentinal].next := GetUsedSentinal;
  end;
end;

{ TdslHashMap<TKey, TValue>.TBucket }

function TdslHashMap<TKey, TValue>.TBucket.IsEmpty: Boolean;
begin
  Result := False;
end;

procedure TdslHashMap<TKey, TValue>.TBucket.SetEmpty;
begin
  hash := INVALID_HASH_INDEX;
end;

{ TdslHashMap<TKey, TValue>.TEnumerator }

function TdslHashMap<TKey, TValue>.TEnumerator.DoGetCurrent: TPair<TKey, TValue>;
begin
  Result := tvCurrent.data;
end;

function TdslHashMap<TKey, TValue>.TEnumerator.MoveNext: Boolean;
begin
  tvCurrent := tvCollection.GetBucket(tvCurrent.next);
  Result := tvCurrent.hash <> INVALID_HASH_INDEX;
end;

end.
