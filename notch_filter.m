function [ b, a ] = notch_filter(f_0, Fs, q)
bw = f_0/q;
r = 1 - 2*pi*bw/Fs;
b = [1, -2*cos(2*pi*f_0/Fs), 1];
a = [1, -2*r*cos(2*pi*f_0/Fs), r^2];
end
