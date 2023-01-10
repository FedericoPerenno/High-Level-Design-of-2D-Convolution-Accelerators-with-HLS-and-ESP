// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"
#include "conv2dlb.hpp"
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
        ac_channel<buf_lin_t> &buf_linear,
        ac_channel<plm_kernel_t> &plm_kernel,
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
	
	uint16_t batch_size = n_w * n_h * n_c + kern * kern * n_c * filt;
	uint16_t filters_size = kern * kern * n_c * filt;
	
	
        
LOAD_BATCH_LOOP:
    for (uint8_t b = 0; b < BATCH_MAX; b++) {
    
    	plm_inputs_t plm_tmp_in;
    	plm_kernel_t plm_tmp_f;
    	buf_lin_t buf_tmp_lin;

        //ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

        // Required to create shared memories
LOAD_LOOP:
	 	for (uint8_t fl = 0; fl < FILT_MAX; fl++)
		{
			for (uint8_t k = 0; k < N_C_MAX; k++)
			{
				//ESP_REPORT_INFO(VON, "Channel = %u",ESP_TO_UINT32(k));
				// Kernel read
				// Configure DMA read channel (CTRL)
				dma_read_data_index = batch_size * b + kern * kern * n_c * fl + kern * kern * k;
				dma_read_data_length = kern * kern;
				dma_info_t dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
				bool dma_read_ctrl_done = false;
				//dma_read_ctrl.write(dma_read_info);
				//dma_read_ctrl_done = true;
LOAD_CTRL_LOOP1:
				do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);
				
				//ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());
				
				// Force serialization between DMA control and DATA data transfer
       			if (dma_read_ctrl_done) { 
					for (uint8_t m = 0; m < KERN_MAX; m++)
					{
						for (uint8_t n = 0; n < KERN_MAX; n++)
						{
						#ifndef __SYNTHESIS__
							while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
						#endif
							ac_int<DATA_WIDTH, false> data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);

							FPDATA_IN data;
							data.set_slc(0, data_ac);
							
							uint8_t index_f = m * kern + n;
							plm_tmp_f.data[index_f] = data;

							//ESP_REPORT_INFO(VON, "plm_kernel[%u] = %f", ESP_TO_UINT32(index_f), data.to_double());
							if (n == kern - 1) break;
						}		        
				   		if (m == kern - 1) break;
			   		}
			   		plm_kernel.write(plm_tmp_f);
			   		//ESP_REPORT_INFO(VON, "Kernel has been written");
		   		}
		   		
		   		// Input read
		   		if (fl == 0)
	   			{
			   		// Configure DMA read channel (CTRL)
					dma_read_data_index = batch_size * b + filters_size + k * n_w * n_h;
					dma_read_data_length = n_w * n_h;
					dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
					dma_read_ctrl_done = false;
				LOAD_CTRL_LOOP2:
					do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);
				}
				//ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());
				
				uint8_t print_buf = kern - 1;
				// Force serialization between DMA control and DATA data transfer
	   			if (dma_read_ctrl_done) { 
			   		for (uint8_t row = 0; row < N_W_IN_MAX; row++)
					{
						//ESP_REPORT_INFO(VON, "Row = %u",ESP_TO_UINT32(row));
						for (uint8_t col = 0; col < N_H_IN_MAX; col++)
						{
							FPDATA_IN data;							
							
							if (fl == 0)
							{
							uint16_t index_in = k * n_w_in * n_h_in + row * n_w_in + col;
								if ((row >= pad) && (col >= pad) && (col < n_h_in - pad) && (row < n_w_in - pad))
								{
								#ifndef __SYNTHESIS__
									while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
								#endif
									ac_int<DATA_WIDTH, false> data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);
									
									data.set_slc(0, data_ac);
								 }
								 else{
								 	data = 0;
								 }
														
								plm_tmp_in.data[index_in] = data;								
							}	
							else
							{		  		
								uint16_t index_in = k * n_w_in * n_h_in + row * n_w_in + col;
								data = plm_tmp_in.data[index_in];
							}
							
							uint8_t row_norm;
							switch (kern){
								case 1:
									row_norm = row % 1;
									break;
								case 3:
									row_norm = row % 3;
									break;
								case 5:
									row_norm = row % 5;
									break;
								case 7:
									row_norm =  row % 7;
									break;
							}
								
							buf_tmp_lin.data[row_norm][col] = data;	
							
							//ESP_REPORT_INFO(VON, "buf_lin[%u][%u] = %f", ESP_TO_UINT32(row_norm), ESP_TO_UINT32(col), buf_tmp_lin.data[row_norm][col].to_double());
							
							if (col == n_h_in - 1) break;
						}
						
						if (row == print_buf)
						{
							buf_linear.write(buf_tmp_lin);
							print_buf += stride;
							//ESP_REPORT_INFO(VON, "BUFFER BEING WRITTEN");
						}  
						if (row == n_w_in - 1) break;
					} 	
				}
					   		
		   		if (k == n_c - 1) break;	
			}
			if (fl == filt - 1) break;
       	}	    						
        ESP_REPORT_INFO(VON, "load() --> compute()");
        if (b == batch - 1) break;
    }
    done.sync_out();
}

#pragma hls_design
void compute(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<buf_lin_t> &buf_linear,
        ac_channel<plm_kernel_t> &plm_kernel,
        ac_channel<FPDATA_OUT> &var_output,
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

        buf_lin_t buf_tmp_lin;
        buf_acc_t buf_tmp_acc;
        plm_kernel_t plm_tmp_f;
        FPDATA_OUT var_tmp_out;
		
		// convolution algorithm 
		// Fill output map			
CONVOLUTION_LOOP:
		for (uint8_t fl = 0; fl < FILT_MAX; fl++)
		{
			for (uint8_t k = 0; k < N_C_MAX; k++)
			{	
				plm_tmp_f = plm_kernel.read();			
				for (uint8_t i = 0; i < N_W_OUT_MAX; i++)
				{
					buf_tmp_lin = buf_linear.read();
				
					for (uint8_t j = 0; j < N_H_OUT_MAX; j++)
					{
						FPDATA_ACC acc = 0; // This holds the convolution results for an index.
						uint8_t x = i * stride; // input row
						uint8_t y = j * stride; // input col

						// Kernel rows and columns are m and n respectively
						for (uint8_t m = 0; m < KERN_MAX; m++)
						{
							for (uint8_t n = 0; n < KERN_MAX; n++)
							{								
								//------------------CONVOLUTION---------------------
								uint8_t index_f = m * kern + n;
								uint8_t x_tmp;
								switch (kern){
									case 1:
										x_tmp = x % 1;
										break;
									case 3:
										x_tmp = x % 3;
										break;
									case 5:
										x_tmp = x % 5;
										break;
									case 7:
										x_tmp = x % 7;
										break;
								}
								
								acc += buf_tmp_lin.data[x_tmp][y] * plm_tmp_f.data[index_f];
								
								
								// Move right by one position
								y++;
								//---------------------------------------------------									
								if (n == kern - 1) break;
							}
							x++; // Move down by one position (s=1)
							y = j * stride; // Restart column position
							
							if (m == kern - 1) break;
						}
						//uint16_t index_out = n_w_out * n_h_out * fl + i * n_w_out + j;
						if (k == 0)
							buf_tmp_acc.data[i][j] = acc; // Add result to output matrix
						else
							buf_tmp_acc.data[i][j] += acc;
						
						if (k == n_c - 1){
							//ESP_REPORT_INFO(VON, "BEFORE ACC[%u][%u] = %f", ESP_TO_UINT32(i), ESP_TO_UINT32(j), plm_tmp_out.data[index_out].to_double());
							var_tmp_out = buf_tmp_acc.data[i][j];
							//ESP_REPORT_INFO(VON, "FINAL ACC[%u][%u] = %f", ESP_TO_UINT32(i), ESP_TO_UINT32(j),  plm_tmp_out.data[index_out].to_double());
							var_output.write(var_tmp_out);
						}
						if (j == n_h_out - 1) break;
					}
					if (i == n_w_out - 1) break;
				}
				if (k == n_c - 1) break;
			}
			if (fl == filt - 1) break;
		}
		
		

		ESP_REPORT_INFO(VON, "compute() ---> store()");
		if (b == batch - 1) break;
    }

    done.sync_out();
}

#pragma hls_design
void store(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<FPDATA_OUT> &var_output,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_write_chnl,
        ac_sync &done) {

    // Bookkeping variables
    uint16_t dma_write_data_length = 0;
	uint16_t dma_write_data_index = 0;
	
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

STORE_BATCH_LOOP:
    for (uint8_t b = 0; b < BATCH_MAX; b++) {

        ESP_REPORT_INFO(VOFF, "store() --> compute()");
                 
STORE_INNER_LOOP:
        for (uint8_t fl = 0; fl < FILT_MAX; fl++)
		{		
			// Configure DMA write controller
			dma_write_data_index = (n_w * n_h * n_c + kern * kern * n_c * filt) * batch + n_w_out * n_h_out * n_c * b + n_w_out * n_h_out * fl;
			dma_write_data_length = n_w_out * n_h_out;	
			
			dma_info_t dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
		    bool dma_write_ctrl_done = false;
		    dma_write_ctrl.write(dma_write_info);
		    dma_write_ctrl_done = true;
		    
		    ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());
        
			if (dma_write_ctrl_done) {
				for (uint8_t i = 0; i < N_W_OUT_MAX; i++)
				{	
					for (uint8_t j = 0; j < N_H_OUT_MAX; j++)
					{
						FPDATA_OUT var_tmp_out = var_output.read();
						FPDATA_OUT data = var_tmp_out;

						ac_int<DMA_WIDTH, false> data_ac;
						ac_int<32, false> DEADBEEF = 0xdeadbeef;
					  	data_ac.set_slc(32, DEADBEEF.template slc<32>(0));
						data_ac.set_slc(0, data.template slc<DATA_WIDTH>(0));

						dma_write_chnl.write(data_ac);

						ESP_REPORT_INFO(VON, "plm_out[%u][%u][%u] = %f", ESP_TO_UINT32(i), ESP_TO_UINT32(j), ESP_TO_UINT32(fl), data.to_double());
						
						if (j == n_h_out - 1) break;
		    		}
		    		if (i == n_w_out - 1) break;
				}
			}
    		if (fl == filt - 1) break;
        }
        if (b == batch - 1) break;
    }
    done.sync_out();
}

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void conv2dlb_cxx_catapult(
#else
void CCS_BLOCK(conv2dlb_cxx_catapult)(
#endif
    ac_channel<conf_info_t> &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    static ac_channel<buf_lin_t> buf_linear;
    static ac_channel<plm_kernel_t> plm_kernel;
    static ac_channel<FPDATA_OUT> var_output;

    static ac_channel<conf_info_t> plm_conf_load;
    static ac_channel<conf_info_t> plm_conf_compute;
    static ac_channel<conf_info_t> plm_conf_store;
    static ac_sync config_done;
    static ac_sync load_done;
    static ac_sync compute_done;
    static ac_sync store_done;

    config(conf_info, plm_conf_load, plm_conf_compute, plm_conf_store, config_done);

    load(plm_conf_load, buf_linear, plm_kernel, dma_read_ctrl, dma_read_chnl, load_done);
    compute(plm_conf_compute, buf_linear, plm_kernel, var_output, compute_done);
    store(plm_conf_store, var_output, dma_write_ctrl, dma_write_chnl, store_done);

    config_done.sync_in();
    load_done.sync_in();
    compute_done.sync_in();
    store_done.sync_in();

    acc_done.sync_out();
}
