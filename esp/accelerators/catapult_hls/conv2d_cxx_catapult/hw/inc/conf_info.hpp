// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONV2D_CONF_INFO_HPP__
#define __CONV2D_CONF_INFO_HPP__

#include "esp_headers.hpp"

//
// Configuration parameters for the accelerator
//
struct conf_info_t {
    uint32_t stride;	
    uint32_t same;
    uint32_t filt;
    uint32_t kern;
    uint32_t n_c;
    uint32_t n_h;
    uint32_t n_w;
    uint32_t batch;	
};

#endif // __CONV2D_CONF_INFO_HPP__
