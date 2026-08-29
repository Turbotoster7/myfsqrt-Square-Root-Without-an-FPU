; ================================================================
; float myfsqrt(float f)  -  pierwiastek kwadratowy bez FPU/SSE-math
;
; Metoda: pierwiastek "cyfra po cyfrze" (radix-4) na liczbie
; calkowitej. Nie ma tu dzielenia ani mnozenia - tylko przesuniecia,
; dodawanie, odejmowanie i porownania.
;
; ABI 32-bit (cdecl): argument na stosie, wynik float w ST(0).
; Uklad skokow:
;   - normalna liczba: jmp do .have_sig (po kilku instr., nie po jcc)
;   - denormal: .dnloop -> fall-through do .have_sig (bez jmp po jz)
;   - NaN/inf/znak: handlery -> .finish
;   - wynik: .have_sig -> fall-through do .finish
; ================================================================

global myfsqrt
section .text

myfsqrt:
    mov   eax, [esp+4]        ; EAX = bity f (czytamy przed pushami)
    push  ebx
    push  esi
    push  edi

    mov   edx, eax
    shr   edx, 23
    and   edx, 0xFF           ; EDX = wykladnik E

    ; --- filtry: tylko odchylenia od sciezki normalnej ---
    cmp   edx, 0xFF
    je    .expmax
    test  eax, eax
    js    .negzero
    test  edx, edx
    jz    .denorm_or_zero

    ; --- normalna (E >= 1): EDX = e, EAX = sig ---
    sub   edx, 127
    and   eax, 0x7FFFFF
    or    eax, 0x800000
    jmp   .have_sig

; --- rzadkie przypadki ---

.expmax:
    test  eax, 0x7FFFFF
    jnz   .finish             ; NaN -> zwroc bez zmian
    test  eax, eax
    jns   .finish             ; +inf -> sqrt(+inf) = +inf
    mov   eax, 0x7FC00000     ; -inf -> NaN
    jmp   .finish

.negzero:
    test  eax, 0x7FFFFFFF
    jz    .finish             ; -0 -> sqrt(-0) = -0
    mov   eax, 0x7FC00000     ; ujemna -> NaN
    jmp   .finish

.denorm_or_zero:
    test  eax, eax
    jz    .finish             ; +0 -> zwroc 0
    and   eax, 0x7FFFFF
    mov   edx, -126
.dnloop:
    dec   edx
    add   eax, eax
    test  eax, 0x800000
    jz    .dnloop             ; wyjscie z petli -> fall-through do .have_sig

; --- wspolne liczenie pierwiastka (EDX = e, EAX = sig) ---

.have_sig:
    mov   ecx, edx
    and   ecx, 1              ; parzystosc e
    add   ecx, 23             ; CL = 23 + (e&1)
    sar   edx, 1
    add   edx, 126            ; Ebase
    push  edx

    xor   edx, edx
    shld  edx, eax, cl
    shl   eax, cl             ; EDX:EAX = V

    xor   ebx, ebx            ; root
    xor   ecx, ecx            ; rem
    mov   esi, 32
.sqloop:
    shld  ecx, edx, 2
    shld  edx, eax, 2
    shl   eax, 2
    add   ebx, ebx
    lea   edi, [ebx*2+1]
    cmp   ecx, edi
    jb    .noset
    sub   ecx, edi
    inc   ebx
.noset:
    dec   esi
    jnz   .sqloop

    cmp   ecx, ebx
    ja    .round_up
    jb    .noround
    test  ebx, 1
    jz    .noround
.round_up:
    inc   ebx
.noround:
    pop   ecx
    shl   ecx, 23
    lea   eax, [ecx + ebx]

.finish:
    pop   edi
    pop   esi
    pop   ebx
    push  eax
    fld   dword [esp]
    add   esp, 4
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
