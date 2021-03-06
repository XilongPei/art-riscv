/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ART_RUNTIME_ARCH_RISCV64_ASM_SUPPORT_RISCV64_S_
#define ART_RUNTIME_ARCH_RISCV64_ASM_SUPPORT_RISCV64_S_

#include "asm_support_riscv64.h"

// Define special registers.

// Register holding suspend check count down.
#define rSUSPEND s11
// Register holding Thread::Current().
#define rSELF s1


    // Declare a function called name, doesn't set up $gp.
.macro ENTRY_NO_GP_CUSTOM_CFA name, cfa_offset
    .type \name, %function
    .global \name
    // Cache alignment for function entry.
    .balign 16
\name:
    .cfi_startproc
     // Ensure we get a sane starting CFA.
    .cfi_def_cfa sp, \cfa_offset
.endm

    // Declare a function called name, doesn't set up $gp.
.macro ENTRY_NO_GP name
    ENTRY_NO_GP_CUSTOM_CFA \name, 0
.endm

    // Declare a function called name, sets up $gp.
    // This macro modifies t8.
.macro ENTRY name
    ENTRY_NO_GP \name
    // Set up $gp and store the previous $gp value to $t8. It will be pushed to the
    // stack after the frame has been constructed.
    // FIXME: T-HEAD, Need check here in future.
    // .cpsetup $t9, $t8, \name
    // Declare a local convenience label to be branched to when $gp is already set up.
.L\name\()_gp_set:
.endm

.macro END name
    .cfi_endproc
    .size \name, .-\name
.endm

.macro UNIMPLEMENTED name
    ENTRY \name
    break
    break
    END \name
.endm

// Macros to poison (negate) the reference for heap poisoning.
.macro POISON_HEAP_REF rRef
#ifdef USE_HEAP_POISONING
    dsubu \rRef, zero, \rRef
    dext  \rRef, \rRef, 0, 32
#endif  // USE_HEAP_POISONING
.endm

// Macros to unpoison (negate) the reference for heap poisoning.
.macro UNPOISON_HEAP_REF rRef
#ifdef USE_HEAP_POISONING
    dsubu \rRef, zero, \rRef
    dext  \rRef, \rRef, 0, 32
#endif  // USE_HEAP_POISONING
.endm

// Byte size of the instructions (un)poisoning heap references.
#ifdef USE_HEAP_POISONING
#define HEAP_POISON_INSTR_SIZE 8
#else
#define HEAP_POISON_INSTR_SIZE 0
#endif  // USE_HEAP_POISONING

#endif  // ART_RUNTIME_ARCH_RISCV64_ASM_SUPPORT_RISCV64_S_
