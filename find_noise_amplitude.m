function A = find_noise_amplitude(y, f_0, Fs)
y_clean = y(1:4*Fs);
y_w_all_noises = y(length(y) - 4*Fs + 1: length(y));
W = 1/Fs * (fft(y_w_all_noises) - fft(y_clean));

k = floor(f_0 * 4 + 0.5);
A = abs(W(k+1)) * 2 / 4;
end
