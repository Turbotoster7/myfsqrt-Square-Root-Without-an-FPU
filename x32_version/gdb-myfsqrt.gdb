# GDB nie obsluguje "set output-radix 2" (tylko 8, 10, 16).
# Binarny podglad: print/t lub komendy ponizej.

define b32
  print/t $arg0
end
document b32
  32 bity binarnie, np.: b32 $eax
end

define bregs
  printf "EAX="
  print/t $eax
  printf "EDX="
  print/t $edx
  printf "EBX="
  print/t $ebx
  printf "ECX="
  print/t $ecx
  printf "ESI="
  print/t $esi
  printf "EDI="
  print/t $edi
end
document bregs
  Rejestry uzywane w myfsqrt (binarnie).
end
