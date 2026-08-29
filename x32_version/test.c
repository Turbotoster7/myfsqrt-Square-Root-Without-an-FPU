/* test.c - bateria testow IEEE vs sqrtf (POZA scope projektu)
 *
 * Plik pomocniczy do walidacji soft-float. Nie nalezy do oddawanego
 * projektu - sluzy tylko do sprawdzenia czy myfsqrt dziala poprawnie.
 *
 * Build: cc -m32 -g -mfpmath=sse -msse2 -o test test.c myfsqrt.o -lm
 */
 #include <stdio.h>
 #include <string.h>
 #include <math.h>
 #include <stdint.h>

 float myfsqrt(float f);

 static uint32_t f2b(float f) { uint32_t b; memcpy(&b, &f, 4); return b; }
 static float    b2f(uint32_t b) { float f; memcpy(&f, &b, 4); return f; }

 /* Roznica w ULP-ach (jednostkach ostatniego bitu) */
 static long long ulp_diff(float a, float b) {
     int32_t ia = (int32_t)f2b(a);
     int32_t ib = (int32_t)f2b(b);
     if (ia < 0) ia = 0x80000000 - ia;
     if (ib < 0) ib = 0x80000000 - ib;
     int64_t d = (int64_t)ia - (int64_t)ib;
     return d < 0 ? -d : d;
 }

 typedef struct { uint32_t bits; const char *desc; } TestCase;

 static const TestCase TESTS[] = {
     { 0x00000000, "+0" },
     { 0x80000000, "-0" },
     { 0x3F800000, "1.0" },
     { 0x40800000, "4.0" },
     { 0x41100000, "9.0" },
     { 0x40000000, "2.0" },
     { 0x3E800000, "0.25" },
     { 0x00800000, "min normal (~1.18e-38)" },
     { 0x00000001, "min denormal (~1.4e-45)" },
     { 0x7F000000, "duza (~1.7e38)" },
     { 0x7F800000, "+inf" },
     { 0xFF800000, "-inf" },
     { 0xBF800000, "-1.0" },
     { 0x7FC00000, "qNaN" },
     { 0x7FC00001, "qNaN z payload" },
     { 0x7F800001, "sNaN" },
 };
 #define N_TESTS (sizeof(TESTS)/sizeof(TESTS[0]))

 int main(void) {
     int64_t max_ulp = 0;
     int fail = 0;

     printf("%-28s %12s %12s %10s\n", "wejscie", "myfsqrt", "sqrtf", "ULP");
     printf("------------------------------------------------------------------\n");

     for (size_t i = 0; i < N_TESTS; i++) {
         float in  = b2f(TESTS[i].bits);
         float got = myfsqrt(in);
         float ref = sqrtf(in);

         int both_nan = isnan(got) && isnan(ref);
         long long u = both_nan ? 0 : (long long)ulp_diff(got, ref);
         if (u > max_ulp && !both_nan) max_ulp = u;

         const char *flag = "";
         if (!both_nan && u > 1) { flag = "  <-- FAIL"; fail++; }

         printf("%-28s %12g %12g %10lld%s\n",
                TESTS[i].desc, got, ref, u, flag);
     }

     printf("------------------------------------------------------------------\n");
     printf("max ULP blad: %ld    (cel: <= 1)    fail: %d\n", max_ulp, fail);
     return fail ? 1 : 0;
 }