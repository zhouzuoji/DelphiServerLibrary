unit uHashTest;

interface

uses
  SysUtils, Classes, Windows, RTLConsts, AnsiStrings, Generics.Collections, Generics.Defaults,
  TypInfo, Rtti, GArrayUtils, GHashMap;


procedure TestHash;

procedure Test_gHashMap;

implementation

function Int64Hash(buf: PAnsiChar; len: TCollectionSize): Int64;
begin
  Result := PInt64(buf)^;
end;

type
  TItemStruct = packed record
    ItemID: Integer;
    UserID: Integer;
  end;

procedure TestHash;
const
  CAPACITY = 2807303;
var
  buckets: TList<Integer>;
  i, lvUserCount, lvItemCount, lvUserId, lvItemId, j, p, q: Integer;
  lvHash: Int64;
  lvUserIdHash: TDictionary<Integer, Integer>;
  lvItemIdHash: TDictionary<Integer, Integer>;
  lvRec: TItemStruct;
begin
  buckets := TList<Integer>.Create;
  lvUserIdHash := TDictionary<Integer, Integer>.Create;
  lvItemIdHash := TDictionary<Integer, Integer>.Create;
  lvUserCount := 0;
  try
    buckets.Count := CAPACITY;
    for i := 0 to buckets.Count-1 do
      buckets[i] := 0;
    while lvUserCount < 10000 do
    begin
      lvUserId := Random($7fffffff);
      if lvUserIdHash.ContainsKey(lvUserId) then Continue;
      Inc(lvUserCount);
      lvItemIdHash.Clear;
      lvItemCount := 0;
      while lvItemCount < 200 do
      begin
        lvItemId := Random(65536);
        if lvItemIdHash.ContainsKey(lvItemId) then Continue;
        Inc(lvItemCount);
        lvRec.UserID := lvUserId;
        lvRec.ItemID := lvItemId;
        lvHash := Int64Hash(@lvRec, SizeOf(lvRec));
        buckets[lvHash mod buckets.Count] := buckets[lvHash mod buckets.Count] + 1;
      end;
    end;
    buckets.Sort;
    for i := 1 to buckets[buckets.Count-1] do
      Writeln(Format('first %d: %d', [i, buckets.IndexOf(i)]));

    i := 1;
    p := buckets.IndexOf(1);
    while i < buckets[buckets.Count-1] do
    begin
      q := -1;
      j := i;
      while q=-1 do
      begin
        Inc(j);
        q := buckets.IndexOf(j);
      end;
      Writeln(i, ': ', q-p, ', %', FormatFloat('0.000', (q-p)*i*100/2000000));
      i := j;
      p := q;
    end;
    Writeln(i, ': ', buckets.Count-p, ', %', FormatFloat('0.000', (buckets.Count-p)*i*100/2000000));

    for i := buckets.Count - 1 downto buckets.Count - 1 - 20 do
      Writeln('conflict: ', buckets[i]);
  finally
    lvUserIdHash.Free;
    lvItemIdHash.Free;
    buckets.Free;
  end;
end;

function RandomString: string;
var
  i, lvLen: Integer;
begin
  lvLen := Random(50) + 10;
  SetLength(Result, lvLen);
  for i := 0 to lvLen-1 do
    PChar(Pointer(Result))[i] := Char(65+Random(26));
end;

procedure Test_gHashMap;
var
  lvMap: TgHashMap<string, Integer>;
  lvDictionary: TDictionary<string, Integer>;
  lvItem: TPair<string, Integer>;
  lvStrings: array of TPair<string, Integer>;
  i: Integer;
  lvTick: DWORD;
begin
  SetLength(lvStrings, 1000000);
  for i := Low(lvStrings) to High(lvStrings) do
  begin
    lvStrings[i].Key := RandomString;
    lvStrings[i].Value := Random(MaxInt);
  end;

  lvMap := TgHashMap<string, Integer>.Create(Length(lvStrings));
  lvDictionary := TDictionary<string, Integer>.Create(Length(lvStrings));
  try
    lvTick := GetTickCount;
    for i := Low(lvStrings) to High(lvStrings) do
    begin
      lvMap.Add(lvStrings[i].Key, lvStrings[i].Value);
    end;
    Writeln('TgHashMap insert: ', GetTickCount-lvTick, 'ms');

    lvTick := GetTickCount;
    for i := Low(lvStrings) to High(lvStrings) do
    begin
      lvMap.ContainsKey(lvStrings[i].Key);
    end;
    Writeln('TgHashMap search: ', GetTickCount-lvTick, 'ms');

    lvMap.Add('zhouzuoji', 34);
    lvMap.Add('Zhouzuoji', 43);
    Writeln(lvMap.Items['zhouzuoji']);
    Writeln(lvMap.Items['Zhouzuoji']);

    lvTick := GetTickCount;
    for i := Low(lvStrings) to High(lvStrings) do
    begin
      lvMap.Remove(lvStrings[i].Key);
    end;
    Writeln('TgHashMap remove: ', GetTickCount-lvTick, 'ms');

    lvTick := GetTickCount;
    for i := Low(lvStrings) to High(lvStrings) do
    begin
      lvDictionary.AddOrSetValue(lvStrings[i].Key, lvStrings[i].Value);
    end;
    Writeln('TDictionary insert: ', GetTickCount-lvTick, 'ms');

    lvTick := GetTickCount;
    for i := Low(lvStrings) to High(lvStrings) do
    begin
      lvDictionary.ContainsKey(lvStrings[i].Key);
    end;
    Writeln('TDictionary search: ', GetTickCount-lvTick, 'ms');

    lvTick := GetTickCount;
    for i := Low(lvStrings) to High(lvStrings) do
    begin
      lvDictionary.Remove(lvStrings[i].Key);
    end;
    Writeln('TDictionary remove: ', GetTickCount-lvTick, 'ms');

    Writeln('TDictionary ', lvDictionary.Count, ' items');
    Writeln(lvMap.Capacity, ', ', lvMap.Count, ', ', lvMap.Collision);
    lvMap.Remove('zhouzuoji');
    lvMap.Remove('Zhouzuoji');
    Assert(lvMap.Count=lvDictionary.Count);
    for lvItem in lvMap do
    begin
      Assert(lvDictionary[lvItem.Key]=lvItem.Value);
    end;
  finally
    lvMap.Free;
    lvDictionary.Free;
  end;
end;

end.
