function A = find_noise_amplitude(y, fi, Fc)
y_last = y(length(y) - 4*Fc + 1: length(y)); % Ultimi 4 secondi
Y_last = 1/Fc * fft(y_last);

k = floor(fi * 4 + 0.5);
maxY = abs(Y_last(k+1));

A = maxY * 2 / 4;
end
