/*
 * fir_dma.h
 *
 *  Created on: Aug 19, 2021
 *      Author: Amin
 */

#ifndef SRC_FIR_DMA_H_
#define SRC_FIR_DMA_H_

#define FILTER_SIZE		16

#define DATA_IN_F	22
#define FIR_F		24
#define SCALE_F		16
#define DATA_OUT_F	24
#define FILTER_F	2

int reloadFilter(char filter_real[FILTER_SIZE], char filter_imag[FILTER_SIZE]);

#endif /* SRC_FIR_DMA_H_ */
