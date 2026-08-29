#include <stdio.h>
#include <stdint.h>
#include <string.h>
float myfsqrt(float f);
int main(void) {
    float f = 9.0f;
    float r = myfsqrt(f);
    uint32_t u, v;
    memcpy(&u, &r, 4);
    memcpy(&v, &f, 4);
    printf("in=%08x out=%08x\n", v, u);
    return 0;
}
