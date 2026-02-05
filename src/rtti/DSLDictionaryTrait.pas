unit DSLDictionaryTrait;

{$I ../DSLDefine.inc}

interface

uses
  SysUtils, Classes, Generics.Collections, TypInfo, DSLUtils, DSLTypeTrait;

type

  // TDictionary<K,V> or TObjectDictionary<K,V>
  TDictionaryTrait = class(TCustomDictTrait)
  private
    FMetaClass: TClass;
    FKey: TDictionaryTrait;
    FValue: TCustomTypeTrait;
    TCapCtor: TCtorWithCapacity;
    TObjDictCtor: TObjectDictCtor;
    FDefCtor: TDefaultConstructor;
    FCountOffset: NativeInt;
    FIsObjectDict: Boolean;
  private
    procedure CheckProperties(_t: TObject; _RttiCtx: PRttiContext);
    procedure CheckMethods(_t: TObject; _RttiCtx: PRttiContext);
  protected
    procedure Init(_RttiCtx: PRttiContext); override;
    procedure FromNull(var _Addr); override;
  public
    function CreateObject: TObject;
    function GetLen(const _Dict): Integer; override;
    procedure Add(var _Dict; const _Key; const _Value); override;
    procedure Remove(var _Dict; const _Key); override;
    procedure Clear(var _Dict); override;
    function TryGetValue(const _Dict, _Key; var _Value): Boolean; override;
    procedure AddOrSetValue(var _Dict; const _Key, _Value); override;
    function TryAdd(var _Dict;  const _Key, _Value): Boolean; override;
    function ContainsKey(const _Dict, _Key): Boolean; override;
    function ContainsValue(const _Value): Boolean; override;
    property MetaClass: TClass read FMetaClass;
    property IsObjectDict: Boolean read FIsObjectDict;
  end;

implementation

{ TDictionaryTrait }

procedure TDictionaryTrait.Add(var _Dict; const _Key, _Value);
begin
  inherited;

end;

procedure TDictionaryTrait.AddOrSetValue(var _Dict; const _Key, _Value);
begin
  inherited;

end;

procedure TDictionaryTrait.CheckMethods(_t: TObject; _RttiCtx: PRttiContext);
begin

end;

procedure TDictionaryTrait.CheckProperties(_t: TObject; _RttiCtx: PRttiContext);
begin

end;

procedure TDictionaryTrait.Clear(var _Dict);
begin
  inherited;

end;

function TDictionaryTrait.ContainsKey(const _Dict, _Key): Boolean;
begin

end;

function TDictionaryTrait.ContainsValue(const _Value): Boolean;
begin

end;

function TDictionaryTrait.CreateObject: TObject;
begin

end;

procedure TDictionaryTrait.FromNull(var _Addr);
begin
  Self.Clear(_Addr);
end;

function TDictionaryTrait.GetLen(const _Dict): Integer;
begin

end;

procedure TDictionaryTrait.Init(_RttiCtx: PRttiContext);
begin
  inherited;

end;

procedure TDictionaryTrait.Remove(var _Dict; const _Key);
begin
  inherited;

end;

function TDictionaryTrait.TryAdd(var _Dict; const _Key, _Value): Boolean;
begin

end;

function TDictionaryTrait.TryGetValue(const _Dict, _Key; var _Value): Boolean;
begin

end;

end.
