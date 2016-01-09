function n = find_noise_start(y, fi, Fc, q_sel, ampl_thresh)
% Seleziona il ruomore a freq. fi
[b, a] = single_freq_filter(fi, Fc, q_sel);
y_noise = filter(b, a, y);

% Trova il campione in cui il rumore inizia a crescere
y_zero_max = max(abs(y_noise(1:4*Fc))); % Max nei primi 4 secondi (dove dovrebbe essere 0)
i = find(abs(y_noise) >= ampl_thresh * y_zero_max, 1);
n = i - 1;
end
