function [ b, a ] = single_freq_filter(f_0, Fs, q)
bw = f_0/q;
r = 1 - pi*bw/Fs;
b = 2*(1-r)*abs(sin(2*pi*f_0/Fs));
a = [1, -2*r*cos(2*pi*f_0/Fs), r^2];
end
