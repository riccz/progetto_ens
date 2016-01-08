function f_0 = find_noise(y, Fs, min_thresh)
min_max_dft = 0.1 * 4 / 2; % Ampiezza minima dei picchi dei rumori
y_last = y(length(y)-4*Fs+1:length(y)); % Ultimi 4 secondi
Y_last = 1/Fs * fft(y_last);
[dft_max, i_max] = max(abs(Y_last));
if dft_max >= min_max_dft * min_thresh;
    f_0 = (i_max-1)/4;
else
    f_0 = NaN;
end
end
