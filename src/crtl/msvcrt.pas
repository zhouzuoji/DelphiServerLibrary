unit msvcrt;

interface

{$ALIGN ON}
{$MINENUMSIZE 4}
{$WEAKPACKAGEUNIT}

uses
  Windows, SysUtils;

const
  msvcrt_dll = 'msvcrt.dll';
  {$EXTERNALSYM msvcrt_dll}

type
  size_t = NativeInt;
{$IFDEF NEXTGEN}
  PAnsiChar = MarshaledAString;
  PPAnsiChar = ^PAnsiChar;
{$ENDIF}

  va_list = Pointer;
  {$EXTERNALSYM va_list}

  qsort_compare_func = function(P1, P2: Pointer): Integer; cdecl;
  {$EXTERNALSYM qsort_compare_func}

  time_t = {$IFDEF Win32} Integer {$ENDIF}
           {$IFDEF Win64} Int64 {$ENDIF};
  {$EXTERNALSYM time_t}
  Ptime_t = ^time_t;
  {$EXTERNALSYM Ptime_t}
  _time64_t = Int64;
  {$EXTERNALSYM _time64_t}
  P_time64_t = ^_time64_t;
  {$EXTERNALSYM P_time64_t}
  tm = packed record
    tm_sec: Integer;            { Seconds.      [0-60] (1 leap second) }
    tm_min: Integer;            { Minutes.      [0-59]  }
    tm_hour: Integer;           { Hours.        [0-23]  }
    tm_mday: Integer;           { Day.          [1-31]  }
    tm_mon: Integer;            { Month.        [0-11]  }
    tm_year: Integer;           { Year          - 1900. }
    tm_wday: Integer;           { Day of week.  [0-6]   }
    tm_yday: Integer;           { Days in year. [0-365] }
    tm_isdst: Integer;          { DST.          [-1/0/1]}
  end;
  {$EXTERNALSYM tm}
  Ptm = ^tm;
  {$EXTERNALSYM Ptm}

function abort: Pointer; cdecl;
{$EXTERNALSYM abort}
function &exit: Pointer; cdecl;
{$EXTERNALSYM exit}
function _exit: Pointer; cdecl;
{$EXTERNALSYM _exit}
function &raise: Pointer; cdecl;
{$EXTERNALSYM raise}
function _getpid: Pointer; cdecl;
{$EXTERNALSYM _getpid}
function signal: Pointer; cdecl;
{$EXTERNALSYM signal}
function getenv: Pointer; cdecl;
{$EXTERNALSYM getenv}

{ ----------------------------------------------------- }
{       Memory                                          }
{ ----------------------------------------------------- }

procedure  __alloca_helper; cdecl;
{$EXTERNALSYM __alloca_helper}
function  malloc(size: size_t): Pointer; cdecl;
{$EXTERNALSYM malloc}
function calloc(numElements, sizeOfElement: size_t): Pointer; cdecl;
{$EXTERNALSYM calloc}
function realloc(P: Pointer; NewSize: size_t): Pointer; cdecl;
{$EXTERNALSYM realloc}
procedure  free(pBlock: Pointer); cdecl;
{$EXTERNALSYM free}

{ ----------------------------------------------------- }
{       CString                                         }
{ ----------------------------------------------------- }

function  memchr(s: Pointer; c: Integer; n: size_t): Pointer; cdecl;
{$EXTERNALSYM memchr}
function  memcmp(buf1: Pointer; buf2: Pointer; n: size_t): Integer; cdecl;
{$EXTERNALSYM memcmp}
function  memcpy(dest, src: Pointer; count: size_t): Pointer; cdecl;
{$EXTERNALSYM memcpy}
function  memmove(dest, src: Pointer; count: size_t): Pointer; cdecl;
{$EXTERNALSYM memmove}
function  memset(dest: Pointer; val: Integer; count: size_t): Pointer; cdecl;
{$EXTERNALSYM memset}
function  strcat(dest: PAnsiChar; src: PAnsiChar): PAnsiChar; cdecl;
{$EXTERNALSYM strcat}
function  strcpy(dest, src: PAnsiChar): PAnsiChar; cdecl;
{$EXTERNALSYM strcpy}
function  strncpy(dest, src: PAnsiChar; n: size_t): PAnsiChar; cdecl;
{$EXTERNALSYM strncpy}
function  strcmp(s1: PAnsiChar; s2: PAnsiChar): Integer; cdecl;
{$EXTERNALSYM strcmp}
function  strncmp(s1: PAnsiChar; s2: PAnsiChar; n: size_t): Integer; cdecl;
{$EXTERNALSYM strncmp}
function  strlen(s: PAnsiChar): size_t; cdecl;
{$EXTERNALSYM strlen}
function  strnlen(s: PAnsiChar; n: size_t): size_t; cdecl;
{$EXTERNALSYM strnlen}
function  strchr(__s: PAnsiChar; __c: Integer): PAnsiChar; cdecl;
{$EXTERNALSYM strchr}
function strstr(const str1, str2: PAnsiChar): PAnsiChar; cdecl;
{$EXTERNALSYM strstr}
function  strrchr(__s: PAnsiChar; __c: Integer): PAnsiChar; cdecl;
{$EXTERNALSYM strrchr}
function  strerror(__errnum: Integer): PAnsiChar; cdecl;
{$EXTERNALSYM strerror}
function strcspn(const str1, str2: PAnsiChar): size_t; cdecl;
{$EXTERNALSYM strcspn}
function stricmp(const str1, str2: PAnsiChar): Integer; cdecl;
{$EXTERNALSYM stricmp}
function _stricmp(const str1, str2: PAnsiChar): Integer; cdecl;
{$EXTERNALSYM _stricmp}
function strnicmp: Pointer; cdecl;
{$EXTERNALSYM strnicmp}
function _mbscspn(const str, strCharSet: PWideChar): size_t; cdecl;
{$EXTERNALSYM _mbscspn}
function mbstowcs(pwcs: PWideChar; const s: PWideChar;n: size_t): size_t; cdecl;
{$EXTERNALSYM mbstowcs}
function wcslen(str: PWideChar): size_t; cdecl;
{$EXTERNALSYM wcslen}
function wcsnlen(str: PWideChar; n: size_t): size_t; cdecl;
{$EXTERNALSYM wcsnlen}
function wcstombs(s:Pointer; const pwcs:Pointer; n:Integer):Integer; cdecl;
{$EXTERNALSYM wcstombs}
function wcsstr(const str1, str2: PWideChar): PWideChar; cdecl;
{$EXTERNALSYM wcsstr}
function wcscpy(dest, src: PWideChar): PWideChar; cdecl;
{$EXTERNALSYM wcscpy}

{ ----------------------------------------------------- }
{       Locale                                          }
{ ----------------------------------------------------- }

function  tolower(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM tolower}
function  toupper(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM toupper}
function  towlower(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM towlower}
function  towupper(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM towupper}
function  isalnum(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM isalnum}
function  isalpha(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM isalpha}
function  iscntrl(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM iscntrl}
function  isdigit(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM isdigit}
function  isgraph(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM isgraph}
function  islower(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM islower}
function  isprint(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM isprint}
function  ispunct(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM ispunct}
function  isspace(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM isspace}
function  isupper(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM isupper}
function  isxdigit(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM isxdigit}
function _ismbblead(c: Cardinal): Integer; cdecl;
{$EXTERNALSYM _ismbblead}


{ ----------------------------------------------------- }
{       IO                                              }
{ ----------------------------------------------------- }
function _open(const __path: PAnsiChar; __access: Integer; __permission: Integer): Integer; cdecl;
{$EXTERNALSYM _open}
function _wopen(const __path: PChar; __access: Integer; __permission: Integer): Integer; cdecl;
{$EXTERNALSYM _wopen}
function fopen: Pointer; cdecl;
{$EXTERNALSYM fopen}
function _wfopen: Pointer; cdecl;
{$EXTERNALSYM _wfopen}
function _fdopen: Pointer; cdecl;
{$EXTERNALSYM _fdopen}
function _close(__handle: Integer): Integer; cdecl;
{$EXTERNALSYM _close}
function fclose: Pointer; cdecl;
{$EXTERNALSYM fclose}

function lseek(__handle: Integer; __offset: Integer; __fromwhere: Integer): Integer; cdecl;
{$EXTERNALSYM lseek}
function _lseek(__handle: Integer; __offset: Integer; __fromwhere: Integer): Integer; cdecl;
{$EXTERNALSYM _lseek}
function fseek(__handle: Integer; __offset: Integer; __fromwhere: Integer): Integer; cdecl;
{$EXTERNALSYM fseek}
function ftell: Pointer; cdecl;
{$EXTERNALSYM ftell}
function _read(__handle: Integer; __buf: Pointer; __len: LongWord): Integer; cdecl;
{$EXTERNALSYM _read}
function fread: Pointer; cdecl;
{$EXTERNALSYM fread}
function _write(__handle: Integer; __buf: Pointer; __len: LongWord): Integer; cdecl;
{$EXTERNALSYM _write}
function fwrite: Pointer; cdecl;
{$EXTERNALSYM fwrite}
function getch: Pointer; cdecl;
{$EXTERNALSYM getch}
function fgets: Pointer; cdecl;
{$EXTERNALSYM fgets}
function fputs: Pointer; cdecl;
{$EXTERNALSYM fputs}
function fflush: Pointer; cdecl;
{$EXTERNALSYM fflush}
function rename(const __oldname, __newname: PAnsiChar): Integer; cdecl;
{$EXTERNALSYM rename}
function setmode: Pointer; cdecl;
{$EXTERNALSYM setmode}
function _chmod: Pointer; cdecl;
{$EXTERNALSYM _chmod}
function _stat: Pointer; cdecl;
{$EXTERNALSYM _stat}
function setvbuf: Pointer; cdecl;
{$EXTERNALSYM setvbuf}
{ ----------------------------------------------------- }
{       Standard IO                                     }
{ ----------------------------------------------------- }

function perror: Pointer; cdecl;
{$EXTERNALSYM perror}
function  printf(format: PAnsiChar): Integer; cdecl; varargs;
{$EXTERNALSYM printf}
function  fprintf(fHandle: Pointer; format: PAnsiChar): Integer; cdecl; varargs;
{$EXTERNALSYM fprintf}
function  sprintf(buf: Pointer; format: PAnsiChar): Integer; cdecl; varargs;
{$EXTERNALSYM sprintf}
function _snprintf(buf: Pointer; nzize: size_t; format: PAnsiChar; param: va_list): Integer; cdecl;
{$EXTERNALSYM _snprintf}
function vsnprintf(buf: Pointer; nzize: size_t; format: PAnsiChar; param: va_list): Integer; cdecl;
{$EXTERNALSYM vsnprintf}
function _vsnprintf(buf: Pointer; nzize: size_t; format: PAnsiChar; param: va_list): Integer; cdecl;
{$EXTERNALSYM _vsnprintf}
function sscanf: Pointer; cdecl;
{$EXTERNALSYM sscanf}

{ ----------------------------------------------------- }
{       Conversion                                      }
{ ----------------------------------------------------- }
function strtol: ULONG; cdecl;
{$EXTERNALSYM strtol}
function strtoul: ULONG; cdecl;
{$EXTERNALSYM strtoul}
function _itoa(value: Integer; str: PAnsiChar; radix: Integer): PAnsiChar; cdecl;
{$EXTERNALSYM _itoa}
function itoa(value: Integer; str: PAnsiChar; radix: Integer): PAnsiChar; cdecl;
{$EXTERNALSYM itoa}
function _i64toa(value: Int64; str: PAnsiChar; radix: Integer): PAnsiChar; cdecl;
{$EXTERNALSYM _i64toa}
function _atoi64(const str: PAnsiChar): Int64; cdecl;
{$EXTERNALSYM _atoi64}
function atoi(const str: PAnsiChar): Integer; cdecl;
{$EXTERNALSYM atoi}
function atof(value: PAnsiChar): Double; cdecl;
{$EXTERNALSYM atof}
function atol(const str: PAnsiChar): LongInt; cdecl;
{$EXTERNALSYM atol}
function strtod(value: PAnsiChar; endPtr: PPAnsiChar): Double; cdecl;
{$EXTERNALSYM strtod}
function gcvt(value: double; digits: Integer; buffer: PAnsiChar): PAnsiChar; cdecl;
{$EXTERNALSYM gcvt}
function _gcvt(value: double; digits: Integer; buffer: PAnsiChar): PAnsiChar; cdecl;
{$EXTERNALSYM _gcvt}

const
  _fltused: Integer = $9875;  // from stubs.c in MS crtl
  {$EXTERNALSYM _fltused}
  _streams: array [0..2] of NativeInt = (0, 1, 2);
  {$EXTERNALSYM _streams}
var
  _errno: Integer;
  {$EXTERNALSYM _errno}
  __errno: Integer;
  {$EXTERNALSYM __errno}
  ___errno: Integer;
  {$EXTERNALSYM ___errno}
  __turboFloat: Integer = 0; // Win32
  {$EXTERNALSYM __turboFloat}

procedure _mbctype; // Not a function, pointer to data
{$EXTERNALSYM _mbctype}

{$IFDEF WIN64}
procedure _purecall; cdecl;
function _lseeki64(__handle: Integer; __offset: Int64; __fromwhere: Integer): Int64; cdecl;
{$EXTERNALSYM _lseeki64}
{$ENDIF}


{$IFDEF WIN32}
procedure _llmod; cdecl;
{$EXTERNALSYM _llmod}
procedure _lldiv; cdecl;
{$EXTERNALSYM _lldiv}
procedure _lludiv; cdecl;
{$EXTERNALSYM _lludiv}
procedure _llmul; cdecl;
{$EXTERNALSYM _llmul}
procedure _llumod; cdecl;
{$EXTERNALSYM _llumod}
procedure _llshl; cdecl;
{$EXTERNALSYM _llshl}
procedure _llshr; cdecl;
{$EXTERNALSYM _llshr}
procedure _llushr; cdecl;
{$EXTERNALSYM _llushr}
procedure __pure_error_;
{$EXTERNALSYM __pure_error_}
function GetMem2(Size: NativeInt): Pointer;
{$EXTERNALSYM GetMem2}
function SysFreeMem2(p: Pointer): Integer;
{$EXTERNALSYM SysFreeMem2}
function _malloc(size: size_t): Pointer; cdecl;
{$EXTERNALSYM _malloc}
function _realloc(P: Pointer; NewSize: size_t): Pointer; cdecl;
{$EXTERNALSYM _realloc}
procedure _free(pBlock: Pointer); cdecl;
{$EXTERNALSYM _free}
function __atold(value: PAnsiChar; endPtr: PPAnsiChar): Extended; cdecl;
{$EXTERNALSYM __atold}
procedure _ftol; cdecl; external;
{$EXTERNALSYM _ftol}
procedure __ftol; cdecl; external;
{$EXTERNALSYM __ftol}
procedure _ftoul; cdecl;
{$EXTERNALSYM _ftoul}
procedure __ftoul; cdecl; external;
{$EXTERNALSYM __ftoul}
procedure __mbctype; // Not a function, pointer to data
{$EXTERNALSYM __mbctype}
function  _ltolower(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM _ltolower}
function  _ltoupper(__ch: Integer): Integer; cdecl;
{$EXTERNALSYM _ltoupper}
function _ltowlower(c:Integer):Integer; cdecl;
{$EXTERNALSYM _ltowlower}
function _ltowupper(c:Integer):Integer; cdecl;
{$EXTERNALSYM _ltowupper}
procedure __ltolower; cdecl;
{$EXTERNALSYM __ltolower}
procedure __ltoupper; cdecl;
{$EXTERNALSYM __ltoupper}
procedure __ltowlower; cdecl;
{$EXTERNALSYM __ltowlower}
procedure __ltowupper; cdecl;
{$EXTERNALSYM __ltowupper}
procedure _atof; cdecl;
{$EXTERNALSYM _atof}
procedure _atol; cdecl;
{$EXTERNALSYM _atol}
procedure _strcspn; cdecl;
{$EXTERNALSYM _strcspn}
procedure _strcat; cdecl;
{$EXTERNALSYM _strcat}
procedure _strcmp; cdecl;
{$EXTERNALSYM _strcmp}
procedure _strncmp; cdecl;
{$EXTERNALSYM _strncmp}
procedure _strcpy; cdecl;
{$EXTERNALSYM _strcpy}
procedure _strncpy; cdecl;
{$EXTERNALSYM _strncpy}
procedure _memmove; cdecl;
{$EXTERNALSYM _memmove}
procedure _memset; cdecl;
{$EXTERNALSYM _memset}
procedure _memcpy; cdecl;
{$EXTERNALSYM _memcpy}
procedure _memcmp; cdecl;
{$EXTERNALSYM _memcmp}
procedure _memchr; cdecl;
{$EXTERNALSYM _memchr}
procedure _strlen; cdecl;
{$EXTERNALSYM _strlen}
procedure _islower; cdecl;
{$EXTERNALSYM _islower}
procedure _isdigit; cdecl;
{$EXTERNALSYM _isdigit}
procedure _isupper; cdecl;
{$EXTERNALSYM _isupper}
procedure _isalnum; cdecl;
{$EXTERNALSYM _isalnum}
procedure _isspace; cdecl;
{$EXTERNALSYM _isspace}
procedure _isxdigit; cdecl;
{$EXTERNALSYM _isxdigit}
procedure _isgraph; cdecl;
{$EXTERNALSYM _isgraph}
procedure _isprint; cdecl;
{$EXTERNALSYM _isprint}
procedure _ispunct; cdecl;
{$EXTERNALSYM _ispunct}
procedure _iscntrl; cdecl;
{$EXTERNALSYM _iscntrl}
procedure _isalpha; cdecl;
{$EXTERNALSYM _isalpha}
procedure _strchr; cdecl;
{$EXTERNALSYM _strchr}
procedure _strnlen; cdecl;
{$EXTERNALSYM _strnlen}
procedure _wcslen; cdecl;
{$EXTERNALSYM _wcslen}
procedure _wcsnlen; cdecl;
{$EXTERNALSYM _wcsnlen}
procedure _printf; cdecl;
{$EXTERNALSYM _printf}
procedure _fprintf; cdecl;
{$EXTERNALSYM _fprintf}
procedure _sprintf; cdecl;
{$EXTERNALSYM _sprintf}
procedure __vsnprintf; cdecl;
{$EXTERNALSYM __vsnprintf}
procedure _tolower; cdecl;
{$EXTERNALSYM _tolower}
procedure _toupper; cdecl;
{$EXTERNALSYM _toupper}
procedure __mbscspn; cdecl;
{$EXTERNALSYM __mbscspn}
procedure __i64toa; cdecl;
{$EXTERNALSYM __i64toa}
procedure __atoi64; cdecl;
{$EXTERNALSYM __atoi64}
procedure _strstr; cdecl;
{$EXTERNALSYM _strstr}
procedure _mbstowcs; cdecl;
{$EXTERNALSYM _mbstowcs}
procedure _wcstombs; cdecl;
{$EXTERNALSYM _wcstombs}
procedure _strerror; cdecl;
{$EXTERNALSYM _strerror}
{$ENDIF WIN32}

procedure qsort(baseP: PByte; NElem, Width: size_t; comparF: qsort_compare_func); cdecl;
{$EXTERNALSYM qsort}

{ time }
function time: Pointer; cdecl;
function gmtime: Pointer; cdecl;
function localtime(t: Ptime_t): Ptm; cdecl;
{$EXTERNALSYM localtime}

function _beginthreadex(security_attr: Pointer; stksize: LongWord;
  start: Pointer; arg: Pointer; create_flags: LongWord;
  var thread_id: LongWord): LongWord; cdecl;
{$EXTERNALSYM _beginthreadex}
procedure _endthreadex(thread_retval: LongWord);
{$EXTERNALSYM _endthreadex}

function log(__x: Double): Double; cdecl;
{$EXTERNALSYM log}

{$ifdef WIN32}
{$L .\win32\ftol.obj}
{$L .\win32\_ftoul.obj}
{$endif}

{$ifdef WIN64}
{$L .\win64\ftol.obj}
{$L .\win64\_ftoul.obj}
{$endif}

implementation

{ ----------------------------------------------------- }
{       Memory                                          }
{ ----------------------------------------------------- }

(*----------------------------------------------------------------------
 copied from C++ Builder rtl source _alloca.asm
 Name          __alloca_helper - allocate temporary stack memory

 Usage         void *alloca(size_t size)

 Prototype in  malloc.h

 Description   __alloca_helper allocates size bytes on the stack the
		allocated space is automatically freed up when the calling
		function exits.

		This function is different from _alloca, because it takes
		an extra parameter, the number of dwords already pushed
		for the current statement.

		The current compiler will force a stackframe when it
		encounters calls to alloca.

               This is an internal function that corresponds to the
               user-visible function alloca().  That function is
               declared in malloc.h.

 Return value  Returns a pointer to the allocated stack area on success.
               If the stack cannot be extended, a NULL pointer is returned.
               The returned pointer should never be passed to free().

 Note          Compatible with Microsoft C and UNIX.  Not recommended.
               Use malloc() instead.
----------------------------------------------------------------------*)

procedure __alloca_helper; cdecl; assembler;
asm
// current stack:
//	pushed entries?
// 	pushed stack depth
// 	requested size of alloca
// 	return address

  pop     edx             // pop return address
  pop     eax             // pop size parameter
	pop	    ecx		          // pop pushed stack depth

// We need an extra register further down. We do this by keeping the return
// addrress on the stack and moving it along with any previously pushed entries.
// The drawback is that we probe one more DWORD than the user requested.

	push	  edx		          // store return address
	inc	    ecx		          // make pushed return address extra entry to move
  add     eax,3           // round size up to multiple of 4
  and     eax,not 3
  neg     eax             // negate size
  add     eax,esp         // add current stack pointer
  cmp     eax,esp         // would new ESP wrap around?
  ja      @bad2           // yes - return error

// Get the current thread's stack base.  The RTL stores this in the
// thread local storage variable named _stkindex.

  (*
  push    eax             // save new ESP
	push	  ecx		          // save pushed stack depth
  call    ___GetStkIndex  // Get the stack base value (in TLS.C)
  add     eax, 4096*4     //  add four extra pages since NT will
                          //  fault upon any access to the guard page
                          //  and the RTL may use up some more stack.

  mov     edx, eax        // put stack base in EDX
	pop	    ecx		          // recover pushed stack depth
  pop     eax             // recover new ESP
  cmp     edx, eax        // would new ESP fall below stack base?
  ja      @bad2
  *)

// The current stack looks like this, from high to low address:
//       pushed entries?
//       pushed entries?
// ESP-> pushed return address
//       ... empty space ...
// EAX -> new stack area

// We must probe the stack in 4K increments to force NT to un-guard the
// stack guard pages.  At this point, EAX contains the future value of ESP.

  mov     edx, esp        // save current ESP into EDX
@probeloop2:
  sub     esp, 4096       // bump down to the next page
  cmp     esp, eax        // any more stack left to probe?
  jb      @movepushes     // no - we're done
  add     esp, 4          // probe next page by pushing a
  push    0               // dummy value
  jmp     @probeloop2

// We are going to move the entries already pushed on the stack
// to below the newly allocated stack area.

@movepushes:
  mov     esp, eax        // set up new ESP
	push	  ebx		          // we need one more register
@moveloop:
	mov	    ebx, [edx]	    // get the pushed entry
	mov	    [eax], ebx	    // and move it
	add	    eax, 4
	add	    edx, 4		      // move the fences
	dec	    ecx
	jnz	    @moveloop
	pop	    ebx		          // recover ebx
@return2:
	pop	    edx		          // recover return address
  // if PopParms@ eq 0
  sub     esp, 4          // fake argument for caller to pop
  // alloca is prototyped as taking one parameter
  // endif
  jmp     edx             // return

// Come here if there isn't enough stack space.  Return a null pointer.
@bad2:
  xor     eax,eax         // return NULL pointer
  jmp     @return2
end;

procedure msvc_alloca; cdecl; assembler;
const
  _PAGESIZE_ = $1000;
asm
  push  ecx
  // Calculate new TOS.
  lea   ecx,[esp+4] // TOS before entering function + size for ret value
  sub   ecx, eax                    // new TOS
  (* Handle allocation size that results in wraparound.
     Wraparound will result in StackOverflow exception. *)
  sbb   eax,eax  // 0 if CF==0, ~0 if CF==1
  not   eax      // ~0 if TOS did not wrapped around, 0 otherwise
  and   ecx,eax  // set to 0 if wraparound
  mov   eax,esp  // current TOS
  //and   eax,0FFFFF000h
  and eax, not ( _PAGESIZE_ - 1) //and eax, not ( _PAGESIZE_ - 1) Round down to current page boundary
  @cs10:
  cmp   ecx,eax   // Is new TOS
  //bnd jb short @cs20              ; in probed page?
  db $F2
  db $72
  db $0B
  mov   eax,ecx // yes. 001F2F79 8B C1                mov         eax,ecx
  pop   ecx
  xchg  eax,esp  // update esp
  mov   eax,dword ptr [eax] // get return address
  mov   dword ptr [esp],eax  // and put it at new TOS
  dw    $C3F2 // bnd ret

@cs20: //Find next lower page and probe
  sub   eax, _PAGESIZE_  // decrease by PAGESIZE
  test  dword ptr [eax],eax // probe page.
  jmp   @cs10   // jmp     short cs10 EB E7
end;

function  malloc(size: size_t): Pointer; cdecl;
begin
  Result := AllocMem(size);
end;

function calloc(numElements, sizeOfElement: size_t): Pointer; cdecl;
begin
  Result := AllocMem(numElements * sizeOfElement);
end;

function realloc(P: Pointer; NewSize: size_t): Pointer; cdecl;
begin
  ReallocMem(P, Newsize);
  Result := P;
end;

procedure free(pBlock: Pointer); cdecl;
begin
  FreeMem(pBlock);
end;

{$IFDEF WIN64}
procedure _purecall; cdecl;
asm
  jmp System.@AbstractError
end;

function _lseeki64; external msvcrt_dll;
{$ENDIF}

{$IFDEF WIN32}
procedure _llmod; cdecl;
asm
  jmp System.@_llmod;
end;

procedure _lldiv; cdecl;
asm
  jmp System.@_lldiv
end;

procedure _lludiv; cdecl;
asm
  jmp System.@_lludiv
end;

procedure _llmul; cdecl;
asm
  jmp System.@_llmul
end;

procedure _llumod; cdecl;
asm
  jmp System.@_llumod
end;

procedure _llshl; cdecl;
asm
  jmp System.@_llshl
end;

procedure _llshr; cdecl;
asm
        AND   CL, $3F
        CMP   CL, 32
        JL    @__llshr@below32
        MOV   EAX, EDX
        CDQ
        SAR   EAX,CL
        RET

@__llshr@below32:
        SHRD  EAX, EDX, CL
        SAR   EDX, CL
        RET
end;

procedure _llushr; cdecl;
asm
  jmp System.@_llushr
end;

function _malloc(size: size_t): Pointer; cdecl;
begin
  try
    Result := AllocMem(size);
  except
    Result := nil;
  end;
end;

function _realloc(P: Pointer; NewSize: size_t): Pointer; cdecl;
begin
  try
    ReallocMem(P, Newsize);
    Result := P;
  except
    Result := nil;
  end;
end;

procedure _free(pBlock: Pointer); cdecl;
begin
  FreeMem(pBlock);
end;

procedure __pure_error_;
asm
  JMP  System.@AbstractError
end;

// C++'s alloc allocates 1 byte if size is 0.
function GetMem2(Size: NativeInt): Pointer;
begin
  if Size = 0 then Inc(Size);
  GetMem(Result, Size);
end;

// C++'s free allow NULL pointer.
function SysFreeMem2(p: Pointer): Integer;
begin
  result := 0;
  if (p <> NIL) then result := FreeMemory(p);
end;

function __atold(value: PAnsiChar; endPtr: PPAnsiChar): Extended; cdecl;
var
  s: string;
begin
  s := string(Value);
  if endPtr <> nil then
    endPtr^ := value;
  if not TryStrToFloat(s, Result) then
    Result := 0
  else if endPtr <> nil then
    endPtr^ := PAnsiChar(Value) + Length(s);
end;

procedure _ftoul; cdecl;
asm
  JMP  System.@Trunc
end;
{$ENDIF WIN32}

function abort; external msvcrt_dll name 'abort';
function exit; external msvcrt_dll name 'exit';
function _exit; external msvcrt_dll name '_exit';
function &raise; external msvcrt_dll name 'raise';
function _getpid; external msvcrt_dll name '_getpid';
function signal; external msvcrt_dll name 'signal';
function getenv; external msvcrt_dll name 'getenv';

{ ----------------------------------------------------- }
{       CString                                         }
{ ----------------------------------------------------- }

function  memchr; external msvcrt_dll;
function  memcmp; external msvcrt_dll;
function  memcpy; external msvcrt_dll;
function  memmove; external msvcrt_dll;
function  memset; external msvcrt_dll;
function  strcat; external msvcrt_dll;
function  strcpy; external msvcrt_dll;
function  strncpy; external msvcrt_dll;
function  strcmp; external msvcrt_dll;
function  strncmp; external msvcrt_dll;
function  strlen; external msvcrt_dll;
function  strnlen; external msvcrt_dll;
function  strchr; external msvcrt_dll;
function  strrchr; external msvcrt_dll name 'strrchr';
function  strerror; external msvcrt_dll;
function strcspn; external msvcrt_dll;
function stricmp; external msvcrt_dll name '_stricmp';
function _stricmp; external msvcrt_dll;
function strnicmp; external msvcrt_dll name '_strnicmp';
function _mbscspn; external msvcrt_dll;
function mbstowcs; external msvcrt_dll;
function wcslen; external msvcrt_dll;
function wcsnlen; external msvcrt_dll;
function wcstombs; external msvcrt_dll;
function strstr; external msvcrt_dll;
function wcsstr; external msvcrt_dll name 'wcsstr';
function wcscpy; external msvcrt_dll;

{ ----------------------------------------------------- }
{       Locale                                          }
{ ----------------------------------------------------- }

function  tolower; external msvcrt_dll;
function  toupper; external msvcrt_dll;
function  towlower; external msvcrt_dll;
function  towupper; external msvcrt_dll;
function  isalnum; external msvcrt_dll;
function  isalpha; external msvcrt_dll;
function  iscntrl; external msvcrt_dll;
function  isdigit; external msvcrt_dll;
function  isgraph; external msvcrt_dll;
function  islower; external msvcrt_dll;
function  isprint; external msvcrt_dll;
function  ispunct; external msvcrt_dll;
function  isspace; external msvcrt_dll;
function  isupper; external msvcrt_dll;
function  isxdigit; external msvcrt_dll;
function _ismbblead; external msvcrt_dll;

{ ----------------------------------------------------- }
{       IO                                              }
{ ----------------------------------------------------- }

function _wopen; external msvcrt_dll;
function _open; external msvcrt_dll;
function fopen; external msvcrt_dll name 'fopen';
function _fdopen; external msvcrt_dll name '_fdopen';
function _wfopen; external msvcrt_dll name '_wfopen';
function _close; external msvcrt_dll;
function fclose; external msvcrt_dll name 'fclose';
function _lseek; external msvcrt_dll;
function lseek; external msvcrt_dll name '_lseek';
function fseek; external msvcrt_dll name 'fseek';
function ftell; external msvcrt_dll name 'ftell';
function fflush; external msvcrt_dll name 'fflush';

function _read; external msvcrt_dll;
function fread; external msvcrt_dll name 'fread';
function _write; external msvcrt_dll;
function fwrite; external msvcrt_dll;
function getch; external msvcrt_dll name '_getch';
function fgets; external msvcrt_dll name 'fgets';
function fputs; external msvcrt_dll name 'fputs';

function rename; external msvcrt_dll;
function setmode; external msvcrt_dll name '_setmode';
function _chmod; external msvcrt_dll name '_chmod';
function _stat; external msvcrt_dll name '_stat';
function setvbuf; external msvcrt_dll name 'setvbuf';

{ ----------------------------------------------------- }
{       Standard IO                                     }
{ ----------------------------------------------------- }
function perror; external msvcrt_dll name 'perror';
function  printf; external msvcrt_dll;
function  fprintf; external msvcrt_dll;
function  sprintf; external msvcrt_dll;
function _snprintf; external msvcrt_dll;
function vsnprintf; external msvcrt_dll name '_vsnprintf';
function _vsnprintf; external msvcrt_dll;
function sscanf; external msvcrt_dll name 'sscanf';

{ ----------------------------------------------------- }
{       Conversion                                      }
{ ----------------------------------------------------- }
function strtol; external msvcrt_dll name 'strtol';
function strtoul; external msvcrt_dll name 'strtoul';
function _itoa; external msvcrt_dll;
function itoa; external msvcrt_dll name '_itoa';
function _i64toa; external msvcrt_dll;
function _atoi64; external msvcrt_dll;
function atoi; external msvcrt_dll;
function atof; external msvcrt_dll;
function atol; external msvcrt_dll;
function strtod; external msvcrt_dll;
function gcvt; external msvcrt_dll name '_gcvt';
function _gcvt; external msvcrt_dll;
procedure _mbctype; external msvcrt_dll; // Not a function, pointer to data

{$IFDEF WIN32}
procedure __mbctype; external msvcrt_dll name '_mbctype'; // Not a function, pointer to data
function  _ltolower; external msvcrt_dll name 'tolower';
function  _ltoupper; external msvcrt_dll name 'toupper';
function _ltowlower; external msvcrt_dll name 'towlower';
function _ltowupper; external msvcrt_dll name 'towupper';
procedure __ltolower; external msvcrt_dll name 'tolower';
procedure __ltoupper; external msvcrt_dll name 'toupper';
procedure __ltowlower; external msvcrt_dll name 'towlower';
procedure __ltowupper; external msvcrt_dll name 'towupper';
procedure _atof; external msvcrt_dll name 'atof';
procedure _atol; external msvcrt_dll name 'atol';
procedure _strcspn; external msvcrt_dll name 'strcspn';
procedure _strcat; external msvcrt_dll name 'strcat';
procedure _strcmp; external msvcrt_dll name 'strcmp';
procedure _strncmp; external msvcrt_dll name 'strncmp';
procedure _strcpy; external msvcrt_dll name 'strcpy';
procedure _strncpy; external msvcrt_dll name 'strncpy';
procedure _memmove; external msvcrt_dll name 'memmove';
procedure _memset; external msvcrt_dll name 'memset';
procedure _memcpy; external msvcrt_dll name 'memcpy';
procedure _memcmp; external msvcrt_dll name 'memcmp';
procedure _memchr; external msvcrt_dll name 'memchr';
procedure _strlen; external msvcrt_dll name 'strlen';
procedure _islower; external msvcrt_dll name 'islower';
procedure _isdigit; external msvcrt_dll name 'isdigit';
procedure _isupper; external msvcrt_dll name 'isupper';
procedure _isalnum; external msvcrt_dll name 'isalnum';
procedure _isspace; external msvcrt_dll name 'isspace';
procedure _isxdigit; external msvcrt_dll name 'isxdigit';
procedure _isgraph; external msvcrt_dll name 'isgraph';
procedure _isprint; external msvcrt_dll name 'isprint';
procedure _ispunct; external msvcrt_dll name 'ispunct';
procedure _iscntrl; external msvcrt_dll name 'iscntrl';
procedure _isalpha; external msvcrt_dll name 'isalpha';
procedure _strchr; external msvcrt_dll name 'strchr';
procedure _strnlen; external msvcrt_dll name 'strnlen';
procedure _wcslen; external msvcrt_dll name 'wcslen';
procedure _wcsnlen; external msvcrt_dll name 'wcsnlen';
procedure _printf; external msvcrt_dll name 'printf';
procedure _fprintf; external msvcrt_dll name 'fprintf';
procedure _sprintf; external msvcrt_dll name 'sprintf';
procedure __vsnprintf; external msvcrt_dll name '_vsnprintf';
procedure _tolower; external msvcrt_dll name 'tolower';
procedure _toupper; external msvcrt_dll name 'toupper';
procedure __mbscspn; external msvcrt_dll name '_mbscspn';
procedure __i64toa; external msvcrt_dll name '_i64toa';
procedure __atoi64; external msvcrt_dll name '_atoi64';
procedure _strstr; external msvcrt_dll name 'strstr';
procedure _mbstowcs; external msvcrt_dll name 'mbstowcs';
procedure _wcstombs; external msvcrt_dll name 'wcstombs';
procedure _strerror; external msvcrt_dll name 'strerror';
{$ENDIF WIN32}

procedure qsort; external msvcrt_dll;
function time; external msvcrt_dll;
function gmtime; external msvcrt_dll name 'gmtime';
function localtime; external msvcrt_dll;
function _beginthreadex; external msvcrt_dll;
procedure _endthreadex; external msvcrt_dll;

function log; external msvcrt_dll;

end.

