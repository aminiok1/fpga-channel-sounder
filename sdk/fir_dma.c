/*
 * fir_dma.c
 *
 *  Created on: Aug 19, 2021
 *      Author: Amin
 */

#include "fir_dma.h"
#include "xparameters.h"
#include "xaxidma.h"



extern XAxiDma  AxiDmaReloadReal, AxiDmaConfigReal, AxiDmaReloadImag, AxiDmaConfigImag;

int reloadFilter(char filter_real[FILTER_SIZE], char filter_imag[FILTER_SIZE])
{
	int status;
	Xil_DCacheFlushRange((unsigned int) filter_real, sizeof(unsigned char) * FILTER_SIZE);

	// Transfer new filter coefficients to the IP block
	status = XAxiDma_SimpleTransfer(&AxiDmaReloadReal, (unsigned int) filter_real, sizeof(unsigned char)*FILTER_SIZE, XAXIDMA_DMA_TO_DEVICE);

	if(status != XST_SUCCESS)
	{
		print("Error: Transferring filters to the Accelerator");
		return XST_FAILURE;
	}

	while(XAxiDma_Busy(&AxiDmaReloadReal, XAXIDMA_DMA_TO_DEVICE));

	// Send Config packet to synchronize the new coefficient reload
	unsigned char config[1] = {0x00};
	status = XAxiDma_SimpleTransfer(&AxiDmaConfigReal, (unsigned int) config, sizeof(unsigned char), XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS)
	{
		print("Error: Transferring config to the Accelerator");
		return XST_FAILURE;
	}

	while(XAxiDma_Busy(&AxiDmaConfigReal, XAXIDMA_DMA_TO_DEVICE));

	// Send Imaginary Filters
	Xil_DCacheFlushRange((unsigned int) filter_imag, sizeof(unsigned char) * FILTER_SIZE);

	status = XAxiDma_SimpleTransfer(&AxiDmaReloadImag, (unsigned int) filter_imag, sizeof(unsigned char)*FILTER_SIZE, XAXIDMA_DMA_TO_DEVICE);

	if(status != XST_SUCCESS)
	{
		print("Error: Transferring filters to the Accelerator");
		return XST_FAILURE;
	}

	while(XAxiDma_Busy(&AxiDmaReloadImag, XAXIDMA_DMA_TO_DEVICE));

	// Send Config packet to synchronize the new coefficient reload
	status = XAxiDma_SimpleTransfer(&AxiDmaConfigImag, (unsigned int) config, sizeof(unsigned char), XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS)
	{
		print("Error: Transferring config to the Accelerator");
		return XST_FAILURE;
	}

	while(XAxiDma_Busy(&AxiDmaConfigImag, XAXIDMA_DMA_TO_DEVICE));

	return XST_SUCCESS;
}
