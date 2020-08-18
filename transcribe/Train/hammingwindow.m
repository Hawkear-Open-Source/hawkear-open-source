function [x] = hammingwindow(N)
% HAMMINGWINDOW returns the coeffs of a hamming window of length N
    x = 0.54 - 0.46 * cos (2 * pi * (0 : N-1)' / (N-1));
end