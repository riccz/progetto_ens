function [ b, a ] = notch_filter(fi, Fc, q)
bw = fi/q;
r = 1 - 2*pi*bw/Fc;
b = [1, -2*cos(2*pi*fi/Fc), 1];
a = [1, -2*r*cos(2*pi*fi/Fc), r^2];
end
