function f_0 = find_noise(y, Fs, dft_thresh)
% Trova l'ampiezza max della DFT nei primi 4 secondi
y_clean = y(1:4*Fs);
Y_clean = 1/Fs * fft(y_clean);
Y_clean_max = max(abs(Y_clean));

% Trova un rumore negli ultimi 4 secondi se la DFT è più grande
y_last = y(length(y)-4*Fs+1:length(y));
Y_last = 1/Fs * fft(y_last);
[dft_max, i_max] = max(abs(Y_last));
if dft_max >= dft_thresh * Y_clean_max
    f_0 = (i_max-1)/4;
else
    f_0 = NaN;
end
end
