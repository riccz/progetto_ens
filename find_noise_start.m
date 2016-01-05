function n_0 = find_noise_start(y, f_0, Fs, q, thresh)
% Seleziona il ruomore a freq. f_0
[b, a] = single_freq_filter(f_0, Fs, q);
y_noise = filter(b, a, y);

% Trova il campione in cui il rumore inizia a crescere
y_zero_max = max(abs(y_noise(1:4*Fs))); % Max nei primi 4 secondi (dove dovrebbe essere 0)
i_0 = find(abs(y_noise) >= thresh * y_zero_max, 1);
n_0 = i_0 - 1;
end
