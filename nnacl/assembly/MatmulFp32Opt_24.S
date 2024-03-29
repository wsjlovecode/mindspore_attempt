#ifdef ENABLE_ARM64
#include "nnacl/assembly_global.h"

.text
.align 5

// void MatmulFloatNeon64_24(const float *a, const float *b, float *c, const float *bias, int act_type, int depth
//                        int row, int col, size_t stride, size_t writeMode)
// x0: a
// x1: b
// x2: c
// x3: bias
// x4: act_type
// x5: depth
// x6: row
// x7: col
// x8: stride
// x9: writeMode

asm_function MatmulFloatNeon64Opt_24
    sub sp, sp, #160
    st1 {v8.4s, v9.4s, v10.4s, v11.4s}, [sp], #64
    st1 {v12.4s, v13.4s, v14.4s, v15.4s}, [sp], #64
    stp x19, x20, [sp], #16
    stp x21, x22, [sp], #16

    ldr x8, [sp]
    ldr x9, [sp, #8]

    mov x21, #96 // sizeof(float) * 24
    mul x17, x5, x21 // block stride of lhs/rhs: sizeof(float) * 24 * depth
    // cbnz x9, NoC8Steps
    // mov x11, x2
    // mov x21, #16
    // mul x16, x6, x21 // row * 4 * sizeof(float)
NoWinoSteps:
    mov x21, #4
    mul x8, x8, x21

LoopRowStart:
    cmp x6, #4
    ble LoopRow4
    cmp x6, #8
    ble LoopRow8
    cmp x6, #16
    ble LoopRow16
        
LoopRow:                          // new added
    mov x14, x1 // reload rhs ptr
    mov x13, x7 // reload rhs col
    mov x12, x3 // reload bias

    LoopCol:
        cbz x9, NoReloadDst
        mov x11, x2
    NoReloadDst:
        mov x10, x0 // reload lhs ptr
        mov x19, x5 // reload depth

    LoopDepthStart:               // new added
        ld1 {v0.4s, v1.4s, v2.4s}, [x10], #48
        ld1 {v3.4s, v4.4s, v5.4s}, [x10], #48
        ld1 {v6.4s}, [x14], #16
        fmul v8.4s, v6.4s, v0.s[0]
        fmul v10.4s, v6.4s, v0.s[1]
        fmul v12.4s, v6.4s, v0.s[2]
        fmul v14.4s, v6.4s, v0.s[3]
        fmul v9.4s, v6.4s, v1.s[0]
        fmul v11.4s, v6.4s, v1.s[1]
        fmul v13.4s, v6.4s, v1.s[2]
        fmul v15.4s, v6.4s, v1.s[3]
        fmul v16.4s, v6.4s, v2.s[0]
        fmul v18.4s, v6.4s, v2.s[1]
        fmul v20.4s, v6.4s, v2.s[2]
        fmul v22.4s, v6.4s, v2.s[3]
        fmul v17.4s, v6.4s, v3.s[0]
        fmul v19.4s, v6.4s, v3.s[1]
        fmul v21.4s, v6.4s, v3.s[2]
        fmul v23.4s, v6.4s, v3.s[3]
        fmul v24.4s, v6.4s, v4.s[0]
        fmul v26.4s, v6.4s, v4.s[1]
        fmul v28.4s, v6.4s, v4.s[2]
        fmul v30.4s, v6.4s, v4.s[3]
        fmul v25.4s, v6.4s, v5.s[0]
        fmul v27.4s, v6.4s, v5.s[1]
        fmul v29.4s, v6.4s, v5.s[2]
        fmul v31.4s, v6.4s, v5.s[3]

        subs x19, x19, #1
        beq Bias

        LoopDepth:
            ld1 {v0.4s, v1.4s, v2.4s}, [x10], #48
            ld1 {v3.4s, v4.4s, v5.4s}, [x10], #48
            ld1 {v6.4s}, [x14], #16
            fmla v8.4s, v6.4s, v0.s[0]
            fmla v10.4s, v6.4s, v0.s[1]
            fmla v12.4s, v6.4s, v0.s[2]
            fmla v14.4s, v6.4s, v0.s[3]
            fmla v9.4s, v6.4s, v1.s[0]
            fmla v11.4s, v6.4s, v1.s[1]
            fmla v13.4s, v6.4s, v1.s[2]
            fmla v15.4s, v6.4s, v1.s[3]
            fmla v16.4s, v6.4s, v2.s[0]
            fmla v18.4s, v6.4s, v2.s[1]
            fmla v20.4s, v6.4s, v2.s[2]
            fmla v22.4s, v6.4s, v2.s[3]
            fmla v17.4s, v6.4s, v3.s[0]
            fmla v19.4s, v6.4s, v3.s[1]
            fmla v21.4s, v6.4s, v3.s[2]
            fmla v23.4s, v6.4s, v3.s[3]
            fmla v24.4s, v6.4s, v4.s[0]
            fmla v26.4s, v6.4s, v4.s[1]
            fmla v28.4s, v6.4s, v4.s[2]
            fmla v30.4s, v6.4s, v4.s[3]
            fmla v25.4s, v6.4s, v5.s[0]
            fmla v27.4s, v6.4s, v5.s[1]
            fmla v29.4s, v6.4s, v5.s[2]
            fmla v31.4s, v6.4s, v5.s[3]

            subs x19, x19, #1
            bgt LoopDepth

        Bias:
            cbz x3, Activation
            ld1 {v0.4s}, [x12], #16
            fadd v8.4s, v8.4s, v0.4s
            fadd v9.4s, v9.4s, v0.4s
            fadd v10.4s, v10.4s, v0.4s
            fadd v11.4s, v11.4s, v0.4s
            fadd v12.4s, v12.4s, v0.4s
            fadd v13.4s, v13.4s, v0.4s
            fadd v14.4s, v14.4s, v0.4s
            fadd v15.4s, v15.4s, v0.4s
            fadd v16.4s, v16.4s, v0.4s
            fadd v17.4s, v17.4s, v0.4s
            fadd v18.4s, v18.4s, v0.4s
            fadd v19.4s, v19.4s, v0.4s
            fadd v20.4s, v20.4s, v0.4s
            fadd v21.4s, v21.4s, v0.4s
            fadd v22.4s, v22.4s, v0.4s
            fadd v23.4s, v23.4s, v0.4s
            fadd v24.4s, v24.4s, v0.4s
            fadd v25.4s, v25.4s, v0.4s
            fadd v26.4s, v26.4s, v0.4s
            fadd v27.4s, v27.4s, v0.4s
            fadd v28.4s, v28.4s, v0.4s
            fadd v29.4s, v29.4s, v0.4s
            fadd v30.4s, v30.4s, v0.4s
            fadd v31.4s, v31.4s, v0.4s

        Activation:
            cmp x4, #3
            beq Relu6
            cmp x4, #1
            beq Relu
            b Write

        Relu6:
            mov w19, #6
            dup v2.4s, w19
            scvtf v2.4s, v2.4s
            fmin v8.4s, v8.4s, v2.4s
            fmin v9.4s, v9.4s, v2.4s
            fmin v10.4s, v10.4s, v2.4s
            fmin v11.4s, v11.4s, v2.4s
            fmin v12.4s, v12.4s, v2.4s
            fmin v13.4s, v13.4s, v2.4s
            fmin v14.4s, v14.4s, v2.4s
            fmin v15.4s, v15.4s, v2.4s
            fmin v16.4s, v16.4s, v2.4s
            fmin v17.4s, v17.4s, v2.4s
            fmin v18.4s, v18.4s, v2.4s
            fmin v19.4s, v19.4s, v2.4s
            fmin v20.4s, v20.4s, v2.4s
            fmin v21.4s, v21.4s, v2.4s
            fmin v22.4s, v22.4s, v2.4s
            fmin v23.4s, v23.4s, v2.4s
            fmin v24.4s, v24.4s, v2.4s
            fmin v25.4s, v25.4s, v2.4s
            fmin v26.4s, v26.4s, v2.4s
            fmin v27.4s, v27.4s, v2.4s
            fmin v28.4s, v28.4s, v2.4s
            fmin v29.4s, v29.4s, v2.4s
            fmin v30.4s, v30.4s, v2.4s
            fmin v31.4s, v31.4s, v2.4s
        
        Relu:
            dup v3.4s, wzr
            fmax v8.4s, v8.4s, v3.4s
            fmax v9.4s, v9.4s, v3.4s
            fmax v10.4s, v10.4s, v3.4s
            fmax v11.4s, v11.4s, v3.4s
            fmax v12.4s, v12.4s, v3.4s
            fmax v13.4s, v13.4s, v3.4s
            fmax v14.4s, v14.4s, v3.4s
            fmax v15.4s, v15.4s, v3.4s
            fmax v16.4s, v16.4s, v3.4s
            fmax v17.4s, v17.4s, v3.4s
            fmax v18.4s, v18.4s, v3.4s
            fmax v19.4s, v19.4s, v3.4s
            fmax v20.4s, v20.4s, v3.4s
            fmax v21.4s, v21.4s, v3.4s
            fmax v22.4s, v22.4s, v3.4s
            fmax v23.4s, v23.4s, v3.4s
            fmax v24.4s, v24.4s, v3.4s
            fmax v25.4s, v25.4s, v3.4s
            fmax v26.4s, v26.4s, v3.4s
            fmax v27.4s, v27.4s, v3.4s
            fmax v28.4s, v28.4s, v3.4s
            fmax v29.4s, v29.4s, v3.4s
            fmax v30.4s, v30.4s, v3.4s
            fmax v31.4s, v31.4s, v3.4s
            b Write

LoopRow16:
    mov x14, x1 // reload rhs ptr
    mov x13, x7 // reload rhs col
    mov x12, x3 // reload bias

    LoopCol16:
        cbz x9, NoReloadDst16
        mov x11, x2
    NoReloadDst16:
        mov x10, x0 // reload lhs ptr
        mov x19, x5 // reload depth

    LoopDepthStart16:
        ld1 {v0.4s, v1.4s, v2.4s}, [x10], #48
        ld1 {v3.4s, v4.4s, v5.4s}, [x10], #48
        ld1 {v6.4s}, [x14], #16
        fmul v8.4s, v6.4s, v0.s[0]
        fmul v10.4s, v6.4s, v0.s[1]
        fmul v12.4s, v6.4s, v0.s[2]
        fmul v14.4s, v6.4s, v0.s[3]
        fmul v9.4s, v6.4s, v1.s[0]
        fmul v11.4s, v6.4s, v1.s[1]
        fmul v13.4s, v6.4s, v1.s[2]
        fmul v15.4s, v6.4s, v1.s[3]
        fmul v16.4s, v6.4s, v2.s[0]
        fmul v18.4s, v6.4s, v2.s[1]
        fmul v20.4s, v6.4s, v2.s[2]
        fmul v22.4s, v6.4s, v2.s[3]
        fmul v17.4s, v6.4s, v3.s[0]
        fmul v19.4s, v6.4s, v3.s[1]
        fmul v21.4s, v6.4s, v3.s[2]
        fmul v23.4s, v6.4s, v3.s[3]

        subs x19, x19, #1
        beq Bias16

        LoopDepth16:
            ld1 {v0.4s, v1.4s, v2.4s}, [x10], #48
            ld1 {v3.4s, v4.4s, v5.4s}, [x10], #48
            ld1 {v6.4s}, [x14], #16
            fmla v8.4s, v6.4s, v0.s[0]
            fmla v10.4s, v6.4s, v0.s[1]
            fmla v12.4s, v6.4s, v0.s[2]
            fmla v14.4s, v6.4s, v0.s[3]
            fmla v9.4s, v6.4s, v1.s[0]
            fmla v11.4s, v6.4s, v1.s[1]
            fmla v13.4s, v6.4s, v1.s[2]
            fmla v15.4s, v6.4s, v1.s[3]
            fmla v16.4s, v6.4s, v2.s[0]
            fmla v18.4s, v6.4s, v2.s[1]
            fmla v20.4s, v6.4s, v2.s[2]
            fmla v22.4s, v6.4s, v2.s[3]
            fmla v17.4s, v6.4s, v3.s[0]
            fmla v19.4s, v6.4s, v3.s[1]
            fmla v21.4s, v6.4s, v3.s[2]
            fmla v23.4s, v6.4s, v3.s[3]

            subs x19, x19, #1
            bgt LoopDepth16

        Bias16:
            cbz x3, Activation16
            ld1 {v0.4s}, [x12], #16
            fadd v8.4s, v8.4s, v0.4s
            fadd v9.4s, v9.4s, v0.4s
            fadd v10.4s, v10.4s, v0.4s
            fadd v11.4s, v11.4s, v0.4s
            fadd v12.4s, v12.4s, v0.4s
            fadd v13.4s, v13.4s, v0.4s
            fadd v14.4s, v14.4s, v0.4s
            fadd v15.4s, v15.4s, v0.4s
            fadd v16.4s, v16.4s, v0.4s
            fadd v17.4s, v17.4s, v0.4s
            fadd v18.4s, v18.4s, v0.4s
            fadd v19.4s, v19.4s, v0.4s
            fadd v20.4s, v20.4s, v0.4s
            fadd v21.4s, v21.4s, v0.4s
            fadd v22.4s, v22.4s, v0.4s
            fadd v23.4s, v23.4s, v0.4s

         Activation16:
            cmp x4, #3
            beq Relu616
            cmp x4, #1
            beq Relu16
            b Write

         Relu616:
            mov w19, #6
            dup v2.4s, w19
            scvtf v2.4s, v2.4s
            fmin v8.4s, v8.4s, v2.4s
            fmin v9.4s, v9.4s, v2.4s
            fmin v10.4s, v10.4s, v2.4s
            fmin v11.4s, v11.4s, v2.4s
            fmin v12.4s, v12.4s, v2.4s
            fmin v13.4s, v13.4s, v2.4s
            fmin v14.4s, v14.4s, v2.4s
            fmin v15.4s, v15.4s, v2.4s
            fmin v16.4s, v16.4s, v2.4s
            fmin v17.4s, v17.4s, v2.4s
            fmin v18.4s, v18.4s, v2.4s
            fmin v19.4s, v19.4s, v2.4s
            fmin v20.4s, v20.4s, v2.4s
            fmin v21.4s, v21.4s, v2.4s
            fmin v22.4s, v22.4s, v2.4s
            fmin v23.4s, v23.4s, v2.4s

         Relu16:
            dup v3.4s, wzr
            fmax v8.4s, v8.4s, v3.4s
            fmax v9.4s, v9.4s, v3.4s
            fmax v10.4s, v10.4s, v3.4s
            fmax v11.4s, v11.4s, v3.4s
            fmax v12.4s, v12.4s, v3.4s
            fmax v13.4s, v13.4s, v3.4s
            fmax v14.4s, v14.4s, v3.4s
            fmax v15.4s, v15.4s, v3.4s
            fmax v16.4s, v16.4s, v3.4s
            fmax v17.4s, v17.4s, v3.4s
            fmax v18.4s, v18.4s, v3.4s
            fmax v19.4s, v19.4s, v3.4s
            fmax v20.4s, v20.4s, v3.4s
            fmax v21.4s, v21.4s, v3.4s
            fmax v22.4s, v22.4s, v3.4s
            fmax v23.4s, v23.4s, v3.4s
            b Write


LoopRow8:               
    mov x14, x1 // reload rhs ptr
    mov x13, x7 // reload rhs col
    mov x12, x3 // reload bias

    LoopCol8:
        cbz x9, NoReloadDst8
        mov x11, x2
    NoReloadDst8:
        mov x10, x0 // reload lhs ptr
        mov x19, x5 // reload depth


    LoopDepthStart8:
        ld1 {v0.4s, v1.4s, v2.4s}, [x10], #48
        ld1 {v3.4s, v4.4s, v5.4s}, [x10], #48
        ld1 {v6.4s}, [x14], #16
        fmul v8.4s, v6.4s, v0.s[0]
        fmul v10.4s, v6.4s, v0.s[1]
        fmul v12.4s, v6.4s, v0.s[2]
        fmul v14.4s, v6.4s, v0.s[3]
        fmul v9.4s, v6.4s, v1.s[0]
        fmul v11.4s, v6.4s, v1.s[1]
        fmul v13.4s, v6.4s, v1.s[2]
        fmul v15.4s, v6.4s, v1.s[3]

        subs x19, x19, #1
        beq Bias8

        LoopDepth8:
            ld1 {v0.4s, v1.4s, v2.4s}, [x10], #48
            ld1 {v3.4s, v4.4s, v5.4s}, [x10], #48
            ld1 {v6.4s}, [x14], #16
            fmla v8.4s, v6.4s, v0.s[0]
            fmla v10.4s, v6.4s, v0.s[1]
            fmla v12.4s, v6.4s, v0.s[2]
            fmla v14.4s, v6.4s, v0.s[3]
            fmla v9.4s, v6.4s, v1.s[0]
            fmla v11.4s, v6.4s, v1.s[1]
            fmla v13.4s, v6.4s, v1.s[2]
            fmla v15.4s, v6.4s, v1.s[3]

            subs x19, x19, #1
            bgt LoopDepth8

        Bias8:
            cbz x3, Activation8
            ld1 {v0.4s}, [x12], #16
            fadd v8.4s, v8.4s, v0.4s
            fadd v9.4s, v9.4s, v0.4s
            fadd v10.4s, v10.4s, v0.4s
            fadd v11.4s, v11.4s, v0.4s
            fadd v12.4s, v12.4s, v0.4s
            fadd v13.4s, v13.4s, v0.4s
            fadd v14.4s, v14.4s, v0.4s
            fadd v15.4s, v15.4s, v0.4s

        Activation8:
            cmp x4, #3
            beq Relu68
            cmp x4, #1
            beq Relu8
            b Write

        Relu68:
            mov w19, #6
            dup v2.4s, w19
            scvtf v2.4s, v2.4s
            fmin v8.4s, v8.4s, v2.4s
            fmin v9.4s, v9.4s, v2.4s
            fmin v10.4s, v10.4s, v2.4s
            fmin v11.4s, v11.4s, v2.4s
            fmin v12.4s, v12.4s, v2.4s
            fmin v13.4s, v13.4s, v2.4s
            fmin v14.4s, v14.4s, v2.4s
            fmin v15.4s, v15.4s, v2.4s
        
        Relu8:
            dup v3.4s, wzr
            fmax v8.4s, v8.4s, v3.4s
            fmax v9.4s, v9.4s, v3.4s
            fmax v10.4s, v10.4s, v3.4s
            fmax v11.4s, v11.4s, v3.4s
            fmax v12.4s, v12.4s, v3.4s
            fmax v13.4s, v13.4s, v3.4s
            fmax v14.4s, v14.4s, v3.4s
            fmax v15.4s, v15.4s, v3.4s
            b Write

    

LoopRow4:                               
    mov x14, x1 // reload rhs ptr
    mov x13, x7 // reload rhs col
    mov x12, x3 // reload bias

    LoopCol4:
        cbz x9, NoReloadDst4
        mov x11, x2
    NoReloadDst4:
        mov x10, x0 // reload lhs ptr
        mov x19, x5 // reload depth


    LoopDepthStart4:
        ld1 {v0.4s, v1.4s, v2.4s}, [x10], #48
        ld1 {v3.4s, v4.4s, v5.4s}, [x10], #48
        ld1 {v6.4s}, [x14], #16
        fmul v8.4s, v6.4s, v0.s[0]
        fmul v10.4s, v6.4s, v0.s[1]
        fmul v12.4s, v6.4s, v0.s[2]
        fmul v14.4s, v6.4s, v0.s[3]

        subs x19, x19, #1
        beq Bias4

        LoopDepth4:
            ld1 {v0.4s, v1.4s, v2.4s}, [x10], #48
            ld1 {v3.4s, v4.4s, v5.4s}, [x10], #48
            ld1 {v6.4s}, [x14], #16
            fmla v8.4s, v6.4s, v0.s[0]
            fmla v10.4s, v6.4s, v0.s[1]
            fmla v12.4s, v6.4s, v0.s[2]
            fmla v14.4s, v6.4s, v0.s[3]

            subs x19, x19, #1
            bgt LoopDepth4

        Bias4:
            cbz x3, Activation4
            ld1 {v0.4s}, [x12], #16
            fadd v8.4s, v8.4s, v0.4s
            fadd v10.4s, v10.4s, v0.4s
            fadd v12.4s, v12.4s, v0.4s
            fadd v14.4s, v14.4s, v0.4s

        Activation4:
            cmp x4, #3
            beq Relu64
            cmp x4, #1
            beq Relu4
            b Write

        Relu64:
            mov w19, #6
            dup v2.4s, w19
            scvtf v2.4s, v2.4s
            fmin v8.4s, v8.4s, v2.4s
            fmin v10.4s, v10.4s, v2.4s
            fmin v12.4s, v12.4s, v2.4s
            fmin v14.4s, v14.4s, v2.4s
        
        Relu4:
            dup v3.4s, wzr
            fmax v8.4s, v8.4s, v3.4s
            fmax v10.4s, v10.4s, v3.4s
            fmax v12.4s, v12.4s, v3.4s
            fmax v14.4s, v14.4s, v3.4s
            b Write


        Write:                              
            // cmp x9, #2
            // beq WriteWino
            // cbz x9, WriteC8
            cmp x13, #1
            beq Write1
            cmp x13, #2
            beq Write2
            cmp x13, #3
            beq Write3
            b Write4

        Write1:
            add x2, x2, #4
            str s8, [x11]
            cmp x6, #1
            beq WriteEnd
            add x11, x11, x8
            str s10, [x11]
            cmp x6, #2
            beq WriteEnd
            add x11, x11, x8
            str s12, [x11]
            cmp x6, #3
            beq WriteEnd
            add x11, x11, x8
            str s14, [x11]
            cmp x6, #4
            beq WriteEnd
            add x11, x11, x8
            str s9, [x11]
            cmp x6, #5
            beq WriteEnd
            add x11, x11, x8
            str s11, [x11]
            cmp x6, #6
            beq WriteEnd
            add x11, x11, x8
            str s13, [x11]
            cmp x6, #7
            beq WriteEnd
            add x11, x11, x8
            str s15, [x11]
            cmp x6, #8
            beq WriteEnd
            add x11, x11, x8
            str s16, [x11]
            cmp x6, #9
            beq WriteEnd
            add x11, x11, x8
            str s18, [x11]
            cmp x6, #10
            beq WriteEnd
            add x11, x11, x8
            str s20, [x11]
            cmp x6, #11
            beq WriteEnd
            add x11, x11, x8
            str s22, [x11]
            cmp x6, #12
            beq WriteEnd
            add x11, x11, x8
            str s17, [x11]
            cmp x6, #13
            beq WriteEnd
            add x11, x11, x8
            str s19, [x11]
            cmp x6, #14
            beq WriteEnd
            add x11, x11, x8
            str s21, [x11]
            cmp x6, #15
            beq WriteEnd
            add x11, x11, x8
            str s23, [x11]
            cmp x6, #16
            beq WriteEnd
            add x11, x11, x8
            str s24, [x11]
            cmp x6, #17
            beq WriteEnd
            add x11, x11, x8
            str s26, [x11]
            cmp x6, #18
            beq WriteEnd
            add x11, x11, x8
            str s28, [x11]
            cmp x6, #19
            beq WriteEnd
            add x11, x11, x8
            str s30, [x11]
            cmp x6, #20
            beq WriteEnd
            add x11, x11, x8
            str s25, [x11]
            cmp x6, #21
            beq WriteEnd
            add x11, x11, x8
            str s27, [x11]
            cmp x6, #22
            beq WriteEnd
            add x11, x11, x8
            str s29, [x11]
            cmp x6, #23
            beq WriteEnd
            add x11, x11, x8
            str s31, [x11]
            add x11, x11, x8
            add x11, x11, #4
            b WriteEnd
        Write2:
            add x2, x2, #8
            st1 {v8.2s}, [x11], x8
            cmp x6, #1
            beq WriteEnd
            st1 {v10.2s}, [x11], x8
            cmp x6, #2
            beq WriteEnd
            st1 {v12.2s}, [x11], x8
            cmp x6, #3
            beq WriteEnd
            st1 {v14.2s}, [x11], x8
            cmp x6, #4
            beq WriteEnd
            st1 {v9.2s}, [x11], x8
            cmp x6, #5
            beq WriteEnd
            st1 {v11.2s}, [x11], x8
            cmp x6, #6
            beq WriteEnd
            st1 {v13.2s}, [x11], x8
            cmp x6, #7
            beq WriteEnd
            st1 {v15.2s}, [x11], x8
            cmp x6, #8
            beq WriteEnd
            st1 {v16.2s}, [x11], x8
            cmp x6, #9
            beq WriteEnd
            st1 {v18.2s}, [x11], x8
            cmp x6, #10
            beq WriteEnd
            st1 {v20.2s}, [x11], x8
            cmp x6, #11
            beq WriteEnd
            st1 {v22.2s}, [x11], x8
            cmp x6, #12
            beq WriteEnd
            st1 {v17.2s}, [x11], x8
            cmp x6, #13
            beq WriteEnd
            st1 {v19.2s}, [x11], x8
            cmp x6, #14
            beq WriteEnd
            st1 {v21.2s}, [x11], x8
            cmp x6, #15
            beq WriteEnd
            st1 {v23.2s}, [x11], x8
            cmp x6, #16
            beq WriteEnd
            st1 {v24.2s}, [x11], x8
            cmp x6, #17
            beq WriteEnd
            st1 {v26.2s}, [x11], x8
            cmp x6, #18
            beq WriteEnd
            st1 {v28.2s}, [x11], x8
            cmp x6, #19
            beq WriteEnd
            st1 {v30.2s}, [x11], x8
            cmp x6, #19
            beq WriteEnd
            st1 {v25.2s}, [x11], x8
            cmp x6, #20
            beq WriteEnd
            st1 {v27.2s}, [x11], x8
            cmp x6, #21
            beq WriteEnd
            st1 {v29.2s}, [x11], x8
            cmp x6, #22
            beq WriteEnd
            st1 {v31.2s}, [x11], x8
            add x11, x11, #8
            b WriteEnd
        Write3:
            add x2, x2, #12
            add x19, x11, #8
            st1 {v8.2s}, [x11], x8
            st1 {v8.s}[2], [x19], x8
            cmp x6, #1
            beq WriteEnd
            st1 {v10.2s}, [x11], x8
            st1 {v10.s}[2], [x19], x8
            cmp x6, #2
            beq WriteEnd
            st1 {v12.2s}, [x11], x8
            st1 {v12.s}[2], [x19], x8
            cmp x6, #3
            beq WriteEnd
            st1 {v14.2s}, [x11], x8
            st1 {v14.s}[2], [x19], x8
            cmp x6, #4
            beq WriteEnd
            st1 {v9.2s}, [x11], x8
            st1 {v9.s}[2], [x19], x8
            cmp x6, #5
            beq WriteEnd
            st1 {v11.2s}, [x11], x8
            st1 {v11.s}[2], [x19], x8
            cmp x6, #6
            beq WriteEnd
            st1 {v13.2s}, [x11], x8
            st1 {v13.s}[2], [x19], x8
            cmp x6, #7
            beq WriteEnd
            st1 {v15.2s}, [x11], x8
            st1 {v15.s}[2], [x19], x8
            cmp x6, #8
            beq WriteEnd
            st1 {v16.2s}, [x11], x8
            st1 {v16.s}[2], [x19], x8
            cmp x6, #9
            beq WriteEnd
            st1 {v18.2s}, [x11], x8
            st1 {v18.s}[2], [x19], x8
            cmp x6, #10
            beq WriteEnd
            st1 {v20.2s}, [x11], x8
            st1 {v20.s}[2], [x19], x8
            cmp x6, #11
            beq WriteEnd
            st1 {v22.2s}, [x11], x8
            st1 {v22.s}[2], [x19], x8
            cmp x6, #12
            beq WriteEnd
            st1 {v17.2s}, [x11], x8
            st1 {v17.s}[2], [x19], x8
            cmp x6, #13
            beq WriteEnd
            st1 {v19.2s}, [x11], x8
            st1 {v19.s}[2], [x19], x8
            cmp x6, #14
            beq WriteEnd
            st1 {v21.2s}, [x11], x8
            st1 {v21.s}[2], [x19], x8
            cmp x6, #15
            beq WriteEnd
            st1 {v23.2s}, [x11], x8
            st1 {v23.s}[2], [x19], x8
            cmp x6, #16
            beq WriteEnd
            st1 {v24.2s}, [x11], x8
            st1 {v24.s}[2], [x19], x8
            cmp x6, #17
            beq WriteEnd
            st1 {v26.2s}, [x11], x8
            st1 {v26.s}[2], [x19], x8
            cmp x6, #18
            beq WriteEnd
            st1 {v28.2s}, [x11], x8
            st1 {v28.s}[2], [x19], x8
            cmp x6, #19
            beq WriteEnd
            st1 {v30.2s}, [x11], x8
            st1 {v30.s}[2], [x19], x8
            cmp x6, #20
            beq WriteEnd
            st1 {v25.2s}, [x11], x8
            st1 {v25.s}[2], [x19], x8
            cmp x6, #21
            beq WriteEnd
            st1 {v27.2s}, [x11], x8
            st1 {v27.s}[2], [x19], x8
            cmp x6, #22
            beq WriteEnd
            st1 {v29.2s}, [x11], x8
            st1 {v29.s}[2], [x19], x8
            cmp x6, #23
            beq WriteEnd
            st1 {v31.2s}, [x11], x8
            st1 {v31.s}[2], [x19]
            add x11, x11, #12
            b WriteEnd
        Write4:
            add x2, x2, #16
            st1 {v8.4s}, [x11], x8
            cmp x6, #1
            beq WriteEnd
            st1 {v10.4s}, [x11], x8
            cmp x6, #2
            beq WriteEnd
            st1 {v12.4s}, [x11], x8
            cmp x6, #3
            beq WriteEnd
            st1 {v14.4s}, [x11], x8
            cmp x6, #4
            beq WriteEnd
            st1 {v9.4s}, [x11], x8
            cmp x6, #5
            beq WriteEnd
            st1 {v11.4s}, [x11], x8
            cmp x6, #6
            beq WriteEnd
            st1 {v13.4s}, [x11], x8
            cmp x6, #7
            beq WriteEnd
            st1 {v15.4s}, [x11], x8
            cmp x6, #8
            beq WriteEnd
            st1 {v16.4s}, [x11], x8
            cmp x6, #9
            beq WriteEnd
            st1 {v18.4s}, [x11], x8
            cmp x6, #10
            beq WriteEnd
            st1 {v20.4s}, [x11], x8
            cmp x6, #11
            beq WriteEnd
            st1 {v22.4s}, [x11], x8
            cmp x6, #12
            beq WriteEnd
            st1 {v17.4s}, [x11], x8
            cmp x6, #13
            beq WriteEnd
            st1 {v19.4s}, [x11], x8
            cmp x6, #14
            beq WriteEnd
            st1 {v21.4s}, [x11], x8
            cmp x6, #15
            beq WriteEnd
            st1 {v23.4s}, [x11], x8
            cmp x6, #16
            beq WriteEnd
            st1 {v24.4s}, [x11], x8
            cmp x6, #17
            beq WriteEnd
            st1 {v26.4s}, [x11], x8
            cmp x6, #18
            beq WriteEnd
            st1 {v28.4s}, [x11], x8
            cmp x6, #19
            beq WriteEnd
            st1 {v30.4s}, [x11], x8
            cmp x6, #20
            beq WriteEnd
            st1 {v25.4s}, [x11], x8
            cmp x6, #21
            beq WriteEnd
            st1 {v27.4s}, [x11], x8
            cmp x6, #22
            beq WriteEnd
            st1 {v29.4s}, [x11], x8
            cmp x6, #23
            beq WriteEnd
            st1 {v31.4s}, [x11], x8
            add x11, x11, #16
            b WriteEnd

        WriteEnd:
            subs x13, x13, #4 // rhs col - 4
            ble LoopColEnd
            cmp x6, #4
            ble LoopCol4
            cmp x6, #8
            ble LoopCol8
            cmp x6, #16
            ble LoopCol16
            b LoopCol

LoopColEnd:
        add x0, x0, x17
        mov x21, #4
        mul x21, x21, x7
        sub x11, x11, x21
        mov x2, x11
        subs x6, x6, #24
        bgt LoopRowStart

  sub sp, sp, #160
  ld1 {v8.4s, v9.4s, v10.4s, v11.4s}, [sp], #64
  ld1 {v12.4s, v13.4s, v14.4s, v15.4s}, [sp], #64
  ldp x19, x20, [sp], #16
  ldp x21, x22, [sp], #16
  ret
#endif
