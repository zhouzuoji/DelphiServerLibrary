{$B-,C+,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,U-,V+,W-,X+,Z1}
{$O+}   // optimization on
{$T+}   // typed pointers on
{$POINTERMATH ON}
unit DSLSax;

interface

uses
  SysUtils,
  Classes,
  DSLUtils,
  DSLByteStr;

type
  TDeserOptions = (
    doNoUnescape,   // don't unescape escaped strings
    doPlaceHolder
  );

  PSaxContext = ^TSaxContext;
  TSaxContext = record
    Options: TDeserOptions;
    Deepest: Integer;
    Depth: Integer;
    ChildIndex: Integer;
    RawText: PAnsiChar;
    RawTextLen: Integer;
    Path: TByteStrBuilder;
  end;

  TSaxNode = record
    Addr, Trait: Pointer;
  end;

  ISaxHandler = interface
    ['{BCBE4FD9-1F0B-48E2-9ED1-4451AAB7BC5E}']
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

end.
