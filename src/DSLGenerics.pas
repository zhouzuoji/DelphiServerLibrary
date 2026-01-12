unit DSLGenerics;

interface

uses
  SysUtils, Classes, RTLConsts, Windows, Dialogs, SyncObjs, Generics.Collections,
  Generics.Defaults, DSLUtils;

type
  TCollectionNotification = Generics.Collections.TCollectionNotification;
  TSingletonedDelegatedComparer<T> = class(TInterfacedObject, IComparer<T>)
  private
    FCompareProc: TComparison<T>;
    class var FSingleton: IComparer<T>;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(const ACompareProc: TComparison<T>);
    class function GetInstance(const ACompareProc: TComparison<T>): IComparer<T>;
    function Compare(const left, right: T): Integer;
  end;

  TARCWrapper<T: class> = class(TRefCountedObject)
  private
    FObj: T;
  public
    constructor Create(_obj: T);
    destructor Destroy; override;
    property obj: T read FObj;
  end;

  TListEx<T> = class(TEnumerable<T>)
  public type
    TItemPointer = ^T;

    TEnumerator = class(TEnumerator<T>)
    private
      FList: TListEx<T>;
      FIndex: Integer;
      function GetCurrent: T;
    protected
      function DoGetCurrent: T; override;
      function DoMoveNext: Boolean; override;
    public
      constructor Create(AList: TListEx<T>);
      property Current: T read GetCurrent;
      function MoveNext: Boolean;
    end;
  private
    FItems: array of T;
    FCount: Integer;
    FComparer: IComparer<T>;
    FOnNotify: TCollectionNotifyEvent<T>;
    function GetCapacity: Integer;
    procedure SetCapacity(Value: Integer);
    procedure SetCount(Value: Integer);
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
    procedure Grow(ACount: Integer);
    procedure GrowCheck(ACount: Integer); inline;
    procedure DoDelete(Index: Integer; Notification: Generics.Collections.TCollectionNotification);
    function GetItemPointer(Index: Integer): TItemPointer; inline;
  protected
    function DoGetEnumerator: TEnumerator<T>; override;
    procedure Notify(const Item: T; Action: Generics.Collections.TCollectionNotification); virtual;
  public
    constructor Create; overload;
    constructor Create(const AComparer: IComparer<T>); overload;
    constructor Create(Collection: TEnumerable<T>); overload;
    destructor Destroy; override;

    function Add: TItemPointer; overload;
    function Add(const Value: T): Integer; overload;

    procedure AddRange(const Values: array of T); overload;
    procedure AddRange(const Collection: IEnumerable<T>); overload;
    procedure AddRange(Collection: TEnumerable<T>); overload;

    procedure Insert(Index: Integer; const Value: T);

    procedure InsertRange(Index: Integer; const Values: array of T); overload;
    procedure InsertRange(Index: Integer; const Collection: IEnumerable<T>); overload;
    procedure InsertRange(Index: Integer; const Collection: TEnumerable<T>); overload;

    function Remove(const Value: T): Integer;
    procedure Delete(Index: Integer);
    procedure DeleteRange(AIndex, ACount: Integer);
    function Extract(const Value: T): T;

    procedure Exchange(Index1, Index2: Integer);
    procedure Move(CurIndex, NewIndex: Integer);

    function First: T;
    function Last: T;

    procedure Clear;

    function Contains(const Value: T): Boolean;
    function IndexOf(const Value: T): Integer;
    function LastIndexOf(const Value: T): Integer;

    procedure Reverse;

    procedure Sort; overload;
    procedure Sort(const AComparer: IComparer<T>); overload;
    function BinarySearch(const Item: T; out Index: Integer): Boolean; overload;
    function BinarySearch(const Item: T; out Index: Integer; const AComparer: IComparer<T>): Boolean; overload;

    procedure TrimExcess;

    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: T read GetItem write SetItem; default;
    property ItemPointers[Index: Integer]: TItemPointer read GetItemPointer;
    property OnNotify: TCollectionNotifyEvent<T>read FOnNotify write FOnNotify;
    function GetEnumerator: TEnumerator; reintroduce;
  end;

  TNotifyEvent<T> = procedure(Sender: TObject; const Param: T) of object;

  TThreadList<T> = class(TList<T>)
  private
    FLock: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LockList;
    procedure UnlockList; inline;
  end;

  TThreadListEx<T: record > = class(TListEx<T>)
  private
    FLock: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LockList;
    procedure UnlockList; inline;
  end;

  TObjectListEx<T: class> = class(TObjectList<T>)
  protected
    procedure Notify(const Value: T; Action: Generics.Collections.TCollectionNotification); override;
  public
    function Clone: TObjectListEx<T>;
    procedure union(another: TObjectListEx<T>);
  end;

  TThreadObjectListEx<T: class> = class(TObjectListEx<T>)
  private
    FLock: TRTLCriticalSection;
  public
    constructor Create(AOwnsObjects: Boolean = True); overload;
    constructor Create(const AComparer: IComparer<T>; AOwnsObjects: Boolean = True); overload;
    constructor Create(Collection: TEnumerable<T>; AOwnsObjects: Boolean = True); overload;
    destructor Destroy; override;
    procedure LockList;
    procedure UnlockList; inline;
  end;

  TObjectListHelper<T: class> = class
  public
    class procedure Clear(list: TList<T>); static;
    class procedure ClearAndFree(list: TList<T>); static;
  end;

  TLinkNode<T> = class
  private
    FData: T;
  protected
    FNext: TLinkNode<T>;
  public
    // property Data: T read FData write FData;
  end;

  TLinkQueue<T> = class
  private
    FLockState: Integer;
    FFirst: TLinkNode<T>;
    FLast: TLinkNode<T>;
    FSize: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure push(Item: T);
    procedure PushFront(Item: T);
    function pop(out Item: T): Boolean;
    property size: Integer read FSize;
  end;

  TLinkNode = class(TRefCountedObject)
  protected
    next: TLinkNode;
  end;

  TLinkStack<T> = class
  private
    FLockState: Integer;
    FFirst: TLinkNode<T>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure push(Item: T);
    function pop(out Item: T): Boolean;
  end;

  TCircularList<T> = class
  private type
    ArrayOfT = array of T;
  private
    FComparer: IComparer<T>;
    FData: ArrayOfT;
    FFirst: Integer;
    FCount: Integer;
    FZeroMemoryWhenDeleted: Boolean;
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
    procedure SetCount(const Value: Integer);
    function GetCapacity: Integer;
    procedure MoveRange(S1, S2, S3, S4, D1, D2, D3, D4: Integer);
    procedure DoDeleteRange(AIndex, ACount: Integer; Notification: Generics.Collections.TCollectionNotification);
    procedure SetCapacity(const Value: Integer);
  protected
    procedure Notify(const Item: T; Action: Generics.Collections.TCollectionNotification); virtual;
  public
    constructor Create(_capacity: Integer; const _comparer: IComparer<T>); overload;
    constructor Create(_capacity: Integer); overload;
    destructor Destroy; override;
    procedure Add(const Value: T); overload;
    function IndexOf(const Value: T): Integer;
    procedure Delete(Index: Integer);
    function Extract(const Value: T): T;
    procedure DeleteRange(AIndex, ACount: Integer);
    procedure Clear;
    function Remove(const Item: T): Integer;
    function GetInternalIndex(Index: Integer): Integer;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property First: Integer read FFirst;
    property Count: Integer read FCount write SetCount;
    property ZeroMemoryWhenDeleted: Boolean read FZeroMemoryWhenDeleted write FZeroMemoryWhenDeleted;
    property Items[Index: Integer]: T read GetItem write SetItem; default;
  end;

  TSequenceDictionary<TKey, TValue> = class(TEnumerable < TPair < TKey, TValue >> )
  private type
    TItemArray = array of TPair<TKey, TValue>;
  private
    FItems: TItemArray;
    FComparer: IEqualityComparer<TKey>;
    function GetCount: Integer;
    function GetItem(const key: TKey): TValue;
    procedure SetItem(const key: TKey; const Value: TValue);
  protected
    function DoGetEnumerator: TEnumerator < TPair < TKey, TValue >> ; override;
  public type
    TPairEnumerator = class(TEnumerator < TPair < TKey, TValue >> )
    private
      FDictionary: TSequenceDictionary<TKey, TValue>;
      FIndex: Integer;
      function GetCurrent: TPair<TKey, TValue>;
    protected
      function DoGetCurrent: TPair<TKey, TValue>; override;
      function DoMoveNext: Boolean; override;
    public
      constructor Create(ADictionary: TSequenceDictionary<TKey, TValue>);
      property Current: TPair<TKey, TValue>read GetCurrent;
      function MoveNext: Boolean;
    end;
  public
    constructor Create(const AComparer: IEqualityComparer<TKey>); overload;
    constructor Create; overload;
    procedure Clear;
    function IndexOf(const key: TKey): Integer;
    function exists(const key: TKey): Boolean;
    property Count: Integer read GetCount;
    property Item[const key: TKey]: TValue read GetItem write SetItem; default;
  end;

  TRefCountedWrapper<T: class> = class(TRefCountedObject)
  private
    FInstance: T;
  public
    constructor Create(_object: T);
    destructor Destroy; override;
    property instance: T read FInstance;
  end;

  TKeyValueList<TKey, TValue> = class(TRefCountedObject)
  private
    FPairs: TList < TPair < TKey, TValue >> ;
    FComparer: IComparer<TKey>;
    function getValue(const AKey: TKey): TValue;
    procedure setValue(const AKey: TKey; const AValue: TValue);
  public
    constructor Create; overload;
    constructor Create(const AComparer: IComparer<TKey>); overload;
    procedure Add(const AKey: TKey; AValue: TValue);
    function exists(const AKey: TKey): Boolean;
    function getValueEx(const AKey: TKey; var AValue: TValue): Boolean;
    function Remove(const AKey: TKey): Boolean;
    destructor Destroy; override;
    property pairs: TList < TPair < TKey, TValue >> read FPairs;
    property Values[const AKey: TKey]: TValue read getValue write setValue; default;
  end;

  TCaseUnsensitiveUnicodeStringComparer = class(TInterfacedObject, IComparer<UnicodeString>)
  private
    class var FSingleton: IComparer<UnicodeString>;
  public
    function Compare(const left, right: UnicodeString): Integer;
    class function GetInstance: IComparer<UnicodeString>;
  end;

  TCaseUnsensitiveRawByteStringComparer = class(TInterfacedObject, IComparer<RawByteString>)
  private
    class var FSingleton: IComparer<RawByteString>;
  public
    function Compare(const left, right: RawByteString): Integer;
    class function GetInstance: IComparer<RawByteString>;
  end;

  THashList<TKey, TValue> = class
  private
    FItems: TList<TValue>;
    FKeyGetter: TFunc<TValue, TKey>;
    FDict: TDictionary<TKey, Integer>;
    function GetCount: Integer;
  public
    constructor Create(_KeyGetter: TFunc<TValue, TKey>);
    destructor Destroy; override;
    function TryGetValue(const _Key: TKey; out _Value: TValue): Boolean;
    procedure Add(const _Value: TValue);
    function TryAdd(const _Value: TValue): Boolean;
    function Remove(const _Key: TKey): Boolean;
    procedure Clear;
    property Count: Integer read GetCount;
    property Items: TList<TValue> read FItems;
  end;

procedure UnitTest_StringKeyStringValueList;

implementation

procedure UnitTest_StringKeyStringValueList;
var
  list: TKeyValueList<string, string>;
  v: string;
begin
  list := TKeyValueList<string, string>.Create(TCaseUnsensitiveUnicodeStringComparer.Create);

  try
    ShowMessage(list['key1']);
    list['key1'] := 'value1';
    ShowMessage(list['key1']);
    ShowMessage(list['Key1']);
    list['Key1'] := 'value1 changed';
    ShowMessage(list['key1']);
    list.getValueEx('Key1', v);
    ShowMessage(v);
  finally
    list.Free;
  end;
end;

{ TObjectListHelper<T> }

class procedure TObjectListHelper<T>.Clear(list: TList<T>);
var
  i: Integer;
begin
  if Assigned(list) then
  begin
    for i := 0 to list.Count - 1 do
      SmartUnrefObject(list[i]);

    list.Clear;
  end;
end;

class procedure TObjectListHelper<T>.ClearAndFree(list: TList<T>);
begin
  Clear(list);
  list.Free;
end;

{ TListEx<T> }

function TListEx<T>.GetCapacity: Integer;
begin
  Result := Length(FItems);
end;

procedure TListEx<T>.SetCapacity(Value: Integer);
begin
  if Value < Count then
    Count := Value;
  SetLength(FItems, Value);
end;

procedure TListEx<T>.SetCount(Value: Integer);
begin
  if Value < 0 then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);
  if Value > Capacity then
    SetCapacity(Value);
  if Value < Count then
    DeleteRange(Value, Count - Value);
  FCount := Value;
end;

function TListEx<T>.GetItem(Index: Integer): T;
begin
  if (Index < 0) or (Index >= Count) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);
  Result := FItems[Index];
end;

function TListEx<T>.GetItemPointer(Index: Integer): TItemPointer;
begin
  if (Index < 0) or (Index >= Count) then
    Result := nil
  else
    Result := @FItems[Index];
end;

procedure TListEx<T>.SetItem(Index: Integer; const Value: T);
var
  oldItem: T;
begin
  if (Index < 0) or (Index >= Count) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);

  oldItem := FItems[Index];
  FItems[Index] := Value;

  Notify(oldItem, cnRemoved);
  Notify(Value, cnAdded);
end;

procedure TListEx<T>.Grow(ACount: Integer);
var
  newCount: Integer;
begin
  newCount := Length(FItems);
  if newCount = 0 then
    newCount := ACount
  else
    repeat
      newCount := newCount * 2;
      if newCount < 0 then
        OutOfMemoryError;
    until newCount >= ACount;
    Capacity := newCount;
end;

procedure TListEx<T>.GrowCheck(ACount: Integer);
begin
  if ACount > Length(FItems) then
    Grow(ACount)
  else if ACount < 0 then
    OutOfMemoryError;
end;

procedure TListEx<T>.Notify(const Item: T; Action: Generics.Collections.TCollectionNotification);
begin
  if Assigned(FOnNotify) then
    FOnNotify(Self, Item, Action);
end;

constructor TListEx<T>.Create;
begin
  Create(TComparer<T>.Default);
end;

constructor TListEx<T>.Create(const AComparer: IComparer<T>);
begin
  inherited Create;
  FComparer := AComparer;
  if FComparer = nil then
    FComparer := TComparer<T>.Default;
end;

constructor TListEx<T>.Create(Collection: TEnumerable<T>);
begin
  inherited Create;
  FComparer := TComparer<T>.Default;
  InsertRange(0, Collection);
end;

destructor TListEx<T>.Destroy;
begin
  Capacity := 0;
  inherited;
end;

function TListEx<T>.DoGetEnumerator: TEnumerator<T>;
begin
  Result := GetEnumerator;
end;

function TListEx<T>.Add(const Value: T): Integer;
begin
  GrowCheck(Count + 1);
  Result := Count;
  FItems[Count] := Value;
  Inc(FCount);
  Notify(Value, cnAdded);
end;

procedure TListEx<T>.AddRange(const Values: array of T);
begin
  InsertRange(Count, Values);
end;

procedure TListEx<T>.AddRange(const Collection: IEnumerable<T>);
begin
  InsertRange(Count, Collection);
end;

function TListEx<T>.Add: TItemPointer;
begin
  GrowCheck(Count + 1);
  Result := @FItems[Count];
  Inc(FCount);
  Notify(FItems[Count], cnAdded);
end;

procedure TListEx<T>.AddRange(Collection: TEnumerable<T>);
begin
  InsertRange(Count, Collection);
end;

function TListEx<T>.BinarySearch(const Item: T; out Index: Integer): Boolean;
begin
  Result := TArray.BinarySearch<T>(FItems, Item, Index, FComparer, 0, Count);
end;

function TListEx<T>.BinarySearch(const Item: T; out Index: Integer; const AComparer: IComparer<T>): Boolean;
begin
  Result := TArray.BinarySearch<T>(FItems, Item, Index, AComparer, 0, Count);
end;

procedure TListEx<T>.Insert(Index: Integer; const Value: T);
begin
  if (Index < 0) or (Index > Count) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);

  GrowCheck(Count + 1);
  if Index <> Count then
  begin
    System.Move(FItems[Index], FItems[Index + 1], (Count - Index) * SizeOf(T));
    FillChar(FItems[Index], SizeOf(FItems[Index]), 0);
  end;
  FItems[Index] := Value;
  Inc(FCount);
  Notify(Value, cnAdded);
end;

procedure TListEx<T>.InsertRange(Index: Integer; const Values: array of T);
var
  i: Integer;
begin
  if (Index < 0) or (Index > Count) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);

  GrowCheck(Count + Length(Values));
  if Index <> Count then
  begin
    System.Move(FItems[Index], FItems[Index + Length(Values)], (Count - Index) * SizeOf(T));
    FillChar(FItems[Index], Length(Values) * SizeOf(T), 0);
  end;

  for i := 0 to Length(Values) - 1 do
    FItems[Index + i] := Values[i];

  Inc(FCount, Length(Values));

  for i := 0 to Length(Values) - 1 do
    Notify(Values[i], cnAdded);
end;

procedure TListEx<T>.InsertRange(Index: Integer; const Collection: IEnumerable<T>);
var
  Item: T;
begin
  for Item in Collection do
  begin
    Insert(Index, Item);
    Inc(Index);
  end;
end;

procedure TListEx<T>.InsertRange(Index: Integer; const Collection: TEnumerable<T>);
var
  Item: T;
begin
  for Item in Collection do
  begin
    Insert(Index, Item);
    Inc(Index);
  end;
end;

procedure TListEx<T>.Exchange(Index1, Index2: Integer);
var
  temp: T;
begin
  temp := FItems[Index1];
  FItems[Index1] := FItems[Index2];
  FItems[Index2] := temp;
end;

function TListEx<T>.Extract(const Value: T): T;
var
  index: Integer;
begin
  index := IndexOf(Value);
  if index < 0 then
    Result := Default(T)
  else
  begin
    Result := FItems[index];
    DoDelete(index, cnExtracted);
  end;
end;

function TListEx<T>.First: T;
begin
  Result := Items[0];
end;

function TListEx<T>.Remove(const Value: T): Integer;
begin
  Result := IndexOf(Value);
  if Result >= 0 then
    Delete(Result);
end;

procedure TListEx<T>.DoDelete(Index: Integer; Notification: Generics.Collections.TCollectionNotification);
var
  oldItem: T;
begin
  if (Index < 0) or (Index >= Count) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);
  oldItem := FItems[Index];
  FItems[Index] := Default(T);
  Dec(FCount);
  if Index <> Count then
  begin
    System.Move(FItems[Index + 1], FItems[Index], (Count - Index) * SizeOf(T));
    FillChar(FItems[Count], SizeOf(T), 0);
  end;
  Notify(oldItem, Notification);
end;

procedure TListEx<T>.Delete(Index: Integer);
begin
  DoDelete(Index, cnRemoved);
end;

procedure TListEx<T>.DeleteRange(AIndex, ACount: Integer);
var
  oldItems: array of T;
  tailCount, i: Integer;
begin
  if (AIndex < 0) or (ACount < 0) or (AIndex + ACount > Count) or (AIndex + ACount < 0) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);
  if ACount = 0 then
    Exit;

  SetLength(oldItems, ACount);
  System.Move(FItems[AIndex], oldItems[0], ACount * SizeOf(T));

  tailCount := Count - (AIndex + ACount);
  if tailCount > 0 then
  begin
    System.Move(FItems[AIndex + ACount], FItems[AIndex], tailCount * SizeOf(T));
    FillChar(FItems[Count - ACount], ACount * SizeOf(T), 0);
  end
  else
  begin
    FillChar(FItems[AIndex], ACount * SizeOf(T), 0);
  end;
  Dec(FCount, ACount);

  for i := 0 to Length(oldItems) - 1 do
    Notify(oldItems[i], cnRemoved);
end;

procedure TListEx<T>.Clear;
begin
  Count := 0;
  Capacity := 0;
end;

function TListEx<T>.Contains(const Value: T): Boolean;
begin
  Result := IndexOf(Value) >= 0;
end;

function TListEx<T>.IndexOf(const Value: T): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if FComparer.Compare(FItems[i], Value) = 0 then
      Exit(i);
  Result := -1;
end;

function TListEx<T>.Last: T;
begin
  Result := Items[Count - 1];
end;

function TListEx<T>.LastIndexOf(const Value: T): Integer;
var
  i: Integer;
begin
  for i := Count - 1 downto 0 do
    if FComparer.Compare(FItems[i], Value) = 0 then
      Exit(i);
  Result := -1;
end;

procedure TListEx<T>.Move(CurIndex, NewIndex: Integer);
var
  temp: T;
begin
  if CurIndex = NewIndex then
    Exit;
  if (NewIndex < 0) or (NewIndex >= FCount) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);

  temp := FItems[CurIndex];
  FItems[CurIndex] := Default(T);
  if CurIndex < NewIndex then
    System.Move(FItems[CurIndex + 1], FItems[CurIndex], (NewIndex - CurIndex) * SizeOf(T))
  else
    System.Move(FItems[NewIndex], FItems[NewIndex + 1], (CurIndex - NewIndex) * SizeOf(T));

  FillChar(FItems[NewIndex], SizeOf(T), 0);
  FItems[NewIndex] := temp;
end;

procedure TListEx<T>.Reverse;
var
  tmp: T;
  b, e: Integer;
begin
  b := 0;
  e := Count - 1;
  while b < e do
  begin
    tmp := FItems[b];
    FItems[b] := FItems[e];
    FItems[e] := tmp;
    Inc(b);
    Dec(e);
  end;
end;

procedure TListEx<T>.Sort;
begin
  TArray.Sort<T>(FItems, FComparer, 0, Count);
end;

procedure TListEx<T>.Sort(const AComparer: IComparer<T>);
begin
  TArray.Sort<T>(FItems, AComparer, 0, Count);
end;

procedure TListEx<T>.TrimExcess;
begin
  Capacity := Count;
end;

{ pending compiler support
  function TListEx<T>.ToArray: TArray<T>;
  var
  i: Integer;
  begin
  SetLength(Result, Count);
  for i := 0 to Count - 1 do
  Result[i] := Items[i];
  end;
}

function TListEx<T>.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

{ TListEx<T>.TEnumerator }

constructor TListEx<T>.TEnumerator.Create(AList: TListEx<T>);
begin
  inherited Create;
  FList := AList;
  FIndex := -1;
end;

function TListEx<T>.TEnumerator.DoGetCurrent: T;
begin
  Result := GetCurrent;
end;

function TListEx<T>.TEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function TListEx<T>.TEnumerator.GetCurrent: T;
begin
  Result := FList[FIndex];
end;

function TListEx<T>.TEnumerator.MoveNext: Boolean;
begin
  if FIndex >= FList.Count then
    Exit(False);
  Inc(FIndex);
  Result := FIndex < FList.Count;
end;

{ TThreadList<T> }

constructor TThreadList<T>.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
end;

destructor TThreadList<T>.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TThreadList<T>.LockList;
begin
  EnterCriticalSection(FLock);
end;

procedure TThreadList<T>.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

{ TLinkQueue }

procedure TLinkQueue<T>.Clear;
var
  node: TLinkNode<T>;
begin
  while InterlockedExchange(FLockState, 1) = 1 do
    ;

  try
    while Assigned(FFirst) do
    begin
      node := FFirst;
      FFirst := FFirst.FNext;
      SmartUnrefObject(node);
    end;

    FLast := nil;
    FSize := 0;

  finally
    InterlockedExchange(FLockState, 0);
  end;
end;

constructor TLinkQueue<T>.Create;
begin
  FLockState := 0;
  FFirst := nil;
  FLast := nil;
end;

destructor TLinkQueue<T>.Destroy;
begin
  Self.Clear;
  inherited;
end;

function TLinkQueue<T>.pop(out Item: T): Boolean;
var
  node: TLinkNode<T>;
begin
  while InterlockedExchange(FLockState, 1) = 1 do
    ;

  try
    node := FFirst;

    if Assigned(FFirst) then
    begin
      Item := node.FData;

      FFirst := node.FNext;

      if not Assigned(FFirst) then
        FLast := nil;

      Dec(FSize);

      Result := True;
    end
    else
      Result := False;
  finally
    InterlockedExchange(FLockState, 0);
  end;

  if Assigned(node) then
    node.Free;
end;

procedure TLinkQueue<T>.push(Item: T);
var
  node: TLinkNode<T>;
begin
  node := TLinkNode<T>.Create;
  node.FData := Item;
  node.FNext := nil;

  while InterlockedExchange(FLockState, 1) = 1 do
    ;

  try
    if Assigned(FFirst) then
    begin
      FLast.FNext := node;
      FLast := node;
    end
    else
    begin
      FFirst := node;
      FLast := node;
    end;

    Inc(FSize);
  finally
    InterlockedExchange(FLockState, 0);
  end;
end;

procedure TLinkQueue<T>.PushFront(Item: T);
var
  node: TLinkNode<T>;
begin
  node := TLinkNode<T>.Create;
  node.FData := Item;
  node.FNext := nil;

  while InterlockedExchange(FLockState, 1) = 1 do
    ;

  try
    node.FNext := FFirst;
    FFirst := node;

    if not Assigned(node.FNext) then
      FLast := node;

    Inc(FSize);
  finally
    InterlockedExchange(FLockState, 0);
  end;
end;

{ TLinkStack }

procedure TLinkStack<T>.Clear;
var
  node: TLinkNode<T>;
begin
  while InterlockedExchange(FLockState, 1) = 1 do
    ;

  try
    while Assigned(FFirst) do
    begin
      node := FFirst;
      FFirst := FFirst.FNext;
      SmartUnrefObject(node);
    end;

  finally
    InterlockedExchange(FLockState, 0);
  end;
end;

constructor TLinkStack<T>.Create;
begin
  FFirst := nil;
  FLockState := 0;
end;

destructor TLinkStack<T>.Destroy;
begin
  Self.Clear;
  inherited;
end;

function TLinkStack<T>.pop(out Item: T): Boolean;
var
  node: TLinkNode<T>;
begin
  while InterlockedExchange(FLockState, 1) = 1 do
    ;

  try
    node := FFirst;

    if Assigned(FFirst) then
    begin
      FFirst := FFirst.FNext;
      Item := node.FData;
      Result := True;
    end
    else
      Result := False;

  finally
    InterlockedExchange(FLockState, 0);
  end;

  if Assigned(node) then
    node.Free;
end;

procedure TLinkStack<T>.push(Item: T);
var
  node: TLinkNode<T>;
begin
  node := TLinkNode<T>.Create;
  node.FData := Item;

  while InterlockedExchange(FLockState, 1) = 1 do
    ;

  try
    node.FNext := FFirst;
    FFirst := node;
  finally
    InterlockedExchange(FLockState, 0);
  end;
end;

{ TObjectListEx<T> }

function TObjectListEx<T>.Clone: TObjectListEx<T>;
var
  i: Integer;
  Item: T;
begin
  Result := TObjectListEx<T>.Create(OwnsObjects);
  Result.Count := Self.Count;

  for i := 0 to Self.Count - 1 do
  begin
    Item := Self.Items[i];

    if OwnsObjects then
      RefObject(Item);

    Result[i] := Item;
  end;
end;

procedure TObjectListEx<T>.Notify(const Value: T; Action: Generics.Collections.TCollectionNotification);
begin
  if OwnsObjects and (Action = cnRemoved) then
    SmartUnrefObject(Value);
end;

procedure TObjectListEx<T>.union(another: TObjectListEx<T>);
var
  i: Integer;
  Item: T;
begin
  if Assigned(another) then
    for i := 0 to another.Count - 1 do
    begin
      Item := another.Items[i];

      if OwnsObjects then
        RefObject(Item);

      Self.Add(Item);
    end;
end;

{ TThreadObjectListEx<T> }

constructor TThreadObjectListEx<T>.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);
  InitializeCriticalSection(FLock);
end;

constructor TThreadObjectListEx<T>.Create(const AComparer: IComparer<T>; AOwnsObjects: Boolean);
begin
  inherited Create(AComparer, AOwnsObjects);
  InitializeCriticalSection(FLock);
end;

constructor TThreadObjectListEx<T>.Create(Collection: TEnumerable<T>; AOwnsObjects: Boolean);
begin
  inherited Create(Collection, AOwnsObjects);
  InitializeCriticalSection(FLock);
end;

destructor TThreadObjectListEx<T>.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TThreadObjectListEx<T>.LockList;
begin
  EnterCriticalSection(FLock);
end;

procedure TThreadObjectListEx<T>.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

{ TCircularList<T> }

procedure TCircularList<T>.Add(const Value: T);
begin
  if Count = Capacity then
  begin
    Notify(FData[FFirst], cnRemoved);
    FData[FFirst] := Value;
    Notify(Value, cnAdded);
    Inc(FFirst);
  end
  else
  begin
    Notify(Value, cnAdded);
    FData[(FFirst + Count) mod Capacity] := Value;
    Inc(FCount);
  end;
end;

procedure TCircularList<T>.Clear;
begin
  Count := 0;
end;

constructor TCircularList<T>.Create(_capacity: Integer; const _comparer: IComparer<T>);
begin
  inherited Create;
  SetLength(FData, _capacity);
  FCount := 0;
  FFirst := 0;
  FComparer := _comparer;

  if FComparer = nil then
    FComparer := TComparer<T>.Default;
end;

constructor TCircularList<T>.Create(_capacity: Integer);
begin
  Create(_capacity, TComparer<T>.Default);
end;

procedure TCircularList<T>.Delete(Index: Integer);
begin
  DoDeleteRange(Index, 1, cnRemoved);
end;

procedure TCircularList<T>.DeleteRange(AIndex, ACount: Integer);
begin
  Self.DoDeleteRange(AIndex, ACount, cnRemoved);
end;

destructor TCircularList<T>.Destroy;
begin
  Self.Clear;
  inherited;
end;

procedure TCircularList<T>.DoDeleteRange(AIndex, ACount: Integer; Notification: Generics.Collections.TCollectionNotification);
var
  i, S1, S2, S3, S4, D1, D2, D3, D4, O1, O2: Integer;
begin
  if (AIndex < 0) or (ACount < 0) or (AIndex + ACount > Count) or (AIndex + ACount < 0) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);

  if ACount = 0 then
    Exit;

  for i := AIndex to AIndex + ACount - 1 do
    Notify(FData[(FFirst + i) mod Capacity], Notification);

  if Count - (AIndex + ACount) <= AIndex then
  begin
    O1 := (FFirst + Count - ACount) mod Capacity;
    O2 := (FFirst + Count - 1) mod Capacity;

    if Count - (AIndex + ACount) > 0 then
    begin
      D1 := (FFirst + AIndex) mod Capacity;
      D2 := (FFirst + AIndex + ACount - 1) mod Capacity;

      if D1 <= D2 then
      begin
        D3 := (D2 + 1) mod Capacity;
        D4 := Capacity - 1;
      end
      else
      begin
        D3 := 0;
        D4 := D2;
        D2 := Capacity - 1;
      end;

      S1 := (FFirst + AIndex + ACount) mod Capacity;
      S2 := (FFirst + Count - 1) mod Capacity;

      if S1 <= S2 then
      begin
        S3 := -1;
        S4 := -2;
      end
      else
      begin
        S3 := 0;
        S4 := S2;
        S2 := Capacity - 1;
      end;

      Self.MoveRange(S1, S2, S3, S4, D1, D2, D3, D4);
    end;
  end
  else
  begin
    O1 := FFirst mod Capacity;
    O2 := (FFirst + ACount - 1) mod Capacity;

    if AIndex > 0 then
    begin
      D2 := (FFirst + AIndex + ACount - 1) mod Capacity;

      if D2 + 1 >= AIndex then
      begin
        D1 := D2 + 1 - AIndex;
        D3 := -1;
        D4 := -2;
      end
      else
      begin
        D3 := 0;
        D4 := D2;
        D2 := Capacity - 1;
        D1 := Capacity + D4 + 1 - AIndex;
      end;

      S1 := FFirst mod Capacity;
      S2 := (FFirst + AIndex - 1) mod Capacity;

      if S1 <= S2 then
      begin
        S3 := -1;
        S4 := -2;
      end
      else
      begin
        S3 := 0;
        S4 := S2;
        S2 := Capacity - 1;
      end;

      Self.MoveRange(S1, S2, S3, S4, D1, D2, D3, D4);
      Inc(FFirst, ACount)
    end;
  end;

  if FZeroMemoryWhenDeleted then
  begin
    if O2 >= O1 then
      FillChar(FData[O1], ACount * SizeOf(T), 0)
    else
    begin
      FillChar(FData[O1], (Capacity - O1) * SizeOf(T), 0);
      FillChar(FData[0], (O2 + 1) * SizeOf(T), 0)
    end;
  end;

  Dec(FCount, ACount);
end;

function TCircularList<T>.Extract(const Value: T): T;
var
  index: Integer;
begin
  index := IndexOf(Value);

  if index < 0 then
    Result := Default(T)
  else
  begin
    Result := Items[index];
    DoDeleteRange(index, 1, cnExtracted);
  end;
end;

function TCircularList<T>.GetCapacity: Integer;
begin
  Result := Length(FData);
end;

function TCircularList<T>.GetInternalIndex(Index: Integer): Integer;
begin
  Result := (FFirst + Index) mod Capacity;
end;

function TCircularList<T>.GetItem(Index: Integer): T;
begin
  if (Index < 0) or (Index >= FCount) then
    TList.Error(SListIndexError, Index);

  Result := FData[(FFirst + Index) mod Capacity];
end;

function TCircularList<T>.IndexOf(const Value: T): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if FComparer.Compare(FData[(FFirst + i) mod Capacity], Value) = 0 then
      Exit(i);

  Result := -1;
end;

procedure TCircularList<T>.MoveRange(S1, S2, S3, S4, D1, D2, D3, D4: Integer);
var
  tailCount, L: Integer;
  SS1, SS2, DD1, DD2: PInteger;
begin
  tailCount := S2 + 1 - S1;

  if tailCount < 0 then
    tailCount := 0;

  if S4 >= S3 then
    Inc(tailCount, S4 + 1 - S3);

  while tailCount > 0 do
  begin
    if S2 >= S1 then
    begin
      SS1 := @S1;
      SS2 := @S2;
    end
    else
    begin
      SS1 := @S3;
      SS2 := @S4;
    end;

    if D2 >= D1 then
    begin
      DD1 := @D1;
      DD2 := @D2;
    end
    else
    begin
      DD1 := @D3;
      DD2 := @D4;
    end;

    L := SS2^ + 1 - SS1^;

    if L > DD2^ + 1 - DD1^ then
      L := DD2^ + 1 - DD1^;

    System.Move(FData[SS1^], FData[DD1^], L * SizeOf(T));

    Inc(SS1^, L);
    Inc(DD1^, L);
    Dec(tailCount, L);
  end;
end;

procedure TCircularList<T>.Notify(const Item: T; Action: Generics.Collections.TCollectionNotification);
begin

end;

function TCircularList<T>.Remove(const Item: T): Integer;
begin
  Result := IndexOf(Item);
  if Result >= 0 then
    Delete(Result);
end;

procedure TCircularList<T>.SetCapacity(const Value: Integer);
var
  NewArray: ArrayOfT;
  S1, S2: Integer;
begin
  if Value >= FCount then
  begin
    SetLength(NewArray, Value);

    if FCount > 0 then
    begin
      S1 := FFirst;
      S2 := (FFirst + FCount - 1) mod Capacity;

      if S2 >= S1 then
        Move(FData[S1], NewArray[0], FCount * SizeOf(T))
      else
      begin
        Move(FData[S1], NewArray[0], (Capacity - S1) * SizeOf(T));
        Move(FData[0], NewArray[(Capacity - S1)], (S2 + 1) * SizeOf(T));
      end;
    end;

    FFirst := 0;
    FData := NewArray;
  end;
end;

procedure TCircularList<T>.SetCount(const Value: Integer);
begin
  if (Value < 0) or (Value > Capacity) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);

  if Value < Count then
    DeleteRange(Value, Count - Value);

  FCount := Value;
end;

procedure TCircularList<T>.SetItem(Index: Integer; const Value: T);
var
  oldItem: T;
  DataIndex: Integer;
begin
  if (Index < 0) or (Index >= Count) then
    raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);

  DataIndex := (FFirst + Index) mod Capacity;

  oldItem := FData[DataIndex];

  FData[DataIndex] := Value;

  Notify(oldItem, cnRemoved);
  Notify(Value, cnAdded);
end;

{ TSequenceDictionary<TKey, TValue>.TPairEnumerator }

constructor TSequenceDictionary<TKey, TValue>.TPairEnumerator.Create(ADictionary: TSequenceDictionary<TKey, TValue>);
begin
  inherited Create;
  FIndex := -1;
  FDictionary := ADictionary;
end;

function TSequenceDictionary<TKey, TValue>.TPairEnumerator.DoGetCurrent: TPair<TKey, TValue>;
begin
  Result := Self.GetCurrent;
end;

function TSequenceDictionary<TKey, TValue>.TPairEnumerator.DoMoveNext: Boolean;
begin
  Result := Self.MoveNext;
end;

function TSequenceDictionary<TKey, TValue>.TPairEnumerator.GetCurrent: TPair<TKey, TValue>;
begin
  Result.key := FDictionary.FItems[FIndex].key;
  Result.Value := FDictionary.FItems[FIndex].Value;
end;

function TSequenceDictionary<TKey, TValue>.TPairEnumerator.MoveNext: Boolean;
begin
  if FIndex + 1 < FDictionary.Count then
  begin
    Inc(FIndex);
    Result := FIndex >= 0;
  end
  else
    Result := False;
end;

{ TSequenceDictionary<TKey, TValue> }

procedure TSequenceDictionary<TKey, TValue>.Clear;
begin
  SetLength(FItems, 0);
end;

constructor TSequenceDictionary<TKey, TValue>.Create(const AComparer: IEqualityComparer<TKey>);
begin
  FComparer := AComparer;
  if FComparer = nil then
    FComparer := TEqualityComparer<TKey>.Default;
end;

constructor TSequenceDictionary<TKey, TValue>.Create;
begin
  Create(nil);
end;

function TSequenceDictionary<TKey, TValue>.DoGetEnumerator: TEnumerator < TPair < TKey, TValue >> ;
begin
  Result := TPairEnumerator.Create(Self);
end;

function TSequenceDictionary<TKey, TValue>.exists(const key: TKey): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := Low(FItems) to High(FItems) do
  begin
    if FComparer.Equals(key, FItems[i].key) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TSequenceDictionary<TKey, TValue>.IndexOf(const key: TKey): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := Low(FItems) to High(FItems) do
  begin
    if FComparer.Equals(key, FItems[i].key) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TSequenceDictionary<TKey, TValue>.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TSequenceDictionary<TKey, TValue>.GetItem(const key: TKey): TValue;
var
  i: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);

  for i := Low(FItems) to High(FItems) do
  begin
    if FComparer.Equals(key, FItems[i].key) then
    begin
      Result := FItems[i].Value;
      Break;
    end;
  end;
end;

procedure TSequenceDictionary<TKey, TValue>.SetItem(const key: TKey; const Value: TValue);
var
  i: Integer;
begin
  for i := Low(FItems) to High(FItems) do
  begin
    if FComparer.Equals(key, FItems[i].key) then
    begin
      FItems[i].Value := Value;
      Exit;
    end;
  end;

  SetLength(FItems, Length(FItems) + 1);
  FItems[ High(FItems)].key := key;
  FItems[ High(FItems)].Value := Value;
end;

{ TRefCountedWrapper<T> }

constructor TRefCountedWrapper<T>.Create(_object: T);
begin
  inherited Create;
  FInstance := _object;
end;

destructor TRefCountedWrapper<T>.Destroy;
begin
  FInstance.Free;
  inherited;
end;

{ TARCWrapper<T> }

constructor TARCWrapper<T>.Create(_obj: T);
begin
  inherited Create;
  FObj := _obj;
end;

destructor TARCWrapper<T>.Destroy;
begin
  FObj.Free;
  inherited;
end;

{ TSingletonedDelegatedComparer<T> }

function TSingletonedDelegatedComparer<T>.Compare(const left, right: T): Integer;
begin
  Result := FCompareProc(left, right);
end;

constructor TSingletonedDelegatedComparer<T>.Create(const ACompareProc: TComparison<T>);
begin
  inherited Create;
  FCompareProc := ACompareProc;
end;

class function TSingletonedDelegatedComparer<T>.GetInstance(const ACompareProc: TComparison<T>): IComparer<T>;
begin
  if not Assigned(Self.FSingleton) then
    Self.FSingleton := TSingletonedDelegatedComparer<T>.Create(ACompareProc);
  Result := FSingleton;
end;

function TSingletonedDelegatedComparer<T>._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TSingletonedDelegatedComparer<T>._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

{ TKeyValueList<TKey, TValue> }

constructor TKeyValueList<TKey, TValue>.Create;
begin
  Create(TComparer<TKey>.Default);
end;

procedure TKeyValueList<TKey, TValue>.Add(const AKey: TKey; AValue: TValue);
var
  r: TPair<TKey,TValue>;
begin
  r.Key := AKey;
  r.Value := AValue;
  FPairs.Add(r);
end;

constructor TKeyValueList<TKey, TValue>.Create(const AComparer: IComparer<TKey>);
begin
  inherited Create;
  FComparer := AComparer;
  if FComparer = nil then
    FComparer := TComparer<TKey>.Default;
  FPairs := TList < TPair < TKey, TValue >> .Create;
end;

destructor TKeyValueList<TKey, TValue>.Destroy;
begin
  FPairs.Free;
  inherited;
end;

function TKeyValueList<TKey, TValue>.exists(const AKey: TKey): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FPairs.Count - 1 do
    if FComparer.Compare(AKey, FPairs[i].key) = 0 then
    begin
      Result := True;
      Break;
    end;
end;

function TKeyValueList<TKey, TValue>.getValue(const AKey: TKey): TValue;
var
  i: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  for i := 0 to FPairs.Count - 1 do
    with FPairs[i] do
      if FComparer.Compare(AKey, key) = 0 then
      begin
        Result := Value;
        Break;
      end;
end;

function TKeyValueList<TKey, TValue>.getValueEx(const AKey: TKey; var AValue: TValue): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FPairs.Count - 1 do
    with FPairs[i] do
      if FComparer.Compare(AKey, key) = 0 then
      begin
        AValue := Value;
        Result := True;
        Break;
      end;
end;

function TKeyValueList<TKey, TValue>.Remove(const AKey: TKey): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FPairs.Count - 1 do
    with FPairs[i] do
      if FComparer.Compare(AKey, key) = 0 then
      begin
        FPairs.Delete(i);
        Result := True;
        Break;
      end;
end;

procedure TKeyValueList<TKey, TValue>.setValue(const AKey: TKey; const AValue: TValue);
var
  i: Integer;
  Item: TPair<TKey, TValue>;
begin
  Item.key := AKey;
  Item.Value := AValue;

  for i := 0 to FPairs.Count - 1 do
    with FPairs[i] do
      if FComparer.Compare(AKey, key) = 0 then
      begin
        FPairs[i] := Item;
        Exit;
      end;

  FPairs.Add(Item);
end;

{ TCaseUnsensitiveUnicodeStringComparer }

function TCaseUnsensitiveUnicodeStringComparer.Compare(const left, right: UnicodeString): Integer;
begin
  Result := UStrCompare(left, right, False);
end;

class function TCaseUnsensitiveUnicodeStringComparer.GetInstance: IComparer<UnicodeString>;
begin
  if not Assigned(FSingleton) then
    FSingleton := TCaseUnsensitiveUnicodeStringComparer.Create;

  Result := FSingleton;
end;

{ TCaseUnsensitiveRawByteStringComparer }

function TCaseUnsensitiveRawByteStringComparer.Compare(const left, right: RawByteString): Integer;
begin
  Result := RBStrCompare(left, right, False);
end;

class function TCaseUnsensitiveRawByteStringComparer.GetInstance: IComparer<RawByteString>;
begin
  if not Assigned(FSingleton) then
    FSingleton := TCaseUnsensitiveRawByteStringComparer.Create;

  Result := FSingleton;
end;

{ TThreadListEx<T> }

constructor TThreadListEx<T>.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
end;

destructor TThreadListEx<T>.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TThreadListEx<T>.LockList;
begin
  EnterCriticalSection(FLock);
end;

procedure TThreadListEx<T>.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

{ THashList<TKey, TValue> }

procedure THashList<TKey, TValue>.Add(const _Value: TValue);
var
  LKey: TKey;
begin
  LKey := FKeyGetter(_Value);
  FDict.Add(LKey, FItems.Count);
  FItems.Add(_Value);
end;

procedure THashList<TKey, TValue>.Clear;
begin
  FDict.Clear;
  FItems.Clear;
end;

constructor THashList<TKey, TValue>.Create(_KeyGetter: TFunc<TValue, TKey>);
begin
  inherited Create;
  FKeyGetter := _KeyGetter;
  FItems := TList<TValue>.Create;
  FDict := TDictionary<TKey, Integer>.Create;
end;

destructor THashList<TKey, TValue>.Destroy;
begin
  FreeAndNil(FItems);
  FreeAndNil(FDict);
  inherited;
end;

function THashList<TKey, TValue>.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function THashList<TKey, TValue>.Remove(const _Key: TKey): Boolean;
var
  LIdx: Integer;
begin
  Result := FDict.TryGetValue(_Key, LIdx);
  if Result then
  begin
    if LIdx <> FItems.Count - 1 then
    begin
      FItems.Exchange(FItems.Count - 1, LIdx);
      FDict.AddOrSetValue(FKeyGetter(FItems.List[LIdx]), LIdx);
      //FDict.AddOrSetValue(FKeyGetter(FItems.List[LIdx]), FItems.Count - 1);
    end;
    FItems.Delete(FItems.Count - 1);
    FDict.Remove(_Key);
  end;
end;

function THashList<TKey, TValue>.TryAdd(const _Value: TValue): Boolean;
var
  LKey: TKey;
begin
  LKey := FKeyGetter(_Value);
  Result := FDict.TryAdd(LKey, FItems.Count);
  if Result then
    FItems.Add(_Value);
end;

function THashList<TKey, TValue>.TryGetValue(const _Key: TKey; out _Value: TValue): Boolean;
var
  LIdx: Integer;
begin
  Result := FDict.TryGetValue(_Key, LIdx);
  if Result then
    _Value := FItems.List[LIdx]
  else
    _Value := Default(TValue);
end;

end.
