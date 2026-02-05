unit DSLSaxConsoleWriter;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, DSLUtils, DSLByteStr, DSLSax;

type
  TSaxConsoleWriter = class(TInterfacedObject, ISaxHandler)
    procedure OnNumber(const _Ctx: PSaxContext; const _Node: TSaxNode; const _Value: TNumber);
    function OnBeforeString(const _Ctx: PSaxContext; const _Node: TSaxNode): Boolean;
    procedure OnString(const _Ctx: PSaxContext; const _Node: TSaxNode; const _Value: TByteStrBuilder);
    procedure OnNull(const _Ctx: PSaxContext; const _Node: TSaxNode);
    function OnArray(const _Ctx: PSaxContext; const _Node: TSaxNode; _SizeHint: Integer): Boolean;
    function OnElem(const _Ctx: PSaxContext; const _Node: TSaxNode; _Idx: Integer): TSaxNode;
    function OnObject(const _Ctx: PSaxContext; const _Node: TSaxNode; _SizeHint: Integer): Boolean;
    function OnField(const _Ctx: PSaxContext; const _Node: TSaxNode; _Idx: Integer; const _FieldName: TByteStrBuilder): TSaxNode;
  end;

implementation

{ TSaxConsoleWriter }

function TSaxConsoleWriter.OnArray(const _Ctx: PSaxContext; const _Node: TSaxNode; _SizeHint: Integer): Boolean;
begin
  Writeln('OnArray depth=', _Ctx.Depth, ', path=', _Ctx.Path.Clone);
  Result := True;
end;

function TSaxConsoleWriter.OnBeforeString(const _Ctx: PSaxContext; const _Node: TSaxNode): Boolean;
begin
  Result := True;
end;

function TSaxConsoleWriter.OnElem(const _Ctx: PSaxContext; const _Node: TSaxNode; _Idx: Integer): TSaxNode;
begin
  Result.Addr := Pointer(1);
end;

function TSaxConsoleWriter.OnField(const _Ctx: PSaxContext; const _Node: TSaxNode; _Idx: Integer;
  const _FieldName: TByteStrBuilder): TSaxNode;
begin
  Result.Addr := Pointer(1);
end;

procedure TSaxConsoleWriter.OnNull(const _Ctx: PSaxContext; const _Node: TSaxNode);
begin
  Writeln('OnNull depth=', _Ctx.Depth, ', path=', _Ctx.Path.Clone);
end;

procedure TSaxConsoleWriter.OnNumber(const _Ctx: PSaxContext; const _Node: TSaxNode; const _Value: TNumber);
begin
  Writeln('OnNumber depth=', _Ctx.Depth, ', ', _Value.expr, ', path=', _Ctx.Path.Clone);
end;

function TSaxConsoleWriter.OnObject(const _Ctx: PSaxContext; const _Node: TSaxNode; _SizeHint: Integer): Boolean;
begin
   Writeln('OnObject depth=', _Ctx.Depth, ', path=', _Ctx.Path.Clone);
   Result := False;
end;

procedure TSaxConsoleWriter.OnString(const _Ctx: PSaxContext; const _Node: TSaxNode; const _Value: TByteStrBuilder);
begin
  Writeln('OnString depth=', _Ctx.Depth, ', value=', _Value.Once, ', path=', _Ctx.Path.Clone);
end;

end.
