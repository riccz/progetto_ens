function [ b, a ] = single_freq_filter(fi, Fc, q)
bw = fi/q;
r = 1 - pi*bw/Fc;
b = 2*(1-r)*abs(sin(2*pi*fi/Fc));
a = [1, -2*r*cos(2*pi*fi/Fc), r^2];
end
