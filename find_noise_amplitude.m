function A = find_noise_amplitude(y, f_0, Fs)
y_clean = y(1:4*Fs);
Y_clean = 1/Fs * fft(y_clean);
y_w_all_noises = y(length(y) - 4*Fs + 1: length(y));
Y_w_all_noises = 1/Fs * fft(y_w_all_noises);

k = floor(f_0 * 4 + 0.5);
Y_clean_f_0 = Y_clean(k+1);
maxY_noises = Y_w_all_noises(k+1);

A = abs(maxY_noises - Y_clean_f_0) * 2 / 4;
end
