#include <stdio.h>
#include <stdlib.h>

// Deklaracja funkcji z asemblera
extern float myfsqrt(float f);

int main(int argc, char *argv[])
{
    if (argc == 2)
    {
        float x = strtof(argv[1], NULL);
        printf("myfsqrt(%g) = %g\n", x, myfsqrt(x));
    }
    else
    {
        printf("Blad! Uzycie: %s <liczba np 9.0>\n", argv[0]);
    }

    return 0;
}