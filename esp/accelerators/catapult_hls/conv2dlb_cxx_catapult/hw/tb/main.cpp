//#include "../inc/espacc_config.h"
//#include "../inc/espacc.h"

#include "conv2dlb.hpp"
#include "esp_headers.hpp" // ESP-common headers

#include <cstdlib>
#include <cstdio>
#include <time.h>

#include <mc_scverify.h>   // Enable SCVerify

void conv2dlb_tb(FPDATA_IN *input, double *output) {
	
	const int n_w = 18;
	const int n_h = 18;
	const int n_c = 32;
	const int kern = 7;
	const int filt = 32;
	const int same = 0;
	const int stride = 2;
	
	const int pad = ((stride * (n_w - 1) - n_w + kern) / 2) * same;
	const int n_w_in = n_w + 2 * pad;
	const int n_h_in = n_h + 2 * pad;
	const int n_w_out = (n_w + 2 * pad - kern)/(stride) + 1;
	const int n_h_out = (n_h + 2 * pad - kern)/(stride) + 1;
	
	
	// initialize filter  and padded buffer
	double filterBuffer[kern * kern * n_c * filt];
	double paddedBuffer[n_w_in * n_h_in * n_c];
	
	unsigned channel_size = n_w * n_h;
	unsigned kernel_size = kern * kern;
	
	// First filter and input tensors
	for (unsigned k = 0; k < n_c; k++)
	{		
		//kernel
		for (unsigned m = 0; m < kern; m++)
		{
			for (unsigned n = 0; n < kern; n++)
			{
				unsigned index_f = k * kern * kern + m * kern + n;
				unsigned index_in = channel_size * k + index_f;
				filterBuffer[index_f] = input[index_in].to_double();
				//ESP_REPORT_INFO(VON, "filterBuffer[%u] = %f", index_f, filterBuffer[index_f]);
			}
		}
		
		//padding
		unsigned index_in = kernel_size * (k+1) + channel_size * k;
		for (unsigned row = 0; row < n_w_in; row++)
		{
			for (unsigned col = 0; col < n_h_in; col++)
			{
				unsigned index_pad = k * n_w_in * n_h_in + row * n_w_in + col;
				
				if ((row >= pad) && (col >= pad) && (col < n_h_in - pad) && (row < n_w_in - pad))
				{
					paddedBuffer[index_pad] = input[index_in].to_double();
					index_in++;
				}
				else
				{	
					paddedBuffer[index_pad] = 0;
				}	
				//ESP_REPORT_INFO(VON, "paddedBuffer[%u] = %f", index_pad, paddedBuffer[index_pad]);						

	  		}
  		}	
	}
	
	unsigned filter_filled = n_c * kern * kern;
	
	for (unsigned index_f = filter_filled; index_f < n_c * kern * kern * filt; index_f++)
	{
		unsigned index_in = index_f +  n_c * n_w * n_h;
		filterBuffer[index_f] = input[index_in].to_double();
		//ESP_REPORT_INFO(VON, "filterBuffer[%u] = %f", index_f, filterBuffer[index_f]);
	}
	
    double acc = 0;
    unsigned x, y;
    // Set golden output
    for (unsigned fl = 0; fl < filt; fl++)
    {
		for (unsigned i = 0; i < n_w_out; i++)
		{
	 	    for (unsigned j = 0; j < n_h_out; j++)
			{
				x = i * stride;
				y = j * stride;

				// Kernel rows and columns are m and n respectively
				for (unsigned m = 0; m < kern; m++)
				{
					for (unsigned n = 0; n < kern; n++)
					{
						for (unsigned k = 0; k < n_c; k++)
						{
							// Convolute here.
							unsigned index_f, index_in;
							index_f = fl * kern * kern * n_c + k * kern * kern + m * kern + n; //filter
							index_in = n_w_in * n_h_in * k + x * n_w_in + y; //padded input
							acc += filterBuffer[index_f] * paddedBuffer[index_in];
							
							//ESP_REPORT_INFO(VON, "plm_f[%u] x plm_in[%u] -->> %f x %f = %f", index1, index2, input[index1].to_double(), paddedBuffer[index2], acc);
						}
						y++; // Move right by one position (s=1)
					}
					x++; // Move down by one position (s=1)
					y = j * stride; // Restart column position
				}
				//ESP_REPORT_INFO(VON, "FINAL ACC = %f", acc);
				unsigned index_out = n_w_out * n_h_out * fl + i * n_w_out + j;
				if (acc >= 32768)
					output[index_out] = 32767.999985;
				else if (acc < -32768)
					output[index_out] = - 32768;
				else
					output[index_out] = acc; // Add result to output matrix
				acc = 0; // Needed before we move on to the next index.
			}
        }
    }
}

double abs_double(const double &input)
{
    return input < 0 ? -input : input;
}

CCS_MAIN(int argv, char **argc) {
    ESP_REPORT_INFO(VON, "--------------------------------");
    ESP_REPORT_INFO(VON, "ESP - Conv2DLB [Catapult HLS C++]");
#ifdef HIERARCHICAL_BLOCKS
    ESP_REPORT_INFO(VON, "      Hierarchical blocks");
#else
    ESP_REPORT_INFO(VON, "      Single block");
#endif
    ESP_REPORT_INFO(VON, "--------------------------------");
    
	// Set config parameters
	const uint8_t batch = 1; 
	const uint8_t n_w = 18;
	const uint8_t n_h = 18;
	const uint8_t n_c = 32;
	const uint8_t kern = 7;
	const uint8_t filt = 32;
	const uint8_t same = 0;
	const uint8_t stride = 2;
	
	// Parameters for validation
	const uint8_t pad = ((stride * (n_w - 1) - n_w + kern) / 2) * same;
	const uint8_t n_w_out = (n_w + 2 * pad - kern)/(stride) + 1;
	const uint8_t n_h_out = (n_h + 2 * pad - kern)/(stride) + 1;
	
    const unsigned input_size = n_w * n_h * n_c + kern * kern * n_c * filt;
    const unsigned output_size = n_w_out * n_h_out * filt;

    // Testbench return value (0 = PASS, non-0 = FAIL)
    int rc = 0;

    // Accelerator configuration
    ac_channel<conf_info_t> conf_info;

    conf_info_t conf_info_data;

    conf_info_data.batch = batch;
    conf_info_data.n_w = n_w;
    conf_info_data.n_h = n_h;
    conf_info_data.n_c = n_c;    
    conf_info_data.kern = kern;
    conf_info_data.filt = filt;
    conf_info_data.same = same;
    conf_info_data.stride = stride;

    // Communication channels
    ac_channel<dma_info_t> dma_read_ctrl;
    ac_channel<dma_info_t> dma_write_ctrl;
    ac_channel<dma_data_t> dma_read_chnl;
    ac_channel<dma_data_t> dma_write_chnl;

    // Accelerator done (workaround)
    ac_sync acc_done;

    // Testbench data
    FPDATA_IN inputs[input_size * BATCH_MAX];
    FPDATA_OUT outputs[output_size * BATCH_MAX];
    double gold_outputs[output_size * BATCH_MAX];

    ESP_REPORT_INFO(VON, "Configuration:");
    ESP_REPORT_INFO(VON, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
    ESP_REPORT_INFO(VON, "  - n_w: %u", ESP_TO_UINT32(conf_info_data.n_w));
    ESP_REPORT_INFO(VON, "  - n_h: %u", ESP_TO_UINT32(conf_info_data.n_h));
    ESP_REPORT_INFO(VON, "  - n_c: %u", ESP_TO_UINT32(conf_info_data.n_c));
    ESP_REPORT_INFO(VON, "  - kern: %u", ESP_TO_UINT32(conf_info_data.kern));
    ESP_REPORT_INFO(VON, "  - filt: %u", ESP_TO_UINT32(conf_info_data.filt));
    ESP_REPORT_INFO(VON, "  - same: %u", ESP_TO_UINT32(conf_info_data.same));
    ESP_REPORT_INFO(VON, "  - stride: %u", ESP_TO_UINT32(conf_info_data.stride));
    ESP_REPORT_INFO(VON, "Other info:");
    ESP_REPORT_INFO(VON, "  - DMA width: %u", DMA_WIDTH);
    ESP_REPORT_INFO(VON, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
    ESP_REPORT_INFO(VON, "  - DATA width: %u", DATA_WIDTH);
    ESP_REPORT_INFO(VON, "  - Batch size: %u", input_size);
    ESP_REPORT_INFO(VON, "  - memory in (words): %u", input_size * ESP_TO_UINT32(conf_info_data.batch));
    ESP_REPORT_INFO(VON, "  - memory out (words): %u", output_size * ESP_TO_UINT32(conf_info_data.batch));
    ESP_REPORT_INFO(VON, "--------------------------------");
	
	// Debug
	ESP_REPORT_INFO(VOFF, "All good before load");

	// initialize random seed:
	//srand (time(NULL));

    // Pass inputs to the accelerator
    for (unsigned i = 0; i < conf_info_data.batch * input_size; i++) {
		//generate random input	
        FPDATA_IN data_fp = (i % 200) * 0.25 - 25;//(rand() % 200 - 100) * 0.25;

        inputs[i] = data_fp;

        ac_int<DMA_WIDTH, true> data_ac;
        ac_int<DMA_WIDTH/2, true> DEADBEEF = 0xdeadbeef;
        data_ac.set_slc(DMA_WIDTH/2, DEADBEEF.template slc<DMA_WIDTH/2>(0));
        data_ac.set_slc(0, inputs[i].template slc<DATA_WIDTH>(0));

        dma_read_chnl.write(data_ac);
    }
	// Debug
	ESP_REPORT_INFO(VOFF, "All good after load");
	
    // Pass configuration to the accelerator
    conf_info.write(conf_info_data);
	
	// Debug
	ESP_REPORT_INFO(VOFF, "All good after conf_info.write");

    // Run the accelerator
    conv2dlb_cxx_catapult(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

    // Fetch outputs from the accelerator
    while (!dma_write_chnl.available(conf_info_data.batch * output_size)) {} // Testbench stalls until data ready
    for (unsigned i = 0; i < conf_info_data.batch * output_size; i++) {
        // DMA_WIDTH = 64
        // discard bits in the range(63,32)
        // keep bits in the range(31,0)
        ac_int<DATA_WIDTH, true> data = dma_write_chnl.read().template slc<DATA_WIDTH>(0);
        outputs[i].template set_slc<32>(0, data);
    }

    // Validation
    
    ESP_REPORT_INFO(VON, "-----------------");
    for (unsigned i = 0; i < conf_info_data.batch; i++) {
        conv2dlb_tb(inputs + i * input_size, gold_outputs + i * output_size);
    }
    unsigned errors = 0;

    double allowed_error = 0.001;

    for (unsigned i = 0; i < conf_info_data.batch * output_size; i++) {
        float gold = gold_outputs[i];
        FPDATA_OUT data = outputs[i];

        // Calculate absolute error
        double error_it = abs_double(data.to_double() - gold);

        if (error_it > allowed_error) {
            ESP_REPORT_INFO(VON, "[%u]: %f (expected %f)", i, data.to_double(), gold);
            errors++;
        }
    }

    if (errors > 0) {
        ESP_REPORT_INFO(VON, "Validation: FAIL (errors %u / total %u)", errors, output_size);
        rc = 1;
    } else {
        ESP_REPORT_INFO(VON, "Validation: PASS");
        rc = 0;
    }
    ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, output_size * ESP_TO_UINT32(conf_info_data.batch));
    ESP_REPORT_INFO(VON, "-----------------");

    CCS_RETURN(rc);
}
