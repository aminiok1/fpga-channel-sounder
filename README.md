
Channel Sounder FPGA Implementation
=======================
This project implements the channel sounding technique on  Xilinx® Zedboard™ FPGA, it requires Xilinx Vivado Design Suit and SDK 2018.2 to be installed on the system.

# Folder Structure
    .
    ├── matlab           # scripts for the host communication with FPGA and plot generation
    ├── sdk              # ARM CPU source code
    ├── vivado
    │   └── bram_coe	   # coefficient files for BRAM initialization
    │   └── ip_repo		   # user defined IPs
    │   └── sim            # IP unit test files
    │   └── src            # tcl for block design generation
    │   └── build.tcl
    ├── LICENSE
    └── README.md
# Build and Run Instructions
The provided <code>build.tcl</code> script is used to generate a bitstream that we will run on the FPGA. The <code>sdk</code> directory contains the host source code that will be executed on the ARM CPU and configures parameters such as noise scale, number of accumulations, and the input sounding waveform. The ARM application will communicate with the host computer through UART by running the MATLAB script that will plot the signal received from the FPGA. 
<H2>Vivado</H2>
The provided <code>build.tcl</code> will create a new project and a block design that implements the channel sounder. In order to run the Tcl file, start Vivado Design Suite, switch to the directory with the Tcl file and simply run

```
$ source build.tcl
```
Alternatively, you can run the Tcl from Tools --> Run Tcl Script option.
When the Tcl run is finished, we need to initialize the BRAMs in the design (this step will be moved to the Tcl as well in the future):
Open the block design <code>channel_sounder</code> from Sources tab in Vivado and choose the corresponding coefficient file for the BRAMs listed below by double-clicking on the BRAM, enabling Load Init File from the Other Options tab, and selecting the .coe file located in the <code>bram_coe</code> directory:
```
blk_mem_gen_0 --> sounding_bram_fi_24_22.coe
blk_mem_gen_1 --> noise_bram_fi_32_24_4096.coe
blk_mem_gen_3 --> sounding_fd_bram_fi_32_24.coe
```
After that, we are ready to run the familiar Synthesis, Implementation, and Generate Bitstream steps to generate the .bit file that will be run on the FPGA.
<H2>SDK</H2>
Create a standalone project in Xilinx SDK using the provided source files in the <code>sdk</code> directory. The steps for exporting hardware and creating a project in SDK can be found
<a href="https://www.xilinx.com/html_docs/xilinx2019_1/SDK_Doc/SDK_tasks/sdk_t_export_hwspec.html">here</a>.
The <code>main.c</code> file can be used to configure some of the parameters that are used in the channel sounder. In order to modify the input sounding waveform initialize the <code>matlab_sounding_input</code> and <code>matlab_sounding_freq_input</code> arrays with the desired sounding waveform and its corresponding signal in the frequency domain (these signals can be generated using the provided MATLAB script as described in the next section). The noise scale and the number of accumulations can be set by <code>setNoiseScale()</code> and <code>setAccCount()</code> APIs. Finally, the number of filter taps and their values can be set in <code>setFilterTaps()</code> function for both real and imaginary taps.

<H2>MATLAB</H2>
Run the <code>channel_sounder_fpga.m</code> script by setting the correct COM port at the top of the file. Accumulation count, the noise scale, and number of FIR filter taps can be configured as well. After that, run the SDK project and wait for the magic to happen!

The <code>channel_sounder_fpga.m</code> script opens a serial port connection and waits for the results to be received from the FPGA. It compares the signal coming from the FPGA with the software model and computes the Mean Squared Error; finally, it plots both the FPGA and the software model PDPs. Notice that due to pseudo-randomness in the noise values, there might be a small error between the FPGA and the software results. 

In order to generate a new sounding waveform signal, uncomment line 20 (<code>generate_sounding_td</code>). This will generate a new input signal with the user provided signal pulse. After that, you need to update the corresponding variables in the SDK project by the values written in the <code>channel_sounder_input.txt</code> file.
# FPGA Architecture
The channel sounding technique can be used to evaluate the environment for wireless communication. This can be achieved through the following steps

* Generate a channel sounding waveform
*  Pass the waveform through an FIR filter to mimic multi-path interference using a known synthetic channel 
* Perform frequency domain correlation
* Compare the estimated power delay profile with the original signal to compute the impulse response of the FIR filter

On the FPGA, the processing system (PS) writes the sounding waveform along with its corresponding signal in the frequency domain to BRAMs on the programmable logic (PL). PL reads the sounding waveform in time domain and using two <code>fir_compiler</code> IP cores and a custom complex multiplier IP computes the real and imaginary response of the signal. The number of filter taps and their values in <code>fir_compiler</code> can be configured from PS using the <code>AXI memory mapped</code> interface. 
The response signal is passed to a custom noise generator IP that adds the pre-stored noise values on BRAM to the signal. In order to mimic noise randomness, the noise generator increases the read address offset of noise BRAM by 1 so that the results are not the same for each iteration. The noise strength can be configured from the PS.
The noisy signal is passed to an FFT module and the output is multiplied by the sounding waveform signal in frequency domain. Finally, the complex multiplication result is passed to an iFFT module to generate the power delay profile (PDP).
In order to remove the noise from PDP, an accumulator unit normalizes the results by accumulating the PDP results coming from the iFFT module for <em>n</em> iterations and then dividing the result by <em>n</em> and writing it to a BRAM. The accumulation count <em>n</em> can be configured from the PS. 
