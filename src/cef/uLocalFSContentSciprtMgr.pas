unit uLocalFSContentSciprtMgr;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  uContentScriptMgr;

type
  TLocalFSContentSciprtMgr = class(TInterfacedObject, IContentScriptMgr)
  private
    FRootDir: string;
    FManifest: TContentScriptManifest;
    procedure LoadManifest;
  public
    constructor Create(const _RootDir: string);
    function GetScripts(const _Url: string; _IsMainFrame: Boolean): TArray<string>;
  end;

implementation

uses
  superobject,
  DSLUtils,
  uJsonConvert;

{ TLocalFSContentSciprtMgr }

constructor TLocalFSContentSciprtMgr.Create(const _RootDir: string);
begin
  inherited Create;
  FRootDir := IncludeTrailingPathDelimiter(_RootDir);
  LoadManifest;
end;

function TLocalFSContentSciprtMgr.GetScripts(const _Url: string; _IsMainFrame: Boolean): TArray<string>;
var
  LRule: TContentScriptRule;
  LUrl, LPattern: string;
  LFound: Boolean;
  i, n:  Integer;
begin
  Result := nil;
  LUrl := _Url.ToLower;
  for LRule in FManifest.content_scripts do
  begin
    if not _IsMainFrame and not LRule.all_frames then
      Continue;
    LFound := False;
    for LPattern in LRule.matches do
    begin
      if Pos(LPattern, LUrl) > 0 then
      begin
        LFound := True;
        Break;
      end;
    end;
    if LFound then
    begin
      n := Length(Result);
      SetLength(Result, n + LRule.js.Count);
      for i := 0 to LRule.js.Count - 1 do
        Result[n + i] := UTF8ToString(LoadStrFromFile(FRootDir + LRule.js[i]));
    end;
  end;
end;

procedure TLocalFSContentSciprtMgr.LoadManifest;
var
  LRule: TContentScriptRule;
  i: Integer;
begin
  FreeAndNil(FManifest);
  TJSONDeserializer.FromJSON(SO(UTF8ToString(LoadStrFromFile(FRootDir + 'manifest.json'))), FManifest);
  for LRule in FManifest.content_scripts do
  begin
    for i := 0 to LRule.matches.Count - 1 do
      LRule.matches[i] := StringReplace(LRule.matches[i], '*', '', [rfReplaceAll]).ToLower;
  end;
end;

end.
