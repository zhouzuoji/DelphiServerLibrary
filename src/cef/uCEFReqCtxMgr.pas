unit uCEFReqCtxMgr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Contnrs, SyncObjs, Generics.Collections, Generics.Defaults,
  superobject, uCEFWinControl, uCEFWindowParent, uCEFChromiumCore, uCEFChromium, uCEFRequest, uCefStringMultimap,
  uCEFInterfaces, uCEFTypes, uCEFConstants, uCEFApplication, uCefRequestContext, uCEFTask;

type
  TCEFReqCtxMgr = class
  private
    FBaseDir, FConfigFileName: string;
    FSettings, FSites, FProfiles, FTmpProfiles: ISuperObject;
    FProfileNames: TList<string>;
    FContexts: TDictionary<string, ICefRequestContext>;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure ExtractTempContext(const _Name: string);
    procedure AddContext(const _Name: string; const _Ctx: ICefRequestContext);
    function FindProfileName(const site, key: string): string;
    function GetProfileName(const site, key: string): string;
    function RequireTmpProfileName: string;
    procedure GetOrCreateContext(const ProfileDir: string; cb: TProc<ICefRequestContext>);
    procedure _FindContext(const site, key: string; cb: TProc<ICefRequestContext>);
    procedure _AssociateContext(const site, key: string; ctx: ICefRequestContext);
    procedure _ReleaseTempContext(_Ctx: ICefRequestContext);
  public
    constructor Create(const _BaseDir: string; const _ConfigFileName: string = 'profiles.json');
    destructor Destroy; override;
    class function GenerateProfileName: string; static;
    procedure RequireContext(const site, key: string; cb: TProc<ICefRequestContext>);
    procedure FindContext(const site, key: string; cb: TProc<ICefRequestContext>);
    procedure AssociateContext(const site, key: string; ctx: ICefRequestContext; cb: TProc<Boolean>);
    procedure NewTempContext(cb: TProc<ICefRequestContext>);
    procedure ReleaseTempContext(_Ctx: ICefRequestContext);
  end;

procedure DumpCachePath(_Ctx: ICefRequestContext);

implementation

uses
  DSLVclApp,
  uCEFUtilFunctions;

procedure DumpCachePath(_Ctx: ICefRequestContext);
begin
  OutputDebugString(PChar(Format('GetCachePath in current thread: %p, %s', [Pointer(_Ctx), _Ctx.CachePath])));
  OutputDebugString(PChar(Format('GetCachePath in current thread: %p, %s', [Pointer(_Ctx), _Ctx.CachePath])));
  TCefFastTask.New(TID_UI, procedure
    begin
      OutputDebugString(PChar(Format('GetCachePath in TID_UI: %p, %s', [Pointer(_Ctx), _Ctx.CachePath])));
    end);
  TCefFastTask.New(TID_IO, procedure
    begin
      OutputDebugString(PChar(Format('GetCachePath in TID_IO: %p, %s', [Pointer(_Ctx), _Ctx.CachePath])));
    end);
  ExecOnMainThread(procedure
  begin
    OutputDebugString(PChar(Format('GetCachePath in MainThread: %p, %s', [Pointer(_Ctx), _Ctx.CachePath])));
  end);
end;

function forceProperty(const obj: ISuperObject; const key: string; t: TSuperType): ISuperObject;
begin
  Result := obj[key];
  if (Result = nil) or not Result.IsType(t) then
  begin
    Result := TSuperObject.Create(t);
    obj[key] := Result;
  end;
end;

{ TCEFReqCtxMgr }

procedure TCEFReqCtxMgr.AddContext(const _Name: string; const _Ctx: ICefRequestContext);
var
  joProfile: ISuperObject;
begin
  if FProfiles[_Name] = nil then
  begin
    FProfileNames.Add(_Name);
    joProfile := TSuperObject.Create(stObject);
    joProfile.S['dir'] := _Name;
    joProfile.S['createTime'] := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
    FProfiles.O[_Name] := joProfile;
    if _Ctx <> nil then
      FContexts.AddOrSetValue(_Name, _Ctx);
  end;
end;

procedure TCEFReqCtxMgr._AssociateContext(const site, key: string; ctx: ICefRequestContext);
var
  LProfileName: string;
  joSite: ISuperObject;
  joKeys: ISuperObject;
  joProfiles: ISuperObject;
begin
  //OutputDebugString(PChar(Format('_AssociateContext: %p, %s', [Pointer(ctx), ctx.CachePath])));
  LProfileName := ExtractFileName(ctx.CachePath);
  ExtractTempContext(LProfileName);
  AddContext(LProfileName, ctx);
  joSite := forceProperty(FSites, site, stObject);
  joKeys := forceProperty(joSite, 'keys', stObject);
  joProfiles := forceProperty(joSite, 'profiles', stObject);
  joProfiles.S[LProfileName] := key;
  joKeys.S[key] := LProfileName;
  SaveSettings;
end;

procedure TCEFReqCtxMgr.AssociateContext(const site, key: string; ctx: ICefRequestContext; cb: TProc<Boolean>);
begin
  ExecOnMainThread(
    procedure
    begin
      _AssociateContext(site, key, ctx);
    end);
end;

constructor TCEFReqCtxMgr.Create(const _BaseDir, _ConfigFileName: string);
begin
  inherited Create;
  FBaseDir := IncludeTrailingPathDelimiter(_BaseDir);
  FConfigFileName := _ConfigFileName;
  FProfileNames := TList<string>.Create;
  FContexts := TDictionary<string, ICefRequestContext>.Create;
  LoadSettings;
end;

destructor TCEFReqCtxMgr.Destroy;
begin
  FProfileNames.Free;
  FContexts.Free;
  inherited;
end;

procedure TCEFReqCtxMgr.ExtractTempContext(const _Name: string);
var
  joProfile: ISuperObject;
  i: Integer;
  arr: TSuperArray;
begin
  arr := FTmpProfiles.AsArray;
  for i := 0 to arr.Length - 1 do
  begin
    joProfile := arr[i];
    if joProfile.S['dir'] = _Name then
    begin
      arr.Delete(i);
      Exit;
    end;
  end;
end;

procedure TCEFReqCtxMgr._FindContext(const site, key: string; cb: TProc<ICefRequestContext>);
var
  LName: string;
begin
  LName := FindProfileName(site, key);
  if LName = '' then
    cb(nil)
  else
    GetOrCreateContext(LName, cb);
end;

procedure TCEFReqCtxMgr.FindContext(const site, key: string; cb: TProc<ICefRequestContext>);
begin
  ExecOnMainThread(
    procedure
    begin
      _FindContext(site, key, cb);
    end);
end;

function TCEFReqCtxMgr.FindProfileName(const site, key: string): string;
var
  joSite: ISuperObject;
  joKeys: ISuperObject;
begin
  joSite := forceProperty(FSites, site, stObject);
  joKeys := forceProperty(joSite, 'keys', stObject);
  Result := joKeys.S[key];
end;

class function TCEFReqCtxMgr.GenerateProfileName: string;
var
  i: Integer;
begin
  SetLength(Result, 8);
  for i := 1 to Length(Result) do
    PChar(Pointer(Result))[i-1] := Char(97 + Random(26));
  Result := Result + FormatDateTime('_yyyymmddhhmmss', Now);
end;

procedure TCEFReqCtxMgr.GetOrCreateContext(const ProfileDir: string; cb: TProc<ICefRequestContext>);
var
  LCtx: ICefRequestContext;
begin
  if FContexts.TryGetValue(ProfileDir, LCtx) then
    cb(LCtx)
  else if ProfileDir = 'default' then
    cb(TCefRequestContextRef.Global)
  else
    CreateRequestContext(FBaseDir + ProfileDir, '', '', False, True, True,
      procedure(_Ctx: ICefRequestContext)
      begin
        ExecOnMainThread(procedure
        begin
          FContexts.Add(ProfileDir, _Ctx);
          cb(_Ctx);
        end);
      end
    );
end;

function TCEFReqCtxMgr.GetProfileName(const site, key: string): string;
var
  profileName: string;
  joSite: ISuperObject;
  joKeys: ISuperObject;
  joProfiles: ISuperObject;
begin
  joSite := forceProperty(FSites, site, stObject);
  joKeys := forceProperty(joSite, 'keys', stObject);
  joProfiles := forceProperty(joSite, 'profiles', stObject);
  Result := joKeys.S[key];
  if Result = '' then
  begin
    AddContext('default', TCefRequestContextRef.Global);
    for profileName in FProfileNames do
    begin
      if joProfiles.S[profileName] = '' then
      begin
        Result := profileName;
        Break;
      end;
    end;
    if Result = '' then
    begin
      Result := GenerateProfileName;
      AddContext(Result, nil);
    end;
    joProfiles.S[Result] := key;
    joKeys.S[key] := Result;
    SaveSettings;
  end;
end;

procedure TCEFReqCtxMgr._ReleaseTempContext(_Ctx: ICefRequestContext);
var
  LName: string;
  joProfile: ISuperObject;
  i: Integer;
  arr: TSuperArray;
begin
  LName := extractFileName(_Ctx.CachePath);
  arr := FTmpProfiles.AsArray;
  for i := 0 to arr.Length - 1 do
  begin
    joProfile := arr[i];
    if joProfile.S['dir'] = LName then
    begin
      joProfile.I['status'] := 0;
      SaveSettings;
      Exit;
    end;
  end;
end;

procedure TCEFReqCtxMgr.ReleaseTempContext(_Ctx: ICefRequestContext);
begin
  ExecOnMainThread(
    procedure
    begin
      _ReleaseTempContext(_Ctx);
    end);
end;

procedure TCEFReqCtxMgr.RequireContext(const site, key: string; cb: TProc<ICefRequestContext>);
begin
  ExecOnMainThread(
    procedure
    begin
      GetOrCreateContext(GetProfileName(site, key), cb)
    end);
end;

function TCEFReqCtxMgr.RequireTmpProfileName: string;
var
  joProfile: ISuperObject;
  i: Integer;
  arr: TSuperArray;
begin
  arr := FTmpProfiles.AsArray;
  for i := 0 to arr.Length - 1 do
  begin
    joProfile := arr[i];
    if joProfile.I['status'] = 0 then
    begin
      joProfile.I['status'] := 1;
      Result := joProfile.S['dir'];
      SaveSettings;
      Exit;
    end;
  end;

  Result := GenerateProfileName;
  joProfile := TSuperObject.Create(stObject);
  joProfile.S['dir'] := Result;
  joProfile.S['createTime'] := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
  joProfile.I['status'] := 1;
  arr.Add(joProfile);
  SaveSettings;
end;

procedure TCEFReqCtxMgr.LoadSettings;
var
  FileName: string;
  fileContent: RawByteString;
  fs: TFileStream;
begin
  FileName := FBaseDir + FConfigFileName;
  if FileExists(FileName) then
  begin
    fs := TFileStream.Create(FileName, fmOpenRead);
    try
      SetLength(fileContent, fs.Size);
      fs.ReadBuffer(Pointer(fileContent)^, Length(fileContent));
    finally
      fs.Free;
    end;
    try
      FSettings := SO(UTF8ToString(fileContent));
    except
    end;
  end;
  if (FSettings = nil) or not FSettings.IsType(stObject) then
    FSettings := TSuperObject.Create(stObject);
  FSites := forceProperty(FSettings, 'sites', stObject);
  FProfiles := forceProperty(FSettings, 'profiles', stObject);
  FTmpProfiles := forceProperty(FSettings, 'TmpProfiles', stArray);
end;

procedure TCEFReqCtxMgr.NewTempContext(cb: TProc<ICefRequestContext>);
begin
  ExecOnMainThread(
    procedure
    begin
      GetOrCreateContext(RequireTmpProfileName, cb);
    end);
end;

procedure TCEFReqCtxMgr.SaveSettings;
var
  fs: TFileStream;
  json: UTF8String;
begin
  fs := TFileStream.Create(FBaseDir + FConfigFileName, fmCreate);
  try
    json := UTF8Encode(FSettings.AsJSon(True, False));
    fs.WriteBuffer(Pointer(json)^, Length(json));
  finally
    fs.Free;
  end;
end;

end.