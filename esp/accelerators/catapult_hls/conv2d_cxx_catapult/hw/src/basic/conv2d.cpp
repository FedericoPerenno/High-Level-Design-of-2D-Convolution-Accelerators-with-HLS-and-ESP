// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"
#include "conv2d.hpp"
#include <mc_scverify.h>

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

    // DMA configuration
    dma_info_t dma_read_info = {0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0};
	
    // Private Local Memories
	plm_inputs_t plm_in;
    plm_filters_t plm_f;
    plm_outputs_t plm_out;
    
    // Buffers
    buf_acc_t buf_acc;
    
    // Parameters
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
	
	// Padded Input Dimensions
	const uint8_t n_w_in = n_w + 2 * pad;
	const uint8_t n_h_in = n_h + 2 * pad;
	
	// Output Dimensions
	uint8_t n_w_out;
	uint8_t n_h_out;
	if (stride == 1){
		n_w_out = (n_w + 2 * pad - kern) + 1;
		n_h_out = (n_h + 2 * pad - kern) + 1;
	}
	else{
		n_w_out = (n_w + 2 * pad - kern)/2 + 1;
		n_h_out = (n_h + 2 * pad - kern)/2 + 1;
	}
	
	// DMA variables
    uint16_t dma_read_data_index = 0;
    uint16_t dma_read_data_length = n_w * n_h * n_c + kern * kern * n_c * filt;
    uint16_t dma_write_data_index= 0;
    uint16_t dma_write_data_length = n_w_out * n_h_out * filt;
    
	ESP_REPORT_INFO(VOFF, "pad= %u", ESP_TO_UINT32(pad));
	ESP_REPORT_INFO(VOFF, "n_w_in= %u", ESP_TO_UINT32(n_w_in));
	ESP_REPORT_INFO(VOFF, "n_h_in= %u", ESP_TO_UINT32(n_h_in));
	ESP_REPORT_INFO(VOFF, "n_w_out= %u", ESP_TO_UINT32(n_w_out));
	ESP_REPORT_INFO(VOFF, "n_h_out= %u", ESP_TO_UINT32(n_h_out));
	ESP_REPORT_INFO(VOFF, "dma_read_data_length= %u", ESP_TO_UINT32(dma_read_data_length));
	
BATCH_LOOP:
    for (uint8_t b = 0; b < BATCH_MAX; b++) {
		
        // Configure DMA read channel (CTRL)
        dma_read_data_index = dma_read_data_length * b;
        dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        bool dma_read_ctrl_done = false;
LOAD_CTRL_LOOP:
        do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);
	
		// Force serialization between DMA control and DATA data transfer
        if (dma_read_ctrl_done) 
        { 
LOAD_LOOP:
            for (uint16_t i = 0; i < FILTERS_SIZE_MAX; i++) 
            {
                // DMA_WIDTH = 64
                // DATA_WIDTH = 32
                // discard bits in the DMA range(63,32)
                // keep bits in the DMA range(31,0)
#ifndef __SYNTHESIS__
                while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
                ac_int<DATA_WIDTH, false> data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);

                FPDATA_IN data;
                data.set_slc(0, data_ac);

                plm_f.data[i] = data;
                
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
						plm_in.data[index_in] = data;
						
						if (col == n_h_in - 1) break;
					}
					if (row == n_w_in - 1) break;
				}
				if (chan == n_c - 1) break;
			}
        }
		
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
						ac_fixed<FPDATA_WL + FPDATA_OUT_IL - 1, FPDATA_OUT_IL * 2 - 1, true, AC_RND_CONV, AC_SAT> acc = 0; // This holds a single convolution result
						uint8_t x = i * stride;
						uint8_t y = j * stride;

						// Kernel rows and columns are m and n respectively
						for (uint8_t m = 0; m < KERN_MAX; m++)
						{
							for (uint8_t n = 0; n < KERN_MAX; n++)
							{
								
								// Convolve here.
								uint16_t index_f, index_in;
								index_f = fl * kern * kern * n_c + k * kern * kern + m * kern + n;
								index_in = n_w_in * n_h_in * k + x * n_w_in + y;
								
								acc += plm_f.data[index_f] * plm_in.data[index_in];
								
								//ESP_REPORT_INFO(VON, "plm_f[%u] x plm_in[%u] -->> %f x %f = %f", index_f, index_in, plm_f.data[index_f].to_double(), plm_in.data[index_in].to_double(), acc.to_double());
								
						   		y++; // Move right by one position 
						   		
						   		if (n == kern - 1) break;
							}
							x++; // Move down by one position 
							y = j * stride; // Restart column position
							
							if (m == kern - 1) break;
							
						}
						uint16_t index_out = n_w_out * n_h_out * fl + i * n_w_out + j;
						
						if (k == 0)
							buf_acc.data[i][j] = acc;
						else
							buf_acc.data[i][j] += acc;
							
						if (k == n_c - 1)
							plm_out.data[index_out] = buf_acc.data[i][j]; 
						
						if (j == n_h_out - 1) break;
					}
					if (i == n_w_out - 1) break;
				}	
				if (k == n_c - 1) break;
			}			
			if (fl == filt - 1) break;
		}


        // Configure DMA write channel (CTRL)
        dma_write_data_index = (dma_read_data_length * batch) + dma_write_data_length * b;
        dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        bool dma_write_ctrl_done = false;
        dma_write_ctrl.write(dma_write_info);
        dma_write_ctrl_done = true;

        ESP_REPORT_INFO(VOFF, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
STORE_LOOP:
            for (uint16_t i = 0; i < OUTPUTS_SIZE_MAX; i++) {
               		
				// Store data
                FPDATA_OUT data = plm_out.data[i];

                // DMA_WIDTH = 64
                // but DATA_WIDTH = 32
                // set to a constante value range(63,32)
                // return results on the range(31,0)
                assert(DMA_WIDTH == 64 && "DMA_WIDTH should be 64 (simplicity choice)");
                ac_int<DMA_WIDTH, false> data_ac;
                ac_int<32, false> DEADBEEF = 0xdeadbeef;
          		data_ac.set_slc(32, DEADBEEF.template slc<32>(0));
                data_ac.set_slc(0, data.template slc<DATA_WIDTH>(0));

                dma_write_chnl.write(data_ac);

                ESP_REPORT_INFO(VOFF, "plm_out[%u] = %f", ESP_TO_UINT32(i), data.to_double());
                
                if (i == dma_write_data_length - 1) break;
            }
        }
        if (b == batch - 1) break;
    }

    acc_done.sync_out();
}
