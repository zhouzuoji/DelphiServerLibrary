unit uContentScriptMgr;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections;

type
  TContentScriptRule = class
  public
    matches: TList<string>;
    js: TList<string>;
    run_at: string;
    all_frames: Boolean;
  end;

  TContentScriptManifest = class
  public
    content_scripts: TObjectList<TContentScriptRule>;
  end;

  IContentScriptMgr = interface
    function GetScripts(const _Url: string; _IsMainFrame: Boolean): TArray<string>;
  end;

implementation

end.
