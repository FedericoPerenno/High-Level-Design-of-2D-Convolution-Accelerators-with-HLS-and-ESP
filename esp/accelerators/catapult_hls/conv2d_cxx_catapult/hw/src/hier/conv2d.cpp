// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"
#include "conv2d.hpp"
#include <mc_scverify.h>

#pragma hls_design
void config(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<conf_info_t> &plm_conf_load,
        ac_channel<conf_info_t> &plm_conf_compute,
        ac_channel<conf_info_t> &plm_conf_store,
        ac_sync &done) {

    struct conf_info_t params;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    params = conf_info.read();

    conf_info_t conf_info_load_tmp;
    conf_info_t conf_info_compute_tmp;
    conf_info_t conf_info_store_tmp;

    conf_info_load_tmp = params;
    conf_info_compute_tmp = params;
    conf_info_store_tmp = params;

    plm_conf_load.write(conf_info_load_tmp);
    plm_conf_compute.write(conf_info_compute_tmp);
    plm_conf_store.write(conf_info_store_tmp);

    done.sync_out();
}

#pragma hls_design
void load(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<plm_inputs_t> &plm_inputs,
        ac_channel<plm_filters_t> &plm_filters,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_sync &done) {

    // Bookkeeping variables
    uint16_t dma_read_data_index = 0;
    uint16_t dma_read_data_length = 0;

    struct conf_info_t params;
    uint8_t batch = 0;
    uint8_t n_w = 0;
	uint8_t n_h = 0;
	uint8_t n_c = 0;
	uint8_t kern = 0;
	uint8_t filt = 0;
	uint8_t same = 0;
	uint8_t stride = 0;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    params = conf_info.read();
    
    batch = params.batch;
    n_w  = params.n_w;
    n_h = params.n_h;
    n_c = params.n_c;
    kern = params.kern;
    filt = params.filt;
    same = params.same;
    stride = params.stride;
    
    const uint8_t pad = ((stride * (n_w - 1) - n_w + kern) / 2) * same;
    const uint8_t n_w_in = n_w + 2 * pad;
	const uint8_t n_h_in = n_h + 2 * pad;
	
	dma_read_data_length = n_w * n_h * n_c + kern * kern * n_c * filt;
	
LOAD_BATCH_LOOP:
    for (uint8_t b = 0; b < BATCH_MAX; b++) {

        // Configure DMA read channel (CTRL)
        dma_read_data_index = dma_read_data_length * b;
        dma_info_t dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        bool dma_read_ctrl_done = false;
LOAD_CTRL_LOOP:
        do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

        // Required to create shared memories
        plm_filters_t plm_tmp_f;
        plm_inputs_t plm_tmp_in;

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_LOOP:
            for (uint16_t i = 0; i < FILTERS_SIZE_MAX; i++) {

                // DATA_WIDTH = 64
                // DATA_WIDTH = 32
                // discard bits in the DMA range(63,32)
                // keep bits in the DMA range(31,0)
#ifndef __SYNTHESIS__
                while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
                ac_int<DATA_WIDTH, false> data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);

                FPDATA_IN data;
                data.set_slc(0, data_ac);

                plm_tmp_f.data[i] = data;

                //ESP_REPORT_INFO(VON, "plm_filters[%u] = %f", ESP_TO_UINT32(i), data.to_double());
                
                if (i == kern * kern * n_c * filt - 1) break;
            }

PADDING_LOOP:
			for (uint8_t chan = 0; chan < N_C_MAX; chan++)
		    {
				for (uint8_t row = 0; row < N_W_IN_MAX; row++)
				{
					for (uint8_t col = 0; col < N_H_IN_MAX; col++)
					{
						FPDATA_IN data;
						
						if ((row >= pad) && (col >= pad) && (col < n_h_in - pad) && (row < n_w_in - pad))
						{
							// DATA_WIDTH = 64
							// DATA_WIDTH = 32
							// discard bits in the DMA range(63,32)
							// keep bits in the DMA range(31,0)
			#ifndef __SYNTHESIS__
							while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
			#endif
							ac_int<DATA_WIDTH, false> data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);
							
							data.set_slc(0, data_ac);
						 }
						else{	
							data = 0;
						}
						
						uint16_t index_in = chan * n_w_in * n_h_in + row * n_h_in + col; 
						plm_tmp_in.data[index_in] = data;

						//ESP_REPORT_INFO(VON, "buf_lin[%u][%u] = %f", row, col, data.to_double());
						if (col == n_h_in - 1) break;
					}
					if (row == n_w_in - 1) break;
				}
				if (chan == n_c - 1) break;
			}
        }
		
		plm_filters.write(plm_tmp_f);
        plm_inputs.write(plm_tmp_in);

        ESP_REPORT_INFO(VON, "load() --> compute()");
        
        if (b == batch - 1) break;
    }

    done.sync_out();
}

#pragma hls_design
void compute(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<plm_inputs_t> &plm_inputs,
        ac_channel<plm_filters_t> &plm_filters,
        ac_channel<plm_outputs_t> &plm_outputs,
        ac_sync &done) {

    struct conf_info_t params;
    uint8_t batch = 0;
    uint8_t n_w = 0;
	uint8_t n_h = 0;
	uint8_t n_c = 0;
	uint8_t kern = 0;
	uint8_t filt = 0;
	uint8_t same = 0;
	uint8_t stride = 0;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    params = conf_info.read();
    
    batch = params.batch;
    n_w  = params.n_w;
    n_h = params.n_h;
    n_c = params.n_c;
    kern = params.kern;
    filt = params.filt;
    same = params.same;
    stride = params.stride;
	
	const uint8_t pad = ((stride * (n_w - 1) - n_w + kern) / 2) * same;
	const uint8_t n_w_in = n_w + 2 * pad;
	const uint8_t n_h_in = n_h + 2 * pad;
	uint8_t n_w_out, n_h_out;
	if (stride == 1){
		n_w_out = (n_w + 2 * pad - kern) + 1;
		n_h_out = (n_h + 2 * pad - kern) + 1;
	}
	else{
		n_w_out = (n_w + 2 * pad - kern)/2 + 1;
		n_h_out = (n_h + 2 * pad - kern)/2 + 1;
	}
	
COMPUTE_LOOP:
    for (uint8_t b = 0; b < BATCH_MAX; b++) 
    {
        ESP_REPORT_INFO(VOFF, "compute() <---> load()");
		
		// PLMs
        plm_inputs_t plm_tmp_in;
        plm_filters_t plm_tmp_f;
        plm_outputs_t plm_tmp_out;
        
        // Buffers
    	buf_acc_t buf_acc;

        plm_tmp_in = plm_inputs.read();
        plm_tmp_f = plm_filters.read();
		
		// compute algorithm 
		// Fill output map
CONVOLUTION_LOOP:
		for (uint8_t fl = 0; fl < FILT_MAX; fl++)
		{
			for (uint8_t k = 0; k < N_C_MAX; k++)
			{				
				for (uint8_t i = 0; i < N_W_OUT_MAX; i++)
				{
					for (uint8_t j = 0; j < N_H_OUT_MAX; j++)
					{
						ac_fixed<FPDATA_WL + FPDATA_OUT_IL - 1, FPDATA_OUT_IL * 2 - 1, true, AC_RND_CONV, AC_SAT> acc = 0; // This holds the convolution results for an index.
						uint8_t x = i * stride;
						uint8_t y = j * stride;

						// Kernel rows and columns are m and n respectively
						for (uint8_t m = 0; m < KERN_MAX; m++)
						{
							for (uint8_t n = 0; n < KERN_MAX; n++)
							{
								
								// Convolute here.
								uint16_t index_f, index_in;
								index_f = fl * kern * kern * n_c + k * kern * kern + m * kern + n;
								index_in = n_w_in * n_h_in * k + x * n_w_in + y;
								//temp = acc;
								acc += plm_tmp_f.data[index_f] * plm_tmp_in.data[index_in];
								
								//ESP_REPORT_INFO(VON, "plm_f[%u] x plm_in[%u] -->> %f x %f = %f", index_f, index_in, plm_f.data[index_f].to_double(), plm_in.data[index_in].to_double(), acc.to_double());
								
						   		y++; // Move right by one position (s=1)
						   		
						   		if (n == kern - 1) break;
							}
							x++; // Move down by one position (s=1)
							y = j * stride; // Restart column position
							
							if (m == kern - 1) break;
							
						}
						uint16_t index_out = n_w_out * n_h_out * fl + i * n_w_out + j;
						
						if (k == 0)
							buf_acc.data[i][j] = acc;
						else
							buf_acc.data[i][j] += acc;
							
						if (k == n_c - 1)
							plm_tmp_out.data[index_out] = buf_acc.data[i][j]; 
						
						//ESP_REPORT_INFO(VON, "BEFORE ACC[%u][%u] = %f", i, j, acc.to_double());
						//ESP_REPORT_INFO(VON, "FINAL ACC[%u][%u] = %f", i, j,  plm_out.data[index_out].to_double());
						if (j == n_h_out - 1) break;
					}
					if (i == n_w_out - 1) break;
				}	
				if (k == n_c - 1) break;
			}			
			if (fl == filt - 1) break;
		}
		plm_outputs.write(plm_tmp_out);

		ESP_REPORT_INFO(VON, "compute() ---> store()");
		if (b == batch - 1) break;
    }

    done.sync_out();
}

#pragma hls_design
void store(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<plm_outputs_t> &plm_outputs,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_write_chnl,
        ac_sync &done) {

    // Bookkeping variables
    uint16_t dma_write_data_index= 0;
    uint16_t dma_write_data_length = 0;

    struct conf_info_t params;
    uint8_t batch = 0;
    uint8_t n_w = 0;
	uint8_t n_h = 0;
	uint8_t n_c = 0;
	uint8_t kern = 0;
	uint8_t filt = 0;
	uint8_t same = 0;
	uint8_t stride = 0;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    params = conf_info.read();
    
    batch = params.batch;
    n_w  = params.n_w;
    n_h = params.n_h;
    n_c = params.n_c;
    kern = params.kern;
    filt = params.filt;
    same = params.same;
    stride = params.stride;
    
    const uint8_t pad = ((stride * (n_w - 1) - n_w + kern) / 2) * same;
    uint8_t n_w_out, n_h_out;
	if (stride == 1){
		n_w_out = (n_w + 2 * pad - kern) + 1;
		n_h_out = (n_h + 2 * pad - kern) + 1;
	}
	else{
		n_w_out = (n_w + 2 * pad - kern)/2 + 1;
		n_h_out = (n_h + 2 * pad - kern)/2 + 1;
	}
	
    dma_write_data_length = n_w_out * n_h_out * filt;

STORE_BATCH_LOOP:
    for (uint8_t b = 0; b < BATCH_MAX; b++) {

        ESP_REPORT_INFO(VON, "store() --> compute()");

        // Configure DMA write channle (CTRL)
        dma_write_data_index = batch * (n_w * n_h * n_c + kern * kern * n_c * filt) + dma_write_data_length * b;
        dma_info_t dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        bool dma_write_ctrl_done = false;
        dma_write_ctrl.write(dma_write_info);
        dma_write_ctrl_done = true;

        ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
            // Required to create shared memories
            plm_outputs_t plm_tmp = plm_outputs.read();

STORE_INNER_LOOP:
            for (uint16_t i = 0; i < OUTPUTS_SIZE_MAX; i++) {
                         
                FPDATA_OUT data = plm_tmp.data[i];

                // DMA_WIDTH = 64
                // DATA_WIDTH = 32
                // set to a constante value range(63,32)
                // return results on the range(31,0)
                //assert(DMA_WIDTH == 64 && "DMA_WIDTH should be 64 (simplicity choice)");
                ac_int<DMA_WIDTH, false> data_ac;
                ac_int<32, false> DEADBEEF = 0xdeadbeef;
              	data_ac.set_slc(32, DEADBEEF.template slc<32>(0));
                data_ac.set_slc(0, data.template slc<DATA_WIDTH>(0));

                dma_write_chnl.write(data_ac);

                ESP_REPORT_INFO(VON, "plm_out[%u] = %f", ESP_TO_UINT32(i), data.to_double());
                
                if (i == dma_write_data_length - 1) break;
            }
        }
        if (b == batch - 1) break;
    }

    done.sync_out();
}

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void conv2d_cxx_catapult(
#else
void CCS_BLOCK(conv2d_cxx_catapult)(
#endif
    ac_channel<conf_info_t> &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    static ac_channel<plm_inputs_t> plm_inputs;
    static ac_channel<plm_filters_t> plm_filters;
    static ac_channel<plm_outputs_t> plm_outputs;

    static ac_channel<conf_info_t> plm_conf_load;
    static ac_channel<conf_info_t> plm_conf_compute;
    static ac_channel<conf_info_t> plm_conf_store;
    static ac_sync config_done;
    static ac_sync load_done;
    static ac_sync compute_done;
    static ac_sync store_done;

    config(conf_info, plm_conf_load, plm_conf_compute, plm_conf_store, config_done);

    load(plm_conf_load, plm_inputs, plm_filters, dma_read_ctrl, dma_read_chnl, load_done);
    compute(plm_conf_compute, plm_inputs, plm_filters, plm_outputs, compute_done);
    store(plm_conf_store, plm_outputs, dma_write_ctrl, dma_write_chnl, store_done);

    config_done.sync_in();
    load_done.sync_in();
    compute_done.sync_in();
    store_done.sync_in();

    acc_done.sync_out();
}
