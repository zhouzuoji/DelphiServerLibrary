{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{                                                       }
{ Copyright(c) 1995-2017 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{ Original Author: Jan Goyvaerts                        }
{                                                       }
{*******************************************************}

unit PCRECore;

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes, Contnrs, PCREAPI;

{$IF defined(CPU386) and defined(IOS32)}
{$DEFINE IOSSIM}   //IOS Simulator
{$IFEND}

{$IF defined(MACOS) and not defined(IOS)}
{$DEFINE OSX}
{$IFEND}

{$IF defined(IOSSIM) or defined(OSX)}
  {$DEFINE DYNAMIC_LIB}
{$IFEND}

resourcestring
  SRegExMissingExpression = 'A regular expression specified in RegEx is required';
  SRegExExpressionError = 'Error in regular expression at offset %d: %s';
  SRegExStudyError = 'Error studying the regex: %s';
  SRegExMatchRequired = 'Successful match required';
  SRegExStringsRequired = 'Strings parameter cannot be nil';
  SRegExInvalidIndexType = 'Invalid index type';
  SRegExIndexOutOfBounds = 'Index out of bounds (%d)';
  SRegExInvalidGroupName = 'Invalid group name (%s)';

type
  UTF8Char = AnsiChar;
  PUTF8Char = PAnsiChar;
  TPerlRegExOptions = set of (
    preCaseLess,       // /i -> Case insensitive
    preMultiLine,      // /m -> ^ and $ also match before/after a newline, not just at the beginning and the end of the string
    preSingleLine,     // /s -> Dot matches any character, including \n (newline). Otherwise, it matches anything except \n
    preExtended,       // /x -> Allow regex to contain extra whitespace, newlines and Perl-style comments, all of which will be filtered out
    preAnchored,       // /A -> Successful match can only occur at the start of the subject or right after the previous match
    preUnGreedy,       // Repeat operators (+, *, ?) are not greedy by default (i.e. they try to match the minimum number of characters instead of the maximum)
    preNoAutoCapture   // (group) is a non-capturing group; only named groups capture
  );

type
  TPerlRegExState = set of (
    preNotBOL,         // Not Beginning Of Line: ^ does not match at the start of Subject
    preNotEOL,         // Not End Of Line: $ does not match at the end of Subject
    preNotEmpty        // Empty matches not allowed
  );

const
  // Maximum number of subexpressions (backreferences)
  // Subexpressions are created by placing round brackets in the regex, and are referenced by \1, \2, ...
  // In Perl, they are available as $1, $2, ... after the regex matched; with TPerlRegEx, use the Subexpressions property
  // You can also insert \1, \2, ... in the replacement string; \0 is the complete matched expression
  MAX_SUBEXPRESSIONS = 99;

// All implicit string casts have been verified to be correct
{. $WARN IMPLICIT_STRING_CAST OFF}

type
  TPerlRegExReplaceEvent = procedure(Sender: TObject; var ReplaceWith: string) of object;

type
  TPerlRegEx = class
  private    // *** Property storage, getters and setters
    FCompiled, FStudied: Boolean;
    FOptions: TPerlRegExOptions;
    FState: TPerlRegExState;
    FRegEx: string;
    FReplacement: UTF8String;
    FSubject: UTF8String;
    FStart, FStop: Integer;
    FOnMatch: TNotifyEvent;
    FOnReplace: TPerlRegExReplaceEvent;
    LastIndex1: Integer;
    LastIndexResult1: Integer;
    LastIndex2: Integer;
    LastIndexResult2: Integer;
    function GetMatchedText: string;
    function GetMatchedLength: Integer; inline;
    function GetMatchedOffset: Integer; inline;
    function InternalGetMatchedOffset: Integer; inline;
    function InternalGetMatchedLength: Integer; inline;
    procedure SetOptions(Value: TPerlRegExOptions);
    procedure SetRegEx(const Value: string);
    function GetGroupCount: Integer; inline;
    function GetGroups(Index: Integer): string;
    function GetGroupLengths(Index: Integer): Integer;
    function GetGroupOffsets(Index: Integer): Integer;
    function InternalGetGroupLengths(Index: Integer): Integer; inline;
    function InternalGetGroupOffsets(Index: Integer): Integer; inline;
    procedure SetFSubject(const Value: UTF8String);
    procedure SetSubject(const Value: string);
    function GetSubject: string;
    procedure SetStart(const Value: Integer);
    procedure SetStop(const Value: Integer);
    function GetFoundMatch: Boolean; inline;
    function UTF8IndexToUnicode(AIndex: Integer): Integer;
  private    // *** Variables used by PCRE
    Offsets: array[0..(MAX_SUBEXPRESSIONS+1)*3] of Integer;
    OffsetCount: Integer;
    FPCREOptions: Integer;
    FPattern: Pointer;
    FHints: Pointer;
    FCharTable: Pointer;
    FHasStoredGroups: Boolean;
    FStoredGroups: array of string;
    function GetSubjectLeft: string; inline;
    function GetSubjectLeftUTF8: UTF8String;
    function GetSubjectRight: string; inline;
    function GetSubjectRightUTF8: UTF8String;
    procedure SetReplacement(const Value: string);
    function GetReplacement: string;
    function GetStart: Integer;
{$IFDEF DYNAMIC_LIB}
    class constructor Create;
    class destructor Destroy;
{$ENDIF DYNAMIC_LIB}
    function InternalNamedGroup(const Name: UTF8String): Integer; inline;
  protected
    procedure CleanUp;
        // Dispose off whatever we created, so we can start over. Called automatically when needed, so it is not made public
    procedure ClearStoredGroups;
  public
    constructor Create;
        // Come to life
    destructor Destroy; override;
        // Clean up after ourselves
    class function EscapeRegExChars(const S: string): string;
        // Escapes regex characters in S so that the regex engine can be used to match S as plain text
    procedure Compile;
        // Compile the regex. Called automatically by Match
    procedure Study;
        // Study the regex. Studying takes time, but will make the execution of the regex a lot faster.
        // Call study if you will be using the same regex many times
    function Match: Boolean;
        // Attempt to match the regex, starting the attempt from the beginning of Subject
    function MatchAgain: Boolean;
        // Attempt to match the regex to the remainder of Subject after the previous match (as indicated by Start)
    function Replace: string;
        // Replace matched expression in Subject with ComputeReplacement.  Returns the actual replacement text from ComputeReplacement
    function ReplaceAll: Boolean;
        // Repeat MatchAgain and Replace until you drop.  Returns True if anything was replaced at all.
    function ComputeReplacement: string;
        // Returns Replacement with backreferences filled in
    procedure StoreGroups;
        // Stores duplicates of Groups[] so they and ComputeReplacement will still return the proper strings
        // even if FSubject is changed or cleared
    function NamedGroup(const Name: string): Integer;
        // Returns the index of the named group Name
    procedure Split(const Strings: TStrings; Limit: Integer);
        // Split Subject along regex matches.  Capturing groups are ignored.
    procedure SplitCapture(const Strings: TStrings; Limit: Integer); overload;
    procedure SplitCapture(const Strings: TStrings; Limit: Integer; Offset : Integer); overload;
        // Split Subject along regex matches.  Capturing groups are added to Strings as well.
    property Compiled: Boolean read FCompiled;
        // True if the RegEx has already been compiled.
    property FoundMatch: Boolean read GetFoundMatch;
        // Returns True when Matched* and Group* indicate a match
    property Studied: Boolean read FStudied;
        // True if the RegEx has already been studied
    property MatchedText: string read GetMatchedText;
        // The matched text
    property MatchedLength: Integer read GetMatchedLength;
        // Length of the matched text
    property MatchedOffset: Integer read GetMatchedOffset;
        // Character offset in the Subject string at which MatchedText starts
    property Start: Integer read GetStart write SetStart;
        // Starting position in Subject from which MatchAgain begins
    property Stop: Integer read FStop write SetStop;
        // Last character in Subject that Match and MatchAgain search through
    property State: TPerlRegExState read FState write FState;
        // State of Subject
    property GroupCount: Integer read GetGroupCount;
        // Number of matched capturing groups
    property Groups[Index: Integer]: string read GetGroups;
        // Text matched by capturing groups
    property GroupLengths[Index: Integer]: Integer read GetGroupLengths;
        // Lengths of the text matched by capturing groups
    property GroupOffsets[Index: Integer]: Integer read GetGroupOffsets;
        // Character offsets in Subject at which the capturing group matches start
    property Subject: string read GetSubject write SetSubject;
        // The string on which Match() will try to match RegEx
    property SubjectLeft: string read GetSubjectLeft;
        // Part of the subject to the left of the match
    property SubjectRight: string read GetSubjectRight;
        // Part of the subject to the right of the match
  public
    property Options: TPerlRegExOptions read FOptions write SetOptions;
        // Options
    property RegEx: string read FRegEx write SetRegEx;
        // The regular expression to be matched
    property Replacement: string read GetReplacement write SetReplacement;
        // Text to replace matched expression with. \number and $number backreferences will be substituted with Groups
        // TPerlRegEx supports the "JGsoft" replacement text flavor as explained at http://www.regular-expressions.info/refreplace.html
    property OnMatch: TNotifyEvent read FOnMatch write FOnMatch;
        // Triggered by Match and MatchAgain after a successful match
    property OnReplace: TPerlRegExReplaceEvent read FOnReplace write FOnReplace;
        // Triggered by Replace and ReplaceAll just before the replacement is done, allowing you to determine the new string
  end;

{
  You can add TPerlRegEx instances to a TPerlRegExList to match them all together on the same subject,
  as if they were one regex regex1|regex2|regex3|...
  TPerlRegExList does not own the TPerlRegEx components, just like a TList
  If a TPerlRegEx has been added to a TPerlRegExList, it should not be used in any other situation
  until it is removed from the list
}

type
  TPerlRegExList = class
  private
    FList: TObjectList;
    FSubject: UTF8String;
    FMatchedRegEx: TPerlRegEx;
    FStart, FStop: Integer;
    function GetRegEx(Index: Integer): TPerlRegEx;
    procedure SetRegEx(Index: Integer; const Value: TPerlRegEx);
    procedure SetSubject(const Value: string);
    function GetSubject: string;
    procedure SetStart(const Value: Integer);
    procedure SetStop(const Value: Integer);
    function GetCount: Integer;
    function GetStart: Integer;
    function GetStop: Integer;
  protected
    procedure UpdateRegEx(const ARegEx: TPerlRegEx);
  public
    constructor Create;
    destructor Destroy; override;
  public
    function Add(const ARegEx: TPerlRegEx): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    function IndexOf(const ARegEx: TPerlRegEx): Integer;
    procedure Insert(Index: Integer; const ARegEx: TPerlRegEx);
  public
    function Match: Boolean;
    function MatchAgain: Boolean;
    property RegEx[Index: Integer]: TPerlRegEx read GetRegEx write SetRegEx;
    property Count: Integer read GetCount;
    property Subject: string read GetSubject write SetSubject;
    property Start: Integer read GetStart write SetStart;
    property Stop: Integer read GetStop write SetStop;
    property MatchedRegEx: TPerlRegEx read FMatchedRegEx;
  end;

  ERegularExpressionError = class(Exception);

implementation

{ ********* Unit support routines ********* }
function FirstCap(const S: string): string;
begin
  if S = '' then
    Result := ''
  else
    Result := UpperCase(S[1]) + AnsiLowerCase(Copy(S, 2, Length(S) - 1));
end;

function InitialCaps(const S: string): string;
var
  I, J, L: Integer;
  Up: Boolean;
  Tmp: array of Char;
begin
  Result := AnsiLowerCase(S);
  L := Length(S);
  SetLength(Tmp, L);

  Up := True;
  J := 0;
  for I := 0 to L - 1 do
  begin
    Tmp[J] := PChar(Result)[I];
    case Tmp[J] of
      #0..'&', '(', '*', '+', ',', '-', '.', '?', '<', '[', '{', #$00B7:
        Up := True
      else
        if Up and (Tmp[J] <> '''') then
        begin
          Tmp[J] := UpperCase(Tmp[J], loUserLocale)[1];
          Up := False;
        end;
    end;
    Inc(J);
  end;
  SetString(Result, PChar(Tmp), J);
end;

{ ********* TPerlRegEx ********* }

procedure TPerlRegEx.CleanUp;
begin
  FCompiled := False;
  FStudied := False;
  pcre_dispose(FPattern, FHints, nil);
  FPattern := nil;
  FHints := nil;
  ClearStoredGroups;
  OffsetCount := 0;
end;

procedure TPerlRegEx.ClearStoredGroups;
begin
  FHasStoredGroups := False;
  FStoredGroups := nil;
end;

procedure TPerlRegEx.Compile;
var
  Error: PAnsiChar;
  ErrorOffset: Integer;
begin
  if FRegEx = '' then
    raise ERegularExpressionError.CreateRes(@SRegExMissingExpression);
  CleanUp;
  FPattern := pcre_compile(PAnsiChar(UTF8String(FRegEx)), FPCREOptions, @Error, @ErrorOffset, FCharTable);
  if FPattern = nil then
    raise ERegularExpressionError.CreateResFmt(@SRegExExpressionError, [ErrorOffset, string(Error)]);
  FCompiled := True
end;

(* Backreference overview:

Assume there are 13 backreferences:

Text        TPerlRegex    .NET      Java       ECMAScript
$17         $1 + "7"      "$17"     $1 + "7"   $1 + "7"
$017        $1 + "7"      "$017"    $1 + "7"   $1 + "7"
$12         $12           $12       $12        $12
$012        $1 + "2"      $12       $12        $1 + "2"
${1}2       $1 + "2"      $1 + "2"  error      "${1}2"
$$          "$"           "$"       error      "$"
\$          "$"           "\$"      "$"        "\$"
*)

function TPerlRegEx.ComputeReplacement: string;
var
  Mode: UTF8Char;
  S: UTF8String;
  I, J, N: Integer;

  procedure ReplaceBackreference(Number: Integer);
  var
    BR: UTF8String;
    Backreference: string;
  begin
    Delete(S, I+1, J - I);
    if Number <= GroupCount then
    begin
      Backreference := Groups[Number];
      if Backreference <> '' then
      begin
        // Ignore warnings; converting to UTF-8 does not cause data loss
        case Mode of
          'L', 'l': Backreference := AnsiLowerCase(Backreference);
          'U', 'u': Backreference := AnsiUpperCase(Backreference);
          'F', 'f': Backreference := FirstCap(Backreference);
          'I', 'i': Backreference := InitialCaps(Backreference);
        end;
        if S <> '' then
        begin
          BR := UTF8String(Backreference);
          Insert(BR, S, I+1);
          I := I + Length(BR);
        end
        else
        begin
          S := UTF8String(Backreference);
          I := MaxInt;
        end
      end;
    end
  end;

  procedure ProcessBackreference(NumberOnly, Dollar: Boolean);
  var
    Number, Number2: Integer;
  begin
    Number := -1;
    if (J < Length(S)) and ( PUTF8Char(Pointer(S))[J] in ['0'..'9']) then
    begin
      // Get the number of the backreference
      Number := Ord(PUTF8Char(Pointer(S))[J]) - Ord('0');
      Inc(J);
      if (J < Length(S)) and (PUTF8Char(Pointer(S))[J] in ['0'..'9']) then
      begin
        // Expand it to two digits only if that would lead to a valid backreference
        Number2 := Number*10 + Ord(PUTF8Char(Pointer(S))[J]) - Ord('0');
        if Number2 <= GroupCount then
        begin
          Number := Number2;
          Inc(J)
        end;
      end;
    end
    else if not NumberOnly then
    begin
      if Dollar and (J < Length(S) - 1) and (PUTF8Char(Pointer(S))[J] = '{') then
      begin
        // Number or name in curly braces
        Inc(J);
        case PUTF8Char(Pointer(S))[J] of
          '0'..'9':
            begin
              Number := Ord(PUTF8Char(Pointer(S))[J]) - Ord('0');
              Inc(J);
              while (J < Length(S)) and (PUTF8Char(Pointer(S))[J] in ['0'..'9']) do
              begin
                Number := Number * 10 + Ord(PUTF8Char(Pointer(S))[J]) - Ord('0');
                Inc(J)
              end;
            end;
          'A'..'Z', 'a'..'z', '_':
            begin
              Inc(J);
              while (J < Length(S)) and (PUTF8Char(Pointer(S))[J] in ['0'..'9', 'A'..'Z', 'a'..'z', '_']) do
                Inc(J);
              if (J < Length(S)) and (PUTF8Char(Pointer(S))[J] = '}') then
                Number := InternalNamedGroup(Copy(S, I+2+1, J-I-2));
            end;
        end;
        if (J >= Length(S)) or (PUTF8Char(Pointer(S))[J] <> '}') then
          Number := -1
        else
          Inc(J);
      end
      else if Dollar and (PUTF8Char(Pointer(S))[J] = '_') then
      begin
        // $_ (whole subject)
        Delete(S, I+1, J + 1 - I);
        Insert(FSubject, S, I+1);
        I := I + Length(FSubject);
        Exit;
      end
      else
      case PUTF8Char(Pointer(S))[J] of
        '&':
          begin
            // \& or $& (whole regex match)
            Number := 0;
            Inc(J);
          end;
        '+':
          begin
            // \+ or $+ (highest-numbered participating group)
            Number := GroupCount;
            Inc(J);
          end;
        '`':
          begin
            // \` or $` (backtick; subject to the left of the match)
            Delete(S, I+1, J+1-I);
            Insert(GetSubjectLeftUTF8, S, I+1);
            I := I + Offsets[0] - 1;
            Exit;
          end;
        '''':
          begin
            // \' or $' (straight quote; subject to the right of the match)
            Delete(S, I+1, J+1-I);
            Insert(GetSubjectRightUTF8, S, I+1);
            I := I + Length(Subject) - Offsets[1];
            Exit;
          end
      end;
    end;
    if Number >= 0 then
      ReplaceBackreference(Number)
    else
      Inc(I)
  end;

begin
  if Length(FReplacement) = 0 then
  begin
    Result := ''; 
    Exit;
  end;
  S := FReplacement;
  I := 0;
  while I < Length(S)-1 do
  begin
    case PUTF8Char(Pointer(S))[I] of
      '\':
        begin
          J := I + 1;
          // We let I stop one character before the end, so J cannot point
          // beyond the end of the UTF8String here
          if J >= Length(S) then
            raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [J]);
          case Char(PUTF8Char(Pointer(S))[J]) of
            '$', '\':
              begin
                Delete(S, I+1, 1);
                Inc(I);
              end;
            'g':
              begin
                if (J < Length(S)-2) and (PUTF8Char(Pointer(S))[J+1] = '<') and (PUTF8Char(Pointer(S))[J+2] in ['A'..'Z', 'a'..'z', '_']) then
                begin
                  // Python-style named group reference \g<name>
                  J := J+3;
                  while (J <= Length(S)-1) and (PUTF8Char(Pointer(S))[J] in ['0'..'9', 'A'..'Z', 'a'..'z', '_']) do
                    Inc(J);
                  if (J <= Length(S)-1) and (PUTF8Char(Pointer(S))[J] = '>') then
                  begin
//                    N := InternalNamedGroup(CopyBytes(S, I+3, J-I-3));
                    N := InternalNamedGroup(Copy(S, I+3+1, J-I-3));
                    Inc(J);
                    Mode := #$0;
                    if N > 0 then
                      ReplaceBackreference(N)
                    else
                      Delete(S, I+1, J-I);
                  end
                  else
                    I := J
                end
                else
                  I := I+2;
              end;
            'l', 'L', 'u', 'U', 'f', 'F', 'i', 'I':
              begin
                Mode := PUTF8Char(Pointer(S))[J];
                Inc(J);
                ProcessBackreference(True, False);
              end;
          else
            Mode := #$0;
            ProcessBackreference(False, False);
          end;
        end;
      '$':
        begin
          J := I + 1;
          // We let I stop one character before the end, so J cannot point
          // beyond the end of the UTF8String here
          if J >= Length(S) then
            raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [J]);
          if PUTF8Char(Pointer(S))[J] = '$' then
          begin
            Delete(S, J+1, 1);
            Inc(I);
          end
          else
          begin
            Mode := #$0;
            ProcessBackreference(False, True);
          end
        end;
    else
      Inc(I);
    end
  end;
  Result := String(S);
end;

constructor TPerlRegEx.Create;
begin
  inherited Create;
  FState := [];
  FCharTable := pcre_maketables;
  FPCREOptions := PCRE_UTF8 or PCRE_NEWLINE_ANY;
end;

destructor TPerlRegEx.Destroy;
begin
  pcre_dispose(FPattern, FHints, FCharTable);
  inherited Destroy;
end;

{$IFDEF DYNAMIC_LIB}
class constructor TPerlRegEx.Create;
begin
  if not LoadPCRELib then
    RaiseLastOSError;
end;

class destructor TPerlRegEx.Destroy;
begin
  UnloadPCRELib;
end;
{$ENDIF DYNAMIC_LIB}

class function TPerlRegEx.EscapeRegExChars(const S: string): string;
var
  I, J, L: Integer;
  Tmp: array of Char;
begin
  L := Length(S);
  SetLength(Tmp, L * 2);
  J := 0;
  for I := 0 to L - 1 do
  begin
    case PChar(Pointer(S))[I] of
      '\', '[', ']', '^', '$', '.', '|', '?', '*', '+', '-', '(', ')', '{', '}', '&', '<', '>':
        begin
          Tmp[J] := '\';
          Inc(j);
          Tmp[J] := PChar(Pointer(S))[I];
        end;
      #0:
        begin
          Tmp[J] := '\';
          Inc(j);
          Tmp[J] := '0';
        end;
      else
        Tmp[J] := PChar(Pointer(S))[I];
    end;
    Inc(J);
  end;
  SetString(Result, PChar(Tmp), J);
end;

function TPerlRegEx.GetFoundMatch: Boolean;
begin
  Result := OffsetCount > 0;
end;

function TPerlRegEx.GetMatchedText: string;
begin
  if not FoundMatch then
    raise ERegularExpressionError.CreateRes(@SRegExMatchRequired);
  Result := GetGroups(0);
end;

function TPerlRegEx.GetReplacement: string;
begin
  Result := string(FReplacement);
end;

function TPerlRegEx.GetMatchedLength: Integer;
begin
  Result := GetGroupLengths(0)
end;

function TPerlRegEx.InternalGetMatchedLength: Integer;
begin
  Result := InternalGetGroupLengths(0)
end;

function TPerlRegEx.InternalGetMatchedOffset: Integer;
begin
  Result := InternalGetGroupOffsets(0);
end;

function TPerlRegEx.InternalNamedGroup(const Name: UTF8String): Integer;
begin
  Result := pcre_get_stringnumber(FPattern, PUTF8Char(Name));
end;

function TPerlRegEx.GetMatchedOffset: Integer;
begin
  Result := GetGroupOffsets(0);
end;

function TPerlRegEx.GetGroupCount: Integer;
begin
  if not FoundMatch then
    raise ERegularExpressionError.CreateRes(@SRegExMatchRequired);
  Result := OffsetCount - 1
end;

function TPerlRegEx.GetGroupLengths(Index: Integer): Integer;
begin
  if not FoundMatch then
    raise ERegularExpressionError.CreateRes(@SRegExMatchRequired);

  if (Index >= 0) and (Index <= GroupCount) then
    Result := UTF8IndexToUnicode(Offsets[Index*2+1]) - UTF8IndexToUnicode(Offsets[Index*2])
  else
    raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [Index]);
end;

function TPerlRegEx.GetGroupOffsets(Index: Integer): Integer;
begin
  if not FoundMatch then
    raise ERegularExpressionError.CreateRes(@SRegExMatchRequired);

  if (Index >= 0) and (Index <= GroupCount) then
    Result := UTF8IndexToUnicode(Offsets[Index*2]) + 1
  else
    raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [Index]);
end;

function TPerlRegEx.InternalGetGroupLengths(Index: Integer): Integer;
begin
  if not FoundMatch then
    raise ERegularExpressionError.CreateRes(@SRegExMatchRequired);

  if (Index >= 0) and (Index <= GroupCount) then
    Result := Offsets[Index*2+1]-Offsets[Index*2]
  else
    raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [Index]);
end;

function TPerlRegEx.InternalGetGroupOffsets(Index: Integer): Integer;
begin
  if not FoundMatch then
    raise ERegularExpressionError.CreateRes(@SRegExMatchRequired);

  if (Index >= 0) and (Index <= GroupCount) then
    Result := Offsets[Index*2]
  else
    raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [Index]);
end;

function TPerlRegEx.GetGroups(Index: Integer): string;
begin
  if not FoundMatch then
    raise ERegularExpressionError.CreateRes(@SRegExMatchRequired);
  if Index > GroupCount then
    Result := ''
  else if FHasStoredGroups then
    Result := FStoredGroups[Index]
  else
    Result := string(Copy(FSubject, Offsets[Index*2]+1, Offsets[Index*2+1]-Offsets[Index*2]));
end;

function TPerlRegEx.GetStart: Integer;
begin
  Result := FStart + 1;
end;

function TPerlRegEx.GetSubject: string;
begin
  Result := string(FSubject);
end;

function TPerlRegEx.GetSubjectLeft: String;
begin
  Result := String(GetSubjectLeftUTF8);
end;

function TPerlRegEx.GetSubjectLeftUTF8: UTF8String;
begin
  Result := Copy(FSubject, 1, Offsets[0]);
end;

function TPerlRegEx.GetSubjectRight: string;
begin
  Result := String(GetSubjectRightUTF8);
end;

function TPerlRegEx.GetSubjectRightUTF8: UTF8String;
begin
  Result := Copy(FSubject, Offsets[1]+1, Length(FSubject) - Offsets[1]);
end;

function TPerlRegEx.Match: Boolean;
var
  Opts: Integer;
begin
  ClearStoredGroups;
  if not Compiled then
    Compile;
  if preNotBOL in State then
    Opts := PCRE_NOTBOL
  else
    Opts := 0;
  if preNotEOL in State then
    Opts := Opts or PCRE_NOTEOL;
  if preNotEmpty in State then
    Opts := Opts or PCRE_NOTEMPTY;
  Opts := Opts or PCRE_NO_UTF8_CHECK;
  OffsetCount := pcre_exec(FPattern, FHints, PUTF8Char(FSubject), FStop, 0, Opts, @Offsets[0], High(Offsets));
  Result := OffsetCount > 0;
  // Convert offsets into TBytes indices
  if Result then
  begin
    FStart := Offsets[1];
    if Offsets[0] = Offsets[1] then
      Inc(FStart); // Make sure we don't get stuck at the same position
    if Assigned(OnMatch) then
      OnMatch(Self)
  end;
end;

function TPerlRegEx.MatchAgain: Boolean;

  function UTF8Len(const B: UTF8Char): Integer; inline;
  begin
    case Byte(B) of
      $00..$7F: Result := 1; //
      $C2..$DF: Result := 2; // 110x xxxx C0 - DF
      $E0..$EF: Result := 3; // 1110 xxxx E0 - EF
      $F0..$F7: Result := 4; // 1111 0xxx F0 - F7
    else
      Result := 1; // Illegal leading character. Advanced one byte.
    end;
  end;

var
  Opts: Integer;
begin
  ClearStoredGroups;
  if not Compiled then
    Compile;
  if preNotBOL in State then
    Opts := PCRE_NOTBOL
  else
    Opts := 0;
  if preNotEOL in State then
    Opts := Opts or PCRE_NOTEOL;
  if preNotEmpty in State then
    Opts := Opts or PCRE_NOTEMPTY;
  Opts := Opts or PCRE_NO_UTF8_CHECK;
  OffsetCount := pcre_exec(FPattern, FHints, PUTF8Char(FSubject), FStop, FStart, Opts, @Offsets[0], High(Offsets));
  Result := OffsetCount > 0;
  // Convert offsets into TBytes indices
  if Result then
  begin
//    for I := 0 to OffsetCount*2-1 do
//      Inc(Offsets[I]);
    FStart := Offsets[1];
    if Offsets[0] = Offsets[1] then // Make sure we don't get stuck at the same position
      if (0 <= Offsets[0]) and (Offsets[0] <= Length(FSubject)) then
        Inc(FStart, UTF8Len(FSubject[Offsets[0] + 1]))
      else
        Inc(FStart);
    if Assigned(OnMatch) then
      OnMatch(Self)
  end;
end;

function TPerlRegEx.NamedGroup(const Name: string): Integer;
begin
  Result := pcre_get_stringnumber(FPattern, PAnsiChar(UTF8String(Name)));
end;

procedure FlushLastIndexCache(const R:TPerlRegEx); inline;
begin
  R.LastIndex1 := 0;
  R.LastIndexResult1 := 0;
  R.LastIndex2 := 0;
  R.LastIndexResult2 := 0;
end;

function TPerlRegEx.Replace: string;
var
  Tmp: UTF8String;
begin
  if not FoundMatch then
    raise ERegularExpressionError.CreateRes(@SRegExMatchRequired);
  // Substitute backreferences
  Result := ComputeReplacement;
  // Allow for just-in-time substitution determination
  if Assigned(OnReplace) then
    OnReplace(Self, Result);
  Tmp := UTF8String(Result);
  // Perform substitution
  Delete(FSubject, InternalGetMatchedOffset+1, InternalGetMatchedLength);
  if Result <> '' then
    Insert(Tmp, FSubject, InternalGetMatchedOffset+1);
  FlushLastIndexCache(Self);
  // Position to continue search
  FStart := FStart - InternalGetMatchedLength +  Length(Tmp);
  FStop := FStop - InternalGetMatchedLength + Length(Tmp);
  // Replacement no longer matches regex, we assume
  ClearStoredGroups;
  OffsetCount := 0;
end;

function TPerlRegEx.ReplaceAll: Boolean;
begin
  if Match then
  begin
    Result := True;
    repeat
      Replace
    until not MatchAgain;
  end
  else
    Result := False;
end;

procedure TPerlRegEx.SetOptions(Value: TPerlRegExOptions);
begin
  if (FOptions <> Value) then
  begin
    FOptions := Value;
    FPCREOptions := PCRE_UTF8 or PCRE_NEWLINE_ANY;
    if (preCaseLess in Value) then
      FPCREOptions := FPCREOptions or PCRE_CASELESS;
    if (preMultiLine in Value) then
      FPCREOptions := FPCREOptions or PCRE_MULTILINE;
    if (preSingleLine in Value) then
      FPCREOptions := FPCREOptions or PCRE_DOTALL;
    if (preExtended in Value) then
      FPCREOptions := FPCREOptions or PCRE_EXTENDED;
    if (preAnchored in Value) then
      FPCREOptions := FPCREOptions or PCRE_ANCHORED;
    if (preUnGreedy in Value) then
      FPCREOptions := FPCREOptions or PCRE_UNGREEDY;
    if (preNoAutoCapture in Value) then
      FPCREOptions := FPCREOptions or PCRE_NO_AUTO_CAPTURE;
    CleanUp
  end
end;

procedure TPerlRegEx.SetRegEx(const Value: string);
begin
  if FRegEx <> Value then
  begin
    FRegEx := Value;
    CleanUp
  end
end;

procedure TPerlRegEx.SetReplacement(const Value: string);
begin
  FReplacement := UTF8String(Value);
end;

procedure TPerlRegEx.SetStart(const Value: Integer);
begin
  if Value < 1 then
    FStart := 0
  else
    FStart := Value - 1;
  // If FStart >= Length(Subject), MatchAgain() will simply return False
end;

procedure TPerlRegEx.SetStop(const Value: Integer);
begin
  if Value > Length(FSubject) then
    FStop := Length(FSubject)
  else
    FStop := Value;
end;

procedure TPerlRegEx.SetFSubject(const Value: UTF8String);
begin
  FSubject := Value;
  FlushLastIndexCache(Self);
  FStart := 0;
  FStop := Length(FSubject);
  if not FHasStoredGroups then
    OffsetCount := 0;
end;

procedure TPerlRegEx.SetSubject(const Value: string);
begin
  SetFSubject(UTF8String(Value));
end;

procedure TPerlRegEx.Split(const Strings: TStrings; Limit: Integer);
var
  Offset, Count: Integer;
begin
  if Strings = nil then
    raise ERegularExpressionError.CreateRes(@SRegExStringsRequired);

  if (Limit = 1) or not Match then
    Strings.Add(Subject)
  else
  begin
    Offset := 0;
    Count := 1;
    repeat
      Strings.Add(string(Copy(FSubject, Offset+1, InternalGetMatchedOffset - Offset)));
      Inc(Count);
      Offset := InternalGetMatchedOffset + InternalGetMatchedLength ;
    until ((Limit > 1) and (Count >= Limit)) or not MatchAgain;
    Strings.Add(string(Copy(FSubject, Offset+1, Length(FSubject) - Offset)));
  end
end;

procedure TPerlRegEx.SplitCapture(const Strings: TStrings; Limit, Offset: Integer);
var
  Count: Integer;
  LUseOffset: Boolean;
  LOffset: Integer;
begin
  if Strings = nil then
    raise ERegularExpressionError.CreateRes(@SRegExStringsRequired);

  if (Limit = 1) or not Match then
    Strings.Add(Subject)
  else
  begin
    Dec(Offset); // One based to zero based
    LUseOffset := Offset <> 0;
    if Offset <> 0 then
      Dec(Limit);
    LOffset := 0;
    Count := 1;
    repeat
      if LUseOffset then
      begin
        if InternalGetMatchedOffset >= Offset then
        begin
          LUseOffset := False;
          Strings.Add(string(Copy(FSubject, 1, InternalGetMatchedOffset)));
          if Self.GroupCount > 0 then
            Strings.Add(Groups[GroupCount]);
        end;
      end
      else
      begin
        Strings.Add(string(Copy(FSubject, LOffset+1, InternalGetMatchedOffset - LOffset)));
        Inc(Count);
        if Self.GroupCount > 0 then
          Strings.Add(Groups[GroupCount]);
      end;
      LOffset := InternalGetMatchedOffset + InternalGetMatchedLength ;
    until ((Limit > 1) and (Count >= Limit)) or not MatchAgain;
    Strings.Add(string(Copy(FSubject, LOffset+1, Length(FSubject) - LOffset)));
  end
end;

procedure TPerlRegEx.SplitCapture(const Strings: TStrings; Limit: Integer);
begin
  SplitCapture(Strings,Limit,1);
end;

procedure TPerlRegEx.StoreGroups;
var
  I: Integer;
begin
  if OffsetCount > 0 then
  begin
    ClearStoredGroups;
    SetLength(FStoredGroups, GroupCount+1);
    for I := GroupCount downto 0 do
      FStoredGroups[I] := Groups[I];
    FHasStoredGroups := True;
  end
end;

procedure TPerlRegEx.Study;
var
  Error: PAnsiChar;
begin
  if not FCompiled then
    Compile;
  FHints := pcre_study(FPattern, 0, @Error);
  if Error <> nil then
    raise ERegularExpressionError.CreateResFmt(@SRegExStudyError, [string(Error)]);
  FStudied := True
end;

function TPerlRegEx.UTF8IndexToUnicode(AIndex: Integer): Integer;
var
  I: Integer;
  Ptr,Target: PUTF8Char;
begin
  if AIndex > Length(FSubject) then
    raise ERegularExpressionError.CreateResFmt(@SRegExIndexOutOfBounds, [AIndex]);

  if AIndex <= 0 then
  begin
    Result := 0;
    Exit;
  end;

  if AIndex = LastIndex1 then
  begin
    Result := LastIndexResult1;
    Exit;
  end;

  if AIndex = LastIndex2 then
  begin
    Result := LastIndexResult2; 
    Exit;
  end;

  if LastIndex1 < AIndex then
  begin
    Result := LastIndexResult1;
    I := LastIndex1;
  end
  else
  if LastIndex2 < AIndex then
  begin
    Result := LastIndexResult2;
    I := LastIndex2;
  end
  else
  begin
    // 0 < AIndex < LastIndex2 < LastIndex1
    LastIndexResult1 := LastIndexResult2;
    LastIndex1 := LastIndex2;
    LastIndexResult2 := 0;
    LastIndex2 := 0;
    // 0 = LastIndex2 < AIndex < LastIndex1
    Result := 0;
    I := 0;
  end;

  Ptr := PUTF8Char(FSubject) + I;
  Target := PUTF8Char(FSubject) + AIndex;
  while Ptr < Target do
  begin
    if (Byte(Ptr^) and $C0) <> $80 then // Skip UTF8 Trail-bytes
      Inc(Result);
    Inc(Ptr);
  end;

  if (LastIndex2 = 0) and (LastIndex1 < AIndex) then
  begin
    LastIndex2 := LastIndex1;
    LastIndexResult2 := LastIndexResult1;
  end;
  if LastIndex1 < AIndex then
  begin
    LastIndex1 := AIndex;
    LastIndexResult1 := Result;
  end
  else
  begin
    LastIndex2 := AIndex;
    LastIndexResult2 := Result;
  end;
end;

{ TPerlRegExList }

function TPerlRegExList.Add(const ARegEx: TPerlRegEx): Integer;
begin
  Result := FList.Add(ARegEx);
  UpdateRegEx(ARegEx);
end;

procedure TPerlRegExList.Clear;
begin
  FList.Clear;
end;

constructor TPerlRegExList.Create;
begin
  inherited Create;
  FList := TObjectList.Create;
end;

procedure TPerlRegExList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TPerlRegExList.Destroy;
begin
  FList.Free;
  inherited
end;

function TPerlRegExList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPerlRegExList.GetRegEx(Index: Integer): TPerlRegEx;
begin
  Result := TPerlRegEx(Pointer(FList[Index]));
end;

function TPerlRegExList.GetStart: Integer;
begin
  Result := FStart + 1;
end;

function TPerlRegExList.GetStop: Integer;
begin
  Result := FStop + 1;
end;

function TPerlRegExList.GetSubject: string;
begin
  Result := string(FSubject);
end;

function TPerlRegExList.IndexOf(const ARegEx: TPerlRegEx): Integer;
begin
  Result := FList.IndexOf(ARegEx);
end;

procedure TPerlRegExList.Insert(Index: Integer; const ARegEx: TPerlRegEx);
begin
  FList.Insert(Index, ARegEx);
  UpdateRegEx(ARegEx);
end;

function TPerlRegExList.Match: Boolean;
begin
  SetStart(1);
  FMatchedRegEx := nil;
  Result := MatchAgain;
end;

function TPerlRegExList.MatchAgain: Boolean;
var
  I, MatchStart, MatchPos: Integer;
  ARegEx: TPerlRegEx;
begin
  if FMatchedRegEx <> nil then
    MatchStart := FMatchedRegEx.InternalGetMatchedOffset + FMatchedRegEx.InternalGetMatchedLength
  else
    MatchStart := FStart;
  FMatchedRegEx := nil;
  MatchPos := MaxInt;
  for I := 0 to Count-1 do
  begin
    ARegEx := RegEx[I];
    if (not ARegEx.FoundMatch) or (ARegEx.InternalGetMatchedOffset < MatchStart) then
    begin
      ARegEx.FStart := MatchStart;
      ARegEx.MatchAgain;
    end;
    if ARegEx.FoundMatch and (ARegEx.InternalGetMatchedOffset < MatchPos) then
    begin
      MatchPos := ARegEx.InternalGetMatchedOffset;
      FMatchedRegEx := ARegEx;
    end;
    if MatchPos = MatchStart then Break;
  end;
  Result := MatchPos < MaxInt;
end;

procedure TPerlRegExList.SetRegEx(Index: Integer; const Value: TPerlRegEx);
begin
  FList[Index] := Value;
  UpdateRegEx(Value);
end;

procedure TPerlRegExList.SetStart(const Value: Integer);
var
  I: Integer;
begin
  if FStart <> (Value - 1) then
  begin
    FStart := Value - 1;
    for I := Count-1 downto 0 do
      RegEx[I].Start := Value;
    FMatchedRegEx := nil;
  end;
end;

procedure TPerlRegExList.SetStop(const Value: Integer);
var
  I: Integer;
begin
  if FStop <> Value then
  begin
    FStop := Value;
    for I := Count-1 downto 0 do
      RegEx[I].Stop := Value;
    FMatchedRegEx := nil;
  end;
end;

procedure TPerlRegExList.SetSubject(const Value: string);
var
  I: Integer;
begin
  FSubject := UTF8String(Value);
  for I := Count-1 downto 0 do
    RegEx[I].SetFSubject(FSubject);
  FMatchedRegEx := nil;
end;

procedure TPerlRegExList.UpdateRegEx(const ARegEx: TPerlRegEx);
begin
  ARegEx.SetFSubject(FSubject);
  ARegEx.FStart := FStart;
end;

end.

