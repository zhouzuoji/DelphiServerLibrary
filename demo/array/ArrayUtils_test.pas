unit ArrayUtils_test;

interface

uses
  SysUtils, Classes, GArrayUtils, GCircularList, ConsoleUtils;

procedure Test_StringDynArray;
procedure Test_CircularList;

function Test_CircularListShift: Boolean;

implementation

procedure Test_StringDynArray;
var
  arr, arr2, sum: TDynArray<string>;
  i: Integer;
begin
  for i := 1 to 10 do
    arr.Add(IntToStr(i));

  arr.Insert(5, ['11', '12', '13']);

  arr.Delete(arr.Count - 2, 2);

  for i := 0 to arr.Count - 1 do
    Writeln(arr[i]);

  arr2.Add('one');
  arr2.Add(['two', 'three']);

  sum := arr + arr2;

  for i := 0 to sum.Count - 1 do
    Writeln(sum[i]);
end;

procedure Test_CircularList;
var
  i: Integer;
  strs: TgCircularList<string>;
  ints: TgCircularList<Integer>;
begin
  WriteSeparator('TgCircularList<string>');

  for i := 1 to 16 do
    strs.Add(IntToStr(i));

  //strs.Delete(1,3);

  strs.Delete(0, 8);

  strs.Insert(strs.Count - 2, ['ins1', 'ins2', 'ins3', 'ins4', 'ins5']);

  strs.Add('17');

  for i := 17 to 32 do
    strs.Add(IntToStr(i));

  strs.Delete(6, 7);

  for i := 0 to strs.Count - 1 do
    Writeln(strs[i]);

  WriteSeparator('TgCircularList<Integer>');

  for i := 1 to 16 do
    ints.Add(i);

  ints.Delete(1,3);

  ints.Delete(0, 5);

  ints.Add(17);

  for i := 17 to 32 do
    ints.Add(i);

  ints.Delete(6, 7);

  for i := 0 to ints.Count - 1 do
    Writeln(ints[i]);
end;

function Test_CircularListShift: Boolean;
var
  i: Integer;
  strlst: TgCircularList<string>;
begin
  WriteSeparator('Test_CircularListShift<string>');

  for i := 1 to 16 do
    strlst.Add(IntToStr(i));
  Writeln('capacity: ', strlst.Capacity, ', size: ', strlst.Count);
  for i := 0 to strlst.Count - 1 do
    Writeln(strlst[i]);

  strlst.BaseIndex := strlst.BaseIndex + 2;
  for i := 0 to strlst.Count - 1 do
    Writeln(strlst[i]);

  strlst.BaseIndex := strlst.BaseIndex + 3;
  for i := 0 to strlst.Count - 1 do
    Writeln(strlst[i]);

  strlst.BaseIndex := strlst.BaseIndex - 12;
  for i := 0 to strlst.Count - 1 do
    Writeln(strlst[i]);

  strlst.BaseIndex := strlst.BaseIndex + 2;
  for i := 0 to strlst.Count - 1 do
    Writeln(strlst[i]);

  Result := True;
end;

end.
