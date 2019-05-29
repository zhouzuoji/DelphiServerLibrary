unit DSLCore;

interface

uses
  SysUtils, Classes, TypInfo;

type
  TdslTypeInfo<T> = class
  private
    class var tvIsManagedType: Boolean;
  public
    type TPointer = ^T;
  public
    class constructor Create;
    class function IsManagedType: Boolean; static; inline;
  end;

function TypeIsManaged(avTypeInfo: PTypeInfo): Boolean;

implementation

function TypeIsManaged(avTypeInfo: PTypeInfo): Boolean;
var
  lvTypeData: PTypeData;
begin
  if Assigned(avTypeInfo) then
  begin
    case avTypeInfo.Kind of
      tkUnknown, tkInteger, tkInt64, tkChar, tkWChar, tkEnumeration, tkFloat, tkSet,
        tkMethod, tkClass, tkClassRef, tkPointer, tkProcedure: Result := False;
      tkRecord:
        begin
          lvTypeData := GetTypeData(avTypeInfo);
          Result := Assigned(lvTypeData) and (lvTypeData.ManagedFldCount>0);
        end;
      tkArray:
        begin
          lvTypeData := GetTypeData(avTypeInfo);
          Result := Assigned(lvTypeData) and TypeIsManaged(lvTypeData.ArrayData.ElType^);
        end;
      else
        Result := True;
    end;
  end
  else
    Result := False;
end;

{ TdslTypeInfo<T> }

class constructor TdslTypeInfo<T>.Create;
begin
  tvIsManagedType := TypeIsManaged(TypeInfo(T));
end;

class function TdslTypeInfo<T>.IsManagedType: Boolean;
begin
  Result := tvIsManagedType;
end;

end.
