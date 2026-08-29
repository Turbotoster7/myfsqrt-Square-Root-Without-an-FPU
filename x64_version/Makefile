# Tworzy plik wykonywalny 'program' z main.o i myfsqrt.o
program: main.o myfsqrt.o
	cc -m64 -g -no-pie -o program main.o myfsqrt.o

# Kompilacja C
main.o: main.c
	cc -m64 -g -no-pie -c main.c

# Kompilacja ASM
myfsqrt.o: myfsqrt.s
	nasm -f elf64 -g myfsqrt.s

# Test poprawnosci (osobny plik, poza scope projektu)
test: test.c myfsqrt.o
	cc -m64 -g -no-pie -o runtest test.c myfsqrt.o -lm
	./runtest

clean:
	rm -f *.o program runtest