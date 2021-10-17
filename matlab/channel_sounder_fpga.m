% This line needs to be called only once
device = serialport("COM4",115200);

% Connect to Serial Port
device.Timeout = 60;

% Set terminator character
configureTerminator(device, "LF");

% Definitions
nFFT = 1024;
ACC_COUNT = 1;
NOISE_SCALE = 10;

% Load noise data from file
noise_main = load_noise() .* NOISE_SCALE;

% Generate a new sounding waveform in time domain
% Input arguments: min and max frequency
%sounding = generate_sounding_td(-128, 128);
sounding = load_sounding_td();
sounding_fd = conj(fft(sounding));

% Replicate the sounding signal for fir function
sounding_rep = [sounding; sounding; sounding];

% Create a filter and set taps
fir_real = zeros(1, 16); fir_imag = zeros(1, 16);
fir_filter = complex(fir_real, fir_imag);
fir_filter(1) = complex(1, 0);
%fir_filter(11) = complex(1, 0);

% FIR filter
conv = filter(fir_filter, 1, sounding_rep);
conv = conv(1025: 2048);

recovered_acc = complex(zeros(1, nFFT), 0);
noise_offset = 1;

for i=1:ACC_COUNT
    
    noise = noise_main(noise_offset: noise_offset + 1023) ;

    % Add noise
    conv_noise = conv + (noise);

    % FFT
    conv_noise_fft  = fft(conv_noise);

    % IFFT
    recovered = ifft(sounding_fd .* conv_noise_fft);
    
    % Accumulation
    recovered_acc = recovered_acc + recovered';
    
    noise_offset = noise_offset + 1;
    
    if noise_offset == 1024
        noise_offset = 1;
    end
    
end

recovered_acc = recovered_acc ./ ACC_COUNT;

% x axis for the plot
t = linspace(-nFFT/2, nFFT/2 - 1, nFFT);

% Array for storing FPGA results
fpgaOutput = complex(zeros(1, nFFT), 0);

write_to_file(sounding, sounding_fd);

for i = 1:nFFT

    % Read real and imaginary parts and store them in the array
    a_r = str2double(readline(device));
    a_i = str2double(readline(device));

    fpgaOutput(i) = complex(a_r, a_i);
end

plot(t, fftshift(abs(fpgaOutput)), 'r', t, fftshift(abs(recovered_acc)), 'b');
legend("FPGA", "Matlab");

DReal = abs(real(fpgaOutput) - real(recovered_acc)).^2;
DImag = abs(imag(fpgaOutput) - imag(recovered_acc)).^2;

fprintf("real part error = %f%%, imaginary part error = %f%%\n", sum(DReal(:))/nFFT * 100, sum(DImag(:))/nFFT * 100);


plot(t, fftshift(abs(recovered_acc)), 'r', t, fftshift(abs(fpgaOutput)), 'b');
%[pk, max_freq] = findpeaks(fftshift(abs(fpgaOutput)), 'MinPeakDistance', 1, 'NPeaks', 5, 'SortStr', 'descend');
%pk_ratio = pk ./ pk(1);

%for i=1:length(pk)
%    fprintf ('Peak %d Value = %f, Location = %d, Amplitude Ratio = %f\n', i, pk(i), max_freq(i)-513, pk_ratio(i));
%end

% utility functions
function noise = load_noise()

fileID = fopen("matlab_noise_real.txt", 'r');
noise_real = fscanf(fileID, "%f ", 2048);
fclose(fileID);

fileID = fopen("matlab_noise_imag.txt", 'r');
noise_img = fscanf(fileID, "%f ", 2048);
fclose(fileID);

noise = complex(noise_real, noise_img);

end

function sounding = load_sounding_td()

fileID = fopen("matlab_soundingtd_real.txt", 'r');
sounding_real = fscanf(fileID, "%f ", 1024);
fclose(fileID);

fileID = fopen("matlab_soundingtd_imag.txt", 'r');
sounding_imag = fscanf(fileID, "%f ", 1024);
fclose(fileID);

sounding = complex(sounding_real, sounding_imag);

end

function sounding = generate_sounding_td(scMin, scMax)

nFFT = 1024;
constellation_qpsk = [1+1i -1+1i 1-1i -1-1i];

sounding_fd = zeros(1, nFFT);
for fd_idx=scMin:scMax
    sounding_fd(nFFT/2 + 1 + fd_idx) = constellation_qpsk(randi(4));
end
sounding_fd = fftshift(sounding_fd);
sounding = ifft(sounding_fd);     % Sounding waveform in time domain (sinc function)
sounding = sounding';
end

function write_to_file(sounding_data, sounding_data_fd)

fileID = fopen('channel_sounder_input.txt','w');

for i = 1:1024
    fprintf(fileID, "%f, %f, ", real(sounding_data(i)), imag(sounding_data(i)));
end

fprintf(fileID, "\n");

for i = 1:1024
    fprintf(fileID, "%f, %f, ", real(sounding_data_fd(i)), imag(sounding_data_fd(i)));
end

fprintf(fileID, "\n");

%for i = 1:1024
%    fprintf(fileID, "%f, %f, ", real(result(i)), imag(result(i)));
%end

fclose(fileID);

end
