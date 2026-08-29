myfsqrt — Square Root Without an FPU - moved from gitlab

float myfsqrt(float) in NASM, with the floating-point and vector units off limits. The root is built digit by digit, radix-4, on the integer significand — shifts, adds, subtracts and compares only, not a single multiply or divide.

The interesting part is the edges, and they are all handled: denormals get a normalising loop, negatives return qNaN 0x7FC00000, signalling NaNs are quieted, ±inf and −0 pass through. Validated against sqrtf with an error measured in ULPs. Two builds: 32- and 64-bit SysV. 
