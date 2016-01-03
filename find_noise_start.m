function n_0 = find_noise_start(y, f_0, Fs, q, thresh)
[b, a] = single_freq_filter(f_0, Fs, q);
y_noise = filter(b, a, y);

y_sig_max = max(abs(y_noise(1:4*Fs))); % Max nei primi 4 secondi
i_0 = find(abs(y_noise) >= thresh * y_sig_max, 1);
n_0 = i_0 - 1;
end
