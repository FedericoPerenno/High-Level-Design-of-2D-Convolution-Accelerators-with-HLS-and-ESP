/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __riscv
#include <stdio.h>
#include <stdlib.h>
#endif

#include <fixed_point.h>

#include <esp_accelerator.h>
#include <esp_probe.h>

//typedef int32_t token_t;
typedef int64_t token_t;

static inline uint64_t get_counter()
{
	uint64_t counter;
	asm volatile (
		"li t0, 0;"
		"csrr t0, mcycle;"
		"mv %0, t0"
		: "=r" ( counter )
		:
		: "t0"
    );
    return counter;
}

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
    return (sizeof(void *) / _st);
}


#define SLD_CONV2DLB_CXX 0x058
#define DEV_NAME "sld,conv2dlb_cxx_catapult"


/* <<--params-->> */
const int32_t batch = 1;
const int32_t n_w = 5;
const int32_t n_h = 5;
const int32_t n_c = 3;
const int32_t kern = 3;
const int32_t filt = 3;
const int32_t same = 0;
const int32_t stride = 1;

const uint8_t pad = ((stride * (n_w - 1) - n_w + kern) / 2) * same;
const uint8_t n_w_in = n_w + 2 * pad;
const uint8_t n_h_in = n_h + 2 * pad;
const uint8_t n_w_out = (n_w + 2 * pad - kern)/(stride) + 1;
const uint8_t n_h_out = (n_w + 2 * pad - kern)/(stride) + 1;

const uint16_t IN_SIZE = n_w * n_h * n_c + kern * kern * n_c * filt;
const uint16_t OUT_SIZE = n_w_out * n_h_out * filt;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;

//const int32_t size = 128;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define CONV2DLB_CXX_STRIDE_REG 0x5c
#define CONV2DLB_CXX_SAME_REG 0x58
#define CONV2DLB_CXX_FILT_REG 0x54
#define CONV2DLB_CXX_KERN_REG 0x50
#define CONV2DLB_CXX_N_C_REG 0x4c
#define CONV2DLB_CXX_N_H_REG 0x48
#define CONV2DLB_CXX_N_W_REG 0x44
#define CONV2DLB_CXX_BATCH_REG 0x40

float abs_float(const float input)
{
    return input < 0 ? -input : input;
}

float allowed_error = 0.001;

static int validate_buf(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;

#ifndef __riscv
	printf("  gold output data @%p\n", gold);
	printf("       output data @%p\n", out);
#else
	print_uart("  gold output data @"); print_uart_addr((uintptr_t) gold); print_uart("\n");
	print_uart("       output data @"); print_uart_addr((uintptr_t) out); print_uart("\n");
#endif

	for (i = 0; i < batch; i++) {
		for (j = 0; j < OUT_SIZE; j++)
        {
            token_t gold_data_fxd = gold[i * out_words_adj + j];
            token_t out_data_fxd = out[i * out_words_adj + j];
            float gold_data_flt = fixed32_to_float(gold_data_fxd, 16);
            float out_data_flt = fixed32_to_float(out_data_fxd, 16);
            float error_it = abs_float(gold_data_flt - out_data_flt);

			if (error_it > allowed_error)
            {
				errors++;
            }
#if 0
#ifndef __riscv
        	printf("  [%X, %X] data %lX / gold %lX\n", i, j, out_data_fxd, gold_data_fxd);
#else
        	print_uart("  [");
            print_uart_int((uint32_t)i);
            print_uart(",");
            print_uart_int((uint32_t)j);
            print_uart("] data ");
            print_uart_int64(out_data_fxd);
            print_uart(" / gold ");
            print_uart_int64(gold_data_fxd);
			if (error_it > allowed_error)
                print_uart(" *** ERROR ***");
            print_uart("\n");
#endif
#endif
        }
    }

#ifndef __riscv
	printf("  total errors %u\n", errors);
#else
	print_uart("  total errors "); print_uart_int(errors); print_uart("\n");
#endif

	return errors;
}

static void conv2dlb_sw(token_t *input, token_t *output)
{
    
    float localGold[n_w_out * n_h_out * filt];
	float paddedBuffer[n_w_in * n_h_in * n_c];
	unsigned indexInp = (kern * kern * n_c * filt);  
	
    //Padding        
	for (unsigned chan = 0; chan < n_c; chan++)
    {
		for (unsigned row = 0; row < n_w_in; row++)
		{
			for (unsigned col = 0; col < n_h_in; col++)
			{
				float data;	
				if ((row >= pad) && (col >= pad) && (col < n_h_in - pad) && (row < n_w_in - pad))
				{

					data = fixed32_to_float(input[indexInp], 16);
					indexInp++;
				 }
				else{	
					data = 0;
				}			
				unsigned index_pad = chan * n_w_in * n_h_in + row * n_h_in + col; 
				paddedBuffer[index_pad] = data;
			}
		}
	}
	
    unsigned x, y;
    // Set golden output
    for (unsigned fl = 0; fl < filt; fl++)
    {
		for (unsigned i = 0; i < n_w_out; i++)
		{
	 	    for (unsigned j = 0; j < n_h_out; j++)
			{
				float acc = 0;
				x = i * stride;
				y = j * stride;

				for (unsigned m = 0; m < kern; m++)
				{
					for (unsigned n = 0; n < kern; n++)
					{
						for (unsigned k = 0; k < n_c; k++)
						{
							// Convolute here.
							unsigned index1, index2;
							index1 = fl * kern * kern * n_c + k * kern * kern + m * kern + n; //filter
							index2 = n_w_in * n_h_in * k + x * n_w_in + y; //padded input
				
							float weight = fixed32_to_float(input[index1], 16);
							acc +=  weight * paddedBuffer[index2];
						}
						y++; // Move right by one position (s=1)
					}
					x++; // Move down by one position (s=1)
					y = j * stride; // Restart column position
				}
				unsigned index3 = n_w_out * n_h_out * fl + i * n_w_out + j;
				if (acc >= 32768)
					localGold[index3] = 32767.999985;
				else if (acc < -32768)
					localGold[index3] = - 32768;
				else
					localGold[index3] = acc; // Add result to output matrix		
			}
        }
    }
    
    for (unsigned j = 0; j < OUT_SIZE; j++) {
        float data_flt = localGold[j];
        token_t data_fxd = float_to_fixed32(data_flt, 16);
		output[j] = 0xdeadbeef00000000 | (token_t) data_fxd;		
	}
}


static void init_buf (token_t *in, token_t * gold)
{
	int i;
	int j;

#ifndef __riscv
	printf("  input data @%p\n", in);
#else
	print_uart("       input  data @"); print_uart_addr((uintptr_t) in); print_uart("\n");
#endif
	
	
	// initialize input
	for (i = 0; i < batch; i++)
    {
		for (j = 0; j < IN_SIZE; j++)
        {
            float data_flt = ((i * IN_SIZE + j) % 200) * 0.25 - 25;
            token_t data_fxd = 0xdeadbeef00000000 | float_to_fixed32(data_flt, 16);
			in[i * in_words_adj + j] = (token_t) data_fxd;
        }
    }
	
	// intalize golden input
	for (i = 0; i < batch; i++)
    {
    	uint64_t start, end, time;
    	start = get_counter();
    	
        conv2dlb_sw(in + (i*IN_SIZE), gold + (i*OUT_SIZE));
        
        end = get_counter();
        time = end - start;      
#ifndef __riscv
		printf("  Software elapsed time = %lu\n", time);
#else
		print_uart("  Software elapsed time = "); print_uart_int((uint64_t)time); print_uart("\n");
#endif
    }

#ifndef __riscv
	printf("  gold output data @%p\n", gold);
#else
	print_uart("  gold output data @"); print_uart_addr((uintptr_t) gold); print_uart("\n");
#endif
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	unsigned **ptable;
	token_t *mem;
	token_t *gold;
	unsigned errors = 0;

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = IN_SIZE;
		out_words_adj = OUT_SIZE;
	} else {
		in_words_adj = round_up(IN_SIZE, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(OUT_SIZE, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}

    in_len = in_words_adj * (batch);
	out_len = out_words_adj * (batch);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_len;
	mem_size = in_size + out_size;

	// Search for the device
#ifndef __riscv
	printf("Scanning device tree... \n");
#else
	print_uart("Scanning device tree... \n");
#endif

	ndev = probe(&espdevs, VENDOR_SLD, SLD_CONV2DLB_CXX, DEV_NAME);

#ifndef __riscv
	printf("Found %d devices: %s\n", ndev, DEV_NAME);
#else
	print_uart("Found "); print_uart_int(ndev); print_uart(" devices: sld,conv2dlb_cxx\n");
#endif

	if (ndev == 0) {
#ifndef __riscv
		printf("conv2dlb_cxx not found\n");
#else
		print_uart("conv2dlb_cxx not found\n");
#endif
		return 0;
	}


#if 1
	// Allocate memory
	gold = aligned_malloc(out_size);
	mem = aligned_malloc(mem_size);
#ifndef __riscv
	printf("  memory buffer base-address = %p\n", mem);
#else
	print_uart("  memory buffer base-address = "); print_uart_addr((uintptr_t) mem); print_uart("\n");
#endif

	// Alocate and populate page table
	ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(mem_size); i++)
		ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
#ifndef __riscv
	printf("  ptable = %p\n", ptable);
	printf("  nchunk = %lu\n", NCHUNK(mem_size));
#else
	print_uart("  ptable = "); print_uart_addr((uintptr_t) ptable); print_uart("\n");
	print_uart("  nchunk = "); print_uart_int(NCHUNK(mem_size)); print_uart("\n");
#endif

#ifndef __riscv
	printf("  Generate input...\n");
#else
	print_uart("  Generate input...\n");
#endif

    init_buf(mem, gold);

#ifndef __riscv
	printf("  ... input ready!\n");
#else
	print_uart("  ... input ready!\n");
#endif

	// Pass common configuration parameters
#endif

	for (n = 0; n < ndev; n++) {

		dev = &espdevs[n];

		// Check DMA capabilities
		if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
#ifndef __riscv
			printf("  -> scatter-gather DMA is disabled. Abort.\n");
#else
			print_uart("  -> scatter-gather DMA is disabled. Abort.\n");
#endif
			return 0;
		}

		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
#ifndef __riscv
			printf("  -> Not enough TLB entries available. Abort.\n");
#else
			print_uart("  -> Not enough TLB entries available. Abort.\n");
#endif
			return 0;
		}
		
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

#ifndef __sparc
		iowrite32(dev, PT_ADDRESS_REG, (unsigned long long) ptable);
#else
		iowrite32(dev, PT_ADDRESS_REG, (unsigned) ptable);
#endif
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		//iowrite32(dev, SRC_OFFSET_REG, 0x0);
		//iowrite32(dev, DST_OFFSET_REG, 0x0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
		iowrite32(dev, CONV2DLB_CXX_BATCH_REG, batch);
		iowrite32(dev, CONV2DLB_CXX_N_W_REG, n_w);
		iowrite32(dev, CONV2DLB_CXX_N_H_REG, n_h);
		iowrite32(dev, CONV2DLB_CXX_N_C_REG, n_c);
		iowrite32(dev, CONV2DLB_CXX_KERN_REG, kern);
		iowrite32(dev, CONV2DLB_CXX_FILT_REG, filt);
		iowrite32(dev, CONV2DLB_CXX_SAME_REG, same);
		iowrite32(dev, CONV2DLB_CXX_STRIDE_REG, stride);

		// Flush (customize coherence model here)
		esp_flush(ACC_COH_NONE);

		// Start accelerators
#ifndef __riscv
		printf("  Start...\n");
#else
		print_uart("  Start...\n");
#endif
		uint64_t start, end, time;
		
		// Wait for completion
		done = 0;
		
		// Run accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);
		
		start = get_counter();  
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}
		end = get_counter();
		iowrite32(dev, CMD_REG, 0x0);
		
		time = end - start;    
#ifndef __riscv
		printf("  Accelerator elapsed time = %lu\n", time);
#else
		print_uart("  Accelerator elapsed time = "); print_uart_int((uint64_t)time); print_uart("\n");
#endif

#ifndef __riscv
		printf("  Done\n");
		printf("  validating...\n");
#else
		print_uart("  Done\n");
		print_uart("  validating...\n");
#endif

		/* Validation */
		errors = validate_buf(&mem[out_offset], gold);
#ifndef __riscv
		if (errors)
			printf("  ... FAIL\n");
		else
			printf("  ... PASS\n");
#else
		if (errors)
			print_uart("  ... FAIL\n");
		else
			print_uart("  ... PASS\n");
#endif

		aligned_free(ptable);
		aligned_free(mem);
		aligned_free(gold);
	}

#ifndef __riscv
	printf("DONE\n");
#else
    print_uart("DONE\n");
#endif

	return 0;
}
