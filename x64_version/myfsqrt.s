; ================================================================
; float myfsqrt(float f)  -  pierwiastek kwadratowy bez FPU/SSE-math
;
; Metoda: pierwiastek "cyfra po cyfrze" (radix-4) na liczbie
; calkowitej. Brak dzielenia i mnozenia - tylko przesuniecia,
; dodawanie, odejmowanie i porownania.
;
; ABI 64-bit (System V): argument w XMM0, wynik w XMM0.
; Uklad skokow jak w x32: denormal fall-through, handlery na koncu.
; ================================================================

global myfsqrt
section .text

myfsqrt:
    movd  eax, xmm0
    mov   edx, eax
    shr   edx, 23
    and   edx, 0xFF           ; EDX = wykladnik E

    cmp   edx, 0xFF
    je    .expmax
    test  eax, eax
    js    .negzero
    test  edx, edx
    jz    .denorm_or_zero

    sub   edx, 127
    and   eax, 0x7FFFFF
    or    eax, 0x800000
    jmp   .have_sig

.expmax:
    test  eax, 0x7FFFFF
    jnz   .finish
    test  eax, eax
    jns   .finish
    mov   eax, 0x7FC00000
    jmp   .finish

.negzero:
    test  eax, 0x7FFFFFFF
    jz    .finish
    mov   eax, 0x7FC00000
    jmp   .finish

.denorm_or_zero:
    test  eax, eax
    jz    .finish
    and   eax, 0x7FFFFF
    mov   edx, -126
.dnloop:
    dec   edx
    add   eax, eax
    test  eax, 0x800000
    jz    .dnloop

.have_sig:
    mov   ecx, edx
    and   ecx, 1
    add   ecx, 23
    sar   edx, 1
    add   edx, 126
    mov   r11d, edx

    xor   edx, edx
    shld  edx, eax, cl
    shl   eax, cl

    xor   r8d, r8d
    xor   ecx, ecx
    mov   r9d, 32
.sqloop:
    shld  ecx, edx, 2
    shld  edx, eax, 2
    shl   eax, 2
    add   r8d, r8d
    lea   r10d, [r8*2+1]
    cmp   ecx, r10d
    jb    .noset
    sub   ecx, r10d
    inc   r8d
.noset:
    dec   r9d
    jnz   .sqloop

    cmp   ecx, r8d
    ja    .round_up
    jb    .noround
    test  r8d, 1
    jz    .noround
.round_up:
    inc   r8d
.noround:
    mov   ecx, r11d
    shl   ecx, 23
    lea   eax, [rcx + r8]

.finish:
    movd  xmm0, eax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
