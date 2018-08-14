{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{                                                       }
{ Copyright(c) 1995-2017 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{ Original Author: Vincent Parrett                      }
{                                                       }
{*******************************************************}

unit PCRE;

interface

uses
  SysUtils, Classes, Variants, PCREAPI, PCRECore;

type
  TStringArray = array of string;
  TRegExOption = (roNone, roIgnoreCase, roMultiLine, roExplicitCapture,
    roCompiled, roSingleLine, roIgnorePatternSpace, roNotEmpty);
  TRegExOptions = set of TRegExOption;

  TGroup = record
  private
    FIndex: Integer;
    FLength: Integer;
    FSuccess: Boolean;
    FValue: string;
    constructor Create(const AValue: string; AIndex, ALength: Integer; ASuccess: Boolean);
    function GetValue: string;
  public
    property Index: Integer read FIndex;
    property Length: Integer read FLength;
    property Success: Boolean read FSuccess;
    property Value: string read GetValue;
  end;

  TGroupCollectionEnumerator = class;

  TGroupCollection = record
  private
    FList: array of TGroup;
    FNotifier: IInterface;
    constructor Create(const ANotifier: IInterface; const AValue: string;
      AIndex, ALength: Integer; ASuccess: Boolean);
    function GetCount: Integer;
    function GetItem(const Index: Variant): TGroup;
  public
    function GetEnumerator: TGroupCollectionEnumerator;
    property Count: Integer read GetCount;
    property Item[const Index: Variant]: TGroup read GetItem; default;
  end;

  TGroupCollectionEnumerator = class
  private
    FCollection: TGroupCollection;
    FIndex: Integer;
  public
    constructor Create(const ACollection: TGroupCollection);
    function GetCurrent: TGroup;
    function MoveNext: Boolean;
    property Current: TGroup read GetCurrent;
  end;

  TMatch = record
  private
    FGroup: TGroup;
    FGroups: TGroupCollection;
    FNotifier: IInterface;
    constructor Create(const ANotifier: IInterface; const AValue: string;
      AIndex, ALength: Integer; ASuccess: Boolean);
    function GetIndex: Integer;
    function GetGroups: TGroupCollection;
    function GetLength: Integer;
    function GetSuccess: Boolean;
    function GetValue: string;
  public
    function NextMatch: TMatch;
    function Result(const Pattern: string): string;
    property Groups: TGroupCollection read GetGroups;
    property Index: Integer read GetIndex;
    property Length: Integer read GetLength;
    property Success: Boolean read GetSuccess;
    property Value: string read GetValue;
  end;

  TMatchCollectionEnumerator = class;

  TMatchCollection = record
  private
    FList: array of TMatch;
    constructor Create(const ANotifier: IInterface; const Input: string;
      AOptions: TRegExOptions; StartPos: Integer);
    function GetCount: Integer;
    function GetItem(Index: Integer): TMatch;
  public
    function GetEnumerator: TMatchCollectionEnumerator;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: TMatch read GetItem; default;
  end;

  TMatchCollectionEnumerator = class
  private
    FCollection: TMatchCollection;
    FIndex: Integer;
  public
    constructor Create(const ACollection: TMatchCollection);
    function GetCurrent: TMatch;
    function MoveNext: Boolean;
    property Current: TMatch read GetCurrent;
  end;

  TMatchEvaluator = function(const Match: TMatch): string of object;

  TRegEx = record
  private
    FOptions: TRegExOptions;
    FMatchEvaluator: TMatchEvaluator;
    FNotifier: IInterface;
    FRegEx: TPerlRegEx;
    procedure InternalOnReplace(Sender: TObject; var ReplaceWith: string);
    function UnicodeIndexToUTF8(const S: string; AIndex: Integer): Integer;
  public
    constructor Create(const Pattern: string; Options: TRegExOptions = [roNotEmpty]);

    function IsMatch(const Input: string): Boolean; overload;
    function IsMatch(const Input: string; StartPos: Integer): Boolean; overload;
    class function IsMatch(const Input, Pattern: string): Boolean;overload; static;
    class function IsMatch(const Input, Pattern: string; Options: TRegExOptions): Boolean; overload; static;

    class function Escape(const Str: string; UseWildCards: Boolean = False): string; static;

    function Match(const Input: string): TMatch; overload;
    function Match(const Input: string; StartPos: Integer): TMatch; overload;
    function Match(const Input: string; StartPos, Length: Integer): TMatch; overload;
    class function Match(const Input, Pattern: string): TMatch; overload; static;
    class function Match(const Input, Pattern: string; Options: TRegExOptions): TMatch; overload; static;

    function Matches(const Input: string): TMatchCollection; overload;
    function Matches(const Input: string; StartPos: Integer): TMatchCollection; overload;
    class function Matches(const Input, Pattern: string): TMatchCollection; overload; static;
    class function Matches(const Input, Pattern: string; Options: TRegExOptions): TMatchCollection; overload; static;

    function Replace(const Input, Replacement: string): string; overload;
    function Replace(const Input: string; Evaluator: TMatchEvaluator): string; overload;
    function Replace(const Input, Replacement: string; Count: Integer): string; overload;
    function Replace(const Input: string; Evaluator: TMatchEvaluator; Count: Integer): string; overload;
    class function Replace(const Input, Pattern, Replacement: string): string; overload; static;
    class function Replace(const Input, Pattern: string; Evaluator: TMatchEvaluator): string; overload; static;
    class function Replace(const Input, Pattern, Replacement: string; Options: TRegExOptions): string; overload; static;
    class function Replace(const Input, Pattern: string; Evaluator: TMatchEvaluator; Options: TRegExOptions): string; overload; static;

    function Split(const Input: string): TStringArray; overload; inline;
    function Split(const Input: string; Count: Integer): TStringArray; overload; inline;
    function Split(const Input: string; Count, StartPos: Integer): TStringArray; overload;
    class function Split(const Input, Pattern: string): TStringArray; overload; static;
    class function Split(const Input, Pattern: string; Options: TRegExOptions): TStringArray; overload; static;
  end;

implementation

{ Helper classes and functions }

type
  TScopeExitNotifier = class(TInterfacedObject)
  private
    FRegEx: TPerlRegEx;
  public
    constructor Create(const ARegEx: TPerlRegEx);
    destructor Destroy; override;
    property RegEx: TPerlRegEx read FRegEx;
  end;

function CopyBytes(const S: TBytes; Index, Count: Integer): TBytes;
var
  Len, I: Integer;
begin
  Len := Length(S);
  if Len = 0 then
    SetLength(Result, 0)
  else
  begin
    if Index < 0 then Index := 0
    else if Index > Len then Count := 0;
    Len := Len - Index;
    if Count <= 0 then
      SetLength(Result, 0)
    else
    begin
      if Count > Len then Count := Len;
      SetLength(Result, Count);
      for I := 0 to Count - 1 do
        Result[I] := S[Index + I];
    end;
  end;
end;

// Helper to extract RegEx object
function GetRegEx(const Notifier: IInterface): TPerlRegEx; inline;
begin
  Result := TScopeExitNotifier(Notifier).RegEx;
end;

constructor TScopeExitNotifier.Create(const ARegEx: TPerlRegEx);
begin
  FRegEx := ARegEx;
end;

destructor TScopeExitNotifier.Destroy;
begin
  FRegEx.Free;
  inherited;
end;

function RegExOptionsToPCREOptions(Value: TRegExOptions): TPerlRegExOptions;
begin
  Result := [];
  if (roIgnoreCase in Value) then
    Include(Result, preCaseLess);
  if (roMultiLine in Value) then
    Include(Result, preMultiLine);
  if (roExplicitCapture in Value) then
    Include(Result, preNoAutoCapture);
  if roSingleLine in Value then
    Include(Result, preSingleLine);
  if (roIgnorePatternSpace in Value) then
    Include(Result, preExtended);
end;

{ TGroup }

constructor TGroup.Create(const AValue: string; AIndex, ALength: Integer; ASuccess: Boolean);
begin
  FSuccess := ASuccess;
  FValue := AValue;
  FIndex := AIndex;
  FLength := ALength;
end;

function TGroup.GetValue: string;
begin
  Result := Copy(FValue, FIndex, FLength);
end;

{ TGroupCollection }

constructor TGroupCollection.Create(const ANotifier: IInterface;
  const AValue: string; AIndex, ALength: Integer; ASuccess: Boolean);
var
  I: Integer;
  LRegEx: TPerlRegEx;
begin
  FNotifier := ANotifier;
  // populate collection;
  if ASuccess then
  begin
    LRegEx := GetRegEx(FNotifier);
    SetLength(FList, LRegEx.GroupCount + 1);
    FList[0] := TGroup.Create(AValue, AIndex, ALength, ASuccess);
    for I := 1 to Length(FList) - 1 do
      FList[I] := TGroup.Create(AValue, LRegEx.GroupOffsets[I], LRegEx.GroupLengths[I], ASuccess);
  end;
end;

function TGroupCollection.GetCount: Integer;
begin
  Result := Length(FList);
end;

function TGroupCollection.GetEnumerator: TGroupCollectionEnumerator;
begin
  Result := TGroupCollectionEnumerator.Create(Self);
end;

function TGroupCollection.GetItem(const Index: Variant): TGroup;
var
  LIndex: Integer;
begin
  case VarType(Index) of
    varString, varOleStr {$if declared(varUString)} ,VARUSTRING {$ifend}:
      LIndex := GetRegEx(FNotifier).NamedGroup(string(Index));
    varByte, varSmallint, varInteger, varShortInt, varWord, varLongWord:
      LIndex := Index;
  else
    raise ERegularExpressionError.CreateRes(@SRegExInvalidIndexType);
  end;

  if (LIndex >= 0) and (LIndex < Length(FList)) then
    Result := FList[LIndex]
  else if (LIndex = PCRE_ERROR_NOSUBSTRING) and
          ((VarType(Index) = varString) or (VarType(Index) = varOleStr)
          {$if declared(varUString)} or (VarType(Index) = varUString) {$ifend}
          ) then
    raise ERegularExpressionError.CreateResFmt(@SRegExInvalidGroupName, [string(Index)])
  else
    raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [LIndex]);
end;

{ TGroupCollectionEnumerator }

constructor TGroupCollectionEnumerator.Create(const ACollection: TGroupCollection);
begin
  FCollection := ACollection;
  FIndex := -1;
end;

function TGroupCollectionEnumerator.GetCurrent: TGroup;
begin
  Result := FCollection.Item[FIndex];
end;

function TGroupCollectionEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FCollection.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TMatch }

constructor TMatch.Create(const ANotifier: IInterface; const AValue: string; AIndex,
  ALength: Integer; ASuccess: Boolean);
begin
  FGroup := TGroup.Create(AValue, AIndex, ALength, ASuccess);
  FGroups := TGroupCollection.Create(ANotifier, AValue, AIndex, ALength, ASuccess);
  FNotifier := ANotifier;
end;

function TMatch.GetGroups: TGroupCollection;
begin
  Result := FGroups;
end;

function TMatch.GetIndex: Integer;
begin
  Result := FGroup.Index;
end;

function TMatch.GetLength: Integer;
begin
  Result := FGroup.Length;
end;

function TMatch.GetSuccess: Boolean;
begin
  Result := FGroup.Success;
end;

function TMatch.GetValue: string;
begin
  Result := FGroup.Value;
end;

function TMatch.NextMatch: TMatch;
var
  LSuccess: Boolean;
  LRegEx: TPerlRegEx;
begin
  LRegEx := GetRegEx(FNotifier);
  LSuccess := LRegEx.MatchAgain;
  if LSuccess then
    Result := TMatch.Create(FNotifier, LRegEx.Subject,
      LRegEx.MatchedOffset, LRegEx.MatchedLength, LSuccess)
  else
    Result := TMatch.Create(FNotifier, LRegEx.Subject, 0, 0, LSuccess)
end;

function TMatch.Result(const Pattern: string): string;
var
  LRegEx: TPerlRegEx;
begin
  LRegEx := GetRegEx(FNotifier);
  LRegEx.Replacement := Pattern;
  Result := LRegEx.ComputeReplacement;
end;

{ TMatchCollection }

constructor TMatchCollection.Create(const ANotifier: IInterface; const Input: string;
  AOptions: TRegExOptions; StartPos: Integer);
var
  Count: Integer;
  LResult: Boolean;
  LRegEx: TPerlRegEx;
begin
  LRegEx := GetRegEx(ANotifier);
  LRegEx.Subject := Input;
  LRegEx.Options := RegExOptionsToPCREOptions(AOptions);
  LRegEx.Start := StartPos;
  Count := 0;
  SetLength(FList, 0);
  LResult := LRegEx.MatchAgain;
  while LResult do
  begin
    if Count mod 100 = 0 then
      SetLength(FList, Length(FList) + 100);
    FList[Count] := TMatch.Create(ANotifier, Input, LRegEx.MatchedOffset,
      LRegEx.MatchedLength, LResult);
    LResult := LRegEx.MatchAgain;
    Inc(Count);
  end;
  if Length(FList) > Count then
    SetLength(FList, Count);
end;

function TMatchCollection.GetCount: Integer;
begin
  Result := Length(FList);
end;

function TMatchCollection.GetEnumerator: TMatchCollectionEnumerator;
begin
  Result := TMatchCollectionEnumerator.Create(Self);
end;

function TMatchCollection.GetItem(Index: Integer): TMatch;
begin
  if (Index >= 0) and (Index < Length(FList)) then
    Result := FList[Index]
  else
    raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [Index]);
end;

{ TMatchCollectionEnumerator }

constructor TMatchCollectionEnumerator.Create(const ACollection: TMatchCollection);
begin
  FCollection := ACollection;
  FIndex := -1;
end;

function TMatchCollectionEnumerator.GetCurrent: TMatch;
begin
  Result := FCollection.Item[FIndex];
end;

function TMatchCollectionEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FCollection.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TRegEx }

constructor TRegEx.Create(const Pattern: string; Options: TRegExOptions);
begin
  FOptions := Options;
  FRegEx := TPerlRegEx.Create;
  FRegEx.Options := RegExOptionsToPCREOptions(FOptions);
  if (roNotEmpty in Options) then
    FRegEx.State := [preNotEmpty];
  FRegEx.RegEx := Pattern;
  FNotifier := TScopeExitNotifier.Create(FRegEx);
  if (roCompiled in FOptions) then
    FRegEx.Compile;
end;

class function TRegEx.Escape(const Str: string; UseWildCards: Boolean): string;
begin
  Result := TPerlRegEx.EscapeRegExChars(Str);
  // CRLF becomes \r\n
  Result := StringReplace(Result, #13#10, '\r\n', [rfReplaceAll]); // do not localize

  // If we're matching wildcards, make them Regex Groups so we can read them back if necessary
  if UseWildCards then
  begin
    // Replace all \*s with (.*)
    Result := StringReplace(Result, '\*', '(.*)', [rfReplaceAll]); // do not localize
    // Replace any \?s with (.)
    Result := StringReplace(Result, '\?', '(.)', [rfReplaceAll]); // do not localize

    // Wildcards can be escaped as ** or ??
    // Change back any escaped wildcards
    Result := StringReplace(Result, '(.*)(.*)', '\*', [rfReplaceAll]); // do not localize
    Result := StringReplace(Result, '(.)(.)', '\?', [rfReplaceAll]); // do not localize
  end;
end;

function TRegEx.IsMatch(const Input: string): Boolean;
begin
  FRegEx.Subject := Input;
  Result := FRegEx.Match;
end;

function TRegEx.IsMatch(const Input: string; StartPos: Integer): Boolean;
begin
  FRegEx.Subject := Input;
  FRegEx.Start := UnicodeIndexToUTF8(Input, StartPos) + 1;
  Result := FRegEx.MatchAgain;
end;

class function TRegEx.IsMatch(const Input, Pattern: string): Boolean;
var
  LRegEx: TRegEx;
  Match: TMatch;
begin
  LRegEx := TRegEx.Create(Pattern);
  Match := LRegEx.Match(Input);
  Result := Match.Success;
end;

procedure TRegEx.InternalOnReplace(Sender: TObject; var ReplaceWith: string);
var
  Match: TMatch;
begin
  if Assigned(FMatchEvaluator) then
  begin
    Match := TMatch.Create(FNotifier, FRegEx.Subject,
      FRegEx.MatchedOffset, FRegEx.MatchedLength, True);
    ReplaceWith := FMatchEvaluator(Match);
  end;
end;

class function TRegEx.IsMatch(const Input, Pattern: string; Options: TRegExOptions): Boolean;
var
  LRegEx: TRegEx;
  Match: TMatch;
begin
  LRegEx := TRegEx.Create(Pattern, Options);
  Match := LRegEx.Match(Input);
  Result := Match.Success;
end;

class function TRegEx.Match(const Input, Pattern: string): TMatch;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern);
  Result := LRegEx.Match(Input);
end;

class function TRegEx.Match(const Input, Pattern: string; Options: TRegExOptions): TMatch;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern, Options);
  Result := LRegEx.Match(Input);
end;

function TRegEx.Matches(const Input: string): TMatchCollection;
begin
  Result := TMatchCollection.Create(FNotifier, Input, FOptions, 1);
end;

function TRegEx.Matches(const Input: string; StartPos: Integer): TMatchCollection;
begin
  Result := TMatchCollection.Create(FNotifier, Input, FOptions,
    UnicodeIndexToUTF8(Input, StartPos));
end;

function TRegEx.Match(const Input: string): TMatch;
var
  LSuccess: Boolean;
begin
  FRegEx.Subject := Input;
  LSuccess := FRegEx.Match;
  if LSuccess then
    Result := TMatch.Create(FNotifier, FRegEx.Subject,
      FRegEx.MatchedOffset, FRegEx.MatchedLength, LSuccess)
  else
    Result := TMatch.Create(FNotifier, FRegEx.Subject, 0, 0, LSuccess);
end;

function TRegEx.Match(const Input: string; StartPos: Integer): TMatch;
var
  LSuccess: Boolean;
begin
  FRegEx.Subject := Input;
  FRegEx.Start := UnicodeIndexToUTF8(Input, StartPos) + 1;
  LSuccess := FRegEx.MatchAgain;
  if LSuccess then
    Result := TMatch.Create(FNotifier, FRegEx.Subject,
      FRegEx.MatchedOffset, FRegEx.MatchedLength, LSuccess)
  else
    Result := TMatch.Create(FNotifier, FRegEx.Subject, 0, 0, LSuccess);
end;

function TRegEx.Match(const Input: string; StartPos, Length: Integer): TMatch;
var
  LSuccess: Boolean;
begin
  FRegEx.Subject := Input;
  FRegEx.Start := UnicodeIndexToUTF8(Input, StartPos) + 1;
  FRegEx.Stop := UnicodeIndexToUTF8(Input, StartPos + Length);
  LSuccess := FRegEx.MatchAgain;
  if LSuccess then
    Result := TMatch.Create(FNotifier, FRegEx.Subject,
      FRegEx.MatchedOffset, FRegEx.MatchedLength, LSuccess)
  else
    Result := TMatch.Create(FNotifier, FRegEx.Subject, 0, 0, LSuccess);
end;

class function TRegEx.Matches(const Input, Pattern: string): TMatchCollection;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern);
  Result := LRegEx.Matches(Input);
end;

class function TRegEx.Matches(const Input, Pattern: string; Options: TRegExOptions): TMatchCollection;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern, Options);
  Result := LRegEx.Matches(Input);
end;

class function TRegEx.Replace(const Input, Pattern, Replacement: string): string;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern);
  Result := LRegEx.Replace(Input, Replacement);
end;

class function TRegEx.Replace(const Input, Pattern: string; Evaluator: TMatchEvaluator): string;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern);
  Result := LRegEx.Replace(Input, Evaluator);
end;

class function TRegEx.Replace(const Input, Pattern: string;
  Evaluator: TMatchEvaluator; Options: TRegExOptions): string;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern, Options);
  Result := LRegEx.Replace(Input, Evaluator);
end;

function TRegEx.Replace(const Input, Replacement: string): string;
begin
  FRegEx.Subject := Input;
  FRegEx.Replacement := Replacement;
  FRegEx.ReplaceAll;
  Result := FRegEx.Subject;
end;

function TRegEx.Replace(const Input, Replacement: string; Count: Integer): string;
var
  I: Integer;
begin
  if Count = -1 then
  begin
    Result := Replace(Input, Replacement);
    Exit;
  end;
  FRegEx.Subject := Input;
  FRegEx.Replacement := Replacement;

  I := 0;
  if FRegEx.Match then
  begin
    repeat
      FRegEx.Replace;
      Inc(I)
    until (I = Count) or (not FRegEx.MatchAgain);
  end;
  Result := FRegEx.Subject;
end;

function TRegEx.Replace(const Input: string; Evaluator: TMatchEvaluator): string;
begin
  FRegEx.Subject := Input;
  FMatchEvaluator := Evaluator;
  FRegEx.OnReplace := Self.InternalOnReplace;
  try
    FRegEx.ReplaceAll;
    Result := FRegEx.Subject;
  finally
    FRegEx.OnReplace := nil;
    FMatchEvaluator := nil;
  end;
end;

function TRegEx.Replace(const Input: string; Evaluator: TMatchEvaluator; Count: Integer): string;
var
  I: Integer;
begin
  if Count = -1 then
  begin
    Result := Replace(Input, Evaluator);
    Exit;
  end;
  FRegEx.Subject := Input;
  FRegEx.OnReplace := Self.InternalOnReplace;
  FMatchEvaluator := Evaluator;

  try
    I := 0;
    if FRegEx.Match then
    begin
      repeat
        FRegEx.Replace;
        Inc(I)
      until (I = Count) or (not FRegEx.MatchAgain);
    end;
    Result := FRegEx.Subject;
  finally
    FRegEx.OnReplace := nil;
    FMatchEvaluator := nil;
  end;
end;

class function TRegEx.Replace(const Input, Pattern, Replacement: string;
  Options: TRegExOptions): string;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern, Options);
  Result := LRegEx.Replace(Input, Replacement);
end;

function TRegEx.Split(const Input: string): TStringArray;
begin
  Result := Split(Input, 0, 1);
end;

function TRegEx.Split(const Input: string; Count: Integer): TStringArray;
begin
  Result := Split(Input, Count, 1);
end;

function StringListToArray(List: TStrings): TStringArray;
var
  i: Integer;
begin
  SetLength(Result, List.Count);
  for i := 0 to List.Count - 1 do
    Result[i] := List[i];
end;

function TRegEx.Split(const Input: string; Count, StartPos: Integer): TStringArray;
var
  List: TStringList;
begin
  if Input <> '' then
  begin
    List := TStringList.Create;
    try
      FRegEx.Subject := Input;
      FRegEx.SplitCapture(List, Count, UnicodeIndexToUTF8(Input, StartPos) + 1);
      Result := StringListToArray(List);
    finally
      List.Free;
    end;
  end
  else
    SetLength(Result, 0);
end;

class function TRegEx.Split(const Input, Pattern: string): TStringArray;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern);
  Result := LRegEx.Split(Input);
end;

class function TRegEx.Split(const Input, Pattern: string; Options: TRegExOptions): TStringArray;
var
  LRegEx: TRegEx;
begin
  LRegEx := TRegEx.Create(Pattern, Options);
  Result := LRegEx.Split(Input);
end;

function TRegEx.UnicodeIndexToUTF8(const S: string; AIndex: Integer): Integer;
var
  I: Integer;
begin
  if AIndex > Length(S) + 1 then
    raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [AIndex]);

  Result := 0;
  I := 0;
  while I < (AIndex - 1) do
  begin
    if PChar(Pointer(S))[I] <= #$007F then
      Inc(Result)
    else if PChar(Pointer(S))[I] <= #$7FF then
      Inc(Result, 2)
    else if IsLeadChar(PChar(Pointer(S))[I]) then
    begin
      Inc(I);
      Inc(Result, 4);
    end
    else
      Inc(Result, 3);
    Inc(I);
  end;
end;

end.

