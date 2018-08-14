program CircularList;

{$APPTYPE CONSOLE}

uses
  SysUtils, DSLUtils, ActiveX, Variants, ComObj, DSLGenerics;

procedure test;
var
  list: TCircularList<Integer>;
  i: Integer;
begin
  list := TCircularList<Integer>.Create(100);

  try
    for i := 0 to list.capacity + 89 do
      list.add(i);

    list.DeleteRange(20, 41);
    //list.delete(20);

    list.capacity := 150;

    for i := 0 to list.count - 1 do
    begin
      Write(', ', list[i]);

      if (i > 0) and (i mod 10 = 0) then
        Writeln;
    end;
  finally
    list.Free;
  end;
end;

procedure SequenceDictionary_test;
var
  dictionary: TSequenceDictionary<string, Variant>;
begin
  dictionary := TSequenceDictionary<string, Variant>.Create;
  dictionary['age'] := 30;
  dictionary['name'] := 'ÖÜ×ô¼ª';
  dictionary['sex'] := 'ÄÐ';
  dictionary['birthday'] := EncodeDate(1985, 9, 2);

  Writeln(dictionary['age']);
  Writeln(dictionary['name']);
  Writeln(dictionary['sex']);
  Writeln(dictionary['birthday']);
  dictionary.Free;
end;

procedure PropDictionary_test;
var
  dictionary: Variant;
  intf: IDispatch;
  obj: TDispProperties;
begin
  obj := TDispProperties.Create;
  intf := obj;
  dictionary := intf;
  dictionary.age := 30;
  dictionary.name := 'ÖÜ×ô¼ª';
  dictionary.sex := 'ÄÐ';
  dictionary.birthday := EncodeDate(1985, 9, 2);

  Writeln(dictionary.age);
  Writeln(dictionary.name);
  Writeln(WideChar(Word(dictionary.sex)));
  Writeln(DateTimeToStr(dictionary.birthday));
end;

begin
  CoInitialize(nil);
  ReportMemoryLeaksOnShutdown := True;

  try
    //test;
    //SequenceDictionary_test;
    PropDictionary_test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  CoUninitialize;
  Readln;
end.
