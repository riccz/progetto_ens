function A = find_noise_amplitude(y, f_0, Fs, q, n_0)
[b, a] = single_freq_filter(f_0, Fs, q);
y_noise = filter(b, a, y);

y_noise_only = y_noise(n_0+1:length(y));
E = sum(abs(y_noise_only).^2);
S = sum(cos(4*pi*f_0/Fs * (0:length(y_noise_only)-1)));
A = sqrt(2*E/(length(y_noise_only) + S));
end
