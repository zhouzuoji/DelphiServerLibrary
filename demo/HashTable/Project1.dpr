program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Windows,
  DSLUtils,
  DSLHashTable;

function StringComparer(const left, right: string): Integer;
begin
  Result := UStrCompare(left, right);
end;

function StringHash(const key: string): UInt32;
begin
  Result := ELFHash(PAnsiChar(Pointer(key)), Length(key) * 2);
end;

procedure TestStringHash;
var
  table: THashTable<string, Integer>;
  iterator: TIterator<string, Integer>;
  i, len: Integer;
  a, b: array of Integer;
begin
  SetLength(a, 2);
  b := a;
  a := nil;
  Writeln(Length(b));
  table := THashTable<string, Integer>.Create(10000, nil);

  try
    table['周佐吉'] := 21;
    table['周欣然'] := 2;

    for i := 1 to 1000 do
    begin
      len := 10 + Random(10);
      table[RandomAlphaDigitStringW(len)] := len;
    end;

    Writeln(table['周欣然']);
    Writeln(table['周佐吉']);

    iterator.SetTable(table);

    while not iterator.eof do
    begin
      Writeln(iterator.key, ' ', iterator.value);
      iterator.next;
    end;

    Writeln(table.conflict);
  finally
    table.Free;
  end;
end;

begin
  RandSeed := GetTickCount;
  Randomize;
  ReportMemoryLeaksOnShutdown := True;
  try
    TestStringHash;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  Readln;
end.
