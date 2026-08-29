# Uruchamiane przez GDB gdy cwd = x32_version (auto-load lub: gdb -x .gdbinit)
set debuginfod enabled off
set architecture i386
# GDB nie ma output-radix 2 — binarnie: print/t $eax  lub  source gdb-myfsqrt.gdb
set output-radix 16
