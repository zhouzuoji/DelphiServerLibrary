unit DSLHashTable;

interface

uses
  SysUtils, Classes, Windows, SyncObjs, Generics.Collections, Generics.Defaults, DSLUtils;

type
  THashSlotFlag = (hsfUsage);
  THashSlotFlags = set of THashSlotFlag;

  THashTable<TKey, TValue> = class
  public
    type
      TValuePointer = ^TValue;
      PHashSlot = ^THashSlot;
      THashSlot = packed record
        prior: PHashSlot;
        next: PHashSlot;
        flags: THashSlotFlags;
        hash: LongWord;
        key: TKey;
        value: TValue;
      end;

      TIterator = record
      private
        FTable: THashTable<TKey, TValue>;
        FSlot: PHashSlot;
        function getKey: TKey; inline;
        function getValue: TValue; inline;
        procedure setValue(const AValue: TValue); inline;
        function getValuePointer: Pointer;
      public
        procedure setTable(ATable: THashTable<TKey, TValue>);
        function next(step: Integer = 1): Integer;
        function prior(step: Integer = 1): Integer;
        function eof: Boolean;
        procedure erase;
        property key: TKey read getKey;
        property value: TValue read getValue write setValue;
        property valuePointer: Pointer read getValuePointer;
      end;
  private
    FLocker: TSynchroObject;
    FComparer: IEqualityComparer<TKey>;
    FConflict: TSizeType;
    FCount: TSizeType;
    FItems: array of THashSlot;
    FFirstEmpty: PHashSlot;
    FFirstUsage: PHashSlot;
    FLastUsage: PHashSlot;
    procedure setItem(const key: TKey; const value: TValue);
    function getItem(const key: TKey): TValue;
    procedure setCapacity(const value: TSizeType);
    procedure InitTable(ACapacity: TSizeType);
    procedure cleanupTable;
    procedure initMemory;
    function getEmptySlot: PHashSlot; inline;
    procedure setSlotEmpty(slot: PHashSlot); inline;
    procedure extractEmptySlot(slot: PHashSlot); inline;
    function findSlot(const key: TKey): PHashSlot;
    procedure grow;
    function getCapacity: TSizeType; inline;
    function getKeyIndex(const key: TKey): TSizeType; inline;
    function insertConflict(const key: TKey; hash: TSizeType; slot: PHashSlot): TValuePointer; inline;
    function getItemPointer(const key: TKey): TValuePointer;
    function deleteSlot(_slot: Pointer): Pointer;
  public
    constructor Create(ACapacity: TSizeType; AComparer: IEqualityComparer<TKey>; ALocker: TSynchroObject = nil);
    destructor Destroy; override;
    procedure lock; inline;
    procedure unlock; inline;
    function find(const key: TKey; var value: TValue): Boolean;
    function exists(const key: TKey): Boolean;
    function delete(const key: TKey): Boolean;
    function insert(const key: TKey; const value: TValue; replace: Boolean = True): Boolean; overload;
    function insert(const key: TKey; replace: Boolean = True): TValuePointer; overload;
    procedure clear;
    procedure assign(const Src: THashTable<TKey, TValue>);
    property capacity: TSizeType read getCapacity write setCapacity;
    property conflict: TSizeType read FConflict;
    property FirstUsage: PHashSlot read FFirstUsage;
    property LastUsage: PHashSlot read FLastUsage;
    property count: TSizeType read FCount;
    property Items[const key: TKey]: TValue read getItem write setItem; default;
    property ItemPointer[const key: TKey]: TValuePointer read getItemPointer;
  end;

function RSHash(buf: PAnsiChar; len: TSizeType): TSizeType;
function JSHash(buf: PAnsiChar; len: TSizeType): TSizeType;
function PJWHash(buf: PAnsiChar; len: TSizeType): TSizeType;
function ELFHash(buf: PAnsiChar; len: TSizeType): TSizeType;
function BKDRHash(buf: PAnsiChar; len: TSizeType): TSizeType;
function SDBMHash(buf: PAnsiChar; len: TSizeType): TSizeType;
function DJBHash(buf: PAnsiChar; len: TSizeType): TSizeType;
function APHash(buf: PAnsiChar; len: TSizeType): TSizeType;

function suitableHashTableSize(ElementCount: TSizeType): TSizeType;

implementation

const
  PRIME_TABLE: array [0 .. 27] of TSizeType = (17, 37, 79, 163, 331, 673, 1361, 2729, 5471, 10949, 21911, 43853, 87719,
    175447, 350899, 701819, 1403641, 2807303, 5614657, 11229331, 22458671, 44917381, 89834777, 179669557, 359339171,
    718678369, 1437356741, 2147483647);

function suitableHashTableSize(ElementCount: TSizeType): TSizeType;
var
  i: Integer;
  cnt: TSizeType;
begin
  cnt := (ElementCount * 3) div 2;
  for i := 0 to Length(PRIME_TABLE) - 1 do
  begin
    if PRIME_TABLE[i] > cnt then
    begin
      cnt := PRIME_TABLE[i];
      Break;
    end;
  end;
  Result := cnt;
end;

function RSHash(buf: PAnsiChar; len: TSizeType): TSizeType;
var
  a, b, hash: TSizeType;
  i: TSizeType;
begin
  b := 378551;
  a := 63689;
  hash := 0;
  for i := 0 to len - 1 do
  begin
    hash := hash * a + Byte(buf[i]);
    a := a * b;
  end;
  Result := hash and $7FFFFFFF;
end;

function JSHash(buf: PAnsiChar; len: TSizeType): TSizeType;
var
  hash: TSizeType;
  i: TSizeType;
begin
  hash := 1315423911;
  for i := 0 to len - 1 do
    hash := hash xor ((hash shl 5) + Byte(buf[i]) + (hash shr 2));
  Result := hash and $7FFFFFFF;
end;

function PJWHash(buf: PAnsiChar; len: TSizeType): TSizeType;
const
  BitsInUnignedInt = SizeOf(TSizeType) * 8;
  ThreeQuarters = (BitsInUnignedInt * 3) div 4;
  OneEighth = BitsInUnignedInt div 8;
  HighBits = $FFFFFFFF shl (BitsInUnignedInt - OneEighth);
var
  hash, flag: TSizeType;
  i: TSizeType;
begin
  hash := 0;
  for i := 0 to len - 1 do
  begin
    hash := (hash shl OneEighth) + Byte(buf[i]);
    flag := hash and HighBits;
    if (flag <> 0) then
      hash := ((hash xor (flag shr ThreeQuarters)) and (not HighBits));
  end;
  Result := hash and $7FFFFFFF;
end;

function ELFHash(buf: PAnsiChar; len: TSizeType): TSizeType;
var
  hash, x: TSizeType;
  i: TSizeType;
begin
  hash := 0;
  for i := 0 to len - 1 do
  begin
    hash := (hash shl 4) + Byte(buf[i]);
    x := hash and $F0000000;
    if x <> 0 then
    begin
      hash := hash xor (x shr 24);
      hash := hash and not x;
    end;
  end;
  Result := hash and $7FFFFFFF;
end;

function BKDRHash(buf: PAnsiChar; len: TSizeType): TSizeType;
var
  hash, seed: TSizeType;
  i: TSizeType;
begin
  seed := 131; // 31 131 1313 13131 131313 etc..
  hash := 0;
  for i := 0 to len - 1 do
    hash := hash * seed + Byte(buf[i]);
  Result := hash and $7FFFFFFF;
end;

function SDBMHash(buf: PAnsiChar; len: TSizeType): TSizeType;
var
  hash: TSizeType;
  i: TSizeType;
begin
  hash := 0;
  for i := 0 to len - 1 do
    hash := Byte(buf[i]) + (hash shl 6) + (hash shl 16) - hash;
  Result := hash and $7FFFFFFF;
end;

function DJBHash(buf: PAnsiChar; len: TSizeType): TSizeType;
var
  hash: TSizeType;
  i: TSizeType;
begin
  hash := 5381;
  for i := 0 to len - 1 do
    hash := hash + (hash shl 5) + Byte(buf[i]);
  Result := hash and $7FFFFFFF;
end;

function APHash(buf: PAnsiChar; len: TSizeType): TSizeType;
var
  hash: TSizeType;
  i: TSizeType;
begin
  hash := 0;
  for i := 0 to len - 1 do
  begin
    if ((i and 1) = 0) then
      hash := hash xor ((hash shl 7) xor Byte(buf[i]) xor (hash shr 3))
    else
      hash := hash xor (not((hash shl 11) xor Byte(buf[i]) xor (hash shr 5)));
  end;
  Result := hash and $7FFFFFFF;
end;

{ THashTable<TKey, TValue> }

function THashTable<TKey, TValue>.getKeyIndex(const key: TKey): TSizeType;
begin
  Result := TSizeType(FComparer.GetHashCode(key)) mod Self.capacity
end;

procedure THashTable<TKey, TValue>.cleanupTable;
begin
  SetLength(FItems, 0);
  FConflict := 0;
  FFirstEmpty := nil;
  FFirstUsage := nil;
  FLastUsage := nil;
  FCount := 0;
end;

procedure THashTable<TKey, TValue>.clear;
begin
  initMemory;
end;

procedure THashTable<TKey, TValue>.assign(const Src: THashTable<TKey, TValue>);
var
  slot: PHashSlot;
begin
  slot := Src.FFirstUsage;
  clear;
  while Assigned(slot) do
  begin
    Self.insert(slot.key, slot.value);
    slot := slot.next;
  end;
end;

constructor THashTable<TKey, TValue>.Create(ACapacity: TSizeType; AComparer: IEqualityComparer<TKey>;
  ALocker: TSynchroObject);
begin
  FLocker := ALocker;

  FComparer := AComparer;

  if FComparer = nil then
    FComparer := TEqualityComparer<TKey>.Default;

  Self.InitTable(suitableHashTableSize(ACapacity));
end;

function THashTable<TKey, TValue>.delete(const key: TKey): Boolean;
var
  slot: PHashSlot;
begin
  slot := findSlot(key);
  if slot = nil then
    Result := False
  else
  begin
    deleteSlot(slot);
    Result := True;
  end;
end;

function THashTable<TKey, TValue>.deleteSlot(_slot: Pointer): Pointer;
var
  slot, prior, next: PHashSlot;
begin
  slot := PHashSlot(_slot);
  prior := slot.prior;
  next := slot.next;
  if ((prior = nil) or (prior.hash <> slot.hash)) and ((next <> nil) and (next.hash = slot.hash)) then
  begin
    { there are more than one items whose hash is equal to
      the item to be deleted， and it's the first in the
      link-list. in this case, we move the next item to
      the deleted slot }
    slot^ := next^;
    setSlotEmpty(next);
    slot.prior := prior;
    if slot.next = nil then
      FLastUsage := slot
    else
      slot.next.prior := slot;

    Result := slot;
  end
  else
  begin
    if prior = nil then
      FFirstUsage := next
    else
      prior.next := next;
    if next = nil then
      FLastUsage := prior
    else
      next.prior := prior;
    setSlotEmpty(slot);
    Result := next;
  end;

  Dec(FCount);
end;

destructor THashTable<TKey, TValue>.Destroy;
begin
  cleanupTable;
  FLocker.Free;
  inherited;
end;

function THashTable<TKey, TValue>.findSlot(const key: TKey): PHashSlot;
var
  hash: UInt32;
  i: Integer;
  slot: PHashSlot;
begin
  Result := nil;
  hash := getKeyIndex(key);
  slot := @FItems[hash];
  if hsfUsage in slot.flags then
  begin
    while True do
    begin
      if slot.hash <> hash then
        Break;

      if FComparer.Equals(key, slot.key) then
      begin
        Result := slot;
        Break;
      end
      else
      begin
        slot := slot.next;
        if slot = nil then
          Break;
      end
    end;
  end;
end;

procedure THashTable<TKey, TValue>.extractEmptySlot(slot: PHashSlot);
begin
  if slot.prior = nil then
    FFirstEmpty := slot.next
  else
    slot.prior.next := slot.next;

  if slot.next <> nil then
    slot.next.prior := slot.prior;
end;

{
  replace: 如果key已存在，是否替换value？
  ReturnValue：是否已插入新的key
}
function THashTable<TKey, TValue>.insert(const key: TKey; const value: TValue; replace: Boolean): Boolean;
var
  p: TValuePointer;
begin
  p := Self.insert(key, replace);

  if Assigned(p) then
    p^ := value;
end;

function THashTable<TKey, TValue>.insert(const key: TKey; replace: Boolean): TValuePointer;
var
  hash: UInt32;
  slot, newSlot: PHashSlot;
begin
  slot := findSlot(key);

  if Assigned(slot) then
  begin
    if replace then
      Result := @slot.value
    else
      Result := nil;
  end
  else begin
    if FCount >= capacity then
      grow;

    hash := getKeyIndex(key);
    slot := @FItems[hash];

    if not(hsfUsage in slot.flags) then
    begin
      extractEmptySlot(slot);
      if FLastUsage <> nil then
        FLastUsage.next := slot;
      slot.prior := FLastUsage;
      slot.next := nil;
      FLastUsage := slot;
      if FFirstUsage = nil then
        FFirstUsage := slot;
      slot.flags := [hsfUsage];
      slot.hash := hash;
      slot.key := key;
      Result := @slot.value;
    end
    else
      Result := insertConflict(key, hash, slot);

    Inc(FCount);
  end;
end;

function THashTable<TKey, TValue>.insertConflict(const key: TKey; hash: TSizeType; slot: PHashSlot): TValuePointer;
var
  newSlot: PHashSlot;
begin
  newSlot := getEmptySlot;

  if slot.hash = hash then
  begin
    Inc(FConflict);
    newSlot.next := slot.next;
    newSlot.prior := slot;
    newSlot.flags := [hsfUsage];
    newSlot.hash := hash;
    newSlot.key := key;

    if slot.next <> nil then
      slot.next.prior := newSlot;
    slot.next := newSlot;
    if slot = FLastUsage then
      FLastUsage := newSlot;
    Result := @newSlot.value;
  end
  else begin
    newSlot^ := slot^;

    // newSlot.prior will never be nil, so needn't check it
    newSlot.prior.next := newSlot;
    if newSlot.next = nil then
      FLastUsage := newSlot
    else
      newSlot.next.prior := newSlot;
    slot.prior := FLastUsage;
    slot.next := nil;
    slot.hash := hash;
    slot.flags := [hsfUsage];
    slot.key := key;
    FLastUsage.next := slot;
    FLastUsage := slot;
    Result := @slot.value;
  end;
end;

procedure THashTable<TKey, TValue>.lock;
begin
  if Assigned(FLocker) then
    FLocker.Acquire;
end;

procedure THashTable<TKey, TValue>.setCapacity(const value: TSizeType);
var
  newTable: THashTable<TKey, TValue>;
begin
  if (value <> Self.capacity) and (value >= Self.count) then
  begin
    newTable := THashTable<TKey, TValue>.Create(value, FComparer, nil);
    newTable.assign(Self);
    cleanupTable;
    FItems := newTable.FItems;
    FFirstEmpty := newTable.FFirstEmpty;
    FFirstUsage := newTable.FFirstUsage;
    FLastUsage := newTable.FLastUsage;
    FCount := newTable.FCount;
    FConflict := newTable.FConflict;
    newTable.FItems := nil;
    newTable.FFirstEmpty := nil;
    newTable.FFirstUsage := nil;
    newTable.FLastUsage := nil;
    newTable.FCount := 0;
    newTable.Free;
  end;
end;

procedure THashTable<TKey, TValue>.setItem(const key: TKey; const value: TValue);
begin
  insert(key, value);
end;

procedure THashTable<TKey, TValue>.setSlotEmpty(slot: PHashSlot);
begin
  slot.flags := [];
  slot.prior := nil;
  slot.next := FFirstEmpty;
  if FFirstEmpty <> nil then
    FFirstEmpty.prior := slot;
  FFirstEmpty := slot;
end;

procedure THashTable<TKey, TValue>.unlock;
begin
  if Assigned(FLocker) then
    FLocker.Release;
end;

procedure THashTable<TKey, TValue>.grow;
begin
  setCapacity(suitableHashTableSize(Self.capacity));
end;

function THashTable<TKey, TValue>.getCapacity: TSizeType;
begin
  Result := Length(FItems);
end;

function THashTable<TKey, TValue>.getEmptySlot: PHashSlot;
begin
  Result := FFirstEmpty;
  if FFirstEmpty <> nil then
  begin
    if FFirstEmpty.next <> nil then
      FFirstEmpty.next.prior := nil;
    FFirstEmpty := FFirstEmpty.next;
  end;
end;

function THashTable<TKey, TValue>.getItem(const key: TKey): TValue;
var
  slot: PHashSlot;
begin
  slot := findSlot(key);
  if slot = nil then
    FillChar(Result, SizeOf(Result), 0)
  else
    Result := slot.value;
end;

function THashTable<TKey, TValue>.getItemPointer(const key: TKey): TValuePointer;
var
  slot: PHashSlot;
begin
  slot := findSlot(key);
  if slot = nil then
    Result := nil
  else
    Result := @slot.value;
end;

procedure THashTable<TKey, TValue>.InitTable(ACapacity: TSizeType);
begin
  SetLength(FItems, ACapacity);
  initMemory;
end;

procedure THashTable<TKey, TValue>.initMemory;
var
  i: Integer;
  next: PHashSlot;
begin
  if capacity > 0 then
  begin
    FFirstUsage := nil;
    FLastUsage := nil;
    FCount := 0;
    FConflict := 0;
    FItems[ Low(FItems)].prior := nil;
    for i := Low(FItems) to High(FItems) - 1 do
    begin
      FItems[i].flags := [];
      FItems[i + 1].prior := @FItems[i];
      FItems[i].next := @FItems[i + 1];
    end;
    FItems[ High(FItems)].flags := [];
    FItems[ High(FItems)].next := nil;
    FFirstEmpty := @FItems[0];
  end;
end;

function THashTable<TKey, TValue>.find(const key: TKey; var value: TValue): Boolean;
var
  slot: PHashSlot;
begin
  slot := findSlot(key);
  if Assigned(slot) then
  begin
    value := slot.value;
    Result := True;
  end
  else
    Result := False;
end;

function THashTable<TKey, TValue>.exists(const key: TKey): Boolean;
begin
  Result := Assigned(findSlot(key));
end;

type
  TRBStrEqualityComparer = class(TInterfacedObject, IEqualityComparer<RawByteString>)
  public
    function Equals(const Left, Right: RawByteString): Boolean; reintroduce; overload;
    function GetHashCode(const value: RawByteString): Integer; reintroduce; overload;
  end;

var
  g_RBStrEqualityComparer: IEqualityComparer<RawByteString>;

type
  TUStrEqualityComparer = class(TInterfacedObject, IEqualityComparer<UnicodeString>)
  public
    function Equals(const Left, Right: UnicodeString): Boolean; reintroduce; overload;
    function GetHashCode(const value: UnicodeString): Integer; reintroduce; overload;
  end;

var
  g_UStrEqualityComparer: IEqualityComparer<UnicodeString>;

  { TRBStrEqualityComparer }

function TRBStrEqualityComparer.Equals(const Left, Right: RawByteString): Boolean;
begin
  Result := RBStrCompare(Left, Right, True) = 0;
end;

function TRBStrEqualityComparer.GetHashCode(const value: RawByteString): Integer;
begin
  Result := ELFHash(PAnsiChar(value), Length(value));
end;

{ TUStrEqualityComparer }

function TUStrEqualityComparer.Equals(const Left, Right: UnicodeString): Boolean;
begin
  Result := UStrCompare(Left, Right, True) = 0;
end;

function TUStrEqualityComparer.GetHashCode(const value: UnicodeString): Integer;
begin
  Result := ELFHash(PAnsiChar(Pointer(value)), Length(value) * 2);
end;

{ THashTableIterator }

function THashTable<TKey, TValue>.TIterator.prior(step: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to step do
  begin
    if Assigned(FSlot) then
    begin
      FSlot := FSlot.prior;
      Inc(Result);
    end
    else
      Break;
  end;
end;

procedure THashTable<TKey, TValue>.TIterator.setTable(ATable: THashTable<TKey, TValue>);
begin
  FTable := ATable;
  FSlot := ATable.FirstUsage;
end;

function THashTable<TKey, TValue>.TIterator.eof: Boolean;
begin
  Result := not Assigned(FSlot) or not (hsfUsage in FSlot.flags);
end;

procedure THashTable<TKey, TValue>.TIterator.erase;
begin
  FSlot := PHashSlot(FTable.deleteSlot(FSlot));
end;

function THashTable<TKey, TValue>.TIterator.next;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to step do
  begin
    if Assigned(FSlot) then
    begin
      FSlot := FSlot.next;
      Inc(Result);
    end
    else
      Break;
  end;
end;

function THashTable<TKey, TValue>.TIterator.getValue: TValue;
begin
  Result := FSlot.value;
end;

function THashTable<TKey, TValue>.TIterator.getValuePointer: Pointer;
begin
  Result := @FSlot.value;
end;

procedure THashTable<TKey, TValue>.TIterator.setValue(const AValue: TValue);
begin
  FSlot.value := AValue;
end;

function THashTable<TKey, TValue>.TIterator.getKey: TKey;
begin
  Result := FSlot.key;
end;

initialization

g_RBStrEqualityComparer := TRBStrEqualityComparer.Create;
g_UStrEqualityComparer := TUStrEqualityComparer.Create;

end.
