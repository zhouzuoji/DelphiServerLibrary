function sar32(value: UInt32; bits: Byte): UInt32;
asm
  mov cl, bits
  sar value, cl
end;

(* copy from Delphi 2010 RTL *)
function StrLenA(const str: PAnsiChar): Integer;
asm
  { Check the first byte }
  cmp byte ptr [eax], 0
  je @ZeroLength
  { Get the negative of the string start in edx }
  mov edx, eax
  neg edx
  { Word align }
  add eax, 1
  and eax, -2
@ScanLoop:
  mov cx, [eax]
  add eax, 2
  test cl, ch
  jnz @ScanLoop
  test cl, cl
  jz @ReturnLess2
  test ch, ch
  jnz @ScanLoop
  lea eax, [eax + edx - 1]
  ret
@ReturnLess2:
  lea eax, [eax + edx - 2]
  ret
@ZeroLength:
  xor eax, eax
end;

(* copy from Delphi 2010 RTL *)
  function StrLenW(s: PWideChar): Integer;
asm
  { Check the first byte }
  cmp word ptr [eax], 0
  je @ZeroLength
  { Get the negative of the string start in edx }
  mov edx, eax
  neg edx
@ScanLoop:
  mov cx, word ptr [eax]
  add eax, 2
  test cx, cx
  jnz @ScanLoop
  lea eax, [eax + edx - 2]
  shr eax, 1
  ret
@ZeroLength:
  xor eax, eax
end;

    function StrPosA(substr: PAnsiChar; sublen: Integer; str: PAnsiChar; len: Integer): PAnsiChar;
asm
      test  eax,eax
      je    @noWork
      test  ecx,ecx
      je    @retNil
      test  edx, edx
      jle   @retNil
      cmp   edx, len
      jg    @retNil
      push  ebx
      push  esi
      mov   ebx, sublen
      mov   edx, str
      add   esp, -16
      mov   esi, len
      dec   ebx
      add   esi, edx
      add   edx, ebx
      mov   [esp+8], esi
      add   eax, ebx
      mov   [esp+4], edx
      neg   ebx
      movzx ecx, byte ptr [eax]
      mov   [esp], ebx
      jnz   @FindString

      sub   esi, 2
      mov   [esp+12], esi

@FindChar2:
      cmp   cl, [edx]
      jz    @Matched0ch
      cmp   cl, [edx+1]
      jz    @Matched1ch
      add   edx, 2
      cmp   edx, [esp+12]
      jb    @FindChar4
      cmp   edx, [esp+8]
      jb    @FindChar2
      xor    eax,eax
      jmp    @exit;

@FindChar4:
      cmp   cl, [edx]
      jz    @Matched0ch
      cmp   cl, [edx+1]
      jz    @Matched1ch
      cmp   cl, [edx+2]
      jz    @Matched2ch
      cmp   cl, [edx+3]
      jz    @Matched3ch
      add   edx, 4
      cmp   edx, [esp+12]
      jb    @FindChar4
      cmp   edx, [esp+8]
      jb    @FindChar2
      xor   eax, eax
      jmp   @exit

@Matched2ch:
      add   edx, 2

@Matched0ch:
      inc   edx
      mov   eax, edx
      add   eax, [esp]
      dec eax
      jmp   @exit

@Matched3ch:
      add   edx, 2

@Matched1ch:
      add   edx, 2
      xor   eax, eax
      cmp   edx, [esp+8]
      ja    @exit
      mov   eax, edx
      add   eax, [esp]
      dec eax
      jmp    @exit

@FindString4:
      cmp   cl, [edx]
      jz    @Test0
      cmp   cl, [edx+1]
      jz    @Test1
      cmp   cl, [edx+2]
      jz    @Test2
      cmp   cl, [edx+3]
      jz    @Test3
      add   edx, 4
      cmp   edx, [esp+12]
      jb    @FindString4
      cmp   edx, [esp+8]
      jb    @FindString2
      xor   eax, eax
      jmp   @exit

@FindString:
      sub   esi, 2
      mov   [esp+12], esi

@FindString2:
      cmp   cl, [edx]
      jz    @Test0

@AfterTest0:
      cmp   cl, [edx+1]
      jz    @Test1

@AfterTest1:
      add   edx, 2
      cmp   edx, [esp+12]
      jb    @FindString4
      cmp   edx, [esp+8]
      jb    @FindString2
      xor   eax, eax
      jmp   @exit

@Test3:
      add   edx, 2

@Test1:
      mov   esi, [esp]

@Loop1:
      movzx ebx, word ptr [esi+eax]
      cmp   bx, word ptr [esi+edx+1]
      jnz   @AfterTest1
      add   esi, 2
      jl    @Loop1
      add   edx, 2
      xor   eax, eax
      cmp   edx, [esp+8]
      ja    @exit

@RetCode1:
      mov   eax, edx
      add   eax, [esp]
      dec eax
      jmp   @exit

@Test2:
      add   edx,2

@Test0:
      mov   esi, [esp]

@Loop0:
      movzx ebx, word ptr [esi+eax]
      cmp   bx, word ptr [esi+edx]
      jnz   @AfterTest0
      add   esi, 2
      jl    @Loop0
      inc   edx
@RetCode0:
      mov   eax, edx
      add   eax, [esp]
      dec eax

@exit:
      add   esp, 16
      pop   esi
      pop   ebx
      jmp  @noWork

@retNil:
      xor eax, eax

@noWork:
end;

      function SysUtils_StrPosA(str, substr: PAnsiChar): PAnsiChar;
      assembler;
      { copy from SysUtils }
asm
  PUSH    EDI
  PUSH    ESI
  PUSH    EBX
  OR      EAX,EAX
  JE      @@2
  OR      EDX,EDX
  JE      @@2
  MOV     EBX,EAX
  MOV     EDI,EDX
  XOR     AL,AL
  MOV     ECX,0FFFFFFFFH
  REPNE   SCASB
  NOT     ECX
  DEC     ECX
  JE      @@2
  MOV     ESI,ECX
  MOV     EDI,EBX
  MOV     ECX,0FFFFFFFFH
  REPNE   SCASB
  NOT     ECX
  SUB     ECX,ESI
  JBE     @@2
  MOV     EDI,EBX
  LEA     EBX,[ESI-1]
@@1:    MOV     ESI,EDX
  LODSB
  REPNE   SCASB
  JNE     @@2
  MOV     EAX,ECX
  PUSH    EDI
  MOV     ECX,EBX
  REPE    CMPSB
  POP     EDI
  MOV     ECX,EAX
  JNE     @@1
  LEA     EAX,[EDI-1]
  JMP     @@3
@@2:    XOR     EAX,EAX
@@3:    POP     EBX
  POP     ESI
  POP     EDI
end;

        function SysUtils_StrPosW(str, substr: PWideChar): PWideChar;
        assembler;
        { copy from SysUtils }
asm
  PUSH    EDI
  PUSH    ESI
  PUSH    EBX
  OR      EAX,EAX
  JE      @@2
  OR      EDX,EDX
  JE      @@2
  MOV     EBX,EAX
  MOV     EDI,EDX
  XOR     AX,AX
  MOV     ECX,0FFFFFFFFH
  REPNE   SCASW
  NOT     ECX
  DEC     ECX
  JE      @@2
  MOV     ESI,ECX
  MOV     EDI,EBX
  MOV     ECX,0FFFFFFFFH
  REPNE   SCASW
  NOT     ECX
  SUB     ECX,ESI
  JBE     @@2
  MOV     EDI,EBX
  LEA     EBX,[ESI-1]
@@1:    MOV     ESI,EDX
  LODSW
  REPNE   SCASW
  JNE     @@2
  MOV     EAX,ECX
  PUSH    EDI
  MOV     ECX,EBX
  REPE    CMPSW
  POP     EDI
  MOV     ECX,EAX
  JNE     @@1
  LEA     EAX,[EDI-2]
  JMP     @@3
@@2:    XOR     EAX,EAX
@@3:    POP     EBX
  POP     ESI
  POP     EDI
end;