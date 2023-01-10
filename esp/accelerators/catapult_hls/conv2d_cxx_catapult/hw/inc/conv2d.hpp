// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONV2D_CXX_HPP__
#define __CONV2D_CXX_HPP__

#include "fpdata.hpp"     // Fixed-point data types
#include "conf_info.hpp"  // Configuration-port data type

#include <ac_channel.h>   // Algorithmic C channel class
#include <ac_sync.h>
#include <ac_int.h>

// NoC-/Accelerator-interface dimensions
#define DMA_SIZE SIZE_DWORD

typedef ac_int<DMA_WIDTH, false> dma_data_t;

// PLM and data dimensions
#define DATA_WIDTH 32

#define BATCH_MAX 16
#define N_W_IN_MAX 18
#define N_H_IN_MAX 18
#define N_C_MAX 32
#define KERN_MAX 7
#define FILT_MAX 32
#define STRIDE_MAX 2
#define PAD_MAX 3

#define N_W_OUT_MAX 18
#define N_H_OUT_MAX 18

#define FILTERS_SIZE_MAX 50176
#define INPUTS_SIZE_MAX 10368
#define OUTPUTS_SIZE_MAX 10368



// Private Local Memory
// Encapsulate the PLM array in a templated struct
template <class T, unsigned S>
struct plm_t {
public:
   T data[S];
};

// Buffer
// Encapsulate the Buffer matrix in a templated struct
template <class T, unsigned R, unsigned C>
struct buf_t{
public:
	T data[R][C];
};

// PLM typedefs
typedef plm_t<FPDATA_IN, INPUTS_SIZE_MAX> plm_inputs_t;
typedef plm_t<FPDATA_IN, FILTERS_SIZE_MAX> plm_filters_t;
typedef plm_t<FPDATA_OUT, OUTPUTS_SIZE_MAX> plm_outputs_t;

typedef buf_t<FPDATA_ACC, N_W_OUT_MAX, N_H_OUT_MAX> buf_acc_t;

// Accelerator top module
void conv2d_cxx_catapult(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_channel<dma_data_t> &dma_write_chnl,
        ac_sync &acc_done);

#endif /* __CONV2D_CXX_HPP__ */
