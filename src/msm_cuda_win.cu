// visual studio compile notes, notice "YOUR" keyword 
// copy msm.fatbin to ~/.aleo/resources/cuda/msm.fatbin
// nvcc.exe -gencode=arch=compute_60,code=sm_60 -gencode=arch=compute_61,code=sm_61 -gencode=arch=compute_70,code=sm_70 -gencode=arch=compute_75,code=sm_75 -gencode=arch=compute_80,code=sm_80 -gencode=arch=compute_86,code=sm_86 --use-local-env -ccbin "YOUR\vs2022\IDE\VC\Tools\MSVC\14.33.31629\bin\HostX64\x64" -x cu   -I./ -I../../../Common -I./ -IYOUR\CUDA\/include -I../../../Common -IYOUR\CUDA\include     --keep-dir x64\Release  -maxrregcount=0  --machine 64 -fatbin -cudart static -Xcompiler "/wd 4819"  --threads 0 -DWIN32 -DWIN32 -D_MBCS -D_MBCS -o msm.fatbin "msm_cuda_win.cu"

#ifndef _ALEO_MSM_CUDA_H_
#define _ALEO_MSM_CUDA_H_

#include <stdio.h>

#ifdef __SIZE_TYPE__
typedef __SIZE_TYPE__ size_t;
#else
#include <stddef.h>
#endif

#include <stdint.h>

#include <string.h>
#include <cuda_runtime.h>

typedef unsigned long long limb_t;
# define LIMB_T_BITS    64

# define TO_LIMB_T(limb64)     limb64

#define NLIMBS(bits)   (bits/LIMB_T_BITS)
#define WINDOW_SIZE 128
// static const uint32_t BLST_WIDTH = 253;

typedef limb_t blst_scalar[NLIMBS(256)];
typedef limb_t blst_fr[NLIMBS(256)];
typedef limb_t blst_fp[NLIMBS(384)];
typedef limb_t vec768[NLIMBS(768)];

typedef struct { blst_fp X, Y; } blst_p1_affine;
typedef struct { blst_fp X, Y, Z; } blst_p1;
typedef struct { blst_fp X, Y, ZZ, ZZZ; } blst_p1_ext;

#define ONE_MONT_P TO_LIMB_T(0x02cdffffffffff68), \
                 TO_LIMB_T(0x51409f837fffffb1), \
                 TO_LIMB_T(0x9f7db3a98a7d3ff2), \
                 TO_LIMB_T(0x7b4e97b76e7c6305), \
                 TO_LIMB_T(0x4cf495bf803c84e8), \
                 TO_LIMB_T(0x008d6661e2fdf49a)

__device__ static const blst_fp BLS12_377_P = {
  TO_LIMB_T(0x8508c00000000001), TO_LIMB_T(0x170b5d4430000000),
  TO_LIMB_T(0x1ef3622fba094800), TO_LIMB_T(0x1a22d9f300f5138f),
  TO_LIMB_T(0xc63b05c06ca1493b), TO_LIMB_T(0x1ae3a4617c510ea)
};
__device__ static const blst_fp BLS12_377_ZERO{ 0 };
__device__ static const blst_fp BLS12_377_ONE{ ONE_MONT_P };
__device__ static const blst_fp BLS12_377_R2{
  0xb786686c9400cd22,
  0x329fcaab00431b1,
  0x22a5f11162d6b46d,
  0xbfdf7d03827dc3ac,
  0x837e92f041790bf9,
  0x6dfccb1e914b88,
};
__device__ static const limb_t BLS12_377_p0 = (limb_t)0x8508bfffffffffff;
__device__ extern const blst_p1 BLS12_377_ZERO_PROJECTIVE;
__device__ extern const blst_p1_affine BLS12_377_ZERO_AFFINE;
__device__ extern const blst_scalar BLS12_377_R;

__device__ static const blst_fp BIGINT_ONE = { 1, 0, 0, 0, 0, 0 };


__device__ const blst_p1 BLS12_377_ZERO_PROJECTIVE = {
  {0},
  {ONE_MONT_P},
  {0}
};

__device__ const blst_p1_affine BLS12_377_ZERO_AFFINE = {
  {0},
  {ONE_MONT_P}
};

__device__ const blst_scalar BLS12_377_R = {
  TO_LIMB_T(0x0a11800000000001), TO_LIMB_T(0x59aa76fed0000001),
  TO_LIMB_T(0x60b44d1e5c37b001), TO_LIMB_T(0x12ab655e9a2ca556)
};

__device__ static inline int is_blst_p1_zero(const blst_p1* p) {
    return p->Z[0] == 0 &&
        p->Z[1] == 0 &&
        p->Z[2] == 0 &&
        p->Z[3] == 0 &&
        p->Z[4] == 0 &&
        p->Z[5] == 0;
}

__device__ static inline int is_blst_fp_zero(const blst_fp p) {
    return p[0] == 0 &&
        p[1] == 0 &&
        p[2] == 0 &&
        p[3] == 0 &&
        p[4] == 0 &&
        p[5] == 0;
}

__device__ static inline int is_blst_fp_eq(const blst_fp p1, const blst_fp p2) {
    return p1[0] == p2[0] &&
        p1[1] == p2[1] &&
        p1[2] == p2[2] &&
        p1[3] == p2[3] &&
        p1[4] == p2[4] &&
        p1[5] == p2[5];
}

__device__ static inline int is_blst_p1_affine_zero(const blst_p1_affine* p) {
    return p->X[0] == 0 &&
        p->X[1] == 0 &&
        p->X[2] == 0 &&
        p->X[3] == 0 &&
        p->X[4] == 0 &&
        p->X[5] == 0;
}


// __device__ void mul_mont_384(blst_fp ret, const blst_fp a, const blst_fp b, const blst_fp p, limb_t p_inv);
// __device__ void sqr_mont_384(blst_fp ret, const blst_fp a, const blst_fp p, limb_t p_inv);
// __device__ void add_mod_384(blst_fp ret, const blst_fp a, const blst_fp b, const blst_fp p);
// __device__ void sub_mod_384(blst_fp ret, const blst_fp a, const blst_fp b, const blst_fp p);
// __device__ void sub_mod_384_unsafe(blst_fp ret, const blst_fp a, const blst_fp b);
// __device__ void add_mod_384_unsafe(blst_fp ret, const blst_fp a, const blst_fp b);
// __device__ void div_by_2_mod_384(blst_fp ret, const blst_fp a);
// __device__ void cneg_mod_384(blst_fp ret, const blst_fp a, bool flag, const blst_fp p);


__device__ static inline int is_gt_384(const blst_fp left, const blst_fp right) {
    for (int i = 5; i >= 0; --i) {
        if (left[i] < right[i]) {
            return 0;
        }
        else if (left[i] > right[i]) {
            return 1;
        }
    }
    return 0;
}

__device__ static inline int is_ge_384(const blst_fp left, const blst_fp right) {
    for (int i = 5; i >= 0; --i) {
        if (left[i] < right[i]) {
            return 0;
        }
        else if (left[i] > right[i]) {
            return 1;
        }
    }
    return 1;
}

__device__ static inline void sub_mod_384_unchecked(blst_fp ret, const blst_fp a, const blst_fp b) {
    asm(
        "sub.cc.u64 %0, %6, %12;\n\t"
        "subc.cc.u64 %1, %7, %13;\n\t"
        "subc.cc.u64 %2, %8, %14;\n\t"
        "subc.cc.u64 %3, %9, %15;\n\t"
        "subc.cc.u64 %4, %10, %16;\n\t"
        "subc.u64 %5, %11, %17;"
        : "=l"(ret[0]),
        "=l"(ret[1]),
        "=l"(ret[2]),
        "=l"(ret[3]),
        "=l"(ret[4]),
        "=l"(ret[5])
        : "l"(a[0]),
        "l"(a[1]),
        "l"(a[2]),
        "l"(a[3]),
        "l"(a[4]),
        "l"(a[5]),
        "l"(b[0]),
        "l"(b[1]),
        "l"(b[2]),
        "l"(b[3]),
        "l"(b[4]),
        "l"(b[5])
    );
    // return cf != 0?
}

__device__ static inline void reduce(blst_fp x, const blst_fp p) {
    if (is_ge_384(x, p)) {
        blst_fp x_sub;
        sub_mod_384_unchecked(x_sub, x, p);
        memcpy(x, x_sub, sizeof(blst_fp));
    }
}


// The Montgomery reduction here is based on Algorithm 14.32 in
// Handbook of Applied Cryptography
// <http://cacr.uwaterloo.ca/hac/about/chap14.pdf>.
__device__ static inline void mont_384(blst_fp ret, limb_t r[12], const blst_fp p, const limb_t p_inv) {
    // printf("c-t%i:0: %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11]);
    limb_t k = r[0] * p_inv;

    limb_t cross_carry = 0;

    asm(
        "{\n\t"
        ".reg .u64 c;\n\t"
        ".reg .u64 t;\n\t"
        ".reg .u64 nc;\n\t"

        "mad.lo.cc.u64 c, %14, %8, %0;\n\t"
        "madc.hi.cc.u64 c, %14, %8, 0;\n\t"

        "addc.cc.u64 t, %1, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %1, %14, %9, t;\n\t"
        "madc.hi.cc.u64 c, %14, %9, nc;\n\t"

        "addc.cc.u64 t, %2, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %2, %14, %10, t;\n\t"
        "madc.hi.cc.u64 c, %14, %10, nc;\n\t"

        "addc.cc.u64 t, %3, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %3, %14, %11, t;\n\t"
        "madc.hi.cc.u64 c, %14, %11, nc;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %14, %12, t;\n\t"
        "madc.hi.cc.u64 c, %14, %12, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %14, %13, t;\n\t"
        "madc.hi.cc.u64 c, %14, %13, nc;\n\t"

        "addc.cc.u64 %6, %6, c;\n\t"
        "addc.u64 %7, 0, 0;\n\t"
        "}"
        : "+l"(r[0]),
        "+l"(r[1]),
        "+l"(r[2]),
        "+l"(r[3]),
        "+l"(r[4]),
        "+l"(r[5]),
        "+l"(r[6]),
        "=l"(cross_carry)
        : "l"(p[0]),
        "l"(p[1]),
        "l"(p[2]),
        "l"(p[3]),
        "l"(p[4]),
        "l"(p[5]),
        "l"(k)
    );

    // printf("c-t%i:1: %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11]);

    k = r[1] * p_inv;

    asm(
        "{\n\t"
        ".reg .u64 c;\n\t"
        ".reg .u64 t;\n\t"
        ".reg .u64 nc;\n\t"

        "mad.lo.cc.u64 c, %14, %8, %0;\n\t"
        "madc.hi.cc.u64 c, %14, %8, 0;\n\t"

        "addc.cc.u64 t, %1, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %1, %14, %9, t;\n\t"
        "madc.hi.cc.u64 c, %14, %9, nc;\n\t"

        "addc.cc.u64 t, %2, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %2, %14, %10, t;\n\t"
        "madc.hi.cc.u64 c, %14, %10, nc;\n\t"

        "addc.cc.u64 t, %3, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %3, %14, %11, t;\n\t"
        "madc.hi.cc.u64 c, %14, %11, nc;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %14, %12, t;\n\t"
        "madc.hi.cc.u64 c, %14, %12, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %14, %13, t;\n\t"
        "madc.hi.cc.u64 c, %14, %13, nc;\n\t"

        "addc.cc.u64 c, c, %7;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "addc.cc.u64 %6, %6, c;\n\t"
        "addc.u64 %7, nc, 0;\n\t"
        "}"
        : "+l"(r[1]),
        "+l"(r[2]),
        "+l"(r[3]),
        "+l"(r[4]),
        "+l"(r[5]),
        "+l"(r[6]),
        "+l"(r[7]),
        "+l"(cross_carry)
        : "l"(p[0]),
        "l"(p[1]),
        "l"(p[2]),
        "l"(p[3]),
        "l"(p[4]),
        "l"(p[5]),
        "l"(k)
    );

    // printf("c-t%i:2: %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11]);
    k = r[2] * p_inv;

    asm(
        "{\n\t"
        ".reg .u64 c;\n\t"
        ".reg .u64 t;\n\t"
        ".reg .u64 nc;\n\t"

        "mad.lo.cc.u64 c, %14, %8, %0;\n\t"
        "madc.hi.cc.u64 c, %14, %8, 0;\n\t"

        "addc.cc.u64 t, %1, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %1, %14, %9, t;\n\t"
        "madc.hi.cc.u64 c, %14, %9, nc;\n\t"

        "addc.cc.u64 t, %2, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %2, %14, %10, t;\n\t"
        "madc.hi.cc.u64 c, %14, %10, nc;\n\t"

        "addc.cc.u64 t, %3, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %3, %14, %11, t;\n\t"
        "madc.hi.cc.u64 c, %14, %11, nc;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %14, %12, t;\n\t"
        "madc.hi.cc.u64 c, %14, %12, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %14, %13, t;\n\t"
        "madc.hi.cc.u64 c, %14, %13, nc;\n\t"

        "addc.cc.u64 c, c, %7;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "addc.cc.u64 %6, %6, c;\n\t"
        "addc.u64 %7, nc, 0;\n\t"
        "}"
        : "+l"(r[2]),
        "+l"(r[3]),
        "+l"(r[4]),
        "+l"(r[5]),
        "+l"(r[6]),
        "+l"(r[7]),
        "+l"(r[8]),
        "+l"(cross_carry)
        : "l"(p[0]),
        "l"(p[1]),
        "l"(p[2]),
        "l"(p[3]),
        "l"(p[4]),
        "l"(p[5]),
        "l"(k)
    );

    // printf("c-t%i:3: %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11]);

    k = r[3] * p_inv;

    asm(
        "{\n\t"
        ".reg .u64 c;\n\t"
        ".reg .u64 t;\n\t"
        ".reg .u64 nc;\n\t"

        "mad.lo.cc.u64 c, %14, %8, %0;\n\t"
        "madc.hi.cc.u64 c, %14, %8, 0;\n\t"

        "addc.cc.u64 t, %1, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %1, %14, %9, t;\n\t"
        "madc.hi.cc.u64 c, %14, %9, nc;\n\t"

        "addc.cc.u64 t, %2, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %2, %14, %10, t;\n\t"
        "madc.hi.cc.u64 c, %14, %10, nc;\n\t"

        "addc.cc.u64 t, %3, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %3, %14, %11, t;\n\t"
        "madc.hi.cc.u64 c, %14, %11, nc;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %14, %12, t;\n\t"
        "madc.hi.cc.u64 c, %14, %12, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %14, %13, t;\n\t"
        "madc.hi.cc.u64 c, %14, %13, nc;\n\t"

        "addc.cc.u64 c, c, %7;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "addc.cc.u64 %6, %6, c;\n\t"
        "addc.u64 %7, nc, 0;\n\t"
        "}"
        : "+l"(r[3]),
        "+l"(r[4]),
        "+l"(r[5]),
        "+l"(r[6]),
        "+l"(r[7]),
        "+l"(r[8]),
        "+l"(r[9]),
        "+l"(cross_carry)
        : "l"(p[0]),
        "l"(p[1]),
        "l"(p[2]),
        "l"(p[3]),
        "l"(p[4]),
        "l"(p[5]),
        "l"(k)
    );

    // printf("c-t%i:4: %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11]);
    k = r[4] * p_inv;

    asm(
        "{\n\t"
        ".reg .u64 c;\n\t"
        ".reg .u64 t;\n\t"
        ".reg .u64 nc;\n\t"

        "mad.lo.cc.u64 c, %14, %8, %0;\n\t"
        "madc.hi.cc.u64 c, %14, %8, 0;\n\t"

        "addc.cc.u64 t, %1, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %1, %14, %9, t;\n\t"
        "madc.hi.cc.u64 c, %14, %9, nc;\n\t"

        "addc.cc.u64 t, %2, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %2, %14, %10, t;\n\t"
        "madc.hi.cc.u64 c, %14, %10, nc;\n\t"

        "addc.cc.u64 t, %3, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %3, %14, %11, t;\n\t"
        "madc.hi.cc.u64 c, %14, %11, nc;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %14, %12, t;\n\t"
        "madc.hi.cc.u64 c, %14, %12, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %14, %13, t;\n\t"
        "madc.hi.cc.u64 c, %14, %13, nc;\n\t"

        "addc.cc.u64 c, c, %7;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "addc.cc.u64 %6, %6, c;\n\t"
        "addc.u64 %7, nc, 0;\n\t"
        "}"
        : "+l"(r[4]),
        "+l"(r[5]),
        "+l"(r[6]),
        "+l"(r[7]),
        "+l"(r[8]),
        "+l"(r[9]),
        "+l"(r[10]),
        "+l"(cross_carry)
        : "l"(p[0]),
        "l"(p[1]),
        "l"(p[2]),
        "l"(p[3]),
        "l"(p[4]),
        "l"(p[5]),
        "l"(k)
    );

    // printf("c-t%i:5: %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11]);
    k = r[5] * p_inv;

    asm(
        "{\n\t"
        ".reg .u64 c;\n\t"
        ".reg .u64 t;\n\t"
        ".reg .u64 nc;\n\t"

        "mad.lo.cc.u64 c, %14, %8, %0;\n\t"
        "madc.hi.cc.u64 c, %14, %8, 0;\n\t"

        "addc.cc.u64 t, %1, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %1, %14, %9, t;\n\t"
        "madc.hi.cc.u64 c, %14, %9, nc;\n\t"

        "addc.cc.u64 t, %2, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %2, %14, %10, t;\n\t"
        "madc.hi.cc.u64 c, %14, %10, nc;\n\t"

        "addc.cc.u64 t, %3, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %3, %14, %11, t;\n\t"
        "madc.hi.cc.u64 c, %14, %11, nc;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %14, %12, t;\n\t"
        "madc.hi.cc.u64 c, %14, %12, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %14, %13, t;\n\t"
        "madc.hi.cc.u64 c, %14, %13, nc;\n\t"

        "addc.cc.u64 c, c, %7;\n\t"
        // "addc.u64 nc, 0, 0;\n\t" if we dont want to clobber cross_carry we need this
        "add.u64 %6, %6, c;\n\t" // and this to be add.cc
        // "addc.u64 %7, nc, 0;\n\t" and this
        "}"
        : "+l"(r[5]),
        "+l"(r[6]),
        "+l"(r[7]),
        "+l"(r[8]),
        "+l"(r[9]),
        "+l"(r[10]),
        "+l"(r[11])
        : "l"(cross_carry),
        "l"(p[0]),
        "l"(p[1]),
        "l"(p[2]),
        "l"(p[3]),
        "l"(p[4]),
        "l"(p[5]),
        "l"(k)
    );

    // printf("c-t%i:6: %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11]);

    memcpy(ret, r + 6, sizeof(limb_t) * 6);
    reduce(ret, p);
}

__device__ void mul_mont_384(blst_fp ret, const blst_fp a, const blst_fp b, const blst_fp p, limb_t p_inv) {
    limb_t r[12];

    asm(
        "{\n\t"
        ".reg .u64 c;\n\t"
        ".reg .u64 nc;\n\t"
        ".reg .u64 t;\n\t"

        "mad.lo.cc.u64 %0, %12, %18, 0;\n\t"
        "madc.hi.cc.u64 c, %12, %18, 0;\n\t"

        "madc.lo.cc.u64 %1, %12, %19, c;\n\t"
        "madc.hi.cc.u64 c, %12, %19, 0;\n\t"

        "madc.lo.cc.u64 %2, %12, %20, c;\n\t"
        "madc.hi.cc.u64 c, %12, %20, 0;\n\t"

        "madc.lo.cc.u64 %3, %12, %21, c;\n\t"
        "madc.hi.cc.u64 c, %12, %21, 0;\n\t"

        "madc.lo.cc.u64 %4, %12, %22, c;\n\t"
        "madc.hi.cc.u64 c, %12, %22, 0;\n\t"

        "madc.lo.cc.u64 %5, %12, %23, c;\n\t"
        "madc.hi.u64 %6, %12, %23, 0;\n\t"


        "mad.lo.cc.u64 %1, %13, %18, %1;\n\t"
        "madc.hi.cc.u64 c, %13, %18, 0;\n\t"

        "addc.cc.u64 t, %2, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %2, %13, %19, t;\n\t"
        "madc.hi.cc.u64 c, %13, %19, nc;\n\t"

        "addc.cc.u64 t, %3, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %3, %13, %20, t;\n\t"
        "madc.hi.cc.u64 c, %13, %20, nc;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %13, %21, t;\n\t"
        "madc.hi.cc.u64 c, %13, %21, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %13, %22, t;\n\t"
        "madc.hi.cc.u64 c, %13, %22, nc;\n\t"

        "addc.cc.u64 t, %6, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %6, %13, %23, t;\n\t"
        "madc.hi.u64 %7, %13, %23, nc;\n\t"


        "mad.lo.cc.u64 %2, %14, %18, %2;\n\t"
        "madc.hi.cc.u64 c, %14, %18, 0;\n\t"

        "addc.cc.u64 t, %3, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %3, %14, %19, t;\n\t"
        "madc.hi.cc.u64 c, %14, %19, nc;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %14, %20, t;\n\t"
        "madc.hi.cc.u64 c, %14, %20, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %14, %21, t;\n\t"
        "madc.hi.cc.u64 c, %14, %21, nc;\n\t"

        "addc.cc.u64 t, %6, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %6, %14, %22, t;\n\t"
        "madc.hi.cc.u64 c, %14, %22, nc;\n\t"

        "addc.cc.u64 t, %7, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %7, %14, %23, t;\n\t"
        "madc.hi.u64 %8, %14, %23, nc;\n\t"



        "mad.lo.cc.u64 %3, %15, %18, %3;\n\t"
        "madc.hi.cc.u64 c, %15, %18, 0;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %15, %19, t;\n\t"
        "madc.hi.cc.u64 c, %15, %19, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %15, %20, t;\n\t"
        "madc.hi.cc.u64 c, %15, %20, nc;\n\t"

        "addc.cc.u64 t, %6, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %6, %15, %21, t;\n\t"
        "madc.hi.cc.u64 c, %15, %21, nc;\n\t"

        "addc.cc.u64 t, %7, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %7, %15, %22, t;\n\t"
        "madc.hi.cc.u64 c, %15, %22, nc;\n\t"

        "addc.cc.u64 t, %8, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %8, %15, %23, t;\n\t"
        "madc.hi.u64 %9, %15, %23, nc;\n\t"




        "mad.lo.cc.u64 %4, %16, %18, %4;\n\t"
        "madc.hi.cc.u64 c, %16, %18, 0;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %16, %19, t;\n\t"
        "madc.hi.cc.u64 c, %16, %19, nc;\n\t"

        "addc.cc.u64 t, %6, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %6, %16, %20, t;\n\t"
        "madc.hi.cc.u64 c, %16, %20, nc;\n\t"

        "addc.cc.u64 t, %7, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %7, %16, %21, t;\n\t"
        "madc.hi.cc.u64 c, %16, %21, nc;\n\t"

        "addc.cc.u64 t, %8, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %8, %16, %22, t;\n\t"
        "madc.hi.cc.u64 c, %16, %22, nc;\n\t"

        "addc.cc.u64 t, %9, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %9, %16, %23, t;\n\t"
        "madc.hi.u64 %10, %16, %23, nc;\n\t"



        "mad.lo.cc.u64 %5, %17, %18, %5;\n\t"
        "madc.hi.cc.u64 c, %17, %18, 0;\n\t"

        "addc.cc.u64 t, %6, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %6, %17, %19, t;\n\t"
        "madc.hi.cc.u64 c, %17, %19, nc;\n\t"

        "addc.cc.u64 t, %7, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %7, %17, %20, t;\n\t"
        "madc.hi.cc.u64 c, %17, %20, nc;\n\t"

        "addc.cc.u64 t, %8, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %8, %17, %21, t;\n\t"
        "madc.hi.cc.u64 c, %17, %21, nc;\n\t"

        "addc.cc.u64 t, %9, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %9, %17, %22, t;\n\t"
        "madc.hi.cc.u64 c, %17, %22, nc;\n\t"

        "addc.cc.u64 t, %10, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %10, %17, %23, t;\n\t"
        "madc.hi.u64 %11, %17, %23, nc;\n\t"

        "}"
        : "+l"(r[0]),
        "+l"(r[1]),
        "+l"(r[2]),
        "+l"(r[3]),
        "+l"(r[4]),
        "+l"(r[5]),
        "+l"(r[6]),
        "+l"(r[7]),
        "+l"(r[8]),
        "+l"(r[9]),
        "+l"(r[10]),
        "+l"(r[11])
        : "l"(a[0]),
        "l"(a[1]),
        "l"(a[2]),
        "l"(a[3]),
        "l"(a[4]),
        "l"(a[5]),
        "l"(b[0]),
        "l"(b[1]),
        "l"(b[2]),
        "l"(b[3]),
        "l"(b[4]),
        "l"(b[5])
    );

    mont_384(ret, r, p, p_inv);
}

__device__ void sqr_mont_384(blst_fp ret, const blst_fp a, const blst_fp p, limb_t p_inv) {
    limb_t r[12];

    asm(
        "{\n\t"
        ".reg .u64 c;\n\t"
        ".reg .u64 nc;\n\t"
        ".reg .u64 t;\n\t"

        "mad.lo.cc.u64 %1, %12, %13, 0;\n\t"
        "madc.hi.cc.u64 c, %12, %13, 0;\n\t"

        "madc.lo.cc.u64 %2, %12, %14, c;\n\t"
        "madc.hi.cc.u64 c, %12, %14, 0;\n\t"

        "madc.lo.cc.u64 %3, %12, %15, c;\n\t"
        "madc.hi.cc.u64 c, %12, %15, 0;\n\t"

        "madc.lo.cc.u64 %4, %12, %16, c;\n\t"
        "madc.hi.cc.u64 c, %12, %16, 0;\n\t"

        "madc.lo.cc.u64 %5, %12, %17, c;\n\t"
        "madc.hi.u64 %6, %12, %17, 0;\n\t"

        "mad.lo.cc.u64 %3, %13, %14, %3;\n\t"
        "madc.hi.cc.u64 c, %13, %14, 0;\n\t"

        "addc.cc.u64 t, %4, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %4, %13, %15, t;\n\t"
        "madc.hi.cc.u64 c, %13, %15, nc;\n\t"

        "addc.cc.u64 t, %5, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %5, %13, %16, t;\n\t"
        "madc.hi.cc.u64 c, %13, %16, nc;\n\t"

        "addc.cc.u64 t, %6, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %6, %13, %17, t;\n\t"
        "madc.hi.u64 %7, %13, %17, nc;\n\t"



        "mad.lo.cc.u64 %5, %14, %15, %5;\n\t"
        "madc.hi.cc.u64 c, %14, %15, 0;\n\t"

        "addc.cc.u64 t, %6, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %6, %14, %16, t;\n\t"
        "madc.hi.cc.u64 c, %14, %16, nc;\n\t"

        "addc.cc.u64 t, %7, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %7, %14, %17, t;\n\t"
        "madc.hi.u64 %8, %14, %17, nc;\n\t"




        "mad.lo.cc.u64 %7, %15, %16, %7;\n\t"
        "madc.hi.cc.u64 c, %15, %16, 0;\n\t"

        "addc.cc.u64 t, %8, c;\n\t"
        "addc.u64 nc, 0, 0;\n\t"
        "mad.lo.cc.u64 %8, %15, %17, t;\n\t"
        "madc.hi.u64 %9, %15, %17, nc;\n\t"



        "mad.lo.cc.u64 %9, %16, %17, %9;\n\t"
        "madc.hi.u64 %10, %16, %17, 0;\n\t"

        "}"
        : "+l"(r[0]),
        "+l"(r[1]),
        "+l"(r[2]),
        "+l"(r[3]),
        "+l"(r[4]),
        "+l"(r[5]),
        "+l"(r[6]),
        "+l"(r[7]),
        "+l"(r[8]),
        "+l"(r[9]),
        "+l"(r[10]),
        "+l"(r[11])
        : "l"(a[0]),
        "l"(a[1]),
        "l"(a[2]),
        "l"(a[3]),
        "l"(a[4]),
        "l"(a[5])
    );

    // printf("c-t%i:0: X, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, X\n", threadIdx.x, r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10]);

    r[11] = r[10] >> 63;
    r[10] = (r[10] << 1) | (r[9] >> 63);
    r[9] = (r[9] << 1) | (r[8] >> 63);
    r[8] = (r[8] << 1) | (r[7] >> 63);
    r[7] = (r[7] << 1) | (r[6] >> 63);
    r[6] = (r[6] << 1) | (r[5] >> 63);
    r[5] = (r[5] << 1) | (r[4] >> 63);
    r[4] = (r[4] << 1) | (r[3] >> 63);
    r[3] = (r[3] << 1) | (r[2] >> 63);
    r[2] = (r[2] << 1) | (r[1] >> 63);
    r[1] = r[1] << 1;

    // printf("c-t%i:1: X, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11]);

    asm(
        "{\n\t"

        "mad.lo.cc.u64 %0, %12, %12, 0;\n\t"
        "madc.hi.cc.u64 %1, %12, %12, %1;\n\t"

        "madc.lo.cc.u64 %2, %13, %13, %2;\n\t"
        "madc.hi.cc.u64 %3, %13, %13, %3;\n\t"

        "madc.lo.cc.u64 %4, %14, %14, %4;\n\t"
        "madc.hi.cc.u64 %5, %14, %14, %5;\n\t"

        "madc.lo.cc.u64 %6, %15, %15, %6;\n\t"
        "madc.hi.cc.u64 %7, %15, %15, %7;\n\t"

        "madc.lo.cc.u64 %8, %16, %16, %8;\n\t"
        "madc.hi.cc.u64 %9, %16, %16, %9;\n\t"

        "madc.lo.cc.u64 %10, %17, %17, %10;\n\t"
        "madc.hi.u64 %11, %17, %17, %11;\n\t"

        "}"
        : "+l"(r[0]),
        "+l"(r[1]),
        "+l"(r[2]),
        "+l"(r[3]),
        "+l"(r[4]),
        "+l"(r[5]),
        "+l"(r[6]),
        "+l"(r[7]),
        "+l"(r[8]),
        "+l"(r[9]),
        "+l"(r[10]),
        "+l"(r[11])
        : "l"(a[0]),
        "l"(a[1]),
        "l"(a[2]),
        "l"(a[3]),
        "l"(a[4]),
        "l"(a[5])
    );
    // printf("c-t%i:2: %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11]);

    mont_384(ret, r, p, p_inv);
}


__device__ static inline void add_mod_384_unchecked(blst_fp ret, const blst_fp a, const blst_fp b) {
    asm(
        "add.cc.u64 %0, %6, %12;\n\t"
        "addc.cc.u64 %1, %7, %13;\n\t"
        "addc.cc.u64 %2, %8, %14;\n\t"
        "addc.cc.u64 %3, %9, %15;\n\t"
        "addc.cc.u64 %4, %10, %16;\n\t"
        "addc.u64 %5, %11, %17;"
        : "=l"(ret[0]),
        "=l"(ret[1]),
        "=l"(ret[2]),
        "=l"(ret[3]),
        "=l"(ret[4]),
        "=l"(ret[5])
        : "l"(a[0]),
        "l"(a[1]),
        "l"(a[2]),
        "l"(a[3]),
        "l"(a[4]),
        "l"(a[5]),
        "l"(b[0]),
        "l"(b[1]),
        "l"(b[2]),
        "l"(b[3]),
        "l"(b[4]),
        "l"(b[5])
    );
    // return cf != 0?
}

__device__ void add_mod_384(blst_fp ret, const blst_fp a, const blst_fp b, const blst_fp p) {
    add_mod_384_unchecked(ret, a, b);

    reduce(ret, p);
    // return cf != 0?
}

__device__ void sub_mod_384(blst_fp ret, const blst_fp a, const blst_fp b, const blst_fp p) {
    blst_fp added;
    memcpy(added, a, sizeof(blst_fp));
    // printf("pre-sub [%llu, %llu, %llu, %llu, %llu, %llu]\n", added[0], added[1], added[2], added[3], added[4], added[5]);
    if (is_gt_384(b, a)) {
        // printf("sub-preduce [%llu, %llu, %llu, %llu, %llu, %llu] > [%llu, %llu, %llu, %llu, %llu, %llu]\n", b[0], b[1], b[2], b[3], b[4], b[5], added[0], added[1], added[2], added[3], added[4], added[5]);
        add_mod_384_unchecked(added, added, p);
        // printf("sub-postduce [%llu, %llu, %llu, %llu, %llu, %llu]\n", added[0], added[1], added[2], added[3], added[4], added[5]);
    }
    else {
        // printf("sub-nonduce [%llu, %llu, %llu, %llu, %llu, %llu] <= [%llu, %llu, %llu, %llu, %llu, %llu]\n", b[0], b[1], b[2], b[3], b[4], b[5], added[0], added[1], added[2], added[3], added[4], added[5]);
    }
    sub_mod_384_unchecked(ret, added, b);
    // printf("post-sub [%llu, %llu, %llu, %llu, %llu, %llu]\n", ret[0], ret[1], ret[2], ret[3], ret[4], ret[5]);
    // return cf != 0?
}

__device__ void sub_mod_384_unsafe(blst_fp ret, const blst_fp a, const blst_fp b) {
    sub_mod_384_unchecked(ret, a, b);
    // return cf != 0?
}

__device__ void add_mod_384_unsafe(blst_fp ret, const blst_fp a, const blst_fp b) {
    add_mod_384_unchecked(ret, a, b);
    // return cf != 0?
}

__device__ static inline void _rshift_384(blst_fp ret, const blst_fp value) {
    ret[0] = (value[1] << 63) | (value[0] >> 1);
    ret[1] = (value[2] << 63) | (value[1] >> 1);
    ret[2] = (value[3] << 63) | (value[2] >> 1);
    ret[3] = (value[4] << 63) | (value[3] >> 1);
    ret[4] = (value[5] << 63) | (value[4] >> 1);
    ret[5] = value[5] >> 1;
}

__device__ void div_by_2_mod_384(blst_fp ret, const blst_fp a) {
    _rshift_384(ret, a);
}

__device__ void cneg_mod_384(blst_fp ret, const blst_fp a, bool flag, const blst_fp p) {
    // just let the compiler cmov
    if (flag) {
        sub_mod_384(ret, p, a, p);
    }
    else {
        memcpy(ret, a, 6 * sizeof(limb_t));
    }
}



__device__ static inline void blst_fp_add(blst_fp ret, const blst_fp a, const blst_fp b)
{
    add_mod_384(ret, a, b, BLS12_377_P);
}

__device__ static inline void blst_fp_add_unsafe(blst_fp ret, const blst_fp a, const blst_fp b)
{
    add_mod_384_unsafe(ret, a, b);
}

__device__ static inline void blst_fp_sub(blst_fp ret, const blst_fp a, const blst_fp b)
{
    sub_mod_384(ret, a, b, BLS12_377_P);
}

__device__ static inline void blst_fp_sub_unsafe(blst_fp ret, const blst_fp a, const blst_fp b)
{
    sub_mod_384_unsafe(ret, a, b);
}

__device__ static inline void blst_fp_cneg(blst_fp ret, const blst_fp a, bool flag)
{
    cneg_mod_384(ret, a, flag, BLS12_377_P);
}

__device__ static inline void blst_fp_mul(blst_fp ret, const blst_fp a, const blst_fp b)
{
    mul_mont_384(ret, a, b, BLS12_377_P, BLS12_377_p0);
}

__device__ static inline void blst_fp_sqr(blst_fp ret, const blst_fp a)
{
    sqr_mont_384(ret, a, BLS12_377_P, BLS12_377_p0);
}




__device__ void blst_fp_inverse(blst_fp out, const blst_fp in) {
    if (is_blst_fp_zero(in)) {
        // this is really bad
        *((int*)NULL);
    }
    // Guajardo Kumar Paar Pelzl
    // Efficient Software-Implementation of Finite Fields with Applications to
    // Cryptography
    // Algorithm 16 (BEA for Inversion in Fp)

    blst_fp u;
    memcpy(u, in, sizeof(blst_fp));
    blst_fp v;
    memcpy(v, BLS12_377_P, sizeof(blst_fp));
    blst_fp b;
    memcpy(b, BLS12_377_R2, sizeof(blst_fp));
    blst_fp c;
    memset(c, 0, sizeof(blst_fp));


    while (!is_blst_fp_eq(u, BIGINT_ONE) && !is_blst_fp_eq(v, BIGINT_ONE)) {
       // printf("c-t%i-inverse_round: u=%llu v=%llu b=%llu c=%llu\n", threadIdx.x, u[0], v[0], b[0], c[0]);
       while ((u[0] & 1) == 0) {
           // printf("c-t%i-inverse_round_u_start: u=%llu b=%llu\n", threadIdx.x, u[0], b[0]);
           div_by_2_mod_384(u, u);

           if ((b[0] & 1) != 0) {
               blst_fp_add_unsafe(b, b, BLS12_377_P);
           }
           div_by_2_mod_384(b, b);
           // printf("c-t%i-inverse_round_u_stop: u=%llu b=%llu\n", threadIdx.x, u[0], b[0]);
       }

       while ((v[0] & 1) == 0) {
           // printf("c-t%i-inverse_round_v_start: u=%llu b=%llu\n", threadIdx.x, v[0], c[0]);
           div_by_2_mod_384(v, v);

           if ((c[0] & 1) != 0) {
               blst_fp_add_unsafe(c, c, BLS12_377_P);
           }
           div_by_2_mod_384(c, c);
           // printf("c-t%i-inverse_round_v_stop: u=%llu b=%llu\n", threadIdx.x, v[0], c[0]);
       }

       if (is_gt_384(u, v)) {
           blst_fp_sub_unsafe(u, u, v);
           blst_fp_sub(b, b, c);
       }
       else {
           blst_fp_sub_unsafe(v, v, u);
           blst_fp_sub(c, c, b);
       }
    }
    if (is_blst_fp_eq(u, BIGINT_ONE)) {
        memcpy(out, b, sizeof(blst_fp));
    }
    else {
        memcpy(out, c, sizeof(blst_fp));
    }
}



__device__ void blst_p1_projective_into_affine(blst_p1_affine* out, const blst_p1* in) {
    if (is_blst_p1_zero(in)) {
        memset(out->X, 0, sizeof(blst_fp));
        memcpy(out->Y, BLS12_377_ONE, sizeof(blst_fp));
        //todo: set inf
    } else if (is_blst_fp_eq(in->Z, BLS12_377_ONE)) {
        memcpy(out->X, in->X, sizeof(blst_fp));
        memcpy(out->Y, in->Y, sizeof(blst_fp));
    } else {
        blst_fp z_inv;
        // printf("c-t%i:cinverse-in: %llu\n", threadIdx.x, in->Z[0]);
        blst_fp_inverse(z_inv, in->Z);
        // printf("c-t%i:cinverse-out: %llu\n", threadIdx.x, z_inv[0]);
        blst_fp z_inv_squared;
        blst_fp_sqr(z_inv_squared, z_inv);
        blst_fp_mul(out->X, in->X, z_inv_squared);
        blst_fp_mul(z_inv_squared, z_inv_squared, z_inv);
        blst_fp_mul(out->Y, in->Y, z_inv_squared);
    }
}

__device__ void blst_p1_double(blst_p1* out, const blst_p1* in) {
    if (is_blst_p1_zero(in)) {
        memcpy(out, in, sizeof(blst_p1));
    }

    // Z3 = 2*Y1*Z1
    blst_fp_mul(out->Z, in->Y, in->Z);
    blst_fp_add(out->Z, out->Z, out->Z);

    // A = X1^2
    blst_fp a;
    blst_fp_sqr(a, in->X);
    
    // B = Y1^2
    blst_fp b;
    blst_fp_sqr(b, in->Y);

    // C = B^2
    blst_fp c;
    blst_fp_sqr(c, b);

    // D = 2*((X1+B)^2-A-C)
    blst_fp d;
    blst_fp_add(d, in->X, b);
    blst_fp_sqr(d, d);
    blst_fp_sub(d, d, a);
    blst_fp_sub(d, d, c);
    blst_fp_add(d, d, d);

    // E = 3*A
    blst_fp e;
    blst_fp_add(e, a, a);
    blst_fp_add(e, e, a);

    // F = E^2
    blst_fp f;
    blst_fp_sqr(f, e);

    // X3 = F-2*D
    blst_fp_add(out->X, d, d);
    blst_fp_sub(out->X, f, out->X);

    // Y3 = E*(D-X3)-8*C
    blst_fp_sub(out->Y, d, out->X);
    blst_fp_mul(out->Y, out->Y, e);

    blst_fp c3;
    blst_fp_add(c3, c, c); // 2c
    blst_fp_add(c3, c3, c3); // 4c
    blst_fp_add(c3, c3, c3); // 8c
    blst_fp_sub(out->Y, out->Y, c3);
}

__device__ void blst_p1_double_affine(blst_p1* out, const blst_p1_affine* p) {
    /*
        dbl-2009-l from
        http://www.hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#doubling-dbl-2009-l
    */

    // A = X1^2
    blst_fp A;
    blst_fp_sqr(A, p->X);

    // B = Y1^2
    blst_fp B;
    blst_fp_sqr(B, p->Y);

    // C = B^2
    blst_fp C;
    blst_fp_sqr(C, B);

    // D = 2 * ((X1 + B)^2 - A - C)
    blst_fp X1B;
    blst_fp_add(X1B, p->X, B);
    blst_fp_sqr(X1B, X1B);
    blst_fp_sub(X1B, X1B, A);
    blst_fp_sub(X1B, X1B, C);
    blst_fp D;
    blst_fp_add(D, X1B, X1B);

    // E = 3 * A
    blst_fp E;
    blst_fp_add(E, A, A);
    blst_fp_add(E, E, A);

    // F = E^2
    blst_fp F;
    blst_fp_sqr(F, E);

    // X3 = F - 2*D
    memcpy(out->X, F, sizeof(blst_fp));
    blst_fp_sub(out->X, out->X, D);
    blst_fp_sub(out->X, out->X, D);

    // Y3 = E*(D - X3) - 8*C
    blst_fp C8;
    blst_fp_add(C8, C, C);
    blst_fp_add(C8, C8, C8);
    blst_fp_add(C8, C8, C8);
    blst_fp_sub(D, D, out->X);
    blst_fp_mul(E, E, D);
    blst_fp_sub(out->Y, E, C8);

    // Z3 = 2*Y1
    blst_fp_add(out->Z, p->Y, p->Y);
}

__device__ void blst_p1_add_affine_to_projective(blst_p1 *out, const blst_p1 *p1, const blst_p1_affine *p2) {
    if (is_blst_p1_affine_zero(p2)) {
        memcpy(out, p1, sizeof(blst_p1));
        return;
    }

    if (is_blst_p1_zero(p1)) {
        memcpy(out->X, p2->X, sizeof(blst_fp));
        memcpy(out->Y, p2->Y, sizeof(blst_fp));
        memcpy(out->Z, BLS12_377_ONE, sizeof(blst_fp));
        return;
    }
  
    // http://www.hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#addition-madd-2007-bl
    // Works for all curves.

    // printf("c-t%llu:add:0 %llu,%llu,%llu -> %llu,%llu\n", threadIdx.x, p1->X[0], p1->Y[0], p1->Z[0], p2->X[0], p2->Y[0]);

    // Z1Z1 = Z1^2
    blst_fp z1z1;
    blst_fp_sqr(z1z1, p1->Z);

    // printf("c-t%llu:add:1 %llu\n", threadIdx.x, z1z1[0]);

    // U2 = X2*Z1Z1
    blst_fp u2;
    blst_fp_mul(u2, p2->X, z1z1);

    // printf("c-t%llu:add:2 %llu\n", threadIdx.x, u2[0]);

    // S2 = Y2*Z1*Z1Z1
    blst_fp s2;
    blst_fp_mul(s2, p2->Y, p1->Z);
    blst_fp_mul(s2, s2, z1z1);

    if (is_blst_fp_eq(p1->X, u2) && is_blst_fp_eq(p1->Y, s2)) {
        blst_p1_double(out, p1);
        return;
    }

    // printf("c-t%llu:add:3 %llu\n", threadIdx.x, s2[0]);

    // printf("c-t%llu:add:pre-4 %llu - %llu\n", threadIdx.x, u2[0], p1->X[0]);
    // H = U2-X1
    blst_fp h;
    blst_fp_sub(h, u2, p1->X);

    // printf("c-t%llu:add:4 %llu\n", threadIdx.x, h[0]);

    // HH = H^2
    blst_fp hh;
    blst_fp_sqr(hh, h);
    // printf("c-t%llu:add:5 %llu\n", threadIdx.x, hh[0]);

    // I = 4*HH
    blst_fp i;
    memcpy(i, hh, sizeof(blst_fp));
    blst_fp_add(i, i, i);
    blst_fp_add(i, i, i);
    // printf("c-t%llu:add:6 %llu\n", threadIdx.x, i[0]);

    // J = H*I
    blst_fp j;
    blst_fp_mul(j, h, i);
    // printf("c-t%llu:add:7 %llu\n", threadIdx.x, j[0]);

    // r = 2*(S2-Y1)
    blst_fp r;
    blst_fp_sub(r, s2, p1->Y);
    blst_fp_add(r, r, r);
    // printf("c-t%llu:add:8 %llu\n", threadIdx.x, r[0]);

    // V = X1*I
    blst_fp v;
    blst_fp_mul(v, p1->X, i);
    // printf("c-t%llu:add:9 %llu\n", threadIdx.x, v[0]);

    // X3 = r^2 - J - 2*V
    blst_fp_sqr(out->X, r);
    // printf("c-t%llu:add:1X %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, out->X[0], out->X[1], out->X[2], out->X[3], out->X[4], out->X[5]);
    blst_fp_sub(out->X, out->X, j);
    // printf("c-t%llu:add:2X %llu, %llu, %llu, %llu, %llu, %llu -- %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, out->X[0], out->X[1], out->X[2], out->X[3], out->X[4], out->X[5], j[0], j[1], j[2], j[3], j[4], j[5]);
    blst_fp_sub(out->X, out->X, v);
    // printf("c-t%llu:add:3X %llu\n", threadIdx.x, out->X[0]);
    blst_fp_sub(out->X, out->X, v);
    // printf("c-t%llu:add:4X %llu\n", threadIdx.x, out->X[0]);

    // Y3 = r*(V-X3)-2*Y1*J
    blst_fp_mul(j, p1->Y, j);
    blst_fp_add(j, j, j);
    blst_fp_sub(out->Y, v, out->X);
    blst_fp_mul(out->Y, out->Y, r);
    blst_fp_sub(out->Y, out->Y, j);
    // printf("c-t%llu:add:Y %llu\n", threadIdx.x, out->Y[0]);

    // Z3 = (Z1+H)^2-Z1Z1-HH
    blst_fp_add(out->Z, p1->Z, h);
    blst_fp_sqr(out->Z, out->Z);
    blst_fp_sub(out->Z, out->Z, z1z1);
    blst_fp_sub(out->Z, out->Z, hh);
    // printf("c-t%llu:add:Z %llu\n", threadIdx.x, out->Z[0]);
}


__device__ void blst_p1_add_affines_into_projective(blst_p1* out, const blst_p1_affine* p1, const blst_p1_affine* p2) {
    /*
        mmadd-2007-bl from
        http://www.hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#addition-mmadd-2007-bl
    */

    // The points can't be 0.
    if (is_blst_p1_affine_zero(p2)) {
        memcpy(out->X, p1->X, sizeof(blst_fp));
        memcpy(out->Y, p1->Y, sizeof(blst_fp));

        if (is_blst_p1_affine_zero(p1)) {
            memcpy(out->Z, BLS12_377_ZERO, sizeof(blst_fp));
        } else {
            memcpy(out->Z, BLS12_377_ONE, sizeof(blst_fp));
        }

        return;
    } else if (is_blst_p1_affine_zero(p1)) {
        memcpy(out->X, p2->X, sizeof(blst_fp));
        memcpy(out->Y, p2->Y, sizeof(blst_fp));

        if (is_blst_p1_affine_zero(p2)) {
            memcpy(out->Z, BLS12_377_ZERO, sizeof(blst_fp));
        } else {
            memcpy(out->Z, BLS12_377_ONE, sizeof(blst_fp));
        }

        return;
    }

    // mmadd-2007-bl does not support equal values for p1 and p2.
    // If `p1` and `p2` are equal, use the doubling algorithm.
    if(is_blst_fp_eq(p1->X, p2->X) && is_blst_fp_eq(p1->Y, p2->Y)) {
        blst_p1_double_affine(out, p1);
        return;
    }

    // H = X2-X1
    blst_fp h;
    blst_fp_sub(h, p2->X, p1->X);

    // HH = H^2
    // I = 4*HH
    blst_fp i;
    memcpy(i, h, sizeof(blst_fp));
    blst_fp_add(i, i, i);
    blst_fp_sqr(i, i);

    // J = H*I
    blst_fp j;
    blst_fp_mul(j, h, i);

    // r = 2*(Y2-Y1)
    blst_fp r;
    blst_fp_sub(r, p2->Y, p1->Y);
    blst_fp_add(r, r, r);

    // V = X1*I
    blst_fp v;
    blst_fp_mul(v, p1->X, i);

    // X3 = r^2-J-2*V
    blst_fp_sqr(out->X, r);
    blst_fp_sub(out->X, out->X, j);
    blst_fp_sub(out->X, out->X, v);
    blst_fp_sub(out->X, out->X, v);

    // Y3 = r*(V-X3)-2*Y1*J
    blst_fp_sub(out->Y, v, out->X);
    blst_fp_mul(out->Y, out->Y, r);

    blst_fp y1j;
    blst_fp_mul(y1j, p1->Y, j);
    blst_fp_sub(out->Y, out->Y, y1j);
    blst_fp_sub(out->Y, out->Y, y1j);

    // Z3 = 2*H
    blst_fp_add(out->Z, h, h);
}

__device__ void blst_p1_add_projective_to_projective(blst_p1 *out, const blst_p1 *p1, const blst_p1 *p2) {
    if (is_blst_p1_zero(p2)) {
        memcpy(out, p1, sizeof(blst_p1));
        return;
    }

    if (is_blst_p1_zero(p1)) {
        memcpy(out, p2, sizeof(blst_p1));
        return;
    }

    int p1_is_affine = is_blst_fp_eq(p1->Z, BLS12_377_ONE);
    int p2_is_affine = is_blst_fp_eq(p2->Z, BLS12_377_ONE);
    // //todo: confirm generated ptx here is *okay* for warp divergence
    if (p1_is_affine && p2_is_affine) {
        blst_p1_affine p1_affine;
        memcpy(&p1_affine.X, &p1->X, sizeof(blst_fp));
        memcpy(&p1_affine.Y, &p1->Y, sizeof(blst_fp));
        blst_p1_affine p2_affine;
        memcpy(&p2_affine.X, &p2->X, sizeof(blst_fp));
        memcpy(&p2_affine.Y, &p2->Y, sizeof(blst_fp));
        blst_p1_add_affines_into_projective(out, &p1_affine, &p2_affine);
        return;
    } if (p1_is_affine) {
        blst_p1_affine p1_affine;
        memcpy(&p1_affine.X, &p1->X, sizeof(blst_fp));
        memcpy(&p1_affine.Y, &p1->Y, sizeof(blst_fp));
        blst_p1_add_affine_to_projective(out, p2, &p1_affine);
        return;
    } else if (p2_is_affine) {
        blst_p1_affine p2_affine;
        memcpy(&p2_affine.X, &p2->X, sizeof(blst_fp));
        memcpy(&p2_affine.Y, &p2->Y, sizeof(blst_fp));
        blst_p1_add_affine_to_projective(out, p1, &p2_affine);
        return;
    }
  
    // http://www.hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#addition-madd-2007-bl
    // Works for all curves.

    // printf("c-t%llu:add:0 %llu,%llu,%llu -> %llu,%llu\n", threadIdx.x, p1->X[0], p1->Y[0], p1->Z[0], p2->X[0], p2->Y[0]);

    // Z1Z1 = Z1^2
    blst_fp z1z1;
    blst_fp_sqr(z1z1, p1->Z);

    // Z2Z2 = Z2^2
    blst_fp z2z2;
    blst_fp_sqr(z2z2, p2->Z);

    // U1 = X1*Z2Z2
    blst_fp u1;
    blst_fp_mul(u1, p1->X, z2z2);

    // U2 = X2*Z1Z1
    blst_fp u2;
    blst_fp_mul(u2, p2->X, z1z1);

    // S1 = Y1*Z2*Z2Z2
    blst_fp s1;
    blst_fp_mul(s1, p1->Y, p2->Z);
    blst_fp_mul(s1, s1, z2z2);

    // S2 = Y2*Z1*Z1Z1
    blst_fp s2;
    blst_fp_mul(s2, p2->Y, p1->Z);
    blst_fp_mul(s2, s2, z1z1);

    // H = U2-U1
    blst_fp h;
    blst_fp_sub(h, u2, u1);

    // printf("c-t%llu:add:4 %llu\n", threadIdx.x, h[0]);

    // HH = H^2
    blst_fp hh;
    blst_fp_sqr(hh, h);
    // printf("c-t%llu:add:5 %llu\n", threadIdx.x, hh[0]);

    // I = 4*HH
    blst_fp i;
    memcpy(i, hh, sizeof(blst_fp));
    blst_fp_add(i, i, i);
    blst_fp_add(i, i, i);
    // printf("c-t%llu:add:6 %llu\n", threadIdx.x, i[0]);

    // J = H*I
    blst_fp j;
    blst_fp_mul(j, h, i);
    // printf("c-t%llu:add:7 %llu\n", threadIdx.x, j[0]);

    // r = 2*(S2-S1)
    blst_fp r;
    blst_fp_sub(r, s2, s1);
    blst_fp_add(r, r, r);
    // printf("c-t%llu:add:8 %llu\n", threadIdx.x, r[0]);

    // V = U1*I
    blst_fp v;
    blst_fp_mul(v, u1, i);
    // printf("c-t%llu:add:9 %llu\n", threadIdx.x, v[0]);

    // X3 = r^2 - J - 2*V
    blst_fp_sqr(out->X, r);
    // printf("c-t%llu:add:1X %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, out->X[0], out->X[1], out->X[2], out->X[3], out->X[4], out->X[5]);
    blst_fp_sub(out->X, out->X, j);
    // printf("c-t%llu:add:2X %llu, %llu, %llu, %llu, %llu, %llu -- %llu, %llu, %llu, %llu, %llu, %llu\n", threadIdx.x, out->X[0], out->X[1], out->X[2], out->X[3], out->X[4], out->X[5], j[0], j[1], j[2], j[3], j[4], j[5]);
    blst_fp_sub(out->X, out->X, v);
    // printf("c-t%llu:add:3X %llu\n", threadIdx.x, out->X[0]);
    blst_fp_sub(out->X, out->X, v);
    // printf("c-t%llu:add:4X %llu\n", threadIdx.x, out->X[0]);

    // Y3 = r*(V-X3)-2*S1*J
    blst_fp_mul(j, s1, j);
    blst_fp_add(j, j, j);
    blst_fp_sub(out->Y, v, out->X);
    blst_fp_mul(out->Y, out->Y, r);
    blst_fp_sub(out->Y, out->Y, j);
    // printf("c-t%llu:add:Y %llu\n", threadIdx.x, out->Y[0]);

    // Z3 = ((Z1+Z2)^2-Z1Z1-Z2Z2)*H
    blst_fp_add(out->Z, p1->Z, p2->Z);
    blst_fp_sqr(out->Z, out->Z);
    blst_fp_sub(out->Z, out->Z, z1z1);
    blst_fp_sub(out->Z, out->Z, z2z2);
    blst_fp_mul(out->Z, out->Z, h);
    // printf("c-t%llu:add:Z %llu\n", threadIdx.x, out->Z[0]);
}


__device__ void blst_p1_add_affine_to_affine(blst_p1_affine* out, const blst_p1_affine* p1, const blst_p1_affine* p2) {
    /*
        http://www.hyperelliptic.org/EFD/g1p/auto-shortw.html
        x3 = (y2-y1)2/(x2-x1)2-x1-x2
        y3 = (2*x1+x2)*(y2-y1)/(x2-x1)-(y2-y1)3/(x2-x1)3-y1
    */
    blst_fp y_diff;
    blst_fp_sub(y_diff, p2->Y, p1->Y);

    blst_fp y_diff2;
    blst_fp_sqr(y_diff2, y_diff);

    blst_fp x_diff_inv;
    blst_fp_sub(x_diff_inv, p2->X, p1->X);
    blst_fp_inverse(x_diff_inv, x_diff_inv);
    
    blst_fp x_diff_inv2;
    blst_fp_sqr(x_diff_inv2, x_diff_inv);

    blst_fp sum_x;
    blst_fp_add(sum_x, p1->X, p2->X);

    blst_fp_mul(out->X, y_diff2, x_diff_inv2);
    blst_fp_sub(out->X, out->X, sum_x);

    blst_fp_mul(out->Y, y_diff, x_diff_inv);
    blst_fp_mul(out->Y, out->Y, sum_x);
    blst_fp_add(out->Y, out->Y, out->Y);

    blst_fp y_diff3;
    blst_fp_mul(y_diff3, y_diff2, y_diff);

    blst_fp x_diff_inv3;
    blst_fp_mul(x_diff_inv3, x_diff_inv2, x_diff_inv);

    blst_fp j;
    blst_fp_mul(j, y_diff3, x_diff_inv3);
    blst_fp_sub(out->Y, out->Y, j);

    blst_fp_sub(out->Y, out->Y, p1->Y);
}

extern "C" __global__ void msm6_pixel(blst_p1 * bucket_lists, const blst_p1_affine * bases_in, const blst_scalar * scalars, const uint32_t * window_lengths, const uint32_t window_count) {
   limb_t index = threadIdx.x / 64;
   size_t shift = threadIdx.x - (index * 64);
   limb_t mask = (limb_t)1 << (limb_t)shift;

   blst_p1 bucket;
   memcpy(&bucket, &BLS12_377_ZERO_PROJECTIVE, sizeof(blst_p1));

   uint32_t window_start = WINDOW_SIZE * blockIdx.x;
   uint32_t window_end = window_start + window_lengths[blockIdx.x];

   uint32_t activated_bases[WINDOW_SIZE];
   uint32_t activated_base_index = 0;

   // we delay the actual additions to a second loop because it reduces warp divergence (20% practical gain)
   for (uint32_t i = window_start; i < window_end; ++i) {
       limb_t bit = (scalars[i][index] & mask);
       if (bit == 0) {
           continue;
       }
       activated_bases[activated_base_index++] = i;
   }
   uint32_t i = 0;
   for (; i < (activated_base_index / 2 * 2); i += 2) {
       blst_p1 intermediate;
       blst_p1_add_affines_into_projective(&intermediate, &bases_in[activated_bases[i]], &bases_in[activated_bases[i + 1]]);
       blst_p1_add_projective_to_projective(&bucket, &bucket, &intermediate);
   }
   for (; i < activated_base_index; ++i) {
       blst_p1_add_affine_to_projective(&bucket, &bucket, &(bases_in[activated_bases[i]]));
   }

   memcpy(&bucket_lists[threadIdx.x * window_count + blockIdx.x], &bucket, sizeof(blst_p1));
}

extern "C" __global__ void msm6_collapse_rows(blst_p1 * target, const blst_p1 * bucket_lists, const uint32_t window_count) {
    blst_p1 temp_target;
    uint32_t base = threadIdx.x * window_count;
    uint32_t term = base + window_count;
    memcpy(&temp_target, &bucket_lists[base], sizeof(blst_p1));

    for (uint32_t i = base + 1; i < term; ++i) {
       blst_p1_add_projective_to_projective(&temp_target, &temp_target, &bucket_lists[i]);
    }

    memcpy(&target[threadIdx.x], &temp_target, sizeof(blst_p1));
}

#endif  // #ifndef _ALEO_MSM_CUDA_H_
