# Tworzy plik wykonywalny 'program' z main.o i myfsqrt.o
program: main.o myfsqrt.o
	cc -m32 -g -o program main.o myfsqrt.o

# Kompilacja C
main.o: main.c
	cc -m32 -g -c main.c

# Kompilacja ASM
myfsqrt.o: myfsqrt.s
	nasm -f elf32 -g myfsqrt.s

# Test poprawnosci (osobny plik, poza scope projektu) - wymaga -lm
test: test.c myfsqrt.o
	cc -m32 -g -o runtest test.c myfsqrt.o -lm
	./runtest

clean:
	rm -f *.o program runtest