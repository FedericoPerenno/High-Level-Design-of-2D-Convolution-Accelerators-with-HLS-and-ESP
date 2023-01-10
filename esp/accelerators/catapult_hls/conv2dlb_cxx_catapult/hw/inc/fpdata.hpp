// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONV2DLB_FPDATA_HPP__
#define __CONV2DLB_FPDATA_HPP__

#include "ac_fixed.h"

#define FX_WIDTH 32
#define FX32_IN_IL 16
#define FX32_OUT_IL 16

// Data types

const unsigned int WORD_SIZE = FX_WIDTH;

const unsigned int FPDATA_WL = FX_WIDTH;

const unsigned int FPDATA_IN_IL = FX32_IN_IL; // parte intera

const unsigned int FPDATA_OUT_IL = FX32_OUT_IL; // parte intera

const unsigned int FPDATA_IN_PL = (FPDATA_WL - FPDATA_IN_IL);

const unsigned int FPDATA_OUT_PL = (FPDATA_WL - FPDATA_OUT_IL);

const unsigned int FPDATA_ACC_IL = 2 * FPDATA_IN_IL + 9;

const unsigned int FPDATA_ACC_WL = FPDATA_ACC_IL +  FPDATA_OUT_PL;

typedef ac_int<WORD_SIZE> FPDATA_WORD;

//ac_fixed <total bits, bits for integer value, signed?, decimal precision, overflow>
typedef ac_fixed<FPDATA_WL, FPDATA_IN_IL, true, AC_TRN, AC_WRAP> FPDATA_IN;
typedef ac_fixed<FPDATA_ACC_WL, FPDATA_ACC_IL, true, AC_RND_CONV, AC_SAT> FPDATA_ACC;
typedef ac_fixed<FPDATA_WL, FPDATA_OUT_IL, true, AC_RND_CONV, AC_SAT> FPDATA_OUT;

#endif // __CONV2DLB_FPDATA_HPP__
